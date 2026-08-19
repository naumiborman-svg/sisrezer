class_name NRCard
extends RefCounted
## Card predicates and accessors. Port of game.core.card.

static func get_cid(card: Dictionary) -> Variant:
	return NRUtil.get_in(card, ["card", "cid"], card.get("cid"))


static func get_title(card: Dictionary) -> String:
	return str(card.get("title", card.get("printed-title", "")))


static func get_nested_host(card: Dictionary) -> Dictionary:
	var cur := card
	while cur is Dictionary and cur.get("host") is Dictionary:
		cur = cur["host"]
	return cur


static func get_zone(card: Dictionary) -> Array:
	return NRUtil.zone_as_array(get_nested_host(card).get("zone", []))


static func zone_eq(zone: Array, expected: Array) -> bool:
	if zone.size() != expected.size():
		return false
	for i in range(zone.size()):
		if NRUtil.to_kw(zone[i]) != NRUtil.to_kw(expected[i]):
			return false
	return true


static func in_server(card: Dictionary) -> bool:
	var z := get_zone(card)
	return not z.is_empty() and NRUtil.to_kw(z[z.size() - 1]) == "content"


static func in_hand(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["hand"])


static func in_discard(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["discard"])


static func in_deck(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["deck"])


static func in_archives_root(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["servers", "archives", "content"])


static func in_hq_root(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["servers", "hq", "content"])


static func in_rd_root(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["servers", "rd", "content"])


static func in_root(card: Dictionary) -> bool:
	return in_archives_root(card) or in_hq_root(card) or in_rd_root(card)


static func protecting_archives(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["servers", "archives", "ices"])


static func protecting_hq(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["servers", "hq", "ices"])


static func protecting_rd(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["servers", "rd", "ices"])


static func protecting_a_central(card: Dictionary) -> bool:
	return protecting_archives(card) or protecting_hq(card) or protecting_rd(card)


static func in_play_area(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["play-area"])


static func in_destroyed(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["destroyed"])


static func in_set_aside(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["set-aside"])


static func set_aside_visible(card: Dictionary, side: String) -> bool:
	if not in_set_aside(card):
		return false
	var vis = card.get("set-aside-visibility", {})
	if not (vis is Dictionary):
		return false
	if NRUtil.to_side(side) == "corp":
		return bool(vis.get("corp-can-see", false))
	return bool(vis.get("runner-can-see", false))


static func in_current(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["current"])


static func in_scored(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["scored"])


static func in_rfg(card: Dictionary) -> bool:
	return zone_eq(get_zone(card), ["rfg"])


static func card_is(card: Dictionary, property: String, value: Variant) -> bool:
	var cv = card.get(property)
	if cv == null:
		return false
	if cv is String and value is String:
		return str(cv).to_lower() == str(value).to_lower()
	return NRUtil.kw_eq(cv, value) or cv == value


static func runner(card: Dictionary) -> bool:
	return card_is(card, "side", "Runner")


static func corp(card: Dictionary) -> bool:
	return card_is(card, "side", "Corp")


static func is_type(card: Dictionary, typ: String) -> bool:
	return card_is(card, "type", typ)


static func agenda(card: Dictionary) -> bool:
	return is_type(card, "Agenda")


static func asset(card: Dictionary) -> bool:
	return is_type(card, "Asset")


static func event(card: Dictionary) -> bool:
	return not facedown(card) and is_type(card, "Event")


static func hardware(card: Dictionary) -> bool:
	return not facedown(card) and is_type(card, "Hardware")


static func ice(card: Dictionary) -> bool:
	return is_type(card, "ICE")


static func fake_identity(card: Dictionary) -> bool:
	return is_type(card, "Fake-Identity")


static func identity(card: Dictionary) -> bool:
	return is_type(card, "Identity") or fake_identity(card)


static func operation(card: Dictionary) -> bool:
	return is_type(card, "Operation")


static func program(card: Dictionary) -> bool:
	return not facedown(card) and is_type(card, "Program")


static func resource(card: Dictionary) -> bool:
	return not facedown(card) and is_type(card, "Resource")


static func upgrade(card: Dictionary) -> bool:
	return is_type(card, "Upgrade")


static func condition_counter(card: Dictionary) -> bool:
	return is_type(card, "Counter")


static func basic_action(card: Dictionary) -> bool:
	return is_type(card, "Basic Action")


static func has_subtype(card: Dictionary, subtype: String) -> bool:
	var subs = card.get("subtypes", [])
	if not (subs is Array):
		if card.get("subtype") is String:
			subs = str(card["subtype"]).split(" - ")
		else:
			return false
	for s in subs:
		if str(s).to_lower() == subtype.to_lower():
			return true
	return false


static func has_any_subtype(card: Dictionary, subtypes: Array) -> bool:
	for s in subtypes:
		if has_subtype(card, str(s)):
			return true
	return false


static func has_all_subtypes(card: Dictionary, subtypes: Array) -> bool:
	for s in subtypes:
		if not has_subtype(card, str(s)):
			return false
	return true


static func virus_program(card: Dictionary) -> bool:
	return program(card) and has_subtype(card, "Virus")


static func console(card: Dictionary) -> bool:
	return hardware(card) and has_subtype(card, "Console")


static func unique(card: Dictionary) -> bool:
	return bool(card.get("uniqueness", false))


static func corp_installable_type(card: Dictionary) -> bool:
	return asset(card) or agenda(card) or ice(card) or upgrade(card)


static func rezzed(card: Dictionary) -> bool:
	return bool(card.get("rezzed", false))


static func faceup(card: Dictionary) -> bool:
	return bool(card.get("seen", false)) or rezzed(card)


static func installed(card: Dictionary) -> bool:
	if card.get("installed"):
		return true
	var z := get_zone(card)
	return not z.is_empty() and NRUtil.to_kw(z[0]) == "servers"


static func facedown(card: Dictionary) -> bool:
	if not condition_counter(card) and zone_eq(get_zone(card), ["rig", "facedown"]):
		return true
	return bool(card.get("facedown", false))


static func active(card: Dictionary) -> bool:
	if basic_action(card):
		return true
	if identity(card) and not facedown(card):
		return true
	if in_play_area(card) or in_current(card) or in_scored(card) or condition_counter(card):
		return true
	if corp(card) and installed(card) and rezzed(card):
		return true
	if runner(card) and installed(card) and not facedown(card):
		return true
	return false


static func get_advancement_requirement(card: Dictionary) -> Variant:
	if not agenda(card):
		return null
	if card.has("current-advancement-requirement"):
		return card["current-advancement-requirement"]
	return card.get("advancementcost")


static func get_agenda_points(card: Dictionary) -> int:
	if card.has("current-points"):
		return int(card["current-points"])
	return int(card.get("agendapoints", 0))


static func can_be_advanced(card: Dictionary, state: NRState = null) -> bool:
	var ok := false
	if card_is(card, "advanceable", "always"):
		ok = true
	elif card_is(card, "advanceable", "while-rezzed") and rezzed(card):
		ok = true
	elif card_is(card, "advanceable", "while-unrezzed") and not rezzed(card):
		ok = true
	elif is_type(card, "Agenda") and installed(card):
		ok = true
	if not ok:
		return false
	if state != null and not agenda(card):
		var reg = state.getv("disabled-card-reg", {})
		if reg is Dictionary and reg.has(card.get("cid")):
			return false
	return true


static func get_counters(card: Dictionary, counter: Variant) -> int:
	if NRUtil.to_kw(counter) == "advancement":
		return int(card.get("advance-counter", 0)) + int(card.get("extra-advance-counter", 0))
	var c = card.get("counter", {})
	if c is Dictionary:
		return int(c.get(NRUtil.to_kw(counter), c.get(str(counter), 0)))
	return 0


static func get_card(state: NRState, card: Variant) -> Variant:
	if not (card is Dictionary):
		return null
	var c: Dictionary = card
	if is_type(c, "Identity"):
		return state.get_in([NRUtil.to_side(c.get("side")), "identity"])
	var cid = c.get("cid")
	if cid == null:
		return c
	if c.get("host") is Dictionary:
		return get_card_hosted(state, c)
	var zone: Array = NRUtil.zone_as_array(c.get("zone", []))
	if zone.is_empty():
		return c
	if NRUtil.to_kw(zone[0]) == "scored":
		for sc in state.get_in(["corp", "scored"], []) + state.get_in(["runner", "scored"], []):
			if sc is Dictionary and sc.get("cid") == cid:
				return sc
		return null
	var side := NRUtil.to_side(c.get("side"))
	var coll = state.get_in([side] + zone, [])
	if coll is Array:
		for item in coll:
			if item is Dictionary and item.get("cid") == cid:
				return item
	return get_corp_installed_card(state, c)


static func get_corp_installed_card(state: NRState, card: Dictionary) -> Variant:
	var zone: Array = NRUtil.zone_as_array(card.get("zone", []))
	if zone.is_empty():
		return null
	var lastz := NRUtil.to_kw(zone[zone.size() - 1])
	if lastz != "ices" and lastz != "content":
		return null
	var servers: Dictionary = state.get_in(["corp", "servers"], {})
	for sk in servers:
		var srv = servers[sk]
		if not (srv is Dictionary):
			continue
		for item in srv.get(lastz, []):
			if item is Dictionary and item.get("cid") == card.get("cid"):
				return item
	return null


static func get_card_hosted(state: NRState, card: Dictionary) -> Variant:
	var root: Dictionary = get_nested_host(card)
	var root_now = get_card(state, root)
	if root_now == null:
		root_now = get_corp_installed_card(state, root)
	if not (root_now is Dictionary):
		return null
	return _search_hosted(root_now, card)


static func _search_hosted(card: Dictionary, target: Dictionary) -> Variant:
	for h in card.get("hosted", []):
		if h is Dictionary:
			if NRUtil.same_card(h, target):
				return h
			var found = _search_hosted(h, target)
			if found != null:
				return found
	return null


static func card_index(state: NRState, card: Dictionary) -> Variant:
	if card.has("index"):
		return card["index"]
	var z := get_zone(card)
	var coll = state.get_in(["corp"] + z, [])
	if coll is Array:
		for i in range(coll.size()):
			if NRUtil.same_card(coll[i], card):
				return i
	return null


static func is_public(card: Dictionary, side: Variant = null) -> bool:
	if basic_action(card) or identity(card) or in_scored(card) or in_current(card) or in_play_area(card) or in_rfg(card) or in_destroyed(card):
		return true
	var s := NRUtil.to_side(side) if side != null else NRUtil.to_side(card.get("side"))
	if set_aside_visible(card, s):
		return true
	if s == "corp":
		if corp(card) and not in_set_aside(card):
			return true
		if (installed(card) or card.get("host")) and (faceup(card) or not facedown(card)):
			return true
		return in_discard(card)
	if runner(card) and not in_set_aside(card):
		return true
	if (installed(card) or card.get("host")) and (operation(card) or condition_counter(card) or faceup(card)):
		return true
	return in_discard(card) and faceup(card)


static func convert_to_agenda(card: Dictionary, n: int) -> Dictionary:
	return {
		"agendapoints": n,
		"cid": card.get("cid"),
		"code": card.get("code"),
		"host": card.get("host"),
		"hosted": card.get("hosted", []),
		"implementation": card.get("implementation"),
		"printed-title": card.get("title"),
		"side": card.get("side"),
		"type": "Agenda",
		"zone": card.get("zone"),
	}


static func convert_to_condition_counter(card: Dictionary) -> Dictionary:
	return {
		"cid": card.get("cid"),
		"code": card.get("code"),
		"implementation": card.get("implementation"),
		"printed-title": card.get("title"),
		"side": card.get("side"),
		"type": "Counter",
		"zone": card.get("zone"),
	}


static func keywords_list(card: Dictionary) -> Array:
	var kw = card.get("keywords", card.get("subtype", ""))
	if kw is Array:
		return kw
	if kw is String and kw != "":
		var parts: Array = []
		for p in kw.split(" - "):
			parts.append(str(p).strip_edges())
		return parts
	return card.get("subtypes", [])
