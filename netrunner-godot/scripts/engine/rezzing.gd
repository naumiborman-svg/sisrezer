class_name NRRezzing
extends RefCounted
## Rez / derez. Port of game.core.rezzing.

static func get_rez_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Array:
	if NRUtil.kw_eq(args.get("ignore-cost"), "all-costs"):
		return [NRPayment.to_c("credit", 0)]
	if args.get("alternative-cost") != null:
		return NRPayment.merge_costs(args["alternative-cost"])
	var cost = NRCostFns.rez_cost(state, side, card, args)
	var additional = NRCostFns.rez_additional_cost_bonus(state, side, card)
	var costs: Array = []
	if not NRUtil.truthy(args.get("ignore-cost", false)) and cost != null:
		costs.append(NRPayment.to_c("credit", int(cost)))
	if not NRUtil.truthy(card.get("disabled", false)):
		costs.append_array(additional)
	return NRPayment.merge_costs(costs)


static func can_pay_to_rez(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> bool:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		return false
	var costs = get_rez_cost(state, side, c, args)
	return NRPayment.can_pay(state, side, eid, c, null, costs) != null


static func rez(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	if not NRUtil.truthy(args.get("force", false)) and not NRFlags.can_rez(state, side, c):
		NREid.effect_completed(state, side, eid)
		return
	if NRCard.rezzed(c):
		NREid.effect_completed(state, side, eid)
		return
	var costs = get_rez_cost(state, side, c, args)
	if not NRUtil.truthy(args.get("ignore-cost", false)) and NRPayment.can_pay(state, side, eid, c, c.get("title"), costs) == null:
		NREid.effect_completed(state, side, eid)
		return
	NREid.wait_for(state, eid, func(pe):
		NREngine.pay(state, side, pe, c, costs)
	, func(payment):
		if not (payment is Dictionary) or payment.get("msg") == null:
			NREid.effect_completed(state, side, eid)
			return
		var updated = c.duplicate(true)
		updated["rezzed"] = "this-turn"
		updated["timestamp"] = NRUtil.make_timestamp()
		if NRUtil.truthy(updated.get("disabled", false)):
			NRUpdate.update_card(state, side, updated)
		else:
			updated = NRInitializing.card_init(state, side, updated, {"resolve-effect": false, "init-data": true})
		if not NRUtil.truthy(args.get("no-msg", false)):
			NRSay.system_msg(state, side, "%s%s" % [NRPayment.build_spend_msg(str(payment.get("msg", "")), "rez"), NRToString.card_str(state, updated if updated is Dictionary else c, {"visible": true})])
			NRSay.implementation_msg(state, updated if updated is Dictionary else c)
		if NRCard.ice(updated if updated is Dictionary else c):
			NRIce.update_ice_strength(state, side, updated if updated is Dictionary else c)
			NRSay.play_sfx(state, side, "rez-ice")
		else:
			NRSay.play_sfx(state, side, "rez-other")
		state.update_in(["stats", "corp", "cards", "rezzed"], NRUtil.inc_n(1), 0)
		var on_rez = NRCardDefs.card_def(c).get("on-rez")
		if on_rez is Dictionary:
			NREngine.register_pending_event(state, "rez", updated if updated is Dictionary else c, on_rez)
		NREngine.queue_event(state, "rez", {"card": NRCard.get_card(state, updated if updated is Dictionary else c), "cost": payment.get("cost-paid")})
		NREngine.checkpoint(state, eid, {"duration": "rez"})
		if NRUtil.truthy(args.get("press-continue", false)):
			NRRuns.continue_run(state, side, null)
	)


static func derez(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary) or not NRCard.rezzed(c):
		NREid.effect_completed(state, side, eid)
		return
	if not NRUtil.truthy(args.get("no-msg", false)):
		NRSay.system_msg(state, side, "derezzes %s" % NRToString.card_str(state, c, {"visible": true}))
	c = NRInitializing.deactivate(state, side, c, true)
	c["rezzed"] = false
	NRUpdate.update_card(state, side, c)
	if not NRUtil.truthy(args.get("no-event", false)):
		NREngine.queue_event(state, "derez", {"card": c})
		NREngine.checkpoint(state, eid)
	else:
		NREid.effect_completed(state, side, eid)
