extends Control

var mode := "runner"
var payload: Dictionary = {}
var client: ClojureClient
var game_id := ""
var state: Dictionary = {}
var human := "runner"
var log_box: RichTextLabel
var action_box: VBoxContainer
var table: Control
var status: Label
var _busy := false
var _notice := ""
var _ai_steps := 0


func _ready() -> void:
	if payload.has("side") and str(payload["side"]) != "":
		mode = str(payload["side"])
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
	client = ClojureClient.new()
	add_child(client)
	if not client.is_node_ready():
		await client.ready
	_notice = "Connecting to Clojure engine at %s …" % client.base_url
	_refresh()
	var created: Dictionary
	if payload.is_empty():
		created = await client.new_game(6)
	else:
		created = await client.new_game(payload)
	if not bool(created.get("ok", false)) or str(created.get("id", "")) == "":
		_notice = "Clojure engine unavailable: %s" % created.get("error", client.last_error)
		_refresh()
		return
	game_id = str(created["id"])
	state = created
	_notice = ""
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
	side.custom_minimum_size = Vector2(340, 0)
	side.add_theme_constant_override("separation", 8)
	mid.add_child(side)
	var actions_title := Label.new()
	actions_title.text = "Clojure actions"
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
	if _notice != "":
		return _notice
	if state.is_empty():
		return "Waiting for Clojure engine…"
	if str(state.get("winner", "")) != "":
		return "%s wins — %s" % [str(state["winner"]).capitalize(), state.get("reason", "")]
	var vs := "Hotseat" if mode == "hotseat" else ("AI vs AI" if mode == "watch" else "vs Clojure AI")
	var corp: Dictionary = state.get("corp", {})
	var runner: Dictionary = state.get("runner", {})
	return "%s  ·  Turn %s  ·  %s    Corp %dc / %dcl / %dAP    Runner %dc / %dcl / %dAP  MU %s/%s" % [
		vs,
		state.get("turn", 0),
		str(state.get("active", "?")).capitalize(),
		int(corp.get("credits", 0)), int(corp.get("clicks", 0)), int(corp.get("agenda_points", 0)),
		int(runner.get("credits", 0)), int(runner.get("clicks", 0)), int(runner.get("agenda_points", 0)),
		runner.get("memory_used", 0), runner.get("memory_base", 4),
	]


func _paint_log() -> void:
	var lines: PackedStringArray = PackedStringArray()
	if state.has("prompt") and state["prompt"] is Dictionary:
		var p: Dictionary = state["prompt"]
		lines.append("[b]%s:[/b] %s" % [p.get("side", ""), p.get("msg", "")])
	var log_items: Array = state.get("log", [])
	var start: int = maxi(0, log_items.size() - 14)
	for i in range(start, log_items.size()):
		lines.append(str(log_items[i]))
	if str(state.get("error", "")) != "":
		lines.append("[color=#f88]engine: %s[/color]" % state["error"])
	log_box.text = "\n".join(lines)


func _paint_actions() -> void:
	for child in action_box.get_children():
		child.queue_free()
	if _notice != "":
		var err := Label.new()
		err.text = _notice
		err.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		action_box.add_child(err)
		return
	if str(state.get("winner", "")) != "":
		var done := Label.new()
		done.text = str(state.get("reason", "Game over"))
		action_box.add_child(done)
		return
	if _ai_to_move():
		var wait := Label.new()
		wait.text = "Clojure AI thinking…"
		action_box.add_child(wait)
		return
	for item: Variant in state.get("actions", []):
		if item is Dictionary:
			var b := Button.new()
			b.text = str(item.get("label", item.get("command", "?")))
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var captured: Dictionary = item
			b.pressed.connect(func() -> void: _do(captured))
			action_box.add_child(b)


func _do(act: Dictionary) -> void:
	if _busy or game_id == "" or _ai_to_move():
		return
	_ai_steps = 0
	_busy = true
	var next_state := await client.action(game_id, act)
	_busy = false
	if bool(next_state.get("ok", false)) or next_state.has("actions"):
		state = next_state
	else:
		_notice = str(next_state.get("error", "action failed"))
	_refresh()
	_maybe_ai()


func _first_command(names: Array) -> Dictionary:
	for item: Variant in state.get("actions", []):
		if item is Dictionary and str(item.get("command", "")) in names:
			return item
	return {}


func _ai_to_move() -> bool:
	if mode == "hotseat" or str(state.get("winner", "")) != "" or state.is_empty():
		return false
	return ClojureAi.actor(state) != human


func _maybe_ai() -> void:
	if not _ai_to_move() or game_id == "":
		_ai_steps = 0
		return
	if _ai_steps >= 16:
		var forced := _first_command(["end-turn", "start-turn", "end-phase-12"])
		if not forced.is_empty() and _ai_steps < 18:
			_ai_steps = 18
			_busy = true
			state = await client.action(game_id, forced)
			_busy = false
			_refresh()
			if _ai_to_move():
				_maybe_ai()
			return
		_busy = false
		_refresh()
		return
	_busy = true
	await get_tree().create_timer(0.08).timeout
	var act := ClojureAi.pick(state, ClojureAi.actor(state))
	if act.is_empty():
		_busy = false
		_refresh()
		return
	var before := JSON.stringify(state.get("actions", []))
	var next_state := await client.action(game_id, act)
	_ai_steps += 1
	_busy = false
	if bool(next_state.get("ok", false)) or next_state.has("actions"):
		state = next_state
	_refresh()
	if JSON.stringify(state.get("actions", [])) == before:
		return
	if _ai_to_move():
		_maybe_ai()


func _paint_table() -> void:
	for child in table.get_children():
		child.queue_free()
	var col := VBoxContainer.new()
	col.set_anchors_preset(PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 8)
	table.add_child(col)
	var corp: Dictionary = state.get("corp", {})
	var runner: Dictionary = state.get("runner", {})
	var servers: Dictionary = state.get("servers", {})
	col.add_child(_section("Corp HQ %s  ·  R&D %s  ·  Archives %s" % [
		corp.get("hand_count", 0), corp.get("deck_count", 0), (corp.get("discard", []) as Array).size()
	], _server_row(servers)))
	col.add_child(_section("Runner rig", _rig_row(runner.get("rig", {}))))
	var hand_who := ClojureAi.actor(state) if mode == "hotseat" else human
	if hand_who == "":
		hand_who = "runner"
	var hand_src: Dictionary = corp if hand_who == "corp" else runner
	col.add_child(_section("%s hand" % hand_who.capitalize(), _hand_row(hand_src.get("hand", []))))


func _section(title: String, body: Control) -> VBoxContainer:
	var box := VBoxContainer.new()
	var l := Label.new()
	l.text = title
	l.add_theme_color_override("font_color", Color(0.5, 0.74, 0.88))
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
	box.custom_minimum_size = Vector2(150, 0)
	var title := Label.new()
	title.text = name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var ices: Array = server.get("ices", [])
	var content: Array = server.get("content", [])
	for card: Variant in ices:
		if card is Dictionary:
			box.add_child(_mini_card(card, bool(card.get("rezzed", false)) or human == "corp" or mode == "hotseat"))
	for card: Variant in content:
		if card is Dictionary:
			box.add_child(_mini_card(card, bool(card.get("rezzed", false)) or human == "corp" or mode == "hotseat"))
	if ices.is_empty() and content.is_empty():
		var empty := Label.new()
		empty.text = "—"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(empty)
	return box


func _rig_row(rig: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	if not rig is Dictionary:
		return row
	for key in ["program", "hardware", "resource"]:
		for card: Variant in rig.get(key, []):
			if card is Dictionary:
				row.add_child(_mini_card(card, true))
	return row


func _hand_row(cards: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	for card: Variant in cards:
		if card is Dictionary:
			row.add_child(_mini_card(card, true))
	return row


func _mini_card(card: Dictionary, face: bool) -> Control:
	var wrap := VBoxContainer.new()
	var code := str(card.get("code", ""))
	var path := "res://assets/cards/%s.png" % code
	if face and code != "" and ResourceLoader.exists(path):
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(90, 126)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.texture = load(path)
		wrap.add_child(tex)
	else:
		var back := ColorRect.new()
		back.custom_minimum_size = Vector2(90, 126)
		back.color = Color(0.12, 0.18, 0.26) if face else Color(0.08, 0.12, 0.18)
		wrap.add_child(back)
		var l := Label.new()
		l.text = str(card.get("title", "??")) if face else ("ICE" if str(card.get("type", "")) == "ICE" else "??")
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(90, 0)
		wrap.add_child(l)
	if int(card.get("advancement", 0)) > 0:
		var adv := Label.new()
		adv.text = "adv %d" % int(card["advancement"])
		adv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wrap.add_child(adv)
	return wrap
