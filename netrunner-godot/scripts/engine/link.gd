class_name NRLink
extends RefCounted
## Runner link strength. Port of game.core.link.

static func get_link(state: NRState, _side: Variant = null) -> int:
	var link = state.get_in(["runner", "link"])
	if link != null:
		return int(link)
	return int(state.get_in(["runner", "identity", "baselink"], 0))


static func update_link(state: NRState, _side: Variant = null) -> bool:
	var id: Dictionary = state.get_in(["runner", "identity"], {})
	var old_link := get_link(state)
	var new_link: int = int(id.get("baselink", 0)) + NREffects.sum_effects(state, "runner", "user-link") + NREffects.sum_effects(state, "runner", "link", id)
	if old_link != new_link:
		state.assoc_in(["runner", "link"], new_link)
		return true
	return false


static func link_plus(req: Variant, value: Variant = null) -> Dictionary:
	if value == null:
		value = req
		req = func(_s, _sd, _e, _c, _t): return true
	return {"type": "link", "req": req, "value": value}
