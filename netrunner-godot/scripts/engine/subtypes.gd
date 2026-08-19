class_name NRSubtypes
extends RefCounted
## Dynamic subtype tracking. Port of game.core.subtypes.

static func subtypes_for_card(state: NRState, card: Dictionary) -> Array:
	if not card.has("title"):
		return []
	var printed: Array = NRCardDefs.server_card(str(card["title"])).get("subtypes", card.get("subtypes", []))
	if printed is String:
		printed = str(printed).split(" - ")
	var gained := NRUtil.flatten(NREffects.get_effects(state, null, "gain-subtype", card))
	var lost := NRUtil.flatten(NREffects.get_effects(state, null, "lose-subtype", card))
	var total := {}
	for s in printed + gained:
		var k := str(s)
		total[k] = int(total.get(k, 0)) + 1
	for s in lost:
		var k := str(s)
		total[k] = int(total.get(k, 0)) - 1
		if total[k] <= 0:
			total.erase(k)
	var keys: Array = total.keys()
	keys.sort()
	return keys


static func update_subtypes_for_card(state: NRState, card: Dictionary) -> bool:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		return false
	var old_s = c.get("subtypes", [])
	var new_s := subtypes_for_card(state, c)
	if str(old_s) != str(new_s):
		c = c.duplicate(true)
		c["subtypes"] = new_s
		NRUpdate.update!(state, NRUtil.to_side(c.get("side")), c)
		return true
	return false


static func update_all_subtypes(state: NRState, _side: Variant = null) -> bool:
	var changed := false
	for c in NRBoard.get_all_cards(state):
		if c is Dictionary and update_subtypes_for_card(state, c):
			changed = true
	return changed
