class_name NRPayment
extends RefCounted
## Cost vectors, merging, and can-pay?. Port of game.core.payment.
## Cost maps use keys: cost/type, cost/amount, cost/additional, cost/stealth, cost/maximum, cost/offset, cost/args.

static func to_c(typ: Variant, n: int = 1, args: Dictionary = {}) -> Dictionary:
	return {
		"cost/type": NRUtil.to_kw(typ),
		"cost/amount": n,
		"cost/additional": NRUtil.truthy(args.get("additional", false)),
		"cost/stealth": args.get("stealth"),
		"cost/maximum": args.get("maximum"),
		"cost/offset": args.get("offset"),
		"cost/args": _cost_args(args),
	}


static func _cost_args(args: Dictionary) -> Variant:
	var out = args.duplicate()
	for k in ["stealth", "additional", "maximum", "offset"]:
		out.erase(k)
	return out if not out.is_empty() else null


static func group_costs(costs: Array) -> Array:
	var groups = {}
	var order: Array = []
	var x_idx = 0
	for c in costs:
		if not (c is Dictionary):
			continue
		var t: String = str(c.get("cost/type"))
		var key = t
		if t == "x-credits":
			key = "x-credits-%d" % x_idx
			x_idx += 1
		if not groups.has(key):
			groups[key] = []
			order.append(key)
		groups[key].append(c)
	var out: Array = []
	for k in order:
		out.append(groups[k])
	return out


static func merge_cost_impl(acc: Variant, cur: Dictionary) -> Dictionary:
	if acc == null:
		return cur
	var acc_stealth = acc.get("cost/stealth")
	var cur_stealth = cur.get("cost/stealth")
	var stealth = null
	if NRUtil.kw_eq(acc_stealth, "all-stealth") or NRUtil.kw_eq(cur_stealth, "all-stealth"):
		stealth = "all-stealth"
	elif acc_stealth != null or cur_stealth != null:
		stealth = int(acc_stealth if acc_stealth != null else 0) + int(cur_stealth if cur_stealth != null else 0)
	return to_c(cur.get("cost/type"), int(acc.get("cost/amount", 0)) + int(cur.get("cost/amount", 0)), {
		"additional": cur.get("cost/additional"),
		"maximum": cur.get("cost/maximum"),
		"offset": cur.get("cost/offset"),
		"stealth": stealth,
	})


static func impl_cost_ranks(cost: Dictionary) -> int:
	match str(cost.get("cost/type")):
		"click":
			return 1
		"lose-click":
			return 2
		"credit":
			return 3
		"advancement", "power", "virus":
			return 4
		"trash-can", "remove-from-game":
			return 5
		_:
			return 6


static func display_cost_ranks(cost: Dictionary) -> int:
	match str(cost.get("cost/type")):
		"click":
			return 1
		"lose-click":
			return 2
		"credit":
			return 3
		"trash-can", "remove-from-game":
			return 4
		_:
			return 5


static func merge_costs(costs: Variant, remove_zero_credit: bool = false) -> Array:
	var flat: Array = []
	for c in NRUtil.flatten(costs):
		if c != null:
			flat.append(c)
	var real: Array = []
	var additional: Array = []
	for c in flat:
		if c is Dictionary and NRUtil.truthy(c.get("cost/additional", false)):
			additional.append(c)
		elif c is Dictionary:
			real.append(c)
	var merged: Array = []
	for group in group_costs(real) + group_costs(additional):
		var acc = null
		for cur in group:
			acc = merge_cost_impl(acc, cur)
		if acc != null:
			if remove_zero_credit and str(acc.get("cost/type")) == "credit" and int(acc.get("cost/amount", 0)) == 0:
				continue
			merged.append(acc)
	merged.sort_custom(func(a, b): return impl_cost_ranks(a) < impl_cost_ranks(b))
	return merged


static func any_effect_stops_pay(state: NRState, side: Variant, cost: Dictionary) -> bool:
	var kw = "cannot-pay-%s" % str(cost.get("cost/type"))
	return NREffects.any_effects(state, side, kw, func(v): return v == true, null, [{"amount": cost.get("cost/amount")}])


static func can_pay(state: NRState, side: Variant, eid: Dictionary, card: Variant, title: Variant, args: Variant) -> Variant:
	var costs_in: Array = []
	if title is String:
		costs_in = NRUtil.as_array(args)
	else:
		costs_in = NRUtil.flatten([title, args])
		title = null
	var remove_zero = NRUtil.kw_eq(eid.get("source-type"), "corp-install") and card is Dictionary and not NRCard.ice(card)
	var costs = merge_costs(NRUtil.filter_some(costs_in), remove_zero)
	for c in costs:
		if any_effect_stops_pay(state, side, c):
			if title:
				NRToasts.toast(state, side, "Unable to pay for %s." % str(title))
			return null
		if not NRCosts.payable(c, state, side, eid, card):
			if title:
				NRToasts.toast(state, side, "Unable to pay for %s." % str(title))
			return null
	return costs


static func has_enough(state: NRState, side: Variant, eid: Dictionary, card: Variant, costs: Variant) -> bool:
	return can_pay(state, side, eid, card, null, costs) != null


static func cost_targets(eid: Dictionary, cost_type: String) -> Variant:
	return NRUtil.get_in(eid, ["cost-paid", cost_type, "paid/targets"])


static func cost_target(eid: Dictionary, cost_type: String) -> Variant:
	var t = cost_targets(eid, cost_type)
	return NRUtil.first_of(t) if t is Array else t


static func cost_value(eid: Dictionary, cost_type: String) -> int:
	return int(NRUtil.get_in(eid, ["cost-paid", cost_type, "paid/value"], 0))


static func x_cost_value(eid: Dictionary) -> int:
	return int(NRUtil.get_in(eid, ["cost-paid", "x-credits", "paid/x-value"], 0))


static func build_cost_label(costs: Variant) -> String:
	var merged = merge_costs(costs)
	merged.sort_custom(func(a, b): return display_cost_ranks(a) < display_cost_ranks(b))
	var labels: Array = []
	for c in merged:
		labels.append(NRCosts.label(c))
	var s = ", ".join(labels)
	if s == "":
		return ""
	return s.substr(0, 1).to_upper() + s.substr(1)


static func add_cost_label_to_ability(ability: Dictionary, cost: Variant = null) -> Dictionary:
	var c = cost if cost != null else ability.get("cost")
	if ability.has("fake-cost"):
		c = merge_costs([c, ability["fake-cost"]])
	var ab = ability.duplicate(true)
	ab["cost-label"] = build_cost_label(c)
	return ab


static func cost_to_string(cost: Dictionary) -> String:
	if int(NRCosts.value(cost)) < 0:
		return ""
	var t = str(cost.get("cost/type"))
	var lab = NRCosts.label(cost)
	if t in ["click", "lose-click"]:
		return "spend " + lab
	if t == "credit":
		return "pay " + lab
	return lab


static func build_cost_string(costs: Variant) -> String:
	var parts: Array = []
	for c in merge_costs(costs):
		var s = cost_to_string(c)
		if s != "":
			parts.append(s)
	var joined = " and ".join(parts)
	if joined == "":
		return ""
	return joined.substr(0, 1).to_upper() + joined.substr(1)


static func build_spend_msg(cost_str: String, verb: String, verb2: Variant = null) -> String:
	if cost_str.strip_edges() == "":
		return str(verb2) + " " if verb2 != null else (verb + "s ")
	return "%s to %s " % [cost_str, verb]
