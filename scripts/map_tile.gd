class_name MapTile
extends StaticBody2D

enum Kind { BRICK, STEEL, WATER, ICE }

var kind: Kind = Kind.BRICK
var is_fortress := false
var sprite: Sprite2D
var shape: CollisionShape2D


func configure(tile_kind: Kind, tex: Texture2D) -> void:
	kind = tile_kind
	position += Vector2(GameArt.TILE, GameArt.TILE) * 0.5
	sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(GameArt.TILE, GameArt.TILE)
	shape.shape = rect
	add_child(shape)
	_apply_physics()


func _apply_physics() -> void:
	match kind:
		Kind.WATER:
			collision_layer = 16
			collision_mask = 0
			if shape:
				shape.disabled = false
		Kind.ICE:
			collision_layer = 0
			collision_mask = 0
			if shape:
				shape.disabled = true
			add_to_group("ice")
		_:
			collision_layer = 1
			collision_mask = 0
			if shape:
				shape.disabled = false
			if is_in_group("ice"):
				remove_from_group("ice")


func set_kind(tile_kind: Kind) -> void:
	kind = tile_kind
	if sprite:
		match kind:
			Kind.STEEL:
				sprite.texture = GameArt.steel_tex
			Kind.BRICK:
				sprite.texture = GameArt.brick_tex
			Kind.WATER:
				sprite.texture = GameArt.water_tex
			Kind.ICE:
				sprite.texture = GameArt.ice_tex
	_apply_physics()


func take_hit(power: int = 1) -> bool:
	if kind == Kind.WATER or kind == Kind.ICE:
		return false
	if kind == Kind.STEEL:
		if power < 3:
			return false
	queue_free()
	return true
