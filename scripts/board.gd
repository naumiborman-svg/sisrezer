extends Control

var mode := NREngine.RUNNER
var engine: NREngine
var human := NREngine.RUNNER
var decks: Dictionary = {}
var card_db: Dictionary = {}
var log_box: RichTextLabel
var action_box: VBoxContainer
var table: Control
var status: Label
var _busy := false


func _ready() -> void:
	NRAi.style = "strong"
	if mode == "watch":
		human = ""
	elif mode != "hotseat":
		human = mode
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.035, 0.07, 0.1)
	add_child(bg)
	_build_chrome()
	engine = NREngine.new(card_db if not card_db.is_empty() else CardLibrary.cards())
	var seed_n := 0 if mode != "hotseat" else 1
	engine.new_game(seed_n, decks if not decks.is_empty() else CardLibrary.decks())
	_refresh()
	_maybe_ai()


func _build_chrome() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(PRESET_FULL_RECT)
	root.offset_left = 12
	root.offset_top = 8
	root.offset_right = -12
	root.offset_bottom = -8
	add_child(root)
	status = Label.new()
	status.add_theme_font_size_override("font_size", 16)
	status.add_theme_color_override("font_color", Color(0.78, 0.88, 0.95))
	root.add_child(status)
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 10)
	root.add_child(mid)
	table = Control.new()
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_child(table)
	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(320, 0)
	side.add_theme_constant_override("separation", 8)
	mid.add_child(side)
	var actions_title := Label.new()
	actions_title.text = "Actions"
	actions_title.add_theme_color_override("font_color", Color(0.45, 0.72, 0.9))
	side.add_child(actions_title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(scroll)
	action_box = VBoxContainer.new()
	action_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_box.add_theme_constant_override("separation", 4)
	scroll.add_child(action_box)
	log_box = RichTextLabel.new()
	log_box.custom_minimum_size = Vector2(0, 140)
	log_box.bbcode_enabled = true
	log_box.scroll_following = true
	log_box.add_theme_font_size_override("normal_font_size", 13)
	root.add_child(log_box)
	var bottom := HBoxContainer.new()
	root.add_child(bottom)
	var back := Button.new()
	back.text = "Title"
	back.pressed.connect(_to_title)
	bottom.add_child(back)


func _to_title() -> void:
	var packed := load("res://scenes/title.tscn") as PackedScene
	get_tree().root.add_child(packed.instantiate())
	queue_free()


func _refresh() -> void:
	status.text = _status_text()
	_paint_table()
	_paint_actions()
	_paint_log()


func _status_text() -> String:
	if engine.winner != "":
		return "%s wins — %s" % [engine.winner.capitalize(), engine.win_reason]
	var vs := "Hotseat" if mode == "hotseat" else ("AI vs AI" if mode == "watch" else "vs Strong AI")
	return "%s  ·  Turn %s  ·  %s    Corp %dc / %dcl / %dAP    Runner %dc / %dcl / %dAP  MU %d/%d" % [
		vs,
		engine.turn.capitalize(),
		engine.phase,
		engine.corp.credits, engine.corp.clicks, engine.agenda_points(NREngine.CORP),
		engine.runner.credits, engine.runner.clicks, engine.agenda_points(NREngine.RUNNER),
		engine.mu_used(), engine.mu_max(),
	]


func _paint_log() -> void:
	var lines: PackedStringArray = PackedStringArray()
	var start: int = maxi(0, engine.log_lines.size() - 12)
	for i in range(start, engine.log_lines.size()):
		lines.append(engine.log_lines[i])
	log_box.text = "\n".join(lines)


func _paint_actions() -> void:
	for child in action_box.get_children():
		child.queue_free()
	if engine.winner != "":
		var done := Label.new()
		done.text = engine.win_reason
		action_box.add_child(done)
		return
	if _ai_to_move():
		var wait := Label.new()
		wait.text = "Strong AI thinking…"
		action_box.add_child(wait)
		return
	for act: Variant in engine.legal():
		if act is Dictionary:
			var b := Button.new()
			b.text = _label(act)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var captured: Dictionary = act
			b.pressed.connect(func() -> void: _do(captured))
			action_box.add_child(b)


func _label(act: Dictionary) -> String:
	var op := str(act.get("op", ""))
	match op:
		"credit":
			return "Click for 1 credit"
		"draw":
			return "Click to draw"
		"end_turn":
			return "End turn"
		"play":
			return "Play  " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"install":
			return "Install  %s  →  %s" % [engine.find_uid(int(act.uid)).get("title", "?"), act.dest]
		"advance":
			return "Advance  " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"score":
			return "Score  " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"rez":
			return "Rez  " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"run":
			return "Run  " + str(act.server)
		"ability":
			return "%s: %s" % [engine.find_uid(int(act.uid)).get("title", "?"), act.get("name", "")]
		"break":
			return "Break with " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"pump":
			return "Pump " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"bioroid_break":
			return "Lose click: break bioroid sub"
		"jack_out":
			return "Jack out"
		"continue":
			return "Continue"
		"no_rez":
			return "Do not rez"
		"steal":
			return "Steal " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"trash_access":
			return "Trash " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"pass_access":
			return "Leave " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"discard":
			return "Discard " + str(engine.find_uid(int(act.uid)).get("title", "?"))
		"choose_server":
			return "Choose " + str(act.server)
		"manegarm_clicks":
			return "Manegarm: spend 2 clicks"
		"manegarm_credits":
			return "Manegarm: pay 5 credits"
		"advance_free":
			return "Place 2 advancements on " + str(engine.find_uid(int(act.uid)).get("title", "?"))
	return op


func _do(act: Dictionary) -> void:
	if _busy or _ai_to_move():
		return
	if engine.apply(act):
		_refresh()
		_maybe_ai()


func _ai_to_move() -> bool:
	if mode == "hotseat" or engine.winner != "":
		return false
	return engine.actor() != human


func _maybe_ai() -> void:
	if not _ai_to_move():
		return
	_busy = true
	await get_tree().create_timer(0.12).timeout
	var act := NRAi.pick(engine, engine.actor())
	var ok := false
	if not act.is_empty():
		ok = engine.apply(act)
	_busy = false
	_refresh()
	if ok and _ai_to_move():
		_maybe_ai()


func _paint_table() -> void:
	for child in table.get_children():
		child.queue_free()
	var col := VBoxContainer.new()
	col.set_anchors_preset(PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 8)
	table.add_child(col)
	col.add_child(_section("Corp HQ %d  ·  R&D %d  ·  Archives %d" % [
		engine.corp.hand.size(), engine.corp.deck.size(), engine.corp.discard.size()
	], _server_row()))
	col.add_child(_section("Runner rig", _rig_row()))
	var hand_who := engine.turn if mode == "hotseat" else human
	col.add_child(_section("%s hand" % hand_who.capitalize(), _hand_row(hand_who)))


func _section(title: String, body: Control) -> VBoxContainer:
	var box := VBoxContainer.new()
	var l := Label.new()
	l.text = title
	l.add_theme_color_override("font_color", Color(0.5, 0.74, 0.88))
	box.add_child(l)
	box.add_child(body)
	return box


func _server_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(_server_panel("HQ", "hq", engine.corp.hq_ices, []))
	row.add_child(_server_panel("R&D", "rd", engine.corp.rd_ices, []))
	row.add_child(_server_panel("Archives", "archives", engine.corp.archives_ices, []))
	for remote: Variant in engine.remotes:
		row.add_child(_server_panel("R%d" % remote.id, "remote:%d" % remote.id, remote.ices, remote.root))
	return row


func _server_panel(name: String, _id: String, ices: Array, root: Array) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(150, 0)
	var title := Label.new()
	title.text = name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	for card: Variant in ices:
		box.add_child(_mini_card(card, card.rezzed or human == NREngine.CORP or mode == "hotseat"))
	for card: Variant in root:
		box.add_child(_mini_card(card, card.rezzed or str(card.type) == "Agenda" and false or (human == NREngine.CORP or mode == "hotseat")))
	if ices.is_empty() and root.is_empty():
		var empty := Label.new()
		empty.text = "—"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(empty)
	return box


func _rig_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	for card: Variant in engine.runner.programs + engine.runner.hardware + engine.runner.resources:
		row.add_child(_mini_card(card, true))
	return row


func _hand_row(who: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var hide := mode != "hotseat" and who != human
	for card: Variant in engine.side_of(who).hand:
		row.add_child(_mini_card(card, not hide))
	return row


func _mini_card(card: Dictionary, face: bool) -> Control:
	var wrap := VBoxContainer.new()
	if face:
		var path := "res://assets/cards/%s.png" % card.code
		if ResourceLoader.exists(path):
			var tex := TextureRect.new()
			tex.custom_minimum_size = Vector2(90, 126)
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tex.texture = load(path)
			wrap.add_child(tex)
		else:
			var face_back := ColorRect.new()
			face_back.custom_minimum_size = Vector2(90, 126)
			face_back.color = Color(0.12, 0.18, 0.26)
			wrap.add_child(face_back)
			var name_l := Label.new()
			name_l.text = str(card.get("title", "??"))
			name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_l.autowrap_mode = TextServer.AUTOWRAP_OFF
			name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			name_l.custom_minimum_size = Vector2(90, 0)
			wrap.add_child(name_l)
	else:
		var back := ColorRect.new()
		back.custom_minimum_size = Vector2(90, 126)
		back.color = Color(0.12, 0.18, 0.26)
		wrap.add_child(back)
		var l := Label.new()
		l.text = "ICE" if str(card.type) == "ICE" else "??"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wrap.add_child(l)
		return wrap
	if int(card.get("advancement", 0)) > 0:
		var adv := Label.new()
		adv.text = "adv %d" % card.advancement
		adv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wrap.add_child(adv)
	return wrap
