# Netrunner Godot Engine API

Headless Godot 4.3+ port of the Jinteki.net (`mtgred/netrunner`) Clojure core.
This document is the contract for translating the ~1900 card implementations
against the engine.

Clojure keyword keys (`:title`, `:cost`) become **plain strings** (`"title"`, `"cost"`).
Namespaced cost keys are kept as strings: `"cost/type"`, `"cost/amount"`.

## Running headless

```bash
godot --headless --path netrunner-godot res://tests/headless_sim.tscn
```

`project.godot` already points `run/main_scene` at that smoke test. Autoload
`NR` (`scripts/nr.gd`) is a Node facade; game logic lives in `class_name NR*`
modules under `scripts/engine/` and `scripts/cards/`.

Minimal boot:

```gdscript
NRCardsBasic.register()          # Corp/Runner basic actions
var state := NRSetUp.init_game({
    "skip-mulligan": true,
    "players": [
        {"side": "Corp", "user": {"username": "Corp"}, "deck": {"identity": {"title": "Custom Biotics: Engineered for Success"}, "cards": [...]}},
        {"side": "Runner", "user": {"username": "Runner"}, "deck": {"identity": {"title": "The Professor: Keeper of Knowledge"}, "cards": [...]}},
    ],
})
NRProcessActions.process_action("start-turn", state, "corp")
NRProcessActions.process_action("credit", state, "corp")
```

## State model

`NRState` wraps a mutable Dictionary (`state.data`), Clojure `@state` / `swap!`.

| Path | Meaning |
|---|---|
| `corp` / `runner` | Player records (`NRPlayer.new_corp` / `new_runner`) |
| `corp.servers.hq\|rd\|archives` | `{content: [], ices: []}` plus `remoteN` |
| `runner.rig` | `{hardware, program, resource, facedown}` |
| `active-player`, `turn`, `end-turn` | Turn flags |
| `run` | Current run or `null` |
| `encounters` | ICE encounter stack |
| `events`, `effects`, `queued-events` | Registered handlers / lingering effects |
| `effect-completed` | eid continuation table |
| `winner` / `reason` | Win state |

Player defaults: Corp 3 clicks / 5 credits / 7 agenda points; Runner 4 clicks / 5 credits / 4 MU / 7 agenda points.

Accessors: `getv` / `setv` / `get_in` / `assoc_in` / `update_in` / `dissoc_in` / `side_get`.

## Card-def dictionary

Register with `NRCardDefs.defcard(title, cdef)`. Runtime cards are dictionaries
produced by `NRInitializing.make_card`, carrying a `cid` plus printed fields.

```gdscript
{
    "title": "Wall of Static",
    "type": "ICE",                 # ICE | Agenda | Asset | Upgrade | Operation | Event | Program | Hardware | Resource | Identity | Basic Action
    "side": "Corp",                # Corp | Runner
    "faction": "Neutral",
    "cost": 3,
    "strength": 3,                 # ICE / breakers
    "advancementcost": 3,          # agendas
    "agendapoints": 2,
    "trash": 3,                    # trash cost
    "memoryunits": 1,
    "keywords": "Barrier",         # printed string and/or:
    "subtypes": ["Barrier"],
    "text": "...",
    "uniqueness": false,
    "implementation": "full",      # or a string warning
    # --- hooks (Callables or nested ability maps) ---
    "abilities": [ability, ...],
    "subroutines": [ability, ...],
    "events": [{"event": "runner-turn-begins", "req": Callable, "effect": Callable, "duration": "default-duration", "location": ["servers"]}],
    "static-abilities": [{"type": "ice-strength", "req": Callable, "value": 1}],
    "on-play": ability,            # events / operations
    "on-rez": ability,
    "on-install": ability,
    "on-score": ability,
    "on-steal": ability,
    "on-access": ability,
    "on-encounter": ability,
    "on-approach": ability,
    "expend": ability,
    "data": {"counter": {"virus": 0, "power": 0}},
    "flags": {},
    "additional-cost": [NRPayment.to_c("click")],
    "leave-play": Callable,
    "suppress": [{"event": "...", "req": Callable}],
}
```

### Ability maps

```gdscript
{
    "async": true,                 # must call NREid.effect_completed / checkpoint
    "req": Callable,               # (state, side, eid, card, targets) -> bool
    "cost": [NRPayment.to_c("click"), NRPayment.to_c("credit", 2)],
    "msg": "gain 1 [Credits]",     # or Callable -> String, or "cost"
    "effect": Callable,            # (state, side, eid, card, targets)
    "once": "per-turn",            # or per-run / per-encounter
    "once-key": "optional-id",
    "label": "Gain 1 [Credits]",
    "action": true,                # basic click action; blocked during a run
    "prompt": "Choose a card",
    "choices": ["Yes", "No"] | {"req": Callable, "max": 1} | {"number": 5},
    "waiting-prompt": true,
    "optional": { "prompt": "...", "yes-ability": {}, "no-ability": {} },
    "psi": { "equal": ability, "not-equal": ability },
    "trace": { "base": 3, "successful": ability, "unsuccessful": ability },
    "player": "corp",              # who sees the prompt
}
```

**5-function convention:** every `req` / `effect` / `msg` Callable is
`(state: NRState, side: Variant, eid: Dictionary, card: Variant, targets: Variant)`.
`targets` is an Array; the first Dictionary is the Clojure `context`
(`NRUtil.ability_context(targets)`). Basic install/play/run pass
`{ "card": ..., "server": ... }` as that context.

Use `NRDefHelpers` (`end_the_run`, `do_net_damage`, `gain_credits_ability`, …)
when translating card files.

## Async / eids

```gdscript
var eid := NREid.make_eid(state, {"source": card, "source-type": "ability"})
NREid.wait_for(state, eid, func(ne):
    NRGaining.gain_credits(state, side, ne, 1)
, func(result):
    NREid.effect_completed(state, side, eid)
)
```

- `make_eid` copies parent keys and assigns a new integer `"eid"`.
- Completing an eid runs its registered continuation (Clojure `effect-completed`).
- `NREngine.checkpoint(state, eid)` flushes queued events, uniqueness/MU, win-by-agenda, empty remotes, then completes `eid`.
- Sync abilities (no `"async": true`) are completed by the engine after `effect`.

## Commands (`NRProcessActions.process_action`)

| command | handler |
|---|---|
| `start-turn` / `end-turn` | turn structure |
| `credit` / `draw` | basic click-credit / click-draw |
| `play` | install or play instant from hand (`args.card`, optional `args.server`) |
| `run` | click-run (`args.server`: `"hq"` / `"HQ"` / `"rd"` / `"archives"` / `"remote1"`) |
| `rez` / `derez` | rez ICE/asset/upgrade |
| `advance` / `score` | advancement / scoring |
| `continue` | run pipeline (both players must continue most phases) |
| `jack-out` | end the run unsuccessfully |
| `ability` | paid ability (`args.card`, `args.ability` index) |
| `subroutine` / `unbroken-subroutines` | fire ICE subs |
| `choice` / `select` | resolve prompts |
| `purge` / `remove-tag` / `trash-resource` | remaining basic actions |
| `keep` / `mulligan` | opening hand |
| `concede` / `change` / `expend` | misc |

## Run pipeline

`initiation` → (if ice) `approach-ice` → `encounter-ice` → `movement` → (repeat) → `approach-server` → `success` → `NRAccess.breach_server` → `run-ends`.

Unrezzed ice is approached then passed without an encounter. `NRRuns.continue_run` implements the two-player “no further action” click.

## Module index (`scripts/engine/`)

| Class | Role |
|---|---|
| `NREngine` | `resolve_ability`, events, `pay`, `checkpoint`, `queue_event` |
| `NREid` | continuations |
| `NRState` / `NRPlayer` / `NRCard` / `NRCardDefs` | data model |
| `NRSetUp` | `init_game` |
| `NRProcessActions` / `NRActions` | command dispatch |
| `NRTurns` | start/end turn, phase 1.2, discard |
| `NRPayment` / `NRCosts` / `NRCostFns` | costs (`to_c`, `can_pay`, `merge_costs`) |
| `NRInstalling` / `NRRezzing` / `NRMoving` / `NRHosting` | board movement |
| `NRInitializing` | `make_card`, `card_init`, deactivate |
| `NRRuns` / `NRIce` / `NRAccess` | runs, ICE, access/steal |
| `NRDamage` / `NRPrevention` | damage + prevention windows (numeric remaining; full simultaneous UI deferred) |
| `NRPsi` / `NRTrace` | psi games / traces |
| `NRGaining` / `NRDrawing` / `NRShuffling` | resources |
| `NRTags` / `NRBadPublicity` / `NRAgendas` / `NRWinning` | scoring / tags / win |
| `NREffects` / `NREvents` / `NRFlags` | lingering effects, event bus, permission flags |
| `NRPrompts` / `NRPromptState` | Yes/No, select, number, waiting |
| `NRMemory` / `NRHandSize` / `NRLink` / `NRVirus` | runner attributes |
| `NROptional` / `NRExpend` / `NRDefHelpers` / `NRChooseOne` | card-authoring helpers |
| `NRCardsBasic` | Corp/Runner basic action cards |

### Engine surface (most used)

```
NREngine.resolve_ability(state, side, eid_or_ability, ability_or_card, card, targets)
NREngine.resolve_ability_eid(state, side, eid, ability, card, targets)
NREngine.continue_ability(state, side, ability, card, targets)
NREngine.pay(state, side, eid, card, costs)
NREngine.trigger_event / trigger_event_sync / trigger_event_simult
NREngine.queue_event / queue_event_and_resolve / checkpoint / fake_checkpoint
NREngine.register_events / unregister_events / register_ability_type
NRPayment.to_c(type, n=1) / can_pay / has_enough / merge_costs
NRInstalling.corp_install / runner_install / corp_can_pay_and_install / runner_can_pay_and_install
NRRuns.make_run / continue_run / jack_out / end_run
NRIce.add_sub / break_subroutine_bang / resolve_subroutine / update_all_ice
NRAccess.access_card / breach_server / steal
NRDamage.damage(state, side, eid, "net"|"meat"|"brain", n)
NRMoving.move / trash / trash_cards
NRGaining.gain_credits / lose_credits / gain_clicks
NRDrawing.draw
NRRezzing.rez / derez
NRProps.add_counter / add_prop
```

Clojure `update!` is `NRUpdate.update_card` (alias `NRUpdate.update`).
Clojure `shuffle!` is `NRShuffling.shuffle_zone`.

## Simplified or deferred

- Prevention windows are numeric remaining + lingering `:prevent-*` effects, not the full simultaneous prompt UI.
- `trigger_event_simult` currently resolves handlers sequentially.
- Sabotage auto-picks HQ then R&D (no choice prompt).
- Virus-counter picking auto-spends rather than prompting.
- `diffs.gd` only strips opponent hand/deck; spectator/replay diffs are omitted.
- `quick_draft.clj` / `turmoil.clj` and the Clojure `web/` + `tasks/` layers are not ported.
- Slash commands (`/credit`, `/click`, …) cover the playtest subset.
- Individual card implementations (~1900) are **not** in this tree — only basic actions plus smoke-test stubs.

Card translators should `NRCardDefs.defcard(title, cdef)` and keep ability
Callables on this 5-fn contract; the engine will install, rez, score, and fire
them without further wiring.
