class_name NREid
extends RefCounted
## Effect-id (continuation) helpers. Port of game.core.eid.

static func make_eid(state: NRState, existing: Variant = null) -> Dictionary:
	var n: int = int(state.getv("eid", 0)) + 1
	state.setv("eid", n)
	var eid: Dictionary = {}
	if existing is Dictionary:
		eid = (existing as Dictionary).duplicate(true)
	eid["eid"] = n
	return eid


static func get_ability_targets(eid: Dictionary) -> Variant:
	return NRUtil.get_in(eid, ["source-info", "ability-targets", 0])


static func is_basic_advance_action(eid: Dictionary) -> bool:
	var src = eid.get("source")
	if not (src is Dictionary):
		return false
	if not NRCard.basic_action(src):
		return false
	return int(NRUtil.get_in(eid, ["source-info", "ability-idx"], -1)) == 4


static func register_effect_completed(state: NRState, eid: Dictionary, effect: Callable) -> void:
	var id = eid.get("eid")
	var table: Dictionary = state.getv("effect-completed", {})
	if table.has(id):
		push_error("Eid has already been registered: %s" % str(id))
		return
	table[id] = effect
	state.setv("effect-completed", table)


static func clear_eid_wait_prompt(state: NRState, side: String, eid: Dictionary) -> void:
	var prompts: Array = state.get_in([side, "prompt"], [])
	if not (prompts is Array):
		return
	var eid_id = eid.get("eid")
	var to_remove: Array = []
	for p in prompts:
		if p is Dictionary and NRUtil.kw_eq(p.get("prompt-type"), "waiting"):
			var pe = p.get("eid")
			var peid = pe.get("eid") if pe is Dictionary else null
			if peid == eid_id:
				to_remove.append(p)
	for p in to_remove:
		NRPromptState.remove_from_prompt_queue(state, side, p)


static func effect_completed(state: NRState, _side: Variant, eid: Dictionary) -> void:
	if eid == null or not eid.has("eid"):
		return
	for side in ["corp", "runner"]:
		clear_eid_wait_prompt(state, side, eid)
	var table: Dictionary = state.getv("effect-completed", {})
	var id = eid.get("eid")
	if table.has(id):
		var handler: Callable = table[id]
		table.erase(id)
		state.setv("effect-completed", table)
		handler.call(eid)
	else:
		state.setv("effect-completed", table)


static func make_result(eid: Dictionary, result: Variant) -> Dictionary:
	var e = eid.duplicate(true)
	e["result"] = result
	return e


static func complete_with_result(state: NRState, side: Variant, eid: Dictionary, result: Variant) -> void:
	effect_completed(state, side, make_result(eid, result))


static func wait_for(state: NRState, parent_eid: Dictionary, start: Callable, then: Callable) -> void:
	var new_eid = make_eid(state, parent_eid)
	register_effect_completed(state, new_eid, func(done_eid: Dictionary):
		then.call(done_eid.get("result"))
	)
	start.call(new_eid)


static func result_of(eid: Dictionary) -> Variant:
	return eid.get("result") if eid is Dictionary else null
