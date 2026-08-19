class_name NRCardRT
extends RefCounted

## Shared helpers for translated card files (Jinteki.net Clojure macros / utils).


static func getv(m: Variant, key: Variant, default_value: Variant = null) -> Variant:
	if m == null:
		return default_value
	if m is Dictionary:
		if m.has(key):
			return m[key]
		var ks = str(key)
		if m.has(ks):
			return m[ks]
		if ks.begins_with(":"):
			ks = ks.substr(1)
			if m.has(ks):
				return m[ks]
		return default_value
	if m is Array:
		var i = int(key) if key is int or key is float else -1
		if i >= 0 and i < m.size():
			return m[i]
		return default_value
	return default_value


static func get_in(m: Variant, path: Array, default_value: Variant = null) -> Variant:
	var cur = m
	for k in path:
		cur = getv(cur, k, null)
		if cur == null:
			return default_value
	return cur


static func first_target(targets: Variant) -> Variant:
	if targets is Dictionary:
		if targets.has("value") and targets.has("uuid"):
			return targets["value"]
		return targets
	if targets is Array and targets.size() > 0:
		var t = targets[0]
		if t is Dictionary and t.has("uuid") and t.has("value"):
			return t["value"]
		return t
	return targets


static func ctx(targets: Variant) -> Dictionary:
	return NRUtil.ability_context(targets)


static func this_server(state: NRState, card: Variant) -> bool:
	if not (card is Dictionary):
		return false
	var z: Array = NRCard.get_zone(card)
	var run = state.getv("run")
	if not (run is Dictionary) or z.size() < 2:
		return false
	var server = run.get("server")
	if server is Array and not server.is_empty():
		return str(z[1]) == str(server[0])
	return str(z[1]) == str(server)


static func currently_encountering(state: NRState, card: Variant) -> bool:
	var enc = NRRuns.get_current_encounter(state)
	if not (enc is Dictionary):
		return false
	return NRUtil.same_card(enc.get("ice"), card)


static func seq_of(x: Variant) -> Variant:
	if x == null:
		return null
	if x is Array:
		return null if x.is_empty() else x
	if x is Dictionary:
		return null if x.is_empty() else x
	if x is String:
		return null if x == "" else x
	return x


static func empty_of(x: Variant) -> bool:
	return seq_of(x) == null


static func as_array(x: Variant) -> Array:
	if x == null:
		return []
	if x is Array:
		return x
	return [x]


static func count_of(x: Variant) -> int:
	if x == null:
		return 0
	if x is Array:
		return x.size()
	if x is Dictionary:
		return x.size()
	if x is String:
		return x.length()
	return 0


static func truthy(x: Variant) -> bool:
	if x == null or x == false:
		return false
	if x is Array:
		return not x.is_empty()
	if x is Dictionary:
		return not x.is_empty()
	if x is String:
		return x != ""
	if x is int or x is float:
		return x != 0
	return true


static func ice_strength_bonus(bonus: Variant, req_fn: Variant = null) -> Dictionary:
	var ab = {
		"type": "ice-strength",
		"req": func(state, side, eid, card, targets):
			var t = first_target(targets)
			if not NRUtil.same_card(card, t):
				return false
			if req_fn is Callable:
				return NRUtil.truthy(req_fn.call(state, side, eid, card, targets))
			return true,
		"value": bonus,
	}
	return ab


static func combine_abilities(ab_x: Dictionary, ab_y: Dictionary) -> Dictionary:
	return {
		"label": str(ab_x.get("label", "")) + ". " + str(ab_y.get("label", "")),
		"async": true,
		"effect": func(state, side, eid, card, targets):
			NREid.wait_for(state, eid, func(ne):
				NREngine.resolve_ability(state, side, ne, ab_x, card, targets)
			, func(_r):
				NREngine.resolve_ability(state, side, eid, ab_y, card, targets)
			),
	}


static func corp_rez_toast() -> Dictionary:
	return {
		"event": "runner-turn-ends",
		"effect": func(state, _side, _eid, _card, _t):
			NRToasts.toast(state, "corp", "Reminder: You have unrezzed cards with \"when turn begins\" abilities.", "info"),
	}


static func filter_list(xs: Variant, pred: Callable) -> Array:
	var out: Array = []
	for x in as_array(xs):
		if NRUtil.truthy(pred.call(x)):
			out.append(x)
	return out


static func map_list(xs: Variant, fn: Callable) -> Array:
	var out: Array = []
	for x in as_array(xs):
		out.append(fn.call(x))
	return out


static func some_list(xs: Variant, pred: Callable) -> Variant:
	for x in as_array(xs):
		if NRUtil.truthy(pred.call(x)):
			return x
	return null


static func every_list(xs: Variant, pred: Callable) -> bool:
	var arr = as_array(xs)
	if arr.is_empty():
		return true
	for x in arr:
		if not NRUtil.truthy(pred.call(x)):
			return false
	return true


static func take_n(xs: Variant, n: int) -> Array:
	var arr = as_array(xs)
	if n < 0:
		n = 0
	return arr.slice(0, mini(n, arr.size()))


static func drop_n(xs: Variant, n: int) -> Array:
	var arr = as_array(xs)
	if n <= 0:
		return arr
	if n >= arr.size():
		return []
	return arr.slice(n, arr.size())


static func repeat_n(x: Variant, n: int) -> Array:
	var out: Array = []
	for i in range(maxi(0, n)):
		out.append(x)
	return out


static func distinct_list(xs: Variant) -> Array:
	var out: Array = []
	for x in as_array(xs):
		if not out.has(x):
			out.append(x)
	return out


static func concat_lists(parts: Array) -> Array:
	var out: Array = []
	for p in parts:
		out.append_array(as_array(p))
	return out


static func kw(v: Variant) -> String:
	return NRUtil.to_kw(v)


static func side_kw(v: Variant) -> String:
	var s = NRUtil.to_side(v)
	return s if s != "" else kw(v)


static func decapitalize(s: Variant) -> String:
	var t = str(s)
	if t == "":
		return t
	return t.substr(0, 1).to_lower() + t.substr(1)


static func quantify(n: int, word: String) -> String:
	if n == 1:
		return "1 %s" % word
	return "%d %ss" % [n, word]


static func enumerate_cards(cards: Variant) -> String:
	var titles: Array = []
	for c in as_array(cards):
		if c is Dictionary:
			titles.append(str(c.get("title", "a card")))
		else:
			titles.append(str(c))
	return ", ".join(titles)


static func pos(n: Variant) -> bool:
	return n != null and float(n) > 0


static func neg(n: Variant) -> bool:
	return n != null and float(n) < 0


static func zero(n: Variant) -> bool:
	return n != null and float(n) == 0


static func other_side(side: Variant) -> String:
	return NRUtil.other_side(side)


static func get_x_fn() -> Callable:
	return func(state, side, eid, card, _t):
		return int(NRPayment.x_cost_value(eid))


static func get_autoresolve(card: Dictionary, key: String = "auto") -> Callable:
	return func(state, side, eid, c, t):
		var special = c.get("special", {}) if c is Dictionary else {}
		return str(special.get(key, "unset"))


static func set_autoresolve(key: String, label: String) -> Dictionary:
	return {
		"label": "Toggle autoresolve (%s)" % label,
		"effect": func(state, side, eid, card, _t):
			var c = NRCard.get_card(state, card)
			if not (c is Dictionary):
				NREid.effect_completed(state, side, eid)
				return
			var special: Dictionary = c.get("special", {}) if c.get("special") is Dictionary else {}
			var cur = str(special.get(key, "unset"))
			var nxt = "Yes" if cur != "Yes" else "No"
			special[key] = nxt
			c = c.duplicate(true)
			c["special"] = special
			NRUpdate.update_card(state, side, c)
			NRSay.system_msg(state, side, "sets autoresolve on %s to %s" % [c.get("title"), nxt])
			NREid.effect_completed(state, side, eid),
	}


static func cost_option(cost: Variant, _side: Variant = null) -> Dictionary:
	return {
		"option": NRPayment.build_cost_string(cost) if cost != null else "Pay",
		"cost": cost,
		"ability": {
			"async": true,
			"effect": func(state, side, eid, card, _t):
				NREngine.pay(state, side, eid, card, cost),
		},
	}


static func choose_one_helper(args = null, xs = null) -> Dictionary:
	if xs == null:
		xs = args
		args = {}
	if not (args is Dictionary):
		args = {}
	if not (xs is Array):
		xs = []
	var prompt = str(args.get("prompt", "Choose one"))
	var player = args.get("player")
	var choices: Array = []
	var map: Dictionary = {}
	for x in xs:
		if x is String:
			choices.append(x)
			map[x] = {"async": true, "effect": func(s, sd, e, _c, _t): NREid.effect_completed(s, sd, e)}
		elif x is Dictionary:
			var lab = str(x.get("option", x.get("label", "Choice")))
			if x.get("cost") != null:
				var cs = NRPayment.build_cost_string(x.get("cost"))
				if cs != "":
					lab = cs + ": " + lab
			choices.append(lab)
			var ab: Dictionary = x.get("ability", x)
			if x.get("cost") != null and ab is Dictionary:
				ab = ab.duplicate(true)
				ab["cost"] = x.get("cost")
			map[lab] = ab
	var extra: Dictionary = {}
	if player != null:
		extra["player"] = player
	return NRUtil.merge({
		"async": true,
		"prompt": prompt,
		"waiting-prompt": args.get("no-wait-msg") != true,
		"choices": choices,
		"effect": func(state, side, eid, card, targets):
			var picked = first_target(targets)
			var lab = str(picked.get("value") if picked is Dictionary else picked)
			var ab = map.get(lab, {})
			if ab is Dictionary and not ab.is_empty():
				NREngine.resolve_ability(state, side, eid, ab, card, targets)
			else:
				NREid.effect_completed(state, side, eid),
	}, extra)
