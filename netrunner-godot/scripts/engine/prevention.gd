class_name NRPrevention
extends RefCounted
## Prevention windows (damage, trash, tags, end-run, encounter, expose, bad-pub).
## Port of game.core.prevention — full simultaneous prevention UI is simplified:
## numeric remaining is reduced by lingering :prevent-* effects, then resolved.

static func preventable(state: NRState, key: String) -> bool:
	return int(state.get_in(["prevention", key, "remaining"], 0)) > 0


static func push_prevention(state: NRState, key: String, amount: int, context: Dictionary = {}) -> void:
	var stack: Array = state.get_in(["prevention", "stack"], [])
	stack.append({"key": key, "remaining": amount, "context": context})
	state.assoc_in(["prevention", "stack"], stack)
	state.assoc_in(["prevention", key], {"remaining": amount, "context": context})


static func fetch_and_clear(state: NRState, key: String) -> Dictionary:
	var cur: Dictionary = state.get_in(["prevention", key], {"remaining": 0})
	state.dissoc_in(["prevention", key])
	return cur


static func prevent_numeric(state: NRState, key: String, n: int) -> void:
	var rem: int = int(state.get_in(["prevention", key, "remaining"], 0))
	state.assoc_in(["prevention", key, "remaining"], maxi(rem - n, 0))


static func prevent_damage(state: NRState, n: int) -> void:
	prevent_numeric(state, "damage", n)


static func prevent_tag(state: NRState, n: int) -> void:
	prevent_numeric(state, "tag", n)


static func prevent_bad_publicity(state: NRState, n: int) -> void:
	prevent_numeric(state, "bad-publicity", n)


static func prevent_expose(state: NRState) -> void:
	prevent_numeric(state, "expose", 1)


static func _sum_prevent(state: NRState, side: Variant, effect_type: String, context: Variant) -> int:
	return NREffects.sum_effects(state, side, effect_type, context)


static func resolve_damage_prevention(state: NRState, side: Variant, eid: Dictionary, typ: String, n: int, args: Dictionary = {}) -> void:
	if NRUtil.truthy(args.get("unpreventable", false)):
		NREid.complete_with_result(state, side, eid, {"remaining": n, "type": typ, "source-card": args.get("card")})
		return
	push_prevention(state, "damage", n, {"type": typ, "card": args.get("card")})
	var prevented = _sum_prevent(state, "runner", "prevent-damage", {"type": typ, "amount": n})
	prevent_numeric(state, "damage", prevented)
	var remaining: int = int(state.get_in(["prevention", "damage", "remaining"], n))
	fetch_and_clear(state, "damage")
	NREid.complete_with_result(state, side, eid, {"remaining": remaining, "type": typ, "source-card": args.get("card")})


static func resolve_tag_prevention(state: NRState, side: Variant, eid: Dictionary, n: int, args: Dictionary = {}) -> void:
	if NRUtil.truthy(args.get("unpreventable", false)):
		NREid.complete_with_result(state, side, eid, {"remaining": n})
		return
	push_prevention(state, "tag", n, args)
	var prevented = _sum_prevent(state, "runner", "prevent-tag", {"amount": n})
	prevent_numeric(state, "tag", prevented)
	var remaining: int = int(state.get_in(["prevention", "tag", "remaining"], n))
	fetch_and_clear(state, "tag")
	NREid.complete_with_result(state, side, eid, {"remaining": remaining})


static func resolve_bad_pub_prevention(state: NRState, side: Variant, eid: Dictionary, n: int, args: Dictionary = {}) -> void:
	if NRUtil.truthy(args.get("unpreventable", false)):
		NREid.complete_with_result(state, side, eid, {"remaining": n})
		return
	push_prevention(state, "bad-publicity", n, args)
	var prevented = _sum_prevent(state, "corp", "prevent-bad-publicity", {"amount": n})
	prevent_numeric(state, "bad-publicity", prevented)
	var remaining: int = int(state.get_in(["prevention", "bad-publicity", "remaining"], n))
	fetch_and_clear(state, "bad-publicity")
	NREid.complete_with_result(state, side, eid, {"remaining": remaining})


static func resolve_trash_prevention(state: NRState, side: Variant, eid: Dictionary, cards: Array, args: Dictionary = {}) -> void:
	if NRUtil.truthy(args.get("unpreventable", false)):
		NREid.complete_with_result(state, side, eid, {"remaining": cards})
		return
	var remaining: Array = []
	for c in cards:
		if c is Dictionary and NRFlags.can_trash(state, side, c):
			remaining.append(c)
	NREid.complete_with_result(state, side, eid, {"remaining": remaining})


static func resolve_encounter_prevention(state: NRState, side: Variant, eid: Dictionary, _ctx: Dictionary = {}) -> void:
	NREid.complete_with_result(state, side, eid, {"remaining": 1})


static func resolve_end_run_prevention(state: NRState, side: Variant, eid: Dictionary) -> void:
	NREid.complete_with_result(state, side, eid, {"remaining": 1})


static func resolve_jack_out_prevention(state: NRState, side: Variant, eid: Dictionary) -> void:
	NREid.complete_with_result(state, side, eid, {"remaining": 1})


static func resolve_expose_prevention(state: NRState, side: Variant, eid: Dictionary) -> void:
	var remaining = 1 - _sum_prevent(state, "corp", "prevent-expose", null)
	NREid.complete_with_result(state, side, eid, {"remaining": maxi(remaining, 0)})


static func prevent_up_to_n_damage(n: int, types: Array = ["net", "meat", "brain"]) -> Dictionary:
	return {
		"msg": "prevent up to %d damage" % n,
		"effect": func(state, _s, eid, _c, _t):
			prevent_damage(state, n)
			NREid.effect_completed(state, _s, eid),
	}


static func prevent_up_to_n_tags(n: int) -> Dictionary:
	return {
		"msg": "prevent up to %s" % NRUtil.quantify(n, "tag"),
		"effect": func(state, _s, eid, _c, _t):
			prevent_tag(state, n)
			NREid.effect_completed(state, _s, eid),
	}
