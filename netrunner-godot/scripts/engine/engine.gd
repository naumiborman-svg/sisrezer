class_name NREngine
extends RefCounted
## Ability resolution, events, payment, and checkpoints. Port of game.core.engine.

static var ability_types: Dictionary = {}


static func register_ability_type(kw: String, ability_fn: Callable) -> void:
	ability_types[NRUtil.to_kw(kw)] = ability_fn


static func select_ability_kw(ability: Dictionary) -> Variant:
	for k in ability_types:
		if ability.has(k):
			return k
	return null


static func dissoc_req(ability: Dictionary) -> Dictionary:
	var ab := ability.duplicate(true)
	var kw = select_ability_kw(ab)
	if kw != null and ab[kw] is Dictionary:
		ab[kw].erase("req")
	else:
		ab.erase("req")
	return ab


static func should_trigger(state: NRState, side: Variant, eid: Dictionary, card: Variant, targets: Variant, ability: Variant) -> bool:
	if not (ability is Dictionary):
		return false
	var kw = select_ability_kw(ability)
	if kw != null:
		return should_trigger(state, side, eid, card, targets, ability[kw])
	var req = ability.get("req")
	if req is Callable:
		return bool(req.call(state, side, eid, card, targets))
	return true


static func not_used_once(state: NRState, ability: Dictionary, card: Dictionary) -> bool:
	var once = ability.get("once")
	if once == null:
		return true
	var key = ability.get("once-key", card.get("cid"))
	return not bool(state.get_in([NRUtil.to_kw(once), key], false))


static func can_trigger(state: NRState, side: Variant, eid: Dictionary, ability: Dictionary, card: Variant, targets: Variant) -> bool:
	if not (card is Dictionary):
		card = {}
	return not_used_once(state, ability, card) and should_trigger(state, side, eid, card, targets, ability)


static func is_ability(ability: Dictionary) -> bool:
	if ability.has("effect") or ability.has("msg"):
		return true
	return select_ability_kw(ability) != null


static func resolve_ability(state: NRState, side: Variant, eid_or_ability: Variant, ability_or_card: Variant = null, card_or_targets: Variant = null, targets: Variant = null) -> void:
	# Overloads:
	# (state, side, ability, card, targets)
	# (state, side, eid, ability, card, targets)
	var eid: Dictionary
	var ability: Dictionary
	var card: Variant
	var tgs: Variant
	if eid_or_ability is Dictionary and eid_or_ability.has("eid") and ability_or_card is Dictionary and (ability_or_card.has("effect") or ability_or_card.has("choices") or ability_or_card.has("cost") or ability_or_card.has("msg") or ability_or_card.has("async") or select_ability_kw(ability_or_card) != null or ability_or_card.has("optional") or ability_or_card.has("prompt")):
		eid = eid_or_ability
		ability = ability_or_card
		card = card_or_targets
		tgs = targets
	elif eid_or_ability is Dictionary and not eid_or_ability.has("eid") or (eid_or_ability is Dictionary and (eid_or_ability.has("effect") or eid_or_ability.has("choices") or eid_or_ability.has("cost") or eid_or_ability.has("prompt") or eid_or_ability.has("optional"))):
		ability = eid_or_ability
		card = ability_or_card
		tgs = card_or_targets
		eid = ability.get("eid") if ability.get("eid") is Dictionary else NREid.make_eid(state, {"source": card, "source-type": "ability"})
	else:
		eid = eid_or_ability if eid_or_ability is Dictionary else NREid.make_eid(state)
		ability = ability_or_card if ability_or_card is Dictionary else {}
		card = card_or_targets
		tgs = targets
	_resolve_ability_eid(state, side, NRUtil.merge(ability, {"eid": eid}), card, tgs)


static func continue_ability(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant) -> void:
	resolve_ability(state, side, ability, card, targets)


static func resolve_ability_eid(state: NRState, side: Variant, eid: Dictionary, ability: Dictionary, card: Variant, targets: Variant = null) -> void:
	resolve_ability(state, side, eid, ability, card, targets)


static func wait_for(state: NRState, parent_eid: Dictionary, start: Callable, then: Callable) -> void:
	NREid.wait_for(state, parent_eid, start, then)


static func queue_event_and_resolve(state: NRState, eid: Dictionary, event: String, context: Variant = null, args: Dictionary = {}) -> void:
	queue_event(state, event, context)
	checkpoint(state, eid, args)


static func _resolve_ability_eid(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant) -> void:
	var eid: Dictionary = ability.get("eid", {})
	card = card if card != null else eid.get("source")
	if eid.has("eid") and ability.size() == 1:
		NREid.effect_completed(state, side, eid)
		return
	if not eid.has("eid"):
		resolve_ability(state, side, ability, card, targets)
		return
	ability = ability.duplicate(true)
	if not (ability.get("eid") is Dictionary):
		ability["eid"] = eid
	ability["eid"] = ability["eid"].duplicate(true)
	ability["eid"]["source"] = card
	var kw = select_ability_kw(ability)
	if kw != null and ability_types.has(kw):
		ability_types[kw].call(state, side, ability, card, targets)
	elif ability.has("choices"):
		_check_choices(state, side, ability, card, targets)
	else:
		_check_ability(state, side, ability, card, targets)


static func _check_choices(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant) -> void:
	if can_trigger(state, side, ability["eid"], ability, card, targets):
		_do_choices(state, side, ability, card, targets)
	else:
		NREid.effect_completed(state, side, ability["eid"])


static func _check_ability(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant) -> void:
	if can_trigger(state, side, ability["eid"], ability, card, targets):
		_do_ability(state, side, ability, card, targets)
	else:
		NREid.effect_completed(state, side, ability["eid"])


static func print_msg(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant, payment_str: String) -> void:
	var message = ability.get("msg")
	if message == null:
		return
	var desc: String
	if message is String:
		desc = message
	elif message is Callable:
		desc = str(message.call(state, side, ability.get("eid"), card, targets))
	else:
		return
	var cost_spend := NRPayment.build_spend_msg(payment_str, "use")
	var title := NRCard.get_title(card) if card is Dictionary else "a card"
	var display := ability.get("display-side", NRUtil.to_side(card.get("side") if card is Dictionary else side))
	if NRUtil.kw_eq(message, "cost"):
		NRSay.system_msg(state, display, "%s to satisfy %s" % [payment_str, title])
	elif desc != "":
		NRSay.system_msg(state, display, "%s%s to %s" % [cost_spend, title, desc])


static func register_once(state: NRState, _side: Variant, ability: Dictionary, card: Dictionary) -> void:
	var once = ability.get("once")
	if once != null:
		var key = ability.get("once-key", card.get("cid"))
		state.assoc_in([NRUtil.to_kw(once), key], true)


static func _do_effect(state: NRState, side: Variant, ability: Dictionary, card: Variant, payment_str: String, targets: Variant) -> void:
	var cigs = ability.get("change-in-game-state")
	var ok := true
	if cigs is Dictionary and cigs.get("req") is Callable:
		ok = bool(cigs["req"].call(state, side, ability.get("eid"), card, targets))
	if ok:
		print_msg(state, side, ability, card, targets, payment_str)
		var effect = ability.get("effect")
		if effect is Callable:
			effect.call(state, side, ability.get("eid"), card, targets)
		else:
			NREid.effect_completed(state, side, ability["eid"])
	else:
		print_msg(state, side, NRUtil.merge(ability, {"msg": "do nothing"}), card, [], payment_str)
		NREid.effect_completed(state, side, ability["eid"])


static func merge_costs_paid(a: Dictionary, b: Dictionary = {}) -> Dictionary:
	var acc := a.duplicate(true)
	for k in b:
		var cur: Dictionary = b[k] if b[k] is Dictionary else {"paid/type": k, "paid/value": b[k]}
		var existing: Dictionary = acc.get(k, {})
		acc[k] = {
			"paid/type": cur.get("paid/type", k),
			"paid/value": int(existing.get("paid/value", 0)) + int(cur.get("paid/value", 0)),
			"paid/x-value": int(existing.get("paid/x-value", 0)) + int(cur.get("paid/x-value", 0)),
			"paid/targets": NRUtil.as_array(existing.get("paid/targets")) + NRUtil.as_array(cur.get("paid/targets")),
		}
	return acc


static func _do_paid_ability(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant, payment: Dictionary) -> void:
	var eid: Dictionary = ability.get("eid", {})
	var cost_paid := merge_costs_paid(eid.get("cost-paid", {}), payment.get("cost-paid", {}))
	ability = ability.duplicate(true)
	ability["eid"] = eid.duplicate(true)
	ability["eid"]["cost-paid"] = cost_paid
	var msg := str(payment.get("msg", ""))
	if msg != "":
		ability["eid"]["latest-payment-str"] = msg
	var latest = NRCard.get_card(state, card) if card is Dictionary else card
	if latest != null:
		card = latest
	register_once(state, side, ability, card if card is Dictionary else {})
	_do_effect(state, side, ability, card, msg, targets)
	if not bool(ability.get("async", false)):
		NREid.effect_completed(state, side, ability["eid"])


static func _do_ability(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant) -> void:
	var eid: Dictionary = ability.get("eid", {})
	if bool(ability.get("waiting-prompt", false)):
		var other := NRUtil.other_side(ability.get("player", side))
		NRPromptState.add_to_prompt_queue(state, other, {
			"eid": {"eid": eid.get("eid")},
			"card": card,
			"prompt-type": "waiting",
			"msg": "Waiting for %s to make a decision" % NRUtil.side_str(side),
		})
	var cost = ability.get("cost")
	if cost != null and NRUtil.flatten(cost).size() > 0:
		NREid.wait_for(state, eid, func(pe):
			pay(state, side, pe, card, cost)
		, func(payment):
			if payment is Dictionary and payment.get("cost-paid") != null:
				_do_paid_ability(state, side, ability, card, targets, payment)
			else:
				NREid.effect_completed(state, side, eid)
		)
	else:
		_do_paid_ability(state, side, ability, card, targets, {"msg": ""})


static func _do_choices(state: NRState, side: Variant, ability: Dictionary, card: Variant, targets: Variant) -> void:
	var s := NRUtil.to_side(ability.get("player", side))
	var choices = ability.get("choices")
	var prompt = ability.get("prompt", "Choose")
	if prompt is Callable:
		prompt = str(prompt.call(state, s, ability.get("eid"), card, targets))
	var ab := ability.duplicate(true)
	ab.erase("choices")
	ab.erase("waiting-prompt")
	var args := {
		"async": ability.get("async"),
		"cancel": ability.get("cancel"),
		"prompt-type": ability.get("prompt-type"),
		"targets": targets,
		"waiting-prompt": ability.get("waiting-prompt"),
	}
	if choices is Dictionary:
		if choices.has("req") or choices.has("card"):
			NRPrompts.show_select(state, s, card, ability, args)
		elif choices.has("number"):
			var n = choices["number"]
			if n is Callable:
				n = n.call(state, s, ability.get("eid"), card, targets)
			NRPrompts.show_prompt(state, s, ability.get("eid"), card, str(prompt), {"number": n, "default": choices.get("default", 0)}, func(choice):
				resolve_ability(state, s, ab, card, [choice])
			, args)
		else:
			NRPrompts.show_prompt(state, s, ability.get("eid"), card, str(prompt), choices, func(choice):
				resolve_ability(state, s, ab, card, [choice])
			, args)
	else:
		var cs = choices
		if choices is Callable:
			cs = choices.call(state, s, ability.get("eid"), card, targets)
		NRPrompts.show_prompt(state, s, ability.get("eid"), card, str(prompt), cs, func(choice):
			resolve_ability(state, s, ab, card, [choice])
		, args)


# --- Events ---

static func default_locations(card: Dictionary) -> Array:
	match NRUtil.to_kw(card.get("type")):
		"agenda":
			return ["scored"]
		"asset", "ice", "upgrade":
			return ["servers"]
		"counter":
			return ["hosted"]
		"event", "operation":
			return ["current", "play-area"]
		"hardware", "program", "resource":
			return ["rig"]
		"identity", "fake-identity":
			return ["identity"]
		_:
			return []


static func build_event_ability(ability: Dictionary, card: Dictionary) -> Dictionary:
	var loc = ability.get("location")
	var location: Array
	if loc is Array:
		location = loc
	elif loc != null:
		location = [loc]
	else:
		location = default_locations(card)
	return {
		"event": ability.get("event"),
		"location": location,
		"duration": ability.get("duration", "default-duration"),
		"condition": ability.get("condition", "active"),
		"unregister-once-resolved": bool(ability.get("unregister-once-resolved", false)),
		"once-per-instance": bool(ability.get("once-per-instance", false)),
		"ability": NRUtil.dissoc(ability, ["event", "duration", "condition"]),
		"card": card,
		"uuid": NRUtil.make_uuid(),
	}


static func register_events(state: NRState, side: Variant, card: Dictionary, events: Array = []) -> void:
	if events.is_empty():
		events = NRCardDefs.card_def(card).get("events", [])
	if not (events is Array):
		return
	var handlers: Array = []
	for ability in events:
		if ability is Dictionary:
			handlers.append(build_event_ability(ability, card))
	if not handlers.is_empty():
		var cur: Array = state.getv("events", [])
		cur.append_array(handlers)
		state.setv("events", cur)


static func register_default_events(state: NRState, side: Variant, card: Dictionary) -> void:
	register_events(state, side, card, NRCardDefs.card_def(card).get("events", []))
	register_suppress(state, side, card)


static func register_pending_event(state: NRState, event: String, card: Dictionary, ability: Dictionary) -> void:
	var handler := build_event_ability(NRUtil.merge(ability, {"event": event, "duration": "pending"}), card)
	var cur: Array = state.getv("events", [])
	cur.append(handler)
	state.setv("events", cur)


static func unregister_events(state: NRState, side: Variant, card: Dictionary) -> void:
	var out: Array = []
	for e in state.getv("events", []):
		if e is Dictionary and NRUtil.same_card(card, e.get("card", {})) and NRUtil.kw_eq(e.get("duration"), "default-duration"):
			continue
		out.append(e)
	state.setv("events", out)
	unregister_suppress(state, side, card)


static func unregister_floating_events(state: NRState, _side: Variant, duration: String) -> void:
	var out: Array = []
	for e in state.getv("events", []):
		if e is Dictionary and NRUtil.kw_eq(e.get("duration"), duration):
			continue
		out.append(e)
	state.setv("events", out)


static func update_floating_event_durations(state: NRState, _side: Variant, from_key: String, to_key: String) -> void:
	var out: Array = []
	for e in state.getv("events", []):
		if e is Dictionary and NRUtil.kw_eq(e.get("duration"), from_key):
			var ne := e.duplicate(true)
			ne["duration"] = to_key
			out.append(ne)
		else:
			out.append(e)
	state.setv("events", out)


static func unregister_event_by_uuid(state: NRState, _side: Variant, uuid: String) -> void:
	var out: Array = []
	var removed := false
	for e in state.getv("events", []):
		if not removed and e is Dictionary and e.get("uuid") == uuid:
			removed = true
			continue
		out.append(e)
	state.setv("events", out)


static func register_suppress(state: NRState, _side: Variant, card: Dictionary, events: Variant = null) -> void:
	if events == null:
		events = NRCardDefs.card_def(card).get("suppress", [])
	if not (events is Array):
		return
	var abilities: Array = []
	for ability in events:
		if ability is Dictionary:
			abilities.append({"event": ability.get("event"), "ability": NRUtil.dissoc(ability, ["event"]), "card": card, "uuid": NRUtil.make_uuid()})
	if not abilities.is_empty():
		var cur: Array = state.getv("suppress", [])
		cur.append_array(abilities)
		state.setv("suppress", cur)


static func unregister_suppress(state: NRState, _side: Variant, card: Dictionary, events: Variant = null) -> void:
	if events == null:
		events = NRCardDefs.card_def(card).get("suppress", [])
	var evs: Array = []
	if events is Array:
		for e in events:
			if e is Dictionary:
				evs.append(e.get("event"))
	var out: Array = []
	for s in state.getv("suppress", []):
		if s is Dictionary and NRUtil.same_card(card, s.get("card", {})) and s.get("event") in evs:
			continue
		out.append(s)
	state.setv("suppress", out)


static func trigger_suppress(state: NRState, side: Variant, event: String, context: Variant) -> bool:
	for s in state.getv("suppress", []):
		if s is Dictionary and NRUtil.kw_eq(s.get("event"), event):
			var ab = s.get("ability", {})
			var req = ab.get("req") if ab is Dictionary else null
			if req is Callable and bool(req.call(state, side, NREid.make_eid(state), s.get("card"), [context])):
				return true
	return false


static func gather_events(state: NRState, _side: Variant, event: String) -> Array:
	var out: Array = []
	for e in state.getv("events", []):
		if e is Dictionary and NRUtil.kw_eq(e.get("event"), event):
			out.append(e)
	return out


static func log_event(state: NRState, event: String, context: Variant) -> void:
	var te: Array = state.getv("turn-events", [])
	te.append([event, context])
	state.setv("turn-events", te)
	var run = state.getv("run")
	if run is Dictionary:
		var re: Array = run.get("events", [])
		re.append([event, context])
		run["events"] = re
		state.setv("run", run)


static func trigger_event(state: NRState, side: Variant, event: String, context: Variant = null) -> void:
	log_event(state, event, context)
	if trigger_suppress(state, side, event, context):
		return
	for handler in gather_events(state, side, event):
		var card = handler.get("card")
		var ability: Dictionary = handler.get("ability", {})
		if can_trigger(state, side, NREid.make_eid(state), ability, card, [context]):
			resolve_ability(state, side, NRUtil.merge(ability, {"async": false}), card, [context])


static func trigger_event_sync(state: NRState, side: Variant, eid: Dictionary, event: String, context: Variant = null) -> void:
	log_event(state, event, context)
	if trigger_suppress(state, side, event, context):
		NREid.effect_completed(state, side, eid)
		return
	_trigger_event_sync_next(state, side, eid, gather_events(state, side, event), context)


static func _trigger_event_sync_next(state: NRState, side: Variant, eid: Dictionary, handlers: Array, context: Variant) -> void:
	if handlers.is_empty():
		NREid.effect_completed(state, side, eid)
		return
	var handler: Dictionary = handlers[0]
	var rest := handlers.slice(1)
	var card = handler.get("card")
	var ability: Dictionary = handler.get("ability", {})
	NREid.wait_for(state, eid, func(ne):
		resolve_ability(state, side, ne, NRUtil.merge(ability, {"async": true}), card, [context])
	, func(_r):
		_trigger_event_sync_next(state, side, eid, rest, context)
	)


static func trigger_event_simult(state: NRState, side: Variant, eid: Dictionary, event: String, _opts: Variant = null, context: Variant = null) -> void:
	# Simultaneous resolution: if any handler is interactive, prompt; else resolve sequentially.
	log_event(state, event, context)
	if trigger_suppress(state, side, event, context):
		NREid.effect_completed(state, side, eid)
		return
	_trigger_event_sync_next(state, side, eid, gather_events(state, side, event), context)


static func queue_event(state: NRState, event: String, context: Variant = null) -> void:
	log_event(state, event, context)
	var q: Dictionary = state.getv("queued-events", {})
	var arr: Array = q.get(event, [])
	arr.append(context)
	q[event] = arr
	state.setv("queued-events", q)


static func mark_pending_abilities(state: NRState, _eid: Dictionary, _args: Dictionary = {}) -> Dictionary:
	var q: Dictionary = state.getv("queued-events", {})
	var handlers: Array = []
	var context_maps: Array = []
	for event in q:
		context_maps.append_array(q[event] if q[event] is Array else [])
		for h in gather_events(state, null, event):
			handlers.append(h)
	state.setv("queued-events", {})
	return {"handlers": handlers, "context-maps": context_maps}


static func trigger_pending_abilities(state: NRState, eid: Dictionary, handlers: Array, args: Dictionary = {}) -> void:
	if handlers.is_empty():
		NREid.effect_completed(state, null, eid)
		return
	_trigger_event_sync_next(state, state.getv("active-player", "corp"), eid, handlers, args)


static func resolve_durations(state: NRState, side: Variant, durations: Array = []) -> void:
	for d in durations:
		NREffects.unregister_lingering_effects(state, side, str(d))
		unregister_floating_events(state, side, str(d))


static func get_old_uniques(state: NRState, side: Variant) -> Array:
	var groups := {}
	for c in NRBoard.all_active_installed(state, side):
		if NRCard.unique(c):
			var t := str(c.get("title"))
			if not groups.has(t):
				groups[t] = []
			groups[t].append(c)
	var out: Array = []
	for t in groups:
		var cards: Array = groups[t]
		if cards.size() > 1:
			cards.sort_custom(func(a, b): return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0)))
			for i in range(cards.size() - 1):
				out.append(cards[i])
	return out


static func check_unique_and_consoles(state: NRState, eid: Dictionary) -> void:
	var to_trash: Array = get_old_uniques(state, "corp") + get_old_uniques(state, "runner")
	var consoles: Array = []
	for c in state.get_in(["runner", "rig", "hardware"], []):
		if c is Dictionary and NRCard.console(c):
			consoles.append(c)
	if consoles.size() > 1:
		consoles.sort_custom(func(a, b): return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0)))
		for i in range(consoles.size() - 1):
			to_trash.append(consoles[i])
	if to_trash.is_empty():
		NREid.effect_completed(state, null, eid)
		return
	NRMoving.trash_cards(state, null, eid, to_trash, {"game-trash": true, "unpreventable": true})


static func check_restrictions(state: NRState, eid: Dictionary) -> void:
	NRMemory.update_mu(state)
	NREid.effect_completed(state, null, eid)


static func checkpoint(state: NRState, eid: Dictionary, args: Dictionary = {}) -> void:
	var marked := mark_pending_abilities(state, eid, args)
	var durations: Array = NRUtil.as_array(args.get("durations", []))
	if args.has("duration"):
		durations.append(args["duration"])
	unregister_floating_events(state, null, "pending")
	for d in durations:
		if d != null:
			NREffects.unregister_lingering_effects(state, null, str(d))
			unregister_floating_events(state, null, str(d))
	NREffects.update_disabled_cards(state)
	if NRWinning.check_win_by_agenda(state) and not bool(state.getv("winner-declared", false)):
		state.setv("winner-declared", true)
		trigger_event(state, null, "win", {"winner": state.getv("winner")})
	NREid.wait_for(state, eid, func(ne):
		check_unique_and_consoles(state, ne)
	, func(_r):
		NREid.wait_for(state, eid, func(ne2):
			check_restrictions(state, ne2)
		, func(_r2):
			NRBoard.clear_empty_remotes(state)
			trigger_pending_abilities(state, eid, marked.get("handlers", []), args)
		)
	)


static func end_of_phase_checkpoint(state: NRState, eid: Dictionary, event: String, context: Variant = null) -> void:
	queue_event(state, event, context)
	checkpoint(state, eid, {"duration": event})


static func fake_checkpoint(state: NRState) -> void:
	for i in range(10):
		var changed := [
			NRIce.update_all_ice(state, "corp"),
			NRIce.update_all_icebreakers(state, "runner"),
			NRInitializing.update_all_card_labels(state),
			NRAgendas.update_all_advancement_requirements(state),
			NRAgendas.update_all_agenda_points(state),
			NRLink.update_link(state),
			NRMemory.update_mu(state),
			NRHandSize.update_hand_size(state, "corp"),
			NRHandSize.update_hand_size(state, "runner"),
			NRSubtypes.update_all_subtypes(state),
			NRTags.update_tag_status(state),
		]
		var any := false
		for c in changed:
			if c:
				any = true
		if not any:
			break
	NRBoard.clear_empty_remotes(state)


# --- Pay ---

static func pay(state: NRState, side: Variant, eid: Dictionary, card: Variant, costs: Variant) -> void:
	var merged := NRPayment.merge_costs(costs)
	_pay_next(state, side, eid, card, merged, {}, "")


static func _pay_next(state: NRState, side: Variant, eid: Dictionary, card: Variant, remaining: Array, paid: Dictionary, msg: String) -> void:
	if remaining.is_empty():
		NREid.complete_with_result(state, side, eid, {"msg": msg, "cost-paid": paid})
		return
	var cost: Dictionary = remaining[0]
	var rest := remaining.slice(1)
	if not NRCosts.payable(cost, state, side, eid, card):
		NREid.complete_with_result(state, side, eid, {"msg": null, "cost-paid": null})
		return
	NREid.wait_for(state, eid, func(ne):
		NRCosts.handler(cost, state, side, ne, card)
	, func(result):
		var r: Dictionary = result if result is Dictionary else {"msg": NRPayment.cost_to_string(cost), "cost-paid": {}}
		var new_paid := merge_costs_paid(paid, r.get("cost-paid", {}))
		var new_msg := msg
		var piece := str(r.get("msg", ""))
		if piece != "":
			new_msg = piece if new_msg == "" else (new_msg + " and " + piece)
		_pay_next(state, side, eid, card, rest, new_paid, new_msg)
	)


static func ability_as_handler(ability: Dictionary, card: Dictionary) -> Dictionary:
	return build_event_ability(ability, card)
