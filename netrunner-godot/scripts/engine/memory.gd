class_name NRMemory
extends RefCounted
## Runner memory units. Port of game.core.memory.

static func mu_plus(req: Variant, value: Variant = null) -> Dictionary:
	if value == null:
		value = req
		req = func(_s, _sd, _e, _c, _t): return true
	return {"type": "available-mu", "req": req, "value": value}


static func virus_mu_plus(req: Variant, amount: Variant = null) -> Dictionary:
	if amount == null:
		amount = req
		req = func(_s, _sd, _e, _c, _t): return true
	return mu_plus(req, ["virus", amount])


static func caissa_mu_plus(req: Variant, amount: Variant = null) -> Dictionary:
	if amount == null:
		amount = req
		req = func(_s, _sd, _e, _c, _t): return true
	return mu_plus(req, ["caissa", amount])


static func available_mu(state: NRState, _side: Variant = null) -> int:
	var memory: Dictionary = state.get_in(["runner", "memory"], {})
	var avail: int = int(memory.get("available", 0))
	var only: Dictionary = memory.get("only-for", {})
	for k in only:
		if only[k] is Dictionary:
			avail += int(only[k].get("available", 0))
	return avail - int(memory.get("used", 0))


static func get_available_mu(state: NRState) -> Array:
	var out: Array = [["regular", int(state.get_in(["runner", "memory", "base"], 0))]]
	out.append_array(NREffects.get_effects(state, "runner", "user-available-mu"))
	out.append_array(NREffects.get_effects(state, "runner", "available-mu"))
	return out


static func merge_available_memory(mu_list: Array) -> Dictionary:
	var acc = {"regular": 0, "caissa": 0, "virus": 0}
	for pair in mu_list:
		if pair is Array and pair.size() >= 2:
			var t = str(pair[0])
			acc[t] = int(acc.get(t, 0)) + int(pair[1])
		elif NRUtil.is_number(pair):
			acc["regular"] += int(pair)
	return acc


static func merge_used_memory(state: NRState, used_mu_effects: Array) -> Dictionary:
	var acc = {"regular": 0, "caissa": 0, "virus": 0}
	var eid = NREid.make_eid(state)
	for effect in used_mu_effects:
		if not (effect is Dictionary):
			continue
		var val = NREffects.get_effect_value(state, "runner", eid, null, effect)
		var card = effect.get("card", {})
		if card is Dictionary and NRCard.has_subtype(card, "Caïssa"):
			acc["caissa"] += int(val)
		elif card is Dictionary and NRCard.virus_program(card):
			acc["virus"] += int(val)
		else:
			acc["regular"] += int(val)
	return acc


static func combine_used_mu(available: Dictionary, used: Dictionary) -> int:
	var total: int = int(used.get("regular", 0))
	for t in ["caissa", "virus"]:
		var diff: int = int(available.get(t, 0)) - int(used.get(t, 0))
		if diff < 0:
			total += -diff
	return total


static func build_new_mu(state: NRState) -> Dictionary:
	var mu_list = get_available_mu(state)
	var available = merge_available_memory(mu_list)
	var used_effects = NREffects.get_effect_maps(state, "runner", NREid.make_eid(state), "used-mu")
	var used = merge_used_memory(state, used_effects)
	var only_for = {}
	for t in ["caissa", "virus"]:
		only_for[t] = {"available": available.get(t, 0), "used": used.get(t, 0)}
	return {
		"only-for": only_for,
		"available": available.get("regular", 0),
		"used": combine_used_mu(available, used),
	}


static func update_mu(state: NRState, _side: Variant = null) -> bool:
	var old_mu = NRUtil.select_keys(state.get_in(["runner", "memory"], {}), ["available", "used", "only-for"])
	var new_mu = build_new_mu(state)
	var changed = old_mu.hash() != new_mu.hash() and str(old_mu) != str(new_mu)
	# compare fields
	changed = int(old_mu.get("available", 0)) != int(new_mu.get("available", 0)) or int(old_mu.get("used", 0)) != int(new_mu.get("used", 0))
	if changed:
		if int(new_mu["available"]) - int(new_mu["used"]) < 0:
			NRToasts.toast(state, "runner", "You have exceeded your memory units!")
		var mem: Dictionary = state.get_in(["runner", "memory"], {})
		for k in new_mu:
			mem[k] = new_mu[k]
		state.assoc_in(["runner", "memory"], mem)
	return changed


static func expected_mu(state: NRState, card: Dictionary) -> int:
	if NRCard.program(card):
		return int(card.get("memoryunits", 0))
	return 0


static func sufficient_mu(state: NRState, card: Dictionary) -> bool:
	if not NRCard.program(card):
		return true
	var mu_cost = expected_mu(state, card)
	var available = merge_available_memory(get_available_mu(state))
	var used_effects: Array = NREffects.get_effect_maps(state, "runner", NREid.make_eid(state), "used-mu")
	used_effects.append({"type": "used-mu", "duration": "while-active", "card": card, "value": mu_cost})
	var used = merge_used_memory(state, used_effects)
	return int(available.get("regular", 0)) - combine_used_mu(available, used) >= 0


static func init_mu_cost(state: NRState, card: Dictionary) -> void:
	NREffects.register_lingering_effect(state, "runner", card, {
		"type": "used-mu",
		"duration": "while-active",
		"value": int(card.get("memoryunits", 0)),
	})
	update_mu(state)
