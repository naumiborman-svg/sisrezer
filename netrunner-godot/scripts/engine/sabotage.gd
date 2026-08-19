class_name NRSabotage
extends RefCounted

## Port of game.core.sabotage.


static func sabotage(state: NRState, n: int, eid: Dictionary) -> void:
	NRSay.system_say(state, null, "Sabotage %d." % n)
	var remaining: int = n
	## Prefer HQ, then R&D (simplified vs full choose-from-HQ-or-RD).
	while remaining > 0:
		var hq: Array = state.get_in(["corp", "hand"], [])
		if hq.is_empty():
			break
		if hq[0] is Dictionary:
			NRMoving.move(state, "corp", hq[0], "discard")
			remaining -= 1
		else:
			break
	while remaining > 0:
		var rd: Array = state.get_in(["corp", "deck"], [])
		if rd.is_empty():
			break
		if rd[0] is Dictionary:
			NRMoving.move(state, "corp", rd[0], "discard")
			remaining -= 1
		else:
			break
	NREngine.queue_event_and_resolve(state, eid, "sabotage", {"amount": n, "remaining": remaining})
