class_name NRAccess
extends RefCounted
## Access / steal / trash on access / breach. Port of game.core.access.

static func access_bonus(state: NRState, server: Variant, n: int) -> void:
	state.update_in(["bonus", "access", NRServers.unknown_to_kw(server)], NRUtil.inc_n(n), 0)


static func access_bonus_count(state: NRState, server: Variant) -> int:
	return int(state.get_in(["bonus", "access", NRServers.unknown_to_kw(server)], 0))


static func max_access(state: NRState, n: int) -> void:
	state.assoc_in(["run", "max-access"], n)


static func num_cards_to_access(state: NRState, server: Variant, args: Dictionary = {}) -> int:
	var base = 1
	if NRServers.unknown_to_kw(server) == "rd":
		base = 1 + access_bonus_count(state, "rd")
	elif NRServers.unknown_to_kw(server) == "hq":
		base = 1 + access_bonus_count(state, "hq")
	elif NRServers.unknown_to_kw(server) == "archives":
		base = state.get_in(["corp", "discard"], []).size()
	else:
		base = state.get_in(["corp", "servers", NRServers.unknown_to_kw(server), "content"], []).size()
	var mx = state.get_in(["run", "max-access"])
	if mx != null:
		base = mini(base, int(mx))
	return maxi(base + int(args.get("access-bonus", 0)), 0)


static func steal(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	if not NRFlags.can_steal(state, side, card):
		NREid.effect_completed(state, side, eid)
		return
	NRSay.system_msg(state, side, "steals %s" % NRCard.get_title(card))
	var moved = NRMoving.move(state, "runner", card, "scored")
	if moved is Dictionary:
		moved["new"] = true
		NRAgendas.update_all_agenda_points(state)
		NRInitializing.card_init(state, "runner", moved, {"resolve-effect": true, "init-data": true})
	NREngine.queue_event(state, "agenda-stolen", {"card": moved})
	NRWinning.check_win_by_agenda(state)
	if NRUtil.truthy(args.get("suppress-checkpoint", false)):
		NREid.complete_with_result(state, side, eid, moved)
	else:
		NREngine.checkpoint(state, eid)


static func access_card(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		c = card
	state.setv("access", c)
	NRSay.system_msg(state, "runner", "accesses %s" % (NRCard.get_title(c) if NRCard.is_public(c, "runner") or NRCard.agenda(c) or NRCard.in_discard(c) else "a card"))
	NREngine.queue_event(state, "access", {"card": c})
	if NRCard.agenda(c):
		steal(state, side, eid, c, args)
		return
	var tcost = NRCostFns.trash_cost(state, side, c)
	if tcost != null and NRPayment.can_pay(state, side, eid, c, null, [NRPayment.to_c("credit", int(tcost))]) != null:
		NREngine.resolve_ability(state, side, eid, {
			"prompt": "Trash %s for %d [Credits]?" % [NRCard.get_title(c), int(tcost)],
			"choices": ["Pay %d [Credits] to trash" % int(tcost), "No"],
			"async": true,
			"effect": func(st, sd, e, _card, targets):
				var val = targets[0].get("value") if targets is Array and targets[0] is Dictionary else (targets[0] if targets is Array else "No")
				if str(val).begins_with("Pay"):
					NREid.wait_for(st, e, func(pe):
						NREngine.pay(st, sd, pe, c, [NRPayment.to_c("credit", int(tcost))])
					, func(_p):
						NRMoving.trash(st, sd, e, c, {})
					)
				else:
					NREid.effect_completed(st, sd, e),
		}, c, null)
	else:
		NREid.effect_completed(state, side, eid)
	state.setv("access", null)


static func breach_server(state: NRState, side: Variant, eid: Dictionary, server: Variant, args: Dictionary = {}) -> void:
	var kw = NRServers.unknown_to_kw(NRUtil.first_of(server) if server is Array else server)
	NRSay.system_msg(state, "runner", "breaches %s" % NRServers.zone_to_name(kw))
	NREngine.queue_event(state, "breach-server", {"server": kw})
	var cards: Array = []
	match kw:
		"hq":
			cards = state.get_in(["corp", "hand"], []).duplicate()
			cards.shuffle()
			cards = NRUtil.take_n(cards, num_cards_to_access(state, "hq", args))
			# plus root
			cards.append_array(state.get_in(["corp", "servers", "hq", "content"], []))
		"rd":
			cards = NRUtil.take_n(state.get_in(["corp", "deck"], []), num_cards_to_access(state, "rd", args))
			cards.append_array(state.get_in(["corp", "servers", "rd", "content"], []))
		"archives":
			cards = state.get_in(["corp", "discard"], []).duplicate()
			cards.append_array(state.get_in(["corp", "servers", "archives", "content"], []))
		_:
			cards = state.get_in(["corp", "servers", kw, "content"], []).duplicate()
	_access_next(state, side, eid, cards, 0)


static func _access_next(state: NRState, side: Variant, eid: Dictionary, cards: Array, idx: int) -> void:
	if idx >= cards.size():
		NREid.effect_completed(state, side, eid)
		return
	var card = cards[idx]
	if not (card is Dictionary):
		_access_next(state, side, eid, cards, idx + 1)
		return
	NREid.wait_for(state, eid, func(ne):
		access_card(state, side, ne, card)
	, func(_r):
		_access_next(state, side, eid, cards, idx + 1)
	)


static func set_only_card_to_access(state: NRState, card: Dictionary) -> void:
	state.assoc_in(["run", "only-card-to-access"], card)


static func get_only_card_to_access(state: NRState) -> Variant:
	return state.get_in(["run", "only-card-to-access"])


static func steal_cost_bonus(state: NRState, n: int) -> void:
	state.update_in(["bonus", "steal-cost"], NRUtil.inc_n(n), 0)


static func access_cost_bonus(state: NRState, n: int) -> void:
	state.update_in(["bonus", "access-cost"], NRUtil.inc_n(n), 0)


static func no_trash_or_steal(state: NRState) -> void:
	state.assoc_in(["run", "no-trash-or-steal"], true)
