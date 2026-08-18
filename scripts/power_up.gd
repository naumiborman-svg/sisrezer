class_name PowerUp
extends Area2D

enum Kind { LIFE, STAR, GRENADE, TIMER, HELMET, SHOVEL }

var kind: Kind = Kind.STAR


func configure(power_kind: Kind) -> void:
	kind = power_kind
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	var sprite := Sprite2D.new()
	sprite.texture = GameArt.powerup_tex(int(kind))
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 14)
	shape.shape = rect
	add_child(shape)
	body_entered.connect(_on_body)
	var blink := create_tween().set_loops()
	blink.tween_property(sprite, "modulate:a", 0.25, 0.12)
	blink.tween_property(sprite, "modulate:a", 1.0, 0.12)


func _on_body(body: Node) -> void:
	if body is PlayerTank:
		var game := get_tree().get_first_node_in_group("game")
		if game and game.has_method("collect_power_up"):
			game.collect_power_up(kind)
		queue_free()
