extends Control
## AI-vs-AI Netrunner match. Heuristic Corp/Runner drive NRProcessActions
## for ~60s of game time (Movie Maker) or until game-over / ~12 turns.

const BG := Color("0a0e14")
const ACCENT := Color("3d8bfd")
const CORP_COL := Color("5ec8ff")
const RUNNER_COL := Color("3dd68c")
const GOLD := Color("f0c14b")
const FAIL_COL := Color("ff6b6b")
const MUTED := Color("8b9bb4")
const TEXT := Color("d7e3f4")
const HEADER := "AI MATCH — Godot 4.7.2"
const FONT_PATH := "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
const MATCH_SECONDS := 60.0
const STEP_SECONDS := 0.05
const MAX_TURNS := 20
const MAX_RUN_STEPS := 28

var _mono: Font
var _log_label: RichTextLabel
var _hud: RichTextLabel
var _board: Label
var _status: Label
var _sub: Label

var _state: NRState
var _game_time := 0.0
var _next_step := 0.0
var _log_count := 0
var _ai_lines: PackedStringArray = PackedStringArray()
var _last_ended := ""
var _started := false
var _match_over := false
var _idle := false
var _stuck := 0
var _run_steps := 0
var _actions := 0
var _movie := false
var _summary_written := false
var _ran_servers: Dictionary = {}
var _purged := false
var _success_waits := 0


func _ready() -> void:
	_movie = _cmdline_has("--write-movie")
	if DisplayServer.get_name() != "headless" and get_window() != null:
		get_window().size = Vector2i(1280, 800)
	_build_ui()
	_boot_engine()
	set_process(true)


func _cmdline_has(flag: String) -> bool:
	var args := OS.get_cmdline_args()
	for a in args:
		if str(a) == flag or str(a).begins_with(flag):
			return true
	return false


func _is_fast() -> bool:
	return DisplayServer.get_name() == "headless" and not _movie


func _process(delta: float) -> void:
	_game_time += delta
	_refresh_hud()
	if _game_time >= MATCH_SECONDS:
		_finish("time")
		return
	if _idle:
		return
	if _is_fast():
		var guard := 0
		while not _idle and not _match_over and guard < 40:
			_step()
			guard += 1
		if _match_over or _idle:
			_finish("fast")
		return
	if _game_time >= _next_step:
		_step()
		_next_step = _game_time + STEP_SECONDS


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mono = _load_mono()

	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var accent := ColorRect.new()
	accent.color = ACCENT
	accent.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	accent.offset_right = 6
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(accent)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 28
	vbox.offset_top = 14
	vbox.offset_right = -20
	vbox.offset_bottom = -14
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)

	var header := Label.new()
	header.text = HEADER
	header.add_theme_font_override("font", _mono)
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", ACCENT)
	vbox.add_child(header)

	_sub = Label.new()
	_sub.text = "heuristic AIs  ·  mtgred/netrunner GDScript port  ·  Godot %s" % Engine.get_version_info().get("string", "?")
	_sub.add_theme_font_override("font", _mono)
	_sub.add_theme_font_size_override("font_size", 13)
	_sub.add_theme_color_override("font_color", MUTED)
	vbox.add_child(_sub)

	_hud = RichTextLabel.new()
	_hud.bbcode_enabled = true
	_hud.fit_content = true
	_hud.scroll_active = false
	_hud.custom_minimum_size = Vector2(0, 44)
	_hud.add_theme_font_override("normal_font", _mono)
	_hud.add_theme_font_override("bold_font", _mono)
	_hud.add_theme_font_size_override("normal_font_size", 15)
	_hud.add_theme_font_size_override("bold_font_size", 15)
	_hud.add_theme_color_override("default_color", TEXT)
	vbox.add_child(_hud)

	_board = Label.new()
	_board.text = "board…"
	_board.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board.add_theme_font_override("font", _mono)
	_board.add_theme_font_size_override("font_size", 12)
	_board.add_theme_color_override("font_color", MUTED)
	vbox.add_child(_board)

	_log_label = RichTextLabel.new()
	_log_label.bbcode_enabled = true
	_log_label.scroll_following = true
	_log_label.fit_content = false
	_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log_label.add_theme_font_override("normal_font", _mono)
	_log_label.add_theme_font_override("bold_font", _mono)
	_log_label.add_theme_font_override("mono_font", _mono)
	_log_label.add_theme_font_size_override("normal_font_size", 13)
	_log_label.add_theme_font_size_override("bold_font_size", 13)
	_log_label.add_theme_font_size_override("mono_font_size", 13)
	_log_label.add_theme_constant_override("line_separation", -1)
	_log_label.add_theme_color_override("default_color", TEXT)
	_log_label.selection_enabled = true
	vbox.add_child(_log_label)

	_status = Label.new()
	_status.text = "booting…"
	_status.add_theme_font_override("font", _mono)
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", MUTED)
	vbox.add_child(_status)


func _load_mono() -> Font:
	if FileAccess.file_exists(FONT_PATH):
		var ff := FontFile.new()
		if ff.load_dynamic_font(FONT_PATH) == OK:
			return ff
	return ThemeDB.fallback_font


func _append(bb: String) -> void:
	_ai_lines.append(bb)
	if _ai_lines.size() > 220:
		_ai_lines = _ai_lines.slice(_ai_lines.size() - 160)
		_rebuild_log()
	else:
		_log_label.append_text(bb + "\n")
	var plain := _strip_bb(bb)
	print(plain)


func _rebuild_log() -> void:
	_log_label.clear()
	for line in _ai_lines:
		_log_label.append_text(line + "\n")


func _strip_bb(bb: String) -> String:
	var out := bb
	for tag in ["[b]", "[/b]", "[code]", "[/code]", "[/color]"]:
		out = out.replace(tag, "")
	for col in ["3dd68c", "ff6b6b", "8b9bb4", "d7e3f4", "3d8bfd", "5ec8ff", "f0c14b"]:
		out = out.replace("[color=#%s]" % col, "")
	return out


func _boot_engine() -> void:
	_append("[color=#8b9bb4]=== boot engine ===[/color]")
	_append("Godot [b]%s[/b]  movie=%s  display=%s" % [
		Engine.get_version_info().get("string", "?"), str(_movie), DisplayServer.get_name()
	])
	NRCardsBasic.register()
	NRCardsCorp.register()
	NRCardsIdentities.register()
	NRCardsEvents.register()
	NRCardsHardware.register()
	NRCardsPrograms.register()
	NRCardsResources.register()
	var titles: int = NRCardDefs.all_titles().size()
	_append("registered card titles: [b][color=#3d8bfd]%d[/color][/b]" % titles)
	_sub.text = "heuristic AIs  ·  %d card titles  ·  Godot %s" % [titles, Engine.get_version_info().get("string", "?")]
	_register_match_cards()
	_state = NRSetUp.init_game({
		"gameid": "ai-match-1",
		"skip-mulligan": true,
		"players": [
			{
				"side": "Corp",
				"user": {"username": "CorpAI"},
				"deck": {
					"identity": {"title": "Custom Biotics: Engineered for Success", "side": "Corp", "type": "Identity"},
					"cards": [
						{"qty": 6, "card": {"title": "Ice Wall"}},
						{"qty": 6, "card": {"title": "Wall of Static"}},
						{"qty": 4, "card": {"title": "Enigma"}},
						{"qty": 6, "card": {"title": "Hedge Fund"}},
						{"qty": 4, "card": {"title": "PAD Campaign"}},
						{"qty": 6, "card": {"title": "Hostile Takeover"}},
						{"qty": 4, "card": {"title": "Project Vitruvius"}},
					],
				},
			},
			{
				"side": "Runner",
				"user": {"username": "RunnerAI"},
				"deck": {
					"identity": {"title": "The Professor: Keeper of Knowledge", "side": "Runner", "type": "Identity"},
					"cards": [
						{"qty": 6, "card": {"title": "Sure Gamble"}},
						{"qty": 6, "card": {"title": "Easy Mark"}},
						{"qty": 5, "card": {"title": "Corroder"}},
						{"qty": 5, "card": {"title": "Gordian Blade"}},
					],
				},
			},
		],
	})
	if _state == null:
		_append("[color=#ff6b6b]init_game failed[/color]")
		_match_over = true
		return
	_append("[color=#8b9bb4]=== match start  CorpAI vs RunnerAI ===[/color]")
	_append("opening  corp HQ=%d ¢%d   runner grip=%d ¢%d" % [
		_state.get_in(["corp", "hand"], []).size(), _credits("corp"),
		_state.get_in(["runner", "hand"], []).size(), _credits("runner"),
	])
	_status.text = "playing…"
	_status.add_theme_color_override("font_color", GOLD)
	_sync_engine_log()
	_refresh_hud()


func _register_match_cards() -> void:
	## Printed card files are data-only (class_name collision vs translated/).
	## Override match-deck titles with working abilities, same as the smoke test.
	var etr: Dictionary = NRDefHelpers.end_the_run()
	NRCardDefs.defcard("Wall of Static", {
		"title": "Wall of Static", "type": "ICE", "side": "Corp", "faction": "Neutral",
		"cost": 3, "strength": 3, "keywords": "Barrier", "subtypes": ["Barrier"],
		"subroutines": [etr],
	})
	NRCardDefs.defcard("Ice Wall", {
		"title": "Ice Wall", "type": "ICE", "side": "Corp", "faction": "Weyland Consortium",
		"cost": 1, "strength": 1, "keywords": "Barrier", "subtypes": ["Barrier"],
		"advanceable": "always",
		"strength-boost-from-advancement": true,
		"subroutines": [etr],
	})
	NRCardDefs.defcard("Enigma", {
		"title": "Enigma", "type": "ICE", "side": "Corp", "faction": "Neutral",
		"cost": 3, "strength": 2, "keywords": "Code Gate", "subtypes": ["Code Gate"],
		"subroutines": [
			{
				"label": "The Runner loses [Click]",
				"msg": "make the Runner lose [Click]",
				"async": true,
				"effect": func(state, side, eid, _card, _t):
					NRGaining.lose(state, "runner", "click", 1)
					NREid.effect_completed(state, side, eid),
			},
			etr,
		],
	})
	NRCardDefs.defcard("Hedge Fund", {
		"title": "Hedge Fund", "type": "Operation", "side": "Corp", "faction": "Neutral",
		"cost": 5, "keywords": "Transaction", "subtypes": ["Transaction"],
		"on-play": NRDefHelpers.gain_credits_ability(9),
	})
	NRCardDefs.defcard("PAD Campaign", {
		"title": "PAD Campaign", "type": "Asset", "side": "Corp", "faction": "Neutral",
		"cost": 2, "trash": 4, "keywords": "Advertisement", "subtypes": ["Advertisement"],
		"events": [{
			"event": "corp-turn-begins",
			"msg": "gain 1 [Credits]",
			"async": true,
			"effect": func(state, side, eid, _c, _t):
				NRGaining.gain_credits(state, side, eid, 1),
		}],
	})
	NRCardDefs.defcard("Hostile Takeover", {
		"title": "Hostile Takeover", "type": "Agenda", "side": "Corp",
		"faction": "Weyland Consortium", "advancementcost": 2, "agendapoints": 1,
		"keywords": "Expansion", "subtypes": ["Expansion"],
		"on-score": NRDefHelpers.gain_credits_ability(7),
	})
	NRCardDefs.defcard("Project Vitruvius", {
		"title": "Project Vitruvius", "type": "Agenda", "side": "Corp",
		"faction": "Haas-Bioroid", "advancementcost": 3, "agendapoints": 2,
		"keywords": "Research", "subtypes": ["Research"],
	})
	NRCardDefs.defcard("Sure Gamble", {
		"title": "Sure Gamble", "type": "Event", "side": "Runner", "faction": "Neutral",
		"cost": 5, "on-play": NRDefHelpers.gain_credits_ability(9),
	})
	NRCardDefs.defcard("Easy Mark", {
		"title": "Easy Mark", "type": "Event", "side": "Runner", "faction": "Neutral",
		"cost": 0, "on-play": NRDefHelpers.gain_credits_ability(3),
	})
	NRCardDefs.defcard("Corroder", {
		"title": "Corroder", "type": "Program", "side": "Runner", "faction": "Anarch",
		"cost": 2, "memoryunits": 1, "strength": 2,
		"keywords": "Icebreaker - Fracter", "subtypes": ["Icebreaker", "Fracter"],
		"abilities": [NRCardXlate.break_sub(1, 1, "Barrier"), NRCardXlate.strength_pump(1, 1)],
	})
	NRCardDefs.defcard("Gordian Blade", {
		"title": "Gordian Blade", "type": "Program", "side": "Runner", "faction": "Shaper",
		"cost": 4, "memoryunits": 1, "strength": 2,
		"keywords": "Icebreaker - Decoder", "subtypes": ["Icebreaker", "Decoder"],
		"abilities": [NRCardXlate.break_sub(1, 1, "Code Gate"), NRCardXlate.strength_pump(1, 1)],
	})


func _step() -> void:
	if _state == null or _match_over or _idle:
		return
	if _state.getv("winner") != null:
		_on_game_over()
		return
	var turn_n := int(_state.getv("turn", 0))
	if turn_n >= MAX_TURNS and not ( _state.getv("run") is Dictionary) and _started:
		_append("[color=#f0c14b]reached turn cap (%d) — holding board until 60s[/color]" % turn_n)
		_idle = true
		_status.text = "turn cap  ·  holding final board"
		return

	_clear_stale_prompts()
	_resolve_prompts()
	if _state.getv("winner") != null:
		_on_game_over()
		return

	if _state.getv("run") is Dictionary:
		var phase := str(_state.get_in(["run", "phase"], ""))
		if phase in ["success", "approach-server"]:
			_success_waits += 1
			_run_step()
			if _success_waits > 12:
				_cmd("jack-out", "runner")
				_note("runner", "jack out (access window stall)")
				_success_waits = 0
			return
		_success_waits = 0
		_run_steps += 1
		if _run_steps > MAX_RUN_STEPS:
			_cmd("jack-out", "runner")
			_note("runner", "jack out (run step cap)")
			_run_steps = 0
			return
		_run_step()
		return
	_run_steps = 0

	var active := str(_state.getv("active-player", ""))
	var ended := NRUtil.truthy(_state.getv("end-turn", false))
	if not _started or active == "" or ended or not NRUtil.truthy(_state.get_in([active if active != "" else "corp", "turn-started"], false)):
		var nxt := "corp"
		if _started and _last_ended == "corp":
			nxt = "runner"
		elif _started and _last_ended == "runner":
			nxt = "corp"
		_cmd("start-turn", nxt)
		_started = true
		_stuck = 0
		if nxt == "runner":
			_ran_servers.clear()
		_note(nxt, "start turn %d" % int(_state.getv("turn", 0)))
		_resolve_prompts()
		return

	# Free (non-click) corp actions first.
	if active == "corp":
		if _corp_free_actions():
			_stuck = 0
			return

	var clicks := _clicks(active)
	if clicks <= 0:
		_cmd("end-turn", active)
		_last_ended = active
		_stuck = 0
		_note(active, "end turn")
		return

	var before_c := clicks
	var before_cred := _credits(active)
	var before_hand: int = _state.get_in([active, "hand"], []).size()
	if active == "corp":
		_corp_click()
	else:
		_runner_click()
	_resolve_prompts()

	if _clicks(active) == before_c and _credits(active) == before_cred and _state.get_in([active, "hand"], []).size() == before_hand and not (_state.getv("run") is Dictionary):
		_stuck += 1
		if _stuck >= 6:
			_cmd("end-turn", active)
			_last_ended = active
			_stuck = 0
			_note(active, "end turn (stuck)")
	else:
		_stuck = 0


func _corp_free_actions() -> bool:
	for agenda in _installed_agendas():
		if NRFlags.can_score(_state, "corp", agenda):
			_cmd("score", "corp", {"card": agenda})
			_note("corp", "score %s  (AP %d)" % [agenda.get("title"), _ap("corp")])
			return true
	for asset in _installed_assets():
		if NRCard.rezzed(asset):
			continue
		if _credits("corp") < int(asset.get("cost", 0)):
			continue
		_cmd("rez", "corp", {"card": asset})
		var latest = NRCard.get_card(_state, asset)
		if latest is Dictionary and NRCard.rezzed(latest):
			_note("corp", "rez %s" % asset.get("title"))
			return true
	return false


func _corp_click() -> void:
	var cred := _credits("corp")
	var clicks := _clicks("corp")

	# Economy.
	var hf = _find_in_hand("corp", "Hedge Fund")
	if hf != null and cred >= 5 and _try_play("corp", hf, "play Hedge Fund"):
		return

	# Advance almost-scored agendas first.
	for agenda in _installed_agendas():
		var need := int(NRCard.get_advancement_requirement(agenda))
		var have := NRCard.get_counters(agenda, "advancement")
		if have < need and cred >= 1:
			var before := NRCard.get_counters(agenda, "advancement")
			_cmd("advance", "corp", {"card": agenda})
			var latest = NRCard.get_card(_state, agenda)
			var after := NRCard.get_counters(latest if latest is Dictionary else agenda, "advancement")
			if after > before:
				_note("corp", "advance %s (%d/%d)" % [agenda.get("title"), after, need])
				return

	# ICE a remote that already holds an agenda (before more centrals).
	for rk in _remote_keys():
		if not _remote_has_agenda(rk):
			continue
		if _ice_n(rk) < 1:
			var ice_r = _cheapest_ice_in_hand()
			if ice_r != null:
				var srv := "Server %s" % str(rk).substr("remote".length())
				if _try_play("corp", ice_r, "install %s on %s" % [ice_r.get("title"), srv], {"server": srv}):
					return

	# Protect centrals with ICE (HQ, then R&D). Rez cost is paid later.
	if _ice_n("hq") < 2:
		var ice = _cheapest_ice_in_hand()
		if ice != null and cred >= _ice_n("hq"):
			if _try_play("corp", ice, "install %s on HQ" % ice.get("title"), {"server": "HQ"}):
				return
	if _ice_n("rd") < 1:
		var ice2 = _cheapest_ice_in_hand()
		if ice2 != null and cred >= _ice_n("rd"):
			if _try_play("corp", ice2, "install %s on R&D" % ice2.get("title"), {"server": "R&D"}):
				return

	# Install an agenda into a new remote only if HQ is already iced or we have a spare click.
	var agenda_h = _find_type_in_hand("corp", "Agenda")
	if agenda_h != null and (_ice_n("hq") >= 1 or _clicks("corp") >= 2):
		if _try_play("corp", agenda_h, "install %s in a new remote" % agenda_h.get("title"), {"server": "New remote"}):
			return

	# PAD Campaign into a new remote when rich.
	var pad = _find_in_hand("corp", "PAD Campaign")
	if pad != null and cred >= 2:
		if _try_play("corp", pad, "install PAD Campaign", {"server": "New remote"}):
			return

	# Occasional purge (3 clicks) if we still have them.
	if not _purged and clicks >= 3 and int(_state.getv("turn", 0)) >= 4:
		_cmd("purge", "corp")
		_purged = true
		_note("corp", "purge virus counters")
		return

	# Draw if HQ is thin, else click for credits.
	if _state.get_in(["corp", "hand"], []).size() < 3 and not _state.get_in(["corp", "deck"], []).is_empty():
		_cmd("draw", "corp")
		_note("corp", "draw")
		return
	_cmd("credit", "corp")
	_note("corp", "click for credit")


func _runner_click() -> void:
	var em = _find_in_hand("runner", "Easy Mark")
	if em != null and _try_play("runner", em, "play Easy Mark"):
		return

	# Steal unprotected remotes that actually have agendas (skip empty PAD farms).
	for rk in _remote_keys():
		if _ice_n(rk) == 0 and _remote_has_agenda(rk):
			var srv := "Server %s" % str(rk).substr("remote".length())
			if _try_run(rk, "run %s (unprotected agenda)" % srv):
				return
	for rk in _remote_keys():
		if _ice_n(rk) == 0 and _content_n(rk) > 0 and not _remote_has_agenda(rk):
			# Trash a rezzed asset only if we can pay typical trash costs.
			if _credits("runner") < 4:
				continue
			var srv := "Server %s" % str(rk).substr("remote".length())
			if _try_run(rk, "run %s (unprotected)" % srv):
				return

	if _installed_breaker("Fracter") == null:
		var cor = _find_in_hand("runner", "Corroder")
		if cor != null and _credits("runner") >= 2 and _try_play("runner", cor, "install Corroder"):
			return
	if _installed_breaker("Decoder") == null:
		var gb = _find_in_hand("runner", "Gordian Blade")
		if gb != null and _credits("runner") >= 4 and _try_play("runner", gb, "install Gordian Blade"):
			return

	var sg = _find_in_hand("runner", "Sure Gamble")
	if sg != null and _credits("runner") >= 5 and _try_play("runner", sg, "play Sure Gamble"):
		return

	# Lightly-iced remotes still worth a run if we have a breaker.
	if _installed_breaker("Fracter") != null or _installed_breaker("Decoder") != null:
		for rk in _remote_keys():
			if _content_n(rk) > 0 and _ice_n(rk) <= 1:
				var srv2 := "Server %s" % str(rk).substr("remote".length())
				if _try_run(rk, "run %s" % srv2):
					return
		if _credits("runner") >= 3:
			if _try_run("hq", "run HQ"):
				return
			if _try_run("rd", "run R&D"):
				return

	if _state.get_in(["runner", "hand"], []).size() < 3 and not _state.get_in(["runner", "deck"], []).is_empty():
		var hand_n: int = _state.get_in(["runner", "hand"], []).size()
		_cmd("draw", "runner")
		if _state.get_in(["runner", "hand"], []).size() != hand_n:
			_note("runner", "draw")
			return
	_cmd("credit", "runner")
	_note("runner", "click for credit")


func _run_step() -> void:
	_resolve_prompts()
	if not (_state.getv("run") is Dictionary):
		_run_steps = 0
		return
	var phase := str(_state.get_in(["run", "phase"], ""))
	if phase in ["success", "approach-server"]:
		_resolve_prompts()
		return
	var ice = NRIce.get_current_ice(_state)

	if NRRuns.get_current_encounter(_state) != null:
		_encounter_step(ice)
		return

	if phase == "approach-ice" and ice is Dictionary and not NRCard.rezzed(ice):
		var cost := int(ice.get("cost", 0))
		var server := str(NRUtil.first_of(_state.get_in(["run", "server"], ["hq"])))
		var protect_central := server in ["hq", "rd"]
		var protect_agenda := _remote_has_agenda(server)
		if (protect_central or protect_agenda or cost <= 1) and _credits("corp") >= cost:
			_cmd("rez", "corp", {"card": ice})
			_note("corp", "rez %s (approach %s)" % [ice.get("title"), server])
			return

	_cmd("continue", "corp")
	_cmd("continue", "runner")
	_resolve_prompts()


func _encounter_step(ice: Variant) -> void:
	if not (ice is Dictionary):
		_cmd("continue", "runner")
		_cmd("continue", "corp")
		return
	ice = NRCard.get_card(_state, ice)
	if not (ice is Dictionary):
		_cmd("continue", "runner")
		_cmd("continue", "corp")
		return

	if not NRIce.all_subs_broken(ice):
		_try_break(ice)
		ice = NRIce.get_current_ice(_state)
	if ice is Dictionary and not NRIce.all_subs_broken(ice):
		_cmd("unbroken-subroutines", "corp")
		_note("corp", "fire unbroken subs on %s" % ice.get("title"))
		_resolve_prompts()
		return

	_cmd("continue", "runner")
	_cmd("continue", "corp")
	_resolve_prompts()


func _try_break(ice: Dictionary) -> void:
	var breaker = _breaker_for(ice)
	if breaker == null:
		return
	breaker = NRCard.get_card(_state, breaker)
	if not (breaker is Dictionary):
		return
	var guard := 0
	while guard < 8:
		guard += 1
		ice = NRIce.get_current_ice(_state)
		breaker = NRCard.get_card(_state, breaker)
		if not (ice is Dictionary) or not (breaker is Dictionary):
			return
		if NRIce.all_subs_broken(ice):
			return
		var istr := NRIce.get_strength(ice)
		var bstr := NRIce.get_strength(breaker)
		if bstr < istr:
			if _credits("runner") < 1:
				return
			_cmd("ability", "runner", {"card": breaker, "ability": 1})
			_note("runner", "pump %s" % breaker.get("title"))
			continue
		if _credits("runner") < 1:
			return
		_cmd("ability", "runner", {"card": breaker, "ability": 0})
		_note("runner", "break with %s" % breaker.get("title"))


func _breaker_for(ice: Dictionary) -> Variant:
	if NRCard.has_subtype(ice, "Barrier"):
		return _installed_breaker("Fracter")
	if NRCard.has_subtype(ice, "Code Gate"):
		return _installed_breaker("Decoder")
	return null


func _installed_breaker(subtype: String) -> Variant:
	for c in _state.get_in(["runner", "rig", "program"], []):
		if c is Dictionary and NRCard.has_subtype(c, "Icebreaker") and NRCard.has_subtype(c, subtype):
			return c
	return null


func _resolve_prompts() -> void:
	for _i in range(8):
		var acted := false
		for side in ["corp", "runner"]:
			var prompts: Array = _state.get_in([side, "prompt"], [])
			if prompts.is_empty():
				continue
			var p: Dictionary = prompts[0]
			var ptype = p.get("prompt-type")
			if NRUtil.kw_eq(ptype, "waiting") or NRUtil.kw_eq(ptype, "run"):
				continue
			var choice = _pick_choice(side, p)
			_cmd("choice", side, {"choice": choice})
			acted = true
		if not acted:
			return


func _pick_choice(side: String, prompt: Dictionary) -> Variant:
	if NRUtil.kw_eq(prompt.get("prompt-type"), "trace"):
		return 0
	var choices = prompt.get("choices", [])
	if not (choices is Array) or choices.is_empty():
		if choices is int:
			return 0
		return "No"
	var cred := _credits(side)
	for ch in choices:
		var val = ch.get("value") if ch is Dictionary else ch
		var s := str(val)
		if s.begins_with("Pay") and cred >= 4:
			return val
		if s.to_lower().contains("steal"):
			return val
		if s.to_lower() == "yes":
			return val
	var first = choices[0]
	return first.get("value") if first is Dictionary else first


func _try_play(side: String, card: Dictionary, label: String, extra: Dictionary = {}) -> bool:
	var args := extra.duplicate(true)
	args["card"] = card
	var hand_n: int = _state.get_in([side, "hand"], []).size()
	_cmd("play", side, args)
	if _state.get_in([side, "hand"], []).size() < hand_n:
		_note(side, label)
		return true
	return false


func _try_run(server: String, label: String) -> bool:
	var key := str(server)
	if _ran_servers.has(key):
		return false
	_cmd("run", "runner", {"server": server})
	if _state.getv("run") is Dictionary:
		_ran_servers[key] = true
		_note("runner", label)
		return true
	return false


func _clear_stale_prompts() -> void:
	if _state.getv("run") is Dictionary:
		return
	for side in ["corp", "runner"]:
		_state.assoc_in([side, "prompt"], [])
		_state.assoc_in([side, "prompt-state"], null)


func _cmd(command: String, side: String, args: Dictionary = {}) -> bool:
	_actions += 1
	var ok := NRProcessActions.process_action(command, _state, side, args)
	_sync_engine_log()
	return ok


func _note(side: String, msg: String) -> void:
	var col := CORP_COL if side == "corp" else RUNNER_COL
	var tag := "CORP" if side == "corp" else "RUNNER"
	_append("[color=#%s][%s AI][/color] %s" % [col.to_html(false), tag, msg])


func _sync_engine_log() -> void:
	if _state == null:
		return
	var logv = _state.getv("log", [])
	if not (logv is Array):
		return
	if logv.size() <= _log_count:
		_log_count = mini(_log_count, logv.size())
		return
	for i in range(_log_count, logv.size()):
		var entry = logv[i]
		var msg = entry
		if entry is Dictionary and entry.has("public"):
			msg = entry["public"]
		var text := ""
		if msg is Dictionary:
			text = str(msg.get("text", ""))
		else:
			text = str(msg)
		if text.strip_edges() == "":
			continue
		var col := MUTED
		if text.contains("scores") or text.contains("steals"):
			col = GOLD
		elif text.contains("CorpAI"):
			col = CORP_COL
		elif text.contains("RunnerAI"):
			col = RUNNER_COL
		_append("[color=#%s]%s[/color]" % [col.to_html(false), text])
	_log_count = logv.size()


func _refresh_hud() -> void:
	if _state == null:
		_hud.text = "[color=#8b9bb4]booting…[/color]"
		return
	var ap_c := _ap("corp")
	var ap_r := _ap("runner")
	var active := str(_state.getv("active-player", "—"))
	var turn_n := int(_state.getv("turn", 0))
	var run_s := ""
	if _state.getv("run") is Dictionary:
		run_s = "  [color=#f0c14b]RUN %s %s[/color]" % [
			NRServers.zone_to_name(_state.get_in(["run", "server"])),
			str(_state.get_in(["run", "phase"], "")),
		]
	_hud.text = "[b][color=#5ec8ff]CORP[/color][/b] ¢[b]%d[/b]  ●[b]%d[/b]  AP [b][color=#f0c14b]%d[/color][/b]/7    [b][color=#3dd68c]RUNNER[/color][/b] ¢[b]%d[/b]  ●[b]%d[/b]  AP [b][color=#f0c14b]%d[/color][/b]/7\n[color=#8b9bb4]turn %d  active=%s  t=%.1fs  actions=%d[/color]%s" % [
		_credits("corp"), _clicks("corp"), ap_c,
		_credits("runner"), _clicks("runner"), ap_r,
		turn_n, active, _game_time, _actions, run_s,
	]
	_board.text = _board_line()


func _board_line() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for key in ["hq", "rd", "archives"]:
		var ices: Array = _state.get_in(["corp", "servers", key, "ices"], [])
		var names: PackedStringArray = PackedStringArray()
		for ice in ices:
			if ice is Dictionary:
				var mark := "*" if NRCard.rezzed(ice) else ""
				names.append("%s%s" % [str(ice.get("title")), mark])
		var label := "HQ" if key == "hq" else ("R&D" if key == "rd" else "Archives")
		parts.append("%s[%s]" % [label, ", ".join(names) if names.size() > 0 else "—"])
	for rk in _remote_keys():
		var content: Array = _state.get_in(["corp", "servers", rk, "content"], [])
		var ices2: Array = _state.get_in(["corp", "servers", rk, "ices"], [])
		var cnames: PackedStringArray = PackedStringArray()
		for c in content:
			if c is Dictionary:
				cnames.append(str(c.get("title")))
		var inames: PackedStringArray = PackedStringArray()
		for ice in ices2:
			if ice is Dictionary:
				inames.append(str(ice.get("title")))
		parts.append("R%s ice[%s] root[%s]" % [
			str(rk).substr("remote".length()),
			", ".join(inames) if inames.size() > 0 else "—",
			", ".join(cnames) if cnames.size() > 0 else "—",
		])
	var progs: PackedStringArray = PackedStringArray()
	for p in _state.get_in(["runner", "rig", "program"], []):
		if p is Dictionary:
			progs.append(str(p.get("title")))
	parts.append("Rig[%s]" % (", ".join(progs) if progs.size() > 0 else "—"))
	var scored_c: PackedStringArray = PackedStringArray()
	for a in _state.get_in(["corp", "scored"], []):
		if a is Dictionary:
			scored_c.append(str(a.get("title")))
	var scored_r: PackedStringArray = PackedStringArray()
	for a in _state.get_in(["runner", "scored"], []):
		if a is Dictionary:
			scored_r.append(str(a.get("title")))
	parts.append("Corp scored[%s]" % (", ".join(scored_c) if scored_c.size() > 0 else "—"))
	parts.append("Runner scored[%s]" % (", ".join(scored_r) if scored_r.size() > 0 else "—"))
	return "  ·  ".join(parts)


func _on_game_over() -> void:
	if _match_over:
		return
	_match_over = true
	_idle = true
	var winner := str(_state.getv("winner", "?"))
	var reason := str(_state.getv("reason", "?"))
	_append("[b][color=#f0c14b]GAME OVER — %s wins (%s)[/color][/b]" % [winner.to_upper(), reason])
	_status.text = "GAME OVER  ·  %s wins (%s)" % [winner, reason]
	_status.add_theme_color_override("font_color", GOLD)
	_dump_summary("game-over")


func _finish(why: String) -> void:
	if not _summary_written:
		if _state != null and _state.getv("winner") != null:
			_on_game_over()
		else:
			_append("[color=#8b9bb4]match window closed (%s)  turn=%d  t=%.1fs[/color]" % [
				why, int(_state.getv("turn", 0)) if _state != null else 0, _game_time
			])
			_status.text = "complete  ·  %s" % why
			_status.add_theme_color_override("font_color", RUNNER_COL)
			_dump_summary(why)
	get_tree().quit(0)


func _dump_summary(why: String) -> void:
	if _summary_written:
		return
	_summary_written = true
	var winner := str(_state.getv("winner", "")) if _state != null else ""
	var reason := str(_state.getv("reason", "")) if _state != null else ""
	var ahead := "tied"
	if _state != null:
		if _ap("corp") > _ap("runner"):
			ahead = "corp"
		elif _ap("runner") > _ap("corp"):
			ahead = "runner"
	var text := "=== AI MATCH SUMMARY ===\n"
	text += "godot=%s\n" % Engine.get_version_info().get("string", "?")
	text += "why=%s\n" % why
	text += "turns=%d\n" % (int(_state.getv("turn", 0)) if _state != null else 0)
	text += "actions=%d\n" % _actions
	text += "game_time=%.2f\n" % _game_time
	if _state != null:
		text += "corp_credits=%d corp_clicks=%d corp_ap=%d corp_hand=%d\n" % [
			_credits("corp"), _clicks("corp"), _ap("corp"), _state.get_in(["corp", "hand"], []).size()
		]
		text += "runner_credits=%d runner_clicks=%d runner_ap=%d runner_hand=%d runner_mu=%s\n" % [
			_credits("runner"), _clicks("runner"), _ap("runner"),
			_state.get_in(["runner", "hand"], []).size(), str(_state.get_in(["runner", "memory"], "")),
		]
		text += "winner=%s reason=%s ahead=%s\n" % [winner, reason, ahead]
		text += "corp_scored=%s\n" % _titles_in(_state.get_in(["corp", "scored"], []))
		text += "runner_scored=%s\n" % _titles_in(_state.get_in(["runner", "scored"], []))
	print(text)
	var f := FileAccess.open("/tmp/ai_match_summary.txt", FileAccess.WRITE)
	if f:
		f.store_string(text)
		f.close()


func _titles_in(arr: Array) -> String:
	var names: PackedStringArray = PackedStringArray()
	for c in arr:
		if c is Dictionary:
			names.append(str(c.get("title")))
	return ", ".join(names)


func _credits(side: String) -> int:
	return int(_state.get_in([side, "credit"], 0))


func _clicks(side: String) -> int:
	return int(_state.get_in([side, "click"], 0))


func _ap(side: String) -> int:
	return int(_state.get_in([side, "agenda-point"], 0))


func _ice_n(server: String) -> int:
	return _state.get_in(["corp", "servers", server, "ices"], []).size()


func _content_n(server: String) -> int:
	return _state.get_in(["corp", "servers", server, "content"], []).size()


func _remote_keys() -> Array:
	var out: Array = []
	var servers = _state.get_in(["corp", "servers"], {})
	if servers is Dictionary:
		for k in servers.keys():
			if str(k).begins_with("remote"):
				out.append(str(k))
	out.sort()
	return out


func _remote_has_agenda(rk: String) -> bool:
	for c in _state.get_in(["corp", "servers", rk, "content"], []):
		if c is Dictionary and NRCard.agenda(c):
			return true
	return false


func _installed_agendas() -> Array:
	var out: Array = []
	for rk in _remote_keys():
		for c in _state.get_in(["corp", "servers", rk, "content"], []):
			if c is Dictionary and NRCard.agenda(c) and NRCard.installed(c):
				out.append(c)
	return out


func _installed_assets() -> Array:
	var out: Array = []
	for rk in _remote_keys():
		for c in _state.get_in(["corp", "servers", rk, "content"], []):
			if c is Dictionary and NRCard.asset(c) and NRCard.installed(c):
				out.append(c)
	return out


func _find_in_hand(side: String, title: String) -> Variant:
	for c in _state.get_in([side, "hand"], []):
		if c is Dictionary and str(c.get("title")) == title:
			return c
	return null


func _find_type_in_hand(side: String, typ: String) -> Variant:
	for c in _state.get_in([side, "hand"], []):
		if c is Dictionary and str(c.get("type")) == typ:
			return c
	return null


func _cheapest_ice_in_hand() -> Variant:
	var best: Variant = null
	var best_cost := 999
	for c in _state.get_in(["corp", "hand"], []):
		if not (c is Dictionary) or not NRCard.ice(c):
			continue
		var cost := int(c.get("cost", 0))
		if cost < best_cost:
			best = c
			best_cost = cost
	return best
