class_name NRAi
extends RefCounted


static func pick(engine: NREngine, who: String) -> Dictionary:
	var options: Array = engine.legal()
	if options.is_empty():
		return {}
	var scored: Array = []
	for act: Variant in options:
		if act is Dictionary:
			scored.append({"act": act, "s": _score(engine, who, act)})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.s) > int(b.s))
	return scored[0].act


static func _score(engine: NREngine, who: String, act: Dictionary) -> int:
	var op := str(act.get("op", ""))
	if who == NREngine.CORP:
		return _corp(engine, act, op)
	return _runner(engine, act, op)


static func _corp(engine: NREngine, act: Dictionary, op: String) -> int:
	match op:
		"score":
			return 1000
		"rez":
			var card := engine.find_uid(int(act.uid))
			if str(card.get("type", "")) == "ICE":
				return 400 - int(card.get("cost", 0))
			return 120
		"play":
			var played := engine.find_uid(int(act.uid))
			if str(played.get("code", "")) == "30075":
				return 300
			if str(played.get("code", "")) == "30064" and engine.corp.credits >= 12:
				return 280
			if str(played.get("code", "")) == "30040":
				return 160
			return 80
		"advance":
			return 220 + int(engine.find_uid(int(act.uid)).get("advancement", 0)) * 10
		"install":
			var inst := engine.find_uid(int(act.uid))
			if str(inst.get("type", "")) == "Agenda":
				return 200
			if str(inst.get("type", "")) == "ICE":
				if str(act.dest) in ["hq", "rd"] and engine.server_ices(str(act.dest)).is_empty():
					return 180
				if str(act.dest).begins_with("remote"):
					return 150
				return 90
			if str(inst.get("type", "")) == "Asset":
				return 130
			return 70
		"ability":
			return 140
		"credit":
			return 40
		"draw":
			return 35 if engine.corp.hand.size() < 5 else 10
		"end_turn":
			return 1
		"continue":
			return 50
		"no_rez":
			return 30
		"advance_free":
			return 500
	return 5


static func _runner(engine: NREngine, act: Dictionary, op: String) -> int:
	match op:
		"steal":
			return 1000
		"trash_access":
			return 200
		"pass_access":
			return 80
		"break":
			return 500
		"pump":
			return 420
		"bioroid_break":
			return 410
		"jack_out":
			if engine.phase == "encounter":
				return 20
			return 5
		"play":
			var card := engine.find_uid(int(act.uid))
			if str(card.get("code", "")) == "30030":
				return 360
			if str(card.get("code", "")) == "30028":
				return 240
			if str(card.get("code", "")) == "30012":
				return 180
			if str(card.get("code", "")) == "30029":
				return 170
			return 90
		"install":
			var inst := engine.find_uid(int(act.uid))
			if "Icebreaker" in inst.get("subtypes", []):
				return 300
			return 150
		"run":
			var ices: Array = engine.server_ices(str(act.server))
			if ices.is_empty():
				return 260
			if str(act.server) == "rd":
				return 120
			return 90
		"choose_server":
			if engine.server_ices(str(act.server)).is_empty():
				return 300
			return 80
		"ability":
			return 160
		"credit":
			return 40
		"draw":
			return 30
		"manegarm_credits":
			return 180
		"manegarm_clicks":
			return 160
		"continue":
			return 60
		"end_turn":
			return 1
	return 5
