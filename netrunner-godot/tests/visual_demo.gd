extends Control
## Visual smoke-test demo: runs the same flow as tests/headless_sim.gd and
## renders the live game log into a terminal-style UI, then captures a PNG.

const BG := Color("0a0e14")
const ACCENT := Color("3d8bfd")
const OK_COL := Color("3dd68c")
const FAIL_COL := Color("ff6b6b")
const MUTED := Color("8b9bb4")
const TEXT := Color("d7e3f4")
const HEADER := "NETRUNNER-GODOT — Godot 4.7.2"
const FONT_PATH := "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
const SHOT_PATH := "res://screenshots/demo_run.png"

var _ok := true
var _failures: PackedStringArray = PackedStringArray()
var _log_label: RichTextLabel
var _status: Label
var _mono: Font
var _state: NRState


func _ready() -> void:
	if DisplayServer.get_name() != "headless" and get_window() != null:
		get_window().size = Vector2i(1280, 800)
	_build_ui()
	await get_tree().process_frame
	_run_smoke()
	_status.text = "SMOKE TEST PASSED" if _ok else "SMOKE TEST FAILED"
	_status.add_theme_color_override("font_color", OK_COL if _ok else FAIL_COL)
	# Let the viewport paint the full log before capturing pixels.
	for _i in range(4):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	await get_tree().create_timer(4.0).timeout
	await RenderingServer.frame_post_draw
	_capture_and_quit()


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
	vbox.offset_top = 16
	vbox.offset_right = -20
	vbox.offset_bottom = -16
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	var header := Label.new()
	header.text = HEADER
	header.add_theme_font_override("font", _mono)
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", ACCENT)
	vbox.add_child(header)

	var sub := Label.new()
	sub.text = "Live engine log  ·  mtgred/netrunner GDScript port  ·  Godot %s" % Engine.get_version_info().get("string", "?")
	sub.add_theme_font_override("font", _mono)
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", MUTED)
	vbox.add_child(sub)

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
	_status.text = "running…"
	_status.add_theme_font_override("font", _mono)
	_status.add_theme_font_size_override("font_size", 18)
	_status.add_theme_color_override("font_color", MUTED)
	vbox.add_child(_status)


func _load_mono() -> Font:
	if FileAccess.file_exists(FONT_PATH):
		var ff := FontFile.new()
		var err := ff.load_dynamic_font(FONT_PATH)
		if err == OK:
			return ff
	return ThemeDB.fallback_font


func _append(bb: String) -> void:
	_log_label.append_text(bb + "\n")
	print(bb.replace("[b]", "").replace("[/b]", "").replace("[color=#3dd68c]", "").replace("[color=#ff6b6b]", "").replace("[color=#8b9bb4]", "").replace("[color=#d7e3f4]", "").replace("[color=#3d8bfd]", "").replace("[/color]", "").replace("[code]", "").replace("[/code]", ""))


func _run_smoke() -> void:
	_append("[color=#8b9bb4]=== boot engine ===[/color]")
	_append("Godot [b]%s[/b]" % Engine.get_version_info().get("string", "?"))
	NRCardsBasic.register()
	NRCardsCorp.register()
	NRCardsIdentities.register()
	NRCardsEvents.register()
	NRCardsHardware.register()
	NRCardsPrograms.register()
	NRCardsResources.register()
	var titles: int = NRCardDefs.all_titles().size()
	_append("registered card titles: [b][color=#3d8bfd]%d[/color][/b]" % titles)
	if _log_label.get_parent() != null:
		for child in _log_label.get_parent().get_children():
			if child is Label and str(child.text).begins_with("Live engine log"):
				child.text = "Live engine log  ·  %d card titles registered  ·  Godot %s" % [titles, Engine.get_version_info().get("string", "?")]
				break
	_register_stubs()
	var state: NRState = NRSetUp.init_game({
		"gameid": "smoke-1",
		"skip-mulligan": true,
		"players": [
			{
				"side": "Corp",
				"user": {"username": "SmokeCorp"},
				"deck": {
					"identity": {"title": "Custom Biotics: Engineered for Success", "side": "Corp", "type": "Identity"},
					"cards": [
						{"qty": 6, "card": {"title": "Wall of Static"}},
						{"qty": 4, "card": {"title": "PAD Campaign"}},
						{"qty": 4, "card": {"title": "Hedge Fund"}},
					],
				},
			},
			{
				"side": "Runner",
				"user": {"username": "SmokeRunner"},
				"deck": {
					"identity": {"title": "The Professor: Keeper of Knowledge", "side": "Runner", "type": "Identity"},
					"cards": [
						{"qty": 6, "card": {"title": "Sure Gamble"}},
						{"qty": 4, "card": {"title": "Corroder"}},
						{"qty": 4, "card": {"title": "Easy Mark"}},
					],
				},
			},
		],
	})
	_state = state
	_expect(state != null, "init_game returned state")
	_append("[color=#8b9bb4]=== game start ===[/color]")
	_expect(state.get_in(["corp", "hand"], []).size() == 5, "corp opening hand 5 (skip-mulligan)")
	_expect(state.get_in(["runner", "hand"], []).size() == 5, "runner opening hand 5")
	_expect(int(state.get_in(["corp", "credit"], 0)) == 5, "corp starts with 5 credits")
	_expect(int(state.get_in(["runner", "credit"], 0)) == 5, "runner starts with 5 credits")

	_expect(NRProcessActions.process_action("start-turn", state, "corp"), "start-turn corp")
	_expect(int(state.get_in(["corp", "click"], 0)) == 3, "corp has 3 clicks")
	var hq_after_draw: int = state.get_in(["corp", "hand"], []).size()
	_expect(hq_after_draw == 6, "corp mandatory draw -> 6 HQ (got %d)" % hq_after_draw)

	var credits_before: int = int(state.get_in(["corp", "credit"], 0))
	_expect(NRProcessActions.process_action("credit", state, "corp"), "click-credit")
	_expect(int(state.get_in(["corp", "credit"], 0)) == credits_before + 1, "corp gained 1 credit")
	_expect(int(state.get_in(["corp", "click"], 0)) == 2, "corp spent 1 click on credit")

	var ice = _find_in_hand(state, "corp", "Wall of Static")
	if ice == null:
		ice = _move_from_deck_to_hand(state, "corp", "Wall of Static")
	_expect(ice != null, "corp has Wall of Static in HQ")
	if ice != null:
		_expect(NRProcessActions.process_action("play", state, "corp", {"card": ice, "server": "HQ"}), "install ice on HQ")
		var ices: Array = state.get_in(["corp", "servers", "hq", "ices"], [])
		_expect(ices.size() == 1, "HQ has 1 ice")
		_expect(int(state.get_in(["corp", "click"], 0)) == 1, "install spent a click")
		_append("[color=#3d8bfd]install[/color] Wall of Static on HQ")

	_expect(NRProcessActions.process_action("end-turn", state, "corp"), "end-turn corp")
	_expect(NRProcessActions.process_action("start-turn", state, "runner"), "start-turn runner")
	_expect(int(state.get_in(["runner", "click"], 0)) == 4, "runner has 4 clicks")

	var r_credits: int = int(state.get_in(["runner", "credit"], 0))
	_expect(NRProcessActions.process_action("credit", state, "runner"), "runner click-credit")
	_expect(int(state.get_in(["runner", "credit"], 0)) == r_credits + 1, "runner gained 1 credit")

	var program = _find_in_hand(state, "runner", "Corroder")
	if program == null:
		program = _move_from_deck_to_hand(state, "runner", "Corroder")
	if program != null:
		NRProcessActions.process_action("play", state, "runner", {"card": program})
		var installed: Array = state.get_in(["runner", "rig", "program"], [])
		_append("runner programs installed: [b]%d[/b]  (Corroder)" % installed.size())
		_append("[color=#3d8bfd]install[/color] Corroder")

	_expect(NRProcessActions.process_action("run", state, "runner", {"server": "hq"}), "click-run HQ")
	_expect(state.getv("run") is Dictionary, "run is active")
	_append("[color=#3d8bfd]run[/color] on HQ  phase=[b]%s[/b]" % str(state.get_in(["run", "phase"], "")))

	for i in range(16):
		if not (state.getv("run") is Dictionary):
			break
		NRProcessActions.process_action("continue", state, "corp")
		NRProcessActions.process_action("continue", state, "runner")
		_auto_resolve_prompts(state)

	_append("run after continues: [code]%s[/code]" % str(state.getv("run")))
	_append("HQ ices: %d" % state.get_in(["corp", "servers", "hq", "ices"], []).size())
	_append("[color=#8b9bb4]--- last log lines (approach / pass ice / successful run / breach / access) ---[/color]")
	var game_log := NRSay.n_last_logs(state, 20)
	for line in game_log.split("\n"):
		_append("[color=#d7e3f4]%s[/color]" % line)
	_append("corp credits=[b]%d[/b] clicks=[b]%d[/b]    runner credits=[b]%d[/b] clicks=[b]%d[/b]" % [
		int(state.get_in(["corp", "credit"], 0)),
		int(state.get_in(["corp", "click"], 0)),
		int(state.get_in(["runner", "credit"], 0)),
		int(state.get_in(["runner", "click"], 0)),
	])
	if _ok:
		_append("[b][color=#3dd68c]SMOKE TEST PASSED[/color][/b]")
	else:
		_append("[b][color=#ff6b6b]SMOKE TEST FAILED[/color][/b]")
		for f in _failures:
			_append("[color=#ff6b6b]  - %s[/color]" % f)


func _register_stubs() -> void:
	NRCardDefs.defcard("Wall of Static", {
		"title": "Wall of Static",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"cost": 3,
		"strength": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"subroutines": [
			NRDefHelpers.end_the_run(),
		],
	})
	NRCardDefs.defcard("PAD Campaign", {
		"title": "PAD Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"cost": 2,
		"trash": 4,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
	})
	NRCardDefs.defcard("Hedge Fund", {
		"title": "Hedge Fund",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"cost": 5,
		"on-play": NRDefHelpers.gain_credits_ability(9),
	})
	NRCardDefs.defcard("Sure Gamble", {
		"title": "Sure Gamble",
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 5,
		"on-play": NRDefHelpers.gain_credits_ability(9),
	})
	NRCardDefs.defcard("Corroder", {
		"title": "Corroder",
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"strength": 2,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
	})
	NRCardDefs.defcard("Easy Mark", {
		"title": "Easy Mark",
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"on-play": NRDefHelpers.gain_credits_ability(3),
	})


func _find_in_hand(state: NRState, side: String, title: String) -> Variant:
	for c in state.get_in([side, "hand"], []):
		if c is Dictionary and str(c.get("title")) == title:
			return c
	return null


func _move_from_deck_to_hand(state: NRState, side: String, title: String) -> Variant:
	var deck: Array = state.get_in([side, "deck"], [])
	for c in deck:
		if c is Dictionary and str(c.get("title")) == title:
			return NRMoving.move(state, side, c, "hand")
	return null


func _auto_resolve_prompts(state: NRState) -> void:
	for side in ["corp", "runner"]:
		var prompts: Array = state.get_in([side, "prompt"], [])
		if prompts.is_empty():
			continue
		var p: Dictionary = prompts[0]
		if NRUtil.kw_eq(p.get("prompt-type"), "waiting"):
			continue
		var choices = p.get("choices", [])
		var choice = "No"
		if choices is Array and not choices.is_empty():
			var first = choices[0]
			choice = first.get("value") if first is Dictionary else first
		NRProcessActions.process_action("choice", state, side, {"choice": choice})


func _expect(cond: bool, msg: String) -> void:
	if cond:
		_append("[color=#3dd68c]  ok[/color]  %s" % msg)
	else:
		_ok = false
		_failures.append(msg)
		_append("[color=#ff6b6b]  FAIL[/color] %s" % msg)


func _capture_and_quit() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://screenshots"))
	var tex := get_viewport().get_texture()
	var img: Image = null
	if tex != null:
		img = tex.get_image()
	var used_viewport := img != null and img.get_width() > 8 and img.get_height() > 8 and not _is_mostly_black(img)
	if used_viewport:
		var err := img.save_png(SHOT_PATH)
		print("viewport screenshot saved to %s (%dx%d) err=%s" % [SHOT_PATH, img.get_width(), img.get_height(), err])
	else:
		print("viewport capture empty/black — falling back to TextServer Image render")
		img = _render_log_to_image()
		var err := img.save_png(SHOT_PATH)
		print("textserver screenshot saved to %s (%dx%d) err=%s" % [SHOT_PATH, img.get_width(), img.get_height(), err])
	get_tree().quit(0 if _ok else 1)


func _is_mostly_black(img: Image) -> bool:
	var samples := 0
	var dark := 0
	var step_x: int = maxi(1, img.get_width() / 16)
	var step_y: int = maxi(1, img.get_height() / 16)
	for y in range(0, img.get_height(), step_y):
		for x in range(0, img.get_width(), step_x):
			var c := img.get_pixel(x, y)
			samples += 1
			if c.r + c.g + c.b < 0.08:
				dark += 1
	return samples > 0 and float(dark) / float(samples) > 0.97


func _render_log_to_image() -> Image:
	## Headless fallback: blit TextServer glyph images onto a 1280x800 PNG.
	var w := 1280
	var h := 800
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(BG)
	var plain := ""
	if _log_label != null:
		plain = _log_label.get_parsed_text()
		if plain.is_empty():
			plain = _log_label.get_text()
	var lines: PackedStringArray = (HEADER + "\n" + plain).split("\n")
	var y := 36.0
	var size := 14
	for line in lines:
		if y > h - 48:
			break
		var col := TEXT
		if line.contains("SMOKE TEST PASSED") or line.contains("  ok"):
			col = OK_COL
		elif line.contains("FAIL"):
			col = FAIL_COL
		elif line.begins_with("NETRUNNER") or line.contains("install") or line.contains("click-run") or line.begins_with("run "):
			col = ACCENT
		_blit_string(img, Vector2(28, y), line, size, col)
		y += 18.0
	var status_col := OK_COL if _ok else FAIL_COL
	var status_txt := "SMOKE TEST PASSED" if _ok else "SMOKE TEST FAILED"
	_blit_string(img, Vector2(28, float(h - 28)), status_txt, 18, status_col)
	return img


func _blit_string(img: Image, pos: Vector2, text: String, font_size: int, color: Color) -> void:
	if _mono == null:
		return
	var ts := TextServerManager.get_primary_interface()
	var rids: Array = _mono.get_rids()
	if rids.is_empty():
		return
	var font_rid: RID = rids[0]
	var sized := Vector2i(font_size, 0)
	var ascent: float = ts.font_get_ascent(font_rid, font_size)
	var x := pos.x
	var baseline := pos.y
	for i in text.length():
		var ch: int = text.unicode_at(i)
		if ch == 9:
			x += float(font_size * 2)
			continue
		var glyph: int = ts.font_get_glyph_index(font_rid, font_size, ch, 0)
		var advance: Vector2 = ts.font_get_glyph_advance(font_rid, font_size, glyph)
		var offset: Vector2 = ts.font_get_glyph_offset(font_rid, sized, glyph)
		var glyph_img: Image = ts.font_get_glyph_texture_image(font_rid, sized, glyph)
		if glyph_img != null and glyph_img.get_width() > 0 and glyph_img.get_height() > 0:
			var gx := int(x + offset.x)
			var gy := int(baseline - ascent + offset.y)
			_blit_glyph(img, glyph_img, gx, gy, color)
		x += advance.x


func _blit_glyph(dst: Image, glyph: Image, dx: int, dy: int, color: Color) -> void:
	if glyph.get_format() != Image.FORMAT_RGBA8:
		glyph.convert(Image.FORMAT_RGBA8)
	var gw := glyph.get_width()
	var gh := glyph.get_height()
	var dw := dst.get_width()
	var dh := dst.get_height()
	for yy in range(gh):
		var sy := dy + yy
		if sy < 0 or sy >= dh:
			continue
		for xx in range(gw):
			var sx := dx + xx
			if sx < 0 or sx >= dw:
				continue
			var p := glyph.get_pixel(xx, yy)
			var a := p.a
			if a <= 0.001:
				# Some rasterizers store coverage in RGB with a=1.
				a = maxf(p.r, maxf(p.g, p.b))
				if a <= 0.001:
					continue
			var out := Color(color.r, color.g, color.b, color.a * a)
			var base := dst.get_pixel(sx, sy)
			dst.set_pixel(sx, sy, Color(
				base.r * (1.0 - out.a) + out.r * out.a,
				base.g * (1.0 - out.a) + out.g * out.a,
				base.b * (1.0 - out.a) + out.b * out.a,
				1.0
			))
