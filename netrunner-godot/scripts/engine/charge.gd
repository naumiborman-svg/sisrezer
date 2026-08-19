class_name NRCharge
extends RefCounted

## Port of game.core.charge — add a power counter if the card can be charged.


static func charge_ability(extra: Dictionary = {}) -> Dictionary:
	var ab: Dictionary = {
		"async": true,
		"req": func(state, side, _eid, card, _t):
			return can_charge(state, side, card),
		"effect": func(state, side, eid, card, _t):
			charge_card(state, side, eid, card),
	}
	ab.merge(extra, true)
	return ab


static func can_charge(_state: NRState, _side: Variant, card: Dictionary) -> bool:
	return NRCard.installed(card) and not NRUtil.truthy(card.get("facedown", false))


static func charge_card(state: NRState, side: Variant, eid: Dictionary, card: Dictionary) -> void:
	NRProps.add_counter(state, side, NREid.make_eid(state), card, "power", 1, {"suppress-checkpoint": true})
	NRSay.system_msg(state, side, "charged %s" % NRToString.card_str(state, card))
	NREngine.queue_event_and_resolve(state, eid, "charge", {"card": card})
