class_name NRCardsPrograms
extends RefCounted

## Port of game.cards.programs — translated from Jinteki.net Clojure.
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
	_register_7()


static func power_counter_break(ice_type):
	return NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 4,
			},
		},
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("power", 1)], 2, ice_type),
			NRCardXlate.strength_pump(1, 1),
		],
	})


static func swap_with_in_hand(card_name, break_req):
	return NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", break_req),
			NRCardXlate.strength_pump(1, 1),
			{
			"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Deva"))).is_empty()),
			"label": "Swap with a deva program from the grip",
			"cost": [NRPayment.to_c("credit", 2)],
			"prompt": (str("Choose a deva program to swap with ") + str(card_name)),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.has_subtype(_pct, "Deva")),
			},
			"msg": func(state, side, eid, card, targets): return str("swap in ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the grip"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return swap_cards_async(state, side, eid, card, NRCardXlate.first_target(targets)),
		},
		],
	})


static func install_from_heap(title, ice_type, abilities):
	return {
		"abilities": abilities,
		"highlight-in-discard": true,
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"async": true,
			"location": "discard",
			"req": func(state, side, eid, card, targets): return (NRCard.in_discard(card) and NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), ice_type) and NRInstalling.runner_can_pay_and_install(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, {
				"no-toast": true,
			})),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"req": func(state, side, eid, card, targets): return ((not (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")), func(_pct, _pct2=null, _pct3=null): return (((title == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(title, NRCardXlate.getk(_pct, "title", null))) and NRUtil.get_in(_pct, ["special", "heap-breaker-dont-install"], null))) != null)) and (not (state.get_in([
					"run",
					"register",
					str((str("conspiracy-") + str(title))),
					NRCardXlate.getk(NRIce.get_current_ice(state), "cid", null),
				], null)))),
				"prompt": (str("Install ") + str(title) + str(" from the heap?")),
				"choices": func(state, side, eid, card, targets):
					return [
					"Yes",
					"No",
					((str("Don't ask again while ") + str(title) + str(" is installed")) if (NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return ((title == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(title, NRCardXlate.getk(_pct, "title", null))))).size() > 0) else null),
				],
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, ({
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRInstalling.runner_install(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, {
						"msg-keys": {
							"install-source": card,
							"display-origin": true,
						},
					}),
				} if ((NRCardXlate.first_target(targets) == "Yes") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Yes")) else ({
					"effect": func(state, side, eid, card, targets):
						return state.assoc_in([
						"run",
						"register",
						str((str("conspiracy-") + str(title))),
						NRCardXlate.getk(NRIce.get_current_ice(state), "cid", null),
					], true),
				} if ((NRCardXlate.first_target(targets) == "No") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "No")) else {
					"effect": func(state, side, eid, card, targets):
						return (func():
						var heap_breakers = NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return ((title == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq(title, NRCardXlate.getk(_pct, "title", null))))
						return NRUtil.as_array(NRUtil.as_array(heap_breakers).map(func(_pct, _pct2=null, _pct3=null): return NRUpdate.update_card(state, side, NRUtil.assoc_in(_pct if _pct is Dictionary else {}, ["special", "heap-breaker-dont-install"], "true"))))
					).call(),
				})), card, targets),
			}, card, targets),
		},
		],
	}


static func trojan(_p, cdef):
	return NRUtil.assoc_in(cdef if cdef is Dictionary else {}, ["hosting", "req"], func(state, side, eid, card, targets):
		return (NRCard.ice(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets)) and ((not (rezzed)) or NRCard.rezzed(NRCardXlate.first_target(targets))) and ((not (host_req)) or host_req(state, side, eid, card, targets))))


static func pump_and_break(cost, strength, subtype):
	return NRUtil.merge(NREngine.dissoc_req(NRCardXlate.break_sub(cost, strength, subtype)) if NREngine.dissoc_req(NRCardXlate.break_sub(cost, strength, subtype)) is Dictionary else {}, {
		"label": (str("add ") + str(strength) + str(" strength and ") + str(" break up to ") + str(NRUtil.quantify(strength, (str(subtype) + str(" subroutine"))))),
		"heap-breaker-pump": strength,
		"heap-breaker-break": strength,
		"cost": cost,
		"msg": func(state, side, eid, card, targets): return str("increase its strength from ") + str(NRIce.get_strength(card)) + str(" to ") + str((strength + NRIce.get_strength(card))),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			NRIce.pump(state, side, card, strength)
			return NREngine.continue_ability(state, side, NRCardXlate.break_sub(null, strength, subtype, {
			"repeatable": false,
		}), NRCard.get_card(state, card), null),
		"pump": strength,
	} if {
		"label": (str("add ") + str(strength) + str(" strength and ") + str(" break up to ") + str(NRUtil.quantify(strength, (str(subtype) + str(" subroutine"))))),
		"heap-breaker-pump": strength,
		"heap-breaker-break": strength,
		"cost": cost,
		"msg": func(state, side, eid, card, targets): return str("increase its strength from ") + str(NRIce.get_strength(card)) + str(" to ") + str((strength + NRIce.get_strength(card))),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			NRIce.pump(state, side, card, strength)
			return NREngine.continue_ability(state, side, NRCardXlate.break_sub(null, strength, subtype, {
			"repeatable": false,
		}), NRCard.get_card(state, card), null),
		"pump": strength,
	} is Dictionary else {})


static func heap_breaker_auto_pump_and_break(_a=null, _b=null, _c=null, _d=null):
	return null


static func mu_based_strength(abilities):
	return {
		"abilities": abilities,
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRMemory.available_mu(state)),
		],
	}


static func break_multiple_types(first_qty, first_type, second_qty, second_type):
	return NRCardXlate.break_sub(2, func(state, side, eid, card, targets):
		return (first_qty if NRCard.has_subtype(NRIce.get_current_ice(state), first_type) else (second_qty if NRCard.has_subtype(NRIce.get_current_ice(state), second_type) else push_error(str(ex_info("What are we encountering?", NRIce.get_current_ice(state)))))), hash_set(first_type, second_type), {
		"label": (str("break ") + str(NRUtil.quantify(first_qty, (str(first_type) + str(" subroutine")))) + str(" or ") + str(NRUtil.quantify(second_qty, (str(second_type) + str(" subroutine"))))),
	})


static func give_ice_subtype(cost, ice_type, abilities):
	return NRCardXlate.auto_icebreaker({
		"abilities": abilities,
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"req": func(state, side, eid, card, targets): return (NREngine.not_used_once(state, {
				"once": "per-turn",
			}, card) and (not (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), ice_type))) and NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", 2)])),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": (str("Pay ") + str(cost) + str(" [Credits] to make ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)) + str(" gain ") + str(ice_type) + str("?")),
					"yes-ability": {
						"cost": [NRPayment.to_c("credit", cost)],
						"msg": func(state, side, eid, card, targets): return str("make ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) + str(" gain ") + str(ice_type),
						"effect": func(state, side, eid, card, targets):
							register_once(state, side, {
							"once": "per-turn",
						}, card)
							return NREffects.register_lingering_effect(state, side, card, (func():
							var ice = NRIce.get_current_ice(state)
							return {
								"type": "gain-subtype",
								"duration": "end-of-encounter",
								"req": func(state, side, eid, card, targets): return NRUtil.same_card(ice, NRCardXlate.first_target(targets)),
								"value": ice_type,
							}
						).call()),
					},
				},
			}, card, null),
		},
		],
	})


static func virus_breaker(ice_type):
	return NRCardXlate.auto_icebreaker({
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.system_msg(state, side, (str("places 1 virus counter on ") + str(NRCardXlate.getk(card, "title", null))))
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("any-virus-counter", 1)], 1, ice_type),
			NRCardXlate.strength_pump([NRPayment.to_c("any-virus-counter", 1)], 1),
		],
	})


static func central_only(_break, pump):
	return NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(NRCardXlate.getk(_break, "break-cost", null), NRCardXlate.getk(_break, "break", null), NRCardXlate.getk(_break, "breaks", null), {
			"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["hq", "rd", "archives"], NRServers.target_server(state.getv("run"))) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card)) and NRCard.has_subtype(NRIce.get_current_ice(state), NRUtil.first_of(NRCardXlate.getk(_break, "breaks", null)))),
		}),
			NRIce.pump,
		],
	})


static func return_and_derez(_break, pump):
	return (func():
		var ice_type = NRUtil.first_of(NRCardXlate.getk(_break, "breaks", null))
		return NRCardXlate.auto_icebreaker({
			"abilities": [
				_break,
				NRIce.pump,
				{
				"label": (str("Derez ") + str(ice_type) + str(" being encountered")),
				"cost": [NRPayment.to_c("credit", 2), NRPayment.to_c("return-to-hand")],
				"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state)) and NRCard.has_subtype(NRIce.get_current_ice(state), ice_type) and all_subs_broken_by_card_p(NRIce.get_current_ice(state), card)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRezzing.derez(state, side, eid, NRIce.get_current_ice(state), {
					"msg-keys": {
						"include-cost-from-eid": eid,
					},
				}),
			},
			],
		})
	).call()


static func trash_to_bypass(_break, pump):
	return (func():
		var ice_type = NRUtil.first_of(NRCardXlate.getk(_break, "breaks", null))
		return NRCardXlate.auto_icebreaker({
			"abilities": [
				_break,
				NRIce.pump,
				{
				"label": (str("Bypass ") + str(ice_type) + str(" being encountered")),
				"cost": [NRPayment.to_c("trash-can")],
				"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and NRCard.has_subtype(NRIce.get_current_ice(state), ice_type)),
				"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
				"effect": func(state, side, eid, card, targets):
					NRCardXlate.bypass_ice(state)
					return _continue(state, "runner", null),
			},
			],
		})
	).call()


static func cloud_icebreaker(cdef):
	return NRUtil.merge(cdef if cdef is Dictionary else {}, {})


static func break_and_enter(ice_type):
	return NRCardXlate.auto_icebreaker(cloud_icebreaker({
		"abilities": [NRCardXlate.break_sub([NRPayment.to_c("trash-can")], 3, ice_type)],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker"))).size()),
		],
	}))


static func global_sec_breaker(ice_type):
	return cloud_icebreaker(NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 0, ice_type), NRCardXlate.strength_pump(2, 3)],
	}))


static func _register_1() -> void:
	NRCardDefs.defcard("Abaasy", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "The first time each turn this program fully breaks a piece of ice, you may trash 1 card from your grip to draw 1 card.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "33070",
		"title": "Abaasy",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(2, 2)],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NREvents.first_event(state, side, "subroutines-broken", func(_pct, _pct2=null, _pct3=null): return all_subs_broken_by_card_p(NRCardXlate.getk(NRUtil.first_of(_pct), "ice", null), card))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose 1 card in the grip to trash",
				"waiting-prompt": true,
				"async": true,
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and NRCard.runner(_pct)),
				},
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to draw 1 card"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
					"unpreventable": true,
					"cause-card": card,
				})
				, func(async_result):
					NRDrawing.draw(state, "runner", eid, 1)),
			}, card, null),
		},
		],
	})))

	NRCardDefs.defcard("Abagnale", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.\n[Trash]<strong>:</strong> Bypass the <strong>code gate</strong> you are encountering.",
		"code": "31021",
		"title": "Abagnale",
	}, trash_to_bypass(NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(2, 2))))

	NRCardDefs.defcard("Adept", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter - Killer",
		"subtypes": ["Icebreaker", "Fracter", "Killer"],
		"text": "This program gets +1 strength for each unused MU.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> or <strong>barrier</strong> subroutine.",
		"code": "13017",
		"title": "Adept",
	}, mu_based_strength([break_multiple_types(1, "Barrier", 1, "Sentry")])))

	NRCardDefs.defcard("Afterimage", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Once per turn → When you encounter a <strong>sentry</strong>, you may pay 2[Credits] to bypass it. Spend credits only from <strong>stealth</strong> cards to use this ability.\nInterface → <strong>1[Credits]:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>1[Credits]:</strong> +2 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "26079",
		"title": "Afterimage",
	}, NRCardXlate.auto_icebreaker({
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Sentry") and NRPayment.can_pay(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source-type": "ability"}), card, null, [NRPayment.to_c("credit", 2, {
					"stealth": "all-stealth",
				})])),
				"once": "per-turn",
				"prompt": func(state, side, eid, card, targets): return str("Pay 2 [Credits] to bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)) + str("?"),
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 2, {
						"stealth": "all-stealth",
					})],
					"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
					"effect": func(state, side, eid, card, targets):
						return NRCardXlate.bypass_ice(state),
				},
			},
		},
		],
		"abilities": [
			NRCardXlate.break_sub(1, 2, "Sentry"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 1, {
			"stealth": "all-stealth",
		}), 2, "end-of-encounter"),
		],
	})))

	NRCardDefs.defcard("Aghora", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Icebreaker - AI - Deva",
		"subtypes": ["Icebreaker", "AI", "Deva"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice that has a rez cost of 5 or greater.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>2[Credits]:</strong> Swap this program with a <strong>deva</strong> program from your grip.",
		"code": "10097",
		"title": "Aghora",
	}, swap_with_in_hand("Aghora", {
		"req": func(state, side, eid, card, targets): return ((5 <= value(NRUtil.first_of(NRRezzing.get_rez_cost(state, side, NRIce.get_current_ice(state), null)))) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
	})))

	NRCardDefs.defcard("Algernon", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Adam",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 5,
		"uniqueness": true,
		"text": "When your turn begins, you may pay 2[Credits] to gain [Click]. If you do, trash Algernon when your turn ends if you did not make a successful run this turn.",
		"code": "22022",
		"title": "Algernon",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"skippable": true,
			"optional": {
				"prompt": "Pay 2 [Credits] to gain [Click]?",
				"req": func(state, side, eid, card, targets): return NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), card, null, [NRPayment.to_c("credit", 2)]),
				"yes-ability": {
					"cost": [NRPayment.to_c("credit", 2)],
					"msg": "gain [Click]",
					"effect": func(state, side, eid, card, targets):
						NRGaining.gain_clicks(state, "runner", 1)
						return NRUpdate.update_card(state, "runner", NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "used-algernon"], true)),
				},
			},
		},
			{
			"event": "runner-turn-ends",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRUpdate.update_card(state, "runner", NRUtil.dissoc_in(card, ["special", "used-algernon"]))
				return ((func():
					NRSay.system_msg(state, "runner", "trashes Algernon because a successful run did not occur")
					return NRMoving.trash(state, "runner", eid, card, {
						"cause-card": card,
					})
				).call() if (not (NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null))) else NREid.effect_completed(state, side, eid))
			).call() if NRUtil.get_in(card, ["special", "used-algernon"], null) else NREid.effect_completed(state, side, eid)),
		},
		],
	}))

	NRCardDefs.defcard("Alias", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.\nThis program cannot interface with ice protecting a remote server.",
		"code": "05041",
		"title": "Alias",
	}, central_only(NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(2, 3))))

	NRCardDefs.defcard("Alpha", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 7,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nThis program can only interface with the outermost piece of ice protecting a server.",
		"code": "04087",
		"title": "Alpha",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"req": func(state, side, eid, card, targets): return (func():
				var server_ice = NRCardXlate.getk(card_to_server(state, NRIce.get_current_ice(state)), "ices", null)
				return NRUtil.same_card(NRIce.get_current_ice(state), NRUtil.last_of(server_ice))
			).call(),
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Amina", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 7,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>2[Credits]:</strong> Break up to 3 <strong>code gate</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.\nThe first time each turn this program fully breaks a piece of ice, the Corp loses 1[Credits].",
		"code": "21104",
		"title": "Amina",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 3, "Code Gate"), NRCardXlate.strength_pump(2, 3)],
		"events": [
			{
			"event": "end-of-encounter",
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NREvents.first_event(state, side, "end-of-encounter", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card)
			).call())),
			"msg": "make the Corp lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "corp", eid, 1),
		},
		],
	})))

	NRCardDefs.defcard("Analog Dreamers", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "<strong>[Click]:</strong> Run R&D. If successful, instead of breaching R&D, you may choose 1 unrezzed non-ice card with no advancement counters on it. The Corp shuffles that card into R&D.",
		"code": "08048",
		"title": "Analog Dreamers",
	}, (func():
		var ability = NRCardXlate.successful_run_replace_breach({
			"target-server": "rd",
			"duration": "end-of-run",
			"ability": {
				"prompt": "Choose a card to shuffle into R&D",
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return ((not (NRCard.ice(_pct))) and (not (NRCard.faceup(_pct))) and (NRCard.get_counters(_pct, "advancement") == 0)),
				},
				"msg": func(state, side, eid, card, targets): return str("shuffle ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))) + str(" into R&D"),
				"effect": func(state, side, eid, card, targets):
					NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "deck")
					return NRShuffling.shuffle_zone(state, "corp", "deck"),
			},
		})
		return {
			"abilities": [
				NRCardXlate.run_server_ability("rd", {
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"events": [ability],
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Ankusa", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 6,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Whenever this program fully breaks a <strong>barrier</strong>, add that <strong>barrier</strong> to HQ.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "10101",
		"title": "Ankusa",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Barrier"), NRCardXlate.strength_pump(1, 1)],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Barrier") and all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card)),
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)) + str(" to HQ after breaking all its subroutines"),
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, "corp", NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "hand", null)
				return _continue(state, "runner", null),
		},
		],
	})))

	NRCardDefs.defcard("Atman", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "When you install this program, you may spend any number of credits to place that many power counters on it.\nThis program gets +1 strength for each hosted power counter, and it can only interface with ice of exactly equal strength.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine.",
		"code": "31030",
		"title": "Atman",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"cost": [NRPayment.to_c("x-credits")],
			"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(NRPayment.cost_value(eid, "x-credits"), "power counter")) + str(" on itself"),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", NRPayment.cost_value(eid, "x-credits"), null),
		},
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"req": func(state, side, eid, card, targets): return ((NRIce.get_strength(NRIce.get_current_ice(state)) == NRIce.get_strength(card)) or NRUtil.kw_eq(NRIce.get_strength(NRIce.get_current_ice(state)), NRIce.get_strength(card))),
		}),
		],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
		],
	})))

	NRCardDefs.defcard("Au Revoir", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Gain 1[Credits] whenever you jack out.",
		"code": "06119",
		"title": "Au Revoir",
	}, {
		"events": [
			{
			"event": "jack-out",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
			"msg": "gain 1 [Credits]",
		},
		],
	}))

	NRCardDefs.defcard("Audrey v2", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 0,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Virus",
		"subtypes": ["Icebreaker", "AI", "Virus"],
		"text": "Whenever you trash a card you are accessing, place 1 virus counter on this program.\nInterface → <strong>Hosted virus counter:</strong> Break up to 2 subroutines.\n<strong>Trash 1 card from your grip:</strong> +3 strength.",
		"code": "34004",
		"title": "Audrey v2",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("virus", 1)], 2),
			NRCardXlate.strength_pump([NRPayment.to_c("trash-from-hand", 1)], 3),
		],
		"events": [
			{
			"event": "runner-trash",
			"once-per-instance": true,
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(NRCardXlate.first_target(targets), "accessed", null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "virus", 1, null),
			"msg": "place 1 virus counter on itself",
		},
		],
	})))

	NRCardDefs.defcard("Aumakua", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Virus",
		"subtypes": ["Icebreaker", "AI", "Virus"],
		"text": "This program gets +1 strength for each hosted virus counter.\nWhenever you expose a card, place 1 virus counter on this program.\nWhenever you finish breaching a server, if you did not steal or trash any accessed cards, place 1 virus counter on this program.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine.",
		"code": "12104",
		"title": "Aumakua",
	}, NRCardXlate.auto_icebreaker({
		"implementation": "[Erratum] Whenever you finish breaching a server, if you did not steal or trash any accessed cards, place 1 virus counter on this program.",
		"abilities": [
			NRCardXlate.break_sub(1, 1),
			{
			"label": "Place 1 virus counter",
			"msg": "manually place 1 virus counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRVirus.get_virus_counters(state, card)),
		],
		"events": [
			{
			"event": "end-breach-server",
			"req": func(state, side, eid, card, targets): return (not ((NRCardXlate.getk(NRCardXlate.first_target(targets), "did-steal", null) or NRCardXlate.getk(NRCardXlate.first_target(targets), "did-trash", null)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
			{
			"event": "expose",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)).size(), null),
		},
		],
	})))

	NRCardDefs.defcard("Aurora", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "20027",
		"title": "Aurora",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Barrier"), NRCardXlate.strength_pump(2, 3)],
	})))

	NRCardDefs.defcard("Azimat", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 2,
		"factioncost": 1,
		"uniqueness": false,
		"text": "2[recurring-credit] <em>(When you install this program and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to pay trash costs.",
		"code": "35029",
		"title": "Azimat",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (("runner-trash-corp-cards" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-trash-corp-cards", NRCardXlate.getk(eid, "source-type", null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Baba Yaga", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 5,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "You may host any number of non-<strong>AI</strong> <strong>icebreaker</strong> programs on this program.\nThis program gains the paid abilities of all hosted <strong>icebreaker</strong> programs.",
		"code": "11088",
		"title": "Baba Yaga",
	}, (func():
		var gain_abis = func(state, side, eid, card, targets):
			return (func():
			var new_abis = mapcat(ability_init, NRCardXlate.getk(card, "hosted", null))
			return NRUpdate.update_card(state, "runner", NRUtil.merge(card if card is Dictionary else {}, {"abilities": new_abis}))
		).call()
		return {
			"static-abilities": [
				{
				"type": "can-host",
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker") and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "AI")))),
			},
			],
			"hosted-gained": gain_abis,
			"hosted-lost": gain_abis,
		}
	).call()))

	NRCardDefs.defcard("Baker", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Once per turn → [Click]<strong>:</strong> Run Archives. When you would approach Archives <em>(after passing all ice)</em>, you may pay 1[Credits] to instead change the attacked server to HQ or R&D and approach that server. Spend credits only from <strong>stealth</strong> cards to pay this cost.",
		"code": "36015",
		"title": "Baker",
	}, (func():
		return {
			"abilities": [
				NRCardXlate.run_server_ability("archives", {
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"once": "per-turn",
				"events": [
					NRChooseOne.choose_one({
					"event": "pre-approach-server",
					"req": func(state, side, eid, card, targets): return (("archives" == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq("archives", NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
					"duration": "end-of-run",
					"unregister-once-resolved": true,
					"interactive": func(state, side, eid, card, targets):
						return true,
					"optional": true,
				}, [switch_server("hq", "HQ"), switch_server("rd", "R&D")]),
				],
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Bankroll", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you make a successful run, you may place 1[Credits] from the bank on Bankroll.\n[Trash]: Take all credits from Bankroll.",
		"code": "22011",
		"title": "Bankroll",
	}, {
		"special": {
			"auto-place-credit": "always",
		},
		"events": [
			{
			"event": "successful-run",
			"optional": {
				"req": func(state, side, eid, card, targets): return (not ((("Jak Sinclair" == NRUtil.get_in(state.getv("run"), ["source-card", "title"], null)) or NRUtil.kw_eq("Jak Sinclair", NRUtil.get_in(state.getv("run"), ["source-card", "title"], null))))),
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-place-credit"),
				"prompt": func(state, side, eid, card, targets): return str("Place 1 credit on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "credit", 1, null),
				},
			},
		},
		],
		"abilities": [
			{
			"label": "Take all hosted credits",
			"async": true,
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "credit") > 0),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRCard.get_counters(card, "credit")) + str(" [Credits]"),
			"cost": [NRPayment.to_c("trash-can")],
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, NRCard.get_counters(card, "credit")),
		},
			NROptional.set_autoresolve("auto-place-credit", "Bankroll placing credits on itself"),
		],
	}))

	NRCardDefs.defcard("Banner", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 5,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter - Weapon",
		"subtypes": ["Icebreaker", "Fracter", "Weapon"],
		"text": "Interface → <strong>2[Credits]:</strong> Subroutines on the <strong>barrier</strong> you are encountering cannot end the run for the remainder of this encounter.",
		"code": "34005",
		"title": "Banner",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			{
			"label": "Prevent barrier subroutines from ending the run this encounter",
			"cost": [NRPayment.to_c("credit", 2)],
			"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card)) and NRCard.has_subtype(NRIce.get_current_ice(state), "Barrier")),
			"msg": func(state, side, eid, card, targets): return str("prevent ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str(" from ending the run this encounter"),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var target_ice = NRCardXlate.getk(NRRuns.get_current_encounter(state), "ice", null)
				return NREngine.register_events(state, side, card, [
					{
					"event": "can-run-be-ended?",
					"duration": "end-of-encounter",
					"async": true,
					"silent": true,
					"req": func(state, side, eid, card, targets): return (("subroutine" == NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "source-eid", null), "source-type", null)) or NRUtil.kw_eq("subroutine", NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "source-eid", null), "source-type", null))),
					"msg": "prevent the run from ending",
					"effect": func(state, side, eid, card, targets):
						return NRPrevention.prevent_end_run(state, side, eid),
				},
				])
			).call(),
		},
		],
	})))

	NRCardDefs.defcard("Battering Ram", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"strength": 3,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength for the remainder of this run.",
		"code": "25052",
		"title": "Battering Ram",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(2, 2, "Barrier"),
			NRCardXlate.strength_pump(1, 1, "end-of-run"),
		],
	})))

	NRCardDefs.defcard("Begemot", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "When you install this program, suffer 1 core damage.\nThis program gets +1 strength for each core damage you have taken this game.\nInterface → <strong>1[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.",
		"code": "33007",
		"title": "Begemot",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDamage.damage(state, side, eid, "brain", 1, {
				"card": card,
			}),
		},
		"abilities": [NRCardXlate.break_sub(1, 0, "Barrier")],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCardXlate.getk(state.getv("runner", {}), "brain-damage", null)),
		],
	})))

	NRCardDefs.defcard("Berserker", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Whenever you encounter a <strong>barrier</strong>, for the remainder of that encounter this program gets +1 strength for each subroutine on that <strong>barrier</strong>.\nInterface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.",
		"code": "12041",
		"title": "Berserker",
	}, NRCardXlate.auto_icebreaker({
		"events": [
			{
			"event": "encounter-ice",
			"req": func(state, side, eid, card, targets): return NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Barrier"),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "subroutines", null)).size()) + str(" strength"),
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, card, NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "subroutines", null)).size()),
		},
		],
		"abilities": [NRCardXlate.break_sub(2, 2, "Barrier")],
	})))

	NRCardDefs.defcard("Bishop", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Caïssa - Trojan",
		"subtypes": ["Caïssa", "Trojan"],
		"text": "Host ice gets -2 strength.\n[Click]: Host this program on a piece of ice that is not hosting a <strong>Caïssa</strong> program.\nIf this program is hosted on ice protecting a central server, its [Click] ability can only be used to host it on ice protecting a remote server. If this program is hosted on ice protecting a remote server, its [Click] ability can only be used to host it on ice protecting a central server.",
		"code": "04021",
		"title": "Bishop",
	}, {
		"implementation": "[Erratum] Program: Caïssa - Trojan",
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Host on another piece of ice",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var b = NRCard.get_card(state, card)
				var hosted_p = NRCard.ice(NRCardXlate.getk(b, "host", null))
				var remote_p = NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(b, "host", null)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.getk(b, "host", null))).size() > 1 else null))
				return NREngine.continue_ability(state, side, {
					"prompt": func(state, side, eid, card, targets): return str("Choose a piece of ice protecting ") + str((("a central" if remote_p else "a remote") if hosted_p else "any")) + str(" server"),
					"choices": {
						"card": func(_pct, _pct2=null, _pct3=null): return (((NRServers.is_central((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null)) if remote_p else NRServers.is_remote((NRUtil.as_array(NRCard.get_zone(_pct))[1] if NRUtil.as_array(NRCard.get_zone(_pct)).size() > 1 else null))) and NRCard.ice(_pct) and NRFlags.can_host(state, _pct) and ((NRUtil.last_of(NRCard.get_zone(_pct)) == "ices") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(_pct)), "ices")) and (not (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(_pct, "hosted", null)), func(c): return NRCard.has_subtype(c, "Caïssa")) != null))) if hosted_p else (NRCard.ice(_pct) and NRFlags.can_host(state, _pct) and ((NRUtil.last_of(NRCard.get_zone(_pct)) == "ices") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(_pct)), "ices")) and (not (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(_pct, "hosted", null)), func(c): return NRCard.has_subtype(c, "Caïssa")) != null)))),
					},
					"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
				}, card, null)
			).call(),
		},
		],
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return (((NRCardXlate.getk(NRCardXlate.first_target(targets), "cid", null) == NRCardXlate.getk(NRCardXlate.getk(card, "host", null), "cid", null)) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "cid", null), NRCardXlate.getk(NRCardXlate.getk(card, "host", null), "cid", null))) and NRCardXlate.getk(NRCardXlate.first_target(targets), "rezzed", null)),
			"value": -2,
		},
		],
	}))

	NRCardDefs.defcard("Black Orchestra", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Whenever you encounter a <strong>code gate</strong>, you may install this program from your heap.\n<strong>3[Credits]:</strong> +2 strength. Then, if this program can interface with the <strong>code gate</strong> you are encountering, break up to 2 subroutines.",
		"code": "11042",
		"title": "Black Orchestra",
	}, (func():
		var events = NRUtil.as_array([
			"run",
			"approach-ice",
			"encounter-ice",
			"pass-ice",
			"run-ends",
			"ice-strength-changed",
			"ice-subtype-changed",
			"breaker-strength-changed",
			"subroutines-changed",
		]).map(func(event): return NRUtil.merge(heap_breaker_auto_pump_and_break if heap_breaker_auto_pump_and_break is Dictionary else {}, {"event": event}))
		var cdef = install_from_heap("Black Orchestra", "Code Gate", [pump_and_break([NRPayment.to_c("credit", 3)], 2, "Code Gate")])
		return NRUtil.merge(cdef if cdef is Dictionary else {}, {"events": conj.callv(NRUtil.as_array(NRCardXlate.getk(cdef, "events", null)))})
	).call()))

	NRCardDefs.defcard("BlacKat", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine. If you spent a credit from a <strong>stealth</strong> card to use this ability, instead break up to 3 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +1 strength. If you spent at least 1 credit from a <strong>stealth</strong> card to use this ability, instead +2 strength.",
		"code": "06053",
		"title": "BlacKat",
	}, NRCardXlate.auto_icebreaker({
		"implementation": "Stealth credit restriction not enforced",
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier"),
			NRCardXlate.break_sub(NRPayment.to_c("credit", 1, {
			"stealth": 1,
		}), 3, "Barrier"),
			NRCardXlate.strength_pump(2, 1),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 2, {
			"stealth": 1,
		}), 2, "end-of-encounter"),
		],
	})))

	NRCardDefs.defcard("Blackstone", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>3[Credits]:</strong> +4 strength for the remainder of this run. Use this ability only by spending at least 1[Credits] from a <strong>stealth</strong> card.",
		"code": "11068",
		"title": "Blackstone",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 3, {
			"stealth": 1,
		}), 4, "end-of-run"),
		],
	})))

	NRCardDefs.defcard("Boi-tatá", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "If you trashed any of your installed cards this turn, paid abilities on this program cost 1[Credits] less to use.\nInterface → <strong>2[Credits]:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>3[Credits]:</strong> +3 strength.",
		"code": "34071",
		"title": "Boi-tatá",
	}, (func():
		var was_a_runner_card_p = func(target): return NRCard.runner(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.first_target(targets)), "card", null))
		var discount_fn = func(state, side, eid, card, targets):
			return ([NRPayment.to_c("credit", -1)] if (not (NREvents.no_event(state, side, "runner-trash", was_a_runner_card_p))) else null)
		return NRCardXlate.auto_icebreaker({
			"abilities": [
				NRCardXlate.break_sub(2, 2, "Sentry", {
				"break-cost-bonus": discount_fn,
			}),
				NRCardXlate.strength_pump(3, 3, "end-of-encounter", {
				"cost-bonus": discount_fn,
			}),
			],
		})
	).call()))

	NRCardDefs.defcard("Botulus", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus - Trojan",
		"subtypes": ["Virus", "Trojan"],
		"text": "Install only on a piece of ice. <em>(If the host ice is uninstalled, this program is trashed.)</em>\nWhen you install this program and when your turn begins, place 1 virus counter on this program.\n<strong>Hosted virus counter:</strong> Break 1 subroutine on host ice.",
		"code": "30004",
		"title": "Botulus",
	}, ({
		"implementation": "[Erratum] Program: Virus - Trojan",
		"data": {
			"counter": {
				"virus": 1,
			},
		},
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("virus", 1)], 1, "All", {
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRIce.get_current_ice(state), NRCardXlate.getk(card, "host", null)),
		}),
		],
	}).call(trojan(NRCardXlate.auto_icebreaker))))

	NRCardDefs.defcard("Brahman", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 3,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 subroutines.\n<strong>2[Credits]:</strong> +1 strength.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, add 1 installed non-<strong>virus</strong> program to the top of your stack.",
		"code": "10062",
		"title": "Brahman",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 2, "All"), NRCardXlate.strength_pump(2, 1)],
		"events": [
			{
			"event": "end-of-encounter",
			"req": func(state, side, eid, card, targets): return any_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"prompt": "Choose a non-virus program to add to the top of the stack",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.program(_pct) and (not (NRCard.facedown(_pct))) and (not (NRCard.has_subtype(_pct, "Virus")))),
			},
			"msg": func(state, side, eid, card, targets): return str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to the top of the stack"),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, NRCard.get_card(state, NRCardXlate.first_target(targets)), "deck", {
				"front": true,
			}),
		},
		],
	})))

	NRCardDefs.defcard("Breach", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>2[Credits]:</strong> Break up to 3 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +4 strength.\nThis program cannot interface with ice protecting a remote server.",
		"code": "05042",
		"title": "Breach",
	}, central_only(NRCardXlate.break_sub(2, 3, "Barrier"), NRCardXlate.strength_pump(2, 4))))

	NRCardDefs.defcard("Bug", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Install only if you made a successful run on HQ this turn.\nWhenever the Corp draws a card, you may pay 2[Credits] to reveal that card.",
		"code": "05043",
		"title": "Bug",
	}, {
		"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq"], _x)) != null),
		"events": [
			{
			"event": "corp-draw",
			"optional": {
				"prompt": "Pay credits to reveal drawn card?",
				"req": func(state, side, eid, card, targets): return (1 < total_available_credits(state, "runner", eid, card)),
				"yes-ability": {
					"prompt": "How many cards do you want to reveal for 2 [Credits] each?",
					"waiting-prompt": true,
					"choices": {
						"number": func(state, side, eid, card, targets):
							return mini(NRCardXlate.getk(NRCardXlate.ctx(targets), "count", null), (total_available_credits(state, "runner", eid, card) / 2)),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var cards = NRUtil.take_n(NRUtil.as_array(keep(func(_pct, _pct2=null, _pct3=null): return NRFinding.find_cid(NRCardXlate.getk(_pct, "cid", null), NRCardXlate.getk(state.getv("corp", {}), "set-aside", null)), shuffle(corp_currently_drawing))), int(NRCardXlate.first_target(targets)))
						return NREid.wait_for(state, eid, func(ne):
							NREngine.pay(state, side, ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("credit", (2 * NRCardXlate.first_target(targets)))])
						, func(async_result):
							(func():
							var payment_str = NRCardXlate.getk(async_result, "msg", null)
							return NREid.wait_for(state, eid, func(ne):
								NRRevealing.reveal(state, side, ne, NREid.make_eid(state, eid), cards)
							, func(async_result):
								(func():
								NRSay.system_msg(state, side, (str(payment_str) + str(" to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to force the Corp to reveal they drew ") + str(NRUtil.enumerate_cards(cards))))
								return NREid.effect_completed(state, side, eid)
							).call())
						).call())
					).call(),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Bukhgalter", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nThe first time each turn this program fully breaks a piece of ice, gain 2[Credits].",
		"code": "26016",
		"title": "Bukhgalter",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(1, 1)],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NREvents.first_event(state, side, "subroutines-broken", func(_pct, _pct2=null, _pct3=null): return all_subs_broken_by_card_p(NRCardXlate.getk(NRUtil.first_of(_pct), "ice", null), card))),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 2),
		},
		],
	})))

	NRCardDefs.defcard("Buzzsaw", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>3[Credits]:</strong> +1 strength.",
		"code": "30005",
		"title": "Buzzsaw",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 2, "Code Gate"), NRCardXlate.strength_pump(3, 1)],
	})))

	NRCardDefs.defcard("Cache", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Place 3 virus counters on Cache when it is installed.\n<strong>Hosted virus counter:</strong> Gain 1[Credits].",
		"code": "29004",
		"title": "Cache",
	}, {
		"abilities": [
			{
			"cost": [NRPayment.to_c("virus", 1)],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
			"keep-menu-open": "while-virus-tokens-left",
			"msg": "gain 1 [Credits]",
		},
		],
		"data": {
			"counter": {
				"virus": 3,
			},
		},
	}))

	NRCardDefs.defcard("Carmen", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "If you made a successful run this turn, this program costs 2[Credits] less to install.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "30015",
		"title": "Carmen",
	}, NRCardXlate.auto_icebreaker({
		"install-cost-bonus": func(state, side, eid, card, targets):
			return (-2 if NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null) else 0),
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(2, 3)],
	})))

	NRCardDefs.defcard("Cerberus \"Cuj.0\" H3", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>Hosted power counter:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "06094",
		"title": "Cerberus \"Cuj.0\" H3",
	}, power_counter_break("Sentry")))

	NRCardDefs.defcard("Cerberus \"Lady\" H1", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>Hosted power counter:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "29006",
		"title": "Cerberus \"Lady\" H1",
	}, power_counter_break("Barrier")))

	NRCardDefs.defcard("Cerberus \"Rex\" H2", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>Hosted power counter:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "06096",
		"title": "Cerberus \"Rex\" H2",
	}, power_counter_break("Code Gate")))


static func _register_2() -> void:
	NRCardDefs.defcard("Cezve", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "2[recurring-credit] <em>(When you install this card and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits during runs on central servers.",
		"code": "33017",
		"title": "Cezve",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(state, "run", null) and NRServers.is_central(NRCardXlate.getk(state.getv("run"), "server", null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Chakana", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on R&D, place 1 virus counter on Chakana.\nIf there are at least 3 virus counters on Chakana, the advancement requirement of all agendas is increased by 1.",
		"code": "03043",
		"title": "Chakana",
	}, {
		"static-abilities": [
			{
			"type": "advancement-requirement",
			"req": func(state, side, eid, card, targets): return (3 <= NRVirus.get_virus_counters(state, card)),
			"value": 1,
		},
		],
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
	}))

	NRCardDefs.defcard("Chameleon", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker",
		"subtypes": ["Icebreaker"],
		"text": "When you install this program, choose <strong>barrier</strong>, <strong>code gate</strong>, or <strong>sentry</strong>.\nWhen your discard phase ends, add this program to your grip.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice that has the chosen subtype.",
		"code": "31031",
		"title": "Chameleon",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"prompt": "Choose one",
			"choices": ["Barrier", "Code Gate", "Sentry"],
			"msg": func(state, side, eid, card, targets): return str("choose ") + str(NRCardXlate.first_target(targets)),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"subtype-target": NRCardXlate.first_target(targets)})),
		},
		"events": [
			{
			"event": "runner-turn-ends",
			"msg": "add itself to Grip",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, card, "hand"),
		},
		],
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"req": func(state, side, eid, card, targets): return (func():
				var subtype = NRCardXlate.getk(card, "subtype-target", null)
				return NRCard.has_subtype(NRIce.get_current_ice(state), subtype) if subtype != null else true
			).call(),
		}),
		],
	})))

	NRCardDefs.defcard("Chisel", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Virus - Trojan",
		"subtypes": ["Virus", "Trojan"],
		"text": "Install only on a piece of ice.\nHost ice gets −1 strength for each hosted virus counter.\nWhenever you encounter host ice, if its strength is 0 or less, trash it. Otherwise, place 1 virus counter on this program.",
		"code": "26003",
		"title": "Chisel",
	}, ({
		"implementation": "[Erratum] Program: Virus - Trojan",
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": func(state, side, eid, card, targets):
				return (-NRVirus.get_virus_counters(state, card)),
		},
		],
		"events": [
			{
			"event": "encounter-ice",
			"automatic": "pre-bypass",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), NRCardXlate.getk(card, "host", null)),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return ((func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to place 1 virus counter on itself")))
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null)
			).call() if (NRIce.ice_strength(state, side, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) > 0) else (func():
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)))))
				return NRMoving.trash(state, side, eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), {
					"cause-card": card,
				})
			).call()),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Chromatophores", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nHost ice gains <strong>barrier</strong>, <strong>code gate</strong>, and <strong>sentry</strong>.",
		"code": "35030",
		"title": "Chromatophores",
	}, ({
		"on-install": {
			"msg": func(state, side, eid, card, targets): return str("make ") + str(NRToString.card_str(state, NRCardXlate.getk(card, "host", null))) + str(" gain Barrier, Code Gate and Sentry subtypes"),
		},
		"static-abilities": [
			{
			"type": "gain-subtype",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": ["Barrier", "Code Gate", "Sentry"],
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Cat's Cradle", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "The rez cost of each piece of <strong>code gate</strong> ice is increased by 1[Credits].\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "33016",
		"title": "Cat's Cradle",
	}, NRCardXlate.auto_icebreaker({
		"static-abilities": [
			{
			"type": "rez-cost",
			"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Code Gate")),
			"value": 1,
		},
		],
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
	})))

	NRCardDefs.defcard("Cleaver", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +1 strength.",
		"code": "30006",
		"title": "Cleaver",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 2, "Barrier"), NRCardXlate.strength_pump(2, 1)],
	})))

	NRCardDefs.defcard("Cloak", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Stealth",
		"subtypes": ["Stealth"],
		"text": "1[recurring-credit]\nUse this credit to pay for using <strong>icebreakers</strong>.",
		"code": "03041",
		"title": "Cloak",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker")),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Clot", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "The Corp cannot score an agenda during the same turn they installed that agenda.\nWhen the Corp purges virus counters, trash this program.",
		"code": "31005",
		"title": "Clot",
	}, {
		"static-abilities": [
			{
			"type": "cannot-score",
			"req": func(state, side, eid, card, targets): return (("this-turn" == NRCard.installed(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null))) or NRUtil.kw_eq("this-turn", NRCard.installed(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)))),
			"value": true,
		},
		],
		"events": [
			trash_on_purge,
			{
			"event": "corp-install",
			"req": func(state, side, eid, card, targets): return NRCard.agenda(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)),
			"effect": func(state, side, eid, card, targets):
				return state.update_in(["corp", "register", "cannot-score"], func(v): return v, 0),
		},
		],
	}))

	NRCardDefs.defcard("Coalescence", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When you install this program, place 2 power counters on it.\n<strong>Hosted power counter:</strong> Gain 2[Credits]. Use this ability only during your turn.",
		"code": "34089",
		"title": "Coalescence",
	}, {
		"abilities": [
			{
			"cost": [NRPayment.to_c("power", 1)],
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(state, "active-player", null) == "runner") or NRUtil.kw_eq(NRCardXlate.getk(state, "active-player", null), "runner")),
			"async": true,
			"keep-menu-open": "while-power-tokens-left",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
			"msg": "gain 2 [Credits]",
		},
		],
		"data": {
			"counter": {
				"power": 2,
			},
		},
	}))

	NRCardDefs.defcard("Collective Consciousness", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Draw 1 card whenever the Corp rezzes a piece of ice.",
		"code": "06116",
		"title": "Collective Consciousness",
	}, {
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)),
			"msg": "draw 1 card",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Conduit", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever a successful run on R&D ends, you may place 1 virus counter on this program.\n[Click]<strong>:</strong> Run R&D. If successful, access X additional cards when you breach R&D. X is equal to the number of hosted virus counters.",
		"code": "30024",
		"title": "Conduit",
	}, {
		"events": [
			{
			"event": "run-ends",
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRCardXlate.getk(NRCardXlate.ctx(targets), "successful", null) and (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets))))),
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-place-counter"),
				"prompt": func(state, side, eid, card, targets): return str("Place 1 virus counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"yes-ability": {
					"msg": "place 1 virus counter on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)) + str(" to place 1 virus counter on itself"))),
				},
			},
		},
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return ((("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))) and NRCardXlate.this_card_run(state, card, targets)),
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, [
				breach_access_bonus("rd", maxi(0, NRVirus.get_virus_counters(state, card)), {
				"duration": "end-of-run",
			}),
			]),
		},
		],
		"abilities": [
			NRCardXlate.run_server_ability("rd", {
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
		}),
			NROptional.set_autoresolve("auto-place-counter", "Conduit placing virus counters on itself"),
		],
	}))

	NRCardDefs.defcard("Consume", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Apex",
		"cost": 2,
		"memoryunits": 0,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you trash a Corp card, you may place 1 virus counter on Consume.\n[Click]: Gain 2[Credits] for each hosted virus counter, then remove all virus counters from Consume.",
		"code": "21068",
		"title": "Consume",
	}, {
		"special": {
			"auto-place-counter": "always",
		},
		"events": [
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
						"prompt": func(state, side, eid, card, targets): return str("Place 1 virus counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
						"autoresolve": NROptional.get_autoresolve("auto-place-counter"),
						"yes-ability": {
							"effect": func(state, side, eid, card, targets):
								return NRProps.add_counter(state, "runner", eid, card, "virus", 1, null),
							"async": true,
							"msg": "place 1 virus counter on itself",
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
					"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "virus counter")) + str(" on itself"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, "runner", eid, card, "virus", NRCardXlate.first_target(targets), null),
				}
				var ab = (sing_ab if ((1 == amt_trashed) or NRUtil.kw_eq(1, amt_trashed)) else mult_ab)
				return NREngine.continue_ability(state, side, ab, card, targets)
			).call(),
		},
		],
		"abilities": [
			{
			"action": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRVirus.get_virus_counters(state, card) > 0),
			},
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Gain 2 [Credits] for each hosted virus counter, then remove all virus counters",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit", (2 * NRVirus.get_virus_counters(state, card)), 3)
				return NREid.wait_for(state, eid, func(ne):
				NRGaining.gain_credits(state, side, ne, (2 * NRVirus.get_virus_counters(state, card)))
			, func(async_result):
				(func():
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["counter", "virus"], 0))
				(func():
					for h in NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return (("Hivemind" == NRCardXlate.getk(_pct, "title", null)) or NRUtil.kw_eq("Hivemind", NRCardXlate.getk(_pct, "title", null))))):
						NRUpdate.update_card(state, side, NRUtil.assoc_in(h if h is Dictionary else {}, ["counter", "virus"], 0))
					return null
				).call()
				return NREid.effect_completed(state, side, eid)
			).call()),
			"msg": func(state, side, eid, card, targets): return str((func():
				var local_virus = NRCard.get_counters(card, "virus")
				var global_virus = NRVirus.get_virus_counters(state, card)
				var hivemind_virus = (global_virus - local_virus)
				return (str("gain ") + str((2 * global_virus)) + str(" [Credits], removing ") + str(NRUtil.quantify(local_virus, "virus counter")) + str(" from itself") + str(((str(" (and ") + str(hivemind_virus) + str(" from Hivemind)")) if (hivemind_virus > 0) else null)))
			).call()),
		},
			NROptional.set_autoresolve("auto-place-counter", "Consume placing virus counters on itself"),
		],
	}))

	NRCardDefs.defcard("Copycat", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "Whenever you pass a piece of ice, you may trash Copycat. If you do, choose another rezzed copy of that piece of ice protecting any server. The run continues as if you had just passed the chosen piece of ice (you are now running from the new position).",
		"code": "04025",
		"title": "Copycat",
	}, {
		"abilities": [
			{
			"async": true,
			"req": func(state, side, eid, card, targets): return (state.getv("run") and NRCardXlate.getk(NRIce.get_current_ice(state), "rezzed", null)),
			"prompt": func(state, side, eid, card, targets): return str("Choose a rezzed copy of ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRCardXlate.first_target(targets)) and NRCard.ice(NRCardXlate.first_target(targets)) and ((NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null) == NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)) or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null), NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)))),
			},
			"msg": "redirect the run",
			"effect": func(state, side, eid, card, targets):
				return (func():
				var dest = (NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null)
				var tgtndx = card_index(state, NRCardXlate.first_target(targets))
				return (func():
					null
					NRIce.set_current_ice(state)
					return NRMoving.trash(state, side, eid, card, {
						"unpreventable": true,
						"cause-card": card,
					})
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Cordyceps", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When you install this program, place 2 virus counters on it.\nOnce per turn → When you make a successful run on a central server, you may remove 1 hosted virus counter to swap 1 piece of ice protecting that server with another installed piece of ice.",
		"code": "26086",
		"title": "Cordyceps",
	}, {
		"data": {
			"counter": {
				"virus": 2,
			},
		},
		"events": [
			{
			"event": "successful-run",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"optional": {
				"req": func(state, side, eid, card, targets): return (NRServers.is_central(NRServers.target_server(NRCardXlate.ctx(targets))) and NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("virus", 1)]) and (not NRUtil.as_array(run_ices).is_empty()) and (2 <= NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "corp")).filter(NRCard.ice)).size())),
				"once": "per-turn",
				"prompt": "Swap 2 pieces of ice?",
				"yes-ability": {
					"prompt": "Choose a piece of ice protecting this server",
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and NRCard.ice(NRCardXlate.first_target(targets)) and ((NRServers.target_server(NRCardXlate.getk(state, "run", null)) == (NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null)) or NRUtil.kw_eq(NRServers.target_server(NRCardXlate.getk(state, "run", null)), (NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null)))),
					},
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, (func():
						var first_ice = NRCardXlate.first_target(targets)
						return {
							"prompt": "Choose a piece of ice to swap with",
							"choices": {
								"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.first_target(targets)) and NRCard.ice(NRCardXlate.first_target(targets)) and (not (((first_ice == NRCardXlate.first_target(targets)) or NRUtil.kw_eq(first_ice, NRCardXlate.first_target(targets)))))),
							},
							"msg": func(state, side, eid, card, targets): return str("swap the positions of ") + str(NRToString.card_str(state, first_ice)) + str(" and ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NREngine.pay(state, side, ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("virus", 1)])
							, func(async_result):
								(func():
								NRSay.system_msg(state, side, NRCardXlate.getk(async_result, "msg", null))
								NRMoving.swap_ice(state, side, first_ice, NRCardXlate.first_target(targets))
								return NREid.effect_completed(state, side, eid)
							).call()),
						}
					).call(), card, null),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Corroder", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "31006",
		"title": "Corroder",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(1, 1)],
	})))

	NRCardDefs.defcard("Corsair", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> The <strong>barrier</strong> you are encountering gets −3 strength for the remainder of this encounter. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "36004",
		"title": "Corsair",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier"),
			{
			"label": "Give -3 strength to encountered Barrier",
			"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and NRCard.has_subtype(NRIce.get_current_ice(state), "Barrier")),
			"keep-menu-open": true,
			"msg": func(state, side, eid, card, targets): return str("give -3 strength to ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return pump_ice(state, side, NRIce.get_current_ice(state), -3),
			"cost": [NRPayment.to_c("credit", 1, {
				"stealth": "all-stealth",
			})],
		},
		],
	})))

	NRCardDefs.defcard("Cradle", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 5,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "This program gets -1 strength for each card in your grip.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>code gate</strong> subroutines.",
		"code": "22006",
		"title": "Cradle",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 0, "Code Gate")],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return (-NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "hand", null)).size())),
		],
	})))

	NRCardDefs.defcard("Creeper", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Cloud",
		"subtypes": ["Icebreaker", "Killer", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "02089",
		"title": "Creeper",
	}, cloud_icebreaker(NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Sentry"), NRCardXlate.strength_pump(1, 1)],
	}))))

	NRCardDefs.defcard("Crescentus", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "<strong>[Trash]:</strong> Derez 1 piece of ice you fully broke during this encounter.",
		"code": "02065",
		"title": "Crescentus",
	}, {
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state)) and NRIce.all_subs_broken(NRIce.get_current_ice(state))),
			"label": "derez an ice",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, side, eid, NRIce.get_current_ice(state), {
				"msg-keys": {
					"include-cost-from-eid": eid,
				},
			}),
		},
		],
	}))

	NRCardDefs.defcard("Crowbar", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Cloud",
		"subtypes": ["Icebreaker", "Decoder", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nThis program gets +1 strength for each installed <strong>icebreaker</strong>.\nInterface → <strong>[Trash]:</strong> Break up to 3 <strong>code gate</strong> subroutines.",
		"code": "08046",
		"title": "Crowbar",
	}, break_and_enter("Code Gate")))

	NRCardDefs.defcard("Crypsis", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 5,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Virus",
		"subtypes": ["Icebreaker", "AI", "Virus"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>[Click]:</strong> Place 1 virus counter on this program.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, remove 1 hosted virus counter or trash this program.",
		"code": "25061",
		"title": "Crypsis",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All"),
			NRCardXlate.strength_pump(1, 1),
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"msg": "place 1 virus counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"events": [
			{
			"event": "end-of-encounter",
			"req": func(state, side, eid, card, targets): return any_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": func(state, side, eid, card, targets): return str(("remove 1 hosted virus counter" if NRPayment.can_pay(state, side, eid, card, null, [NRPayment.to_c("virus", 1)]) else "trash itself")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NREngine.pay(state, "runner", ne, NREid.make_eid(state, eid), card, [NRPayment.to_c("virus", 1)])
			, func(async_result):
				(func():
				var payment_str = NRCardXlate.getk(async_result, "msg", null)
				return (func():
				NRSay.system_msg(state, "runner", payment_str)
				return NREid.effect_completed(state, side, eid)
			).call() if payment_str != null else NRMoving.trash(state, side, eid, card, {
				"cause-card": card,
			})
			).call()),
		},
		],
	})))

	NRCardDefs.defcard("Cupellation", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Limit 1 hosted card.\nAccess → <strong>1[Credits]:</strong> Host the non-agenda card you are accessing faceup on this program. <em>(If it was installed, it becomes uninstalled.)</em>\nWhenever you breach HQ, if this program has a hosted Corp card, you may pay 1[Credits] and trash this program to access 2 additional cards.",
		"code": "34080",
		"title": "Cupellation",
	}, {
		"events": [
			{
			"event": "end-breach-server",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (((NRCardXlate.getk(NRCardXlate.first_target(targets), "from-server", null) == "archives") or NRUtil.kw_eq(NRCardXlate.getk(NRCardXlate.first_target(targets), "from-server", null), "archives")) and (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCardXlate.getk(_pct, "seen", null) and (not (NRCard.agenda(_pct)))))).is_empty()) and (NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp) is Array and NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp).is_empty() if false else (str(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp)) == ""))),
			"prompt": "1 [Credits]: Host a card from archives?",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCardXlate.getk(_pct, "seen", null) and (not (NRCard.agenda(_pct))))),
			"cost": [NRPayment.to_c("credit", 1)],
			"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" on itself"),
			"effect": func(state, side, eid, card, targets):
				return NRHosting.host(state, side, card, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true})),
		},
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return ((("hq" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (not NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp)).is_empty())),
				"prompt": "1 [Credits]: Trash this program to access 2 additional cards from HQ?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRAccess.access_bonus(state, side, "hq", 2)
						return NREid.effect_completed(state, side, eid),
					"cost": [NRPayment.to_c("credit", 1), NRPayment.to_c("trash-can")],
					"msg": "access 2 additional cards from HQ",
				},
			},
		},
		],
		"interactions": {
			"access-ability": {
				"label": "Host card",
				"trash?": false,
				"req": func(state, side, eid, card, targets): return ((NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp) is Array and NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp).is_empty() if false else (str(NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(NRCard.corp)) == "")) and (not (NRCard.agenda(NRCardXlate.first_target(targets))))),
				"cost": [NRPayment.to_c("credit", 1)],
				"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" on itself"),
				"effect": func(state, side, eid, card, targets):
					NRHosting.host(state, side, card, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}))
					return null,
			},
		},
	}))

	NRCardDefs.defcard("Curupira", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Whenever you encounter a <strong>barrier</strong>, you may spend 3 hosted power counters to bypass it.\nWhenever this program fully breaks a piece of ice, place 1 power counter on this program.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "34015",
		"title": "Curupira",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(1, 1)],
		"interactive": func(state, side, eid, card, targets):
			return true,
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": {
				"prompt": func(state, side, eid, card, targets): return str("Spend 3 power counters to bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str("?"),
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Barrier") and (3 <= NRCard.get_counters(NRCard.get_card(state, card), "power"))),
				"yes-ability": {
					"cost": [NRPayment.to_c("power", 3)],
					"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
					"effect": func(state, side, eid, card, targets):
						return NRCardXlate.bypass_ice(state),
				},
			},
		},
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
	})))

	NRCardDefs.defcard("Customized Secretary", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When you install Customized Secretary reveal the top 5 cards of the stack. You may host any number of revealed programs from your stack on it. Shuffle your stack.\n[Click]: Install a hosted program, paying all install costs.",
		"code": "12027",
		"title": "Customized Secretary",
	}, (func():
		return {
			"on-install": {
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return (NRUtil.find_first(NRUtil.as_array(NRBoard.all_active(state, "runner")), func(_pct, _pct2=null, _pct3=null): return NRFlags.card_flag(_pct, "runner-install-draw", true)) != null),
				"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRUtil.enumerate_cards(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(5)))) + str(" from the top of the stack"),
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var from = NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), int(5))
					return NREid.wait_for(state, eid, func(ne):
						NRRevealing.reveal(state, side, ne, from)
					, func(async_result):
						NREngine.continue_ability(state, side, custsec_host(from), card, null))
				).call(),
			},
			"abilities": [
				{
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"keep-menu-open": "while-clicks-left",
				"label": "Install a hosted program",
				"prompt": "Choose a program to install",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"include-cost-from-eid": eid,
					},
				}),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Cyber-Cypher", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"strength": 4,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "When you install this program, choose a server. Use this program only during runs on the chosen server.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "03044",
		"title": "Cyber-Cypher",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"prompt": "Choose a server",
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"choices": func(state, side, eid, card, targets):
				return NRServers.zones_to_sorted_names(NRBoard.get_zones(state)),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})),
		},
		"leave-play": func(state, side, eid, card, targets):
			return NRUpdate.update_card(state, side, NRUtil.dissoc(card if card is Dictionary else {}, ["card-target"])),
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate", {
			"req": func(state, side, eid, card, targets): return (NRUtil.in_coll([
				NRUtil.last_of(NRBoard.server_to_zone(state, NRCardXlate.getk(card, "card-target", null))),
			], NRServers.target_server(state.getv("run"))) if NRCardXlate.getk(card, "card-target", null) else true),
		}),
			NRCardXlate.strength_pump(1, 1, "end-of-encounter", {
			"req": func(state, side, eid, card, targets): return (NRUtil.in_coll([
				NRUtil.last_of(NRBoard.server_to_zone(state, NRCardXlate.getk(card, "card-target", null))),
			], NRServers.target_server(state.getv("run"))) if NRCardXlate.getk(card, "card-target", null) else true),
		}),
		],
	})))

	NRCardDefs.defcard("D4v1d", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"text": "Place 3 power counters on D4v1d when it is installed.\n<strong>Hosted power counter:</strong> Break ice subroutine on a piece of ice that has a strength of 5 or greater.",
		"code": "06033",
		"title": "D4v1d",
	}, NRCardXlate.auto_icebreaker((func():
		var david_req = func(state, side, eid, card, targets):
			return (5 <= NRIce.get_strength(NRIce.get_current_ice(state)))
		return {
			"data": {
				"counter": {
					"power": 3,
				},
			},
			"abilities": [
				NRCardXlate.break_sub([NRPayment.to_c("power", 1)], 1, "All", {
				"req": david_req,
			}),
			],
		}
	).call())))

	NRCardDefs.defcard("Dagger", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +5 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "03042",
		"title": "Dagger",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Sentry"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 1, {
			"stealth": 1,
		}), 5, "end-of-encounter"),
		],
	})))

	NRCardDefs.defcard("Dai V", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 6,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>2[Credits]:</strong> Break all subroutines. Spend credits only from <strong>stealth</strong> cards to use this ability.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "11006",
		"title": "Dai V",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("credit", 2, {
			"stealth": "all-stealth",
		})], 0, "All", {
			"all": true,
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Darwin", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Virus",
		"subtypes": ["Icebreaker", "AI", "Virus"],
		"text": "Interface → 2[Credits]: Break 1 subroutine.\nX is equal to the number of hosted virus counters.\nWhen your turn begins, you may pay 1[Credits] to place 1 virus counter on this program.",
		"code": "20008",
		"title": "Darwin",
	}, NRCardXlate.auto_icebreaker({
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"x-fn": func(state, side, eid, card, targets):
			return NRVirus.get_virus_counters(state, card),
		"abilities": [
			NRCardXlate.break_sub(2, 1),
			{
			"label": "Place 1 virus counter (start of turn)",
			"once": "per-turn",
			"cost": [NRPayment.to_c("credit", 1)],
			"msg": "place 1 virus counter on itself",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"static-abilities": [breaker_strength_bonus(get_x_fn())],
	})))

	NRCardDefs.defcard("Datasucker", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on a central server, place 1 virus counter on Datasucker.\n<strong>Hosted virus counter:</strong> Rezzed piece of ice currently being encountered has -1 strength until the end of the encounter.",
		"code": "25011",
		"title": "Datasucker",
	}, {
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return NRServers.is_central(NRServers.target_server(NRCardXlate.ctx(targets))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			{
			"cost": [NRPayment.to_c("virus", 1)],
			"label": "Give -1 strength to current piece of ice",
			"req": func(state, side, eid, card, targets): return (NRCard.rezzed(NRIce.get_current_ice(state)) and NRRuns.get_current_encounter(state)),
			"keep-menu-open": "while-virus-tokens-left",
			"msg": func(state, side, eid, card, targets): return str("give -1 strength to ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return pump_ice(state, side, NRIce.get_current_ice(state), -1),
		},
		],
	}))

	NRCardDefs.defcard("DaVinci", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you make a successful run, place 1 power counter on DaVinci.\n[Trash]: Install a card from your grip with an install cost equal to or less than the number of power counters on DaVinci, ignoring the install cost.",
		"code": "08107",
		"title": "DaVinci",
	}, {
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")), func(_pct, _pct2=null, _pct3=null): return ((NRCard.hardware(_pct) or NRCard.program(_pct) or NRCard.resource(_pct)) and NRInstalling.runner_can_install(state, side, eid, _pct, null) and (NRCostFns.install_cost(state, side, _pct) <= NRCard.get_counters(card, "power")))) != null),
			"label": "install a card from the grip",
			"cost": [NRPayment.to_c("trash-can")],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"waiting-prompt": true,
				"prompt": "Choose a card to install",
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets)) and (NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets)) or NRCard.resource(NRCardXlate.first_target(targets))) and (NRCostFns.install_cost(state, side, NRCardXlate.first_target(targets)) <= NRCard.get_counters(cost_target(eid, "trash-can"), "power"))),
				},
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"ignore-install-cost": true,
					"msg-keys": {
						"install-source": card,
						"include-cost-from-eid": eid,
						"display-origin": true,
					},
				}),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Deep Thought", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on R&D, place 1 virus counter on Deep Thought.\nIf there are at least 3 virus counters on Deep Thought, it gains \"When your turn begins, you may look at the top card of R&D.\"",
		"code": "02108",
		"title": "Deep Thought",
	}, {
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
			"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
		},
			{
			"event": "runner-turn-begins",
			"req": func(state, side, eid, card, targets): return (NRVirus.get_virus_counters(state, card) >= 3),
			"msg": "look at the top card of R&D",
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

	NRCardDefs.defcard("Demara", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.\n<strong>[Trash]:</strong> Bypass the <strong>barrier</strong> you are encountering.",
		"code": "25034",
		"title": "Demara",
	}, trash_to_bypass(NRCardXlate.break_sub(2, 2, "Barrier"), NRCardXlate.strength_pump(2, 3))))

	NRCardDefs.defcard("Deus X", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 10,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker",
		"subtypes": ["Icebreaker"],
		"text": "Interface → <strong>[Trash]:</strong> Break any number of <strong>AP</strong> subroutines.\n[interrupt] → <strong>[Trash]:</strong> Prevent any amount of net damage.",
		"code": "25053",
		"title": "Deus X",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"ability": NRUtil.merge(prevent_up_to_n_damage("all", ["net"]) if prevent_up_to_n_damage("all", ["net"]) is Dictionary else {}, {"cost": [NRPayment.to_c("trash-can")]}),
		},
		],
		"abilities": [NRCardXlate.break_sub([NRPayment.to_c("trash-can")], 0, "AP")],
	}))

	NRCardDefs.defcard("Devadatta Drone", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "When you install this program, place 2 power counters on it.\nWhenever you breach R&D, you may remove 1 hosted power counter to access 1 additional card.",
		"code": "35031",
		"title": "Devadatta Drone",
	}, {
		"data": {
			"counter": {
				"power": 2,
			},
		},
		"events": [
			{
			"event": "breach-server",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return ((NRCard.get_counters(card, "power") > 0) and (("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)))),
				"waiting-prompt": true,
				"prompt": "Spend 1 hosted power counter to access 1 additional card?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": "access 1 additional card from R&D",
					"cost": [NRPayment.to_c("power", 1)],
					"effect": func(state, side, eid, card, targets):
						return NRAccess.access_bonus(state, side, "rd", 1),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Devadatta Drone")],
	}))

	NRCardDefs.defcard("Dhegdheer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Daemon",
		"subtypes": ["Daemon"],
		"text": "You can install other programs onto this program. Each program installed this way costs 1[Credits] less to install. Limit 1 hosted program.\nThe memory cost of the hosted program does not count against your memory limit.",
		"code": "13020",
		"title": "Dhegdheer",
	}, {
		"implementation": "Discount not considered by any engine functions when checking if a program is playable",
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return NRCard.program(NRCardXlate.first_target(targets)),
			"no-mu": true,
			"cost-bonus": -1,
			"max-cards": 1,
		},
		],
	}))

	NRCardDefs.defcard("Disrupter", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[interrupt] → [Trash]: Reduce the base trace strength of a trace to 0.",
		"code": "02061",
		"title": "Disrupter",
	}, {
		"events": [
			{
			"event": "initialize-trace",
			"fake-cost": [NRPayment.to_c("trash-can")],
			"optional": {
				"waiting-prompt": true,
				"prompt": "Trash Disrupter to reduce the base trace strength to 0?",
				"yes-ability": {
					"cost": [NRPayment.to_c("trash-can")],
					"effect": func(state, side, eid, card, targets):
						return NRTrace.force_base(state, 0),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Diwan", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When you install this program, choose a server. As an additional cost to install a card in the root of or protecting that server, the Corp must pay 1[Credits].\nWhen the Corp purges virus counters, trash this program.",
		"code": "10021",
		"title": "Diwan",
	}, {
		"on-install": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRServers.zones_to_sorted_names(NRBoard.get_zones(state)),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})),
		},
		"static-abilities": [
			{
			"type": "install-cost",
			"req": func(state, side, eid, card, targets): return (func():
				var serv = NRCardXlate.getk((NRUtil.as_array(targets)[1] if NRUtil.as_array(targets).size() > 1 else null), "server", null)
				return ((serv == NRCardXlate.getk(card, "card-target", null)) or NRUtil.kw_eq(serv, NRCardXlate.getk(card, "card-target", null)))
			).call(),
			"value": 1,
		},
		],
		"events": [trash_on_purge],
	}))

	NRCardDefs.defcard("Djinn", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Daemon",
		"subtypes": ["Daemon"],
		"text": "Djinn can host up to 3[Memory Unit] of non-<strong>icebreaker</strong> programs.\nThe memory costs of hosted programs do not count against your memory limit.\n[Click], 1[Credits]: Search your stack for a <strong>virus</strong> program, reveal it, and add it to your grip. Shuffle your stack.",
		"code": "01009",
		"title": "Djinn",
	}, {
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return ((expected_mu(state, NRCardXlate.first_target(targets)) <= 3) and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker"))) and NRCard.program(NRCardXlate.first_target(targets))),
			"no-mu": true,
			"max-mu": 3,
		},
		],
		"abilities": [
			NRUtil.merge(tutor_abi(true, func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.has_subtype(_pct, "Virus"))) if tutor_abi(true, func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.has_subtype(_pct, "Virus"))) is Dictionary else {}, {"action": true}),
		],
	}))


static func _register_3() -> void:
	NRCardDefs.defcard("Eater", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine. You cannot access cards for the remainder of this run.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "07040",
		"title": "Eater",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"additional-ability": {
				"msg": "access not more than 0 cards for the remainder of this run",
				"effect": func(state, side, eid, card, targets):
					return max_access(state, 0),
			},
			"label": "break 1 subroutine and access 0 cards",
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Echelon", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "This program gets +1 strength for each installed <strong>icebreaker</strong> <em>(including this one)</em>.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +2 strength.",
		"code": "30025",
		"title": "Echelon",
	}, NRCardXlate.auto_icebreaker({
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.has_subtype(_pct, "Icebreaker")))).size()),
		],
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(3, 2)],
	})))

	NRCardDefs.defcard("Egret", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a rezzed piece of ice.\nHost ice gains <strong>barrier</strong>, <strong>code gate</strong>, and <strong>sentry</strong>.",
		"code": "31032",
		"title": "Egret",
	}, ({
		"implementation": "[Erratum] Program: Trojan",
		"on-install": {
			"msg": func(state, side, eid, card, targets): return str("make ") + str(NRToString.card_str(state, NRCardXlate.getk(card, "host", null))) + str(" gain Barrier, Code Gate and Sentry subtypes"),
		},
		"static-abilities": [
			{
			"type": "gain-subtype",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": ["Barrier", "Code Gate", "Sentry"],
		},
		],
	}).call(trojan({
		"rezzed": true,
	}))))

	NRCardDefs.defcard("Endless Hunger", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Apex",
		"cost": 0,
		"strength": 11,
		"memoryunits": 4,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker",
		"subtypes": ["Icebreaker"],
		"text": "Interface → <strong>Trash 1 installed card:</strong> Break 1 \"[subroutine] End the run.\" subroutine.",
		"code": "09033",
		"title": "Endless Hunger",
	}, {
		"implementation": "ETR restriction not implemented",
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("trash-installed", 1)], 1, "All", {
			"label": "break 1 \"[Subroutine] End the run.\" subroutine",
		}),
		],
	}))

	NRCardDefs.defcard("Engolo", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Once per turn → When you encounter a piece of ice, you may pay 2[Credits]. If you do, it gains <strong>code gate</strong> for the remainder of that encounter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +4 strength.",
		"code": "21108",
		"title": "Engolo",
	}, give_ice_subtype(2, "Code Gate", [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(2, 4)])))

	NRCardDefs.defcard("Equivocation", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": true,
		"text": "Whenever you make a successful run on R&D, you may reveal the top card of R&D. If you do, you may force the Corp to draw that card.",
		"code": "11084",
		"title": "Equivocation",
	}, (func():
		var force_draw = func(c): return {
			"optional": {
				"prompt": (str("Force the Corp to draw ") + str(NRCardXlate.getk(c, "title", null)) + str("?")),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRSay.system_msg(state, "corp", (str("is forced to draw ") + str(NRCardXlate.getk(c, "title", null))))
						return NRDrawing.draw(state, "corp", eid, 1),
				},
			},
		}
		var rvl = {
			"optional": {
				"prompt": "Reveal the top card of R&D?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						var topcard = state.get_in(["corp", "deck", 0], null)
						return NREid.wait_for(state, eid, func(ne):
							NRRevealing.reveal(state, side, ne, topcard)
						, func(async_result):
							(func():
							NRSay.system_msg(state, "runner", (str("reveals ") + str(NRCardXlate.getk(topcard, "title", null)) + str(" from the top of R&D")))
							return NREngine.continue_ability(state, side, force_draw(topcard), card, null)
						).call())
					).call(),
				},
			},
		}
		return {
			"events": [
				{
				"event": "successful-run",
				"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, rvl, card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Euler", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>0[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine. Use this ability only if this program was installed this turn.\nInterface → <strong>2[Credits]:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "26087",
		"title": "Euler",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(0, 1, "Code Gate", {
			"req": func(state, side, eid, card, targets): return (("this-turn" == NRCard.installed(card)) or NRUtil.kw_eq("this-turn", NRCard.installed(card))),
		}),
			NRCardXlate.break_sub(2, 2, "Code Gate"),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("eXer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you breach R&D, access 1 additional card.\nWhen the Corp purges virus counters, trash this program.",
		"code": "21041",
		"title": "eXer",
	}, {
		"events": [breach_access_bonus("rd", 1), trash_on_purge],
	}))

	NRCardDefs.defcard("Expert Schedule Analyzer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "<strong>[Click]:</strong> Run HQ. If successful, instead of breaching HQ, you may reveal all cards in HQ.",
		"code": "04045",
		"title": "Expert Schedule Analyzer",
	}, (func():
		var ability = NRCardXlate.successful_run_replace_breach({
			"target-server": "hq",
			"duration": "end-of-run",
			"ability": {
				"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRUtil.enumerate_cards(NRCardXlate.getk(state.getv("corp", {}), "hand", null), "sorted")) + str(" from HQ"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRRevealing.reveal(state, side, eid, NRCardXlate.getk(state.getv("corp", {}), "hand", null)),
			},
		})
		return {
			"abilities": [
				NRCardXlate.run_server_ability("hq", {
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"events": [ability],
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Faerie", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → 0[Credits]: Break 1 <strong>sentry</strong> subroutine.\n1[Credits]: +1 strength.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, trash this program.",
		"code": "25035",
		"title": "Faerie",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(0, 1, "Sentry"), NRCardXlate.strength_pump(1, 1)],
		"events": [
			{
			"event": "end-of-encounter",
			"async": true,
			"req": func(state, side, eid, card, targets): return any_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(card, "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRMoving.trash(state, side, eid, card, {
				"cause": "runner-ability",
				"cause-card": card,
			}),
		},
		],
	})))

	NRCardDefs.defcard("False Echo", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Whenever you pass a piece of unrezzed ice, you may trash False Echo. If you do, the Corp must rez that ice or add it to HQ.",
		"code": "04007",
		"title": "False Echo",
	}, {
		"events": [
			{
			"event": "pass-ice",
			"optional": {
				"req": func(state, side, eid, card, targets): return (not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)))),
				"prompt": func(state, side, eid, card, targets): return str("Trash ") + str(NRCardXlate.getk(card, "title", null)) + str(" to make the Corp rez the passed piece of ice or add it to HQ?"),
				"yes-ability": {
					"async": true,
					"msg": "force the Corp to either rez the passed piece of ice or add it to HQ",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, card, null)
					, func(async_result):
						NREngine.continue_ability(state, side, (func():
						var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
						return {
							"async": true,
							"prompt": "Choose one",
							"waiting-prompt": true,
							"player": "corp",
							"choices": func(state, side, eid, card, targets):
								return [
								((str("Rez ") + str(NRCard.get_title(ice))) if NRPayment.can_pay(state, "runner", eid, card, null, [NRPayment.to_c("credit", NRCostFns.rez_cost(state, side, ice))]) else null),
								(str("Add ") + str(NRCard.get_title(ice)) + str(" to HQ")),
							],
							"effect": func(state, side, eid, card, targets):
								return (NRRezzing.rez(state, side, eid, ice) if ((NRCardXlate.first_target(targets) == (str("Rez ") + str(NRCard.get_title(ice)))) or NRUtil.kw_eq(NRCardXlate.first_target(targets), (str("Rez ") + str(NRCard.get_title(ice))))) else (func():
								NRSay.system_msg(state, "corp", "adds the passed piece of ice to HQ")
								NRMoving.move(state, "corp", ice, "hand")
								return NREid.effect_completed(state, side, eid)
							).call()),
						}
					).call(), card, NRCardXlate.first_target(targets))),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Faust", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>Trash a card from your grip:</strong> Break 1 subroutine.\n<strong>Trash a card from your grip:</strong> +2 strength.",
		"code": "08061",
		"title": "Faust",
	}, {
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("trash-from-hand", 1)], 1),
			NRCardXlate.strength_pump([NRPayment.to_c("trash-from-hand", 1)], 2),
		],
	}))

	NRCardDefs.defcard("Fawkes", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>X[Credits]:</strong> +X strength for the remainder of this run. Use this ability only by spending at least 1 credit from a <strong>stealth</strong> card.",
		"code": "11108",
		"title": "Fawkes",
	}, {
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Sentry"),
			{
			"label": "+X strength for the remainder of the run (using at least 1 stealth [Credits])",
			"cost": [NRPayment.to_c("x-credits", 0, {
				"stealth": 1,
			})],
			"prompt": "How many credits do you want to spend?",
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, card, NRPayment.cost_value(eid, "x-credits"), "end-of-run"),
			"msg": func(state, side, eid, card, targets): return str("increase strength by ") + str(NRPayment.cost_value(eid, "x-credits")) + str(" for the remainder of the run"),
		},
		],
	}))

	NRCardDefs.defcard("Femme Fatale", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 9,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength.\nWhen you install this program, choose 1 installed piece of ice.\nWhenever you encounter the chosen ice, you may pay 1[Credits] for each subroutine it has. If you do, bypass that ice.",
		"code": "31022",
		"title": "Femme Fatale",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"prompt": "Choose a piece of ice to target for bypassing",
			"choices": {
				"card": NRCard.ice,
			},
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(NRCard.get_card(state, card) if NRCard.get_card(state, card) is Dictionary else {}, ["special", "femme"], NRCardXlate.first_target(targets))),
		},
		"static-abilities": [
			{
			"type": "icon",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRUtil.get_in(card, ["special", "femme"], null)),
			"value": func(state, side, eid, card, targets):
				return make_icon("FF", card),
		},
		],
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets):
					return (func():
					var ice = NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))
					return NRPayment.can_pay(state, "runner", eid, card, null, [
						NRPayment.to_c("credit", NRUtil.as_array(NRCardXlate.getk(ice, "subroutines", null)).size()),
					])
				).call(),
			},
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRUtil.get_in(card, ["special", "femme"], null), NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				var c = NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, ice), "subroutines", null)).size()
				return NREngine.continue_ability(state, side, {
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Pay ") + str(c) + str(" [Credits] to bypass ") + str(NRCardXlate.getk(ice, "title", null)) + str("?"),
						"yes-ability": {
							"cost": [NRPayment.to_c("credit", c)],
							"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "title", null)),
							"effect": func(state, side, eid, card, targets):
								return NRCardXlate.bypass_ice(state),
						},
					},
				}, card, targets)
			).call(),
		},
		],
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(2, 1)],
	})))

	NRCardDefs.defcard("Fermenter", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When you install this program and when your turn begins, place 1 virus counter on this program.\n[Click], [Trash]<strong>:</strong> Gain 2[Credits] for each hosted virus counter.",
		"code": "30007",
		"title": "Fermenter",
	}, {
		"data": {
			"counter": {
				"virus": 1,
			},
		},
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			{
			"action": true,
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (NRVirus.get_virus_counters(state, card) > 0),
			},
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"label": "Gain 2 [Credits] for each hosted virus counter",
			"msg": func(state, side, eid, card, targets): return str((str("gain ") + str((2 * NRVirus.get_virus_counters(state, card))) + str(" [Credits]"))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit", (2 * NRVirus.get_virus_counters(state, card)), 3)
				return NRGaining.gain_credits(state, side, eid, (2 * NRVirus.get_virus_counters(state, card))),
		},
		],
	}))

	NRCardDefs.defcard("Flashbang", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>6[Credits]:</strong> Derez the <strong>sentry</strong> you are encountering.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "12085",
		"title": "Flashbang",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			{
			"label": "Derez a Sentry being encountered",
			"cost": [NRPayment.to_c("credit", 6)],
			"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.has_subtype(NRIce.get_current_ice(state), "Sentry")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRRezzing.derez(state, side, eid, NRIce.get_current_ice(state), {
				"msg-keys": {
					"include-cost-from-eid": eid,
				},
			}),
		},
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Flux Capacitor", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nThe first time you break a subroutine during each encounter with host ice, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>",
		"code": "33087",
		"title": "Flux Capacitor",
	}, ({
		"events": [
			{
			"event": "subroutines-broken",
			"once": "per-encounter",
			"async": true,
			"req": func(state, side, eid, card, targets): return (this_server and NRUtil.same_card(NRIce.get_current_ice(state), NRCardXlate.getk(card, "host", null))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRCharge.charge_ability(state, side), card, null),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Force of Nature", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "25012",
		"title": "Force of Nature",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 2, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
	})))

	NRCardDefs.defcard("Garrote", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 7,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "04065",
		"title": "Garrote",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(1, 1)],
	})))

	NRCardDefs.defcard("Gauss", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "When you install this program, it gets +3 strength for the remainder of the turn.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "26024",
		"title": "Gauss",
	}, NRCardXlate.auto_icebreaker({
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return (("this-turn" == NRCard.installed(card)) or NRUtil.kw_eq("this-turn", NRCard.installed(card))), 3),
		],
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(2, 2)],
	})))

	NRCardDefs.defcard("Gingerbread", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker",
		"subtypes": ["Icebreaker"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>tracer</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "05044",
		"title": "Gingerbread",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Tracer"), NRCardXlate.strength_pump(2, 3)],
	})))

	NRCardDefs.defcard("God of War", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Virus",
		"subtypes": ["Icebreaker", "AI", "Virus"],
		"text": "When your turn begins, you may take 1 tag to place 2 virus counters on this program.\nInterface → <strong>Hosted virus counter:</strong> Break 1 subroutine.\n<strong>2[Credits]:</strong> +1 strength.",
		"code": "12082",
		"title": "God of War",
	}, NRCardXlate.auto_icebreaker((func():
		var abi = {
			"label": "Take 1 tag to place 2 virus counters (start of turn)",
			"cost": [NRPayment.to_c("gain-tag")],
			"once": "per-turn",
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("place 2 virus counters on ") + str(NRCardXlate.getk(card, "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 2, null),
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
					"prompt": "Take 1 tag: Place 2 virus counters on God of War",
					"req": func(state, side, eid, card, targets): return NREngine.not_used_once(state, {
						"once": "per-turn",
					}, card),
					"yes-ability": abi,
				},
			},
			],
			"abilities": [
				NRCardXlate.break_sub([NRPayment.to_c("virus", 1)], 1),
				NRCardXlate.strength_pump(2, 1),
				abi,
			],
		}
	).call())))

	NRCardDefs.defcard("Golden", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → 2[Credits]: Break up to 2 <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +4 strength.\n<strong>2[Credits]</strong>, <strong>add this program to your grip:</strong> Derez 1 <strong>sentry</strong> this program fully broke during this encounter.",
		"code": "11025",
		"title": "Golden",
	}, return_and_derez(NRCardXlate.break_sub(2, 2, "Sentry"), NRCardXlate.strength_pump(2, 4))))

	NRCardDefs.defcard("Gordian Blade", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength for the remainder of this run.",
		"code": "31033",
		"title": "Gordian Blade",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			NRCardXlate.strength_pump(1, 1, "end-of-run"),
		],
	})))

	NRCardDefs.defcard("Gorman Drip v1", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever the Corp spends a [Click] to draw 1 card or gain 1[Credits] (not through a card ability), place 1 virus counter on Gorman Drip v1.\n[Click], [Trash]: Gain 1[Credits] for each virus counter on Gorman Drip v1.",
		"code": "04005",
		"title": "Gorman Drip v1",
	}, {
		"events": [
			{
			"event": "corp-credit-gain",
			"req": func(state, side, eid, card, targets): return (("corp-click-credit" == NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null)) or NRUtil.kw_eq("corp-click-credit", NRCardXlate.getk(NRCardXlate.ctx(targets), "action", null))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "virus", 1, null),
		},
			{
			"event": "corp-click-draw",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"label": "Gain credits",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, NRVirus.get_virus_counters(state, card)),
			"msg": func(state, side, eid, card, targets): return str("gain ") + str(NRVirus.get_virus_counters(state, card)) + str(" [Credits]"),
		},
		],
	}))

	NRCardDefs.defcard("Gourmand", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Access → [Trash]<strong>:</strong> Trash the non-agenda card you are accessing. If you do, draw 1 card.",
		"code": "35007",
		"title": "Gourmand",
	}, {
		"interactions": {
			"access-ability": {
				"label": "Trash card",
				"trash?": true,
				"req": func(state, side, eid, card, targets): return (NRFlags.can_trash(state, "runner", NRCardXlate.first_target(targets)) and (not (NRCard.agenda(NRCardXlate.first_target(targets)))) and (not (NRCard.in_discard(NRCardXlate.first_target(targets))))),
				"cost": [NRPayment.to_c("trash-can")],
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRMoving.trash(state, side, ne, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}), {
					"accessed": true,
					"cause-card": card,
				})
				, func(async_result):
					NRDrawing.draw(state, side, eid, card, 1)),
			},
		},
	}))

	NRCardDefs.defcard("Grappling Hook", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "[Trash]: Break all but 1 subroutine on a piece of ice.",
		"code": "05045",
		"title": "Grappling Hook",
	}, (func():
		var break_subs = func(state, ice, subroutines): return (func():
			for sub in NRUtil.as_array(subroutines):
				NRIce.break_subroutine_bang(state, NRCard.get_card(state, ice), sub)
			return null
		).call()
		return {
			"abilities": [
				{
				"label": "break all but 1 subroutine",
				"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and (1 < NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)).filter(func(_x): return not ((func(_x): return bool(NRCardXlate.getk(_x, "broken"))).call(_x)))).size())),
				"break": 1,
				"breaks": "All",
				"break-cost": [NRPayment.to_c("trash-can")],
				"cost": [NRPayment.to_c("trash-can")],
				"prompt": "Choose the subroutine to NOT break",
				"choices": func(state, side, eid, card, targets):
					return NRIce.unbroken_subroutines_choice(NRIce.get_current_ice(state)),
				"msg": func(state, side, eid, card, targets): return str((func():
					var subroutines = NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)
					var target = NRUtil.first_of(NRUtil.as_array(subroutines).filter(func(_pct, _pct2=null, _pct3=null): return ((not (NRCardXlate.getk(_pct, "broken", null))) and ((NRCardXlate.first_target(targets) == make_label(NRCardXlate.getk(_pct, "sub-effect", null))) or NRUtil.kw_eq(NRCardXlate.first_target(targets), make_label(NRCardXlate.getk(_pct, "sub-effect", null)))))))
					var broken_subs = NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "index", null) == NRCardXlate.getk(NRCardXlate.first_target(targets), "index", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "index", null), NRCardXlate.getk(NRCardXlate.first_target(targets), "index", null)))).call(_x)))
					return break_subroutines_msg(NRIce.get_current_ice(state), broken_subs, card)
				).call()),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var selected = NRCardXlate.getk(NRUtil.first_of(targets), "idx", null)
					var subs_to_break = NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)).filter(func(_x): return not ((func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "index", null) == selected) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "index", null), selected))).call(_x)))
					return (func():
						break_subs(state, NRIce.get_current_ice(state), subs_to_break)
						return (func():
							var ice = NRCard.get_card(state, NRIce.get_current_ice(state))
							var on_break_subs = (NRCardXlate.getk(NRCardDefs.card_def(ice), "on-break-subs", null) if ice else null)
							var event_args = ({
								"card-abilities": ability_as_handler(ice, on_break_subs),
							} if on_break_subs else null)
							return NREid.wait_for(state, eid, func(ne):
								NREngine.trigger_event_simult(state, side, ne, "subroutines-broken", event_args, break_subs_event_context(state, ice, subs_to_break, card))
							, func(async_result):
								NREid.effect_completed(state, side, eid))
						).call()
					).call()
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Gravedigger", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever an installed Corp card is trashed, place 1 virus counter on Gravedigger.\n[Click], <strong>hosted virus counter:</strong> The Corp trashes the top card of R&D.",
		"code": "07041",
		"title": "Gravedigger",
	}, (func():
		var e = {
			"req": func(state, side, eid, card, targets): return (NRCard.installed(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null)) and NRCard.corp(NRCardXlate.getk(NRCardXlate.first_target(targets), "card", null))),
			"msg": func(state, side, eid, card, targets): return str("place 1 virus counter on ") + str(NRCardXlate.getk(card, "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "virus", 1, null),
		}
		return {
			"events": [
				NRUtil.merge(e if e is Dictionary else {}, {"event": "runner-trash"}),
				NRUtil.merge(e if e is Dictionary else {}, {"event": "corp-trash"}),
			],
			"abilities": [
				{
				"action": true,
				"async": true,
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("virus", 1)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)).is_empty()),
				},
				"keep-menu-open": "while-virus-tokens-left",
				"msg": "force the Corp to trash the top card of R&D",
				"effect": func(state, side, eid, card, targets):
					return NRMoving.mill(state, "corp", eid, "corp", 1),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("GS Sherman M3", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter - Cloud",
		"subtypes": ["Icebreaker", "Fracter", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "09050",
		"title": "GS Sherman M3",
	}, global_sec_breaker("Barrier")))

	NRCardDefs.defcard("GS Shrike M2", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 5,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Cloud",
		"subtypes": ["Icebreaker", "Killer", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "09049",
		"title": "GS Shrike M2",
	}, global_sec_breaker("Sentry")))

	NRCardDefs.defcard("GS Striker M1", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Sunny Lebeau",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Cloud",
		"subtypes": ["Icebreaker", "Decoder", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>code gate</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "09048",
		"title": "GS Striker M1",
	}, global_sec_breaker("Code Gate")))

	NRCardDefs.defcard("Harbinger", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Apex",
		"cost": 0,
		"memoryunits": 0,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[interrupt] → When this program would be trashed, turn it facedown instead of adding it to your heap. <em>(It is still considered trashed.)</em>",
		"code": "09034",
		"title": "Harbinger",
	}, {
		"on-trash": {
			"req": func(state, side, eid, card, targets): return (not (NRUtil.find_first(NRUtil.as_array(NRCard.get_zone(card)), func(_x): return NRUtil.in_coll(["facedown", "hand"], _x)) != null)),
			"effect": func(state, side, eid, card, targets):
				return ((func():
				var locks = state.get_in(["runner", "locked", "discard"], null)
				return (func():
					(func():
						for lock in NRUtil.as_array(locks):
							NRFlags.release_zone(state, side, lock, "runner", "discard")
						return null
					).call()
					NRMoving.flip_facedown(state, side, card)
					return (func():
						for lock in NRUtil.as_array(locks):
							NRFlags.lock_zone(state, side, lock, "runner", "discard")
						return null
					).call()
				).call()
			).call() if NRFlags.zone_locked(state, "runner", "discard") else NRMoving.flip_facedown(state, side, card)),
		},
	}))

	NRCardDefs.defcard("Heliamphora", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "[interrupt] → Whenever you would access a card in Archives, you may host it faceup on this program instead. <em>(It is not installed.)</em> Use this ability only once each time you breach Archives.\nWhen the Corp purges virus counters, they trash 2 cards from HQ at random. Trash this program.",
		"code": "34072",
		"title": "Heliamphora",
	}, {
		"events": [
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return ((("archives" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("archives", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))) and (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "discard", null)).is_empty())),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				turn_archives_faceup(state, side, ne, ["archives"])
			, func(async_result):
				(func():
				NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "host-available"], true))
				return NREngine.continue_ability(state, side, {
					"optional": {
						"prompt": "Host a card on this program instead of accessing it?",
						"yes-ability": {
							"prompt": "Choose a card in Archives",
							"choices": func(state, side, eid, card, targets):
								return NRCardXlate.getk(state.getv("corp", {}), "discard", null),
							"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" on itself instead of accessing it"),
							"effect": func(state, side, eid, card, targets):
								NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "host-available"], false))
								return NRHosting.host(state, side, card, NRCardXlate.first_target(targets)),
						},
					},
				}, card, null)
			).call()),
		},
			{
			"event": "pre-access-card",
			"req": func(state, side, eid, card, targets): return (func():
				var target = NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)
				return (NRUtil.get_in(card, ["special", "host-available"], null) and NRCard.in_discard(NRCardXlate.first_target(targets)) and (NRCard.agenda(NRCardXlate.first_target(targets)) or (not (NRCardXlate.getk(NRCardXlate.first_target(targets), "seen", null))) or NRCardXlate.getk(NRCardXlate.first_target(targets), "poison", null)))
			).call(),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var target_card = NRCardXlate.first_target(targets)
				var is_facedown_p = (not (NRCardXlate.getk(NRCardXlate.first_target(targets), "seen", null)))
				var is_agenda_p = NRCard.agenda(NRCardXlate.first_target(targets))
				var is_poison_p = NRCardXlate.getk(NRCardXlate.first_target(targets), "poison", null)
				return NREngine.continue_ability(state, side, ({
					"optional": {
						"prompt": "Host face-down card on this program instead of accessing it?",
						"yes-ability": {
							"msg": "host a facedown card on itself instead of accessing it",
							"effect": func(state, side, eid, card, targets):
								NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "host-available"], false))
								return NRHosting.host(state, side, card, target_card),
						},
					},
				} if is_facedown_p else ({
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Host ") + str(NRCardXlate.getk(target_card, "title", null)) + str(" on this program instead of accessing it?"),
						"yes-ability": {
							"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(target_card, "title", null)) + str(" on itself instead of accessing it"),
							"effect": func(state, side, eid, card, targets):
								NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "host-available"], false))
								return NRHosting.host(state, side, card, target_card),
						},
					},
				} if (is_agenda_p or is_poison_p) else null)), card, null)
			).call(),
		},
			{
			"event": "purge",
			"msg": "force the Corp to trash 2 cards from HQ at random, then trash itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRMoving.trash_cards(state, "corp", ne, NREid.make_eid(state, eid), NRUtil.take_n(NRUtil.as_array(shuffle(NRCardXlate.getk(state.getv("corp", {}), "hand", null))), int(2)), {
				"cause-card": card,
			})
			, func(async_result):
				NRMoving.trash(state, "runner", eid, card, {
				"cause": "purge",
				"cause-card": card,
			})),
		},
		],
	}))

	NRCardDefs.defcard("Hantu", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Virus",
		"subtypes": ["Icebreaker", "Killer", "Virus"],
		"text": "When you install this program, place 2 virus counters on it.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>Hosted virus counter:</strong> +2 strength.",
		"code": "35008",
		"title": "Hantu",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"virus": 2,
			},
		},
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Sentry"),
			NRCardXlate.strength_pump([NRPayment.to_c("virus", 1), 3], 2),
		],
	})))

	NRCardDefs.defcard("Hemorrhage", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run, place 1 virus counter on Hemorrhage.\n[Click], <strong>2 hosted virus counters:</strong> The Corp trashes 1 card from HQ.",
		"code": "20012",
		"title": "Hemorrhage",
	}, {
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("virus", 2)],
			"keep-menu-open": "while-2-virus-tokens-left",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return (not NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).is_empty()),
			},
			"msg": "force the Corp to trash 1 card from HQ",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, "corp", {
				"waiting-prompt": true,
				"prompt": "Choose a card to trash",
				"choices": func(state, side, eid, card, targets):
					return NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "hand", null)).filter(NRCard.corp),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NRMoving.trash(state, side, eid, NRCardXlate.first_target(targets), {
					"cause-card": card,
					"cause": "forced-to-trash",
				}),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Hivemind", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 2,
		"factioncost": 5,
		"uniqueness": true,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Place 1 virus counter on Hivemind when it is installed.\nVirus counters on Hivemind are considered to be hosted on all other <strong>virus</strong> programs for the purposes of card effects (and can be spent as if on them).",
		"code": "07042",
		"title": "Hivemind",
	}, {
		"data": {
			"counter": {
				"virus": 1,
			},
		},
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(card, "virus") > 0),
			"label": "Move hosted virus counters",
			"prompt": "Choose a Virus card to move hosted virus counters to",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Virus"),
				"not-self": true,
			},
			"msg": func(state, side, eid, card, targets): return str("manually move a virus counter from itself to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, "runner", ne, NRCardXlate.first_target(targets), "virus", 1, {
				"suppress-checkpoint": true,
			})
			, func(async_result):
				NRProps.add_counter(state, "runner", eid, card, "virus", -1, null)),
		},
		],
	}))

	NRCardDefs.defcard("Houdini", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +4 strength for the remainder of this run. Use this ability only by spending at least 1 credit from a <strong>stealth</strong> card.",
		"code": "11045",
		"title": "Houdini",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 2, {
			"stealth": 1,
		}), 4, "end-of-run"),
		],
	})))

	NRCardDefs.defcard("Hush", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nHost ice cannot gain abilities and loses all abilities except its printed subroutines.\n<strong>[Click]:</strong> Host this program on another installed piece of ice.",
		"code": "33071",
		"title": "Hush",
	}, ({
		"implementation": "Experimentally implemented. If it doesn't work correctly, please file a bug report with the exact case and cards used, and we will investigate.",
		"static-abilities": [
			{
			"type": "disable-card",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": true,
		},
		],
		"abilities": [
			{
			"action": true,
			"label": "Host on a piece of ice",
			"prompt": "Choose a piece of ice",
			"cost": [NRPayment.to_c("click", 1)],
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets))),
			},
			"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				NRHosting.host(state, side, NRCardXlate.first_target(targets), card)
				return update_disabled_cards(state),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Hyperbaric", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "When you install this program, place 1 power counter on it.\nThis program gets +1 strength for each hosted power counter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> Place 1 power counter on this program.",
		"code": "33026",
		"title": "Hyperbaric",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 1,
			},
		},
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			{
			"cost": [NRPayment.to_c("credit", 2)],
			"msg": "place 1 power counter",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
		],
	})))

	NRCardDefs.defcard("Hyperdriver", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 3,
		"factioncost": 3,
		"uniqueness": false,
		"text": "When your turn begins, you may remove Hyperdriver from the game and gain [Click][Click][Click].",
		"code": "08070",
		"title": "Hyperdriver",
	}, {
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return true,
		},
		"abilities": [
			{
			"label": "Remove Hyperdriver from the game to gain [Click] [Click] [Click]",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"effect": func(state, side, eid, card, targets):
				NRMoving.move(state, side, card, "rfg")
				return NRGaining.gain_clicks(state, side, 3),
			"msg": "gain [Click][Click][Click]",
		},
		],
	}))


static func _register_4() -> void:
	NRCardDefs.defcard("Ika", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Trojan",
		"subtypes": ["Icebreaker", "Killer", "Trojan"],
		"text": "<strong>2[Credits]:</strong> Host this program on a piece of ice.\nInterface → <strong>1[Credits]:</strong> Break up to 2 subroutines on host <strong>sentry</strong>.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "22019",
		"title": "Ika",
	}, NRCardXlate.auto_icebreaker({
		"implementation": "[Erratum] Program: Icebreaker - Killer - Trojan",
		"abilities": [
			{
			"label": "Host on a piece of ice",
			"prompt": "Choose a piece of ice",
			"cost": [NRPayment.to_c("credit", 2)],
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets))),
			},
			"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
			"effect": func(state, side, eid, card, targets):
				return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
		},
			NRCardXlate.break_sub(1, 2, "Sentry"),
			NRCardXlate.strength_pump(2, 3),
		],
	})))

	NRCardDefs.defcard("Imp", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When you install this program, place 2 virus counters on it.\nAccess, once per turn → <strong>Hosted virus counter:</strong> Trash the card you are accessing.",
		"code": "31007",
		"title": "Imp",
	}, {
		"data": {
			"counter": {
				"virus": 2,
			},
		},
		"interactions": {
			"access-ability": {
				"label": "Trash card",
				"trash?": true,
				"req": func(state, side, eid, card, targets): return (NRFlags.can_trash(state, "runner", NRCardXlate.first_target(targets)) and (not (NRCard.in_discard(NRCardXlate.first_target(targets)))) and (not (state.get_in(["per-turn", NRCardXlate.getk(card, "cid", null)], null)))),
				"cost": [NRPayment.to_c("virus", 1)],
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

	NRCardDefs.defcard("Incubator", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When your turn begins, place 1 virus counter on Incubator.\n[Click], [Trash]: Move all virus counters from Incubator to another installed <strong>virus</strong> program.",
		"code": "06113",
		"title": "Incubator",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("trash-can")],
			"label": "move hosted virus counters",
			"msg": func(state, side, eid, card, targets): return str("move ") + str(NRCard.get_counters(card, "virus")) + str(" virus counter to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.has_subtype(_pct, "Virus")),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, NRCardXlate.first_target(targets), "virus", NRCard.get_counters(card, "virus"), null),
		},
		],
	}))

	NRCardDefs.defcard("Inti", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength for the remainder of this run.",
		"code": "03048",
		"title": "Inti",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier"),
			NRCardXlate.strength_pump(2, 1, "end-of-run"),
		],
	})))

	NRCardDefs.defcard("Inversificator", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 6,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "The first time each turn you pass a piece of ice after an encounter during which this program fully broke that ice, you may swap it with another installed piece of ice.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "12048",
		"title": "Inversificator",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
		"events": [
			{
			"event": "pass-ice",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NREvents.first_event(state, side, "end-of-encounter", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card)
			).call())),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return {
					"optional": {
						"prompt": (str("Swap ") + str(NRCardXlate.getk(ice, "title", null)) + str(" with another ice?")),
						"yes-ability": {
							"prompt": "Choose another ice",
							"choices": {
								"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct) and (not (NRUtil.same_card(_pct, ice)))),
							},
							"msg": func(state, side, eid, card, targets): return str("swap the positions of ") + str(NRToString.card_str(state, ice)) + str(" and ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
							"effect": func(state, side, eid, card, targets):
								return NRMoving.swap_ice(state, side, NRCard.get_card(state, ice), NRCard.get_card(state, NRCardXlate.first_target(targets))),
						},
					},
				}
			).call(), card, null),
		},
		],
	})))

	NRCardDefs.defcard("Ixodidae", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever the Corp loses at least 1[Credits], gain 1[Credits].\nTrash Ixodidae if the Corp purges virus counters.",
		"code": "06114",
		"title": "Ixodidae",
	}, {
		"events": [
			{
			"event": "corp-credit-loss",
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
		},
			trash_on_purge,
		],
	}))

	NRCardDefs.defcard("K2CP Turbine", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"text": "Each installed non-<strong>AI</strong> <strong>icebreaker</strong> gets +2 strength.",
		"code": "33090",
		"title": "K2CP Turbine",
	}, {
		"static-abilities": [
			{
			"type": "breaker-strength",
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.first_target(targets), "Icebreaker") and (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "AI")))),
			"value": 2,
		},
		],
		"leave-play": func(state, side, eid, card, targets):
			return NRIce.update_all_icebreakers(state, side),
	}))

	NRCardDefs.defcard("Keyhole", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "<strong>[Click]:</strong> Run R&D. If successful, instead of breaching R&D, look at the top 3 cards of R&D. Trash 1 of those cards, then the Corp shuffles R&D.\n",
		"code": "04061",
		"title": "Keyhole",
	}, (func():
		var ability = NRCardXlate.successful_run_replace_breach({
			"target-server": "rd",
			"mandatory": true,
			"duration": "end-of-run",
			"ability": {
				"prompt": "Choose a card to trash",
				"not-distinct": true,
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"choices": func(state, side, eid, card, targets):
					return NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3)),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NRShuffling.shuffle_zone(state, "corp", "deck")
					return NRMoving.trash(state, side, eid, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}), {
					"cause-card": card,
				}),
			},
		})
		return {
			"abilities": [
				NRCardXlate.run_server_ability("rd", {
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"events": [ability],
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Knight", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"strength": 7,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Caïssa - Trojan",
		"subtypes": ["Icebreaker", "AI", "Caïssa", "Trojan"],
		"text": "Interface → <strong>2[Credits]:</strong> Break 1 subroutine on host ice.\n<strong>[Click]:</strong> Host this program on a piece of ice that is not hosting a <strong>Caïssa</strong> program.\nIf this program is hosted on ice, its [Click] ability cannot be used to host it on the next inward or outward piece of ice.",
		"code": "04043",
		"title": "Knight",
	}, (func():
		var knight_req = func(state, side, eid, card, targets):
			return (NRUtil.same_card(NRIce.get_current_ice(state), NRCard.get_nested_host(card)) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card)))
		return {
			"implementation": "[Erratum] Program: Icebreaker - AI - Caïssa - Trojan",
			"abilities": [
				{
				"action": true,
				"label": "Host on a piece of ice",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var k = NRCard.get_card(state, card)
					var hosted = NRCard.ice(NRCardXlate.getk(k, "host", null))
					var icepos = card_index(state, NRCard.get_card(state, NRCardXlate.getk(k, "host", null)))
					return NREngine.continue_ability(state, side, {
						"prompt": func(state, side, eid, card, targets): return str("Choose a piece of ice") + str((" not before or after the current host ice" if hosted else null)),
						"cost": [NRPayment.to_c("click", 1)],
						"choices": {
							"req": func(state, side, eid, card, targets): return (((((not (((1 == absi((card_index(state, NRCardXlate.first_target(targets)) - icepos))) or NRUtil.kw_eq(1, absi((card_index(state, NRCardXlate.first_target(targets)) - icepos)))))) if ((NRCard.get_zone(NRCardXlate.first_target(targets)) == NRCard.get_zone(NRCardXlate.getk(k, "host", null))) or NRUtil.kw_eq(NRCard.get_zone(NRCardXlate.first_target(targets)), NRCard.get_zone(NRCardXlate.getk(k, "host", null)))) else null) or (not (((NRCard.get_zone(NRCardXlate.first_target(targets)) == NRCard.get_zone(NRCardXlate.getk(k, "host", null))) or NRUtil.kw_eq(NRCard.get_zone(NRCardXlate.first_target(targets)), NRCard.get_zone(NRCardXlate.getk(k, "host", null))))))) and NRCard.ice(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets)) and (not (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "hosted", null)), func(c): return NRCard.has_subtype(c, "Caïssa")) != null))) if hosted else (NRCard.ice(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets)) and (not (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "hosted", null)), func(c): return NRCard.has_subtype(c, "Caïssa")) != null)))),
						},
						"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
						"effect": func(state, side, eid, card, targets):
							return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
					}, card, null)
				).call(),
			},
				NRCardXlate.break_sub(2, 1, "All", {
				"req": knight_req,
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Kyuban", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nWhenever you pass host ice, gain 2[Credits].",
		"code": "22020",
		"title": "Kyuban",
	}, ({
		"implementation": "[Erratum] Program: Trojan",
		"events": [
			{
			"event": "pass-ice",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), NRCardXlate.getk(card, "host", null)),
			"msg": "gain 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 2),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Laamb", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Once per turn → When you encounter a piece of ice, you may pay 2[Credits]. If you do, it gains <strong>barrier</strong> for the remainder of that encounter.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.\n<strong>3[Credits]:</strong> +6 strength.",
		"code": "21086",
		"title": "Laamb",
	}, give_ice_subtype(2, "Barrier", [NRCardXlate.break_sub(2, 0, "Barrier"), NRCardXlate.strength_pump(3, 6)])))

	NRCardDefs.defcard("Lampades", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When you install this program, place 3 power counters on it.\nAccess → <strong>Hosted power counter</strong>, <strong>pay the printed rez or play cost of the card you are accessing:</strong> Trash that card. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "36005",
		"title": "Lampades",
	}, {
		"interactions": {
			"access-ability": {
				"async": true,
				"trash?": true,
				"label": "Trash card",
				"req": func(state, side, eid, card, targets): return ((not (NRCardXlate.getk(card, "disabled", null))) and (not (NRCard.agenda(NRCardXlate.first_target(targets)))) and (not (NRCard.in_discard(NRCardXlate.first_target(targets)))) and NRPayment.can_pay(state, side, eid, card, null, [
					NRPayment.to_c("power", 1),
					NRPayment.to_c("credit", NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", 0), {
					"stealth": "all-stealth",
				}),
				])),
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					return (func():
					var accessed_card = NRCardXlate.first_target(targets)
					var play_or_rez = NRCardXlate.getk(NRCardXlate.first_target(targets), "cost", null)
					return NREngine.continue_ability(state, side, {
						"async": true,
						"cost": [
							NRPayment.to_c("power", 1),
							NRPayment.to_c("credit", NRCardXlate.getk(accessed_card, "cost", 0), {
							"stealth": "all-stealth",
						}),
						],
						"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(accessed_card, "title", null)),
						"effect": func(state, side, eid, card, targets):
							return NRMoving.trash(state, side, eid, NRUtil.merge(accessed_card if accessed_card is Dictionary else {}, {"seen": true}), {
							"accessed": true,
						}),
					}, card, null)
				).call(),
			},
		},
		"data": {
			"counter": {
				"power": 3,
			},
		},
	}))

	NRCardDefs.defcard("Lamprey", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on HQ, the Corp loses 1[Credits].\nTrash Lamprey if the Corp purges virus counters.",
		"code": "25014",
		"title": "Lamprey",
	}, {
		"events": [
			{
			"event": "successful-run",
			"automatic": "drain-credits",
			"req": func(state, side, eid, card, targets): return (("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"msg": "force the Corp to lose 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.lose_credits(state, "corp", eid, 1),
		},
			trash_on_purge,
		],
	}))

	NRCardDefs.defcard("Laser Pointer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Weapon",
		"subtypes": ["Weapon"],
		"text": "Whenever you encounter a piece of <strong>AP</strong>, <strong>destroyer</strong>, or <strong>observer</strong> ice, you may trash this program to bypass that ice.",
		"code": "34016",
		"title": "Laser Pointer",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"req": func(state, side, eid, card, targets): return NRCard.has_any_subtype(NRIce.get_current_ice(state), ["AP", "Observer", "Destroyer"]),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"optional": {
					"prompt": func(state, side, eid, card, targets): return str("Trash this program to bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str("?"),
					"waiting-prompt": true,
					"yes-ability": {
						"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NREid.wait_for(state, eid, func(ne):
							NRMoving.trash(state, "runner", ne, NREid.make_eid(state, eid), card, {
							"unpreventable": "true",
							"cause-card": card,
						})
						, func(async_result):
							(func():
							NRCardXlate.bypass_ice(state)
							return NREid.effect_completed(state, side, eid)
						).call()),
					},
				},
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Leech", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on a central server, place 1 virus counter on this program.\n<strong>Hosted virus counter:</strong> The ice you are encountering gets -1 strength for the remainder of this encounter.",
		"code": "30008",
		"title": "Leech",
	}, {
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return NRServers.is_central(NRServers.target_server(NRCardXlate.ctx(targets))),
			"msg": "place 1 virus counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"abilities": [
			{
			"cost": [NRPayment.to_c("virus", 1)],
			"label": "Give -1 strength to current piece of ice",
			"req": func(state, side, eid, card, targets): return NRRuns.active_encounter(state),
			"keep-menu-open": "while-virus-tokens-left",
			"msg": func(state, side, eid, card, targets): return str("give -1 strength to ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return pump_ice(state, side, NRIce.get_current_ice(state), -1),
		},
		],
	}))

	NRCardDefs.defcard("Leprechaun", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Daemon",
		"subtypes": ["Daemon"],
		"text": "Leprechaun can host up to 2 programs. The memory costs of hosted programs do not count against your memory limit.",
		"code": "06019",
		"title": "Leprechaun",
	}, {
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return NRCard.program(NRCardXlate.first_target(targets)),
			"no-mu": true,
			"max-cards": 2,
		},
		],
	}))

	NRCardDefs.defcard("Leviathan", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 6,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>3[Credits]:</strong> Break up to 3 <strong>code gate</strong> subroutines.\n<strong>3[Credits]:</strong> +5 strength.",
		"code": "04026",
		"title": "Leviathan",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(3, 3, "Code Gate"), NRCardXlate.strength_pump(3, 5)],
	})))

	NRCardDefs.defcard("Living Mural", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Trojan",
		"subtypes": ["Icebreaker", "Killer", "Trojan"],
		"text": "Install only on a piece of ice.\nThreat 4 → When you install this program, it gets +3 strength for the remainder of the turn. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine on a <strong>sentry</strong> protecting this server.\n<strong>1[Credits]:</strong> +2 strength.",
		"code": "34024",
		"title": "Living Mural",
	}, ({
		"on-install": {
			"req": func(state, side, eid, card, targets): return NRThreat.threat_level(4, state),
			"msg": "gain 3 strength for the remainder of the turn",
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, card, 3, "end-of-turn"),
		},
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Sentry", {
			"req": func(state, side, eid, card, targets): return NRServers.protecting_same_server(NRIce.get_current_ice(state), NRCardXlate.getk(card, "host", null)),
		}),
			NRCardXlate.strength_pump(1, 2),
		],
	}).call(trojan(NRCardXlate.auto_icebreaker))))

	NRCardDefs.defcard("LLDS Energy Regulator", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[interrupt] → <strong>3[Credits]</strong> or [Trash]<strong>:</strong> Prevent a player from trashing 1 installed piece of hardware.",
		"code": "06039",
		"title": "LLDS Energy Regulator",
	}, (func():
		return {
			"prevention": [
				prevent_trash_installed_by_type("3 [Credits]: LLDS Energy Regulator", ["Hardware"], [NRPayment.to_c("credit", 3)], valid_context_p),
				prevent_trash_installed_by_type("[Trash]: LLDS Energy Regulator", ["Hardware"], [NRPayment.to_c("trash-can")], valid_context_p),
			],
		}
	).call()))

	NRCardDefs.defcard("Lobisomem", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 8,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Fracter",
		"subtypes": ["Icebreaker", "Decoder", "Fracter"],
		"text": "When you install this program and whenever it fully breaks a <strong>code gate</strong>, place 1 power counter on this program.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\nInterface → <strong>X[Credits]</strong>, <strong>hosted power counter:</strong> Break X <strong>barrier</strong> subroutines.\n<strong>1[Credits]:</strong> +2 strength.",
		"code": "34090",
		"title": "Lobisomem",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 1,
			},
		},
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate", {
			"auto-break-sort": 1,
		}),
			{
			"label": "Break X Barrier subroutines",
			"cost": [NRPayment.to_c("x-credits"), NRPayment.to_c("power", 1)],
			"break-cost": [NRPayment.to_c("x-credits"), NRPayment.to_c("power", 1)],
			"auto-break-creds-per-sub": 1,
			"break": 0,
			"break-req": func(state, side, eid, card, targets):
				return (NRRuns.active_encounter(state) and NRCard.has_subtype(NRIce.get_current_ice(state), "Barrier")),
			"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
			"msg": func(state, side, eid, card, targets): return str("break ") + str(NRUtil.quantify(NRPayment.cost_value(eid, "x-credits"), "subroutine")) + str(" on ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (NRCardXlate.break_sub(null, NRPayment.cost_value(eid, "x-credits"), "Barrier") if (NRPayment.cost_value(eid, "x-credits") > 0) else null), card, null),
		},
			NRCardXlate.strength_pump(1, 2),
		],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Code Gate")),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
	})))

	NRCardDefs.defcard("Lustig", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +5 strength.\n<strong>[Trash]:</strong> Bypass the <strong>sentry</strong> you are encountering.",
		"code": "13007",
		"title": "Lustig",
	}, trash_to_bypass(NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(3, 5))))

	NRCardDefs.defcard("Magnum Opus", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "[Click]: Gain 2[Credits].",
		"code": "20050",
		"title": "Magnum Opus",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"keep-menu-open": "while-clicks-left",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRSay.play_sfx(state, side, "click-credit-2")
				return NRGaining.gain_credits(state, side, eid, 2),
			"msg": "gain 2 [Credits]",
		},
		],
	}))

	NRCardDefs.defcard("Makler", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +2 strength.\nThe first time each turn this program fully breaks a piece of ice, gain 1[Credits].",
		"code": "26080",
		"title": "Makler",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 2, "Barrier"), NRCardXlate.strength_pump(2, 2)],
		"events": [
			{
			"event": "pass-ice",
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NREvents.first_event(state, side, "pass-ice", func(targets): return (func():
				var context = NRUtil.first_of(targets)
				return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card)
			).call())),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 1),
		},
		],
	})))

	NRCardDefs.defcard("Malandragem", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"text": "When you install this program, load 2 power counters onto it. When it is empty, remove it from the game.\nOnce per turn → When you encounter a piece of ice, if its strength is 3 or less, you may remove 1 hosted power counter to bypass it.\nThreat 4 → Whenever you encounter a piece of ice, you may remove this program from the game to bypass it.",
		"code": "34081",
		"title": "Malandragem",
	}, {
		"data": {
			"counter": {
				"power": 2,
			},
		},
		"events": [
			rfg_on_empty("power"),
			{
			"event": "encounter-ice",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"ability-name": "Malandragem (rfg)",
			"optional": {
				"prompt": "Remove this program from the game to bypass encountered ice?",
				"req": func(state, side, eid, card, targets): return NRThreat.threat_level(4, state),
				"yes-ability": {
					"cost": [NRPayment.to_c("remove-from-game")],
					"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
					"effect": func(state, side, eid, card, targets):
						return NRCardXlate.bypass_ice(state),
				},
			},
		},
			{
			"event": "encounter-ice",
			"skippable": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"ability-name": "Malandragem (Power counter)",
			"change-in-game-state": {
				"silent": true,
				"req": func(state, side, eid, card, targets): return (3 >= NRIce.ice_strength(state, side, NRIce.get_current_ice(state))),
			},
			"optional": {
				"prompt": "Remove 1 power counter to bypass encountered ice?",
				"once": "per-turn",
				"req": func(state, side, eid, card, targets): return (1 <= NRCard.get_counters(NRCard.get_card(state, card), "power")),
				"yes-ability": {
					"cost": [NRPayment.to_c("power", 1)],
					"msg": func(state, side, eid, card, targets): return str("bypass ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
					"effect": func(state, side, eid, card, targets):
						return NRCardXlate.bypass_ice(state),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Mammon", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "When your turn begins, you may spend any number of credits to place that many power counters on this program.\nWhen your discard phase ends, remove all hosted power counters.\nInterface → <strong>Hosted power counter:</strong> Break 1 subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "13009",
		"title": "Mammon",
	}, NRCardXlate.auto_icebreaker({
		"flags": {
			"runner-phase-12": func(state, side, eid, card, targets):
				return (NRCardXlate.getk(state.getv("runner", {}), "credit", null) > 0),
		},
		"abilities": [
			{
			"label": "Place X power counters",
			"prompt": "How many credits do you want to spend?",
			"once": "per-turn",
			"cost": [NRPayment.to_c("x-credits")],
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", NRPayment.cost_value(eid, "x-credits"), null),
			"msg": func(state, side, eid, card, targets): return str("place ") + str(NRUtil.quantify(NRPayment.cost_value(eid, "x-credits"), "power counter")) + str(" on itself"),
		},
			NRCardXlate.break_sub([NRPayment.to_c("power", 1)], 1),
			NRCardXlate.strength_pump(2, 2),
		],
		"events": [
			{
			"event": "runner-turn-ends",
			"silent": true,
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["counter", "power"], 0)),
		},
		],
	})))

	NRCardDefs.defcard("Mantle", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Stealth",
		"subtypes": ["Stealth"],
		"text": "1[recurring-credit]\nYou can spend hosted credits to use hardware and programs.",
		"code": "26088",
		"title": "Mantle",
	}, {
		"recurring": 1,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and (NRCard.hardware(NRCardXlate.first_target(targets)) or NRCard.program(NRCardXlate.first_target(targets)))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Marjanah", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine. If you made a successful run this turn, this ability costs 1[Credits] less to use.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "30016",
		"title": "Marjanah",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(2, 1, "Barrier", {
			"label": "Break 1 Barrier subroutine",
			"break-cost-bonus": func(state, side, eid, card, targets):
				return ([NRPayment.to_c("credit", -1)] if NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null) else null),
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Mass-Driver", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 8,
		"strength": 1,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Whenever this program fully breaks a piece of ice, the first 3 subroutines of the next encounter this run do not resolve.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "12067",
		"title": "Mass-Driver",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": "prevent the first 3 subroutines from resolving on the next encountered ice",
			"effect": func(state, side, eid, card, targets):
				return NREngine.register_events(state, side, card, (func():
				var broken_ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return [
					{
					"event": "encounter-ice",
					"duration": "end-of-run",
					"unregister-once-resolved": true,
					"effect": func(state, side, eid, card, targets):
						return (func():
						for sub in NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "subroutines", null)), int(3))):
							dont_resolve_subroutine_bang(state, NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)), sub)
						return null
					).call(),
				},
				]
			).call()),
		},
		],
	})))

	NRCardDefs.defcard("Matryoshka", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 3,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "When your turn begins, turn each hosted card faceup.\n[Click]<strong>:</strong> Host a copy of Matryoshka from your grip faceup on this program. <em>(It is not installed.)</em>\nInterface → <strong>X[Credits]</strong>, <strong>turn 1 hosted copy of Matryoshka facedown:</strong> Break X subroutines.\n<strong>1[Credits]:</strong> +1 strength.\nLimit 6 per deck.",
		"code": "33094",
		"title": "Matryoshka",
	}, (func():
		var break_abi = {
			"label": "Break X subroutines",
			"cost": [
				NRPayment.to_c("x-credits"),
				NRPayment.to_c("turn-hosted-matryoshka-facedown", 1),
			],
			"break-cost": [
				NRPayment.to_c("x-credits"),
				NRPayment.to_c("turn-hosted-matryoshka-facedown", 1),
			],
			"async": true,
			"auto-break-creds-per-sub": 1,
			"break": 0,
			"break-req": func(state, side, eid, card, targets):
				return NRRuns.active_encounter(state),
			"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
			"msg": func(state, side, eid, card, targets): return str("break ") + str(NRUtil.quantify(NRPayment.cost_value(eid, "x-credits"), "subroutine")) + str(" on ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (NRCardXlate.break_sub(null, NRPayment.cost_value(eid, "x-credits"), "All", {
				"repeatable": false,
			}) if (NRPayment.cost_value(eid, "x-credits") > 0) else null), card, null),
		}
		var host_abi = {
			"action": true,
			"label": "Host 1 copy of Matryoshka",
			"prompt": func(state, side, eid, card, targets): return str("Choose 1 copy of ") + str(NRCardXlate.getk(card, "title", null)) + str(" in the grip"),
			"keep-menu-open": "while-clicks-left",
			"cost": [NRPayment.to_c("click", 1)],
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.in_hand(_pct) and ((NRCardXlate.getk(_pct, "title", null) == "Matryoshka") or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), "Matryoshka"))),
			},
			"msg": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" on itself"),
			"effect": func(state, side, eid, card, targets):
				return NRHosting.host(state, "runner", card, NRCardXlate.first_target(targets)),
		}
		return NRCardXlate.auto_icebreaker({
			"abilities": [host_abi, break_abi, NRCardXlate.strength_pump(1, 1)],
			"events": [
				{
				"event": "runner-turn-begins",
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null)), func(_pct, _pct2=null, _pct3=null): return NRCard.facedown(_pct)) != null),
				"msg": "turn all cards hosted on itself face-up",
				"effect": func(state, side, eid, card, targets):
					return (func():
					var targets = NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.facedown(_pct))
					return (func():
						for oc in NRUtil.as_array(targets):
							(func():
						var newcard = NRUtil.merge(oc if oc is Dictionary else {}, {"facedown": null})
						return NRUpdate.update_card(state, side, newcard)
					).call()
						return null
					).call()
				).call(),
			},
			],
		})
	).call()))

	NRCardDefs.defcard("Maven", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 5,
		"strength": 0,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "This program gets +1 strength for each installed program.\nInterface → <strong>2[Credits]:</strong> Break 1 subroutine.",
		"code": "12087",
		"title": "Maven",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1)],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(NRCard.program)).size()),
		],
	})))

	NRCardDefs.defcard("Mayfly", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 1,
		"strength": 1,
		"memoryunits": 2,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine. When this run ends, trash this program.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "30032",
		"title": "Mayfly",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"additional-ability": {
				"msg": "will trash itself when this run ends",
				"effect": func(state, side, eid, card, targets):
					return NREngine.register_events(state, "runner", NRCard.get_card(state, card), [
					{
					"event": "run-ends",
					"duration": "end-of-run",
					"unregister-once-resolved": true,
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, side, eid, card, {
						"cause": "runner-ability",
						"cause-card": card,
					}),
				},
				]),
			},
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Medium", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on R&D, place 1 virus counter on this program.\nWhenever you breach R&D, choose a number less than the number of hosted virus counters. Access that many additional cards.",
		"code": "29001",
		"title": "Medium",
	}, {
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"req": func(state, side, eid, card, targets): return (("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"req": func(state, side, eid, card, targets): return (1 < NRVirus.get_virus_counters(state, card)),
				"prompt": "How many additional cards from R&D do you want to access?",
				"choices": {
					"number": func(state, side, eid, card, targets):
						return (NRVirus.get_virus_counters(state, card) - 1),
					"default": func(state, side, eid, card, targets):
						return (NRVirus.get_virus_counters(state, card) - 1),
				},
				"msg": func(state, side, eid, card, targets): return str("access ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "additional card")) + str(" from R&D"),
				"effect": func(state, side, eid, card, targets):
					return NRAccess.access_bonus(state, side, "rd", maxi(0, NRCardXlate.first_target(targets))),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Mimic", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.",
		"code": "31008",
		"title": "Mimic",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry")],
	})))

	NRCardDefs.defcard("Misdirection", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "[Click], [Click], X[Credits]: Remove X tags.",
		"code": "11085",
		"title": "Misdirection",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2), NRPayment.to_c("x-credits")],
			"label": "remove X tags",
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("remove ") + str(NRUtil.quantify(NRPayment.cost_value(eid, "x-credits"), "tag")),
			"effect": func(state, side, eid, card, targets):
				return NRTags.lose_tags(state, "runner", eid, NRPayment.cost_value(eid, "x-credits")),
		},
		],
	}))

	NRCardDefs.defcard("MKUltra", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Whenever you encounter a <strong>sentry</strong>, you may install this program from your heap.\n<strong>3[Credits]:</strong> +2 strength. Then, if this program can interface with the <strong>sentry</strong> you are encountering, break up to 2 subroutines.",
		"code": "11081",
		"title": "MKUltra",
	}, (func():
		var events = NRUtil.as_array([
			"run",
			"approach-ice",
			"encounter-ice",
			"pass-ice",
			"run-ends",
			"ice-strength-changed",
			"ice-subtype-changed",
			"breaker-strength-changed",
			"subroutines-changed",
		]).map(func(event): return NRUtil.merge(heap_breaker_auto_pump_and_break if heap_breaker_auto_pump_and_break is Dictionary else {}, {"event": event}))
		var cdef = install_from_heap("MKUltra", "Sentry", [pump_and_break([NRPayment.to_c("credit", 3)], 2, "Sentry")])
		return NRUtil.merge(cdef if cdef is Dictionary else {}, {"events": conj.callv(NRUtil.as_array(NRCardXlate.getk(cdef, "events", null)))})
	).call()))

	NRCardDefs.defcard("Mongoose", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "You cannot use this program to break subroutines on more than one ice per run.\nInterface → <strong>1[Credits]:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "10005",
		"title": "Mongoose",
	}, NRCardXlate.auto_icebreaker({
		"events": [
			{
			"event": "subroutines-broken",
			"silent": true,
			"req": func(state, side, eid, card, targets): return (any_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and state.getv("run")),
			"effect": func(state, side, eid, card, targets):
				return (func():
				var broken_ice = NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)
				return NREffects.register_lingering_effect(state, side, card, {
					"type": "prevent-paid-ability",
					"duration": "end-of-run",
					"req": func(state, side, eid, card, targets): return (func():
						var _destructured_0 = targets
						return ((not (NRUtil.same_card(NRIce.get_current_ice(state), broken_ice))) and NRUtil.same_card(break_card, card))
					).call(),
					"value": func(state, side, eid, card, targets):
						return true,
				})
			).call(),
		},
		],
		"abilities": [NRCardXlate.break_sub(1, 2, "Sentry"), NRCardXlate.strength_pump(2, 2)],
	})))

	NRCardDefs.defcard("Monkeywrench", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nHost ice gets −2 strength. Each other piece of ice protecting this server gets −1 strength.",
		"code": "34006",
		"title": "Monkeywrench",
	}, ({
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and ((NRCard.get_zone(NRCardXlate.getk(card, "host", null)) == NRCard.get_zone(NRCardXlate.first_target(targets))) or NRUtil.kw_eq(NRCard.get_zone(NRCardXlate.getk(card, "host", null)), NRCard.get_zone(NRCardXlate.first_target(targets))))),
			"value": func(state, side, eid, card, targets):
				return (-2 if NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)) else -1),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Morning Star", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 8,
		"strength": 5,
		"memoryunits": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.",
		"code": "20014",
		"title": "Morning Star",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 0, "Barrier")],
	})))

	NRCardDefs.defcard("Multithreader", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Adam",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "2[recurring-credit]\nUse these credits to pay for using programs.",
		"code": "09040",
		"title": "Multithreader",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("ability" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("ability", NRCardXlate.getk(eid, "source-type", null))) and NRCard.program(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Musaazi", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"strength": 1,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Virus",
		"subtypes": ["Icebreaker", "Killer", "Virus"],
		"text": "Whenever you make a successful run, you may place 1 virus counter on this program.\nInterface → <strong>Any virus counter:</strong> Break <strong>sentry</strong> subroutine.\n<strong>Any virus counter:</strong> +1 strength.",
		"code": "21102",
		"title": "Musaazi",
	}, virus_breaker("Sentry")))


static func _register_5() -> void:
	NRCardDefs.defcard("Muse", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Daemon",
		"subtypes": ["Daemon"],
		"text": "When you install this program, search your stack, heap, or grip for 1 non-<strong>daemon</strong> program. <em>(Shuffle your stack after searching it.)</em> If that program is a <strong>trojan</strong>, install it on a piece of ice. Otherwise, install it on this program.",
		"code": "34091",
		"title": "Muse",
	}, (func():
		var _b0 = muse_abi([where], {
			"prompt": "Choose a non-daemon program",
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(where(state.getv("runner", {}))).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and (not (NRCard.has_subtype(_pct, "Daemon"))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct))))).is_empty())) + NRUtil.as_array(["Done"])),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				((func():
				NREngine.trigger_event(state, side, "searched-stack")
				NRSay.system_msg(state, side, (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to shuffle the stack")))
				return NRShuffling.shuffle_zone(state, side, "deck")
			).call() if (("deck" == where) or NRUtil.kw_eq("deck", where)) else null)
				return (func():
				var msg_keys = {
					"install-source": card,
					"display-origin": true,
				}
				return ((NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"host-card": NRCard.get_card(state, card),
					"msg-keys": msg_keys,
				}) if (not (NRCard.has_subtype(NRCardXlate.first_target(targets), "Trojan"))) else (NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"msg-keys": msg_keys,
				}) if trojan_auto_hosts_p(NRCardXlate.first_target(targets)) else (func():
					var target_card = NRCardXlate.first_target(targets)
					return NREngine.continue_ability(state, side, {
						"prompt": func(state, side, eid, card, targets): return str("Choose a piece of ice to host ") + str(NRCardXlate.getk(target_card, "title", null)),
						"choices": {
							"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct)),
						},
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), target_card, {
							"host-card": NRCard.get_card(state, NRCardXlate.first_target(targets)),
							"msg-keys": msg_keys,
						}),
					}, card, null)
				).call())) if (not (((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")))) else NREid.effect_completed(state, side, eid))
			).call(),
		})
		return {
			"on-install": {
				"async": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"prompt": "Choose where to install from",
				"choices": func(state, side, eid, card, targets):
					return [
					"Grip",
					"Stack",
					("Heap" if (not (NRFlags.zone_locked(state, "runner", "discard"))) else null),
				],
				"msg": func(state, side, eid, card, targets): return str("search the ") + str(NRCardXlate.first_target(targets)) + str(" for a non-daemon program to install"),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, muse_abi(("deck" if (("Stack" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Stack", NRCardXlate.first_target(targets))) else ("hand" if (("Grip" == NRCardXlate.first_target(targets)) or NRUtil.kw_eq("Grip", NRCardXlate.first_target(targets))) else "discard"))), card, null),
			},
		}
	).call()))

	NRCardDefs.defcard("Na'Not'K", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "During runs, this program gets +1 strength for each piece of ice protecting the attacked server.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +2 strength.",
		"code": "12088",
		"title": "Na'Not'K",
	}, NRCardXlate.auto_icebreaker({
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRUtil.as_array(run_ices).size()),
		],
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(3, 2)],
	})))

	NRCardDefs.defcard("Nanuq", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 3,
		"memoryunits": 2,
		"factioncost": 5,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "When this program is uninstalled, remove it from the game.\nWhen an agenda is scored or stolen, remove this program from the game.\nInterface → <strong>2[Credits]:</strong> Break up to 2 subroutines.\n1[Credits]: +1 strength.",
		"code": "33088",
		"title": "Nanuq",
	}, (func():
		var self_rfg = {
			"msg": "remove itself from the game",
			"once": "per-turn",
			"interactive": func(state, side, eid, card, targets):
				return true,
			"effect": func(state, side, eid, card, targets):
				return NRMoving.move(state, side, card, "rfg"),
		}
		return NRCardXlate.auto_icebreaker({
			"abilities": [NRCardXlate.break_sub(2, 2, "All"), NRCardXlate.strength_pump(1, 1)],
			"move-zone-replacement": func(state, side, eid, card, targets):
				return (func():
				var old = NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)
				var target_zone = NRCardXlate.getk(NRCardXlate.ctx(targets), "zone", null)
				return (["rfg"] if (NRCardXlate.getk(old, "installed", null) and (not (NRCardXlate.getk(NRCardXlate.ctx(targets), "shuffled", null))) and (not (NREffects.is_disabled_reg(state, old))) and (not (NRCardXlate.getk(old, "facedown", null))) and (not (((["rfg"] == target_zone) or NRUtil.kw_eq(["rfg"], target_zone))))) else null)
			).call(),
			"events": [
				NRUtil.merge(self_rfg if self_rfg is Dictionary else {}, {"event": "agenda-scored"}),
				NRUtil.merge(self_rfg if self_rfg is Dictionary else {}, {"event": "agenda-stolen"}),
			],
		})
	).call()))

	NRCardDefs.defcard("Nerve Agent", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Whenever you make a successful run on HQ, place 1 virus counter on this program.\nWhenever you breach HQ, choose a number less than the number of hosted virus counters. Access that many additional cards.",
		"code": "02041",
		"title": "Nerve Agent",
	}, {
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return (("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
			{
			"event": "breach-server",
			"automatic": "pre-breach",
			"async": true,
			"req": func(state, side, eid, card, targets): return (("hq" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("hq", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null))),
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"req": func(state, side, eid, card, targets): return (1 < NRVirus.get_virus_counters(state, card)),
				"prompt": "How many additional cards from HQ do you want to access?",
				"choices": {
					"number": func(state, side, eid, card, targets):
						return (NRVirus.get_virus_counters(state, card) - 1),
					"default": func(state, side, eid, card, targets):
						return (NRVirus.get_virus_counters(state, card) - 1),
				},
				"msg": func(state, side, eid, card, targets): return str("access ") + str(NRUtil.quantify(NRCardXlate.first_target(targets), "additional card")) + str(" from HQ"),
				"effect": func(state, side, eid, card, targets):
					return NRAccess.access_bonus(state, side, "hq", maxi(0, NRCardXlate.first_target(targets))),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Net Shield", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "[interrupt] → The first time each turn you would suffer net damage, you may pay 1[Credits] to prevent 1 net damage.",
		"code": "01045",
		"title": "Net Shield",
	}, {
		"prevention": [
			{
			"prevents": "damage",
			"type": "ability",
			"max-uses": 1,
			"ability": {
				"async": true,
				"cost": [NRPayment.to_c("credit", 1)],
				"msg": "prevent 1 net damage",
				"req": func(state, side, eid, card, targets): return ((("net" == NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRCardXlate.ctx(targets), "type", null))) and NRPrevention.preventable(NRCardXlate.ctx(targets)) and NREvents.first_event(state, side, "pre-damage-flag", func(_pct, _pct2=null, _pct3=null): return (("net" == NRCardXlate.getk(NRUtil.first_of(_pct), "type", null)) or NRUtil.kw_eq("net", NRCardXlate.getk(NRUtil.first_of(_pct), "type", null))))),
				"effect": func(state, side, eid, card, targets):
					return NRPrevention.prevent_damage(state, side, eid, 1),
			},
		},
		],
	}))

	NRCardDefs.defcard("Nfr", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Whenever this program fully breaks a piece of ice, place 1 power counter on this program.\nThis program gets +1 strength for each power counter on it.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.",
		"code": "11023",
		"title": "Nfr",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier")],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
		],
		"events": [
			{
			"event": "end-of-encounter",
			"req": func(state, side, eid, card, targets): return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
	})))

	NRCardDefs.defcard("Nga", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": true,
		"text": "When you install this program, load 3 power counters onto it. When it is empty, trash it.\nThe first time each turn you make a successful run, you may remove 1 hosted power counter to sabotage 1. <em>(The Corp trashes 1 card of their choice from HQ or the top of R&D.)</em>",
		"code": "33072",
		"title": "Nga",
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"events": [
			trash_on_empty("power"),
			{
			"event": "successful-run",
			"skippable": true,
			"interactive": NROptional.get_autoresolve("auto-fire", func(_x): return not never_p.call(_x)),
			"silent": NROptional.get_autoresolve("auto-fire", never_p),
			"optional": {
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, side, "successful-run") and (NRCard.get_counters(card, "power") > 0)),
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"waiting-prompt": true,
				"prompt": "Remove 1 hosted power counter?",
				"yes-ability": {
					"msg": "remove 1 hosted power counter to sabotage 1",
					"async": true,
					"cost": [NRPayment.to_c("power", 1)],
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, NRSabotage.sabotage(1), card, null),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Nga")],
	}))

	NRCardDefs.defcard("Ninja", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +5 strength.",
		"code": "01027",
		"title": "Ninja",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Sentry"), NRCardXlate.strength_pump(3, 5)],
	})))

	NRCardDefs.defcard("Num", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 8,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.",
		"code": "33073",
		"title": "Num",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Sentry")],
	})))

	NRCardDefs.defcard("Nyashia", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "When you install this program, place 3 power counters on it.\nWhenever you breach R&D, you may remove 1 hosted power counter to access 1 additional card.",
		"code": "21067",
		"title": "Nyashia",
	}, {
		"data": {
			"counter": {
				"power": 3,
			},
		},
		"events": [
			{
			"event": "breach-server",
			"skippable": true,
			"optional": {
				"req": func(state, side, eid, card, targets): return ((NRCard.get_counters(card, "power") > 0) and (("rd" == NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) or NRUtil.kw_eq("rd", NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)))),
				"waiting-prompt": true,
				"prompt": "Spend 1 hosted power counter to access 1 additional card?",
				"autoresolve": NROptional.get_autoresolve("auto-fire"),
				"yes-ability": {
					"msg": "access 1 additional card from R&D",
					"cost": [NRPayment.to_c("power", 1)],
					"effect": func(state, side, eid, card, targets):
						return NRAccess.access_bonus(state, side, "rd", 1),
				},
			},
		},
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "Nyashia")],
	}))

	NRCardDefs.defcard("Odore", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>2[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines.\nInterface → <strong>0[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine. Use this ability only if you have 3 or more installed <strong>virtual</strong> resources.\n<strong>3[Credits]:</strong> +3 strength.",
		"code": "26071",
		"title": "Odore",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(2, 0, "Sentry"),
			NRCardXlate.break_sub(0, 1, "Sentry", {
			"label": "Break 1 Sentry subroutine (Virtual restriction)",
			"req": func(state, side, eid, card, targets): return (3 <= NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Virtual"))).size()),
		}),
			NRCardXlate.strength_pump(3, 3),
		],
	})))

	NRCardDefs.defcard("Omega", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 7,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nThis program can only interface with the innermost piece of ice protecting a server.",
		"code": "04088",
		"title": "Omega",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"req": func(state, side, eid, card, targets): return (func():
				var server_ice = NRCardXlate.getk(card_to_server(state, NRIce.get_current_ice(state)), "ices", null)
				return NRUtil.same_card(NRIce.get_current_ice(state), NRUtil.first_of(server_ice))
			).call(),
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Orca", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 10,
		"strength": 3,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "The first time each turn this program fully breaks a piece of ice, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "33089",
		"title": "Orca",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 0, "Sentry"), NRCardXlate.strength_pump(2, 3)],
		"events": [
			{
			"event": "subroutines-broken",
			"req": func(state, side, eid, card, targets): return (all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card) and NREvents.first_event(state, side, "subroutines-broken", func(_pct, _pct2=null, _pct3=null): return all_subs_broken_by_card_p(NRCardXlate.getk(NRUtil.first_of(_pct), "ice", null), card))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, NRCharge.charge_ability(state, side), card, null),
		},
		],
	})))

	NRCardDefs.defcard("Origami", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Your maximum hand size is increased by 1 for each copy of Origami installed.",
		"code": "06074",
		"title": "Origami",
	}, {
		"static-abilities": [
			{
			"type": "hand-size",
			"req": func(state, side, eid, card, targets): return (("runner" == side) or NRUtil.kw_eq("runner", side)),
			"value": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(_pct, "title", null) == "Origami") or NRUtil.kw_eq(NRCardXlate.getk(_pct, "title", null), "Origami")))).size(),
		},
		],
	}))

	NRCardDefs.defcard("Overmind", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 4,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 0,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "When you install this program, place 1 power counter on it for each unused MU. <em>(Place counters after this program's MU cost applies.)</em>\nInterface → <strong>Hosted power counter:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "05053",
		"title": "Overmind",
	}, NRCardXlate.auto_icebreaker({
		"on-install": {
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", NRMemory.available_mu(state), null),
		},
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("power", 1)], 1),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Paintbrush", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"memoryunits": 2,
		"factioncost": 4,
		"uniqueness": false,
		"text": "[Click]: Choose a rezzed piece of ice. That ice gains <strong>sentry</strong>, <strong>code gate</strong> or <strong>barrier</strong> until the end of the next run this turn.",
		"code": "04108",
		"title": "Paintbrush",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "give ice a subtype",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct) and NRCard.rezzed(_pct)),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var ice = NRCardXlate.first_target(targets)
				return {
					"prompt": "Choose one",
					"choices": ["Sentry", "Code Gate", "Barrier"],
					"msg": func(state, side, eid, card, targets): return str("spend [Click] and make ") + str(NRToString.card_str(state, ice)) + str(" gain ") + str(NRCardXlate.first_target(targets)) + str(" until the end of the next run this turn"),
					"effect": func(state, side, eid, card, targets):
						return NREffects.register_lingering_effect(state, side, card, {
						"type": "gain-subtype",
						"duration": "end-of-next-run",
						"req": func(state, side, eid, card, targets): return NRUtil.same_card(ice, NRCardXlate.first_target(targets)),
						"value": NRCardXlate.first_target(targets),
					}),
				}
			).call(), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Panchatantra", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Once per turn → When you encounter a piece of ice, you may choose 1 subtype that is not <strong>barrier</strong>, <strong>code gate</strong>, or <strong>sentry</strong>. That ice gains the chosen subtype for the remainder of this run.",
		"code": "10008",
		"title": "Panchatantra",
	}, {
		"events": [
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": {
				"prompt": "Give encountered piece ice a subtype?",
				"req": func(state, side, eid, card, targets): return (not (state.get_in(["per-turn", NRCardXlate.getk(card, "cid", null)], null))),
				"yes-ability": {
					"prompt": "Choose an ice subtype",
					"choices": func(state, side, eid, card, targets):
						return NRUtil.as_array((func(_pct, _pct2=null, _pct3=null): return disj(_pct, "Barrier", "Code Gate", "Sentry")).call(reduce(func(acc, card): return (conj.callv(NRUtil.as_array(NRCardXlate.getk(card, "subtypes", null))) if NRCard.ice(card) else acc), [], server_cards()))),
					"msg": func(state, side, eid, card, targets): return str("make ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str(" gain ") + str(NRCardXlate.first_target(targets)),
					"effect": func(state, side, eid, card, targets):
						register_once(state, side, {
						"once": "per-turn",
					}, card)
						return NREffects.register_lingering_effect(state, side, card, (func():
						var ice = NRIce.get_current_ice(state)
						return {
							"type": "gain-subtype",
							"duration": "end-of-run",
							"req": func(state, side, eid, card, targets): return NRUtil.same_card(ice, NRCardXlate.first_target(targets)),
							"value": NRCardXlate.first_target(targets),
						}
					).call()),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Paperclip", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Whenever you encounter a <strong>barrier</strong>, you may install this program from your heap.\n<strong>X[Credits]:</strong> +X strength. Then, if this program can interface with the <strong>barrier</strong> you are encountering, break up to X subroutines.",
		"code": "11024",
		"title": "Paperclip",
	}, (func():
		var events = NRUtil.as_array([
			"run",
			"approach-ice",
			"encounter-ice",
			"pass-ice",
			"run-ends",
			"ice-strength-changed",
			"ice-subtype-changed",
			"breaker-strength-changed",
			"subroutines-changed",
		]).map(func(event): return NRUtil.merge(heap_breaker_auto_pump_and_break if heap_breaker_auto_pump_and_break is Dictionary else {}, {"event": event}))
		var cdef = install_from_heap("Paperclip", "Barrier", [])
		var abilities = [
			{
			"label": "+X strength, break X subroutines",
			"cost": [NRPayment.to_c("x-credits")],
			"heap-breaker-pump": "x",
			"heap-breaker-break": "x",
			"break-req": func(state, side, eid, card, targets):
				return (NRRuns.active_encounter(state) and NRCard.has_subtype(NRIce.get_current_ice(state), "Barrier")),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRIce.pump(state, side, card, NRPayment.cost_value(eid, "x-credits"))
				return NREngine.continue_ability(state, side, NRCardXlate.break_sub(null, NRPayment.cost_value(eid, "x-credits"), "Barrier", {
				"repeatable": false,
			}), NRCard.get_card(state, card), null),
			"msg": func(state, side, eid, card, targets): return str("increase its strength from ") + str(NRIce.get_strength(card)) + str(" to ") + str((NRPayment.cost_value(eid, "x-credits") + NRIce.get_strength(card))),
		},
		]
		return NRUtil.merge(cdef if cdef is Dictionary else {}, {"events": conj.callv(NRUtil.as_array(NRCardXlate.getk(cdef, "events", null)))})
	).call()))

	NRCardDefs.defcard("Parasite", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus - Trojan",
		"subtypes": ["Virus", "Trojan"],
		"text": "Install only on a rezzed piece of ice.\nWhen your turn begins, place 1 virus counter on this program.\nHost ice gets -1 strength for each hosted virus counter.\nWhen the strength of host ice is 0 or less, trash it.",
		"code": "29002",
		"title": "Parasite",
	}, ({
		"implementation": "[Erratum] Program: Virus - Trojan",
		"on-install": {
			"effect": func(state, side, eid, card, targets):
				return (func():
				var h = NRCardXlate.getk(card, "host", null)
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "installing"], true)) if h != null else (func():
				var card = NRCard.get_card(state, card)
				return NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special"], dissoc, "installing")) if card != null else null
			).call()
			).call(),
		},
		"static-abilities": [
			{
			"type": "ice-strength",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), NRCardXlate.getk(card, "host", null)),
			"value": func(state, side, eid, card, targets):
				return (-NRVirus.get_virus_counters(state, card)),
		},
		],
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
			{
			"event": "ice-strength-changed",
			"req": func(state, side, eid, card, targets): return (NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(card, "host", null)) and (not (untrashable_while_rezzed_p(state, side, NRCardXlate.getk(card, "host", null)))) and (NRIce.get_strength(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null)) <= 0)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.unregister_events(state, side, card)
				((func():
				NRUpdate.update_card(state, side, NRUtil.update_in(card, ["special"], dissoc, "installing"))
				return NREngine.trigger_event(state, "runner", "runner-install", card)
			).call() if NRUtil.get_in(card, ["special", "installing"], null) else null)
				return NRMoving.trash(state, "runner", eid, NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), {
				"unpreventable": true,
				"cause-card": card,
			}),
			"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)),
		},
		],
	}).call(trojan({
		"rezzed": true,
	}))))

	NRCardDefs.defcard("Paricia", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "2[recurring-credit] <em>(When you install this card and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to pay trash costs of assets.",
		"code": "31034",
		"title": "Paricia",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-trash-corp-cards" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-trash-corp-cards", NRCardXlate.getk(eid, "source-type", null))) and NRCard.asset(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Passport", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.\nThis program cannot interface with ice protecting a remote server.",
		"code": "05046",
		"title": "Passport",
	}, central_only(NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(2, 2))))

	NRCardDefs.defcard("Pawn", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"memoryunits": 0,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Caïssa - Trojan",
		"subtypes": ["Caïssa", "Trojan"],
		"text": "[Click]: Host this program on the outermost piece of ice protecting a central server.\nWhenever you make a successful run while this program is hosted on a piece of ice, host it on the next inward piece of ice. If you cannot, trash this program and install 1 other <strong>Caïssa</strong> program from your grip or heap, ignoring all costs.",
		"code": "04002",
		"title": "Pawn",
	}, (func():
		var _b0 = can_move_inwards_p([state, {
			"keys": [NRHosting.host],
			"as": card,
		}], (NRHosting.host and (NRCardXlate.getk(NRHosting.host, "index", null) > 0) and NRFlags.can_host(state, next_ice_inwards(state, NRHosting.host))))
		return {
			"implementation": "[Erratum] Program: Caïssa - Trojan",
			"events": [
				{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"req": func(state, side, eid, card, targets): return NRCard.ice(NRCardXlate.getk(card, "host", null)),
				"effect": func(state, side, eid, card, targets):
					return (NREngine.continue_ability(state, side, {
					"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
				}, card, [next_ice_inwards(state, NRCardXlate.getk(card, "host", null))]) if can_move_inwards_p(state, card) else NREngine.continue_ability(state, side, {
					"prompt": "Choose another Caïssa to install",
					"show-discard": true,
					"choices": {
						"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.first_target(targets), "Caïssa") and (NRCard.in_hand(NRCardXlate.first_target(targets)) or ((not (NRFlags.zone_locked(state, "runner", "discard"))) and NRCard.in_discard(NRCardXlate.first_target(targets))))),
					},
					"msg": func(state, side, eid, card, targets): return str("trash itself and install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(", ignoring all costs"),
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, card, {
						"cause-card": card,
					})
					, func(async_result):
						NRInstalling.runner_install(state, side, eid, NRCardXlate.first_target(targets), {
						"ignore-all-cost": true,
						"msg-keys": {
							"display-origin": true,
							"install-source": card,
						},
					})),
					"cancel": {
						"msg": "trash itself",
						"async": true,
						"effect": func(state, side, eid, card, targets):
							return NRMoving.trash(state, side, eid, card, {
							"cause-card": card,
							"unpreventable": true,
						}),
					},
				}, card, null)),
			},
			],
			"abilities": [
				{
				"action": true,
				"label": "Host on the outermost piece of ice of a central server",
				"cost": [NRPayment.to_c("click", 1)],
				"prompt": "Choose the outermost piece of ice of a central server",
				"choices": {
					"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets)) and ((NRUtil.last_of(NRCard.get_zone(NRCardXlate.first_target(targets))) == "ices") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(NRCardXlate.first_target(targets))), "ices")) and ((NRCardXlate.first_target(targets) == NRUtil.last_of(state.get_in(NRUtil.as_array((NRUtil.as_array(["corp"]) + NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "zone", null)))), null))) or NRUtil.kw_eq(NRCardXlate.first_target(targets), NRUtil.last_of(state.get_in(NRUtil.as_array((NRUtil.as_array(["corp"]) + NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "zone", null)))), null)))) and NRServers.is_central((NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets)))[1] if NRUtil.as_array(NRCard.get_zone(NRCardXlate.first_target(targets))).size() > 1 else null))),
				},
				"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
				"effect": func(state, side, eid, card, targets):
					return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Peacock", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "20030",
		"title": "Peacock",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Code Gate"), NRCardXlate.strength_pump(2, 3)],
	})))

	NRCardDefs.defcard("Pelangi", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When you install this program, place 2 virus counters on it.\nOnce per turn → <strong>Hosted virus counter:</strong> Choose an ice subtype. The ice you are encountering gains that subtype for the remainder of this encounter.",
		"code": "26025",
		"title": "Pelangi",
	}, {
		"data": {
			"counter": {
				"virus": 2,
			},
		},
		"abilities": [
			{
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRRuns.active_encounter(state),
			"cost": [NRPayment.to_c("virus", 1)],
			"label": "Make ice gain a subtype",
			"prompt": "Choose an ice subtype",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(reduce(func(acc, card): return ((NRUtil.as_array(acc) + NRUtil.as_array(NRCardXlate.getk(card, "subtypes", null))) if NRCard.ice(card) else acc), [], server_cards())),
			"msg": func(state, side, eid, card, targets): return str("make ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))) + str(" gain ") + str(NRCardXlate.first_target(targets)) + str(" until end of the encounter"),
			"effect": func(state, side, eid, card, targets):
				return NREffects.register_lingering_effect(state, side, card, (func():
				var ice = NRIce.get_current_ice(state)
				return {
					"type": "gain-subtype",
					"duration": "end-of-encounter",
					"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.first_target(targets), ice),
					"value": NRCardXlate.first_target(targets),
				}
			).call()),
		},
		],
	}))

	NRCardDefs.defcard("Penrose", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Fracter",
		"subtypes": ["Icebreaker", "Decoder", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine. Use this ability only if this program was installed this turn.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +3 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "26089",
		"title": "Penrose",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier", {
			"req": func(state, side, eid, card, targets): return (("this-turn" == NRCard.installed(card)) or NRUtil.kw_eq("this-turn", NRCard.installed(card))),
		}),
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 1, {
			"stealth": 1,
		}), 3, "end-of-encounter"),
		],
	})))

	NRCardDefs.defcard("Peregrine", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 5,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → 1[Credits]: Break 1 <strong>code gate</strong> subroutine.\n<strong>3[Credits]:</strong> +3 strength.\n<strong>2[Credits]</strong>, </strong>add this program to your grip:</strong> Derez 1 <strong>code gate</strong> this program fully broke during this encounter.",
		"code": "11044",
		"title": "Peregrine",
	}, return_and_derez(NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(3, 3))))

	NRCardDefs.defcard("Persephone", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"strength": 1,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nWhenever you pass a <strong>sentry</strong> after encountering it, you may trash the top card of your stack. If you do, trash 1 card from the top of R&D for each subroutine on that <strong>sentry</strong> that resolved during that encounter.",
		"code": "12042",
		"title": "Persephone",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Sentry"), NRCardXlate.strength_pump(1, 1)],
		"events": [
			{
			"event": "pass-ice",
			"req": func(state, side, eid, card, targets): return (NRCard.has_subtype(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "Sentry") and NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)) and (NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).size() > 0)),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var fired_subs = NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "subroutines", null)).filter(func(_x): return bool(NRCardXlate.getk(_x, "fired")))).size()
				return {
					"optional": {
						"prompt": (str("Trash the top card of the stack to trash ") + str(NRUtil.quantify(fired_subs, "card")) + str(" from R&D?")),
						"yes-ability": {
							"async": true,
							"msg": func(state, side, eid, card, targets): return str((str("trash ") + str(NRCardXlate.getk(NRUtil.first_of(NRCardXlate.getk(state.getv("runner", {}), "deck", null)), "title", null)) + str(" from the stack and") + str(" trash ") + str(NRUtil.quantify(fired_subs, "card")) + str(" from R&D"))),
							"effect": func(state, side, eid, card, targets):
								return NREid.wait_for(state, eid, func(ne):
								NRMoving.mill(state, "runner", ne, "runner", 1)
							, func(async_result):
								NRMoving.mill(state, "runner", eid, "corp", fired_subs)),
						},
					},
				}
			).call(), card, null),
		},
		],
	})))

	NRCardDefs.defcard("Pheromones", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "X[recurring-credit]\nUse these credits during runs on HQ. X is the number of virus counters on Pheromones.\nWhenever you make a successful run on HQ, place 1 virus counter on Pheromones.",
		"code": "20031",
		"title": "Pheromones",
	}, {
		"x-fn": func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "virus"),
		"recurring": get_x_fn(),
		"events": [
			{
			"event": "successful-run",
			"silent": true,
			"req": func(state, side, eid, card, targets): return (("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
		},
		],
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return (("hq" == state.get_in(["run", "server", 0], null)) or NRUtil.kw_eq("hq", state.get_in(["run", "server", 0], null))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Physarum Entangler", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus - Trojan",
		"subtypes": ["Virus", "Trojan"],
		"text": "Install only on a piece of ice.\nWhenever you encounter host ice, if it is not a <strong>barrier</strong>, you may pay 1[Credits] for each subroutine it has. If you do, bypass that ice.\nWhen the Corp purges virus counters, trash this program.",
		"code": "34082",
		"title": "Physarum Entangler",
	}, ({
		"events": [
			trash_on_purge,
			{
			"event": "encounter-ice",
			"skippable": true,
			"optional": {
				"prompt": func(state, side, eid, card, targets): return str("Pay ") + str(NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, NRIce.get_current_ice(state)), "subroutines", null)).size()) + str(" [Credits] to bypass encountered ice?"),
				"req": func(state, side, eid, card, targets): return ((not (NRCard.has_subtype(NRIce.get_current_ice(state), "Barrier"))) and NRUtil.same_card(NRIce.get_current_ice(state), NRCardXlate.getk(card, "host", null)) and NRPayment.can_pay(state, "runner", NRUtil.merge(eid if eid is Dictionary else {}, {"source-type": "ability"}), card, null, [
					NRPayment.to_c("credit", NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, NRIce.get_current_ice(state)), "subroutines", null)).size()),
				])),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NREngine.pay(state, side, ne, NREid.make_eid(state, eid), card, [
						NRPayment.to_c("credit", NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, NRIce.get_current_ice(state)), "subroutines", null)).size()),
					])
					, func(async_result):
						(func():
						(func():
							var payment_str = NRCardXlate.getk(async_result, "msg", null)
							var msg_ab = {
								"msg": (str("bypass ") + str(NRToString.card_str(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)))),
							}
							return print_msg(state, side, msg_ab, card, null, payment_str)
						).call()
						NRCardXlate.bypass_ice(state)
						return NREid.effect_completed(state, side, eid)
					).call()),
				},
			},
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Pichação", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nWhenever you pass host ice, you may gain [Click]. If this is not the first time you gained [Click] during a run this turn, add this program to your grip.",
		"code": "34025",
		"title": "Pichação",
	}, ({
		"events": [
			{
			"event": "pass-ice",
			"optional": {
				"interactive": func(state, side, eid, card, targets):
					return true,
				"prompt": "Gain [Click]?",
				"waiting-prompt": true,
				"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), NRCardXlate.getk(card, "host", null)),
				"yes-ability": {
					"msg": "gain [Click]",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						NRGaining.gain_clicks(state, "runner", 1)
						return (NREngine.continue_ability(state, side, {
						"optional": {
							"prompt": (str("Is ") + str(NRCardXlate.getk(card, "title", null)) + str(" added to the grip?")),
							"waiting-prompt": true,
							"yes-ability": {
								"msg": "appease the rules",
								"cost": [NRPayment.to_c("return-to-hand")],
							},
						},
					}, card, null) if (1 < NRUtil.as_array(NREvents.turn_events(state, side, "runner-click-gain")).size()) else NREid.effect_completed(state, side, eid)),
				},
				"no-ability": {
					"effect": func(state, side, eid, card, targets):
						return NRSay.system_msg(state, side, (str("declines to use ") + str(NRCardXlate.getk(card, "title", null)))),
				},
			},
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Pipeline", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength for the remainder of this run.",
		"code": "25055",
		"title": "Pipeline",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Sentry"),
			NRCardXlate.strength_pump(2, 1, "end-of-run"),
		],
	})))

	NRCardDefs.defcard("Plague", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "When you install Plague, choose a server.\nWhenever you make a successful run on the chosen server, you may place 2 virus counters on Plague.",
		"code": "21022",
		"title": "Plague",
	}, {
		"on-install": {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRServers.zones_to_sorted_names(NRBoard.get_zones(state)),
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"req": func(state, side, eid, card, targets): return (not (NRCardXlate.getk(card, "card-target", null))),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})),
		},
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return ((NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)) == NRCardXlate.getk(NRCard.get_card(state, card), "card-target", null)) or NRUtil.kw_eq(NRServers.zone_to_name(NRCardXlate.getk(NRCardXlate.ctx(targets), "server", null)), NRCardXlate.getk(NRCard.get_card(state, card), "card-target", null))),
			"msg": "place 2 virus counters on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, "runner", eid, card, "virus", 2, null),
		},
		],
	}))

	NRCardDefs.defcard("Pressure Spike", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.\nThreat 4 → <strong>2[Credits]:</strong> +9 strength. Use this ability only once per run. <em>(This ability is active if any player has 4 or more agenda points.)</em>",
		"code": "34092",
		"title": "Pressure Spike",
	}, (func():
		return NRCardXlate.auto_icebreaker({
			"abilities": [
				NRCardXlate.break_sub(1, 1, "Barrier"),
				NRCardXlate.strength_pump(2, 3, "end-of-encounter", {
				"auto-pump-sort": 1,
			}),
				(func():
				var base = NRCardXlate.strength_pump(2, 9, "end-of-encounter", {
					"auto-pump-ignore": true,
					"req": func(state, side, eid, card, targets): return (NRThreat.threat_level(4, state) and NREngine.not_used_once(state, once(card), card)),
				})
				return NRUtil.merge(base if base is Dictionary else {}, {"effect": func(state, side, eid, card, targets):
					register_once(state, side, once(card), card)
					return (NRCardXlate.getk(base, "effect", null)).call(state, side, eid, card, targets)})
			).call(),
			],
		})
	).call()))

	NRCardDefs.defcard("Principia", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "This program costs 1[Credits] less to install for each other installed <strong>icebreaker</strong>. <em>(Programs trashed as part of installing this program don’t count.)</em>\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "35032",
		"title": "Principia",
	}, NRCardXlate.auto_icebreaker({
		"install-cost-bonus": func(state, side, eid, card, targets):
			return (-NRUtil.as_array(NRUtil.as_array(NRBoard.all_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Icebreaker"))).size()),
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(2, 2)],
	})))

	NRCardDefs.defcard("Progenitor", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"memoryunits": 0,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Daemon",
		"subtypes": ["Daemon"],
		"text": "You can install <strong>virus</strong> programs onto this program. Limit 1 hosted program.\nThe memory cost of the hosted program does not count against your memory limit.\n[interrupt] → Whenever virus counters would be purged, prevent 1 virus counter on the hosted program from being removed.",
		"code": "07043",
		"title": "Progenitor",
	}, {
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCard.has_subtype(NRCardXlate.first_target(targets), "Virus")),
			"no-mu": true,
			"max-cards": 1,
		},
			{
			"type": "prevent-purge-virus-counters",
			"req": func(state, side, eid, card, targets): return (NRCard.get_counters(NRUtil.first_of(NRCardXlate.getk(card, "hosted", null)), "virus") > 0),
			"value": func(state, side, eid, card, targets):
				return {
				"card": NRUtil.first_of(NRCardXlate.getk(card, "hosted", null)),
				"quantity": 1,
			},
		},
		],
	}))

	NRCardDefs.defcard("Propeller", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>Hosted power counter:</strong> +2 strength.",
		"code": "33027",
		"title": "Propeller",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 4,
			},
		},
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier"),
			NRCardXlate.strength_pump([NRPayment.to_c("power", 1)], 2),
		],
	})))

	NRCardDefs.defcard("Puffer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "This program gets +1 strength and costs +1[Memory Unit] for each hosted power counter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength.\n<strong>[Click]:</strong> Place 1 power counter on this program or remove 1 hosted power counter.",
		"code": "21004",
		"title": "Puffer",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Sentry"),
			NRCardXlate.strength_pump(2, 1),
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"msg": "place 1 power counter",
			"label": "Place 1 power counter",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"msg": "remove 1 power counter",
			"label": "Remove 1 power counter",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", -1, null),
		},
		],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
			{
			"type": "used-mu",
			"duration": "while-active",
			"value": func(state, side, eid, card, targets):
				return NRCard.get_counters(card, "power"),
		},
		],
	})))

	NRCardDefs.defcard("Read-Write Share", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Limit 4 hosted cards.\nWhen you install this program and when your turn begins, you may host 1 card from your grip facedown on this program to draw 1 card.\n[Trash]<strong>:</strong> Shuffle all hosted cards into your stack.",
		"code": "36022",
		"title": "Read-Write Share",
	}, (func():
		var ab = {
			"interactive": func(state, side, eid, card, targets):
				return true,
			"req": func(state, side, eid, card, targets): return (NRUtil.as_array(NRCardXlate.getk(card, "hosted", null)).size() < 4),
			"prompt": "Host a card from your grip to draw a card?",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.in_hand(NRCardXlate.first_target(targets))),
			},
			"skippable": true,
			"msg": {
				"public": "host a card facedown from the Grip to draw a card",
				"runner": func(state, side, eid, card, targets): return str("host ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" facedown from the Grip to draw a card"),
			},
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NRHosting.host(state, side, NRCard.get_card(state, card), NRCardXlate.first_target(targets), {
				"facedown": true,
			})
				return NRDrawing.draw(state, side, eid, 1),
		}
		return {
			"on-install": ab,
			"events": [NRUtil.merge(ab if ab is Dictionary else {}, {"event": "runner-turn-begins"})],
			"abilities": [
				{
				"fake-cost": [NRPayment.to_c("trash-can")],
				"label": "Shuffle all hosted cards into the stack",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return ((func():
					var set_aside_cards = NRSetAside.set_aside_for_me(state, side, eid, NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null))
					var set_aside_cards = NRSetAside.get_set_aside(state, side, eid)
					return NREngine.continue_ability(state, side, {
						"cost": [NRPayment.to_c("trash-can")],
						"msg": (str("shuffle ") + str(NRUtil.quantify(NRUtil.as_array(set_aside_cards).size(), "hosted card")) + str(" into the Stack")),
						"effect": func(state, side, eid, card, targets):
							(func():
							for c in NRUtil.as_array(set_aside_cards):
								NRMoving.move(state, side, c, "deck")
							return null
						).call()
							return NRShuffling.shuffle_zone(state, side, "deck"),
					}, NRCard.get_card(state, card), null)
				).call() if (not NRUtil.as_array(NRCardXlate.getk(NRCard.get_card(state, card), "hosted", null)).is_empty()) else NREngine.continue_ability(state, side, {
					"cost": [NRPayment.to_c("trash-can")],
					"msg": "shuffle the Stack",
					"effect": func(state, side, eid, card, targets):
						return NRShuffling.shuffle_zone(state, side, "deck"),
				}, card, null)),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Reaver", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Apex",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"text": "The first time you trash an installed card each turn, draw 1 card.",
		"code": "11086",
		"title": "Reaver",
	}, {
		"events": [
			{
			"event": "runner-trash",
			"async": true,
			"interactive": func(state, side, eid, card, targets):
				return true,
			"once-per-instance": true,
			"req": func(state, side, eid, card, targets): return ((NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.installed(NRCardXlate.getk(_pct, "card", null))) != null) and NREvents.first_event(state, side, "runner-trash", func(targets): return (NRUtil.find_first(NRUtil.as_array(targets), func(_pct, _pct2=null, _pct3=null): return NRCard.installed(NRCardXlate.getk(_pct, "card", null))) != null))),
			"msg": "draw 1 card",
			"effect": func(state, side, eid, card, targets):
				return NRDrawing.draw(state, "runner", eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Refractor", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +3 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "06057",
		"title": "Refractor",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 1, {
			"stealth": 1,
		}), 3, "end-of-encounter"),
		],
	})))


static func _register_6() -> void:
	NRCardDefs.defcard("Revolver", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Weapon",
		"subtypes": ["Icebreaker", "Killer", "Weapon"],
		"text": "When you install this program, place 6 power counters on it.\nInterface → [Trash] or <strong>hosted power counter:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
		"code": "33018",
		"title": "Revolver",
	}, NRCardXlate.auto_icebreaker({
		"data": {
			"counter": {
				"power": 6,
			},
		},
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("power", 1)], 1, "Sentry", {
			"auto-break-sort": 1,
		}),
			NRCardXlate.break_sub([NRPayment.to_c("trash-can")], 1, "Sentry"),
			NRCardXlate.strength_pump(2, 3),
		],
	})))

	NRCardDefs.defcard("Rezeki", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"text": "When your turn begins, gain 1[Credits].",
		"code": "26026",
		"title": "Rezeki",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"automatic": "gain-credits",
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Rising Tide", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "This program gets +1 strength for each <strong>fracter</strong> in your heap.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "35009",
		"title": "Rising Tide",
	}, NRCardXlate.auto_icebreaker({
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Fracter"))).size()),
		],
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(1, 1)],
	})))

	NRCardDefs.defcard("RNG Key", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 0,
		"uniqueness": true,
		"text": "The first time you make a successful run on HQ or R&D each turn, you may name a number. If you do, reveal the next card that you access this run. If it has a rez cost, play cost, or advancement requirement equal to the named number, either gain 3[Credits] or draw 2 cards.",
		"code": "21029",
		"title": "RNG Key",
	}, {
		"events": [
			{
			"event": "pre-access-card",
			"req": func(state, side, eid, card, targets): return NRUtil.get_in(card, ["special", "rng-guess"], null),
			"async": true,
			"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "title", null)) + str(" from ") + str(NRServers.zone_to_name(NRCard.get_zone(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)))),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRRevealing.reveal(state, side, ne, NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null))
			, func(async_result):
				NREngine.continue_ability(state, side, (func():
				var guess = NRUtil.get_in(card, ["special", "rng-guess"], null)
				return ({
					"prompt": "Choose one",
					"waiting-prompt": true,
					"choices": ["Gain 3 [Credits]", "Draw 2 cards"],
					"async": true,
					"msg": func(state, side, eid, card, targets): return str(decapitalize(NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return (NRDrawing.draw(state, "runner", eid, 2) if ((NRCardXlate.first_target(targets) == "Draw 2 cards") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Draw 2 cards")) else NRGaining.gain_credits(state, "runner", eid, 3)),
				} if NRUtil.in_coll([
					NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null), "cost", null),
					get_advancement_requirement(NRCardXlate.getk(NRCardXlate.ctx(targets), "accessed-card", null)),
				], guess) else null)
			).call(), card, null)),
		},
			{
			"event": "post-access-card",
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "rng-guess"], null)),
		},
			(func():
			var highest_cost = func(state, card): return (NRUtil.get_in(card, ["special", "rng-highest"], null) or (func():
				var cost = NRUtil.last_of(NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(server_cards()).filter(func(_x): return bool(NRCardXlate.getk(_x, "cost")))).map(func(_x): return bool(NRCardXlate.getk(_x, "cost")))))
				return (func():
					NRUpdate.update_card(state, "runner", NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "rng-highest"], cost))
					return cost
				).call()
			).call())
			return {
				"event": "successful-run",
				"optional": {
					"req": func(state, side, eid, card, targets): return (NRUtil.in_coll(["hq", "rd"], NRServers.target_server(NRCardXlate.ctx(targets))) and NREvents.first_event(state, "runner", "successful-run", func(targets): return (func():
						var context = NRUtil.first_of(targets)
						return NRUtil.in_coll(["hq", "rd"], NRServers.target_server(NRCardXlate.ctx(targets)))
					).call())),
					"prompt": "Name a number?",
					"autoresolve": NROptional.get_autoresolve("auto-fire"),
					"yes-ability": {
						"prompt": "Guess a number",
						"choices": {
							"number": func(state, side, eid, card, targets):
								return highest_cost(state, card),
						},
						"msg": func(state, side, eid, card, targets): return str("guess ") + str(NRCardXlate.first_target(targets)),
						"effect": func(state, side, eid, card, targets):
							return NRUpdate.update_card(state, side, NRUtil.assoc_in(card if card is Dictionary else {}, ["special", "rng-guess"], NRCardXlate.first_target(targets))),
					},
				},
			}
		).call(),
		],
		"abilities": [NROptional.set_autoresolve("auto-fire", "RNG Key")],
	}))

	NRCardDefs.defcard("Rook", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Caïssa - Trojan",
		"subtypes": ["Caïssa", "Trojan"],
		"text": "While this program is hosted on ice, the rez cost of each piece of ice protecting this server is increased by 2.\n[Click]: Host this program on a piece of ice that is not hosting a <strong>Caïssa</strong> program.\nIf this program is hosted on ice, its [Click] ability can only be used to host it on ice protecting the same server or in the same position as its current host ice. <em>(Count positions from the innermost ice.)</em>",
		"code": "04003",
		"title": "Rook",
	}, {
		"implementation": "[Erratum] Program: Caïssa - Trojan",
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"label": "Host on another ice",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var r = NRCard.get_card(state, card)
				var hosted_p = NRCard.ice(NRCardXlate.getk(r, "host", null))
				var icepos = card_index(state, NRCard.get_card(state, NRCardXlate.getk(r, "host", null)))
				return NREngine.continue_ability(state, side, {
					"prompt": (func(state, side, eid, card, targets): return str("Choose a piece of ice protecting this server or at position ") + str(icepos) + str(" of a different server") if hosted_p else "Choose a piece of ice protecting any server"),
					"choices": {
						"req": func(state, side, eid, card, targets): return (((((NRCard.get_zone(NRCardXlate.first_target(targets)) == NRCard.get_zone(NRCardXlate.getk(r, "host", null))) or NRUtil.kw_eq(NRCard.get_zone(NRCardXlate.first_target(targets)), NRCard.get_zone(NRCardXlate.getk(r, "host", null)))) or ((card_index(state, NRCardXlate.first_target(targets)) == icepos) or NRUtil.kw_eq(card_index(state, NRCardXlate.first_target(targets)), icepos))) and ((NRUtil.last_of(NRCard.get_zone(NRCardXlate.first_target(targets))) == "ices") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(NRCardXlate.first_target(targets))), "ices")) and NRCard.ice(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets)) and (not (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "hosted", null)), func(c): return NRCard.has_subtype(c, "Caïssa")) != null))) if hosted_p else (NRCard.ice(NRCardXlate.first_target(targets)) and NRFlags.can_host(state, NRCardXlate.first_target(targets)) and ((NRUtil.last_of(NRCard.get_zone(NRCardXlate.first_target(targets))) == "ices") or NRUtil.kw_eq(NRUtil.last_of(NRCard.get_zone(NRCardXlate.first_target(targets))), "ices")) and (not (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.first_target(targets), "hosted", null)), func(c): return NRCard.has_subtype(c, "Caïssa")) != null)))),
					},
					"msg": func(state, side, eid, card, targets): return str("host itself on ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
					"effect": func(state, side, eid, card, targets):
						return NRHosting.host(state, side, NRCardXlate.first_target(targets), card),
				}, card, null)
			).call(),
		},
		],
		"static-abilities": [
			{
			"type": "rez-cost",
			"req": func(state, side, eid, card, targets): return (NRCard.ice(NRCardXlate.first_target(targets)) and ((NRCard.get_zone(NRCardXlate.getk(card, "host", null)) == NRCard.get_zone(NRCardXlate.first_target(targets))) or NRUtil.kw_eq(NRCard.get_zone(NRCardXlate.getk(card, "host", null)), NRCard.get_zone(NRCardXlate.first_target(targets))))),
			"value": 2,
		},
		],
	}))

	NRCardDefs.defcard("Saci", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nWhenever host ice is rezzed or derezzed, gain 3[Credits].",
		"code": "34017",
		"title": "Saci",
	}, ({
		"events": [
			{
			"event": "rez",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), NRCardXlate.getk(card, "host", null)),
			"msg": "gain 3 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 3),
		},
			{
			"event": "derez",
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRCardXlate.ctx(targets), "cards", null)), func(_pct, _pct2=null, _pct3=null): return NRUtil.same_card(_pct, NRCardXlate.getk(card, "host", null))) != null),
			"msg": "gain 3 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "runner", eid, 3),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Sadyojata", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Icebreaker - AI - Deva",
		"subtypes": ["Icebreaker", "AI", "Deva"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice with 3 or more subtypes.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>2[Credits]:</strong> Swap this program with a <strong>deva</strong> program from your grip.",
		"code": "10044",
		"title": "Sadyojata",
	}, swap_with_in_hand("Sadyojata", {
		"req": func(state, side, eid, card, targets): return ((3 <= NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subtypes", null)).size()) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
	})))

	NRCardDefs.defcard("Sage", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 0,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Fracter",
		"subtypes": ["Icebreaker", "Decoder", "Fracter"],
		"text": "This program gets +1 strength for each unused MU.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>code gate</strong> or 1 <strong>barrier</strong> subroutine.",
		"code": "06117",
		"title": "Sage",
	}, mu_based_strength([break_multiple_types(1, "Barrier", 1, "Code Gate")])))

	NRCardDefs.defcard("Sahasrara", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "2[recurring-credit]\nUse these credits to install programs (you cannot use Sahasrara to install a program that trashes Sahasrara).",
		"code": "03047",
		"title": "Sahasrara",
	}, {
		"recurring": 2,
		"interactions": {
			"pay-credits": {
				"req": func(state, side, eid, card, targets): return ((("runner-install" == NRCardXlate.getk(eid, "source-type", null)) or NRUtil.kw_eq("runner-install", NRCardXlate.getk(eid, "source-type", null))) and NRCard.program(NRCardXlate.first_target(targets))),
				"type": "recurring",
			},
		},
	}))

	NRCardDefs.defcard("Saker", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.\n<strong>2[Credits]</strong>, <strong>add this program to your grip:</strong> Derez 1 <strong>barrier</strong> this program fully broke during this encounter.",
		"code": "11064",
		"title": "Saker",
	}, return_and_derez(NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(2, 2))))

	NRCardDefs.defcard("Sang Kancil", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>3[Credits]:</strong> +2 strength. If a <strong>run</strong> event is active, this ability costs 2[Credits] less to use.",
		"code": "35020",
		"title": "Sang Kancil",
	}, NRCardXlate.auto_icebreaker((func():
		var discount_fn = func(state, side, eid, card, targets):
			return ([NRPayment.to_c("credit", -2)] if (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "play-area", null)), func(_pct, _pct2=null, _pct3=null): return (NRCard.event(_pct) and NRCard.has_subtype(_pct, "Run"))) != null) else null)
		return {
			"abilities": [
				NRCardXlate.break_sub(1, 1, "Code Gate"),
				NRCardXlate.strength_pump(3, 2, "end-of-encounter", {
				"cost-bonus": discount_fn,
			}),
			],
		}
	).call())))

	NRCardDefs.defcard("Savant", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 1,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Decoder",
		"subtypes": ["Icebreaker", "Killer", "Decoder"],
		"text": "This program gets +1 strength for each unused MU.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> or 2 <strong>code gate</strong> subroutines.",
		"code": "13018",
		"title": "Savant",
	}, mu_based_strength([break_multiple_types(2, "Code Gate", 1, "Sentry")])))

	NRCardDefs.defcard("Savoir-faire", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "You cannot use Savoir-faire more than once each turn.\n2[Credits]: Install a program from your grip, paying the install cost.",
		"code": "04105",
		"title": "Savoir-faire",
	}, {
		"abilities": [
			{
			"cost": [NRPayment.to_c("credit", 2)],
			"label": "Install a program",
			"once": "per-turn",
			"change-in-game-state": {
				"req": func(state, side, eid, card, targets): return ((not (NRInstalling.install_locked(state, side))) and (not NRUtil.as_array(NRCardXlate.all_cards_in_hand_star(state, "runner")).is_empty())),
			},
			"prompt": "Choose a program to install",
			"choices": {
				"req": func(state, side, eid, card, targets): return (NRCard.program(NRCardXlate.first_target(targets)) and NRCardXlate.in_hand_star(state, NRCardXlate.first_target(targets))),
			},
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

	NRCardDefs.defcard("Scheherazade", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 0,
		"memoryunits": 0,
		"factioncost": 1,
		"uniqueness": true,
		"keywords": "Daemon",
		"subtypes": ["Daemon"],
		"text": "Scheherazade can host any number of programs.\nWhenever you install a program on Scheherazade, gain 1[Credits].",
		"code": "04022",
		"title": "Scheherazade",
	}, {
		"static-abilities": [
			{
			"type": "can-host",
			"req": func(state, side, eid, card, targets): return NRCard.program(NRCardXlate.first_target(targets)),
		},
		],
		"events": [
			{
			"event": "runner-install",
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(card, NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "host", null)),
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 1),
		},
		],
	}))

	NRCardDefs.defcard("Self-modifying Code", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "<strong>2[Credits]</strong>, <strong>[Trash]:</strong> Search your stack for 1 program. Install it. <em>(Shuffle your stack after searching it.)</em>",
		"code": "26090",
		"title": "Self-modifying Code",
	}, {
		"abilities": [
			{
			"label": "Install a program from the stack",
			"cost": [NRPayment.to_c("trash-can"), NRPayment.to_c("credit", 2)],
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"prompt": "Choose a program to install",
				"choices": func(state, side, eid, card, targets):
					return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and (not (NRInstalling.install_locked(state, side))) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct))))).is_empty())) + NRUtil.as_array(["Done"])),
				"async": true,
				"waiting-prompt": true,
				"effect": func(state, side, eid, card, targets):
					NREngine.trigger_event(state, side, "searched-stack")
					NRShuffling.shuffle_zone(state, side, "deck")
					return ((func():
					NRSay.system_msg(state, side, (str(NRCardXlate.getk(eid, "latest-payment-str", null)) + str(" to shuffle the Stack")))
					return NREid.effect_completed(state, side, eid)
				).call() if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else NREid.wait_for(state, eid, func(ne):
					NRInstalling.runner_install(state, side, ne, NRUtil.merge(NREid.make_eid(state, eid) if NREid.make_eid(state, eid) is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
					"msg-keys": {
						"install-source": card,
						"display-origin": true,
						"include-cost-from-eid": eid,
					},
				})
				, func(async_result):
					(func():
					(NRSay.system_msg(state, side, (str(NRCardXlate.getk(eid, "latest-payment-str", null)) + str(" to shuffle the Stack"))) if (not (async_result)) else null)
					return NREid.effect_completed(state, side, eid)
				).call())),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Sharpshooter", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker",
		"subtypes": ["Icebreaker"],
		"text": "Interface → <strong>[Trash]:</strong> Break any number of <strong>destroyer</strong> subroutines.\n<strong>1[Credits]:</strong> +2 strength.",
		"code": "04067",
		"title": "Sharpshooter",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub([NRPayment.to_c("trash-can")], 0, "Destroyer"),
			NRCardXlate.strength_pump(1, 2),
		],
	})))

	NRCardDefs.defcard("Shibboleth", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Threat 4 → This program gets −2 strength. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "34018",
		"title": "Shibboleth",
	}, NRCardXlate.auto_icebreaker({
		"x-fn": func(state, side, eid, card, targets):
			return (-2 if NRThreat.threat_level(4, state) else 0),
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(2, 2)],
		"static-abilities": [breaker_strength_bonus(get_x_fn())],
	})))

	NRCardDefs.defcard("Shiv", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer - Cloud",
		"subtypes": ["Icebreaker", "Killer", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nThis program gets +1 strength for each installed <strong>icebreaker</strong>.\nInterface → <strong>[Trash]:</strong> Break up to 3 <strong>sentry</strong> subroutines.",
		"code": "08066",
		"title": "Shiv",
	}, break_and_enter("Sentry")))

	NRCardDefs.defcard("Sipa", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "The first time each turn you pass the outermost piece of ice protecting a server after fully breaking it, you may swap it with another installed piece of ice.",
		"code": "36023",
		"title": "Sipa",
	}, {
		"events": [
			{
			"event": "pass-ice",
			"req": func(state, side, eid, card, targets): return (func():
				return (valid_ctx_p(NRCardXlate.ctx(targets)) and NREvents.first_event(state, side, "pass-ice", func(_pct, _pct2=null, _pct3=null): return (NRUtil.find_first(NRUtil.as_array(_pct), valid_ctx_p) != null)))
			).call(),
			"interactive": func(state, side, eid, card, targets):
				return true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, (func():
				var ice = NRCard.get_card(state, NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null))
				return {
				"prompt": (str("Swap ") + str(NRCardXlate.getk(ice, "title", null)) + str(" with another ice?")),
				"choices": {
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.installed(_pct) and NRCard.ice(_pct) and (not (NRUtil.same_card(_pct, ice)))),
				},
				"msg": func(state, side, eid, card, targets): return str("swap the positions of ") + str(NRToString.card_str(state, ice)) + str(" and ") + str(NRToString.card_str(state, NRCardXlate.first_target(targets))),
				"effect": func(state, side, eid, card, targets):
					return NRMoving.swap_ice(state, side, ice, NRCard.get_card(state, NRCardXlate.first_target(targets))),
			} if ice != null else null
			).call(), card, null),
		},
		],
	}))

	NRCardDefs.defcard("Slap Vandal", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"strength": 6,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - AI - Trojan",
		"subtypes": ["Icebreaker", "AI", "Trojan"],
		"text": "Install only on a piece of ice.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine on host ice. Use this ability only once per encounter.",
		"code": "34026",
		"title": "Slap Vandal",
	}, ({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "All", {
			"req": func(state, side, eid, card, targets): return NRUtil.same_card(NRIce.get_current_ice(state), NRCardXlate.getk(card, "host", null)),
			"repeatable": false,
		}),
		],
	}).call(trojan)))

	NRCardDefs.defcard("Sneakdoor Beta", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 4,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "[Click]<strong>:</strong> Run Archives. If that run would be declared successful, change the attacked server to HQ for the remainder of that run.",
		"code": "31023",
		"title": "Sneakdoor Beta",
	}, {
		"abilities": [
			NRCardXlate.run_server_ability("archives", {
			"action": true,
			"cost": [NRPayment.to_c("click", 1)],
			"events": [
				{
				"event": "pre-successful-run",
				"duration": "end-of-run",
				"unregister-once-resolved": true,
				"interactive": func(state, side, eid, card, targets):
					return true,
				"msg": "change the attacked server to HQ",
				"req": func(state, side, eid, card, targets): return (("archives" == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq("archives", NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
				"effect": func(state, side, eid, card, targets):
					return state.assoc_in(["run", "server"], ["hq"]),
			},
			],
		}),
		],
	}))

	NRCardDefs.defcard("Sneakdoor Prime A", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 6,
		"memoryunits": 2,
		"factioncost": 0,
		"uniqueness": false,
		"text": "[Click],[Click]: Make a run on a remote server. If successful, instead treat it as a successful run on a central server.",
		"code": "14026",
		"title": "Sneakdoor Prime A",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_remote)).map(NRServers.remote_to_name),
			"msg": "make a run on a remote server",
			"makes-run": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var initial_server = NRCardXlate.first_target(targets)
				return (func():
					NREngine.register_events(state, side, card, [
						{
						"event": "pre-successful-run",
						"duration": "end-of-run",
						"unregister-once-resolved": true,
						"req": func(state, side, eid, card, targets): return ((NRServers.unknown_to_kw(initial_server) == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq(NRServers.unknown_to_kw(initial_server), NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
						"prompt": "Choose a server",
						"choices": func(state, side, eid, card, targets):
							return ["Archives", "R&D", "HQ"],
						"msg": func(state, side, eid, card, targets): return str("change the attacked server to ") + str(NRCardXlate.first_target(targets)),
						"effect": func(state, side, eid, card, targets):
							return state.assoc_in(["run", "server"], [NRServers.unknown_to_kw(NRCardXlate.first_target(targets))]),
					},
					])
					return NRRuns.make_run(state, side, eid, initial_server, card)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Sneakdoor Prime B", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 6,
		"memoryunits": 2,
		"factioncost": 0,
		"uniqueness": false,
		"text": "[Click],[Click]: Make a run on a central server. If successful, instead treat it as a successful run on a remote server.",
		"code": "14027",
		"title": "Sneakdoor Prime B",
	}, {
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 2)],
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)).map(NRServers.unknown_to_kw)).filter(NRServers.is_central)).map(NRServers.central_to_name),
			"msg": "make a run on central server",
			"makes-run": true,
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return (func():
				var initial_server = NRCardXlate.first_target(targets)
				return (func():
					NREngine.register_events(state, side, card, [
						{
						"event": "pre-successful-run",
						"duration": "end-of-run",
						"unregister-once-resolved": true,
						"req": func(state, side, eid, card, targets): return ((NRServers.unknown_to_kw(initial_server) == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq(NRServers.unknown_to_kw(initial_server), NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
						"prompt": "Choose a server",
						"choices": func(state, side, eid, card, targets):
							return NRBoard.get_remote_names(state),
						"msg": func(state, side, eid, card, targets): return str("change the attacked server to ") + str(NRCardXlate.first_target(targets)),
						"effect": func(state, side, eid, card, targets):
							return state.assoc_in(["run", "server"], [NRServers.unknown_to_kw(NRCardXlate.first_target(targets))]),
					},
					])
					return NRRuns.make_run(state, side, eid, initial_server, card)
				).call()
			).call(),
		},
		],
	}))

	NRCardDefs.defcard("Snitch", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"text": "Once per run, you may expose an unrezzed piece of ice when you approach it. You may then jack out.",
		"code": "02045",
		"title": "Snitch",
	}, {
		"events": [
			{
			"event": "approach-ice",
			"optional": {
				"req": func(state, side, eid, card, targets): return (not (NRCard.rezzed(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)))),
				"prompt": "Expose approached piece of ice?",
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRExpose.expose(state, side, ne, [NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null)])
					, func(async_result):
						NREngine.continue_ability(state, side, NRDefHelpers.offer_jack_out(), card, null)),
				},
			},
		},
		],
	}))

	NRCardDefs.defcard("Snowball", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 4,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nWhenever you use this program to break a subroutine, this program gets +1 strength for the remainder of this run.",
		"code": "02027",
		"title": "Snowball",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Barrier", {
			"additional-ability": {
				"msg": "gain +1 strength for the remainder of the run",
				"effect": func(state, side, eid, card, targets):
					return NRIce.pump(state, side, card, 1, "end-of-run"),
			},
		}),
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Spike", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter - Cloud",
		"subtypes": ["Icebreaker", "Fracter", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nThis program gets +1 strength for each installed <strong>icebreaker</strong>.\nInterface → <strong>[Trash]:</strong> Break up to 3 <strong>barrier</strong> subroutines.",
		"code": "08004",
		"title": "Spike",
	}, break_and_enter("Barrier")))

	NRCardDefs.defcard("Stargate", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 4,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Once per turn → [Click]<strong>:</strong> Run R&D. If successful, instead of breaching R&D, reveal the top 3 cards of R&D. Trash 1 of the revealed cards.",
		"code": "26004",
		"title": "Stargate",
	}, (func():
		var ability = NRCardXlate.successful_run_replace_breach({
			"target-server": "rd",
			"mandatory": true,
			"duration": "end-of-run",
			"ability": {
				"async": true,
				"msg": func(state, side, eid, card, targets): return str("reveal ") + str(NRUtil.enumerate_cards(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3)))) + str(" from the top of R&D"),
				"effect": func(state, side, eid, card, targets):
					return NREid.wait_for(state, eid, func(ne):
					NRRevealing.reveal(state, side, ne, NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3)))
				, func(async_result):
					NREngine.continue_ability(state, side, {
					"async": true,
					"prompt": "Choose a card to trash",
					"not-distinct": true,
					"choices": func(state, side, eid, card, targets):
						return NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3)),
					"msg": func(state, side, eid, card, targets): return str((func():
						var card_titles = NRUtil.as_array(NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))).map(func(_x): return bool(NRCardXlate.getk(_x, "title")))
						var target_position = NRUtil.first_of(positions([NRCardXlate.first_target(targets)], NRUtil.take_n(NRUtil.as_array(NRCardXlate.getk(state.getv("corp", {}), "deck", null)), int(3))))
						var position = ("top " if (target_position == 0) else ("middle " if (target_position == 1) else ("bottom " if (target_position == 2) else "this-should-not-happen ")))
						return ((str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))) if ((1 == NRUtil.as_array(NRUtil.as_array(card_titles).filter(func(_x): return NRUtil.in_coll([NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)], _x))).size()) or NRUtil.kw_eq(1, NRUtil.as_array(NRUtil.as_array(card_titles).filter(func(_x): return NRUtil.in_coll([NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)], _x))).size())) else (str("trash ") + str(position) + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null))))
					).call()),
					"effect": func(state, side, eid, card, targets):
						return NRMoving.trash(state, "runner", eid, NRUtil.merge(NRCardXlate.first_target(targets) if NRCardXlate.first_target(targets) is Dictionary else {}, {"seen": true}), {
						"cause-card": card,
					}),
				}, card, null)),
			},
		})
		return {
			"abilities": [
				NRCardXlate.run_server_ability("rd", {
				"action": true,
				"cost": [NRPayment.to_c("click", 1)],
				"once": "per-turn",
				"events": [ability],
			}),
			],
		}
	).call()))

	NRCardDefs.defcard("Stowaway", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Trojan",
		"subtypes": ["Trojan"],
		"text": "Install only on a piece of ice.\nWhenever you make a successful run on this server, gain 2[Credits].",
		"code": "36024",
		"title": "Stowaway",
	}, ({
		"events": [
			{
			"event": "successful-run",
			"req": func(state, side, eid, card, targets): return (((NRUtil.as_array(NRCard.get_zone(NRCard.get_card(state, NRCardXlate.getk(card, "host", null))))[1] if NRUtil.as_array(NRCard.get_zone(NRCard.get_card(state, NRCardXlate.getk(card, "host", null)))).size() > 1 else null) == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq((NRUtil.as_array(NRCard.get_zone(NRCard.get_card(state, NRCardXlate.getk(card, "host", null))))[1] if NRUtil.as_array(NRCard.get_zone(NRCard.get_card(state, NRCardXlate.getk(card, "host", null)))).size() > 1 else null), NRServers.target_server(NRCardXlate.ctx(targets)))),
			"async": true,
			"msg": "gain 2 [Credits]",
			"automatic": "gain-credits",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, 2),
		},
		],
	}).call(trojan)))

	NRCardDefs.defcard("Study Guide", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "This program gets +1 strength for each hosted power counter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> Place 1 power counter on this program.",
		"code": "08028",
		"title": "Study Guide",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			{
			"cost": [NRPayment.to_c("credit", 2)],
			"msg": "place 1 power counter",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
		],
	})))

	NRCardDefs.defcard("Sūnya", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Whenever this program fully breaks a piece of ice, place 1 power counter on this program.\nThis program gets +1 strength for each power counter on it.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.",
		"code": "11102",
		"title": "Sūnya",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(2, 1, "Sentry")],
		"static-abilities": [
			breaker_strength_bonus(func(state, side, eid, card, targets):
			return NRCard.get_counters(card, "power")),
		],
		"events": [
			{
			"event": "end-of-encounter",
			"req": func(state, side, eid, card, targets): return all_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": "place 1 power counter on itself",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
	})))

	NRCardDefs.defcard("Surfer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "2[Credits]: Swap a piece of <strong>barrier</strong> ice currently being encountered with a piece of ice directly before or after it. The run continues from this new position. You are still encountering that ice.",
		"code": "08102",
		"title": "Surfer",
	}, (func():
		return {
			"abilities": [
				{
				"cost": [NRPayment.to_c("credit", 2)],
				"msg": "swap a piece of Barrier ice",
				"req": func(state, side, eid, card, targets): return (NRRuns.get_current_encounter(state) and NRCard.rezzed(NRIce.get_current_ice(state)) and NRCard.has_subtype(NRIce.get_current_ice(state), "Barrier")),
				"label": "Swap the piece of Barrier ice currently being encountered with a piece of ice directly before or after it",
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, surf(state, NRIce.get_current_ice(state)), card, null),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Surveillance Network Key", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Whenever the Corp spends [Click] to draw 1 or more cards (including through a card ability), reveal the first card drawn.",
		"code": "14018",
		"title": "Surveillance Network Key",
	}, {
		"implementation": "Only implemented for click to draw",
		"events": [
			{
			"event": "corp-click-draw",
			"msg": func(state, side, eid, card, targets): return str("reveal that they drew ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)),
		},
		],
	}))

	NRCardDefs.defcard("Surveillance Network Key 2", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 0,
		"uniqueness": false,
		"text": "Whenever the Corp spends [Click] to draw 1 or more cards (including through a card ability), reveal the first card drawn.\n2[Credits]: For the remainder of this run, access 1 additional card whenever you access cards from HQ or R&D. Use this ability only once per turn.",
		"code": "14019",
		"title": "Surveillance Network Key 2",
	}, (func():
		return {
			"implementation": "Only implemented for click to draw",
			"abilities": [ttw_ab("R&D", "rd"), ttw_ab("HQ", "hq")],
			"events": [
				{
				"event": "corp-click-draw",
				"msg": func(state, side, eid, card, targets): return str("reveal that they drew ") + str(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "card", null), "title", null)),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Switchblade", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Killer",
		"subtypes": ["Icebreaker", "Killer"],
		"text": "Interface → <strong>1[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines. Spend credits only from <strong>stealth</strong> cards to use this ability.\n<strong>1[Credits]:</strong> +7 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
		"code": "06077",
		"title": "Switchblade",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(NRPayment.to_c("credit", 1, {
			"stealth": 1,
		}), 0, "Sentry"),
			NRCardXlate.strength_pump(NRPayment.to_c("credit", 1, {
			"stealth": 1,
		}), 7, "end-of-encounter"),
		],
	})))

	NRCardDefs.defcard("Takobi", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": true,
		"text": "Whenever you fully break a piece of ice, you may place 1 power counter on this program.\n<strong>2 hosted power counters:</strong> Choose 1 installed non-<strong>AI</strong> <strong>icebreaker</strong>. That <strong>icebreaker</strong> gets +3 strength for the remainder of the current encounter.",
		"code": "21026",
		"title": "Takobi",
	}, {
		"special": {
			"auto-place-counter": "always",
		},
		"events": [
			{
			"event": "subroutines-broken",
			"optional": {
				"req": func(state, side, eid, card, targets): return NRCardXlate.getk(NRCardXlate.first_target(targets), "all-subs-broken", null),
				"prompt": func(state, side, eid, card, targets): return str("Place 1 power counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"autoresolve": NROptional.get_autoresolve("auto-place-counter"),
				"yes-ability": {
					"msg": "place 1 power counter on itself",
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 1, null),
				},
			},
		},
		],
		"abilities": [
			{
			"req": func(state, side, eid, card, targets): return NRRuns.get_current_encounter(state),
			"cost": [NRPayment.to_c("power", 2)],
			"label": "Give non-AI icebreaker +3 strength",
			"prompt": "Choose an installed non-AI icebreaker",
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Icebreaker") and (not (NRCard.has_subtype(_pct, "AI"))) and NRCard.installed(_pct)),
			},
			"keep-menu-open": "while-power-tokens-left",
			"msg": func(state, side, eid, card, targets): return str("give +3 strength to ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return NRIce.pump(state, side, NRCardXlate.first_target(targets), 3),
		},
			NROptional.set_autoresolve("auto-place-counter", "Takobi placing power counters on itself"),
		],
	}))

	NRCardDefs.defcard("Tapwrm", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Virus",
		"subtypes": ["Virus"],
		"text": "Install only if you made a successful run on a central server this turn.\nWhen your turn begins, gain 1[Credits] for every 5[Credits] in the Corp's credit pool.\nTrash Tapwrm if the Corp purges virus counters.",
		"code": "11104",
		"title": "Tapwrm",
	}, (func():
		var ability = {
			"label": "Gain [Credits] (start of turn)",
			"automatic": "gain-credits",
			"msg": func(state, side, eid, card, targets): return str("gain ") + str((NRCardXlate.getk(state.getv("corp", {}), "credit", null) / 5)) + str(" [Credits]"),
			"once": "per-turn",
			"req": func(state, side, eid, card, targets): return NRCardXlate.getk(state, "runner-phase-12", null),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, side, eid, (NRCardXlate.getk(state.getv("corp", {}), "credit", null) / 5)),
		}
		return {
			"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(state.get_in(["runner", "register"], {}), "successful-run", null)), func(_x): return NRUtil.in_coll(["hq", "rd", "archives"], _x)) != null),
			"flags": {
				"drip-economy": true,
			},
			"abilities": [ability],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				trash_on_purge,
			],
		}
	).call()))

	NRCardDefs.defcard("Torch", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 9,
		"strength": 4,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "04047",
		"title": "Torch",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
	})))

	NRCardDefs.defcard("Tracker", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 0,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"text": "When your turn begins, you may choose a server.\n<strong>[Click]</strong>, <strong>2[Credits]:</strong> Run the chosen server. The first time a subroutine would resolve during that run, prevent it from resolving.",
		"code": "11105",
		"title": "Tracker",
	}, (func():
		var ability = {
			"prompt": "Choose a server",
			"choices": func(state, side, eid, card, targets):
				return NRServers.zones_to_sorted_names(NRBoard.get_zones(state)),
			"msg": func(state, side, eid, card, targets): return str("target ") + str(NRCardXlate.first_target(targets)),
			"req": func(state, side, eid, card, targets): return (not (NRCardXlate.getk(card, "card-target", null))),
			"effect": func(state, side, eid, card, targets):
				return NRUpdate.update_card(state, side, NRUtil.merge(card if card is Dictionary else {}, {"card-target": NRCardXlate.first_target(targets)})),
		}
		var prevent_sub = {
			"event": "pre-resolve-subroutine",
			"duration": "end-of-run",
			"unregister-once-resolved": true,
			"req": func(state, side, eid, card, targets): return true,
			"effect": func(state, side, eid, card, targets):
				return NRRuns.update_current_encounter(state, "prevent-subroutine", true),
			"msg": func(state, side, eid, card, targets): return str((str("prevent a subroutine (") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "label", null)) + str(") from resolving"))),
		}
		return {
			"abilities": [
				{
				"action": true,
				"label": "Make a run on targeted server",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)],
				"change-in-game-state": {
					"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.runnable_servers(state, side, eid, card)), func(_pct, _pct2=null, _pct3=null): return ((NRCardXlate.getk(card, "card-target", null) == _pct) or NRUtil.kw_eq(NRCardXlate.getk(card, "card-target", null), _pct))) != null),
				},
				"msg": func(state, side, eid, card, targets): return str("make a run on ") + str(NRCardXlate.getk(card, "card-target", null)) + str(". Prevent the first subroutine that would resolve from resolving"),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					NREngine.register_events(state, side, card, [prevent_sub])
					return NRRuns.make_run(state, side, eid, NRCardXlate.getk(card, "card-target", null), card),
			},
			],
			"events": [
				NRUtil.merge(ability if ability is Dictionary else {}, {"event": "runner-turn-begins"}),
				{
				"event": "runner-turn-ends",
				"silent": true,
				"effect": func(state, side, eid, card, targets):
					return NRUpdate.update_card(state, side, NRUtil.dissoc(card if card is Dictionary else {}, ["card-target"])),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Tranquilizer", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus - Trojan",
		"subtypes": ["Virus", "Trojan"],
		"text": "Install only on a piece of ice. <em>(If the host ice is uninstalled, this program is trashed.)</em>\nWhen you install this program and when your turn begins, place 1 virus counter on this program. Then, if there are 3 or more hosted virus counters, derez host ice.",
		"code": "30017",
		"title": "Tranquilizer",
	}, (func():
		return (func():
			[
				action,
				func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRProps.add_counter(state, side, ne, card, "virus", 1, null)
			, func(async_result):
				(NRRezzing.derez(state, side, eid, NRCard.get_card(state, NRCardXlate.getk(card, "host", null))) if (NRCard.rezzed(NRCard.get_card(state, NRCardXlate.getk(card, "host", null))) and (3 <= NRVirus.get_virus_counters(state, NRCard.get_card(state, card)))) else NREid.effect_completed(state, side, eid))),
			]
			return {
				"on-install": {
					"interactive": func(state, side, eid, card, targets):
						return true,
					"async": true,
					"effect": action,
				},
				"events": [
					{
					"event": "runner-turn-begins",
					"async": true,
					"effect": action,
				},
				],
			}
		).call()
	).call()))

	NRCardDefs.defcard("Tremolo", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 3,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>3[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines. This ability costs 1[Credits] less to use for each installed piece of <strong>cybernetic</strong> hardware.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "33080",
		"title": "Tremolo",
	}, (func():
		return NRCardXlate.auto_icebreaker({
			"abilities": [
				NRCardXlate.break_sub(3, 2, "Barrier", {
				"label": "Break up to 2 Barrier subroutine",
				"break-cost-bonus": func(state, side, eid, card, targets):
					return [NRPayment.to_c("credit", maxi(-3, credit_discount(state)))],
			}),
				NRCardXlate.strength_pump(2, 2),
			],
		})
	).call()))


static func _register_7() -> void:
	NRCardDefs.defcard("Trope", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "When your turn begins, place 1 power counter on Trope.\n[Click], <strong>remove Trope from the game:</strong> Shuffle 1 card from your heap into your stack for each power counter on Trope.",
		"code": "08081",
		"title": "Trope",
	}, {
		"events": [
			{
			"event": "runner-turn-begins",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRProps.add_counter(state, side, eid, card, "power", 1, null),
		},
		],
		"abilities": [
			{
			"action": true,
			"req": func(state, side, eid, card, targets): return (not (NRFlags.zone_locked(state, "runner", "discard"))),
			"label": "shuffle cards from heap into stack",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NREngine.continue_ability(state, side, {
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("remove-from-game")],
				"label": "Reshuffle cards from heap into stack",
				"show-discard": true,
				"choices": {
					"max": mini(NRCard.get_counters(card, "power"), NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "discard", null)).size()),
					"all": true,
					"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.runner(_pct) and NRCard.in_discard(_pct)),
				},
				"msg": func(state, side, eid, card, targets): return str("shuffle ") + str(NRUtil.enumerate_cards(targets)) + str(" into the stack"),
				"effect": func(state, side, eid, card, targets):
					(func():
					for c in NRUtil.as_array(targets):
						NRMoving.move(state, side, c, "deck")
					return null
				).call()
					return NRShuffling.shuffle_zone(state, side, "deck"),
			}, card, null),
		},
		],
	}))

	NRCardDefs.defcard("Trypano", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Virus - Trojan",
		"subtypes": ["Virus", "Trojan"],
		"text": "Install only on a piece of ice.\nWhen your turn begins, you may place 1 virus counter on this program.\nWhen there are 5 or more hosted virus counters, trash host ice.",
		"code": "21082",
		"title": "Trypano",
	}, (func():
		return (func():
			[
				trash_if_5,
				func(state, side, eid, card, targets):
				return (func():
				var h = NRCard.get_card(state, NRCardXlate.getk(card, "host", null))
				return ((func():
					NRSay.system_msg(state, "runner", (str("uses ") + str(NRCardXlate.getk(card, "title", null)) + str(" to trash ") + str(NRToString.card_str(state, h))))
					NREngine.unregister_events(state, side, card)
					return NRMoving.trash(state, "runner", eid, h, {
						"cause-card": card,
					})
				).call() if (h and (NRVirus.get_virus_counters(state, card) >= 5) and (not ((untrashable_while_rezzed_p(state, side, NRCardXlate.getk(card, "host", null)) and NRCard.rezzed(h))))) else NREid.effect_completed(state, side, eid))
			).call(),
			]
			return {
				"implementation": "[Erratum] Program: Virus - Trojan",
				"on-install": {
					"async": true,
					"effect": trash_if_5,
				},
				"abilities": [
					NROptional.set_autoresolve("auto-place-counter", "Trypano placing virus counters on itself"),
				],
				"events": [
					{
					"event": "runner-turn-begins",
					"optional": {
						"prompt": func(state, side, eid, card, targets): return str("Place 1 virus counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
						"autoresolve": NROptional.get_autoresolve("auto-place-counter"),
						"yes-ability": {
							"msg": "place 1 virus counter on itself",
							"async": true,
							"effect": func(state, side, eid, card, targets):
								return NRProps.add_counter(state, side, eid, card, "virus", 1, null),
						},
					},
				},
					{
					"event": "counter-added",
					"async": true,
					"effect": trash_if_5,
				},
					{
					"event": "card-moved",
					"async": true,
					"effect": trash_if_5,
				},
					{
					"event": "runner-install",
					"async": true,
					"effect": trash_if_5,
				},
				],
			}
		).call()
	).call()))

	NRCardDefs.defcard("Tunnel Vision", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 2,
		"strength": 2,
		"memoryunits": 2,
		"factioncost": 3,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "When your turn begins, identify your mark. <em>(If you donʼt have a mark, a random central server becomes your mark for this turn.)</em>\nInterface → <strong>2[Credits]:</strong> Break up to 2 subroutines on a piece of ice protecting your mark.\n<strong>2[Credits]:</strong> +2 strength.",
		"code": "33081",
		"title": "Tunnel Vision",
	}, NRCardXlate.auto_icebreaker({
		"events": [
			mark_changed_event,
			NRUtil.merge(NRMark.identify_mark_ability if NRMark.identify_mark_ability is Dictionary else {}, {"event": "runner-turn-begins"}),
		],
		"abilities": [
			NRCardXlate.break_sub(2, 2, "All", {
			"req": func(state, side, eid, card, targets): return ((NRCardXlate.getk(state, "mark", null) == NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null))) or NRUtil.kw_eq(NRCardXlate.getk(state, "mark", null), NRUtil.first_of(NRCardXlate.getk(state.getv("run"), "server", null)))),
		}),
			NRCardXlate.strength_pump(2, 2),
		],
	})))

	NRCardDefs.defcard("Tycoon", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, the Corp gains 2[Credits].",
		"code": "22012",
		"title": "Tycoon",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 2, "Barrier"), NRCardXlate.strength_pump(2, 3)],
		"events": [
			{
			"event": "end-of-encounter",
			"req": func(state, side, eid, card, targets): return any_subs_broken_by_card_p(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), card),
			"msg": "give the Corp 2 [Credits]",
			"async": true,
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_credits(state, "corp", eid, 2),
		},
		],
	})))

	NRCardDefs.defcard("Umbrella", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 5,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Weapon",
		"subtypes": ["Icebreaker", "Decoder", "Weapon"],
		"text": "This program can only interface with ice hosting a <strong>trojan</strong> program.\nInterface → <strong>2[Credits]:</strong> Break up to 3 <strong>code gate</strong> subroutines. If at least 1 subroutine was broken this way, each player may draw 1 card.",
		"code": "34027",
		"title": "Umbrella",
	}, (func():
		var corp_draw = {
			"optional": {
				"prompt": "Draw 1 card?",
				"player": "corp",
				"waiting-prompt": true,
				"yes-ability": {
					"async": true,
					"display-side": "corp",
					"msg": "draw 1 card",
					"effect": func(state, side, eid, card, targets):
						return NRDrawing.draw(state, "corp", eid, 1),
				},
				"no-ability": {
					"display-side": "corp",
					"msg": "decline to draw 1 card",
				},
			},
		}
		var runner_draw = {
			"label": "Each player draws 1 card (manual)",
			"optional": {
				"prompt": "Draw 1 card?",
				"waiting-prompt": true,
				"yes-ability": {
					"async": true,
					"msg": "draw 1 card",
					"effect": func(state, side, eid, card, targets):
						return NREid.wait_for(state, eid, func(ne):
						NRDrawing.draw(state, "runner", ne, 1)
					, func(async_result):
						NREngine.continue_ability(state, side, corp_draw, card, null)),
				},
				"no-ability": {
					"async": true,
					"msg": "decline to draw 1 card",
					"effect": func(state, side, eid, card, targets):
						return NREngine.continue_ability(state, side, corp_draw, card, null),
				},
			},
		}
		return NRCardXlate.auto_icebreaker({
			"implementation": "Draw doesn't work when mixing breakers",
			"abilities": [
				NRCardXlate.break_sub(2, 3, "Code Gate", {
				"req": func(state, side, eid, card, targets): return (NRUtil.find_first(NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "hosted", null)), func(_pct, _pct2=null, _pct3=null): return (NRCard.has_subtype(_pct, "Trojan") and NRCard.program(_pct))) != null),
			}),
				runner_draw,
			],
			"events": [
				{
				"event": "subroutines-broken",
				"req": func(state, side, eid, card, targets): return NRUtil.as_array(NRCardXlate.getk(NRCardXlate.getk(NRCardXlate.ctx(targets), "ice", null), "subroutines", null)).all(func(_pct, _pct2=null, _pct3=null): return (((NRCardXlate.getk(_pct, "breaker", null) == null) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "breaker", null), null)) or ((NRCardXlate.getk(_pct, "breaker", null) == NRCardXlate.getk(card, "cid", null)) or NRUtil.kw_eq(NRCardXlate.getk(_pct, "breaker", null), NRCardXlate.getk(card, "cid", null))))),
				"async": true,
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, runner_draw, card, null),
			},
			],
		})
	).call()))

	NRCardDefs.defcard("Unity", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 3,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +X strength. X is equal to the number of installed <strong>icebreakers</strong> <em>(including this one)</em>.",
		"code": "30026",
		"title": "Unity",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(1, 1, "Code Gate"),
			NRCardXlate.strength_pump(1, 0, "end-of-encounter", {
			"label": "Add 1 strength for each installed icebreaker",
			"pump-bonus": func(state, side, eid, card, targets):
				return NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.program(_pct) and NRCard.has_subtype(_pct, "Icebreaker")))).size(),
		}),
		],
	})))

	NRCardDefs.defcard("Upya", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 0,
		"memoryunits": 1,
		"factioncost": 3,
		"uniqueness": false,
		"text": "Whenever you make a successful run on R&D, you may place 1 power counter on this program.\nOnce per turn → [Click], <strong>3 hosted power counters:</strong> Gain [Click][Click].",
		"code": "21007",
		"title": "Upya",
	}, {
		"special": {
			"auto-place-counters": "always",
		},
		"events": [
			{
			"event": "successful-run",
			"optional": {
				"player": "runner",
				"req": func(state, side, eid, card, targets): return (("rd" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("rd", NRServers.target_server(NRCardXlate.ctx(targets)))),
				"waiting-prompt": true,
				"autoresolve": NROptional.get_autoresolve("auto-place-counters"),
				"prompt": func(state, side, eid, card, targets): return str("Place 1 power counter on ") + str(NRCardXlate.getk(card, "title", null)) + str("?"),
				"yes-ability": {
					"async": true,
					"effect": func(state, side, eid, card, targets):
						return NRProps.add_counter(state, side, eid, card, "power", 1, null),
				},
			},
		},
		],
		"abilities": [
			{
			"action": true,
			"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("power", 3)],
			"once": "per-turn",
			"msg": "gain [Click][Click]",
			"effect": func(state, side, eid, card, targets):
				return NRGaining.gain_clicks(state, side, 2),
		},
			NROptional.set_autoresolve("auto-place-counters", "Upya placing counters on itself"),
		],
	}))

	NRCardDefs.defcard("Utae", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>X[Credits]:</strong> Break X <strong>code gate</strong> subroutines. Use this ability only once per run.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine. Use this ability only if you have 3 or more installed <strong>virtual</strong> resources.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "26005",
		"title": "Utae",
	}, (func():
		var break_req = NRCardXlate.getk(NRCardXlate.break_sub(1, 1, "Code Gate"), "break-req", null)
		return NRCardXlate.auto_icebreaker({
			"abilities": [
				{
				"label": "Break X Code Gate subroutines",
				"cost": [NRPayment.to_c("x-credits")],
				"break-cost": [NRPayment.to_c("x-credits")],
				"async": true,
				"once": "per-run",
				"req": func(state, side, eid, card, targets): return (break_req(state, side, eid, card, targets) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
				"auto-break-creds-per-sub": 1,
				"auto-break-sort": 2,
				"break": 0,
				"break-req": func(state, side, eid, card, targets):
					return (NRRuns.active_encounter(state) and NREngine.not_used_once(state, {
					"once": "per-run",
				}, card) and NRCard.has_subtype(NRIce.get_current_ice(state), "Code Gate")),
				"msg": func(state, side, eid, card, targets): return str("break ") + str(NRUtil.quantify(NRPayment.cost_value(eid, "x-credits"), "subroutine")) + str(" on ") + str(NRToString.card_str(state, NRIce.get_current_ice(state))),
				"effect": func(state, side, eid, card, targets):
					return NREngine.continue_ability(state, side, (NRCardXlate.break_sub(null, NRPayment.cost_value(eid, "x-credits"), "Code Gate") if (NRPayment.cost_value(eid, "x-credits") > 0) else null), card, null),
			},
				NRCardXlate.break_sub(1, 1, "Code Gate", {
				"label": "Break 1 Code Gate subroutine (Virtual restriction)",
				"auto-break-sort": 1,
				"req": func(state, side, eid, card, targets): return (3 <= NRUtil.as_array(NRUtil.as_array(NRBoard.all_active_installed(state, "runner")).filter(func(_pct, _pct2=null, _pct3=null): return NRCard.has_subtype(_pct, "Virtual"))).size()),
			}),
				NRCardXlate.strength_pump(1, 1),
			],
		})
	).call()))

	NRCardDefs.defcard("Vamadeva", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 6,
		"strength": 2,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": true,
		"keywords": "Icebreaker - AI - Deva",
		"subtypes": ["Icebreaker", "AI", "Deva"],
		"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice with exactly 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>2[Credits]:</strong> Swap this program with a <strong>deva</strong> program from your grip.",
		"code": "10061",
		"title": "Vamadeva",
	}, swap_with_in_hand("Vamadeva", {
		"req": func(state, side, eid, card, targets): return (((1 == NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)).size()) or NRUtil.kw_eq(1, NRUtil.as_array(NRCardXlate.getk(NRIce.get_current_ice(state), "subroutines", null)).size())) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
	})))

	NRCardDefs.defcard("Wari", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Criminal",
		"cost": 1,
		"memoryunits": 1,
		"factioncost": 4,
		"uniqueness": true,
		"text": "The first time you make a successful run on HQ each turn, you may trash Wari to name <strong>sentry</strong>, <strong>code gate</strong> or <strong>barrier</strong>. Expose a piece of ice, then add it to HQ if it has the named subtype.",
		"code": "21024",
		"title": "Wari",
	}, (func():
		var _b0 = expose_and_maybe_bounce([chosen_subtype], {
			"choices": {
				"card": func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and (not (NRCard.rezzed(_pct)))),
			},
			"async": true,
			"msg": (str("name ") + str(chosen_subtype)),
			"effect": func(state, side, eid, card, targets):
				return NREid.wait_for(state, eid, func(ne):
				NRExpose.expose(state, side, ne, [NRCardXlate.first_target(targets)])
			, func(async_result):
				(func():
				((func():
					NRMoving.move(state, "corp", NRCardXlate.first_target(targets), "hand")
					return NRSay.system_msg(state, "runner", (str("add ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" to HQ")))
				).call() if (async_result and NRCard.has_subtype(NRCardXlate.first_target(targets), chosen_subtype)) else null)
				return NREid.effect_completed(state, side, eid)
			).call()),
		})
		return {
			"events": [
				{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"optional": {
					"req": func(state, side, eid, card, targets): return ((("hq" == NRServers.target_server(NRCardXlate.ctx(targets))) or NRUtil.kw_eq("hq", NRServers.target_server(NRCardXlate.ctx(targets)))) and NREvents.first_successful_run_on_server(state, "hq") and (NRUtil.find_first(NRUtil.as_array(NRBoard.all_installed(state, "corp")), func(_pct, _pct2=null, _pct3=null): return (NRCard.ice(_pct) and (not (NRCard.rezzed(_pct))))) != null)),
					"prompt": "Trash Wari to expose a piece of ice?",
					"yes-ability": prompt_for_subtype(),
				},
			},
			],
		}
	).call()))

	NRCardDefs.defcard("World Tree", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 6,
		"memoryunits": 2,
		"factioncost": 4,
		"uniqueness": false,
		"keywords": "Deep Net",
		"subtypes": ["Deep Net"],
		"text": "The first time each turn you make a successful run, you may trash 1 of your other installed cards to search your stack for 1 card of the same type. <em>(Shuffle your stack after searching it.)</em> Install the card you found, paying 3[Credits] less.",
		"code": "33091",
		"title": "World Tree",
	}, (func():
		var search_and_install = func(trashed_card): return {
			"prompt": func(state, side, eid, card, targets): return str("Choose a ") + str(NRCardXlate.getk(trashed_card, "type", null)) + str(" to install"),
			"req": func(state, side, eid, card, targets): return (not (NRInstalling.install_locked(state, side))),
			"msg": func(state, side, eid, card, targets): return str(("shuffle the stack" if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else (str("install ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)) + str(" from the stack, paying 3 [Credits] less")))),
			"choices": func(state, side, eid, card, targets):
				return (NRUtil.as_array((not NRUtil.as_array(NRUtil.as_array(NRUtil.as_array(NRCardXlate.getk(state.getv("runner", {}), "deck", null)).filter(func(_pct, _pct2=null, _pct3=null): return (NRCard.is_type(_pct, NRCardXlate.getk(trashed_card, "type", null)) and NRInstalling.runner_can_pay_and_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), _pct, {
				"cost-bonus": -3,
			}))))).is_empty())) + NRUtil.as_array(["Done"])),
			"async": true,
			"effect": func(state, side, eid, card, targets):
				NREngine.trigger_event(state, side, "searched-stack")
				NRShuffling.shuffle_zone(state, side, "deck")
				return (NREid.effect_completed(state, side, eid) if ((NRCardXlate.first_target(targets) == "Done") or NRUtil.kw_eq(NRCardXlate.first_target(targets), "Done")) else NRInstalling.runner_install(state, side, NRUtil.merge(eid if eid is Dictionary else {}, {"source": card}), NRCardXlate.first_target(targets), {
				"cost-bonus": -3,
			})),
		}
		return {
			"events": [
				{
				"event": "successful-run",
				"interactive": func(state, side, eid, card, targets):
					return true,
				"req": func(state, side, eid, card, targets): return (NREvents.first_event(state, "runner", "successful-run") and (NRUtil.as_array(NRBoard.all_installed(state, "runner")).size() >= 2)),
				"async": true,
				"choices": {
					"not-self": true,
					"req": func(state, side, eid, card, targets): return (NRCard.runner(NRCardXlate.first_target(targets)) and NRCard.installed(NRCardXlate.first_target(targets))),
				},
				"msg": func(state, side, eid, card, targets): return str("trash ") + str(NRCardXlate.getk(NRCardXlate.first_target(targets), "title", null)),
				"effect": func(state, side, eid, card, targets):
					return (func():
					var facedown_target = NRCard.facedown(NRCardXlate.first_target(targets))
					return NREid.wait_for(state, eid, func(ne):
						NRMoving.trash(state, side, ne, NRCardXlate.first_target(targets), {
						"unpreventable": true,
						"cause-card": card,
					})
					, func(async_result):
						(NREid.effect_completed(state, side, eid) if facedown_target else NREngine.continue_ability(state, side, search_and_install(NRCardXlate.first_target(targets)), card, null)))
				).call(),
			},
			],
		}
	).call()))

	NRCardDefs.defcard("Wyrm", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - AI",
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → <strong>3[Credits]:</strong> Break 1 subroutine on a piece of ice with 0 or less strength.\nInterface → <strong>1[Credits]:</strong> The ice you are encountering gets -1 strength for the remainder of this encounter.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "01013",
		"title": "Wyrm",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [
			NRCardXlate.break_sub(3, 1, "All", {
			"label": "break 1 subroutine on a piece of ice with 0 or less strength",
			"req": func(state, side, eid, card, targets): return (not ((NRIce.get_strength(NRIce.get_current_ice(state)) > 0))),
		}),
			{
			"cost": [NRPayment.to_c("credit", 1)],
			"label": "Give -1 strength to current piece of ice",
			"req": func(state, side, eid, card, targets): return (NRRuns.active_encounter(state) and (NRIce.get_strength(NRIce.get_current_ice(state)) <= NRIce.get_strength(card))),
			"msg": func(state, side, eid, card, targets): return str("give -1 strength to ") + str(NRCardXlate.getk(NRIce.get_current_ice(state), "title", null)),
			"effect": func(state, side, eid, card, targets):
				return pump_ice(state, side, NRIce.get_current_ice(state), -1),
		},
			NRCardXlate.strength_pump(1, 1),
		],
	})))

	NRCardDefs.defcard("Yog.0", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 5,
		"strength": 3,
		"memoryunits": 1,
		"factioncost": 1,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder",
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → <strong>0[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.",
		"code": "01014",
		"title": "Yog.0",
	}, NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(0, 1, "Code Gate")],
	})))

	NRCardDefs.defcard("Yusuf", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 1,
		"strength": 3,
		"memoryunits": 2,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Fracter - Virus",
		"subtypes": ["Icebreaker", "Fracter", "Virus"],
		"text": "Whenever you make a successful run, you may place 1 virus counter on this program.\nInterface → <strong>Any virus counter:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>Any virus counter:</strong> +1 strength.",
		"code": "21002",
		"title": "Yusuf",
	}, virus_breaker("Barrier")))

	NRCardDefs.defcard("ZU.13 Key Master", NRCardXlate.merge_cdef({
		"type": "Program",
		"side": "Runner",
		"faction": "Shaper",
		"cost": 1,
		"strength": 1,
		"memoryunits": 1,
		"factioncost": 2,
		"uniqueness": false,
		"keywords": "Icebreaker - Decoder - Cloud",
		"subtypes": ["Icebreaker", "Decoder", "Cloud"],
		"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
		"code": "02007",
		"title": "ZU.13 Key Master",
	}, cloud_icebreaker(NRCardXlate.auto_icebreaker({
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
	}))))


