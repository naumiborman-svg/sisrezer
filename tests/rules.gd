extends SceneTree

var failed := false


func _fail(msg: String) -> void:
	push_error(msg)
	failed = true


func _initialize() -> void:
	var defs := CardLibrary.cards()
	var decks := CardLibrary.decks()
	if defs.size() != 77:
		_fail("expected 77 System Gateway cards, got %d" % defs.size())
	var e := NREngine.new(defs)
	e.new_game(7, decks)
	if e.corp.credits != 5 or e.runner.credits != 5:
		_fail("starting credits")
	if e.corp.clicks != 3:
		_fail("corp should have 3 clicks, got %d" % e.corp.clicks)
	if e.corp.hand.size() != 6:
		_fail("corp hand after mandatory draw should be 6, got %d" % e.corp.hand.size())
	if e.runner.hand.size() != 5:
		_fail("runner starting hand")
	if e.agenda_goal != 6:
		_fail("beginner agenda goal")
	if not e.apply({"op": "credit"}):
		_fail("click for credit failed")
	if e.corp.credits != 6 or e.corp.clicks != 2:
		_fail("credit action")
	_test_hedge_fund()
	_test_ice_etr()
	_test_steal_unprotected()
	_test_score_agenda()
	_test_decked()
	_test_flatline()
	_test_ai_plays()
	if failed:
		quit(1)
		return
	print("RULES_OK")
	quit(0)


func _engine() -> NREngine:
	var e := NREngine.new(CardLibrary.cards())
	e.new_game(99, CardLibrary.decks())
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
		_fail("hedge fund play")
		return
	if e.corp.credits != 9:
		_fail("hedge fund should end at 9 credits, got %d" % e.corp.credits)
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
		_fail("run hq")
		return
	if e.phase != "approach_ice":
		_fail("should approach ice")
		return
	if not e.apply({"op": "rez", "uid": ice.uid}):
		_fail("rez palisade")
		return
	if e.phase != "encounter":
		_fail("should encounter after rez")
		return
	if not e.apply({"op": "continue"}):
		_fail("let palisade fire")
		return
	if e.phase != "action" or e.winner != "":
		_fail("palisade should end the run, not the game")
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
		_fail("run remote")
		return
	if e.phase != "approach_server":
		_fail("unprotected remote should approach server, got %s" % e.phase)
		return
	if not e.apply({"op": "continue"}):
		_fail("approach server continue")
		return
	if e.phase != "access":
		_fail("should access")
		return
	if not e.apply({"op": "steal", "uid": agenda.uid}):
		_fail("steal")
		return
	if e.agenda_points("runner") != 2:
		_fail("stolen offworld is 2 AP, got %d" % e.agenda_points("runner"))
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
		_fail("score superconducting hub")
		return
	if e.agenda_points("corp") != 1:
		_fail("scored 1 AP")
		return
	if e.max_hand("corp") != 7:
		_fail("hub should give +2 hand size, got %d" % e.max_hand("corp"))
		return


func _test_decked() -> void:
	var e := _engine()
	e.turn = "corp"
	e.phase = "action"
	e.corp.clicks = 1
	e.corp.deck.clear()
	if not e.apply({"op": "draw"}):
		_fail("draw empty rd")
		return
	if e.winner != "runner":
		_fail("empty R&D should deck the corp")
		return


func _test_flatline() -> void:
	var e := _engine()
	e.runner.hand.clear()
	e._net_damage(1)
	if e.winner != "corp":
		_fail("empty grip net damage should flatline")
		return


func _test_ai_plays() -> void:
	var e := _engine()
	for _i in 120:
		if e.winner != "":
			break
		var act: Dictionary = NRAi.pick(e, e.actor(), "greedy")
		if act.is_empty():
			_fail("AI found no action in phase %s" % e.phase)
			return
		if not e.apply(act):
			_fail("AI action failed %s in %s" % [act, e.phase])
			return
	if e.log_lines.is_empty():
		_fail("AI produced no log")
		return
