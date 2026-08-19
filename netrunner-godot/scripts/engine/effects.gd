class_name NREffects
extends RefCounted
## Static / lingering effect registry. Port of game.core.effects.

static func is_disabled_reg(state: NRState, card: Dictionary) -> bool:
	var reg = state.getv("disabled-card-reg", {})
	return reg is Dictionary and reg.has(card.get("cid"))


static func gather_effects(state: NRState, _side: Variant, effect_type: String) -> Array:
	var active := str(state.getv("active-player", "corp"))
	var out: Array = []
	for e in state.getv("effects", []):
		if not (e is Dictionary):
			continue
		if NRUtil.to_kw(e.get("type")) != NRUtil.to_kw(effect_type):
			continue
		if bool(e.get("static", false)) and e.get("card") is Dictionary and is_disabled_reg(state, e["card"]):
			continue
		out.append(e)
	out.sort_custom(func(a, b):
		var sa := NRUtil.to_side(NRUtil.get_in(a, ["card", "side"]))
		var sb := NRUtil.to_side(NRUtil.get_in(b, ["card", "side"]))
		var aa := 0 if sa == active else 1
		var bb := 0 if sb == active else 1
		return aa < bb
	)
	return out


static func update_effect_card(state: NRState, ability: Dictionary) -> Dictionary:
	var ab := ability.duplicate(true)
	if ab.get("card") is Dictionary:
		var latest = NRCard.get_card(state, ab["card"])
		ab["card"] = latest
	return ab


static func get_effect_maps(state: NRState, side: Variant, eid: Dictionary, effect_type: String, targets: Variant = null) -> Array:
	var out: Array = []
	for e in gather_effects(state, side, effect_type):
		var ab := update_effect_card(state, e)
		var req = ab.get("req")
		var ok := true
		if req is Callable:
			ok = bool(req.call(state, side, eid, ab.get("card"), targets))
		if ok:
			out.append(ab)
	return out


static func get_effect_value(state: NRState, side: Variant, eid: Dictionary, targets: Variant, effect_map: Dictionary) -> Variant:
	var value = effect_map.get("value")
	if value is Callable:
		return value.call(state, side, eid, effect_map.get("card"), targets)
	return value


static func get_effects(state: NRState, side: Variant, effect_type: String, target: Variant = null, targets: Variant = null) -> Array:
	var eid := NREid.make_eid(state)
	var tgs: Array = []
	if target != null:
		tgs.append(target)
	if targets is Array:
		tgs.append_array(targets)
	var maps := get_effect_maps(state, side, eid, effect_type, tgs)
	var out: Array = []
	for m in maps:
		out.append(get_effect_value(state, side, eid, tgs, m))
	return out


static func get_tagged_effects(state: NRState, side: Variant, effect_type: String, target: Variant = null, targets: Variant = null) -> Array:
	var eid := NREid.make_eid(state)
	var tgs: Array = []
	if target != null:
		tgs.append(target)
	if targets is Array:
		tgs.append_array(targets)
	var out: Array = []
	for m in get_effect_maps(state, side, eid, effect_type, tgs):
		var value = get_effect_value(state, side, eid, tgs, m)
		if value is Dictionary:
			value = value.duplicate(true)
			value["cid"] = NRUtil.get_in(m, ["card", "cid"])
			value["uuid"] = m.get("uuid")
			out.append(value)
		else:
			out.append({"value": value, "cid": NRUtil.get_in(m, ["card", "cid"]), "uuid": m.get("uuid")})
	return out


static func sum_effects(state: NRState, side: Variant, effect_type: String, target: Variant = null, targets: Variant = null) -> int:
	var total := 0
	for v in get_effects(state, side, effect_type, target, targets):
		if NRUtil.is_number(v):
			total += int(v)
	return total


static func any_effects(state: NRState, side: Variant, effect_type: String, pred: Variant = null, target: Variant = null, targets: Variant = null) -> bool:
	var p: Callable = pred if pred is Callable else func(v): return v == true or (v is Callable and v.call() == true)
	# default pred is true?
	if pred == null:
		p = func(v): return v == true
	elif pred is Callable and pred.get_argument_count() == 1:
		p = pred
	for v in get_effects(state, side, effect_type, target, targets):
		if p.call(v):
			return true
	return false


static func is_disabled(state: NRState, side: Variant, target: Dictionary) -> bool:
	return any_effects(state, side, "disable-card", func(v): return v == true, target)


static func all_disabled_cards(state: NRState) -> Dictionary:
	var out := {}
	for c in NRBoard.get_all_cards(state):
		if c is Dictionary and (is_disabled(state, null, c) or (NRCard.runner(c) and NRCard.facedown(c))):
			out[c.get("cid")] = c
	return out


static func update_disabled_cards(state: NRState) -> Dictionary:
	var reg := all_disabled_cards(state)
	state.setv("disabled-card-reg", reg)
	return reg


static func register_static_abilities(state: NRState, _side: Variant, card: Dictionary) -> Array:
	var cdef := NRCardDefs.card_def(card)
	var statics = cdef.get("static-abilities", [])
	if not (statics is Array) or statics.is_empty():
		return []
	var abilities: Array = []
	for ability in statics:
		if ability is Dictionary:
			abilities.append({
				"type": ability.get("type"),
				"req": ability.get("req"),
				"value": ability.get("value"),
				"static": true,
				"duration": "while-active",
				"card": card,
				"uuid": NRUtil.make_uuid(),
			})
	var effects: Array = state.getv("effects", [])
	effects.append_array(abilities)
	state.setv("effects", effects)
	update_disabled_cards(state)
	return abilities


static func unregister_static_abilities(state: NRState, _side: Variant, card: Dictionary) -> void:
	var effects: Array = []
	for e in state.getv("effects", []):
		if e is Dictionary and NRUtil.same_card(card, e.get("card", {})) and NRUtil.kw_eq(e.get("duration"), "while-active"):
			continue
		effects.append(e)
	state.setv("effects", effects)
	update_disabled_cards(state)


static func register_lingering_effect(state: NRState, _side: Variant, card: Dictionary, ability: Dictionary) -> Dictionary:
	var ab := {
		"type": ability.get("type"),
		"req": ability.get("req"),
		"value": ability.get("value"),
		"duration": ability.get("duration", true),
		"card": card,
		"lingering": true,
		"uuid": NRUtil.make_uuid(),
	}
	var effects: Array = state.getv("effects", [])
	effects.append(ab)
	state.setv("effects", effects)
	update_disabled_cards(state)
	return ab


static func unregister_effect_by_uuid(state: NRState, _side: Variant, ability: Dictionary) -> void:
	var uuid = ability.get("uuid")
	var effects: Array = []
	var removed := false
	for e in state.getv("effects", []):
		if not removed and e is Dictionary and e.get("uuid") == uuid:
			removed = true
			continue
		effects.append(e)
	state.setv("effects", effects)


static func update_lingering_effect_durations(state: NRState, _side: Variant, from_key: String, to_key: String) -> void:
	var effects: Array = []
	for e in state.getv("effects", []):
		if e is Dictionary and NRUtil.kw_eq(e.get("duration"), from_key):
			var ne := e.duplicate(true)
			ne["duration"] = to_key
			effects.append(ne)
		else:
			effects.append(e)
	state.setv("effects", effects)
	update_disabled_cards(state)


static func unregister_lingering_effects(state: NRState, _side: Variant, duration: String) -> void:
	var effects: Array = []
	for e in state.getv("effects", []):
		if e is Dictionary and NRUtil.kw_eq(e.get("duration"), duration):
			continue
		effects.append(e)
	state.setv("effects", effects)
	update_disabled_cards(state)


static func unregister_effects_for_card(state: NRState, _side: Variant, card: Dictionary, pred: Callable = Callable()) -> void:
	var effects: Array = []
	for e in state.getv("effects", []):
		if e is Dictionary and NRUtil.same_card(card, e.get("card", {})):
			if pred.is_valid() and not pred.call(e):
				effects.append(e)
			elif not pred.is_valid():
				continue
			else:
				continue
		else:
			effects.append(e)
	state.setv("effects", effects)
	update_disabled_cards(state)
