extends Control

const BG := Color(0.06, 0.07, 0.09)
const ACCENT := Color(0.92, 0.55, 0.18)
const TEXT := Color(0.88, 0.90, 0.93)
const DIM := Color(0.55, 0.60, 0.66)

var client: ClojureClient
var _clojure_ok := false
var _clojure_cards := 0
var _page := "play"
var _side := "runner"
var _matchup_key := "beginner"
var _search := ""
var _left: VBoxContainer
var _right: VBoxContainer
var _status: Label
var _search_box: LineEdit


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
	_fill(self)
	var bg := ColorRect.new()
	_fill(bg)
	bg.color = BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_build()
	client = ClojureClient.new()
	add_child(client)
	if not client.is_node_ready():
		await client.ready
	var st: Dictionary = await client.status()
	_clojure_ok = bool(st.get("ok", false))
	_clojure_cards = int(st.get("cards", 0))
	_paint()


func _build() -> void:
	var root := VBoxContainer.new()
	_fill(root, Vector4(28, 16, 28, 16))
	add_child(root)
	var top := HBoxContainer.new()
	root.add_child(top)
	top.add_child(_label("JINTEKI.NET", 28, ACCENT))
	top.add_child(_gap_h(24))
	top.add_child(_nav("PLAY", "play"))
	top.add_child(_nav("CARDS", "cards"))
	top.add_child(_nav("CHIRIBOGA", "chiriboga"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	top.add_child(_label("Godot  ·  github.com/mtgred/netrunner", 13, DIM))
	root.add_child(_gap(8))
	_status = _label("", 13, DIM)
	root.add_child(_status)
	root.add_child(_gap(8))
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 24)
	root.add_child(mid)
	_left = VBoxContainer.new()
	_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left.size_flags_stretch_ratio = 1.15
	_left.add_theme_constant_override("separation", 8)
	mid.add_child(_left)
	_right = VBoxContainer.new()
	_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right.add_theme_constant_override("separation", 8)
	mid.add_child(_right)


func _nav(text: String, page: String) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.add_theme_color_override("font_color", ACCENT)
	b.pressed.connect(func() -> void:
		if page == "chiriboga":
			_to_chiriboga()
			return
		_page = page
		_paint()
	)
	return b


func _paint() -> void:
	var pool := CardLibrary.jinteki_cards().size()
	var engine_line := "Clojure engine ON  ·  %s cards" % _clojure_cards if _clojure_ok else "Clojure engine OFF  ·  Godot rules + %s printed cards" % pool
	_status.text = engine_line
	_clear(_left)
	_clear(_right)
	if _page == "cards":
		_paint_cards()
	else:
		_paint_play()


func _paint_play() -> void:
	_left.add_child(_label("OFFICIAL MATCHUPS", 16, ACCENT))
	_left.add_child(_label("From mtgred/netrunner jinteki.preconstructed — Worlds, Classique, System Gateway.", 12, DIM, true))
	var list := ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.custom_minimum_size = Vector2(0, 280)
	var matchups := CardLibrary.matchups()
	var select := 0
	for i in matchups.size():
		var mu: Dictionary = matchups[i]
		var label := "%s  ·  %s vs %s" % [mu.get("label", mu.get("key")), mu.get("corp", {}).get("faction", ""), mu.get("runner", {}).get("faction", "")]
		list.add_item(label)
		list.set_item_metadata(i, str(mu.get("key", "")))
		if str(mu.get("key", "")) == _matchup_key:
			select = i
	if list.item_count > 0:
		list.select(select)
		_matchup_key = str(list.get_item_metadata(select))
	list.item_selected.connect(func(idx: int) -> void:
		_matchup_key = str(list.get_item_metadata(idx))
		_paint_play_side()
	)
	_left.add_child(list)
	_paint_play_side()


func _paint_play_side() -> void:
	_clear(_right)
	var mu := CardLibrary.matchup(_matchup_key)
	_right.add_child(_label("PLAY", 16, ACCENT))
	if mu.is_empty():
		_right.add_child(_label("No matchup loaded.", 13, DIM))
		return
	_right.add_child(_label(str(mu.get("label", "")), 18, TEXT, true))
	_right.add_child(_label("Corp  ·  %s  ·  %s (%s cards)" % [
		mu.get("corp", {}).get("name", ""), mu.get("corp", {}).get("identity_title", ""), mu.get("corp", {}).get("card_count", 0)
	], 13, DIM, true))
	_right.add_child(_label("Runner  ·  %s  ·  %s (%s cards)" % [
		mu.get("runner", {}).get("name", ""), mu.get("runner", {}).get("identity_title", ""), mu.get("runner", {}).get("card_count", 0)
	], 13, DIM, true))
	_right.add_child(_label("Agenda goal  %s" % mu.get("agenda_goal", 7), 13, TEXT))
	var you := OptionButton.new()
	you.add_item("You play Runner")
	you.set_item_metadata(0, "runner")
	you.add_item("You play Corp")
	you.set_item_metadata(1, "corp")
	you.select(0 if _side == "runner" else 1)
	you.item_selected.connect(func(idx: int) -> void:
		_side = str(you.get_item_metadata(idx))
	)
	_right.add_child(you)
	if _clojure_ok:
		_right.add_child(_btn("Play full Clojure engine", func() -> void: _start_clojure()))
	else:
		_right.add_child(_label("Start mtgred/netrunner with lein run (:1042) for 2065-card process-action rules.", 12, DIM, true))
	_right.add_child(_btn("Play Godot engine (printed stats)", func() -> void: _start_godot(false)))
	_right.add_child(_btn("Godot hotseat", func() -> void: _start_godot(true)))
	_right.add_child(_gap(12))
	_right.add_child(_label("SYSTEM GATEWAY TEACHING", 14, ACCENT))
	_right.add_child(_btn("Offline beginner  ·  Runner vs AI", func() -> void: _start_teaching(NREngine.RUNNER)))
	_right.add_child(_btn("Offline beginner  ·  Corp vs AI", func() -> void: _start_teaching(NREngine.CORP)))


func _paint_cards() -> void:
	_left.add_child(_label("CARD BROWSER", 16, ACCENT))
	_left.add_child(_label("%s cards from mtgred/netrunner data/cards.edn" % CardLibrary.jinteki_cards().size(), 12, DIM))
	_search_box = LineEdit.new()
	_search_box.placeholder_text = "Search title, faction, type…"
	_search_box.text = _search
	_search_box.text_changed.connect(func(t: String) -> void:
		_search = t
		_paint_card_list()
	)
	_left.add_child(_search_box)
	_paint_card_list()
	_right.add_child(_label("NSG / FFG card texts. Art only for System Gateway scans in assets/cards/.", 12, DIM, true))


func _paint_card_list() -> void:
	for child in _left.get_children():
		if child is ScrollContainer:
			child.queue_free()
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	var q := _search.to_lower()
	var n := 0
	var cards := CardLibrary.jinteki_cards().values()
	cards.sort_custom(func(a: Variant, b: Variant) -> bool:
		return str((a as Dictionary).get("title", "")) < str((b as Dictionary).get("title", ""))
	)
	for item: Variant in cards:
		if n >= 80:
			box.add_child(_label("… %s more. Narrow the search." % (cards.size() - n), 12, DIM))
			break
		if not item is Dictionary:
			continue
		var c: Dictionary = item
		var blob := "%s %s %s %s" % [c.get("title", ""), c.get("type", ""), c.get("faction", ""), c.get("text", "")]
		if q != "" and blob.to_lower().find(q) < 0:
			continue
		n += 1
		box.add_child(_label("%s  ·  %s  ·  %s  ·  %s" % [c.get("title", ""), c.get("type", ""), c.get("faction", ""), c.get("code", "")], 13, TEXT, true))
		var tx := str(c.get("text", "")).replace("[credit]", "c").replace("<li>", " • ")
		if tx != "":
			box.add_child(_label(tx.substr(0, 220), 11, DIM, true))


func _start_clojure() -> void:
	var packed := load("res://scenes/clojure_board.tscn") as PackedScene
	var board := packed.instantiate()
	board.set("mode", _side)
	board.set("payload", {
		"mode": "precon",
		"matchup": _matchup_key,
		"side": _side,
		"agenda_goal": int(CardLibrary.matchup(_matchup_key).get("agenda_goal", 7)),
	})
	get_tree().root.add_child(board)
	queue_free()


func _start_godot(hotseat: bool) -> void:
	var packed := load("res://scenes/board.tscn") as PackedScene
	var board := packed.instantiate()
	board.set("mode", "hotseat" if hotseat else _side)
	board.set("decks", CardLibrary.decks_for(_matchup_key))
	board.set("card_db", CardLibrary.jinteki_cards())
	get_tree().root.add_child(board)
	queue_free()


func _start_teaching(side: String) -> void:
	var packed := load("res://scenes/board.tscn") as PackedScene
	var board := packed.instantiate()
	board.set("mode", side)
	get_tree().root.add_child(board)
	queue_free()


func _to_chiriboga() -> void:
	var packed := load("res://scenes/chiriboga_title.tscn") as PackedScene
	get_tree().root.add_child(packed.instantiate())
	queue_free()


func _label(text: String, size: int, color: Color, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
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


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(cb)
	return b


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
