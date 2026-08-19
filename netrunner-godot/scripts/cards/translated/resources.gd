class_name NRCardsResources
extends RefCounted

## Port of game.cards.resources — translated from Jinteki.net Clojure.
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
	_register_5()
	_register_6()


static func genetics_trigger_p(state, side, event):
	return (NREvents.first_event(state, side, event) or (has_flag_p(state, side, "persistent", "genetics-trigger-twice") and second_event_p(state, side, event)))


static func shard_constructor(title, target_server, message, effect_fn):
	return {
		"events": [
			NRUtil.merge(NRCardXlate.successful_run_replace_breach({
			"target-server": NRServers.target_server,
			"ability": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, card, {
					"ignore-all-cost": true,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				}),
			},
		}) if NRCardXlate.successful_run_replace_breach({
			"target-server": NRServers.target_server,
			"ability": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, card, {
					"ignore-all-cost": true,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				}),
			},
		}) is Dictionary else {}, {"location": "hand"}),
			NRUtil.merge(NRCardXlate.successful_run_replace_breach({
			"target-server": NRServers.target_server,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return NRCardXlate.in_hand_star(state, card),
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, card, {
					"ignore-all-cost": true,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				}),
			},
		}) if NRCardXlate.successful_run_replace_breach({
			"target-server": NRServers.target_server,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return NRCardXlate.in_hand_star(state, card),
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, card, {
					"ignore-all-cost": true,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				}),
			},
		}) is Dictionary else {}, {"location": "hosted"}),
		],
		"abilities": [
			{
			"async": true,
			"cost": [NRPayment.to_c("trash-can")],
			"msg": message,
			"effect": func(state, side, eid, card, targets):
				return effect_fn(state, side, eid, card, targets),
		},
		],
	}


static func move_virus_counter(state, side, eid, from, to, count):
	return NREid.wait_for(state, eid, func(ne):
		NRProps.add_counter(state, side, ne, from, "virus", (-count), {
		"suppress-checkpoint": true,
	})
	, func(async_result):
		NRProps.add_counter(state, side, eid, to, "virus", count))


static func companion_builder(pay_credits_req, turn_ends_ability, ability):
	return (func():
		var place_credit = {
			"msg": "add 1 [Credits] to itself",
			"automatic": "gain-credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 1),
		}
		return {
			"interactions": {
				"pay-credits": {
					"req": pay_credits_req,
					"type": "credit",
				},
			},
			"events": [
				NRUtil.merge(place_credit if place_credit is Dictionary else {}, {"event": "runner-turn-begins"}),
				NRUtil.merge(place_credit if place_credit is Dictionary else {}, {"event": "agenda-stolen"}),
				{
				"event": "runner-turn-ends",
				"req": func(state, side, eid, card, targets): return (3 <= NRCard.get_counters(NRCard.get_card(state, card), "credit")),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, turn_ends_ability, card, targets),
			},
			],
			"abilities": [ability],
		}
	).call()


static func trash_when_tagged(cname, c):
	return (func():
		var _b0 = evs([], [
			NRUtil.merge(ev() if ev() is Dictionary else {}, {"event": "tags-changed"}),
			NRUtil.merge(ev() if ev() is Dictionary else {}, {"event": "disabled-cards-updated"}),
		])
		return NRUtil.merge(c if c is Dictionary else {}, {"events": (NRUtil.as_array([]) + NRUtil.as_array((NRUtil.as_array(NRCardXlate.getk(c, "events", null)) + NRUtil.as_array(evs()))))})
	).call()


static func bitey_boi(f):
	return (func():
		var selector = resolve(f)
		var descriptor = str(f)
		return {
			"abilities": [
				{
				"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state)) and (not (NRCardXlate.getk(selector(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)), "broken", null)))),
				"break": 1,
				"breaks": "All",
				"break-cost": [NRPayment.to_c("trash-can")],
				"cost": [NRPayment.to_c("trash-can")],
				"label": (str("Break the ") + str(descriptor) + str(" subroutine")),
				"msg": func(state, side, eid, card, targets): return str("break the ") + str(descriptor) + str(" subroutine on ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str(" (\"[subroutine] ") + str(NRCardXlate.getk(selector(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)), "label", null)) + str("\")"),
				"effect": func(state, side, eid, card, targets):
					return NRIce.break_subroutine_bang(state, NRIce.get_current_ice(state), selector(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null))),
			},
			],
		}
	).call()


static func _register_1() -> void:
	NRCardDefs.defcard("Aaron Marrón", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever an agenda is scored or stolen, place 2 power counters on Aaron Marrón.\n<strong>Hosted power counter:</strong> Remove 1 tag and draw 1 card.",
		"code": "11106",
		"title": "Aaron Marrón",
	}, (func():
		var am = {
			"msg": "place 2 power counters on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 2),
		}
		return {
			"abilities": [
				{
				"cost": [NRPayment.to_c("power", 1)],
				"keep-menu-open": "while-power-tokens-left",
				"msg": "remove 1 tag and draw 1 card",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRTags.lose_tags(state, side, ne, 1)
				, func(async_result):
					NRDrawing.draw(state, side, eid, 1)),
			},
			],
			"events": [
				NRUtil.merge(am if am is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(am if am is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Access to Globalsec", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Link",
		"subtypes": ["Link"],
		"text": "+1[link]",
		"code": "01052",
		"title": "Access to Globalsec",
	}, {
		"static-abilities": [link_(1)],
	}))

	NRCardDefs.defcard("Activist Support", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When the Corp's turn begins, take 1 tag if you have no tags.\nWhen your turn begins, give the Corp 1 bad publicity if they have no bad publicity.",
		"code": "04062",
		"title": "Activist Support",
	}, {
		"events": [
			{
			"event": "corp-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRTags.gain_tags(state, "runner", eid, 1)
				return NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to take 1 tag")))
			).call() if (NRCardXlate.count_tags(state) == 0) else NREid.effect_completed(state, "runner", eid)),
		},
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)
				return NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to give the corp 1 bad publicity")))
			).call() if (not (has_bad_pub_p(state))) else NREid.effect_completed(state, "runner", eid)),
		},
		],
	}))

	NRCardDefs.defcard("Adjusted Chronotype", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Genetics",
		"subtypes": ["Genetics"],
		"text": "The first time each turn you lose [Click] except by paying the trigger cost of a paid ability, gain [Click].",
		"code": "08003",
		"title": "Adjusted Chronotype",
	}, {
		"events": [
			{
			"event": "runner-click-loss",
			"req": func(state, side, eid, card, targets): return (func():
				var click_losses = NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "runner-lose")).filter(func(_pct, _pct2=null, _pct3=null): return (("click" == NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)) or NRUtil.kw_eq("click", NRCardXlate.getk(NRUtil.first_of(_pct), "type", null))))).size()
				return (((1 == click_losses) or NRUtil.kw_eq(1, click_losses)) or (((2 == click_losses) or NRUtil.kw_eq(2, click_losses)) and has_flag_p(state, side, "persistent", "genetics-trigger-twice")))
			).call(),
			"msg": "gain [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, "runner", 1),
		},
		],
	}))

	NRCardDefs.defcard("Aeneas Informant", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever you access a card with a trash cost not in Archives and do not trash it, you may reveal it and gain 1[Credits].",
		"code": "12044",
		"title": "Aeneas Informant",
	}, {
		"events": [
			{
			"event": "post-access-card",
			"optional": {
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card-snapshot", null), "trash", null) and (not (NRCard.in_discard(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))))),
				"prompt": "Gain 1 [Credits] and reveal accessed card?",
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str((str("gain 1 [Credits]") + str(((str(" and reveal ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null))) if (not (NRCard.installed(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)))) else null)))),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, 1),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Aeneas Informant")],
	}))

	NRCardDefs.defcard("Aesop's Pawnshop", NRCardXlate.merge_cdef({
		"title": "Aesop's Pawnshop",
	}, (func():
		var ability = {
			"async": true,
			"label": "trash a card to gain 3 [Credits]",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRBoard.all_installed(state, "runner")).size() >= 2),
			"choices": {
				"not-self": true,
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets))),
			},
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" and gain 3 [Credits]"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
				"unpreventable": true,
				"cause-card": card,
			})
			, func(async_result):
				NRGaining.gain_credits(state, side, eid, 3)),
		}
		return {
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return (NRUtil.as_array(NRBoard.all_installed(state, "runner")).size() >= 2),
			},
			"events": [NRUtil.merge(ability if ability is Dictionary else {}, {"skippable": true})],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Akshara Sareen", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Each player gets +1 allotted [Click] for each of their turns.",
		"code": "10046",
		"title": "Akshara Sareen",
	}, {
		"in-play": ["click-per-turn", 1],
		"on-install": {
			"msg": "give each player 1 additional [Click] to spend during their turn",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain(state, "corp", "click-per-turn", 1),
		},
		"leave-play": func(state, side, eid, card, targets):
			return NRGaining.lose(state, "corp", "click-per-turn", 1),
	}))

	NRCardDefs.defcard("Algo Trading", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When your turn begins, you may move up to 3[Credits] from your credit pool to Algo Trading.\nWhen your turn begins, place 2[Credits] on Algo Trading from the bank if there are at least 6[Credits] on it.\n[Click],[Trash]: Take all credits from Algo Trading.",
		"code": "11029",
		"title": "Algo Trading",
	}, {
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return (NRCardXlate.getk(state.getv("runner", {}), "credit", null) > 0),
		},
		"abilities": [
			{
			"label": "Store up to 3 [Credit]",
			"prompt": "How many credits do you want to store?",
			"once": "per-turn",
			"choices": {
				"number": func(state, side, eid, card, targets):
					return mini(3, total_available_credits(state, "runner", eid, card)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "credit", NRCardXlate.first_target(targets), {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRGaining.lose_credits(state, side, eid, NRCardXlate.first_target(targets))),
			"msg": func(state, side, eid, card, targets): return str("store ") + str(NRCardXlate.first_target(targets)) + str(" [Credit]"),
		},
			{
			"action": true,
			"label": "Take all hosted credits",
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRCard.get_counters(card, "credit")) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-3")
				return NRCardXlate.take_credits(state, side, eid, card, "credit", "all"),
		},
		],
		"events": [
			{
			"event": "runner-turn-begins",
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "credit") >= 6),
			"msg": "place 2 [Credit] on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 2),
		},
		],
	}))

	NRCardDefs.defcard("All-nighter", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "[Click], [Trash]: Gain [Click][Click].",
		"code": "20053",
		"title": "All-nighter",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 2),
			"msg": "gain [Click][Click]",
		},
		],
	}))

	NRCardDefs.defcard("Always Be Running", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Adam",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Directive - Virtual",
		"subtypes": ["Directive", "Virtual"],
		"text": "The first [Click] you spend each turn must be spent to take the basic action to play an event or the basic action to run a server. You cannot take the action to play an event this way except if you play a <strong>run</strong> event.\nOnce per turn → <strong>Lose [Click][Click]:</strong> Break 1 subroutine.",
		"code": "09041",
		"title": "Always Be Running",
	}, {
		"implementation": "Run requirement not enforced",
		"events": [
			{
			"event": "runner-turn-begins",
			"effect": func(state, side, eid, card, targets):
				return NRToasts.toast(state, "runner", "Reminder: Always Be Running requires a run on the first click", "info"),
		},
		],
		"abilities": [
			NRUtil.merge(NRCardXlate.break_sub([NRPayment.to_c("lose-click", 2)], 1, "All", {
			"req": func(state, side, eid, card, targets): return true,
		}) if NRCardXlate.break_sub([NRPayment.to_c("lose-click", 2)], 1, "All", {
			"req": func(state, side, eid, card, targets): return true,
		}) is Dictionary else {}, {"once": "per-turn"}),
		],
	}))

	NRCardDefs.defcard("Amelia Earhart", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Virtual - Companion",
		"subtypes": ["Virtual", "Companion"],
		"text": "Whenever a run on HQ or R&D ends, if you accessed 3 or more cards during that run, place 1 power counter on this resource.\nWhen your turn begins, you may remove 3 hosted power counters and trash this resource. If you do, the Corp loses 10[Credits].",
		"code": "34083",
		"title": "Amelia Earhart",
	}, {
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"events": [
			{
			"event": "run-ends",
			"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["hq", "rd"], NRServers.target_server(NRCardXlate.ctx(targets))) and (total_cards_accessed(NRCardXlate.ctx(targets)) >= 3)),
			"msg": "add 1 power counter to itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, NRCard.get_card(state, card), "power", 1),
		},
			{
			"event": "runner-turn-begins",
			"skippable": true,
			"optional": {
				"prompt": "Trash this resource to force the Corp to lose 10 [Credits]?",
				"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRCard.get_card(state, card), "power") >= 3),
				"yes-ability": {
					"msg": "trash itself and force the Corp to lose 10 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, card, {
						"cause-card": card,
					})
					, func(async_result):
						NRGaining.lose_credits(state, "corp", eid, mini(10, NRCardXlate.getk(state.getv("corp", {}), "credit", null)))),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Angel Arena", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "Place X power counters on Angel Arena when it is installed. When there are no power counters left on Angel Arena, trash it.\n<strong>Hosted power counter:</strong> Reveal the top card of your stack. You may add that card to the bottom of your stack.",
		"code": "06080",
		"title": "Angel Arena",
	}, {
		"on-install": {
			"prompt": "How many credits do you want to spend?",
			"choices": "credit",
			"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "power counter")) + str(" on itself"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", NRCardXlate.first_target(targets)),
		},
		"events": [trash_on_empty("power")],
		"abilities": [
			{
			"cost": [NRPayment.to_c("power", 1)],
			"keep-menu-open": "while-power-tokens-left",
			"msg": "reveal the top card of Stack",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var top_card = NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null))
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, card, null, top_card)
				, func(async_result):
					NREngine.continue_ability(state, side, {
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Add ") + str(NRCardXlate.getk(top_card, "title", null)) + str(" to bottom of Stack?"),
						"yes-ability": {
							"msg": (str("move ") + str(NRCardXlate.getk(top_card, "title", null)) + str(" to the bottom of the Stack")),
							"effect": func(state, side, eid, card, targets):
								return NRMoving.move(state, side, NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "deck"),
						},
					},
				}, card, null))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Armitage Codebusting", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "Place 12[Credits] from the bank on Armitage Codebusting when it is installed. When there are no credits left on Armitage Codebusting, trash it.\n[Click]: Take 2[Credits] from Armitage Codebusting.",
		"code": "25062",
		"title": "Armitage Codebusting",
	}, {
		"data": {
			"counter": {
				"credit": 12,
			},
		},
		"events": [trash_on_empty("credit")],
		"abilities": [
			NRCardXlate.take_n_credits_ability(2, "resource", {
			"label": "Take 2 [Credits]",
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
		}),
		],
	}))

	NRCardDefs.defcard("Artist Colony", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "<strong>Forfeit 1 agenda:</strong> Search your stack for 1 program, resource, or piece of hardware. Install that card.",
		"code": "10009",
		"title": "Artist Colony",
	}, {
		"abilities": [
			{
			"prompt": "Choose a card to install",
			"label": "install a card",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"req": func(state, side, eid, card, targets): return (not (NRInstalling.install_locked(state, side))),
			"cost": [NRPayment.to_c("forfeit")],
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (not (NRCard.event(_pct)))),
			"cancel": NRUtil.merge(fail_to_find_bang if fail_to_find_bang is Dictionary else {}, {"cost": [NRPayment.to_c("forfeit")]}),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"include-cost-from-eid": eid,
					"display-origin": true,
				},
			}),
		},
		],
	}))

	NRCardDefs.defcard("Arruaceiras Crew", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "Once per turn → <strong>Take 1 tag:</strong> The ice you are encountering gets –2 strength for the remainder of this encounter.\n[Trash], <strong>2[Credits]:</strong> Trash the ice you are encountering if its strength is 0 or less.",
		"code": "34073",
		"title": "Arruaceiras Crew",
	}, {
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return NRRuns.active_encounter(state),
			"cost": [NRPayment.to_c("gain-tag", 1)],
			"once": "per-turn",
			"label": "Give encountered ice -2 strength",
			"msg": func(state, side, eid, card, targets): return str("give ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str(" -2 strength for the remainder of the encounter"),
			"effect": func(state, side, eid, card, targets):
				return pump_ice(state, side, NRIce.get_current_ice(state), -2, "end-of-encounter"),
		},
			{
			"label": "Trash encountered ice",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and (not ((NRIce.ice_strength(state, side, NRIce.get_current_ice(state)) > 0)))),
			"cost": [NRPayment.to_c("credit", 2), NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, NRIce.get_current_ice(state), {
				"cause-card": card,
			}),
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
		},
		],
	}))

	NRCardDefs.defcard("Asmund Pudlat", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "When you install this resource, search your stack for up to 2 <strong>virus</strong> or <strong>weapon</strong> cards with different names. Host those cards faceup on this resource. <em>(They are not installed.)</em>\nWhen your turn begins, you may add 1 hosted card to your grip. If there are no more hosted cards, trash this resource.",
		"code": "33082",
		"title": "Asmund Pudlat",
	}, (func():
		var _b0 = trash_if_empty([state, side, eid, card], (NREid.effect_completed(state, side, eid) if (not ((NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null) is Array and NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null).is_empty() if false else (str(NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null)) == "")))) else (func():
			NRSay.system_msg(state, side, (str("trashes ") + str(NRCard.get_title(card))))
			return NRMoving.trash(state, side, eid, card, {
				"unpreventable": true,
				"source-card": card,
			})
		).call()))
		return {
			"on-install": search_and_host(2),
			"events": [
				{
				"event": "runner-turn-begins",
				"skippable": true,
				"label": "Add a hosted card to the grip (start of turn)",
				"prompt": "Choose a hosted card to move to the grip",
				"choices": {
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null)),
				},
				"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCard.get_title(NRCardXlate.first_target(targets))) + str(" to the grip"),
				"once": "per-turn",
				"async": true,
				"waiting-prompt": true,
				"cancel": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return trash_if_empty(state, side, eid, card),
				},
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
					return trash_if_empty(state, side, eid, card),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Assimilator", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Apex",
		"cost": 5,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Click],[Click]: Turn one of your facedown installed cards faceup. If that card is an event, trash it.",
		"code": "21008",
		"title": "Assimilator",
	}, {
		"abilities": [
			{
			"action": true,
			"label": "Turn a facedown card faceup",
			"cost": [NRPayment.to_c("click", 2)],
			"keep-menu-open": "while-2-clicks-left",
			"prompt": "Choose a facedown installed card",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.facedown(_pct) and NRCard.installed(_pct) and NRCard.runner(_pct)),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("turn ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" faceup"),
			"effect": func(state, side, eid, card, targets):
				return (NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
				"unpreventable": true,
			}) if NRCard.event(NRCardXlate.first_target(targets)) else (func():
				NRMoving.flip_faceup(state, side, NRCardXlate.first_target(targets))
				return NREngine.checkpoint(state, null, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Avgustina Ivanovskaya", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The first time each turn you install a <strong>virus</strong> program, sabotage 1. <em>(The Corp trashes 1 card of their choice from HQ or the top of R&D.)</em>",
		"code": "33008",
		"title": "Avgustina Ivanovskaya",
	}, {
		"events": [
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return (virus_program_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and NREvents.first_event(state, side, "runner-install", func(_pct, _pct2=null, _pct3=null): return virus_program_p(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRSabotage.sabotage(1), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Backstitching", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "When your turn begins, identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nWhenever you encounter a piece of ice during a run on your mark, you may trash this resource to bypass that ice.",
		"code": "33019",
		"title": "Backstitching",
	}, (func():
		return {
			"events": [
				mark_changed_event,
				NRUtil.merge(NRMark.identify_mark_ability if NRMark.identify_mark_ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				{
				"event": "encounter-ice",
				"skippable": true,
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"prompt": func(state, side, eid, card, targets): return str("Trash ") + str(NRCardXlate.getk(card, "title", null)) + str(" to bypass ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str("?"),
					"req": func(state, side, eid, card, targets): return (is_min_index(state, card) and ((NRCardXlate.getk(state, "mark", null) == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq(NRCardXlate.getk(state, "mark", null), NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))))),
					"yes-ability": {
						"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, side, ne, card, {
							"cause-card": card,
							"cause": "runner-ability",
						})
						, func(async_result):
							(func():
							NRCardXlate.bypass_ice(state)
							return NREid.effect_completed(state, side, eid)
						).call()),
					},
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("\"Baklan\" Bochkin", NRCardXlate.merge_cdef({
		"title": "\"Baklan\" Bochkin",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"automatic": "pre-bypass",
			"req": func(state, side, eid, card, targets): return NREvents.first_run_event(state, side, "encounter-ice"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
		],
		"abilities": [
			{
			"label": "Derez a piece of ice currently being encountered",
			"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state)) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRCard.get_counters(NRCard.get_card(state, card), "power"))),
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRezzing.derez(state, side, ne, NRIce.get_current_ice(state), {
				"msg-keys": {
					"include-cost-from-eid": eid,
				},
			})
			, func(async_result):
				NREngine.continue_ability(state, side, NRTags.gain_tags_ability(1), card, null)),
		},
		],
	}))

	NRCardDefs.defcard("Bank Job", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When you install this resource, load 8[Credits] on it. When it is empty, trash it.\nWhenever you make a successful run on a remote server, instead of breaching that server, you may take any number of credits from this resource.",
		"code": "25038",
		"title": "Bank Job",
	}, {
		"data": {
			"counter": {
				"credit": 8,
			},
		},
		"events": [
			trash_on_empty("credit"),
			NRCardXlate.successful_run_replace_breach({
			"target-server": "remote",
			"ability": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					return (NREngine.continue_ability(state, side, {
						"async": true,
						"prompt": func(state, side, eid, card, targets): return str("Choose a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" to use"),
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(card, "title", null)))),
						},
						"effect": func(state, side, eid, card, targets):
							return NREngine.continue_ability(state, side, select_credits_ability(NRCardXlate.first_target(targets)), NRCardXlate.first_target(targets), null),
					}, card, null) if (1 < NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == "Bank Job") or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), "Bank Job")))).size()) else NREngine.continue_ability(state, side, select_credits_ability(card), card, null))
				).call(),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Bazaar", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "Whenever you install a piece of hardware from your grip, you may install another copy of that hardware from your grip (paying all costs).",
		"code": "10065",
		"title": "Bazaar",
	}, (func():
		return {
			"events": [
				{
				"event": "runner-install",
				"interactive": func(state, side, eid, card, targets):
					return hardware_and_in_hand_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), state.getv("runner", {}), state),
				"silent": func(state, side, eid, card, targets):
					return (not (hardware_and_in_hand_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), state.getv("runner", {}), state))),
				"async": true,
				"req": func(state, side, eid, card, targets): return (NRCard.hardware(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and ((["hand"] == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "previous-zone", null)) or NRUtil.kw_eq(["hand"], NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "previous-zone", null)))),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, (func():
					var hw = NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)
					return {
						"optional": {
							"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(_pct, "title", null) == hw) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), hw)) else null)) != null),
							"prompt": func(state, side, eid, card, targets): return str("Install another copy of ") + str(hw) + str("?"),
							"yes-ability": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return (func():
									var c = (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(_pct, "title", null) == hw) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), hw)) else null)) != null)
									return NRInstalling.runner_install(state, side, eid, c, {
									"msg-keys": {
										"display-origin": true,
										"install-source": card,
									},
								}) if c != null else NREid.effect_completed(state, side, eid)
								).call(),
							},
						},
					}
				).call(), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Beach Party", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "When your turn begins, lose [Click].\nYour maximum hand size is increased by 5.",
		"code": "08031",
		"title": "Beach Party",
	}, {
		"static-abilities": [runner_hand_size_(5)],
		"events": [
			{
			"event": "runner-turn-begins",
			"automatic": "lose-clicks",
			"msg": "lose [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_clicks(state, side, 1),
		},
		],
	}))

	NRCardDefs.defcard("Beatriz Friere Gonzalez", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click][Click]<strong>:</strong> Run HQ. If successful, instead of breaching HQ, breach R&D. When you do, access 1 additional card.",
		"code": "34028",
		"title": "Beatriz Friere Gonzalez",
	}, {
		"abilities": [
			NRCardXlate.run_server_ability("hq", {
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "hq",
				"duration": "end-of-run",
				"unregister-once-resolved": true,
				"mandatory": true,
				"ability": {
					"msg": "breach R&D, accessing 1 additional card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NREngine.register_events(state, side, card, [breach_access_bonus("rd", 1, {
						"duration": "end-of-run",
					})])
						return NRAccess.breach_server(state, "runner", eid, ["rd"], null),
				},
			}),
			],
		}),
		],
	}))

	NRCardDefs.defcard("Beth Kilrain-Chang", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "If the Corp has 5-9[Credits] when your turn begins, gain 1[Credits].\nIf the Corp has 10-14[Credits] when your turn begins, draw 1 card.\nIf the Corp has at least 15[Credits] when your turn begins, gain [Click].",
		"code": "11030",
		"title": "Beth Kilrain-Chang",
	}, (func():
		var ability = {
			"once": "per-turn",
			"automatic": "gain-clicks",
			"label": "Gain 1 [Credits], draw 1 card, or gain [Click] (start of turn)",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var c = NRCardXlate.getk(state.getv("corp", {}), "credit", null)
				var b = NRCardXlate.getk(card, "title", null)
				return ((func():
					NRSay.system_msg(state, side, (str("uses ") + str(b) + str(" to gain 1 [Credits]")))
					return NRGaining.gain_credits(state, side, eid, 1)
				).call() if true else ((func():
					NRSay.system_msg(state, side, (str("uses ") + str(b) + str(" to draw 1 card")))
					return NRDrawing.draw(state, side, eid, 1)
				).call() if true else ((func():
					NRSay.system_msg(state, side, (str("uses ") + str(b) + str(" to gain [Click]")))
					NRGaining.gain_clicks(state, side, 1)
					return NREid.effect_completed(state, side, eid)
				).call() if (15 <= c) else NREid.effect_completed(state, side, eid))))
			).call(),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Bhagat", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The first time you make a successful run on HQ each turn, force the Corp to trash the top card of R&D.",
		"code": "10098",
		"title": "Bhagat",
	}, {
		"events": [
			{
			"event": "successful-run",
			"automatic": "force-discard",
			"async": true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "hq")),
			"msg": "force the Corp to trash the top card of R&D",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.mill(state, "corp", eid, "corp", 1),
		},
		],
	}))

	NRCardDefs.defcard("Bio-Modeled Network", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent all but 1 net damage.",
		"code": "12006",
		"title": "Bio-Modeled Network",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"max-uses": 1,
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null) > 1) and (("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str((NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null) - 1)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, (NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null) - 1)),
			},
		},
		],
	}))

	NRCardDefs.defcard("Biometric Spoofing", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent 2 damage.",
		"code": "13026",
		"title": "Biometric Spoofing",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"max-uses": 1,
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(mini(2, NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null))) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, mini(2, NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null))),
			},
		},
		],
	}))

	NRCardDefs.defcard("Blockade Runner", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click],[Click]: Draw 3 cards. Shuffle 1 card from your grip into your stack.",
		"code": "11065",
		"title": "Blockade Runner",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"keep-menu-open": "while-2-clicks-left",
			"msg": "draw 3 cards and shuffle 1 card from the grip back into the stack",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-card-3")
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, side, ne, 3)
			, func(async_result):
				NREngine.continue_ability(state, side, {
				"prompt": "Choose a card in the grip to shuffle back into the stack",
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()),
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.runner(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, side, NRCardXlate.first_target(targets), "deck")
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}, card, null)),
		},
		],
	}))

	NRCardDefs.defcard("Bloo Moose", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 4,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location - Seedy",
		"subtypes": ["Location", "Seedy"],
		"text": "When your turn begins, you may remove 1 card in the heap from the game. If you do, gain 2[Credits].",
		"code": "12089",
		"title": "Bloo Moose",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return (not (NRFlags.zone_locked(state, "runner", "discard"))),
			"label": "Remove a card in the Heap from the game to gain 2 [Credits]",
			"once": "per-turn",
			"prompt": "Choose a card in the Heap",
			"show-discard": true,
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_discard(_pct) and NRCard.runner(_pct)),
			},
			"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the game and gain 2 [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "rfg")
				return NRGaining.gain_credits(state, side, eid, 2),
		}
		return {
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return (not (NRFlags.zone_locked(state, "runner", "discard"))),
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Borrowed Satellite", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Link",
		"subtypes": ["Link"],
		"text": "+1[link]\nYour maximum hand size is increased by 1.",
		"code": "03050",
		"title": "Borrowed Satellite",
	}, {
		"static-abilities": [link_(1), runner_hand_size_(1)],
	}))

	NRCardDefs.defcard("Bug Out Bag", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"factioncost": 2,
		"uniqueness": false,
		"text": "When you install this resource, place X power counters on it.\nWhen your turn ends, if you have no cards in your grip, draw 1 card for each hosted power counter, then trash this resource.",
		"code": "12064",
		"title": "Bug Out Bag",
	}, {
		"on-install": {
			"prompt": "How many credits do you want to spend?",
			"choices": "credit",
			"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "power counter")) + str(" on itself"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", NRCardXlate.first_target(targets)),
		},
		"events": [
			{
			"event": "runner-turn-ends",
			"automatic": "draw-cards",
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() == 0),
			"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify(NRCard.get_counters(card, "power"), "card")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, side, ne, NRCard.get_counters(card, "power"))
			, func(async_result):
				NRMoving.trash(state, side, eid, card, {
				"cause-card": card,
			})),
		},
		],
	}))

	NRCardDefs.defcard("Caldera", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[interrupt] → <strong>3[Credits]:</strong> Prevent 1 core damage or 1 net damage.",
		"code": "12105",
		"title": "Caldera",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("credit", 3)],
				"msg": func(state, side, eid, card, targets): return str("prevent 1 ") + str(damage_name(state)) + str(" damage"),
				"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["net", "core", "brain"], NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
		],
	}))

	NRCardDefs.defcard("Cacophony", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The first time each turn you steal or trash a Corp card, place 1 power counter on this resource.\nWhen your action phase ends, you may remove 2 hosted power counters to sabotage 3. <em>(The Corp trashes 3 cards of their choice from HQ and/or the top of R&D.)</em>",
		"code": "35010",
		"title": "Cacophony",
	}, (func():
		var ev = {
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		}
		var valid_ctx_p = func(evs): return (NRUtil.find_first(NRUtil.as_array(evs), func(_pct, _pct2=null, _pct3=null): return NRCard.corp(NRCardXlate.getk(_pct, "card", null))) != null)
		return {
			"events": [
				{
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
				"event": "runner-trash",
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets): return (valid_ctx_p(targets) and NREvents.first_event(state, side, "runner-trash", valid_ctx_p) and NREvents.no_event(state, "runner", "agenda-stolen")),
			},
				{
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
				"async": true,
				"event": "agenda-stolen",
				"req": func(state, side, eid, card, targets): return (NREvents.no_event(state, side, "runner-trash", valid_ctx_p) and NREvents.first_event(state, "runner", "agenda-stolen")),
			},
				{
				"event": "runner-turn-ends",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"skippable": true,
				"optional": {
					"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "power") >= 2),
					"prompt": "Sabotage 3?",
					"waiting-prompt": true,
					"yes-ability": NRUtil.merge(NRSabotage.sabotage(3) if NRSabotage.sabotage(3) is Dictionary else {}, {"cost": [NRPayment.to_c("power", 2)]}),
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Charlatan", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "<strong>[Click][Click]:</strong> Run any server. The first time you approach a rezzed piece of ice during this run, you may pay credits equal to the strength of that ice. If you do, when you encounter that ice after this approach, bypass it.",
		"code": "13010",
		"title": "Charlatan",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"label": "Make a run",
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.register_events(state, side, card, [
				{
				"event": "approach-ice",
				"unregister-once-resolved": true,
				"duration": "end-of-run",
				"optional": {
					"prompt": func(state, side, eid, card, targets): return str("Pay ") + str(NRIce.get_strength(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))) + str(" [Credits] to bypass encountered piece of ice?"),
					"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and NREvents.first_run_event(state, side, "approach-ice", func(targets): return (func():
						var context = NRUtil.first_of(targets)
						return NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))
					).call()) and NRPayment.can_pay(state, "runner", eid, card, null, [
						NRPayment.to_c("credit", NRIce.get_strength(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))),
					])),
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
							var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
							return NREid.wait_for(state, eid, func(ne):
								NREngine.pay(state, "runner", ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("credit", NRIce.get_strength(ice))])
							, func(async_result):
								(func():
								var payment_str = NRCardXlate.getk(async_result, "msg", null)
								return (func():
								NRSay.system_msg(state, "runner", (str(build_spend_msg(payment_str, "use")) + str(NRCardXlate.getk(card, "title", null)) + str(" to bypass ") + str(NRCardXlate.getk(ice, "title", null))))
								NREngine.register_events(state, "runner", card, [
									{
									"event": "encounter-ice",
									"automatic": "bypass",
									"req": func(state, side, eid, card, targets): return (NRUtil.same_card(ice, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))),
									"effect": func(state, side, eid, card, targets):
										return NRCardXlate.bypass_ice(state),
								},
								])
								return NREid.effect_completed(state, side, eid)
							).call() if payment_str != null else (func():
								NRSay.system_msg(state, "runner", (str("can't afford to pay to bypass ") + str(NRCardXlate.getk(ice, "title", null))))
								return NREid.effect_completed(state, side, eid)
							).call()
							).call())
						).call(),
					},
				},
			},
			])
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		],
	}))

	NRCardDefs.defcard("Chatterjee University", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "[Click]: Place 1 power counter on Chatterjee University.\n[Click]: Install a program from your grip, lowering the install cost by 1 for each power counter on Chatterjee University. Remove 1 hosted power counter.",
		"code": "10010",
		"title": "Chatterjee University",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"label": "Place 1 power counter",
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()),
			},
			"label": "Install a program from the grip",
			"prompt": "Choose a program to install",
			"async": true,
			"choices": {
				"async": true,
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": (-NRCard.get_counters(card, "power")),
				})),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRInstalling.runner_install(state, side, ne, NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
					"cost-bonus": (-NRCard.get_counters(card, "power")),
				})
				, func(async_result):
					(NRProps.add_counter(state, side, eid, card, "power", -1) if (NRCard.get_counters(card, "power") > 0) else NREid.effect_completed(state, side, eid))),
			},
		},
		],
	}))

	NRCardDefs.defcard("Chrome Parlor", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "[interrupt] → Whenever you would suffer damage from a \"when installed\" ability on a piece of <strong>cybernetic</strong> hardware, prevent all of that damage.",
		"code": "08044",
		"title": "Chrome Parlor",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "event",
			"max-uses": 1,
			"mandatory": true,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "source-card", null), "Cybernetic") and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, "all"),
			},
		},
		],
	}))

	NRCardDefs.defcard("Citadel Sanctuary", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "When your discard phase ends while you are tagged, the Corp must trace[1]. If unsuccessful, remove 1 tag.\n[interrupt] → [Trash], <strong>trash all cards from your grip:</strong> Prevent all meat damage.",
		"code": "11070",
		"title": "Citadel Sanctuary",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"prompt": "Use Citadel Sanctuary to prevent meat damage?",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("trash-can"), NRPayment.to_c("trash-entire-hand")],
				"req": func(state, side, eid, card, targets): return ((("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, "all"),
			},
		},
		],
		"events": [
			{
			"event": "runner-turn-ends",
			"automatic": "trace",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "force the Corp to initiate a trace",
			"label": "Trace 1 - If unsuccessful, Runner removes 1 tag",
			"trace": {
				"base": 1,
				"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
				"unsuccessful": {
					"msg": "remove 1 tag",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRTags.lose_tags(state, "runner", eid, 1),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Clan Vengeance", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Clan",
		"subtypes": ["Clan"],
		"text": "Whenever you suffer any amount of damage, place 1 power counter on Clan Vengeance.\n[Trash]: Trash 1 card from HQ at random for each power counter on Clan Vengeance.",
		"code": "12022",
		"title": "Clan Vengeance",
	}, {
		"events": [
			{
			"event": "damage",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null) > 0),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
		],
		"abilities": [
			{
			"label": "Trash 1 random card from HQ for each hosted power counter",
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "power") > 0),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.quantify(mini(NRCard.get_counters(card, "power"), NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()), "card")) + str(" from HQ"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(state, side, eid, NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(mini(NRCard.get_counters(card, "power"), NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()))), {
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Climactic Showdown", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 5,
		"uniqueness": true,
		"text": "When your turn begins, remove this resource from the game. Choose a server protected by ice. The Corp may trash 1 piece of ice protecting that server. If they do not, the first time this turn you breach either R&D or HQ, access 2 additional cards.",
		"code": "26006",
		"title": "Climactic Showdown",
	}, (func():
		var _b0 = trash_or_bonus([chosen_server], {
			"player": "corp",
			"waiting-prompt": true,
			"prompt": "Choose a piece of ice to trash",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (((NRUtil.last_of(NRCard.get_zone(_pct)) == "ices") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(_pct)), "ices")) and ((chosen_server == (NRUtil.as_array(butlast(NRCard.get_zone(_pct))).slice(1) if NRUtil.as_array(butlast(NRCard.get_zone(_pct))).size() > 0 else [])) or NRUtil.kw_eq(chosen_server, (NRUtil.as_array(butlast(NRCard.get_zone(_pct))).slice(1) if NRUtil.as_array(butlast(NRCard.get_zone(_pct))).size() > 0 else [])))),
			},
			"async": true,
			"display-side": "corp",
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, "corp", eid, NRCardXlate.first_target(targets), {
				"unpreventable": true,
				"cause-card": card,
				"cause": "forced-to-trash",
			}),
			"cancel": {
				"display-side": "corp",
				"msg": func(state, side, eid, card, targets): return str("decline to trash a piece of ice protecting ") + str(NRServers.zone_to_name(chosen_server)),
				"effect": func(state, side, eid, card, targets):
					return NREngine.register_events(state, "runner", card, [
					{
					"event": "breach-server",
					"automatic": "pre-breach",
					"duration": "until-runner-turn-ends",
					"req": func(state, side, eid, card, targets): return NRUtil.in_coll(["hq", "rd"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)),
					"once": "per-turn",
					"msg": func(state, side, eid, card, targets): return str("access 2 additional cards from ") + str(NRServers.zone_to_name(NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return NRAccess.access_bonus(state, "runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null), 2),
				},
				]),
			},
		})
		return {
			"events": [
				{
				"event": "runner-turn-begins",
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var card = NRMoving.move(state, side, card, "rfg")
					return NREngine.continue_ability(state, side, ({
						"prompt": "Choose a server",
						"waiting-prompt": true,
						"choices": func(state, side, eid, card, targets):
							return iced_servers(state, side, eid, card),
						"msg": func(state, side, eid, card, targets): return str("choose ") + str(NRServers.zone_to_name(NRServers.unknown_to_kw(NRCardXlate.first_target(targets)))) + str(" and remove itself from the game"),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREngine.continue_ability(state, "corp", trash_or_bonus((NRUtil.as_array(NRBoard.server_to_zone(state, NRCardXlate.first_target(targets))).slice(1) if NRUtil.as_array(NRBoard.server_to_zone(state, NRCardXlate.first_target(targets))).size() > 0 else [])), card, null),
					} if (NRUtil.as_array(iced_servers(state, side, eid, card)).size() > 0) else {
						"msg": "remove itself from the game",
					}), card, null)
				).call(),
			},
			],
		}
	).call()))


static func _register_2() -> void:
	NRCardDefs.defcard("Compromised Employee", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection - Link",
		"subtypes": ["Connection", "Link"],
		"text": "1[recurring-credit]\nUse this credit during traces.\nGain 1[Credits] whenever the Corp rezzes a piece of ice.",
		"code": "02025",
		"title": "Compromised Employee",
	}, {
		"recurring": 1,
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (("trace" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("trace", NRCardXlate.getk(eid, "source-type", null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Cookbook", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever you install a <strong>virus</strong> program, you may place 1 virus counter on it.",
		"code": "30009",
		"title": "Cookbook",
	}, {
		"special": {
			"auto-fire": "always",
		},
		"events": [
			{
			"event": "runner-install",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Place 1 virus counter?",
				"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Virus"),
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str("place 1 virus counter on ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "virus", 1),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Cookbook")],
	}))

	NRCardDefs.defcard("Corporate Defector", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever the Corp draws a card with the basic action, reveal that card.",
		"code": "12109",
		"title": "Corporate Defector",
	}, {
		"events": [
			{
			"event": "corp-click-draw",
			"msg": func(state, side, eid, card, targets): return str("force the Corp to reveal that they drew ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRevealing.reveal(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
		},
		],
	}))

	NRCardDefs.defcard("Councilman", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever the Corp rezzes an asset or upgrade, you may pay credits equal to its rez cost and trash Councilman. If you do, derez that asset or upgrade. The Corp cannot rez it for the remainder of this turn.",
		"code": "10047",
		"title": "Councilman",
	}, {
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return ((NRCard.asset(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) or NRCard.upgrade(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) and NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, [
				NRPayment.to_c("credit", NRCostFns.rez_cost(state, "corp", NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))),
			])),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"waiting-prompt": true,
					"prompt": func(state, side, eid, card, targets): return str("Trash ") + str(NRCardXlate.getk(card, "title", null)) + str(" and pay ") + str(NRCostFns.rez_cost(state, "corp", NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) + str(" [Credits] to derez ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) + str("?"),
					"yes-ability": {
						"cost": [
							NRPayment.to_c("credit", NRCostFns.rez_cost(state, "corp", NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))),
							NRPayment.to_c("trash-self"),
						],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRRezzing.derez(state, "runner", ne, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), {
							"msg-keys": {
								"source-card": card,
								"and-then": " and prevent the Corp from rezzing it for the remainder of this turn.",
							},
						})
						, func(async_result):
							(func():
							NRFlags.register_turn_flag(state, side, card, "can-rez", func(state, _, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez the rest of this turn due to Councilman")) if NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) else true))
							return NREid.effect_completed(state, side, eid)
						).call()),
					},
				},
			}, card, targets),
		},
		],
	}))

	NRCardDefs.defcard("Counter Surveillance", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Clan",
		"subtypes": ["Clan"],
		"text": "<strong>[Click]</strong>, <strong>[Trash]:</strong> Run any server. If successful, instead of breaching the attacked server, pay X[Credits] if able, where X is equal to the number of tags you have. If you do, choose a number less than or equal to X. Access that many cards in and/or in the root of the attacked server. <em>(If you cannot pay, you will not access anything.)</em>",
		"code": "12023",
		"title": "Counter Surveillance",
	}, (func():
		var ability = NRCardXlate.successful_run_replace_breach({
			"mandatory": true,
			"duration": "end-of-run",
			"ability": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var tags = NRCardXlate.count_tags(state)
					return (NREngine.continue_ability(state, "runner", {
						"async": true,
						"cost": [NRPayment.to_c("credit", tags)],
						"msg": func(state, side, eid, card, targets): return str("access up to ") + str(NRUtil.quantify(tags, "card")) + str(" from ") + str(NRServers.zone_to_name(NRCardXlate.getk(state.getv("run"), "server", null))),
						"effect": func(state, side, eid, card, targets):
							return NREngine.continue_ability(state, "runner", {
							"async": true,
							"prompt": "How many cards do you want to access?",
							"waiting-prompt": true,
							"choices": {
								"number": func(state, side, eid, card, targets):
									return tags,
								"default": func(state, side, eid, card, targets):
									return tags,
							},
							"effect": func(state, side, eid, card, targets):
								return access_n_cards(state, side, eid, NRCardXlate.getk(state.getv("run"), "server", null), NRCardXlate.first_target(targets)),
						}, card, null),
					}, card, targets) if (tags <= total_available_credits(state, "runner", eid, card)) else (func():
						NRSay.system_msg(state, "runner", (str("could not afford to use ") + str(NRCardXlate.getk(card, "title", null))))
						return NREid.effect_completed(state, null, eid)
					).call())
				).call(),
			},
		})
		return {
			"abilities": [
				NRCardXlate.run_any_server_ability({
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"events": [ability],
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Crash Space", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "2[recurring-credit]\nYou can spend hosted credits to take the basic action to remove 1 tag.\n[interrupt] → [Trash]<strong>:</strong> Prevent up to 3 meat damage.",
		"code": "20034",
		"title": "Crash Space",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": NRUtil.merge(prevent_up_to_n_damage(3, ["meat"]) if prevent_up_to_n_damage(3, ["meat"]) is Dictionary else {}, {"cost": [NRPayment.to_c("trash-can")]}),
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("remove-tag" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("remove-tag", NRCardXlate.getk(eid, "source-type", null))) or (NRUtil.same_card(NRCardXlate.getk(eid, "source", null), NRCardXlate.getk(state.getv("runner", {}), "basic-action-card", null)) and ((5 == NRCardXlate.getk(NRCardXlate.getk(eid, "source-info", null), "ability-idx", null)) or NRUtil.kw_eq(5, NRCardXlate.getk(NRCardXlate.getk(eid, "source-info", null), "ability-idx", null))))),
				"type": "recurring",
			},
		},
		"recurring": 2,
	}))

	NRCardDefs.defcard("Crowdfunding", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Seedy - Virtual",
		"subtypes": ["Seedy", "Virtual"],
		"text": "When you install this resource, load 3[Credits] onto it. When it is empty, trash it and draw 1 card.\nWhen your turn begins, take 1[Credits] from this resource.\nWhen your turn ends, if you made at least 3 successful runs this turn and this card is in your heap, you may install it, ignoring all costs.",
		"code": "28002",
		"title": "Crowdfunding",
	}, (func():
		var ability = {
			"async": true,
			"once": "per-turn",
			"automatic": "gain-credits",
			"label": "Take 1 [Credits] (start of turn)",
			"msg": "gain 1 [Credits]",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (NRCard.get_counters(card, "credit") > 0)),
			"effect": func(state, side, eid, card, targets):
				return (func():
				return NREid.wait_for(state, eid, func(ne):
					NRCardXlate.take_credits(state, side, ne, card, "credit", 1)
				, func(async_result):
					(maybe_trash_myself(state, side, eid, card) if (not ((NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0))) else NREid.effect_completed(state, side, eid)))
			).call(),
		}
		return {
			"data": {
				"counter": {
					"credit": 3,
				},
			},
			"highlight-in-discard": true,
			"flags": {
				"drip-economy": true,
				"runner-turn-draw": func(state, side, eid, card, targets):
					return ((1 == NRCard.get_counters(NRCard.get_card(state, card), "credit")) or NRUtil.kw_eq(1, NRCard.get_counters(NRCard.get_card(state, card), "credit"))),
				"runner-phase-12": func(state, side, eid, card, targets):
					return ((1 == NRCard.get_counters(NRCard.get_card(state, card), "credit")) or NRUtil.kw_eq(1, NRCard.get_counters(NRCard.get_card(state, card), "credit"))),
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				{
				"event": "runner-turn-ends",
				"skippable": true,
				"async": true,
				"location": "discard",
				"req": func(state, side, eid, card, targets): return NRInstalling.runner_can_install(state, side, eid, card, null),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, {
					"optional": {
						"req": func(state, side, eid, card, targets): return ((3 <= NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)).size()) and (not (state.get_in(["runner", "register", "crowdfunding-prompt"], null)))),
						"prompt": "Install Crowdfunding from the Heap?",
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRInstalling.runner_install(state, "runner", eid, card, {
								"ignore-all-cost": true,
								"msg-keys": {
									"install-source": card,
									"display-origin": true,
								},
							}),
						},
						"no-ability": {
							"effect": func(state, side, eid, card, targets):
								return state.assoc_in(["runner", "register", "crowdfunding-prompt"], true),
						},
					},
				}, card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Crypt", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever you make a successful run on Archives, you may place 1 virus counter on Crypt.\n[Click], [Trash], <strong>3 hosted virus counters</strong>: Search your stack for a <strong>virus</strong> program and install it (paying its install cost), then shuffle your stack.",
		"code": "21043",
		"title": "Crypt",
	}, {
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"optional": {
				"prompt": func(state, side, eid, card, targets): return str("Place 1 virus counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"req": func(state, side, eid, card, targets): return (("archives" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("archives", NRServers.target_server(NRCardXlate.ctx(targets)))),
				"autoresolve": NROptional.get_autoresolve("auto-place-counter"),
				"yes-ability": {
					"msg": "place 1 virus counter on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "virus", 1),
				},
			},
		},
		],
		"abilities": [
			{
			"action": true,
			"async": true,
			"label": "Install a virus program from the stack",
			"prompt": "Choose a virus",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.has_subtype(_pct, "Virus"))),
			"cost": [
				NRPayment.to_c("click", 1),
				NRPayment.to_c("virus", 3),
				NRPayment.to_c("trash-can"),
			],
			"cancel": NRUtil.merge(fail_to_find_bang if fail_to_find_bang is Dictionary else {}, {"cost": [
				NRPayment.to_c("click", 1),
				NRPayment.to_c("virus", 3),
				NRPayment.to_c("trash-can"),
			]}),
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		},
			NROptional.set_autoresolve("auto-place-counter", "Crypt placing virus counters on itself"),
		],
	}))

	NRCardDefs.defcard("Cybertrooper Talut", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection - Virtual",
		"subtypes": ["Connection", "Virtual"],
		"text": "+1[link]\nWhenever you install a non-<strong>AI</strong> <strong>icebreaker</strong>, that <strong>icebreaker</strong> gets +2 strength for the remainder of the turn.",
		"code": "27003",
		"title": "Cybertrooper Talut",
	}, {
		"static-abilities": [link_(1)],
		"events": [
			{
			"event": "runner-install",
			"silent": true,
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Icebreaker") and (not (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "AI")))),
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), 2, "end-of-turn"),
		},
		],
	}))

	NRCardDefs.defcard("Dadiana Chacon", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, gain 1[Credits] if you have fewer than 6[Credits].\nWhenever you have 0[Credits], trash Dadiana Chacon and take 3 meat damage.",
		"code": "12049",
		"title": "Dadiana Chacon",
	}, (func():
		return {
			"on-install": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (NREngine.continue_ability(state, side, trash_effect(), card, null) if (state.get_in(["runner", "credit"], null) == 0) else NREid.effect_completed(state, side, eid)),
			},
			"flags": {
				"drip-economy": true,
			},
			"events": [
				NRUtil.merge(trash_effect() if trash_effect() is Dictionary else {}, {"event": "runner-credit-loss"}),
				NRUtil.merge(trash_effect() if trash_effect() is Dictionary else {}, {"event": "runner-spent-credits"}),
				{
				"event": "runner-turn-begins",
				"automatic": "gain-credits",
				"once": "per-turn",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, {
					"msg": "gain 1 [Credits]",
					"req": func(state, side, eid, card, targets): return (state.get_in(["runner", "credit"], null) < 6),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "runner", eid, 1),
				}, card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Daily Casts", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"text": "When you install this resource, load 8[Credits] onto it. When it is empty, trash it.\nWhen your turn begins, take 2[Credits] from this resource.",
		"code": "26094",
		"title": "Daily Casts",
	}, (func():
		var ability = {
			"once": "per-turn",
			"automatic": "gain-credits",
			"label": "Take 2 [Credits] (start of turn)",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (NRCard.get_counters(card, "credit") > 0)),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(mini(2, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.take_credits(state, side, eid, card, "credit", 2),
		}
		return {
			"data": {
				"counter": {
					"credit": 8,
				},
			},
			"flags": {
				"drip-economy": true,
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				trash_on_empty("credit"),
			],
		}
	).call()))

	NRCardDefs.defcard("Daeg, First Net-Cat", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Companion - Virtual",
		"subtypes": ["Companion", "Virtual"],
		"text": "Whenever an agenda is scored or stolen, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>",
		"code": "33028",
		"title": "Daeg, First Net-Cat",
	}, (func():
		var ability = {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRCharge.charge_ability(state, side), card, null),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Data Dealer", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "<strong>[Click]</strong>, <strong>forfeit 1 agenda:</strong> Gain 9[Credits].",
		"code": "25039",
		"title": "Data Dealer",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("forfeit")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-3")
				return NRGaining.gain_credits(state, side, eid, 9),
			"msg": "gain 9 [Credits]",
		},
		],
	}))

	NRCardDefs.defcard("Data Folding", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "When your turn begins, gain 1[Credits] if you have 2 or more unused MU.",
		"code": "07055",
		"title": "Data Folding",
	}, (func():
		var ability = {
			"label": "Gain 1 [Credits] (start of turn)",
			"automatic": "gain-credits",
			"msg": "gain 1 [Credits]",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return ((2 <= NRMemory.available_mu(state)) and NRCardXlate.getk(state, "runner-phase-12", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Data Leak Reversal", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual - Sabotage",
		"subtypes": ["Virtual", "Sabotage"],
		"text": "Install only if you made a successful run on a central server this turn.\nIf you are tagged, Data Leak Reversal gains \"[Click]: The Corp trashes the top card of R&D.\"",
		"code": "02103",
		"title": "Data Leak Reversal",
	}, {
		"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq", "rd", "archives"], _x)) != null),
		"abilities": [
			{
			"action": true,
			"async": true,
			"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
			},
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.mill(state, "corp", eid, "corp", 1),
			"msg": "force the Corp to trash the top card of R&D",
		},
		],
	}))

	NRCardDefs.defcard("DDoS", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Trash]: The Corp cannot rez the outermost piece of ice during a run on any server this turn.",
		"code": "08103",
		"title": "DDoS",
	}, {
		"abilities": [
			{
			"msg": "prevent the corp from rezzing the outermost piece of ice during a run on any server this turn",
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRFlags.register_turn_flag(state, side, card, "can-rez", func(state, _, card): return (func():
				var idx = card_index(state, card)
				return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez any outermost ice due to DDoS.", "warning")) if (NRCard.ice(card) and idx and ((NRUtil.as_array(state.get_in(((NRUtil.as_array(["corp", "servers"]) + NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "server", null))) + NRUtil.as_array(["ices"])), null)).size() == (idx + 1)) or NRUtil.kw_eq(NRUtil.as_array(state.get_in(((NRUtil.as_array(["corp", "servers"]) + NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "server", null))) + NRUtil.as_array(["ices"])), null)).size(), (idx + 1)))) else true)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Dean Lister", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Trash]: Choose an <strong>icebreaker</strong>. Until the end of the run, that <strong>icebreaker</strong> has +1 strength for each card in your grip.",
		"code": "13025",
		"title": "Dean Lister",
	}, {
		"abilities": [
			{
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker")) != null),
				"pay-cost": true,
			},
			"label": "pump icebreaker",
			"msg": func(state, side, eid, card, targets): return str("give +1 strength for each card in [their] Grip to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" until the end of the run"),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Icebreaker")),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NREffects.register_lingering_effect(state, side, card, (func():
					var breaker = NRCardXlate.first_target(targets)
					return {
						"type": "breaker-strength",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets): return NRUtil.same_card(breaker, NRCardXlate.first_target(targets)),
						"value": func(state, side, eid, card, targets):
							return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size(),
					}
				).call())
				return NRIce.update_breaker_strength(state, side, NRCardXlate.first_target(targets))
			).call() if state.getv("run") else null),
		},
		],
	}))

	NRCardDefs.defcard("Debbie \"Downtown\" Moreira", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Threat 4 → When you install this resource, place 2[Credits] on it. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nWhenever you play a <strong>run</strong> event, place 1[Credits] on this resource.\n[Click]<strong>:</strong> Run any server. You can spend hosted credits during that run.",
		"code": "34019",
		"title": "Debbie \"Downtown\" Moreira",
	}, {
		"on-install": {
			"req": func(state, side, eid, card, targets): return NRThreat.threat_level(4, state),
			"msg": "place 2 [Credits] on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 2),
		},
		"events": [
			{
			"event": "play-event",
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Run"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 1),
		},
		],
		"abilities": [
			{
			"msg": "take 1 [Credits]",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0),
			"effect": func(state, side, eid, card, targets):
				return spend_credits(state, side, eid, card, "credit", 1),
		},
			NRCardXlate.run_any_server_ability({
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
		}),
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (NRUtil.get_in(card, ["special", "run-id"], null) and ((NRUtil.get_in(card, ["special", "run-id"], null) == NRCardXlate.getk(state.getv("run"), "run-id", null)) or NRUtil.kw_eq(NRUtil.get_in(card, ["special", "run-id"], null), NRCardXlate.getk(state.getv("run"), "run-id", null)))),
				"type": "credit",
			},
		},
	}))

	NRCardDefs.defcard("Decoy", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent 1 tag.",
		"code": "01032",
		"title": "Decoy",
	}, {
		"prevention": [
			{
			"prevents": "tag",
			"type": "ability",
			"label": "Decoy",
			"prompt": "Trash Decoy to avoid 1 tag?",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"msg": "avoid 1 tag",
				"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
				"effect": func(state, side, eid, card, targets):
					return prevent_tag(state, "runner", eid, 1),
			},
		},
		],
	}))

	NRCardDefs.defcard("District 99", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Location - Seedy",
		"subtypes": ["Location", "Seedy"],
		"text": "The first time each turn a program or a piece of hardware is trashed (from any location), you may place 1 power counter on District 99.\n[Click], <strong>3 hosted power counters</strong>: Add a card that matches the faction of your identity from your heap to your grip.",
		"code": "22007",
		"title": "District 99",
	}, (func():
		return {
			"implementation": "Place counters manually for programs or pieces of hardware trashed manually (e.g. by being over MU)",
			"abilities": [
				{
				"action": true,
				"label": "Add a card from the heap to the grip",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(eligible_cards(state.getv("runner", {}))).is_empty()) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
				},
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 3)],
				"prompt": "Choose a card to add to grip",
				"choices": func(state, side, eid, card, targets):
					return eligible_cards(state.getv("runner", {})),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
				"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the heap to the grip"),
			},
				{
				"label": "Place 1 power counter",
				"once": "per-turn",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
				"msg": "manually place 1 power counter on itself",
			},
			],
			"events": (func():
				var prog_or_hw = func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return (NRCard.program(NRCardXlate.getk(_pct, "card", null)) or NRCard.hardware(NRCardXlate.getk(_pct, "card", null)))) != null)
				var trash_event = func(side_trash): return {
					"event": side_trash,
					"once-per-instance": true,
					"once": "per-turn",
					"req": func(state, side, eid, card, targets): return (prog_or_hw(targets) and NREvents.first_event(state, side, side_trash, prog_or_hw)),
					"msg": "place 1 power counter on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 1),
				}
				return [trash_event("corp-trash"), trash_event("runner-trash")]
			).call(),
		}
	).call()))

	NRCardDefs.defcard("DJ Fenris", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Host a <strong>g-mod</strong> identity that does not match the faction of your identity on DJ Fenris when he is installed. Remove hosted identity from the game if DJ Fenris is uninstalled.\nDJ Fenris gains the text of hosted identity.\nLimit 1 per deck.",
		"code": "22025",
		"title": "DJ Fenris",
	}, (func():
		var is_draft_id_p = func(_pct, _pct2=null, _pct3=null): return str_starts_with_p(NRCardXlate.getk(_pct, "code", null), "00")
		var sorted_id_list = func(runner, format): return NRUtil.as_array(NRUtil.as_array(server_cards()).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.identity(_pct) and NRCard.has_subtype(_pct, "G-mod") and (not (((NRCardXlate.getk(NRCardXlate.getk(state.getv("runner", {}), "identity", null), "faction", null) == NRCardXlate.getk(_pct, "faction", null)) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.getk(state.getv("runner", {}), "identity", null), "faction", null), NRCardXlate.getk(_pct, "faction", null))))) and (not (is_draft_id_p(_pct))) and (NRUtil.in_coll(["casual", "quick-draft", "preconstructed"], format) or legal_p(format, "legal", _pct)))))
		var fenris_effect = {
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose a g-mod identity to host",
			"choices": func(state, side, eid, card, targets):
				return sorted_id_list(state.getv("runner", {}), NRCardXlate.getk(state, "format", null)),
			"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var card = assoc_host_zones(card)
				var c = NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"type": "Fake-Identity"})
				var c = NRInitializing.make_card(c)
				var c = NRUtil.merge(c if c is Dictionary else {}, {"host": NRUtil.dissoc(card if card is Dictionary else {}, ["hosted"])})
				return (func():
					NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"hosted": [c]}))
					NRInitializing.card_init(state, "runner", c)
					return NREid.effect_completed(state, side, eid)
				).call()
			).call(),
		}
		return {
			"on-install": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, fenris_effect, card, null),
			},
			"disable": {
				"effect": func(state, side, eid, card, targets):
					return (func():
					for hosted in NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)):
						NRIdentities.disable_card(state, side, hosted)
					return null
				).call(),
			},
			"reactivate": {
				"effect": func(state, side, eid, card, targets):
					return (func():
					for hosted in NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)):
						NRIdentities.enable_card(state, side, hosted)
					return null
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Donut Taganes", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The play cost of operations and events is increased by 1.",
		"code": "05055",
		"title": "Donut Taganes",
	}, {
		"static-abilities": [{
			"type": "play-cost",
			"value": 1,
		}],
	}))

	NRCardDefs.defcard("Dr. Lovegood", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Adam",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, choose 1 of your installed cards. That card loses its printed abilities for the remainder of the turn.",
		"code": "09042",
		"title": "Dr. Lovegood",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"skippable": true,
			"label": "blank a card",
			"prompt": "Choose an installed card to make its text box blank for the remainder of the turn",
			"once": "per-turn",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"choices": {
				"card": NRCard.installed,
			},
			"msg": func(state, side, eid, card, targets): return str("make the text box of ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" blank for the remainder of the turn"),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var c = NRCardXlate.first_target(targets)
				return (func():
					NREffects.register_lingering_effect(state, side, card, {
						"type": "icon",
						"duration": "end-of-turn",
						"req": func(state, side, eid, card, targets): return NRUtil.same_card(c, NRCardXlate.first_target(targets)),
						"value": make_icon("DL", card),
					})
					NREffects.register_lingering_effect(state, side, card, {
						"type": "disable-card",
						"duration": "end-of-turn",
						"req": func(state, side, eid, card, targets): return NRUtil.same_card(c, NRCardXlate.first_target(targets)),
						"value": func(state, side, eid, card, targets):
							return true,
					})
					return update_disabled_cards(state)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Dr. Nuka Vrolyck", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you install this resource, load 2 power counters onto it. When it is empty, trash it.\n[Click], <strong>hosted power counter:</strong> Draw 3 cards.",
		"code": "33092",
		"title": "Dr. Nuka Vrolyck",
	}, {
		"data": {
			"counter": {
				"power": 2,
			},
		},
		"events": [trash_on_empty("power")],
		"abilities": [
			NRDefHelpers.draw_ability(3, null, {
			"action": true,
			"keep-menu-open": "while-clicks-left",
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
		}),
		],
	}))

	NRCardDefs.defcard("DreamNet", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The first time each turn you make a successful run, draw 1 card. If your identity is <strong>digital</strong> or you have at least 2[link], also gain 1[Credits].",
		"code": "26095",
		"title": "DreamNet",
	}, {
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"async": true,
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, "runner", "successful-run"),
			"msg": func(state, side, eid, card, targets): return str("draw 1 card") + str((" and gain 1 [Credit]" if ((2 <= NRLink.get_link(state)) or NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.getk(state, "runner", null), "identity", null), "Digital")) else null)),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "runner", ne, 1)
			, func(async_result):
				(NRGaining.gain_credits(state, "runner", eid, 1) if ((2 <= NRLink.get_link(state)) or NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.getk(state, "runner", null), "identity", null), "Digital")) else NREid.effect_completed(state, side, eid))),
		},
		],
	}))

	NRCardDefs.defcard("Drug Dealer", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, lose 1[Credits].\nWhen the Corp's turn begins, draw 1 card.",
		"code": "08083",
		"title": "Drug Dealer",
	}, {
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "drip-economy", true)) != null),
		},
		"abilities": [
			{
			"label": "Lose 1 [Credits] (start of turn)",
			"msg": func(state, side, eid, card, targets): return str(("lose 0 [Credits] (Runner has no credits to lose)" if (state.get_in(["runner", "credit"], null) == 0) else "lose 1 [Credits]")),
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, side, eid, 1),
		},
		],
		"events": [
			{
			"event": "corp-turn-begins",
			"automatic": "draw-cards",
			"msg": func(state, side, eid, card, targets): return str("draw ") + str(("no cards (the stack is empty)" if (NRUtil.as_array(state.get_in(["runner", "deck"], null)).size() == 0) else "1 card")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 1),
		},
			{
			"event": "runner-turn-begins",
			"automatic": "lose-credits",
			"msg": func(state, side, eid, card, targets): return str("lose ") + str(("0 [Credits] (Runner has no credits to lose)" if (state.get_in(["runner", "credit"], null) == 0) else "1 [Credits]")),
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Duggar's", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Location - Seedy",
		"subtypes": ["Location", "Seedy"],
		"text": "[Click],[Click],[Click],[Click]: Draw 10 cards.",
		"code": "06054",
		"title": "Duggar's",
	}, {
		"abilities": [
			NRDefHelpers.draw_ability(10, null, {
			"action": true,
			"cost": [NRPayment.to_c("click", 4)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"keep-menu-open": "while-4-clicks-left",
		}),
		],
	}))

	NRCardDefs.defcard("Dummy Box", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[interrupt] → <strong>Trash 1 card from your grip:</strong> Prevent the Corp from trashing 1 installed card of the same type.",
		"code": "12108",
		"title": "Dummy Box",
	}, (func():
		return {
			"prevention": [
				prevent_trash_installed_by_type("Dummy Box (Hardware)", ["Hardware"], [NRPayment.to_c("trash-hardware-from-hand", 1)], valid_context_p),
				prevent_trash_installed_by_type("Dummy Box (Program)", ["Program"], [NRPayment.to_c("trash-program-from-hand", 1)], valid_context_p),
				prevent_trash_installed_by_type("Dummy Box (Resource)", ["Resource"], [NRPayment.to_c("trash-resource-from-hand", 1)], valid_context_p),
			],
		}
	).call()))

	NRCardDefs.defcard("Earthrise Hotel", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 4,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "When you install this resource, load 3 power counters onto it. When it is empty, trash it.\nWhen your turn begins, remove 1 hosted power counter and draw 2 cards.",
		"code": "31039",
		"title": "Earthrise Hotel",
	}, (func():
		var ability = {
			"msg": "draw 2 cards",
			"automatic": "draw-cards",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "power", -1)
			, func(async_result):
				NRDrawing.draw(state, side, eid, 2)) if (NRCard.get_counters(card, "power") > 0) else NRDrawing.draw(state, side, eid, 2)),
		}
		return {
			"flags": {
				"runner-turn-draw": true,
				"runner-phase-12": func(state, side, eid, card, targets):
					return (1 < NRUtil.as_array(NRUtil.as_array(([state.get_in(["runner", "identity"], null)] + NRUtil.as_array(NRBoard.all_active_installed(state, "runner")))).filter(func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-turn-draw", true))).size()),
			},
			"data": {
				"counter": {
					"power": 3,
				},
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				trash_on_empty("power"),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Eden Shard", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 7,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Virtual - Source",
		"subtypes": ["Virtual", "Source"],
		"text": "Whenever you make a successful run on R&D, instead of breaching R&D, you may install this resource from your grip, ignoring all costs.\n<strong>[Trash]:</strong> The Corp draws 2 cards.\nLimit 1 per deck.",
		"code": "06020",
		"title": "Eden Shard",
	}, shard_constructor("Eden Shard", "rd", "force the Corp to draw 2 cards", func(state, side, eid, card, targets):
		return NRDrawing.draw(state, "corp", eid, 2))))

	NRCardDefs.defcard("Emptied Mind", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"text": "When your turn begins, gain [Click] if you have no cards in your grip.",
		"code": "10078",
		"title": "Emptied Mind",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() == 0),
			"automatic": "gain-clicks",
			"msg": "gain [Click]",
			"label": "Gain [Click] (start of turn)",
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Enhanced Vision", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Genetics",
		"subtypes": ["Genetics"],
		"text": "The first time you make a successful run each turn, the Corp reveals 1 card at random from HQ.",
		"code": "08005",
		"title": "Enhanced Vision",
	}, {
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var target = NRUtil.first_of(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null)))
				return (func():
					NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to force the Corp to reveal ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from HQ")))
					return NRRevealing.reveal(state, "corp", eid, NRCardXlate.first_target(targets))
				).call()
			).call(),
			"req": func(state, side, eid, card, targets): return genetics_trigger_p(state, side, "successful-run"),
		},
		],
	}))

	NRCardDefs.defcard("Environmental Testing", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you install a program or piece of hardware, place 1 power counter on this resource.\nWhen there are 4 or more hosted power counters, trash this resource and gain 9[Credits].",
		"code": "33029",
		"title": "Environmental Testing",
	}, (func():
		return {
			"events": [
				{
				"event": "runner-install",
				"silent": func(state, side, eid, card, targets):
					return (not (((3 == NRCard.get_counters(card, "power")) or NRUtil.kw_eq(3, NRCard.get_counters(card, "power"))))),
				"req": func(state, side, eid, card, targets): return ((NRCard.hardware(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) or NRCard.program(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "facedown?", null)))),
				"async": true,
				"msg": "place 1 power counter on itself",
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, "runner", eid, card, "power", 1),
			},
				{
				"event": "counter-added",
				"async": true,
				"req": func(state, side, eid, card, targets): return (4 <= NRCard.get_counters(NRCard.get_card(state, card), "power")),
				"msg": "trash itself and gain 9 [Credit]",
				"effect": func(state, side, eid, card, targets):
					return maybe_trash_myself(state, side, eid, card),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Eru Ayase-Pessoa", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection - Clone",
		"subtypes": ["Connection", "Clone"],
		"text": "Once per turn → [Click], <strong>take 1 tag:</strong> Run Archives. If successful, instead of breaching Archives, breach R&D.\nThreat 3 → Whenever you breach R&D during a run on Archives, access 1 additional card. <em>(This ability is active if any player has 3 or more agenda points.)</em>",
		"code": "34007",
		"title": "Eru Ayase-Pessoa",
	}, {
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"req": func(state, side, eid, card, targets): return (NRThreat.threat_level(3, state) and (("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (("archives" == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq("archives", NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))))),
			"msg": "access 1 additional card",
			"effect": func(state, side, eid, card, targets):
				return NRAccess.access_bonus(state, side, "rd", 1),
		},
		],
		"abilities": [
			NRCardXlate.run_server_ability("archives", {
			"cost": [NRPayment.to_c("gain-tag", 1), NRPayment.to_c("click", 1)],
			"once": "per-turn",
			"action": true,
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "archives",
				"mandatory": true,
				"duration": "end-of-run",
				"unregister-once-resolved": true,
				"ability": {
					"msg": "breach R&D",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRAccess.breach_server(state, "runner", eid, ["rd"], null),
				},
			}),
			],
		}),
		],
	}))

	NRCardDefs.defcard("Fall Guy", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent a player from trashing another installed resource.\n[Trash]<strong>:</strong> Gain 2[Credits].",
		"code": "20035",
		"title": "Fall Guy",
	}, (func():
		return {
			"prevention": [
				prevent_trash_installed_by_type("Fall Guy", ["Resource"], [NRPayment.to_c("trash-can")], valid_context_p),
			],
			"abilities": [
				{
				"label": "Gain 2 [Credits]",
				"msg": "gain 2 [Credits]",
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Fan Site", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever the Corp scores an agenda, add Fan Site to your score area as an agenda worth 0 agenda points.",
		"code": "08085",
		"title": "Fan Site",
	}, {
		"events": [
			{
			"event": "agenda-scored",
			"msg": "add itself to [their] score area as an agenda worth 0 agenda points",
			"req": func(state, side, eid, card, targets): return NRCard.installed(card),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.as_agenda(state, "runner", card, 0),
		},
		],
	}))

	NRCardDefs.defcard("Fencer Fueno", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Companion - Virtual",
		"subtypes": ["Companion", "Virtual"],
		"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nWhenever you make a successful run, you can spend hosted credits for the remainder of that run.\nWhen your turn ends, if there are 3 or more hosted credits, you must pay 1[Credits] or trash this resource.",
		"code": "26007",
		"title": "Fencer Fueno",
	}, companion_builder(func(state, side, eid, card, targets):
		return NRCardXlate.getk(state.getv("run"), "successful", null), {
		"prompt": "Choose one",
		"waiting-prompt": true,
		"choices": func(state, side, eid, card, targets):
			return [
			("Pay 1 [Credits]" if NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, NRPayment.to_c("credit", 1)) else null),
			"Trash Fencer Fueno",
		],
		"msg": func(state, side, eid, card, targets): return str(("trash itself" if ((NRCardXlate.first_target(targets) == "Trash Fencer Fueno") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Fencer Fueno")) else decapitalize(NRCardXlate.first_target(targets)))),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return (NRMoving.trash(state, "runner", eid, card, {
			"cause-card": card,
		}) if ((NRCardXlate.first_target(targets) == "Trash Fencer Fueno") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Fencer Fueno")) else NREngine.pay(state, "runner", eid, card, NRPayment.to_c("credit", 1))),
	}, {
		"req": func(state, side, eid, card, targets): return ((NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0) and NRCardXlate.getk(state.getv("run"), "successful", null)),
		"msg": "take 1 [Credits]",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return spend_credits(state, side, eid, card, "credit", 1),
	})))

	NRCardDefs.defcard("Fester", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever the Corp purges virus counters, if the Corp has at least 2[Credits], they lose 2[Credits].",
		"code": "06075",
		"title": "Fester",
	}, {
		"events": [
			{
			"event": "purge",
			"msg": "force the Corp to lose 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NRGaining.lose_credits(state, "corp", eid, 2) if (2 <= NRCardXlate.getk(state.getv("corp", {}), "credit", null)) else NREid.effect_completed(state, side, eid)),
		},
		],
	}))

	NRCardDefs.defcard("Film Critic", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Film Critic can host a single agenda.\nWhenever you access an agenda, you may host that agenda on Film Critic (the agenda is no longer being accessed and is uninstalled).\n[Click],[Click]: Add an agenda hosted on Film Critic to your score area.",
		"code": "08086",
		"title": "Film Critic",
	}, (func():
		var _b0 = host_agenda_p([agenda], {
			"optional": {
				"prompt": (str("Host ") + str(NRCardXlate.getk(agenda, "title", null)) + str(" on Film Critic?")),
				"yes-ability": {
					"effect": func(state, side, eid, card, targets):
						NRHosting.host(state, side, card, agenda)
						return null,
					"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(agenda, "title", null)) + str(" instead of accessing it"),
				},
			},
		})
		return {
			"events": [
				{
				"event": "access",
				"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.agenda) is Array and NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.agenda).is_empty() if false else (str(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.agenda)) == "")) and NRCard.agenda(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, host_agenda_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)), card, null),
			},
			],
			"abilities": [
				{
				"action": true,
				"cost": [NRPayment.to_c("click", 2)],
				"label": "Add hosted agenda to your score area",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return get_agenda(card),
				},
				"async": true,
				"msg": func(state, side, eid, card, targets): return str((func():
					var c = get_agenda(card)
					return (str("add ") + str(NRCardXlate.getk(c, "title", null)) + str(" to [their] score area and gain ") + str(NRUtil.quantify(get_agenda_points(c), "agenda point")))
				).call()),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var c = NRMoving.move(state, "runner", get_agenda(card), "scored")
					return (func():
						(NRInitializing.card_init(state, "corp", c, {
							"resolve-effect": false,
							"init-data": true,
						}) if NRFlags.card_flag(c, "has-events-when-stolen", true) else null)
						update_all_advancement_requirements(state)
						NRAgendas.update_all_agenda_points(state)
						check_win_by_agenda(state, side)
						return NREid.effect_completed(state, side, eid)
					).call()
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Find the Truth", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Adam",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Directive - Virtual",
		"subtypes": ["Directive", "Virtual"],
		"text": "Whenever you draw a card, reveal that card.\nThe first time each turn you make a successful run, you may look at the top card of R&D.",
		"code": "11047",
		"title": "Find the Truth",
	}, {
		"events": [
			{
			"event": "post-runner-draw",
			"msg": func(state, side, eid, card, targets): return str("reveal that they drew ") + str(NRUtil.enumerate_cards(runner_currently_drawing)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var current_draws = runner_currently_drawing
				return NRRevealing.reveal(state, side, eid, current_draws)
			).call(),
		},
			{
			"event": "successful-run",
			"interactive": NROptional.get_autoresolve("auto-peek", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-peek", never_p),
			"optional": {
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, side, "successful-run") and (NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(state, "corp", null), "deck", null)).size() > 0)),
				"autoresolve": NROptional.get_autoresolve("auto-peek"),
				"prompt": "Look at the top card of R&D?",
				"yes-ability": {
					"prompt": func(state, side, eid, card, targets):
						return (str("The top card of R&D is ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null))),
					"msg": "look at the top card of R&D",
					"choices": ["OK"],
				},
			},
		},
		],
		"abilities": [
			NROptional.set_autoresolve("auto-peek", "Find the Truth looking at the top card of R&D"),
		],
	}))


static func _register_3() -> void:
	NRCardDefs.defcard("First Responders", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "2[Credits]: Draw 1 card. Use this ability only if you have suffered damage from a Corp card ability this turn.",
		"code": "11048",
		"title": "First Responders",
	}, {
		"abilities": [
			NRDefHelpers.draw_ability(1, null, {
			"cost": [NRPayment.to_c("credit", 2)],
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, "runner", "damage")).map(func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))), NRCard.corp) != null),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Fransofia Ward", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The rez cost of each piece of ice is increased by 1[Credits].\nWhenever you encounter a piece of ice, if the Corp has 15[Credits] or more, you may trash this resource to bypass that ice. <em>(Pass that ice. No subroutines or further \"when encountered\" abilities resolve.)</em>",
		"code": "35021",
		"title": "Fransofia Ward",
	}, {
		"static-abilities": [
			{
			"type": "rez-cost",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.first_target(targets)),
			"value": 1,
		},
		],
		"events": [
			{
			"event": "encounter-ice",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (15 <= NRCardXlate.getk(state.getv("corp", {}), "credit", null)),
				"prompt": func(state, side, eid, card, targets): return str("Trash Fransofia Ward to bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)) + str("?"),
				"yes-ability": {
					"cost": [NRPayment.to_c("trash-self")],
					"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
					"effect": func(state, side, eid, card, targets):
						return NRCardXlate.bypass_ice(state),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Friend of a Friend", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click], [Trash]<strong>:</strong> Gain 5[Credits] and remove 1 tag.\n[Click], [Trash]<strong>:</strong> Gain 9[Credits] and take 1 tag. Use this ability only if you are not tagged.",
		"code": "34074",
		"title": "Friend of a Friend",
	}, {
		"abilities": [
			{
			"action": true,
			"label": "Gain 5 [Credits] and remove 1 tag",
			"msg": "gain 5 [Credits] and remove 1 tag",
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-3")
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, NREid.make_eid(state, eid), 5)
			, func(async_result):
				NRTags.lose_tags(state, "runner", eid, 1)),
		},
			{
			"action": true,
			"label": "Gain 9 [Credits] and take 1 tag",
			"msg": "gain 9 [Credits] and take 1 tag",
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"req": func(state, side, eid, card, targets): return (not (NRUtil.is_tagged(state))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-3")
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, NREid.make_eid(state, eid), 9)
			, func(async_result):
				NRTags.gain_tags(state, "runner", eid, 1)),
		},
		],
	}))

	NRCardDefs.defcard("Gang Sign", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever the Corp scores an agenda, breach HQ. You cannot access cards in the root of HQ during this breach.",
		"code": "08067",
		"title": "Gang Sign",
	}, {
		"events": [
			{
			"event": "agenda-scored",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "breach HQ",
			"effect": func(state, side, eid, card, targets):
				return NRAccess.breach_server(state, "runner", eid, ["hq"], {
				"no-root": true,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Gbahali", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Trash]: Break the last subroutine on the encountered piece of ice.",
		"code": "21047",
		"title": "Gbahali",
	}, bitey_boi("last")))

	NRCardDefs.defcard("Gene Conditioning Shoppe", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "<strong>Genetics</strong> also trigger the second time each turn their trigger condition is met.",
		"code": "08006",
		"title": "Gene Conditioning Shoppe",
	}, {
		"on-install": {
			"msg": "make Genetics trigger a second time each turn",
			"effect": func(state, side, eid, card, targets):
				return register_persistent_flag_bang(state, side, card, "genetics-trigger-twice", constantly(true)),
		},
		"leave-play": func(state, side, eid, card, targets):
			return clear_persistent_flag_bang(state, side, card, "genetics-trigger-twice"),
	}))

	NRCardDefs.defcard("Ghost Runner", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Stealth - Virtual",
		"subtypes": ["Stealth", "Virtual"],
		"text": "Place 3[Credits] on Ghost Runner when it is installed. When there are no credits left on Ghost Runner, trash it.\nYou can use the credits on Ghost Runner during a run.",
		"code": "06040",
		"title": "Ghost Runner",
	}, {
		"data": {
			"counter": {
				"credit": 3,
			},
		},
		"abilities": [
			{
			"msg": "gain 1 [Credits]",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (NRCard.get_counters(card, "credit") > 0)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return spend_credits(state, side, eid, card, "credit", 1),
		},
		],
		"events": [trash_on_empty("credit")],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
	}))

	NRCardDefs.defcard("Globalsec Security Clearance", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Install only if you have at least 2[link].\nWhen your turn begins, you may lose [Click]. If you do, look at the top card of R&D.",
		"code": "09051",
		"title": "Globalsec Security Clearance",
	}, (func():
		var ability = {
			"once": "per-turn",
			"label": "Lose [Click] and look at the top card of R&D (start of turn)",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"optional": {
				"prompt": "Lose [Click] to look at the top card of R&D?",
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": "lose [Click] and look at the top card of R&D",
					"prompt": func(state, side, eid, card, targets):
						return (str("The top card of R&D is ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null))),
					"choices": ["OK"],
					"effect": func(state, side, eid, card, targets):
						return NRGaining.lose_clicks(state, side, 1),
				},
			},
		}
		return {
			"req": func(state, side, eid, card, targets): return (1 < NRLink.get_link(state)),
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"abilities": [ability, NROptional.set_autoresolve("auto-fire", "Globalsec Security Clearance")],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Grifter", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "When your turn ends, gain 1[Credits] if you made a successful run this turn; otherwise, trash Grifter.",
		"code": "04046",
		"title": "Grifter",
	}, {
		"events": [
			{
			"event": "runner-turn-ends",
			"automatic": "gain-credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var ab = ({
					"msg": "gain 1 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, 1),
				} if NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null) else {
					"msg": "trash Grifter",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, card, {
						"cause": "runner-ability",
						"cause-card": card,
					}),
				})
				return NREngine.continue_ability(state, side, ab, card, targets)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Guru Davinder", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[interrupt] → Whenever you would take net or meat damage, prevent all of that damage.\nWhenever this resource prevents 1 or more damage, trash it unless you pay 4[Credits].",
		"code": "10084",
		"title": "Guru Davinder",
	}, {
		"static-abilities": [
			{
			"type": "cannot-pay-net",
			"value": true,
		},
			{
			"type": "cannot-pay-meat",
			"value": true,
		},
		],
		"prevention": [
			{
			"prevents": "damage",
			"type": "event",
			"max-uses": 1,
			"mandatory": true,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return (((("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) or (("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRPrevention.prevent_damage(state, side, ne, "all")
				, func(async_result):
					NREngine.continue_ability(state, side, {
					"msg": func(state, side, eid, card, targets): return str(("trash itself" if ((NRCardXlate.first_target(targets) == "Trash Guru Davinder") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Guru Davinder")) else decapitalize(NRCardXlate.first_target(targets)))),
					"prompt": "Choose one",
					"waiting-prompt": true,
					"choices": func(state, side, eid, card, targets):
						return [
						("Pay 4 [Credits]" if NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, NRPayment.to_c("credit", 4)) else null),
						"Trash Guru Davinder",
					],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (NRMoving.trash(state, "runner", eid, card, {
						"cause": "runner-ability",
						"cause-card": card,
					}) if ((NRCardXlate.first_target(targets) == "Trash Guru Davinder") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Guru Davinder")) else NREngine.pay(state, "runner", eid, card, NRPayment.to_c("credit", 4))),
				}, card, null)),
			},
		},
		],
	}))

	NRCardDefs.defcard("Hackerspace", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "You can install unique <em>(♦)</em> <strong>companion</strong> resources and unique <em>(♦)</em> <strong>connection</strong> resources onto this resource. Each resource installed this way costs 1[Credits] less to install.\nWhile this resource has a hosted <strong>companion</strong> and a hosted <strong>connection</strong>, you get +2 maximum hand size.",
		"code": "36006",
		"title": "Hackerspace",
	}, {
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return (NRCard.resource(NRCardXlate.first_target(targets)) and NRCard.has_any_subtype(NRCardXlate.first_target(targets), ["Connection", "Companion"]) and unique_p(NRCardXlate.first_target(targets))),
			"cost-bonus": -1,
		},
			runner_hand_size_(func(state, side, eid, card, targets):
			return (2 if ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)), func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Connection")) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)), func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Companion")) != null)) else 0)),
		],
	}))

	NRCardDefs.defcard("Hades Shard", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 7,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Virtual - Source",
		"subtypes": ["Virtual", "Source"],
		"text": "Whenever you make a successful run on Archives, instead of breaching Archives, you may install this resource from your grip, ignoring all costs.\n<strong>[Trash]:</strong> Breach Archives. You cannot access cards in the root of Archives during this breach.\nLimit 1 per deck.",
		"code": "06059",
		"title": "Hades Shard",
	}, shard_constructor("Hades Shard", "archives", "breach Archives", func(state, side, eid, card, targets):
		return NRAccess.breach_server(state, side, eid, ["archives"], {
		"no-root": true,
	}))))

	NRCardDefs.defcard("Hannah \"Wheels\" Pilintra", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Once per turn → [Click]<strong>:</strong> Gain [Click]. Run a remote server. When that run ends, if it was unsuccessful, take 1 tag.\n[Click], [Trash]<strong>:</strong> Gain [Click][Click]. Remove 1 tag.",
		"code": "34008",
		"title": "Hannah \"Wheels\" Pilintra",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"once": "per-turn",
			"label": "Run a remote server",
			"async": true,
			"prompt": "Choose a remote server",
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_remote)).is_empty()),
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_remote)).map(NRServers.remote_to_name),
			"msg": func(state, side, eid, card, targets): return str("gain [Click] and make a run on ") + str(NRCardXlate.first_target(targets)),
			"makes-run": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 1)
				NREngine.register_events(state, side, card, [
				{
				"event": "run-ends",
				"duration": "end-of-run",
				"unregister-once-resolved": true,
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "unsuccessful", null) and NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.ctx(targets), "source-card", null))),
				"async": true,
				"msg": "take 1 tag",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "runner", eid, 1),
			},
			])
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"async": true,
			"label": "Gain [Click][Click]. Remove 1 tag",
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 2)
				return NRTags.lose_tags(state, side, eid, 1),
			"msg": "gain [Click][Click] and remove 1 tag",
		},
		],
	}))

	NRCardDefs.defcard("Hard at Work", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When your turn begins, gain 2[Credits] and lose [Click].",
		"code": "04023",
		"title": "Hard at Work",
	}, (func():
		var ability = {
			"msg": "gain 2 [Credits] and lose [Click]",
			"automatic": "lose-clicks",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.lose_clicks(state, side, 1)
				return NRGaining.gain_credits(state, side, eid, 2),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Hernando Cortez", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "If the Corp has at least 10[Credits], as an additional cost to rez each piece of ice, the Corp must spend credits equal to the number of subroutines on that ice.",
		"code": "11004",
		"title": "Hernando Cortez",
	}, {
		"static-abilities": [
			{
			"type": "rez-additional-cost",
			"req": func(state, side, eid, card, targets): return ((10 <= NRCardXlate.getk(state.getv("corp", {}), "credit", null)) and NRCard.ice(NRCardXlate.first_target(targets))),
			"value": func(state, side, eid, card, targets):
				return [
				NRPayment.to_c("credit", NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "subroutines", null)).size()),
			],
		},
		],
	}))

	NRCardDefs.defcard("Human First", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever an agenda is scored or stolen, gain credits equal to the agenda points on that agenda.",
		"code": "07048",
		"title": "Human First",
	}, {
		"events": [
			{
			"event": "agenda-scored",
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(get_agenda_points(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, get_agenda_points(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))),
		},
			{
			"event": "agenda-stolen",
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(get_agenda_points(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, get_agenda_points(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))),
		},
		],
	}))

	NRCardDefs.defcard("Hunting Grounds", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Apex",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Location - Virtual",
		"subtypes": ["Location", "Virtual"],
		"text": "[interrupt], once per turn → <strong>0[Credits]:</strong> Prevent a \"when encountered\" ability on a piece of ice.\n[Trash]<strong>:</strong> Install the top 3 cards of your stack facedown.",
		"code": "09035",
		"title": "Hunting Grounds",
	}, {
		"prevention": [
			{
			"prevents": "encounter",
			"type": "event",
			"ability": {
				"async": true,
				"once": "per-turn",
				"req": func(state, side, eid, card, targets): return (NRPrevention.preventable(NRCardXlate.ctx(targets)) and NREngine.not_used_once(state, {
					"once": "per-turn",
				}, card)),
				"msg": func(state, side, eid, card, targets): return str("prevent the encounter ability on ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
				"effect": func(state, side, eid, card, targets):
					return prevent_encounter(state, side, eid),
			},
		},
		],
		"abilities": [
			(func():
			return {
				"async": true,
				"label": "Install the top 3 cards of the stack facedown",
				"msg": "install the top 3 cards of the stack facedown",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, ri(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(3))), card, null),
			}
		).call(),
		],
	}))

	NRCardDefs.defcard("Ice Analyzer", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever the Corp rezzes a piece of ice, place 1[Credits] on Ice Analyzer.\nYou may use credits on Ice Analyzer to install programs.",
		"code": "25057",
		"title": "Ice Analyzer",
	}, {
		"implementation": "Credit use restriction is not enforced",
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "credit", 1),
		},
		],
		"abilities": [
			{
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return spend_credits(state, side, eid, card, "credit", 1),
			"msg": "take 1 hosted [Credits] to install programs",
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and NRCard.program(NRCardXlate.first_target(targets))),
				"type": "credit",
			},
		},
	}))

	NRCardDefs.defcard("Ice Carver", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "While you are encountering a piece of ice, it gets −1 strength.",
		"code": "31009",
		"title": "Ice Carver",
	}, {
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRUtil.same_card(NRIce.get_current_ice(state), NRCardXlate.first_target(targets))),
			"value": -1,
		},
		],
	}))

	NRCardDefs.defcard("Info Bounty", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When your turn begins, identify your mark. <em>(If you donʼt have a mark, a random central server becomes your mark for this turn.)</em>\nThe first time each turn a run on your mark ends, gain 2[Credits] if you breached that server during that run.",
		"code": "33083",
		"title": "Info Bounty",
	}, {
		"events": [
			mark_changed_event,
			NRUtil.merge(NRMark.identify_mark_ability if NRMark.identify_mark_ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			{
			"event": "run-ends",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "marked-server", null) and NREvents.first_event(state, side, "run-ends", func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "marked-server", null)) and (func():
				var run_server = NRUtil.first_of(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))
				var evs = mapcat(rest, NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "events", null)).filter(func(_pct, _pct2=null, _pct3=null): return (("end-breach-server" == NRUtil.first_of(_pct)) or NRUtil.kw_eq("end-breach-server", NRUtil.first_of(_pct)))))
				return (NRUtil.find_first(NRUtil.as_array(evs), func(_pct, _pct2=null, _pct3=null): return ((run_server == NRCardXlate.getk(NRUtil.first_of(_pct), "from-server", null)) or NRUtil.kw_eq(run_server, NRCardXlate.getk(NRUtil.first_of(_pct), "from-server", null)))) != null)
			).call()),
			"msg": "gain 2 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("Inside Man", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "2[recurring-credit]\nUse these credits to install hardware.",
		"code": "02068",
		"title": "Inside Man",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and NRCard.hardware(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Investigative Journalism", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Install only if the Corp has at least 1 bad publicity.\n[Click][Click][Click][Click], [Trash]<strong>:</strong> Give the Corp 1 bad publicity.",
		"code": "07049",
		"title": "Investigative Journalism",
	}, {
		"req": func(state, side, eid, card, targets): return has_bad_pub_p(state),
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 4), NRPayment.to_c("trash-can")],
			"msg": "give the Corp 1 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.gain_bad_publicity(state, "corp", 1),
		},
		],
	}))

	NRCardDefs.defcard("Investigator Inez Delgado", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you win a game with Investigator Inez Delgado in your score area, reveal set 2.\n<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Expose all cards in a remote server. Use this only if you have stolean an agenda this turn.",
		"code": "14014",
		"title": "Investigator Inez Delgado",
	}, {
		"abilities": [
			{
			"msg": "add itself to [their] score area as an agenda worth 0 agenda points",
			"label": "Add to score area and reveal cards in server",
			"async": true,
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRBoard.get_remote_names(state),
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "stole-agenda", null),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var moved_card = NRMoving.as_agenda(state, "runner", card, 0)
				var zone = NRBoard.server_to_zone(state, NRCardXlate.first_target(targets))
				var path = (NRUtil.as_array((NRUtil.as_array([NRPayment.to_c("corp")]) + NRUtil.as_array(zone))) + ["content"])
				var cards = state.get_in(path, null)
				return (func():
					NREngine.register_events(state, side, moved_card, [
						{
						"event": "win",
						"req": func(state, side, eid, card, targets): return (("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "winner", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "winner", null))),
						"unregister-once-resolved": true,
						"msg": "reveal set 2",
					},
					])
					return NRExpose.expose(state, "runner", eid, state.get_in([
						"corp",
						"servers",
						NRServers.unknown_to_kw(NRCardXlate.first_target(targets)),
						"content",
					], null))
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Investigator Inez Delgado 2", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you win a game with Investigator Inez Delgado in your score area, reveal set 5.\n<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Reveal the top 3 cards in R&D. Use this only if you have stolean an agenda this turn.",
		"code": "14015",
		"title": "Investigator Inez Delgado 2",
	}, {
		"abilities": [
			{
			"msg": "add itself to [their] score area as an agenda worth 0 agenda points",
			"label": "Add to score area and reveal the top 3 cards of R&D",
			"async": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "stole-agenda", null),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var moved_card = NRMoving.as_agenda(state, "runner", card, 0)
				return (func():
					NREngine.register_events(state, side, moved_card, [
						{
						"event": "win",
						"req": func(state, side, eid, card, targets): return (("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "winner", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "winner", null))),
						"unregister-once-resolved": true,
						"msg": "reveal set 5",
					},
					])
					return (NRRevealing.reveal(state, side, eid, card, null, NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))) if (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()) else NREid.effect_completed(state, side, eid))
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Investigator Inez Delgado 3", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you win a game with Investigator Inez Delgado in your score area, reveal set 8.\n<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Reveal each card in HQ. Use this only if you have stolean an agenda this turn.",
		"code": "14016",
		"title": "Investigator Inez Delgado 3",
	}, {
		"abilities": [
			{
			"msg": "add itself to [their] score area as an agenda worth 0 agenda points",
			"label": "Add to score area and reveal the top 3 cards of R&D",
			"async": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "stole-agenda", null),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var moved_card = NRMoving.as_agenda(state, "runner", card, 0)
				return (func():
					NREngine.register_events(state, side, moved_card, [
						{
						"event": "win",
						"req": func(state, side, eid, card, targets): return (("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "winner", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "winner", null))),
						"unregister-once-resolved": true,
						"msg": "reveal set 8",
					},
					])
					return (NRRevealing.reveal(state, side, eid, card, null, NRCardXlate.getk(state.getv("corp", {}), "hand", null)) if (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()) else NREid.effect_completed(state, side, eid))
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Investigator Inez Delgado 4", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Reveal each card in HQ and the top card of R&D. Use this only if you have stolean an agenda this turn.",
		"code": "14017",
		"title": "Investigator Inez Delgado 4",
	}, {
		"abilities": [
			{
			"msg": "add itself to [their] score area as an agenda worth 0 agenda points",
			"label": "Add to score area and reveal the top 3 cards of R&D",
			"async": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "stole-agenda", null),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var moved_card = NRMoving.as_agenda(state, "runner", card, 0)
				return (NRRevealing.reveal(state, side, eid, card, null, (NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)) + NRUtil.as_array([NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null))]))) if (not NRUtil.as_array((NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)) + NRUtil.as_array([NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null))]))).is_empty()) else NREid.effect_completed(state, side, eid))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Jackpot!", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "When your turn begins, you may place 1[Credits] on Jackpot!.\nWhenever an agenda is added to your score area, you may take any number of credits from Jackpot!. If you do, trash Jackpot!.",
		"code": "21090",
		"title": "Jackpot!",
	}, {
		"implementation": "Credit gain must be manually triggered",
		"events": [
			{
			"event": "runner-turn-begins",
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "credit", 1),
		},
			{
			"event": "card-moved",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCard.in_scored(NRCardXlate.getk(NRCardXlate.ctx(targets), "moved-card", null)) and (("runner" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "moved-card", null), "scored-side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "moved-card", null), "scored-side", null)))),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets): return str("Trash ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"yes-ability": {
					"prompt": "How many hosted credits do you want to take?",
					"choices": {
						"number": func(state, side, eid, card, targets):
							return NRCard.get_counters(card, "credit"),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRCardXlate.take_credits(state, side, ne, card, "credit", NRCardXlate.first_target(targets))
					, func(async_result):
						(func():
						NRSay.system_msg(state, "runner", (str("trashes ") + str(NRCardXlate.getk(card, "title", null)) + str(" to gain ") + str(NRCardXlate.first_target(targets)) + str(" [Credits]")))
						return NRMoving.trash(state, "runner", eid, card, {
							"cause-card": card,
						})
					).call()),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Jak Sinclair", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Reduce the cost to install Jak Sinclair by 1 for each [link] you have.\nWhen your turn begins, you may make a run. You cannot use programs during this run.",
		"code": "09052",
		"title": "Jak Sinclair",
	}, (func():
		var ability = {
			"label": "Make a run (start of turn)",
			"prompt": "Choose a server",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str(" during which no programs can be used"),
			"makes-run": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		}
		return {
			"implementation": "Doesn't prevent program use",
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"install-cost-bonus": func(state, side, eid, card, targets):
				return (-NRLink.get_link(state)),
			"events": [
				{
				"event": "runner-turn-begins",
				"skippable": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"once": "per-turn",
					"prompt": "Make a run?",
					"yes-ability": ability,
				},
			},
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Jarogniew Mercs", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Clan - Connection",
		"subtypes": ["Clan", "Connection"],
		"text": "When you install this resource, take 1 tag. Load X power counters onto this resource, where X is equal to the number of tags you have plus 3. When this resource is empty, trash it.\nThe Corp cannot trash this resource while there is another resource installed.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent 1 meat damage.",
		"code": "12062",
		"title": "Jarogniew Mercs",
	}, {
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRTags.gain_tags(state, "runner", ne, 1)
			, func(async_result):
				NRProps.add_counter(state, "runner", eid, card, "power", (3 + NRCardXlate.count_tags(state)), null)),
		},
		"events": [trash_on_empty("power")],
		"flags": {
			"untrashable-while-resources": true,
		},
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("power", 1)],
				"msg": "prevent 1 meat damage",
				"req": func(state, side, eid, card, targets): return ((("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
		],
	}))

	NRCardDefs.defcard("John Masanori", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The first time you make a successful run each turn, draw 1 card.\nThe first time you make an unsuccessful run each turn, take 1 tag.",
		"code": "25064",
		"title": "John Masanori",
	}, {
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "successful-run"),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "draw 1 card",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		},
			{
			"event": "unsuccessful-run",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "unsuccessful-run"),
			"async": true,
			"msg": "take 1 tag",
			"effect": func(state, side, eid, card, targets):
				return NRTags.gain_tags(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Joshua B.", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, you may gain [Click]. If you do, take 1 tag when this turn ends.",
		"code": "02042",
		"title": "Joshua B.",
	}, (func():
		var ability = {
			"msg": "gain [Click]",
			"once": "per-turn",
			"label": "Gain [Click] (start of turn)",
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 1)
				return NREngine.register_events(state, side, card, [
				NRUtil.merge(NRTags.gain_tags_ability(1) if NRTags.gain_tags_ability(1) is Dictionary else {}, {
				"event": "runner-turn-ends",
				"unregister-once-resolved": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
			} if {
				"event": "runner-turn-ends",
				"unregister-once-resolved": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
			} is Dictionary else {}),
			]),
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
				"optional": {
					"prompt": "Gain [Click]?",
					"once": "per-turn",
					"yes-ability": ability,
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to gain [Click]")))
							return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "joshua-b"], false)),
					},
				},
			},
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Juli Moreira Lee", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you install this resource, load 4 power counters onto it. When it is empty, trash it.\nThe first time each turn you take an action on an installed resource, remove 1 hosted power counter and gain [Click].",
		"code": "34084",
		"title": "Juli Moreira Lee",
	}, {
		"data": {
			"counter": {
				"power": 4,
			},
		},
		"events": [
			trash_on_empty("power"),
			{
			"event": "action-played",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return (func():
				var valid_ctx_p = func(_p): return NRCard.resource(NRCardXlate.getk(ctx, "card", null))
				return (valid_ctx_p(targets) and (("runner" == side) or NRUtil.kw_eq("runner", side)) and NREvents.first_event(state, side, "action-played", valid_ctx_p))
			).call(),
			"msg": "gain [Click]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRGaining.gain_clicks(state, side, 1)
				return NRProps.add_counter(state, side, eid, card, "power", -1)
			).call() if (NRCard.get_counters(card, "power") > 0) else (func():
				NRGaining.gain_clicks(state, side, 1)
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Kasi String", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The first time each turn a successful run on a remote server ends, if you breached the server but stole no agendas, you may place 1 power counter on this resource.\nWhen this resource has 4 or more hosted power counters, add it to your score area as an agenda worth 1 agenda point.",
		"code": "21111",
		"title": "Kasi String",
	}, {
		"special": {
			"auto-place-counter": "always",
		},
		"events": [
			{
			"event": "run-ends",
			"optional": {
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, "runner", "run-ends", func(_pct, _pct2=null, _pct3=null): return NRServers.is_remote(NRCardXlate.getk(NRUtil.first_of(_pct), "server", null))) and (not (NRCardXlate.getk(NRCardXlate.first_target(targets), "did-steal", null))) and NRCardXlate.getk(NRCardXlate.first_target(targets), "did-access", null) and NRServers.is_remote(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null))),
				"autoresolve": NROptional.get_autoresolve("auto-place-counter"),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets): return str("Place 1 power counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"yes-ability": {
					"msg": "place 1 power counter on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 1, {
						"placed": true,
					}),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
			{
			"event": "counter-added",
			"req": func(state, side, eid, card, targets): return (4 <= NRCard.get_counters(NRCard.get_card(state, card), "power")),
			"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.as_agenda(state, "runner", card, 1),
		},
		],
		"abilities": [
			NROptional.set_autoresolve("auto-place-counter", "Kasi String placing power counters on itself"),
		],
	}))

	NRCardDefs.defcard("Kati Jones", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "You cannot use this resource more than once per turn.\n[Click]<strong>:</strong> Place 3[Credits] on this resource.\n[Click]<strong>:</strong> Take all credits from this resource.",
		"code": "25065",
		"title": "Kati Jones",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"msg": "store 3 [Credits]",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 3),
		},
			take_all_credits_ability({
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"once": "per-turn",
		}),
		],
	}))

	NRCardDefs.defcard("Keros Mcintyre", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The first time you derez a piece of ice each turn, gain 2[Credits].",
		"code": "12065",
		"title": "Keros Mcintyre",
	}, {
		"events": [
			{
			"event": "derez",
			"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, side, "derez", func(_pct, _pct2=null, _pct3=null): return (("runner" == NRCardXlate.getk(NRUtil.first_of(_pct), "side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRUtil.first_of(_pct), "side", null)))) and ((NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null) == "runner") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null), "runner"))),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("\"Knickknack\" O'Brian", NRCardXlate.merge_cdef({
		"title": "\"Knickknack\" O'Brian",
	}, {
		"events": [
			{
			"async": true,
			"once": "per-turn",
			"event": "run",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRBoard.all_installed(state, "runner")).size() >= 2) and NREvents.first_event(state, side, "run")),
			"waiting-prompt": true,
			"skippable": true,
			"choices": {
				"not-self": true,
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets))),
			},
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to gain ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null)) + str(" [Credits] and draw a card"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
				"unpreventable": true,
				"cause-card": card,
			})
			, func(async_result):
				NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null))
			, func(async_result):
				NRDrawing.draw(state, side, eid, 1))),
		},
		],
	}))

	NRCardDefs.defcard("Kongamato", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Trash]: Break the first subroutine on the encountered piece of ice.",
		"code": "21027",
		"title": "Kongamato",
	}, bitey_boi("first")))

	NRCardDefs.defcard("Lago Paranoá Shelter", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection - Location",
		"subtypes": ["Connection", "Location"],
		"text": "The first time each turn the Corp installs a card in the root of a server, you may trash the top card of your stack to draw 1 card.",
		"code": "34009",
		"title": "Lago Paranoá Shelter",
	}, {
		"events": [
			{
			"event": "corp-install",
			"optional": {
				"prompt": "Trash the top card of the stack?",
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"req": func(state, side, eid, card, targets): return ((not (NRCard.ice(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)))) and (not (NRCard.condition_counter(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)))) and NREvents.first_event(state, side, "corp-install", func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.ice(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))) and (not (NRCard.condition_counter(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))))))),
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str(((str("trash ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)) + str(" from the stack and draw 1 card")) if (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) else "trash no cards from the stack (it is empty)")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRMoving.mill(state, "runner", ne, "runner", 1)
					, func(async_result):
						NRDrawing.draw(state, "runner", eid, 1)),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Lago Paranoá Shelter")],
	}))

	NRCardDefs.defcard("Laguna Velasco District", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "Whenever you take the basic action to draw cards, increase the number of cards you draw by 1.",
		"code": "13022",
		"title": "Laguna Velasco District",
	}, {
		"events": [
			{
			"event": "runner-click-draw",
			"msg": "draw 1 additional card",
			"effect": func(state, side, eid, card, targets):
				return click_draw_bonus(state, side, 1),
		},
		],
	}))

	NRCardDefs.defcard("Levy Advanced Research Lab", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "[Click]: Reveal the top 4 cards of your stack. If any of those cards are programs, you may add 1 to your grip. Add the rest of the cards to the bottom of your stack in any order.",
		"code": "13021",
		"title": "Levy Advanced Research Lab",
	}, (func():
		return {
			"abilities": [
				{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"keep-menu-open": "while-clicks-left",
				"label": "Reveal the top 4 cards of the stack",
				"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRUtil.enumerate_cards(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(4)))) + str(" from the top of the stack"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var from = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(4))
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, from)
					, func(async_result):
						NREngine.continue_ability(state, side, lab_keep(from), card, null))
				).call(),
			},
			],
		}
	).call()))


static func _register_4() -> void:
	NRCardDefs.defcard("Lewi Guilherme", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, either lose 1[Credits] or trash Lewi Guilherme.\nThe Corp's maximum hand size is reduced by 1.",
		"code": "21005",
		"title": "Lewi Guilherme",
	}, (func():
		var ability = {
			"label": "lose 1 [Credits] or trash",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
				("Pay 1 [Credits]" if NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, NRPayment.to_c("credit", 1)) else null),
				"Trash Lewi Guilherme",
			],
			"msg": func(state, side, eid, card, targets): return str(("trash itself" if ((NRCardXlate.first_target(targets) == "Trash Lewi Guilherme") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Lewi Guilherme")) else decapitalize(NRCardXlate.first_target(targets)))),
			"effect": func(state, side, eid, card, targets):
				return (NRMoving.trash(state, "runner", eid, card, {
				"cause-card": card,
			}) if ((NRCardXlate.first_target(targets) == "Trash Lewi Guilherme") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Lewi Guilherme")) else NREngine.pay(state, "runner", eid, card, NRPayment.to_c("credit", 1))),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"static-abilities": [corp_hand_size_(-1)],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Liberated Account", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 6,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When you install this resource, load 16[Credits] onto it. When it is empty, trash it.\n[Click]<strong>:</strong> Take 4[Credits] from this resource.",
		"code": "31010",
		"title": "Liberated Account",
	}, {
		"data": {
			"counter": {
				"credit": 16,
			},
		},
		"abilities": [
			NRCardXlate.take_n_credits_ability(4, "resource", {
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"label": "take 4 [Credits]",
		}),
		],
		"events": [trash_on_empty("credit")],
	}))

	NRCardDefs.defcard("Liberated Chela", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click][Click][Click][Click][Click], <strong>forfeit an agenda:</strong> The Corp may forfeit an agenda to remove this resource from the game. If they do not, add this resource to your score area as an agenda worth 2 agenda points.",
		"code": "10081",
		"title": "Liberated Chela",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 5), NRPayment.to_c("forfeit")],
			"msg": "add itself to [their] score area",
			"label": "Add liberated Chela to your score area",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, ({
				"optional": {
					"waiting-prompt": true,
					"prompt": func(state, side, eid, card, targets): return str("Forfeit an agenda to prevent ") + str(NRCardXlate.getk(card, "title", null)) + str(" from being added to Runner's score area?"),
					"player": "corp",
					"async": true,
					"yes-ability": {
						"player": "corp",
						"prompt": "Choose an agenda to forfeit",
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return NRFlags.in_corp_scored(state, side, _pct),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRMoving.forfeit(state, side, ne, NREid.make_eid(state, eid), NRCardXlate.first_target(targets))
						, func(async_result):
							(func():
							NRMoving.move(state, "runner", card, "rfg")
							return NREid.effect_completed(state, side, eid)
						).call()),
					},
					"no-ability": {
						"msg": "add itself to [their] score area as an agenda worth 2 points",
						"effect": func(state, side, eid, card, targets):
							return NRMoving.as_agenda(state, "runner", card, 2),
					},
				},
			} if (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "scored", null)).is_empty()) else {
				"msg": "add itself to [their] score area as an agenda worth 2 points",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, "runner", card, 2),
			}), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Light the Fire!", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Sabotage",
		"subtypes": ["Sabotage"],
		"text": "[Click], [Trash], <strong>suffer 1 core damage:</strong> Run a remote server. During that run, cards in the root of the attacked server lose all abilities. When that run is successful, trash all cards in the root of the attacked server.",
		"code": "33009",
		"title": "Light the Fire!",
	}, (func():
		var successful_run_event = {
			"event": "successful-run",
			"duration": "end-of-run",
			"async": true,
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NRServers.is_remote(NRCardXlate.getk(state.getv("run"), "server", null))),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(state, side, eid, NRCardXlate.getk(run_server, "content", null)),
			"msg": "trash all cards in the server for no cost",
		}
		var disable_card_effect = {
			"type": "disable-card",
			"duration": "end-of-run",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "zone", null)), func(_x): return NRUtil.in_coll(["content"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "zone", null)), func(_x): return NRUtil.in_coll([
				NRUtil.first_of(NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "server", null)),
			], _x)) != null)),
			"value": true,
		}
		return {
			"abilities": [
				{
				"action": true,
				"label": "Run a remote server",
				"cost": [
					NRPayment.to_c("click", 1),
					NRPayment.to_c("trash-can"),
					NRPayment.to_c("brain", 1),
				],
				"prompt": "Choose a remote server",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRBoard.get_remote_names(state)).filter(func(_pct, _pct2=null, _pct3=null): return NRRuns.can_run_server(state, _pct)),
				"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str(" during which cards in the root of the attacked server lose all abilities"),
				"makes-run": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NREngine.register_events(state, side, card, [successful_run_event])
					NREffects.register_lingering_effect(state, side, card, disable_card_effect)
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Logic Bomb", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Adam",
		"cost": 0,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Trash]: Bypass a piece of ice you are currently encountering. Lose any remaining clicks.",
		"code": "21089",
		"title": "Logic Bomb",
	}, {
		"abilities": [
			{
			"label": "Bypass the encountered ice",
			"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state))),
			"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str(((str(" and loses ") + str(str.callv(NRUtil.as_array(repeat(NRCardXlate.getk(state.getv("runner", {}), "click", null), "[Click]"))))) if (NRCardXlate.getk(state.getv("runner", {}), "click", null) > 0) else null)),
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				NRCardXlate.bypass_ice(state)
				return NRGaining.lose_clicks(state, "runner", NRCardXlate.getk(state.getv("runner", {}), "click", null)),
		},
		],
	}))

	NRCardDefs.defcard("London Library", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "Trash all programs hosted on London Library when your turn ends.\n[Click]: Install a non-<strong>virus</strong> program from your grip on London Library, ignoring the install cost.\n[Click]: Add a program on London Library to your grip.",
		"code": "08029",
		"title": "London Library",
	}, {
		"abilities": [
			{
			"action": true,
			"async": true,
			"label": "Install and host a non-virus program",
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"prompt": "Choose a non-virus program in the grip",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "Virus"))) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets))),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
				"host-card": card,
				"ignore-install-cost": true,
				"msg-keys": {
					"install-source": card,
					"include-cost-from-eid": eid,
					"display-origin": true,
				},
			}),
		},
			{
			"action": true,
			"label": "Add a hosted program to the grip",
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null)).is_empty()),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null)),
			},
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to [their] Grip"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
		},
		],
		"events": [
			{
			"event": "runner-turn-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(state, side, eid, NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.program), {
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Manuel Lattes de Moura", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever you breach HQ or R&D while you are tagged, access 1 additional card.\nThreat 3 → As an additional cost to trash this resource with the basic action, the Corp must trash 1 card from HQ. <em>(This ability is active if any player has 3 or more agenda points.)</em>",
		"code": "34075",
		"title": "Manuel Lattes de Moura",
	}, {
		"static-abilities": [
			{
			"type": "basic-ability-additional-trash-cost",
			"req": func(state, side, eid, card, targets): return (NRUtil.same_card(card, NRCardXlate.first_target(targets)) and (("corp" == side) or NRUtil.kw_eq("corp", side)) and NRThreat.threat_level(3, state)),
			"value": [NRPayment.to_c("trash-from-hand", 1)],
		},
		],
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"req": func(state, side, eid, card, targets): return (NRUtil.is_tagged(state) and NRUtil.in_coll(["hq", "rd"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
			"msg": func(state, side, eid, card, targets): return str("access 1 additional card from ") + str(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
			"effect": func(state, side, eid, card, targets):
				return NRAccess.access_bonus(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null), 1),
		},
		],
	}))

	NRCardDefs.defcard("\"Pretty\" Mary da Silva", NRCardXlate.merge_cdef({
		"title": "\"Pretty\" Mary da Silva",
	}, {
		"implementation": "only works after other abilities increasing the number of accesses have resolved",
		"events": [
			{
			"event": "breach-server",
			"automatic": "last",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (not (get_only_card_to_access(state)))),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var num_access = NRCardXlate.getk(num_cards_to_access(state, side, "rd", null), "random-access-limit", null)
				return NREngine.continue_ability(state, side, ({
					"optional": {
						"prompt": "Access 1 additional card?",
						"yes-ability": {
							"msg": "access 1 additional card",
							"effect": func(state, side, eid, card, targets):
								return NRAccess.access_bonus(state, side, "rd", 1),
						},
					},
				} if (num_access and (num_access >= 2)) else null), card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Maxwell James", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "+1[link]\n[Trash]: Derez a piece of ice protecting a remote server. Use this ability only during the next paid ability window after a successful run on HQ ends.",
		"code": "13011",
		"title": "Maxwell James",
	}, {
		"static-abilities": [link_(1)],
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null),
			"prompt": "Choose a piece of ice protecting a remote server",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null))),
			},
			"label": "Derez a piece of ice protecting a remote server",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets), {
				"msg-keys": {
					"include-cost-from-eid": eid,
				},
			}),
		},
		],
	}))

	NRCardDefs.defcard("Miss Bones", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Place 12[Credits] from the bank on Miss Bones when she is installed. When there are no credits left on Miss Bones, trash her.\nUse these credits to trash installed cards.",
		"code": "22014",
		"title": "Miss Bones",
	}, {
		"data": {
			"counter": {
				"credit": 12,
			},
		},
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-trash-corp-cards" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-trash-corp-cards", NRCardXlate.getk(eid, "source-type", null))) and NRCard.installed(NRCardXlate.first_target(targets))),
				"type": "credit",
			},
		},
		"abilities": [
			{
			"prompt": "How many hosted credits do you want to take?",
			"label": "Take hosted credits",
			"choices": {
				"number": func(state, side, eid, card, targets):
					return NRCard.get_counters(card, "credit"),
			},
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRCardXlate.first_target(targets)) + str(" [Credits] for trashing installed cards"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return spend_credits(state, side, eid, card, "credit", NRCardXlate.first_target(targets)),
		},
		],
		"events": [trash_on_empty("credit")],
	}))

	NRCardDefs.defcard("Motivation", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "When your turn begins, you may look at the top card of your stack.",
		"code": "04008",
		"title": "Motivation",
	}, (func():
		var ability = {
			"label": "Look at the top card of the stack (start of turn)",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"once": "per-turn",
			"optional": {
				"waiting-prompt": true,
				"prompt": "Look at the top card of the stack?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"prompt": func(state, side, eid, card, targets):
						return (str("The top card of the stack is ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null))),
					"msg": "look at the top card of the stack",
					"choices": ["OK"],
				},
			},
		}
		return {
			"special": {
				"auto-fire": "always",
			},
			"flags": {
				"runner-turn-draw": true,
				"runner-phase-12": func(state, side, eid, card, targets):
					return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-turn-draw", true)) != null),
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability, NROptional.set_autoresolve("auto-fire", "Motivation")],
		}
	).call()))

	NRCardDefs.defcard("Mr. Li", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "<strong>[Click]:</strong> Draw 2 cards. When you do, add 1 of those cards to the bottom of your stack.",
		"code": "20036",
		"title": "Mr. Li",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"msg": "draw 2 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.register_events(state, side, card, [
				{
				"event": "runner-draw",
				"unregister-once-resolved": true,
				"duration": "end-of-turn",
				"waiting-prompt": true,
				"prompt": "Choose 1 card to add to the bottom of the Stack",
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(runner_currently_drawing), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.first_target(targets), _pct)) != null),
				},
				"msg": "add 1 card to the bottom of the Stack",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, side, NRCardXlate.first_target(targets), "deck"),
			},
			])
				NRSay.play_sfx(state, side, "click-card-2")
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, side, ne, 2)
			, func(async_result):
				(func():
				NREngine.unregister_events(state, side, card)
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Muertos Gang Member", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you install Muertos Gang Member, the Corp must derez a card.\nWhen Muertos Gang Member is uninstalled, the Corp may rez a card, ignoring the rez cost.\n[Trash]: Draw 1 card.",
		"code": "08068",
		"title": "Muertos Gang Member",
	}, {
		"on-install": {
			"player": "corp",
			"waiting-prompt": true,
			"prompt": "Choose a card to derez",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return (NRCard.rezzed(_pct) and (not (NRCard.agenda(_pct))))) != null),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and (not (NRCard.agenda(_pct))) and NRCard.rezzed(_pct)),
				"all": true,
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, "corp", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets)),
		},
		"uninstall": func(state, side, eid, card, targets):
			return NREngine.continue_ability(state, side, {
			"player": "corp",
			"waiting-prompt": true,
			"prompt": "Choose a card to rez, ignoring the rez cost",
			"choices": {
				"card": func(_x): return not NRCard.rezzed.call(_x),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.rez(state, side, eid, NRCardXlate.first_target(targets), {
				"ignore-cost": "rez-cost",
				"no-msg": true,
			}),
		}, card, null),
		"abilities": [
			NRDefHelpers.draw_ability(1, null, {
			"cost": [NRPayment.to_c("trash-can")],
		}),
		],
	}))

	NRCardDefs.defcard("Mystic Maemi", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Companion - Virtual",
		"subtypes": ["Companion", "Virtual"],
		"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nYou can spend hosted credits to play events.\nWhen your turn ends, if there are 3 or more hosted credits, you must trash 1 card from your grip at random or trash this resource.",
		"code": "27001",
		"title": "Mystic Maemi",
	}, companion_builder(func(state, side, eid, card, targets):
		return (NRCard.event(NRCardXlate.first_target(targets)) and (((0 == NRUtil.as_array(NRCardXlate.getk(eid, "cost-paid", null)).size()) or NRUtil.kw_eq(0, NRUtil.as_array(NRCardXlate.getk(eid, "cost-paid", null)).size())) or NRCardXlate.getk(eid, "x-cost", null)) and (("play" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("play", NRCardXlate.getk(eid, "source-type", null)))), NRChooseOne.choose_one([
		{
		"option": "Trash Mystic Maemi",
		"ability": {
			"async": true,
			"msg": "trash itself",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, card, {
				"cause-card": card,
			}),
		},
	},
		{
		"option": "Trash a random card from the grip",
		"req": func(state, side, eid, card, targets): return NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("randomly-trash-from-hand", 1)]),
		"ability": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"cost": [NRPayment.to_c("randomly-trash-from-hand", 1)],
				"msg": "cost",
			}, card, null),
		},
	},
	]), {
		"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0),
		"msg": "take 1 [Credits]",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRCardXlate.take_credits(state, side, eid, card, "credit", 1),
	})))

	NRCardDefs.defcard("Net Mercur", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Stealth - Virtual",
		"subtypes": ["Stealth", "Virtual"],
		"text": "The first time you spend credits from a <strong>stealth</strong> card during each run, place 1[Credits] on this resource or draw 1 card.\nYou can spend hosted credits for anything.",
		"code": "11046",
		"title": "Net Mercur",
	}, {
		"abilities": [
			{
			"msg": "gain 1 [Credits]",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0),
			"effect": func(state, side, eid, card, targets):
				return spend_credits(state, side, eid, card, "credit", 1),
		},
		],
		"events": [
			{
			"event": "spent-credits-from-card",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Stealth")),
			"once": "per-run",
			"waiting-prompt": true,
			"prompt": "Choose one",
			"choices": ["Place 1 [Credits] on Net Mercur", "Draw 1 card"],
			"async": true,
			"msg": func(state, side, eid, card, targets): return str((decapitalize(NRCardXlate.first_target(targets)) if ((NRCardXlate.first_target(targets) == "Draw 1 card") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 1 card")) else "place 1 [Credits] on itself")),
			"effect": func(state, side, eid, card, targets):
				return (NRDrawing.draw(state, side, eid, 1) if ((NRCardXlate.first_target(targets) == "Draw 1 card") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 1 card")) else NRProps.add_counter(state, "runner", eid, card, "credit", 1)),
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (state.getv("run") or (("corp" == NRCardXlate.getk(state, "active-player", null)) or NRUtil.kw_eq("corp", NRCardXlate.getk(state, "active-player", null))) or NRUtil.in_coll(["psi", "trace"], NRCardXlate.getk(eid, "source-type", null)) or state.get_in(["prevent"], null)),
				"type": "credit",
			},
		},
	}))

	NRCardDefs.defcard("Network Exchange", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The install cost of each piece of ice that is not installed in the innermost position is increased by 1.",
		"code": "12007",
		"title": "Network Exchange",
	}, {
		"on-install": {
			"msg": "increase the install cost of non-innermost ice by 1",
		},
		"static-abilities": [
			{
			"type": "install-cost",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.first_target(targets)),
			"value": func(state, side, eid, card, targets):
				return (1 if (NRUtil.as_array(NRCardXlate.getk((NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), "dest-zone", null)).size() > 0) else null),
		},
		],
	}))

	NRCardDefs.defcard("Neutralize All Threats", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Adam",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Directive - Virtual",
		"subtypes": ["Directive", "Virtual"],
		"text": "The first time each turn you access a card with a trash cost, reveal it. You must trash that card by paying its trash cost, if able.\nWhenever you breach HQ, access 1 additional card.",
		"code": "09043",
		"title": "Neutralize All Threats",
	}, {
		"events": [
			breach_access_bonus("hq", 1),
			{
			"event": "breach-server",
			"req": func(state, side, eid, card, targets): return ((("archives" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("archives", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(func(_x): return bool(NRCardXlate.getk(_x, "trash")))).is_empty())),
			"effect": func(state, side, eid, card, targets):
				return state.assoc_in(["per-turn", NRCardXlate.getk(card, "cid", null)], true),
		},
			{
			"event": "pre-trash",
			"req": func(state, side, eid, card, targets): return (func():
				var cards = NRUtil.as_array((NRUtil.as_array(NREvents.turn_events(state, side, "pre-trash")).slice(1) if NRUtil.as_array(NREvents.turn_events(state, side, "pre-trash")).size() > 0 else [])).map(first)
				return ((NRUtil.as_array(cards).filter(func(_x): return bool(NRCardXlate.getk(_x, "trash"))) is Array and NRUtil.as_array(cards).filter(func(_x): return bool(NRCardXlate.getk(_x, "trash"))).is_empty() if false else (str(NRUtil.as_array(cards).filter(func(_x): return bool(NRCardXlate.getk(_x, "trash")))) == "")) and NRUtil.is_number(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "trash", null)))
			).call(),
			"once": "per-turn",
			"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), {
				"visible": true,
			})),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				state.assoc_in(["runner", "register", "must-trash-with-credits"], true)
				return NRRevealing.reveal(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)),
		},
			{
			"event": "post-access-card",
			"req": func(state, side, eid, card, targets): return state.get_in(["runner", "register", "must-trash-with-credits"], null),
			"effect": func(state, side, eid, card, targets):
				return state.assoc_in(["runner", "register", "must-trash-with-credits"], false),
		},
		],
	}))

	NRCardDefs.defcard("New Angeles City Hall", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location - Government",
		"subtypes": ["Location", "Government"],
		"text": "[interrupt] → <strong>2[Credits]:</strong> Prevent 1 tag.\nWhen you steal an agenda, trash this resource.",
		"code": "02109",
		"title": "New Angeles City Hall",
	}, (func():
		return {
			"prevention": [
				{
				"prevents": "tag",
				"type": "ability",
				"label": "New Angeles City Hall",
				"prompt": "Pay 2 [Credits] to avoid a tag?",
				"ability": {
					"async": true,
					"cost": [NRPayment.to_c("credit", 2)],
					"msg": "avoid 1 tag",
					"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						prevent_tag(state, "runner", ne, 1)
					, func(async_result):
						NREngine.continue_ability(state, side, prevent_another_tag(), card, null)),
				},
			},
			],
			"events": [
				{
				"event": "agenda-stolen",
				"async": true,
				"msg": "trash itself",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, card, {
					"cause": "runner-ability",
					"cause-card": card,
				}),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Nurse Hạnh", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever 2 or more facedown cards in Archives are turned faceup, draw 2 cards.",
		"code": "36007",
		"title": "Nurse Hạnh",
	}, {
		"events": [
			{
			"event": "archives-flipped",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "count", null) >= 2),
			"msg": "draw 2 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("No Free Lunch", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[Trash]<strong>:</strong> Gain 3[Credits].\n[Trash]<strong>:</strong> Remove 1 tag.",
		"code": "33020",
		"title": "No Free Lunch",
	}, {
		"abilities": [
			{
			"label": "Gain 3 [Credits]",
			"msg": "gain 3 [Credits]",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 3),
		},
			{
			"label": "Remove 1 tag",
			"msg": "remove 1 tag",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("No One Home", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[interrupt] → The first time each turn you would take tags or suffer net damage, you may trash this resource to have the Corp trace[0]. If unsuccessful, prevent all tags or all net damage.",
		"code": "21045",
		"title": "No One Home",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "event",
			"prompt": "Trash No One Home to force the Corp to trace",
			"ability": {
				"async": true,
				"msg": "force the Corp to trace",
				"req": func(state, side, eid, card, targets): return ((("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NREvents.first_event(state, side, "pre-damage-flag", func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)))) and NREvents.no_event(state, side, "runner-prevents-all-tags") and NREvents.no_event(state, side, "runner-gain-tag") and NRPrevention.preventable(state, "damage")),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, card, {
					"unpreventable": true,
					"cause-card": card,
				})
				, func(async_result):
					NREngine.continue_ability(state, "corp", {
					"label": "Trace 0 - if unsuccessful, the Runner prevents any amount of net damage",
					"trace": {
						"base": 0,
						"unsuccessful": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREngine.continue_ability(state, "runner", prevent_up_to_n_damage("all", ["net"]), card, null),
						},
					},
				}, card, null)),
			},
		},
			{
			"prevents": "tag",
			"type": "event",
			"prompt": "Trash No One Home to force the Corp to trace",
			"ability": {
				"async": true,
				"msg": "force the Corp to trace",
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, side, "tag-interrupt") and NRPrevention.preventable(state, "tag") and NREvents.no_event(state, side, "all-damage-was-prevented", func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)))) and NREvents.no_event(state, side, "damage", func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null))))),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, card, {
					"unpreventable": true,
					"cause-card": card,
				})
				, func(async_result):
					NREngine.continue_ability(state, "corp", {
					"label": "Trace 0 - if unsuccessful, the Runner avoids any number of tags",
					"trace": {
						"base": 0,
						"unsuccessful": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREngine.continue_ability(state, "runner", prevent_up_to_n_tags("all"), card, null),
						},
					},
				}, card, null)),
			},
		},
		],
	}))

	NRCardDefs.defcard("Off-Campus Apartment", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "Off-Campus Apartment can host any number of <strong>connections</strong>.\nWhenever you install a <strong>connection</strong> on Off-Campus Apartment, draw 1 card.",
		"code": "08022",
		"title": "Off-Campus Apartment",
	}, {
		"flags": {
			"runner-install-draw": true,
		},
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return (NRCard.resource(NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Connection")),
		},
		],
		"events": [
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "host", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Officer Frank", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Trash], 1[Credits]: The Corp trashes 2 cards from HQ at random. Use this ability only if you suffered meat damage this turn.",
		"code": "13024",
		"title": "Officer Frank",
	}, {
		"abilities": [
			{
			"cost": [NRPayment.to_c("credit", 1), NRPayment.to_c("trash-can")],
			"req": func(state, side, eid, card, targets): return find_first(func(_pct, _pct2=null, _pct3=null): return (("meat" == NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null))), NREvents.turn_events(state, "runner", "damage")),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
			},
			"msg": "force the Corp to trash 2 random cards from HQ",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(state, "corp", eid, NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(2)), {
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Open Market", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Job - Location",
		"subtypes": ["Job", "Location"],
		"text": "When you install this resource, load 6[Credits] onto it. When it is empty, trash it.\nYou can spend hosted credits to install <strong>connection</strong> and <strong>job</strong> resources.\nWhen your turn begins, take 1[Credits] from this resource.",
		"code": "35022",
		"title": "Open Market",
	}, (func():
		var ability = {
			"once": "per-turn",
			"automatic": "gain-credits",
			"label": "Take 1 [Credits] (start of turn)",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (NRCard.get_counters(card, "credit") > 0)),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(mini(1, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.take_credits(state, side, eid, card, "credit", 1),
		}
		return {
			"data": {
				"counter": {
					"credit": 6,
				},
			},
			"automatic": "gain-credits",
			"flags": {
				"drip-economy": true,
			},
			"interactions": {
				"pay-credits": {
					"req": func(state, side, eid, card, targets): return ((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_any_subtype(NRCardXlate.first_target(targets), ["Job", "Connection"])),
					"type": "credit",
				},
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				trash_on_empty("credit"),
			],
		}
	).call()))

	NRCardDefs.defcard("Oracle May", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "You cannot use this resource more than once per turn.\n[Click]<strong>:</strong> Choose a card type. Reveal the top card of your stack. If that card has the chosen type, draw it and gain 2[Credits]. Otherwise, trash it.",
		"code": "05054",
		"title": "Oracle May",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"label": "Name a card type",
			"once": "per-turn",
			"prompt": "Choose one",
			"choices": ["Event", "Hardware", "Program", "Resource"],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var c = NRUtil.first_of(state.get_in(["runner", "deck"], null))
				return (func():
					NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to name ") + str(NRCardXlate.first_target(targets)) + str(" and reveal ") + str(NRCardXlate.getk(c, "title", null)) + str(" from the top of the stack")))
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, c)
					, func(async_result):
						((func():
						NRSay.system_msg(state, side, (str("gains 2 [Credits] and draws ") + str(NRCardXlate.getk(c, "title", null))))
						NRSay.play_sfx(state, side, "professional-contacts")
						return NREid.wait_for(state, eid, func(ne):
							NRGaining.gain_credits(state, side, ne, 2)
						, func(async_result):
							NRDrawing.draw(state, side, eid, 1))
					).call() if NRCard.is_type(c, NRCardXlate.first_target(targets)) else (func():
						NRSay.system_msg(state, side, (str("trashes ") + str(NRCardXlate.getk(c, "title", null))))
						return NRMoving.mill(state, side, eid, "runner", 1)
					).call()))
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Order of Sol", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "The first time you have no credits in your credit pool each turn, gain 1[Credits].",
		"code": "06058",
		"title": "Order of Sol",
	}, (func():
		var ability = {
			"msg": "gain 1 [Credits]",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state.getv("runner", {}), "credit", null) == 0),
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		}
		return {
			"on-install": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, ability, card, null),
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-credit-loss"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-spent-credits"}),
			],
		}
	).call()))

	NRCardDefs.defcard("PAD Tap", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "The first time the Corp gains credits through a card ability each turn, you may gain 1[Credits].\n[Click], 3[Credits]: Trash PAD Tap. Only the Corp can use this ability.",
		"code": "21106",
		"title": "PAD Tap",
	}, {
		"special": {
			"auto-fire": "always",
		},
		"events": [
			{
			"event": "corp-credit-gain",
			"optional": {
				"prompt": "Gain 1 [Credit]?",
				"req": func(state, side, eid, card, targets): return ((not (((NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null) == "corp-click-credit") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null), "corp-click-credit")))) and ((1 == NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, "corp", "corp-credit-gain")).filter(func(_x): return not ((func(_p): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null) == "corp-click-credit") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null), "corp-click-credit"))).call(_x)))).size()) or NRUtil.kw_eq(1, NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, "corp", "corp-credit-gain")).filter(func(_x): return not ((func(_p): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null) == "corp-click-credit") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null), "corp-click-credit"))).call(_x)))).size()))),
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": "gain 1 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "runner", eid, 1),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "PAD Tap")],
		"corp-abilities": [
			{
			"action": true,
			"label": "Trash PAD Tap",
			"async": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 3)],
			"req": func(state, side, eid, card, targets): return (("corp" == side) or NRUtil.kw_eq("corp", side)),
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, "corp", "spends [Click] and 3 [Credits] to trash PAD Tap")
				return NRMoving.trash(state, "corp", eid, card, {
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Paige Piper", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The first time you install a card each turn (including Paige Piper), you may search your stack for any number of copies of that card and add them to your heap. Shuffle your stack.",
		"code": "08002",
		"title": "Paige Piper",
	}, (func():
		return {
			"events": [
				{
				"event": "runner-install",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "runner-install"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, pphelper(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null), filterv(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null))), NRCardXlate.getk(state.getv("runner", {}), "deck", null))), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Paladin Poemu", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Companion - Virtual",
		"subtypes": ["Companion", "Virtual"],
		"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nYou can spend hosted credits to install non-<strong>connection</strong> cards.\nWhen your turn ends, if there are 3 or more hosted credits, trash 1 of your installed cards.",
		"code": "26073",
		"title": "Paladin Poemu",
	}, companion_builder(func(state, side, eid, card, targets):
		return ((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "Connection")))), {
		"prompt": "Choose an installed card to trash",
		"waiting-prompt": true,
		"choices": {
			"all": true,
			"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.runner(_pct)),
		},
		"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
			"cause": "runner-ability",
			"cause-card": card,
		}),
	}, {
		"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0),
		"msg": "take 1 [Credits]",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRCardXlate.take_credits(state, side, eid, card, "credit", 1),
	})))

	NRCardDefs.defcard("Paparazzi", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "You are tagged.\n[interrupt] → Whenever you would take meat damage, prevent all of that damage.",
		"code": "08087",
		"title": "Paparazzi",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "event",
			"max-uses": 1,
			"mandatory": true,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return ((("meat" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("meat", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, "all"),
			},
		},
		],
		"static-abilities": [{
			"type": "is-tagged",
			"value": true,
		}],
	}))

	NRCardDefs.defcard("Patron", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, you may choose a server.\nThe first time each turn you make a successful run on the chosen server, instead of breaching it, draw 2 cards.",
		"code": "10063",
		"title": "Patron",
	}, (func():
		var ability = {
			"prompt": "Choose a server",
			"label": "Choose a server (start of turn)",
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array(NRServers.zones_to_sorted_names(NRBoard.get_zones(state))) + NRUtil.as_array(["No server"])),
			"skippable": true,
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (not (used_this_turn_p(NRCardXlate.getk(card, "cid", null), state)))),
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"effect": func(state, side, eid, card, targets):
				return (NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})) if (not (((NRCardXlate.first_target(targets) == "No server") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "No server")))) else null),
		}
		return {
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				NRUtil.merge(NRCardXlate.successful_run_replace_breach({
				"mandatory": true,
				"ability": NRDefHelpers.draw_ability(2),
			}) if NRCardXlate.successful_run_replace_breach({
				"mandatory": true,
				"ability": NRDefHelpers.draw_ability(2),
			}) is Dictionary else {}, {"req": func(state, side, eid, card, targets):
				return (func():
				var card = NRCard.get_card(state, card)
				return (((NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == NRCardXlate.getk(card, "card-target", null)) or NRUtil.kw_eq(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), NRCardXlate.getk(card, "card-target", null))) and NREvents.first_event(state, side, "successful-run", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return ((NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == NRCardXlate.getk(card, "card-target", null)) or NRUtil.kw_eq(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), NRCardXlate.getk(card, "card-target", null)))
			).call())) if card != null else null
			).call()}),
				{
				"event": "runner-turn-ends",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.dissoc(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["card-target"])),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Paule's Café", NRCardXlate.merge_cdef({
		"title": "Paule's Café",
	}, {
		"abilities": [
			{
			"action": true,
			"label": "Host a program or piece of hardware",
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRUtil.in_coll(["Program", "Hardware"], NRCardXlate.getk(_pct, "type", null)) and NRCard.in_hand(_pct) and NRCard.runner(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				return NRHosting.host(state, side, card, NRCardXlate.first_target(targets)),
			"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(""),
		},
			(func():
			return {
				"async": true,
				"label": "Install hosted card",
				"cost": [NRPayment.to_c("credit", 1)],
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty()) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)), func(_pct, _pct2=null, _pct3=null): return NRInstalling.runner_can_pay_and_install(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
					"cost-bonus": discount(state, card),
				})) != null)),
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
						"cost-bonus": discount(state, card),
					})),
				},
				"effect": func(state, side, eid, card, targets):
					NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": discount(state, card),
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
						"include-cost-from-eid": eid,
					},
				})
					return state.assoc_in(["per-turn", NRCardXlate.getk(card, "cid", null)], true),
			}
		).call(),
		],
	}))

	NRCardDefs.defcard("Penumbral Toolkit", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Stealth - Virtual",
		"subtypes": ["Stealth", "Virtual"],
		"text": "If you made a successful run on HQ this turn, this resource costs 2[Credits] less to install.\nWhen you install this resource, load 4[Credits] onto it. When it is empty, trash it.\nYou can spend hosted credits during runs.",
		"code": "26081",
		"title": "Penumbral Toolkit",
	}, {
		"data": {
			"counter": {
				"credit": 4,
			},
		},
		"install-cost-bonus": func(state, side, eid, card, targets):
			return (-2 if (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) else 0),
		"abilities": [
			{
			"msg": "gain 1 [Credits]",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (NRCard.get_counters(card, "credit") > 0)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return spend_credits(state, side, eid, card, "credit", 1),
		},
		],
		"events": [trash_on_empty("credit")],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
	}))

	NRCardDefs.defcard("Personal Workshop", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "[Click]: Host a program or piece of hardware from your grip on Personal Workshop and place power counters on it equal to its install cost.\n1[Credits]: Remove 1 power counter from a hosted card.\nWhen your turn begins, remove 1 power counter from a hosted card.\nWhen there are no power counters left on a hosted card, install it, ignoring all costs.",
		"code": "02049",
		"title": "Personal Workshop",
	}, (func():
		var remove_counter = {
			"async": true,
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty()),
			"msg": func(state, side, eid, card, targets): return str("remove 1 power counter from ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(_pct, "host", null),
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, NRCardXlate.first_target(targets), "power", -1)
			, func(async_result):
				(NREid.effect_completed(state, side, eid) if (NRCard.get_counters(NRCard.get_card(state, NRCardXlate.first_target(targets)), "power") > 0) else NRInstalling.runner_install(state, side, eid, NRUtil.dissoc(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, ["counter"]), {
				"ignore-all-cost": true,
				"msg-keys": {
					"display-origin": true,
					"install-source": card,
				},
			}))),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"abilities": [
				{
				"action": true,
				"async": true,
				"label": "Host a program or piece of hardware",
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"prompt": "Choose a program or piece of hardware in the grip",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return ((NRCard.program(_pct) or NRCard.hardware(_pct)) and NRCard.in_hand(_pct) and NRCard.runner(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					return (NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"ignore-all-cost": true,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				}) if (not ((NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null) > 0))) else (func():
					NRHosting.host(state, side, card, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"counter": {
						"power": NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null),
					}}))
					return NREid.effect_completed(state, side, eid)
				).call()),
				"msg": func(state, side, eid, card, targets): return str("install and host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			},
				NRUtil.merge(remove_counter if remove_counter is Dictionary else {}, {"label": "Remove 1 power counter from a hosted card"}),
				{
				"async": true,
				"label": "Remove power counters from a hosted card",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(_pct, "host", null),
				},
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty()),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, (func():
					var paydowntarget = NRCardXlate.first_target(targets)
					var num_counters = NRCard.get_counters(NRCard.get_card(state, paydowntarget), "power")
					return {
						"async": true,
						"prompt": "How many power counters do you want to remove?",
						"choices": {
							"number": func(state, side, eid, card, targets):
								return mini(num_counters, total_available_credits(state, "runner", eid, card)),
						},
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NREngine.pay(state, "runner", ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("credit", NRCardXlate.first_target(targets))])
						, func(async_result):
							(func():
							var payment_str = NRCardXlate.getk(async_result, "msg", null)
							return (func():
							NRSay.system_msg(state, side, (str(build_spend_msg(payment_str, "use")) + str(NRCardXlate.getk(card, "title", null)) + str(" to remove ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "power counter")) + str(" from ") + str(NRCardXlate.getk(paydowntarget, "title", null))))
							return (NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRUtil.dissoc(paydowntarget if paydowntarget is Dictionary else {}, ["counter"]), {
								"ignore-all-cost": true,
								"msg-keys": {
									"display-origin": true,
									"install-source": card,
								},
							}) if ((num_counters == NRCardXlate.first_target(targets)) or NRUtil.kw_eq(num_counters, NRCardXlate.first_target(targets))) else NRProps.add_counter(state, side, eid, paydowntarget, "power", (-NRCardXlate.first_target(targets))))
						).call() if payment_str != null else NREid.effect_completed(state, side, eid)
						).call()),
					}
				).call(), card, null),
			},
			],
			"events": [
				NRUtil.merge(remove_counter if remove_counter is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Political Operative", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Install only if you made a successful run on HQ this turn.\n<strong>[Trash]</strong>, <strong>X[Credits]:</strong> Trash 1 rezzed card with trash cost equal to X.",
		"code": "10043",
		"title": "Political Operative",
	}, {
		"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null),
		"abilities": [
			{
			"async": true,
			"fake-cost": [NRPayment.to_c("trash-can")],
			"label": "Trash a rezzed card",
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose a rezzed card with a trash cost",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCardXlate.getk(_pct, "trash", null) and NRCard.rezzed(_pct) and NRPayment.can_pay(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, [NRPayment.to_c("credit", trash_cost(state, "runner", _pct))])),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, {
					"async": true,
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"cost": [
						NRPayment.to_c("credit", trash_cost(state, "runner", NRCardXlate.first_target(targets))),
						NRPayment.to_c("trash-can"),
					],
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
						"cause-card": card,
					}),
				}, card, targets),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Power Tap", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Gain 1[Credits] whenever a trace is initiated.",
		"code": "06016",
		"title": "Power Tap",
	}, {
		"events": [
			{
			"event": "initialize-trace",
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Professional Contacts", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click]<strong>:</strong> Gain 1[Credits] and draw 1 card.",
		"code": "31036",
		"title": "Professional Contacts",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"msg": "gain 1 [Credits] and draw 1 card",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 1)
			, func(async_result):
				(func():
				NRSay.play_sfx(state, side, "professional-contacts")
				return NRDrawing.draw(state, side, eid, 1)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Psych Mike", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The first time each turn a successful run on R&D ends, you may gain 1[Credits] for each time you accessed a card in R&D during that run.",
		"code": "22021",
		"title": "Psych Mike",
	}, {
		"special": {
			"auto-fire": "always",
		},
		"events": [
			{
			"event": "run-ends",
			"optional": {
				"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "rd") and (total_cards_accessed(NRCardXlate.first_target(targets), "deck") > 0)),
				"prompt": "Gain 1 [Credits] for each card you accessed from R&D?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str("gain ") + str(total_cards_accessed(NRCardXlate.first_target(targets), "deck")) + str(" [Credits]"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "runner", eid, total_cards_accessed(NRCardXlate.first_target(targets), "deck")),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Psych Mike")],
	}))

	NRCardDefs.defcard("Public Sympathy", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Your maximum hand size is increased by 2.",
		"code": "02050",
		"title": "Public Sympathy",
	}, {
		"static-abilities": [runner_hand_size_(2)],
	}))

	NRCardDefs.defcard("Rachel Beckman", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 8,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "You get +1 allotted [Click] for each of your turns.\nIf you are tagged, trash this resource.",
		"code": "06060",
		"title": "Rachel Beckman",
	}, trash_when_tagged("Rachel Beckman", {
		"in-play": ["click-per-turn", 1],
	})))


static func _register_5() -> void:
	NRCardDefs.defcard("Raymond Flint", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever the Corp takes bad publicity, breach HQ. You cannot access cards in the root of HQ during this breach.\n<strong>[Trash]:</strong> Expose 1 card.",
		"code": "04049",
		"title": "Raymond Flint",
	}, {
		"events": [
			{
			"event": "corp-gain-bad-publicity",
			"async": true,
			"msg": "breach HQ",
			"effect": func(state, side, eid, card, targets):
				return NRAccess.breach_server(state, "runner", eid, ["hq"], {
				"no-root": true,
			}),
		},
		],
		"abilities": [
			{
			"label": "Expose 1 installed card",
			"choices": {
				"card": NRCard.installed,
			},
			"async": true,
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRExpose.expose(state, side, eid, [NRCardXlate.first_target(targets)]),
		},
		],
	}))

	NRCardDefs.defcard("Reclaim", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "[Click], [Trash], <strong>trash a card from your grip</strong>: Install a program, piece of hardware, or <strong>virtual</strong> resource from your heap, paying its install cost.",
		"code": "21107",
		"title": "Reclaim",
	}, {
		"abilities": [
			{
			"action": true,
			"async": true,
			"label": "Install a program, piece of hardware, or Virtual resource from the heap",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return ((NRCard.program(_pct) or NRCard.hardware(_pct) or (NRCard.resource(_pct) and NRCard.has_subtype(_pct, "Virtual"))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
				"no-toast": true,
			}))) != null),
			"cost": [
				NRPayment.to_c("click", 1),
				NRPayment.to_c("trash-can"),
				NRPayment.to_c("trash-from-hand", 1),
			],
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"async": true,
				"prompt": "Choose a card to install",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCard.program(_pct) or NRCard.hardware(_pct) or (NRCard.resource(_pct) and NRCard.has_subtype(_pct, "Virtual"))) and NRInstalling.runner_can_pay_and_install(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct))))),
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
						"include-cost-from-eid": eid,
					},
				}),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Red Team", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When you install this resource, load 12[Credits] onto it. When it is empty, trash it.\n[Click]<strong>:</strong> Run a central server you have not run this turn. If successful, take 3[Credits] from this resource.",
		"code": "30018",
		"title": "Red Team",
	}, {
		"data": {
			"counter": {
				"credit": 12,
			},
		},
		"events": [
			trash_on_empty("credit"),
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(mini(3, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.take_credits(state, side, eid, card, "credit", 3),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"prompt": "Choose a server",
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_central)).filter(func(_x): return not (((NRUtil.as_array([]) + NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "made-run", null)))).call(_x)))).is_empty()),
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_central)).filter(func(_x): return not (((NRUtil.as_array([]) + NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "made-run", null)))).call(_x)))).map(NRServers.central_to_name),
			"label": "make a run on a central server",
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)),
			"makes-run": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		],
	}))

	NRCardDefs.defcard("Rent Rioters", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "[Click][Click][Click],[Trash]<strong>:</strong> Gain 9[Credits].",
		"code": "35011",
		"title": "Rent Rioters",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 3), NRPayment.to_c("trash-can")],
			"keep-menu-open": "while-clicks-left",
			"label": "gain 9 [Credits]",
			"msg": "gain 9 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-3")
				return NRGaining.gain_credits(state, side, eid, 9),
		},
		],
	}))

	NRCardDefs.defcard("Rogue Trading", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "Place 18[Credits] from the bank on Rogue Trading when it is installed. When there are no credits left on Rogue Trading, trash it.\n[Click], [Click]: Take 6[Credits] from Rogue Trading and take 1 tag.",
		"code": "21065",
		"title": "Rogue Trading",
	}, {
		"data": {
			"counter": {
				"credit": 18,
			},
		},
		"events": [trash_on_empty("credit")],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"keep-menu-open": "while-2-clicks-left",
			"msg": "gain 6 [Credits] and take 1 tag",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-3")
				return NREid.wait_for(state, eid, func(ne):
				NRCardXlate.take_credits(state, side, ne, card, "credit", 6, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRTags.gain_tags(state, "runner", eid, 1)),
		},
		],
	}))

	NRCardDefs.defcard("Rolodex", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "When you install Rolodex, look at the top 5 cards of your stack and arrange them in any order.\nWhen Rolodex is trashed, trash the top 3 cards of your stack.",
		"code": "08084",
		"title": "Rolodex",
	}, {
		"on-install": {
			"async": true,
			"msg": "look at the top 5 cards of the stack",
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var from = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(5))
				return (reorder_choice("runner", "corp", from, [], NRUtil.as_array(from).size(), from) if (NRUtil.as_array(from).size() > 0) else null)
			).call(), card, null),
		},
		"on-trash": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, "runner", (str("trashes ") + str(NRUtil.enumerate_cards(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(3)))) + str(" from the stack due to ") + str(NRCardXlate.getk(card, "title", null)) + str(" being trashed")))
				return NRMoving.mill(state, "runner", eid, "runner", 3),
		},
	}))

	NRCardDefs.defcard("Rosetta 2.0", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Click], <strong>remove an installed program from the game</strong>: Search your stack for a non-<strong>virus</strong> program, shuffle your stack, then install that program, lowering the install cost by the cost of the program removed from the game.",
		"code": "12045",
		"title": "Rosetta 2.0",
	}, (func():
		var find_rfg = func(state, card): return NRUtil.last_of(NRUtil.as_array(state.get_in(["runner", "rfg"], null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(card, "cid", null) == NRUtil.get_in(_pct, ["persistent", "from-cid"], null)) or NRUtil.kw_eq(NRCardXlate.getk(card, "cid", null), NRUtil.get_in(_pct, ["persistent", "from-cid"], null)))))
		return {
			"abilities": [
				{
				"action": true,
				"req": func(state, side, eid, card, targets): return (not (NRInstalling.install_locked(state, side))),
				"label": "Install a program from the stack",
				"async": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("rfg-program", 1)],
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, {
					"async": true,
					"prompt": "Choose a non-virus program to install",
					"choices": func(state, side, eid, card, targets):
						return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and (not (NRCard.has_subtype(_pct, "Virus"))) and NRInstalling.runner_can_pay_and_install(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
						"cost-bonus": (-NRCardXlate.getk(find_rfg(state, card), "cost", null)),
					}))))).is_empty())) + NRUtil.as_array(["Done"])),
					"effect": func(state, side, eid, card, targets):
						NREngine.trigger_event(state, side, "searched-stack")
						NRShuffling.shuffle_zone(state, side, "deck")
						return ((func():
						NRSay.system_msg(state, side, (str(NRCardXlate.getk(eid, "latest-payment-str", null)) + str(" to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to shuffle the Stack")))
						return NREid.effect_completed(state, side, eid)
					).call() if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
						"msg-keys": {
							"display-origin": true,
							"include-cost-from-eid": eid,
							"install-source": card,
						},
						"cost-bonus": (-NRCardXlate.getk(find_rfg(state, card), "cost", null)),
					})),
				}, card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Sacrificial Clone", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent all damage. Trash all installed hardware, all installed non-<strong>virtual</strong> resources, and all cards from your grip. Lose all credits in your credit pool. Remove all tags.",
		"code": "07050",
		"title": "Sacrificial Clone",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"max-uses": 1,
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRPrevention.prevent_damage(state, side, ne, "all")
				, func(async_result):
					(func():
					var cards = ((NRUtil.as_array(NRUtil.get_in(state.getv("runner", {}), ["rig", "hardware"], null)) + NRUtil.as_array(NRUtil.as_array(NRUtil.get_in(state.getv("runner", {}), ["rig", "resource"], null)).filter(func(_pct, _pct2=null, _pct3=null): return (not (NRCard.has_subtype(_pct, "Virtual")))))) + NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)))
					return (func():
						NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRUtil.quantify(NRUtil.as_array(cards).size(), "card")) + str(" (") + str(NRUtil.enumerate_str(NRUtil.as_array(cards).map(func(_x): return bool(NRCardXlate.getk(_x, "title"))))) + str("),") + str(" lose ") + str(NRUtil.quantify(NRCardXlate.getk(NRCardXlate.getk(state, "runner", null), "credit", null), "credit")) + str(", and lose ") + str(NRUtil.quantify(count_real_tags(state), "tag"))))
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash_cards(state, side, ne, ((NRUtil.as_array(NRUtil.get_in(state.getv("runner", {}), ["rig", "hardware"], null)) + NRUtil.as_array(NRUtil.as_array(NRUtil.get_in(state.getv("runner", {}), ["rig", "resource"], null)).filter(func(_pct, _pct2=null, _pct3=null): return (not (NRCard.has_subtype(_pct, "Virtual")))))) + NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null))), {
							"cause-card": card,
						})
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
							NRGaining.lose_credits(state, side, ne, NREid.make_eid(state, eid), "all")
						, func(async_result):
							NRTags.lose_tags(state, side, eid, "all")))
					).call()
				).call()),
			},
		},
		],
	}))

	NRCardDefs.defcard("Sacrificial Construct", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Remote",
		"subtypes": ["Remote"],
		"text": "[interrupt] → [Trash]<strong>:</strong> Prevent a player from trashing 1 installed program or piece of hardware.",
		"code": "20054",
		"title": "Sacrificial Construct",
	}, (func():
		return {
			"prevention": [
				prevent_trash_installed_by_type("Sacrificial Construct", ["Program", "Hardware"], [NRPayment.to_c("trash-can")], valid_context_p),
			],
		}
	).call()))

	NRCardDefs.defcard("Safety First", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Adam",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Directive - Virtual",
		"subtypes": ["Directive", "Virtual"],
		"text": "Your maximum hand size is reduced by 2.\nWhen your turn ends, draw 1 card if you do not have cards in your grip equal to or greater than your maximum hand size.",
		"code": "09044",
		"title": "Safety First",
	}, {
		"static-abilities": [runner_hand_size_(-2)],
		"events": [
			{
			"event": "runner-turn-ends",
			"automatic": "pre-draw-cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to draw 1 card")))
				return NRDrawing.draw(state, "runner", eid, 1)
			).call() if (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() < NRHandSize.hand_size(state, "runner")) else NREid.effect_completed(state, "runner", eid)),
		},
		],
	}))

	NRCardDefs.defcard("Salsette Slums", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Location - Seedy",
		"subtypes": ["Location", "Seedy"],
		"text": "Access, once per turn → <strong>Pay the trash cost of the card you are accessing:</strong> Remove that card from the game.",
		"code": "10059",
		"title": "Salsette Slums",
	}, {
		"interactions": {
			"access-ability": {
				"label": "Remove card from game",
				"req": func(state, side, eid, card, targets): return ((not (state.get_in(["per-turn", NRCardXlate.getk(card, "cid", null)], null))) and (not (NRCard.in_discard(NRCardXlate.first_target(targets)))) and NRCardXlate.getk(NRCardXlate.first_target(targets), "trash", null) and NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null), [
					NRPayment.to_c("credit", trash_cost(state, side, NRCardXlate.first_target(targets))),
				])),
				"once": "per-turn",
				"async": true,
				"trash?": false,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var trash_cost = trash_cost(state, side, NRCardXlate.first_target(targets))
					return NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, side, ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("credit", trash_cost)])
					, func(async_result):
						(func():
						var payment_str = NRCardXlate.getk(async_result, "msg", null)
						var card = NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "rfg")
						return (func():
							NRSay.system_msg(state, side, (str(payment_str) + str(" and remove ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the game")))
							return NREid.complete_with_result(state, side, eid, card)
						).call()
					).call())
				).call(),
			},
		},
	}))

	NRCardDefs.defcard("Salvaged Vanadis Armory", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Clan",
		"subtypes": ["Clan"],
		"text": "<strong>[Trash]:</strong> The Corp trashes the top X cards of R&D. X is equal to the amount of damage you have suffered this turn. Use this ability only during the next paid ability window after suffering any amount of damage.",
		"code": "12103",
		"title": "Salvaged Vanadis Armory",
	}, {
		"events": [
			{
			"event": "damage",
			"fake-cost": [NRPayment.to_c("trash-can")],
			"optional": {
				"waiting-prompt": true,
				"prompt": "Trash Salvaged Vanadis Armory to force the Corp to trash the top cards of R&D?",
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("trash-can")],
					"msg": func(state, side, eid, card, targets): return str("force the Corp to trash the top ") + str(NRUtil.quantify(get_turn_damage(state, "runner"), "card")) + str(" of R&D"),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.mill(state, "corp", eid, "corp", get_turn_damage(state, "runner")),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Same Old Thing", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "[Click], [Click], [Trash]: Play an event from your heap (paying its play cost).",
		"code": "03054",
		"title": "Same Old Thing",
	}, {
		"abilities": [
			{
			"action": true,
			"async": true,
			"label": "play an event in the heap",
			"cost": [NRPayment.to_c("click", 2), NRPayment.to_c("trash-can")],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not (NRFlags.zone_locked(state, "runner", "discard"))) and (NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(NRCard.event)).size() > 0)),
			},
			"prompt": "Choose an event in the heap",
			"msg": func(state, side, eid, card, targets): return str("play ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"show-discard": true,
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.event(NRCardXlate.first_target(targets)) and NRCard.in_discard(NRCardXlate.first_target(targets)) and NRPlayInstants.can_play_instant(state, side, eid, NRCardXlate.first_target(targets), {
					"base-cost": [NRPayment.to_c("click", 2)],
				})),
			},
			"effect": func(state, side, eid, card, targets):
				return NRPlayInstants.play_instant(state, side, eid, NRCardXlate.first_target(targets)),
		},
		],
	}))

	NRCardDefs.defcard("Scrubber", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "2[recurring-credit] <em>(When you install this card and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to pay trash costs.",
		"code": "31011",
		"title": "Scrubber",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-trash-corp-cards" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-trash-corp-cards", NRCardXlate.getk(eid, "source-type", null))) and NRCard.corp(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Security Testing", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When your turn begins, you may choose a server.\nThe first time each turn you make a successful run on the chosen server, instead of breaching it, gain 2[Credits].",
		"code": "31024",
		"title": "Security Testing",
	}, (func():
		var ability = {
			"prompt": "Choose a server",
			"label": "Choose a server (start of turn)",
			"skippable": true,
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array(NRServers.zones_to_sorted_names(NRBoard.get_zones(state))) + NRUtil.as_array(["No server"])),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (not (used_this_turn_p(NRCardXlate.getk(card, "cid", null), state)))),
			"effect": func(state, side, eid, card, targets):
				return (NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})) if (not (((NRCardXlate.first_target(targets) == "No server") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "No server")))) else null),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				NRUtil.merge(NRCardXlate.successful_run_replace_breach({
				"mandatory": true,
				"ability": {
					"msg": "gain 2 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, 2),
				},
			}) if NRCardXlate.successful_run_replace_breach({
				"mandatory": true,
				"ability": {
					"msg": "gain 2 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, 2),
				},
			}) is Dictionary else {}, {"req": func(state, side, eid, card, targets):
				return (func():
				var card = NRCard.get_card(state, card)
				return (((NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == NRCardXlate.getk(card, "card-target", null)) or NRUtil.kw_eq(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), NRCardXlate.getk(card, "card-target", null))) and NREvents.first_event(state, side, "successful-run", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return ((NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == NRCardXlate.getk(card, "card-target", null)) or NRUtil.kw_eq(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), NRCardXlate.getk(card, "card-target", null)))
			).call())) if card != null else null
			).call()}),
				{
				"event": "runner-turn-ends",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.dissoc(card if card is Dictionary else {}, ["card-target"])),
			},
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Shadow Team", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever you draw a Shadow Team, immediately install it.\nWhenever you initiate a run, trash a card from your grip, if able. When you make a successful run on a central server, destroy Shadow Team.",
		"code": "14022",
		"title": "Shadow Team",
	}, {
		"on-draw": {
			"req": func(state, side, eid, card, targets): return (NRInstalling.runner_can_pay_and_install(state, side, eid, card) and in_set_aside_p(card)),
			"msg": "install itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, eid, card),
		},
		"events": [
			{
			"event": "run",
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()),
			"msg": "cost",
			"cost": [NRPayment.to_c("trash-from-hand", 1)],
		},
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return NRUtil.in_coll(["hq", "rd", "archives"], NRServers.target_server(NRCardXlate.ctx(targets))),
			"msg": "destroy itself",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, card, "destroyed"),
		},
		],
	}))

	NRCardDefs.defcard("Side Hustle", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When you install this resource and whenever a run begins, place 1[Credits] on this resource.\nWhen there are 6 or more hosted credits, take all credits from this resource, trash it, and draw 1 card.",
		"code": "35034",
		"title": "Side Hustle",
	}, {
		"data": {
			"counter": {
				"credit": 1,
			},
		},
		"events": [
			{
			"event": "run",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return (NRCard.get_counters(card, "credit") >= 5),
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 1, null),
		},
			{
			"event": "counter-added",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (6 <= NRCard.get_counters(NRCard.get_card(state, card), "credit")),
			"automatic": "draw-cards",
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRCard.get_counters(NRCard.get_card(state, card), "credit")) + str(" [Credits], draw 1 card, and trash itself"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRCardXlate.take_credits(state, side, ne, card, "credit", "all", {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, side, ne, 1, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRMoving.trash(state, side, eid, card, {
				"cause-card": card,
			}))),
		},
		],
	}))

	NRCardDefs.defcard("Smartware Distributor", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click]<strong>:</strong> Place 3[Credits] on this resource.\nWhen your turn begins, take 1[Credits] from this resource.",
		"code": "30033",
		"title": "Smartware Distributor",
	}, (func():
		var start_of_turn_ability = {
			"once": "per-turn",
			"automatic": "gain-credits",
			"label": "Take 1 [Credits] (start of turn)",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (NRCard.get_counters(card, "credit") > 0)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.take_credits(state, side, eid, card, "credit", 1),
		}
		return {
			"flags": {
				"drip-economy": func(state, side, eid, card, targets):
					return (NRCard.get_counters(card, "credit") > 0),
			},
			"abilities": [
				{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "place 3 [Credits]",
				"req": func(state, side, eid, card, targets): return (not (NRCardXlate.getk(state, "runner-phase-12", null))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "credit", 3),
			},
				start_of_turn_ability,
			],
			"events": [
				NRUtil.merge(start_of_turn_ability if start_of_turn_ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Slipstream", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever you pass a rezzed piece of ice, you may trash this resource. If you do, choose 1 piece of ice protecting a central server in the same position as the passed ice. Move to that ice and approach it. You may jack out.",
		"code": "21085",
		"title": "Slipstream",
	}, {
		"events": [
			{
			"event": "pass-ice",
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and (not (NRServers.protecting_same_server(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), _pct))) and ((state.get_in(["run", "position"], 0) == card_index(state, _pct)) or NRUtil.kw_eq(state.get_in(["run", "position"], 0), card_index(state, _pct))) and NRServers.is_central((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))) != null)),
				"prompt": func(state, side, eid, card, targets): return str("Trash ") + str(NRCardXlate.getk(card, "title", null)) + str(" to approach a piece of ice protecting a central server?"),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, (func():
						var passed_ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
						return {
							"async": true,
							"prompt": "Choose a piece of ice protecting a central server at the same position",
							"choices": {
								"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and (not (NRServers.protecting_same_server(passed_ice, NRCardXlate.first_target(targets)))) and ((state.get_in(["run", "position"], 0) == card_index(state, NRCardXlate.first_target(targets))) or NRUtil.kw_eq(state.get_in(["run", "position"], 0), card_index(state, NRCardXlate.first_target(targets)))) and (not (NRUtil.same_card(NRCardXlate.first_target(targets), passed_ice))) and NRServers.is_central((NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null))),
							},
							"msg": func(state, side, eid, card, targets): return str("approach ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, card, {
								"unpreventable": true,
								"cause-card": card,
							})
							, func(async_result):
								(func():
								var dest = (NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null)
								return (func():
									null
									set_next_phase(state, "approach-ice")
									NRIce.update_all_ice(state, side)
									NRIce.update_all_icebreakers(state, side)
									return NREngine.continue_ability(state, side, NRDefHelpers.offer_jack_out(), card, null)
								).call()
							).call()),
						}
					).call(), card, null),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Spoilers", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever the Corp scores an agenda, they trash the top card of R&D.",
		"code": "08082",
		"title": "Spoilers",
	}, {
		"events": [
			{
			"event": "agenda-scored",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "trash the top card of R&D",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.mill(state, "corp", eid, "corp", 1),
		},
		],
	}))

	NRCardDefs.defcard("Starlight Crusade Funding", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"text": "When your turn begins, lose [Click].\nIgnore any additional costs on each <strong>double</strong> event you play.",
		"code": "04069",
		"title": "Starlight Crusade Funding",
	}, {
		"on-install": {
			"msg": "ignore additional costs on Double events",
			"effect": func(state, side, eid, card, targets):
				return state.assoc_in(["runner", "register", "double-ignore-additional"], true),
		},
		"events": [
			{
			"event": "runner-turn-begins",
			"automatic": "lose-clicks",
			"msg": "lose [Click] and ignore additional costs on Double events",
			"effect": func(state, side, eid, card, targets):
				NRGaining.lose_clicks(state, "runner", 1)
				return state.assoc_in(["runner", "register", "double-ignore-additional"], true),
		},
		],
		"leave-play": func(state, side, eid, card, targets):
			return state.update_in(["runner", "register"], func(v): return v, 0),
	}))

	NRCardDefs.defcard("Stick and Poke", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Companion - Virtual",
		"subtypes": ["Companion", "Virtual"],
		"text": "The first time each turn you encounter a piece of ice, it gains “[subroutine] Do 1 net damage. The Runner draws 1 card.”, before its other subroutines, for the remainder of that encounter.",
		"code": "36008",
		"title": "Stick and Poke",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "encounter-ice"),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NREffects.register_lingering_effect(state, side, card, (func():
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return {
					"duration": "end-of-encounter",
					"type": "additional-subroutines",
					"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.first_target(targets)) and NRUtil.same_card(NRCardXlate.first_target(targets), ice)),
					"value": {
						"position": "front",
						"subroutines": [
							{
							"label": "[Stick] Do 1 net damage. The Runner draws 1 card.",
							"msg": "Do 1 net damage",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRDamage.damage(state, side, ne, "net", 1)
							, func(async_result):
								NRDrawing.draw(state, "runner", eid, card, 1)),
						},
						],
					},
				}
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Stim Dealer", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, if there are 2 or more hosted power counters, remove all of them and suffer 1 core damage. This damage cannot be prevented. Otherwise, place 1 power counter on this resource and gain [Click].",
		"code": "07051",
		"title": "Stim Dealer",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"msg": func(state, side, eid, card, targets): return str(("takes 1 core damage" if (NRCard.get_counters(card, "power") >= 2) else "gain [Click]")),
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "power", (-NRCard.get_counters(card, "power")))
			, func(async_result):
				NRDamage.damage(state, side, eid, "brain", 1, {
				"unpreventable": true,
				"card": card,
			})) if (NRCard.get_counters(card, "power") >= 2) else NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "power", 1)
			, func(async_result):
				(func():
				NRGaining.gain_clicks(state, side, 1)
				return NREid.effect_completed(state, side, eid)
			).call())),
		},
		],
	}))

	NRCardDefs.defcard("Stoneship Chart Room", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "[Trash]<strong>:</strong> Draw 2 cards.\n[Trash]<strong>:</strong> Charge 1 of your installed cards.",
		"code": "33030",
		"title": "Stoneship Chart Room",
	}, {
		"abilities": [
			NRDefHelpers.draw_ability(2, null, {
			"cost": [NRPayment.to_c("trash-can")],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
		}),
			{
			"label": "Charge a card",
			"req": func(state, side, eid, card, targets): return NRCharge.can_charge(state, side),
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRCharge.charge_ability(state, side), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Street Magic", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Unbroken subroutines resolve in the order of your choice.",
		"code": "10003",
		"title": "Street Magic",
	}, (func():
		return {
			"abilities": [
				{
				"implementation": "Effect is manually triggered",
				"label": "Choose subroutine order",
				"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)).filter(func(_x): return not ((func(_x): return bool(NRCardXlate.getk(_x, "broken"))).call(_x)))).size() > 0),
				"async": true,
				"msg": func(state, side, eid, card, targets): return str("choose the order the unbroken subroutines on ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str(" resolve"),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, runner_break(NRIce.unbroken_subroutines_choice(NRIce.get_current_ice(state))), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Street Peddler", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "When you install Street Peddler, host the top 3 cards of your stack facedown on Street Peddler (you may look at these cards at any time).\n[Trash]: Install 1 card hosted on Street Peddler, lowering its install cost by 1.",
		"code": "08062",
		"title": "Street Peddler",
	}, {
		"on-install": {
			"interactive": func(state, side, eid, card, targets):
				return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-install-draw", true)) != null),
			"effect": func(state, side, eid, card, targets):
				return (func():
				for c in NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(3))):
					NRHosting.host(state, side, NRCard.get_card(state, card), c, {
				"facedown": true,
			})
				return null
			).call(),
		},
		"abilities": [
			{
			"async": true,
			"fake-cost": [NRPayment.to_c("trash-can")],
			"label": "Install a hosted card",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array((not NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).is_empty())), func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.event(NRCard.get_card(state, _pct)))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCard.get_card(state, _pct), {
					"cost-bonus": -1,
					"no-toast": true,
				}))) != null),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var set_aside_cards = NRSetAside.set_aside(state, side, eid, NRCardXlate.getk(card, "hosted", null))
				return NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, side, ne, card, NRPayment.to_c("trash-can"))
				, func(async_result):
					NREngine.continue_ability(state, side, {
					"prompt": "Choose a set-aside card to install",
					"waiting-prompt": true,
					"not-distinct": true,
					"async": true,
					"choices": func(state, side, eid, card, targets):
						return (func():
						var options = (not NRUtil.as_array(NRUtil.as_array(set_aside_cards).filter(func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.event(_pct))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
						"cost-bonus": -1,
					})))).is_empty())
						return options if options != null else ["Done"]
					).call(),
					"msg": func(state, side, eid, card, targets): return str(((str("trash ") + str(NRUtil.enumerate_cards(set_aside_cards, "sorted"))) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else (str("install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(", lowering its install cost by 1 [Credits]. ") + str(NRUtil.enumerate_cards(remove_once(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets)), set_aside_cards), "sorted")) + str(" are trashed as a result")))),
					"effect": func(state, side, eid, card, targets):
						return (NRMoving.trash_cards(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRUtil.as_array(set_aside_cards).filter(func(_pct, _pct2=null, _pct3=null): return (not (NRUtil.same_card(_pct, NRCardXlate.first_target(targets))))), {
						"unpreventable": true,
						"cause-card": card,
					}) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else NREid.wait_for(state, eid, func(ne):
						NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card})), NRCardXlate.first_target(targets), {
						"cost-bonus": -1,
					})
					, func(async_result):
						NRMoving.trash_cards(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRUtil.as_array(set_aside_cards).filter(func(_pct, _pct2=null, _pct3=null): return (not (NRUtil.same_card(_pct, NRCardXlate.first_target(targets))))), {
						"unpreventable": true,
						"cause-card": card,
					}))),
				}, card, null))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Symmetrical Visage", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Genetics",
		"subtypes": ["Genetics"],
		"text": "The first time you spend [Click] to draw 1 card (not through a card ability) each turn, gain 1[Credits].",
		"code": "08009",
		"title": "Symmetrical Visage",
	}, {
		"events": [
			{
			"event": "runner-click-draw",
			"req": func(state, side, eid, card, targets): return genetics_trigger_p(state, side, "runner-click-draw"),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Synthetic Blood", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Genetics",
		"subtypes": ["Genetics"],
		"text": "The first time you take damage each turn, draw 1 card.",
		"code": "08007",
		"title": "Synthetic Blood",
	}, {
		"events": [
			{
			"event": "damage",
			"req": func(state, side, eid, card, targets): return genetics_trigger_p(state, side, "damage"),
			"msg": "draw 1 card",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Tallie Perrault", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever a <strong>gray ops</strong> or <strong>black ops</strong> operation is trashed after resolving, you may give the Corp 1 bad publicity and take 1 tag.\n[Trash]<strong>:</strong> Draw 1 card for each bad publicity the Corp has.",
		"code": "04083",
		"title": "Tallie Perrault",
	}, {
		"abilities": [
			{
			"label": "Draw 1 card for each bad publicity the Corp has",
			"async": true,
			"cost": [NRPayment.to_c("trash-can")],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.count_bad_pub(state) > 0),
			},
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, NRUtil.count_bad_pub(state)),
			"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify(NRUtil.count_bad_pub(state), "card")),
		},
		],
		"events": [
			{
			"event": "play-operation",
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Black Ops") or NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Gray Ops")),
				"waiting-prompt": true,
				"prompt": "Give the Corp 1 bad publicity and take 1 tag?",
				"yes-ability": {
					"msg": "give the Corp 1 bad publicity and take 1 tag",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRBadPublicity.gain_bad_publicity(state, "corp", 1, {
						"suppress-checkpoint": true,
					})
						return NRTags.gain_tags(state, "runner", eid, 1),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Tech Trader", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever you use a [Trash] ability, gain 1[Credits].",
		"code": "10023",
		"title": "Tech Trader",
	}, {
		"events": [
			{
			"event": "costs-paid",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null))) and (NRUtil.find_first(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "payment", null)).map(func(_x): return bool(NRCardXlate.getk(_x, "paid/type")))), func(_x): return NRUtil.in_coll(["trash-can"], _x)) != null)),
			"msg": "gain 1 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Technical Writer", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Whenever you install a piece of hardware or a program, place 1[Credits] from the bank on Technical Writer.\n[Click],[Trash]: Take all credits from Technical Writer.",
		"code": "09055",
		"title": "Technical Writer",
	}, {
		"events": [
			{
			"event": "runner-install",
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((NRCard.hardware(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) or NRCard.program(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "facedown?", null)))),
			"msg": "place 1 [Credits] on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "credit", 1),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"label": "Take all hosted credits",
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRCard.get_counters(card, "credit")) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, NRCard.get_counters(card, "credit")),
		},
		],
	}))

	NRCardDefs.defcard("Telework Contract", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "When you install this resource, load 9[Credits] onto it. When it is empty, trash it.\nOnce per turn → [Click]<strong>:</strong> Take 3[Credits] from this resource.",
		"code": "30027",
		"title": "Telework Contract",
	}, {
		"data": {
			"counter": {
				"credit": 9,
			},
		},
		"events": [trash_on_empty("credit")],
		"abilities": [
			NRCardXlate.take_n_credits_ability(3, "resource", {
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"once": "per-turn",
		}),
		],
	}))

	NRCardDefs.defcard("Temple of the Liberated Mind", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "[Click]<strong>:</strong> Place 1 power counter on this resource.\nOnce per turn → <strong>Hosted power counter:</strong> Gain [Click]. Use this ability only during your turn.",
		"code": "10082",
		"title": "Temple of the Liberated Mind",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Place 1 power counter",
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
			{
			"label": "Gain [Click]",
			"cost": [NRPayment.to_c("power", 1)],
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(state, "active-player", null) == "runner") or NRUtil.kw_eq(NRCardXlate.getk(state, "active-player", null), "runner")),
			"msg": "gain [Click]",
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		},
		],
	}))

	NRCardDefs.defcard("Temüjin Contract", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "Choose a server and place 20[Credits] from the bank on Temüjin Contract when you install it. When there are no credits left on Temüjin Contract, trash it.\nWhenever you make a successful run on the chosen server, take 4[Credits] from Temüjin Contract.",
		"code": "11026",
		"title": "Temüjin Contract",
	}, {
		"data": {
			"counter": {
				"credit": 20,
			},
		},
		"on-install": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRServers.zones_to_sorted_names(NRBoard.get_zones(state)),
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})),
		},
		"events": [
			trash_on_empty("credit"),
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"req": func(state, side, eid, card, targets): return ((NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == NRCardXlate.getk(NRCard.get_card(state, card), "card-target", null)) or NRUtil.kw_eq(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), NRCardXlate.getk(NRCard.get_card(state, card), "card-target", null))),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(mini(4, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.take_credits(state, side, eid, card, "credit", 4),
		},
		],
	}))

	NRCardDefs.defcard("The Archivist", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "+1[link]\nWhenever the Corp scores an <strong>initiative</strong> or <strong>security</strong> agenda, they must trace[1]. If unsuccessful, give them 1 bad publicity.",
		"code": "12003",
		"title": "The Archivist",
	}, {
		"static-abilities": [link_(1)],
		"events": [
			{
			"event": "agenda-scored",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"trace": {
				"base": 1,
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Initiative") or NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Security")),
				"unsuccessful": {
					"effect": func(state, side, eid, card, targets):
						NRBadPublicity.gain_bad_publicity(state, "corp", 1)
						return NRSay.system_msg(state, "corp", str("takes 1 bad publicity")),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("The Artist", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 5,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Once per turn → [Click]<strong>:</strong> Gain 2[Credits].\nOnce per turn → [Click]<strong>:</strong> Install 1 program or piece of hardware from your grip, paying 1[Credits] less.",
		"code": "26027",
		"title": "The Artist",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Gain 2 [Credits]",
			"msg": "gain 2 [Credits]",
			"once": "per-turn",
			"once-key": "artist-credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-2")
				return NRGaining.gain_credits(state, side, eid, 2),
		},
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Install a program or piece of hardware",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")), func(_pct, _pct2=null, _pct3=null): return ((NRCard.hardware(_pct) or NRCard.program(_pct)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
				"cost-bonus": -1,
			}))) != null),
			"prompt": "Choose a program or piece of hardware to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return ((NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets))) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -1,
				})),
			},
			"once": "per-turn",
			"once-key": "artist-install",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"display-source": true,
				},
				"cost-bonus": -1,
			}),
		},
		],
	}))

	NRCardDefs.defcard("The Back", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Job - Location",
		"subtypes": ["Job", "Location"],
		"text": "The first time each turn you use a piece of hardware during a run, place 1 power counter on this resource.\n[Click], <strong>remove this resource from the game:</strong> For each hosted power counter, choose up to 2 cards in your heap with [Trash] abilities. Shuffle the chosen cards into your stack.",
		"code": "26082",
		"title": "The Back",
	}, {
		"implementation": "Placing power counters is manual",
		"abilities": [
			{
			"label": "Manually place 1 power counter",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, side, (str("manually places 1 power counter on ") + str(NRCardXlate.getk(card, "title", null))))
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
			{
			"action": true,
			"label": "Shuffle back cards with [Trash] abilities",
			"req": func(state, side, eid, card, targets): return ((NRCard.get_counters(card, "power") > 0) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), has_trash_ability_p) != null) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("remove-from-game")],
			"show-discard": true,
			"choices": {
				"max": func(state, side, eid, card, targets):
					return (2 * NRCard.get_counters(card, "power")),
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.in_discard(NRCardXlate.first_target(targets)) and has_trash_ability_p(NRCardXlate.first_target(targets))),
			},
			"msg": func(state, side, eid, card, targets): return str("shuffle ") + str(NRUtil.enumerate_cards(targets, "sorted")) + str(" into the stack"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(func():
				for c in NRUtil.as_array(targets):
					NRMoving.move(state, side, c, "deck")
				return null
			).call()
				NRShuffling.shuffle_zone(state, side, "deck")
				return NREid.effect_completed(state, side, eid),
		},
		],
	}))

	NRCardDefs.defcard("The Black File", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The Corp cannot win the game except if you are flatlined.\nWhen your turn begins, place 1 power counter on this resource. If there are 3 or more hosted power counters, remove this resource from the game.\nLimit 1 per deck.",
		"code": "10099",
		"title": "The Black File",
	}, {
		"on-install": {
			"msg": "prevent the Corp from winning the game unless they are flatlined",
		},
		"static-abilities": [
			{
			"type": "cannot-win-on-points",
			"req": func(state, side, eid, card, targets): return ((("corp" == side) or NRUtil.kw_eq("corp", side)) and (NRCard.get_counters(card, "power") < 3)),
			"value": true,
		},
		],
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRMoving.move(state, side, card, "rfg")
				NRSay.system_msg(state, side, "removes The Black File from the game")
				check_win_by_agenda(state, side)
				return NREid.effect_completed(state, side, eid)
			).call() if (2 <= NRCard.get_counters(card, "power")) else NRProps.add_counter(state, side, eid, card, "power", 1)),
		},
		],
		"on-trash": {
			"effect": func(state, side, eid, card, targets):
				return check_win_by_agenda(state, side),
		},
		"leave-play": func(state, side, eid, card, targets):
			return check_win_by_agenda(state, side),
	}))

	NRCardDefs.defcard("The Class Act", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 5,
		"uniqueness": true,
		"keywords": "Connection - Ritzy",
		"subtypes": ["Connection", "Ritzy"],
		"text": "When a discard phase ends, if you installed this resource this turn, draw 4 cards.\n[interrupt] → The first time each turn you would draw any number of cards, look at the top X cards of your stack. Add 1 of those cards to the bottom of your stack. X is equal to the number of cards you would draw plus 1.",
		"code": "26018",
		"title": "The Class Act",
	}, (func():
		var draw_ability = {
			"req": func(state, side, eid, card, targets): return (("this-turn" == NRCard.installed(card)) or NRUtil.kw_eq("this-turn", NRCard.installed(card))),
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"automatic": "pre-draw-cards",
			"msg": "draw 4 cards",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 4),
		}
		return {
			"events": [
				NRUtil.merge(draw_ability if draw_ability is Dictionary else {}, {"event": "corp-turn-ends"}),
				NRUtil.merge(draw_ability if draw_ability is Dictionary else {}, {"event": "runner-turn-ends"}),
				{
				"event": "pre-runner-draw",
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, "runner", "pre-runner-draw") and (1 < NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).size()) and (NRCardXlate.getk(NRCardXlate.ctx(targets), "count", null) > 0)),
				"once": "per-turn",
				"once-key": "the-class-act-put-bottom",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var cards = NRSetAside.set_aside_for_me(state, "runner", eid, NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int((NRCardXlate.getk(NRCardXlate.ctx(targets), "count", null) + 1))))
					return NREngine.continue_ability(state, side, {
						"waiting-prompt": true,
						"prompt": "Choose 1 card to add to the bottom of the stack",
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRUtil.find_first(NRUtil.as_array(cards), func(c): return NRUtil.same_card(c, _pct)) != null),
							"all": true,
						},
						"msg": {
							"public": func(state, side, eid, card, targets): return str("add the ") + str(verbal_card_index(state, NRCardXlate.first_target(targets))) + str(" card on the top of the stack to the bottom"),
							"runner": func(state, side, eid, card, targets): return str("add the ") + str(verbal_card_index(state, NRCardXlate.first_target(targets))) + str(" card on the top of the stack (") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(") to the bottom"),
						},
						"effect": func(state, side, eid, card, targets):
							return (func():
							for c in NRUtil.as_array((func(_a=NRUtil.as_array(cards)):
							var _b = _a.duplicate()
							_b.reverse()
							return _b
						).call()):
								NRMoving.move(state, "runner", c, "deck", (null if NRUtil.same_card(c, NRCardXlate.first_target(targets)) else {
							"front": true,
						}))
							return null
						).call(),
					}, card, null)
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("The Helpful AI", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection - Link - Virtual",
		"subtypes": ["Connection", "Link", "Virtual"],
		"text": "+1[link]\n[Trash]: Choose an <strong>icebreaker</strong>. That <strong>icebreaker</strong> has +2 strength until the end of the turn.",
		"code": "02008",
		"title": "The Helpful AI",
	}, {
		"static-abilities": [link_(1)],
		"abilities": [
			{
			"msg": func(state, side, eid, card, targets): return str("give +2 strength to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"label": "pump icebreaker",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and NRCard.installed(_pct)),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCardXlate.first_target(targets), 2, "end-of-turn"),
		},
		],
	}))


static func _register_6() -> void:
	NRCardDefs.defcard("The Masque A", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click],[Trash]: Make a run and gain [Click]. If successful, draw 1 card.",
		"code": "14024",
		"title": "The Masque A",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"label": "Make a run and gain [click]. If successful, draw 1 card",
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str(" and gain [click]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, "runner", 1)
				NREngine.register_events(state, side, card, [
				{
				"event": "successful-run",
				"automatic": "draw-cards",
				"unregister-once-resolved": true,
				"duration": "end-of-run",
				"async": true,
				"msg": "draw 1 card",
				"effect": func(state, side, eid, card, targets):
					return NRDrawing.draw(state, "runner", eid, 1),
			},
			])
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		],
	}))

	NRCardDefs.defcard("The Masque B", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click],[Trash]: Make a run and gain [Click]. If that run is successful when it ends, you may immediately make another run on another server.",
		"code": "14025",
		"title": "The Masque B",
	}, {
		"implementation": "Successful run condition not implemented",
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"label": "Make a run and gain [click]. If successful, make another run on another server",
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str(" and gain [click]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 1)
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		],
	}))

	NRCardDefs.defcard("The Nihilist", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 5,
		"uniqueness": true,
		"keywords": "Connection - Seedy",
		"subtypes": ["Connection", "Seedy"],
		"text": "The first time each turn you install a <strong>virus</strong> program, place 2 virus counters on this resource.\nWhen your turn begins, you may remove any 2 virus counters from your installed cards. If you do, draw 2 cards unless the Corp trashes the top card of R&D.",
		"code": "26008",
		"title": "The Nihilist",
	}, (func():
		var corp_choice = {
			"player": "corp",
			"waiting-prompt": true,
			"prompt": "Choose one",
			"choices": func(state, side, eid, card, targets):
				return [
				("Trash the top card of R&D" if (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()) else null),
				"The Runner draws 2 cards",
			],
			"async": true,
			"msg": func(state, side, eid, card, targets): return str(("draw 2 cards" if ((NRCardXlate.first_target(targets) == "The Runner draws 2 cards") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "The Runner draws 2 cards")) else (str("force the Corp to ") + str(decapitalize(NRCardXlate.first_target(targets)))))),
			"effect": func(state, side, eid, card, targets):
				return (NRDrawing.draw(state, "runner", eid, 2) if ((NRCardXlate.first_target(targets) == "The Runner draws 2 cards") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "The Runner draws 2 cards")) else NRMoving.mill(state, "corp", eid, "corp", 1)),
		}
		var maybe_spend_2 = {
			"event": "runner-turn-begins",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Spend 2 virus counters?",
				"yes-ability": {
					"req": func(state, side, eid, card, targets): return (2 <= NRVirus.number_of_runner_virus_counters(state)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, pick_virus_counters_to_spend(2), card, null)
					, func(async_result):
						((func():
						NRSay.system_msg(state, side, (str("spends ") + str(NRCardXlate.getk(async_result, "msg", null))))
						return NREngine.continue_ability(state, side, corp_choice, card, null)
					).call() if NRCardXlate.getk(async_result, "msg", null) else NREid.effect_completed(state, side, eid))),
				},
			},
		}
		return {
			"events": [
				maybe_spend_2,
				{
				"event": "runner-install",
				"once": "per-turn",
				"msg": "place 2 virus counters on itself",
				"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Virus"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "virus", 2),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("The Shadow Net", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "[Click]<strong>, forfeit an agenda:</strong> Play an event from your heap, ignoring all costs.",
		"code": "13027",
		"title": "The Shadow Net",
	}, (func():
		return {
			"abilities": [
				{
				"action": true,
				"async": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("forfeit")],
				"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(events(state.getv("runner", {}))).size() > 0) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
				"label": "Play an event from the heap, ignoring all costs",
				"prompt": "Choose an event to play",
				"msg": func(state, side, eid, card, targets): return str("play ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the heap, ignoring all costs"),
				"choices": func(state, side, eid, card, targets):
					return events(state.getv("runner", {})),
				"effect": func(state, side, eid, card, targets):
					return NRPlayInstants.play_instant(state, side, eid, NRCardXlate.first_target(targets), {
					"ignore-cost": true,
				}),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("The Source", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "The advancement requirement of all agendas is increased by 1.\nAs an additional cost to steal an agenda, you must pay 3[Credits].\nTrash The Source when an agenda is scored or stolen.",
		"code": "03055",
		"title": "The Source",
	}, {
		"static-abilities": [
			{
			"type": "advancement-requirement",
			"value": 1,
		},
			{
			"type": "steal-additional-cost",
			"value": func(state, side, eid, card, targets):
				return NRPayment.to_c("credit", 3),
		},
		],
		"events": [
			{
			"event": "agenda-scored",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, card, {
				"cause": "runner-ability",
				"cause-card": card,
			}),
		},
			{
			"event": "agenda-stolen",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, card, {
				"cause": "runner-ability",
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("The Supplier", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "[Click]: Host a resource or piece of hardware from your grip on The Supplier.\nWhen your turn begins, you may install a hosted card, lowering the install cost by 2.",
		"code": "06056",
		"title": "The Supplier",
	}, (func():
		var ability = {
			"label": "Install a hosted card (start of turn)",
			"skippable": true,
			"prompt": "Choose a hosted card to install",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)), func(_pct, _pct2=null, _pct3=null): return NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
				"cost-bonus": -2,
			})) != null),
			"choices": {
				"req": func(state, side, eid, card, targets): return ((("The Supplier" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null), "title", null)) or NRUtil.kw_eq("The Supplier", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.first_target(targets), "host", null), "title", null))) and NRCard.runner(NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -2,
				})),
			},
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.effect_completed(state, side, eid) if (not (NRInstalling.runner_can_install(state, side, eid, NRCardXlate.first_target(targets), null))) else (func():
				NRUpdate.update_card(state, side, NRUtil.update_in(NRUtil.merge(card if card is Dictionary else {}, {"supplier-installed": NRCardXlate.getk(NRCardXlate.first_target(targets), "cid", null)}), ["hosted"], func(coll): return remove_once(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets)), coll)))
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -2,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				})
			).call()),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"abilities": [
				{
				"action": true,
				"label": "Host a resource or piece of hardware",
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"prompt": "Choose a card in the grip",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return ((NRCard.hardware(_pct) or NRCard.resource(_pct)) and NRCard.in_hand(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					return NRHosting.host(state, side, card, NRCardXlate.first_target(targets)),
				"msg": func(state, side, eid, card, targets): return str("install and host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			},
				ability,
			],
			"suppress": [
				{
				"event": "runner-turn-begins",
				"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.first_target(targets), "cid", null) == NRCardXlate.getk(NRCard.get_card(state, card), "supplier-installed", null)) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "cid", null), NRCardXlate.getk(NRCard.get_card(state, card), "supplier-installed", null))),
			},
			],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				{
				"event": "runner-turn-ends",
				"silent": true,
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(card, "supplier-installed", null),
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.dissoc(card if card is Dictionary else {}, ["supplier-installed"])),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("The Turning Wheel", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "Whenever a run on HQ or R&D ends, place 1 power counter on this resource if you stole no agendas during that run.\n<strong>2 hosted power counters:</strong> Choose HQ or R&D. For the remainder of this run, access 1 additional card whenever you breach that server.",
		"code": "10085",
		"title": "The Turning Wheel",
	}, (func():
		var _b0 = ttw_bounce([name, server], {
			"action": true,
			"label": (str("Shortcut: Bounce ") + str(name)),
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"msg": func(state, side, eid, card, targets): return str("bounce off of ") + str(name) + str(" for a counter (shortcut)"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				state.assoc_in(["runner", "register", "made-click-run"], true)
				state.update_in(["runner", "register", "unsuccessful-run"], func(v): return v, 0)
				state.update_in(["runner", "register", "made-run"], func(v): return v, 0)
				return NRProps.add_counter(state, "runner", eid, card, "power", 1),
		})
		return {
			"events": [
				{
				"event": "run-ends",
				"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(NRCardXlate.ctx(targets), "did-steal", null))) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), func(_x): return NRUtil.in_coll(["hq", "rd"], _x)) != null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
				"silent": true,
			},
			],
			"abilities": [
				ttw_ab("R&D", "rd"),
				ttw_ab("HQ", "hq"),
				ttw_bounce("R&D", "rd"),
				ttw_bounce("HQ", "hq"),
			],
		}
	).call()))

	NRCardDefs.defcard("The Twinning", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The first time each turn you spend credits from an installed card, place 1 power counter on this resource.\nWhenever you breach HQ or R&D, you may remove up to 2 hosted power counters to access that many additional cards.",
		"code": "33010",
		"title": "The Twinning",
	}, {
		"events": [
			{
			"event": "spent-credits-from-card",
			"req": func(state, side, eid, card, targets): return (func():
				return ((NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return valid_ctx_p([_pct])) != null) and NREvents.first_event(state, side, "spent-credits-from-card", valid_ctx_p))
			).call(),
			"once-per-instance": true,
			"async": true,
			"msg": "place a power counter on itself",
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "power", 1, {
				"placed": true,
			}),
		},
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return NRUtil.in_coll(["rd", "hq"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "power") > 0),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var target_server = NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)
				return NREngine.continue_ability(state, side, {
					"prompt": func(state, side, eid, card, targets): return str("How many additional ") + str(NRServers.zone_to_name(NRServers.target_server)) + str(" accesses do you want to make?"),
					"choices": {
						"number": func(state, side, eid, card, targets):
							return mini(2, NRCard.get_counters(card, "power")),
						"default": func(state, side, eid, card, targets):
							return mini(2, NRCard.get_counters(card, "power")),
					},
					"msg": func(state, side, eid, card, targets): return str("access ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "additional card")) + str(" from ") + str(NRServers.zone_to_name(NRServers.target_server)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRAccess.access_bonus(state, side, NRServers.target_server, maxi(0, NRCardXlate.first_target(targets)))
						return NRProps.add_counter(state, "runner", eid, card, "power", (-NRCardXlate.first_target(targets)), {
						"placed": true,
					}),
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Theophilius Bagbiter", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When you install Theophilius Bagbiter, lose all credits in your credit pool.\nYour maximum hand size is equal to the number of credits in your credit pool.",
		"code": "05049",
		"title": "Theophilius Bagbiter",
	}, {
		"static-abilities": [
			runner_hand_size_(func(state, side, eid, card, targets):
			return NRCardXlate.getk(state.getv("runner", {}), "credit", null)),
		],
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				state.assoc_in(["runner", "hand-size", "base"], 0)
				return NRGaining.lose_credits(state, "runner", eid, "all"),
		},
		"leave-play": func(state, side, eid, card, targets):
			return state.assoc_in(["runner", "hand-size", "base"], 5),
	}))

	NRCardDefs.defcard("Thunder Art Gallery", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Location - Ritzy",
		"subtypes": ["Location", "Ritzy"],
		"text": "The first time you avoid or remove a tag each turn, you may install a card from your grip, lowering its install cost by 1.",
		"code": "22013",
		"title": "Thunder Art Gallery",
	}, (func():
		var first_event_check = func(state, fn1, fn2): return (fn1(state, "runner", "runner-lose-tag", func(_p): return (("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null)))) and fn2(state, "runner", "runner-prevent", func(_p): return (("tag" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("tag", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)))))
		var ability = {
			"async": true,
			"prompt": "Choose a card in the grip",
			"waiting-prompt": true,
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.in_hand(NRCardXlate.first_target(targets)) and (not (NRCard.event(NRCardXlate.first_target(targets)))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -1,
				})),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"cost-bonus": -1,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-lose-tag"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-prevent"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Tri-maf Contact", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "You cannot use this resource more than once per turn.\n[Click]<strong>:</strong> Gain 2[Credits].\nWhen this resource is trashed, suffer 3 meat damage.",
		"code": "05050",
		"title": "Tri-maf Contact",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"msg": "gain 2 [Credits]",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-2")
				return NRGaining.gain_credits(state, side, eid, 2),
		},
		],
		"on-trash": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "meat", 3, {
				"unboostable": true,
				"card": card,
			}),
		},
	}))

	NRCardDefs.defcard("Trickster Taka", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Companion - Stealth - Virtual",
		"subtypes": ["Companion", "Stealth", "Virtual"],
		"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nYou can spend hosted credits to use programs during runs.\nWhen your turn ends, if there are 3 or more hosted credits, you must take 1 tag or trash this resource.",
		"code": "26009",
		"title": "Trickster Taka",
	}, companion_builder(func(state, side, eid, card, targets):
		return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.program(NRCardXlate.first_target(targets)) and state.getv("run")), {
		"prompt": "Choose one",
		"waiting-prompt": true,
		"choices": ["Take 1 tag", "Trash Trickster Taka"],
		"msg": func(state, side, eid, card, targets): return str(("trash itself" if ((NRCardXlate.first_target(targets) == "Trash Trickster Taka") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Trickster Taka")) else decapitalize(NRCardXlate.first_target(targets)))),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return (NRMoving.trash(state, "runner", eid, card, {
			"cause-card": card,
		}) if ((NRCardXlate.first_target(targets) == "Trash Trickster Taka") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Trash Trickster Taka")) else NRTags.gain_tags(state, "runner", eid, 1)),
	}, {
		"req": func(state, side, eid, card, targets): return ((NRCard.get_counters(NRCard.get_card(state, card), "credit") > 0) and state.getv("run") and (not (NRCardXlate.getk(state.getv("run"), "successful", null))) and (not (NRCardXlate.getk(state.getv("run"), "unsuccessful", null)))),
		"msg": "take 1 [Credits]",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return spend_credits(state, side, eid, card, "credit", 1),
	})))

	NRCardDefs.defcard("Tsakhia \"Bankhar\" Gantulga", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, you may choose a server.\nDuring the first encounter each turn with a piece of ice protecting the chosen server, whenever the Corp would resolve a subroutine, instead they resolve \"[subroutine] Do 1 net damage.\".",
		"code": "33074",
		"title": "Tsakhia \"Bankhar\" Gantulga",
	}, (func():
		var sub = {
			"variable": true,
			"sub-effect": {
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(state, "corp", eid, "net", 1, {
					"card": card,
					"cause": "subroutine",
				}),
				"label": "Do 1 net damage",
				"async": true,
				"msg": "do 1 net damage",
			},
		}
		var matches_server = func(target, card, state, side): return ((NRCardXlate.getk(card, "card-target", null) == NRServers.zone_to_name((NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null))) or NRUtil.kw_eq(NRCardXlate.getk(card, "card-target", null), NRServers.zone_to_name((NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null))))
		var ability = {
			"prompt": "Choose a server",
			"label": "Choose a server (start of turn)",
			"skippable": true,
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array(NRServers.zones_to_sorted_names(NRBoard.get_zones(state))) + NRUtil.as_array(["No server"])),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "runner-phase-12", null) and (not (used_this_turn_p(NRCardXlate.getk(card, "cid", null), state)))),
			"effect": func(state, side, eid, card, targets):
				return (NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})) if (not (((NRCardXlate.first_target(targets) == "No server") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "No server")))) else null),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				{
				"event": "encounter-ice",
				"req": func(state, side, eid, card, targets): return (matches_server(NRCardXlate.getk(NRCardXlate.first_target(targets), "ice", null), card, state, side) and NREvents.first_event(state, side, "encounter-ice", func(_pct, _pct2=null, _pct3=null): return matches_server(NRCardXlate.getk(NRUtil.first_of(_pct), "ice", null), card, state, side))),
				"effect": func(state, side, eid, card, targets):
					return NREngine.register_events(state, side, card, (func():
					var target_ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
					return [
						{
						"event": "pre-resolve-subroutine",
						"duration": "end-of-encounter",
						"async": true,
						"req": func(state, side, eid, card, targets): return NRCard.get_card(state, target_ice),
						"msg": "force the Corp to resolve \"[Subroutine] Do 1 net damage\"",
						"effect": func(state, side, eid, card, targets):
							NRRuns.update_current_encounter(state, "replace-subroutine", sub)
							return NREid.effect_completed(state, side, eid),
					},
					]
				).call()),
			},
				{
				"event": "runner-turn-ends",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.dissoc(card if card is Dictionary else {}, ["card-target"])),
			},
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Tyson Observatory", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "[Click], [Click]: Search your stack for a piece of hardware, reveal it, and add it to your grip. Shuffle your stack.",
		"code": "08030",
		"title": "Tyson Observatory",
	}, {
		"abilities": [
			{
			"action": true,
			"prompt": "Choose a piece of Hardware",
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to [their] Grip"),
			"label": "Search stack for a piece of hardware",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(NRCard.hardware),
			"cost": [NRPayment.to_c("click", 2)],
			"cancel": NRUtil.merge(fail_to_find_bang if fail_to_find_bang is Dictionary else {}, {"cost": [NRPayment.to_c("click", 2)]}),
			"keep-menu-open": "while-2-clicks-left",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
		},
		],
	}))

	NRCardDefs.defcard("Underdome Irregulars", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your action phase ends, if a piece of ice was rezzed this turn, draw 2 cards or remove 1 tag. If no ice was rezzed this turn, trash this resource.",
		"code": "36016",
		"title": "Underdome Irregulars",
	}, {
		"events": [
			{
			"event": "runner-action-phase-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, ({
				"msg": "trash itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, card),
			} if NREvents.no_event(state, "corp", "rez", func(_pct, _pct2=null, _pct3=null): return NRCard.ice(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))) else NRChooseOne.choose_one({
				"event": "runner-action-phase-ends",
				"interactive": func(state, side, eid, card, targets):
					return true,
			}, [
				{
				"option": "Draw 2 cards",
				"ability": {
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(state.get_in(["runner", "deck"], null)).is_empty()),
					},
					"msg": "draw 2 cards",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, side, eid, 2),
				},
			},
				{
				"option": "Remove 1 tag",
				"ability": {
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
					},
					"msg": "remove 1 tag",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRTags.lose_tags(state, side, eid, 1),
				},
			},
			])), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Underworld Contact", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "When your turn begins, gain 1[Credits] if you have at least 2[link].",
		"code": "20060",
		"title": "Underworld Contact",
	}, (func():
		var ability = {
			"label": "Gain 1 [Credits] (start of turn)",
			"once": "per-turn",
			"automatic": "gain-credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to gain 1 [Credits]")))
				return NRGaining.gain_credits(state, "runner", eid, 1)
			).call() if ((2 <= NRLink.get_link(state)) and NRCardXlate.getk(state, "runner-phase-12", null)) else NREid.effect_completed(state, side, eid)),
		}
		return {
			"flags": {
				"drip-economy": true,
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Urban Art Vernissage", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Job - Ritzy",
		"subtypes": ["Job", "Ritzy"],
		"text": "When your turn begins, you may add 1 installed non-<strong>virus</strong> <strong>trojan</strong> program to your grip. If you do, place 2[Credits] on this resource.\nYou can spend hosted credits to install cards.",
		"code": "34029",
		"title": "Urban Art Vernissage",
	}, (func():
		var is_eligible_p = func(cr): return (NRCard.program(cr) and NRCard.has_subtype(cr, "Trojan") and (not (NRCard.has_subtype(cr, "Virus"))))
		var ability = {
			"async": true,
			"label": "Return a non-virus trojan program to the grip",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(all_installed_runner(state)), is_eligible_p) != null),
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets)) and is_eligible_p(NRCardXlate.first_target(targets))),
			},
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to the grip and place 2 [Credits] on itself"),
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				return NRProps.add_counter(state, side, eid, card, "credit", 2),
		}
		return {
			"interactions": {
				"pay-credits": {
					"req": func(state, side, eid, card, targets): return (("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))),
					"type": "credit",
				},
			},
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return (NRUtil.find_first(NRUtil.as_array(all_installed_runner(state)), is_eligible_p) != null),
			},
			"events": [NRUtil.merge(ability if ability is Dictionary else {}, {"skippable": true})],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Utopia Shard", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 7,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Virtual - Source",
		"subtypes": ["Virtual", "Source"],
		"text": "Whenever you make a successful run on HQ, instead of breaching HQ, you may install this resource from your grip, ignoring all costs.\n<strong>[Trash]:</strong> The Corp discards 2 cards from HQ at random.\nLimit 1 per deck.",
		"code": "06100",
		"title": "Utopia Shard",
	}, shard_constructor("Utopia Shard", "hq", "force the Corp to discard 2 cards from HQ at random", func(state, side, eid, card, targets):
		return NRMoving.trash_cards(state, "corp", eid, NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(2)), {
		"cause-card": card,
	}))))

	NRCardDefs.defcard("Valentina Ferreira Carvalho", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever you remove 1 or more tags, gain 1[Credits].\nThreat 3 → When you install this resource during your turn, you may remove 1 tag or gain 2[Credits]. <em>(This ability is active if any player has 3 or more agenda points.)</em>",
		"code": "34095",
		"title": "Valentina Ferreira Carvalho",
	}, {
		"on-install": {
			"prompt": "Choose one",
			"choices": func(state, side, eid, card, targets):
				return [
				("Remove 1 tag" if NRUtil.is_tagged(state) else null),
				"Gain 2 [Credits]",
				"Done",
			],
			"req": func(state, side, eid, card, targets): return (NRThreat.threat_level(3, state) and ((NRCardXlate.getk(state, "active-player", null) == "runner") or NRUtil.kw_eq(NRCardXlate.getk(state, "active-player", null), "runner"))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRTags.lose_tags(state, "runner", eid, 1)
				return NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to ") + str(decapitalize(NRCardXlate.first_target(targets)))))
			).call() if (("Remove 1 tag" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Remove 1 tag", NRCardXlate.first_target(targets))) else ((func():
				NRGaining.gain_credits(state, "runner", eid, 2)
				return NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to ") + str(decapitalize(NRCardXlate.first_target(targets)))))
			).call() if (("Gain 2 [Credits]" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Gain 2 [Credits]", NRCardXlate.first_target(targets))) else NREid.effect_completed(state, side, eid))),
		},
		"events": [
			{
			"event": "runner-lose-tag",
			"req": func(state, side, eid, card, targets): return ((("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null))) and (NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null) > 0)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Verbal Plasticity", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Genetics",
		"subtypes": ["Genetics"],
		"text": "The first time each turn you take the basic action to draw 1 card, instead draw 2 cards.",
		"code": "30034",
		"title": "Verbal Plasticity",
	}, {
		"events": [
			{
			"event": "runner-click-draw",
			"req": func(state, side, eid, card, targets): return genetics_trigger_p(state, side, "runner-click-draw"),
			"msg": "draw 1 additional card",
			"effect": func(state, side, eid, card, targets):
				return click_draw_bonus(state, side, 1),
		},
		],
	}))

	NRCardDefs.defcard("Virus Breeding Ground", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "When your turn begins, place 1 virus counter on Virus Breeding Ground.\n[Click]: Move 1 virus counter on Virus Breeding Ground to another card with at least 1 virus counter on it.",
		"code": "07052",
		"title": "Virus Breeding Ground",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "move hosted virus counter",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "virus") > 0),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"msg": func(state, side, eid, card, targets): return str("move 1 virus counter to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"choices": {
					"not-self": true,
					"card": func(_pct, _pct2=null, _pct3=null): return (NRVirus.get_virus_counters(state, _pct) > 0),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return move_virus_counter(state, side, eid, card, NRCardXlate.first_target(targets), 1),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Wasteland", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Apex",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Location - Virtual",
		"subtypes": ["Location", "Virtual"],
		"text": "The first time each turn you trash 1 of your installed cards, gain 1[Credits].",
		"code": "09036",
		"title": "Wasteland",
	}, {
		"events": [
			{
			"event": "runner-trash",
			"once-per-instance": true,
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p(targets) and NREvents.first_event(state, side, "runner-trash", valid_ctx_p))
			).call(),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Whistleblower", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Connection",
		"subtypes": ["Connection"],
		"text": "Whenever you make a successful run, you may trash this resource to choose a card name. The next time this run you access an agenda with the chosen name, steal it, ignoring all costs. <em>(You are no longer accessing it.)</em>",
		"code": "26030",
		"title": "Whistleblower",
	}, {
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"optional": {
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"prompt": "Name an agenda?",
				"yes-ability": {
					"async": true,
					"prompt": "Name an agenda",
					"choices": {
						"card-title": func(state, side, eid, card, targets):
							return (NRCard.corp(NRCardXlate.first_target(targets)) and NRCard.agenda(NRCardXlate.first_target(targets))),
					},
					"effect": func(state, side, eid, card, targets):
						NRSay.system_msg(state, side, (str("trashes ") + str(NRCardXlate.getk(card, "title", null)) + str(" to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to name ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))))
						NREngine.register_events(state, side, card, (func():
						var named_agenda = NRCardXlate.first_target(targets)
						return [
							{
							"event": "access",
							"duration": "end-of-run",
							"unregister-once-resolved": true,
							"async": true,
							"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null) == named_agenda) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null), named_agenda)),
							"effect": func(state, side, eid, card, targets):
								return NRAccess.steal(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)),
						},
						]
					).call())
						return NRMoving.trash(state, side, eid, card, {
						"unpreventable": true,
						"cause-card": card,
					}),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Whistleblower")],
	}))

	NRCardDefs.defcard("Wireless Net Pavilion", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": true,
		"keywords": "Location",
		"subtypes": ["Location"],
		"text": "As an additional cost to take the basic action to trash 1 installed resource, the Corp must pay 2[Credits].",
		"code": "08108",
		"title": "Wireless Net Pavilion",
	}, {
		"implementation": "[Erratum] Should be unique",
		"static-abilities": [
			{
			"type": "card-ability-additional-cost",
			"req": func(state, side, eid, card, targets): return (NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(state.getv("corp", {}), "basic-action-card", null)) and (("Trash 1 resource if the Runner is tagged" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)) or NRUtil.kw_eq("Trash 1 resource if the Runner is tagged", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)))),
			"value": NRPayment.to_c("credit", 2),
		},
		],
	}))

	NRCardDefs.defcard("Woman in the Red Dress", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": true,
		"keywords": "Connection - Virtual",
		"subtypes": ["Connection", "Virtual"],
		"text": "When your turn begins, reveal the top card of R&D. The Corp may draw that card.",
		"code": "04048",
		"title": "Woman in the Red Dress",
	}, (func():
		var ability = {
			"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null)) + str(" from the top of R&D"),
			"label": "Reveal the top card of R&D (start of turn)",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRevealing.reveal(state, side, ne, NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)))
			, func(async_result):
				NREngine.continue_ability(state, side, {
				"optional": {
					"player": "corp",
					"waiting-prompt": true,
					"prompt": func(state, side, eid, card, targets): return str("Draw ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null)) + str("?"),
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							NRSay.system_msg(state, side, (str("draws ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null))))
							return NRDrawing.draw(state, side, eid, 1),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
					},
				},
			}, card, null)),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Word on the Street", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": true,
		"text": "As an additional cost to score an agenda the Corp installed this turn, they must add this resource to their score area as an agenda worth −1 agenda points with “You cannot forfeit this agenda.”.\nWhen the Corp scores an agenda they did not install this turn, trash this resource, gain 4[Credits], and draw 1 card.",
		"code": "36025",
		"title": "Word on the Street",
	}, {
		"events": [
			{
			"event": "pre-agenda-scored",
			"req": func(state, side, eid, card, targets): return (("this-turn" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "scored-card", null), "installed", null)) or NRUtil.kw_eq("this-turn", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "scored-card", null), "installed", null))),
			"msg": "add itself to the score area as an agenda worth -1 agenda points",
			"display-side": "corp",
			"effect": func(state, side, eid, card, targets):
				return (func():
				var fake_gendie = NRMoving.as_agenda(state, "corp", card, -1)
				return NRUpdate.update_card(state, "corp", NRUtil.assoc_in(fake_gendie if fake_gendie is Dictionary else {}, ["flags", "cannot-forfeit"], true))
			).call(),
		},
			{
			"event": "agenda-scored",
			"msg": "trash itself, gain 4 [Credits] and draw a card",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, side, ne, card, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 4, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRDrawing.draw(state, side, eid, 1))),
			"async": true,
		},
		],
	}))

	NRCardDefs.defcard("Wyldside", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": true,
		"keywords": "Location - Seedy",
		"subtypes": ["Location", "Seedy"],
		"text": "When your turn begins, draw 2 cards and lose [Click].",
		"code": "01016",
		"title": "Wyldside",
	}, (func():
		var ab = {
			"msg": "draw 2 cards and lose [Click]",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.lose_clicks(state, side, 1)
				return NRDrawing.draw(state, side, eid, 2),
		}
		return {
			"flags": {
				"runner-turn-draw": true,
				"runner-phase-12": func(state, side, eid, card, targets):
					return (1 < NRUtil.as_array(NRUtil.as_array(([state.get_in(["runner", "identity"], null)] + NRUtil.as_array(NRBoard.all_active_installed(state, "runner")))).filter(func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-turn-draw", true))).size()),
			},
			"events": [NRUtil.merge(ab if ab is Dictionary else {}, {"event": "runner-turn-begins"})],
			"abilities": [ab],
		}
	).call()))

	NRCardDefs.defcard("Xanadu", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Virtual",
		"subtypes": ["Virtual"],
		"text": "The rez cost of each piece of ice is increased by 1[Credits].",
		"code": "31012",
		"title": "Xanadu",
	}, {
		"static-abilities": [
			{
			"type": "rez-cost",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.first_target(targets)),
			"value": 1,
		},
		],
	}))

	NRCardDefs.defcard("Zona Sul Shipping", NRCardXlate.merge_cdef({
		"type": "Resource",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Place 1[Credits] on Zona Sul Shipping when your turn begins.\n[Click]: Take all credits from Zona Sul Shipping.\nTrash Zona Sul Shipping if you are tagged.",
		"code": "06097",
		"title": "Zona Sul Shipping",
	}, trash_when_tagged("Zona Sul Shipping", {
		"events": [
			{
			"event": "runner-turn-begins",
			"automatic": "gain-credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "credit", 1),
		},
		],
		"abilities": [
			take_all_credits_ability({
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
		}),
		],
	})))


