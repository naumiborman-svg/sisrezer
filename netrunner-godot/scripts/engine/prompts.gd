class_name NRPrompts
extends RefCounted
## Player prompts. Port of game.core.prompts.

static func choice_parser(choices: Variant) -> Variant:
	if choices is Dictionary or choices is String:
		return choices
	var out: Array = []
	var idx = 0
	for choice in NRUtil.as_array(choices):
		if choice == null:
			continue
		out.append({"value": choice, "uuid": NRUtil.make_uuid(), "idx": idx})
		idx += 1
	return out


static func show_prompt(state: NRState, side: Variant, eid: Dictionary, card: Variant, message: Variant, choices: Variant, f: Callable, args: Dictionary = {}) -> void:
	var s = NRUtil.to_side(side)
	var prompt = str(message) if not (message is Callable) else str(message.call(state, s, eid, card, args.get("targets")))
	var parsed = choice_parser(choices)
	var item = {
		"eid": eid,
		"msg": prompt,
		"choices": parsed,
		"effect": f,
		"card": card,
		"prompt-type": args.get("prompt-type", "other"),
		"cancel": args.get("cancel"),
		"end-effect": args.get("end-effect"),
		"show-discard": args.get("show-discard"),
	}
	if NRUtil.truthy(args.get("waiting-prompt", false)):
		NRPromptState.add_to_prompt_queue(state, NRUtil.other_side(s), {
			"eid": {"eid": eid.get("eid")},
			"card": card,
			"prompt-type": "waiting",
			"msg": "Waiting for %s to make a decision" % NRUtil.side_str(s),
		})
	NRPromptState.add_to_prompt_queue(state, s, item)


static func show_prompt_with_dice(state: NRState, side: Variant, card: Variant, message: String, other_choices: Array, f: Callable, args: Dictionary = {}) -> void:
	var dice_msg = "Roll a d6"
	var choices = other_choices.duplicate()
	choices.append(dice_msg)
	show_prompt(state, side, NREid.make_eid(state), card, message, choices, func(choice):
		var val = choice.get("value") if choice is Dictionary else choice
		if str(val) != dice_msg:
			f.call(choice)
		else:
			show_prompt(state, side, NREid.make_eid(state), card, "%s (Dice result: %d)" % [message, randi_range(1, 6)], other_choices, f, args)
	, args)


static func show_trace_prompt(state: NRState, side: Variant, eid: Dictionary, card: Variant, message: String, f: Callable, args: Dictionary) -> void:
	var s = NRUtil.to_side(side)
	var item = {
		"eid": eid,
		"msg": message,
		"choices": args.get("corp-credits") if s == "corp" else args.get("runner-credits"),
		"prompt-type": "trace",
		"effect": f,
		"card": card,
		"base": args.get("base"),
		"bonus": args.get("bonus"),
		"strength": args.get("strength"),
		"link": args.get("link"),
	}
	NRPromptState.add_to_prompt_queue(state, s, item)


static func first_prompt_by_eid(state: NRState, side: Variant, eid: Dictionary, typ: Variant = null) -> Variant:
	for p in state.get_in([NRUtil.to_side(side), "prompt"], []):
		if p is Dictionary:
			var pe = p.get("eid")
			var peid = pe.get("eid") if pe is Dictionary else null
			if peid == eid.get("eid") and (typ == null or NRUtil.kw_eq(p.get("prompt-type"), typ)):
				return p
	return null


static func resolve_select(state: NRState, side: Variant, eid: Dictionary, card: Variant, args: Dictionary) -> void:
	var s = NRUtil.to_side(side)
	var selected_arr: Array = state.get_in([s, "selected"], [])
	var selected = selected_arr[0] if not selected_arr.is_empty() else {}
	var cards: Array = []
	if selected is Dictionary:
		for c in selected.get("cards", []):
			if c is Dictionary:
				var cc = c.duplicate(true)
				cc.erase("selected")
				cards.append(cc)
	var prompt = first_prompt_by_eid(state, s, eid, "select")
	if prompt is Dictionary:
		NRPromptState.remove_from_prompt_queue(state, s, prompt)
	state.assoc_in([s, "selected"], [])
	if not cards.is_empty():
		NREngine.resolve_ability(state, s, selected.get("ability", {}), card, cards)
	elif args.get("cancel") is Callable:
		args["cancel"].call(null)
	else:
		NREid.effect_completed(state, s, eid)


static func show_select(state: NRState, side: Variant, card: Variant, ability: Dictionary, args: Dictionary = {}) -> void:
	var s = NRUtil.to_side(side)
	var choices: Dictionary = ability.get("choices", {})
	show_prompt(state, s, ability.get("eid", NREid.make_eid(state)), card, ability.get("prompt", "Choose a card"), {"select": true, "max": choices.get("max", 1), "all": choices.get("all"), "req": choices.get("req"), "card": choices.get("card")}, func(choice):
		NREngine.resolve_ability(state, s, NRUtil.dissoc(ability, ["choices"]), card, [choice])
	, NRUtil.merge(args, {"prompt-type": "select"}))
	var selected: Array = state.get_in([s, "selected"], [])
	selected.append({"ability": ability, "cards": []})
	state.assoc_in([s, "selected"], selected)


static func show_wait_prompt(state: NRState, side: Variant, msg: String, _args: Dictionary = {}) -> void:
	NRPromptState.add_to_prompt_queue(state, NRUtil.to_side(side), {
		"eid": {"eid": -1},
		"prompt-type": "waiting",
		"msg": msg,
	})


static func clear_wait_prompt(state: NRState, side: Variant) -> void:
	var s = NRUtil.to_side(side)
	var prompts: Array = state.get_in([s, "prompt"], [])
	var out: Array = []
	for p in prompts:
		if p is Dictionary and NRUtil.kw_eq(p.get("prompt-type"), "waiting"):
			continue
		out.append(p)
	state.assoc_in([s, "prompt"], out)
	NRPromptState.set_prompt_state(state, s)


static func show_run_prompts(state: NRState, msg: String, card: Variant) -> void:
	for side in ["corp", "runner"]:
		NRPromptState.add_to_prompt_queue(state, side, {
			"eid": {"eid": state.get_in(["run", "eid", "eid"]) if state.getv("run") is Dictionary else 0},
			"prompt-type": "run",
			"msg": msg,
			"card": card,
		})


static func clear_run_prompts(state: NRState) -> void:
	for side in ["corp", "runner"]:
		var prompts: Array = state.get_in([side, "prompt"], [])
		var out: Array = []
		for p in prompts:
			if p is Dictionary and NRUtil.kw_eq(p.get("prompt-type"), "run"):
				continue
			out.append(p)
		state.assoc_in([side, "prompt"], out)
		NRPromptState.set_prompt_state(state, side)


static func cancellable(choices: Array) -> Array:
	var c = choices.duplicate()
	c.append("Cancel")
	return c
