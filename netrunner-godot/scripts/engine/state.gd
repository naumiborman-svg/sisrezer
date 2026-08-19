class_name NRState
extends RefCounted
## Mutable game state wrapping a Dictionary. Clojure `@state` / `swap!` equivalent.

var data: Dictionary = {}

func getv(key: Variant, default_value: Variant = null) -> Variant:
	return data.get(key, default_value)


func setv(key: Variant, value: Variant) -> void:
	data[key] = value


func get_in(path: Array, default_value: Variant = null) -> Variant:
	return NRUtil.get_in(data, path, default_value)


func assoc_in(path: Array, value: Variant) -> void:
	NRUtil.assoc_in(data, path, value)


func update_in(path: Array, updater: Callable, default_value: Variant = 0) -> void:
	NRUtil.update_in(data, path, updater, default_value)


func dissoc_in(path: Array) -> void:
	NRUtil.dissoc_in(data, path)


func inc_in(path: Array, n: int = 1) -> void:
	update_in(path, NRUtil.inc_n(n), 0)


func player(side: Variant) -> Dictionary:
	var s = NRUtil.to_side(side)
	var p = data.get(s, {})
	return p if p is Dictionary else {}


func side_get(side: Variant, key: String, default_value: Variant = null) -> Variant:
	return get_in([NRUtil.to_side(side), key], default_value)


func side_set(side: Variant, key: String, value: Variant) -> void:
	assoc_in([NRUtil.to_side(side), key], value)


func make_rid() -> int:
	var current: int = int(data.get("rid", 1))
	data["rid"] = current + 1
	return current


static func new_state(gameid: Variant, room: Variant, fmt: Variant, now: Variant, options: Dictionary, corp: Dictionary, runner: Dictionary) -> NRState:
	var st = NRState.new()
	st.data = {
		"gameid": gameid,
		"log": {"public": [], "corp": [], "runner": []},
		"active-player": "runner",
		"end-turn": true,
		"format": NRUtil.to_kw(fmt),
		"history": [],
		"mark": null,
		"room": room,
		"rid": 1,
		"turn": 0,
		"eid": 0,
		"sfx": [],
		"sfx-current-id": 0,
		"stats": {"time": {"started": now}},
		"start-date": now,
		"options": options,
		"encounters": [],
		"sequence": 0,
		"corp": corp,
		"runner": runner,
		"effects": [],
		"events": [],
		"queued-events": {},
		"effect-completed": {},
		"suppress": [],
		"turn-events": [],
		"bonus": {},
		"stack": {},
		"trash": {},
		"end-run": {},
		"per-run": {},
		"per-turn": {},
		"per-encounter": {},
		"winner": null,
		"loser": null,
		"reason": null,
		"run": null,
		"psi": {},
		"trace": {},
		"damage": {},
		"access": null,
		"breach": {},
		"prompt": {},
		"disabled-card-reg": {},
		"last-revealed": [],
		"click-states": [],
		"corp-phase-12": false,
		"runner-phase-12": false,
		"corp-post-discard": false,
		"runner-post-discard": false,
	}
	return st
