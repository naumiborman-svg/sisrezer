class_name Tank
extends CharacterBody2D

enum Heading { UP, DOWN, LEFT, RIGHT }

const SIZE := 32

@export var move_speed := 90.0
@export var fire_cooldown := 0.45
@export var max_hp := 1
@export var team := 0

var heading: Heading = Heading.UP
var hp := 1
var can_fire := true
var frozen := false
var sprite: Sprite2D
var _cooldown_left := 0.0


func _init() -> void:
	collision_layer = 2
	collision_mask = 1 | 2 | 8 | 16
	motion_mode = MOTION_MODE_FLOATING


func setup_visual(tex: Texture2D) -> void:
	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = true
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	add_child(shape)
	hp = max_hp


func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left -= delta
		if _cooldown_left <= 0.0:
			can_fire = true


func set_heading(next: Heading) -> void:
	heading = next
	if sprite:
		sprite.rotation = heading_angle(heading)


func heading_vector(h: Heading = heading) -> Vector2:
	match h:
		Heading.UP:
			return Vector2.UP
		Heading.DOWN:
			return Vector2.DOWN
		Heading.LEFT:
			return Vector2.LEFT
		_:
			return Vector2.RIGHT


static func heading_angle(h: Heading) -> float:
	match h:
		Heading.UP:
			return 0.0
		Heading.RIGHT:
			return PI * 0.5
		Heading.DOWN:
			return PI
		_:
			return -PI * 0.5


func try_fire() -> bool:
	if frozen or not can_fire or not is_inside_tree():
		return false
	var game := get_tree().get_first_node_in_group("game")
	if game == null or not game.has_method("spawn_bullet"):
		return false
	can_fire = false
	_cooldown_left = fire_cooldown
	var muzzle := global_position + heading_vector() * 16.0
	game.spawn_bullet(muzzle, heading_vector(), self)
	GameArt.play(GameArt.sfx_shoot, -6.0)
	return true


func take_hit(from_team: int) -> void:
	if frozen:
		return
	if from_team == team:
		return
	hp -= 1
	if sprite:
		_flash()
	if hp <= 0:
		die()


func _flash() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(2, 2, 2, 1), 0.05)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.08)


func die() -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("spawn_explosion"):
		game.spawn_explosion(global_position)
	GameArt.play(GameArt.sfx_boom, -2.0)
	queue_free()
