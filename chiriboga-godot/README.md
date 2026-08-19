# Chiriboga (Netrunner: Solo Mode) — Godot 4 port

A GDScript port of **[Chiriboga](https://github.com/drbo6/chiriboga)** / [Netrunner: Solo Mode](https://chiriboga.cronbach.com). You play Android: Netrunner against a Corp AI (or watch AI vs AI) in a CRT-green terminal UI.

This is a fan project. *Netrunner* and *Android* are trademarks of Fantasy Flight Publishing, Inc. and/or Wizards of the Coast LLC. Card text is from Null Signal Games' System Gateway (and one Core Set ice) as used by Chiriboga. Not affiliated with FFG, WotC, or Null Signal Games.

The original JS engine is GPL-3.0; this port follows the same license.

## How to run

1. Install **[Godot 4.3+](https://godotengine.org/download)** (standard build, not C#).
2. Open Godot → **Import** → select `chiriboga-godot/project.godot` (or drag the `chiriboga-godot` folder onto the project list).
3. Press **F5** (Run Project). The main scene is `scenes/main.tscn`.

From a terminal:

```bash
godot --path chiriboga-godot
# or, if the binary is not on PATH:
godot4 --path /absolute/path/to/chiriboga-godot
```

Headless AI vs AI smoke test:

```bash
godot --headless --path chiriboga-godot res://tests/headless_sim.tscn
```

### Controls

| Input | Action |
| --- | --- |
| Click action buttons (right column) | Play / install / run / rez / break / … |
| Click a card in hand or on a server | Inspect printed text |
| **R** | Return to the mode menu |
| **A** | Toggle Runner AI (useful mid-game) |

Start menu:

- **Play as Runner** vs Corp AI (default Chiriboga experience)
- **Play as Corp** vs Runner AI
- **Watch AI vs AI**

## What is implemented

Core loop, using System Gateway starter identities (**The Catalyst** vs **The Syndicate**):

- 3 clicks per turn, credits, draw, discard to grip/HQ limit (5, modified by brain damage / Superconducting Hub)
- Runner: stack / grip / heap, MU, programs / hardware / resources, tags, steal agendas
- Corp: HQ, R&D, Archives, two starting remotes (more can be created), ice, rez, advance, score
- Runs: approach ice → optional rez → encounter (boost / break / bioroid click-break) → subroutines → jack out or continue → approach server → access
- Access: HQ (random, plus extra-access effects), R&D (top), Archives (all), remotes (root). Steal agendas, trash for trash cost, ambush damage
- Damage (meat / net / brain), flatline, tags, bad publicity (credits on run), influence values on cards
- Win: **7 agenda points** (either side) or Corp win on Runner flatline / negative hand size; Runner win if Corp decks out
- Trace mechanic (Hunter: Trace[3] → tag)
- Data-driven cards: add an entry in `scripts/data/card_db.gd` (ops + flags). No per-card subclass required
- Corp AI: scores, advances agendas, ices scoring servers, rezzes economy, Hedge Fund / Seamless Launch, rez-on-approach
- Runner AI: economy + breakers, then runs weak remotes / centrals
- CRT UI: green-on-black monospace, scanlines, event log, status bar

### Cards (41, real Chiriboga / NSG text)

**Runner:** The Catalyst, Sure Gamble, Creative Commission, VRcation, Wildcat Strike, Jailbreak, Overclock, Tread Lightly, Cleaver, Carmen, Unity, Mayfly, Pennyshaver, Docklands Pass, Telework Contract, Smartware Distributor, Verbal Plasticity, Red Team

**Corp:** The Syndicate, Hedge Fund, Government Subsidy, Seamless Launch, Retribution, Public Trail, Offworld Office, Orbital Superiority, Send a Message, Superconducting Hub, Nico Campaign, Regolith Mining License, Urtica Cipher, Manegarm Skunkworks, Palisade, Tithe, Whitespace, Diviner, Karunā, Brân 1.0, Funhouse, Ping, Hunter (Core Set tracer)

Starter decks follow *My First Runner* / *My First Corp* with a few extra ice (Hunter, Ping, Funhouse, Orbital Superiority, Retribution) so traces and tags show up in typical games.

## What is simplified vs the original

The JS Chiriboga engine is a near-complete NISEI rules implementation (paid ability windows, full trigger priority, 1000+ cards, gauntlet, decklauncher, 3D card renderer). This port is a **playable solo subset**:

| Original | This port |
| --- | --- |
| Full NISEI timing (paid windows 1.1 / 2.1 / 3.1 / 4.3 / …) | Action phase + a linear run state machine |
| All printed sets | ~38 representative cards, data-driven for more |
| Gauntlet / custom decks / mulligan / rewind | Starter game only; no mulligan |
| Virus counters, unique-per-card edge cases, preventable damage | Damage is not preventable; purge is a no-op flavour action |
| Full run calculator + deep AI | Heuristic AI, auto-break helper |
| Card art from NRDB | Text-only CRT cards (art is not in the Chiriboga git repo) |
| 6 AP win on tutorial starters | Always **7 AP** (standard) |
| Influence as deckbuilding constraint | Printed on cards; precons are already legal |

Adding a card: copy a Dictionary in `scripts/data/card_db.gd` using existing `on_play` / `subroutines` / `breaker` / `abilities` ops. Then add copies to `scripts/data/decks.gd` if you want them in the starter lists.

## Project layout

```
chiriboga-godot/
  project.godot
  scenes/main.tscn          # playable main scene
  scripts/main.gd           # CRT UI
  scripts/game/game_state.gd
  scripts/data/card_db.gd   # card definitions
  scripts/data/decks.gd
  scripts/ai/corp_ai.gd
  scripts/ai/runner_ai.gd
  tests/headless_sim.gd
```

## Credits

- **Chiriboga** engine: [bobtheuberfish](https://github.com/bobtheuberfish/chiriboga)
- **Solo Mode** / this card pool and CRT aesthetic: [DrBo6](https://github.com/drbo6/chiriboga)
- Cards: Null Signal Games (System Gateway and Core Set)
