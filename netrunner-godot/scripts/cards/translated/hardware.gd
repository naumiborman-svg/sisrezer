class_name NRCardsHardware
extends RefCounted

## Port of game.cards.hardware — translated from Jinteki.net Clojure.
## Call register() to defcard every implementation in this file.

static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_1()
	_register_2()
	_register_3()
	_register_4()


static func _register_1() -> void:
	NRCardDefs.defcard("Acacia", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Whenever the Corp purges virus counters, you may gain 1[Credits] for each virus counter removed and trash Acacia.",
		"code": "21021",
		"title": "Acacia",
	}, {
		"events": [
			{
			"event": "purge",
			"optional": {
				"waiting-prompt": true,
				"prompt": "Trash Acacia to gain 1 [Credits] for each purged virus counter?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var counters = NRCardXlate.getk(NRCardXlate.ctx(targets), "total-purged-counters", null)
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, side, ne, card, {
							"cause-card": card,
						})
						, func(async_result):
							(func():
							NRSay.system_msg(state, side, (str("trashes Acacia and gains ") + str(counters) + str(" [Credit]")))
							return NRGaining.gain_credits(state, side, eid, counters)
						).call())
					).call(),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Adjusted Matrix", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Install only on an <strong>icebreaker</strong>.\nHost <strong>icebreaker</strong> gains <strong>AI</strong> and \"Interface → <strong>Lose [Click]:</strong> Break 1 subroutine.\"",
		"code": "12046",
		"title": "Adjusted Matrix",
	}, {
		"implementation": "Click Adjusted Matrix to use the ability",
		"on-install": {
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker"))).is_empty()),
			"prompt": "Choose an icebreaker",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.has_subtype(_pct, "Icebreaker") and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return NRHosting.host(state, side, NRCard.get_card(state, NRCardXlate.first_target(targets)), NRCard.get_card(state, card)),
		},
		"static-abilities": [
			{
			"type": "gain-subtype",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": "AI",
		},
		],
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("lose-click", 1)], 1, "All", {
			"req": func(state, side, eid, card, targets): return true,
		}),
		],
	}))

	NRCardDefs.defcard("AirbladeX (JSRF Ed.)", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Vehicle",
		"subtypes": ["Vehicle"],
		"text": "When you install this hardware, load 3 power counters onto it. When it is empty, trash it.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent 1 net damage. Use this ability only during a run.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent a \"when encountered\" ability on a piece of ice.",
		"code": "34022",
		"title": "AirbladeX (JSRF Ed.)",
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("power", 1)],
				"msg": "prevent 1 net damage",
				"req": func(state, side, eid, card, targets): return (state.getv("run") and (("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
			{
			"prevents": "encounter",
			"type": "ability",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("power", 1)],
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null) > 0),
				"msg": func(state, side, eid, card, targets): return str("prevent the encounter ability on ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
				"effect": func(state, side, eid, card, targets):
					return prevent_encounter(state, side, eid),
			},
		},
		],
		"events": [trash_on_empty("power")],
	}))

	NRCardDefs.defcard("Akamatsu Mem Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+1[Memory Unit]",
		"code": "25048",
		"title": "Akamatsu Mem Chip",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
	}))

	NRCardDefs.defcard("Alarm Clock", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": true,
		"text": "When your turn begins, you may run HQ. The first time you encounter a piece of ice during that run, you may spend [Click][Click] to bypass it.",
		"code": "34078",
		"title": "Alarm Clock",
	}, (func():
		var ability = {
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"msg": "make a run on HQ",
			"makes-run": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.register_events(state, side, card, [
				{
				"event": "encounter-ice",
				"skippable": true,
				"unregister-once-resolved": true,
				"duration": "end-of-run",
				"optional": {
					"prompt": "Spend [Click][Click] to bypass encountered ice?",
					"req": func(state, side, eid, card, targets): return NREvents.first_run_event(state, side, "encounter-ice"),
					"yes-ability": {
						"cost": [NRPayment.to_c("click", 2)],
						"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state.getv("runner", {}), "click", null) >= 2),
						"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))),
						"effect": func(state, side, eid, card, targets):
							return NRCardXlate.bypass_ice(state),
					},
				},
			},
			])
				return NRRuns.make_run(state, side, eid, "hq", card),
		}
		return {
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [
				{
				"event": "runner-turn-begins",
				"skippable": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"once": "per-turn",
					"prompt": "Make a run on HQ?",
					"yes-ability": ability,
				},
			},
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Amanuensis", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhen your turn ends, place 1 power counter on this hardware if you are tagged.\nWhenever you remove 1 or more tags, you may remove 1 hosted power counter to draw 2 cards.\nLimit 1 <strong>console</strong> per player.",
		"code": "34069",
		"title": "Amanuensis",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "runner-lose-tag",
			"optional": {
				"prompt": "Remove 1 power counter to draw 2 cards?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets): return ((("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null))) and (NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null) > 0) and (NRCard.get_counters(card, "power") > 0)),
				"yes-ability": NRDefHelpers.draw_ability(2, null, {
					"cost": [NRPayment.to_c("power", 1)],
				}),
			},
		},
			{
			"event": "runner-turn-ends",
			"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
		],
	}))

	NRCardDefs.defcard("Aniccam", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nThe first time each turn an event is trashed <em>(from any location)</em>, draw 1 card.\nLimit 1 <strong>console</strong> per player.",
		"code": "26084",
		"title": "Aniccam",
	}, (func():
		var ability = {
			"async": true,
			"once-per-instance": true,
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.event(NRCardXlate.getk(_pct, "card", null))) != null) and (func():
				return NREvents.first_trash(state, event_targets_p)
			).call()),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"msg": "draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 1),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "corp-trash"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "game-trash"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Archives Interface", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"text": "[interrupt] → Whenever you would access a card in Archives, you may instead remove it from the game. Use this ability only once each time you breach Archives.",
		"code": "07044",
		"title": "Archives Interface",
	}, {
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((("archives" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("archives", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (not (((NRCardXlate.getk(state.getv("run"), "max-access", null) == 0) or NRUtil.kw_eq(NRCardXlate.getk(state.getv("run"), "max-access", null), 0)))) and (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).is_empty())),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				turn_archives_faceup(state, side, ne, ["archives"])
			, func(async_result):
				NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": "Remove a card from the game instead of accessing it?",
					"yes-ability": {
						"prompt": "Choose a card in Archives",
						"choices": func(state, side, eid, card, targets):
							return NRCardXlate.getk(state.getv("corp", {}), "discard", null),
						"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the game"),
						"effect": func(state, side, eid, card, targets):
							return NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "rfg"),
					},
				},
			}, card, null)),
		},
		],
	}))

	NRCardDefs.defcard("Astrolabe", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nDraw 1 card whenever the Corp creates a server.\nLimit 1 <strong>console</strong> per player.",
		"code": "06079",
		"title": "Astrolabe",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [NRDefHelpers.draw_ability(1, null, {
			"event": "server-created",
		})],
	}))

	NRCardDefs.defcard("Autoscripter", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"text": "The first time you install a program from your grip during your turn, gain [Click].\nTrash Autoscripter if you make an unsuccessful run.",
		"code": "06076",
		"title": "Autoscripter",
	}, {
		"events": [
			{
			"event": "runner-install",
			"silent": true,
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and ((NRCardXlate.getk(state, "active-player", null) == "runner") or NRUtil.kw_eq(NRCardXlate.getk(state, "active-player", null), "runner")) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "previous-zone", null)), func(_x): return NRUtil.in_coll(["hand"], _x)) != null) and NREvents.first_event(state, "runner", "runner-install", func(_p): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "previous-zone", null)), func(_x): return NRUtil.in_coll(["hand"], _x)) != null) and NRCard.program(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))))),
			"msg": "gain [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		},
			{
			"event": "unsuccessful-run",
			"async": true,
			"msg": "trash itself",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, card, {
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Basilar Synthgland 2KVJ", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, suffer 2 core damage.\nYou get +1 allotted [Click] for each of your turns.",
		"code": "33086",
		"title": "Basilar Synthgland 2KVJ",
	}, {
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 2, {
				"card": card,
			}),
		},
		"in-play": ["click-per-turn", 1],
	}))

	NRCardDefs.defcard("Blackguard", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 11,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nWhenever you expose a card, the Corp must rez it by paying its rez cost, if able.\nLimit 1 <strong>console</strong> per player.",
		"code": "04085",
		"title": "Blackguard",
	}, (func():
		var _b0 = choose_a_card([cards], (force_a_rez(NRUtil.first_of(cards)) if ((1 == NRUtil.as_array(cards).size()) or NRUtil.kw_eq(1, NRUtil.as_array(cards).size())) else {
			"prompt": "Force the Corp to rez which card?",
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(cards).is_empty()),
			"choices": func(state, side, eid, card, targets):
				return cards,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, side, ne, force_a_rez(NRCardXlate.first_target(targets)), card, null)
			, func(async_result):
				NREngine.continue_ability(state, side, choose_a_card(filterv(func(_pct, _pct2=null, _pct3=null): return (not (NRUtil.same_card(_pct, NRCardXlate.first_target(targets)))), cards)), card, null)),
		}))
		return {
			"static-abilities": [NRCardXlate.mu_plus(2)],
			"events": [
				{
				"event": "expose",
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)).is_empty()),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, choose_a_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Bling", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever you install a card without spending credits, you may host the top card of your stack faceup on this hardware. <em>(It is not installed.)</em>\nYou can play or install hosted cards as if they were in your grip.\nWhen your discard phase ends, trash all hosted cards.\nLimit 1 <strong>console</strong> per player.",
		"code": "35006",
		"title": "Bling",
	}, (func():
		return {
			"static-abilities": [
				NRCardXlate.mu_plus(1),
				{
				"type": "can-play-as-if-in-hand",
				"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null), card),
				"value": true,
			},
			],
			"events": [
				{
				"event": "runner-install",
				"skippable": true,
				"optional": {
					"waiting-prompt": true,
					"req": func(state, side, eid, card, targets): return (is_no_creds_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "costs", null)) and (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty())),
					"prompt": "Host the top card of your stack on Bling?",
					"yes-ability": {
						"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)),
						"effect": func(state, side, eid, card, targets):
							NREngine.trigger_event(state, side, "bling-hosted")
							(func():
							var times_hosted = mini(NREvents.event_count(state, null, "bling-hosted"), 10)
							return NRSay.play_sfx(state, side, (str("bling-") + str(times_hosted)))
						).call()
							return NRHosting.host(state, side, card, NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null))),
					},
				},
			},
				{
				"event": "runner-turn-ends",
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty()),
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.enumerate_cards(NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null), "sorted")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash_cards(state, "runner", eid, NRCardXlate.getk(card, "hosted", null)),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("BMI Buffer", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Whenever a program is trashed from your grip, host it on BMI Buffer instead of adding it to your heap.\n[Click][Click]: Install 1 hosted program (paying all costs).",
		"code": "14020",
		"title": "BMI Buffer",
	}, (func():
		var grip_program_trash_p = func(card): return (NRCard.runner(card) and NRCard.program(card) and NRCard.in_discard(card) and ((NRUtil.first_of(NRCardXlate.getk(card, "previous-zone", null)) == "hand") or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(card, "previous-zone", null)), "hand")))
		var triggered_ability = {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(func():
				for c in NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(targets).map(func(_pct, _pct2=null, _pct3=null): return NRFinding.find_latest(state, NRCardXlate.getk(_pct, "card", null)))).filter(grip_program_trash_p)):
					NRHosting.host(state, side, NRCard.get_card(state, card), c)
				return null
			).call()
				return NREid.effect_completed(state, side, eid),
		}
		return {
			"events": [
				NRUtil.merge(triggered_ability if triggered_ability is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(triggered_ability if triggered_ability is Dictionary else {}, {"event": "corp-trash"}),
			],
			"abilities": [
				{
				"action": true,
				"cost": [NRPayment.to_c("click", 2)],
				"label": "Install a hosted program",
				"prompt": "Choose a program to install",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct)),
				"msg": func(state, side, eid, card, targets): return str("install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets)),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("BMI Buffer 2", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Whenever a program is trashed from your grip, host it on BMI Buffer instead of adding it to your heap.\n[Click][Click]: Install 1 hosted program, ignoring all costs.",
		"code": "14021",
		"title": "BMI Buffer 2",
	}, (func():
		var grip_program_trash_p = func(card): return (NRCard.runner(card) and NRCard.program(card) and NRCard.in_discard(card) and ((NRUtil.first_of(NRCardXlate.getk(card, "previous-zone", null)) == "hand") or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(card, "previous-zone", null)), "hand")))
		var triggered_ability = {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(func():
				for c in NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(targets).map(func(_pct, _pct2=null, _pct3=null): return NRFinding.find_latest(state, NRCardXlate.getk(_pct, "card", null)))).filter(grip_program_trash_p)):
					NRHosting.host(state, side, NRCard.get_card(state, card), c)
				return null
			).call()
				return NREid.effect_completed(state, side, eid),
		}
		return {
			"events": [
				NRUtil.merge(triggered_ability if triggered_ability is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(triggered_ability if triggered_ability is Dictionary else {}, {"event": "corp-trash"}),
			],
			"abilities": [
				{
				"action": true,
				"cost": [NRPayment.to_c("click", 2)],
				"label": "Install a hosted program",
				"prompt": "Choose a program to install",
				"choices": func(state, side, eid, card, targets):
					return NRCardXlate.getk(card, "hosted", null),
				"msg": func(state, side, eid, card, targets): return str("install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"ignore-all-cost": true,
				}),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Bookmark", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "<strong>[Click]:</strong> Host up to 3 cards from your grip facedown on this hardware <em>(you may look at these cards at any time)</em>.\n<strong>[Click]:</strong> Add all hosted cards to your grip.\n<strong>[Trash]:</strong> Add all hosted cards to your grip.",
		"code": "08106",
		"title": "Bookmark",
	}, {
		"abilities": [
			{
			"action": true,
			"label": "Host up to 3 cards from the grip facedown",
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"msg": "host up to 3 cards from the grip facedown",
			"choices": {
				"max": 3,
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_hand(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				for c in NRUtil.as_array(targets):
					NRHosting.host(state, side, NRCard.get_card(state, card), c, {
				"facedown": true,
			})
				return null
			).call(),
		},
			{
			"action": true,
			"label": "Add all hosted cards to the grip",
			"cost": [NRPayment.to_c("click", 1)],
			"msg": "add all hosted cards to the grip",
			"effect": func(state, side, eid, card, targets):
				return (func():
				for c in NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)):
					NRMoving.move(state, side, c, "hand")
				return null
			).call(),
		},
			{
			"label": "Add all hosted cards to the grip",
			"fake-cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var hosted_cards = NRCardXlate.getk(card, "hosted", null)
				return (func():
					(func():
						for c in NRUtil.as_array(hosted_cards):
							NRMoving.move(state, side, c, "hand")
						return null
					).call()
					return NREngine.continue_ability(state, side, {
						"cost": [NRPayment.to_c("trash-can")],
						"msg": func(state, side, eid, card, targets): return str("add ") + str(NRUtil.quantify(NRUtil.as_array(hosted_cards).size(), "hosted card")) + str(" to the grip"),
					}, card, null)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Boomerang", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"text": "When you install this hardware, choose 1 installed piece of ice. Use this hardware only during encounters with that ice.\n<strong>[Trash]:</strong> Break up to 2 subroutines. When this run ends, if it was successful, you may shuffle 1 copy of Boomerang from your heap into your stack.",
		"code": "26075",
		"title": "Boomerang",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"prompt": "Choose an installed piece of ice",
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "boomerang-target"], NRCardXlate.first_target(targets))),
		},
		"static-abilities": [
			{
			"type": "icon",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRUtil.get_in(card, ["special", "boomerang-target"], null)),
			"while-disabled": true,
			"value": func(state, side, eid, card, targets):
				return make_icon("B", card),
		},
		],
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("trash-can")], 2, "All", {
			"req": func(state, side, eid, card, targets): return (func():
				var boomerang_target = NRUtil.get_in(card, ["special", "boomerang-target"], null)
				return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state, "encounters", null)), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(boomerang_target, NRCardXlate.getk(_pct, "ice", null))) != null) if boomerang_target != null else true
			).call(),
			"additional-ability": {
				"effect": func(state, side, eid, card, targets):
					return (func():
					var source = (card or NRUtil.first_of(NRUtil.get_in(eid, ["cost-paid", "trash-can", "paid/targets"], null)))
					return NREngine.register_events(state, side, source, [
						{
						"event": "run-ends",
						"duration": "end-of-run",
						"unregister-once-resolved": true,
						"optional": {
							"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and (not (NRFlags.zone_locked(state, "runner", "discard"))) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(card, "title", null) == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(card, "title", null), NRCardXlate.getk(_pct, "title", null)))) != null)),
							"once": "per-run",
							"prompt": func(state, side, eid, card, targets): return str("Shuffle a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" back into the Stack?"),
							"yes-ability": {
								"msg": func(state, side, eid, card, targets): return str("shuffle a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" back into the Stack"),
								"effect": func(state, side, eid, card, targets):
									NRMoving.move(state, side, (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(card, "title", null) == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(card, "title", null), NRCardXlate.getk(_pct, "title", null))) else null)) != null), "deck")
									return NRShuffling.shuffle_zone(state, side, "deck"),
							},
						},
					},
					])
				).call(),
			},
		}),
			{
			"label": "Break 0 subroutines",
			"cost": [NRPayment.to_c("trash-can")],
			"msg": "break 0 subroutines",
			"req": func(state, side, eid, card, targets): return (func():
				var boomerang_target = NRUtil.get_in(card, ["special", "boomerang-target"], null)
				return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state, "encounters", null)), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(boomerang_target, NRCardXlate.getk(_pct, "ice", null))) != null) if boomerang_target != null else true
			).call(),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var source = (card or NRUtil.first_of(NRUtil.get_in(eid, ["cost-paid", "trash-can", "paid/targets"], null)))
				return NREngine.register_events(state, side, source, [
					{
					"event": "run-ends",
					"duration": "end-of-run",
					"unregister-once-resolved": true,
					"optional": {
						"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and (not (NRFlags.zone_locked(state, "runner", "discard"))) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(card, "title", null) == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(card, "title", null), NRCardXlate.getk(_pct, "title", null)))) != null)),
						"once": "per-run",
						"prompt": func(state, side, eid, card, targets): return str("Shuffle a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" back into the Stack?"),
						"yes-ability": {
							"msg": func(state, side, eid, card, targets): return str("shuffle a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" back into the Stack"),
							"effect": func(state, side, eid, card, targets):
								NRMoving.move(state, side, (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(card, "title", null) == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(card, "title", null), NRCardXlate.getk(_pct, "title", null))) else null)) != null), "deck")
								return NRShuffling.shuffle_zone(state, side, "deck"),
						},
					},
				},
				])
			).call(),
		},
		],
	})))

	NRCardDefs.defcard("Borrowed Goods", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+1[Memory Unit]\nWhen you install this hardware, if you are not tagged, take 1 tag.",
		"code": "36013",
		"title": "Borrowed Goods",
	}, {
		"on-install": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not (NRUtil.is_tagged(state))),
				"silent": true,
			},
			"msg": "take 1 tag",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.gain_tags(state, side, eid, 1),
		},
		"static-abilities": [NRCardXlate.mu_plus(1)],
	}))

	NRCardDefs.defcard("Box-E", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nYour maximum hand size is increased by 2.\nLimit 1 <strong>console</strong> per player.",
		"code": "06055",
		"title": "Box-E",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2), runner_hand_size_(2)],
	}))

	NRCardDefs.defcard("Brain Cage", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "You get +3 maximum hand size.\nWhen you install this hardware, suffer 1 core damage.",
		"code": "08049",
		"title": "Brain Cage",
	}, {
		"static-abilities": [runner_hand_size_(3)],
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
	}))

	NRCardDefs.defcard("Brain Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Adam",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+X[Memory Unit]\nYour maximum hand size is increased by X.\nX is equal to the number of agenda points you have.\nLimit 1 <strong>console</strong> per player.",
		"code": "09039",
		"title": "Brain Chip",
	}, {
		"x-fn": func(state, side, eid, card, targets):
			return maxi(state.get_in(["runner", "agenda-point"], 0), 0),
		"static-abilities": [
			NRCardXlate.mu_plus(func(state, side, eid, card, targets):
			return ((get_x_fn()).call(state, side, eid, card, targets) > 0), func(state, side, eid, card, targets):
			return ["regular", (get_x_fn()).call(state, side, eid, card, targets)]),
			runner_hand_size_(get_x_fn()),
		],
	}))

	NRCardDefs.defcard("Buffer Drive", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": true,
		"text": "The first time each turn 1 or more cards are trashed from your grip or stack, you may add 1 of those cards to the bottom of your stack.\n<strong>Remove this hardware from the game:</strong> Add 1 card from your heap to the top of your stack.",
		"code": "26093",
		"title": "Buffer Drive",
	}, (func():
		var grip_or_stack_trash_p = func(_p): return (NRCard.runner(card) and (NRCard.in_hand(card) or NRCard.in_deck(card)))
		var triggered_ability = {
			"once-per-instance": true,
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), grip_or_stack_trash_p) != null) and NREvents.first_trash(state, func(_pct, _pct2=null, _pct3=null): return (NRUtil.find_first(NRUtil.as_array(_pct), grip_or_stack_trash_p) != null))),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Choose 1 trashed card to add to the bottom of the stack",
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array(NRUtil.as_array(keep(func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRCardXlate.getk(_pct, "moved-card", null), "title", null), NRUtil.as_array(targets).filter(grip_or_stack_trash_p)))) + ["No action"]),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.effect_completed(state, side, eid) if (("No action" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("No action", NRCardXlate.first_target(targets))) else (func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to add ") + str(NRCardXlate.first_target(targets)) + str(" to the bottom of the stack")))
				NRMoving.move(state, side, NRFinding.find_card(NRCardXlate.first_target(targets), (func(_a=NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(state, "runner", null), "discard", null))):
					var _b = _a.duplicate()
					_b.reverse()
					return _b
				).call()), "deck")
				return NREid.effect_completed(state, side, eid)
			).call()),
		}
		return {
			"events": [
				NRUtil.merge(triggered_ability if triggered_ability is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(triggered_ability if triggered_ability is Dictionary else {}, {"event": "corp-trash"}),
			],
			"abilities": [
				{
				"req": func(state, side, eid, card, targets): return (not (NRFlags.zone_locked(state, "runner", "discard"))),
				"label": "Add a card from the heap to the top of the stack",
				"cost": [NRPayment.to_c("remove-from-game")],
				"show-discard": true,
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_discard(_pct)),
				},
				"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to the top of the stack"),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, side, NRCardXlate.first_target(targets), "deck", {
					"front": true,
				}),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Capstone", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"text": "[Click]: Trash any number of cards from your grip. For each trashed card of which you have another copy installed, draw 1 card.",
		"code": "04068",
		"title": "Capstone",
	}, {
		"abilities": [
			{
			"action": true,
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() > 0),
			"label": "trash and install cards",
			"cost": [NRPayment.to_c("click", 1)],
			"async": true,
			"prompt": "Choose any number of cards to trash from the grip",
			"choices": {
				"max": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size(),
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_hand(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var trashed_card_names = keep("title", targets)
				var installed_card_names = keep("title", NRBoard.all_active_installed(state, "runner"))
				var overlap = set_intersection(NRUtil.as_array(trashed_card_names), NRUtil.as_array(installed_card_names))
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
					"unpreventable": true,
					"cause-card": card,
				})
				, func(trashed_cards):
					NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, NRUtil.as_array(NRUtil.as_array(trashed_card_names).filter(overlap)).size())
				, func(drawn_cards):
					(func():
					NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRUtil.enumerate_cards(trashed_cards, true)) + str(" from the grip and draw ") + str(NRUtil.quantify(NRUtil.as_array(drawn_cards).size(), "card"))))
					return NREid.effect_completed(state, side, eid)
				).call()))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Capybara", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"text": "Whenever you bypass a piece of ice, you may remove this hardware from the game to derez that ice.",
		"code": "34013",
		"title": "Capybara",
	}, {
		"events": [
			{
			"event": "bypassed-ice",
			"async": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return true,
				"prompt": func(state, side, eid, card, targets): return str("Remove this hardware from the game to derez ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str("?"),
				"waiting-prompt": true,
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("remove-from-game")],
					"effect": func(state, side, eid, card, targets):
						return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets), {
						"msg-keys": {
							"include-cost-from-eid": eid,
						},
					}),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Carnivore", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nAccess, once per turn → <strong>Trash 2 cards from your grip:</strong> Trash the card you are accessing.\nLimit 1 <strong>console</strong> per player.",
		"code": "30003",
		"title": "Carnivore",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"interactions": {
			"access-ability": {
				"label": "Trash card",
				"trash?": true,
				"req": func(state, side, eid, card, targets): return (NRFlags.can_trash(state, "runner", NRCardXlate.first_target(targets)) and (not (NRCard.in_discard(NRCardXlate.first_target(targets)))) and (not (state.get_in(["per-turn", NRCardXlate.getk(card, "cid", null)], null))) and (2 <= NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size())),
				"cost": [NRPayment.to_c("trash-from-hand", 2)],
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" at no cost"),
				"once": "per-turn",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}), {
					"accessed": true,
					"cause-card": card,
				}),
			},
		},
	}))

	NRCardDefs.defcard("Cataloguer", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": false,
		"text": "When you install this hardware, load 2 power counters onto it. When it is empty, trash it.\nWhenever you make a successful run on R&D, instead of breaching R&D, you may remove 1 hosted power counter to look at the top 4 cards of R&D and arrange them in any order.\n[Click], <strong>hosted power counter:</strong> Breach R&D. Use this ability only if you made a successful run on R&D this turn.",
		"code": "34088",
		"title": "Cataloguer",
	}, (func():
		var index_ability = NRCardXlate.successful_run_replace_breach({
			"target-server": "rd",
			"mandatory": false,
			"ability": {
				"async": true,
				"msg": "rearrange the top 4 cards of R&D",
				"cost": [NRPayment.to_c("power", 1)],
				"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "power") > 0),
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, (func():
					var from = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(4))
					return (reorder_choice("corp", "corp", from, [], NRUtil.as_array(from).size(), from) if (NRUtil.as_array(from).size() > 0) else null)
				).call(), card, null),
			},
		})
		var access_ability = {
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null),
			"label": "Breach R&D",
			"msg": "breach R&D",
			"keep-menu-open": "while-power-tokens-left",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRAccess.breach_server(state, side, eid, ["rd"]),
		}
		return {
			"data": {
				"counter": {
					"power": 2,
				},
			},
			"abilities": [access_ability],
			"events": [trash_on_empty("power"), index_ability],
		}
	).call()))

	NRCardDefs.defcard("Chop Bot 3000", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"text": "When your turn begins, you may trash another of your installed cards. If you do, draw 1 card or remove 1 tag.",
		"code": "07045",
		"title": "Chop Bot 3000",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRBoard.all_installed(state, "runner")).size() >= 2),
			"label": "Trash another installed card to draw 1 card or remove 1 tag",
			"once": "per-turn",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.installed(_pct)),
				"not-self": true,
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, "runner", ne, NRCardXlate.first_target(targets), {
				"unpreventable": true,
				"cause-card": card,
			})
			, func(async_result):
				NREngine.continue_ability(state, side, (func():
				var trashed_card = NRCardXlate.first_target(targets)
				var tags = (count_real_tags(state) > 0)
				return {
					"prompt": "Choose one",
					"waiting-prompt": true,
					"choices": ["Draw 1 card", ("Remove 1 tag" if tags else null)],
					"async": true,
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(trashed_card, "title", null)) + str(" and ") + str(decapitalize(NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return (NRDrawing.draw(state, "runner", eid, 1) if ((NRCardXlate.first_target(targets) == "Draw 1 card") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 1 card")) else NRTags.lose_tags(state, "runner", eid, 1)),
				}
			).call(), card, null)),
		}
		return {
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return (NRUtil.as_array(NRBoard.all_installed(state, "runner")).size() >= 2),
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Clone Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "[Trash]: Install a program from your heap (paying the install cost).",
		"code": "03038",
		"title": "Clone Chip",
	}, {
		"abilities": [
			{
			"prompt": "Choose a program to install",
			"label": "Install program from the heap",
			"show-discard": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
					"no-toast": true,
				}))) != null),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCard.in_discard(NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets))),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
					"include-cost-from-eid": eid,
				},
			}),
		},
		],
	}))

	NRCardDefs.defcard("Comet", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nThe first time you play an event each turn, you may play another event (without spending a click) after the first one resolves.\nLimit 1 <strong>console</strong> per player.",
		"code": "08027",
		"title": "Comet",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "play-event",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "play-event"),
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, "runner", str("can play another event without spending a [Click] by clicking on Comet"))
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"comet-event": true})),
		},
		],
		"abilities": [
			{
			"async": true,
			"label": "Play an event in the grip twice",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(card, "comet-event", null),
			"prompt": "Choose an event to play",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.event(_pct) and NRCard.in_hand(_pct)),
			},
			"msg": func(state, side, eid, card, targets): return str("play ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var eid = NRUtil.merge(eid if eid is Dictionary else {}, {"source-type": "play"})
				return (func():
					NRUpdate.update_card(state, "runner", NRUtil.dissoc(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["comet-event"]))
					return NRPlayInstants.play_instant(state, side, eid, NRCardXlate.first_target(targets), null)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Cortez Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "[Trash]: Choose a piece of ice. The Corp must pay 2[Credits] as an additional cost to rez that ice until the end of the turn.",
		"code": "02005",
		"title": "Cortez Chip",
	}, {
		"abilities": [
			{
			"prompt": "Choose a piece of ice",
			"label": "increase rez cost of ice",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and (not (NRCard.rezzed(_pct)))),
			},
			"msg": func(state, side, eid, card, targets): return str("increase the rez cost of ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" by 2 [Credits] until the end of the turn"),
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NREffects.register_lingering_effect(state, side, card, (func():
				var ice = NRCardXlate.first_target(targets)
				return {
					"type": "rez-additional-cost",
					"duration": "end-of-turn",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), ice),
					"value": [NRPayment.to_c("credit", 2)],
				}
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Cyberdelia", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+1[Memory Unit]\nThe first time each turn you fully break a piece of ice, gain 1[Credits].",
		"code": "21006",
		"title": "Cyberdelia",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "all-subs-broken", null) and NREvents.first_event(state, side, "subroutines-broken", func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "all-subs-broken", null))),
			"msg": "gain 1 [Credits] for breaking all subroutines on a piece of ice",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Cyberfeeder", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "1[recurring-credit]\nUse this credit to pay for using <strong>icebreakers</strong> or for installing <strong>virus</strong> programs.",
		"code": "25008",
		"title": "Cyberfeeder",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Virus") and NRCard.program(NRCardXlate.first_target(targets))) or ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker"))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("CyberSolutions Mem Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+2[Memory Unit]",
		"code": "04086",
		"title": "CyberSolutions Mem Chip",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
	}))

	NRCardDefs.defcard("Cybsoft MacroDrive", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "1[recurring-credit]\nUse this credit to install programs.",
		"code": "06098",
		"title": "Cybsoft MacroDrive",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and NRCard.program(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Daredevil", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nThe first time you initiate a run on a server protected by 2 or more pieces of ice each turn, draw 2 cards.\nLimit 1 <strong>console</strong> per player.",
		"code": "12066",
		"title": "Daredevil",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			NRDefHelpers.draw_ability(2, null, {
			"event": "run",
			"req": func(state, side, eid, card, targets): return ((2 <= NRCardXlate.getk(NRCardXlate.first_target(targets), "position", null)) and NREvents.first_event(state, side, "run", func(_pct, _pct2=null, _pct3=null): return (2 <= NRCardXlate.getk(NRUtil.first_of(_pct), "position", null)))),
		}),
		],
	}))

	NRCardDefs.defcard("Dedicated Processor", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Install Dedicated Processor on a non-<strong>AI icebreaker</strong>.\nHost <strong>icebreaker</strong> gains \"2[Credits]: +4 strength.\"",
		"code": "12047",
		"title": "Dedicated Processor",
	}, {
		"implementation": "Click Dedicated Processor to use ability",
		"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker"))).is_empty()),
		"hosting": {
			"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and (not (NRCard.has_subtype(_pct, "AI"))) and NRCard.installed(_pct)),
		},
		"abilities": [
			{
			"cost": [NRPayment.to_c("credit", 2)],
			"label": "add 4 strength for the remainder of the run",
			"req": func(state, side, eid, card, targets): return state.getv("run"),
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCard.get_card(state, NRCardXlate.getk(card, "host", null)), 4),
			"msg": func(state, side, eid, card, targets): return str("pump the strength of ") + str(NRUtil.get_in(card, ["host", "title"], null)) + str(" by 4"),
		},
		],
	}))

	NRCardDefs.defcard("Deep Red", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+3[Memory Unit]\nUse the MU on Deep Red only for <strong>Caïssa</strong> programs.\nWhenever you install a <strong>Caïssa</strong> program, you may trigger its [Click] ability without spending [Click].\nLimit 1 <strong>console</strong> per player.",
		"code": "04042",
		"title": "Deep Red",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(3)],
		"events": [
			{
			"event": "runner-install",
			"optional": {
				"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Caïssa"),
				"prompt": "Trigger the [Click] ability of the just-installed Caïssa program?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return play_ability(state, side, eid, {
						"card": NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null),
						"ability": 0,
						"ignore-cost": true,
					}),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Demolisher", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nThe trash cost of each Corp card is lowered by 1[Credits].\nThe first time each turn you trash a Corp card, gain 1[Credits].\nLimit 1 <strong>console</strong> per player.",
		"code": "26002",
		"title": "Demolisher",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1), {
			"type": "trash-cost",
			"value": -1,
		}],
		"events": [
			{
			"event": "runner-trash",
			"once-per-instance": true,
			"req": func(state, side, eid, card, targets): return (NRCard.corp(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)) and NREvents.first_event(state, side, "runner-trash", func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.corp(NRCardXlate.getk(_pct, "card", null))) != null))),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Desperado", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nGain 1[Credits] whenever you make a successful run.\nLimit 1 <strong>console</strong> per player.",
		"code": "01024",
		"title": "Desperado",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"silent": true,
			"async": true,
			"msg": "gain 1 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Detente", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nThe first time each turn you make a successful run on HQ, you may host 1 card from HQ at random faceup on this hardware. <em>(It is not installed or rezzed.)</em>\n[Click], <strong>add 2 hosted cards to HQ:</strong> The Runner may access 1 card in HQ at random. Any player can use this ability.\nLimit 1 <strong>console</strong> per player.",
		"code": "35018",
		"title": "Detente",
	}, (func():
		var return_cards = {
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("hosted-to-hq", 2)],
			"label": "Runner may access 1 card from HQ",
			"msg": "cost",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, "runner", {
				"optional": {
					"prompt": "Access 1 card from HQ?",
					"waiting-prompt": true,
					"yes-ability": {
						"msg": "access 1 card from HQ",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRAccess.access_card(state, "runner", eid, NRUtil.first_of(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null)))),
					},
				},
			}, card, null),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"events": [
				{
				"event": "successful-run",
				"skippable": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"req": func(state, side, eid, card, targets): return (func():
						var valid_ctx_p = func(_p): return ((NRUtil.first_of(NRCardXlate.getk(ctx, "server", null)) == "hq") or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(ctx, "server", null)), "hq"))
						return (valid_ctx_p([NRCardXlate.ctx(targets)]) and NREvents.first_event(state, side, "successful-run", valid_ctx_p) and (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()))
					).call(),
					"waiting-prompt": true,
					"prompt": "Reveal and host a card from HQ (at random)",
					"yes-ability": {
						"effect": func(state, side, eid, card, targets):
							return (func():
							var target_card = NRUtil.first_of(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null)))
							return (func():
								NRSay.system_msg(state, side, (str("uses Detente to reveal and host ") + str(NRCardXlate.getk(target_card, "title", null)) + str(" from HQ")))
								return NREid.wait_for(state, eid, func(ne):
									NRRevealing.reveal(state, "runner", ne, target_card)
								, func(async_result):
									(func():
									NRHosting.host(state, side, card, NRUtil.merge(target_card if target_card is Dictionary else {}, {"seen": true}))
									return NREid.effect_completed(state, side, eid)
								).call())
							).call()
						).call(),
						"async": true,
					},
				},
			},
			],
			"abilities": [return_cards],
			"corp-abilities": [
				NRUtil.merge(return_cards if return_cards is Dictionary else {}, {"player": "corp"}),
			],
		}
	).call()))


static func _register_2() -> void:
	NRCardDefs.defcard("Devil Charm", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "Whenever you encounter a piece of ice, you may remove this hardware from the game. If you do, that ice gets −6 strength for the remainder of this run.",
		"code": "26068",
		"title": "Devil Charm",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Remove Devil Charm from the game to give encountered ice -6 strength?",
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str("give -6 strength to ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))) + str(" for the remainder of the run"),
					"cost": [NRPayment.to_c("remove-from-game")],
					"effect": func(state, side, eid, card, targets):
						NREffects.register_lingering_effect(state, side, card, (func():
						var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
						return {
							"type": "ice-strength",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), ice),
							"value": -6,
						}
					).call())
						return NRIce.update_all_ice(state, side),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Dinosaurus", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "Dinosaurus can host a single non-<strong>AI icebreaker</strong>. The memory cost of the hosted <strong>icebreaker</strong> does not count against your memory limit.\nHosted <strong>icebreaker</strong> has +2 strength.\nLimit 1 <strong>console</strong> per player.",
		"code": "25049",
		"title": "Dinosaurus",
	}, {
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker") and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "AI")))),
			"max-cards": 1,
			"no-mu": true,
		},
			{
			"type": "breaker-strength",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRUtil.first_of(NRCardXlate.getk(card, "hosted", null))),
			"value": 2,
		},
		],
	}))

	NRCardDefs.defcard("Docklands Pass", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"text": "The first time each turn you breach HQ, access 1 additional card.",
		"code": "30013",
		"title": "Docklands Pass",
	}, {
		"events": [
			breach_access_bonus("hq", 1, {
			"req": func(state, side, eid, card, targets): return ((("hq" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and NREvents.first_event(state, side, "breach-server", func(_pct, _pct2=null, _pct3=null): return (("hq" == NRCardXlate.getk(NRUtil.first_of(_pct), "server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk(NRUtil.first_of(_pct), "server", null))))),
			"msg": "access 1 additional card from HQ",
		}),
		],
	}))

	NRCardDefs.defcard("Doppelgänger", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nOnce per turn → When a successful run ends, you may run any server.\nLimit 1 <strong>console</strong> per player.",
		"code": "20025",
		"title": "Doppelgänger",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "run-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return NREngine.not_used_once(state, {
					"once": "per-turn",
				}, card),
			},
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and NREngine.not_used_once(state, {
					"once": "per-turn",
				}, card)),
				"prompt": "Make another run?",
				"yes-ability": {
					"prompt": "Choose a server",
					"once": "per-turn",
					"async": true,
					"choices": func(state, side, eid, card, targets):
						return NRCardXlate.runnable_servers(state, side, eid, card),
					"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)),
					"makes-run": true,
					"effect": func(state, side, eid, card, targets):
						unregister_lingering_effects(state, side, "end-of-run")
						NREngine.unregister_floating_events(state, side, "end-of-run")
						register_once(state, side, {
						"once": "per-turn",
					}, card)
						NRIce.update_all_icebreakers(state, side)
						NRIce.update_all_ice(state, side)
						reset_all_ice(state, side)
						NRPrompts.clear_wait_prompt(state, "corp")
						return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), NRCard.get_card(state, card)),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Dorm Computer", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "When you install this hardware, place 4 power counters on it.\n[Click], <strong>hosted power counter:</strong> Run any server. Whenever you would take tags during that run, prevent all of those tags.",
		"code": "08024",
		"title": "Dorm Computer",
	}, {
		"data": {
			"counter": {
				"power": 4,
			},
		},
		"static-abilities": [
			{
			"type": "forced-to-avoid-tag",
			"value": true,
			"req": func(state, side, eid, card, targets): return (state.getv("run") is Dictionary and NRUtil.same_card(card, state.get_in(["run", "source-card"], {}))),
		},
		],
		"events": [
			{
			"event": "tag-interrupt",
			"req": func(state, side, eid, card, targets): return ((NRUtil.get_in(state.getv("run"), ["source-card", "title"], null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRUtil.get_in(state.getv("run"), ["source-card", "title"], null), NRCardXlate.getk(card, "title", null))),
			"async": true,
			"msg": "avoid all tags",
			"effect": func(state, side, eid, card, targets):
				return prevent_tag(state, "runner", eid, "all"),
		},
		],
		"abilities": [
			NRCardXlate.run_any_server_ability({
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
			"msg": "make a run and avoid all tags for the remainder of the run",
		}),
		],
	}))

	NRCardDefs.defcard("Dyson Fractal Generator", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Chip - Stealth",
		"subtypes": ["Chip", "Stealth"],
		"text": "1[recurring-credit]\nUse this credit to pay for using <strong>fracters</strong>.",
		"code": "04103",
		"title": "Dyson Fractal Generator",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Fracter") and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Dyson Mem Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Chip - Link",
		"subtypes": ["Chip", "Link"],
		"text": "+1[Memory Unit], +1[link]",
		"code": "20057",
		"title": "Dyson Mem Chip",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1), NRCardXlate.link_plus(1)],
	}))

	NRCardDefs.defcard("DZMZ Optimizer", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "+1[Memory Unit]\nThe first program you install each turn costs 1[Credits] less to install.",
		"code": "30022",
		"title": "DZMZ Optimizer",
	}, {
		"static-abilities": [
			NRCardXlate.mu_plus(1),
			{
			"type": "install-cost",
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NREvents.no_event(state, "runner", "runner-install", func(_pct, _pct2=null, _pct3=null): return NRCard.program(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
			"value": -1,
		},
		],
		"events": [
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NREvents.first_event(state, "runner", "runner-install", func(_pct, _pct2=null, _pct3=null): return NRCard.program(NRUtil.first_of(_pct)))),
			"silent": true,
			"msg": func(state, side, eid, card, targets): return str("reduce the install cost of ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" by 1 [Credits]"),
		},
		],
	}))

	NRCardDefs.defcard("e3 Feedback Implants", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Whenever you break a subroutine on a piece of ice, you may pay 1[Credits] to break 1 subroutine on that ice.",
		"code": "29003",
		"title": "e3 Feedback Implants",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"req": func(state, side, eid, card, targets): return NRIce.any_subs_broken(NRIce.get_current_ice(state)),
		}),
		],
	})))

	NRCardDefs.defcard("Ekomind", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "Your memory limit is equal to the number of cards in your grip.\nLimit 1 <strong>console</strong> per player.",
		"code": "06093",
		"title": "Ekomind",
	}, (func():
		var update_base_mu = func(state, n): return state.assoc_in(["runner", "memory", "base"], n)
		return {
			"effect": func(state, side, eid, card, targets):
				update_base_mu(state, NRUtil.as_array(state.get_in(["runner", "hand"], null)).size())
				return add_watch(state, "ekomind", func(_k, ref, old, new): return (func():
				var hand_size = NRUtil.as_array(NRUtil.get_in(new, ["runner", "hand"], null)).size()
				return (update_base_mu(ref, NRHandSize.hand_size) if (not (((NRUtil.as_array(NRUtil.get_in(old, ["runner", "hand"], null)).size() == NRHandSize.hand_size) or NRUtil.kw_eq(NRUtil.as_array(NRUtil.get_in(old, ["runner", "hand"], null)).size(), NRHandSize.hand_size)))) else null)
			).call()),
			"leave-play": func(state, side, eid, card, targets):
				return remove_watch(state, "ekomind"),
		}
	).call()))

	NRCardDefs.defcard("EMP Device", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "[Trash]: The Corp cannot rez more than 1 piece of ice for the remainder of this run. Use this ability only during a run.",
		"code": "10020",
		"title": "EMP Device",
	}, {
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return state.getv("run"),
			"msg": "prevent the Corp from rezzing more than 1 piece of ice for the remainder of the run",
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [
				{
				"event": "rez",
				"duration": "end-of-run",
				"unregister-once-resolved": true,
				"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
				"effect": func(state, side, eid, card, targets):
					return NRFlags.register_run_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez ice the rest of this run due to EMP Device")) if NRCard.ice(card) else true)),
			},
			]),
		},
		],
	}))

	NRCardDefs.defcard("Endurance", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 8,
		"factioncost": 5,
		"uniqueness": true,
		"keywords": "Console - Vehicle",
		"subtypes": ["Console", "Vehicle"],
		"text": "+2[Memory Unit]\nWhen you install this hardware, place 3 power counters on it.\nThe first time each turn you make a successful run, place 1 power counter on this hardware.\n<strong>2 hosted power counters:</strong> Break up to 2 subroutines.\nLimit 1 <strong>console</strong> per player.",
		"code": "33025",
		"title": "Endurance",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, "runner", "successful-run"),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
		],
		"abilities": [NRCardXlate.break_sub([NRPayment.to_c("power", 2)], 2, "All")],
	})))

	NRCardDefs.defcard("Feedback Filter", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Gear",
		"subtypes": ["Gear"],
		"text": "[interrupt] → <strong>3[Credits]:</strong> Prevent 1 net damage.\n[interrupt] → <strong>[Trash]:</strong> Prevent up to 2 core damage.",
		"code": "03037",
		"title": "Feedback Filter",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"label": "Feedback Filter (Net)",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("credit", 3)],
				"msg": "prevent 1 net damage",
				"req": func(state, side, eid, card, targets): return ((("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
			{
			"prevents": "damage",
			"type": "ability",
			"label": "Feedback Filter (Core)",
			"ability": NRUtil.merge(prevent_up_to_n_damage(2, ["brain", "core"]) if prevent_up_to_n_damage(2, ["brain", "core"]) is Dictionary else {}, {"cost": [NRPayment.to_c("trash-can")]}),
		},
		],
	}))

	NRCardDefs.defcard("Flame-out", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Flame-out can host a single program.\nWhen you install Flame-out, place 9[Credits] on it. Use these credits to pay for using hosted program.\nWhen a turn ends in which you used credits on Flame-out, trash hosted program.",
		"code": "21109",
		"title": "Flame-out",
	}, (func():
		var register_flame_effect = func(state, card): return NRUpdate.update_card(state, "runner", NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "flame-out-trigger"], true))
		var maybe_turn_end = {
			"async": true,
			"automatic": "last",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(NRCardXlate.getk(NRCard.get_card(state, card), "special", null), "flame-out-trigger", null),
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "flame-out-trigger"], null))
				return (func():
				var hosted = NRUtil.first_of(NRCardXlate.getk(card, "hosted", null))
				return (func():
				NRSay.system_msg(state, "runner", (str("trashes ") + str(NRCardXlate.getk(hosted, "title", null)) + str(" from Flame-out")))
				return NRMoving.trash(state, side, eid, hosted, {
					"cause-card": card,
				})
			).call() if hosted != null else NREid.effect_completed(state, side, eid)
			).call(),
		}
		return {
			"implementation": "Credit usage restriction not enforced",
			"static-abilities": [
				{
				"type": "can-host",
				"req": func(state, side, eid, card, targets): return NRCard.program(NRCardXlate.first_target(targets)),
				"max-cards": 1,
			},
			],
			"data": {
				"counter": {
					"credit": 9,
				},
			},
			"abilities": [
				{
				"label": "Take 1 hosted [Credits]",
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty()) and (NRCard.get_counters(card, "credit") > 0)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRSay.system_msg(state, "runner", "takes 1 hosted [Credits] from Flame-out")
					register_flame_effect(state, card)
					return spend_credits(state, side, eid, card, "credit", 1),
			},
				{
				"label": "Take all hosted [Credits]",
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty()) and (NRCard.get_counters(card, "credit") > 0)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var credits = NRCard.get_counters(card, "credit")
					return (func():
						NRSay.system_msg(state, "runner", (str("takes ") + str(credits) + str(" hosted [Credits] from Flame-out")))
						register_flame_effect(state, card)
						return NRCardXlate.take_credits(state, side, eid, card, "credit", "all")
					).call()
				).call(),
			},
			],
			"events": [
				NRUtil.merge(maybe_turn_end if maybe_turn_end is Dictionary else {}, {"event": "runner-turn-ends"}),
				NRUtil.merge(maybe_turn_end if maybe_turn_end is Dictionary else {}, {"event": "corp-turn-ends"}),
			],
			"interactions": {
				"pay-credits": {
					"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null)) and (NRCard.get_counters(card, "credit") > 0)),
					"custom-amount": 1,
					"custom": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "credit", -1, {
						"suppress-checkpoint": true,
					})
					, func(async_result):
						(func():
						register_flame_effect(state, card)
						return NREid.effect_completed(state, side, NREid.make_result(eid, 1))
					).call()),
					"type": "custom",
				},
			},
		}
	).call()))

	NRCardDefs.defcard("Flip Switch", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Use this hardware only during your turn.\n[Trash]<strong>:</strong> Jack out.\n[Trash]<strong>:</strong> Remove 1 tag.\n[interrupt] → [Trash]<strong>:</strong> Reduce the base trace strength of a trace to 0.",
		"code": "26013",
		"title": "Flip Switch",
	}, {
		"events": [
			{
			"event": "initialize-trace",
			"optional": {
				"req": func(state, side, eid, card, targets): return (("runner" == NRCardXlate.getk(state, "active-player", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(state, "active-player", null))),
				"waiting-prompt": true,
				"prompt": "Trash Flip Switch to reduce the base trace strength to 0?",
				"yes-ability": {
					"msg": "reduce the base trace strength to 0",
					"cost": [NRPayment.to_c("trash-can")],
					"effect": func(state, side, eid, card, targets):
						return state.assoc_in(["trace", "force-base"], 0),
				},
			},
		},
		],
		"abilities": [
			{
			"label": "Jack out",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return (state.getv("run") or NRRuns.get_current_encounter(state)),
			},
			"req": func(state, side, eid, card, targets): return (("runner" == NRCardXlate.getk(state, "active-player", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(state, "active-player", null))),
			"msg": "jack out",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.jack_out(state, side, eid),
		},
			{
			"label": "Remove 1 tag",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return (count_real_tags(state) > 0),
			},
			"req": func(state, side, eid, card, targets): return (("runner" == NRCardXlate.getk(state, "active-player", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(state, "active-player", null))),
			"msg": "remove 1 tag",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Forger", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[link]\n[interrupt] → <strong>[Trash]:</strong> Prevent 1 tag.\n<strong>[Trash]:</strong> Remove 1 tag.\nLimit 1 <strong>console</strong> per player.",
		"code": "08065",
		"title": "Forger",
	}, (func():
		var avoid_ab = {
			"msg": "avoid 1 tag",
			"label": "Avoid 1 tag",
			"async": true,
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return prevent_tag(state, "runner", eid, 1),
		}
		return {
			"events": [
				NRChooseOne.choose_one({
				"event": "tag-interrupt",
				"req": func(state, side, eid, card, targets): return ((state.get_in(["prevent", "tag", "remaining"], null) > 0) and (not (NREffects.any_effects(state, side, "prevent-paid-ability", true_p, card, [avoid_ab, 0])))),
				"optional": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
			}, [
				{
				"option": "Avoid 1 tag",
				"cost": [NRPayment.to_c("trash-can")],
				"ability": avoid_ab,
			},
			]),
			],
			"static-abilities": [NRCardXlate.link_plus(1)],
			"abilities": [
				{
				"msg": "remove 1 tag",
				"label": "Remove 1 tag",
				"cost": [NRPayment.to_c("trash-can")],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (count_real_tags(state) > 0),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRTags.lose_tags(state, side, eid, 1),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Friday Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "Whenever you trash a Corp card, you may place 1 virus counter on Friday Chip.\nWhen your turn begins, you may move 1 hosted virus counter to a <strong>virus</strong> program.",
		"code": "21042",
		"title": "Friday Chip",
	}, (func():
		var ability = {
			"msg": func(state, side, eid, card, targets): return str("move 1 virus counter to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"skippable": true,
			"req": func(state, side, eid, card, targets): return ((NRCard.get_counters(card, "virus") > 0) and (NRVirus.count_virus_programs(state) > 0)),
			"choices": {
				"card": virus_program_p,
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, "runner", ne, card, "virus", -1, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRProps.add_counter(state, "runner", eid, NRCardXlate.first_target(targets), "virus", 1)),
		}
		return {
			"abilities": [
				NROptional.set_autoresolve("auto-fire", "Friday Chip placing virus counters on itself"),
			],
			"special": {
				"auto-fire": "always",
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				{
				"event": "runner-trash",
				"once-per-instance": true,
				"async": true,
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.corp(NRCardXlate.getk(_pct, "card", null))) != null),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var amt_trashed = NRUtil.as_array(NRUtil.as_array(targets).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.corp(NRCardXlate.getk(_pct, "card", null)))).size()
					var sing_ab = {
						"optional": {
							"prompt": func(state, side, eid, card, targets): return str("Place a virus counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
							"autoresolve": NROptional.get_autoresolve("auto-fire"),
							"yes-ability": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to place 1 virus counter on itself")))
									return NRProps.add_counter(state, "runner", eid, card, "virus", 1),
							},
						},
					}
					var mult_ab = {
						"prompt": func(state, side, eid, card, targets): return str("Place virus counters on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
						"choices": {
							"number": func(state, side, eid, card, targets):
								return amt_trashed,
							"default": func(state, side, eid, card, targets):
								return amt_trashed,
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to place ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "virus counter")) + str(" on itself")))
							return NRProps.add_counter(state, "runner", eid, card, "virus", NRCardXlate.first_target(targets)),
					}
					var ab = (mult_ab if (amt_trashed > 1) else sing_ab)
					return NREngine.continue_ability(state, side, ab, card, targets)
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Gachapon", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "<strong>[Trash]:</strong> Set aside the top 6 cards of your stack faceup. You may install 1 program or <strong>virtual</strong> resource from among those cards, paying 2[Credits] less. Shuffle 3 of the remaining cards into your stack, then remove the rest from the game.",
		"code": "26069",
		"title": "Gachapon",
	}, (func():
		var _b0 = shuffle_next([set_aside_cards, NRCardXlate.first_target(targets), to_shuffle], (func():
			var set_aside_cards = remove_once(func(_pct, _pct2=null, _pct3=null): return ((_pct == NRCardXlate.first_target(targets)) or NRUtil.kw_eq(_pct, NRCardXlate.first_target(targets))), set_aside_cards)
			var to_shuffle = ((NRUtil.as_array(to_shuffle) + NRUtil.as_array([NRCardXlate.first_target(targets)])) if NRCardXlate.first_target(targets) else [])
			var finished_p = (((3 == NRUtil.as_array(to_shuffle).size()) or NRUtil.kw_eq(3, NRUtil.as_array(to_shuffle).size())) or (set_aside_cards is Array and set_aside_cards.is_empty() if false else (str(set_aside_cards) == "")))
			return {
				"prompt": func(state, side, eid, card, targets): return str(((str("Removing: ") + str((NRUtil.enumerate_cards(set_aside_cards, "sorted") if (not NRUtil.as_array(set_aside_cards).is_empty()) else "nothing")) + str("[br]Shuffling: ") + str((NRUtil.enumerate_cards(to_shuffle, "sorted") if (not NRUtil.as_array(to_shuffle).is_empty()) else "nothing"))) if finished_p else (str("Choose ") + str((3 - NRUtil.as_array(to_shuffle).size())) + str(" more cards to shuffle back.") + str(((str("[br]Currently shuffling back: ") + str(NRUtil.enumerate_cards(to_shuffle, "sorted"))) if (not NRUtil.as_array(to_shuffle).is_empty()) else null))))),
				"async": true,
				"not-distinct": true,
				"choices": func(state, side, eid, card, targets):
					return (["Done", "Start over"] if finished_p else (not NRUtil.as_array(set_aside_cards).is_empty())),
				"effect": func(state, side, eid, card, targets):
					return ((NREngine.continue_ability(state, side, shuffle_end(set_aside_cards, to_shuffle), card, null) if (("Done" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Done", NRCardXlate.first_target(targets))) else NREngine.continue_ability(state, side, shuffle_next(NRUtil.as_array((NRUtil.as_array(set_aside_cards) + NRUtil.as_array(to_shuffle))), null, null), card, null)) if finished_p else NREngine.continue_ability(state, side, shuffle_next(set_aside_cards, NRCardXlate.first_target(targets), to_shuffle), card, null)),
			}
		).call())
		return {
			"abilities": [
				{
				"label": "Install a card from among the top 6 cards of the stack",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					NRSetAside.set_aside(state, side, eid, NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(6)))
					return (func():
					var set_aside_cards = NRUtil.as_array(NRSetAside.get_set_aside(state, side, eid))
					return (func():
						NRSay.system_msg(state, side, (str(NRCardXlate.getk(eid, "latest-payment-str", null)) + str(" to use ") + str(NRCard.get_title(card)) + str(" to set aside ") + str(NRUtil.enumerate_cards(set_aside_cards)) + str(" from the top of the stack")))
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, {
							"async": true,
							"prompt": (str("The set aside cards are: ") + str(NRUtil.enumerate_cards(set_aside_cards))),
							"choices": ["OK"],
						}, card, null)
						, func(async_result):
							NREngine.continue_ability(state, side, {
							"prompt": "Choose a card to install",
							"async": true,
							"choices": func(state, side, eid, card, targets):
								return (NRUtil.as_array(NRUtil.as_array(set_aside_cards).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCard.program(_pct) or (NRCard.resource(_pct) and NRCard.has_subtype(_pct, "Virtual"))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
								"cost-bonus": -2,
								"no-toast": true,
							})))) + NRUtil.as_array(["Done"])),
							"effect": func(state, side, eid, card, targets):
								return (NREngine.continue_ability(state, side, shuffle_next(set_aside_cards, null, null), card, null) if (("Done" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Done", NRCardXlate.first_target(targets))) else (func():
								var set_aside_cards = remove_once(func(_pct, _pct2=null, _pct3=null): return ((_pct == NRCardXlate.first_target(targets)) or NRUtil.kw_eq(_pct, NRCardXlate.first_target(targets))), set_aside_cards)
								var new_eid = NRUtil.merge(eid if eid is Dictionary else {}, {"source": card})
								return NREid.wait_for(state, eid, func(ne):
									NRInstalling.runner_install(state, side, ne, new_eid, NRCardXlate.first_target(targets), {
									"cost-bonus": -2,
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								})
								, func(async_result):
									NREngine.continue_ability(state, side, shuffle_next(set_aside_cards, null, null), card, null))
							).call()),
						}, card, null))
					).call()
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("GAMEDRAGON™ Pro", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "When you install this hardware and when your turn begins, you may host this hardware on an installed non-<strong>AI</strong> <strong>icebreaker</strong>.\nHost <strong>icebreaker</strong> gets +1 strength. Abilities that increase its strength last for the remainder of the run <em>(instead of any shorter duration)</em>.",
		"code": "35027",
		"title": "GAMEDRAGON™ Pro",
	}, (func():
		var abi = {
			"prompt": "Choose an icebreaker to host GAMEDRAGON™ Pro",
			"event": "runner-turn-begins",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and (not (NRCard.has_subtype(_pct, "AI"))) and (not (NRUtil.same_card(_pct, NRCardXlate.getk(card, "host", null)))) and NRCard.has_subtype(_pct, "Icebreaker"))) != null),
			},
			"waiting-prompt": true,
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and NRCard.program(NRCardXlate.first_target(targets)) and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "AI"))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
			},
			"effect": func(state, side, eid, card, targets):
				return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
			"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
		}
		return {
			"on-install": abi,
			"events": [
				abi,
				{
				"event": "pump-breaker",
				"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(card, "host", null)),
				"effect": func(state, side, eid, card, targets):
					(func():
					var new_pump = NRUtil.merge(NRCardXlate.getk(NRCardXlate.ctx(targets), "effect", null) if NRCardXlate.getk(NRCardXlate.ctx(targets), "effect", null) is Dictionary else {}, {"duration": "end-of-run"})
					return state.setv("effects", (NRUtil.as_array([]) + NRUtil.as_array((func(_pct, _pct2=null, _pct3=null): return (NRUtil.as_array(_pct) + [new_pump])).call(NRUtil.as_array(NRCardXlate.getk(state, "effects", null)).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "uuid", null) == NRCardXlate.getk(new_pump, "uuid", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "uuid", null), NRCardXlate.getk(new_pump, "uuid", null)))).call(_x)))))))
				).call()
					return NRIce.update_breaker_strength(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			},
			],
			"static-abilities": [
				{
				"type": "breaker-strength",
				"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
				"value": 1,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Gebrselassie", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "[Click]: Host this hardware on an installed non-AI <strong>icebreaker</strong>.\nAbilities that increase host icebreaker's strength last for the remainder of the turn <em>(instead of any shorter duration)</em>.",
		"code": "21087",
		"title": "Gebrselassie",
	}, {
		"abilities": [
			{
			"action": true,
			"msg": "host itself on an installed non-AI icebreaker",
			"cost": [NRPayment.to_c("click", 1)],
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Icebreaker") and (not (NRCard.has_subtype(_pct, "AI")))),
			},
			"effect": func(state, side, eid, card, targets):
				(func():
				var host = NRCard.get_card(state, NRCardXlate.getk(card, "host", null))
				return state.setv("effects", reduce(func(effects, e): return (NRUtil.as_array(effects) + [(NRUtil.dissoc(NRUtil.merge(e if e is Dictionary else {}, {"duration": NRCardXlate.getk(e, "original-duration", null)}) if NRUtil.merge(e if e is Dictionary else {}, {"duration": NRCardXlate.getk(e, "original-duration", null)}) is Dictionary else {}, ["original-duration"]) if (NRUtil.same_card(NRHosting.host, NRCardXlate.getk(e, "card", null)) and (("breaker-strength" == NRCardXlate.getk(e, "type", null)) or NRUtil.kw_eq("breaker-strength", NRCardXlate.getk(e, "type", null))) and NRCardXlate.getk(e, "original-duration", null)) else e)]), [], NRCardXlate.getk(state, "effects", null))) if host != null else NRIce.update_breaker_strength(state, side, NRHosting.host)
			).call()
				return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
		},
		],
		"events": [
			{
			"event": "pump-breaker",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(card, "host", null)),
			"effect": func(state, side, eid, card, targets):
				(func():
				var last_pump = NRUtil.merge(NRCardXlate.getk(NRCardXlate.ctx(targets), "effect", null) if NRCardXlate.getk(NRCardXlate.ctx(targets), "effect", null) is Dictionary else {}, {"duration": "end-of-turn"})
				return state.setv("effects", (NRUtil.as_array([]) + NRUtil.as_array((func(_pct, _pct2=null, _pct3=null): return (NRUtil.as_array(_pct) + [last_pump])).call(NRUtil.as_array(NRCardXlate.getk(state, "effects", null)).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(last_pump, "uuid", null) == NRCardXlate.getk(_pct, "uuid", null)) or NRUtil.kw_eq(NRCardXlate.getk(last_pump, "uuid", null), NRCardXlate.getk(_pct, "uuid", null)))).call(_x)))))))
			).call()
				return NRIce.update_breaker_strength(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
		},
		],
		"leave-play": func(state, side, eid, card, targets):
			return (func():
			var host = NRCard.get_card(state, NRCardXlate.getk(card, "host", null))
			return state.setv("effects", reduce(func(effects, e): return (NRUtil.as_array(effects) + [(NRUtil.dissoc(NRUtil.merge(e if e is Dictionary else {}, {"duration": NRCardXlate.getk(e, "original-duration", null)}) if NRUtil.merge(e if e is Dictionary else {}, {"duration": NRCardXlate.getk(e, "original-duration", null)}) is Dictionary else {}, ["original-duration"]) if (NRUtil.same_card(NRHosting.host, NRCardXlate.getk(e, "card", null)) and (("breaker-strength" == NRCardXlate.getk(e, "type", null)) or NRUtil.kw_eq("breaker-strength", NRCardXlate.getk(e, "type", null))) and NRCardXlate.getk(e, "original-duration", null)) else e)]), [], NRCardXlate.getk(state, "effects", null))) if host != null else NRIce.update_breaker_strength(state, side, NRHosting.host)
		).call(),
	}))

	NRCardDefs.defcard("Ghosttongue", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, suffer 1 core damage.\nThe play cost of each event is lowered by 1[Credits].",
		"code": "33005",
		"title": "Ghosttongue",
	}, {
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
		"static-abilities": [
			{
			"type": "play-cost",
			"req": func(state, side, eid, card, targets): return NRCard.event(NRCardXlate.first_target(targets)),
			"value": -1,
		},
		],
	}))

	NRCardDefs.defcard("GPI Net Tap", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you approach a piece of ice, you may expose it. You may then trash GPI Net Tap to jack out.",
		"code": "11003",
		"title": "GPI Net Tap",
	}, {
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return ((("approach-ice" == NRCardXlate.getk(state.getv("run"), "phase", null)) or NRUtil.kw_eq("approach-ice", NRCardXlate.getk(state.getv("run"), "phase", null))) and NRCard.ice(NRIce.get_current_ice(state)) and (not (NRCard.rezzed(NRIce.get_current_ice(state))))),
			"label": "expose approached ice",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRExpose.expose(state, side, ne, NREid.make_eid(state, eid), [NRIce.get_current_ice(state)])
			, func(async_result):
				NREngine.continue_ability(state, side, NRDefHelpers.offer_jack_out(), card, null)),
		},
		],
	}))

	NRCardDefs.defcard("Grimoire", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nWhenever you install a <strong>virus</strong> program, place 1 virus counter on that program.\nLimit 1 <strong>console</strong> per player.",
		"code": "01006",
		"title": "Grimoire",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			{
			"event": "runner-install",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Virus"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "virus", 1),
		},
		],
	}))

	NRCardDefs.defcard("Heartbeat", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Apex",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\n[interrupt] → <strong>Trash 1 of your installed cards:</strong> Prevent 1 damage.\nLimit 1 <strong>console</strong> per player.",
		"code": "09032",
		"title": "Heartbeat",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"label": "Heartbeat",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("trash-installed", 1)],
				"msg": func(state, side, eid, card, targets): return str("prevent 1 ") + str(damage_name(state)) + str(" damage"),
				"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
		],
	}))

	NRCardDefs.defcard("Hermes", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever an agenda is scored or stolen, add 1 unrezzed card to HQ.\nLimit 1 <strong>console</strong> per player.",
		"code": "34014",
		"title": "Hermes",
	}, (func():
		var ab = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Choose an unrezzed card",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.faceup(_pct))) and NRCard.installed(_pct))) != null),
			},
			"waiting-prompt": true,
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.faceup(_pct))) and NRCard.installed(_pct) and NRCard.corp(_pct)),
				"all": true,
			},
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" to HQ"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "hand"),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"events": [
				NRUtil.merge(ab if ab is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(ab if ab is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Hijacked Router", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"text": "Whenever the Corp creates a server, they lose 1[Credits].\nWhenever you make a successful run on Archives, you may trash this hardware. If you do, the Corp loses 3[Credits].",
		"code": "22005",
		"title": "Hijacked Router",
	}, {
		"events": [
			{
			"event": "server-created",
			"msg": "force the Corp to lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "corp", eid, 1),
		},
			{
			"event": "successful-run",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (("archives" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("archives", NRServers.target_server(NRCardXlate.ctx(targets)))),
				"prompt": func(state, side, eid, card, targets): return str("Trash ") + str(NRCardXlate.getk(card, "title", null)) + str(" to force the Corp to lose 3 [Credits]?"),
				"yes-ability": {
					"async": true,
					"msg": "force the Corp to lose 3 [Credits]",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, "runner", ne, card, {
						"unpreventable": true,
						"cause-card": card,
					})
					, func(async_result):
						NRGaining.lose_credits(state, "corp", eid, 3)),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Hippo", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 5,
		"uniqueness": true,
		"text": "The first time each turn you fully break the outermost piece of ice protecting the attacked server during a run, you may remove this hardware from the game to trash that ice.",
		"code": "21103",
		"title": "Hippo",
	}, {
		"events": [
			{
			"event": "subroutines-broken",
			"optional": {
				"req": func(state, side, eid, card, targets): return (func():
					var pred = func(_x): return ((func(_x): return bool(NRCardXlate.getk(_x, "all-subs-broken"))).call(_x)) and ((func(_x): return bool(NRCardXlate.getk(_x, "outermost"))).call(_x)) and ((func(_x): return bool(NRCardXlate.getk(_x, "during-run"))).call(_x)) and ((func(_x): return bool(NRCardXlate.getk(_x, "on-attacked-server"))).call(_x))
					return (pred(NRCardXlate.ctx(targets)) and NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and NREvents.first_event(state, side, "subroutines-broken", func(_pct, _pct2=null, _pct3=null): return pred(NRUtil.first_of(_pct))))
				).call(),
				"prompt": func(state, side, eid, card, targets): return str("Remove this hardware from the game to trash ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)) + str("?"),
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("remove-from-game")],
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), {
						"cause-card": card,
					}),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Hippocampic Mechanocytes", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, place 2 power counters on it and suffer 1 meat damage.\nYou get +1 maximum hand size for each hosted power counter.",
		"code": "33085",
		"title": "Hippocampic Mechanocytes",
	}, {
		"on-install": {
			"async": true,
			"msg": "suffer 1 meat damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "meat", 1, {
				"unboostable": true,
				"card": card,
			}),
		},
		"data": {
			"counter": {
				"power": 2,
			},
		},
		"static-abilities": [
			runner_hand_size_(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
		],
	}))

	NRCardDefs.defcard("HQ Interface", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you breach HQ, access 1 additional card.",
		"code": "25031",
		"title": "HQ Interface",
	}, {
		"events": [breach_access_bonus("hq", 1)],
	}))

	NRCardDefs.defcard("Jeitinho", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "When your turn ends, if you made a successful run on HQ, R&D, and Archives this turn, you may add this hardware to your score area as an <strong>assassination</strong> agenda worth 0 agenda points. Then, if you have 3 <strong>assassination</strong> agendas in your score area, you win the game.\nThreat 3 → Whenever you bypass a piece of ice, you may spend [Click] to install this hardware from your heap.",
		"code": "34079",
		"title": "Jeitinho",
	}, {
		"events": [
			{
			"event": "bypassed-ice",
			"location": "discard",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (NRThreat.threat_level(3, state) and NRCard.in_discard(card)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": "Install this hardware from the heap?",
					"yes-ability": {
						"cost": [NRPayment.to_c("lose-click", 1)],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
							var target_card = NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "printed-title", null) == NRCardXlate.getk(card, "printed-title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "printed-title", null), NRCardXlate.getk(card, "printed-title", null)))))
							return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), target_card, {
								"msg-keys": {
									"display-origin": true,
									"install-source": card,
								},
							})
						).call(),
					},
				},
			}, card, null),
		},
			{
			"event": "runner-turn-ends",
			"req": func(state, side, eid, card, targets): return (NRCard.installed(card) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
			"msg": "add itself to the score area as an assassination agenda worth 0 agenda points",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRMoving.as_agenda(state, "runner", card, 0)
				return ((func():
				NRSay.system_msg(state, side, "wins the game")
				NRWinning.win(state, "runner", "assassination plot (Jeitinho)")
				return NREid.effect_completed(state, side, eid)
			).call() if ((3 == NRUtil.as_array(NRUtil.as_array(state.get_in(["runner", "scored"], null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "printed-title", null) == NRCardXlate.getk(card, "printed-title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "printed-title", null), NRCardXlate.getk(card, "printed-title", null))))).size()) or NRUtil.kw_eq(3, NRUtil.as_array(NRUtil.as_array(state.get_in(["runner", "scored"], null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "printed-title", null) == NRCardXlate.getk(card, "printed-title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "printed-title", null), NRCardXlate.getk(card, "printed-title", null))))).size())) else NREid.effect_completed(state, side, eid)),
		},
		],
	}))

	NRCardDefs.defcard("Keiko", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console - Companion",
		"subtypes": ["Console", "Companion"],
		"text": "+2[Memory Unit]\nThe first time each turn you install a <strong>companion</strong> card or spend credits from an installed <strong>companion</strong> card, gain 1[Credits].\nLimit 1 <strong>console</strong> per player.",
		"code": "26070",
		"title": "Keiko",
	}, (func():
		var _b0 = valid_ctx_p([[{
			"keys": [card],
			"as": ctx,
		}, _, rem]], ((func(_x): return ((NRCard.runner).call(_x)) and ((NRCard.installed).call(_x)) and ((companion_p).call(_x))).call(card) or (rem and valid_ctx_p(rem))))
		return {
			"static-abilities": [NRCardXlate.mu_plus(2)],
			"events": [
				{
				"event": "spent-credits-from-card",
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return valid_ctx_p([_pct])) != null) and NREvents.first_event(state, side, "spent-credits-from-card", valid_ctx_p) and NREvents.no_event(state, side, "runner-install", func(_pct, _pct2=null, _pct3=null): return companion_p(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
				"msg": "gain 1 [Credit]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "runner", eid, 1),
			},
				{
				"event": "runner-install",
				"req": func(state, side, eid, card, targets): return (companion_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and NREvents.first_event(state, side, "runner-install", func(_pct, _pct2=null, _pct3=null): return companion_p(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))) and NREvents.no_event(state, side, "spent-credits-from-card", valid_ctx_p)),
				"msg": "gain 1 [Credit]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "runner", eid, 1),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Knobkierie", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+3[Memory Unit]\nUse the MU on Knobkierie only for <strong>virus</strong> programs.\nThe first time you make a successful run each turn, you may place 1 virus counter on an installed <strong>virus</strong> program.\nLimit 1 <strong>console</strong> per player.",
		"code": "21062",
		"title": "Knobkierie",
	}, {
		"static-abilities": [virus_mu_(3)],
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, "runner", "successful-run") and (NRVirus.count_virus_programs(state) > 0)),
				"prompt": "Place 1 virus counter?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"prompt": "Choose an installed virus program to place 1 virus counter on",
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Virus") and NRCard.program(_pct)),
					},
					"msg": func(state, side, eid, card, targets): return str("place 1 virus counter on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, NRCardXlate.first_target(targets), "virus", 1),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Knobkierie")],
	}))

	NRCardDefs.defcard("Lemuria Codecracker", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[Click], 1[Credits]: Expose 1 card. Use this ability only if you have made a successful run on HQ this turn.",
		"code": "01023",
		"title": "Lemuria Codecracker",
	}, {
		"abilities": [
			{
			"action": true,
			"async": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 1)],
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null),
			"choices": {
				"card": NRCard.installed,
			},
			"label": "Expose a card",
			"effect": func(state, side, eid, card, targets):
				return NRExpose.expose(state, side, eid, [NRCardXlate.first_target(targets)], {
				"card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("LilyPAD", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nThe first time each turn you install a program, you may draw 1 card.\nLimit 1 <strong>console</strong> per player.",
		"code": "34023",
		"title": "LilyPAD",
	}, {
		"events": [
			{
			"event": "runner-install",
			"optional": {
				"prompt": "Draw 1 card?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)) and NREvents.first_event(state, "runner", "runner-install", func(_pct, _pct2=null, _pct3=null): return NRCard.program(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": NRDefHelpers.draw_ability(1),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"abilities": [NROptional.set_autoresolve("auto-fire", "LilyPAD")],
	}))

	NRCardDefs.defcard("LLDS Memory Diamond", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "+1[Memory Unit], +1[link]\nYour maximum hand size is increased by 1.",
		"code": "13015",
		"title": "LLDS Memory Diamond",
	}, {
		"static-abilities": [NRCardXlate.link_plus(1), runner_hand_size_(1), NRCardXlate.mu_plus(1)],
	}))

	NRCardDefs.defcard("LLDS Processor", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "Whenever you install an <strong>icebreaker</strong>, that <strong>icebreaker</strong> has +1 strength until the end of the turn.",
		"code": "04066",
		"title": "LLDS Processor",
	}, {
		"events": [
			{
			"event": "runner-install",
			"silent": true,
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Icebreaker"),
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), 1, "end-of-turn"),
		},
		],
	}))

	NRCardDefs.defcard("Lockpick", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Chip - Stealth",
		"subtypes": ["Chip", "Stealth"],
		"text": "1[recurring-credit]\nUse this credit to pay for using <strong>decoders</strong>.",
		"code": "04006",
		"title": "Lockpick",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Decoder") and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Logos", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nYour maximum hand size is increased by 1.\nWhenever the Corp scores an agenda, you may search your stack for a card and add it to your grip. Shuffle your stack.\nLimit 1 <strong>console</strong> per player.",
		"code": "05037",
		"title": "Logos",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1), runner_hand_size_(1)],
		"events": [
			{
			"event": "agenda-scored",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"optional": {
				"prompt": "Search for a card?",
				"waiting-prompt": true,
				"yes-ability": {
					"prompt": "Choose a card",
					"msg": "add 1 card from the stack to the grip",
					"choices": func(state, side, eid, card, targets):
						return NRCardXlate.getk(state.getv("runner", {}), "deck", null),
					"effect": func(state, side, eid, card, targets):
						NREngine.trigger_event(state, side, "searched-stack")
						NRShuffling.shuffle_zone(state, side, "deck")
						return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Lucky Charm", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "[interrupt] → <strong>Remove this hardware from the game:</strong> Prevent a Corp card ability from ending the run. Use this ability only if you made a successful run on HQ this turn.",
		"code": "26014",
		"title": "Lucky Charm",
	}, {
		"prevention": [
			{
			"prevents": "end-run",
			"type": "ability",
			"ability": {
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null) > 0) and (("corp" == state.get_in(["prevent", "end-run", "source-player"], null)) or NRUtil.kw_eq("corp", state.get_in(["prevent", "end-run", "source-player"], null)))),
				"cost": [NRPayment.to_c("remove-from-game")],
				"async": true,
				"msg": "prevent the run from ending",
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_end_run(state, side, eid),
			},
		},
		],
	}))

	NRCardDefs.defcard("Mâché", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"text": "The first time you trash an accessed card each turn, you may place power counters on Mâché equal to that card's trash cost.\n<strong>3 hosted power counters</strong>: Draw 1 card.",
		"code": "22018",
		"title": "Mâché",
	}, (func():
		return {
			"abilities": [
				NRDefHelpers.draw_ability(1, null, {
				"cost": [NRPayment.to_c("power", 3)],
				"keep-menu-open": "while-3-power-tokens-left",
			}),
			],
			"events": [
				{
				"event": "runner-trash",
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), pred) != null) and NREvents.first_event(state, side, "runner-trash", func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), pred) != null))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var target = (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return (NRCardXlate.getk(_pct, "card", null) if pred(_pct) else null)) != null)
					var cost = trash_cost(state, side, NRCardXlate.first_target(targets))
					return ((func():
						NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to place ") + str(NRUtil.quantify(cost, "power counter")) + str(" on itself")))
						return NRProps.add_counter(state, side, eid, card, "power", cost)
					).call() if cost else NREid.effect_completed(state, side, eid))
				).call(),
			},
			],
		}
	).call()))


static func _register_3() -> void:
	NRCardDefs.defcard("Madani", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "[Click]<strong>:</strong> Host any number of programs from your grip faceup on this hardware. <em>(They are not installed.)</em>\nOnce per turn → <strong>0[Credits]:</strong> Install 1 hosted program <em>(paying its install cost)</em>.\nLimit 1 <strong>console</strong> per player.",
		"code": "35028",
		"title": "Madani",
	}, {
		"static-abilities": [],
		"abilities": [
			{
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Host any number of programs",
			"prompt": "Choose any number of program",
			"action": true,
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.in_hand(NRCardXlate.first_target(targets)) and NRCard.program(NRCardXlate.first_target(targets))),
				"max": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).filter(NRCard.program)).size(),
			},
			"msg": func(state, side, eid, card, targets): return str("host ") + str(NRUtil.enumerate_cards(targets, "sorted")),
			"effect": func(state, side, eid, card, targets):
				return (func():
				for t in NRUtil.as_array(targets):
					NRHosting.host(state, side, card, t)
				return null
			).call(),
		},
			{
			"cost": [NRPayment.to_c("credit", 0)],
			"label": "Install a hosted program",
			"async": true,
			"once": "per-turn",
			"prompt": "Choose a hosted program to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, eid, NRCardXlate.first_target(targets), {
					"no-toast": true,
				}) and NRUtil.same_card(NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null), card)),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
				"display-origin": true,
				"install-source": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Maglectric Rapid (748 Mod)", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "Whenever you make a successful run on HQ, you may trash this hardware to derez 1 installed Corp card.",
		"code": "35019",
		"title": "Maglectric Rapid (748 Mod)",
	}, {
		"events": [
			{
			"event": "successful-run",
			"prompt": "Derez a card?",
			"skippable": true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return ((NRCard.rezzed).call(_x)) and ((func(_x): return not NRCard.agenda.call(_x)).call(_x))) != null)),
			"choices": {
				"card": func(_x): return ((NRCard.installed).call(_x)) and ((NRCard.corp).call(_x)) and ((NRCard.rezzed).call(_x)) and ((func(_x): return not NRCard.agenda.call(_x)).call(_x)),
			},
			"cost": [NRPayment.to_c("trash-self", 1)],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets)),
		},
		],
	}))

	NRCardDefs.defcard("Marrow", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console - Cybernetic",
		"subtypes": ["Console", "Cybernetic"],
		"text": "+1[Memory Unit]\nYou get +3 maximum hand size.\nWhen you install this hardware, suffer 1 core damage.\nWhenever the Corp scores an agenda, sabotage 1. <em>(The Corp trashes 1 card of their choice from HQ or the top of R&D.)</em>\nLimit 1 <strong>console</strong> per player.",
		"code": "33006",
		"title": "Marrow",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1), runner_hand_size_(3)],
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
		"events": [
			NRUtil.merge(NRSabotage.sabotage(1) if NRSabotage.sabotage(1) is Dictionary else {}, {"event": "agenda-scored"}),
		],
	}))

	NRCardDefs.defcard("Masterwork (v37)", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nThe first time each turn you install a piece of hardware, draw 1 card.\nWhenever a run begins, you may install 1 piece of hardware from your grip, paying 1[Credits] more.\nLimit 1 <strong>console</strong> per player.",
		"code": "26015",
		"title": "Masterwork (v37)",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "run",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()),
			},
			"optional": {
				"prompt": "Pay 1 [Credit] to install a piece of hardware?",
				"yes-ability": {
					"async": true,
					"prompt": "Choose a piece of hardware",
					"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (NRCard.hardware(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
						"cost-bonus": 1,
					}))) != null),
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRCard.hardware(NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
							"cost-bonus": 1,
						})),
					},
					"effect": func(state, side, eid, card, targets):
						return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
						"cost-bonus": 1,
						"msg-keys": {
							"display-origin": true,
							"install-source": card,
						},
					}),
				},
			},
		},
			NRDefHelpers.draw_ability(1, null, {
			"event": "runner-install",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (NRCard.hardware(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and NREvents.first_event(state, side, "runner-install", func(_pct, _pct2=null, _pct3=null): return NRCard.hardware(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
		}),
		],
	}))

	NRCardDefs.defcard("Māui", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nX[recurring-credit]\nUse these credits during runs on HQ. X is the number of pieces of ice protecting HQ.\nLimit 1 <strong>console</strong> per player.",
		"code": "12063",
		"title": "Māui",
	}, {
		"x-fn": func(state, side, eid, card, targets):
			return NRUtil.as_array(NRUtil.get_in(state.getv("corp", {}), ["servers", "hq", "ices"], null)).size(),
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"recurring": get_x_fn(),
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((["hq"] == state.get_in(["run", "server"], null)) or NRUtil.kw_eq(["hq"], state.get_in(["run", "server"], null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Maw", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 6,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nThe first time each turn you access a card not in Archives and do not steal or trash it, the Corp must trash 1 card from HQ at random.\nLimit 1 <strong>console</strong> per player.",
		"code": "12002",
		"title": "Maw",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			{
			"event": "post-access-card",
			"label": "Trash a card from HQ",
			"async": true,
			"req": func(state, side, eid, card, targets): return (((1 == state.get_in(["runner", "register", "no-trash-or-steal"], null)) or NRUtil.kw_eq(1, state.get_in(["runner", "register", "no-trash-or-steal"], null))) and (NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() > 0) and (not (NRCard.in_discard(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)))) and (not (NRCard.in_scored(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))))),
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return (func():
				var card_to_trash = NRUtil.first_of(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null)))
				var card_seen_p = NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), card_to_trash)
				var card_to_trash = (NRUtil.merge(card_to_trash if card_to_trash is Dictionary else {}, {"seen": true}) if card_seen_p else card_to_trash)
				return NREngine.continue_ability(state, side, {
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, "corp", eid, card_to_trash, {
						"cause-card": card,
						"cause": "forced-to-trash",
					}),
					"async": true,
					"msg": (str("force the Corp to trash a random card from HQ") + str(((func():
						" ("
						NRCardXlate.getk(card_to_trash, "title", null)
						return ")"
					).call() if card_seen_p else null))),
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Maya", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nOnce per turn → When you finish accessing a card in R&D, you may add that card to the bottom of R&D. If you do, take 1 tag.\nLimit 1 <strong>console</strong> per player.",
		"code": "10007",
		"title": "Maya",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			{
			"event": "post-access-card",
			"optional": {
				"req": func(state, side, eid, card, targets): return NRCard.in_deck(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card-snapshot", null)),
				"once": "per-turn",
				"prompt": func(state, side, eid, card, targets): return str("Move ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null)) + str(" to the bottom of R&D?"),
				"yes-ability": {
					"msg": "move the card just accessed to the bottom of R&D",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRMoving.move(state, "corp", NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "deck")
						return NRTags.gain_tags(state, "runner", eid, 1),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("MemStrips", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+3[Memory Unit]\nUse the MU on MemStrips only for <strong>virus</strong> programs.",
		"code": "07046",
		"title": "MemStrips",
	}, {
		"static-abilities": [virus_mu_(3)],
	}))

	NRCardDefs.defcard("Methuselah", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console - Stealth",
		"subtypes": ["Console", "Stealth"],
		"text": "+1[Memory Unit]\nWhenever a run begins, you may trash 1 piece of hardware from your grip to place 2[Credits] on this hardware.\nYou can spend hosted credits during runs.\nLimit 1 <strong>console</strong> per player.",
		"code": "36020",
		"title": "Methuselah",
	}, {
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
		"events": [
			{
			"event": "run",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()),
				"silent": true,
			},
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Trash a hardware from the Grip?",
			"choices": {
				"card": func(_x): return ((NRCard.hardware).call(_x)) and ((NRCard.in_hand).call(_x)),
			},
			"async": true,
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" and place 2 [Credits] on itself"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
				"unpreventable": true,
			})
			, func(async_result):
				NRProps.add_counter(state, side, eid, card, "credit", 2)),
		},
		],
		"static-abilities": [NRCardXlate.mu_plus(1)],
	}))

	NRCardDefs.defcard("Mind's Eye", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever you make a successful run on R&D, you may place 1 power counter on this hardware.\n<strong>[Click]</strong>, <strong>3 hosted power counters:</strong> Breach R&D. You cannot access cards in the root of R&D during this breach.\nLimit 1 <strong>console</strong> per player.",
		"code": "22017",
		"title": "Mind's Eye",
	}, {
		"implementation": "Power counters added automatically",
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
		],
		"abilities": [
			{
			"action": true,
			"async": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 3)],
			"msg": "breach R&D",
			"effect": func(state, side, eid, card, targets):
				return NRAccess.breach_server(state, side, eid, ["rd"], {
				"no-root": true,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Mirror", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nWhenever you make a successful run on R&D, you may replace 1 spent recurring credit.\nLimit 1 <strong>console</strong> per player.",
		"code": "11005",
		"title": "Mirror",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"async": true,
			"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose a card and replace 1 spent [Recurring Credits] on it",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.get_counters(_pct, "recurring") < NRCardXlate.getk(NRCardDefs.card_def(_pct), "recurring", 0)),
				},
				"msg": func(state, side, eid, card, targets): return str("replace 1 spent [Recurring Credits] on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, NRCardXlate.first_target(targets), "recurring", 1),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Monolith", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 18,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+3[Memory Unit]\nWhen you install this hardware, install up to 3 programs from your grip, paying 4[Credits] less for each.\n[interrupt] → <strong>Trash 1 program from your grip:</strong> Prevent 1 core damage or 1 net damage.\nLimit 1 <strong>console</strong> per player.",
		"code": "03036",
		"title": "Monolith",
	}, (func():
		var mhelper = func(n): return {
			"prompt": "Choose a program to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -4,
				})),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRInstalling.runner_install(state, side, ne, NRCardXlate.first_target(targets), {
				"cost-bonus": -4,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
			, func(async_result):
				NREngine.continue_ability(state, side, (mh((n + 1)) if (n < 3) else null), card, null)),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(3)],
			"on-install": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, mhelper(1), card, null),
			},
			"prevention": [
				{
				"prevents": "damage",
				"type": "ability",
				"ability": {
					"async": true,
					"cost": [NRPayment.to_c("trash-program-from-hand", 1)],
					"msg": func(state, side, eid, card, targets): return str("prevent 1 ") + str(damage_name(state)) + str(" damage"),
					"req": func(state, side, eid, card, targets): return ((not ((("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Mu Safecracker", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"text": "Spend credits only from <strong>stealth</strong> cards to use this hardware.\nWhenever you make a successful run on HQ, you may pay 1[Credits] to access 1 additional card when you breach HQ.\nWhenever you make a successful run on R&D, you may pay 2[Credits] to access 1 additional card when you breach R&D.",
		"code": "26076",
		"title": "Mu Safecracker",
	}, {
		"implementation": "Stealth credit restriction not enforced",
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Stealth")) != null)),
				"prompt": "Pay 1 [Credits] to access 1 additional card?",
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 1, {
						"stealth": 1,
					})],
					"msg": "access 1 additional card from HQ",
					"effect": func(state, side, eid, card, targets):
						return NREngine.register_events(state, side, card, [breach_access_bonus("hq", 1, {
						"duration": "end-of-run",
					})]),
				},
			},
		},
			{
			"event": "successful-run",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Stealth")) != null)),
				"prompt": "Pay 2 [Credits] to access 1 additional card?",
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 2, {
						"stealth": "all-stealth",
					})],
					"msg": "access 1 additional card from R&D",
					"effect": func(state, side, eid, card, targets):
						return NREngine.register_events(state, side, card, [breach_access_bonus("rd", 1, {
						"duration": "end-of-run",
					})]),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Muresh Bodysuit", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Gear",
		"subtypes": ["Gear"],
		"text": "[interrupt] → The first time each turn you would suffer meat damage, prevent 1 meat damage.",
		"code": "02044",
		"title": "Muresh Bodysuit",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "event",
			"max-uses": 1,
			"mandatory": true,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return ((("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NREvents.first_event(state, side, "pre-damage-flag", func(_pct, _pct2=null, _pct3=null): return (("meat" == NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"msg": "reduce the pending meat damage by 1",
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
		],
	}))

	NRCardDefs.defcard("Net-Ready Eyes", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install Net-Ready Eyes, suffer 2 meat damage.\nWhenever you initiate a run, choose an <strong>icebreaker</strong>. That <strong>icebreaker</strong> has +1 strength for the remainder of the run.",
		"code": "08047",
		"title": "Net-Ready Eyes",
	}, {
		"on-install": {
			"async": true,
			"msg": "suffer 2 meat damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "meat", 2, {
				"unboostable": true,
				"card": card,
			}),
		},
		"events": [
			{
			"event": "run",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.has_subtype(_pct, "Icebreaker"))) != null),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Icebreaker")),
			},
			"msg": func(state, side, eid, card, targets): return str("give ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" +1 strength"),
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCardXlate.first_target(targets), 1, "end-of-run"),
		},
		],
	}))

	NRCardDefs.defcard("NetChip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Consumer-grade - Chip",
		"subtypes": ["Consumer-grade", "Chip"],
		"text": "NetChip can host a program with a memory cost less than or equal to the number of copies of NetChip installed. The memory cost of the hosted program does not count against your memory limit.\nLimit 6 per deck.",
		"code": "10024",
		"title": "NetChip",
	}, (func():
		return {
			"enforce-conditions": {
				"req": func(state, side, eid, card, targets): return (func():
					var first_program = NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program))
					return (first_program and (expected_mu(state, first_program) > netchip_count(state)))
				).call(),
				"silent": true,
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program)))) + str(" for violating hosting restrictions"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var first_program = NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program))
					return (func():
						NRSay.system_msg(state, null, NRToString.card_str(state, NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program))), " is trashed for violating hosting restrictions")
						return NRMoving.trash_cards(state, side, eid, [first_program], {
							"unpreventable": true,
							"game-trash": true,
						})
					).call()
				).call(),
			},
			"static-abilities": [
				{
				"type": "can-host",
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and (expected_mu(state, NRCardXlate.first_target(targets)) <= netchip_count(state))),
				"max-mu": func(state, side, eid, card, targets):
					return netchip_count(state),
				"max-cards": 1,
				"no-mu": true,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Obelus", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nYou get +1 maximum hand size for each tag you have.\nThe first time each turn a successful run on HQ or R&D ends, draw 1 card for each time you accessed a card during that run.\nLimit 1 <strong>console</strong> per player.",
		"code": "11041",
		"title": "Obelus",
	}, {
		"static-abilities": [
			NRCardXlate.mu_plus(1),
			runner_hand_size_(func(state, side, eid, card, targets):
			return NRCardXlate.count_tags(state)),
		],
		"events": [
			{
			"event": "run-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and NRUtil.in_coll(["rd", "hq"], NRServers.target_server(NRCardXlate.first_target(targets))) and NREvents.first_event(state, side, "run-ends", func(_pct, _pct2=null, _pct3=null): return (NRCardXlate.getk(NRUtil.first_of(_pct), "successful", null) and NRUtil.in_coll(["rd", "hq"], NRServers.target_server(NRUtil.first_of(_pct)))))),
			"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify(total_cards_accessed(NRCardXlate.first_target(targets)), "card")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, total_cards_accessed(NRCardXlate.first_target(targets))),
		},
		],
	}))

	NRCardDefs.defcard("Omni-drive", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Gear",
		"subtypes": ["Gear"],
		"text": "Omni-drive can host a single program of 1[Memory Unit] or less. The memory cost of the hosted program does not count against your memory limit.\n1[recurring-credit]\nUse this credit to pay for using the hosted program.",
		"code": "03039",
		"title": "Omni-drive",
	}, {
		"recurring": 1,
		"enforce-conditions": {
			"req": func(state, side, eid, card, targets): return (func():
				var first_program = NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program))
				return (first_program and (expected_mu(state, first_program) > 1))
			).call(),
			"silent": true,
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program)))) + str(" for violating hosting restrictions"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var first_program = NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program))
				return (func():
					NRSay.system_msg(state, null, NRToString.card_str(state, NRUtil.first_of(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program))), " is trashed for violating hosting restrictions")
					return NRMoving.trash_cards(state, side, eid, [first_program], {
						"unpreventable": true,
						"game-trash": true,
					})
				).call()
			).call(),
		},
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and (expected_mu(state, NRCardXlate.first_target(targets)) <= 1)),
			"max-mu": 1,
			"max-cards": 1,
			"no-mu": true,
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.program(NRCardXlate.first_target(targets)) and NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("PAN-Weave", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, suffer 1 meat damage.\nThe first time each turn you make a successful run on HQ, the Corp loses 1[Credits]. If they do, gain 1[Credits].",
		"code": "33014",
		"title": "PAN-Weave",
	}, {
		"on-install": {
			"async": true,
			"msg": "suffer 1 meat damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "meat", 1, {
				"unboostable": true,
				"card": card,
			}),
		},
		"events": [
			{
			"event": "successful-run",
			"automatic": "drain-credits",
			"req": func(state, side, eid, card, targets): return ((("hq" == NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null))) or NRUtil.kw_eq("hq", NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)))) and NREvents.first_event(state, side, "successful-run", func(_pct, _pct2=null, _pct3=null): return (("hq" == NRUtil.first_of(NRCardXlate.getk(NRUtil.first_of(_pct), "server", null))) or NRUtil.kw_eq("hq", NRUtil.first_of(NRCardXlate.getk(NRUtil.first_of(_pct), "server", null)))))),
			"msg": "force the Corp to lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NRGaining.lose_credits(state, "corp", ne, 1)
			, func(async_result):
				(func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to gain 1 [Credits]")))
				return NRGaining.gain_credits(state, "runner", eid, 1)
			).call()) if (NRCardXlate.getk(state.getv("corp", {}), "credit", null) > 0) else NREid.effect_completed(state, side, eid)),
		},
		],
	}))

	NRCardDefs.defcard("Pantograph", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever an agenda is scored or stolen, gain 1[Credits]. Then, you may install 1 card from your grip.\nLimit 1 <strong>console</strong> per player.",
		"code": "30023",
		"title": "Pantograph",
	}, (func():
		var install_ability = {
			"async": true,
			"prompt": "Choose a card to install",
			"waiting-prompt": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
				"silent": true,
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and (not (NRCard.event(NRCardXlate.first_target(targets)))) and NRInstalling.runner_can_pay_and_install(state, side, eid, NRCardXlate.first_target(targets), {
					"no-toast": true,
				})),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		}
		var gain_credit_ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"msg": "gain 1 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, "runner", ne, 1)
			, func(async_result):
				NREngine.continue_ability(state, side, install_ability, card, null)),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"events": [
				NRUtil.merge(gain_credit_ability if gain_credit_ability is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(gain_credit_ability if gain_credit_ability is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Paragon", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nThe first time you make a successful run each turn, you may gain 1[Credits] and look at the top card of your stack. If you do, you may add that card to the bottom of your stack.\nLimit 1 <strong>console</strong> per player.",
		"code": "25032",
		"title": "Paragon",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "successful-run",
			"automatic": "pre-draw",
			"interactive": NROptional.get_autoresolve("auto-fire", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-fire", never_p),
			"optional": {
				"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "successful-run"),
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"waiting-prompt": true,
				"prompt": "Gain 1 [Credit] and look at the top card of the stack?",
				"yes-ability": {
					"msg": "gain 1 [Credit] and look at the top card of the stack",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, 1)
					, func(async_result):
						NREngine.continue_ability(state, "runner", {
						"optional": {
							"prompt": func(state, side, eid, card, targets): return str("Add ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)) + str(" to bottom of the stack?"),
							"yes-ability": {
								"msg": "add the top card of the stack to the bottom",
								"effect": func(state, side, eid, card, targets):
									return NRMoving.move(state, "runner", NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "deck"),
							},
							"no-ability": {
								"effect": func(state, side, eid, card, targets):
									return NRSay.system_msg(state, side, "does not add the top card of the the stack to the bottom"),
							},
						},
					}, card, null)),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Paragon")],
	}))

	NRCardDefs.defcard("Patchwork", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\n[interrupt], once per turn → When you would play or install a card, you may trash 1 card from your grip. If you do, instead play or install that card paying 2[Credits] less.\nLimit 1 <strong>console</strong> per player.",
		"code": "25009",
		"title": "Patchwork",
	}, (func():
		var install_word = func(c): return ("play" if NRCard.event(c) else "install")
		var patchwork_ability = {
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "patchwork"], true)),
		}
		var patchwork_manual_prognosis = {
			"cost": [NRPayment.to_c("click", 1)],
			"action": true,
			"once": "per-turn",
			"label": "Manually resolve patchwork",
			"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()) and can_trigger_p(state, side, eid, patchwork_ability, card, targets)),
			"prompt": "Designate a card to play or install",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets))),
			},
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var to_play = NRCardXlate.first_target(targets)
				return NREngine.continue_ability(state, side, {
					"prompt": "Designate a card to trash",
					"choices": {
						"card": func(_x): return ((NRCard.runner).call(_x)) and ((NRCard.in_hand).call(_x)),
						"all": true,
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						register_once(state, side, patchwork_ability, card)
						return (func():
						var to_trash = NRCardXlate.first_target(targets)
						return NREngine.continue_ability(state, side, ({
							"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(to_trash, "title", null)) + str(" from the Grip, and is no longer able to ") + str(install_word(to_trash)) + str(" it"),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRMoving.trash(state, side, eid, to_trash, {
								"cause-card": card,
							}),
						} if NRUtil.same_card(to_trash, to_play) else {
							"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(to_trash, "title", null)) + str(" to ") + str(install_word(to_play)) + str(" ") + str(NRCardXlate.getk(to_play, "title", null)) + str(" from the Grip, paying 2 [Credits] less"),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, to_trash, {
								"cause-card": card,
							})
							, func(async_result):
								(NRPlayInstants.play_instant(state, "runner", eid, to_play, {
								"cost-bonus": -2,
							}) if NRCard.event(to_play) else NRInstalling.runner_install(state, "runner", eid, to_play, {
								"cost-bonus": -2,
							}))),
						}), card, null)
					).call(),
				}, card, null)
			).call(),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"abilities": [patchwork_manual_prognosis],
			"implementation": "click on patchwork to manually resolve it (for tricks)",
			"interactions": {
				"pay-credits": {
					"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["play", "runner-install"], NRCardXlate.getk(eid, "source-type", null)) and (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).filter(func(_x): return not ((func(_x): return NRUtil.same_card.call(NRCardXlate.first_target(targets), _x)).call(_x)))).is_empty()) and (not (NRUtil.get_in(card, ["special", "patchwork"], null))) and can_trigger_p(state, side, eid, patchwork_ability, card, targets)),
					"custom-amount": 2,
					"custom": func(state, side, eid, card, targets):
						return (func():
						var cost_type = (str(("play" if (("play" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("play", NRCardXlate.getk(eid, "source-type", null))) else null)) + str(("install" if (("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) else null)))
						var targetcard = NRCardXlate.first_target(targets)
						return NREngine.continue_ability(state, side, {
							"prompt": (str("Trash a card to lower the ") + str(cost_type) + str(" cost of ") + str(NRCardXlate.getk(targetcard, "title", null)) + str(" by 2 [Credits]")),
							"async": true,
							"choices": {
								"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.runner(_pct) and (not (NRUtil.same_card(_pct, targetcard)))),
							},
							"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to lower the ") + str(cost_type) + str(" cost of ") + str(NRCardXlate.getk(targetcard, "title", null)) + str(" by 2 [Credits]"),
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
								"unpreventable": true,
								"cause-card": card,
							})
							, func(async_result):
								(func():
								register_once(state, side, patchwork_ability, card)
								return NREid.effect_completed(state, side, NREid.make_result(eid, 2))
							).call()),
							"cancel": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NREid.effect_completed(state, side, NREid.make_result(eid, 0)),
							},
						}, card, null)
					).call(),
					"type": "custom",
					"cost-reduction": true,
				},
			},
		}
	).call()))

	NRCardDefs.defcard("Pennyshaver", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever you make a successful run, place 1[Credits] on this hardware.\n[Click]<strong>:</strong> Place 1[Credits] on this hardware, then take all credits from it.\nLimit 1 <strong>console</strong> per player.",
		"code": "30014",
		"title": "Pennyshaver",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"async": true,
			"msg": "place 1 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "credit", 1),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Gain 1 [Credits]. Take all hosted credits",
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("gain ") + str((NRCard.get_counters(card, "credit") + 1)) + str(" [Credits]"),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var credits = (NRCard.get_counters(card, "credit") + 1)
				return (func():
					NRSay.play_sfx(state, side, "click-credit", credits, 3)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "credit", (-(credits - 1)))
					, func(async_result):
						NRGaining.gain_credits(state, "runner", eid, credits))
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Plascrete Carapace", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Gear",
		"subtypes": ["Gear"],
		"text": "When you install this hardware, load 4 power counters onto it. When it is empty, trash it.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent 1 meat damage.",
		"code": "02009",
		"title": "Plascrete Carapace",
	}, {
		"data": {
			"counter": {
				"power": 4,
			},
		},
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("power", 1)],
				"msg": "prevent 1 meat damage",
				"req": func(state, side, eid, card, targets): return (NRPrevention.preventable(NRCardXlate.ctx(targets)) and (("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)))),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
		],
		"events": [trash_on_empty("power")],
	}))

	NRCardDefs.defcard("Poison Vial", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "When you install this hardware, load 3 power counters onto it. When it is empty, trash it.\n<strong>Hosted power counter:</strong> Break up to 2 subroutines. Use this ability only if you have already broken a subroutine during this encounter.",
		"code": "33077",
		"title": "Poison Vial",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"events": [trash_on_empty("power")],
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("power", 1)], 2, "All", {
			"req": func(state, side, eid, card, targets): return NRIce.any_subs_broken(NRIce.get_current_ice(state)),
		}),
		],
	})))

	NRCardDefs.defcard("Polyhistor", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit], +1[link]\nThe first time each turn you pass all of the ice protecting HQ, you may draw 1 card to force the Corp to draw 1 card.\nLimit 1 <strong>console</strong> per player.",
		"code": "13005",
		"title": "Polyhistor",
	}, (func():
		var abi = {
			"optional": {
				"prompt": "Draw 1 card to force the Corp to draw 1 card?",
				"waiting-prompt": true,
				"yes-ability": {
					"msg": "draw 1 card and force the Corp to draw 1 card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, "runner", ne, 1)
					, func(async_result):
						NRDrawing.draw(state, "corp", eid, 1)),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1), NRCardXlate.link_plus(1)],
			"events": [
				{
				"event": "pass-ice",
				"req": func(state, side, eid, card, targets): return (((NRCardXlate.getk(state.getv("run"), "server", null) == ["hq"]) or NRUtil.kw_eq(NRCardXlate.getk(state.getv("run"), "server", null), ["hq"])) and ((NRCardXlate.getk(state.getv("run"), "position", null) == 0) or NRUtil.kw_eq(NRCardXlate.getk(state.getv("run"), "position", null), 0)) and (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).size() > 0)),
				"async": true,
				"once": "per-turn",
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, "runner", abi, card, null),
			},
				{
				"event": "run",
				"req": func(state, side, eid, card, targets): return (((NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null) == ["hq"]) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null), ["hq"])) and (NRCardXlate.getk(NRCardXlate.first_target(targets), "position", null) == 0) and (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).size() > 0)),
				"async": true,
				"once": "per-turn",
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, "runner", abi, card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Prepaid VoicePAD", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Gear",
		"subtypes": ["Gear"],
		"text": "1[recurring-credit] <em>(When you install this card and before your turn begins, refill to 1 hosted credit.)</em>\nYou can spend hosted credits to play events.",
		"code": "31038",
		"title": "Prepaid VoicePAD",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (NRCard.event(NRCardXlate.first_target(targets)) and (((0 == NRUtil.as_array(NRCardXlate.getk(eid, "cost-paid", null)).size()) or NRUtil.kw_eq(0, NRUtil.as_array(NRCardXlate.getk(eid, "cost-paid", null)).size())) or NRCardXlate.getk(eid, "x-cost", null)) and (("play" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("play", NRCardXlate.getk(eid, "source-type", null)))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Prognostic Q-Loop", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "The first time each turn a run begins, you may look at the top 2 cards of your stack.\nOnce per turn → <strong>1[Credits]:</strong> Reveal the top card of your stack. If that card is a program or piece of hardware, you may install it.",
		"code": "26077",
		"title": "Prognostic Q-Loop",
	}, {
		"events": [
			{
			"event": "run",
			"interactive": NROptional.get_autoresolve("auto-fire", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-fire", never_p),
			"optional": {
				"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "run"),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"prompt": "Look at top 2 cards of the stack?",
				"yes-ability": look_at_the_top("runner", "runner", 2),
			},
		},
		],
		"abilities": [
			NROptional.set_autoresolve("auto-fire", "Prognostic Q-Loop"),
			{
			"label": "Reveal and install top card of the stack",
			"once": "per-turn",
			"cost": [NRPayment.to_c("credit", 1)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).size() > 0),
			},
			"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)) + str(" from the top of the stack"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRevealing.reveal(state, side, ne, NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)))
			, func(async_result):
				NREngine.continue_ability(state, side, (func():
				var top_card = NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null))
				return {
					"optional": {
						"req": func(state, side, eid, card, targets): return ((NRCard.program(top_card) or NRCard.hardware(top_card)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source-type": "runner-install"}), top_card)),
						"prompt": func(state, side, eid, card, targets): return str("Install ") + str(NRCardXlate.getk(top_card, "title", null)) + str("?"),
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source-type": "runner-install"}), top_card, {
								"msg-keys": {
									"display-origin": true,
									"origin-index": 0,
									"install-source": card,
								},
							}),
						},
					},
				}
			).call(), card, null)),
		},
		],
	}))

	NRCardDefs.defcard("Public Terminal", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "1[recurring-credit]\nUse this credit to play <strong>run</strong> events.",
		"code": "05038",
		"title": "Public Terminal",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("play" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("play", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Run")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Q-Coherence Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+1[Memory Unit]\nWhen an installed program is trashed, trash this hardware.",
		"code": "05052",
		"title": "Q-Coherence Chip",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": (func():
			var e = {
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)) and NRCard.program(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null))),
				"msg": "trash itself",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, card, {
					"cause-card": card,
				}),
			}
			return [
				NRUtil.merge(e if e is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(e if e is Dictionary else {}, {"event": "corp-trash"}),
			]
		).call(),
	}))

	NRCardDefs.defcard("Qianju PT", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Vehicle",
		"subtypes": ["Vehicle"],
		"text": "When your turn begins, you may lose [Click]. If you do, the first time you would take tags from now until your next turn begins, prevent 1 tag.",
		"code": "07054",
		"title": "Qianju PT",
	}, {
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			{
			"label": "Lose [Click], avoid 1 tag (start of turn)",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"cost": [NRPayment.to_c("lose-click", 1)],
			"msg": "avoid the first tag received until [their] next turn",
			"effect": func(state, side, eid, card, targets):
				return (func():
				var current_turn = NRCardXlate.getk(state, "turn", null)
				var lingering = NREffects.register_lingering_effect(state, side, card, {
					"type": "forced-to-avoid-tag",
					"duration": "until-next-runner-turn-begins",
					"value": true,
				})
				return NREngine.register_events(state, side, card, [
					{
					"event": "tag-interrupt",
					"unregister-once-resolved": true,
					"duration": "until-next-runner-turn-begins",
					"async": true,
					"msg": "avoid 1 tag",
					"effect": func(state, side, eid, card, targets):
						unregister_effect_by_uuid(state, side, lingering)
						return prevent_tag(state, "runner", eid, 1),
				},
				])
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("R&D Interface", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you breach R&D, access 1 additional card.",
		"code": "25050",
		"title": "R&D Interface",
	}, {
		"events": [breach_access_bonus("rd", 1)],
	}))

	NRCardDefs.defcard("Rabbit Hole", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Link",
		"subtypes": ["Link"],
		"text": "+1[link]\nWhen Rabbit Hole is installed, you may search your stack for another copy of Rabbit Hole and install it by paying its install cost. Shuffle your stack.",
		"code": "20046",
		"title": "Rabbit Hole",
	}, {
		"static-abilities": [NRCardXlate.link_plus(1)],
		"on-install": {
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(card, "title", null))) else null)) != null),
				"prompt": func(state, side, eid, card, targets): return str("Install another copy of ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NREngine.trigger_event(state, side, "searched-stack")
						NRShuffling.shuffle_zone(state, "runner", "deck")
						return (func():
						var c = (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(card, "title", null))) else null)) != null)
						return NRInstalling.runner_install(state, side, eid, c, {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}) if c != null else NREid.effect_completed(state, side, eid)
					).call(),
				},
			},
		},
	}))

	NRCardDefs.defcard("Ramujan-reliant 550 BMI", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Consumer-grade",
		"subtypes": ["Consumer-grade"],
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent up to X core damage or net damage. Trash cards from the top of your stack equal to the amount of damage prevented. X is equal to the number of other installed copies of Ramujan-reliant 550 BMI plus 1.\nLimit 6 per deck.",
		"code": "10002",
		"title": "Ramujan-reliant 550 BMI",
	}, (func():
		return {
			"prevention": [
				{
				"prevents": "damage",
				"type": "ability",
				"ability": {
					"async": true,
					"cost": [NRPayment.to_c("trash-can")],
					"msg": func(state, side, eid, card, targets): return str("prevent up to ") + str(max_trash(state)) + str(" damage"),
					"req": NRCardXlate.getk(prevent_up_to_n_damage(1, ["net", "core", "brain"]), "req", null),
					"effect": func(state, side, eid, card, targets):
						return (func():
						var prevented = NRCardXlate.getk(NRCardXlate.ctx(targets), "prevented", null)
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, prevent_up_to_n_damage(max_trash(state), ["net", "core", "brain"]), card, targets)
						, func(async_result):
							(func():
							var prevented_this_instance = (state.get_in(["prevent", "damage", "prevented"], null) - prevented)
							return (func():
								NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash the top ") + str(prevented_this_instance) + str(" cards of the stack")))
								return NRMoving.mill(state, "runner", eid, "runner", prevented_this_instance)
							).call()
						).call())
					).call(),
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Recon Drone", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "[interrupt] → <strong>X[Credits]</strong>, [Trash]<strong>:</strong> Prevent X damage from a card you are accessing.",
		"code": "11103",
		"title": "Recon Drone",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": {
				"async": true,
				"fake-cost": [NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets): return (NRPrevention.preventable(NRCardXlate.ctx(targets)) and NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "source-card", null), NRCardXlate.getk(state, "access", null))),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, {
					"cost": [
						NRPayment.to_c("trash-can"),
						NRPayment.to_c("x-credits", 0, {
						"maximum": NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null),
					}),
					],
					"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRPayment.cost_value(eid, "x-credits")) + str(" ") + str(damage_type(state)) + str(" damage"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRPrevention.prevent_damage(state, side, eid, NRPayment.cost_value(eid, "x-credits")),
				}, card, null),
			},
		},
		],
	}))

	NRCardDefs.defcard("Record Reconstructor", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Whenever you make a successful run on Archives, instead of breaching Archives, you may add 1 faceup card from Archives to the top of R&D.",
		"code": "04028",
		"title": "Record Reconstructor",
	}, {
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "archives",
			"ability": {
				"prompt": "Choose one faceup card to add to the top of R&D",
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(NRCard.faceup)).is_empty()),
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(NRCard.faceup),
				"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to the top of R&D"),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "deck", {
					"front": true,
				}),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Reflection", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": " +1[Memory Unit] +1[link]\nWhenever you jack out, the Corp reveals 1 card from HQ at random.\nLimit 1 <strong>console</strong> per player.",
		"code": "10041",
		"title": "Reflection",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1), NRCardXlate.link_plus(1)],
		"events": [
			{
			"event": "jack-out",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var card = NRUtil.first_of(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null)))
				return (func():
					NRSay.system_msg(state, "runner", (str("force the Corp to reveal ") + str(NRCardXlate.getk(card, "title", null)) + str(" from HQ")))
					return NRRevealing.reveal(state, "corp", eid, card)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Replicator", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you install a piece of hardware (including Replicator), you may search your stack for another copy of that hardware, reveal it, and add it your grip. Shuffle your stack.",
		"code": "02088",
		"title": "Replicator",
	}, (func():
		return {
			"events": [
				{
				"event": "runner-install",
				"interactive": func(state, side, eid, card, targets):
					return hardware_and_in_deck_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), state.getv("runner", {})),
				"silent": func(state, side, eid, card, targets):
					return (not (hardware_and_in_deck_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), state.getv("runner", {})))),
				"optional": {
					"prompt": func(state, side, eid, card, targets): return str("Search the stack for another copy of ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) + str(" and add it to the grip?"),
					"req": func(state, side, eid, card, targets): return hardware_and_in_deck_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), state.getv("runner", {})),
					"yes-ability": {
						"msg": func(state, side, eid, card, targets): return str("add a copy of ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) + str(" from the stack to the grip"),
						"effect": func(state, side, eid, card, targets):
							NREngine.trigger_event(state, side, "searched-stack")
							NRShuffling.shuffle_zone(state, side, "deck")
							return NRMoving.move(state, side, (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null))) else null)) != null), "hand"),
					},
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Respirocytes", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, suffer 1 meat damage.\nThe first time each turn you have no cards in your grip, draw 1 card and place 1 power counter on this hardware.\nWhen this hardware has 3 or more hosted power counters, trash it.",
		"code": "12102",
		"title": "Respirocytes",
	}, (func():
		var ability = {
			"once": "per-turn",
			"msg": "draw 1 card and place a power counter",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "runner", ne, 1)
			, func(async_result):
				NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, NRCard.get_card(state, card), "power", 1)
			, func(async_result):
				((func():
				NRSay.system_msg(state, "runner", (str("trashes ") + str(NRCardXlate.getk(card, "title", null)) + str(" as it reached 3 power counters")))
				return NRMoving.trash(state, side, eid, card, {
					"unpreventable": true,
					"cause-card": card,
				})
			).call() if ((3 == NRCard.get_counters(NRCard.get_card(state, card), "power")) or NRUtil.kw_eq(3, NRCard.get_counters(NRCard.get_card(state, card), "power"))) else NREid.effect_completed(state, side, eid)))),
		}
		var event = {
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() == 0),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, ability, card, targets),
		}
		return {
			"implementation": "Only watches trashes, playing events, and installing. Doesn't know about your hand size pre-install.",
			"on-install": {
				"async": true,
				"msg": "suffer 1 meat damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(state, side, eid, "meat", 1, {
					"unboostable": true,
					"card": card,
				}),
			},
			"events": [
				NRUtil.merge(event if event is Dictionary else {}, {"event": "play-event"}),
				NRUtil.merge(event if event is Dictionary else {}, {"event": "runner-hand-changed?"}),
				NRUtil.merge(event if event is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(event if event is Dictionary else {}, {"event": "corp-trash"}),
				NRUtil.merge(event if event is Dictionary else {}, {"event": "runner-install"}),
				{
				"event": "runner-turn-begins",
				"automatic": "draw-cards",
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state.getv("runner", {}), "hand", null) is Array and NRCardXlate.getk(state.getv("runner", {}), "hand", null).is_empty() if false else (str(NRCardXlate.getk(state.getv("runner", {}), "hand", null)) == "")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, ability, card, null),
			},
				{
				"event": "corp-turn-begins",
				"automatic": "draw-cards",
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state.getv("runner", {}), "hand", null) is Array and NRCardXlate.getk(state.getv("runner", {}), "hand", null).is_empty() if false else (str(NRCardXlate.getk(state.getv("runner", {}), "hand", null)) == "")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, ability, card, null),
			},
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Rotary", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever you breach HQ or R&D, you may take 1 tag to access 1 additional card.\n[Click], <strong>2[Credits]:</strong> Trash this hardware. Only the Corp can use this ability, and only if the Runner is tagged.\nLimit 1 <strong>console</strong> per player.",
		"code": "36014",
		"title": "Rotary",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"optional": {
				"req": func(state, side, eid, card, targets): return NRUtil.in_coll(["hq", "rd"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)),
				"prompt": "Tag 1 tag to see an additional card?",
				"yes-ability": {
					"cost": [NRPayment.to_c("gain-tag", 1)],
					"msg": func(state, side, eid, card, targets): return str("access 1 additional card from ") + str(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
					"effect": func(state, side, eid, card, targets):
						return NRAccess.access_bonus(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null), 1),
				},
			},
		},
		],
		"corp-abilities": [
			{
			"action": true,
			"label": "Trash Rotary",
			"async": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)],
			"req": func(state, side, eid, card, targets): return (NRUtil.is_tagged(state) and (("corp" == side) or NRUtil.kw_eq("corp", side))),
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, "corp", "spends [Click] and 2 [Credits] to trash Rotary")
				return NRMoving.trash(state, "corp", eid, card, {
				"cause-card": card,
			}),
		},
		],
	}))


static func _register_4() -> void:
	NRCardDefs.defcard("Rubicon Switch", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"text": "Once per turn → [Click], <strong>X[Credits]:</strong> Derez 1 piece of ice with a printed rez cost of X[Credits] that was rezzed this turn.",
		"code": "12043",
		"title": "Rubicon Switch",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("x-credits")],
			"label": "Derez a piece of ice rezzed this turn",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var payment_eid = eid
				var spent_credits = NRPayment.cost_value(eid, "x-credits")
				return NREngine.continue_ability(state, side, {
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and (("this-turn" == NRCardXlate.getk(NRCardXlate.first_target(targets), "rezzed", null)) or NRUtil.kw_eq("this-turn", NRCardXlate.getk(NRCardXlate.first_target(targets), "rezzed", null))) and (NRCostFns.rez_cost(state, "corp", NRCardXlate.first_target(targets), null) <= spent_credits)),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets), {
						"msg-keys": {
							"include-cost-from-eid": payment_eid,
						},
					}),
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Security Chip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "[Trash]: Choose an <strong>icebreaker</strong> (or any number of <strong>cloud icebreakers</strong>). Each chosen <strong>icebreaker</strong> has +1 strength for each [link] you have for the remainder of this run. Use this ability only during a run.",
		"code": "09046",
		"title": "Security Chip",
	}, {
		"abilities": [
			{
			"label": "Add [Link] strength to a non-Cloud icebreaker until the end of the run",
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRLink.get_link(state)) + str(" strength to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" until the end of the run"),
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "run", null),
			"prompt": "Choose one non-Cloud icebreaker",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and (not (NRCard.has_subtype(_pct, "Cloud"))) and NRCard.installed(_pct)),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCardXlate.first_target(targets), NRLink.get_link(state), "end-of-run"),
		},
			{
			"label": "Add [Link] strength to any Cloud icebreakers until the end of the run",
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRLink.get_link(state)) + str(" strength to ") + str(NRUtil.as_array(targets).size()) + str(" Cloud icebreakers until the end of the run"),
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "run", null),
			"prompt": "Choose any number of Cloud icebreakers",
			"choices": {
				"max": 50,
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and NRCard.has_subtype(_pct, "Cloud") and NRCard.installed(_pct)),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return (func():
				for t in NRUtil.as_array(targets):
					(func():
				NRIce.pump(state, side, t, NRLink.get_link(state), "end-of-run")
				return NRIce.update_breaker_strength(state, side, t)
			).call()
				return null
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Security Nexus", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 8,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit], +1[link]\nOnce per turn → When you encounter a piece of ice, you may have the Corp trace[5]. If successful, they give you 1 tag and end the run. If unsuccesful, bypass the encountered ice.\nLimit 1 <strong>console</strong> per player.",
		"code": "09047",
		"title": "Security Nexus",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1), NRCardXlate.link_plus(1)],
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Trace 5 to bypass current ice?",
				"once": "per-turn",
				"yes-ability": {
					"msg": "force the Corp to initiate a trace",
					"trace": {
						"base": 5,
						"successful": {
							"msg": "give the Runner 1 tag and end the run",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRTags.gain_tags(state, "runner", ne, 1)
							, func(async_result):
								NRRuns.end_run(state, side, eid, card)),
						},
						"unsuccessful": {
							"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
							"effect": func(state, side, eid, card, targets):
								return NRCardXlate.bypass_ice(state),
						},
					},
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Severnius Stim Implant", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "<strong>[Click]:</strong> Trash 2 or more cards from your grip. Run HQ or R&D. Whenever you breach that server during this run, access 1 additional card for every 2 cards you trashed.",
		"code": "12021",
		"title": "Severnius Stim Implant",
	}, (func():
		return {
			"abilities": [
				{
				"action": true,
				"req": func(state, side, eid, card, targets): return (2 <= NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size()),
				"label": "Run HQ or R&D",
				"prompt": "Choose one",
				"waiting-prompt": true,
				"choices": ["HQ", "R&D"],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, implant_fn(NRCardXlate.first_target(targets), ("hq" if ((NRCardXlate.first_target(targets) == "HQ") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "HQ")) else "rd")), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Şifr", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nOnce per turn → When you encounter a piece of ice, you may get –1 maximum hand size until your next turn begins. If you do, the strength of that ice is lowered to 0 for the remainder of the encounter.\nLimit 1 <strong>console</strong> per player.",
		"code": "11101",
		"title": "Şifr",
	}, (func():
		var _b0 = gather_pre_sifr_effects([sifr, state, side, eid, NRCardXlate.first_target(targets), targets], (0 if NRFlags.card_flag(NRCardXlate.first_target(targets), "cannot-lower-strength", true) else absi(reduce(_, NRUtil.as_array(NRUtil.first_of((func(_pct, _pct2=null, _pct3=null): return split_at(index_of(func(item): return NRUtil.same_card(sifr, NRCardXlate.getk(item, "card", null)), _pct), _pct)).call(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state, "effects", null)).filter(func(_pct, _pct2=null, _pct3=null): return (("ice-strength" == NRCardXlate.getk(_pct, "type", null)) or NRUtil.kw_eq("ice-strength", NRCardXlate.getk(_pct, "type", null))))).filter(func(_pct, _pct2=null, _pct3=null): return (true if (not (NRCardXlate.getk(_pct, "req", null))) else (NRCardXlate.getk(_pct, "req", null)).call(state, side, eid, NRCard.get_card(state, NRCardXlate.getk(_pct, "card", null)), ([NRCardXlate.first_target(targets)] + NRUtil.as_array(targets)))))))).map(func(_pct, _pct2=null, _pct3=null): return (NRCardXlate.getk(_pct, "value", null) if (not ((NRCardXlate.getk(_pct, "value", null) is Callable))) else (NRCardXlate.getk(_pct, "value", null)).call(state, side, eid, NRCard.get_card(state, NRCardXlate.getk(_pct, "card", null)), ([NRCardXlate.first_target(targets)] + NRUtil.as_array(targets)))))))))
		return {
			"static-abilities": [NRCardXlate.mu_plus(2)],
			"events": [
				{
				"event": "encounter-ice",
				"skippable": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"prompt": "Lower your maximum hand size by 1 to reduce the strength of encountered ice to 0?",
					"once": "per-turn",
					"yes-ability": {
						"msg": func(state, side, eid, card, targets): return str("lower [their] maximum hand size by 1 and reduce the strength of ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str(" to 0"),
						"effect": func(state, side, eid, card, targets):
							NREffects.register_lingering_effect(state, side, card, {
							"type": "hand-size",
							"duration": "until-runner-turn-begins",
							"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
							"value": -1,
						})
							return NREffects.register_lingering_effect(state, "runner", card, (func():
							var ice = NRIce.get_current_ice(state)
							return {
								"type": "ice-strength",
								"duration": "end-of-encounter",
								"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), ice),
								"value": func(state, side, eid, card, targets):
									return (-(NRCardXlate.getk(NRCardXlate.first_target(targets), "strength", null) + gather_pre_sifr_effects(card, state, side, eid, NRCardXlate.first_target(targets), (NRUtil.as_array(targets).slice(1) if NRUtil.as_array(targets).size() > 0 else [])))),
							}
						).call()),
					},
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Silencer", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Chip - Stealth",
		"subtypes": ["Chip", "Stealth"],
		"text": "1[recurring-credit]\nUse this credit to pay for using <strong>killers</strong>.",
		"code": "04104",
		"title": "Silencer",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Killer") and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Simulchip", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "As an additional cost to use this hardware, trash 1 installed program. Ignore this cost if an installed program has already been trashed this turn.\n<strong>[Trash]:</strong> Install 1 program from your heap, paying 3[Credits] less.",
		"code": "26085",
		"title": "Simulchip",
	}, {
		"static-abilities": [
			{
			"type": "card-ability-additional-cost",
			"req": func(state, side, eid, card, targets): return (NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and (func():
				var pred = func(event): return (NRUtil.find_first(NRUtil.as_array(event), func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(NRCardXlate.getk(_pct, "card", null)) and NRCard.installed(NRCardXlate.getk(_pct, "card", null)) and NRCard.program(NRCardXlate.getk(_pct, "card", null)))) != null)
				return ((NREvents.event_count(state, null, "runner-trash", pred) + NREvents.event_count(state, null, "corp-trash", pred) + NREvents.event_count(state, null, "game-trash", pred)) == 0)
			).call()),
			"value": [NRPayment.to_c("program", 1)],
		},
		],
		"abilities": [
			{
			"async": true,
			"label": "Install a program from the heap",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
					"cost-bonus": -3,
					"no-toast": true,
				}))) != null),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"show-discard": true,
				"waiting-prompt": true,
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRCard.in_discard(NRCardXlate.first_target(targets)) and NRCard.program(NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
						"cost-bonus": -3,
					})),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -3,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
						"include-cost-from-eid": eid,
					},
				}),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Skulljack", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, suffer 1 core damage.\nThe trash cost of each Corp card is lowered by 1.",
		"code": "08042",
		"title": "Skulljack",
	}, {
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
		"static-abilities": [{
			"type": "trash-cost",
			"value": -1,
		}],
	}))

	NRCardDefs.defcard("Solidarity Badge", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "The first time each turn you trash a Corp card, place 1 power counter on this hardware.\nWhen your turn begins, you may remove 1 hosted power counter to draw 1 card or remove 1 tag.",
		"code": "34003",
		"title": "Solidarity Badge",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"skippable": true,
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRCard.get_card(state, card), "power") > 0),
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return (NRCard.get_counters(NRCard.get_card(state, card), "power") > 0),
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
				"Draw 1 card",
				("Remove 1 tag" if (count_real_tags(state) > 0) else null),
				"Done",
			],
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "power", -1)
			, func(async_result):
				(func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to draw 1 card")))
				return NRDrawing.draw(state, "runner", eid, 1)
			).call()) if ((NRCardXlate.first_target(targets) == "Draw 1 card") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 1 card")) else (NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "power", -1)
			, func(async_result):
				(func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to remove 1 tag")))
				return NRTags.lose_tags(state, "runner", eid, 1)
			).call()) if ((NRCardXlate.first_target(targets) == "Remove 1 tag") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Remove 1 tag")) else NREid.effect_completed(state, "runner", eid))),
		},
			{
			"event": "runner-trash",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.corp(NRCardXlate.getk(_pct, "card", null))) != null) and NREvents.first_event(state, side, "runner-trash", func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.corp(NRCardXlate.getk(_pct, "card", null))) != null))),
			"msg": "place 1 power counter on itself",
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "power", 1),
		},
		],
	}))

	NRCardDefs.defcard("Spinal Modem", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit], 2[recurring-credit]\nYou can spend hosted credits to use <strong>icebreakers</strong>.\nWhenever there is a successful trace during a run, suffer 1 core damage.\nLimit 1 <strong>console</strong> per player.",
		"code": "20007",
		"title": "Spinal Modem",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"recurring": 2,
		"events": [
			{
			"event": "successful-trace",
			"req": func(state, side, eid, card, targets): return state.getv("run"),
			"msg": "suffer 1 core damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Sports Hopper", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Vehicle",
		"subtypes": ["Vehicle"],
		"text": " +1[link]\n[Trash]: Draw 3 cards.",
		"code": "10064",
		"title": "Sports Hopper",
	}, {
		"static-abilities": [NRCardXlate.link_plus(1)],
		"abilities": [
			NRDefHelpers.draw_ability(3, null, {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"cost": [NRPayment.to_c("trash-can")],
		}),
		],
	}))

	NRCardDefs.defcard("Spy Camera", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Consumer-grade",
		"subtypes": ["Consumer-grade"],
		"text": "[Click]: Look at the top X cards of your stack and arrange them in any order. X is the number of copies of Spy Camera installed.\n[Trash]: Look at the top card of R&D.\nLimit 6 per deck.",
		"code": "10042",
		"title": "Spy Camera",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"async": true,
			"label": "Look at the top X cards of the stack",
			"msg": "look at the top X cards of the stack and rearrange them",
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var n = NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(card, "title", null))))).size()
				var from = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(n))
				return NREngine.continue_ability(state, side, (reorder_choice("runner", "corp", from, [], NRUtil.as_array(from).size(), from) if (NRUtil.as_array(from).size() > 0) else null), card, null)
			).call(),
		},
			{
			"label": "Look at the top card of R&D",
			"msg": "look at the top card of R&D",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": func(state, side, eid, card, targets):
					return (str("The top card of R&D is ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null))),
				"choices": ["OK"],
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Supercorridor", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nYou get +1 maximum hand size.\nWhen your turn ends, if you and the Corp have the same number of credits, you may gain 2[Credits].\nLimit 1 <strong>console</strong> per player.",
		"code": "26023",
		"title": "Supercorridor",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2), runner_hand_size_(1)],
		"events": [
			{
			"event": "runner-turn-ends",
			"interactive": NROptional.get_autoresolve("auto-fire", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-fire", never_p),
			"optional": {
				"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(state.getv("runner", {}), "credit", null) == NRCardXlate.getk(state.getv("corp", {}), "credit", null)) or NRUtil.kw_eq(NRCardXlate.getk(state.getv("runner", {}), "credit", null), NRCardXlate.getk(state.getv("corp", {}), "credit", null))),
				"waiting-prompt": true,
				"prompt": "Gain 2 [Credits]?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": "gain 2 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, 2),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Supercorridor")],
	}))

	NRCardDefs.defcard("Swift", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console - Vehicle",
		"subtypes": ["Console", "Vehicle"],
		"text": "+1[Memory Unit]\nThe first time each turn you play a <strong>run</strong> event, gain [Click].\nLimit 1 <strong>console</strong> per player.",
		"code": "27002",
		"title": "Swift",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "play-event",
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Run") and NREvents.first_event(state, side, "play-event", func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null), "Run"))),
			"msg": "gain a [click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		},
		],
	}))

	NRCardDefs.defcard("T400 Memory Diamond", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Chip",
		"subtypes": ["Chip"],
		"text": "+1[Memory Unit]\nYou get +1 maximum hand size.",
		"code": "30031",
		"title": "T400 Memory Diamond",
	}, {
		"static-abilities": [
			NRCardXlate.mu_plus(1),
			{
			"type": "hand-size",
			"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
			"value": 1,
		},
		],
	}))

	NRCardDefs.defcard("The Gauntlet", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nWhenever you breach HQ during a run, access 1 additional card for each piece of ice protecting HQ that you fully broke during that run.\nLimit 1 <strong>console</strong> per player.",
		"code": "11063",
		"title": "The Gauntlet",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"req": func(state, side, eid, card, targets): return (("hq" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var evs = NREvents.run_events(state, side, "subroutines-broken")
				var relevant = NRUtil.as_array(evs).filter(func(_pct, _pct2=null, _pct3=null): return (func():
					var context = NRUtil.first_of(_pct)
					var t = NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))
					return (NRCardXlate.getk(NRCardXlate.ctx(targets), "all-subs-broken", null) and (("hq" == (NRUtil.as_array(NRCard.get_zone(t))[1] if NRUtil.as_array(NRCard.get_zone(t)).size() > 1 else null)) or NRUtil.kw_eq("hq", (NRUtil.as_array(NRCard.get_zone(t))[1] if NRUtil.as_array(NRCard.get_zone(t)).size() > 1 else null))))
				).call())
				var by_cid = NRUtil.as_array(relevant).map(func(_pct, _pct2=null, _pct3=null): return NRUtil.get_in(NRUtil.first_of(_pct), ["card", "cid"], null))
				var bonus_count = NRUtil.as_array(NRUtil.as_array(by_cid)).size()
				return NRAccess.access_bonus(state, "runner", "hq", bonus_count)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("The Personal Touch", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Install The Personal Touch only on an <strong>icebreaker.</strong>\nHost <strong>icebreaker</strong> has +1 strength.",
		"code": "20047",
		"title": "The Personal Touch",
	}, {
		"hosting": {
			"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and NRCard.installed(_pct)),
		},
		"on-install": {
			"effect": func(state, side, eid, card, targets):
				return NRIce.update_breaker_strength(state, side, NRCardXlate.getk(card, "host", null)),
		},
		"static-abilities": [
			{
			"type": "breaker-strength",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": 1,
		},
		],
	}))

	NRCardDefs.defcard("The Toolbox", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 9,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit] +2[link]\n2[recurring-credit]\nUse these credits to pay for using <strong>icebreakers</strong>.\nLimit 1 <strong>console</strong> per player.",
		"code": "01041",
		"title": "The Toolbox",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(2), NRCardXlate.link_plus(2)],
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("The Tungsten Tailor", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"text": "Each piece of ice gets −1 strength.\nThe first time each turn you break a subroutine on a piece of ice with 0 or less strength, gain 1[Credits].",
		"code": "36003",
		"title": "The Tungsten Tailor",
	}, {
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.first_target(targets)),
			"value": -1,
		},
		],
		"events": [
			{
			"event": "subroutines-broken",
			"async": true,
			"once-per-instance": true,
			"automatic": "gain-credits",
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p(targets) and NREvents.first_event(state, side, "subroutines-broken", valid_ctx_p))
			).call(),
			"msg": "gain 1 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("The Wizard's Chest", NRCardXlate.merge_cdef({
		"title": "The Wizard's Chest",
	}, (func():
		var _b0 = wiz_search_fn([state, side, eid, card, remainder, type, rev_str, first_card], ((func():
			var revealed_card = NRUtil.first_of(remainder)
			var rest_of_deck = (NRUtil.as_array(remainder).slice(1) if NRUtil.as_array(remainder).size() > 0 else [])
			var rev_str = (NRCardXlate.getk(revealed_card, "title", null) if (("" == rev_str) or NRUtil.kw_eq("", rev_str)) else (str(rev_str) + str(", ") + str(NRCardXlate.getk(revealed_card, "title", null))))
			return ((wiz_search_fn(state, side, eid, card, rest_of_deck, type, rev_str, revealed_card) if (not (first_card)) else install_choice(state, side, eid, card, rev_str, first_card, revealed_card)) if NRCard.is_type(revealed_card, type) else wiz_search_fn(state, side, eid, card, rest_of_deck, type, rev_str, first_card))
		).call() if (not NRUtil.as_array(remainder).is_empty()) else (NREngine.continue_ability(state, side, {
			"msg": func(state, side, eid, card, targets): return str("reveal ") + str(rev_str) + str(" from the top of the stack"),
			"effect": func(state, side, eid, card, targets):
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRSay.system_msg(state, side, "shuffles the Stack"),
		}, card, null) if (not (first_card)) else install_choice(state, side, eid, card, rev_str, first_card, null))))
		return {
			"abilities": [
				{
				"cost": [NRPayment.to_c("trash-can")],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"label": "Set aside cards from the top of the stack",
				"prompt": "Choose a card type",
				"waiting-prompt": true,
				"choices": func(state, side, eid, card, targets):
					return ["Hardware", "Program", "Resource"],
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return wiz_search_fn(state, side, eid, card, NRCardXlate.getk(state.getv("runner", {}), "deck", null), NRCardXlate.first_target(targets), "", null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Time Bomb", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "Install only if you made a successful run on a central server this turn. When you install this hardware, place 1 power counter on it.\nWhen your turn begins, if there are 3 or more hosted power counters, trash this hardware and sabotage 3. <em>(The Corp trashes 3 cards of their choice from HQ and/or the top of R&D.)</em> Otherwise, place 1 power counter on this hardware.",
		"code": "33069",
		"title": "Time Bomb",
	}, {
		"data": {
			"counter": {
				"power": 1,
			},
		},
		"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq", "rd", "archives"], _x)) != null),
		"events": [
			{
			"event": "runner-turn-begins",
			"automatic": "force-discard",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, side, ne, card, {
				"cause-card": card,
			})
			, func(async_result):
				NREngine.continue_ability(state, side, NRSabotage.sabotage(3), card, null)) if (3 <= NRCard.get_counters(NRCard.get_card(state, card), "power")) else (func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to place 1 power counter on itself")))
				return NRProps.add_counter(state, side, eid, card, "power", 1)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Titanium Ribs", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install Titanium Ribs, suffer 2 meat damage.\nYou choose the card(s) from your grip to trash whenever you take damage (including the damage taken by installing Titanium Ribs).",
		"code": "08045",
		"title": "Titanium Ribs",
	}, {
		"on-install": {
			"async": true,
			"msg": "suffer 2 meat damage",
			"effect": func(state, side, eid, card, targets):
				enable_runner_damage_choice(state, side)
				return NRDamage.damage(state, side, eid, "meat", 2, {
				"unboostable": true,
				"card": card,
			}),
		},
		"leave-play": func(state, side, eid, card, targets):
			return null,
		"events": [
			{
			"event": "pre-resolve-damage",
			"async": true,
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null) > 0) and runner_can_choose_damage_p(state) and (not (state.get_in(["damage", "damage-replace"], null)))),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var _destructured_0 = NRCardXlate.ctx(targets)
				var hand = NRCardXlate.getk(state.getv("runner", {}), "hand", null)
				return NREngine.continue_ability(state, "runner", ({
					"effect": func(state, side, eid, card, targets):
						return chosen_damage(state, "runner", hand),
				} if (NRUtil.as_array(hand).size() < dmg) else {
					"waiting-prompt": true,
					"prompt": func(state, side, eid, card, targets): return str("Choose ") + str(NRUtil.quantify(dmg, "card")) + str(" to trash for the ") + str(str(dtype)) + str(" damage"),
					"choices": {
						"max": dmg,
						"all": true,
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.runner(_pct)),
					},
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.enumerate_cards(targets, "sorted")),
					"effect": func(state, side, eid, card, targets):
						return chosen_damage(state, "runner", targets),
				}), card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Top Hat", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Whenever you make a successful run on R&D, instead of breaching R&D, you may choose 1 of the top 5 cards in R&D and access it.",
		"code": "11067",
		"title": "Top Hat",
	}, {
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "rd",
			"ability": {
				"req": func(state, side, eid, card, targets): return ((not (((NRCardXlate.getk(state.getv("run"), "max-access", null) == 0) or NRUtil.kw_eq(NRCardXlate.getk(state.getv("run"), "max-access", null), 0)))) and (NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).size() > 0)),
				"prompt": "Which card from the top of R&D would you like to access? (Card 1 is on top)",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(_range(1, 6)), int(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).size()))).map(str),
				"msg": func(state, side, eid, card, targets): return str("only access the card at position ") + str(NRCardXlate.first_target(targets)) + str(" of R&D"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (NREid.effect_completed(state, null, eid) if get_only_card_to_access(state) else (func():
					var deck = NRCardXlate.getk(state.getv("corp", {}), "deck", null)
					var idx = (str_to_int(NRCardXlate.first_target(targets)) - 1)
					var selected_card = NRUtil.as_array(deck)[idx]
					return (NRAccess.access_card(state, side, eid, selected_card, "an unseen card") if selected_card else NREid.effect_completed(state, side, eid))
				).call()),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Touchstone", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Stealth",
		"subtypes": ["Stealth"],
		"text": "The first time each turn you play an event, place 1[Credits] on this hardware.\nYou can spend hosted credits during runs.",
		"code": "36021",
		"title": "Touchstone",
	}, {
		"events": [
			{
			"event": "play-event",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "play-event"),
			"async": true,
			"silent": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 1),
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
	}))

	NRCardDefs.defcard("Turntable", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhenever you steal an agenda, you may swap that agenda with an agenda in the Corp's score area.\nLimit 1 <strong>console</strong> per player.",
		"code": "08043",
		"title": "Turntable",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			{
			"event": "agenda-stolen",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "scored", null)).is_empty()),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var stolen = NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)
				return {
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Swap ") + str(NRCardXlate.getk(stolen, "title", null)) + str(" for an agenda in the Corp's score area?"),
						"yes-ability": {
							"prompt": (str("Choose a scored Corp agenda to swap with ") + str(NRCardXlate.getk(stolen, "title", null))),
							"choices": {
								"card": func(_pct, _pct2=null, _pct3=null): return NRFlags.in_corp_scored(state, side, _pct),
							},
							"msg": func(state, side, eid, card, targets): return str("swap ") + str(NRCardXlate.getk(stolen, "title", null)) + str(" for ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
							"effect": func(state, side, eid, card, targets):
								return swap_agendas(state, side, NRCardXlate.first_target(targets), stolen),
						},
					},
				}
			).call(), card, targets),
		},
		],
	}))

	NRCardDefs.defcard("Ubax", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhen your turn begins, draw 1 card.\nLimit 1 <strong>console</strong> per player.",
		"code": "13016",
		"title": "Ubax",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"automatic": "draw-cards",
			"msg": "draw 1 card",
			"label": "Draw 1 card (start of turn)",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"flags": {
				"runner-turn-draw": true,
				"runner-phase-12": func(state, side, eid, card, targets):
					return (1 < NRUtil.as_array(NRUtil.as_array(([state.get_in(["runner", "identity"], null)] + NRUtil.as_array(NRBoard.all_active_installed(state, "runner")))).filter(func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-turn-draw", true))).size()),
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Unregistered S&W '35", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "Use this hardware only if you have made a successful run on HQ this turn.\n<strong>[Click][Click]:</strong> Trash 1 rezzed <strong>bioroid</strong>, <strong>clone</strong>, <strong>executive</strong>, or <strong>sysop</strong> in the root of a remote server.",
		"code": "05039",
		"title": "Unregistered S&W '35",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (not NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "corp")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.rezzed(_pct) and NRCard.installed(_pct) and NRCard.has_any_subtype(_pct, ["Bioroid", "Clone", "Executive", "Sysop"])))).is_empty())),
			"label": "trash a Bioroid, Clone, Executive or Sysop",
			"prompt": "Choose a Bioroid, Clone, Executive, or Sysop to trash",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.rezzed(_pct) and NRCard.installed(_pct) and NRCard.has_any_subtype(_pct, ["Bioroid", "Clone", "Executive", "Sysop"])),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Vigil", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhen your turn begins, if the Corp has cards in HQ equal to their maximum hand size, draw 1 card.\nLimit 1 <strong>console</strong> per player.",
		"code": "07047",
		"title": "Vigil",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and ((NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() == NRHandSize.hand_size(state, "corp")) or NRUtil.kw_eq(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size(), NRHandSize.hand_size(state, "corp")))),
			"automatic": "draw-cards",
			"msg": "draw 1 card",
			"label": "Draw 1 card (start of turn)",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		}
		return {
			"static-abilities": [NRCardXlate.mu_plus(1)],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Virtuoso", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+1[Memory Unit]\nWhen your turn begins, identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nThe first time each turn you make a successful run on your mark, if that server is HQ, access 1 additional card when you breach HQ. Otherwise, breach HQ when the run ends.\nLimit 1 <strong>console</strong> per player.",
		"code": "33015",
		"title": "Virtuoso",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
		"events": [
			mark_changed_event,
			NRUtil.merge(NRMark.identify_mark_ability if NRMark.identify_mark_ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "marked-server", null) and NREvents.first_event(state, side, "successful-run", func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "marked-server", null))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to access 1 additional card from HQ this run")))
				NREngine.register_events(state, side, card, [breach_access_bonus("hq", 1, {
					"duration": "end-of-run",
				})])
				return NREid.effect_completed(state, side, eid)
			).call() if (("hq" == NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null))) or NRUtil.kw_eq("hq", NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)))) else (func():
				NRSay.system_msg(state, side, (str("will use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to breach HQ when this run ends")))
				NREngine.register_events(state, side, card, [
					{
					"event": "run-ends",
					"duration": "end-of-run",
					"async": true,
					"interactive": func(state, side, eid, card, targets):
						return true,
					"msg": "breach HQ",
					"effect": func(state, side, eid, card, targets):
						return NRAccess.breach_server(state, "runner", eid, ["hq"], null),
				},
				])
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("WAKE Implant v2A-JRJ", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Cybernetic",
		"subtypes": ["Cybernetic"],
		"text": "When you install this hardware, suffer 1 meat damage.\nWhenever you make a successful run on HQ, place 1 power counter on this hardware.\nWhenever you breach R&D, you may remove up to 3 hosted power counters to access that many additional cards.",
		"code": "33078",
		"title": "WAKE Implant v2A-JRJ",
	}, {
		"on-install": {
			"async": true,
			"msg": "suffer 1 meat damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "meat", 1, {
				"unboostable": true,
				"card": card,
			}),
		},
		"events": [
			{
			"event": "successful-run",
			"async": true,
			"req": func(state, side, eid, card, targets): return (("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"msg": "place 1 power counter on itself",
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "power", 1, {
				"placed": true,
			}),
		},
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"req": func(state, side, eid, card, targets): return ((("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (NRCard.get_counters(card, "power") > 0)),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "How many additional R&D accesses do you want to make?",
				"choices": {
					"number": func(state, side, eid, card, targets):
						return mini(3, NRCard.get_counters(card, "power")),
					"default": func(state, side, eid, card, targets):
						return mini(3, NRCard.get_counters(card, "power")),
				},
				"msg": func(state, side, eid, card, targets): return str("access ") + str(NRUtil.quantify(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null), "additional card")) + str(" from R&D"),
				"waiting-prompt": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRAccess.access_bonus(state, "runner", "rd", maxi(0, NRCardXlate.first_target(targets)))
					return NRProps.add_counter(state, "runner", eid, card, "power", (-NRCardXlate.first_target(targets)), {
					"placed": true,
				}),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Window", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[Click]: Draw 1 card from the bottom of your stack.",
		"code": "05040",
		"title": "Window",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"keep-menu-open": "while-clicks-left",
			"msg": "draw 1 card from the bottom of the stack",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRUtil.last_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "hand"),
		},
		],
	}))

	NRCardDefs.defcard("Zamba", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Console",
		"subtypes": ["Console"],
		"text": "+2[Memory Unit]\nWhenever a Corp card is exposed, you may gain 1[Credits].\nLimit 1 <strong>console</strong> per player.",
		"code": "21003",
		"title": "Zamba",
	}, {
		"special": {
			"auto-gain-credits": "always",
		},
		"implementation": "Credit gain is automatic",
		"static-abilities": [NRCardXlate.mu_plus(2)],
		"abilities": [
			NROptional.set_autoresolve("auto-gain-credits", "Zamba gaining credits on expose"),
		],
		"events": [
			{
			"event": "expose",
			"interactive": NROptional.get_autoresolve("auto-gain-credits", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-gain-credits", never_p),
			"async": true,
			"optional": {
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets): return str("Gain ") + str(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)).size()) + str(" [Credits]?"),
				"autoresolve": NROptional.get_autoresolve("auto-gain-credits"),
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)).size()) + str(" [Credits]"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)).size()),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Zenit Chip JZ-2MJ", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Cybernetic - Chip",
		"subtypes": ["Cybernetic", "Chip"],
		"text": "When you install this hardware, suffer 1 core damage.\nThe first time each turn you make a successful run on a central server, draw 1 card.",
		"code": "33079",
		"title": "Zenit Chip JZ-2MJ",
	}, {
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) and NREvents.first_event(state, side, "successful-run", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))
			).call())),
			"msg": "draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Zer0", NRCardXlate.merge_cdef({
		"type": "Hardware",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"text": "Once per turn → [Click], <strong>suffer 1 net damage:</strong> Gain 1[Credits] and draw 2 cards.",
		"code": "21101",
		"title": "Zer0",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("net", 1)],
			"once": "per-turn",
			"msg": "gain 1 [Credits] and draw 2 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "professional-contacts")
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 1, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRDrawing.draw(state, side, eid, 2)),
		},
		],
	}))


