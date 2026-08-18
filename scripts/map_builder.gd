class_name MapBuilder
extends Node2D

const STAGE_MAPS: Array[String] = [
"S...........@@...........S\n............@@............\n..######..........######..\n..#....................#..\n..#..##....@@@@....##..#..\n..........................\n####......##..##......####\n..........................\n..~~~~~~..........~~~~~~..\n..........................\n######....##..##....######\n............@@............\n............@@............\n....####..........####....\n..........................\n..##......######......##..\n..........................\n######..............######\n..........######..........\n....##..............##....\n....##....######....##....\n......##.######.##........\n......##.#.EE.#.##........\n......##.#.EE.#.##........\n......##....P....##.......\n......##############......",
"S.....@@..........@@.....S\n......@@..........@@......\n..##......######......##..\n..##..................##..\n@@@@......~~~~~~......@@@@\n..........................\n######....##..##....######\n..........................\n..##......@@@@@@......##..\n..........................\nS.........######..........\n..........######..........\n....~~~~..........~~~~....\n..........................\n######..............######\n..##......######......##..\n..........................\n@@@@..................@@@@\n....##....######....##....\n....##..............##....\n......######EE######......\n......##....EE....##......\n......##....P.....##......\n......##..........##......\n......##############......\n..........................",
"S....@@@@@@....@@@@@@....S\n.....@@@@@@....@@@@@@.....\n..##..................##..\n..##..~~~~~~..~~~~~~..##..\n..........................\n######....@@@@....######..\n..........................\n@@@@......##..##......@@@@\n..........................\n..~~~~~~..........~~~~~~..\n..........................\n######....##..##....######\nS.........@@@@............\n..........@@@@............\n....##..............##....\n....##....######....##....\n..........................\n@@@@@@..............@@@@@@\n..........######..........\n....##....#....#....##....\n....##....#..EE#....##....\n......##....EE....##......\n......##....P.....##......\n......@@..........@@......\n......##############......\n..........................",
]


func build(stage_index: int) -> Dictionary:
	var raw := STAGE_MAPS[clampi(stage_index, 0, STAGE_MAPS.size() - 1)]
	var lines: PackedStringArray = PackedStringArray()
	for line in raw.split("\n"):
		if line.is_empty():
			continue
		lines.append(line)
	if lines.size() != 26:
		push_error("Map must be 26 rows, got %s" % lines.size())
	for line in lines:
		if line.length() != 26:
			push_error("Map row must be 26 chars: '%s' (%s)" % [line, line.length()])

	var result := {
		"player": Vector2.ZERO,
		"spawns": [],
		"eagle": Vector2.ZERO,
	}
	var eagle_cells: Array[Vector2] = []
	for y in lines.size():
		var row := lines[y]
		for x in row.length():
			var ch := row[x]
			var cell := Vector2(x * GameArt.TILE, y * GameArt.TILE)
			match ch:
				"#":
					_add_tile(cell, MapTile.Kind.BRICK, GameArt.brick_tex)
				"@":
					_add_tile(cell, MapTile.Kind.STEEL, GameArt.steel_tex)
				"~":
					_add_tile(cell, MapTile.Kind.WATER, GameArt.water_tex)
				"%":
					_add_bush(cell)
				"S":
					result["spawns"].append(cell + Vector2(GameArt.TILE, GameArt.TILE) * 0.5)
				"P":
					result["player"] = cell + Vector2(GameArt.TILE, GameArt.TILE) * 0.5
				"E":
					eagle_cells.append(cell)
				".":
					pass
				" ":
					pass
				_:
					push_warning("Unknown map char: %s" % ch)
	if not eagle_cells.is_empty():
		var center := Vector2.ZERO
		for c in eagle_cells:
			center += c
		center /= float(eagle_cells.size())
		result["eagle"] = center + Vector2(GameArt.TILE, GameArt.TILE) * 0.5
	return result


func _add_tile(cell: Vector2, kind: MapTile.Kind, tex: Texture2D) -> void:
	var tile := MapTile.new()
	tile.position = cell
	add_child(tile)
	tile.configure(kind, tex)


func _add_bush(cell: Vector2) -> void:
	var bush := Sprite2D.new()
	bush.texture = GameArt.bush_tex
	bush.position = cell + Vector2(GameArt.TILE, GameArt.TILE) * 0.5
	bush.z_index = 20
	add_child(bush)
