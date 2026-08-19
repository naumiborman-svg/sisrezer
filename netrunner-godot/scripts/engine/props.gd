class_name NRProps
extends RefCounted
## Counters and properties on cards. Port of game.core.props.

static func add_prop(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, prop_type: String, n: int, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	c = c.duplicate(true)
	c[prop_type] = int(c.get(prop_type, 0)) + n
	var updated = NRUpdate.update_card(state, side, c)
	var payload = {"counter-type": prop_type, "amount": n, "placed": args.get("placed")}
	if prop_type == "advance-counter":
		if updated is Dictionary and NRCard.ice(updated) and NRCard.rezzed(updated):
			NRIce.update_ice_strength(state, side, updated)
		payload["card"] = NRCard.get_card(state, updated if updated is Dictionary else c)
		NREngine.queue_event(state, ("advancement-placed" if NRUtil.truthy(args.get("placed")) else "advance"), payload)
	else:
		payload["card"] = NRCard.get_card(state, updated if updated is Dictionary else c)
		NREngine.queue_event(state, "counter-added", payload)
	if not NRUtil.truthy(args.get("suppress-checkpoint", false)):
		NREngine.checkpoint(state, eid)
	else:
		NREid.effect_completed(state, side, eid)


static func add_counter(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, prop_type: String, n: int, args: Dictionary = {}) -> void:
	if NRUtil.to_kw(prop_type) == "advancement":
		add_prop(state, side, eid, card, "advance-counter", n, args)
		return
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	c = c.duplicate(true)
	var ctr: Dictionary = c.get("counter", {})
	if not (ctr is Dictionary):
		ctr = {}
	else:
		ctr = ctr.duplicate(true)
	var key = NRUtil.to_kw(prop_type)
	ctr[key] = int(ctr.get(key, 0)) + n
	c["counter"] = ctr
	var updated = NRUpdate.update_card(state, side, c)
	NREngine.queue_event(state, "counter-added", {"card": updated, "counter-type": key, "amount": n, "placed": args.get("placed")})
	if not NRUtil.truthy(args.get("suppress-checkpoint", false)):
		NREngine.checkpoint(state, eid)
	else:
		NREid.effect_completed(state, side, eid)


static func set_prop(state: NRState, side: Variant, card: Dictionary, pairs: Dictionary) -> void:
	var c = card.duplicate(true)
	for k in pairs:
		c[k] = pairs[k]
	NRUpdate.update_card(state, side, c)
