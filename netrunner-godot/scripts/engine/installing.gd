class_name NRInstalling
extends RefCounted
## Corp and Runner install. Port of game.core.installing.

static func install_locked(state: NRState, side: Variant) -> bool:
	var kw := "%s-lock-install" % NRUtil.to_side(side)
	return not state.get_in(["stack", "current-run", kw], []).is_empty() or not state.get_in(["stack", "current-turn", kw], []).is_empty() or not state.get_in(["stack", "persistent", kw], []).is_empty()


static func corp_can_install(state: NRState, side: Variant, card: Dictionary, slot: Array, args: Dictionary = {}) -> bool:
	if NRCard.ice(card) and not NRFlags.turn_flag(state, side, card, "can-install-ice"):
		if not bool(args.get("no-toast", false)):
			NRToasts.toast(state, side, "Unable to install %s: can only install 1 piece of ice per turn" % card.get("title"))
		return false
	if install_locked(state, "corp"):
		if not bool(args.get("no-toast", false)):
			NRToasts.toast(state, side, "Unable to install %s, installing is currently locked" % card.get("title"))
		return false
	return true


static func corp_install_cost(state: NRState, side: Variant, card: Dictionary, server: Variant, args: Dictionary = {}) -> Array:
	var base: Array = args.get("base-cost", [])
	if base == null:
		base = []
	var ignore_ice := bool(args.get("ignore-ice-cost", false))
	var costs: Array = NRUtil.as_array(base)
	if NRCard.ice(card) and not ignore_ice:
		var dest := NRBoard.server_to_zone(state, server)
		var ices: Array = state.get_in(["corp"] + dest + ["ices"], [])
		costs.append(NRPayment.to_c("credit", ices.size()))
	if not bool(args.get("ignore-install-cost", false)):
		var ic := NRCostFns.install_cost(state, side, card, args)
		if ic > 0:
			costs.append(NRPayment.to_c("credit", ic))
	costs.append_array(NRCostFns.install_additional_cost_bonus(state, side, card))
	return NRPayment.merge_costs(costs)


static func corp_can_pay_and_install(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, server: Variant, args: Dictionary = {}) -> bool:
	if not corp_can_install(state, side, card, NRBoard.server_to_zone(state, server), args):
		return false
	var costs := corp_install_cost(state, side, card, server, args)
	return NRPayment.can_pay(state, side, eid, card, card.get("title"), costs) != null


static func corp_install(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, server: Variant, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		c = card
	if server == null:
		var servers := NRBoard.installable_servers(state, c)
		NREngine.resolve_ability(state, side, eid, {
			"prompt": "Choose a server to install %s" % c.get("title"),
			"choices": servers,
			"async": true,
			"effect": func(st, sd, e, _card, targets):
				var sv = targets[0].get("value") if targets is Array and targets[0] is Dictionary else (targets[0] if targets is Array else server)
				corp_install(st, sd, e, c, sv, args)
			,
		}, c, null)
		return
	var costs := corp_install_cost(state, side, c, server, args)
	if not corp_can_pay_and_install(state, side, eid, c, server, args):
		NREid.effect_completed(state, side, eid)
		return
	NREid.wait_for(state, eid, func(pe):
		NREngine.pay(state, side, pe, c, costs)
	, func(payment):
		if not (payment is Dictionary) or payment.get("cost-paid") == null:
			NREid.effect_completed(state, side, eid)
			return
		var dest := NRBoard.server_to_zone(state, server)
		if str(server) == "New remote":
			var rid := state.make_rid()
			dest = ["servers", "remote%d" % rid]
			state.assoc_in(["corp"] + dest, {"content": [], "ices": []})
		var slot := "ices" if NRCard.ice(c) else "content"
		var dest_zone: Array = dest + [slot]
		# trash previous asset/agenda if needed
		if (NRCard.asset(c) or NRCard.agenda(c)) and slot == "content":
			for prev in state.get_in(["corp"] + dest_zone, []):
				if prev is Dictionary and (NRCard.asset(prev) or NRCard.agenda(prev)):
					NRMoving.trash(state, "corp", NREid.make_eid(state), prev, {"keep-server-alive": true, "suppress-checkpoint": true, "unpreventable": true})
		var moved = NRMoving.move(state, "corp", c, dest_zone)
		if moved is Dictionary:
			moved["installed"] = "this-turn"
			NRUpdate.update_card(state, "corp", moved)
			if NRCard.agenda(moved):
				NRAgendas.update_advancement_requirement(state, moved)
		var cost_str := str(payment.get("msg", ""))
		var name := moved.get("title") if moved is Dictionary and (NRCard.ice(moved) == false or bool(args.get("known"))) else ("ice" if NRCard.ice(c) else "a card")
		if NRCard.ice(c):
			NRSay.system_msg(state, "corp", "%sinstall ice protecting %s" % [NRPayment.build_spend_msg(cost_str, "install"), NRServers.zone_to_name(dest)])
		else:
			NRSay.system_msg(state, "corp", "%sinstall a card in the root of %s" % [NRPayment.build_spend_msg(cost_str, "install"), NRServers.zone_to_name(dest)])
		NREngine.queue_event(state, "corp-install", {"card": moved, "server": dest})
		var install_state = args.get("install-state")
		if NRUtil.kw_eq(install_state, "rezzed") or NRUtil.kw_eq(install_state, "rezzed-no-cost"):
			NRRezzing.rez(state, "corp", eid, moved, {"ignore-cost": NRUtil.kw_eq(install_state, "rezzed-no-cost")})
		else:
			if not bool(args.get("suppress-checkpoint", false)):
				NREngine.checkpoint(state, eid)
			else:
				NREid.complete_with_result(state, side, eid, moved)
	)


static func runner_can_install(state: NRState, _side: Variant, card: Dictionary, args: Dictionary = {}) -> bool:
	if install_locked(state, "runner"):
		if not bool(args.get("no-toast", false)):
			NRToasts.toast(state, "runner", "Unable to install %s, installing is currently locked" % card.get("title"))
		return false
	if NRCard.program(card) and not NRMemory.sufficient_mu(state, card) and not bool(args.get("ignore-mu", false)):
		if not bool(args.get("no-toast", false)):
			NRToasts.toast(state, "runner", "Insufficient MU to install %s" % card.get("title"))
		return false
	return true


static func runner_install_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Array:
	var base: Array = NRUtil.as_array(args.get("base-cost", []))
	if not bool(args.get("ignore-install-cost", false)) and not NRCostFns.ignore_install_cost(state, side, card):
		base.append(NRPayment.to_c("credit", NRCostFns.install_cost(state, side, card, args)))
	base.append_array(NRCostFns.install_additional_cost_bonus(state, side, card))
	return NRPayment.merge_costs(base)


static func runner_can_pay_and_install(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> bool:
	if not runner_can_install(state, side, card, args):
		return false
	return NRPayment.can_pay(state, side, eid, card, card.get("title"), runner_install_cost(state, side, card, args)) != null


static func runner_install(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, args: Dictionary = {}) -> void:
	var c = NRCard.get_card(state, card)
	if not (c is Dictionary):
		c = card
	if not runner_can_pay_and_install(state, side, eid, c, args):
		NREid.effect_completed(state, side, eid)
		return
	var costs := runner_install_cost(state, side, c, args)
	NREid.wait_for(state, eid, func(pe):
		NREngine.pay(state, side, pe, c, costs)
	, func(payment):
		if not (payment is Dictionary) or payment.get("cost-paid") == null:
			NREid.effect_completed(state, side, eid)
			return
		var dest := ["rig", "facedown"] if bool(args.get("facedown", false)) else NRServers.type_to_rig_zone(str(c.get("type")))
		var moved = NRMoving.move(state, "runner", c, dest, args)
		if moved is Dictionary:
			NRInitializing.card_init(state, "runner", moved, {"resolve-effect": true, "init-data": true, "no-mu": bool(args.get("no-mu", false))})
		var cost_str := str(payment.get("msg", ""))
		NRSay.system_msg(state, "runner", "%s%s" % [NRPayment.build_spend_msg(cost_str, "install"), NRCard.get_title(moved if moved is Dictionary else c)])
		NREngine.queue_event(state, "runner-install", {"card": moved})
		if not bool(args.get("suppress-checkpoint", false)):
			NREngine.checkpoint(state, eid)
		else:
			NREid.complete_with_result(state, side, eid, moved)
	)


static func corp_install_msg(card: Dictionary) -> String:
	return "install %s from %s" % [("an unseen card" if not bool(card.get("seen")) else card.get("title")), NRServers.name_zone("corp", card.get("zone"))]
