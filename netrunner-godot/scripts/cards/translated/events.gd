class_name NRCardsEvents
extends RefCounted

## Port of game.cards.events — translated from Jinteki.net Clojure.
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


static func cutlery(subtype):
	return {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "subroutines-broken",
			"async": true,
			"req": func(state, side, eid, card, targets): return (func():
				var pred = func(_x): return ((func(_x): return bool(NRCardXlate.getk(_x, "all-subs-broken"))).call(_x)) and ((func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(NRCardXlate.getk(_pct, "ice", null), subtype)).call(_x))
				return (pred(NRCardXlate.ctx(targets)) and NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and NREvents.first_run_event(state, side, "subroutines-broken", func(_pct, _pct2=null, _pct3=null): return pred(NRUtil.first_of(_pct))))
			).call(),
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), {
				"cause-card": card,
			}),
		},
		],
	}


static func _register_1() -> void:
	NRCardDefs.defcard("Account Siphon", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, you may force the Corp to lose up to 5[Credits], then you gain 2[Credits] for each credit lost and take 2 tags.",
		"code": "01018",
		"title": "Account Siphon",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"ability": NRCardXlate.drain_credits("runner", "corp", 5, 2, 2),
		}),
		],
	}))

	NRCardDefs.defcard("Aircheck", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run - Stealth",
		"subtypes": ["Run", "Stealth"],
		"text": "Place 4[Credits] on this event. While this event is active, you can spend hosted credits, and you cannot lose or spend credits from your credit pool.\nRun HQ or R&D.\nWhen that run ends, if it was successful, you may run a remote server.",
		"code": "36018",
		"title": "Aircheck",
	}, {
		"makes-run": true,
		"data": {
			"counter": {
				"credit": 4,
			},
		},
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
		"static-abilities": [
			{
			"type": "cannot-pay-credits-from-pool",
			"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
			"value": true,
		},
			{
			"type": "cannot-lose-credits",
			"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
			"value": true,
		},
		],
		"on-play": NRCardXlate.run_server_from_choices_ability(["HQ", "R&D"], {
			"events": [
				{
				"event": "run-ends",
				"unregister-once-resolved": true,
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "successful", null) and NRCardXlate.this_card_run(state, card, targets) and (((["hq"] == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq(["hq"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) or ((["rd"] == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq(["rd"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))))),
				"prompt": "Choose a remote server to run",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_remote)).map(NRServers.remote_to_name),
				"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
			},
			],
		}),
	}))

	NRCardDefs.defcard("Always Have a Backup Plan", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. When that run ends, if it was unsuccessful, you may run the attacked server again, ignoring any additional costs to run. During the second run, whenever you encounter the last piece of ice you encountered during the first run, bypass it.",
		"code": "26011",
		"title": "Always Have a Backup Plan",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"change-on-game-state": func(state, side, eid, card, targets):
				return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRuns.make_run(state, side, ne, NRCardXlate.first_target(targets), card)
			, func(async_result):
				(func():
				var card = NRCard.get_card(state, card)
				var run_again = NRUtil.get_in(card, ["special", "run-again"], null)
				return (NRRuns.make_run(state, side, eid, run_again, card, {
					"ignore-costs": true,
				}) if run_again else NREid.effect_completed(state, side, eid))
			).call()),
		},
		"events": [
			{
			"event": "run-ends",
			"optional": {
				"req": func(state, side, eid, card, targets): return ((not (NRUtil.get_in(card, ["special", "run-again"], null))) and NRCardXlate.getk(NRCardXlate.first_target(targets), "unsuccessful", null)),
				"prompt": "Make another run on the same server?",
				"yes-ability": {
					"effect": func(state, side, eid, card, targets):
						return (func():
						var last_run = state.get_in(["runner", "register", "last-run"], null)
						var attacked_server = NRUtil.first_of(NRCardXlate.getk(last_run, "server", null))
						var ice = NRCardXlate.getk(ffirst(NREvents.run_events(last_run, "encounter-ice")), "ice", null)
						return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {}))
					).call(),
				},
			},
		},
			{
			"event": "encounter-ice",
			"automatic": "bypass",
			"once": "per-run",
			"req": func(state, side, eid, card, targets): return (NRUtil.get_in(card, ["special", "run-again"], null) and NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), NRUtil.get_in(card, ["special", "run-again-ice"], null))),
			"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.bypass_ice(state),
		},
		],
	}))

	NRCardDefs.defcard("Amped Up", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Gain [Click][Click][Click] and suffer 1 core damage. This damage cannot be prevented.",
		"code": "07031",
		"title": "Amped Up",
	}, {
		"on-play": {
			"msg": "gain [Click][Click][Click] and suffer 1 core damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 3)
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"unpreventable": true,
				"card": card,
			}),
		},
	}))

	NRCardDefs.defcard("Another Day, Another Paycheck", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhenever you steal an agenda, force the Corp to \"Trace[0]. If unsuccessful, the Runner gains credits equal to the number of agenda points in both players' score areas.\"",
		"code": "11007",
		"title": "Another Day, Another Paycheck",
	}, {
		"events": [
			{
			"event": "agenda-stolen",
			"trace": {
				"base": 0,
				"unsuccessful": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "runner", eid, (NRCardXlate.getk(state.getv("runner", {}), "agenda-point", null) + NRCardXlate.getk(state.getv("corp", {}), "agenda-point", null))),
					"msg": func(state, side, eid, card, targets): return str((str("gain ") + str((NRCardXlate.getk(state.getv("runner", {}), "agenda-point", null) + NRCardXlate.getk(state.getv("corp", {}), "agenda-point", null))) + str(" [Credits]"))),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Apocalypse", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Apex",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Play only if you made a successful run on HQ, R&D and Archives this turn.\nTrash all installed Corp cards. Turn all installed Runner cards facedown.",
		"code": "09030",
		"title": "Apocalypse",
	}, (func():
		var corp_trash = {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var ai = NRBoard.all_installed(state, "corp")
				var onhost = NRUtil.as_array(ai).filter(func(_pct, _pct2=null, _pct3=null): return ((["onhost"] == NRCardXlate.getk(_pct, "zone", null)) or NRUtil.kw_eq(["onhost"], NRCardXlate.getk(_pct, "zone", null))))
				var unhosted = (func(_a=NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(ai).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((["onhost"] == NRCardXlate.getk(_pct, "zone", null)) or NRUtil.kw_eq(["onhost"], NRCardXlate.getk(_pct, "zone", null)))).call(_x)))))):
					var _b = _a.duplicate()
					_b.reverse()
					return _b
				).call()
				var allcorp = (NRUtil.as_array(onhost) + NRUtil.as_array(unhosted))
				return NRMoving.trash_cards(state, "runner", eid, allcorp, {
					"cause-card": card,
				})
			).call(),
		}
		var runner_facedown = {
			"effect": func(state, side, eid, card, targets):
				return (func():
				var installedcards = NRBoard.all_active_installed(state, "runner")
				var ishosted = func(c): return ((["onhost"] == (c.get("zone") if c is Dictionary else null)) or NRUtil.kw_eq(["onhost"], (c.get("zone") if c is Dictionary else null)))
				var hostedcards = NRUtil.as_array(installedcards).filter(ishosted)
				var nonhostedcards = NRUtil.as_array(installedcards).filter(func(_x): return not ((ishosted).call(_x)))
				return (func():
					(func():
						for oc in NRUtil.as_array(hostedcards):
							NRMoving.flip_facedown(state, side, c)
						return null
					).call()
					return (func():
						for oc in NRUtil.as_array(nonhostedcards):
							NRMoving.flip_facedown(state, side, c)
						return null
					).call()
				).call()
			).call(),
		}
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
				"async": true,
				"msg": "trash all installed Corp cards and turn all installed Runner cards facedown",
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, corp_trash, card, null)
				, func(async_result):
					NREngine.continue_ability(state, side, runner_facedown, card, null)),
			},
		}
	).call()))

	NRCardDefs.defcard("Ashen Epilogue", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 5,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Shuffle your grip and heap into your stack, then remove the top 5 cards of your stack from the game. Draw 5 cards.\nRemove this event from the game.",
		"code": "34094",
		"title": "Ashen Epilogue",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str(("shuffle the grip and heap into the stack" if (not (NRFlags.zone_locked(state, "runner", "discard"))) else "shuffle the grip into the stack")),
			"rfg-instead-of-trashing": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRShuffling.shuffle_into_deck(state, "runner", "hand", "discard")
				return (func():
				var top_5 = NRUtil.take_n(NRUtil.as_array(state.get_in(["runner", "deck"], null)), int(5))
				return (func():
					(func():
						for c in NRUtil.as_array(top_5):
							NRMoving.move(state, side, c, "rfg")
						return null
					).call()
					NRSay.system_msg(state, side, (str("removes ") + str(NRUtil.enumerate_cards(top_5)) + str(" from the game and draws 5 cards")))
					return NRDrawing.draw(state, "runner", eid, 5)
				).call()
			).call(),
		},
	}))

	NRCardDefs.defcard("Bahia Bands", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. If successful, resolve 2 of the following in any order:<ul><li>Draw 2 cards.</li><li>Install 1 card from your grip, paying 1[Credits] less.</li><li>Remove 1 tag.</li><li>Place 4[Credits] on this event. You can spend hosted credits to pay trash costs for the remainder of this run.</li></ul>",
		"code": "34030",
		"title": "Bahia Bands",
	}, (func():
		var all = [
			{
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 2),
			"msg": "draw 2 cards",
		},
			{
			"msg": "install a card from the grip, paying 1 [Credits] less",
			"async": true,
			"req": func(state, side, eid, card, targets): return (not (NRInstalling.install_locked(state, side))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose a card to install",
				"waiting-prompt": true,
				"choices": {
					"req": func(state, side, eid, card, targets): return ((NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets)) or NRCard.resource(NRCardXlate.first_target(targets))) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
						"cost-bonus": -1,
					})),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -1,
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
				}),
			}, card, null),
		},
			{
			"msg": "remove 1 tag",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, side, eid, 1),
		},
			{
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, NRCard.get_card(state, card), "credit", 4, null),
			"async": true,
			"msg": "place 4 [Credits] for paying trash costs",
		},
		]
		var choice = func(abis, rem): return {
			"prompt": (str("Choose an ability to resolve (") + str(rem) + str(" remaining)")),
			"waiting-prompt": true,
			"choices": NRUtil.as_array(abis).map(func(_pct, _pct2=null, _pct3=null): return capitalize(NRCardXlate.getk(_pct, "msg", null))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var chosen = (NRUtil.find_first(NRUtil.as_array(abis), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.first_target(targets) == capitalize(NRCardXlate.getk(_pct, "msg", null))) or NRUtil.kw_eq(NRCardXlate.first_target(targets), capitalize(NRCardXlate.getk(_pct, "msg", null)))) else null)) != null)
				return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, chosen, card, null)
				, func(async_result):
					(NREngine.continue_ability(state, side, choice(remove_once(func(_pct, _pct2=null, _pct3=null): return ((_pct == chosen) or NRUtil.kw_eq(_pct, chosen)), abis), (rem - 1)), card, null) if (1 < rem) else NREid.effect_completed(state, side, eid)))
			).call(),
		}
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_any_server_ability(),
			"interactions": {
				"pay-credits": {
					"req": func(state, side, eid, card, targets): return ((("runner-trash-corp-cards" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-trash-corp-cards", NRCardXlate.getk(eid, "source-type", null))) and NRCard.corp(NRCardXlate.first_target(targets))),
					"type": "credit",
				},
			},
			"events": [
				{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, choice(all, 2), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Because I Can", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run a remote server. If successful, instead of breaching that server, you may force the Corp to shuffle all cards in the root of that server into R&D.",
		"code": "21066",
		"title": "Because I Can",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_remote_server_ability,
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "remote",
			"this-card-run": true,
			"ability": {
				"msg": "shuffle all cards in the server into R&D",
				"effect": func(state, side, eid, card, targets):
					(func():
					for c in NRUtil.as_array(NRCardXlate.getk(run_server, "content", null)):
						NRMoving.move(state, "corp", c, "deck")
					return null
				).call()
					return NRShuffling.shuffle_zone(state, "corp", "deck"),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Beta Build", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Search your stack for 1 non-<strong>virus</strong> program. Install it, ignoring all costs. <em>(Shuffle your stack after searching it.)</em>\nRun any server. When that run ends, if that program has not been uninstalled, add it to the top of your stack.",
		"code": "36019",
		"title": "Beta Build",
	}, {
		"makes-run": true,
		"on-play": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, side, ne, {
				"prompt": "Install a non-virus program",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and (not (NRCard.has_subtype(_pct, "Virus"))) and NRInstalling.runner_can_install(state, side, eid, _pct, {
					"no-toast": true,
				}))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
					"ignore-all-cost": "true",
					"msg-keys": {
						"display-origin": true,
						"source-card": card,
					},
				}),
			}, card, null)
			, func(installed_card):
				NREngine.continue_ability(state, side, NRCardXlate.run_any_server_ability({
				"events": [
					{
					"event": "run-ends",
					"unregister-once-resolved": true,
					"duration": "end-of-run",
					"interactive": func(state, side, eid, card, targets):
						return true,
					"automatic": "last",
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets): return NRCard.get_card(state, installed_card),
					},
					"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(installed_card, "title", null)) + str(" to the top of the stack"),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.move(state, side, NRCard.get_card(state, installed_card), "deck", {
						"front": true,
					}),
				},
				],
			}), card, null)),
		},
	}))

	NRCardDefs.defcard("Black Hat", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 2,
		"factioncost": 5,
		"uniqueness": false,
		"text": "The Corp must trace[4]. If unsuccessful, for the remainder of the turn, access 2 additional cards whenever you breach HQ or R&D.",
		"code": "21110",
		"title": "Black Hat",
	}, {
		"on-play": {
			"trace": {
				"base": 4,
				"unsuccessful": {
					"effect": func(state, side, eid, card, targets):
						return NREngine.register_events(state, side, card, [
						breach_access_bonus("rd", 2, {
						"duration": "end-of-turn",
					}),
						breach_access_bonus("hq", 2, {
						"duration": "end-of-turn",
					}),
					]),
				},
			},
		},
	}))

	NRCardDefs.defcard("Blackmail", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Play only if the Corp has at least 1 bad publicity.\nRun any server. The Corp cannot rez ice during that run.",
		"code": "04089",
		"title": "Blackmail",
	}, {
		"makes-run": true,
		"on-play": {
			"req": func(state, side, eid, card, targets): return has_bad_pub_p(state),
			"prompt": "Choose a server",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": "prevent ice from being rezzed during this run",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRFlags.register_run_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez ice on this run due to Blackmail")) if NRCard.ice(card) else true))
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
	}))

	NRCardDefs.defcard("Blueberry!™ Diesel", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Look at the top 2 cards of your stack. You may add 1 of those cards to the bottom of your stack. Draw 2 cards.",
		"code": "26012",
		"title": "Blueberry!™ Diesel",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"prompt": "Move a card to the bottom of the stack?",
			"not-distinct": true,
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array(NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(2)))) + ["No"]),
			"effect": func(state, side, eid, card, targets):
				(NRMoving.move(state, side, NRCardXlate.first_target(targets), "deck") if (not ((NRCardXlate.first_target(targets) is String))) else null)
				NRSay.system_msg(state, side, (str("looks at the top 2 cards of the stack") + str((" and adds one to the bottom of the stack" if (not ((NRCardXlate.first_target(targets) is String))) else null))))
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to draw 2 cards")))
				return NRDrawing.draw(state, "runner", eid, 2),
		},
	}))

	NRCardDefs.defcard("Bravado", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run a server protected by ice. When that run ends, gain 6[Credits] plus 1[Credits] for each piece of ice you passed during that run.",
		"code": "26074",
		"title": "Bravado",
	}, (func():
		return {
			"makes-run": true,
			"on-play": {
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(iced_servers(state, side, eid, card)).is_empty()),
				},
				"prompt": "Choose an iced server",
				"choices": func(state, side, eid, card, targets):
					return iced_servers(state, side, eid, card),
				"effect": func(state, side, eid, card, targets):
					NREngine.register_events(state, side, card, [
					{
					"event": "pass-ice",
					"duration": "end-of-run",
					"effect": func(state, side, eid, card, targets):
						return NRUpdate.update_card(state, side, NRUtil.update_in(NRCard.get_card(state, card), ["special", "bravado-passed"], func(v): return (conj).call(v if v != null else []), NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "cid", null))),
				},
				])
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), NRCard.get_card(state, card)),
			},
			"events": [
				{
				"event": "run-ends",
				"silent": true,
				"msg": func(state, side, eid, card, targets): return str("gain ") + str((6 + NRUtil.as_array(NRUtil.get_in(card, ["special", "bravado-passed"], null)).size() + NRUtil.get_in(card, ["special", "bravado-moved"], 0))) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var qty = (6 + NRUtil.as_array(NRUtil.get_in(card, ["special", "bravado-passed"], null)).size() + NRUtil.get_in(card, ["special", "bravado-moved"], 0))
					return NRGaining.gain_credits(state, "runner", eid, qty)
				).call(),
			},
				{
				"event": "card-moved",
				"silent": true,
				"req": func(state, side, eid, card, targets): return (NRUtil.get_in(card, ["special", "bravado-passed"], null).get(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "moved-card", null), "cid", null)) if NRUtil.get_in(card, ["special", "bravado-passed"], null) is Dictionary else null),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var card = NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special", "bravado-moved"], func(v): return (inc).call(v if v != null else 0)))
					return NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special", "bravado-passed"], disj, NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "moved-card", null), "cid", null)))
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Bribery", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. During this run, the Corp must pay X[Credits] as an additional cost to rez the first unrezzed piece of ice approached.",
		"code": "06118",
		"title": "Bribery",
	}, {
		"makes-run": true,
		"on-play": {
			"async": true,
			"base-play-cost": [NRPayment.to_c("x-credits")],
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str(" and increase the rez cost of the first unrezzed piece of ice approached by ") + str(x_cost_value(eid)) + str(" [Credits]"),
			"prompt": "Choose a server",
			"effect": func(state, side, eid, card, targets):
				(func():
				var bribery_x = x_cost_value(eid)
				return NREngine.register_events(state, side, card, [
					{
					"event": "approach-ice",
					"duration": "end-of-run",
					"unregister-once-resolved": true,
					"req": func(state, side, eid, card, targets): return ((not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)))) and NREvents.first_run_event(state, side, "approach-ice", func(targets): return (func():
						var context = NRUtil.first_of(targets)
						return (not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))))
					).call())),
					"effect": func(state, side, eid, card, targets):
						return NREffects.register_lingering_effect(state, side, card, (func():
						var approached_ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
						return {
							"type": "rez-additional-cost",
							"duration": "end-of-run",
							"unregister-once-resolved": true,
							"req": func(state, side, eid, card, targets): return NRUtil.same_card(approached_ice, NRCardXlate.first_target(targets)),
							"value": [NRPayment.to_c("credit", bribery_x)],
						}
					).call()),
				},
				])
			).call()
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
	}))

	NRCardDefs.defcard("Brute-Force-Hack", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nDerez a piece of ice that has a rez cost of X or lower.",
		"code": "13002",
		"title": "Brute-Force-Hack",
	}, (func():
		return {
			"on-play": {
				"async": true,
				"base-play-cost": [NRPayment.to_c("x-credits")],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return valid_p(state, _pct, eid)) != null),
				},
				"prompt": func(state, side, eid, card, targets): return str("derez an ice with a rez cost of ") + str(x_cost_value(eid)) + str(" or lower"),
				"choices": {
					"req": func(state, side, eid, card, targets): return valid_p(state, NRCardXlate.first_target(targets), eid),
				},
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets)),
			},
		}
	).call()))

	NRCardDefs.defcard("Build Script", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Gain 1[Credits] and draw 2 cards.",
		"code": "12028",
		"title": "Build Script",
	}, {
		"on-play": {
			"msg": "gain 1 [Credits] and draw 2 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 1)
			, func(async_result):
				NRDrawing.draw(state, side, eid, 2)),
		},
	}))

	NRCardDefs.defcard("Burner", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. If successful, instead of breaching HQ, reveal 3 cards in HQ at random. Add 2 of the revealed cards to the top and/or bottom of R&D.",
		"code": "34085",
		"title": "Burner",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_server_ability("hq"),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "hq",
				"this-card-run": true,
				"mandatory": true,
				"ability": {
					"req": func(state, side, eid, card, targets): return (1 <= NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var chosen_cards = NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(3))
						return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, card, null, chosen_cards)
						, func(async_result):
							NREngine.continue_ability(state, side, move_ab(chosen_cards, mini(2, NRUtil.as_array(chosen_cards).size())), card, null))
					).call(),
				},
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("By Any Means", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Priority - Sabotage",
		"subtypes": ["Priority", "Sabotage"],
		"text": "Play only as your first [Click].\nFor the remainder of the turn, whenever you access a card not in Archives, trash it and suffer 1 meat damage.",
		"code": "21001",
		"title": "By Any Means",
	}, {
		"on-play": {
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [
				{
				"event": "access",
				"duration": "end-of-turn",
				"req": func(state, side, eid, card, targets): return (NRFlags.can_trash(state, "runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)) and (not (NRCard.in_discard(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))))),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null)) + str(" at no cost and suffer 1 meat damage"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, NRUtil.merge(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null) if NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null) is Dictionary else {}, {"seen": true}), {
					"cause-card": card,
					"accessed": true,
				})
				, func(async_result):
					(func():
					state.assoc_in(["runner", "register", "trashed-card"], true)
					state.assoc_in(["runner", "register", "trashed-accessed-card"], true)
					return NRDamage.damage(state, "runner", eid, "meat", 1, {
						"unboostable": true,
					})
				).call()),
			},
			]),
		},
	}))

	NRCardDefs.defcard("Calling in Favors", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Gain 1[Credits] for each installed <strong>connection</strong> resource.",
		"code": "05031",
		"title": "Calling in Favors",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Connection") and NRCard.resource(_pct)))).size()) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Connection") and NRCard.resource(_pct))) != null),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Connection") and NRCard.resource(_pct)))).size()),
		},
	}))

	NRCardDefs.defcard("Career Fair", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Install 1 resource from your grip, paying 3[Credits] less.",
		"code": "31015",
		"title": "Career Fair",
	}, {
		"on-play": {
			"prompt": "Choose a resource to install",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.resource(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, eid, card, {
					"cost-bonus": -3,
				})),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"cost-bonus": -3,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		},
	}))

	NRCardDefs.defcard("Careful Planning", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nChoose 1 card installed in the root of or protecting a remote server. That card cannot be rezzed this turn.",
		"code": "13013",
		"title": "Careful Planning",
	}, {
		"on-play": {
			"prompt": "Choose a card in or protecting a remote server",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)),
			},
			"msg": func(state, side, eid, card, targets): return str("prevent the Corp from rezzing ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" for the rest of the turn"),
			"effect": func(state, side, eid, card, targets):
				(func():
				var t = NRCardXlate.first_target(targets)
				var c = card
				return NREffects.register_lingering_effect(state, side, card, {
					"type": "icon",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), t),
					"duration": "post-runner-turn-ends",
					"value": make_icon("CP", c),
				})
			).call()
				return NRFlags.register_turn_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez the rest of this turn due to Careful Planning")) if NRUtil.same_card(card, NRCardXlate.first_target(targets)) else true)),
		},
	}))

	NRCardDefs.defcard("Carpe Diem", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nGain 4[Credits]. You may run your mark.",
		"code": "33012",
		"title": "Carpe Diem",
	}, {
		"makes-run": true,
		"events": [mark_changed_event],
		"on-play": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, side, ne, NRMark.identify_mark_ability, card, null)
			, func(async_result):
				(func():
				var marked_server = NRCardXlate.getk(state, "mark", null)
				return (func():
					NRUpdate.update_card(state, "runner", NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRServers.central_to_name(marked_server)}))
					NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to gain 4 [Credits]")))
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, 4)
					, func(async_result):
						NREngine.continue_ability(state, side, {
						"optional": {
							"prompt": (str("Run on ") + str(NRServers.zone_to_name(marked_server)) + str("?")),
							"no-ability": {
								"effect": func(state, side, eid, card, targets):
									return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to make a run"))),
							},
							"yes-ability": {
								"msg": (str("make a run on ") + str(NRServers.zone_to_name(marked_server))),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRRuns.make_run(state, side, eid, marked_server, card),
							},
						},
					}, card, null))
				).call()
			).call()),
		},
	}))

	NRCardDefs.defcard("CBI Raid", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, the Corp adds all cards in HQ to the top of R&D in the order of their choice.",
		"code": "10022",
		"title": "CBI Raid",
	}, (func():
		var _b0 = cbi_choice([remaining, chosen, n, original], {
			"player": "corp",
			"prompt": "Choose a card to move next onto R&D",
			"choices": remaining,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var chosen = ([NRCardXlate.first_target(targets)] + NRUtil.as_array(chosen))
				return (cbi_choice(remove_once(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.first_target(targets) == _pct) or NRUtil.kw_eq(NRCardXlate.first_target(targets), _pct)), remaining), chosen, n, original) if (NRUtil.as_array(chosen).size() < n) else cbi_final(chosen, original))
			).call(), card, null),
		})
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_server_ability("hq"),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "hq",
				"mandatory": true,
				"this-card-run": true,
				"ability": {
					"msg": "force the Corp to add all cards in HQ to the top of R&D",
					"player": "corp",
					"waiting-prompt": true,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, (func():
						var from = NRCardXlate.getk(state.getv("corp", {}), "hand", null)
						return (cbi_choice(from, [], NRUtil.as_array(from).size(), from) if (NRUtil.as_array(from).size() > 0) else null)
					).call(), card, null),
				},
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Chain Reaction", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 5,
		"uniqueness": false,
		"text": "Play only if you made a successful run on HQ, R&D, and Archives this turn.\nTrash 2 installed Corp cards. The Corp trashes 1 installed Runner card.",
		"code": "36001",
		"title": "Chain Reaction",
	}, (func():
		var corp_choice = {
			"player": "corp",
			"prompt": "Choose a Runner card to trash",
			"async": true,
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRBoard.all_installed(state, "runner")).is_empty()),
			"choices": {
				"card": func(_x): return ((NRCard.runner).call(_x)) and ((NRCard.installed).call(_x)),
			},
			"waiting-prompt": true,
			"display-side": "corp",
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, "corp", eid, NRCardXlate.first_target(targets)),
		}
		var cards_to_trash = func(state): return mini(2, NRUtil.as_array(NRBoard.all_installed(state, "corp")).size())
		var runner_choice = {
			"prompt": func(state, side, eid, card, targets): return str("choose ") + str(NRUtil.quantify(cards_to_trash(state), "card")) + str(" to trash"),
			"async": true,
			"choices": {
				"card": func(_x): return ((NRCard.corp).call(_x)) and ((NRCard.installed).call(_x)),
				"max": func(state, side, eid, card, targets):
					return cards_to_trash(state),
				"all": true,
			},
			"waiting-prompt": true,
			"msg": {
				"public": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.enumerate_str(NRUtil.as_array(targets).map(func(_pct, _pct2=null, _pct3=null): return NRToString.card_str(state, _pct)))),
				"corp": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.enumerate_str(NRUtil.as_array(targets).map(func(_pct, _pct2=null, _pct3=null): return NRToString.card_str(state, _pct, {
					"maybe-visible": true,
				})))),
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash_cards(state, side, ne, targets)
			, func(async_result):
				NREngine.continue_ability(state, "corp", corp_choice, card, null)),
		}
		return {
			"on-play": {
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return ((not NRUtil.as_array(NRBoard.all_installed(state, "corp")).is_empty()) or (not NRUtil.as_array(NRBoard.all_installed(state, "runner")).is_empty())),
				},
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
				"effect": func(state, side, eid, card, targets):
					return (NREngine.continue_ability(state, side, runner_choice, card, null) if (not NRUtil.as_array(NRBoard.all_installed(state, "corp")).is_empty()) else NREngine.continue_ability(state, "corp", corp_choice, card, null)),
			},
		}
	).call()))

	NRCardDefs.defcard("Charm Offensive", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run Archives. When that run ends, you may trash 1 rezzed copy of a card you accessed in Archives during that run.",
		"code": "35003",
		"title": "Charm Offensive",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_server_ability("archives"),
			"events": [
				{
				"event": "breach-server",
				"req": func(state, side, eid, card, targets): return (("archives" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("archives", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var ts = NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).map(func(_x): return bool(NRCardXlate.getk(_x, "title"))))
					return NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special", "accessed"], concat, ts))
				).call(),
			},
				{
				"event": "access-card",
				"req": func(state, side, eid, card, targets): return NRCard.in_discard(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)),
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special", "accessed"], conj, NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null))),
			},
				{
				"event": "run-ends",
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.get_in(card, ["special", "accessed"], null)).is_empty()),
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var rezzed_titles = NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.rezzed)).map(func(_x): return bool(NRCardXlate.getk(_x, "title")))
					var isec = set_intersection((NRUtil.as_array([]) + NRUtil.as_array(rezzed_titles)), (NRUtil.as_array([]) + NRUtil.as_array(NRUtil.get_in(card, ["special", "accessed"], null))))
					return (NREngine.continue_ability(state, side, {
						"async": true,
						"prompt": "Trash a rezzed copy of a card you accessed",
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.rezzed(_pct) and NRUtil.in_coll(isec, NRCardXlate.getk(_pct, "title", null))),
						},
						"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
						"effect": func(state, side, eid, card, targets):
							return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
							"cause-card": card,
						}),
					}, card, null) if (not NRUtil.as_array(isec).is_empty()) else NREid.effect_completed(state, side, eid))
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Chastushka", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, sabotage 4. <em>(The Corp trashes 4 cards of their choice from HQ and/or the top of R&D.)</em>",
		"code": "33002",
		"title": "Chastushka",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"mandatory": true,
			"ability": NRSabotage.sabotage(4),
		}),
		],
	}))

	NRCardDefs.defcard("Chrysopoeian Skimming", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "The Corp may reveal an agenda from HQ. If they do, gain [Click] and draw 1 card. Otherwise, look at the top 3 cards of R&D.",
		"code": "34011",
		"title": "Chrysopoeian Skimming",
	}, {
		"on-play": {
			"prompt": "Choose an agenda to reveal",
			"player": "corp",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).filter(NRCard.agenda)) + ["Done"]),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.system_msg(state, "corp", "declines to reveal an agenda from HQ")
				return scry(state, "runner", eid, card, "corp", 3)
			).call() if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else NREid.wait_for(state, eid, func(ne):
				NRRevealing.reveal(state, side, ne, card, {
				"forced": true,
			}, NRCardXlate.first_target(targets))
			, func(async_result):
				NREngine.continue_ability(state, "runner", {
				"msg": "gain [Click] and draw 1 card",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRGaining.gain_clicks(state, "runner", 1)
					return NRDrawing.draw(state, "runner", eid, 1),
			}, card, null))),
		},
	}))

	NRCardDefs.defcard("Clean Getaway", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. If successful, gain 6[Credits].",
		"code": "35014",
		"title": "Clean Getaway",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"msg": "gain 6 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 6),
		},
		],
	}))

	NRCardDefs.defcard("Code Siphon", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, instead of breaching R&D, you may search your stack for 1 program. Install it, paying 3[Credits] less for each piece of ice protecting R&D, and then take 1 tag.",
		"code": "06115",
		"title": "Code Siphon",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_server_ability("rd"),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "rd",
				"this-card-run": true,
				"ability": {
					"async": true,
					"prompt": "Choose a program to install",
					"msg": func(state, side, eid, card, targets): return str("install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" and take 1 tag"),
					"choices": func(state, side, eid, card, targets):
						return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
						"cost-bonus": rd_ice(state),
					}))),
					"effect": func(state, side, eid, card, targets):
						NREngine.trigger_event(state, side, "searched-stack")
						NRShuffling.shuffle_zone(state, side, "deck")
						return NREid.wait_for(state, eid, func(ne):
						NRInstalling.runner_install(state, side, ne, NRCardXlate.first_target(targets), {
						"cost-bonus": rd_ice(state),
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
					, func(async_result):
						NRTags.gain_tags(state, side, eid, 1)),
				},
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Cold Read", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run - Stealth",
		"subtypes": ["Run", "Stealth"],
		"text": "Place 4[Credits] on this event, then run any server. You can spend hosted credits during that run. When that run ends, trash 1 installed program you used during that run. Trashing a program this way cannot be prevented.",
		"code": "11083",
		"title": "Cold Read",
	}, {
		"implementation": "Used programs restriction not enforced",
		"makes-run": true,
		"data": {
			"counter": {
				"credit": 4,
			},
		},
		"on-play": NRCardXlate.run_any_server_ability(),
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
		"events": [
			{
			"event": "run-ends",
			"prompt": "Choose a program that was used during the run",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
				"unpreventable": true,
				"cause-card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Compile", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. The first time you encounter a piece of ice during this run, you may search your stack or heap for a program and install it, ignoring all costs. When the run ends, add that program to the bottom of your stack if it is still installed.",
		"code": "21088",
		"title": "Compile",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_any_server_ability(),
			"events": [
				{
				"event": "encounter-ice",
				"skippable": true,
				"optional": {
					"prompt": "Install a program?",
					"req": func(state, side, eid, card, targets): return NREvents.first_run_event(state, side, "encounter-ice"),
					"yes-ability": {
						"async": true,
						"prompt": "Choose where to install the program from",
						"choices": func(state, side, eid, card, targets):
							return (["Stack", "Heap"] if (not (NRFlags.zone_locked(state, "runner", "discard"))) else ["Stack"]),
						"effect": func(state, side, eid, card, targets):
							return NREngine.continue_ability(state, side, compile_fn(("deck" if (("Stack" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Stack", NRCardXlate.first_target(targets))) else "discard")), card, null),
					},
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Concerto", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Reveal the top card of your stack and place credits equal to its printed play or install cost on this event. Add the revealed card to your grip.\nRun any server. You can spend hosted credits during that run.",
		"code": "33075",
		"title": "Concerto",
	}, (func():
		return {
			"makes-run": true,
			"interactions": {
				"pay-credits": {
					"req": func(state, side, eid, card, targets): return state.getv("run"),
					"type": "credit",
				},
			},
			"on-play": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, reveal_and_load_credits(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), card, null)
				, func(async_result):
					NREngine.continue_ability(state, side, NRCardXlate.run_any_server_ability(), NRCard.get_card(state, card), null)),
			},
		}
	).call()))

	NRCardDefs.defcard("Contaminate", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Place 3 virus counters on an installed Runner card with no hosted virus counters.",
		"code": "21083",
		"title": "Contaminate",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("place 3 virus counters on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and NRCard.runner(NRCardXlate.first_target(targets)) and (NRVirus.get_virus_counters(state, NRCardXlate.first_target(targets)) == 0)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (NRVirus.get_virus_counters(state, _pct) == 0)) != null),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, NRCardXlate.first_target(targets), "virus", 3, null),
		},
	}))

	NRCardDefs.defcard("Corporate \"Grant\"", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe first time you install a card each turn, the Corp loses 1[Credits].",
		"code": "21044",
		"title": "Corporate \"Grant\"",
	}, {
		"events": [
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "runner-install"),
			"msg": "force the Corp to lose 1 [Credit]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "corp", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Corporate Scandal", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp is considered to have 1 additional bad publicity <em>(even if they had no bad publicity)</em>.",
		"code": "10025",
		"title": "Corporate Scandal",
	}, {
		"on-play": {
			"msg": "give the Corp 1 additional bad publicity",
			"implementation": "No enforcement that this Bad Pub cannot be removed",
			"effect": func(state, side, eid, card, targets):
				return state.update_in(["corp", "bad-publicity", "additional"], func(v): return v, 0),
		},
		"leave-play": func(state, side, eid, card, targets):
			return state.update_in(["corp", "bad-publicity", "additional"], func(v): return v, 0),
	}))

	NRCardDefs.defcard("Creative Commission", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Gain 5[Credits]. If you have any [Click] remaining, lose [Click].",
		"code": "30020",
		"title": "Creative Commission",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("gain 5 [Credits]") + str((" and lose [Click]" if (NRCardXlate.getk(state.getv("runner", {}), "click", null) > 0) else null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(NRGaining.lose_clicks(state, "runner", 1) if (NRCardXlate.getk(state.getv("runner", {}), "click", null) > 0) else null)
				return NRGaining.gain_credits(state, "runner", eid, 5),
		},
	}))

	NRCardDefs.defcard("Credit Crash", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. Trash the first non-agenda card you access during this run at no cost. The Corp can spend credits equal to the rez or play cost of the accessed card to prevent this trash.",
		"code": "11021",
		"title": "Credit Crash",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "pre-access-card",
			"once": "per-run",
			"async": true,
			"req": func(state, side, eid, card, targets): return (not (NRCard.agenda(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)))),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var c = NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)
				var cost = (((NRCard.asset(c) or NRCard.upgrade(c) or NRCard.ice(c)) and NRCostFns.rez_cost(state, side, c)) or (NRCard.operation(c) and NRCostFns.play_cost(state, side, c)))
				var title = NRCardXlate.getk(c, "title", null)
				return (NREngine.continue_ability(state, "corp", {
					"optional": {
						"waiting-prompt": true,
						"prompt": func(state, side, eid, card, targets): return str("Spend ") + str(cost) + str(" [Credits] to prevent the trash of ") + str(title) + str("?"),
						"player": "corp",
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								NRSay.system_msg(state, "corp", (str("spends ") + str(cost) + str(" [Credits] to prevent ") + str(title) + str(" from being trashed at no cost")))
								return NRGaining.lose_credits(state, "corp", eid, cost),
						},
						"no-ability": {
							"msg": func(state, side, eid, card, targets): return str("trash ") + str(title) + str(" at no cost"),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRMoving.trash(state, side, eid, NRUtil.merge(c if c is Dictionary else {}, {"seen": true}), {
								"cause-card": card,
							}),
						},
					},
				}, card, null) if NRPayment.can_pay(state, "corp", eid, card, null, [NRPayment.to_c("credit", cost)]) else (func():
					NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(title) + str(" at no cost")))
					return NRMoving.trash(state, side, eid, NRUtil.merge(c if c is Dictionary else {}, {"seen": true}), null)
				).call())
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Credit Kiting", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Play only if you made a successful run on a central server this turn.\nInstall a card from your grip, lowering its install cost by 8[Credits], and take 1 tag.",
		"code": "21023",
		"title": "Credit Kiting",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq", "rd", "archives"], _x)) != null),
			"prompt": "Choose a card to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return ((not (NRCard.event(NRCardXlate.first_target(targets)))) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -8,
				})),
			},
			"async": true,
			"cancel": {
				"msg": "take 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "runner", eid, 1),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var new_eid = NREid.make_eid(state, {
					"source": card,
					"source-type": "runner-install",
				})
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.runner_install(state, "runner", ne, new_eid, NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
					"cost-bonus": -8,
					"suppress-checkpoint": true,
				})
				, func(async_result):
					NRTags.gain_tags(state, "runner", eid, 1))
			).call(),
		},
	}))

	NRCardDefs.defcard("Cyber Threat", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nChoose a server. The Corp may rez 1 piece of ice protecting that server. If they do not, run that server. The Corp cannot rez ice during that run.",
		"code": "06013",
		"title": "Cyber Threat",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var serv = NRCardXlate.first_target(targets)
				return NREngine.continue_ability(state, "corp", ({
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Rez a piece of ice protecting ") + str(serv) + str("?"),
						"yes-ability": {
							"async": true,
							"prompt": func(state, side, eid, card, targets): return str("Choose a piece of ice protecting ") + str(serv) + str(" to rez"),
							"player": "corp",
							"choices": {
								"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.rezzed(_pct))) and NRCard.ice(_pct) and NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("credit", NRCostFns.rez_cost(state, side, _pct))])),
							},
							"effect": func(state, side, eid, card, targets):
								return NRRezzing.rez(state, "corp", eid, NRCardXlate.first_target(targets)),
							"cancel": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									NRFlags.register_run_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez ice on this run due to Cyber Threat")) if NRCard.ice(card) else true))
									return NRRuns.make_run(state, side, eid, serv, card),
							},
						},
						"no-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								NRFlags.register_run_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez ice on this run due to Cyber Threat")) if NRCard.ice(card) else true))
								return NRRuns.make_run(state, side, eid, serv, card),
							"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(serv) + str(" during which no ice can be rezzed"),
						},
					},
				} if (not NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.rezzed(_pct))) and NRCard.ice(_pct) and NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("credit", NRCostFns.rez_cost(state, side, _pct))])))).is_empty()) else {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRFlags.register_run_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez ice on this run due to Cyber Threat")) if NRCard.ice(card) else true))
						return NRRuns.make_run(state, side, eid, serv, card),
					"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(serv) + str(" during which no ice can be rezzed"),
				}), card, null)
			).call(),
		},
	}))


static func _register_2() -> void:
	NRCardDefs.defcard("Data Breach", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, when that run ends, you may run R&D again.",
		"code": "11028",
		"title": "Data Breach",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("rd"),
		"events": [
			{
			"event": "run-ends",
			"unregister-once-resolved": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and NRCardXlate.this_card_run(state, card, targets) and (not (NRCardXlate.getk(card, "run-again", null))) and ((["rd"] == NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)) or NRUtil.kw_eq(["rd"], NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)))),
				"prompt": "Make another run on R&D?",
				"yes-ability": NRCardXlate.run_server_ability("rd"),
			},
		},
		],
	}))

	NRCardDefs.defcard("Day Job", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "As an additional cost to play this event, spend [Click][Click][Click].\nGain 10[Credits].",
		"code": "07036",
		"title": "Day Job",
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("click", 3)],
			"msg": "gain 10 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 10),
		},
	}))

	NRCardDefs.defcard("Deep Data Mining", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, access X additional cards when you breach R&D. X is equal to your unused MU or 4, whichever is less.",
		"code": "13014",
		"title": "Deep Data Mining",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("rd"),
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"silent": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [
				breach_access_bonus("rd", maxi(0, mini(4, NRMemory.available_mu(state))), {
				"duration": "end-of-run",
			}),
			]),
		},
		],
	}))

	NRCardDefs.defcard("Deep Dive", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 5,
		"uniqueness": false,
		"text": "Play only if you made a successful run on HQ, R&D, and Archives this turn.\nThe Corp must set aside the top 8 cards of R&D faceup. Access 1 of those cards. You may spend [Click] to access another 1 of those cards. Then, the Corp shuffles the set-aside cards into R&D.",
		"code": "33022",
		"title": "Deep Dive",
	}, (func():
		var _b0 = deep_dive_access([cards], {
			"prompt": "Choose a card to access",
			"waiting-prompt": true,
			"not-distinct": true,
			"choices": cards,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRAccess.access_card(state, side, ne, NRCardXlate.first_target(targets))
			, func(async_result):
				(func():
				var new_cards = NRUtil.as_array(cards).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets))).call(_x)))
				return NREid.effect_completed(state, side, NREid.make_result(eid, new_cards))
			).call()),
		})
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
				},
				"effect": func(state, side, eid, card, targets):
					NRSetAside.set_aside(state, "corp", eid, NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(8)))
					return (func():
					var top_8 = NRUtil.as_array(NRSetAside.get_set_aside(state, "corp", eid))
					return (func():
						NRSay.system_msg(state, side, (str("uses ") + str(NRCard.get_title(card)) + str(" to set aside ") + str(NRUtil.enumerate_cards(top_8)) + str(" from the top of R&D")))
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, {
							"async": true,
							"prompt": (str("The set aside cards are: ") + str(NRUtil.enumerate_cards(top_8))),
							"choices": ["OK"],
						}, card, null)
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, deep_dive_access(top_8), card, null)
						, func(cards):
							(func():
							var cards = (not NRUtil.as_array(cards).is_empty())
							return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, {
							"optional": {
								"prompt": "Pay [Click] to access another card?",
								"req": func(state, side, eid, card, targets): return NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, [NRPayment.to_c("click", 1)]),
								"no-ability": {
									"effect": func(state, side, eid, card, targets):
										return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to access another card"))),
								},
								"yes-ability": {
									"async": true,
									"cost": [NRPayment.to_c("click", 1)],
									"msg": "access another card",
									"effect": func(state, side, eid, card, targets):
										return NREngine.continue_ability(state, side, deep_dive_access(cards), card, null),
								},
							},
						}, card, null)
						, func(async_result):
							(func():
							shuffle_back(state, NRSetAside.get_set_aside(state, "corp", eid))
							return NREid.effect_completed(state, side, eid)
						).call()) if cards != null else (func():
							shuffle_back(state, NRSetAside.get_set_aside(state, "corp", eid))
							return NREid.effect_completed(state, side, eid)
						).call()
						).call()))
					).call()
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Déjà Vu", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Add 1 card (or up to 2 <strong>virus</strong> cards) from your heap to your grip.",
		"code": "01002",
		"title": "Déjà Vu",
	}, {
		"on-play": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).is_empty()) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
			},
			"prompt": "Choose a card to add to Grip",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.getk(state.getv("runner", {}), "discard", null),
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to [their] Grip"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				return NREngine.continue_ability(state, side, ({
				"prompt": "Choose a virus to add to Grip",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Virus"))).is_empty()),
				},
				"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to [their] Grip"),
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Virus")),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
			} if NRCard.has_subtype(NRCardXlate.first_target(targets), "Virus") else null), card, null),
		},
	}))

	NRCardDefs.defcard("Demolition Run", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ or R&D.\nAccess → <strong>0[Credits]:</strong> Trash the card you are accessing.",
		"code": "20002",
		"title": "Demolition Run",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_from_choices_ability(["HQ", "R&D"]),
		"interactions": {
			"access-ability": {
				"label": "Trash card",
				"trash?": true,
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" at no cost"),
				"req": func(state, side, eid, card, targets): return (NRFlags.can_trash(state, "runner", NRCardXlate.first_target(targets)) and (not (NRCard.in_discard(NRCardXlate.first_target(targets))))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}), {
					"cause-card": card,
				}),
			},
		},
	}))

	NRCardDefs.defcard("Deuces Wild", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Resolve two of the following in any order:<ul><li>Gain 3[Credits].</li><li>Draw 2 cards.</li><li>Remove 1 tag.</li><li>Expose 1 piece of ice, then make a run.</li></ul>",
		"code": "11008",
		"title": "Deuces Wild",
	}, (func():
		var all = [
			{
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 3),
			"async": true,
			"msg": "gain 3 [Credits]",
		},
			{
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 2),
			"msg": "draw 2 cards",
		},
			{
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, side, eid, 1),
			"msg": "remove 1 tag",
		},
			{
			"prompt": "Choose 1 piece of ice to expose",
			"msg": "expose 1 ice and make a run",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRExpose.expose(state, side, ne, [NRCardXlate.first_target(targets)])
			, func(async_result):
				NREngine.continue_ability(state, side, NRCardXlate.run_any_server_ability(), card, null)),
			"cancel": NRCardXlate.run_any_server_ability(),
		},
		]
		var choice = func(abis): return {
			"prompt": "Choose an ability to resolve",
			"choices": NRUtil.as_array(abis).map(func(_pct, _pct2=null, _pct3=null): return capitalize(NRCardXlate.getk(_pct, "msg", null))),
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var chosen = (NRUtil.find_first(NRUtil.as_array(abis), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.first_target(targets) == capitalize(NRCardXlate.getk(_pct, "msg", null))) or NRUtil.kw_eq(NRCardXlate.first_target(targets), capitalize(NRCardXlate.getk(_pct, "msg", null)))) else null)) != null)
				return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, chosen, card, null)
				, func(async_result):
					(NREngine.continue_ability(state, side, choice(remove_once(func(_pct, _pct2=null, _pct3=null): return ((_pct == chosen) or NRUtil.kw_eq(_pct, chosen)), abis)), card, null) if ((NRUtil.as_array(abis).size() == 4) or NRUtil.kw_eq(NRUtil.as_array(abis).size(), 4)) else NREid.effect_completed(state, side, eid)))
			).call(),
		}
		return {
			"on-play": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, choice(all), card, null),
			},
		}
	).call()))

	NRCardDefs.defcard("Diana's Hunt", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. Whenever you encounter a piece of ice during that run, you may install 1 program from your grip, ignoring all costs. When that run ends, trash all programs installed this way.",
		"code": "12106",
		"title": "Diana's Hunt",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).filter(NRCard.program)).is_empty()),
				"prompt": "Install a program from the grip?",
				"yes-ability": {
					"prompt": "Choose a program to install",
					"async": true,
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRCard.program(NRCardXlate.first_target(targets))),
					},
					"effect": func(state, side, eid, card, targets):
						return NRInstalling.runner_install(state, side, eid, NRUtil.assoc_in(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, ["special", "diana-installed"], true), {
						"ignore-all-cost": true,
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}),
				},
			},
		},
			{
			"event": "run-ends",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var installed_cards = NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.get_in(_pct, ["special", "diana-installed"], null))
				return ((func():
					NRSay.system_msg(state, "runner", (str("trashes ") + str(NRUtil.quantify(NRUtil.as_array(installed_cards).size(), "card")) + str(" (") + str(NRUtil.enumerate_cards(installed_cards, "sorted")) + str(") at the end of the run from Diana's Hunt")))
					return NRMoving.trash_cards(state, "runner", eid, installed_cards, {
						"cause-card": card,
					})
				).call() if (not NRUtil.as_array(installed_cards).is_empty()) else NREid.effect_completed(state, side, eid))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Diesel", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Draw 3 cards.",
		"code": "31027",
		"title": "Diesel",
	}, {
		"on-play": NRDefHelpers.draw_ability(3),
	}))

	NRCardDefs.defcard("Direct Access", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "While you are resolving this event, each playerʼs identity loses all abilities.\nRun any server. When that run ends, you may shuffle this event into your stack.",
		"code": "26028",
		"title": "Direct Access",
	}, {
		"makes-run": true,
		"static-abilities": [
			{
			"type": "disable-card",
			"req": func(state, side, eid, card, targets): return (NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(state.getv("corp", {}), "identity", null)) or NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(state.getv("runner", {}), "identity", null))),
			"value": true,
		},
		],
		"on-play": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.fake_checkpoint(state)
				return NREngine.continue_ability(state, side, {
				"async": true,
				"prompt": "Choose a server",
				"choices": func(state, side, eid, card, targets):
					return NRCardXlate.runnable_servers(state, side, eid, card),
				"effect": func(state, side, eid, card, targets):
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
			}, card, null),
		},
		"events": [
			{
			"event": "run-ends",
			"unregister-once-resolved": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, "runner", {
				"optional": {
					"prompt": "Shuffle Direct Access into the Stack?",
					"yes-ability": {
						"msg": "shuffle itself into the Stack",
						"effect": func(state, side, eid, card, targets):
							NRMoving.move(state, side, NRCard.get_card(state, card), "deck")
							return NRShuffling.shuffle_zone(state, side, "deck"),
					},
				},
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Dirty Laundry", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. When that run ends, if it was successful, gain 5[Credits].",
		"code": "31037",
		"title": "Dirty Laundry",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "run-ends",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and NRCardXlate.this_card_run(state, card, targets)),
			"msg": "gain 5 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 5),
		},
		],
	}))

	NRCardDefs.defcard("Diversion of Funds", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Double - Run - Sabotage",
		"subtypes": ["Double", "Run", "Sabotage"],
		"text": "As an additional cost to play this event, spend [Click].\nRun HQ. If successful, instead of breaching HQ, you may force the Corp to lose up to 5[Credits], then you gain 1[Credits] for each credit lost.",
		"code": "21105",
		"title": "Diversion of Funds",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"ability": NRCardXlate.drain_credits("runner", "corp", 5, 1),
		}),
		],
	}))

	NRCardDefs.defcard("Divide and Conquer", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run Archives. If successful, after breaching Archives, breach HQ, then breach R&D. You cannot access cards in the root of HQ or R&D during these breaches.",
		"code": "22002",
		"title": "Divide and Conquer",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("archives"),
		"events": [
			{
			"event": "end-breach-server",
			"async": true,
			"req": func(state, side, eid, card, targets): return ((("archives" == NRCardXlate.getk(NRCardXlate.first_target(targets), "from-server", null)) or NRUtil.kw_eq("archives", NRCardXlate.getk(NRCardXlate.first_target(targets), "from-server", null))) and NRCardXlate.getk(state.getv("run"), "successful", null)),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRAccess.breach_server(state, side, ne, ["hq"], {
				"no-root": true,
			})
			, func(async_result):
				NRAccess.breach_server(state, side, eid, ["rd"], {
				"no-root": true,
			})),
		},
		],
	}))

	NRCardDefs.defcard("Drive By", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nExpose 1 card installed in the root of a remote server. If you do and that card is an asset or upgrade, trash it.",
		"code": "08064",
		"title": "Drive By",
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (func():
					var topmost = NRCard.get_nested_host(_pct)
					return (NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(topmost))[1] if NRUtil.as_array(NRCard.get_zone(topmost)).size() > 1 else null)) and ((NRUtil.last_of(NRCard.get_zone(topmost)) == "content") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(topmost)), "content")) and (not (NRCardXlate.getk(_pct, "rezzed", null))))
				).call(),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRExpose.expose(state, side, ne, [NRCardXlate.first_target(targets)])
			, func(async_result):
				((func():
				NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRCardXlate.getk(exposed, "title", null))))
				return NRMoving.trash(state, "runner", eid, NRUtil.merge(exposed if exposed is Dictionary else {}, {"seen": true}), {
					"cause-card": card,
				})
			).call() if (NRCard.asset(exposed) or NRCard.upgrade(exposed)) else NREid.effect_completed(state, side, eid))),
		},
	}))

	NRCardDefs.defcard("Early Bird", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority - Run",
		"subtypes": ["Priority", "Run"],
		"text": "Play only as your first click.\nGain [Click]. Run any server.",
		"code": "05032",
		"title": "Early Bird",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str(" and gain [Click]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 1)
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
	}))

	NRCardDefs.defcard("Easy Mark", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "Gain 3[Credits].",
		"code": "25023",
		"title": "Easy Mark",
	}, {
		"on-play": NRDefHelpers.gain_credits_ability(3),
	}))

	NRCardDefs.defcard("Embezzle", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, name asset, ice, operation or upgrade, then reveal 2 cards from HQ at random. Trash each revealed card that has the named type, then gain 4[Credits] for each card trashed this way.",
		"code": "21084",
		"title": "Embezzle",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"mandatory": true,
			"ability": {
				"prompt": "Choose a card type",
				"choices": ["Asset", "Upgrade", "Operation", "ICE"],
				"msg": func(state, side, eid, card, targets): return str("reveal 2 cards from HQ and trash all ") + str(NRCardXlate.first_target(targets)) + str(("s" if (not ((("ICE" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("ICE", NRCardXlate.first_target(targets))))) else null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var cards_to_reveal = NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(2))
					var cards_to_trash = NRUtil.as_array(cards_to_reveal).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.is_type(_pct, NRCardXlate.first_target(targets)))
					var credits = (4 * NRUtil.as_array(cards_to_trash).size())
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, card, null, cards_to_reveal)
					, func(async_result):
						((func():
						NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRUtil.enumerate_cards(cards_to_trash, "sorted")) + str(" from HQ and gain ") + str(credits) + str(" [Credits]")))
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash_cards(state, "runner", ne, NRUtil.as_array(cards_to_trash).map(func(_pct, _pct2=null, _pct3=null): return NRUtil.merge(_pct if _pct is Dictionary else {}, {"seen": true})), {
							"cause-card": card,
						})
						, func(async_result):
							NRGaining.gain_credits(state, "runner", eid, credits))
					).call() if (credits > 0) else NREid.effect_completed(state, side, eid)))
				).call(),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Emergency Shutdown", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Sabotage",
		"subtypes": ["Sabotage"],
		"text": "Play only if you made a successful run on HQ this turn.\nDerez 1 installed piece of ice.",
		"code": "31016",
		"title": "Emergency Shutdown",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return ((NRCard.ice).call(_x)) and ((NRCard.rezzed).call(_x))) != null),
			},
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets)),
		},
	}))

	NRCardDefs.defcard("Emergent Creativity", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Adam",
		"cost": 2,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nTrash any number of programs and/or pieces of hardware from your grip. Search your stack for 1 program or piece of hardware. Install it, paying X[Credits] less. X is equal to the total install cost of the trashed cards.",
		"code": "21028",
		"title": "Emergent Creativity",
	}, (func():
		return {
			"on-play": {
				"prompt": "Choose pieces of hardware and/or programs to trash",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) or (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty())),
				},
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return ((NRCard.hardware(_pct) or NRCard.program(_pct)) and NRCard.in_hand(_pct)),
					"max": func(state, side, eid, card, targets):
						return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size(),
				},
				"cancel": ec(0, []),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var trash_cost = reduce(_, keep("cost", targets))
					var to_trash = targets
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash_cards(state, side, ne, to_trash, {
						"unpreventable": true,
						"cause-card": card,
					})
					, func(async_result):
						NREngine.continue_ability(state, side, ec(trash_cost, to_trash), card, null))
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Employee Strike", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp's identity loses its printed abilities.",
		"code": "09053",
		"title": "Employee Strike",
	}, {
		"on-play": {
			"msg": "disable the Corp's identity",
		},
		"static-abilities": [
			{
			"type": "disable-card",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(state.getv("corp", {}), "identity", null)),
			"value": true,
		},
		],
	}))

	NRCardDefs.defcard("En Passant", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Sabotage",
		"subtypes": ["Sabotage"],
		"text": "Play only if you made a successful run this turn.\nTrash 1 unrezzed piece of ice you passed during your last run.",
		"code": "31003",
		"title": "En Passant",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null),
			"prompt": "Choose an unrezzed piece of ice that you passed on your last run",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRUtil.as_array(keep(func(_pct, _pct2=null, _pct3=null): return NRCard.get_card(state, NRCardXlate.getk(NRUtil.first_of(_pct), "ice", null)), NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "last-run", null), "events", null)).filter(func(_pct, _pct2=null, _pct3=null): return (("pass-ice" == NRUtil.first_of(_pct)) or NRUtil.kw_eq("pass-ice", NRUtil.first_of(_pct))))).map(second))).filter(func(_x): return not NRCard.rezzed.call(_x))), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.first_target(targets), _pct)) != null),
			},
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"async": true,
			"cancel": {
				"msg": "do nothing",
			},
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
				"cause-card": card,
			}),
		},
	}))

	NRCardDefs.defcard("Encore", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": false,
		"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nTake an additional turn after this one. Remove Encore from the game instead of trashing it.",
		"code": "11107",
		"title": "Encore",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
			"rfg-instead-of-trashing": true,
			"msg": "take an additional turn after this one",
			"effect": func(state, side, eid, card, targets):
				return state.update_in(["runner", "extra-turns"], func(v): return v, 0),
		},
	}))

	NRCardDefs.defcard("Escher", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. If successful, instead of breaching HQ, rearrange any number of ice protecting all servers. <em>(Do not rez or derez any ice or change the number of ice protecting any server.)</em>",
		"code": "03031",
		"title": "Escher",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_server_ability("hq"),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "hq",
				"this-card-run": true,
				"mandatory": true,
				"ability": {
					"async": true,
					"msg": "rearrange installed ice",
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, es(), card, null),
				},
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Eureka!", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nReveal the top card of your stack. You may install that card, lowering the install cost by 10[Credits], if able; otherwise, trash it.",
		"code": "04027",
		"title": "Eureka!",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var topcard = NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null))
				var caninst = ((NRCard.hardware(topcard) or NRCard.program(topcard) or NRCard.resource(topcard)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), topcard, {
					"cost-bonus": -10,
				}))
				return (NREngine.continue_ability(state, side, {
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Install ") + str(NRCardXlate.getk(topcard, "title", null)) + str("?"),
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRInstalling.runner_install(state, side, eid, topcard, {
								"msg-keys": {
									"display-origin": true,
									"install-source": card,
								},
								"cost-bonus": -10,
							}),
						},
						"no-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, topcard)
							, func(async_result):
								(func():
								NRSay.system_msg((str("reveals ") + str(NRCardXlate.getk(topcard, "title", null)) + str(" from the top of the stack and trashes it")))
								return NRMoving.trash(eid, topcard, {
									"unpreventable": true,
									"cause-card": card,
								})
							).call()),
						},
					},
				}, card, null) if caninst else NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, topcard)
				, func(async_result):
					(func():
					NRSay.system_msg(state, side, (str("reveals ") + str(NRCardXlate.getk(topcard, "title", null)) + str(" from the top of the stack and trashes it")))
					return NRMoving.trash(state, side, eid, topcard, {
						"unpreventable": true,
						"cause-card": card,
					})
				).call()))
			).call(),
		},
	}))

	NRCardDefs.defcard("Exclusive Party", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Draw 1 card. Gain 1[Credits] for each copy of Exclusive Party in your heap.\nLimit 6 per deck.",
		"code": "10060",
		"title": "Exclusive Party",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("draw 1 card and gain ") + str(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(card, "title", null))))).size()) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, side, ne, 1)
			, func(async_result):
				NRGaining.gain_credits(state, side, eid, NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(card, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(card, "title", null))))).size())),
		},
	}))

	NRCardDefs.defcard("Executive Wiretaps", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nReveal all cards in HQ.",
		"code": "04084",
		"title": "Executive Wiretaps",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRUtil.enumerate_cards(NRCardXlate.getk(state.getv("corp", {}), "hand", null), "sorted")) + str(" from HQ"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRevealing.reveal(state, side, eid, NRCardXlate.getk(state.getv("corp", {}), "hand", null)),
		},
	}))

	NRCardDefs.defcard("Exploit", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nDerez up to 3 pieces of ice.",
		"code": "12004",
		"title": "Exploit",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
			"prompt": "Choose up to 3 pieces of ice to derez",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return ((NRCard.ice).call(_x)) and ((NRCard.rezzed).call(_x))) != null),
			},
			"choices": {
				"max": 3,
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.rezzed(_pct) and NRCard.ice(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, side, eid, targets),
		},
	}))

	NRCardDefs.defcard("Exploratory Romp", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. If successful, instead of breaching that server, remove up to 3 advancement counters from 1 card in the root of or protecting the attacked server.",
		"code": "03032",
		"title": "Exploratory Romp",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"mandatory": true,
			"this-card-run": true,
			"ability": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return ((NRCard.get_counters(_pct, "advancement") > 0) and ((NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)) == (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)), (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null))))) != null),
				"prompt": "How many advancements counters do you want to remove?",
				"choices": ["0", "1", "2", "3"],
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var c = str_to_int(NRCardXlate.first_target(targets))
					return NREngine.continue_ability(state, side, {
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return ((NRCard.get_counters(_pct, "advancement") > 0) and ((NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)) == (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)), (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))),
						},
						"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRUtil.quantify(c, "advancement counter")) + str(" from ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
							var to_remove = mini(c, NRCard.get_counters(NRCardXlate.first_target(targets), "advancement"))
							return NRProps.add_prop(state, "corp", eid, NRCardXlate.first_target(targets), "advance-counter", (-to_remove))
						).call(),
					}, card, null)
				).call(),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Express Delivery", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Look at the top 4 cards of your stack and add 1 of those cards to your grip. Shuffle your stack.",
		"code": "05033",
		"title": "Express Delivery",
	}, {
		"on-play": {
			"prompt": "Choose a card to add to the grip",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(4)),
			"msg": "look at the top 4 cards of the stack and add 1 of them to the grip",
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				return NRShuffling.shuffle_zone(state, side, "deck"),
		},
	}))

	NRCardDefs.defcard("Eye for an Eye", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Play only if you are not tagged.\nRun HQ. If successful, take 1 tag and access 1 additional card when you breach HQ.\nAccess → <strong>Trash 1 card from your grip:</strong> Trash the card you are accessing.",
		"code": "34067",
		"title": "Eye for an Eye",
	}, {
		"makes-run": true,
		"on-play": NRUtil.merge(NRCardXlate.run_server_ability("hq") if NRCardXlate.run_server_ability("hq") is Dictionary else {}, {"req": func(state, side, eid, card, targets):
			return (not (NRUtil.is_tagged(state)))}),
		"interactions": {
			"access-ability": {
				"label": "Trash card",
				"trash?": true,
				"cost": [NRPayment.to_c("trash-from-hand", 1)],
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from HQ"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}), {
					"accessed": true,
					"cause-card": card,
				}),
			},
		},
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"async": true,
			"msg": "take 1 tag and access 1 additional card from HQ",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRTags.gain_tags(state, "runner", ne, 1, {
				"unpreventable": true,
			})
			, func(async_result):
				(func():
				NREngine.register_events(state, side, card, [breach_access_bonus("hq", 1, {
					"duration": "end-of-run",
				})])
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Falsified Credentials", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Name a card type. Expose a card in a remote server, then gain 5[Credits] if the exposed card has the named card type.",
		"code": "21064",
		"title": "Falsified Credentials",
	}, {
		"on-play": {
			"prompt": "Choose one",
			"choices": ["Agenda", "Asset", "Upgrade"],
			"msg": func(state, side, eid, card, targets): return str("guess ") + str(NRCardXlate.first_target(targets)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var chosen_type = NRCardXlate.first_target(targets)
				return {
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (func():
							var topmost = NRCard.get_nested_host(_pct)
							return (NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(topmost))[1] if NRUtil.as_array(NRCard.get_zone(topmost)).size() > 1 else null)) and ((NRUtil.last_of(NRCard.get_zone(topmost)) == "content") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(topmost)), "content")) and (not (NRCard.rezzed(_pct))))
						).call(),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRExpose.expose(state, side, ne, [NRCardXlate.first_target(targets)])
					, func(async_result):
						NREngine.continue_ability(state, "runner", ({
						"msg": "gain 5 [Credits]",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRGaining.gain_credits(state, side, eid, 5),
					} if (exposed and ((chosen_type == NRCardXlate.getk(NRCardXlate.first_target(targets), "type", null)) or NRUtil.kw_eq(chosen_type, NRCardXlate.getk(NRCardXlate.first_target(targets), "type", null)))) else null), card, null)),
				}
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("Fear the Masses", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, reveal any number of copies of Fear the Masses from your grip. The Corp trashes X cards from the top of R&D, where X is equal to 1 plus the number of cards you revealed.\nLimit 6 per deck.",
		"code": "10096",
		"title": "Fear the Masses",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"mandatory": true,
			"ability": {
				"async": true,
				"msg": "force the Corp to trash the top card of R&D",
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.mill(state, "corp", ne, "corp", 1)
				, func(async_result):
					NREngine.continue_ability(state, side, (func():
					var n = NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card("title", card, _pct))).size()
					return {
						"async": true,
						"prompt": func(state, side, eid, card, targets): return str("How many copies of ") + str(NRCardXlate.getk(card, "title", null)) + str(" do you want to reveal?"),
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRUtil.same_card("title", card, _pct)),
							"max": n,
						},
						"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRUtil.quantify(NRUtil.as_array(targets).size(), "cop", "y", "ies")) + str(" of itself,") + str(" forcing the Corp to trash ") + str(NRUtil.quantify(NRUtil.as_array(targets).size(), "additional card")) + str(" from the top of R&D"),
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, "runner", ne, targets)
						, func(async_result):
							NRMoving.mill(state, "corp", eid, "corp", NRUtil.as_array(targets).size())),
					}
				).call(), card, null)),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Feint", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. The first 2 times this run you encounter a piece of ice, bypass that ice. If successful, you cannot breach HQ.",
		"code": "05034",
		"title": "Feint",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			{
			"event": "encounter-ice",
			"automatic": "bypass",
			"req": func(state, side, eid, card, targets): return (NRUtil.get_in(card, ["special", "bypass-count"], 0) < 2),
			"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
			"effect": func(state, side, eid, card, targets):
				NRCardXlate.bypass_ice(state)
				return NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special", "bypass-count"], func(v): return (inc).call(v if v != null else 0))),
		},
			{
			"event": "successful-run",
			"effect": func(state, side, eid, card, targets):
				return NRRuns.prevent_access(state, side),
		},
		],
	}))

	NRCardDefs.defcard("Finality", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "As an additional cost to play this event, suffer 1 core damage.\nRun R&D. If successful, access 3 additional cards when you breach R&D.",
		"code": "33066",
		"title": "Finality",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("rd", {
			"additional-cost": [NRPayment.to_c("brain", 1)],
		}),
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [breach_access_bonus("rd", 3, {
				"duration": "end-of-run",
			})]),
		},
		],
	}))

	NRCardDefs.defcard("Fisk Investment Seminar", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nEach player draws 3 cards.",
		"code": "08105",
		"title": "Fisk Investment Seminar",
	}, {
		"on-play": {
			"msg": "make each player draw 3 cards",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) or (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty())),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "runner", ne, 3, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRDrawing.draw(state, "corp", eid, 3)),
		},
	}))

	NRCardDefs.defcard("Forged Activation Orders", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Sabotage",
		"subtypes": ["Sabotage"],
		"text": "Choose 1 unrezzed piece of ice. The Corp may rez that ice. If they do not, they trash it.",
		"code": "31017",
		"title": "Forged Activation Orders",
	}, {
		"on-play": {
			"choices": {
				"card": func(_x): return ((NRCard.ice).call(_x)) and ((func(_x): return not NRCard.rezzed.call(_x)).call(_x)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return ((NRCard.ice).call(_x)) and ((func(_x): return not NRCard.rezzed.call(_x)).call(_x))) != null),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var ice = NRCardXlate.first_target(targets)
				var serv = NRServers.zone_to_name((NRUtil.as_array(NRCard.get_zone(ice))[1] if NRUtil.as_array(NRCard.get_zone(ice)).size() > 1 else null))
				var icepos = card_index(state, ice)
				return NREngine.continue_ability(state, "corp", {
					"prompt": "Choose one",
					"choices": [
						((str("Rez ") + str(NRToString.card_str(state, ice))) if (NRFlags.can_rez(state, "corp", ice) and NRPayment.can_pay(state, "corp", eid, ice, null, NRRezzing.get_rez_cost(state, "corp", ice, null))) else null),
						(str("Trash ") + str(NRToString.card_str(state, ice))),
					],
					"async": true,
					"msg": func(state, side, eid, card, targets): return str("force the Corp to ") + str(decapitalize(NRCardXlate.first_target(targets))),
					"waiting-prompt": true,
					"effect": func(state, side, eid, card, targets):
						return (NRRezzing.rez(state, "corp", eid, ice) if str_starts_with_p(NRCardXlate.first_target(targets), "Rez") else NRMoving.trash(state, "corp", eid, ice, {
						"cause-card": card,
						"cause": "forced-to-trash",
					})),
				}, card, null)
			).call(),
		},
	}))

	NRCardDefs.defcard("Forked", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run any server. The first time you fully break a <strong>sentry</strong> during that run, trash that <strong>sentry</strong>.",
		"code": "07037",
		"title": "Forked",
	}, cutlery("Sentry")))

	NRCardDefs.defcard("Frame Job", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nForfeit 1 agenda. If you do, give the Corp 1 bad publicity.",
		"code": "04001",
		"title": "Frame Job",
	}, {
		"on-play": {
			"prompt": "Choose an agenda to forfeit",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.getv("runner", {}), "scored", null),
			},
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.getk(state.getv("runner", {}), "scored", null),
			"msg": func(state, side, eid, card, targets): return str("forfeit ") + str(NRCard.get_title(card)) + str(" and give the Corp 1 bad publicity"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.forfeit(state, side, ne, NREid.make_eid(state, eid), NRCardXlate.first_target(targets), {
				"msg": false,
			})
			, func(async_result):
				NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
		},
	}))

	NRCardDefs.defcard("Frantic Coding", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Look at the top 10 cards of your stack. If any of those cards are programs, you may install one of them, lowering the install cost by 5. Trash the rest of those cards.",
		"code": "11062",
		"title": "Frantic Coding",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var top_ten = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(10))
				return {
					"prompt": (str("The top cards of the stack are (top->bottom): ") + str(NRUtil.enumerate_cards(top_ten))),
					"choices": ["OK"],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, {
						"prompt": "Install a program?",
						"choices": (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(top_ten).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
							"cost-bonus": -5,
						}))))).is_empty())) + NRUtil.as_array(["Done"])),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
							return (log_and_trash_cards(top_ten, eid) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else (func():
								var number_of_shuffles = NRUtil.as_array(NREvents.turn_events(state, "runner", "runner-shuffle-deck")).size()
								return NREid.wait_for(state, eid, func(ne):
									NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, {
									"source": card,
									"source-type": "runner-install",
								}), NRCardXlate.first_target(targets), {
									"cost-bonus": -5,
									"msg-keys": {
										"display-origin": true,
										"install-source": card,
									},
								})
								, func(async_result):
									(log_and_trash_cards(NRUtil.as_array(top_ten).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets))).call(_x))), eid) if ((number_of_shuffles == NRUtil.as_array(NREvents.turn_events(state, "runner", "runner-shuffle-deck")).size()) or NRUtil.kw_eq(number_of_shuffles, NRUtil.as_array(NREvents.turn_events(state, "runner", "runner-shuffle-deck")).size())) else (func():
									NRSay.system_msg(state, side, "does not have to trash cards because the stack was shuffled")
									return NREid.effect_completed(state, side, eid)
								).call()))
							).call())
						).call(),
					}, card, null),
				}
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("\"Freedom Through Equality\"", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhen you steal an agenda, add \"Freedom Through Equality\" to your score area as an agenda worth 1 agenda point.",
		"code": "10045",
		"title": "\"Freedom Through Equality\"",
	}, {
		"events": [
			{
			"event": "agenda-stolen",
			"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.as_agenda(state, "runner", card, 1),
		},
		],
	}))


static func _register_3() -> void:
	NRCardDefs.defcard("Freelance Coding Contract", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "Trash up to 5 programs from your grip. Gain 2[Credits] for each program trashed.",
		"code": "03033",
		"title": "Freelance Coding Contract",
	}, {
		"on-play": {
			"choices": {
				"max": 5,
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.in_hand(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()),
			},
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.enumerate_cards(targets, "sorted")) + str(" and gain ") + str((2 * NRUtil.as_array(targets).size())) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash_cards(state, side, ne, targets, {
				"unpreventable": true,
				"cause-card": card,
			})
			, func(async_result):
				NRGaining.gain_credits(state, side, eid, (2 * NRUtil.as_array(targets).size()))),
		},
	}))

	NRCardDefs.defcard("Game Day", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nIf you have fewer cards in your grip than your maximum hand size, draw cards until you have cards in your grip equal to your maximum hand size.",
		"code": "08026",
		"title": "Game Day",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify((NRHandSize.hand_size(state, "runner") - NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size()), "card")),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((NRHandSize.hand_size(state, "runner") - NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size()) > 0),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, (NRHandSize.hand_size(state, "runner") - NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size())),
		},
	}))

	NRCardDefs.defcard("Glut Cipher", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run Archives. If successful, instead of breaching Archives, the Corp adds exactly 5 cards from Archives to HQ, if able. If they do, they trash 5 cards from HQ at random.",
		"code": "21061",
		"title": "Glut Cipher",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("archives"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "archives",
			"this-card-run": true,
			"mandatory": true,
			"ability": {
				"req": func(state, side, eid, card, targets): return (5 <= NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).size()),
				"show-discard": true,
				"async": true,
				"player": "corp",
				"waiting-prompt": true,
				"prompt": "Choose 5 cards from Archives to add to HQ",
				"choices": {
					"max": 5,
					"all": true,
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
				},
				"msg": func(state, side, eid, card, targets): return str("move ") + str((func():
					var seen = NRUtil.as_array(targets).filter(func(_x): return bool(NRCardXlate.getk(_x, "seen")))
					var m = NRUtil.as_array(NRUtil.as_array(targets).filter(func(_x): return not ((func(_x): return bool(NRCardXlate.getk(_x, "seen"))).call(_x)))).size()
					return (str(NRUtil.enumerate_cards(seen)) + str(((str((" and " if (not ((seen is Array and seen.is_empty() if false else (str(seen) == "")))) else null)) + str(NRUtil.quantify(m, "unseen card"))) if (m > 0) else null)) + str(" into HQ, then trash 5 cards"))
				).call()),
				"effect": func(state, side, eid, card, targets):
					(func():
					for c in NRUtil.as_array(targets):
						NRMoving.move(state, side, c, "hand")
					return null
				).call()
					return NRMoving.trash_cards(state, "corp", eid, NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(NRCardXlate.getk(state, "corp", null), "hand", null))), int(5)), {
					"cause-card": card,
				}),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Government Investigations", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhile secretly spending credits, players cannot spend 2[Credits].",
		"code": "11069",
		"title": "Government Investigations",
	}, {
		"flags": {
			"prevent-secretly-spend": func(state, side, eid, card, targets):
				return 2,
		},
	}))

	NRCardDefs.defcard("Guinea Pig", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Trash your grip.\nGain 10[Credits].",
		"code": "22003",
		"title": "Guinea Pig",
	}, {
		"on-play": {
			"msg": "trash all cards in the grip and gain 10 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash_cards(state, side, ne, NRCardXlate.getk(state.getv("runner", {}), "hand", null), {
				"unpreventable": true,
				"cause-card": card,
			})
			, func(async_result):
				NRGaining.gain_credits(state, "runner", eid, 10)),
		},
	}))

	NRCardDefs.defcard("Hacktivist Meeting", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nAs an additional cost to rez non-ice cards, the Corp must randomly trash a card from HQ.",
		"code": "08021",
		"title": "Hacktivist Meeting",
	}, {
		"static-abilities": [
			{
			"type": "rez-additional-cost",
			"req": func(state, side, eid, card, targets): return (not (NRCard.ice(NRCardXlate.first_target(targets)))),
			"value": [NRPayment.to_c("randomly-trash-from-hand", 1)],
		},
		],
	}))

	NRCardDefs.defcard("Harmony AR Therapy", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Choose up to 5 cards with different names in your heap. Shuffle those cards into your stack.\nRemove this event from the game.",
		"code": "26083",
		"title": "Harmony AR Therapy",
	}, (func():
		var _b0 = choose_next([to_shuffle, NRCardXlate.first_target(targets), remaining], (func():
			var remaining = (remaining if (("Done" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Done", NRCardXlate.first_target(targets))) else NRUtil.as_array(remaining).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((_pct == NRCardXlate.first_target(targets)) or NRUtil.kw_eq(_pct, NRCardXlate.first_target(targets)))).call(_x))))
			var to_shuffle = (to_shuffle if (("Done" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Done", NRCardXlate.first_target(targets))) else ((NRUtil.as_array(to_shuffle) + NRUtil.as_array([NRCardXlate.first_target(targets)])) if NRCardXlate.first_target(targets) else []))
			var remaining_choices = (5 - NRUtil.as_array(to_shuffle).size())
			var finished_p = ((("Done" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Done", NRCardXlate.first_target(targets))) or ((0 == remaining_choices) or NRUtil.kw_eq(0, remaining_choices)) or (remaining is Array and remaining.is_empty() if false else (str(remaining) == "")))
			return {
				"prompt": func(state, side, eid, card, targets): return str(((str("Shuffling: ") + str(NRUtil.enumerate_str(to_shuffle))) if finished_p else (str("Choose up to ") + str(remaining_choices) + str((" more" if (not NRUtil.as_array(to_shuffle).is_empty()) else null)) + str(" cards.") + str(((str("[br]Shuffling: ") + str(NRUtil.enumerate_str(to_shuffle))) if (not NRUtil.as_array(to_shuffle).is_empty()) else null))))),
				"async": true,
				"choices": func(state, side, eid, card, targets):
					return (["OK", "Start over"] if finished_p else (NRUtil.as_array(remaining) + NRUtil.as_array((["Done"] if (not NRUtil.as_array(to_shuffle).is_empty()) else null)))),
				"effect": func(state, side, eid, card, targets):
					return ((NREngine.continue_ability(state, side, choose_end(to_shuffle), card, null) if (("OK" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("OK", NRCardXlate.first_target(targets))) else NREngine.continue_ability(state, side, choose_next([], null, NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).map(func(_x): return bool(NRCardXlate.getk(_x, "title"))))), card, null)) if finished_p else NREngine.continue_ability(state, side, choose_next(to_shuffle, NRCardXlate.first_target(targets), remaining), card, null)),
			}
		).call())
		return {
			"on-play": {
				"rfg-instead-of-trashing": true,
				"waiting-prompt": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (NREngine.continue_ability(state, side, choose_next([], null, NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).map(func(_x): return bool(NRCardXlate.getk(_x, "title")))))), card, null) if ((not (NRFlags.zone_locked(state, "runner", "discard"))) and (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).size() > 0)) else (func():
					NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to shuffle the stack")))
					NRShuffling.shuffle_zone(state, "runner", "deck")
					return NREid.effect_completed(state, side, eid)
				).call()),
			},
		}
	).call()))

	NRCardDefs.defcard("High-Stakes Job", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 6,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Job",
		"subtypes": ["Run", "Job"],
		"text": "Make a run on a server with at least 1 piece of unrezzed ice. When the run ends, gain 12[Credits] if it was successful.",
		"code": "10004",
		"title": "High-Stakes Job",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return (func():
				var unrezzed_ice = func(_pct, _pct2=null, _pct3=null): return (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk((NRUtil.as_array(_pct)[1] if NRUtil.as_array(_pct).size() > 1 else null), "ices", null)).filter(func(_x): return not NRCard.rezzed.call(_x))).is_empty())
				var bad_zones = keys(NRUtil.as_array(state.get_in(["corp", "servers"], null)).filter(func(_x): return not unrezzed_ice.call(_x)))
				return NRServers.zones_to_sorted_names(NRUtil.as_array(NRRuns.get_runnable_zones(state, side, eid, card, null)).filter(func(_x): return not ((NRUtil.as_array(bad_zones)).call(_x))))
			).call(),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		"events": [
			{
			"event": "run-ends",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and NRCardXlate.this_card_run(state, card, targets)),
			"msg": "gain 12 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 12),
		},
		],
	}))

	NRCardDefs.defcard("Hostage", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nSearch your stack for a <strong>connection</strong>, reveal it, and add it to your grip. You may install that <strong>connection</strong> (paying its install cost). Shuffle your stack.",
		"code": "25025",
		"title": "Hostage",
	}, {
		"on-play": {
			"prompt": "Choose a Connection",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Connection")),
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the stack to the grip and shuffle the stack"),
			"async": true,
			"cancel": fail_to_find_bang,
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				return NREngine.continue_ability(state, side, (func():
				var connection = NRCardXlate.first_target(targets)
				return ({
					"optional": {
						"prompt": (str("Install ") + str(NRCardXlate.getk(connection, "title", null)) + str("?")),
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), connection, null)
								return NRShuffling.shuffle_zone(state, side, "deck"),
						},
						"no-ability": {
							"effect": func(state, side, eid, card, targets):
								NRMoving.move(state, side, connection, "hand")
								return NRShuffling.shuffle_zone(state, side, "deck"),
						},
					},
				} if NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), connection) else {
					"effect": func(state, side, eid, card, targets):
						NRMoving.move(state, side, connection, "hand")
						return NRShuffling.shuffle_zone(state, side, "deck"),
				})
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("Hot Pursuit", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run on HQ. If successful, gain 9[Credits] and take 1 tag.",
		"code": "22009",
		"title": "Hot Pursuit",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"async": true,
			"msg": "gain 9 [Credits] and take 1 tag",
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRTags.gain_tags(state, "runner", ne, 1, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRGaining.gain_credits(state, "runner", eid, 9)),
		},
		],
	}))

	NRCardDefs.defcard("I've Had Worse", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Draw 3 cards.\nWhenever I've Had Worse is trashed by taking net or meat damage, draw 3 cards.",
		"code": "07032",
		"title": "I've Had Worse",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 3),
		},
		"on-trash": {
			"when-inactive": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"req": func(state, side, eid, card, targets): return NRUtil.in_coll(["meat", "net"], NRCardXlate.getk(NRCardXlate.ctx(targets), "cause", null)),
			"msg": "draw 3 cards",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 3),
		},
	}))

	NRCardDefs.defcard("Illumination", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, install up to 3 cards from your grip <em>(one at a time)</em>, paying 1[Credits] less for each.",
		"code": "35025",
		"title": "Illumination",
	}, (func():
		return {
			"makes-run": true,
			"play-sound": "illumination",
			"on-play": NRCardXlate.run_server_ability("rd"),
			"events": [
				NRUtil.merge(install_fn(3) if install_fn(3) is Dictionary else {}, {"event": "successful-run"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Immolation Script", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run Archives. If successful, whenever you would access a faceup piece of ice in Archives this run, you may instead trash 1 rezzed copy of that ice. Use this ability only once this run.",
		"code": "08041",
		"title": "Immolation Script",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("archives"),
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"req": func(state, side, eid, card, targets): return ((("archives" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("archives", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (not NRUtil.as_array(set_intersection((NRUtil.as_array([]) + NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(NRCard.ice)).map(func(_x): return bool(NRCardXlate.getk(_x, "title"))))), (NRUtil.as_array([]) + NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.rezzed)).map(func(_x): return bool(NRCardXlate.getk(_x, "title"))))))).is_empty())),
			"prompt": "Choose a piece of ice in Archives",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(NRCard.ice),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var ice = NRCardXlate.first_target(targets)
				return {
					"async": true,
					"prompt": func(state, side, eid, card, targets): return str("Choose a rezzed copy of ") + str(NRCardXlate.getk(ice, "title", null)) + str(" to trash"),
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and NRUtil.same_card("title", _pct, ice)),
					},
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
						"cause-card": card,
					}),
				}
			).call(), card, null),
		},
		],
	}))

	NRCardDefs.defcard("In the Groove", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nFor the remainder of this turn, whenever you install a card with a printed install cost of 1[Credits] or greater, draw 1 card or gain 1[Credits].",
		"code": "26020",
		"title": "In the Groove",
	}, {
		"events": [
			{
			"event": "runner-install",
			"duration": "end-of-turn",
			"req": func(state, side, eid, card, targets): return ((1 <= NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "cost", null)) and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "facedown", null)))),
			"interactive": func(state, side, eid, card, targets):
				return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Cybernetic") or NREvents.first_event(state, side, "runner-install")),
			"async": true,
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Draw 1 card", "Gain 1 [Credits]"],
			"msg": func(state, side, eid, card, targets): return str(decapitalize(NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return (NRDrawing.draw(state, side, eid, 1) if ((NRCardXlate.first_target(targets) == "Draw 1 card") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 1 card")) else NRGaining.gain_credits(state, side, eid, 1)),
		},
		],
	}))

	NRCardDefs.defcard("Independent Thinking", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Adam",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Trash up to 5 of your installed cards. Draw 1 card for each card trashed (or 2 cards for each card trashed if you trashed at least 1 <strong>directive</strong>).",
		"code": "09038",
		"title": "Independent Thinking",
	}, (func():
		return {
			"on-play": {
				"prompt": "Choose up to 5 installed cards to trash",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRBoard.all_installed(state, "runner")).is_empty()),
				},
				"choices": {
					"max": 5,
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.runner(_pct)),
				},
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRUtil.enumerate_cards(targets)) + str(" and draw ") + str(NRUtil.quantify(cards_to_draw(targets), "card")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
					"cause-card": card,
				})
				, func(async_result):
					NRDrawing.draw(state, "runner", eid, cards_to_draw(targets))),
			},
		}
	).call()))

	NRCardDefs.defcard("Indexing", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, instead of breaching R&D, you may look at the top 5 cards of R&D and arrange them in any order.",
		"code": "29005",
		"title": "Indexing",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("rd"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "rd",
			"this-card-run": true,
			"ability": {
				"msg": "rearrange the top 5 cards of R&D",
				"waiting-prompt": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, (func():
					var from = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(5))
					return (reorder_choice("corp", "corp", from, [], NRUtil.as_array(from).size(), from) if (NRUtil.as_array(from).size() > 0) else null)
				).call(), card, null),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Infiltration", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Gain 2[Credits] or expose 1 card.",
		"code": "20055",
		"title": "Infiltration",
	}, {
		"on-play": NRChooseOne.choose_one([
			{
			"option": "Gain 2 [Credits]",
			"ability": NRDefHelpers.gain_credits_ability(2),
		},
			{
			"option": "Expose a card",
			"ability": {
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.rezzed(_pct)))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRExpose.expose(state, side, eid, [NRCardXlate.first_target(targets)]),
			},
		},
		]),
	}))

	NRCardDefs.defcard("Information Sifting", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. If successful, instead of breaching HQ, the Corp separates all cards in HQ into 2 facedown piles. Choose 1 of the piles. Access each card in the chosen pile.",
		"code": "10079",
		"title": "Information Sifting",
	}, (func():
		var _b0 = which_pile([p1, p2], {
			"waiting-prompt": true,
			"prompt": "Choose a pile to access",
			"choices": [
				(str("Pile 1 (") + str(NRUtil.quantify(NRUtil.as_array(p1).size(), "card")) + str(")")),
				(str("Pile 2 (") + str(NRUtil.quantify(NRUtil.as_array(p2).size(), "card")) + str(")")),
			],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var choice = (1 if str_starts_with_p(NRCardXlate.first_target(targets), "Pile 1") else 2)
				return (func():
					NRSay.system_msg(state, side, (str("chooses to access ") + str(NRCardXlate.first_target(targets))))
					return NREngine.continue_ability(state, side, access_pile((p1 if ((1 == choice) or NRUtil.kw_eq(1, choice)) else p2), choice, NRUtil.as_array((p1 if ((1 == choice) or NRUtil.kw_eq(1, choice)) else p2)).size()), card, null)
				).call()
			).call(),
		})
		return (func():
			var access_effect = {
				"player": "corp",
				"req": func(state, side, eid, card, targets): return (1 <= NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()),
				"async": true,
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets): return str("Choose up to ") + str(NRUtil.quantify((NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() - 1), "card")) + str(" for the first pile"),
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
					"max": func(state, side, eid, card, targets):
						return (NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() - 1),
				},
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, "runner", which_pile(shuffle(targets), shuffle(NRUtil.as_array(set_difference(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)), NRUtil.as_array(targets))))), card, null),
			}
			return {
				"makes-run": true,
				"on-play": NRCardXlate.run_server_ability("hq"),
				"events": [
					NRCardXlate.successful_run_replace_breach({
					"target-server": "hq",
					"this-card-run": true,
					"mandatory": true,
					"ability": access_effect,
				}),
				],
			}
		).call()
	).call()))

	NRCardDefs.defcard("Inject", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Reveal the top 4 cards of your stack and trash all programs revealed. Gain 1[Credits] for each program trashed, and add the rest of the revealed cards to your grip.",
		"code": "06073",
		"title": "Inject",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var cards = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(4))
				var programs = NRUtil.as_array(cards).filter(NRCard.program)
				var others = NRUtil.as_array(cards).filter(func(_x): return not ((NRCard.program).call(_x)))
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, cards)
				, func(async_result):
					(NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, programs, {
					"unpreventable": true,
					"cause-card": card,
				})
				, func(async_result):
					(func():
					NRSay.system_msg(state, side, (str("reveals ") + str(NRUtil.enumerate_cards(programs)) + str(" from the top of the stack,") + str(" trashes them, and gains ") + str(NRUtil.as_array(programs).size()) + str(" [Credits]")))
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, NRUtil.as_array(programs).size())
					, func(async_result):
						(func():
						(func():
							for c in NRUtil.as_array(others):
								(func():
							NRMoving.move(state, side, c, "hand")
							return NRSay.system_msg(state, side, (str("adds ") + str(NRCardXlate.getk(c, "title", null)) + str(" to the grip")))
						).call()
							return null
						).call()
						return NREid.effect_completed(state, side, eid)
					).call())
				).call()) if (not NRUtil.as_array(programs).is_empty()) else (func():
					(func():
						for c in NRUtil.as_array(others):
							(func():
						NRMoving.move(state, side, c, "hand")
						return NRSay.system_msg(state, side, (str("adds ") + str(NRCardXlate.getk(c, "title", null)) + str(" to the grip")))
					).call()
						return null
					).call()
					return NREid.effect_completed(state, side, eid)
				).call()))
			).call(),
		},
	}))

	NRCardDefs.defcard("Injection Attack", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Choose 1 installed <strong>icebreaker</strong> and run any server. During that run, the chosen <strong>icebreaker</strong> gets +2 strength.",
		"code": "11009",
		"title": "Injection Attack",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var server = NRCardXlate.first_target(targets)
				return {
					"prompt": "Choose an icebreaker",
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Icebreaker")),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRIce.pump(state, side, NRCardXlate.first_target(targets), 2, "end-of-run")
						return NRRuns.make_run(state, side, eid, server, card),
				}
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("Inside Job", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. The first time you encounter a piece of ice during that run, bypass it.",
		"code": "31018",
		"title": "Inside Job",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "encounter-ice",
			"automatic": "bypass",
			"req": func(state, side, eid, card, targets): return (NREvents.first_run_event(state, side, "encounter-ice") and (state.getv("run") is Dictionary and NRUtil.same_card(card, state.get_in(["run", "source-card"], {})))),
			"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.bypass_ice(state),
		},
		],
	}))

	NRCardDefs.defcard("Insight", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nThe Corp may look at the top 4 cards of R&D and arrange them in any order.\nReveal the top 4 cards of R&D.",
		"code": "22016",
		"title": "Insight",
	}, {
		"on-play": {
			"async": true,
			"player": "corp",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
			},
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, "corp", ne, reorder_choice("corp", NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(4))), card, targets)
			, func(async_result):
				(func():
				var top_4 = NRUtil.take_n(NRUtil.as_array(state.get_in(["corp", "deck"], null)), int(4))
				return (func():
					NRSay.system_msg(state, "runner", (str("reveals ") + str(NRUtil.enumerate_cards(top_4)) + str(" from the top of R&D (top->bottom)")))
					return NRRevealing.reveal(state, "runner", eid, top_4)
				).call()
			).call()),
		},
	}))

	NRCardDefs.defcard("Interdiction", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp cannot rez non-ice cards during the Runner's turn.",
		"code": "11087",
		"title": "Interdiction",
	}, (func():
		var ab = func(state, side, eid, card, targets):
			return NRFlags.register_turn_flag(state, side, card, "can-rez", func(state, _side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot rez non-ice on the Runner's turn due to Interdiction")) if (((NRCardXlate.getk(state, "active-player", null) == "runner") or NRUtil.kw_eq(NRCardXlate.getk(state, "active-player", null), "runner")) and (not (NRCard.ice(card)))) else true))
		return {
			"on-play": {
				"msg": "prevent the Corp from rezzing non-ice cards on the Runner's turn",
				"effect": ab,
			},
			"events": [{
				"event": "runner-turn-begins",
				"silent": true,
				"effect": ab,
			}],
			"leave-play": func(state, side, eid, card, targets):
				return clear_all_flags_for_card_bang(state, side, card),
		}
	).call()))

	NRCardDefs.defcard("Into the Depths", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. If successful, for each time you passed ice this run, resolve 1 of the following that you have not yet resolved this run:<ul><li>Gain 4[Credits].</li><li>Search your stack for a program. Install it. <em>(Shuffle your stack after searching it.)</em></li><li>Charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em></li></ul>",
		"code": "33023",
		"title": "Into the Depths",
	}, (func():
		var all = [
			{
			"msg": "gain 4 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 4),
		},
			{
			"msg": "install a program from the stack",
			"async": true,
			"req": func(state, side, eid, card, targets): return (not (NRInstalling.install_locked(state, side))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose a program to install",
				"msg": func(state, side, eid, card, targets): return str(("shuffle the stack" if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else (str("install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the stack")))),
				"choices": func(state, side, eid, card, targets):
					return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct))))).is_empty())) + NRUtil.as_array(["Done"])),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NREngine.trigger_event(state, side, "searched-stack")
					NRShuffling.shuffle_zone(state, side, "deck")
					return (NREid.effect_completed(state, side, eid) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
				})),
			}, card, null),
		},
			{
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRCharge.charge_ability(state, side), card, null),
			"msg": "charge a card",
		},
		]
		var choice = func(abis, rem): return {
			"prompt": (str("Choose an ability to resolve (") + str(rem) + str(" remaining)")),
			"waiting-prompt": true,
			"choices": NRUtil.as_array(abis).map(func(_pct, _pct2=null, _pct3=null): return capitalize(NRCardXlate.getk(_pct, "msg", null))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var chosen = (NRUtil.find_first(NRUtil.as_array(abis), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.first_target(targets) == capitalize(NRCardXlate.getk(_pct, "msg", null))) or NRUtil.kw_eq(NRCardXlate.first_target(targets), capitalize(NRCardXlate.getk(_pct, "msg", null)))) else null)) != null)
				return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, chosen, card, null)
				, func(async_result):
					(NREngine.continue_ability(state, side, choice(remove_once(func(_pct, _pct2=null, _pct3=null): return ((_pct == chosen) or NRUtil.kw_eq(_pct, chosen)), abis), (rem - 1)), card, null) if (1 < rem) else NREid.effect_completed(state, side, eid)))
			).call(),
		}
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_any_server_ability(),
			"events": [
				{
				"event": "successful-run",
				"automatic": "gain-credits",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var ice_passed = NREvents.run_event_count(state, side, "pass-ice")
					var num_choices = (0 if (ice_passed == null) else mini(3, ice_passed))
					return (NREngine.continue_ability(state, side, choice(all, num_choices), card, null) if (0 < num_choices) else NREid.effect_completed(state, side, eid))
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Isolation", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "As an additional cost to play this event, trash 1 installed resource.\nGain 7[Credits].",
		"code": "26001",
		"title": "Isolation",
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("resource", 1)],
			"msg": "gain 7 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 7),
		},
	}))

	NRCardDefs.defcard("Itinerant Protesters", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp gets −1 maximum hand size for each bad publicity they have.",
		"code": "07033",
		"title": "Itinerant Protesters",
	}, {
		"on-play": {
			"msg": "reduce the Corp's maximum hand size by 1 for each bad publicity",
		},
		"static-abilities": [
			corp_hand_size_(func(state, side, eid, card, targets):
			return (-NRUtil.count_bad_pub(state))),
		],
	}))

	NRCardDefs.defcard("Jailbreak", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ or R&D. If successful, draw 1 card and when you breach the attacked server, access 1 additional card.",
		"code": "30028",
		"title": "Jailbreak",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_from_choices_ability(["HQ", "R&D"]),
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"silent": true,
			"async": true,
			"msg": "draw 1 card",
			"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["hq", "rd"], NRServers.target_server(NRCardXlate.ctx(targets))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				NREngine.register_events(state, side, card, [
				breach_access_bonus(NRServers.target_server(NRCardXlate.ctx(targets)), 1, {
				"duration": "end-of-run",
			}),
			])
				return NRDrawing.draw(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Joy Ride", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, draw 5 cards.",
		"code": "34021",
		"title": "Joy Ride",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return rd_runnable,
			},
			"effect": func(state, side, eid, card, targets):
				return NRRuns.make_run(state, side, eid, "rd", card),
		},
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"silent": true,
			"async": true,
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"msg": "draw 5 cards",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 5),
		},
		],
	}))

	NRCardDefs.defcard("Katorga Breakout", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. If successful, add 1 card from your heap to your grip.",
		"code": "33067",
		"title": "Katorga Breakout",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.this_card_run(state, card, targets) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
			"prompt": "Choose 1 card to add to the grip",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.getk(state.getv("runner", {}), "discard", null),
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to the grip"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
		},
		],
	}))

	NRCardDefs.defcard("Khusyuk", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, instead of breaching R&D, choose an install cost greater than 0[Credits]. The Corp sets aside the top X cards of R&D faceup, where X is equal to the number of your installed cards with that printed install cost, up to 6. Access 1 of the set-aside cards. The Corp shuffles the set-aside cards into R&D.",
		"code": "26021",
		"title": "Khusyuk",
	}, (func():
		var access_revealed = func(revealed): return {
			"async": true,
			"prompt": "Choose a card to access",
			"waiting-prompt": true,
			"not-distinct": true,
			"choices": revealed,
			"req": func(state, side, eid, card, targets): return (not (((NRCardXlate.getk(state.getv("run"), "max-access", null) == 0) or NRUtil.kw_eq(NRCardXlate.getk(state.getv("run"), "max-access", null), 0)))),
			"effect": func(state, side, eid, card, targets):
				return NRAccess.access_card(state, side, eid, NRCardXlate.first_target(targets)),
		}
		var select_install_cost = func(state): return (func():
			var current_values = (NRUtil.as_array(sorted_map()) + NRUtil.as_array(NRUtil.merge({
				1: 0,
			} if {
				1: 0,
			} is Dictionary else {}, frequencies(NRUtil.as_array(keep("cost", NRBoard.all_active_installed(state, "runner"))).filter(func(_x): return not ((zero_p).call(_x)))) if frequencies(NRUtil.as_array(keep("cost", NRBoard.all_active_installed(state, "runner"))).filter(func(_x): return not ((zero_p).call(_x)))) is Dictionary else {})))
			return {
				"async": true,
				"prompt": "Choose an install cost from among your installed cards",
				"choices": NRUtil.as_array(NRUtil.as_array((func(_pct, _pct2=null, _pct3=null): return (NRUtil.as_array(_pct) + NRUtil.as_array([99]))).call(_range(1, (NRUtil.last_of(keys(current_values)) + 1)))).map(func(x): return (str(x) + str(" [Credit]: ") + str(NRUtil.quantify((current_values.get(x, 0) if current_values is Dictionary else 0), "card"))))).map(str),
				"effect": func(state, side, eid, card, targets):
					return NREid.complete_with_result(state, side, eid, [
					str_to_int(NRUtil.first_of(str_split(NRCardXlate.first_target(targets), " "))),
					mini(6, str_to_int(NRUtil.as_array(str_split(NRCardXlate.first_target(targets), " "))[2])),
				]),
			}
		).call()
		var access_effect = {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, side, ne, select_install_cost(state), card, null)
			, func(async_result):
				(func():
				var revealed = (not NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(reveals))).is_empty())
				return (func():
					NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to choose an install cost of ") + str(NRCostFns.install_cost) + str(" [Credit] and reveals ") + str(((str(NRUtil.enumerate_cards(revealed)) + str(" from the top of R&D (top->bottom)")) if revealed else "no cards"))))
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, ({
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRRevealing.reveal(state, side, eid, revealed),
					} if revealed else null), card, null)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, (access_revealed(revealed) if (revealed and (not (get_only_card_to_access(state)))) else null), card, null)
					, func(async_result):
						(func():
						NRShuffling.shuffle_zone(state, "corp", "deck")
						NRSay.system_msg(state, "runner", "shuffles R&D")
						return NREid.effect_completed(state, side, eid)
					).call()))
				).call()
			).call()),
		}
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_server_ability("rd"),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "rd",
				"this-card-run": true,
				"mandatory": true,
				"ability": access_effect,
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Knifed", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run any server. The first time you fully break a <strong>barrier</strong> during that run, trash that <strong>barrier</strong>.",
		"code": "07038",
		"title": "Knifed",
	}, cutlery("Barrier")))

	NRCardDefs.defcard("Kompromat", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run a server protected by ice. When that run ends, if it was successful, give the Corp 1 bad publicity unless they derez 1 piece of ice protecting the attacked server.\nRemove this event from the game.",
		"code": "36010",
		"title": "Kompromat",
	}, (func():
		return {
			"makes-run": true,
			"on-play": {
				"async": true,
				"rfg-instead-of-trashing": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(iced_servers(state, side, eid, card)).is_empty()),
				},
				"prompt": "Choose an iced server",
				"choices": func(state, side, eid, card, targets):
					return iced_servers(state, side, eid, card),
				"effect": func(state, side, eid, card, targets):
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
			},
			"events": [
				{
				"event": "run-ends",
				"req": func(state, side, eid, card, targets): return (NRCardXlate.this_card_run(state, card, targets) and NRCardXlate.getk(NRCardXlate.ctx(targets), "successful", null)),
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var valid_ice = NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and ((NRUtil.first_of(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))))
					return NREngine.continue_ability(state, side, ({
						"prompt": "Derez an ice? (if you click done, you take a bad publicity)",
						"player": "corp",
						"waiting-prompt": true,
						"choices": {
							"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(valid_ice), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets))) != null),
						},
						"cancel": {
							"display-side": "runner",
							"msg": "give the Corp 1 bad publicity",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRBadPublicity.gain_bad_publicity(state, "runner", eid, 1),
						},
						"msg": func(state, side, eid, card, targets): return str("derez ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
						"display-side": "corp",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets), {
							"no-msg": true,
						}),
					} if (not NRUtil.as_array(valid_ice).is_empty()) else {
						"msg": "give the Corp 1 bad publicity",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRBadPublicity.gain_bad_publicity(state, "runner", eid, 1),
					}), card, null)
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Kraken", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Play only if you stole an agenda this turn.\nChoose a server. The Corp trashes 1 piece of ice protecting that server.",
		"code": "02090",
		"title": "Kraken",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "stole-agenda", null),
			"prompt": "Choose a server",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), NRCard.ice) != null),
			},
			"choices": func(state, side, eid, card, targets):
				return NRServers.zones_to_sorted_names(NRBoard.get_zones(state)),
			"msg": func(state, side, eid, card, targets): return str("force the Corp to trash a piece of ice protecting ") + str(NRCardXlate.first_target(targets)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var serv = (NRUtil.as_array(NRBoard.server_to_zone(state, NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRBoard.server_to_zone(state, NRCardXlate.first_target(targets))).size() > 1 else null)
				return {
					"player": "corp",
					"async": true,
					"prompt": func(state, side, eid, card, targets): return str("Choose a piece of ice in ") + str(NRCardXlate.first_target(targets)) + str(" to trash"),
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and ((serv == (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) or NRUtil.kw_eq(serv, (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))),
					},
					"effect": func(state, side, eid, card, targets):
						NRSay.system_msg(state, side, (str("trashes ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets)))))
						return NRMoving.trash(state, "corp", eid, NRCardXlate.first_target(targets), {
						"cause-card": card,
					}),
				}
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("Labor Rights", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Trash the top 3 cards of your stack. Shuffle 3 cards from your heap into your stack. Draw 1 card. Remove this event from the game instead of trashing it.",
		"code": "28001",
		"title": "Labor Rights",
	}, {
		"on-play": {
			"rfg-instead-of-trashing": true,
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) or ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).is_empty()) and (not (NRFlags.zone_locked(state, "runner", "discard"))))),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
				var mill_count = mini(3, NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).size())
				var top_n_msg = (not NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(mill_count))).is_empty())
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.mill(state, "runner", ne, "runner", mill_count)
				, func(async_result):
					(func():
					NRSay.system_msg(state, "runner", ((str("trashes ") + str(NRUtil.enumerate_cards(top_n_msg)) + str(" from the top of the stack")) if top_n_msg else "trashes no cards from the top of the stack"))
					return (func():
						var heap_count = mini(3, NRUtil.as_array(state.get_in(["runner", "discard"], null)).size())
						return NREngine.continue_ability(state, side, ({
							"prompt": (str("Choose ") + str(NRUtil.quantify(heap_count, "card")) + str(" to shuffle into the stack")),
							"show-discard": true,
							"async": true,
							"choices": {
								"max": heap_count,
								"all": true,
								"not-self": true,
								"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_discard(_pct)),
							},
							"effect": func(state, side, eid, card, targets):
								(func():
								for c in NRUtil.as_array(targets):
									NRMoving.move(state, side, c, "deck")
								return null
							).call()
								NRSay.system_msg(state, "runner", (str("shuffles ") + str(NRUtil.enumerate_cards(targets)) + str(" from the heap into the stack, and draws 1 card")))
								NRShuffling.shuffle_zone(state, "runner", "deck")
								return NRDrawing.draw(state, "runner", eid, 1),
						} if (not (NRFlags.zone_locked(state, "runner", "discard"))) else {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return (func():
								state
								side
								NRSay.system_msg(state, "runner", "shuffles the stack and draws 1 card")
								NRShuffling.shuffle_zone(state, "runner", "deck")
								return NRDrawing.draw(state, "runner", eid, 1)
							).call(),
						}), card, null)
					).call()
				).call())
			).call(),
		},
	}))

	NRCardDefs.defcard("Lawyer Up", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nRemove up to 2 tags and draw 3 cards.",
		"code": "04063",
		"title": "Lawyer Up",
	}, {
		"on-play": {
			"msg": "remove 2 tags and draw 3 cards",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.is_tagged(state) or (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty())),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRTags.lose_tags(state, side, ne, 2)
			, func(async_result):
				NRDrawing.draw(state, side, eid, 3)),
		},
	}))

	NRCardDefs.defcard("Lean and Mean", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. If you have 3 or fewer programs installed, all <strong>icebreakers</strong> have +2 strength during this run.",
		"code": "12086",
		"title": "Lean and Mean",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)) + str((", giving +2 strength to all icebreakers" if (NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(NRCard.program)).size() <= 3) else null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(pump_all_icebreakers(state, side, 2, "end-of-run") if (NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(NRCard.program)).size() <= 3) else null)
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
	}))

	NRCardDefs.defcard("Leave No Trace", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. When the run ends, derez all ice that was rezzed during this run.",
		"code": "12083",
		"title": "Leave No Trace",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "run-ends",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var rezzed_ice = NRUtil.as_array(keep(func(_p): return (NRCard.get_card(state, card) if NRCard.ice(card) else null), NREvents.run_events(NRCardXlate.first_target(targets), "rez"))).filter(NRCard.rezzed)
				return NRRezzing.derez(state, "runner", eid, rezzed_ice)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Legwork", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. If successful, access 2 additional cards when you breach HQ.",
		"code": "31019",
		"title": "Legwork",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [breach_access_bonus("hq", 2, {
				"duration": "end-of-run",
			})]),
		},
		],
	}))

	NRCardDefs.defcard("Leverage", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Play only if you made a successful run on HQ this turn.\nThe Corp may take 2 bad publicity. If they do not, whenever you would take damage until your next turn begins, prevent all of that damage.",
		"code": "04064",
		"title": "Leverage",
	}, {
		"on-play": {
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null),
				"player": "corp",
				"prompt": "Take 2 bad publicity?",
				"waiting-prompt": true,
				"yes-ability": {
					"player": "corp",
					"msg": "takes 2 bad publicity",
					"effect": func(state, side, eid, card, targets):
						return NRBadPublicity.gain_bad_publicity(state, "corp", 2),
				},
				"no-ability": {
					"player": "runner",
					"msg": "is immune to damage until the beginning of the Runner's next turn",
					"effect": func(state, side, eid, card, targets):
						return NREffects.register_lingering_effect(state, side, card, {
						"type": "prevention",
						"duration": "until-runner-turn-begins",
						"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
						"value": {
							"prevents": "damage",
							"type": "floating",
							"max-uses": 1,
							"card": card,
							"mandatory": true,
							"ability": {
								"async": true,
								"card": card,
								"condition": "floating",
								"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
								"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
								"effect": func(state, side, eid, card, targets):
									return NRPrevention.prevent_damage(state, side, eid, "all"),
							},
						},
					}),
				},
			},
		},
	}))

	NRCardDefs.defcard("Levy AR Lab Access", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Shuffle your grip and heap into your stack. Draw 5 cards. Remove Levy AR Lab Access from the game instead of trashing it.",
		"code": "03035",
		"title": "Levy AR Lab Access",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str(("shuffle the grip and heap into the stack and draw 5 cards" if (not (NRFlags.zone_locked(state, "runner", "discard"))) else "shuffle the grip into the stack and draw 5 cards")),
			"rfg-instead-of-trashing": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRShuffling.shuffle_into_deck(state, side, "hand", "discard")
				return NRDrawing.draw(state, side, eid, 5),
		},
	}))


static func _register_4() -> void:
	NRCardDefs.defcard("Lie Low", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nResolve 1 of the following:<ul><li>Draw 4 cards.</li><li>Remove up to 2 tags.</li></ul>",
		"code": "35015",
		"title": "Lie Low",
	}, (func():
		return {
			"on-play": NRChooseOne.choose_one({
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) or NRUtil.is_tagged(state)),
				},
			}, [
				{
				"option": "Draw 4 cards",
				"ability": {
					"msg": "draw 4 cards",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, side, eid, 4),
				},
			},
				{
				"option": "Remove up to 2 tags",
				"ability": NRChooseOne.choose_one(NRUtil.as_array(NRUtil.as_array([0, 1, 2]).map(remove_tag_opt))),
			},
			]),
		}
	).call()))

	NRCardDefs.defcard("Lucky Find", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nGain 9[Credits].",
		"code": "29007",
		"title": "Lucky Find",
	}, {
		"on-play": {
			"msg": "gain 9 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 9),
		},
	}))

	NRCardDefs.defcard("Mad Dash", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. When that run ends, if you stole an agenda during that run, add this event to your score area as an agenda worth 1 agenda point. Otherwise, suffer 1 meat damage.",
		"code": "12008",
		"title": "Mad Dash",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "run-ends",
			"async": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.system_msg(state, "runner", str("adds Mad Dash to [their] score area as an agenda worth 1 agenda point"))
				NRMoving.as_agenda(state, "runner", NRCard.get_card(state, card), 1)
				return NREid.effect_completed(state, side, eid)
			).call() if NRCardXlate.getk(NRCardXlate.first_target(targets), "did-steal", null) else (func():
				NRSay.system_msg(state, "runner", str("suffers 1 meat damage from Mad Dash"))
				return NRDamage.damage(state, side, eid, "meat", 1, {
					"card": card,
				})
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Maintenance Access", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Double",
		"subtypes": ["Run", "Double"],
		"text": "As an additional cost to play this event, spend [Click].\nRun Archives. When you would approach Archives <em>(after passing all ice)</em>, instead change the attacked server to HQ and approach HQ.",
		"code": "35016",
		"title": "Maintenance Access",
	}, {
		"makes-run": true,
		"events": [
			{
			"event": "pre-approach-server",
			"unregister-once-resolved": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "change the attacked server to HQ",
			"req": func(state, side, eid, card, targets): return (("archives" == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq("archives", NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
			"effect": func(state, side, eid, card, targets):
				return state.assoc_in(["run", "server"], ["hq"]),
		},
		],
		"on-play": NRCardXlate.run_server_ability("archives"),
	}))

	NRCardDefs.defcard("Making an Entrance", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nLook at the top 6 cards of your stack. You may trash any of those cards and arrange the rest in any order.",
		"code": "10058",
		"title": "Making an Entrance",
	}, (func():
		return {
			"on-play": {
				"msg": "look at and trash or rearrange the top 6 cards of the stack",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, entrance_trash(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(6))), card, null),
			},
		}
	).call()))

	NRCardDefs.defcard("Marathon", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run on a remote server. When the run ends, gain [Click] and add Marathon to your grip instead of trashing it if the run was successful. You may not make another run on that server for the remainder of this turn.",
		"code": "21046",
		"title": "Marathon",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_remote_server_ability,
		"events": [
			{
			"event": "run-ends",
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"effect": func(state, side, eid, card, targets):
				(func():
				var blocked_server = NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null))
				return NREffects.register_lingering_effect(state, side, card, {
					"type": "cannot-run-on-server",
					"req": func(state, side, eid, card, targets): return true,
					"value": [blocked_server],
					"duration": "end-of-turn",
				})
			).call()
				return ((func():
				NRSay.system_msg(state, "runner", str("gains [Click] and adds Marathon to [their] grip"))
				NRGaining.gain_clicks(state, "runner", 1)
				NRMoving.move(state, "runner", card, "hand")
				return NREngine.unregister_events(state, side, card)
			).call() if NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) else null),
		},
		],
	}))

	NRCardDefs.defcard("Mars for Martians", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nDraw 1 card for each installed <strong>clan</strong> resource. Gain 1[Credits] for each tag you have.",
		"code": "12081",
		"title": "Mars for Martians",
	}, (func():
		return {
			"on-play": {
				"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify(count_clan(state), "card")) + str(" and gain ") + str(NRCardXlate.count_tags(state)) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, count_clan(state))
				, func(async_result):
					NRGaining.gain_credits(state, side, eid, NRCardXlate.count_tags(state))),
			},
		}
	).call()))

	NRCardDefs.defcard("Mass Install", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Install up to 3 programs from your grip (paying the install costs).",
		"code": "05051",
		"title": "Mass Install",
	}, (func():
		return {
			"on-play": {
				"async": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
				},
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, mhelper(0), card, null),
			},
		}
	).call()))

	NRCardDefs.defcard("Meeting of Minds", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Choose <strong>connection</strong> or <strong>virtual</strong>. You may search your stack for 1 resource with the chosen subtype and reveal it. Add that card to your grip.\nReveal any number of cards with the chosen subtype in your grip. Gain 1[Credits] for each card revealed this way.",
		"code": "34076",
		"title": "Meeting of Minds",
	}, (func():
		var _b0 = tutor_abi([type], {
			"prompt": (str("Choose a ") + str(decapitalize(type)) + str(" resource")),
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, type)),
			"cancel": {
				"async": true,
				"msg": "shuffle the stack",
				"effect": func(state, side, eid, card, targets):
					NREngine.trigger_event(state, side, "searched-stack")
					NRShuffling.shuffle_zone(state, side, "deck")
					return NREngine.continue_ability(state, side, credit_gain_abi(type), card, null),
			},
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the stack to the grip and shuffle the stack"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				NRShuffling.shuffle_zone(state, side, "deck")
				return NREngine.continue_ability(state, side, credit_gain_abi(type), card, null),
		})
		return {
			"on-play": {
				"prompt": "Choose one",
				"async": true,
				"waiting-prompt": true,
				"choices": ["Connection", "Virtual"],
				"effect": func(state, side, eid, card, targets):
					return (func():
					var choice = NRCardXlate.first_target(targets)
					return NREngine.continue_ability(state, side, {
						"optional": {
							"prompt": (str("Search the stack for a ") + str(decapitalize(choice)) + str(" resource?")),
							"yes-ability": {
								"async": true,
								"msg": func(state, side, eid, card, targets): return str("search the stack for a ") + str(decapitalize(choice)) + str(" resource"),
								"effect": func(state, side, eid, card, targets):
									return NREngine.continue_ability(state, side, tutor_abi(choice), card, null),
							},
							"no-ability": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NREngine.continue_ability(state, side, credit_gain_abi(choice), card, null),
							},
						},
					}, card, null)
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Mining Accident", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Play only if you made a successful run on a central server this turn.\nGive the Corp 1 bad publicity unless they pay 5[Credits].\nRemove this event from the game.",
		"code": "12101",
		"title": "Mining Accident",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq", "rd", "archives"], _x)) != null),
			"rfg-instead-of-trashing": true,
			"msg": func(state, side, eid, card, targets): return str("force the corp to ") + str(decapitalize(NRCardXlate.first_target(targets))),
			"waiting-prompt": true,
			"player": "corp",
			"prompt": "Choose one",
			"choices": func(state, side, eid, card, targets):
				return [
				("Pay 5 [Credits]" if NRPayment.can_pay(state, "corp", eid, card, null, NRPayment.to_c("credit", 5)) else null),
				"Take 1 bad publicity",
			],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NREngine.pay(state, "corp", ne, NREid.make_eid(state, eid), card, NRPayment.to_c("credit", 5))
			, func(async_result):
				(func():
				NRSay.system_msg(state, "corp", msg)
				return NREid.effect_completed(state, side, eid)
			).call()) if ((NRCardXlate.first_target(targets) == "Pay 5 [Credits]") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Pay 5 [Credits]")) else NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
		},
	}))

	NRCardDefs.defcard("Möbius", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, when that run ends, you may run R&D again. If the second run is successful, gain 4[Credits].",
		"code": "12024",
		"title": "Möbius",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return rd_runnable,
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRuns.make_run(state, side, ne, "rd", card)
			, func(async_result):
				(func():
				var card = NRCard.get_card(state, card)
				return (NRRuns.make_run(state, side, eid, "rd", card) if NRUtil.get_in(card, ["special", "run-again"], null) else NREid.effect_completed(state, side, eid))
			).call()),
		},
		"events": [
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"req": func(state, side, eid, card, targets): return (NRUtil.get_in(card, ["special", "run-again"], null) and (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets))))),
			"msg": "gain 4 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 4),
		},
			{
			"event": "run-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "successful", null) and (not (NRUtil.get_in(card, ["special", "run-again"], null))) and ((["rd"] == NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)) or NRUtil.kw_eq(["rd"], NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)))),
				"prompt": "Make another run on R&D?",
				"yes-ability": {
					"effect": func(state, side, eid, card, targets):
						NRPrompts.clear_wait_prompt(state, "corp")
						return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "run-again"], true)),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Modded", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Install a program or piece of hardware, lowering the install cost by 3.",
		"code": "25043",
		"title": "Modded",
	}, {
		"on-play": {
			"prompt": "Choose a program or piece of hardware to install",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return ((NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets))) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, eid, card, {
					"cost-bonus": -3,
				})),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"cost-bonus": -3,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		},
	}))

	NRCardDefs.defcard("Moshing", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"text": "As an additional cost to play this event, trash 3 cards from your grip.\nGain 3[Credits] and draw 3 cards.",
		"code": "26067",
		"title": "Moshing",
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("trash-from-hand", 3)],
			"msg": "draw 3 cards and gain 3 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, side, ne, 3)
			, func(async_result):
				NRGaining.gain_credits(state, side, eid, 3)),
		},
	}))

	NRCardDefs.defcard("Mutual Favor", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Search your stack for 1 <strong>icebreaker</strong> and reveal it. <em>(Shuffle your stack after searching it.)</em> If you made a successful run this turn, you may install that program. If you do not, add it to your grip.",
		"code": "30011",
		"title": "Mutual Favor",
	}, {
		"on-play": {
			"prompt": "Choose an Icebreaker",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker")),
			"cancel": fail_to_find_bang,
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the stack to the grip and shuffle the stack"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				return NREngine.continue_ability(state, side, (func():
				var icebreaker = NRCardXlate.first_target(targets)
				return ({
					"optional": {
						"prompt": (str("Install ") + str(NRCardXlate.getk(icebreaker, "title", null)) + str("?")),
						"yes-ability": {
							"async": true,
							"msg": func(state, side, eid, card, targets): return str(" install ") + str(NRCardXlate.getk(icebreaker, "title", null)),
							"effect": func(state, side, eid, card, targets):
								NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), icebreaker, null)
								return NRShuffling.shuffle_zone(state, side, "deck"),
						},
						"no-ability": {
							"effect": func(state, side, eid, card, targets):
								NRMoving.move(state, side, icebreaker, "hand")
								return NRShuffling.shuffle_zone(state, side, "deck"),
						},
					},
				} if (NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), icebreaker)) else {
					"effect": func(state, side, eid, card, targets):
						NRMoving.move(state, side, icebreaker, "hand")
						return NRShuffling.shuffle_zone(state, side, "deck"),
				})
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("Net Celebrity", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\n1[recurring-credit]\nUse this credit during a run.",
		"code": "06038",
		"title": "Net Celebrity",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Networking", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Remove 1 tag. Then, you may pay 1[Credits] to add this event to your grip.",
		"code": "31020",
		"title": "Networking",
	}, {
		"on-play": {
			"async": true,
			"msg": func(state, side, eid, card, targets): return str(("remove 1 tag" if NRUtil.is_tagged(state) else "do nothing")),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRTags.lose_tags(state, side, ne, 1)
			, func(async_result):
				NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": func(state, side, eid, card, targets): return str("Pay 1 [Credits] to add ") + str(NRCardXlate.getk(card, "title", null)) + str(" to Grip?"),
					"req": func(state, side, eid, card, targets): return NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("credit", 1)]),
					"yes-ability": {
						"cost": [NRPayment.to_c("credit", 1)],
						"msg": "add itself to the Grip",
						"effect": func(state, side, eid, card, targets):
							return NRMoving.move(state, side, card, "hand"),
					},
				},
			}, card, null)),
		},
	}))

	NRCardDefs.defcard("Notoriety", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nAdd Notoriety to your score area as an agenda worth 1 agenda point.",
		"code": "25044",
		"title": "Notoriety",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
			"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.as_agenda(state, "runner", card, 1),
		},
	}))

	NRCardDefs.defcard("Office Supplies", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Reduce the play cost of Office Supplies by 1 for each [link] you have.\nGain 4[Credits] or draw 4 cards.",
		"code": "22024",
		"title": "Office Supplies",
	}, {
		"on-play": {
			"play-cost-bonus": func(state, side, eid, card, targets):
				return (-NRLink.get_link(state)),
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Gain 4 [Credits]", "Draw 4 cards"],
			"msg": func(state, side, eid, card, targets): return str(decapitalize(NRCardXlate.first_target(targets))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NRGaining.gain_credits(state, "runner", eid, 4) if ((NRCardXlate.first_target(targets) == "Gain 4 [Credits]") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Gain 4 [Credits]")) else NRDrawing.draw(state, "runner", eid, 4)),
		},
	}))

	NRCardDefs.defcard("On the Lam", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Host this event on an installed resource as a condition counter with \"[interrupt] → [Trash]<strong>:</strong> Prevent up to 3 tags or up to 3 damage.\"",
		"code": "11082",
		"title": "On the Lam",
	}, {
		"prevention": [
			{
			"prevents": "tag",
			"type": "ability",
			"prompt": "Trash On the Lam to avoid up to 3 tags?",
			"ability": NRUtil.merge(prevent_up_to_n_tags(3) if prevent_up_to_n_tags(3) is Dictionary else {}, {"cost": [NRPayment.to_c("trash-can")]}),
		},
			{
			"prevents": "damage",
			"type": "ability",
			"prompt": "Trash On the Lam to prevent up to 3 damage?",
			"ability": NRUtil.merge(prevent_up_to_n_damage(3, ["net", "meat", "core", "brain"]) if prevent_up_to_n_damage(3, ["net", "meat", "core", "brain"]) is Dictionary else {}, {"cost": [NRPayment.to_c("trash-can")]}),
		},
		],
		"on-play": {
			"prompt": "Choose a resource to host On the Lam on",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.resource(_pct) and NRCard.installed(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), NRCard.resource) != null),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, side, (str("hosts On the Lam on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))))
				return install_as_condition_counter(state, side, eid, card, NRCardXlate.first_target(targets)),
		},
	}))

	NRCardDefs.defcard("Out of the Ashes", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run.\nWhen your turn begins, if Out of the Ashes is in your heap, you may remove it from the game to make a run.\nLimit 6 per deck.",
		"code": "10080",
		"title": "Out of the Ashes",
	}, (func():
		var ashes_run = {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		}
		var ashes_recur = func(): return {
			"optional": {
				"req": func(state, side, eid, card, targets): return (not (NRFlags.zone_locked(state, "runner", "discard"))),
				"prompt": func(state, side, eid, card, targets):
					return (str("Remove Out of the Ashes from the game to make a run? (") + str(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (("Out of the Ashes" == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq("Out of the Ashes", NRCardXlate.getk(_pct, "title", null))))).size()) + str(" available)")),
				"yes-ability": {
					"async": true,
					"msg": "removes Out of the Ashes from the game to make a run",
					"effect": func(state, side, eid, card, targets):
						NRMoving.move(state, side, card, "rfg")
						return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, NREid.make_eid(state, eid), ashes_run, card, null)
					, func(async_result):
						(func():
						var next_out_of_ashes = (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), func(_pct, _pct2=null, _pct3=null): return (_pct if ((("Out of the Ashes" == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq("Out of the Ashes", NRCardXlate.getk(_pct, "title", null))) and (not (NRUtil.same_card(card, _pct)))) else null)) != null)
						return NREngine.continue_ability(state, side, ashes_recur(), NRCard.get_card(state, next_out_of_ashes), null) if next_out_of_ashes != null else NREid.effect_completed(state, side, eid)
					).call()),
				},
			},
		}
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_any_server_ability(),
			"events": [
				{
				"event": "runner-turn-begins",
				"skippable": true,
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"silent": func(state, side, eid, card, targets):
					return (func():
					var ashes = NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (("Out of the Ashes" == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq("Out of the Ashes", NRCardXlate.getk(_pct, "title", null))))
					return ((not (((card == NRUtil.first_of(ashes)) or NRUtil.kw_eq(card, NRUtil.first_of(ashes))))) or (not (NREngine.not_used_once(state, {
						"once": "per-turn",
						"once-key": "out-of-ashes",
					}, card))))
				).call(),
				"location": "discard",
				"once": "per-turn",
				"once-key": "out-of-ashes",
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, NREid.make_eid(state, eid), ashes_recur(), card, null)
				, func(async_result):
					NREid.effect_completed(state, side, eid)),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Overclock", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Place 5[Credits] on this event, then run any server. You can spend hosted credits during that run.",
		"code": "30029",
		"title": "Overclock",
	}, {
		"makes-run": true,
		"data": {
			"counter": {
				"credit": 5,
			},
		},
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
		"on-play": NRCardXlate.run_any_server_ability(),
	}))

	NRCardDefs.defcard("Paper Tripping", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nRemove all tags.",
		"code": "06015",
		"title": "Paper Tripping",
	}, {
		"on-play": {
			"msg": "remove all tags",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, side, eid, "all"),
		},
	}))

	NRCardDefs.defcard("Peace in Our Time", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click] and only if the Corp scored no agendas during their last turn.\nGain 10[Credits]. The Corp gains 5[Credits]. You cannot make any runs this turn.",
		"code": "11109",
		"title": "Peace in Our Time",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return (not (NRCardXlate.getk(state.get_in(["corp", "register-last-turn"], {}), "scored-agenda", null))),
			"msg": "gain 10 [Credits]. The Corp gains 5 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, "runner", ne, 10)
			, func(async_result):
				(func():
				NRFlags.register_turn_flag(state, side, card, "can-run", null)
				return NRGaining.gain_credits(state, "corp", eid, 5)
			).call()),
		},
	}))

	NRCardDefs.defcard("Pinhole Threading", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. If successful, instead of breaching the attacked server, access 1 card in the root of another server. If that card is an agenda, you cannot steal or trash it during this access.",
		"code": "33013",
		"title": "Pinhole Threading",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"mandatory": true,
			"this-card-run": true,
			"ability": {
				"prompt": "Choose a card in the root of another server to access",
				"choices": {
					"req": func(state, side, eid, card, targets): return ((not (((NRUtil.first_of(NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "server", null)) == (NRUtil.as_array(NRCard.get_zone(NRCard.get_nested_host(NRCardXlate.first_target(targets))))[1] if NRUtil.as_array(NRCard.get_zone(NRCard.get_nested_host(NRCardXlate.first_target(targets)))).size() > 1 else null)) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "server", null)), (NRUtil.as_array(NRCard.get_zone(NRCard.get_nested_host(NRCardXlate.first_target(targets))))[1] if NRUtil.as_array(NRCard.get_zone(NRCard.get_nested_host(NRCardXlate.first_target(targets)))).size() > 1 else null))))) and ((NRUtil.last_of(NRCard.get_zone(NRCard.get_nested_host(NRCardXlate.first_target(targets)))) == "content") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(NRCard.get_nested_host(NRCardXlate.first_target(targets)))), "content"))),
				},
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return ((func():
					var protected_card = NRCardXlate.first_target(targets)
					return (func():
						NRFlags.register_run_flag(state, side, card, "can-steal", func(_, _, c): return (not (NRUtil.same_card(c, protected_card))))
						NRFlags.register_run_flag(state, side, card, "can-trash", func(_, _, c): return (not (NRUtil.same_card(c, protected_card))))
						return NREid.wait_for(state, eid, func(ne):
							NRAccess.access_card(state, side, ne, protected_card)
						, func(async_result):
							(func():
							NRFlags.clear_run_flag(state, side, card, "can-steal")
							NRFlags.clear_run_flag(state, side, card, "can-trash")
							return NREid.effect_completed(state, side, eid)
						).call())
					).call()
				).call() if NRCard.agenda(NRCardXlate.first_target(targets)) else NRAccess.access_card(state, side, eid, NRCardXlate.first_target(targets))),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Planned Assault", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nSearch your stack for a <strong>run</strong> event and play that <strong>run</strong> event (paying its play cost), ignoring any additional costs. Shuffle your stack.",
		"code": "05036",
		"title": "Planned Assault",
	}, {
		"on-play": {
			"prompt": "Choose a Run event",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Run") and NRPayment.can_pay(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, null, [NRPayment.to_c("credit", NRCostFns.play_cost(state, side, _pct))])))),
			"msg": func(state, side, eid, card, targets): return str("play ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRPlayInstants.play_instant(state, side, eid, NRCardXlate.first_target(targets), {
				"no-additional-cost": true,
			}),
		},
	}))

	NRCardDefs.defcard("Political Graffiti", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run Archives. If successful, instead of breaching Archives, host this event on an agenda in the Corp's score area as a condition counter with \"Host agenda is worth 1 less agenda point. When the Corp purges virus counters, trash this counter.\"",
		"code": "10039",
		"title": "Political Graffiti",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("archives"),
		"static-abilities": [
			{
			"type": "agenda-value",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(card, "host", null), NRCardXlate.first_target(targets)),
			"value": -1,
		},
		],
		"events": [
			{
			"event": "purge",
			"condition": "hosted",
			"async": true,
			"msg": "trash itself",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash(state, "runner", ne, card, {
				"cause": "purge",
				"cause-card": card,
			})
			, func(async_result):
				(func():
				NRAgendas.update_all_agenda_points(state, side)
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
			NRCardXlate.successful_run_replace_breach({
			"target-server": "archives",
			"this-card-run": true,
			"mandatory": true,
			"ability": {
				"prompt": func(state, side, eid, card, targets): return str("Choose an agenda to host ") + str(NRCardXlate.getk(card, "title", null)) + str(" on"),
				"choices": {
					"req": func(state, side, eid, card, targets): return NRFlags.in_corp_scored(state, side, NRCardXlate.first_target(targets)),
				},
				"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" as a hosted condition counter"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					install_as_condition_counter(state, side, ne, NREid.make_eid(state, eid), card, NRCardXlate.first_target(targets))
				, func(async_result):
					(func():
					NRAgendas.update_all_agenda_points(state, side)
					return NREid.effect_completed(state, side, eid)
				).call()),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Populist Rally", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Play only if you have a <strong>seedy</strong> card installed.\nThe Corp gets -1 allotted [Click] for their next turn.",
		"code": "10026",
		"title": "Populist Rally",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Seedy"))).is_empty()),
			"msg": "give the Corp 1 fewer [Click] to spend on [corp-pronoun] next turn",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose(state, "corp", "click-per-turn", 1),
		},
		"events": [
			{
			"event": "corp-turn-ends",
			"duration": "until-corp-turn-ends",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain(state, "corp", "click-per-turn", 1),
		},
		],
	}))

	NRCardDefs.defcard("Power Nap", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nGain 2[Credits]. Gain an additional 1[Credits] for each <strong>double</strong> event in your heap.",
		"code": "04107",
		"title": "Power Nap",
	}, {
		"on-play": {
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("gain ") + str((2 + NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Double"))).size())) + str(" [Credits]"),
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, (2 + NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Double"))).size())),
		},
	}))

	NRCardDefs.defcard("Power to the People", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nThe first time you access an agenda this turn, gain 7[Credits].",
		"code": "08101",
		"title": "Power to the People",
	}, {
		"events": [
			{
			"event": "access",
			"req": func(state, side, eid, card, targets): return (NRCard.agenda(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)) and NREvents.first_event(state, side, "access", func(_pct, _pct2=null, _pct3=null): return NRCard.agenda(NRCardXlate.getk(NRUtil.first_of(_pct), "accessed-card", null)))),
			"duration": "end-of-turn",
			"unregister-once-resolved": true,
			"msg": "gain 7 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 7),
		},
		],
	}))

	NRCardDefs.defcard("Prey", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Apex",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. Once during this run, when you pass a piece of ice, you may trash a number of your installed cards equal to the strength of that ice. If you do, trash that ice.",
		"code": "09031",
		"title": "Prey",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "pass-ice",
			"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and NREngine.not_used_once(state, {
				"once": "per-run",
			}, card) and (NRIce.get_strength(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) <= NRUtil.as_array(NRBoard.all_installed(state, "runner")).size())),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return ({
					"optional": {
						"prompt": (str("Trash ") + str(NRUtil.quantify(NRIce.get_strength(ice), "installed card")) + str(" to trash ") + str(NRCardXlate.getk(ice, "title", null)) + str("?")),
						"once": "per-run",
						"yes-ability": {
							"async": true,
							"cost": [NRPayment.to_c("trash-installed", NRIce.get_strength(ice))],
							"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, ice)),
							"effect": func(state, side, eid, card, targets):
								return NRMoving.trash(state, side, eid, ice, {
								"cause-card": card,
							}),
						},
					},
				} if (NRIce.get_strength(ice) > 0) else {
					"optional": {
						"prompt": (str("Trash ") + str(NRCardXlate.getk(ice, "title", null)) + str("?")),
						"once": "per-run",
						"yes-ability": {
							"async": true,
							"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRToString.card_str(state, ice)),
							"effect": func(state, side, eid, card, targets):
								return NRMoving.trash(state, side, eid, ice, {
								"cause-card": card,
							}),
						},
					},
				})
			).call(), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Privileged Access", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Play only if you are not tagged.\nRun Archives. If successful, instead of breaching Archives, take 1 tag.\nWhen you take a tag with this event, you may install 1 resource from your heap, paying 2[Credits] less.\nThreat 3 → When you take a tag with this event, you may install 1 program from your heap.",
		"code": "34068",
		"title": "Privileged Access",
	}, (func():
		var install_program_from_heap = {
			"prompt": "Choose a program to install",
			"waiting-prompt": true,
			"async": true,
			"req": func(state, side, eid, card, targets): return ((not (NRUtil.get_in(card, ["special", "maybe-a-bonus-tag"], null))) and (not (NRFlags.zone_locked(state, "runner", "discard"))) and (not (NRInstalling.install_locked(state, side))) and NRThreat.threat_level(3, state)),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"ability-name": "Privileged Access (program)",
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct))))).is_empty())) + NRUtil.as_array(["Done"])),
			"effect": func(state, side, eid, card, targets):
				return (NREid.effect_completed(state, side, eid) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else (func():
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "maybe-a-bonus-tag"], true))
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card})), NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
				})
				, func(async_result):
					(func():
					NRUpdate.update_card(state, side, NRUtil.dissoc_in(card, ["special", "maybe-a-bonus-tag"]))
					return NREid.effect_completed(state, side, eid)
				).call())
			).call()),
		}
		var install_resource_from_heap = {
			"prompt": "Choose a resource to install, paying 2 [Credits] less",
			"waiting-prompt": true,
			"req": func(state, side, eid, card, targets): return ((not (NRUtil.get_in(card, ["special", "maybe-a-bonus-tag"], null))) and (not (NRFlags.zone_locked(state, "runner", "discard"))) and (not (NRInstalling.install_locked(state, side)))),
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"ability-name": "Privileged Access (resource)",
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.resource(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
				"cost-bonus": -2,
			}))))).is_empty())) + NRUtil.as_array(["Done"])),
			"effect": func(state, side, eid, card, targets):
				return (NREid.effect_completed(state, side, eid) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else (func():
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "maybe-a-bonus-tag"], true))
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card})), NRCardXlate.first_target(targets), {
					"cost-bonus": -2,
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
				})
				, func(async_result):
					(func():
					NRUpdate.update_card(state, side, NRUtil.dissoc_in(card, ["special", "maybe-a-bonus-tag"]))
					return NREid.effect_completed(state, side, eid)
				).call())
			).call()),
		}
		return {
			"makes-run": true,
			"on-play": NRUtil.merge(NRCardXlate.run_server_ability("archives") if NRCardXlate.run_server_ability("archives") is Dictionary else {}, {"req": func(state, side, eid, card, targets):
				return (not (NRUtil.is_tagged(state)))}),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "archives",
				"this-card-run": true,
				"mandatory": true,
				"ability": {
					"async": true,
					"msg": "take 1 tag",
					"effect": func(state, side, eid, card, targets):
						NREngine.register_pending_event(state, "runner-gain-tag", card, install_resource_from_heap)
						NREngine.register_pending_event(state, "runner-gain-tag", card, install_program_from_heap)
						return NREid.wait_for(state, eid, func(ne):
						NRTags.gain_tags(state, "runner", ne, 1)
					, func(async_result):
						(func():
						NREngine.unregister_events(state, side, card)
						return NREid.effect_completed(state, side, eid)
					).call()),
				},
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Process Automation", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Gain 2[Credits] and draw 1 card.",
		"code": "13023",
		"title": "Process Automation",
	}, {
		"on-play": {
			"msg": "gain 2 [Credits] and draw 1 card",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 2)
			, func(async_result):
				NRDrawing.draw(state, side, eid, 1)),
		},
	}))

	NRCardDefs.defcard("Push Your Luck", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Secretly spend any number of credits. The Corp guesses if you spent an even or odd amount. Reveal spent credits. If the Corp guessed incorrectly, gain credits equal to twice the amount spent.",
		"code": "05047",
		"title": "Push Your Luck",
	}, (func():
		var _b0 = runner_choice([choices], {
			"prompt": "How many credits do you want to spend?",
			"waiting-prompt": true,
			"choices": choices,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, "corp", corp_choice(str_to_int(NRCardXlate.first_target(targets))), card, null),
		})
		return {
			"on-play": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var all_amounts = _range((state.get_in(["runner", "credit"], null) + 1))
					var valid_amounts = NRUtil.as_array(all_amounts).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return (NRFlags.any_flag_fn(state, "corp", "prevent-secretly-spend", _pct) or NRFlags.any_flag_fn(state, "runner", "prevent-secretly-spend", _pct))).call(_x)))
					var choices = NRUtil.as_array(valid_amounts).map(str)
					return NREngine.continue_ability(state, side, runner_choice(choices), card, null)
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Pushing the Envelope", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. If you have 2 or fewer cards in your grip, each installed <strong>icebreaker</strong> has +2 strength until the end of the run.",
		"code": "12001",
		"title": "Pushing the Envelope",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"msg": func(state, side, eid, card, targets): return str(("make a run, and give +2 strength to installed icebreakers" if (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() <= 2) else "make a run")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(pump_all_icebreakers(state, side, 2, "end-of-run") if (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() <= 2) else null)
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
	}))

	NRCardDefs.defcard("Quality Time", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Draw 5 cards.",
		"code": "02087",
		"title": "Quality Time",
	}, {
		"on-play": NRDefHelpers.draw_ability(5),
	}))

	NRCardDefs.defcard("Queen's Gambit", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nPlace up to 3 advancement counters on 1 unrezzed card in the root of a remote server. Gain 2[Credits] for each counter placed this way. You cannot access that card for the remainder of the turn.",
		"code": "25003",
		"title": "Queen's Gambit",
	}, {
		"on-play": {
			"choices": ["0", "1", "2", "3"],
			"prompt": "How many advancement counters do you want to place?",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var c = str_to_int(NRCardXlate.first_target(targets))
				return {
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) and ((NRUtil.last_of(NRCard.get_zone(_pct)) == "content") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(_pct)), "content")) and (not (NRCardXlate.getk(_pct, "rezzed", null)))),
					},
					"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(c, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" and gain ") + str((2 * c)) + str(" [Credits]"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, (2 * c))
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
						NRProps.add_prop(state, "corp", ne, NRCardXlate.first_target(targets), "advance-counter", c, {
						"placed": true,
					})
					, func(async_result):
						(func():
						NRFlags.register_turn_flag(state, side, card, "can-access", func(_, _, card): return (not (NRUtil.same_card(NRCardXlate.first_target(targets), card))))
						return NREid.effect_completed(state, side, eid)
					).call())),
				}
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("Quest Completed", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nAccess 1 installed card (non-ice).",
		"code": "25004",
		"title": "Quest Completed",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["rd"], _x)) != null) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["archives"], _x)) != null)),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return not NRCard.ice.call(_x)) != null),
			},
			"choices": {
				"card": NRCard.installed,
			},
			"msg": func(state, side, eid, card, targets): return str("access ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRAccess.access_card(state, side, eid, NRCardXlate.first_target(targets)),
		},
	}))

	NRCardDefs.defcard("Raindrops Cut Stone", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. Whenever a subroutine resolves during that run <em>(including a subroutine that ends the run)</em>, place 1 power counter on this event.\nWhen that run ends, draw 1 card for each hosted power counter and gain 3[Credits].",
		"code": "33068",
		"title": "Raindrops Cut Stone",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "subroutine-fired",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(card, "zone", null)), func(_pct, _pct2=null, _pct3=null): return ((_pct == "play-area") or NRUtil.kw_eq(_pct, "play-area"))) != null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, NRCard.get_card(state, card), "power", 1, null),
		},
			{
			"event": "run-ends",
			"async": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var cards_to_draw = NRCard.get_counters(NRCard.get_card(state, card), "power")
				return NREngine.continue_ability(state, side, {
					"msg": func(state, side, eid, card, targets): return str(((str("draw ") + str(NRUtil.quantify(cards_to_draw, "card")) + str(" and gain 3 [Credits]")) if (cards_to_draw > 0) else "gain 3 [Credits]")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, side, ne, cards_to_draw)
					, func(async_result):
						NRGaining.gain_credits(state, side, eid, 3)) if (cards_to_draw > 0) else NRGaining.gain_credits(state, side, eid, 3)),
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Rebirth", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Switch your identity with another identity from the same faction. Remove Rebirth from the game instead of trashing it.\nLimit 1 per deck.",
		"code": "10083",
		"title": "Rebirth",
	}, {
		"on-play": {
			"prompt": "Choose an identity",
			"rfg-instead-of-trashing": true,
			"choices": func(state, side, eid, card, targets):
				return (func():
				var is_draft_id_p = func(_pct, _pct2=null, _pct3=null): return str(NRCardXlate.getk(_pct, "code", null)).begins_with("00")
				var runner_identity = NRCardXlate.getk(state.getv("runner", {}), "identity", null)
				var format = NRCardXlate.getk(state, "format", null)
				var is_swappable = func(_pct, _pct2=null, _pct3=null): return ((("Identity" == NRCardXlate.getk(_pct, "type", null)) or NRUtil.kw_eq("Identity", NRCardXlate.getk(_pct, "type", null))) and (("Runner" == NRCardXlate.getk(_pct, "side", null)) or NRUtil.kw_eq("Runner", NRCardXlate.getk(_pct, "side", null))) and ((NRCardXlate.getk(runner_identity, "faction", null) == NRCardXlate.getk(_pct, "faction", null)) or NRUtil.kw_eq(NRCardXlate.getk(runner_identity, "faction", null), NRCardXlate.getk(_pct, "faction", null))) and (not (is_draft_id_p(_pct))) and (not (((NRCardXlate.getk(runner_identity, "title", null) == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(runner_identity, "title", null), NRCardXlate.getk(_pct, "title", null))))) and (NRUtil.in_coll(["casual", "quick-draft", "preconstructed"], format) or legal_p(format, "legal", _pct)))
				var swappable_ids = NRUtil.as_array(server_cards()).filter(is_swappable)
				return NRUtil.as_array(swappable_ids)
			).call(),
			"msg": "change identities",
			"effect": func(state, side, eid, card, targets):
				(func():
				var old_runner_identity = NRCardXlate.getk(state.getv("runner", {}), "identity", null)
				return (func():
					(func():
						for c in NRUtil.as_array(NRCardXlate.getk(old_runner_identity, "hosted", null)):
							NRMoving.move(state, side, c, "temp-hosted")
						return null
					).call()
					NRIdentities.disable_identity(state, side)
					return (func():
						var new_id = NRUtil.merge(NRInitializing.make_card(server_card(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))) if NRInitializing.make_card(server_card(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))) is Dictionary else {}, {"zone": [NRPayment.to_c("identity")]})
						var num_old_blanks = NRCardXlate.getk(old_runner_identity, "num-disabled", null)
						return (func():
							state.assoc_in([side, "identity"], new_id)
							NRInitializing.card_init(state, side, new_id)
							return ((func():
								for _ in range(int(num_old_blanks)):
									NRIdentities.disable_identity(state, side)
								return null
							).call() if num_old_blanks else null)
						).call()
					).call()
				).call()
			).call()
				return (func():
				for c in NRUtil.as_array(state.get_in(["runner", "temp-hosted"], null)):
					NRHosting.host(state, side, state.get_in(["runner", "identity"], null), c, {
				"facedown": true,
			})
				return null
			).call(),
		},
	}))

	NRCardDefs.defcard("Reboot", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Apex",
		"cost": 1,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run Archives. If successful, instead of breaching Archives, install up to 5 cards from your heap facedown.\nRemove this event from the game.",
		"code": "22023",
		"title": "Reboot",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRUtil.merge(NRCardXlate.run_server_ability("archives") if NRCardXlate.run_server_ability("archives") is Dictionary else {}, {"rfg-instead-of-trashing": true}),
			"events": [
				NRCardXlate.successful_run_replace_breach({
				"target-server": "archives",
				"this-card-run": true,
				"mandatory": true,
				"ability": {
					"req": func(state, side, eid, card, targets): return (not (NRFlags.zone_locked(state, "runner", "discard"))),
					"async": true,
					"prompt": "Choose up to 5 cards to install",
					"show-discard": true,
					"choices": {
						"max": 5,
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_discard(_pct) and NRCard.runner(_pct)),
					},
					"effect": func(state, side, eid, card, targets):
						return install_cards(state, side, eid, card, targets, NRUtil.as_array(targets).map(func(_x): return bool(NRCardXlate.getk(_x, "title")))),
				},
			}),
			],
		}
	).call()))


static func _register_5() -> void:
	NRCardDefs.defcard("Recon", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. You may jack out when you encounter the first piece of ice.",
		"code": "04024",
		"title": "Recon",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": NRCardXlate.getk(NRDefHelpers.offer_jack_out({
				"req": func(state, side, eid, card, targets): return NREvents.first_run_event(state, side, "encounter-ice"),
			}), "optional", null),
		},
		],
	}))

	NRCardDefs.defcard("Rejig", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "As an additional cost to play this event, add 1 installed program or piece of hardware to your grip.\nInstall 1 program or piece of hardware from your grip, paying X[Credits] less. X is equal to the printed install cost of the card you added to your grip.",
		"code": "26029",
		"title": "Rejig",
	}, (func():
		var valid_target_p = func(card): return (NRCard.runner(card) and (NRCard.program(card) or NRCard.hardware(card)))
		var pick_up = {
			"async": true,
			"prompt": "Choose a program or piece of hardware to add to the grip",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (valid_target_p(_pct) and NRCard.installed(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				return NREid.complete_with_result(state, side, eid, NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null)),
		}
		var put_down = func(bonus): return {
			"async": true,
			"prompt": "Choose a program or piece of hardware to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return (valid_target_p(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": (-bonus),
				})),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"cost-bonus": (-bonus),
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		}
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), valid_target_p) != null),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, pick_up, card, null)
				, func(install_cost):
					NREngine.continue_ability(state, side, put_down(NRCostFns.install_cost), card, null)),
			},
		}
	).call()))

	NRCardDefs.defcard("Reprise", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Play only if you stole an agenda this turn.\nAdd 1 installed Corp card to HQ. You may run any server.",
		"code": "33076",
		"title": "Reprise",
	}, (func():
		return {
			"makes-run": true,
			"on-play": {
				"async": true,
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state.get_in(["runner", "register"], {}), "stole-agenda", null),
				"prompt": "Choose an installed Corp card to add to HQ",
				"waiting-prompt": true,
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.corp(_pct)),
				},
				"msg": func(state, side, eid, card, targets): return str("add ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" to HQ"),
				"cancel": opt_run(),
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "hand")
					return NREngine.continue_ability(state, side, opt_run(), card, null),
			},
		}
	).call()))

	NRCardDefs.defcard("Reshape", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 4,
		"uniqueness": false,
		"text": "Swap 2 pieces of unrezzed ice.",
		"code": "12107",
		"title": "Reshape",
	}, {
		"on-play": {
			"prompt": "Choose 2 unrezzed pieces of ice to swap positions",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.rezzed(_pct))) and NRCard.ice(_pct)),
				"max": 2,
				"all": true,
			},
			"msg": func(state, side, eid, card, targets): return str("swap the positions of ") + str(NRToString.card_str(state, NRUtil.first_of(targets))) + str(" and ") + str(NRToString.card_str(state, (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null))),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.swap_ice(state, side, NRUtil.first_of(targets), (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null)),
		},
	}))

	NRCardDefs.defcard("Retrieval Run", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run Archives. If successful, instead of breaching Archives, you may install 1 program from your heap, ignoring all costs.",
		"code": "31004",
		"title": "Retrieval Run",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("archives"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "archives",
			"this-card-run": true,
			"ability": {
				"async": true,
				"req": func(state, side, eid, card, targets): return ((not (NRFlags.zone_locked(state, "runner", "discard"))) and (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_install(state, side, eid, _pct, {
					"no-toast": true,
				})))).is_empty())),
				"prompt": "Choose a program to install",
				"waiting-prompt": true,
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_install(state, side, eid, _pct, {
					"no-toast": true,
				}))),
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
					},
					"ignore-all-cost": true,
				}),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Rigged Results", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Secretly spend up to 2[Credits]. The Corp guesses how much you spent. Reveal spent credits. If the Corp guessed incorrectly, choose a piece of ice protecting a server and run that server. The first time during this run you encounter the chosen ice, bypass it.",
		"code": "10102",
		"title": "Rigged Results",
	}, (func():
		var _b0 = corp_choice([choices, spent], {
			"player": "corp",
			"waiting-prompt": true,
			"prompt": "How many credits were spent?",
			"choices": choices,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.lose_credits(state, "runner", ne, NREid.make_eid(state, eid), spent)
			, func(async_result):
				(func():
				NRSay.system_msg(state, "runner", (str("spends ") + str(spent) + str(" [Credit]")))
				NRSay.system_msg(state, "corp", (str(" guesses ") + str(NRCardXlate.first_target(targets)) + str(" [Credit]")))
				return NREid.wait_for(state, eid, func(ne):
					NREngine.trigger_event_simult(state, side, ne, "reveal-spent-credits", null, {
					"runner-credits": spent,
				})
				, func(async_result):
					(NREngine.continue_ability(state, "runner", choose_ice(), card, null) if (not (((spent == str_to_int(NRCardXlate.first_target(targets))) or NRUtil.kw_eq(spent, str_to_int(NRCardXlate.first_target(targets)))))) else NREid.effect_completed(state, side, eid)))
			).call()),
		})
		return {
			"on-play": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var all_amounts = _range(mini(3, (state.get_in(["runner", "credit"], null) + 1)))
					var valid_amounts = NRUtil.as_array(all_amounts).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return (NRFlags.any_flag_fn(state, "corp", "prevent-secretly-spend", _pct) or NRFlags.any_flag_fn(state, "runner", "prevent-secretly-spend", _pct))).call(_x)))
					var choices = NRUtil.as_array(valid_amounts).map(str)
					return NREngine.continue_ability(state, side, runner_choice(choices), card, null)
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Rigging Up", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Install 1 program or piece of hardware from your grip, paying 3[Credits] less. You may charge that card if able. <em>(If it has a power counter on it, add another.)</em>",
		"code": "33024",
		"title": "Rigging Up",
	}, {
		"on-play": {
			"prompt": "Choose a program or piece of hardware to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return ((NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets))) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"cost-bonus": -3,
				})),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, {
				"source": card,
			}), NRCardXlate.first_target(targets), {
				"cost-bonus": -3,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
			, func(rig_target):
				NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": (str("Charge ") + str(NRCardXlate.getk(rig_target, "title", null)) + str("?")),
					"req": func(state, side, eid, card, targets): return NRCharge.can_charge(state, side, rig_target),
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRCharge.charge_card(state, side, eid, rig_target),
						"msg": func(state, side, eid, card, targets): return str("charge ") + str(NRCardXlate.getk(rig_target, "title", null)),
					},
				},
			}, card, null)),
		},
	}))

	NRCardDefs.defcard("Rip Deal", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. If successful, when you determine the number of cards in HQ you are allowed to access during this run's breach of HQ, you may add that many cards from your heap to your grip. If you do, you cannot access any cards in HQ during this breach. <em>(You can still access cards in the root of HQ.)</em>\nWhen the run ends, remove this event from the game.",
		"code": "12084",
		"title": "Rip Deal",
	}, (func():
		var add_cards_from_heap = {
			"optional": {
				"prompt": "Add cards from heap to grip?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets): return (state.getv("run") and (NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() > 0) and (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).size() > 0) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var random_access_limit = NRCardXlate.getk(num_cards_to_access(state, side, "hq", null), "random-access-limit", null)
						var cards_to_move = NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()
						return NREngine.continue_ability(state, side, {
							"async": true,
							"show-discard": true,
							"prompt": (str("Choose ") + str(NRUtil.quantify(cards_to_move, "card")) + str(" to add from the heap to the grip")),
							"msg": func(state, side, eid, card, targets): return str("add ") + str(NRUtil.enumerate_cards(targets, "sorted")) + str(" from the heap to the grip"),
							"choices": {
								"max": cards_to_move,
								"all": true,
								"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_discard(_pct)),
							},
							"effect": func(state, side, eid, card, targets):
								(func():
								for c in NRUtil.as_array(targets):
									NRMoving.move(state, side, c, "hand")
								return null
							).call()
								state.assoc_in(["run", "prevent-hand-access"], true)
								return NREid.effect_completed(state, side, eid),
						}, card, null)
					).call(),
				},
			},
		}
		return {
			"makes-run": true,
			"on-play": NRUtil.merge(NRCardXlate.run_server_ability("hq") if NRCardXlate.run_server_ability("hq") is Dictionary else {}, {"rfg-instead-of-trashing": true}),
			"events": [
				{
				"event": "successful-run",
				"automatic": "draw-cards",
				"silent": true,
				"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
				"effect": func(state, side, eid, card, targets):
					return NREngine.register_events(state, side, card, [
					{
					"event": "candidates-determined",
					"duration": "end-of-run",
					"async": true,
					"req": func(state, side, eid, card, targets): return (("hq" == NRCardXlate.getk(NRCardXlate.ctx(targets), "breached-server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk(NRCardXlate.ctx(targets), "breached-server", null))),
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, add_cards_from_heap, card, null),
				},
				]),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Ritual", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Draw 1 card for each [Click] you have remaining.",
		"code": "35026",
		"title": "Ritual",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": func(state, side, eid, card, targets):
				return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) and (state.get_in(["runner", "click"], 0) > 0)),
			"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify(state.get_in(["runner", "click"], null), "card")),
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, state.get_in(["runner", "click"], 0)),
		},
	}))

	NRCardDefs.defcard("Rumor Mill", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nEach unique (♦) non-<strong>region</strong> asset and upgrade loses its printed abilities.",
		"code": "11022",
		"title": "Rumor Mill",
	}, (func():
		return {
			"static-abilities": [
				{
				"type": "disable-card",
				"req": func(state, side, eid, card, targets): return eligible_p(NRCardXlate.first_target(targets)),
				"value": true,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Run Amok", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Make a run. When the run ends, trash 1 piece of ice that was rezzed during this run.",
		"code": "25006",
		"title": "Run Amok",
	}, (func():
		return {
			"makes-run": true,
			"on-play": {
				"prompt": "Choose a server",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
				},
				"choices": func(state, side, eid, card, targets):
					return NRCardXlate.runnable_servers(state, side, eid, card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "run-amok"], get_rezzed_cids(NRBoard.all_installed(state, "corp"))))
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), NRCard.get_card(state, card)),
			},
			"events": [
				{
				"event": "run-ends",
				"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var new = NRUtil.as_array(get_rezzed_cids(NRBoard.all_installed(state, "corp")))
					var old = NRUtil.as_array(NRUtil.get_in(NRCard.get_card(state, card), ["special", "run-amok"], null))
					var diff_cid = (not NRUtil.as_array(set_difference(new, old)).is_empty())
					var diff = NRUtil.as_array(diff_cid).map(func(_pct, _pct2=null, _pct3=null): return NRFinding.find_cid(_pct, NRBoard.all_installed(state, "corp")))
					return NREngine.continue_ability(state, "runner", ({
						"async": true,
						"prompt": "Choose an ice to trash",
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRUtil.find_first(NRUtil.as_array(diff), func(_x): return NRUtil.same_card.call(_pct, _x)) != null),
							"all": true,
						},
						"effect": func(state, side, eid, card, targets):
							return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
							"cause-card": card,
						}),
					} if (not NRUtil.as_array(diff).is_empty()) else null), card, null)
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Running Hot", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "As an additional cost to play this event, suffer 1 core damage.\nGain [Click][Click][Click].",
		"code": "33003",
		"title": "Running Hot",
	}, {
		"on-play": {
			"msg": "gain [Click][Click][Click]",
			"additional-cost": [NRPayment.to_c("brain", 1)],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, side, 3)
				return NREid.effect_completed(state, side, eid),
		},
	}))

	NRCardDefs.defcard("Running Interference", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Double - Run",
		"subtypes": ["Double", "Run"],
		"text": "As an additional cost to play this event, spend [Click].\nMake a run. During this run, the Corp must pay X[Credits] as an additional cost to rez each piece of ice, where X is the rez cost of that ice.",
		"code": "04044",
		"title": "Running Interference",
	}, {
		"makes-run": true,
		"static-abilities": [
			{
			"type": "rez-additional-cost",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NRCard.ice(NRCardXlate.first_target(targets))),
			"value": func(state, side, eid, card, targets):
				return [
				NRPayment.to_c("credit", NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null)),
			],
		},
		],
		"on-play": NRCardXlate.run_any_server_ability(),
	}))

	NRCardDefs.defcard("S-Dobrado", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run a central server. The first time you encounter a piece of ice during that run, bypass it.\nThreat 4 → The second time you encounter a piece of ice during that run, you may spend [Click] to bypass it. <em>(This ability is active if any player has 4 or more agenda points.)</em>",
		"code": "34012",
		"title": "S-Dobrado",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_central_server_ability,
		"events": [
			{
			"event": "encounter-ice",
			"automatic": "bypass",
			"req": func(state, side, eid, card, targets): return NREvents.first_run_event(state, side, "encounter-ice"),
			"once": "per-run",
			"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.bypass_ice(state),
		},
			{
			"event": "encounter-ice",
			"skippable": true,
			"req": func(state, side, eid, card, targets): return (((2 == NRUtil.as_array(NREvents.run_events(state, side, "encounter-ice")).size()) or NRUtil.kw_eq(2, NRUtil.as_array(NREvents.run_events(state, side, "encounter-ice")).size())) and NRThreat.threat_level(4, state)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": func(state, side, eid, card, targets): return str("Spend [Click] to bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str("?"),
					"waiting-prompt": true,
					"yes-ability": {
						"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
						"cost": [NRPayment.to_c("click", 1)],
						"effect": func(state, side, eid, card, targets):
							return NRCardXlate.bypass_ice(state),
					},
				},
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Satellite Uplink", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Expose up to 2 cards.",
		"code": "02023",
		"title": "Satellite Uplink",
	}, {
		"on-play": {
			"choices": {
				"max": func(state, side, eid, card, targets):
					return mini(2, NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(func(_x): return not NRCard.faceup.call(_x))).size()),
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and NRCard.installed(_pct) and (not (NRCard.rezzed(_pct)))),
			},
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return not NRCard.faceup.call(_x)) != null),
			},
			"effect": func(state, side, eid, card, targets):
				return (NRExpose.expose(state, side, eid, targets) if (NRUtil.as_array(targets).size() > 0) else NREid.effect_completed(state, side, eid)),
		},
	}))

	NRCardDefs.defcard("Scavenge", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "As an additional cost to play this event, trash 1 installed program.\n Install 1 program from your grip or heap, paying X[Credits] less. X is equal to the install cost of the program you trashed.",
		"code": "03034",
		"title": "Scavenge",
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.installed(_pct))) != null),
			"prompt": "Choose an installed program to trash",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.installed(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var trashed = NRCardXlate.first_target(targets)
				var tcost = NRCardXlate.getk(trashed, "cost", null)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
					"unpreventable": true,
					"cause-card": card,
				})
				, func(async_result):
					NREngine.continue_ability(state, side, {
					"async": true,
					"prompt": ("Choose a program to install from the grip or heap" if (not (NRFlags.zone_locked(state, "runner", "discard"))) else "Choose a program to install"),
					"show-discard": (not (NRFlags.zone_locked(state, "runner", "discard"))),
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) or (NRCard.in_discard(NRCardXlate.first_target(targets)) and (not (NRFlags.zone_locked(state, "runner", "discard"))))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
							"cost-bonus": (-tcost),
						})),
					},
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(trashed, "title", null)) + str(" and install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(", lowering the cost by ") + str(tcost) + str(" [Credits]"),
					"effect": func(state, side, eid, card, targets):
						return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
						"cost-bonus": (-tcost),
					}),
				}, card, null))
			).call(),
		},
	}))

	NRCardDefs.defcard("Scrounge", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nInstall 1 program from your heap. You may add 1 program from your heap to the bottom of your stack.",
		"code": "35004",
		"title": "Scrounge",
	}, (func():
		var bottom_one_program = {
			"prompt": "Put a program on the bottom of the stack?",
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(NRCard.program)).is_empty()),
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCard.in_discard(NRCardXlate.first_target(targets))),
			},
			"show-discard": true,
			"msg": func(state, side, eid, card, targets): return str("put ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" on the bottom of the stack"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRCardXlate.first_target(targets), "deck"),
		}
		return {
			"on-play": {
				"prompt": "Choose a program to install",
				"label": "Install program from the heap",
				"show-discard": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)), NRCard.program) != null),
				},
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCard.in_discard(NRCardXlate.first_target(targets)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRInstalling.runner_install(state, side, ne, NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
						"include-cost-from-eid": eid,
					},
				})
				, func(async_result):
					NREngine.continue_ability(state, side, bottom_one_program, card, null)),
				"cancel": bottom_one_program,
			},
		}
	).call()))

	NRCardDefs.defcard("Scrubbed", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe first piece of ice encountered each turn has -2 strength for the remainder of the run.",
		"code": "06034",
		"title": "Scrubbed",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				NREffects.register_lingering_effect(state, side, card, (func():
				var target_ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return {
					"type": "ice-strength",
					"duration": "end-of-run",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), target_ice),
					"value": -2,
				}
			).call())
				return NRIce.update_all_ice(state, side),
		},
		],
	}))

	NRCardDefs.defcard("Security Leak", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nAs an additional cost to advance a card, the Corp must pay 1[Credits].",
		"code": "14009",
		"title": "Security Leak",
	}, {
		"static-abilities": [
			{
			"type": "card-ability-additional-cost",
			"req": func(state, side, eid, card, targets): return (NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(state.getv("corp", {}), "basic-action-card", null)) and (("Advance 1 installed card" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)) or NRUtil.kw_eq("Advance 1 installed card", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)))),
			"value": NRPayment.to_c("credit", 1),
		},
		],
	}))

	NRCardDefs.defcard("Sell Out", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "As an additional cost to play this event, trash 1 installed resource.\nGain 4[Credits] and draw 2 cards.",
		"code": "36011",
		"title": "Sell Out",
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("resource", 1)],
			"async": true,
			"msg": "gain 4 [Credits] and draw 2 cards",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 4, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRDrawing.draw(state, side, eid, 2)),
		},
	}))

	NRCardDefs.defcard("Shred", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. The first time the Corp would end that run, prevent the run from ending unless the Corp reveals and trashes X cards from HQ at random. X is equal to the number of cards in the root of the attacked server.",
		"code": "35005",
		"title": "Shred",
	}, {
		"on-play": NRCardXlate.run_any_server_ability(),
		"makes-run": true,
		"static-abilities": [
			{
			"type": "prevention",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NREvents.first_run_event(state, side, "end-run-interrupt")),
			"value": {
				"prevents": "end-run",
				"type": "floating",
				"max-uses": 1,
				"mandatory": true,
				"ability": {
					"async": true,
					"condition": "floating",
					"req": func(state, side, eid, card, targets): return NRPrevention.preventable(NRCardXlate.ctx(targets)),
					"effect": func(state, side, eid, card, targets):
						return (func():
						var cards_in_server = NRUtil.as_array(NRCardXlate.getk(run_server, "content", null)).size()
						return NREngine.continue_ability(state, side, (NRChooseOne.choose_one({
							"player": "corp",
						}, [
							cost_option([NRPayment.to_c("reveal-and-randomly-trash-from-hand", cards_in_server)], "corp"),
							{
							"option": "The run does not end",
							"ability": {
								"display-side": "runner",
								"async": true,
								"msg": "prevent the run from ending",
								"effect": func(state, side, eid, card, targets):
									return NRPrevention.prevent_end_run(state, side, eid),
							},
						},
						]) if (cards_in_server > 0) else null), card, null)
					).call(),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Showing Off", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run R&D. If successful, when you breach R&D, access cards from the bottom of R&D instead of the top.",
		"code": "07034",
		"title": "Showing Off",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("rd"),
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"silent": true,
			"msg": "access cards from the bottom of R&D",
			"effect": func(state, side, eid, card, targets):
				return state.assoc_in(["runner", "rd-access-fn"], reverse),
		},
			{
			"event": "run-ends",
			"effect": func(state, side, eid, card, targets):
				return state.assoc_in(["runner", "rd-access-fn"], seq),
		},
		],
	}))

	NRCardDefs.defcard("Singularity", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Double - Run",
		"subtypes": ["Double", "Run"],
		"text": "As an additional cost to play this event, spend [Click].\nRun a remote server. If successful, instead of breaching that server, trash all cards installed in the root of that server.",
		"code": "20004",
		"title": "Singularity",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "remote",
			"this-card-run": true,
			"mandatory": true,
			"ability": {
				"async": true,
				"msg": "trash all cards in the server at no cost",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash_cards(state, side, eid, NRCardXlate.getk(run_server, "content", null), {
					"cause-card": card,
				}),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Social Engineering", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nChoose an unrezzed piece of ice. If the Corp rezzes that piece of ice this turn, gain credits equal to its rez cost.",
		"code": "06018",
		"title": "Social Engineering",
	}, {
		"on-play": {
			"prompt": "Choose an unrezzed piece of ice",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.rezzed(_pct))) and NRCard.installed(_pct) and NRCard.ice(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_x): return ((NRCard.ice).call(_x)) and ((func(_x): return not NRCard.rezzed.call(_x)).call(_x))) != null),
			},
			"msg": func(state, side, eid, card, targets): return str("select ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, (func():
				var ice = NRCardXlate.first_target(targets)
				return [
					{
					"event": "rez",
					"duration": "end-of-turn",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), ice),
					"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRCostFns.rez_cost(state, side, NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))) + str(" [Credits]"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "runner", eid, NRCostFns.rez_cost(state, side, NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))),
				},
				]
			).call()),
		},
	}))

	NRCardDefs.defcard("Spark of Inspiration", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Set aside cards from the top of your stack faceup until you set aside a program. You may install that program, paying 10[Credits] less. Shuffle the set-aside cards into your stack.",
		"code": "33084",
		"title": "Spark of Inspiration",
	}, (func():
		var _b0 = install_program([state, side, eid, card, revealed_card, revealed_cards], (NREngine.continue_ability(state, side, {
			"optional": {
				"prompt": (str("Install ") + str(NRCardXlate.getk(revealed_card, "title", null)) + str(" paying 10 [Credits] less?")),
				"waiting-prompt": true,
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, card, null, revealed_cards)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
						NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, {
						"source": card,
						"source-type": "runner-install",
					}), revealed_card, {
						"cost-bonus": -10,
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
					, func(async_result):
						(func():
						NRShuffling.shuffle_zone(state, side, "deck")
						NRSay.system_msg(state, side, "shuffles the Stack")
						return NREid.effect_completed(state, side, eid)
					).call())),
				},
				"no-ability": shuffle_back(revealed_cards),
			},
		}, card, null) if NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), revealed_card, {
			"cost-bonus": -10,
		}) else NREngine.continue_ability(state, side, shuffle_back(revealed_cards), card, null)))
		return {
			"on-play": {
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
				},
				"effect": func(state, side, eid, card, targets):
					return spark_search_fn(state, side, eid, card, NRCardXlate.getk(state.getv("runner", {}), "deck", null), []),
			},
		}
	).call()))

	NRCardDefs.defcard("Spear Phishing", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Make a run. When you encounter the innermost piece of ice protecting that server, bypass it.",
		"code": "25029",
		"title": "Spear Phishing",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"events": [
			{
			"event": "encounter-ice",
			"automatic": "bypass",
			"req": func(state, side, eid, card, targets): return ((1 == state.get_in(["run", "position"], 0)) or NRUtil.kw_eq(1, state.get_in(["run", "position"], 0))),
			"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRCardXlate.bypass_ice(state),
		},
		],
	}))

	NRCardDefs.defcard("Spec Work", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Job",
		"subtypes": ["Job"],
		"text": "As an additional cost to play this event, trash 1 installed program.\nGain 4[Credits] and draw 2 cards.",
		"code": "26022",
		"title": "Spec Work",
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("program", 1)],
			"msg": "gain 4 [Credits] and draw 2 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 4)
			, func(async_result):
				NRDrawing.draw(state, side, eid, 2)),
		},
	}))

	NRCardDefs.defcard("Special Order", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Search your stack for an <strong>icebreaker</strong>, reveal it, and add it to your grip. Shuffle your stack.",
		"code": "25030",
		"title": "Special Order",
	}, {
		"on-play": tutor_abi(true, func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker")),
	}))

	NRCardDefs.defcard("Spooned", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run any server. The first time you fully break a <strong>code gate</strong> during that run, trash that <strong>code gate</strong>.",
		"code": "07039",
		"title": "Spooned",
	}, cutlery("Code Gate")))

	NRCardDefs.defcard("Spot the Prey", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Expose 1 non-ice card, then make a run.",
		"code": "12005",
		"title": "Spot the Prey",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose 1 non-ice card to expose",
			"msg": "expose 1 card and make a run",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.ice(_pct))) and NRCard.corp(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRExpose.expose(state, side, ne, [NRCardXlate.first_target(targets)])
			, func(async_result):
				NREngine.continue_ability(state, side, NRCardXlate.run_any_server_ability(), card, null)),
		},
	}))

	NRCardDefs.defcard("Spree", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Place 3 power counters on this event, then run any server.\n<strong>Hosted power counter:</strong> Host 1 installed <strong>trojan</strong> program on a piece of ice protecting the attacked server.",
		"code": "34086",
		"title": "Spree",
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"makes-run": true,
		"on-play": NRCardXlate.run_any_server_ability(),
		"abilities": [
			{
			"cost": [NRPayment.to_c("power", 1)],
			"label": "Host an installed trojan on a piece of ice protecting this server",
			"prompt": "Choose an installed trojan",
			"waiting-prompt": true,
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Trojan") and NRCard.program(_pct) and NRCard.installed(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var trojan = NRCardXlate.first_target(targets)
				return NREngine.continue_ability(state, side, {
					"prompt": "Choose a piece of ice protecting this server",
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and ((NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)) == (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)), (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))),
					},
					"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(trojan, "title", null)) + str(" on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						NRHosting.host(state, side, NRCardXlate.first_target(targets), trojan)
						return NRIce.update_all_ice(state, side),
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Steelskin Scarring", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Draw 3 cards.\nWhen this event is trashed from your grip or stack, you may draw 2 cards.",
		"code": "33004",
		"title": "Steelskin Scarring",
	}, {
		"on-play": {
			"async": true,
			"msg": "draw 3 cards",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 3),
		},
		"on-trash": {
			"when-inactive": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"req": func(state, side, eid, card, targets): return (func():
				var zone = NRUtil.first_of(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "zone", null))
				return NRUtil.in_coll(["hand", "deck"], zone)
			).call(),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": "Draw 2 cards?",
					"waiting-prompt": true,
					"yes-ability": {
						"msg": "draw 2 cards",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRDrawing.draw(state, "runner", eid, 2),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
					},
				},
			}, card, null),
		},
	}))

	NRCardDefs.defcard("Stimhack", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Place 9[Credits] on this event, then run any server. During that run, hosted credits are considered to be in your credit pool. When that run ends, suffer 1 core damage. This damage cannot be prevented.",
		"code": "25007",
		"title": "Stimhack",
	}, {
		"makes-run": true,
		"on-play": {
			"prompt": "Choose a server",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.runnable_servers(state, side, eid, card),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				gain_next_run_credits(state, side, 9)
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		"events": [
			{
			"event": "run-ends",
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"msg": "take 1 core damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"unpreventable": true,
				"card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Strike Fund", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Gain 4[Credits].\nWhen this event is trashed from your grip or stack, you may gain 2[Credits].",
		"code": "34001",
		"title": "Strike Fund",
	}, {
		"on-play": {
			"async": true,
			"msg": "gain 4 [Credits]",
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_credits(state, "runner", null, 4)
				return NREid.effect_completed(state, side, eid),
		},
		"on-trash": {
			"when-inactive": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"req": func(state, side, eid, card, targets): return (func():
				var zone = NRUtil.first_of(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "zone", null))
				return NRUtil.in_coll(["hand", "deck"], zone)
			).call(),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": "Gain 2 [Credits]?",
					"waiting-prompt": true,
					"yes-ability": {
						"msg": "gain 2 [Credits]",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRGaining.gain_credits(state, "runner", eid, 2),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
					},
				},
			}, card, null),
		},
	}))

	NRCardDefs.defcard("Sure Gamble", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 5,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Gain 9[Credits].",
		"code": "30030",
		"title": "Sure Gamble",
	}, {
		"on-play": {
			"msg": "gain 9 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 9),
		},
	}))

	NRCardDefs.defcard("Surge", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Play only if you placed at least 1 virus counter on a program this turn.\nPlace 2 virus counters on that program.",
		"code": "02081",
		"title": "Surge",
	}, (func():
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets): return placed_virus_cards(state),
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(placed_virus_cards(state)), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets))) != null),
				},
				"msg": func(state, side, eid, card, targets): return str("place 2 virus counters on ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, "runner", eid, NRCardXlate.first_target(targets), "virus", 2, null),
			},
		}
	).call()))

	NRCardDefs.defcard("SYN Attack", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this event, spend [Click].\nThe Corp must either discard 2 cards or draw 4 cards.",
		"code": "13004",
		"title": "SYN Attack",
	}, {
		"on-play": {
			"player": "corp",
			"waiting-prompt": true,
			"prompt": "Choose one",
			"choices": func(state, side, eid, card, targets):
				return [
				("Discard 2 cards from HQ" if (2 <= NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()) else null),
				"Draw 4 cards",
			],
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("force the Corp to ") + str(decapitalize(NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return (NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "corp", ne, 4)
			, func(async_result):
				NREid.effect_completed(state, side, eid)) if ((NRCardXlate.first_target(targets) == "Draw 4 cards") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 4 cards")) else NREngine.continue_ability(state, "corp", {
				"prompt": "Choose 2 cards to discard",
				"choices": {
					"max": 2,
					"all": true,
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash_cards(state, "corp", eid, targets, {
					"unpreventable": true,
					"cause-card": card,
					"cause": "forced-to-trash",
				}),
			}, card, null)),
		},
	}))

	NRCardDefs.defcard("System Outage", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhenever the Corp draws 1 or more cards, if it is not the first time they have drawn cards this turn, they lose 1[Credits].",
		"code": "11001",
		"title": "System Outage",
	}, {
		"events": [
			{
			"event": "corp-draw",
			"req": func(state, side, eid, card, targets): return (not (NREvents.first_event(state, side, "corp-draw"))),
			"msg": "force the Corp to lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "corp", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("System Seizure", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\n[interrupt] → The first time each turn you would increase the strength of an <strong>icebreaker</strong>, for the remainder of the run that <strong>icebreaker</strong> gains \"Abilities that increase this program's strength last for the remainder of the run <em>(instead of any shorter duration)</em>.\"",
		"code": "12026",
		"title": "System Seizure",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return NRUtil.get_in(card, ["special", "ss-target"], null),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.dissoc_in(card, ["special", "ss-target"])),
		}
		return {
			"events": [
				{
				"event": "pump-breaker",
				"req": func(state, side, eid, card, targets): return ((not (NRUtil.get_in(card, ["special", "ss-target"], null))) or NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRUtil.get_in(card, ["special", "ss-target"], null))),
				"effect": func(state, side, eid, card, targets):
					(NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "ss-target"], NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) if (not (NRUtil.get_in(card, ["special", "ss-target"], null))) else null)
					(func():
					var new_pump = NRUtil.merge(NRCardXlate.getk(NRCardXlate.ctx(targets), "effect", null) if NRCardXlate.getk(NRCardXlate.ctx(targets), "effect", null) is Dictionary else {}, {"duration": "end-of-run"})
					return state.setv("effects", (NRUtil.as_array([]) + NRUtil.as_array((func(_pct, _pct2=null, _pct3=null): return (NRUtil.as_array(_pct) + [new_pump])).call(NRUtil.as_array(NRCardXlate.getk(state, "effects", null)).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "uuid", null) == NRCardXlate.getk(new_pump, "uuid", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "uuid", null), NRCardXlate.getk(new_pump, "uuid", null)))).call(_x)))))))
				).call()
					return NRIce.update_breaker_strength(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			},
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "corp-turn-ends"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-ends"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Tailgate", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "The play cost of this event is lowered by 1[Credits] for each piece of ice protecting HQ.\nRun HQ. If successful, access 2 additional cards when you breach HQ.",
		"code": "36012",
		"title": "Tailgate",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq", {
			"play-cost-bonus": func(state, side, eid, card, targets):
				return (-NRUtil.as_array(state.get_in(["corp", "servers", "hq", "ices"], null)).size()),
		}),
		"events": [
			{
			"event": "successful-run",
			"silent": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [breach_access_bonus("hq", 2, {
				"duration": "end-of-run",
			})]),
		},
		],
	}))


static func _register_6() -> void:
	NRCardDefs.defcard("Take a Dive", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ or R&D. If successful, and if a subroutine resolved during this run, give the Corp 1 bad publicity.\nRemove this event from the game.",
		"code": "36002",
		"title": "Take a Dive",
	}, {
		"on-play": NRCardXlate.run_server_from_choices_ability(["HQ", "R&D"], {
			"rfg-instead-of-trashing": true,
		}),
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["hq", "rd"], NRServers.target_server(NRCardXlate.ctx(targets))) and ((NRCardXlate.getk(NRCardXlate.ctx(targets), "subroutines-fired", null) or 0) > 0)),
			"msg": "force the Corp to take 1 Bad Publicity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1, {
				"card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Test Run", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Search either your stack or your heap for 1 program. <em>(Shuffle your stack after searching it.)</em> Install that program, ignoring all costs. When your turn ends, if that program has not been uninstalled, add it to the top of your stack.",
		"code": "31028",
		"title": "Test Run",
	}, {
		"on-play": {
			"prompt": func(state, side, eid, card, targets):
				return ("Install a program from the stack or heap?" if (not (NRFlags.zone_locked(state, "runner", "discard"))) else "Install a program from the stack?"),
			"choices": func(state, side, eid, card, targets):
				return [
				"Stack",
				("Heap" if (not (NRFlags.zone_locked(state, "runner", "discard"))) else null),
			],
			"msg": func(state, side, eid, card, targets): return str("install a program from the ") + str(NRCardXlate.first_target(targets)),
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var where = NRCardXlate.first_target(targets)
				var where_key = ("discard" if ((where == "Heap") or NRUtil.kw_eq(where, "Heap")) else "deck")
				return {
					"prompt": "Choose a program to install",
					"choices": func(state, side, eid, card, targets):
						return NRUtil.as_array(where_key(state.getv("runner", {}))).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_install(state, side, eid, _pct, {
						"no-toast": true,
					}))),
					"async": true,
					"cancel": (fail_to_find_bang if ((where == "Stack") or NRUtil.kw_eq(where, "Stack")) else null),
					"effect": func(state, side, eid, card, targets):
						((func():
						NREngine.trigger_event(state, side, "searched-stack")
						return NRShuffling.shuffle_zone(state, side, "deck")
					).call() if ((where == "Stack") or NRUtil.kw_eq(where, "Stack")) else null)
						return NREid.wait_for(state, eid, func(ne):
						NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, {
						"source": card,
					}), NRCardXlate.first_target(targets), {
						"ignore-all-cost": true,
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
					, func(installed_card):
						(func():
						(func():
							var installed_card = (NRUpdate.update_card(state, side, NRUtil.assoc_in(installed_card if installed_card is Dictionary else {}, ["special", "test-run"], true)) if installed_card else null)
							return NREngine.register_events(state, side, installed_card, [
							{
							"event": "runner-turn-ends",
							"duration": "end-of-turn",
							"req": func(state, side, eid, card, targets): return NRUtil.get_in(NRFinding.find_latest(state, installed_card), ["special", "test-run"], null),
							"msg": func(state, side, eid, card, targets): return str("move ") + str(NRCardXlate.getk(installed_card, "title", null)) + str(" to the top of the stack"),
							"effect": func(state, side, eid, card, targets):
								return NRMoving.move(state, side, NRFinding.find_latest(state, installed_card), "deck", {
								"front": true,
							}),
						},
						]) if installed_card != null else null
						).call()
						return NREid.effect_completed(state, side, eid)
					).call()),
				}
			).call(), card, null),
		},
	}))

	NRCardDefs.defcard("The Maker's Eye", NRCardXlate.merge_cdef({
		"title": "The Maker's Eye",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("rd"),
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [breach_access_bonus("rd", 2, {
				"duration": "end-of-run",
			})]),
		},
		],
	}))

	NRCardDefs.defcard("The Noble Path", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Trash all cards from your grip. Run any server. Whenever you would take damage during that run, prevent all of that damage.",
		"code": "10077",
		"title": "The Noble Path",
	}, {
		"makes-run": true,
		"static-abilities": [
			{
			"type": "cannot-pay-net",
			"req": func(state, side, eid, card, targets): return state.getv("run"),
			"value": true,
		},
			{
			"type": "cannot-pay-brain",
			"req": func(state, side, eid, card, targets): return state.getv("run"),
			"value": true,
		},
			{
			"type": "cannot-pay-meat",
			"req": func(state, side, eid, card, targets): return state.getv("run"),
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
				"req": func(state, side, eid, card, targets): return (state.getv("run") and NRUtil.same_card(card, state.get_in(["runner", "play-area", 0], null)) and NRPrevention.preventable(NRCardXlate.ctx(targets))),
				"condition": "active",
				"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRCardXlate.getk(NRCardXlate.ctx(targets), "remaining", null)) + str(" ") + str(damage_name(state)) + str(" damage"),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, "all"),
			},
		},
		],
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).is_empty()) or (not NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).is_empty())),
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash_cards(state, side, ne, NRCardXlate.getk(state.getv("runner", {}), "hand", null), {
				"cause-card": card,
			})
			, func(async_result):
				NREngine.continue_ability(state, side, {
				"async": true,
				"prompt": "Choose a server",
				"choices": func(state, side, eid, card, targets):
					return NRCardXlate.runnable_servers(state, side, eid, card),
				"msg": func(state, side, eid, card, targets): return str("trash [their] grip and make a run on ") + str(NRCardXlate.first_target(targets)) + str(", preventing all damage"),
				"effect": func(state, side, eid, card, targets):
					return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
			}, card, null)),
		},
	}))

	NRCardDefs.defcard("The Price", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Trash the top 4 cards of your stack. You may install 1 of those cards, paying 3[Credits] less.",
		"code": "34002",
		"title": "The Price",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.mill(state, "runner", ne, NREid.make_eid(state, eid), "runner", 4)
			, func(trashed_cards):
				(func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRUtil.enumerate_cards(trashed_cards)) + str(" from the top of the stack")))
				return NREngine.continue_ability(state, side, {
					"prompt": "Choose a card to install",
					"waiting-prompt": true,
					"async": true,
					"req": func(state, side, eid, card, targets): return (not (NRFlags.zone_locked(state, "runner", "discard"))),
					"choices": func(state, side, eid, card, targets):
						return NRUtil.as_array(trashed_cards).filter(func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.event(_pct))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
						"cost-bonus": -3,
					}) and NRCard.in_discard(NRCard.get_card(state, _pct)))),
					"effect": func(state, side, eid, card, targets):
						return (func():
						var card_to_install = NRUtil.first_of(NRUtil.as_array(trashed_cards).filter(func(_pct, _pct2=null, _pct3=null): return (((NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null) == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null), NRCardXlate.getk(_pct, "title", null))) and NRCard.in_discard(NRCard.get_card(state, _pct)))))
						return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card_to_install, {
							"cost-bonus": -3,
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						})
					).call(),
				}, card, null)
			).call()),
		},
	}))

	NRCardDefs.defcard("The Price of Freedom", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"text": "As an additional cost to play this event, trash 1 installed <strong>connection</strong> resource.\nThe Corp cannot advance cards during their next turn.\nRemove this event from the game.",
		"code": "10100",
		"title": "The Price of Freedom",
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("connection", 1)],
			"rfg-instead-of-trashing": true,
			"msg": "prevent the Corp from advancing cards during [their] next turn",
		},
		"events": [
			{
			"event": "corp-turn-begins",
			"duration": "until-runner-turn-begins",
			"effect": func(state, side, eid, card, targets):
				return NRFlags.register_turn_flag(state, side, card, "can-advance", constantly(false)),
		},
		],
	}))

	NRCardDefs.defcard("Three Steps Ahead", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Priority",
		"subtypes": ["Priority"],
		"text": "Play only as your first [Click].\nWhen this turn ends, gain 2[Credits] for each successful run you made during it.",
		"code": "06035",
		"title": "Three Steps Ahead",
	}, {
		"on-play": {
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [
				{
				"event": "runner-turn-ends",
				"automatic": "gain-credits",
				"duration": "end-of-turn",
				"unregister-once-resolved": true,
				"msg": func(state, side, eid, card, targets): return str("gain ") + str((2 * NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)).size())) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, (2 * NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)).size())),
			},
			]),
		},
	}))

	NRCardDefs.defcard("Tinkering", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Mod",
		"subtypes": ["Mod"],
		"text": "Choose a piece of ice. That ice gains <strong>sentry</strong>, <strong>code gate</strong>, and <strong>barrier</strong> until the end of the turn.",
		"code": "25047",
		"title": "Tinkering",
	}, {
		"on-play": {
			"prompt": "Choose a piece of ice",
			"choices": {
				"card": func(_x): return ((NRCard.ice).call(_x)) and ((NRCard.installed).call(_x)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), NRCard.ice) != null),
			},
			"msg": func(state, side, eid, card, targets): return str("make ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" gain Sentry, Code Gate, and Barrier until the end of the turn"),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var ice = NRCardXlate.first_target(targets)
				return (func():
					NREffects.register_lingering_effect(state, side, card, {
						"type": "gain-subtype",
						"duration": "end-of-turn",
						"req": func(state, side, eid, card, targets): return NRUtil.same_card(ice, NRCardXlate.first_target(targets)),
						"value": ["Sentry", "Code Gate", "Barrier"],
					})
					return NREffects.register_lingering_effect(state, side, card, {
						"type": "icon",
						"duration": "end-of-turn",
						"req": func(state, side, eid, card, targets): return NRUtil.same_card(ice, NRCardXlate.first_target(targets)),
						"value": make_icon("T", card),
					})
				).call()
			).call(),
		},
	}))

	NRCardDefs.defcard("Trade-In", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "As an additional cost to play this event, trash an installed piece of hardware.\nGain credits equal to half the install cost of the trashed hardware (rounded down) and search your stack for a piece of hardware, reveal it, and add it to your grip. Shuffle your stack.",
		"code": "06078",
		"title": "Trade-In",
	}, (func():
		return {
			"on-play": {
				"additional-cost": [NRPayment.to_c("hardware", 1)],
				"msg": func(state, side, eid, card, targets): return str((func():
					var _destructured_0 = trashed_hw(state)
					return (str("trash ") + str(title) + str(" and gain ") + str((cost / 2)) + str(" [Credits]"))
				).call()),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var _destructured_0 = trashed_hw(state)
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, (cost / 2))
					, func(async_result):
						NREngine.continue_ability(state, "runner", {
						"prompt": "Choose a piece of hardware to add to the grip",
						"choices": func(state, side, eid, card, targets):
							return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(NRCard.hardware),
						"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the stack to the Grip and shuffle the stack"),
						"effect": func(state, side, eid, card, targets):
							NREngine.trigger_event(state, side, "searched-stack")
							NRShuffling.shuffle_zone(state, side, "deck")
							return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
					}, card, null))
				).call(),
			},
		}
	).call()))

	NRCardDefs.defcard("Traffic Jam", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe advancement requirement of each agenda is increased by 1 for each copy of that agenda in the Corp's score area.",
		"code": "08008",
		"title": "Traffic Jam",
	}, {
		"static-abilities": [
			{
			"type": "advancement-requirement",
			"value": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "scored", null)).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))))).size(),
		},
		],
	}))

	NRCardDefs.defcard("Transfer of Wealth", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run HQ. If successful, take 1 tag and the Corp loses 3[Credits]. Gain 2[Credits] for each credit lost this way.",
		"code": "35017",
		"title": "Transfer of Wealth",
	}, {
		"on-play": NRCardXlate.run_server_ability("hq"),
		"makes-run": true,
		"events": [
			{
			"event": "successful-run",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"automatic": "drain-credits",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.this_card_run(state, card, targets) and (("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets))))),
			"msg": func(state, side, eid, card, targets): return str("take 1 tag") + str((func():
				var cc = mini(NRCardXlate.getk(state.getv("corp", {}), "credit", null), 3)
				return ((str("and force the Corp to lose ") + str(cc) + str(" [Credits], and then gain ") + str((2 * cc)) + str(" [Credits]")) if (cc > 0) else null)
			).call()),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var cc = mini(NRCardXlate.getk(state.getv("corp", {}), "credit", null), 3)
				return (NREid.wait_for(state, eid, func(ne):
					NRTags.gain_tags(state, "runner", ne, 1, {
					"suppress-checkpoint": true,
				})
				, func(async_result):
					NREid.wait_for(state, eid, func(ne):
					NRGaining.lose_credits(state, "corp", ne, cc)
				, func(async_result):
					NREid.wait_for(state, eid, func(ne):
					NREngine.checkpoint(state, "runner", ne)
				, func(async_result):
					NRGaining.gain_credits(state, "runner", eid, (cc * 2))))) if (cc > 0) else NRTags.gain_tags(state, "runner", eid, 1))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Tread Lightly", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Run any server. During that run, the rez cost of each piece of ice is increased by 3[Credits].",
		"code": "30012",
		"title": "Tread Lightly",
	}, {
		"on-play": NRCardXlate.run_any_server_ability(),
		"makes-run": true,
		"static-abilities": [
			{
			"type": "rez-cost",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NRCard.ice(NRCardXlate.first_target(targets))),
			"value": 3,
		},
		],
	}))

	NRCardDefs.defcard("Trick Shot", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "Place 4[Credits] on this event. You can spend hosted credits during runs.\nRun R&D. If successful, place 2[Credits] on this event and access 1 additional card when you breach R&D.\nWhen that run ends, you may run a remote server.",
		"code": "34087",
		"title": "Trick Shot",
	}, {
		"makes-run": true,
		"data": {
			"counter": {
				"credit": 4,
			},
		},
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return state.getv("run"),
				"type": "credit",
			},
		},
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return rd_runnable,
			},
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "run-eid"], eid))
				return NRRuns.make_run(state, side, eid, "rd", card),
		},
		"events": [
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"unregister-once-resolved": true,
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets) and ((NRUtil.get_in(card, ["special", "run-eid", "eid"], null) == state.get_in(["run", "eid", "eid"], null)) or NRUtil.kw_eq(NRUtil.get_in(card, ["special", "run-eid", "eid"], null), state.get_in(["run", "eid", "eid"], null)))),
			"msg": "place 2 [Credits] on itself and access 1 additional card from R&D",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.register_events(state, side, card, [breach_access_bonus("rd", 1, {
				"duration": "end-of-run",
			})])
				return NRProps.add_counter(state, side, eid, card, "credit", 2, {
				"placed": true,
			}),
		},
			{
			"event": "run-ends",
			"unregister-once-resolved": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.this_card_run(state, card, targets),
			"prompt": "Choose a remote server to run",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_remote)).map(NRServers.remote_to_name),
			"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.first_target(targets)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card),
		},
		],
	}))

	NRCardDefs.defcard("Uninstall", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Add an installed program or piece of hardware to your grip.",
		"code": "07053",
		"title": "Uninstall",
	}, {
		"on-play": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.facedown(_pct))) and (NRCard.hardware(_pct) or NRCard.program(_pct)))) != null),
			},
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.facedown(_pct))) and (NRCard.hardware(_pct) or NRCard.program(_pct))),
			},
			"msg": func(state, side, eid, card, targets): return str("move ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to [their] Grip"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand"),
		},
	}))

	NRCardDefs.defcard("Unscheduled Maintenance", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp cannot install more than 1 piece of ice each turn.",
		"code": "06036",
		"title": "Unscheduled Maintenance",
	}, {
		"events": [
			{
			"event": "corp-install",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			"effect": func(state, side, eid, card, targets):
				return NRFlags.register_turn_flag(state, side, card, "can-install-ice", func(state, side, card): return ((constantly(false)).call(NRToasts.toast(state, "corp", "Cannot install ice the rest of this turn due to Unscheduled Maintenance")) if NRCard.ice(card) else true)),
		},
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRFlags.clear_turn_flag(state, side, card, "can-install-ice"),
	}))

	NRCardDefs.defcard("Vamp", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, you may spend X[Credits]. If you do, the Corp loses X[Credits]. If you spent credits, take 1 tag.",
		"code": "02021",
		"title": "Vamp",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"ability": {
				"cost": [NRPayment.to_c("x-credits")],
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (NRPayment.cost_value(eid, "x-credits") > 0),
				},
				"msg": func(state, side, eid, card, targets): return str("make the corp lose ") + str(NRPayment.cost_value(eid, "x-credits")) + str(" [Credits]"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRGaining.lose_credits(state, "corp", ne, NRPayment.cost_value(eid, "x-credits"))
				, func(async_result):
					NREngine.continue_ability(state, side, NRTags.gain_tags_ability(1), card, null)),
			},
		}),
		],
	}))

	NRCardDefs.defcard("VRcation", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Draw 4 cards. If you have any [Click] remaining, lose [Click].",
		"code": "30021",
		"title": "VRcation",
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets): return str("draw 4 cards") + str((" and lose [Click]" if (NRCardXlate.getk(state.getv("runner", {}), "click", null) > 0) else null)),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()) or (NRCardXlate.getk(state.getv("runner", {}), "click", null) > 0)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(NRGaining.lose_clicks(state, "runner", 1) if (NRCardXlate.getk(state.getv("runner", {}), "click", null) > 0) else null)
				return NRDrawing.draw(state, "runner", eid, 4),
		},
	}))

	NRCardDefs.defcard("Wanton Destruction", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Run - Sabotage",
		"subtypes": ["Run", "Sabotage"],
		"text": "Run HQ. If successful, instead of breaching HQ, you may spend any number of [Click] to force the Corp to trash that many cards from HQ at random.",
		"code": "07035",
		"title": "Wanton Destruction",
	}, {
		"makes-run": true,
		"on-play": NRCardXlate.run_server_ability("hq"),
		"events": [
			NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"this-card-run": true,
			"ability": {
				"msg": func(state, side, eid, card, targets): return str("force the Corp to discard ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "card")) + str(" from HQ at random"),
				"prompt": "How many [Click] do you want to spend?",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(_range(0, (NRCardXlate.getk(state.getv("runner", {}), "click", null) + 1))).map(str),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var n = str_to_int(NRCardXlate.first_target(targets))
					return NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, "runner", ne, NREid.make_eid(state, eid), card, NRPayment.to_c("click", n))
					, func(async_result):
						(func():
						NRSay.system_msg(state, "runner", msg)
						return NRMoving.trash_cards(state, "corp", eid, NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(n)), {
							"cause-card": card,
						})
					).call())
				).call(),
			},
		}),
		],
	}))

	NRCardDefs.defcard("Watch the World Burn", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Orgcrime - Run - Terminal",
		"subtypes": ["Orgcrime", "Run", "Terminal"],
		"text": "After you resolve this event, end your action phase.\nMake a run on a remote server. If successful, remove the first non-agenda card that you access from the game.\nUntil the game ends, whenever you access a copy of that card, remove it from the game.\nLimit 1 per deck.",
		"code": "23100",
		"title": "Watch the World Burn",
	}, (func():
		return {
			"makes-run": true,
			"on-play": NRCardXlate.run_remote_server_ability,
			"events": [
				{
				"event": "pre-access-card",
				"req": func(state, side, eid, card, targets): return ((not (NRCard.agenda(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)))) and NRCardXlate.getk(state.getv("run"), "successful", null)),
				"once": "per-run",
				"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null)) + str(" from the game, and watch for other copies of ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null)) + str(" to burn"),
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, "corp", NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "rfg")
					return NREngine.register_events(state, side, card, rfg_card_event(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("White Hat", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 0,
		"factioncost": 5,
		"uniqueness": false,
		"text": "Play only if you made a successful run on a central server this turn.\nForce the Corp to \"Trace[3]. If unsuccessful, reveal all cards in HQ. The Runner may choose up to 2 of the revealed cards. Shuffle those cards into R&D.\"",
		"code": "21048",
		"title": "White Hat",
	}, {
		"on-play": {
			"trace": {
				"base": 3,
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq", "rd", "archives"], _x)) != null),
				"unsuccessful": with_revealed_hand("corp", {
					"event-side": "corp",
					"forced": true,
				}, {
					"prompt": "Shuffle up to 2 cards into R&D",
					"player": "runner",
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCard.corp(NRCardXlate.first_target(targets)) and NRCard.in_hand(NRCardXlate.first_target(targets))),
						"max": func(state, side, eid, card, targets):
							return mini(2, NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()),
					},
					"msg": func(state, side, eid, card, targets): return str("shuffle ") + str(NRUtil.enumerate_cards(targets, "sorted")) + str(" into R&D"),
					"effect": func(state, side, eid, card, targets):
						(func():
						for t in NRUtil.as_array(targets):
							NRMoving.move(state, "corp", t, "deck")
						return null
					).call()
						return NRShuffling.shuffle_zone(state, "corp", "deck"),
				}),
			},
		},
	}))

	NRCardDefs.defcard("Wildcat Strike", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Resolve 1 of the following of the Corpʼs choice:<ul><li>Gain 6[Credits].</li><li>Draw 4 cards.</li></ul>",
		"code": "30002",
		"title": "Wildcat Strike",
	}, {
		"on-play": NRChooseOne.choose_one({
			"player": "corp",
		}, [
			{
			"option": "Runner gains 6 [Credits]",
			"ability": {
				"msg": "force the Runner to gain 6 [Credits]",
				"display-side": "corp",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "runner", eid, 6),
			},
		},
			{
			"option": "Runner draws 4 cards",
			"ability": {
				"msg": "force the Runner to draw 4 cards",
				"display-side": "corp",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDrawing.draw(state, "runner", eid, 4),
			},
		},
		]),
	}))

	NRCardDefs.defcard("Windfall", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Shuffle your stack. Trash the top card of your stack. Gain X[Credits] where X is equal to the install cost of that card.",
		"code": "09054",
		"title": "Windfall",
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"effect": func(state, side, eid, card, targets):
				NRShuffling.shuffle_zone(state, side, "deck")
				return (func():
				var topcard = NRUtil.first_of(NRCardXlate.getk(NRCardXlate.getk(state, "runner", null), "deck", null))
				var cost = NRCardXlate.getk(topcard, "cost", null)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, topcard, {
					"cause-card": card,
				})
				, func(async_result):
					NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, (0 if NRCard.event(topcard) else cost))
				, func(async_result):
					(func():
					NRSay.system_msg(state, side, (str("shuffles the stack and trashes ") + str(NRCardXlate.getk(topcard, "title", null)) + str(((str(" to gain ") + str(cost) + str(" [Credits]")) if (not (NRCard.event(topcard))) else null))))
					return NREid.effect_completed(state, side, eid)
				).call()))
			).call(),
		},
	}))

	NRCardDefs.defcard("Window of Opportunity", NRCardXlate.merge_cdef({
		"type": "Event",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Run",
		"subtypes": ["Run"],
		"text": "You may install 1 program or piece of hardware from your grip.\nRun any server. When that run begins, derez 1 piece of ice protecting that server. When that run ends, the Corp may rez the ice derezzed this way, ignoring all costs.",
		"code": "34077",
		"title": "Window of Opportunity",
	}, (func():
		var install_abi = {
			"prompt": "Choose 1 program or piece of hardware to install",
			"waiting-prompt": true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and (NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}),
		}
		return {
			"makes-run": true,
			"events": [
				{
				"event": "run",
				"async": true,
				"unregister-once-resolved": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var rezzed_targets = NRUtil.as_array(NRBoard.all_active_installed(state, "corp")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and ((NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)) == (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null)), (NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))))
					return (NREngine.continue_ability(state, side, {
						"prompt": "Choose a piece of ice protecting this server to derez",
						"waiting-prompt": true,
						"choices": {
							"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(rezzed_targets), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.first_target(targets))) != null),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
							var chosen_ice = NRCardXlate.first_target(targets)
							return (func():
								NREngine.register_events(state, side, card, [
									{
									"event": "run-ends",
									"duration": "end-of-run",
									"optional": {
										"player": "corp",
										"waiting-prompt": true,
										"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCard.get_card(state, chosen_ice)) and (not (NRCard.rezzed(NRCard.get_card(state, chosen_ice))))),
										"prompt": (str("Rez ") + str(NRToString.card_str(state, chosen_ice)) + str(", ignoring all costs?")),
										"yes-ability": {
											"async": true,
											"effect": func(state, side, eid, card, targets):
												return NRRezzing.rez(state, "corp", eid, chosen_ice, {
												"ignore-cost": "all-costs",
											}),
										},
									},
								},
								])
								return NRRezzing.derez(state, side, eid, NRCardXlate.first_target(targets))
							).call()
						).call(),
					}, card, null) if (not NRUtil.as_array(rezzed_targets).is_empty()) else NREid.effect_completed(state, side, eid))
				).call(),
			},
			],
			"on-play": {
				"async": true,
				"prompt": "Choose a server",
				"choices": func(state, side, eid, card, targets):
					return NRCardXlate.runnable_servers(state, side, eid, card),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, install_abi, card, null)
				, func(async_result):
					NRRuns.make_run(state, side, eid, NRCardXlate.first_target(targets), card)),
			},
		}
	).call()))


