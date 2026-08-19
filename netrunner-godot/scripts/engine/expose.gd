class_name NRExpose
extends RefCounted

## Port of game.core.expose.


static func expose(state: NRState, side: Variant, eid: Dictionary, target: Dictionary, args: Dictionary = {}) -> void:
	if target.is_empty():
		NREid.effect_completed(state, side, eid)
		return
	if NRCard.rezzed(target):
		NREid.effect_completed(state, side, eid)
		return
	var c := target.duplicate(true)
	c["seen"] = true
	NRUpdate.update_card(state, "corp", c)
	NRSay.system_msg(state, side, "exposes %s" % NRToString.card_str(state, c))
	NREngine.queue_event_and_resolve(state, eid, "expose", {"card": c}, args)
