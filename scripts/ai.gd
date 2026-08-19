class_name NRAi
extends RefCounted

static var style := "strong"


static func pick(engine: NREngine, who: String, kind: String = "") -> Dictionary:
	var use := kind if kind != "" else style
	if use == "greedy":
		return pick_greedy(engine, who)
	return pick_strong(engine, who)


static func pick_greedy(engine: NREngine, who: String) -> Dictionary:
	var options: Array = engine.legal()
	if options.is_empty():
		return {}
	var best: Dictionary = options[0]
	var best_s := -1000000
	for act: Variant in options:
		if act is Dictionary:
			var s := _heuristic(engine, who, act)
			if s > best_s:
				best_s = s
				best = act
	return best


static func pick_strong(engine: NREngine, who: String) -> Dictionary:
	var options: Array = engine.legal()
	if options.is_empty():
		return {}
	if options.size() == 1:
		return options[0]
	var ranked: Array = []
	for act: Variant in options:
		if act is Dictionary:
			var h := _heuristic(engine, who, act)
			if h <= -300:
				continue
			ranked.append({"act": act, "h": h})
	if ranked.is_empty():
		return pick_greedy(engine, who)
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.h) > int(b.h))
	var depth := _depth_for(engine, ranked[0].act)
	var cap: int = mini(ranked.size(), 8 if engine.phase == "action" else 6)
	var best: Dictionary = ranked[0].act
	var best_s := -1.0e12
	for i in cap:
		var act: Dictionary = ranked[i].act
		var sim := engine.clone()
		if not sim.apply(act):
			continue
		var s := _search(sim, who, depth - 1) + float(ranked[i].h) * 0.01
		if s > best_s:
			best_s = s
			best = act
	return best


static func _depth_for(engine: NREngine, act: Dictionary) -> int:
	var op := str(act.get("op", ""))
	if engine.phase in ["encounter", "approach_ice", "access"]:
		return 4
	if op in ["run", "choose_server"] or (op == "play" and _is_run_event(engine, act)):
		return 5
	if op in ["score", "steal", "advance", "install"]:
		return 3
	return 2


static func _is_run_event(engine: NREngine, act: Dictionary) -> bool:
	if not act.has("uid"):
		return false
	return str(engine.find_uid(int(act.uid)).get("code", "")) in ["30028", "30029", "30012"]


static func _search(sim: NREngine, me: String, depth: int) -> float:
	if sim.winner != "":
		if sim.winner == me:
			return 10000.0 - float(sim.agenda_goal)
		return -10000.0
	if depth <= 0:
		return _evaluate(sim, me)
	var options: Array = sim.legal()
	if options.is_empty():
		return _evaluate(sim, me)
	var actor := sim.actor()
	if actor == me:
		var best := -1.0e12
		var ranked: Array = _rank(sim, actor, options, 6)
		for item: Variant in ranked:
			var child := sim.clone()
			if child.apply(item.act):
				best = maxf(best, _search(child, me, depth - 1))
		return best if best > -1.0e11 else _evaluate(sim, me)
	var reply: Dictionary = pick_greedy(sim, actor)
	if reply.is_empty():
		return _evaluate(sim, me)
	var opp := sim.clone()
	if not opp.apply(reply):
		return _evaluate(sim, me)
	return _search(opp, me, depth - 1)


static func _rank(engine: NREngine, who: String, options: Array, cap: int) -> Array:
	var ranked: Array = []
	for act: Variant in options:
		if act is Dictionary:
			var h := _heuristic(engine, who, act)
			if h <= -300:
				continue
			ranked.append({"act": act, "h": h})
	if ranked.is_empty():
		for act: Variant in options:
			if act is Dictionary:
				ranked.append({"act": act, "h": _heuristic(engine, who, act)})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.h) > int(b.h))
	if ranked.size() > cap:
		ranked = ranked.slice(0, cap)
	return ranked


static func _evaluate(e: NREngine, me: String) -> float:
	var corp_ap := e.agenda_points(NREngine.CORP)
	var runner_ap := e.agenda_points(NREngine.RUNNER)
	var s := 180.0 * float(corp_ap - runner_ap)
	s += 1.4 * float(e.corp.credits) - 1.1 * float(e.runner.credits)
	s += 2.0 * float(e.corp.hand.size()) - 1.2 * float(e.runner.hand.size())
	s += 8.0 * float(e.runner.tags)
	s += 14.0 * float(e.server_ices("hq").size())
	s += 12.0 * float(e.server_ices("rd").size())
	s += 6.0 * float(e.server_ices("archives").size())
	s += _ice_quality(e, "hq") + _ice_quality(e, "rd")
	var naked := 0
	var scored_remote := 0
	for remote: Variant in e.remotes:
		var ices: Array = remote.ices
		var has_agenda := false
		var adv := 0
		for card: Variant in remote.root:
			if str(card.type) == "Agenda":
				has_agenda = true
				adv = maxi(adv, int(card.advancement))
				if int(card.advancement) >= int(card.get("advancementcost", 99)):
					scored_remote += 1
		if has_agenda:
			s += 22.0 * float(ices.size()) + 8.0 * float(adv)
			if ices.is_empty():
				naked += 1
				s -= 90.0
			else:
				s += _ice_quality(e, "remote:%d" % remote.id)
		elif not ices.is_empty():
			s += 8.0 * float(ices.size())
	s += 70.0 * float(scored_remote)
	s -= 14.0 * float(_breaker_count(e))
	s -= 4.0 * float(e.mu_used())
	if e.corp.deck.size() <= 3:
		s -= 40.0
	if e.runner.hand.size() <= 1:
		s += 18.0
	if me == NREngine.CORP and corp_ap >= e.agenda_goal - 2:
		s += 35.0
	if me == NREngine.RUNNER and runner_ap >= e.agenda_goal - 2:
		s -= 35.0
	if e.phase in ["approach_server", "access"]:
		if _run_hits_agenda(e):
			s -= 280.0
	if e.phase in ["approach_ice", "encounter"]:
		var ice_v: Variant = e.run.get("ice", {})
		if ice_v is Dictionary and bool((ice_v as Dictionary).get("rezzed", false)):
			var ice := ice_v as Dictionary
			var bc := _break_cost(e, ice)
			var pool := int(e.runner.credits) + int(e.run.get("overclock", 0))
			if bc >= 90 or bc > pool:
				s += 260.0
	if me == NREngine.RUNNER:
		s = -s
	return s


static func _ice_quality(e: NREngine, server: String) -> float:
	var n := 0.0
	for card: Variant in e.server_ices(server):
		n += 3.0 + float(e.ice_strength(card))
		if card.rezzed:
			n += 4.0
		if _break_cost(e, card) >= 8:
			n += 10.0
	return n


static func _breaker_count(e: NREngine) -> int:
	var n := 0
	for card: Variant in e.runner.programs:
		if "Icebreaker" in card.get("subtypes", []):
			n += 1
	return n


static func _break_cost(e: NREngine, ice: Dictionary) -> int:
	var need := e.ice_strength(ice)
	var best := 99
	for br: Variant in e.runner.programs:
		if not e._is_breaker(br) or not e._breaker_matches(br, ice):
			continue
		var have := e.breaker_strength(br)
		var pump_amt := 1
		var pump_cost := 2
		match str(br.code):
			"30032", "30026":
				pump_cost = 1
			"30015":
				pump_amt = 3
		if str(br.code) == "30026":
			pump_amt = maxi(1, _breaker_count(e))
		var pumps := 0
		if have < need:
			pumps = int(ceili(float(need - have) / float(pump_amt)))
		var subs := 1
		match str(ice.get("code", "")):
			"30074", "30073", "30047":
				subs = 2
			"30039":
				subs = 3
		var per := 1
		var chunk := 2 if str(br.code) == "30006" else 1
		var breaks: int = int(ceili(float(subs) / float(chunk)))
		best = mini(best, pumps * pump_cost + breaks * per)
	return best


static func _heuristic(engine: NREngine, who: String, act: Dictionary) -> int:
	var op := str(act.get("op", ""))
	if who == NREngine.CORP:
		return _corp_h(engine, act, op)
	return _runner_h(engine, act, op)


static func _corp_h(engine: NREngine, act: Dictionary, op: String) -> int:
	match op:
		"score":
			return 5000 + engine.agenda_points(NREngine.CORP) * 10
		"advance_free":
			return 900
		"rez":
			return _corp_rez_h(engine, act)
		"play":
			return _corp_play_h(engine, act)
		"advance":
			return _corp_advance_h(engine, act)
		"install":
			return _corp_install_h(engine, act)
		"ability":
			return 160
		"credit":
			return 30 if engine.corp.credits < 6 else 12
		"draw":
			if engine.corp.deck.is_empty():
				return -8000
			return 50 if engine.corp.hand.size() < 4 else 8
		"end_turn":
			return _corp_end_h(engine)
		"no_rez":
			return _corp_no_rez_h(engine)
		"continue":
			return 40
		"discard":
			return -int(engine.find_uid(int(act.uid)).get("cost", 0))
	return 5


static func _corp_rez_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	if str(card.get("type", "")) != "ICE":
		if str(card.get("code", "")) in ["30037", "30071"]:
			return 200
		return 110
	var cost := engine._rez_cost(card)
	var bc := _break_cost(engine, card)
	if bc >= 8:
		return 700 - cost
	if bc >= 5:
		return 420 - cost
	return 80 - cost


static func _corp_no_rez_h(engine: NREngine) -> int:
	var ice: Dictionary = engine.run.get("ice", {})
	if ice.is_empty():
		return 40
	if engine.corp.credits < engine._rez_cost(ice):
		return 60
	if _break_cost(engine, ice) <= 2:
		return 90
	return 10


static func _corp_play_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	match str(card.get("code", "")):
		"30075":
			return 380 if engine.corp.credits <= 9 else 220
		"30064":
			return 360 if engine.corp.credits >= 12 else 40
		"30040":
			return 240
	return 70


static func _corp_advance_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	var need := int(card.get("advancementcost", 99))
	var have := int(card.get("advancement", 0))
	var ices: Array = engine.server_ices(str(card.get("server", "")))
	var s := 180 + have * 25
	if have + 1 >= need:
		s += 400
	if ices.is_empty() and engine.runner.clicks >= 1 and engine.turn == NREngine.CORP:
		s -= 120
	if str(card.get("code", "")) == "30045":
		s += 20 * have
	return s


static func _corp_install_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	var dest := str(act.get("dest", ""))
	var t := str(card.get("type", ""))
	if t == "Agenda":
		if dest == "new_remote":
			var can_ice := false
			for held: Variant in engine.corp.hand:
				if str(held.type) == "ICE" and int(held.uid) != int(card.uid):
					can_ice = true
			if engine.runner.clicks >= 2 and not can_ice:
				return 40
			return 210
		return 160
	if t == "ICE":
		if dest in ["hq", "rd"] and engine.server_ices(dest).is_empty():
			return 260
		if dest.begins_with("remote:"):
			var remote := engine.remote_by_id(int(dest.get_slice(":", 1)))
			for root: Variant in remote.root:
				if str(root.type) == "Agenda":
					return 300
			return 140
		if dest == "new_remote":
			return 70
		return 100
	if t == "Asset":
		return 150 if dest == "new_remote" else 120
	return 60


static func _corp_end_h(engine: NREngine) -> int:
	for card: Dictionary in engine._installed_corp_cards():
		if str(card.type) == "Agenda" and int(card.advancement) >= int(card.get("advancementcost", 99)):
			return -400
	return 8


static func _runner_h(engine: NREngine, act: Dictionary, op: String) -> int:
	match op:
		"steal":
			return 5000 + int(engine.find_uid(int(act.uid)).get("agendapoints", 0)) * 80
		"trash_access":
			return _trash_h(engine, act)
		"pass_access":
			return 70
		"break":
			return 800
		"pump":
			return _pump_h(engine, act)
		"bioroid_break":
			return 620 if engine.runner.clicks > 1 else 200
		"jack_out":
			return _jack_h(engine)
		"play":
			return _runner_play_h(engine, act)
		"install":
			return _runner_install_h(engine, act)
		"run":
			return _run_h(engine, str(act.server))
		"choose_server":
			return _run_h(engine, str(act.server)) + 20
		"ability":
			return _runner_ability_h(engine, act)
		"credit":
			return 55 if engine.runner.credits < 5 else 18
		"draw":
			return 28 if engine.runner.hand.size() < 5 else 10
		"manegarm_credits":
			return 220
		"manegarm_clicks":
			return 80 if engine.runner.clicks >= 3 else 20
		"continue":
			return _continue_h(engine)
		"end_turn":
			return 6
		"discard":
			return -_keep_value(engine.find_uid(int(act.uid)))
	return 5


static func _trash_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	if str(card.get("code", "")) == "30045":
		return 360
	if str(card.get("type", "")) == "Upgrade":
		return 240
	return 160


static func _pump_h(engine: NREngine, act: Dictionary) -> int:
	var br := engine.find_uid(int(act.uid))
	var ice: Dictionary = engine.run.get("ice", {})
	if ice.is_empty():
		return 200
	if engine.breaker_strength(br) >= engine.ice_strength(ice):
		return 40
	return 700


static func _jack_h(engine: NREngine) -> int:
	if engine.phase != "encounter":
		return 8
	var ice: Dictionary = engine.run.get("ice", {})
	if ice.is_empty():
		return 10
	if _break_cost(engine, ice) > engine.runner.credits + int(engine.run.get("overclock", 0)):
		return 550
	if engine.runner.hand.size() <= 2 and str(ice.get("code", "")) in ["30047", "30046", "30073"]:
		return 400
	return 15


static func _continue_h(engine: NREngine) -> int:
	if engine.phase == "encounter":
		var left := 0
		for sub: Variant in engine.run.get("subs", []):
			if not sub.broken:
				left += 1
		if left == 0:
			return 300
		var ice: Dictionary = engine.run.get("ice", {})
		if _break_cost(engine, ice) <= engine.runner.credits and left > 0:
			return 20
		return 30
	if engine.phase == "approach_server":
		return 200
	return 80


static func _runner_play_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	if _unprotected_agenda_server(engine) != "" and engine.runner.clicks <= 1:
		return 15
	match str(card.get("code", "")):
		"30030":
			return 420 if engine.runner.credits <= 8 else 200
		"30020":
			return 90 if engine.runner.clicks <= 1 else 40
		"30021":
			return 80 if engine.runner.hand.size() < 4 else 20
		"30028":
			return _run_h(engine, "rd") + 40
		"30012", "30029":
			return _event_run_h(engine)
	return 70


static func _runner_install_h(engine: NREngine, act: Dictionary) -> int:
	var card := engine.find_uid(int(act.uid))
	if "Icebreaker" in card.get("subtypes", []):
		if _has_breaker_type(engine, card):
			return 80
		return 340
	if str(card.get("code", "")) == "30027":
		return 200
	if str(card.get("code", "")) == "30033":
		return 170
	if str(card.get("code", "")) == "30014":
		return 160
	return 120


static func _has_breaker_type(engine: NREngine, card: Dictionary) -> bool:
	for p: Variant in engine.runner.programs:
		if str(p.code) == str(card.code):
			return true
		var a: Array = p.get("subtypes", [])
		var b: Array = card.get("subtypes", [])
		for tag: Variant in ["Fracter", "Decoder", "Killer"]:
			if tag in a and tag in b:
				return true
	return false


static func _unprotected_agenda_server(engine: NREngine) -> String:
	for remote: Variant in engine.remotes:
		if not remote.ices.is_empty():
			continue
		for card: Variant in remote.root:
			if str(card.type) == "Agenda":
				return "remote:%d" % remote.id
	return ""


static func _run_hits_agenda(e: NREngine) -> bool:
	var cur: Variant = e.run.get("current", {})
	if cur is Dictionary and str((cur as Dictionary).get("type", "")) == "Agenda":
		return true
	var server := str(e.run.get("server", ""))
	if not server.begins_with("remote:"):
		return false
	var remote := e.remote_by_id(int(server.get_slice(":", 1)))
	for card: Variant in remote.root:
		if str(card.type) == "Agenda":
			return true
	return false


static func _event_run_h(engine: NREngine) -> int:
	if _unprotected_agenda_server(engine) != "":
		return 40
	return _best_run(engine) + 40


static func _run_h(engine: NREngine, server: String) -> int:
	var ices: Array = engine.server_ices(server)
	if ices.is_empty():
		var bonus := 0
		if server.begins_with("remote:"):
			var remote := engine.remote_by_id(int(server.get_slice(":", 1)))
			for card: Variant in remote.root:
				if str(card.type) == "Agenda":
					bonus += 820 + 40 * int(card.advancement) + 80 * int(card.get("agendapoints", 0))
				else:
					bonus += 80
		if server == "rd":
			bonus += 90
		if server == "hq":
			bonus += 70
		return 280 + bonus
	var cost := 0
	var blocked := false
	for ice: Variant in ices:
		if ice.rezzed:
			var bc := _break_cost(engine, ice)
			cost += bc
			if bc >= 90:
				blocked = true
		else:
			if engine.corp.credits >= int(ice.get("cost", 0)):
				cost += mini(6, _break_cost(engine, ice))
	if blocked or cost > engine.runner.credits + 2:
		return -400
	var dest_bonus := 50
	if server == "rd":
		dest_bonus = 80
	if server.begins_with("remote:"):
		dest_bonus = 110
	return 140 + dest_bonus - cost * 8


static func _best_run(engine: NREngine) -> int:
	var best := _run_h(engine, "rd")
	best = maxi(best, _run_h(engine, "hq"))
	best = maxi(best, _run_h(engine, "archives"))
	for remote: Variant in engine.remotes:
		best = maxi(best, _run_h(engine, "remote:%d" % remote.id))
	return best


static func _runner_ability_h(engine: NREngine, act: Dictionary) -> int:
	if str(act.get("name", "")) == "run":
		return _run_h(engine, str(act.get("server", ""))) + 10
	if str(act.get("name", "")) == "take":
		return 190
	if str(act.get("name", "")) == "load":
		return 150
	return 100


static func _keep_value(card: Dictionary) -> int:
	if "Icebreaker" in card.get("subtypes", []):
		return 12
	if str(card.get("code", "")) in ["30030", "30028"]:
		return 10
	return int(card.get("cost", 1))
