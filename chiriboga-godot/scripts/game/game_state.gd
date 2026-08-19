extends RefCounted
class_name GameState
## Core Netrunner Solo Mode rules engine. UI and AI both consume `legal_actions()` / `act()`.

const _NRCard := preload("res://scripts/game/nr_card.gd")
const _NRServer := preload("res://scripts/game/nr_server.gd")
const _NRPlayer := preload("res://scripts/game/nr_player.gd")
const _CorpAI := preload("res://scripts/ai/corp_ai.gd")
const _RunnerAI := preload("res://scripts/ai/runner_ai.gd")

signal log_line(text: String)
signal changed
signal game_over(winner: String, reason: String)

enum Phase {
	RUNNER_ACTION,
	RUNNER_DISCARD,
	CORP_ACTION,
	CORP_DISCARD,
	RUN_APPROACH_ICE,
	RUN_ENCOUNTER,
	RUN_SUBS,
	RUN_MOVEMENT,
	RUN_APPROACH_SERVER,
	RUN_ACCESS,
	GAME_OVER,
}

var rng := RandomNumberGenerator.new()
var runner: NRPlayer
var corp: NRPlayer
var hq: NRServer
var rnd: NRServer
var archives: NRServer
var remotes: Array = [] ## NRServer
var _next_remote_id := 1
var _next_iid := 1

var phase: int = Phase.RUNNER_ACTION
var turn_number: int = 1
var whose_turn: String = "runner"
var agenda_points_to_win: int = 7
var winner: String = ""
var win_reason: String = ""
var log_lines: PackedStringArray = PackedStringArray()

var runner_is_ai: bool = false
var corp_is_ai: bool = true
var human_side: String = "runner"

## Run
var run_server: NRServer = null
var run_ice_index: int = -1
var run_event: NRCard = null
var run_hosted_credits: int = 0
var ice_rez_surcharge: int = 0
var extra_access: int = 0
var run_active: bool = false
var run_successful: bool = false
var mayfly_used: bool = false
var red_team_card: NRCard = null
var access_queue: Array = []
var accessing: NRCard = null
var _subs_queue: Array = []
var _hq_breached_this_turn: bool = false
var runner_ran_last_turn: bool = false
var _ran_this_turn: bool = false
var _trace_base: int = 0
var _trace_corp_spent: int = 0
var _trace_success_ops: Array = []

var _pending_kind: String = ""
var _pending_title: String = ""
var _pending_choices: Array = []
var _pending_data: Dictionary = {}

var _max_ai_steps: int = 8 ## pending auto-resolves per tick


func is_over() -> bool:
	return phase == Phase.GAME_OVER


func start_new_game(opts: Dictionary = {}) -> void:
	rng.seed = int(opts.get("seed", randi()))
	runner_is_ai = bool(opts.get("runner_ai", false))
	corp_is_ai = bool(opts.get("corp_ai", true))
	human_side = str(opts.get("human_side", "runner"))
	agenda_points_to_win = int(opts.get("ap", 7))
	winner = ""
	win_reason = ""
	log_lines = PackedStringArray()
	_next_iid = 1
	_next_remote_id = 1
	turn_number = 1
	whose_turn = "runner"
	_clear_run()
	_pending_kind = ""
	runner = _NRPlayer.new()
	runner.side = "runner"
	corp = _NRPlayer.new()
	corp.side = "corp"
	hq = _make_server("HQ", true, 0)
	rnd = _make_server("R&D", true, -1)
	archives = _make_server("Archives", true, -2)
	remotes = []
	remotes.append(_make_server("Remote 1", false, _next_remote_id)); _next_remote_id += 1
	remotes.append(_make_server("Remote 2", false, _next_remote_id)); _next_remote_id += 1
	_build_decks()
	runner.identity.location = "identity"
	corp.identity.location = "identity"
	runner.credits = 5
	corp.credits = 5
	_shuffle(runner.stack)
	_shuffle(rnd.cards)
	for _i in 5:
		_draw_runner(1, false)
		_draw_corp(1, false)
	_log("Game begins. First to %d agenda points wins. Flatline also wins for the Corp." % agenda_points_to_win)
	_log("You are the Runner (%s) vs Corp AI (%s)." % [runner.identity.title(), corp.identity.title()])
	_begin_runner_turn()
	_notify()


func all_servers() -> Array:
	var out: Array = [archives, rnd, hq]
	for r in remotes:
		out.append(r)
	return out


func server_by_id(sid: int) -> NRServer:
	for s in all_servers():
		if s.id == sid:
			return s
	return null


func max_hand(p: NRPlayer) -> int:
	var n: int = p.base_max_hand - p.brain_damage
	if p.side == "corp":
		for c in p.score_area:
			n += int(c.def().get("max_hand_mod", 0))
	return n


func used_mu() -> int:
	var n := 0
	for c in runner.programs:
		n += c.memory_cost()
	return n


func max_mu() -> int:
	var n: int = runner.base_mu
	for c in runner.hardware:
		n += c.memory_provided()
	return n


func ice_strength(ice: NRCard) -> int:
	var n: int = ice.printed_strength()
	n += int(ice.def().get("strength_if_remote", 0)) if _is_remote_ice(ice) else 0
	return n


func breaker_strength(b: NRCard) -> int:
	return b.printed_strength() + b.strength_boost


func rez_cost_now(card: NRCard) -> int:
	var n: int = card.rez_cost()
	if card.card_type() == "ice":
		n += ice_rez_surcharge
	return max(0, n)


func available_credits(side: String) -> int:
	if side == "runner":
		return runner.credits + (run_hosted_credits if run_active else 0)
	return corp.credits


func spend_credits(side: String, n: int, why: String = "") -> bool:
	if n <= 0:
		return true
	if side == "runner":
		var from_hosted := 0
		if run_active and run_hosted_credits > 0:
			from_hosted = mini(n, run_hosted_credits)
			run_hosted_credits -= from_hosted
			n -= from_hosted
			if from_hosted > 0 and run_event != null:
				run_event.hosted_credits = run_hosted_credits
		if runner.credits < n:
			return false
		runner.credits -= n
		if why != "":
			_log("Runner spends %d[c]%s." % [n + from_hosted, " (" + why + ")" if why != "" else ""])
		return true
	if corp.credits < n:
		return false
	corp.credits -= n
	if why != "":
		_log("Corp spends %d[c]%s." % [n, " (" + why + ")" if why != "" else ""])
	return true


func legal_actions() -> Array:
	if is_over():
		return []
	if _pending_kind != "":
		return _pending_choices.duplicate()
	match phase:
		Phase.RUNNER_ACTION:
			return _actions_runner()
		Phase.RUNNER_DISCARD:
			return _actions_discard(runner)
		Phase.CORP_ACTION:
			return _actions_corp()
		Phase.CORP_DISCARD:
			return _actions_discard_corp()
		Phase.RUN_APPROACH_ICE:
			return _actions_approach_ice()
		Phase.RUN_ENCOUNTER:
			return _actions_encounter()
		Phase.RUN_SUBS:
			return [] ## auto-resolved
		Phase.RUN_MOVEMENT:
			return _actions_movement()
		Phase.RUN_APPROACH_SERVER:
			return [] ## auto / pending manegarm
		Phase.RUN_ACCESS:
			return _actions_access()
		_:
			return []


func act(action: Dictionary) -> void:
	if is_over():
		return
	var t := str(action.get("type", ""))
	if t == "pending":
		_resolve_pending(action)
		_after_act()
		return
	match t:
		"credit":
			_basic_credit(action.get("who", whose_turn))
		"draw":
			_basic_draw(action.get("who", whose_turn))
		"play":
			_play_card(action.card, action)
		"install":
			_install_card(action.card, action)
		"run":
			_start_run(action.server, null)
		"ability":
			_use_ability(action.card, int(action.get("ab", 0)), action)
		"remove_tag":
			_remove_tag()
		"end_phase":
			_end_action_phase()
		"discard":
			_do_discard(action.card)
		"score":
			_score(action.card)
		"rez":
			_rez(action.card, false)
		"advance":
			_advance(action.card)
		"purge":
			_purge()
		"trash_resource":
			_corp_trash_resource(action.card)
		"no_rez":
			_log("Corp does not rez %s." % run_server.ice[run_ice_index].title())
			_pass_ice()
		"begin_enc":
			_begin_encounter()
		"rez_approached":
			var ice: NRCard = run_server.ice[run_ice_index]
			if _rez(ice, true):
				_begin_encounter()
			else:
				_pass_ice()
		"boost":
			_boost(action.card)
		"break":
			_break_sub(action.card, int(action.sub))
		"auto_break":
			_auto_break(action.card)
		"bioroid_break":
			_bioroid_break(int(action.sub))
		"resolve_subs":
			_begin_subs()
		"jack_out":
			_jack_out()
		"continue_run":
			_continue_after_ice()
		"access_done":
			_finish_access_card(false)
		"access_trash":
			_trash_accessing()
		"access_steal":
			_steal(accessing)
		_:
			_log("Unknown action %s" % t)
	_after_act()


func ai_tick() -> bool:
	if is_over():
		return false
	var steps := 0
	while not is_over() and steps < 24:
		var acts := legal_actions()
		if acts.is_empty():
			_auto_advance_empty()
			steps += 1
			continue
		var actor := _current_actor()
		var use_ai := (actor == "runner" and runner_is_ai) or (actor == "corp" and corp_is_ai)
		if not use_ai:
			return false
		var pick: Dictionary
		if actor == "corp":
			pick = _CorpAI.pick(self, acts)
		else:
			pick = _RunnerAI.pick(self, acts)
		if pick.is_empty():
			pick = acts[0]
		act(pick)
		steps += 1
	return not is_over()


func _current_actor() -> String:
	if _pending_kind != "":
		return str(_pending_data.get("actor", "runner"))
	match phase:
		Phase.RUNNER_ACTION, Phase.RUNNER_DISCARD:
			return "runner"
		Phase.CORP_ACTION, Phase.CORP_DISCARD:
			return "corp"
		Phase.RUN_APPROACH_ICE:
			return "corp"
		Phase.RUN_ENCOUNTER, Phase.RUN_MOVEMENT, Phase.RUN_ACCESS:
			return "runner"
		_:
			return whose_turn


func _after_act() -> void:
	_check_win()
	if not is_over():
		if phase == Phase.RUN_SUBS:
			_fire_next_sub()
		elif phase == Phase.RUN_APPROACH_SERVER and _pending_kind == "":
			_breach_server()
		elif phase == Phase.RUN_ACCESS and accessing == null and _pending_kind == "":
			_next_access()
	_notify()


func _auto_advance_empty() -> void:
	match phase:
		Phase.RUN_SUBS:
			_fire_next_sub()
		Phase.RUN_APPROACH_SERVER:
			_breach_server()
		Phase.RUN_ACCESS:
			_next_access()
		Phase.RUNNER_ACTION, Phase.CORP_ACTION:
			_end_action_phase()
		Phase.RUNNER_DISCARD:
			if runner.grip.size() <= max_hand(runner):
				_begin_corp_turn()
		Phase.CORP_DISCARD:
			if hq.cards.size() <= max_hand(corp):
				_begin_runner_turn()
		Phase.RUN_APPROACH_ICE:
			if run_server != null and run_ice_index >= 0:
				_log("Corp does not rez ice.")
				_pass_ice()
		_:
			pass
	_notify()


func _notify() -> void:
	changed.emit()


func _log(msg: String) -> void:
	log_lines.append(msg)
	log_line.emit(msg)
	print("[NR] ", msg)


func _make_server(n: String, central: bool, id: int) -> NRServer:
	var s = _NRServer.new()
	s.server_name = n
	s.is_central = central
	s.id = id
	return s


func _make_card(def_id: int) -> NRCard:
	var c = _NRCard.new()
	c.def_id = def_id
	c.instance_id = _next_iid
	_next_iid += 1
	var subs: Array = c.def().get("subroutines", [])
	c.subroutine_broken.clear()
	for _s in subs:
		c.subroutine_broken.append(false)
	return c


func _build_decks() -> void:
	runner.identity = _make_card(Decklists.RUNNER_ID)
	corp.identity = _make_card(Decklists.CORP_ID)
	for id in Decklists.RUNNER_STARTER:
		var c := _make_card(id)
		c.location = "stack"
		runner.stack.append(c)
	for id in Decklists.CORP_STARTER:
		var c := _make_card(id)
		c.location = "rnd"
		rnd.cards.append(c)


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func _begin_runner_turn() -> void:
	whose_turn = "runner"
	phase = Phase.RUNNER_ACTION
	runner.clicks = 3
	runner.successful_run_this_turn = false
	runner.centrals_run_this_turn = {"HQ": false, "R&D": false, "Archives": false}
	_hq_breached_this_turn = false
	_ran_this_turn = false
	runner.installed_this_turn.clear()
	_reset_used_flags(runner)
	if runner.identity:
		runner.identity.extra["drew_basic"] = false
	_log("--- Runner turn %d ---" % turn_number)
	_run_turn_begin_triggers("runner")


func _begin_corp_turn() -> void:
	whose_turn = "corp"
	corp.clicks = 3
	corp.installed_this_turn.clear()
	_reset_used_flags(corp)
	_log("--- Corp turn %d ---" % turn_number)
	_run_turn_begin_triggers("corp")
	if rnd.cards.is_empty():
		_end_game("runner", "Corp cannot draw from empty R&D.")
		return
	_draw_corp(1, true)
	phase = Phase.CORP_ACTION


func _reset_used_flags(p: NRPlayer) -> void:
	var cards: Array = []
	if p.side == "runner":
		cards = p.programs + p.hardware + p.resources + p.grip
	else:
		for s in all_servers():
			cards.append_array(s.ice)
			cards.append_array(s.root)
		cards.append_array(hq.cards)
	for c in cards:
		c.used_this_turn = false


func _run_turn_begin_triggers(who: String) -> void:
	var installed: Array = _all_installed()
	for c in installed:
		var key := "on_runner_turn_begins" if who == "runner" else "on_corp_turn_begins"
		var ops: Array = c.def().get(key, [])
		if ops.is_empty():
			continue
		if c.side() == "corp" and not c.rezzed and c.card_type() != "agenda":
			continue
		_exec_ops(c, ops, {})


func _all_installed() -> Array:
	var out: Array = []
	out.append_array(runner.programs)
	out.append_array(runner.hardware)
	out.append_array(runner.resources)
	for s in all_servers():
		out.append_array(s.ice)
		out.append_array(s.root)
	return out


func _end_action_phase() -> void:
	if phase == Phase.RUNNER_DISCARD:
		_begin_corp_turn()
		return
	if phase == Phase.CORP_DISCARD:
		turn_number += 1
		runner_ran_last_turn = _ran_this_turn
		_begin_runner_turn()
		return
	if whose_turn == "runner":
		if runner.clicks > 0:
			_log("Runner forfeits %d click(s)." % runner.clicks)
		runner.clicks = 0
		if runner.grip.size() > max_hand(runner):
			phase = Phase.RUNNER_DISCARD
			_log("Runner must discard down to %d." % max_hand(runner))
		else:
			_begin_corp_turn()
	else:
		if corp.clicks > 0:
			_log("Corp forfeits %d click(s)." % corp.clicks)
		corp.clicks = 0
		if hq.cards.size() > max_hand(corp):
			phase = Phase.CORP_DISCARD
			_log("Corp must discard down to %d." % max_hand(corp))
		else:
			turn_number += 1
			runner_ran_last_turn = _ran_this_turn
			_begin_runner_turn()


func _basic_credit(who: String) -> void:
	if who == "runner":
		if runner.clicks < 1:
			return
		runner.clicks -= 1
		runner.credits += 1
		_log("Runner gains 1[c] (click).")
	else:
		if corp.clicks < 1:
			return
		corp.clicks -= 1
		corp.credits += 1
		_log("Corp gains 1[c] (click).")


func _basic_draw(who: String) -> void:
	if who == "runner":
		if runner.clicks < 1:
			return
		runner.clicks -= 1
		var n := 1
		if _has_verbal() and not bool(runner.identity.extra.get("drew_basic", false)):
			n = 2
			runner.identity.extra["drew_basic"] = true
			_log("Verbal Plasticity: draw 2 instead of 1.")
		_draw_runner(n, true)
	else:
		if corp.clicks < 1:
			return
		corp.clicks -= 1
		_draw_corp(1, true)


func _has_verbal() -> bool:
	for c in runner.resources:
		if c.def().get("double_first_basic_draw", false):
			return true
	return false


func _draw_runner(n: int, announce: bool) -> void:
	for _i in n:
		if runner.stack.is_empty():
			_log("Runner stack is empty.")
			return
		var c: NRCard = runner.stack.pop_back()
		c.location = "grip"
		runner.grip.append(c)
	if announce:
		_log("Runner draws %d." % n)


func _draw_corp(n: int, announce: bool) -> void:
	for _i in n:
		if rnd.cards.is_empty():
			_end_game("runner", "Corp decks out (empty R&D).")
			return
		var c: NRCard = rnd.cards.pop_back()
		c.location = "hq"
		hq.cards.append(c)
	if announce:
		_log("Corp draws %d." % n)


func _remove_tag() -> void:
	if runner.clicks < 1 or runner.credits < 2 or runner.tags < 1:
		return
	runner.clicks -= 1
	spend_credits("runner", 2, "removing a tag")
	runner.tags -= 1
	_log("Runner removes a tag. Tags: %d." % runner.tags)


func _purge() -> void:
	if corp.clicks < 3:
		return
	corp.clicks -= 3
	_log("Corp purges virus counters. (No viruses in this subset.)")


func _corp_trash_resource(card: NRCard) -> void:
	if corp.clicks < 1 or corp.credits < 2 or runner.tags < 1:
		return
	corp.clicks -= 1
	spend_credits("corp", 2, "trashing a resource")
	_trash(card, "Corp trashes %s." % card.title())


func _play_card(card: NRCard, action: Dictionary) -> void:
	var d := card.def()
	if int(d.get("requires_tags", 0)) > runner.tags:
		return
	if bool(d.get("requires_runner_ran_last_turn", false)) and not runner_ran_last_turn:
		return
	var cost := card.play_cost()
	var who := card.side()
	var clicks_ok := (runner.clicks if who == "runner" else corp.clicks) >= 1
	if not clicks_ok or available_credits(who) < cost:
		return
	if who == "runner":
		runner.clicks -= 1
		_remove_from_zone(card)
		spend_credits("runner", cost, "playing " + card.title())
	else:
		corp.clicks -= 1
		_remove_from_zone(card)
		spend_credits("corp", cost, "playing " + card.title())
	_log("%s plays %s." % [who.capitalize(), card.title()])
	var targets: Array = d.get("run_targets", [])
	if not targets.is_empty():
		var hosted := int(d.get("run_hosted_credits", 0))
		if hosted > 0:
			card.hosted_credits = hosted
			run_hosted_credits = hosted
			_log("%d[c] placed on %s for this run." % [hosted, card.title()])
		ice_rez_surcharge = int(d.get("ice_rez_surcharge", 0))
		extra_access = int(d.get("extra_access", 0))
		var srv: NRServer = action.get("server", null)
		card.location = "play"
		_start_run(srv, card)
		return
	_exec_ops(card, d.get("on_play", []), action)
	_discard_played(card)


func _discard_played(card: NRCard) -> void:
	if card.side() == "runner":
		card.location = "heap"
		runner.heap.append(card)
	else:
		card.location = "archives"
		archives.cards.append(card)


func _install_card(card: NRCard, action: Dictionary) -> void:
	var who := card.side()
	var cost := _install_cost(card)
	if who == "runner":
		if runner.clicks < 1 or available_credits("runner") < cost:
			return
		if card.card_type() == "program" and used_mu() + card.memory_cost() > max_mu():
			_log("Not enough MU to install %s." % card.title())
			return
		if card.is_unique() and _unique_installed(card.title()):
			_log("Unique already installed: %s." % card.title())
			return
		if card.has_subtype("Console") and _has_console():
			_log("Already have a console.")
			return
		runner.clicks -= 1
		_remove_from_zone(card)
		spend_credits("runner", cost, "installing " + card.title())
		match card.card_type():
			"program":
				card.location = "program"
				runner.programs.append(card)
			"hardware":
				card.location = "hardware"
				runner.hardware.append(card)
			_:
				card.location = "resource"
				runner.resources.append(card)
		runner.installed_this_turn.append(card)
		_log("Runner installs %s." % card.title())
		_exec_ops(card, card.def().get("on_install", []), {})
	else:
		if corp.clicks < 1:
			return
		var srv: NRServer = action.get("server", null)
		var as_ice := card.card_type() == "ice"
		if srv == null:
			return
		if srv.id == -99:
			srv = _new_remote()
		if not as_ice:
			if card.card_type() in ["asset", "agenda"] and (srv.has_asset() or srv.has_agenda()):
				## install in a brand-new remote
				srv = _new_remote()
		corp.clicks -= 1
		_remove_from_zone(card)
		card.rezzed = false
		card.known_to_runner = false
		if as_ice:
			card.location = "ice"
			card.server_id = srv.id
			srv.ice.append(card)
			_log("Corp installs ice protecting %s." % srv.server_name)
		else:
			card.location = "root"
			card.server_id = srv.id
			srv.root.append(card)
			_log("Corp installs a card in %s." % srv.server_name)
		corp.installed_this_turn.append(card)
		_exec_ops(card, card.def().get("on_install", []), {})


func _install_cost(card: NRCard) -> int:
	var n := card.play_cost()
	var disc := int(card.def().get("install_discount_after_success", 0))
	if disc > 0 and runner.successful_run_this_turn:
		n = max(0, n - disc)
	return n


func _unique_installed(title: String) -> bool:
	for c in _all_installed():
		if c.title() == title:
			return true
	return false


func _has_console() -> bool:
	for c in runner.hardware:
		if c.has_subtype("Console"):
			return true
	return false


func _new_remote() -> NRServer:
	var s := _make_server("Remote %d" % _next_remote_id, false, _next_remote_id)
	_next_remote_id += 1
	remotes.append(s)
	return s


func _use_ability(card: NRCard, ab_i: int, action: Dictionary) -> void:
	var abs: Array = card.def().get("abilities", [])
	if ab_i < 0 or ab_i >= abs.size():
		return
	var ab: Dictionary = abs[ab_i]
	var click_c := int(ab.get("click_cost", 0))
	var who := card.side()
	if who == "runner":
		if runner.clicks < click_c:
			return
		if bool(ab.get("once_per_turn", false)) and card.used_this_turn:
			return
		if int(ab.get("take_hosted", 0)) > 0 and card.hosted_credits < int(ab.take_hosted):
			return
		if bool(ab.get("run_unrun_central", false)):
			var srv: NRServer = action.get("server", null)
			if srv == null or not srv.is_central:
				return
			if bool(runner.centrals_run_this_turn.get(srv.server_name, false)):
				return
			runner.clicks -= click_c
			red_team_card = card
			card.used_this_turn = true
			_start_run(srv, null)
			return
		runner.clicks -= click_c
		card.used_this_turn = true
		_exec_ops(card, ab.get("ops", []), {})
	else:
		if not card.rezzed:
			return
		if corp.clicks < click_c:
			return
		if int(ab.get("take_hosted", 0)) > 0 and card.hosted_credits < int(ab.take_hosted):
			return
		corp.clicks -= click_c
		card.used_this_turn = true
		_exec_ops(card, ab.get("ops", []), {})


func _score(card: NRCard) -> void:
	if not card.can_be_advanced():
		return
	if card.card_type() != "agenda":
		return
	if card.advancement < card.advancement_requirement():
		return
	_remove_from_zone(card)
	card.location = "scored"
	card.faceup = true
	card.rezzed = true
	corp.score_area.append(card)
	_log("Corp scores %s (%d AP)." % [card.title(), card.agenda_points()])
	_exec_ops(card, card.def().get("on_scored", []), {})
	_check_win()


func _rez(card: NRCard, during_run: bool) -> bool:
	if card.rezzed:
		return true
	if bool(card.def().get("never_rez_usability", false)):
		return false
	var cost := rez_cost_now(card)
	if corp.credits < cost:
		_log("Corp cannot afford to rez %s (%d[c])." % [card.title(), cost])
		return false
	spend_credits("corp", cost, "rezzing " + card.title())
	card.rezzed = true
	card.faceup = true
	card.known_to_runner = true
	_log("Corp rezzes %s." % card.title())
	if bool(card.def().get("tag_on_rez_during_run", false)) and run_active and run_server != null and card.server_id == run_server.id:
		_add_tags(1)
	_exec_ops(card, card.def().get("on_rez", []), {})
	return true


func _advance(card: NRCard) -> void:
	if corp.clicks < 1 or corp.credits < 1:
		return
	if not card.can_be_advanced():
		return
	corp.clicks -= 1
	spend_credits("corp", 1, "advancing")
	card.advancement += 1
	_log("Corp advances a card (%d advancement)." % card.advancement)


func _steal(card: NRCard) -> void:
	_remove_from_zone(card)
	card.location = "stolen"
	card.faceup = true
	runner.score_area.append(card)
	_log("Runner steals %s (%d AP)." % [card.title(), card.agenda_points()])
	_exec_ops(card, card.def().get("on_stolen", []), {})
	accessing = null
	_check_win()


func _trash_accessing() -> void:
	if accessing == null:
		return
	var tc := accessing.trash_cost()
	if tc < 0:
		_finish_access_card(false)
		return
	if available_credits("runner") < tc:
		_log("Cannot afford trash cost %d." % tc)
		return
	spend_credits("runner", tc, "trashing " + accessing.title())
	var c := accessing
	accessing = null
	_trash(c, "Runner trashes %s." % c.title())
	_finish_access_card(true)


func _finish_access_card(already_gone: bool) -> void:
	if not already_gone and accessing != null:
		_log("Runner returns %s." % accessing.title())
		accessing = null
	_next_access()


func _trash(card: NRCard, msg: String) -> void:
	_remove_from_zone(card)
	if card.side() == "runner":
		card.location = "heap"
		runner.heap.append(card)
	else:
		card.location = "archives"
		card.known_to_runner = true
		archives.cards.append(card)
	card.rezzed = false
	card.hosted_credits = 0
	_log(msg)


func _remove_from_zone(card: NRCard) -> void:
	_erase(runner.grip, card)
	_erase(runner.stack, card)
	_erase(runner.heap, card)
	_erase(runner.programs, card)
	_erase(runner.hardware, card)
	_erase(runner.resources, card)
	_erase(hq.cards, card)
	_erase(rnd.cards, card)
	_erase(archives.cards, card)
	_erase(corp.score_area, card)
	_erase(runner.score_area, card)
	for s in all_servers():
		_erase(s.ice, card)
		_erase(s.root, card)
	card.server_id = -1


func _erase(arr: Array, card: NRCard) -> void:
	var i := arr.find(card)
	if i >= 0:
		arr.remove_at(i)


func _is_remote_ice(ice: NRCard) -> bool:
	var s := server_by_id(ice.server_id)
	return s != null and not s.is_central


func _check_win() -> void:
	if is_over():
		return
	if runner.scored_points() >= agenda_points_to_win:
		_end_game("runner", "Runner stole %d agenda points." % runner.scored_points())
	elif corp.scored_points() >= agenda_points_to_win:
		_end_game("corp", "Corp scored %d agenda points." % corp.scored_points())
	elif max_hand(runner) < 0:
		_end_game("corp", "Runner flatlined (hand size below 0).")


func _end_game(w: String, reason: String) -> void:
	phase = Phase.GAME_OVER
	winner = w
	win_reason = reason
	_clear_run()
	_pending_kind = ""
	_log("GAME OVER — %s wins. %s" % [w.capitalize(), reason])
	game_over.emit(w, reason)


func _clear_run() -> void:
	run_active = false
	run_server = null
	run_ice_index = -1
	run_event = null
	run_hosted_credits = 0
	ice_rez_surcharge = 0
	extra_access = 0
	run_successful = false
	access_queue.clear()
	accessing = null
	_subs_queue.clear()
	red_team_card = null


# ---------- actions lists ----------

func _A(t: String, label: String, extra: Dictionary = {}) -> Dictionary:
	var d := extra.duplicate()
	d["type"] = t
	d["label"] = label
	return d


func _actions_runner() -> Array:
	var a: Array = []
	if runner.clicks > 0:
		a.append(_A("credit", "[click] Gain 1[c]", {"who": "runner"}))
		if not runner.stack.is_empty():
			a.append(_A("draw", "[click] Draw 1", {"who": "runner"}))
		if runner.tags > 0 and runner.credits >= 2:
			a.append(_A("remove_tag", "[click] 2[c]: Remove a tag"))
		for card in runner.grip:
			_add_play_install_runner(a, card)
		for s in all_servers():
			a.append(_A("run", "[click] Run %s" % s.server_name, {"server": s}))
		_add_runner_abilities(a)
	a.append(_A("end_phase", "End turn / discard phase"))
	return a


func _add_play_install_runner(a: Array, card: NRCard) -> void:
	match card.card_type():
		"event":
			if runner.clicks < 1 or available_credits("runner") < card.play_cost():
				return
			var targets: Array = card.def().get("run_targets", [])
			if targets.is_empty():
				a.append(_A("play", "Play %s (%d[c])" % [card.title(), card.play_cost()], {"card": card}))
			else:
				for s in _run_targets_for(card):
					a.append(_A("play", "Play %s → %s" % [card.title(), s.server_name], {"card": card, "server": s}))
		"program", "hardware", "resource":
			var cost := _install_cost(card)
			if runner.clicks < 1 or available_credits("runner") < cost:
				return
			if card.card_type() == "program" and used_mu() + card.memory_cost() > max_mu():
				return
			if card.is_unique() and _unique_installed(card.title()):
				return
			if card.has_subtype("Console") and _has_console():
				return
			a.append(_A("install", "Install %s (%d[c])" % [card.title(), cost], {"card": card}))


func _run_targets_for(card: NRCard) -> Array:
	var spec: Array = card.def().get("run_targets", [])
	var out: Array = []
	if spec.has("any"):
		return all_servers()
	for s in all_servers():
		if spec.has(s.server_name):
			out.append(s)
	return out


func _add_runner_abilities(a: Array) -> void:
	var inst: Array = runner.programs + runner.hardware + runner.resources
	for card in inst:
		var abs: Array = card.def().get("abilities", [])
		for i in abs.size():
			var ab: Dictionary = abs[i]
			if int(ab.get("click_cost", 0)) > runner.clicks:
				continue
			if bool(ab.get("once_per_turn", false)) and card.used_this_turn:
				continue
			if int(ab.get("take_hosted", 0)) > card.hosted_credits:
				continue
			if bool(ab.get("run_unrun_central", false)):
				for s in [hq, rnd, archives]:
					if not bool(runner.centrals_run_this_turn.get(s.server_name, false)):
						a.append(_A("ability", "%s: Run %s" % [card.title(), s.server_name], {"card": card, "ab": i, "server": s}))
			else:
				a.append(_A("ability", "%s: %s" % [card.title(), str(ab.get("text", "ability"))], {"card": card, "ab": i}))


func _actions_corp() -> Array:
	var a: Array = []
	for s in remotes:
		for card in s.root:
			if card.card_type() == "agenda" and card.advancement >= card.advancement_requirement():
				a.append(_A("score", "Score %s" % card.title(), {"card": card}))
	for s in all_servers():
		for card in s.root + s.ice:
			if card.card_type() == "agenda":
				continue
			if not card.rezzed and not bool(card.def().get("never_rez_usability", false)) and corp.credits >= rez_cost_now(card):
				a.append(_A("rez", "Rez %s (%d[c])" % [card.title(), rez_cost_now(card)], {"card": card}))
	if corp.clicks > 0:
		a.append(_A("credit", "[click] Gain 1[c]", {"who": "corp"}))
		if not rnd.cards.is_empty():
			a.append(_A("draw", "[click] Draw 1", {"who": "corp"}))
		if corp.clicks >= 3:
			a.append(_A("purge", "[click][click][click] Purge"))
		if runner.tags > 0 and corp.credits >= 2:
			for r in runner.resources:
				a.append(_A("trash_resource", "Trash resource %s" % r.title(), {"card": r}))
		for card in hq.cards:
			_add_play_install_corp(a, card)
		for s in all_servers():
			for card in s.root + s.ice:
				if card.can_be_advanced() and corp.credits >= 1:
					a.append(_A("advance", "Advance %s (%d)" % [card.title() if card.rezzed or card.card_type() != "agenda" else "facedown card", card.advancement], {"card": card}))
	a.append(_A("end_phase", "End Corp action phase"))
	return a


func _add_play_install_corp(a: Array, card: NRCard) -> void:
	match card.card_type():
		"operation":
			if corp.clicks < 1 or available_credits("corp") < card.play_cost():
				return
			if int(card.def().get("requires_tags", 0)) > runner.tags:
				return
			if bool(card.def().get("requires_runner_ran_last_turn", false)) and not runner_ran_last_turn:
				return
			a.append(_A("play", "Play %s (%d[c])" % [card.title(), card.play_cost()], {"card": card}))
		"ice":
			if corp.clicks < 1:
				return
			for s in all_servers():
				a.append(_A("install", "Install ice on %s (%s)" % [s.server_name, card.title()], {"card": card, "server": s}))
			a.append(_A("install", "Install ice on a new remote (%s)" % card.title(), {"card": card, "server": _preview_new_remote(card)}))
		"asset", "agenda", "upgrade":
			if corp.clicks < 1:
				return
			for s in remotes:
				if card.card_type() == "upgrade" or not (s.has_agenda() or s.has_asset()):
					a.append(_A("install", "Install %s in %s" % [card.title(), s.server_name], {"card": card, "server": s}))
			a.append(_A("install", "Install %s in a new remote" % card.title(), {"card": card, "server": _preview_new_remote(card)}))


var _ghost_remote: NRServer = null

func _preview_new_remote(_card: NRCard) -> NRServer:
	## Actual new remote is created at install time if this ghost is used.
	if _ghost_remote == null:
		_ghost_remote = _make_server("(new remote)", false, -99)
	return _ghost_remote


func _actions_discard(p: NRPlayer) -> Array:
	var a: Array = []
	if p.grip.size() <= max_hand(p):
		a.append(_A("end_phase", "Continue"))
		return a
	for c in p.grip:
		a.append(_A("discard", "Discard %s" % c.title(), {"card": c}))
	return a


func _actions_discard_corp() -> Array:
	var a: Array = []
	if hq.cards.size() <= max_hand(corp):
		a.append(_A("end_phase", "Continue"))
		return a
	for c in hq.cards:
		a.append(_A("discard", "Discard %s" % c.title(), {"card": c}))
	return a


func _do_discard(card: NRCard) -> void:
	if whose_turn == "runner" or phase == Phase.RUNNER_DISCARD:
		_remove_from_zone(card)
		card.location = "heap"
		runner.heap.append(card)
		_log("Runner discards %s." % card.title())
		if runner.grip.size() <= max_hand(runner) and phase == Phase.RUNNER_DISCARD:
			_begin_corp_turn()
	else:
		_remove_from_zone(card)
		card.location = "archives"
		archives.cards.append(card)
		_log("Corp discards %s." % card.title())
		if hq.cards.size() <= max_hand(corp) and phase == Phase.CORP_DISCARD:
			turn_number += 1
			runner_ran_last_turn = _ran_this_turn
			_begin_runner_turn()


# ---------- runs ----------

func _start_run(server: NRServer, event: NRCard) -> void:
	if server != null and server.id == -99:
		server = _new_remote()
	if event == null:
		if runner.clicks < 1:
			return
		runner.clicks -= 1
	if server == null:
		return
	run_active = true
	run_server = server
	run_event = event
	run_successful = false
	mayfly_used = false
	_ran_this_turn = true
	if server.is_central:
		runner.centrals_run_this_turn[server.server_name] = true
	if event != null:
		extra_access = int(event.def().get("extra_access", extra_access))
		ice_rez_surcharge = int(event.def().get("ice_rez_surcharge", ice_rez_surcharge))
		if int(event.def().get("run_hosted_credits", 0)) > 0:
			run_hosted_credits = event.hosted_credits
	if corp.bad_publicity > 0:
		runner.credits += corp.bad_publicity
		_log("Runner gains %d[c] from bad publicity." % corp.bad_publicity)
	_log("Run initiated attacking %s." % server.server_name)
	if server.ice.is_empty():
		phase = Phase.RUN_APPROACH_SERVER
	else:
		run_ice_index = server.outermost_index()
		phase = Phase.RUN_APPROACH_ICE
		_log("Approaching ice protecting %s (position %d)." % [server.server_name, run_ice_index])
		if server.ice[run_ice_index].rezzed:
			_begin_encounter()


func _actions_approach_ice() -> Array:
	var a: Array = []
	var ice: NRCard = run_server.ice[run_ice_index]
	if ice.rezzed:
		a.append(_A("begin_enc", "Encounter %s" % ice.title()))
		return a
	if corp.credits >= rez_cost_now(ice) and not bool(ice.def().get("never_rez_usability", false)):
		a.append(_A("rez_approached", "Rez %s (%d[c])" % [ice.title(), rez_cost_now(ice)], {"card": ice}))
	a.append(_A("no_rez", "Do not rez (pass ice)"))
	return a


func _begin_encounter() -> void:
	var ice: NRCard = run_server.ice[run_ice_index]
	for i in ice.subroutine_broken.size():
		ice.subroutine_broken[i] = false
	ice.strength_boost = 0
	for b in runner.programs:
		b.strength_boost = 0
	_log("Encountering %s (str %d)." % [ice.title(), ice_strength(ice)])
	phase = Phase.RUN_ENCOUNTER
	_exec_ops(ice, ice.def().get("on_encounter", []), {})


func _pass_ice() -> void:
	phase = Phase.RUN_MOVEMENT


func _actions_encounter() -> Array:
	if not run_active:
		return []
	var ice: NRCard = run_server.ice[run_ice_index]
	var a: Array = []
	if _unbroken_count(ice) == 0:
		a.append(_A("resolve_subs", "All broken — continue"))
		return a
	for b in runner.programs:
		if not b.has_subtype("Icebreaker"):
			continue
		if not _breaker_matches(b, ice):
			continue
		var br: Dictionary = b.def().get("breaker", {})
		var bcost := int(br.get("boost_cost", 1))
		if breaker_strength(b) < ice_strength(ice) and available_credits("runner") >= bcost:
			a.append(_A("boost", "Boost %s (+%s str)" % [b.title(), _boost_amount(b)], {"card": b}))
		if breaker_strength(b) >= ice_strength(ice) and available_credits("runner") >= int(br.get("break_cost", 1)):
			for si in ice.subroutine_broken.size():
				if not ice.subroutine_broken[si]:
					a.append(_A("break", "Break sub %d with %s" % [si + 1, b.title()], {"card": b, "sub": si}))
			if _unbroken_count(ice) > 0:
				a.append(_A("auto_break", "Auto-break with %s" % b.title(), {"card": b}))
	if bool(ice.def().get("bioroid_break", false)) and runner.clicks > 0:
		for si in ice.subroutine_broken.size():
			if not ice.subroutine_broken[si]:
				a.append(_A("bioroid_break", "[click] Break sub %d (Bioroid)" % (si + 1), {"sub": si}))
	a.append(_A("resolve_subs", "Let remaining subroutines fire"))
	return a


func _breaker_matches(b: NRCard, ice: NRCard) -> bool:
	var br: Dictionary = b.def().get("breaker", {})
	var kind := str(br.get("breaks", ""))
	if kind == "any" or kind == "":
		return true
	return ice.has_subtype(kind)


func _boost_amount(b: NRCard) -> int:
	var br: Dictionary = b.def().get("breaker", {})
	var n := int(br.get("boost_n", 1))
	if bool(br.get("boost_per_breaker", false)):
		n = 0
		for p in runner.programs:
			if p.has_subtype("Icebreaker"):
				n += 1
	return n


func _unbroken_count(ice: NRCard) -> int:
	var n := 0
	for v in ice.subroutine_broken:
		if not v:
			n += 1
	return n


func _boost(b: NRCard) -> void:
	var br: Dictionary = b.def().get("breaker", {})
	var cost := int(br.get("boost_cost", 1))
	if not spend_credits("runner", cost, "boosting " + b.title()):
		return
	var amt := _boost_amount(b)
	b.strength_boost += amt
	_log("%s is now strength %d." % [b.title(), breaker_strength(b)])


func _break_sub(b: NRCard, si: int) -> void:
	var ice: NRCard = run_server.ice[run_ice_index]
	if si < 0 or si >= ice.subroutine_broken.size() or ice.subroutine_broken[si]:
		return
	if breaker_strength(b) < ice_strength(ice):
		_log("%s does not have enough strength." % b.title())
		return
	var br: Dictionary = b.def().get("breaker", {})
	var cost := int(br.get("break_cost", 1))
	var n := int(br.get("break_n", 1))
	if not spend_credits("runner", cost, "breaking with " + b.title()):
		return
	ice.subroutine_broken[si] = true
	_log("%s breaks a subroutine on %s." % [b.title(), ice.title()])
	if bool(b.def().get("trash_at_run_end_if_used", false)):
		mayfly_used = true
		b.extra["used_break"] = true
	## break_n extra optional autos for remaining cost-already-paid (Cleaver: up to 2)
	if n > 1:
		var extra := n - 1
		for j in ice.subroutine_broken.size():
			if extra <= 0:
				break
			if not ice.subroutine_broken[j]:
				ice.subroutine_broken[j] = true
				extra -= 1
				_log("%s breaks an additional subroutine." % b.title())


func _auto_break(b: NRCard) -> void:
	var ice: NRCard = run_server.ice[run_ice_index]
	var br: Dictionary = b.def().get("breaker", {})
	while _unbroken_count(ice) > 0 and run_active:
		if breaker_strength(b) < ice_strength(ice):
			if available_credits("runner") < int(br.get("boost_cost", 1)):
				break
			_boost(b)
			continue
		var si := -1
		for j in ice.subroutine_broken.size():
			if not ice.subroutine_broken[j]:
				si = j
				break
		if si < 0:
			break
		if available_credits("runner") < int(br.get("break_cost", 1)):
			break
		_break_sub(b, si)


func _bioroid_break(si: int) -> void:
	if runner.clicks < 1:
		return
	var ice: NRCard = run_server.ice[run_ice_index]
	if si < 0 or si >= ice.subroutine_broken.size():
		return
	runner.clicks -= 1
	ice.subroutine_broken[si] = true
	_log("Runner loses [click] to break a subroutine on %s." % ice.title())


func _begin_subs() -> void:
	var ice: NRCard = run_server.ice[run_ice_index]
	_subs_queue.clear()
	for i in ice.subroutine_broken.size():
		if not ice.subroutine_broken[i]:
			_subs_queue.append(i)
	phase = Phase.RUN_SUBS
	if _subs_queue.is_empty():
		_log("All subroutines broken.")
		_pass_ice()


func _fire_next_sub() -> void:
	if not run_active or is_over():
		return
	if _pending_kind != "":
		return
	if _subs_queue.is_empty():
		if run_active:
			_pass_ice()
		return
	var ice: NRCard = run_server.ice[run_ice_index]
	var si: int = _subs_queue.pop_front()
	var subs: Array = ice.def().get("subroutines", [])
	if si >= subs.size():
		return
	var sub: Dictionary = subs[si]
	_log("Subroutine of %s fires: %s" % [ice.title(), str(sub.get("text", ""))])
	_exec_ops(ice, sub.get("ops", []), {})


func _actions_movement() -> Array:
	var a: Array = []
	a.append(_A("continue_run", "Continue the run"))
	a.append(_A("jack_out", "Jack out"))
	return a


func _jack_out() -> void:
	_log("Runner jacks out.")
	_end_run(false)


func _continue_after_ice() -> void:
	run_ice_index -= 1
	if run_ice_index >= 0:
		phase = Phase.RUN_APPROACH_ICE
		_log("Approaching next ice (position %d)." % run_ice_index)
		if run_server.ice[run_ice_index].rezzed:
			_begin_encounter()
	else:
		phase = Phase.RUN_APPROACH_SERVER
		_log("Approaching %s." % run_server.server_name)


func _breach_server() -> void:
	if not run_active:
		return
	## Manegarm
	for card in run_server.root:
		if card.card_type() == "upgrade" and card.rezzed:
			var ops: Array = card.def().get("on_approach_server", [])
			if not ops.is_empty():
				_exec_ops(card, ops, {})
				return
	_successful_breach()


func _successful_breach() -> void:
	if not run_active:
		return
	run_successful = true
	runner.successful_run_this_turn = true
	_log("Run successful — breaching %s." % run_server.server_name)
	if run_event != null:
		_exec_ops(run_event, run_event.def().get("on_successful_run", []), {})
	for c in runner.hardware + runner.resources + runner.programs:
		_exec_ops(c, c.def().get("on_successful_run", []), {})
	if red_team_card != null and red_team_card.hosted_credits >= 3:
		red_team_card.hosted_credits -= 3
		runner.credits += 3
		_log("Red Team: take 3[c] (remaining %d)." % red_team_card.hosted_credits)
		if red_team_card.hosted_credits <= 0:
			_trash(red_team_card, "Red Team is empty and is trashed.")
	_build_access_queue()
	phase = Phase.RUN_ACCESS
	accessing = null


func _build_access_queue() -> void:
	access_queue.clear()
	var bonus := extra_access
	if run_server.server_name == "HQ":
		for c in runner.hardware:
			if int(c.def().get("first_hq_extra_access", 0)) > 0 and not _hq_breached_this_turn:
				bonus += int(c.def().get("first_hq_extra_access", 0))
		_hq_breached_this_turn = true
		var n: int = mini(1 + bonus, hq.cards.size())
		var pool: Array = hq.cards.duplicate()
		_shuffle(pool)
		for i in n:
			access_queue.append(pool[i])
	elif run_server.server_name == "R&D":
		var n2: int = mini(1 + bonus, rnd.cards.size())
		for i in n2:
			access_queue.append(rnd.cards[rnd.cards.size() - 1 - i])
	elif run_server.server_name == "Archives":
		for c in archives.cards:
			access_queue.append(c)
	else:
		for c in run_server.root:
			access_queue.append(c)


func _next_access() -> void:
	if not run_active:
		return
	if access_queue.is_empty():
		_end_run(true)
		return
	accessing = access_queue.pop_front()
	accessing.known_to_runner = true
	_log("Accessing %s." % accessing.title())
	if accessing.location == "root" or accessing.location == "ice":
		_exec_ops(accessing, accessing.def().get("on_access_installed", []), {})
		if is_over() or not run_active:
			return


func _actions_access() -> Array:
	if accessing == null:
		return []
	var a: Array = []
	if accessing.card_type() == "agenda":
		a.append(_A("access_steal", "Steal %s (%d AP)" % [accessing.title(), accessing.agenda_points()]))
	var tc := accessing.trash_cost()
	if tc >= 0 and accessing.card_type() != "agenda" and accessing.location != "archives":
		if available_credits("runner") >= tc:
			a.append(_A("access_trash", "Trash %s (%d[c])" % [accessing.title(), tc]))
	a.append(_A("access_done", "No action / next"))
	return a


func _end_run(success: bool) -> void:
	if not run_active:
		return
	_log("Run ends (%s)." % ("successful" if success else "unsuccessful"))
	for p in runner.programs:
		if bool(p.def().get("trash_at_run_end_if_used", false)) and bool(p.extra.get("used_break", false)):
			p.extra["used_break"] = false
			_trash(p, "%s is trashed at the end of the run." % p.title())
	if run_event != null:
		_discard_played(run_event)
	_clear_run()
	if not is_over():
		phase = Phase.RUNNER_ACTION if whose_turn == "runner" else Phase.CORP_ACTION


# ---------- effects ----------

func phase_name() -> String:
	match phase:
		Phase.RUNNER_ACTION: return "Runner action"
		Phase.RUNNER_DISCARD: return "Runner discard"
		Phase.CORP_ACTION: return "Corp action"
		Phase.CORP_DISCARD: return "Corp discard"
		Phase.RUN_APPROACH_ICE: return "Run: approach ice"
		Phase.RUN_ENCOUNTER: return "Run: encounter"
		Phase.RUN_SUBS: return "Run: subroutines"
		Phase.RUN_MOVEMENT: return "Run: movement"
		Phase.RUN_APPROACH_SERVER: return "Run: approach server"
		Phase.RUN_ACCESS: return "Run: access"
		Phase.GAME_OVER: return "Game over"
		_: return "?"


func pending_title() -> String:
	return _pending_title


func _src_title(source) -> String:
	if source == null:
		return "effect"
	return str(source.title())


func _exec_ops(source, ops: Array, ctx: Dictionary) -> void:
	if ops == null:
		return
	for op in ops:
		if is_over():
			return
		if not run_active and str(op.get("op", "")) == "end_the_run":
			continue
		_exec_op(source, op, ctx)


func _exec_op(source, op: Dictionary, ctx: Dictionary) -> void:
	var name := str(op.get("op", ""))
	match name:
		"gain_credits":
			var who := str(op.get("who", source.side()))
			var n := int(op.n)
			if who == "runner":
				runner.credits += n
			else:
				corp.credits += n
			_log("%s gains %d[c] from %s." % [who.capitalize(), n, source.title()])
		"lose_credits":
			var who2 := str(op.get("who", "runner"))
			var n2 := int(op.n)
			if who2 == "runner":
				var lost := mini(n2, runner.credits)
				runner.credits -= lost
				_log("Runner loses %d[c]." % lost)
			else:
				var lost2 := mini(n2, corp.credits)
				corp.credits -= lost2
		"draw":
			var who3 := str(op.get("who", source.side()))
			if who3 == "runner":
				_draw_runner(int(op.n), true)
			else:
				_draw_corp(int(op.n), true)
		"lose_click_if_any":
			if source.side() == "runner" and runner.clicks > 0:
				runner.clicks -= 1
				_log("Runner loses [click] (remaining %d)." % runner.clicks)
			elif source.side() == "corp" and corp.clicks > 0:
				corp.clicks -= 1
		"load_credits":
			source.hosted_credits += int(op.n)
			_log("%d[c] loaded onto %s." % [int(op.n), source.title()])
		"place_credits":
			source.hosted_credits += int(op.n)
			_log("Place %d[c] on %s (now %d)." % [int(op.n), source.title(), source.hosted_credits])
		"take_credits":
			var take := int(op.n)
			if int(op.get("if_has", 0)) > 0 and source.hosted_credits < int(op.if_has):
				return
			take = mini(take, source.hosted_credits)
			if take <= 0:
				return
			source.hosted_credits -= take
			if source.side() == "runner" or source.location in ["program", "hardware", "resource"]:
				runner.credits += take
				_log("Runner takes %d[c] from %s." % [take, source.title()])
			else:
				corp.credits += take
				_log("Corp takes %d[c] from %s." % [take, source.title()])
		"take_all_credits":
			var allc: int = int(source.hosted_credits)
			source.hosted_credits = 0
			runner.credits += allc
			_log("Runner takes %d[c] from %s." % [allc, source.title()])
		"trash_if_empty":
			if source.hosted_credits <= 0:
				_trash(source, "%s is empty and is trashed." % source.title())
		"trash_if_empty_draw":
			if source.hosted_credits <= 0:
				_trash(source, "%s is empty and is trashed." % source.title())
				_draw_corp(1, true)
		"end_the_run":
			_log("End the run.")
			_end_run(false)
		"etr_if_credits_le":
			if runner.credits <= int(op.n):
				_log("Runner has %d[c] — end the run." % runner.credits)
				_end_run(false)
		"damage":
			_do_damage(str(op.get("type", "net")), int(op.n))
		"add_tags":
			_add_tags(int(op.n))
		"wildcat":
			_offer("wildcat", "Wildcat Strike — Corp chooses", [
				_P("Gain 6[c]", {"n": 0}, "corp"),
				_P("Draw 4 cards", {"n": 1}, "corp"),
			], {"actor": "corp"})
		"orbital":
			if runner.tags > 0:
				_do_damage("meat", 4)
			else:
				_add_tags(1)
		"maybe_draw":
			_offer("maybe_draw", "%s: draw %d?" % [source.title(), int(op.n)], [
				_P("Draw %d" % int(op.n), {"n": int(op.n), "who": str(op.get("who", "corp"))}, "corp"),
				_P("Decline", {"n": 0}, "corp"),
			], {"actor": "corp"})
		"send_a_message":
			_offer_send_message()
		"seamless_launch":
			_offer_seamless()
		"retribution":
			_offer_retribution()
		"urtica":
			_do_damage("net", 2 + source.advancement)
		"manegarm":
			_offer_manegarm(source)
		"diviner":
			_diviner()
		"jack_out_optional":
			if run_active:
				_offer("jack_opt", "Karunā: jack out?", [
					_P("Jack out", {"yes": true}, "runner"),
					_P("Continue", {"yes": false}, "runner"),
				], {"actor": "runner"})
		"bran_install":
			_offer_bran(source)
		"funhouse_encounter":
			_offer("fun_enc", "Funhouse: take 1 tag or end the run", [
				_P("Take 1 tag", {"tag": true}, "runner"),
				_P("End the run", {"tag": false}, "runner"),
			], {"actor": "runner"})
		"funhouse_sub":
			var ch: Array = []
			if available_credits("runner") >= 4:
				ch.append(_P("Pay 4[c]", {"pay": true}, "runner"))
			ch.append(_P("Take 1 tag", {"pay": false}, "runner"))
			_offer("fun_sub", "Funhouse subroutine", ch, {"actor": "runner"})
		"trace":
			_begin_trace(int(op.get("base", 0)), op.get("on_success", []))
		_:
			_log("Unimplemented op %s on %s" % [name, _src_title(source)])


func _P(label: String, payload: Dictionary, actor: String) -> Dictionary:
	var d := payload.duplicate()
	d["type"] = "pending"
	d["label"] = label
	d["actor"] = actor
	return d


func _offer(kind: String, title: String, choices: Array, data: Dictionary) -> void:
	_pending_kind = kind
	_pending_title = title
	_pending_choices = choices
	_pending_data = data
	_log(title)


func _offer_send_message() -> void:
	var ch: Array = [_P("Decline", {"card": null}, "corp")]
	for s in all_servers():
		for ice in s.ice:
			if not ice.rezzed:
				ch.append(_P("Rez %s for free" % ice.title(), {"card": ice}, "corp"))
	if ch.size() == 1:
		return
	_offer("send_msg", "Send a Message: rez ice, ignoring all costs?", ch, {"actor": "corp"})


func _offer_seamless() -> void:
	var ch: Array = []
	for s in all_servers():
		for card in s.root + s.ice:
			if card.can_be_advanced() and corp.installed_this_turn.find(card) < 0:
				ch.append(_P("%s in %s" % [card.title(), s.server_name], {"card": card}, "corp"))
	if ch.is_empty():
		_log("Seamless Launch: no legal target.")
		return
	_offer("seamless", "Seamless Launch: place 2 advancement", ch, {"actor": "corp"})


func _offer_retribution() -> void:
	var ch: Array = []
	for c in runner.programs + runner.hardware:
		ch.append(_P("Trash %s" % c.title(), {"card": c}, "corp"))
	if ch.is_empty():
		_log("Retribution: nothing to trash.")
		return
	_offer("retribution", "Retribution: trash program or hardware", ch, {"actor": "corp"})


func _offer_manegarm(source: NRCard) -> void:
	var ch: Array = []
	if runner.clicks >= 2:
		ch.append(_P("Spend [click][click]", {"pay": "clicks"}, "runner"))
	if available_credits("runner") >= 5:
		ch.append(_P("Pay 5[c]", {"pay": "credits"}, "runner"))
	ch.append(_P("End the run", {"pay": "etr"}, "runner"))
	_offer("manegarm", "Manegarm Skunkworks", ch, {"actor": "runner", "source": source})


func _offer_bran(ice: NRCard) -> void:
	var ch: Array = [_P("Decline", {"card": null}, "corp")]
	for c in hq.cards:
		if c.card_type() == "ice":
			ch.append(_P("Install %s from HQ" % c.title(), {"card": c}, "corp"))
	for c in archives.cards:
		if c.card_type() == "ice":
			ch.append(_P("Install %s from Archives" % c.title(), {"card": c}, "corp"))
	_offer("bran", "Brân 1.0: install ice inward, ignoring costs?", ch, {"actor": "corp", "ice": ice})


func _begin_trace(base: int, success_ops: Array) -> void:
	_trace_base = base
	_trace_success_ops = success_ops
	var ch: Array = []
	for i in range(0, corp.credits + 1):
		ch.append(_P("Trace %d + %d = %d" % [base, i, base + i], {"spent": i}, "corp"))
	_offer("trace_corp", "Trace[%d]: Corp spends for trace strength" % base, ch, {"actor": "corp"})


func _resolve_pending(action: Dictionary) -> void:
	var kind := _pending_kind
	_pending_kind = ""
	_pending_choices = []
	match kind:
		"wildcat":
			if int(action.get("n", 0)) == 0:
				runner.credits += 6
				_log("Wildcat Strike: Runner gains 6[c].")
			else:
				_draw_runner(4, true)
		"maybe_draw":
			if int(action.get("n", 0)) > 0:
				if str(action.get("who", "corp")) == "corp":
					_draw_corp(int(action.n), true)
				else:
					_draw_runner(int(action.n), true)
		"send_msg":
			var ice = action.get("card", null)
			if ice != null:
				ice.rezzed = true
				ice.faceup = true
				_log("Corp rezzes %s, ignoring all costs." % ice.title())
		"seamless":
			var t = action.get("card", null)
			if t != null:
				t.advancement += 2
				_log("Seamless Launch: 2 advancement on a card (now %d)." % t.advancement)
		"retribution":
			var tr = action.get("card", null)
			if tr != null:
				_trash(tr, "Retribution trashes %s." % tr.title())
		"manegarm":
			var pay := str(action.get("pay", "etr"))
			if pay == "clicks":
				runner.clicks -= 2
				_log("Runner spends 2[click] for Manegarm.")
				_successful_breach()
			elif pay == "credits":
				spend_credits("runner", 5, "Manegarm")
				_successful_breach()
			else:
				_end_run(false)
		"jack_opt":
			if bool(action.get("yes", false)):
				_jack_out()
		"bran":
			var ic = action.get("card", null)
			if ic != null and run_server != null:
				_remove_from_zone(ic)
				ic.location = "ice"
				ic.server_id = run_server.id
				ic.rezzed = false
				var idx := run_ice_index
				run_server.ice.insert(idx, ic)
				run_ice_index += 1
				_log("Corp installs %s inward of Brân 1.0, ignoring costs." % ic.title())
		"fun_enc":
			if bool(action.get("tag", false)):
				_add_tags(1)
			else:
				_end_run(false)
		"fun_sub":
			if bool(action.get("pay", false)):
				spend_credits("runner", 4, "Funhouse")
			else:
				_add_tags(1)
		"trace_corp":
			_trace_corp_spent = int(action.get("spent", 0))
			spend_credits("corp", _trace_corp_spent, "trace")
			var ch: Array = []
			for i in range(0, runner.credits + 1):
				ch.append(_P("Link %d + %d = %d" % [runner.link, i, runner.link + i], {"spent": i}, "runner"))
			_offer("trace_runner", "Increase link?", ch, {"actor": "runner"})
		"trace_runner":
			var sp := int(action.get("spent", 0))
			spend_credits("runner", sp, "link")
			var tr := _trace_base + _trace_corp_spent
			var lk := runner.link + sp
			_log("Trace %d vs link %d." % [tr, lk])
			if tr > lk:
				_log("Trace successful.")
				_exec_ops(null, _trace_success_ops, {})
			else:
				_log("Trace unsuccessful.")
		_:
			_log("Unhandled pending %s" % kind)


func _add_tags(n: int) -> void:
	runner.tags += n
	_log("Runner gets %d tag(s). Tags: %d." % [n, runner.tags])


func _diviner() -> void:
	var before := runner.grip.size()
	_do_damage("net", 1)
	if is_over():
		return
	if runner.grip.size() < before and not runner.heap.is_empty():
		var last: NRCard = runner.heap[runner.heap.size() - 1]
		var pc := last.printed_cost()
		_log("%s has printed cost %d." % [last.title(), pc])
		if pc % 2 == 1:
			_log("Odd cost — end the run.")
			_end_run(false)


func _do_damage(kind: String, n: int) -> void:
	if n <= 0:
		return
	_log("Runner suffers %d %s damage." % [n, kind])
	if kind == "brain":
		runner.brain_damage += n
		if max_hand(runner) < 0:
			_end_game("corp", "Runner flatlined from brain damage.")
			return
	var hand: Array = runner.grip
	if hand.size() < n:
		_end_game("corp", "Runner flatlined (%s damage)." % kind)
		return
	## trash n random from grip
	var pool: Array = hand.duplicate()
	_shuffle(pool)
	for i in n:
		var c: NRCard = pool[i]
		_remove_from_zone(c)
		c.location = "heap"
		runner.heap.append(c)
		_log("  trashed from grip: %s" % c.title())
