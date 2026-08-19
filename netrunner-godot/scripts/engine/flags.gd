class_name NRFlags
extends RefCounted
## Permission flags (run/turn/persistent). Port of game.core.flags.

static func card_flag(card: Dictionary, flag_key: String, value: Variant = "__any__") -> bool:
	var cdef := NRCardDefs.card_def(card)
	var flags = cdef.get("flags", {})
	if not (flags is Dictionary) or not flags.has(flag_key):
		return false
	if str(value) == "__any__":
		return true
	return flags[flag_key] == value


static func card_flag_fn(state: NRState, side: Variant, card: Dictionary, flag_key: String, value: Variant = "__any__") -> bool:
	var cdef := NRCardDefs.card_def(card)
	var funcv = NRUtil.get_in(cdef, ["flags", flag_key])
	if not (funcv is Callable):
		return false
	var result = funcv.call(state, side, NREid.make_eid(state), card, null)
	if str(value) == "__any__":
		return bool(result)
	return result == value


static func any_flag_fn(state: NRState, side: Variant, flag_key: String, value: Variant, cards: Array = []) -> bool:
	var pool := cards if not cards.is_empty() else NRBoard.all_active(state, side)
	for c in pool:
		if c is Dictionary and card_flag_fn(state, side, c, flag_key, value):
			return true
	return false


static func register_flag(state: NRState, _side: Variant, card: Dictionary, flag_type: String, flag: String, condition: Callable) -> void:
	var arr: Array = state.get_in(["stack", flag_type, flag], [])
	arr.append({"card": card, "condition": condition})
	state.assoc_in(["stack", flag_type, flag], arr)


static func check_flag(state: NRState, side: Variant, card: Dictionary, flag_type: String, flag: String) -> bool:
	var conditions: Array = state.get_in(["stack", flag_type, flag], [])
	for c in conditions:
		if c is Dictionary and c.get("condition") is Callable:
			if not bool(c["condition"].call(state, side, card)):
				return false
	return true


static func check_flag_types(state: NRState, side: Variant, card: Dictionary, flag: String, flag_types: Array) -> bool:
	for ft in flag_types:
		if not check_flag(state, side, card, str(ft), flag):
			return false
	return true


static func get_preventing_cards(state: NRState, side: Variant, card: Dictionary, flag: String, flag_types: Array) -> Array:
	var out: Array = []
	for ft in flag_types:
		for c in state.get_in(["stack", ft, flag], []):
			if c is Dictionary and c.get("condition") is Callable and not bool(c["condition"].call(state, side, card)):
				out.append(c.get("card"))
	return out


static func has_flag(state: NRState, _side: Variant, flag_type: String, flag: String) -> bool:
	return not state.get_in(["stack", flag_type, flag], []).is_empty()


static func clear_all_flags(state: NRState, flag_type: String) -> void:
	state.assoc_in(["stack", flag_type], null)


static func clear_flag_for_card(state: NRState, _side: Variant, card: Dictionary, flag_type: String, flag: String) -> void:
	var arr: Array = state.get_in(["stack", flag_type, flag], [])
	var out: Array = []
	for c in arr:
		if not (c is Dictionary) or NRUtil.get_in(c, ["card", "cid"]) != card.get("cid"):
			out.append(c)
	state.assoc_in(["stack", flag_type, flag], out)


static func register_run_flag(state: NRState, side: Variant, card: Dictionary, flag: String, condition: Callable) -> void:
	register_flag(state, side, card, "current-run", flag, condition)


static func run_flag(state: NRState, side: Variant, card: Dictionary, flag: String) -> bool:
	return check_flag(state, side, card, "current-run", flag)


static func clear_run_register(state: NRState) -> void:
	clear_all_flags(state, "current-run")


static func clear_run_flag(state: NRState, side: Variant, card: Dictionary, flag: String) -> void:
	clear_flag_for_card(state, side, card, "current-run", flag)


static func register_turn_flag(state: NRState, side: Variant, card: Dictionary, flag: String, condition: Callable) -> void:
	register_flag(state, side, card, "current-turn", flag, condition)


static func turn_flag(state: NRState, side: Variant, card: Dictionary, flag: String) -> bool:
	return check_flag(state, side, card, "current-turn", flag)


static func clear_turn_register(state: NRState) -> void:
	clear_all_flags(state, "current-turn")


static func clear_turn_flag(state: NRState, side: Variant, card: Dictionary, flag: String) -> void:
	clear_flag_for_card(state, side, card, "current-turn", flag)


static func register_persistent_flag(state: NRState, side: Variant, card: Dictionary, flag: String, condition: Callable) -> void:
	register_flag(state, side, card, "persistent", flag, condition)


static func persistent_flag(state: NRState, side: Variant, card: Dictionary, flag: String) -> bool:
	return check_flag(state, side, card, "persistent", flag)


static func clear_persistent_flag(state: NRState, side: Variant, card: Dictionary, flag: String) -> void:
	clear_flag_for_card(state, side, card, "persistent", flag)


static func prevent_draw(state: NRState, _side: Variant) -> void:
	state.assoc_in(["runner", "register", "cannot-draw"], true)


static func prevent_current(state: NRState, _side: Variant) -> void:
	state.assoc_in(["runner", "register", "cannot-play-current"], true)


static func lock_zone(state: NRState, _side: Variant, cid: Variant, tside: Variant, tzone: Variant) -> void:
	var arr: Array = state.get_in([NRUtil.to_side(tside), "locked", NRUtil.to_kw(tzone)], [])
	arr.append(cid)
	state.assoc_in([NRUtil.to_side(tside), "locked", NRUtil.to_kw(tzone)], arr)


static func release_zone(state: NRState, _side: Variant, cid: Variant, tside: Variant, tzone: Variant) -> void:
	var arr: Array = state.get_in([NRUtil.to_side(tside), "locked", NRUtil.to_kw(tzone)], [])
	var out: Array = []
	for x in arr:
		if x != cid:
			out.append(x)
	state.assoc_in([NRUtil.to_side(tside), "locked", NRUtil.to_kw(tzone)], out)


static func zone_locked(state: NRState, side: Variant, zone: Variant) -> bool:
	return not state.get_in([NRUtil.to_side(side), "locked", NRUtil.to_kw(zone)], []).is_empty()


static func untrashable_while_rezzed(state: NRState, side: Variant, card: Dictionary) -> bool:
	return NREffects.any_effects(state, side, "cannot-be-trashed", func(v): return v == true, card)


static func untrashable_while_resources(card: Dictionary) -> bool:
	return card_flag(card, "untrashable-while-resources", true) and NRCard.installed(card)


static func can_rez_reason(state: NRState, side: Variant, card: Dictionary) -> Variant:
	if not NRUtil.same_side(side, card.get("side")):
		return "side"
	if not run_flag(state, side, card, "can-rez"):
		return "run-flag"
	if not turn_flag(state, side, card, "can-rez"):
		return "turn-flag"
	if not persistent_flag(state, side, card, "can-rez"):
		return "persistent-flag"
	var rez_req = NRCardDefs.card_def(card).get("rez-req")
	if rez_req is Callable and not bool(rez_req.call(state, side, NREid.make_eid(state), card, null)):
		return "req"
	return true


static func can_rez(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> bool:
	var reason = can_rez_reason(state, side, card)
	if reason == true:
		return true
	if not bool(args.get("no-toast", false)):
		NRToasts.toast(state, side, "Cannot rez %s." % NRCard.get_title(card))
	return false


static func can_steal(state: NRState, side: Variant, card: Dictionary) -> bool:
	return check_flag_types(state, side, card, "can-steal", ["current-run", "current-turn", "persistent"])


static func can_trash(state: NRState, side: Variant, card: Dictionary) -> bool:
	if untrashable_while_rezzed(state, side, card) and NRCard.rezzed(card):
		return false
	if untrashable_while_resources(card):
		var resources := 0
		for c in NRBoard.all_active_installed(state, "runner"):
			if NRCard.resource(c):
				resources += 1
		if resources < 2:
			return false
	return true


static func can_run(state: NRState, _side: Variant = "runner") -> bool:
	if state.getv("run") is Dictionary:
		return false
	return not NREffects.any_effects(state, "runner", "cannot-run", func(v): return v == true)


static func can_access(state: NRState, side: Variant, card: Dictionary) -> bool:
	return check_flag_types(state, side, card, "can-access", ["current-run", "current-turn", "persistent"])


static func can_access_loud(state: NRState, side: Variant, card: Dictionary) -> bool:
	var ok := can_access(state, side, card)
	if not ok:
		NRToasts.toast(state, side, "Cannot access %s." % NRCard.get_title(card))
	return ok


static func can_advance(state: NRState, side: Variant, card: Dictionary) -> bool:
	if not NRCard.can_be_advanced(card, state):
		return false
	return check_flag_types(state, side, card, "can-advance", ["current-turn", "persistent"])


static func can_score(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> bool:
	if not NRCard.agenda(card) or not NRCard.installed(card):
		return false
	var req = NRCard.get_advancement_requirement(card)
	if req == null:
		return false
	var counters := NRCard.get_counters(card, "advancement")
	if counters < int(req) and not bool(args.get("ignore-req", false)):
		return false
	return check_flag_types(state, side, card, "can-score", ["current-turn", "persistent"])


static func is_scored(state: NRState, side: Variant, card: Dictionary) -> bool:
	return NRFinding.find_cid(card.get("cid"), state.get_in([NRUtil.to_side(side), "scored"], [])) != null


static func in_corp_scored(state: NRState, card: Dictionary) -> bool:
	return is_scored(state, "corp", card)


static func in_runner_scored(state: NRState, card: Dictionary) -> bool:
	return is_scored(state, "runner", card)


static func can_host(_state: NRState, card: Dictionary) -> bool:
	return not card_flag(card, "cannot-host", true)


static func when_scored(card: Dictionary) -> bool:
	return NRCardDefs.card_def(card).has("on-score") or card_flag(card, "has-abilities-when-stolen", true)
