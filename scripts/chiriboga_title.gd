extends Control

const BG := Color(0.015, 0.035, 0.02)
const GREEN := Color(0.2, 1.0, 0.2)
const DIM := Color(0.35, 0.65, 0.35)
const MUTED := Color(0.28, 0.48, 0.28)

var client: ChiribogaClient
var catalog: Dictionary = {}
var preview: Dictionary = {}
var settings: Dictionary = {}
var _left: VBoxContainer
var _preview_box: VBoxContainer
var _host_ok := false
var _threat := 1


func _ready() -> void:
	settings = ChiribogaSave.settings()
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = BG
	add_child(bg)
	_build_chrome()
	if bool(settings.get("crt", true)):
		_add_scanlines()
	client = ChiribogaClient.new()
	add_child(client)
	if not client.is_node_ready():
		await client.ready
	_load_catalog()


func _add_scanlines() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/crt_scanlines.gdshader")
	overlay.material = mat
	overlay.color = Color(1, 1, 1, 1)
	add_child(overlay)


func _build_chrome() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(PRESET_FULL_RECT)
	root.offset_left = 36
	root.offset_top = 18
	root.offset_right = -36
	root.offset_bottom = -18
	add_child(root)
	var top := HBoxContainer.new()
	root.add_child(top)
	top.add_child(_label("CH1R180G4 SYSTEMS v2.71 // NEURAL INTERFACE READY", 13, MUTED))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	top.add_child(_label("BUILD 0.6.13-BETA // 2077.08.19", 13, MUTED))
	root.add_child(_gap(8))
	root.add_child(_label("NETRUNNER", 56, GREEN))
	root.add_child(_label("$0LØ MOÐ3", 30, GREEN))
	root.add_child(_gap(10))
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 36)
	root.add_child(mid)
	_left = VBoxContainer.new()
	_left.custom_minimum_size = Vector2(420, 0)
	_left.add_theme_constant_override("separation", 8)
	mid.add_child(_left)
	_preview_box = VBoxContainer.new()
	_preview_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_box.alignment = BoxContainer.ALIGNMENT_CENTER
	mid.add_child(_preview_box)
	var bottom := HBoxContainer.new()
	root.add_child(bottom)
	var cred := _text_btn("CREDITS", func() -> void: _show_credits())
	bottom.add_child(cred)
	bottom.add_child(_gap_h(24))
	bottom.add_child(_label("THREAT LEVEL: %s" % _threat, 13, GREEN))
	bottom.add_child(_gap_h(24))
	bottom.add_child(_label("IP: 127.0.0.1", 13, MUTED))
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(fill)
	bottom.add_child(_text_btn("LEGACY JINTEKI", func() -> void: _legacy()))
	_show_main()


func _show_main() -> void:
	_clear(_left)
	_left.add_child(_menu_btn("QUICK GAME", func() -> void: _start_quick()))
	_left.add_child(_menu_btn("CUSTOM GAME", func() -> void: _show_custom()))
	_left.add_child(_menu_btn("GAUNTLET", func() -> void: _show_gauntlet()))
	_left.add_child(_menu_btn("TUTORIAL", func() -> void: _show_tutorial()))
	_left.add_child(_menu_btn("ACHIEVEMENTS [%s%%]" % ChiribogaSave.percent(), func() -> void: _show_achievements()))
	_left.add_child(_menu_btn("SETTINGS", func() -> void: _show_settings()))
	_paint_preview()


func _paint_preview() -> void:
	_clear(_preview_box)
	var title := _label("QUICK GAME\nINCOMING..", 20, GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_box.add_child(title)
	if preview.is_empty():
		_preview_box.add_child(_label("Connecting Chiriboga host :1043 …" if not _host_ok else "Rerolling pair…", 14, DIM))
		return
	var player: Dictionary = preview.get("player", {})
	var ai: Dictionary = preview.get("ai", {})
	_preview_box.add_child(_portrait("YOU", player))
	_preview_box.add_child(_label("VS", 28, GREEN))
	_preview_box.add_child(_portrait("CPU", ai))
	var reroll := _menu_btn("REROLL MATCHUP", func() -> void: _reroll())
	_preview_box.add_child(reroll)


func _portrait(who: String, deck: Dictionary) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_child(_label(who, 12, MUTED))
	var code := str(deck.get("identity", ""))
	var path := "res://assets/cards/%s.png" % code
	if ResourceLoader.exists(path):
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(160, 224)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.texture = load(path)
		box.add_child(tex)
	else:
		var rect := ColorRect.new()
		rect.custom_minimum_size = Vector2(160, 80)
		rect.color = Color(0.04, 0.12, 0.05)
		box.add_child(rect)
	box.add_child(_label(str(deck.get("name", "—")), 16, GREEN))
	box.add_child(_label(str(deck.get("identity_title", "")), 13, DIM))
	box.add_child(_label(str(deck.get("faction", "")), 12, MUTED))
	return box


func _load_catalog() -> void:
	var st: Dictionary = await client.status()
	_host_ok = bool(st.get("ok", false))
	if not _host_ok:
		preview = {}
		_paint_preview()
		return
	catalog = await client.catalog()
	if catalog.has("preview"):
		var p: Variant = catalog["preview"]
		if p is Dictionary:
			preview = p
	_paint_preview()


func _reroll() -> void:
	var p: Dictionary = await client.preview()
	if bool(p.get("ok", false)):
		preview = p
	_paint_preview()


func _start_quick() -> void:
	var payload := {"mode": "quick"}
	if not preview.is_empty():
		payload["player_deck"] = str(preview.get("player", {}).get("name", ""))
		payload["ai_deck"] = str(preview.get("ai", {}).get("name", ""))
		payload["side"] = str(preview.get("side", "runner"))
	_start(payload)


func _show_custom() -> void:
	_clear(_left)
	_left.add_child(_label("CUSTOM GAME", 22, GREEN))
	var runners := _precons("runner", true)
	var corps := _precons("corp", true)
	_left.add_child(_label("YOUR DECK", 13, MUTED))
	var you := OptionButton.new()
	for deck: Dictionary in runners + corps:
		you.add_item("%s  ·  %s" % [deck.get("name", ""), deck.get("faction", "")])
		you.set_item_metadata(you.item_count - 1, deck)
	_left.add_child(you)
	_left.add_child(_label("CPU DECK", 13, MUTED))
	var cpu := OptionButton.new()
	for deck: Dictionary in corps + runners:
		cpu.add_item("%s  ·  %s" % [deck.get("name", ""), deck.get("faction", "")])
		cpu.set_item_metadata(cpu.item_count - 1, deck)
	_left.add_child(cpu)
	_left.add_child(_menu_btn("LAUNCH", func() -> void:
		var a: Variant = you.get_selected_metadata()
		var b: Variant = cpu.get_selected_metadata()
		var payload := {"mode": "custom"}
		if a is Dictionary:
			payload["player_deck"] = str(a.get("name", ""))
			payload["side"] = str(a.get("side", "runner"))
		if b is Dictionary:
			payload["ai_deck"] = str(b.get("name", ""))
		_start(payload)
	))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_gauntlet() -> void:
	_clear(_left)
	_left.add_child(_label("GAUNTLET", 22, GREEN))
	_left.add_child(_label("Sequential corp opponents. Shop / hack / perks from gauntlet.php stay on the JS host as match chain.", 13, DIM))
	var length := int(settings.get("gauntlet_length", 4))
	_left.add_child(_label("LENGTH  %s" % length, 14, GREEN))
	_left.add_child(_menu_btn("NEW", func() -> void:
		_start({"mode": "gauntlet", "side": "runner", "gauntlet_length": length})
	))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_tutorial() -> void:
	_clear(_left)
	_left.add_child(_label("TUTORIAL", 22, GREEN))
	var lessons := [
		"CLICKS & RUNS",
		"CREDITS & CARD TYPES",
		"ICE & ICEBREAKERS",
		"ASSETS & TRASH COSTS",
		"ADVANCING & SCORING",
		"UPGRADES & ROOT",
		"VS CORP STARTER DECK",
		"VS RUNNER STARTER DECK",
	]
	for i in lessons.size():
		var idx := i
		_left.add_child(_menu_btn("%s  %s" % [idx + 1, lessons[i]], func() -> void:
			_start({"mode": "tutorial", "mentor": idx})
		))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_achievements() -> void:
	_clear(_left)
	_left.add_child(_label("ACHIEVEMENTS", 22, GREEN))
	var data := ChiribogaSave.achievements()
	_left.add_child(_label("HIGH SCORES", 13, MUTED))
	for item: Variant in data.get("high_scores", []):
		if item is Dictionary:
			_left.add_child(_label("%s" % item.get("score", 0), 14, DIM))
	_left.add_child(_label("ACHIEVEMENTS", 13, MUTED))
	for item: Variant in data.get("achievements", []):
		if item is Dictionary:
			var mark := "■" if bool(item.get("achieved", false)) else "□"
			_left.add_child(_label("%s  %s" % [mark, item.get("name", "")], 14, GREEN if bool(item.get("achieved", false)) else MUTED))
			_left.add_child(_label(str(item.get("description", "")), 12, DIM))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_settings() -> void:
	_clear(_left)
	_left.add_child(_label("SETTINGS", 22, GREEN))
	_left.add_child(_label("GLOBAL SETTINGS", 13, MUTED))
	_left.add_child(_toggle("CRT EFFECTS", "crt"))
	_left.add_child(_label("GAUNTLET SETTINGS", 13, MUTED))
	var row := HBoxContainer.new()
	var minus := _menu_btn("−", func() -> void:
		settings["gauntlet_length"] = maxi(4, int(settings.get("gauntlet_length", 4)) - 4)
		ChiribogaSave.save_settings(settings)
		_show_settings()
	)
	minus.custom_minimum_size = Vector2(48, 32)
	var plus := _menu_btn("+", func() -> void:
		settings["gauntlet_length"] = mini(12, int(settings.get("gauntlet_length", 4)) + 4)
		ChiribogaSave.save_settings(settings)
		_show_settings()
	)
	plus.custom_minimum_size = Vector2(48, 32)
	row.add_child(minus)
	row.add_child(_label("  LENGTH  %s  " % settings.get("gauntlet_length", 4), 16, GREEN))
	row.add_child(plus)
	_left.add_child(row)
	_left.add_child(_label("Engine host  %s" % client.base_url, 12, DIM))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_credits() -> void:
	_clear(_left)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	box.add_child(_label("CREDITS", 22, GREEN))
	box.add_child(_label("This Netrunner Solo Mode extension for the Chiriboga engine is developed by DrBo6. It adds a more refined interface and game modes.", 13, DIM))
	box.add_child(_label("Chiriboga is a Netrunner engine developed by bobtheuberfish. It implements Android: Netrunner gameplay with an AI opponent.", 13, DIM))
	box.add_child(_label("Godot replica drives the original JS engine headless (text mode) over HTTP :1043.", 13, DIM))
	box.add_child(_label("Card art & symbols are property of Null Signal Games, used under CC BY-ND 4.0. Fan implementation, not endorsed by NSG / FFG / WotC.", 13, DIM))
	box.add_child(_label("GPL-3.0  ·  chiriboga.cronbach.com  ·  github.com/bobtheuberfish/chiriboga  ·  github.com/drbo6/chiriboga", 12, MUTED))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _toggle(label: String, key: String) -> Button:
	var on := bool(settings.get(key, false))
	return _menu_btn("%s  [%s]" % [label, "ON" if on else "OFF"], func() -> void:
		settings[key] = not bool(settings.get(key, false))
		ChiribogaSave.save_settings(settings)
		_show_settings()
	)


func _precons(side: String, custom_only: bool) -> Array:
	var out: Array = []
	for item: Variant in catalog.get("precons", []):
		if item is Dictionary:
			if str(item.get("side", "")) != side:
				continue
			if custom_only and not bool(item.get("useForCustomGame", true)):
				continue
			out.append(item)
	return out


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _gap(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _gap_h(w: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, 0)
	return c


func _style_btn(b: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.03, 0.08, 0.04, 0.85)
	normal.border_color = Color(0.2, 0.55, 0.2)
	normal.set_border_width_all(1)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var hover := normal.duplicate()
	hover.bg_color = Color(0.06, 0.16, 0.07, 0.95)
	hover.border_color = GREEN
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", GREEN)
	b.add_theme_color_override("font_hover_color", Color(0.55, 1, 0.55))
	b.add_theme_font_size_override("font_size", 16)


func _menu_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 36)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_style_btn(b)
	b.pressed.connect(cb)
	return b


func _text_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.add_theme_color_override("font_color", DIM)
	b.pressed.connect(cb)
	return b


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _start(payload: Dictionary) -> void:
	var packed := load("res://scenes/chiriboga_board.tscn") as PackedScene
	var board := packed.instantiate()
	board.set("payload", payload)
	get_tree().root.add_child(board)
	queue_free()


func _legacy() -> void:
	var packed := load("res://scenes/title.tscn") as PackedScene
	get_tree().root.add_child(packed.instantiate())
	queue_free()
