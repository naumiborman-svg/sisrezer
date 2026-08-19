class_name ChiribogaSave
extends RefCounted

const SETTINGS_PATH := "user://chiriboga_settings.json"
const ACHIEVEMENTS_PATH := "user://chiriboga_achievements.json"

static func default_settings() -> Dictionary:
	return {
		"game_speed": 350,
		"crt": true,
		"debug": false,
		"gauntlet_length": 4,
		"alternate_corps": true,
	}


static func default_achievements() -> Dictionary:
	return {
		"high_scores": [
			{"score": 0, "timestamp": "", "identity": ""},
			{"score": 0, "timestamp": "", "identity": ""},
			{"score": 0, "timestamp": "", "identity": ""},
		],
		"achievements": [
			{"id": "getHighScore", "name": "High Scorer", "description": "Record a High Score.", "achieved": false, "achievedAt": ""},
			{"id": "beat4gauntlet", "name": "Complete a short Gauntlet", "description": "Survive a Gauntlet of 4 opponents.", "achieved": false, "achievedAt": ""},
			{"id": "beat8gauntlet", "name": "Complete a regular Gauntlet", "description": "Survive a Gauntlet of 8 opponents.", "achieved": false, "achievedAt": ""},
			{"id": "beat12gauntlet", "name": "Complete a long Gauntlet", "description": "Survive a Gauntlet of 12 opponents.", "achieved": false, "achievedAt": ""},
		],
	}


static func load_json(path: String, fallback: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		return fallback.duplicate(true)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return fallback.duplicate(true)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return fallback.duplicate(true)


static func save_json(path: String, data: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))


static func settings() -> Dictionary:
	var d := load_json(SETTINGS_PATH, default_settings())
	var base := default_settings()
	for key: Variant in base.keys():
		if not d.has(key):
			d[key] = base[key]
	return d


static func save_settings(data: Dictionary) -> void:
	save_json(SETTINGS_PATH, data)


static func achievements() -> Dictionary:
	var d := load_json(ACHIEVEMENTS_PATH, default_achievements())
	if not d.has("achievements"):
		d = default_achievements()
	return d


static func save_achievements(data: Dictionary) -> void:
	save_json(ACHIEVEMENTS_PATH, data)


static func unlock(id: String) -> void:
	var data := achievements()
	for item: Variant in data.get("achievements", []):
		if item is Dictionary and str(item.get("id", "")) == id and not bool(item.get("achieved", false)):
			item["achieved"] = true
			item["achievedAt"] = Time.get_datetime_string_from_system()
	save_achievements(data)


static func percent() -> int:
	var data := achievements()
	var items: Array = data.get("achievements", [])
	if items.is_empty():
		return 0
	var n := 0
	for item: Variant in items:
		if item is Dictionary and bool(item.get("achieved", false)):
			n += 1
	return int(round(100.0 * n / float(items.size())))
