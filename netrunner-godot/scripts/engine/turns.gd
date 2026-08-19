class_name NRTurns
extends RefCounted
## Turn structure: start-turn, phase 1.2, discard, end-turn. Port of game.core.turns.

static func start_turn(state: NRState, side: Variant, _args: Variant = null) -> void:
	var s = NRUtil.to_side(side)
	if NRUtil.truthy(state.get_in([s, "turn-started"], false)):
		return
	state.setv("turn-events", [])
	state.assoc_in([s, "turn-started"], true)
	state.setv("last-revealed", [])
	state.setv("click-states", [])
	state.data.erase("paid-ability-state")
	if s == "corp":
		state.setv("turn", int(state.getv("turn", 0)) + 1)
	for c in NRBoard.all_installed_and_scored(state, s) + state.get_in([s, "discard"], []):
		if c is Dictionary and NRUtil.truthy(c.get("new", false)):
			var cc = c.duplicate(true)
			cc.erase("new")
			NRUpdate.update_card(state, s, cc)
	state.setv("active-player", s)
	state.setv("per-turn", null)
	state.setv("end-turn", false)
	for sd in ["runner", "corp"]:
		state.assoc_in([sd, "register"], {})
	NRGaining.gain(state, s, "click", int(state.get_in([s, "click-per-turn"], 3)))
	var extra: int = int(state.get_in([s, "extra-click-temp"], 0))
	if extra < 0:
		NRGaining.lose(state, s, "click", abs(extra))
	elif extra > 0:
		NRGaining.gain(state, s, "click", extra)
	state.dissoc_in([s, "extra-click-temp"])
	var phase = "corp-phase-12" if s == "corp" else "runner-phase-12"
	state.setv(phase, {"active": true})
	NREngine.trigger_event(state, s, phase, null)
	end_phase_12(state, s, null)


static func end_phase_12(state: NRState, side: Variant, _args: Variant = null, eid: Dictionary = {}) -> void:
	if eid.is_empty():
		eid = NREid.make_eid(state)
	var s = NRUtil.to_side(side)
	var flag = "corp-phase-12" if s == "corp" else "runner-phase-12"
	if not state.getv(flag):
		NREid.effect_completed(state, s, eid)
		return
	var credits: int = int(state.side_get(s, "credit", 0))
	var cards: int = state.get_in([s, "hand"], []).size()
	NRSay.system_msg(state, s, "started [their] turn %d with %d [Credit] and %s in %s" % [int(state.getv("turn", 0)), credits, NRUtil.quantify(cards, "card"), ("HQ" if s == "corp" else "[their] Grip")])
	var begin = "corp-turn-begins" if s == "corp" else "runner-turn-begins"
	NREid.wait_for(state, eid, func(ne):
		NREngine.trigger_event_simult(state, s, ne, begin, null, null)
	, func(_r):
		NREngine.resolve_durations(state, s, ["start-of-turn", "until-corp-turn-begins" if s == "corp" else "until-runner-turn-begins"])
		if s == "corp":
			NRSay.system_msg(state, s, "makes [their] mandatory start of turn draw")
			NRDrawing.draw(state, s, NREid.make_eid(state), 1, {"suppress-event": false})
		state.setv(flag, false)
		NREid.effect_completed(state, s, eid)
	)


static func phase_12_pass_priority(state: NRState, side: Variant, _args: Variant = null) -> void:
	end_phase_12(state, NRUtil.to_side(state.getv("active-player", side)), null)


static func end_turn(state: NRState, side: Variant, _args: Variant = null, eid: Dictionary = {}) -> void:
	if eid.is_empty():
		eid = NREid.make_eid(state)
	var s = NRUtil.to_side(side)
	NREid.wait_for(state, eid, func(ne):
		NREngine.trigger_event_simult(state, s, ne, ("runner-action-phase-ends" if s == "runner" else "corp-action-phase-ends"), null, null)
	, func(_r):
		_handle_end_of_turn_discard(state, s, eid)
	)


static func _handle_end_of_turn_discard(state: NRState, side: Variant, eid: Dictionary) -> void:
	var s = NRUtil.to_side(side)
	var cur: int = state.get_in([s, "hand"], []).size()
	var maxn = NRHandSize.hand_size(state, s)
	if s == "runner" and maxn < 0:
		NRWinning.flatline(state)
		NREid.effect_completed(state, s, eid)
		return
	if NREffects.any_effects(state, s, "skip-discard"):
		NRSay.system_msg(state, s, "skips [their] discard step this turn")
		end_turn_continue(state, s, eid)
		return
	if cur > maxn:
		var to_discard = cur - maxi(maxn, 0)
		var hand: Array = state.get_in([s, "hand"], [])
		var dumped = NRUtil.take_n(hand, to_discard)
		for c in dumped:
			NRMoving.move(state, s, c, "discard")
		NRSay.system_msg(state, s, "discards %s from %s at end of turn" % [NRUtil.quantify(dumped.size(), "card"), ("HQ" if s == "corp" else "[their] Grip")])
	end_turn_continue(state, s, eid)


static func end_turn_continue(state: NRState, side: Variant, eid: Dictionary = {}, _args: Variant = null) -> void:
	if eid.is_empty():
		eid = NREid.make_eid(state)
	var s = NRUtil.to_side(side)
	var credits: int = int(state.side_get(s, "credit", 0))
	var cards: int = state.get_in([s, "hand"], []).size()
	NRSay.system_msg(state, s, "is ending [their] turn %d with %d [Credit] and %s in %s" % [int(state.getv("turn", 0)), credits, NRUtil.quantify(cards, "card"), ("HQ" if s == "corp" else "[their] Grip")], {"hr": true})
	NREngine.trigger_event(state, s, ("runner-turn-ends" if s == "runner" else "corp-turn-ends"), null)
	state.assoc_in([s, "register-last-turn"], state.get_in([s, "register"], {}))
	NREngine.resolve_durations(state, s, ["end-of-turn", "end-of-next-run", "end-of-run", "end-of-encounter", "until-runner-turn-ends" if s == "runner" else "until-corp-turn-ends"])
	state.setv("end-turn", true)
	NRSetAside.clean_set_aside(state, s)
	for card in NRBoard.all_active_installed(state, "runner"):
		if card is Dictionary and str(card.get("installed")) == "this-turn":
			var cc = card.duplicate(true)
			cc["installed"] = true
			NRUpdate.update_card(state, "runner", cc)
		if card is Dictionary and NRCard.has_subtype(card, "Icebreaker"):
			NRIce.update_breaker_strength(state, "runner", card)
	for card in NRBoard.all_installed(state, "corp"):
		if card is Dictionary and str(card.get("installed")) == "this-turn":
			var cc = card.duplicate(true)
			cc["installed"] = true
			NRUpdate.update_card(state, "corp", cc)
		if card is Dictionary and str(card.get("rezzed")) == "this-turn":
			var cc2 = card.duplicate(true)
			cc2["rezzed"] = true
			NRUpdate.update_card(state, "corp", cc2)
	NRIce.update_all_ice(state, s)
	state.dissoc_in([s, "register", "cannot-draw"])
	state.dissoc_in([s, "register", "drawn-this-turn"])
	state.dissoc_in([s, "turn-started"])
	state.setv("mark", null)
	NRFlags.clear_turn_register(state)
	NREid.effect_completed(state, s, eid)


static func post_discard_pass_priority(state: NRState, side: Variant, _args: Variant = null) -> void:
	end_turn_continue(state, NRUtil.to_side(state.getv("active-player", side)))
