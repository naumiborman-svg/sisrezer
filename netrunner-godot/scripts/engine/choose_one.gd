class_name NRChooseOne
extends RefCounted

## Port of game.core.choose-one.


static func choose_one(state: NRState, side: Variant, eid: Dictionary, choices: Array, card: Dictionary = {}) -> void:
	var labels: Array = []
	var map: Dictionary = {}
	for c in choices:
		if c is String:
			labels.append(c)
			map[c] = {"async": true, "effect": func(s, sd, e, _cd, _t): NREid.effect_completed(s, sd, e)}
		elif c is Dictionary:
			var lab: String = str(c.get("option", c.get("label", "Choice")))
			labels.append(lab)
			map[lab] = c
	NREngine.resolve_ability(state, side, eid, {
		"prompt": "Choose one",
		"choices": labels,
		"async": true,
		"effect": func(s, sd, e, cd, t):
			var picked = t[0].get("value") if t is Array and t.size() > 0 and t[0] is Dictionary else (t[0] if t is Array and t.size() > 0 else "")
			var ab: Dictionary = map.get(str(picked), {})
			if ab.is_empty():
				NREid.effect_completed(s, sd, e)
			else:
				NREngine.resolve_ability_eid(s, sd, e, ab, cd, t)
	}, card, [])
