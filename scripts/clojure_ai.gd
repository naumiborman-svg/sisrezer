class_name ClojureAi
extends RefCounted


static func actor(state: Dictionary) -> String:
	var prompt: Variant = state.get("prompt", null)
	if prompt is Dictionary and str(prompt.get("side", "")) != "":
		return str(prompt["side"])
	return str(state.get("active", "corp"))


static func pick(state: Dictionary, side: String) -> Dictionary:
	var best: Dictionary = {}
	var best_score := -99999
	for item: Variant in state.get("actions", []):
		if not item is Dictionary:
			continue
		var act: Dictionary = item
		var who := str(act.get("side", side))
		if who != "" and who != side:
			continue
		var score := _score(state, act, side)
		if score > best_score:
			best_score = score
			best = act
	return best


static func _score(state: Dictionary, act: Dictionary, side: String) -> int:
	var cmd := str(act.get("command", ""))
	var label := str(act.get("label", "")).to_lower()
	var corp: Dictionary = state.get("corp", {})
	var runner: Dictionary = state.get("runner", {})
	match cmd:
		"choice":
			if label == "keep":
				return 200
			if label.find("steal") >= 0:
				return 190
			if label.find("score") >= 0:
				return 185
			if label == "mulligan":
				return -20
			if label.find("cancel") >= 0 or label == "no":
				return 5
			return 80
		"select":
			return 70
		"score":
			return 170
		"run":
			var server := str(act.get("args", {}).get("server", "")).to_lower()
			if _naked(state, server):
				return 140
			if server.find("archives") >= 0:
				return 55
			if server.find("hq") >= 0:
				return 50
			if server.find("r&d") >= 0 or server.find("rd") >= 0:
				return 45
			return 30
		"play":
			if label.find("sure gamble") >= 0 or label.find("hedge fund") >= 0:
				return 95
			return 60
		"rez":
			return 75
		"advance":
			return 85
		"credit":
			var creds: int = int((corp if side == "corp" else runner).get("credits", 0))
			return 40 if creds < 6 else 15
		"draw":
			var hand_n: int = int((corp if side == "corp" else runner).get("hand_count", 0))
			return 35 if hand_n < 5 else 10
		"continue":
			return 90
		"jack-out":
			return 20
		"end-phase-12":
			return 100
		"start-turn":
			return 110
		"end-turn":
			return 8
		"remove-tag":
			return 65
		"ability":
			if label.find("break") >= 0:
				return 88
			return 40
	return 1


static func _naked(state: Dictionary, server: String) -> bool:
	var servers: Dictionary = state.get("servers", {})
	var ices: Array = []
	if server.find("hq") >= 0:
		ices = servers.get("hq", {}).get("ices", [])
	elif server.find("r&d") >= 0 or server == "rd":
		ices = servers.get("rd", {}).get("ices", [])
	elif server.find("archives") >= 0:
		ices = servers.get("archives", {}).get("ices", [])
	else:
		for remote: Variant in servers.get("remotes", []):
			if remote is Dictionary and str(remote.get("name", "")).to_lower().find(server) >= 0:
				ices = remote.get("ices", [])
	return ices.is_empty()
