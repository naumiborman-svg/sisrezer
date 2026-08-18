class_name MapTile
extends StaticBody2D

enum Kind { BRICK, STEEL, WATER }

var kind: Kind = Kind.BRICK


func configure(tile_kind: Kind, tex: Texture2D) -> void:
	kind = tile_kind
	position += Vector2(GameArt.TILE, GameArt.TILE) * 0.5
	var sprite := Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(GameArt.TILE, GameArt.TILE)
	shape.shape = rect
	add_child(shape)
	match kind:
		Kind.WATER:
			collision_layer = 16
			collision_mask = 0
		_:
			collision_layer = 1
			collision_mask = 0


func take_hit() -> bool:
	if kind == Kind.STEEL or kind == Kind.WATER:
		return false
	queue_free()
	return true
