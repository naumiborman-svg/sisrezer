class_name NRPlayInstants
extends RefCounted
## Play events and operations. Port of game.core.play_instants.

static func can_play_instant(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> bool:
	if NRFlags.zone_locked(state, side, "discard") and NRCard.in_discard(card):
		return false
	if str(card.get("type")) == "Current" or NRCard.has_subtype(card, "Current"):
		if bool(state.get_in([NRUtil.to_side(side), "register", "cannot-play-current"], false)):
			return false
	var costs := play_instant_costs(state, side, card, args)
	return NRPayment.can_pay(state, side, eid, card, card.get("title"), costs) != null


static func play_instant_costs(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Array:
	var base: Array = NRUtil.as_array(args.get("base-cost", []))
	base.append_array(NRCostFns.base_play_cost(state, side, card, args))
	base.append_array(NRCostFns.play_additional_cost_bonus(state, side, card))
	return NRPayment.merge_costs(base)


static func play_instant(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		c = card
	if not can_play_instant(state, side, eid, c, args):
		NREid.effect_completed(state, side, eid)
		return
	var costs := play_instant_costs(state, side, c, args)
	NREid.wait_for(state, eid, func(pe):
		NREngine.pay(state, side, pe, c, costs)
	, func(payment):
		if not (payment is Dictionary) or payment.get("cost-paid") == null:
			NREid.effect_completed(state, side, eid)
			return
		var cdef := NRCardDefs.card_def(c)
		var moved = NRMoving.move(state, side, c, "play-area")
		var cost_str := str(payment.get("msg", ""))
		NRSay.system_msg(state, side, "%s%s" % [NRPayment.build_spend_msg(cost_str, "play"), NRCard.get_title(c)])
		var on_play = cdef.get("on-play", cdef)
		if NRCard.has_subtype(c, "Current") or str(c.get("type")) == "Current":
			for old in state.get_in([NRUtil.to_side(side), "current"], []):
				NRMoving.move(state, side, old, "discard")
			NRMoving.move(state, side, moved if moved is Dictionary else c, "current")
		NREngine.register_pending_event(state, "play-instant", moved if moved is Dictionary else c, on_play if on_play is Dictionary else {})
		NREngine.queue_event(state, "play-instant", {"card": moved})
		NREid.wait_for(state, eid, func(ne):
			NREngine.checkpoint(state, ne, {"duration": "play-instant"})
		, func(_r):
			var latest = NRCard.get_card(state, moved if moved is Dictionary else c)
			if latest is Dictionary and NRUtil.zone_as_array(latest.get("zone")) == ["play-area"]:
				if bool(latest.get("rfg-instead-of-trashing")) or bool(args.get("as-flashback")):
					NRMoving.move(state, side, latest, "rfg")
				else:
					NRMoving.move(state, side, latest, "discard")
			NREid.effect_completed(state, side, eid)
		)
	)
