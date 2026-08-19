class_name NROptional
extends RefCounted

## Port of game.core.optional (optional-ability / check-optional).


static func optional_ability(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, message: Variant, ability: Dictionary, targets: Variant) -> void:
	var yes_ab: Dictionary = ability.get("yes-ability", {})
	var no_ab: Dictionary = ability.get("no-ability", {})
	var prompt: String = str(message) if not (message is Callable) else str(message.call(state, side, eid, card, targets))
	var auto = ability.get("autoresolve")
	var auto_ans = ""
	if auto is Callable:
		auto_ans = str(auto.call(state, side, eid, card, targets))
	var yes_ok = true
	if not yes_ab.is_empty():
		yes_ok = NRPayment.has_enough(state, side, eid, card, yes_ab.get("cost", []))
		var yreq = yes_ab.get("req")
		if yreq is Callable:
			yes_ok = yes_ok and NRUtil.truthy(yreq.call(state, side, eid, card, targets))
	var choices: Array = []
	if yes_ok:
		choices.append("Yes")
	choices.append("No")
	var finish = func(choice: Variant) -> void:
		var val = choice.get("value") if choice is Dictionary else choice
		var todo: Dictionary = yes_ab if str(val) == "Yes" and not yes_ab.is_empty() else no_ab
		if ability.has("once") and not todo.is_empty():
			todo = todo.duplicate(true)
			todo["once"] = ability.get("once")
		NREid.wait_for(state, eid, func(ne):
			if todo.is_empty():
				NREid.effect_completed(state, side, ne)
			else:
				NREngine.resolve_ability(state, side, ne, todo, card, targets)
		, func(_r):
			var end_effect = ability.get("end-effect")
			if end_effect is Callable:
				end_effect.call(state, side, eid, card, targets)
			NREid.effect_completed(state, side, eid)
		)
	if auto_ans == "Yes" or auto_ans == "No":
		finish.call({"value": auto_ans})
		return
	if auto is Callable:
		NRToasts.toast(state, side, "This prompt can be skipped by toggling autoresolve on %s" % card.get("title", "this card"), "info")
	NRPrompts.show_prompt(state, side, eid, card, prompt if prompt != "" else "Pay the optional cost?", choices, finish, {"waiting-prompt": ability.get("waiting-prompt")})


static func check_optional(state: NRState, side: Variant, ability: Dictionary, card: Dictionary, targets: Variant) -> void:
	var opt: Dictionary = ability.get("optional", {})
	var eid: Dictionary = ability.get("eid", NREid.make_eid(state))
	if not NREngine.can_trigger(state, side, eid, opt, card, targets):
		NREid.effect_completed(state, side, eid)
		return
	var prompt = opt.get("prompt", "Do you want to trigger the optional ability?")
	var player = opt.get("player", side)
	if player is Callable:
		player = player.call(state, side, eid, card, targets)
	NREngine.resolve_ability(state, side, eid, {
		"async": true,
		"effect": func(st, sd, e, c, t):
			optional_ability(st, player, e, c, prompt, opt, t)
	}, card, targets)
