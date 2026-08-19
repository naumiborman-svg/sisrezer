class_name NRCardXlate
extends RefCounted

## Shared helpers for translated Jinteki.net card files.
## Ports of game.core.def-helpers (run abilities, drain-credits) and
## game.core.ice (break-sub, strength-pump) so card files can stay in scripts/cards/.


static func merge_cdef(printed: Dictionary, logic: Dictionary) -> Dictionary:
	var out = printed.duplicate(true)
	out.merge(logic, true)
	return out


static func ctx(targets: Variant) -> Dictionary:
	return NRUtil.ability_context(targets)


static func first_target(targets: Variant) -> Variant:
	var c = ctx(targets)
	if not c.is_empty():
		if c.has("value"):
			return c.get("value")
		if c.size() == 1 and c.has("card"):
			return c.get("card")
	if targets is Array and not targets.is_empty():
		var t = targets[0]
		if t is Dictionary and t.has("value"):
			return t.get("value")
		return t
	return targets


static func this_card_run(state: NRState, card: Variant, targets: Variant) -> bool:
	if not (card is Dictionary):
		return false
	var run = state.getv("run")
	if not (run is Dictionary):
		var c = ctx(targets)
		run = {"run-id": c.get("run-id"), "source-card": c.get("source-card")}
	var src = run.get("source-card")
	if src is Dictionary and NRUtil.same_card(card, src):
		return true
	var special_id = NRUtil.get_in(card, ["special", "run-id"])
	if special_id != null and special_id == run.get("run-id"):
		return true
	return false


static func runnable_servers(state: NRState, side: Variant, eid: Dictionary, card: Variant) -> Array:
	return NRServers.zones_to_sorted_names(NRRuns.get_runnable_zones(state, side, eid, card, {}))


static func cost_vec(cost: Variant) -> Array:
	if cost == null:
		return []
	if NRUtil.is_number(cost):
		return [NRPayment.to_c("credit", int(cost))]
	if cost is Array:
		var out: Array = []
		for c in cost:
			out.append_array(cost_vec(c))
		return out
	if cost is Dictionary:
		return [cost]
	return []


static func run_server_ability(server: Variant, extra: Dictionary = {}) -> Dictionary:
	var events: Array = extra.get("events", [])
	var ab = {
		"async": true,
		"makes-run": true,
		"label": "run %s" % NRServers.zone_to_name(server),
		"msg": "make a run on %s" % NRServers.zone_to_name(server),
		"req": func(state, _side, _eid, _card, _t):
			return NRRuns.can_run_server(state, server),
		"effect": func(state, side, eid, card, _t):
			if events.size() > 0:
				NREngine.register_events(state, side, card, events)
			NRRuns.make_run(state, side, eid, server, card),
	}
	var rest = extra.duplicate(true)
	rest.erase("events")
	ab.merge(rest, true)
	return ab


static func run_any_server_ability(extra: Dictionary = {}) -> Dictionary:
	var events: Array = extra.get("events", [])
	var ab = {
		"async": true,
		"prompt": "Choose a server",
		"choices": func(state, side, eid, card, _t):
			return runnable_servers(state, side, eid, card),
		"req": func(state, side, eid, card, _t):
			return not runnable_servers(state, side, eid, card).is_empty(),
		"label": "Run a server",
		"makes-run": true,
		"msg": func(_s, _sd, _e, _c, targets):
			return "make a run on %s" % str(first_target(targets)),
		"effect": func(state, side, eid, card, targets):
			if events.size() > 0:
				NREngine.register_events(state, side, card, events)
			NRRuns.make_run(state, side, eid, first_target(targets), card),
	}
	var rest = extra.duplicate(true)
	rest.erase("events")
	ab.merge(rest, true)
	return ab


static func run_central_server_ability() -> Dictionary:
	return {
		"prompt": "Choose a central server",
		"choices": func(state, side, eid, card, _t):
			var out: Array = []
			for s in runnable_servers(state, side, eid, card):
				if str(s) in ["HQ", "R&D", "Archives"]:
					out.append(s)
			return out,
		"async": true,
		"label": "Run a central server",
		"msg": func(_s, _sd, _e, _c, targets):
			return "make a run on %s" % str(first_target(targets)),
		"effect": func(state, side, eid, card, targets):
			NRRuns.make_run(state, side, eid, first_target(targets), card),
	}


static func run_remote_server_ability() -> Dictionary:
	return {
		"async": true,
		"prompt": "Choose a remote server",
		"choices": func(state, side, eid, card, _t):
			var out: Array = []
			for s in runnable_servers(state, side, eid, card):
				if NRServers.is_remote(s):
					out.append(s)
			return out,
		"label": "Run a remote server",
		"msg": func(_s, _sd, _e, _c, targets):
			return "make a run on %s" % str(first_target(targets)),
		"effect": func(state, side, eid, card, targets):
			NRRuns.make_run(state, side, eid, first_target(targets), card),
	}


static func run_server_from_choices_ability(choices: Array, extra: Dictionary = {}) -> Dictionary:
	var events: Array = extra.get("events", [])
	var ab = {
		"prompt": "Choose a server",
		"choices": func(state, _side, _eid, _card, _t):
			var out: Array = []
			for s in choices:
				if NRRuns.can_run_server(state, s):
					out.append(s)
			return out,
		"async": true,
		"msg": func(_s, _sd, _e, _c, targets):
			return "make a run on %s" % str(first_target(targets)),
		"effect": func(state, side, eid, card, targets):
			if events.size() > 0:
				NREngine.register_events(state, side, card, events)
			NRRuns.make_run(state, side, eid, first_target(targets), card),
	}
	var rest = extra.duplicate(true)
	rest.erase("events")
	ab.merge(rest, true)
	return ab


static func successful_run_replace_breach(props: Dictionary) -> Dictionary:
	var ability: Dictionary = props.get("ability", {})
	var attacked = props.get("target-server")
	var use_this: bool = NRUtil.truthy(props.get("this-card-run", false))
	return {
		"event": "successful-run",
		"duration": props.get("duration"),
		"silent": true,
		"async": true,
		"req": func(state, _side, _eid, card, targets):
			if use_this and not this_card_run(state, card, targets):
				return false
			var c = ctx(targets)
			var server = c.get("server", state.get_in(["run", "server"]))
			var kw = NRServers.unknown_to_kw(NRUtil.first_of(NRUtil.as_array(server)))
			if attacked == null:
				return true
			var atk = NRUtil.to_kw(attacked)
			if atk in ["hq", "rd", "archives"]:
				return kw == atk
			if atk == "remote":
				return NRServers.is_remote(kw)
			return true,
		"effect": func(state, side, eid, card, targets):
			NRRuns.prevent_access(state)
			if ability.is_empty():
				NREid.effect_completed(state, side, eid)
			else:
				NREngine.resolve_ability(state, side, eid, ability, card, targets),
	}


static func drain_credits(draining_side: Variant, victim_side: Variant, qty: int, multiplier: int = 1, tags_to_gain: int = 0) -> Dictionary:
	return {
		"async": true,
		"msg": func(state, _s, _e, _c, _t):
			var have: int = int(state.get_in([NRUtil.to_side(victim_side), "credit"], 0))
			var drain: int = mini(have, qty)
			var gain: int = drain * multiplier
			var m = "force the %s to lose %d [Credits], gain %d [Credits]" % [NRUtil.side_str(victim_side), drain, gain]
			if tags_to_gain > 0:
				m += ", and take %d tag%s" % [tags_to_gain, "s" if tags_to_gain != 1 else ""]
			return m,
		"effect": func(state, _side, eid, _card, _t):
			var have: int = int(state.get_in([NRUtil.to_side(victim_side), "credit"], 0))
			var drain: int = mini(have, qty)
			var gain: int = drain * multiplier
			if tags_to_gain <= 0:
				NREid.wait_for(state, eid, func(ne):
					NRGaining.lose_credits(state, victim_side, ne, drain, {"suppress-checkpoint": true})
				, func(_r):
					NRGaining.gain_credits(state, draining_side, eid, gain)
				)
			else:
				NREid.wait_for(state, eid, func(ne):
					NRTags.gain_tags(state, draining_side, ne, tags_to_gain)
				, func(_r):
					NREid.wait_for(state, eid, func(ne2):
						NRGaining.lose_credits(state, victim_side, ne2, drain, {"suppress-checkpoint": true})
					, func(_r2):
						NRGaining.gain_credits(state, draining_side, eid, gain)
					)
				),
	}


static func break_sub(cost: Variant, n: Variant, subtypes: Variant = null, args: Dictionary = {}) -> Dictionary:
	var costs: Array = cost_vec(cost)
	var subtype_set: Array = []
	if subtypes is String:
		subtype_set = [subtypes]
	elif subtypes is Array:
		subtype_set = subtypes
	elif subtypes == null:
		subtype_set = ["All"]
	else:
		subtype_set = [str(subtypes)]
	var n_num: int = int(n) if NRUtil.is_number(n) else 0
	var label: String = str(args.get("label", ""))
	if label == "":
		var ice_bit = "" if subtype_set == ["All"] else " " + " or ".join(subtype_set)
		if n_num <= 0:
			label = "break any number of%s subroutines" % ice_bit
		elif n_num == 1:
			label = "break 1%s subroutine" % ice_bit
		else:
			label = "break up to %d%s subroutines" % [n_num, ice_bit]
	var extra_req = args.get("req")
	return {
		"async": true,
		"break": n_num,
		"breaks": subtype_set,
		"break-cost": costs,
		"label": label,
		"req": func(state, side, eid, card, targets):
			var ice = NRIce.get_current_ice(state)
			if not (ice is Dictionary) or not NRIce.active_ice(state, ice):
				return false
			if not ("All" in subtype_set):
				var ok = false
				for st in subtype_set:
					if NRCard.has_subtype(ice, str(st)):
						ok = true
						break
				if not ok:
					return false
			if NRCard.has_subtype(card, "Icebreaker") and NRIce.get_strength(ice) > NRIce.get_strength(card):
				return false
			if extra_req is Callable and not NRUtil.truthy(extra_req.call(state, side, eid, card, targets)):
				return false
			return true,
		"cost": costs,
		"effect": func(state, side, eid, card, _t):
			var ice = NRIce.get_current_ice(state)
			if not (ice is Dictionary):
				NREid.effect_completed(state, side, eid)
				return
			var broken: Array = []
			var limit: int = n_num if n_num > 0 else 99
			for sub in ice.get("subroutines", []):
				if broken.size() >= limit:
					break
				if sub is Dictionary and not NRUtil.truthy(sub.get("broken")) and sub.get("resolve", true) != false:
					NRIce.break_subroutine_bang(state, ice, sub, card)
					broken.append(sub)
			ice = NRIce.get_current_ice(state)
			if ice is Dictionary:
				NREngine.queue_event(state, "subroutines-broken", NRIce.break_subs_event_context(state, ice, broken, card))
			var extra: Dictionary = args.get("additional-ability", {})
			if extra.is_empty():
				NREid.effect_completed(state, side, eid)
			else:
				NREngine.resolve_ability(state, side, eid, extra, card, []),
	}


static func strength_pump(cost: Variant, strength: int, duration: Variant = "end-of-encounter", args: Dictionary = {}) -> Dictionary:
	var costs: Array = cost_vec(cost)
	var dur = str(duration) if duration != null else "end-of-encounter"
	if dur.begins_with(":"):
		dur = dur.substr(1)
	var dur_str = ""
	if dur == "end-of-run":
		dur_str = " for the remainder of the run"
	elif dur == "end-of-turn":
		dur_str = " for the remainder of the turn"
	var label: String = str(args.get("label", "add %d strength%s" % [strength, dur_str]))
	return {
		"label": label,
		"cost": costs,
		"pump": strength,
		"msg": func(state, _s, _e, card, _t):
			var cur = NRIce.get_strength(card)
			return "increase its strength from %d to %d%s" % [cur, cur + strength, dur_str],
		"effect": func(state, side, _eid, card, _t):
			NRIce.pump(state, side, card, strength, dur),
	}


static func auto_icebreaker(cdef: Dictionary) -> Dictionary:
	## Auto-pump event wiring is simplified; break/pump abilities still register.
	return cdef


static func take_credits(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, typ: String, n: Variant) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	var have: int = NRCard.get_counters(c, typ)
	var amt: int = have if str(n) == "all" or NRUtil.kw_eq(n, "all") else mini(have, int(n))
	if amt <= 0:
		NREid.effect_completed(state, side, eid)
		return
	NREid.wait_for(state, eid, func(ne):
		NRProps.add_counter(state, side, ne, c, typ, -amt, {"placed": true, "suppress-checkpoint": true})
	, func(_r):
		NRGaining.gain_credits(state, side, eid, amt)
	)


static func take_n_credits_ability(n: int, extra: Dictionary = {}) -> Dictionary:
	var ab = {
		"label": "Take %d [Credits] from this card" % n,
		"msg": func(_s, _sd, _e, card, _t):
			return "gain %d [Credits]" % mini(n, NRCard.get_counters(card, "credit")),
		"async": true,
		"req": func(_s, _sd, _e, card, _t):
			return NRCard.get_counters(card, "credit") > 0,
		"effect": func(state, side, eid, card, _t):
			take_credits(state, side, eid, card, "credit", n),
	}
	ab.merge(extra, true)
	return ab


static func in_hand_star(state: NRState, card: Dictionary) -> bool:
	return NRCard.in_hand(card)


static func current_ice(state: NRState) -> Variant:
	return NRIce.get_current_ice(state)


static func tagged(state: NRState) -> bool:
	return NRUtil.is_tagged(state)


static func corp_player(state: NRState) -> Dictionary:
	return state.getv("corp", {})


static func runner_player(state: NRState) -> Dictionary:
	return state.getv("runner", {})


static func getk(obj: Variant, key: Variant, default_value: Variant = null) -> Variant:
	if obj is Dictionary:
		if obj.has(key):
			return obj[key]
		var ks = str(key)
		if obj.has(ks):
			return obj[ks]
		for k in obj.keys():
			if NRUtil.kw_eq(k, key):
				return obj[k]
	return default_value


static func bypass_ice(state: NRState) -> void:
	NRRuns.update_current_encounter(state, "bypass", true)


static func count_tags(state: NRState) -> int:
	return int(state.get_in(["runner", "tag", "total"], 0))


static func all_cards_in_hand_star(state: NRState, side: Variant) -> Array:
	var out: Array = []
	for c in state.get_in([NRUtil.to_side(side), "hand"], []):
		if c is Dictionary:
			out.append(c)
	return out


static func fnil(_inner: Callable = Callable(), default_value: Variant = 0) -> Callable:
	return func(v):
		return default_value if v == null else v


static func mu_plus(n: int = 1) -> Dictionary:
	return {"type": "available-mu", "value": n}


static func link_plus(n: int = 1) -> Dictionary:
	return {"type": "user-link", "value": n}


static func hand_size_plus(n: int = 1) -> Dictionary:
	return {"type": "hand-size", "value": n}
