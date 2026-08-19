class_name NRRuns
extends RefCounted
## Run pipeline: initiation, approach, encounter, movement, success, jack-out, end. Port of game.core.runs.

static func total_run_cost(state: NRState, side: Variant, card: Variant, args: Dictionary = {}) -> Array:
	if NRUtil.truthy(args.get("ignore-costs", false)):
		return []
	var cost = NRCostFns.run_cost(state, side, card, args)
	var costs: Array = []
	if NRUtil.truthy(args.get("click-run", false)):
		costs.append(NRPayment.to_c("click", 1))
	if cost > 0:
		costs.append(NRPayment.to_c("credit", cost))
	costs.append_array(NRCostFns.run_additional_cost_bonus(state, side, card, args))
	return NRPayment.merge_costs(costs)


static func get_runnable_zones(state: NRState, side: Variant = "runner", eid: Dictionary = {}, card: Variant = null, args: Dictionary = {}) -> Array:
	if eid.is_empty():
		eid = NREid.make_eid(state)
	var restricted: Array = NRUtil.flatten(NREffects.get_effects(state, side, "cannot-run-on-server"))
	var zones: Array = args.get("zones", NRBoard.get_zones(state))
	var permitted: Array = []
	for z in zones:
		if not (z in restricted):
			permitted.append(z)
	if NRUtil.truthy(args.get("ignore-costs", false)):
		return permitted
	var out: Array = []
	for z in permitted:
		var costs = total_run_cost(state, side, card, NRUtil.merge(args, {"server": NRServers.unknown_to_kw(z)}))
		if NRPayment.can_pay(state, "runner", eid, card, null, costs) != null:
			out.append(z)
	return out


static func can_run_server(state: NRState, server: Variant) -> bool:
	var kw = NRServers.unknown_to_kw(server)
	for z in get_runnable_zones(state):
		if NRServers.unknown_to_kw(z) == kw:
			return true
	return false


static func get_current_encounter(state: NRState) -> Variant:
	var enc: Array = state.getv("encounters", [])
	if enc.is_empty():
		return null
	return enc[enc.size() - 1]


static func active_encounter(state: NRState) -> bool:
	return get_current_encounter(state) != null and NRIce.active_ice(state)


static func update_current_encounter(state: NRState, key: String, value: Variant) -> void:
	var enc = get_current_encounter(state)
	if not (enc is Dictionary):
		return
	var updated = enc.duplicate(true)
	updated[key] = value
	var all: Array = state.getv("encounters", [])
	all[all.size() - 1] = updated
	state.setv("encounters", all)


static func clear_encounter(state: NRState) -> void:
	var enc = get_current_encounter(state)
	if not (enc is Dictionary):
		return
	var all: Array = state.getv("encounters", [])
	all.pop_back()
	state.setv("encounters", all)
	state.setv("per-encounter", null)
	if enc.get("eid") is Dictionary:
		NREid.effect_completed(state, null, enc["eid"])


static func set_phase(state: NRState, phase: String) -> String:
	state.assoc_in(["run", "phase"], phase)
	state.dissoc_in(["run", "next-phase"])
	state.assoc_in(["run", "no-action"], false)
	return phase


static func set_next_phase(state: NRState, phase: String) -> String:
	state.assoc_in(["run", "next-phase"], phase)
	return phase


static func make_run(state: NRState, side: Variant, eid: Dictionary, server: Variant, card: Variant = null, args: Dictionary = {}) -> void:
	var cost_args = NRUtil.merge(args, {"server": NRServers.unknown_to_kw(server)})
	var costs = total_run_cost(state, side, card, cost_args)
	var c = NRCard.get_card(state, card) if card is Dictionary else card
	eid = eid.duplicate(true)
	eid["source-type"] = "make-run"
	if not NRFlags.can_run(state, "runner") or not can_run_server(state, server) or NRPayment.can_pay(state, "runner", eid, c, "a run", costs) == null:
		NREid.effect_completed(state, side, eid)
		return
	state.dissoc_in(["end-run", "ended"])
	if NRUtil.truthy(args.get("click-run", false)):
		state.assoc_in(["runner", "register", "made-click-run"], true)
		NRSay.play_sfx(state, side, "click-run")
	NREid.wait_for(state, eid, func(pe):
		NREngine.pay(state, "runner", pe, c, costs)
	, func(payment):
		if not (payment is Dictionary) or payment.get("msg") == null:
			NREid.effect_completed(state, side, eid)
			return
		var dest: Array
		if server is String or NRUtil.to_kw(server) in ["hq", "rd", "archives"] or str(server).begins_with("remote"):
			dest = [NRServers.unknown_to_kw(server)]
		else:
			var z = NRBoard.server_to_zone(state, server)
			dest = [z[z.size() - 1]]
		var ices: Array = state.get_in(["corp", "servers"] + dest + ["ices"], [])
		var n = ices.size()
		var pay_str = str(payment.get("msg", ""))
		if pay_str != "":
			NRSay.system_msg(state, "runner", "%s%s" % [NRPayment.build_spend_msg(pay_str, "make a run on", "makes a run on"), NRServers.zone_to_name(dest)])
		var run_id = NREid.make_eid(state)
		state.setv("per-run", null)
		state.setv("run", {
			"run-id": run_id,
			"server": dest,
			"position": n,
			"corp-auto-no-action": false,
			"phase": "initiation",
			"eid": eid,
			"current-ice": null,
			"events": [],
			"source-card": NRUtil.select_keys(c, ["code", "cid", "zone", "title", "side", "type"]) if c is Dictionary else {},
		})
		NRPrompts.show_run_prompts(state, "running on %s" % NRServers.zone_to_name(dest), c)
		var made: Array = state.get_in(["runner", "register", "made-run"], [])
		made.append(dest[0])
		state.assoc_in(["runner", "register", "made-run"], made)
		state.update_in(["stats", "runner", "runs", "started"], NRUtil.inc_n(1), 0)
		state.assoc_in(["run", "bad-publicity-available"], NRUtil.count_bad_pub(state))
		NREngine.queue_event(state, "run", {"server": dest, "position": n, "cost-args": cost_args})
		NREngine.end_of_phase_checkpoint(state, NREid.make_eid(state, eid), "end-of-initiation")
	)


static func start_next_phase(state: NRState, side: Variant, eid: Variant = null) -> void:
	var nextp = state.get_in(["run", "next-phase"])
	match str(nextp):
		"approach-ice":
			_start_approach_ice(state, side, eid)
		"encounter-ice":
			_start_encounter_ice(state, side, eid)
		"movement":
			_start_movement(state, side, eid)
		"success":
			_start_success(state, side, eid)
		_:
			pass


static func continue_run(state: NRState, side: Variant, _args: Variant = null) -> void:
	if get_current_encounter(state) != null:
		_continue_encounter(state, side)
		return
	var phase = str(state.get_in(["run", "phase"], ""))
	match phase:
		"initiation":
			_continue_initiation(state, side)
		"approach-ice":
			_continue_approach_ice(state, side)
		"movement":
			_continue_movement(state, side)
		_:
			pass


static func _continue_initiation(state: NRState, side: Variant) -> void:
	if not state.get_in(["run", "no-action"]):
		state.assoc_in(["run", "no-action"], side)
		if NRUtil.to_side(side) == "corp":
			NRSay.system_msg(state, side, "has no further action")
		return
	if int(state.get_in(["run", "position"], 0)) > 0:
		set_next_phase(state, "approach-ice")
		start_next_phase(state, side)
	else:
		set_next_phase(state, "movement")
		start_next_phase(state, side)


static func _start_approach_ice(state: NRState, side: Variant, eid: Variant) -> void:
	set_phase(state, "approach-ice")
	NRIce.set_current_ice(state)
	NRIce.reset_all_ice(state, side)
	state.assoc_in(["run", "approached-ice?"], true)
	var ice = NRIce.get_current_ice(state)
	NRSay.system_msg(state, "runner", "approaches %s" % NRToString.card_str(state, ice if ice is Dictionary else {}))
	if ice is Dictionary:
		var on_approach = NRCardDefs.card_def(ice).get("on-approach")
		if on_approach is Dictionary:
			NREngine.register_pending_event(state, "approach-ice", ice, on_approach)
		NREngine.queue_event(state, "approach-ice", {"ice": ice})
	var e: Dictionary = eid if eid is Dictionary else NREid.make_eid(state)
	NREngine.checkpoint(state, e)


static func _continue_approach_ice(state: NRState, side: Variant) -> void:
	if not state.get_in(["run", "no-action"]):
		state.assoc_in(["run", "no-action"], side)
		if NRUtil.to_side(side) == "corp":
			NRSay.system_msg(state, side, "has no further action")
		return
	var ice = NRIce.get_current_ice(state)
	if ice is Dictionary and NRCard.rezzed(ice):
		set_next_phase(state, "encounter-ice")
		start_next_phase(state, "runner")
	else:
		set_next_phase(state, "movement")
		start_next_phase(state, "runner")


static func encounter_ice(state: NRState, side: Variant, eid: Dictionary, ice: Dictionary) -> void:
	var encs: Array = state.getv("encounters", [])
	encs.append({"eid": eid, "ice": ice})
	state.setv("encounters", encs)
	NRSay.system_msg(state, "runner", "encounters %s" % NRToString.card_str(state, ice, {"visible": NRIce.active_ice(state, ice)}))
	var on_enc = NRCardDefs.card_def(ice).get("on-encounter")
	if on_enc is Dictionary:
		NREngine.register_pending_event(state, "encounter-ice", ice, on_enc)
	NREngine.queue_event(state, "encounter-ice", {"ice": ice})
	NREngine.checkpoint(state, NREid.make_eid(state))


static func _start_encounter_ice(state: NRState, side: Variant, _eid: Variant) -> void:
	set_phase(state, "encounter-ice")
	var ice = NRIce.get_current_ice(state)
	var e = NREid.make_eid(state)
	if ice is Dictionary:
		encounter_ice(state, side, e, ice)


static func _continue_encounter(state: NRState, side: Variant) -> void:
	var enc = get_current_encounter(state)
	if not (enc is Dictionary):
		return
	var no_action = enc.get("no-action")
	if (no_action != null and NRUtil.to_side(no_action) != NRUtil.to_side(side)) or NRUtil.truthy(enc.get("bypass")):
		encounter_ends(state, side, NREid.make_eid(state))
	else:
		update_current_encounter(state, "no-action", side)
		if NRUtil.to_side(side) == "runner":
			NRSay.system_msg(state, side, "has no further action")


static func encounter_ends(state: NRState, side: Variant, eid: Dictionary) -> void:
	var ice = NRIce.get_current_ice(state)
	update_current_encounter(state, "ending", true)
	var enc = get_current_encounter(state)
	if enc is Dictionary and NRUtil.truthy(enc.get("bypass")) and ice is Dictionary:
		NREngine.queue_event(state, "bypassed-ice", ice)
		NRSay.system_msg(state, "runner", "bypasses %s" % ice.get("title"))
	NREid.wait_for(state, eid, func(ne):
		NREngine.end_of_phase_checkpoint(state, ne, "end-of-encounter", {"ice": ice})
	, func(_r):
		NRSubtypes.update_all_subtypes(state)
		if check_for_empty_server(state):
			clear_encounter(state)
			handle_end_run(state, side, eid)
			return
		if NRUtil.truthy(state.get_in(["end-run", "ended"])) or state.getv("encounters", []).size() > 1 or state.getv("run") == null or NRUtil.truthy(state.get_in(["run", "successful"])):
			if ice is Dictionary:
				NRIce.reset_all_subs_bang(state, ice)
			clear_encounter(state)
			NREid.effect_completed(state, side, eid)
			return
		if state.get_in(["run", "next-phase"]) != null:
			clear_encounter(state)
			start_next_phase(state, side, eid)
			return
		if str(state.get_in(["run", "phase"])) == "encounter-ice":
			clear_encounter(state)
			set_next_phase(state, "movement")
			start_next_phase(state, side, eid)
			return
		if ice is Dictionary:
			NRIce.reset_all_subs_bang(state, ice)
		clear_encounter(state)
		NREid.effect_completed(state, side, eid)
	)


static func _start_movement(state: NRState, side: Variant, eid: Variant) -> void:
	var prev = str(state.get_in(["run", "phase"], ""))
	var pos: int = int(state.get_in(["run", "position"], 0))
	var ice = NRIce.get_current_ice(state)
	var pass_ice = prev in ["approach-ice", "encounter-ice"] and ice is Dictionary
	var new_pos = (pos - 1) if pass_ice else pos
	set_phase(state, "movement")
	if pass_ice:
		NRSay.system_msg(state, "runner", "passes %s" % NRToString.card_str(state, ice))
		NREngine.queue_event(state, "pass-ice", {"ice": ice, "all-subs-broken": NRIce.all_subs_broken(ice)})
	state.assoc_in(["run", "position"], new_pos)
	if new_pos == 0 or prev == "initiation":
		NREngine.queue_event(state, "pass-all-ice", {"ice": ice})
	var e: Dictionary = eid if eid is Dictionary else NREid.make_eid(state)
	NREngine.checkpoint(state, e)
	NRIce.reset_all_ice(state, side)
	if check_for_empty_server(state) or NRUtil.truthy(state.get_in(["end-run", "ended"])):
		handle_end_run(state, side, e)
	elif state.get_in(["run", "next-phase"]) != null:
		start_next_phase(state, side, e)


static func _continue_movement(state: NRState, side: Variant) -> void:
	if not state.get_in(["run", "no-action"]):
		state.assoc_in(["run", "no-action"], side)
		if NRUtil.to_side(side) == "runner":
			NRSay.system_msg(state, side, "will continue the run")
		return
	var e = NREid.make_eid(state)
	if check_for_empty_server(state) or NRUtil.truthy(state.get_in(["end-run", "ended"])):
		handle_end_run(state, side, e)
	elif int(state.get_in(["run", "position"], 0)) > 0:
		set_next_phase(state, "approach-ice")
		start_next_phase(state, side, e)
	else:
		approach_server(state, side, e)


static func approach_server(state: NRState, side: Variant, eid: Dictionary) -> void:
	NRIce.set_current_ice(state, null)
	NRSay.system_msg(state, "runner", "approaches %s" % NRServers.zone_to_name(state.get_in(["run", "server"])))
	NREngine.queue_event(state, "approach-server", null)
	NREid.wait_for(state, eid, func(ne):
		NREngine.checkpoint(state, ne)
	, func(_r):
		if check_for_empty_server(state) or NRUtil.truthy(state.get_in(["end-run", "ended"])):
			handle_end_run(state, side, eid)
		elif state.get_in(["run", "next-phase"]) != null:
			start_next_phase(state, side, eid)
		else:
			set_next_phase(state, "success")
			start_next_phase(state, side, eid)
	)


static func _start_success(state: NRState, side: Variant, _eid: Variant) -> void:
	set_phase(state, "success")
	if check_for_empty_server(state):
		handle_end_run(state, side, NREid.make_eid(state))
	else:
		successful_run(state, "runner")


static func successful_run(state: NRState, _side: Variant) -> void:
	state.assoc_in(["run", "successful"], true)
	NRSay.system_msg(state, "runner", "makes a successful run on %s" % NRServers.zone_to_name(state.get_in(["run", "server"])))
	NREngine.queue_event(state, "successful-run", {"server": state.get_in(["run", "server"])})
	var eid = NREid.make_eid(state)
	NREid.wait_for(state, eid, func(ne):
		NREngine.checkpoint(state, ne)
	, func(_r):
		if NRUtil.truthy(state.get_in(["run", "prevent-access"])):
			handle_end_run(state, "runner", eid)
		else:
			NREid.wait_for(state, eid, func(ne2):
				NRAccess.breach_server(state, "runner", ne2, state.get_in(["run", "server"]))
			, func(_r2):
				handle_end_run(state, "runner", eid)
			)
	)


static func check_for_empty_server(state: NRState) -> bool:
	var run = state.getv("run")
	if not (run is Dictionary):
		return false
	var server = NRUtil.first_of(run.get("server", []))
	if not NRServers.is_remote(server):
		return false
	return state.get_in(["corp", "servers", server, "content"], []).is_empty() and state.get_in(["corp", "servers", server, "ices"], []).is_empty()


static func jack_out(state: NRState, side: Variant, args: Variant = null) -> void:
	var eid = NREid.make_eid(state)
	if not (state.getv("run") is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	NRSay.system_msg(state, "runner", "jacks out")
	state.assoc_in(["run", "unsuccessful"], true)
	end_run(state, side, eid)


static func end_run(state: NRState, side: Variant, eid: Dictionary, _args: Dictionary = {}) -> void:
	state.assoc_in(["end-run", "ended"], true)
	handle_end_run(state, side, eid)


static func handle_end_run(state: NRState, side: Variant, eid: Dictionary) -> void:
	var run = state.getv("run")
	if not (run is Dictionary):
		NREid.effect_completed(state, side, eid)
		return
	var successful = NRUtil.truthy(run.get("successful", false))
	if not successful:
		NREngine.queue_event(state, "unsuccessful-run", {"server": run.get("server")})
	NREngine.queue_event(state, "run-ends", {"server": run.get("server"), "successful": successful})
	run_cleanup(state, "runner", eid)


static func run_cleanup(state: NRState, side: Variant, eid: Dictionary) -> void:
	var run = state.getv("run")
	var run_eid = run.get("eid") if run is Dictionary else null
	var run_credit: int = int(state.get_in(["runner", "run-credit"], 0))
	if run_credit > 0:
		NRGaining.lose(state, "runner", "credit", run_credit)
		state.assoc_in(["runner", "run-credit"], 0)
	NRPrompts.clear_run_prompts(state)
	state.setv("run", null)
	state.setv("encounters", [])
	state.setv("end-run", {})
	state.setv("per-run", null)
	NRFlags.clear_run_register(state)
	NRIce.reset_all_ice(state, side)
	if run_eid is Dictionary and run_eid.get("eid") != eid.get("eid"):
		NREid.effect_completed(state, side, run_eid)
	NREngine.checkpoint(state, eid)
	NREngine.resolve_durations(state, side, ["end-of-run", "end-of-next-run"])


static func redirect_run(state: NRState, side: Variant, server: Variant, phase: Variant = null) -> void:
	if not (state.getv("run") is Dictionary):
		return
	var dest_zone = NRBoard.server_to_zone(state, server)
	var dest = dest_zone[dest_zone.size() - 1]
	var num_ice: int = state.get_in(["corp", "servers", dest, "ices"], []).size()
	NRSay.play_sfx(state, side, "redirect")
	var run: Dictionary = state.getv("run")
	run["position"] = num_ice
	run["server"] = [dest]
	state.setv("run", run)
	if phase != null:
		set_next_phase(state, str(phase))
	NRIce.set_current_ice(state)


static func prevent_access(state: NRState) -> void:
	state.assoc_in(["run", "prevent-access"], true)


static func gain_run_credits(state: NRState, eid: Dictionary, n: int) -> void:
	state.update_in(["runner", "run-credit"], NRUtil.inc_n(n), 0)
	NRGaining.gain_credits(state, "runner", eid, n)


static func toggle_auto_no_action(state: NRState, _side: Variant, _args: Variant = null) -> void:
	var cur = NRUtil.truthy(state.get_in(["run", "corp-auto-no-action"], false))
	state.assoc_in(["run", "corp-auto-no-action"], not cur)


static func total_cards_accessed(state: NRState) -> int:
	return int(state.get_in(["run", "cards-accessed"], 0))
