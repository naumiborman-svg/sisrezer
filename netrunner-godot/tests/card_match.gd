extends "res://tests/ai_match.gd"
## Visual AI-vs-AI match: same heuristic AIs as ai_match.gd, plus a card HUD.
## Card faces are built at runtime from NRCardDefs.card_def / server_card.

const CardFace := preload("res://tests/card_face.gd")

const VISUAL_STEP := 0.55
const CARD_HOLD := 0.50
const INTRO_CORP := 1.15
const INTRO_RUNNER := 2.30
const PLAY_SHOT := "res://screenshots/card_match_play.png"
const OVER_SHOT := "res://screenshots/card_match_gameover.png"

var _spot_host: Control
var _spot_card: NRCardFace
var _effect_banner: ColorRect
var _effect_lbl: Label
var _effect_sub: Label
var _corp_bar: RichTextLabel
var _runner_bar: RichTextLabel
var _run_banner: Label
var _over_layer: ColorRect
var _over_lbl: Label
var _corp_hist: HFlowContainer
var _runner_hist: HFlowContainer
var _board_row: HBoxContainer
var _header: Label
var _event_log: PackedStringArray = PackedStringArray()

var _title_index: PackedStringArray = PackedStringArray()
var _corp_shown: Dictionary = {}
var _runner_shown: Dictionary = {}
var _pulse := 0.0
var _just_card := false
var _play_shot_done := false
var _over_shot_done := false
var _last_spot_title := ""
var _cards_seen := 0


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mono = _load_mono()

	var bg := ColorRect.new()
	bg.color = Color("07090e")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var grid := ColorRect.new()
	grid.color = Color("0c121c")
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid.offset_left = 0
	grid.offset_top = 52
	grid.offset_right = 0
	grid.offset_bottom = -148
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grid)

	_header = Label.new()
	_header.text = "CARD MATCH  ·  heuristic AIs  ·  Godot %s" % Engine.get_version_info().get("string", "?")
	_header.position = Vector2(16, 6)
	_header.size = Vector2(900, 20)
	_header.add_theme_font_override("font", _mono)
	_header.add_theme_font_size_override("font_size", 13)
	_header.add_theme_color_override("font_color", ACCENT)
	add_child(_header)

	_sub = Label.new()
	_sub.text = "faces from NRCardDefs at runtime"
	_sub.position = Vector2(920, 6)
	_sub.size = Vector2(340, 20)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_sub.add_theme_font_override("font", _mono)
	_sub.add_theme_font_size_override("font_size", 12)
	_sub.add_theme_color_override("font_color", MUTED)
	add_child(_sub)

	_corp_bar = RichTextLabel.new()
	_corp_bar.bbcode_enabled = true
	_corp_bar.scroll_active = false
	_corp_bar.fit_content = false
	_corp_bar.position = Vector2(12, 28)
	_corp_bar.size = Vector2(1256, 28)
	_style_rtl(_corp_bar, 14)
	add_child(_corp_bar)

	_runner_bar = RichTextLabel.new()
	_runner_bar.bbcode_enabled = true
	_runner_bar.scroll_active = false
	_runner_bar.fit_content = false
	_runner_bar.position = Vector2(12, 668)
	_runner_bar.size = Vector2(1256, 24)
	_style_rtl(_runner_bar, 14)
	add_child(_runner_bar)

	# Dummy nodes the parent AI controller still writes to.
	_hud = RichTextLabel.new()
	_hud.visible = false
	add_child(_hud)
	_board = Label.new()
	_board.visible = false
	add_child(_board)
	_status = Label.new()
	_status.visible = false
	add_child(_status)

	var left := Control.new()
	left.position = Vector2(10, 56)
	left.size = Vector2(318, 552)
	add_child(left)
	var left_cap := _cap("CORP PLAYED")
	left_cap.position = Vector2(0, 0)
	left.add_child(left_cap)
	_corp_hist = HFlowContainer.new()
	_corp_hist.position = Vector2(0, 22)
	_corp_hist.size = Vector2(318, 496)
	_corp_hist.add_theme_constant_override("h_separation", 6)
	_corp_hist.add_theme_constant_override("v_separation", 6)
	left.add_child(_corp_hist)

	var right := Control.new()
	right.position = Vector2(952, 56)
	right.size = Vector2(318, 552)
	add_child(right)
	var right_cap := _cap("RUNNER PLAYED")
	right_cap.position = Vector2(0, 0)
	right_cap.add_theme_color_override("font_color", RUNNER_COL)
	right.add_child(right_cap)
	_runner_hist = HFlowContainer.new()
	_runner_hist.position = Vector2(0, 22)
	_runner_hist.size = Vector2(318, 496)
	_runner_hist.add_theme_constant_override("h_separation", 6)
	_runner_hist.add_theme_constant_override("v_separation", 6)
	right.add_child(_runner_hist)

	_spot_host = Control.new()
	_spot_host.position = Vector2(430, 52)
	_spot_host.size = Vector2(420, 560)
	_spot_host.pivot_offset = Vector2(210, 280)
	add_child(_spot_host)
	_spot_card = CardFace.new()
	_spot_host.add_child(_spot_card)
	_spot_card.configure(_placeholder_cdef("Awaiting first card"), _mono, CardFace.Mode.SPOTLIGHT)

	_effect_banner = ColorRect.new()
	_effect_banner.color = Color("1a1408")
	_effect_banner.position = Vector2(430, 616)
	_effect_banner.size = Vector2(420, 48)
	add_child(_effect_banner)
	var ebar := ColorRect.new()
	ebar.color = GOLD
	ebar.position = Vector2(0, 0)
	ebar.size = Vector2(420, 3)
	_effect_banner.add_child(ebar)
	_effect_lbl = Label.new()
	_effect_lbl.text = "EFFECT"
	_effect_lbl.position = Vector2(10, 6)
	_effect_lbl.size = Vector2(400, 16)
	_effect_lbl.add_theme_font_override("font", _mono)
	_effect_lbl.add_theme_font_size_override("font_size", 11)
	_effect_lbl.add_theme_color_override("font_color", GOLD)
	_effect_banner.add_child(_effect_lbl)
	_effect_sub = Label.new()
	_effect_sub.text = "match starting…"
	_effect_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_effect_sub.position = Vector2(10, 20)
	_effect_sub.size = Vector2(400, 26)
	_effect_sub.add_theme_font_override("font", _mono)
	_effect_sub.add_theme_font_size_override("font_size", 15)
	_effect_sub.add_theme_color_override("font_color", Color("fff4d0"))
	_effect_banner.add_child(_effect_sub)

	_run_banner = Label.new()
	_run_banner.position = Vector2(430, 50)
	_run_banner.size = Vector2(420, 16)
	_run_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_run_banner.add_theme_font_override("font", _mono)
	_run_banner.add_theme_font_size_override("font_size", 12)
	_run_banner.add_theme_color_override("font_color", GOLD)
	add_child(_run_banner)

	_board_row = HBoxContainer.new()
	_board_row.visible = false
	add_child(_board_row)

	_log_label = RichTextLabel.new()
	_log_label.bbcode_enabled = true
	_log_label.scroll_following = true
	_log_label.scroll_active = false
	_log_label.fit_content = false
	_log_label.position = Vector2(12, 694)
	_log_label.size = Vector2(1256, 100)
	_style_rtl(_log_label, 12)
	_log_label.add_theme_constant_override("line_separation", -2)
	add_child(_log_label)

	_over_layer = ColorRect.new()
	_over_layer.color = Color(0.03, 0.04, 0.07, 0.82)
	_over_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_over_layer.visible = false
	_over_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_over_layer)
	_over_lbl = Label.new()
	_over_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_over_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_over_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_over_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_over_lbl.add_theme_font_override("font", _mono)
	_over_lbl.add_theme_font_size_override("font_size", 28)
	_over_lbl.add_theme_color_override("font_color", GOLD)
	_over_layer.add_child(_over_lbl)


func _style_rtl(rtl: RichTextLabel, px: int) -> void:
	rtl.add_theme_font_override("normal_font", _mono)
	rtl.add_theme_font_override("bold_font", _mono)
	rtl.add_theme_font_override("mono_font", _mono)
	rtl.add_theme_font_size_override("normal_font_size", px)
	rtl.add_theme_font_size_override("bold_font_size", px)
	rtl.add_theme_font_size_override("mono_font_size", px)
	rtl.add_theme_color_override("default_color", TEXT)


func _cap(txt: String) -> Label:
	var l := Label.new()
	l.text = txt
	l.size = Vector2(200, 18)
	l.add_theme_font_override("font", _mono)
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", CORP_COL)
	return l


func _placeholder_cdef(title: String) -> Dictionary:
	return {
		"title": title,
		"type": "Identity",
		"side": "Corp",
		"faction": "Neutral",
		"text": "Booting engine and loading printed card faces from NRCardDefs.",
	}


func _boot_engine() -> void:
	super._boot_engine()
	_rebuild_title_index()
	_header.text = "CARD MATCH  ·  %d titles in NRCardDefs  ·  Godot %s" % [
		_title_index.size(), Engine.get_version_info().get("string", "?")
	]
	_spotlight("Custom Biotics: Engineered for Success", "corp", "Match start — Corp identity")


func _rebuild_title_index() -> void:
	_title_index = PackedStringArray()
	for t in NRCardDefs.all_titles():
		_title_index.append(str(t))
	# Longest first so "Wall of Static" wins over "Wall".
	var arr: Array = []
	for t in _title_index:
		arr.append(t)
	arr.sort_custom(func(a, b): return str(a).length() > str(b).length())
	_title_index = PackedStringArray()
	for t in arr:
		_title_index.append(str(t))


func _process(delta: float) -> void:
	_game_time += delta
	if _pulse > 0.0:
		_pulse = maxf(0.0, _pulse - delta * 3.2)
		var s := 1.0 + 0.09 * _pulse
		_spot_host.scale = Vector2(s, s)
		_spot_host.modulate = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(1.35, 1.22, 0.85, 1.0), _pulse)
	else:
		_spot_host.scale = Vector2.ONE
		_spot_host.modulate = Color.WHITE
	_refresh_hud()
	if _is_fast():
		if _idle or _match_over or _game_time >= MATCH_SECONDS:
			_finish("fast")
			return
		var guard := 0
		while not _idle and not _match_over and guard < 40:
			_step()
			guard += 1
		return
	if not _play_shot_done and _cards_seen >= 3 and _game_time >= 16.0 and _last_spot_title != "" and not _last_spot_title.begins_with("The Professor") and not _last_spot_title.begins_with("Custom Biotics") and not _over_layer.visible:
		_capture(PLAY_SHOT)
		_play_shot_done = true
	if _game_time >= MATCH_SECONDS - 3.6:
		if not _over_layer.visible:
			_prepare_over("time")
		if not _over_shot_done and _game_time >= MATCH_SECONDS - 1.6:
			_capture(OVER_SHOT)
			_over_shot_done = true
	if _game_time >= MATCH_SECONDS:
		_finish("time")
		return
	if _idle or _match_over:
		return
	# Intro: swap to runner identity before the AI loop starts.
	if _game_time >= INTRO_CORP and _game_time < INTRO_RUNNER and _last_spot_title != "The Professor: Keeper of Knowledge":
		_spotlight("The Professor: Keeper of Knowledge", "runner", "Match start — Runner identity")
		return
	if _game_time < INTRO_RUNNER:
		return
	if _game_time >= _next_step:
		_step()
		var extra := CARD_HOLD if _just_card else 0.0
		_just_card = false
		_next_step = _game_time + VISUAL_STEP + extra


func _append(bb: String) -> void:
	_ai_lines.append(bb)
	if _ai_lines.size() > 6:
		_ai_lines = _ai_lines.slice(_ai_lines.size() - 6)
	_rebuild_log()
	print(_strip_bb(bb))


func _note(side: String, msg: String) -> void:
	super._note(side, msg)
	_maybe_card_event(side, msg, "")


func _sync_engine_log() -> void:
	var before := _log_count
	super._sync_engine_log()
	if _state == null:
		return
	var logv = _state.getv("log", [])
	if not (logv is Array) or logv.size() <= before:
		return
	for i in range(before, logv.size()):
		var text := _log_text(logv[i])
		if text == "":
			continue
		_maybe_card_event(_side_of_log(text), text, text)


func _log_text(entry: Variant) -> String:
	var msg = entry
	if entry is Dictionary and entry.has("public"):
		msg = entry["public"]
	if msg is Dictionary:
		return str(msg.get("text", "")).strip_edges()
	return str(msg).strip_edges()


func _side_of_log(text: String) -> String:
	if text.contains("RunnerAI") or text.begins_with("Runner"):
		return "runner"
	return "corp"


func _maybe_card_event(side: String, msg: String, engine_text: String) -> void:
	var title := _title_in(msg)
	var effect := _summarize(msg, title, engine_text)
	if title == "":
		if effect != "":
			_set_effect(effect)
		return
	var low := msg.to_lower()
	var interesting := (
		low.contains("play") or low.contains("install") or low.contains("rez")
		or low.contains("score") or low.contains("steal") or low.contains("break")
		or low.contains("pump") or low.contains("uses ") or low.contains("advance")
		or low.contains("subroutine") or low.contains("gain")
	)
	if not interesting:
		return
	_spotlight(title, side, effect if effect != "" else _default_effect(msg, title))


func _title_in(msg: String) -> String:
	for t in _title_index:
		if t == "Corp Basic Action Card" or t == "Runner Basic Action Card":
			continue
		if msg.contains(t):
			return t
	return ""


func _summarize(msg: String, title: String, engine_text: String) -> String:
	var src := engine_text if engine_text != "" else msg
	var low := src.to_lower()
	if low.contains("steal"):
		var ap := 0
		var cdef := lookup_cdef(title) if title != "" else {}
		ap = int(cdef.get("agendapoints", cdef.get("agenda-point", 0)))
		if ap <= 0:
			ap = _ap("runner")
		return "Steal agenda: +%d AP" % ap
	if low.contains("score"):
		var cdef2 := lookup_cdef(title) if title != "" else {}
		var ap2 := int(cdef2.get("agendapoints", cdef2.get("agenda-point", 0)))
		if title == "Hostile Takeover":
			return "Score agenda: +%d AP  ·  Gain 7 credits" % (ap2 if ap2 > 0 else 1)
		return "Score agenda: +%d AP" % ap2
	var gain := _extract_gain(src)
	if gain > 0:
		return "Gain %d credits" % gain
	if low.contains("break"):
		return "Break subroutine"
	if low.contains("pump"):
		return "Pump strength"
	if low.contains("unbroken") or (low.contains("subroutine") and low.contains("end the run")):
		return "Resolve subroutine"
	if low.contains("end the run"):
		return "End the run"
	if low.begins_with("play ") or low.contains(" to play ") or low.contains("spend") and low.contains("play"):
		return _play_effect(title)
	if low.contains("rez"):
		return "Rez"
	if low.contains("install"):
		return "Install"
	if low.contains("advance"):
		return "Advance agenda"
	if low.contains("uses ") and title != "":
		return CardFace.pretty_text(str(lookup_cdef(title).get("text", "Card effect")))
	return ""


func _extract_gain(src: String) -> int:
	var re := RegEx.new()
	if re.compile("gain(?:s)?\\s+(\\d+)\\s*\\[?credits?\\]?") != OK:
		return 0
	var m := re.search(src.to_lower().replace("[credit]", "credit"))
	if m:
		return int(m.get_string(1))
	return 0


func _play_effect(title: String) -> String:
	match title:
		"Hedge Fund", "Sure Gamble":
			return "Gain 9 credits"
		"Easy Mark":
			return "Gain 3 credits"
		"PAD Campaign":
			return "Install asset — when Corp turn begins: Gain 1 credit"
		_:
			var cdef := lookup_cdef(title)
			var t := CardFace.pretty_text(str(cdef.get("text", "")).strip_edges())
			if t != "":
				var first := t.split("\n")[0]
				if first.length() > 64:
					first = first.substr(0, 61) + "…"
				return first
			return "Play %s" % title


func _default_effect(msg: String, title: String) -> String:
	var s := _summarize(msg, title, "")
	if s != "":
		return s
	return msg


func _set_effect(text: String) -> void:
	_effect_sub.text = text
	_effect_lbl.text = "EFFECT"
	_flash()


func _spotlight(title: String, side: String, effect: String) -> void:
	var cdef := lookup_cdef(title)
	if cdef.is_empty():
		return
	_spot_card.configure(cdef, _mono, CardFace.Mode.SPOTLIGHT)
	_last_spot_title = title
	if effect != "":
		_effect_sub.text = effect
	_flash()
	_just_card = true
	_add_history(cdef, side)
	_cards_seen += 1
	var line := "t=%05.2fs  [%s]  %s  |  %s" % [_game_time, side, title, effect]
	_event_log.append(line)
	print("SPOT %s" % line)


func _flash() -> void:
	_pulse = 1.0


func _add_history(cdef: Dictionary, side: String) -> void:
	var title := str(cdef.get("title", ""))
	var bucket := _corp_shown if side == "corp" else _runner_shown
	var host := _corp_hist if side == "corp" else _runner_hist
	if bucket.has(title):
		return
	if host.get_child_count() >= 8:
		return
	bucket[title] = true
	var mini := CardFace.new()
	mini.configure(cdef, _mono, CardFace.Mode.HISTORY)
	host.add_child(mini)


func lookup_cdef(title: String) -> Dictionary:
	## Printed faces live in NRCardDefs.server_card (first registration keeps
	## `text`). Gameplay overrides in `_defs` via card_def() may drop `text`,
	## so merge: printed as base, then fill blanks from the live def.
	if title == "":
		return {}
	var printed: Dictionary = NRCardDefs.server_card(title)
	var live: Dictionary = NRCardDefs.card_def({"title": title})
	var out: Dictionary = printed.duplicate(true) if not printed.is_empty() else {}
	if live.is_empty() and out.is_empty():
		return {"title": title, "type": "Card", "faction": "Neutral", "text": ""}
	for k in live.keys():
		var v = live[k]
		if v is Callable:
			continue
		if not out.has(k) or out[k] == null or (out[k] is String and str(out[k]).strip_edges() == ""):
			if not (v is Dictionary and (v.has("effect") or v.has("async"))):
				out[k] = v
	out["title"] = title
	return out


func _refresh_hud() -> void:
	if _state == null:
		_corp_bar.text = "[color=#8b9bb4]booting…[/color]"
		return
	var run_s := ""
	if _state.getv("run") is Dictionary:
		run_s = "RUN %s · %s" % [
			NRServers.zone_to_name(_state.get_in(["run", "server"])),
			str(_state.get_in(["run", "phase"], "")),
		]
	_run_banner.text = run_s
	var corp_scored := _titles_in(_state.get_in(["corp", "scored"], []))
	var runner_scored := _titles_in(_state.get_in(["runner", "scored"], []))
	_corp_bar.text = "[b][color=#e85d4c]CORP[/color][/b]  Custom Biotics   ¢[b]%d[/b]  ●[b]%d[/b]  HQ [b]%d[/b]  AP [b][color=#f0c14b]%d[/color][/b]/7  scored: %s" % [
		_credits("corp"), _clicks("corp"), _state.get_in(["corp", "hand"], []).size(), _ap("corp"),
		corp_scored if corp_scored != "" else "—",
	]
	_runner_bar.text = "[b][color=#2ec4b6]RUNNER[/color][/b]  The Professor   ¢[b]%d[/b]  ●[b]%d[/b]  grip [b]%d[/b]  AP [b][color=#f0c14b]%d[/color][/b]/7  scored: %s" % [
		_credits("runner"), _clicks("runner"), _state.get_in(["runner", "hand"], []).size(), _ap("runner"),
		runner_scored if runner_scored != "" else "—",
	]


func _refresh_board_row() -> void:
	if _board_row == null or _state == null:
		return
	for c in _board_row.get_children():
		c.queue_free()
	var chips: PackedStringArray = PackedStringArray()
	for key in ["hq", "rd"]:
		var label := "HQ" if key == "hq" else "R&D"
		var ices: Array = _state.get_in(["corp", "servers", key, "ices"], [])
		for ice in ices:
			if ice is Dictionary:
				var mark := "*" if NRCard.rezzed(ice) else ""
				chips.append("%s:%s%s" % [label, str(ice.get("title")), mark])
	for rk in _remote_keys():
		for c in _state.get_in(["corp", "servers", rk, "content"], []):
			if c is Dictionary:
				chips.append("R%s:%s" % [str(rk).substr("remote".length()), str(c.get("title"))])
		for ice in _state.get_in(["corp", "servers", rk, "ices"], []):
			if ice is Dictionary:
				var mark2 := "*" if NRCard.rezzed(ice) else ""
				chips.append("R%s:%s%s" % [str(rk).substr("remote".length()), str(ice.get("title")), mark2])
	for p in _state.get_in(["runner", "rig", "program"], []):
		if p is Dictionary:
			chips.append("Rig:%s" % str(p.get("title")))
	var n := 0
	for chip in chips:
		if n >= 10:
			break
		n += 1
		var lbl := Label.new()
		lbl.text = chip
		lbl.add_theme_font_override("font", _mono)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", MUTED)
		_board_row.add_child(lbl)


func _on_game_over() -> void:
	if _match_over:
		return
	super._on_game_over()
	_show_over("GAME OVER\n%s wins  (%s)\nCorp AP %d   ·   Runner AP %d" % [
		str(_state.getv("winner", "?")).to_upper(),
		str(_state.getv("reason", "?")),
		_ap("corp"), _ap("runner"),
	])


func _prepare_over(why: String) -> void:
	if _over_layer.visible:
		return
	if _state != null and _state.getv("winner") != null:
		_on_game_over()
		return
	var ahead := "TIED"
	if _state != null:
		if _ap("corp") > _ap("runner"):
			ahead = "CORP AHEAD"
		elif _ap("runner") > _ap("corp"):
			ahead = "RUNNER AHEAD"
	var cap := _ap("corp") if _state != null else 0
	var rap := _ap("runner") if _state != null else 0
	var turn_n := int(_state.getv("turn", 0)) if _state != null else 0
	_show_over("MATCH COMPLETE  ·  %s\n%s\nCorp AP %d   ·   Runner AP %d\nturn %d  ·  t=%.0fs" % [
		why, ahead, cap, rap, turn_n, _game_time,
	])


func _finish(why: String) -> void:
	_prepare_over(why)
	if not _play_shot_done:
		_capture(PLAY_SHOT)
		_play_shot_done = true
	if not _over_shot_done:
		_capture(OVER_SHOT)
		_over_shot_done = true
	if not _summary_written:
		_dump_summary(why)
	_write_event_log()
	get_tree().quit(0)


func _write_event_log() -> void:
	var f := FileAccess.open("/tmp/card_match_spot.txt", FileAccess.WRITE)
	if f:
		f.store_string("\n".join(_event_log) + "\n")
		f.close()


func _show_over(text: String) -> void:
	_over_layer.visible = true
	_over_lbl.text = text


func _capture(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://screenshots"))
	var tex := get_viewport().get_texture()
	if tex == null:
		print("capture skipped (no viewport) %s" % path)
		return
	var img := tex.get_image()
	if img == null:
		print("capture skipped (no image) %s" % path)
		return
	var err := img.save_png(path)
	print("screenshot %s %dx%d err=%s" % [path, img.get_width(), img.get_height(), err])
