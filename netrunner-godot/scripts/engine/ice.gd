class_name NRIce
extends RefCounted
## ICE strength, subroutines, breakers. Port of game.core.ice.

static func get_run_ices(state: NRState) -> Array:
	var run = state.getv("run")
	if not (run is Dictionary):
		return []
	return state.get_in(["corp", "servers"] + NRUtil.as_array(run.get("server")) + ["ices"], [])


static func get_current_ice(state: NRState) -> Variant:
	var encounters: Array = state.getv("encounters", [])
	if not encounters.is_empty() and encounters[encounters.size() - 1] is Dictionary:
		var ice = encounters[encounters.size() - 1].get("ice")
		var latest = NRCard.get_card(state, ice) if ice is Dictionary else null
		if latest != null:
			return latest
	var cur = state.get_in(["run", "current-ice"])
	if cur is Dictionary:
		var latest2 = NRCard.get_card(state, cur)
		return latest2 if latest2 != null else cur
	return cur


static func set_current_ice(state: NRState, card: Variant = "__auto__") -> void:
	if not (state.getv("run") is Dictionary):
		return
	if str(card) == "__auto__":
		var run_ice := get_run_ices(state)
		var pos: int = int(state.get_in(["run", "position"], 0))
		if pos > 0 and pos <= run_ice.size():
			set_current_ice(state, run_ice[pos - 1])
		return
	if card == null:
		state.assoc_in(["run", "current-ice"], null)
		return
	state.assoc_in(["run", "current-ice"], NRCard.get_card(state, card) if card is Dictionary else card)


static func active_ice(state: NRState, ice: Variant = null) -> bool:
	if ice == null:
		ice = get_current_ice(state)
	if not (ice is Dictionary):
		return false
	if NRCard.installed(ice):
		return NRCard.rezzed(ice)
	var encounters: Array = state.getv("encounters", [])
	if encounters.is_empty():
		return false
	var enc_ice = encounters[encounters.size() - 1].get("ice")
	return NRUtil.same_card(ice, enc_ice) if enc_ice is Dictionary else false


static func build_sub(sub: Dictionary, cid: Variant, args: Dictionary = {}) -> Dictionary:
	return {
		"label": NRUtil.make_label(sub),
		"from-cid": cid,
		"sub-effect": sub.get("sub-effect", NRUtil.dissoc(sub, ["breakable"])),
		"variable": bool(args.get("variable", false)),
		"printed": bool(args.get("printed", false)),
		"source": sub.get("source", ("printed" if bool(args.get("printed")) else null)),
		"breakable": sub.get("breakable", true),
	}


static func add_sub(ice: Dictionary, sub: Dictionary, cid: Variant = null, args: Dictionary = {}) -> Dictionary:
	if cid == null:
		cid = ice.get("cid")
	var curr: Array = ice.get("subroutines", [])
	var position := 0
	if bool(args.get("back", false)):
		position = 1
	elif bool(args.get("front", false)):
		position = -1
	var new_sub := build_sub(sub, cid, args)
	new_sub["position"] = position
	curr = curr.duplicate()
	curr.append(new_sub)
	curr.sort_custom(func(a, b): return int(a.get("position", 0)) < int(b.get("position", 0)))
	for i in range(curr.size()):
		curr[i] = curr[i].duplicate(true)
		curr[i]["index"] = i
	var out := ice.duplicate(true)
	out["subroutines"] = curr
	return out


static func break_subroutine(ice: Dictionary, sub: Dictionary, breaker: Variant = null) -> Dictionary:
	var replacement := sub.duplicate(true)
	replacement["broken"] = true
	if breaker is Dictionary:
		replacement["breaker"] = breaker.get("cid")
		replacement["breaker-subtypes"] = breaker.get("subtypes")
	var subs: Array = ice.get("subroutines", []).duplicate()
	var idx: int = int(sub.get("index", -1))
	if idx >= 0 and idx < subs.size():
		subs[idx] = replacement
	var out := ice.duplicate(true)
	out["subroutines"] = subs
	return out


static func break_subroutine_bang(state: NRState, ice: Dictionary, sub: Dictionary, breaker: Variant = null) -> void:
	var c = NRCard.get_card(state, ice)
	if c is Dictionary:
		NRUpdate.update_card(state, "corp", break_subroutine(c, sub, breaker))


static func break_all_subroutines(ice: Dictionary, breaker: Variant = null) -> Dictionary:
	var cur := ice
	for sub in ice.get("subroutines", []):
		if sub is Dictionary:
			cur = break_subroutine(cur, sub, breaker)
	return cur


static func break_all_subroutines_bang(state: NRState, ice: Dictionary, breaker: Variant = null) -> void:
	NRUpdate.update_card(state, "corp", break_all_subroutines(ice, breaker))


static func any_subs_broken(ice: Dictionary) -> bool:
	for sub in ice.get("subroutines", []):
		if sub is Dictionary and bool(sub.get("broken")):
			return true
	return false


static func all_subs_broken(ice: Dictionary) -> bool:
	var subs: Array = ice.get("subroutines", [])
	if subs.is_empty():
		return true
	for sub in subs:
		if not (sub is Dictionary) or not bool(sub.get("broken")):
			return false
	return true


static func reset_all_subs(ice: Dictionary) -> Dictionary:
	var out := ice.duplicate(true)
	var subs: Array = []
	for sub in ice.get("subroutines", []):
		if sub is Dictionary:
			var s := sub.duplicate(true)
			s.erase("broken")
			s.erase("fired")
			s.erase("resolve")
			subs.append(s)
	out["subroutines"] = subs
	return out


static func reset_all_subs_bang(state: NRState, ice: Dictionary) -> void:
	var c = NRCard.get_card(state, ice)
	if c is Dictionary:
		NRUpdate.update_card(state, "corp", reset_all_subs(c))


static func reset_all_ice(state: NRState, _side: Variant) -> void:
	for ice in NRBoard.all_installed(state, "corp"):
		if ice is Dictionary and NRCard.ice(ice):
			reset_all_subs_bang(state, ice)


static func get_strength(card: Dictionary) -> int:
	if card.has("current-strength") and card["current-strength"] != null:
		return int(card["current-strength"])
	return int(card.get("strength", 0))


static func ice_strength(state: NRState, ice: Dictionary) -> int:
	var base: int = int(ice.get("strength", 0))
	var cdef := NRCardDefs.card_def(ice)
	if cdef.get("strength-bonus") is Callable:
		base += int(cdef["strength-bonus"].call(state, "corp", NREid.make_eid(state), ice, null))
	elif NRUtil.is_number(cdef.get("strength-bonus")):
		base += int(cdef["strength-bonus"])
	base += NREffects.sum_effects(state, "corp", "ice-strength", ice)
	base += int(ice.get("advance-counter", 0)) if NRCard.has_subtype(ice, "Power") or bool(ice.get("strength-boost-from-advancement")) else 0
	return base + int(ice.get("extra-strength", 0))


static func update_ice_strength(state: NRState, side: Variant, ice: Dictionary) -> bool:
	var c = NRCard.get_card(state, ice)
	if not (c is Dictionary) or not NRCard.ice(c):
		return false
	var prev = c.get("current-strength")
	var new_s := ice_strength(state, c)
	if prev != new_s:
		c = c.duplicate(true)
		c["current-strength"] = new_s
		NRUpdate.update_card(state, side, c)
		return true
	return false


static func update_all_ice(state: NRState, side: Variant) -> bool:
	var changed := false
	for ice in NRBoard.all_installed(state, "corp"):
		if ice is Dictionary and NRCard.ice(ice):
			if update_ice_strength(state, side, ice):
				changed = true
	return changed


static func breaker_strength(state: NRState, breaker: Dictionary) -> int:
	var base: int = int(breaker.get("strength", 0))
	var cdef := NRCardDefs.card_def(breaker)
	if cdef.get("strength-bonus") is Callable:
		base += int(cdef["strength-bonus"].call(state, "runner", NREid.make_eid(state), breaker, null))
	base += NREffects.sum_effects(state, "runner", "breaker-strength", breaker)
	base += int(breaker.get("pump-strength", 0))
	return base


static func update_breaker_strength(state: NRState, side: Variant, card: Dictionary) -> bool:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		return false
	var prev = c.get("current-strength")
	var new_s := breaker_strength(state, c)
	if prev != new_s:
		c = c.duplicate(true)
		c["current-strength"] = new_s
		NRUpdate.update_card(state, side, c)
		return true
	return false


static func update_all_icebreakers(state: NRState, side: Variant) -> bool:
	var changed := false
	for c in NRBoard.all_active_installed(state, "runner"):
		if c is Dictionary and NRCard.has_subtype(c, "Icebreaker"):
			if update_breaker_strength(state, side, c):
				changed = true
	return changed


static func pump(state: NRState, side: Variant, card: Dictionary, n: int, duration: String = "end-of-encounter") -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		return
	c = c.duplicate(true)
	c["pump-strength"] = int(c.get("pump-strength", 0)) + n
	NRUpdate.update_card(state, side, c)
	update_breaker_strength(state, side, c)
	NREffects.register_lingering_effect(state, side, c, {
		"type": "breaker-strength",
		"duration": duration,
		"value": 0, # pump stored on card; lingering just to expire
		"req": func(_st, _sd, _e, _cd, _t): return false,
	})


static func get_pump_strength(card: Dictionary) -> int:
	return int(card.get("pump-strength", 0))


static func resolve_subroutine(state: NRState, side: Variant, eid: Dictionary, ice: Dictionary, sub: Dictionary) -> void:
	var c = NRCard.get_card(state, ice)
	if not (c is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	if bool(sub.get("broken")) or sub.get("resolve") == false:
		NREid.effect_completed(state, side, eid)
		return
	var effect: Dictionary = sub.get("sub-effect", {})
	NRSay.system_msg(state, "corp", "%s fires %s" % [NRCard.get_title(c), sub.get("label", "a subroutine")])
	var fired := sub.duplicate(true)
	fired["fired"] = true
	var updated := c.duplicate(true)
	var subs: Array = updated.get("subroutines", []).duplicate()
	var idx := int(sub.get("index", -1))
	if idx >= 0 and idx < subs.size():
		subs[idx] = fired
		updated["subroutines"] = subs
		NRUpdate.update_card(state, "corp", updated)
	NREngine.resolve_ability(state, "corp", eid, NRUtil.merge(effect, {"async": true}), c, [sub])


static func resolve_unbroken_subs(state: NRState, side: Variant, eid: Dictionary, ice: Dictionary) -> void:
	var c = NRCard.get_card(state, ice)
	if not (c is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	var to_fire: Array = []
	for sub in c.get("subroutines", []):
		if sub is Dictionary and not bool(sub.get("broken")) and sub.get("resolve", true) != false:
			to_fire.append(sub)
	_fire_next(state, side, eid, c, to_fire, 0)


static func _fire_next(state: NRState, side: Variant, eid: Dictionary, ice: Dictionary, subs: Array, idx: int) -> void:
	if idx >= subs.size():
		NREid.effect_completed(state, side, eid)
		return
	NREid.wait_for(state, eid, func(ne):
		resolve_subroutine(state, side, ne, ice, subs[idx])
	, func(_r):
		_fire_next(state, side, eid, ice, subs, idx + 1)
	)


static func break_subs_event_context(state: NRState, ice: Dictionary, broken: Array, breaker: Variant) -> Dictionary:
	return {"ice": ice, "broken-subs": broken, "breaker": breaker}


static func unbroken_subroutines_choice(ice: Dictionary) -> Array:
	var out: Array = []
	for sub in ice.get("subroutines", []):
		if sub is Dictionary and not bool(sub.get("broken")) and sub.get("resolve", true) != false:
			out.append(NRUtil.make_label(sub.get("sub-effect", sub)))
	return out
