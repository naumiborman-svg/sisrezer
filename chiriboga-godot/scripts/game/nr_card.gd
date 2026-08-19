extends RefCounted
class_name NRCard
## A single card instance in play (distinct from the static definition in CardLibrary).

const _LibScript = preload("res://scripts/data/card_db.gd")
static var _lib = null

var def_id: int = 0
var instance_id: int = 0
var hosted_credits: int = 0
var advancement: int = 0
var rezzed: bool = false
var strength_boost: int = 0
var used_this_turn: bool = false
var known_to_runner: bool = false
var faceup: bool = false
var location: String = "" ## grip, stack, heap, hq, rnd, archives, ice, root, scored, stolen, program, hardware, resource, identity, play
var server_id: int = -1
var extra: Dictionary = {}
var subroutine_broken: Array = [] ## bool per subroutine index


func def() -> Dictionary:
	if _lib == null:
		_lib = _LibScript.new()
	return _lib.get_def(def_id)


func title() -> String:
	return str(def().get("title", "?"))


func card_type() -> String:
	return str(def().get("type", "?"))


func side() -> String:
	return str(def().get("side", ""))


func subtypes() -> Array:
	return def().get("subtypes", [])


func has_subtype(s: String) -> bool:
	var sl := s.to_lower()
	for t in subtypes():
		if str(t).to_lower() == sl:
			return true
	return false


func printed_cost() -> int:
	var d := def()
	if d.has("cost"):
		return int(d.cost)
	return 0


func play_cost() -> int:
	return int(def().get("cost", 0))


func rez_cost() -> int:
	return int(def().get("cost", 0))


func trash_cost() -> int:
	return int(def().get("trash_cost", -1))


func memory_cost() -> int:
	return int(def().get("memory_cost", 0))


func memory_provided() -> int:
	return int(def().get("memory_units", 0))


func printed_strength() -> int:
	return int(def().get("strength", 0))


func agenda_points() -> int:
	return int(def().get("agenda_points", 0))


func advancement_requirement() -> int:
	return int(def().get("advancement_requirement", 0))


func is_unique() -> bool:
	return bool(def().get("unique", false))


func can_be_advanced() -> bool:
	if card_type() == "agenda":
		return true
	return bool(def().get("can_advance", false))


func text() -> String:
	return str(def().get("text", ""))


func faction() -> String:
	return str(def().get("faction", ""))


func influence() -> int:
	return int(def().get("influence", 0))


func short_label() -> String:
	var t := title()
	if t.length() > 22:
		return t.substr(0, 20) + "…"
	return t
