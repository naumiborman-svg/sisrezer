class_name NRCardsAssets
extends RefCounted

## Port of game.cards.assets — translated from Jinteki.net Clojure.


static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Adonis Campaign", NRUtil.merge({
		"title": "Adonis Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "Put 12[credit] from the bank on Adonis Campaign when rezzed. When there are no credits left on Adonis Campaign, trash it.\nTake 3[credit] from Adonis Campaign when your turn begins."
	}, _campaign(12, 3)))
	NRCardDefs.defcard("Advanced Assembly Lines", NRUtil.merge({
		"title": "Advanced Assembly Lines",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "When you rez Advanced Assembly Lines, gain 3[credit].\n[trash]: Install a non-agenda card from HQ (paying the install cost). You cannot use this ability during a run."
	}, {
		"on-rez": {
			"async": true,
			"msg": "gain 3 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 3),
		},
		"abilities": [
			{
				"label": "Install a non-agenda card from HQ",
				"async": true,
				"prompt": "Choose a non-agenda card to install from HQ",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				},
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCardRT.getv(state.data, "run"))),
				"choices": {
					"card": func(_pct):
						return (NRCard.corp_installable_type(_pct) and (not NRCardRT.truthy(NRCard.agenda(_pct))) and NRCard.in_hand(_pct) and NRCard.corp(_pct)),
				},
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						null,
						{
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Aggressive Secretary", NRUtil.merge({
		"title": "Aggressive Secretary",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "Aggressive Secretary can be advanced.\nIf you pay 2[credit] when the Runner accesses Aggressive Secretary, trash 1 program for each advancement token on Aggressive Secretary."
	}, _advance_ambush(
		2,
		{
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"waiting-prompt": true,
			"prompt": func(state, side, eid, card, targets):
				return str("Choose ") + str(NRCardRT.quantify(NRCard.get_counters(NRCard.get_card(state, card), "advancement"), "program")) + str(" to trash"),
			"choices": {
				"max": func(state, side, eid, card, targets):
					return NRCard.get_counters(NRCard.get_card(state, card), "advancement"),
				"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy(NRCard.program(x))),
			},
			"msg": func(state, side, eid, card, targets):
				return str("trash ") + str(NRCardRT.enumerate_cards(targets)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(
					state,
					side,
					eid,
					targets,
					{
						"cause-card": card,
					}
				),
		}
	)))
	NRCardDefs.defcard("Alexa Belsky", NRUtil.merge({
		"title": "Alexa Belsky",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "[trash]: Shuffle all cards in HQ into R&D. The Runner may pay any number of credits to prevent 1 random card in HQ from being shuffled into R&D for every 2[credit] spent."
	}, {
		"abilities": [
			{
				"label": "Shuffle all cards in HQ into R&D",
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, {
						"waiting-prompt": true,
						"prompt": "How many credits do you want to pay?",
						"choices": "credit",
						"player": "runner",
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
							return str("shuffle ") + str(NRCardRT.quantify((NRCardRT.count_of(NRCardRT.getv(corp, "hand")) - quot(target, 2)), "card")) + str(" in HQ into R&D"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
							return ((func():
								var prevented = quot(target, 2)
								var unprevented = (NRCardRT.count_of(NRCardRT.getv(corp, "hand")) - prevented)
								(func():
									for c in NRCardRT.as_array(NRCardRT.take_n(shuffle(NRCardRT.getv(corp, "hand")), int(unprevented))):
										NRMoving.move(state, "corp", c, "deck")
									return null
								).call()
								(NRShuffling.shuffle_zone(state, "corp", "deck") if NRCardRT.truthy(NRCardRT.pos(unprevented)) else null)
								return NRSay.system_msg(state, "runner", str("pays ") + str(target) + str(" [Credits] to prevent ") + str(NRCardRT.quantify(prevented, "random card")) + str(" in HQ from being shuffled into R&D"))
							).call() if NRCardRT.pos(quot(target, 2)) else NRShuffling.shuffle_into_deck(state, "corp", "hand")),
					}, card, null),
			}
		],
	}))
	NRCardDefs.defcard("Alix T4LB07", NRUtil.merge({
		"title": "Alix T4LB07",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "Place 1 power counter on Alix T4LB07 whenever you install a card.\n[click],[trash]: Gain 2[credit] for each power counter on Alix T4LB07."
	}, {
		"events": [
			{
				"event": "corp-install",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
		"abilities": [
			{
				"action": true,
				"label": "Gain 2 [Credits] for each counter on Alix T4LB07",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str((2 * NRCard.get_counters(card, "power"))) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, (2 * NRCard.get_counters(card, "power"))),
			}
		],
	}))
	NRCardDefs.defcard("Allele Repression", NRUtil.merge({
		"title": "Allele Repression",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 3,
		"text": "Allele Repression can be advanced.\n[trash]: Swap 1 card in HQ with 1 card in Archives for each advancement token on Allele Repression."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"label": "Swap 1 card in HQ and Archives for each advancement counter",
				"cost": [NRPayment.to_c("trash-can")],
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str("swap ") + str(NRCardRT.quantify(maxi(NRCardRT.count_of(NRCardRT.getv(corp, "discard")), NRCardRT.count_of(NRCardRT.getv(corp, "hand"))), "card")) + str(" in HQ and Archives"),
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					var async_result = NREid.result_of(eid)
					return (func():
						var total = mini(NRCardRT.count_of(NRCardRT.getv(corp, "discard")), NRCardRT.count_of(NRCardRT.getv(corp, "hand")))
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, _select_hq_cards_2(total), card, null)
						, func(async_result):
							(func():
								var hq_cards = async_result
								return NREid.wait_for(state, eid, func(ne):
									NREngine.resolve_ability(state, side, ne, _select_archives_cards_1(total), card, null)
								, func(async_result):
									(func():
										var archives_cards = async_result
										return null
									).call()
									NREid.effect_completed(state, side, eid))
							).call())
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Amani Senai", NRUtil.merge({
		"title": "Amani Senai",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 4,
		"factioncost": 4,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever an agenda is scored or stolen, you may trace[X]. If successful, add an installed Runner card to the grip. X is the advancement requirement of the scored or stolen agenda."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NREngine.resolve_ability(state, side, eid, _senai_ability_3(NRCardRT.getv(context, "card")), card, null),
			},
			{
				"event": "agenda-stolen",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NREngine.resolve_ability(state, side, eid, _senai_ability_3(NRCardRT.getv(context, "card")), card, null),
			}
		],
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "Amani Senai")],
	}))
	NRCardDefs.defcard("Anson Rose", NRUtil.merge({
		"title": "Anson Rose",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 1,
		"trash": 4,
		"factioncost": 1,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "When your turn begins, place 1 advancement token on Anson Rose.\nWhenever you rez a piece of ice, you may move any number of advancement tokens from Anson Rose to that ice."
	}, (func():
		var ability = {
			"label": "Place 1 advancement counter (start of turn)",
			"once": "per-turn",
			"msg": "place 1 advancement counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_prop(
					state,
					side,
					eid,
					card,
					"advance-counter",
					1,
					{
						"placed": true,
					}
				),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [
				NRUtil.merge(ability, {"event": "corp-turn-begins"}),
				{
					"event": "rez",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRCard.ice(NRCardRT.getv(context, "card")) and NRCardRT.pos(NRCard.get_counters(card, "advancement")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var context = NRCardRT.ctx(targets)
						return (func():
							var ice = NRCard.get_card(state, NRCardRT.getv(context, "card"))
							var icename = NRCardRT.getv(ice, "title")
							return NREngine.resolve_ability(state, side, eid, {
								"optional": {
									"waiting-prompt": true,
									"prompt": str("Move advancement counters to ") + str(icename) + str("?"),
									"yes-ability": {
										"prompt": "How many advancement counters do you want to move?",
										"choices": {
											"number": func(state, side, eid, card, targets):
												return NRCard.get_counters(card, "advancement"),
										},
										"async": true,
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return NREid.wait_for(state, eid, func(ne):
												NRProps.add_prop(state, "corp", ne, ice, "advance-counter", target, {
													"placed": true,
												})
											, func(async_result):
												NREid.wait_for(state, eid, func(ne):
													NRProps.add_prop(state, "corp", ne, card, "advance-counter", (-target), {
														"placed": true,
													})
												, func(async_result):
													NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to move ") + str(NRCardRT.quantify(target, "advancement counter")) + str(" to ") + str(NRToString.card_str(state, ice)))
													NREid.effect_completed(state, side, eid))),
									},
								},
							}, card, null)
						).call(),
				}
			],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Anthill Excavation Contract", NRUtil.merge({
		"title": "Anthill Excavation Contract",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Industrial",
		"subtypes": ["Industrial"],
		"text": "When you rez this asset, load 8[credit] onto it. When it is empty, trash it.\nWhen your turn begins, take 4[credit] from this asset and draw 1 card."
	}, (func():
		var ability = {
			"once": "per-turn",
			"label": "Take 4 [Credits] and draw a card (start of turn)",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(mini(4, NRCard.get_counters(card, "credit"))) + str(" [Credits] and draw a card"),
			"async": true,
			"automatic": "draw-cards",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 1, {
						"suppress-checkpoint": true,
					})
				, func(async_result):
					NRDefHelpers.take_credits(state, side, eid, card, "credit", 4)),
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
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"}), trash_on_empty("credit")],
		}
	).call()))
	NRCardDefs.defcard("API-S Keeper Isobel", NRUtil.merge({
		"title": "API-S Keeper Isobel",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "When your turn begins, you may remove an advancement token from an installed card to gain 3[credit]."
	}, {
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return _counters_available_4(state),
		},
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(state.data, "corp-phase-12") and _counters_available_4(state),
				"once": "per-turn",
				"label": "Remove an advancement counter (start of turn)",
				"prompt": "Choose a card to remove an advancement counter from",
				"choices": {
					"card": func(_pct):
						return (NRCardRT.pos(NRCard.get_counters(_pct, "advancement")) and NRCard.installed(_pct)),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var cnt = NRCard.get_counters(target, "advancement")
						NRProps.set_prop(state, side, target, "advance-counter", (int(cnt) - 1))
						NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to remove 1 advancement counter from ") + str(NRToString.card_str(state, target)) + str(" and gains 3 [Credits]"))
						return NRGaining.gain_credits(state, "corp", eid, 3)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Aryabhata Tech", NRUtil.merge({
		"title": "Aryabhata Tech",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Ritzy",
		"subtypes": ["Ritzy"],
		"text": "Whenever there is a successful trace, gain 1[credit] and the Runner loses 1[credit]."
	}, {
		"events": [
			{
				"event": "successful-trace",
				"msg": "gain 1 [Credit] and force the Runner to lose 1 [Credit]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, 1)
					, func(async_result):
						NRGaining.lose_credits(state, "runner", eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("B-1001", NRUtil.merge({
		"title": "B-1001",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 0,
		"keywords": "Bioroid - Enforcer",
		"subtypes": ["Bioroid", "Enforcer"],
		"text": "<strong>Remove 1 tag:</strong> End the run. Use this ability only during a run against another server."
	}, {
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return run and (not NRCardRT.truthy(this_server)),
				"async": true,
				"cost": [NRPayment.to_c("tag", 1)],
				"msg": "end the run",
				"label": "End the run on another server",
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card),
			}
		],
	}))
	NRCardDefs.defcard("Balanced Coverage", NRUtil.merge({
		"title": "Balanced Coverage",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Seedy",
		"subtypes": ["Seedy"],
		"text": "When your turn begins, you may choose a card type to look at the top card of R&D. If that card has the chosen type, you may reveal it and gain 2[credit]."
	}, (func():
		var name_abi = {
			"prompt": "Choose a card type",
			"waiting-prompt": true,
			"choices": ["Operation", "Asset", "Upgrade", "ICE", "Agenda"],
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(target),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return (func():
					var named_type = target
					var top_card = NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, {
							"async": true,
							"prompt": func(state, side, eid, card, targets):
								return str("The top card of R&D is: ") + str(NRCardRT.getv(top_card, "title")),
							"waiting-prompt": true,
							"choices": ["OK"],
						}, card, null)
					, func(async_result):
						(NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"prompt": "Reveal it to gain 2 [Credits]?",
								"waiting-prompt": true,
								"yes-ability": {
									"async": true,
									"msg": func(state, side, eid, card, targets):
										return str("reveal ") + str(NRCardRT.getv(top_card, "title")) + str(" from the top of R&D and gain 2 [Credits]"),
									"effect": func(state, side, eid, card, targets):
										return NREid.wait_for(state, eid, func(ne):
											NRRevealing.reveal(state, side, ne, top_card)
										, func(async_result):
											NRGaining.gain_credits(state, "corp", eid, 2)),
								},
								"no-ability": {
									"effect": func(state, side, eid, card, targets):
										return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title")) + str(" to reveal the top card of R&D")),
								},
							},
						}, card, null) if ((NRCardRT.getv(top_card, "type") == named_type) or NRUtil.kw_eq(NRCardRT.getv(top_card, "type"), named_type)) else (func():
							NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title")) + str(" to reveal the top card of R&D"))
							return NREid.effect_completed(state, side, eid)
						).call()))
				).call(),
		}
		var ability = {
			"label": "Look at the top card of R&D (start of turn)",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, name_abi, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Bass CH1R180G4", NRUtil.merge({
		"title": "Bass CH1R180G4",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "[click], <strong>[trash]:</strong> Gain [click][click]."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"msg": "gain [Click][Click]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_clicks(state, side, 2),
			}
		],
	}))
	NRCardDefs.defcard("Behold!", NRUtil.merge({
		"title": "Behold!",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset anywhere except in Archives, you may pay 4[credit] to give them 2 tags."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_discard(card))),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("Pay 4 [Credits] to use ") + str(NRCardRT.getv(card, "title")) + str(" ability?"),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
				"yes-ability": NRUtil.merge(NRDefHelpers.give_tags(2), {"cost": [NRPayment.to_c("credit", 4)]}),
			},
		},
	}))
	NRCardDefs.defcard("Bio-Ethics Association", NRUtil.merge({
		"title": "Bio-Ethics Association",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political",
		"subtypes": ["Political"],
		"text": "When your turn begins, do 1 net damage if there is no ice protecting this server."
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets):
				var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
				return unprotected,
			"automatic": "corp-damage",
			"async": true,
			"label": "Do 1 net damage (start of turn)",
			"once": "per-turn",
			"msg": "do 1 net damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					1,
					{
						"card": card,
					}
				),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Bioroid Work Crew", NRUtil.merge({
		"title": "Bioroid Work Crew",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 4,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "<strong>[trash]:</strong> Install 1 card from HQ. Use this ability only during the next paid ability window after playing and resolving an operation."
	}, {
		"implementation": "Timing restriction of ability use not enforced",
		"abilities": [
			{
				"label": "Install 1 card, paying all costs",
				"req": func(state, side, eid, card, targets):
					return ((NRCardRT.getv(state.data, "active-player") == "corp") or NRUtil.kw_eq(NRCardRT.getv(state.data, "active-player"), "corp")),
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				},
				"prompt": "Choose a card in HQ to install",
				"choices": {
					"card": func(_pct):
						return ((not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.in_hand(_pct) and NRCard.corp(_pct)),
				},
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						null,
						{
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Blacklist", NRUtil.merge({
		"title": "Blacklist",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"text": "Cards cannot leave the Runner's heap for any reason."
	}, {
		"on-rez": {
			"effect": func(state, side, eid, card, targets):
				return lock_zone(state, side, NRCardRT.getv(card, "cid"), "runner", "discard"),
		},
		"leave-play": func(state, side, eid, card, targets):
			return release_zone(state, side, NRCardRT.getv(card, "cid"), "runner", "discard"),
	}))
	NRCardDefs.defcard("Bladderwort", NRUtil.merge({
		"title": "Bladderwort",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "When your turn begins, gain 1[credit]. Then, if you have 4[credit] or less, do 1 net damage."
	}, (func():
		var ability = {
			"msg": "gain 1 [Credits]",
			"label": "Gain 1 [Credits] (start of turn)",
			"once": "per-turn",
			"automatic": "pre-gain-credits",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 1)
				, func(async_result):
					(NREngine.resolve_ability(state, side, eid, {
						"msg": "do 1 net damage",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(
								state,
								side,
								eid,
								"net",
								1,
								{
									"card": card,
								}
							),
					}, card, null) if (NRCardRT.getv(NRCardRT.getv(state.data, "corp"), "credit") <= 4) else NREid.effect_completed(state, side, eid))),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Brain-Taping Warehouse", NRUtil.merge({
		"title": "Brain-Taping Warehouse",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 4,
		"factioncost": 1,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "The rez cost of <strong>bioroid</strong> ice is lowered by 1 for each unspent click the Runner has."
	}, {
		"static-abilities": [
			{
				"type": "rez-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRCard.has_subtype(target, "Bioroid"),
				"value": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (-NRCardRT.getv(runner, "click")),
			}
		],
	}))
	NRCardDefs.defcard("Breached Dome", NRUtil.merge({
		"title": "Breached Dome",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, do 1 meat damage and trash the top card of the stack."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
					var c = NRCardRT.getv(state.get_in(["runner", "deck"], null), 0)
					NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to do 1 meat damage") + str(" and to trash ") + str(NRCardRT.getv(c, "title")) + str(" from the top of the stack"))
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.mill(state, "corp", ne, "runner", 1)
					, func(async_result):
						NRDamage.damage(
							state,
							side,
							eid,
							"meat",
							1,
							{
								"card": card,
							}
						))
				).call(),
		},
	}))
	NRCardDefs.defcard("Broadcast Square", NRUtil.merge({
		"title": "Broadcast Square",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "[interrupt] → Whenever you would take bad publicity, trace[3]. If successful, prevent all of that bad publicity."
	}, {
		"prevention": [
			{
				"prevents": "bad-publicity",
				"type": "event",
				"max-uses": 1,
				"mandatory": true,
				"ability": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRPrevention.preventable(context),
					"trace": {
						"base": 3,
						"successful": {
							"msg": "prevent all bad publicity",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return prevent_bad_publicity(state, side, eid, "all"),
						},
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Byte!", NRUtil.merge({
		"title": "Byte!",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset anywhere except in Archives, you may pay 4[credit]. If you do, give the Runner 1 tag and do 3 net damage."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_discard(card))) and NRPayment.can_pay(state, "corp", eid, card, null, [NRPayment.to_c("credit", 4)]),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("Pay 4 [Credits] to use ") + str(NRCardRT.getv(card, "title")) + str(" ability?"),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("credit", 4)],
					"msg": "give the Runner 1 tag and do 3 net damage",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRTags.gain_tags(state, "corp", ne, 1, {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRDamage.damage(
								state,
								side,
								eid,
								"net",
								3,
								{
									"card": card,
								}
							)),
				},
			},
		},
	}))
	NRCardDefs.defcard("C.I. Fund", NRUtil.merge({
		"title": "C.I. Fund",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"text": "When your turn begins, you may move up to 3[credit] from your credit pool to C.I. Fund.\nWhen your turn begins, place 2[credit] on C.I. Fund from the bank if there are at least 6[credit] on it.\n2[credit],[trash]: Take all credits from C.I. Fund."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.pos(NRCardRT.getv(corp, "credit")),
		},
		"abilities": [
			{
				"label": "Store up to 3 [Credit] (start of turn)",
				"prompt": "How many credits do you want to store?",
				"once": "per-turn",
				"choices": {
					"number": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return mini(NRCardRT.getv(corp, "credit"), 3),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "credit", target, null)
					, func(async_result):
						NRGaining.lose_credits(state, side, eid, target)),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("store ") + str(target) + str(" [Credit]"),
			},
			{
				"label": "Take all hosted credits",
				"cost": [NRPayment.to_c("credit", 2), NRPayment.to_c("trash-can")],
				"msg": func(state, side, eid, card, targets):
					return str("trash it and gain ") + str(NRCard.get_counters(card, "credit")) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, NRCard.get_counters(card, "credit")),
			}
		],
		"events": [
			{
				"event": "corp-turn-begins",
				"msg": "place 2 [Credits] on itself",
				"req": func(state, side, eid, card, targets):
					return (NRCard.get_counters(card, "credit") >= 6),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "credit", 2, null),
			}
		],
	}))
	NRCardDefs.defcard("Calvin B4L3Y", NRUtil.merge({
		"title": "Calvin B4L3Y",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "Once per turn → [click]<strong>:</strong> Draw 2 cards.\nWhen the Runner trashes this asset, you may draw 2 cards."
	}, {
		"abilities": [
			NRDefHelpers.draw_ability(
				2,
				null,
				{
					"action": true,
					"cost": [NRPayment.to_c("click", 1)],
					"once": "per-turn",
				}
			)
		],
		"on-trash": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"req": func(state, side, eid, card, targets):
					return (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"waiting-prompt": true,
				"prompt": "Draw 2 cards?",
				"yes-ability": NRDefHelpers.draw_ability(2),
			},
		},
	}))
	NRCardDefs.defcard("Capital Investors", NRUtil.merge({
		"title": "Capital Investors",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"text": "[click]: Gain 2[credit]."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "gain 2 [Credits]",
				"keep-menu-open": "while-clicks-left",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			}
		],
	}))
	NRCardDefs.defcard("Cerebral Overwriter", NRUtil.merge({
		"title": "Cerebral Overwriter",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "You can advance this asset.\nWhen the Runner accesses this asset while it is installed, you may pay 3[credit] to do X core damage. X is equal to the number of hosted advancement counters."
	}, _advance_ambush(
		3,
		{
			"async": true,
			"waiting-prompt": true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str(NRCard.get_counters(NRCard.get_card(state, card), "advancement")) + str(" core damage"),
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"brain",
					NRCard.get_counters(NRCard.get_card(state, card), "advancement"),
					{
						"card": card,
					}
				),
		}
	)))
	NRCardDefs.defcard("Chairman Hiro", NRUtil.merge({
		"title": "Chairman Hiro",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 6,
		"factioncost": 5,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "The Runner gets -2 maximum hand size.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
	}, {
		"static-abilities": [NRHandSize.runner_hand_size_plus(-2)],
		"on-trash": _executive_trash_effect(),
	}))
	NRCardDefs.defcard("Charlotte Caçador", NRUtil.merge({
		"title": "Charlotte Caçador",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "You can advance this asset.\nWhen your turn begins, you may remove 1 hosted advancement counter to gain 4[credit] and draw 1 card.\n[trash], <strong>hosted advancement counter:</strong> Gain 3[credit]."
	}, (func():
		var choice_abi = {
			"label": "Gain 4 [Credits] and draw 1 card",
			"optional": {
				"once": "per-turn",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "advancement")) and NRCardRT.getv(state.data, "corp-phase-12"),
				"prompt": "Remove 1 hosted advancement counter to gain 4 [Credits] and draw 1 card?",
				"yes-ability": {
					"msg": "remove 1 hosted advancement counter from itself to gain 4 [Credits] and draw 1 card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRProps.add_prop(state, "corp", ne, card, "advance-counter", -1)
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
								NRGaining.gain_credits(state, side, ne, 4)
							, func(async_result):
								NRDrawing.draw(state, side, eid, 1))),
				},
			},
		}
		var queue_ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"event": "corp-turn-begins",
			"req": func(state, side, eid, card, targets):
				return NREngine.not_used_once(
					state,
					{
						"once": "per-turn",
					},
					card
				) and NRCardRT.getv(state.data, "corp-phase-12"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, choice_abi, card, null),
		}
		var trash_ab = {
			"cost": [NRPayment.to_c("advancement", 1), NRPayment.to_c("trash-can")],
			"label": "Gain 3 [Credits]",
			"msg": func(state, side, eid, card, targets):
				return str("gain 3 [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 3),
		}
		return {
			"advanceable": "always",
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [queue_ability],
			"abilities": [choice_abi, trash_ab],
		}
	).call()))
	NRCardDefs.defcard("Chekist Scion", NRUtil.merge({
		"title": "Chekist Scion",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "You can advance this asset.\nWhen the Runner accesses this asset while it is installed, give them 1 tag plus 1 tag for each hosted advancement counter."
	}, _advance_ambush(
		0,
		{
			"msg": func(state, side, eid, card, targets):
				return str("give the Runner ") + str(NRCardRT.quantify((int(NRCard.get_counters(NRCard.get_card(state, card), "advancement")) + 1), "tag")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.gain_tags(state, "corp", eid, (int(NRCard.get_counters(NRCard.get_card(state, card), "advancement")) + 1)),
		}
	)))
	NRCardDefs.defcard("Chief Slee", NRUtil.merge({
		"title": "Chief Slee",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever an encounter with a piece of ice ends, place 1 power counter on Chief Slee for each unbroken subroutine on the encountered piece of ice.\n[click], <strong>5 hosted power counters</strong>: Do 5 meat damage."
	}, {
		"events": [
			{
				"event": "end-of-encounter",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.getv(x, "broken")).call(x))))),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var unbroken_count = NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.getv(x, "broken")).call(x))))
						return str("place ") + str(NRCardRT.quantify(unbroken_count, "power counter")) + str(" on itself")
					).call(),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRProps.add_counter(state, "corp", eid, card, "power", NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.getv(x, "broken")).call(x)))), null),
			}
		],
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 5)],
				"keep-menu-open": "while-5-power-tokens-left",
				"async": true,
				"msg": "do 5 meat damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"meat",
						5,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("City Surveillance", NRUtil.merge({
		"title": "City Surveillance",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"trash": 3,
		"factioncost": 4,
		"text": "When the Runner's turn begins, give them 1 tag unless they pay 1[credit]."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"events": [
			{
				"event": "runner-turn-begins",
				"player": "runner",
				"prompt": "Choose one",
				"waiting-prompt": true,
				"choices": func(state, side, eid, card, targets):
					return [
						("Pay 1 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)])) else null),
						"Take 1 tag"
					],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str(("give the runner 1 tag" if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else str("force the runner to ") + str(NRCardRT.decapitalize(target)))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var async_result = NREid.result_of(eid)
					return (NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", 1))
					, func(async_result):
						NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
						NREid.effect_completed(state, side, eid)) if ((target == "Pay 1 [Credits]") or NRUtil.kw_eq(target, "Pay 1 [Credits]")) else NRTags.gain_tags(state, "corp", eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("Clearinghouse", NRUtil.merge({
		"title": "Clearinghouse",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "You can advance this asset.\nWhen your turn begins, you may trash this asset to do 1 meat damage for each hosted advancement counter."
	}, (func():
		var ability = {
			"once": "per-turn",
			"async": true,
			"label": "Trash this asset to do 1 meat damage for each hosted advancement counter (start of turn)",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": func(state, side, eid, card, targets):
							return str("Trash this asset to do ") + str(NRCard.get_counters(card, "advancement")) + str(" meat damage?"),
						"yes-ability": {
							"async": true,
							"msg": "do 1 meat damage for each hosted advancement counter",
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, card, {
										"cause-card": card,
									})
								, func(async_result):
									NRDamage.damage(
										state,
										side,
										eid,
										"meat",
										NRCard.get_counters(card, "advancement"),
										{
											"card": card,
										}
									)),
						},
					},
				}, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"advanceable": "always",
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Clone Suffrage Movement", NRUtil.merge({
		"title": "Clone Suffrage Movement",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political",
		"subtypes": ["Political"],
		"text": "When your turn begins, you may add 1 operation from Archives to HQ if there is no ice protecting this server."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
				return (NRCardRT.some_list(NRCardRT.getv(corp, "discard"), NRCard.operation) and unprotected),
		},
		"abilities": [
			NRCardRT.concat_lists([corp_recur(NRCard.operation), {
				"label": "Add 1 operation from Archives to HQ",
				"waiting-prompt": true,
				"prompt": "Choose an operation in Archives to add to HQ",
				"once": "per-turn",
			}])
		],
	}))
	NRCardDefs.defcard("Clyde Van Rite", NRUtil.merge({
		"title": "Clyde Van Rite",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "When your turn begins, the Runner must pay 1[credit] or trash the top card of the stack."
	}, (func():
		var ability = {
			"async": true,
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return (NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)]) or NRCardRT.seq_of(NRCardRT.getv(runner, "deck"))),
			"player": "runner",
			"once": "per-turn",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return [
					("Pay 1 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)])) else null),
					("Trash the top card of the stack" if NRCardRT.truthy(((not NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)]))) or NRCardRT.seq_of(NRCardRT.getv(runner, "deck")))) else null)
				],
			"label": "make the Runner pay 1 [Credits] or trash the top card of the stack (start of turn)",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, side, ne, card, NRPayment.to_c("credit", 1))
				, func(async_result):
					NRSay.system_msg(state, side, NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid)) if ((target == "Pay 1 [Credits]") or NRUtil.kw_eq(target, "Pay 1 [Credits]")) else NRMoving.mill(state, "runner", eid, "runner", 1)),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Cohort Guidance Program", NRUtil.merge({
		"title": "Cohort Guidance Program",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "When your turn begins, you may resolve 1 of the following:<ul><li>Trash 1 card from HQ. If you do, gain 2[credit] and draw 1 card.</li><li>Turn 1 facedown card in Archives faceup. If you do, place 1 advancement counter on an installed card.</li></ul>"
	}, {
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"events": [
			{
				"event": "corp-turn-begins",
				"skippable": true,
				"prompt": "Choose one",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return [
						("Trash 1 card from HQ to gain 2 [Credits] and draw 1 card" if NRCardRT.truthy(NRCardRT.seq_of(NRCardRT.getv(corp, "hand"))) else null),
						("Turn 1 facedown card in Archives faceup to place 1 advancement counter on an installed card" if NRCardRT.truthy(NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
							return (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen"))))) else null),
						"Done"
					],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NREid.effect_completed(state, side, eid) if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NREngine.resolve_ability(state, side, eid, ({
						"prompt": "Choose a card to trash",
						"msg": "trash a card from HQ to gain 2 [Credits] and draw 1 card",
						"choices": {
							"max": 1,
							"all": true,
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash_cards(state, side, ne, targets, {
									"cause-card": card,
								})
							, func(async_result):
								NREid.wait_for(state, eid, func(ne):
									NRGaining.gain_credits(state, side, ne, 2)
								, func(async_result):
									NRDrawing.draw(state, side, eid, 1))),
					} if ((target == "Trash 1 card from HQ to gain 2 [Credits] and draw 1 card") or NRUtil.kw_eq(target, "Trash 1 card from HQ to gain 2 [Credits] and draw 1 card")) else {
						"prompt": "Choose a card to turn faceup",
						"choices": {
							"card": func(_pct):
								return (NRCard.in_discard(_pct) and NRCard.corp(_pct) and (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen")))),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("turn ") + str(NRCardRT.getv(target, "title")) + str(" in Archives faceup"),
						"show-discard": true,
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							NRUpdate.update_card(state, side, NRUtil.merge(target, {"seen": true}))
							return NREngine.resolve_ability(state, side, eid, {
								"prompt": "Choose an installed card",
								"choices": {
									"card": func(_pct):
										return (NRCard.corp(_pct) and NRCard.installed(_pct)),
								},
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRProps.add_prop(
										state,
										side,
										eid,
										target,
										"advance-counter",
										1,
										{
											"placed": true,
										}
									),
							}, card, null),
					}), card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Commercial Bankers Group", NRUtil.merge({
		"title": "Commercial Bankers Group",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political",
		"subtypes": ["Political"],
		"text": "When your turn begins, gain 3[credit] if there is no ice protecting this server."
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets):
				var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
				return unprotected,
			"automatic": "gain-credits",
			"label": "Gain 3 [Credits] (start of turn)",
			"once": "per-turn",
			"msg": "gain 3 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 3),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Constellation Protocol", NRUtil.merge({
		"title": "Constellation Protocol",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 2,
		"text": "When your turn begins, you may move an advancement token from a piece of ice to an installed piece of ice that can be advanced."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return (func():
					var a_token = NRCardRT.getv(NRCardRT.getv(NRCardRT.filter_list(NRCardRT.filter_list(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), NRCard.ice), func(_pct):
						return NRCardRT.pos(NRCard.get_counters(_pct, "advancement"))), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(empty.call(x) if empty is Callable else empty)).call(x))), 0), "title")
					return as_to_(
						NRBoard.all_installed(state, "corp"),
						it,
						NRCardRT.filter_list(it, NRCard.ice),
						NRCardRT.filter_list(it, func(_pct):
							return NRCard.can_be_advanced(state, _pct)),
						NRCardRT.filter_list(it, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(empty.call(x) if empty is Callable else empty)).call(x))),
						NRCardRT.map_list(it, func(x): return NRCardRT.getv(x, "title")),
						split_with((func(x): return not_(a_token, x)), it),
						NRCardRT.concat_lists([NRCardRT.getv(it, 0), NRCardRT.drop_n(NRCardRT.getv(NRCardRT.drop_n(it, 1), 0), 1)]),
						NRCardRT.count_of(it),
						NRCardRT.pos(it)
					)
				).call(),
		},
		"abilities": [
			{
				"label": "Move an advancement counter between 2 pieces of ice",
				"once": "per-turn",
				"waiting-prompt": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.get_counters(_pct, "advancement")),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, (func():
						var from_ice = target
						return {
							"prompt": "Choose a piece of ice that can be advanced",
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCard.ice(target) and (not NRCardRT.truthy(NRUtil.same_card(from_ice, target))) and NRCard.can_be_advanced(state, target),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("move an advancement counter from ") + str(NRToString.card_str(state, from_ice)) + str(" to ") + str(NRToString.card_str(state, target)),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRProps.add_prop(state, "corp", ne, target, "advance-counter", 1, {
										"placed": true,
									})
								, func(async_result):
									NRProps.add_prop(state, "corp", eid, from_ice, "advance-counter", -1)),
						}
					).call(), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Contract Killer", NRUtil.merge({
		"title": "Contract Killer",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "Contract Killer can be advanced.\nIf there are at least 2 advancement tokens on Contract Killer, it gains: \"[click], [trash]: Trash a <strong>connection</strong> or do 2 meat damage.\""
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"action": true,
				"label": "Trash a connection",
				"async": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets):
					return (NRCard.get_counters(card, "advancement") >= 2),
				"choices": {
					"card": func(_pct):
						return NRCard.has_subtype(_pct, "Connection"),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause-card": card,
						}
					),
			},
			{
				"action": true,
				"label": "Do 2 meat damage",
				"async": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets):
					return (NRCard.get_counters(card, "advancement") >= 2),
				"msg": "do 2 meat damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"meat",
						2,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Corporate Town", NRUtil.merge({
		"title": "Corporate Town",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"text": "As an additional cost to rez this asset, forfeit 1 agenda.\nWhen your turn begins, you may trash 1 installed resource. Trashing a resource this way cannot be prevented."
	}, (func():
		var ability = {
			"label": "Trash a resource",
			"once": "per-turn",
			"async": true,
			"prompt": "Choose a resource to trash",
			"choices": {
				"card": NRCard.resource,
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRCardRT.getv(target, "title")),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), NRCard.resource),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRMoving.trash(
					state,
					side,
					eid,
					target,
					{
						"unpreventable": true,
						"cause-card": card,
					}
				),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"additional-cost": [NRPayment.to_c("forfeit")],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return (NRCard.rezzed(card) and NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.resource)))),
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("CPC Generator", NRUtil.merge({
		"title": "CPC Generator",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "The first time the Runner spends [click] to gain 1[credit] each turn (not through a card effect), gain 1[credit]."
	}, {
		"events": [
			{
				"event": "runner-credit-gain",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var valid_ctx = func(__vec______sym____ctx____):
							return (("runner-click-credit" == NRCardRT.getv(context, "action")) or NRUtil.kw_eq("runner-click-credit", NRCardRT.getv(context, "action")))
						return (valid_ctx(targets) and NREvents.first_event(state, side, "runner-credit-gain", valid_ctx))
					).call(),
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("CSR Campaign", NRUtil.merge({
		"title": "CSR Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When your turn begins, you may draw 1 card."
	}, (func():
		var ability = {
			"once": "per-turn",
			"async": true,
			"label": "Draw 1 card (start of turn)",
			"automatic": "draw-cards",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": "Draw 1 card?",
						"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
						"yes-ability": NRDefHelpers.draw_ability(1),
					},
				}, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability, NRCardRT.set_autoresolve("auto-fire", "CSR Campaign")],
		}
	).call()))
	NRCardDefs.defcard("Cybernetics Court", NRUtil.merge({
		"title": "Cybernetics Court",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 0,
		"trash": 5,
		"factioncost": 5,
		"keywords": "Facility - Ritzy",
		"subtypes": ["Facility", "Ritzy"],
		"text": "Your maximum hand size is increased by 4."
	}, {
		"static-abilities": [NRHandSize.corp_hand_size_plus(4)],
	}))
	NRCardDefs.defcard("Cybersand Harvester", NRUtil.merge({
		"title": "Cybersand Harvester",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 2,
		"text": "Whenever you rez a piece of ice, place 2[credit] on this asset.\nYou can spend hosted credits to pay install costs.\n[trash]<strong>:</strong> Take all credits from this asset."
	}, {
		"events": [
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.ice(NRCardRT.getv(context, "card")),
				"msg": "place 2 [Credits] on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, "corp", eid, card, "credit", 2, null),
			}
		],
		"abilities": [
			{
				"label": "Take all hosted credits",
				"cost": [NRPayment.to_c("trash-can")],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRCard.get_counters(card, "credit")),
				},
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str(NRCard.get_counters(card, "credit")) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, NRCard.get_counters(card, "credit")),
			},
			{
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return spend_credits(state, side, eid, card, "credit", 1),
				"label": "Take 1 hosted [Credits] (manual)",
				"msg": "take 1 hosted [Credits]",
			}
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (("corp-install" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("corp-install", NRCardRT.getv(eid, "source-type"))),
				"type": "credit",
			},
		},
	}))
	NRCardDefs.defcard("Daily Business Show", NRUtil.merge({
		"title": "Daily Business Show",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 1,
		"keywords": "Cast",
		"subtypes": ["Cast"],
		"text": "[interrupt] → The first time each turn you would draw any number of cards, increase the number of cards you will draw by 1. When you draw those cards, add 1 of them to the bottom of R&D."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"events": [
			NRDrawing.first_time_draw_bonus("corp", 1),
			{
				"event": "corp-draw",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, "corp", "corp-draw"),
				"once": "per-turn",
				"once-key": "daily-business-show-put-bottom",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"silent": func(state, side, eid, card, targets):
					return (func():
						var dbs = NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return ((("Daily Business Show" == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq("Daily Business Show", NRCardRT.getv(_pct, "title"))) and NRCard.rezzed(_pct)))
						return (not ((card == NRCardRT.getv(dbs, 0)) or NRUtil.kw_eq(card, NRCardRT.getv(dbs, 0))))
					).call(),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
						var dbs = NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return ((("Daily Business Show" == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq("Daily Business Show", NRCardRT.getv(_pct, "title"))) and NRCard.rezzed(_pct))))
						var drawn = corp_currently_drawing
						return NREngine.resolve_ability(state, side, eid, ({
							"waiting-prompt": true,
							"prompt": str("Choose ") + str(NRCardRT.quantify(dbs, "card")) + str(" to add to the bottom of R&D"),
							"choices": {
								"max": mini(dbs, NRCardRT.count_of(drawn)),
								"card": func(_pct):
									return NRCardRT.some_list(drawn, func(c):
										return NRUtil.same_card(c, _pct)),
								"all": true,
							},
							"effect": func(state, side, eid, card, targets):
								return (func():
									for c in NRCardRT.as_array(NRCardRT.as_array(targets)):
										NRSay.system_msg(
									state,
									side,
									str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to add the ") + str(pprint_cl_format(
										null,
										"~:R",
										(int(NRCardRT.getv(keep_indexed(
											func(_pct, _pct2):
												return (_pct1 if NRCardRT.truthy(NRUtil.same_card(c, _pct2)) else null),
											drawn
										), 0)) + 1)
									)) + str(" card drawn to the bottom of R&D")
								)
										NRMoving.move(state, side, c, "deck")
										remove_from_currently_drawing(state, side, c)
									return null
								).call(),
						} if NRCardRT.truthy(NRCardRT.seq_of(drawn)) else null), card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Daily Quest", NRUtil.merge({
		"title": "Daily Quest",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"text": "Rez only during your action phase.\nWhenever the Runner makes a successful run on this server, they gain 2[credit].\nWhen your turn begins, if the Runner did not make a successful run on this server during their last turn, gain 3[credit]."
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCardRT.some_list(NRCardRT.getv(runner_reg_last, "successful-run"), NRCardRT.concat_lists([[], [
					NRCardRT.getv(NRCard.get_zone(card), 1),
					NRCardRT.getv(NRCard.get_zone(NRCardRT.getv(card, "host")), 1)
				]])))),
			"label": "gain 3 [Credits] (start of turn)",
			"automatic": "gain-credits",
			"msg": "gain 3 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 3),
		}
		return {
			"rez-req": func(state, side, eid, card, targets):
				return ((NRCardRT.getv(state.data, "active-player") == "corp") or NRUtil.kw_eq(NRCardRT.getv(state.data, "active-player"), "corp")),
			"events": [
				{
					"event": "successful-run",
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRSay.system_msg(state, "runner", str("gains 2 [Credits] for a successful run ") + str("on the Daily Quest server"))
						return NRGaining.gain_credits(state, "runner", eid, 2),
				},
				NRUtil.merge(ability, {"event": "corp-turn-begins"})
			],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Dedicated Response Team", NRUtil.merge({
		"title": "Dedicated Response Team",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "If the Runner is tagged, Dedicated Response Team gains \"Whenever a successful run ends, do 2 meat damage.\""
	}, {
		"events": [
			NRUtil.merge(NRDefHelpers.do_meat_damage(2), {"event": "run-ends", "req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var tagged = NRUtil.is_tagged(state)
				return (tagged and NRCardRT.getv(target, "successful"))})
		],
	}))
	NRCardDefs.defcard("Dedicated Server", NRUtil.merge({
		"title": "Dedicated Server",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "2[recurring-credit]\nUse these credits to rez ice."
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (("rez" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("rez", NRCardRT.getv(eid, "source-type"))) and NRCard.ice(target),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Director Haas", NRUtil.merge({
		"title": "Director Haas",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"trash": 5,
		"factioncost": 5,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "You get +1 allotted [click] for each of your turns.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
	}, {
		"in-play": ["click-per-turn", 1],
		"on-trash": _executive_trash_effect(),
	}))
	NRCardDefs.defcard("Docklands Crackdown", NRUtil.merge({
		"title": "Docklands Crackdown",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 0,
		"text": "[click], [click]: Place 1 power counter on Docklands Crackdown.\nThe install cost of the first card the Runner installs each turn is increased by 1 for each power counter on Docklands Crackdown."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 2)],
				"keep-menu-open": "while-2-clicks-left",
				"msg": "place 1 power counter in itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
		"static-abilities": [
			{
				"type": "install-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.runner(target) and _not_triggered_5(state),
				"value": func(state, side, eid, card, targets):
					return NRCard.get_counters(card, "power"),
			}
		],
		"events": [
			{
				"event": "runner-install",
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "power")) and _not_triggered_5(state),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("increase the install cost of ") + str(NRCardRT.getv(NRCardRT.getv(context, "card"), "title")) + str(" by ") + str(NRCard.get_counters(card, "power")) + str(" [Credits]"),
			}
		],
	}))
	NRCardDefs.defcard("Dr. Vientiane Keeling", NRUtil.merge({
		"title": "Dr. Vientiane Keeling",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 3,
		"trash": 4,
		"factioncost": 4,
		"keywords": "Academic",
		"subtypes": ["Academic"],
		"text": "When you rez this asset and when your turn begins, place 1 power counter on this asset.\nThe Runner gets -1 maximum hand size for each hosted power counter."
	}, {
		"static-abilities": [
			NRHandSize.runner_hand_size_plus(
				func(state, side, eid, card, targets):
					return (-NRCard.get_counters(card, "power"))
			)
		],
		"on-rez": _gain_power_counter(),
		"events": [NRUtil.merge(_gain_power_counter(), {"event": "corp-turn-begins"})],
	}))
	NRCardDefs.defcard("Drago Ivanov", NRUtil.merge({
		"title": "Drago Ivanov",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 0,
		"trash": 1,
		"factioncost": 4,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "You can advance this asset.\n<strong>2 hosted advancement counters:</strong> Give the Runner 1 tag. Use this ability only during your turn."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"cost": [NRPayment.to_c("advancement", 2)],
				"req": func(state, side, eid, card, targets):
					return (("corp" == NRCardRT.getv(state.data, "active-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(state.data, "active-player"))),
				"msg": "give the runner a tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "corp", eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Drudge Work", NRUtil.merge({
		"title": "Drudge Work",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"text": "Place 3 power counters on Drudge Work when it is rezzed. When there are no power counters left on Drudge Work, trash it.\n[click], <strong>hosted power counter</strong>: Reveal an agenda in HQ or Archives. Gain credits equal to its agenda points, then shuffle it into R&D."
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"events": [trash_on_empty("power")],
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
				"choices": {
					"card": func(_pct):
						return (NRCard.agenda(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
				},
				"label": "Reveal an agenda from HQ or Archives",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from ") + str(NRServers.zone_to_name(NRCard.get_zone(target))) + str((func():
						var target_agenda_points = NRCard.get_agenda_points(target)
						return str(", gain ") + str(target_agenda_points) + str(" [Credits], ")
					).call()) + str(" and shuffle it into R&D"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRGaining.gain_credits(state, "corp", ne, NRCard.get_agenda_points(target))
						, func(async_result):
							NRMoving.move(state, "corp", target, "deck")
							NRShuffling.shuffle_zone(state, "corp", "deck")
							NREid.effect_completed(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Early Premiere", NRUtil.merge({
		"title": "Early Premiere",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 3,
		"text": "When your turn begins, you may pay 1[credit]. If you do, place 1 advancement counter on a card you can advance in the root of a server."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return (NRCard.can_be_advanced(state, _pct) and NRCard.in_server(_pct))),
		},
		"abilities": [
			{
				"cost": [NRPayment.to_c("credit", 1)],
				"label": "Place 1 advancement counter on a card that can be advanced in a server",
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.can_be_advanced(state, target) and NRCard.installed(target) and NRCard.in_server(target),
				},
				"once": "per-turn",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRProps.add_prop(
						state,
						side,
						eid,
						target,
						"advance-counter",
						1,
						{
							"placed": true,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Echo Chamber", NRUtil.merge({
		"title": "Echo Chamber",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"trash": 1,
		"factioncost": 4,
		"text": "[click], [click], [click]: Add Echo Chamber to your score area as an agenda worth 1 agenda point."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Add this asset to your score area as an agenda worth 1 agenda point",
				"cost": [NRPayment.to_c("click", 3)],
				"msg": func(state, side, eid, card, targets):
					return str("add itself to [their] score area as an agenda worth 1 agenda point"),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, "corp", card, 1),
			}
		],
	}))
	NRCardDefs.defcard("Edge of World", NRUtil.merge({
		"title": "Edge of World",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "When the Runner accesses this asset while it is installed, you may pay 3[credit]. If you do, do 1 core damage for each piece of ice protecting this server."
	}, installed_access_trigger(
		3,
		{
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str(_ice_count_6(state)) + str(" core damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"brain",
					_ice_count_6(state),
					{
						"card": card,
					}
				),
		}
	)))
	NRCardDefs.defcard("Eliza's Toybox", NRUtil.merge({
		"title": "Eliza's Toybox",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 4,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Ritzy",
		"subtypes": ["Ritzy"],
		"text": "[click],[click],[click]: Rez a card, ignoring all costs."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 3)],
				"keep-menu-open": "while-3-clicks-left",
				"label": "Rez a card, ignoring all costs",
				"choices": {
					"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.corp(x)) and NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.agenda(x)))) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x))))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRRezzing.rez(
						state,
						side,
						eid,
						target,
						{
							"ignore-cost": "all-costs",
							"msg-keys": {
								"include-cost-from-eid": eid,
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Elizabeth Mills", NRUtil.merge({
		"title": "Elizabeth Mills",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Executive - Liability",
		"subtypes": ["Executive", "Liability"],
		"text": "When you rez this asset, remove 1 bad publicity.\n[click], [trash]<strong>:</strong> Trash 1 installed <strong>location</strong> resource. Take 1 bad publicity."
	}, {
		"on-rez": {
			"msg": "remove 1 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.lose_bad_publicity(state, side, 1),
		},
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"label": "Trash a location and take 1 bad publicity",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NREngine.resolve_ability(state, side, eid, {
						"prompt": "Trash a location and take 1 bad publicity",
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("trash ") + str(NRCardRT.getv(target, "title")) + str(" and take 1 bad publicity"),
						"choices": {
							"min": 1,
							"card": func(_pct):
								return NRCard.has_subtype(_pct, "Location"),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, target, {
									"cause-card": card,
								})
							, func(async_result):
								NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
					}, card, null) if NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
						return NRCard.has_subtype(_pct, "Location")) else NREngine.resolve_ability(state, side, eid, {
						"msg": "take 1 bad publicity",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRBadPublicity.gain_bad_publicity(state, side, eid, 1),
					}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Encryption Protocol", NRUtil.merge({
		"title": "Encryption Protocol",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"text": "The trash cost of all installed cards is increased by 1."
	}, {
		"static-abilities": [
			{
				"type": "trash-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target),
				"value": 1,
			}
		],
	}))
	NRCardDefs.defcard("Esca", NRUtil.merge({
		"title": "Esca",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they lose 1[credit]. If they are tagged, do 1 net damage."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"msg": "force the Runner to lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.lose_credits(state, "runner", ne, 1)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"req": func(state, side, eid, card, targets):
							var tagged = NRUtil.is_tagged(state)
							return tagged,
						"msg": "do 1 net damage",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(state, side, eid, "net", 1),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Estelle Moon", NRUtil.merge({
		"title": "Estelle Moon",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Whenever you install a card in the root of a remote server, place 1 power counter on this asset.\n<strong>[trash]:</strong> For each power counter on this asset, gain 2[credit] and draw 1 card."
	}, {
		"events": [
			{
				"event": "corp-install",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (NRCard.asset(NRCardRT.getv(context, "card")) or NRCard.agenda(NRCardRT.getv(context, "card")) or NRCard.upgrade(NRCardRT.getv(context, "card"))) and NRServers.is_remote(NRCardRT.getv(NRCard.get_zone(NRCardRT.getv(context, "card")), 1)),
				"msg": "place 1 power counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
		"abilities": [
			{
				"label": "Draw 1 card and gain 2 [Credits] for each hosted power counter",
				"cost": [NRPayment.to_c("trash-can")],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRCard.get_counters(card, "power")),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
						var counters = NRCard.get_counters(card, "power")
						var credits = (2 * counters)
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to draw ") + str(NRCardRT.quantify(counters, "card")) + str(" and gain ") + str(credits) + str(" [Credits]"))
						return NREid.wait_for(state, eid, func(ne):
							NRDrawing.draw(state, side, ne, counters)
						, func(async_result):
							NRGaining.gain_credits(state, side, eid, credits))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Eve Campaign", NRUtil.merge({
		"title": "Eve Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "Place 16[credit] from the bank on Eve Campaign when it is rezzed. When there are no credits left on Eve Campaign, trash it.\nWhen your turn begins, take 2[credit] from Eve Campaign."
	}, _campaign(16, 2)))
	NRCardDefs.defcard("Executive Boot Camp", NRUtil.merge({
		"title": "Executive Boot Camp",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"text": "When your turn begins, you may rez a card, lowering the rez cost by 1[credit].\n1[credit],[trash]: Search R&D for an asset, reveal it, and add it to HQ. Shuffle R&D."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"events": [
			{
				"event": "corp-turn-begins",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"prompt": "Rez a card, paying 1 [Credit] less",
				"waiting-prompt": true,
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.corp(target) and NRCard.installed(target) and (not NRCardRT.truthy(NRCard.rezzed(target))) and NRRezzing.can_pay_to_rez(
							state,
							side,
							eid,
							target,
							{
								"cost-bonus": -1,
							}
						),
				},
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return (not NRCardRT.truthy(NRCard.rezzed(_pct)))),
					"silent": true,
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRRezzing.rez(
						state,
						side,
						eid,
						target,
						{
							"cost-bonus": -1,
							"no-warning": true,
						}
					),
			}
		],
		"abilities": [
			{
				"prompt": "Choose an asset to reveal and add to HQ",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(", add it to HQ, and shuffle R&D"),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.asset))),
				"cost": [NRPayment.to_c("credit", 1), NRPayment.to_c("trash-can")],
				"cancel": NRUtil.merge(NRShuffling.shuffle_deck, {"cost": [NRPayment.to_c("credit", 1), NRPayment.to_c("trash-can")]}),
				"label": "Search R&D for an asset",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NRShuffling.shuffle_zone(state, side, "deck")
						NRMoving.move(state, side, target, "hand")
						NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Executive Search Firm", NRUtil.merge({
		"title": "Executive Search Firm",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Alliance - Ritzy",
		"subtypes": ["Alliance", "Ritzy"],
		"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [weyland-consortium] cards in your deck.\n[click]: Search R&D for an <strong>executive</strong>, <strong>sysop</strong>, or <strong>character</strong>, reveal it, and add it to HQ. Shuffle R&D."
	}, {
		"abilities": [
			{
				"action": true,
				"prompt": "Choose an Executive, Sysop, or Character to add to HQ",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(", add it to HQ, and shuffle R&D"),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
						return NRCard.has_any_subtype(_pct, ["Executive", "Sysop", "Character"])))),
				"cost": [NRPayment.to_c("click", 1)],
				"cancel": NRUtil.merge(NRShuffling.shuffle_deck, {"cost": [NRPayment.to_c("click", 1)], "action": true}),
				"keep-menu-open": "while-clicks-left",
				"label": "Search R&D for an Executive, Sysop, or Character",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRMoving.move(state, side, target, "hand")
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}
		],
	}))
	NRCardDefs.defcard("Exposé", NRUtil.merge({
		"title": "Exposé",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"text": "You can advance this asset.\n[trash]<strong>:</strong> Remove 1 bad publicity for each hosted advancement counter."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"label": "Remove 1 bad publicity for each advancement counter on Exposé",
				"msg": func(state, side, eid, card, targets):
					return str("remove ") + str(NRCard.get_counters(card, "advancement")) + str(" bad publicity"),
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NRBadPublicity.lose_bad_publicity(state, side, NRCard.get_counters(card, "advancement")),
			}
		],
	}))
	NRCardDefs.defcard("False Flag", NRUtil.merge({
		"title": "False Flag",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "False Flag can be advanced.\nWhen the Runner accesses False Flag, give the Runner 1 tag for every 2 advancement tokens on False Flag.\n[click], <strong>7 hosted advancement tokens</strong>: add False Flag to your score area as an agenda worth 3 agenda points."
	}, {
		"advanceable": "always",
		"on-access": {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"msg": func(state, side, eid, card, targets):
				return str("give the runner ") + str(NRCardRT.quantify(_tag_count_7(NRCard.get_card(state, card)), "tag")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.gain_tags(state, "corp", eid, _tag_count_7(NRCard.get_card(state, card))),
		},
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("advancement", 7)],
				"label": "Add this asset to your score area as an agenda worth 3 agenda points",
				"msg": func(state, side, eid, card, targets):
					return str("add itself to [their] score area as an agenda worth 3 agenda points"),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, "corp", card, 3),
			}
		],
	}))
	NRCardDefs.defcard("Federal Fundraising", NRUtil.merge({
		"title": "Federal Fundraising",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political - Ritzy",
		"subtypes": ["Political", "Ritzy"],
		"text": "When your turn begins, you may look at the top 3 cards of R&D and arrange them in any order. Then, if this server is not protected by ice, you may draw 1 card."
	}, (func():
		var draw_ab = {
			"optional": {
				"req": func(state, side, eid, card, targets):
					var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
					return unprotected,
				"prompt": "Draw 1 card?",
				"waiting-prompt": true,
				"yes-ability": {
					"msg": "draw 1 card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, side, eid, 1),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title")) + str(" to draw 1 card")),
				},
			},
		}
		var ability = {
			"once": "per-turn",
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.getv(state.data, "corp-phase-12") and NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"label": "Look at the top 3 cards of R&D (start of turn)",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": "Look at the top 3 cards of R&D?",
						"waiting-prompt": true,
						"no-ability": draw_ab,
						"yes-ability": {
							"msg": "rearrange the top 3 cards of R&D",
							"async": true,
							"waiting-prompt": true,
							"effect": func(state, side, eid, card, targets):
								var corp = state.player("corp")
								return (func():
									var from = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3))
									return NREid.wait_for(state, eid, func(ne):
										NREngine.resolve_ability(state, side, ne, reorder_choice("corp", "runner", from, null, NRCardRT.count_of(from), from), card, null)
									, func(async_result):
										NREngine.resolve_ability(state, side, eid, draw_ab, card, null))
								).call(),
						},
					},
				}, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Franchise City", NRUtil.merge({
		"title": "Franchise City",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"trash": 2,
		"factioncost": 5,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "While the Runner is accessing an agenda in R&D, they must reveal it.\nWhen the Runner accesses an agenda, add this asset to your score area as an agenda worth 1 agenda point."
	}, {
		"events": [
			{
				"event": "access",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.agenda(NRCardRT.getv(context, "accessed-card")),
				"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, "corp", card, 1),
			}
		],
	}))
	NRCardDefs.defcard("Front Company", NRUtil.merge({
		"title": "Front Company",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political - Seedy",
		"subtypes": ["Political", "Seedy"],
		"text": "Rez only during your turn.\nThe first run each turn cannot be made against a remote server.\nThe first time each turn a run on Archives begins, if this server is not protected by ice, do 2 net damage."
	}, {
		"static-abilities": [
			{
				"type": "cannot-run-on-server",
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCardRT.pos(NRCardRT.count_of(NREvents.turn_events(state, side, "run"))))),
				"value": func(state, side, eid, card, targets):
					return NRCardRT.map_list(NRBoard.get_remotes(state), func(x): return NRCardRT.truthy(first.call(x) if first is Callable else first)),
			}
		],
		"rez-req": func(state, side, eid, card, targets):
			return ((NRCardRT.getv(state.data, "active-player") == "corp") or NRUtil.kw_eq(NRCardRT.getv(state.data, "active-player"), "corp")),
		"events": [
			{
				"event": "run",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
					return (("archives" == NRServers.target_server(context)) or NRUtil.kw_eq("archives", NRServers.target_server(context))) and NREvents.first_event(
						state,
						"runner",
						"run",
						func(_pct):
							return (("archives" == NRServers.target_server(NRCardRT.getv(_pct, 0))) or NRUtil.kw_eq("archives", NRServers.target_server(NRCardRT.getv(_pct, 0))))
					) and unprotected,
				"msg": "do 2 net damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(state, side, eid, "net", 2),
			}
		],
	}))
	NRCardDefs.defcard("Full Immersion RecStudio", NRUtil.merge({
		"title": "Full Immersion RecStudio",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "Full Immersion RecStudio can host up to 2 assets and/or agendas.\nThe trash cost of Full Immersion RecStudio is increased by 3 for each card hosted on it."
	}, {
		"can-host": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return ((NRCard.asset(target) or NRCard.agenda(target)) and (2 > NRCardRT.count_of(NRCardRT.getv(card, "hosted")))),
		"trash-cost-bonus": func(state, side, eid, card, targets):
			return (3 * NRCardRT.count_of(NRCardRT.getv(card, "hosted"))),
		"abilities": [
			{
				"action": true,
				"label": "Install an asset or agenda on this asset",
				"req": func(state, side, eid, card, targets):
					return (NRCardRT.count_of(NRCardRT.getv(card, "hosted")) < 2),
				"cost": [NRPayment.to_c("click", 1)],
				"prompt": "Choose an asset or agenda to install",
				"choices": {
					"card": func(_pct):
						return ((NRCard.asset(_pct) or NRCard.agenda(_pct)) and NRCard.in_hand(_pct) and NRCard.corp(_pct)),
				},
				"msg": "install and host an asset or agenda",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(state, side, eid, target, card, null),
			},
			{
				"label": "Install a previously-installed asset or agenda on this asset (fixes only)",
				"req": func(state, side, eid, card, targets):
					return (NRCardRT.count_of(NRCardRT.getv(card, "hosted")) < 2),
				"prompt": "Choose an installed asset or agenda to host",
				"choices": {
					"card": func(_pct):
						return ((NRCard.asset(_pct) or NRCard.agenda(_pct)) and NRCard.installed(_pct) and NRCard.corp(_pct)),
				},
				"msg": "install and host an asset or agenda",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRHosting.host(state, side, card, target),
			}
		],
	}))
	NRCardDefs.defcard("Fumiko Yamamori", NRUtil.merge({
		"title": "Fumiko Yamamori",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 4,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever you and the Runner reveal secretly spent credits, do 1 meat damage if you and the Runner spent a different number of credits."
	}, {
		"events": [
			{
				"event": "reveal-spent-credits",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var _m_8 = context
						var corp_credits = NRCardRT.getv(_m_8, "corp-credits")
						var runner_credits = NRCardRT.getv(_m_8, "runner-credits")
						return ((corp_credits != null) and (runner_credits != null) and (not ((corp_credits == runner_credits) or NRUtil.kw_eq(corp_credits, runner_credits))))
					).call(),
				"msg": "do 1 meat damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"meat",
						1,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Gaslight", NRUtil.merge({
		"title": "Gaslight",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"text": "When your turn begins, you may trash this asset. If you do, search R&D for an operation and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that operation to HQ."
	}, (func():
		var search_for_operation = {
			"prompt": "Choose an operation to add to HQ",
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(("shuffle R&D" if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else str("add ") + str(NRCard.get_title(target)) + str(" from R&D to HQ"))),
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRCardRT.as_array(NRCardRT.as_array(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.operation)))) + ["Done"]),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return ((func():
					NRShuffling.shuffle_zone(state, "corp", "deck")
					return NREid.effect_completed(state, side, eid)
				).call() if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, target)
				, func(async_result):
					NRShuffling.shuffle_zone(state, "corp", "deck")
					NRMoving.move(state, "corp", target, "hand")
					NREid.effect_completed(state, side, eid))),
		}
		var ability = {
			"once": "per-turn",
			"skippable": true,
			"async": true,
			"label": "Search R&D for an operation (start of turn)",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": "Trash this asset to search R&D for an operation?",
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, card, {
										"cause-card": card,
									})
								, func(async_result):
									NREngine.resolve_ability(state, side, eid, search_for_operation, card, null)),
						},
					},
				}, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Gene Splicer", NRUtil.merge({
		"title": "Gene Splicer",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "Gene Splicer can be advanced.\nWhen the Runner accesses Gene Splicer, do 1 net damage for each advancement token on Gene Splicer.\n<strong>[click], 3 hosted advancement tokens:</strong> Add Gene Splicer to your score area as an agenda worth 1 agenda point."
	}, {
		"advanceable": "always",
		"on-access": {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str(NRCard.get_counters(NRCard.get_card(state, card), "advancement")) + str(" net damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					NRCard.get_counters(NRCard.get_card(state, card), "advancement"),
					{
						"card": card,
					}
				),
		},
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("advancement", 3)],
				"label": "Add this asset to your score area as an agenda worth 1 agenda point",
				"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, "corp", card, 1),
			}
		],
	}))
	NRCardDefs.defcard("Genetics Pavilion", NRUtil.merge({
		"title": "Genetics Pavilion",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 5,
		"factioncost": 5,
		"keywords": "Facility - Ritzy",
		"subtypes": ["Facility", "Ritzy"],
		"text": "The Runner cannot draw more than 2 cards during each of their turns."
	}, {
		"on-rez": {
			"msg": func(state, side, eid, card, targets):
				return str("prevent the Runner from drawing more than 2 cards during [runner-pronoun] turn"),
			"effect": func(state, side, eid, card, targets):
				NRDrawing.max_draw(state, "runner", 2)
				return (NRFlags.prevent_draw(state, "runner") if NRCardRT.truthy(NRCardRT.zero(NRDrawing.remaining_draws(state, "runner"))) else null),
		},
		"events": [
			{
				"event": "runner-turn-begins",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRDrawing.max_draw(state, "runner", 2),
			}
		],
		"leave-play": func(state, side, eid, card, targets):
			return state.update_in(["runner", "register"], func(v): return v),
	}))
	NRCardDefs.defcard("Ghost Branch", NRUtil.merge({
		"title": "Ghost Branch",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 1,
		"keywords": "Ambush - Facility",
		"subtypes": ["Ambush", "Facility"],
		"text": "Ghost Branch can be advanced.\nWhen the Runner accesses Ghost Branch, you may give the Runner 1 tag for each advancement token on Ghost Branch."
	}, _advance_ambush(
		0,
		{
			"async": true,
			"waiting-prompt": true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"msg": func(state, side, eid, card, targets):
				return str("give the Runner ") + str(NRCardRT.quantify(NRCard.get_counters(NRCard.get_card(state, card), "advancement"), "tag")),
			"effect": func(state, side, eid, card, targets):
				return NRTags.gain_tags(state, "corp", eid, NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
		}
	)))
	NRCardDefs.defcard("GRNDL Refinery", NRUtil.merge({
		"title": "GRNDL Refinery",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "GRNDL Refinery can be advanced.\n[click], [trash]: Gain 4[credit] for each advancement token on GRNDL Refinery."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"action": true,
				"label": "Gain 4 [Credits] for each advancement counter on GRNDL Refinery",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str((4 * NRCard.get_counters(card, "advancement"))) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, (4 * NRCard.get_counters(card, "advancement"))),
			}
		],
	}))
	NRCardDefs.defcard("Haas Arcology AI", NRUtil.merge({
		"title": "Haas Arcology AI",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 1,
		"factioncost": 4,
		"text": "You can advance this asset if it is unrezzed.\nOnce per turn → [click], <strong>hosted advancement counter:</strong> Gain [click][click]."
	}, {
		"advanceable": "while-unrezzed",
		"abilities": [
			{
				"action": true,
				"label": "Gain [Click][Click]",
				"once": "per-turn",
				"msg": "gain [Click][Click]",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("advancement", 1)],
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_clicks(state, side, 2),
			}
		],
	}))
	NRCardDefs.defcard("Hearts and Minds", NRUtil.merge({
		"title": "Hearts and Minds",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Political",
		"subtypes": ["Political"],
		"text": "When your turn begins, you may move 1 advancement counter from an installed card to an installed card you can advance. If this server is not protected by ice, you may also place 1 advancement counter on an installed card you can advance."
	}, (func():
		var political = NRUtil.merge(place_advancement_counter(true, 1), {"req": func(state, side, eid, card, targets):
			var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
			return unprotected})
		var ability = {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"label": "Move 1 hosted advancement counter to another card you can advance (start of turn)",
			"skippable": true,
			"once": "per-turn",
			"waiting-prompt": true,
			"prompt": "Choose an installed card to move 1 hosted advancement counter from",
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCardRT.pos(NRCard.get_counters(_pct, "advancement"))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var from_ice = target
					return {
						"prompt": "Choose an installed card you can advance",
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRCard.installed(target) and NRCard.can_be_advanced(state, target) and (not NRCardRT.truthy(NRUtil.same_card(from_ice, target))),
						},
						"msg": {
							"public": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("move 1 hosted advancement counter from ") + str(NRToString.card_str(state, from_ice)) + str(" to ") + str(NRToString.card_str(state, target)),
							"corp": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("move 1 hosted advancement counter from ") + str(NRToString.card_str(
									state,
									from_ice,
									{
										"maybe-visible": true,
									}
								)) + str(" to ") + str(NRToString.card_str(
									state,
									target,
									{
										"maybe-visible": true,
									}
								)),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRProps.add_prop(state, "corp", ne, target, "advance-counter", 1, {
									"placed": true,
								})
							, func(async_result):
								NREid.wait_for(state, eid, func(ne):
									NRProps.add_prop(state, "corp", ne, from_ice, "advance-counter", -1)
								, func(async_result):
									NREngine.resolve_ability(state, "corp", eid, political, card, null))),
						"cancel": political,
					}
				).call(), card, null),
			"cancel": political,
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Honeyfarm", NRUtil.merge({
		"title": "Honeyfarm",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they lose 1[credit]."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"msg": "force the Runner to lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "runner", eid, 1),
		},
	}))
	NRCardDefs.defcard("Hostile Architecture", NRUtil.merge({
		"title": "Hostile Architecture",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 5,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "The first time each turn the Runner trashes any of your installed cards <em>(including this asset)</em>, do 2 meat damage."
	}, {
		"events": [
			{
				"event": "runner-trash",
				"async": true,
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets):
					return _valid_ctx_9(targets) and NREvents.first_event(state, side, "runner-trash", _valid_ctx_9()),
				"msg": "do 2 meat damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						"corp",
						eid,
						"meat",
						2,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Hostile Infrastructure", NRUtil.merge({
		"title": "Hostile Infrastructure",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"trash": 5,
		"factioncost": 2,
		"text": "Whenever the Runner trashes a Corp card (including Hostile Infrastructure), do 1 net damage."
	}, {
		"events": [
			{
				"event": "runner-trash",
				"async": true,
				"once-per-instance": false,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.corp(NRCardRT.getv(target, "card")),
				"msg": "do 1 net damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						"corp",
						eid,
						"net",
						1,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Humanoid Resources", NRUtil.merge({
		"title": "Humanoid Resources",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 2,
		"text": "[click][click][click], [trash]<strong>:</strong> Gain 4[credit] and draw 3 cards. Install up to 2 cards from HQ <em>(one at a time)</em>. You may play 1 operation from HQ."
	}, (func():
		var play_an_instant = {
			"prompt": "Choose an operation",
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), func(_pct):
					return (NRCard.operation(_pct) and NREngine.should_trigger(state, "corp", NRUtil.merge(eid, {"source": _pct, "source-type": "play"}), _pct, null, (NRCardRT.getv(NRCardDefs.card_def(_pct), "on-play") or {})) and NRPayment.can_pay(state, side, NRUtil.merge(eid, {"source": _pct, "source-type": "play"}), _pct, null, [NRPayment.to_c("credit", NRCostFns.play_cost(state, side, _pct, null))])))) + ["Done"]),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NREid.effect_completed(state, side, eid) if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NRPlayInstants.play_instant(state, side, eid, target, null)),
		}
		return {
			"abilities": [
				{
					"cost": [NRPayment.to_c("click", 3), NRPayment.to_c("trash-can", 1)],
					"action": true,
					"label": "Gain 4 [Credits] and draw 3 cards",
					"msg": "gain 4 [Credits] and draw 3 cards",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRSay.play_sfx(state, side, "professional-contacts")
						return NREid.wait_for(state, eid, func(ne):
							NRGaining.gain_credits(state, side, ne, 4, {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
								NRDrawing.draw(state, side, ne, 3)
							, func(async_result):
								NREid.wait_for(state, eid, func(ne):
									NREngine.resolve_ability(state, side, ne, corp_install_up_to_n_cards(2), card, null)
								, func(async_result):
									NREngine.resolve_ability(state, side, eid, play_an_instant, card, null)))),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Hyoubu Research Facility", NRUtil.merge({
		"title": "Hyoubu Research Facility",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "The first time each turn you reveal secretly spent credits, gain that many credits."
	}, {
		"events": [
			{
				"event": "reveal-spent-credits",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (NRCardRT.getv(context, "corp-credits") != null) and NREvents.first_event(state, side, "reveal-spent-credits"),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("gain ") + str(NRCardRT.getv(context, "corp-credits")) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRGaining.gain_credits(state, "corp", eid, NRCardRT.getv(context, "corp-credits")),
			}
		],
	}))
	NRCardDefs.defcard("Ibrahim Salem", NRUtil.merge({
		"title": "Ibrahim Salem",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Alliance - Character",
		"subtypes": ["Alliance", "Character"],
		"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [nbn] cards in your deck.\nAs an additional cost to rez Ibrahim Salem, forfeit an agenda.\nWhen your turn begins, name a card type. Look at the Runner's grip and trash 1 card in it of the named type."
	}, (func():
		var trash_ability = func(card_type):
			return with_revealed_hand(
			"runner",
			{
				"event-side": "corp",
			},
			{
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
						return NRCard.is_type(_pct, card_type))),
				"prompt": str("Choose a ") + str(card_type) + str(" to trash"),
				"choices": {
					"card": func(_pct):
						return (NRCard.in_hand(_pct) and NRCard.runner(_pct) and NRCard.is_type(_pct, card_type)),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause-card": card,
						}
					),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")) + str(" from the grip"),
			}
		)
		var choose_ability = {
			"label": "Trash 1 card in the grip of a named type",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "hand")),
				"silent": true,
			},
			"once": "per-turn",
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRCardRT.seq_of(NRCardRT.getv(runner, "hand")),
			"prompt": "Choose a card type",
			"choices": ["Event", "Hardware", "Program", "Resource"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(target),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, trash_ability(target), card, null),
		}
		return {
			"additional-cost": [NRPayment.to_c("forfeit")],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NREffects.is_disabled_reg(state, card))),
			},
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"abilities": [choose_ability],
		}
	).call()))
	NRCardDefs.defcard("Idiosyncresis", NRUtil.merge({
		"title": "Idiosyncresis",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "You can advance this asset.\nWhen your turn begins, you may trash this asset. If you do, for each hosted advancement counter, gain 3[credit] and the Runner loses 2[credit]."
	}, (func():
		var abi = {
			"event": "corp-turn-begins",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"label": "Trash Idiosyncresis",
			"optional": {
				"prompt": "Trash Idiosyncresis?",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(state.data, "corp-phase-12"),
				"yes-ability": {
					"async": true,
					"msg": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return str("force the runner to lose ") + str(NRGaining.lose(card, runner)) + str(" [Credits], and then gain ") + str(NRGaining.gain(card)) + str(" [Credits]"),
					"cost": [NRPayment.to_c("trash-can")],
					"effect": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NREid.wait_for(state, eid, func(ne):
							NRGaining.lose_credits(state, "runner", ne, NRGaining.lose(card, runner))
						, func(async_result):
							NRGaining.gain_credits(state, side, eid, NRGaining.gain(card))),
				},
			},
		}
		return {
			"advanceable": "always",
			"events": [abi],
			"abilities": [abi],
		}
	).call()))
	NRCardDefs.defcard("Illegal Arms Factory", NRUtil.merge({
		"title": "Illegal Arms Factory",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"trash": 6,
		"factioncost": 2,
		"keywords": "Facility - Liability",
		"subtypes": ["Facility", "Liability"],
		"text": "When your turn begins, gain 1[credit] and draw 1 card.\nWhen the Runner trashes this asset <em>(while it is rezzed)</em>, take 1 bad publicity."
	}, (func():
		var ability = {
			"msg": "gain 1 [Credits] and draw 1 card",
			"label": "Gain 1 [Credits] and draw 1 card (start of turn)",
			"once": "per-turn",
			"automatic": "draw-cards",
			"async": true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 1)
				, func(async_result):
					NRDrawing.draw(state, side, eid, 1)),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
			"on-trash": {
				"req": func(state, side, eid, card, targets):
					return ((side == "runner") or NRUtil.kw_eq(side, "runner")),
				"msg": "take 1 bad publicity",
				"effect": func(state, side, eid, card, targets):
					return NRBadPublicity.gain_bad_publicity(state, "corp", 1),
			},
		}
	).call()))
	NRCardDefs.defcard("Indian Union Stock Exchange", NRUtil.merge({
		"title": "Indian Union Stock Exchange",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"text": "Whenever you rez or play an out-of-faction card (including Indian Union Stock Exchange), gain 1[credit]."
	}, {
		"events": [
			{
				"event": "play-operation",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var corp = state.player("corp")
					return (not ((NRCardRT.getv(NRCardRT.getv(context, "card"), "faction") == NRCardRT.getv(NRCardRT.getv(corp, "identity"), "faction")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "faction"), NRCardRT.getv(NRCardRT.getv(corp, "identity"), "faction")))),
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 1),
			},
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var corp = state.player("corp")
					return (not ((NRCardRT.getv(NRCardRT.getv(context, "card"), "faction") == NRCardRT.getv(NRCardRT.getv(corp, "identity"), "faction")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "faction"), NRCardRT.getv(NRCardRT.getv(corp, "identity"), "faction")))),
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Investigator Inez Delgado A", NRUtil.merge({
		"title": "Investigator Inez Delgado A",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 0,
		"trash": 5,
		"factioncost": 0,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever you score an agenda, you may swap it with an agenda in the Runner's score area worth at least 1 point, then resolve the \"when scored\" ability on that agenda."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "scored")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return (func():
						var scored = NRCardRT.getv(context, "card")
						return NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"prompt": func(state, side, eid, card, targets):
									return str("Swap ") + str(NRCardRT.getv(scored, "title")) + str(" for an agenda in the Runner's score area?"),
								"waiting-prompt": true,
								"req": func(state, side, eid, card, targets):
									return NRCardRT.seq_of(state.get_in(["runner", "scored"], null)),
								"yes-ability": {
									"prompt": str("Choose a scored Runner agenda to swap with ") + str(NRCardRT.getv(scored, "title")),
									"choices": {
										"req": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return NRFlags.in_runner_scored(state, side, target) and NRCardRT.getv(target, "agendapoints") and NRCardRT.pos(NRCardRT.getv(target, "agendapoints")),
									},
									"msg": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return str("swap ") + str(NRToString.card_str(state, scored)) + str(" for ") + str(NRToString.card_str(state, target)),
									"async": true,
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return (func():
											var new_scored = NRCardRT.getv(swap_agendas(state, side, scored, target), 1)
											return NREngine.resolve_ability(state, side, eid, NRCardRT.getv(NRCardDefs.card_def(new_scored), "on-score"), new_scored, null)
										).call(),
								},
							},
						}, card, targets)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Investigator Inez Delgado A 2", NRUtil.merge({
		"title": "Investigator Inez Delgado A 2",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 0,
		"trash": 5,
		"factioncost": 0,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever the Runner steals an agenda, you may resolve the \"when scored\" ability on that agenda, then swap it with an agenda in your scored area."
	}, {
		"events": [
			{
				"event": "agenda-stolen",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"skippable": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var stolen = NRCardRT.getv(context, "card")
						return (NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"prompt": str("Resolve the when-scored ability on ") + str(NRCardRT.getv(stolen, "title")),
								"waiting-prompt": true,
								"yes-ability": {
									"async": true,
									"msg": func(state, side, eid, card, targets):
										return str("resolve the when-scored ability on ") + str(NRCardRT.getv(stolen, "title")),
									"effect": func(state, side, eid, card, targets):
										return NREid.wait_for(state, eid, func(ne):
											NREngine.resolve_ability(state, side, ne, NRCardRT.getv(NRCardDefs.card_def(stolen), "on-score"), stolen, null)
										, func(async_result):
											(NREngine.resolve_ability(state, side, eid, _swap_abi_13(stolen), card, null) if NRCard.get_card(state, stolen) else NREid.effect_completed(state, side, eid))),
								},
								"no-ability": _swap_abi_13(stolen),
							},
						}, card, null) if NRCardRT.getv(NRCardDefs.card_def(stolen), "on-score") else NREngine.resolve_ability(state, side, eid, _swap_abi_13(stolen), card, null))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Isabel McGuire", NRUtil.merge({
		"title": "Isabel McGuire",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "[click]: Add 1 of your installed cards to HQ."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Add an installed card to HQ",
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"choices": {
					"card": NRCard.installed,
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("move ") + str(NRToString.card_str(state, target)) + str(" to HQ"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.move(state, side, target, "hand"),
			}
		],
	}))
	NRCardDefs.defcard("IT Department", NRUtil.merge({
		"title": "IT Department",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 1,
		"text": "[click]: Place 1 power counter on IT Department.\n<strong>Hosted power counter:</strong> Choose a rezzed piece of ice. That ice has +1 strength until the end of the turn for each power counter (including the one spent) on IT Department."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"msg": "place 1 power counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			},
			{
				"cost": [NRPayment.to_c("power", 1)],
				"keep-menu-open": "while-power-tokens-left",
				"label": "Add strength to a rezzed piece of ice",
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
				},
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "power")),
				"msg": "add strength to a rezzed piece of ice",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						(func():
							var it_target = target
							return {
								"type": "ice-strength",
								"duration": "end-of-turn",
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRUtil.same_card(target, it_target),
								"value": func(state, side, eid, card, targets):
									return (int(NRCard.get_counters(card, "power")) + 1),
							}
						).call()
					)
					return NRIce.update_ice_strength(state, side, target),
			}
		],
	}))
	NRCardDefs.defcard("Jackson Howard", NRUtil.merge({
		"title": "Jackson Howard",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "[click]: Draw 2 cards.\n<strong>Remove Jackson Howard from the game:</strong> Shuffle up to 3 cards from Archives into R&D."
	}, {
		"abilities": [
			NRDefHelpers.draw_ability(
				2,
				null,
				{
					"action": true,
					"cost": [NRPayment.to_c("click", 1)],
					"keep-menu-open": "while-clicks-left",
				}
			),
			{
				"label": "Shuffle up to 3 cards from Archives into R&D",
				"cost": [NRPayment.to_c("remove-from-game")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return shuffle_into_rd_effect(state, side, eid, card, 3),
			}
		],
	}))
	NRCardDefs.defcard("Janaína \"JK\" Dumont Kindelán", NRUtil.merge({
		"title": "Janaína \"JK\" Dumont Kindelán"
	}, (func():
		var ability = {
			"label": "Place 3 [Credits] on this asset (start of turn)",
			"once": "per-turn",
			"msg": "place 3 [Credits] on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(
					state,
					side,
					eid,
					card,
					"credit",
					3,
					{
						"placed": true,
					}
				),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [
				ability,
				{
					"action": true,
					"cost": [NRPayment.to_c("click", 1)],
					"label": "Take all hosted credits and add this asset to HQ. Install 1 card from HQ",
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("gain ") + str(NRCard.get_counters(NRCard.get_card(state, card), "credit")) + str(" [Credits] and add itself to HQ"),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						(NRSay.play_sfx(state, side, "click-credit-3") if NRCardRT.truthy(NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "credit"))) else null)
						return NREid.wait_for(state, eid, func(ne):
							NRDefHelpers.take_credits(state, side, ne, card, "credit", "all")
						, func(async_result):
							NRMoving.move(state, "corp", card, "hand")
							NREngine.resolve_ability(state, side, eid, {
								"async": true,
								"prompt": "Choose 1 card to install",
								"choices": {
									"card": func(_pct):
										return (NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
								},
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRInstalling.corp_install(
										state,
										side,
										eid,
										target,
										null,
										{
											"msg-keys": {
												"install-source": card,
												"display-origin": true,
											},
										}
									),
							}, card, null)),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Jeeves Model Bioroids", NRUtil.merge({
		"title": "Jeeves Model Bioroids",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Alliance",
		"subtypes": ["Alliance"],
		"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [haas-bioroid] cards in your deck.\nThe first time you spend 3[click] on the same action each turn, gain [click]."
	}, (func():
		var ability = {
			"label": "Gain [Click]",
			"msg": "gain [Click]",
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		}
		var cleanup = func(state, side, eid, card, targets):
			return NRUpdate.update_card(state, side, NRUtil.dissoc(card, ["seen-this-turn"]))
		return {
			"abilities": [ability],
			"leave-play": cleanup,
			"events": [
				{
					"event": "corp-spent-click",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (func():
							var _m_14 = context
							var action = NRCardRT.getv(_m_14, "action")
							var value = NRCardRT.getv(_m_14, "value")
							var ability_idx = NRCardRT.getv(_m_14, "ability-idx")
							var bac_cid = state.get_in(["corp", "basic-action-card", "cid"], null)
							var cause = (([bac_cid, 3] if ((action == "play-instant") or NRUtil.kw_eq(action, "play-instant")) else ([bac_cid, 2] if ((action == "corp-click-install") or NRUtil.kw_eq(action, "corp-click-install")) else [action, ability_idx])) if (action is String) else [action, ability_idx])
							var clicks_spent = (NRCardRT.get_in(card, ["seen-this-turn", cause], 0) + value)
							var card = NRUpdate.update_card(state, side, NRUtil.assoc_in(card, ["seen-this-turn", cause], clicks_spent))
							return (NREngine.resolve_ability(state, side, eid, ability, card, null) if (clicks_spent >= 3) else NREid.effect_completed(state, side, eid))
						).call(),
				},
				{
					"event": "corp-turn-ends",
					"silent": true,
					"effect": cleanup,
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Kala Ghoda Real TV", NRUtil.merge({
		"title": "Kala Ghoda Real TV",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 1,
		"keywords": "Cast",
		"subtypes": ["Cast"],
		"text": "When your turn begins, you may look at the top card of the stack.\n<strong>[trash]:</strong> The Runner trashes the top card of the stack."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			{
				"msg": "look at the top card of the stack",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.seq_of(NRCardRT.getv(runner, "deck")),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": func(state, side, eid, card, targets):
							var runner = state.player("runner")
							return str("The top card of the stack is ") + str(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(runner, "deck"), 0), "title")),
						"waiting-prompt": true,
						"choices": ["OK"],
					}, card, null),
			},
			{
				"async": true,
				"label": "Trash the top card of the stack",
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str("trash ") + str(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(runner, "deck"), 0), "title")) + str(" from the stack"),
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NRMoving.mill(state, "corp", eid, "runner", 1),
			}
		],
	}))
	NRCardDefs.defcard("Kuwinda K4H1U3", NRUtil.merge({
		"title": "Kuwinda K4H1U3",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "When your turn begins, you may trace[X], where X is equal to the number of hosted power counters. If successful, do 1 core damage and trash this asset. If unsuccessful, place 1 power counter on this asset."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power"),
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			{
				"label": "Trace X - do 1 core damage (start of turn)",
				"trace": {
					"base": NRCardRT.get_x_fn(),
					"successful": {
						"async": true,
						"msg": "do 1 core damage",
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRDamage.damage(state, "runner", ne, "brain", 1, {
									"card": card,
								})
							, func(async_result):
								NRMoving.trash(
									state,
									side,
									eid,
									card,
									{
										"cause-card": card,
									}
								)),
					},
					"unsuccessful": {
						"effect": func(state, side, eid, card, targets):
							return NRProps.add_counter(state, side, eid, card, "power", 1, null),
						"async": true,
						"msg": "place 1 power counter on itself",
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Lady Liberty", NRUtil.merge({
		"title": "Lady Liberty",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 5,
		"trash": 4,
		"factioncost": 0,
		"keywords": "Region - Ritzy",
		"subtypes": ["Region", "Ritzy"],
		"text": "When your turn begins, place 1 power counter on Lady Liberty.\n[click], [click], [click]: Add an agenda from HQ to your score area worth agenda points equal to the exact number of hosted power counters.\nLimit 1 <strong>region</strong> per server.\nLimit 1 per deck."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 3)],
				"keep-menu-open": "while-3-clicks-left",
				"label": "Add agenda from HQ to score area",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (func():
						var counters = NRCard.get_counters(NRCard.get_card(state, card), "power")
						return NRCardRT.some_list(NRCardRT.getv(corp, "hand"), func(_pct):
							return (NRCard.agenda(_pct) and ((counters == NRCardRT.getv(_pct, "agendapoints")) or NRUtil.kw_eq(counters, NRCardRT.getv(_pct, "agendapoints")))))
					).call(),
				"waiting-prompt": true,
				"prompt": "Choose an Agenda in HQ to add to score area",
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.agenda(target) and ((NRCardRT.getv(target, "agendapoints") == NRCard.get_counters(NRCard.get_card(state, card), "power")) or NRUtil.kw_eq(NRCardRT.getv(target, "agendapoints"), NRCard.get_counters(NRCard.get_card(state, card), "power"))) and NRCard.in_hand(target),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to score area"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					(func():
						var c = NRMoving.move(state, "corp", target, "scored")
						return NRInitializing.card_init(
							state,
							"corp",
							c,
							{
								"resolve-effect": false,
								"init-data": true,
							}
						)
					).call()
					NRAgendas.update_all_advancement_requirements(state)
					NRAgendas.update_all_agenda_points(state)
					return NRWinning.check_win_by_agenda(state, side),
			}
		],
		"events": [
			{
				"event": "corp-turn-begins",
				"automatic": "last",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
	}))
	NRCardDefs.defcard("Lakshmi Smartfabrics", NRUtil.merge({
		"title": "Lakshmi Smartfabrics",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"text": "Whenever you rez a card, place 1 power counter on Lakshmi Smartfabrics.\n<strong>X hosted power counters:</strong> Reveal an agenda worth X points from HQ. The Runner cannot steal copies of that agenda for the remainder of this turn."
	}, {
		"events": [
			{
				"event": "rez",
				"async": true,
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
			}
		],
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), func(_pct):
						return (NRCard.agenda(_pct) and (NRCard.get_counters(card, "power") >= NRCardRT.getv(_pct, "agendapoints"))))),
				"label": "Reveal an agenda worth X points from HQ",
				"async": true,
				"cost": [NRPayment.to_c("x-power")],
				"keep-menu-open": "while-power-tokens-left",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var paid_amt = NRPayment.cost_value(eid, "x-power")
						return NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose an agenda in HQ to reveal",
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCard.agenda(target) and (NRCardRT.getv(target, "agendapoints") <= paid_amt),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from HQ"),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRRevealing.reveal(state, side, ne, target)
								, func(async_result):
									(func():
										var title = NRCardRT.getv(target, "title")
										NRFlags.register_turn_flag(
											state,
											side,
											card,
											"can-steal",
											func(state, _side, card):
												return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "runner", "Cannot steal due to Lakshmi Smartfabrics.", "warning")) if ((NRCardRT.getv(card, "title") == title) or NRUtil.kw_eq(NRCardRT.getv(card, "title"), title)) else true)
										)
										return NREid.effect_completed(state, side, eid)
									).call()),
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Launch Campaign", NRUtil.merge({
		"title": "Launch Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "Place 6[credit] from the bank on Launch Campaign when it is rezzed. When there are no credits left on Launch Campaign, trash it.\nWhen your turn begins, take 2[credit] from Launch Campaign."
	}, _campaign(6, 2)))
	NRCardDefs.defcard("Levy University", NRUtil.merge({
		"title": "Levy University",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 3,
		"trash": 1,
		"factioncost": 0,
		"keywords": "Ritzy",
		"subtypes": ["Ritzy"],
		"text": "[click], 1[credit]: Search R&D for a piece of ice, reveal it, and add it to HQ. Shuffle R&D."
	}, {
		"abilities": [
			{
				"action": true,
				"prompt": "Choose a piece of ice",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("adds ") + str(NRCardRT.getv(target, "title")) + str(" to HQ"),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice))),
				"label": "Search R&D for a piece of ice",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 1)],
				"cancel": NRUtil.merge(NRShuffling.shuffle_deck, {"cost": [NRPayment.to_c("credit", 1), NRPayment.to_c("click", 1)], "action": true}),
				"keep-menu-open": "while-clicks-left",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRMoving.move(state, side, target, "hand")
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}
		],
	}))
	NRCardDefs.defcard("Lily Lockwell", NRUtil.merge({
		"title": "Lily Lockwell",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "When you rez Lily Lockwell, draw 3 cards.\n[click], <strong>remove 1 tag:</strong> Search R&D for an operation, reveal it, and shuffle the rest of R&D. Add the operation to the top of R&D."
	}, {
		"on-rez": NRDefHelpers.draw_ability(3),
		"abilities": [
			{
				"action": true,
				"label": "Search R&D for an operation",
				"prompt": "Choose an operation to add to the top of R&D",
				"waiting-prompt": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("tag", 1)],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str(("shuffle R&D" if ((target == "No action") or NRUtil.kw_eq(target, "No action")) else str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to the top of R&D"))),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (NRCardRT.as_array(NRCardRT.as_array(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.operation)))) + ["No action"]),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return ((func():
						NRShuffling.shuffle_zone(state, "corp", "deck")
						return NREid.effect_completed(state, side, eid)
					).call() if ((target == "No action") or NRUtil.kw_eq(target, "No action")) else NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NRShuffling.shuffle_zone(state, "corp", "deck")
						NRMoving.move(
							state,
							"corp",
							target,
							"deck",
							{
								"front": true,
							}
						)
						NREid.effect_completed(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Long-Term Investment", NRUtil.merge({
		"title": "Long-Term Investment",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 0,
		"text": "When your turn begins, place 2[credit] on Long-Term Investment. If there are at least 8[credit] on Long-Term Investment, it gains \"[click]: Take any number of credits from Long-Term Investment.\""
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"abilities": [
			{
				"action": true,
				"label": "Move any number of hosted credits to your credit pool",
				"req": func(state, side, eid, card, targets):
					return (NRCard.get_counters(card, "credit") >= 8),
				"cost": [NRPayment.to_c("click", 1)],
				"prompt": "How many hosted credits do you want to take?",
				"choices": {
					"counter": "credit",
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("gain ") + str(target) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRSay.play_sfx(state, "corp", "click-credit-3")
					return NRGaining.gain_credits(state, side, eid, target),
			}
		],
		"events": [
			{
				"event": "corp-turn-begins",
				"msg": "place 2 [Credit] on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "credit", 2),
			}
		],
	}))
	NRCardDefs.defcard("Lt. Todachine", NRUtil.merge({
		"title": "Lt. Todachine",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 3,
		"trash": 5,
		"factioncost": 0,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever you rez a piece of ice, give the Runner 1 tag."
	}, {
		"events": [
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.ice(NRCardRT.getv(context, "card")),
				"async": true,
				"msg": "give the Runner 1 tag",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "runner", eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Lt. Todachine 2", NRUtil.merge({
		"title": "Lt. Todachine 2",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 3,
		"trash": 5,
		"factioncost": 0,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Whenever you rez a piece of ice, give the Runner 1 tag.\nWhenever the Runner accesses cards, he or she accesses 1 fewer card if he or she is tagged (to a minimum of 1 card)."
	}, {
		"events": [
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.ice(NRCardRT.getv(context, "card")),
				"async": true,
				"msg": "give the Runner 1 tag",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "runner", eid, 1),
			},
			{
				"event": "breach-server",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var tagged = NRUtil.is_tagged(state)
					return NREngine.resolve_ability(state, side, eid, {
						"req": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							var tagged = NRUtil.is_tagged(state)
							return tagged and (NRCardRT.getv(num_cards_to_access(state, "runner", NRCardRT.getv(context, "server"), null), "random-access-limit") > 1) and (not NRCardRT.truthy(get_only_card_to_access(state))),
						"msg": func(state, side, eid, card, targets):
							return str("make the runner access 1 card fewer"),
						"effect": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							return NRAccess.access_bonus(state, "runner", NRCardRT.getv(context, "server"), -1),
					}, card, targets),
			}
		],
	}))
	NRCardDefs.defcard("Luana Campos", NRUtil.merge({
		"title": "Luana Campos",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Executive - Liability",
		"subtypes": ["Executive", "Liability"],
		"text": "When your turn begins, you may host 1 of your bad publicity counters on this asset. <em>(It has no effect while hosted.)</em> If you do, gain 3[credit] and draw 1 card.\n[interrupt] → When this asset would be uninstalled, take all hosted bad publicity."
	}, {
		"uninstall": func(state, side, eid, card, targets):
			var context = NRCardRT.ctx(targets)
			return NREngine.resolve_ability(state, side, eid, {
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.rezzed(NRCardRT.getv(context, "old-card")) and NRCardRT.pos(NRCard.get_counters(NRCardRT.getv(context, "old-card"), "bad-publicity")),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("take ") + str(NRCard.get_counters(NRCardRT.getv(context, "old-card"), "bad-publicity")) + str(" bad publicity"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRBadPublicity.gain_bad_publicity(state, side, eid, NRCard.get_counters(NRCardRT.getv(context, "old-card"), "bad-publicity")),
			}, card, targets),
		"events": [
			{
				"event": "corp-turn-begins",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(count_bad_pub(state)),
					"silent": true,
				},
				"optional": {
					"interactive": func(state, side, eid, card, targets):
						return true,
					"prompt": "Host a bad publicity counter to gain 3 [Credits] and draw a card?",
					"yes-ability": {
						"msg": func(state, side, eid, card, targets):
							return str("gain 3 [Credits] and draw 1 card"),
						"cost": [NRPayment.to_c("host-bad-pub", 1)],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRGaining.gain_credits(state, side, ne, 3, {
									"suppress-checkpoint": true,
								})
							, func(async_result):
								NRDrawing.draw(state, side, eid, 1)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Magistrate Revontulet", NRUtil.merge({
		"title": "Magistrate Revontulet",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "As an additional cost to steal an agenda, the Runner must pay 3[credit].\nWhenever you score an agenda, the Runner loses 3[credit]."
	}, {
		"static-abilities": [
			{
				"type": "steal-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.agenda(target),
				"value": func(state, side, eid, card, targets):
					return [NRPayment.to_c("credit", 3)],
			}
		],
		"events": [
			{
				"event": "agenda-scored",
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"msg": "force the Runner to lose 3 [Credits]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose_credits(state, "runner", eid, 3),
			}
		],
	}))
	NRCardDefs.defcard("Malia Z0L0K4", NRUtil.merge({
		"title": "Malia Z0L0K4",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "When you rez this asset, choose 1 installed non-<strong>virtual</strong> resource.\nThe chosen resource loses its printed abilities."
	}, (func():
		var unmark = func(state, side, eid, card, targets):
			(func():
				var malia_target = NRCardRT.get_in(card, ["special", "malia-target"], null)
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card), ["special", "malia-target"], null)) if malia_target != null and NRCardRT.truthy(malia_target) else null
			).call()
			NREffects.update_disabled_cards(state)
			return NREngine.trigger_event_sync(state, null, eid, "disabled-cards-updated")
		return {
			"on-rez": {
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("blank the text box of ") + str(NRToString.card_str(state, target)),
				"choices": {
					"card": func(_pct):
						return (NRCard.runner(_pct) and NRCard.installed(_pct) and NRCard.resource(_pct) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Virtual")))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card), ["special", "malia-target"], target))
					return NREffects.update_disabled_cards(state),
			},
			"leave-play": unmark,
			"move-zone": unmark,
			"static-abilities": [
				{
					"type": "icon",
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var malia_target = NRCardRT.get_in(NRCard.get_card(state, card), ["special", "malia-target"], null)
							return (NRUtil.same_card(target, malia_target) or (NRUtil.same_card(NRCardRT.getv(target, "host"), malia_target) and ((NRCardRT.getv(malia_target, "title") == "DJ Fenris") or NRUtil.kw_eq(NRCardRT.getv(malia_target, "title"), "DJ Fenris")) and ((NRCardRT.getv(target, "type") == "Fake-Identity") or NRUtil.kw_eq(NRCardRT.getv(target, "type"), "Fake-Identity"))))
						).call(),
					"value": func(state, side, eid, card, targets):
						return make_icon("MZ", card),
				},
				{
					"type": "disable-card",
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var malia_target = NRCardRT.get_in(NRCard.get_card(state, card), ["special", "malia-target"], null)
							return (NRUtil.same_card(target, malia_target) or (NRUtil.same_card(NRCardRT.getv(target, "host"), malia_target) and ((NRCardRT.getv(malia_target, "title") == "DJ Fenris") or NRUtil.kw_eq(NRCardRT.getv(malia_target, "title"), "DJ Fenris")) and ((NRCardRT.getv(target, "type") == "Fake-Identity") or NRUtil.kw_eq(NRCardRT.getv(target, "type"), "Fake-Identity"))))
						).call(),
					"value": true,
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Marilyn Campaign", NRUtil.merge({
		"title": "Marilyn Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When you rez this asset, load 8[credit] onto it. When it is empty, trash it.\nWhen your turn begins, take 2[credit] from this asset.\n[interrupt] → When this asset would be trashed, you may shuffle it into R&D instead of adding it to Archives. <em>(It is still considered trashed.)</em>"
	}, (func():
		var ability = {
			"once": "per-turn",
			"interactive": func(state, side, eid, card, targets):
				return (2 >= NRCard.get_counters(card, "credit")),
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"label": str("Gain 2 [Credits] (start of turn)"),
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(mini(2, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"async": true,
			"automatic": "gain-credits",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDefHelpers.take_credits(state, side, ne, card, "credit", 2)
				, func(async_result):
					(NRMoving.trash(
						state,
						"corp",
						eid,
						card,
						{
							"unpreventable": true,
							"cause-card": card,
						}
					) if (not NRCardRT.truthy(NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "credit")))) else NREid.effect_completed(state, "corp", eid))),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"data": {
				"counter": {
					"credit": 8,
				},
			},
			"prevention": [
				{
					"prevents": "trash",
					"type": "event",
					"label": "Shuffle Marilyn Campaign into R&D",
					"max-uses": 1,
					"ability": {
						"msg": "shuffle itself into R&D instead of moving it to Archives",
						"req": func(state, side, eid, card, targets):
							return NRCardRT.some_list(NRCardRT.map_list(state.get_in(["prevent", "trash", "remaining"], null), func(x): return NRCardRT.getv(x, "card")), func(_pct):
								return NRUtil.same_card(_pct, card)),
						"effect": func(state, side, eid, card, targets):
							return state.update_in(["prevent", "trash", "remaining"], func(v): return v),
					},
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Mark Yale", NRUtil.merge({
		"title": "Mark Yale",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Whenever you spend an agenda counter, gain 1[credit].\n[trash] or <strong>any agenda counter:</strong> Gain 2[credit]."
	}, {
		"events": [
			{
				"event": "agenda-counter-spent",
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 1),
			}
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
			{
				"label": "Gain 2 [Credits]",
				"msg": "gain 2 [Credits]",
				"cost": [NRPayment.to_c("any-agenda-counter")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			}
		],
	}))
	NRCardDefs.defcard("Marked Accounts", NRUtil.merge({
		"title": "Marked Accounts",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 5,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "When your turn begins, take 1[credit] from Marked Accounts, if able.\n[click]: Place 3[credit] from the bank on Marked Accounts."
	}, (func():
		var ability = _take_n_credits_start_of_turn(1)
		return {
			"abilities": [
				ability,
				{
					"action": true,
					"cost": [NRPayment.to_c("click", 1)],
					"msg": "store 3 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "credit", 3, null),
				}
			],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
		}
	).call()))
	NRCardDefs.defcard("MCA Austerity Policy", NRUtil.merge({
		"title": "MCA Austerity Policy",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"text": "Once per turn → [click]<strong>:</strong> Place 1 power counter on this asset. When the Runner's next turn begins, they lose [click].\n[click], [trash], <strong>3 hosted power counters:</strong> Gain [click][click][click][click]."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"once": "per-turn",
				"msg": "force the Runner to lose a [Click] next turn and place a power counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NREngine.register_events(
						state,
						side,
						card,
						[
							{
								"event": "runner-turn-begins",
								"unregister-once-resolved": true,
								"duration": "until-runner-turn-begins",
								"effect": func(state, side, eid, card, targets):
									return NRGaining.lose_clicks(state, "runner", 1),
							}
						]
					)
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			},
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 3), NRPayment.to_c("trash-can")],
				"msg": "gain 4 [Click]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_clicks(state, side, 4),
			}
		],
	}))
	NRCardDefs.defcard("Melange Mining Corp.", NRUtil.merge({
		"title": "Melange Mining Corp.",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 0,
		"text": "[click], [click], [click]: Gain 7[credit]."
	}, {
		"abilities": [
			NRUtil.merge(NRDefHelpers.gain_credits_ability(7), {
				"action": true,
				"cost": [NRPayment.to_c("click", 3)],
				"keep-menu-open": "while-3-clicks-left",
			})
		],
	}))
	NRCardDefs.defcard("Mental Health Clinic", NRUtil.merge({
		"title": "Mental Health Clinic",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "Gain 1[credit] when your turn begins.\nThe Runner's maximum hand size is increased by 1."
	}, NRUtil.merge(_creds_on_round_start(1), {"static-abilities": [NRHandSize.runner_hand_size_plus(1)]})))
	NRCardDefs.defcard("Moon Pool", NRUtil.merge({
		"title": "Moon Pool",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "<strong>Remove this asset from the game:</strong> Trash up to 2 cards from HQ. Reveal up to 2 facedown cards in Archives and shuffle them into R&D. For each agenda revealed this way, you may place 1 advancement counter on an installed card."
	}, (func():
		var moon_pool_reveal_ability = {
			"prompt": "Choose up to 2 facedown cards from Archives to shuffle into R&D",
			"async": true,
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_discard(_pct) and (not NRCardRT.truthy(NRCard.faceup(_pct)))),
				"max": 2,
			},
			"msg": func(state, side, eid, card, targets):
				return str("reveal ") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(" from Archives and shuffle ") + str(("it" if ((1 == NRCardRT.count_of(targets)) or NRUtil.kw_eq(1, NRCardRT.count_of(targets))) else "them")) + str(" into R&D"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, targets)
				, func(async_result):
					(func():
						for c in NRCardRT.as_array(targets):
							NRMoving.move(state, side, c, "deck")
						return null
					).call()
					NRShuffling.shuffle_zone(state, side, "deck")
					(func():
						var agenda_count = NRCardRT.count_of(NRCardRT.filter_list(targets, NRCard.agenda))
						return (NREngine.resolve_ability(state, side, eid, _moon_pool_place_advancements_15(agenda_count), card, null) if NRCardRT.pos(agenda_count) else NREid.effect_completed(state, side, eid))
					).call()),
			"cancel": NRShuffling.shuffle_deck,
		}
		var moon_pool_discard_ability = {
			"prompt": "Choose up to 2 cards from HQ to trash",
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
				"max": 2,
			},
			"async": true,
			"msg": {
				"public": func(state, side, eid, card, targets):
					return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ"),
				"corp": func(state, side, eid, card, targets):
					return str("trash facedown ") + str(NRCardRT.enumerate_cards(targets)) + str(" from HQ"),
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, "corp", ne, targets, {
						"cause-card": card,
					})
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, moon_pool_reveal_ability, card, null)),
			"cancel": {
				"msg": "decline to trash any cards from HQ",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, moon_pool_reveal_ability, card, null),
			},
		}
		return {
			"abilities": [
				{
					"label": "Trash up to 2 cards from HQ. Shuffle up to 2 cards from Archives into R&D",
					"cost": [NRPayment.to_c("remove-from-game")],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREngine.resolve_ability(state, side, eid, moon_pool_discard_ability, card, null),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Mr. Stone", NRUtil.merge({
		"title": "Mr. Stone",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 4,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Whenever the Runner takes 1 or more tags, do 1 meat damage."
	}, {
		"events": [
			{
				"event": "runner-gain-tag",
				"async": true,
				"msg": "do 1 meat damage",
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						"corp",
						eid,
						"meat",
						1,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Mumba Temple", NRUtil.merge({
		"title": "Mumba Temple",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Alliance - Facility",
		"subtypes": ["Alliance", "Facility"],
		"text": "This card costs 0 influence if you have 15 or fewer ice in your deck.\n2[recurring-credit]\nUse these credits to rez cards."
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (("rez" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("rez", NRCardRT.getv(eid, "source-type"))),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Mumbad City Hall", NRUtil.merge({
		"title": "Mumbad City Hall",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Facility - Government",
		"subtypes": ["Facility", "Government"],
		"text": "[click]: Search R&D for an <strong>alliance</strong> card, reveal it, and play or install it (paying all costs). Shuffle R&D."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Search R&D for an Alliance card",
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"prompt": "Choose an Alliance card to play or install",
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
						return (NRCard.has_subtype(_pct, "Alliance") and ((NRCardRT.getv(_pct, "cost") <= NRCardRT.getv(corp, "credit")) if NRCard.operation(_pct) else true))))),
				"cancel": NRUtil.merge(NRShuffling.shuffle_deck, {"action": true, "cost": [NRPayment.to_c("click", 1)]}),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and ") + str(("play" if ((NRCardRT.getv(target, "type") == "Operation") or NRUtil.kw_eq(NRCardRT.getv(target, "type"), "Operation")) else "install")) + str(" it"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NRShuffling.shuffle_zone(state, side, "deck")
						(NRPlayInstants.play_instant(state, side, eid, target, null) if NRCard.operation(target) else NRInstalling.corp_install(
							state,
							side,
							eid,
							target,
							null,
							{
								"msg-keys": {
									"install-source": card,
									"known": true,
									"display-origin": true,
								},
							}
						))),
			}
		],
	}))
	NRCardDefs.defcard("Mumbad Construction Co.", NRUtil.merge({
		"title": "Mumbad Construction Co.",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"trash": 3,
		"factioncost": 3,
		"text": "When your turn begins, place 1 advancement token on Mumbad Construction Co.\n2[credit]: Move 1 advancement token from Mumbad Construction Co. to a faceup card."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"events": [
			{
				"event": "corp-turn-begins",
				"silent": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_prop(
						state,
						side,
						eid,
						card,
						"advance-counter",
						1,
						{
							"placed": true,
						}
					),
			}
		],
		"abilities": [
			{
				"cost": [NRPayment.to_c("credit", 2)],
				"keep-menu-open": "while-advancement-tokens-left",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "advancement")) and NRCardRT.seq_of(NRBoard.all_active_installed(state, "corp")),
				"label": "Move an advancement counter to a faceup card",
				"prompt": "Choose a faceup card",
				"choices": {
					"card": NRCard.faceup,
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("move an advancement counter to ") + str(NRToString.card_str(state, target)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_prop(state, side, ne, card, "advance-counter", -1, {
							"placed": true,
						})
					, func(async_result):
						NRProps.add_prop(
							state,
							side,
							eid,
							target,
							"advance-counter",
							1,
							{
								"placed": true,
							}
						)),
			}
		],
	}))
	NRCardDefs.defcard("Museum of History", NRUtil.merge({
		"title": "Museum of History",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Alliance - Ritzy",
		"subtypes": ["Alliance", "Ritzy"],
		"text": "This asset costs 0 influence if you have 50 or more cards in your deck.\nWhen your turn begins, you may shuffle 1 card from Archives into R&D."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCardRT.count_of(state.get_in(["corp", "discard"], null))),
		},
		"abilities": [
			{
				"label": "Shuffle cards in Archives into R&D",
				"prompt": func(state, side, eid, card, targets):
					return str((func():
						var mus = NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return (((NRCardRT.getv(card, "title") == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(NRCardRT.getv(card, "title"), NRCardRT.getv(_pct, "title"))) and NRCard.rezzed(_pct))))
						return str("Choose ") + str(NRCardRT.quantify(mus, "card")) + str(" in Archives to shuffle into R&D")
					).call()),
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
					"max": func(state, side, eid, card, targets):
						return NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return (((NRCardRT.getv(card, "title") == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(NRCardRT.getv(card, "title"), NRCardRT.getv(_pct, "title"))) and NRCard.rezzed(_pct)))),
				},
				"show-discard": true,
				"once": "per-turn",
				"once-key": "museum-of-history",
				"msg": func(state, side, eid, card, targets):
					return str("shuffle ") + str((func():
						var seen = NRCardRT.filter_list(targets, func(x): return NRCardRT.getv(x, "seen"))
						var n = NRCardRT.count_of(NRCardRT.filter_list(targets, func(_pct):
							return (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen")))))
						return str(NRCardRT.enumerate_cards(seen, "sorted")) + str((str((" and " if not NRCardRT.truthy(NRCardRT.empty_of(seen)) else null)) + str(NRCardRT.quantify(n, "card")) if NRCardRT.truthy(NRCardRT.pos(n)) else null))
					).call()) + str(" into R&D"),
				"effect": func(state, side, eid, card, targets):
					(func():
						for c in NRCardRT.as_array(targets):
							NRMoving.move(state, side, c, "deck")
						return null
					).call()
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}
		],
		"implementation": "[Erratum] Should be unique",
	}))
	NRCardDefs.defcard("Nanoetching Matrix", NRUtil.merge({
		"title": "Nanoetching Matrix",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Industrial",
		"subtypes": ["Industrial"],
		"text": "Once per turn → [click]<strong>:</strong> Gain 2[credit].\nWhen the Runner trashes this asset, you may gain 2[credit]."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"once": "per-turn",
				"msg": "gain 2 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			}
		],
		"on-trash": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					return (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"waiting-prompt": true,
				"prompt": "Gain 2 [Credits]?",
				"yes-ability": {
					"msg": "gain 2 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "corp", eid, 2),
				},
			},
		},
	}))
	NRCardDefs.defcard("NASX", NRUtil.merge({
		"title": "NASX",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 2,
		"trash": 4,
		"factioncost": 0,
		"text": "Gain 1[credit] when your turn begins.\nWhenever you gain credits through a card ability other than from NASX, you may spend up to 2[credit] to place that many power counters on NASX.\n[click],[trash]: Gain 2[credit] for each power counter on NASX."
	}, (func():
		var ability = {
			"msg": "gain 1 [Credits]",
			"automatic": "gain-credits",
			"label": "Gain 1 [Credits] (start of turn)",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		}
		return {
			"implementation": "Manual - click NASX to place power counters on itself",
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [
				ability,
				{
					"label": "Place 1 power counter",
					"cost": [NRPayment.to_c("credit", 1)],
					"msg": "place 1 power counter on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 1, null),
				},
				{
					"label": "Place 2 power counters",
					"cost": [NRPayment.to_c("credit", 2)],
					"msg": "place 2 power counters on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 2, null),
				},
				{
					"action": true,
					"label": "Gain 2 [Credits] for each hosted power counter",
					"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
					"msg": func(state, side, eid, card, targets):
						return str("gain ") + str((2 * NRCard.get_counters(card, "power"))) + str(" [Credits]"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, (2 * NRCard.get_counters(card, "power"))),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Net Analytics", NRUtil.merge({
		"title": "Net Analytics",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"text": "Whenever the Runner avoids or removes 1 or more tags, you may draw 1 card."
	}, (func():
		var ability = {
			"optional": {
				"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
				"waiting-prompt": true,
				"player": "corp",
				"prompt": "Draw 1 card?",
				"yes-ability": NRDefHelpers.draw_ability(1),
			},
		}
		return {
			"events": [
				NRUtil.assoc_in(NRUtil.merge(ability, {"event": "runner-lose-tag"}), ["optional", "req"], func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return ((NRCardRT.getv(context, "side") == "runner") or NRUtil.kw_eq(NRCardRT.getv(context, "side"), "runner"))),
				NRUtil.assoc_in(NRUtil.merge(ability, {"event": "runner-prevent"}), ["optional", "req"], func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("tag" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("tag", NRCardRT.getv(context, "type"))))
			],
			"abilities": [NRCardRT.set_autoresolve("auto-fire", "Net Analytics")],
		}
	).call()))
	NRCardDefs.defcard("Net Police", NRUtil.merge({
		"title": "Net Police",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 2,
		"text": "X[recurring-credit]\nUse these credits during traces. X is the number of links the Runner has."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			return NRLink.get_link(state),
		"recurring": NRCardRT.get_x_fn(),
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (("trace" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("trace", NRCardRT.getv(eid, "source-type"))),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Neurostasis", NRUtil.merge({
		"title": "Neurostasis",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "Neurostasis can be advanced.\nIf you pay 3[credit] when the Runner accesses Neurostasis, choose 1 installed Runner card for each advancement token on Neurostasis. The Runner must shuffle the chosen cards into the stack."
	}, _advance_ambush(
		3,
		{
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"waiting-prompt": true,
			"async": true,
			"prompt": func(state, side, eid, card, targets):
				return str("Choose ") + str(NRCardRT.quantify(NRCard.get_counters(NRCard.get_card(state, card), "advancement"), "installed card")) + str(" to shuffle into the stack"),
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.runner(_pct)),
				"max": func(state, side, eid, card, targets):
					return NRCard.get_counters(NRCard.get_card(state, card), "advancement"),
			},
			"msg": func(state, side, eid, card, targets):
				return str("shuffle ") + str(NRCardRT.enumerate_cards(targets)) + str(" into the stack"),
			"effect": func(state, side, eid, card, targets):
				(func():
					for c in NRCardRT.as_array(targets):
						NRMoving.move(
					state,
					"runner",
					c,
					"deck",
					{
						"shuffled": true,
					}
				)
					return null
				).call()
				NRShuffling.shuffle_zone(state, "runner", "deck")
				return NREid.effect_completed(state, side, eid),
		}
	)))
	NRCardDefs.defcard("News Team", NRUtil.merge({
		"title": "News Team",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they must either take 2 tags or add this asset to their score area as an agenda worth -1 agenda point."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"player": "runner",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Take 2 tags", "Add News Team to score area"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRTags.gain_tags(state, "runner", eid, 2) if ((target == "Take 2 tags") or NRUtil.kw_eq(target, "Take 2 tags")) else (func():
					NRMoving.as_agenda(state, "runner", card, -1)
					return NREid.effect_completed(state, side, eid)
				).call()),
		},
	}))
	NRCardDefs.defcard("NGO Front", NRUtil.merge({
		"title": "NGO Front",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 1,
		"factioncost": 0,
		"text": "NGO Front can be advanced.\n[trash],<strong>1 hosted advancement token</strong>: Gain 5[credit].\n[trash],<strong>2 hosted advancement tokens</strong>: Gain 8[credit]."
	}, {
		"advanceable": "always",
		"abilities": [_builder_16(1, 5), _builder_16(2, 8)],
	}))
	NRCardDefs.defcard("Nico Campaign", NRUtil.merge({
		"title": "Nico Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When you rez this asset, load 9[credit] onto it. When it is empty, trash it and draw 1 card.\nWhen your turn begins, take 3[credit] from this asset."
	}, (func():
		var ability = {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"once": "per-turn",
			"automatic": "draw-cards",
			"label": "Take 3 [Credits] (start of turn)",
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(mini(3, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NREid.wait_for(state, eid, func(ne):
					NRDefHelpers.take_credits(state, side, ne, card, "credit", 3)
				, func(async_result):
					(NREid.effect_completed(state, side, eid) if NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "credit")) else NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, "corp", ne, card, {
							"unpreventable": true,
							"cause-card": card,
						})
					, func(async_result):
						NRSay.system_msg(state, "corp", str("trashes Nico Campaign") + str((" and draws 1 card" if NRCardRT.truthy(NRCardRT.seq_of(NRCardRT.getv(corp, "deck"))) else null)))
						NRDrawing.draw(state, "corp", eid, 1)))),
		}
		return {
			"data": {
				"counter": {
					"credit": 9,
				},
			},
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"abilities": [ability],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
		}
	).call()))
	NRCardDefs.defcard("Nightmare Archive", NRUtil.merge({
		"title": "Nightmare Archive",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 4,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they may add it to their score area as an agenda worth -1 agenda point. If they do not, do 1 core damage and remove this asset from the game."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(("do 1 core damage" if ((target == "Suffer 1 core damage") or NRUtil.kw_eq(target, "Suffer 1 core damage")) else str("force the runner to ") + str(NRCardRT.decapitalize(target)))),
			"player": "runner",
			"prompt": "Choose one",
			"choices": ["Suffer 1 core damage", "Add Nightmare Archive to score area"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return ((func():
					NRMoving.move(state, "corp", card, "rfg")
					return NRDamage.damage(
						state,
						"corp",
						eid,
						"brain",
						1,
						{
							"card": card,
						}
					)
				).call() if ((target == "Suffer 1 core damage") or NRUtil.kw_eq(target, "Suffer 1 core damage")) else (func():
					NRMoving.as_agenda(state, "runner", card, -1)
					return NREid.effect_completed(state, side, eid)
				).call()),
		},
	}))
	NRCardDefs.defcard("Nihilo Agent", NRUtil.merge({
		"title": "Nihilo Agent",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Enforcer - Liability",
		"subtypes": ["Enforcer", "Liability"],
		"text": "When you rez this asset, load 3 power counters onto it. When it is empty, trash it.\nWhen your turn begins, remove 1 tag and 1 bad publicity.\nWhen your discard phase ends, give the Runner 1 tag, take 1 bad publicity, and remove 1 hosted power counter."
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"events": [
			trash_on_empty("power"),
			{
				"event": "corp-turn-ends",
				"msg": "take 1 bad publicity and give the Runner 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRBadPublicity.gain_bad_publicity(state, "corp", ne, 1, {
							"suppress-checkpoint": true,
						})
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRProps.add_counter(state, side, ne, card, "power", -1, {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRTags.gain_tags(state, side, eid, 1))),
			},
			{
				"event": "corp-turn-begins",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return (tagged or NRCardRT.pos(count_bad_pub(state))),
				},
				"msg": "remove 1 bad publicity and 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRBadPublicity.lose_bad_publicity(state, "corp", ne, 1, {
							"suppress-checkpoint": true,
						})
					, func(async_result):
						NRTags.lose_tags(state, side, eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("Open Forum", NRUtil.merge({
		"title": "Open Forum",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"text": "After your mandatory draw, reveal the top card of R&D and add it to HQ. Add 1 card from HQ to the top of R&D."
	}, {
		"events": [
			{
				"event": "corp-mandatory-draw",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str((str("reveal ") + str(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "title")) + str(" from the top of R&D and add it to HQ") if NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "deck"))) else "reveal no cards from R&D (it is empty)")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0))
					, func(async_result):
						NRMoving.move(state, "corp", NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "hand")
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a card in HQ to add to the top of R&D",
							"async": true,
							"choices": {
								"card": func(_pct):
									return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
							},
							"msg": "add 1 card from HQ to the top of R&D",
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								NRMoving.move(
									state,
									side,
									target,
									"deck",
									{
										"front": true,
									}
								)
								return NREid.effect_completed(state, side, eid),
						}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Otto Campaign", NRUtil.merge({
		"title": "Otto Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When you rez this asset, load 6[credit] onto it. When it is empty, trash it and gain [click][click].\nWhen your turn begins, take 2[credit] from this asset."
	}, (func():
		var ability = {
			"once": "per-turn",
			"interactive": func(state, side, eid, card, targets):
				return (2 >= NRCard.get_counters(card, "credit")),
			"event": "corp-turn-begins",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"label": str("Gain 2 [Credits] (start of turn)"),
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(mini(2, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
			"async": true,
			"automatic": "gain-credits",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDefHelpers.take_credits(state, side, ne, card, "credit", 2)
				, func(async_result):
					(NREngine.resolve_ability(state, side, eid, {
						"msg": "trash itself and gain [click][click]",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, card, {
									"source-card": card,
								})
							, func(async_result):
								NRGaining.gain_clicks(state, side, 2)
								NREid.effect_completed(state, side, eid)),
					}, card, null) if (not NRCardRT.truthy(NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "credit")))) else NREid.effect_completed(state, side, eid))),
		}
		return {
			"data": {
				"counter": {
					"credit": 6,
				},
			},
			"events": [ability],
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("PAD Campaign", NRUtil.merge({
		"title": "PAD Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 0,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When your turn begins, gain 1[credit]."
	}, _creds_on_round_start(1)))
	NRCardDefs.defcard("PAD Factory", NRUtil.merge({
		"title": "PAD Factory",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Alliance - Facility",
		"subtypes": ["Alliance", "Facility"],
		"text": "This card costs 0 influence if you have 3 PAD Campaigns in your deck.\n[click]: Place 1 advancement token on a card. You cannot score that card until your next turn begins."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"label": "Place 1 advancement counter on a card",
				"choices": {
					"card": NRCard.installed,
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_prop(state, "corp", ne, target, "advance-counter", 1, {
							"placed": true,
						})
					, func(async_result):
						(func():
							var tgtcid = NRCardRT.getv(target, "cid")
							return NRFlags.register_turn_flag(
								state,
								side,
								target,
								"can-score",
								func(state, _, card):
									return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score due to PAD Factory.", "warning")) if (((tgtcid == NRCardRT.getv(card, "cid")) or NRUtil.kw_eq(tgtcid, NRCardRT.getv(card, "cid"))) and (NRCard.get_advancement_requirement(card) <= NRCard.get_counters(card, "advancement"))) else true)
							)
						).call()
						NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Pālanā Agroplex", NRUtil.merge({
		"title": "Pālanā Agroplex",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "When your turn begins, each player draws 1 card. "
	}, (func():
		var ability = {
			"msg": "make each player draw 1 card",
			"label": "Make each player draw 1 card (start of turn)",
			"once": "per-turn",
			"automatic": "draw-cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, "corp", ne, 1)
				, func(async_result):
					NRDrawing.draw(state, "runner", eid, 1)),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Personalized Portal", NRUtil.merge({
		"title": "Personalized Portal",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"text": "When your turn begins, the Runner draws 1 card. You may gain 1[credit] for every 2 cards in the grip."
	}, {
		"special": {
			"auto-fire": "always",
		},
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "Personalized Portal (gain credits)")],
		"events": [
			{
				"event": "corp-turn-begins",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"msg": "force the runner to draw 1 card",
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, "runner", ne, 1)
					, func(async_result):
						(func():
							var creds_to_gain = quot(NRCardRT.count_of(state.get_in(["runner", "hand"], null)), 2)
							return NREngine.resolve_ability(state, side, eid, {
								"optional": {
									"prompt": str("Gain ") + str(creds_to_gain) + str(" [Credits]?"),
									"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
									"req": func(state, side, eid, card, targets):
										return NRCardRT.pos(creds_to_gain),
									"waiting-prompt": true,
									"yes-ability": {
										"msg": str("gain ") + str(creds_to_gain) + str(" [Credits]"),
										"async": true,
										"effect": func(state, side, eid, card, targets):
											return NRGaining.gain_credits(state, side, eid, creds_to_gain),
									},
								},
							}, card, null)
						).call()),
			}
		],
	}))
	NRCardDefs.defcard("Phật Gioan Baotixita", NRUtil.merge({
		"title": "Phật Gioan Baotixita",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "When your discard phase ends, place 1 power counter on this asset.\nThe first time each turn an agenda is scored or stolen, you may remove up to 2 hosted power counters. Do 1 net damage plus 1 net damage for each power counter removed this way."
	}, (func():
		var place = {
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(
					state,
					side,
					eid,
					card,
					"power",
					1,
					{
						"placed": true,
					}
				),
		}
		var opt = func(x):
			return NRUtil.merge({
			"option": str("Do ") + str(x) + str(" net damage"),
			"ability": {
				"msg": str("do ") + str(x) + str(" net damage"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(state, "corp", eid, "net", x),
			},
		}, ({} if ((x == 1) or NRUtil.kw_eq(x, 1)) else {
			"cost": [NRPayment.to_c("power", (int(x) - 1))],
		}))
		var abi = NRCardRT.choose_one_helper(
			{
				"req": func(state, side, eid, card, targets):
					return ((NREvents.first_event(state, "corp", "agenda-scored") and NREvents.no_event(state, "runner", "agenda-stolen")) or (NREvents.first_event(state, "runner", "agenda-stolen") and NREvents.no_event(state, "corp", "agenda-scored"))),
				"player": "corp",
				"side": "corp",
				"interactive": func(state, side, eid, card, targets):
					return true,
			},
			NRCardRT.as_array(NRCardRT.map_list([1, 2, 3], func(x): return NRCardRT.truthy(opt.call(x) if opt is Callable else opt)))
		)
		return {
			"events": [
				NRUtil.merge(abi, {"event": "agenda-scored"}),
				NRUtil.merge(place, {"event": "corp-turn-ends"}),
				NRUtil.merge(abi, {"event": "agenda-stolen"})
			],
		}
	).call()))
	NRCardDefs.defcard("Plan B", NRUtil.merge({
		"title": "Plan B",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 1,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "Plan B can be advanced.\nIf the Runner accesses Plan B, you may reveal and score an agenda from HQ with an advancement requirement equal to or less than the number of advancement tokens on Plan B."
	}, _advance_ambush(
		0,
		{
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"waiting-prompt": true,
			"prompt": "Choose an Agenda in HQ to score",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.agenda(target) and (NRCard.get_advancement_requirement(target) <= NRCard.get_counters(NRCard.get_card(state, card), "advancement")) and NRCard.in_hand(target),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("score ") + str(NRCardRT.getv(target, "title")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRAgendas.score(
					state,
					side,
					eid,
					target,
					{
						"no-req": true,
						"ignore-turn": true,
					}
				),
		}
	)))
	NRCardDefs.defcard("Plutus", NRUtil.merge({
		"title": "Plutus",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Deep Net",
		"subtypes": ["Deep Net"],
		"text": "As an additional cost to rez this asset, forfeit 1 agenda or reveal and trash 3 cards from HQ.\nWhen your turn begins, you may play 1 <strong>transaction</strong> operation from Archives. After it resolves, remove it from the game."
	}, (func():
		var abi = {
			"once": "per-turn",
			"label": "Play a transaction from Archives?",
			"prompt": "Play a transaction from Archives?",
			"show-discard": true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return ((not NRCardRT.truthy(NRCardRT.getv(_pct, "seen"))) or (NRCard.operation(_pct) and NRCard.has_subtype(_pct, "Transaction") and NRPlayInstants.can_play_instant(state, side, eid, _pct, null)))),
			},
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.operation(target) and NRCard.has_subtype(target, "Transaction") and NRPlayInstants.can_play_instant(state, side, eid, target, null),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("play ") + str(NRCardRT.getv(target, "title")) + str(" from Archives"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRPlayInstants.play_instant(
					state,
					side,
					NRUtil.merge(eid, {"source": target, "source-type": "play", "source-info": {
						"ability-targets": [target],
					}}),
					NRUtil.assoc_in(NRUtil.merge(target, {"rfg-instead-of-trashing": true}), ["special", "rfg-when-trashed"], true),
					null
				),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(abi, {"event": "corp-turn-begins"})],
			"abilities": [abi],
			"additional-cost": [NRPayment.to_c("forfeit-or-trash-x-from-hand", 3)],
		}
	).call()))
	NRCardDefs.defcard("Political Dealings", NRUtil.merge({
		"title": "Political Dealings",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Seedy",
		"subtypes": ["Seedy"],
		"text": "Whenever you draw an agenda, you may reveal and install it."
	}, {
		"events": [
			{
				"event": "corp-draw",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return ((func():
						var agendas = NRCardRT.filter_list(corp_currently_drawing, func(_pct):
							return (NRCard.agenda(_pct) and NRCard.get_card(state, _pct)))
						return NREngine.resolve_ability(state, side, eid, _pdhelper_17(agendas), card, null)
					).call() if NRCardRT.truthy(NRCardRT.some_list(corp_currently_drawing, NRCard.agenda)) else NREngine.resolve_ability(state, "corp", eid, {
						"prompt": "You did not draw any agenda",
						"choices": ["Carry on!"],
						"prompt-type": "bogus",
					}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Prāna Condenser", NRUtil.merge({
		"title": "Prāna Condenser",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 4,
		"factioncost": 3,
		"text": "[interrupt] → Whenever you would do 1 or more net damage, you may prevent 1 net damage. If you do, place 1 power counter on this asset and gain 3[credit].\n[click][click], <strong>[trash]:</strong> Do 1 net damage for each hosted power counter."
	}, {
		"prevention": [
			{
				"prevents": "damage",
				"type": "event",
				"max-uses": 1,
				"ability": {
					"async": true,
					"msg": "prevent 1 net damage, place 1 counter on itself, and gain 3 [Credits]",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (("net" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("net", NRCardRT.getv(context, "type"))) and (("corp" == NRCardRT.getv(context, "source-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(context, "source-player"))) and NRPrevention.preventable(context),
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRPrevention.prevent_damage(state, side, ne, 1)
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
								NRProps.add_counter(state, side, ne, card, "power", 1, {
									"suppress-checkpoint": true,
								})
							, func(async_result):
								NRGaining.gain_credits(state, side, eid, 3))),
				},
			}
		],
		"abilities": [
			{
				"action": true,
				"msg": func(state, side, eid, card, targets):
					return str("deal ") + str(NRCard.get_counters(card, "power")) + str(" net damage"),
				"label": "deal net damage",
				"cost": [NRPayment.to_c("click", 2), NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"net",
						NRCard.get_counters(card, "power"),
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Primary Transmission Dish", NRUtil.merge({
		"title": "Primary Transmission Dish",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Beanstalk",
		"subtypes": ["Beanstalk"],
		"text": "3[recurring-credit]\nUse these credits during traces."
	}, {
		"recurring": 3,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (("trace" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("trace", NRCardRT.getv(eid, "source-type"))),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Private Contracts", NRUtil.merge({
		"title": "Private Contracts",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"trash": 5,
		"factioncost": 0,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Place 14[credit] from the bank on Private Contracts when it is rezzed. When there are no credits left on Private Contracts, trash it.\n[click]: Take 2[credit] from Private Contracts."
	}, {
		"data": {
			"counter": {
				"credit": 14,
			},
		},
		"events": [trash_on_empty("credit")],
		"abilities": [
			take_n_credits_ability(
				2,
				"asset",
				{
					"action": true,
					"keep-menu-open": "while-clicks-left",
					"cost": [NRPayment.to_c("click", 1)],
				}
			)
		],
	}))
	NRCardDefs.defcard("Project Junebug", NRUtil.merge({
		"title": "Project Junebug",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 1,
		"keywords": "Ambush - Research",
		"subtypes": ["Ambush", "Research"],
		"text": "Project Junebug can be advanced.\nIf you pay 1[credit] when the Runner accesses Project Junebug, do 2 net damage for each advancement token on Project Junebug."
	}, _advance_ambush(
		1,
		{
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str((2 * NRCard.get_counters(NRCard.get_card(state, card), "advancement"))) + str(" net damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					(2 * NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
					{
						"card": card,
					}
				),
		}
	)))
	NRCardDefs.defcard("Psychic Field", NRUtil.merge({
		"title": "Psychic Field",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Ambush - Psi",
		"subtypes": ["Ambush", "Psi"],
		"text": "If the Runner exposes or accesses Psychic Field while installed, you and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, do 1 net damage for each card in the Runner's grip."
	}, (func():
		var ab = {
			"async": true,
			"req": func(state, side, eid, card, targets):
				var installed = NRCard.installed(card) if card is Dictionary else false
				return installed,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return (func():
					var hand = NRCardRT.count_of(NRCardRT.getv(runner, "hand"))
					var message = str("do ") + str(hand) + str(" net damage")
					return NREngine.resolve_ability(state, side, eid, {
						"psi": {
							"not-equal": {
								"msg": message,
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRDamage.damage(
										state,
										side,
										eid,
										"net",
										hand,
										{
											"card": card,
										}
									),
							},
						},
					}, card, null)
				).call(),
		}
		return {
			"on-expose": ab,
			"on-access": ab,
		}
	).call()))
	NRCardDefs.defcard("Public Access Plaza", NRUtil.merge({
		"title": "Public Access Plaza",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 1,
		"text": "When your turn begins, gain 1[credit].\nThreat 2 → When the Runner trashes this asset <em>(while it is rezzed)</em>, give them 1 tag."
	}, NRUtil.merge(_creds_on_round_start(1), {"on-trash": NRUtil.merge(NRDefHelpers.give_tags(1), {"req": func(state, side, eid, card, targets):
		return ((("runner" == side) or NRUtil.kw_eq("runner", side)) and NRThreat.threat(state, int(2)))})})))
	NRCardDefs.defcard("Public Health Portal", NRUtil.merge({
		"title": "Public Health Portal",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "When your turn begins, reveal the top card of R&D and gain 2[credit]."
	}, (func():
		var ability = {
			"once": "per-turn",
			"label": "Reveal the top card of R&D and gain 2 [Credits] (start of turn)",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"automatic": "gain-credits",
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str("reveal ") + str(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "title")) + str(" from the top of R&D") + str(" and gain 2 [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0))
				, func(async_result):
					NRGaining.gain_credits(state, side, eid, 2)),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Public Support", NRUtil.merge({
		"title": "Public Support",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 3,
		"text": "Place 3 power counters on Public Support when it is rezzed. When there are no power counters left on Public Support, add it to your score area as an agenda worth 1 agenda point.\nWhen your turn begins, remove 1 power counter from Public Support."
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"events": [
			{
				"event": "corp-turn-begins",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "power")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", -1, null),
			},
			{
				"event": "counter-added",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "card")) and (not NRCardRT.truthy(NRCardRT.pos(NRCard.get_counters(card, "power")))),
				"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, side, card, 1),
			}
		],
	}))
	NRCardDefs.defcard("Quarantine System", NRUtil.merge({
		"title": "Quarantine System",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 4,
		"text": "<strong>Forfeit an agenda</strong>: Rez up to 3 pieces of ice, lowering the cost of each by 2[credit] for each printed agenda point on the forfeited agenda."
	}, {
		"abilities": [
			{
				"label": "Forfeit agenda to rez up to 3 pieces of ice with a 2 [Credit] discount per agenda point",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "scored"))),
				"cost": [NRPayment.to_c("forfeit")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, _rez_ice_18(1, (2 * NRCardRT.getv((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCardRT.getv(corp, "rfg"))), "agendapoints", 0))), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Raman Rai", NRUtil.merge({
		"title": "Raman Rai",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Alliance - Executive",
		"subtypes": ["Alliance", "Executive"],
		"text": "This asset costs 0 influence if you have 6 or more non-<strong>alliance</strong> [jinteki] cards in your deck.\nOnce per turn → When you draw a card, you may lose [click]. If you do, reveal that card and 1 card in Archives of the same type. Swap those cards."
	}, {
		"events": [
			{
				"event": "corp-draw",
				"optional": {
					"prompt": "Swap two cards?",
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.pos(NRCardRT.getv(corp, "click")) and NRCardRT.seq_of(set_intersection(NRCardRT.concat_lists([[], NRCardRT.map_list(NRCardRT.getv(corp, "discard"), func(x): return NRCardRT.getv(x, "type"))]), NRCardRT.concat_lists([[], NRCardRT.map_list(corp_currently_drawing, func(x): return NRCardRT.getv(x, "type"))]))) and NRCardRT.seq_of(NREvents.turn_events(state, side, "corp-draw")),
					"yes-ability": {
						"once": "per-turn",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							NRGaining.lose_clicks(state, "corp", 1)
							return NREngine.resolve_ability(state, side, eid, {
								"prompt": "Choose a card in HQ that you just drew to swap for a card of the same type in Archives",
								"choices": {
									"card": func(_pct):
										return NRCardRT.some_list(corp_currently_drawing, func(c):
											return NRUtil.same_card(c, _pct)),
								},
								"async": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NREngine.resolve_ability(state, side, eid, (func():
										var set_aside_card = target
										var t = NRCardRT.getv(set_aside_card, "type")
										return {
											"show-discard": true,
											"prompt": func(state, side, eid, card, targets):
												return str("Choose an ") + str(t) + str(" in Archives to reveal and swap into HQ for ") + str(NRCardRT.getv(set_aside_card, "title")),
											"choices": {
												"card": func(_pct):
													return (NRCard.corp(_pct) and ((NRCardRT.getv(_pct, "type") == t) or NRUtil.kw_eq(NRCardRT.getv(_pct, "type"), t)) and NRCard.in_discard(_pct)),
											},
											"msg": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return str("lose [Click], reveal ") + str(NRCardRT.getv(set_aside_card, "title")) + str(" from HQ, and swap it for ") + str(NRCardRT.getv(target, "title")) + str(" from Archives"),
											"async": true,
											"effect": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return NREid.wait_for(state, eid, func(ne):
													NRRevealing.reveal(state, side, ne, set_aside_card, target)
												, func(async_result):
													swap_set_aside_cards(state, side, set_aside_card, target)
													NREid.effect_completed(state, side, eid)),
										}
									).call(), card, null),
							}, card, null),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Rashida Jaheem", NRUtil.merge({
		"title": "Rashida Jaheem",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 0,
		"trash": 1,
		"factioncost": 0,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "When your turn begins, you may trash Rashida Jaheem to gain 3[credit] and draw 3 cards."
	}, (func():
		var ability = {
			"once": "per-turn",
			"skippable": true,
			"async": true,
			"label": "Gain 3 [Credits] and draw 3 cards (start of turn)",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": "Trash this asset to gain 3 [Credits] and draw 3 cards?",
						"yes-ability": {
							"async": true,
							"msg": "gain 3 [Credits] and draw 3 cards",
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, card, {
										"cause-card": card,
									})
								, func(async_result):
									state.update_in(["stats", side, "rashida-count"], func(v): return v)
									NREid.wait_for(state, eid, func(ne):
										NRGaining.gain_credits(state, side, ne, 3)
									, func(async_result):
										NRDrawing.draw(state, side, eid, 3))),
						},
					},
				}, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Reality Threedee", NRUtil.merge({
		"title": "Reality Threedee",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 6,
		"factioncost": 2,
		"keywords": "Liability",
		"subtypes": ["Liability"],
		"text": "When you rez this asset, take 1 bad publicity.\nWhen your turn begins, if the Runner is tagged, gain 2[credit]. Otherwise, gain 1[credit]."
	}, (func():
		var ability = {
			"effect": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return NRGaining.gain_credits(state, side, eid, (2 if tagged else 1)),
			"async": true,
			"label": "Gain credits (start of turn)",
			"automatic": "gain-credits",
			"once": "per-turn",
			"msg": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return str(("gain 2 [Credits]" if tagged else "gain 1 [Credits]")),
		}
		return {
			"on-rez": {
				"msg": "take 1 bad publicity",
				"effect": func(state, side, eid, card, targets):
					return NRBadPublicity.gain_bad_publicity(state, "corp", 1),
			},
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Reaper Function", NRUtil.merge({
		"title": "Reaper Function",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "When your turn begins, you may trash this asset to do 2 net damage."
	}, (func():
		var ability = {
			"async": true,
			"once": "per-turn",
			"label": "Trash this asset to do 2 net damage (start of turn)",
			"automatic": "corp-damage",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": "Trash Reaper Function to do 2 net damage?",
						"yes-ability": {
							"msg": "do 2 net damage",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, card, {
										"cause-card": card,
									})
								, func(async_result):
									NRDamage.damage(
										state,
										side,
										eid,
										"net",
										2,
										{
											"card": card,
										}
									)),
						},
					},
				}, card, null),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Reconstruction Contract", NRUtil.merge({
		"title": "Reconstruction Contract",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 4,
		"factioncost": 4,
		"text": "Whenever the Runner suffers any amount of meat damage, you may place 1 advancement token on Reconstruction Contract.\n[trash]: Move any number of advancement tokens from Reconstruction Contract to a card that can be advanced."
	}, {
		"events": [
			{
				"event": "damage",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCardRT.pos(NRCardRT.getv(context, "amount")) and (("meat" == NRCardRT.getv(context, "damage-type")) or NRUtil.kw_eq("meat", NRCardRT.getv(context, "damage-type"))),
				"msg": "place 1 advancement counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(
						state,
						side,
						eid,
						card,
						"advancement",
						1,
						{
							"placed": true,
						}
					),
			}
		],
		"abilities": [
			{
				"label": "Move hosted advancement counters to another card",
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"prompt": "How many hosted advancement counters do you want to move?",
				"choices": {
					"number": func(state, side, eid, card, targets):
						return NRCard.get_counters(card, "advancement"),
					"default": func(state, side, eid, card, targets):
						return NRCard.get_counters(card, "advancement"),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var num_counters = target
						return NREngine.resolve_ability(state, side, eid, {
							"async": true,
							"prompt": "Choose a card that can be advanced",
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCard.can_be_advanced(state, target),
							},
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to move ") + str(NRCardRT.quantify(num_counters, "hosted advancement counter")) + str(" to ") + str(NRToString.card_str(state, target)))
								return NRProps.add_counter(
									state,
									side,
									eid,
									target,
									"advancement",
									num_counters,
									{
										"placed": true,
									}
								),
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Refuge Campaign", NRUtil.merge({
		"title": "Refuge Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When your turn begins, gain 2[credit]."
	}, _creds_on_round_start(2)))
	NRCardDefs.defcard("Regolith Mining License", NRUtil.merge({
		"title": "Regolith Mining License",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 0,
		"text": "When you rez this asset, load 15[credit] onto it. When it is empty, trash it.\n[click]<strong>:</strong> Take 3[credit] from this asset."
	}, {
		"data": {
			"counter": {
				"credit": 15,
			},
		},
		"events": [trash_on_empty("credit")],
		"abilities": [
			take_n_credits_ability(
				3,
				"asset",
				{
					"action": true,
					"keep-menu-open": "while-clicks-left",
					"cost": [NRPayment.to_c("click", 1)],
				}
			)
		],
	}))
	NRCardDefs.defcard("Reversed Accounts", NRUtil.merge({
		"title": "Reversed Accounts",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "You can advance this asset.\n[click], [trash]<strong>:</strong> The Runner loses 4[credit] for each hosted advancement counter."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
				"label": "Force the Runner to lose 4 [Credits] per advancement",
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str("force the Runner to lose ") + str(mini((4 * NRCard.get_counters(card, "advancement")), NRCardRT.getv(runner, "credit"))) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose_credits(state, "runner", eid, (4 * NRCard.get_counters(card, "advancement"))),
			}
		],
	}))
	NRCardDefs.defcard("Rex Campaign", NRUtil.merge({
		"title": "Rex Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When you rez this asset, load 3 power counters onto it. When it is empty, trash it and either remove 1 bad publicity or gain 5[credit].\nWhen your turn begins, remove 1 hosted power counter."
	}, (func():
		var payout_ab = {
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Remove 1 bad publicity", "Gain 5 [Credits]"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(NRCardRT.decapitalize(target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRBadPublicity.lose_bad_publicity(state, side, eid, 1) if ((target == "Remove 1 bad publicity") or NRUtil.kw_eq(target, "Remove 1 bad publicity")) else NRGaining.gain_credits(state, side, eid, 5)),
		}
		var ability = {
			"once": "per-turn",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12"),
			"label": "Remove 1 counter (start of turn)",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRProps.add_counter(state, side, ne, card, "power", -1, null)
				, func(async_result):
					(NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, card, {
							"cause-card": card,
						})
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, payout_ab, card, null)) if NRCardRT.zero(NRCard.get_counters(NRCard.get_card(state, card), "power")) else NREid.effect_completed(state, side, eid))),
		}
		return {
			"data": {
				"counter": {
					"power": 3,
				},
			},
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"ability": [ability],
		}
	).call()))
	NRCardDefs.defcard("Ronald Five", NRUtil.merge({
		"title": "Ronald Five",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "Whenever the Runner trashes a Corp card <em>(including this asset)</em>, they lose [click]."
	}, (func():
		var ability = {
			"event": "runner-trash",
			"once-per-instance": false,
			"req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return NRCard.corp(NRCardRT.getv(target, "card")) and NRCardRT.pos(NRCardRT.getv(runner, "click")),
			"msg": "force the runner to lose [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_clicks(state, "runner", 1),
		}
		return {
			"events": [ability],
			"on-trash": ability,
		}
	).call()))
	NRCardDefs.defcard("Ronin", NRUtil.merge({
		"title": "Ronin",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 4,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "You can advance this asset.\n[click], [trash]<strong>:</strong> Do 3 net damage. Use this ability only if there are 4 or more hosted advancement counters."
	}, {
		"advanceable": "always",
		"abilities": [
			NRUtil.merge(NRDefHelpers.do_net_damage(3), {"action": true, "cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")], "req": func(state, side, eid, card, targets):
				return (NRCard.get_counters(card, "advancement") >= 4)})
		],
	}))
	NRCardDefs.defcard("Roughneck Repair Squad", NRUtil.merge({
		"title": "Roughneck Repair Squad",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Industrial",
		"subtypes": ["Industrial"],
		"text": "[click][click][click]<strong>:</strong> Gain 6[credit]. You may remove 1 bad publicity."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Gain 6 [Credits], may remove 1 bad publicity",
				"cost": [NRPayment.to_c("click", 3)],
				"keep-menu-open": "while-3-clicks-left",
				"msg": "gain 6 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, 6)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"req": func(state, side, eid, card, targets):
									return NRCardRT.pos(count_bad_pub(state)),
								"prompt": "Remove 1 bad publicity?",
								"yes-ability": {
									"msg": "remove 1 bad publicity",
									"effect": func(state, side, eid, card, targets):
										return NRBadPublicity.lose_bad_publicity(state, side, 1),
								},
							},
						}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Sandburg", NRUtil.merge({
		"title": "Sandburg",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 0,
		"trash": 4,
		"factioncost": 0,
		"text": "If you have at least 10[credit], each piece of ice has +1 strength for every 5[credit] in your credit pool."
	}, {
		"on-rez": {
			"effect": func(state, side, eid, card, targets):
				return NRIce.update_all_ice(state, side),
		},
		"static-abilities": [
			{
				"type": "ice-strength",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (10 <= NRCardRT.getv(corp, "credit")),
				"value": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return quot(NRCardRT.getv(corp, "credit"), 5),
			}
		],
		"events": [
			{
				"event": "corp-gain",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("credit" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("credit", NRCardRT.getv(context, "type"))),
				"effect": func(state, side, eid, card, targets):
					return NRIce.update_all_ice(state, side),
			},
			{
				"event": "corp-lose",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("credit" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("credit", NRCardRT.getv(context, "type"))),
				"effect": func(state, side, eid, card, targets):
					return NRIce.update_all_ice(state, side),
			}
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRIce.update_all_ice(state, side),
	}))
	NRCardDefs.defcard("Sealed Vault", NRUtil.merge({
		"title": "Sealed Vault",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 8,
		"factioncost": 1,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "<strong>1[credit]:</strong> Move any number of credits from your credit pool to this asset.\n<strong>[click]:</strong> Take any number of credits from this asset.\n<strong>[trash]:</strong> Take any number of credits from this asset."
	}, {
		"abilities": [
			{
				"label": "Store any number of credits",
				"cost": [NRPayment.to_c("credit", 1)],
				"prompt": "How many credits do you want to move?",
				"choices": {
					"number": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (NRCardRT.getv(corp, "credit") - 1),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("store ") + str(target) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "credit", target)
					, func(async_result):
						NRGaining.lose_credits(state, side, eid, target)),
			},
			{
				"action": true,
				"label": "Move any number of credits to your credit pool",
				"cost": [NRPayment.to_c("click", 1)],
				"prompt": "How many credits do you want to move?",
				"choices": {
					"counter": "credit",
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("gain ") + str(target) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRGaining.gain_credits(state, side, eid, target),
			},
			{
				"label": "Move any number of credits to your credit pool",
				"prompt": "How many credits do you want to move?",
				"choices": {
					"counter": "credit",
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("gain ") + str(target) + str(" [Credits]"),
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRGaining.gain_credits(state, side, eid, target),
			}
		],
	}))
	NRCardDefs.defcard("Security Subcontract", NRUtil.merge({
		"title": "Security Subcontract",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "[click], <strong>trash a rezzed piece of ice:</strong> Gain 4[credit]."
	}, {
		"abilities": [
			NRUtil.merge(NRDefHelpers.gain_credits_ability(4), {
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("ice", 1)],
				"keep-menu-open": "while-clicks-left",
			})
		],
	}))
	NRCardDefs.defcard("Sensie Actors Union", NRUtil.merge({
		"title": "Sensie Actors Union",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political",
		"subtypes": ["Political"],
		"text": "When your turn begins, you may draw 3 cards if there is no ice protecting this server. If you do, add 1 card from HQ to the bottom of R&D."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
				return unprotected,
		},
		"abilities": [
			{
				"label": "Draw 3 cards and add 1 card in HQ to the bottom of R&D",
				"once": "per-turn",
				"msg": "draw 3 cards",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, side, ne, 3)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a card in HQ to add to the bottom of R&D",
							"choices": {
								"card": func(_pct):
									return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
							},
							"msg": "add 1 card from HQ to the bottom of R&D",
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRMoving.move(state, side, target, "deck"),
						}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Server Diagnostics", NRUtil.merge({
		"title": "Server Diagnostics",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"trash": 2,
		"factioncost": 0,
		"text": "Gain 2[credit] when your turn begins.\nTrash Server Diagnostics when you install a piece of ice."
	}, (func():
		var ability = {
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
			"async": true,
			"once": "per-turn",
			"automatic": "gain-credits",
			"label": "Gain 2 [Credits] (start of turn)",
			"msg": "gain 2 [Credits]",
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability, {"event": "corp-turn-begins"}),
				{
					"event": "corp-install",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRCard.ice(NRCardRT.getv(context, "card")),
					"async": true,
					"msg": "trash itself",
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(
							state,
							side,
							eid,
							card,
							{
								"cause-card": card,
							}
						),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Shannon Claire", NRUtil.merge({
		"title": "Shannon Claire",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "[click]: Draw 1 card from the bottom of R&D.\n[trash]: Search R&D or Archives for an agenda and reveal it. Shuffle the rest of R&D if you searched it. Add the agenda to the bottom of R&D."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"msg": "draw 1 card from the bottom of R&D",
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					NRSay.play_sfx(state, side, "click-card")
					return NRMoving.move(state, side, (func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCardRT.getv(corp, "deck"))), "hand"),
			},
			{
				"label": "Search R&D for an agenda",
				"prompt": "Choose an agenda to add to the bottom of R&D",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to the bottom of R&D"),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.agenda))),
				"cost": [NRPayment.to_c("trash-can")],
				"cancel": NRUtil.merge(NRShuffling.shuffle_deck, {"cost": [NRPayment.to_c("trash-can")]}),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NRShuffling.shuffle_zone(state, side, "deck")
						NRMoving.move(state, side, target, "deck")
						NREid.effect_completed(state, side, eid)),
			},
			{
				"label": "Search Archives for an agenda",
				"prompt": "Choose an agenda to add to the bottom of R&D",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from Archives and add it to the bottom of R&D"),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), NRCard.agenda))),
				"cancel": {
					"msg": "do nothing",
					"cost": [NRPayment.to_c("trash-can")],
				},
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NRMoving.move(state, side, target, "deck")
						NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Shattered Remains", NRUtil.merge({
		"title": "Shattered Remains",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "Shattered Remains can be advanced.\nIf you pay 1[credit] when the Runner accesses Shattered Remains, trash 1 piece of hardware for each advancement token on Shattered Remains."
	}, _advance_ambush(
		1,
		{
			"async": true,
			"waiting-prompt": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
			},
			"prompt": func(state, side, eid, card, targets):
				return str("Choose ") + str(NRCardRT.quantify(NRCard.get_counters(NRCard.get_card(state, card), "advancement"), "piece")) + str(" of hardware to trash"),
			"msg": func(state, side, eid, card, targets):
				return str("trash ") + str(NRCardRT.enumerate_cards(targets)),
			"choices": {
				"max": func(state, side, eid, card, targets):
					return NRCard.get_counters(NRCard.get_card(state, card), "advancement"),
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.hardware(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(
					state,
					side,
					eid,
					targets,
					{
						"cause-card": card,
					}
				),
		}
	)))
	NRCardDefs.defcard("Shi.Kyū", NRUtil.merge({
		"title": "Shi.Kyū",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 4,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "When the Runner accesses this asset anywhere except in R&D, spend any number of credits. The Runner suffers 1 net damage for each credit spent this way unless they add this asset to their score area as an agenda worth −1 agenda point."
	}, {
		"poison": true,
		"on-access": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_deck(card))),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("Pay credits to use ") + str(NRCardRT.getv(card, "title")) + str(" ability?"),
				"yes-ability": {
					"prompt": "How many credits do you want to pay?",
					"choices": "credit",
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("attempt to do ") + str(target) + str(" net damage"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, (func():
							var dmg = target
							return {
								"player": "runner",
								"prompt": "Choose one",
								"waiting-prompt": true,
								"choices": [str("Take ") + str(dmg) + str(" net damage"), "Add Shi.Kyū to score area"],
								"async": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return ((func():
										NRSay.system_msg(state, "runner", str("adds ") + str(NRCardRT.getv(card, "title")) + str(" to [their] score area as an agenda worth ") + str(NRCardRT.quantify(-1, "agenda point")))
										NRMoving.as_agenda(state, "runner", card, -1)
										return NREid.effect_completed(state, side, eid)
									).call() if str_starts_with(target, "Add") else (func():
										NRSay.system_msg(state, "runner", str("takes ") + str(dmg) + str(" net damage from ") + str(NRCardRT.getv(card, "title")))
										return NRDamage.damage(
											state,
											"corp",
											eid,
											"net",
											dmg,
											{
												"card": card,
											}
										)
									).call()),
							}
						).call(), card, targets),
				},
			},
		},
	}))
	NRCardDefs.defcard("Shock!", NRUtil.merge({
		"title": "Shock!",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, do 1 net damage."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"msg": "do 1 net damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					1,
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("SIU", NRUtil.merge({
		"title": "SIU",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 3,
		"trash": 1,
		"factioncost": 3,
		"text": "When your turn begins, you may trash SIU to Trace[3]. If successful, give the Runner 1 tag."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			{
				"label": "Trace 3 - Give the Runner 1 tag",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(state.data, "corp-phase-12"),
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, {
						"trace": {
							"base": 3,
							"label": "Trace 3 - Give the Runner 1 tag",
							"successful": NRDefHelpers.give_tags(1),
						},
					}, card, null),
			}
		],
	}))
	NRCardDefs.defcard("Snare!", NRUtil.merge({
		"title": "Snare!",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset anywhere except in Archives, you may pay 4[credit]. If you do, give the Runner 1 tag and do 3 net damage."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_discard(card))) and NRPayment.can_pay(state, "corp", eid, card, null, [NRPayment.to_c("credit", 4)]),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("Pay 4 [Credits] to use ") + str(NRCardRT.getv(card, "title")) + str(" ability?"),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("credit", 4)],
					"msg": "give the Runner 1 tag and do 3 net damage",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRTags.gain_tags(state, "corp", ne, 1, {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRDamage.damage(
								state,
								side,
								eid,
								"net",
								3,
								{
									"card": card,
								}
							)),
				},
			},
		},
	}))
	NRCardDefs.defcard("Space Camp", NRUtil.merge({
		"title": "Space Camp",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, you may place 1 advancement counter on an installed card you can advance."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"optional": {
				"waiting-prompt": true,
				"prompt": "Place 1 advancement counter on a card that can be advanced?",
				"yes-ability": {
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
					"prompt": "Choose a card to place an advancement counter on",
					"choices": {
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRCard.can_be_advanced(state, target),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRProps.add_prop(
							state,
							side,
							eid,
							target,
							"advance-counter",
							1,
							{
								"placed": true,
							}
						),
				},
			},
		},
	}))
	NRCardDefs.defcard("Spin Doctor", NRUtil.merge({
		"title": "Spin Doctor",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "When you rez this asset, draw 2 cards.\n<strong>Remove this asset from the game:</strong> Shuffle up to 2 cards from Archives into R&D."
	}, {
		"on-rez": {
			"async": true,
			"msg": "draw 2 cards",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 2),
		},
		"abilities": [
			{
				"label": "Shuffle up to 2 cards from Archives into R&D",
				"cost": [NRPayment.to_c("remove-from-game")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return shuffle_into_rd_effect(state, side, eid, card, 2),
			}
		],
	}))
	NRCardDefs.defcard("Storgotic Resonator", NRUtil.merge({
		"title": "Storgotic Resonator",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "The first time each turn you trash a card that matches the faction of the Runnerʼs identity <em>(from any location)</em>, place 1 power counter on this asset.\n[click], <strong>hosted power counter:</strong> Do 1 net damage. "
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
				"keep-menu-open": "while-power-tokens-left",
				"label": "Do 1 net damage",
				"msg": "do 1 net damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"net",
						1,
						{
							"card": card,
						}
					),
			}
		],
		"events": [
			{
				"event": "corp-trash",
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.some_list(targets, func(_pct):
						return ((NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction") == NRCardRT.getv(NRCardRT.getv(_pct, "card"), "faction")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction"), NRCardRT.getv(NRCardRT.getv(_pct, "card"), "faction")))) and NREvents.first_event(
						state,
						side,
						"corp-trash",
						func(targets):
							return NRCardRT.some_list(targets, func(_pct):
								return ((NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction") == NRCardRT.getv(NRCardRT.getv(_pct, "card"), "faction")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction"), NRCardRT.getv(NRCardRT.getv(_pct, "card"), "faction"))))
					),
				"msg": "place 1 power counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
	}))
	NRCardDefs.defcard("Student Loans", NRUtil.merge({
		"title": "Student Loans",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"text": "As an additional cost to play an event, if there is a copy of that event in the heap, the Runner must pay 2[credit]."
	}, {
		"static-abilities": [
			{
				"type": "play-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return NRCard.event(target) and NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(runner, "discard"), func(_pct):
						return ((NRCardRT.getv(_pct, "title") == NRCardRT.getv(target, "title")) or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), NRCardRT.getv(target, "title"))))),
				"value": [NRPayment.to_c("credit", 2)],
			}
		],
	}))
	NRCardDefs.defcard("Superdeep Borehole", NRUtil.merge({
		"title": "Superdeep Borehole",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"trash": 6,
		"factioncost": 5,
		"keywords": "Industrial - Liability",
		"subtypes": ["Industrial", "Liability"],
		"text": "When you rez this asset, load 6 bad publicity counters onto it. When it is empty, you win the game.\nWhen your turn begins, take 1 bad publicity from this asset."
	}, {
		"on-rez": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card), ["special", "borehole-valid"], true))
				return NRProps.add_counter(state, side, eid, card, "bad-publicity", 6, null),
		},
		"events": [
			{
				"event": "corp-turn-begins",
				"msg": func(state, side, eid, card, targets):
					return str("take 1 bad publicity from ") + str(NRCardRT.getv(card, "title")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "bad-publicity", -1, null)
					, func(async_result):
						NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
			},
			{
				"event": "counter-added",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "card")) and (not NRCardRT.truthy(NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "bad-publicity")))) and NRCardRT.getv(NRCardRT.getv(card, "special"), "borehole-valid"),
				"msg": "win the game",
				"effect": func(state, side, eid, card, targets):
					return NRWinning.win(state, "corp", NRCardRT.getv(card, "title")),
			}
		],
	}))
	NRCardDefs.defcard("Synchrocyclotron", NRUtil.merge({
		"title": "Synchrocyclotron",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "The first <strong>double</strong> operation you play each turn costs [click] less to play."
	}, {
		"static-abilities": [
			{
				"type": "play-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.corp(target) and NREvents.no_event(
						state,
						side,
						"play-operation",
						func(_pct):
							return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "Double")
					) and NRCard.has_subtype(target, "Double"),
				"value": [NRPayment.to_c("click", -1)],
			}
		],
	}))
	NRCardDefs.defcard("Sundew", NRUtil.merge({
		"title": "Sundew",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 3,
		"text": "The first time the Runner spends 1 or more [click] during their turn, gain 2[credit]. If those [click] were spent to take an action, the first time during that action a run on this server begins, pay 2[credit]."
	}, {
		"events": [
			{
				"event": "runner-spent-click",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "runner-spent-click"),
				"msg": "gain 2 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRUpdate.update_card(state, side, NRUtil.assoc_in(card, ["special", "spent-click"], true))
					return NRGaining.gain_credits(state, "corp", eid, 2),
			},
			{
				"event": "run",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return NREvents.first_event(state, side, "runner-spent-click") and run and this_server and NRCardRT.get_in(card, ["special", "spent-click"], null),
				"msg": "lose 2 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRUpdate.update_card(state, side, card)
					return NRGaining.lose_credits(state, "corp", eid, 2),
			}
		],
	}))
	NRCardDefs.defcard("Svyatogor Excavator", NRUtil.merge({
		"title": "Svyatogor Excavator",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 1,
		"keywords": "Industrial",
		"subtypes": ["Industrial"],
		"text": "When your turn begins, you may trash 1 of your other installed cards. If you do, gain 3[credit]."
	}, (func():
		var ability = {
			"async": true,
			"label": "trash a card to gain 3 [Credits]",
			"once": "per-turn",
			"req": func(state, side, eid, card, targets):
				return (NRCardRT.count_of(NRBoard.all_installed(state, "corp")) >= 2),
			"choices": {
				"not-self": true,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.corp(target) and NRCard.installed(target),
			},
			"msg": {
				"public": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRToString.card_str(state, target)) + str(" and gain 3 [Credits]"),
				"corp": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRToString.card_str(
						state,
						target,
						{
							"maybe-visible": true,
						}
					)) + str(" and gain 3 [Credits]"),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, target, {
						"unpreventable": true,
						"cause-card": card,
					})
				, func(async_result):
					NRGaining.gain_credits(state, side, eid, 3)),
		}
		return {
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return (NRCardRT.count_of(NRBoard.all_installed(state, "corp")) >= 2),
			},
			"events": [
				NRUtil.merge(ability, {"event": "corp-turn-begins", "interactive": func(state, side, eid, card, targets):
					return true})
			],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Synth DNA Modification", NRUtil.merge({
		"title": "Synth DNA Modification",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 1,
		"text": "The first time a subroutine on a piece of <strong>AP</strong> ice is broken each turn, do 1 net damage."
	}, {
		"events": [
			{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.has_subtype(NRCardRT.getv(context, "ice"), "AP") and NREvents.first_event(
						state,
						side,
						"subroutines-broken",
						func(_pct):
							return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "ice"), "AP")
					),
				"msg": "do 1 net damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"net",
						1,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Team Sponsorship", NRUtil.merge({
		"title": "Team Sponsorship",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 4,
		"factioncost": 1,
		"text": "Whenever you score an agenda, you may install a card from Archives or HQ, ignoring the install cost."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"prompt": "Choose a card from Archives or HQ to install",
				"show-discard": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"choices": {
					"card": func(_pct):
						return ((not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						null,
						{
							"ignore-install-cost": true,
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Tech Startup", NRUtil.merge({
		"title": "Tech Startup",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 1,
		"factioncost": 0,
		"text": "When your turn begins, you may trash Tech Startup. If you do, search R&D for an asset, reveal it, and install it. Shuffle R&D."
	}, {
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"flags": {
			"corp-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			{
				"label": "Search R&D for an asset to install",
				"prompt": "Choose an asset",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and install it"),
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.asset)),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.asset),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, card, {
							"cause-card": card,
						})
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, target)
						, func(async_result):
							NRShuffling.shuffle_zone(state, side, "deck")
							NRInstalling.corp_install(
								state,
								side,
								eid,
								target,
								null,
								{
									"msg-keys": {
										"install-source": card,
										"known": true,
										"display-origin": true,
									},
								}
							))),
			}
		],
	}))
	NRCardDefs.defcard("TechnoCo", NRUtil.merge({
		"title": "TechnoCo",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Corporation",
		"subtypes": ["Corporation"],
		"text": "The install cost of each program, piece of hardware, and <strong>virtual</strong> resource is increased by 1.\nWhenever the Runner installs a program, piece of hardware, or <strong>virtual</strong> resource, you may gain 1[credit]."
	}, {
		"special": {
			"auto-fire": "always",
		},
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "TechnoCo")],
		"static-abilities": [
			{
				"type": "install-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return _is_techno_target_19(target) and (not NRCardRT.truthy(NRCardRT.getv(NRCardRT.getv(targets, 1), "facedown"))),
				"value": 1,
			}
		],
		"events": [
			{
				"event": "runner-install",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return _is_techno_target_19(NRCardRT.getv(context, "card")) and (not NRCardRT.truthy(NRCardRT.getv(context, "facedown"))),
					"prompt": "Gain 1 [Credit]?",
					"waiting-prompt": true,
					"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
					"yes-ability": {
						"msg": "gain 1 [Credits]",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRGaining.gain_credits(state, "corp", eid, 1),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Tenma Line", NRUtil.merge({
		"title": "Tenma Line",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "[click]: Swap 2 pieces of installed ice."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Swap 2 installed pieces of ice",
				"cost": [NRPayment.to_c("click")],
				"keep-menu-open": "while-clicks-left",
				"prompt": "Choose 2 pieces of ice to swap positions",
				"req": func(state, side, eid, card, targets):
					return (2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), NRCard.ice))),
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.ice(_pct)),
					"max": 2,
					"all": true,
				},
				"msg": func(state, side, eid, card, targets):
					return str("swap the positions of ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 0))) + str(" and ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 1))),
				"effect": func(state, side, eid, card, targets):
					return apply(NRMoving.swap_installed, state, side, targets),
			}
		],
	}))
	NRCardDefs.defcard("Test Ground", NRUtil.merge({
		"title": "Test Ground",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"text": "Test Ground can be advanced.\n[trash]: Derez 1 card for each advancement token on Test Ground."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"label": "Derez 1 card for each advancement counter",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "advancement")),
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
						var cards_to_pick = mini(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return (NRCard.rezzed(_pct) and (not NRCardRT.truthy(NRCard.agenda(_pct)))))), NRCard.get_counters(card, "advancement"))
						var payment_eid = eid
						return NREngine.resolve_ability(state, side, eid, {
							"prompt": str("derez ") + str(cards_to_pick) + str(" cards"),
							"waiting-prompt": true,
							"choices": {
								"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy(NRCard.rezzed(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.agenda(x))))),
								"max": cards_to_pick,
								"all": true,
							},
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRRezzing.derez(
									state,
									side,
									eid,
									targets,
									{
										"msg-keys": {
											"include-cost-from-eid": payment_eid,
										},
									}
								),
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("The Board", NRUtil.merge({
		"title": "The Board",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 3,
		"trash": 7,
		"factioncost": 5,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Each agenda in the Runner's score area is worth 1 less agenda point.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
	}, {
		"on-trash": _executive_trash_effect(),
		"static-abilities": [
			{
				"type": "agenda-value",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (("runner" == NRCardRT.getv(target, "scored-side")) or NRUtil.kw_eq("runner", NRCardRT.getv(target, "scored-side"))),
				"value": -1,
			}
		],
	}))
	NRCardDefs.defcard("The News Now Hour", NRUtil.merge({
		"title": "The News Now Hour",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Cast",
		"subtypes": ["Cast"],
		"text": "The Runner cannot play <strong>current</strong> events."
	}, {
		"events": [
			{
				"event": "runner-turn-begins",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return prevent_current(state, side),
			}
		],
		"on-rez": {
			"effect": func(state, side, eid, card, targets):
				return prevent_current(state, side),
		},
		"leave-play": func(state, side, eid, card, targets):
			return state.assoc_in(["runner", "register", "cannot-play-current"], false),
	}))
	NRCardDefs.defcard("The Powers That Be", NRUtil.merge({
		"title": "The Powers That Be",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Ritzy",
		"subtypes": ["Ritzy"],
		"text": "Whenever you score an agenda, you may install 1 card from HQ or Archives, ignoring all costs."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"prompt": "Choose a card from Archives or HQ to install, ignoring all costs",
				"show-discard": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.corp_installable_type(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						null,
						{
							"ignore-install-cost": true,
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("The Root", NRUtil.merge({
		"title": "The Root",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 6,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Beanstalk",
		"subtypes": ["Beanstalk"],
		"text": "3[recurring-credit]\nUse these credits to advance, install, and rez cards."
	}, {
		"recurring": 3,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (["advance", "corp-install", "rez"](NRCardRT.getv(eid, "source-type")) or NREid.is_basic_advance_action(eid)),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Thomas Haas", NRUtil.merge({
		"title": "Thomas Haas",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 1,
		"factioncost": 1,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Thomas Haas can be advanced.\n[trash]: Gain 2[credit] for each advancement token on Thomas Haas."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"label": "Gain credits",
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str((2 * NRCard.get_counters(card, "advancement"))) + str(" [Credits]"),
				"cost": [NRPayment.to_c("trash-can")],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, (2 * NRCard.get_counters(card, "advancement"))),
			}
		],
	}))
	NRCardDefs.defcard("Tiered Subscription", NRUtil.merge({
		"title": "Tiered Subscription",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "The first time each turn a run begins, gain 1[credit]."
	}, {
		"events": [
			{
				"event": "run",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "run"),
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Toshiyuki Sakai", NRUtil.merge({
		"title": "Toshiyuki Sakai",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Toshiyuki Sakai can be advanced.\nIf Toshiyuki Sakai is accessed while installed, you may swap him with an agenda or asset from HQ. The new agenda or asset is installed unrezzed, and keeps all advancement tokens on Toshiyuki Sakai. The Runner can choose not to access the new card."
	}, _advance_ambush(
		0,
		{
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose an asset or agenda in HQ",
			"choices": {
				"card": func(_pct):
					return ((NRCard.agenda(_pct) or NRCard.asset(_pct)) and NRCard.in_hand(_pct)),
			},
			"msg": "swap itself for an asset or agenda from HQ",
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var counters = NRCard.get_counters(card, "advancement")
					var _v_20 = NRMoving.swap_cards(state, side, card, target)
					var moved_card = NRCardRT.getv(_v_20, 0)
					var moved_target = NRCardRT.getv(_v_20, 1)
					NRProps.set_prop(state, side, moved_target, "advance-counter", counters)
					return NREngine.resolve_ability(state, "runner", eid, {
						"optional": {
							"prompt": "Access the newly installed card?",
							"yes-ability": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRAccess.access_card(state, side, eid, NRCard.get_card(state, moved_target)),
							},
						},
					}, moved_card, null)
				).call(),
		}
	)))
	NRCardDefs.defcard("Trieste Model Bioroids", NRUtil.merge({
		"title": "Trieste Model Bioroids",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "When you rez this asset, choose 1 rezzed piece of <strong>bioroid</strong> ice.\nRunner card abilities cannot break subroutines on the chosen ice."
	}, {
		"on-rez": {
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("prevent ") + str(NRToString.card_str(state, target)) + str(" from being broken by runner card abilities"),
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and NRCard.has_subtype(_pct, "Bioroid")),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card), ["special", "trieste-target"], target)),
		},
		"static-abilities": [
			{
				"type": "icon",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.get_in(card, ["special", "trieste-target"], null)),
				"value": func(state, side, eid, card, targets):
					return make_icon("TMB", card),
			},
			{
				"type": "prevent-paid-ability",
				"req": func(state, side, eid, card, targets):
					var current_ice = NRIce.get_current_ice(state)
					return (func():
						var _v_21 = targets
						var break_card = NRCardRT.getv(_v_21, 0)
						var break_ability = NRCardRT.getv(_v_21, 1)
						return (NRUtil.same_card(current_ice, NRCardRT.get_in(card, ["special", "trieste-target"], null)) and NRCard.runner(break_card) and ((not NRCardRT.truthy(NRCard.identity(break_card))) or NRCard.identity(break_card)) and (NRCardRT.as_array(break_ability).has("break") or NRCardRT.as_array(break_ability).has("breaks") or NRCardRT.as_array(break_ability).has("heap-breaker-break") or NRCardRT.as_array(break_ability).has("break-cost")))
					).call(),
				"value": true,
			}
		],
	}))
	NRCardDefs.defcard("Trojan", NRUtil.merge({
		"title": "Trojan",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 0,
		"text": "If Trojan is accessed from R&D, then Runner must reveal it.\nWhen the Runner accesses Trojan, lose 2[credit], trash 1 card from HQ at random, and destroy Trojan. Ignore this ability if the Runner accesses Trojan from Archives."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.in_discard(card))),
			"msg": func(state, side, eid, card, targets):
				return str("lose 2 [Credits], destroy itself, and trash 1 card from HQ at random"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.lose_credits(state, "corp", ne, 2)
				, func(async_result):
					NRMoving.move(state, side, card, "destroyed")
					(func():
						var trash_target = NRCardRT.getv(shuffle(state.get_in(["corp", "hand"], null)), 0)
						return (NRMoving.trash(
							state,
							"corp",
							eid,
							trash_target,
							{
								"cause-card": card,
							}
						) if trash_target else NREid.effect_completed(state, side, eid))
					).call()),
		},
	}))
	NRCardDefs.defcard("Turtlebacks", NRUtil.merge({
		"title": "Turtlebacks",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 1,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "Gain 1[credit] whenever you create a server."
	}, {
		"events": [
			{
				"event": "server-created",
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Ubiquitous Vig", NRUtil.merge({
		"title": "Ubiquitous Vig",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "You can advance this asset.\nWhen your turn begins, gain 1[credit] for each hosted advancement counter."
	}, (func():
		var ability = {
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(NRCard.get_counters(card, "advancement")) + str(" [Credits]"),
			"label": "Gain 1 [Credits] for each advancement counter (start of turn)",
			"automatic": "corp-gain-credits",
			"once": "per-turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, NRCard.get_counters(card, "advancement")),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"advanceable": "always",
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Urban Renewal", NRUtil.merge({
		"title": "Urban Renewal",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "Place 3 power counters on Urban Renewal when it is rezzed. When there are no power counters left on Urban Renewal, trash it and do 4 meat damage.\nWhen your turn begins, remove 1 power counter from Urban Renewal."
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"derezzed-events": [NRCardRT.corp_rez_toast],
		"events": [
			{
				"event": "corp-turn-begins",
				"automatic": "corp-damage",
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "power", -1, null)
					, func(async_result):
						(NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, side, ne, card, {
								"cause-card": card,
							})
						, func(async_result):
							NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to do 4 meat damage"))
							NRDamage.damage(
								state,
								side,
								eid,
								"meat",
								4,
								{
									"card": card,
								}
							)) if (not NRCardRT.truthy(NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "power")))) else NREid.effect_completed(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Urtica Cipher", NRUtil.merge({
		"title": "Urtica Cipher",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "You can advance this asset.\nWhen the Runner accesses this asset while it is installed, do 2 net damage plus 1 net damage for each hosted advancement counter."
	}, _advance_ambush(
		0,
		{
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str((2 + NRCard.get_counters(NRCard.get_card(state, card), "advancement"))) + str(" net damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					(2 + NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
					{
						"card": card,
					}
				),
		}
	)))
	NRCardDefs.defcard("Vaporframe Fabricator", NRUtil.merge({
		"title": "Vaporframe Fabricator",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Industrial",
		"subtypes": ["Industrial"],
		"text": "Once per turn → [click]<strong>:</strong> Install 1 card from HQ, ignoring all costs.\nWhen the Runner trashes this asset, you may install 1 card from HQ, ignoring all costs. You cannot install that card in the root of this server."
	}, {
		"on-trash": {
			"req": func(state, side, eid, card, targets):
				return (("runner" == side) or NRUtil.kw_eq("runner", side)),
			"async": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct)))),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var card_to_install = target
					return {
						"async": true,
						"prompt": "Choose a server",
						"choices": func(state, side, eid, card, targets):
							return NRCardRT.filter_list(NRBoard.installable_servers(state, card_to_install), func(x): return not NRCardRT.truthy((NRCardRT.distinct_list(NRServers.zone_to_name(NRCard.get_zone(card)))).call(x))),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRInstalling.corp_install(
								state,
								side,
								eid,
								card_to_install,
								target,
								{
									"ignore-all-cost": true,
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								}
							),
					}
				).call(), card, null),
		},
		"abilities": [
			{
				"action": true,
				"label": "Install 1 card",
				"async": true,
				"cost": [NRPayment.to_c("click", 1)],
				"once": "per-turn",
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_hand(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct)))),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str(corp_install_msg(target)),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						null,
						{
							"ignore-all-cost": true,
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Vera Ivanovna Shuyskaya", NRUtil.merge({
		"title": "Vera Ivanovna Shuyskaya",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 3,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Whenever an agenda is scored or stolen, you may reveal the grip. Trash 1 card revealed this way."
	}, (func():
		var ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Reveal the grip and trash a card?",
				"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
				"yes-ability": with_revealed_hand(
					"runner",
					{
						"event-side": "corp",
					},
					{
						"prompt": "Choose a card to trash",
						"req": func(state, side, eid, card, targets):
							var runner = state.player("runner")
							return NRCardRT.seq_of(NRCardRT.getv(runner, "hand")),
						"choices": {
							"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.in_hand(x)) and NRCardRT.truthy(NRCard.runner(x))),
						},
						"async": true,
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("trash ") + str(NRCardRT.getv(target, "title")) + str(" from the Grip"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRMoving.trash(
								state,
								side,
								eid,
								target,
								{
									"cause-card": card,
								}
							),
					}
				),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		}
		return {
			"events": [
				NRUtil.merge(ability, {"event": "agenda-scored"}),
				NRUtil.merge(ability, {"event": "agenda-stolen"})
			],
			"abilities": [NRCardRT.set_autoresolve("auto-fire", "Vera Ivanovna Shuyskaya")],
		}
	).call()))
	NRCardDefs.defcard("Victoria Jenkins", NRUtil.merge({
		"title": "Victoria Jenkins",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 3,
		"trash": 5,
		"factioncost": 5,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "The Runner gets -1 allotted [click] for each of their turns.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
	}, {
		"on-rez": {
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose(state, "runner", "click-per-turn", 1),
		},
		"leave-play": func(state, side, eid, card, targets):
			return NRGaining.gain(state, "runner", "click-per-turn", 1),
		"on-trash": _executive_trash_effect(),
	}))
	NRCardDefs.defcard("Wage Workers", NRUtil.merge({
		"title": "Wage Workers",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Bioroid - Clone - Industrial",
		"subtypes": ["Bioroid", "Clone", "Industrial"],
		"text": "Whenever you finish taking an action, if you have taken that action exactly 3 times this turn, gain [click]."
	}, (func():
		var payoff = {
			"msg": "gain [Click]",
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(state.get_in([side, "register", "terminal"], null))),
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		}
		var relevant_keys = func(context):
			return {
			"cid": NRCardRT.get_in(context, ["card", "cid"], null),
			"idx": NRCardRT.getv(context, "ability-idx"),
		}
		return {
			"events": [
				{
					"event": "action-resolved",
					"req": func(state, side, eid, card, targets):
						return (("corp" == side) or NRUtil.kw_eq("corp", side)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (func():
							var similar_actions = NREvents.event_count(
								state,
								side,
								"action-resolved",
								func(__vec______sym____ctx____):
									return ((relevant_keys(ctx) == relevant_keys(context)) or NRUtil.kw_eq(relevant_keys(ctx), relevant_keys(context)))
							)
							return NREngine.resolve_ability(state, side, eid, (payoff if NRCardRT.truthy(((3 == similar_actions) or NRUtil.kw_eq(3, similar_actions))) else null), card, null)
						).call(),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Wall to Wall", NRUtil.merge({
		"title": "Wall to Wall",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "When your turn begins, if you have any other rezzed assets, resolve 1 of the following; otherwise, resolve up to 3 in any order:<ul><li>Draw 1 card.</li><li>Gain 1[credit].</li><li>Place 1 advancement counter on an installed piece of ice.</li><li>Add this asset to HQ.</li></ul>"
	}, (func():
		var all = [
			{
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 1),
			},
			{
				"msg": "draw 1 card",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDrawing.draw(state, side, eid, 1),
			},
			{
				"label": "place 1 advancement counter on a piece of ice",
				"msg": {
					"public": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
					"corp": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("place 1 advancement counter on ") + str(NRToString.card_str(
							state,
							target,
							{
								"maybe-visible": true,
							}
						)),
				},
				"prompt": "Choose a piece of ice to place 1 advancement counter on",
				"async": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.installed(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRProps.add_prop(
						state,
						side,
						eid,
						target,
						"advance-counter",
						1,
						{
							"placed": true,
						}
					),
			},
			{
				"label": "add this asset to HQ",
				"msg": "add itself to HQ",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, side, card, "hand"),
			}
		]
		var choice = func(abis, n):
			return (func():
				var choices = NRCardRT.concat_lists([mapv(NRUtil.make_label, abis), ["Done"]])
				return {
					"prompt": "Choose an ability to resolve",
					"choices": choices,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var chosen = NRCardRT.getv(NRCardRT.filter_list(choices, func(_pct):
								return ((_pct == target) or NRUtil.kw_eq(_pct, target))), 0)
							var chosen_ability = NRCardRT.getv(NRCardRT.filter_list(abis, func(_pct):
								return ((target == NRUtil.make_label(_pct)) or NRUtil.kw_eq(target, NRUtil.make_label(_pct)))), 0)
							return NREid.wait_for(state, eid, func(ne):
								NREngine.resolve_ability(state, side, ne, chosen_ability, card, null)
							, func(async_result):
								(NREngine.resolve_ability(state, side, eid, choice(
									NRCardRT.filter_list(abis, func(x): return not NRCardRT.truthy((func(_pct):
										return ((_pct == chosen_ability) or NRUtil.kw_eq(_pct, chosen_ability))).call(x))),
									(int(n) - 1)
								), card, null) if (NRCardRT.pos((int(n) - 1)) and (not (("Done" == chosen) or NRUtil.kw_eq("Done", chosen)))) else NREid.effect_completed(state, side, eid)))
						).call(),
			}
		).call()
		var ability = {
			"async": true,
			"automatic": "last",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"label": "resolve an ability (start of turn)",
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, choice(all, (1 if (1 < NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), NRCard.asset))) else 3)), card, null),
		}
		return {
			"derezzed-events": [NRUtil.merge(NRCardRT.corp_rez_toast, {"event": "runner-turn-ends"})],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Warden Fatuma", NRUtil.merge({
		"title": "Warden Fatuma",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Each rezzed piece of <strong>bioroid</strong> ice gains \"[subroutine] The Runner loses [click].\" before its other subroutines."
	}, {
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRCard.rezzed(target) and NRCard.has_subtype(target, "Bioroid"),
				"value": {
					"position": "front",
					"subroutines": [
						{
							"label": "[Warden Fatuma] Force the Runner to lose [Click], if able",
							"msg": "force the Runner to lose [Click], if able",
							"effect": func(state, side, eid, card, targets):
								return NRGaining.lose_clicks(state, "runner", 1),
						}
					],
				},
			}
		],
	}))
	NRCardDefs.defcard("Warm Reception", NRUtil.merge({
		"title": "Warm Reception",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Political - Ritzy",
		"subtypes": ["Political", "Ritzy"],
		"text": "When your turn begins, you may install 1 card from HQ. You cannot score that card this turn. If this server is not protected by ice, you may derez this asset to derez another installed card."
	}, (func():
		var install = {
			"prompt": "Choose a card to install",
			"async": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.corp_install(state, side, ne, target, null, {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
				, func(async_result):
					(func():
						var installed_card = async_result
						NRFlags.register_turn_flag(
							state,
							side,
							card,
							"can-score",
							func(state, _, card):
								return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score due to Warm Reception.", "warning")) if NRUtil.same_card(card, installed_card) else true)
						)
						return NREid.effect_completed(state, side, eid)
					).call()),
		}
		var derez_abi = {
			"label": "Derez another card (start of turn)",
			"req": func(state, side, eid, card, targets):
				var unprotected = (card is Dictionary and NRCardRT.empty_of(state.get_in(["corp", "servers", NRCard.get_zone(card)[1] if NRCard.get_zone(card).size() > 1 else "", "ices"], [])))
				return unprotected,
			"prompt": "Choose another card to derez",
			"choices": {
				"not-self": true,
				"card": func(_pct):
					return NRCard.rezzed(_pct),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRRezzing.derez(state, side, eid, [card, target]),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [
				{
					"event": "corp-turn-begins",
					"interactive": func(state, side, eid, card, targets):
						return true,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, install, card, null)
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, derez_abi, card, null)),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Watchdog", NRUtil.merge({
		"title": "Watchdog",
		"type": "Asset",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 1,
		"text": "The rez cost of the first piece of ice you rez each turn is lowered by 1 for each tag the Runner has."
	}, {
		"static-abilities": [
			{
				"type": "rez-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and _not_triggered_22(state),
				"value": func(state, side, eid, card, targets):
					return (-count_tags(state)),
			}
		],
		"events": [
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.ice(NRCardRT.getv(context, "card")) and _not_triggered_22(state),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("reduce the rez cost of ") + str(NRCardRT.getv(NRCardRT.getv(context, "card"), "title")) + str(" by ") + str(count_tags(state)) + str(" [Credits]"),
			}
		],
	}))
	NRCardDefs.defcard("Whampoa Reclamation", NRUtil.merge({
		"title": "Whampoa Reclamation",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Corporation",
		"subtypes": ["Corporation"],
		"text": "Once per turn → <strong>Trash 1 card from HQ:</strong> Add 1 card from Archives to the bottom of R&D."
	}, {
		"abilities": [
			{
				"label": "Add 1 card from Archives to the bottom of R&D",
				"once": "per-turn",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))) and NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "discard"))),
				"async": true,
				"cost": [NRPayment.to_c("trash-from-hand", 1)],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, {
						"waiting-prompt": true,
						"prompt": "Choose a card in Archives to add to the bottom of R&D",
						"show-discard": true,
						"choices": {
							"card": func(_pct):
								return (NRCard.in_discard(_pct) and NRCard.corp(_pct)),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("trash 1 card from HQ and add ") + str((NRCardRT.getv(target, "title") if NRCardRT.getv(target, "seen") else "a card")) + str(" from Archives to the bottom of R&D"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRMoving.move(state, side, target, "deck"),
					}, card, null),
			}
		],
	}))
	NRCardDefs.defcard("Working Prototype", NRUtil.merge({
		"title": "Working Prototype",
		"type": "Asset",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "Whenever you rez a card <em>(including this asset)</em>, place 1 power counter on this asset.\n[click], <strong>hosted power counter:</strong> Gain 3[credit].\n[click], <strong>5 hosted power counters:</strong> Gain 6[credit]. Add 1 installed resource to the top of the stack."
	}, {
		"events": [
			{
				"event": "rez",
				"silent": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
				"label": "Gain 3 [Credits]",
				"msg": "gain 3 [Credits]",
				"keep-menu-open": "while-power-tokens-left",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 3),
			},
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 5)],
				"label": "Gain 6 [Credits]. Add 1 resource to the top of the stack",
				"keep-menu-open": "while-5-power-tokens-left",
				"msg": "gain 6 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, 6)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a resource",
							"req": func(state, side, eid, card, targets):
								return NRCardRT.seq_of(all_installed_runner_type(state, "resource")),
							"choices": {
								"card": func(_pct):
									return NRCard.resource(_pct),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str(str("add ") + str(NRCardRT.getv(target, "title")) + str(" to the top of the stack")),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRMoving.move(
									state,
									"runner",
									target,
									"deck",
									{
										"front": true,
									}
								),
						}, card, null)
						NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Worlds Plaza", NRUtil.merge({
		"title": "Worlds Plaza",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 5,
		"factioncost": 5,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "Worlds Plaza can host up to 3 assets.\n[click]: Install an asset from HQ on Worlds Plaza and rez it, lowering its rez cost by 2, if able."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Install an asset on this asset",
				"req": func(state, side, eid, card, targets):
					return (NRCardRT.count_of(NRCardRT.getv(card, "hosted")) < 3),
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"prompt": "Choose an asset to install",
				"choices": {
					"card": func(_pct):
						return (NRCard.asset(_pct) and NRCard.in_hand(_pct) and NRCard.corp(_pct)),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("host ") + str(NRCardRT.getv(target, "title")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRInstalling.corp_install(state, side, ne, target, card, null)
					, func(async_result):
						NRRezzing.rez(
							state,
							side,
							eid,
							(func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCardRT.getv(NRCard.get_card(state, card), "hosted"))),
							{
								"cost-bonus": -2,
							}
						)),
			}
		],
	}))
	NRCardDefs.defcard("Zaibatsu Loyalty", NRUtil.merge({
		"title": "Zaibatsu Loyalty",
		"type": "Asset",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 1,
		"text": "[interrupt] → When a card would be exposed, you may rez this asset.\n[interrupt] → <strong>1[credit]</strong> or <strong>[trash]:</strong> Prevent 1 card from being exposed."
	}, {
		"prevention": [
			{
				"prevents": "expose",
				"type": "ability",
				"label": "1 [Credit]: Zaibatsu Loyalty",
				"ability": {
					"cost": [NRPayment.to_c("credit", 1)],
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRPrevention.preventable(context),
					"msg": "prevent a card from being exposed",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return prevent_expose(state, side, eid, card),
				},
			},
			{
				"prevents": "expose",
				"type": "ability",
				"label": "[trash]: Zaibatsu Loyalty",
				"ability": {
					"cost": [NRPayment.to_c("trash-can")],
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRPrevention.preventable(context),
					"msg": "prevent a card from being exposed",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return prevent_expose(state, side, eid, card),
				},
			}
		],
		"derezzed-events": [
			{
				"event": "expose-interrupt",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var ctx = context
						return NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"req": func(state, side, eid, card, targets):
									return (not NRCardRT.truthy(NRCard.rezzed(card))),
								"prompt": func(state, side, eid, card, targets):
									return str("The Runner is about to expose ") + str(enumerate_str(
										NRCardRT.map_list(NRCardRT.getv(ctx, "cards"), func(_pct):
											return NRToString.card_str(
											state,
											_pct,
											{
												"visible": true,
											}
										))
									)) + str(". Rez Zaibatsu Loyalty?"),
								"yes-ability": {
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NRRezzing.rez(state, side, eid, card),
								},
							},
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Zealous Judge", NRUtil.merge({
		"title": "Zealous Judge",
		"type": "Asset",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "Zealous Judge can only be rezzed if the Runner is tagged.\n[click], 1[credit]: Give the Runner 1 tag."
	}, {
		"rez-req": func(state, side, eid, card, targets):
			var tagged = NRUtil.is_tagged(state)
			return tagged,
		"abilities": [
			{
				"action": true,
				"async": true,
				"label": "Give the Runner 1 tag",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 1)],
				"keep-menu-open": "while-clicks-left",
				"msg": "give the Runner 1 tag",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, side, eid, 1),
			}
		],
	}))

static func _advance_ambush(cost = null, ability = null, prompt = null):
	return NRUtil.merge(installed_access_trigger(cost, ability, prompt), {"advanceable": "always"})

static func _take_n_credits_start_of_turn(n = null, counter_type = null):
	return (func():
		var num_counters = func(card):
			return mini(n, NRCard.get_counters(card, counter_type))
		return {
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(num_counters(card)) + str(" [Credits]"),
			"once": "per-turn",
			"automatic": "gain-credits",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.getv(state.data, "corp-phase-12") and NRCardRT.pos(NRCard.get_counters(card, counter_type)),
			"label": str("Gain ") + str(n) + str(" [Credits] (start of turn)"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDefHelpers.take_credits(state, side, eid, card, counter_type, n),
		}
	).call()

static func _campaign(counters = null, per_turn = null, counter_type = null):
	return (func():
		var ability = _take_n_credits_start_of_turn(per_turn, counter_type)
		return {
			"data": {
				"counter": {
					"counter-type": counters,
				},
			},
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [trash_on_empty(counter_type), NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()

static func _creds_on_round_start(per_turn):
	return (func():
		var ability = {
			"msg": str("gain ") + str(per_turn) + str(" [Credits]"),
			"label": str("Gain ") + str(per_turn) + str(" [Credits] (start of turn)"),
			"once": "per-turn",
			"async": true,
			"automatic": "gain-credits",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, per_turn),
		}
		return {
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()

static func _return_to_top(set_aside_cards = null, reveal = null):
	return {
		"prompt": "Choose a card to put on top of R&D",
		"req": func(state, side, eid, card, targets):
			return (not NRCardRT.truthy(NRCardRT.zero(NRCardRT.count_of(set_aside_cards)))),
		"choices": {
			"min": 1,
			"max": 1,
			"req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRCardRT.some_list(set_aside_cards, func(_pct):
					return NRUtil.same_card(_pct, target)),
		},
		"async": true,
		"waiting-prompt": true,
		"msg": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str("place ") + str((NRCardRT.getv(target, "title") if NRRevealing.reveal else "a card")) + str(" on top of R&D"),
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			NRMoving.move(
				state,
				"corp",
				target,
				"deck",
				{
					"front": true,
				}
			)
			return (func():
				var rem = NRCardRT.seq_of(NRCardRT.filter_list(set_aside_cards, func(_pct):
					return (not NRCardRT.truthy(NRUtil.same_card(target, _pct)))))
				return (NREngine.resolve_ability(state, side, eid, _return_to_top(rem, NRRevealing.reveal), card, null) if NRCardRT.seq_of(rem) else NREid.effect_completed(state, side, eid))
			).call(),
	}

static func _select_archives_cards_1(total):
	return {
	"async": true,
	"show-discard": true,
	"prompt": str("Choose ") + str(NRCardRT.quantify(total, "card")) + str(" from Archives"),
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
		"max": total,
		"all": true,
	},
	"effect": func(state, side, eid, card, targets):
		return NREid.complete_with_result(state, side, eid, targets),
}

static func _select_hq_cards_2(total):
	return {
	"async": true,
	"prompt": str("Choose ") + str(NRCardRT.quantify(total, "card")) + str(" from HQ"),
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
		"max": total,
		"all": true,
	},
	"effect": func(state, side, eid, card, targets):
		return NREid.complete_with_result(state, side, eid, targets),
}

static func _senai_ability_3(agenda):
	return {
	"interactive": func(state, side, eid, card, targets):
		return true,
	"optional": {
		"prompt": "Initiate a trace?",
		"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
		"yes-ability": {
			"trace": {
				"base": NRCard.get_advancement_requirement(agenda),
				"successful": {
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and NRCard.runner(_pct)),
					},
					"label": "add 1 installed card to the grip",
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to the grip"),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.move(state, "runner", target, "hand"),
				},
			},
		},
	},
}

static func _counters_available_4(state):
	return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
		return NRCardRT.pos(NRCard.get_counters(_pct, "advancement")))

static func _not_triggered_5(state):
	return NREvents.no_event(state, "runner", "runner-install")

static func _ice_count_6(state):
	return NRCardRT.count_of(NRCardRT.get_in(NRCardRT.getv(state.data, "corp"), [
	"servers",
	(func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))),
	"ices"
], null))

static func _tag_count_7(false_flag):
	return int((NRCard.get_counters(false_flag, "advancement") / 2))

static func _valid_ctx_9(evs):
	return NRCardRT.some_list(evs, func(_pct):
		return (NRCard.corp(NRCardRT.getv(_pct, "card")) and NRCard.installed(NRCardRT.getv(_pct, "card"))))

static func _adv_10(card):
	return NRCard.get_counters(card, "advancement")

static func _lose_11(card, runner):
	return mini((2 * _adv_10(card)), NRCardRT.getv(runner, "credit"))

static func _gain_12(card):
	return (3 * _adv_10(card))

static func _swap_abi_13(stolen):
	return {
	"prompt": str("Swap ") + str(NRCardRT.getv(stolen, "title")) + str(" with an agenda in your score area?"),
	"req": func(state, side, eid, card, targets):
		var corp = state.player("corp")
		return NRCardRT.seq_of(NRCardRT.getv(corp, "scored")),
	"choices": {
		"req": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRFlags.in_corp_scored(state, side, target),
	},
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str("swap ") + str(NRToString.card_str(state, stolen)) + str(" for ") + str(NRToString.card_str(state, target)),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return swap_agendas(state, side, target, stolen),
}

static func _moon_pool_place_advancements_15(x):
	return {
	"async": true,
	"prompt": func(state, side, eid, card, targets):
		return str("Choose an installed card to place advancement counters on (") + str(x) + str(" remaining)"),
	"choices": {
		"card": func(_pct):
			return NRCard.installed(_pct),
	},
	"msg": {
		"public": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
		"corp": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str("place 1 advancement counter on ") + str(NRToString.card_str(
				state,
				target,
				{
					"maybe-visible": true,
				}
			)),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRProps.add_prop(state, side, ne, target, "advance-counter", 1, {
				"placed": true,
			})
		, func(async_result):
			(NREngine.resolve_ability(state, side, eid, moon_pool_place_advancements((int(x) - 1)), card, null) if (x > 1) else NREid.effect_completed(state, side, eid))),
	"cancel": {
		"msg": "decline to place advancement counters",
	},
}

static func _builder_16(cost, cred):
	return {
	"cost": [NRPayment.to_c("advancement", cost), NRPayment.to_c("trash-can")],
	"async": true,
	"effect": func(state, side, eid, card, targets):
		return NRGaining.gain_credits(state, side, eid, cred),
	"label": str("Gain ") + str(cred) + str(" [Credits]"),
	"msg": str("gain ") + str(cred) + str(" [Credits]"),
}

static func _pdhelper_17(agendas):
	return (func():
		var agenda = NRCardRT.getv(agendas, 0)
		return {
		"optional": {
			"prompt": func(state, side, eid, card, targets):
				return str("Reveal and install ") + str(NRCardRT.getv(agenda, "title")) + str("?"),
			"yes-ability": {
				"msg": func(state, side, eid, card, targets):
					return str("reveal they drew ") + str(NRCardRT.getv(agenda, "title")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, agenda)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRInstalling.corp_install(state, side, ne, agenda, null, {
								"install-state": NRCardRT.getv(NRCardDefs.card_def(agenda), "install-state", "unrezzed"),
								"msg-keys": {
									"install-source": card,
									"known": true,
									"display-origin": true,
								},
							})
						, func(async_result):
							remove_from_currently_drawing(state, side, agenda)
							NREngine.resolve_ability(state, side, eid, pdhelper(NRCardRT.seq_of(NRCardRT.drop_n(agendas, 1))), card, null))),
			},
			"no-ability": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, pdhelper(NRCardRT.seq_of(NRCardRT.drop_n(agendas, 1))), card, null),
			},
	},
} if agenda != null and NRCardRT.truthy(agenda) else null
).call()

static func _rez_ice_18(cnt, discount):
	return {
	"prompt": str("Choose a piece of ice to rez, paying ") + str(discount) + str(" [Credits] less"),
	"async": true,
	"choices": {
		"req": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRCard.ice(target) and NRRezzing.can_pay_to_rez(
				state,
				side,
				NRUtil.merge(eid, {"source": card}),
				target,
				{
					"cost-bonus": (-discount),
				}
			) and (not NRCardRT.truthy(NRCard.rezzed(target))),
	},
	"waiting-prompt": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRRezzing.rez(state, side, ne, target, {
				"no-warning": true,
				"cost-bonus": (-discount),
			})
		, func(async_result):
			(NREngine.resolve_ability(state, side, eid, rez_ice((int(cnt) + 1), discount), card, null) if (cnt < 3) else NREid.effect_completed(state, side, eid))),
}

static func _is_techno_target_19(card):
	return (NRCard.program(card) or NRCard.hardware(card) or (NRCard.resource(card) and NRCard.has_subtype(card, "Virtual")))

static func _not_triggered_22(state):
	return NREvents.no_event(
	state,
	"runner",
	"rez",
	func(_pct):
		return NRCard.ice(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
)
