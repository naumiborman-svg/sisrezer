class_name NRCosts
extends RefCounted
## Cost type handlers (value/label/payable/handler). Port of game.core.costs.

static func value(cost: Dictionary) -> int:
	match str(cost.get("cost/type")):
		"x-credits", "x-tags", "x-power":
			return 0
		"expend", "return-to-hand", "remove-from-game", "forfeit-self", "trash-entire-hand":
			return 1
		_:
			return int(cost.get("cost/amount", 0))


static func stealth_value(_cost: Dictionary) -> int:
	return 0


static func label(cost: Dictionary) -> String:
	var t = str(cost.get("cost/type"))
	var n = value(cost)
	match t:
		"click":
			return "[Click]".repeat(maxi(n, 1)) if n > 0 else "[Click]"
		"lose-click":
			return "lose " + NRUtil.quantify(n, "[Click]")
		"credit":
			return "%d [Credits]" % n
		"x-credits":
			return "X [Credits]"
		"trash-can":
			return "[trash]"
		"trash-self":
			return "trash itself"
		"forfeit":
			return "forfeit " + NRUtil.quantify(n, "Agenda")
		"forfeit-self":
			return "forfeit this Agenda"
		"gain-tag":
			return "take " + NRUtil.quantify(n, "tag")
		"tag":
			return "remove " + NRUtil.quantify(n, "tag")
		"x-tags":
			return "remove X tags"
		"net":
			return "suffer %d net damage" % n
		"meat":
			return "suffer %d meat damage" % n
		"brain":
			return "suffer %d core damage" % n
		"advancement":
			return "hosted advancement counters"
		"power":
			return NRUtil.quantify(n, "hosted power counter")
		"virus":
			return NRUtil.quantify(n, "hosted virus counter")
		"agenda":
			return NRUtil.quantify(n, "hosted agenda counter")
		"remove-from-game":
			return "remove this card from the game"
		"return-to-hand":
			return "return this card to your hand"
		"expend":
			return "reveal from HQ and trash itself"
		_:
			return t.replace("-", " ")


static func payable(cost: Dictionary, state: NRState, side: Variant, eid: Dictionary, card: Variant) -> bool:
	var t = str(cost.get("cost/type"))
	var n = value(cost)
	var s = NRUtil.to_side(side)
	match t:
		"click":
			return int(state.side_get(s, "click", 0)) >= n
		"lose-click":
			return true
		"credit":
			return total_available_credits(state, s, eid, card) >= n
		"x-credits":
			return total_available_credits(state, s, eid, card) >= 0
		"tag":
			return int(state.get_in(["runner", "tag", "base"], 0)) >= n
		"x-tags":
			return int(state.get_in(["runner", "tag", "base"], 0)) >= 0
		"gain-tag":
			return true
		"net", "meat", "brain":
			return true
		"trash-can", "trash-self":
			return card is Dictionary
		"forfeit":
			return state.get_in([s, "scored"], []).size() >= n
		"forfeit-self":
			return card is Dictionary and NRCard.agenda(card) and NRCard.in_scored(card)
		"remove-from-game", "return-to-hand", "expend":
			return card is Dictionary
		"advancement":
			return card is Dictionary and NRCard.get_counters(card, "advancement") >= n
		"power":
			return card is Dictionary and NRCard.get_counters(card, "power") >= n
		"virus":
			return card is Dictionary and NRVirus.get_virus_counters(state, card) >= n
		"agenda":
			return card is Dictionary and NRCard.get_counters(card, "agenda") >= n
		"trash-from-hand":
			return state.get_in([s, "hand"], []).size() >= n
		"trash-from-deck":
			return state.get_in([s, "deck"], []).size() >= n
		"trash-entire-hand":
			return true
		"randomly-trash-from-hand":
			return state.get_in([s, "hand"], []).size() >= n
		"hardware":
			return NRBoard.all_installed_runner_type(state, "Hardware").size() >= n
		"program":
			return NRBoard.all_installed_runner_type(state, "Program").size() >= n
		"resource":
			return NRBoard.all_installed_runner_type(state, "Resource").size() >= n
		"ice":
			var ices = 0
			for c in NRBoard.all_installed(state, "corp"):
				if NRCard.ice(c):
					ices += 1
			return ices >= n
		_:
			return true


static func handler(cost: Dictionary, state: NRState, side: Variant, eid: Dictionary, card: Variant) -> void:
	var t = str(cost.get("cost/type"))
	var n = value(cost)
	var s = NRUtil.to_side(side)
	var paid = {"paid/type": t, "paid/value": n, "paid/x-value": 0, "paid/targets": []}
	match t:
		"click":
			NRGaining.lose_clicks(state, s, n)
			paid["paid/value"] = n
		"lose-click":
			var have: int = int(state.side_get(s, "click", 0))
			var lost = mini(have, n)
			NRGaining.lose_clicks(state, s, lost)
			paid["paid/value"] = lost
		"credit":
			NRGaining.lose(state, s, "credit", n)
			paid["paid/value"] = n
		"x-credits":
			var have_c: int = int(state.side_get(s, "credit", 0))
			NRGaining.lose(state, s, "credit", have_c)
			paid["paid/value"] = have_c
			paid["paid/x-value"] = have_c
		"tag":
			NRTags.lose_tags(state, s, eid, n, {"suppress-checkpoint": true})
			paid["paid/value"] = n
			NREid.effect_completed(state, s, NREid.make_result(eid, {"msg": NRPayment.cost_to_string(cost), "cost-paid": {t: paid}}))
			return
		"gain-tag":
			NRTags.gain_tags(state, s, eid, n, {"suppress-checkpoint": true})
			NREid.effect_completed(state, s, NREid.make_result(eid, {"msg": NRPayment.cost_to_string(cost), "cost-paid": {t: paid}}))
			return
		"net", "meat", "brain":
			NRDamage.damage(state, s, eid, t, n, {"unpreventable": false, "suppress-checkpoint": true})
			# damage is async; wrap completion
			return
		"trash-self", "trash-can":
			if card is Dictionary:
				NRMoving.trash(state, s, eid, card, {"unpreventable": true, "suppress-checkpoint": true})
				paid["paid/targets"] = [card]
				return
		"forfeit":
			# caller should have selected agendas; forfeit first n scored
			var scored: Array = state.get_in([s, "scored"], [])
			var targets: Array = NRUtil.take_n(scored, n)
			for ag in targets:
				NRMoving.forfeit(state, s, eid, ag, {"suppress-checkpoint": true})
			paid["paid/targets"] = targets
		"remove-from-game":
			if card is Dictionary:
				NRMoving.move(state, s, card, "rfg")
		"return-to-hand":
			if card is Dictionary:
				NRMoving.move(state, s, card, "hand")
		"advancement":
			if card is Dictionary:
				card["advance-counter"] = maxi(0, int(card.get("advance-counter", 0)) - n)
				NRUpdate.update_card(state, s, card)
		"power", "virus", "agenda":
			if card is Dictionary:
				var ctr: Dictionary = card.get("counter", {})
				ctr[t] = maxi(0, int(ctr.get(t, 0)) - n)
				card["counter"] = ctr
				NRUpdate.update_card(state, s, card)
		"trash-from-hand":
			var hand: Array = state.get_in([s, "hand"], [])
			var dumped = NRUtil.take_n(hand, n)
			for c in dumped:
				NRMoving.move(state, s, c, "discard")
			paid["paid/targets"] = dumped
		"trash-from-deck":
			var deck: Array = state.get_in([s, "deck"], [])
			var milled = NRUtil.take_n(deck, n)
			for c in milled:
				NRMoving.move(state, s, c, "discard")
			paid["paid/targets"] = milled
		"trash-entire-hand":
			var all_hand: Array = state.get_in([s, "hand"], []).duplicate()
			for c in all_hand:
				NRMoving.move(state, s, c, "discard")
			paid["paid/targets"] = all_hand
		"randomly-trash-from-hand":
			var h: Array = state.get_in([s, "hand"], []).duplicate()
			h.shuffle()
			var rand = NRUtil.take_n(h, n)
			for c in rand:
				NRMoving.move(state, s, c, "discard")
			paid["paid/targets"] = rand
		_:
			pass
	var msg = NRPayment.cost_to_string(cost)
	NREid.complete_with_result(state, side, eid, {"msg": msg, "cost-paid": {t: paid}})


static func total_available_credits(state: NRState, side: Variant, _eid: Dictionary = {}, _card: Variant = null) -> int:
	return int(state.side_get(side, "credit", 0)) + (int(state.get_in(["runner", "run-credit"], 0)) if NRUtil.to_side(side) == "runner" else 0)


static func all_active_pay_credit_cards(state: NRState, side: Variant) -> Array:
	var out: Array = []
	for c in NRBoard.all_active_installed(state, side):
		var cdef = NRCardDefs.card_def(c)
		if cdef.has("recurring") or (c.get("counter") is Dictionary and int(c["counter"].get("recurring", 0)) > 0):
			out.append(c)
	return out


static func all_active_reduce_credit_cards(state: NRState, side: Variant) -> Array:
	return all_active_pay_credit_cards(state, side)


static func eligible_pay_credit_cards(state: NRState, side: Variant, _eid: Dictionary, _card: Variant) -> Array:
	return all_active_pay_credit_cards(state, side)


static func eligible_reduce_credit_cards(state: NRState, side: Variant, _eid: Dictionary, _card: Variant) -> Array:
	return all_active_reduce_credit_cards(state, side)


static func eligible_pay_stealth_credit_cards(state: NRState, side: Variant, eid: Dictionary, card: Variant) -> Array:
	var out: Array = []
	for c in eligible_pay_credit_cards(state, side, eid, card):
		if NRCard.has_subtype(c, "Stealth"):
			out.append(c)
	return out


static func total_available_stealth_credits(state: NRState, side: Variant, eid: Dictionary, card: Variant) -> int:
	var n = 0
	for c in eligible_pay_stealth_credit_cards(state, side, eid, card):
		n += NRCard.get_counters(c, "credit") + NRCard.get_counters(c, "recurring")
	return n


static func can_forfeit(state: NRState, side: Variant, n: int = 1) -> bool:
	return state.get_in([NRUtil.to_side(side), "scored"], []).size() >= n
