class_name NRDamage
extends RefCounted
## Net / meat / core damage. Port of game.core.damage.

static func damage_name(damage_type: Variant) -> String:
	match NRUtil.to_kw(damage_type):
		"net":
			return "net"
		"meat":
			return "meat"
		"core", "brain":
			return "core"
		_:
			return "[UNKNOWN DAMAGE TYPE]"


static func enable_runner_damage_choice(state: NRState, _side: Variant) -> void:
	state.assoc_in(["damage", "damage-choose-runner"], true)


static func enable_corp_damage_choice(state: NRState, _side: Variant) -> void:
	state.assoc_in(["damage", "damage-choose-corp"], true)


static func runner_can_choose_damage(state: NRState) -> bool:
	return bool(state.get_in(["damage", "damage-choose-runner"], false))


static func corp_can_choose_damage(state: NRState) -> bool:
	return bool(state.get_in(["damage", "damage-choose-corp"], false))


static func chosen_damage(state: NRState, _side: Variant, targets: Array) -> void:
	var arr: Array = state.get_in(["damage", "chosen-damage"], [])
	arr.append_array(NRUtil.flatten(targets))
	state.assoc_in(["damage", "chosen-damage"], arr)


static func damage(state: NRState, side: Variant, eid: Dictionary, typ: Variant, n: int, args: Dictionary = {}) -> void:
	var dtype := NRUtil.to_kw(typ)
	if dtype == "brain":
		dtype = "brain"
	NREid.wait_for(state, eid, func(pe):
		NRPrevention.resolve_damage_prevention(state, side, pe, dtype, n, args)
	, func(async_result):
		var remaining := n
		var rtype := dtype
		if async_result is Dictionary:
			remaining = int(async_result.get("remaining", n))
			rtype = str(async_result.get("type", dtype))
		if remaining > 0:
			_resolve_damage(state, side, eid, rtype, remaining, args)
		else:
			NREngine.queue_event(state, "all-damage-was-prevented", {"side": side, "type": rtype})
			if bool(args.get("suppress-checkpoint", false)):
				NREid.effect_completed(state, side, eid)
			else:
				NREngine.checkpoint(state, eid)
	)


static func _resolve_damage(state: NRState, side: Variant, eid: Dictionary, dmg_type: String, n: int, args: Dictionary) -> void:
	if n <= 0:
		NREid.effect_completed(state, side, eid)
		return
	var hand: Array = state.get_in(["runner", "hand"], [])
	var chosen: Array = state.get_in(["damage", "chosen-damage"], [])
	state.dissoc_in(["damage", "chosen-damage"])
	var chosen_cids := {}
	for c in chosen:
		if c is Dictionary:
			chosen_cids[c.get("cid")] = true
	var leftovers: Array = []
	for c in hand:
		if c is Dictionary and not chosen_cids.has(c.get("cid")):
			leftovers.append(c)
	leftovers.shuffle()
	var needed := n - chosen.size()
	var cards_trashed: Array = chosen + NRUtil.take_n(leftovers, needed)
	if dmg_type == "brain":
		state.update_in(["runner", "brain-damage"], NRUtil.inc_n(n), 0)
		NRHandSize.update_hand_size(state, "runner")
	if not cards_trashed.is_empty():
		NRSay.system_msg(state, side, "trashes %s due to %s damage" % [NRUtil.enumerate_cards(cards_trashed, true), damage_name(dmg_type)])
	state.update_in(["stats", "corp", "damage", "all"], NRUtil.inc_n(n), 0)
	state.update_in(["stats", "corp", "damage", dmg_type], NRUtil.inc_n(n), 0)
	if hand.size() < n:
		NRWinning.flatline(state)
		NREngine.trigger_event(state, side, "win", {"winner": "corp"})
		NRMoving.trash_cards(state, side, eid, cards_trashed, {"unpreventable": true})
		return
	NREid.wait_for(state, eid, func(ne):
		NRMoving.trash_cards(state, side, ne, cards_trashed, {"unpreventable": true, "cause": dmg_type, "suppress-checkpoint": true, "suppress-event": true})
	, func(_r):
		NREngine.queue_event(state, "damage", {"amount": n, "card": args.get("card"), "damage-type": dmg_type, "from-side": side, "cards-trashed": cards_trashed})
		if bool(args.get("suppress-checkpoint", false)):
			NREid.complete_with_result(state, side, eid, cards_trashed)
		else:
			NREngine.checkpoint(state, eid)
			NREid.complete_with_result(state, side, eid, cards_trashed)
	)
