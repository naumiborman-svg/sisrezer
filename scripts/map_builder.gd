class_name MapBuilder
extends Node2D

var fortress_tiles: Array[MapTile] = []
var fortress_cells: Array[Vector2] = []


func build(stage_index: int) -> Dictionary:
	var raw := StageBook.map_text(stage_index)
	var lines: PackedStringArray = PackedStringArray()
	for line in raw.split("\n"):
		if line.is_empty():
			continue
		lines.append(line)
	var result := {
		"player": Vector2(4 * 32 + 16, 12 * 32 + 16),
		"spawns": [
			Vector2(16, 16),
			Vector2(6 * 32 + 16, 16),
			Vector2(12 * 32 + 16, 16),
		],
		"eagle": Vector2(6 * 32 + 16, 12 * 32 + 16),
	}
	var eagle_cells: Array[Vector2] = []
	var tiles: Array[MapTile] = []
	for y in lines.size():
		var row := lines[y]
		for x in row.length():
			var ch := row[x]
			var cell := Vector2(x * GameArt.TILE, y * GameArt.TILE)
			match ch:
				"#":
					tiles.append(_add_tile(cell, MapTile.Kind.BRICK, GameArt.brick_tex))
				"@":
					tiles.append(_add_tile(cell, MapTile.Kind.STEEL, GameArt.steel_tex))
				"~":
					tiles.append(_add_tile(cell, MapTile.Kind.WATER, GameArt.water_tex))
				"=":
					tiles.append(_add_tile(cell, MapTile.Kind.ICE, GameArt.ice_tex))
				"%":
					_add_bush(cell)
				"E":
					eagle_cells.append(cell)
				".":
					pass
				_:
					push_warning("Unknown map char: %s" % ch)
	if not eagle_cells.is_empty():
		var center := Vector2.ZERO
		for c in eagle_cells:
			center += c
		center /= float(eagle_cells.size())
		result["eagle"] = center + Vector2(GameArt.TILE, GameArt.TILE) * 0.5
		for tile in tiles:
			for c in eagle_cells:
				if tile.position.distance_to(c + Vector2(GameArt.TILE, GameArt.TILE) * 0.5) <= 28.0:
					tile.is_fortress = true
					fortress_tiles.append(tile)
					fortress_cells.append(tile.position)
					break
		if fortress_cells.is_empty():
			fortress_cells = _default_fortress_cells(result["eagle"])
	return result


func steel_fortress() -> void:
	_rebuild_fortress(MapTile.Kind.STEEL)


func restore_fortress() -> void:
	_rebuild_fortress(MapTile.Kind.BRICK)


func _default_fortress_cells(eagle: Vector2) -> Array[Vector2]:
	var cells: Array[Vector2] = []
	for dx in [-24, -8, 8, 24]:
		for dy in [-24, -8, 8]:
			if absf(float(dx)) < 16.0 and absf(float(dy)) < 16.0:
				continue
			cells.append(eagle + Vector2(dx, dy))
	return cells


func _rebuild_fortress(kind: MapTile.Kind) -> void:
	var remaining: Array[MapTile] = []
	for tile in fortress_tiles:
		if is_instance_valid(tile):
			remaining.append(tile)
	fortress_tiles = remaining
	for cell in fortress_cells:
		var found: MapTile = null
		for tile in fortress_tiles:
			if tile.global_position.distance_to(cell) < 2.0:
				found = tile
				break
		if found:
			found.set_kind(kind)
			continue
		var tex := GameArt.steel_tex if kind == MapTile.Kind.STEEL else GameArt.brick_tex
		var tile := _add_tile(cell - Vector2(GameArt.TILE, GameArt.TILE) * 0.5, kind, tex)
		tile.is_fortress = true
		fortress_tiles.append(tile)


func _add_tile(cell: Vector2, kind: MapTile.Kind, tex: Texture2D) -> MapTile:
	var tile := MapTile.new()
	tile.position = cell
	add_child(tile)
	tile.configure(kind, tex)
	return tile


func _add_bush(cell: Vector2) -> void:
	var bush := Sprite2D.new()
	bush.texture = GameArt.bush_tex
	bush.position = cell + Vector2(GameArt.TILE, GameArt.TILE) * 0.5
	bush.z_index = 20
	add_child(bush)
