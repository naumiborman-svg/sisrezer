class_name NRCardsIdentities
extends RefCounted

## Port of game.cards.identities — translated from Jinteki.net Clojure.
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


static func draft_points_target(_a=null, _b=null, _c=null, _d=null):
	return null


static func has_most_faction_p(state, side, fc):
	return (func():
		var card_list = NRBoard.all_active_installed(state, side)
		var faction_freq = frequencies(NRUtil.as_array(card_list).map(func(_x): return bool(NRCardXlate.getk(_x, "faction"))))
		var reducer = func(_p, faction, count): return ({
			"max-count": count,
			"max-faction": faction,
		} if (count > max_count) else (NRUtil.dissoc(acc if acc is Dictionary else {}, ["max-faction"]) if ((count == max_count) or NRUtil.kw_eq(count, max_count)) else acc))
		var best_faction = NRCardXlate.getk(reduce_kv(reducer, {
			"max-count": 0,
			"max-faction": null,
		}, faction_freq), "max-faction", null)
		return ((fc == best_faction) or NRUtil.kw_eq(fc, best_faction))
	).call()


static func _register_1() -> void:
	NRCardDefs.defcard("419: Amoral Scammer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "The first time the Corp installs a card each turn, you may expose that card unless the Corp pays 1[Credits].",
		"code": "21063",
		"title": "419: Amoral Scammer",
	}, {
		"events": [
			{
			"event": "corp-install",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, "corp", "corp-install") and (NRCardXlate.getk(state, "turn", null) > 0) and (not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))) and (not (NRUtil.in_coll(["face-up"], NRCardXlate.getk(NRCardXlate.ctx(targets), "install-state", null))))),
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": "Expose installed card unless the Corp pays 1 [Credits]?",
					"autoresolve": NROptional.get_autoresolve("auto-fire"),
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRPrompts.clear_wait_prompt(state, "corp"),
					},
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return ((func():
							NRToasts.toast(state, "corp", "Cannot afford to pay 1 [Credit] to block card exposure", "info")
							return NRExpose.expose(state, "runner", eid, [NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)])
						).call() if (not (NRPayment.can_pay(state, "corp", eid, card, null, NRPayment.to_c("credit", 1)))) else NREngine.continue_ability(state, side, {
							"optional": {
								"waiting-prompt": true,
								"prompt": func(state, side, eid, card, targets):
									return (str("Pay 1 [Credits] to prevent exposing ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) + str("?")),
								"player": "corp",
								"no-ability": {
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NRExpose.expose(state, "runner", eid, [NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)]),
								},
								"yes-ability": {
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NREid.wait_for(state, eid, func(ne):
										NREngine.pay(state, "corp", ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("credit", 1)])
									, func(async_result):
										(func():
										NRSay.system_msg(state, "corp", (str(NRCardXlate.getk(async_result, "msg", null)) + str(" to prevent exposing ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))))
										return NREid.effect_completed(state, side, eid)
									).call()),
								},
							},
						}, card, targets)),
					},
				},
			}, card, targets),
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "419: Amoral Scammer")],
	}))

	NRCardDefs.defcard("A Teia: IP Recovery", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Limit 2 remote servers.\nThe first time each turn you install a card in the root of or protecting a remote server, you may install 1 card from HQ in the root of or protecting another remote server, ignoring all costs. You cannot score the second card this turn.",
		"code": "34039",
		"title": "A Teia: IP Recovery",
	}, {
		"flags": {
			"server-limit": 2,
		},
		"events": [
			{
			"event": "corp-install",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))).size() > 1 else null)) and NREvents.first_event(state, side, "corp-install", func(_pct, _pct2=null, _pct3=null): return NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))).size() > 1 else null)))),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var original_server = NRServers.zone_to_name((NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))).size() > 1 else null))
				return NREngine.continue_ability(state, side, {
					"prompt": "Choose a card to install in or protecting another remote server",
					"waiting-prompt": true,
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and corp_installable_type_p(_pct) and NRCard.in_hand(_pct) and not_every_p(["HQ", "R&D", "Archives"], NRBoard.installable_servers(state, _pct))),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var chosen_card = NRCardXlate.first_target(targets)
						return NREngine.continue_ability(state, side, {
							"prompt": "Choose a remote server",
							"waiting-prompt": true,
							"choices": func(state, side, eid, card, targets):
								return (NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRBoard.get_remote_names(state)).filter(func(_pct, _pct2=null, _pct3=null): return (not (((original_server == _pct) or NRUtil.kw_eq(original_server, _pct))))))) + ["New remote"]),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRInstalling.corp_install(state, side, eid, chosen_card, NRCardXlate.first_target(targets), {
								"ignore-install-cost": true,
								"msg-keys": {
									"install-source": card,
									"display-origin": true,
								},
							}),
						}, card, null)
					).call(),
				}, card, null)
			).call(),
		},
		],
		"enforce-conditions": {
			"req": func(state, side, eid, card, targets): return (2 < NRUtil.as_array(NRBoard.get_remote_names(state)).size()),
			"prompt": "Choose 2 servers to be saved from the rules apocalypse",
			"choices": func(state, side, eid, card, targets):
				return NRBoard.get_remote_names(state),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var saved = NRCardXlate.first_target(targets)
				return NREngine.continue_ability(state, side, {
					"prompt": "Choose another server to save",
					"choices": func(state, side, eid, card, targets):
						return NRUtil.as_array(NRBoard.get_remote_names(state)).filter(func(_pct, _pct2=null, _pct3=null): return (not (((saved == _pct) or NRUtil.kw_eq(saved, _pct))))),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var to_be_trashed = NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return NRUtil.in_coll(["Archives", "R&D", "HQ", NRCardXlate.first_target(targets), saved], NRServers.zone_to_name((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))).call(_x)))
						return (func():
							NRSay.system_msg(state, side, (str("chooses ") + str(NRCardXlate.first_target(targets)) + str(" and ") + str(saved) + str(" to be saved from the rules apocalypse and trashes ") + str(NRUtil.quantify(NRUtil.as_array(to_be_trashed).size(), "card"))))
							return NRMoving.trash_cards(state, side, eid, to_be_trashed, {
								"unpreventable": true,
								"game-trash": true,
							})
						).call()
					).call(),
				}, card, null)
			).call(),
		},
	}))

	NRCardDefs.defcard("AU Co.: The Gold Standard in Clones", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever you do damage or trash 1 or more cards from HQ, place 1 power counter on this identity.\nWhen your turn begins, you may remove 2 hosted power counters to look at the top 3 cards of R&D. Trash 1 of those cards and add the rest to HQ.",
		"code": "35046",
		"title": "AU Co.: The Gold Standard in Clones",
	}, (func():
		var abi = {
			"msg": "place 1 power counter on itself",
			"label": "Manually place 1 power counter",
			"once-per-instance": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		}
		var start_of_turn_ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"event": "corp-turn-begins",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (2 <= NRCard.get_counters(card, "power")),
			},
			"label": "Look at the top 3 cards of R&D",
			"optional": {
				"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()) and NRCardXlate.getk(state, "corp-phase-12", null)),
				"prompt": "Look at the top 3 cards of R&D?",
				"waiting-prompt": true,
				"yes-ability": {
					"cost": [NRPayment.to_c("power", 2)],
					"async": true,
					"msg": "look at the top 3 cards of R&D",
					"effect": func(state, side, eid, card, targets):
						return (func():
						var top_3 = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))
						var to_draw = (NRUtil.as_array(top_3).size() - 1)
						return NREngine.continue_ability(state, side, {
							"async": true,
							"prompt": (str("The top of R&D is (top->bottom): ") + str(NRUtil.enumerate_cards(top_3)) + str(". Choose a card to trash")),
							"not-distinct": true,
							"choices": func(state, side, eid, card, targets):
								return top_3,
							"msg": func(state, side, eid, card, targets): return str((func():
								var target_position = NRUtil.first_of(positions([NRCardXlate.first_target(targets)], NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))))
								var position = ("top " if (target_position == 0) else ("second " if (target_position == 1) else ("third " if (target_position == 2) else "this-should-not-happen ")))
								return (str("trash the ") + str(position) + str("card from R&D"))
							).call()) + str(((str(" and draw ") + str(to_draw) + str(" cards")) if (to_draw > 0) else null)),
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRMoving.trash(state, "corp", ne, NRCardXlate.first_target(targets), {
								"cause-card": card,
								"suppress-checkpoint": (to_draw > 0),
							})
							, func(async_result):
								(NRDrawing.draw(state, side, eid, to_draw) if (to_draw > 0) else NREid.effect_completed(state, side, eid))),
						}, card, null)
					).call(),
				},
			},
		}
		return {
			"events": [
				NRUtil.merge(abi if abi is Dictionary else {}, {"event": "damage"}),
				NRUtil.merge(abi if abi is Dictionary else {}, {"event": "corp-trash"}),
				start_of_turn_ability,
			],
			"abilities": [abi, start_of_turn_ability],
		}
	).call()))

	NRCardDefs.defcard("Acme Consulting: The Truth You Need", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Subsidiary",
		"subtypes": ["Subsidiary"],
		"text": "The Runner is considered to have 1 additional tag (even if they have 0) during encounters with the outermost piece of ice protecting any server.",
		"code": "22042",
		"title": "Acme Consulting: The Truth You Need",
	}, (func():
		return {
			"static-abilities": [
				{
				"type": "tags",
				"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state)) and outermost_p(state, NRIce.get_current_ice(state))),
				"value": 1,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Adam: Compulsive Hacker", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Adam",
		"baselink": 0,
		"influencelimit": 25,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "You start the game with 3 different <strong>directive</strong> cards installed (these cards are not considered part of your deck).",
		"code": "09037",
		"title": "Adam: Compulsive Hacker",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"req": func(state, side, eid, card, targets): return ((side == "runner") or NRUtil.kw_eq(side, "runner")),
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var directives = (NRUtil.as_array([]) + NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(server_cards()).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Directive"))).map(NRInitializing.make_card)).map(func(_pct, _pct2=null, _pct3=null): return NRUtil.merge(_pct if _pct is Dictionary else {}, {"zone": ["play-area"]}))))
				return (func():
					state.assoc_in(["runner", "play-area"], directives)
					return NREngine.continue_ability(state, side, {
						"prompt": str("Choose 3 starting directives"),
						"choices": {
							"max": 3,
							"all": true,
							"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_play_area(_pct)),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, eid), NRUtil.first_of(targets), {
							"ignore-all-cost": true,
							"custom-message": func(_): return (str("starts with ") + str(NRCardXlate.getk(NRUtil.first_of(targets), "title", null)) + str(" in play")),
						})
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
							NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, eid), (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), {
							"ignore-all-cost": true,
							"custom-message": func(_): return (str("starts with ") + str(NRCardXlate.getk((NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), "title", null)) + str(" in play")),
						})
						, func(async_result):
							NREid.wait_for(state, eid, func(ne):
							NRInstalling.runner_install(state, side, ne, NREid.make_eid(state, eid), NRUtil.first_of(next(next(targets))), {
							"ignore-all-cost": true,
							"custom-message": func(_): return (str("starts with ") + str(NRCardXlate.getk(NRUtil.first_of(next(next(targets))), "title", null)) + str(" in play")),
						})
						, func(async_result):
							(func():
							state.assoc_in(["runner", "play-area"], [])
							return NREid.effect_completed(state, null, eid)
						).call()))),
					}, card, null)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("AgInfusion: New Miracles for a New World", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 17,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Once per turn → <strong>Trash the unrezzed piece of ice the Runner is approaching:</strong> Choose a server other than the attacked server. The Runner moves to the outermost position of that server and encounters any ice there.",
		"code": "12052",
		"title": "AgInfusion: New Miracles for a New World",
	}, {
		"abilities": [
			{
			"label": "Trash a piece of ice to choose another server- the runner is now running that server",
			"once": "per-turn",
			"async": true,
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (("approach-ice" == NRCardXlate.getk(state.getv("run"), "phase", null)) or NRUtil.kw_eq("approach-ice", NRCardXlate.getk(state.getv("run"), "phase", null))) and (not (NRCard.rezzed(NRIce.get_current_ice(state))))),
			"prompt": "Choose another server and redirect the run to its outermost position",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRServers.zones_to_sorted_names(NRBoard.get_zones(state))).filter(func(_x): return not ((func(_x): return NRUtil.in_coll([
				NRServers.central_to_name(NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "server", null)),
			], _x)).call(_x))),
			"msg": func(state, side, eid, card, targets): return str("trash the approached piece of ice. The Runner is now running on ") + str(NRCardXlate.first_target(targets)),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var dest = NRBoard.server_to_zone(state, NRCardXlate.first_target(targets))
				var ice = NRUtil.as_array(NRUtil.get_in(state.getv("corp", {}), (NRUtil.as_array(dest) + ["ices"]), null)).size()
				var phase = ("encounter-ice" if (ice > 0) else "movement")
				return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, NREid.make_eid(state, eid), NRIce.get_current_ice(state), {
					"unpreventable": true,
				})
				, func(async_result):
					(func():
					NRRuns.redirect_run(state, side, NRCardXlate.first_target(targets), phase)
					return start_next_phase(state, side, eid)
				).call())
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Akiko Nisei: Head Case", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 1,
		"influencelimit": 12,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Clone",
		"subtypes": ["Clone"],
		"text": "Whenever you breach R&D, you and the Corp secretly spend 0[Credits], 1[Credits], or 2[Credits]. Reveal spent credits. If you and the Corp spent the same number of credits, access 1 additional card.",
		"code": "22015",
		"title": "Akiko Nisei: Head Case",
	}, {
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"psi": {
				"req": func(state, side, eid, card, targets): return (("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
				"equal": {
					"msg": "access 1 additional card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRAccess.access_bonus(state, side, "rd", 1)
						return NREid.effect_completed(state, side, eid),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Alice Merchant: Clan Agitator", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 50,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "The first time you make a successful run on Archives each turn, the Corp must trash 1 card from HQ.",
		"code": "12061",
		"title": "Alice Merchant: Clan Agitator",
	}, {
		"events": [
			{
			"event": "successful-run",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"automatic": "force-discard",
			"req": func(state, side, eid, card, targets): return ((("archives" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("archives", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "archives")),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
			},
			"waiting-prompt": true,
			"prompt": "Choose a card in HQ to discard",
			"player": "corp",
			"choices": {
				"all": true,
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.corp(_pct)),
			},
			"msg": "force the Corp to trash 1 card from HQ",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, "corp", eid, NRCardXlate.first_target(targets), null),
		},
		],
	}))

	NRCardDefs.defcard("Ampère: Cybernetics For Anyone", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Neutral",
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "Your deck cannot include more than 1 copy of any card.\nYour deck may include up to 2 different agenda cards from each Corp faction.",
		"code": "33128",
		"title": "Ampère: Cybernetics For Anyone",
	}, {}))

	NRCardDefs.defcard("Andromeda: Dispossessed Ristie", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "You draw a starting hand of 9 cards.",
		"code": "02083",
		"title": "Andromeda: Dispossessed Ristie",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"req": func(state, side, eid, card, targets): return ((side == "runner") or NRUtil.kw_eq(side, "runner")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 4, {
				"suppress-event": true,
			}),
		},
		],
		"mulligan": func(state, side, eid, card, targets):
			return NRDrawing.draw(state, side, eid, 4, {
			"suppress-event": true,
		}),
	}))

	NRCardDefs.defcard("Apex: Invasive Predator", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Apex",
		"baselink": 0,
		"influencelimit": 25,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Digital",
		"subtypes": ["Digital"],
		"text": "You cannot install non-<strong>virtual</strong> resources.\nWhen your turn begins, you may install 1 card from your grip facedown.",
		"code": "09029",
		"title": "Apex: Invasive Predator",
	}, (func():
		var ability = {
			"prompt": "Choose a card to install facedown",
			"label": "Install a card facedown (start of turn)",
			"once": "per-turn",
			"choices": {
				"max": 1,
				"req": func(state, side, eid, card, targets):
					return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets))),
			},
			"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() > 0) and NRCardXlate.getk(state, "runner-phase-12", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"facedown": true,
				"msg-keys": {
					"install-source": card,
				},
			}),
		}
		return {
			"implementation": "Install restriction not enforced",
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"flags": {
				"runner-phase-12": func(state, side, eid, card, targets):
					return true,
			},
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Argus Security: Protection Guaranteed", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "Whenever the Runner steals an agenda, they must take 1 tag or suffer 2 meat damage.",
		"code": "07001",
		"title": "Argus Security: Protection Guaranteed",
	}, {
		"events": [
			{
			"event": "agenda-stolen",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"async": true,
			"choices": ["Take 1 tag", "Suffer 2 meat damage"],
			"player": "runner",
			"display-side": "corp",
			"msg": func(state, side, eid, card, targets): return str("force the Runner to ") + str(decapitalize(NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return (NRTags.gain_tags(state, "runner", eid, 1) if ((NRCardXlate.first_target(targets) == "Take 1 tag") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Take 1 tag")) else NRDamage.damage(state, "runner", eid, "meat", 2, {
				"unboostable": true,
				"card": card,
			})),
		},
		],
	}))

	NRCardDefs.defcard("Armand \"Geist\" Walker: Tech Lord", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "Whenever you use a [Trash] ability, draw 1 card.",
		"code": "08063",
		"title": "Armand \"Geist\" Walker: Tech Lord",
	}, {
		"events": [
			{
			"event": "costs-paid",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((("runner" == NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null)) or NRUtil.kw_eq("runner", NRCardXlate.getk(NRCardXlate.ctx(targets), "side", null))) and (NRUtil.find_first(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "payment", null)).map(func(_x): return bool(NRCardXlate.getk(_x, "paid/type")))), func(_x): return NRUtil.in_coll(["trash-can"], _x)) != null)),
			"msg": "draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Arissana Rocha Nahu: Street Artist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Once per turn → <strong>0[Credits]:</strong> Install 1 program from your grip <em>(paying its install cost)</em>. Use this ability only during a run. When that run ends, trash that program if it is not a <strong>trojan</strong>.",
		"code": "34020",
		"title": "Arissana Rocha Nahu: Street Artist",
	}, {
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NREngine.not_used_once(state, {
				"once": "per-turn",
			}, card) and (not (NRInstalling.install_locked(state, side)))),
			"async": true,
			"label": "Install a program from the grip",
			"prompt": "Choose a program to install",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source-type": "runner-install"}), _pct, {
				"no-toast": true,
			}))),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRInstalling.runner_install(state, "runner", ne, NRUtil.merge(NREid.make_eid(state, eid) if NREid.make_eid(state, eid) is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
			, func(async_result):
				(func():
				register_once(state, side, {
					"once": "per-turn",
				}, card)
				(func():
					var installed_card = async_result
					return (NREngine.register_events(state, side, card, [
					{
					"event": "run-ends",
					"interactive": func(state, side, eid, card, targets):
						return true,
					"duration": "end-of-run",
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets): return (func():
							var c = NRCard.get_card(state, installed_card)
							return (not (NRCard.has_subtype(c, "Trojan"))) if c != null else null
						).call(),
					},
					"async": true,
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(installed_card, "title", null)),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, installed_card),
				},
				]) if state.getv("run") else null) if installed_card != null else null
				).call()
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Asa Group: Security Through Vigilance", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn you install a card, you may install 1 non-agenda card from HQ in the root of or protecting the same server.",
		"code": "21009",
		"title": "Asa Group: Security Through Vigilance",
	}, {
		"events": [
			{
			"event": "corp-install",
			"async": true,
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, "corp", "corp-install"),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var installed_card = NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)
				var z = butlast(NRCard.get_zone(installed_card))
				return NREngine.continue_ability(state, side, {
					"prompt": "Choose a non-agenda card in HQ to install",
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.corp(_pct) and corp_installable_type_p(_pct) and (NRServers.is_remote(z) or (not (NRCard.asset(_pct)))) and (not (NRCard.agenda(_pct)))),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRInstalling.corp_install(state, side, eid, NRCardXlate.first_target(targets), NRServers.zone_to_name(z), {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}),
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Ayla \"Bios\" Rahim: Simulant Specialist", NRCardXlate.merge_cdef({
		"title": "Ayla \"Bios\" Rahim: Simulant Specialist",
	}, {
		"abilities": [
			{
			"action": true,
			"label": "Add 1 hosted card to the grip",
			"cost": [NRPayment.to_c("click", 1)],
			"async": true,
			"prompt": "Choose a hosted card",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.getk(card, "hosted", null),
			"msg": "add a hosted card to the grip",
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				return NREid.effect_completed(state, side, eid),
		},
		],
		"events": [
			{
			"event": "pre-start-game",
			"req": func(state, side, eid, card, targets): return ((side == "runner") or NRUtil.kw_eq(side, "runner")),
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				(func():
				for c in NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(6))):
					NRMoving.move(state, side, c, "play-area")
				return null
			).call()
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose 4 cards to be hosted",
				"choices": {
					"max": 4,
					"all": true,
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_play_area(_pct)),
				},
				"effect": func(state, side, eid, card, targets):
					(func():
					for c in NRUtil.as_array(targets):
						NRHosting.host(state, side, NRCard.get_card(state, card), c, {
					"facedown": true,
				})
					return null
				).call()
					(func():
					for c in NRUtil.as_array(state.get_in(["runner", "play-area"], null)):
						NRMoving.move(state, side, c, "deck")
					return null
				).call()
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Az McCaffrey: Mechanical Prodigy", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "The first <strong>job</strong> resource, <strong>connection</strong> resource, or piece of hardware you install each turn costs 1[Credits] less to install.",
		"code": "26010",
		"title": "Az McCaffrey: Mechanical Prodigy",
	}, (func():
		var _b0 = not_triggered_p([state], NREvents.no_event(state, "runner", "runner-install", func(_pct, _pct2=null, _pct3=null): return az_type_p(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))))
		return {
			"static-abilities": [
				{
				"type": "install-cost",
				"req": func(state, side, eid, card, targets): return (az_type_p(NRCardXlate.first_target(targets)) and not_triggered_p(state)),
				"value": -1,
			},
			],
			"events": [
				{
				"event": "runner-install",
				"req": func(state, side, eid, card, targets): return (az_type_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and not_triggered_p(state)),
				"silent": true,
				"msg": func(state, side, eid, card, targets): return str("reduce the install cost of ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) + str(" by 1 [Credits]"),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Azmari EdTech: Shaping the Future", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "When your turn ends, you may name a card type. Gain 2[Credits] the first time each turn the Runner plays or installs a card that has the type you last named this way.",
		"code": "21054",
		"title": "Azmari EdTech: Shaping the Future",
	}, {
		"events": [
			{
			"event": "corp-turn-ends",
			"prompt": "Choose a card type",
			"choices": ["Event", "Resource", "Program", "Hardware", "None"],
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": (null if (("None" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("None", NRCardXlate.first_target(targets))) else NRCardXlate.first_target(targets))}))
				return (NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))) if (("None" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("None", NRCardXlate.first_target(targets))) else NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to name ") + str(NRCardXlate.first_target(targets))))),
		},
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(card, "card-target", null) and NRCard.is_type(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(card, "card-target", null)) and NREvents.first_event(state, "runner", "runner-install", func(_pct, _pct2=null, _pct3=null): return NRCard.is_type(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null), NRCardXlate.getk(card, "card-target", null))) and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "facedown", null)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 2),
			"msg": func(state, side, eid, card, targets): return str("gain 2 [Credits] from ") + str(NRCardXlate.getk(card, "card-target", null)),
		},
			{
			"event": "play-event",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(card, "card-target", null) and NREvents.first_event(state, "runner", "play-event") and NRCard.is_type(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(card, "card-target", null))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 2),
			"msg": func(state, side, eid, card, targets): return str("gain 2 [Credits] from ") + str(NRCardXlate.getk(card, "card-target", null)),
		},
		],
	}))

	NRCardDefs.defcard("Barry \"Baz\" Wong: Tri-Maf Veteran", NRCardXlate.merge_cdef({
		"title": "Barry \"Baz\" Wong: Tri-Maf Veteran",
	}, {
		"events": [
			{
			"async": true,
			"prompt": "Install a resource or piece of hardware",
			"event": "rez",
			"waiting-prompt": true,
			"player": "runner",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty()),
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and (NRCard.resource(NRCardXlate.first_target(targets)) or NRCard.hardware(NRCardXlate.first_target(targets))) and NRInstalling.runner_can_pay_and_install(state, side, eid, NRCardXlate.first_target(targets))),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"msg-keys": {
					"install-source": card,
				},
			}),
		},
		],
	}))

	NRCardDefs.defcard("BANGUN: When Disaster Strikes", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "You may install agendas faceup. <em>(This does not make their abilities active.)</em>\nWhenever the Runner accesses a faceup installed agenda, do 2 meat damage and give the Runner 1 tag.",
		"code": "35068",
		"title": "BANGUN: When Disaster Strikes",
	}, {
		"abilities": [
			{
			"label": "Manually turn an agenda faceup",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.agenda(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets))),
			},
			"msg": func(state, side, eid, card, targets): return str("turn ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets), {
				"visible": true,
			})) + str(" faceup"),
			"effect": func(state, side, eid, card, targets): return set_last_played_or_rezzed(state, NRUpdate.update_card(state, side, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}))),
		},
		],
		"events": [
			{
			"event": "access",
			"req": func(state, side, eid, card, targets): return (func(_x): return ((NRCard.faceup).call(_x)) and ((NRCard.installed).call(_x)) and ((NRCard.agenda).call(_x)) and ((func(_x): return bool(NRCardXlate.getk(_x, "was-seen"))).call(_x))).call(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "do 2 meat damage and give the Runner a tag",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDamage.damage(state, "corp", ne, "meat", 2, {
				"card": card,
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRTags.gain_tags(state, "corp", eid, 1)),
		},
			{
			"event": "corp-install",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"req": func(state, side, eid, card, targets): return ((not (NRCard.ice(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)))) and (not (NRCard.condition_counter(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)))) and (not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))) and (not (NRUtil.in_coll(["hq", "archives", "rd"], (NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null))).size() > 1 else null)))) and (not (NRUtil.in_coll(["face-up"], NRCardXlate.getk(NRCardXlate.ctx(targets), "install-state", null)))) and (func():
				var cards_in_slot = NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "zone", null) == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "zone", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "zone", null), NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "zone", null))))
				return (not ((NRUtil.find_first(NRUtil.as_array(cards_in_slot), func(_pct, _pct2=null, _pct3=null): return ((NRCard.asset(_pct) or NRCard.agenda(_pct)) and (NRCard.rezzed(_pct) or NRCardXlate.getk(_pct, "face-up", null)))) != null)))
			).call()),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var tcard = NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)
				return NREngine.continue_ability(state, side, ({
					"optional": {
						"prompt": (str("Turn ") + str(NRCardXlate.getk(tcard, "title", null)) + str(" faceup?")),
						"waiting-prompt": true,
						"yes-ability": {
							"msg": (str("turn ") + str(NRToString.card_str(state, tcard, {
								"visible": true,
							})) + str(" faceup")),
							"effect": func(state, side, eid, card, targets): return set_last_played_or_rezzed(state, NRUpdate.update_card(state, side, NRUtil.merge(tcard if tcard is Dictionary else {}, {"seen": true}))),
						},
					},
				} if NRCard.agenda(tcard) else {
					"prompt": "Nothing to see here",
					"waiting-prompt": true,
					"choices": ["OK"],
				}), card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Blue Sun: Powering the Future", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "When your turn begins, you may add 1 rezzed card to HQ and gain credits equal to its rez cost.",
		"code": "25123",
		"title": "Blue Sun: Powering the Future",
	}, (func():
		var blue_sun = {
			"choices": {
				"card": NRCard.rezzed,
			},
			"label": "Add 1 rezzed card to HQ and gain credits equal to its rez cost",
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to HQ and gain ") + str(NRCostFns.rez_cost(state, side, NRCardXlate.first_target(targets))) + str(" [Credits]"),
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), NRCard.rezzed) != null),
				"silent": true,
			},
			"async": true,
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
				return NRGaining.gain_credits(state, side, eid, NRCostFns.rez_cost(state, side, NRCardXlate.first_target(targets))),
		}
		return {
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and NREngine.not_used_once(state, {
					"once": "per-turn",
				}, card) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), NRCard.rezzed) != null)),
			},
			"events": [
				NRUtil.merge({
				"event": "corp-turn-begins",
				"automatic": "last",
				"skippable": true,
			} if {
				"event": "corp-turn-begins",
				"automatic": "last",
				"skippable": true,
			} is Dictionary else {}, blue_sun if blue_sun is Dictionary else {}),
			],
			"abilities": [blue_sun],
		}
	).call()))

	NRCardDefs.defcard("Boris \"Syfr\" Kovac: Crafty Veteran", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "Draft format only.\nIf you have more [criminal] cards installed than any other faction, when your turn begins, remove 1 tag.",
		"code": "00008",
		"title": "Boris \"Syfr\" Kovac: Crafty Veteran",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"effect": draft_points_target,
		},
			{
			"event": "runner-turn-begins",
			"req": func(state, side, eid, card, targets): return (has_most_faction_p(state, "runner", "Criminal") and (NRUtil.get_in(state.getv("runner", {}), ["tag", "base"], null) > 0)),
			"msg": "remove 1 tag",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Captain Padma Isbister: Intrepid Explorer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "The first time each turn a run on R&D begins, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>",
		"code": "33021",
		"title": "Captain Padma Isbister: Intrepid Explorer",
	}, {
		"events": [
			{
			"event": "run",
			"async": true,
			"req": func(state, side, eid, card, targets): return (((NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null) == ["rd"]) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "server", null), ["rd"])) and NREvents.first_event(state, side, "run", func(_pct, _pct2=null, _pct3=null): return ((["rd"] == NRCardXlate.getk(NRUtil.first_of(_pct), "server", null)) or NRUtil.kw_eq(["rd"], NRCardXlate.getk(NRUtil.first_of(_pct), "server", null))))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRCharge.charge_ability(state, side), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Cerebral Imaging: Infinite Frontiers", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Your maximum hand size is equal to the number of credits in your credit pool.",
		"code": "03001",
		"title": "Cerebral Imaging: Infinite Frontiers",
	}, {
		"static-abilities": [
			corp_hand_size_(func(state, side, eid, card, targets):
			return (NRCardXlate.getk(state.getv("corp", {}), "credit", null) - 5)),
		],
	}))

	NRCardDefs.defcard("Chaos Theory: Wünderkind", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "+1[Memory Unit]",
		"code": "25040",
		"title": "Chaos Theory: Wünderkind",
	}, {
		"static-abilities": [NRCardXlate.mu_plus(1)],
	}))

	NRCardDefs.defcard("Chronos Protocol: Haas-Bioroid", NRCardXlate.merge_cdef({
		"title": "Chronos Protocol: Haas-Bioroid",
	}, {
		"events": [
			{
			"event": "damage",
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "damage-type", null) == "brain") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "damage-type", null), "brain")),
			"msg": func(state, side, eid, card, targets): return str("remove all copies of ") + str(NRUtil.enumerate_cards(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards-trashed", null))) + str(", everywhere, from the game"),
			"effect": func(state, side, eid, card, targets):
				return (func():
				for c in NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards-trashed", null)):
					NRMoving.move(state, "runner", candidate, "rfg")
				return null
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Chronos Protocol: Selective Mind-mapping", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "For the first net damage the Runner suffers each turn, you may look at the Runner's grip and select the card that is trashed.",
		"code": "08111",
		"title": "Chronos Protocol: Selective Mind-mapping",
	}, {
		"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NREvents.turn_events(state, "runner", "damage")).filter(func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)))) is Array and NRUtil.as_array(NREvents.turn_events(state, "runner", "damage")).filter(func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)))).is_empty() if false else (str(NRUtil.as_array(NREvents.turn_events(state, "runner", "damage")).filter(func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null))))) == "")),
		"effect": func(state, side, eid, card, targets):
			return enable_corp_damage_choice(state, side),
		"leave-play": func(state, side, eid, card, targets):
			return state.update_in(["damage"], func(v): return v, 0),
		"events": [
			{
			"event": "corp-phase-12",
			"effect": func(state, side, eid, card, targets):
				return enable_corp_damage_choice(state, side),
		},
			{
			"event": "runner-phase-12",
			"effect": func(state, side, eid, card, targets):
				return enable_corp_damage_choice(state, side),
		},
			{
			"event": "pre-resolve-damage",
			"optional": {
				"req": func(state, side, eid, card, targets): return ((("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "damage-type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "damage-type", null))) and corp_can_choose_damage_p(state) and (NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null) > 0) and NREvents.no_event(state, "runner", "damage", func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "damage-type", null)))) and (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() > 0)),
				"waiting-prompt": true,
				"prompt": "Choose the first card to trash?",
				"yes-ability": with_revealed_hand("runner", {
					"no-event": true,
				}, {
					"prompt": "Choose 1 card to trash",
					"choices": {
						"card": func(_x): return ((NRCard.runner).call(_x)) and ((NRCard.in_hand).call(_x)),
					},
					"msg": func(state, side, eid, card, targets): return str("choose ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to trash"),
					"effect": func(state, side, eid, card, targets):
						return chosen_damage(state, "corp", NRCardXlate.first_target(targets)),
				}),
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, "corp", (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Cybernetics Division: Humanity Upgraded", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Each player's maximum hand size is reduced by 1.",
		"code": "08050",
		"title": "Cybernetics Division: Humanity Upgraded",
	}, {
		"static-abilities": [NRCardXlate.hand_size_plus(-1)],
	}))

	NRCardDefs.defcard("Dewi Subrotoputri: Pedagogical Dhalang", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Whenever you make a successful run, if your [Memory Unit] is full, you may flip this identity and gain 1[Credits].\nFlip side:\nWhenever you make a successful run, if you have at least 1 unused [Memory Unit], you may flip this identity and draw 1 card.",
		"code": "35023",
		"title": "Dewi Subrotoputri: Pedagogical Dhalang",
	}, (func():
		var flip_effect = {
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, (NRUtil.merge(card if card is Dictionary else {}, {"flipped": false}) if NRCardXlate.getk(card, "flipped", null) else NRUtil.merge(card if card is Dictionary else {}, {"flipped": true}))),
		}
		var maybe_flip = {
			"event": "successful-run",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(card, "flipped", null) and (NRMemory.available_mu(state) > 0)) or ((not (NRCardXlate.getk(card, "flipped", null))) and (NRMemory.available_mu(state) == 0))),
			},
			"optional": {
				"prompt": func(state, side, eid, card, targets): return str("Flip your ID (") + str(("draw 1 card)?" if NRCardXlate.getk(card, "flipped", null) else "gain 1 [Credits])?")),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return ((NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, "runner", ne, 1)
					, func(async_result):
						(func():
						NRSay.system_msg(state, side, "draws 1 card and flips [their] identity to Dewi Subrotoputri: Pedagogical Dhalang")
						return NREngine.continue_ability(state, side, flip_effect, card, targets)
					).call()) if (NRMemory.available_mu(state) > 0) else NREid.effect_completed(state, side, eid)) if NRCardXlate.getk(card, "flipped", null) else (NREid.wait_for(state, eid, func(ne):
						NRGaining.gain_credits(state, "runner", ne, 1)
					, func(async_result):
						(func():
						NRSay.system_msg(state, side, "gain 1 [Credits] and flips [their] identity to Dewi Subrotoputri: Shadow Guide")
						return NREngine.continue_ability(state, "runner", flip_effect, card, null)
					).call()) if (NRMemory.available_mu(state) == 0) else NREid.effect_completed(state, side, eid))),
				},
			},
		}
		return {
			"events": [
				{
				"event": "pre-first-turn",
				"req": func(state, side, eid, card, targets): return ((side == "runner") or NRUtil.kw_eq(side, "runner")),
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"flipped": false})),
			},
				maybe_flip,
			],
			"abilities": [
				NRUtil.merge(flip_effect if flip_effect is Dictionary else {}, {"label": "Manually flip identity"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Earth Station: SEA Headquarters", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Limit 1 remote server.\nAs an additional cost to run HQ, the Runner must pay 1[Credits].\n<strong>[Click]:</strong> Flip this identity.\nFlip side:\nLimit 1 remote server.\nAs an additional cost to run a remote server, the Runner must pay 6[Credits].\nWhen the Runner makes a successful run on HQ, flip this identity.",
		"code": "26120",
		"title": "Earth Station: SEA Headquarters",
	}, (func():
		var flip_effect = func(state, side, eid, card, targets):
			return NRUpdate.update_card(state, side, ((func():
			NRSay.system_msg(state, "corp", "flipped [pronoun] identity to Earth Station: SEA Headquarters")
			return NRUtil.merge(card if card is Dictionary else {}, {"flipped": false})
		).call() if NRCardXlate.getk(card, "flipped", null) else NRUtil.merge(card if card is Dictionary else {}, {"flipped": true})))
		return {
			"flags": {
				"server-limit": 1,
			},
			"events": [
				{
				"event": "pre-first-turn",
				"req": func(state, side, eid, card, targets): return ((side == "corp") or NRUtil.kw_eq(side, "corp")),
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"flipped": false})),
			},
				{
				"event": "successful-run",
				"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.getk(card, "flipped", null)),
				"effect": flip_effect,
			},
			],
			"static-abilities": [
				{
				"type": "run-additional-cost",
				"req": func(state, side, eid, card, targets): return (((not (NRCardXlate.getk(card, "flipped", null))) and (("hq" == NRCardXlate.getk((NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), "server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk((NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), "server", null)))) or (NRCardXlate.getk(card, "flipped", null) and NRUtil.in_coll(keys(NRBoard.get_remote_names(state)), NRCardXlate.getk((NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), "server", null)))),
				"value": func(state, side, eid, card, targets):
					return [NRPayment.to_c("credit", (6 if NRCardXlate.getk(card, "flipped", null) else 1))],
			},
			],
			"async": true,
			"enforce-conditions": {
				"req": func(state, side, eid, card, targets): return (1 < NRUtil.as_array(NRBoard.get_remote_names(state)).size()),
				"prompt": "Choose a server to be saved from the rules apocalypse",
				"choices": func(state, side, eid, card, targets):
					return NRBoard.get_remote_names(state),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var to_be_trashed = NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return NRUtil.in_coll(["Archives", "R&D", "HQ", NRCardXlate.first_target(targets)], NRServers.zone_to_name((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)))).call(_x)))
					return (func():
						NRSay.system_msg(state, side, (str("chooses ") + str(NRCardXlate.first_target(targets)) + str(" to be saved from the rules apocalypse and trashes ") + str(NRUtil.quantify(NRUtil.as_array(to_be_trashed).size(), "card"))))
						return NRMoving.trash_cards(state, side, eid, to_be_trashed, {
							"unpreventable": true,
							"game-trash": true,
						})
					).call()
				).call(),
			},
			"abilities": [
				{
				"action": true,
				"label": "Flip identity to Earth Station: Ascending to Orbit",
				"req": func(state, side, eid, card, targets): return (not (NRCardXlate.getk(card, "flipped", null))),
				"cost": [NRPayment.to_c("click", 1)],
				"msg": "flip [their] identity to Earth Station: Ascending to Orbit",
				"effect": flip_effect,
			},
				{
				"label": "Manually flip identity to Earth Station: SEA Headquarters",
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(card, "flipped", null),
				"effect": flip_effect,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Editorial Division: Ad Nihilum", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn you take bad publicity, you may search R&D for 1 non-agenda <strong>black ops</strong>, <strong>gray ops</strong>, or <strong>liability</strong> card and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that card to HQ.",
		"code": "36046",
		"title": "Editorial Division: Ad Nihilum",
	}, {
		"events": [
			{
			"event": "corp-gain-bad-publicity",
			"optional": {
				"req": func(state, side, eid, card, targets): return (func():
					var valid_ctx_p = func(_p): return (NRCardXlate.getk(ctx, "amount", null) > 0)
					return (valid_ctx_p(targets) and NREvents.first_event(state, side, "corp-gain-bad-publicity", valid_ctx_p))
				).call(),
				"prompt": "Search for a card?",
				"waiting-prompt": true,
				"yes-ability": {
					"prompt": "Choose a card",
					"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to HQ from R&D"),
					"choices": func(state, side, eid, card, targets):
						return NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).filter(func(_x): return not NRCard.agenda.call(_x))).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_any_subtype(_pct, ["Illicit", "Black Ops", "Gray Ops", "Liability"])),
					"cancel": NRShuffling.shuffle_deck,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						reveal_and_queue_event(state, side, NRCardXlate.first_target(targets))
						NRShuffling.shuffle_zone(state, side, "deck")
						NRMoving.move(state, side, NRCardXlate.first_target(targets), "hand")
						return NREngine.checkpoint(state, side, eid),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Edward Kim: Humanity's Hammer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Trash the first operation you access each turn at no cost.",
		"code": "07028",
		"title": "Edward Kim: Humanity's Hammer",
	}, {
		"events": [
			{
			"event": "access",
			"req": func(state, side, eid, card, targets): return (NRCard.operation(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)) and NREvents.first_event(state, side, "access", func(_pct, _pct2=null, _pct3=null): return NRCard.operation(NRCardXlate.getk(NRUtil.first_of(_pct), "accessed-card", null)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (NREid.effect_completed(state, side, eid) if NRCard.in_discard(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)) else NREngine.continue_ability(state, side, (func():
				var c = NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)
				return {
					"prompt": (str("You accessed") + str(NRCardXlate.getk(c, "title", null))),
					"choices": ["[Edward Kim] Trash"],
					"async": true,
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(c, "title", null)),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, c, null),
				}
			).call(), card, null)),
		},
		],
	}))

	NRCardDefs.defcard("Ele \"Smoke\" Scovak: Cynosure of the Net", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod - Stealth",
		"subtypes": ["G-mod", "Stealth"],
		"text": "1[recurring-credit]\nUse this credit to pay for using <strong>icebreakers</strong>.",
		"code": "11066",
		"title": "Ele \"Smoke\" Scovak: Cynosure of the Net",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Epiphany Analytica: Nations Undivided", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn the Runner steals or trashes a Corp card, place 1 power counter on this identity.\n[Click], <strong>hosted power counter:</strong> Look at the top 3 cards of R&D. You may install 1 of those cards.",
		"code": "34048",
		"title": "Epiphany Analytica: Nations Undivided",
	}, (func():
		var valid_trash = func(target): return NRCard.corp(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null))
		var ability = {
			"once": "per-turn",
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "agenda-stolen"}),
			],
			"abilities": [
				{
				"action": true,
				"label": "Look at the top 3 cards of R&D",
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
				},
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 1)],
				"msg": "look at the top 3 cards of R&D",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var top = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))
					return NREid.wait_for(state, eid, func(ne):
						scry(state, side, ne, card, side, 3)
					, func(async_result):
						NREngine.continue_ability(state, "corp", {
						"prompt": "Choose a card to install",
						"waiting-prompt": true,
						"not-distinct": true,
						"choices": NRUtil.as_array(top).filter(func(_pct, _pct2=null, _pct3=null): return corp_installable_type_p(_pct)),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRInstalling.corp_install(state, side, eid, NRCardXlate.first_target(targets), null, {
							"msg-keys": {
								"install-source": card,
								"origin-index": NRUtil.first_of(keep_indexed(func(_pct, _pct2=null, _pct3=null): return (_pct if NRUtil.same_card(NRCardXlate.first_target(targets), _pct2) else null), top)),
								"display-origin": true,
							},
						}),
					}, card, null))
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Esâ Afontov: Eco-Insurrectionist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "The first time each turn you suffer core damage, you may draw 1 card and sabotage 2. <em>(The Corp trashes 2 cards of their choice from HQ and/or the top of R&D.)</em>",
		"code": "33001",
		"title": "Esâ Afontov: Eco-Insurrectionist",
	}, (func():
		return {
			"events": [
				{
				"event": "damage",
				"optional": {
					"req": func(state, side, eid, card, targets): return (check_brain(targets) and NREvents.first_event(state, "runner", "damage", check_brain)),
					"prompt": "Draw 1 card and sabotage 2?",
					"autoresolve": NROptional.get_autoresolve("auto-fire"),
					"yes-ability": {
						"async": true,
						"msg": "draw 1 card and sabotage 2",
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRDrawing.draw(state, side, ne, 1, {
							"suppress-checkpoint": true,
						})
						, func(async_result):
							NREngine.continue_ability(state, side, NRSabotage.sabotage(2), card, null)),
					},
				},
			},
			],
			"abilities": [
				NROptional.set_autoresolve("auto-fire", "Esâ Afontov: Eco-Insurrectionist drawing cards"),
			],
		}
	).call()))

	NRCardDefs.defcard("Exile: Streethawk", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Whenever you install a program from your heap, draw 1 card.",
		"code": "03030",
		"title": "Exile: Streethawk",
	}, {
		"flags": {
			"runner-install-draw": true,
		},
		"events": [
			{
			"event": "runner-install",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "previous-zone", null)), func(_x): return NRUtil.in_coll(["discard"], _x)) != null)),
			"msg": "draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Freedom Khumalo: Crypto-Anarchist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "Access, once per turn → <strong>Any X virus counters:</strong> Trash the non-agenda card you are accessing. X must be equal to that card's rez or play cost.",
		"code": "21081",
		"title": "Freedom Khumalo: Crypto-Anarchist",
	}, {
		"interactions": {
			"access-ability": {
				"async": true,
				"trash?": true,
				"once": "per-turn",
				"label": "Trash card",
				"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and (not (NRCard.agenda(NRCardXlate.first_target(targets)))) and (not (NRCard.in_discard(NRCardXlate.first_target(targets)))) and (NRCostFns.play_cost(state, side, NRCardXlate.first_target(targets)) <= NRVirus.number_of_runner_virus_counters(state))),
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var accessed_card = NRCardXlate.first_target(targets)
					var play_or_rez = NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null)
					return (NREngine.continue_ability(state, side, {
						"async": true,
						"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(accessed_card, "title", null)) + str(" at no cost"),
						"effect": func(state, side, eid, card, targets):
							return NRMoving.trash(state, side, eid, NRUtil.merge(accessed_card if accessed_card is Dictionary else {}, {"seen": true}), {
							"accessed": true,
						}),
					}, card, null) if (play_or_rez == 0) else NREid.wait_for(state, eid, func(ne):
						NREngine.resolve_ability(state, side, ne, pick_virus_counters_to_spend(play_or_rez), card, null)
					, func(async_result):
						(func():
						var msg = NRCardXlate.getk(async_result, "msg", null)
						return (func():
						NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to") + str(" trash ") + str(NRCardXlate.getk(accessed_card, "title", null)) + str(" at no cost, spending ") + str(msg)))
						return NRMoving.trash(state, side, eid, NRUtil.merge(accessed_card if accessed_card is Dictionary else {}, {"seen": true}), {
							"accessed": true,
						})
					).call() if msg != null else (func():
						state.dissoc_in(["per-turn", NRCardXlate.getk(card, "cid", null)])
						return access_non_agenda(state, side, eid, accessed_card, "skip-trigger-event", true)
					).call()
					).call()))
				).call(),
			},
		},
	}))

	NRCardDefs.defcard("Fringe Applications: Tomorrow, Today", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Draft format only.\nIf you have more [weyland-consortium] cards rezzed than any other faction, when the Runner's turn begins, place an advancement token on a piece of ice.",
		"code": "00013",
		"title": "Fringe Applications: Tomorrow, Today",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"effect": draft_points_target,
		},
			{
			"event": "runner-turn-begins",
			"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and has_most_faction_p(state, "corp", "Weyland Consortium")),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.ice)).is_empty()),
			},
			"prompt": "Choose a piece of ice to place 1 advancement counter on",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct)),
			},
			"msg": func(state, side, eid, card, targets): return str("place 1 advancement counter on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_prop(state, "corp", eid, NRCardXlate.first_target(targets), "advance-counter", 1, {
				"placed": true,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Gabriel Santiago: Consummate Professional", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "The first time you make a successful run on HQ each turn, gain 2[Credits].",
		"code": "25020",
		"title": "Gabriel Santiago: Consummate Professional",
	}, {
		"events": [
			{
			"event": "successful-run",
			"automatic": "gain-credits",
			"silent": true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "hq")),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("Gagarin Deep Space: Expanding the Horizon", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "As an additional cost to access a card in the root of a remote server, the Runner must pay 1[Credits].",
		"code": "07002",
		"title": "Gagarin Deep Space: Expanding the Horizon",
	}, {
		"events": [
			{
			"event": "pre-access-card",
			"req": func(state, side, eid, card, targets): return NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))).size() > 1 else null)),
			"effect": func(state, side, eid, card, targets):
				return access_cost_bonus(state, side, [NRPayment.to_c("credit", 1)]),
			"msg": "make the Runner spend 1 [Credits] to access",
		},
		],
	}))


static func _register_2() -> void:
	NRCardDefs.defcard("GameNET: Where Dreams are Real", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 17,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever a Corp card ability causes the Runner to spend or lose at least 1[Credits] during a run, gain 1[Credits].",
		"code": "26113",
		"title": "GameNET: Where Dreams are Real",
	}, (func():
		var gamenet_ability = {
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "run", null) and (("Corp" == NRCardXlate.getk(NRCardXlate.getk(eid, "source", null), "side", null)) or NRUtil.kw_eq("Corp", NRCardXlate.getk(NRCardXlate.getk(eid, "source", null), "side", null))) and ((not (NRUtil.in_coll(["runner-trash-corp-cards", "runner-steal"], NRCardXlate.getk(eid, "source-type", null)))) or (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(eid, "additional-costs", null)), func(cost): return (NRUtil.in_coll(["credit", "x-credit"], NRCardXlate.getk(cost, "cost/type", null)) and (("Corp" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.getk(cost, "cost/args", null), "source", null), "side", null)) or NRUtil.kw_eq("Corp", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.getk(cost, "cost/args", null), "source", null), "side", null))))) != null))),
			"async": true,
			"msg": "gain 1 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 1),
		}
		return {
			"events": [
				NRUtil.merge(gamenet_ability if gamenet_ability is Dictionary else {}, {"event": "runner-credit-loss"}),
				NRUtil.merge(gamenet_ability if gamenet_ability is Dictionary else {}, {"event": "runner-spent-credits"}),
			],
		}
	).call()))

	NRCardDefs.defcard("GRNDL: Power Unleashed", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 10,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division - Liability",
		"subtypes": ["Division", "Liability"],
		"text": "You start the game with 10[Credits] and 1 bad publicity.",
		"code": "04097",
		"title": "GRNDL: Power Unleashed",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"req": func(state, side, eid, card, targets): return (("corp" == side) or NRUtil.kw_eq("corp", side)),
			"async": true,
			"msg": "start the game with 10 [Credits] and 1 bad publicity",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, "corp", ne, 5)
			, func(async_result):
				(NRBadPublicity.gain_bad_publicity(state, "corp", eid, 1) if (NRUtil.count_bad_pub(state) == 0) else NREid.effect_completed(state, side, eid))),
		},
		],
	}))

	NRCardDefs.defcard("Haarpsichord Studios: Entertainment Unleashed", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The Runner cannot steal more than one agenda each turn.",
		"code": "08092",
		"title": "Haarpsichord Studios: Entertainment Unleashed",
	}, {
		"static-abilities": [
			{
			"type": "cannot-steal",
			"value": func(state, side, eid, card, targets):
				return (NREvents.event_count(state, side, "agenda-stolen") > 0),
		},
		],
		"events": [
			{
			"event": "access",
			"req": func(state, side, eid, card, targets): return (NRCard.agenda(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)) and (NREvents.event_count(state, side, "agenda-stolen") > 0)),
			"effect": func(state, side, eid, card, targets):
				return NRToasts.toast(state, "runner", "Cannot steal due to Haarpsichord Studios.", "warning"),
		},
		],
	}))

	NRCardDefs.defcard("Haas-Bioroid: Architects of Tomorrow", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 12,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "The first time each turn the Runner passes a rezzed piece of <strong>bioroid</strong> ice, you may rez 1 <strong>bioroid</strong> card, paying 4[Credits] less.",
		"code": "31040",
		"title": "Haas-Bioroid: Architects of Tomorrow",
	}, {
		"events": [
			{
			"event": "pass-ice",
			"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Bioroid") and NREvents.first_event(state, "runner", "pass-ice", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return (NRCard.rezzed(ice) and NRCard.installed(ice) and NRCard.has_subtype(ice, "Bioroid"))
			).call())),
			"waiting-prompt": true,
			"prompt": "Choose a Bioroid to rez",
			"player": "corp",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.first_target(targets), "Bioroid") and (not (NRCard.rezzed(NRCardXlate.first_target(targets)))) and can_pay_to_rez_p(state, side, eid, NRCardXlate.first_target(targets), {
					"cost-bonus": -4,
				})),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.rez(state, side, eid, NRCardXlate.first_target(targets), {
				"cost-bonus": -4,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Haas-Bioroid: Engineering the Future", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "The first time you install a card each turn, gain 1[Credits].",
		"code": "01054",
		"title": "Haas-Bioroid: Engineering the Future",
	}, {
		"events": [
			{
			"event": "corp-install",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, state.getv("corp", {}), "corp-install"),
			"automatic": "gain-credits",
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Haas-Bioroid: Precision Design", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "You get +1 maximum hand size.\nWhenever you score an agenda, you may add 1 card from Archives to HQ.",
		"code": "30035",
		"title": "Haas-Bioroid: Precision Design",
	}, {
		"static-abilities": [corp_hand_size_(1)],
		"events": [
			{
			"event": "agenda-scored",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Add 1 card from Archives to HQ?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": NRDefHelpers.gain_credits_ability(),
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Haas-Bioroid: Precision Design")],
	}))

	NRCardDefs.defcard("Haas-Bioroid: Stronger Together", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "All <strong>bioroid</strong> ice has +1 strength.",
		"code": "25066",
		"title": "Haas-Bioroid: Stronger Together",
	}, {
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.first_target(targets), "Bioroid"),
			"value": 1,
		},
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRIce.update_all_ice(state, side),
		"effect": func(state, side, eid, card, targets):
			return NRIce.update_all_ice(state, side),
	}))

	NRCardDefs.defcard("Harishchandra Ent.: Where You're the Star", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 17,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "While the Runner is tagged, they play with the grip revealed.",
		"code": "10107",
		"title": "Harishchandra Ent.: Where You're the Star",
	}, (func():
		return {
			"events": [
				{
				"event": "post-runner-draw",
				"req": func(state, side, eid, card, targets): return NRUtil.is_tagged(state),
				"msg": func(state, side, eid, card, targets): return str("see that the Runner drew: ") + str(NRUtil.enumerate_cards(runner_currently_drawing)),
			},
				{
				"event": "tags-changed",
				"effect": func(state, side, eid, card, targets):
					return (((func():
					NRSay.system_msg(state, "corp", (str("uses ") + str(NRCard.get_title(card)) + str(" make the Runner play with [runner-pronoun] grip revealed")))
					NRSay.system_msg(state, "corp", (str("uses ") + str(NRCard.get_title(card)) + str(" to see that the Runner currently has ") + str(format_grip(state.getv("runner", {}))) + str(" in [runner-pronoun] grip")))
					return reveal_hand(state, "runner")
				).call() if (not (state.get_in(["runner", "openhand"], null))) else null) if NRUtil.is_tagged(state) else ((func():
					NRSay.system_msg(state, "corp", (str("uses ") + str(NRCard.get_title(card)) + str(" stop making the Runner play with [runner-pronoun] grip revealed")))
					NRSay.system_msg(state, "corp", (str("uses ") + str(NRCard.get_title(card)) + str(" to note that the Runner had ") + str(format_grip(state.getv("runner", {}))) + str(" in [runner-pronoun] grip before it was concealed")))
					return conceal_hand(state, "runner")
				).call() if state.get_in(["runner", "openhand"], null) else null)),
			},
			],
			"effect": func(state, side, eid, card, targets):
				return (reveal_hand(state, "runner") if NRUtil.is_tagged(state) else null),
			"leave-play": func(state, side, eid, card, targets):
				return (conceal_hand(state, "runner") if NRUtil.is_tagged(state) else null),
		}
	).call()))

	NRCardDefs.defcard("Harmony Medtech: Biomedical Pioneer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 12,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Each player needs 1 fewer agenda point to win the game.",
		"code": "05001",
		"title": "Harmony Medtech: Biomedical Pioneer",
	}, {
		"static-abilities": [{
			"type": "agenda-point-req",
			"value": -1,
		}],
	}))

	NRCardDefs.defcard("Hayley Kaplan: Universal Scholar", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "The first time you install a card each turn, you may install another card of the same type from your grip (paying its install cost).",
		"code": "08025",
		"title": "Hayley Kaplan: Universal Scholar",
	}, {
		"events": [
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, side, "runner-install") and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "facedown", null)))),
			"interactive": func(state, side, eid, card, targets):
				return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-install-draw")) != null),
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var itarget = NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)
				var card_type = NRCardXlate.getk(itarget, "type", null)
				return ({
					"optional": {
						"prompt": (str("Install another ") + str(card_type) + str(" from the grip?")),
						"yes-ability": {
							"prompt": (str("Choose a ") + str(card_type) + str(" to install")),
							"choices": {
								"req": func(state, side, eid, card, targets): return (NRCard.is_type(NRCardXlate.first_target(targets), card_type) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets))),
							},
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
								"msg-keys": {
									"install-source": card,
									"display-origin": true,
								},
							}),
						},
					},
				} if (NRUtil.find_first(NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRCard.is_type(_pct, NRCardXlate.getk(itarget, "type", null))) != null) else {
					"prompt": (str("You have no ") + str(card_type) + str(" to install")),
					"choices": ["Carry on!"],
					"prompt-type": "bogus",
				})
			).call(), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Hiram \"0mission\" Svensson: Shadow of the Past", NRCardXlate.merge_cdef({
		"title": "Hiram \"0mission\" Svensson: Shadow of the Past",
	}, (func():
		var scry = {
			"change-in-game-state": {
				"silent": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
			},
			"msg": {
				"public": "look at the top card of R&D",
				"runner": func(state, side, eid, card, targets): return str("look at ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null)) + str(" on top of R&D"),
			},
			"interactive": func(state, side, eid, card, targets):
				return true,
		}
		return {
			"events": [
				NRUtil.merge(scry if scry is Dictionary else {}, {"event": "runner-install"}),
				NRUtil.merge(scry if scry is Dictionary else {}, {"event": "runner-trash"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Hoshiko Shiro: Untold Protagonist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "When your turn ends, if you accessed a card this turn, gain 2[Credits] and flip this identity.\nFlip side:\nWhen your turn begins, draw 1 card and lose 1[Credits].\nWhen your turn ends, if you did not access any cards this turn, flip this identity.",
		"code": "26066",
		"title": "Hoshiko Shiro: Untold Protagonist",
	}, (func():
		var flip_effect = func(state, side, eid, card, targets):
			NRUpdate.update_card(state, side, (NRUtil.merge(card if card is Dictionary else {}, {"flipped": false}) if NRCardXlate.getk(card, "flipped", null) else NRUtil.merge(card if card is Dictionary else {}, {"flipped": true})))
			return update_link(state)
		return {
			"static-abilities": [
				NRCardXlate.link_plus(func(state, side, eid, card, targets):
				return NRCardXlate.getk(card, "flipped", null), 1),
				{
				"type": "gain-subtype",
				"req": func(state, side, eid, card, targets): return (NRUtil.same_card(card, NRCardXlate.first_target(targets)) and NRCardXlate.getk(card, "flipped", null)),
				"value": "Digital",
			},
				{
				"type": "lose-subtype",
				"req": func(state, side, eid, card, targets): return (NRUtil.same_card(card, NRCardXlate.first_target(targets)) and NRCardXlate.getk(card, "flipped", null)),
				"value": "Natural",
			},
			],
			"events": [
				{
				"event": "pre-first-turn",
				"req": func(state, side, eid, card, targets): return ((side == "runner") or NRUtil.kw_eq(side, "runner")),
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"flipped": false})),
			},
				{
				"event": "runner-turn-ends",
				"automatic": "gain-credits",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return ((func():
					NRSay.system_msg(state, "runner", "flips [their] identity to Hoshiko Shiro: Untold Protagonist")
					return NREngine.continue_ability(state, "runner", {
						"effect": flip_effect,
					}, card, null)
				).call() if (NRCardXlate.getk(card, "flipped", null) and (not (NRCardXlate.getk(state.get_in(["runner", "register"], {}), "accessed-cards", null)))) else (NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, "runner", ne, 2)
				, func(async_result):
					(func():
					NRSay.system_msg(state, "runner", "gains 2 [Credits] and flips [their] identity to Hoshiko Shiro: Mahou Shoujo")
					return NREngine.continue_ability(state, "runner", {
						"effect": flip_effect,
					}, card, null)
				).call()) if ((not (NRCardXlate.getk(card, "flipped", null))) and NRCardXlate.getk(state.get_in(["runner", "register"], {}), "accessed-cards", null)) else NREid.effect_completed(state, side, eid))),
			},
				{
				"event": "runner-turn-begins",
				"automatic": "lose-credits",
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(card, "flipped", null),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, "runner", ne, 1)
				, func(async_result):
					NREid.wait_for(state, eid, func(ne):
					NRGaining.lose_credits(state, "runner", ne, NREid.make_eid(state, eid), 1)
				, func(async_result):
					(func():
					NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to draw 1 card and lose 1 [Credits]")))
					return NREid.effect_completed(state, side, eid)
				).call())),
			},
			],
			"abilities": [
				{
				"label": "flip identity",
				"msg": "flip [their] identity manually",
				"effect": flip_effect,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Hyoubu Institute: Absolute Clarity", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn you reveal a card, gain 1[Credits].\n<strong>[Click]:</strong> Reveal 1 card from the grip at random or the top card of the stack.",
		"code": "26039",
		"title": "Hyoubu Institute: Absolute Clarity",
	}, {
		"events": [
			{
			"event": "corp-reveal",
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p([NRCardXlate.ctx(targets)]) and NREvents.first_event(state, side, "corp-reveal", valid_ctx_p))
			).call(),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Reveal the top card of the Stack",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var revealed_card = NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null))
				return (func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to reveal ") + str(NRCardXlate.getk(revealed_card, "title", null)) + str(" from the top of the Stack")))
				return NRRevealing.reveal(state, side, eid, revealed_card)
			).call() if revealed_card != null else NREid.effect_completed(state, side, eid)
			).call(),
		},
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Reveal a random card from the Grip",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var revealed_card = NRUtil.first_of(shuffle(NRCardXlate.getk(state.getv("runner", {}), "hand", null)))
				return (func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to reveal ") + str(NRCardXlate.getk(revealed_card, "title", null)) + str(" from the Grip")))
				return NRRevealing.reveal(state, side, eid, revealed_card)
			).call() if revealed_card != null else NREid.effect_completed(state, side, eid)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Iain Stirling: Retired Spook", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 1,
		"influencelimit": 10,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "When your turn begins, gain 2[Credits] if the Corp has more scored agenda points than you.",
		"code": "05028",
		"title": "Iain Stirling: Retired Spook",
	}, (func():
		var ability = {
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state.getv("corp", {}), "agenda-point", null) > NRCardXlate.getk(state.getv("runner", {}), "agenda-point", null)),
			"once": "per-turn",
			"automatic": "gain-credits",
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
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

	NRCardDefs.defcard("Industrial Genomics: Growing Solutions", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The trash cost of each card is increased by 1 for each facedown card in Archives.",
		"code": "06105",
		"title": "Industrial Genomics: Growing Solutions",
	}, {
		"static-abilities": [
			{
			"type": "trash-cost",
			"value": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(func(_x): return not ((func(_x): return bool(NRCardXlate.getk(_x, "seen"))).call(_x)))).size(),
		},
		],
	}))

	NRCardDefs.defcard("Information Dynamics: All You Need To Know", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Draft format only.\nIf you have more [nbn] cards rezzed than any other faction, whenever an agenda is scored or stolen, give the runner 1 tag.",
		"code": "00012",
		"title": "Information Dynamics: All You Need To Know",
	}, {
		"events": (func():
			var inf = {
				"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and has_most_faction_p(state, "corp", "NBN")),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"msg": "give the Runner 1 tag",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRTags.gain_tags(state, "corp", eid, 1),
			}
			return [
				{
				"event": "pre-start-game",
				"effect": draft_points_target,
			},
				NRUtil.merge(inf if inf is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(inf if inf is Dictionary else {}, {"event": "agenda-stolen"}),
			]
		).call(),
	}))

	NRCardDefs.defcard("Issuaq Adaptics: Sustaining Diversity", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever you score an agenda that you did not install or advance this turn, place 1 power counter on this identity.\nFor each hosted power counter, you need 1 less agenda point to win the game.",
		"code": "33104",
		"title": "Issuaq Adaptics: Sustaining Diversity",
	}, {
		"effect": func(state, side, eid, card, targets):
			return NRGaining.lose(state, side, "agenda-point-req", NRCard.get_counters(card, "power")),
		"leave-play": func(state, side, eid, card, targets):
			return NRGaining.gain(state, side, "agenda-point-req", NRCard.get_counters(card, "power")),
		"static-abilities": [
			{
			"type": "agenda-point-req",
			"req": func(state, side, eid, card, targets): return (("corp" == side) or NRUtil.kw_eq("corp", side)),
			"value": func(state, side, eid, card, targets):
				return (-NRCard.get_counters(card, "power")),
		},
		],
		"events": [
			{
			"event": "agenda-scored",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "corp-install")).map(func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), _pct)) is Array and NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "corp-install")).map(func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), _pct)).is_empty() if false else (str(NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "corp-install")).map(func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), _pct))) == "")) and (NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "advance")).map(func(_pct, _pct2=null, _pct3=null): return NRUtil.first_of(_pct))).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(_pct, "card", null))) is Array and NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "advance")).map(func(_pct, _pct2=null, _pct3=null): return NRUtil.first_of(_pct))).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(_pct, "card", null))).is_empty() if false else (str(NRUtil.as_array(NRUtil.as_array(NREvents.turn_events(state, side, "advance")).map(func(_pct, _pct2=null, _pct3=null): return NRUtil.first_of(_pct))).filter(func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(_pct, "card", null)))) == ""))),
			"msg": "put 1 charge counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1),
		},
		],
	}))

	NRCardDefs.defcard("Jamie \"Bzzz\" Micken: Techno Savant", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Draft format only.\nIf you have more [shaper] cards installed than any other faction, when you install a card the first time each turn, draw 1 card.",
		"code": "00009",
		"title": "Jamie \"Bzzz\" Micken: Techno Savant",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"effect": draft_points_target,
		},
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return (has_most_faction_p(state, "runner", "Shaper") and NREvents.first_event(state, side, "runner-install")),
			"msg": "draw 1 card",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Jemison Astronautics: Sacrifice. Audacity. Success.", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "Whenever you forfeit an agenda, place X advancement counters on 1 installed card. X is equal to the agenda point value of the forfeited agenda plus 1.",
		"code": "12016",
		"title": "Jemison Astronautics: Sacrifice. Audacity. Success.",
	}, {
		"events": [
			{
			"event": "corp-forfeit-agenda",
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var p = (NRAgendas.get_agenda_points(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) + 1)
				return {
					"prompt": "Choose a card to place advancement counters on",
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.corp(_pct)),
					},
					"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(p, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_prop(state, "corp", eid, NRCardXlate.first_target(targets), "advance-counter", p, {
						"placed": true,
					}),
				}
			).call(), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Jesminder Sareen: Girl Behind the Curtain", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "[interrupt] → The first time each run you would take 1 or more tags, prevent 1 tag.",
		"code": "10006",
		"title": "Jesminder Sareen: Girl Behind the Curtain",
	}, {
		"static-abilities": [
			{
			"type": "forced-to-avoid-tag",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (NREvents.run_event_count(state, side, "tag-interrupt") == 0)),
			"value": true,
		},
		],
		"events": [
			{
			"event": "tag-interrupt",
			"async": true,
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (NREvents.run_event_count(state, side, "tag-interrupt") <= 1)),
			"msg": "avoid 1 tag",
			"effect": func(state, side, eid, card, targets):
				return prevent_tag(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Jinteki Biotech: Life Imagined", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Before taking your first turn, you may switch this identity with any copy of Jinteki Biotech.\n<strong>[Click][Click][Click]:</strong> Flip this identity.\nSide 1: When you flip this identity, do 2 net damage.\nSide 2: When you flip this identity, shuffle all cards in Archives into R&D.\nSide 3: When you flip this identity, place 4 advancement counters on 1 installed card that you can advance.",
		"code": "08012",
		"title": "Jinteki Biotech: Life Imagined",
	}, {
		"events": [
			{
			"event": "pre-first-turn",
			"req": func(state, side, eid, card, targets): return ((side == "corp") or NRUtil.kw_eq(side, "corp")),
			"prompt": func(state, side, eid, card, targets): return str("Choose a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" to use this game"),
			"choices": ["The Brewery", "The Tank", "The Greenhouse"],
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"biotech-target": NRCardXlate.first_target(targets)}))
				return NRSay.system_msg(state, side, (str("has chosen a copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" for this game"))),
		},
		],
		"abilities": [
			{
			"label": "Check chosen flip identity",
			"effect": func(state, side, eid, card, targets):
				return (NRToasts.toast(state, "corp", "Flip to: The Brewery (Do 2 net damage)", "info") if (NRCardXlate.getk(card, "biotech-target", null) == "The Brewery") else (NRToasts.toast(state, "corp", "Flip to: The Tank (Shuffle Archives into R&D)", "info") if (NRCardXlate.getk(card, "biotech-target", null) == "The Tank") else (NRToasts.toast(state, "corp", "Flip to: The Greenhouse (Place 4 advancement counters on a card)", "info") if (NRCardXlate.getk(card, "biotech-target", null) == "The Greenhouse") else NRToasts.toast(state, "corp", "No flip identity specified", "info")))),
		},
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 3)],
			"req": func(state, side, eid, card, targets): return (not (NRCardXlate.getk(card, "biotech-used", null))),
			"label": "Flip this identity",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var flip = NRCardXlate.getk(card, "biotech-target", null)
				return (func():
					NRUpdate.update_card(state, side, NRUtil.merge(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, {"biotech-used": true}))
					return ((func():
						NRSay.system_msg(state, side, (str("uses ") + str(flip) + str(" to do 2 net damage")))
						NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"code": "brewery"}))
						return NRDamage.damage(state, side, eid, "net", 2, {
							"card": card,
						})
					).call() if (flip == "The Brewery") else ((func():
						NRSay.system_msg(state, side, (str("uses ") + str(flip) + str(" to shuffle Archives into R&D")))
						NRShuffling.shuffle_into_deck(state, side, "discard")
						NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"code": "tank"}))
						return NREid.effect_completed(state, side, eid)
					).call() if (flip == "The Tank") else ((func():
						NRSay.system_msg(state, side, (str("uses ") + str(flip) + str(" to place 4 advancement counters ") + str("on a card that can be advanced")))
						NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"code": "greenhouse"}))
						return NREngine.continue_ability(state, side, {
							"prompt": "Choose a card that can be advanced",
							"choices": {
								"req": func(state, side, eid, card, targets): return NRAgendas.can_be_advanced(state, NRCardXlate.first_target(targets)),
							},
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRProps.add_prop(state, side, eid, NRCardXlate.first_target(targets), "advance-counter", 4, {
								"placed": true,
							}),
						}, card, null)
					).call() if (flip == "The Greenhouse") else (func():
						NRToasts.toast(state, "corp", (str("Unknown Jinteki Biotech: Life Imagined card: ") + str(flip)), "error")
						return NREid.effect_completed(state, side, eid)
					).call())))
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Jinteki: Personal Evolution", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Whenever an agenda is scored or stolen, do 1 net damage.",
		"code": "31050",
		"title": "Jinteki: Personal Evolution",
	}, (func():
		var ability = {
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "do 1 net damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "net", 1, {
				"card": card,
			}),
		}
		return {
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Jinteki: Potential Unleashed", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 12,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Whenever the Runner takes at least 1 net damage, trash the top card of the stack.",
		"code": "11054",
		"title": "Jinteki: Potential Unleashed",
	}, {
		"events": [
			{
			"async": true,
			"event": "damage",
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "damage-type", null) == "net") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "damage-type", null), "net")),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)) + str(" from the top of the stack"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.mill(state, "corp", eid, "runner", 1),
		},
		],
	}))

	NRCardDefs.defcard("Jinteki: Replicating Perfection", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "The Runner cannot run on remote servers. Ignore this ability until the end of the turn whenever the Runner runs on a central server.",
		"code": "25085",
		"title": "Jinteki: Replicating Perfection",
	}, {
		"static-abilities": [
			{
			"type": "cannot-run-on-server",
			"req": func(state, side, eid, card, targets): return NREvents.no_event(state, side, "run", func(_pct, _pct2=null, _pct3=null): return NRServers.is_central(NRCardXlate.getk(NRUtil.first_of(_pct), "server", null))),
			"value": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRBoard.get_remote_names(state)).map(first),
		},
		],
	}))

	NRCardDefs.defcard("Jinteki: Restoring Humanity", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "When your discard phase ends, if there is a facedown card in Archives, gain 1[Credits].",
		"code": "30043",
		"title": "Jinteki: Restoring Humanity",
	}, {
		"events": [
			{
			"event": "corp-turn-ends",
			"automatic": "gain-credits",
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(func(_x): return not ((func(_x): return bool(NRCardXlate.getk(_x, "seen"))).call(_x)))).size() > 0),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Kabonesa Wu: Netspace Thrillseeker", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "[Click]: Search your stack for a non-<strong>virus</strong> program and install it, lowering its install cost by 1[Credits], then shuffle your stack. If that program is still installed when your turn ends, remove it from the game.",
		"code": "21025",
		"title": "Kabonesa Wu: Netspace Thrillseeker",
	}, {
		"abilities": [
			{
			"action": true,
			"label": "Install a non-virus program from the stack, lowering the cost by 1 [Credit]",
			"cost": [NRPayment.to_c("click", 1)],
			"prompt": "Choose a program",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			},
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and (not (NRCard.has_subtype(_pct, "Virus"))) and NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, null, [
				NRPayment.to_c("credit", NRCostFns.install_cost(state, side, _pct, {
				"cost-bonus": -1,
			})),
			]))),
			"async": true,
			"waiting-prompt": true,
			"cancel": NRUtil.merge(fail_to_find_bang if fail_to_find_bang is Dictionary else {}, {"action": true}),
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRShuffling.shuffle_zone(state, side, "deck")
				return NREid.wait_for(state, eid, func(ne):
				NRInstalling.runner_install(state, side, ne, NRCardXlate.first_target(targets), {
				"cost-bonus": -1,
				"msg-keys": {
					"display-origin": true,
					"include-cost-from-eid": eid,
					"install-source": card,
				},
			})
			, func(async_result):
				(func():
				(func():
					var installed_card = async_result
					return NREffects.register_lingering_effect(state, side, card, {
					"type": "icon",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(installed_card, NRCardXlate.first_target(targets)),
					"value": make_icon("WU", card),
					"duration": "post-runner-turn-ends",
				}) if installed_card != null else NREngine.register_events(state, side, card, [
					{
					"event": "runner-turn-ends",
					"interactive": func(state, side, eid, card, targets):
						return NRCard.get_card(state, installed_card),
					"silent": func(state, side, eid, card, targets):
						return (not (NRCard.get_card(state, installed_card))),
					"change-in-game-state": {
						"silent": true,
						"req": func(state, side, eid, card, targets): return NRCard.get_card(state, installed_card),
					},
					"ability-name": (str("Kabonesa Wu (") + str(NRCardXlate.getk(installed_card, "title", null)) + str(")")),
					"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRCardXlate.getk(installed_card, "title", null)) + str(" from the game"),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.move(state, side, NRCard.get_card(state, installed_card), "rfg"),
				},
				])
				).call()
				return NREid.effect_completed(state, side, eid)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Kate \"Mac\" McCaffrey: Digital Tinker", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Lower the install cost of the first program or piece of hardware you install each turn by 1.",
		"code": "01033",
		"title": "Kate \"Mac\" McCaffrey: Digital Tinker",
	}, (func():
		var _b0 = not_triggered_p([state], NREvents.no_event(state, "runner", "runner-install", func(_pct, _pct2=null, _pct3=null): return kate_type_p(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null))))
		return {
			"static-abilities": [
				{
				"type": "install-cost",
				"req": func(state, side, eid, card, targets): return (kate_type_p(NRCardXlate.first_target(targets)) and not_triggered_p(state)),
				"value": -1,
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Ken \"Express\" Tenma: Disappeared Clone", NRCardXlate.merge_cdef({
		"title": "Ken \"Express\" Tenma: Disappeared Clone",
	}, {
		"events": [
			{
			"event": "play-event",
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Run") and NREvents.first_event(state, "runner", "play-event", func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null), "Run"))),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Khan: Savvy Skiptracer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 12,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "The first time you pass a piece of ice each turn, you may install an <strong>icebreaker</strong> from your hand, lowering the install cost by 1.",
		"code": "11027",
		"title": "Khan: Savvy Skiptracer",
	}, {
		"events": [
			{
			"event": "pass-ice",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, "runner", "pass-ice"),
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, ({
				"prompt": "Choose an icebreaker to install",
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker") and NRPayment.can_pay(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), null, [
						NRPayment.to_c("credit", NRCostFns.install_cost(state, side, NRCardXlate.first_target(targets), {
						"cost-bonus": -1,
					})),
					])),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
					"cost-bonus": -1,
					"msg-keys": {
						"display-origin": true,
						"install-source": card,
					},
				}),
			} if (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)), func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and NRPayment.can_pay(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, null, [
				NRPayment.to_c("credit", NRCostFns.install_cost(state, side, _pct, {
				"cost-bonus": -1,
			})),
			]))) != null) else null), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Laramy Fisk: Savvy Investor", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "The first time you make a successful run on a central server each turn, you may force the Corp to draw 1 card.",
		"code": "08104",
		"title": "Laramy Fisk: Savvy Investor",
	}, {
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"async": true,
			"interactive": NROptional.get_autoresolve("auto-fire", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-fire", never_p),
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) and NREvents.first_event(state, side, "successful-run", func(targets): return (func():
					var context = NRUtil.first_of(targets)
					return NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))
				).call())),
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"prompt": "Force the Corp to draw 1 card?",
				"yes-ability": {
					"msg": "force the Corp to draw 1 card",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, "corp", eid, 1),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Laramy Fisk: Savvy Investor")],
	}))

	NRCardDefs.defcard("Lat: Ethical Freelancer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "When your discard phase ends, if you have the same number of cards in your grip as the Corp has in HQ, you may draw 1 card.",
		"code": "26019",
		"title": "Lat: Ethical Freelancer",
	}, {
		"events": [
			{
			"event": "runner-turn-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() == NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()) or NRUtil.kw_eq(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size(), NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size())),
					"autoresolve": NROptional.get_autoresolve("auto-fire"),
					"waiting-prompt": true,
					"prompt": "Draw 1 card?",
					"yes-ability": {
						"async": true,
						"msg": "draw 1 card",
						"effect": func(state, side, eid, card, targets):
							return NRDrawing.draw(state, "runner", eid, 1),
					},
					"no-ability": {
						"effect": func(state, side, eid, card, targets):
							return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
					},
				},
			}, card, null),
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Lat: Ethical Freelancer")],
	}))

	NRCardDefs.defcard("Leela Patel: Trained Pragmatist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Whenever an agenda is scored or stolen, add 1 unrezzed card to HQ.",
		"code": "25021",
		"title": "Leela Patel: Trained Pragmatist",
	}, (func():
		var leela = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"prompt": "Choose an unrezzed card to return to HQ",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.faceup(_pct))) and NRCard.installed(_pct) and NRCard.corp(_pct)),
				"all": true,
			},
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.faceup(_pct))) and NRCard.installed(_pct))) != null),
			},
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" to HQ"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "hand"),
		}
		return {
			"events": [
				NRUtil.merge(leela if leela is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(leela if leela is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("LEO Construction: Labor Solutions", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Once per turn → <strong>Trash 1 rezzed bioroid card in the root of or protecting the attacked server:</strong> End the run.",
		"code": "35035",
		"title": "LEO Construction: Labor Solutions",
	}, {
		"abilities": [
			{
			"cost": [NRPayment.to_c("bioroid-run-server", 1)],
			"once": "per-turn",
			"label": "end the run",
			"msg": "end the run",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.end_run(state, side, eid, card),
		},
		],
	}))

	NRCardDefs.defcard("Liza Talking Thunder: Prominent Legislator", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 50,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "The first time you make a successful run on a central server each turn, draw 2 cards and take 1 tag.",
		"code": "22008",
		"title": "Liza Talking Thunder: Prominent Legislator",
	}, {
		"events": [
			{
			"event": "successful-run",
			"automatic": "draw-cards",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"msg": "draw 2 cards and take 1 tag",
			"req": func(state, side, eid, card, targets): return (NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) and NREvents.first_event(state, side, "successful-run", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))
			).call())),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "runner", ne, 2, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRTags.gain_tags(state, "runner", eid, 1)),
		},
		],
	}))

	NRCardDefs.defcard("Los: Data Hijacker", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "The first time the Corp rezzes a piece of ice each turn, gain 2[Credits].",
		"code": "12025",
		"title": "Los: Data Hijacker",
	}, {
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and NREvents.first_event(state, side, "rez", func(_pct, _pct2=null, _pct3=null): return NRCard.ice(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("Magdalene Keino-Chemutai: Cryptarchitect", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "Whenever you discard cards to reach your maximum hand size, you may install 1 program or piece of hardware from among those cards.",
		"code": "35024",
		"title": "Magdalene Keino-Chemutai: Cryptarchitect",
	}, {
		"events": [
			{
			"event": "runner-discard-to-hand-size",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var installable = filterv(func(c): return ((NRCard.hardware(c) or NRCard.program(c)) and NRInstalling.runner_can_pay_and_install(state, "runner", eid, c, {
					"no-toast": true,
				})), NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null))
				return (NREngine.continue_ability(state, side, {
					"prompt": "Install a discarded program or piece of hardware?",
					"choices": func(state, side, eid, card, targets):
						return installable,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}),
				}, card, null) if (not NRUtil.as_array(installable).is_empty()) else NREid.effect_completed(state, side, eid))
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("MaxX: Maximum Punk Rock", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "When your turn begins, trash the top 2 cards of your stack. Draw 1 card.",
		"code": "07029",
		"title": "MaxX: Maximum Punk Rock",
	}, (func():
		var ability = {
			"msg": func(state, side, eid, card, targets): return str((func():
				var deck = NRCardXlate.getk(state.getv("runner", {}), "deck", null)
				return ((str("trash ") + str(NRUtil.enumerate_cards(NRUtil.take_n(NRUtil.as_array(deck), int(2)))) + str(" from the stack and draw 1 card")) if (NRUtil.as_array(deck).size() > 0) else "trash the top 2 cards from the stack and draw 1 card - but the stack is empty")
			).call()),
			"label": "trash and draw cards",
			"once": "per-turn",
			"automatic": "post-draw-cards",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.mill(state, "runner", ne, "runner", 2)
			, func(async_result):
				NRDrawing.draw(state, "runner", eid, 1)),
		}
		return {
			"flags": {
				"runner-turn-draw": true,
				"runner-phase-12": func(state, side, eid, card, targets):
					return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-turn-draw", true)) != null)),
			},
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
			"abilities": [ability],
		}
	).call()))

	NRCardDefs.defcard("Méliès U: Only the Brightest", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "When your discard phase ends, secretly set your identity to any copy of Méliès U: Only the Brightest.\nWhen the Runner makes a successful run on a central server, flip this identity.\nWhen the Runner’s action phase ends, gain 1[Credits].\nSide 1: When you flip this identity to this side during a run on HQ, look at the top card of R&D. You may trash that card. If you do, add 1 card from Archives to HQ.\nWhen the Runner’s discard phase ends, flip this identity.\nSide 2: When you flip this identity to this side during a run on R&D, look at the top card of R&D. You may trash that card. If you do, add 1 card from Archives to HQ.\nWhen the Runner’s discard phase ends, flip this identity.\nSide 3: When you flip this identity to this side during a run on Archives, look at the top card of R&D. You may trash that card. If you do, add 1 card from Archives to HQ.\nWhen the Runner’s discard phase ends, flip this identity.",
		"code": "36036",
		"title": "Méliès U: Only the Brightest",
	}, (func():
		return {
			"abilities": [
				{
				"label": "Check chosen flip identity",
				"effect": func(state, side, eid, card, targets):
					return (NRToasts.toast(state, "corp", "Tenure Floors (HQ)", "info") if (NRCardXlate.getk(card, "melies-target", null) == "HQ") else (NRToasts.toast(state, "corp", "Subsurface Labs (R&D)", "info") if (NRCardXlate.getk(card, "melies-target", null) == "R&D") else (NRToasts.toast(state, "corp", "Disposal Grounds (Archives)", "info") if (NRCardXlate.getk(card, "melies-target", null) == "Archives") else NRToasts.toast(state, "corp", "No flip identity specified", "info")))),
			},
			],
			"events": [
				{
				"event": "pre-first-turn",
				"req": func(state, side, eid, card, targets): return ((side == "corp") or NRUtil.kw_eq(side, "corp")),
				"effect": func(state, side, eid, card, targets):
					NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"face": "front"}))
					return NRSay.system_msg(state, side, "reveals that the three hidden faces of Méliès U: Only the Brightest are: Tenure Floors: Méliès U, Subsurface Labs: Méliès U, and Disposal Grounds: Méliès U"),
			},
				{
				"event": "corp-turn-ends",
				"prompt": "Choose a server",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"waiting-prompt": true,
				"choices": ["HQ", "R&D", "Archives"],
				"msg": {
					"public": "secretly choose a server",
					"corp": func(state, side, eid, card, targets): return str("secretly choose ") + str(server_to_face(NRCardXlate.first_target(targets))) + str(" (") + str(NRCardXlate.first_target(targets)) + str(")"),
				},
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"melies-target": NRCardXlate.first_target(targets)})),
			},
				{
				"event": "runner-turn-ends",
				"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(card, "face", null) == "front") or NRUtil.kw_eq(NRCardXlate.getk(card, "face", null), "front")),
				"msg": "gain 1 [Credit]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_credits(state, side, eid, 1),
			},
				{
				"event": "corp-turn-begins",
				"silent": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"face": "front"})),
			},
				{
				"event": "successful-run",
				"req": func(state, side, eid, card, targets): return (((NRCardXlate.getk(card, "face", null) == "front") or NRUtil.kw_eq(NRCardXlate.getk(card, "face", null), "front")) and NRServers.is_central(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
				"msg": func(state, side, eid, card, targets): return str("flip to ") + str(server_to_face(NRCardXlate.getk(card, "melies-target", null))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var _destructured_0 = (["hq", "tenure"] if (NRCardXlate.getk(card, "melies-target", null) == "HQ") else (["rd", "subsurface"] if (NRCardXlate.getk(card, "melies-target", null) == "R&D") else (["archives", "disposal"] if (NRCardXlate.getk(card, "melies-target", null) == "Archives") else ["hq", "tenure"])))
					return (func():
						NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"face": face}))
						return (NREngine.continue_ability(state, side, {
							"optional": {
								"prompt": func(state, side, eid, card, targets): return str("The top card of R&D is ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null)) + str(". Trash it?"),
								"waiting-prompt": true,
								"change-in-game-state": {
									"silent": true,
									"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
								},
								"yes-ability": {
									"cost": [NRPayment.to_c("trash-from-deck", 1)],
									"once": "per-turn",
									"msg": "add 1 card from Archives to HQ",
									"async": true,
									"effect": func(state, side, eid, card, targets):
										return NREngine.continue_ability(state, side, NRDefHelpers.gain_credits_ability(), card, null),
								},
							},
						}, card, null) if (((NRUtil.first_of(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == target_zone) or NRUtil.kw_eq(NRUtil.first_of(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), target_zone)) and (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty())) else NREid.effect_completed(state, side, eid))
					).call()
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Mercury: Chrome Libertador", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Bioroid",
		"subtypes": ["Bioroid"],
		"text": "Once per turn → When you breach HQ or R&D during a run, if you did not break any subroutines during that run, you may access 1 additional card.",
		"code": "34010",
		"title": "Mercury: Chrome Libertador",
	}, {
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (NREvents.run_events(state, side, "subroutines-broken") is Array and NREvents.run_events(state, side, "subroutines-broken").is_empty() if false else (str(NREvents.run_events(state, side, "subroutines-broken")) == "")) and NRUtil.in_coll(["hq", "rd"], NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var breached_server = NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)
				return NREngine.continue_ability(state, side, {
					"optional": {
						"prompt": "Access 1 additional card?",
						"waiting-prompt": true,
						"once": "per-turn",
						"yes-ability": {
							"msg": "access 1 additional card",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								NRAccess.access_bonus(state, side, breached_server, 1, "end-of-access")
								return NREid.effect_completed(state, side, eid),
						},
						"no-ability": {
							"effect": func(state, side, eid, card, targets):
								return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to access 1 additional card"))),
						},
					},
				}, card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("MirrorMorph: Endless Iteration", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "If the first, second, and third actions you take on your turn are each different from one another, when the third action completes, you may gain 1[Credits] or take another different action, paying [Click] less.",
		"code": "26031",
		"title": "MirrorMorph: Endless Iteration",
	}, (func():
		var relevant_keys = func(context): return {
			"cid": NRUtil.get_in(NRCardXlate.ctx(targets), ["card", "cid"], null),
			"idx": NRCardXlate.getk(NRCardXlate.ctx(targets), "ability-idx", null),
		}
		var mm_clear = {
			"prompt": "Manually fix Mirrormorph",
			"msg": "manually clear Mirrormorph flags",
			"label": "Manually fix Mirrormorph",
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "mm-actions"], []))
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "mm-click"], false)),
		}
		var mm_ability = {
			"prompt": "Choose one",
			"choices": ["Gain [Click]", "Gain 1 [Credits]"],
			"msg": func(state, side, eid, card, targets): return str(decapitalize(NRCardXlate.first_target(targets))),
			"once": "per-turn",
			"label": "Manually trigger ability",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRGaining.gain_clicks(state, side, 1)
				NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "mm-click"], true))
				return NREid.effect_completed(state, side, eid)
			).call() if (("Gain [Click]" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Gain [Click]", NRCardXlate.first_target(targets))) else NRGaining.gain_credits(state, side, eid, 1)),
		}
		return {
			"implementation": "Does not work with terminal Operations",
			"abilities": [mm_ability, mm_clear],
			"events": [
				{
				"event": "action-resolved",
				"async": true,
				"req": func(state, side, eid, card, targets): return (("corp" == side) or NRUtil.kw_eq("corp", side)),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var ctx_keys = relevant_keys(NRCardXlate.ctx(targets))
					var prev_actions = NRUtil.get_in(card, ["special", "mm-actions"], [])
					var actions = (NRUtil.as_array(prev_actions) + [ctx_keys])
					return (func():
						NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "mm-actions"], actions))
						NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "mm-click"], false))
						return (NREngine.continue_ability(state, side, mm_ability, NRCard.get_card(state, card), null) if (((3 == NRUtil.as_array(actions).size()) or NRUtil.kw_eq(3, NRUtil.as_array(actions).size())) and ((3 == NRUtil.as_array(NRUtil.as_array(actions)).size()) or NRUtil.kw_eq(3, NRUtil.as_array(NRUtil.as_array(actions)).size()))) else NREid.effect_completed(state, side, eid))
					).call()
				).call(),
			},
				{
				"event": "runner-turn-begins",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "mm-actions"], []))
					return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "mm-click"], false)),
			},
				{
				"event": "corp-turn-ends",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "mm-actions"], []))
					return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "mm-click"], false)),
			},
			],
			"static-abilities": [
				{
				"type": "prevent-paid-ability",
				"req": func(state, side, eid, card, targets): return (NRUtil.get_in(card, ["special", "mm-click"], null) and (func():
					var ctx = {
						"cid": NRCardXlate.getk(NRCardXlate.first_target(targets), "cid", null),
						"idx": NRUtil.as_array(targets)[2],
					}
					var prev_actions = NRUtil.get_in(card, ["special", "mm-actions"], [])
					var actions = (NRUtil.as_array(prev_actions) + [ctx])
					return (not ((((4 == NRUtil.as_array(actions).size()) or NRUtil.kw_eq(4, NRUtil.as_array(actions).size())) and ((4 == NRUtil.as_array(NRUtil.as_array(actions)).size()) or NRUtil.kw_eq(4, NRUtil.as_array(NRUtil.as_array(actions)).size())))))
				).call()),
				"value": true,
			},
			],
		}
	).call()))


static func _register_3() -> void:
	NRCardDefs.defcard("Mti Mwekundu: Life Improved", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Once per turn → When the Runner approaches a server, you may install 1 piece of ice from HQ in the innermost position protecting that server, ignoring all costs. The Runner moves to that ice and approaches it. If this is not the first time they have approached ice this run, they may jack out.",
		"code": "21114",
		"title": "Mti Mwekundu: Life Improved",
	}, {
		"events": [
			{
			"event": "approach-server",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"waiting": "Corp to make a decision",
			"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() > 0) and (not (used_this_turn_p(NRCardXlate.getk(card, "cid", null), state)))),
			"effect": func(state, side, eid, card, targets):
				return (NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": "Install a piece of ice?",
					"once": "per-turn",
					"yes-ability": {
						"prompt": "Choose a piece of ice to install from HQ",
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and NRCard.in_hand(_pct)),
						},
						"async": true,
						"msg": "install a piece of ice from HQ at the innermost position of this server. Runner is now approaching that piece of ice",
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRInstalling.corp_install(state, side, ne, NRCardXlate.first_target(targets), NRServers.zone_to_name(NRServers.target_server(state.getv("run"))), {
							"ignore-all-cost": true,
							"front": true,
						})
						, func(async_result):
							(func():
							state.assoc_in(["run", "position"], 1)
							set_next_phase(state, "approach-ice")
							NRIce.update_all_ice(state, side)
							NRIce.update_all_icebreakers(state, side)
							return NREngine.continue_ability(state, side, NRDefHelpers.offer_jack_out({
								"req": func(state, side, eid, card, targets): return NRCardXlate.getk(NRCardXlate.getk(state, "run", null), "approached-ice?", null),
							}), card, null)
						).call()),
					},
				},
			}, card, null) if (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)), NRCard.ice) != null) else NREngine.continue_ability(state, "corp", {
				"async": true,
				"prompt": "You have no piece of ice to install",
				"choices": ["Carry on!"],
				"prompt-type": "bogus",
				"effect": func(state, side, eid, card, targets):
					return NREid.effect_completed(state, side, eid),
			}, card, null)),
		},
		],
	}))

	NRCardDefs.defcard("MuslihaT: Multifarious Marketeer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "When your turn begins, look at the top card of your stack. If that card is an <strong>icebreaker</strong> or a <strong>run</strong> event, you may reveal it and add it to your grip.",
		"code": "35013",
		"title": "MuslihaT: Multifarious Marketeer",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty()),
			"msg": {
				"public": "look at the top card of the stack",
				"runner": func(state, side, eid, card, targets): return str("look at ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)) + str(" on the top of the stack"),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var top_card = NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null))
				return NREngine.continue_ability(state, side, ({
					"optional": {
						"prompt": (str("Add ") + str(NRCardXlate.getk(top_card, "title", null)) + str(" to the grip?")),
						"waiting-prompt": true,
						"yes-ability": {
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, card, {
								"and-then": " and add it to the grip",
							}, top_card)
							, func(async_result):
								(func():
								NRMoving.move(state, side, top_card, "hand")
								return NREid.effect_completed(state, side, eid)
							).call()),
						},
					},
				} if ((NRCard.event(top_card) and NRCard.has_subtype(top_card, "Run")) or (NRCard.program(top_card) and NRCard.has_subtype(top_card, "Icebreaker"))) else {
					"prompt": (str("The top card of the stack is ") + str(NRCardXlate.getk(top_card, "title", null))),
					"choices": ["OK"],
					"waiting-prompt": true,
					"async": true,
				}), card, null)
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Nasir Meidan: Cyber Explorer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "Whenever you encounter a piece of ice after an approach during which that ice was rezzed, lose all credits in your credit pool. Gain credits equal to the rez cost of that ice.",
		"code": "06017",
		"title": "Nasir Meidan: Cyber Explorer",
	}, {
		"events": [
			{
			"event": "approach-ice",
			"req": func(state, side, eid, card, targets): return (not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, (func():
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				var cost = NRCostFns.rez_cost(state, side, ice)
				return [
					{
					"event": "encounter-ice",
					"duration": "end-of-encounter",
					"unregister-once-resolved": true,
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), ice),
					"msg": func(state, side, eid, card, targets): return str("lose all credits and gain ") + str(cost) + str(" [Credits] from the rez of ") + str(NRCardXlate.getk(ice, "title", null)),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRGaining.lose_credits(state, "runner", ne, NREid.make_eid(state, eid), "all")
					, func(async_result):
						NRGaining.gain_credits(state, "runner", eid, cost)),
				},
				]
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Nathaniel \"Gnat\" Hall: One-of-a-Kind", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "When your turn begins, gain 1[Credits] if you have 2 or fewer cards in your grip.",
		"code": "22001",
		"title": "Nathaniel \"Gnat\" Hall: One-of-a-Kind",
	}, (func():
		var ability = {
			"label": "Gain 1 [Credits] (start of turn)",
			"once": "per-turn",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"automatic": "pre-draw-cards",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (3 > NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size()),
			},
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
			"msg": "gain 1 [Credits]",
		}
		return {
			"flags": {
				"drip-economy": true,
				"runner-phase-12": func(state, side, eid, card, targets):
					return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-turn-draw", true)) != null)),
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			],
		}
	).call()))

	NRCardDefs.defcard("NBN: Controlling the Message", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 12,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "The first time the Runner trashes an installed Corp card each turn, you may trace[4]. If successful, give the Runner 1 tag (cannot be avoided).",
		"code": "11017",
		"title": "NBN: Controlling the Message",
	}, {
		"events": [
			{
			"event": "runner-trash",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"once-per-instance": true,
			"optional": {
				"player": "corp",
				"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(NRCardXlate.getk(_pct, "card", null)) and NRCard.installed(NRCardXlate.getk(_pct, "card", null)))) != null) and NREvents.first_event(state, side, "runner-trash", func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(NRCardXlate.getk(_pct, "card", null)) and NRCard.corp(NRCardXlate.getk(_pct, "card", null)))) != null))),
				"waiting-prompt": true,
				"prompt": "Initiate a trace with strength 4?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"trace": {
						"base": 4,
						"successful": {
							"msg": "give the Runner 1 tag",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRTags.gain_tags(state, "corp", eid, 1, {
								"unpreventable": true,
							}),
						},
					},
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "NBN: Controlling the Message")],
	}))

	NRCardDefs.defcard("NBN: Making News", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "2[recurring-credit]\nUse these credits during trace attempts.",
		"code": "25104",
		"title": "NBN: Making News",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (("trace" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("trace", NRCardXlate.getk(eid, "source-type", null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("NBN: Reality Plus", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "The first time each turn the Runner takes a tag, gain 2[Credits] or draw 2 cards.",
		"code": "30051",
		"title": "NBN: Reality Plus",
	}, {
		"events": [
			{
			"event": "runner-gain-tag",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, "runner", "runner-gain-tag"),
			"player": "corp",
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose one",
			"choices": ["Gain 2 [Credits]", "Draw 2 cards"],
			"msg": func(state, side, eid, card, targets): return str(decapitalize(NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return (NRGaining.gain_credits(state, "corp", eid, 2) if ((NRCardXlate.first_target(targets) == "Gain 2 [Credits]") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Gain 2 [Credits]")) else NRDrawing.draw(state, "corp", eid, 2)),
		},
		],
	}))

	NRCardDefs.defcard("NBN: The World is Yours*", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 12,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Your maximum hand size is increased by 1.",
		"code": "02114",
		"title": "NBN: The World is Yours*",
	}, {
		"static-abilities": [corp_hand_size_(1)],
	}))

	NRCardDefs.defcard("Near-Earth Hub: Broadcast Center", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 17,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn you create a remote server, draw 1 card.",
		"code": "31060",
		"title": "Near-Earth Hub: Broadcast Center",
	}, {
		"events": [
			{
			"event": "server-created",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, "corp", "server-created"),
			"async": true,
			"msg": "draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "corp", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Nebula Talent Management: Making Stars", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "When your action phase ends, if you played an operation this turn, gain 1[Credits] and flip this identity.\nFlip side:\nThe first time each turn you play an operation, gain [Click].\nWhen the Runner makes a successful run on HQ or R&D, flip this identity.",
		"code": "35057",
		"title": "Nebula Talent Management: Making Stars",
	}, (func():
		var flip_effect = {
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, (NRUtil.merge(card if card is Dictionary else {}, {"flipped": false}) if NRCardXlate.getk(card, "flipped", null) else NRUtil.merge(card if card is Dictionary else {}, {"flipped": true}))),
		}
		return {
			"abilities": [
				NRUtil.merge(flip_effect if flip_effect is Dictionary else {}, {"label": "Manually flip identity"}),
			],
			"events": [
				{
				"event": "pre-first-turn",
				"req": func(state, side, eid, card, targets): return ((side == "corp") or NRUtil.kw_eq(side, "corp")),
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"flipped": false})),
			},
				{
				"event": "corp-turn-ends",
				"req": func(state, side, eid, card, targets): return ((not (NREvents.no_event(state, side, "play-operation"))) and (not (NRCardXlate.getk(card, "flipped", null)))),
				"msg": "flip [their] identity to Gemilang Arena: Burning Bright and gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRGaining.gain_credits(state, side, ne, 1)
				, func(async_result):
					NREngine.continue_ability(state, side, flip_effect, card, null)),
			},
				{
				"event": "successful-run",
				"req": func(state, side, eid, card, targets): return (((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) or (("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets))))) and NRCardXlate.getk(card, "flipped", null)),
				"msg": "flip [their] identity to Nebula Talent Management: Making Stars",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, flip_effect, card, targets),
			},
				{
				"event": "play-operation-resolved",
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, side, "play-operation-resolved") and (not (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Terminal"))) and NRCardXlate.getk(card, "flipped", null)),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"msg": "gain [click]",
				"effect": func(state, side, eid, card, targets):
					return NRGaining.gain_clicks(state, "corp", 1),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Nero Severn: Information Broker", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Once per turn → When you encounter a <strong>sentry</strong>, you may jack out.",
		"code": "10040",
		"title": "Nero Severn: Information Broker",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": NRCardXlate.getk(NRDefHelpers.offer_jack_out({
				"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Sentry"),
				"once": "per-turn",
			}), "optional", null),
		},
		],
	}))

	NRCardDefs.defcard("New Angeles Sol: Your News", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever an agenda is scored or stolen, you may play 1 <strong>current</strong> from HQ or Archives (paying its play cost).",
		"code": "09002",
		"title": "New Angeles Sol: Your News",
	}, (func():
		var nasol = {
			"optional": {
				"prompt": "Play a Current?",
				"player": "corp",
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(((NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)) + NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null))) + NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "current", null)))), func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Current")) != null),
				"yes-ability": {
					"prompt": "Choose a Current to play from HQ or Archives",
					"show-discard": true,
					"async": true,
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Current") and NRCard.corp(_pct) and (NRCard.in_hand(_pct) or NRCard.in_discard(_pct))),
					},
					"msg": func(state, side, eid, card, targets): return str("play a current from ") + str(NRServers.name_zone("Corp", NRCard.get_zone(NRCardXlate.first_target(targets)))),
					"effect": func(state, side, eid, card, targets):
						return NRPlayInstants.play_instant(state, side, eid, NRCardXlate.first_target(targets)),
				},
			},
		}
		return {
			"events": [
				NRUtil.merge(nasol if nasol is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(nasol if nasol is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("NEXT Design: Guarding the Net", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 12,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Before taking your first turn, you may install up to 3 pieces of ice, with no more than a single piece of ice per server. Draw until you have 5 cards in HQ.",
		"code": "03003",
		"title": "NEXT Design: Guarding the Net",
	}, (func():
		var ndhelper = func(n): return {
			"prompt": func(state, side, eid, card, targets): return str("When finished, click ") + str(NRCardXlate.getk(card, "title", null)) + str(" to draw back up to 5 cards in HQ. ") + str("Choose a piece of ice in HQ to install"),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and NRCard.ice(_pct) and NRCard.in_hand(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRInstalling.corp_install(state, side, ne, NRCardXlate.first_target(targets), null, {
				"msg-keys": {
					"install-source": card,
					"display-origin": true,
				},
			})
			, func(async_result):
				NREngine.continue_ability(state, side, (nd((n + 1)) if (n < 3) else null), card, null)),
		}
		return {
			"events": [
				{
				"event": "pre-first-turn",
				"req": func(state, side, eid, card, targets): return ((side == "corp") or NRUtil.kw_eq(side, "corp")),
				"msg": "install up to 3 pieces of ice and draw back up to 5 cards",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NREngine.resolve_ability(state, side, ne, ndhelper(1), card, null)
				, func(async_result):
					(func():
					NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"fill-hq": true}))
					return NREid.effect_completed(state, side, eid)
				).call()),
			},
			],
			"abilities": [
				{
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(card, "fill-hq", null),
				"label": "draw remaining cards",
				"msg": func(state, side, eid, card, targets): return str("draw ") + str(NRUtil.quantify((5 - NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()), "card")),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, (5 - NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size()), {
					"suppress-event": true,
				})
				, func(async_result):
					(func():
					NRUpdate.update_card(state, side, NRUtil.dissoc(card if card is Dictionary else {}, ["fill-hq"]))
					state.setv("turn-events", null)
					return NREid.effect_completed(state, side, eid)
				).call()),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Nisei Division: The Next Generation", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever you and the Runner reveal secretly spent credits, gain 1[Credits].",
		"code": "05002",
		"title": "Nisei Division: The Next Generation",
	}, {
		"events": [
			{
			"event": "reveal-spent-credits",
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(NRCardXlate.ctx(targets), "corp-credits", null) != null) and (NRCardXlate.getk(NRCardXlate.ctx(targets), "runner-credits", null) != null)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Noise: Hacker Extraordinaire", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "Whenever you install a <strong>virus</strong> program, the Corp trashes the top card of R&D.",
		"code": "01001",
		"title": "Noise: Hacker Extraordinaire",
	}, {
		"events": [
			{
			"async": true,
			"event": "runner-install",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Virus"),
			"msg": "force the Corp to trash the top card of R&D",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.mill(state, "corp", eid, "corp", 1),
		},
		],
	}))

	NRCardDefs.defcard("Null: Whistleblower", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Once per turn → When you encounter a piece of ice, you may trash 1 card from your grip. If you do, that ice gets –2 strength for the remainder of this run.",
		"code": "11002",
		"title": "Null: Whistleblower",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size() > 0),
				"prompt": "Trash a card in the grip to lower the strength of encountered ice by 2?",
				"once": "per-turn",
				"yes-ability": {
					"prompt": "Choose a card to trash",
					"choices": {
						"card": NRCard.in_hand,
					},
					"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the grip to lower the strength of ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str(" by 2 for the remainder of the run"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NREffects.register_lingering_effect(state, side, card, (func():
						var ice = NRIce.get_current_ice(state)
						return {
							"type": "ice-strength",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), ice),
							"value": -2,
						}
					).call())
						NRIce.update_all_ice(state, side)
						return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
						"unpreventable": true,
					}),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Nuvem SA: Law of the Land", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 50,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "Whenever you finish resolving an operation or an action on an <strong>expendable</strong> card, look at the top card of R&D. You may trash that card.\nThe first time you trash a card from R&D during each of your turns, gain 2[Credits].",
		"code": "34121",
		"title": "Nuvem SA: Law of the Land",
	}, (func():
		var abi2 = {
			"event": "corp-trash",
			"req": func(state, side, eid, card, targets): return ((("corp" == NRCardXlate.getk(state, "active-player", null)) or NRUtil.kw_eq("corp", NRCardXlate.getk(state, "active-player", null))) and ((["deck"] == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null), "zone", null)) or NRUtil.kw_eq(["deck"], NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null), "zone", null))) and NREvents.first_event(state, side, "corp-trash", func(_pct, _pct2=null, _pct3=null): return ((["deck"] == NRCardXlate.getk(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null), "zone", null)) or NRUtil.kw_eq(["deck"], NRCardXlate.getk(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null), "zone", null))))),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 2),
		}
		var abi1 = {
			"prompt": func(state, side, eid, card, targets): return str("The top card of R&D is: ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null)),
			"async": true,
			"msg": "look at the top card of R&D",
			"choices": ["OK"],
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": (str("Trash ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), "title", null)) + str("?")),
					"yes-ability": {
						"msg": "trash the top card of R&D",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRMoving.mill(state, "corp", eid, "corp", 1),
					},
				},
			}, card, null),
		}
		return {
			"events": [
				NRUtil.merge(abi1 if abi1 is Dictionary else {}, {"event": "expend-resolved"}),
				NRUtil.merge(abi1 if abi1 is Dictionary else {}, {"event": "play-operation-resolved"}),
				abi2,
			],
		}
	).call()))

	NRCardDefs.defcard("Nyusha \"Sable\" Sintashta: Symphonic Prodigy", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "When your turn begins, identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nThe first time each turn you make a successful run on your mark, gain [Click].",
		"code": "33011",
		"title": "Nyusha \"Sable\" Sintashta: Symphonic Prodigy",
	}, {
		"events": [
			mark_changed_event,
			NRUtil.merge(NRMark.identify_mark_ability if NRMark.identify_mark_ability is Dictionary else {}, {"event": "runner-turn-begins"}),
			{
			"event": "successful-run",
			"automatic": "gain-clicks",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.first_target(targets), "marked-server", null) and NREvents.first_event(state, side, "successful-run", func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(NRUtil.first_of(_pct), "marked-server", null))),
			"msg": "gain [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		},
		],
	}))

	NRCardDefs.defcard("Ob Superheavy Logistics: Extract. Export. Excel.", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "Once per turn → When you trash a rezzed card, except during installation, you may search R&D for 1 card with a printed rez cost exactly 1[Credits] less than the trashed card's printed rez cost. Install and rez the card you found, ignoring credit costs.",
		"code": "33057",
		"title": "Ob Superheavy Logistics: Extract. Export. Excel.",
	}, (func():
		var _b0 = trash_cause([eid, NRCardXlate.first_target(targets)], (func():
			var cause = NRCardXlate.getk(NRCardXlate.first_target(targets), "cause", null)
			var cause_card = NRCardXlate.getk(NRCardXlate.first_target(targets), "cause-card", null)
			return (NRCard.corp(NRCardXlate.getk(eid, "source", null)) or (("ability-cost" == cause) or NRUtil.kw_eq("ability-cost", cause)) or (("subroutine" == cause) or NRUtil.kw_eq("subroutine", cause)) or (NRCard.corp(cause_card) and (not (((cause == "opponent-trashes") or NRUtil.kw_eq(cause, "opponent-trashes"))))) or (NRCard.runner(cause_card) and ((cause == "forced-to-trash") or NRUtil.kw_eq(cause, "forced-to-trash"))))
		).call())
		return {
			"abilities": [
				NRChooseOne.choose_one({
				"label": "Always pause at start of turn",
			}, [
				{
				"option": "Always pause at turn start",
				"ability": {
					"effect": func(state, side, eid, card, targets):
						NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "pause-at-phase-12"], true))
						return NRToasts.toast(state, "corp", "The game will always pause at the start of the turn"),
				},
			},
				{
				"option": "Only if triggered by cards in play",
				"ability": {
					"effect": func(state, side, eid, card, targets):
						NRUpdate.update_card(state, side, NRUtil.dissoc_in(card, ["special", "pause-at-phase-12"]))
						return NRToasts.toast(state, "corp", "The game only pause at turn start if triggered by cards in play"),
				},
			},
			]),
			],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return NRUtil.get_in(card, ["special", "pause-at-phase-12"], null),
			},
			"events": [
				{
				"event": "corp-trash",
				"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "during-installation", null))) and NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and trash_cause(eid, NRCardXlate.first_target(targets)) and (not (used_this_turn_p(NRCardXlate.getk(card, "cid", null), state)))),
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var target_cost = (NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null), "cost", null) - 1)
					return NREngine.continue_ability(state, side, ob_ability(target_cost), card, null)
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Omar Keung: Conspiracy Theorist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 12,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Once per turn → [Click]<strong>:</strong> Run Archives. If that run would be declared successful, change the attacked server to HQ or R&D for the remainder of that run.",
		"code": "11043",
		"title": "Omar Keung: Conspiracy Theorist",
	}, {
		"abilities": [
			NRCardXlate.run_server_ability("archives", {
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"once": "per-turn",
			"events": [
				{
				"event": "pre-successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"duration": "end-of-run",
				"unregister-once-resolved": true,
				"req": func(state, side, eid, card, targets): return (("archives" == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq("archives", NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
				"prompt": "Choose one",
				"choices": ["HQ", "R&D"],
				"msg": func(state, side, eid, card, targets): return str("change the attacked server to ") + str(NRCardXlate.first_target(targets)),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var target_server = ("hq" if ((NRCardXlate.first_target(targets) == "HQ") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "HQ")) else "rd")
					return state.assoc_in(["run", "server"], [NRServers.target_server])
				).call(),
			},
			],
		}),
		],
	}))

	NRCardDefs.defcard("Nova Initiumia: Catalyst & Impetus", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Neutral",
		"baselink": 0,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Digital - Natural",
		"subtypes": ["Digital", "Natural"],
		"text": "Your deck cannot include more than 1 copy of any card.",
		"code": "33093",
		"title": "Nova Initiumia: Catalyst & Impetus",
	}, {}))

	NRCardDefs.defcard("Pālanā Foods: Sustainable Growth", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn the Runner draws a card, gain 1[Credits].",
		"code": "10030",
		"title": "Pālanā Foods: Sustainable Growth",
	}, {
		"events": [
			{
			"event": "runner-draw",
			"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, "corp", "runner-draw") and (NRCardXlate.getk(NRCardXlate.first_target(targets), "count", null) > 0)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"automatic": "gain-credits",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Poétrï Luxury Brands: All the Rage", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever you score an agenda, look at the top 3 cards of R&D. You may install 1 non-agenda card from among them.\nWhenever an agenda is stolen, you may install 1 non-agenda card from HQ.",
		"code": "35036",
		"title": "Poétrï Luxury Brands: All the Rage",
	}, (func():
		var remote_choice = func(chosen): return {
			"async": true,
			"waiting-prompt": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var target_position = NRUtil.first_of(positions([chosen], NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))))
				return NRInstalling.corp_install(state, side, eid, chosen, null, {
					"msg-keys": {
						"install-source": card,
						"origin-index": target_position,
						"display-origin": true,
					},
				})
			).call(),
		}
		var opts_fn = func(cards): return NRUtil.as_array(cards).map(func(_pct, _pct2=null, _pct3=null): return ({
			"option": (str("Install ") + str(NRCardXlate.getk(_pct, "title", null))),
			"ability": remote_choice(_pct),
		} if ((not (NRCard.operation(_pct))) and (not (NRCard.agenda(_pct)))) else null))
		var ev = {
			"prompt": func(state, side, eid, card, targets): return str("The top of R&D is (in order): ") + str(NRUtil.enumerate_cards(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3)))),
			"async": true,
			"msg": "look at the top 3 cards of R&D",
			"effect": func(state, side, eid, card, targets):
				return (func():
				var top_3 = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))
				return NREngine.continue_ability(state, side, NRChooseOne.choose_one({
					"prompt": (str("The top of R&D is (in order): ") + str(NRUtil.enumerate_cards(top_3))),
					"optional": true,
				}, opts_fn(top_3)), card, null)
			).call(),
		}
		var score_ev = {
			"event": "agenda-scored",
			"skippabe": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"prompt": "Look at the top 3 cards of R&D?",
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
				"yes-ability": ev,
			},
		}
		return {
			"events": [
				{
				"event": "agenda-stolen",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"skippable": true,
				"async": true,
				"prompt": "Install a non-agenda from HQ?",
				"change-in-game-state": {
					"silent": true,
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
				},
				"waiting-prompt": true,
				"choices": {
					"card": func(_x): return ((NRCard.corp).call(_x)) and ((NRCard.in_hand).call(_x)) and ((func(_x): return not NRCard.agenda.call(_x)).call(_x)) and ((func(_x): return not NRCard.operation.call(_x)).call(_x)),
				},
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.corp_install(state, side, eid, NRCardXlate.first_target(targets), null, {
					"msg-keys": {
						"install-source": card,
					},
				}),
			},
				score_ev,
			],
		}
	).call()))

	NRCardDefs.defcard("Pravdivost Consulting: Political Solutions", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn the Runner makes a successful run, you may place 1 advancement counter on an installed card you can advance.",
		"code": "33048",
		"title": "Pravdivost Consulting: Political Solutions",
	}, {
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "successful-run"),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"waiting-prompt": true,
			"prompt": "Choose a card that can be advanced to place 1 advancement counter on",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and NRAgendas.can_be_advanced(state, NRCardXlate.first_target(targets))),
			},
			"msg": {
				"public": func(state, side, eid, card, targets): return str("place 1 advancement counter on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
				"corp": func(state, side, eid, card, targets): return str("place 1 advancement counter on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets), {
					"maybe-visible": true,
				})),
			},
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_prop(state, "corp", eid, NRCardXlate.first_target(targets), "advance-counter", 1, {
				"placed": true,
			}),
		},
		],
	}))

	NRCardDefs.defcard("PT Untaian: Life's Building Blocks", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "When your discard phase ends, if there are 3 or fewer cards in HQ, you may pay 1[Credits] to place 1 advancement counter on an unrezzed card you can advance. <em>(You cannot score that card this turn.)</em>",
		"code": "35047",
		"title": "PT Untaian: Life's Building Blocks",
	}, {
		"events": [
			{
			"event": "corp-turn-ends",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"skippable": true,
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).size() <= 3),
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return ((func(_x): return not NRCard.rezzed.call(_x)).call(_pct) or NRAgendas.can_be_advanced(state, _pct))) != null),
			},
			"prompt": "Pay 1 [Credits]: place 1 advancement counter on an unrezzed advanceable card?",
			"waiting-prompt": true,
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and (not (NRCard.rezzed(NRCardXlate.first_target(targets)))) and NRAgendas.can_be_advanced(state, NRCardXlate.first_target(targets))),
			},
			"cost": [NRPayment.to_c("credit", 1)],
			"async": true,
			"msg": {
				"public": func(state, side, eid, card, targets): return str("place 1 advancement counter on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
				"corp": func(state, side, eid, card, targets): return str("place 1 advancement counter on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets), {
					"maybe-visible": true,
				})),
			},
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_prop(state, side, eid, NRCardXlate.first_target(targets), "advance-counter", 1, {
				"placed": true,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Quetzal: Free Spirit", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "Once per turn → <strong>0[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.",
		"code": "31001",
		"title": "Quetzal: Free Spirit",
	}, {
		"abilities": [
			NRUtil.merge(NRCardXlate.break_sub(null, 1, "Barrier", {
			"repeatable": false,
		}) if NRCardXlate.break_sub(null, 1, "Barrier", {
			"repeatable": false,
		}) is Dictionary else {}, {"once": "per-turn"}),
		],
	}))

	NRCardDefs.defcard("Reina Roja: Freedom Fighter", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 1,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg - G-mod",
		"subtypes": ["Cyborg", "G-mod"],
		"text": "The first piece of ice the Corp rezzes each turn costs 1[Credits] more to rez.",
		"code": "31002",
		"title": "Reina Roja: Freedom Fighter",
	}, (func():
		return {
			"static-abilities": [
				{
				"type": "rez-cost",
				"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and (not (NRCard.rezzed(NRCardXlate.first_target(targets)))) and not_triggered_p(state)),
				"value": 1,
			},
			],
			"events": [
				{
				"event": "rez",
				"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and not_triggered_p(state)),
				"msg": func(state, side, eid, card, targets): return str("increased the rez cost of ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) + str(" by 1 [Credits]"),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("René \"Loup\" Arcemont: Party Animal", NRCardXlate.merge_cdef({
		"title": "René \"Loup\" Arcemont: Party Animal",
	}, {
		"events": [
			{
			"event": "runner-trash",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed", null) and NREvents.first_event(state, side, "runner-trash", func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCardXlate.getk(_pct, "accessed", null)) != null))),
			"async": true,
			"msg": "gain 1 [Credits] and draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRDrawing.draw(state, "runner", ne, 1, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRGaining.gain_credits(state, "runner", eid, 1)),
		},
		],
	}))

	NRCardDefs.defcard("Rielle \"Kit\" Peddler: Transhuman", NRCardXlate.merge_cdef({
		"title": "Rielle \"Kit\" Peddler: Transhuman",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"req": func(state, side, eid, card, targets): return NREvents.first_event(state, side, "encounter-ice"),
			"msg": func(state, side, eid, card, targets): return str("make ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)) + str(" gain Code Gate until the end of the run"),
			"effect": func(state, side, eid, card, targets):
				return NREffects.register_lingering_effect(state, side, card, (func():
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return {
					"type": "gain-subtype",
					"duration": "end-of-run",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(ice, NRCardXlate.first_target(targets)),
					"value": "Code Gate",
				}
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Ryō \"Phoenix\" Ōno: Out of the Ashes", NRCardXlate.merge_cdef({
		"title": "Ryō \"Phoenix\" Ōno: Out of the Ashes",
	}, {
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p([NRCardXlate.ctx(targets)]) and NREvents.first_event(state, side, "successful-run", valid_ctx_p))
			).call(),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"automatic": "force-discard",
			"msg": "gain 1 [Credits]",
			"async": true,
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, 1)
			, func(async_result):
				(NREid.effect_completed(state, side, eid) if (not ((not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()))) else NREngine.continue_ability(state, "corp", {
				"display-side": "corp",
				"waiting-prompt": true,
				"player": "corp",
				"cost": [NRPayment.to_c("trash-from-hand", 1)],
				"msg": "cost",
			}, card, null))),
		},
		],
	}))

	NRCardDefs.defcard("Saraswati Mnemonics: Endless Exploration", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "<strong>[Click]</strong>, <strong>1[Credits]:</strong> Install 1 card from HQ in the root of a remote server, then place 1 advancement counter on it. You cannot score or rez that card until your next turn begins.",
		"code": "22034",
		"title": "Saraswati Mnemonics: Endless Exploration",
	}, (func():
		return {
			"abilities": [
				{
				"action": true,
				"async": true,
				"label": "Install a card from HQ",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 1)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
				},
				"prompt": "Choose a card to install from HQ",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return ((NRCard.asset(_pct) or NRCard.agenda(_pct) or NRCard.upgrade(_pct)) and NRCard.corp(_pct) and NRCard.in_hand(_pct)),
				},
				"msg": "install a card in a remote server and place 1 advancement counter on it",
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, install_card(NRCardXlate.first_target(targets)), card, null),
			},
			],
			"events": [
				{
				"event": "corp-turn-begins",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return clear_persistent_flag_bang(state, side, card, "can-rez"),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Sebastião Souza Pessoa: Activist Organizer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "Whenever you take 1 or more tags, if you had no tags, you may install 1 <strong>connection</strong> resource from your grip, paying 2[Credits] less.\nAs an additional cost to trash a <strong>connection</strong> resource with the basic action, the Corp must trash 1 card from HQ.",
		"code": "34066",
		"title": "Sebastião Souza Pessoa: Activist Organizer",
	}, {
		"static-abilities": [
			{
			"type": "basic-ability-additional-trash-cost",
			"req": func(state, side, eid, card, targets): return (NRCard.resource(NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Connection") and (("corp" == side) or NRUtil.kw_eq("corp", side))),
			"value": [NRPayment.to_c("trash-from-hand", 1)],
		},
		],
		"events": [
			{
			"event": "runner-gain-tag",
			"async": true,
			"req": func(state, side, eid, card, targets): return ((not (NRInstalling.install_locked(state, side))) and ((NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null) == NRCardXlate.count_tags(state)) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", null), NRCardXlate.count_tags(state)))),
			"prompt": "Choose a connection to install, paying 2 [Credits] less",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.first_target(targets), "Connection") and NRCard.resource(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and NRPayment.can_pay(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), null, [
					NRPayment.to_c("credit", NRCostFns.install_cost(state, side, NRCardXlate.first_target(targets), {
					"cost-bonus": -2,
				})),
				])),
			},
			"effect": func(state, side, eid, card, targets):
				return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"cost-bonus": -2,
				"msg-keys": {
					"display-origin": true,
					"install-source": card,
				},
			}),
		},
		],
	}))

	NRCardDefs.defcard("Seidr Laboratories: Destiny Defined", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn the Runner loses or spends [Click] during a run, you may add 1 card from Archives to the top of R&D.",
		"code": "25067",
		"title": "Seidr Laboratories: Destiny Defined",
	}, {
		"implementation": "Manually triggered",
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return (state.getv("run") and (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).is_empty())),
			"label": "add card from Archives to R&D during a run",
			"once": "per-turn",
			"prompt": "Choose a card to add to the top of R&D",
			"show-discard": true,
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
			},
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRCardXlate.first_target(targets), "deck", {
				"front": true,
			}),
			"msg": func(state, side, eid, card, targets): return str("add ") + str((NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null) if NRCardXlate.getk(NRCardXlate.first_target(targets), "seen", null) else "a card")) + str(" to the top of R&D"),
		},
		],
	}))

	NRCardDefs.defcard("Silhouette: Stealth Operative", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "The first time you make a successful run on HQ each turn, you may expose 1 card.",
		"code": "05030",
		"title": "Silhouette: Stealth Operative",
	}, {
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return (not (NRCard.rezzed(_pct)))) != null),
			"async": true,
			"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "hq")),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and (not (NRCard.rezzed(_pct)))),
			},
			"effect": func(state, side, eid, card, targets):
				return NRExpose.expose(state, side, eid, [NRCardXlate.first_target(targets)]),
		},
		],
	}))

	NRCardDefs.defcard("Skorpios Defense Systems: Persuasive Power", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Subsidiary",
		"subtypes": ["Subsidiary"],
		"text": "[interrupt] → Whenever 1 or more Runner cards would be trashed <em>(from any location)</em>, set those cards aside instead of adding them to the heap. You can look at those cards. You may remove 1 of them from the game. Then, add all of those cards that are still set aside to the heap. Ignore this ability if you have already removed a card from the game with it this turn.",
		"code": "13041",
		"title": "Skorpios Defense Systems: Persuasive Power",
	}, (func():
		var set_resolution_mode = func(x): return {
			"label": x,
			"effect": func(state, side, eid, card, targets):
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "resolution-mode"], x))
				NRToasts.toast(state, "corp", (str("Set Skorpios resolution to ") + str(x) + str(" mode")))
				return NRUpdate.update_card(state, side, NRUtil.merge(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, {"card-target": x})),
		}
		var in_grip_or_stack_p = func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and (NRCard.in_hand(_pct) or NRCard.in_deck(_pct)))
		var grip_or_stack_trash_p = func(_pct, _pct2=null, _pct3=null): return (NRUtil.find_first(NRUtil.as_array(NRUtil.as_array(_pct).map(func(_x): return bool(NRCardXlate.getk(_x, "card")))), in_grip_or_stack_p) != null)
		var relevant_cards_general = ["Labor Rights", "The Price"]
		var relevant_cards_trashed = ["I've Had Worse", "Strike Fund", "Steelskin Scarring", "Crowdfunding"]
		var trigger_ability_req = func(state, side, eid, card, targets):
			return (func():
			var res_type = NRUtil.get_in(NRCard.get_card(state, card), ["special", "resolution-mode"], null)
			var trashed_cards = NRCardXlate.getk(NRCardXlate.ctx(targets), "trashed-cards", null)
			return ((NRUtil.find_first(NRUtil.as_array(trashed_cards), NRCard.runner) != null) and (true if ((res_type == "Automatic") or NRUtil.kw_eq(res_type, "Automatic")) else ((NRUtil.in_coll(relevant_cards_general, NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "play-area", null)), "title", null)) or ((NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == "Buffer Drive") or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), "Buffer Drive"))) != null) and (NRUtil.find_first(NRUtil.as_array(trashed_cards), in_grip_or_stack_p) != null) and NREvents.no_event(state, null, "runner-trash", grip_or_stack_trash_p) and NREvents.no_event(state, null, "corp-trash", grip_or_stack_trash_p) and NREvents.no_event(state, null, "game-trash", grip_or_stack_trash_p)) or (NRUtil.find_first(NRUtil.as_array(trashed_cards), NRCard.program) != null) or (NRUtil.find_first(NRUtil.as_array(NRUtil.as_array(trashed_cards).map(func(_x): return bool(NRCardXlate.getk(_x, "title")))), func(_pct, _pct2=null, _pct3=null): return NRUtil.in_coll(relevant_cards_trashed, _pct)) != null)) if ((res_type == "Smart") or NRUtil.kw_eq(res_type, "Smart")) else null)))
		).call()
		var triggered_ability = {
			"once": "per-turn",
			"player": "corp",
			"event": "pre-trash-interrupt",
			"waiting-prompt": true,
			"req": trigger_ability_req,
			"prompt": "Remove a card from the game?",
			"choices": func(state, side, eid, card, targets):
				return NRCardXlate.getk(NRCardXlate.ctx(targets), "trashed-cards", null),
			"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the game"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, "runner", NRCardXlate.first_target(targets), "rfg")
				return NREid.effect_completed(state, side, eid),
		}
		return {
			"implementation": "Switch between Manual, \"Smart\", and Automatic resolution by using the ability on the card",
			"events": [
				NRUtil.merge(set_resolution_mode("Smart") if set_resolution_mode("Smart") is Dictionary else {}, {"event": "pre-first-turn"}),
				triggered_ability,
			],
			"abilities": [
				NRChooseOne.choose_one({
				"optional": true,
				"label": "Set resolution mode",
			}, NRUtil.as_array(["Manual", "Smart", "Automatic"]).map(func(x): return {
				"option": x,
				"ability": set_resolution_mode(x),
			})),
				{
				"label": "Remove a card in the Heap that was just trashed from the game",
				"waiting-prompt": true,
				"prompt": "Choose a card in the Heap that was just trashed",
				"once": "per-turn",
				"choices": func(state, side, eid, card, targets):
					return NRCardXlate.getk(state.getv("runner", {}), "discard", null),
				"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the game"),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.move(state, "runner", NRCardXlate.first_target(targets), "rfg"),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Spark Agency: Worldswide Reach", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn you rez an <strong>advertisement</strong>, the Runner loses 1[Credits].",
		"code": "25105",
		"title": "Spark Agency: Worldswide Reach",
	}, {
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Advertisement") and NREvents.first_event(state, "corp", "rez", func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null), "Advertisement"))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "runner", eid, 1),
			"msg": "make the Runner lose 1 [Credits]",
		},
		],
	}))

	NRCardDefs.defcard("Sportsmetal: Go Big or Go Home", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Subsidiary",
		"subtypes": ["Subsidiary"],
		"text": "Whenever an agenda is scored or stolen, gain 2[Credits] or draw 2 cards.",
		"code": "22026",
		"title": "Sportsmetal: Go Big or Go Home",
	}, (func():
		var ab = {
			"prompt": "Choose one",
			"waiting-prompt": true,
			"player": "corp",
			"choices": ["Gain 2 [Credits]", "Draw 2 cards"],
			"msg": func(state, side, eid, card, targets): return str(decapitalize(NRCardXlate.first_target(targets))),
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return (NRGaining.gain_credits(state, "corp", eid, 2) if ((NRCardXlate.first_target(targets) == "Gain 2 [Credits]") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Gain 2 [Credits]")) else NRDrawing.draw(state, "corp", eid, 2)),
		}
		return {
			"events": [
				NRUtil.merge(ab if ab is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(ab if ab is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("SSO Industries: Fueling Innovation", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "When your turn ends, you may choose a piece of ice with no advancement tokens on it. If you do, place 1 advancement token on that piece of ice for each agenda point on all installed faceup agendas.",
		"code": "21077",
		"title": "SSO Industries: Fueling Innovation",
	}, (func():
		var _b0 = selectable_ice_p([card], (NRCard.ice(card) and NRCard.installed(card) and (NRCard.get_counters(card, "advancement") == 0)))
		return {
			"events": [
				{
				"event": "corp-turn-ends",
				"optional": {
					"req": func(state, side, eid, card, targets): return ((not NRUtil.as_array(installed_faceup_agendas(state)).is_empty()) and (not NRUtil.as_array(ice_with_no_advancement_tokens(state)).is_empty())),
					"waiting-prompt": true,
					"prompt": "Place advancement counters on an installed piece of ice?",
					"autoresolve": NROptional.get_autoresolve("auto-fire"),
					"yes-ability": {
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return (func():
							var agendas = installed_faceup_agendas(state)
							var agenda_points = reduce(_, NRUtil.as_array(agendas).map(func(_x): return bool(NRCardXlate.getk(_x, "agendapoints"))))
							return NREngine.continue_ability(state, side, {
								"prompt": (str("Choose a piece of ice with no advancement counters to place ") + str(NRUtil.quantify(agenda_points, "advancement counter")) + str(" on")),
								"choices": {
									"card": func(_pct, _pct2=null, _pct3=null): return selectable_ice_p(_pct),
								},
								"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(agenda_points, "advancement counter")) + str(" on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
								"async": true,
								"effect": func(state, side, eid, card, targets):
									return NRProps.add_prop(state, side, eid, NRCardXlate.first_target(targets), "advance-counter", agenda_points, {
									"placed": true,
								}),
							}, card, null)
						).call(),
					},
				},
			},
			],
			"abilities": [NROptional.set_autoresolve("auto-fire", "SSO Industries: Fueling Innovation")],
		}
	).call()))

	NRCardDefs.defcard("Steve Cambridge: Master Grifter", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "The first time each turn you make a successful run on HQ, you may choose 2 cards in your heap. If you do, the Corp removes 1 of those cards from the game, then you add the other card to your grip.",
		"code": "31014",
		"title": "Steve Cambridge: Master Grifter",
	}, {
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "hq") and (2 <= NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).size()) and (not (NRFlags.zone_locked(state, "runner", "discard")))),
				"prompt": "Choose 2 cards in the heap?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"interactive": func(state, side, eid, card, targets):
					return true,
				"yes-ability": {
					"async": true,
					"prompt": "Choose 2 cards in the heap",
					"show-discard": true,
					"choices": {
						"max": 2,
						"all": true,
						"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_discard(_pct) and NRCard.runner(_pct)),
					},
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, (func():
						var c1 = NRUtil.first_of(targets)
						var c2 = (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null)
						return {
							"waiting-prompt": true,
							"prompt": "Choose which card to remove from the game",
							"player": "corp",
							"choices": [c1, c2],
							"msg": func(state, side, eid, card, targets): return str((func():
								var _destructured_0 = ([c1, c2] if ((NRCardXlate.first_target(targets) == c1) or NRUtil.kw_eq(NRCardXlate.first_target(targets), c1)) else [c2, c1])
								return (str("add ") + str(NRCardXlate.getk(other, "title", null)) + str(" from the heap to the grip.") + str(" Corp removes ") + str(NRCardXlate.getk(chosen, "title", null)) + str(" from the game"))
							).call()),
							"effect": func(state, side, eid, card, targets):
								return (func():
								var _destructured_0 = ([c1, c2] if ((NRCardXlate.first_target(targets) == c1) or NRUtil.kw_eq(NRCardXlate.first_target(targets), c1)) else [c2, c1])
								return (func():
									NRMoving.move(state, "runner", chosen, "rfg")
									return NRMoving.move(state, "runner", other, "hand")
								).call()
							).call(),
						}
					).call(), card, null),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Steve Cambridge: Master Grifter")],
	}))

	NRCardDefs.defcard("Strategic Innovations: Future Forward", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Draft format only.\nIf you have more [haas-bioroid] cards rezzed than any other faction, when the Runner's turn ends, shuffle 1 card in Archives into R&D.",
		"code": "00010",
		"title": "Strategic Innovations: Future Forward",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"effect": draft_points_target,
		},
			{
			"event": "runner-turn-ends",
			"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (is_disabled_p(state, side, card))) and has_most_faction_p(state, "corp", "Haas-Bioroid")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				shuffle_cards_into_deck_bang(state, "corp", card, [])
				return NREid.effect_completed(state, side, eid)
			).call() if (NRCardXlate.getk(state.getv("corp", {}), "discard", null) is Array and NRCardXlate.getk(state.getv("corp", {}), "discard", null).is_empty() if false else (str(NRCardXlate.getk(state.getv("corp", {}), "discard", null)) == "")) else NREngine.continue_ability(state, side, {
				"prompt": "Choose a card in Archives to shuffle into R&D",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.corp(_pct) and NRCard.in_discard(_pct)),
					"all": true,
				},
				"player": "corp",
				"show-discard": true,
				"effect": func(state, side, eid, card, targets):
					return shuffle_cards_into_deck_bang(state, "corp", card, [NRCardXlate.first_target(targets)]),
			}, card, null)),
		},
		],
	}))


static func _register_4() -> void:
	NRCardDefs.defcard("Sunny Lebeau: Security Specialist", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"baselink": 2,
		"influencelimit": 25,
		"minimumdecksize": 50,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"code": "09045",
		"title": "Sunny Lebeau: Security Specialist",
	}, {}))

	NRCardDefs.defcard("SYNC: Everything, Everywhere", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "[Click]: Flip this identity.\nThe Runner pays 1[Credits] more when spending a [Click] to remove a tag (not through a card ability).\nFlip side:\n[Click]: Flip this identity.\nYou may pay 2[Credits] fewer when spending a [Click] to trash a resource (not through a card ability).",
		"code": "09001",
		"title": "SYNC: Everything, Everywhere",
	}, {
		"static-abilities": [
			{
			"type": "card-ability-cost",
			"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(card, "sync-flipped", null))) and NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(state.getv("runner", {}), "basic-action-card", null)) and (("Remove 1 tag" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)) or NRUtil.kw_eq("Remove 1 tag", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)))),
			"value": NRPayment.to_c("credit", 1),
		},
			{
			"type": "card-ability-cost",
			"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(card, "sync-flipped", null) and NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(state.getv("corp", {}), "basic-action-card", null)) and (("Trash 1 resource if the Runner is tagged" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)) or NRUtil.kw_eq("Trash 1 resource if the Runner is tagged", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ability", null), "label", null)))),
			"value": NRPayment.to_c("credit", -2),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"effect": func(state, side, eid, card, targets):
				return (NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"sync-flipped": false})) if NRCardXlate.getk(card, "sync-flipped", null) else NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"sync-flipped": true}))),
			"label": "Flip this identity",
			"msg": "flip [their] identity",
		},
		],
	}))

	NRCardDefs.defcard("Synapse Global: Faster than Thought", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "NBN",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time each turn a tag is removed, you may reveal and install 1 card from HQ, ignoring all costs.\n[Click], <strong>remove 1 tag:</strong> Gain 2[Credits].",
		"code": "35058",
		"title": "Synapse Global: Faster than Thought",
	}, {
		"events": [
			{
			"event": "runner-lose-tag",
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p(targets) and NREvents.first_event(state, side, "runner-lose-tag", valid_ctx_p))
			).call(),
			"prompt": "Reveal and install a card from HQ?",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
				"silent": true,
			},
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.corp(NRCardXlate.first_target(targets)) and NRCard.in_hand(NRCardXlate.first_target(targets)) and (not (NRCard.operation(NRCardXlate.first_target(targets))))),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRevealing.reveal(state, side, ne, card, null, [NRCardXlate.first_target(targets)])
			, func(async_result):
				NRInstalling.corp_install(state, side, eid, NRCardXlate.first_target(targets), null, {
				"ignore-install-cost": true,
				"msg-keys": {
					"install-source": card,
				},
			})),
		},
		],
		"abilities": [
			{
			"label": "Gain 2 [Credits]",
			"action": "true",
			"async": true,
			"cost": [NRPayment.to_c("tag", 1), NRPayment.to_c("click", 1)],
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("Synthetic Systems: The World Re-imagined", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Draft format only.\nIf you have more [jinteki] cards rezzed than any other faction, when your turn begins, you may swap 2 pieces of installed ice.",
		"code": "00011",
		"title": "Synthetic Systems: The World Re-imagined",
	}, (func():
		var abi = {
			"prompt": "Choose 2 installed pieces of ice to swap",
			"label": "swap 2 installed pieces of ice",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct)),
				"max": 2,
				"all": true,
			},
			"once": "per-turn",
			"effect": func(state, side, eid, card, targets):
				return NRMoving.swap_ice.callv(NRUtil.as_array(targets)),
			"msg": func(state, side, eid, card, targets): return str("swap the positions of ") + str(NRToString.card_str(state, NRUtil.first_of(targets))) + str(" and ") + str(NRToString.card_str(state, (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null))),
		}
		return {
			"events": [
				{
				"event": "pre-start-game",
				"effect": draft_points_target,
			},
				{
				"events": "corp-turn-begins",
				"optional": {
					"req": func(state, side, eid, card, targets): return (has_most_faction_p(state, "corp", "Jinteki") and (2 <= NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.ice)).size())),
					"prompt": "Swap two ice?",
					"waiting-prompt": true,
					"yes-ability": abi,
				},
			},
			],
			"flags": {
				"corp-phase-12": func(state, side, eid, card, targets):
					return ((not (NRCardXlate.getk(NRCard.get_card(state, card), "disabled", null))) and (not (is_disabled_p(state, side, card))) and has_most_faction_p(state, "corp", "Jinteki") and (2 <= NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.ice)).size())),
			},
			"abilities": [abi],
		}
	).call()))

	NRCardDefs.defcard("Tāo Salonga: Telepresence Magician", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Whenever an agenda is scored or stolen, you may swap 2 installed pieces of ice.",
		"code": "30019",
		"title": "Tāo Salonga: Telepresence Magician",
	}, (func():
		var swap_ability = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (2 <= NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.ice)).size()),
			},
			"optional": {
				"prompt": "Swap 2 pieces of ice?",
				"waiting-prompt": true,
				"yes-ability": {
					"prompt": "Choose 2 pieces of ice",
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and NRCard.ice(NRCardXlate.first_target(targets))),
						"max": 2,
						"all": true,
					},
					"msg": func(state, side, eid, card, targets): return str("swap the positions of ") + str(NRToString.card_str(state, NRUtil.first_of(targets))) + str(" and ") + str(NRToString.card_str(state, (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null))),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.swap_ice(state, side, NRUtil.first_of(targets), (NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null)),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		}
		return {
			"events": [
				NRUtil.merge(swap_ability if swap_ability is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(swap_ability if swap_ability is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		}
	).call()))

	NRCardDefs.defcard("Tennin Institute: The Secrets Within", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Jinteki",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "When your turn begins, if the Runner did not make a successful run during their last turn, you may place 1 advancement counter on an installed card.",
		"code": "05003",
		"title": "Tennin Institute: The Secrets Within",
	}, {
		"events": [
			{
			"msg": func(state, side, eid, card, targets): return str("place 1 advancement token on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"label": "Place 1 advancement token on a card if the Runner did not make a successful run last turn",
			"choices": {
				"card": NRCard.installed,
			},
			"event": "corp-turn-begins",
			"req": func(state, side, eid, card, targets): return not_last_turn_p(state, "runner", "successful-run"),
			"waiting-prompt": true,
			"once": "per-turn",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_prop(state, side, eid, NRCardXlate.first_target(targets), "advance-counter", 1, {
				"placed": true,
			}),
		},
		],
	}))

	NRCardDefs.defcard("The Catalyst: Convention Breaker", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Neutral",
		"baselink": 0,
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Starter game only.",
		"code": "30076",
		"title": "The Catalyst: Convention Breaker",
	}, {}))

	NRCardDefs.defcard("The Collective: Williams, Wu, et al.", NRCardXlate.merge_cdef({
		"title": "The Collective: Williams, Wu, et al.",
	}, (func():
		var gain_click_abi = {
			"label": "Manually gain [Click]",
			"once": "per-turn",
			"msg": "gain [Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 1),
		}
		var relevant_keys = func(context): return {
			"cid": NRUtil.get_in(NRCardXlate.ctx(targets), ["card", "cid"], null),
			"idx": NRCardXlate.getk(NRCardXlate.ctx(targets), "ability-idx", null),
		}
		return {
			"events": [
				{
				"event": "action-resolved",
				"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
				"silent": true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var current_queue = NRUtil.get_in(card, ["special", "previous-actions"], null)
					var filtered_context = relevant_keys(NRCardXlate.ctx(targets))
					return ((func():
						var new_queue = (NRUtil.as_array(current_queue) + NRUtil.as_array([filtered_context]))
						return (func():
							NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "previous-actions"], new_queue))
							return (NREngine.continue_ability(state, side, gain_click_abi, card, null) if ((3 == NRUtil.as_array(new_queue).size()) or NRUtil.kw_eq(3, NRUtil.as_array(new_queue).size())) else NREid.effect_completed(state, side, eid))
						).call()
					).call() if ((not NRUtil.as_array(current_queue).is_empty()) and ((NRUtil.first_of(current_queue) == filtered_context) or NRUtil.kw_eq(NRUtil.first_of(current_queue), filtered_context))) else (func():
						NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "previous-actions"], [filtered_context]))
						return NREid.effect_completed(state, side, eid)
					).call())
				).call(),
			},
				{
				"event": "runner-turn-begins",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "previous-actions"], null)),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("The Foundry: Refining the Process", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "The first time you rez a piece of ice each turn, you may search R&D for another copy of that ice, reveal it, and add it to HQ. Shuffle R&D.",
		"code": "06021",
		"title": "The Foundry: Refining the Process",
	}, {
		"events": [
			{
			"event": "rez",
			"optional": {
				"prompt": func(state, side, eid, card, targets): return str("Add another copy of ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) + str(" to HQ?"),
				"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and NREvents.first_event(state, "runner", "rez", func(_pct, _pct2=null, _pct3=null): return NRCard.ice(NRCardXlate.getk(NRUtil.first_of(_pct), "card", null)))),
				"yes-ability": {
					"effect": func(state, side, eid, card, targets):
						return (func():
						var found_card = (NRUtil.find_first(NRUtil.as_array((NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)) + NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "play-area", null)))), func(_pct, _pct2=null, _pct3=null): return (_pct if ((NRCardXlate.getk(_pct, "title", null) == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null))) else null)) != null)
						return (func():
						NRMoving.move(state, side, found_card, "hand")
						NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to add a copy of ") + str(NRCardXlate.getk(found_card, "title", null)) + str(" to HQ, and shuffle R&D")))
						return NRShuffling.shuffle_zone(state, side, "deck")
					).call() if found_card != null else (func():
						NRSay.system_msg(state, side, str("shuffles R&D"))
						return NRShuffling.shuffle_zone(state, side, "deck")
					).call()
					).call(),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("The Masque: Cyber General", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Neutral",
		"baselink": 0,
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Draft format only.",
		"code": "00006",
		"title": "The Masque: Cyber General",
	}, {
		"events": [{
			"event": "pre-start-game",
			"effect": draft_points_target,
		}],
	}))

	NRCardDefs.defcard("The Outfit: Family Owned and Operated", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Subsidiary",
		"subtypes": ["Subsidiary"],
		"text": "Whenever you take 1 or more bad publicity, gain 3[Credits].",
		"code": "22050",
		"title": "The Outfit: Family Owned and Operated",
	}, {
		"events": [
			{
			"event": "corp-gain-bad-publicity",
			"msg": "gain 3 [Credit]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 3),
		},
		],
	}))

	NRCardDefs.defcard("The Professor: Keeper of Knowledge", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Shaper",
		"baselink": 0,
		"influencelimit": 1,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "The first copy of each program in this deck does not count against your influence limit.",
		"code": "03029",
		"title": "The Professor: Keeper of Knowledge",
	}, {}))

	NRCardDefs.defcard("The Shadow: Pulling the Strings", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Neutral",
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Draft format only.\nYou can use agendas from all factions in this deck.",
		"code": "00005",
		"title": "The Shadow: Pulling the Strings",
	}, {
		"events": [{
			"event": "pre-start-game",
			"effect": draft_points_target,
		}],
	}))

	NRCardDefs.defcard("The Syndicate: Profit over Principle", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Neutral",
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Starter game only.",
		"code": "30077",
		"title": "The Syndicate: Profit over Principle",
	}, {}))

	NRCardDefs.defcard("The Zwicky Group: Invisible Hands", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Unsubstantiated",
		"subtypes": ["Unsubstantiated"],
		"text": "The first time each turn you gain credits through an ability on an agenda or operation, you may draw 1 card.",
		"code": "35069",
		"title": "The Zwicky Group: Invisible Hands",
	}, {
		"events": [
			{
			"event": "corp-credit-gain",
			"async": true,
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p(targets) and NREvents.first_event(state, side, "corp-credit-gain", valid_ctx_p))
			).call(),
			"effect": func(state, side, eid, card, targets):
				return maybe_draw(state, side, eid, card, 1),
		},
		],
	}))

	NRCardDefs.defcard("Thule Subsea: Safety Below", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever the Runner steals an agenda, do 1 core damage unless they spend [Click] and 2[Credits].",
		"code": "33095",
		"title": "Thule Subsea: Safety Below",
	}, {
		"events": [
			{
			"event": "agenda-stolen",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose one",
				"player": "runner",
				"choices": func(state, side, eid, card, targets):
					return [
					("Pay [Click] and 2 [Credits]" if NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 2), NRPayment.to_c("click", 1)]) else null),
					"Suffer 1 core damage",
				],
				"async": true,
				"waiting-prompt": true,
				"msg": func(state, side, eid, card, targets): return str(((str("force the runner to ") + str(decapitalize(NRCardXlate.first_target(targets)))) if ((NRCardXlate.first_target(targets) == "Pay [Click] and 2 [Credits]") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Pay [Click] and 2 [Credits]")) else "do 1 core damage")),
				"effect": func(state, side, eid, card, targets):
					return (NREid.wait_for(state, eid, func(ne):
					NREngine.pay(state, side, ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)])
				, func(async_result):
					(func():
					NRSay.system_msg(state, side, NRCardXlate.getk(async_result, "msg", null))
					return NREid.effect_completed(state, "runner", eid)
				).call()) if ((NRCardXlate.first_target(targets) == "Pay [Click] and 2 [Credits]") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Pay [Click] and 2 [Credits]")) else NRDamage.damage(state, side, eid, "brain", 1, {
					"card": card,
				})),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Thunderbolt Armaments: Peace Through Power", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Haas-Bioroid",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Division",
		"subtypes": ["Division"],
		"text": "Whenever you rez a piece of <strong>AP</strong> or <strong>destroyer</strong> ice during a run, that ice gets +1 strength and gains “[subroutine] End the run unless the Runner trashes 1 of their installed cards.” after its other subroutines for the remainder of that run.",
		"code": "34096",
		"title": "Thunderbolt Armaments: Peace Through Power",
	}, (func():
		var thunderbolt_sub = {
			"player": "runner",
			"async": true,
			"label": "End the run unless the Runner trashes 1 of their installed cards",
			"prompt": "Choose one",
			"waiting-prompt": true,
			"choices": func(state, side, eid, card, targets):
				return [
				"End the run",
				(capitalize(cost_to_string(NRPayment.to_c("trash-installed", 1))) if NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("trash-installed", 1)]) else null),
			],
			"msg": func(state, side, eid, card, targets): return str((decapitalize(NRCardXlate.first_target(targets)) if (("End the run" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("End the run", NRCardXlate.first_target(targets))) else (str("force the runner to ") + str(decapitalize(NRCardXlate.first_target(targets)))))),
			"effect": func(state, side, eid, card, targets):
				return (NRRuns.end_run(state, "corp", eid, card) if (("End the run" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("End the run", NRCardXlate.first_target(targets))) else NREid.wait_for(state, eid, func(ne):
				NREngine.pay(state, "runner", ne, NREid.make_eid(state, eid), card, NRPayment.to_c("trash-installed", 1))
			, func(async_result):
				(func():
				(func():
					var payment_str = NRCardXlate.getk(async_result, "msg", null)
					return NRSay.system_msg(state, "runner", (str(payment_str) + str(" due to ") + str(NRCardXlate.getk(card, "title", null)) + str(" subroutine"))) if payment_str != null else null
				).call()
				return NREid.effect_completed(state, side, eid)
			).call())),
		}
		return {
			"events": [
				{
				"event": "rez",
				"req": func(state, side, eid, card, targets): return (state.getv("run") and NRCard.ice(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) and (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "AP") or NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Destroyer"))),
				"msg": func(state, side, eid, card, targets): return str("give ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) + str(" +1 strength and \"") + str(NRCardXlate.getk(thunderbolt_sub, "label", null)) + str("\" after its other subroutines"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NREffects.register_lingering_effect(state, side, card, (func():
					var t = NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)
					return {
						"type": "additional-subroutines",
						"duration": "end-of-run",
						"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.first_target(targets)) and NRUtil.same_card(t, NRCardXlate.first_target(targets))),
						"value": {
							"subroutines": [thunderbolt_sub],
						},
					}
				).call())
					pump_ice(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), 1, "end-of-run")
					return NREid.effect_completed(state, side, eid),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Titan Transnational: Investing In Your Future", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 17,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Corp",
		"subtypes": ["Corp"],
		"text": "Whenever you score an agenda, you may place 1 agenda counter on it.",
		"code": "07003",
		"title": "Titan Transnational: Investing In Your Future",
	}, {
		"events": [
			{
			"event": "agenda-scored",
			"msg": func(state, side, eid, card, targets): return str("place 1 agenda counter on ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "agenda", 1, null),
		},
		],
	}))

	NRCardDefs.defcard("Topan: Ormas Leader", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "Once per turn → [Click]<strong>:</strong> Install 1 card from your grip, paying 2[Credits] less. When you install that card, suffer 1 meat damage.",
		"code": "35002",
		"title": "Topan: Ormas Leader",
	}, (func():
		return {
			"abilities": [
				{
				"cost": [NRPayment.to_c("click", 1)],
				"action": true,
				"once": "per-turn",
				"async": true,
				"prompt": "Install a card, paying 2 [Credits] less",
				"waiting-prompt": true,
				"choices": {
					"req": func(state, side, eid, card, targets): return installable_p(state, side, eid, NRCardXlate.first_target(targets)),
				},
				"label": "Install 1 card from your grip, paying 2{c} less. When you install that card, suffer 1 meat damage.",
				"effect": func(state, side, eid, card, targets):
					return (func():
					var evs = NREngine.register_events(state, side, card, [
						{
						"event": "runner-install",
						"unregister-once-resolved": true,
						"async": true,
						"interactive": func(state, side, eid, card, targets):
							return true,
						"msg": "suffer 1 meat damage",
						"effect": func(state, side, eid, card, targets):
							return NRDamage.damage(state, side, eid, "meat", 1),
					},
					])
					return NREid.wait_for(state, eid, func(ne):
						NRInstalling.runner_install(state, side, ne, NRCardXlate.first_target(targets), {
						"cost-bonus": -2,
						"msg-keys": {
							"include-cost-from-eid": eid,
							"install-source": card,
						},
					})
					, func(async_result):
						(func():
						unregister_event_by_uuid(state, side, NRCardXlate.getk(NRUtil.first_of(evs), "uuid", null))
						return NREid.effect_completed(state, side, eid)
					).call())
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Valencia Estevez: The Angel of Cayambe", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 50,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "The Corp starts the game with 1 bad publicity.",
		"code": "07030",
		"title": "Valencia Estevez: The Angel of Cayambe",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"req": func(state, side, eid, card, targets): return (((side == "runner") or NRUtil.kw_eq(side, "runner")) and (NRUtil.count_bad_pub(state) == 0)),
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain(state, "corp", "bad-publicity", 1),
		},
		],
	}))

	NRCardDefs.defcard("Virtual Intelligence, P.I.: \"You Can Call Me Vic\"", NRCardXlate.merge_cdef({
		"title": "Virtual Intelligence, P.I.: \"You Can Call Me Vic\"",
	}, {
		"abilities": [
			{
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 1)],
			"action": true,
			"once": "per-turn",
			"label": "Draw 1 card and remove 1 tag.",
			"msg": func(state, side, eid, card, targets): return str(("draw 1 card and remove 1 tag" if NRUtil.is_tagged(state) else "draw 1 card")),
			"async": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRUtil.is_tagged(state) or (not NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).is_empty())),
			},
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.play_sfx(state, side, "vic")
				return NREid.wait_for(state, eid, func(ne):
					NRDrawing.draw(state, side, ne, 1, {
					"suppress-checkpoint": true,
				})
				, func(async_result):
					NRTags.lose_tags(state, side, eid, 1))
			).call() if NRUtil.is_tagged(state) else (func():
				NRSay.play_sfx(state, side, "click-card")
				return NRDrawing.draw(state, side, eid, 1)
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Weyland Consortium: Because We Built It", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "1[recurring-credit]\nUse this credit to advance ice.",
		"code": "02076",
		"title": "Weyland Consortium: Because We Built It",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (func():
					var ab_target = NRCardXlate.getk(NREid.get_ability_targets(eid), "card", null)
					return (NRCard.ice(ab_target) and ((("advance" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("advance", NRCardXlate.getk(eid, "source-type", null))) or NREid.is_basic_advance_action(eid)))
				).call(),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Weyland Consortium: Builder of Nations", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 12,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "The first time each turn an encounter with an advanced piece of ice ends, do 1 meat damage.",
		"code": "11038",
		"title": "Weyland Consortium: Builder of Nations",
	}, {
		"implementation": "[Erratum] The first time an encounter with a piece of ice with at least 1 advancement counter ends each turn, do 1 meat damage.",
		"events": [
			{
			"event": "end-of-encounter",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and (NRCard.get_counters(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "advancement") > 0) and NREvents.first_event(state, "runner", "end-of-encounter", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and (NRCard.get_counters(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "advancement") > 0))
			).call())),
			"msg": "do 1 meat damage",
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "meat", 1, {
				"card": card,
			}),
		},
		],
	}))

	NRCardDefs.defcard("Weyland Consortium: Building a Better World", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Whenever you play a <strong>transaction</strong> operation, gain 1[Credits].",
		"code": "31070",
		"title": "Weyland Consortium: Building a Better World",
	}, {
		"events": [
			{
			"event": "play-operation",
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "Transaction"),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Weyland Consortium: Built to Last", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Corp",
		"faction": "Weyland Consortium",
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Megacorp",
		"subtypes": ["Megacorp"],
		"text": "Whenever you advance a card, gain 2[Credits] if it had no advancement counters.",
		"code": "30059",
		"title": "Weyland Consortium: Built to Last",
	}, {
		"events": [
			{
			"event": "advance",
			"async": true,
			"req": func(state, side, eid, card, targets): return (func(_x): return not pos_p.call(_x)).call((NRCard.get_counters(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "advancement") - NRCardXlate.getk(NRCardXlate.ctx(targets), "amount", 0))),
			"msg": "gain 2 [Credits]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 2),
		},
		],
	}))

	NRCardDefs.defcard("Whizzard: Master Gamer", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 45,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Natural",
		"subtypes": ["Natural"],
		"text": "3[recurring-credit]\nUse these credits to trash cards.",
		"code": "02001",
		"title": "Whizzard: Master Gamer",
	}, {
		"recurring": 3,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-trash-corp-cards" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-trash-corp-cards", NRCardXlate.getk(eid, "source-type", null))) and NRCard.corp(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Wyvern: Chemically Enhanced", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Anarch",
		"baselink": 0,
		"minimumdecksize": 30,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "G-mod",
		"subtypes": ["G-mod"],
		"text": "Draft format only.\nYou must maintain the order of your heap.\nWhenever you trash a Corp card, if you have more [anarch] cards installed than any other faction, shuffle the top card of your heap into your stack.",
		"code": "00007",
		"title": "Wyvern: Chemically Enhanced",
	}, {
		"events": [
			{
			"event": "pre-start-game",
			"effect": draft_points_target,
		},
			{
			"event": "runner-trash",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (has_most_faction_p(state, "runner", "Anarch") and NRCard.corp(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null))),
			"effect": func(state, side, eid, card, targets):
				return shuffle_cards_into_deck_bang(state, "runner", card, [NRUtil.last_of(NRCardXlate.getk(state.getv("runner", {}), "discard", null))]),
		},
		],
	}))

	NRCardDefs.defcard("Zahya Sadeghi: Versatile Smuggler", NRCardXlate.merge_cdef({
		"type": "Identity",
		"side": "Runner",
		"faction": "Criminal",
		"baselink": 0,
		"influencelimit": 15,
		"minimumdecksize": 40,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Cyborg",
		"subtypes": ["Cyborg"],
		"text": "Once per turn → When a run on HQ or R&D ends, you may gain 1[Credits] for each time you accessed a card during that run.",
		"code": "30010",
		"title": "Zahya Sadeghi: Versatile Smuggler",
	}, {
		"events": [
			{
			"event": "run-ends",
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["hq", "rd"], NRServers.target_server(NRCardXlate.ctx(targets))) and (total_cards_accessed(NRCardXlate.ctx(targets)) > 0)),
				"prompt": "Gain 1 [Credits] for each card you accessed?",
				"once": "per-turn",
				"yes-ability": {
					"msg": func(state, side, eid, card, targets): return str("gain ") + str(total_cards_accessed(NRCardXlate.ctx(targets))) + str(" [Credits]"),
					"once": "per-turn",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRGaining.gain_credits(state, "runner", eid, total_cards_accessed(NRCardXlate.ctx(targets))),
				},
			},
		},
		],
	}))


