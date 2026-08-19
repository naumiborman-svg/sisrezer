class_name NRGaining
extends RefCounted
## Gain/lose clicks, credits, and generic attributes. Port of game.core.gaining.

static func deduct(state: NRState, side: Variant, attr: String, value: Variant) -> void:
	var s = NRUtil.to_side(side)
	if value is Dictionary:
		for subattr in value:
			var amt: int = int(value[subattr])
			if str(subattr) in ["mod", "used"]:
				state.update_in([s, attr, subattr], func(v): return (0 if v == null else int(v)) - amt, 0)
			else:
				state.update_in([s, attr, subattr], NRUtil.sub_to_zero(amt), 0)
		return
	if attr == "memory":
		deduct(state, side, attr, {"mod": value})
		return
	if attr in ["tag", "bad-publicity"]:
		deduct(state, side, attr, {"base": value})
		return
	if attr == "agenda-point":
		state.update_in([s, attr], func(v): return (0 if v == null else int(v)) - int(value), 0)
	else:
		state.update_in([s, attr], NRUtil.sub_to_zero(int(value)), 0)
	if attr == "credit" and s == "runner" and int(state.get_in(["runner", "run-credit"], 0)) > 0:
		state.update_in(["runner", "run-credit"], NRUtil.sub_to_zero(int(value)), 0)


static func gain(state: NRState, side: Variant, cost_type: String, amount: Variant) -> void:
	var s = NRUtil.to_side(side)
	if amount is Dictionary:
		for subtype in amount:
			state.update_in([s, cost_type, subtype], NRUtil.inc_n(int(amount[subtype])), 0)
			state.update_in(["stats", s, "gain", cost_type, subtype], NRUtil.inc_n(int(amount[subtype])), 0)
	elif cost_type in ["hand-size", "memory"]:
		gain(state, side, cost_type, {"mod": amount})
		return
	elif cost_type in ["tag", "bad-publicity"]:
		gain(state, side, cost_type, {"base": amount})
		return
	else:
		state.update_in([s, cost_type], NRUtil.inc_n(int(amount)), 0)
		state.update_in(["stats", s, "gain", cost_type], NRUtil.inc_n(int(amount)), 0)
	NREngine.trigger_event(state, side, ("corp-gain" if s == "corp" else "runner-gain"), {"type": cost_type, "amount": amount})


static func lose(state: NRState, side: Variant, cost_type: String, amount: Variant) -> void:
	var s = NRUtil.to_side(side)
	if str(amount) == "all" or NRUtil.kw_eq(amount, "all"):
		state.update_in(["stats", s, "lose", cost_type], NRUtil.inc_n(int(state.get_in([s, cost_type], 0))), 0)
		state.assoc_in([s, cost_type], 0)
	else:
		if NRUtil.is_number(amount):
			state.update_in(["stats", s, "lose", cost_type], NRUtil.inc_n(int(amount)), 0)
		deduct(state, side, cost_type, amount)
	NREngine.trigger_event(state, side, ("corp-lose" if s == "corp" else "runner-lose"), {"type": cost_type, "amount": amount})


static func gain_credits(state: NRState, side: Variant, eid: Dictionary, amount: int, args: Dictionary = {}) -> void:
	if amount > 0:
		var s = NRUtil.to_side(side)
		var event = "corp-credit-gain" if s == "corp" else "runner-credit-gain"
		gain(state, s, "credit", amount)
		NREngine.queue_event(state, event, {"side": s, "amount": amount, "source": eid.get("source"), "action": args.get("action")})
		if NRUtil.truthy(args.get("suppress-checkpoint", false)):
			NREid.effect_completed(state, null, eid)
		else:
			NREngine.checkpoint(state, eid)
	else:
		NREid.effect_completed(state, side, eid)


static func lose_credits(state: NRState, side: Variant, eid: Dictionary, amount: Variant, args: Dictionary = {}) -> void:
	var s = NRUtil.to_side(side)
	var credits: int = int(state.side_get(s, "credit", 0))
	var all = NRUtil.kw_eq(amount, "all") or str(amount) == "all"
	if amount != null and (all or (NRUtil.is_number(amount) and int(amount) > 0)) and credits > 0 and not NREffects.any_effects(state, s, "cannot-lose-credits"):
		lose(state, s, "credit", amount)
		if s == "runner" and all:
			lose(state, "runner", "run-credit", "all")
		NREngine.trigger_event_sync(state, s, eid, ("corp-credit-loss" if s == "corp" else "runner-credit-loss"), null)
	else:
		NREid.effect_completed(state, s, eid)


static func gain_clicks(state: NRState, side: Variant, amount: int, args: Dictionary = {}) -> void:
	if amount > 0:
		var s = NRUtil.to_side(side)
		gain(state, s, "click", amount)
		NREngine.trigger_event(state, s, ("corp-click-gain" if s == "corp" else "runner-click-gain"), {"amount": amount, "args": args})


static func lose_clicks(state: NRState, side: Variant, amount: Variant, args: Dictionary = {}) -> void:
	var all = NRUtil.kw_eq(amount, "all") or str(amount) == "all"
	if amount != null and (all or (NRUtil.is_number(amount) and int(amount) > 0)):
		var s = NRUtil.to_side(side)
		lose(state, s, "click", amount)
		NREngine.trigger_event(state, s, ("corp-click-loss" if s == "corp" else "runner-click-loss"), {"amount": amount, "args": args})


static func base_mod_size(state: NRState, side: Variant, prop: String) -> int:
	var s = NRUtil.to_side(side)
	return int(state.get_in([s, prop, "base"], 0)) + int(state.get_in([s, prop, "mod"], 0))
