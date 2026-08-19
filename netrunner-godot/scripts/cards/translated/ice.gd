class_name NRCardsIce
extends RefCounted

## Port of game.cards.ice — translated from Jinteki.net Clojure.


static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Ablative Barrier", NRUtil.merge({
		"title": "Ablative Barrier",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Threat 3 → When you rez this ice during a run against this server, you may install 1 non-agenda card from HQ or Archives in the root of or protecting another server. <em>(This ability is active if any player has 3 or more agenda points.)</em>\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"on-rez": {
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return NRThreat.threat(state, int(3)) and run and this_server,
			"prompt": "Choose a non-agenda card to install from Archives or HQ in another server",
			"waiting-prompt": true,
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.corp_installable_type(_pct) and (not NRCardRT.truthy(NRCard.agenda(_pct))) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var this_ = NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1))
					var nice = target
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a server",
						"waiting-prompt": true,
						"choices": func(state, side, eid, card, targets):
							return NRCardRT.filter_list(NRBoard.installable_servers(state, nice), func(x): return not NRCardRT.truthy((func(_pct):
								return ((this_ == _pct) or NRUtil.kw_eq(this_, _pct))).call(x))),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRInstalling.corp_install(
								state,
								side,
								eid,
								nice,
								target,
								{
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								}
							),
					}, card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("Anemone", NRUtil.merge({
		"title": "Anemone",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "When you rez this ice during a run against this server, you may trash 1 card from HQ to do 2 net damage.\n[subroutine] Do 1 net damage."
	}, {
		"on-rez": {
			"optional": {
				"prompt": "Trash a card from HQ to do 2 net damage?",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return (0 < NRCardRT.count_of(NRCardRT.getv(corp, "hand"))) and run and this_server,
				"waiting-prompt": true,
				"yes-ability": {
					"msg": "do 2 net damage",
					"cost": [NRPayment.to_c("trash-from-hand", 1)],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(
							state,
							side,
							eid,
							"net",
							2,
							{
								"card": card,
							}
						),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
		"subroutines": [NRDefHelpers.do_net_damage(1)],
	}))
	NRCardDefs.defcard("Ansel 1.0", NRUtil.merge({
		"title": "Ansel 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Sentry - Bioroid - Destroyer",
		"subtypes": ["Sentry", "Bioroid", "Destroyer"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] You may install 1 card from HQ or Archives.\n[subroutine] The Runner cannot steal or trash Corp cards for the remainder of this run."
	}, {
		"subroutines": [_trash_installed_sub(), _install_from_hq_or_archives_sub(), _cannot_steal_or_trash_sub()],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Ansel 2.0", NRUtil.merge({
		"title": "Ansel 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 4,
		"keywords": "Sentry - Bioroid - Destroyer",
		"subtypes": ["Sentry", "Bioroid", "Destroyer"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] Remove 1 card in the heap from the game.\n[subroutine] You may install 1 card from HQ or Archives.\n[subroutine] End the run."
	}, {
		"runner-abilities": [_bioroid_break(2, 2)],
		"subroutines": [
			_trash_installed_sub(),
			{
				"label": "Remove 1 card in the Heap from the game",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.seq_of(NRCardRT.getv(runner, "discard")) and (not NRCardRT.truthy(NRFlags.zone_locked(state, "runner", "discard"))),
				},
				"prompt": "Choose a card in the heap to remove from the game",
				"show-opponent-discard": true,
				"waiting-prompt": true,
				"choices": {
					"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.runner(x)) and NRCardRT.truthy(NRCard.in_discard(x))),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("remove ") + str(NRCardRT.getv(target, "title")) + str(" from the game"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.move(state, "runner", target, "rfg"),
			},
			_install_from_hq_or_archives_sub(),
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Anvil", NRUtil.merge({
		"title": "Anvil",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, you may trash 1 of your other installed cards. If you do, the Runner cannot break this iceʼs printed subroutines for the remainder of this encounter.\n[subroutine] Gain 1[credit]. The Runner loses 1[credit].\n[subroutine] The Runner trashes 1 of their installed cards."
	}, {
		"on-encounter": _encounter_ab_4(),
		"subroutines": [_corps_gains_and_runner_loses_credits(1, 1), _runner_trash_installed_sub()],
	}))
	NRCardDefs.defcard("Afshar", NRUtil.merge({
		"title": "Afshar",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "While this ice is protecting HQ, the Runner cannot break more than 1 of its printed subroutines during each encounter.\n[subroutine] The Runner loses 2[credit].\n[subroutine] End the run."
	}, (func():
		var breakable_fn = func(state, side, eid, card, targets):
			return (NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), func(_pct):
				return (NRCardRT.getv(_pct, "broken") and NRCardRT.getv(_pct, "printed")))) if ((("hq" == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq("hq", NRCardRT.getv(NRCard.get_zone(card), 1))) and ((NRCardRT.getv(card, "title") == "Afshar") or NRUtil.kw_eq(NRCardRT.getv(card, "title"), "Afshar")) and (not NRCardRT.truthy(NREffects.is_disabled_reg(state, card)))) else "unrestricted")
		return {
			"subroutines": [
				NRUtil.merge(_runner_loses_credits(2), {"breakable": breakable_fn}),
				NRUtil.merge(_end_the_run(), {"breakable": breakable_fn})
			],
		}
	).call()))
	NRCardDefs.defcard("Aiki", NRUtil.merge({
		"title": "Aiki",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - Psi - AP",
		"subtypes": ["Code Gate", "Psi", "AP"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, the Runner draws 2 cards.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
	}, {
		"subroutines": [
			_do_psi(
				{
					"label": "Runner draws 2 cards",
					"msg": "make the Runner draw 2 cards",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, "runner", eid, 2),
				}
			),
			NRDefHelpers.do_net_damage(1),
			NRDefHelpers.do_net_damage(1)
		],
	}))
	NRCardDefs.defcard("Aimor", NRUtil.merge({
		"title": "Aimor",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] Trash the top 3 cards of the stack. Trash Aimor."
	}, {
		"subroutines": [
			{
				"async": true,
				"label": "Trash the top 3 cards of the stack",
				"effect": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(NRCardRT.getv(runner, "deck"), int(3)))) + str(" from the top of the stack and trash itself"))
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.mill(state, "corp", ne, "runner", 3)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, "corp", ne, card, {
								"cause": "subroutine",
							})
						, func(async_result):
							NRRuns.encounter_ends(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Akhet", NRUtil.merge({
		"title": "Akhet",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "You can advance this ice.\nWhile there are 3 or more hosted advancement counters, this ice gets +3 strength and the Runner cannot break more than 1 of its printed subroutines during each encounter.\n[subroutine] Gain 1[credit]. Place 1 advancement counter on an installed card.\n[subroutine] End the run."
	}, (func():
		var breakable_fn = func(state, side, eid, card, targets):
			return (NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), func(_pct):
				return (NRCardRT.getv(_pct, "broken") and NRCardRT.getv(_pct, "printed")))) if ((3 <= NRCard.get_counters(card, "advancement")) and ((NRCardRT.getv(card, "title") == "Akhet") or NRUtil.kw_eq(NRCardRT.getv(card, "title"), "Akhet")) and (not NRCardRT.truthy(NREffects.is_disabled_reg(state, card)))) else "unrestricted")
		return {
			"advanceable": "always",
			"subroutines": [
				{
					"label": "Gain 1 [Credit]. Place 1 advancement counter",
					"breakable": breakable_fn,
					"msg": {
						"public": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("gain 1 [Credit] and place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
						"corp": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("gain 1 [Credit] and place 1 advancement counter on ") + str(NRToString.card_str(
								state,
								target,
								{
									"maybe-visible": true,
								}
							)),
					},
					"prompt": "Choose an installed card",
					"choices": {
						"card": NRCard.installed,
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREid.wait_for(state, eid, func(ne):
							NRProps.add_prop(state, side, ne, target, "advance-counter", 1, {
								"placed": true,
							})
						, func(async_result):
							NRGaining.gain_credits(state, side, eid, 1)),
				},
				NRUtil.merge(_end_the_run(), {"breakable": breakable_fn})
			],
			"static-abilities": [
				NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
					return (3 <= NRCard.get_counters(card, "advancement")))
			],
		}
	).call()))
	NRCardDefs.defcard("Anansi", NRUtil.merge({
		"title": "Anansi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 4,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "Whenever an encounter with this ice ends, if the Runner did not fully break it, do 3 net damage.\n[subroutine] Look at the top 5 cards of R&D and arrange them in any order.\n[subroutine] You may draw 1 card. The Runner may pay 2[credit] to draw 1 card.\n[subroutine] Do 1 net damage."
	}, (func():
		var runner_draw = {
			"player": "runner",
			"optional": {
				"waiting-prompt": true,
				"prompt": "Pay 2 [Credits] to draw 1 card?",
				"yes-ability": {
					"async": true,
					"cost": [NRPayment.to_c("credit", 2)],
					"msg": "draw 1 card",
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, "runner", eid, 1),
				},
				"no-ability": {
					"msg": "does not draw 1 card",
				},
			},
		}
		return {
			"subroutines": [
				{
					"msg": "rearrange the top 5 cards of R&D",
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
					},
					"async": true,
					"waiting-prompt": true,
					"effect": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (func():
							var from = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5))
							return NREngine.resolve_ability(state, side, eid, (reorder_choice("corp", "runner", from, null, NRCardRT.count_of(from), from) if NRCardRT.truthy(NRCardRT.pos(NRCardRT.count_of(from))) else null), card, null)
						).call(),
				},
				{
					"label": "Draw 1 card, runner draws 1 card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRDrawing.maybe_draw(state, side, ne, card, 1)
						, func(async_result):
							NREngine.resolve_ability(state, "runner", eid, runner_draw, card, null)),
				},
				NRDefHelpers.do_net_damage(1)
			],
			"events": [
				NRUtil.merge(NRDefHelpers.do_net_damage(3), {"event": "end-of-encounter", "req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (((NRCardRT.getv(context, "ice") == card) or NRUtil.kw_eq(NRCardRT.getv(context, "ice"), card)) and NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.getv(x, "broken")).call(x)))))})
			],
		}
	).call()))
	NRCardDefs.defcard("Archangel", NRUtil.merge({
		"title": "Archangel",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 6,
		"factioncost": 4,
		"keywords": "Code Gate - Tracer - Ambush",
		"subtypes": ["Code Gate", "Tracer", "Ambush"],
		"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, you may pay 3[credit]. If you do, they encounter it.\n[subroutine] Trace[6]. If successful, add 1 installed Runner card to the grip."
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
					return str("Pay 3 [Credits] to force Runner to encounter ") + str(NRCardRT.getv(card, "title")) + str("?"),
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 3)],
					"async": true,
					"msg": "force the Runner to encounter it",
					"effect": func(state, side, eid, card, targets):
						return NRRuns.force_ice_encounter(state, side, eid, card),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
		"subroutines": [_trace_ability(6, _add_runner_card_to_grip())],
	}))
	NRCardDefs.defcard("Archer", NRUtil.merge({
		"title": "Archer",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "As an additional cost to rez this ice, forfeit 1 agenda.\n[subroutine] Gain 2[credit].\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program.\n[subroutine] End the run."
	}, {
		"additional-cost": [NRPayment.to_c("forfeit")],
		"rez-sound": "archer",
		"subroutines": [_gain_credits_sub(2), _trash_program_sub(), _trash_program_sub(), _end_the_run()],
	}))
	NRCardDefs.defcard("Architect", NRUtil.merge({
		"title": "Architect",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "Players cannot trash this ice.\n[subroutine] Look at the top 5 cards of R&D. You may install 1 of those cards, ignoring the install cost.\n[subroutine] You may install 1 card from Archives or HQ."
	}, {
		"static-abilities": [
			{
				"type": "cannot-be-trashed",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
				"value": true,
			}
		],
		"subroutines": [
			{
				"async": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"label": "Look at the top 5 cards of R&D",
				"msg": "look at the top 5 cards of R&D",
				"prompt": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str("The top cards of R&D are (top->bottom) ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5)))),
				"waiting-prompt": true,
				"choices": ["OK"],
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card to install",
						"choices": NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5)), NRCard.corp_installable_type))),
						"async": true,
						"waiting-prompt": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
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
										"origin-index": NRCardRT.getv([], 0),
										"display-origin": true,
									},
								}
							),
					}, card, null),
			},
			_install_from_hq_or_archives_sub()
		],
	}))
	NRCardDefs.defcard("Ashigaru", NRUtil.merge({
		"title": "Ashigaru",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 9,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "This ice gains \"[subroutine] End the run.\" for each card in HQ."
	}, _variable_subs_ice(
		func(state):
			return NRCardRT.count_of(state.get_in(["corp", "hand"], null)),
		_end_the_run()
	)))
	NRCardDefs.defcard("Assassin", NRUtil.merge({
		"title": "Assassin",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 0,
		"keywords": "Sentry - Destroyer - AP - Tracer",
		"subtypes": ["Sentry", "Destroyer", "AP", "Tracer"],
		"text": "[subroutine] Trace[5]. If successful, do 3 net damage.\n[subroutine] Trace[4]. If successful, trash 1 program."
	}, {
		"subroutines": [_trace_ability(5, NRDefHelpers.do_net_damage(3)), _trace_ability(4, _trash_program_sub())],
	}))
	NRCardDefs.defcard("Asteroid Belt", NRUtil.merge({
		"title": "Asteroid Belt",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 9,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Asteroid Belt can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] End the run."
	}, _space_ice(_end_the_run())))
	NRCardDefs.defcard("Attini", NRUtil.merge({
		"title": "Attini",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 6,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "Threat 3 → The Runner cannot spend credits while subroutines on this ice are resolving. <em>(This ability is active if any player has 3 or more agenda points.)</em>\n[subroutine] Do 1 net damage unless the Runner pays 2[credit].\n[subroutine] Do 1 net damage unless the Runner pays 2[credit].\n[subroutine] Do 1 net damage unless the Runner pays 2[credit]."
	}, (func():
		var sub = {
			"label": "Do 1 net damage unless the Runner pays 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRDamage.damage(
					state,
					side,
					eid,
					"net",
					1,
					{
						"card": card,
					}
				) if (NRThreat.threat(state, int(3)) and (not NRCardRT.truthy(NREffects.is_disabled_reg(state, card)))) else NREngine.resolve_ability(state, side, eid, {
					"prompt": "Choose one",
					"waiting-prompt": true,
					"player": "runner",
					"async": true,
					"choices": func(state, side, eid, card, targets):
						return [
							"Take 1 net damage",
							("Pay 2 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", NRUtil.merge(eid, {"source": card, "source-type": "ability"}), card, null, [NRPayment.to_c("credit", 2)])) else null)
						],
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (NRDamage.damage(
							state,
							"corp",
							eid,
							"net",
							1,
							{
								"card": card,
							}
						) if (("Take 1 net damage" == target) or NRUtil.kw_eq("Take 1 net damage", target)) else NREngine.pay(state, "runner", eid, card, NRPayment.to_c("credit", 2))),
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str(("do 1 net damage" if (("Take 1 net damage" == target) or NRUtil.kw_eq("Take 1 net damage", target)) else str("force the runner to ") + str(NRCardRT.decapitalize(target)))),
				}, card, null)),
		}
		return {
			"events": [
				{
					"event": "pre-resolve-subroutine",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRThreat.threat(state, int(3)) and NRUtil.same_card(NRCardRT.getv(context, "ice"), card),
					"silent": true,
					"effect": func(state, side, eid, card, targets):
						return NREffects.register_lingering_effect(
							state,
							side,
							card,
							{
								"type": "cannot-pay-credit",
								"req": func(state, side, eid, card, targets):
									return (("runner" == side) or NRUtil.kw_eq("runner", side)),
								"value": true,
								"duration": "subroutine-currently-resolving",
							}
						),
				}
			],
			"subroutines": [sub, sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Authenticator", NRUtil.merge({
		"title": "Authenticator",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, they may take 1 tag to bypass it.\n[subroutine] The Corp gains 2[credit].\n[subroutine] End the run."
	}, {
		"on-encounter": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (not NRCardRT.truthy(NRCardRT.getv(run, "bypass"))) and (not NRCardRT.truthy(_forced_to_avoid_tags(state, side))),
				"player": "runner",
				"prompt": "Take 1 tag to bypass Authenticator?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRSay.system_msg(state, "runner", "takes 1 tag on encountering Authenticator to bypass it")
						NRRuns.bypass_ice(state)
						return NRTags.gain_tags(
							state,
							"runner",
							eid,
							1,
							{
								"unpreventable": true,
							}
						),
				},
			},
		},
		"subroutines": [_gain_credits_sub(2), _end_the_run()],
	}))
	NRCardDefs.defcard("Bailiff", NRUtil.merge({
		"title": "Bailiff",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Whenever the Runner breaks a subroutine on Bailiff, gain 1[credit].\n[subroutine] End the run."
	}, {
		"on-break-subs": {
			"msg": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return str((func():
					var n_subs = NRCardRT.count_of(NRCardRT.getv(context, "broken-subs"))
					return str("gain ") + str(n_subs) + str(" [Credits] from the runner breaking subs")
				).call()),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return _bailiff_gain_credits_5(state, side, eid, NRCardRT.count_of(NRCardRT.getv(context, "broken-subs"))),
		},
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Ballista", NRUtil.merge({
		"title": "Ballista",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "[subroutine] Trash 1 installed program or end the run."
	}, {
		"subroutines": [_trash_type_or_end_the_run("program", NRCard.program, _trash_program_sub())],
	}))
	NRCardDefs.defcard("Bandwidth", NRUtil.merge({
		"title": "Bandwidth",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] Give the Runner 1 tag. If this run is successful, the Runner removes 1 tag."
	}, {
		"subroutines": [
			{
				"msg": "give the Runner 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRTags.gain_tags(state, "corp", ne, 1)
					, func(async_result):
						NREngine.register_events(
							state,
							side,
							card,
							[
								{
									"event": "successful-run",
									"automatic": "corp-lose-tag",
									"duration": "end-of-run",
									"unregister-once-resolved": true,
									"async": true,
									"msg": "make the Runner lose 1 tag",
									"effect": func(state, side, eid, card, targets):
										return NRTags.lose_tags(state, "corp", eid, 1),
								}
							]
						)
						NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Bastion", NRUtil.merge({
		"title": "Bastion",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Bathynomus", NRUtil.merge({
		"title": "Bathynomus",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 3,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "While this ice is protecting Archives, it gets +3 strength.\n[subroutine] Do 3 net damage."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(3)],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
				return NRCard.protecting_archives(card))
		],
	}))
	NRCardDefs.defcard("Battlement", NRUtil.merge({
		"title": "Battlement",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"factioncost": 4,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine]End the run.\n[subroutine]End the run."
	}, {
		"subroutines": [_end_the_run(), _end_the_run()],
	}))
	NRCardDefs.defcard("Blockchain", NRUtil.merge({
		"title": "Blockchain",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 7,
		"strength": 4,
		"factioncost": 4,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "This ice gains \"[subroutine] Gain 1[credit] and the Runner loses 1[credit].\" before its other subroutines for every 2 faceup <strong>transaction</strong> operations in Archives.\n[subroutine] Gain 1[credit] and the Runner loses 1[credit].\n[subroutine] End the run."
	}, (func():
		var sub_count = func(state):
			return quot(
			NRCardRT.count_of(NRCardRT.filter_list(state.get_in(["corp", "discard"], null), func(_pct):
				return (NRCard.operation(_pct) and NRCard.has_subtype(_pct, "Transaction") and NRCard.faceup(_pct)))),
			2
		)
		var sub = _corps_gains_and_runner_loses_credits(1, 1)
		return {
			"static-abilities": [
				{
					"type": "additional-subroutines",
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRUtil.same_card(card, target),
					"value": func(state, side, eid, card, targets):
						return {
							"position": "front",
							"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(sub, int(sub_count(state)))),
						},
				}
			],
			"subroutines": [sub, _end_the_run()],
		}
	).call()))
	NRCardDefs.defcard("Bloodletter", NRUtil.merge({
		"title": "Bloodletter",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "[subroutine] The Runner must trash either 1 installed program or the top 2 cards of the stack."
	}, {
		"subroutines": [
			{
				"async": true,
				"label": "Runner trashes 1 program or top 2 cards of the stack",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return ((func():
						NRSay.system_msg(state, "runner", "trashes the top 2 cards of the stack")
						return NRMoving.mill(state, "runner", eid, "runner", 2)
					).call() if NRCardRT.empty_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.program)) else NREngine.resolve_ability(state, "runner", eid, {
						"waiting-prompt": true,
						"prompt": "Choose one",
						"choices": func(state, side, eid, card, targets):
							var runner = state.player("runner")
							return [
								("Trash 1 program" if NRCardRT.truthy(NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.program))) else null),
								("Trash the top 2 cards of the stack" if NRCardRT.truthy((1 <= NRCardRT.count_of(NRCardRT.getv(runner, "deck")))) else null)
							],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (NREngine.resolve_ability(state, "runner", eid, _trash_program_sub(), card, null) if ((target == "Trash 1 program") or NRUtil.kw_eq(target, "Trash 1 program")) else (func():
								NRSay.system_msg(state, "runner", "trashes the top 2 cards of the stack")
								return NRMoving.mill(state, "runner", eid, "runner", 2)
							).call()),
					}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Bloom", NRUtil.merge({
		"title": "Bloom",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - Observer",
		"subtypes": ["Code Gate", "Observer"],
		"text": "[subroutine] You may install 1 piece of ice from HQ protecting another server, ignoring all costs.\n[subroutine] You may install 1 piece of ice from HQ directly inward from this ice, ignoring all costs."
	}, {
		"subroutines": [
			{
				"label": "Install a piece of ice from HQ protecting another server, ignoring all costs",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				},
				"prompt": "Choose a piece of ice to install from HQ in another server",
				"async": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.in_hand(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var this_ = NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1))
						var nice = target
						return NREngine.resolve_ability(state, side, eid, {
							"prompt": str("Choose a location to install ") + str(NRCardRT.getv(target, "title")),
							"choices": func(state, side, eid, card, targets):
								return NRCardRT.filter_list(NRBoard.installable_servers(state, nice), func(x): return not NRCardRT.truthy((func(_pct):
									return ((this_ == _pct) or NRUtil.kw_eq(this_, _pct))).call(x))),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRInstalling.corp_install(
									state,
									side,
									eid,
									nice,
									target,
									{
										"ignore-all-cost": true,
										"msg-keys": {
											"install-source": card,
											"display-origin": true,
										},
									}
								),
						}, card, null)
					).call(),
			},
			{
				"label": "Install a piece of ice from HQ in the next innermost position, protecting this server, ignoring all costs",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				},
				"prompt": "Choose a piece of ice to install from HQ in this server",
				"async": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.in_hand(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var run = state.getv("run")
					var run_position = state.get_in(["run", "position"])
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						NRServers.zone_to_name(NRServers.target_server(run)),
						{
							"ignore-all-cost": true,
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
							"index": maxi((int(run_position) - 1), 0),
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Bloop", NRUtil.merge({
		"title": "Bloop",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - AP - Destroyer - Harmonic",
		"subtypes": ["Sentry", "AP", "Destroyer", "Harmonic"],
		"text": "As an additional cost to rez this ice, derez another piece of <strong>harmonic</strong> ice.\n[subroutine] Do 1 core damage.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program."
	}, {
		"additional-cost": [NRPayment.to_c("derez-other-harmonic")],
		"rez-sound": "bloop",
		"subroutines": [NRDefHelpers.do_brain_damage(1), _trash_program_sub(), _trash_program_sub()],
	}))
	NRCardDefs.defcard("Border Control", NRUtil.merge({
		"title": "Border Control",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 1,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[trash]: End the run. Use this ability only during a run on this server.\n[subroutine] Gain 1[credit] for each piece of ice protecting this server.\n[subroutine] End the run."
	}, {
		"abilities": [
			{
				"label": "End the run",
				"msg": "end the run",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return this_server and run,
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card),
			}
		],
		"subroutines": [
			{
				"label": "Gain 1 [Credits] for each ice protecting this server",
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str(NRCardRT.count_of(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices"))) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
						var num_ice = NRCardRT.count_of(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices"))
						return NRGaining.gain_credits(state, "corp", eid, num_ice)
					).call(),
			},
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Boto", NRUtil.merge({
		"title": "Boto",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "Threat 4 → This ice gets +2 strength. <em>(This ability is active if any player has 4 or more agenda points.)</em>\n[subroutine] Do 2 net damage.\n[subroutine] You may trash 1 card from HQ to end the run.\n[subroutine] You may trash 1 card from HQ to end the run."
	}, (func():
		var discard_card_to_end_the_run_sub = {
			"label": "Trash 1 card from HQ to end the run",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"optional": {
				"prompt": "Trash 1 card from HQ to end the run?",
				"yes-ability": {
					"cost": [NRPayment.to_c("trash-from-hand", 1)],
					"msg": "end the run",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRRuns.end_run(state, side, eid, card),
				},
			},
		}
		return {
			"static-abilities": [
				NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
					return (2 if NRThreat.threat(state, int(4)) else 0))
			],
			"subroutines": [
				NRDefHelpers.do_net_damage(2),
				discard_card_to_end_the_run_sub,
				discard_card_to_end_the_run_sub
			],
		}
	).call()))
	NRCardDefs.defcard("Brainstorm", NRUtil.merge({
		"title": "Brainstorm",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 9,
		"strength": 2,
		"factioncost": 4,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "When the Runner encounters this ice, it gains X \"[subroutine] Do 1 core damage.\" subroutines for the remainder of this run. X is equal to the number of cards in the grip."
	}, {
		"on-encounter": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return (func():
					var sub_count = NRCardRT.count_of(NRCardRT.getv(runner, "hand"))
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "additional-subroutines",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRUtil.same_card(card, target),
							"duration": "end-of-run",
							"value": func(state, side, eid, card, targets):
								return {
									"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(NRDefHelpers.do_brain_damage(1), int(sub_count))),
								},
						}
					)
				).call(),
		},
	}))
	NRCardDefs.defcard("Builder", NRUtil.merge({
		"title": "Builder",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[click]: Move this piece of ice to the outermost position protecting any server.\n[subroutine] Place 1 advancement token on a piece of ice protecting this server that can be advanced.\n[subroutine] Place 1 advancement token on a piece of ice protecting this server that can be advanced."
	}, (func():
		var sub = {
			"label": "Place 1 advancement counter on a piece of ice that can be advanced protecting this server",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRCard.can_be_advanced(state, target),
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
			"abilities": [
				{
					"action": true,
					"label": "Move this ice to the outermost position of any server",
					"cost": [NRPayment.to_c("click", 1)],
					"prompt": "Choose a server",
					"choices": func(state, side, eid, card, targets):
						return servers,
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("move itself to the outermost position of ") + str(target),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.move(state, side, card, (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["ices"])),
				}
			],
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Bumi 1.0", NRUtil.merge({
		"title": "Bumi 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Sentry - Bioroid - AP - Destroyer",
		"subtypes": ["Sentry", "Bioroid", "AP", "Destroyer"],
		"text": "When you rez this ice during a run against this server, you may trash 1 installed <strong>trojan</strong> program.\n<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Do 1 core damage."
	}, {
		"subroutines": [_trash_program_sub(), NRDefHelpers.do_brain_damage(1)],
		"runner-abilities": [_bioroid_break(1, 1)],
		"on-rez": {
			"prompt": "Trash a trojan program",
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.program(_pct) and NRCard.has_subtype(_pct, "Trojan")),
			},
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return run and this_server and NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
					return NRCard.has_subtype(_pct, "Trojan")),
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRCardRT.getv(target, "title")),
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
		},
	}))
	NRCardDefs.defcard("Brân 1.0", NRUtil.merge({
		"title": "Brân 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Barrier - Bioroid",
		"subtypes": ["Barrier", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] You may install 1 piece of ice from HQ or Archives directly inward from this ice, ignoring all costs.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [
			{
				"async": true,
				"label": "Install an ice from HQ or Archives",
				"prompt": "Choose an ice to install from Archives or HQ",
				"show-discard": true,
				"waiting-prompt": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRInstalling.corp_install(state, "corp", ne, target, NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1)), {
							"ignore-install-cost": true,
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
							"index": NRCardRT.getv(card, "index"),
						})
					, func(async_result):
						NREid.effect_completed(state, side, eid)),
			},
			_end_the_run(),
			_end_the_run()
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Bullfrog", NRUtil.merge({
		"title": "Bullfrog",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate - Deflector - Psi",
		"subtypes": ["Code Gate", "Deflector", "Psi"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit] or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits and this ice is installed, move this ice to the outermost position protecting another server. <em>(The run continues from this new position.)</em>"
	}, {
		"subroutines": [
			_do_psi(
				{
					"label": "Move this ice to another server",
					"prompt": "Choose a server",
					"choices": func(state, side, eid, card, targets):
						return servers,
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets):
							return NRCard.installed(card),
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("move itself to the outermost position of ") + str(target),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						NRMoving.move(state, side, card, (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["ices"]))
						NRRuns.redirect_run(state, side, target)
						return NREid.effect_completed(state, side, eid),
				}
			)
		],
	}))
	NRCardDefs.defcard("Bulwark", NRUtil.merge({
		"title": "Bulwark",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 10,
		"strength": 8,
		"factioncost": 3,
		"keywords": "Barrier - Liability",
		"subtypes": ["Barrier", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\nWhen the Runner encounters this ice, if there is an installed <strong>AI</strong> program, gain 2[credit].\n[subroutine] The Runner trashes 1 installed program.\n[subroutine] Gain 2[credit]. End the run.\n[subroutine] Gain 2[credit]. End the run."
	}, (func():
		var sub = {
			"msg": "gain 2 [Credits] and end the run",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 2)
				, func(async_result):
					NRRuns.end_run(state, side, eid, card)),
		}
		return {
			"on-rez": _take_bad_pub(),
			"on-encounter": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
						return NRCard.has_subtype(_pct, "AI")),
				"msg": "gain 2 [Credits] if there is an installed AI",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			},
			"subroutines": [_runner_trash_program_sub(), sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Burke Bugs", NRUtil.merge({
		"title": "Burke Bugs",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "[subroutine] Trace[0]. If successful, the Runner trashes 1 program."
	}, {
		"subroutines": [_trace_ability(0, _runner_trash_program_sub())],
	}))
	NRCardDefs.defcard("Caduceus", NRUtil.merge({
		"title": "Caduceus",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] Trace[3]. If successful, the Corp gains 3[credit].\n[subroutine] Trace[2]. If successful, end the run."
	}, {
		"subroutines": [_trace_ability(3, _gain_credits_sub(3)), _trace_ability(2, _end_the_run())],
	}))
	NRCardDefs.defcard("Capacitor", NRUtil.merge({
		"title": "Capacitor",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "While the Runner is tagged, this ice gets +2 strength.\n[subroutine] Gain 1[credit] for each tag the Runner has.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return (2 if NRUtil.is_tagged(state) else 0))
		],
		"subroutines": [
			{
				"label": "Gain 1 [Credits] for each tag the Runner has",
				"async": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return tagged,
				},
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str(count_tags(state)) + str(" [Credits]"),
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, count_tags(state)),
			},
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Cell Portal", NRUtil.merge({
		"title": "Cell Portal",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"strength": 7,
		"factioncost": 2,
		"keywords": "Code Gate - Deflector",
		"subtypes": ["Code Gate", "Deflector"],
		"text": "[subroutine] The Runner moves to the outermost position of the attacked server. They may jack out. Derez this ice."
	}, {
		"subroutines": [
			{
				"async": true,
				"msg": "make the Runner approach the outermost piece of ice",
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (func():
						var server = NRServers.zone_to_name(NRServers.target_server(run))
						NRRuns.redirect_run(state, side, server, "approach-ice")
						return NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, "runner", ne, NRDefHelpers.offer_jack_out(), card, null)
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
								NRRezzing.derez(state, side, ne, card)
							, func(async_result):
								NRRuns.encounter_ends(state, side, eid)))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Changeling", NRUtil.merge({
		"title": "Changeling",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Barrier - Morph",
		"subtypes": ["Barrier", "Morph"],
		"text": "Changeling can be advanced.\nWhile Changeling has an odd number of advancement tokens on it, it gains <strong>sentry</strong> and loses <strong>barrier</strong>.\n[subroutine] End the run."
	}, _morph_ice("Barrier", "Sentry", _end_the_run())))
	NRCardDefs.defcard("Checkpoint", NRUtil.merge({
		"title": "Checkpoint",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 7,
		"factioncost": 2,
		"keywords": "Code Gate - Tracer - Liability",
		"subtypes": ["Code Gate", "Tracer", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trace[5]. If successful, do 3 meat damage when this run becomes successful."
	}, {
		"on-rez": _take_bad_pub(),
		"subroutines": [
			_trace_ability(
				5,
				{
					"label": "Do 3 meat damage when this run is successful",
					"msg": "do 3 meat damage when this run is successful",
					"effect": func(state, side, eid, card, targets):
						return NREngine.register_events(
							state,
							side,
							card,
							[
								{
									"event": "successful-run",
									"automatic": "corp-damage",
									"duration": "end-of-run",
									"async": true,
									"msg": "do 3 meat damage",
									"effect": func(state, side, eid, card, targets):
										return NRDamage.damage(
											state,
											side,
											eid,
											"meat",
											3,
											{
												"card": card,
											}
										),
								}
							]
						),
				}
			)
		],
	}))
	NRCardDefs.defcard("Chetana", NRUtil.merge({
		"title": "Chetana",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - AP - Psi",
		"subtypes": ["Sentry", "AP", "Psi"],
		"text": "[subroutine] Each player gains 2[credit].\n[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, do 1 net damage for each card in the Runner's grip."
	}, {
		"subroutines": [
			{
				"msg": "make each player gain 2 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, 2)
					, func(async_result):
						NRGaining.gain_credits(state, "corp", eid, 2)),
			},
			_do_psi(
				{
					"label": "Do 1 net damage for each card in the grip",
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("do ") + str(NRCardRT.count_of(state.get_in(["runner", "hand"], null))) + str(" net damage"),
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(
							state,
							side,
							eid,
							"net",
							NRCardRT.count_of(state.get_in(["runner", "hand"], null)),
							{
								"card": card,
							}
						),
				}
			)
		],
	}))
	NRCardDefs.defcard("Chimera", NRUtil.merge({
		"title": "Chimera",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Mythic",
		"subtypes": ["Mythic"],
		"text": "When you rez Chimera, choose <strong>sentry</strong>, <strong>code gate</strong>, or <strong>barrier</strong>. Chimera gains that subtype until derezzed.\nWhen a turn ends, derez Chimera.\n[subroutine] End the run."
	}, {
		"on-rez": {
			"prompt": "Choose one subtype",
			"choices": ["Barrier", "Code Gate", "Sentry"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("make itself gain ") + str(target),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRUpdate.update_card(state, side, NRUtil.merge(card, {"subtype-target": target})),
		},
		"static-abilities": [
			{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and NRCardRT.getv(card, "subtype-target"),
				"value": func(state, side, eid, card, targets):
					return NRCardRT.getv(card, "subtype-target"),
			}
		],
		"events": [
			{
				"event": "runner-turn-ends",
				"req": func(state, side, eid, card, targets):
					return NRCard.rezzed(card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, side, eid, card),
			},
			{
				"event": "corp-turn-ends",
				"req": func(state, side, eid, card, targets):
					return NRCard.rezzed(card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, side, eid, card),
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Chiyashi", NRUtil.merge({
		"title": "Chiyashi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 12,
		"strength": 8,
		"factioncost": 2,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "Whenever the Runner breaks a subroutine on Chiyashi while there is an <strong>AI</strong> installed, trash the top 2 cards of the Runner's stack.\n[subroutine] Do 2 net damage.\n[subroutine] Do 2 net damage.\n[subroutine] End the run."
	}, {
		"events": [
			{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
						return NRCard.has_subtype(_pct, "AI"))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return _chiyashi_auto_trash_6(state, "corp", eid, NRCardRT.count_of(NRCardRT.getv(context, "broken-subs"))),
			}
		],
		"subroutines": [NRDefHelpers.do_net_damage(2), NRDefHelpers.do_net_damage(2), _end_the_run()],
	}))
	NRCardDefs.defcard("Chrysalis", NRUtil.merge({
		"title": "Chrysalis",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, they encounter it.\n[subroutine] Do 2 net damage."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"subroutines": [NRDefHelpers.do_net_damage(2)],
		"on-access": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.in_discard(card))),
			"msg": "force the Runner to encounter Chrysalis",
			"effect": func(state, side, eid, card, targets):
				return NRRuns.force_ice_encounter(state, side, eid, card),
		},
	}))
	NRCardDefs.defcard("Chum", NRUtil.merge({
		"title": "Chum",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The next piece of ice the Runner encounters during this run gets +2 strength. When that encounter ends, if the Runner did not fully break that ice, do 3 net damage."
	}, {
		"subroutines": [
			{
				"label": "Give +2 strength to next piece of ice Runner encounters",
				"req": func(state, side, eid, card, targets):
					var this_server = NRCardRT.this_server(state, card)
					return this_server,
				"msg": func(state, side, eid, card, targets):
					return str("give +2 strength to the next piece of ice the Runner encounters"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return NREngine.register_events(
						state,
						side,
						card,
						[
							{
								"event": "encounter-ice",
								"duration": "end-of-run",
								"unregister-once-resolved": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									var context = NRCardRT.ctx(targets)
									return (func():
										var target_ice = NRCardRT.getv(context, "ice")
										NREffects.register_lingering_effect(
											state,
											side,
											card,
											{
												"type": "ice-strength",
												"duration": "end-of-encounter",
												"value": 2,
												"req": func(state, side, eid, card, targets):
													var target = NRCardRT.first_target(targets)
													return NRUtil.same_card(target, target_ice),
											}
										)
										return NREngine.register_events(
											state,
											side,
											card,
											[
												NRUtil.merge(NRDefHelpers.do_net_damage(3), {"event": "end-of-encounter", "duration": "end-of-run", "unregister-once-resolved": true, "req": func(state, side, eid, card, targets):
													var context = NRCardRT.ctx(targets)
													return (NRUtil.same_card(NRCardRT.getv(context, "ice"), target_ice) and NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.getv(x, "broken")).call(x)))))})
											]
										)
									).call(),
							}
						]
					),
			}
		],
	}))
	NRCardDefs.defcard("Clairvoyant Monitor", NRUtil.merge({
		"title": "Clairvoyant Monitor",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - Psi",
		"subtypes": ["Code Gate", "Psi"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, place 1 advancement token on an installed card and end the run."
	}, {
		"subroutines": [
			_do_psi(
				{
					"label": "Place 1 advancement counter and end the run",
					"async": true,
					"prompt": "Choose an installed card to place 1 advancement counter on",
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)) + str(" and end the run"),
					"choices": {
						"card": NRCard.installed,
					},
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREid.wait_for(state, eid, func(ne):
							NRProps.add_prop(state, side, ne, target, "advance-counter", 1, {
								"placed": true,
							})
						, func(async_result):
							NRRuns.end_run(state, side, eid, card)),
				}
			)
		],
	}))
	NRCardDefs.defcard("Cloud Eater", NRUtil.merge({
		"title": "Cloud Eater",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 10,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - AP - Destroyer - Observer",
		"subtypes": ["Sentry", "AP", "Destroyer", "Observer"],
		"text": "Whenever an encounter with this ice ends, if it was rezzed this turn, trash 1 installed Runner card unless the Runner takes 2 tags or suffers 3 net damage.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] Give the Runner 2 tags.\n[subroutine] Do 3 net damage."
	}, {
		"subroutines": [_trash_installed_sub(), NRDefHelpers.give_tags(2), NRDefHelpers.do_net_damage(3)],
		"events": [
			{
				"event": "end-of-encounter",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("this-turn" == NRCardRT.getv(card, "rezzed")) or NRUtil.kw_eq("this-turn", NRCardRT.getv(card, "rezzed"))) and NRUtil.same_card(NRCardRT.getv(context, "ice"), card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose one",
						"player": "runner",
						"choices": func(state, side, eid, card, targets):
							return [
								"Corp trashes 1 Runner card",
								("Take 2 tags" if not NRCardRT.truthy(_forced_to_avoid_tags(state, side)) else null),
								("Suffer 3 net damage" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, NRPayment.to_c("net", 3))) else null)
							],
						"waiting-prompt": true,
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREngine.resolve_ability(state, ("corp" if ((target == "Corp trashes 1 Runner card") or NRUtil.kw_eq(target, "Corp trashes 1 Runner card")) else "runner"), eid, (_trash_installed_sub() if NRCardRT.truthy(((target == "Corp trashes 1 Runner card") or NRUtil.kw_eq(target, "Corp trashes 1 Runner card"))) else ({
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRTags.gain_tags(
										state,
										"runner",
										eid,
										2,
										{
											"unpreventable": true,
										}
									),
							} if NRCardRT.truthy(((target == "Take 2 tags") or NRUtil.kw_eq(target, "Take 2 tags"))) else {
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NREngine.pay(state, "runner", eid, card, [NRPayment.to_c("net", 3)]),
							})), card, targets),
					}, card, null),
			}
		],
	}))
	NRCardDefs.defcard("Cobra", NRUtil.merge({
		"title": "Cobra",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"strength": 1,
		"factioncost": 0,
		"keywords": "Sentry - Destroyer - AP",
		"subtypes": ["Sentry", "Destroyer", "AP"],
		"text": "[subroutine] Trash 1 program.\n[subroutine] Do 2 net damage."
	}, {
		"subroutines": [_trash_program_sub(), NRDefHelpers.do_net_damage(2)],
	}))
	NRCardDefs.defcard("Colossus", NRUtil.merge({
		"title": "Colossus",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "You can advance this ice. It gets +1 strength for each hosted advancement counter.\n[subroutine] Give the Runner 1 tag. If there are 3 or more hosted advancement counters, instead give the Runner 2 tags.\n[subroutine] Trash 1 installed program. If there are 3 or more hosted advancement counters, instead trash 1 installed program and 1 installed resource."
	}, _wall_ice(
		[
			{
				"label": "Give the Runner 1 tag (Give the Runner 2 tags)",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					return str("give the Runner ") + str(("2 tags" if _wonder_sub(card, 3) else "1 tag")),
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "corp", eid, (2 if _wonder_sub(card, 3) else 1)),
			},
			{
				"label": "Trash 1 program (Trash 1 program and 1 resource)",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					return str("trash 1 program") + str((" and 1 resource" if NRCardRT.truthy(_wonder_sub(card, 3)) else null)),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return (NRCardRT.some_list(NRBoard.all_installed(state, "runner"), NRCard.program) or (_wonder_sub(card, 3) and NRCardRT.some_list(NRBoard.all_installed(state, "runner"), NRCard.resource))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, _trash_program_sub(), card, null)
					, func(async_result):
						(NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a resource to trash",
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("trash ") + str(NRCardRT.getv(target, "title")),
							"choices": {
								"card": func(_pct):
									return (NRCard.installed(_pct) and NRCard.resource(_pct)),
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
										"cause": "subroutine",
									}
								),
						}, card, null) if _wonder_sub(card, 3) else NREid.effect_completed(state, side, eid))),
			}
		]
	)))
	NRCardDefs.defcard("Congratulations!", NRUtil.merge({
		"title": "Congratulations!",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - Advertisement",
		"subtypes": ["Code Gate", "Advertisement"],
		"text": "When the Runner passes this ice, gain 1[credit].\n[subroutine] Gain 2[credit]. The Runner gains 1[credit]."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), card),
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 1),
			}
		],
		"subroutines": [
			{
				"label": "Gain 2 [Credits]. The Runner gains 1 [Credits]",
				"msg": "gain 2 [Credits]. The Runner gains 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "corp", ne, 2)
					, func(async_result):
						NRGaining.gain_credits(state, "runner", eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("Conundrum", NRUtil.merge({
		"title": "Conundrum",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 8,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "Conundrum has +3 strength if there is an installed <strong>AI</strong>.\n[subroutine] The Runner trashes an installed program.\n[subroutine] The Runner loses [click], if able.\n[subroutine] End the run."
	}, {
		"subroutines": [_runner_trash_program_sub(), _runner_loses_click(), _end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
					return NRCard.has_subtype(_pct, "AI")))
		],
	}))
	NRCardDefs.defcard("Cortex Lock", NRUtil.merge({
		"title": "Cortex Lock",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 1 net damage for each unused MU the Runner has."
	}, {
		"subroutines": [
			{
				"label": "Do 1 net damage for each unused memory unit the Runner has",
				"msg": func(state, side, eid, card, targets):
					return str("do ") + str(NRMemory.available_mu(state)) + str(" net damage"),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRMemory.available_mu(state)),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"net",
						NRMemory.available_mu(state),
						{
							"card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Crick", NRUtil.merge({
		"title": "Crick",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "Crick has +3 strength while protecting Archives.\n[subroutine] Install a card from Archives (paying its install cost)."
	}, {
		"subroutines": [_install_from_archives_sub()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
				return NRCard.protecting_archives(card))
		],
	}))
	NRCardDefs.defcard("Curtain Wall", NRUtil.merge({
		"title": "Curtain Wall",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 14,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "If Curtain Wall is the outermost piece of ice protecting a server, it has +4 strength.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run(), _end_the_run(), _end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(4, func(state, side, eid, card, targets):
				return (func():
					var ices = NRCardRT.getv(NRBoard.card_to_server(state, card), "ices")
					return NRUtil.same_card(card, (func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(ices)))
				).call())
		],
		"events": [
			{
				"event": "trash",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (not NRCardRT.truthy(NRUtil.same_card(card, target))) and ((NRBoard.card_to_server(state, card) == NRBoard.card_to_server(state, target)) or NRUtil.kw_eq(NRBoard.card_to_server(state, card), NRBoard.card_to_server(state, target))),
				"effect": func(state, side, eid, card, targets):
					return NRIce.update_ice_strength(state, side, card),
			},
			{
				"event": "corp-install",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (not NRCardRT.truthy(NRUtil.same_card(card, NRCardRT.getv(context, "card")))) and ((NRBoard.card_to_server(state, card) == NRBoard.card_to_server(state, NRCardRT.getv(context, "card"))) or NRUtil.kw_eq(NRBoard.card_to_server(state, card), NRBoard.card_to_server(state, NRCardRT.getv(context, "card")))),
				"effect": func(state, side, eid, card, targets):
					return NRIce.update_ice_strength(state, side, card),
			}
		],
	}))
	NRCardDefs.defcard("Data Hound", NRUtil.merge({
		"title": "Data Hound",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Sentry - Tracer - Observer",
		"subtypes": ["Sentry", "Tracer", "Observer"],
		"text": "[subroutine] Trace[2]. If successful, look at the top X cards of the stack, where X is equal to the amount by which your trace strength exceeded the Runner's link strength. Trash 1 of those cards and arrange the rest in any order."
	}, {
		"subroutines": [
			_trace_ability(
				2,
				{
					"async": true,
					"label": "Look at the top cards of the stack",
					"change-in-game-state": {
						"req": func(state, side, eid, card, targets):
							var runner = state.player("runner")
							return NRCardRT.seq_of(NRCardRT.getv(runner, "deck")),
						"silent": true,
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var runner = state.player("runner")
						return str("look at ") + str(NRCardRT.quantify(mini((target - NRCardRT.getv(targets, 1)), NRCardRT.count_of(NRCardRT.getv(runner, "deck"))), "card")) + str(" from the top of the stack"),
					"waiting-prompt": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var runner = state.player("runner")
						return (func():
							var c = (target - NRCardRT.getv(targets, 1))
							var from = NRCardRT.take_n(NRCardRT.getv(runner, "deck"), int(c))
							return (NREngine.resolve_ability(state, side, eid, _dh_trash_7(from), card, null) if (1 < c) else NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, side, ne, NRCardRT.getv(from, 0), {
									"unpreventable": true,
									"cause": "subroutine",
								})
							, func(async_result):
								NRSay.system_msg(state, "corp", str("trashes ") + str(NRCardRT.getv(NRCardRT.getv(from, 0), "title")))
								NREid.effect_completed(state, side, eid)))
						).call(),
				}
			)
		],
	}))
	NRCardDefs.defcard("Data Loop", NRUtil.merge({
		"title": "Data Loop",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 7,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner encounters this ice, they add 2 cards from the grip to the top of the stack.\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run."
	}, {
		"on-encounter": {
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NREngine.resolve_ability(state, "runner", eid, (func():
					var n = mini(2, NRCardRT.count_of(NRCardRT.getv(runner, "hand")))
					return {
						"prompt": str("Choose ") + str(NRCardRT.quantify(n, "card")) + str(" in the grip to add to the top of the stack (second card targeted will be topmost)"),
						"choices": {
							"max": n,
							"all": true,
							"card": func(_pct):
								return (NRCard.in_hand(_pct) and NRCard.runner(_pct)),
						},
						"msg": func(state, side, eid, card, targets):
							return str("add ") + str(NRCardRT.quantify(n, "card")) + str(" from the grip to the top of the stack"),
						"effect": func(state, side, eid, card, targets):
							return (func():
								for c in NRCardRT.as_array(targets):
									NRMoving.move(
								state,
								"runner",
								c,
								"deck",
								{
									"front": true,
								}
							)
								return null
							).call(),
					}
				).call(), card, null),
		},
		"subroutines": [_end_the_run_if_tagged(), _end_the_run()],
	}))
	NRCardDefs.defcard("Data Mine", NRUtil.merge({
		"title": "Data Mine",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Trap - AP",
		"subtypes": ["Trap", "AP"],
		"text": "[subroutine] Do 1 net damage. Trash Data Mine."
	}, {
		"subroutines": [
			{
				"msg": "do 1 net damage and trash itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRDamage.damage(state, "runner", ne, "net", 1, {
							"card": card,
						})
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, "corp", ne, card, {
								"cause": "subroutine",
							})
						, func(async_result):
							NRRuns.encounter_ends(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Data Raven", NRUtil.merge({
		"title": "Data Raven",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Tracer - Observer",
		"subtypes": ["Sentry", "Tracer", "Observer"],
		"text": "When the Runner encounters this ice, they must take 1 tag or end the run.\n<strong>Hosted power counter:</strong> Give the Runner 1 tag.\n[subroutine] Trace[3]. If successful, place 1 power counter on this ice."
	}, {
		"abilities": [_power_counter_ability(NRDefHelpers.give_tags(1))],
		"on-encounter": {
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str((NRCardRT.decapitalize(target) if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else str("force the runner to ") + str(NRCardRT.decapitalize(target)) + str(" on encountering it"))),
			"player": "runner",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Take 1 tag", "End the run"],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRTags.gain_tags(state, "runner", eid, 1) if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else NRRuns.end_run(state, "runner", eid, card)),
		},
		"subroutines": [_trace_ability(3, _gain_power_counter())],
	}))
	NRCardDefs.defcard("Data Ward", NRUtil.merge({
		"title": "Data Ward",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"strength": 8,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner encounters this ice, they take 1 tag unless they pay 3[credit].\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged."
	}, {
		"on-encounter": {
			"player": "runner",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the runner to ") + str(NRCardRT.decapitalize(target)) + str(" on encountering it"),
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
					("Pay 3 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, NRPayment.to_c("credit", 3))) else null),
					"Take 1 tag"
				],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", 3))
				, func(async_result):
					NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid)) if ((target == "Pay 3 [Credits]") or NRUtil.kw_eq(target, "Pay 3 [Credits]")) else NRTags.gain_tags(state, "runner", eid, 1)),
		},
		"subroutines": [
			_end_the_run_if_tagged(),
			_end_the_run_if_tagged(),
			_end_the_run_if_tagged(),
			_end_the_run_if_tagged()
		],
	}))
	NRCardDefs.defcard("Datapike", NRUtil.merge({
		"title": "Datapike",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner must pay 2[credit], if able. If the Runner cannot pay 2[credit], end the run.\n[subroutine] End the run."
	}, {
		"subroutines": [
			{
				"async": true,
				"label": "Runner must pay 2 [Credits]. If they cannot, end the run",
				"effect": func(state, side, eid, card, targets):
					var async_result = NREid.result_of(eid)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", 2))
					, func(async_result):
						((func():
							NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
							return NREid.effect_completed(state, side, eid)
						).call() if NRCardRT.getv(async_result, "cost-paid") else NRRuns.end_run(state, "corp", eid, card))),
			},
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Diviner", NRUtil.merge({
		"title": "Diviner",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "[subroutine] Do 1 net damage. If you trash a card this way with a printed play or install cost that is an odd number, end the run. <em>(0 is not odd.)</em>"
	}, {
		"subroutines": [
			{
				"label": "Do 1 net damage",
				"async": true,
				"msg": "do 1 net damage",
				"effect": func(state, side, eid, card, targets):
					var async_result = NREid.result_of(eid)
					return NREid.wait_for(state, eid, func(ne):
						NRDamage.damage(state, "corp", ne, "net", 1, {
							"card": card,
						})
					, func(async_result):
						(func():
							var _v_8 = async_result
							var trashed_card = NRCardRT.getv(_v_8, 0)
							return (NREid.effect_completed(state, side, eid) if NRCardRT.truthy((trashed_card == null)) else ((func():
								NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to end the run"))
								return NRRuns.end_run(state, "corp", eid, card)
							).call() if NRCardRT.truthy((int(NRCardRT.getv(trashed_card, "cost")) % 2 == 1)) else NREid.effect_completed(state, side, eid)))
						).call()),
			}
		],
	}))
	NRCardDefs.defcard("DNA Tracker", NRUtil.merge({
		"title": "DNA Tracker",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 8,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "[subroutine] Do 1 net damage. The Runner loses 2[credit].\n[subroutine] Do 1 net damage. The Runner loses 2[credit].\n[subroutine] Do 1 net damage. The Runner loses 2[credit]."
	}, (func():
		var sub = {
			"msg": "do 1 net damage and make the Runner lose 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDamage.damage(state, side, ne, "net", 1, {
						"card": card,
					})
				, func(async_result):
					NRGaining.lose_credits(state, "runner", eid, 2)),
		}
		return {
			"subroutines": [sub, sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Doomscroll", NRUtil.merge({
		"title": "Doomscroll",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - AP - Observer",
		"subtypes": ["Sentry", "AP", "Observer"],
		"text": "[subroutine] Give the Runner 1 tag.\n[subroutine] Do 1 net damage.\n[subroutine] Do 2 net damage if the Runner has at least 2 tags."
	}, {
		"subroutines": [
			NRDefHelpers.give_tags(1),
			NRDefHelpers.do_net_damage(1),
			NRUtil.merge(NRDefHelpers.do_net_damage(2), {"label": "Do 2 net damage if the runner has 2 tags", "change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (count_tags(state) >= 2),
			}})
		],
	}))
	NRCardDefs.defcard("Dracō", NRUtil.merge({
		"title": "Dracō",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "When you rez this ice, you may spend any number of credits to place that many power counters on it.\nThis ice gets +1 strength for each hosted power counter.\n[subroutine] Trace[2]. If successful, give the Runner 1 tag and end the run."
	}, {
		"on-rez": {
			"prompt": "How many power counters do you want to place?",
			"choices": "credit",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place ") + str(NRCardRT.quantify(target, "power counter")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRProps.add_counter(state, side, ne, card, "power", target, null)
				, func(async_result):
					NRIce.update_ice_strength(state, side, card)
					NREid.effect_completed(state, side, eid)),
		},
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "power"))
		],
		"subroutines": [
			_trace_ability(
				2,
				{
					"label": "Give the Runner 1 tag and end the run",
					"msg": "give the Runner 1 tag and end the run",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRTags.gain_tags(state, "corp", ne, 1)
						, func(async_result):
							NRRuns.end_run(state, "corp", eid, card)),
				}
			)
		],
	}))
	NRCardDefs.defcard("Drafter", NRUtil.merge({
		"title": "Drafter",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "[subroutine] You may add 1 card from Archives to HQ.\n[subroutine] You may install 1 card from Archives or HQ, ignoring all costs."
	}, {
		"subroutines": [
			corp_recur(),
			_install_from_hq_or_archives_sub(
				{
					"ignore-all-cost": true,
				}
			)
		],
	}))
	NRCardDefs.defcard("Echo", NRUtil.merge({
		"title": "Echo",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Barrier - Harmonic",
		"subtypes": ["Barrier", "Harmonic"],
		"text": "Whenever you rez a piece of <strong>harmonic</strong> ice, place 1 power counter on this ice.\nThis ice gains \"[subroutine] End the run.\" for each hosted power counter."
	}, {
		"rez-sound": "echo",
		"events": [
			{
				"event": "rez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.has_subtype(NRCardRT.getv(context, "card"), "Harmonic") and NRCard.ice(NRCardRT.getv(context, "card")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
				"value": func(state, side, eid, card, targets):
					return {
						"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(_end_the_run(), int(NRCard.get_counters(card, "power")))),
					},
			}
		],
	}))
	NRCardDefs.defcard("Eli 1.0", NRUtil.merge({
		"title": "Eli 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Barrier - Bioroid",
		"subtypes": ["Barrier", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run(), _end_the_run()],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Eli 2.0", NRUtil.merge({
		"title": "Eli 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Barrier - Bioroid",
		"subtypes": ["Barrier", "Bioroid"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] You may draw 1 card.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [_maybe_draw_sub(1), _end_the_run(), _end_the_run()],
		"runner-abilities": [_bioroid_break(2, 2)],
	}))
	NRCardDefs.defcard("Empiricist", NRUtil.merge({
		"title": "Empiricist",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Sentry - AP - Observer",
		"subtypes": ["Sentry", "AP", "Observer"],
		"text": "[subroutine] Draw 1 card. You may add 1 card from HQ to the top of R&D.\n[subroutine] Do 1 net damage. Give the Runner 1 tag.\n[subroutine] Do 2 net damage."
	}, {
		"subroutines": [
			{
				"label": "Draw 1 card. You may add 1 card from HQ to the top of R&D.",
				"msg": "draw 1 card",
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, side, ne, 1)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"req": func(state, side, eid, card, targets):
								var corp = state.player("corp")
								return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
							"prompt": "Place a card in HQ on the top of R&D?",
							"msg": {
								"public": "add 1 card in HQ to the top of R&D",
								"corp": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("add facedown ") + str(NRCardRT.getv(target, "title")) + str(" in HQ to the top of R&D"),
							},
							"choices": {
								"card": func(_pct):
									return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
							},
							"async": true,
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
			},
			{
				"label": "Do 1 net damage and give the Runner 1 tag",
				"msg": "do 1 net damage and give the Runner 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRDamage.damage(state, side, ne, "net", 1, {
							"card": card,
							"suppress-checkpoint": true,
						})
					, func(async_result):
						NRTags.gain_tags(state, "corp", eid, 1)),
			},
			NRDefHelpers.do_net_damage(2)
		],
	}))
	NRCardDefs.defcard("Endless EULA", NRUtil.merge({
		"title": "Endless EULA",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit]."
	}, (func():
		var sub = _end_the_run_unless_runner_pays(NRPayment.to_c("credit", 1))
		return {
			"subroutines": [sub, sub, sub, sub, sub, sub],
			"runner-abilities": [
				{
					"req": func(state, side, eid, card, targets):
						return (NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), func(x): return not NRCardRT.truthy((func(_pct):
							return (NRCardRT.getv(_pct, "broken") or ((false == NRCardRT.getv(_pct, "resolve")) or NRUtil.kw_eq(false, NRCardRT.getv(_pct, "resolve"))))).call(x)))) <= NRCosts.total_available_credits(state, "runner", eid, card)),
					"async": true,
					"label": "Pay for all unbroken subs",
					"effect": func(state, side, eid, card, targets):
						return (func():
							var unbroken_subs = NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), func(x): return not NRCardRT.truthy((func(_pct):
								return (NRCardRT.getv(_pct, "broken") or ((false == NRCardRT.getv(_pct, "resolve")) or NRUtil.kw_eq(false, NRCardRT.getv(_pct, "resolve"))))).call(x)))
							var eid = NRUtil.merge(eid, {"source-type": "subroutine"})
							NRUpdate.update_card(state, side, reduce(NRIce.resolve_subroutine, card, unbroken_subs))
							return NREngine.resolve_ability(state, side, eid, _break_fn_9(unbroken_subs, 0), card, null)
						).call(),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Enforcer 1.0", NRUtil.merge({
		"title": "Enforcer 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Bioroid - Destroyer - AP",
		"subtypes": ["Sentry", "Bioroid", "Destroyer", "AP"],
		"text": "As an additional cost to rez this ice, forfeit 1 agenda.\n<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Do 1 core damage.\n[subroutine] Trash 1 installed <strong>console</strong>.\n[subroutine] Trash all installed <strong>virtual</strong> resources."
	}, {
		"additional-cost": [NRPayment.to_c("forfeit")],
		"subroutines": [
			_trash_program_sub(),
			NRDefHelpers.do_brain_damage(1),
			{
				"label": "Trash a console",
				"prompt": "Choose a console to trash",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
							return NRCard.has_subtype(_pct, "Console")),
				},
				"choices": {
					"card": func(_pct):
						return (NRCard.has_subtype(_pct, "Console") and NRCard.installed(_pct)),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause": "subroutine",
						}
					),
			},
			{
				"msg": "trash all virtual resources",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
							return (NRCard.has_subtype(_pct, "Virtual") and NRCard.resource(_pct))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
						var cards = NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
							return NRCard.has_subtype(_pct, "Virtual"))
						return NRMoving.trash_cards(
							state,
							side,
							eid,
							cards,
							{
								"cause": "subroutine",
							}
						)
					).call(),
			}
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Engram Flush", NRUtil.merge({
		"title": "Engram Flush",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate - Observer",
		"subtypes": ["Code Gate", "Observer"],
		"text": "When the Runner encounters this ice, choose a card type. For the remainder of the encounter, whenever you reveal the grip with a subroutine on this ice, you may trash 1 revealed card of the chosen type.\n[subroutine] Reveal the grip.\n[subroutine] Reveal the grip."
	}, (func():
		var sub = {
			"async": true,
			"label": "Reveal the grip",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.getv(runner, "hand"),
			},
			"msg": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return str("reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.getv(runner, "hand"), "sorted")) + str(" from the grip"),
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRRevealing.reveal(state, side, eid, NRCardRT.getv(runner, "hand")),
		}
		return {
			"on-encounter": {
				"prompt": "Choose a card type",
				"choices": ["Event", "Hardware", "Program", "Resource"],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("name ") + str(target),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					var runner = state.player("runner")
					return (func():
						var cardtype = target
						return NREngine.register_events(
							state,
							side,
							card,
							[
								{
									"event": "corp-reveal",
									"duration": "end-of-encounter",
									"req": func(state, side, eid, card, targets):
										var context = NRCardRT.ctx(targets)
										var runner = state.player("runner")
										return NRCardRT.every_list(NRCardRT.getv(context, "cards"), NRCard.in_hand) and ((NRCardRT.count_of(NRCardRT.getv(context, "cards")) == NRCardRT.count_of(NRCardRT.getv(runner, "hand"))) or NRUtil.kw_eq(NRCardRT.count_of(NRCardRT.getv(context, "cards")), NRCardRT.count_of(NRCardRT.getv(runner, "hand")))) and NRCardRT.some_list(NRCardRT.getv(context, "cards"), func(_pct):
											return NRCard.is_type(_pct, cardtype)),
									"async": true,
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return NREngine.resolve_ability(state, side, eid, with_revealed_hand(
											"runner",
											{
												"skip-reveal": true,
											},
											{
												"prompt": "Choose revealed card to trash",
												"choices": {
													"card": func(_pct):
														return (NRCard.runner(_pct) and NRCard.in_hand(_pct) and NRCard.is_type(_pct, cardtype)),
												},
												"msg": func(state, side, eid, card, targets):
													var target = NRCardRT.first_target(targets)
													return str("trash ") + str(NRCardRT.getv(target, "title")) + str(" from the Grip"),
												"async": true,
												"effect": func(state, side, eid, card, targets):
													var target = NRCardRT.first_target(targets)
													return NRMoving.trash(
														state,
														side,
														eid,
														target,
														{
															"cause": "subroutine",
														}
													),
											}
										), card, null),
								}
							]
						)
					).call(),
			},
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Enigma", NRUtil.merge({
		"title": "Enigma",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner loses [click].\n[subroutine] End the run."
	}, {
		"subroutines": [_runner_loses_click(), _end_the_run()],
	}))
	NRCardDefs.defcard("Envelopment", NRUtil.merge({
		"title": "Envelopment",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When you rez this ice, place 4 power counters on it.\nWhen your turn begins, remove 1 hosted power counter.\nThis ice gains \"[subroutine] End the run.\" before its other subroutines for each hosted power counter.\n[subroutine] Trash this ice."
	}, {
		"on-rez": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 4, null),
		},
		"events": [
			{
				"event": "corp-turn-begins",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "power")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", -1, null),
			}
		],
		"subroutines": [
			{
				"label": "Trash this ice",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					return str("trash ") + str(NRCardRT.getv(card, "title")),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(
						state,
						side,
						eid,
						card,
						{
							"cause": "subroutine",
						}
					),
			}
		],
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
				"value": func(state, side, eid, card, targets):
					return {
						"position": "front",
						"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(_end_the_run(), int(NRCard.get_counters(card, "power")))),
					},
			}
		],
	}))
	NRCardDefs.defcard("Envelope", NRUtil.merge({
		"title": "Envelope",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "[subroutine] Do 1 net damage.\n[subroutine] End the run."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(1), _end_the_run()],
	}))
	NRCardDefs.defcard("Errand Boy", NRUtil.merge({
		"title": "Errand Boy",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 1,
		"factioncost": 1,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "[subroutine] The Corp gains 1[credit] or draws 1 card.\n[subroutine] The Corp gains 1[credit] or draws 1 card.\n[subroutine] The Corp gains 1[credit] or draws 1 card."
	}, (func():
		var sub = {
			"async": true,
			"label": "Draw a card or gain 1 [Credits]",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Gain 1 [Credits]", "Draw 1 card"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(NRCardRT.decapitalize(target)),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRGaining.gain_credits(state, "corp", eid, 1) if ((target == "Gain 1 [Credits]") or NRUtil.kw_eq(target, "Gain 1 [Credits]")) else NRDrawing.draw(state, "corp", eid, 1)),
		}
		return {
			"subroutines": [sub, sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Event Horizon", NRUtil.merge({
		"title": "Event Horizon",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 0,
		"factioncost": 3,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "[trash]<strong>:</strong> End the run. Use this ability only during a run against this server.\n[subroutine] Trash 1 installed program unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner pays 3[credit]."
	}, {
		"subroutines": [
			NRCardRT.choose_one_helper(
				{
					"label": "Trash 1 program unless runner pays 3 [Credits]",
					"player": "runner",
				},
				[
					NRCardRT.cost_option([NRPayment.to_c("credit", 3)], "runner"),
					{
						"option": "The Corp trashes a Program",
						"ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREngine.resolve_ability(state, "corp", eid, _trash_program_sub(), card, null),
						},
					}
				]
			),
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 3))
		],
		"abilities": [
			{
				"label": "End the run",
				"msg": "end the run",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return this_server and run,
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card),
			}
		],
	}))
	NRCardDefs.defcard("Excalibur", NRUtil.merge({
		"title": "Excalibur",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 2,
		"strength": 3,
		"factioncost": 0,
		"keywords": "Mythic - Grail",
		"subtypes": ["Mythic", "Grail"],
		"text": "[subroutine] The Runner cannot make another run this turn."
	}, {
		"subroutines": [_prevent_runs_this_turn()],
	}))
	NRCardDefs.defcard("Executive Functioning", NRUtil.merge({
		"title": "Executive Functioning",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 3,
		"keywords": "Code Gate - AP - Tracer",
		"subtypes": ["Code Gate", "AP", "Tracer"],
		"text": "[subroutine] Trace[4]. If successful, do 1 core damage."
	}, {
		"subroutines": [_trace_ability(4, NRDefHelpers.do_brain_damage(1))],
	}))
	NRCardDefs.defcard("ezaM", NRUtil.merge({
		"title": "ezaM",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[click]<strong>:</strong> Swap this ice with another installed piece of ice.\n[subroutine] Look at the top card of R&D. You may add that card to the bottom of R&D.\n[subroutine] Each piece of ice gets +1 strength for the remainder of this run."
	}, {
		"subroutines": [
			{
				"label": "Look at the top card of R&D",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"waiting-prompt": true,
				"prompt": func(state, side, eid, card, targets):
					return str("The top card of R&D is ") + str(state.get_in(["corp", "deck", 0, "title"], null)),
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return [
						("Place it on the bottom of R&D" if NRCardRT.truthy((not ((NRCardRT.count_of(NRCardRT.getv(corp, "deck")) == 1) or NRUtil.kw_eq(NRCardRT.count_of(NRCardRT.getv(corp, "deck")), 1)))) else null),
						"Done"
					],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("look at the top card of R&D") + str((" and add it to the bottom of R&D" if not NRCardRT.truthy(((target == "Done") or NRUtil.kw_eq(target, "Done"))) else null)),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return (NRMoving.move(state, side, NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "deck") if not NRCardRT.truthy(((target == "Done") or NRUtil.kw_eq(target, "Done"))) else null),
			},
			{
				"label": "Each piece of ice gets +1 strength for the remainder of this run.",
				"msg": "give +1 strength to all ice for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						(func():
							var c_ice = card
							return {
								"type": "ice-strength",
								"duration": "end-of-run",
								"value": 1,
							}
						).call()
					)
					return NRIce.update_all_ice(state, side),
			}
		],
		"abilities": [
			{
				"cost": [NRPayment.to_c("click", 1)],
				"action": true,
				"label": "Swap this ice with another installed ice.",
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.ice(target) and NRCard.installed(target) and (not NRCardRT.truthy(NRUtil.same_card(card, target))),
				},
				"msg": {
					"public": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("swap itself with ") + str(NRToString.card_str(state, target)),
					"corp": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("swap itself with ") + str(NRToString.card_str(
							state,
							target,
							{
								"maybe-visible": true,
							}
						)),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.swap_ice(state, side, card, target),
			}
		],
	}))
	NRCardDefs.defcard("F2P", NRUtil.merge({
		"title": "F2P",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "<strong>2[credit]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability, and only if they are not tagged.\n[subroutine] Add 1 installed Runner card to the grip.\n[subroutine] Give the Runner 1 tag."
	}, {
		"subroutines": [_add_runner_card_to_grip(), NRDefHelpers.give_tags(1)],
		"runner-abilities": [
			{
				"async": true,
				"break": 1,
				"break-cost": [NRPayment.to_c("credit", 2)],
				"label": "Break subroutine",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.currently_encountering(state, card),
			}
		],
	}))
	NRCardDefs.defcard("Fairchild", NRUtil.merge({
		"title": "Fairchild",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 9,
		"strength": 8,
		"factioncost": 5,
		"keywords": "Code Gate - Bioroid - AP",
		"subtypes": ["Code Gate", "Bioroid", "AP"],
		"text": "[subroutine] End the run unless the Runner pays 4[credit].\n[subroutine] End the run unless the Runner pays 4[credit].\n[subroutine] End the run unless the Runner trashes 1 of their installed cards.\n[subroutine] End the run unless the Runner suffers 1 core damage."
	}, {
		"subroutines": [
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 4)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 4)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("trash-installed", 1)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("brain", 1))
		],
	}))
	NRCardDefs.defcard("Fairchild 1.0", NRUtil.merge({
		"title": "Fairchild 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Code Gate - Bioroid",
		"subtypes": ["Code Gate", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner must pay 1[credit] or trash 1 of their installed cards.\n[subroutine] The Runner must pay 1[credit] or trash 1 of their installed cards."
	}, (func():
		var sub = {
			"label": "Force the Runner to pay 1 [Credits] or trash an installed card",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"player": "runner",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)]) or NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)])),
			},
			"choices": func(state, side, eid, card, targets):
				return [
					("Pay 1 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)])) else null),
					("Trash an installed card" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)])) else null)
				],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, side, ne, card, NRPayment.to_c("credit", 1))
				, func(async_result):
					NRSay.system_msg(state, side, NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid)) if ((target == "Pay 1 [Credits]") or NRUtil.kw_eq(target, "Pay 1 [Credits]")) else NREngine.resolve_ability(state, "runner", eid, _runner_trash_installed_sub(), card, null)),
		}
		return {
			"subroutines": [sub, sub],
			"runner-abilities": [_bioroid_break(1, 1)],
		}
	).call()))
	NRCardDefs.defcard("Fairchild 2.0", NRUtil.merge({
		"title": "Fairchild 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - Bioroid - AP",
		"subtypes": ["Code Gate", "Bioroid", "AP"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] The Runner must pay 2[credit] or trash 1 of their installed cards.\n[subroutine] The Runner must pay 2[credit] or trash 1 of their installed cards.\n[subroutine] Do 1 core damage."
	}, (func():
		var sub = {
			"label": "Force the Runner to pay 2 [Credits] or trash an installed card",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"player": "runner",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 2)]) or NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)])),
			},
			"choices": func(state, side, eid, card, targets):
				return [
					("Pay 2 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 2)])) else null),
					("Trash an installed card" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)])) else null)
				],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, side, ne, card, NRPayment.to_c("credit", 2))
				, func(async_result):
					NRSay.system_msg(state, side, NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid)) if ((target == "Pay 2 [Credits]") or NRUtil.kw_eq(target, "Pay 2 [Credits]")) else NREngine.resolve_ability(state, "runner", eid, _runner_trash_installed_sub(), card, null)),
		}
		return {
			"subroutines": [sub, sub, NRDefHelpers.do_brain_damage(1)],
			"runner-abilities": [_bioroid_break(2, 2)],
		}
	).call()))
	NRCardDefs.defcard("Fairchild 3.0", NRUtil.merge({
		"title": "Fairchild 3.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Code Gate - Bioroid - AP",
		"subtypes": ["Code Gate", "Bioroid", "AP"],
		"text": "<strong>Lose [click][click][click]:</strong> Break up to 3 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] The Runner must pay 3[credit] or trash 1 of their installed cards.\n[subroutine] The Runner must pay 3[credit] or trash 1 of their installed cards.\n[subroutine] Do 1 core damage or end the run."
	}, (func():
		var sub = {
			"label": "Force the Runner to pay 3 [Credits] or trash an installed card",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"player": "runner",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 3)]) or NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)])),
			},
			"choices": func(state, side, eid, card, targets):
				return [
					("Pay 3 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 3)])) else null),
					("Trash an installed card" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)])) else null)
				],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, side, ne, card, NRPayment.to_c("credit", 3))
				, func(async_result):
					NRSay.system_msg(state, side, NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid)) if NRCardRT.truthy(((target == "Pay 3 [Credits]") or NRUtil.kw_eq(target, "Pay 3 [Credits]"))) else (NREngine.resolve_ability(state, "runner", eid, _runner_trash_installed_sub(), card, null) if NRCardRT.truthy(((target == "Trash an installed card") or NRUtil.kw_eq(target, "Trash an installed card"))) else NREid.effect_completed(state, side, eid))),
		}
		return {
			"subroutines": [
				sub,
				sub,
				{
					"label": "Do 1 core damage or end the run",
					"prompt": "Choose one",
					"waiting-prompt": true,
					"choices": ["Do 1 core damage", "End the run"],
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str(NRCardRT.decapitalize(target)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (NRDamage.damage(
							state,
							side,
							eid,
							"brain",
							1,
							{
								"card": card,
							}
						) if ((target == "Do 1 core damage") or NRUtil.kw_eq(target, "Do 1 core damage")) else NRRuns.end_run(state, "corp", eid, card)),
				}
			],
			"runner-abilities": [_bioroid_break(3, 3)],
		}
	).call()))
	NRCardDefs.defcard("Fenris", NRUtil.merge({
		"title": "Fenris",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - AP - Liability",
		"subtypes": ["Sentry", "AP", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Do 1 core damage.\n[subroutine] End the run."
	}, {
		"on-rez": _take_bad_pub(),
		"subroutines": [NRDefHelpers.do_brain_damage(1), _end_the_run()],
	}))
	NRCardDefs.defcard("Fire Wall", NRUtil.merge({
		"title": "Fire Wall",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Fire Wall can be advanced and gains +1 strength for each advancement token on it.\n[subroutine] End the run."
	}, _wall_ice([_end_the_run()])))
	NRCardDefs.defcard("Flare", NRUtil.merge({
		"title": "Flare",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 9,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - Tracer - AP",
		"subtypes": ["Sentry", "Tracer", "AP"],
		"text": "[subroutine]Trace[6]. If successful, trash 1 piece of hardware, do 2 meat damage (cannot be prevented), and end the run."
	}, {
		"subroutines": [
			_trace_ability(
				6,
				{
					"label": "Trash 1 piece of hardware, do 2 meat damage, and end the run",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, ({
							"prompt": "Choose a piece of hardware to trash",
							"label": "Trash a piece of hardware",
							"choices": {
								"card": NRCard.hardware,
								"all": true,
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("trash ") + str(NRCardRT.getv(target, "title")) + str(", do 2 meat damage, and end the run"),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, target, {
										"cause": "subroutine",
										"suppress-checkpoint": true,
									})
								, func(async_result):
									NREid.wait_for(state, eid, func(ne):
										NRDamage.damage(state, side, ne, "meat", 2, {
											"unpreventable": true,
											"suppress-checkpoint": true,
											"card": card,
										})
									, func(async_result):
										NRRuns.end_run(state, side, eid, card))),
						} if NRCardRT.some_list(NRBoard.all_installed(state, "runner"), NRCard.hardware) else {
							"async": true,
							"msg": "do 2 meat damage and end the run",
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
									NRDamage.damage(state, side, ne, "meat", 2, {
										"unpreventable": true,
										"suppress-checkpoint": true,
										"card": card,
									})
								, func(async_result):
									NRRuns.end_run(state, side, eid, card)),
						}), card, null),
				}
			)
		],
	}))
	NRCardDefs.defcard("Flyswatter", NRUtil.merge({
		"title": "Flyswatter",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When you rez this ice during a run against this server, purge virus counters.\n[subroutine] End the run."
	}, {
		"suppress-rez-sound": func(state, side, eid, card, targets):
			var run = state.getv("run")
			var this_server = NRCardRT.this_server(state, card)
			return (run and this_server and (not NRCardRT.truthy(NREffects.is_disabled_reg(state, card)))),
		"on-rez": {
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return run and this_server,
			"msg": func(state, side, eid, card, targets):
				return str("purge virus counters"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "virus-purge")
				return NRPurging.purge(state, side, eid),
		},
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Flywheel", NRUtil.merge({
		"title": "Flywheel",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "[subroutine] Gain 1[credit]. You may draw 1 card.\n[subroutine] Gain 1[credit]. You may draw 1 card."
	}, (func():
		var sub = {
			"label": "Gain 1 [Credit]. You may draw 1 card",
			"async": true,
			"msg": "gain 1 [Credit]",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 1)
				, func(async_result):
					NRDrawing.maybe_draw(state, side, eid, card, 1)),
		}
		return {
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Formicary", NRUtil.merge({
		"title": "Formicary",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "Whenever the Runner approaches a server, you may rez this ice. If you do, move this ice to the innermost position protecting the approached server. The Runner moves to this ice and encounters it.\n[subroutine] End the run unless the Runner suffers 2 net damage."
	}, {
		"derezzed-events": [
			{
				"event": "approach-server",
				"interactive": func(state, side, eid, card, targets):
					return (not ((NRCardRT.get_autoresolve("auto-fire")(state, side, eid, card, null) == "No") or NRUtil.kw_eq(NRCardRT.get_autoresolve("auto-fire")(state, side, eid, card, null), "No"))),
				"silent": func(state, side, eid, card, targets):
					return ((NRCardRT.get_autoresolve("auto-fire")(state, side, eid, card, null) == "No") or NRUtil.kw_eq(NRCardRT.get_autoresolve("auto-fire")(state, side, eid, card, null), "No")),
				"optional": {
					"prompt": func(state, side, eid, card, targets):
						return str("Rez and move ") + str(NRToString.card_str(
							state,
							card,
							{
								"visible": true,
							}
						)) + str(" to protect the approached server?"),
					"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
					"req": func(state, side, eid, card, targets):
						return NRFlags.can_rez(state, side, card) and NRPayment.can_pay(state, side, eid, card, null, NRRezzing.get_rez_cost(state, side, card, null)),
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var run = state.getv("run")
							var async_result = NREid.result_of(eid)
							return NREid.wait_for(state, eid, func(ne):
								NRRezzing.rez(state, side, ne, card)
							, func(async_result):
								((func():
									NRSay.system_msg(state, side, str("uses Formicary to move itself to the innermost position of the attacked server. The runner is now encountering it"))
									NRMoving.move(
										state,
										side,
										NRCard.get_card(state, card),
										["servers", NRServers.target_server(run), "ices"],
										{
											"front": true,
										}
									)
									state.assoc_in(["run", "position"], 1)
									NRRuns.set_next_phase(state, "encounter-ice")
									NRIce.set_current_ice(state)
									NRIce.update_all_ice(state, side)
									return NRIce.update_all_icebreakers(state, side)
								).call() if NRCardRT.truthy(NRCard.rezzed(NRCardRT.getv(async_result, "card"))) else null)
								NREid.effect_completed(state, side, eid)),
					},
				},
			}
		],
		"subroutines": [_end_the_run_unless_runner_pays(NRPayment.to_c("net", 2))],
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "Formicary rezzing and moving itself on approach")],
	}))
	NRCardDefs.defcard("Free Lunch", NRUtil.merge({
		"title": "Free Lunch",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "<strong>Hosted power counter:</strong> The Runner loses 1[credit].\n[subroutine] Place 1 power counter on Free Lunch.\n[subroutine] Place 1 power counter on Free Lunch."
	}, {
		"abilities": [_power_counter_ability(_runner_loses_credits(1))],
		"subroutines": [_gain_power_counter(), _gain_power_counter()],
	}))
	NRCardDefs.defcard("Funhouse", NRUtil.merge({
		"title": "Funhouse",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, end the run unless the Runner takes 1 tag.\n[subroutine] Give the Runner 1 tag unless they pay 4[credit]."
	}, {
		"on-encounter": {
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str((str("force the runner to ") + str(NRCardRT.decapitalize(target)) + str(" on encountering it") if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else NRCardRT.decapitalize(target))),
			"player": "runner",
			"prompt": "Choose one",
			"choices": func(state, side, eid, card, targets):
				return [
					("Take 1 tag" if not NRCardRT.truthy(_forced_to_avoid_tags(state, "runner")) else null),
					"End the run"
				],
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRTags.gain_tags(
					state,
					"runner",
					eid,
					1,
					{
						"unpreventable": true,
					}
				) if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else NRRuns.end_run(state, "runner", eid, card)),
		},
		"subroutines": [_tag_or_pay_credits(4)],
	}))
	NRCardDefs.defcard("Galahad", NRUtil.merge({
		"title": "Galahad",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 1,
		"keywords": "Barrier - Grail",
		"subtypes": ["Barrier", "Grail"],
		"text": "When the Runner encounters this ice, you may reveal up to 2 pieces of <strong>grail</strong> ice in HQ. For the remainder of this run, this ice gains the subroutines of each revealed piece of ice in the order of your choice.\n[subroutine] End the run."
	}, _grail_ice(_end_the_run())))
	NRCardDefs.defcard("Gatekeeper", NRUtil.merge({
		"title": "Gatekeeper",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "Gatekeeper has +6 strength if you rezzed it this turn.\n[subroutine] Draw up to 3 cards. Reveal up to 3 agendas in HQ and/or Archives, then shuffle those agendas into R&D.\n[subroutine] End the run."
	}, (func():
		var reveal_and_shuffle = {
			"prompt": "Reveal and shuffle up to 3 agendas into R&D",
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct)) and NRCard.agenda(_pct)),
				"max": func(state, side, eid, card, targets):
					return 3,
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, card, {
						"and-then": ", and shuffle [them] into R&D",
					}, targets)
				, func(async_result):
					(func():
						for c in NRCardRT.as_array(targets):
							NRMoving.move(state, "corp", c, "deck")
						return null
					).call()
					NRShuffling.shuffle_zone(state, "corp", "deck")
					NREid.effect_completed(state, "corp", eid)),
			"cancel": NRShuffling.shuffle_deck,
		}
		var draw_reveal_shuffle = {
			"async": true,
			"label": "Draw cards, reveal and shuffle agendas",
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw_up_to(state, side, ne, card, 3)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, reveal_and_shuffle, card, null)),
		}
		return {
			"static-abilities": [
				NRCardRT.ice_strength_bonus(6, func(state, side, eid, card, targets):
					return (("this-turn" == NRCardRT.getv(card, "rezzed")) or NRUtil.kw_eq("this-turn", NRCardRT.getv(card, "rezzed"))))
			],
			"subroutines": [draw_reveal_shuffle, _end_the_run()],
		}
	).call()))
	NRCardDefs.defcard("Gemini", NRUtil.merge({
		"title": "Gemini",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Tracer - AP",
		"subtypes": ["Sentry", "Tracer", "AP"],
		"text": "[subroutine] Trace[2]. If successful, do 1 net damage. If your trace strength is 5 or greater, do 1 net damage."
	}, _constellation_ice(NRDefHelpers.do_net_damage(1))))
	NRCardDefs.defcard("Gold Farmer", NRUtil.merge({
		"title": "Gold Farmer",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Whenever the Runner breaks a printed subroutine on this ice, they lose 1[credit].\n[subroutine] End the run unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner pays 3[credit]."
	}, {
		"implementation": "Auto breaking will break even with too few credits",
		"on-break-subs": {
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return NRCardRT.some_list(NRCardRT.getv(context, "broken-subs"), func(x): return NRCardRT.getv(x, "printed")),
			"msg": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return str((func():
					var n_subs = NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(context, "broken-subs"), func(x): return NRCardRT.getv(x, "printed")))
					return str("force the runner to lose ") + str(n_subs) + str(" [Credits] for breaking printed subs")
				).call()),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return _gf_lose_credits_10(state, side, eid, NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(context, "broken-subs"), func(x): return NRCardRT.getv(x, "printed")))),
		},
		"subroutines": [
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 3)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 3))
		],
	}))
	NRCardDefs.defcard("Grim", NRUtil.merge({
		"title": "Grim",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 0,
		"keywords": "Sentry - Destroyer - Liability",
		"subtypes": ["Sentry", "Destroyer", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trash 1 installed program."
	}, {
		"on-rez": _take_bad_pub(),
		"subroutines": [_trash_program_sub()],
	}))
	NRCardDefs.defcard("Grubber", NRUtil.merge({
		"title": "Grubber",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Barrier - Liability",
		"subtypes": ["Barrier", "Liability"],
		"text": "When you rez this ice, if it is protecting a central server, take 1 bad publicity.\n[subroutine] End the run unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner pays 3[credit]."
	}, {
		"on-rez": {
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return NRCard.protecting_a_central(card),
			},
			"async": true,
			"msg": "take 1 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.gain_bad_publicity(state, side, eid, 1),
		},
		"subroutines": [
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 3)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 3))
		],
	}))
	NRCardDefs.defcard("Guard", NRUtil.merge({
		"title": "Guard",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 0,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "Guard cannot be bypassed.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			{
				"type": "bypass-ice",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
				"value": false,
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Gutenberg", NRUtil.merge({
		"title": "Gutenberg",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "Gutenberg has +3 strength while protecting R&D.\n[subroutine] Trace[7]. If successful, give the Runner 1 tag."
	}, {
		"subroutines": [_tag_trace(7)],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
				return NRCard.protecting_rd(card))
		],
	}))
	NRCardDefs.defcard("Gyri Labyrinth", NRUtil.merge({
		"title": "Gyri Labyrinth",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner's maximum hand size is reduced by 2 until the beginning of the Corp's next turn."
	}, {
		"subroutines": [
			{
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run,
				"label": "Reduce Runner's hand size by 2",
				"msg": "reduce the Runner's maximum hand size by 2 until the start of the next Corp turn",
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
							"value": -2,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Hadrian's Wall", NRUtil.merge({
		"title": "Hadrian's Wall",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 10,
		"strength": 7,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Hadrian's Wall can be advanced and has +1 strength for each advancement token on it.\n[subroutine] End the run.\n[subroutine] End the run."
	}, _wall_ice([_end_the_run(), _end_the_run()])))
	NRCardDefs.defcard("Hafrún", NRUtil.merge({
		"title": "Hafrún",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Barrier - Code Gate",
		"subtypes": ["Barrier", "Code Gate"],
		"text": "When you rez this ice during a run against this server, you may trash 1 card from HQ. If you do, choose 1 installed Runner card. That cardʼs abilities cannot break subroutines for the remainder of that run.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"on-rez": {
			"optional": {
				"prompt": "Trash a card from HQ to prevent subroutines from being broken by a Runner card abilities for the remainder of the run?",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return run and this_server and NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
				"waiting-prompt": true,
				"yes-ability": {
					"cost": [NRPayment.to_c("trash-from-hand", 1)],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, {
							"waiting-prompt": true,
							"prompt": "Choose an installed Runner card",
							"async": true,
							"choices": {
								"card": func(_pct):
									return (NRCard.installed(_pct) and NRCard.runner(_pct)),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("trash 1 card from HQ to prevent subroutines from being broken by ") + str(NRCardRT.getv(target, "title")) + str(" abilities for the remainder of the run"),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (func():
									var t = target
									NREffects.register_lingering_effect(
										state,
										side,
										card,
										{
											"type": "icon",
											"duration": "end-of-run",
											"req": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return NRUtil.same_card(t, target),
											"value": make_icon("H", card),
										}
									)
									NREffects.register_lingering_effect(state, side, card, _prevent_sub_break_by_11(t))
									return NREid.effect_completed(state, side, eid)
								).call(),
						}, card, null),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
	}))
	NRCardDefs.defcard("Hákarl 1.0", NRUtil.merge({
		"title": "Hákarl 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Barrier - Bioroid - AP",
		"subtypes": ["Barrier", "Bioroid", "AP"],
		"text": "When you rez this ice during a run against this server, you may derez another installed card. If you do, the Runner cannot use paid abilities printed on <strong>bioroid</strong> ice for the remainder of this turn.\n<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] End the run."
	}, {
		"runner-abilities": [_bioroid_break(1, 1)],
		"subroutines": [NRDefHelpers.do_brain_damage(1), _end_the_run()],
		"on-rez": {
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return run and this_server and NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.filter_list(NRBoard.get_all_installed(state), func(x): return not NRCardRT.truthy((func(_pct):
					return NRUtil.same_card(card, _pct)).call(x))), NRCard.rezzed))),
			"prompt": "Derez another card to prevent the runner from using printed abilities on bioroid ice this turn?",
			"choices": {
				"not-self": true,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target) and NRCard.rezzed(target),
			},
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRRezzing.derez(state, side, ne, target)
				, func(async_result):
					NRSay.system_msg(state, side, "prevents the runner from using printed abilities on bioroid ice for the rest of the turn")
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "prevent-paid-ability",
							"duration": "end-of-turn",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRCard.ice(target) and (("runner" == side) or NRUtil.kw_eq("runner", side)) and NRCard.has_subtype(target, "Bioroid"),
							"value": true,
						}
					)
					NREid.effect_completed(state, side, eid)),
		},
	}))
	NRCardDefs.defcard("Hagen", NRUtil.merge({
		"title": "Hagen",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Barrier - Destroyer",
		"subtypes": ["Barrier", "Destroyer"],
		"text": "This ice gets −1 strength for each installed <strong>icebreaker</strong>.\n[subroutine] Trash 1 installed program that is not a <strong>decoder</strong>, <strong>fracter</strong>, or <strong>killer</strong>.\n[subroutine] End the run."
	}, {
		"subroutines": [
			{
				"label": "Trash 1 program",
				"prompt": "Choose a program that is not a decoder, fracter or killer",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
							return (NRCard.program(_pct) and (not NRCardRT.truthy(NRCard.has_any_subtype(_pct, ["Decoder", "Fracter", "Killer"]))))),
				},
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.program(_pct) and (not NRCardRT.truthy(NRCard.has_any_subtype(_pct, ["Decoder", "Fracter", "Killer"])))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRPrompts.clear_wait_prompt(state, "runner")
					return NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause": "subroutine",
						}
					),
			},
			_end_the_run()
		],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return (-NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
					return NRCard.has_subtype(_pct, "Icebreaker")))))
		],
	}))
	NRCardDefs.defcard("Hailstorm", NRUtil.merge({
		"title": "Hailstorm",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"strength": 5,
		"factioncost": 4,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] Remove a card in the heap from the game.\n[subroutine] End the run."
	}, {
		"subroutines": [
			{
				"label": "Remove a card in the Heap from the game",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return (not NRCardRT.truthy(NRFlags.zone_locked(state, "runner", "discard"))) and NRCardRT.seq_of(NRCardRT.getv(runner, "discard")),
				},
				"prompt": "Choose a card in the Heap",
				"choices": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.getv(runner, "discard"))),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("remove ") + str(NRCardRT.getv(target, "title")) + str(" from the game"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.move(state, "runner", target, "rfg"),
			},
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Hammer", NRUtil.merge({
		"title": "Hammer",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer - Observer",
		"subtypes": ["Sentry", "Destroyer", "Observer"],
		"text": "During each encounter with this ice, the Runner cannot break more than 1 of its printed subroutines except using <strong>killers</strong>.\n[subroutine] Give the Runner 1 tag.\n[subroutine] Trash 1 installed resource or piece of hardware.\n[subroutine] Trash 1 installed program that is not a <strong>decoder</strong>, <strong>fracter</strong>, or <strong>killer</strong>."
	}, (func():
		var breakable_fn = func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return (NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), func(_pct):
				return (NRCardRT.getv(_pct, "printed") and NRCardRT.getv(_pct, "broken") and (not NRCardRT.truthy(NRCardRT.as_array(NRCardRT.distinct_list(NRCardRT.getv(_pct, "breaker-subtypes"))).has("Killer")))))) or NRCard.has_subtype(target, "Killer"))
		return {
			"static-abilities": [
				{
					"type": "cannot-auto-break-subs-on-ice",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and (not NRCardRT.truthy(NRCard.has_subtype(NRCardRT.getv(context, "breaker"), "Killer"))),
					"value": true,
				}
			],
			"subroutines": [
				NRUtil.merge(NRDefHelpers.give_tags(1), {"breakable": breakable_fn}),
				{
					"label": "Choose a resource or piece of hardware to trash",
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("trash ") + str(NRCardRT.getv(target, "title")),
					"prompt": "Trash a resource or piece of hardware",
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets):
							return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
								return (NRCard.hardware(_pct) or NRCard.resource(_pct))),
					},
					"choices": {
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRCard.installed(target) and (NRCard.hardware(target) or NRCard.resource(target)),
					},
					"async": true,
					"breakable": breakable_fn,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.trash(
							state,
							side,
							eid,
							target,
							{
								"cause": "subroutine",
							}
						),
				},
				{
					"label": "Choose a program to trash that is not a decoder, fracter or killer",
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets):
							return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
								return (NRCard.program(_pct) and (not NRCardRT.truthy(NRCard.has_any_subtype(_pct, ["Decoder", "Fracter", "Killer"]))))),
					},
					"prompt": "Trash a program that is not a decoder, fracter or killer",
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("trash ") + str(NRCardRT.getv(target, "title")),
					"breakable": breakable_fn,
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and NRCard.program(_pct) and (not NRCardRT.truthy(NRCard.has_any_subtype(_pct, ["Decoder", "Fracter", "Killer"])))),
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
								"cause": "subroutine",
							}
						),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Descent", NRUtil.merge({
		"title": "Descent",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Code Gate - Expendable",
		"subtypes": ["Code Gate", "Expendable"],
		"text": "[click], <strong>1[credit]</strong>, <strong>reveal and trash this ice from HQ:</strong> Draw 1 card. Reveal up to 2 agendas in HQ and/or Archives and shuffle them into R&D.\nWhen your turn begins, you may add this ice to HQ.\n[subroutine] End the run."
	}, (func():
		var shuffle_ab = {
			"label": "Draw 1 card and shuffle up to 2 agendas in HQ and/or Archives into R&D",
			"msg": "draw 1 card",
			"async": true,
			"cost": [NRPayment.to_c("credit", 1)],
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-card")
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 1)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose up to 2 agendas in HQ and/or Archives",
						"choices": {
							"max": 2,
							"card": func(_pct):
								return (NRCard.agenda(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
						},
						"async": true,
						"show-discard": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, card, {
									"and-then": " and shuffle [them] into R&D",
								}, targets)
							, func(async_result):
								(func():
									for c in NRCardRT.as_array(targets):
										NRMoving.move(state, "corp", c, "deck")
									return null
								).call()
								NRShuffling.shuffle_zone(state, "corp", "deck")
								NREid.effect_completed(state, side, eid)),
					}, card, null)),
		}
		return {
			"events": [
				{
					"event": "corp-turn-begins",
					"skippable": true,
					"interactive": func(state, side, eid, card, targets):
						return true,
					"req": func(state, side, eid, card, targets):
						return NRCard.rezzed(card),
					"optional": {
						"prompt": func(state, side, eid, card, targets):
							return str("Add ") + str(NRToString.card_str(state, card)) + str(" to HQ?"),
						"yes-ability": {
							"effect": func(state, side, eid, card, targets):
								return NRMoving.move(state, side, card, "hand"),
							"msg": func(state, side, eid, card, targets):
								return str("add ") + str(NRToString.card_str(state, card)) + str(" to HQ"),
						},
					},
				}
			],
			"expend": shuffle_ab,
			"subroutines": [_end_the_run()],
		}
	).call()))
	NRCardDefs.defcard("Harvester", NRUtil.merge({
		"title": "Harvester",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner draws 3 cards and then discards down to their maximum hand size.\n[subroutine] The Runner draws 3 cards and then discards down to their maximum hand size."
	}, (func():
		var sub = {
			"label": "Runner draws 3 cards and discards down to maximum hand size",
			"msg": "make the Runner draw 3 cards and discard down to [runner-pronoun] maximum hand size",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, "runner", ne, 3)
				, func(async_result):
					NREngine.resolve_ability(state, "runner", eid, (func():
						var delta = (NRCardRT.count_of(state.get_in(["runner", "hand"], null)) - NRHandSize.hand_size(state, "runner"))
						return ({
							"prompt": func(state, side, eid, card, targets):
								return str("Choose ") + str(NRCardRT.quantify(delta, "card")) + str(" to discard"),
							"player": "runner",
							"choices": {
								"max": delta,
								"card": func(_pct):
									return NRCard.in_hand(_pct),
							},
							"async": true,
							"display-side": "runner",
							"msg": func(state, side, eid, card, targets):
								return str("discard ") + str(NRCardRT.enumerate_cards(targets)),
							"effect": func(state, side, eid, card, targets):
								return (func():
									var discard = NRCardRT.seq_of(NRCardRT.map_list(targets, func(_pct):
										return NRMoving.move(state, side, _pct, "discard")))
									var ev = ("runner-discard-to-hand-size" if ((side == "runner") or NRUtil.kw_eq(side, "runner")) else "corp-discard-to-hand-size")
									NREngine.queue_event(
										state,
										ev,
										{
											"cards": discard,
										}
									)
									return NREngine.checkpoint(
										state,
										null,
										eid,
										{
											"durations": [ev],
										}
									)
								).call(),
						} if NRCardRT.truthy(NRCardRT.pos(delta)) else null)
					).call(), card, null)),
		}
		return {
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Heimdall 1.0", NRUtil.merge({
		"title": "Heimdall 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 8,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Barrier - Bioroid - AP",
		"subtypes": ["Barrier", "Bioroid", "AP"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [NRDefHelpers.do_brain_damage(1), _end_the_run(), _end_the_run()],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Heimdall 2.0", NRUtil.merge({
		"title": "Heimdall 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 11,
		"strength": 7,
		"factioncost": 3,
		"keywords": "Barrier - Bioroid - AP",
		"subtypes": ["Barrier", "Bioroid", "AP"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage and end the run.\n[subroutine] End the run."
	}, {
		"subroutines": [
			NRDefHelpers.do_brain_damage(1),
			{
				"msg": "do 1 core damage and end the run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRDamage.damage(state, side, ne, "brain", 1, {
							"card": card,
						})
					, func(async_result):
						NRRuns.end_run(state, side, eid, card)),
			},
			_end_the_run()
		],
		"runner-abilities": [_bioroid_break(2, 2)],
	}))
	NRCardDefs.defcard("Herald", NRUtil.merge({
		"title": "Herald",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, they encounter it.\n[subroutine] Gain 2[credit].\n[subroutine] You may pay up to 2[credit] to place that many advancement counters on 1 installed card you can advance."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"subroutines": [
			_gain_credits_sub(2),
			{
				"async": true,
				"label": "Pay up to 2 [Credits] to place up to 2 advancement counters",
				"prompt": "How many advancement counters do you want to place?",
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.map_list(range_((int(mini(2, NRCardRT.getv(corp, "credit"))) + 1)), func(x): return NRCardRT.truthy(str_.call(x) if str_ is Callable else str_)),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var async_result = NREid.result_of(eid)
					return (func():
						var c = str_to_int(target)
						return ((func():
							var new_eid = NREid.make_eid(
								state,
								{
									"source": card,
									"source-type": "subroutine",
								}
							)
							return NREid.wait_for(state, eid, func(ne):
								NREngine.pay(state, "corp", ne, new_eid, card, NRPayment.to_c("credit", c))
							, func(async_result):
								NRSay.system_msg(state, "corp", NRCardRT.getv(async_result, "msg"))
								NREngine.resolve_ability(state, side, eid, {
									"msg": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return str("pay ") + str(c) + str(" [Credits] and place ") + str(NRCardRT.quantify(c, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, target)),
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
											c,
											{
												"placed": true,
											}
										),
								}, card, null))
						).call() if NRPayment.can_pay(state, side, NRUtil.merge(eid, {"source": card, "source-type": "subroutine"}), card, NRCardRT.getv(card, "title"), NRPayment.to_c("credit", c)) else NREid.effect_completed(state, side, eid))
					).call(),
			}
		],
		"on-access": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.in_discard(card))),
			"msg": "force the Runner to encounter Herald",
			"effect": func(state, side, eid, card, targets):
				return NRRuns.force_ice_encounter(state, side, eid, card),
		},
	}))
	NRCardDefs.defcard("Himitsu-Bako", NRUtil.merge({
		"title": "Himitsu-Bako",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "1[credit]: Add Himitsu-Bako to HQ.\n[subroutine] End the run."
	}, {
		"abilities": [
			{
				"msg": "add itself to HQ",
				"cost": [NRPayment.to_c("credit", 1)],
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, side, card, "hand"),
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Hive", NRUtil.merge({
		"title": "Hive",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "This ice loses 1 of its printed \"[subroutine] End the run.\" subroutines for each agenda point in your score area.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			{
				"type": "lose-printed-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
				"value": func(state, side, eid, card, targets):
					return maxi(0, state.get_in(["corp", "agenda-point"], null)),
			}
		],
		"subroutines": [_end_the_run(), _end_the_run(), _end_the_run(), _end_the_run(), _end_the_run()],
	}))
	NRCardDefs.defcard("Holmegaard", NRUtil.merge({
		"title": "Holmegaard",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Tracer - Destroyer",
		"subtypes": ["Sentry", "Tracer", "Destroyer"],
		"text": "[subroutine] Trace[4]. If successful, the Runner cannot access cards or breach the attacked server for the remainder of this run.\n[subroutine] Trash 1 installed <strong>icebreaker</strong>."
	}, {
		"subroutines": [
			_trace_ability(
				4,
				{
					"label": "Runner cannot access any cards this run",
					"msg": "stop the Runner from accessing any cards this run",
					"effect": func(state, side, eid, card, targets):
						return NRRuns.prevent_access(state, side),
				}
			),
			{
				"label": "Trash an icebreaker",
				"prompt": "Choose an icebreaker to trash",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
							return NRCard.has_subtype(_pct, "Icebreaker")),
				},
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Icebreaker")),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRPrompts.clear_wait_prompt(state, "runner")
					return NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause": "subroutine",
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Hortum", NRUtil.merge({
		"title": "Hortum",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "You can advance this ice. If there are 3 or more hosted advancement counters, the Runner cannot break subroutines on this ice using <strong>AI</strong> programs.\n[subroutine] Gain 1[credit]. If there are 3 or more hosted advancement counters, instead gain 4[credit].\n[subroutine] End the run. If there are 3 or more hosted advancement counters, instead search R&D for up to 2 cards. Add those cards to HQ, then end the run."
	}, (func():
		var breakable_fn = func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return ("unrestricted" if NRCardRT.truthy(((3 > NRCard.get_counters(card, "advancement")) or (not NRCardRT.truthy(NRCard.has_subtype(target, "AI"))) or (not ((NRCardRT.getv(card, "title") == "Hortum") or NRUtil.kw_eq(NRCardRT.getv(card, "title"), "Hortum"))) or NREffects.is_disabled_reg(state, card))) else null)
		return {
			"advanceable": "always",
			"subroutines": [
				{
					"label": "Gain 1 [Credits] (Gain 4 [Credits])",
					"breakable": breakable_fn,
					"msg": func(state, side, eid, card, targets):
						return str("gain ") + str(("4" if _wonder_sub(card, 3) else "1")) + str(" [Credits]"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "corp", eid, (4 if _wonder_sub(card, 3) else 1)),
				},
				{
					"label": "End the run (Search R&D for up to 2 cards and add them to HQ, shuffle R&D, end the run)",
					"async": true,
					"breakable": breakable_fn,
					"effect": func(state, side, eid, card, targets):
						return (NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, _hort_13(1), card, null)
						, func(async_result):
							(func():
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to add 2 cards to HQ from R&D, ") + str("shuffle R&D, and end the run"))
								return NRRuns.end_run(state, side, eid, card)
							).call()) if _wonder_sub(card, 3) else (func():
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to end the run"))
								return NRRuns.end_run(state, side, eid, card)
						).call()),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Hourglass", NRUtil.merge({
		"title": "Hourglass",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner loses [click], if able.\n[subroutine] The Runner loses [click], if able.\n[subroutine] The Runner loses [click], if able."
	}, {
		"subroutines": [_runner_loses_click(), _runner_loses_click(), _runner_loses_click()],
	}))
	NRCardDefs.defcard("Howler", NRUtil.merge({
		"title": "Howler",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] You may install and rez 1 piece of <strong>bioroid</strong> ice from HQ or Archives directly inward from this ice, ignoring all costs. When this run ends, if you installed a piece of ice this way, trash this ice and derez the ice you installed."
	}, {
		"subroutines": [
			{
				"label": "Install and rez a piece of Bioroid ice from HQ or Archives",
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.some_list(NRCardRT.concat_lists([NRCardRT.getv(corp, "hand"), NRCardRT.getv(corp, "discard")]), func(_pct):
						return (NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct)) and NRCard.has_subtype(_pct, "Bioroid"))),
				"async": true,
				"prompt": "Choose a piece of Bioroid ice in HQ or Archives to install",
				"show-discard": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct)) and NRCard.has_subtype(_pct, "Bioroid")),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var run = state.getv("run")
					var async_result = NREid.result_of(eid)
					return NREid.wait_for(state, eid, func(ne):
						NRInstalling.corp_install(state, side, ne, target, NRServers.zone_to_name(NRServers.target_server(run)), {
							"ignore-all-cost": true,
							"install-state": "rezzed-no-cost",
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
							"index": NRCard.card_index(state, card),
						})
					, func(async_result):
						(func():
							var new_ice = NRCardRT.getv(async_result, "card")
							NREngine.register_events(
								state,
								side,
								card,
								[
									{
										"event": "run-ends",
										"duration": "end-of-run",
										"async": true,
										"effect": func(state, side, eid, card, targets):
											return NREid.wait_for(state, eid, func(ne):
												NRRezzing.derez(state, side, ne, new_ice, {
													"suppress-checkpoint": true,
													"msg-keys": {
														"and-then": " and trash itself",
													},
												})
											, func(async_result):
												NRMoving.trash(
													state,
													side,
													eid,
													card,
													{
														"cause": "subroutine",
													}
												)),
									}
								]
							)
							return NREid.effect_completed(state, side, eid)
						).call()),
			}
		],
	}))
	NRCardDefs.defcard("Hudson 1.0", NRUtil.merge({
		"title": "Hudson 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate - Bioroid",
		"subtypes": ["Code Gate", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner cannot access more than 1 card during this run.\n[subroutine] The Runner cannot access more than 1 card during this run."
	}, (func():
		var sub = {
			"msg": "prevent the Runner from accessing more than 1 card during this run",
			"effect": func(state, side, eid, card, targets):
				return NRAccess.max_access(state, 1),
		}
		return {
			"subroutines": [sub, sub],
			"runner-abilities": [_bioroid_break(1, 1)],
		}
	).call()))
	NRCardDefs.defcard("Hunter", NRUtil.merge({
		"title": "Hunter",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Sentry - Tracer - Observer",
		"subtypes": ["Sentry", "Tracer", "Observer"],
		"text": "[subroutine] Trace[3]. If successful, give the Runner 1 tag."
	}, {
		"subroutines": [_tag_trace(3)],
	}))
	NRCardDefs.defcard("Hydra", NRUtil.merge({
		"title": "Hydra",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 10,
		"strength": 6,
		"factioncost": 4,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 3 net damage if the Runner is tagged; otherwise, give the Runner 1 tag.\n[subroutine] Gain 5[credit] if the Runner is tagged; otherwise, give the Runner 1 tag.\n[subroutine] End the run if the Runner is tagged; otherwise, give the Runner 1 tag.\n"
	}, {
		"subroutines": [
			_otherwise_tag_14(
				"do 3 net damage",
				func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						"runner",
						eid,
						"net",
						3,
						{
							"card": card,
						}
					)
			),
			_otherwise_tag_14(
				"gain 5 [Credits]",
				func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 5)
			),
			_otherwise_tag_14(
				"end the run",
				func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card)
			)
		],
	}))
	NRCardDefs.defcard("Ice Wall", NRUtil.merge({
		"title": "Ice Wall",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"strength": 1,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "You can advance this ice. It gets +1 strength for each hosted advancement counter.\n[subroutine] End the run."
	}, _wall_ice([_end_the_run()])))
	NRCardDefs.defcard("Ichi 1.0", NRUtil.merge({
		"title": "Ichi 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Bioroid - Tracer - Destroyer",
		"subtypes": ["Sentry", "Bioroid", "Tracer", "Destroyer"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program.\n[subroutine] Trace[1]. If successful, do 1 core damage and give the Runner 1 tag."
	}, {
		"subroutines": [
			_trash_program_sub(),
			_trash_program_sub(),
			_trace_ability(
				1,
				{
					"label": "Give the Runner 1 tag and do 1 core damage",
					"msg": "give the Runner 1 tag and do 1 core damage",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRDamage.damage(state, "runner", ne, "brain", 1, {
								"card": card,
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRTags.gain_tags(state, "corp", eid, 1)),
				}
			)
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Ichi 2.0", NRUtil.merge({
		"title": "Ichi 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Sentry - Bioroid - Destroyer - Tracer",
		"subtypes": ["Sentry", "Bioroid", "Destroyer", "Tracer"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program.\n[subroutine] Trace[3]. If successful, do 1 core damage and give the Runner 1 tag."
	}, {
		"subroutines": [
			_trash_program_sub(),
			_trash_program_sub(),
			_trace_ability(
				3,
				{
					"label": "Give the Runner 1 tag and do 1 core damage",
					"msg": "give the Runner 1 tag and do 1 core damage",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRDamage.damage(state, "runner", ne, "brain", 1, {
								"card": card,
							})
						, func(async_result):
							NRTags.gain_tags(state, "corp", eid, 1)),
				}
			)
		],
		"runner-abilities": [_bioroid_break(2, 2)],
	}))
	NRCardDefs.defcard("Inazuma", NRUtil.merge({
		"title": "Inazuma",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] During the next encounter this run, the Runner cannot break subroutines on the encountered ice.\n[subroutine] The Runner cannot jack out this run until after their next encounter with a piece of ice begins."
	}, {
		"subroutines": [
			{
				"msg": "prevent the Runner from breaking subroutines on the next piece of ice they encounter this run",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						return run,
				},
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NREngine.register_events(
						state,
						side,
						card,
						[
							{
								"event": "encounter-ice",
								"duration": "end-of-run",
								"unregister-once-resolved": true,
								"msg": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									return str("prevent the runner from breaking subroutines on ") + str(NRCardRT.getv(NRCardRT.getv(context, "ice"), "title")),
								"effect": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									return NREffects.register_lingering_effect(
										state,
										side,
										card,
										(func():
											var encountered_ice = NRCardRT.getv(context, "ice")
											return {
												"type": "cannot-break-subs-on-ice",
												"duration": "end-of-encounter",
												"req": func(state, side, eid, card, targets):
													var context = NRCardRT.ctx(targets)
													return NRUtil.same_card(encountered_ice, NRCardRT.getv(context, "ice")),
												"value": true,
											}
										).call()
									),
							}
						]
					),
			},
			{
				"msg": "prevent the Runner from jacking out until after the next piece of ice",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						return run,
				},
				"effect": func(state, side, eid, card, targets):
					return (func():
						var lingering = NREffects.register_lingering_effect(
							state,
							side,
							card,
							{
								"type": "cannot-jack-out",
								"value": true,
								"duration": "end-of-run",
							}
						)
						return NREngine.register_events(
							state,
							side,
							card,
							[
								{
									"event": "encounter-ice",
									"duration": "end-of-run",
									"unregister-once-resolved": true,
									"effect": func(state, side, eid, card, targets):
										return NREffects.unregister_effect_by_uuid(state, side, lingering),
								}
							]
						)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Information Overload", NRUtil.merge({
		"title": "Information Overload",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "When the Runner encounters this ice, Trace[1]. If successful, give them 1 tag.\nThis ice gains \"[subroutine] The Runner trashes 1 of their installed cards.\" for each tag the Runner has."
	}, NRUtil.merge(_variable_subs_ice(
		func(state):
			return count_tags(state),
		_runner_trash_installed_sub()
	), {"on-encounter": _tag_trace(1)})))
	NRCardDefs.defcard("Interrupt 0", NRUtil.merge({
		"title": "Interrupt 0",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] For the remainder of this run, as an additional cost to use an <strong>icebreaker</strong> ability to break subroutines, the Runner must pay 1[credit].\n[subroutine] For the remainder of this run, as an additional cost to use an <strong>icebreaker</strong> ability to break subroutines, the Runner must pay 1[credit]"
	}, (func():
		var sub = {
			"label": "Make the Runner pay 1 [Credits] to use icebreaker",
			"msg": "make the Runner pay 1 [Credits] to use icebreakers to break subroutines during this run",
			"effect": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "break-sub-additional-cost",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							return NRCard.has_subtype(NRCardRT.getv(context, "card"), "Icebreaker") and NRCardRT.as_array(NRCardRT.getv(context, "ability")).has("break") and NRCardRT.pos(NRCardRT.getv(NRCardRT.getv(context, "ability"), "break", 0)),
						"value": NRPayment.to_c("credit", 1),
					}
				),
		}
		return {
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("IP Block", NRUtil.merge({
		"title": "IP Block",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Barrier - Tracer",
		"subtypes": ["Barrier", "Tracer"],
		"text": "When the Runner encounters this ice, give them 1 tag if there is an installed <strong>AI</strong> program.\n[subroutine] Trace[3]. If successful, give the Runner 1 tag.\n[subroutine] End the run if the Runner is tagged."
	}, {
		"on-encounter": NRUtil.merge(NRDefHelpers.give_tags(1), {"req": func(state, side, eid, card, targets):
			return NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
				return NRCard.has_subtype(_pct, "AI"))), "msg": "give the runner 1 tag because there is an installed AI"}),
		"subroutines": [_tag_trace(3), _end_the_run_if_tagged()],
	}))
	NRCardDefs.defcard("IQ", NRUtil.merge({
		"title": "IQ",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "The rez cost of IQ is increased by 1 for each card in HQ.\nIQ has +1 strength for each card in HQ.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.count_of(NRCardRT.getv(corp, "hand")))
		],
		"rez-cost-bonus": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return NRCardRT.count_of(NRCardRT.getv(corp, "hand")),
		"leave-play": func(state, side, eid, card, targets):
			return remove_watch(state, str(str("iq") + str(NRCardRT.getv(card, "cid")))),
	}))
	NRCardDefs.defcard("Ireress", NRUtil.merge({
		"title": "Ireress",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "This ice gains \"[subroutine] The Runner loses 1[credit].\" for each bad publicity you have."
	}, _variable_subs_ice(
		func(state):
			return count_bad_pub(state),
		_runner_loses_credits(1)
	)))
	NRCardDefs.defcard("It's a Trap!", NRUtil.merge({
		"title": "It's a Trap!",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 3,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "Whenever this ice is exposed, do 2 net damage.\n[subroutine] The Runner trashes 1 of their installed cards. Trash this ice."
	}, {
		"on-expose": {
			"msg": "do 2 net damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					2,
					{
						"card": card,
					}
				),
		},
		"subroutines": [
			NRUtil.merge(_runner_trash_installed_sub(), {"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, target, {
						"cause": "subroutine",
					})
				, func(async_result):
					NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash itself"))
					NRMoving.trash(
						state,
						"corp",
						NREid.make_eid(state, eid),
						card,
						{
							"cause": "subroutine",
						}
					)
					NRRuns.encounter_ends(state, side, eid))})
		],
	}))
	NRCardDefs.defcard("Ivik", NRUtil.merge({
		"title": "Ivik",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "The rez cost of this ice is lowered by 1[credit] for each rezzed piece of <strong>code gate</strong> ice.\n[subroutine] Do 2 net damage.\n[subroutine] End the run."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(2), _end_the_run()],
		"rez-cost-bonus": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return (-_subtype_ice_count(corp, "Code Gate")),
	}))
	NRCardDefs.defcard("Jaguarundi", NRUtil.merge({
		"title": "Jaguarundi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "Threat 4 → When the Runner encounters this ice, give them 1 tag unless they spend [click]. <em>(This ability is active if any player has 4 or more agenda points.)</em>\n[subroutine] Give the Runner 1 tag.\n[subroutine] If the Runner is tagged, do 1 core damage."
	}, {
		"on-encounter": {
			"req": func(state, side, eid, card, targets):
				return NRThreat.threat(state, int(4)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREngine.resolve_ability(state, side, eid, {
					"player": "runner",
					"prompt": "Choose one",
					"choices": func(state, side, eid, card, targets):
						return [
							"Take 1 tag",
							("Spend [Click]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", null, card, null, [NRPayment.to_c("click", 1)])) else null)
						],
					"waiting-prompt": true,
					"async": true,
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str(("give the Runner 1 tag" if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else str("force the runner to ") + str(NRCardRT.decapitalize(target)) + str(" on encountering it"))),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var async_result = NREid.result_of(eid)
						return (NRTags.gain_tags(state, "runner", eid, 1) if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else NREid.wait_for(state, eid, func(ne):
							NREngine.pay(state, "runner", ne, card, NRPayment.to_c("click", 1))
						, func(async_result):
							NRSay.system_msg(state, side, NRCardRT.getv(async_result, "msg"))
							NREid.effect_completed(state, "runner", eid))),
				}, card, null),
		},
		"subroutines": [
			NRDefHelpers.give_tags(1),
			{
				"label": "Do 1 core damage if the Runner is tagged",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return tagged,
				},
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
	NRCardDefs.defcard("Janus 1.0", NRUtil.merge({
		"title": "Janus 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 15,
		"strength": 8,
		"factioncost": 3,
		"keywords": "Sentry - Bioroid - AP",
		"subtypes": ["Sentry", "Bioroid", "AP"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage."
	}, {
		"subroutines": [
			NRDefHelpers.do_brain_damage(1),
			NRDefHelpers.do_brain_damage(1),
			NRDefHelpers.do_brain_damage(1),
			NRDefHelpers.do_brain_damage(1)
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Jua", NRUtil.merge({
		"title": "Jua",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "When the Runner encounters this ice, they cannot install cards for the remainder of the turn.\n[subroutine] Choose 2 installed Runner cards, if able. The Runner must add 1 of the chosen cards to the top of the stack."
	}, {
		"on-encounter": {
			"msg": "prevent the Runner from installing cards for the rest of the turn",
			"effect": func(state, side, eid, card, targets):
				return NRFlags.register_turn_flag(state, side, card, "runner-lock-install", (func(_a=null, _b=null, _c=null, _d=null, _e=null): return true)),
		},
		"subroutines": [
			{
				"label": "Choose 2 installed Runner cards, if able. The Runner must add 1 of those to the top of the Stack",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return (NRCardRT.count_of(NRBoard.all_installed(state, "runner")) >= 2),
				},
				"async": true,
				"prompt": "Choose 2 installed Runner cards",
				"choices": {
					"card": func(_pct):
						return (NRCard.runner(_pct) and NRCard.installed(_pct)),
					"max": 2,
					"all": true,
				},
				"msg": func(state, side, eid, card, targets):
					return str("add either ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 0))) + str(" or ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 1))) + str(" to the top of the Stack"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, ({
						"player": "runner",
						"waiting-prompt": true,
						"prompt": "Choose a card to move to the top of the Stack",
						"choices": {
							"card": func(_pct):
								return NRCardRT.some_list(targets, (func(x): return NRUtil.same_card(_pct, x))),
						},
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							NRMoving.move(
								state,
								"runner",
								target,
								"deck",
								{
									"front": true,
								}
							)
							return NRSay.system_msg(state, "runner", str("selected ") + str(NRToString.card_str(state, target)) + str(" to move to the top of the Stack")),
					} if NRCardRT.truthy(((2 == NRCardRT.count_of(targets)) or NRUtil.kw_eq(2, NRCardRT.count_of(targets)))) else null), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Kakugo", NRUtil.merge({
		"title": "Kakugo",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 1,
		"factioncost": 3,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "When the Runner passes Kakugo, do 1 net damage.\n[subroutine] End the run."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), card),
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
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Kamali 1.0", NRUtil.merge({
		"title": "Kamali 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 3,
		"factioncost": 4,
		"keywords": "Sentry - Bioroid - Destroyer - AP",
		"subtypes": ["Sentry", "Bioroid", "Destroyer", "AP"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage unless the Runner trashes 1 installed resource.\n[subroutine] Do 1 core damage unless the Runner trashes 1 installed piece of hardware.\n[subroutine] Do 1 core damage unless the Runner trashes 1 installed program."
	}, {
		"subroutines": [
			_brain_damage_unless_runner_pays_15([NRPayment.to_c("resource", 1)], "resource"),
			_brain_damage_unless_runner_pays_15([NRPayment.to_c("hardware", 1)], "piece of hardware"),
			_brain_damage_unless_runner_pays_15([NRPayment.to_c("program", 1)], "program")
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Karunā", NRUtil.merge({
		"title": "Karunā",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 2 net damage. The Runner may jack out.\n[subroutine] Do 2 net damage."
	}, {
		"subroutines": [
			{
				"label": "Do 2 net damage. The Runner may jack out",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, NRDefHelpers.do_net_damage(2), card, null)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, NRDefHelpers.offer_jack_out(), card, null)),
			},
			NRDefHelpers.do_net_damage(2)
		],
	}))
	NRCardDefs.defcard("Kessleroid", NRUtil.merge({
		"title": "Kessleroid",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "The Runner cannot trash this ice <em>(while it is rezzed)</em>.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			{
				"type": "cannot-be-trashed",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"value": true,
			}
		],
		"subroutines": [_end_the_run(), _end_the_run()],
	}))
	NRCardDefs.defcard("Kitsune", NRUtil.merge({
		"title": "Kitsune",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Mythic - Trap",
		"subtypes": ["Mythic", "Trap"],
		"text": "[subroutine] You may choose 1 card in HQ. If you do, the Runner breaches HQ. During this breach, the Runner cannot access cards in the root of HQ, and the first card they access must be the chosen card. When the breach ends, trash this ice."
	}, {
		"subroutines": [
			{
				"label": "Force the Runner to access a card in HQ",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
					"prompt": "Force the Runner to access a card in HQ?",
					"yes-ability": {
						"async": true,
						"prompt": "Choose a card in HQ",
						"choices": {
							"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.in_hand(x)) and NRCardRT.truthy(NRCard.corp(x))),
							"all": true,
						},
						"label": "Force the Runner to breach HQ and access a card",
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("force the Runner to breach HQ and access ") + str(NRCardRT.getv(target, "title")),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRAccess.breach_server(state, "runner", ne, ["hq"], {
									"no-root": true,
									"access-first": target,
								})
							, func(async_result):
								NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash itself"))
								NRMoving.trash(
									state,
									"corp",
									NREid.make_eid(state, eid),
									card,
									{
										"cause": "subroutine",
									}
								)
								NRRuns.encounter_ends(state, side, eid)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Klevetnik", NRUtil.merge({
		"title": "Klevetnik",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When you rez this ice during a run against this server, you may have the Runner gain 2[credit]. If you do, choose 1 installed resource. That resource loses all abilities until your next turn ends.\n[subroutine] End the run."
	}, (func():
		var on_rez_ability = {
			"prompt": "Choose an installed resource",
			"waiting-prompt": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.resource(_pct)),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("let the Runner gain 2 [Credits] to") + str(" blank the text box of ") + str(NRCardRT.getv(target, "title")) + str(" until the Corp next turn ends"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var t = target
					var duration = ("until-next-corp-turn-ends" if (("corp" == NRCardRT.getv(state.data, "active-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(state.data, "active-player"))) else "until-corp-turn-ends")
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, 2)
					, func(async_result):
						NREffects.register_lingering_effect(
							state,
							side,
							card,
							{
								"type": "disable-card",
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRUtil.same_card(t, target),
								"duration": duration,
								"value": true,
							}
						)
						NREid.effect_completed(state, side, eid))
				).call(),
		}
		return {
			"subroutines": [_end_the_run()],
			"on-rez": {
				"optional": {
					"prompt": "Let the Runner gain 2 [Credits]?",
					"waiting-prompt": true,
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						var this_server = NRCardRT.this_server(state, card)
						return run and this_server and NRCardRT.seq_of(all_installed_runner_type(state, "resource")),
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREngine.resolve_ability(state, side, eid, on_rez_ability, card, null),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
					},
				},
			},
		}
	).call()))
	NRCardDefs.defcard("Knowledge Seeker", NRUtil.merge({
		"title": "Knowledge Seeker",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "Whenever an encounter with this ice ends, if it has 3 or more hosted virus counters, purge virus counters and derez this ice.\n[subroutine] Place 1 virus counter on this ice.\n[subroutine] Look at the top 4 cards of R&D and arrange them in any order.\n[subroutine] End the run."
	}, {
		"events": [
			{
				"event": "end-of-encounter",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return ((NRCardRT.getv(context, "ice") == card) or NRUtil.kw_eq(NRCardRT.getv(context, "ice"), card)) and (NRCard.get_counters(card, "virus") >= 3),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"msg": "purge virus counters and derez itself",
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRRezzing.derez(state, side, ne, card)
					, func(async_result):
						NRSay.play_sfx(state, side, "virus-purge")
						NRPurging.purge(state, side, eid)),
			}
		],
		"subroutines": [
			{
				"label": "Place 1 virus counter on this card",
				"msg": "place 1 virus counter on itself",
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "virus", 1),
				"async": true,
			},
			{
				"label": "Rearrange the top 4 cards of R&D",
				"async": true,
				"waiting-prompt": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, reorder_choice("corp", NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(4))), card, targets),
			},
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Komainu", NRUtil.merge({
		"title": "Komainu",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"strength": 1,
		"factioncost": 4,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "When the Runner encounters this ice, it gains X \"[subroutine] Do 1 net damage.\" subroutines for the remainder of this run. X is equal to the number of cards in the grip."
	}, {
		"on-encounter": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return (func():
					var sub_count = NRCardRT.count_of(NRCardRT.getv(runner, "hand"))
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "additional-subroutines",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRUtil.same_card(card, target),
							"duration": "end-of-run",
							"value": func(state, side, eid, card, targets):
								return {
									"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(NRDefHelpers.do_net_damage(1), int(sub_count))),
								},
						}
					)
				).call(),
		},
	}))
	NRCardDefs.defcard("Konjin", NRUtil.merge({
		"title": "Konjin",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 3,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Mythic - Psi",
		"subtypes": ["Mythic", "Psi"],
		"text": "When the Runner encounters this ice, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, you may choose another rezzed piece of ice. The Runner encounters that ice. <em>(When that encounter ends, if the run has not ended, finish encountering this ice.)</em>"
	}, {
		"on-encounter": _do_psi(
			{
				"async": true,
				"label": "Force the runner to encounter another ice",
				"prompt": "Choose a piece of ice",
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
					"not-self": true,
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("force the Runner to encounter ") + str(NRToString.card_str(state, target)),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRRuns.force_ice_encounter(state, side, eid, target),
			}
		),
	}))
	NRCardDefs.defcard("Lab Dog", NRUtil.merge({
		"title": "Lab Dog",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] The Runner trashes an installed piece of hardware. Trash Lab Dog."
	}, {
		"subroutines": [
			{
				"label": "Force the Runner to trash an installed piece of hardware",
				"player": "runner",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("force the Runner to trash ") + str(NRCardRT.getv(target, "title")) + str(" and trash itself"),
				"prompt": "Choose a piece of hardware to trash",
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.hardware(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, target, {
							"cause": "subroutine",
						})
					, func(async_result):
						NRMoving.trash(
							state,
							"corp",
							NREid.make_eid(state, eid),
							card,
							{
								"cause": "subroutine",
							}
						)
						NRRuns.encounter_ends(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Lamplighter", NRUtil.merge({
		"title": "Lamplighter",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 0,
		"keywords": "Sentry - Observer",
		"subtypes": ["Sentry", "Observer"],
		"text": "When an agenda is scored or stolen from this server or its root, trash this ice.\n[subroutine] Give the Runner 1 tag unless they pay 3[credit].\n[subroutine] End the run if the Runner is tagged."
	}, (func():
		var trash_self = {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"automatic": "pre-draw-cards",
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return (func():
					var target_zone = (NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), 1) or NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), 0))
					var target_zone = ("rd" if NRCardRT.truthy(((target_zone == "deck") or NRUtil.kw_eq(target_zone, "deck"))) else ("hq" if NRCardRT.truthy(((target_zone == "hand") or NRUtil.kw_eq(target_zone, "hand"))) else ("archives" if NRCardRT.truthy(((target_zone == "discard") or NRUtil.kw_eq(target_zone, "discard"))) else target_zone)))
					return ((target_zone == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(target_zone, NRCardRT.getv(NRCard.get_zone(card), 1)))
				).call(),
			"msg": func(state, side, eid, card, targets):
				return str("trash itself"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(
					state,
					"corp",
					eid,
					card,
					{
						"cause-card": card,
						"cause": "effect",
					}
				),
		}
		return {
			"subroutines": [_tag_or_pay_credits(3), _end_the_run_if_tagged()],
			"events": [
				NRUtil.merge(trash_self, {"event": "agenda-scored"}),
				NRUtil.merge(trash_self, {"event": "agenda-stolen"})
			],
		}
	).call()))
	NRCardDefs.defcard("Lancelot", NRUtil.merge({
		"title": "Lancelot",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Sentry - Grail - Destroyer",
		"subtypes": ["Sentry", "Grail", "Destroyer"],
		"text": "When the Runner encounters this ice, you may reveal up to 2 pieces of <strong>grail</strong> ice in HQ. For the remainder of this run, this ice gains the subroutines of each revealed piece of ice in the order of your choice.\n[subroutine] Trash 1 installed program."
	}, _grail_ice(_trash_program_sub())))
	NRCardDefs.defcard("Lethe", NRUtil.merge({
		"title": "Lethe",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 9,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Sentry - Observer",
		"subtypes": ["Sentry", "Observer"],
		"text": "Whenever the Runner bypasses or fully breaks this ice, give them 1 tag.\n[subroutine] You may add 1 card from Archives to the top or bottom of R&D.\n[subroutine] Add 1 installed Runner card to the grip."
	}, {
		"events": [
			NRUtil.merge(NRDefHelpers.give_tags(1), {
				"event": "bypassed-ice",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
			}),
			NRUtil.merge(NRDefHelpers.give_tags(1), {
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), card) and NRCardRT.getv(context, "all-subs-broken"),
			})
		],
		"subroutines": [
			{
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "discard")),
				},
				"label": "add card from Archives to R&D",
				"prompt": "Choose a card to add to the top or bottom of R&D",
				"show-discard": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, move_card_to_top_or_bottom(target, "corp"), card, null),
			},
			_add_runner_card_to_grip()
		],
	}))
	NRCardDefs.defcard("Lionsmane", NRUtil.merge({
		"title": "Lionsmane",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 2 net damage.\n[subroutine] Do 2 net damage unless the Runner pays 3[credit].\n[subroutine] Do 2 net damage unless the Runner jacks out."
	}, {
		"subroutines": (func():
			var two_net_option = {
				"option": "Corp does 2 net damage",
				"ability": {
					"msg": "do 2 net damage",
					"display-side": "corp",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(state, "corp", eid, "net", 2),
				},
			}
			return [
				NRDefHelpers.do_net_damage(2),
				NRCardRT.choose_one_helper(
					{
						"label": "Do 2 net damage unless the Runner pays 3 [Credits]",
						"player": "runner",
					},
					[NRCardRT.cost_option([NRPayment.to_c("credit", 3)], "runner"), two_net_option]
				),
				NRCardRT.choose_one_helper(
					{
						"label": "Do 2 net damage unless the Runner jacks out",
						"player": "runner",
					},
					[
						{
							"option": "Jack out",
							"ability": {
								"msg": "jack out",
								"display-side": "runner",
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRRuns.jack_out(state, "runner", eid),
							},
						},
						two_net_option
					]
				)
			]
		).call(),
	}))
	NRCardDefs.defcard("Little Engine", NRUtil.merge({
		"title": "Little Engine",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 7,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] The Runner gains 5[credit]."
	}, {
		"subroutines": [
			_end_the_run(),
			_end_the_run(),
			{
				"msg": "make the Runner gain 5 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "runner", eid, 5),
			}
		],
	}))
	NRCardDefs.defcard("Lockdown", NRUtil.merge({
		"title": "Lockdown",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner cannot draw cards for the remainder of this turn."
	}, {
		"subroutines": [
			{
				"label": "The Runner cannot draw cards for the remainder of this turn",
				"msg": "prevent the Runner from drawing cards",
				"effect": func(state, side, eid, card, targets):
					return NRFlags.prevent_draw(state, side),
			}
		],
	}))
	NRCardDefs.defcard("Logjam", NRUtil.merge({
		"title": "Logjam",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "You can advance this ice. It gets +1 strength for each hosted advancement counter.\nWhen you rez this ice, place 1 advancement counter on it plus 1 advancement counter for each card type among faceup cards in Archives.\n[subroutine] Gain 2[credit]. End the run.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"advanceable": "always",
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "advancement"))
		],
		"on-rez": {
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str("place ") + str(NRCardRT.quantify((int(_faceup_archives_types(corp)) + 1), "advancement counter")) + str(" on itself"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRProps.add_prop(
					state,
					side,
					eid,
					card,
					"advance-counter",
					(int(_faceup_archives_types(corp)) + 1),
					{
						"placed": true,
					}
				),
		},
		"subroutines": [
			NRCardRT.combine_abilities(_gain_credits_sub(2), _end_the_run()),
			_end_the_run(),
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Loki", NRUtil.merge({
		"title": "Loki",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 6,
		"strength": 3,
		"factioncost": 5,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "When the Runner encounters this ice, choose another rezzed piece of ice. For the remainder of this run, this ice gains the subtypes of the chosen ice and gains the subroutines of that ice in order before its other subroutines.\n[subroutine] End the run unless the Runner shuffles all cards from the grip into the stack."
	}, {
		"on-encounter": {
			"req": func(state, side, eid, card, targets):
				return (2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), NRCard.ice))),
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.active(_pct)),
				"not-self": true,
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(NRToString.card_str(state, target)),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var target_subtypes = NRCardRT.getv(target, "subtype")
					NREffects.register_lingering_effect(
						state,
						"corp",
						card,
						{
							"type": "gain-subtype",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRUtil.same_card(card, target),
							"value": NRCardRT.getv(target, "subtypes"),
						}
					)
					return (func():
						var additional_subs = NRCardRT.getv(target, "subroutines")
						return NREffects.register_lingering_effect(
							state,
							"corp",
							card,
							{
								"type": "additional-subroutines",
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRUtil.same_card(card, target),
								"duration": "end-of-run",
								"value": {
									"position": "front",
									"subroutines": mapv("sub-effect", additional_subs),
								},
							}
						)
					).call()
				).call(),
		},
		"subroutines": [
			{
				"label": "End the run unless the Runner shuffles the grip into the stack",
				"player": "runner",
				"async": true,
				"prompt": "Choose one",
				"waiting-prompt": true,
				"choices": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return [
						("Shuffle the grip into the stack" if not NRCardRT.truthy((NRCardRT.zero(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))) and (NRCardRT.count_of(NRCardRT.getv(runner, "deck")) < 2))) else null),
						"End the run"
					],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str((NRCardRT.decapitalize(target) if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else str("force the Runner to ") + str(NRCardRT.decapitalize(target)))),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return (NRRuns.end_run(state, "corp", eid, card) if ((target == "End the run") or NRUtil.kw_eq(target, "End the run")) else (func():
						(func():
							for c in NRCardRT.as_array(NRCardRT.getv(runner, "hand")):
								NRMoving.move(state, "runner", c, "deck")
							return null
						).call()
						NRShuffling.shuffle_zone(state, "runner", "deck")
						return NREid.effect_completed(state, side, eid)
					).call()),
			}
		],
	}))
	NRCardDefs.defcard("Loot Box", NRUtil.merge({
		"title": "Loot Box",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] End the run unless the Runner pays 2[credit].\n[subroutine] Reveal the top 3 cards of the stack. Add 1 of those cards to the grip and gain X[credit], where X is equal to that cardʼs play or install cost. The Runner shuffles the stack. Trash this ice."
	}, {
		"subroutines": [
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 2)),
			{
				"label": "Reveal the top 3 cards of the Stack",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return ((func():
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to reveal ") + str(NRCardRT.enumerate_cards(_top_3_16(state))) + str(" from the top of the stack"))
						return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, _top_3_16(state))
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, {
								"waiting-prompt": true,
								"prompt": "Choose a card to add to the Grip",
								"choices": func(state, side, eid, card, targets):
									return _top_3_16(state),
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to the Grip, gain ") + str(NRCardRT.getv(target, "cost")) + str(" [Credits], shuffle the Stack and trash itself"),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									NRMoving.move(state, "runner", target, "hand")
									return NREid.wait_for(state, eid, func(ne):
										NRGaining.gain_credits(state, "corp", ne, NRCardRT.getv(target, "cost"))
									, func(async_result):
										NRShuffling.shuffle_zone(state, "runner", "deck")
										NREid.wait_for(state, eid, func(ne):
											NRMoving.trash(state, "corp", ne, card, {
												"cause": "subroutine",
											})
										, func(async_result):
											NRRuns.encounter_ends(state, side, eid))),
							}, card, null))
					).call() if NRCardRT.seq_of(NRCardRT.getv(runner, "deck")) else (func():
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash itself"))
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, "corp", ne, card, {
								"cause": "subroutine",
							})
						, func(async_result):
							NRRuns.encounter_ends(state, side, eid))
					).call()),
			}
		],
	}))
	NRCardDefs.defcard("Lotus Field", NRUtil.merge({
		"title": "Lotus Field",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "The strength of this ice cannot be lowered.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			{
				"type": "cannot-lower-strength",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")),
				"value": true,
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Lycan", NRUtil.merge({
		"title": "Lycan",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 6,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer - Morph",
		"subtypes": ["Sentry", "Destroyer", "Morph"],
		"text": "Lycan can be advanced.\nWhile Lycan has an odd number of advancement tokens on it, it gains <strong>code gate</strong> and loses <strong>sentry</strong>.\n[subroutine] Trash 1 program."
	}, _morph_ice("Sentry", "Code Gate", _trash_program_sub())))
	NRCardDefs.defcard("Lycian Multi-Munition", NRUtil.merge({
		"title": "Lycian Multi-Munition",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 3,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Mythic - Destroyer",
		"subtypes": ["Mythic", "Destroyer"],
		"text": "When you rez this ice, choose 1 or more subtypes among <strong>barrier</strong>, <strong>code gate</strong>, and <strong>sentry</strong>. This ice gains the chosen subtypes while it remains rezzed.\nWhen a turn ends, derez this ice.\n[subroutine] If this ice is a <strong>code gate</strong>, the Runner loses [click] and 1[credit].\n[subroutine] If this ice is a <strong>sentry</strong>, trash 1 installed program.\n[subroutine] If this ice is a <strong>barrier</strong>, gain 1[credit] and end the run."
	}, {
		"on-rez": {
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _ice_subtype_choice_17(["Barrier", "Code Gate", "Sentry"]), card, null),
		},
		"derez-effect": {
			"effect": func(state, side, eid, card, targets):
				return NREffects.unregister_effects_for_card(
					state,
					side,
					card,
					func(_pct):
						return (("gain-subtype" == NRCardRT.getv(_pct, "type")) or NRUtil.kw_eq("gain-subtype", NRCardRT.getv(_pct, "type")))
				),
		},
		"static-abilities": [
			{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and NRCardRT.getv(card, "subtype-target"),
				"value": func(state, side, eid, card, targets):
					return NRCardRT.getv(card, "subtype-target"),
			}
		],
		"events": [
			{
				"event": "runner-turn-ends",
				"req": func(state, side, eid, card, targets):
					return NRCard.rezzed(card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, "corp", eid, card),
			},
			{
				"event": "corp-turn-ends",
				"req": func(state, side, eid, card, targets):
					return NRCard.rezzed(card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, "corp", eid, card),
			}
		],
		"subroutines": [
			{
				"label": "(Code Gate) Force the Runner to lose [Click] and 1 [Credit]",
				"msg": "force the Runner to lose [Click] and 1 [Credit]",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCard.has_subtype(card, "Code Gate") and (NRCardRT.pos(NRCardRT.getv(runner, "credit")) or NRCardRT.pos(NRCardRT.getv(runner, "click"))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.lose_credits(state, "runner", ne, 1)
					, func(async_result):
						NRGaining.lose_clicks(state, "runner", 1)
						NREid.effect_completed(state, side, eid)),
			},
			{
				"label": "(Sentry) Trash a program",
				"prompt": "Choose a program to trash",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCard.has_subtype(card, "Sentry") and NRCardRT.some_list(NRBoard.all_installed(state, "runner"), NRCard.program),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.program(_pct)),
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
							"cause": "subroutine",
						}
					),
			},
			{
				"label": "(Barrier) Gain 1 [Credit] and end the run",
				"msg": "gain 1 [Credit] and end the run",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCard.has_subtype(card, "Barrier"),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "corp", ne, 1)
					, func(async_result):
						NRRuns.end_run(state, "corp", eid, card)),
			}
		],
	}))
	NRCardDefs.defcard("M.I.C.", NRUtil.merge({
		"title": "M.I.C.",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[trash]<strong>:</strong> End the run unless the Runner spends [click]. Use this ability only during a run on this server.\n[subroutine] The Runner loses [click].\n[subroutine] The Runner loses [click].\n[subroutine] End the run."
	}, {
		"abilities": [
			{
				"label": "End the run unless the Runner spends [Click]",
				"msg": "end the run unless the Runner spends [Click]",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return run and this_server,
				"async": true,
				"cost": [NRPayment.to_c("trash-can")],
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, _end_the_run_unless_runner_pays(NRPayment.to_c("click", 1), "ability"), card, null)
					, func(async_result):
						(NRRuns.encounter_ends(state, side, eid) if (run and ((NRIce.get_current_ice(state) == card) or NRUtil.kw_eq(NRIce.get_current_ice(state), card))) else NREid.effect_completed(state, side, eid))),
			}
		],
		"subroutines": [_runner_loses_click(), _runner_loses_click(), _end_the_run()],
	}))
	NRCardDefs.defcard("Machicolation A", NRUtil.merge({
		"title": "Machicolation A",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Code Gate - Destroyer",
		"subtypes": ["Code Gate", "Destroyer"],
		"text": "[subroutine] Trash 1 program.\n[subroutine] Trash 1 program.\n[subroutine] Trash 1 piece of hardware.\n[subroutine] The Runner loses 3[credit], if able. End the run."
	}, {
		"subroutines": [
			_trash_program_sub(),
			_trash_program_sub(),
			_trash_hardware_sub(),
			{
				"label": "Runner loses 3 [Credits], if able. End the run",
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str(("make the Runner lose 3 [Credits] and end the run" if (NRCardRT.getv(runner, "credit") >= 3) else "end the run")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (NREid.wait_for(state, eid, func(ne):
						NRGaining.lose_credits(state, "runner", ne, 3)
					, func(async_result):
						NRRuns.end_run(state, "corp", eid, card)) if (NRCardRT.getv(runner, "credit") >= 3) else NRRuns.end_run(state, "corp", eid, card)),
			}
		],
	}))
	NRCardDefs.defcard("Machicolation B", NRUtil.merge({
		"title": "Machicolation B",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Code Gate - Destroyer - AP",
		"subtypes": ["Code Gate", "Destroyer", "AP"],
		"text": "[subroutine] Trash 1 resource.\n[subroutine] Trash 1 resource.\n[subroutine] Do 1 net damage.\n[subroutine] The Runner loses [click], if able. End the run."
	}, {
		"subroutines": [
			_trash_resource_sub(),
			_trash_resource_sub(),
			NRDefHelpers.do_net_damage(1),
			{
				"label": "Runner loses [click], if able. End the run",
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str(("make the Runner lose [click] and end the run" if NRCardRT.pos(NRCardRT.getv(runner, "click")) else "end the run")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					(NRGaining.lose_clicks(state, "runner", 1) if NRCardRT.truthy(NRCardRT.pos(NRCardRT.getv(runner, "click"))) else null)
					return NRRuns.end_run(state, "corp", eid, card),
			}
		],
	}))
	NRCardDefs.defcard("Macrophage", NRUtil.merge({
		"title": "Macrophage",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 7,
		"factioncost": 0,
		"keywords": "Code Gate - Tracer",
		"subtypes": ["Code Gate", "Tracer"],
		"text": "[subroutine] Trace[4]. If successful, purge virus counters.\n[subroutine] Trace[3]. If successful, trash 1 <strong>virus</strong>.\n[subroutine] Trace[2]. If successful, remove a <strong>virus</strong> in the heap from the game.\n[subroutine] Trace[1]. If successful, end the run."
	}, {
		"subroutines": [
			_trace_ability(
				4,
				{
					"label": "Purge virus counters",
					"msg": "purge virus counters",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRPurging.purge(state, side, eid),
				}
			),
			_trace_ability(
				3,
				{
					"label": "Trash a virus",
					"prompt": "Choose a virus to trash",
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Virus")),
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("trash ") + str(NRCardRT.getv(target, "title")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						NRPrompts.clear_wait_prompt(state, "runner")
						return NRMoving.trash(
							state,
							side,
							eid,
							target,
							{
								"cause": "subroutine",
							}
						),
				}
			),
			_trace_ability(
				2,
				{
					"label": "Remove a virus in the Heap from the game",
					"req": func(state, side, eid, card, targets):
						return (not NRCardRT.truthy(NRFlags.zone_locked(state, "runner", "discard"))),
					"prompt": "Choose a virus in the Heap to remove from the game",
					"choices": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(runner, "discard"), func(_pct):
							return NRCard.has_subtype(_pct, "Virus")))),
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("remove ") + str(NRCardRT.getv(target, "title")) + str(" from the game"),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.move(state, "runner", target, "rfg"),
				}
			),
			_trace_ability(1, _end_the_run())
		],
	}))
	NRCardDefs.defcard("Magnet", NRUtil.merge({
		"title": "Magnet",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When you rez this ice, choose 1 installed program hosted on a piece of ice. Host that program on this ice.\nEach hosted program loses all abilities and cannot gain abilities.\n[subroutine] End the run."
	}, {
		"on-rez": {
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.some_list(NRCardRT.filter_list(NRCardRT.filter_list(NRBoard.all_installed(state, corp), NRCard.ice), func(x): return not NRCardRT.truthy((func(_pct):
					return NRUtil.same_card(_pct, card)).call(x))), func(_pct):
						return NRCardRT.some_list(NRCardRT.getv(_pct, "hosted"), NRCard.program)),
			"prompt": "Choose a Program to host",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("host ") + str(NRToString.card_str(state, target)),
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.program(target) and NRCard.ice(NRCardRT.getv(target, "host")) and (not NRCardRT.truthy(NRUtil.same_card(NRCardRT.getv(target, "host"), card))),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRHosting.host(state, side, card, target)
				NREffects.update_disabled_cards(state)
				return NREngine.trigger_event(state, "corp", "subroutines-should-update"),
		},
		"static-abilities": [
			{
				"type": "disable-card",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(NRCardRT.getv(target, "host"), card) and (not ((NRCardRT.getv(target, "title") == "Hush") or NRUtil.kw_eq(NRCardRT.getv(target, "title"), "Hush"))) and NRCard.program(target),
				"value": true,
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Mamba", NRUtil.merge({
		"title": "Mamba",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Psi - AP",
		"subtypes": ["Sentry", "Psi", "AP"],
		"text": "<strong>Hosted power counter:</strong> Do 1 net damage. Use this ability only during a run.\n[subroutine] Do 1 net damage.\n[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, place 1 power counter on Mamba."
	}, {
		"abilities": [
			_power_counter_ability(
				NRUtil.merge(NRDefHelpers.do_net_damage(1), {"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run})
			)
		],
		"subroutines": [NRDefHelpers.do_net_damage(1), _do_psi(_gain_power_counter())],
	}))
	NRCardDefs.defcard("Marker", NRUtil.merge({
		"title": "Marker",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The next piece of ice the Runner encounters during this run gains \"[subroutine] End the run.\" after its other subroutines for the remainder of that run."
	}, {
		"subroutines": [
			{
				"label": "Give next encountered ice \"End the run\"",
				"msg": "give next encountered ice \"[Subroutine] End the run\" after all its other subroutines for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return NREngine.register_events(
						state,
						side,
						card,
						[
							{
								"event": "encounter-ice",
								"duration": "end-of-run",
								"unregister-once-resolved": true,
								"req": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									return NRCard.rezzed(NRCardRT.getv(context, "ice")),
								"msg": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									return str("give ") + str(NRCardRT.getv(NRCardRT.getv(context, "ice"), "title")) + str("\"[Subroutine] End the run\" after all its other subroutines"),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									var context = NRCardRT.ctx(targets)
									return NREffects.register_lingering_effect(
										state,
										side,
										card,
										(func():
											var t_card = NRCardRT.getv(context, "ice")
											return {
												"type": "additional-subroutines",
												"req": func(state, side, eid, card, targets):
													var target = NRCardRT.first_target(targets)
													return NRUtil.same_card(t_card, target),
												"duration": "end-of-run",
												"value": {
													"subroutines": [_end_the_run()],
												},
											}
										).call()
									),
							}
						]
					),
			}
		],
	}))
	NRCardDefs.defcard("Markus 1.0", NRUtil.merge({
		"title": "Markus 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Barrier - Bioroid",
		"subtypes": ["Barrier", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner trashes 1 of their installed cards.\n[subroutine] End the run."
	}, {
		"subroutines": [_runner_trash_installed_sub(), _end_the_run()],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Maskirovka", NRUtil.merge({
		"title": "Maskirovka",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] Gain 2[credit].\n[subroutine] End the run."
	}, {
		"subroutines": [_gain_credits_sub(2), _end_the_run()],
	}))
	NRCardDefs.defcard("Masvingo", NRUtil.merge({
		"title": "Masvingo",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "You can advance this ice.\nWhen you rez this ice, place 1 advancement counter on it.\nThis ice gains \"[subroutine] End the run.\" for each hosted advancement counter."
	}, NRUtil.merge(_hero_to_hero(_end_the_run()), {"on-rez": {
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
	}})))
	NRCardDefs.defcard("Matrix Analyzer", NRUtil.merge({
		"title": "Matrix Analyzer",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - Tracer - Observer",
		"subtypes": ["Sentry", "Tracer", "Observer"],
		"text": "When the Runner encounters Matrix Analyzer, you may pay 1[credit] to place 1 advancement token on a card that can be advanced.\n[subroutine] Trace[2]. If successful, give the Runner 1 tag."
	}, {
		"on-encounter": NRUtil.merge(place_advancement_counter(true), {"cost": [NRPayment.to_c("credit", 1)]}),
		"subroutines": [_tag_trace(2)],
	}))
	NRCardDefs.defcard("Mausolus", NRUtil.merge({
		"title": "Mausolus",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "You can advance this ice.\n[subroutine] Gain 1[credit]. If there are 3 or more hosted advancement counters, instead gain 3[credit].\n[subroutine] Do 1 net damage. If there are 3 or more hosted advancement counters, instead do 3 net damage.\n[subroutine] Give the Runner 1 tag. If there are 3 or more hosted advancement counters, instead give the Runner 1 tag and end the run."
	}, {
		"advanceable": "always",
		"subroutines": [
			{
				"label": "Gain 1 [Credits] (Gain 3 [Credits])",
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str((3 if _wonder_sub(card, 3) else 1)) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, (3 if _wonder_sub(card, 3) else 1)),
			},
			{
				"label": "Do 1 net damage (Do 3 net damage)",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					return str("do ") + str((3 if _wonder_sub(card, 3) else 1)) + str(" net damage"),
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"net",
						(3 if _wonder_sub(card, 3) else 1),
						{
							"card": card,
						}
					),
			},
			{
				"label": "Give the Runner 1 tag (and end the run)",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					return str("give the Runner 1 tag") + str((" and end the run" if NRCardRT.truthy(_wonder_sub(card, 3)) else null)),
				"effect": func(state, side, eid, card, targets):
					NRTags.gain_tags(state, "corp", eid, 1)
					return (NRRuns.end_run(state, side, eid, card) if _wonder_sub(card, 3) else NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Meridian", NRUtil.merge({
		"title": "Meridian",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] Gain 4[credit] and end the run unless the Runner adds this ice to their score area as an agenda worth -1 agenda point."
	}, {
		"subroutines": [
			{
				"label": "Gain 4 [Credits] and end the run",
				"waiting-prompt": true,
				"prompt": "Choose one",
				"choices": ["Corp gains 4 [Credits] and end the run", "Add Meridian to score area"],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str(("gain 4 [Credits] and end the run" if str_starts_with(target, "Corp") else str("force the Runner to ") + str(NRCardRT.decapitalize(target)))),
				"player": "runner",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "corp", ne, 4)
					, func(async_result):
						NRRuns.end_run(state, "runner", eid, card)) if str_starts_with(target, "Corp") else NREid.wait_for(state, eid, func(ne):
							NRRuns.encounter_ends(state, side, ne)
					, func(async_result):
						NRMoving.as_agenda(state, "runner", card, -1)
						NREid.effect_completed(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Merlin", NRUtil.merge({
		"title": "Merlin",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate - Grail - AP",
		"subtypes": ["Code Gate", "Grail", "AP"],
		"text": "When the Runner encounters this ice, you may reveal up to 2 pieces of <strong>grail</strong> ice in HQ. For the remainder of this run, this ice gains the subroutines of each revealed piece of ice in the order of your choice.\n[subroutine] Do 2 net damage."
	}, _grail_ice(NRDefHelpers.do_net_damage(2))))
	NRCardDefs.defcard("Meru Mati", NRUtil.merge({
		"title": "Meru Mati",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Meru Mati has +3 strength while protecting HQ.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
				return NRCard.protecting_hq(card))
		],
	}))
	NRCardDefs.defcard("Metamorph", NRUtil.merge({
		"title": "Metamorph",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate - Observer",
		"subtypes": ["Code Gate", "Observer"],
		"text": "[subroutine] Swap 2 other installed pieces of ice or 2 of your installed non-ice cards."
	}, {
		"subroutines": [
			{
				"label": "Swap 2 pieces of ice or swap 2 installed non-ice",
				"msg": "swap 2 pieces of ice or swap 2 installed non-ice",
				"async": true,
				"prompt": "Choose one",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					return ((2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), NRCard.ice))) or (2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(x): return not NRCardRT.truthy((NRCard.ice).call(x)))))),
				"choices": func(state, side, eid, card, targets):
					return [
						("Swap 2 pieces of ice" if NRCardRT.truthy((2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), NRCard.ice)))) else null),
						("Swap 2 non-ice" if NRCardRT.truthy((2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(x): return not NRCardRT.truthy((NRCard.ice).call(x)))))) else null)
					],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, ({
						"prompt": "Choose 2 pieces of ice to swap",
						"choices": {
							"card": func(_pct):
								return (NRCard.installed(_pct) and NRCard.ice(_pct)),
							"not-self": true,
							"max": 2,
							"all": true,
						},
						"msg": func(state, side, eid, card, targets):
							return str("swap the positions of ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 0))) + str(" and ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 1))),
						"effect": func(state, side, eid, card, targets):
							return apply(NRMoving.swap_ice, state, side, targets),
					} if ((target == "Swap 2 pieces of ice") or NRUtil.kw_eq(target, "Swap 2 pieces of ice")) else {
						"prompt": "Choose 2 cards to swap",
						"choices": {
							"card": func(_pct):
								return (NRCard.installed(_pct) and (not NRCardRT.truthy(NRCard.ice(_pct)))),
							"max": 2,
							"all": true,
						},
						"msg": func(state, side, eid, card, targets):
							return str("swap the positions of ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 0))) + str(" and ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 1))),
						"effect": func(state, side, eid, card, targets):
							return apply(NRMoving.swap_installed, state, side, targets),
					}), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Mestnichestvo", NRUtil.merge({
		"title": "Mestnichestvo",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "You can advance this ice.\nWhen the Runner encounters this ice, you may remove 1 hosted advancement counter. If you do, the Runner loses 3[credit].\n[subroutine] The Runner loses 3[credit].\n[subroutine] End the run."
	}, {
		"advanceable": "always",
		"on-encounter": {
			"optional": {
				"prompt": "Remove 1 hosted advancement counter to make the Runner lose 3 [Credits]?",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(NRCard.get_card(state, card), "advancement")),
				"yes-ability": {
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("spend 1 hosted advancement counter from ") + str(NRCardRT.getv(card, "title")) + str(" to force the Runner to lose 3 [Credits]"),
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRProps.add_prop(state, "corp", ne, card, "advance-counter", -1, {
								"placed": true,
							})
						, func(async_result):
							NRGaining.lose_credits(state, "runner", eid, 3)),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
		"subroutines": [_runner_loses_credits(3), _end_the_run()],
	}))
	NRCardDefs.defcard("Mganga", NRUtil.merge({
		"title": "Mganga",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Trap - Psi - AP",
		"subtypes": ["Trap", "Psi", "AP"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit] or 2[credit]. Reveal spent credits. If you and the Runner spend a different number of credits, do 2 net damage; otherwise do 1 net damage. Trash Mganga."
	}, {
		"subroutines": [
			_do_psi(
				{
					"async": true,
					"label": "Do 2 net damage",
					"msg": "do 2 net damage and trash itself",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRDamage.damage(state, "corp", ne, "net", 2, {
								"card": card,
							})
						, func(async_result):
							NRMoving.trash(
								state,
								"corp",
								NREid.make_eid(state, eid),
								card,
								{
									"cause": "subroutine",
								}
							)
							NRRuns.encounter_ends(state, side, eid)),
				},
				{
					"async": true,
					"label": "Do 1 net damage",
					"msg": "do 1 net damage and trash itself",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRDamage.damage(state, "corp", ne, "net", 1, {
								"card": card,
							})
						, func(async_result):
							NRMoving.trash(
								state,
								"corp",
								NREid.make_eid(state, eid),
								card,
								{
									"cause": "subroutine",
								}
							)
							NRRuns.encounter_ends(state, side, eid)),
				}
			)
		],
	}))
	NRCardDefs.defcard("Mind Game", NRUtil.merge({
		"title": "Mind Game",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate - Psi - Deflector",
		"subtypes": ["Code Gate", "Psi", "Deflector"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, choose another server. The Runner moves to the outermost position of that server instead of passing this ice. For the remainder of this run, the Runner must add 1 installed Runner card to the bottom of their stack as an additional cost to jack out. The Runner may jack out."
	}, {
		"subroutines": [
			_do_psi(
				{
					"label": "Redirect the run to another server",
					"async": true,
					"prompt": "Choose a server",
					"waiting-prompt": true,
					"choices": func(state, side, eid, card, targets):
						return NRCardRT.filter_list(servers, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy([NRServers.central_to_name(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))].call(x) if [NRServers.central_to_name(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))] is Callable else [NRServers.central_to_name(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))])).call(x))),
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("redirect the run to ") + str(target) + str(" and for the remainder of the run, the runner must add 1 installed card to the bottom of the stack as an additional cost to jack out"),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var can_redirect = (NRCardRT.getv(state.data, "run") and ((1 == NRCardRT.count_of(NRCardRT.getv(state.data, "encounters"))) or NRUtil.kw_eq(1, NRCardRT.count_of(NRCardRT.getv(state.data, "encounters")))) and (not (("success" == NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")) or NRUtil.kw_eq("success", NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")))))
							(NRRuns.redirect_run(state, side, target, "approach-ice") if NRCardRT.truthy(can_redirect) else null)
							NREffects.register_lingering_effect(
								state,
								side,
								card,
								{
									"type": "jack-out-additional-cost",
									"duration": "end-of-run",
									"value": [NRPayment.to_c("add-installed-to-bottom-of-deck", 1)],
								}
							)
							return NREid.wait_for(state, eid, func(ne):
								NREngine.resolve_ability(state, side, ne, NRDefHelpers.offer_jack_out(), card, null)
							, func(async_result):
								(NRRuns.encounter_ends(state, side, eid) if (can_redirect and (not NRCardRT.truthy(NRCardRT.getv(NRCardRT.getv(state.data, "end-run"), "ended")))) else NREid.effect_completed(state, side, eid)))
						).call(),
				}
			)
		],
	}))
	NRCardDefs.defcard("Minelayer", NRUtil.merge({
		"title": "Minelayer",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] You may install 1 piece of ice from HQ protecting this server, ignoring the install cost."
	}, {
		"subroutines": [
			{
				"async": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.in_hand(_pct)),
				},
				"prompt": "Choose a piece of ice to install from HQ",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
					"silent": true,
				},
				"label": "install ice from HQ, ignoring all costs",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var run = state.getv("run")
					return NRInstalling.corp_install(
						state,
						side,
						eid,
						target,
						NRServers.zone_to_name(NRServers.target_server(run)),
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
	NRCardDefs.defcard("Mirāju", NRUtil.merge({
		"title": "Mirāju",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate - Deflector",
		"subtypes": ["Code Gate", "Deflector"],
		"text": "Whenever an encounter with this ice ends, if the Runner broke its printed subroutine, the Runner moves to the outermost position of Archives instead of passing this ice. They may jack out. Derez this ice.\n[subroutine] You may draw 1 card. Then, shuffle 1 card from HQ into R&D."
	}, {
		"events": [
			{
				"event": "end-of-encounter",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and NRCardRT.getv(NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(context, "ice"), "subroutines"), func(x): return NRCardRT.getv(x, "printed")), 0), "broken"),
				"msg": "make the Runner continue the run on Archives",
				"effect": func(state, side, eid, card, targets):
					(NRRuns.redirect_run(state, side, "Archives", "approach-ice") if NRCardRT.truthy((NRCardRT.getv(state.data, "run") and ((1 == NRCardRT.count_of(NRCardRT.getv(state.data, "encounters"))) or NRUtil.kw_eq(1, NRCardRT.count_of(NRCardRT.getv(state.data, "encounters")))) and (not (("success" == NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")) or NRUtil.kw_eq("success", NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")))))) else null)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, "runner", ne, NRDefHelpers.offer_jack_out(), card, null)
					, func(async_result):
						NRRezzing.derez(state, side, eid, card)),
			}
		],
		"subroutines": [
			{
				"async": true,
				"label": "Draw 1 card, then shuffle 1 card from HQ into R&D",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, {
							"optional": {
								"prompt": "Draw 1 card?",
								"yes-ability": {
									"async": true,
									"msg": "draw 1 card",
									"effect": func(state, side, eid, card, targets):
										return NRDrawing.draw(state, side, eid, 1),
								},
							},
						}, card, null)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose 1 card in HQ to shuffle into R&D",
							"choices": {
								"card": func(_pct):
									return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
							},
							"msg": "shuffle 1 card in HQ into R&D",
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								NRMoving.move(state, side, target, "deck")
								return NRShuffling.shuffle_zone(state, side, "deck"),
						}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("Mlinzi", NRUtil.merge({
		"title": "Mlinzi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 1 net damage unless the Runner trashes the top 2 cards of the stack.\n[subroutine] Do 2 net damage unless the Runner trashes the top 3 cards of the stack.\n[subroutine] Do 3 net damage unless the Runner trashes the top 4 cards of the stack."
	}, {
		"subroutines": [_net_or_mill_18(1, 2), _net_or_mill_18(2, 3), _net_or_mill_18(3, 4)],
	}))
	NRCardDefs.defcard("Mother Goddess", NRUtil.merge({
		"title": "Mother Goddess",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"cost": 4,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Mythic",
		"subtypes": ["Mythic"],
		"text": "Mother Goddess gains the subtypes of all other rezzed ice.\n[subroutine] End the run."
	}, (func():
		var context_mg = {
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return NRCard.ice(NRCardRT.getv(context, "card")),
			"effect": func(state, side, eid, card, targets):
				return NRSubtypes.update_all_subtypes(state, side),
		}
		var mg = {
			"req": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRCard.ice(target),
			"effect": func(state, side, eid, card, targets):
				return NRSubtypes.update_all_subtypes(state, side),
		}
		return {
			"static-abilities": [
				{
					"type": "gain-subtype",
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRUtil.same_card(card, target),
					"value": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.concat_lists(NRCardRT.map_list(NRCardRT.filter_list(NRCardRT.concat_lists(NRCardRT.map_list((NRCardRT.getv(corp, "servers") as Dictionary).values(), func(x): return NRCardRT.getv(x, "ices"))), func(_pct):
							return (NRCard.rezzed(_pct) and (not NRCardRT.truthy(NRUtil.same_card(card, _pct))))), func(x): return NRCardRT.getv(x, "subtypes"))),
				}
			],
			"subroutines": [_end_the_run()],
			"events": [
				NRUtil.merge(context_mg, {"event": "rez"}),
				NRUtil.merge(context_mg, {"event": "derez"}),
				NRUtil.merge(context_mg, {"event": "card-moved"}),
				NRUtil.merge(mg, {"event": "ice-subtype-changed"})
			],
		}
	).call()))
	NRCardDefs.defcard("Muckraker", NRUtil.merge({
		"title": "Muckraker",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Sentry - Tracer - Liability",
		"subtypes": ["Sentry", "Tracer", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trace[1]. If successful, give the Runner 1 tag.\n[subroutine] Trace[2]. If successful, give the Runner 1 tag.\n[subroutine] Trace[3]. If successful, give the Runner 1 tag.\n[subroutine] End the run if the Runner is tagged."
	}, {
		"on-rez": _take_bad_pub(),
		"subroutines": [_tag_trace(1), _tag_trace(2), _tag_trace(3), _end_the_run_if_tagged()],
	}))
	NRCardDefs.defcard("Mycoweb", NRUtil.merge({
		"title": "Mycoweb",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] You may install 1 piece of ice from Archives, ignoring all costs.\n[subroutine] You may rez 1 installed piece of ice, paying 2[credit] less.\n[subroutine] Resolve 1 subroutine on a rezzed <strong>sentry</strong>.\n[subroutine] Resolve 1 subroutine on another rezzed <strong>code gate</strong>."
	}, {
		"subroutines": [
			{
				"label": "Install an ice from Archives, ignoring all costs",
				"prompt": "Choose an ice to install from Archives",
				"show-discard": true,
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.ice(target) and NRCard.in_discard(target),
				},
				"waiting-prompt": true,
				"async": true,
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
							"ignore-install-cost": true,
						}
					),
			},
			_rez_an_ice(
				{
					"cost-bonus": -2,
				}
			),
			_resolve_another_subroutine(
				func(_pct):
					return NRCard.has_subtype(_pct, "Sentry"),
				"Resolve subroutine on a rezzed Sentry",
				true
			),
			_resolve_another_subroutine(
				func(_pct):
					return NRCard.has_subtype(_pct, "Code Gate"),
				"Resolve subroutine on another rezzed Code Gate"
			)
		],
	}))
	NRCardDefs.defcard("N-Pot", NRUtil.merge({
		"title": "N-Pot",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "<strong>3[credit]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] End the run.\n[subroutine] If the threat level is 2 or greater, end the run.\n[subroutine] If the threat level is 4 or greater, end the run."
	}, {
		"subroutines": [_end_the_run(), _etr_if_threat_x_19(2), _etr_if_threat_x_19(4)],
		"runner-abilities": [
			{
				"async": true,
				"break": 1,
				"break-cost": [NRPayment.to_c("credit", 3)],
				"label": "Break subroutine",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.currently_encountering(state, card),
			}
		],
	}))
	NRCardDefs.defcard("Najja 1.0", NRUtil.merge({
		"title": "Najja 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Barrier - Bioroid",
		"subtypes": ["Barrier", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run(), _end_the_run()],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Nebula", NRUtil.merge({
		"title": "Nebula",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 9,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "Nebula can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] Trash 1 program."
	}, _space_ice(_trash_program_sub())))
	NRCardDefs.defcard("Negotiator", NRUtil.merge({
		"title": "Negotiator",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "2[credit]: Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Gain 2[credit].\n[subroutine] Trash 1 installed program."
	}, {
		"subroutines": [_gain_credits_sub(2), _trash_program_sub()],
		"runner-abilities": [
			{
				"async": true,
				"break": 1,
				"break-cost": [NRPayment.to_c("credit", 2)],
				"label": "Break subroutine",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.currently_encountering(state, card),
			}
		],
	}))
	NRCardDefs.defcard("Nerine 2.0", NRUtil.merge({
		"title": "Nerine 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate - Bioroid - AP",
		"subtypes": ["Code Gate", "Bioroid", "AP"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage. You may draw 1 card.\n[subroutine] Do 1 core damage. You may draw 1 card."
	}, (func():
		var sub = {
			"label": "Do 1 core damage and Corp may draw 1 card",
			"async": true,
			"msg": "do 1 core damage",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDamage.damage(state, "runner", ne, "brain", 1, {
						"card": card,
					})
				, func(async_result):
					NRDrawing.maybe_draw(state, side, eid, card, 1)),
		}
		return {
			"subroutines": [sub, sub],
			"runner-abilities": [_bioroid_break(2, 2)],
			"abilities": [NRCardRT.set_autoresolve("auto-fire", "Nerine 2.0 drawing cards")],
		}
	).call()))
	NRCardDefs.defcard("Neural Katana", NRUtil.merge({
		"title": "Neural Katana",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 3 net damage."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(3)],
	}))
	NRCardDefs.defcard("News Hound", NRUtil.merge({
		"title": "News Hound",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] Trace[3]. If successful, give the Runner 1 tag.\nIf a <strong>current</strong> is active, this ice gains \"[subroutine] End the run.\" after its other subroutines."
	}, {
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and NRCardRT.pos(NRCardRT.count_of(NRCardRT.concat_lists([state.get_in(["corp", "current"], null), state.get_in(["runner", "current"], null)]))),
				"value": {
					"subroutines": [_end_the_run()],
				},
			}
		],
		"subroutines": [_tag_trace(3)],
	}))
	NRCardDefs.defcard("NEXT Bronze", NRUtil.merge({
		"title": "NEXT Bronze",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate - NEXT",
		"subtypes": ["Code Gate", "NEXT"],
		"text": "NEXT Bronze has +1 strength for each rezzed piece of <strong>NEXT</strong> ice.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return _next_ice_count(corp))
		],
	}))
	NRCardDefs.defcard("NEXT Diamond", NRUtil.merge({
		"title": "NEXT Diamond",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 10,
		"strength": 6,
		"factioncost": 4,
		"keywords": "Sentry - NEXT - Destroyer - AP",
		"subtypes": ["Sentry", "NEXT", "Destroyer", "AP"],
		"text": "The rez cost of this ice is lowered by 1[credit] for each other rezzed piece of <strong>NEXT</strong> ice.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage.\n[subroutine] Trash 1 installed Runner card."
	}, {
		"rez-cost-bonus": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return (-_next_ice_count(corp)),
		"subroutines": [
			NRDefHelpers.do_brain_damage(1),
			NRDefHelpers.do_brain_damage(1),
			{
				"prompt": "Choose a card to trash",
				"label": "Trash 1 installed Runner card",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.seq_of(NRBoard.all_installed(state, "runner")),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.runner(_pct)),
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
							"cause": "subroutine",
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("NEXT Gold", NRUtil.merge({
		"title": "NEXT Gold",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 8,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Sentry - NEXT - AP - Destroyer",
		"subtypes": ["Sentry", "NEXT", "AP", "Destroyer"],
		"text": "X is the number of rezzed <strong>NEXT</strong> ice.\n[subroutine] Do X net damage.\n[subroutine] Trash X programs."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return _next_ice_count(corp),
		"subroutines": [
			{
				"label": "Do X net damage",
				"msg": func(state, side, eid, card, targets):
					return str("do ") + str(NRCardRT.get_x_fn()(state, side, eid, card, targets)) + str(" net damage"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDamage.damage(
						state,
						side,
						eid,
						"net",
						NRCardRT.get_x_fn()(state, side, eid, card, targets),
						{
							"card": card,
						}
					),
			},
			{
				"label": "Trash X programs",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return _trash_programs_20(mini(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.program)), NRCardRT.get_x_fn()(state, side, eid, card, targets)), state, side, card, eid),
			}
		],
	}))
	NRCardDefs.defcard("NEXT Opal", NRUtil.merge({
		"title": "NEXT Opal",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Code Gate - Observer - NEXT",
		"subtypes": ["Code Gate", "Observer", "NEXT"],
		"text": "This ice gains \"[subroutine] You may install 1 card from HQ.\" for each rezzed piece of <strong>NEXT</strong> ice."
	}, _next_ice_variable_subs(_install_from_hq_sub())))
	NRCardDefs.defcard("NEXT Sapphire", NRUtil.merge({
		"title": "NEXT Sapphire",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Code Gate - NEXT",
		"subtypes": ["Code Gate", "NEXT"],
		"text": "X is the number of rezzed <strong>NEXT</strong> ice.\n[subroutine] Draw up to X cards.\n[subroutine] Add up to X cards from Archives to HQ.\n[subroutine] Shuffle up to X cards from HQ into R&D."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return _next_ice_count(corp),
		"subroutines": [
			{
				"label": "Draw up to X cards",
				"prompt": "How many cards do you want to draw?",
				"waiting-prompt": true,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("draw ") + str(NRCardRT.quantify(target, "card")),
				"choices": {
					"number": NRCardRT.get_x_fn(),
					"default": func(state, side, eid, card, targets):
						return 1,
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRDrawing.draw(state, side, eid, target),
			},
			{
				"label": "Add up to X cards from Archives to HQ",
				"prompt": "Choose cards to add to HQ",
				"show-discard": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
					"max": NRCardRT.get_x_fn(),
				},
				"effect": func(state, side, eid, card, targets):
					return (func():
						for c in NRCardRT.as_array(targets):
							NRMoving.move(state, side, c, "hand")
						return null
					).call(),
				"msg": func(state, side, eid, card, targets):
					return str("add ") + str((func():
						var seen = NRCardRT.filter_list(targets, func(x): return NRCardRT.getv(x, "seen"))
						var m = NRCardRT.count_of(NRCardRT.filter_list(targets, func(_pct):
							return (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen")))))
						return str(NRCardRT.enumerate_cards(seen, "sorted")) + str((str((" and " if not NRCardRT.truthy(NRCardRT.empty_of(seen)) else null)) + str(NRCardRT.quantify(m, "unseen card")) if NRCardRT.truthy(NRCardRT.pos(m)) else null))
					).call()) + str(" to HQ"),
			},
			{
				"label": "Shuffle up to X cards from HQ into R&D",
				"prompt": "Choose cards to shuffle into R&D",
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
					"max": NRCardRT.get_x_fn(),
				},
				"effect": func(state, side, eid, card, targets):
					(func():
						for c in NRCardRT.as_array(targets):
							NRMoving.move(state, "corp", c, "deck")
						return null
					).call()
					return NRShuffling.shuffle_zone(state, "corp", "deck"),
				"cancel": NRShuffling.shuffle_deck,
				"msg": func(state, side, eid, card, targets):
					return str("shuffle ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ into R&D"),
			}
		],
	}))
	NRCardDefs.defcard("NEXT Silver", NRUtil.merge({
		"title": "NEXT Silver",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Barrier - NEXT",
		"subtypes": ["Barrier", "NEXT"],
		"text": "This ice gains \"[subroutine] End the run.\" for each rezzed piece of <strong>NEXT</strong> ice."
	}, _next_ice_variable_subs(_end_the_run())))
	NRCardDefs.defcard("Nightdancer", NRUtil.merge({
		"title": "Nightdancer",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner loses [click], if able. You have an additional [click] to spend during your next turn.\n[subroutine] The Runner loses [click], if able. You have an additional [click] to spend during your next turn."
	}, (func():
		var sub = {
			"label": str("The Runner loses [Click], if able. ") + str("You have an additional [Click] to spend during your next turn"),
			"msg": str("force the runner to lose a [Click], if able. ") + str("Corp gains an additional [Click] to spend during [their] next turn"),
			"effect": func(state, side, eid, card, targets):
				NRGaining.lose_clicks(state, "runner", 1)
				return state.update_in(["corp", "extra-click-temp"], func(v): return v),
		}
		return {
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Oduduwa", NRUtil.merge({
		"title": "Oduduwa",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 7,
		"strength": 5,
		"factioncost": 5,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters Oduduwa, place 1 advancement token on it. You may place X advancement tokens on another piece of ice. X is the number of advancement tokens on Oduduwa.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"on-encounter": {
			"msg": "place 1 advancement counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRProps.add_prop(state, side, ne, card, "advance-counter", 1, {
						"placed": true,
					})
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, (func():
						var card = NRCard.get_card(state, card)
						var counters = NRCardRT.get_x_fn()(state, side, eid, card, targets)
						return {
							"optional": {
								"prompt": str("Place ") + str(NRCardRT.quantify(counters, "advancement counter")) + str(" on another ice?"),
								"yes-ability": {
									"msg": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return str("place ") + str(NRCardRT.quantify(counters, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, target)),
									"async": true,
									"choices": {
										"card": NRCard.ice,
										"not-self": true,
									},
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return NRProps.add_prop(
											state,
											side,
											eid,
											target,
											"advance-counter",
											counters,
											{
												"placed": true,
											}
										),
								},
							},
						}
					).call(), NRCard.get_card(state, card), null)),
		},
		"x-fn": func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "advancement"),
		"subroutines": [_end_the_run(), _end_the_run()],
	}))
	NRCardDefs.defcard("Orion", NRUtil.merge({
		"title": "Orion",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"cost": 15,
		"strength": 8,
		"factioncost": 3,
		"keywords": "Sentry - Code Gate - Barrier",
		"subtypes": ["Sentry", "Code Gate", "Barrier"],
		"text": "Orion can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] Trash 1 program.\n[subroutine] Resolve a subroutine on another piece of rezzed ice.\n[subroutine] End the run."
	}, _space_ice(_trash_program_sub(), _resolve_another_subroutine(), _end_the_run())))
	NRCardDefs.defcard("Otoroshi", NRUtil.merge({
		"title": "Otoroshi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "[subroutine] You may place up to 3 advancement counters on 1 card installed in the root of a remote server. If you do, the Runner accesses that card unless they pay 3[credit]."
	}, {
		"subroutines": [
			{
				"async": true,
				"label": "Place 3 advancement counters on an installed card",
				"msg": "place 3 advancement counters on an installed card",
				"prompt": "Choose an installed card in the root of a remote server",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x): return not NRCardRT.truthy(NRCard.ice(x)))),
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.installed(_pct) and (not NRCardRT.truthy(NRCard.ice(_pct)))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var async_result = NREid.result_of(eid)
					return (func():
						var c = target
						var title = NRToString.card_str(state, target)
						return NREid.wait_for(state, eid, func(ne):
							NRProps.add_counter(state, side, ne, c, "advancement", 3, {
								"placed": true,
							})
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, {
								"player": "runner",
								"async": true,
								"waiting-prompt": true,
								"prompt": "Choose one",
								"choices": [
									str("Access ") + str(title),
									("Pay 3 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 3)])) else null)
								],
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									var async_result = NREid.result_of(eid)
									return (NREid.wait_for(state, eid, func(ne):
										NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", 3))
									, func(async_result):
										NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
										NREid.effect_completed(state, side, eid)) if ((target == "Pay 3 [Credits]") or NRUtil.kw_eq(target, "Pay 3 [Credits]")) else NRAccess.access_card(state, "runner", eid, c)),
							}, card, null))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Owl", NRUtil.merge({
		"title": "Owl",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 0,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "[subroutine] Add 1 installed program to the top of the stack."
	}, {
		"subroutines": [_add_program_to_top_of_stack()],
	}))
	NRCardDefs.defcard("Pachinko", NRUtil.merge({
		"title": "Pachinko",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged."
	}, {
		"subroutines": [_end_the_run_if_tagged(), _end_the_run_if_tagged()],
	}))
	NRCardDefs.defcard("Palisade", NRUtil.merge({
		"title": "Palisade",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "While this ice is protecting a remote server, it gets +2 strength.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			NRCardRT.ice_strength_bonus(2, func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.protecting_a_central(card))))
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Paper Wall", NRUtil.merge({
		"title": "Paper Wall",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"strength": 1,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner fully breaks this ice, trash it.\n[subroutine] End the run."
	}, {
		"events": [
			{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and NRCardRT.getv(context, "all-subs-broken"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(
						state,
						"corp",
						eid,
						card,
						{
							"cause-card": card,
							"cause": "effect",
						}
					),
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Paywall", NRUtil.merge({
		"title": "Paywall",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 1,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner encounters this ice, they lose 1[credit].\n[subroutine] End the run unless the Runner pays 1[credit]."
	}, {
		"on-encounter": _runner_loses_credits(1),
		"subroutines": [_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 1))],
	}))
	NRCardDefs.defcard("Peeping Tom", NRUtil.merge({
		"title": "Peeping Tom",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, choose a card type, then reveal all cards in the grip. For the remainder of this run, this ice gains \"[subroutine] End the run unless the Runner takes 1 tag.\" for each revealed card of the chosen type."
	}, (func():
		var sub = _end_the_run_unless_runner("takes 1 tag", "take 1 tag", NRDefHelpers.give_tags(1))
		return {
			"on-encounter": {
				"prompt": "Choose a card type",
				"choices": ["Event", "Hardware", "Program", "Resource"],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return (func():
						var n = NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
							return NRCard.is_type(_pct, target)))
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to name ") + str(target) + str(", reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.getv(runner, "hand"), "sorted")) + str(" from the grip, and gain ") + str(NRCardRT.quantify(n, "subroutine")))
						return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, NRCardRT.getv(runner, "hand"))
						, func(async_result):
							NREffects.register_lingering_effect(
								state,
								side,
								card,
								{
									"type": "additional-subroutines",
									"duration": "end-of-run",
									"req": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return NRUtil.same_card(card, target),
									"value": {
										"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(sub, int(n))),
									},
								}
							)
							NREid.effect_completed(state, side, eid))
					).call(),
			},
		}
	).call()))
	NRCardDefs.defcard("Pharos", NRUtil.merge({
		"title": "Pharos",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "You can advance this ice. It gets +5 strength while there are 3 or more hosted advancement counters.\n[subroutine] Give the Runner 1 tag.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"advanceable": "always",
		"subroutines": [NRDefHelpers.give_tags(1), _end_the_run(), _end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(5, func(state, side, eid, card, targets):
				return _wonder_sub(card, 3))
		],
	}))
	NRCardDefs.defcard("Phoneutria", NRUtil.merge({
		"title": "Phoneutria",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - AP - Observer",
		"subtypes": ["Sentry", "AP", "Observer"],
		"text": "When the Runner passes this ice, if there are 4 or more cards in the grip, give them 1 tag.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(1), NRDefHelpers.do_net_damage(1)],
		"events": [
			{
				"event": "pass-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var runner = state.player("runner")
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), card) and (4 <= NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
				"msg": "give the Runner 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, side, eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Ping", NRUtil.merge({
		"title": "Ping",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When you rez this ice during a run against this server, give the Runner 1 tag.\n[subroutine] End the run."
	}, {
		"on-rez": NRUtil.merge(NRDefHelpers.give_tags(1), {"req": func(state, side, eid, card, targets):
			var run = state.getv("run")
			var this_server = NRCardRT.this_server(state, card)
			return (run and this_server)}),
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Piranhas", NRUtil.merge({
		"title": "Piranhas",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Code Gate - AP - Liability",
		"subtypes": ["Code Gate", "AP", "Liability"],
		"text": "As an additional cost to rez this ice, take 1 bad publicity or remove 1 tag.\n[subroutine] You may draw 1 card.\n[subroutine] Do 1 net damage.\n[subroutine] End the run if there are more cards in HQ than in the grip."
	}, {
		"additional-cost": [NRPayment.to_c("tag-or-bad-pub")],
		"subroutines": [
			_maybe_draw_sub(1),
			NRDefHelpers.do_net_damage(1),
			NRUtil.merge(_end_the_run(), {"label": "End the run if there are more cards in HQ than in the grip", "change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					var corp = state.player("corp")
					return (NRCardRT.count_of(NRCardRT.getv(corp, "hand")) > NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
			}})
		],
	}))
	NRCardDefs.defcard("Pop-up Window", NRUtil.merge({
		"title": "Pop-up Window",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Code Gate - Advertisement",
		"subtypes": ["Code Gate", "Advertisement"],
		"text": "When the Runner encounters this ice, gain 1[credit].\n[subroutine] End the run unless the Runner pays 1[credit]."
	}, {
		"on-encounter": _gain_credits_sub(1),
		"subroutines": [_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 1))],
	}))
	NRCardDefs.defcard("Biawak", NRUtil.merge({
		"title": "Biawak",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 14,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "You can forfeit 1 agenda as you rez this ice to pay for 10[credit] of its rez cost.\n[subroutine] Trash 1 installed program or end the run.\n[subroutine] Trash 1 installed resource or end the run.\n[subroutine] End the run."
	}, {
		"subroutines": [
			_trash_type_or_end_the_run("program", NRCard.program, _trash_program_sub()),
			_trash_type_or_end_the_run("resource", NRCard.resource, _trash_resource_sub()),
			_end_the_run()
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return ["rez"](NRCardRT.getv(eid, "source-type")) and NRCardRT.seq_of(state.get_in(["corp", "scored"], null)) and NRUtil.same_card(card, target),
				"custom-amount": 10,
				"max-uses": 1,
				"custom": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var cost_type = "rez"
						var targetcard = target
						return NREngine.resolve_ability(state, side, eid, {
							"prompt": str("Forfiet an agenda to pay for 10 [Credits] of the rez cost?"),
							"async": true,
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRFlags.in_corp_scored(state, side, target),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("forfeit ") + str(NRCardRT.getv(target, "title")) + str(" to pay for 10 [Credits] its rez cost"),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.forfeit(state, side, ne, target)
								, func(async_result):
									NREid.effect_completed(state, side, NREid.make_result(eid, 10))),
							"cancel": {
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NREid.effect_completed(state, side, NREid.make_result(eid, 0)),
							},
						}, card, null)
					).call(),
				"type": "custom",
				"while-inactive": true,
			},
		},
	}))
	NRCardDefs.defcard("Pulse", NRUtil.merge({
		"title": "Pulse",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Code Gate - Harmonic",
		"subtypes": ["Code Gate", "Harmonic"],
		"text": "When you rez this ice during a run against this server, the Runner loses [click].\n[subroutine] The Runner loses 1[credit] for each rezzed piece of <strong>harmonic</strong> ice.\n[subroutine] End the run unless the Runner spends [click]."
	}, {
		"rez-sound": "pulse",
		"on-rez": {
			"req": func(state, side, eid, card, targets):
				var run = state.getv("run")
				var this_server = NRCardRT.this_server(state, card)
				return run and this_server,
			"msg": "force the runner to lose [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_clicks(state, "runner", 1),
		},
		"subroutines": [
			{
				"label": "Runner loses 1 [Credits] for each rezzed piece of Harmonic ice",
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str("make the runner lose ") + str(_harmonic_ice_count(corp)) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRGaining.lose_credits(state, "runner", eid, _harmonic_ice_count(corp)),
			},
			_end_the_run_unless_runner_pays(NRPayment.to_c("click", 1))
		],
	}))
	NRCardDefs.defcard("Pup", NRUtil.merge({
		"title": "Pup",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 1 net damage unless the Runner pays 1[credit].\n[subroutine] Do 1 net damage unless the Runner pays 1[credit]."
	}, (func():
		var sub = {
			"player": "runner",
			"async": true,
			"label": "Do 1 net damage unless the Runner pays 1 [Credits]",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
					"Suffer 1 net damage",
					("Pay 1 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 1)])) else null)
				],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREngine.resolve_ability(state, "corp", eid, NRDefHelpers.do_net_damage(1), card, null) if (("Suffer 1 net damage" == target) or NRUtil.kw_eq("Suffer 1 net damage", target)) else NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, "runner", ne, card, [NRPayment.to_c("credit", 1)])
				, func(async_result):
					NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid))),
		}
		return {
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Quandary", NRUtil.merge({
		"title": "Quandary",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Quicksand", NRUtil.merge({
		"title": "Quicksand",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner encounters Quicksand, place 1 power counter on Quicksand.\nQuicksand has +1 strength for each power counter on it.\n[subroutine] End the run."
	}, {
		"on-encounter": _gain_power_counter(),
		"subroutines": [_end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "power"))
		],
	}))
	NRCardDefs.defcard("Rainbow", NRUtil.merge({
		"title": "Rainbow",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 0,
		"keywords": "Sentry - Code Gate - Barrier",
		"subtypes": ["Sentry", "Code Gate", "Barrier"],
		"text": "[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Ravana 1.0", NRUtil.merge({
		"title": "Ravana 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate - Bioroid",
		"subtypes": ["Code Gate", "Bioroid"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Resolve 1 subroutine on another rezzed <strong>bioroid</strong> ice.\n[subroutine] Resolve 1 subroutine on another rezzed <strong>bioroid</strong> ice."
	}, (func():
		var sub = _resolve_another_subroutine(
			func(_pct):
				return NRCard.has_subtype(_pct, "Bioroid"),
			"Resolve a subroutine on a rezzed bioroid ice"
		)
		return {
			"subroutines": [sub, sub],
			"runner-abilities": [_bioroid_break(1, 1)],
		}
	).call()))
	NRCardDefs.defcard("Red Tape", NRUtil.merge({
		"title": "Red Tape",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] All ice has +3 strength for the remainder of this run."
	}, {
		"subroutines": [
			{
				"label": "Give +3 strength to all ice for the remainder of the run",
				"msg": "give +3 strength to all ice for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "ice-strength",
							"duration": "end-of-run",
							"value": 3,
						}
					)
					return NRIce.update_all_ice(state, side),
			}
		],
	}))
	NRCardDefs.defcard("Resistor", NRUtil.merge({
		"title": "Resistor",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Barrier - Tracer",
		"subtypes": ["Barrier", "Tracer"],
		"text": "Resistor has +1 strength for each tag the Runner has.\n[subroutine] Trace[4]. If successful, end the run."
	}, {
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return count_tags(state))
		],
		"subroutines": [_trace_ability(4, _end_the_run())],
	}))
	NRCardDefs.defcard("Reverb", NRUtil.merge({
		"title": "Reverb",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Barrier - Harmonic",
		"subtypes": ["Barrier", "Harmonic"],
		"text": "The rez cost of this ice is lowered by 1[credit] for each other unrezzed piece of ice.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"rez-cost-bonus": func(state, side, eid, card, targets):
			return (-NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
				return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRUtil.same_card(card, _pct))) and (not NRCardRT.truthy(NRCard.rezzed(_pct))))))),
		"subroutines": [_end_the_run(), _end_the_run()],
	}))
	NRCardDefs.defcard("Rime", NRUtil.merge({
		"title": "Rime",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Mythic",
		"subtypes": ["Mythic"],
		"text": "During runs against this server, you can rez this ice any time you could rez non-ice cards.\nEach piece of ice protecting this server gets +1 strength.\n[subroutine] The Runner loses 1[credit]."
	}, {
		"implementation": "Can be rezzed anytime already",
		"on-rez": {
			"effect": func(state, side, eid, card, targets):
				return NRIce.update_all_ice(state, side),
		},
		"subroutines": [_runner_loses_credits(1)],
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
	NRCardDefs.defcard("Rototurret", NRUtil.merge({
		"title": "Rototurret",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "[subroutine] Trash 1 installed program.\n[subroutine] End the run."
	}, {
		"subroutines": [_trash_program_sub(), _end_the_run()],
	}))
	NRCardDefs.defcard("RSVP", NRUtil.merge({
		"title": "RSVP",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner cannot spend any credits for the remainder of this run."
	}, {
		"subroutines": [
			{
				"label": "Runner cannot spend credits this run",
				"msg": "prevent the runner from spending credits this run",
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					return (NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "cannot-pay-credit",
							"req": func(state, side, eid, card, targets):
								var context = NRCardRT.ctx(targets)
								return ((NRCardRT.getv(context, "amount") == null) or NRCardRT.pos(NRCardRT.getv(context, "amount"))),
							"value": true,
							"duration": "end-of-run",
						}
					) if NRCardRT.truthy(run) else null),
			}
		],
	}))
	NRCardDefs.defcard("Sadaka", NRUtil.merge({
		"title": "Sadaka",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] Look at the top 3 cards of R&D and either arrange them in any order or shuffle R&D. You may draw 1 card.\n[subroutine] You may trash 1 card in HQ. If you do, trash 1 resource. Trash Sadaka."
	}, {
		"subroutines": [
			{
				"label": "Look at the top 3 cards of R&D",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, (func():
						var top_cards = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3))
						return {
							"waiting-prompt": true,
							"prompt": str("The top cards of R&D are (top->bottom): ") + str(NRCardRT.enumerate_cards(top_cards)),
							"choices": ["Arrange cards", "Shuffle R&D"],
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (NREid.wait_for(state, eid, func(ne):
									NREngine.resolve_ability(state, side, ne, reorder_choice("corp", top_cards), card, null)
								, func(async_result):
									NRSay.system_msg(state, "corp", str("rearranges the top ") + str(NRCardRT.quantify(NRCardRT.count_of(top_cards), "card")) + str(" of R&D"))
									NRDrawing.maybe_draw(state, side, eid, card, 1)) if ((target == "Arrange cards") or NRUtil.kw_eq(target, "Arrange cards")) else (func():
										NRShuffling.shuffle_zone(state, "corp", "deck")
										NRSay.system_msg(state, "corp", str("shuffles R&D"))
										return NRDrawing.maybe_draw(state, side, eid, card, 1)
								).call()),
						}
					).call(), card, null),
			},
			{
				"label": "Trash 1 card in HQ",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, {
							"waiting-prompt": true,
							"prompt": "Choose a card in HQ to trash",
							"choices": func(state, side, eid, card, targets):
								var corp = state.player("corp")
								return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.getv(corp, "hand"))),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, "corp", ne, target, {
										"cause": "subroutine",
									})
								, func(async_result):
									NRSay.system_msg(state, "corp", "trashes a card from HQ")
									NREngine.resolve_ability(state, side, eid, _trash_resource_sub(), card, null)),
						}, card, null)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, "corp", ne, card, {
								"cause-card": card,
							})
						, func(async_result):
							NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash itself"))
							NRRuns.encounter_ends(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Sagittarius", NRUtil.merge({
		"title": "Sagittarius",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Tracer - Destroyer",
		"subtypes": ["Sentry", "Tracer", "Destroyer"],
		"text": "[subroutine] Trace[2]. If successful, trash 1 program. If your trace strength is 5 or greater, trash 1 program."
	}, _constellation_ice(_trash_program_sub())))
	NRCardDefs.defcard("Saisentan", NRUtil.merge({
		"title": "Saisentan",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Sentry - AP - Observer",
		"subtypes": ["Sentry", "AP", "Observer"],
		"text": "When the Runner encounters this ice, choose a card type. For the remainder of the encounter, whenever you trash a card of the chosen type with net damage from a subroutine on this ice, do 1 net damage.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
	}, (func():
		var sub = {
			"label": "Do 1 net damage",
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
						"cause": "subroutine",
					}
				),
		}
		return {
			"on-encounter": {
				"waiting-prompt": true,
				"prompt": "Choose a card type",
				"choices": ["Event", "Hardware", "Program", "Resource"],
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("choose the card type ") + str(target),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUpdate.update_card(state, side, NRUtil.merge(card, {"card-target": target})),
			},
			"events": [
				{
					"event": "damage",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return ((NRCardRT.getv(context, "damage-type") == "net") or NRUtil.kw_eq(NRCardRT.getv(context, "damage-type"), "net")) and ((NRCardRT.getv(context, "cause") == "subroutine") or NRUtil.kw_eq(NRCardRT.getv(context, "cause"), "subroutine")) and NRUtil.same_card(NRCardRT.getv(context, "card"), card),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (func():
							var trashed_cards = NRCardRT.getv(context, "cards-trashed")
							var chosen_type = NRCardRT.getv(card, "card-target")
							var matching_type = NRCardRT.filter_list(trashed_cards, func(_pct):
								return ((NRCardRT.getv(_pct, "type") == chosen_type) or NRUtil.kw_eq(NRCardRT.getv(_pct, "type"), chosen_type)))
							return (NREid.effect_completed(state, side, eid) if not NRCardRT.truthy(NRCardRT.seq_of(matching_type)) else _resolve_extra_damage_21(NRCardRT.count_of(matching_type), eid))
						).call(),
				},
				{
					"event": "end-of-encounter",
					"req": func(state, side, eid, card, targets):
						return NRCardRT.getv(card, "card-target"),
					"effect": func(state, side, eid, card, targets):
						return NRUpdate.update_card(state, side, NRUtil.dissoc(card, ["card-target"])),
				}
			],
			"subroutines": [sub, sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Salvage", NRUtil.merge({
		"title": "Salvage",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate - Tracer",
		"subtypes": ["Code Gate", "Tracer"],
		"text": "You can advance this ice if it is rezzed. It gains \"[subroutine] Trace[2]. If successful, give the Runner 1 tag.\" for each hosted advancement counter."
	}, _zero_to_hero(_tag_trace(2))))
	NRCardDefs.defcard("Sand Storm", NRUtil.merge({
		"title": "Sand Storm",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Trap - Deflector",
		"subtypes": ["Trap", "Deflector"],
		"text": "[subroutine] If this ice is installed, move it to the outermost position protecting another server. <em>(The run continues from this new position.)</em> Trash this ice."
	}, {
		"subroutines": [
			{
				"async": true,
				"label": "Move this ice and the run to another server",
				"prompt": "Choose another server and redirect the run to its outermost position",
				"choices": func(state, side, eid, card, targets):
					return NRCardRT.filter_list(NRPrompts.cancellable(NRCardRT.as_array(servers)), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy([NRServers.zone_to_name(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))].call(x) if [NRServers.zone_to_name(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))] is Callable else [NRServers.zone_to_name(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"))])).call(x))),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("move itself and the run on ") + str(target) + str(" and trash itself"),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCard.installed(card),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var moved_ice = NRMoving.move(state, side, card, (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["ices"]))
						NRRuns.redirect_run(state, side, target)
						return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, side, ne, moved_ice, {
								"unpreventable": true,
								"cause": "subroutine",
							})
						, func(async_result):
							NRRuns.encounter_ends(state, side, eid))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Sandman", NRUtil.merge({
		"title": "Sandman",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine]Add an installed Runner card to the grip.\n[subroutine]Add an installed Runner card to the grip."
	}, {
		"subroutines": [_add_runner_card_to_grip(), _add_runner_card_to_grip()],
	}))
	NRCardDefs.defcard("Sandstone", NRUtil.merge({
		"title": "Sandstone",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner encounters this ice, place 1 virus counter on it.\nThis ice gets −1 strength for each hosted virus counter.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return (-NRCard.get_counters(card, "virus")))
		],
		"on-encounter": {
			"msg": "place 1 virus counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRProps.add_counter(state, side, ne, card, "virus", 1, null)
				, func(async_result):
					NRIce.update_ice_strength(state, side, NRCard.get_card(state, card))
					NREid.effect_completed(state, side, eid)),
		},
	}))
	NRCardDefs.defcard("Sapper", NRUtil.merge({
		"title": "Sapper",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"trash": 2,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, they encounter it.\n[subroutine] Trash 1 installed program."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"subroutines": [_trash_program_sub()],
		"on-access": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.in_discard(card))),
			"msg": "force the Runner to encounter Sapper",
			"effect": func(state, side, eid, card, targets):
				return NRRuns.force_ice_encounter(state, side, eid, card),
		},
	}))
	NRCardDefs.defcard("Scatter Field", NRUtil.merge({
		"title": "Scatter Field",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "While this ice is the only piece of ice protecting this server, it gets +4 strength.\n[subroutine] You may install 1 card from HQ.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			NRCardRT.ice_strength_bonus(4, func(state, side, eid, card, targets):
				return ((1 == NRCardRT.count_of(state.get_in(["corp", "servers", NRCardRT.getv(NRCard.get_zone(card), 1), "ices"], null))) or NRUtil.kw_eq(1, NRCardRT.count_of(state.get_in(["corp", "servers", NRCardRT.getv(NRCard.get_zone(card), 1), "ices"], null)))))
		],
		"subroutines": [_install_from_hq_sub(), _end_the_run()],
	}))
	NRCardDefs.defcard("Searchlight", NRUtil.merge({
		"title": "Searchlight",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Sentry - Tracer - Observer",
		"subtypes": ["Sentry", "Tracer", "Observer"],
		"text": "Searchlight can be advanced. X is the number of advancement tokens on Searchlight.\n[subroutine]Trace[X]. If successful, give the Runner 1 tag.\n[subroutine]Trace[X]. If successful, give the Runner 1 tag."
	}, (func():
		var sub = {
			"label": "Trace X - Give the Runner 1 tag",
			"trace": {
				"base": NRCardRT.get_x_fn(),
				"label": "Give the Runner 1 tag",
				"successful": NRDefHelpers.give_tags(1),
			},
		}
		return {
			"x-fn": func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "advancement"),
			"advanceable": "always",
			"subroutines": [sub, sub],
		}
	).call()))
	NRCardDefs.defcard("Seidr Adaptive Barrier", NRUtil.merge({
		"title": "Seidr Adaptive Barrier",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "Seidr Adaptive Barrier has +1 strength for each piece of ice protecting this server.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return NRCardRT.count_of(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices")))
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Self-Adapting Code Wall", NRUtil.merge({
		"title": "Self-Adapting Code Wall",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "The strength of Self-Adapting Code Wall cannot be lowered.\n[subroutine] End the run."
	}, {
		"static-abilities": [
			{
				"type": "cannot-lower-strength",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")),
				"value": true,
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Semak-samun", NRUtil.merge({
		"title": "Semak-samun",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "The Runner cannot break the printed subroutine on this ice except using a <strong>fracter</strong>.\n[subroutine] End the run unless the Runner suffers 3 net damage."
	}, {
		"static-abilities": [
			{
				"type": "cannot-break-subs-on-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and (not NRCardRT.truthy(NRCard.has_subtype(NRCardRT.getv(context, "icebreaker"), "Fracter"))),
				"value": true,
			}
		],
		"subroutines": [_end_the_run_unless_runner_pays(NRPayment.to_c("net", 3))],
	}))
	NRCardDefs.defcard("Sensei", NRUtil.merge({
		"title": "Sensei",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] For the remainder of this run, while the Runner is encountering another piece of ice, it gains \"[subroutine] End the run.\" after its other subroutines."
	}, {
		"subroutines": [
			{
				"label": "Give encountered ice \"End the run\"",
				"msg": "give encountered ice \"[Subroutine] End the run\" after all its other subroutines for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var current_ice = NRIce.get_current_ice(state)
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "additional-subroutines",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								var current_ice = NRIce.get_current_ice(state)
								return NRCard.rezzed(target) and NRUtil.same_card(target, current_ice) and (not NRCardRT.truthy(NRUtil.same_card(card, target))),
							"value": {
								"subroutines": [_end_the_run()],
							},
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Seraph", NRUtil.merge({
		"title": "Seraph",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 10,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Sentry - AP - Observer - Deep Net",
		"subtypes": ["Sentry", "AP", "Observer", "Deep Net"],
		"text": "When the Runner encounters this ice, they lose 3[credit] unless they suffer 2 net damage or take 1 tag.\n[subroutine] The Runner loses 3[credit].\n[subroutine] Do 2 net damage.\n[subroutine] Give the Runner 1 tag."
	}, (func():
		var encounter_ab = {
			"prompt": "Choose one",
			"player": "runner",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return [
					"Lose 3 [Credits]",
					("Suffer 2 net damage" if NRCardRT.truthy((NRCardRT.count_of(NRCardRT.getv(runner, "hand")) >= 2)) else null),
					("Take 1 tag" if not NRCardRT.truthy(_forced_to_avoid_tags(state, side)) else null)
				],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)) + str(" on encountering it"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRGaining.lose_credits(state, "runner", eid, 3) if NRCardRT.truthy((("Lose 3 [Credits]" == target) or NRUtil.kw_eq("Lose 3 [Credits]", target))) else (NREngine.pay(state, "runner", eid, card, [NRPayment.to_c("net", 2)]) if NRCardRT.truthy((("Suffer 2 net damage" == target) or NRUtil.kw_eq("Suffer 2 net damage", target))) else NRTags.gain_tags(
					state,
					"runner",
					eid,
					1,
					{
						"unpreventable": true,
					}
				))),
		}
		return {
			"on-encounter": _encounter_ab_4(),
			"subroutines": [_runner_loses_credits(3), NRDefHelpers.do_net_damage(2), NRDefHelpers.give_tags(1)],
		}
	).call()))
	NRCardDefs.defcard("Shadow", NRUtil.merge({
		"title": "Shadow",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"strength": 1,
		"factioncost": 1,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "Shadow can be advanced and has +1 strength for each advancement token on it.\n[subroutine] The Corp gains 2[credit].\n[subroutine] Trace[3]. If successful, give the Runner 1 tag."
	}, _wall_ice([_gain_credits_sub(2), _tag_trace(3)])))
	NRCardDefs.defcard("Sherlock 1.0", NRUtil.merge({
		"title": "Sherlock 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Bioroid - Tracer",
		"subtypes": ["Sentry", "Bioroid", "Tracer"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trace[4]. If successful, add 1 installed program to the top of the Runner's stack.\n[subroutine] Trace[4]. If successful, add 1 installed program to the top of the Runner's stack."
	}, {
		"subroutines": [
			_trace_ability(4, _add_program_to_top_of_stack()),
			_trace_ability(4, _add_program_to_top_of_stack())
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Sherlock 2.0", NRUtil.merge({
		"title": "Sherlock 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 7,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - Bioroid - Tracer",
		"subtypes": ["Sentry", "Bioroid", "Tracer"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trace[4]. If successful, add 1 installed program to the bottom of the Runner's stack.\n[subroutine] Trace[4]. If successful, add 1 installed program to the bottom of the Runner's stack.\n[subroutine] Give the Runner 1 tag."
	}, (func():
		var sub = _trace_ability(
			4,
			{
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.program(_pct)),
				},
				"label": "Add 1 installed program to the bottom of the stack",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to the bottom of the stack"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.move(state, "runner", target, "deck"),
			}
		)
		return {
			"subroutines": [sub, sub, NRDefHelpers.give_tags(1)],
			"runner-abilities": [_bioroid_break(2, 2)],
		}
	).call()))
	NRCardDefs.defcard("Shinobi", NRUtil.merge({
		"title": "Shinobi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 7,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Sentry - Tracer - AP - Liability",
		"subtypes": ["Sentry", "Tracer", "AP", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trace[1]. If successful, do 1 net damage.\n[subroutine] Trace[2]. If successful, do 2 net damage.\n[subroutine] Trace[3]. If successful, do 3 net damage and end the run."
	}, {
		"on-rez": _take_bad_pub(),
		"subroutines": [
			_trace_ability(1, NRDefHelpers.do_net_damage(1)),
			_trace_ability(2, NRDefHelpers.do_net_damage(2)),
			_trace_ability(
				3,
				{
					"label": "Do 3 net damage and end the run",
					"msg": "do 3 net damage and end the run",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRDamage.damage(state, side, ne, "net", 3, {
								"card": card,
							})
						, func(async_result):
							NRRuns.end_run(state, side, eid, card)),
				}
			)
		],
	}))
	NRCardDefs.defcard("Shiro", NRUtil.merge({
		"title": "Shiro",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 6,
		"strength": 5,
		"factioncost": 4,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] Look at the top 3 cards of R&D and arrange them in any order.\n[subroutine] You may pay 1[credit]. If you do not, the Runner breaches R&D. They cannot access cards in the root of R&D during that breach."
	}, {
		"subroutines": [
			{
				"label": "Rearrange the top 3 cards of R&D",
				"msg": "rearrange the top 3 cards of R&D",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, (func():
						var from = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3))
						return (reorder_choice("corp", "runner", from, null, NRCardRT.count_of(from), from) if NRCardRT.truthy(NRCardRT.pos(NRCardRT.count_of(from))) else null)
					).call(), card, null),
			},
			{
				"label": "The runner breaches R&D unless the corp pays 1 [Credit]",
				"optional": {
					"prompt": "Pay 1 [Credits] to keep the Runner from breaching R&D?",
					"yes-ability": {
						"cost": [NRPayment.to_c("credit", 1)],
						"msg": "keep the Runner from breaching R&D",
					},
					"no-ability": {
						"async": true,
						"msg": "make the Runner breach R&D",
						"effect": func(state, side, eid, card, targets):
							return NRAccess.breach_server(
								state,
								"runner",
								eid,
								["rd"],
								{
									"no-root": true,
								}
							),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Sleipnir", NRUtil.merge({
		"title": "Sleipnir",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] You may draw 1 card.\n[subroutine] You may shuffle 1 card from HQ or Archives into R&D.\n[subroutine] End the run."
	}, {
		"subroutines": [
			_maybe_draw_sub(1),
			{
				"prompt": "Shuffle up 1 card from HQ or Archives into R&D?",
				"label": "You may shuffle 1 card from HQ or Archives into R&D",
				"show-discard": true,
				"waiting-prompt": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
				},
				"async": true,
				"msg": {
					"public": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("shuffle ") + str(NRToString.card_str(state, target)) + str(" into R&D"),
					"corp": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("shuffle ") + str(NRToString.card_str(
							state,
							target,
							{
								"maybe-visible": true,
							}
						)) + str(" into R&D"),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRMoving.move(state, "corp", target, "deck")
					NRShuffling.shuffle_zone(state, "corp", "deck")
					return NREid.effect_completed(state, "corp", eid),
			},
			_end_the_run()
		],
	}))
	NRCardDefs.defcard("Slot Machine", NRUtil.merge({
		"title": "Slot Machine",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, they put the top card of the stack on the bottom, then you reveal the top 3 cards of the stack.\n[subroutine] The Runner loses 3[credit].\n[subroutine] If you revealed 2 or more cards that share a type when this encounter began, gain 3[credit].\n[subroutine] If you revealed 3 or more cards that share a type when this encounter began, place 3 advancement tokens on an installed card."
	}, {
		"on-encounter": _ability_27(),
		"abilities": [_ability_27()],
		"subroutines": [
			{
				"label": "Runner loses 3 [Credits]",
				"msg": "force the Runner to lose 3 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose_credits(state, "runner", eid, 3),
			},
			{
				"label": "Gain 3 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
						var et = _effect_type_24(card)
						var unique_types = _top_3_types_26(state, card, et)
						return ((func():
							NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain 3 [Credits]"))
							return NRGaining.gain_credits(state, "corp", eid, 3)
						).call() if (((unique_types <= 2) and ((3 == NRCardRT.count_of(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0))) or NRUtil.kw_eq(3, NRCardRT.count_of(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0))))) or (((unique_types == 1) or NRUtil.kw_eq(unique_types, 1)) and ((2 == NRCardRT.count_of(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0))) or NRUtil.kw_eq(2, NRCardRT.count_of(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0)))))) else NREid.effect_completed(state, side, eid))
					).call(),
			},
			{
				"label": "Place 3 advancement counters",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, (func():
						var et = _effect_type_24(card)
						var unique_types = _top_3_types_26(state, card, et)
						return ({
							"choices": {
								"card": NRCard.installed,
							},
							"prompt": "Choose an installed card",
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("place 3 advancement counters on ") + str(NRToString.card_str(state, target)),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRProps.add_prop(
									state,
									side,
									eid,
									target,
									"advance-counter",
									3,
									{
										"placed": true,
									}
								),
						} if NRCardRT.truthy((((3 == NRCardRT.count_of(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0))) or NRUtil.kw_eq(3, NRCardRT.count_of(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0)))) and ((1 == unique_types) or NRUtil.kw_eq(1, unique_types)))) else null)
					).call(), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Snoop", NRUtil.merge({
		"title": "Snoop",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"strength": 6,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "When the Runner encounters Snoop, reveal all cards in the Runner's grip.\n<strong>Hosted power counter:</strong> Reveal all cards in the Runner's grip. Trash 1 of those cards.\n[subroutine] Trace[3]. If successful, place 1 power counter on Snoop."
	}, {
		"on-encounter": {
			"msg": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return str("reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.getv(runner, "hand"), "sorted")) + str(" from the grip"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRRevealing.reveal(state, side, eid, NRCardRT.getv(runner, "hand")),
		},
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "power")),
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.seq_of(NRCardRT.getv(runner, "hand")),
				},
				"cost": [NRPayment.to_c("power", 1)],
				"label": "Reveal all cards in the grip and trash 1 card",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return NREngine.resolve_ability(state, side, eid, with_revealed_hand(
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
					), card, null),
			}
		],
		"subroutines": [_trace_ability(3, _gain_power_counter())],
	}))
	NRCardDefs.defcard("Snowflake", NRUtil.merge({
		"title": "Snowflake",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Barrier - Psi",
		"subtypes": ["Barrier", "Psi"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. End the run if you and the Runner spent a different number of credits."
	}, {
		"subroutines": [_do_psi(_end_the_run())],
	}))
	NRCardDefs.defcard("Sorocaban Blade", NRUtil.merge({
		"title": "Sorocaban Blade",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "You cannot trash more than 1 installed Runner card with this ice during each encounter.\n[subroutine] Trash 1 installed resource.\n[subroutine] Trash 1 installed piece of hardware.\n[subroutine] Trash 1 installed program."
	}, {
		"events": [
			{
				"event": "corp-trash",
				"silent": true,
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets):
					return NRRuns.get_current_encounter(state) and NRCardRT.some_list(NRCardRT.map_list(targets, func(x): return NRCardRT.getv(x, "card")), func(_pct):
						return (NRCard.runner(_pct) and NRCard.installed(_pct))),
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.assoc_in(card, ["special", "sorocaban-blade"], true)),
			},
			{
				"event": "end-of-encounter",
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, card),
			}
		],
		"subroutines": [
			_trash_resource_sub(),
			NRUtil.merge(_trash_hardware_sub(), {"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCardRT.get_in(card, ["special", "sorocaban-blade"], null))),
			}}),
			NRUtil.merge(_trash_program_sub(), {"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (not NRCardRT.truthy(NRCardRT.get_in(card, ["special", "sorocaban-blade"], null))),
			}})
		],
	}))
	NRCardDefs.defcard("Special Offer", NRUtil.merge({
		"title": "Special Offer",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Trap - Advertisement",
		"subtypes": ["Trap", "Advertisement"],
		"text": "[subroutine] The Corp gains 5[credit]. Trash Special Offer."
	}, {
		"subroutines": [
			{
				"label": "Gain 5 [Credits] and trash this ice",
				"msg": "gain 5 [Credits] and trash itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "corp", ne, 5)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, "corp", ne, card, {
								"cause": "subroutine",
							})
						, func(async_result):
							NRRuns.encounter_ends(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Spiderweb", NRUtil.merge({
		"title": "Spiderweb",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run(), _end_the_run(), _end_the_run()],
	}))
	NRCardDefs.defcard("Starlit Knight", NRUtil.merge({
		"title": "Starlit Knight",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Sentry - Observer",
		"subtypes": ["Sentry", "Observer"],
		"text": "Threat 4 → When the Runner encounters this ice, it gains X \"[subroutine] End the run.\" subroutines for the remainder of this run, after its other subroutines. X is equal to the number of tags the Runner has.\n[subroutine] Give the Runner 1 tag.\n[subroutine] Give the Runner 1 tag."
	}, {
		"on-encounter": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				return NRThreat.threat(state, int(4)),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var subs = NRTags.sum_tag_effects(state)
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "additional-subroutines",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRUtil.same_card(card, target),
							"value": func(state, side, eid, card, targets):
								return {
									"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(_end_the_run(), int(subs))),
								},
						}
					)
				).call(),
		},
		"subroutines": [NRDefHelpers.give_tags(1), NRDefHelpers.give_tags(1)],
	}))
	NRCardDefs.defcard("Stavka", NRUtil.merge({
		"title": "Stavka",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - Destroyer",
		"subtypes": ["Sentry", "Destroyer"],
		"text": "When you rez this ice, you may trash 1 of your other installed cards. If you do, this ice gets +5 strength for the remainder of the run.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program."
	}, {
		"on-rez": {
			"optional": {
				"prompt": "Trash another card to give Stavka +5 strength?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					return NRPayment.can_pay(state, side, NRUtil.merge(eid, {"source": card, "source-type": "ability"}), card, null, [NRPayment.to_c("trash-other-installed", 1)]),
				"yes-ability": {
					"prompt": "Choose another installed card to trash",
					"cost": [NRPayment.to_c("trash-other-installed", 1)],
					"msg": "give itself +5 strength for the remainder of the run",
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return ((func():
							NREffects.register_lingering_effect(
								state,
								side,
								card,
								{
									"type": "ice-strength",
									"duration": "end-of-run",
									"req": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return NRUtil.same_card(target, card),
									"value": 5,
								}
							)
							return NRIce.update_ice_strength(state, side, card)
						).call() if NRCardRT.truthy(NRCardRT.getv(state.data, "run")) else null),
				},
			},
		},
		"subroutines": [_trash_program_sub(), _trash_program_sub()],
	}))
	NRCardDefs.defcard("Surveyor", NRUtil.merge({
		"title": "Surveyor",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "X is twice the number of ice protecting this server.\n[subroutine]Trace[X]. If successful, give the Runner 2 tags.\n[subroutine]Trace[X]. If successful, end the run."
	}, {
		"static-abilities": [NRCardRT.ice_strength_bonus(NRCardRT.get_x_fn())],
		"x-fn": func(state, side, eid, card, targets):
			return (2 * NRCardRT.count_of(NRCardRT.getv(NRBoard.card_to_server(state, card), "ices"))),
		"subroutines": [
			{
				"label": "Trace X - Give the Runner 2 tags",
				"trace": {
					"base": NRCardRT.get_x_fn(),
					"label": "Give the Runner 2 tags",
					"successful": NRDefHelpers.give_tags(2),
				},
			},
			{
				"label": "Trace X - End the run",
				"trace": {
					"base": NRCardRT.get_x_fn(),
					"label": "End the run",
					"successful": _end_the_run(),
				},
			}
		],
	}))
	NRCardDefs.defcard("Susanoo-no-Mikoto", NRUtil.merge({
		"title": "Susanoo-no-Mikoto",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 9,
		"strength": 7,
		"factioncost": 3,
		"keywords": "Sentry - Deflector",
		"subtypes": ["Sentry", "Deflector"],
		"text": "[subroutine] If the attacked server is not Archives, the Runner moves to the outermost position of Archives instead of passing this ice. The Runner cannot jack out this run until after they encounter a piece of ice."
	}, {
		"subroutines": [
			{
				"async": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						return run and (not ((NRCardRT.getv(run, "server") == ["discard"]) or NRUtil.kw_eq(NRCardRT.getv(run, "server"), ["discard"]))),
				},
				"msg": "make the Runner continue the run on Archives",
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (func():
						var lingering = NREffects.register_lingering_effect(
							state,
							side,
							card,
							{
								"type": "cannot-jack-out",
								"value": true,
								"duration": "end-of-run",
							}
						)
						NREngine.register_events(
							state,
							side,
							card,
							[
								{
									"event": "encounter-ice",
									"duration": "end-of-run",
									"unregister-once-resolved": true,
									"effect": func(state, side, eid, card, targets):
										return NREffects.unregister_effect_by_uuid(state, side, lingering),
								}
							]
						)
						return ((func():
							NRRuns.redirect_run(state, side, "Archives", "approach-ice")
							return NRRuns.encounter_ends(state, side, eid)
						).call() if (((1 == NRCardRT.count_of(NRCardRT.getv(state.data, "encounters"))) or NRUtil.kw_eq(1, NRCardRT.count_of(NRCardRT.getv(state.data, "encounters")))) and (not (("success" == NRCardRT.getv(run, "phase")) or NRUtil.kw_eq("success", NRCardRT.getv(run, "phase"))))) else NREid.effect_completed(state, side, eid))
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Swarm", NRUtil.merge({
		"title": "Swarm",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 4,
		"keywords": "Sentry - Destroyer - Liability",
		"subtypes": ["Sentry", "Destroyer", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\nYou can advance this ice. It gains \"[subroutine] Trash 1 installed program unless the Runner pays 3[credit].\" for each hosted advancement counter."
	}, (func():
		var sub = {
			"player": "runner",
			"async": true,
			"label": "Trash a program",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
					"The Corp trashes a program",
					("Pay 3 [Credits]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 3)])) else null)
				],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, "runner", ne, card, [NRPayment.to_c("credit", 3)])
				, func(async_result):
					NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
					NREid.effect_completed(state, side, eid)) if (("Pay 3 [Credits]" == target) or NRUtil.kw_eq("Pay 3 [Credits]", target)) else NREngine.resolve_ability(state, "corp", eid, _trash_program_sub(), card, null)),
		}
		return NRUtil.merge(_hero_to_hero(sub), {"on-rez": _take_bad_pub()})
	).call()))
	NRCardDefs.defcard("Swordsman", NRUtil.merge({
		"title": "Swordsman",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Sentry - AP - Destroyer",
		"subtypes": ["Sentry", "AP", "Destroyer"],
		"text": "The Runner cannot break subroutines on this ice using <strong>AI</strong> programs.\n[subroutine] Trash 1 installed <strong>AI</strong> program.\n[subroutine] Do 1 net damage."
	}, {
		"static-abilities": [
			{
				"type": "cannot-break-subs-on-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and NRCard.has_subtype(NRCardRT.getv(context, "icebreaker"), "AI"),
				"value": true,
			}
		],
		"subroutines": [
			{
				"async": true,
				"prompt": "Choose an AI program to trash",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"label": "Trash an AI program",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
							return (NRCard.installed(_pct) and NRCard.program(_pct) and NRCard.has_subtype(_pct, "AI"))),
				},
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.program(_pct) and NRCard.has_subtype(_pct, "AI")),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause": "subroutine",
						}
					),
			},
			NRDefHelpers.do_net_damage(1)
		],
	}))
	NRCardDefs.defcard("SYNC BRE", NRUtil.merge({
		"title": "SYNC BRE",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] Trace[4]. If successful, give the Runner 1 tag.\n[subroutine] Trace[2]. If successful, whenever the Runner breaches a server for the remainder of this run, they access 1 fewer card."
	}, {
		"subroutines": [
			_tag_trace(4),
			_trace_ability(
				2,
				{
					"label": "Runner reduces cards accessed by 1 for this run",
					"msg": "reduce cards accessed for this run by 1",
					"effect": func(state, side, eid, card, targets):
						return NRAccess.access_bonus(state, side, "total", -1),
				}
			)
		],
	}))
	NRCardDefs.defcard("Syailendra", NRUtil.merge({
		"title": "Syailendra",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "You can advance this ice.\nWhen the Runner encounters this ice, if it has 3 or more hosted advancement counters, you may place 1 advancement counter on an installed card you can advance.\n[subroutine] You may place 1 advancement counter on an installed card you can advance.\n[subroutine] The Runner loses 2[credit].\n[subroutine] Do 1 net damage."
	}, {
		"advanceable": "always",
		"on-encounter": NRUtil.merge(place_advancement_counter(true), {"interactive": func(state, side, eid, card, targets):
			return true, "req": func(state, side, eid, card, targets):
				return (NRCard.get_counters(card, "advancement") >= 3)}),
		"prompt": "Place 1 advancement counter on an installed card",
		"subroutines": [place_advancement_counter(true), _runner_loses_credits(2), NRDefHelpers.do_net_damage(1)],
	}))
	NRCardDefs.defcard("Tapestry", NRUtil.merge({
		"title": "Tapestry",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 6,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner loses [click], if able.\n[subroutine] The Corp may draw 1 card.\n[subroutine] The Corp may add 1 card from HQ to the top of R&D."
	}, {
		"subroutines": [
			_runner_loses_click(),
			_maybe_draw_sub(1),
			{
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
				"prompt": "Choose a card in HQ to move to the top of R&D",
				"choices": {
					"card": func(_pct):
						return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
				},
				"msg": "add 1 card in HQ to the top of R&D",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.move(
						state,
						side,
						target,
						"deck",
						{
							"front": true,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Tatu-Bola", NRUtil.merge({
		"title": "Tatu-Bola",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When the Runner passes this ice, you may swap it with a piece of ice from HQ. If you do, gain 4[credit]. <em>(The new ice is installed unrezzed. You do not pay an install cost.)</em>\n[subroutine] End the run."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"interactive": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), card),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, ({
						"optional": {
							"prompt": func(state, side, eid, card, targets):
								return str("Gain 4 [Credits] and swap ") + str(NRToString.card_str(state, card)) + str(" with a piece of ice in HQ?"),
							"waiting-prompt": true,
							"no-ability": {
								"msg": "decline to install a card",
							},
							"yes-ability": {
								"prompt": "Choose a piece of ice",
								"waiting-prompt": true,
								"choices": func(state, side, eid, card, targets):
									var corp = state.player("corp")
									return NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), NRCard.ice),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NREid.wait_for(state, eid, func(ne):
										swap_cards_async(state, side, ne, target, NRCard.get_card(state, card))
									, func(async_result):
										NRGaining.gain_credits(state, "corp", eid, 4)),
								"msg": func(state, side, eid, card, targets):
									return str("swap ") + str(NRToString.card_str(state, card)) + str(" with a piece of ice from HQ and gain 4 [Credits]"),
							},
						},
					} if NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), NRCard.ice)) else {
						"prompt": "You have no ice",
						"choices": ["OK"],
						"waiting-prompt": true,
						"msg": "decline to install a card",
					}), card, null),
			}
		],
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Taurus", NRUtil.merge({
		"title": "Taurus",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] Trace[2]. If successful, trash 1 piece of hardware. If your trace strength is 5 or greater, trash 1 piece of hardware."
	}, _constellation_ice(_trash_hardware_sub())))
	NRCardDefs.defcard("Thimblerig", NRUtil.merge({
		"title": "Thimblerig",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When your turn begins and whenever the Runner passes this ice, you may swap this ice with another installed piece of ice.\n[subroutine] End the run."
	}, (func():
		var ability = {
			"interactive": func(state, side, eid, card, targets):
				var run = state.getv("run")
				return run,
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					return (2 <= NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), NRCard.ice))) and (NRUtil.same_card(NRCardRT.getv(context, "ice"), card) if run else true),
				"prompt": func(state, side, eid, card, targets):
					return str("Swap ") + str(NRToString.card_str(state, card)) + str(" with another ice?"),
				"yes-ability": {
					"prompt": "Choose a piece of ice to swap Thimblerig with",
					"choices": {
						"card": NRCard.ice,
						"not-self": true,
					},
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.swap_ice(state, side, card, target),
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("swap ") + str(NRToString.card_str(state, card)) + str(" with ") + str(NRToString.card_str(state, target)),
				},
			},
		}
		return {
			"events": [
				NRUtil.merge(_ability_27(), {"event": "pass-ice"}),
				NRUtil.merge(_ability_27(), {"event": "corp-turn-begins"})
			],
			"subroutines": [_end_the_run()],
		}
	).call()))
	NRCardDefs.defcard("Thoth", NRUtil.merge({
		"title": "Thoth",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"cost": 7,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "When the Runner encounters this ice, give them 1 tag.\n[subroutine] Trace[4]. If successful, do 1 net damage for each tag the Runner has.\n[subroutine] Trace[4]. If successful, the Runner loses 1[credit] for each tag they have."
	}, {
		"on-encounter": NRDefHelpers.give_tags(1),
		"subroutines": [
			_trace_ability(
				4,
				{
					"label": "Do 1 net damage for each Runner tag",
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("do ") + str(count_tags(state)) + str(" net damage"),
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(
							state,
							side,
							eid,
							"net",
							count_tags(state),
							{
								"card": card,
							}
						),
				}
			),
			_trace_ability(
				4,
				{
					"label": "Runner loses 1 [Credits] for each tag",
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("force the Runner to lose ") + str(count_tags(state)) + str(" [Credits]"),
					"effect": func(state, side, eid, card, targets):
						return NRGaining.lose_credits(state, "runner", eid, count_tags(state)),
				}
			)
		],
	}))
	NRCardDefs.defcard("Tithe", NRUtil.merge({
		"title": "Tithe",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"strength": 1,
		"factioncost": 0,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] Do 1 net damage.\n[subroutine] Gain 1[credit]."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(1), _gain_credits_sub(1)],
	}))
	NRCardDefs.defcard("Tithonium", NRUtil.merge({
		"title": "Tithonium",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 9,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Barrier - Destroyer",
		"subtypes": ["Barrier", "Destroyer"],
		"text": "You may forfeit an agenda to rez Tithonium instead of paying its rez cost.\nTithonium cannot host cards.\n[subroutine] Trash 1 program.\n[subroutine] Trash 1 program.\n[subroutine] Trash 1 resource and end the run."
	}, {
		"alternative-cost": [NRPayment.to_c("forfeit")],
		"cannot-host": true,
		"subroutines": [
			_trash_program_sub(),
			_trash_program_sub(),
			{
				"label": "Trash a resource and end the run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var async_result = NREid.result_of(eid)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, {
							"req": func(state, side, eid, card, targets):
								return NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "runner"), NRCard.resource))),
							"async": true,
							"choices": {
								"all": true,
								"card": func(_pct):
									return (NRCard.installed(_pct) and NRCard.resource(_pct)),
							},
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash(state, side, ne, target, {
										"cause": "subroutine",
									})
								, func(async_result):
									NREid.complete_with_result(state, side, eid, target)),
						}, card, null)
					, func(async_result):
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to ") + str((str("trash ") + str(NRCardRT.getv(async_result, "title")) + str(" and ends the run") if async_result else "end the run")))
						NRRuns.end_run(state, side, eid, card)),
			}
		],
	}))
	NRCardDefs.defcard("TL;DR", NRUtil.merge({
		"title": "TL;DR",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The next time the Runner encounters a piece of ice during this run, that ice gains a second copy of each of its subroutines <em>(after the original subroutine)</em> for the remainder of that encounter."
	}, {
		"subroutines": [
			{
				"label": "Duplicate each subroutine on a piece of ice",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return NREngine.register_events(
						state,
						side,
						card,
						[
							{
								"event": "encounter-ice",
								"duration": "end-of-run",
								"unregister-once-resolved": true,
								"msg": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									return str("duplicate each subroutine on ") + str(NRCardRT.getv(NRCardRT.getv(context, "ice"), "title")),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									var context = NRCardRT.ctx(targets)
									return (func():
										var t = NRCardRT.getv(context, "ice")
										return NREffects.register_lingering_effect(
											state,
											side,
											card,
											{
												"type": "tldr-effect",
												"duration": "end-of-encounter",
												"value": 1,
												"req": func(state, side, eid, card, targets):
													var target = NRCardRT.first_target(targets)
													return NRUtil.same_card(t, target),
											}
										)
									).call(),
							}
						]
					),
			}
		],
	}))
	NRCardDefs.defcard("TMI", NRUtil.merge({
		"title": "TMI",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "When you rez TMI, Trace[2]. If unsuccessful, derez TMI.\n[subroutine] End the run."
	}, {
		"on-rez": {
			"trace": {
				"base": 2,
				"msg": "keep TMI rezzed",
				"label": "Keep TMI rezzed",
				"unsuccessful": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRRezzing.derez(state, side, eid, card),
				},
			},
		},
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Tocsin", NRUtil.merge({
		"title": "Tocsin",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Code Gate - Expendable",
		"subtypes": ["Code Gate", "Expendable"],
		"text": "[click], <strong>1</strong>[credit], <strong>reveal and trash this ice from HQ:</strong> Search R&D for up to 1 <strong>barrier</strong> and up to 1 <strong>sentry</strong> and reveal them. <em>(Shuffle R&D after searching it.)</em> Add those cards to HQ.\n[subroutine] The Runner loses 2[credit].\n[subroutine] End the run.\n[subroutine] End the run."
	}, {
		"subroutines": [_runner_loses_credits(2), _end_the_run(), _end_the_run()],
		"expend": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"cost": [NRPayment.to_c("credit", 1)],
			"msg": "search R&D for up to 1 barrier and up to 1 sentry",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _search_for_type_29("Barrier", []), card, null),
		},
	}))
	NRCardDefs.defcard("Tollbooth", NRUtil.merge({
		"title": "Tollbooth",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, they must pay 3[credit], if able. If they do not, end the run.\n[subroutine] End the run."
	}, {
		"on-encounter": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, "runner", ne, card, [NRPayment.to_c("credit", 3)])
				, func(async_result):
					((func():
						NRSay.system_msg(state, "runner", str(NRCardRT.getv(async_result, "msg")) + str(" on encountering ") + str(NRCardRT.getv(card, "title")))
						return NREid.effect_completed(state, side, eid)
					).call() if NRCardRT.getv(async_result, "cost-paid") else (func():
						NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to end the run"))
						return NRRuns.end_run(state, "corp", eid, card)
					).call())),
		},
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Tour Guide", NRUtil.merge({
		"title": "Tour Guide",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "This ice gains \"[subroutine] End the run.\" for each rezzed asset."
	}, _variable_subs_ice(
		func(state):
			return NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), NRCard.asset)),
		_end_the_run()
	)))
	NRCardDefs.defcard("Trebuchet", NRUtil.merge({
		"title": "Trebuchet",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 7,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Sentry - Destroyer - Tracer - Liability",
		"subtypes": ["Sentry", "Destroyer", "Tracer", "Liability"],
		"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] Trace[6]. If successful, the Runner cannot steal or trash Corp cards for the remainder of this run."
	}, {
		"on-rez": _take_bad_pub(),
		"subroutines": [_trash_installed_sub(), _trace_ability(6, _cannot_steal_or_trash_sub())],
	}))
	NRCardDefs.defcard("Tree Line", NRUtil.merge({
		"title": "Tree Line",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Barrier - Expendable",
		"subtypes": ["Barrier", "Expendable"],
		"text": "[click], <strong>1</strong>[credit], <strong>reveal and trash this ice from HQ:</strong> Place 3 advancement counters on 1 installed piece of ice.\nYou can advance this ice. It gets +1 strength for each hosted advancement counter.\n[subroutine] Gain 1[credit]. End the run."
	}, {
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "advancement"))
		],
		"subroutines": [
			{
				"msg": "gain 1 [Credits] and end the run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, 1)
					, func(async_result):
						NRRuns.end_run(state, side, eid, card)),
			}
		],
		"advanceable": "always",
		"expend": NRUtil.merge(place_advancement_counter(null, 3, "an ice", NRCard.ice), {"cost": [NRPayment.to_c("credit", 1)]}),
	}))
	NRCardDefs.defcard("Tribunal", NRUtil.merge({
		"title": "Tribunal",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 7,
		"strength": 3,
		"factioncost": 0,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "[subroutine] The Runner trashes 1 of their installed cards.\n[subroutine] The Runner trashes 1 of their installed cards.\n[subroutine] The Runner trashes 1 of their installed cards."
	}, {
		"subroutines": [_runner_trash_installed_sub(), _runner_trash_installed_sub(), _runner_trash_installed_sub()],
	}))
	NRCardDefs.defcard("Tributary", NRUtil.merge({
		"title": "Tributary",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"cost": 3,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "The first time each turn a run begins, you may move this ice to the outermost position protecting the attacked server. <em>(The Runner will approach this ice.)</em>\n[subroutine] You may draw 1 card. You may install 1 piece of ice from HQ protecting another server, ignoring all costs.\n[subroutine] Each piece of ice gets +2 strength for the remainder of this run."
	}, {
		"subroutines": [
			{
				"label": "Draw 1 card and install a piece of ice from HQ protecting another server",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.maybe_draw(state, side, ne, card, 1)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"choices": {
								"card": func(_pct):
									return (NRCard.ice(_pct) and NRCard.in_hand(_pct)),
							},
							"prompt": "Choose a piece of ice to install",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (func():
									var this_ = NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(card), 1))
									var nice = target
									return NREngine.resolve_ability(state, side, eid, {
										"prompt": str("Choose a location to install ") + str(NRCardRT.getv(target, "title")),
										"choices": func(state, side, eid, card, targets):
											return NRCardRT.filter_list(NRBoard.installable_servers(state, nice), func(x): return not NRCardRT.truthy((func(_pct):
												return ((this_ == _pct) or NRUtil.kw_eq(this_, _pct))).call(x))),
										"async": true,
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return NRInstalling.corp_install(
												state,
												side,
												eid,
												nice,
												target,
												{
													"ignore-install-cost": true,
													"msg-keys": {
														"install-source": card,
														"display-origin": true,
													},
												}
											),
									}, card, null)
								).call(),
						}, card, null)),
			},
			{
				"label": "Give +2 strength to each piece of ice for the remainder of the run",
				"msg": "give +2 strength to each piece of ice for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "ice-strength",
							"duration": "end-of-run",
							"value": 2,
						}
					)
					return NRIce.update_all_ice(state, side),
			}
		],
		"events": [
			{
				"event": "run",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "run"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (func():
						var target_server = NRCardRT.getv(run, "server")
						return NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"prompt": func(state, side, eid, card, targets):
									return str("Move ") + str(NRCardRT.getv(card, "title")) + str(" to the outermost position of ") + str(NRServers.zone_to_name(NRServers.target_server)) + str("?"),
								"waiting-prompt": true,
								"yes-ability": {
									"once": "per-turn",
									"msg": func(state, side, eid, card, targets):
										return str("move itself to the outermost position of ") + str(NRServers.zone_to_name(NRServers.target_server)),
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return (func():
											var moved = NRMoving.move(state, side, NRCard.get_card(state, card), (NRCardRT.as_array(["servers", NRCardRT.getv(NRServers.target_server, 0)]) + ["ices"]))
											NRRuns.redirect_run(state, side, NRServers.target_server)
											NREngine.unregister_events(state, side, moved)
											NREngine.register_default_events(state, side, moved)
											return NREid.effect_completed(state, side, eid)
										).call(),
								},
							},
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Troll", NRUtil.merge({
		"title": "Troll",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry",
		"subtypes": ["Sentry"],
		"text": "When the Runner encounters Troll, Trace[2]. If successful, the Runner must lose [click] or end the run."
	}, {
		"on-encounter": _trace_ability(
			2,
			{
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str((str("force the runner to ") + str(NRCardRT.decapitalize(target)) if ((target == "Spend [Click]") or NRUtil.kw_eq(target, "Spend [Click]")) else NRCardRT.decapitalize(target))),
				"player": "runner",
				"prompt": "Choose one",
				"waiting-prompt": true,
				"choices": func(state, side, eid, card, targets):
					return [
						("Spend [Click]" if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("click", 1)])) else null),
						"End the run"
					],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var async_result = NREid.result_of(eid)
					return (NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, side, ne, card, NRPayment.to_c("click", 1))
					, func(async_result):
						NRSay.system_msg(state, side, NRCardRT.getv(async_result, "msg"))
						NREid.effect_completed(state, "runner", eid)) if (((target == "Spend [Click]") or NRUtil.kw_eq(target, "Spend [Click]")) and NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("click", 1)])) else NRRuns.end_run(state, "corp", eid, card)),
			}
		),
	}))
	NRCardDefs.defcard("Tsurugi", NRUtil.merge({
		"title": "Tsurugi",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 6,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "[subroutine] End the run unless the Corp pays 1[credit].\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
	}, {
		"subroutines": [
			_end_the_run_unless_corp_pays([NRPayment.to_c("credit", 1)]),
			NRDefHelpers.do_net_damage(1),
			NRDefHelpers.do_net_damage(1),
			NRDefHelpers.do_net_damage(1)
		],
	}))
	NRCardDefs.defcard("Turing", NRUtil.merge({
		"title": "Turing",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "Turing has +3 strength while protecting a remote server.\nThe Runner cannot use <strong>AI</strong> programs to break subroutines on Turing.\n[subroutine] End the run unless the Runner spends [click][click][click]."
	}, {
		"static-abilities": [
			{
				"type": "cannot-break-subs-on-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and NRCard.has_subtype(NRCardRT.getv(context, "icebreaker"), "AI"),
				"value": true,
			},
			NRCardRT.ice_strength_bonus(3, func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRCard.protecting_a_central(card))))
		],
		"subroutines": [_end_the_run_unless_runner_pays(NRPayment.to_c("click", 3))],
	}))
	NRCardDefs.defcard("Turnpike", NRUtil.merge({
		"title": "Turnpike",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "When the Runner encounters this ice, they lose 1[credit].\n[subroutine] Trace[5]. If successful, give the Runner 1 tag."
	}, {
		"on-encounter": _runner_loses_credits(1),
		"subroutines": [_tag_trace(5)],
	}))
	NRCardDefs.defcard("Týr", NRUtil.merge({
		"title": "Týr",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 10,
		"strength": 7,
		"factioncost": 5,
		"keywords": "Sentry - Bioroid - AP - Destroyer",
		"subtypes": ["Sentry", "Bioroid", "AP", "Destroyer"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. The Corp gets +1 allotted [click] for their next turn. Only the Runner can use this ability.\n[subroutine] Do 2 core damage.\n[subroutine] Trash 1 installed Runner card. Gain 3[credit].\n[subroutine] End the run."
	}, {
		"subroutines": [
			NRDefHelpers.do_brain_damage(2),
			NRCardRT.combine_abilities(_trash_installed_sub(), _gain_credits_sub(3)),
			_end_the_run()
		],
		"runner-abilities": [
			_bioroid_break(
				1,
				1,
				{
					"additional-ability": {
						"effect": func(state, side, eid, card, targets):
							return state.update_in(["corp", "extra-click-temp"], func(v): return v),
					},
				}
			)
		],
	}))
	NRCardDefs.defcard("Tyrant", NRUtil.merge({
		"title": "Tyrant",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 7,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "You can advance this ice if it is rezzed. It gains \"[subroutine] End the run.\" for each hosted advancement counter."
	}, _zero_to_hero(_end_the_run())))
	NRCardDefs.defcard("Universal Connectivity Fee", NRUtil.merge({
		"title": "Universal Connectivity Fee",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 1,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] If the Runner is not tagged, they lose 1[credit]. If the Runner is tagged, they lose all credits in their credit pool and you trash this ice."
	}, {
		"subroutines": [
			{
				"label": "Force the Runner to lose credits",
				"msg": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return str("force the Runner to lose ") + str(("all credits and trash itself" if tagged else "1 [Credits]")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return (NREid.wait_for(state, eid, func(ne):
						NRGaining.lose_credits(state, "runner", ne, "all")
					, func(async_result):
						NRMoving.trash(
							state,
							"corp",
							NREid.make_eid(state, eid),
							card,
							{
								"cause": "subroutine",
							}
						)
						NRRuns.encounter_ends(state, side, eid)) if tagged else NRGaining.lose_credits(state, "runner", eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("Unsmiling Tsarevna", NRUtil.merge({
		"title": "Unsmiling Tsarevna",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "When you rez this ice during a run against this server, you may have the Runner gain 2[credit]. If you do, during each encounter with this ice for the remainder of that run, the Runner cannot break more than 1 of its printed subroutines.\n[subroutine] Give the Runner 1 tag.\n[subroutine] Do 2 net damage.\n[subroutine] You may draw 2 cards."
	}, (func():
		var breakable_fn = func(state, side, eid, card, targets):
			return (NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCardRT.getv(x, "broken")) and NRCardRT.truthy(NRCardRT.getv(x, "printed"))))) or (not NRCardRT.truthy(NREffects.any_effects(state, side, "unsmiling-effect", true_, card, [card]))))
		var on_rez_ability = {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str("let the Runner gain 2 [Credits] to") + str(" prevent them from breaking more than 1 printed subroutine") + str(" on this ice per encounter for the remainder of this run"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var context = NRCardRT.ctx(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, "runner", ne, 2)
				, func(async_result):
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "unsmiling-effect",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRUtil.same_card(card, target),
							"value": true,
						}
					)
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "cannot-auto-break-subs-on-ice",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var context = NRCardRT.ctx(targets)
								return NRUtil.same_card(card, NRCardRT.getv(context, "ice")),
							"value": true,
						}
					)
					NREid.effect_completed(state, side, eid)),
		}
		return {
			"subroutines": [
				NRUtil.merge(NRDefHelpers.give_tags(1), {"breakable": breakable_fn}),
				NRUtil.merge(NRDefHelpers.do_net_damage(2), {"breakable": breakable_fn}),
				NRUtil.merge(_maybe_draw_sub(2), {"breakable": breakable_fn})
			],
			"on-rez": {
				"optional": {
					"prompt": "Let the Runner gain 2 [Credits]?",
					"waiting-prompt": true,
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						var this_server = NRCardRT.this_server(state, card)
						return run and this_server,
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREngine.resolve_ability(state, side, eid, on_rez_ability, card, null),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
					},
				},
			},
		}
	).call()))
	NRCardDefs.defcard("Upayoga", NRUtil.merge({
		"title": "Upayoga",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate - Psi",
		"subtypes": ["Code Gate", "Psi"],
		"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, the Runner loses 2[credit].\n[subroutine] Resolve a subroutine on a piece of rezzed <strong>psi</strong> ice."
	}, {
		"subroutines": [
			_do_psi(_runner_loses_credits(2)),
			_resolve_another_subroutine(
				func(_pct):
					return NRCard.has_subtype(_pct, "Psi"),
				"Resolve a subroutine on a rezzed psi ice",
				true
			)
		],
	}))
	NRCardDefs.defcard("Uroboros", NRUtil.merge({
		"title": "Uroboros",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] Trace[4]. If successful, the Runner cannot make another run this turn.\n[subroutine] Trace[4]. If successful, end the run."
	}, {
		"subroutines": [_trace_ability(4, _prevent_runs_this_turn()), _trace_ability(4, _end_the_run())],
	}))
	NRCardDefs.defcard("Valentão", NRUtil.merge({
		"title": "Valentão",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"strength": 6,
		"factioncost": 3,
		"keywords": "Code Gate - Liability",
		"subtypes": ["Code Gate", "Liability"],
		"text": "As an additional cost to rez this ice, take 1 bad publicity or remove 1 tag.\n[subroutine] Gain 2[credit].\n[subroutine] The Runner loses 2[credit].\n[subroutine] End the run if you have more credits than the Runner."
	}, {
		"additional-cost": [NRPayment.to_c("tag-or-bad-pub")],
		"subroutines": [
			_gain_credits_sub(2),
			_runner_loses_credits(2),
			NRUtil.merge(_end_the_run(), {"label": "End the run if you have more credits than the Runner", "change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					var corp = state.player("corp")
					return (NRCardRT.getv(corp, "credit") > NRCardRT.getv(runner, "credit")),
			}})
		],
	}))
	NRCardDefs.defcard("Vampyronassa", NRUtil.merge({
		"title": "Vampyronassa",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 7,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "[subroutine] The Runner loses 2[credit].\n[subroutine] Gain 2[credit].\n[subroutine] Do 2 net damage.\n[subroutine] You may draw 1 or 2 cards."
	}, {
		"subroutines": [
			_runner_loses_credits(2),
			_gain_credits_sub(2),
			NRDefHelpers.do_net_damage(2),
			_draw_up_to_sub(
				2,
				{
					"allow-zero-draws": true,
				}
			)
		],
	}))
	NRCardDefs.defcard("Vanilla", NRUtil.merge({
		"title": "Vanilla",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Vasilisa", NRUtil.merge({
		"title": "Vasilisa",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Sentry - Observer",
		"subtypes": ["Sentry", "Observer"],
		"text": "When the Runner encounters this ice, you may pay 1[credit]. If you do, place 1 advancement counter on an installed card you can advance.\n[subroutine] Give the Runner 1 tag."
	}, {
		"on-encounter": NRUtil.merge(place_advancement_counter(true), {"cost": [NRPayment.to_c("credit", 1)]}),
		"subroutines": [NRDefHelpers.give_tags(1)],
	}))
	NRCardDefs.defcard("Veritas", NRUtil.merge({
		"title": "Veritas",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] The Corp gains 2[credit].\n[subroutine] The Runner loses 2[credit].\n[subroutine] Trace[2]. If successful, give the Runner 1 tag."
	}, {
		"subroutines": [_gain_credits_sub(2), _runner_loses_credits(2), _trace_ability(2, NRDefHelpers.give_tags(1))],
	}))
	NRCardDefs.defcard("Vertigo", NRUtil.merge({
		"title": "Vertigo",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "When the Runner passes this ice, if they have no [click] remaining, they cannot steal or trash Corp cards for the remainder of this run.\n[subroutine] The Runner loses [click]."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), card),
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.zero(NRCardRT.getv(runner, "click")),
				},
				"msg": "prevent the Runner from stealing or trashing Corp cards for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					NRFlags.register_run_flag(
						state,
						side,
						card,
						"can-steal",
						func(state, _side, _card):
							return (func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "runner", "Cannot steal due to Vertigo.", "warning"))
					)
					return NRFlags.register_run_flag(
						state,
						side,
						card,
						"can-trash",
						func(state, _side, card):
							return (func(_a=null, _b=null, _c=null, _d=null, _e=null): return (not NRCardRT.truthy(NRCard.corp(card))))(NRToasts.toast(state, "runner", "Cannot trash due to Vertigo.", "warning"))
					),
			}
		],
		"subroutines": [_runner_loses_click()],
	}))
	NRCardDefs.defcard("Vicsek", NRUtil.merge({
		"title": "Vicsek",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Trap - AP - Observer",
		"subtypes": ["Trap", "AP", "Observer"],
		"text": "[subroutine] Do X net damage and give the Runner X tags. X is equal to the number of tags the Runner has.\n[subroutine] Give the Runner 1 tag. Trash this ice."
	}, {
		"subroutines": [
			{
				"label": "Do X damage and give the Runner X tags.",
				"async": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return tagged,
				},
				"effect": func(state, side, eid, card, targets):
					return (func():
						var x = count_tags(state)
						return NREid.wait_for(state, eid, func(ne):
							NRTags.gain_tags(state, "side", ne, x, {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRDamage.damage(state, side, eid, "net", x))
					).call(),
			},
			{
				"label": "Give the Runner 1 tag. Trash this ice.",
				"async": true,
				"msg": func(state, side, eid, card, targets):
					return str("give the runner 1 tag"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRTags.gain_tags(state, side, ne, 1)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, side, ne, card, {
								"cause": "subroutine",
							})
						, func(async_result):
							NRRuns.encounter_ends(state, side, eid))),
			}
		],
	}))
	NRCardDefs.defcard("Vikram 1.0", NRUtil.merge({
		"title": "Vikram 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Bioroid - Tracer - AP",
		"subtypes": ["Sentry", "Bioroid", "Tracer", "AP"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner cannot use programs for the remainder of this run.\n[subroutine] Trace[4]. If successful, do 1 core damage.\n[subroutine] Trace[4]. If successful, do 1 core damage."
	}, {
		"implementation": "Program prevention is not implemented",
		"subroutines": [
			{
				"msg": "prevent the Runner from using programs for the remainder of this run",
			},
			_trace_ability(4, NRDefHelpers.do_brain_damage(1)),
			_trace_ability(4, NRDefHelpers.do_brain_damage(1))
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Viktor 1.0", NRUtil.merge({
		"title": "Viktor 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 2,
		"keywords": "Code Gate - Bioroid - AP",
		"subtypes": ["Code Gate", "Bioroid", "AP"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] End the run."
	}, {
		"subroutines": [NRDefHelpers.do_brain_damage(1), _end_the_run()],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Viktor 2.0", NRUtil.merge({
		"title": "Viktor 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 3,
		"keywords": "Code Gate - Bioroid - Tracer - AP",
		"subtypes": ["Code Gate", "Bioroid", "Tracer", "AP"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n<strong>Hosted power counter:</strong> Do 1 core damage.\n[subroutine] Trace[2]. If successful, place 1 power counter on this ice.\n[subroutine] End the run."
	}, {
		"abilities": [_power_counter_ability(NRDefHelpers.do_brain_damage(1))],
		"subroutines": [_trace_ability(2, _gain_power_counter()), _end_the_run()],
		"runner-abilities": [_bioroid_break(2, 2)],
	}))
	NRCardDefs.defcard("Viper", NRUtil.merge({
		"title": "Viper",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"strength": 4,
		"factioncost": 1,
		"keywords": "Code Gate - Tracer",
		"subtypes": ["Code Gate", "Tracer"],
		"text": "[subroutine] Trace[3]. If successful, the Runner loses [click], if able.\n[subroutine] Trace[3]. If successful, end the run."
	}, {
		"subroutines": [_trace_ability(3, _runner_loses_click()), _trace_ability(3, _end_the_run())],
	}))
	NRCardDefs.defcard("Virgo", NRUtil.merge({
		"title": "Virgo",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Sentry - Tracer",
		"subtypes": ["Sentry", "Tracer"],
		"text": "[subroutine] Trace[2]. If successful, give the Runner 1 tag. If your trace strength is 5 or greater, give the Runner 1 tag."
	}, _constellation_ice(NRDefHelpers.give_tags(1))))
	NRCardDefs.defcard("Virtual Service Agent", NRUtil.merge({
		"title": "Virtual Service Agent",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 2,
		"factioncost": 2,
		"keywords": "Code Gate - Observer",
		"subtypes": ["Code Gate", "Observer"],
		"text": "Whenever the Runner passes this ice after encountering it, if they did not break its printed subroutine with a <strong>decoder</strong> during that encounter, give them 1 tag.\n[subroutine] The Runner loses 1[credit]."
	}, {
		"subroutines": [_runner_loses_credits(1)],
		"implementation": "Might be incorrect if decoder is uninstalled",
		"events": [
			{
				"event": "end-of-encounter",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (func():
						var printed_sub = NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(card, "subroutines"), func(x): return NRCardRT.getv(x, "printed")), 0)
						return (NRUtil.same_card(card, NRCardRT.getv(context, "ice")) and ((not NRCardRT.truthy(NRCardRT.getv(printed_sub, "broken"))) or (not NRCardRT.truthy(NRCardRT.as_array(NRCardRT.distinct_list(NRCardRT.getv(printed_sub, "breaker-subtypes"))).has("Decoder")))))
					).call(),
				"msg": "give the Runner 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, side, eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Waiver", NRUtil.merge({
		"title": "Waiver",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"strength": 5,
		"factioncost": 2,
		"keywords": "Code Gate - Tracer",
		"subtypes": ["Code Gate", "Tracer"],
		"text": "[subroutine] Trace[5]. If successful, the Runner reveals the grip. Trash each card revealed this way with a play or install cost of X or less. X is equal to the amount by which your trace strength exceeded the Runner's link strength."
	}, {
		"subroutines": [
			_trace_ability(
				5,
				{
					"label": "Reveal the grip and trash cards",
					"msg": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return str("reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.getv(runner, "hand"), "sorted")) + str(" from the grip"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var runner = state.player("runner")
						return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, NRCardRT.getv(runner, "hand"))
						, func(async_result):
							(func():
								var delta = (target - NRCardRT.getv(targets, 1))
								var cards = NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
									return (NRCardRT.getv(_pct, "cost") <= delta))
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash ") + str(NRCardRT.enumerate_cards(cards)))
								return NRMoving.trash_cards(
									state,
									side,
									eid,
									cards,
									{
										"cause": "subroutine",
									}
								)
							).call()),
				}
			)
		],
	}))
	NRCardDefs.defcard("Wall of Static", NRUtil.merge({
		"title": "Wall of Static",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 0,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
	}))
	NRCardDefs.defcard("Wall of Thorns", NRUtil.merge({
		"title": "Wall of Thorns",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 8,
		"strength": 5,
		"factioncost": 1,
		"keywords": "Barrier - AP",
		"subtypes": ["Barrier", "AP"],
		"text": "[subroutine] Do 2 net damage.\n[subroutine] End the run."
	}, {
		"subroutines": [NRDefHelpers.do_net_damage(2), _end_the_run()],
	}))
	NRCardDefs.defcard("Watchtower", NRUtil.merge({
		"title": "Watchtower",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 3,
		"factioncost": 3,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] Search R&D for a card and add it to HQ. Shuffle R&D."
	}, {
		"subroutines": [
			{
				"label": "Search R&D and add 1 card to HQ",
				"prompt": "Choose a card to add to HQ",
				"msg": "add a card from R&D to HQ",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.as_array(NRCardRT.getv(corp, "deck")),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRShuffling.shuffle_zone(state, side, "deck")
					return NRMoving.move(state, side, target, "hand"),
			}
		],
	}))
	NRCardDefs.defcard("Wave", NRUtil.merge({
		"title": "Wave",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 3,
		"factioncost": 1,
		"keywords": "Code Gate - Harmonic",
		"subtypes": ["Code Gate", "Harmonic"],
		"text": "When you rez this ice during a run against this server, you may search R&D for a piece of ice and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that ice to HQ.\n[subroutine] Gain 1[credit] for each rezzed piece of <strong>harmonic</strong> ice."
	}, {
		"on-rez": {
			"optional": {
				"prompt": "Search R&D for a piece of ice?",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var this_server = NRCardRT.this_server(state, card)
					return run and this_server,
				"yes-ability": {
					"prompt": "Choose a piece of ice",
					"async": true,
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to HQ"),
					"choices": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
							return NRCard.ice(_pct)))),
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
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
		"rez-sound": "wave",
		"subroutines": [
			{
				"label": str("Gain 1 [Credits] for each rezzed piece of Harmonic ice"),
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str("gain ") + str(_harmonic_ice_count(corp)) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRGaining.gain_credits(state, "corp", eid, _harmonic_ice_count(corp)),
			}
		],
	}))
	NRCardDefs.defcard("Weir", NRUtil.merge({
		"title": "Weir",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"strength": 3,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner loses [click].\n[subroutine] The Runner trashes 1 card from their grip."
	}, {
		"subroutines": [
			_runner_loses_click(),
			{
				"label": "Runner trashes 1 card from the grip",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
					"silent": true,
				},
				"prompt": "Choose a card to trash",
				"player": "runner",
				"choices": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.getv(runner, "hand"),
				"not-distinct": true,
				"display-side": "corp",
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("force the Runner to trash ") + str(NRCardRT.getv(target, "title")) + str(" from [their] grip"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.trash(
						state,
						"runner",
						eid,
						target,
						{
							"cause": "subroutine",
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Wendigo", NRUtil.merge({
		"title": "Wendigo",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"strength": 4,
		"factioncost": 2,
		"keywords": "Code Gate - Morph",
		"subtypes": ["Code Gate", "Morph"],
		"text": "Wendigo can be advanced.\nWhile Wendigo has an odd number of advancement tokens on it, it gains <strong>barrier</strong> and loses <strong>code gate</strong>.\n[subroutine] Choose a program. The Runner cannot use the chosen program for the remainder of this run."
	}, _implementation_note(
		"Program prevention is not implemented",
		_morph_ice(
			"Code Gate",
			"Barrier",
			{
				"msg": "prevent the Runner from using a chosen program for the remainder of this run",
			}
		)
	)))
	NRCardDefs.defcard("Whirlpool", NRUtil.merge({
		"title": "Whirlpool",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Trap",
		"subtypes": ["Trap"],
		"text": "[subroutine] The Runner cannot jack out for the remainder of this run. Trash Whirlpool."
	}, {
		"subroutines": [
			{
				"label": "The Runner cannot jack out for the remainder of this run",
				"msg": "prevent the Runner from jacking out and trash itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "cannot-jack-out",
							"value": true,
							"duration": "end-of-run",
						}
					)
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, "corp", ne, card, {
							"cause": "subroutine",
						})
					, func(async_result):
						NRRuns.encounter_ends(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Whitespace", NRUtil.merge({
		"title": "Whitespace",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 0,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "[subroutine] The Runner loses 3[credit].\n[subroutine] If the Runner has 6[credit] or less, end the run."
	}, {
		"subroutines": [
			_runner_loses_credits(3),
			{
				"label": "End the run if the Runner has 6 [Credits] or less",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return (NRCardRT.getv(runner, "credit") < 7),
					"silent": true,
				},
				"msg": "end the run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, "corp", eid, card),
			}
		],
	}))
	NRCardDefs.defcard("Winchester", NRUtil.merge({
		"title": "Winchester",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 4,
		"factioncost": 4,
		"keywords": "Sentry - Destroyer - Tracer",
		"subtypes": ["Sentry", "Destroyer", "Tracer"],
		"text": "[subroutine] Trace[4]. If successful, trash 1 installed program.\n[subroutine] Trace[3]. If successful, trash 1 installed piece of hardware.\nWhile this ice is protecting HQ, it gains “[subroutine] Trace[3]. If successful, end the run.” after its other subroutines."
	}, {
		"subroutines": [_trace_ability(4, _trash_program_sub()), _trace_ability(3, _trash_hardware_sub())],
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and NRCard.protecting_hq(card),
				"value": {
					"subroutines": [_trace_ability(3, _end_the_run())],
				},
			}
		],
	}))
	NRCardDefs.defcard("Woodcutter", NRUtil.merge({
		"title": "Woodcutter",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"strength": 2,
		"factioncost": 3,
		"keywords": "Sentry - AP",
		"subtypes": ["Sentry", "AP"],
		"text": "You can advance this ice if it is rezzed. It gains \"[subroutine] Do 1 net damage.\" for each hosted advancement counter."
	}, _zero_to_hero(NRDefHelpers.do_net_damage(1))))
	NRCardDefs.defcard("Wormhole", NRUtil.merge({
		"title": "Wormhole",
		"type": "ICE",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 9,
		"strength": 7,
		"factioncost": 2,
		"keywords": "Code Gate",
		"subtypes": ["Code Gate"],
		"text": "Wormhole can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] Resolve a subroutine on another piece of rezzed ice."
	}, _space_ice(_resolve_another_subroutine())))
	NRCardDefs.defcard("Wotan", NRUtil.merge({
		"title": "Wotan",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"cost": 14,
		"strength": 10,
		"factioncost": 5,
		"keywords": "Barrier - Bioroid",
		"subtypes": ["Barrier", "Bioroid"],
		"text": "[subroutine] End the run unless the Runner spends [click][click].\n[subroutine] End the run unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner trashes 1 installed program.\n[subroutine] End the run unless the Runner suffers 1 core damage."
	}, {
		"subroutines": [
			_end_the_run_unless_runner_pays(NRPayment.to_c("click", 2)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("credit", 3)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("program", 1)),
			_end_the_run_unless_runner_pays(NRPayment.to_c("brain", 1))
		],
	}))
	NRCardDefs.defcard("Wraparound", NRUtil.merge({
		"title": "Wraparound",
		"type": "ICE",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"strength": 0,
		"factioncost": 1,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"text": "While there are no installed <strong>fracter</strong> programs, this ice gets +7 strength.\n[subroutine] End the run."
	}, {
		"subroutines": [_end_the_run()],
		"static-abilities": [
			NRCardRT.ice_strength_bonus(7, func(state, side, eid, card, targets):
				return (not NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
					return NRCard.has_subtype(_pct, "Fracter"))))
		],
	}))
	NRCardDefs.defcard("Yagura", NRUtil.merge({
		"title": "Yagura",
		"type": "ICE",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"strength": 0,
		"factioncost": 2,
		"keywords": "Code Gate - AP",
		"subtypes": ["Code Gate", "AP"],
		"text": "[subroutine] Look at the top card of R&D. You may add that card to the bottom of R&D.\n[subroutine] Do 1 net damage."
	}, {
		"subroutines": [
			{
				"label": "Look at the top card of R&D",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"optional": {
					"prompt": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return str("Move ") + str(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "title")) + str(" to the bottom of R&D?"),
					"yes-ability": {
						"msg": "move the top card of R&D to the bottom",
						"effect": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRMoving.move(state, side, NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "deck"),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title")) + str(" to move the top card of R&D to the bottom")),
					},
				},
			},
			NRDefHelpers.do_net_damage(1)
		],
	}))
	NRCardDefs.defcard("Zed 1.0", NRUtil.merge({
		"title": "Zed 1.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"strength": 1,
		"factioncost": 2,
		"keywords": "Sentry - Bioroid - AP",
		"subtypes": ["Sentry", "Bioroid", "AP"],
		"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] If the Runner has lost [click] to break a subroutine during this run, do 1 core damage.\n[subroutine] If the Runner has lost [click] to break a subroutine during this run, do 1 core damage."
	}, {
		"subroutines": [
			{
				"label": "Do 1 core damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (NREngine.resolve_ability(state, side, eid, NRDefHelpers.do_brain_damage(1), card, null) if _spent_click_to_break_sub(state, run) else (func():
						NRSay.system_msg(state, side, "does not do core damage with Zed 1.0")
						return NREid.effect_completed(state, side, eid)
					).call()),
			},
			{
				"label": "Do 1 core damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (NREngine.resolve_ability(state, side, eid, NRDefHelpers.do_brain_damage(1), card, null) if _spent_click_to_break_sub(state, run) else (func():
						NRSay.system_msg(state, side, "does not do core damage with Zed 1.0")
						return NREid.effect_completed(state, side, eid)
					).call()),
			}
		],
		"runner-abilities": [_bioroid_break(1, 1)],
	}))
	NRCardDefs.defcard("Zed 2.0", NRUtil.merge({
		"title": "Zed 2.0",
		"type": "ICE",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"strength": 4,
		"factioncost": 3,
		"keywords": "Sentry - Bioroid - AP - Destroyer",
		"subtypes": ["Sentry", "Bioroid", "AP", "Destroyer"],
		"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed piece of hardware.\n[subroutine] Trash 1 installed piece of hardware.\n[subroutine] If the Runner has lost [click] to break a subroutine during this run, do 2 core damage."
	}, {
		"subroutines": [
			_trash_hardware_sub(),
			_trash_hardware_sub(),
			{
				"label": "Do 1 core damage",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return (NREngine.resolve_ability(state, side, eid, NRDefHelpers.do_brain_damage(2), card, null) if _spent_click_to_break_sub(state, run) else (func():
						NRSay.system_msg(state, side, "does not do core damage with Zed 2.0")
						return NREid.effect_completed(state, side, eid)
					).call()),
			}
		],
		"runner-abilities": [_bioroid_break(2, 2)],
	}))

static func _all_subroutines_not_broken_by(state = null, side = null, card = null, type_ = null, context = null):
	return (func():
		var ice = NRCardRT.getv(context, "ice")
		var subs = NRCardRT.getv(ice, "subroutines")
		return (((ice == card) or NRUtil.kw_eq(ice, card)) and NRCardRT.some_list(subs, func(_pct):
			return (NRCardRT.getv(_pct, "printed") and ((not NRCardRT.truthy(NRCardRT.getv(_pct, "broken"))) or (not NRCardRT.truthy(NRCard.has_subtype(NRFinding.find_cid(NRCardRT.getv(_pct, "breaker"), NRBoard.all_installed(state, "runner")), type_)))))))
	).call()

static func _forced_to_avoid_tags(state, side):
	return NREffects.any_effects(state, side, "forced-to-avoid-tag")

static func _currently_encountering_card(card, state):
	return NRUtil.same_card(NRCardRT.getv(NRRuns.get_current_encounter(state), "ice"), card)

static func _bioroid_break(cost = null, qty = null, args = null):
	return {
		"async": true,
		"break": qty,
		"break-cost": [NRPayment.to_c("lose-click", cost)],
		"label": "Break subroutine",
		"req": func(state, side, eid, card, targets):
			return NRCardRT.currently_encountering(state, card),
	}

static func _end_the_run():
	return {
		"label": "End the run",
		"msg": "end the run",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRRuns.end_run(state, "corp", eid, card),
	}

static func _end_the_run_if_tagged():
	return {
		"label": "End the run if the Runner is tagged",
		"change-in-game-state": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"silent": true,
		},
		"msg": "end the run",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRRuns.end_run(state, "corp", eid, card),
	}

static func _faceup_archives_types(corp):
	return NRCardRT.count_of(NRCardRT.distinct_list(NRCardRT.map_list(NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), NRCard.faceup), func(x): return NRCardRT.getv(x, "type"))))

static func _maybe_draw_sub(qty):
	return {
		"async": true,
		"label": str("You may draw ") + str(NRCardRT.quantify(qty, "card")),
		"effect": func(state, side, eid, card, targets):
			return NRDrawing.maybe_draw(state, side, eid, card, qty),
	}

static func _draw_up_to_sub(qty = null, args = null):
	return {
		"async": true,
		"label": str("Draw up to ") + str(NRCardRT.quantify(qty, "card")),
		"effect": func(state, side, eid, card, targets):
			return NRDrawing.draw_up_to(state, side, eid, card, qty, args),
	}

static func _runner_pays(cost):
	return {
		"display-side": "runner",
		"cost": cost,
		"msg": "cost",
	}

static func _end_the_run_unless_runner_pays(cost = null, reason = null):
	return {
		"player": "runner",
		"async": true,
		"label": str("End the run unless the Runner pays ") + str(NRPayment.build_cost_label(cost)),
		"prompt": "Choose one",
		"waiting-prompt": true,
		"choices": func(state, side, eid, card, targets):
			return [
				"End the run",
				(str(NRPayment.cost_to_string(cost)) if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, cost)) else null)
			],
		"msg": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str((NRCardRT.decapitalize(target) if (("End the run" == target) or NRUtil.kw_eq("End the run", target)) else str("force the runner to ") + str(NRCardRT.decapitalize(target)))),
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			var async_result = NREid.result_of(eid)
			return (NRRuns.end_run(state, "corp", eid, card) if (("End the run" == target) or NRUtil.kw_eq("End the run", target)) else NREid.wait_for(state, eid, func(ne):
				NREngine.pay(state, "runner", ne, card, cost)
			, func(async_result):
				(func():
					var payment_str = NRCardRT.getv(async_result, "msg")
					return NRSay.system_msg(state, "runner", str(payment_str) + str(" due to ") + str(NRCardRT.getv(card, "title")) + str(" ") + str(reason)) if payment_str != null and NRCardRT.truthy(payment_str) else null
				).call()
				NREid.effect_completed(state, side, eid))),
	}

static func _end_the_run_unless_corp_pays(cost):
	return {
		"async": true,
		"label": str("End the run unless the Corp pays ") + str(NRPayment.build_cost_label(cost)),
		"prompt": "Choose one",
		"waiting-prompt": true,
		"choices": func(state, side, eid, card, targets):
			return [
				"End the run",
				(str(NRPayment.cost_to_string(cost)) if NRCardRT.truthy(NRPayment.can_pay(state, "corp", eid, card, null, cost)) else null)
			],
		"msg": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str(NRCardRT.decapitalize(target)),
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			var async_result = NREid.result_of(eid)
			return (NRRuns.end_run(state, "corp", eid, card) if (("End the run" == target) or NRUtil.kw_eq("End the run", target)) else NREid.wait_for(state, eid, func(ne):
				NREngine.pay(state, "corp", ne, card, cost)
			, func(async_result):
				(func():
					var payment_str = NRCardRT.getv(async_result, "msg")
					return NRSay.system_msg(state, "corp", payment_str) if payment_str != null and NRCardRT.truthy(payment_str) else null
				).call()
				NREid.effect_completed(state, side, eid))),
	}

static func _end_the_run_unless_runner(label, prompt, ability):
	return {
		"player": "runner",
		"async": true,
		"label": str("End the run unless the Runner ") + str(label),
		"prompt": "Choose one",
		"waiting-prompt": true,
		"choices": ["End the run", str(prompt)],
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return ((func():
				NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to end the run"))
				return NRRuns.end_run(state, "corp", eid, card)
			).call() if (("End the run" == target) or NRUtil.kw_eq("End the run", target)) else NREngine.resolve_ability(state, side, eid, ability, card, null)),
	}

static func _gain_power_counter():
	return {
		"label": "Place 1 power counter",
		"msg": "place 1 power counter on itself",
		"change-in-game-state": {
			"silent": true,
			"req": func(state, side, eid, card, targets):
				return NRCard.installed(card),
		},
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

static func _rez_an_ice(_p_1 = null):
	return (func():
		var tag_str = str("Rez an ice") + str((null if NRCardRT.truthy(((not NRCardRT.truthy(cost_bonus)) or NRCardRT.zero(cost_bonus))) else (str(", paying ") + str(cost_bonus) + str(" more") if NRCardRT.truthy(NRCardRT.pos(cost_bonus)) else str(", paying ") + str((-cost_bonus)) + str(" less"))))
		return {
			"label": tag_str,
			"prompt": tag_str,
			"async": true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct))))),
			},
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target) and NRCard.ice(target) and (not NRCardRT.truthy(NRCard.rezzed(target))) and NRRezzing.can_pay_to_rez(state, side, eid, target, args),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRRezzing.rez(state, side, eid, target, args),
		}
	).call()

static func _trace_ability(base = null, ability = null, un_ability = null):
	return (func():
		var label = str(NRCardRT.getv(ability, "label")) + str(" / ") + str(NRCardRT.getv(un_ability, "label"))
		return {
			"label": str("Trace ") + str(base) + str(" - ") + str(label),
			"trace": {
				"base": base,
				"label": label,
				"successful": ability,
				"unsuccessful": un_ability,
			},
		}
	).call()

static func _tag_trace(base = null, n = null):
	return _trace_ability(base, NRDefHelpers.give_tags(n))

static func _tag_or_pay_credits(x):
	return {
		"label": str("Give the Runner 1 tag unless they pay ") + str(x) + str(" [Credits]"),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NREngine.resolve_ability(state, side, eid, (NRCardRT.choose_one_helper(
				{
					"player": "runner",
				},
				[
					{
						"option": "Take 1 tag",
						"ability": NRDefHelpers.give_tags(1),
					},
					NRCardRT.cost_option([NRPayment.to_c("credit", x)], "runner")
				]
			) if NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", x)]) else {
				"msg": "give the Runner 1 tag",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, side, eid, 1),
				"async": true,
			}), card, null),
	}

static func _gain_credits_sub(credits):
	return {
		"label": str("Gain ") + str(credits) + str(" [Credits]"),
		"msg": str("gain ") + str(credits) + str(" [Credits]"),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRGaining.gain_credits(state, side, eid, credits),
	}

static func _corps_gains_and_runner_loses_credits(gain, loss):
	return {
		"label": str("Gain ") + str(NRGaining.gain) + str(" [Credits], Runner loses ") + str(loss) + str(" [Credits]"),
		"msg": str("gain ") + str(NRGaining.gain) + str(" [Credits] and force the Runner to lose ") + str(loss) + str(" [Credits]"),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, "corp", ne, NRGaining.gain)
			, func(async_result):
				NRGaining.lose_credits(state, "runner", eid, loss)),
	}

static func _power_counter_ability(ability):
	return NRUtil.merge(ability, {"cost": [NRPayment.to_c("power", 1)]})

static func _do_psi(_p_2 = null, _p_3 = null):
	return {
		"label": str("Psi Game - ") + str(label_neq) + str(" / ") + str(label_eq),
		"msg": str("start a psi game (") + str(label_neq) + str(" / ") + str(label_eq) + str(")"),
		"psi": {
			"not-equal": neq_ability,
			"equal": eq_ability,
		},
	}

static func _runner_loses_credits(credits):
	return {
		"label": str("Make the Runner lose ") + str(credits) + str(" [Credits]"),
		"msg": str("force the Runner to lose ") + str(credits) + str(" [Credits]"),
		"change-in-game-state": {
			"silent": true,
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRCardRT.pos(NRCardRT.getv(runner, "credit")),
		},
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NRGaining.lose_credits(state, "runner", eid, credits),
	}

static func _add_runner_card_to_grip():
	return {
		"label": "Add an installed Runner card to the grip",
		"change-in-game-state": {
			"silent": true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.seq_of(NRBoard.all_installed(state, "runner")),
		},
		"waiting-prompt": true,
		"prompt": "Choose a card",
		"choices": {
			"card": func(_pct):
				return (NRCard.installed(_pct) and NRCard.runner(_pct)),
		},
		"msg": "add 1 installed card to the grip",
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			NRMoving.move(state, "runner", target, "hand", true)
			return NRSay.system_msg(state, side, str("adds ") + str(NRCardRT.getv(target, "title")) + str(" to the grip")),
	}

static func _install_from_hq_sub(args = null):
	return {
		"label": "Install a card from HQ",
		"prompt": "Choose a card to install from HQ",
		"waiting-prompt": true,
		"choices": {
			"card": func(_pct):
				return (NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
		},
		"async": true,
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRInstalling.corp_install(
				state,
				side,
				eid,
				target,
				null,
				NRUtil.merge(args, {"msg-keys": {
					"install-source": card,
				}})
			),
	}

static func _install_from_archives_sub(args = null):
	return {
		"label": "Install a card from Archives",
		"prompt": "Choose a card to install from Archives",
		"show-discard": true,
		"waiting-prompt": true,
		"choices": {
			"card": func(_pct):
				return (NRCard.corp_installable_type(_pct) and NRCard.in_discard(_pct)),
		},
		"async": true,
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRInstalling.corp_install(
				state,
				side,
				eid,
				target,
				null,
				NRUtil.merge(args, {"msg-keys": {
					"install-source": card,
					"display-origin": true,
				}})
			),
	}

static func _install_from_hq_or_archives_sub(args = null):
	return {
		"label": "Install a card from HQ or Archives",
		"prompt": "Choose a card to install from HQ or Archives",
		"show-discard": true,
		"waiting-prompt": true,
		"choices": {
			"card": func(_pct):
				return (NRCard.corp_installable_type(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
		},
		"async": true,
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRInstalling.corp_install(
				state,
				side,
				eid,
				target,
				null,
				NRUtil.merge(args, {"msg-keys": {
					"install-source": card,
					"display-origin": true,
				}})
			),
	}

static func _wall_ice(subroutines):
	return {
		"advanceable": "always",
		"subroutines": subroutines,
		"static-abilities": [
			NRCardRT.ice_strength_bonus(func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "advancement"))
		],
	}

static func _space_ice(_, abilities):
	return {
		"advanceable": "always",
		"subroutines": NRCardRT.as_array(abilities),
		"rez-cost-bonus": func(state, side, eid, card, targets):
			return (-3 * NRCard.get_counters(card, "advancement")),
	}

static func _spent_click_to_break_sub(state, run):
	return (func():
		var all_cards = NRBoard.get_all_cards(state)
		var events = NREvents.run_events(state, "runner", "subroutines-broken")
		var breakers = NRCardRT.map_list(events, func(_pct):
			return (func():
				var context = NRCardRT.getv(_pct, 0)
				return NRCardRT.getv(context, "breaker")
		).call())
		var actual_breakers = NRCardRT.map_list(breakers, func(_pct):
			return NRFinding.find_cid(NRCardRT.getv(_pct, "cid"), all_cards))
		var abs = NRCardRT.concat_lists(NRCardRT.map_list(actual_breakers, func(_pct):
			return (NRCardRT.getv(_pct, "abilities") if ((NRCardRT.getv(_pct, "side") == "Runner") or NRUtil.kw_eq(NRCardRT.getv(_pct, "side"), "Runner")) else NRCardRT.getv(_pct, "runner-abilities"))))
		var costs = NRCardRT.map_list(abs, func(x): return NRCardRT.getv(x, "break-cost"))
		var clicks = NRCardRT.filter_list(NRCardRT.concat_lists(NRCardRT.as_array(costs)), func(_pct):
			return (("lose-click" == NRCardRT.getv(_pct, "cost/type")) or NRUtil.kw_eq("lose-click", NRCardRT.getv(_pct, "cost/type"))))
		return NRCardRT.seq_of(clicks)
	).call()

static func _grail_in_hand(card):
	return (NRCard.corp(card) and NRCard.in_hand(card) and NRCard.has_subtype(card, "Grail"))

static func _add_grail_subs(cards):
	return ((func():
		var t = NRCardRT.getv(cards, 0)
		var s = NRCardRT.getv(NRCardDefs.card_def(t), "subroutines")
		return {
			"prompt": str("Add ") + str(NRCardRT.getv(NRCardRT.getv(s, 0), "label")) + str(" subroutine where?"),
			"choices": ["Front", "End"],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var is_front = ("front" if NRCardRT.truthy(((target == "Front") or NRUtil.kw_eq(target, "Front"))) else null)
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "additional-subroutines",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRUtil.same_card(card, target),
							"value": {
								"position": is_front,
								"subroutines": NRCardRT.as_array(s),
							},
						}
					)
					return NREngine.resolve_ability(state, side, eid, _add_grail_subs(NRCardRT.drop_n(cards, 1)), card, null)
				).call(),
		}
	).call() if NRCardRT.truthy(NRCardRT.seq_of(cards)) else null)

static func _grail_ice(ability):
	return {
		"on-encounter": _reveal_grail(),
		"subroutines": [ability],
	}

static func _trash_type_or_end_the_run(type_name, type_fn, sub):
	return {
		"label": str("Trash 1 ") + str(type_name) + str(" or end the run"),
		"prompt": "Choose one",
		"waiting-prompt": true,
		"choices": func(state, side, eid, card, targets):
			return [
				("Do nothing" if NRCardRT.empty_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(x): return NRCardRT.truthy(type_fn.call(x) if type_fn is Callable else type_fn))) else str("Trash a ") + str(type_name)),
				"End the run"
			],
		"async": true,
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NREngine.resolve_ability(state, side, eid, (_end_the_run() if NRCardRT.truthy(((target == "End the run") or NRUtil.kw_eq(target, "End the run"))) else (null if NRCardRT.truthy(((target == "Do nothing") or NRUtil.kw_eq(target, "Do nothing"))) else sub)), card, null),
	}

static func _variable_subs_ice(subs_count, sub):
	return {
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target),
				"value": func(state, side, eid, card, targets):
					return {
						"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(sub, int(subs_count(state)))),
					},
			}
		],
	}

static func _subtype_ice_count(corp, subtype):
	return NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.concat_lists(NRCardRT.map_list((NRCardRT.getv(corp, "servers") as Dictionary).values(), func(x): return NRCardRT.getv(x, "ices"))), func(_pct):
		return (NRCard.rezzed(_pct) and NRCard.has_subtype(_pct, subtype))))

static func _next_ice_count(corp):
	return _subtype_ice_count(corp, "NEXT")

static func _next_ice_variable_subs(sub):
	return _variable_subs_ice(
		func(state):
			return _next_ice_count(NRCardRT.getv(state.data, "corp")),
		sub
	)

static func _harmonic_ice_count(corp):
	return _subtype_ice_count(corp, "Harmonic")

static func _morph_ice(base, other, ability):
	return {
		"advanceable": "always",
		"static-abilities": [
			{
				"type": "lose-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and (int(NRCard.get_counters(NRCard.get_card(state, card), "advancement")) % 2 == 1),
				"value": base,
			},
			{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and (int(NRCard.get_counters(NRCard.get_card(state, card), "advancement")) % 2 == 1),
				"value": other,
			}
		],
		"subroutines": [ability],
	}

static func _constellation_ice(ability):
	return {
		"subroutines": [
			NRUtil.assoc_in(NRUtil.assoc_in(_trace_ability(2, ability), ["trace", "kicker"], ability), ["trace", "kicker-min"], 5)
		],
	}

static func _zero_to_hero(sub):
	return {
		"advanceable": "while-rezzed",
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and NRCardRT.pos(NRCard.get_counters(card, "advancement")),
				"value": func(state, side, eid, card, targets):
					return {
						"position": "front",
						"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(sub, int(NRCard.get_counters(card, "advancement")))),
					},
			}
		],
	}

static func _hero_to_hero(sub):
	return {
		"advanceable": "always",
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(card, target) and NRCardRT.pos(NRCard.get_counters(card, "advancement")),
				"value": func(state, side, eid, card, targets):
					return {
						"position": "front",
						"subroutines": NRCardRT.as_array(NRCardRT.repeat_n(sub, int(NRCard.get_counters(card, "advancement")))),
					},
			}
		],
	}

static func _wonder_sub(card, number):
	return (number <= NRCard.get_counters(card, "advancement"))

static func _resolve_another_subroutine(pred = null, label = null, allow_same_card = null):
	return (func():
		var pred = func(card, target):
			return (NRCard.ice(target) and NRCard.rezzed(target) and (NRCardRT.count_of(NRCardRT.getv(target, "subroutines")) >= 1) and (allow_same_card or (not NRCardRT.truthy(NRUtil.same_card(card, target)))) and pred(target))
		return {
			"async": true,
			"label": label,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return pred(card, _pct)),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, {
					"async": true,
					"prompt": label,
					"choices": {
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return pred(card, target),
						"all": true,
					},
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, (func():
							var ice = target
							return {
								"async": true,
								"prompt": "Choose the subroutine",
								"choices": func(state, side, eid, card, targets):
									return NRIce.unbroken_subroutines_choice(ice),
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("resolve the subroutine (\"[subroutine] ") + str(target) + str("\") from ") + str(NRCardRT.getv(ice, "title")),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return (func():
										var sub = NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(ice, "subroutines"), func(_pct):
											return ((target == NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))) or NRUtil.kw_eq(target, NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))))), 0)
										return NREngine.resolve_ability(state, side, eid, NRCardRT.getv(sub, "sub-effect"), ice, null)
									).call(),
							}
						).call(), card, null),
				}, card, null),
		}
	).call()

static func _implementation_note(note, ice_def):
	return NRUtil.merge(ice_def, {"implementation": note})

static func _encounter_ab_4():
	return {
	"optional": {
		"prompt": "Trash another card?",
		"waiting-prompt": true,
		"req": func(state, side, eid, card, targets):
			return NRPayment.can_pay(state, side, NRUtil.merge(eid, {"source": card, "source-type": "ability"}), card, null, [NRPayment.to_c("trash-other-installed", 1)]),
		"yes-ability": {
			"prompt": "Select another installed card to trash",
			"cost": [NRPayment.to_c("trash-other-installed", 1)],
			"msg": "prevent its printed subroutines being broken this encounter",
			"effect": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "cannot-break-subs-on-ice",
						"req": func(state, side, eid, card, targets):
							var context = NRCardRT.ctx(targets)
							return NRUtil.same_card(card, NRCardRT.getv(context, "ice")),
						"value": true,
						"duration": "end-of-encounter",
					}
				),
		},
	},
}

static func _bailiff_gain_credits_5(state, side, eid, n):
	return (NREid.wait_for(state, eid, func(ne):
		NRGaining.gain_credits(state, "corp", ne, 1)
, func(async_result):
	bailiff_gain_credits(state, side, eid, (int(n) - 1))) if NRCardRT.pos(n) else NREid.effect_completed(state, side, eid))

static func _chiyashi_auto_trash_6(state, side, eid, n):
	return (NREid.wait_for(state, eid, func(ne):
		NRMoving.mill(state, "corp", ne, "runner", 2)
, func(async_result):
	NRSay.system_msg(state, side, "uses Chiyashi to trash the top 2 cards of the Stack")
	chiyashi_auto_trash(state, side, eid, (int(n) - 1))) if NRCardRT.pos(n) else NREid.effect_completed(state, side, eid))

static func _dh_trash_7(cards):
	return {
	"prompt": "Choose a card to trash",
	"choices": cards,
	"async": true,
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str("trash ") + str(NRCardRT.getv(target, "title")),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRMoving.trash(state, side, ne, target, {
				"unpreventable": true,
				"cause": "subroutine",
			})
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, reorder_choice(
				"runner",
				"runner",
				NRCardRT.filter_list(cards, func(x): return not NRCardRT.truthy((func(_pct):
					return ((_pct == target) or NRUtil.kw_eq(_pct, target))).call(x))),
				null,
				NRCardRT.count_of(NRCardRT.filter_list(cards, func(x): return not NRCardRT.truthy((func(_pct):
					return ((_pct == target) or NRUtil.kw_eq(_pct, target))).call(x)))),
				NRCardRT.filter_list(cards, func(x): return not NRCardRT.truthy((func(_pct):
					return ((_pct == target) or NRUtil.kw_eq(_pct, target))).call(x)))
			), card, null)),
}

static func _break_fn_9(unbroken_subs, total):
	return {
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var async_result = NREid.result_of(eid)
		return (NREid.wait_for(state, eid, func(ne):
			NREngine.pay(state, "runner", ne, card, [NRPayment.to_c("credit", 1)])
		, func(async_result):
			NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
			NREngine.resolve_ability(state, side, eid, break_fn(NRCardRT.drop_n(unbroken_subs, 1), (int(total) + 1)), card, null)) if NRCardRT.seq_of(unbroken_subs) else (func():
				var msgs = (str("resolves ") + str(NRCardRT.quantify(total, "unbroken subroutine")) + str(" on Endless EULA") + str(" (\"[subroutine] ") + str(NRCardRT.getv(sub, "label")) + str("\")") if NRCardRT.truthy(NRCardRT.pos(total)) else null)
				(NRSay.system_msg(state, side, msgs) if NRCardRT.truthy(NRCardRT.pos(total)) else null)
				return NREid.effect_completed(state, side, eid)
		).call()),
}

static func _gf_lose_credits_10(state, side, eid, n):
	return (NREid.wait_for(state, eid, func(ne):
		NRGaining.lose_credits(state, "runner", ne, 1)
, func(async_result):
	gf_lose_credits(state, side, eid, (int(n) - 1))) if NRCardRT.pos(n) else NREid.effect_completed(state, side, eid))

static func _prevent_sub_break_by_11(t):
	return {
	"type": "prevent-paid-ability",
	"duration": "end-of-run",
	"value": true,
	"req": func(state, side, eid, card, targets):
		return (func():
			var _v_12 = targets
			var break_card = NRCardRT.getv(_v_12, 0)
			var break_ability = NRCardRT.getv(_v_12, 1)
			return (NRUtil.same_card(break_card, t) and (NRCardRT.as_array(break_ability).has("break") or NRCardRT.as_array(break_ability).has("breaks") or NRCardRT.as_array(break_ability).has("heap-breaker-break") or NRCardRT.as_array(break_ability).has("break-cost")))
		).call(),
}

static func _hort_13(n):
	return {
	"prompt": "Choose a card to add to HQ",
	"async": true,
	"choices": func(state, side, eid, card, targets):
		var corp = state.player("corp")
		return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.getv(corp, "deck"))),
	"msg": "add 1 card to HQ from R&D",
	"cancel": NRShuffling.shuffle_deck,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		NRMoving.move(state, side, target, "hand")
		return (NREngine.resolve_ability(state, side, eid, hort((int(n) + 1)), card, null) if (n < 2) else (func():
			NRShuffling.shuffle_zone(state, side, "deck")
			NRSay.system_msg(state, side, str("shuffles R&D"))
			return NREid.effect_completed(state, side, eid)
		).call()),
}

static func _otherwise_tag_14(message, ability):
	return {
	"msg": func(state, side, eid, card, targets):
		var tagged = NRUtil.is_tagged(state)
		return str((message if tagged else "give the Runner 1 tag")),
	"label": str(str(message)) + str(" if the Runner is tagged; otherwise, give the Runner 1 tag"),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var tagged = NRUtil.is_tagged(state)
		return (ability(state, "runner", eid, card, null) if tagged else NRTags.gain_tags(state, "runner", eid, 1)),
}

static func _brain_damage_unless_runner_pays_15(cost, text):
	return {
	"player": "runner",
	"async": true,
	"label": str("Do 1 core damage unless the Runner trashes 1 installed ") + str(text),
	"prompt": "Choose one",
	"waiting-prompt": true,
	"choices": func(state, side, eid, card, targets):
		return [
			"Take 1 core damage",
			(str(NRPayment.cost_to_string(cost)) if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, cost)) else null)
		],
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str(("do 1 core damage" if (("Take 1 core damage" == target) or NRUtil.kw_eq("Take 1 core damage", target)) else str("force the runner to ") + str(NRCardRT.decapitalize(target)))),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		var async_result = NREid.result_of(eid)
		return (NRDamage.damage(
			state,
			side,
			eid,
			"brain",
			1,
			{
				"card": card,
			}
		) if (("Take 1 core damage" == target) or NRUtil.kw_eq("Take 1 core damage", target)) else NREid.wait_for(state, eid, func(ne):
			NREngine.pay(state, "runner", ne, card, cost)
		, func(async_result):
			(func():
				var payment_str = NRCardRT.getv(async_result, "msg")
				return NRSay.system_msg(state, "runner", str(payment_str) + str(" due to ") + str(NRCardRT.getv(card, "title"))) if payment_str != null and NRCardRT.truthy(payment_str) else null
			).call()
			NREid.effect_completed(state, side, eid))),
}

static func _top_3_16(state):
	return NRCardRT.take_n(state.get_in(["runner", "deck"], null), int(3))

static func _ice_subtype_choice_17(choices):
	return {
	"prompt": "Choose an ice subtype",
	"choices": choices,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return (NREid.effect_completed(state, side, eid) if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else (func():
			var remaining_choices = NRCardRT.filter_list(choices, func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy([target].call(x) if [target] is Callable else [target])).call(x)))
			var new_choices = dedupe((NRCardRT.as_array(remaining_choices) + ["Done"]))
			NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to make itself gain ") + str(target))
			NREffects.register_lingering_effect(
				state,
				side,
				card,
				(func():
					var ice = card
					return {
						"type": "gain-subtype",
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRUtil.same_card(ice, target),
						"value": target,
					}
				).call()
			)
			return NREngine.resolve_ability(state, side, eid, ice_subtype_choice(new_choices), card, null)
		).call()),
}

static func _net_or_mill_18(net_dmg, mill_cnt):
	return {
	"label": str("Do ") + str(net_dmg) + str(" net damage"),
	"player": "runner",
	"waiting-prompt": true,
	"prompt": "Choose one",
	"choices": func(state, side, eid, card, targets):
		return [
			str("Take ") + str(net_dmg) + str(" net damage"),
			(str(NRPayment.build_cost_label([NRPayment.to_c("trash-from-deck", mill_cnt)])) if NRCardRT.truthy(NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-from-deck", mill_cnt)])) else null)
		],
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		var async_result = NREid.result_of(eid)
		return ((func():
			NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to do ") + str(net_dmg) + str(" net damage"))
			return NRDamage.damage(
				state,
				"runner",
				eid,
				"net",
				net_dmg,
				{
					"card": card,
				}
			)
		).call() if ((target == str("Take ") + str(net_dmg) + str(" net damage")) or NRUtil.kw_eq(target, str("Take ") + str(net_dmg) + str(" net damage"))) else NREid.wait_for(state, eid, func(ne):
			NREngine.pay(state, "runner", ne, card, [NRPayment.to_c("trash-from-deck", mill_cnt)])
		, func(async_result):
			NRSay.system_msg(state, "runner", NRCardRT.getv(async_result, "msg"))
			NREid.effect_completed(state, side, eid))),
}

static func _etr_if_threat_x_19(x):
	return NRUtil.merge(_end_the_run(), {"label": str("If threat >=") + str(x) + str(", End the run"), "change-in-game-state": {
	"silent": true,
	"req": func(state, side, eid, card, targets):
		return NRThreat.threat(state, int(x)),
}})

static func _trash_programs_20(cnt, state, side, card, eid):
	return (NREid.wait_for(state, eid, func(ne):
		NREngine.resolve_ability(state, side, ne, _trash_program_sub(), card, null)
, func(async_result):
	trash_programs((int(cnt) - 1), state, side, card, eid)) if NRCardRT.pos(cnt) else NREid.effect_completed(state, side, eid))

static func _resolve_extra_damage_21(x, eid):
	NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to deal 1 additional net damage") + str((str(" (") + str((int(x) - 1)) + str(" remaining)") if NRCardRT.truthy((x > 1)) else null)))
	return (NRDamage.damage(
	state,
	side,
	eid,
	"net",
	1,
	{
		"card": card,
	}
) if not NRCardRT.truthy((x > 1)) else NREid.wait_for(state, eid, func(ne):
	NRDamage.damage(side, "net", ne, 1, {
		"card": card,
	})
, func(async_result):
	resolve_extra_damage((int(x) - 1), eid)))

static func _top_3_22(state):
	return NRCardRT.take_n(state.get_in(["runner", "deck"], null), int(3))

static func _top_3_names_23(cards):
	return NRCardRT.map_list(cards, func(_pct):
		return str(NRCardRT.getv(_pct, "title")) + str(" (") + str(NRCardRT.getv(_pct, "type")) + str(")"))

static func _effect_type_24(card):
	return str(str("slot-machine-top-3-") + str(NRCardRT.getv(card, "cid")))

static func _name_builder_25(card):
	return str(NRCardRT.getv(card, "title")) + str(" (") + str(NRCardRT.getv(card, "type")) + str(")")

static func _top_3_types_26(state, card, et):
	return NRCardRT.count_of(NRCardRT.concat_lists([[], NRCardRT.filter_list(NRCardRT.getv(NREffects.get_effects(state, "corp", et, card), 0), func(x): return NRCardRT.getv(x, "type"))]))

static func _ability_27():
	return {
	"label": "Encounter ability (manual)",
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var runner = state.player("runner")
		NRMoving.move(state, "runner", NRCardRT.getv(NRCardRT.getv(runner, "deck"), 0), "deck")
		return (func():
			var t3 = _top_3_22(state)
			var effect_type = _effect_type_24(card)
			NREffects.register_lingering_effect(
				state,
				side,
				card,
				{
					"type": _effect_type_24(),
					"duration": "end-of-encounter",
					"value": t3,
				}
			)
			NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to put the top card of the stack to the bottom,") + str(" then reveal ") + str(enumerate_str(_top_3_names_23(t3))) + str(" from the top of the stack"))
			return NRRevealing.reveal(state, side, eid, t3)
		).call(),
}

static func _next_t_28(t):
	return ("Sentry" if NRCardRT.truthy(((t == "Barrier") or NRUtil.kw_eq(t, "Barrier"))) else null)

static func _search_for_type_29(t, chosen):
	return ({
	"prompt": str("Pick a ") + str(t) + str(" to add to HQ"),
	"choices": func(state, side, eid, card, targets):
		var corp = state.player("corp")
		return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
			return NRCard.has_subtype(_pct, t)))),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, search_for_type(_next_t_28(t), (NRCardRT.as_array(chosen) + [target])), card, null),
	"cancel": {
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NREngine.resolve_ability(state, side, eid, search_for_type(_next_t_28(t), chosen), card, null),
	},
} if t else NRCardRT.choose_one_helper(
	{
		"prompt": (str("You will tutor ") + str(NRCardRT.enumerate_cards(chosen)) if NRCardRT.seq_of(chosen) else "You will shuffle R&D"),
	},
	[
		{
			"option": "OK",
			"ability": ({
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, card, {
							"and-then": ", and add [them] to HQ",
						}, NRCardRT.as_array(chosen))
					, func(async_result):
						(func():
							for c in NRCardRT.as_array(chosen):
								NRMoving.move(state, "corp", c, "hand")
							return null
						).call()
						NRShuffling.shuffle_zone(state, "corp", "deck")
						NREid.effect_completed(state, side, eid)),
			} if NRCardRT.seq_of(chosen) else {
				"msg": "shuffle R&D",
				"effect": func(state, side, eid, card, targets):
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}),
		},
		{
			"option": "I want to start over",
			"ability": search_for_type("Barrier", []),
		}
	]
))
