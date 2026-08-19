class_name NRHandSize
extends RefCounted
## Hand size calculation. Port of game.core.hand_size.

static func hand_size(state: NRState, side: Variant) -> int:
	return int(state.get_in([NRUtil.to_side(side), "hand-size", "total"], 5))


static func sum_hand_size_effects(state: NRState, side: Variant) -> int:
	var s := NRUtil.to_side(side)
	return int(state.get_in([s, "hand-size", "base"], 5)) - int(state.get_in([s, "brain-damage"], 0)) + NREffects.sum_effects(state, s, "hand-size") + NREffects.sum_effects(state, s, "user-hand-size")


static func update_hand_size(state: NRState, side: Variant) -> bool:
	var s := NRUtil.to_side(side)
	var old_total: int = int(state.get_in([s, "hand-size", "total"], 5))
	var new_total := sum_hand_size_effects(state, s)
	if old_total != new_total:
		state.assoc_in([s, "hand-size", "total"], new_total)
		return true
	return false


static func hand_size_plus(req: Variant, value: Variant = null) -> Dictionary:
	if value == null:
		value = req
		req = func(_s, _sd, _e, _c, _t): return true
	return {"type": "hand-size", "req": req, "value": value}
