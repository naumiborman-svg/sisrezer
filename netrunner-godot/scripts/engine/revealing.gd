class_name NRRevealing
extends RefCounted

## Port of game.core.revealing.


static func reveal(state: NRState, side: Variant, eid: Dictionary, targets, args: Dictionary = {}) -> void:
	var cards: Array = targets if targets is Array else [targets]
	for c in cards:
		if c is Dictionary:
			var cc = c.duplicate(true)
			cc["seen"] = true
			NRUpdate.update_card(state, NRUtil.to_side(cc.get("side", side)), cc)
			NRSay.system_msg(state, side, "reveals %s" % NRToString.card_str(state, cc))
	NREngine.queue_event_and_resolve(state, eid, "reveal", {"cards": cards}, args)


static func conceal(state: NRState, side: Variant, eid: Dictionary, targets) -> void:
	var cards: Array = targets if targets is Array else [targets]
	for c in cards:
		if c is Dictionary:
			var cc = c.duplicate(true)
			cc["seen"] = false
			NRUpdate.update_card(state, NRUtil.to_side(cc.get("side", side)), cc)
	NREid.effect_completed(state, side, eid)
