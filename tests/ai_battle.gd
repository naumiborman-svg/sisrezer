extends SceneTree

var failed := false


func _fail(msg: String) -> void:
	push_error(msg)
	failed = true


func _initialize() -> void:
	_test_clone_isolation()
	_test_scores_when_able()
	_test_steals_unprotected()
	_test_rez_to_protect()
	_test_skips_suicide_run()
	_test_self_play()
	if failed:
		quit(1)
		return
	print("AI_BATTLE_OK")
	quit(0)


func _engine(seed_n: int = 21) -> NREngine:
	var e := NREngine.new(CardLibrary.cards())
	e.new_game(seed_n, CardLibrary.decks())
	return e


func _test_clone_isolation() -> void:
	var e := _engine()
	var before := int(e.corp.credits)
	var c := e.clone()
	if not c.apply({"op": "credit"}):
		_fail("clone could not click credit")
		return
	if int(e.corp.credits) != before:
		_fail("clone mutated the live game")
	if int(c.corp.credits) != before + 1:
		_fail("clone did not apply independently")


func _test_scores_when_able() -> void:
	var e := _engine()
	e.turn = "corp"
	e.phase = "action"
	e.corp.clicks = 1
	var agenda: Dictionary = e._make_card("30070")
	agenda.zone = "root"
	agenda.advancement = 3
	var remote := e._new_remote()
	remote.root.append(agenda)
	agenda.server = "remote:%d" % remote.id
	var act := NRAi.pick(e, "corp", "strong")
	if str(act.get("op", "")) != "score":
		_fail("strong corp should score a finished agenda, got %s" % act)
		return
	e.apply(act)
	if e.agenda_points("corp") != 1:
		_fail("score did not land")


func _test_steals_unprotected() -> void:
	var e := _engine()
	e.turn = "runner"
	e.phase = "action"
	e.runner.clicks = 1
	e.runner.credits = 5
	var agenda: Dictionary = e._make_card("30069")
	agenda.zone = "root"
	var remote := e._new_remote()
	remote.root.append(agenda)
	agenda.server = "remote:%d" % remote.id
	var act := NRAi.pick(e, "runner", "strong")
	if str(act.get("op", "")) != "run" or str(act.get("server", "")) != "remote:%d" % remote.id:
		_fail("strong runner should run the naked agenda remote, got %s" % act)
		return
	e.apply(act)
	if e.phase == "approach_server":
		e.apply({"op": "continue"})
	if e.phase == "access":
		var steal := NRAi.pick(e, "runner", "strong")
		if str(steal.get("op", "")) != "steal":
			_fail("strong runner should steal, got %s" % steal)


func _test_rez_to_protect() -> void:
	var e := _engine()
	e.turn = "runner"
	e.phase = "action"
	e.runner.clicks = 1
	e.corp.credits = 8
	var ice: Dictionary = e._make_card("30072")
	ice.zone = "ice"
	ice.server = "hq"
	ice.rezzed = false
	e.corp.hq_ices.append(ice)
	e.apply({"op": "run", "server": "hq"})
	if e.phase != "approach_ice":
		_fail("expected approach ice")
		return
	var act := NRAi.pick(e, "corp", "strong")
	if str(act.get("op", "")) != "rez":
		_fail("strong corp should rez Palisade, got %s" % act)


func _test_skips_suicide_run() -> void:
	var e := _engine()
	e.turn = "runner"
	e.phase = "action"
	e.runner.clicks = 2
	e.runner.credits = 1
	e.runner.programs.clear()
	var ice: Dictionary = e._make_card("30039")
	ice.zone = "ice"
	ice.server = "rd"
	ice.rezzed = true
	e.corp.rd_ices.append(ice)
	var act := NRAi.pick(e, "runner", "strong")
	if str(act.get("op", "")) == "run" and str(act.get("server", "")) == "rd":
		_fail("strong runner should not dive into rezzed Brân with no breakers")


func _test_self_play() -> void:
	var e := _engine(33)
	NRAi.style = "strong"
	for _i in 220:
		if e.winner != "":
			break
		var act: Dictionary = NRAi.pick(e, e.actor(), "strong")
		if act.is_empty():
			_fail("strong AI found no move in %s" % e.phase)
			return
		if not e.apply(act):
			_fail("strong AI illegal move %s in %s" % [act, e.phase])
			return
	if e.log_lines.is_empty():
		_fail("self-play produced no log")
	print("self-play winner=%s reason=%s ap=%d/%d moves_logged=%d" % [
		e.winner, e.win_reason, e.agenda_points("corp"), e.agenda_points("runner"), e.log_lines.size()
	])
