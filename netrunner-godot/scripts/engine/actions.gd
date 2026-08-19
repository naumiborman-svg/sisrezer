class_name NRActions
extends RefCounted
## Player commands: click-credit, click-draw, play, rez, score, etc. Port of game.core.actions.

static func play_ability(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card")) if args.get("card") is Dictionary else args.get("card")
	if not (card is Dictionary):
		return
	var idx: int = int(args.get("ability", 0))
	var abilities: Array = card.get("abilities", [])
	if idx < 0 or idx >= abilities.size():
		return
	var ability: Dictionary = abilities[idx]
	if NRUtil.truthy(card.get("disabled", false)):
		return
	if NRUtil.truthy(ability.get("action", false)) and state.getv("run") is Dictionary:
		NRToasts.toast(state, side, "You cannot play actions during a run.")
		return
	var prompt_type = state.get_in([NRUtil.to_side(side), "prompt-state", "prompt-type"])
	if prompt_type != null and not NRUtil.kw_eq(prompt_type, "run") and not NRUtil.kw_eq(prompt_type, "prevent"):
		NRToasts.toast(state, side, "You cannot play abilities while other abilities are resolving.", "warning")
		return
	if NRUtil.to_side(side) != NRUtil.to_side(card.get("side")):
		return
	var eid = NREid.make_eid(state, {"source": card, "source-type": "ability", "source-info": {"ability-idx": idx, "ability-targets": args.get("targets")}})
	var cost = NRCostFns.card_ability_cost(state, side, ability, card, args.get("targets"))
	ability = ability.duplicate(true)
	ability["cost"] = cost
	if cost != null and NRPayment.can_pay(state, side, eid, card, card.get("title"), cost) == null:
		return
	if NRUtil.truthy(ability.get("action", false)):
		NREngine.trigger_event_simult(state, side, NREid.make_eid(state), "action-played", null, {"ability-idx": idx, "card": NRUtil.select_keys(card, ["cid", "type", "title"])})
	NREngine.resolve_ability(state, side, eid, ability, card, args.get("targets"))


static func click_credit(state: NRState, side: Variant, _args: Variant = null) -> void:
	play_ability(state, side, {"card": state.get_in([NRUtil.to_side(side), "basic-action-card"]), "ability": 0})


static func click_draw(state: NRState, side: Variant, _args: Variant = null) -> void:
	play_ability(state, side, {"card": state.get_in([NRUtil.to_side(side), "basic-action-card"]), "ability": 1})


static func play(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card"))
	if not (card is Dictionary):
		return
	if state.get_in([NRUtil.to_side(side), "prompt-state", "prompt-type"]) != null:
		return
	var typ = str(card.get("type"))
	var bac = state.get_in([NRUtil.to_side(side), "basic-action-card"])
	if typ in ["Event", "Operation"]:
		play_ability(state, side, {"card": bac, "ability": 3, "targets": [NRUtil.merge(args, {"card": card})]})
	elif typ in ["Hardware", "Resource", "Program", "ICE", "Upgrade", "Asset", "Agenda"]:
		play_ability(state, side, {"card": bac, "ability": 2, "targets": [NRUtil.merge(args, {"card": card})]})


static func click_run(state: NRState, side: Variant, args: Dictionary) -> void:
	var server = args.get("server", args.get("target"))
	play_ability(state, side, {"card": state.get_in(["runner", "basic-action-card"]), "ability": 4, "targets": [{"server": server}]})


static func click_advance(state: NRState, side: Variant, args: Dictionary) -> void:
	play_ability(state, side, {"card": state.get_in(["corp", "basic-action-card"]), "ability": 4, "targets": [args]})


static func remove_tag(state: NRState, side: Variant, _args: Variant = null) -> void:
	play_ability(state, side, {"card": state.get_in(["runner", "basic-action-card"]), "ability": 5})


static func do_purge(state: NRState, side: Variant, _args: Variant = null) -> void:
	play_ability(state, side, {"card": state.get_in(["corp", "basic-action-card"]), "ability": 6})


static func trash_resource(state: NRState, side: Variant, _args: Variant = null) -> void:
	play_ability(state, side, {"card": state.get_in(["corp", "basic-action-card"]), "ability": 5})


static func score(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary) or not NRFlags.can_score(state, side, c, args):
		NREid.effect_completed(state, side, eid)
		return
	NRSay.system_msg(state, side, "scores %s" % NRCard.get_title(c))
	var moved = NRMoving.move(state, "corp", c, "scored")
	if moved is Dictionary:
		moved["new"] = true
		NRAgendas.update_all_agenda_points(state)
		NRInitializing.card_init(state, "corp", moved, {"resolve-effect": true, "init-data": true})
	NREngine.queue_event(state, "agenda-scored", {"card": moved})
	NRWinning.check_win_by_agenda(state)
	NREngine.checkpoint(state, eid)


static func advance(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary) or not NRFlags.can_advance(state, side, c):
		NREid.effect_completed(state, side, eid)
		return
	NRAgendas.update_advancement_requirement(state, c)
	NRProps.add_prop(state, side, eid, c, "advance-counter", 1, args)


static func resolve_prompt(state: NRState, side: Variant, args: Dictionary) -> void:
	var s = NRUtil.to_side(side)
	var prompts: Array = state.get_in([s, "prompt"], [])
	if prompts.is_empty():
		return
	var prompt: Dictionary = prompts[0]
	NRPromptState.remove_from_prompt_queue(state, s, prompt)
	if NRUtil.kw_eq(prompt.get("prompt-type"), "waiting"):
		return
	var choice = args.get("choice", args.get("value", args))
	var effect = prompt.get("effect")
	if effect is Callable:
		effect.call({"value": choice, "uuid": args.get("uuid")})


static func select(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card"))
	if not (card is Dictionary):
		return
	var s = NRUtil.to_side(side)
	var selected_arr: Array = state.get_in([s, "selected"], [])
	if selected_arr.is_empty():
		return
	var selected: Dictionary = selected_arr[0]
	var cards: Array = selected.get("cards", [])
	var c2 = card.duplicate(true)
	c2["selected"] = true
	cards.append(c2)
	selected["cards"] = cards
	selected_arr[0] = selected
	state.assoc_in([s, "selected"], selected_arr)
	var ability: Dictionary = selected.get("ability", {})
	var maxn = NRUtil.get_in(ability, ["choices", "max"], 1)
	if maxn is Callable:
		maxn = maxn.call(state, s, ability.get("eid"), ability.get("card"), null)
	if cards.size() >= int(maxn) or NRUtil.truthy(args.get("done", false)):
		NRPrompts.resolve_select(state, s, ability.get("eid", NREid.make_eid(state)), ability.get("card"), {})


static func play_subroutine(state: NRState, side: Variant, args: Dictionary) -> void:
	var ice = NRIce.get_current_ice(state)
	if not (ice is Dictionary):
		return
	var idx: int = int(args.get("subroutine", args.get("index", 0)))
	var subs: Array = ice.get("subroutines", [])
	if idx < 0 or idx >= subs.size():
		return
	NRIce.resolve_subroutine(state, side, NREid.make_eid(state), ice, subs[idx])


static func play_unbroken_subroutines(state: NRState, side: Variant, _args: Variant = null) -> void:
	var ice = NRIce.get_current_ice(state)
	if ice is Dictionary:
		NRIce.resolve_unbroken_subs(state, side, NREid.make_eid(state), ice)


static func generate_install_list(state: NRState, _side: Variant, args: Dictionary) -> void:
	var card = args.get("card")
	if card is Dictionary:
		state.setv("install-list", NRBoard.installable_servers(state, card))


static func generate_runnable_zones(state: NRState, _side: Variant, _args: Variant = null) -> void:
	state.setv("runnable-list", NRServers.zones_to_sorted_names(NRRuns.get_runnable_zones(state)))


static func view_deck(state: NRState, side: Variant, _args: Variant = null) -> void:
	state.assoc_in([NRUtil.to_side(side), "view-deck"], true)
	NRSay.system_msg(state, side, "looks at the top of [pronoun] deck")


static func close_deck(state: NRState, side: Variant, _args: Variant = null) -> void:
	state.assoc_in([NRUtil.to_side(side), "view-deck"], false)


static func move_card(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card"))
	var server = args.get("server")
	if not (card is Dictionary) or server == null:
		return
	match str(server):
		"HQ", "R&D", "Archives", "Grip", "Stack", "Heap":
			var dest = "hand"
			if str(server) in ["R&D", "Stack"]:
				dest = "deck"
			elif str(server) in ["Archives", "Heap"]:
				dest = "discard"
			NRMoving.move(state, NRUtil.to_side(card.get("side")), card, dest)
		_:
			pass


static func play_corp_ability(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card"))
	if not (card is Dictionary):
		return
	var idx: int = int(args.get("ability", 0))
	var abs: Array = card.get("corp-abilities", [])
	if idx >= 0 and idx < abs.size():
		NREngine.resolve_ability(state, side, abs[idx], card, args.get("targets"))


static func play_runner_ability(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card"))
	if not (card is Dictionary):
		return
	var idx: int = int(args.get("ability", 0))
	var abs: Array = card.get("runner-abilities", [])
	if idx >= 0 and idx < abs.size():
		NREngine.resolve_ability(state, side, abs[idx], card, args.get("targets"))


static func play_dynamic_ability(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = NRCard.get_card(state, args.get("card"))
	var dynamic = args.get("dynamic")
	if card is Dictionary and dynamic is Dictionary:
		NREngine.resolve_ability(state, side, dynamic, card, args.get("targets"))


static func trash_button(state: NRState, side: Variant, eid: Dictionary, card: Dictionary) -> void:
	if card is Dictionary:
		NRMoving.trash(state, side, eid, card, {})
	else:
		NREid.effect_completed(state, side, eid)


static func resolve_bad_pub_choice(state: NRState, side: Variant, args: Dictionary) -> void:
	resolve_prompt(state, side, args)
