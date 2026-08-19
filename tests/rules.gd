extends SceneTree


func _initialize() -> void:
	CardDB.load_data()
	if CardDB.by_code.size() != 77:
		push_error("expected 77 System Gateway cards, got %d" % CardDB.by_code.size())
		quit(1)
		return
	var e := NREngine.new(CardDB.by_code)
	e.new_game(7, CardDB.decks)
	if e.corp.credits != 5 or e.runner.credits != 5:
		push_error("starting credits")
		quit(1)
		return
	if e.corp.clicks != 3:
		push_error("corp should have 3 clicks, got %d" % e.corp.clicks)
		quit(1)
		return
	if e.corp.hand.size() != 6:
		push_error("corp hand after mandatory draw should be 6, got %d" % e.corp.hand.size())
		quit(1)
		return
	if e.runner.hand.size() != 5:
		push_error("runner starting hand")
		quit(1)
		return
	if e.agenda_goal != 6:
		push_error("beginner agenda goal")
		quit(1)
		return
	if not e.apply({"op": "credit"}):
		push_error("click for credit failed")
		quit(1)
		return
	if e.corp.credits != 6 or e.corp.clicks != 2:
		push_error("credit action")
		quit(1)
		return
	_test_hedge_fund()
	_test_ice_etr()
	_test_steal_unprotected()
	_test_score_agenda()
	_test_decked()
	_test_flatline()
	_test_ai_plays()
	print("RULES_OK")
	quit(0)


func _engine() -> NREngine:
	var e := NREngine.new(CardDB.by_code)
	e.new_game(99, CardDB.decks)
	return e


func _put_in_hand(e: NREngine, who: String, code: String) -> Dictionary:
	var card: Dictionary = e._make_card(code)
	card.zone = "hand"
	e.side_of(who).hand.append(card)
	return card


func _test_hedge_fund() -> void:
	var e := _engine()
	e.corp.hand.clear()
	e.corp.credits = 5
	e.corp.clicks = 1
	var hf := _put_in_hand(e, "corp", "30075")
	if not e.apply({"op": "play", "uid": hf.uid}):
		push_error("hedge fund play")
		quit(1)
		return
	if e.corp.credits != 9:
		push_error("hedge fund should end at 9 credits, got %d" % e.corp.credits)
		quit(1)
		return


func _test_ice_etr() -> void:
	var e := _engine()
	e.turn = "runner"
	e.phase = "action"
	e.runner.clicks = 1
	e.runner.credits = 5
	e.corp.credits = 10
	var ice: Dictionary = e._make_card("30072")
	ice.zone = "ice"
	ice.server = "hq"
	ice.rezzed = false
	e.corp.hq_ices.append(ice)
	if not e.apply({"op": "run", "server": "hq"}):
		push_error("run hq")
		quit(1)
		return
	if e.phase != "approach_ice":
		push_error("should approach ice")
		quit(1)
		return
	if not e.apply({"op": "rez", "uid": ice.uid}):
		push_error("rez palisade")
		quit(1)
		return
	if e.phase != "encounter":
		push_error("should encounter after rez")
		quit(1)
		return
	if not e.apply({"op": "continue"}):
		push_error("let palisade fire")
		quit(1)
		return
	if e.phase != "action" or e.winner != "":
		push_error("palisade should end the run, not the game")
		quit(1)
		return


func _test_steal_unprotected() -> void:
	var e := _engine()
	e.turn = "runner"
	e.phase = "action"
	e.runner.clicks = 1
	var agenda: Dictionary = e._make_card("30067")
	agenda.zone = "root"
	var remote := e._new_remote()
	remote.root.append(agenda)
	agenda.server = "remote:%d" % remote.id
	if not e.apply({"op": "run", "server": "remote:%d" % remote.id}):
		push_error("run remote")
		quit(1)
		return
	if e.phase != "approach_server":
		push_error("unprotected remote should approach server, got %s" % e.phase)
		quit(1)
		return
	if not e.apply({"op": "continue"}):
		push_error("approach server continue")
		quit(1)
		return
	if e.phase != "access":
		push_error("should access")
		quit(1)
		return
	if not e.apply({"op": "steal", "uid": agenda.uid}):
		push_error("steal")
		quit(1)
		return
	if e.agenda_points("runner") != 2:
		push_error("stolen offworld is 2 AP, got %d" % e.agenda_points("runner"))
		quit(1)
		return


func _test_score_agenda() -> void:
	var e := _engine()
	e.turn = "corp"
	e.phase = "action"
	e.corp.clicks = 0
	var agenda: Dictionary = e._make_card("30070")
	agenda.zone = "root"
	agenda.advancement = 3
	var remote := e._new_remote()
	remote.root.append(agenda)
	agenda.server = "remote:%d" % remote.id
	if not e.apply({"op": "score", "uid": agenda.uid}):
		push_error("score superconducting hub")
		quit(1)
		return
	if e.agenda_points("corp") != 1:
		push_error("scored 1 AP")
		quit(1)
		return
	if e.max_hand("corp") != 7:
		push_error("hub should give +2 hand size, got %d" % e.max_hand("corp"))
		quit(1)
		return


func _test_decked() -> void:
	var e := _engine()
	e.turn = "corp"
	e.phase = "action"
	e.corp.clicks = 1
	e.corp.deck.clear()
	if not e.apply({"op": "draw"}):
		push_error("draw empty rd")
		quit(1)
		return
	if e.winner != "runner":
		push_error("empty R&D should deck the corp")
		quit(1)
		return


func _test_flatline() -> void:
	var e := _engine()
	e.runner.hand.clear()
	e._net_damage(1)
	if e.winner != "corp":
		push_error("empty grip net damage should flatline")
		quit(1)
		return


func _test_ai_plays() -> void:
	var e := _engine()
	for _i in 40:
		if e.winner != "":
			break
		var act: Dictionary = NRAi.pick(e, e.turn if e.phase == "action" else (
			"corp" if e.phase == "approach_ice" and not e.run.get("rez_done", false) and not e.run.get("ice", {}).get("rezzed", false) else "runner"
		))
		if act.is_empty():
			push_error("AI found no action in phase %s" % e.phase)
			quit(1)
			return
		if not e.apply(act):
			push_error("AI action failed %s in %s" % [act, e.phase])
			quit(1)
			return
	if e.log_lines.is_empty():
		push_error("AI produced no log")
		quit(1)
		return
