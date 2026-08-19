extends RefCounted
class_name RunnerAI
## Simple Runner: build economy and breakers, then run poorly-protected servers.

static func pick(gs: GameState, acts: Array) -> Dictionary:
	if acts.is_empty():
		return {}
	var best: Dictionary = acts[0]
	var best_s := -99999
	for a in acts:
		var s := _score(gs, a)
		if s > best_s:
			best_s = s
			best = a
	return best


static func _score(gs: GameState, a: Dictionary) -> int:
	var t := str(a.get("type", ""))
	match t:
		"pending":
			return _pending(gs, a)
		"play":
			return _play(gs, a)
		"install":
			return _install(gs, a)
		"run":
			return _run(gs, a)
		"ability":
			var card: NRCard = a.get("card")
			if card != null and int(card.hosted_credits) >= 3:
				return 750
			return 400
		"credit":
			if gs.runner.credits < 5:
				return 300
			if gs.runner.credits < 9:
				return 80
			return 20
		"draw":
			if gs.runner.grip.size() < 3:
				return 900
			if gs.runner.grip.size() < 4:
				return 420
			if gs.runner.grip.size() < 6:
				return 90
			return 15
		"remove_tag":
			return 500 if gs.runner.tags > 0 else 0
		"boost":
			return 900
		"break":
			return 950
		"auto_break":
			return 1200
		"bioroid_break":
			return 200 if gs.runner.clicks > 1 else 40
		"resolve_subs":
			return 2000 if str(a.get("label", "")).find("All broken") >= 0 else 50
		"continue_run":
			return 400
		"jack_out":
			return 10
		"access_steal":
			return 10000
		"access_trash":
			var c: NRCard = gs.accessing
			if c != null and (c.has_subtype("Ambush") or c.card_type() == "upgrade"):
				return 700
			if c != null and c.card_type() == "asset":
				return 500
			return 80
		"access_done":
			return 40
		"discard":
			var d: NRCard = a.get("card")
			if d == null:
				return 10
			if d.card_type() == "event" and d.play_cost() > gs.runner.credits + 3:
				return 60
			if d.card_type() == "program" and _has_breaker_type(gs, d):
				return 70
			return 20
		"end_phase":
			return 5 if gs.runner.clicks == 0 else -40
		_:
			return 1


static func _play(gs: GameState, a: Dictionary) -> int:
	var card: NRCard = a.get("card")
	if card == null:
		return 100
	var title := card.title()
	if title.find("Sure Gamble") >= 0:
		return 2000
	if title.find("Creative Commission") >= 0:
		return 900 if gs.runner.clicks <= 1 else 100
	if title.find("VRcation") >= 0:
		return 850 if gs.runner.clicks <= 1 and gs.runner.grip.size() < 6 else 80
	if title.find("Wildcat") >= 0:
		return 400
	if title.find("Jailbreak") >= 0:
		var srv: NRServer = a.get("server")
		return 500 + _run(gs, {"server": srv, "type": "run"})
	if title.find("Overclock") >= 0 or title.find("Tread") >= 0:
		var srv2: NRServer = a.get("server")
		return 350 + _run(gs, {"server": srv2, "type": "run"})
	return 120


static func _install(gs: GameState, a: Dictionary) -> int:
	var card: NRCard = a.get("card")
	if card == null:
		return 50
	if card.has_subtype("Icebreaker"):
		if not _has_breaker_type(gs, card):
			return 1600
		return 200
	if card.card_type() == "hardware" and card.has_subtype("Console"):
		return 1400
	if card.card_type() == "resource":
		return 1000 if gs.runner.credits < 8 else 600
	if card.card_type() == "hardware":
		return 700
	return 100


static func _has_breaker_type(gs: GameState, card: NRCard) -> bool:
	var br: Dictionary = card.def().get("breaker", {})
	var kind := str(br.get("breaks", ""))
	for p in gs.runner.programs:
		var k2 := str(p.def().get("breaker", {}).get("breaks", ""))
		if k2 == kind and p.title() == card.title():
			return true
		if k2 == kind:
			return true
	return false


static func _run(gs: GameState, a: Dictionary) -> int:
	var srv: NRServer = a.get("server")
	if srv == null:
		return 0
	var ice_n := srv.ice_count()
	var rezzed := 0
	for ice in srv.ice:
		if ice.rezzed:
			rezzed += 1
	var score := 120
	var grip: int = gs.runner.grip.size()
	if grip < 2:
		return -800
	if srv.server_name.begins_with("Remote") and srv.root.size() > 0:
		var known_agenda := false
		var known_ambush := false
		for c in srv.root:
			if c.known_to_runner and c.card_type() == "agenda":
				known_agenda = true
			if c.known_to_runner and c.has_subtype("Ambush"):
				known_ambush = true
		if known_ambush:
			return -500
		if known_agenda:
			score += 900
		else:
			score += 280
		if ice_n == 0:
			score += 200
		if grip <= 3:
			score -= 700
	if srv.server_name == "R&D":
		score += 250
	if srv.server_name == "HQ":
		score += 220
	if srv.server_name == "Archives":
		score += 40
	score -= ice_n * 120
	score -= rezzed * 80
	if gs.runner.credits < 3 and ice_n > 0:
		score -= 400
	if not _has_any_breaker(gs) and ice_n > 0:
		score -= 500
	return score


static func _has_any_breaker(gs: GameState) -> bool:
	for p in gs.runner.programs:
		if p.has_subtype("Icebreaker"):
			return true
	return false


static func _pending(gs: GameState, a: Dictionary) -> int:
	var label := str(a.get("label", "")).to_lower()
	if label.find("steal") >= 0:
		return 10000
	if label.find("jack out") >= 0:
		return 30
	if label.find("continue") >= 0:
		return 200
	if label.find("take 1 tag") >= 0:
		return 150
	if label.find("end the run") >= 0:
		return 40
	if label.find("pay") >= 0:
		return 180 if gs.runner.credits > 6 else 60
	if label.find("spend [click]") >= 0:
		return 220
	if label.find("link") >= 0:
		var spent := int(a.get("spent", 0))
		if spent == 0:
			return 80
		if spent <= 2:
			return 90 - spent
		return 5
	return 40
