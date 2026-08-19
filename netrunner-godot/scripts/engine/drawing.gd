class_name NRDrawing
extends RefCounted
## Draw from deck to hand. Port of game.core.drawing.

static func max_draw(state: NRState, side: Variant, n: int) -> void:
	state.assoc_in([NRUtil.to_side(side), "register", "max-draw"], n)


static func remaining_draws(state: NRState, side: Variant) -> Variant:
	var s = NRUtil.to_side(side)
	var md = state.get_in([s, "register", "max-draw"])
	if md == null:
		return null
	var drawn: int = int(state.get_in([s, "register", "drawn-this-turn"], 0))
	return maxi(int(md) - drawn, 0)


static func draw_bonus(state: NRState, _side: Variant, n: int) -> void:
	state.update_in(["bonus", "draw"], NRUtil.inc_n(n), 0)


static func click_draw_bonus(state: NRState, _side: Variant, n: int) -> void:
	state.update_in(["bonus", "click-draw"], NRUtil.inc_n(n), 0)


static func use_bonus_click_draws(state: NRState) -> int:
	var n: int = int(state.get_in(["bonus", "click-draw"], 0))
	state.dissoc_in(["bonus", "click-draw"])
	return n


static func first_time_draw_bonus(side: String, n: int) -> Dictionary:
	var event = "pre-%s-draw" % side
	return {
		"event": event,
		"msg": "draw 1 additional card",
		"once": "per-turn",
		"effect": func(state, s, _eid, _card, _targets): draw_bonus(state, s, n),
	}


static func draw(state: NRState, side: Variant, eid: Dictionary, n: int, args: Dictionary = {}) -> void:
	var s = NRUtil.to_side(side)
	if n == 0:
		NREid.effect_completed(state, s, eid)
		return
	var bonus: int = int(state.get_in(["bonus", "draw"], 0))
	n = n + bonus
	var draws_wanted = n
	var active: String = str(state.getv("active-player", s))
	var remaining = remaining_draws(state, s)
	if s == active and remaining != null:
		n = mini(n, int(remaining))
	state.dissoc_in(["bonus", "draw"])
	var deck_count: int = state.get_in([s, "deck"], []).size()
	if s == "corp" and deck_count < n:
		NRWinning.win_decked(state)
	if n < draws_wanted:
		NRSay.system_msg(state, NRUtil.other_side(s), "prevents %s from being drawn" % NRUtil.quantify(draws_wanted - n, "card"))
	if NRUtil.truthy(state.get_in([s, "register", "cannot-draw"], false)) or n <= 0 or deck_count <= 0:
		NREid.effect_completed(state, s, eid)
		return
	var deck: Array = state.get_in([s, "deck"], [])
	var to_draw = NRUtil.take_n(deck, n)
	var drawn = NRSetAside.set_aside_for_me(state, s, eid, to_draw)
	var drawn_count = drawn.size()
	state.update_in([s, "register", "drawn-this-turn"], NRUtil.inc_n(drawn_count), 0)
	if not NRUtil.truthy(args.get("no-update-draw-stats", false)):
		state.update_in(["stats", s, "gain", "card"], NRUtil.inc_n(n), 0)
	if NRUtil.truthy(args.get("suppress-event", false)):
		for c in NRSetAside.get_set_aside(state, s, eid):
			NRMoving.move(state, s, c, "hand")
		NREid.effect_completed(state, s, eid)
	else:
		var draw_event = "corp-draw" if s == "corp" else "runner-draw"
		var currently: Array = state.get_in([s, "register", "currently-drawing"], [])
		currently.append(drawn)
		state.assoc_in([s, "register", "currently-drawing"], currently)
		NREngine.queue_event(state, draw_event, {"cards": drawn, "count": drawn_count})
		NREid.wait_for(state, eid, func(ck):
			NREngine.checkpoint(state, ck)
		, func(_r):
			for c in NRSetAside.get_set_aside(state, s, eid):
				NRMoving.move(state, s, c, "hand")
			var currently2: Array = state.get_in([s, "register", "currently-drawing"], [])
			if not currently2.is_empty():
				currently2.pop_back()
				state.assoc_in([s, "register", "currently-drawing"], currently2)
			NREid.effect_completed(state, s, NREid.make_result(eid, drawn))
		)
	if remaining_draws(state, s) == 0:
		NRFlags.prevent_draw(state, s)


static func maybe_draw(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, n: int, _args: Dictionary = {}) -> void:
	if n == 0:
		draw(state, side, eid, 0)
		return
	NREngine.resolve_ability(state, side, eid, {
		"optional": {
			"prompt": "Draw %s?" % NRUtil.quantify(n, "card"),
			"waiting-prompt": true,
			"yes-ability": {
				"async": true,
				"msg": "draw %s" % NRUtil.quantify(n, "card"),
				"effect": func(st, sd, e, _c, _t): draw(st, sd, e, n),
			},
		},
	}, card, null)


static func draw_up_to(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, n: int, args: Dictionary = {}) -> void:
	if n == 0:
		draw(state, side, eid, 0, args)
		return
	NREngine.resolve_ability(state, side, eid, {
		"prompt": "Draw how many cards?",
		"choices": {"number": func(_st, _sd, _e, _c, _t): return n, "default": func(_st, _sd, _e, _c, _t): return n},
		"waiting-prompt": true,
		"async": true,
		"effect": func(st, sd, e, _c, targets):
			var amt = n
			if targets is Array and not targets.is_empty():
				var t = targets[0]
				amt = int(t.get("value", t) if t is Dictionary else t)
			draw(st, sd, e, amt, args),
	}, card, null)
