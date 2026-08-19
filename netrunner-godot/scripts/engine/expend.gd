class_name NRExpend
extends RefCounted

## Port of game.core.expend — trash from HQ to trigger an expend ability.


static func expendable(state: NRState, card: Dictionary) -> bool:
	return NRCard.expendable(state, card)


static func expend(ex: Dictionary) -> Dictionary:
	var exp_cost: Array = [NRPayment.to_c("click", 1), NRPayment.to_c("expend", 1)]
	var merged: Array = exp_cost
	if ex.get("cost") != null:
		merged = NRPayment.merge_costs([ex.get("cost"), exp_cost])
	return {
		"req": func(state, side, eid, card, targets):
			if not NRPayment.has_enough(state, side, eid, card, merged):
				return false
			var req = ex.get("req")
			if req is Callable:
				return NRUtil.truthy(req.call(state, side, eid, card, targets))
			return true,
		"async": true,
		"action": true,
		"cost": merged,
		"effect": func(state, side, eid, card, targets):
			NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, "corp", ne, NRUtil.merge(ex, {"cost": []}), card, targets)
			, func(_r):
				NREngine.queue_event_and_resolve(state, eid, "expend-resolved", {"card": card})
			),
	}


static func expend_ability(state: NRState, side: Variant, args: Dictionary) -> void:
	var card = args.get("card", args)
	if not (card is Dictionary):
		return
	card = NRCard.get_card(state, card)
	if not (card is Dictionary) or not expendable(state, card):
		return
	var cdef = NRCardDefs.card_def(card)
	var ab = expend(cdef.get("expend", {}))
	var eid = NREid.make_eid(state, {"source": card, "source-type": "ability"})
	NREngine.resolve_ability(state, side, eid, ab, card, args.get("targets"))
