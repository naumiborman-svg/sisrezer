class_name Eagle
extends StaticBody2D

var destroyed := false
var sprite: Sprite2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("eagle")
	sprite = Sprite2D.new()
	sprite.texture = GameArt.eagle_tex
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(22, 22)
	shape.shape = rect
	add_child(shape)


func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	sprite.texture = GameArt.eagle_dead_tex
	GameArt.play(GameArt.sfx_boom, 0.0)
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("spawn_explosion"):
		game.spawn_explosion(global_position)
	if game and game.has_method("on_eagle_destroyed"):
		game.on_eagle_destroyed()
