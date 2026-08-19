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


static func jinteki_cards() -> Dictionary:
	var by_code := {}
	var raw: Variant = _read_json("res://data/jinteki/cards.json")
	if raw is Array:
		for item: Variant in raw:
			if item is Dictionary and item.has("code"):
				by_code[str(item["code"])] = item
	return by_code


static func matchups() -> Array:
	var raw: Variant = _read_json("res://data/jinteki/matchups.json")
	if raw is Array:
		return raw
	return []


static func matchup(key: String) -> Dictionary:
	for item: Variant in matchups():
		if item is Dictionary and str(item.get("key", "")) == key:
			return item
	return {}


static func decks_for(key: String) -> Dictionary:
	var mu := matchup(key)
	if mu.is_empty():
		return decks()
	var corp: Dictionary = mu.get("corp", {})
	var runner: Dictionary = mu.get("runner", {})
	return {
		"format": key,
		"agenda_goal": int(mu.get("agenda_goal", 7)),
		"corp": {
			"name": str(corp.get("name", "")),
			"identity": str(corp.get("identity", "")),
			"cards": corp.get("cards", {}),
		},
		"runner": {
			"name": str(runner.get("name", "")),
			"identity": str(runner.get("identity", "")),
			"cards": runner.get("cards", {}),
		},
	}


static func _read_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("missing %s" % path)
		return null
	return JSON.parse_string(f.get_as_text())
