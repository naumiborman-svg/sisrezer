class_name NRCardsOperations
extends RefCounted

## Port of game.cards.operations — translated from Jinteki.net Clojure.


static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("24/7 News Cycle", NRUtil.merge({
		"title": "24/7 News Cycle",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"text": "As an additional cost to play 24/7 News Cycle, forfeit an agenda.\nResolve the \"when scored\" ability on an agenda in your score area."
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("forfeit")],
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "scored"))),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, {
					"prompt": "Choose an agenda in your score area",
					"choices": {
						"card": func(_pct):
							return (NRCard.agenda(_pct) and when_scored(_pct) and is_scored(state, "corp", _pct)),
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("trigger the \"when scored\" ability of ") + str(NRCardRT.getv(target, "title")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, NRCardRT.getv(NRCardDefs.card_def(target), "on-score"), target, null),
				}, card, null),
		},
	}))
	NRCardDefs.defcard("Accelerated Diagnostics", NRUtil.merge({
		"title": "Accelerated Diagnostics",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"text": "Look at the top 3 cards of R&D. If any of those cards are operations, you may play them (paying their play cost), ignoring any additional costs. Trash the rest of the unplayed cards you looked at."
	}, {
		"prompt": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return str("The top cards of R&D are (top->bottom): ") + str(NRCardRT.enumerate_cards(NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3)))),
		"change-in-game-state": {
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
		},
		"choices": ["OK"],
		"async": true,
		"waiting-prompt": true,
		"effect": func(state, side, eid, card, targets):
			var corp = state.player("corp")
			return NREngine.resolve_ability(state, side, eid, _ad_4(state, eid, card, NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(3)), _shuffle_count_fn_2(state)), card, null),
	}))
	NRCardDefs.defcard("Active Policing", NRUtil.merge({
		"title": "Active Policing",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"keywords": "Terminal - Gray Ops",
		"subtypes": ["Terminal", "Gray Ops"],
		"text": "Play only if the Runner stole or trashed a Corp card during their last turn.\nAfter you resolve this operation, your action phase ends.\nYou may install 1 card from HQ. The Runner gets −1 allotted [click] for their next turn.\nThreat 3 → You may pay 2[credit]. If you do, the Runner gets −1 allotted [click] for their next turn. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
	}, (func():
		var lose_click_abi = {
			"msg": "give the Runner -1 allotted [Click] for [runner-pronoun] next turn",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				state.update_in(["runner", "extra-click-temp"], func(v): return v)
				return NREngine.resolve_ability(state, side, eid, ({
					"optional": {
						"prompt": "Pay 2 [credits] to give the Runner -1 allotted [Click] for [runner-pronoun] next turn?",
						"yes-ability": {
							"cost": [NRPayment.to_c("credit", 2)],
							"msg": "give the Runner -1 allotted [Click] for [runner-pronoun] next turn",
							"effect": func(state, side, eid, card, targets):
								return state.update_in(["runner", "extra-click-temp"], func(v): return v),
						},
					},
				} if NRCardRT.truthy(NRThreat.threat(state, int(3))) else null), card, null),
		}
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets):
					return (NREvents.last_turn(state, "runner", "trashed-card") or NREvents.last_turn(state, "runner", "stole-agenda")),
				"prompt": "Choose a card to install",
				"waiting-prompt": true,
				"choices": {
					"card": func(_pct):
						return (NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
				},
				"async": true,
				"cancel": lose_click_abi,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRInstalling.corp_install(state, side, ne, target, null, {
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						})
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, lose_click_abi, card, null)),
			},
		}
	).call()))
	NRCardDefs.defcard("Ad Blitz", NRUtil.merge({
		"title": "Ad Blitz",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"factioncost": 1,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nInstall and rez (paying all costs) X <strong>advertisements</strong> from Archives and/or HQ, if able."
	}, {
		"on-play": {
			"base-play-cost": [NRPayment.to_c("x-credits")],
			"msg": func(state, side, eid, card, targets):
				return str("install and rez ") + str(NRPayment.x_cost_value(eid)) + str(" Advertisements"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _ab_5(0, NRPayment.x_cost_value(eid)), card, null),
		},
	}))
	NRCardDefs.defcard("Aggressive Negotiation", NRUtil.merge({
		"title": "Aggressive Negotiation",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"text": "Play only if you scored an agenda this turn.\nSearch R&D for 1 card and add it to HQ. Shuffle R&D."
	}, {
		"on-play": NRUtil.merge(tutor_abi(null), {"req": func(state, side, eid, card, targets):
			var corp_reg = state.get_in(["corp", "register"])
			return NRCardRT.getv(corp_reg, "scored-agenda")}),
	}))
	NRCardDefs.defcard("An Offer You Can't Refuse", NRUtil.merge({
		"title": "An Offer You Can't Refuse",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 3,
		"text": "Choose a central server. The Runner may run that server. They cannot jack out during that run. If no run is made this way, add this operation to your score area as an agenda worth 1 agenda point."
	}, {
		"on-play": {
			"async": true,
			"prompt": "Choose a server",
			"choices": ["Archives", "R&D", "HQ"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRPrompts.show_wait_prompt(state, side, str("Runner to decide on running ") + str(target))
				return NREngine.resolve_ability(state, side, eid, (func():
					var serv = target
					return {
						"optional": {
							"prompt": str("Make a run on ") + str(serv) + str("?"),
							"player": "runner",
							"yes-ability": {
								"msg": str("let the Runner make a run on ") + str(serv),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									NRPrompts.clear_wait_prompt(state, "corp")
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
									return NRRuns.make_run(state, "runner", eid, serv, card),
							},
							"no-ability": {
								"msg": "add itself to [their] score area as an agenda worth 1 agenda point",
								"effect": func(state, side, eid, card, targets):
									NRPrompts.clear_wait_prompt(state, "corp")
									return NRMoving.as_agenda(state, "corp", card, 1),
							},
						},
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Anonymous Tip", NRUtil.merge({
		"title": "Anonymous Tip",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Draw 3 cards."
	}, {
		"on-play": NRDefHelpers.draw_ability(3),
	}))
	NRCardDefs.defcard("Archived Memories", NRUtil.merge({
		"title": "Archived Memories",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"text": "Add 1 card from Archives to HQ."
	}, {
		"on-play": corp_recur(),
	}))
	NRCardDefs.defcard("Argus Crackdown", NRUtil.merge({
		"title": "Argus Crackdown",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Lockdown - Gray Ops",
		"subtypes": ["Lockdown", "Gray Ops"],
		"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nWhenever the Runner makes a successful run on a server protected by ice, do 2 meat damage."
	}, _lockdown(
		{
			"events": [
				{
					"event": "successful-run",
					"automatic": "corp-damage",
					"req": func(state, side, eid, card, targets):
						var run_ices = NRIce.get_run_ices(state)
						return NRCardRT.seq_of(run_ices),
					"msg": "deal 2 meat damage",
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
				}
			],
		}
	)))
	NRCardDefs.defcard("Ark Lockdown", NRUtil.merge({
		"title": "Ark Lockdown",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"text": "Name a card. Remove all copies of that card in the heap from the game."
	}, {
		"on-play": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "discard")) and (not NRCardRT.truthy(NRFlags.zone_locked(state, "runner", "discard"))),
			},
			"prompt": "Name a card to remove all copies in the Heap from the game",
			"show-discard": true,
			"choices": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.getv(runner, "discard"))),
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("remove all copies of ") + str(NRCardRT.getv(target, "title")) + str(" in the Heap from the game"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				(func():
					for c in NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(runner, "discard"), func(_pct):
						return NRUtil.same_card("title", target, _pct))):
							NRMoving.move(state, "runner", c, "rfg")
						return null
				).call()
				return NREid.effect_completed(state, side, eid),
		},
	}))
	NRCardDefs.defcard("Armed Asset Protection", NRUtil.merge({
		"title": "Armed Asset Protection",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 3[credit]. Gain 1[credit] for each card type among faceup cards in Archives. If any of those cards are agendas, gain another 2[credit]."
	}, (func():
		var faceup_agendas = func(corp):
			return NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
				return (NRCard.faceup(_pct) and NRCard.agenda(_pct)))
		return {
			"on-play": {
				"msg": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return str("gain 3 [Credits], then gain ") + str(_faceup_archives_types(corp)) + str(" [Credits]"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "corp", ne, 3)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRGaining.gain_credits(state, "corp", ne, _faceup_archives_types(corp))
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, ({
								"msg": "gain 2 [Credits] for having faceup agendas in Archives",
								"effect": func(state, side, eid, card, targets):
									return NRGaining.gain_credits(state, side, eid, 2),
								"async": true,
							} if NRCardRT.truthy(faceup_agendas(corp)) else null), card, null))),
			},
		}
	).call()))
	NRCardDefs.defcard("Attitude Adjustment", NRUtil.merge({
		"title": "Attitude Adjustment",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"text": "Draw 2 cards. Reveal up to 2 agendas in HQ and/or Archives. Gain 2[credit] for each agenda revealed, then shuffle those agendas into R&D."
	}, {
		"on-play": {
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str("draw 2 cards"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 2)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose up to 2 agendas in HQ or Archives",
						"choices": {
							"max": 2,
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.agenda(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
						},
						"async": true,
						"show-discard": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
								var to_gain = (2 * NRCardRT.count_of(targets))
								return NREid.wait_for(state, eid, func(ne):
									NRRevealing.reveal(state, side, ne, card, {
										"and-then": str(", gain ") + str(to_gain) + str(" [Credits], and shuffle [them] into R&D"),
									}, targets)
								, func(async_result):
									NREid.wait_for(state, eid, func(ne):
										NRGaining.gain_credits(state, side, ne, to_gain)
									, func(async_result):
										(func():
											for c in NRCardRT.as_array(targets):
												NRMoving.move(state, "corp", c, "deck")
											return null
										).call()
										NRShuffling.shuffle_zone(state, "corp", "deck")
										NREid.effect_completed(state, side, eid)))
							).call(),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Audacity", NRUtil.merge({
		"title": "Audacity",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 4,
		"text": "Play only if there are at least 2 other cards in HQ.\nTrash all cards from HQ. Place a total of 2 advancement counters on installed cards you can advance."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (3 <= NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
			"async": true,
			"msg": "trash all cards in HQ",
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, NRCardRT.getv(corp, "hand"), {
						"unpreventable": true,
						"cause-card": card,
					})
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, _audacity_6(2), card, null)),
		},
	}))
	NRCardDefs.defcard("Back Channels", NRUtil.merge({
		"title": "Back Channels",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Choose 1 card in the root of a remote server. Gain 3[credit] for each advancement counter on that card, then trash it."
	}, {
		"on-play": {
			"prompt": "Choose an installed card in a server to trash",
			"choices": {
				"card": func(_pct):
					return ((((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))) == "content") or NRUtil.kw_eq((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))), "content")) and NRServers.is_remote(NRCardRT.getv(NRCard.get_zone(_pct), 1))),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return ((((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))) == "content") or NRUtil.kw_eq((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))), "content")) and NRServers.is_remote(NRCardRT.getv(NRCard.get_zone(_pct), 1)))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRToString.card_str(state, target)) + str(" and gain ") + str((3 * NRCard.get_counters(target, "advancement"))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, (3 * NRCard.get_counters(target, "advancement")), {
						"suppress-checkpoint": true,
					})
				, func(async_result):
					NRMoving.trash(
						state,
						side,
						eid,
						target,
						{
							"cause-card": card,
						}
					)),
		},
	}))
	NRCardDefs.defcard("Backroom Machinations", NRUtil.merge({
		"title": "Backroom Machinations",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "As an additional cost to play this operation, remove 1 tag.\nAdd this operation to your score area as an agenda worth 1 agenda point."
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("tag", 1)],
			"msg": "add itself to the score area as an agenda worth 1 agenda point",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.as_agenda(state, "corp", card, 1),
		},
	}))
	NRCardDefs.defcard("Bad Times", NRUtil.merge({
		"title": "Bad Times",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 0,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nThe Runner's memory limit is reduced by 2 until the end of the turn."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"msg": "force the Runner to lose 2[mu] until the end of the turn",
			"effect": func(state, side, eid, card, targets):
				NREffects.register_lingering_effect(state, "corp", card, NRUtil.merge(NRMemory.mu_plus(-2), {"duration": "end-of-turn"}))
				return NRMemory.update_mu(state),
		},
	}))
	NRCardDefs.defcard("Beanstalk Royalties", NRUtil.merge({
		"title": "Beanstalk Royalties",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 3[credit]."
	}, {
		"on-play": NRDefHelpers.gain_credits_ability(3),
	}))
	NRCardDefs.defcard("Best Defense", NRUtil.merge({
		"title": "Best Defense",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 0,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Trash 1 installed card with an install cost equal to or less than the number of tags the Runner has."
	}, {
		"on-play": {
			"prompt": func(state, side, eid, card, targets):
				return str("Choose a Runner card with an install cost of ") + str(count_tags(state)) + str(" or less to trash"),
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.runner(target) and NRCard.installed(target) and (not NRCardRT.truthy(NRCard.facedown(target))) and (NRCardRT.getv(target, "cost") <= count_tags(state)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
						return (NRCard.runner(_pct) and NRCard.installed(_pct) and (not NRCardRT.truthy(NRCard.facedown(_pct))) and (NRCardRT.getv(_pct, "cost") <= count_tags(state)))),
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
	NRCardDefs.defcard("Biased Reporting", NRUtil.merge({
		"title": "Biased Reporting",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"text": "Choose resource, hardware, or program. The Runner may trash any of their installed cards of the chosen type and gain 1[credit] for each card trashed this way. Gain 2[credit] for each card of the chosen type that is still installed."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.seq_of(NRBoard.all_active_installed(state, "runner")),
			"prompt": "Choose one",
			"choices": ["Hardware", "Program", "Resource"],
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(target),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (func():
					var t = target
					var n = _num_installed_7(state, t)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, "runner", ne, {
							"waiting-prompt": true,
							"prompt": func(state, side, eid, card, targets):
								return str("Choose any number of cards of type ") + str(t) + str(" to trash"),
							"choices": {
								"max": n,
								"card": func(_pct):
									return (NRCard.installed(_pct) and NRCard.is_type(_pct, t)),
							},
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var async_result = NREid.result_of(eid)
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash_cards(state, "runner", ne, targets, {
										"unpreventable": true,
										"cause-card": card,
										"cause": "forced-to-trash",
										"suppress-checkpoint": true,
									})
								, func(async_result):
									(func():
										var trashed_cards = async_result
										return NREid.wait_for(state, eid, func(ne):
											NRGaining.gain_credits(state, "runner", ne, NRCardRT.count_of(trashed_cards))
										, func(async_result):
											NRSay.system_msg(state, "runner", str("trashes ") + str(NRCardRT.enumerate_cards(trashed_cards)) + str(" and gains ") + str(NRCardRT.count_of(trashed_cards)) + str(" [Credits]"))
											NREid.effect_completed(state, side, eid))
									).call()),
						}, card, null)
					, func(async_result):
						(func():
							var n = (2 * _num_installed_7(state, t))
							return ((func():
								NRSay.system_msg(state, "corp", str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain ") + str(n) + str(" [Credits]"))
								return NRGaining.gain_credits(state, "corp", eid, n)
							).call() if NRCardRT.pos(n) else NREid.effect_completed(state, side, eid))
						).call())
				).call(),
		},
	}))
	NRCardDefs.defcard("Big Brother", NRUtil.merge({
		"title": "Big Brother",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nGive the Runner 2 tags."
	}, {
		"on-play": NRUtil.merge(NRDefHelpers.give_tags(2), {"req": func(state, side, eid, card, targets):
			var tagged = NRUtil.is_tagged(state)
			return tagged}),
	}))
	NRCardDefs.defcard("Big Deal", NRUtil.merge({
		"title": "Big Deal",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 17,
		"trash": 3,
		"factioncost": 5,
		"keywords": "Terminal",
		"subtypes": ["Terminal"],
		"text": "After you resolve this operation, your action phase ends.\nPlace 4 advancement counters on 1 installed card. You may score that card, if able.\nRemove this operation from the game."
	}, {
		"on-play": {
			"prompt": "Choose a card on which to place 4 advancement counters",
			"rfg-instead-of-trashing": true,
			"async": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place 4 advancement counters on ") + str(NRToString.card_str(state, target)),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.seq_of(NRBoard.all_installed(state, "corp")),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRProps.add_prop(state, "corp", ne, target, "advance-counter", 4, {
						"placed": true,
					})
				, func(async_result):
					(func():
						var card_to_score = target
						return NREngine.resolve_ability(state, side, eid, {
							"optional": {
								"req": func(state, side, eid, card, targets):
									return NRAgendas.can_score(state, side, NRCard.get_card(state, card_to_score)),
								"prompt": str("Score ") + str(NRCardRT.getv(card_to_score, "title")) + str("?"),
								"yes-ability": {
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NRAgendas.score(state, side, eid, NRCard.get_card(state, card_to_score)),
								},
								"no-ability": {
									"effect": func(state, side, eid, card, targets):
										return NRSay.system_msg(state, side, str("declines to use ") + str(NRCardRT.getv(card, "title")) + str(" to score ") + str(NRToString.card_str(state, card_to_score))),
								},
							},
						}, card, null)
					).call()),
		},
	}))
	NRCardDefs.defcard("Bigger Picture", NRUtil.merge({
		"title": "Bigger Picture",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nResolve 1 of the following:<ul><li>Give the Runner 1 tag.</li><li>Remove any number of tags. The Runner loses 5[credit] for each tag removed this way. Gain credits equal to the number of credits the Runner lost.</li></ul>"
	}, {
		"on-play": NRCardRT.choose_one_helper(
			{
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
			},
			[
				{
					"option": "Give the runner 1 tag",
					"ability": NRDefHelpers.give_tags(1),
				},
				{
					"option": "Remove any number of tags",
					"ability": {
						"req": func(state, side, eid, card, targets):
							var tagged = NRUtil.is_tagged(state)
							return tagged,
						"prompt": "Remove how many tags?",
						"choices": {
							"number": func(state, side, eid, card, targets):
								return count_tags(state),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREngine.resolve_ability(state, side, eid, NRUtil.merge(drain_credits("corp", "runner", (5 * target)), {"cost": [NRPayment.to_c("tag", target)]}), card, null),
					},
				}
			]
		),
	}))
	NRCardDefs.defcard("Bioroid Efficiency Research", NRUtil.merge({
		"title": "Bioroid Efficiency Research",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Rez a piece of <strong>bioroid</strong> ice, ignoring all costs, and install Bioroid Efficiency Research on that ice as a hosted condition counter with the text \"Trash Bioroid Efficiency Research and derez host ice if all of its subroutines are broken during a single encounter.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.has_subtype(_pct, "Bioroid") and NRCard.installed(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct)))),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct))))),
			},
			"async": true,
			"cancel": {
				"msg": "do nothing",
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRRezzing.rez(state, side, ne, target, {
						"ignore-cost": "all-costs",
					})
				, func(async_result):
					install_as_condition_counter(state, side, eid, card, NRCardRT.getv(async_result, "card"))),
		},
		"events": [
			{
				"event": "subroutines-broken",
				"condition": "hosted",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), NRCardRT.getv(card, "host")) and NRCardRT.getv(context, "all-subs-broken"),
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRRezzing.derez(state, side, ne, NRCardRT.getv(context, "ice"), {
							"msg-keys": {
								"and-then": " and trash itself",
							},
							"suppress-checkpoint": true,
						})
					, func(async_result):
						NRMoving.trash(
							state,
							"corp",
							eid,
							card,
							{
								"cause-card": card,
							}
						)),
			}
		],
	}))
	NRCardDefs.defcard("Biotic Labor", NRUtil.merge({
		"title": "Biotic Labor",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 4,
		"text": "Gain [click][click]."
	}, {
		"on-play": _gain_n_clicks(2),
	}))
	NRCardDefs.defcard("Blue Level Clearance", NRUtil.merge({
		"title": "Blue Level Clearance",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Double - Transaction",
		"subtypes": ["Double", "Transaction"],
		"text": "As an additional cost to play this operation, spend [click].\nGain 5[credit] and draw 2 cards."
	}, {
		"on-play": _clearance(5, 2),
	}))
	NRCardDefs.defcard("BOOM!", NRUtil.merge({
		"title": "BOOM!",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"trash": 1,
		"factioncost": 3,
		"keywords": "Double - Black Ops",
		"subtypes": ["Double", "Black Ops"],
		"text": "Play only if the Runner has at least 2 tags.\nAs an additional cost to play this operation, spend [click].\nDo 7 meat damage."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return (2 <= count_tags(state)),
			"msg": "do 7 meat damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"meat",
					7,
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("Bring Them Home", NRUtil.merge({
		"title": "Bring Them Home",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Terminal - Black Ops",
		"subtypes": ["Terminal", "Black Ops"],
		"text": "Play only if the Runner stole or trashed a Corp card during their last turn.\nAfter you resolve this operation, your action phase ends.\nReveal and add 2 cards at random from the grip to the top of the stack.\nThreat 3 → You may pay 2[credit] to reveal 1 card in the grip at random. The Runner shuffles it into the stack."
	}, (func():
		var threat_abi = {
			"optional": {
				"prompt": "Shuffle 1 random card from the grip into the stack?",
				"req": func(state, side, eid, card, targets):
					return NRThreat.threat(state, int(3)),
				"waiting-prompt": true,
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 2)],
					"req": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return NRCardRT.seq_of(NRCardRT.getv(runner, "hand")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var runner = state.player("runner")
						return (func():
							var target_card = NRCardRT.getv(shuffle(NRCardRT.getv(runner, "hand")), 0)
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, card, {
									"and-then": " and shuffle it into the Stack",
								}, target_card)
							, func(async_result):
								NRMoving.move(state, "runner", target_card, "deck")
								NRShuffling.shuffle_zone(state, "runner", "deck")
								NREid.effect_completed(state, side, eid))
						).call(),
				},
			},
		}
		return {
			"on-play": {
				"async": true,
				"req": func(state, side, eid, card, targets):
					return (NREvents.last_turn(state, "runner", "trashed-card") or NREvents.last_turn(state, "runner", "stole-agenda")),
				"effect": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (func():
						var chosen_cards = NRCardRT.take_n(shuffle(NRCardRT.getv(runner, "hand")), int(2))
						return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, card, {
								"and-then": " and place [them] on the top of the stack (in a random order)",
							}, chosen_cards)
						, func(async_result):
							(func():
								for c in NRCardRT.as_array(shuffle(chosen_cards)):
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
							).call()
							NREngine.resolve_ability(state, side, eid, threat_abi, card, null))
					).call(),
			},
		}
	).call()))
	NRCardDefs.defcard("Building Blocks", NRUtil.merge({
		"title": "Building Blocks",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 4,
		"text": "Reveal a <strong>barrier</strong> from HQ. Install and rez it, ignoring all costs."
	}, {
		"on-play": {
			"prompt": "Choose a Barrier to install and rez",
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.has_subtype(_pct, "Barrier") and NRCard.in_hand(_pct)),
			},
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, card, null, target)
				, func(async_result):
					NRInstalling.corp_install(
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
							"install-state": "rezzed-no-cost",
						}
					)),
		},
	}))
	NRCardDefs.defcard("Business As Usual", NRUtil.merge({
		"title": "Business As Usual",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Resolve 1 of the following:<ul><li>Place 1 advancement counter on each of up to 2 installed cards you can advance.</li><li>Remove all virus counters from 1 installed card.</li></ul>\nThreat 3 → You may also resolve the other mode. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
	}, (func():
		var faux_purge = {
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target) and NRCardRT.pos(NRCard.get_counters(target, "virus")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRProps.add_counter(state, side, eid, target, "virus", (-1 * NRCard.get_counters(target, "virus")), null),
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("remove all virus counters from ") + str(NRToString.card_str(state, target)),
		}
		var kaguya = {
			"choices": {
				"max": 2,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.corp(target) and NRCard.installed(target) and NRCard.can_be_advanced(state, target),
			},
			"msg": func(state, side, eid, card, targets):
				return str("place 1 advancement counter on ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
					var _v_8 = targets
					var f1 = NRCardRT.getv(_v_8, 0)
					var f2 = NRCardRT.getv(_v_8, 1)
					return (NREid.wait_for(state, eid, func(ne):
						NRProps.add_prop(state, "corp", ne, f1, "advance-counter", 1, {
							"placed": true,
						})
					, func(async_result):
						NRProps.add_prop(
							state,
							"corp",
							eid,
							f2,
							"advance-counter",
							1,
							{
								"placed": true,
							}
						)) if f2 else NRProps.add_prop(
						state,
						"corp",
						eid,
						f1,
						"advance-counter",
						1,
						{
							"placed": true,
						}
					))
				).call(),
		}
		return {
			"on-play": NRCardRT.choose_one_helper(
				{
					"optional": "after-first",
					"change-in-game-state": {
						"req": func(state, side, eid, card, targets):
							return (something_can_be_advanced(state) or NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
								return NRCardRT.pos(NRCard.get_counters(_pct, "virus")))),
					},
					"count": func(state, side, eid, card, targets):
						return (2 if NRThreat.threat(state, int(3)) else 1),
				},
				[
					{
						"option": "Place 1 advancement counter on up to two cards you can advance",
						"ability": kaguya,
					},
					{
						"option": "Remove all virus counters from 1 installed card",
						"ability": faux_purge,
					}
				]
			),
		}
	).call()))
	NRCardDefs.defcard("Casting Call", NRUtil.merge({
		"title": "Casting Call",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Install 1 agenda from HQ faceup and host this operation on that agenda as a condition counter with \"Whenever the Runner accesses host agenda, they take 2 tags.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.agenda(_pct) and NRCard.in_hand(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.corp_install(state, side, ne, target, null, {
						"install-state": "face-up",
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
				, func(async_result):
					(func():
						var agenda = async_result
						NRSay.system_msg(state, side, str("hosts ") + str(NRCardRT.getv(card, "title")) + str(" on ") + str(NRCardRT.getv(agenda, "title")))
						return install_as_condition_counter(state, side, eid, card, agenda)
					).call()),
		},
		"events": [
			{
				"event": "access",
				"condition": "hosted",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "accessed-card"), NRCardRT.getv(card, "host")),
				"msg": "give the Runner 2 tags",
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "runner", eid, 2),
			}
		],
	}))
	NRCardDefs.defcard("Caveat Emptor", NRUtil.merge({
		"title": "Caveat Emptor",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 3,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Resolve 1 of the following:\n<ul><li>Gain 6[credit]. The Runner gets −1 allotted [click] for their next turn.</li><li>Gain 10[credit]. The Runner gets +1 allotted [click] for their next turn.</li></ul>"
	}, {
		"on-play": NRCardRT.choose_one_helper(
			[
				{
					"option": "Gain 6 [Credits]. Runner has -1 [Click] next turn",
					"ability": {
						"msg": "Gain 6 [Credits] and give the Runner -1 alotted [Click] next turn",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							state.update_in(["runner", "extra-click-temp"], func(v): return v)
							return NRGaining.gain_credits(state, side, eid, 6),
					},
				},
				{
					"option": "Gain 10 [Credits]. Runner has +1 [Click] next turn",
					"ability": {
						"msg": "Gain 10 [Credits] and give the Runner +1 alotted [Click] next turn",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							state.update_in(["runner", "extra-click-temp"], func(v): return v)
							return NRGaining.gain_credits(state, side, eid, 10),
					},
				}
			]
		),
	}))
	NRCardDefs.defcard("Cultivate", NRUtil.merge({
		"title": "Cultivate",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Look at the top 5 cards of R&D. Trash 1 of those cards, add 1 of them to HQ, and arrange the rest in any order."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str(("trash the top card of R&D" if ((1 == NRCardRT.count_of(NRCardRT.getv(corp, "deck"))) or NRUtil.kw_eq(1, NRCardRT.count_of(NRCardRT.getv(corp, "deck")))) else str("look at the top ") + str(mini(5, NRCardRT.count_of(NRCardRT.getv(corp, "deck")))) + str(" cards of R&D"))),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRMoving.trash(state, side, eid, NRCardRT.getv(NRCardRT.getv(corp, "deck"), 0)) if ((1 == NRCardRT.count_of(NRCardRT.getv(corp, "deck"))) or NRUtil.kw_eq(1, NRCardRT.count_of(NRCardRT.getv(corp, "deck")))) else (func():
					var set_aside_cards = set_aside_for_me(state, side, eid, NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5)))
					var set_aside_eid = eid
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": str("The top cards of R&D are (top->bottom): ") + str(NRCardRT.enumerate_cards(set_aside_cards)),
						"waiting-prompt": true,
						"choices": ["OK"],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREngine.resolve_ability(state, side, eid, _interact_10(set_aside_cards, set_aside_cards, null, null, []), card, null),
					}, card, null)
				).call()),
		},
	}))
	NRCardDefs.defcard("Celebrity Gift", NRUtil.merge({
		"title": "Celebrity Gift",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nReveal up to 5 cards in HQ. Gain 2[credit] for each card you revealed this way."
	}, {
		"on-play": {
			"choices": {
				"max": 5,
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"msg": func(state, side, eid, card, targets):
				return str("reveal ") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(" from HQ and gain ") + str((2 * NRCardRT.count_of(targets))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, targets)
				, func(async_result):
					NRGaining.gain_credits(state, side, eid, (2 * NRCardRT.count_of(targets)))),
		},
	}))
	NRCardDefs.defcard("Cerebral Cast", NRUtil.merge({
		"title": "Cerebral Cast",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Gray Ops - Psi",
		"subtypes": ["Gray Ops", "Psi"],
		"text": "Play only if the Runner made a successful run during their last turn.\nYou and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, they must suffer 1 core damage or take 1 tag."
	}, {
		"on-play": {
			"psi": {
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "successful-run"),
				"not-equal": {
					"player": "runner",
					"async": true,
					"prompt": "Choose one",
					"waiting-prompt": true,
					"choices": ["Take 1 tag", "Suffer 1 core damage"],
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (NRTags.gain_tags(state, "runner", eid, 1) if ((target == "Take 1 tag") or NRUtil.kw_eq(target, "Take 1 tag")) else NRDamage.damage(
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
	NRCardDefs.defcard("Cerebral Static", NRUtil.merge({
		"title": "Cerebral Static",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner's identity loses its printed abilities."
	}, {
		"on-play": {
			"msg": "disable the Runner's identity",
		},
		"static-abilities": [
			{
				"type": "disable-card",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var runner = state.player("runner")
					return NRUtil.same_card(target, NRCardRT.getv(runner, "identity")),
				"value": true,
			}
		],
	}))
	NRCardDefs.defcard("\"Clones are not People\"", NRUtil.merge({
		"title": "\"Clones are not People\"",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhen you score an agenda, add \"Clones are not People\" to your score area as an agenda worth 1 agenda point."
	}, {
		"events": [
			{
				"event": "agenda-scored",
				"msg": "add itself to the score area as an agenda worth 1 agenda point",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.as_agenda(state, "corp", card, 1),
			}
		],
	}))
	NRCardDefs.defcard("Closed Accounts", NRUtil.merge({
		"title": "Closed Accounts",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nThe Runner loses all credits in their credit pool."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.pos(NRCardRT.getv(runner, "credit")),
			},
			"msg": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return str("force the Runner to lose all ") + str(NRCardRT.getv(runner, "credit")) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "runner", eid, "all"),
		},
	}))
	NRCardDefs.defcard("Commercialization", NRUtil.merge({
		"title": "Commercialization",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Choose a piece of ice. Gain 1[credit] for each advancement token on that ice."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("gain ") + str(NRCard.get_counters(target, "advancement")) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return (NRCard.ice(_pct) and NRCardRT.pos(NRCard.get_counters(_pct, "advancement")))),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.installed(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRGaining.gain_credits(state, side, eid, NRCard.get_counters(target, "advancement")),
		},
	}))
	NRCardDefs.defcard("Complete Image", NRUtil.merge({
		"title": "Complete Image",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"trash": 2,
		"factioncost": 4,
		"keywords": "Terminal - Gray Ops",
		"subtypes": ["Terminal", "Gray Ops"],
		"text": "Play only if the Runner has 3 or more agenda points and they made a successful run during their last turn.\nAfter you resolve this operation, your action phase ends.\nChoose a card name, then do 1 net damage. If you trash a card with the chosen name this way, repeat this process."
	}, {
		"implementation": "Doesn't work with Chronos Protocol: Selective Mind-mapping",
		"on-play": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NREvents.last_turn(state, "runner", "successful-run") and (3 <= NRCardRT.getv(runner, "agenda-point")),
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _name_a_card_11(), card, null),
		},
	}))
	NRCardDefs.defcard("Consulting Visit", NRUtil.merge({
		"title": "Consulting Visit",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Alliance - Double",
		"subtypes": ["Alliance", "Double"],
		"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [weyland-consortium] cards in your deck.\nAs an additional cost to play this operation, spend [click].\nSearch R&D for an operation and play it (paying all costs). Shuffle R&D."
	}, {
		"on-play": {
			"prompt": "Choose an Operation from R&D to play",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
					return (NRCard.operation(_pct) and (NRCardRT.getv(_pct, "cost") <= NRCardRT.getv(corp, "credit")))))),
			"cancel": NRShuffling.shuffle_deck,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("search R&D for ") + str(NRCardRT.getv(target, "title")) + str(" and play it"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRShuffling.shuffle_zone(state, side, "deck")
				NRSay.system_msg(state, side, "shuffles [their] deck")
				return NRPlayInstants.play_instant(state, side, eid, target, null),
		},
	}))
	NRCardDefs.defcard("Corporate Hospitality", NRUtil.merge({
		"title": "Corporate Hospitality",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"trash": 1,
		"factioncost": 2,
		"keywords": "Double - Transaction",
		"subtypes": ["Double", "Transaction"],
		"text": "As an additional cost to play this operation, spend [click].\nGain 6[credit] and draw 2 cards. Add 1 card from Archives to HQ."
	}, {
		"on-play": NRCardRT.combine_abilities(_clearance(6, 2), corp_recur()),
	}))
	NRCardDefs.defcard("Corporate Shuffle", NRUtil.merge({
		"title": "Corporate Shuffle",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nShuffle all cards in HQ into R&D. Draw 5 cards."
	}, {
		"on-play": {
			"msg": "shuffle all cards in HQ into R&D and draw 5 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRShuffling.shuffle_into_deck(state, side, "hand")
				return NRDrawing.draw(state, side, eid, 5),
		},
	}))
	NRCardDefs.defcard("Cyberdex Trial", NRUtil.merge({
		"title": "Cyberdex Trial",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"text": "Purge virus counters."
	}, {
		"play-sound": "virus-purge",
		"on-play": {
			"msg": "purge virus counters",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRPurging.purge(state, side, eid),
		},
	}))
	NRCardDefs.defcard("Death and Taxes", NRUtil.merge({
		"title": "Death and Taxes",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Current - Transaction",
		"subtypes": ["Current", "Transaction"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhenever the Runner installs a card or trashes an installed card, you may gain 1[credit]."
	}, (func():
		var maybe_gain_credit = {
			"prompt": "Gain 1 [Credits]?",
			"waiting-prompt": true,
			"autoresolve": NRCardRT.get_autoresolve("auto-fire"),
			"yes-ability": {
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 1),
			},
		}
		return {
			"special": {
				"auto-fire": "always",
			},
			"abilities": [NRCardRT.set_autoresolve("auto-fire", "Death and Taxes")],
			"events": [
				{
					"event": "runner-install",
					"optional": maybe_gain_credit,
				},
				{
					"event": "runner-trash",
					"optional": NRUtil.merge(maybe_gain_credit, {"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.installed(NRCardRT.getv(target, "card"))}),
				}
			],
		}
	).call()))
	NRCardDefs.defcard("Dedication Ceremony", NRUtil.merge({
		"title": "Dedication Ceremony",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"text": "Place 3 advancement tokens on a faceup card. You cannot score that card until your next turn begins."
	}, {
		"on-play": {
			"prompt": "Choose a faceup card",
			"choices": {
				"card": func(_pct):
					return ((NRCard.corp(_pct) and NRCard.installed(_pct) and NRCard.faceup(_pct)) or (NRCard.runner(_pct) and (NRCard.installed(_pct) or NRCardRT.getv(_pct, "host")) and (not NRCardRT.truthy(NRCard.facedown(_pct))))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place 3 advancement counters on ") + str(NRToString.card_str(state, target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRProps.add_counter(
					state,
					side,
					eid,
					target,
					"advancement",
					3,
					{
						"placed": true,
					}
				)
				return NRFlags.register_turn_flag(
					state,
					side,
					target,
					"can-score",
					func(state, _, card):
						return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score due to Dedication Ceremony.", "warning")) if NRUtil.same_card(card, target) else true)
				),
		},
	}))
	NRCardDefs.defcard("Defective Brainchips", NRUtil.merge({
		"title": "Defective Brainchips",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 1,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\n[interrupt] → The first time each turn the Runner would suffer core damage, increase that damage by 1."
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
						return ((("brain" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("brain", NRCardRT.getv(context, "type"))) or (("core" == NRCardRT.getv(context, "type")) or NRUtil.kw_eq("core", NRCardRT.getv(context, "type")))) and NREvents.first_event(
							state,
							side,
							"pre-damage-flag",
							func(_pct):
								return (("brain" == NRCardRT.getv(NRCardRT.getv(_pct, 0), "type")) or NRUtil.kw_eq("brain", NRCardRT.getv(NRCardRT.getv(_pct, 0), "type")))
						) and (not (("all" == NRCardRT.getv(context, "prevented")) or NRUtil.kw_eq("all", NRCardRT.getv(context, "prevented")))) and NRCardRT.pos(NRCardRT.getv(context, "remaining")) and (not NRCardRT.truthy(NRCardRT.getv(context, "unboostable"))),
					"msg": "increase the pending core damage by 1",
					"effect": func(state, side, eid, card, targets):
						return damage_boost(state, side, eid, 1),
				},
			}
		],
	}))
	NRCardDefs.defcard("Digital Rights Management", NRUtil.merge({
		"title": "Digital Rights Management",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"text": "Play only if the Runner did not make a successful run on HQ during their last turn.\nSearch R&D for 1 agenda and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that agenda to HQ. You may install 1 card from HQ in the root of a remote server.\nYou cannot score agendas for the remainder of the turn."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return (1 < NRCardRT.getv(state.data, "turn")) and (not NRCardRT.truthy(NRCardRT.some_list(NRCardRT.getv(runner_reg_last, "successful-run"), func(x): return NRCardRT.truthy(["hq"].call(x) if ["hq"] is Callable else ["hq"])))),
			"prompt": "Choose an Agenda",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (NRCardRT.seq_of(NRCardRT.getv(corp, "deck")) or NRCardRT.seq_of(NRCardRT.getv(corp, "hand"))),
			},
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRCardRT.as_array(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.agenda))) + ["None"]),
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(("shuffle R&D" if (("None" == target) or NRUtil.kw_eq("None", target)) else str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to HQ"))),
			"async": true,
			"effect": (func():
				var end_effect = func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					NRSay.system_msg(state, side, "can not score agendas for the remainder of the turn")
					NREffects.register_lingering_effect(
						state,
						side,
						card,
						{
							"type": "cannot-score",
							"duration": "end-of-turn",
							"value": true,
						}
					)
					NREngine.register_events(
						state,
						side,
						card,
						[
							{
								"event": "corp-install",
								"duration": "until-corp-turn-begins",
								"async": true,
								"req": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									return NRCard.agenda(NRCardRT.getv(context, "card")),
								"effect": func(state, side, eid, card, targets):
									var context = NRCardRT.ctx(targets)
									NRFlags.register_turn_flag(
										state,
										side,
										NRCardRT.getv(context, "card"),
										"can-score",
										func(state, _, card):
											return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score due to Digital Rights Management.", "warning")) if NRUtil.same_card(card, NRCardRT.getv(context, "card")) else true)
									)
									return NREid.effect_completed(state, side, eid),
							}
						]
					)
					return NREid.effect_completed(state, side, eid)
				return func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, ({
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRRevealing.reveal(state, side, ne, target)
								, func(async_result):
									NRMoving.move(state, side, target, "hand")
									NREid.effect_completed(state, side, eid)),
						} if not NRCardRT.truthy((("None" == target) or NRUtil.kw_eq("None", target))) else null), card, targets)
					, func(async_result):
						NRShuffling.shuffle_zone(state, side, "deck")
						NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a card in HQ to install",
							"choices": {
								"card": func(_pct):
									return (NRCard.in_hand(_pct) and NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct)))),
							},
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NREngine.resolve_ability(state, side, ne, (func():
										var card_to_install = target
										return {
											"prompt": "Choose a server",
											"choices": NRCardRT.filter_list(NRBoard.installable_servers(state, card_to_install), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
											"async": true,
											"effect": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return NRInstalling.corp_install(
													state,
													side,
													eid,
													card_to_install,
													target,
													{
														"msg-keys": {
															"install-source": card,
															"display-origin": true,
														},
													}
												),
										}
									).call(), card, null)
								, func(async_result):
									end_effect(state, side, eid, card, targets)),
							"cancel": {
								"async": true,
								"effect": end_effect,
							},
						}, card, null))
			).call(),
		},
	}))
	NRCardDefs.defcard("Distract the Masses", NRUtil.merge({
		"title": "Distract the Masses",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"text": "The Runner gains 2[credit]. Trash up to 2 cards from HQ, then shuffle up to 2 cards from Archives into R&D. Remove Distract the Masses from the game instead of trashing it."
	}, (func():
		var shuffle_two = {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return shuffle_into_rd_effect(state, side, eid, card, 2),
		}
		var trash_from_hq = {
			"async": true,
			"prompt": "Choose up to 2 cards in HQ to trash",
			"choices": {
				"max": 2,
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
						"cause-card": card,
					})
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, shuffle_two, card, null)),
			"cancel": shuffle_two,
		}
		return {
			"on-play": {
				"rfg-instead-of-trashing": true,
				"msg": "give The Runner 2 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, 2)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, trash_from_hq, card, null)),
			},
		}
	).call()))
	NRCardDefs.defcard("Distributed Tracing", NRUtil.merge({
		"title": "Distributed Tracing",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 4,
		"keywords": "Double - Gray Ops",
		"subtypes": ["Double", "Gray Ops"],
		"text": "As an additional cost to play this operation, spend [click].\nPlay only if the Runner stole an agenda during their last turn.\nGive the Runner 1 tag."
	}, {
		"on-play": NRUtil.merge(NRDefHelpers.give_tags(1), {"req": func(state, side, eid, card, targets):
			return NREvents.last_turn(state, "runner", "stole-agenda")}),
	}))
	NRCardDefs.defcard("Diversified Portfolio", NRUtil.merge({
		"title": "Diversified Portfolio",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 0,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 1[credit] for each remote server with a card in its root."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(_number_of_non_empty_remotes_13(state)) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(_number_of_non_empty_remotes_13(state)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, _number_of_non_empty_remotes_13(state)),
		},
	}))
	NRCardDefs.defcard("Divert Power", NRUtil.merge({
		"title": "Divert Power",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 1,
		"text": "Derez any number of cards. You may rez a card, lowering its rez cost by 3 for each card that you derezzed this way."
	}, {
		"on-play": {
			"prompt": "Choose any number of cards to derez",
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.rezzed(_pct)),
				"max": func(state, side, eid, card, targets):
					return NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), NRCard.rezzed)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.seq_of(NRBoard.all_installed(state, "corp")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRRezzing.derez(state, side, ne, targets)
				, func(async_result):
					(func():
						var discount = (3 * NRCardRT.count_of(targets))
						return NREngine.resolve_ability(state, side, eid, {
							"async": true,
							"prompt": str("Choose a card to rez, paying ") + str(discount) + str(" [Credits] less"),
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy(NRCard.corp(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x)))) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.agenda(x)))))(target) and NRRezzing.can_pay_to_rez(
										state,
										side,
										NRUtil.merge(eid, {"source": card}),
										target,
										{
											"cost-bonus": (-discount),
										}
									),
							},
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRRezzing.rez(
									state,
									side,
									eid,
									target,
									{
										"cost-bonus": (-discount),
									}
								),
						}, card, null)
					).call()),
		},
	}))
	NRCardDefs.defcard("Door to Door", NRUtil.merge({
		"title": "Door to Door",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Current - Black Ops",
		"subtypes": ["Current", "Black Ops"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhen the Runner's turn begins, Trace[1]. If successful, do 1 meat damage if the Runner is tagged; otherwise, give the Runner 1 tag."
	}, {
		"events": [
			{
				"event": "runner-turn-begins",
				"automatic": "corp-damage",
				"trace": {
					"base": 1,
					"label": "Do 1 meat damage if Runner is tagged, or give the Runner 1 tag",
					"successful": {
						"msg": func(state, side, eid, card, targets):
							var tagged = NRUtil.is_tagged(state)
							return str(("do 1 meat damage" if tagged else "give the Runner 1 tag")),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var tagged = NRUtil.is_tagged(state)
							return (NRDamage.damage(
								state,
								side,
								eid,
								"meat",
								1,
								{
									"card": card,
								}
							) if tagged else NRTags.gain_tags(state, "corp", eid, 1)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Eavesdrop", NRUtil.merge({
		"title": "Eavesdrop",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Gray Ops - Condition",
		"subtypes": ["Gray Ops", "Condition"],
		"text": "Install Eavesdrop on a piece of ice as a hosted condition counter with the text \"Whenever the Runner encounters host ice, Trace[3]. If successful, give the Runner 1 tag.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("give ") + str(NRToString.card_str(
					state,
					target,
					{
						"visible": false,
					}
				)) + str(" additional text"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), NRCard.ice),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return install_as_condition_counter(state, side, eid, card, target),
		},
		"events": [
			{
				"event": "encounter-ice",
				"condition": "hosted",
				"trace": {
					"base": 3,
					"req": func(state, side, eid, card, targets):
						var current_ice = NRIce.get_current_ice(state)
						return NRUtil.same_card(current_ice, NRCardRT.getv(card, "host")),
					"successful": NRDefHelpers.give_tags(1),
				},
			}
		],
	}))
	NRCardDefs.defcard("Economic Warfare", NRUtil.merge({
		"title": "Economic Warfare",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner made a successful run during their last turn.\nIf the Runner has at least 4[credit], they lose 4[credit]."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "successful-run"),
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (NRCardRT.getv(runner, "credit") >= 4),
			},
			"msg": "make the runner lose 4 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "runner", eid, 4),
		},
	}))
	NRCardDefs.defcard("Election Day", NRUtil.merge({
		"title": "Election Day",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"text": "Trash all cards in HQ (minimum of 1). Draw 5 cards."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(state.get_in(["corp", "hand"], null), func(_pct):
					return (not NRCardRT.truthy(NRUtil.same_card(_pct, card)))))),
			"msg": "trash all cards in HQ and draw 5 cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, state.get_in(["corp", "hand"], null), {
						"cause-card": card,
					})
				, func(async_result):
					NRDrawing.draw(state, side, eid, 5)),
		},
	}))
	NRCardDefs.defcard("End of the Line", NRUtil.merge({
		"title": "End of the Line",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 4,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "As an additional cost to play this operation, remove 1 tag.\nDo 4 meat damage."
	}, {
		"play-sound": "end-of-the-line",
		"on-play": {
			"additional-cost": [NRPayment.to_c("tag", 1)],
			"msg": "do 4 meat damage",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"meat",
					4,
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("Enforced Curfew", NRUtil.merge({
		"title": "Enforced Curfew",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner's maximum hand size is reduced by 1."
	}, {
		"on-play": {
			"msg": "reduce the Runner's maximum hand size by 1",
		},
		"static-abilities": [NRHandSize.runner_hand_size_plus(-1)],
	}))
	NRCardDefs.defcard("Enforcing Loyalty", NRUtil.merge({
		"title": "Enforcing Loyalty",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"trash": 1,
		"factioncost": 1,
		"keywords": "Double - Gray Ops",
		"subtypes": ["Double", "Gray Ops"],
		"text": "As an additional cost to play this operation, spend [click].\nTrace[3]. If successful, trash an installed card that does not match the faction of the Runner's identity."
	}, {
		"on-play": {
			"trace": {
				"base": 3,
				"label": "Trash a card not matching the faction of the Runner's identity",
				"successful": {
					"async": true,
					"prompt": "Choose an installed card not matching the faction of the Runner's identity",
					"choices": {
						"req": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var runner = state.player("runner")
							return NRCard.installed(target) and NRCard.runner(target) and ((not ((NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction") == NRCardRT.getv(target, "faction")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction"), NRCardRT.getv(target, "faction")))) or ((NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction") == "Neutral") or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(runner, "identity"), "faction"), "Neutral"))),
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
			},
		},
	}))
	NRCardDefs.defcard("Enhanced Login Protocol", NRUtil.merge({
		"title": "Enhanced Login Protocol",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAs an additional cost to take the basic action to run a server for the first time each turn, the Runner must spend [click]."
	}, {
		"on-play": {
			"msg": str("add an additional cost of [Click]") + str(" to make the first run not through a card ability each turn"),
		},
		"static-abilities": [
			{
				"type": "run-additional-cost",
				"req": func(state, side, eid, card, targets):
					return NREvents.no_event(
						state,
						side,
						"run",
						func(_pct):
							return NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(_pct, 0), "cost-args"), "click-run")
					) and NRCardRT.getv(NRCardRT.getv(targets, 1), "click-run"),
				"value": [NRPayment.to_c("click", 1)],
			}
		],
	}))
	NRCardDefs.defcard("Exchange of Information", NRUtil.merge({
		"title": "Exchange of Information",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nSwap an agenda in your score area with an agenda in the Runner's score area."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "scored")) and NRCardRT.seq_of(NRCardRT.getv(corp, "scored")),
			},
			"prompt": "Choose an agenda in the Runner's score area to swap",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRFlags.in_runner_scored(state, side, target),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var stolen = target
					return {
						"prompt": func(state, side, eid, card, targets):
							return str("Choose a scored agenda to swap for ") + str(NRCardRT.getv(stolen, "title")),
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRFlags.in_corp_scored(state, side, target),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("swap ") + str(NRCardRT.getv(target, "title")) + str(" for ") + str(NRCardRT.getv(stolen, "title")),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return swap_agendas(state, side, target, stolen),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Extract", NRUtil.merge({
		"title": "Extract",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 6[credit]. You may trash 1 of your installed cards to gain 3[credit]."
	}, {
		"on-play": {
			"async": true,
			"msg": "gain 6 [Credit]",
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 6)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose an installed card to trash",
						"req": func(state, side, eid, card, targets):
							return NRCardRT.seq_of(NRBoard.all_installed(state, "corp")),
						"choices": {
							"card": func(_pct):
								return (NRCard.installed(_pct) and NRCard.corp(_pct)),
						},
						"async": true,
						"waiting-prompt": true,
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
									"cause-card": card,
								})
							, func(async_result):
								NRGaining.gain_credits(state, side, eid, 3)),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Fast Break", NRUtil.merge({
		"title": "Fast Break",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 3,
		"text": "Gain X[credit]. Draw up to X cards. Install up to X cards in the root of and/or protecting a single remote server. X is equal to the number of agendas in the Runner's score area."
	}, {
		"x-fn": func(state, side, eid, card, targets):
			var runner = state.player("runner")
			return NRCardRT.count_of(NRCardRT.getv(runner, "scored")),
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCardRT.get_x_fn()(state, side, eid, card, targets)),
			},
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str(NRCardRT.get_x_fn()(state, side, eid, card, targets)) + str(" [Credits]"),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return (func():
					var draw = {
						"async": true,
						"prompt": "How many cards do you want to draw?",
						"waiting-prompt": true,
						"choices": {
							"number": NRCardRT.get_x_fn(),
							"max": NRCardRT.get_x_fn(),
							"default": func(state, side, eid, card, targets):
								return 1,
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("draw ") + str(NRCardRT.quantify(target, "card")),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NRDrawing.draw(state, side, eid, target),
					}
					var install_cards = func(server, n):
						return ({
						"prompt": "Choose a card to install",
						"choices": {
							"card": func(_pct):
								return (NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.in_hand(_pct) and NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.installable_servers(state, _pct), func(c):
									return ((server == c) or NRUtil.kw_eq(server, c))))),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var async_result = NREid.result_of(eid)
							return NREid.wait_for(state, eid, func(ne):
								NRInstalling.corp_install(state, side, ne, target, server, {
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								})
							, func(async_result):
								(func():
									var server = remote_to_name(NRCardRT.getv(NRCardRT.getv(async_result, "zone"), 1))
									return (NREngine.resolve_ability(state, side, eid, install_cards(server, (int(n) + 1)), card, null) if (n < NRCardRT.get_x_fn()(state, side, eid, card, targets)) else NREid.effect_completed(state, side, eid))
								).call()),
					} if NRCardRT.truthy(NRCardRT.pos(n)) else null)
					var select_server = {
						"async": true,
						"prompt": "Choose a server",
						"choices": func(state, side, eid, card, targets):
							return (NRCardRT.as_array(NRCardRT.as_array(NRBoard.get_remote_names(state))) + ["New remote"]),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREngine.resolve_ability(state, side, eid, install_cards(target, 1), card, null),
					}
					return NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "corp", ne, NRCardRT.get_x_fn()(state, side, eid, card, targets))
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NREngine.resolve_ability(state, side, ne, NRDrawing.draw, card, null)
						, func(async_result):
							NREngine.resolve_ability(state, side, eid, select_server, card, null)))
				).call(),
		},
	}))
	NRCardDefs.defcard("Fast Track", NRUtil.merge({
		"title": "Fast Track",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"text": "Search R&D for an agenda, reveal it, and add it to HQ. Shuffle R&D."
	}, {
		"on-play": {
			"prompt": "Choose an Agenda",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.agenda))),
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to HQ"),
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
	}))
	NRCardDefs.defcard("Financial Collapse", NRUtil.merge({
		"title": "Financial Collapse",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"text": "Play only if the Runner has at least 6[credit].\nThe Runner loses 2[credit] for each installed resource. The Runner can trash a resource to prevent this."
	}, {
		"on-play": {
			"optional": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (6 <= NRCardRT.getv(runner, "credit")),
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.pos(_count_resources_14(state)),
				},
				"player": "runner",
				"waiting-prompt": true,
				"prompt": "Trash a resource?",
				"yes-ability": {
					"display-side": "runner",
					"cost": [NRPayment.to_c("resource", 1)],
					"msg": "cost",
				},
				"no-ability": {
					"player": "corp",
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("make the Runner lose ") + str(_count_resources_14(state)) + str(" [Credits]"),
					"effect": func(state, side, eid, card, targets):
						return NRGaining.lose_credits(state, "runner", eid, _count_resources_14(state)),
				},
			},
		},
	}))
	NRCardDefs.defcard("Flood the Market", NRUtil.merge({
		"title": "Flood the Market",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nChoose 1 installed card you can advance. Place 1 advancement counter on that card for each remote server that has a card in its root and is protected by ice."
	}, {
		"on-play": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(_full_servers_15(state)),
			},
			"async": true,
			"prompt": func(state, side, eid, card, targets):
				return str("Choose a card and place ") + str(NRCardRT.quantify(_full_servers_15(state), "advancement counter")) + str(" on it"),
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.installed(target) and NRCard.can_be_advanced(state, target),
			},
			"cancel": {
				"msg": "do nothing",
			},
			"msg": {
				"corp": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place ") + str(NRCardRT.quantify(_full_servers_15(state), "advancement counter")) + str(" on ") + str(NRToString.card_str(
						state,
						target,
						{
							"maybe-visible": true,
						}
					)),
				"public": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("place ") + str(NRCardRT.quantify(_full_servers_15(state), "advancement counter")) + str(" on ") + str(NRToString.card_str(state, target)),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRProps.add_prop(
					state,
					state,
					eid,
					target,
					"advance-counter",
					_full_servers_15(state),
					{
						"placed": true,
					}
				),
		},
	}))
	NRCardDefs.defcard("Focus Group", NRUtil.merge({
		"title": "Focus Group",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"text": "Play only if the Runner made a successful run during their last turn.\nChoose a card type, then reveal the grip. Choose a value for X equal to or less than the number of revealed cards of the chosen type. You may pay X[credit] to place X advancement counters on 1 installed card."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "successful-run"),
			"prompt": "Choose one",
			"choices": ["Event", "Hardware", "Program", "Resource"],
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(target),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				var async_result = NREid.result_of(eid)
				return (func():
					var type_ = target
					var numtargets = NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
						return ((type_ == NRCardRT.getv(_pct, "type")) or NRUtil.kw_eq(type_, NRCardRT.getv(_pct, "type")))))
					return NREngine.resolve_ability(state, side, eid, with_revealed_hand(
						"runner",
						{
							"event-side": "corp",
						},
						({
							"async": true,
							"prompt": "How many credits do you want to pay?",
							"choices": {
								"number": func(state, side, eid, card, targets):
									return numtargets,
							},
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								var async_result = NREid.result_of(eid)
								return (func():
									var c = target
									return (NREid.wait_for(state, eid, func(ne):
										NREngine.pay(state, "corp", ne, card, NRPayment.to_c("credit", c))
									, func(async_result):
										(func():
											var payment_str = NRCardRT.getv(async_result, "msg")
											return NRSay.system_msg(state, "corp", payment_str) if payment_str != null and NRCardRT.truthy(payment_str) else null
										).call()
										NREngine.resolve_ability(state, "corp", eid, place_advancement_counter(null, c), card, null)) if NRPayment.can_pay(state, side, eid, card, NRCardRT.getv(card, "title"), NRPayment.to_c("credit", c)) else NREid.effect_completed(state, side, eid))
								).call(),
						} if NRCardRT.truthy(NRCardRT.pos(numtargets)) else null)
					), card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("Foxfire", NRUtil.merge({
		"title": "Foxfire",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"text": "Trace[7]. If successful, trash 1 <strong>virtual</strong> resource or 1 <strong>link</strong>."
	}, {
		"on-play": {
			"trace": {
				"base": 7,
				"successful": _trash_type(
					"virtual resource or link",
					func(c):
						return ((NRCard.resource(c) and NRCard.has_subtype(c, "Virtual")) or NRCard.has_subtype(c, "Link")),
					"loud"
				),
			},
		},
	}))
	NRCardDefs.defcard("Freelancer", NRUtil.merge({
		"title": "Freelancer",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nTrash up to 2 resources."
	}, {
		"on-play": _trash_type(
			"resource",
			NRCard.resource,
			"loud",
			2,
			null,
			{
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
			}
		),
	}))
	NRCardDefs.defcard("Friends in High Places", NRUtil.merge({
		"title": "Friends in High Places",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 1,
		"keywords": "Terminal",
		"subtypes": ["Terminal"],
		"text": "After you resolve this operation, end your action phase.\nInstall up to 2 cards from Archives (paying all install costs)."
	}, (func():
		var fhelper = func(n):
			return {
			"prompt": "Choose a card in Archives to install",
			"async": true,
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.in_discard(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.corp_install(state, side, ne, target, null, {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
				, func(async_result):
					(NREngine.resolve_ability(state, side, eid, fhp((int(n) + 1)), card, null) if (n < 2) else NREid.effect_completed(state, side, eid))),
		}
		return {
			"on-play": {
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.seq_of(NRCardRT.getv(corp, "discard")),
				},
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, fhelper(1), card, null),
			},
		}
	).call()))
	NRCardDefs.defcard("Fully Operational", NRUtil.merge({
		"title": "Fully Operational",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"text": "Gain 2[credit] or draw 2 cards. Repeat this process for each remote server that has a card in its root and is protected by ice."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				return str("make ") + str(NRCardRT.quantify((int(NRCardRT.count_of(_full_servers_16(state))) + 1), "gain/draw decision")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _repeat_choice_17(1, (int(NRCardRT.count_of(_full_servers_16(state))) + 1)), card, null),
		},
	}))
	NRCardDefs.defcard("Game Changer", NRUtil.merge({
		"title": "Game Changer",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"trash": 2,
		"factioncost": 5,
		"text": "Gain [click] for each agenda in the Runner's score area. Remove Game Changer from the game instead of trashing it."
	}, {
		"on-play": {
			"rfg-instead-of-trashing": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(runner, "scored"))),
			},
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRGaining.gain_clicks(state, side, NRCardRT.count_of(NRCardRT.getv(runner, "scored"))),
		},
	}))
	NRCardDefs.defcard("Game Over", NRUtil.merge({
		"title": "Game Over",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 3,
		"keywords": "Gray Ops - Liability",
		"subtypes": ["Gray Ops", "Liability"],
		"text": "Play only if the Runner stole an agenda during their last turn.\nChoose a Runner card type. Trash all installed non-<strong>icebreaker</strong> cards of the chosen type. For each card that would be trashed this way, the Runner may pay 3[credit] to prevent that card from being trashed.\nTake 1 bad publicity."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "stole-agenda"),
			"prompt": "Choose one",
			"choices": ["Hardware", "Program", "Resource"],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				var async_result = NREid.result_of(eid)
				return (func():
					var card_type = target
					var trashtargets = NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
						return (NRCard.is_type(_pct, card_type) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Icebreaker")))))
					var numtargets = NRCardRT.count_of(trashtargets)
					var typemsg = str(("non-Icebreaker " if NRCardRT.truthy(((card_type == "Program") or NRUtil.kw_eq(card_type, "Program"))) else null)) + str(card_type) + str(("s" if not NRCardRT.truthy(((card_type == "Hardware") or NRUtil.kw_eq(card_type, "Hardware"))) else null))
					NRSay.system_msg(state, "corp", str("chooses to trash all ") + str(typemsg))
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, "runner", ne, {
							"async": true,
							"req": func(state, side, eid, card, targets):
								var runner = state.player("runner")
								return (3 <= NRCardRT.getv(runner, "credit")),
							"waiting-prompt": true,
							"prompt": func(state, side, eid, card, targets):
								return str("Prevent any ") + str(typemsg) + str(" from being trashed? Pay 3 [Credits] per card"),
							"choices": {
								"max": func(state, side, eid, card, targets):
									return mini(numtargets, quot(NRCosts.total_available_credits(state, "runner", eid, card), 3)),
								"card": func(_pct):
									return (NRCard.installed(_pct) and NRCard.is_type(_pct, card_type) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Icebreaker")))),
							},
							"effect": func(state, side, eid, card, targets):
								var async_result = NREid.result_of(eid)
								return NREid.wait_for(state, eid, func(ne):
									NREngine.pay(state, "runner", ne, card, NRPayment.to_c("credit", (3 * NRCardRT.count_of(targets))))
								, func(async_result):
									NRSay.system_msg(state, "runner", str(NRCardRT.getv(async_result, "msg")) + str(" to prevent the trashing of ") + str(NRCardRT.enumerate_cards(targets, "sorted")))
									NREid.effect_completed(state, side, NREid.make_result(eid, targets))),
						}, card, null)
					, func(async_result):
						(func():
							var prevented = async_result
							var cids_to_trash = set_difference(NRCardRT.distinct_list(NRCardRT.map_list(trashtargets, func(x): return NRCardRT.getv(x, "cid"))), NRCardRT.distinct_list(NRCardRT.map_list(prevented, func(x): return NRCardRT.getv(x, "cid"))))
							var cards_to_trash = NRCardRT.filter_list(trashtargets, func(_pct):
								return cids_to_trash(NRCardRT.getv(_pct, "cid")))
							(NRSay.system_msg(state, "runner", str("chooses to not prevent Corp trashing all ") + str(typemsg)) if NRCardRT.truthy((not NRCardRT.truthy(async_result))) else null)
							return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash_cards(state, side, ne, cards_to_trash, {
									"cause-card": card,
								})
							, func(async_result):
								NRSay.system_msg(state, "corp", str("trashes all ") + str(("other " if NRCardRT.truthy(NRCardRT.seq_of(prevented)) else null)) + str(typemsg) + str(": ") + str(NRCardRT.enumerate_cards(async_result, "sorted")))
								NREid.wait_for(state, eid, func(ne):
									NRBadPublicity.gain_bad_publicity(state, "corp", ne, 1)
								, func(async_result):
									(NRSay.system_msg(state, "corp", "takes 1 bad publicity from Game Over") if NRCardRT.truthy(async_result) else null)
									NREid.effect_completed(state, side, eid)))
						).call())
				).call(),
		},
	}))
	NRCardDefs.defcard("Genotyping", NRUtil.merge({
		"title": "Genotyping",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"text": "Trash the top 2 cards of R&D, then shuffle up to 4 cards from Archives into R&D. Remove Genotyping from the game instead of trashing it."
	}, {
		"on-play": {
			"msg": "trash the top 2 cards of R&D",
			"rfg-instead-of-trashing": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.mill(state, "corp", ne, "corp", 2)
				, func(async_result):
					shuffle_into_rd_effect(state, side, eid, card, 4)),
		},
	}))
	NRCardDefs.defcard("Government Subsidy", NRUtil.merge({
		"title": "Government Subsidy",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 10,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 15[credit]."
	}, {
		"on-play": NRDefHelpers.gain_credits_ability(15),
	}))
	NRCardDefs.defcard("Greasing the Palm", NRUtil.merge({
		"title": "Greasing the Palm",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 5[credit]. You may install 1 card from HQ. You may remove 1 tag to place 1 advancement counter on that card."
	}, {
		"on-play": {
			"msg": "gain 5 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 5)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card to install",
						"waiting-prompt": true,
						"req": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), NRCard.corp_installable_type)),
						"choices": {
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var async_result = NREid.result_of(eid)
							return NREid.wait_for(state, eid, func(ne):
								NRInstalling.corp_install(state, "corp", ne, target, null, {
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								})
							, func(async_result):
								(func():
									var installed_card = async_result
									return (NREngine.resolve_ability(state, side, eid, {
										"optional": {
											"prompt": "Remove 1 tag to place 1 advancement counter on the installed card?",
											"waiting-prompt": true,
											"yes-ability": {
												"msg": func(state, side, eid, card, targets):
													return str("place 1 advancement counter on ") + str(NRToString.card_str(state, installed_card)),
												"cost": [NRPayment.to_c("tag", 1)],
												"async": true,
												"effect": func(state, side, eid, card, targets):
													return NRProps.add_prop(
														state,
														"corp",
														eid,
														installed_card,
														"advance-counter",
														1,
														{
															"placed": true,
														}
													),
											},
										},
									}, card, null) if (not NRCardRT.truthy(NRCardRT.zero(count_tags(state)))) else NREid.effect_completed(state, side, eid))
								).call()),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Green Level Clearance", NRUtil.merge({
		"title": "Green Level Clearance",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 3[credit] and draw 1 card."
	}, {
		"on-play": _clearance(3, 1),
	}))
	NRCardDefs.defcard("Hangeki", NRUtil.merge({
		"title": "Hangeki",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Reprisal - Gray Ops",
		"subtypes": ["Reprisal", "Gray Ops"],
		"text": "Play only if the Runner trashed a Corp card during their last turn and you have at least 1 installed card.\nChoose 1 of your installed cards. The Runner may access that card. If they do, remove this operation from the game; otherwise, add this operation to the Runner's score area as an agenda worth -1 agenda point."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "trashed-card"),
			"prompt": "Choose an installed Corp card",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.seq_of(NRBoard.all_installed(state, "corp")),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.installed(_pct)),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(NRToString.card_str(state, target)),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, {
					"optional": {
						"player": "runner",
						"waiting-prompt": true,
						"prompt": "Access the installed card?",
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NREid.wait_for(state, eid, func(ne):
									NRAccess.access_card(state, side, ne, target)
								, func(async_result):
									NRUpdate.update_card(state, side, NRUtil.merge(card, {"rfg-instead-of-trashing": true}))
									NREid.effect_completed(state, side, eid)),
						},
						"no-ability": {
							"msg": "add itself to the Runner's score area as an agenda worth -1 agenda point",
							"effect": func(state, side, eid, card, targets):
								return NRMoving.as_agenda(state, "runner", card, -1),
						},
					},
				}, card, targets),
		},
	}))
	NRCardDefs.defcard("Hansei Review", NRUtil.merge({
		"title": "Hansei Review",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 10[credit]. If there are any cards in HQ, trash 1 of them."
	}, {
		"on-play": {
			"async": true,
			"msg": "gain 10 [Credits]",
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, "corp", ne, 10)
				, func(async_result):
					NREngine.resolve_ability(state, "corp", eid, ({
						"prompt": "Choose a card in HQ to trash",
						"choices": {
							"max": 1,
							"all": true,
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
						},
						"msg": {
							"public": "trash a card from HQ",
							"corp": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("trash ") + str(NRToString.card_str(
									state,
									target,
									{
										"maybe-visible": true,
									}
								)) + str(" from HQ"),
						},
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
					} if NRCardRT.truthy(NRCardRT.seq_of(NRCardRT.getv(corp, "hand"))) else null), card, null)),
		},
	}))
	NRCardDefs.defcard("Hard-Hitting News", NRUtil.merge({
		"title": "Hard-Hitting News",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Terminal",
		"subtypes": ["Terminal"],
		"text": "After you resolve this operation, your action phase ends.\nPlay only if the Runner made a run during their last turn.\nTrace[4]. If successful, give the Runner 4 tags."
	}, {
		"on-play": {
			"trace": {
				"base": 4,
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "made-run"),
				"label": "Give the Runner 4 tags",
				"successful": NRDefHelpers.give_tags(4),
			},
		},
	}))
	NRCardDefs.defcard("Hasty Relocation", NRUtil.merge({
		"title": "Hasty Relocation",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"text": "As an additional cost to play this operation, trash the top card of R&D.\nDraw 3 cards. Add 3 cards from HQ to the top of R&D in any order."
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("trash-from-deck", 1)],
			"msg": "trash the top card of R&D, draw 3 cards, and add 3 cards in HQ to the top of R&D",
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 3)
				, func(async_result):
					(func():
						var from = state.get_in(["corp", "hand"], null)
						return NREngine.resolve_ability(state, "corp", eid, _hr_choice_19(from, null, 3, from), card, null)
					).call()),
		},
	}))
	NRCardDefs.defcard("Hatchet Job", NRUtil.merge({
		"title": "Hatchet Job",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"trash": 0,
		"factioncost": 2,
		"keywords": "Double - Gray Ops",
		"subtypes": ["Double", "Gray Ops"],
		"text": "As an additional cost to play this operation, spend [click].\nTrace[5]. If successful, add an installed non-<strong>virtual</strong> card to the Runner's grip."
	}, {
		"on-play": {
			"trace": {
				"base": 5,
				"successful": {
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and NRCard.runner(_pct) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Virtual")))),
					},
					"msg": "add 1 installed non-virtual card to the grip",
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.move(state, "runner", target, "hand", true),
				},
			},
		},
	}))
	NRCardDefs.defcard("Hedge Fund", NRUtil.merge({
		"title": "Hedge Fund",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 0,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 9[credit]."
	}, {
		"on-play": NRDefHelpers.gain_credits_ability(9),
	}))
	NRCardDefs.defcard("Hellion Alpha Test", NRUtil.merge({
		"title": "Hellion Alpha Test",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Black Ops - Liability",
		"subtypes": ["Black Ops", "Liability"],
		"text": "Play only if the Runner installed a resource during their last turn.\nTrace[2]. If successful, add 1 installed resource to the top of the stack. If unsuccessful, take 1 bad publicity."
	}, {
		"on-play": {
			"trace": {
				"base": 2,
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "installed-resource"),
				"successful": {
					"msg": "add a Resource to the top of the Stack",
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and NRCard.resource(_pct)),
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
						return NRSay.system_msg(state, side, str("adds ") + str(NRCardRT.getv(target, "title")) + str(" to the top of the Stack")),
				},
				"unsuccessful": {
					"msg": "take 1 bad publicity",
					"effect": func(state, side, eid, card, targets):
						return NRBadPublicity.gain_bad_publicity(state, "corp", 1),
				},
			},
		},
	}))
	NRCardDefs.defcard("Hellion Beta Test", NRUtil.merge({
		"title": "Hellion Beta Test",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Black Ops - Liability",
		"subtypes": ["Black Ops", "Liability"],
		"text": "Play only if the Runner trashed a card while accessing it during their last turn.\nTrace[2]. If successful, trash 2 installed non-program cards. If unsuccessful, take 1 bad publicity."
	}, {
		"on-play": {
			"trace": {
				"base": 2,
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(runner_reg_last, "trashed-accessed-card"),
				"label": "Trash 2 installed non-program cards or take 1 bad publicity",
				"successful": _trash_type(
					"non-program",
					func(_pct):
						return (NRCard.facedown(_pct) or (not NRCardRT.truthy(NRCard.program(_pct)))),
					"loud",
					2,
					"all"
				),
				"unsuccessful": {
					"msg": "take 1 bad publicity",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1),
				},
			},
		},
	}))
	NRCardDefs.defcard("Heritage Committee", NRUtil.merge({
		"title": "Heritage Committee",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Alliance",
		"subtypes": ["Alliance"],
		"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [jinteki] cards in your deck.\nDraw 3 cards. Add 1 card from HQ to the top of R&D."
	}, {
		"on-play": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 3)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card in HQ to add to the top of R&D",
						"choices": {
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
						},
						"msg": "draw 3 cards and add 1 card from HQ to the top of R&D",
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
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("High-Profile Target", NRUtil.merge({
		"title": "High-Profile Target",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 5,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "Play only if the Runner is tagged.\nDo 2 meat damage for each tag the Runner has."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"msg": func(state, side, eid, card, targets):
				return str("do ") + str(_dmg_count_20(state)) + str(" meat damage"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(
					state,
					side,
					eid,
					"meat",
					_dmg_count_20(state),
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("Housekeeping", NRUtil.merge({
		"title": "Housekeeping",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Current - Gray Ops",
		"subtypes": ["Current", "Gray Ops"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe first time each turn the Runner installs a card, they trash 1 card from the grip."
	}, {
		"events": [
			{
				"event": "runner-install",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "runner-install"),
				"player": "runner",
				"prompt": "Choose a card to trash",
				"choices": {
					"card": func(_pct):
						return (NRCard.runner(_pct) and NRCard.in_hand(_pct)),
				},
				"async": true,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("force the Runner to trash") + str(NRCardRT.getv(target, "title")) + str(" from the grip"),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRMoving.trash(
						state,
						"runner",
						eid,
						target,
						{
							"unpreventable": true,
							"cause-card": card,
							"cause": "forced-to-trash",
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Hunter Seeker", NRUtil.merge({
		"title": "Hunter Seeker",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Double - Gray Ops",
		"subtypes": ["Double", "Gray Ops"],
		"text": "As an additional cost to play this operation, spend [click].\nPlay only if the Runner stole an agenda during their last turn.\nTrash 1 installed card."
	}, {
		"on-play": _trash_type(
			"card",
			NRCard.installed,
			"loud",
			1,
			null,
			{
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "stole-agenda"),
			}
		),
	}))
	NRCardDefs.defcard("Hyoubu Precog Manifold", NRUtil.merge({
		"title": "Hyoubu Precog Manifold",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Lockdown - Psi",
		"subtypes": ["Lockdown", "Psi"],
		"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nWhen you play this operation, choose a server.\nWhenever the Runner makes a successful run on the chosen server, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, end the run."
	}, _lockdown(
		{
			"on-play": {
				"prompt": "Choose a server",
				"choices": func(state, side, eid, card, targets):
					return servers,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("choose ") + str(target),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUpdate.update_card(state, side, NRUtil.merge(card, {"card-target": target})),
			},
			"events": [
				{
					"event": "successful-run",
					"psi": {
						"req": func(state, side, eid, card, targets):
							return ((NRServers.zone_to_name(state.get_in(["run", "server"], null)) == NRCardRT.getv(card, "card-target")) or NRUtil.kw_eq(NRServers.zone_to_name(state.get_in(["run", "server"], null)), NRCardRT.getv(card, "card-target"))),
						"not-equal": {
							"msg": "end the run",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRRuns.end_run(state, side, eid, card),
						},
					},
				}
			],
		}
	)))
	NRCardDefs.defcard("Hypoxia", NRUtil.merge({
		"title": "Hypoxia",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "Play only if the Runner is tagged.\nDo 1 core damage. The Runner gets -1 allotted [click] for their next turn.\nRemove this operation from the game."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"msg": "do 1 core damage and give the Runner -1 allotted [Click] for [runner-pronoun] next turn",
			"rfg-instead-of-trashing": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDamage.damage(state, "runner", ne, "brain", 1, {
						"card": card,
					})
				, func(async_result):
					state.update_in(["runner", "extra-click-temp"], func(v): return v)
					NREid.effect_completed(state, side, eid)),
		},
	}))
	NRCardDefs.defcard("Interns", NRUtil.merge({
		"title": "Interns",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nInstall a non-operation card from Archives or HQ, ignoring the install cost."
	}, {
		"on-play": {
			"prompt": "Choose a card to install from Archives or HQ",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (NRCardRT.seq_of(NRCardRT.getv(corp, "hand")) or NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return ((not NRCardRT.truthy(NRCard.operation(_pct))) or (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen")))))),
			},
			"show-discard": true,
			"not-distinct": true,
			"choices": {
				"card": func(_pct):
					return ((not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
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
						"ignore-install-cost": true,
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}
				),
		},
	}))
	NRCardDefs.defcard("Invasion of Privacy", NRUtil.merge({
		"title": "Invasion of Privacy",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Double - Gray Ops - Liability",
		"subtypes": ["Double", "Gray Ops", "Liability"],
		"text": "As an additional cost to play this operation, spend [click].\nTrace[2]. If successful, reveal the grip. Trash up to X resources and/or events revealed this way, where X is equal to the amount by which your trace strength exceeded the Runner's link strength. If unsuccessful, take 1 bad publicity."
	}, {
		"on-play": {
			"trace": {
				"base": 2,
				"successful": with_revealed_hand(
					"runner",
					{
						"event-side": "corp",
					},
					{
						"prompt": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("Trash up to ") + str((target - NRCardRT.getv(targets, 1))) + str(" resources and/or events from the grip"),
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRCard.in_hand(target) and NRCard.runner(target) and (NRCard.resource(target) or NRCard.event(target)),
							"max": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								var runner = state.player("runner")
								return mini((target - NRCardRT.getv(targets, 1)), NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
									return (NRCard.resource(_pct) or NRCard.event(_pct))))),
						},
						"async": true,
						"msg": func(state, side, eid, card, targets):
							return str("trash ") + str(NRCardRT.enumerate_cards(targets)),
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
				),
				"unsuccessful": {
					"msg": "take 1 bad publicity",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1),
				},
			},
		},
	}))
	NRCardDefs.defcard("IP Enforcement", NRUtil.merge({
		"title": "IP Enforcement",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"trash": 5,
		"factioncost": 5,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "As an additional cost to play this operation, remove X tags.\nInstall 1 agenda from the Runner’s score area with a printed agenda point value equal to X. If the Runner is still tagged, place 1 advancement counter on that agenda."
	}, {
		"on-play": {
			"prompt": "Remove how many tags?",
			"choices": {
				"number": func(state, side, eid, card, targets):
					return mini(count_tags(state), NRCosts.total_available_credits(state, side, NRUtil.merge(eid, {"source-type": "play"}), card)),
				"default": func(state, side, eid, card, targets):
					return 0,
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return _resolve_fixed_cost_abi_22(state, side, eid, card, target),
			"cancel": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return _resolve_fixed_cost_abi_22(state, side, eid, card, 0),
			},
		},
	}))
	NRCardDefs.defcard("IPO", NRUtil.merge({
		"title": "IPO",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 8,
		"factioncost": 0,
		"keywords": "Terminal - Transaction",
		"subtypes": ["Terminal", "Transaction"],
		"text": "After you resolve this operation, end your action phase.\nGain 13[credit]."
	}, {
		"on-play": NRDefHelpers.gain_credits_ability(13),
	}))
	NRCardDefs.defcard("Kakurenbo", NRUtil.merge({
		"title": "Kakurenbo",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Triple",
		"subtypes": ["Triple"],
		"text": "As an additional cost to play this operation, spend [click][click].\nTrash any number of cards from HQ. Turn all cards in Archives facedown. You may install 1 card from Archives in the root of a remote server and place 2 advancement counters on it.\nRemove this operation from the game."
	}, (func():
		var install_abi = {
			"async": true,
			"prompt": "Choose an agenda, asset or upgrade to install from Archives and place 2 advancement counters on",
			"show-discard": true,
			"not-distinct": true,
			"choices": {
				"card": func(_pct):
					return ((NRCard.agenda(_pct) or NRCard.asset(_pct) or NRCard.upgrade(_pct)) and NRCard.in_discard(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRInstalling.corp_install(
					state,
					side,
					NRUtil.merge(eid, {"source": card, "source-type": "corp-install"}),
					target,
					null,
					{
						"counters": {
							"advance-counter": 2,
						},
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}
				),
		}
		return {
			"on-play": {
				"prompt": "Choose any number of cards in HQ to trash",
				"rfg-instead-of-trashing": true,
				"choices": {
					"max": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.count_of(NRCardRT.getv(corp, "hand")),
					"card": func(_pct):
						return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
				},
				"msg": {
					"public": func(state, side, eid, card, targets):
						return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" in HQ and turn Archives face-down"),
					"corp": func(state, side, eid, card, targets):
						return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" in HQ (") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(") and turn Archives face-down"),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash_cards(state, side, ne, targets, {
							"unpreventable": true,
							"cause-card": card,
						})
					, func(async_result):
						(func():
							for c in NRCardRT.as_array(NRCardRT.getv(NRCardRT.getv(state.data, "corp"), "discard")):
								NRUpdate.update_card(state, side, NRUtil.assoc_in(c, ["seen"], false))
							return null
						).call()
						NRShuffling.shuffle_zone(state, "corp", "discard")
						NREngine.resolve_ability(state, side, eid, install_abi, card, null)),
				"cancel": {
					"msg": "turn Archives face-down",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						(func():
							for c in NRCardRT.as_array(NRCardRT.getv(NRCardRT.getv(state.data, "corp"), "discard")):
								NRUpdate.update_card(state, side, NRUtil.assoc_in(c, ["seen"], false))
							return null
						).call()
						NRShuffling.shuffle_zone(state, "corp", "discard")
						return NREngine.resolve_ability(state, side, eid, install_abi, card, null),
				},
			},
		}
	).call()))
	NRCardDefs.defcard("Key Performance Indicators", NRUtil.merge({
		"title": "Key Performance Indicators",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Resolve 2 of the following in any order:<ul><li>Draw 1 card. Shuffle 1 card from HQ into R&D.</li><li>Install 1 piece of ice from HQ, ignoring all costs.</li><li>Place 1 advancement counter on an installed card you can advance.</li><li>Gain 2[credit].</li></ul>"
	}, {
		"on-play": NRCardRT.choose_one_helper(
			{
				"count": 2,
				"optional": true,
			},
			[
				{
					"option": "Gain 2 [Credit]",
					"ability": NRDefHelpers.gain_credits_ability(2),
				},
				{
					"option": "Install 1 piece of ice from HQ, ignoring all costs",
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return NRCardRT.some_list(NRCardRT.getv(corp, "hand"), NRCard.ice),
					"ability": {
						"choices": {
							"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.corp(x)) and NRCardRT.truthy(NRCard.in_hand(x))),
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
									"install-source": card,
								}
							),
					},
				},
				{
					"option": "Place 1 advancement counter",
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), NRCard.can_be_advanced),
					"ability": {
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRCard.corp(target) and NRCard.installed(target) and NRCard.can_be_advanced(state, target),
						},
						"msg": {
							"public": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("place 1 ") + str(("solid gold " if NRCardRT.truthy(((state.get_in([side, "user", "username"], null) == "Sokka234") or NRUtil.kw_eq(state.get_in([side, "user", "username"], null), "Sokka234"))) else null)) + str("advancement counter on ") + str(NRToString.card_str(state, target)),
							"corp": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("place 1 ") + str(("solid gold " if NRCardRT.truthy(((state.get_in([side, "user", "username"], null) == "Sokka234") or NRUtil.kw_eq(state.get_in([side, "user", "username"], null), "Sokka234"))) else null)) + str("advancement counter on ") + str(NRToString.card_str(
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
				{
					"option": "Draw 1 card. Shuffle 1 card from HQ into R&D",
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (NRCardRT.count_of(NRCardRT.getv(corp, "hand")) >= 1),
					"ability": {
						"msg": "draw 1 card",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
							return NREid.wait_for(state, eid, func(ne):
								NRDrawing.draw(state, side, ne, 1)
							, func(async_result):
								NREngine.resolve_ability(state, side, eid, {
									"prompt": "Shuffle 1 card into R&D",
									"req": func(state, side, eid, card, targets):
										var corp = state.player("corp")
										return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
									"choices": {
										"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.corp(x)) and NRCardRT.truthy(NRCard.in_hand(x))),
										"all": true,
									},
									"msg": {
										"public": "shuffle 1 card from HQ into R&D",
										"corp": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return str("shuffle ") + str(NRCardRT.getv(target, "title")) + str(" from HQ into R&D"),
									},
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										NRMoving.move(state, side, target, "deck")
										return NRShuffling.shuffle_zone(state, "corp", "deck"),
								}, card, null)),
					},
				}
			]
		),
	}))
	NRCardDefs.defcard("Kill Switch", NRUtil.merge({
		"title": "Kill Switch",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 5,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhile the Runner is accessing an agenda in R&D, they must reveal it.\nWhenever an agenda is accessed or scored, Trace[3]. If successful, do 1 core damage."
	}, (func():
		var trace_for_brain_damage = {
			"msg": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return str("reveal that they accessed ") + str(NRCardRT.getv((NRCardRT.getv(context, "card") or NRCardRT.getv(context, "accessed-card")), "title")),
			"trace": {
				"base": 3,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return (NRCard.agenda(NRCardRT.getv(context, "card")) or NRCard.agenda(NRCardRT.getv(context, "accessed-card"))),
				"successful": {
					"msg": "do 1 core damage",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(
							state,
							"runner",
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
		return {
			"events": [
				NRUtil.merge(trace_for_brain_damage, {"event": "access", "interactive": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.agenda(NRCardRT.getv(context, "accessed-card"))}),
				NRUtil.merge(trace_for_brain_damage, {"event": "agenda-scored"})
			],
		}
	).call()))
	NRCardDefs.defcard("Lag Time", NRUtil.merge({
		"title": "Lag Time",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 0,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAll <strong>ice</strong> have +1 strength."
	}, {
		"on-play": {
			"effect": func(state, side, eid, card, targets):
				return NRIce.update_all_ice(state, side),
		},
		"static-abilities": [
			{
				"type": "ice-strength",
				"value": 1,
			}
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRIce.update_all_ice(state, side),
	}))
	NRCardDefs.defcard("Lateral Growth", NRUtil.merge({
		"title": "Lateral Growth",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 4[credit]. You may install 1 card (paying the install cost)."
	}, {
		"on-play": {
			"msg": "gain 4 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 4)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card to install",
						"req": func(state, side, eid, card, targets):
							var corp = state.player("corp")
							return NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), NRCard.corp_installable_type)),
						"choices": {
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
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
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								}
							),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Liquidation", NRUtil.merge({
		"title": "Liquidation",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"keywords": "Double - Gray Ops - Transaction",
		"subtypes": ["Double", "Gray Ops", "Transaction"],
		"text": "As an additional cost to play this operation, spend [click].\nTrash any number of your rezzed cards and gain 3[credit] for each card trashed."
	}, {
		"on-play": {
			"prompt": "Choose any number of rezzed cards to trash",
			"choices": {
				"max": func(state, side, eid, card, targets):
					return NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
						return (not NRCardRT.truthy(NRCard.agenda(_pct))))),
				"card": func(_pct):
					return (NRCard.rezzed(_pct) and (not NRCardRT.truthy(NRCard.agenda(_pct)))),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), NRCard.rezzed),
			},
			"msg": func(state, side, eid, card, targets):
				return str("trash ") + str(NRCardRT.enumerate_cards(targets)) + str(" and gain ") + str((NRCardRT.count_of(targets) * 3)) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
						"cause-card": card,
					})
				, func(async_result):
					NRGaining.gain_credits(state, side, eid, (NRCardRT.count_of(targets) * 3))),
		},
	}))
	NRCardDefs.defcard("Load Testing", NRUtil.merge({
		"title": "Load Testing",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 5,
		"text": "When the Runner's next turn begins, they lose [click]."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				return str("make the Runner lose [Click] when [runner-pronoun] next turn begins"),
		},
		"events": [
			{
				"event": "runner-turn-begins",
				"duration": "until-runner-turn-begins",
				"msg": "make the Runner lose [Click]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.lose_clicks(state, "runner", 1),
			}
		],
	}))
	NRCardDefs.defcard("Localized Product Line", NRUtil.merge({
		"title": "Localized Product Line",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 3,
		"text": "Search R&D for any number of copies of a card, reveal them, and add them to HQ. Shuffle R&D."
	}, {
		"on-play": {
			"prompt": "Choose a card",
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.getv(corp, "deck"))),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return NREngine.resolve_ability(state, side, eid, (func():
					var title = NRCardRT.getv(target, "title")
					var copies = NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
						return ((NRCardRT.getv(_pct, "title") == title) or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), title)))
					return {
						"prompt": func(state, side, eid, card, targets):
							return str("How many copies of ") + str(title) + str(" do you want to find?"),
						"choices": {
							"number": func(state, side, eid, card, targets):
								return NRCardRT.count_of(copies),
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("add ") + str(NRCardRT.quantify(target, "cop", "y", "ies")) + str(" of ") + str(title) + str(" to HQ"),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							NRShuffling.shuffle_zone(state, "corp", "deck")
							return (func():
								for copy in NRCardRT.as_array(NRCardRT.take_n(copies, int(target))):
									NRMoving.move(state, side, copy, "hand")
								return null
							).call(),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Manhunt", NRUtil.merge({
		"title": "Manhunt",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe first time the Runner makes a successful run each turn, Trace[2]. If successful, give the Runner 1 tag."
	}, {
		"events": [
			{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"trace": {
					"req": func(state, side, eid, card, targets):
						return NREvents.first_event(state, side, "successful-run"),
					"base": 2,
					"successful": NRDefHelpers.give_tags(1),
				},
			}
		],
	}))
	NRCardDefs.defcard("Market Forces", NRUtil.merge({
		"title": "Market Forces",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nThe Runner loses 3[credit] for each tag they have, then you gain 1[credit] for each credit lost this way."
	}, {
		"on-play": NRUtil.merge(drain_credits(
			"corp",
			"runner",
			func(state, side, eid, card, targets):
				return (3 * count_tags(state))
		), {"req": func(state, side, eid, card, targets):
			var tagged = NRUtil.is_tagged(state)
			return tagged, "change-in-game-state": {
			"req": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRCardRT.pos(NRCardRT.getv(runner, "credit")),
		}}),
	}))
	NRCardDefs.defcard("Mass Commercialization", NRUtil.merge({
		"title": "Mass Commercialization",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 2[credit] for each card with at least 1 advancement token on it."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				return str("gain ") + str((2 * NRCardRT.count_of(NRCardRT.filter_list(NRBoard.get_all_installed(state), func(_pct):
					return NRCardRT.pos(NRCard.get_counters(_pct, "advancement")))))) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.get_all_installed(state), func(_pct):
						return NRCardRT.pos(NRCard.get_counters(_pct, "advancement"))))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(
					state,
					side,
					eid,
					(2 * NRCardRT.count_of(NRCardRT.filter_list(NRBoard.get_all_installed(state), func(_pct):
						return NRCardRT.pos(NRCard.get_counters(_pct, "advancement")))))
				),
		},
	}))
	NRCardDefs.defcard("MCA Informant", NRUtil.merge({
		"title": "MCA Informant",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 2,
		"keywords": "Terminal",
		"subtypes": ["Terminal"],
		"text": "After you resolve this operation, your action phase ends.\nHost this operation on an installed <strong>connection</strong> resource as a condition counter with \"The Runner is considered to have 1 additional tag. Host resource gains '<strong>[click]</strong>, <strong>2[credit]:</strong> Trash this resource.'\""
	}, {
		"on-play": {
			"prompt": "Choose a connection to host MCA Informant on",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "runner"), func(_pct):
						return NRCard.has_subtype(_pct, "Connection")),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.runner(_pct) and NRCard.has_subtype(_pct, "Connection") and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("host itself on ") + str(NRToString.card_str(state, target)) + str(". The Runner has an additional tag"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return install_as_condition_counter(state, side, eid, card, target),
		},
		"static-abilities": [
			{
				"type": "tags",
				"value": 1,
			}
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRSay.system_msg(state, "corp", "trashes MCA Informant"),
		"runner-abilities": [
			{
				"action": true,
				"label": "Trash MCA Informant host",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRSay.system_msg(state, "runner", str("spends [Click] and 2 [Credits] to trash ") + str(NRToString.card_str(state, NRCardRT.getv(card, "host"))))
					return NRMoving.trash(
						state,
						"runner",
						eid,
						NRCard.get_card(state, NRCardRT.getv(card, "host")),
						{
							"cause-card": NRCardRT.getv(card, "host"),
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Measured Response", NRUtil.merge({
		"title": "Measured Response",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"trash": 3,
		"factioncost": 4,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "Play only if the threat level is 4 or greater, and only if the Runner made a successful run during their last turn.\nDo 4 meat damage unless the Runner pays 8[credit]."
	}, {
		"on-play": NRCardRT.choose_one_helper(
			{
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "successful-run") and NRThreat.threat(state, int(4)),
				"player": "runner",
			},
			[
				NRCardRT.cost_option([NRPayment.to_c("credit", 8)], "runner"),
				{
					"option": "Corp does 4 meat damage",
					"player": "corp",
					"ability": {
						"msg": "do 4 meat damage",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(state, "corp", eid, "meat", 4),
					},
				}
			]
		),
	}))
	NRCardDefs.defcard("Media Blitz", NRUtil.merge({
		"title": "Media Blitz",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nChoose an agenda in the Runner's score area. Media Blitz gains the text of that agenda."
	}, {
		"on-play": {
			"prompt": "Choose an agenda in the runner's score area",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.agenda(target) and is_scored(state, "runner", target),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "scored")),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRUpdate.update_card(state, side, NRUtil.merge(card, {"title": NRCardRT.getv(target, "title"), "abilities": ability_init(NRCardDefs.card_def(target))}))
				NRInitializing.card_init(
					state,
					side,
					NRCard.get_card(state, card),
					{
						"resolve-effect": false,
						"init-data": true,
					}
				)
				return NRUpdate.update_card(state, side, NRUtil.merge(NRCard.get_card(state, card), {"title": "Media Blitz"})),
		},
	}))
	NRCardDefs.defcard("Medical Research Fundraiser", NRUtil.merge({
		"title": "Medical Research Fundraiser",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 8[credit]. The Runner gains 3[credit]."
	}, {
		"on-play": {
			"msg": "gain 8 [Credits]. The Runner gains 3 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 8)
				, func(async_result):
					NRGaining.gain_credits(state, "runner", eid, 3)),
		},
	}))
	NRCardDefs.defcard("Midseason Replacements", NRUtil.merge({
		"title": "Midseason Replacements",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 4,
		"text": "Play only if the Runner stole an agenda during their last turn.\nTrace[6]. If successful, give the Runner X tags. X is equal to the amount by which your trace strength exceeded their link strength."
	}, {
		"on-play": {
			"trace": {
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "stole-agenda"),
				"base": 6,
				"label": "Trace 6 - Give the Runner X tags",
				"successful": {
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("give the Runner ") + str(NRCardRT.quantify((target - NRCardRT.getv(targets, 1)), "tag")),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRTags.gain_tags(state, side, eid, (target - NRCardRT.getv(targets, 1))),
				},
			},
		},
	}))
	NRCardDefs.defcard("Mindscaping", NRUtil.merge({
		"title": "Mindscaping",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Resolve 1 of the following:<ul><li>Gain 4[credit] and draw 2 cards. Add 1 card from HQ to the top of R&D.</li><li>Do X net damage. X is equal to the number of tags the Runner has, up to 3.</li></ul>"
	}, {
		"on-play": NRCardRT.choose_one_helper(
			[
				{
					"option": "Gain 4 [Credits] and draw 2 cards",
					"ability": {
						"msg": "gain 4 [Credits] and draw 2 cards",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
							return NREid.wait_for(state, eid, func(ne):
								NRGaining.gain_credits(state, side, ne, 4, {
									"suppress-checkpoint": true,
								})
							, func(async_result):
								NREid.wait_for(state, eid, func(ne):
									NRDrawing.draw(state, "corp", ne, 2)
								, func(async_result):
									NREngine.resolve_ability(state, side, eid, {
										"req": func(state, side, eid, card, targets):
											var corp = state.player("corp")
											return NRCardRT.pos(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
										"prompt": "Choose 1 card to add to the top of R&D",
										"waiting-prompt": true,
										"msg": {
											"public": "add 1 card from HQ to the top of R&D",
											"corp": func(state, side, eid, card, targets):
												var target = NRCardRT.first_target(targets)
												return str("add facedown ") + str(NRCardRT.getv(target, "title")) + str(" from HQ to the top of R&D"),
										},
										"choices": {
											"card": func(_pct):
												return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
											"all": func(state, side, eid, card, targets):
												var corp = state.player("corp")
												return (not NRCardRT.truthy(NRCardRT.zero(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))))),
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
					},
				},
				{
					"option": "Do 1 net damage per tag (up to 3)",
					"ability": {
						"async": true,
						"msg": func(state, side, eid, card, targets):
							return str("do ") + str(mini(3, count_tags(state))) + str(" net damage"),
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(
								state,
								side,
								eid,
								"net",
								mini(3, count_tags(state)),
								{
									"card": card,
								}
							),
					},
				}
			]
		),
	}))
	NRCardDefs.defcard("Mitosis", NRUtil.merge({
		"title": "Mitosis",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 4,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nInstall up to 2 cards from HQ, creating a new remote server each time. Place 2 advancement counters on each of those cards. You cannot score or rez either of those cards this turn."
	}, {
		"on-play": {
			"prompt": "Choose 2 cards to install in new remote servers",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"choices": {
				"card": func(_pct):
					return ((not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.corp(_pct) and NRCard.in_hand(_pct)),
				"max": 2,
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return _mitosis_ability_23(state, side, card, eid, targets),
		},
	}))
	NRCardDefs.defcard("Mushin No Shin", NRUtil.merge({
		"title": "Mushin No Shin",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nInstall 1 asset, agenda, or upgrade from HQ in the root of a new server. Place 3 advancement counters on that card. You cannot score or rez that card until your next turn begins."
	}, {
		"on-play": {
			"prompt": "Choose a card to install from HQ",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"choices": {
				"card": func(_pct):
					return ((not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.corp_install(state, side, ne, target, "New remote", {
						"counters": {
							"advance-counter": 3,
						},
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
				, func(async_result):
					(func():
						var installed_card = async_result
						return register_persistent_flag_bang(
						state,
						side,
						installed_card,
						"can-rez",
						func(state, _, card):
							return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot rez due to Mushin No Shin.", "warning")) if NRUtil.same_card(card, installed_card) else true)
					) if installed_card != null and NRCardRT.truthy(installed_card) else NRFlags.register_turn_flag(
						state,
						side,
						installed_card,
						"can-score",
						func(state, _, card):
							return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score due to Mushin No Shin.", "warning")) if NRUtil.same_card(card, installed_card) else true)
					)
					).call()
					NREid.effect_completed(state, side, eid)),
		},
	}))
	NRCardDefs.defcard("Mutate", NRUtil.merge({
		"title": "Mutate",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"text": "As an additional cost to play this operation, trash a rezzed piece of ice.\nReveal cards from the top of R&D until you reveal a piece of ice. Install and rez that ice in the same position as the ice that was trashed, ignoring all costs. Shuffle R&D."
	}, {
		"on-play": {
			"prompt": "Choose a rezzed piece of ice to trash",
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.rezzed(x)))),
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var index = NRCard.card_index(state, target)
					var _v_24 = split_with((func(x): return not NRCardRT.truthy(NRCard.ice(x))), state.get_in(["corp", "deck"], null))
					var revealed_cards = NRCardRT.getv(_v_24, 0)
					var r = NRCardRT.getv(_v_24, 1)
					var titles = NRCardRT.map_list(NRCardRT.filter_list((NRCardRT.as_array(NRCardRT.as_array(revealed_cards)) + [NRCardRT.getv(r, 0)]), func(x): return NRCardRT.truthy(identity.call(x) if identity is Callable else identity)), func(x): return NRCardRT.getv(x, "title"))
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, "corp", ne, target, {
							"cause-card": card,
						})
					, func(async_result):
						NRShuffling.shuffle_zone(state, "corp", "deck")
						NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to trash ") + str(NRCardRT.getv(target, "title")))
						NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, revealed_cards)
						, func(async_result):
							NRSay.system_msg(state, side, str("reveals ") + str(enumerate_str(titles)) + str(" from R&D"))
							(func():
								var ice = NRCardRT.getv(r, 0)
								var zone = NRServers.zone_to_name(NRCardRT.getv(NRCard.get_zone(target), 1))
								return ((func():
									NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to install and rez ") + str(NRCardRT.getv(ice, "title")) + str(" from R&D at no cost"))
									return NRInstalling.corp_install(
										state,
										side,
										eid,
										ice,
										zone,
										{
											"ignore-all-cost": true,
											"install-state": "rezzed-no-cost",
											"display-message": false,
											"origin-index": index,
										}
									)
								).call() if ice else (func():
									NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to shuffle R&D"))
									return NREid.effect_completed(state, side, eid)
								).call())
							).call()))
				).call(),
		},
	}))
	NRCardDefs.defcard("Mutually Assured Destruction", NRUtil.merge({
		"title": "Mutually Assured Destruction",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 4,
		"keywords": "Triple",
		"subtypes": ["Triple"],
		"text": "As an additional cost to play this operation, spend [click][click].\nTrash any number of your rezzed cards. Give the Runner 1 tag for each card trashed this way."
	}, {
		"on-play": {
			"prompt": "Choose any number of rezzed cards to trash",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), NRCard.rezzed),
			},
			"choices": {
				"max": func(state, side, eid, card, targets):
					return NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "corp"), func(_pct):
						return (not NRCardRT.truthy(NRCard.agenda(_pct))))),
				"card": func(_pct):
					return (NRCard.rezzed(_pct) and (not NRCardRT.truthy(NRCard.agenda(_pct)))),
			},
			"msg": func(state, side, eid, card, targets):
				return str("trash ") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(" and give the runner ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "tag")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
						"cause-card": card,
					})
				, func(async_result):
					NRTags.gain_tags(state, "corp", eid, NRCardRT.count_of(targets))),
		},
	}))
	NRCardDefs.defcard("Myōshu", NRUtil.merge({
		"title": "Myōshu",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 10,
		"factioncost": 4,
		"text": "Play only if you scored an agenda this turn that you did not install this turn.\nAdd this operation to your score area as an agenda worth 2 agenda points."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return (not NRCardRT.truthy(NREvents.no_event(
					state,
					side,
					"agenda-scored",
					func(_pct):
						return (not (("this-turn" == NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(_pct, 0), "scored-card"), "installed")) or NRUtil.kw_eq("this-turn", NRCardRT.getv(NRCardRT.getv(NRCardRT.getv(_pct, 0), "scored-card"), "installed"))))
				))),
			"msg": "add itself to [their] score area as an Agenda worth 2 points",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.as_agenda(state, side, card, 2),
		},
	}))
	NRCardDefs.defcard("Nanomanagement", NRUtil.merge({
		"title": "Nanomanagement",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 4,
		"text": "Gain [click][click]."
	}, {
		"on-play": _gain_n_clicks(2),
	}))
	NRCardDefs.defcard("NAPD Cordon", NRUtil.merge({
		"title": "NAPD Cordon",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"trash": 2,
		"factioncost": 0,
		"keywords": "Lockdown",
		"subtypes": ["Lockdown"],
		"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nAs an additional cost to steal an agenda, the Runner must pay 4[credit] plus 2[credit] for each advancement counter on that agenda."
	}, _lockdown(
		{
			"static-abilities": [
				{
					"type": "steal-additional-cost",
					"value": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRPayment.to_c("credit", (4 + (2 * NRCard.get_counters(target, "advancement")))),
				}
			],
		}
	)))
	NRCardDefs.defcard("Net Watchlist", NRUtil.merge({
		"title": "Net Watchlist",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner must pay 2[credit] as an additional cost to use an icebreaker."
	}, {
		"implementation": "Only modifies ability costs, does not adjust non-ability uses",
		"static-abilities": [
			{
				"type": "card-ability-additional-cost",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.has_subtype(NRCardRT.getv(context, "card"), "Icebreaker") and (not NRCardRT.truthy(NRCardRT.get_in(context, ["ability", "break"], null))),
				"value": NRPayment.to_c("credit", 2),
			},
			{
				"type": "break-sub-additional-cost",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRCard.has_subtype(NRCardRT.getv(context, "card"), "Icebreaker"),
				"value": NRPayment.to_c("credit", 2),
			}
		],
	}))
	NRCardDefs.defcard("Neural EMP", NRUtil.merge({
		"title": "Neural EMP",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner made a run during their last turn.\nDo 1 net damage."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "made-run"),
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
	NRCardDefs.defcard("Neurospike", NRUtil.merge({
		"title": "Neurospike",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Do X net damage, where X is equal to the sum of the printed agenda points on agendas you scored this turn."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var corp_reg = state.get_in(["corp", "register"])
				return str("do ") + str(NRCardRT.getv(corp_reg, "scored-agenda", 0)) + str(" net damage"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp_reg = state.get_in(["corp", "register"])
					return NRCardRT.pos(NRCardRT.getv(corp_reg, "scored-agenda", 0)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp_reg = state.get_in(["corp", "register"])
				return NRDamage.damage(
					state,
					side,
					eid,
					"net",
					NRCardRT.getv(corp_reg, "scored-agenda", 0),
					{
						"card": card,
					}
				),
		},
	}))
	NRCardDefs.defcard("NEXT Activation Command", NRUtil.merge({
		"title": "NEXT Activation Command",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"trash": 4,
		"factioncost": 3,
		"keywords": "Lockdown",
		"subtypes": ["Lockdown"],
		"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nEach piece of ice gets +2 strength.\nThe Runner cannot use non-<strong>icebreaker</strong> cards to break subroutines."
	}, _lockdown(
		{
			"static-abilities": [
				{
					"type": "ice-strength",
					"value": 2,
				},
				{
					"type": "prevent-paid-ability",
					"req": func(state, side, eid, card, targets):
						return (func():
							var target_card = NRCardRT.getv(targets, 0)
							var ability = NRCardRT.getv(targets, 1)
							return ((not NRCardRT.truthy(NRCard.has_subtype(target_card, "Icebreaker"))) and NRCardRT.getv(ability, "break"))
						).call(),
					"value": true,
				}
			],
		}
	)))
	NRCardDefs.defcard("Nonequivalent Exchange", NRUtil.merge({
		"title": "Nonequivalent Exchange",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 5[credit]. You may have each player gain 2[credit]."
	}, {
		"on-play": {
			"optional": {
				"prompt": "Have each player gain 2 [Credits]?",
				"waiting-prompt": true,
				"yes-ability": {
					"msg": "gain 7 [Credits]. The Runner gains 2 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
							NRGaining.gain_credits(state, side, ne, 7)
						, func(async_result):
							NRGaining.gain_credits(state, "runner", eid, 2)),
				},
				"no-ability": {
					"msg": "gain 5 [Credits]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, side, eid, 5),
				},
			},
		},
	}))
	NRCardDefs.defcard("O₂ Shortage", NRUtil.merge({
		"title": "O₂ Shortage",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"text": "The Runner may trash 1 card from the grip at random. If they do not, gain [click][click]."
	}, {
		"on-play": NRCardRT.choose_one_helper(
			{
				"player": "runner",
			},
			[
				NRCardRT.cost_option([NRPayment.to_c("randomly-trash-from-hand", 1)], "runner"),
				{
					"option": "The Corp gains [Click][Click]",
					"player": "corp",
					"ability": _gain_n_clicks(2),
				}
			]
		),
	}))
	NRCardDefs.defcard("Observe and Destroy", NRUtil.merge({
		"title": "Observe and Destroy",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner has fewer than 6[credit].\nAs an additional cost to play this operation, remove 1 tag.\nTrash 1 installed card."
	}, {
		"on-play": _trash_type(
			"installed",
			NRCard.installed,
			"loud",
			1,
			"all",
			{
				"additional-cost": [NRPayment.to_c("tag", 1)],
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return (NRCardRT.getv(runner, "credit") < 6),
			}
		),
	}))
	NRCardDefs.defcard("Oppo Research", NRUtil.merge({
		"title": "Oppo Research",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Terminal - Gray Ops",
		"subtypes": ["Terminal", "Gray Ops"],
		"text": "Play only if the Runner stole or trashed a Corp card during their last turn.\nAfter you resolve this operation, your action phase ends.\nGive the Runner 2 tags.\nThreat 3 → You may pay 5[credit] to give the Runner 2 tags. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
	}, {
		"on-play": {
			"msg": "give the Runner 2 tags",
			"async": true,
			"req": func(state, side, eid, card, targets):
				return (NREvents.last_turn(state, "runner", "trashed-card") or NREvents.last_turn(state, "runner", "stole-agenda")),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRTags.gain_tags(state, "corp", ne, 2)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"optional": {
							"prompt": "Pay 5 [Credit] to give the Runner 2 tags?",
							"req": func(state, side, eid, card, targets):
								return NRThreat.threat(state, int(3)),
							"waiting-prompt": true,
							"yes-ability": {
								"async": true,
								"cost": [NRPayment.to_c("credit", 5)],
								"msg": "give the Runner 2 tags",
								"effect": func(state, side, eid, card, targets):
									return NRTags.gain_tags(state, "corp", eid, 2),
							},
						},
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Oversight AI", NRUtil.merge({
		"title": "Oversight AI",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Rez a piece of ice, ignoring all costs, and install Oversight AI on that ice as a hosted condition counter with the text \"Trash host ice if all its subroutines are broken during a single encounter.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct))) and (((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))) == "ices") or NRUtil.kw_eq((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCard.get_zone(_pct))), "ices"))),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x)))))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRRezzing.rez(state, side, ne, target, {
						"ignore-cost": "all-costs",
					})
				, func(async_result):
					install_as_condition_counter(state, side, eid, card, NRCardRT.getv(async_result, "card"))),
		},
		"events": [
			{
				"event": "subroutines-broken",
				"condition": "hosted",
				"async": true,
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), NRCardRT.getv(card, "host")) and NRCardRT.getv(context, "all-subs-broken"),
				"msg": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return str("trash ") + str(NRToString.card_str(state, NRCardRT.getv(context, "ice"))),
				"effect": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRMoving.trash(
						state,
						"corp",
						eid,
						NRCardRT.getv(context, "ice"),
						{
							"unpreventable": true,
							"cause-card": card,
						}
					),
			}
		],
	}))
	NRCardDefs.defcard("Patch", NRUtil.merge({
		"title": "Patch",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Install Patch on a rezzed piece of ice as a hosted condition counter with the text \"Host ice has +2 strength.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.rezzed(x)))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("give +2 strength to ") + str(NRToString.card_str(state, target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return install_as_condition_counter(state, side, eid, card, target),
		},
		"static-abilities": [
			{
				"type": "ice-strength",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.getv(card, "host")),
				"value": 2,
			}
		],
	}))
	NRCardDefs.defcard("Paywall Implementation", NRUtil.merge({
		"title": "Paywall Implementation",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Current - Transaction",
		"subtypes": ["Current", "Transaction"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nGain 1[credit] whenever the Runner makes a successful run."
	}, {
		"events": [
			{
				"event": "successful-run",
				"automatic": "gain-credits",
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Peak Efficiency", NRUtil.merge({
		"title": "Peak Efficiency",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"text": "Gain 1[credit] for each rezzed piece of ice."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str("gain ") + str(reduce(
					func(c, server):
						return (c + NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(server, "ices"), func(ice):
							return NRCardRT.getv(ice, "rezzed")))),
					0,
					NRCardRT.concat_lists(NRCardRT.as_array(NRCardRT.seq_of(NRCardRT.getv(corp, "servers"))))
				)) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.rezzed(x)))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRGaining.gain_credits(
					state,
					side,
					eid,
					reduce(
						func(c, server):
							return (c + NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(server, "ices"), func(ice):
								return NRCardRT.getv(ice, "rezzed")))),
						0,
						NRCardRT.concat_lists(NRCardRT.as_array(NRCardRT.seq_of(NRCardRT.getv(corp, "servers"))))
					)
				),
		},
	}))
	NRCardDefs.defcard("Peer Review", NRUtil.merge({
		"title": "Peer Review",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Reveal all but 1 card in HQ.\nGain 7[credit]. You may install 1 card from HQ in the root of a remote server."
	}, (func():
		var gain_abi = {
			"msg": func(state, side, eid, card, targets):
				return str("gain 7 [credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 7)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Install a card from HQ in the root of a remote server",
						"choices": {
							"card": func(_pct):
								return (NRCard.in_hand(_pct) and NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.ice(_pct))) and (not NRCardRT.truthy(NRCard.operation(_pct)))),
						},
						"async": true,
						"waiting-prompt": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NREngine.resolve_ability(state, side, ne, (func():
									var card_to_install = target
									return {
										"prompt": "Choose a server",
										"choices": NRCardRT.filter_list(NRBoard.installable_servers(state, card_to_install), func(x): return not NRCardRT.truthy((func(x): return NRCardRT.truthy(["HQ", "R&D", "Archives"].call(x) if ["HQ", "R&D", "Archives"] is Callable else ["HQ", "R&D", "Archives"])).call(x))),
										"async": true,
										"effect": func(state, side, eid, card, targets):
											var target = NRCardRT.first_target(targets)
											return NRInstalling.corp_install(state, side, eid, card_to_install, target, null),
									}
								).call(), target, null)
							, func(async_result):
								NREid.effect_completed(state, side, eid)),
					}, card, null)),
		}
		return {
			"on-play": {
				"async": true,
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					var corp = state.player("corp")
					return NREngine.resolve_ability(state, side, eid, ({
						"prompt": "Choose a card in HQ to keep private",
						"choices": {
							"req": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRCard.in_hand(target) and NRCard.corp(target),
							"all": true,
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							var corp = state.player("corp")
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, card, null, NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), func(x): return not NRCardRT.truthy((func(_pct):
									return NRUtil.same_card(_pct, target)).call(x))))
							, func(async_result):
								NREngine.resolve_ability(state, side, eid, gain_abi, card, null)),
					} if (NRCardRT.count_of(NRCardRT.getv(corp, "hand")) >= 2) else gain_abi), card, null),
			},
		}
	).call()))
	NRCardDefs.defcard("Petty Cash", NRUtil.merge({
		"title": "Petty Cash",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 0,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Play only if you have not finished an action yet this turn.\nGain 5[credit]. If you played this operation from anywhere except HQ, gain [click].\n[click]<strong>:</strong> Play this operation from Archives. After it resolves, remove it from the game."
	}, {
		"flashback": [NRPayment.to_c("click", 1)],
		"on-play": {
			"msg": "gain 5 [credits]",
			"async": true,
			"req": func(state, side, eid, card, targets):
				return NREvents.no_event(state, side, "action-resolved"),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 5)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, (_gain_n_clicks(1) if not NRCardRT.truthy(NRCardRT.some_list(NRCardRT.getv(card, "previous-zone"), func(x): return NRCardRT.truthy(["hand"].call(x) if ["hand"] is Callable else ["hand"]))) else null), card, null)),
		},
	}))
	NRCardDefs.defcard("Pivot", NRUtil.merge({
		"title": "Pivot",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"trash": 3,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nSearch R&D for 1 operation or agenda and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that card to HQ.\nThreat 3 → You may play or install 1 card from HQ. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
	}, {
		"on-play": {
			"prompt": "Choose a card",
			"waiting-prompt": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("reveal ") + str(NRCardRT.getv(target, "title")) + str(" from R&D and add it to HQ"),
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
					return (NRCard.operation(_pct) or NRCard.agenda(_pct)))),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return (NRCardRT.seq_of(NRCardRT.getv(corp, "deck")) or (NRThreat.threat(state, int(3)) and NRCardRT.seq_of(NRCardRT.getv(corp, "hand")))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, target)
				, func(async_result):
					NRShuffling.shuffle_zone(state, "corp", "deck")
					NRMoving.move(state, side, target, "hand")
					(NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card to play or install",
						"waiting-prompt": true,
						"choices": {
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.in_hand(_pct) and ((NRCardRT.getv(_pct, "cost") <= NRCardRT.getv(corp, "credit")) if NRCard.operation(_pct) else true)),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (func():
								var target_card = target
								return (NREngine.resolve_ability(state, side, eid, {
									"async": true,
									"msg": func(state, side, eid, card, targets):
										return str("play ") + str(NRCardRT.getv(target_card, "title")),
									"effect": func(state, side, eid, card, targets):
										return NRPlayInstants.play_instant(state, side, eid, target_card, null),
								}, card, null) if NRCard.operation(target_card) else NREngine.resolve_ability(state, side, eid, {
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NRInstalling.corp_install(
											state,
											side,
											eid,
											target_card,
											null,
											{
												"msg-keys": {
													"install-source": card,
													"display-origin": true,
												},
											}
										),
								}, card, null))
							).call(),
					}, card, null) if NRThreat.threat(state, int(3)) else NREid.effect_completed(state, side, eid))),
		},
	}))
	NRCardDefs.defcard("Power Grid Overload", NRUtil.merge({
		"title": "Power Grid Overload",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"text": "Play only if the Runner made a successful run during their last turn.\nTrace[2]. If successful, trash 1 installed piece of hardware with an install cost of X or less, where X is equal to the amount by which your trace strength exceeded the Runner's link strength."
	}, {
		"on-play": {
			"trace": {
				"base": 2,
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "made-run"),
				"successful": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var max_cost = (target - NRCardRT.getv(targets, 1))
							return NREngine.resolve_ability(state, side, eid, _trash_type(
								str("piece of hardware that costs ") + str(max_cost) + str(" or less"),
								func(_pct):
									return (NRCard.hardware(_pct) and (NRCardRT.getv(_pct, "cost") <= max_cost)),
								"loud"
							), card, null)
						).call(),
				},
			},
		},
	}))
	NRCardDefs.defcard("Power Shutdown", NRUtil.merge({
		"title": "Power Shutdown",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner made a run during their last turn.\nTrash any number of cards from the top of R&D. The Runner trashes an installed program or piece of hardware with an install cost equal to or less than the number of cards you trashed this way."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "made-run"),
			"prompt": "How many cards do you want to trash from the top of R&D?",
			"waiting-prompt": true,
			"choices": {
				"number": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.count_of(NRCardRT.getv(corp, "deck")),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRCardRT.quantify(target, "card")) + str(" from the top of R&D"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.mill(state, "corp", ne, "corp", target)
				, func(async_result):
					NREngine.resolve_ability(state, "runner", eid, (func():
						var n = target
						return {
							"async": true,
							"prompt": "Choose a Program or piece of Hardware to trash",
							"choices": {
								"card": func(_pct):
									return ((NRCard.hardware(_pct) or NRCard.program(_pct)) and (NRCardRT.getv(_pct, "cost") <= n)),
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
										"cause": "forced-to-trash",
									}
								),
						}
					).call(), card, null)),
		},
	}))
	NRCardDefs.defcard("Precognition", NRUtil.merge({
		"title": "Precognition",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"text": "Look at the top 5 cards of R&D and arrange them in any order."
	}, {
		"on-play": {
			"msg": "rearrange the top 5 cards of R&D",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NREngine.resolve_ability(state, side, eid, (func():
					var from = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5))
					return (reorder_choice("corp", "runner", from, null, NRCardRT.count_of(from), from) if NRCardRT.truthy(NRCardRT.pos(NRCardRT.count_of(from))) else null)
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Predictive Algorithm", NRUtil.merge({
		"title": "Predictive Algorithm",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAs an additional cost to steal an agenda, the Runner must pay 2[credit]."
	}, {
		"static-abilities": [
			{
				"type": "steal-additional-cost",
				"value": func(state, side, eid, card, targets):
					return NRPayment.to_c("credit", 2),
			}
		],
	}))
	NRCardDefs.defcard("Predictive Planogram", NRUtil.merge({
		"title": "Predictive Planogram",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Resolve 1 of the following. If the Runner is tagged, you may resolve both instead.<ul><li>Gain 3[credit].</li><li>Draw 3 cards.</li></ul>"
	}, {
		"on-play": {
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return [
					"Gain 3 [Credits]",
					"Draw 3 cards",
					("Gain 3 [Credits] and draw 3 cards" if NRCardRT.truthy(tagged) else null)
				],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str(NRCardRT.decapitalize(target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NRGaining.gain_credits(state, "corp", eid, 3) if ((target == "Gain 3 [Credits]") or NRUtil.kw_eq(target, "Gain 3 [Credits]")) else (NRDrawing.draw(state, "corp", eid, 3) if ((target == "Draw 3 cards") or NRUtil.kw_eq(target, "Draw 3 cards")) else (NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, "corp", ne, 3)
				, func(async_result):
					NRDrawing.draw(state, "corp", eid, 3)) if ((target == "Gain 3 [Credits] and draw 3 cards") or NRUtil.kw_eq(target, "Gain 3 [Credits] and draw 3 cards")) else NREid.effect_completed(state, side, eid)))),
		},
	}))
	NRCardDefs.defcard("Preemptive Action", NRUtil.merge({
		"title": "Preemptive Action",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Terminal",
		"subtypes": ["Terminal"],
		"text": "After you resolve this operation, end your action phase.\nShuffle 3 cards from Archives into R&D. Remove Preemptive Action from the game instead of trashing it."
	}, {
		"on-play": {
			"rfg-instead-of-trashing": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "discard")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return shuffle_into_rd_effect(state, side, eid, card, 3, true),
		},
	}))
	NRCardDefs.defcard("Priority Construction", NRUtil.merge({
		"title": "Priority Construction",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nInstall a piece of ice from HQ protecting a remote server (ignoring all costs). Place 3 advancement tokens on that ice."
	}, {
		"on-play": {
			"prompt": "Choose a piece of ice in HQ to install",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.in_hand(_pct) and NRCard.corp(_pct) and NRCard.ice(_pct)),
			},
			"msg": "install a piece of ice from HQ and place 3 advancements on it",
			"cancel": {
				"msg": "do nothing",
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, _install_card_25(target), card, null),
		},
	}))
	NRCardDefs.defcard("Product Recall", NRUtil.merge({
		"title": "Product Recall",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Alliance",
		"subtypes": ["Alliance"],
		"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [haas-bioroid] cards in your deck.\nTrash a rezzed asset or upgrade. If you do, gain credits equal to its trash cost."
	}, {
		"on-play": {
			"prompt": "Choose a rezzed asset or upgrade to trash",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return (NRCard.rezzed(_pct) and (NRCard.asset(_pct) or NRCard.upgrade(_pct)))),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.rezzed(_pct) and (NRCard.asset(_pct) or NRCard.upgrade(_pct))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRToString.card_str(state, target)) + str(" and gain ") + str(NRCostFns.trash_cost(state, side, target)) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, target, {
						"unpreventable": true,
						"cause-card": card,
					})
				, func(async_result):
					NRGaining.gain_credits(state, "corp", eid, NRCostFns.trash_cost(state, side, target))),
		},
	}))
	NRCardDefs.defcard("Psychographics", NRUtil.merge({
		"title": "Psychographics",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"factioncost": 3,
		"text": "X must be equal to or less than the number of tags the Runner has.\nPlace X advancement counters on 1 installed card you can advance."
	}, {
		"on-play": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged and NRCardRT.pos(NRPayment.x_cost_value(eid)),
			},
			"waiting-prompt": true,
			"base-play-cost": [
				NRPayment.to_c("x-credits", 0, {
					"maximum": func(state, side, eid, card, targets):
						return count_tags(state),
				})
			],
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.can_be_advanced(state, target),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("place ") + str(NRCardRT.quantify(NRPayment.x_cost_value(eid), " advancement counter")) + str(" on ") + str(NRToString.card_str(state, target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NRProps.add_prop(
					state,
					side,
					eid,
					target,
					"advance-counter",
					NRPayment.x_cost_value(eid),
					{
						"placed": true,
					}
				),
		},
	}))
	NRCardDefs.defcard("Psychokinesis", NRUtil.merge({
		"title": "Psychokinesis",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Terminal",
		"subtypes": ["Terminal"],
		"text": "After you resolve this operation, end your action phase.\nLook at the top 5 cards of R&D. If any of those cards are agendas, assets, or upgrades, you may install 1 of those cards in a remote server."
	}, {
		"on-play": {
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"msg": "look at the top 5 cards of R&D",
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return NREngine.resolve_ability(state, side, eid, (func():
					var top_five = NRCardRT.take_n(NRCardRT.getv(corp, "deck"), int(5))
					return {
						"prompt": str("The top cards of R&D are (top->bottom): ") + str(NRCardRT.enumerate_cards(top_five)),
						"waiting-prompt": true,
						"choices": ["OK"],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREngine.resolve_ability(state, side, eid, {
								"prompt": "Choose an agenda, asset, or upgrade to install",
								"waiting-prompt": true,
								"async": true,
								"choices": NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(top_five, func(_pct):
									return (NRCard.corp_installable_type(_pct) and NRCardRT.some_list(NRBoard.installable_servers(state, _pct), func(x): return NRCardRT.truthy(["New remote"].call(x) if ["New remote"] is Callable else ["New remote"])))))),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NREngine.resolve_ability(state, side, eid, _install_card_26(target), card, null),
							}, card, null),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Public Trail", NRUtil.merge({
		"title": "Public Trail",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner made a successful run during their last turn.\nGive the Runner 1 tag unless they pay 8[credit]."
	}, {
		"on-play": NRCardRT.choose_one_helper(
			{
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "successful-run"),
				"player": "runner",
			},
			[
				{
					"option": "Take 1 tag",
					"ability": {
						"async": true,
						"display-side": "corp",
						"msg": "give the runner 1 tag",
						"effect": func(state, side, eid, card, targets):
							return NRTags.gain_tags(state, "corp", eid, 1),
					},
				},
				NRCardRT.cost_option([NRPayment.to_c("credit", 8)], "runner")
			]
		),
	}))
	NRCardDefs.defcard("Punitive Counterstrike", NRUtil.merge({
		"title": "Punitive Counterstrike",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "Trace[5]. If successful, do X meat damage. X is equal to the sum of the printed agenda points on all agendas the Runner stole during their last turn."
	}, {
		"on-play": {
			"trace": {
				"base": 5,
				"successful": {
					"async": true,
					"msg": func(state, side, eid, card, targets):
						return str("do ") + str(NRCardRT.getv(runner_reg_last, "stole-agenda", 0)) + str(" meat damage"),
					"effect": func(state, side, eid, card, targets):
						return NRDamage.damage(
							state,
							side,
							eid,
							"meat",
							NRCardRT.getv(runner_reg_last, "stole-agenda", 0),
							{
								"card": card,
							}
						),
				},
			},
		},
	}))
	NRCardDefs.defcard("realloc()", NRUtil.merge({
		"title": "realloc()",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nChoose 2 rezzed pieces of ice. For each chosen piece of ice, gain credits equal to its printed rez cost, then derez it."
	}, {
		"on-play": {
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.seq_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.rezzed(x)) and NRCardRT.truthy(NRCard.ice(x))))),
			},
			"waiting-prompt": true,
			"prompt": func(state, side, eid, card, targets):
				return str("choose ") + str(NRCardRT.quantify(mini(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.rezzed(x)) and NRCardRT.truthy(NRCard.ice(x))))), 2), "piece")) + str(" of ice to derez"),
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.rezzed(target) and NRCard.ice(target) and NRCard.installed(target),
				"all": true,
				"max": func(state, side, eid, card, targets):
					return mini(NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.rezzed(x)) and NRCardRT.truthy(NRCard.ice(x))))), 2),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets):
				return str("derez ") + str(NRCardRT.enumerate_cards(targets)) + str(" and gain ") + str(reduce(_, 0, mapv("cost", targets))) + str(" [Credits]"),
			"effect": func(state, side, eid, card, targets):
				return (func():
					var c = reduce(_, 0, mapv("cost", targets))
					return NREid.wait_for(state, eid, func(ne):
						NRRezzing.derez(state, side, ne, targets)
					, func(async_result):
						NRGaining.gain_credits(state, side, eid, c))
				).call(),
		},
	}))
	NRCardDefs.defcard("Reanimation Protocol", NRUtil.merge({
		"title": "Reanimation Protocol",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Liability",
		"subtypes": ["Liability"],
		"text": "Install and rez 1 piece of ice from Archives, paying a total of 10[credit] less. If you rezzed a piece of non-<strong>liability</strong> ice this way, take 1 bad publicity."
	}, {
		"on-play": {
			"prompt": "Choose an Ice to install and rez (paying a total of 10 less)",
			"show-discard": true,
			"choices": {
				"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.corp(x)) and NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.in_discard(x))),
			},
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.corp_install(state, side, ne, target, null, {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
						"install-state": "rezzed",
						"combined-credit-discount": 10,
					})
				, func(async_result):
					(func():
						var installed_card = async_result
						return (NREid.effect_completed(state, side, eid) if NRCardRT.truthy((NRCard.rezzed(installed_card) and NRCard.has_any_subtype(installed_card, ["Liability", "Illicit"]))) else (NREngine.resolve_ability(state, side, eid, {
						"msg": "take 1 bad publicity",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRBadPublicity.gain_bad_publicity(state, side, eid, 1),
					}, card, null) if NRCardRT.truthy(NRCard.rezzed(installed_card)) else NREid.effect_completed(state, side, eid))) if installed_card != null and NRCardRT.truthy(installed_card) else NREid.effect_completed(state, side, eid)
					).call()),
		},
	}))
	NRCardDefs.defcard("Reclamation Order", NRUtil.merge({
		"title": "Reclamation Order",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nName a card other than Reclamation Order. Reveal any number of copies of the named card from Archives and add them to HQ."
	}, {
		"on-play": {
			"prompt": "Choose a card from Archives",
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and (not ((NRCardRT.getv(_pct, "title") == "Reclamation Order") or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), "Reclamation Order"))) and NRCard.in_discard(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("name ") + str(NRCardRT.getv(target, "title")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return (func():
					var title = NRCardRT.getv(target, "title")
					var cards = NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return ((title == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(title, NRCardRT.getv(_pct, "title"))))
					var n = NRCardRT.count_of(cards)
					return NREngine.resolve_ability(state, side, eid, {
						"prompt": str("How many copies of ") + str(title) + str(" do you want to reveal?"),
						"choices": {
							"number": func(state, side, eid, card, targets):
								return n,
						},
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("reveal ") + str(NRCardRT.quantify(target, "cop", "y", "ies")) + str(" of ") + str(title) + str(" from Archives") + str((str(" and add ") + str(("it" if ((1 == target) or NRUtil.kw_eq(1, target)) else "them")) + str(" to HQ") if NRCardRT.truthy(NRCardRT.pos(target)) else null)),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, cards)
							, func(async_result):
								(func():
									for c in NRCardRT.as_array(NRCardRT.take_n(NRCardRT.as_array(NRCardRT.as_array(cards)), int(target))):
										NRMoving.move(state, side, c, "hand")
									return null
								).call()
								NREid.effect_completed(state, side, eid)),
					}, card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("Recruiting Trip", NRUtil.merge({
		"title": "Recruiting Trip",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"factioncost": 1,
		"text": "Search R&D for up to X different <strong>sysops</strong> (by title), reveal them, and add them to HQ. Shuffle R&D."
	}, (func():
		var rthelp = func(total, left, selected):
			return ({
			"prompt": str("Choose a Sysop (") + str((int((total - left)) + 1)) + str("/") + str(total) + str(")"),
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRPrompts.cancellable(NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), func(_pct):
					return (NRCard.has_subtype(_pct, "Sysop") and (not NRCardRT.some_list(selected, func(x): return NRCardRT.truthy([NRCardRT.getv(_pct, "title")].call(x) if [NRCardRT.getv(_pct, "title")] is Callable else [NRCardRT.getv(_pct, "title")]))))))),
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("add ") + str(NRCardRT.getv(target, "title")) + str(" to HQ"),
			"async": true,
			"cancel": NRShuffling.shuffle_deck,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRMoving.move(state, side, target, "hand")
				return NREngine.resolve_ability(state, side, eid, rt(total, (int(left) - 1), ([NRCardRT.getv(target, "title")] + NRCardRT.as_array(selected))), card, null),
		} if NRCardRT.pos(left) else NRShuffling.shuffle_deck)
		return {
			"on-play": {
				"base-play-cost": [NRPayment.to_c("x-credits")],
				"msg": func(state, side, eid, card, targets):
					return str("search for ") + str(NRPayment.x_cost_value(eid)) + str(" Sysops"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, rthelp(NRPayment.x_cost_value(eid), NRPayment.x_cost_value(eid), []), card, null),
			},
		}
	).call()))
	NRCardDefs.defcard("Red Level Clearance", NRUtil.merge({
		"title": "Red Level Clearance",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Resolve 2 of the following in any order:<ul><li>Draw 2 cards.</li><li>Gain 2[credit].</li><li>Install 1 non-agenda card from HQ.</li><li>Gain [click].</li></ul>"
	}, (func():
		var all = [
			{
				"msg": "gain 2 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 2),
			},
			{
				"msg": "draw 2 cards",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRDrawing.draw(state, side, eid, 2),
			},
			_gain_n_clicks(1),
			{
				"prompt": "Choose a non-agenda to install",
				"msg": "install a non-agenda from hand",
				"choices": {
					"card": func(_pct):
						return ((not NRCardRT.truthy(NRCard.agenda(_pct))) and NRCard.corp_installable_type(_pct) and NRCard.in_hand(_pct)),
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
							"msg-keys": {
								"install-source": card,
								"display-origin": true,
							},
						}
					),
			}
		]
		var can_install = func(hand):
			return NRCardRT.seq_of(NRCardRT.filter_list(hand, func(x): return not NRCardRT.truthy((func(_pct):
				return (NRCard.agenda(_pct) or NRCard.operation(_pct))).call(x))))
		var choice = func(abis, chose_once):
			return {
			"prompt": "Choose an ability to resolve",
			"choices": NRCardRT.map_list(abis, func(_pct):
				return str(NRCardRT.getv(_pct, "msg"))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return (func():
					var chosen = NRCardRT.some_list(abis, func(_pct):
						return (_pct if NRCardRT.truthy(((target == str(NRCardRT.getv(_pct, "msg"))) or NRUtil.kw_eq(target, str(NRCardRT.getv(_pct, "msg"))))) else null))
					return (NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, chosen, card, null)
					, func(async_result):
						(NREngine.resolve_ability(state, side, eid, choice(
							NRCardRT.filter_list(abis, func(x): return not NRCardRT.truthy((func(_pct):
								return ((_pct == chosen) or NRUtil.kw_eq(_pct, chosen))).call(x))),
							true
						), card, null) if (chose_once == false) else NREid.effect_completed(state, side, eid))) if ((not ((target == "Install a non-agenda from hand") or NRUtil.kw_eq(target, "Install a non-agenda from hand"))) or (((target == "Install a non-agenda from hand") or NRUtil.kw_eq(target, "Install a non-agenda from hand")) and can_install(NRCardRT.getv(corp, "hand")))) else NREngine.resolve_ability(state, side, eid, choice(abis, chose_once), card, null))
				).call(),
		}
		return {
			"on-play": {
				"waiting-prompt": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, choice(all, false), card, null),
			},
		}
	).call()))
	NRCardDefs.defcard("Red Planet Couriers", NRUtil.merge({
		"title": "Red Planet Couriers",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 5,
		"factioncost": 4,
		"keywords": "Triple",
		"subtypes": ["Triple"],
		"text": "As an additional cost to play this operation, spend [click], [click].\nMove all advancement tokens from all installed cards to 1 card that can be advanced."
	}, {
		"on-play": {
			"prompt": "Choose an installed card that can be advanced",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.can_be_advanced(state, target),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return something_can_be_advanced(state),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var installed = NRCard.installed(card) if card is Dictionary else false
				return (func():
					var installed = NRBoard.get_all_installed(state)
					var total_adv = reduce(
						_,
						NRCardRT.map_list(installed, func(_pct):
							return NRCard.get_counters(_pct, "advancement"))
					)
					return NREid.wait_for(state, eid, func(ne):
						_clear_counters_27()(state, side, ne, installed)
					, func(async_result):
						NREid.wait_for(state, eid, func(ne):
							NRProps.add_prop(state, side, ne, target, "advance-counter", total_adv, {
								"placed": true,
							})
						, func(async_result):
							NRIce.update_all_ice(state, side)
							NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to move ") + str(NRCardRT.quantify(total_adv, "advancement counter")) + str(" to ") + str(NRToString.card_str(state, target)))
							NREid.effect_completed(state, side, eid)))
				).call(),
		},
	}))
	NRCardDefs.defcard("Replanting", NRUtil.merge({
		"title": "Replanting",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nAdd one of your installed cards to HQ. Install 2 cards from HQ, ignoring all costs."
	}, {
		"on-play": {
			"prompt": "Choose an installed card to add to HQ",
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("add ") + str(NRToString.card_str(state, target)) + str(" to HQ, then install 2 cards ignoring all costs"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRMoving.move(state, side, target, "hand")
				return NREngine.resolve_ability(state, side, eid, _replant_28(1), card, null),
		},
	}))
	NRCardDefs.defcard("Restore", NRUtil.merge({
		"title": "Restore",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"text": "Install and rez 1 card from Archives (paying all costs). Remove all other copies of that card in Archives from the game."
	}, {
		"on-play": {
			"prompt": "Choose a card in Archives to install & rez",
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct))) and NRCard.in_discard(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRInstalling.corp_install(state, side, ne, target, null, {
						"install-state": "rezzed",
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					})
				, func(async_result):
					(func():
						var leftover = NRCardRT.filter_list(NRCardRT.getv(NRCardRT.getv(state.data, "corp"), "discard"), func(_pct):
							return ((NRCardRT.getv(target, "title") == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(NRCardRT.getv(target, "title"), NRCardRT.getv(_pct, "title"))))
						return ((func():
							(func():
								for c in NRCardRT.as_array(leftover):
									NRMoving.move(state, side, c, "rfg")
								return null
							).call()
							return NRSay.system_msg(state, side, str("removes ") + str(NRCardRT.count_of(leftover)) + str(" copies of ") + str(NRCardRT.getv(target, "title")) + str(" from the game"))
						).call() if NRCardRT.truthy(NRCardRT.seq_of(leftover)) else null)
					).call()
					NREid.effect_completed(state, side, eid)),
		},
	}))
	NRCardDefs.defcard("Restoring Face", NRUtil.merge({
		"title": "Restoring Face",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"text": "Reveal and trash 1 of your installed <strong>sysop</strong>, <strong>executive</strong>, or <strong>clone</strong> cards. If you do, remove up to 2 bad publicity."
	}, {
		"on-play": {
			"prompt": "Choose a Sysop, Executive or Clone to trash",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRCardRT.getv(target, "title")) + str(" to remove 2 bad publicity"),
			"choices": {
				"card": func(_pct):
					return NRCard.has_any_subtype(_pct, ["Clone", "Executive", "Sysop"]),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRBadPublicity.lose_bad_publicity(state, side, ne, 2)
				, func(async_result):
					NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, ({
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return NRRevealing.reveal(state, side, eid, target),
						} if NRCardRT.truthy(NRCard.facedown(target)) else null), card, targets)
					, func(async_result):
						NRMoving.trash(
							state,
							side,
							eid,
							target,
							{
								"cause-card": card,
							}
						))),
		},
	}))
	NRCardDefs.defcard("Restructure", NRUtil.merge({
		"title": "Restructure",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 10,
		"factioncost": 0,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 15[credit]."
	}, {
		"on-play": NRDefHelpers.gain_credits_ability(15),
	}))
	NRCardDefs.defcard("Retirement Plan", NRUtil.merge({
		"title": "Retirement Plan",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nInstall 1 agenda, asset, or piece of ice from Archives."
	}, {
		"on-play": {
			"prompt": "Install an Asset, Ice or Agenda from Archives",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
						return (NRCard.asset(_pct) or NRCard.ice(_pct) or NRCard.agenda(_pct) or (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen"))))),
			},
			"show-discard": true,
			"not-distinct": true,
			"choices": {
				"card": func(_pct):
					return ((NRCard.ice(_pct) or NRCard.asset(_pct) or NRCard.agenda(_pct)) and NRCard.corp(_pct) and NRCard.in_discard(_pct)),
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
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}
				),
		},
	}))
	NRCardDefs.defcard("Retribution", NRUtil.merge({
		"title": "Retribution",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nTrash 1 installed program or piece of hardware."
	}, {
		"on-play": _trash_type(
			"program of piece of hardware",
			func(_pct):
				return (NRCard.program(_pct) or NRCard.hardware(_pct)),
			"loud",
			1,
			null,
			{
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
			}
		),
	}))
	NRCardDefs.defcard("Reuse", NRUtil.merge({
		"title": "Reuse",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nTrash any number of cards from HQ. Gain 2[credit] for each card trashed."
	}, {
		"on-play": {
			"prompt": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str("Choose up to ") + str(NRCardRT.quantify(NRCardRT.count_of(NRCardRT.getv(corp, "hand")), "card")) + str(" in HQ to trash"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"choices": {
				"max": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.count_of(NRCardRT.getv(corp, "hand")),
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				return str((func():
					var m = NRCardRT.count_of(targets)
					return str("trash ") + str(NRCardRT.quantify(m, "card")) + str(" and gain ") + str((2 * m)) + str(" [Credits]")
				).call()),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var async_result = NREid.result_of(eid)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash_cards(state, side, ne, targets, {
						"unpreventable": true,
						"cause-card": card,
					})
				, func(async_result):
					NRGaining.gain_credits(state, side, eid, (2 * NRCardRT.count_of(async_result)))),
		},
	}))
	NRCardDefs.defcard("Reverse Infection", NRUtil.merge({
		"title": "Reverse Infection",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Choose one:<ul><li>Purge virus counters. Trash 1 card from the top of the stack for every 3 virus counters removed.</li><li>Gain 2[credit].</li></ul>"
	}, {
		"on-play": {
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": ["Purge virus counters", "Gain 2 [Credits]"],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 2)
				, func(async_result):
					NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to gain 2 [Credits]"))
					NREid.effect_completed(state, side, eid)) if ((target == "Gain 2 [Credits]") or NRUtil.kw_eq(target, "Gain 2 [Credits]")) else (func():
						var pre_purge_virus = NRVirus.number_of_virus_counters(state)
						return NREid.wait_for(state, eid, func(ne):
							NRPurging.purge(state, side, ne)
						, func(async_result):
							(func():
								var post_purge_virus = NRVirus.number_of_virus_counters(state)
								var num_virus_purged = (pre_purge_virus - post_purge_virus)
								var num_to_trash = quot(num_virus_purged, 3)
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.mill(state, "corp", ne, "runner", num_to_trash)
								, func(async_result):
									NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to purge ") + str(NRCardRT.quantify(num_virus_purged, "virus counter")) + str(" and trash ") + str(NRCardRT.quantify(num_to_trash, "card")) + str(" from the top of the stack"))
									NREid.effect_completed(state, side, eid))
							).call())
				).call()),
		},
	}))
	NRCardDefs.defcard("Rework", NRUtil.merge({
		"title": "Rework",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Shuffle 1 card from HQ into R&D."
	}, {
		"on-play": {
			"prompt": "Choose a card from HQ to shuffle into R&D",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"msg": "shuffle a card from HQ into R&D",
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				NRMoving.move(state, side, target, "deck")
				return NRShuffling.shuffle_zone(state, side, "deck"),
		},
	}))
	NRCardDefs.defcard("Riot Suppression", NRUtil.merge({
		"title": "Riot Suppression",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 4,
		"keywords": "Reprisal - Gray Ops",
		"subtypes": ["Reprisal", "Gray Ops"],
		"text": "Play only if the Runner trashed a Corp card during their last turn.\nThe Runner may suffer 1 core damage. If they do not, they get -3 allotted [click] for their next turn.\nRemove this operation from the game."
	}, {
		"on-play": {
			"rfg-instead-of-trashing": true,
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "trashed-card"),
			"player": "runner",
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose one",
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("force the Runner to ") + str(NRCardRT.decapitalize(target)),
			"choices": ["Suffer 1 core damage", "Get 3 fewer [Click] on the next turn"],
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (NREngine.pay(state, "runner", eid, card, [NRPayment.to_c("brain", 1)]) if ((target == "Suffer 1 core damage") or NRUtil.kw_eq(target, "Suffer 1 core damage")) else (func():
					state.update_in(["runner", "extra-click-temp"], func(v): return v)
					return NREid.effect_completed(state, side, eid)
				).call()),
		},
	}))
	NRCardDefs.defcard("Rolling Brownout", NRUtil.merge({
		"title": "Rolling Brownout",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 1,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe play cost of each operation and event is increased by 1.\nThe first time the Runner plays an event each turn, gain 1[credit]."
	}, {
		"on-play": {
			"msg": "increase the play cost of operations and events by 1 [Credits]",
		},
		"static-abilities": [
			{
				"type": "play-cost",
				"value": 1,
			}
		],
		"events": [
			{
				"event": "play-event",
				"req": func(state, side, eid, card, targets):
					return NREvents.first_event(state, side, "play-event"),
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, "corp", eid, 1),
			}
		],
	}))
	NRCardDefs.defcard("Rover Algorithm", NRUtil.merge({
		"title": "Rover Algorithm",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 0,
		"text": "Install Rover Algorithm on a rezzed piece of ice as a hosted condition counter with the text \"Host ice has +1 strength for each power counter on Rover Algorithm. Whenever the Runner passes host ice, place 1 power counter on Rover Algorithm.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.rezzed(x)))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("host itself as a condition counter on ") + str(NRToString.card_str(state, target)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return install_as_condition_counter(state, side, eid, card, target),
		},
		"static-abilities": [
			{
				"type": "ice-strength",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.getv(card, "host")),
				"value": func(state, side, eid, card, targets):
					return NRCard.get_counters(card, "power"),
			}
		],
		"events": [
			{
				"event": "pass-ice",
				"condition": "hosted",
				"req": func(state, side, eid, card, targets):
					var context = NRCardRT.ctx(targets)
					return NRUtil.same_card(NRCardRT.getv(context, "ice"), NRCardRT.getv(card, "host")),
				"msg": "place 1 power counter on itself",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRProps.add_counter(state, side, eid, card, "power", 1, null),
			}
		],
	}))
	NRCardDefs.defcard("Sacrifice", NRUtil.merge({
		"title": "Sacrifice",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "As an additional cost to play this operation, forfeit 1 agenda.\nRemove X bad publicity. X is equal to the agenda point value of the forfeited agenda. Gain 1[credit] for each bad publicity removed this way."
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("forfeit")],
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(count_bad_pub(state)),
			},
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (func():
					var bp_lost = maxi(0, mini(NRCardRT.getv((func(a): return null if a.is_empty() else a[a.size()-1]).call(NRCardRT.as_array(NRCardRT.getv(corp, "rfg"))), "agendapoints"), count_bad_pub(state)))
					NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to lose ") + str(bp_lost) + str(" bad publicity and gain ") + str(bp_lost) + str(" [Credits]"))
					return (NREid.wait_for(state, eid, func(ne):
						NRBadPublicity.lose_bad_publicity(state, side, ne, bp_lost)
					, func(async_result):
						NRGaining.gain_credits(state, side, eid, bp_lost)) if NRCardRT.pos(bp_lost) else NREid.effect_completed(state, side, eid))
				).call(),
		},
	}))
	NRCardDefs.defcard("Salem's Hospitality", NRUtil.merge({
		"title": "Salem's Hospitality",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 4,
		"keywords": "Alliance - Gray Ops",
		"subtypes": ["Alliance", "Gray Ops"],
		"text": "This operation costs 0 influence if you have 6 or more non-<strong>alliance</strong> [nbn] cards in your deck.\nChoose a card name. The Runner reveals the grip and trashes all cards with the chosen name revealed this way."
	}, {
		"on-play": {
			"prompt": "Name a Runner card",
			"choices": {
				"card-title": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return (NRCard.runner(target) and (not NRCardRT.truthy(NRCard.identity(target)))),
			},
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return str("reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.getv(runner, "hand"), "sorted")) + str(" from the grip and trash any copies of ") + str(target),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return (func():
					var cards = NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
						return ((target == NRCardRT.getv(_pct, "title")) or NRUtil.kw_eq(target, NRCardRT.getv(_pct, "title"))))
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, cards)
					, func(async_result):
						NRMoving.trash_cards(
							state,
							side,
							eid,
							cards,
							{
								"unpreventable": true,
								"cause-card": card,
							}
						))
				).call(),
		},
	}))
	NRCardDefs.defcard("Scapegoat", NRUtil.merge({
		"title": "Scapegoat",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Resolve 1 of the following of the Runner’s choice:<ul><li>Remove 2 bad publicity.</li><li>Choose 1 installed Runner card. The Runner shuffles it into the stack.</li></ul>"
	}, {
		"on-play": NRCardRT.choose_one_helper(
			{
				"player": "runner",
			},
			[
				{
					"option": "Corp removes 2 bad publicity",
					"ability": {
						"async": true,
						"display-side": "corp",
						"msg": "remove 2 bad publicity",
						"effect": func(state, side, eid, card, targets):
							return NRBadPublicity.lose_bad_publicity(state, "corp", eid, 2),
					},
				},
				{
					"option": "Corp shuffles 1 Runner card into the Stack",
					"ability": {
						"change-in-game-state": {
							"req": func(state, side, eid, card, targets):
								return NRCardRT.seq_of(NRBoard.all_installed(state, "runner")),
						},
						"player": "corp",
						"prompt": "Shuffle an installed Runner card into the stack",
						"choices": {
							"max": 1,
							"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.runner(x)) and NRCardRT.truthy(NRCard.installed(x))),
							"all": true,
						},
						"display-side": "corp",
						"msg": func(state, side, eid, card, targets):
							return str("shuffle ") + str(enumerate_str(NRCardRT.map_list(targets, func(x): return NRCardRT.getv(x, "title")))) + str(" into the Stack"),
						"effect": func(state, side, eid, card, targets):
							(func():
								for t in NRCardRT.as_array(targets):
									NRMoving.move(state, "runner", t, "deck")
								return null
							).call()
							return NRShuffling.shuffle_zone(state, "runner", "deck"),
					},
				}
			]
		),
	}))
	NRCardDefs.defcard("Scapenet", NRUtil.merge({
		"title": "Scapenet",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner made a successful run during their last turn.\nTrace[7]. If successful, remove 1 installed <strong>chip</strong> or <strong>virtual</strong> card from the game."
	}, {
		"on-play": {
			"trace": {
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "successful-run"),
				"base": 7,
				"successful": {
					"prompt": "Choose an installed virtual or chip card to remove from game",
					"choices": {
						"card": func(_pct):
							return (NRCard.installed(_pct) and (NRCard.has_subtype(_pct, "Virtual") or NRCard.has_subtype(_pct, "Chip"))),
					},
					"msg": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return str("remove ") + str(NRToString.card_str(state, target)) + str(" from game"),
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRMoving.move(state, "runner", target, "rfg"),
				},
			},
		},
	}))
	NRCardDefs.defcard("Scarcity of Resources", NRUtil.merge({
		"title": "Scarcity of Resources",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 0,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe install cost of each resource is increased by 2."
	}, {
		"on-play": {
			"msg": "increase the install cost of resources by 2",
		},
		"static-abilities": [
			{
				"type": "install-cost",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.resource(target),
				"value": 2,
			}
		],
	}))
	NRCardDefs.defcard("Scorched Earth", NRUtil.merge({
		"title": "Scorched Earth",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 4,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "Play only if the Runner is tagged.\nDo 4 meat damage."
	}, {
		"on-play": NRUtil.merge(NRDefHelpers.do_meat_damage(4), {"req": func(state, side, eid, card, targets):
			var tagged = NRUtil.is_tagged(state)
			return tagged}),
	}))
	NRCardDefs.defcard("SEA Source", NRUtil.merge({
		"title": "SEA Source",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"text": "Play only if the Runner made a successful run during their last turn.\nTrace[3]. If successful, give the Runner 1 tag."
	}, {
		"on-play": {
			"trace": {
				"base": 3,
				"req": func(state, side, eid, card, targets):
					return NREvents.last_turn(state, "runner", "successful-run"),
				"label": "Trace 3 - Give the Runner 1 tag",
				"successful": NRDefHelpers.give_tags(1),
			},
		},
	}))
	NRCardDefs.defcard("Seamless Launch", NRUtil.merge({
		"title": "Seamless Launch",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"text": "Place 2 advancement counters on 1 installed card that you did not install this turn."
	}, {
		"on-play": NRUtil.merge(place_advancement_counter(
			null,
			2,
			"an installed card",
			func(_pct):
				return (not (("this-turn" == NRCard.installed(_pct)) or NRUtil.kw_eq("this-turn", NRCard.installed(_pct))))
		), {"change-in-game-state": {
			"req": func(state, side, eid, card, targets):
				return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
					return (NRCard.corp(_pct) and NRCard.installed(_pct) and (not (("this-turn" == NRCard.installed(_pct)) or NRUtil.kw_eq("this-turn", NRCard.installed(_pct)))))),
		}}),
	}))
	NRCardDefs.defcard("Secure and Protect", NRUtil.merge({
		"title": "Secure and Protect",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nSearch R&D for 1 piece of ice and reveal it. <em>(Shuffle R&D after searching it.)</em> Install that ice protecting a central server, paying 3[credit] less."
	}, {
		"on-play": {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "deck")),
			},
			"waiting-prompt": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var corp = state.player("corp")
				return (NREngine.resolve_ability(state, side, eid, {
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
								"prompt": "Choose a server",
								"choices": ["Archives", "R&D", "HQ"],
								"msg": func(state, side, eid, card, targets):
									return str("reveal ") + str(NRCardRT.getv(chosen_ice, "title")) + str(" from R&D and install it, paying 3 [Credit] less"),
								"effect": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NREid.wait_for(state, eid, func(ne):
										NRRevealing.reveal(state, side, ne, chosen_ice)
									, func(async_result):
										NRShuffling.shuffle_zone(state, side, "deck")
										NRInstalling.corp_install(
											state,
											side,
											eid,
											chosen_ice,
											target,
											{
												"cost-bonus": -3,
												"msg-keys": {
													"install-source": card,
													"display-origin": true,
												},
											}
										)),
							}
						).call(), card, null),
				}, card, null) if NRCardRT.seq_of(NRCardRT.filter_list(NRCardRT.getv(corp, "deck"), NRCard.ice)) else (func():
					NRShuffling.shuffle_zone(state, side, "deck")
					return NREid.effect_completed(state, side, eid)
				).call()),
		},
	}))
	NRCardDefs.defcard("Self-Growth Program", NRUtil.merge({
		"title": "Self-Growth Program",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nAdd 2 installed Runner cards to the grip."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"prompt": "Choose 2 installed Runner cards",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.seq_of(NRBoard.all_installed(state, "runner")),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.installed(_pct) and NRCard.runner(_pct)),
				"max": 2,
			},
			"msg": func(state, side, eid, card, targets):
				return str("move ") + str(NRCardRT.enumerate_cards(targets)) + str(" to the grip"),
			"effect": func(state, side, eid, card, targets):
				return (func():
					for c in NRCardRT.as_array(targets):
						NRMoving.move(state, "runner", c, "hand")
					return null
				).call(),
		},
	}))
	NRCardDefs.defcard("Service Outage", NRUtil.merge({
		"title": "Service Outage",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAs an additional cost to run for the first time during their turn, the Runner must spend 1[credit]."
	}, {
		"on-play": {
			"msg": "add a cost of 1 [Credit] for the Runner to make the first run each turn",
		},
		"static-abilities": [
			{
				"type": "run-additional-cost",
				"req": func(state, side, eid, card, targets):
					return NREvents.no_event(state, side, "run"),
				"value": [NRPayment.to_c("credit", 1)],
			}
		],
	}))
	NRCardDefs.defcard("Shipment from Kaguya", NRUtil.merge({
		"title": "Shipment from Kaguya",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Place 1 advancement token on each of up to 2 different installed cards that can be advanced."
	}, {
		"on-play": {
			"choices": {
				"max": 2,
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.corp(target) and NRCard.installed(target) and NRCard.can_be_advanced(state, target),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return something_can_be_advanced(state),
			},
			"msg": func(state, side, eid, card, targets):
				return str("place 1 advancement counters on ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
					var _v_29 = targets
					var f1 = NRCardRT.getv(_v_29, 0)
					var f2 = NRCardRT.getv(_v_29, 1)
					return (NREid.wait_for(state, eid, func(ne):
						NRProps.add_prop(state, "corp", ne, f1, "advance-counter", 1, {
							"placed": true,
						})
					, func(async_result):
						NRProps.add_prop(
							state,
							"corp",
							eid,
							f2,
							"advance-counter",
							1,
							{
								"placed": true,
							}
						)) if f2 else NRProps.add_prop(
						state,
						"corp",
						eid,
						f1,
						"advance-counter",
						1,
						{
							"placed": true,
						}
					))
				).call(),
		},
	}))
	NRCardDefs.defcard("Shipment from MirrorMorph", NRUtil.merge({
		"title": "Shipment from MirrorMorph",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"text": "Install up to 3 cards from HQ (one at a time and paying all install costs)."
	}, {
		"on-play": corp_install_up_to_n_cards(3),
	}))
	NRCardDefs.defcard("Shipment from SanSan", NRUtil.merge({
		"title": "Shipment from SanSan",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nPlace up to 2 advancement tokens on a card that can be advanced."
	}, {
		"on-play": {
			"choices": ["0", "1", "2"],
			"prompt": "How many advancement counters do you want to place?",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return something_can_be_advanced(state),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var c = str_to_int(target)
					return NREngine.resolve_ability(state, side, eid, place_advancement_counter(true, c), card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("Shipment from Tennin", NRUtil.merge({
		"title": "Shipment from Tennin",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"text": "Play only if the Runner did not make a successful run during their last turn.\nPlace 2 advancement counters on 1 installed card."
	}, {
		"on-play": NRUtil.merge(place_advancement_counter(null, 2), {"req": func(state, side, eid, card, targets):
			return NREvents.not_last_turn(state, "runner", "successful-run")}),
	}))
	NRCardDefs.defcard("Shipment from Vladisibirsk", NRUtil.merge({
		"title": "Shipment from Vladisibirsk",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner has at least 2 tags.\nPlace a total of 4 advancement counters on installed cards you can advance."
	}, {
		"on-play": {
			"async": true,
			"req": func(state, side, eid, card, targets):
				return (2 <= count_tags(state)),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return something_can_be_advanced(state),
			},
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _ability_30(4), card, null),
		},
	}))
	NRCardDefs.defcard("Shoot the Moon", NRUtil.merge({
		"title": "Shoot the Moon",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nRez 1 piece of ice for each tag the Runner has, ignoring all costs."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x)))))),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and (not NRCardRT.truthy(NRCard.rezzed(_pct)))),
				"max": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return mini(count_tags(state), reduce(
						func(c, server):
							return (c + NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(server, "ices"), func(_pct):
								return (not NRCardRT.truthy(NRCardRT.getv(_pct, "rezzed")))))),
						0,
						NRCardRT.concat_lists(NRCardRT.as_array(NRCardRT.seq_of(NRCardRT.getv(corp, "servers"))))
					)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.rez_multiple_cards(
					state,
					side,
					eid,
					targets,
					{
						"ignore-cost": "all-costs",
					}
				),
		},
	}))
	NRCardDefs.defcard("Simulation Reset", NRUtil.merge({
		"title": "Simulation Reset",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"text": "Trash up to 5 cards from HQ. Shuffle that many cards from Archives into R&D. Draw that many cards.\nRemove this operation from the game."
	}, {
		"on-play": {
			"rfg-instead-of-trashing": true,
			"prompt": "Choose up to 5 cards in HQ to trash",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"waiting-prompt": true,
			"choices": {
				"max": func(state, side, eid, card, targets):
					return 5,
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"async": true,
			"msg": {
				"corp": func(state, side, eid, card, targets):
					return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "facedown card")) + str(" from HQ (") + str(NRCardRT.enumerate_cards(targets)) + str(")"),
				"public": func(state, side, eid, card, targets):
					return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ"),
			},
			"effect": func(state, side, eid, card, targets):
				return (func():
					var n = NRCardRT.count_of(targets)
					var t = targets
					return NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
									NRMoving.trash_cards(state, side, ne, t, {
										"unpreventable": true,
										"cause-card": card,
									})
								, func(async_result):
									shuffle_into_rd_effect(state, side, eid, card, NRCardRT.count_of(t), true)),
						}, card, null)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, {
							"msg": func(state, side, eid, card, targets):
								return str("draw ") + str(NRCardRT.quantify(n, "card")),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRDrawing.draw(state, side, eid, n),
						}, card, null))
				).call(),
		},
	}))
	NRCardDefs.defcard("Snatch and Grab", NRUtil.merge({
		"title": "Snatch and Grab",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Trace[3]. If successful, trash 1 <strong>connection</strong>. The Runner can take 1 tag to prevent this."
	}, {
		"on-play": {
			"trace": {
				"base": 3,
				"successful": {
					"waiting-prompt": true,
					"msg": "trash a connection",
					"choices": {
						"card": func(_pct):
							return NRCard.has_subtype(_pct, "Connection"),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NREngine.resolve_ability(state, side, eid, (func():
							var c = target
							return {
								"optional": {
									"player": "runner",
									"waiting-prompt": true,
									"prompt": str("Take 1 tag to prevent ") + str(NRCardRT.getv(c, "title")) + str(" from being trashed?"),
									"yes-ability": {
										"async": true,
										"msg": func(state, side, eid, card, targets):
											return str("take 1 tag to prevent ") + str(NRCardRT.getv(c, "title")) + str(" from being trashed"),
										"effect": func(state, side, eid, card, targets):
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
									"no-ability": {
										"async": true,
										"msg": func(state, side, eid, card, targets):
											return str("trash ") + str(NRCardRT.getv(c, "title")),
										"effect": func(state, side, eid, card, targets):
											return NRMoving.trash(
												state,
												"corp",
												eid,
												c,
												{
													"cause-card": card,
												}
											),
									},
								},
							}
						).call(), card, null),
				},
			},
		},
	}))
	NRCardDefs.defcard("Special Report", NRUtil.merge({
		"title": "Special Report",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"text": "Shuffle any number of cards from HQ into R&D. Draw that number of cards."
	}, {
		"on-play": {
			"prompt": "Choose any number of cards in HQ to shuffle into R&D",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"choices": {
				"max": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.count_of(NRCardRT.getv(corp, "hand")),
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				return str("shuffle ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" in HQ into R&D and draw ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				(func():
					for c in NRCardRT.as_array(targets):
						NRMoving.move(state, side, c, "deck")
					return null
				).call()
				NRShuffling.shuffle_zone(state, side, "deck")
				return NRDrawing.draw(state, side, eid, NRCardRT.count_of(targets)),
		},
	}))
	NRCardDefs.defcard("Sprint", NRUtil.merge({
		"title": "Sprint",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Draw 3 cards. Shuffle 2 cards from HQ into R&D."
	}, {
		"on-play": {
			"async": true,
			"msg": "draw 3 cards",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 3)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose 2 cards in HQ to shuffle into R&D",
						"choices": {
							"max": 2,
							"all": true,
							"card": func(_pct):
								return (NRCard.corp(_pct) and NRCard.in_hand(_pct)),
						},
						"msg": {
							"public": func(state, side, eid, card, targets):
								return str("shuffle ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "card")) + str(" from HQ into R&D"),
							"corp": func(state, side, eid, card, targets):
								return str("shuffle ") + str(NRCardRT.quantify(NRCardRT.count_of(targets), "facedown card")) + str(" from HQ into R&D (") + str(NRCardRT.enumerate_cards(targets, "sorted")) + str(")"),
						},
						"effect": func(state, side, eid, card, targets):
							(func():
								for c in NRCardRT.as_array(targets):
									NRMoving.move(state, side, c, "deck")
								return null
							).call()
							return NRShuffling.shuffle_zone(state, side, "deck"),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Standard Procedure", NRUtil.merge({
		"title": "Standard Procedure",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"text": "Play only if the Runner made a successful run during their last turn.\nChoose a card type, then reveal the grip. Gain 2[credit] for each card of the chosen type revealed this way."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "successful-run"),
			"prompt": "Choose one",
			"choices": ["Event", "Hardware", "Program", "Resource"],
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return str("name ") + str(target) + str(", reveal ") + str(NRCardRT.enumerate_cards(NRCardRT.getv(runner, "hand"), "sorted")) + str(" from the grip, and gain ") + str((2 * NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
					return NRCard.is_type(_pct, target))))) + str(" [Credits]"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var runner = state.player("runner")
				return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, NRCardRT.getv(runner, "hand"))
				, func(async_result):
					NRGaining.gain_credits(
						state,
						"corp",
						eid,
						(2 * NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.getv(runner, "hand"), func(_pct):
							return NRCard.is_type(_pct, target))))
					)),
		},
	}))
	NRCardDefs.defcard("Stock Buy-Back", NRUtil.merge({
		"title": "Stock Buy-Back",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Terminal - Transaction",
		"subtypes": ["Terminal", "Transaction"],
		"text": "After you resolve this operation, end your action phase.\nGain 3[credit] for each agenda in the Runner's score area."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return str("gain ") + str((3 * NRCardRT.count_of(NRCardRT.getv(runner, "scored")))) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "scored")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRGaining.gain_credits(state, side, eid, (3 * NRCardRT.count_of(NRCardRT.getv(runner, "scored")))),
		},
	}))
	NRCardDefs.defcard("Sudden Commandment", NRUtil.merge({
		"title": "Sudden Commandment",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"trash": 2,
		"factioncost": 3,
		"keywords": "Mandate",
		"subtypes": ["Mandate"],
		"text": "Draw 2 cards. You may play 1 non-<strong>terminal</strong> operation from HQ.\nThreat 3 → If this operation is the first <strong>mandate</strong> you played this turn, you may pay 3[credit] to gain [click]. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
	}, (func():
		var play_instant_second = {
			"optional": {
				"prompt": "Pay 3 [Credits] to gain [Click]?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets):
					return NRThreat.threat(state, int(3)),
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 3)],
					"msg": "gain [Click]",
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_clicks(state, side, 1),
				},
			},
		}
		var play_instant_first = {
			"prompt": "Choose a non-terminal operation",
			"choices": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRCardRT.as_array(NRCardRT.filter_list(NRCardRT.getv(corp, "hand"), func(_pct):
					return (NRCard.operation(_pct) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Terminal"))) and NREngine.should_trigger(state, "corp", NRUtil.merge(eid, {"source": _pct, "source-type": "play"}), _pct, null, (NRCardRT.getv(NRCardDefs.card_def(_pct), "on-play") or {})) and NRPayment.can_pay(state, side, NRUtil.merge(eid, {"source": _pct, "source-type": "play"}), _pct, null, [NRPayment.to_c("credit", NRCostFns.play_cost(state, side, _pct, null))])))) + ["Done"]),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var is_first_mandate = NREvents.first_event(
						state,
						side,
						"play-operation",
						func(_pct):
							return NRCard.has_subtype(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), "Mandate")
					)
					return (NREngine.resolve_ability(state, side, eid, (play_instant_second if NRCardRT.truthy(is_first_mandate) else null), card, null) if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NREid.wait_for(state, eid, func(ne):
						NRPlayInstants.play_instant(state, side, ne, target, null)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, (play_instant_second if NRCardRT.truthy(is_first_mandate) else null), card, null)))
				).call(),
		}
		return {
			"on-play": {
				"msg": "draw 2 cards",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, side, ne, 2)
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, play_instant_first, card, null)),
			},
		}
	).call()))
	NRCardDefs.defcard("Sub Boost", NRUtil.merge({
		"title": "Sub Boost",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Host this operation on a rezzed piece of ice as a condition counter with \"Host ice gains <strong>barrier</strong> and gains '[subroutine] End the run.' after its other subroutines.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.rezzed(_pct)),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.rezzed(x)))),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("make ") + str(NRToString.card_str(state, target)) + str(" gain Barrier and \"[Subroutine] End the run\""),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return install_as_condition_counter(state, side, eid, card, NRCard.get_card(state, target)),
		},
		"static-abilities": [
			{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.getv(card, "host")) and NRCard.rezzed(target),
				"value": "Barrier",
			},
			{
				"type": "additional-subroutines",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.getv(card, "host")) and NRCard.rezzed(target),
				"value": {
					"subroutines": [
						{
							"label": "[Sub Boost] End the run",
							"msg": "end the run",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRRuns.end_run(state, side, eid, card),
						}
					],
				},
			}
		],
	}))
	NRCardDefs.defcard("Subcontract", NRUtil.merge({
		"title": "Subcontract",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nPlay up to 2 operations from HQ (paying all costs), resolving them one at a time."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var tagged = NRUtil.is_tagged(state)
				return tagged,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.resolve_ability(state, side, eid, _sc_31(1, card), card, null),
		},
	}))
	NRCardDefs.defcard("Subliminal Messaging", NRUtil.merge({
		"title": "Subliminal Messaging",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 0,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Gain 1[credit].\nThe first time each turn you play a copy of Subliminal Messaging, gain [click].\nWhen your turn begins, if this card is in Archives and the Runner did not initiate any runs during their last turn, you may reveal this card and add it to HQ."
	}, {
		"on-play": {
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 1)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"once": "per-turn",
						"once-key": "subliminal-messaging",
						"msg": "gain [Click]",
						"effect": func(state, side, eid, card, targets):
							return NRGaining.gain_clicks(state, "corp", 1),
					}, card, null)),
		},
		"highlight-in-discard": true,
		"events": [
			{
				"event": "corp-phase-12",
				"location": "discard",
				"optional": {
					"req": func(state, side, eid, card, targets):
						return NREvents.not_last_turn(state, "runner", "made-run"),
					"prompt": func(state, side, eid, card, targets):
						return str("Add ") + str(NRCardRT.getv(card, "title")) + str(" to HQ?"),
					"yes-ability": {
						"msg": "reveal and add itself to HQ",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, card)
							, func(async_result):
								NRMoving.move(state, side, card, "hand")
								NREid.effect_completed(state, side, eid)),
					},
				},
			}
		],
	}))
	NRCardDefs.defcard("Success", NRUtil.merge({
		"title": "Success",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Triple",
		"subtypes": ["Triple"],
		"text": "As an additional cost to play this operation, forfeit an agenda and spend [click][click].\nAdvance a card X times. X equals the advancement requirement of the agenda just forfeited."
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("forfeit")],
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.can_be_advanced(state, target),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return something_can_be_advanced(state),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("advance ") + str(NRToString.card_str(state, target)) + str(" ") + str(NRCardRT.quantify(NRCard.get_advancement_requirement(NRPayment.cost_target(eid, "forfeit")), "time")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return _advance_n_times_32(state, side, eid, card, target, NRCard.get_advancement_requirement(NRPayment.cost_target(eid, "forfeit"))),
		},
	}))
	NRCardDefs.defcard("Successful Demonstration", NRUtil.merge({
		"title": "Successful Demonstration",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 1,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Play only if the Runner made an unsuccessful run during their last turn.\nGain 7[credit]."
	}, {
		"on-play": NRUtil.merge(NRDefHelpers.gain_credits_ability(7), {"req": func(state, side, eid, card, targets):
			return NREvents.last_turn(state, "runner", "unsuccessful-run")}),
	}))
	NRCardDefs.defcard("Sunset", NRUtil.merge({
		"title": "Sunset",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"text": "Choose a server. Arrange the ice protecting that server in any order."
	}, {
		"on-play": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return servers,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("rearrange ice protecting ") + str(target),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var serv = (NRCardRT.as_array(NRBoard.server_to_zone(state, target)) + ["ices"])
					return NREngine.resolve_ability(state, side, eid, _sun_33(serv), card, null)
				).call(),
		},
	}))
	NRCardDefs.defcard("Surveillance Sweep", NRUtil.merge({
		"title": "Surveillance Sweep",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner must spend credits first for each trace attempt during a run."
	}, {
		"static-abilities": [
			{
				"type": "trace-runner-spends-first",
				"req": func(state, side, eid, card, targets):
					var run = state.getv("run")
					return run,
				"value": true,
			}
		],
	}))
	NRCardDefs.defcard("Sweeps Week", NRUtil.merge({
		"title": "Sweeps Week",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"text": "Gain 1[credit] for each card in the Runner's grip."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return str("gain ") + str(NRCardRT.count_of(NRCardRT.getv(runner, "hand"))) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "hand")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var runner = state.player("runner")
				return NRGaining.gain_credits(state, side, eid, NRCardRT.count_of(NRCardRT.getv(runner, "hand"))),
		},
	}))
	NRCardDefs.defcard("SYNC Rerouting", NRUtil.merge({
		"title": "SYNC Rerouting",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"trash": 3,
		"factioncost": 3,
		"keywords": "Lockdown",
		"subtypes": ["Lockdown"],
		"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nWhenever a run begins, give the Runner 1 tag unless they pay 4[credit]."
	}, _lockdown(
		{
			"events": [
				NRCardRT.choose_one_helper(
					{
						"event": "run",
						"player": "runner",
					},
					[
						{
							"option": "Take 1 tag",
							"ability": {
								"async": true,
								"display-side": "corp",
								"msg": "give the runner 1 tag",
								"effect": func(state, side, eid, card, targets):
									return NRTags.gain_tags(state, "corp", eid, 1),
							},
						},
						NRCardRT.cost_option([NRPayment.to_c("credit", 4)], "runner")
					]
				)
			],
		}
	)))
	NRCardDefs.defcard("Targeted Marketing", NRUtil.merge({
		"title": "Targeted Marketing",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Current",
		"subtypes": ["Current"],
		"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nName a card. Gain 10[credit] whenever the Runner plays or installs a copy of that card."
	}, (func():
		var gaincr = {
			"req": func(state, side, eid, card, targets):
				var context = NRCardRT.ctx(targets)
				return ((NRCardRT.getv(NRCardRT.getv(context, "card"), "title") == NRCardRT.getv(card, "card-target")) or NRUtil.kw_eq(NRCardRT.getv(NRCardRT.getv(context, "card"), "title"), NRCardRT.getv(card, "card-target"))),
			"async": true,
			"msg": "gain 10 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 10),
		}
		return {
			"on-play": {
				"prompt": "Name a Runner card",
				"choices": {
					"card-title": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (NRCard.runner(target) and (not NRCardRT.truthy(NRCard.identity(target)))),
				},
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					NRUpdate.update_card(state, side, NRUtil.merge(card, {"card-target": target}))
					return NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to name ") + str(target)),
			},
			"events": [
				NRUtil.merge(gaincr, {"event": "runner-install"}),
				NRUtil.merge(gaincr, {"event": "play-event"})
			],
		}
	).call()))
	NRCardDefs.defcard("The All-Seeing I", NRUtil.merge({
		"title": "The All-Seeing I",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 1,
		"text": "Play only if the Runner is tagged.\nTrash all installed resources unless the Runner removes 1 bad publicity."
	}, (func():
		var trash_all_resources = {
			"msg": "trash all resources",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(
					state,
					"corp",
					eid,
					NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.resource),
					{
						"cause-card": card,
					}
				),
		}
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), NRCard.resource),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.resolve_ability(state, side, eid, ({
						"optional": {
							"player": "runner",
							"prompt": "Remove 1 bad publicity to prevent all resources from being trashed?",
							"yes-ability": {
								"msg": "remove 1 bad publicity, preventing all resources from being trashed",
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRBadPublicity.lose_bad_publicity(state, side, eid, 1),
							},
							"no-ability": trash_all_resources,
						},
					} if NRCardRT.pos(count_bad_pub(state)) else trash_all_resources), card, null),
			},
		}
	).call()))
	NRCardDefs.defcard("Threat Assessment", NRUtil.merge({
		"title": "Threat Assessment",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Reprisal - Gray Ops",
		"subtypes": ["Reprisal", "Gray Ops"],
		"text": "Play only if the Runner trashed a Corp card during their last turn and the Runner has at least 1 installed card.\nChoose 1 installed Runner card. The Runner must take 2 tags or add that card to the top of the stack.\nRemove this operation from the game."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "trashed-card"),
			"prompt": "Choose an installed Runner card",
			"choices": {
				"card": func(_pct):
					return (NRCard.runner(_pct) and NRCard.installed(_pct)),
			},
			"rfg-instead-of-trashing": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var chosen = target
					return {
						"player": "runner",
						"waiting-prompt": true,
						"prompt": "Choose one",
						"choices": [
							str("Add ") + str(NRCardRT.getv(chosen, "title")) + str(" to the top of the Stack"),
							"Take 2 tags"
						],
						"async": true,
						"msg": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return str("force the Runner to") + str(NRCardRT.decapitalize(target)),
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return (NRTags.gain_tags(state, "runner", eid, 2) if ((target == "Take 2 tags") or NRUtil.kw_eq(target, "Take 2 tags")) else (func():
								NRMoving.move(
									state,
									"runner",
									chosen,
									"deck",
									{
										"front": true,
									}
								)
								return NREid.effect_completed(state, side, eid)
							).call()),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Threat Level Alpha", NRUtil.merge({
		"title": "Threat Level Alpha",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 3,
		"factioncost": 2,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nTrace[1]. If successful, give the Runner 1 tag for each tag they have or, if the Runner has no tags, give them 1 tag."
	}, {
		"on-play": {
			"trace": {
				"base": 1,
				"successful": {
					"label": "Give the Runner X tags",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
							var tags = maxi(1, count_tags(state))
							return NREid.wait_for(state, eid, func(ne):
								NRTags.gain_tags(state, "corp", ne, tags)
							, func(async_result):
								NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to give the Runner ") + str(NRCardRT.quantify(tags, "tag")))
								NREid.effect_completed(state, null, eid))
						).call(),
				},
			},
		},
	}))
	NRCardDefs.defcard("Too Big to Fail", NRUtil.merge({
		"title": "Too Big to Fail",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"trash": 5,
		"factioncost": 4,
		"keywords": "Transaction - Liability",
		"subtypes": ["Transaction", "Liability"],
		"text": "Play only if you have less than 10[credit].\nGain 7[credit] and take 1 bad publicity."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (NRCardRT.getv(corp, "credit") < 10),
			"msg": "gain 7 [Credits] and take 1 bad publicity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 7, {
						"suppress-checkpoint": true,
					})
				, func(async_result):
					NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
		},
	}))
	NRCardDefs.defcard("Top-Down Solutions", NRUtil.merge({
		"title": "Top-Down Solutions",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"text": "Draw 2 cards. Install up to 2 cards from HQ <em>(one at a time)</em>."
	}, {
		"on-play": {
			"async": true,
			"msg": "draw 2 cards",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 2)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, corp_install_up_to_n_cards(2), card, null)),
		},
	}))
	NRCardDefs.defcard("Traffic Accident", NRUtil.merge({
		"title": "Traffic Accident",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 1,
		"keywords": "Black Ops",
		"subtypes": ["Black Ops"],
		"text": "Play only if the Runner has at least 2 tags.\nDo 2 meat damage."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return (2 <= count_tags(state)),
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
	}))
	NRCardDefs.defcard("Transparency Initiative", NRUtil.merge({
		"title": "Transparency Initiative",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 4,
		"text": "Turn an agenda faceup and install Transparency Initiative on that agenda as a hosted condition counter with the text \"Host agenda gains <strong>public</strong>. Whenever you advance host agenda, gain 1[credit].\""
	}, {
		"static-abilities": [
			{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.getv(card, "host")) and NRCard.rezzed(target),
				"value": "Public",
			}
		],
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.agenda(_pct) and NRCard.installed(_pct) and (not NRCardRT.truthy(NRCard.faceup(_pct)))),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.faceup(x)))) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.ice(x)))))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				var context = NRCardRT.ctx(targets)
				var async_result = NREid.result_of(eid)
				return (func():
					var target = NRUpdate.update_card(state, side, NRUtil.merge(target, {"seen": true, "rezzed": true}))
					return NREid.wait_for(state, eid, func(ne):
						install_as_condition_counter(state, side, ne, card, target)
					, func(async_result):
						(func():
							var card = async_result
							return NREngine.register_events(
								state,
								side,
								card,
								[
									{
										"event": "advance",
										"condition": "hosted",
										"req": func(state, side, eid, card, targets):
											var context = NRCardRT.ctx(targets)
											return NRUtil.same_card(NRCardRT.getv(card, "host"), NRCardRT.getv(context, "card")),
										"async": true,
										"msg": "gain 1 [Credit]",
										"effect": func(state, side, eid, card, targets):
											return NRGaining.gain_credits(state, side, eid, 1),
									}
								]
							)
						).call()
						NREid.effect_completed(state, side, eid))
				).call(),
		},
	}))
	NRCardDefs.defcard("Trick of Light", NRUtil.merge({
		"title": "Trick of Light",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"text": "Choose 1 installed card you can advance. Move up to 2 advancement counters from 1 other card to the chosen card."
	}, {
		"on-play": {
			"prompt": "Choose an installed card you can advance",
			"choices": {
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRCard.can_be_advanced(state, target) and NRCard.installed(target),
			},
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return something_can_be_advanced(state),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var card_to_advance = target
					return {
						"async": true,
						"prompt": "Choose another installed card",
						"choices": {
							"card": func(_pct):
								return ((not NRCardRT.truthy(NRUtil.same_card(card_to_advance, _pct))) and NRCard.installed(_pct)),
						},
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return NREngine.resolve_ability(state, side, eid, (func():
								var source = target
								return {
									"prompt": "How many advancement counters do you want to move?",
									"choices": NRCardRT.take_n(["0", "1", "2"], int((int(NRCard.get_counters(source, "advancement")) + 1))),
									"msg": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return str("move ") + str(target) + str(" advancement counters from ") + str(NRToString.card_str(state, source)) + str(" to ") + str(NRToString.card_str(state, card_to_advance)),
									"async": true,
									"effect": func(state, side, eid, card, targets):
										var target = NRCardRT.first_target(targets)
										return NREid.wait_for(state, eid, func(ne):
											NRProps.add_prop(state, "corp", ne, card_to_advance, "advance-counter", str_to_int(target), {
												"placed": true,
												"suppress-checkpoint": true,
											})
										, func(async_result):
											NRProps.add_prop(
												state,
												"corp",
												eid,
												source,
												"advance-counter",
												(-str_to_int(target)),
												{
													"placed": true,
												}
											)),
								}
							).call(), card, null),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Trojan Horse", NRUtil.merge({
		"title": "Trojan Horse",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner accessed a card during their last turn.\nTrace[4]. If successful, trash 1 installed program with an install cost of X or less, where X is equal to the amount by which your trace strength exceeded the Runner's link strength."
	}, {
		"on-play": {
			"trace": {
				"base": 4,
				"req": func(state, side, eid, card, targets):
					return NRCardRT.getv(runner_reg_last, "accessed-cards"),
				"label": "Trace 4 - Trash a program",
				"successful": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return (func():
							var exceed = (target - NRCardRT.getv(targets, 1))
							return NREngine.resolve_ability(state, side, eid, {
								"async": true,
								"prompt": str("Choose a program with an install cost of no more than ") + str(exceed) + str(" [Credits]"),
								"choices": {
									"card": func(_pct):
										return (NRCard.program(_pct) and NRCard.installed(_pct) and (exceed >= NRCardRT.getv(_pct, "cost"))),
								},
								"msg": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return str("trash ") + str(NRToString.card_str(state, target)),
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
							}, card, null)
						).call(),
				},
			},
		},
	}))
	NRCardDefs.defcard("Trust Operation", NRUtil.merge({
		"title": "Trust Operation",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 3,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged.\nTrash 1 installed resource. Install and rez 1 card from Archives, ignoring all costs."
	}, (func():
		var ability = {
			"prompt": "Choose a card to install from Archives",
			"show-discard": true,
			"choices": {
				"card": func(_pct):
					return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
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
						"ignore-all-cost": true,
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
						"install-state": "rezzed-no-cost",
					}
				),
		}
		return {
			"on-play": {
				"req": func(state, side, eid, card, targets):
					var tagged = NRUtil.is_tagged(state)
					return tagged,
				"msg": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return str("trash ") + str(NRCardRT.getv(target, "title")),
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						var corp = state.player("corp")
						return (NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), NRCard.resource) or NRCardRT.some_list(NRCardRT.getv(corp, "discard"), func(_pct):
							return ((not NRCardRT.truthy(NRCard.operation(_pct))) or (not NRCardRT.truthy(NRCardRT.getv(_pct, "seen")))))),
				},
				"prompt": "Choose a resource to trash",
				"choices": {
					"card": func(_pct):
						return (NRCard.installed(_pct) and NRCard.resource(_pct)),
				},
				"async": true,
				"cancel": _ability_30(),
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, target, {
							"cause-card": card,
						})
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, _ability_30(), card, null)),
			},
		}
	).call()))
	NRCardDefs.defcard("Touch-ups", NRUtil.merge({
		"title": "Touch-ups",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 3,
		"keywords": "Double",
		"subtypes": ["Double"],
		"text": "As an additional cost to play this operation, spend [click].\nPlace 2 advancement counters on 1 installed card you can advance. If you do, choose a card type and reveal the grip. Choose up to 2 revealed cards of that type. The Runner shuffles those cards into the stack."
	}, (func():
		var name_abi = {
			"prompt": "Choose a card type",
			"waiting-prompt": true,
			"choices": ["Event", "Hardware", "Program", "Resource"],
			"async": true,
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("choose ") + str(target),
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return (func():
					var chosen_type = target
					return NREngine.resolve_ability(state, side, eid, with_revealed_hand(
						"runner",
						{
							"event-side": "corp",
						},
						{
							"prompt": str("Shuffle up to two ") + str(chosen_type) + str(" cards into the stack"),
							"choices": {
								"req": func(state, side, eid, card, targets):
									var target = NRCardRT.first_target(targets)
									return NRCard.in_hand(target) and NRCard.runner(target) and ((NRCardRT.getv(target, "type") == chosen_type) or NRUtil.kw_eq(NRCardRT.getv(target, "type"), chosen_type)),
								"max": 2,
							},
							"effect": func(state, side, eid, card, targets):
								(func():
									for t in NRCardRT.as_array(targets):
										NRMoving.move(state, "runner", t, "deck")
									return null
								).call()
								return NRShuffling.shuffle_zone(state, "runner", "deck"),
							"msg": func(state, side, eid, card, targets):
								return str("shuffle ") + str(NRCardRT.enumerate_cards(targets)) + str(" into the Stack"),
						}
					), card, null)
				).call(),
		}
		return {
			"on-play": {
				"async": true,
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets):
						return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
							return ((not NRCardRT.truthy(NRCard.rezzed(_pct))) or NRCard.can_be_advanced(state, _pct))),
				},
				"choices": {
					"req": func(state, side, eid, card, targets):
						var target = NRCardRT.first_target(targets)
						return NRCard.can_be_advanced(state, target),
				},
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
				"effect": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NREid.wait_for(state, eid, func(ne):
						NRProps.add_prop(state, side, ne, target, "advance-counter", 2, {
							"placed": true,
						})
					, func(async_result):
						NREngine.resolve_ability(state, side, eid, name_abi, card, null)),
			},
		}
	).call()))
	NRCardDefs.defcard("Ultraviolet Clearance", NRUtil.merge({
		"title": "Ultraviolet Clearance",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 6,
		"factioncost": 4,
		"keywords": "Transaction - Triple",
		"subtypes": ["Transaction", "Triple"],
		"text": "As an additional cost to play this operation, spend [click][click].\nGain 10[credit] and draw 4 cards. You may install 1 card from HQ."
	}, {
		"on-play": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, _clearance(10, 4), card, null)
				, func(async_result):
					NREngine.resolve_ability(state, side, eid, {
						"prompt": "Choose a card in HQ to install",
						"choices": {
							"card": func(_pct):
								return (NRCard.in_hand(_pct) and NRCard.corp(_pct) and (not NRCardRT.truthy(NRCard.operation(_pct)))),
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
									"msg-keys": {
										"install-source": card,
										"display-origin": true,
									},
								}
							),
					}, card, null)),
		},
	}))
	NRCardDefs.defcard("Under the Bus", NRUtil.merge({
		"title": "Under the Bus",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Gray Ops - Liability",
		"subtypes": ["Gray Ops", "Liability"],
		"text": "Play only if the Runner accessed a card during their last turn.\nTrash 1 installed <strong>connection</strong> resource and take 1 bad publicity."
	}, {
		"on-play": {
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "accessed-cards"),
			"prompt": "Choose a connection to trash",
			"choices": {
				"card": func(_pct):
					return (NRCard.runner(_pct) and NRCard.resource(_pct) and NRCard.has_subtype(_pct, "Connection") and NRCard.installed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("trash ") + str(NRCardRT.getv(target, "title")) + str(" and take 1 bad publicity"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, target, {
						"cause-card": card,
						"suppress-checkpoint": true,
					})
				, func(async_result):
					NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1)),
			"cancel": {
				"msg": "take 1 bad publicity",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRBadPublicity.gain_bad_publicity(state, side, eid, 1),
			},
		},
	}))
	NRCardDefs.defcard("Unleash", NRUtil.merge({
		"title": "Unleash",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 0,
		"factioncost": 2,
		"keywords": "Gray Ops",
		"subtypes": ["Gray Ops"],
		"text": "As an additional cost to play this operation, remove 1 tag.\nRez 1 installed piece of ice, ignoring all costs. You may resolve 1 subroutine on that ice."
	}, {
		"on-play": {
			"additional-cost": [NRPayment.to_c("tag", 1)],
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x)))))),
			},
			"choices": {
				"card": (func(x, _s=null, _e=null, _c=null, _t=null): return NRCardRT.truthy(NRCard.ice(x)) and NRCardRT.truthy(NRCard.installed(x)) and NRCardRT.truthy((func(x): return not NRCardRT.truthy(NRCard.rezzed(x))))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREid.wait_for(state, eid, func(ne):
					NRRezzing.rez(state, side, ne, target, {
						"ignore-cost": "all-costs",
					})
				, func(async_result):
					(func():
						var rezzed_card = NRCard.get_card(state, target)
						return (NREngine.resolve_ability(state, side, eid, {
							"prompt": "Choose a subroutine to resolve",
							"choices": func(state, side, eid, card, targets):
								return NRIce.unbroken_subroutines_choice(rezzed_card),
							"msg": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return str("resolve the subroutine (\"[subroutine] ") + str(target) + str("\") from ") + str(NRCardRT.getv(rezzed_card, "title")),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								var target = NRCardRT.first_target(targets)
								return (func():
									var sub = NRCardRT.getv(NRCardRT.filter_list(NRCardRT.getv(rezzed_card, "subroutines"), func(_pct):
										return ((target == NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))) or NRUtil.kw_eq(target, NRUtil.make_label(NRCardRT.getv(_pct, "sub-effect"))))), 0)
									return NRIce.resolve_subroutine(state, side, eid, rezzed_card, NRUtil.merge(sub, {"external-trigger": true}))
								).call(),
						}, card, null) if (rezzed_card and NRCard.rezzed(rezzed_card) and NRCardRT.seq_of(NRCardRT.getv(rezzed_card, "subroutines"))) else NREid.effect_completed(state, side, eid))
					).call()),
		},
	}))
	NRCardDefs.defcard("Violet Level Clearance", NRUtil.merge({
		"title": "Violet Level Clearance",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 5,
		"trash": 1,
		"factioncost": 3,
		"keywords": "Terminal - Transaction",
		"subtypes": ["Terminal", "Transaction"],
		"text": "After you resolve this operation, end your action phase.\nGain 8[credit] and draw 4 cards."
	}, {
		"on-play": _clearance(8, 4),
	}))
	NRCardDefs.defcard("Voter Intimidation", NRUtil.merge({
		"title": "Voter Intimidation",
		"type": "Operation",
		"side": "Corp",
		"faction": "Jinteki",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Gray Ops - Psi",
		"subtypes": ["Gray Ops", "Psi"],
		"text": "Play only if there is an agenda in the Runner's score area.\nYou and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, trash 1 resource."
	}, {
		"on-play": {
			"psi": {
				"req": func(state, side, eid, card, targets):
					var runner = state.player("runner")
					return NRCardRT.seq_of(NRCardRT.getv(runner, "scored")),
				"not-equal": _trash_type("resource", NRCard.resource, "loud"),
			},
		},
	}))
	NRCardDefs.defcard("Vulture Fund", NRUtil.merge({
		"title": "Vulture Fund",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 7,
		"factioncost": 2,
		"keywords": "Transaction - Liability",
		"subtypes": ["Transaction", "Liability"],
		"text": "Gain 14[credit] and take 1 bad publicity."
	}, {
		"on-play": {
			"msg": "gain 14 [Credits] and take 1 bad publicity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 14, {
						"suppress-checkpoint": true,
					})
				, func(async_result):
					NRBadPublicity.gain_bad_publicity(state, side, eid, 1)),
		},
	}))
	NRCardDefs.defcard("Wake Up Call", NRUtil.merge({
		"title": "Wake Up Call",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 3,
		"keywords": "Reprisal - Gray Ops",
		"subtypes": ["Reprisal", "Gray Ops"],
		"text": "Play only if the Runner trashed a Corp card during their last turn and the Runner has at least 1 installed piece of hardware or non-<strong>virtual</strong> resource.\nChoose 1 installed piece of hardware or non-<strong>virtual</strong> resource. The Runner must either trash that card or suffer 4 meat damage.\nRemove this operation from the game."
	}, {
		"on-play": {
			"rfg-instead-of-trashing": true,
			"req": func(state, side, eid, card, targets):
				return NREvents.last_turn(state, "runner", "trashed-card"),
			"prompt": "Choose a piece of hardware or non-virtual resource",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
						return (NRCard.hardware(_pct) or (NRCard.resource(_pct) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Virtual")))))),
			},
			"choices": {
				"card": func(_pct):
					return (NRCard.hardware(_pct) or (NRCard.resource(_pct) and (not NRCardRT.truthy(NRCard.has_subtype(_pct, "Virtual"))))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return NREngine.resolve_ability(state, side, eid, (func():
					var chosen = target
					var wake = card
					return {
						"player": "runner",
						"waiting-prompt": true,
						"prompt": "Choose one",
						"choices": [str("Trash ") + str(NRToString.card_str(state, chosen)), "Suffer 4 meat damage"],
						"async": true,
						"effect": func(state, side, eid, card, targets):
							var target = NRCardRT.first_target(targets)
							return ((func():
								NRSay.system_msg(state, side, "suffers 4 meat damage")
								return NRDamage.damage(
									state,
									side,
									eid,
									"meat",
									4,
									{
										"card": wake,
										"unboostable": true,
									}
								)
							).call() if ((target == "Suffer 4 meat damage") or NRUtil.kw_eq(target, "Suffer 4 meat damage")) else (func():
								NRSay.system_msg(state, side, str("trashes ") + str(NRToString.card_str(state, chosen)))
								return NRMoving.trash(
									state,
									side,
									eid,
									chosen,
									{
										"cause-card": card,
										"cause": "forced-to-trash",
									}
								)
							).call()),
					}
				).call(), card, null),
		},
	}))
	NRCardDefs.defcard("Wetwork Refit", NRUtil.merge({
		"title": "Wetwork Refit",
		"type": "Operation",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"uniqueness": false,
		"cost": 1,
		"factioncost": 2,
		"keywords": "Condition",
		"subtypes": ["Condition"],
		"text": "Host this operation on a rezzed piece of <strong>bioroid</strong> ice as a condition counter with \"Host ice gains '[subroutine] Do 1 core damage.' before all its other subroutines.\""
	}, {
		"on-play": {
			"choices": {
				"card": func(_pct):
					return (NRCard.ice(_pct) and NRCard.has_subtype(_pct, "Bioroid") and NRCard.rezzed(_pct)),
			},
			"msg": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return str("give ") + str(NRToString.card_str(state, target)) + str(" \"[Subroutine] Do 1 core damage\" before all its other subroutines"),
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.some_list(NRBoard.all_installed(state, "corp"), func(_pct):
						return (NRCard.ice(_pct) and NRCard.rezzed(_pct) and NRCard.has_subtype(_pct, "Bioroid"))),
			},
			"effect": func(state, side, eid, card, targets):
				var target = NRCardRT.first_target(targets)
				return install_as_condition_counter(state, side, eid, card, NRCard.get_card(state, target)),
		},
		"static-abilities": [
			{
				"type": "additional-subroutines",
				"duration": "end-of-run",
				"req": func(state, side, eid, card, targets):
					var target = NRCardRT.first_target(targets)
					return NRUtil.same_card(target, NRCardRT.getv(card, "host")) and NRCard.rezzed(target),
				"value": {
					"position": "front",
					"subroutines": [
						NRUtil.merge(NRDefHelpers.do_brain_damage(1), {"label": "[Wetwork Refit] Do 1 core damage"})
					],
				},
			}
		],
	}))
	NRCardDefs.defcard("Witness Tampering", NRUtil.merge({
		"title": "Witness Tampering",
		"type": "Operation",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"uniqueness": false,
		"cost": 4,
		"factioncost": 1,
		"keywords": "Double - Gray Ops",
		"subtypes": ["Double", "Gray Ops"],
		"text": "As an additional cost to play this operation, spend [click].\nRemove up to 2 bad publicity."
	}, {
		"on-play": {
			"msg": "remove 2 bad publicity",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					return NRCardRT.pos(count_bad_pub(state)),
			},
			"effect": func(state, side, eid, card, targets):
				return NRBadPublicity.lose_bad_publicity(state, side, 2),
		},
	}))
	NRCardDefs.defcard("Your Digital Life", NRUtil.merge({
		"title": "Your Digital Life",
		"type": "Operation",
		"side": "Corp",
		"faction": "NBN",
		"uniqueness": false,
		"cost": 2,
		"factioncost": 2,
		"keywords": "Transaction",
		"subtypes": ["Transaction"],
		"text": "Gain 1[credit] for each card in HQ."
	}, {
		"on-play": {
			"msg": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return str("gain ") + str(NRCardRT.count_of(NRCardRT.getv(corp, "hand"))) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets):
					var corp = state.player("corp")
					return NRCardRT.seq_of(NRCardRT.getv(corp, "hand")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return NRGaining.gain_credits(state, "corp", eid, NRCardRT.count_of(NRCardRT.getv(corp, "hand"))),
		},
	}))

static func _lockdown(cardfn):
	return (func():
		var untrashed = NRUtil.merge(cardfn, {"on-play": (NRCardRT.as_array({
			"trash-after-resolving": false,
			"req": func(state, side, eid, card, targets):
				var corp = state.player("corp")
				return (not NRCardRT.truthy(NRCardRT.some_list(NRCardRT.getv(corp, "play-area"), func(_pct):
					return NRCard.has_subtype(_pct, "Lockdown")))),
		}) + [NRCardRT.getv(cardfn, "on-play")])})
		return NRUtil.merge(untrashed, {"events": conj(NRCardRT.getv(untrashed, "events"), {
			"event": "corp-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, card, null),
		})})
	).call()

static func _faceup_archives_types(corp):
	return NRCardRT.count_of(NRCardRT.distinct_list(NRCardRT.map_list(NRCardRT.filter_list(NRCardRT.getv(corp, "discard"), NRCard.faceup), func(x): return NRCardRT.getv(x, "type"))))

static func _clearance(creds, cards):
	return {
		"msg": str("gain ") + str(creds) + str(" [Credits] and draw ") + str(NRCardRT.quantify(cards, "card")),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, creds, {
					"suppress-checkpoint": true,
				})
			, func(async_result):
				NRDrawing.draw(state, side, eid, cards)),
	}

static func _gain_n_clicks(n):
	return {
		"msg": str("gain ") + str(apply(str_, NRCardRT.repeat_n("[Click]", int(n)))),
		"effect": func(state, side, eid, card, targets):
			return NRGaining.gain_clicks(state, side, n),
	}

static func _trash_type(type_ = null, f = null, loud = null, max_targets = null, all = null, ab = null):
	return NRUtil.merge({
		"async": true,
		"change-in-game-state": {
			"silent": (not NRCardRT.truthy(loud)),
			"req": func(state, side, eid, card, targets):
				return NRCardRT.seq_of(_valid_targets_1(state)),
		},
		"prompt": (str("Choose a ") + str(type_) + str(" to trash") if NRCardRT.truthy(((1 == max_targets) or NRUtil.kw_eq(1, max_targets))) else (func(state, side, eid, card, targets):
			return str((func():
				var ct = NRCardRT.count_of(_valid_targets_1(state))
				return (str("Choose a ") + str(type_) + str(" to trash") if ((1 == ct) or NRUtil.kw_eq(1, ct)) else str("Choose ") + str(ct) + str(" ") + str(type_) + str("s to trash"))
			).call()) if NRCardRT.truthy(all) else str("Choose up to ") + str(NRCardRT.quantify(max_targets, type_)) + str(" to trash"))),
		"waiting-prompt": true,
		"choices": {
			"card": func(_pct):
				return (NRCard.installed(_pct) and f(_pct)),
			"max": func(state, side, eid, card, targets):
				return mini(max_targets, NRCardRT.count_of(_valid_targets_1(state))),
			"all": all,
		},
		"msg": func(state, side, eid, card, targets):
			return str("trash ") + str(NRCardRT.enumerate_cards(targets)),
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
	}, ab)

static func _valid_targets_1(state):
	return filterv(f, NRCardRT.concat_lists([NRBoard.all_installed(state, "runner"), NRBoard.all_installed(state, "corp")]))

static func _shuffle_count_fn_2(state):
	return NREvents.event_count(state, "corp", "corp-shuffle-deck")

static func _is_top_x_3(state, card, X):
	return NRCardRT.some_list(NRCardRT.take_n(state.get_in(["corp", "deck"], null), int(X)), func(_pct):
		return NRUtil.same_card(_pct, card))

static func _ad_4(state, eid, card, remaining_cards, starting_shuffle_count):
	return (func():
		var playable_cards = filterv(
			func(_pct):
				return (NRCard.operation(_pct) and _is_top_x_3(state, _pct, NRCardRT.count_of(remaining_cards)) and NRPayment.can_pay(state, "corp", NRUtil.merge(eid, {"source": card, "source-type": "play"}), card, null, [NRPayment.to_c("credit", NRCostFns.play_cost(state, "corp", _pct))])),
			remaining_cards
		)
		return ({} if NRCardRT.truthy((not NRCardRT.truthy(NRCardRT.seq_of(remaining_cards)))) else ({
			"msg": str("is unable to continue resolving ") + str(NRCardRT.getv(card, "title")),
	} if NRCardRT.truthy((_shuffle_count_fn_2(state) > starting_shuffle_count)) else ({
		"prompt": "Choose an operation to play",
		"choices": NRPrompts.cancellable(NRCardRT.as_array(playable_cards)),
		"msg": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return str("play ") + str(NRCardRT.getv(target, "title")),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NREid.wait_for(state, eid, func(ne):
				NRPlayInstants.play_instant(state, side, ne, target, {
					"no-additional-cost": true,
				})
			, func(async_result):
				(func():
					var remaining = filterv(
						func(_pct):
							return (not NRCardRT.truthy(NRUtil.same_card(_pct, target))),
						remaining_cards
					)
					return NREngine.resolve_ability(state, side, eid, ad(state, eid, card, remaining, starting_shuffle_count), card, null)
				).call()),
		"cancel": {
			"msg": func(state, side, eid, card, targets):
				return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(remaining_cards), "card")) + str(" from the top of R&D"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash_cards(
					state,
					side,
					eid,
					remaining_cards,
					{
						"unpreventable": true,
						"cause-card": card,
					}
				),
		},
	} if NRCardRT.truthy(NRCardRT.seq_of(playable_cards)) else {
		"prompt": "There are no playable cards",
		"choices": ["OK"],
		"async": true,
		"msg": func(state, side, eid, card, targets):
			return str("trash ") + str(NRCardRT.quantify(NRCardRT.count_of(remaining_cards), "card")) + str(" from the top of R&D"),
		"effect": func(state, side, eid, card, targets):
			return NRMoving.trash_cards(
				state,
				side,
				eid,
				remaining_cards,
				{
					"unpreventable": true,
					"cause-card": card,
				}
			),
	})))
).call()

static func _ab_5(n, total):
	return ({
	"async": true,
	"show-discard": true,
	"prompt": "Choose an Advertisement to install and rez",
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.has_subtype(_pct, "Advertisement") and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
	},
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRInstalling.corp_install(state, side, ne, target, null, {
				"install-state": "rezzed",
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, ab((int(n) + 1), total), card, null)),
} if NRCardRT.truthy((n < total)) else null)

static func _audacity_6(x):
	return {
	"prompt": func(state, side, eid, card, targets):
		return str("Choose a card that can be advanced to place advancement counters on (") + str(x) + str(" remaining)"),
	"async": true,
	"choices": {
		"req": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return NRCard.can_be_advanced(state, target),
	},
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str("place 1 advancement counter on ") + str(NRToString.card_str(state, target)),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRProps.add_prop(state, side, ne, target, "advance-counter", 1, {
				"placed": true,
			})
		, func(async_result):
			(NREngine.resolve_ability(state, side, eid, audacity((int(x) - 1)), card, null) if (x > 1) else NREid.effect_completed(state, side, eid))),
}

static func _num_installed_7(state, t):
	return NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), func(_pct):
		return NRCard.is_type(_pct, t)))

static func _remove_card_9(remaining, target):
	return filterv(
	func(_pct):
		return (not NRCardRT.truthy(NRUtil.same_card(_pct, target))),
	remaining
)

static func _interact_10(cards, remaining, to_trash, to_add, to_top):
	return (NRCardRT.choose_one_helper(
	{
		"prompt": str(NRCardRT.getv(to_trash, "title")) + str(" will be trashed, ") + str(NRCardRT.getv(to_add, "title")) + str(" will be added to HQ") + str((str(", and the top of R&D will be (top->bottom): ") + str(NRCardRT.enumerate_cards(NRCardRT.as_array(to_top))) if NRCardRT.truthy(NRCardRT.seq_of(to_top)) else null)),
	},
	[
		{
			"option": "OK",
			"ability": {
				"msg": {
					"public": func(state, side, eid, card, targets):
						return str("trash a card from among the top ") + str(NRCardRT.count_of(cards)) + str(" cards of R&D") + str((", " if NRCardRT.seq_of(to_top) else " and ")) + str("add another one of those cards to HQ") + str((", and re-arrange the remainder" if NRCardRT.truthy(NRCardRT.seq_of(to_top)) else null)),
					"corp": func(state, side, eid, card, targets):
						return str("trash ") + str(NRCardRT.getv(to_trash, "title")) + str(" from among the top ") + str(NRCardRT.count_of(cards)) + str(" cards of R&D") + str((", " if NRCardRT.seq_of(to_top) else " and ")) + str(str("add ") + str(NRCardRT.getv(to_add, "title")) + str(" to HQ")) + str((str(", and re-arrange the remainder (top->bottom): ") + str(NRCardRT.enumerate_cards(NRCardRT.as_array(to_top))) if NRCardRT.truthy(NRCardRT.seq_of(to_top)) else null)),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, side, to_add, "hand")
					NRMoving.move(
						state,
						side,
						to_trash,
						"deck",
						{
							"front": true,
						}
					)
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, state.get_in(["corp", "deck", 0], null), {
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
			"ability": interact(cards, cards, null, null, []),
		}
	]
) if NRCardRT.truthy((not NRCardRT.truthy(NRCardRT.seq_of(remaining)))) else ({
	"prompt": "Choose a card to trash",
	"choices": remaining,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, interact(cards, _remove_card_9(remaining, target), target, null, []), card, null),
} if NRCardRT.truthy((not NRCardRT.truthy(to_trash))) else ({
	"prompt": "Choose a card to add to HQ",
	"choices": remaining,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, interact(cards, _remove_card_9(remaining, target), to_trash, target, []), card, null),
} if NRCardRT.truthy((not NRCardRT.truthy(to_add))) else {
	"prompt": "Add a card to the top of R&D",
	"choices": remaining,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREngine.resolve_ability(state, side, eid, interact(cards, _remove_card_9(remaining, target), to_trash, to_add, (NRCardRT.as_array(to_top) + [target])), card, null),
})))

static func _name_a_card_11():
	return {
	"async": true,
	"prompt": "Name a Runner card",
	"choices": {
		"card-title": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return (NRCard.runner(target) and (not NRCardRT.truthy(NRCard.identity(target)))),
	},
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str("name ") + str(target),
	"effect": func(state, side, eid, card, targets):
		return NREngine.resolve_ability(state, side, eid, damage_ability(), card, targets),
}

static func _damage_ability_12():
	return {
	"async": true,
	"msg": "do 1 net damage",
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRDamage.damage(state, side, ne, "net", 1, {
				"card": card,
			})
		, func(async_result):
			(func():
				var should_continue = (not NRCardRT.truthy(NRCardRT.getv(state.data, "winner")))
				var cards = NRCardRT.some_list(NREvents.turn_events(state, "corp", "damage"), func(_pct):
					return (NRCardRT.getv(NRCardRT.getv(_pct, 0), "cards-trashed") if NRCardRT.truthy(NRUtil.same_card(NRCardRT.getv(NRCardRT.getv(_pct, 0), "card"), card)) else null))
				var dmg = NRCardRT.some_list(cards, func(_pct):
					return (_pct if NRCardRT.truthy(((NRCardRT.getv(_pct, "title") == target) or NRUtil.kw_eq(NRCardRT.getv(_pct, "title"), target))) else null))
				return NREngine.resolve_ability(state, side, eid, (_name_a_card_11() if NRCardRT.truthy((should_continue and dmg)) else null), card, null)
			).call()),
}

static func _number_of_non_empty_remotes_13(state):
	return NRCardRT.count_of(NRCardRT.filter_list(NRCardRT.map_list(NRBoard.get_remotes(state), func(_pct):
		return NRCardRT.getv(NRCardRT.getv(_pct, 1), "content")), func(x): return NRCardRT.truthy(seq.call(x) if seq is Callable else seq)))

static func _count_resources_14(state):
	return (2 * NRCardRT.count_of(NRCardRT.filter_list(NRBoard.all_active_installed(state, "runner"), NRCard.resource)))

static func _full_servers_15(state):
	return NRCardRT.count_of(NRCardRT.filter_list((NRBoard.get_remotes(state) as Dictionary).values(), func(_pct):
		return (NRCardRT.seq_of(NRCardRT.getv(_pct, "content")) and NRCardRT.seq_of(NRCardRT.getv(_pct, "ices")))))

static func _full_servers_16(state):
	return NRCardRT.filter_list((NRBoard.get_remotes(state) as Dictionary).values(), func(_pct):
		return (NRCardRT.seq_of(NRCardRT.getv(_pct, "content")) and NRCardRT.seq_of(NRCardRT.getv(_pct, "ices"))))

static func _repeat_choice_17(current, total):
	return ({
	"async": true,
	"prompt": str("Choose one. Choice ") + str(current) + str(" of ") + str(total),
	"choices": ["Gain 2 [Credits]", "Draw 2 cards"],
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str(NRCardRT.decapitalize(target)),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return (NREid.wait_for(state, eid, func(ne):
			NRGaining.gain_credits(state, "corp", ne, 2)
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, repeat_choice((int(current) + 1), total), card, null)) if ((target == "Gain 2 [Credits]") or NRUtil.kw_eq(target, "Gain 2 [Credits]")) else NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "corp", ne, 2)
		, func(async_result):
			NREngine.resolve_ability(state, side, eid, repeat_choice((int(current) + 1), total), card, null))),
} if NRCardRT.truthy((current <= total)) else null)

static func _hr_final_18(chosen, original):
	return {
	"prompt": str("The top cards of R&D will be ") + str(NRCardRT.enumerate_cards(chosen)),
	"choices": ["Done", "Start over"],
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return ((func():
			(func():
				for c in NRCardRT.as_array(NRCardRT.as_array(chosen)):
					NRMoving.move(
				state,
				"corp",
				c,
				"deck",
				{
					"front": true,
				}
			)
				return null
			).call()
			NRPrompts.clear_wait_prompt(state, "runner")
			return NREid.effect_completed(state, side, eid)
		).call() if ((target == "Done") or NRUtil.kw_eq(target, "Done")) else NREngine.resolve_ability(state, side, eid, hr_choice(original, null, 3, original), card, null)),
}

static func _hr_choice_19(remaining, chosen, n, original):
	return {
	"prompt": "Choose a card to move next onto R&D",
	"choices": remaining,
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return (func():
			var chosen = ([target] + NRCardRT.as_array(chosen))
			return (NREngine.resolve_ability(state, side, eid, hr_choice(
				NRCardRT.filter_list(remaining, func(x): return not NRCardRT.truthy((func(_pct):
					return ((target == _pct) or NRUtil.kw_eq(target, _pct))).call(x))),
				chosen,
				n,
				original
			), card, null) if (NRCardRT.count_of(chosen) < n) else NREngine.resolve_ability(state, side, eid, _hr_final_18(chosen, original), card, null))
		).call(),
}

static func _dmg_count_20(state):
	return (2 * count_tags(state))

static func _valid_agenda_21(state, c, x):
	return (NRCard.agenda(c) and ((NRCardRT.getv(c, "zone") == ["scored"]) or NRUtil.kw_eq(NRCardRT.getv(c, "zone"), ["scored"])) and ((NRCardRT.getv(c, "scored-side") == "runner") or NRUtil.kw_eq(NRCardRT.getv(c, "scored-side"), "runner")) and NRCardRT.getv(c, "title") and ((NRCardRT.getv(c, "agendapoints") == x) or NRUtil.kw_eq(NRCardRT.getv(c, "agendapoints"), x)))

static func _resolve_fixed_cost_abi_22(state, side, eid, card, x):
	return NREngine.resolve_ability(state, side, eid, ({
	"cost": [NRPayment.to_c("tag", x), NRPayment.to_c("credit", x)],
	"prompt": str("Choose an agenda with ") + str(x) + str(" printed agenda points"),
	"choices": {
		"req": func(state, side, eid, card, targets):
			var target = NRCardRT.first_target(targets)
			return _valid_agenda_21(state, target, x),
	},
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		var tagged = NRUtil.is_tagged(state)
		return (func():
			var updated_card = NRUpdate.update_card(state, side, NRUtil.merge(target, {"counter": {}(NRCardRT.getv(target, "counter"))}))
			return NRInstalling.corp_install(
				state,
				side,
				eid,
				NRCard.get_card(state, target),
				null,
				{
					"msg-keys": {
						"install-source": card,
						"known": true,
						"include-cost-from-eid": eid,
						"set-zone": "the Runner score area",
						"display-origin": true,
					},
					"counters": {
						"advance-counter": (1 if tagged else 0),
					},
				}
			)
		).call(),
} if NRCardRT.some_list(state.get_in(["runner", "scored"], null), func(_pct):
	return _valid_agenda_21(state, _pct, x)) else {
	"cost": [NRPayment.to_c("tag", x), NRPayment.to_c("credit", x)],
	"change-in-game-state": {
		"req": func(state, side, eid, card, targets):
			return false,
	},
}), card, null)

static func _mitosis_ability_23(state, side, card, eid, target_cards):
	return NREid.wait_for(state, eid, func(ne):
		NRInstalling.corp_install(state, side, ne, NRCardRT.getv(target_cards, 0), "New remote", {
			"counters": {
				"advance-counter": 2,
			},
			"msg-keys": {
				"install-source": card,
				"display-origin": true,
			},
	})
, func(async_result):
	(func():
		var installed_card = async_result
		return NRFlags.register_turn_flag(
		state,
		side,
		card,
		"can-rez",
		func(state, _, card):
			return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot rez due to Mitosis.", "warning")) if NRUtil.same_card(card, installed_card) else true)
	) if installed_card != null and NRCardRT.truthy(installed_card) else NRFlags.register_turn_flag(
		state,
		side,
		card,
		"can-score",
		func(state, _, card):
			return ((func(_a=null, _b=null, _c=null, _d=null, _e=null): return false)(NRToasts.toast(state, "corp", "Cannot score due to Mitosis.", "warning")) if NRUtil.same_card(card, installed_card) else true)
	)
	).call()
	(mitosis_ability(state, side, card, eid, NRCardRT.drop_n(target_cards, 1)) if NRCardRT.seq_of(NRCardRT.drop_n(target_cards, 1)) else NREid.effect_completed(state, side, eid)))

static func _install_card_25(chosen):
	return {
	"prompt": "Choose a remote server",
	"choices": func(state, side, eid, card, targets):
		return (NRCardRT.as_array(NRCardRT.as_array(NRBoard.get_remote_names(state))) + ["New remote"]),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NRInstalling.corp_install(
			state,
			side,
			eid,
			chosen,
			target,
			{
				"ignore-all-cost": true,
				"counters": {
					"advance-counter": 3,
				},
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			}
		),
}

static func _install_card_26(chosen):
	return {
	"prompt": "Choose a remote server",
	"waiting-prompt": true,
	"choices": func(state, side, eid, card, targets):
		return (NRCardRT.as_array(NRCardRT.as_array(NRBoard.get_remote_names(state))) + ["New remote"]),
	"async": true,
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		var corp = state.player("corp")
		return NRInstalling.corp_install(
			state,
			side,
			eid,
			chosen,
			target,
			{
				"msg-keys": {
					"install-source": card,
					"origin-index": NRCardRT.getv([], 0),
					"display-origin": true,
				},
			}
		),
}

static func _clear_counters_27(state, side, eid, _p):
	return (NREid.wait_for(state, eid, func(ne):
		NRProps.add_prop(state, side, ne, c, "advance-counter", (-NRCard.get_counters(c, "advancement")), {
			"placed": true,
			"suppress-checkpoint": true,
	})
, func(async_result):
	clear_counters(state, side, eid, NRCardRT.drop_n(installed, 1))) if NRCardRT.seq_of(installed) else NREid.effect_completed(state, side, eid))

static func _replant_28(n):
	return {
	"prompt": "Choose a card to install",
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
			(NREngine.resolve_ability(state, side, eid, replant((int(n) + 1)), card, null) if (n < 2) else NREid.effect_completed(state, side, eid))),
}

static func _ability_30(x):
	return {
	"prompt": func(state, side, eid, card, targets):
		return str("Choose an installed card to place advancement counters on (") + str(x) + str(" remaining)"),
	"async": true,
	"waiting-prompt": true,
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.installed(_pct)),
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
			(NREngine.resolve_ability(state, side, eid, ability((int(x) - 1)), card, null) if (x > 1) else NREid.effect_completed(state, side, eid))),
}

static func _sc_31(i, sccard):
	return {
	"prompt": "Choose an operation in HQ to play",
	"choices": {
		"card": func(_pct):
			return (NRCard.corp(_pct) and NRCard.operation(_pct) and NRCard.in_hand(_pct)),
	},
	"async": true,
	"msg": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return str("play ") + str(NRCardRT.getv(target, "title")),
	"effect": func(state, side, eid, card, targets):
		var target = NRCardRT.first_target(targets)
		return NREid.wait_for(state, eid, func(ne):
			NRPlayInstants.play_instant(state, side, ne, target, null)
		, func(async_result):
			(NREngine.resolve_ability(state, side, eid, sc((int(i) + 1), sccard), sccard, null) if ((not NRCardRT.truthy(state.get_in(["corp", "register", "terminal"], null))) and (i < 2)) else NREid.effect_completed(state, side, eid))),
}

static func _advance_n_times_32(state, side, eid, card, target, n):
	return (NREid.wait_for(state, eid, func(ne):
		advance(state, "corp", ne, NRCard.get_card(state, target), "no-cost")
, func(async_result):
	advance_n_times(state, side, eid, card, target, (int(n) - 1))) if NRCardRT.pos(n) else NREid.effect_completed(state, side, eid))

static func _sun_33(serv):
	return {
	"prompt": "Choose 2 pieces of ice to swap",
	"choices": {
		"card": func(_pct):
			return (((serv == NRCard.get_zone(_pct)) or NRUtil.kw_eq(serv, NRCard.get_zone(_pct))) and NRCard.ice(_pct)),
		"max": 2,
	},
	"async": true,
	"effect": func(state, side, eid, card, targets):
		return ((func():
			NRMoving.swap_ice(state, side, NRCardRT.getv(targets, 0), NRCardRT.getv(targets, 1))
			NRSay.system_msg(state, side, str("uses ") + str(NRCardRT.getv(card, "title")) + str(" to swap ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 0))) + str(" with ") + str(NRToString.card_str(state, NRCardRT.getv(targets, 1))))
			return NREngine.resolve_ability(state, side, eid, sun(serv), card, null)
		).call() if ((NRCardRT.count_of(targets) == 2) or NRUtil.kw_eq(NRCardRT.count_of(targets), 2)) else (func():
			NRSay.system_msg(state, side, "has finished rearranging ice")
			return NREid.effect_completed(state, side, eid)
		).call()),
}
