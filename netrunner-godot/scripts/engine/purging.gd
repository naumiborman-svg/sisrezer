class_name NRPurging
extends RefCounted
## Virus purge. Port of game.core.purging.

static func purge(state: NRState, side: Variant, eid: Dictionary) -> void:
	var cards_to_purge: Array = []
	for card in NRBoard.get_all_installed(state):
		if card is Dictionary:
			var qty = NRCard.get_counters(card, "virus")
			if qty > 0:
				cards_to_purge.append({"card": card, "quantity": qty})
	_remove_next(state, side, eid, cards_to_purge, 0)


static func _remove_next(state: NRState, side: Variant, eid: Dictionary, cards: Array, idx: int) -> void:
	if idx >= cards.size():
		NRIce.update_all_ice(state, side)
		var total = 0
		for p in cards:
			total += int(p.get("quantity", 0))
		NREngine.queue_event(state, "purge", {"total-purged-counters": total, "purges": cards})
		NREngine.checkpoint(state, eid)
		return
	var cur: Dictionary = cards[idx]
	NREid.wait_for(state, eid, func(ne):
		NRProps.add_counter(state, "runner", ne, cur["card"], "virus", -int(cur["quantity"]))
	, func(_r):
		_remove_next(state, side, eid, cards, idx + 1)
	)
