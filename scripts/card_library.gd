class_name CardLibrary
extends RefCounted


static func cards() -> Dictionary:
	var by_code := {}
	var raw: Variant = _read_json("res://data/cards.json")
	if raw is Array:
		for item: Variant in raw:
			if item is Dictionary and item.has("code"):
				by_code[str(item["code"])] = item
	return by_code


static func decks() -> Dictionary:
	var raw: Variant = _read_json("res://data/decks.json")
	if raw is Dictionary:
		return raw
	return {}


static func _read_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("missing %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())
