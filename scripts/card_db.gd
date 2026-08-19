extends Node

var by_code: Dictionary = {}
var decks: Dictionary = {}


func _ready() -> void:
	load_data()


func load_data() -> void:
	by_code.clear()
	var cards_raw: Variant = _read_json("res://data/cards.json")
	if cards_raw is Array:
		for item: Variant in cards_raw:
			if item is Dictionary and item.has("code"):
				by_code[str(item["code"])] = item
	var decks_raw: Variant = _read_json("res://data/decks.json")
	if decks_raw is Dictionary:
		decks = decks_raw


func defn(code: String) -> Dictionary:
	return by_code.get(code, {})


func title_of(code: String) -> String:
	return str(defn(code).get("title", code))


func _read_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("missing %s" % path)
		return null
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed
