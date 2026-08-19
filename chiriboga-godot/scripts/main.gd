extends Control
## CRT terminal UI for Chiriboga (Netrunner: Solo Mode).

const GREEN := Color("33ff33")
const GREEN_DIM := Color("1f6d1f")
const GREEN_MUTED := Color("8fdc8f")
const AMBER := Color("ffb000")
const BG := Color("0a100a")
const BG2 := Color("0d1d0d")
const DANGER := Color("ff5555")

var gs: GameState
var _mono: Font
var _status: Label
var _phase: Label
var _servers: HBoxContainer
var _grip: HBoxContainer
var _rig: VBoxContainer
var _log: RichTextLabel
var _actions: VBoxContainer
var _inspect: RichTextLabel
var _run_banner: Label
var _menu: Control
var _ai_timer: Timer
var _selected: NRCard = null
var _started := false


func _ready() -> void:
	_mono = _make_font()
	_build()
	_show_menu()


func _make_font() -> Font:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["DejaVu Sans Mono", "Liberation Mono", "Ubuntu Mono", "Courier New", "monospace"])
	return f


func _build() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var title := Label.new()
	title.text = "CHIRIBOGA  //  NETRUNNER: SOLO MODE  //  GODOT PORT"
	_style_label(title, 18, GREEN)
	root.add_child(title)

	var status_row := HBoxContainer.new()
	_status = Label.new()
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(_status, 14, GREEN_MUTED)
	_phase = Label.new()
	_style_label(_phase, 14, AMBER)
	status_row.add_child(_status)
	status_row.add_child(_phase)
	root.add_child(status_row)

	_run_banner = Label.new()
	_run_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(_run_banner, 16, DANGER)
	root.add_child(_run_banner)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	root.add_child(body)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 2.2
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)

	left.add_child(_section_label("CORP SERVERS"))
	var srv_scroll := ScrollContainer.new()
	srv_scroll.custom_minimum_size = Vector2(0, 210)
	srv_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	srv_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_servers = HBoxContainer.new()
	_servers.add_theme_constant_override("separation", 8)
	srv_scroll.add_child(_servers)
	left.add_child(srv_scroll)

	left.add_child(_section_label("RUNNER RIG"))
	_rig = VBoxContainer.new()
	left.add_child(_rig)

	left.add_child(_section_label("GRIP  (click a card, then an action)"))
	var grip_scroll := ScrollContainer.new()
	grip_scroll.custom_minimum_size = Vector2(0, 150)
	grip_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_grip = HBoxContainer.new()
	_grip.add_theme_constant_override("separation", 6)
	grip_scroll.add_child(_grip)
	left.add_child(grip_scroll)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(380, 0)
	right.add_theme_constant_override("separation", 6)
	body.add_child(right)

	right.add_child(_section_label("INSPECTOR"))
	_inspect = RichTextLabel.new()
	_inspect.custom_minimum_size = Vector2(0, 160)
	_inspect.bbcode_enabled = true
	_inspect.scroll_active = true
	_inspect.add_theme_font_override("normal_font", _mono)
	_inspect.add_theme_color_override("default_color", GREEN)
	right.add_child(_inspect)

	right.add_child(_section_label("ACTIONS"))
	var act_scroll := ScrollContainer.new()
	act_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	act_scroll.custom_minimum_size = Vector2(0, 180)
	_actions = VBoxContainer.new()
	_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	act_scroll.add_child(_actions)
	right.add_child(act_scroll)

	right.add_child(_section_label("LOG"))
	_log = RichTextLabel.new()
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.custom_minimum_size = Vector2(0, 160)
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.add_theme_font_override("normal_font", _mono)
	_log.add_theme_color_override("default_color", GREEN_MUTED)
	right.add_child(_log)

	var footer := Label.new()
	footer.text = "Click actions on the right  ·  R restart  ·  A toggle Runner AI  ·  original: chiriboga.cronbach.com"
	_style_label(footer, 11, GREEN_DIM)
	root.add_child(footer)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := ShaderMaterial.new()
	sh.shader = load("res://scripts/ui/scanlines.gdshader")
	overlay.material = sh
	overlay.color = Color(1, 1, 1, 1)
	add_child(overlay)

	_ai_timer = Timer.new()
	_ai_timer.wait_time = 0.28
	_ai_timer.timeout.connect(_on_ai_tick)
	add_child(_ai_timer)

	_menu = _build_menu()
	add_child(_menu)


func _section_label(t: String) -> Label:
	var l := Label.new()
	l.text = t
	_style_label(l, 12, GREEN_DIM)
	return l


func _style_label(l: Label, size: int, col: Color) -> void:
	l.add_theme_font_override("font", _mono)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)


func _panel() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BG2
	s.border_color = GREEN_DIM
	s.set_border_width_all(1)
	s.set_content_margin_all(6)
	return s


func _build_menu() -> Control:
	var wrap := ColorRect.new()
	wrap.color = Color(0.02, 0.05, 0.02, 0.94)
	wrap.set_anchors_preset(PRESET_FULL_RECT)
	var c := CenterContainer.new()
	c.set_anchors_preset(PRESET_FULL_RECT)
	wrap.add_child(c)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	c.add_child(box)
	var t := Label.new()
	t.text = "CHIRIBOGA"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(t, 42, GREEN)
	box.add_child(t)
	var sub := Label.new()
	sub.text = "NETRUNNER  ·  SOLO MODE\nGodot 4 port of the Chiriboga engine"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(sub, 14, GREEN_MUTED)
	box.add_child(sub)
	box.add_child(_menu_btn("PLAY AS RUNNER  (vs Corp AI)", func (): _start_game("runner")))
	box.add_child(_menu_btn("PLAY AS CORP  (vs Runner AI)", func (): _start_game("corp")))
	box.add_child(_menu_btn("WATCH  AI vs AI", func (): _start_game("watch")))
	var hint := Label.new()
	hint.text = "Starter decks: The Catalyst vs The Syndicate\nWin: 7 agenda points  ·  Corp also wins on flatline"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(hint, 12, GREEN_DIM)
	box.add_child(hint)
	return wrap


func _menu_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 36)
	_style_btn(b)
	b.pressed.connect(cb)
	return b


func _style_btn(b: Button) -> void:
	b.add_theme_font_override("font", _mono)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", GREEN)
	b.add_theme_color_override("font_hover_color", Color.BLACK)
	var n := StyleBoxFlat.new()
	n.bg_color = Color("0a170a")
	n.border_color = GREEN_DIM
	n.set_border_width_all(1)
	n.set_content_margin_all(6)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = GREEN
	h.border_color = GREEN
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)


func _show_menu() -> void:
	_menu.visible = true
	_ai_timer.stop()


func _start_game(mode: String) -> void:
	gs = GameState.new()
	var opts := {"seed": randi(), "ap": 7}
	match mode:
		"runner":
			opts["human_side"] = "runner"
			opts["runner_ai"] = false
			opts["corp_ai"] = true
		"corp":
			opts["human_side"] = "corp"
			opts["runner_ai"] = true
			opts["corp_ai"] = false
		"watch":
			opts["human_side"] = "runner"
			opts["runner_ai"] = true
			opts["corp_ai"] = true
	gs.start_new_game(opts)
	gs.log_line.connect(_on_log)
	_started = true
	_menu.visible = false
	_log.clear()
	_refresh()
	_ai_timer.start()


func _on_log(text: String) -> void:
	_log.append_text(text + "\n")


func _on_ai_tick() -> void:
	if gs == null or gs.is_over():
		return
	var actor := gs._current_actor()
	var use_ai := (actor == "runner" and gs.runner_is_ai) or (actor == "corp" and gs.corp_is_ai)
	if use_ai:
		gs.ai_tick()
		_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_show_menu()
		elif event.keycode == KEY_A and gs != null:
			gs.runner_is_ai = not gs.runner_is_ai
			_refresh()


func _refresh() -> void:
	if gs == null:
		return
	_status.text = "RUNNER  $%d  clicks:%d  tags:%d  AP:%d/%d  grip:%d  MU:%d/%d    CORP  $%d  clicks:%d  BP:%d  AP:%d/%d  HQ:%d" % [
		gs.runner.credits, gs.runner.clicks, gs.runner.tags, gs.runner.scored_points(), gs.agenda_points_to_win,
		gs.runner.grip.size(), gs.used_mu(), gs.max_mu(),
		gs.corp.credits, gs.corp.clicks, gs.corp.bad_publicity, gs.corp.scored_points(), gs.agenda_points_to_win,
		gs.hq.cards.size()
	]
	var extra := ""
	if gs._pending_kind != "":
		extra = "  |  " + gs.pending_title()
	_phase.text = "T%d  %s%s" % [gs.turn_number, gs.phase_name(), extra]
	if gs.run_active and gs.run_server:
		_run_banner.text = "⚠  RUN ACTIVE  →  %s" % gs.run_server.server_name
		_run_banner.visible = true
	else:
		_run_banner.visible = false
	_rebuild_servers()
	_rebuild_rig()
	_rebuild_grip()
	_rebuild_actions()
	_rebuild_inspect()
	if gs.is_over():
		_run_banner.visible = true
		_run_banner.text = "GAME OVER — %s wins. %s" % [gs.winner.capitalize(), gs.win_reason]


func _rebuild_servers() -> void:
	_clear(_servers)
	for s in gs.all_servers():
		_servers.add_child(_server_panel(s))


func _server_panel(s: NRServer) -> Control:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _panel())
	p.custom_minimum_size = Vector2(170, 190)
	var v := VBoxContainer.new()
	p.add_child(v)
	var name := Label.new()
	var extra := ""
	if s.server_name == "HQ":
		extra = " [%d]" % s.cards.size()
	elif s.server_name == "R&D":
		extra = " [%d]" % s.cards.size()
	elif s.server_name == "Archives":
		extra = " [%d]" % s.cards.size()
	name.text = s.server_name + extra
	_style_label(name, 13, AMBER if (gs.run_active and gs.run_server == s) else GREEN)
	v.add_child(name)
	var ice_l := Label.new()
	var ice_bits: PackedStringArray = PackedStringArray()
	for i in range(s.ice.size() - 1, -1, -1):
		var ice: NRCard = s.ice[i]
		if ice.rezzed:
			ice_bits.append("%s s%d" % [ice.short_label(), gs.ice_strength(ice)])
		else:
			ice_bits.append("ICE?")
	ice_l.text = "ICE: " + (" | ".join(ice_bits) if ice_bits.size() > 0 else "(none)")
	ice_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(ice_l, 11, GREEN_MUTED)
	v.add_child(ice_l)
	for c in s.root:
		var rl := Label.new()
		var shown: String = "facedown"
		if gs.human_side == "corp" or c.rezzed or c.known_to_runner:
			shown = c.title()
			if c.card_type() == "agenda":
				shown += " %d/%d" % [c.advancement, c.advancement_requirement()]
			elif c.advancement > 0:
				shown += " adv%d" % c.advancement
			if c.hosted_credits > 0:
				shown += " $%d" % c.hosted_credits
			if not c.rezzed and c.card_type() != "agenda":
				shown = "?" if gs.human_side != "corp" else ("(unrez) " + shown)
		rl.text = "· " + shown
		rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_style_label(rl, 11, GREEN)
		v.add_child(rl)
		_click_label(rl, c)
	if s.root.is_empty() and not s.is_central:
		var empty := Label.new()
		empty.text = "(empty remote)"
		_style_label(empty, 11, GREEN_DIM)
		v.add_child(empty)
	return p


func _click_label(l: Label, card: NRCard) -> void:
	l.mouse_filter = Control.MOUSE_FILTER_STOP
	l.gui_input.connect(func (ev):
		if ev is InputEventMouseButton and ev.pressed:
			_selected = card
			_rebuild_inspect()
	)


func _rebuild_rig() -> void:
	_clear(_rig)
	var line := func (title: String, arr: Array) -> void:
		var l := Label.new()
		var names: PackedStringArray = PackedStringArray()
		for c in arr:
			var extra := ""
			if c.hosted_credits > 0:
				extra = " $%d" % c.hosted_credits
			if c.has_subtype("Icebreaker"):
				extra += " s%d" % gs.breaker_strength(c)
			names.append(c.short_label() + extra)
		l.text = title + (": " + ", ".join(names) if names.size() else ": (none)")
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_style_label(l, 12, GREEN_MUTED)
		_rig.add_child(l)
		for c in arr:
			_click_label(l, c)
	line.call("Programs", gs.runner.programs)
	line.call("Hardware", gs.runner.hardware)
	line.call("Resources", gs.runner.resources)
	var scored := Label.new()
	var sp: PackedStringArray = PackedStringArray()
	for c in gs.runner.score_area:
		sp.append(c.title())
	var cp: PackedStringArray = PackedStringArray()
	for c in gs.corp.score_area:
		cp.append(c.title())
	scored.text = "Stolen: %s    Corp scored: %s" % [
		(", ".join(sp) if sp.size() else "—"),
		(", ".join(cp) if cp.size() else "—"),
	]
	scored.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(scored, 12, AMBER)
	_rig.add_child(scored)
	var piles := Label.new()
	piles.text = "Stack: %d    Heap: %d    %s" % [gs.runner.stack.size(), gs.runner.heap.size(), gs.runner.identity.title()]
	_style_label(piles, 12, GREEN_DIM)
	_rig.add_child(piles)


func _rebuild_grip() -> void:
	_clear(_grip)
	if gs.human_side == "corp":
		for c in gs.hq.cards:
			_grip.add_child(_card_btn(c, true))
		var hint := Label.new()
		hint.text = "  (HQ — you are the Corp)"
		_style_label(hint, 11, GREEN_DIM)
		_grip.add_child(hint)
		return
	for c in gs.runner.grip:
		_grip.add_child(_card_btn(c, true))


func _card_btn(c: NRCard, faceup: bool) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(128, 132)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if faceup:
		b.text = "%s\n[%s %s]\n%d[c]\n%s" % [c.short_label(), c.faction(), c.card_type(), c.play_cost(), c.text().substr(0, 80)]
	else:
		b.text = "████\nRUNNER"
	_style_btn(b)
	if _selected == c:
		var h := StyleBoxFlat.new()
		h.bg_color = Color("1a3a1a")
		h.border_color = AMBER
		h.set_border_width_all(2)
		h.set_content_margin_all(6)
		b.add_theme_stylebox_override("normal", h)
	b.pressed.connect(func ():
		_selected = c
		_rebuild_inspect()
		_rebuild_grip()
	)
	return b


func _rebuild_actions() -> void:
	_clear(_actions)
	if gs.is_over():
		var l := Label.new()
		l.text = gs.win_reason
		_style_label(l, 13, AMBER)
		_actions.add_child(l)
		var r := Button.new()
		r.text = "Return to menu"
		_style_btn(r)
		r.pressed.connect(_show_menu)
		_actions.add_child(r)
		return
	var actor := gs._current_actor()
	var use_ai := (actor == "runner" and gs.runner_is_ai) or (actor == "corp" and gs.corp_is_ai)
	if use_ai:
		var think := Label.new()
		think.text = "%s AI thinking…" % actor.capitalize()
		_style_label(think, 12, AMBER)
		_actions.add_child(think)
		return
	var acts := gs.legal_actions()
	if gs._pending_kind != "":
		var pt := Label.new()
		pt.text = gs.pending_title()
		pt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_style_label(pt, 12, AMBER)
		_actions.add_child(pt)
	for a in acts:
		var b := Button.new()
		b.text = str(a.get("label", "?"))
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_style_btn(b)
		var captured: Dictionary = a
		b.pressed.connect(func ():
			gs.act(captured)
			_refresh()
		)
		_actions.add_child(b)


func _rebuild_inspect() -> void:
	if _selected == null:
		_inspect.text = "[color=#8fdc8f]Select a card to inspect.[/color]"
		return
	var c := _selected
	var d := c.def()
	var bits: PackedStringArray = PackedStringArray()
	bits.append("[color=#33ff33][b]%s[/b][/color]" % c.title())
	bits.append("[color=#ffb000]%s  ·  %s  ·  %s[/color]" % [c.side(), c.card_type(), c.faction()])
	if d.has("cost"):
		bits.append("Cost: %s" % d.cost)
	if d.has("strength"):
		bits.append("Strength: %s" % d.strength)
	if c.card_type() == "agenda":
		bits.append("Advancement: %d / %d   Points: %d" % [c.advancement, c.advancement_requirement(), c.agenda_points()])
	if c.hosted_credits > 0:
		bits.append("Hosted credits: %d" % c.hosted_credits)
	if int(d.get("influence", 0)) > 0:
		bits.append("Influence: %d" % int(d.influence))
	if d.has("memory_cost"):
		bits.append("MU: %s" % d.memory_cost)
	bits.append("")
	bits.append(c.text())
	if c.subtypes().size():
		bits.append("\nKeywords: %s" % ", ".join(PackedStringArray(c.subtypes())))
	_inspect.text = "\n".join(bits)


func _clear(n: Node) -> void:
	for ch in n.get_children():
		n.remove_child(ch)
		ch.queue_free()
