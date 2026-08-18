class_name HUD
extends CanvasLayer

var lives_label: Label
var score_label: Label
var stage_label: Label
var enemy_label: Label
var banner: Label
var hint: Label


func _ready() -> void:
	layer = 10
	var sidebar := ColorRect.new()
	sidebar.color = Color("1c1c22")
	sidebar.position = Vector2(416, 0)
	sidebar.size = Vector2(96, 416)
	add_child(sidebar)

	var border := ColorRect.new()
	border.color = Color("3a3a44")
	border.position = Vector2(416, 0)
	border.size = Vector2(2, 416)
	add_child(border)

	stage_label = _make_label(Vector2(428, 18), 14, Color("f0d878"))
	lives_label = _make_label(Vector2(428, 70), 13, Color("9ee08a"))
	enemy_label = _make_label(Vector2(428, 122), 13, Color("e08a8a"))
	score_label = _make_label(Vector2(428, 174), 13, Color("d0d0d8"))
	banner = _make_label(Vector2(40, 170), 28, Color("ffe680"))
	banner.size = Vector2(336, 48)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.visible = false
	hint = _make_label(Vector2(40, 222), 14, Color("c8c8d0"))
	hint.size = Vector2(336, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.visible = false

	var help := _make_label(Vector2(428, 250), 11, Color("8a8a96"))
	help.text = "WASD 移动\n空格 射击\nP 暂停\n闪光坦克\n掉落道具"


func _make_label(pos: Vector2, size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	return label


func refresh(stage: int, lives: int, score: int, remaining: int, alive: int) -> void:
	stage_label.text = "关卡 %02d" % stage
	lives_label.text = "生命 %d" % lives
	enemy_label.text = "敌军 %d\n战场 %d" % [remaining, alive]
	score_label.text = "得分\n%d" % score


func show_banner(text: String, sub: String = "") -> void:
	banner.text = text
	banner.visible = true
	hint.text = sub
	hint.visible = not sub.is_empty()


func hide_banner() -> void:
	banner.visible = false
	hint.visible = false
