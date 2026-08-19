class_name NRTrace
extends RefCounted
## Traces. Port of game.core.trace.

static func init_trace(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, trace: Dictionary, targets: Variant = null) -> void:
	var base = trace.get("base", 0)
	if base is Callable:
		base = int(base.call(state, side, eid, card, targets))
	state.setv("trace", {"base": int(base), "bonus": 0, "card": card, "eid": eid, "ability": trace, "targets": targets, "corp": null, "runner": null})
	_corp_boost(state, eid, card, int(base), trace, targets)


static func _corp_boost(state: NRState, eid: Dictionary, card: Dictionary, base: int, trace: Dictionary, targets: Variant) -> void:
	var credits := NRCosts.total_available_credits(state, "corp", eid, card)
	NRPrompts.show_trace_prompt(state, "corp", eid, card, "Boost trace strength? (base %d)" % base, func(choice):
		var boost := int(choice.get("value", choice) if choice is Dictionary else choice)
		boost = clampi(boost, 0, credits)
		state.assoc_in(["trace", "corp"], boost)
		NREid.wait_for(state, eid, func(pe):
			NREngine.pay(state, "corp", pe, card, [NRPayment.to_c("credit", boost)])
		, func(_p):
			_runner_link(state, eid, card, base + boost, trace, targets)
		)
	, {"corp-credits": credits, "runner-credits": 0, "base": base})


static func _runner_link(state: NRState, eid: Dictionary, card: Dictionary, strength: int, trace: Dictionary, targets: Variant) -> void:
	var link := NRLink.get_link(state)
	var credits := NRCosts.total_available_credits(state, "runner", eid, card)
	NRPrompts.show_trace_prompt(state, "runner", eid, card, "Boost link? (base link %d vs trace %d)" % [link, strength], func(choice):
		var boost := int(choice.get("value", choice) if choice is Dictionary else choice)
		boost = clampi(boost, 0, credits)
		state.assoc_in(["trace", "runner"], boost)
		NREid.wait_for(state, eid, func(pe):
			NREngine.pay(state, "runner", pe, card, [NRPayment.to_c("credit", boost)])
		, func(_p):
			_resolve_trace(state, eid, card, strength, link + boost, trace, targets)
		)
	, {"corp-credits": 0, "runner-credits": credits, "base": link, "strength": strength, "link": link})


static func _resolve_trace(state: NRState, eid: Dictionary, card: Dictionary, strength: int, link: int, trace: Dictionary, targets: Variant) -> void:
	var successful := strength >= link
	NRSay.system_say(state, null, "Trace attempt: Corp %d vs Runner %d — %s" % [strength, link, "success" if successful else "failure"])
	var ability = trace.get("successful") if successful else trace.get("unsuccessful")
	var kicker = trace.get("kicker")
	var kmin: int = int(trace.get("kicker-min", 0))
	if ability is Dictionary:
		NREngine.continue_ability(state, "corp", NRUtil.merge(ability, {"async": true}), card, targets)
	elif kicker is Dictionary and successful and strength >= kmin:
		NREngine.continue_ability(state, "corp", NRUtil.merge(kicker, {"async": true}), card, targets)
	else:
		NREid.effect_completed(state, "corp", eid)
	state.setv("trace", {})


static func check_trace(state: NRState, side: Variant, ability: Dictionary, card: Dictionary, targets: Variant) -> void:
	var trace: Dictionary = ability.get("trace", {})
	if NREngine.can_trigger(state, side, ability.get("eid"), trace, card, targets):
		init_trace(state, side, ability.get("eid"), card, trace, targets)
	else:
		NREid.effect_completed(state, side, ability.get("eid"))


static func force_base(state: NRState, n: int) -> void:
	state.assoc_in(["trace", "base"], n)
