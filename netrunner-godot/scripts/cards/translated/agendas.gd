class_name NRCardsAgendas
extends RefCounted

## Port of game.cards.agendas — translated from Jinteki.net Clojure.


static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("15 Minutes", NRUtil.merge({
		"title": "15 Minutes",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": true,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"text": "[click]: Shuffle 15 Minutes into R&D. The Corp can trigger this ability while 15 Minutes is in the Runner's score area.\nLimit 1 per deck."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "shuffle itself into R&D",
				"label": "Shuffle this agenda into R&D",
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, "corp", card, "deck", null)
					NRShuffling.shuffle_zone(state, "corp", "deck")
					return NRAgendas.update_all_agenda_points(state, side),
			}
		],
		"flags": {
			"has-abilities-when-stolen": true,
		},
	}))
	NRCardDefs.defcard("Above the Law", NRUtil.merge({
		"title": "Above the Law",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, you may trash 1 installed resource.\nLimit 1 per deck."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Choose a resource to trash",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
					return (NRCard.installed(_pct) and NRCard.resource(_pct))),
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.resource(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRToString.card_str(state, target)),
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
	NRCardDefs.defcard("Accelerated Beta Test", NRUtil.merge({
		"title": "Accelerated Beta Test",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score Accelerated Beta Test, you may look at the top 3 cards of R&D. If any of those cards are ice, you may install and rez them, ignoring all costs. Trash the rest of the cards you looked at."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Look at the top 3 cards of R&D?",
				"yes-ability": {
					"async": true,
					"msg": "look at the top 3 cards of R&D",
					"effect": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						NREngine.register_events(
							state,
							side,
							card,
							[
								{
									"event": "corp-shuffle-deck",
									"effect": func(state, side, eid, card, targets):
										return NRUpdate.update_card(state, side, NRUtil.assoc_in(card, ["special", "shuffle-occurred"], true)),
								}
							]
						)
						return (func():
							var choices = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3))
							return NREid.wait_for(state, eid, func(ne):
								NREngine.resolve_ability(state, side, ne, {
									"async": true,
									"prompt": str("The top cards of R&D are (top->bottom): ") + str(NRCardRT.enumerate_cards(choices)),
									"choices": ["OK"],
								}, card, null)
							, func(async_result):
								NREngine.resolve_ability(state, side, eid, _abt_3(choices), card, null))
						).call(),
				},
			},
		},
	}))
	NRCardDefs.defcard("Advanced Concept Hopper", NRUtil.merge({
		"title": "Advanced Concept Hopper",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "The first time the Runner initiates a run each turn, you may draw 1 card or gain 1[credit]."
	}, {
		"events": [
			{
				"event": "run",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "run"),
				"async": true,
				"waiting-prompt": true,
				"prompt": "Choose one",
				"choices": ["Draw 1 card", "Gain 1 [Credits]", "No action"],
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return ((func():
						NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain 1 [Credits]"))
						return NRGaining.gain_credits(state, "corp", eid, 1)
					).call() if ((target == "Gain 1 [Credits]") or NRUtil.kw_eq(target, "Gain 1 [Credits]")) else ((func():
						NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to draw 1 card"))
						return NRDrawing.draw(state, "corp", eid, 1)
					).call() if ((target == "Draw 1 card") or NRUtil.kw_eq(target, "Draw 1 card")) else ((func():
						NRSay.system_msg(state, "corp", str("declines to use ") + str(NRCardRT.getv(card, "title")))
						return NREid.effect_completed(state, side, eid)
					).call() if ((target == "No action") or NRUtil.kw_eq(target, "No action")) else null))),
			}
		],
	}))
	NRCardDefs.defcard("Aggressive Trendsetting", NRUtil.merge({
		"title": "Aggressive Trendsetting",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "The first time the Runner trashes an installed Corp card during each of their turns, they may spend [click]. If they do not, you get +1 allotted [click] for your next turn."
	}, {
		"events": [
			{
				"event": "runner-trash",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"once-per-instance": true,
				"optional": {
					"req": func(state, side, eid, card, targets):
						return (_valid_ctx_4(targets) and (("runner" == NRCardRT.getv(state.data, "active-player")) or NRUtil.kw_eq("runner", NRCardRT.getv(state.data, "active-player"))) and NREvents.first_event(state, side, "runner-trash", _valid_ctx_4())),
					"player": "runner",
					"prompt": "Spend [click] to prevent the corporation having +1 allotted [click] during their next turn?",
					"yes-ability": {
						"cost": [NRPayment.to_c("click", 1)],
						"display-side": "runner",
						"msg": "cost",
					},
					"no-ability": {
						"display-side": "corp",
						"msg": func(state, side, eid, card, targets):
							return str("gain [Click] during their next turn"),
						"effect": func(state, side, eid, card, targets):
							return NREngine.register_events(
								state,
								side,
								card,
								[
									{
										"event": "corp-turn-begins",
										"unregister-once-resolved": true,
										"duration": "until-corp-turn-begins",
										"effect": func(state, side, eid, card, targets):
											return NRGaining.gain_clicks(state, "corp", 1),
									}
								]
							),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Ancestral Imager", NRUtil.merge({
		"title": "Ancestral Imager",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "Whenever the Runner jacks out, do 1 net damage."
	}, {
		"events": [
			{
				"event": "jack-out",
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
	NRCardDefs.defcard("AR-Enhanced Security", NRUtil.merge({
		"title": "AR-Enhanced Security",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "The first time each turn the Runner trashes a Corp card, give them 1 tag."
	}, {
		"events": [
			{
				"event": "runner-trash",
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"once-per-instance": true,
				"req": func(state, side, eid, card, targets):
					return (_valid_ctx_5(targets) and NREvents.first_event(state, side, "runner-trash", _valid_ctx_5())),
				"msg": "give the Runner a tag",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, side, eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Architect Deployment Test", NRUtil.merge({
		"title": "Architect Deployment Test",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, look at the top 5 cards of R&D. You may install and rez 1 of those cards, ignoring all costs."
	}, {
		"on-score": NRCardRT.combine_abilities(
			look_at_the_top("corp", "corp", 5),
			{
				"prompt": "Choose a card to install",
				"choices": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5)), NRCard.corp_installable_type))),
				"async": true,
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return (func():
						var target_position = NRCardRT.getv([], 0)
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
									"origin-index": target_position,
									"display-origin": true,
								},
								"install-state": "rezzed-no-cost",
							}
						)
					).call(),
			}
		),
	}))
	NRCardDefs.defcard("Armed Intimidation", NRUtil.merge({
		"title": "Armed Intimidation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Armed Intimidation, the Runner must either suffer 5 meat damage or take 2 tags."
	}, {
		"on-score": {
			"player": "runner",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose one",
			"choices": ["Suffer 5 meat damage", "Take 2 tags"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRTags.gain_tags(
					state,
					"runner",
					eid,
					2,
					{
						"card": card,
					}
				) if ((target == "Take 2 tags") or NRUtil.kw_eq(target, "Take 2 tags")) else NRDamage.damage(
					state,
					"runner",
					eid,
					"meat",
					5,
					{
						"card": card,
						"unboostable": true,
					}
				)),
		},
	}))
	NRCardDefs.defcard("Armored Servers", NRUtil.merge({
		"title": "Armored Servers",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> For the remainder of this run, the Runner must trash 1 card from the grip as an additional cost to jack out or break a subroutine. Use this ability only during a run."
	}, {
		"on-score": _agenda_counters(1),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run,
				"label": "increase cost to break subroutines or jack out",
				"msg": "make the Runner trash a card from the grip as an additional cost to jack out or break subroutines for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "break-sub-additional-cost",
							"duration": "end-of-run",
							"value": func(state, side, eid, card, targets):
								var context = NRCardRT.ctx(targets)
								return NRCardRT.repeat_n(NRPayment.to_c("trash-from-hand", 1), int(NRCardRT.count_of(NRCardRT.getv(NRCardRT.getv(context, "ability"), "broken-subs")))),
						}
					)
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "jack-out-additional-cost",
							"duration": "end-of-run",
							"value": NRPayment.to_c("trash-from-hand", 1),
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Artificial Cryptocrash", NRUtil.merge({
		"title": "Artificial Cryptocrash",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, the Runner loses 7[credit]."
	}, {
		"on-score": {
			"async": true,
			"msg": "make the Runner lose 7 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "runner", eid, 7),
		},
	}))
	NRCardDefs.defcard("AstroScript Pilot Program", NRUtil.merge({
		"title": "AstroScript Pilot Program",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> Place 1 advancement counter on an installed card you can advance."
	}, {
		"on-score": _agenda_counters(1),
		"abilities": [NRUtil.merge(place_advancement_counter(true, 1), {"cost": [NRPayment.to_c("agenda", 1)]})],
	}))
	NRCardDefs.defcard("Award Bait", NRUtil.merge({
		"title": "Award Bait",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Sensie",
		"subtypes": ["Sensie"],
		"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda, you may place up to 2 advancement counters on 1 installed card you can advance."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				return NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return NRCard.can_be_advanced(state, _pct))),
			"waiting-prompt": true,
			"prompt": "How many advancement counters do you want to place?",
			"choices": ["0", "1", "2"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var c = str_to_int(target)
					return {
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRCard.can_be_advanced(state, target),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("place ") + str(NRCardRT.quantify(c, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, target)),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRProps.add_prop(
								state,
								"corp",
								eid,
								target,
								"advance-counter",
								c,
								{
									"placed": true,
								}
							),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Azef Protocol", NRUtil.merge({
		"title": "Azef Protocol",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "As an additional cost to score this agenda, trash 1 of your other installed cards.\nWhen you score this agenda, do 2 meat damage."
	}, {
		"additional-cost": [NRPayment.to_c("trash-other-installed", 1)],
		"on-score": {
			"async": true,
			"msg": "do 2 meat damage",
			"automatic": "damage",
			"interactive": func(state, side, eid, card, targets):
				return true,
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
	}))
	NRCardDefs.defcard("Bacterial Programming", NRUtil.merge({
		"title": "Bacterial Programming",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When Bacterial Programming is scored or stolen, you may look at the top 7 cards of R&D, add any number of them to HQ, trash any number of them, and arrange the rest in any order."
	}, (func():
		var arrange_rd = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"optional": {
				"waiting-prompt": true,
				"prompt": "Look at the top 7 cards of R&D?",
				"yes-ability": {
					"async": true,
					"msg": "look at the top 7 cards of R&D",
					"prompt": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return str("The top cards of R&D are (top->bottom): ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(7)))),
					"choices": ["OK"],
					"effect": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (func():
							var set_aside_cards = set_aside_for_me(state, side, eid, NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(7)))
							(state.assoc_in(["run", "shuffled-during-access", "rd"], true) if NRCardRT.truthy((NRCardRT.getv(state.data, "access") and NRCardRT.getv(state.data, "run"))) else null)
							return NREngine.resolve_ability(state, side, eid, _interact_8(set_aside_cards, set_aside_cards, [], [], [], "trash"), card, null)
						).call(),
				},
			},
		}
		return {
			"on-score": arrange_rd,
			"stolen": arrange_rd,
		}
	).call()))
	NRCardDefs.defcard("The Basalt Spire", NRUtil.merge({
		"title": "The Basalt Spire",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"text": "When the Runner steals this agenda, you may add 1 card from Archives to HQ.\nWhen you score this agenda, place 2 agenda counters on it.\nOnce per turn → <strong> Hosted agenda counter</strong>, <strong>trash the top card of R&D:</strong> Add 1 card from Archives to HQ."
	}, {
		"on-score": _agenda_counters(2),
		"stolen": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, corp_recur(), card, null),
		},
		"flags": {
			"has-abilities-when-stolen": true,
		},
		"abilities": [
			{
				"label": "Choose a card to add to HQ",
				"cost": [NRPayment.to_c("trash-from-deck", 1), NRPayment.to_c("agenda", 1)],
				"once": "per-turn",
				"msg": "add 1 card from Archives to HQ",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, corp_recur(), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Bellona", NRUtil.merge({
		"title": "Bellona",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "As an additional cost to steal this agenda, the Runner must pay 5[credit].\nWhen you score this agenda, gain 5[credit]."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("credit", 5)],
		"on-score": NRDefHelpers.gain_credits_ability(5),
	}))
	NRCardDefs.defcard("Better Citizen Program", NRUtil.merge({
		"title": "Better Citizen Program",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "The first time the Runner plays a <strong>run</strong> event or installs an <strong>icebreaker</strong> program each turn, you may give the Runner 1 tag."
	}, {
		"events": [
			{
				"event": "play-event",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRCard.has_subtype(NRCardRT.getv(context, "card"), "Run") and NREvents.first_event(
							state,
							"runner",
							"play-event",
							func(_pct):
								return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "Run")
						) and NREvents.no_event(
							state,
							"runner",
							"runner-install",
							func(_pct):
								return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "Icebreaker")
						),
					"waiting-prompt": true,
					"prompt": "Give the runner 1 tag?",
					"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
					"yes-ability": {
						"async": true,
						"msg": "give the Runner a tag for playing a run event",
						"effect": func(state, side, eid, card, targets):
							return NRTags.gain_tags(state, "corp", eid, 1),
					},
				},
			},
			{
				"event": "runner-install",
				"silent": true,
				"optional": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (not NRCardRT.truthy(NRCardRT.getv(context, "facedown"))) and NRCard.has_subtype(NRCardRT.getv(context, "card"), "Icebreaker") and NREvents.first_event(
							state,
							"runner",
							"runner-install",
							func(_pct):
								return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "Icebreaker")
						) and NREvents.no_event(
							state,
							"runner",
							"play-event",
							func(_pct):
								return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "Run")
						),
					"waiting-prompt": true,
					"prompt": "Give the runner 1 tag?",
					"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
					"yes-ability": {
						"async": true,
						"msg": "give the Runner a tag for installing an icebreaker",
						"effect": func(state, side, eid, card, targets):
							return NRTags.gain_tags(state, "corp", eid, 1),
					},
				},
			}
		],
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "Better Citizen Program")],
	}))
	NRCardDefs.defcard("Bifrost Array", NRUtil.merge({
		"title": "Bifrost Array",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score Bifrost Array, you may trigger the \"when scored\" ability of another agenda that is not a copy of Bifrost Array in your score area."
	}, {
		"on-score": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "scored"), func(_pct):
						return (not ((NRCardRT.getv(_pct, "title") == "Bifrost Array") or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), "Bifrost Array"))))),
				"prompt": "Trigger the ability of a scored agenda?",
				"yes-ability": {
					"prompt": "Choose an agenda to trigger its \"when scored\" ability",
					"choices": {
						"card": func(_pct):
							return (NRCard.agenda(_pct) and (not ((NRCardRT.getv(_pct, "title") == "Bifrost Array") or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), "Bifrost Array"))) and NRCard.in_scored(_pct) and when_scored(_pct)),
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("trigger the \"when scored\" ability of ") + str(NRCardRT.getv(target, "title")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, NRCardRT.getv(NRCardDefs.card_def(target), "on-score"), target, null),
				},
			},
		},
	}))
	NRCardDefs.defcard("Blood in the Water", NRUtil.merge({
		"title": "Blood in the Water",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "X is equal to the number of cards in the Runner's grip."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			var runner = state.player("runner")
			return NRCardRT.count_of(NRCardRT.getv(runner, "hand")),
		"advancement-requirement": NRCardRT.get_x_fn(),
	}))
	NRCardDefs.defcard("Brain Rewiring", NRUtil.merge({
		"title": "Brain Rewiring",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, you may spend any number of credits. If you do, the Runner adds that many cards from the grip to the bottom of the stack at random, then draws 1 card."
	}, {
		"on-score": {
			"optional": {
				"waiting-prompt": true,
				"prompt": "Pay credits to add random cards from the grip to the bottom of the stack?",
				"yes-ability": {
					"prompt": "How many credits do you want to pay?",
					"choices": {
						"number": func(state, side, eid, card, targets):
							var runner = state.player("runner")
							var corp = state.player("corp")
							return mini(NRCardRT.getv(corp, "credit"), NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var runner = state.player("runner")
						return (NREid.wait_for(state, eid, func(ne):
							NREngine.pay(state, "corp", ne, card, NRPayment.to_c("credit", target))
						, func(async_result):
							(func():
								var from = NRCardRT.take_n(shuffle(NRCardRT.getv(runner, "hand")), int(target))
								(func():
									for c in NRCardRT.as_array(from):
										NRMoving.move(state, "runner", c, "deck")
									return null
								).call()
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to pay ") + str(target) + str(" [Credits] and add ") + str(NRCardRT.quantify(target, "card")) + str(" from the grip") + str(" to the bottom of the stack.") + str(" The Runner draws 1 card"))
								NREngine.queue_event(state, "runner-hand-changed?")
								return NREid.wait_for(state, eid, func(ne):
									NREngine.checkpoint(state, side, ne)
								, func(async_result):
									NRDrawing.draw(state, "runner", eid, 1))
							).call()) if NRCardRT.pos(target) else NREid.effect_completed(state, side, eid)),
				},
			},
		},
	}))
	NRCardDefs.defcard("Braintrust", NRUtil.merge({
		"title": "Braintrust",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score Braintrust, place 1 agenda counter on it for every 2 advancement tokens on it over 3.\nThe rez cost of all ice is lowered by 1 for each agenda counter on Braintrust."
	}, _project_agenda(
		{
			"granularity": 2,
		}
	)))
	NRCardDefs.defcard("Breaking News", NRUtil.merge({
		"title": "Breaking News",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"text": "When you score this agenda, give the Runner 2 tags.\nWhen a discard phase ends, if you scored this agenda this turn, the Runner removes 2 tags."
	}, {
		"on-score": NRDefHelpers.give_tags(2),
		"events": (func():
			var event = {
				"unregister-once-resolved": true,
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(
						state,
						side,
						"agenda-scored",
						func(_pct):
							return NRUtil.same_card(card, NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
					),
				"msg": "make the Runner lose 2 tags",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose(state, "runner", "tag", 2),
			}
			return [
				NRUtil.merge(event, {"event": "corp-turn-ends"}),
				NRUtil.merge(event, {"event": "runner-turn-ends"})
			]
		).call(),
	}))
	NRCardDefs.defcard("Broad Daylight", NRUtil.merge({
		"title": "Broad Daylight",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security - Liability",
		"subtypes": ["Security", "Liability"],
		"text": "When you score this agenda, you may take 1 bad publicity. Place 1 agenda counter on this agenda for each bad publicity you have.\nOnce per turn → [click], <strong>hosted agenda counter:</strong> Do 2 meat damage."
	}, {
		"on-score": {
			"optional": {
				"prompt": "Take 1 bad publicity?",
				"yes-ability": {
					"async": true,
					"msg": "take 1 bad publicity",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRBadPublicity.gain_bad_publicity(state, "corp", ne, 1)
						, func(async_result):
							_agenda_counters_9(state, side, card, eid)),
				},
				"no-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return _agenda_counters_9(state, side, card, eid),
				},
			},
		},
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda", 1)],
				"async": true,
				"label": "Do 2 meat damage",
				"once": "per-turn",
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
	NRCardDefs.defcard("CFC Excavation Contract", NRUtil.merge({
		"title": "CFC Excavation Contract",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"text": "When you score CFC Excavation Contract, gain 2[credit] for each rezzed <strong>bioroid</strong>."
	}, {
		"on-score": {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(_bucks_10(state)) + str(" [Credits]"),
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, _bucks_10(state)),
		},
	}))
	NRCardDefs.defcard("Character Assassination", NRUtil.merge({
		"title": "Character Assassination",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Character Assassination, trash 1 resource (cannot be prevented)."
	}, {
		"on-score": {
			"prompt": "Choose a resource to trash",
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.resource(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRCardRT.getv(target, "title")),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
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
		},
	}))
	NRCardDefs.defcard("Chronos Project", NRUtil.merge({
		"title": "Chronos Project",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, the Runner removes all cards in the heap from the game."
	}, {
		"on-score": {
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NRFlags.zone_locked(state, "runner", "discard"))),
			"msg": "remove all cards in the heap from the game",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move_zone(state, "runner", "discard", "rfg"),
		},
	}))
	NRCardDefs.defcard("City Works Project", NRUtil.merge({
		"title": "City Works Project",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Public",
		"subtypes": ["Public"],
		"text": "Install City Works Project faceup.\nWhen the Runner accesses City Works Project while it is installed, do 2 meat damage and 1 additional meat damage for each advancement token on it."
	}, {
		"install-state": "face-up",
		"on-access": {
			"req": func(state, side, eid, card, targets):
				var installed = NRCard.installed(card) if card is Dictionary else false
				return installed,
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str(_meat_damage_11(state, card)) + str(" meat damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"meat",
					_meat_damage_11(state, card),
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("Clone Retirement", NRUtil.merge({
		"title": "Clone Retirement",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative - Liability",
		"subtypes": ["Initiative", "Liability"],
		"text": "When you score this agenda, you may remove 1 bad publicity.\nWhen the Runner steals this agenda, take 1 bad publicity."
	}, {
		"on-score": {
			"msg": "remove 1 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.lose_bad_publicity(state, side, 1),
			"silent": true,
		},
		"stolen": {
			"msg": "force the Corp to take 1 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.gain_bad_publicity(state, "corp", 1),
		},
	}))
	NRCardDefs.defcard("Corporate Oversight A", NRUtil.merge({
		"title": "Corporate Oversight A",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 0,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score Corporate Oversight, you may search R&D for a piece of ice. Install and rez it protecting a remote server, ignoring all costs. Shuffle R&D.\nIf you win a game with Corporate Oversight in your score area, destroy it."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Search R&D for a piece of ice to install protecting a remote server?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var corp = state.player("corp")
						return NREngine.resolve_ability(state, side, eid, ({
							"async": true,
							"prompt": "Choose a piece of ice",
							"choices": func(state, side, eid, card, targets):
								var corp = state.player("corp")
								return NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREngine.resolve_ability(state, side, eid, (func():
									var chosen_ice = target
									return {
										"async": true,
										"prompt": str("Choose a server to install ") + str(NRCardRT.getv(chosen_ice, "title")) + str(" on"),
										"choices": NRCardRT.filter_list(NRBoard.installable_servers(state, chosen_ice), func(_pct):
											return (not NRCardRT.truthy(["HQ", "Archives", "R&D"](_pct)))),
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											NRShuffling.shuffle_zone(state, side, "deck")
											return NRInstalling.corp_install(
												state,
												side,
												eid,
												chosen_ice,
												target,
												{
													"ignore-all-cost": true,
													"install-state": "rezzed-no-cost",
												}
											),
									}
								).call(), card, null),
						} if NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice)) else {
							"prompt": "You have no ice in R&D",
							"choices": ["Carry on!"],
							"prompt-type": "bogus",
							"msg": "shuffle R&D",
							"effect": func(state, side, eid, card, targets):
								return NRShuffling.shuffle_zone(state, side, "deck"),
						}), card, null),
				},
			},
		},
	}))
	NRCardDefs.defcard("Corporate Oversight B", NRUtil.merge({
		"title": "Corporate Oversight B",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 0,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score Corporate Oversight, you may search R&D for a piece of ice. Install and rez it protecting a central server, ignoring all costs. Shuffle R&D.\nIf you win a game with Corporate Oversight in your score area, destroy it."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Search R&D for a piece of ice to install protecting a central server?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var corp = state.player("corp")
						return NREngine.resolve_ability(state, side, eid, ({
							"async": true,
							"prompt": "Choose a piece of ice",
							"choices": func(state, side, eid, card, targets):
								var corp = state.player("corp")
								return NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREngine.resolve_ability(state, side, eid, (func():
									var chosen_ice = target
									return {
										"async": true,
										"prompt": str("Choose a server to install ") + str(NRCardRT.getv(chosen_ice, "title")) + str(" on"),
										"choices": NRCardRT.filter_list(NRBoard.installable_servers(state, chosen_ice), func(_pct):
											return ["HQ", "Archives", "R&D"](_pct)),
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											NRShuffling.shuffle_zone(state, side, "deck")
											return NRInstalling.corp_install(
												state,
												side,
												eid,
												chosen_ice,
												target,
												{
													"ignore-all-cost": true,
													"install-state": "rezzed-no-cost",
												}
											),
									}
								).call(), card, null),
						} if NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice)) else {
							"prompt": "You have no ice in R&D",
							"choices": ["Carry on!"],
							"prompt-type": "bogus",
							"msg": "shuffle R&D",
							"effect": func(state, side, eid, card, targets):
								return NRShuffling.shuffle_zone(state, side, "deck"),
						}), card, null),
				},
			},
		},
	}))
	NRCardDefs.defcard("Corporate Sales Team", NRUtil.merge({
		"title": "Corporate Sales Team",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score Corporate Sales Team, place 10[credit] on it.\nWhen each player's turn begins, take 1[credit] from Corporate Sales Team."
	}, (func():
		var e = {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCard.get_counters(card, "credit")),
			"msg": "gain 1 [Credits]",
			"automatic": "gain-credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDefHelpers.take_credits(state, side, eid, card, "credit", 1),
		}
		return {
			"on-score": _agenda_counters_9(10, "credit"),
			"events": [
				NRUtil.merge(e, {"event": "runner-turn-begins"}),
				NRUtil.merge(e, {"event": "corp-turn-begins"})
			],
		}
	).call()))
	NRCardDefs.defcard("Corporate War", NRUtil.merge({
		"title": "Corporate War",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "If you have at least 7[credit] when you score Corporate War, gain 7[credit]; otherwise, lose all credits in your credit pool."
	}, {
		"on-score": {
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str(("gain 7 [Credits]" if (NRCardRT.getv(corp, "credit") > 6) else "lose all credits")),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRGaining.gain_credits(state, "corp", eid, 7) if (NRCardRT.getv(corp, "credit") > 6) else NRGaining.lose_credits(state, "corp", eid, "all")),
		},
	}))
	NRCardDefs.defcard("Crisis Management", NRUtil.merge({
		"title": "Crisis Management",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "If the Runner is tagged, Crisis Management gains \"When your turn begins, do 1 meat damage.\""
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"async": true,
			"label": "Do 1 meat damage (start of turn)",
			"automatic": "corp-damage",
			"once": "per-turn",
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
		return {
			"events": [NRUtil.merge(ability, {"event": "corp-turn-begins"})],
			"abilities": [ability],
		}
	).call()))
	NRCardDefs.defcard("Cyberdex Sandbox", NRUtil.merge({
		"title": "Cyberdex Sandbox",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "The first time each turn you purge virus counters, gain 4[credit].\nWhen you score this agenda, you may purge virus counters."
	}, {
		"on-score": {
			"optional": {
				"prompt": "Purge virus counters?",
				"yes-ability": {
					"msg": "purge virus counters",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRPurging.purge(state, side, eid),
				},
			},
		},
		"events": [
			{
				"event": "purge",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, "corp", "purge"),
				"msg": "gain 4 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 4),
			}
		],
	}))
	NRCardDefs.defcard("Dedicated Neural Net", NRUtil.merge({
		"title": "Dedicated Neural Net",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative - Psi",
		"subtypes": ["Initiative", "Psi"],
		"text": "The first time there is a successful run on HQ each turn, you and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, you choose which cards the Runner accesses from HQ for the remainder of this run."
	}, {
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"psi": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (("hq" == NRServers.target_server(context)) or NRUtil.kw_eq("hq", NRServers.target_server(context))) and NREvents.first_event(
							state,
							side,
							"successful-run",
							func(_pct):
								return (("hq" == NRServers.target_server(NRCardRT.getv(_pct, 0))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardRT.getv(_pct, 0))))
						),
					"not-equal": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							NREffects.register_lingering_effect(
								state,
								side,
								card,
								{
									"type": "corp-choose-hq-access",
									"duration": "end-of-run",
									"value": true,
								}
							)
							return NREid.effect_completed(state, side, eid),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Degree Mill", NRUtil.merge({
		"title": "Degree Mill",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "As an additional cost to steal Degree Mill, the Runner must shuffle 2 installed Runner cards into the stack."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("shuffle-installed-to-stack", 2)],
	}))
	NRCardDefs.defcard("Director Haas' Pet Project", NRUtil.merge({
		"title": "Director Haas' Pet Project",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": true,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, you may create a new remote server by installing up to 3 cards from HQ and/or Archives in the root of and/or protecting that server, ignoring all install costs.\nLimit 1 per deck."
	}, {
		"on-score": {
			"optional": {
				"prompt": "Install cards in a new remote server?",
				"yes-ability": _install_ability_12("New remote", 0),
			},
		},
	}))
	NRCardDefs.defcard("Divested Trust", NRUtil.merge({
		"title": "Divested Trust",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"text": "Whenever the Runner steals another agenda, you may forfeit this agenda to gain 5[credit] and add the stolen agenda to HQ."
	}, {
		"events": [
			{
				"event": "agenda-stolen",
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (NREid.effect_completed(state, side, eid) if NRCardRT.getv(state.data, "winner") else (func():
						var card = NRFinding.find_latest(state, card)
						var stolen_agenda = NRFinding.find_latest(state, NRCardRT.getv(context, "card"))
						var title = NRCard.get_title(stolen_agenda)
						var prompt = str("Forfeit Divested Trust to add ") + str(title) + str(" to HQ and gain 5 [Credits]?")
						var message = str("add ") + str(title) + str(" to HQ and gain 5 [Credits]")
						var card_side = ("runner" if NRFlags.in_runner_scored(state, side, card) else "corp")
						return NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"waiting-prompt": true,
								"prompt": prompt,
								"yes-ability": {
									"msg": message,
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NREid.wait_for(state, eid, func(ne):
											NRMoving.forfeit(state, card_side, ne, card)
										, func(async_result):
											NRMoving.move(state, side, stolen_agenda, "hand")
											NRAgendas.update_all_agenda_points(state, side)
											NRGaining.gain_credits(state, side, eid, 5)),
								},
							},
						}, card, null)
					).call()),
			}
		],
	}))
	NRCardDefs.defcard("Domestic Sleepers", NRUtil.merge({
		"title": "Domestic Sleepers",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 0,
		"factioncost": 0,
		"text": "[click],[click],[click]: Place 1 agenda counter on Domestic Sleepers.\nDomestic Sleepers is worth 1 agenda point while it has at least 1 agenda counter on it."
	}, {
		"agendapoints-corp": func(state, side, eid, card, targets):
			return (1 if NRCardRT.pos(NRCard.get_counters(card, "agenda")) else 0),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 3)],
				"msg": "place 1 agenda counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return _add_agenda_point_counters(state, side, eid, card, 1),
			}
		],
	}))
	NRCardDefs.defcard("Élivágar Bifurcation", NRUtil.merge({
		"title": "Élivágar Bifurcation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, you may derez 1 installed card."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"waiting-prompt": true,
			"prompt": "Choose a card to derez",
			"choices": {
				"card": func(_pct):
					return NRCard.rezzed(_pct),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRRezzing.derez(state, side, eid, target),
		},
	}))
	NRCardDefs.defcard("Eden Fragment", NRUtil.merge({
		"title": "Eden Fragment",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Source",
		"subtypes": ["Source"],
		"text": "Ignore the install cost of the first piece of ice you install each turn.\nLimit 1 per deck."
	}, {
		"static-abilities": [
			{
				"type": "ignore-install-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.map_list(NREvents.turn_events(state, side, "corp-install"), func(_pct):
						return NRCardRT.getv(NRCardRT.getv(_pct, 0), "card")), NRCard.ice)),
				"value": true,
			}
		],
		"events": [
			{
				"event": "corp-install",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.ice(target) and NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.map_list(NREvents.turn_events(state, side, "corp-install"), func(_pct):
						return NRCardRT.getv(NRCardRT.getv(_pct, 0), "card")), NRCard.ice)),
				"msg": "ignore the install cost of the first piece of ice this turn",
			}
		],
	}))
	NRCardDefs.defcard("Efficiency Committee", NRUtil.merge({
		"title": "Efficiency Committee",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Place 3 agenda counters on Efficiency Committee when you score it.\n[click], <strong>hosted agenda counter:</strong> Gain [click][click]. You cannot advance cards for the remainder of this turn."
	}, {
		"on-score": _agenda_counters_9(3),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda", 1)],
				"effect": func(state, side, eid, card, targets):
					NRGaining.gain_clicks(state, side, 2)
					return NRFlags.register_turn_flag(state, side, card, "can-advance", (func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)),
				"keep-menu-open": "while-agenda-tokens-left",
				"msg": "gain [Click][Click]",
			}
		],
	}))
	NRCardDefs.defcard("Elective Upgrade", NRUtil.merge({
		"title": "Elective Upgrade",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, place 2 agenda counters on it.\nOnce per turn → [click], <strong>hosted agenda counter:</strong> Gain [click][click]."
	}, {
		"on-score": _agenda_counters_9(2),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda", 1)],
				"once": "per-turn",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_clicks(state, side, 2),
				"msg": "gain [Click][Click]",
			}
		],
	}))
	NRCardDefs.defcard("Embedded Reporting", NRUtil.merge({
		"title": "Embedded Reporting",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Dividends 2 <em>(When you score this agenda, place 2 agenda counters on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to search R&D for 1 operation and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that operation to the top of R&D."
	}, _project_agenda(
		{
			"quantity": 2,
			"mode": "computed",
		}
	)))
	NRCardDefs.defcard("Eminent Domain", NRUtil.merge({
		"title": "Eminent Domain",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion - Expendable",
		"subtypes": ["Expansion", "Expendable"],
		"text": "[click], <strong>1[credit]</strong>, <strong>reveal and trash this agenda from HQ:</strong> Install and rez 1 card from HQ, paying a total of 5[credit] less.\nWhen you score this agenda, you may search R&D for 1 card. <em>(Shuffle R&D after searching it.)</em> Install and rez that card, ignoring all costs."
	}, (func():
		var expend_abi = {
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.some_list(NRCardRT.getv(corp, "hand"), NRCard.corp_installable_type),
			"cost": [NRPayment.to_c("credit", 1)],
			"prompt": "Choose 1 card to install and rez, paying 5 [Credits] less",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.in_hand(target) and NRCard.corp_installable_type(target) and (not NRCardRT.truthy(NRUtil.same_card(card, target))),
			},
			"msg": "install and rez 1 card from HQ, paying 5 [Credits] less",
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
						"install-state": "rezzed",
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
						"combined-credit-discount": 5,
					}
				),
		}
		var score_abi = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Search R&D for 1 card to install and rez, ignoring all costs?",
				"yes-ability": {
					"async": true,
					"prompt": "Choose a card to install",
					"choices": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.concat_lists([NRCardRT.seq_of(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
							return NRCard.corp_installable_type(_pct)))), ["Cancel"]]),
					"cancel": NRShuffling.shuffle_deck,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						NRShuffling.shuffle_zone(state, side, "deck")
						return NRInstalling.corp_install(
							state,
							side,
							eid,
							target,
							null,
							{
								"install-state": "rezzed-no-cost",
								"msg-keys": {
									"install-source": card,
									"display-origin": true,
								},
								"ignore-all-cost": true,
							}
						),
				},
			},
		}
		return {
			"on-score": score_abi,
			"expend": expend_abi,
		}
	).call()))
	NRCardDefs.defcard("Encrypted Portals", NRUtil.merge({
		"title": "Encrypted Portals",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "All <strong>code gate</strong> ice have +1 strength.\nWhen you score Encrypted Portals, gain 1[credit] for each rezzed <strong>code gate</strong>."
	}, _ice_boost_agenda("Code Gate")))
	NRCardDefs.defcard("Escalate Vitriol", NRUtil.merge({
		"title": "Escalate Vitriol",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Once per turn → [click]<strong>:</strong> Gain 1[credit] for each tag the Runner has."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Gain 1 [Credit] for each Runner tag",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return tagged,
				},
				"cost": [NRPayment.to_c("click", 1)],
				"once": "per-turn",
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str(count_tags(state)) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, count_tags(state)),
			}
		],
	}))
	NRCardDefs.defcard("Executive Retreat", NRUtil.merge({
		"title": "Executive Retreat",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"text": "When you score Executive Retreat, place 1 agenda counter on it and shuffle HQ into R&D.\n[click], <strong>hosted agenda counter:</strong> Draw 5 cards."
	}, {
		"on-score": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRShuffling.shuffle_into_deck(state, side, "hand")
				return NRProps.add_counter(state, side, eid, card, "agenda", 1, null),
			"interactive": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			NRDefHelpers.draw_ability(
				5,
				null,
				{
					"action": true,
					"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda", 1)],
					"keep-menu-open": "while-agenda-tokens-left",
				}
			)
		],
	}))
	NRCardDefs.defcard("Explode-a-palooza", NRUtil.merge({
		"title": "Explode-a-palooza",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Sensie",
		"subtypes": ["Sensie"],
		"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda, you may gain 5[credit]."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"optional": {
				"waiting-prompt": true,
				"prompt": "Gain 5 [Credits]?",
				"yes-ability": NRDefHelpers.gain_credits_ability(5),
			},
		},
	}))
	NRCardDefs.defcard("Evidence Collection", NRUtil.merge({
		"title": "Evidence Collection",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you win a game with Evidence Collection in your score area, reveal set 2."
	}, {
		"events": [
			{
				"event": "win",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("corp" == NRCardRT.getv(context, "winner")) or NRUtil.kw_eq("corp", NRCardRT.getv(context, "winner"))),
				"msg": "reveal set 2",
			}
		],
	}))
	NRCardDefs.defcard("Evidence Collection 2", NRUtil.merge({
		"title": "Evidence Collection 2",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you win a game with Evidence Collection in your score area, reveal set 5."
	}, {
		"events": [
			{
				"event": "win",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("corp" == NRCardRT.getv(context, "winner")) or NRUtil.kw_eq("corp", NRCardRT.getv(context, "winner"))),
				"msg": "reveal set 5",
			}
		],
	}))
	NRCardDefs.defcard("Evidence Collection 3", NRUtil.merge({
		"title": "Evidence Collection 3",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you win a game with Evidence Collection in your score area, reveal set 8."
	}, {
		"events": [
			{
				"event": "win",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (("corp" == NRCardRT.getv(context, "winner")) or NRUtil.kw_eq("corp", NRCardRT.getv(context, "winner"))),
				"msg": "reveal set 8",
			}
		],
	}))
	NRCardDefs.defcard("Evidence Collection 4", NRUtil.merge({
		"title": "Evidence Collection 4",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "Evidence Collection is worth 1 fewer agenda point while in the Runner's score area."
	}, {
		"agendapoints-runner": func(state, side, eid, card, targets):
			return 1,
	}))
	NRCardDefs.defcard("False Lead", NRUtil.merge({
		"title": "False Lead",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "<strong>Forfeit this agenda:</strong> If the Runner has 2 or more [click] remaining, they lose [click][click]."
	}, (func():
		var ab = {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (2 <= NRCardRT.getv(runner, "click")),
			},
			"label": "runner loses [Click][Click]",
			"msg": "force the Runner to lose [Click][Click]",
			"cost": [NRPayment.to_c("forfeit-self")],
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_clicks(state, "runner", 2),
		}
		return {
			"events": [
				{
					"event": "post-runner-turn-begins",
					"optional": {
						"req": func(state, side, eid, card, targets):
							var tagged = NRUtil.is_tagged(state)
							return (true if ((NRCardRT.get_in(card, ["special", "ask-when-runner-turn-starts"], null) == "Always") or NRUtil.kw_eq(NRCardRT.get_in(card, ["special", "ask-when-runner-turn-starts"], null), "Always")) else (tagged if ((NRCardRT.get_in(card, ["special", "ask-when-runner-turn-starts"], null) == "When tagged") or NRUtil.kw_eq(NRCardRT.get_in(card, ["special", "ask-when-runner-turn-starts"], null), "When tagged")) else null)),
						"prompt": "Fire False Lead?",
						"waiting-prompt": true,
						"yes-ability": ab,
					},
				}
			],
			"abilities": [
				ab,
				{
					"label": "Ask when runner turn begins?",
					"prompt": "Ask to use False Lead after the Runner turn begins?",
					"choices": ["Always", "Never", "When tagged"],
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						NRUpdate.update_card(state, side, NRUtil.assoc_in(card, ["special", "ask-when-runner-turn-starts"], target))
						return NRToasts.toast(state, "corp", str("False Lead prompt set to: ") + str(target), "warning"),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Fetal AI", NRUtil.merge({
		"title": "Fetal AI",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda anywhere except in Archives, do 2 net damage.\nAs an additional cost to steal this agenda, the Runner must pay 2[credit]."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": NRUtil.merge(NRDefHelpers.do_net_damage(2), {"req": func(state, side, eid, card, targets):
			return (not NRCardRT.truthy(NRCard.in_discard(card)))}),
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("credit", 2)],
	}))
	NRCardDefs.defcard("Firmware Updates", NRUtil.merge({
		"title": "Firmware Updates",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, place 3 agenda counters on it.\nOnce per turn → <strong>Hosted agenda counter:</strong> Place 1 advancement counter on an installed piece of ice you can advance."
	}, {
		"on-score": _agenda_counters_9(3),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"label": "Place 1 advancement counter",
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (NRCard.ice(target) and NRCard.can_be_advanced(state, target)),
				},
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "agenda")),
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
				"once": "per-turn",
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
	NRCardDefs.defcard("Flower Sermon", NRUtil.merge({
		"title": "Flower Sermon",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"text": "When you score this agenda, place 5 agenda counters on it.\nOnce per turn → <strong>Hosted agenda counter:</strong> Reveal the top card of R&D. Draw 2 cards. Add 1 card from HQ to the top of R&D."
	}, {
		"on-score": _agenda_counters_9(5),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"label": "Reveal the top card of R&D and draw 2 cards",
				"once": "per-turn",
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str("reveal ") + str(NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0), "title")) + str(" and draw 2 cards"),
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0))
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRDrawing.draw(state, side, ne, 2)
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, {
								"req": func(state, side, eid, card, targets):
									var corp = state.player("corp")
									return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
								"prompt": "Choose a card in HQ to move to the top of R&D",
								"msg": {
									"public": "add 1 card in HQ to the top of R&D",
									"corp": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return str("add facedown ") + str(NRCardRT.getv(target, "title")) + str(" to the top of R&D"),
								},
								"choices": {
									"card": func(_pct):
										return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
								},
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
							}, card, null))),
			}
		],
	}))
	NRCardDefs.defcard("Fly on the Wall", NRUtil.merge({
		"title": "Fly on the Wall",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score Fly on the Wall, give the Runner 1 tag."
	}, {
		"on-score": NRDefHelpers.give_tags(1),
	}))
	NRCardDefs.defcard("Freedom of Information", NRUtil.merge({
		"title": "Freedom of Information",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "This agenda gets -1 advancement requirement for each tag the Runner has."
	}, {
		"advancement-requirement": func(state, side, eid, card, targets):
			return (-count_tags(state)),
	}))
	NRCardDefs.defcard("Fujii Asset Retrieval", NRUtil.merge({
		"title": "Fujii Asset Retrieval",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Ambush - Security",
		"subtypes": ["Ambush", "Security"],
		"text": "When this agenda is scored or stolen, do 2 net damage."
	}, (func():
		var ability = {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "do 2 net damage",
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
		}
		return {
			"stolen": ability,
			"on-score": ability,
		}
	).call()))
	NRCardDefs.defcard("Genetic Resequencing", NRUtil.merge({
		"title": "Genetic Resequencing",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score Genetic Resequencing, you may place 1 agenda counter on an agenda in your score area."
	}, {
		"on-score": {
			"choices": {
				"card": NRCard.in_scored,
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place 1 agenda counter on ") + str(NRCardRT.getv(target, "title")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRProps.add_counter(state, side, ne, target, "agenda", 1, null)
				, func(async_result):
					NRAgendas.update_all_agenda_points(state)
					NREid.effect_completed(state, side, eid)),
			"silent": true,
		},
	}))
	NRCardDefs.defcard("Geothermal Fracking", NRUtil.merge({
		"title": "Geothermal Fracking",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion - Liability",
		"subtypes": ["Expansion", "Liability"],
		"text": "When you score this agenda, place 2 agenda counters on it.\n[click], <strong>hosted agenda counter:</strong> Gain 7[credit] and take 1 bad publicity."
	}, {
		"on-score": _agenda_counters_9(2),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda", 1)],
				"msg": "gain 7 [Credits] and take 1 bad publicity",
				"async": true,
				"keep-menu-open": "while-agenda-tokens-left",
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, side, ne, 7)
					, func(async_result):
						NRBadPublicity.gain_bad_publicity(state, side, eid, 1)),
			}
		],
	}))
	NRCardDefs.defcard("Gila Hands Arcology", NRUtil.merge({
		"title": "Gila Hands Arcology",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "[click], [click]: Gain 3[credit]."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 2)],
				"msg": "gain 3 [Credits]",
				"async": true,
				"keep-menu-open": "while-2-clicks-left",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 3),
			}
		],
	}))
	NRCardDefs.defcard("Glenn Station", NRUtil.merge({
		"title": "Glenn Station",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "Glenn Station can host a single card.\n[click]: Host a card from HQ facedown on Glenn Station.\n[click]: Add a card on Glenn Station to HQ."
	}, {
		"abilities": [
			{
				"action": true,
				"label": "Host a card from HQ",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")) and NRCardRT.empty_of(NRCardRT.filter_list(NRCardRT.getv(card, "hosted"), NRCard.corp)),
				},
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "host a card from HQ",
				"prompt": "Choose a card to host",
				"choices": {
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRHosting.host(
						state,
						side,
						card,
						target,
						{
							"facedown": true,
						}
					),
			},
			{
				"action": true,
				"label": "Add a hosted card to HQ",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(card, "hosted"), NRCard.corp)),
				},
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "add a hosted card to HQ",
				"prompt": "Choose a hosted card",
				"choices": {
					"all": true,
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var hosted_corp_cards = NRCardRT.concat_lists([[], NRCardRT.map_list(NRCardRT.filter_list(NRCardRT.getv(card, "hosted"), NRCard.corp), func(x): return NRCardRT.getv(x, "cid"))])
							return hosted_corp_cards(NRCardRT.getv(target, "cid"))
						).call(),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.move(state, side, target, "hand"),
			}
		],
	}))
	NRCardDefs.defcard("Global Food Initiative", NRUtil.merge({
		"title": "Global Food Initiative",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 1,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Global Food Initiative is worth 1 fewer agenda point while in the Runner's score area."
	}, {
		"agendapoints-runner": func(state, side, eid, card, targets):
			return 2,
	}))
	NRCardDefs.defcard("Government Contracts", NRUtil.merge({
		"title": "Government Contracts",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"text": "[click], [click]: Gain 4[credit]."
	}, {
		"abilities": [
			NRUtil.merge(NRDefHelpers.gain_credits_ability(4), {"action": true, "cost": [NRPayment.to_c("click", 2)], "keep-menu-open": "while-2-clicks-left"})
		],
	}))
	NRCardDefs.defcard("Government Takeover", NRUtil.merge({
		"title": "Government Takeover",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": true,
		"advancementcost": 9,
		"agendapoints": 6,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "[click]: Gain 3[credit].\nLimit 1 Government Takeover per deck."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"async": true,
				"keep-menu-open": "while-clicks-left",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 3),
				"msg": "gain 3 [Credits]",
			}
		],
	}))
	NRCardDefs.defcard("Graft", NRUtil.merge({
		"title": "Graft",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"text": "When you score Graft, you may search your deck for up to 3 cards, reveal them, and add them to HQ. Shuffle R&D."
	}, {
		"on-score": {
			"async": true,
			"msg": "add up to 3 cards from R&D to HQ",
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _graft_13(1), card, null),
		},
	}))
	NRCardDefs.defcard("Greenmail", NRUtil.merge({
		"title": "Greenmail",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, gain 2[credit].\nWhen you forfeit this agenda, gain 4[credit]."
	}, {
		"on-score": NRDefHelpers.gain_credits_ability(2),
		"on-forfeit": NRDefHelpers.gain_credits_ability(4),
	}))
	NRCardDefs.defcard("Hades Fragment", NRUtil.merge({
		"title": "Hades Fragment",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Source",
		"subtypes": ["Source"],
		"text": "When your turn begins, you may add 1 card from Archives to the bottom of R&D.\nLimit 1 per deck."
	}, (func():
		var abi = {
			"prompt": "Choose a card to add to the bottom of R&D",
			"label": "add card to bottom of R&D",
			"show-discard": true,
			"event": "corp-turn-begins",
			"once": "per-turn",
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRMoving.move(state, side, target, "deck"),
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("add ") + str((NRCardRT.getv(target, "title") if NRCardRT.getv(target, "seen") else "a card")) + str(" to the bottom of R&D"),
		}
		return {
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (NRCardRT.seq_of(NRCardRT.getv(corp, "discard")) and is_scored(state, "corp", card)),
			},
			"abilities": [abi],
			"events": [
				NRUtil.merge(abi, {"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "discard")),
					"silent": true,
				}})
			],
		}
	).call()))
	NRCardDefs.defcard("Helium-3 Deposit", NRUtil.merge({
		"title": "Helium-3 Deposit",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"text": "When you score Helium-3 Deposit, place up to 2 power counters on a card with at least 1 power counter on it."
	}, {
		"on-score": {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "How many power counters do you want to place?",
			"choices": ["0", "1", "2"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var c = str_to_int(target)
					return NREngine.resolve_ability(state, side, eid, {
						"choices": {
							"card": func(_pct):
								return NRCardRT.pos(NRCard.get_counters(_pct, "power")),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("place ") + str(NRCardRT.quantify(c, "power counter")) + str(" on ") + str(NRCardRT.getv(target, "title")),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRProps.add_counter(state, side, eid, target, "power", c, null),
					}, card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("High-Risk Investment", NRUtil.merge({
		"title": "High-Risk Investment",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "Place 1 agenda counter on High-Risk Investment when you score it.\n[click], <strong>hosted agenda counter:</strong> Gain 1[credit] for each credit in the Runner's credit pool."
	}, {
		"on-score": _agenda_counters_9(1),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda", 1)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.pos(NRCardRT.getv(runner, "credit")),
				},
				"label": "gain credits",
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str("gain ") + str(NRCardRT.getv(runner, "credit")) + str(" [Credits]"),
				"async": true,
				"keep-menu-open": "while-agenda-tokens-left",
				"effect": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRGaining.gain_credits(state, side, eid, NRCardRT.getv(runner, "credit")),
			}
		],
	}))
	NRCardDefs.defcard("Hollywood Renovation", NRUtil.merge({
		"title": "Hollywood Renovation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative - Public",
		"subtypes": ["Initiative", "Public"],
		"text": "Install Hollywood Renovation faceup.\nWhenever you advance Hollywood Renovation, you may place 1 advancement token on another card that can be advanced (or 2 advancement tokens instead if there are 6 or more advancement tokens on Hollywood Renovation)."
	}, {
		"install-state": "face-up",
		"events": [
			{
				"event": "advance",
				"condition": "faceup",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "card")),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var n = (2 if (NRCard.get_counters(NRCard.get_card(state, card), "advancement") >= 6) else 1)
						return NREngine.resolve_ability(state, side, eid, {
							"choices": {
								"not-self": true,
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCard.can_be_advanced(state, target),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("place ") + str(NRCardRT.quantify(n, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, target)),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRProps.add_prop(
									state,
									"corp",
									eid,
									target,
									"advance-counter",
									n,
									{
										"placed": true,
									}
								),
						}, card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Hostile Takeover", NRUtil.merge({
		"title": "Hostile Takeover",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion - Liability",
		"subtypes": ["Expansion", "Liability"],
		"text": "When you score this agenda, gain 7[credit] and take 1 bad publicity."
	}, {
		"on-score": {
			"msg": "gain 7 [Credits] and take 1 bad publicity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 7, {
						"suppress-checkpoint": true,
					})
				, func(async_result):
					NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
			"interactive": func(state, side, eid, card, targets):
				return true,
		},
	}))
	NRCardDefs.defcard("House of Knives", NRUtil.merge({
		"title": "House of Knives",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, place 3 agenda counters on it.\n<strong>Hosted agenda counter:</strong> Do 1 net damage. Use this ability only during a run and only once per run."
	}, {
		"on-score": _agenda_counters_9(3),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"msg": "do 1 net damage",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(state.data, "run"),
				"once": "per-run",
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
	NRCardDefs.defcard("Hybrid Release", NRUtil.merge({
		"title": "Hybrid Release",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, you may install 1 facedown card from Archives."
	}, {
		"on-score": {
			"prompt": "Choose a facedown card in Archives to install",
			"show-discard": true,
			"waiting-prompt": true,
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
					return (not NRCardRT.truthy(NRCard.faceup(_pct)))),
			"async": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp_installable_type(_pct) and NRCard.in_discard(_pct) and (not NRCardRT.truthy(NRCard.faceup(_pct)))),
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
		},
	}))
	NRCardDefs.defcard("Hyperloop Extension", NRUtil.merge({
		"title": "Hyperloop Extension",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When Hyperloop Extension is scored or stolen, the Corp gains 3[credit]."
	}, {
		"on-score": NRDefHelpers.gain_credits_ability(3),
		"stolen": NRDefHelpers.gain_credits_ability(3),
	}))
	NRCardDefs.defcard("Ikawah Project", NRUtil.merge({
		"title": "Ikawah Project",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "As an additional cost to steal Ikawah Project, the Runner must spend [click] and 2[credit]."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)],
	}))
	NRCardDefs.defcard("Illicit Sales", NRUtil.merge({
		"title": "Illicit Sales",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion - Liability",
		"subtypes": ["Expansion", "Liability"],
		"text": "When you score this agenda, you may take 1 bad publicity. Gain 3[credit] for each bad publicity you have."
	}, {
		"on-score": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, {
						"optional": {
							"prompt": "Take 1 bad publicity?",
							"yes-ability": {
								"msg": "take 1 bad publicity",
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1),
							},
						},
					}, card, null)
				, func(async_result):
					(func():
						var n = (3 * count_bad_pub(state))
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain ") + str(n) + str(" [Credits]"))
						return NRGaining.gain_credits(state, side, eid, n)
					).call()),
		},
	}))
	NRCardDefs.defcard("Improved Protein Source", NRUtil.merge({
		"title": "Improved Protein Source",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When Improved Protein Source is scored or stolen, the Runner gains 4[credit]."
	}, (func():
		var ability = {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "make the Runner gain 4 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 4),
		}
		return {
			"on-score": ability,
			"stolen": ability,
		}
	).call()))
	NRCardDefs.defcard("Improved Tracers", NRUtil.merge({
		"title": "Improved Tracers",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "All <strong>tracer</strong> ice have +1 strength.\nThe base trace strength of each subroutine is increased by 1."
	}, {
		"move-zone": func(state, side, eid, card, targets):
			return ((func():
				NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to increase the strength of Tracer ice by 1"))
				NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to increase the base strength of all trace subroutines by 1"))
				NRIce.update_all_ice(state, side)
				return NREid.effect_completed(state, side, eid)
			).call() if (NRCard.in_scored(card) and (("corp" == NRCardRT.getv(card, "scored-side")) or NRUtil.kw_eq("corp", NRCardRT.getv(card, "scored-side")))) else NREid.effect_completed(state, side, eid)),
		"static-abilities": [
			{
				"type": "ice-strength",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.has_subtype(target, "Tracer"),
				"value": 1,
			},
			{
				"type": "trace-base-strength",
				"req": func(state, side, eid, card, targets):
					return (("subroutine" == NRCardRT.getv(NRCardRT.getv(targets, 1), "source-type")) or NRUtil.kw_eq("subroutine", NRCardRT.getv(NRCardRT.getv(targets, 1), "source-type"))),
				"value": 1,
			}
		],
	}))
	NRCardDefs.defcard("Jumon", NRUtil.merge({
		"title": "Jumon",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 6,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When your turn ends, place 2 advancement counters on 1 card in the root of a remote server."
	}, {
		"events": [
			{
				"event": "corp-turn-ends",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return ((((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))) == "content") or NRUtil.kw_eq((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))), "content")) and NRServers.is_remote(NRCardRT.getv(NRCard.get_zone(_pct), 1)))),
				"prompt": "Choose a card to place 2 advancement counters on",
				"choices": {
					"card": func(_pct):
						return ((((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))) == "content") or NRUtil.kw_eq((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))), "content")) and NRServers.is_remote(NRCardRT.getv(NRCard.get_zone(_pct), 1))),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place 2 advancement counters on ") + str(NRToString.card_str(state, target)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRProps.add_prop(
						state,
						"corp",
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
	NRCardDefs.defcard("Kimberlite Field", NRUtil.merge({
		"title": "Kimberlite Field",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, you may trash 1 of your rezzed cards. If you do, trash 1 installed Runner card with a printed install cost equal to or less than the printed rez cost of the Corp card you trashed."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose a rezzed card to trash",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRToString.card_str(state, target)),
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), NRCard.rezzed),
			"choices": {
				"card": func(_pct):
					return NRCard.rezzed(_pct),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var target_cost = NRCardRT.getv(target, "cost")
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, target, {
							"cause-card": card,
						})
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"prompt": str("Choose a runner card that costs ") + str(target_cost) + str(" or less to trash"),
							"choices": {
								"card": func(_pct):
									return (NRCard.installed(_pct) and NRCard.runner(_pct) and (NRCardRT.getv(_pct, "cost") <= target_cost)),
							},
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("trash ") + str(NRCardRT.getv(target, "title")),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRMoving.trash(state, side, eid, target),
						}, card, null))
				).call(),
		},
	}))
	NRCardDefs.defcard("Kingmaking", NRUtil.merge({
		"title": "Kingmaking",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, draw up to 3 cards. You may add 1 agenda worth 1 or less agenda points from HQ to your score area."
	}, (func():
		var add_abi = {
			"prompt": "Choose 1 agenda worth 1 or less points",
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			"async": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.agenda(_pct) and NRCard.in_hand(_pct) and (1 >= NRCardRT.getv(_pct, "agendapoints"))),
			},
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("add ") + str(NRCardRT.getv(target, "title")) + str(" from HQ to [their] score area"),
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
				NRWinning.check_win_by_agenda(state, side)
				return NREid.effect_completed(state, side, eid),
		}
		return {
			"on-score": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw_up_to(state, side, ne, card, 3)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, add_abi, card, null)),
			},
		}
	).call()))
	NRCardDefs.defcard("Labyrinthine Servers", NRUtil.merge({
		"title": "Labyrinthine Servers",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, place 2 power counters on it.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent the Runner from jacking out. The Runner cannot jack out for the remainder of this run."
	}, {
		"on-score": _agenda_counters_9(2, "power"),
		"prevention": [
			{
				"prevents": "jack-out",
				"type": "ability",
				"ability": {
					"cost": [NRPayment.to_c("power", 1)],
					"msg": "prevent the runner from jacking out for the remainder of this run",
					"condition": "active",
					"async": true,
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRPrevention.preventable(context),
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							prevent_jack_out(state, side, ne)
						, func(async_result):
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
							NREid.effect_completed(state, side, eid)),
				},
			}
		],
	}))
	NRCardDefs.defcard("Let Them Dream", NRUtil.merge({
		"title": "Let Them Dream",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 1,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, you may search HQ, R&D, or Archives for 1 agenda and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that agenda to HQ or the bottom of R&D.\nWhile this agenda is in the Runner’s score area, it is worth 1 less agenda point."
	}, {
		"on-score": NRCardRT.choose_one_helper(
			{
				"optional": true,
				"prompt": "Search for an Agenda from where?",
			},
			[
				{
					"option": "HQ",
					"ability": _find_ab_15("hq"),
				},
				{
					"option": "R&D",
					"ability": _find_ab_15("rd"),
				},
				{
					"option": "Archives",
					"ability": _find_ab_15("archives"),
				}
			]
		),
		"agendapoints-runner": func(state, side, eid, card, targets):
			return 1,
	}))
	NRCardDefs.defcard("License Acquisition", NRUtil.merge({
		"title": "License Acquisition",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, you may install and rez 1 asset or upgrade from HQ or Archives, ignoring all costs."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Choose an asset or upgrade to install from Archives or HQ",
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and (NRCard.asset(_pct) or NRCard.upgrade(_pct)) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("install and rez ") + str(NRCardRT.getv(target, "title")) + str(", ignoring all costs"),
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
						"install-state": "rezzed-no-cost",
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}
				),
		},
	}))
	NRCardDefs.defcard("Lightning Laboratory", NRUtil.merge({
		"title": "Lightning Laboratory",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, place 1 agenda counter on it.\nWhenever a run begins, you may remove 1 hosted agenda counter to rez up to 2 pieces of ice protecting the attacked server, ignoring all costs. When this turn ends, derez 2 pieces of ice protecting that server."
	}, {
		"on-score": _agenda_counters_9(1),
		"events": [
			{
				"event": "run",
				"async": true,
				"optional": {
					"prompt": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return str("Remove 1 hosted agenda counter to rez up to 2 pieces of ice protecting ") + str(NRServers.zone_to_name(NRCardRT.getv(context, "server"))) + str(", ignoring all costs?"),
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRCard.get_counters(card, "agenda")),
					"yes-ability": {
						"cost": [NRPayment.to_c("agenda", 1)],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
								var current_server = NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(state.data, "run"), "server"), 0)
								return NREngine.resolve_ability(state, side, eid, {
									"prompt": func(state, side, eid, card, targets):
										return str("Choose up to 2 pieces of ice protecting ") + str(NRServers.zone_to_name(current_server)),
									"waiting-prompt": true,
									"choices": {
										"card": func(_pct):
											return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct))) and ((NRCardRT.getv(NRCard.get_zone(_pct), 1) == current_server) or NRUtil.kw_eq(NRCardRT.getv(NRCard.get_zone(_pct), 1), current_server))),
										"max": 2,
									},
									"async": true,
									"cancel": {
										"effect": func(state, side, eid, card, targets):
											return NREngine.register_events(state, side, card, [_ice_derez_16(current_server)]),
									},
									"effect": func(state, side, eid, card, targets):
										NREngine.register_events(state, side, card, [_ice_derez_16(current_server)])
										return NRRezzing.rez_multiple_cards(
											state,
											side,
											eid,
											targets,
											{
												"ignore-cost": "all-costs",
												"msg-keys": {
													"include-cost-from-eid": eid,
												},
											}
										),
								}, card, null)
							).call(),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Longevity Serum", NRUtil.merge({
		"title": "Longevity Serum",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, trash any number of cards from HQ. Shuffle up to 3 cards from Archives into R&D.\nLimit 1 per deck."
	}, {
		"on-score": {
			"prompt": "Choose any number of cards in HQ to trash",
			"choices": {
				"max": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.count_of(NRCardRT.getv(corp, "hand")),
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"msg": {
				"public": func(state, side, eid, card, targets):
					return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ"),
				"corp": func(state, side, eid, card, targets):
					return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ (") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(")"),
			},
			"async": true,
			"cancel": {
				"msg": "decline trashing any cards from HQ",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return shuffle_into_rd_effect(state, side, eid, card, 3),
			},
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
						"unpreventable": true,
						"cause-card": card,
					})
				, func(async_result):
					shuffle_into_rd_effect(state, side, eid, card, 3)),
		},
	}))
	NRCardDefs.defcard("Lotus Haze", NRUtil.merge({
		"title": "Lotus Haze",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, place 3 agenda counters on it.\n<strong>Hosted agenda counter:</strong> Move 1 rezzed upgrade to the root of another server."
	}, {
		"on-score": _agenda_counters_9(3),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"prompt": "Choose an upgrade to move",
				"choices": {
					"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.upgrade(x)) and NRCardRT.truthy(NRCard.rezzed(x))),
				},
				"label": "Move a rezzed upgrade to the root of another server.",
				"waiting-prompt": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var to_move = target
						var zone = NRCardRT.getv(NRCard.get_zone(to_move), 1)
						var not_same_zone = func(zones):
							return NRCardRT.filter_list(zones, func(_pct):
								return (not ((_pct == NRServers.zone_to_name(zone)) or NRUtil.kw_eq(_pct, NRServers.zone_to_name(zone)))))
						var legal_zones_fn = (func():
							var f = NRCardRT.getv(NRCardDefs.card_def(to_move), "legal-zones")
							return func(zones):
								return f(state, side, eid, card, zones) if f != null and NRCardRT.truthy(f) else func(zones):
									return NRCardRT.as_array(zones)
						).call()
						var region = func(_pct):
							return NRCard.has_subtype(_pct, "Region")
						var region_restriction = func(zones):
							return (NRCardRT.filter_list(zones, func(_pct):
								return (func():
									var z = (func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRBoard.server_to_zone(state, _pct)))
									var content = state.get_in(["corp", "servers", z, "content"], null)
									return (not NRCardRT.truthy(NRCardRT.some_list(content, func(x): return NRCardRT.truthy(region.call(x) if region is Callable else region))))
						).call()) if region(target) else zones)
						var legal_moves = region_restriction(legal_zones_fn(not_same_zone(NRBoard.server_list(state))))
						return NREngine.resolve_ability(state, side, eid, ({
							"prompt": "Choose a server",
							"choices": func(state, side, eid, card, targets):
								return legal_moves,
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("move ") + str(NRCardRT.getv(to_move, "title")) + str(" to ") + str(target),
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (func():
									var c = NRMoving.move(state, side, to_move, (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["content"]))
									NREngine.unregister_events(state, side, to_move)
									return NREngine.register_default_events(state, side, c)
								).call(),
						} if NRCardRT.seq_of(legal_moves) else {
							"prompt": str("You have no legal moves for ") + str(NRCardRT.getv(to_move, "title")),
							"msg": func(state, side, eid, card, targets):
								return str("reveal that they have no legal moves for ") + str(NRCardRT.getv(to_move, "title")),
							"choices": ["OK"],
						}), card, null)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Luminal Transubstantiation", NRUtil.merge({
		"title": "Luminal Transubstantiation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, gain [click][click][click]. You cannot score agendas for the remainder of the turn.\nLimit 1 per deck."
	}, {
		"on-score": {
			"silent": true,
			"effect": func(state, side, eid, card, targets):
				NRGaining.gain_clicks(state, "corp", 3)
				return NRFlags.register_turn_flag(
					state,
					side,
					card,
					"can-score",
					func(state, side, card):
						return (func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score cards this turn due to Luminal Transubstantiation.", "warning"))
				),
		},
	}))
	NRCardDefs.defcard("Mandatory Seed Replacement", NRUtil.merge({
		"title": "Mandatory Seed Replacement",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Mandatory Seed Replacement, rearrange any number of ice protecting all servers."
	}, {
		"on-score": {
			"async": true,
			"msg": "rearrange any number of ice",
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _msr_17(), card, null),
		},
	}))
	NRCardDefs.defcard("Mandatory Upgrades", NRUtil.merge({
		"title": "Mandatory Upgrades",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 6,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "You have 1 additional [click] to spend each turn."
	}, {
		"move-zone": func(state, side, eid, card, targets):
			return ((func():
				NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain 1 addition [Click] per turn"))
				(NRGaining.gain_clicks(state, "corp", 1) if NRCardRT.truthy((("corp" == NRCardRT.getv(state.data, "active-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(state.data, "active-player")))) else null)
				NRGaining.gain(state, "corp", "click-per-turn", 1)
				return NREid.effect_completed(state, side, eid)
			).call() if (NRCard.in_scored(card) and (("corp" == NRCardRT.getv(card, "scored-side")) or NRUtil.kw_eq("corp", NRCardRT.getv(card, "scored-side")))) else NREid.effect_completed(state, side, eid)),
		"leave-play": func(state, side, eid, card, targets):
			return NRGaining.lose(state, "corp", "click", 1, "click-per-turn", 1),
	}))
	NRCardDefs.defcard("Market Research", NRUtil.merge({
		"title": "Market Research",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "If the Runner is tagged when you score Market Research, place 1 agenda counter on it.\nMarket Research is worth 1 additional agenda point while it has an agenda counter on it."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return _add_agenda_point_counters(state, side, eid, card, 1),
		},
		"agendapoints-corp": func(state, side, eid, card, targets):
			return (2 if NRCardRT.zero(NRCard.get_counters(card, "agenda")) else 3),
	}))
	NRCardDefs.defcard("Medical Breakthrough", NRUtil.merge({
		"title": "Medical Breakthrough",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "Lower the advancement requirement of each Medical Breakthrough by 1. This ability is active even while Medical Breakthrough is in the Runner's score area."
	}, {
		"flags": {
			"has-events-when-stolen": true,
		},
		"static-abilities": [
			{
				"type": "advancement-requirement",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return ((NRCardRT.getv(target, "title") == "Medical Breakthrough") or NRUtil.kw_eq(NRCardRT.getv(target, "title"), "Medical Breakthrough")),
				"value": -1,
			}
		],
	}))
	NRCardDefs.defcard("Méliès City Luxury Line", NRUtil.merge({
		"title": "Méliès City Luxury Line",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "As an additional cost to steal this agenda, the Runner must spend [click].\nWhen you score this agenda, gain [click]."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("click", 1)],
		"on-score": {
			"msg": "gain [Click]",
			"silent": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, "corp", 1),
		},
	}))
	NRCardDefs.defcard("Megaprix Qualifier", NRUtil.merge({
		"title": "Megaprix Qualifier",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"text": "When you score this agenda, if there is another copy of Megaprix Qualifier in either playerʼs score area, place 1 agenda counter on this agenda.\nWhile this agenda has a hosted agenda counter, it is worth 1 more agenda point."
	}, {
		"on-score": {
			"silent": true,
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				var corp = state.player("corp")
				return (1 < NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.concat_lists([NRCardRT.getv(corp, "scored"), NRCardRT.getv(runner, "scored")]), func(_pct):
					return ((NRCardRT.getv(_pct, "title") == "Megaprix Qualifier") or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), "Megaprix Qualifier"))))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return _add_agenda_point_counters(state, side, eid, card, 1),
		},
		"agendapoints-corp": func(state, side, eid, card, targets):
			return (1 if NRCardRT.zero(NRCard.get_counters(card, "agenda")) else 2),
	}))
	NRCardDefs.defcard("Merger", NRUtil.merge({
		"title": "Merger",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 1,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "Merger is worth 1 additional agenda point while in the Runner's score area."
	}, {
		"agendapoints-runner": func(state, side, eid, card, targets):
			return 3,
	}))
	NRCardDefs.defcard("Meteor Mining", NRUtil.merge({
		"title": "Meteor Mining",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 2,
		"factioncost": 0,
		"text": "When you score Meteor Mining, you may gain 7[credit]. If the Runner has at least 2 tags, you may do 7 meat damage instead."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
					"Gain 7 [Credits]",
					("Do 7 meat damage" if NRCardRT.truthy((count_tags(state) >= 2)) else null),
					"No action"
				],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return ((func():
					NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain 7 [Credits]"))
					return NRGaining.gain_credits(state, side, eid, 7)
				).call() if ((target == "Gain 7 [Credits]") or NRUtil.kw_eq(target, "Gain 7 [Credits]")) else ((func():
					NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to do 7 meat damage"))
					return NRDamage.damage(
						state,
						side,
						eid,
						"meat",
						7,
						{
							"card": card,
						}
					)
				).call() if ((target == "Do 7 meat damage") or NRUtil.kw_eq(target, "Do 7 meat damage")) else ((func():
					NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title")))
					return NREid.effect_completed(state, side, eid)
				).call() if ((target == "No action") or NRUtil.kw_eq(target, "No action")) else null))),
		},
	}))
	NRCardDefs.defcard("Midnight-3 Arcology", NRUtil.merge({
		"title": "Midnight-3 Arcology",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, draw 3 cards. Skip your discard step this turn."
	}, {
		"on-score": {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str("draw 3 cards and skip [their] discard step this turn"),
			"effect": func(state, side, eid, card, targets):
				NREffects.register_lingering_effect(
					state,
					side,
					card,
					{
						"type": "skip-discard",
						"duration": "end-of-turn",
						"value": true,
					}
				)
				return NRDrawing.draw(state, "corp", eid, 3),
		},
	}))
	NRCardDefs.defcard("NAPD Contract", NRUtil.merge({
		"title": "NAPD Contract",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "This agenda gets +1 advancement requirement for each bad publicity you have.\nAs an additional cost to steal this agenda, the Runner must pay 4[credit]."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("credit", 4)],
		"advancement-requirement": func(state, side, eid, card, targets):
			return count_bad_pub(state),
	}))
	NRCardDefs.defcard("Net Quarantine", NRUtil.merge({
		"title": "Net Quarantine",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "For the first trace each turn, the Runner's [link] is treated as 0. <em>(They can still increase their link strength by spending credits.)</em>\nWhenever the Runner spends credits to increase their link strength, gain 1[credit] for every 2[credit] they spent."
	}, (func():
		var nq = {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var extra = int((NRCardRT.getv(target, "runner-spent") / 2))
					return ((func():
						NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain ") + str(extra) + str(" [Credits]"))
						return NRGaining.gain_credits(state, side, eid, extra)
					).call() if NRCardRT.pos(extra) else NREid.effect_completed(state, side, eid))
				).call(),
		}
		return {
			"static-abilities": [
				{
					"type": "trace-force-link",
					"req": func(state, side, eid, card, targets):
						return ((1 == NRCardRT.count_of(NREvents.turn_events(state, side, "initialize-trace"))) or NRUtil.kw_eq(1, NRCardRT.count_of(NREvents.turn_events(state, side, "initialize-trace")))),
					"value": 0,
				}
			],
			"events": [
				NRUtil.merge(nq, {"event": "successful-trace"}),
				NRUtil.merge(nq, {"event": "unsuccessful-trace"})
			],
		}
	).call()))
	NRCardDefs.defcard("New Construction", NRUtil.merge({
		"title": "New Construction",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Public",
		"subtypes": ["Public"],
		"text": "Install only faceup. <em>(This agenda is neither rezzed nor unrezzed.)</em>\nWhenever you advance this agenda, you may install 1 card from HQ in the root of a new server. If there are 5 or more hosted advancement counters, rez that card, ignoring all costs."
	}, {
		"install-state": "face-up",
		"events": [
			{
				"event": "advance",
				"condition": "faceup",
				"optional": {
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRUtil.same_card(card, NRCardRT.getv(context, "card")),
					"prompt": "Install a card from HQ in a new remote?",
					"yes-ability": {
						"prompt": "Choose a card to install",
						"choices": {
							"card": func(_pct):
								return ((not NRCardRT.truthy(NRCard.operation(_pct))) and (not NRCardRT.truthy(NRCard.ice(_pct))) and NRCard.corp(_pct) and NRCard.in_hand(_pct)),
						},
						"msg": func(state, side, eid, card, targets):
							return str("install a card from HQ") + str((" and rez it, ignoring all costs" if NRCardRT.truthy((5 <= NRCard.get_counters(NRCard.get_card(state, card), "advancement"))) else null)),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRInstalling.corp_install(
								state,
								side,
								eid,
								target,
								"New remote",
								{
									"install-state": ("rezzed-no-cost" if NRCardRT.truthy((5 <= NRCard.get_counters(NRCard.get_card(state, card), "advancement"))) else null),
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								}
							),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Next Big Thing", NRUtil.merge({
		"title": "Next Big Thing",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When this agenda is scored or stolen, place 1 agenda counter on it.\n<strong>[click]</strong>, <strong>hosted agenda counter:</strong> Draw 4 cards. Shuffle any number of cards from HQ into R&D. The Corp can use this ability even if this agenda is in the Runner's score area."
	}, {
		"on-score": _agenda_counters_9(1),
		"stolen": _agenda_counters_9(1),
		"flags": {
			"has-abilities-when-stolen": true,
		},
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("agenda")],
				"label": "Draw 4 cards",
				"msg": "draw 4 cards",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					NRSay.play_sfx(state, side, "click-card-2")
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, side, ne, 4)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Shuffle any number of cards into R&D",
							"waiting-prompt": true,
							"choices": {
								"max": func(state, side, eid, card, targets):
									var corp = state.player("corp")
									return NRCardRT.count_of(NRCardRT.getv(corp, "hand")),
								"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.corp(x)) and NRCardRT.truthy(NRCard.in_hand(x))),
							},
							"msg": {
								"public": func(state, side, eid, card, targets):
									return str("shuffle ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ into R&D"),
								"corp": func(state, side, eid, card, targets):
									return str("shuffle ") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(" from HQ into R&D"),
							},
							"cancel": NRShuffling.shuffle_deck,
							"effect": func(state, side, eid, card, targets):
								(func():
									for t in NRCardRT.as_array(targets):
										NRMoving.move(state, side, t, "deck")
									return null
								).call()
								return NRShuffling.shuffle_zone(state, side, "deck"),
						}, card, null)),
			}
		],
	}))
	NRCardDefs.defcard("NEXT Wave 2", NRUtil.merge({
		"title": "NEXT Wave 2",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "NEXT",
		"subtypes": ["NEXT"],
		"text": "When you score this agenda, if there is a rezzed piece of <strong>NEXT</strong> ice, you may do 1 core damage."
	}, {
		"on-score": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, ({
					"optional": {
						"prompt": "Do 1 core damage?",
						"yes-ability": {
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
						},
					},
				} if NRCardRT.truthy(NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return (NRCard.rezzed(_pct) and NRCard.ice(_pct) and NRCard.has_subtype(_pct, "NEXT")))) else null), card, null),
		},
	}))
	NRCardDefs.defcard("Nisei MK II", NRUtil.merge({
		"title": "Nisei MK II",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> End the run."
	}, {
		"on-score": _agenda_counters_9(1),
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(state.data, "run"),
				"cost": [NRPayment.to_c("agenda", 1)],
				"msg": "end the run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRuns.end_run(state, side, eid, card),
			}
		],
	}))
	NRCardDefs.defcard("Oaktown Renovation", NRUtil.merge({
		"title": "Oaktown Renovation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Public - Initiative",
		"subtypes": ["Public", "Initiative"],
		"text": "Install only faceup. <em>(This agenda is neither rezzed nor unrezzed.)</em>\nWhenever you advance this agenda, gain 2[credit]. If there are 5 or more hosted advancement counters <em>(including the counter just placed)</em>, gain 3[credit] instead."
	}, {
		"install-state": "face-up",
		"events": [
			{
				"event": "advance",
				"condition": "faceup",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "card")),
				"msg": func(state, side, eid, card, targets):
					return str("gain ") + str(("3" if (NRCard.get_counters(NRCard.get_card(state, card), "advancement") >= 5) else "2")) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, (3 if (5 <= NRCard.get_counters(NRCard.get_card(state, card), "advancement")) else 2)),
			}
		],
	}))
	NRCardDefs.defcard("Obokata Protocol", NRUtil.merge({
		"title": "Obokata Protocol",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "As an additional cost to steal Obokata Protocol, the Runner must suffer 4 net damage."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("net", 4)],
	}))
	NRCardDefs.defcard("Offworld Office", NRUtil.merge({
		"title": "Offworld Office",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, gain 7[credit]."
	}, {
		"on-score": NRDefHelpers.gain_credits_ability(7),
	}))
	NRCardDefs.defcard("Off the Books", NRUtil.merge({
		"title": "Off the Books",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Dividends 1 <em>(When you score this agenda, place 1 agenda counter on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to search R&D for 1 card and reveal it. <em>(Shuffle R&D after searching it.)</em> You may install that card, ignoring all costs. If you do not, add it to HQ."
	}, _project_agenda(
		{
			"mode": "computed",
		}
	)))
	NRCardDefs.defcard("Ontological Dependence", NRUtil.merge({
		"title": "Ontological Dependence",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "This agenda gets -1 advancement requirement for each core damage the Runner has taken this game."
	}, {
		"advancement-requirement": func(state, side, eid, card, targets):
			return (-(state.get_in(["runner", "brain-damage"], null) or 0)),
	}))
	NRCardDefs.defcard("Oracle Thinktank", NRUtil.merge({
		"title": "Oracle Thinktank",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When the Runner steals this agenda, give them 1 tag.\n[click], <strong>remove 1 tag:</strong> Shuffle this agenda into R&D. The Corp can use this ability only if this agenda is in the Runner's score area."
	}, {
		"stolen": NRDefHelpers.give_tags(1),
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("tag", 1)],
				"req": func(state, side, eid, card, targets):
					return is_scored(state, "runner", card),
				"msg": "shuffle itself into R&D",
				"label": "Shuffle this agenda into R&D",
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, "corp", card, "deck", null)
					NRShuffling.shuffle_zone(state, "corp", "deck")
					return NRAgendas.update_all_agenda_points(state, side),
			}
		],
		"flags": {
			"has-abilities-when-stolen": true,
		},
	}))
	NRCardDefs.defcard("Orbital Superiority", NRUtil.merge({
		"title": "Orbital Superiority",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, if the Runner is tagged, do 4 meat damage; otherwise, give the Runner 1 tag."
	}, {
		"on-score": {
			"msg": func(state, side, eid, card, targets):
				return str(("do 4 meat damage" if NRUtil.is_tagged(state) else "give the Runner 1 tag")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NRDamage.damage(
					state,
					"corp",
					eid,
					"meat",
					4,
					{
						"card": card,
					}
				) if NRUtil.is_tagged(state) else NRTags.gain_tags(state, "corp", eid, 1)),
		},
	}))
	NRCardDefs.defcard("Paper Trail", NRUtil.merge({
		"title": "Paper Trail",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Paper Trail, Trace[6]. If successful, trash all <strong>connection</strong> and <strong>job</strong> resources."
	}, {
		"on-score": {
			"trace": {
				"base": 6,
				"successful": {
					"msg": "trash all connection and job resources",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
							var resources = NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
								return (NRCard.has_subtype(_pct, "Job") or NRCard.has_subtype(_pct, "Connection")))
							return NRMoving.trash_cards(
								state,
								side,
								eid,
								resources,
								{
									"cause-card": card,
								}
							)
						).call(),
				},
			},
		},
	}))
	NRCardDefs.defcard("Personality Profiles", NRUtil.merge({
		"title": "Personality Profiles",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "Whenever the Runner searches the stack or installs a card from the heap, they trash 1 card from the grip at random."
	}, (func():
		var pp = {
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return (func():
					var c = NRCardRT.getv(shuffle(NRCardRT.getv(runner, "hand")), 0)
					NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to force the Runner") + str(" to trash ") + str(NRCardRT.getv(c, "title")) + str(" from the grip at random"))
					return NRMoving.trash(
						state,
						side,
						eid,
						c,
						{
							"cause-card": card,
						}
					)
				).call(),
		}
		return {
			"events": [
				NRUtil.merge(pp, {"event": "searched-stack"}),
				NRUtil.merge(pp, {"event": "runner-install", "req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var runner = state.player("runner")
					return (NRCardRT.some_list(NRCardRT.getv(NRCardRT.getv(context, "card"), "previous-zone"), func(x): return NRCardRT.truthy(["discard"].call(x) if ["discard"] is Callable else ["discard"])) and NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))))})
			],
		}
	).call()))
	NRCardDefs.defcard("Philotic Entanglement", NRUtil.merge({
		"title": "Philotic Entanglement",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": true,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Philotic Entanglement, do 1 net damage for each agenda in the Runner's score area.\nLimit 1 Philotic Entanglement per deck."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "scored"))),
			"msg": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return str("do ") + str(NRCardRT.count_of(NRCardRT.getv(runner, "scored"))) + str(" net damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					NRCardRT.count_of(NRCardRT.getv(runner, "scored")),
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("Post-Truth Dividend", NRUtil.merge({
		"title": "Post-Truth Dividend",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, you may draw 1 card."
	}, {
		"on-score": {
			"optional": {
				"prompt": "Draw 1 card?",
				"yes-ability": {
					"msg": "draw 1 card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, side, eid, 1),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title"))),
				},
			},
		},
	}))
	NRCardDefs.defcard("Posted Bounty", NRUtil.merge({
		"title": "Posted Bounty",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security - Liability",
		"subtypes": ["Security", "Liability"],
		"text": "When you score this agenda, you may forfeit it. If you do, give the Runner 1 tag and take 1 bad publicity."
	}, {
		"on-score": {
			"optional": {
				"prompt": "Forfeit this agenda to give the Runner 1 tag and take 1 bad publicity?",
				"yes-ability": {
					"msg": "give the Runner 1 tag and take 1 bad publicity",
					"cost": [NRPayment.to_c("forfeit-self")],
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRBadPublicity.gain_bad_publicity(state, "corp", ne, 1, {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRTags.gain_tags(state, "corp", eid, 1)),
				},
			},
		},
	}))
	NRCardDefs.defcard("Priority Requisition", NRUtil.merge({
		"title": "Priority Requisition",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Priority Requisition, you may rez a piece of ice ignoring all costs."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"choices": {
				"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x))))),
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
					}
				),
		},
	}))
	NRCardDefs.defcard("Private Security Force", NRUtil.merge({
		"title": "Private Security Force",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "If the Runner is tagged, Private Security Force gains: \"[click]: Do 1 meat damage.\""
	}, {
		"abilities": [
			{
				"action": true,
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
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
				"msg": "do 1 meat damage",
			}
		],
	}))
	NRCardDefs.defcard("Profiteering", NRUtil.merge({
		"title": "Profiteering",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Liability",
		"subtypes": ["Liability"],
		"text": "When you score this agenda, take up to 3 bad publicity. Gain 5[credit] for each bad publicity taken this way."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"choices": ["0", "1", "2", "3"],
			"prompt": "How many bad publicity do you want to take?",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("take ") + str(target) + str(" bad publicity and gain ") + str((5 * str_to_int(target))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var bp = count_bad_pub(state)
					return NREid.wait_for(state, eid, func(ne):
						NRBadPublicity.gain_bad_publicity(state, "corp", ne, str_to_int(target))
					, func(async_result):
						(NRGaining.gain_credits(state, "corp", eid, (5 * str_to_int(target))) if (bp < count_bad_pub(state)) else NREid.effect_completed(state, side, eid)))
				).call(),
		},
	}))
	NRCardDefs.defcard("Project Ares", NRUtil.merge({
		"title": "Project Ares",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security - Liability",
		"subtypes": ["Security", "Liability"],
		"text": "When you score this agenda, the Runner trashes 1 of their installed cards for each hosted advancement counter past 4. If the Runner trashes at least 1 card this way, take 1 bad publicity."
	}, {
		"on-score": {
			"player": "runner",
			"silent": true,
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return (4 < NRCard.get_counters(NRCardRT.getv(context, "card"), "advancement")) and NRCardRT.pos(NRCardRT.count_of(NRBoard.all_installed(state, "runner"))),
			"waiting-prompt": true,
			"prompt": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return str("Choose ") + str(NRCardRT.quantify(_trash_count_str_18(NRCardRT.getv(context, "card")), "installed card")) + str(" to trash"),
			"choices": {
				"max": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return mini((NRCard.get_counters(NRCardRT.getv(context, "card"), "advancement") - 4), NRCardRT.count_of(NRBoard.all_installed(state, "runner"))),
				"card": func(_pct):
					return (NRCard.runner(_pct) and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return str("force the Runner to trash ") + str(_trash_count_str_18(NRCardRT.getv(context, "card"))) + str(" and take 1 bad publicity"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
						"cause-card": card,
						"cause": "forced-to-trash",
					})
				, func(async_result):
					NRSay.system_msg(state, side, str("trashes ") + str(NRCardRT.enumerate_cards(targets)))
					NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
		},
	}))
	NRCardDefs.defcard("Project Atlas", NRUtil.merge({
		"title": "Project Atlas",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, place 1 agenda counter on it for each hosted advancement counter past 3.\n<strong>Hosted agenda counter:</strong> Search R&D for 1 card and reveal it. Add it to HQ."
	}, _project_agenda()))
	NRCardDefs.defcard("Project Beale", NRUtil.merge({
		"title": "Project Beale",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, place 1 agenda counter on it for every 2 hosted advancement counters past 3.\nThis agenda is worth 1 more agenda point for each hosted agenda counter."
	}, _project_agenda(
		{
			"granularity": 2,
		}
	)))
	NRCardDefs.defcard("Project Ingatan", NRUtil.merge({
		"title": "Project Ingatan",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "Dividends 1 <em>(When you score this agenda, place 1 agenda counter on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to install 1 card from Archives, ignoring all costs."
	}, _project_agenda(
		{
			"mode": "computed",
		},
		{
			"events": [
				{
					"event": "corp-turn-ends",
					"cost": [NRPayment.to_c("agenda", 1)],
					"req": func(state, side, eid, card, targets):
						return NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("agenda", 1)]),
					"interactive": func(state, side, eid, card, targets):
						return true,
					"label": "Install a card from Archives",
					"prompt": "Install a card from Archives, ignoring all costs",
					"show-discard": true,
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
								return ((not NRCardRT.truthy(NRCardRT.getv(_pct, "seen"))) or (not NRCardRT.truthy(NRCard.operation(_pct))))),
					},
					"choices": {
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (not NRCardRT.truthy(NRCard.operation(target))) and NRCard.in_discard(target),
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
		}
	)))
	NRCardDefs.defcard("Project Kusanagi", NRUtil.merge({
		"title": "Project Kusanagi",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 0,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Project Kusanagi, place 1 agenda counter on it for each advancement token on it over 2.\n<strong>Hosted agenda counter:</strong> Choose 1 piece of ice to gain \"[subroutine] Do 1 net damage.\" after all its other subroutines for the remainder of this run."
	}, _project_agenda()))
	NRCardDefs.defcard("Project Vacheron", NRUtil.merge({
		"title": "Project Vacheron",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "[interrupt] → When this agenda would be added to the Runnerʼs score area from anywhere except Archives, instead it is added to their score area with 4 hosted agenda counters.\nWhile this agenda is in the Runnerʼs score area with 1 or more hosted agenda counters, it is worth 0 agenda points and gains “When the Runnerʼs turn begins, remove 1 hosted agenda counter.“"
	}, {
		"flags": {
			"has-events-when-stolen": true,
		},
		"agendapoints-runner": func(state, side, eid, card, targets):
			return (3 if (((NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 0) == "discard") or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 0), "discard")) or NRCardRT.zero(NRCard.get_counters(card, "agenda"))) else 0),
		"move-zone": func(state, side, eid, card, targets):
			return ((func():
				NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to place 4 agenda counters on itself"))
				return NRProps.add_counter(state, side, eid, NRCard.get_card(state, card), "agenda", 4, null)
			).call() if (NRCard.in_scored(card) and (("runner" == NRCardRT.getv(card, "scored-side")) or NRUtil.kw_eq("runner", NRCardRT.getv(card, "scored-side"))) and (not ((NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 0) == "discard") or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(card, "previous-zone"), 0), "discard")))) else NREid.effect_completed(state, side, eid)),
		"events": [
			{
				"event": "runner-turn-begins",
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCard.get_counters(card, "agenda")),
				"msg": func(state, side, eid, card, targets):
					return str("remove 1 agenda counter from ") + str(NRCardRT.getv(card, "title")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (NREid.wait_for(state, eid, func(ne):
						NRProps.add_counter(state, side, ne, card, "agenda", -1, null)
					, func(async_result):
						NRAgendas.update_all_agenda_points(state, side)
						(func():
							var card = NRCard.get_card(state, card)
							return ((func():
								var points = NRCard.get_agenda_points(card)
								return NRSay.system_msg(state, "runner", str("gains ") + str(NRCardRT.quantify(points, "agenda point")) + str(" from ") + str(NRCardRT.getv(card, "title")))
							).call() if NRCardRT.truthy(NRCardRT.zero(NRCard.get_counters(card, "agenda"))) else null)
						).call()
						NRWinning.check_win_by_agenda(state, side)
						NREid.effect_completed(state, side, eid)) if NRCardRT.pos(NRCard.get_counters(card, "agenda")) else NREid.effect_completed(state, side, eid)),
			}
		],
	}))
	NRCardDefs.defcard("Project Vitruvius", NRUtil.merge({
		"title": "Project Vitruvius",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, place 1 agenda counter on it for each hosted advancement counter past 3.\n<strong>Hosted agenda counter:</strong> Add 1 card from Archives to HQ."
	}, _project_agenda()))
	NRCardDefs.defcard("Project Wotan", NRUtil.merge({
		"title": "Project Wotan",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, place 3 agenda counters on it.\n<strong>Hosted agenda counter:</strong> The rezzed piece of <strong>bioroid</strong> ice the Runner is approaching gains \"[subroutine] End the run.\" after its other subroutines for the remainder of this run."
	}, {
		"on-score": _agenda_counters_9(3),
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					var current_ice = NRIce.get_current_ice(state)
					return current_ice and NRCard.rezzed(current_ice) and NRCard.has_subtype(current_ice, "Bioroid") and (("approach-ice" == NRCardRT.getv(run, "phase")) or NRUtil.kw_eq("approach-ice", NRCardRT.getv(run, "phase"))),
				"cost": [NRPayment.to_c("agenda", 1)],
				"keep-menu-open": "while-agenda-tokens-left",
				"msg": str("make the approached piece of Bioroid ice gain \"[Subroutine] End the run\"") + str("after all its other subroutines for the remainder of this run"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var current_ice = NRIce.get_current_ice(state)
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						(func():
							var card_target = current_ice
							return {
								"type": "additional-subroutines",
								"duration": "end-of-run",
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRUtil.same_card(target, card_target),
								"value": {
									"subroutines": [
										{
											"label": "End the run",
											"msg": "end the run",
											"async": true,
											"effect": func(state, side, eid, card, targets):
												return NRRuns.end_run(state, side, eid, card),
										}
									],
								},
							}
						).call()
					),
			}
		],
	}))
	NRCardDefs.defcard("Project Yagi-Uda", NRUtil.merge({
		"title": "Project Yagi-Uda",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, place 1 agenda counter on it for each hosted advancement counter past 3.\n<strong>Hosted agenda counter:</strong> Swap 1 card from HQ with 1 card in the root of or protecting the attacked server. The Runner may jack out. Use this ability only during a run."
	}, _project_agenda(
		{
			"abilities": [
				{
					"async": true,
					"waiting-prompt": true,
					"fake-cost": [NRPayment.to_c("agenda", 1)],
					"keep-menu-open": false,
					"label": "swap card in HQ with installed card",
					"req": func(state, side, eid, card, targets):
						var run = state.getv("run")
						return run and NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("agenda", 1)]),
					"effect": func(state, side, eid, card, targets):
						var run = state.getv("run")
						return NREngine.resolve_ability(state, side, eid, _choose_card_20(NRCardRT.getv(run, "server")), card, null),
				}
			],
		}
	)))
	NRCardDefs.defcard("Puppet Master", NRUtil.merge({
		"title": "Puppet Master",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Whenever the Runner makes a successful run, you may place 1 advancement token on a card that can be advanced."
	}, {
		"events": [
			{
				"event": "successful-run",
				"skippable": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"waiting-prompt": true,
				"prompt": "Choose a card that can be advanced to place 1 advancement counter on",
				"choices": {
					"req": func(state, side, eid, card, targets):
						return NRCard.can_be_advanced(state, card),
				},
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRProps.add_prop(
						state,
						"corp",
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
	NRCardDefs.defcard("Proprionegation", NRUtil.merge({
		"title": "Proprionegation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> The Runner moves to the outermost position of Archives. <em>(They approach any ice in that position.)</em> Use this ability only during a run."
	}, {
		"on-score": {
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "agenda", 1),
		},
		"abilities": [
			{
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(state.data, "run"),
				"cost": [NRPayment.to_c("agenda", 1)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return (not (("success" == NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")) or NRUtil.kw_eq("success", NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")))),
				},
				"label": "Redirect runner to archives",
				"msg": "make the Runner continue the run on Archives",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return ((func():
						NRRuns.redirect_run(state, side, "Archives", "approach-ice")
						return NREid.effect_completed(state, side, eid)
					).call() if NRCardRT.truthy(NRCardRT.getv(state.data, "forced-encounter")) else ((func():
						(NREngine.queue_event(
							state,
							"end-of-encounter",
							{
								"ice": NRIce.get_current_ice(state),
							}
						) if NRCardRT.truthy(NRRuns.get_current_encounter(state)) else null)
						return NREid.wait_for(state, eid, func(ne):
							NREngine.checkpoint(state, side, ne, {
								"duration": "end-of-encounter",
							})
						, func(async_result):
							NRRuns.clear_encounter(state)
							NRRuns.redirect_run(state, side, "Archives", "approach-ice")
							NRRuns.start_next_phase(state, side, eid))
					).call() if NRCardRT.truthy((("encounter-ice" == NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")) or NRUtil.kw_eq("encounter-ice", NRCardRT.getv(NRCardRT.getv(state.data, "run"), "phase")))) else (func():
						NRRuns.clear_encounter(state)
						NRRuns.redirect_run(state, side, "Archives", "approach-ice")
						return NRRuns.start_next_phase(state, side, eid)
					).call())),
			}
		],
	}))
	NRCardDefs.defcard("Quantum Predictive Model", NRUtil.merge({
		"title": "Quantum Predictive Model",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda while they are tagged, add it to your score area."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"player": "runner",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Quantum Predictive Model will be added to the Corp's score area",
			"choices": ["OK"],
			"msg": func(state, side, eid, card, targets):
				return str("add itself to [their] score area and gain 1 agenda point"),
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(
					state,
					"corp",
					card,
					"scored",
					{
						"force": true,
					}
				)
				NRAgendas.update_all_agenda_points(state, side)
				return NRWinning.check_win_by_agenda(state, side),
		},
	}))
	NRCardDefs.defcard("Rebranding Team", NRUtil.merge({
		"title": "Rebranding Team",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "All assets gain <strong>advertisement</strong>."
	}, {
		"move-zone": func(state, side, eid, card, targets):
			(NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to make all assets gain Advertisement")) if NRCardRT.truthy((NRCard.in_scored(card) and (("corp" == NRCardRT.getv(card, "scored-side")) or NRUtil.kw_eq("corp", NRCardRT.getv(card, "scored-side"))))) else null)
			return NREid.effect_completed(state, side, eid),
		"static-abilities": [
			{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.asset(target),
				"value": "Advertisement",
			}
		],
	}))
	NRCardDefs.defcard("Reeducation", NRUtil.merge({
		"title": "Reeducation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, add any number of cards from HQ to the bottom of R&D. Draw X cards, where X is equal to the number of cards you added to R&D this way. If the Runner has at least X cards in the grip, they add X cards from the grip to the bottom of the stack at random."
	}, {
		"on-score": {
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
					var from = state.get_in(["corp", "hand"], null)
					return (NREngine.resolve_ability(state, "corp", eid, _corp_choice_22(from, null, from), card, null) if NRCardRT.pos(NRCardRT.count_of(from)) else (func():
						NRSay.system_msg(state, side, "does not add any cards from HQ to bottom of R&D")
						return NREid.effect_completed(state, side, eid)
					).call())
				).call(),
		},
	}))
	NRCardDefs.defcard("Regenesis", NRUtil.merge({
		"title": "Regenesis",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score this agenda, if no Corp cards have been added to Archives this turn, you may reveal 1 facedown agenda in Archives and add it to your score area."
	}, {
		"on-score": {
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				var corp = state.player("corp")
				return NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
					return (not NRCardRT.truthy(NRCard.faceup(_pct)))) and NREvents.no_event(
					state,
					side,
					"card-moved",
					func(__vec______sym____context____):
						return (NRCard.in_discard(NRCardRT.getv(context, "moved-card")) and NRCard.corp(NRCardRT.getv(context, "moved-card")))
				),
			"prompt": "Choose a face-down agenda in Archives",
			"choices": {
				"card": func(_pct):
					return (NRCard.agenda(_pct) and NRCard.in_discard(_pct) and (not NRCardRT.truthy(NRCard.faceup(_pct)))),
			},
			"show-discard": true,
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str("reveal ") + str(NRCardRT.getv(NRCardRT.getv(targets, 0), "title")) + str(" and add it to [their] score area"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, target)
				, func(async_result):
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
					NRWinning.check_win_by_agenda(state, side)
					NREid.effect_completed(state, side, eid)),
		},
	}))
	NRCardDefs.defcard("Regulatory Capture", NRUtil.merge({
		"title": "Regulatory Capture",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 6,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "For each bad publicity you have up to 4, this agenda gets −1 advancement requirement."
	}, {
		"advancement-requirement": func(state, side, eid, card, targets):
			return (-mini(4, count_bad_pub(state))),
	}))
	NRCardDefs.defcard("Remastered Edition", NRUtil.merge({
		"title": "Remastered Edition",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> Place 1 advancement counter on an installed card."
	}, {
		"on-score": _agenda_counters_9(1),
		"abilities": [NRUtil.merge(place_advancement_counter(null, 1), {"cost": [NRPayment.to_c("agenda", 1)]})],
	}))
	NRCardDefs.defcard("Remote Data Farm", NRUtil.merge({
		"title": "Remote Data Farm",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "Your maximum hand size is increased by 2."
	}, {
		"move-zone": func(state, side, eid, card, targets):
			(NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to increase [their] maximum hand size by 2")) if NRCardRT.truthy((NRCard.in_scored(card) and (("corp" == NRCardRT.getv(card, "scored-side")) or NRUtil.kw_eq("corp", NRCardRT.getv(card, "scored-side"))))) else null)
			return NREid.effect_completed(state, side, eid),
		"static-abilities": [NRHandSize.corp_hand_size_plus(2)],
	}))
	NRCardDefs.defcard("Remote Enforcement", NRUtil.merge({
		"title": "Remote Enforcement",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Remote Enforcement, you may search R&D for a piece of ice, install it protecting a remote server (paying its install cost), and rez it, ignoring its rez cost, then shuffle R&D."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Search R&D for a piece of ice to install protecting a remote server?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						var corp = state.player("corp")
						return NREngine.resolve_ability(state, side, eid, ({
							"async": true,
							"prompt": "Choose a piece of ice",
							"choices": func(state, side, eid, card, targets):
								var corp = state.player("corp")
								return NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice),
							"cancel": NRShuffling.shuffle_deck,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREngine.resolve_ability(state, side, eid, (func():
									var chosen_ice = target
									return {
										"async": true,
										"prompt": str("Choose a server to install ") + str(NRCardRT.getv(chosen_ice, "title")) + str(" on"),
										"choices": NRCardRT.filter_list(NRBoard.installable_servers(state, chosen_ice), func(_pct):
											return (not NRCardRT.truthy(["HQ", "Archives", "R&D"](_pct)))),
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											NRShuffling.shuffle_zone(state, side, "deck")
											return NRInstalling.corp_install(
												state,
												side,
												eid,
												chosen_ice,
												target,
												{
													"install-state": "rezzed-no-rez-cost",
													"msg-keys": {
														"install-source": card,
														"display-origin": true,
													},
												}
											),
									}
								).call(), card, null),
						} if NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice)) else {
							"prompt": "You have no ice in R&D",
							"choices": ["Carry on!"],
							"prompt-type": "bogus",
							"msg": "shuffle R&D",
							"effect": func(state, side, eid, card, targets):
								return NRShuffling.shuffle_zone(state, side, "deck"),
						}), card, null),
				},
			},
		},
	}))
	NRCardDefs.defcard("Research Grant", NRUtil.merge({
		"title": "Research Grant",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score Research Grant, you may score another copy of Research Grant that is installed."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"silent": func(state, side, eid, card, targets):
				return NRCardRT.empty_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return ((NRCardRT.getv(_pct, "title") == NRCardRT.getv(card, "title")) or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), NRCardRT.getv(card, "title"))))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, {
					"prompt": str("Choose another installed copy of ") + str(NRCardRT.getv(card, "title")) + str(" to score"),
					"choices": {
						"card": func(_pct):
							return ((NRCardRT.getv(_pct, "title") == NRCardRT.getv(card, "title")) or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), NRCardRT.getv(card, "title"))),
					},
					"interactive": func(state, side, eid, card, targets):
						return true,
					"async": true,
					"req": func(state, side, eid, card, targets):
						return NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return ((NRCardRT.getv(_pct, "title") == NRCardRT.getv(card, "title")) or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), NRCardRT.getv(card, "title"))))),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRAgendas.score(
							state,
							side,
							eid,
							NRCard.get_card(state, target),
							{
								"no-req": true,
							}
						),
					"msg": "score another installed copy of itself",
				}, card, null),
		},
	}))
	NRCardDefs.defcard("Restructured Datapool", NRUtil.merge({
		"title": "Restructured Datapool",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "[click]: Trace[2]. If successful, give the Runner 1 tag."
	}, {
		"abilities": [
			{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"label": "give runner 1 tag",
				"keep-menu-open": "while-clicks-left",
				"trace": {
					"base": 2,
					"successful": NRDefHelpers.give_tags(1),
				},
			}
		],
	}))
	NRCardDefs.defcard("Sacrifice Zone Expansion", NRUtil.merge({
		"title": "Sacrifice Zone Expansion",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Public - Expansion",
		"subtypes": ["Public", "Expansion"],
		"text": "Install only faceup. <em>(This agenda is neither rezzed nor unrezzed.)</em>\nThe first time each turn you advance this agenda, gain 3[credit].\nOnce per turn → When the Runner makes a successful run on another server, you may remove 1 hosted advancement counter to do 1 meat damage."
	}, {
		"install-state": "face-up",
		"events": [
			{
				"event": "advance",
				"condition": "faceup",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "card")) and NREvents.first_event(
						state,
						side,
						"advance",
						func(_pct):
							return NRUtil.same_card(card, NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
					),
				"msg": func(state, side, eid, card, targets):
					return str("gain 3 [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 3),
			},
			{
				"event": "successful-run",
				"condition": "faceup",
				"optional": {
					"prompt": "Do 1 meat damage?",
					"once": "per-turn",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return NRCard.installed(card) and (not ((NRServers.target_server(context) == NRCardRT.getv(NRCard.get_zone(card), 1)) or NRUtil.kw_eq(NRServers.target_server(context), NRCardRT.getv(NRCard.get_zone(card), 1)))) and NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("advancement", 1)]),
					"yes-ability": {
						"cost": [NRPayment.to_c("advancement", 1)],
						"msg": "do 1 meat damage",
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(state, side, eid, "meat", 1),
						"async": true,
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Salvo Testing", NRUtil.merge({
		"title": "Salvo Testing",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "Whenever you score an agenda <em>(including this one)</em>, you may do 1 core damage."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"prompt": "Do 1 core damage?",
					"waiting-prompt": true,
					"yes-ability": {
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
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("SDS Drone Deployment", NRUtil.merge({
		"title": "SDS Drone Deployment",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "As an additional cost to steal this agenda, the Runner must trash 1 installed program.\nWhen you score this agenda, trash 1 installed program."
	}, {
		"steal-cost-bonus": func(state, side, eid, card, targets):
			return [NRPayment.to_c("program", 1)],
		"on-score": {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.seq_of(all_installed_runner_type(state, "program")),
			"waiting-prompt": true,
			"prompt": "Choose a program to trash",
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.program(_pct)),
				"all": true,
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
						"cause-card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("See How They Run", NRUtil.merge({
		"title": "See How They Run",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Psi - Security",
		"subtypes": ["Psi", "Security"],
		"text": "When you score this agenda, give the Runner 1 tag. Play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, do 1 core damage. If the bids match, do 1 net damage."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "give the runner 1 tag",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRTags.gain_tags(state, "runner", ne, 1)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"msg": "start a psi game (do 1 core damage / do 1 net damage)",
						"psi": {
							"not-equal": {
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
							},
							"equal": {
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
							},
						},
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Self-Destruct Chips", NRUtil.merge({
		"title": "Self-Destruct Chips",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "The Runner's maximum hand size is reduced by 1."
	}, {
		"move-zone": func(state, side, eid, card, targets):
			(NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to decrease the Runner's maximum hand size by 1")) if NRCardRT.truthy((NRCard.in_scored(card) and (("corp" == NRCardRT.getv(card, "scored-side")) or NRUtil.kw_eq("corp", NRCardRT.getv(card, "scored-side"))))) else null)
			return NREid.effect_completed(state, side, eid),
		"static-abilities": [NRHandSize.runner_hand_size_plus(-1)],
	}))
	NRCardDefs.defcard("Send a Message", NRUtil.merge({
		"title": "Send a Message",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When this agenda is scored or stolen, you may rez 1 installed piece of ice, ignoring all costs."
	}, (func():
		var ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct))) and NRCard.installed(_pct)),
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
					}
				),
		}
		return {
			"on-score": ability,
			"stolen": ability,
		}
	).call()))
	NRCardDefs.defcard("Sensor Net Activation", NRUtil.merge({
		"title": "Sensor Net Activation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "Place 1 agenda counter on Sensor Net Activation when you score it.\n<strong>Hosted agenda counter:</strong> Rez a <strong>bioroid</strong>, ignoring all costs. When the turn ends, derez that <strong>bioroid</strong>."
	}, {
		"on-score": _agenda_counters_9(1),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return (NRCard.has_subtype(_pct, "Bioroid") and (not NRCardRT.truthy(NRCard.rezzed(_pct))))),
				"label": "Choose a bioroid to rez, ignoring all costs",
				"prompt": "Choose a bioroid to rez, ignoring all costs",
				"choices": {
					"card": func(_pct):
						return (NRCard.has_subtype(_pct, "Bioroid") and (not NRCardRT.truthy(NRCard.rezzed(_pct)))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRezzing.rez(state, side, ne, target, {
							"ignore-cost": "all-costs",
							"msg-keys": {
								"include-cost-from-eid": eid,
							},
						})
					, func(async_result):
						(func():
							var ev = ("corp-turn-ends" if ((NRCardRT.getv(state.data, "active-player") == "corp") or NRUtil.kw_eq(NRCardRT.getv(state.data, "active-player"), "corp")) else "runner-turn-ends")
							NREngine.register_events(
								state,
								side,
								card,
								[
									{
										"event": ev,
										"unregister-once-resolved": true,
										"duration": "end-of-turn",
										"async": true,
										"effect": func(state, side, eid, card, targets):
											return NRRezzing.derez(state, side, eid, c),
									}
								]
							)
							return NREid.effect_completed(state, side, eid)
						).call()),
			}
		],
	}))
	NRCardDefs.defcard("Sentinel Defense Program", NRUtil.merge({
		"title": "Sentinel Defense Program",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "Whenever the Runner suffers at least 1 core damage, do 1 net damage."
	}, {
		"events": [
			{
				"event": "damage",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCardRT.pos(NRCardRT.getv(context, "amount")) and ((NRCardRT.getv(context, "damage-type") == "brain") or NRUtil.kw_eq(NRCardRT.getv(context, "damage-type"), "brain")),
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
	NRCardDefs.defcard("Sericulture Expansion", NRUtil.merge({
		"title": "Sericulture Expansion",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "Dividends 1 <em>(When you score this agenda, place 1 agenda counter on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to place 2 advancement counters on 1 installed card. <em>(You cannot score that card this turn.)</em>"
	}, _project_agenda(
		{
			"mode": "computed",
		}
	)))
	NRCardDefs.defcard("Show of Force", NRUtil.merge({
		"title": "Show of Force",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Show of Force, do 2 meat damage."
	}, {
		"on-score": {
			"async": true,
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
	}))
	NRCardDefs.defcard("Sisyphus Protocol", NRUtil.merge({
		"title": "Sisyphus Protocol",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "The first time each turn the Runner passes a rezzed <strong>code gate</strong> or <strong>sentry</strong>, you may pay 1[credit] or trash 1 card from HQ. If you do, the Runner encounters that ice again."
	}, {
		"events": [
			{
				"event": "pass-ice",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return _rezzed_gate_or_sentry_23(context) and NREvents.first_event(
						state,
						side,
						"pass-ice",
						func(_pct):
							return _rezzed_gate_or_sentry_23(NRCardRT.getv(_pct, 0))
					),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					return (func():
						var enc_ice = NRCard.get_card(state, NRCardRT.getv(context, "ice"))
						return NREngine.resolve_ability(state, side, eid, {
							"prompt": func(state, side, eid, card, targets):
								var context = NRCardRT.ctx(targets)
								return str("Make the runner encounter ") + str(NRCardRT.getv(NRCardRT.getv(context, "ice"), "title")) + str(" again?"),
							"choices": func(state, side, eid, card, targets):
								return [
									("Pay 1 [Credit]" if NRCardRT.truthy(NRPayment.can_pay(state, "corp", eid, card, null, NRPayment.to_c("credit", 1))) else null),
									("Trash 1 card from HQ" if NRCardRT.truthy(NRPayment.can_pay(state, "corp", eid, card, null, NRPayment.to_c("trash-from-hand", 1))) else null),
									"Done"
								],
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (NREid.effect_completed(state, side, eid) if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NREngine.resolve_ability(state, side, eid, {
									"cost": (NRPayment.to_c("credit", 1) if ((target == "Pay 1 [Credit]") or NRUtil.kw_eq(target, "Pay 1 [Credit]")) else NRPayment.to_c("trash-from-hand", 1)),
									"change-in-game-state": {
										"req": func(state, side, eid, card, targets):
											return enc_ice and NRCard.rezzed(enc_ice),
									},
									"msg": func(state, side, eid, card, targets):
										return str("make the runner encounter ") + str(NRToString.card_str(state, enc_ice)) + str(" again"),
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NRRuns.force_ice_encounter(state, side, eid, enc_ice),
								}, card, null)),
						}, card, targets)
					).call(),
			}
		],
	}))
	NRCardDefs.defcard("Slash and Burn Agriculture", NRUtil.merge({
		"title": "Slash and Burn Agriculture",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Expansion - Expendable",
		"subtypes": ["Expansion", "Expendable"],
		"text": "[click], <strong>1</strong>[credit], <strong>reveal and trash this agenda from HQ:</strong> Place 2 advancement counters on 1 installed card that you can advance."
	}, {
		"expend": NRUtil.merge(place_advancement_counter(true, 2), {"cost": [NRPayment.to_c("credit", 1)]}),
	}))
	NRCardDefs.defcard("SSL Endorsement", NRUtil.merge({
		"title": "SSL Endorsement",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When this agenda is scored or stolen, place 9[credit] on it.\nWhen the Corp's turn begins, they may take 3[credit] from this agenda. This ability is active even while this agenda is in the Runner's score area."
	}, {
		"flags": {
			"has-events-when-stolen": true,
		},
		"abilities": [NRCardRT.set_autoresolve("auto-fire", "SSL Endorsement")],
		"stolen": _agenda_counters_9(9, "credit"),
		"on-score": _agenda_counters_9(9, "credit"),
		"events": [
			{
				"event": "corp-turn-begins",
				"automatic": "gain-credits",
				"optional": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRCard.get_counters(card, "credit")),
					"once": "per-turn",
					"prompt": "Gain 3 [Credits]?",
					"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
					"yes-ability": {
						"async": true,
						"msg": func(state, side, eid, card, targets):
							return str("gain ") + str(mini(3, NRCard.get_counters(card, "credit"))) + str(" [Credits]"),
						"effect": func(state, side, eid, card, targets):
							return (NRDefHelpers.take_credits(state, side, eid, card, "credit", 3) if NRCardRT.pos(NRCard.get_counters(card, "credit")) else NREid.effect_completed(state, side, eid)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Standoff", NRUtil.merge({
		"title": "Standoff",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 2,
		"agendapoints": 0,
		"factioncost": 0,
		"text": "When you score this agenda, the Runner may trash 1 of their installed cards. If they do not, draw 1 card and gain 5[credit]. Otherwise, you may trash 1 of your installed cards to repeat this process."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRPrompts.show_wait_prompt(state, side, str(NRUtil.side_str(NRUtil.other_side(side))) + str(" to trash a card for Standoff"))
				return NREngine.resolve_ability(state, "runner", eid, _stand_24("runner"), card, null),
		},
	}))
	NRCardDefs.defcard("Stegodon MK IV", NRUtil.merge({
		"title": "Stegodon MK IV",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "Each run, as long as a piece of ice has been derezzed during that run, each installed <strong>icebreaker</strong> gets –2 strength.\nOnce per turn → When a run begins, you may derez 1 piece of ice not protecting the attacked server to gain 1[credit]."
	}, {
		"events": [
			{
				"event": "run",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (func():
						var rezzed_targets = NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_installed_corp(state), func(_pct):
							return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and (not ((NRCardRT.getv(NRCardRT.getv(target, "server"), 0) == NRCardRT.getv(NRCard.get_zone(_pct), 1)) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(target, "server"), 0), NRCardRT.getv(NRCard.get_zone(_pct), 1)))))))
						return NREngine.resolve_ability(state, side, eid, ({
							"prompt": "Choose a piece of ice protecting another server to derez",
							"waiting-prompt": true,
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCardRT.some_list(rezzed_targets, func(x): return NRCardRT.truthy([target].call(x) if [target] is Callable else [target])),
							},
							"once": "per-turn",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRRezzing.derez(state, side, ne, target, {
										"msg-keys": {
											"and-then": " and gain 1 [Credits]",
										},
									})
								, func(async_result):
									NRGaining.gain_credits(state, side, eid, 1)),
						} if NRCardRT.truthy(rezzed_targets) else null), card, null)
					).call(),
			},
			{
				"event": "derez",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					return run and NREvents.first_run_event(
						state,
						side,
						"derez",
						func(__vec______sym____context____):
							return NRCardRT.some_list(NRCardRT.getv(context, "cards"), NRCard.ice)
					),
				"msg": "lower strength of each installed icebreaker by 2",
			}
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRIce.update_all_icebreakers(state, side),
		"static-abilities": [
			{
				"type": "breaker-strength",
				"value": -2,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var context = NRCardRT.ctx(targets)
					var run = state.getv("run")
					return run and NRCard.has_subtype(target, "Icebreaker") and (1 <= NREvents.run_event_count(
						state,
						side,
						"derez",
						func(__vec______sym____context____):
							return NRCardRT.some_list(NRCardRT.getv(context, "cards"), NRCard.ice)
					)),
			}
		],
	}))
	NRCardDefs.defcard("Sting!", NRUtil.merge({
		"title": "Sting!",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "When a player scores or steals this agenda, do X net damage. X is equal to 1 plus the number of copies of Sting! in the other playerʼs score area."
	}, {
		"on-score": {
			"msg": func(state, side, eid, card, targets):
				return str("deal ") + str((int(_count_opp_stings_25(state, "corp")) + 1)) + str(" net damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					(int(_count_opp_stings_25(state, "corp")) + 1),
					{
						"card": card,
					}
				),
		},
		"stolen": {
			"msg": func(state, side, eid, card, targets):
				return str("deal ") + str((int(_count_opp_stings_25(state, "runner")) + 1)) + str(" net damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					(int(_count_opp_stings_25(state, "runner")) + 1),
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("Stoke the Embers", NRUtil.merge({
		"title": "Stoke the Embers",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, gain 3[credit] and place 1 advancement counter on an installed card.\nWhen you install this agenda from anywhere except HQ, you may reveal it. If you do, gain 2[credit] and place 1 advancement counter on an installed card."
	}, {
		"on-score": _score_abi_26(3),
		"derezzed-events": [
			{
				"event": "corp-install",
				"optional": {
					"prompt": "Reveal this agenda to gain 2 [Credits] and place 1 advancement counter on an installed card?",
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (not ((["hand"] == NRCardRT.getv(card, "previous-zone")) or NRUtil.kw_eq(["hand"], NRCardRT.getv(card, "previous-zone")))) and NRUtil.same_card(NRCardRT.getv(target, "card"), card),
					"yes-ability": {
						"msg": func(state, side, eid, card, targets):
							return str("reveal itself from ") + str(NRServers.zone_to_name(NRCardRT.getv(card, "previous-zone"))),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, card)
							, func(async_result):
								NREngine.resolve_ability(state, side, eid, _score_abi_26(2), NRCard.get_card(state, card), null)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Successful Field Test", NRUtil.merge({
		"title": "Successful Field Test",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "When you score Successful Field Test, install any number of cards from HQ, ignoring all costs."
	}, {
		"on-score": {
			"async": true,
			"msg": "install cards from HQ, ignoring all costs",
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (func():
					var max_ops = NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), (func(x): return not NRCardRT.truthy(NRCard.operation(x)))))
					return NREngine.resolve_ability(state, side, eid, _sft_27(1, max_ops), card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("Superconducting Hub", NRUtil.merge({
		"title": "Superconducting Hub",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Expansion",
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, you may draw 2 cards.\nYou get +2 maximum hand size."
	}, {
		"static-abilities": [
			{
				"type": "hand-size",
				"req": func(state, side, eid, card, targets):
					return (("corp" == side) or NRUtil.kw_eq("corp", side)),
				"value": 2,
			}
		],
		"on-score": {
			"optional": {
				"prompt": "Draw 2 cards?",
				"yes-ability": {
					"msg": "draw 2 cards",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, "corp", eid, 2),
				},
			},
		},
	}))
	NRCardDefs.defcard("Superior Cyberwalls", NRUtil.merge({
		"title": "Superior Cyberwalls",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "All <strong>barrier</strong> ice have +1 strength.\nWhen you score Superior Cyberwalls, gain 1[credit] for each rezzed <strong>barrier</strong>."
	}, _ice_boost_agenda("Barrier")))
	NRCardDefs.defcard("TGTBT", NRUtil.merge({
		"title": "TGTBT",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda, give them 1 tag."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": NRDefHelpers.give_tags(1),
	}))
	NRCardDefs.defcard("The Cleaners", NRUtil.merge({
		"title": "The Cleaners",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "[interrupt] → Whenever you would do meat damage, increase that damage by 1."
	}, {
		"prevention": [
			{
				"prevents": "pre-damage",
				"type": "event",
				"max-uses": 1,
				"mandatory": true,
				"ability": {
					"async": true,
					"condition": "active",
					"req": func(state, side, eid, card, targets):
						var context = NRCardRT.ctx(targets)
						return (("meat" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("meat", NRCardRT.getv(context, "type"))) and (not (("all" == NRCardRT.getv(context, "prevented")) or NRUtil.kw_eq("all", NRCardRT.getv(context, "prevented")))) and (("corp" == NRCardRT.getv(context, "source-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(context, "source-player"))) and (not NRCardRT.truthy(NRCardRT.getv(context, "unboostable"))),
					"msg": "increase the pending meat damage by 1",
					"effect": func(state, side, eid, card, targets):
						return damage_boost(state, side, eid, 1),
				},
			}
		],
	}))
	NRCardDefs.defcard("The Future is Now", NRUtil.merge({
		"title": "The Future is Now",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score The Future is Now, search R&D for a card and add it to HQ. Shuffle R&D."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Choose a card to add to HQ",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.getv(corp, "deck"),
			"msg": "add a card from R&D to HQ and shuffle R&D",
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "deck"))),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRMoving.move(state, side, target, "hand"),
		},
	}))
	NRCardDefs.defcard("The Future Perfect", NRUtil.merge({
		"title": "The Future Perfect",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative - Psi",
		"subtypes": ["Initiative", "Psi"],
		"text": "When the Runner accesses this agenda while it is not installed, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, the Runner cannot steal this agenda during this access."
	}, {
		"flags": {
			"rd-reveal": func(state, side, eid, card, targets):
				return true,
		},
		"on-access": {
			"psi": {
				"req": func(state, side, eid, card, targets):
					var installed = NRCard.installed(card) if card is Dictionary else false
					return (not NRCardRT.truthy(installed)),
				"not-equal": {
					"msg": "prevent itself from being stolen",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRFlags.register_run_flag(
							state,
							side,
							card,
							"can-steal",
							func(_, _, c):
								return (not NRCardRT.truthy(NRUtil.same_card(c, card)))
						)
						return NREid.effect_completed(state, side, eid),
				},
			},
		},
	}))
	NRCardDefs.defcard("Timely Public Release", NRUtil.merge({
		"title": "Timely Public Release",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter</strong>: Install 1 piece of ice from HQ or Archives in any position protecting a server, ignoring all costs."
	}, {
		"on-score": _agenda_counters_9(1),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"keep-menu-open": false,
				"label": "Install a piece of ice in any position, ignoring all costs",
				"prompt": "Choose a piece of ice to install",
				"show-discard": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
				},
				"async": true,
				"msg": "install an ice from HQ or Archives",
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREngine.resolve_ability(state, side, eid, (func():
						var chosen_ice = target
						return {
							"prompt": "Choose a server",
							"choices": func(state, side, eid, card, targets):
								return NRBoard.installable_servers(state, chosen_ice),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREngine.resolve_ability(state, side, eid, (func():
									var chosen_server = target
									var num_ice = NRCardRT.count_of(NRCardRT.get_in(NRCardRT.getv(state.data, "corp"), (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["ices"]), null))
									return {
										"prompt": "Which position to install in? (0 is innermost)",
										"choices": NRCardRT.as_array(NRCardRT.as_array(NRCardRT.map_list(range_((int(num_ice) + 1)), func(x): return NRCardRT.truthy(str_.call(x) if str_ is Callable else str_)))),
										"async": true,
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return (func():
												var target = Integer_parseInt(target)
												return NRInstalling.corp_install(
													state,
													side,
													eid,
													chosen_ice,
													chosen_server,
													{
														"ignore-all-cost": true,
														"index": target,
														"msg-keys": {
															"install-source": card,
															"display-origin": true,
														},
													}
												)
											).call(),
									}
								).call(), card, null),
						}
					).call(), card, null),
			}
		],
	}))
	NRCardDefs.defcard("Tomorrow's Headline", NRUtil.merge({
		"title": "Tomorrow's Headline",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Ambush",
		"subtypes": ["Ambush"],
		"text": "When this agenda is scored or stolen, give the Runner 1 tag.\nLimit 1 per deck."
	}, {
		"on-score": NRDefHelpers.give_tags(1),
		"stolen": NRDefHelpers.give_tags(1),
	}))
	NRCardDefs.defcard("Transport Monopoly", NRUtil.merge({
		"title": "Transport Monopoly",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, place 2 agenda counters on it.\nOnce per turn → <strong>Hosted agenda counter:</strong> This run cannot be declared successful. <em>(This effect does not cause the run to become unsuccessful.)</em> Use this ability only during a run."
	}, {
		"on-score": _agenda_counters_9(2),
		"abilities": [
			{
				"cost": [NRPayment.to_c("agenda", 1)],
				"once": "per-turn",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run,
				"msg": "prevent this run from becoming successful",
				"effect": func(state, side, eid, card, targets):
					return NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "block-successful-run",
							"duration": "end-of-run",
							"value": true,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Underway Renovation", NRUtil.merge({
		"title": "Underway Renovation",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative - Public",
		"subtypes": ["Initiative", "Public"],
		"text": "Install Underway Renovation faceup.\nWhenever you advance Underway Renovation, trash the top card of the Runner's stack (or top 2 cards instead if there are 4 or more advancement tokens on Underway Renovation)."
	}, {
		"install-state": "face-up",
		"events": [
			{
				"event": "advance",
				"condition": "faceup",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(card, NRCardRT.getv(context, "card")),
				"msg": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return str((str("trash ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(NRCardRT.getv(runner, "deck"), int(_adv4_28(state, card))))) + str(" from the stack") if NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "deck"))) else "trash no cards from the stack (it is empty)")),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.mill(state, "corp", eid, "runner", _adv4_28(state, card)),
			}
		],
	}))
	NRCardDefs.defcard("Unorthodox Predictions", NRUtil.merge({
		"title": "Unorthodox Predictions",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security",
		"subtypes": ["Security"],
		"text": "When you score Unorthodox Predictions, choose <strong>sentry</strong>, <strong>code gate</strong> or <strong>barrier</strong>. Subroutines on ice of the chosen type cannot be broken until the beginning of your next turn."
	}, {
		"implementation": "Prevention of subroutine breaking is not enforced",
		"on-score": {
			"prompt": "Choose an ice type",
			"choices": ["Barrier", "Code Gate", "Sentry"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("prevent subroutines on ") + str(target) + str(" ice from being broken until next turn"),
		},
	}))
	NRCardDefs.defcard("Utopia Fragment", NRUtil.merge({
		"title": "Utopia Fragment",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": true,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Source",
		"subtypes": ["Source"],
		"text": "As an additional cost to steal an agenda, the Runner must pay 2[credit] for each advancement token on that agenda.\nLimit 1 per deck."
	}, {
		"static-abilities": [
			{
				"type": "steal-additional-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCardRT.pos(NRCard.get_counters(target, "advancement")),
				"value": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRPayment.to_c("credit", (2 * NRCard.get_counters(target, "advancement"))),
			}
		],
	}))
	NRCardDefs.defcard("Vanity Project", NRUtil.merge({
		"title": "Vanity Project",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 6,
		"agendapoints": 4,
		"factioncost": 1
	}, {}))
	NRCardDefs.defcard("Veterans Program", NRUtil.merge({
		"title": "Veterans Program",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "When you score this agenda, you may remove up to 2 bad publicity."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "remove 2 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.lose_bad_publicity(state, side, 2),
		},
	}))
	NRCardDefs.defcard("Viral Weaponization", NRUtil.merge({
		"title": "Viral Weaponization",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Research - Security",
		"subtypes": ["Research", "Security"],
		"text": "When the turn on which you scored Viral Weaponization ends, do 1 net damage for each card in the grip."
	}, {
		"on-score": {
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NREngine.register_events(
					state,
					side,
					card,
					[
						{
							"event": ("corp-turn-ends" if (("corp" == NRCardRT.getv(state.data, "active-player")) or NRUtil.kw_eq("corp", NRCardRT.getv(state.data, "active-player"))) else "runner-turn-ends"),
							"unregister-once-resolved": true,
							"duration": "end-of-turn",
							"msg": func(state, side, eid, card, targets):
								var runner = state.player("runner")
								return str("do ") + str(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))) + str(" net damage"),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var runner = state.player("runner")
								return NRDamage.damage(
									state,
									side,
									eid,
									"net",
									NRCardRT.count_of(NRCardRT.getv(runner, "hand")),
									{
										"card": card,
									}
								),
						}
					]
				),
		},
	}))
	NRCardDefs.defcard("Voting Machine Initiative", NRUtil.merge({
		"title": "Voting Machine Initiative",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"advancementcost": 5,
		"agendapoints": 3,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "Place 3 agenda counters on Voting Machine Initiative when you score it.\nWhen the Runner's turn begins, you may spend 1 hosted agenda counter. If you do, the Runner loses [click], if able."
	}, {
		"on-score": _agenda_counters_9(3),
		"events": [
			{
				"event": "runner-turn-begins",
				"optional": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(NRCard.get_counters(card, "agenda")),
					"waiting-prompt": true,
					"prompt": "Make the Runner lose [Click]?",
					"yes-ability": {
						"msg": "make the Runner lose [Click]",
						"cost": [NRPayment.to_c("agenda", 1)],
						"effect": func(state, side, eid, card, targets):
							return NRGaining.lose_clicks(state, "runner", 1),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Vulcan Coverup", NRUtil.merge({
		"title": "Vulcan Coverup",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Security - Liability",
		"subtypes": ["Security", "Liability"],
		"text": "When you score this agenda, do 2 meat damage.\nWhen the Runner steals this agenda, take 1 bad publicity."
	}, {
		"on-score": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "do 2 meat damage",
			"async": true,
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
		"stolen": {
			"msg": "force the Corp to take 1 bad publicity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1),
		},
	}))
	NRCardDefs.defcard("Vulnerability Audit", NRUtil.merge({
		"title": "Vulnerability Audit",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 3,
		"factioncost": 1,
		"keywords": "Research",
		"subtypes": ["Research"],
		"text": "You cannot score this agenda if it was installed this turn."
	}, {
		"flags": {
			"can-score": func(state, side, eid, card, targets):
				return (func():
					var result = (not (("this-turn" == NRCard.installed(card)) or NRUtil.kw_eq("this-turn", NRCard.installed(card))))
					(NRToasts.toast(state, "corp", "Cannot score Vulnerability Audit the turn it was installed.", "warning") if not NRCardRT.truthy(result) else null)
					return result
				).call(),
		},
	}))
	NRCardDefs.defcard("Water Monopoly", NRUtil.merge({
		"title": "Water Monopoly",
		"type": "Agenda",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"advancementcost": 3,
		"agendapoints": 1,
		"factioncost": 0,
		"keywords": "Initiative",
		"subtypes": ["Initiative"],
		"text": "The install cost of each non-<strong>virtual</strong> resource is increased by 1."
	}, {
		"static-abilities": [
			{
				"type": "install-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.resource(target) and (not NRCardRT.truthy(NRCard.has_subtype(target, "Virtual"))) and (not NRCardRT.truthy(NRCardRT.getv(NRCardRT.getv(targets, 1), "facedown"))),
				"value": 1,
			}
		],
	}))
	NRCardDefs.defcard("Witch Hunt", NRUtil.merge({
		"title": "Witch Hunt",
		"type": "Agenda",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"advancementcost": 4,
		"agendapoints": 2,
		"factioncost": 0,
		"keywords": "Initiative - Liability",
		"subtypes": ["Initiative", "Liability"],
		"text": "When this agenda is scored or stolen, take 1 bad publicity.\nWhen your action phase ends, if you scored this agenda this turn, remove all tags, then give the Runner 3 tags."
	}, (func():
		var bp = {
			"msg": "take 1 bad publicity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1),
		}
		return {
			"stolen": bp,
			"on-score": bp,
			"events": [
				{
					"unregister-once-resolved": true,
					"event": "corp-action-phase-ends",
					"duration": "end-of-turn",
					"req": func(state, side, eid, card, targets):
						return NREvents.first_event(
							state,
							side,
							"agenda-scored",
							func(_pct):
								return NRUtil.same_card(card, NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"))
						),
					"msg": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return str(("Remove all tags, and then give the Runner 3 tags" if tagged else "give the Runner 3 tags")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var tagged = NRUtil.is_tagged(state)
						return (NREid.wait_for(state, eid, func(ne):
							NRTags.lose_tags(state, side, ne, "all", {
								"suppress-checkpoint": true,
							})
						, func(async_result):
							NRTags.gain_tags(state, side, eid, 3)) if tagged else NRTags.gain_tags(state, side, eid, 3)),
				}
			],
		}
	).call()))

static func _add_agenda_point_counters(state, side, eid, card, counters):
	return NREid.wait_for(state, eid, func(ne):
		NRProps.add_counter(state, side, ne, card, "agenda", counters, null)
	, func(async_result):
		NRAgendas.update_all_agenda_points(state, side)
		NRWinning.check_win_by_agenda(state, side)
		NREid.effect_completed(state, side, eid))

static func _ice_boost_agenda(subtype):
	return {
		"on-score": {
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str("gain ") + str(_count_ice_1(corp)) + str(" [Credits]"),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRGaining.gain_credits(state, side, eid, _count_ice_1(corp)),
		},
		"static-abilities": [
			{
				"type": "ice-strength",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.has_subtype(target, subtype),
				"value": 1,
			}
		],
	}

static func _project_agenda(_p_2 = null, cdef = null):
	return NRUtil.merge(cdef, {"on-score": {
		"silent": true,
		"async": true,
		"effect": func(state, side, eid, card, targets):
			var context = NRCardRT.ctx(targets)
			return NRProps.add_counter(state, side, eid, card, type_, (quantity * quot(maxi(0, (NRCardRT.getv(context, "advancement-tokens") - (NRCardRT.getv(context, "advancement-requirement") if ((mode == "computed") or NRUtil.kw_eq(mode, "computed")) else NRCardRT.getv(card, "advancementcost")))), granularity))),
	}})

static func _agenda_counters(qty = null, ctype = null):
	return {
		"effect": func(state, side, eid, card, targets):
			return NRProps.add_counter(state, side, eid, card, ctype, qty, null),
		"async": true,
		"silent": true,
	}

static func _count_ice_1(corp):
	return reduce(
	func(c, server):
		return (c + NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(server, "ices"), func(_pct):
			return (NRCard.has_subtype(_pct, subtype) and NRCard.rezzed(_pct))))),
	0,
	NRCardRT.concat_lists(NRCardRT.as_array(NRCardRT.seq_of(NRCardRT.getv(corp, "servers"))))
)

static func _abt_3(choices):
	return {
	"async": true,
	"prompt": "Choose a card to install and rez at no cost",
	"choices": NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(choices, NRCard.ice))),
	"cancel": {
		"msg": func(state, side, eid, card, targets):
			return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(choices), " card")) + str(" from the top of R&D"),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			NREngine.unregister_events(state, side, card)
			return NRMoving.trash_cards(
				state,
				side,
				eid,
				choices,
				{
					"unpreventable": true,
					"cause-card": card,
				}
			),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRInstalling.corp_install(state, side, ne, target, null, {
				"ignore-all-cost": true,
				"install-state": "rezzed-no-cost",
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
		, func(async_result):
			(func():
				var choices = NRCardRT.filter_list(choices, func(x): return not NRCardRT.truthy((func(_pct):
					return ((target == _pct) or NRUtil.kw_eq(target, _pct))).call(x)))
				return ((func():
					NREngine.unregister_events(state, side, card)
					return NRMoving.trash_cards(
						state,
						side,
						eid,
						choices,
						{
							"unpreventable": true,
							"cause-card": card,
						}
					)
				).call() if NRCardRT.truthy(NRCardRT.get_in(NRCard.get_card(state, card), ["special", "shuffle-occurred"], null)) else (NREngine.resolve_ability(state, side, eid, abt(choices), card, null) if NRCardRT.truthy(NRCardRT.seq_of(choices)) else (func():
					NREngine.unregister_events(state, side, card)
					return NREid.effect_completed(state, side, eid)
				).call()))
			).call()),
}

static func _valid_ctx_4(contexts):
	return NRCardRT.some_list(NRCardRT.map_list(contexts, func(x): return NRCardRT.getv(x, "card")), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy(NRCard.corp(x))))

static func _valid_ctx_5(evs):
	return NRCardRT.some_list(evs, func(_pct):
		return NRCard.corp(NRCardRT.getv(_pct, "card")))

static func _remove_card_6(remaining, target):
	return filterv(
	func(_pct):
		return (not NRCardRT.truthy(NRUtil.same_card(_pct, target))),
	remaining
)

static func _enumerate_text_7(phrases):
	return (func():
		var phrases = filterv(identity, phrases)
		return ("" if NRCardRT.truthy(NRCardRT.zero(NRCardRT.count_of(phrases))) else (NRCardRT.getv(phrases, 0) if NRCardRT.truthy(((1 == NRCardRT.count_of(phrases)) or NRUtil.kw_eq(1, NRCardRT.count_of(phrases)))) else (str(NRCardRT.getv(phrases, 0)) + str(" and ") + str(NRCardRT.getv(phrases, 1)) if NRCardRT.truthy(((2 == NRCardRT.count_of(phrases)) or NRUtil.kw_eq(2, NRCardRT.count_of(phrases)))) else str(NRCardRT.getv(phrases, 0)) + str(", ") + str(enumerate_text(NRCardRT.drop_n(phrases, 1))))))
).call()

static func _interact_8(cards, remaining, to_trash, to_add, to_top, stage):
	return (NRCardRT.choose_one_helper(
	{
		"prompt": str((str(NRCardRT.enumerate_cards(to_trash)) + str(" will be trashed. ") if NRCardRT.truthy(NRCardRT.seq_of(to_trash)) else null)) + str((str(NRCardRT.enumerate_cards(to_add)) + str(" will be added to HQ. ") if NRCardRT.truthy(NRCardRT.seq_of(to_add)) else null)) + str((str("the top of R&D will be (top->bottom): ") + str(NRCardRT.enumerate_cards(NRCardRT.as_array(to_top))) if NRCardRT.truthy(NRCardRT.seq_of(to_top)) else null)),
	},
	[
		{
			"option": "OK",
			"ability": {
				"msg": func(state, side, eid, card, targets):
					return str(_enumerate_text_7(
						[
							(str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(to_trash), "card")) + str(" from R&D") if NRCardRT.truthy(NRCardRT.seq_of(to_trash)) else null),
							(str("add ") + str(NRCardRT.quantify(NRCardRT.count_of(to_add), "card")) + str(" to HQ") if NRCardRT.truthy(NRCardRT.seq_of(to_add)) else null),
							(str("rearrange the top ") + str(NRCardRT.quantify(NRCardRT.count_of(to_top), "card")) + str(" of R&D") if NRCardRT.truthy(NRCardRT.seq_of(to_top)) else null)
						]
					)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					(func():
						for c in NRCardRT.as_array(to_add):
							NRMoving.move(state, side, c, "hand")
						return null
					).call()
					(func():
						for c in NRCardRT.as_array(to_trash):
							NRMoving.move(
						state,
						side,
						c,
						"deck",
						{
							"front": true,
						}
					)
						return null
					).call()
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash_cards(state, side, ne, NRCardRT.take_n(state.get_in(["corp", "deck"], null), int(NRCardRT.count_of(to_trash))), {
							"suppress-checkpoint": true,
						})
					, func(async_result):
						(func():
							for c in NRCardRT.as_array(to_top):
								NRMoving.move(
							state,
							side,
							c,
							"deck",
							{
								"front": true,
							}
						)
							return null
						).call()
						NREngine.checkpoint(state, side, eid)),
			},
		},
		{
			"option": "I want to start over",
			"ability": interact(cards, cards, [], [], [], "trash"),
		}
	]
) if NRCardRT.truthy((not NRCardRT.truthy(NRCardRT.seq_of(remaining)))) else ({
	"prompt": "Choose a card to trash",
	"choices": (NRCardRT.as_array(remaining) + ["Done"]),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, (interact(cards, remaining, to_trash, to_add, to_top, "add") if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else interact(cards, _remove_card_6(remaining, target), (NRCardRT.as_array(to_trash) + [target]), to_add, to_top, stage)), card, null),
} if NRCardRT.truthy(((stage == "trash") or NRUtil.kw_eq(stage, "trash"))) else ({
	"prompt": "Choose a card to add to HQ",
	"choices": (NRCardRT.as_array(remaining) + ["Done"]),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, (interact(cards, remaining, to_trash, to_add, to_top, "order") if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else interact(cards, _remove_card_6(remaining, target), to_trash, (NRCardRT.as_array(to_add) + [target]), to_top, stage)), card, null),
} if NRCardRT.truthy(((stage == "add") or NRUtil.kw_eq(stage, "add"))) else {
	"prompt": "Add a card to the top of R&D",
	"choices": remaining,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, interact(cards, _remove_card_6(remaining, target), to_trash, to_add, (NRCardRT.as_array(to_top) + [target]), stage), card, null),
})))

static func _agenda_counters_9(state, side, card, eid):
	return NRProps.add_counter(state, "corp", eid, card, "agenda", count_bad_pub(state), null)

static func _bucks_10(state):
	return (2 * NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
		return NRCard.has_subtype(_pct, "Bioroid"))))

static func _meat_damage_11(s, c):
	return (2 + NRCard.get_counters(NRCard.get_card(s, c), "advancement"))

static func _install_ability_12(server_name, n):
	return {
	"prompt": "Choose a card to install",
	"show-discard": true,
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct))) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
	},
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRInstalling.corp_install(state, side, ne, target, server_name, {
				"ignore-all-cost": true,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, (install_ability((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRBoard.get_remote_names(state))), (int(n) + 1)) if NRCardRT.truthy((n < 2)) else null), card, null)),
}

static func _graft_13(n):
	return {
	"prompt": "Choose a card to add to HQ",
	"async": true,
	"choices": func(state, side, eid, card, targets):
		var corp = state.player("corp")
		return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.getv(corp, "deck"))),
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to HQ from R&D"),
	"cancel": NRShuffling.shuffle_deck,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		NRMoving.move(state, side, target, "hand")
		return (NREngine.resolve_ability(state, side, eid, graft((int(n) + 1)), card, null) if (n < 3) else (func():
			NRShuffling.shuffle_zone(state, side, "deck")
			NRSay.system_msg(state, side, str("shuffles R&D"))
			return NREid.effect_completed(state, side, eid)
		).call()),
}

static func _move_to_14(c, from):
	return NRCardRT.choose_one_helper(
	(func():
		var and_then = func(s):
			return str((", shuffle R&D, and then " if ((from == "rd") or NRUtil.kw_eq(from, "rd")) else " and ")) + str(s)
		{
			"prompt": str("Move ") + str(NRCardRT.getv(c, "title")) + str(" where?"),
		}
		return [
			{
				"option": "HQ",
				"ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						(NRShuffling.shuffle_zone(state, side, "deck") if NRCardRT.truthy(((from == "rd") or NRUtil.kw_eq(from, "rd"))) else null)
						NRMoving.move(state, side, c, "hand")
						return NRRevealing.reveal(
							state,
							side,
							eid,
							card,
							{
								"and-then": and_then("add it to HQ"),
							},
							c
						),
				},
			},
			{
				"option": "Bottom of R&D",
				"ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						(NRShuffling.shuffle_zone(state, side, "deck") if NRCardRT.truthy(((from == "rd") or NRUtil.kw_eq(from, "rd"))) else null)
						NRMoving.move(state, side, c, "deck")
						return NRRevealing.reveal(
							state,
							side,
							eid,
							card,
							{
								"and-then": and_then("add it to the bottom of R&D"),
							},
							c
						),
				},
			}
		]
	).call()
)

static func _find_ab_15(zone):
	return {
	"prompt": "Choose an agenda",
	"show-discard": ((zone == "archives") or NRUtil.kw_eq(zone, "archives")),
	"choices": (func(state, side, eid, card, targets):
		var corp = state.player("corp")
		return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.agenda))) if ((zone == "rd") or NRUtil.kw_eq(zone, "rd")) else {
		"card": func(_pct):
			return (NRCard.agenda(_pct) and (NRCard.in_hand(_pct) if ((zone == "hq") or NRUtil.kw_eq(zone, "hq")) else NRCard.in_discard(_pct))),
	}),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, _move_to_14(target, zone), card, null),
	"async": true,
	"cancel-effect": NRShuffling.shuffle_deck,
}

static func _ice_derez_16(zone):
	return {
	"event": "runner-turn-ends",
	"req": func(state, side, eid, card, targets):
		return NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
			return ((NRCardRT.getv(_pct, "zone") == ["servers", zone, "ices"]) or NRUtil.kw_eq(NRCardRT.getv(_pct, "zone"), ["servers", zone, "ices"])))),
	"duration": "end-of-turn",
	"async": true,
	"effect": func(state, side, eid, card, targets):
		return (func():
			var derez_count = mini(2, NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
				return ((NRCardRT.getv(_pct, "zone") == ["servers", zone, "ices"]) or NRUtil.kw_eq(NRCardRT.getv(_pct, "zone"), ["servers", zone, "ices"])))))
			return NREngine.resolve_ability(state, side, eid, {
				"prompt": func(state, side, eid, card, targets):
					return str("Choose ") + str(NRCardRT.quantify(derez_count, "piece")) + str(" of ice protecting ") + str(NRServers.zone_to_name([zone])) + str(" to derez"),
				"waiting-prompt": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and ((NRCardRT.getv(NRCard.get_zone(_pct), 1) == zone) or NRUtil.kw_eq(NRCardRT.getv(NRCard.get_zone(_pct), 1), zone))),
					"max": derez_count,
					"min": derez_count,
				},
				"msg": func(state, side, eid, card, targets):
					return str("derez ") + str(enumerate_str(
						NRCardRT.map_list(targets, func(_pct):
							return NRToString.card_str(state, _pct))
					)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, side, eid, targets),
			}, card, null)
		).call(),
}

static func _msr_17():
	return {
	"prompt": "Choose two pieces of ice to swap positions",
	"choices": {
		"card": func(_pct):
			return (NRCard.installed(_pct) and NRCard.ice(_pct)),
		"max": 2,
	},
	"async": true,
	"effect": func(state, side, eid, card, targets):
		return ((func():
			NRMoving.swap_ice(state, side, NRCardRT.getv(targets, 0), NRCardRT.getv(targets, 1))
			NRSay.system_msg(state, side, str("swaps the position of ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 0))) + str(" and ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 1))))
			return NREngine.resolve_ability(state, side, eid, msr(), card, null)
		).call() if ((NRCardRT.count_of(targets) == 2) or NRUtil.kw_eq(NRCardRT.count_of(targets), 2)) else (func():
			NRSay.system_msg(state, "corp", "has finished rearranging ice")
			return NREid.effect_completed(state, side, eid)
		).call()),
}

static func _trash_count_str_18(card):
	return NRCardRT.quantify((NRCard.get_counters(card, "advancement") - 4), "installed card")

static func _choose_swap_19(to_swap):
	return {
	"async": true,
	"prompt": str("Choose a card in HQ to swap with ") + str(NRCardRT.getv(to_swap, "title")),
	"cost": [NRPayment.to_c("agenda", 1)],
	"choices": {
		"not-self": true,
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.in_hand(_pct) and (NRCard.ice(_pct) if NRCard.ice(to_swap) else (NRCard.agenda(_pct) or NRCard.asset(_pct) or NRCard.upgrade(_pct)))),
	},
	"msg": {
		"public": func(state, side, eid, card, targets):
			return str("swap ") + str(NRToString.card_str(state, to_swap)) + str(" with a card from HQ"),
		"corp": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str("swap ") + str(NRToString.card_str(
				state,
				to_swap,
				{
					"maybe-visible": true,
				}
			)) + str(" with a card from HQ (") + str(NRCardRT.getv(target, "title")) + str(")"),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			swap_cards_async(state, side, ne, to_swap, target)
		, func(async_result):
			NREngine.resolve_ability(state, "runner", eid, NRDefHelpers.offer_jack_out(), card, null)),
}

static func _choose_card_20(run_server):
	return {
	"async": true,
	"prompt": "Choose a card in or protecting the attacked server",
	"choices": {
		"card": func(_pct):
			return ((NRCardRT.getv(run_server, 0) == NRCardRT.getv(NRCard.get_zone(_pct), 1)) or NRUtil.kw_eq(NRCardRT.getv(run_server, 0), NRCardRT.getv(NRCard.get_zone(_pct), 1))),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, _choose_swap_19(target), card, null),
}

static func _corp_final_21(chosen, original):
	return {
	"prompt": str("The bottom cards of R&D will be ") + str(NRCardRT.enumerate_cards(chosen)),
	"choices": ["Done", "Start over"],
	"async": true,
	"msg": func(state, side, eid, card, targets):
		var runner = state.player("runner")
		return (func():
			var n = NRCardRT.count_of(chosen)
			return str("add ") + str(NRCardRT.quantify(n, "card")) + str(" from HQ to the bottom of R&D and draw ") + str(NRCardRT.quantify(n, "card")) + str((str(". The Runner randomly adds ") + str(NRCardRT.quantify(n, "card")) + str(" from [runner-pronoun] Grip to the bottom of the Stack") if NRCardRT.truthy((n <= NRCardRT.count_of(NRCardRT.getv(runner, "hand")))) else null))
		).call(),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		var runner = state.player("runner")
		return (func():
			var n = NRCardRT.count_of(chosen)
			return ((func():
				(func():
					for c in NRCardRT.as_array(NRCardRT.as_array(chosen)):
						NRMoving.move(state, "corp", c, "deck")
					return null
				).call()
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, "corp", ne, n)
				, func(async_result):
					((func():
						(func():
							for r in NRCardRT.as_array(NRCardRT.take_n(shuffle(NRCardRT.getv(runner, "hand")), int(n))):
								NRMoving.move(state, "runner", r, "deck")
							return null
						).call()
						NREngine.queue_event(state, "runner-hand-changed?")
						return NREngine.checkpoint(state, side, eid)
					).call() if (n <= NRCardRT.count_of(NRCardRT.getv(runner, "hand"))) else NREid.effect_completed(state, side, eid)))
			).call() if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NREngine.resolve_ability(state, side, eid, corp_choice(original, null, original), card, null))
		).call(),
}

static func _corp_choice_22(remaining, chosen, original):
	return {
	"prompt": "Choose a card to move to bottom of R&D",
	"choices": (NRCardRT.as_array(NRCardRT.as_array(remaining)) + ["Done"]),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return (func():
			var chosen = ([target] + NRCardRT.as_array(chosen))
			return (NREngine.resolve_ability(state, side, eid, corp_choice(
				NRCardRT.filter_list(remaining, func(x): return not NRCardRT.truthy((func(_pct):
					return ((target == _pct) or NRUtil.kw_eq(target, _pct))).call(x))),
				chosen,
				original
			), card, null) if (not ((target == "Done") or NRUtil.kw_eq(target, "Done"))) else (NREngine.resolve_ability(state, side, eid, _corp_final_21(
				NRCardRT.filter_list(chosen, func(x): return not NRCardRT.truthy((func(_pct):
					return ((_pct == "Done") or NRUtil.kw_eq(_pct, "Done"))).call(x))),
				original
			), card, null) if NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(chosen, func(x): return not NRCardRT.truthy((func(_pct):
				return ((_pct == "Done") or NRUtil.kw_eq(_pct, "Done"))).call(x))))) else (func():
					NRSay.system_msg(state, side, "does not add any cards from HQ to bottom of R&D")
					return NREid.effect_completed(state, side, eid)
			).call()))
		).call(),
}

static func _rezzed_gate_or_sentry_23(context):
	return (NRCard.rezzed(NRCardRT.getv(context, "ice")) and (NRCard.has_subtype(NRCardRT.getv(context, "ice"), "Code Gate") or NRCard.has_subtype(NRCardRT.getv(context, "ice"), "Sentry")))

static func _stand_24(side):
	return {
	"async": true,
	"prompt": "Choose one of your installed cards to trash",
	"choices": {
		"card": func(_pct):
			return (NRCard.installed(_pct) and NRUtil.same_side(side, NRCardRT.getv(_pct, "side"))),
	},
	"cancel": {
		"display-side": side,
		"msg": "decline trashing any more cards",
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return (NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "corp", ne, 1)
			, func(async_result):
				NRPrompts.clear_wait_prompt(state, "corp")
				NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to draw 1 card and gain 5 [Credits]"))
				NRGaining.gain_credits(state, "corp", eid, 5)) if ((side == "runner") or NRUtil.kw_eq(side, "runner")) else (func():
					NRPrompts.clear_wait_prompt(state, "runner")
					return NREid.effect_completed(state, "corp", eid)
			).call()),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRMoving.trash(state, side, ne, target, ({
				"unpreventable": true,
				"cause-card": card,
			} if ((side == "corp") or NRUtil.kw_eq(side, "corp")) else {
				"unpreventable": true,
				"cause-card": card,
				"cause": "forced-to-trash",
			}))
		, func(async_result):
			NRSay.system_msg(state, side, str("trashes ") + str(NRToString.card_str(state, target)) + str(" for ") + str(NRCardRT.getv(card, "title")))
			NRPrompts.clear_wait_prompt(state, NRUtil.other_side(side))
			NRPrompts.show_wait_prompt(state, side, str(NRUtil.side_str(NRUtil.other_side(side))) + str(" to trash a card for ") + str(NRCardRT.getv(card, "title")))
			NREngine.resolve_ability(state, NRUtil.other_side(side), eid, stand(NRUtil.other_side(side)), card, null)),
}

static func _count_opp_stings_25(state, side):
	return NRCardRT.count_of(NRCardRT.filter_list(state.get_in([NRUtil.other_side(side), "scored"], null), func(_pct):
		return ((NRCardRT.getv(_pct, "title") == "Sting!") or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), "Sting!"))))

static func _score_abi_26(cred_gain):
	return {
	"msg": func(state, side, eid, card, targets):
		return str("gain ") + str(cred_gain) + str(" [Credits]"),
	"interactive": func(state, side, eid, card, targets):
		return true,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		return NREid.wait_for(state, eid, func(ne):
			NRGaining.gain_credits(state, side, ne, cred_gain)
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, NRUtil.merge(place_advancement_counter(null, 1), {"req": func(state, side, eid, card, targets):
				return NRCardRT.seq_of(NRBoard.all_installed_corp(state))}), card, null)),
}

static func _sft_27(n, max_ops):
	return {
	"prompt": "Choose a card in HQ to install",
	"async": true,
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.in_hand(_pct)),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRInstalling.corp_install(state, side, ne, target, null, {
				"ignore-all-cost": true,
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, (sft((int(n) + 1), max_ops) if NRCardRT.truthy((n < max_ops)) else null), card, null)),
}

static func _adv4_28(s, c):
	return (2 if (NRCard.get_counters(NRCard.get_card(s, c), "advancement") >= 4) else 1)
