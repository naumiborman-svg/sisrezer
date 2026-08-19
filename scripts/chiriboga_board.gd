extends Control

const BG := Color(0.02, 0.04, 0.03)
const GREEN := Color(0.2, 1.0, 0.2)
const DIM := Color(0.45, 0.7, 0.45)

var payload: Dictionary = {"mode": "starter", "side": "runner", "ap": 6}
var client: Node
var game_id := ""
var state: Dictionary = {}
var log_box: RichTextLabel
var action_box: VBoxContainer
var table: Control
var status: Label
var _busy := false
var _notice := ""
var _ai_watch := false
var _jinteki := false
var _human := "runner"


func _fill(node: Control, pad := Vector4.ZERO) -> void:
	node.anchor_left = 0.0
	node.anchor_top = 0.0
	node.anchor_right = 1.0
	node.anchor_bottom = 1.0
	node.offset_left = pad.x
	node.offset_top = pad.y
	node.offset_right = -pad.z
	node.offset_bottom = -pad.w
	node.grow_horizontal = Control.GROW_DIRECTION_BOTH
	node.grow_vertical = Control.GROW_DIRECTION_BOTH


func _ready() -> void:
	_ai_watch = str(payload.get("mode", "")) == "watch"
	_fill(self)
	var bg := ColorRect.new()
	_fill(bg)
	bg.color = BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	if bool(ChiribogaSave.settings().get("crt", true)):
		var overlay := ColorRect.new()
		_fill(overlay)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mat := ShaderMaterial.new()
		mat.shader = load("res://assets/shaders/crt_scanlines.gdshader")
		overlay.material = mat
		add_child(overlay)
	_build()
	_jinteki = str(payload.get("engine", "")) == "jinteki"
	_human = str(payload.get("side", "runner"))
	if _jinteki:
		client = ClojureClient.new()
	else:
		client = ChiribogaClient.new()
	add_child(client)
	if not client.is_node_ready():
		await client.ready
	_notice = "Connecting %s at %s …" % ["mtgred/netrunner" if _jinteki else "Chiriboga", str(client.get("base_url"))]
	_refresh()
	var created: Dictionary
	if _jinteki:
		created = await (client as ClojureClient).new_game(payload)
	else:
		created = await (client as ChiribogaClient).new_game(payload)
	if not bool(created.get("ok", false)) or str(created.get("id", "")) == "":
		_notice = "%s unavailable: %s" % [
			"mtgred/netrunner (lein run :1042)" if _jinteki else "Chiriboga host (./chiriboga-bridge/start.sh)",
			created.get("error", str(client.get("last_error"))),
		]
		_refresh()
		return
	game_id = str(created["id"])
	state = _normalize(created)
	_notice = ""
	_refresh()
	if _jinteki:
		_maybe_ai()
	else:
		_maybe_autocommit()
		_maybe_watch()


func _build() -> void:
	var root := VBoxContainer.new()
	_fill(root, Vector4(12, 8, 12, 8))
	add_child(root)
	status = Label.new()
	status.add_theme_font_size_override("font_size", 15)
	status.add_theme_color_override("font_color", GREEN)
	root.add_child(status)
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(mid)
	table = Control.new()
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_child(table)
	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(340, 0)
	mid.add_child(side)
	var ht := Label.new()
	ht.text = "CHIRIBOGA ACTIONS"
	ht.add_theme_color_override("font_color", GREEN)
	side.add_child(ht)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(scroll)
	action_box = VBoxContainer.new()
	action_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(action_box)
	log_box = RichTextLabel.new()
	log_box.custom_minimum_size = Vector2(0, 150)
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


func _maybe_unlock() -> void:
	var g: Variant = state.get("gauntlet", null)
	if g is Dictionary and str(state.get("winner", "")) == "runner":
		var defeated := int(g.get("defeated", 0)) + 1
		var length := int(g.get("length", 0))
		if defeated >= length and length >= 4:
			ChiribogaSave.unlock("beat4gauntlet")
		if defeated >= length and length >= 8:
			ChiribogaSave.unlock("beat8gauntlet")
		if defeated >= length and length >= 12:
			ChiribogaSave.unlock("beat12gauntlet")


func _to_title() -> void:
	var packed := load("res://scenes/chiriboga_title.tscn") as PackedScene
	get_tree().root.add_child(packed.instantiate())
	queue_free()


func _refresh() -> void:
	status.text = _status_text()
	_paint_table()
	_paint_actions()
	_paint_log()


func _status_text() -> String:
	if _notice != "":
		return _notice
	if state.is_empty():
		return "Waiting for Chiriboga…"
	if str(state.get("winner", "")) != "":
		_maybe_unlock()
		return "%s wins — %s" % [str(state["winner"]).capitalize(), state.get("reason", "")]
	var corp: Dictionary = state.get("corp", {})
	var runner: Dictionary = state.get("runner", {})
	var extra := ""
	var g: Variant = state.get("gauntlet", null)
	if g is Dictionary:
		extra = "    Gauntlet %s/%s  %s" % [g.get("defeated", 0), g.get("length", 0), g.get("opponent", "")]
	var engine := "mtgred/netrunner" if _jinteki else "Chiriboga"
	return "%s  ·  %s  ·  %s    Corp %dc / %dcl / %dAP    Runner %dc / %dcl / %dAP  goal %s%s" % [
		engine,
		state.get("phase", ""),
		str(state.get("active", "")).capitalize(),
		int(corp.get("credits", 0)), int(corp.get("clicks", 0)), int(corp.get("agenda_points", 0)),
		int(runner.get("credits", 0)), int(runner.get("clicks", 0)), int(runner.get("agenda_points", 0)),
		state.get("agenda_goal", 7),
		extra,
	]


func _paint_log() -> void:
	var lines: PackedStringArray = PackedStringArray()
	var tut := str(state.get("tutorial", ""))
	if tut != "":
		lines.append("[color=#6f6]%s[/color]" % tut)
	for item: Variant in state.get("log", []):
		lines.append(str(item))
	if str(state.get("error", "")) != "":
		lines.append("[color=#f88]%s[/color]" % state["error"])
	log_box.text = "\n".join(lines)


func _paint_actions() -> void:
	for child in action_box.get_children():
		child.queue_free()
	if _notice != "":
		var e := Label.new()
		e.text = _notice
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		action_box.add_child(e)
		return
	if str(state.get("winner", "")) != "":
		var d := Label.new()
		d.text = str(state.get("reason", "Game over"))
		action_box.add_child(d)
		return
	if _ai_watch:
		var w := Label.new()
		w.text = "AI faceoff…"
		action_box.add_child(w)
		return
	for item: Variant in _visible_actions():
		if item is Dictionary:
			var b := Button.new()
			b.text = str(item.get("label", item.get("command", "?")))
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var captured: Dictionary = item
			b.pressed.connect(func() -> void: _do(captured))
			action_box.add_child(b)


func _visible_actions() -> Array:
	var acts: Array = state.get("actions", [])
	if not _jinteki:
		return acts
	var actor := ClojureAi.actor(state)
	if actor != _human:
		return []
	return acts


func _normalize(raw: Dictionary) -> Dictionary:
	var out: Dictionary = raw.duplicate(true)
	var servers: Variant = out.get("servers", {})
	if servers is Dictionary:
		for key in ["hq", "rd", "archives"]:
			var sv: Variant = servers.get(key, {})
			if sv is Dictionary and sv.has("ices") and not sv.has("ice"):
				sv["ice"] = sv["ices"]
		for remote: Variant in servers.get("remotes", []):
			if remote is Dictionary and remote.has("ices") and not remote.has("ice"):
				remote["ice"] = remote["ices"]
	if str(out.get("engine", "")) == "mtgred/netrunner":
		out["phase"] = "Turn %s" % out.get("turn", 0)
		var corp: Dictionary = out.get("corp", {})
		out["agenda_goal"] = corp.get("agenda_point_req", out.get("agenda_goal", 7))
	return out


func _do(act: Dictionary) -> void:
	if _busy or game_id == "":
		return
	_busy = true
	var next_state: Dictionary
	if _jinteki:
		next_state = await (client as ClojureClient).action(game_id, act)
	else:
		next_state = await (client as ChiribogaClient).action(game_id, act)
	_busy = false
	if next_state.has("actions") or bool(next_state.get("ok", false)):
		state = _normalize(next_state)
	else:
		_notice = str(next_state.get("error", "action failed"))
	_refresh()
	if _jinteki:
		_maybe_ai()
	else:
		_maybe_autocommit()
		_maybe_watch()


func _maybe_ai() -> void:
	if not _jinteki or _busy or game_id == "" or str(state.get("winner", "")) != "":
		return
	var actor := ClojureAi.actor(state)
	if actor == _human:
		return
	var act := ClojureAi.pick(state, actor)
	if act.is_empty():
		return
	await get_tree().create_timer(0.2).timeout
	if not _busy:
		_do(act)


func _maybe_autocommit() -> void:
	if _busy or _ai_watch or _jinteki or game_id == "":
		return
	if str(state.get("phase", "")) == "Tutorial":
		return
	var acts: Array = state.get("actions", [])
	if acts.size() != 1 or not (acts[0] is Dictionary):
		return
	var label := str(acts[0].get("label", "")).to_lower()
	var command := str(acts[0].get("command", ""))
	if command != "n" and label != "continue" and not label.begins_with("continue "):
		return
	await get_tree().create_timer(0.15).timeout
	if not _busy:
		_do(acts[0])


func _maybe_watch() -> void:
	if not _ai_watch or game_id == "" or str(state.get("winner", "")) != "":
		return
	await get_tree().create_timer(0.4).timeout
	var st := await client.get_state(game_id)
	if st.has("actions"):
		state = st
	_refresh()
	if _ai_watch and str(state.get("winner", "")) == "":
		_maybe_watch()


func _paint_table() -> void:
	for child in table.get_children():
		child.queue_free()
	var col := VBoxContainer.new()
	_fill(col)
	col.add_theme_constant_override("separation", 8)
	table.add_child(col)
	var corp: Dictionary = state.get("corp", {})
	var runner: Dictionary = state.get("runner", {})
	var servers: Dictionary = state.get("servers", {})
	col.add_child(_section("Corp HQ %s  ·  R&D %s  ·  Archives %s" % [
		corp.get("hand_count", 0), corp.get("deck_count", 0), (corp.get("discard", []) as Array).size()
	], _server_row(servers)))
	col.add_child(_section("Runner rig", _card_row(((runner.get("rig", {}) as Dictionary).get("program", []) as Array) + ((runner.get("rig", {}) as Dictionary).get("hardware", []) as Array) + ((runner.get("rig", {}) as Dictionary).get("resource", []) as Array), true)))
	var viewing := str(state.get("viewing", "runner"))
	var hand_src: Dictionary = corp if viewing == "corp" else runner
	col.add_child(_section("%s hand" % viewing.capitalize(), _card_row(hand_src.get("hand", []), true)))


func _section(title: String, body: Control) -> VBoxContainer:
	var box := VBoxContainer.new()
	var l := Label.new()
	l.text = title
	l.add_theme_color_override("font_color", DIM)
	box.add_child(l)
	box.add_child(body)
	return box


func _server_row(servers: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(_server_panel("HQ", servers.get("hq", {})))
	row.add_child(_server_panel("R&D", servers.get("rd", {})))
	row.add_child(_server_panel("Archives", servers.get("archives", {})))
	for remote: Variant in servers.get("remotes", []):
		if remote is Dictionary:
			row.add_child(_server_panel(str(remote.get("name", "Remote")), remote))
	return row


func _server_panel(name: String, server: Dictionary) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(140, 0)
	var title := Label.new()
	title.text = name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", GREEN)
	box.add_child(title)
	var ices: Array = server.get("ice", [])
	var content: Array = server.get("content", [])
	var corp_view := str(state.get("viewing", "")) == "corp"
	for card: Variant in ices:
		if card is Dictionary:
			box.add_child(_mini(card, _face_up(card, corp_view)))
	for card: Variant in content:
		if card is Dictionary:
			box.add_child(_mini(card, _face_up(card, corp_view)))
	if ices.is_empty() and content.is_empty():
		var empty := Label.new()
		empty.text = "—"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(empty)
	return box


func _face_up(card: Dictionary, corp_view: bool) -> bool:
	return corp_view or bool(card.get("rez", false)) or bool(card.get("rezzed", false)) or bool(card.get("faceUp", false)) or bool(card.get("seen", false))


func _card_row(cards: Array, face: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	for card: Variant in cards:
		if card is Dictionary:
			row.add_child(_mini(card, face))
	return row


func _mini(card: Dictionary, face: bool) -> Control:
	var wrap := VBoxContainer.new()
	var code := str(card.get("setNumber", card.get("code", "")))
	if code.length() > 2:
		code = code
	var path := "res://assets/cards/%s.png" % code
	if face and ResourceLoader.exists(path):
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(84, 118)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.texture = load(path)
		wrap.add_child(tex)
	else:
		var back := ColorRect.new()
		back.custom_minimum_size = Vector2(84, 118)
		back.color = Color(0.05, 0.12, 0.06)
		wrap.add_child(back)
		var l := Label.new()
		l.text = str(card.get("title", "??")) if face else "ICE"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l.custom_minimum_size = Vector2(84, 0)
		l.add_theme_color_override("font_color", GREEN)
		wrap.add_child(l)
	return wrap
