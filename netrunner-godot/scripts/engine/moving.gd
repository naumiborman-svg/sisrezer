class_name NRMoving
extends RefCounted
## Move, trash, mill, swap, forfeit. Port of game.core.moving.

static func remove_old_card(state: NRState, _side: Variant, card: Dictionary) -> void:
	if card.get("host") is Dictionary:
		NRHosting.remove_from_host(state, _side, card)
		return
	var zone: Array = NRUtil.zone_as_array(card.get("zone", []))
	for s in ["runner", "corp"]:
		var coll = state.get_in([s] + zone, [])
		if coll is Array:
			var out = NRUtil.remove_once(coll, func(c): return c is Dictionary and NRUtil.same_card(c, card))
			if out.size() != coll.size():
				state.assoc_in([s] + zone, out)


static func move(state: NRState, side: Variant, card: Dictionary, to: Variant, args: Dictionary = {}) -> Variant:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		c = card
	if c == null:
		return null
	var dest: Array = NRUtil.zone_as_array(to) if not (to is Array) else to.duplicate()
	if dest.is_empty():
		dest = [NRUtil.to_kw(to)]
	var s = NRUtil.to_side(side)
	var old = c.duplicate(true)
	remove_old_card(state, s, old)
	var moved = old.duplicate(true)
	var src_zone: Array = NRUtil.zone_as_array(old.get("zone", []))
	var to_installed = not dest.is_empty() and dest[0] in ["servers", "rig"]
	var from_installed = not src_zone.is_empty() and src_zone[0] in ["servers", "rig"]
	if dest == ["rig", "facedown"]:
		moved["facedown"] = true
	else:
		moved.erase("facedown")
	if to_installed:
		moved["installed"] = "this-turn"
	else:
		moved.erase("installed")
	if dest[0] == "scored":
		moved["scored-side"] = s
	if dest[0] == "discard" and s == "corp" and (NRCard.rezzed(old) or NRCard.condition_counter(old)):
		moved["seen"] = true
	if dest[0] in ["hand", "deck"]:
		moved.erase("seen")
	if from_installed or old.get("host") or (not src_zone.is_empty() and src_zone[0] in ["servers", "scored", "current", "play-area"]):
		if dest[0] in ["hand", "deck", "discard", "rfg"] or dest == ["rig", "facedown"]:
			moved = NRInitializing.deactivate(state, s, moved, dest == ["rig", "facedown"])
	moved["zone"] = dest
	moved["host"] = null
	moved["previous-zone"] = old.get("zone")
	if not NRUtil.truthy(args.get("keep-hosted", false)):
		moved["hosted"] = []
	if dest[0] == "discard":
		moved["new"] = true
	var dest_path: Array = [s] + dest
	if dest[0] == "servers":
		dest_path = ["corp"] + dest
	var coll: Array = state.get_in(dest_path, [])
	if not (coll is Array):
		coll = []
	if NRUtil.truthy(args.get("front", false)):
		coll = [moved] + coll
	else:
		coll.append(moved)
	state.assoc_in(dest_path, coll)
	if dest[0] == "scored":
		NRAgendas.update_all_agenda_points(state)
		NRWinning.check_win_by_agenda(state)
	if dest[0] == "rig" and NRCard.program(moved) and not NRUtil.truthy(args.get("no-mu", false)):
		NRMemory.init_mu_cost(state, moved)
	return moved


static func move_zone(state: NRState, side: Variant, from_zone: String, to_zone: String) -> void:
	var s = NRUtil.to_side(side)
	var cards: Array = state.get_in([s, from_zone], []).duplicate()
	for c in cards:
		if c is Dictionary:
			move(state, s, c, to_zone)


static func trash(state: NRState, side: Variant, eid: Dictionary, card: Variant, args: Dictionary = {}) -> void:
	trash_cards(state, side, eid, [card] if card is Dictionary else NRUtil.as_array(card), args)


static func trash_cards(state: NRState, side: Variant, eid: Dictionary, cards: Array, args: Dictionary = {}) -> void:
	var moved: Array = []
	for c in cards:
		if c is Dictionary:
			var prevent = not NRUtil.truthy(args.get("unpreventable", false))
			if prevent and not NRFlags.can_trash(state, side if side != null else NRUtil.to_side(c.get("side")), c):
				continue
			var m = move(state, NRUtil.to_side(c.get("side", side)), c, "discard", args)
			if m is Dictionary:
				moved.append(m)
	if not NRUtil.truthy(args.get("suppress-event", false)):
		var ev = "game-trash" if NRUtil.truthy(args.get("game-trash")) else ("%s-trash" % NRUtil.to_side(side if side != null else "corp"))
		NREngine.queue_event(state, ev, {"cards": moved, "cause": args.get("cause")})
	if NRUtil.truthy(args.get("suppress-checkpoint", false)):
		NREid.complete_with_result(state, side, eid, moved)
	else:
		NREngine.checkpoint(state, eid)
		NREid.complete_with_result(state, side, eid, moved)


static func mill(state: NRState, side: Variant, eid: Dictionary, from_side: Variant, n: int) -> void:
	var deck: Array = state.get_in([NRUtil.to_side(from_side), "deck"], [])
	var cards = NRUtil.take_n(deck, n)
	trash_cards(state, side, eid, cards, {"unpreventable": true})


static func discard_from_hand(state: NRState, side: Variant, eid: Dictionary, from_side: Variant, n: int) -> void:
	var hand: Array = state.get_in([NRUtil.to_side(from_side), "hand"], [])
	trash_cards(state, side, eid, NRUtil.take_n(hand, n), {})


static func swap_cards(state: NRState, a: Dictionary, b: Dictionary) -> void:
	var za = NRUtil.zone_as_array(a.get("zone"))
	var zb = NRUtil.zone_as_array(b.get("zone"))
	var sa = NRUtil.to_side(a.get("side"))
	var sb = NRUtil.to_side(b.get("side"))
	var ca = a.duplicate(true)
	var cb = b.duplicate(true)
	ca["zone"] = zb
	cb["zone"] = za
	remove_old_card(state, sa, a)
	remove_old_card(state, sb, b)
	var pa: Array = ([sa] + za) if za[0] != "servers" else (["corp"] + za)
	var pb: Array = ([sb] + zb) if zb[0] != "servers" else (["corp"] + zb)
	var coll_a: Array = state.get_in(pb, [])
	coll_a.append(ca)
	state.assoc_in(pb, coll_a)
	var coll_b: Array = state.get_in(pa, [])
	coll_b.append(cb)
	state.assoc_in(pa, coll_b)


static func swap_ice(state: NRState, a: Dictionary, b: Dictionary) -> void:
	swap_cards(state, a, b)
	NRIce.set_current_ice(state)


static func swap_installed(state: NRState, a: Dictionary, b: Dictionary) -> void:
	swap_cards(state, a, b)


static func as_agenda(state: NRState, side: Variant, card: Dictionary, n: int) -> void:
	var converted = NRCard.convert_to_agenda(card, n)
	move(state, side, converted, "scored")


static func forfeit(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	NRSay.system_msg(state, side, "forfeits %s" % NRCard.get_title(card))
	move(state, side, card, "rfg")
	NRAgendas.update_all_agenda_points(state)
	if NRUtil.truthy(args.get("suppress-checkpoint", false)):
		NREid.effect_completed(state, side, eid)
	else:
		NREngine.checkpoint(state, eid)


static func flip_facedown(state: NRState, side: Variant, card: Dictionary) -> void:
	var c = card.duplicate(true)
	c["facedown"] = true
	NRUpdate.update_card(state, side, c)


static func flip_faceup(state: NRState, side: Variant, card: Dictionary) -> void:
	var c = card.duplicate(true)
	c["facedown"] = false
	c["seen"] = true
	NRUpdate.update_card(state, side, c)


static func get_trash_event(side: Variant, game_trash: bool) -> String:
	if game_trash:
		return "game-trash"
	return "%s-trash" % NRUtil.to_side(side)
