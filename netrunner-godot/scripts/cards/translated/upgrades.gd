class_name NRCardsUpgrades
extends RefCounted

## Port of game.cards.upgrades — translated from Jinteki.net Clojure.


static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Adrian Seis", NRUtil.merge({
		"title": "Adrian Seis",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 2,
		"factioncost": 4,
		"keywords": "Psi - Clone - Sysop",
		"subtypes": ["Psi", "Clone", "Sysop"],
		"text": "Whenever the Runner makes a successful run on this server, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, the Runner cannot access cards other than this upgrade for the remainder of that run. If the bids match, the Runner cannot access this upgrade for the remainder of that run.\nWhen your turn ends, you may move this upgrade to the root of another server."
	}, {
		"events": [
			_mobile_sysop_event(),
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"psi": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"not-equal": {
						"msg": func(state, side, eid, card, targets):
							return str("prevent the Runner from accessing cards other than ") + str(NRCardRT.getv(card, "title")),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							set_only_card_to_access(state, side, card)
							return NREid.effect_completed(state, side, eid),
					},
					"equal": {
						"msg": func(state, side, eid, card, targets):
							return str("prevent the Runner from accessing ") + str(NRCardRT.getv(card, "title")),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							NRFlags.register_run_flag(
								state,
								side,
								card,
								"can-access",
								func(_, _, target):
									return (not NRCardRT.truthy(NRUtil.same_card(target, card)))
							)
							return NREid.effect_completed(state, side, eid),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Akitaro Watanabe", NRUtil.merge({
		"title": "Akitaro Watanabe",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Sysop - Unorthodox",
		"subtypes": ["Sysop", "Unorthodox"],
		"text": "The rez cost of ice protecting this server is lowered by 2."
	}, {
		"static-abilities": [
			{
				"type": "rez-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRServers.protecting_same_server(card, target),
				"value": -2,
			}
		],
	}))
	NRCardDefs.defcard("AMAZE Amusements", NRUtil.merge({
		"title": "AMAZE Amusements",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"text": "Persistent → Whenever a run on this server ends, if the Runner stole any agendas during that run, give the Runner 2 tags. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
	}, (func():
		var ability = {
			"event": "run-ends",
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return ((NRCardRT.getv(NRCard.get_zone(card), 1) == NRCardRT.getv(NRCardRT.getv(context, "server"), 0)) or NRUtil.kw_eq(NRCardRT.getv(NRCard.get_zone(card), 1), NRCardRT.getv(NRCardRT.getv(context, "server"), 0))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return ((func():
					NRTags.gain_tags(state, "corp", eid, 2)
					return NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to give the Runner 2 tags"))
				).call() if NRCardRT.getv(context, "did-steal") else NREid.effect_completed(state, side, eid)),
		}
		return {
			"events": [ability],
			"on-trash": {
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run and (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NREngine.register_events(
						state,
						side,
						card,
						[
							NRUtil.merge(ability, {"req": func(state, side, eid, card, targets):
								var context = NRCardRT.ctx(targets)
								return ((NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 1) == NRCardRT.getv(NRCardRT.getv(context, "server"), 0)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 1), NRCardRT.getv(NRCardRT.getv(context, "server"), 0))), "duration": "end-of-run"})
						]
					),
			},
		}
	).call()))
	NRCardDefs.defcard("Amazon Industrial Zone", NRUtil.merge({
		"title": "Amazon Industrial Zone",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever you install a piece of ice protecting this server, you may immediately rez it, lowering its rez cost by 3.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "corp-install",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRCard.ice(NRCardRT.getv(context, "card")) and NRServers.protecting_same_server(card, NRCardRT.getv(context, "card")) and NRRezzing.can_pay_to_rez(
							state,
							side,
							NRUtil.merge(eid, {"source": card}),
							NRCardRT.getv(context, "card"),
							{
								"cost-bonus": -3,
							}
						),
					"prompt": "Rez ice with rez cost lowered by 3?",
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							return NRRezzing.rez(
								state,
								side,
								eid,
								NRCardRT.getv(context, "card"),
								{
									"cost-bonus": -3,
								}
							),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Angelique Garza Correa", NRUtil.merge({
		"title": "Angelique Garza Correa",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 0,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Ambush - Enforcer - Expendable",
		"subtypes": ["Ambush", "Enforcer", "Expendable"],
		"text": "Threat 3 → [click], <strong>1</strong>[credit], <strong>reveal and trash this upgrade from HQ:</strong> Do 1 meat damage. <em>(This ability is active if any player has 3 or more agenda points.)</em>\nWhen the Runner accesses this upgrade while it is rezzed, you may pay 2[credit] to do 2 meat damage."
	}, {
		"expend": {
			"req": func(state, side, eid, card, targets):
				return NRThreat.threat(state, int(3)),
			"cost": [NRPayment.to_c("credit", 1)],
			"msg": "do 1 meat damage",
			"async": true,
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
		},
		"on-access": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					return NRCard.rezzed(card),
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("Pay 2 [Credits] to use ") + str(NRCardRT.getv(card, "title")) + str(" ability?"),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("credit", 2)],
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
				},
			},
		},
	}))
	NRCardDefs.defcard("Anoetic Void", NRUtil.merge({
		"title": "Anoetic Void",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 1,
		"factioncost": 4,
		"text": "Whenever the Runner approaches this server, you may pay 2[credit] and trash 2 cards from HQ. If you do, end the run."
	}, {
		"events": [
			{
				"event": "approach-server",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"prompt": "Pay 2 [Credits] and trash 2 cards from HQ to end the run?",
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("credit", 2), NRPayment.to_c("trash-from-hand", 2)]) and this_server,
					"yes-ability": {
						"async": true,
						"msg": "end the run",
						"cost": [NRPayment.to_c("credit", 2), NRPayment.to_c("trash-from-hand", 2)],
						"effect": func(state, side, eid, card, targets):
							return NRRuns.end_run(state, side, eid, card),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Arella Salvatore", NRUtil.merge({
		"title": "Arella Salvatore",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever an agenda is scored from this server, you may install a card from HQ, ignoring all costs, and place 1 advancement token on it."
	}, (func():
		var select_ability = {
			"prompt": "Choose a card in HQ to install",
			"choices": {
				"card": func(_pct):
					return (NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct) and NRCard.corp(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRInstalling.corp_install(
					state,
					"corp",
					eid,
					target,
					null,
					{
						"ignore-all-cost": true,
						"counters": {
							"advance-counter": 1,
						},
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}
				),
		}
		return {
			"events": [
				{
					"event": "agenda-scored",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone") == NRCard.get_zone(card)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), NRCard.get_zone(card))),
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
					},
					"interactive": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.some_list(NRCardRT.getv(corp, "hand"), NRCard.corp_installable_type),
					"silent": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (not NRCardRT.some_list(NRCardRT.getv(corp, "hand"), NRCard.corp_installable_type)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (NREngine.resolve_ability(state, side, eid, select_ability, card, null) if NRCardRT.some_list(NRCardRT.getv(corp, "hand"), NRCard.corp_installable_type) else NREid.effect_completed(state, side, eid)),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Ash 2X3ZB9CY", NRUtil.merge({
		"title": "Ash 2X3ZB9CY",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "Whenever there is a successful run on this server, Trace[4]. If successful, the Runner cannot access any cards other than Ash 2X3ZB9CY for the remainder of this run."
	}, {
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"trace": {
					"base": 4,
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"successful": {
						"msg": "prevent the Runner from accessing cards other than Ash 2X3ZB9CY",
						"effect": func(state, side, eid, card, targets):
							return set_only_card_to_access(state, side, card),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Awakening Center", NRUtil.merge({
		"title": "Awakening Center",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 1,
		"text": "You can install <strong>bioroid</strong> ice onto this upgrade at no install cost.\nWhenever the Runner passes all of the ice protecting this server, you may rez 1 hosted piece of ice, paying 7[credit] less. If you do, the Runner encounters that ice. When this run ends, trash that ice."
	}, {
		"can-host": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRCard.ice(target),
		"abilities": [
			{
				"action": true,
				"label": "Host a piece of Bioroid ice",
				"cost": [NRPayment.to_c("click", 1)],
				"prompt": "Choose a piece of Bioroid ice in HQ to host",
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.has_subtype(_pct, "Bioroid") and NRCard.in_hand(_pct)),
				},
				"msg": "host a piece of Bioroid ice",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						card,
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
		"events": [
			{
				"event": "pass-all-ice",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server and NRCardRT.some_list(NRCardRT.getv(card, "hosted"), func(_pct):
							return NRRezzing.can_pay_to_rez(
							state,
							side,
							NRUtil.merge(eid, {"source": card}),
							_pct,
							{
								"cost-bonus": -7,
							}
						)),
					"prompt": "Rez and force the Runner to encounter a hosted piece of ice?",
					"waiting-prompt": true,
					"yes-ability": {
						"async": true,
						"prompt": "Choose a hosted piece of Bioroid ice to rez",
						"choices": func(state, side, eid, card, targets):
							return NRCardRT.filter_list(NRCardRT.getv(card, "hosted"), func(_pct):
								return NRRezzing.can_pay_to_rez(
								state,
								side,
								NRUtil.merge(eid, {"source": card}),
								_pct,
								{
									"cost-bonus": -7,
								}
							)),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRRezzing.rez(state, side, ne, target, {
									"cost-bonus": -7,
								})
							, func(async_result):
								NREngine.register_events(
									state,
									side,
									card,
									[
										{
											"event": "run-ends",
											"duration": "end-of-run",
											"async": true,
											"req": func(state, side, eid, card, targets):
												return NRCard.get_card(state, ice),
											"effect": func(state, side, eid, card, targets):
												return NRMoving.trash(
													state,
													side,
													eid,
													NRCard.get_card(state, ice),
													{
														"cause-card": card,
													}
												),
										}
									]
								)
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to force the Runner to encounter ") + str(NRToString.card_str(state, ice)))
								NRRuns.force_ice_encounter(state, side, eid, ice)),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Bamboo Dome", NRUtil.merge({
		"title": "Bamboo Dome",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Install only in the root of R&D.\n[click]: Reveal the top 3 cards of R&D. Secretly choose 1 to add to HQ. Return the others to the top of R&D, in any order.\nLimit 1 <strong>region</strong> per server."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return NRCardRT.truthy(["R&D"].call(x) if ["R&D"] is Callable else ["R&D"])),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "deck"))),
				},
				"async": true,
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str(str("reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3)))) + str(" from the top of R&D")),
				"label": "Add 1 card from top 3 of R&D to HQ",
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3)))
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a card to add to HQ",
							"async": true,
							"choices": NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3)),
							"not-distinct": true,
							"msg": "add 1 of the revealed cards to HQ",
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								NRMoving.move(state, side, target, "hand")
								return NREngine.resolve_ability(state, side, eid, (func():
									var from = NRCardRT.take_n(state.get_in(["corp", "deck"], null), int(2))
									return (reorder_choice("corp", "runner", from, null, NRCardRT.count_of(from), from) if NRCardRT.truthy(NRCardRT.pos(NRCardRT.count_of(from))) else null)
								).call(), card, null),
						}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Ben Musashi", NRUtil.merge({
		"title": "Ben Musashi",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "Persistent → As an additional cost to steal an agenda from this server or its root, the Runner must suffer 2 net damage. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
	}, {
		"on-trash": {
			"req": func(state, side, eid, card, targets):
				return (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCardRT.getv(state.data, "run"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "steal-additional-cost",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (((NRCard.get_zone(target) == NRCardRT.getv(card, "previous-zone")) or NRUtil.kw_eq(NRCard.get_zone(target), NRCardRT.getv(card, "previous-zone"))) or ((central_to_zone(NRCard.get_zone(target)) == butlast(NRCardRT.getv(card, "previous-zone"))) or NRUtil.kw_eq(central_to_zone(NRCard.get_zone(target)), butlast(NRCardRT.getv(card, "previous-zone"))))),
						"value": func(state, side, eid, card, targets):
							return NRPayment.to_c("net", 2),
					}
				),
		},
		"static-abilities": [
			{
				"type": "steal-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (in_same_server(card, target) or from_same_server(card, target)),
				"value": func(state, side, eid, card, targets):
					return NRPayment.to_c("net", 2),
			}
		],
	}))
	NRCardDefs.defcard("Bernice Mai", NRUtil.merge({
		"title": "Bernice Mai",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever there is a successful run on this server, Trace[5]. If successful, give the Runner 1 tag. If unsuccessful, trash Bernice Mai."
	}, {
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"trace": {
					"base": 5,
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"successful": NRDefHelpers.give_tags(1),
					"unsuccessful": {
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
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Bio Vault", NRUtil.merge({
		"title": "Bio Vault",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Off-site",
		"subtypes": ["Off-site"],
		"text": "Remote server only.\nYou can advance this upgrade.\n[trash], <strong>2 hosted advancement counters:</strong> End the run. Use this ability only during a run."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
		"advanceable": "always",
		"abilities": [
			{
				"label": "End the run",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.getv(state.data, "run"),
				},
				"msg": "end the run",
				"async": true,
				"cost": [NRPayment.to_c("advancement", 2), NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card),
			}
		],
	}))
	NRCardDefs.defcard("Black Level Clearance", NRUtil.merge({
		"title": "Black Level Clearance",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"trash": 1,
		"factioncost": 5,
		"keywords": "Security Protocol",
		"subtypes": ["Security Protocol"],
		"text": "Whenever the Runner makes a successful run on this server, they must either suffer 1 core damage or jack out. If the Runner jacks out this way, gain 5[credit], draw 1 card, and trash this upgrade."
	}, {
		"events": [
			{
				"event": "successful-run",
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"player": "runner",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
				"prompt": "Choose one",
				"waiting-prompt": true,
				"choices": ["Take 1 core damage", "Jack out"],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NRDamage.damage(
						state,
						"runner",
						eid,
						"brain",
						1,
						{
							"card": card,
						}
					) if ((target == "Take 1 core damage") or NRUtil.kw_eq(target, "Take 1 core damage")) else NREid.wait_for(state, eid, func(ne):
						NRRuns.jack_out(state, "runner", ne)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRGaining.gain_credits(state, "corp", ne, 5)
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
								NRDrawing.draw(state, "corp", ne, 1)
							, func(async_result):
								NRSay.system_msg(state, "corp", str("gains 5 [Credits] and draws 1 card. ") + str("Black Level Clearance is trashed"))
								NRMoving.trash(
									state,
									"corp",
									eid,
									card,
									{
										"cause-card": card,
									}
								))))),
			}
		],
	}))
	NRCardDefs.defcard("Brasília Government Grid", NRUtil.merge({
		"title": "Brasília Government Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Once per turn → When you rez a piece of ice during a run against this server, you may derez another installed piece of ice. If you do, the rezzed ice gets +3 strength for the remainder of that run.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return NRCard.ice(NRCardRT.getv(context, "card")) and this_server and run and NRCardRT.some_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
						return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRUtil.same_card(_pct, NRCardRT.getv(context, "card")))))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return (func():
						var rezzed_card = NRCardRT.getv(context, "card")
						return NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"prompt": str("Derez another piece of ice to give ") + str(NRCardRT.getv(rezzed_card, "title")) + str(" +3 strength for the remainder of the run?"),
								"waiting-prompt": true,
								"once": "per-turn",
								"yes-ability": {
									"choices": {
										"card": func(_pct):
											return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and (not NRCardRT.truthy(NRUtil.same_card(_pct, rezzed_card)))),
									},
									"async": true,
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return NREid.wait_for(state, eid, func(ne):
											NRRezzing.derez(state, side, ne, NRCard.get_card(state, target), {
												"msg-keys": {
													"and-then": str(" to give ") + str(NRToString.card_str(state, rezzed_card)) + str(" +3 strength for the remainder of the run"),
												},
											})
										, func(async_result):
											pump_ice(state, side, rezzed_card, 3, "end-of-run")
											NREid.effect_completed(state, side, eid)),
								},
							},
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Breaker Bay Grid", NRUtil.merge({
		"title": "Breaker Bay Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "The rez cost of each card in the root of this server is lowered by 5.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "rez-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return in_same_server(card, target),
				"value": -5,
			}
		],
	}))
	NRCardDefs.defcard("Bryan Stinson", NRUtil.merge({
		"title": "Bryan Stinson",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Character",
		"subtypes": ["Character"],
		"text": "While the Runner has fewer than 6[credit], Bryan Stinson gains \"[click]: Play a <strong>transaction</strong> operation from Archives, ignoring all costs. Remove that <strong>transaction</strong> from the game instead of trashing it.\""
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					var corp = state.player("corp")
					return (NRCardRT.getv(runner, "credit") < 6) and NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return (NRCard.operation(_pct) and NRCard.has_subtype(_pct, "Transaction"))))),
				"label": "Play a transaction operation from Archives, ignoring all costs, and remove it from the game",
				"prompt": "Choose a transaction operation to play",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("play ") + str(NRCardRT.getv(target, "title")) + str(" from Archives, ignoring all costs, and removes it from the game"),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return (NRCard.operation(_pct) and NRCard.has_subtype(_pct, "Transaction"))))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRPlayInstants.play_instant(
						state,
						side,
						eid,
						NRUtil.assoc_in(NRUtil.merge(target, {"rfg-instead-of-trashing": true}), ["special", "rfg-when-trashed"], true),
						{
							"no-additional-cost": true,
							"ignore-cost": true,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Calibration Testing", NRUtil.merge({
		"title": "Calibration Testing",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Off-site",
		"subtypes": ["Off-site"],
		"text": "Remote server only.\n<strong>[trash]:</strong> Place 1 advancement counter on a card installed in the root of this server."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
		"abilities": [
			{
				"label": "Place 1 advancement counter on a card in this server",
				"async": true,
				"fake-cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card in this server",
						"choices": {
							"card": func(_pct):
								return in_same_server(_pct, card),
						},
						"async": true,
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("place an advancement counter on ") + str(NRToString.card_str(state, target)),
						"cost": [NRPayment.to_c("trash-can")],
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
			}
		],
	}))
	NRCardDefs.defcard("Caprice Nisei", NRUtil.merge({
		"title": "Caprice Nisei",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 1,
		"factioncost": 4,
		"keywords": "Clone - Psi",
		"subtypes": ["Clone", "Psi"],
		"text": "Whenever the Runner passes all of the ice protecting this server, you and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, end the run."
	}, {
		"events": [
			{
				"event": "pass-all-ice",
				"psi": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"not-equal": {
						"msg": "end the run",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRRuns.end_run(state, side, eid, card),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Cayambe Grid", NRUtil.merge({
		"title": "Cayambe Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "When your turn begins, place 1 advancement counter on a piece of ice protecting this server.\nWhenever the Runner approaches this server, end the run unless they pay 2[credit] for each advanced piece of ice protecting this server.\nLimit 1 <strong>region</strong> per server."
	}, (func():
		var ability = {
			"interactive": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return (NRCard.ice(_pct) and same_server(card, _pct))))),
			"label": "place 1 advancement counter (start of turn)",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, ({
					"prompt": str("Place 1 advancement counter on an ice protecting ") + str(NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1))),
					"choices": {
						"card": func(_pct):
							return (NRCard.ice(_pct) and same_server(_pct, card)),
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
				} if NRCardRT.truthy(NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return (NRCard.ice(_pct) and same_server(card, _pct)))))) else null), card, null),
		}
		return {
			"events": [
				NRUtil.merge(ability, {"event": "corp-turn-begins"}),
				{
					"event": "approach-server",
					"interactive": func(state, side, eid, card, targets):
						return true,
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, (func():
							var cost = (2 * NRCardRT.count_of(NRCardRT.filter_list(get_run_ices(state), func(_pct):
								return NRCardRT.pos(NRCard.get_counters(_pct, "advancement")))))
							return {
								"async": true,
								"player": "runner",
								"waiting-prompt": true,
								"prompt": "Choose one",
								"choices": [
									(str("Pay ") + str(cost) + str(" [Credits]") if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", cost)])) else null),
									"End the run"
								],
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str((NRCardRT.decapitalize(target) if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else str("force the Runner to ") + str(NRCardRT.decapitalize(target)))),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return (NRRuns.end_run(state, side, eid, card) if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else NREid.wait_for(state, eid, func(ne):
										NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", cost))
									, func(async_result):
										NRSay.system_msg(state, "runner", msg)
										NREid.effect_completed(state, side, eid))),
							}
						).call(), card, null),
				}
			],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("ChiLo City Grid", NRUtil.merge({
		"title": "ChiLo City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"trash": 6,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever there is a successful trace during a run on this server, give the Runner 1 tag.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			NRUtil.merge(NRDefHelpers.give_tags(1), {"event": "successful-trace", "req": func(state, side, eid, card, targets):
				var this_server = NRCardRT.this_server(state, card)
				return this_server})
		],
	}))
	NRCardDefs.defcard("Code Replicator", NRUtil.merge({
		"title": "Code Replicator",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"text": "Whenever the Runner passes a rezzed piece of ice protecting this server, you may trash this upgrade. If you do, the Runner must approach that ice again. They may jack out."
	}, {
		"abilities": [
			{
				"label": "Force the runner to approach the passed piece of ice again",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					var run_position = state.get_in(["run", "position"])
					return this_server and (run_position < NRCardRT.count_of(get_run_ices(state))) and NRCard.rezzed(NRCardRT.get_in(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices"), [NRCardRT.getv(run, "position")], null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, "corp", ne, card, {
							"cause-card": card,
						})
					, func(async_result):
						state.update_in(["run", "position"], func(v): return v)
						NRRuns.set_next_phase(state, "approach-ice")
						NRIce.update_all_ice(state, side)
						NRIce.update_all_icebreakers(state, side)
						NRSay.system_msg(state, "corp", str("trashes ") + str(NRCardRT.getv(card, "title")) + str(" to make the runner approach ") + str(NRCardRT.getv(NRCardRT.get_in(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices"), [NRCardRT.getv(run, "position")], null), "title")) + str(" again"))
						NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, "runner", ne, NRDefHelpers.offer_jack_out(), card, null)
						, func(async_result):
							(NRRuns.start_next_phase(state, side, eid) if (not NRCardRT.truthy(NRCardRT.getv(NRCardRT.getv(state.data, "end-run"), "ended"))) else NREid.effect_completed(state, side, eid)))),
			}
		],
	}))
	NRCardDefs.defcard("Cold Site Server", NRUtil.merge({
		"title": "Cold Site Server",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "<strong>[click]:</strong> Place 1 power counter on this upgrade.\nAs an additional cost to run this server, the Runner must spend [click] and 1[credit] for each hosted power counter.\nWhen your turn begins, remove all hosted power counters."
	}, {
		"static-abilities": [
			{
				"type": "run-additional-cost",
				"req": func(state, side, eid, card, targets):
					return ((NRCardRT.getv(NRCardRT.getv(targets, 1), "server") == unknown_to_kw(NRCard.get_zone(card))) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(targets, 1), "server"), unknown_to_kw(NRCard.get_zone(card)))),
				"value": func(state, side, eid, card, targets):
					return NRCardRT.repeat_n([NRPayment.to_c("credit", 1), NRPayment.to_c("click", 1)], int(NRCard.get_counters(card, "power"))),
			}
		],
		"events": [
			{
				"event": "corp-turn-begins",
				"automatic": "last",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "power")),
				"msg": "remove all hosted power counters",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", (-NRCard.get_counters(card, "power")), null),
			}
		],
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"msg": "place 1 power counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
	}))
	NRCardDefs.defcard("Corporate Troubleshooter", NRUtil.merge({
		"title": "Corporate Troubleshooter",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"text": "<strong>X</strong>[credit], [trash]<strong>:</strong> Choose 1 rezzed piece of ice protecting this server. That ice gets +X strength for the remainder of the turn."
	}, {
		"abilities": [
			{
				"label": "Add strength to a rezzed piece of ice protecting this server",
				"cost": [NRPayment.to_c("trash-can"), NRPayment.to_c("x-credits")],
				"choices": {
					"all": true,
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.ice(target) and NRCard.rezzed(target) and NRServers.protecting_same_server(card, target),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("add ") + str(NRPayment.cost_value(eid, "x-credits")) + str(" strength to ") + str(NRCardRT.getv(target, "title")),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return pump_ice(state, side, target, NRPayment.cost_value(eid, "x-credits"), "end-of-turn"),
			}
		],
	}))
	NRCardDefs.defcard("Crisium Grid", NRUtil.merge({
		"title": "Crisium Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"trash": 5,
		"factioncost": 1,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Runs against this server cannot be declared successful. <em>(This effect does not cause runs to become unsuccessful.)</em>\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "block-successful-run",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"value": true,
			}
		],
	}))
	NRCardDefs.defcard("Cyberdex Virus Suite", NRUtil.merge({
		"title": "Cyberdex Virus Suite",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"trash": 1,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may purge virus counters.\n<strong>[trash]:</strong> Purge virus counters."
	}, (func():
		var resolve_purge = {
			"msg": "purge virus counters",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRPurging.purge(state, side, eid),
		}
		return {
			"flags": {
				"rd-reveal": func(state, side, eid, card, targets):
					return true,
			},
			"poison": true,
			"on-access": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, (resolve_purge if _can_smart_purge(state) else {
						"optional": {
							"waiting-prompt": true,
							"prompt": "Purge virus counters?",
							"yes-ability": resolve_purge,
						},
					}), card, null),
			},
			"abilities": [
				{
					"label": "Purge virus counters",
					"msg": "purge virus counters",
					"cost": [NRPayment.to_c("trash-can")],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRPurging.purge(state, side, eid),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Daniela Jorge Inácio", NRUtil.merge({
		"title": "Daniela Jorge Inácio",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "As an additional cost to trash this upgrade, the Runner must add 2 cards from the grip at random to the bottom of the stack.\nPersistent → As an additional cost to steal an agenda from this server or its root, the Runner must add 2 cards from the grip at random to the bottom of the stack."
	}, (func():
		var steal_cost = {
			"type": "steal-additional-cost",
			"req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (in_same_server(card, target) or from_same_server(card, target)),
			"value": func(state, side, eid, card, targets):
				return NRPayment.to_c("add-random-from-hand-to-bottom-of-deck", 2),
		}
		return {
			"static-abilities": [steal_cost],
			"events": [
				{
					"event": "pre-access-card",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRCard.rezzed(card) and NRUtil.same_card(NRCardRT.getv(context, "accessed-card"), card),
					"effect": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRFlags.register_run_flag(
							state,
							side,
							card,
							"can-trash",
							func(state, _, card):
								return ((not NRCardRT.truthy(NRUtil.same_card(NRCardRT.getv(context, "accessed-card"), card))) or NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("add-random-from-hand-to-bottom-of-deck", 2)]))
						),
				},
				steal_cost
			],
			"on-trash": {
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run and (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"msg": "force the Runner to add 2 random cards from the grip to the bottom of the stack as additional cost to trash it",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var async_result = NREid.result_of(eid)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, "runner", ne, card, [NRPayment.to_c("add-random-from-hand-to-bottom-of-deck", 2)])
					, func(async_result):
						NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
						NREffects.register_lingering_effect(
							state,
							side,
							card,
							NRUtil.merge(steal_cost, {"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (((NRCardRT.getv(card, "previous-zone") == NRCardRT.getv(target, "zone")) or NRUtil.kw_eq(NRCardRT.getv(card, "previous-zone"), NRCardRT.getv(target, "zone"))) or ((central_to_zone(NRCardRT.getv(target, "zone")) == butlast(NRCardRT.getv(card, "previous-zone"))) or NRUtil.kw_eq(central_to_zone(NRCardRT.getv(target, "zone")), butlast(NRCardRT.getv(card, "previous-zone"))))), "duration": "end-of-run"})
						)
						NREid.effect_completed(state, side, eid)),
			},
		}
	).call()))
	NRCardDefs.defcard("Daruma", NRUtil.merge({
		"title": "Daruma",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 3,
		"text": "When the Runner approaches this server, you may trash this upgrade. If you do, choose 1 card in the root of another server or 1 agenda, asset, or upgrade in HQ. Swap that card with 1 card in the root of this server. If you swap cards this way, the Runner may jack out."
	}, (func():
		var choose_swap = func(to_swap):
			return {
			"prompt": str("Choose a card to swap with ") + str(NRCardRT.getv(to_swap, "title")),
			"choices": {
				"not-self": true,
				"card": func(_pct):
					return (NRCard.corp(_pct) and (not NRCardRT.truthy((NRCard.operation(_pct) or NRCard.ice(_pct)))) and (NRCard.in_hand(_pct) or NRCard.installed(_pct))),
			},
			"cost": [NRPayment.to_c("trash-can")],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("swap ") + str(NRToString.card_str(state, to_swap)) + str(" with ") + str(NRToString.card_str(state, target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return swap_cards_async(state, side, eid, to_swap, target),
		}
		var ability = {
			"optional": {
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("Trash ") + str(NRCardRT.getv(card, "title")) + str(" to swap a card in this server?"),
				"yes-ability": {
					"async": true,
					"prompt": "Choose a card in this server to swap",
					"choices": {
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRCard.installed(target) and in_same_server(card, target),
						"not-self": true,
					},
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, choose_swap(target), card, null),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRPrompts.clear_wait_prompt(state, "runner"),
				},
			},
		}
		return {
			"events": [
				{
					"event": "approach-server",
					"interactive": func(state, side, eid, card, targets):
						return true,
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, "corp", ne, ability, card, null)
						, func(async_result):
							NREngine.resolve_ability(state, "runner", eid, NRDefHelpers.offer_jack_out(), card, null)),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Dedicated Technician Team", NRUtil.merge({
		"title": "Dedicated Technician Team",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 0,
		"text": "2[recurring-credit]\nUse these credits to install ice protecting this server."
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (("corp-install" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("corp-install", NRCardRT.getv(eid, "source-type"))) and ((NRCardRT.getv(NRCard.get_zone(card), 1) == unknown_to_kw(NRCardRT.getv(NREid.get_ability_targets(eid), "server"))) or NRUtil.kw_eq(NRCardRT.getv(NRCard.get_zone(card), 1), unknown_to_kw(NRCardRT.getv(NREid.get_ability_targets(eid), "server")))),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Defense Construct", NRUtil.merge({
		"title": "Defense Construct",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 0,
		"factioncost": 3,
		"text": "Defense Construct can be advanced.\n[trash]: Add 1 facedown card from Archives to HQ for each advancement token on Defense Construct. Use this ability only during a run on Archives."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"label": "Add cards from Archives to HQ",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run and ((NRCardRT.getv(run, "server") == ["archives"]) or NRUtil.kw_eq(NRCardRT.getv(run, "server"), ["archives"])) and NRCardRT.pos(NRCard.get_counters(card, "advancement")),
				"cost": [NRPayment.to_c("trash-can")],
				"show-discard": true,
				"choices": {
					"max": func(state, side, eid, card, targets):
						return NRCard.get_counters(card, "advancement"),
					"card": func(_pct):
						return (NRCard.corp(_pct) and (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen"))) and NRCard.in_discard(_pct)),
				},
				"msg": func(state, side, eid, card, targets):
					return str("add ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "facedown card")) + str(" in Archives to HQ"),
				"effect": func(state, side, eid, card, targets):
					return (func():
						for c in NRCardRT.as_array(targets):
							NRMoving.move(state, side, c, "hand")
						return null
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Disposable HQ", NRUtil.merge({
		"title": "Disposable HQ",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 5,
		"factioncost": 1,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may add any number of cards from HQ to the bottom of R&D."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"optional": {
				"waiting-prompt": true,
				"prompt": "Add cards from HQ to the bottom of R&D?",
				"yes-ability": {
					"async": true,
					"msg": "add cards in HQ to the bottom of R&D",
					"effect": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NREngine.resolve_ability(state, side, eid, _dhq_1(1, NRCardRT.count_of(NRCardRT.getv(corp, "hand"))), card, null),
				},
			},
		},
	}))
	NRCardDefs.defcard("Djupstad Grid", NRUtil.merge({
		"title": "Djupstad Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"trash": 4,
		"factioncost": 4,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever you score an agenda from the root of this server, do 1 core damage.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone") == NRCard.get_zone(card)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), NRCard.get_zone(card))),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"brain",
						1,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Drone Screen", NRUtil.merge({
		"title": "Drone Screen",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 4,
		"factioncost": 2,
		"text": "If the Runner is tagged, Drone Screen gains \"Whenever the Runner initiates a run on this server, Trace[3]. If successful, do 1 meat damage (cannot be prevented).\""
	}, {
		"events": [
			{
				"event": "run",
				"async": true,
				"trace": {
					"base": 3,
					"req": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						var this_server = NRCardRT.this_server(state, card)
						return this_server and tagged,
					"successful": {
						"msg": "do 1 meat damage",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(
								state,
								side,
								eid,
								"meat",
								1,
								{
									"card": card,
									"unpreventable": true,
								}
							),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Embolus", NRUtil.merge({
		"title": "Embolus",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 1,
		"text": "When your turn begins, you may pay 1[credit] to place 1 power counter on this upgrade.\nWhenever the Runner makes a successful run, remove 1 power counter from this upgrade.\n<strong>Hosted power counter</strong>: End the run. Use this ability only during a run on this server."
	}, (func():
		var maybe_gain_counter = {
			"once": "per-turn",
			"async": true,
			"label": "Place 1 power counter (start of turn)",
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"prompt": func(state, side, eid, card, targets):
							return str("Pay 1 [Credit] to place 1 power counter on ") + str(NRCardRT.getv(card, "title")) + str("?"),
						"yes-ability": {
							"effect": func(state, side, eid, card, targets):
								return NRProps.add_counter(state, side, eid, card, "power", 1, null),
							"async": true,
							"cost": [NRPayment.to_c("credit", 1)],
							"msg": "place 1 power counter on itself",
						},
					},
				}, card, null),
		}
		var etr = {
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return this_server and run,
			"cost": [NRPayment.to_c("power", 1)],
			"msg": "end the run",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.end_run(state, side, eid, card),
		}
		return {
			"derezzed-events": [NRUtil.merge(NRCardRT.corp_rez_toast, {"event": "runner-turn-ends"})],
			"events": [
				NRUtil.merge(maybe_gain_counter, {"event": "corp-turn-begins"}),
				{
					"event": "successful-run",
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRCard.get_counters(card, "power")),
					"msg": "remove 1 power counter from itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", -1, null),
				}
			],
			"abilities": [maybe_gain_counter, etr],
		}
	).call()))
	NRCardDefs.defcard("Experiential Data", NRUtil.merge({
		"title": "Experiential Data",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 1,
		"text": "All ice protecting this server has +1 strength."
	}, {
		"static-abilities": [
			{
				"type": "ice-strength",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRServers.protecting_same_server(card, target),
				"value": 1,
			}
		],
	}))
	NRCardDefs.defcard("Expo Grid", NRUtil.merge({
		"title": "Expo Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "When your turn begins, gain 1[credit] if there is a rezzed asset installed in the root of this server.\nLimit 1 <strong>region</strong> per server."
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.some_list(NRCardRT.get_in(corp, NRCard.get_zone(card), null), func(_pct):
					return (NRCard.asset(_pct) and NRCard.rezzed(_pct))),
			"msg": "gain 1 [Credits]",
			"once": "per-turn",
			"automatic": "gain-credits",
			"label": "Gain 1 [Credits] (start of turn)",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		}
		return {
			"derezzed-events": [NRUtil.merge(NRCardRT.corp_rez_toast, {"event": "runner-turn-ends"})],
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Forced Connection", NRUtil.merge({
		"title": "Forced Connection",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, Trace[3]. If successful, give the Runner 2 tags."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"trace": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_discard(card))),
				"base": 3,
				"successful": NRDefHelpers.give_tags(2),
			},
		},
	}))
	NRCardDefs.defcard("Flagship", NRUtil.merge({
		"title": "Flagship",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 3,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Ritzy",
		"subtypes": ["Ritzy"],
		"text": "HQ or R&D only.\nRuns against this server cannot be declared successful. <em>(This effect does not cause runs to become unsuccessful.)</em>\nPersistent → During each run against this server, the Runner cannot access more than 1 card other than this upgrade."
	}, (func():
		var other_cards_accessed = func(state, card):
			return NRCardRT.map_list(NRCardRT.filter_list(apply(concat, NREvents.run_events(state, "runner", "access")), func(_pct):
				return (not ((NRCardRT.getv(NRCardRT.getv(_pct, "accessed-card"), "cid") == NRCardRT.getv(card, "cid")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(_pct, "accessed-card"), "cid"), NRCardRT.getv(card, "cid"))))), func(x): return NRCardRT.getv(x, "cid"))
		var prevent_random = {
			"type": "disable-random-accesses",
			"value": true,
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return run and this_server and NRCardRT.seq_of(other_cards_accessed(state, card)),
		}
		var prevent_installed = {
			"type": "disable-access-candidacy",
			"value": true,
			"req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return run and this_server and (not NRCardRT.truthy(NRUtil.same_card(card, target))) and NRCardRT.seq_of(other_cards_accessed(state, card)),
		}
		return {
			"static-abilities": [
				{
					"type": "block-successful-run",
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"value": true,
				},
				prevent_random,
				prevent_installed
			],
			"legal-zones": func(state, side, eid, card, targets):
				return NRCardRT.filter_list(targets, func(x): return NRCardRT.truthy(["R&D", "HQ"].call(x) if ["R&D", "HQ"] is Callable else ["R&D", "HQ"])),
			"on-trash": {
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run and (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					return (func():
						var c = NRCardRT.getv(context, "card")
						NREffects.register_lingering_effect(
							state,
							side,
							NRCardRT.getv(context, "card"),
							{
								"type": "disable-random-accesses",
								"value": true,
								"duration": "end-of-run",
								"req": func(state, side, eid, card, targets):
									var run = state.getv("run")
									return run and ((NRCardRT.getv(run, "server") == [NRCardRT.getv(NRCard.get_zone(c), 1)]) or NRUtil.kw_eq(NRCardRT.getv(run, "server"), [NRCardRT.getv(NRCard.get_zone(c), 1)])) and NRCardRT.seq_of(other_cards_accessed(state, c)),
							}
						)
						return NREffects.register_lingering_effect(
							state,
							side,
							NRCardRT.getv(context, "card"),
							{
								"type": "disable-access-candidacy",
								"value": true,
								"duration": "end-of-run",
								"req": func(state, side, eid, card, targets):
									var run = state.getv("run")
									return run and ((NRCardRT.getv(run, "server") == [NRCardRT.getv(NRCard.get_zone(c), 1)]) or NRUtil.kw_eq(NRCardRT.getv(run, "server"), [NRCardRT.getv(NRCard.get_zone(c), 1)])) and NRCardRT.seq_of(other_cards_accessed(state, c)),
							}
						)
					).call(),
			},
		}
	).call()))
	NRCardDefs.defcard("Fractal Threat Matrix", NRUtil.merge({
		"title": "Fractal Threat Matrix",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Security Protocol",
		"subtypes": ["Security Protocol"],
		"text": "Each time all the subroutines are broken on a piece of ice protecting this server, trash the top 2 cards of the stack."
	}, {
		"events": [
			{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCardRT.getv(context, "all-subs-broken") and NRServers.protecting_same_server(card, NRCardRT.getv(context, "ice")),
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str((func():
						var deck = NRCardRT.getv(runner, "deck")
						return (str("trash ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(deck, int(2)))) + str(" from the stack") if NRCardRT.pos(NRCardRT.count_of(deck)) else "trash no cards from the stack (it is empty)")
					).call()),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.mill(state, "corp", eid, "runner", 2),
			}
		],
	}))
	NRCardDefs.defcard("Ganked!", NRUtil.merge({
		"title": "Ganked!",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may trash it to choose a rezzed piece of ice protecting this server. The Runner encounters that ice."
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
					return str("Trash ") + str(NRCardRT.getv(card, "title")) + str(" to force the Runner to encounter a piece of ice?"),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, ({
							"async": true,
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCard.ice(target) and NRCard.installed(target) and NRCard.rezzed(target) and NRServers.protecting_same_server(card, target),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("force the Runner to encounter ") + str(NRToString.card_str(state, target)),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								(func():
									var target_card = target
									return NREngine.register_events(
										state,
										side,
										card,
										[
											{
												"event": "post-access-card",
												"duration": "end-of-run",
												"unregister-once-resolved": true,
												"async": true,
												"effect": func(state, side, eid, card, targets):
													return NRRuns.force_ice_encounter(state, side, eid, target_card),
											}
										]
									)
								).call()
								return NRMoving.trash(
									state,
									side,
									eid,
									NRUtil.merge(card, {"seen": true}),
									{
										"unpreventable": true,
										"cause-card": card,
									}
								),
						} if NRCardRT.some_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
							return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and NRServers.protecting_same_server(card, _pct))) else {
							"async": true,
							"msg": "trash itself",
							"effect": func(state, side, eid, card, targets):
								return NRMoving.trash(
									state,
									side,
									eid,
									NRUtil.merge(card, {"seen": true}),
									{
										"unpreventable": true,
										"cause-card": card,
									}
								),
						}), card, null),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
	}))
	NRCardDefs.defcard("Georgia Emelyov", NRUtil.merge({
		"title": "Georgia Emelyov",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever the Runner makes an unsuccessful run on this server, do 1 net damage.\n2[credit]: Move Georgia Emelyov to another server."
	}, {
		"events": [
			{
				"event": "unsuccessful-run",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return ((NRServers.target_server(target) == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRServers.target_server(target), NRCardRT.getv(NRCard.get_zone(card), 1))),
				"async": true,
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
		],
		"abilities": [
			{
				"cost": [NRPayment.to_c("credit", 2)],
				"label": "Move to another server",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a server",
						"choices": NRBoard.server_list(state),
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("move to ") + str(target),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (func():
								var c = NRMoving.move(state, side, card, (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["content"]))
								NREngine.unregister_events(state, side, card)
								return NREngine.register_default_events(state, side, c)
							).call(),
					}, card, null),
			}
		],
	}))
	NRCardDefs.defcard("Giordano Memorial Field", NRUtil.merge({
		"title": "Giordano Memorial Field",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "Whenever the Runner makes a successful run on this server, end the run unless they pay 2[credit] for each agenda in their score area."
	}, {
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return (func():
						var credit_cost = (2 * NRCardRT.count_of(NRCardRT.getv(runner, "scored")))
						return NREngine.resolve_ability(state, side, eid, {
							"player": "runner",
							"async": true,
							"waiting-prompt": true,
							"prompt": "Choose one",
							"choices": [
								(str("Pay ") + str(credit_cost) + str(" [Credits]") if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, NRPayment.to_c("credit", credit_cost))) else null),
								"End the run"
							],
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str((NRCardRT.decapitalize(target) if (("End the run" == target) or NRUtil.kw_eq("End the run", target)) else str("force the runner to ") + str(NRCardRT.decapitalize(target)))),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (NRRuns.end_run(state, "corp", eid, card) if (("End the run" == target) or NRUtil.kw_eq("End the run", target)) else NREid.wait_for(state, eid, func(ne):
									NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", credit_cost))
								, func(async_result):
									NRSay.system_msg(state, "runner", msg)
									NREid.effect_completed(state, side, eid))),
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Heinlein Grid", NRUtil.merge({
		"title": "Heinlein Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever the Runner loses or spends [click] during a run on this server, they lose all credits in their credit pool.\nLimit 1 <strong>region</strong> per server."
	}, {
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"label": "Force the Runner to lose all [Credits] from spending or losing a [Click]",
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str("force the Runner to lose all ") + str(NRCardRT.getv(runner, "credit")) + str(" [Credits]"),
				"once": "per-run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose_credits(state, "runner", eid, "all"),
			}
		],
	}))
	NRCardDefs.defcard("Helheim Servers", NRUtil.merge({
		"title": "Helheim Servers",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "<strong>Trash 1 card from HQ</strong>: All ice protecting this server has +2 strength until the end of the run. Use this ability only during a run on this server."
	}, {
		"abilities": [
			{
				"label": "All ice protecting this server has +2 strength until the end of the run",
				"msg": "increase the strength of all ice protecting this server until the end of the run",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return this_server and run and NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
				"cost": [NRPayment.to_c("trash-from-hand", 1)],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "ice-strength",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRServers.protecting_same_server(card, target),
							"value": 2,
						}
					)
					return NRIce.update_all_ice(state, side),
				"keep-menu-open": "while-cards-in-hand",
			}
		],
	}))
	NRCardDefs.defcard("Henry Phillips", NRUtil.merge({
		"title": "Henry Phillips",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever the Runner breaks a subroutine during a run on this server, gain 2[credit] if they are tagged."
	}, {
		"events": [
			{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					var this_server = NRCardRT.this_server(state, card)
					return this_server and tagged,
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("gain ") + str((2 * NRCardRT.count_of(NRCardRT.getv(context, "broken-subs")))) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return _hp_gain_credits_2(state, "corp", eid, NRCardRT.count_of(NRCardRT.getv(context, "broken-subs"))),
			}
		],
	}))
	NRCardDefs.defcard("Hired Help", NRUtil.merge({
		"title": "Hired Help",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Orgcrime - Enforcer",
		"subtypes": ["Orgcrime", "Enforcer"],
		"text": "As an additional cost to run this server, the Runner must trash 1 agenda from their score area. Ignore this ability if the Runner made a successful run on HQ this turn.\nLimit 1 per deck."
	}, (func():
		var prompt_to_trash_agenda_or_etr = {
			"prompt": "Choose one",
			"waiting-prompt": true,
			"player": "runner",
			"choices": ["Trash 1 scored agenda", "End the run"],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return ((func():
					NRSay.system_msg(state, "runner", str("declines to pay the additional cost from ") + str(NRCardRT.getv(card, "title")))
					return NRRuns.end_run(state, side, eid, card)
				).call() if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else (NREngine.resolve_ability(state, "runner", eid, {
					"prompt": "Choose an Agenda to trash",
					"async": true,
					"choices": {
						"max": 1,
						"card": func(_pct):
							return is_scored(state, side, _pct),
					},
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, side, ne, target, {
								"unpreventable": true,
								"cause-card": card,
								"cause": "forced-to-trash",
							})
						, func(async_result):
							NRSay.system_msg(state, "runner", str("trashes ") + str(NRCardRT.getv(target, "title")) + str(" as an additional cost to initiate a run"))
							NREid.effect_completed(state, side, eid)),
				}, card, null) if NRCardRT.seq_of(NRCardRT.getv(runner, "scored")) else (func():
					NRSay.system_msg(state, "runner", str("cannot pay the additional cost from ") + str(NRCardRT.getv(card, "title")))
					return NRRuns.end_run(state, side, eid, card)
				).call())),
		}
		return {
			"events": [
				{
					"event": "run",
					"async": true,
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						var runner_reg = state.get_in(["runner", "register"])
						return this_server and NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.getv(runner_reg, "successful-run"), func(x): return NRCardRT.truthy(["hq"].call(x) if ["hq"] is Callable else ["hq"]))),
					"effect": func(state, side, eid, card, targets):
						return NREngine.resolve_ability(state, "runner", eid, prompt_to_trash_agenda_or_etr, card, null),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Hokusai Grid", NRUtil.merge({
		"title": "Hokusai Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever the Runner makes a successful run on this server, do 1 net damage.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			NRUtil.merge(NRDefHelpers.do_net_damage(1), {"event": "successful-run", "req": func(state, side, eid, card, targets):
				var this_server = NRCardRT.this_server(state, card)
				return this_server})
		],
	}))
	NRCardDefs.defcard("Hype Machine", NRUtil.merge({
		"title": "Hype Machine",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "As long as an agenda was scored or stolen this turn, the rez cost of this upgrade is lowered by 6[credit].\n[trash]<strong>:</strong> Place 1 advancement counter on a card you can advance in the root of this server."
	}, {
		"rez-cost-bonus": func(state, side, eid, card, targets):
			return (-6 if not NRCardRT.truthy((NREvents.no_event(state, side, "agenda-scored") and NREvents.no_event(state, side, "agenda-stolen"))) else 0),
		"abilities": [
			{
				"label": "Place 1 advancement token on a card in this server",
				"async": true,
				"prompt": "Choose a card in this server",
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return in_same_server(card, target),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place an advancement token on ") + str(NRToString.card_str(state, target)),
				"cost": [NRPayment.to_c("trash-can")],
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
	NRCardDefs.defcard("Increased Drop Rates", NRUtil.merge({
		"title": "Increased Drop Rates",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, remove 1 bad publicity unless they take 1 tag."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"poison": true,
		"on-access": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"player": "runner",
			"async": true,
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(("remove 1 bad publicity" if ((target == "The Corp removes 1 bad publicity") or NRUtil.kw_eq(target, "The Corp removes 1 bad publicity")) else str("force the Runner to ") + str(NRCardRT.decapitalize(target)))),
			"prompt": "Choose one",
			"choices": ["Take 1 tag", "The Corp removes 1 bad publicity"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRTags.gain_tags(
					state,
					side,
					eid,
					1,
					{
						"unpreventable": true,
					}
				) if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else (func():
					NRBadPublicity.lose_bad_publicity(state, "corp", 1)
					return NREid.effect_completed(state, side, eid)
				).call()),
		},
	}))
	NRCardDefs.defcard("Intake", NRUtil.merge({
		"title": "Intake",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 3,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, Trace[4]. If successful, add 1 installed program or <strong>virtual</strong> resource to the grip."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"trace": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_discard(card))),
				"base": 4,
				"label": "add an installed program or virtual resource to the Grip",
				"successful": {
					"waiting-prompt": true,
					"prompt": "Choose a program or virtual resource",
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and (NRCard.program(_pct) or (NRCard.resource(_pct) and NRCard.has_subtype(_pct, "Virtual")))),
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("move ") + str(NRCardRT.getv(target, "title")) + str(" to the Grip"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						NRMoving.move(state, "runner", target, "hand")
						return NREid.effect_completed(state, side, eid),
				},
			},
		},
	}))
	NRCardDefs.defcard("Isaac Liberdade", NRUtil.merge({
		"title": "Isaac Liberdade",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 3,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Bioroid - Sysop",
		"subtypes": ["Bioroid", "Sysop"],
		"text": "Each advanced piece of ice protecting this server gets +2 strength.\nWhenever this upgrade moves to the root of a server, you may place 1 advancement counter on a piece of ice protecting that server that has no advancement counters.\nWhen your turn ends, you may move this upgrade to the root of another server."
	}, (func():
		var ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_installed_corp(state), func(_pct):
					return (NRCard.ice(_pct) and NRCardRT.zero(NRCard.get_counters(_pct, "advancement")) and same_server(card, _pct))),
			"prompt": "Choose a piece of ice protecting this server",
			"waiting-prompt": true,
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRCardRT.zero(NRCard.get_counters(target, "advancement")) and same_server(target, card),
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
		}
		return {
			"static-abilities": [
				{
					"type": "ice-strength",
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.ice(target) and ((NRBoard.card_to_server(state, card) == NRBoard.card_to_server(state, target)) or NRUtil.kw_eq(NRBoard.card_to_server(state, card), NRBoard.card_to_server(state, target))),
					"value": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (2 if NRCardRT.pos(NRCard.get_counters(target, "advancement")) else 0),
				}
			],
			"events": [_mobile_sysop_event("corp-turn-ends", ability)],
		}
	).call()))
	NRCardDefs.defcard("Jinja City Grid", NRUtil.merge({
		"title": "Jinja City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever you draw a piece of ice, you may reveal it and install it protecting this server, paying 4[credit] less.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "corp-draw",
				"once": "per-turn",
				"once-key": "jinja-city-grid-draw",
				"async": true,
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRFinding.find_cid(NRCardRT.getv(card, "cid"), NRCardRT.concat_lists(NRCardRT.as_array((state.get_in(["trash", "trash-list"], null) as Dictionary).values()))))),
				"effect": func(state, side, eid, card, targets):
					return ((func():
						var ices = NRCardRT.filter_list(corp_currently_drawing, func(_pct):
							return (NRCard.ice(_pct) and NRCard.get_card(state, _pct)))
						var grids = filterv(
							func(_pct):
								return ((NRCardRT.getv(card, "title") == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(NRCardRT.getv(card, "title"), NRCardRT.getv(_pct, "title"))),
							NRBoard.all_active_installed(state, "corp")
						)
						return NREngine.resolve_ability(state, side, eid, (_choose_ice_5(ices, grids) if NRCardRT.truthy(NRCardRT.seq_of(ices)) else null), card, null)
					).call() if NRCardRT.truthy(NRCardRT.some_list(corp_currently_drawing, NRCard.ice)) else NREngine.resolve_ability(state, "corp", eid, {
						"prompt": "You did not draw any ice",
						"choices": ["Carry on!"],
						"prompt-type": "bogus",
					}, card, null)),
			},
			{
				"event": "post-corp-draw",
				"effect": func(state, side, eid, card, targets):
					return null,
			}
		],
	}))
	NRCardDefs.defcard("K. P. Lynn", NRUtil.merge({
		"title": "K. P. Lynn",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Whenever the Runner passes all of the ice protecting this server, they must take 1 tag or end the run."
	}, {
		"events": [
			{
				"event": "pass-all-ice",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"player": "runner",
				"waiting-prompt": true,
				"prompt": "Choose one",
				"choices": ["Take 1 tag", "End the run"],
				"async": true,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str((NRCardRT.decapitalize(target) if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else str("force the Runner to ") + str(NRCardRT.decapitalize(target)))),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NRTags.gain_tags(state, "runner", eid, 1) if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else NRRuns.end_run(state, side, eid, card)),
			}
		],
	}))
	NRCardDefs.defcard("Keegan Lane", NRUtil.merge({
		"title": "Keegan Lane",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "[trash], <strong>remove 1 tag:</strong> Trash 1 program. Use this ability only during a run on this server."
	}, {
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server and (NRCardRT.getv(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.program), 0) != null),
				"prompt": "Choose a program to trash",
				"label": "Trash a program",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.program(_pct)),
				},
				"cost": [NRPayment.to_c("tag", 1), NRPayment.to_c("trash-can")],
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
			}
		],
	}))
	NRCardDefs.defcard("Khondi Plaza", NRUtil.merge({
		"title": "Khondi Plaza",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 3,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Ritzy",
		"subtypes": ["Ritzy"],
		"text": "X[recurring-credit]\nUse these credits to rez ice protecting this server. X is the number of remote servers."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			return NRCardRT.count_of(NRBoard.get_remotes(state)),
		"recurring": NRCardRT.get_x_fn(),
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (("rez" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("rez", NRCardRT.getv(eid, "source-type"))) and NRCard.ice(target) and same_server(card, target),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("La Costa Grid", NRUtil.merge({
		"title": "La Costa Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Region - Seedy",
		"subtypes": ["Region", "Seedy"],
		"text": "Remote server only.\nWhen your turn begins, place 1 advancement counter on a card in the root of this server.\nLimit 1 <strong>region</strong> per server."
	}, (func():
		var ability = {
			"prompt": func(state, side, eid, card, targets):
				return str("Choose a card in ") + str(NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1))),
			"label": "Place 1 advancement counter (start of turn)",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target) and in_same_server(card, target),
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
		}
		return {
			"legal-zones": func(state, side, eid, card, targets):
				return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
			"derezzed-events": [NRCardRT.corp_rez_toast],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Letheia Nisei", NRUtil.merge({
		"title": "Letheia Nisei",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Psi - Clone",
		"subtypes": ["Psi", "Clone"],
		"text": "The first time the Runner approaches this server during each run, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, you may trash this upgrade. If you do, the Runner moves to the outermost position of this server. They may jack out."
	}, {
		"events": [
			{
				"event": "approach-server",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"psi": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"once": "per-run",
					"not-equal": {
						"optional": {
							"waiting-prompt": true,
							"prompt": func(state, side, eid, card, targets):
								return str("Trash ") + str(NRCardRT.getv(card, "title")) + str(" to force the Runner to approach the outermost piece of ice?"),
							"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
							"yes-ability": {
								"async": true,
								"msg": "force the Runner to approach the outermost piece of ice",
								"effect": func(state, side, eid, card, targets):
									return NREid.wait_for(state, eid, func(ne):
										NRMoving.trash(state, side, ne, card, {
											"unpreventable": true,
											"cause-card": card,
										})
									, func(async_result):
										NRRuns.redirect_run(state, side, NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1)), "approach-ice")
										NREngine.resolve_ability(state, "runner", eid, NRDefHelpers.offer_jack_out(), card, null)),
							},
						},
					},
				},
			}
		],
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "Letheia Nisei")],
	}))
	NRCardDefs.defcard("Mahkota Langit Grid", NRUtil.merge({
		"title": "Mahkota Langit Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "2[recurring-credit] <em>(When you rez this upgrade and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to rez assets in the root of this server and ice protecting this server.\nPersistent → The trash cost of each asset in the root of this server is increased by 2[credit].\nLimit 1 <strong>region</strong> per server."
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (("rez" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("rez", NRCardRT.getv(eid, "source-type"))) and (NRCard.ice(target) or NRCard.asset(target)) and same_server(card, target),
				"type": "recurring",
			},
		},
		"static-abilities": [
			{
				"type": "trash-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target) and NRCard.asset(target) and same_server(card, target),
				"value": 2,
			}
		],
		"on-trash": {
			"req": func(state, side, eid, card, targets):
				return (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCardRT.getv(state.data, "run"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var run = state.getv("run")
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "trash-cost",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var run = state.getv("run")
							return run and (((NRCardRT.getv(card, "previous-zone") == NRCardRT.getv(target, "zone")) or NRUtil.kw_eq(NRCardRT.getv(card, "previous-zone"), NRCardRT.getv(target, "zone"))) or ((central_to_zone(NRCardRT.getv(target, "zone")) == butlast(NRCardRT.getv(card, "previous-zone"))) or NRUtil.kw_eq(central_to_zone(NRCardRT.getv(target, "zone")), butlast(NRCardRT.getv(card, "previous-zone"))))) and NRCard.asset(target),
						"value": 2,
					}
				),
		},
	}))
	NRCardDefs.defcard("Malapert Data Vault", NRUtil.merge({
		"title": "Malapert Data Vault",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 1,
		"trash": 4,
		"factioncost": 3,
		"text": "Whenever you score an agenda from the root of this server, you may search R&D for 1 non-agenda card and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that card to HQ."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"prompt": "Search R&D for non-agenda card?",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone") == NRCard.get_zone(card)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), NRCard.get_zone(card))),
					"yes-ability": {
						"prompt": "Choose a card",
						"choices": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
								return (not NRCardRT.truthy(NRCard.agenda(_pct)))))),
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to HQ"),
						"async": true,
						"cancel": NRShuffling.shuffle_deck,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, target)
							, func(async_result):
								NRShuffling.shuffle_zone(state, side, "deck")
								NRMoving.move(state, side, target, "hand")
								NREid.effect_completed(state, side, eid)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Manegarm Skunkworks", NRUtil.merge({
		"title": "Manegarm Skunkworks",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 3,
		"text": "Whenever the Runner approaches this server, end the run unless they either spend [click][click] or pay 5[credit]."
	}, {
		"events": [
			{
				"event": "approach-server",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"player": "runner",
				"prompt": "Choose one",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"choices": func(state, side, eid, card, targets):
					return [
						("Spend [Click][Click]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("click", 2)])) else null),
						("Pay 5 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 5)])) else null),
						"End the run"
					],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, side, ne, card, NRPayment.to_c("click", 2))
					, func(async_result):
						NRSay.system_msg(state, side, msg)
						NREid.effect_completed(state, "runner", eid)) if NRCardRT.truthy((((target == "Spend [Click][Click]") or NRUtil.kw_eq(target, "Spend [Click][Click]")) and NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("click", 2)]))) else (NREid.wait_for(state, eid, func(ne):
							NREngine.pay(state, side, ne, card, NRPayment.to_c("credit", 5))
					, func(async_result):
						NRSay.system_msg(state, side, msg)
						NREid.effect_completed(state, "runner", eid)) if NRCardRT.truthy((((target == "Pay 5 [Credits]") or NRUtil.kw_eq(target, "Pay 5 [Credits]")) and NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 5)]))) else NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to end the run")))),
			}
		],
	}))
	NRCardDefs.defcard("Manta Grid", NRUtil.merge({
		"title": "Manta Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "If the Runner has fewer than 6[credit] or no unspent clicks when a successful run on this server ends, you have 1 additional [click] to spend your next turn.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "run-ends",
				"msg": "gain a [Click] next turn",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return NRCardRT.getv(target, "successful") and ((NRServers.target_server(target) == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRServers.target_server(target), NRCardRT.getv(NRCard.get_zone(card), 1))) and ((NRCardRT.getv(runner, "credit") < 6) or NRCardRT.zero(NRCardRT.getv(runner, "click"))),
				"effect": func(state, side, eid, card, targets):
					return state.update_in(["corp", "extra-click-temp"], func(v): return v),
			}
		],
	}))
	NRCardDefs.defcard("Marcus Batty", NRUtil.merge({
		"title": "Marcus Batty",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 1,
		"factioncost": 3,
		"keywords": "Sysop - Psi",
		"subtypes": ["Sysop", "Psi"],
		"text": "[trash]: You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, resolve 1 subroutine on a rezzed piece of ice protecting this server. Use this ability only during a run on this server."
	}, {
		"abilities": [
			{
				"label": "Start a Psi game to resolve a subroutine",
				"cost": [NRPayment.to_c("trash-can")],
				"psi": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"not-equal": {
						"prompt": "Choose a piece of ice",
						"choices": {
							"card": func(_pct):
								return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
							"all": true,
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREngine.resolve_ability(state, side, eid, (func():
								var ice = target
								return {
									"prompt": "Choose a subroutine",
									"choices": func(state, side, eid, card, targets):
										return NRIce.unbroken_subroutines_choice(ice),
									"msg": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return str("resolve the subroutine (\"[subroutine] ") + str(target) + str("\") from ") + str(NRCardRT.getv(ice, "title")),
									"async": true,
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return (func():
											var sub = NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(ice, "subroutines"), func(_pct):
												return ((target == NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))) or NRUtil.kw_eq(target, NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))))), 0)
											return NRIce.resolve_subroutine(state, side, eid, ice, NRUtil.merge(sub, {"external-trigger": true}))
										).call(),
								}
							).call(), card, null),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Mason Bellamy", NRUtil.merge({
		"title": "Mason Bellamy",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever an encounter with a piece of ice protecting this server ends, if the Runner broke at least 1 subroutine during that encounter, they lose [click]."
	}, {
		"events": [
			{
				"event": "end-of-encounter",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var this_server = NRCardRT.this_server(state, card)
					return this_server and NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return NRCardRT.getv(x, "broken"))),
				"msg": "force the Runner to lose [Click]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose_clicks(state, "runner", 1),
			}
		],
	}))
	NRCardDefs.defcard("Mavirus", NRUtil.merge({
		"title": "Mavirus",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 0,
		"factioncost": 1,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may purge virus counters. If this upgrade is rezzed, do 1 net damage.\n[trash]<strong>:</strong> Purge virus counters."
	}, (func():
		var resolve_purge = {
			"msg": func(state, side, eid, card, targets):
				return str("purge virus counters"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRPurging.purge(state, side, ne)
				, func(async_result):
					((func():
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to do 1 net damage"))
						return NRDamage.damage(
							state,
							side,
							eid,
							"net",
							1,
							{
								"card": card,
							}
						)
					).call() if NRCard.rezzed(card) else NREid.effect_completed(state, side, eid))),
		}
		return {
			"flags": {
				"rd-reveal": func(state, side, eid, card, targets):
					return true,
			},
			"poison": true,
			"on-access": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, (resolve_purge if _can_smart_purge(state) else {
						"optional": {
							"waiting-prompt": true,
							"prompt": "Purge virus counters?",
							"yes-ability": resolve_purge,
							"no-ability": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title")))
									return ((func():
										NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to do 1 net damage"))
										return NRDamage.damage(
											state,
											side,
											eid,
											"net",
											1,
											{
												"card": card,
											}
										)
									).call() if NRCard.rezzed(card) else NREid.effect_completed(state, side, eid)),
							},
						},
					}), card, null),
			},
			"abilities": [
				{
					"label": "Purge virus counters",
					"msg": "purge virus counters",
					"cost": [NRPayment.to_c("trash-can")],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRPurging.purge(state, side, eid),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Mercia B4LL4RD", NRUtil.merge({
		"title": "Mercia B4LL4RD",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Bioroid - Academic",
		"subtypes": ["Bioroid", "Academic"],
		"text": "When your action phase ends, you may install 1 piece of ice from HQ, paying 1[credit] less. If you do, move this upgrade to the root of the server that piece of ice is protecting."
	}, {
		"events": [
			{
				"event": "corp-action-phase-ends",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				"prompt": "Install an ice, paying 1 [Credits] less",
				"waiting-prompt": true,
				"choices": {
					"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.in_hand(x))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRInstalling.corp_install(state, side, ne, target, null, {
							"cost-bonus": -1,
							"msg-keys": {
								"install-source": card,
							},
						})
					, func(moved_card):
						update_hand_size(state, "corp")
						((func():
							var target_server = NRCardRT.getv(NRCardRT.getv(moved_card, "zone"), 1)
							var target_zone = ["servers", NRServers.target_server, "content"]
							var target_name = NRServers.zone_to_name(NRServers.target_server)
							return (NREngine.resolve_ability(state, side, eid, {
								"msg": func(state, side, eid, card, targets):
									return str("move itself to ") + str(target_name),
								"effect": func(state, side, eid, card, targets):
									NREngine.unregister_events(state, side, card)
									return (func():
										var c = NRMoving.move(state, side, card, target_zone)
										return NREngine.register_default_events(state, side, c)
									).call(),
							}, card, null) if not NRCardRT.truthy(same_server(moved_card, card)) else NREid.effect_completed(state, side, eid))
						).call() if moved_card else NREid.effect_completed(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Midori", NRUtil.merge({
		"title": "Midori",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever the Runner approaches a piece of ice protecting this server, you may swap that ice with 1 piece of ice from HQ. <em>(The new ice is installed unrezzed.)</em> If you do, the Runner may jack out. Use this ability only once per run."
	}, {
		"events": [
			{
				"event": "approach-ice",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				},
				"optional": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"once": "per-run",
					"prompt": "Swap the piece of ice being approached with a piece of ice from HQ?",
					"yes-ability": {
						"async": true,
						"prompt": "Choose a piece of ice",
						"choices": {
							"card": func(_pct):
								return (NRCard.ice(_pct) and NRCard.in_hand(_pct)),
						},
						"msg": func(state, side, eid, card, targets):
							var current_ice = NRIce.get_current_ice(state)
							return str("swap ") + str(NRToString.card_str(state, current_ice)) + str(" with a piece of ice from HQ"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var current_ice = NRIce.get_current_ice(state)
							return NREid.wait_for(state, eid, func(ne):
								swap_cards_async(state, "corp", ne, current_ice, target)
							, func(async_result):
								NREngine.resolve_ability(state, "runner", eid, NRDefHelpers.offer_jack_out(), card, null)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Midway Station Grid", NRUtil.merge({
		"title": "Midway Station Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"trash": 4,
		"factioncost": 4,
		"keywords": "Beanstalk - Region",
		"subtypes": ["Beanstalk", "Region"],
		"text": "During runs on this server, the Runner must pay 1[credit] as an additional cost to use an <strong>icebreaker</strong> ability to break subroutines.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "break-sub-additional-cost",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var this_server = NRCardRT.this_server(state, card)
					return NRCard.has_subtype(NRCardRT.getv(context, "card"), "Icebreaker") and NRCardRT.as_array(NRCardRT.getv(context, "ability")).has("break") and NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(NRCardRT.getv(context, "ability"), "broken-subs"))) and this_server,
				"value": NRPayment.to_c("credit", 1),
			}
		],
	}))
	NRCardDefs.defcard("Mitra Aman", NRUtil.merge({
		"title": "Mitra Aman",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 0,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "Whenever the Runner approaches a piece of ice protecting this server, you may trash this upgrade. If you do, gain 3[credit] and you may swap the ice being approached with a piece of ice from Archives or HQ."
	}, {
		"events": [
			{
				"event": "approach-ice",
				"skippable": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server,
					"prompt": "Trash Mitra Aman to gain 3 [Credits]?",
					"waiting-prompt": true,
					"yes-ability": {
						"cost": [NRPayment.to_c("trash-can", 1)],
						"msg": "gain 3 [Credits]",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRGaining.gain_credits(state, side, ne, 3)
							, func(async_result):
								NREngine.resolve_ability(state, side, eid, {
									"async": true,
									"show-discard": true,
									"prompt": "Swap the approached ice with another ice?",
									"choices": {
										"card": func(_pct):
											return (NRCard.ice(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
									},
									"msg": {
										"public": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return str("swap ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str(" with ") + str(NRToString.card_str(state, target)),
										"corp": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return str("swap ") + str(NRToString.card_str(
												state,
												NRIce.get_current_ice(state),
												{
													"maybe-visible": true,
												}
											)) + str(" with ") + str(NRToString.card_str(
												state,
												target,
												{
													"maybe-visible": true,
												}
											)),
									},
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return (func():
											var approached_ice = NRIce.get_current_ice(state)
											return swap_cards_async(state, side, eid, approached_ice, target)
										).call(),
								}, card, null)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Mr. Hendrik", NRUtil.merge({
		"title": "Mr. Hendrik",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Ambush - Sysop",
		"subtypes": ["Ambush", "Sysop"],
		"text": "When the Runner accesses this upgrade while it is installed, you may pay 2[credit] to do 1 core damage. If the Runner has any [click] remaining, they may lose all their [click] to prevent this damage."
	}, installed_access_trigger(
		2,
		{
			"async": true,
			"msg": "force the Runner to suffer a core damage or lose all remaining [Click]",
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return NREngine.resolve_ability(state, side, eid, {
					"player": "runner",
					"prompt": "Choose one",
					"waiting-prompt": true,
					"choices": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return [
							"Suffer 1 core damage",
							("Lose all remaining [Click]" if NRCardRT.truthy(NRCardRT.pos(NRCardRT.getv(runner, "click"))) else null)
						],
					"async": true,
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str(("do 1 core damage" if ((target == "Suffer 1 core damage") or NRUtil.kw_eq(target, "Suffer 1 core damage")) else str("force the Runner to ") + str(NRCardRT.decapitalize(target)))),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var runner = state.player("runner")
						return (NRDamage.damage(
							state,
							"corp",
							eid,
							"brain",
							1,
							{
								"card": card,
							}
						) if ((target == "Suffer 1 core damage") or NRUtil.kw_eq(target, "Suffer 1 core damage")) else (func():
							NRGaining.lose_clicks(state, "runner", NRCardRT.getv(runner, "click"))
							return NREid.effect_completed(state, side, eid)
						).call()),
				}, card, null),
		}
	)))
	NRCardDefs.defcard("Mumbad City Grid", NRUtil.merge({
		"title": "Mumbad City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever the Runner passes a piece of ice protecting this server, you may swap that ice with another piece of ice protecting this server.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					var run_ices = NRIce.get_run_ices(state)
					return this_server and (2 <= NRCardRT.count_of(run_ices)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					return NREngine.resolve_ability(state, side, eid, (func():
						var passed_ice = NRCardRT.getv(context, "ice")
						return {
							"prompt": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("Choose a piece of ice to swap with ") + str(NRCardRT.getv(target, "title")),
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									var run = state.getv("run")
									return NRCard.installed(target) and NRCard.ice(target) and ((NRServers.target_server(run) == NRCardRT.getv(NRCard.get_zone(target), 1)) or NRUtil.kw_eq(NRServers.target_server(run), NRCardRT.getv(NRCard.get_zone(target), 1))) and (not NRCardRT.truthy(NRUtil.same_card(target, passed_ice))),
							},
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRMoving.swap_ice(state, side, target, passed_ice),
						}
					).call(), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Mumbad Virtual Tour", NRUtil.merge({
		"title": "Mumbad Virtual Tour",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Alliance",
		"subtypes": ["Alliance"],
		"text": "This upgrade costs 0 influence if you have 7 or more assets in your deck.\nWhen the Runner accesses this upgrade while it is installed, they must trash it, if able."
	}, {
		"flags": {
			"must-trash": func(state, side, eid, card, targets):
				var installed = NRCard.installed(card) if card is Dictionary else false
				return (true if NRCardRT.truthy(installed) else null),
		},
	}))
	NRCardDefs.defcard("Mwanza City Grid", NRUtil.merge({
		"title": "Mwanza City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 5,
		"factioncost": 1,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Root of HQ or R&D only.\nWhenever the Runner breaches this server, they access 3 additional cards. When the breach ends, gain 2[credit] for each time the Runner accessed a card during that breach.\nLimit 1 <strong>region</strong> per server."
	}, (func():
		var mwanza_gain_creds = {
			"event": "end-breach-server",
			"duration": "end-of-run",
			"silent": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"unregister-once-resolved": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var accessed_cards = reduce(_, (NRCardRT.getv(target, "cards-accessed") as Dictionary).values())
					return (func():
						NRSay.system_msg(state, "corp", str("gains ") + str((2 * accessed_cards)) + str(" [Credits] from ") + str(NRCardRT.getv(card, "title")))
						return NRGaining.gain_credits(state, "corp", eid, (2 * accessed_cards))
				).call() if accessed_cards != null and NRCardRT.truthy(accessed_cards) else NREid.effect_completed(state, side, eid)
				).call(),
		}
		var unboost_access = func(bonus_server):
			return {
			"event": "end-breach-server",
			"duration": "end-of-run",
			"req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return ((NRCardRT.getv(target, "from-server") == bonus_server) or NRUtil.kw_eq(NRCardRT.getv(target, "from-server"), bonus_server)),
			"unregister-once-resolved": true,
			"effect": func(state, side, eid, card, targets):
				return NRAccess.access_bonus(state, "runner", bonus_server, -3),
		}
		var boost_access_when_trashed = func(bonus_server):
			return {
			"event": "breach-server",
			"duration": "end-of-run",
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return ((NRCardRT.getv(context, "server") == bonus_server) or NRUtil.kw_eq(NRCardRT.getv(context, "server"), bonus_server)),
			"msg": "force the runner to access 3 additional cards",
			"effect": func(state, side, eid, card, targets):
				NRAccess.access_bonus(state, "runner", bonus_server, 3)
				return NREngine.register_events(state, side, card, [mwanza_gain_creds, unboost_access(bonus_server)]),
		}
		var boost_access_by_3 = {
			"event": "breach-server",
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return ((NRCardRT.getv(context, "server") == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRCardRT.getv(context, "server"), NRCardRT.getv(NRCard.get_zone(card), 1))),
			"msg": "force the Runner to access 3 additional cards",
			"effect": func(state, side, eid, card, targets):
				return (func():
					var bonus_server = NRCardRT.getv(NRCardRT.getv(card, "zone"), 1)
					NRAccess.access_bonus(state, "runner", bonus_server, 3)
					return NREngine.register_events(state, side, card, [mwanza_gain_creds, unboost_access(bonus_server)])
				).call(),
		}
		return {
			"install-req": func(state, side, eid, card, targets):
				return NRCardRT.filter_list(targets, func(x): return NRCardRT.truthy(["HQ", "R&D"].call(x) if ["HQ", "R&D"] is Callable else ["HQ", "R&D"])),
			"events": [boost_access_by_3],
			"on-trash": {
				"req": func(state, side, eid, card, targets):
					return (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCardRT.getv(state.data, "run"),
				"effect": func(state, side, eid, card, targets):
					return (func():
						var bonus_server = NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 1)
						return NREngine.register_events(state, side, card, [boost_access_when_trashed(bonus_server)])
					).call(),
			},
		}
	).call()))
	NRCardDefs.defcard("Nanisivik Grid", NRUtil.merge({
		"title": "Nanisivik Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever the Runner approaches this server, you may turn 1 facedown piece of ice in Archives faceup. If you do, resolve 1 subroutine on that ice.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "approach-server",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"prompt": "Choose a facedown piece of ice in Archives",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					var this_server = NRCardRT.this_server(state, card)
					return this_server and NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen"))))),
				"show-discard": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.in_discard(_pct) and (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen")))),
				},
				"async": true,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from Archives"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, target)
					, func(async_result):
						NRUpdate.update_card(state, side, NRUtil.merge(target, {"seen": true}))
						NREngine.resolve_ability(state, side, eid, (func():
							var ice = NRCard.get_card(state, target)
							return {
								"async": true,
								"prompt": "Choose a subroutine to resolve",
								"choices": func(state, side, eid, card, targets):
									return NRIce.unbroken_subroutines_choice(ice),
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("resolve the subroutine (\"[subroutine] ") + str(target) + str("\") from ") + str(NRToString.card_str(state, ice)),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return (func():
										var sub = NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(ice, "subroutines"), func(_pct):
											return ((target == NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))) or NRUtil.kw_eq(target, NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))))), 0)
										return NREngine.resolve_ability(state, side, eid, NRCardRT.getv(sub, "sub-effect"), ice, null)
									).call(),
							}
						).call(), card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Navi Mumbai City Grid", NRUtil.merge({
		"title": "Navi Mumbai City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "During runs on this server, the Runner cannot use paid abilities on their installed cards except for mid-access abilities and abilities on <strong>icebreakers</strong>.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "prevent-paid-ability",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (func():
						var target_card = NRCardRT.getv(targets, 0)
						return (run and ((NRCardRT.getv(target_card, "side") == "Runner") or NRUtil.kw_eq(NRCardRT.getv(target_card, "side"), "Runner")) and ((NRServers.target_server(run) == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRServers.target_server(run), NRCardRT.getv(NRCard.get_zone(card), 1))) and (not NRCardRT.truthy(NRCard.has_subtype(target_card, "Icebreaker"))))
					).call(),
				"value": true,
			}
		],
	}))
	NRCardDefs.defcard("NeoTokyo Grid", NRUtil.merge({
		"title": "NeoTokyo Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "The first time each turn an advancement counter is placed on a card in the root of this server, gain 1[credit].\nLimit 1 <strong>region</strong> per server."
	}, (func():
		var only_ev = func(state, side, ev, no_ev, card):
			return (NREvents.first_event(
			state,
			side,
			ev,
			func(_pct):
				return in_same_server(card, NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
		) and NREvents.no_event(
			state,
			side,
			no_ev,
			func(_pct):
				return in_same_server(card, NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
		))
		var ng = {
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return in_same_server(card, NRCardRT.getv(context, "card")) and (only_ev(state, side, "advance", "advancement-placed", card) or only_ev(state, side, "advancement-placed", "advance", card)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		}
		return {
			"events": [NRUtil.merge(ng, {"event": "advance"}), NRUtil.merge(ng, {"event": "advancement-placed"})],
		}
	).call()))
	NRCardDefs.defcard("Nihongai Grid", NRUtil.merge({
		"title": "Nihongai Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever the Runner makes a successful run on this server, if they do not have at least 2 cards in the grip and 6[credit], you may look at the top 5 cards of R&D and swap 1 of those cards with 1 card in HQ.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"skippable": true,
				"optional": {
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						var corp = state.player("corp")
						var this_server = NRCardRT.this_server(state, card)
						return this_server and ((NRCosts.total_available_credits(state, "runner", eid, card) < 6) or (NRCardRT.count_of(NRCardRT.getv(runner, "hand")) < 2)) and NRCardRT.seq_of(NRCardRT.getv(corp, "hand")) and NRCardRT.pos(NRCardRT.count_of(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5)))),
					"prompt": "Look at the top 5 cards of R&D?",
					"yes-ability": {
						"async": true,
						"msg": "look at the top 5 cards of R&D",
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
							return NREngine.resolve_ability(state, side, eid, {
								"async": true,
								"prompt": "Choose a card in R&D",
								"choices": NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5)),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NREngine.resolve_ability(state, side, eid, (func():
										var rdc = target
										return {
										"prompt": "Choose a card in HQ",
										"choices": {
											"card": NRCard.in_hand,
										},
										"msg": "swap a card from the top 5 of R&D with a card in HQ",
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											NRMoving.move(state, side, rdc, "hand")
											return NRMoving.move(
												state,
												side,
												target,
												"deck",
												{
													"index": NRCardRT.getv(rdc, "index"),
												}
											),
									} if rdc != null and NRCardRT.truthy(rdc) else null
									).call(), card, null),
							}, card, null),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Oaktown Grid", NRUtil.merge({
		"title": "Oaktown Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "The trash cost of each card in the root of this server is increased by 3.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "trash-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return in_same_server(card, target),
				"value": 3,
			}
		],
	}))
	NRCardDefs.defcard("Oberth Protocol", NRUtil.merge({
		"title": "Oberth Protocol",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 4,
		"text": "As an additional cost to rez this upgrade, forfeit 1 agenda.\nThe first time each turn you advance a card in the root of or protecting this server, place 1 more advancement counter on that card."
	}, {
		"additional-cost": [NRPayment.to_c("forfeit")],
		"events": [
			{
				"event": "advance",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return same_server(card, NRCardRT.getv(context, "card")) and ((1 == NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.map_list(NREvents.turn_events(state, side, "advance"), func(x): return NRCardRT.truthy(first.call(x) if first is Callable else first)), func(_pct):
						return ((NRCardRT.getv(NRCard.get_zone(NRCardRT.getv(_pct, "card")), 1) == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRCardRT.getv(NRCard.get_zone(NRCardRT.getv(_pct, "card")), 1), NRCardRT.getv(NRCard.get_zone(card), 1)))))) or NRUtil.kw_eq(1, NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.map_list(NREvents.turn_events(state, side, "advance"), func(x): return NRCardRT.truthy(first.call(x) if first is Callable else first)), func(_pct):
							return ((NRCardRT.getv(NRCard.get_zone(NRCardRT.getv(_pct, "card")), 1) == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRCardRT.getv(NRCard.get_zone(NRCardRT.getv(_pct, "card")), 1), NRCardRT.getv(NRCard.get_zone(card), 1))))))),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("place 1 additional advancement counter on ") + str(NRToString.card_str(state, NRCardRT.getv(context, "card"))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRProps.add_prop(
						state,
						"corp",
						eid,
						NRCardRT.getv(context, "card"),
						"advance-counter",
						1,
						{
							"placed": true,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Off the Grid", NRUtil.merge({
		"title": "Off the Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"trash": 0,
		"factioncost": 3,
		"text": "Install only in a remote server.\nThe Runner cannot initiate a run on this server.\nWhenever the Runner makes a successful run on HQ, trash Off the Grid."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
		"static-abilities": [
			{
				"type": "cannot-run-on-server",
				"req": func(state, side, eid, card, targets):
					return NRCard.rezzed(card),
				"value": func(state, side, eid, card, targets):
					return NRCardRT.getv(NRCard.get_zone(card), 1),
			}
		],
		"events": [
			{
				"event": "successful-run",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("hq" == NRServers.target_server(context)) or NRUtil.kw_eq("hq", NRServers.target_server(context))),
				"async": true,
				"msg": "trash itself",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(
						state,
						"corp",
						eid,
						card,
						{
							"cause-card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Old Hollywood Grid", NRUtil.merge({
		"title": "Old Hollywood Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Persistent → The Runner cannot steal agendas from this server or its root. Ignore this ability for any agenda the Runner has a copy of in their score area. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>\nLimit 1 <strong>region</strong> per server."
	}, {
		"on-trash": {
			"req": func(state, side, eid, card, targets):
				return (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCardRT.getv(state.data, "run"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "cannot-steal",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var runner = state.player("runner")
							return (not NRCardRT.some_list(NRCardRT.getv(runner, "scored"), func(_pct):
								return ((NRCardRT.getv(target, "title") == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(NRCardRT.getv(target, "title"), NRCardRT.getv(_pct, "title"))))) and (((NRCard.get_zone(target) == NRCardRT.getv(card, "previous-zone")) or NRUtil.kw_eq(NRCard.get_zone(target), NRCardRT.getv(card, "previous-zone"))) or ((central_to_zone(NRCard.get_zone(target)) == butlast(NRCardRT.getv(card, "previous-zone"))) or NRUtil.kw_eq(central_to_zone(NRCard.get_zone(target)), butlast(NRCardRT.getv(card, "previous-zone"))))),
						"value": true,
					}
				),
		},
		"static-abilities": [
			{
				"type": "cannot-steal",
				"duration": "end-of-run",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return (not NRCardRT.some_list(NRCardRT.getv(runner, "scored"), func(_pct):
						return ((NRCardRT.getv(target, "title") == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(NRCardRT.getv(target, "title"), NRCardRT.getv(_pct, "title"))))) and (in_same_server(card, target) or from_same_server(card, target)),
				"value": true,
			}
		],
	}))
	NRCardDefs.defcard("Overseer Matrix", NRUtil.merge({
		"title": "Overseer Matrix",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 4,
		"text": "Persistent → Whenever the Runner trashes a card from this server or its root, you may pay 1[credit] to give the Runner 1 tag. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
	}, (func():
		var ability = {
			"event": "runner-trash",
			"once-per-instance": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(targets, func(_pct):
					return (NRCard.corp(NRCardRT.getv(_pct, "card")) and (in_same_server(card, NRCardRT.getv(_pct, "card")) or from_same_server(card, NRCardRT.getv(_pct, "card"))))),
			"waiting-prompt": true,
			"prompt": "How many credits do you want to pay?",
			"choices": {
				"number": func(state, side, eid, card, targets):
					return mini(NRCardRT.count_of(NRCardRT.filter_list(targets, func(_pct):
						return (in_same_server(card, NRCardRT.getv(_pct, "card")) or from_same_server(card, NRCardRT.getv(_pct, "card")) or in_same_server(NRUtil.merge(card, {"zone": NRCardRT.getv(card, "previous-zone")}), NRCardRT.getv(_pct, "card"))))), NRCosts.total_available_credits(state, "corp", eid, card)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var n = target
					return NRUtil.merge(NRDefHelpers.give_tags(n), {"cost": [NRPayment.to_c("credit", n)]})
				).call(), card, null),
		}
		return {
			"on-trash": {
				"silent": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					return (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (NREngine.register_events(state, side, card, [NRUtil.merge(ability, {"duration": "end-of-run"})]) if NRCardRT.truthy(run) else null),
			},
			"events": [ability],
		}
	).call()))
	NRCardDefs.defcard("Panic Button", NRUtil.merge({
		"title": "Panic Button",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 1,
		"text": "Install only in the root of HQ.\n1[credit]: Draw 1 card. Use this ability only during a run on HQ."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return NRCardRT.truthy(["HQ"].call(x) if ["HQ"] is Callable else ["HQ"])),
		"abilities": [
			NRDefHelpers.draw_ability(
				1,
				null,
				{
					"cost": [NRPayment.to_c("credit", 1)],
					"keep-menu-open": "while-credits-left",
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						return run and ((NRServers.target_server(run) == "hq") or NRUtil.kw_eq(NRServers.target_server(run), "hq")),
				}
			)
		],
	}))
	NRCardDefs.defcard("Perfect Recall", NRUtil.merge({
		"title": "Perfect Recall",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"text": "When you rez this upgrade and whenever an agenda is scored or stolen from this server or its root, place 1 power counter on this upgrade.\n<strong>Hosted power counter:</strong> Reveal 1 card in HQ. The Runner cannot steal or trash copies of that card for the remainder of this run. Use this ability only during a run."
	}, (func():
		var ab = {
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				return run,
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.corp(target) and NRCard.in_hand(target),
			},
			"label": "Reveal a card and prevent it being trashed or stolen this run",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("reveal ") + str(NRCardRT.getv(target, "title")) + str("from HQ and prevent the runner from stealing or trashing any copies of it this run"),
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, target)
				, func(async_result):
					(func():
						var revealed_card = target
						NREffects.register_lingering_effect(
							state,
							side,
							card,
							{
								"type": "cannot-steal",
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return ((NRCardRT.getv(target, "title") == NRCardRT.getv(revealed_card, "title")) or NRUtil.kw_eq(NRCardRT.getv(target, "title"), NRCardRT.getv(revealed_card, "title"))),
								"value": true,
								"duration": "end-of-run",
							}
						)
						return NREffects.register_lingering_effect(
							state,
							side,
							card,
							{
								"type": "cannot-be-trashed",
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return ((NRCardRT.getv(target, "title") == NRCardRT.getv(revealed_card, "title")) or NRUtil.kw_eq(NRCardRT.getv(target, "title"), NRCardRT.getv(revealed_card, "title"))) and (("runner" == side) or NRUtil.kw_eq("runner", side)),
								"value": true,
								"duration": "end-of-run",
							}
						)
					).call()
					NREid.effect_completed(state, side, eid)),
		}
		return {
			"events": mapv(
				func(_pct):
					return NRUtil.merge({
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 1),
				}, _pct),
				[
					{
						"event": "agenda-stolen",
						"req": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone") == NRCard.get_zone(card)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), NRCard.get_zone(card))),
					},
					{
						"event": "agenda-scored",
						"req": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone") == NRCard.get_zone(card)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), NRCard.get_zone(card))),
					}
				]
			),
			"on-rez": {
				"silent": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
			},
			"abilities": [NRUtil.merge(ab, {"cost": [NRPayment.to_c("power", 1)]})],
		}
	).call()))
	NRCardDefs.defcard("Port Anson Grid", NRUtil.merge({
		"title": "Port Anson Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 5,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "As an additional cost to jack out during a run on this server, the Runner must trash 1 installed program.\nLimit 1 <strong>region</strong> per server."
	}, {
		"on-rez": {
			"msg": "prevent the Runner from jacking out unless they trash an installed program",
		},
		"static-abilities": [
			{
				"type": "jack-out-additional-cost",
				"duration": "end-of-run",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"value": [NRPayment.to_c("program", 1)],
			}
		],
		"events": [
			{
				"event": "run",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"msg": "prevent the Runner from jacking out unless they trash an installed program",
			}
		],
	}))
	NRCardDefs.defcard("Prisec", NRUtil.merge({
		"title": "Prisec",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "If the Runner accesses Prisec while installed, you may pay 2[credit] to give the Runner 1 tag and do 1 meat damage."
	}, installed_access_trigger(
		2,
		{
			"waiting-prompt": true,
			"msg": "do 1 meat damage and give the Runner 1 tag",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDamage.damage(state, side, ne, "meat", 1, {
						"card": card,
					})
				, func(async_result):
					NRTags.gain_tags(state, "corp", eid, 1)),
		}
	)))
	NRCardDefs.defcard("Product Placement", NRUtil.merge({
		"title": "Product Placement",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, gain 2[credit]."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.in_discard(card))),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 2),
		},
	}))
	NRCardDefs.defcard("Red Herrings", NRUtil.merge({
		"title": "Red Herrings",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 2,
		"text": "Persistent → As an additional cost to steal an agenda from this server or its root, the Runner must pay 5[credit]. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
	}, {
		"on-trash": {
			"req": func(state, side, eid, card, targets):
				return (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCardRT.getv(state.data, "run"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "steal-additional-cost",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (((NRCard.get_zone(target) == NRCardRT.getv(card, "previous-zone")) or NRUtil.kw_eq(NRCard.get_zone(target), NRCardRT.getv(card, "previous-zone"))) or ((central_to_zone(NRCard.get_zone(target)) == butlast(NRCardRT.getv(card, "previous-zone"))) or NRUtil.kw_eq(central_to_zone(NRCard.get_zone(target)), butlast(NRCardRT.getv(card, "previous-zone"))))),
						"value": func(state, side, eid, card, targets):
							return NRPayment.to_c("credit", 5),
					}
				),
		},
		"static-abilities": [
			{
				"type": "steal-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (in_same_server(card, target) or from_same_server(card, target)),
				"value": func(state, side, eid, card, targets):
					return NRPayment.to_c("credit", 5),
			}
		],
	}))
	NRCardDefs.defcard("Reduced Service", NRUtil.merge({
		"title": "Reduced Service",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 0,
		"trash": 2,
		"factioncost": 3,
		"text": "When you rez this upgrade, you may pay up to 4[credit] to place that many power counters on it.\nAs an additional cost to run this server, the Runner must pay 2[credit] for each hosted power counter.\nWhenever the Runner makes a successful run on a central server, remove 1 hosted power counter."
	}, {
		"static-abilities": [
			{
				"type": "run-additional-cost",
				"req": func(state, side, eid, card, targets):
					return ((NRCardRT.getv(NRCardRT.getv(targets, 1), "server") == unknown_to_kw(NRCard.get_zone(card))) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(targets, 1), "server"), unknown_to_kw(NRCard.get_zone(card)))),
				"value": func(state, side, eid, card, targets):
					return NRCardRT.repeat_n([NRPayment.to_c("credit", 2)], int(NRCard.get_counters(card, "power"))),
			}
		],
		"events": [
			{
				"event": "successful-run",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCardRT.pos(NRCard.get_counters(card, "power")) and is_central(NRCardRT.getv(context, "server")),
				"msg": "remove 1 hosted power counter",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", -1, null),
			}
		],
		"on-rez": {
			"waiting-prompt": true,
			"prompt": "How many credits do you want to pay?",
			"choices": func(state, side, eid, card, targets):
				return NRCardRT.map_list(range_((int(mini(4, state.get_in(["corp", "credit"], null))) + 1)), func(x): return NRCardRT.truthy(str_.call(x) if str_ is Callable else str_)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var spent = str_to_int(target)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, "corp", ne, card, "power", spent, null)
					, func(async_result):
						NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to place ") + str(NRCardRT.quantify(spent, "power counter")) + str(" on itself"))
						NRGaining.lose_credits(state, "corp", eid, spent))
				).call(),
		},
	}))
	NRCardDefs.defcard("Research Station", NRUtil.merge({
		"title": "Research Station",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 1,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "Install only in the root of HQ.\nYour maximum hand size is +2."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return NRCardRT.truthy(["HQ"].call(x) if ["HQ"] is Callable else ["HQ"])),
		"static-abilities": [NRHandSize.corp_hand_size_plus(2)],
	}))
	NRCardDefs.defcard("Ruhr Valley", NRUtil.merge({
		"title": "Ruhr Valley",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "As an additional cost to make a run on this server, the Runner must spend [click].\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "run-additional-cost",
				"req": func(state, side, eid, card, targets):
					return ((NRCardRT.getv(NRCardRT.getv(targets, 1), "server") == unknown_to_kw(NRCard.get_zone(card))) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(targets, 1), "server"), unknown_to_kw(NRCard.get_zone(card)))),
				"value": [NRPayment.to_c("click", 1)],
			}
		],
	}))
	NRCardDefs.defcard("Rutherford Grid", NRUtil.merge({
		"title": "Rutherford Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "The base trace strength of each trace during a run on this server is increased by 2.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "trace-base-strength",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"value": 2,
			}
		],
	}))
	NRCardDefs.defcard("Ryon Knight", NRUtil.merge({
		"title": "Ryon Knight",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "[trash]: Do 1 core damage. Use this ability only during a run against this server and only if the Runner has no unspent [click]."
	}, {
		"abilities": [
			{
				"label": "Do 1 core damage",
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					var this_server = NRCardRT.this_server(state, card)
					return this_server and NRCardRT.zero(NRCardRT.getv(runner, "click")),
				"cost": [NRPayment.to_c("trash-can")],
				"msg": "do 1 core damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"brain",
						1,
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("SanSan City Grid", NRUtil.merge({
		"title": "SanSan City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"trash": 5,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Each agenda in the root of this server gets −1 advancement requirement.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "advancement-requirement",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return in_same_server(card, target),
				"value": -1,
			}
		],
	}))
	NRCardDefs.defcard("Satellite Grid", NRUtil.merge({
		"title": "Satellite Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Each piece of ice protecting this server is considered to have 1 additional advancement token on it.\nLimit 1 <strong>region</strong> per server."
	}, {
		"on-rez": {
			"effect": func(state, side, eid, card, targets):
				(func():
					for c in NRCardRT.as_array(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices")):
						NRProps.set_prop(state, side, c, "extra-advance-counter", 1)
					return null
				).call()
				return NRIce.update_all_ice(state, side),
		},
		"events": [
			{
				"event": "corp-install",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.ice(NRCardRT.getv(context, "card")) and NRServers.protecting_same_server(card, NRCardRT.getv(context, "card")),
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRProps.set_prop(state, side, NRCardRT.getv(context, "card"), "extra-advance-counter", 1),
			}
		],
		"leave-play": func(state, side, eid, card, targets):
			(func():
				for c in NRCardRT.as_array(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices")):
					NRUpdate.update_card(state, side, NRUtil.dissoc(c, ["extra-advance-counter"]))
				return null
			).call()
			return NRIce.update_all_ice(state, side),
	}))
	NRCardDefs.defcard("Self-destruct", NRUtil.merge({
		"title": "Self-destruct",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 0,
		"factioncost": 0,
		"text": "Remote server only.\n<strong>[trash]:</strong> Trash all cards installed in the root of or protecting this server. Trace[X], where X is equal to the number of cards trashed. If successful, do 3 net damage. Use this ability only during a run on this server."
	}, {
		"install-req": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
		"abilities": [
			{
				"async": true,
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"cost": [NRPayment.to_c("trash-can")],
				"label": "Trace X - Do 3 net damage",
				"effect": func(state, side, eid, card, targets):
					return (func():
						var serv = NRBoard.card_to_server(state, card)
						var cards = NRCardRT.concat_lists([NRCardRT.getv(serv, "ices"), NRCardRT.getv(serv, "content")])
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash_cards(state, side, ne, cards, {
								"cause-card": card,
							})
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, {
								"trace": {
									"base": NRCardRT.count_of(cards),
									"successful": {
										"async": true,
										"msg": "do 3 net damage",
										"effect": func(state, side, eid, card, targets):
											return NRDamage.damage(
												state,
												side,
												eid,
												"net",
												3,
												{
													"card": card,
												}
											),
									},
								},
							}, card, null))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Shackleton Grid", NRUtil.merge({
		"title": "Shackleton Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Once per turn → When the Runner spends credits from outside their credit pool during a run against this server, you may do 4 meat damage.\nLimit 1 <strong>region</strong> per server."
	}, (func():
		var ev = {
			"optional": {
				"prompt": "Do 4 meat damage?",
				"waiting-prompt": true,
				"once": "per-turn",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return run and this_server and ((not NRCardRT.truthy(NRCardRT.getv(target, "card"))) or NRCard.runner(NRCardRT.getv(target, "card"))),
				"yes-ability": {
					"async": true,
					"msg": "do 4 meat damage",
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(state, side, eid, "meat", 4),
				},
			},
		}
		return {
			"events": [
				NRUtil.merge(ev, {
					"event": "bad-publicity-spent",
				}),
				NRUtil.merge(ev, {
					"event": "spent-credits-from-card",
				})
			],
		}
	).call()))
	NRCardDefs.defcard("Shell Corporation", NRUtil.merge({
		"title": "Shell Corporation",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 0,
		"text": "You cannot use this upgrade more than once per turn.\n[click]<strong>:</strong> Place 3[credit] on this upgrade.\n[click]<strong>:</strong> Take all credits from this upgrade."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "place 3 [Credits]",
				"once": "per-turn",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "credit", 3, null),
			},
			take_all_credits_ability(
				{
					"cost": [NRPayment.to_c("click", 1)],
					"action": true,
					"once": "per-turn",
				}
			)
		],
	}))
	NRCardDefs.defcard("Signal Jamming", NRUtil.merge({
		"title": "Signal Jamming",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 0,
		"text": "[trash]: Cards cannot be installed until the end of the run. Use this ability only during a run on this server."
	}, {
		"abilities": [
			{
				"label": "Cards cannot be installed until the end of the run",
				"msg": "prevent cards being installed until the end of the run",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return this_server and run,
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					NRFlags.register_run_flag(state, side, card, "corp-lock-install", (func(_a=null, _b=null, _c=null, _d=null, _e=null): return true))
					NRFlags.register_run_flag(state, side, card, "runner-lock-install", (func(_a=null, _b=null, _c=null, _d=null, _e=null): return true))
					NRToasts.toast(state, "runner", "Cannot install until the end of the run")
					return NRToasts.toast(state, "corp", "Cannot install until the end of the run"),
			}
		],
	}))
	NRCardDefs.defcard("Simone Diego", NRUtil.merge({
		"title": "Simone Diego",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 4,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "2[recurring-credit]\nYou can spend hosted credits to take the basic action to advance cards in the root of or protecting this server."
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					return (func():
						var ab_target = NRCardRT.getv(NREid.get_ability_targets(eid), "card")
						return (same_server(card, ab_target) and ((("advance" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("advance", NRCardRT.getv(eid, "source-type"))) or NREid.is_basic_advance_action(eid)))
					).call(),
				"type": "recurring",
			},
		},
	}))
	NRCardDefs.defcard("Strongbox", NRUtil.merge({
		"title": "Strongbox",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"trash": 1,
		"factioncost": 2,
		"text": "Persistent → As an additional cost to steal an agenda from this server or its root, the Runner must spend [click]. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
	}, {
		"on-trash": {
			"req": func(state, side, eid, card, targets):
				return (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCardRT.getv(state.data, "run"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "steal-additional-cost",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (((NRCard.get_zone(target) == NRCardRT.getv(card, "previous-zone")) or NRUtil.kw_eq(NRCard.get_zone(target), NRCardRT.getv(card, "previous-zone"))) or ((central_to_zone(NRCard.get_zone(target)) == butlast(NRCardRT.getv(card, "previous-zone"))) or NRUtil.kw_eq(central_to_zone(NRCard.get_zone(target)), butlast(NRCardRT.getv(card, "previous-zone"))))),
						"value": func(state, side, eid, card, targets):
							return NRPayment.to_c("click", 1),
					}
				),
		},
		"static-abilities": [
			{
				"type": "steal-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (in_same_server(card, target) or from_same_server(card, target)),
				"value": func(state, side, eid, card, targets):
					return NRPayment.to_c("click", 1),
			}
		],
	}))
	NRCardDefs.defcard("Surat City Grid", NRUtil.merge({
		"title": "Surat City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever you rez another card in the root of or protecting this server, you may rez 1 card, paying 2[credit] less.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "rez",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var context = NRCardRT.ctx(targets)
						return (func():
							var target = NRCardRT.getv(context, "card")
							return (same_server(card, target) and (not NRCardRT.truthy(NRUtil.same_card(target, card))) and NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
								return ((not NRCardRT.truthy(NRCard.rezzed(_pct))) and (not NRCardRT.truthy(NRCard.agenda(_pct))) and NRCard.corp(_pct) and NRRezzing.can_pay_to_rez(
								state,
								side,
								NRUtil.merge(eid, {"source": card}),
								_pct,
								{
									"cost-bonus": -2,
								}
							))))
						).call(),
					"prompt": "Rez another card paying 2 [Credits] less?",
					"yes-ability": {
						"prompt": "Choose a card to rez",
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (not NRCardRT.truthy(NRCard.rezzed(target))) and (not NRCardRT.truthy(NRCard.agenda(target))) and NRCard.corp(target) and NRCard.installed(target) and NRRezzing.can_pay_to_rez(
									state,
									side,
									NRUtil.merge(eid, {"source": card}),
									target,
									{
										"cost-bonus": -2,
									}
								),
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
									"cost-bonus": -2,
								}
							),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Tempus", NRUtil.merge({
		"title": "Tempus",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 0,
		"factioncost": 3,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, Trace[3]. If successful, the Runner must lose [click][click] or suffer 1 core damage."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"trace": {
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCard.in_discard(card))),
				"base": 3,
				"successful": {
					"waiting-prompt": true,
					"prompt": "Choose one",
					"player": "runner",
					"choices": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return [
							("Lose [Click][Click]" if NRCardRT.truthy((2 <= NRCardRT.getv(runner, "click"))) else null),
							"Suffer 1 core damage"
						],
					"async": true,
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var runner = state.player("runner")
						return ((func():
							NRGaining.lose_clicks(state, "runner", 2)
							return NREid.effect_completed(state, side, eid)
						).call() if (((target == "Lose [Click][Click]") or NRUtil.kw_eq(target, "Lose [Click][Click]")) and (2 <= NRCardRT.getv(runner, "click"))) else NRDamage.damage(
							state,
							side,
							eid,
							"brain",
							1,
							{
								"card": card,
							}
						)),
				},
			},
		},
	}))
	NRCardDefs.defcard("The Holo Man", NRUtil.merge({
		"title": "The Holo Man",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Academic - Executive - Sysop",
		"subtypes": ["Academic", "Executive", "Sysop"],
		"text": "When your turn begins, you may move this upgrade to the root of another server.\nOnce per turn → [click], <strong>4[credit]:</strong> Place 2 advancement counters on 1 card in the root of or protecting this server. If you have not installed any cards from HQ this turn, instead place 3 advancement counters on that card."
	}, (func():
		var is_boosted_fn = func(state, side):
			return NREvents.no_event(
			state,
			side,
			"corp-install",
			func(_pct):
				return ((["hand"] == NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "previous-zone")) or NRUtil.kw_eq(["hand"], NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "previous-zone")))
		)
		var abi = {
			"action": true,
			"cost": [NRPayment.to_c("click"), NRPayment.to_c("credit", 4)],
			"label": "Place advancement counters on a card in or protecting this server",
			"once": "per-turn",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return same_server(card, target),
			},
			"msg": {
				"public": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place ") + str((3 if is_boosted_fn(state, side) else 2)) + str(" advancement counters on ") + str(NRToString.card_str(state, target)),
				"corp": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place ") + str((3 if is_boosted_fn(state, side) else 2)) + str(" advancement counters on ") + str(NRToString.card_str(
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
				return (func():
					var n = (3 if is_boosted_fn(state, side) else 2)
					return NRProps.add_prop(
						state,
						side,
						eid,
						target,
						"advance-counter",
						n,
						{
							"placed": true,
						}
					)
				).call(),
		}
		return {
			"abilities": [abi],
			"events": [_mobile_sysop_event("corp-turn-begins")],
		}
	).call()))
	NRCardDefs.defcard("The Red Room", NRUtil.merge({
		"title": "The Red Room",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 1,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Facility",
		"subtypes": ["Facility"],
		"text": "Central server only.\nThe first time each turn an agenda is scored or stolen, place 1 power counter on this upgrade.\n<strong>Hosted power counter:</strong> End the run. Use this ability only during a run against another server."
	}, {
		"legal-zones": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return NRCardRT.truthy(["R&D", "HQ", "Archives"].call(x) if ["R&D", "HQ", "Archives"] is Callable else ["R&D", "HQ", "Archives"])),
		"events": [
			{
				"event": "agenda-stolen",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "agenda-stolen") and NREvents.no_event(state, side, "agenda-scored"),
			},
			{
				"event": "agenda-scored",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1),
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "agenda-scored") and NREvents.no_event(state, side, "agenda-stolen"),
			}
		],
		"abilities": [
			{
				"cost": [NRPayment.to_c("power", 1)],
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return run and (not NRCardRT.truthy(this_server)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card),
				"msg": "End the run",
			}
		],
	}))
	NRCardDefs.defcard("The Twins", NRUtil.merge({
		"title": "The Twins",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 1,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "Whenever the Runner passes a rezzed piece of ice protecting this server, you may reveal and trash another copy of that ice from HQ to force the Runner to encounter the piece of ice just passed again."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						var corp = state.player("corp")
						var this_server = NRCardRT.this_server(state, card)
						return this_server and NRCard.rezzed(NRCardRT.getv(context, "ice")) and NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), func(_pct):
							return NRUtil.same_card("title", _pct, NRCardRT.getv(context, "ice")))),
					"prompt": func(state, side, eid, card, targets):
						var current_ice = NRIce.get_current_ice(state)
						return str("Force the runner to encounter ") + str(NRCardRT.getv(current_ice, "title")) + str(" again?"),
					"yes-ability": {
						"async": true,
						"prompt": func(state, side, eid, card, targets):
							var current_ice = NRIce.get_current_ice(state)
							return str("Choose a copy of ") + str(NRCardRT.getv(current_ice, "title")) + str(" in HQ"),
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								var current_ice = NRIce.get_current_ice(state)
								return NRCard.in_hand(target) and NRCard.ice(target) and NRUtil.same_card("title", current_ice, target),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("reveal a copy of ") + str(NRCardRT.getv(target, "title")) + str(" from HQ, trash it and force the Runner to encounter it again"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var current_ice = NRIce.get_current_ice(state)
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, target)
							, func(async_result):
								NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, NRUtil.merge(target, {"seen": true}), {
										"cause-card": card,
									})
								, func(async_result):
									NRRuns.force_ice_encounter(state, side, eid, current_ice))),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Tori Hanzō", NRUtil.merge({
		"title": "Tori Hanzō",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 3,
		"trash": 2,
		"factioncost": 4,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "[interrupt] → The first time you would do 1 or more net damage during each run against this server, instead you may pay 2[credit] to do 1 core damage."
	}, {
		"prevention": [
			{
				"prevents": "damage",
				"type": "event",
				"max-uses": 1,
				"prompt": "Pay 2 [Credits] to do 1 core damage instead?",
				"ability": {
					"cost": [NRPayment.to_c("credit", 2)],
					"msg": "instead do 1 core damage",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (("net" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("net", NRCardRT.getv(context, "type"))) and (("corp" == NRCardRT.getv(context, "source-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(context, "source-player"))) and NREvents.first_run_event(
							state,
							side,
							"pre-damage-flag",
							func(_pct):
								return (("net" == NRCardRT.getv(NRCardRT.getv(_pct, 0), "type")) or NRUtil.kw_eq("net", NRCardRT.getv(NRCardRT.getv(_pct, 0), "type")))
						) and NRCardRT.pos(NRCardRT.getv(context, "remaining")),
					"effect": func(state, side, eid, card, targets):
						return state.update_in(["prevent", "damage"], func(v): return v),
				},
			}
		],
	}))
	NRCardDefs.defcard("Traffic Analyzer", NRUtil.merge({
		"title": "Traffic Analyzer",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 1,
		"text": "Whenever you rez a piece of ice protecting this server, Trace[2]. If successful, the Corp gains 1[credit]."
	}, {
		"events": [
			{
				"event": "rez",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"trace": {
					"base": 2,
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRServers.protecting_same_server(card, NRCardRT.getv(context, "card")) and NRCard.ice(NRCardRT.getv(context, "card")),
					"successful": {
						"msg": "gain 1 [Credits]",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRGaining.gain_credits(state, side, eid, 1),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Tranquility Home Grid", NRUtil.merge({
		"title": "Tranquility Home Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Remote server only.\nThe first time each turn you install a card in the root of this server, gain 2[credit] or draw 1 card.\nLimit 1 <strong>region</strong> per server."
	}, {
		"legal-zones": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
		"events": [
			{
				"event": "corp-install",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (NRCard.asset(NRCardRT.getv(context, "card")) or NRCard.agenda(NRCardRT.getv(context, "card")) or NRCard.upgrade(NRCardRT.getv(context, "card"))) and in_same_server(card, NRCardRT.getv(context, "card")) and NREvents.first_event(
						state,
						"corp",
						"corp-install",
						func(_pct):
							return in_same_server(card, NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
					),
				"prompt": "Choose one",
				"waiting-prompt": true,
				"choices": ["Gain 2 [Credits]", "Draw 1 card"],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str(NRCardRT.decapitalize(target)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NRGaining.gain_credits(state, side, eid, 2) if ((target == "Gain 2 [Credits]") or NRUtil.kw_eq(target, "Gain 2 [Credits]")) else NRDrawing.draw(state, side, eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("Tucana", NRUtil.merge({
		"title": "Tucana",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 1,
		"factioncost": 3,
		"text": "Remote server only.\nPersistent → Whenever an agenda is scored or stolen from the root of this server, you may search R&D for 1 piece of ice. <em>(Shuffle R&D after searching it.)</em> Install and rez that ice, paying a total of 3[credit] less."
	}, (func():
		var ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Search R&D for an ice?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone") == NRCard.get_zone(card)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), NRCard.get_zone(card))),
				"yes-ability": {
					"async": true,
					"prompt": "Choose a piece of ice to install and rez",
					"waiting-prompt": true,
					"choices": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice))),
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("install and rez ") + str(NRToString.card_str(state, target)) + str(", paying a total of 3 [Credits] less"),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREid.wait_for(state, eid, func(ne):
							NRInstalling.corp_install(state, side, ne, target, null, {
								"install-state": "rezzed",
								"combined-credit-discount": 3,
								"msg-keys": {
									"install-source": card,
									"display-origin": true,
								},
							})
						, func(async_result):
							NRShuffling.shuffle_zone(state, "corp", "deck")
							NRSay.system_msg(state, side, str("shuffles R&D"))
							NREid.effect_completed(state, side, eid)),
					"cancel": NRShuffling.shuffle_deck,
				},
			},
		}
		return {
			"legal-zones": func(state, side, eid, card, targets):
				return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
			"events": [
				NRUtil.merge(ability, {"event": "agenda-stolen"}),
				NRUtil.merge(ability, {"event": "agenda-scored"})
			],
			"on-trash": {
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run and (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NREngine.register_events(
						state,
						side,
						card,
						[
							NRUtil.assoc_in(NRUtil.merge(ability, {"event": "agenda-stolen", "duration": "end-of-run"}), ["optional", "req"], func(state, side, eid, card, targets):
								var context = NRCardRT.ctx(targets)
								return ((NRCardRT.getv(card, "previous-zone") == NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone")) or NRUtil.kw_eq(NRCardRT.getv(card, "previous-zone"), NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"))))
						]
					),
			},
		}
	).call()))
	NRCardDefs.defcard("Tyr's Hand", NRUtil.merge({
		"title": "Tyr's Hand",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"trash": 1,
		"factioncost": 1,
		"keywords": "Hostile",
		"subtypes": ["Hostile"],
		"text": "[interrupt] → When a subroutine would be broken on a piece of <strong>bioroid</strong> ice protecting this server, you may rez this upgrade.\n[interrupt] → <strong>[trash]:</strong> Prevent 1 subroutine from being broken on a piece of <strong>bioroid</strong> ice protecting this server."
	}, {
		"abilities": [
			{
				"label": "Prevent a subroutine on a piece of Bioroid ice from being broken",
				"req": func(state, side, eid, card, targets):
					var current_ice = NRIce.get_current_ice(state)
					return ((butlast(NRCard.get_zone(current_ice)) == butlast(NRCard.get_zone(card))) or NRUtil.kw_eq(butlast(NRCard.get_zone(current_ice)), butlast(NRCard.get_zone(card)))) and NRCard.has_subtype(current_ice, "Bioroid"),
				"cost": [NRPayment.to_c("trash-can")],
				"msg": func(state, side, eid, card, targets):
					var current_ice = NRIce.get_current_ice(state)
					return str("prevent a subroutine on ") + str(NRCardRT.getv(current_ice, "title")) + str(" from being broken"),
			}
		],
	}))
	NRCardDefs.defcard("Underway Grid", NRUtil.merge({
		"title": "Underway Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 0,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Ice protecting this server cannot be bypassed.\nCards in the root of and/or protecting this server cannot be exposed.\nLimit 1 <strong>region</strong> per server."
	}, {
		"static-abilities": [
			{
				"type": "cannot-be-exposed",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return same_server(card, target),
				"value": true,
			},
			{
				"type": "bypass-ice",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return same_server(card, target),
				"value": false,
			}
		],
	}))
	NRCardDefs.defcard("Valley Grid", NRUtil.merge({
		"title": "Valley Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Whenever the Runner fully breaks a piece of ice protecting this server, they get -1 maximum hand size until the beginning of your next turn.\nLimit 1 <strong>region</strong> per server."
	}, {
		"events": [
			{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var this_server = NRCardRT.this_server(state, card)
					return this_server and NRCardRT.getv(context, "all-subs-broken"),
				"msg": "reduce the Runner's maximum hand size by 1 until the start of the next Corp turn",
				"effect": func(state, side, eid, card, targets):
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "hand-size",
							"duration": "until-corp-turn-begins",
							"req": func(state, side, eid, card, targets):
								return (("runner" == side) or NRUtil.kw_eq("runner", side)),
							"value": -1,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Vladisibirsk City Grid", NRUtil.merge({
		"title": "Vladisibirsk City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"trash": 4,
		"factioncost": 4,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "You can advance this upgrade.\nOnce per turn → <strong>2 hosted advancement counters:</strong> Place 2 advancement counters on another card you can advance in the root of this server.\nLimit 1 <strong>region</strong> per server."
	}, {
		"advanceable": "always",
		"abilities": [
			{
				"cost": [NRPayment.to_c("advancement", 2)],
				"once": "per-turn",
				"prompt": func(state, side, eid, card, targets):
					return str("Choose an advanceable card in ") + str(NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1))),
				"label": "Place 2 advancement counters (once per turn)",
				"msg": {
					"public": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("place 2 advancement counters on ") + str(NRToString.card_str(state, target)),
					"corp": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("place 2 advancement counters on ") + str(NRToString.card_str(
							state,
							target,
							{
								"maybe-visible": true,
							}
						)),
				},
				"choices": {
					"not-self": true,
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.installed(target) and NRCard.can_be_advanced(state, target) and in_same_server(card, target),
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
						2,
						{
							"placed": true,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Vovô Ozetti", NRUtil.merge({
		"title": "Vovô Ozetti",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 1,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Sysop",
		"subtypes": ["Sysop"],
		"text": "The rez cost of each piece of ice protecting this server is lowered by 2[credit].\nThreat 4 → The rez cost of each card in the root of this server is lowered by 2[credit]. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nWhen your turn ends, you may move this upgrade to the root of another server."
	}, {
		"static-abilities": [
			{
				"type": "rez-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NRCard.ice(target) or NRThreat.threat(state, int(4))) and ((NRBoard.card_to_server(state, card) == NRBoard.card_to_server(state, target)) or NRUtil.kw_eq(NRBoard.card_to_server(state, card), NRBoard.card_to_server(state, target))),
				"value": -2,
			}
		],
		"events": [_mobile_sysop_event()],
	}))
	NRCardDefs.defcard("Warroid Tracker", NRUtil.merge({
		"title": "Warroid Tracker",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"trash": 4,
		"factioncost": 2,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "Whenever the Runner trashes at least 1 card from this server, from its root, or protecting it, Trace[4]. If successful, the Runner trashes 2 of their installed cards."
	}, {
		"events": [
			{
				"event": "runner-trash",
				"async": true,
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCardRT.some_list(targets, func(target):
						return (NRCard.corp(NRCardRT.getv(target, "card")) and (func():
							var target_zone = NRCard.get_zone(NRCardRT.getv(target, "card"))
							var target_zone = (central_to_zone(target_zone) or target_zone)
							var warroid_zone = NRCard.get_zone(card)
							return ((NRCardRT.getv(warroid_zone, 1) == NRCardRT.getv(target_zone, 1)) or NRUtil.kw_eq(NRCardRT.getv(warroid_zone, 1), NRCardRT.getv(target_zone, 1)))
					).call())),
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, _ability_7(), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Will-o'-the-Wisp", NRUtil.merge({
		"title": "Will-o'-the-Wisp",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"trash": 1,
		"factioncost": 0,
		"text": "Whenever the Runner makes a successful run on this server, you may trash this upgrade. If you do, choose 1 installed <strong>icebreaker</strong> that was used to break at least 1 subroutine during this run. The Runner adds that <strong>icebreaker</strong> to the bottom of the stack."
	}, {
		"implementation": "Doesn't restrict icebreaker selection",
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"req": func(state, side, eid, card, targets):
						var this_server = NRCardRT.this_server(state, card)
						return this_server and NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
							return NRCard.has_subtype(_pct, "Icebreaker")),
					"waiting-prompt": true,
					"prompt": func(state, side, eid, card, targets):
						return str("Trash ") + str(NRCardRT.getv(card, "title")) + str(" to choose an icebreaker?"),
					"yes-ability": {
						"async": true,
						"prompt": "Choose an icebreaker used to break at least 1 subroutine during this run",
						"choices": {
							"card": func(_pct):
								return NRCard.has_subtype(_pct, "Icebreaker"),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to the bottom of the stack"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, card, {
									"cause-card": card,
								})
							, func(async_result):
								NRMoving.move(state, "runner", target, "deck")
								NREid.effect_completed(state, side, eid)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Yakov Erikovich Avdakov", NRUtil.merge({
		"title": "Yakov Erikovich Avdakov",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Executive",
		"subtypes": ["Executive"],
		"text": "Whenever a player trashes a card <em>(including this upgrade)</em> from the root of this server or protecting it, except during installation, gain 2[credit]."
	}, {
		"events": [
			{
				"event": "runner-trash",
				"async": true,
				"once-per-instance": false,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return _valid_target_fn_8(context, card),
				"msg": "gain 2 [Credits]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			},
			{
				"event": "corp-trash",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"once-per-instance": false,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var cause = NRCardRT.getv(context, "cause")
						var cause_card = NRCardRT.getv(context, "cause-card")
						return ((not (("corp-install" == NRCardRT.getv(eid, "source-type")) or NRUtil.kw_eq("corp-install", NRCardRT.getv(eid, "source-type")))) and (NRCard.corp(NRCardRT.getv(eid, "source")) or (("ability-cost" == cause) or NRUtil.kw_eq("ability-cost", cause)) or (("subroutine" == cause) or NRUtil.kw_eq("subroutine", cause)) or (NRCard.corp(cause_card) and (not ((cause == "opponent-trashes") or NRUtil.kw_eq(cause, "opponent-trashes")))) or (NRCard.runner(cause_card) and ((cause == "forced-to-trash") or NRUtil.kw_eq(cause, "forced-to-trash")))) and _valid_target_fn_8(context, card))
					).call(),
				"async": true,
				"msg": "gain 2 [Credits]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			}
		],
	}))
	NRCardDefs.defcard("ZATO City Grid", NRUtil.merge({
		"title": "ZATO City Grid",
		"type": "Upgrade",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Region",
		"subtypes": ["Region"],
		"text": "Remote server only.\nEach piece of ice protecting this server gains \"When the Runner encounters this ice, choose 1 subroutine on it. You may trash this ice to resolve that subroutine.\".\nLimit 1 <strong>region</strong> per server."
	}, {
		"legal-zones": func(state, side, eid, card, targets):
			return NRCardRT.filter_list(targets, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
		"static-abilities": [
			{
				"type": "gain-encounter-ability",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRServers.protecting_same_server(card, target) and (not NRCardRT.truthy(NRCardRT.getv(target, "disabled"))),
				"value": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return {
						"async": true,
						"ability-name": "ZATO City Grid",
						"interactive": func(state, side, eid, card, targets):
							return true,
						"optional": {
							"waiting-prompt": true,
							"prompt": "Trash ice to fire a (printed) subroutine?",
							"yes-ability": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									var context = NRCardRT.ctx(targets)
									return (func():
										var target_ice = NRCardRT.getv(context, "ice")
										return NREngine.resolve_ability(state, side, eid, ({
											"prompt": "Choose a subroutine to resolve",
											"choices": func(state, side, eid, card, targets):
												return NRIce.unbroken_subroutines_choice(target_ice),
											"cost": [NRPayment.to_c("trash-can")],
											"msg": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return str("resolve (\"[Subroutine] ") + str(target) + str("\")"),
											"async": true,
											"effect": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return (func():
													var sub = NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(target_ice, "subroutines"), func(_pct):
														return ((target == NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))) or NRUtil.kw_eq(target, NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))))), 0)
													return NRIce.resolve_subroutine(state, side, eid, target_ice, NRUtil.merge(sub, {"external-trigger": true}))
												).call(),
										} if NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(target_ice, "subroutines"), func(x): return NRCardRT.getv(x, "printed"))) else {
											"cost": [NRPayment.to_c("trash-can")],
											"change-in-game-state": {
												"req": func(state, side, eid, card, targets):
													return false,
											},
										}), card, null)
									).call(),
							},
						},
					},
			}
		],
	}))

static func _mobile_sysop_event(ev = null, callback = null):
	return {
		"event": ev,
		"skippable": true,
		"optional": {
			"prompt": func(state, side, eid, card, targets):
				return str("Move ") + str(NRCardRT.getv(card, "title")) + str(" to another server?"),
			"waiting-prompt": true,
			"yes-ability": {
				"prompt": "Choose a server",
				"waiting-prompt": true,
				"choices": func(state, side, eid, card, targets):
					return server_list_exclude(state, [NRCardRT.getv(NRCardRT.getv(card, "zone"), 1)]),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("move itself to ") + str(target),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var c = NRMoving.move(state, side, card, (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["content"]))
						NREngine.unregister_events(state, side, card)
						NREngine.register_default_events(state, side, c)
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, callback, c, null)
						, func(async_result):
							NREid.effect_completed(state, side, eid))
					).call(),
			},
		},
	}

static func _can_smart_purge(state):
	return (state.get_in(["corp", "properties", "auto-purge"], null) and (not NRCardRT.truthy(["Acacia", "Fester", "Heliamphora"](NRCardRT.map_list(NRBoard.all_installed(state, "runner"), func(x): return NRCardRT.getv(x, "title"))))))

static func _dhq_1(i, n):
	return {
	"req": func(state, side, eid, card, targets):
		return NRCardRT.pos(n),
	"prompt": "Choose a card in HQ to add to the bottom of R&D",
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
	},
	"async": true,
	"msg": "add a card to the bottom of R&D",
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		NRMoving.move(state, side, target, "deck")
		return NREngine.resolve_ability(state, side, eid, (dhq((int(i) + 1), n) if NRCardRT.truthy((i < n)) else null), card, null),
}

static func _hp_gain_credits_2(state, side, eid, n):
	return (NREid.wait_for(state, eid, func(ne):
		NRGaining.gain_credits(state, "corp", ne, 2)
, func(async_result):
	hp_gain_credits(state, side, eid, (int(n) - 1))) if NRCardRT.pos(n) else NREid.effect_completed(state, side, eid))

static func _install_ice_3(ice, ices, grids, server):
	return (func():
		var remaining = NRCardRT.filter_list(ices, func(x): return not NRCardRT.truthy((func(_pct):
			return NRUtil.same_card(_pct, ice)).call(x)))
		return {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREngine.resolve_ability(state, side, eid, choose_ice(remaining, grids), card, null) if (("None" == server) or NRUtil.kw_eq("None", server)) else NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, ice)
				, func(async_result):
					NRSay.system_msg(state, side, str("reveals that they drew ") + str(NRCardRT.getv(ice, "title")))
					NREid.wait_for(state, eid, func(ne):
						NRInstalling.corp_install(state, side, ne, ice, server, {
							"cost-bonus": -4,
							"msg-keys": {
								"install-source": card,
								"known": true,
								"display-origin": true,
							},
						})
					, func(async_result):
						remove_from_currently_drawing(state, side, ice)
						NREngine.resolve_ability(state, side, eid, (choose_ice(remaining, grids) if not NRCardRT.truthy(((1 == NRCardRT.count_of(ices)) or NRUtil.kw_eq(1, NRCardRT.count_of(ices)))) else null), card, null)))),
	}
).call()

static func _choose_grid_4(ice, ices, grids):
	return (_install_ice_3(ice, ices, grids, NRServers.zone_to_name(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(grids, 0), "zone"), 1))) if ((1 == NRCardRT.count_of(grids)) or NRUtil.kw_eq(1, NRCardRT.count_of(grids))) else {
	"async": true,
	"prompt": str("Choose a server to install ") + str(NRCardRT.getv(ice, "title")),
	"choices": (NRCardRT.as_array(mapv(
		func(_pct):
			return NRServers.zone_to_name(NRCardRT.getv(NRCardRT.getv(_pct, "zone"), 1)),
		grids
	)) + ["None"]),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, _install_ice_3(ice, ices, grids, target), card, null),
})

static func _choose_ice_5(ices, grids):
	return ({
	"async": true,
	"prompt": "Choose an ice to reveal and install",
	"choices": (NRCardRT.as_array(mapv("title", ices)) + ["None"]),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, (_choose_grid_4(
			NRCardRT.some_list(ices, func(_pct):
				return (_pct if NRCardRT.truthy(((target == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(target, NRCardRT.getv(_pct, "title")))) else null)),
			ices,
			grids
		) if not NRCardRT.truthy((("None" == target) or NRUtil.kw_eq("None", target))) else null), card, null),
} if NRCardRT.truthy(NRCardRT.seq_of(ices)) else null)

static func _wt_6(n):
	return {
	"waiting-prompt": true,
	"prompt": "Choose an installed card to trash",
	"async": true,
	"interactive": func(state, side, eid, card, targets):
		return true,
	"player": "runner",
	"choices": {
		"all": true,
		"max": n,
		"card": func(_pct):
			return (NRCard.runner(_pct) and NRCard.installed(_pct)),
	},
	"msg": func(state, side, eid, card, targets):
		return str("force the Runner to trash ") + str(NRCardRT.enumerate_cards(targets)),
	"effect": func(state, side, eid, card, targets):
		return NRMoving.trash_cards(
			state,
			"runner",
			eid,
			targets,
			{
				"unpreventable": true,
				"cause-card": card,
				"cause": "forced-to-trash",
			}
		),
}

static func _ability_7():
	return {
	"trace": {
		"base": 4,
		"successful": {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str((func():
					var n = mini(2, NRCardRT.count_of(NRBoard.all_installed(state, "runner")))
					return str("force the runner to trash ") + str(NRCardRT.quantify(n, "installed card")) + str(("but there are no installed cards to trash" if NRCardRT.truthy((not NRCardRT.truthy(NRCardRT.pos(n)))) else null))
				).call()),
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, (func():
					var n = mini(2, NRCardRT.count_of(NRBoard.all_installed(state, "runner")))
					return (_wt_6(n) if NRCardRT.truthy(NRCardRT.pos(n)) else null)
				).call(), card, null),
		},
	},
}

static func _valid_target_fn_8(context, card):
	return (same_server(card, NRCardRT.getv(context, "card")) and NRCard.corp(NRCardRT.getv(context, "card")) and NRCard.installed(NRCardRT.getv(context, "card")))
