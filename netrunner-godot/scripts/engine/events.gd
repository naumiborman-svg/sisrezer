class_name NREvents
extends RefCounted
## Turn / run event queries. Port of game.core.events.

static func turn_events(state: NRState, _side: Variant, ev: String) -> Array:
	var out: Array = []
	for entry in state.getv("turn-events", []):
		if entry is Array and not entry.is_empty() and NRUtil.kw_eq(entry[0], ev):
			out.append(entry.slice(1) if entry.size() > 1 else [])
	return out


static func last_turn(state: NRState, side: Variant, event: String) -> bool:
	return bool(state.get_in([NRUtil.to_side(side), "register-last-turn", event], false))


static func not_last_turn(state: NRState, side: Variant, event: String) -> bool:
	var reg = state.get_in([NRUtil.to_side(side), "register-last-turn"])
	if reg == null:
		return false
	if reg is Dictionary and reg.get(event):
		return false
	return true


static func no_event(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> bool:
	var p := pred if pred.is_valid() else func(_t): return true
	for t in turn_events(state, side, ev):
		if p.call(t):
			return false
	return true


static func event_count(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> int:
	var p := pred if pred.is_valid() else func(_t): return true
	var n := 0
	for t in turn_events(state, side, ev):
		if p.call(t):
			n += 1
	return n


static func first_event(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> bool:
	return event_count(state, side, ev, pred) == 1


static func second_event(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> bool:
	return event_count(state, side, ev, pred) == 2


static func first_successful_run_on_server(state: NRState, server: Variant) -> bool:
	return first_event(state, "runner", "successful-run", func(t):
		var ctx = NRUtil.first_of(t)
		return ctx is Dictionary and NRUtil.as_array(ctx.get("server")) == [server]
	)


static func first_trash(state: NRState, pred: Callable = Callable()) -> bool:
	return event_count(state, null, "runner-trash", pred) + event_count(state, null, "corp-trash", pred) + event_count(state, null, "game-trash", pred) == 1


static func get_turn_damage(state: NRState, _side: Variant = null) -> int:
	var n := 0
	for t in turn_events(state, "runner", "damage"):
		var ctx = NRUtil.first_of(t)
		if ctx is Dictionary:
			n += int(ctx.get("amount", 0))
	return n


static func get_installed_trashed(state: NRState, side: Variant) -> Array:
	var ev := "corp-trash" if NRUtil.to_side(side) == "corp" else "runner-trash"
	var out: Array = []
	for targets in turn_events(state, side, ev):
		for t in NRUtil.as_array(targets):
			if t is Dictionary and t.get("card") is Dictionary and NRCard.installed(t["card"]):
				out.append(t)
	return out


static func first_installed_trash(state: NRState, side: Variant) -> bool:
	return get_installed_trashed(state, side).size() == 1


static func first_installed_trash_own(state: NRState, side: Variant) -> bool:
	var n := 0
	for t in get_installed_trashed(state, side):
		if NRUtil.same_side(NRUtil.get_in(t, ["card", "side"]), side):
			n += 1
	return n == 1


static func run_events(state: NRState, _side: Variant, ev: String) -> Array:
	var run = state.getv("run")
	if not (run is Dictionary):
		return []
	var out: Array = []
	for entry in run.get("events", []):
		if entry is Array and not entry.is_empty() and NRUtil.kw_eq(entry[0], ev):
			out.append(entry.slice(1) if entry.size() > 1 else [])
	return out


static func no_run_event(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> bool:
	var p := pred if pred.is_valid() else func(_t): return true
	for t in run_events(state, side, ev):
		if p.call(t):
			return false
	return true


static func run_event_count(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> int:
	var p := pred if pred.is_valid() else func(_t): return true
	var n := 0
	for t in run_events(state, side, ev):
		if p.call(t):
			n += 1
	return n


static func first_run_event(state: NRState, side: Variant, ev: String, pred: Callable = Callable()) -> bool:
	return run_event_count(state, side, ev, pred) == 1
