class_name NRUpdate
extends RefCounted
## In-place card updates. Port of game.core.update.

static func update(state: NRState, side: Variant, card: Dictionary) -> Variant:
	return update_card(state, side, card)


static func update_card(state: NRState, side: Variant, card: Dictionary) -> Variant:
	if str(card.get("type")) == "Identity":
		if NRUtil.to_side(side) == NRUtil.to_side(card.get("side")):
			state.assoc_in([NRUtil.to_side(side), "identity"], card)
			return card
		return null
	if card.get("host") is Dictionary:
		update_hosted(state, side, card)
		return NRCard.get_card(state, card)
	var owner = NRFinding.get_scoring_owner(state, card)
	if owner == null:
		owner = NRUtil.to_side(card.get("side", side))
	var z: Array = [owner] + NRUtil.zone_as_array(card.get("zone", []))
	var coll = state.get_in(z, [])
	if not (coll is Array):
		return null
	var cid = card.get("cid")
	var found = false
	var out: Array = []
	for item in coll:
		if not found and item is Dictionary and item.get("cid") == cid:
			out.append(card)
			found = true
		else:
			out.append(item)
	if found:
		state.assoc_in(z, out)
		return card
	return null


static func update_hosted(state: NRState, side: Variant, card: Dictionary) -> void:
	var host = NRCard.get_card(state, card.get("host"))
	if host is Dictionary:
		var hosted: Array = host.get("hosted", [])
		var cid = card.get("cid")
		var out: Array = []
		for h in hosted:
			if h is Dictionary and h.get("cid") == cid:
				out.append(card)
			else:
				out.append(h)
		var updated: Dictionary = host.duplicate(true)
		updated["hosted"] = out
		update_hosted(state, side, updated)
	elif card.get("host") == null:
		update_card(state, side, card)
