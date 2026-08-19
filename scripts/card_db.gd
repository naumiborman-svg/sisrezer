extends Node

var by_code: Dictionary = {}
var decks: Dictionary = {}


func _ready() -> void:
	load_data()


func load_data() -> void:
	by_code = CardLibrary.cards()
	decks = CardLibrary.decks()


func defn(code: String) -> Dictionary:
	return by_code.get(code, {})


func title_of(code: String) -> String:
	return str(defn(code).get("title", code))
