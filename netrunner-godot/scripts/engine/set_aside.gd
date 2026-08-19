class_name NRSetAside
extends RefCounted
## Set-aside zone. Port of game.core.set_aside.

static func set_aside(state: NRState, side: Variant, eid: Dictionary, cards: Array, args: Dictionary = {}) -> Array:
	var s = NRUtil.to_side(side)
	var moved: Array = []
	for c in cards:
		if c is Dictionary:
			var vis = {
				"corp-can-see": NRUtil.truthy(args.get("corp-can-see", s == "corp")),
				"runner-can-see": NRUtil.truthy(args.get("runner-can-see", s == "runner")),
			}
			var mc = c.duplicate(true)
			mc["set-aside-visibility"] = vis
			mc["set-aside-eid"] = eid.get("eid")
			var result = NRMoving.move(state, s, mc, "set-aside")
			if result is Dictionary:
				moved.append(result)
	var tracking: Dictionary = state.get_in([s, "set-aside-tracking"], {})
	tracking[eid.get("eid")] = []
	for m in moved:
		tracking[eid.get("eid")].append(m.get("cid"))
	state.assoc_in([s, "set-aside-tracking"], tracking)
	return moved


static func set_aside_for_me(state: NRState, side: Variant, eid: Dictionary, cards: Array) -> Array:
	var s = NRUtil.to_side(side)
	return set_aside(state, s, eid, cards, {"corp-can-see": s == "corp", "runner-can-see": s == "runner"})


static func get_set_aside(state: NRState, side: Variant, eid: Dictionary) -> Array:
	var s = NRUtil.to_side(side)
	var ids: Array = state.get_in([s, "set-aside-tracking", eid.get("eid")], [])
	var out: Array = []
	for c in state.get_in([s, "set-aside"], []):
		if c is Dictionary and c.get("cid") in ids:
			out.append(c)
	return out


static func clean_set_aside(state: NRState, side: Variant) -> void:
	var s = NRUtil.to_side(side)
	for c in state.get_in([s, "set-aside"], []).duplicate():
		if c is Dictionary:
			NRMoving.move(state, s, c, "discard")
	state.assoc_in([s, "set-aside"], [])
	state.assoc_in([s, "set-aside-tracking"], {})


static func add_to_set_aside(state: NRState, side: Variant, eid: Dictionary, card: Dictionary) -> void:
	set_aside_for_me(state, side, eid, [card])


static func swap_set_aside_cards(_state: NRState, _side: Variant, _a: Dictionary, _b: Dictionary) -> void:
	pass
