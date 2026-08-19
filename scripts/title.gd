extends Control

const BG := Color(0.04, 0.08, 0.12)
const ACCENT := Color(0.36, 0.68, 0.89)


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = BG
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, 40)
	box.add_child(pad)
	box.add_child(_label("JINTEKI", 48, ACCENT))
	box.add_child(_label("Android: Netrunner  ·  System Gateway beginner", 18, Color(0.75, 0.82, 0.88)))
	box.add_child(_label("Godot port of github.com/mtgred/netrunner", 14, Color(0.5, 0.58, 0.64)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	row.add_child(_btn("Play as Runner", func() -> void: _start(NREngine.RUNNER)))
	row.add_child(_btn("Play as Corp", func() -> void: _start(NREngine.CORP)))
	row.add_child(_btn("Hotseat", func() -> void: _start("hotseat")))
	box.add_child(_label("Starter decks play to 6 agenda points.  Click actions on the right.", 14, Color(0.55, 0.62, 0.68)))


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(180, 40)
	b.pressed.connect(cb)
	return b


func _start(mode: String) -> void:
	var packed := load("res://scenes/board.tscn") as PackedScene
	var board := packed.instantiate()
	board.set("mode", mode)
	get_tree().root.add_child(board)
	queue_free()
