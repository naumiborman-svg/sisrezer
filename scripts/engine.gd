class_name NREngine
extends RefCounted

const CORP := "corp"
const RUNNER := "runner"

var db: Dictionary = {}
var rng := RandomNumberGenerator.new()
var uid_seq := 0
var corp: Dictionary = {}
var runner: Dictionary = {}
var remotes: Array = []
var turn := CORP
var phase := "action"
var run: Dictionary = {}
var prompt := ""
var prompt_data: Dictionary = {}
var winner := ""
var win_reason := ""
var log_lines: PackedStringArray = PackedStringArray()
var agenda_goal := 6
var flags: Dictionary = {}


func _init(card_defs: Dictionary) -> void:
	db = card_defs


func new_game(p_seed: int, decks: Dictionary) -> void:
	rng.seed = p_seed if p_seed != 0 else Time.get_ticks_usec()
	uid_seq = 0
	remotes.clear()
	run.clear()
	prompt = ""
	prompt_data.clear()
	winner = ""
	win_reason = ""
	log_lines = PackedStringArray()
	flags = {"turn": 0, "hq_breach": false, "successful_run": false, "ran_centrals": []}
	agenda_goal = int(decks.get("agenda_goal", 6))
	corp = _blank_side(CORP)
	runner = _blank_side(RUNNER)
	_build_deck(corp, decks["corp"])
	_build_deck(runner, decks["runner"])
	_shuffle(corp.deck)
	_shuffle(runner.deck)
	_draw(CORP, 5)
	_draw(RUNNER, 5)
	turn = CORP
	phase = "action"
	_begin_turn(CORP)
	_log("Game start. Play to %d agenda points." % agenda_goal)


func legal() -> Array:
	if winner != "":
		return []
	if prompt != "":
		return _legal_prompt()
	if phase == "discard":
		return _legal_discard()
	if phase == "approach_ice":
		return _legal_approach_ice()
	if phase == "encounter":
		return _legal_encounter()
	if phase == "approach_server":
		return _legal_approach_server()
	if phase == "access":
		return _legal_access()
	if phase != "action":
		return []
	return _legal_actions()


func apply(act: Dictionary) -> bool:
	if winner != "":
		return false
	var op := str(act.get("op", ""))
	for option: Variant in legal():
		if option is Dictionary and _acts_match(option, act):
			return _do(act)
	return false


func side_of(who: String) -> Dictionary:
	return corp if who == CORP else runner


func find_uid(uid: int) -> Dictionary:
	var found := _find_in(corp.hand, uid)
	if not found.is_empty():
		return found
	found = _find_in(corp.deck, uid)
	if not found.is_empty():
		return found
	found = _find_in(corp.discard, uid)
	if not found.is_empty():
		return found
	found = _find_in(corp.score, uid)
	if not found.is_empty():
		return found
	if int(corp.identity.get("uid", -1)) == uid:
		return corp.identity
	found = _find_in(runner.hand, uid)
	if not found.is_empty():
		return found
	found = _find_in(runner.deck, uid)
	if not found.is_empty():
		return found
	found = _find_in(runner.discard, uid)
	if not found.is_empty():
		return found
	found = _find_in(runner.score, uid)
	if not found.is_empty():
		return found
	found = _find_in(runner.programs, uid)
	if not found.is_empty():
		return found
	found = _find_in(runner.hardware, uid)
	if not found.is_empty():
		return found
	found = _find_in(runner.resources, uid)
	if not found.is_empty():
		return found
	if int(runner.identity.get("uid", -1)) == uid:
		return runner.identity
	for remote: Variant in remotes:
		found = _find_in(remote.ices, uid)
		if not found.is_empty():
			return found
		found = _find_in(remote.root, uid)
		if not found.is_empty():
			return found
	for arr: Array in [corp.hq_ices, corp.rd_ices, corp.archives_ices]:
		found = _find_in(arr, uid)
		if not found.is_empty():
			return found
	return {}


func ice_strength(card: Dictionary) -> int:
	var n := int(card.get("strength", 0)) + int(card.get("strength_mod", 0))
	if str(card.get("code", "")) == "30072" and str(card.get("server", "")).begins_with("remote"):
		n += 2
	return n


func breaker_strength(card: Dictionary) -> int:
	var n := int(card.get("strength", 0)) + int(card.get("pump", 0))
	return n


func server_ices(server: String) -> Array:
	match server:
		"hq":
			return corp.hq_ices
		"rd":
			return corp.rd_ices
		"archives":
			return corp.archives_ices
		_:
			if server.begins_with("remote:"):
				var rid := int(server.get_slice(":", 1))
				for remote: Variant in remotes:
					if int(remote.id) == rid:
						return remote.ices
	return []


func remote_by_id(rid: int) -> Dictionary:
	for remote: Variant in remotes:
		if int(remote.id) == rid:
			return remote
	return {}


func agenda_points(who: String) -> int:
	var n := 0
	for card: Variant in side_of(who).score:
		n += int(card.get("agendapoints", 0))
	return n


func max_hand(who: String) -> int:
	var n := 5
	if who == CORP:
		for card: Variant in corp.score:
			if str(card.get("code", "")) == "30070":
				n += 2
	else:
		for card: Variant in runner.hardware:
			if str(card.get("code", "")) == "30031":
				n += 1
	return n - int(side_of(who).get("brain", 0))


func mu_used() -> int:
	var n := 0
	for card: Variant in runner.programs:
		n += int(card.get("memoryunits", 1))
	return n


func mu_max() -> int:
	var n := 4
	for card: Variant in runner.hardware:
		if str(card.get("code", "")) in ["30014", "30031", "30022", "30023"]:
			n += 1
	return n


func _blank_side(who: String) -> Dictionary:
	var d := {
		"who": who,
		"credits": 5,
		"clicks": 0,
		"clicks_max": 3 if who == CORP else 4,
		"hand": [],
		"deck": [],
		"discard": [],
		"score": [],
		"identity": {},
		"tags": 0,
		"brain": 0,
	}
	if who == CORP:
		d["hq_ices"] = []
		d["rd_ices"] = []
		d["archives_ices"] = []
	else:
		d["programs"] = []
		d["hardware"] = []
		d["resources"] = []
	return d


func _build_deck(side: Dictionary, spec: Dictionary) -> void:
	side.identity = _make_card(str(spec["identity"]))
	side.identity.zone = "identity"
	var counts: Dictionary = spec["cards"]
	for code: Variant in counts.keys():
		var n := int(counts[code])
		for _i in n:
			var card := _make_card(str(code))
			card.zone = "deck"
			side.deck.append(card)


func _make_card(code: String) -> Dictionary:
	uid_seq += 1
	var d: Dictionary = db.get(code, {}).duplicate(true)
	d["uid"] = uid_seq
	d["code"] = code
	d["zone"] = ""
	d["server"] = ""
	d["rezzed"] = str(d.get("type", "")) == "Identity"
	d["advancement"] = 0
	d["hosted"] = 0
	d["pump"] = 0
	d["installed_turn"] = -1
	d["strength_mod"] = 0
	if not d.has("subtypes"):
		d["subtypes"] = []
	if d["subtypes"] is String:
		d["subtypes"] = [d["subtypes"]]
	return d


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func _draw(who: String, n: int) -> int:
	var side := side_of(who)
	var got := 0
	for _i in n:
		if side.deck.is_empty():
			if who == CORP:
				_win(RUNNER, "Corp is decked")
			return got
		var card: Dictionary = side.deck.pop_front()
		card.zone = "hand"
		side.hand.append(card)
		got += 1
	return got


func _gain(who: String, n: int) -> void:
	side_of(who).credits += n


func _pay(who: String, n: int) -> bool:
	if n <= 0:
		return true
	if who == RUNNER and int(run.get("overclock", 0)) > 0:
		var use: int = mini(n, int(run.overclock))
		run.overclock = int(run.overclock) - use
		n -= use
	if side_of(who).credits < n:
		return false
	side_of(who).credits -= n
	return true


func _log(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > 80:
		log_lines = log_lines.slice(log_lines.size() - 80)


func _begin_turn(who: String) -> void:
	turn = who
	phase = "action"
	var side := side_of(who)
	side.clicks = int(side.clicks_max)
	flags.successful_run = false
	flags.hq_breach = false
	flags.ran_centrals = []
	flags.telework = false
	flags.verbal = false
	flags.turn = int(flags.turn) + (1 if who == CORP else 0)
	if who == CORP:
		_draw(CORP, 1)
		_log("Corp turn. Mandatory draw.")
	else:
		_log("Runner turn.")
	_start_of_turn_cards(who)


func _start_of_turn_cards(who: String) -> void:
	if who == CORP:
		for remote: Variant in remotes:
			for card: Variant in remote.root:
				if card.rezzed and str(card.code) == "30037":
					_take_hosted(card, 3, true)
				if card.rezzed and str(card.code) == "30071":
					pass
	else:
		for card: Variant in runner.resources:
			if str(card.code) == "30033" and int(card.hosted) > 0:
				_take_hosted(card, 1, false)


func _take_hosted(card: Dictionary, n: int, draw_on_empty: bool) -> void:
	var got: int = mini(n, int(card.hosted))
	card.hosted -= got
	_gain(CORP if str(card.side) == "Corp" else RUNNER, got)
	_log("%s takes %d from %s." % [_side_name(card), got, card.title])
	if int(card.hosted) <= 0:
		_trash_installed(card)
		if draw_on_empty:
			_draw(CORP, 1)


func _side_name(card: Dictionary) -> String:
	return "Corp" if str(card.get("side", "")) == "Corp" else "Runner"


func _find_in(arr: Array, uid: int) -> Dictionary:
	for card: Variant in arr:
		if int(card.uid) == uid:
			return card
	return {}


func _acts_match(legal_act: Dictionary, got: Dictionary) -> bool:
	for key: Variant in legal_act.keys():
		if str(legal_act[key]) != str(got.get(key, "")):
			return false
	return true


func _legal_actions() -> Array:
	var out: Array = []
	var side := side_of(turn)
	if turn == CORP:
		_legal_corp_free(out)
	if int(side.clicks) <= 0:
		out.append({"op": "end_turn"})
		return out
	out.append({"op": "credit"})
	if not side.deck.is_empty():
		out.append({"op": "draw"})
	out.append({"op": "end_turn"})
	if turn == CORP:
		_legal_corp(out)
	else:
		_legal_runner(out)
	return out


func _legal_corp_free(out: Array) -> void:
	for card: Dictionary in _installed_corp_cards():
		if str(card.type) == "Agenda" and int(card.advancement) >= int(card.get("advancementcost", 99)):
			out.append({"op": "score", "uid": card.uid})
		if not card.rezzed and str(card.type) in ["Asset", "Upgrade"] and corp.credits >= int(card.get("cost", 0)):
			out.append({"op": "rez", "uid": card.uid})


func _legal_corp(out: Array) -> void:
	for card: Variant in corp.hand:
		var t := str(card.type)
		if t == "Operation" and corp.credits >= int(card.get("cost", 0)):
			if str(card.code) == "30040":
				if _advanceable_not_this_turn().is_empty():
					continue
			out.append({"op": "play", "uid": card.uid})
		if t in ["Agenda", "Asset", "Upgrade"]:
			out.append({"op": "install", "uid": card.uid, "dest": "new_remote"})
			for remote: Variant in remotes:
				if remote.root.is_empty():
					out.append({"op": "install", "uid": card.uid, "dest": "remote:%d" % remote.id})
		if t == "ICE":
			for dest: String in ["hq", "rd", "archives"]:
				out.append({"op": "install", "uid": card.uid, "dest": dest})
			out.append({"op": "install", "uid": card.uid, "dest": "new_remote"})
			for remote: Variant in remotes:
				out.append({"op": "install", "uid": card.uid, "dest": "remote:%d" % remote.id})
	for card: Dictionary in _installed_corp_cards():
		if _can_advance(card) and corp.credits >= 1:
			out.append({"op": "advance", "uid": card.uid})
		if card.rezzed and str(card.code) == "30071" and int(card.hosted) > 0:
			out.append({"op": "ability", "uid": card.uid, "name": "take"})


func _legal_runner(out: Array) -> void:
	for card: Variant in runner.hand:
		var t := str(card.type)
		var cost := _install_cost(card)
		if t == "Event" and runner.credits >= int(card.get("cost", 0)):
			out.append({"op": "play", "uid": card.uid})
		if t in ["Program", "Hardware", "Resource"] and runner.credits >= cost:
			if t == "Program" and mu_used() + int(card.get("memoryunits", 1)) > mu_max():
				continue
			if t == "Hardware" and _is_console(card) and _has_console():
				continue
			out.append({"op": "install", "uid": card.uid, "dest": "rig"})
	for dest: String in ["hq", "rd", "archives"]:
		out.append({"op": "run", "server": dest})
	for remote: Variant in remotes:
		out.append({"op": "run", "server": "remote:%d" % remote.id})
	for card: Variant in runner.resources:
		if str(card.code) == "30033":
			out.append({"op": "ability", "uid": card.uid, "name": "load"})
		if str(card.code) == "30027" and not flags.telework and int(card.hosted) > 0:
			out.append({"op": "ability", "uid": card.uid, "name": "take"})
		if str(card.code) == "30018" and int(card.hosted) > 0:
			for dest: String in ["hq", "rd", "archives"]:
				if dest not in flags.ran_centrals:
					out.append({"op": "ability", "uid": card.uid, "name": "run", "server": dest})
	for card: Variant in runner.hardware:
		if str(card.code) == "30014":
			out.append({"op": "ability", "uid": card.uid, "name": "take"})


func _install_cost(card: Dictionary) -> int:
	var cost := int(card.get("cost", 0))
	if str(card.code) == "30015" and flags.successful_run:
		cost = maxi(0, cost - 2)
	return cost


func _is_console(card: Dictionary) -> bool:
	return "Console" in card.get("subtypes", [])


func _has_console() -> bool:
	for card: Variant in runner.hardware:
		if _is_console(card):
			return true
	return false


func _can_advance(card: Dictionary) -> bool:
	return str(card.type) == "Agenda" or str(card.code) == "30045"


func _advanceable_not_this_turn() -> Array:
	var out: Array = []
	for card: Dictionary in _installed_corp_cards():
		if _can_advance(card) and int(card.installed_turn) != int(flags.turn):
			out.append(card)
	return out


func _installed_corp_cards() -> Array:
	var out: Array = []
	for arr: Array in [corp.hq_ices, corp.rd_ices, corp.archives_ices]:
		for card: Variant in arr:
			out.append(card)
	for remote: Variant in remotes:
		for card: Variant in remote.ices:
			out.append(card)
		for card: Variant in remote.root:
			out.append(card)
	return out


func _legal_discard() -> Array:
	var side := side_of(turn)
	if side.hand.size() <= max_hand(turn):
		return [{"op": "end_turn"}]
	var out: Array = []
	for card: Variant in side.hand:
		out.append({"op": "discard", "uid": card.uid})
	return out


func _legal_approach_ice() -> Array:
	var ice: Dictionary = run.ice
	if not ice.rezzed and not run.get("rez_done", false):
		var out: Array = [{"op": "no_rez"}]
		if corp.credits >= _rez_cost(ice):
			out.append({"op": "rez", "uid": ice.uid})
		return out
	var out2: Array = [{"op": "continue"}]
	if int(run.pos) > 0:
		out2.append({"op": "jack_out"})
	return out2


func _legal_encounter() -> Array:
	var out: Array = [{"op": "continue"}]
	var ice: Dictionary = run.ice
	if "Bioroid" in ice.get("subtypes", []) and runner.clicks > 0:
		out.append({"op": "bioroid_break"})
	for br: Variant in runner.programs:
		if not _is_breaker(br):
			continue
		if _breaker_matches(br, ice) and breaker_strength(br) >= ice_strength(ice):
			var left := _unbroken_count()
			if left > 0 and _can_pay_break(br):
				out.append({"op": "break", "uid": br.uid})
		if _can_pay_pump(br):
			out.append({"op": "pump", "uid": br.uid})
	return out


func _legal_approach_server() -> Array:
	var out: Array = [{"op": "continue"}]
	if _manegarm() != {}:
		if runner.clicks >= 2:
			out.append({"op": "manegarm_clicks"})
		if runner.credits >= 5:
			out.append({"op": "manegarm_credits"})
	return out


func _legal_access() -> Array:
	var out: Array = []
	var card: Dictionary = run.get("current", {})
	if card.is_empty():
		return [{"op": "continue"}]
	if str(card.type) == "Agenda":
		out.append({"op": "steal", "uid": card.uid})
	if str(card.type) in ["Asset", "Upgrade", "ICE"] and int(card.get("trash", 0)) <= runner.credits:
		if card.zone != "discard":
			out.append({"op": "trash_access", "uid": card.uid})
	out.append({"op": "pass_access", "uid": card.uid})
	return out


func _legal_prompt() -> Array:
	match prompt:
		"jailbreak_server":
			return [{"op": "choose_server", "server": "hq"}, {"op": "choose_server", "server": "rd"}]
		"overclock_server", "tread_server":
			var out: Array = [{"op": "choose_server", "server": "hq"}, {"op": "choose_server", "server": "rd"}, {"op": "choose_server", "server": "archives"}]
			for remote: Variant in remotes:
				out.append({"op": "choose_server", "server": "remote:%d" % remote.id})
			return out
		"karuna_jack":
			return [{"op": "jack_out"}, {"op": "continue"}]
		"seamless":
			var out2: Array = []
			for card: Dictionary in _advanceable_not_this_turn():
				out2.append({"op": "advance_free", "uid": card.uid})
			return out2
	return [{"op": "continue"}]


func _rez_cost(ice: Dictionary) -> int:
	return int(ice.get("cost", 0)) + int(run.get("rez_extra", 0))


func _is_breaker(card: Dictionary) -> bool:
	return "Icebreaker" in card.get("subtypes", [])


func _breaker_matches(br: Dictionary, ice: Dictionary) -> bool:
	var code := str(br.code)
	if code == "30032":
		return true
	if code == "30006":
		return "Barrier" in ice.get("subtypes", [])
	if code == "30026":
		return "Code Gate" in ice.get("subtypes", [])
	if code == "30015":
		return "Sentry" in ice.get("subtypes", [])
	return false


func _unbroken_count() -> int:
	var n := 0
	for sub: Variant in run.subs:
		if not sub.broken:
			n += 1
	return n


func _can_pay_break(br: Dictionary) -> bool:
	return _available_runner_credits() >= 1


func _can_pay_pump(br: Dictionary) -> bool:
	var need := 1 if str(br.code) in ["30032", "30026"] else 2
	return _available_runner_credits() >= need


func _available_runner_credits() -> int:
	return int(runner.credits) + int(run.get("overclock", 0))


func _manegarm() -> Dictionary:
	var server := str(run.get("server", ""))
	if not server.begins_with("remote:"):
		return {}
	var remote := remote_by_id(int(server.get_slice(":", 1)))
	if remote.is_empty():
		return {}
	for card: Variant in remote.root:
		if card.rezzed and str(card.code) == "30042":
			return card
	return {}


func _do(act: Dictionary) -> bool:
	var op := str(act.op)
	match op:
		"credit":
			return _act_credit()
		"draw":
			return _act_draw()
		"end_turn":
			return _act_end_turn()
		"play":
			return _act_play(int(act.uid))
		"install":
			return _act_install(int(act.uid), str(act.dest))
		"advance":
			return _act_advance(int(act.uid))
		"score":
			return _act_score(int(act.uid))
		"rez":
			return _act_rez(int(act.uid))
		"run":
			return _start_run(str(act.server), {})
		"ability":
			return _act_ability(act)
		"discard":
			return _act_discard(int(act.uid))
		"continue":
			return _act_continue()
		"no_rez":
			run.rez_done = true
			_log("Corp does not rez the ice.")
			return true
		"jack_out":
			return _end_run(false, "Runner jacks out.")
		"break":
			return _act_break(int(act.uid))
		"pump":
			return _act_pump(int(act.uid))
		"bioroid_break":
			return _act_bioroid()
		"steal":
			return _act_steal(int(act.uid))
		"trash_access":
			return _act_trash_access(int(act.uid))
		"pass_access":
			return _next_access()
		"choose_server":
			return _act_choose_server(str(act.server))
		"manegarm_clicks":
			runner.clicks -= 2
			_log("Runner spends 2 clicks on Manegarm.")
			return _begin_access()
		"manegarm_credits":
			if not _pay(RUNNER, 5):
				return false
			_log("Runner pays 5 on Manegarm.")
			return _begin_access()
		"advance_free":
			return _act_seamless(int(act.uid))
	return false


func _spend_click() -> bool:
	if side_of(turn).clicks <= 0:
		return false
	side_of(turn).clicks -= 1
	return true


func _act_credit() -> bool:
	if not _spend_click():
		return false
	_gain(turn, 1)
	_log("%s clicks for a credit." % turn.capitalize())
	return true


func _act_draw() -> bool:
	if not _spend_click():
		return false
	var n := 2 if turn == RUNNER and not _has_card(runner.resources, "30034").is_empty() and not flags.verbal else 1
	if n == 2:
		flags.verbal = true
	_draw(turn, n)
	_log("%s draws %d." % [turn.capitalize(), n])
	return true


func _has_card(arr: Array, code: String) -> Dictionary:
	for card: Variant in arr:
		if str(card.code) == code:
			return card
	return {}


func _act_end_turn() -> bool:
	if phase == "action":
		phase = "discard"
		if side_of(turn).hand.size() <= max_hand(turn):
			return _finish_turn()
		_log("%s must discard to %d." % [turn.capitalize(), max_hand(turn)])
		return true
	if phase == "discard":
		if side_of(turn).hand.size() <= max_hand(turn):
			return _finish_turn()
	return false


func _finish_turn() -> bool:
	if max_hand(turn) < 0:
		_win(CORP, "Runner flatline (hand size)")
		return true
	var nxt := RUNNER if turn == CORP else CORP
	_begin_turn(nxt)
	return true


func _act_discard(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty() or card.zone != "hand":
		return false
	_move_to_discard(card)
	_log("Discard %s." % card.title)
	if side_of(turn).hand.size() <= max_hand(turn):
		return _finish_turn()
	return true


func _act_play(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty():
		return false
	if not _spend_click():
		return false
	if not _pay(turn, int(card.get("cost", 0))):
		side_of(turn).clicks += 1
		return false
	_log("%s plays %s." % [turn.capitalize(), card.title])
	_remove_from_hand(card)
	return _resolve_play(card)


func _resolve_play(card: Dictionary) -> bool:
	match str(card.code):
		"30075":
			_gain(CORP, 9)
			_move_to_discard(card)
		"30064":
			_gain(CORP, 15)
			_move_to_discard(card)
		"30030":
			_gain(RUNNER, 9)
			_move_to_discard(card)
		"30020":
			_gain(RUNNER, 5)
			if runner.clicks > 0:
				runner.clicks -= 1
			_move_to_discard(card)
		"30021":
			_draw(RUNNER, 4)
			if runner.clicks > 0:
				runner.clicks -= 1
			_move_to_discard(card)
		"30040":
			_move_to_discard(card)
			prompt = "seamless"
			phase = "action"
		"30028":
			_move_to_discard(card)
			prompt = "jailbreak_server"
			run = {"event": "30028"}
		"30029":
			_move_to_discard(card)
			prompt = "overclock_server"
			run = {"event": "30029", "overclock": 5}
		"30012":
			_move_to_discard(card)
			prompt = "tread_server"
			run = {"event": "30012", "rez_extra": 3}
		_:
			_move_to_discard(card)
	return true


func _act_choose_server(server: String) -> bool:
	var extra: Dictionary = run.duplicate(true)
	prompt = ""
	return _start_run(server, extra)


func _act_seamless(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty():
		return false
	card.advancement += 2
	prompt = ""
	_log("Seamless Launch places 2 advancements on %s." % card.title)
	return true


func _act_install(uid: int, dest: String) -> bool:
	var card := find_uid(uid)
	if card.is_empty():
		return false
	if not _spend_click():
		return false
	if turn == RUNNER:
		var cost := _install_cost(card)
		if not _pay(RUNNER, cost):
			runner.clicks += 1
			return false
		_remove_from_hand(card)
		card.zone = str(card.type).to_lower()
		card.rezzed = true
		card.installed_turn = int(flags.turn)
		match str(card.type):
			"Program":
				runner.programs.append(card)
			"Hardware":
				runner.hardware.append(card)
			"Resource":
				runner.resources.append(card)
		_on_runner_install(card)
		_log("Runner installs %s." % card.title)
		return true
	_remove_from_hand(card)
	card.installed_turn = int(flags.turn)
	card.rezzed = false
	if str(card.type) == "ICE":
		_install_ice(card, dest)
	else:
		_install_root(card, dest)
	_log("Corp installs a card.")
	return true


func _on_runner_install(card: Dictionary) -> void:
	match str(card.code):
		"30018":
			card.hosted = 12
		"30027":
			card.hosted = 9


func _install_ice(card: Dictionary, dest: String) -> void:
	card.zone = "ice"
	card.type = "ICE"
	if dest == "new_remote":
		var remote := _new_remote()
		dest = "remote:%d" % remote.id
		remote.ices.insert(0, card)
	elif dest.begins_with("remote:"):
		remote_by_id(int(dest.get_slice(":", 1))).ices.insert(0, card)
	elif dest == "hq":
		corp.hq_ices.insert(0, card)
	elif dest == "rd":
		corp.rd_ices.insert(0, card)
	elif dest == "archives":
		corp.archives_ices.insert(0, card)
	card.server = dest


func _install_root(card: Dictionary, dest: String) -> void:
	card.zone = "root"
	var remote: Dictionary
	if dest == "new_remote":
		remote = _new_remote()
	else:
		remote = remote_by_id(int(dest.get_slice(":", 1)))
	remote.root.append(card)
	card.server = "remote:%d" % remote.id


func _new_remote() -> Dictionary:
	var remote := {"id": remotes.size() + 1, "ices": [], "root": []}
	remotes.append(remote)
	return remote


func _act_advance(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty() or not _can_advance(card):
		return false
	if not _spend_click():
		return false
	if not _pay(CORP, 1):
		corp.clicks += 1
		return false
	card.advancement += 1
	_log("Corp advances a card (%d)." % card.advancement)
	return true


func _act_score(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty() or str(card.type) != "Agenda":
		return false
	_remove_installed(card)
	card.zone = "score"
	card.rezzed = true
	corp.score.append(card)
	_log("Corp scores %s for %d AP." % [card.title, int(card.agendapoints)])
	_on_score(card, CORP)
	_check_agenda_win()
	return true


func _on_score(card: Dictionary, who: String) -> void:
	match str(card.code):
		"30067":
			if who == CORP:
				_gain(CORP, 7)
		"30070":
			if who == CORP:
				_draw(CORP, 2)
		"30069":
			_send_a_message()


func _send_a_message() -> void:
	var best: Dictionary = {}
	for card: Dictionary in _installed_corp_cards():
		if str(card.type) == "ICE" and not card.rezzed:
			if best.is_empty() or int(card.get("cost", 0)) < int(best.get("cost", 0)):
				best = card
	if not best.is_empty():
		best.rezzed = true
		_log("Send a Message rezzes %s." % best.title)


func _act_rez(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty() or card.rezzed:
		return false
	var cost := _rez_cost(card) if str(card.type) == "ICE" else int(card.get("cost", 0))
	if not _pay(CORP, cost):
		return false
	card.rezzed = true
	_log("Corp rezzes %s." % card.title)
	match str(card.code):
		"30037":
			card.hosted = 9
		"30071":
			card.hosted = 15
	if phase == "approach_ice" and int(run.get("ice", {}).get("uid", -1)) == uid:
		return _enter_encounter()
	return true


func _act_ability(act: Dictionary) -> bool:
	var card := find_uid(int(act.uid))
	if card.is_empty():
		return false
	var name := str(act.get("name", ""))
	if str(card.code) == "30071" and name == "take":
		if not _spend_click():
			return false
		_take_hosted(card, 3, false)
		return true
	if str(card.code) == "30033" and name == "load":
		if not _spend_click():
			return false
		card.hosted += 3
		_log("Smartware loads 3.")
		return true
	if str(card.code) == "30027" and name == "take":
		if not _spend_click():
			return false
		flags.telework = true
		_take_hosted(card, 3, false)
		return true
	if str(card.code) == "30014" and name == "take":
		if not _spend_click():
			return false
		card.hosted += 1
		var got: int = int(card.hosted)
		card.hosted = 0
		_gain(RUNNER, got)
		_log("Pennyshaver takes %d." % got)
		return true
	if str(card.code) == "30018" and name == "run":
		if not _spend_click():
			return false
		run = {"red_team": card.uid}
		return _start_run(str(act.server), run)
	return false


func _start_run(server: String, extra: Dictionary) -> bool:
	if extra.is_empty() and not _spend_click():
		return false
	run = extra
	run["server"] = server
	run["pos"] = 0
	run["successful"] = false
	run["subs"] = []
	run["ice"] = {}
	run["queue"] = []
	run["current"] = {}
	if server in ["hq", "rd", "archives"] and server not in flags.ran_centrals:
		flags.ran_centrals.append(server)
	_log("Runner runs %s." % server)
	return _next_ice_or_server()


func _next_ice_or_server() -> bool:
	var ices := server_ices(str(run.server))
	if int(run.pos) < ices.size():
		run.ice = ices[int(run.pos)]
		run.rez_done = false
		phase = "approach_ice"
		_log("Approaching %s." % (run.ice.title if run.ice.rezzed else "unrezzed ice"))
		return true
	phase = "approach_server"
	_log("Approaching the server.")
	return true


func _act_continue() -> bool:
	if prompt == "karuna_jack":
		prompt = ""
		return _finish_subs()
	if phase == "approach_ice":
		var ice: Dictionary = run.ice
		if ice.rezzed:
			return _enter_encounter()
		run.pos = int(run.pos) + 1
		return _next_ice_or_server()
	if phase == "encounter":
		return _fire_unbroken()
	if phase == "approach_server":
		if _manegarm() != {}:
			_end_run(false, "Manegarm ends the run.")
			return true
		return _begin_access()
	if phase == "access":
		return _next_access()
	return false


func _enter_encounter() -> bool:
	phase = "encounter"
	var ice: Dictionary = run.ice
	run.subs = _build_subs(ice)
	for br: Variant in runner.programs:
		br.pump = 0
	_log("Encountering %s." % ice.title)
	return true


func _build_subs(ice: Dictionary) -> Array:
	match str(ice.code):
		"30072":
			return [_sub("etr")]
		"30073":
			return [_sub("net", 1), _sub("corp_credit", 1)]
		"30074":
			return [_sub("lose_credits", 3), _sub("etr_if_poor")]
		"30046":
			return [_sub("diviner")]
		"30047":
			return [_sub("karuna"), _sub("net", 2)]
		"30039":
			return [_sub("bran_install"), _sub("etr"), _sub("etr")]
		_:
			return [_sub("etr")]


func _sub(kind: String, n: int = 0) -> Dictionary:
	return {"kind": kind, "n": n, "broken": false}


func _act_break(uid: int) -> bool:
	var br := find_uid(uid)
	if br.is_empty() or not _pay(RUNNER, 1):
		return false
	var max_n := 2 if str(br.code) == "30006" else 1
	var broken := 0
	for sub: Variant in run.subs:
		if not sub.broken and broken < max_n:
			sub.broken = true
			broken += 1
	_log("Break %d subroutine(s) with %s." % [broken, br.title])
	if str(br.code) == "30032":
		run.mayfly = br.uid
	return true


func _act_pump(uid: int) -> bool:
	var br := find_uid(uid)
	if br.is_empty():
		return false
	var cost := 1 if str(br.code) in ["30032", "30026"] else 2
	if not _pay(RUNNER, cost):
		return false
	if str(br.code) == "30026":
		var n := 0
		for p: Variant in runner.programs:
			if _is_breaker(p):
				n += 1
		br.pump += n
	elif str(br.code) == "30015":
		br.pump += 3
	else:
		br.pump += 1
	_log("Pump %s to %d strength." % [br.title, breaker_strength(br)])
	return true


func _act_bioroid() -> bool:
	if runner.clicks <= 0:
		return false
	runner.clicks -= 1
	for sub: Variant in run.subs:
		if not sub.broken:
			sub.broken = true
			_log("Runner loses a click to break a bioroid subroutine.")
			return true
	return false


func _fire_unbroken() -> bool:
	for sub: Variant in run.subs:
		if sub.broken:
			continue
		if not _fire_sub(sub):
			return true
	return _finish_subs()


func _fire_sub(sub: Dictionary) -> bool:
	match str(sub.kind):
		"etr":
			_end_run(false, "A subroutine ends the run.")
			return false
		"net":
			_net_damage(int(sub.n))
			return winner == ""
		"corp_credit":
			_gain(CORP, int(sub.n))
		"lose_credits":
			var lose: int = mini(int(sub.n), int(runner.credits))
			runner.credits -= lose
		"etr_if_poor":
			if runner.credits <= 6:
				_end_run(false, "Whitespace ends the run.")
				return false
		"diviner":
			var before := runner.hand.duplicate()
			_net_damage(1)
			if winner != "":
				return false
			for card: Variant in before:
				if card.zone == "discard" and int(card.get("cost", 0)) % 2 == 1:
					_end_run(false, "Diviner ends the run.")
					return false
		"karuna":
			_net_damage(2)
			if winner != "":
				return false
			prompt = "karuna_jack"
			return false
		"bran_install":
			_bran_install()
	return true


func _finish_subs() -> bool:
	if winner != "" or phase != "encounter":
		return true
	run.pos = int(run.pos) + 1
	return _next_ice_or_server()


func _bran_install() -> void:
	for card: Variant in corp.hand:
		if str(card.type) == "ICE":
			_remove_from_hand(card)
			var dest := str(run.server)
			card.installed_turn = int(flags.turn)
			card.rezzed = false
			var ices := server_ices(dest)
			var idx := ices.find(run.ice)
			ices.insert(idx + 1, card)
			card.zone = "ice"
			card.server = dest
			_log("Brân installs ice inward.")
			return


func _begin_access() -> bool:
	phase = "access"
	run.successful = true
	flags.successful_run = true
	var penn := _has_card(runner.hardware, "30014")
	if not penn.is_empty():
		penn.hosted += 1
	if str(run.get("event", "")) == "30028":
		_draw(RUNNER, 1)
	if run.has("red_team"):
		var rt := find_uid(int(run.red_team))
		if not rt.is_empty():
			_take_hosted(rt, 3, false)
	run.queue = _access_queue()
	_log("Successful run. Accessing %d card(s)." % run.queue.size())
	return _next_access()


func _access_queue() -> Array:
	var server := str(run.server)
	var extra := 0
	if str(run.get("event", "")) == "30028":
		extra += 1
	if server == "hq" and not flags.hq_breach and not _has_card(runner.hardware, "30013").is_empty():
		extra += 1
		flags.hq_breach = true
	var out: Array = []
	if server == "hq":
		var hand: Array = corp.hand.duplicate()
		_shuffle(hand)
		var n: int = mini(1 + extra, hand.size())
		for i in n:
			out.append(hand[i])
	elif server == "rd":
		var n2: int = mini(1 + extra, corp.deck.size())
		for i in n2:
			out.append(corp.deck[i])
	elif server == "archives":
		out = corp.discard.duplicate()
	elif server.begins_with("remote:"):
		var remote := remote_by_id(int(server.get_slice(":", 1)))
		out = remote.root.duplicate()
	return out


func _next_access() -> bool:
	if run.queue.is_empty():
		return _end_run(true, "Run succeeds.")
	run.current = run.queue.pop_front()
	var card: Dictionary = run.current
	_log("Access %s." % card.title)
	if str(card.code) == "30045" and card.zone == "root":
		_net_damage(2 + int(card.advancement))
		if winner != "":
			return true
	return true


func _act_steal(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty() or str(card.type) != "Agenda":
		return false
	_remove_from_any(card)
	card.zone = "score"
	card.rezzed = true
	runner.score.append(card)
	_log("Runner steals %s for %d AP." % [card.title, int(card.agendapoints)])
	_on_score(card, RUNNER)
	_check_agenda_win()
	if winner != "":
		return true
	return _next_access()


func _act_trash_access(uid: int) -> bool:
	var card := find_uid(uid)
	if card.is_empty():
		return false
	if not _pay(RUNNER, int(card.get("trash", 0))):
		return false
	_remove_from_any(card)
	_move_to_discard(card)
	_log("Runner trashes %s." % card.title)
	return _next_access()


func _end_run(success: bool, reason: String) -> bool:
	if run.has("mayfly"):
		var fly := find_uid(int(run.mayfly))
		if not fly.is_empty() and fly.zone == "program":
			_trash_installed(fly)
			_log("Mayfly is trashed.")
	_log(reason)
	run.clear()
	prompt = ""
	phase = "action"
	if success:
		pass
	return true


func _net_damage(n: int) -> void:
	_log("Runner takes %d net damage." % n)
	for _i in n:
		if runner.hand.is_empty():
			_win(CORP, "Runner flatline")
			return
		var idx := rng.randi_range(0, runner.hand.size() - 1)
		var card: Dictionary = runner.hand[idx]
		_move_to_discard(card)


func _win(who: String, reason: String) -> void:
	winner = who
	win_reason = reason
	phase = "over"
	_log("%s wins: %s" % [who.capitalize(), reason])


func _check_agenda_win() -> void:
	if agenda_points(CORP) >= agenda_goal:
		_win(CORP, "Corp scores %d AP" % agenda_points(CORP))
	elif agenda_points(RUNNER) >= agenda_goal:
		_win(RUNNER, "Runner scores %d AP" % agenda_points(RUNNER))


func _remove_from_hand(card: Dictionary) -> void:
	corp.hand.erase(card)
	runner.hand.erase(card)


func _move_to_discard(card: Dictionary) -> void:
	_remove_from_any(card)
	card.zone = "discard"
	card.rezzed = false
	card.server = ""
	if str(card.side) == "Corp":
		corp.discard.append(card)
	else:
		runner.discard.append(card)


func _trash_installed(card: Dictionary) -> void:
	_move_to_discard(card)


func _remove_installed(card: Dictionary) -> void:
	_remove_from_any(card)


func _remove_from_any(card: Dictionary) -> void:
	for arr_name: String in ["hand", "deck", "discard", "score", "programs", "hardware", "resources"]:
		if corp.has(arr_name):
			corp[arr_name].erase(card)
		if runner.has(arr_name):
			runner[arr_name].erase(card)
	corp.hq_ices.erase(card)
	corp.rd_ices.erase(card)
	corp.archives_ices.erase(card)
	for remote: Variant in remotes:
		remote.ices.erase(card)
		remote.root.erase(card)
