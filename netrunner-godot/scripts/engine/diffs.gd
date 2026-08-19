class_name NRDiffs
extends RefCounted

## Minimal port of game.core.diffs — public-state stripping for a client.
## Full spectator/private diffs (Clojure specter walks) are deferred.


static func public_state(state: NRState, side: Variant) -> Dictionary:
	var out: Dictionary = state.data.duplicate(true)
	_strip_private(out.get(NRUtil.other_side(side), {}))
	return out


static func _strip_private(player: Variant) -> void:
	if not (player is Dictionary) or player.is_empty():
		return
	for z in ["hand", "deck"]:
		var cards: Array = player.get(z, [])
		var hidden: Array = []
		for c in cards:
			if c is Dictionary:
				hidden.append({"cid": c.get("cid"), "side": c.get("side"), "zone": c.get("zone")})
		player[z] = hidden
