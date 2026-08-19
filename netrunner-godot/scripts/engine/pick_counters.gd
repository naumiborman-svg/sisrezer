class_name NRPickCounters
extends RefCounted

## Port of game.core.pick-counters.


static func pick_virus_counters_to_spend(state: NRState, side: Variant, eid: Dictionary, target, count: int) -> void:
	## Simplified: spend from the given card first, then from any installed virus counters.
	var remaining: int = count
	if target is Dictionary:
		var have: int = NRCard.get_counters(target, "virus")
		var spend: int = mini(have, remaining)
		if spend > 0:
			NRProps.add_counter(state, side, NREid.make_eid(state), target, "virus", -spend, {"suppress-checkpoint": true})
			remaining -= spend
	if remaining > 0:
		for c in NRBoard.all_installed(state, "runner"):
			if remaining <= 0:
				break
			if not (c is Dictionary):
				continue
			var have2: int = NRCard.get_counters(c, "virus")
			var spend2: int = mini(have2, remaining)
			if spend2 > 0:
				NRProps.add_counter(state, side, NREid.make_eid(state), c, "virus", -spend2, {"suppress-checkpoint": true})
				remaining -= spend2
	NREid.complete_with_result(state, side, eid, remaining <= 0)
