extends Control


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("08080c")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "坦克大战"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 90)
	title.size = Vector2(512, 64)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("f0d060"))
	add_child(title)

	var sub := Label.new()
	sub.text = "BATTLE CITY"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 148)
	sub.size = Vector2(512, 28)
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color("c8b070"))
	add_child(sub)

	var tank := Sprite2D.new()
	tank.texture = GameArt.player_tex
	tank.position = Vector2(256, 220)
	tank.scale = Vector2(2, 2)
	add_child(tank)

	var enemy := Sprite2D.new()
	enemy.texture = GameArt.enemy_basic_tex
	enemy.position = Vector2(196, 220)
	enemy.rotation = PI * 0.5
	add_child(enemy)

	var armor := Sprite2D.new()
	armor.texture = GameArt.enemy_armor_tex
	armor.position = Vector2(316, 220)
	armor.rotation = -PI * 0.5
	add_child(armor)

	var prompt := Label.new()
	prompt.text = "按 Enter 开始"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(0, 268)
	prompt.size = Vector2(512, 28)
	prompt.add_theme_font_size_override("font_size", 18)
	prompt.add_theme_color_override("font_color", Color("f8f0c8"))
	add_child(prompt)
	var tw := create_tween().set_loops()
	tw.tween_property(prompt, "modulate:a", 0.25, 0.6)
	tw.tween_property(prompt, "modulate:a", 1.0, 0.6)

	var help := Label.new()
	help.text = "WASD / 方向键 移动    空格 / J 射击\n35 关原作地图 · 四种敌军 · 星星升级\n闪光坦克掉落道具，保护老鹰基地"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.position = Vector2(40, 318)
	help.size = Vector2(432, 70)
	help.add_theme_font_size_override("font_size", 13)
	help.add_theme_color_override("font_color", Color("9aa0aa"))
	add_child(help)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start") or event.is_action_pressed("fire"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
