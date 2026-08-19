class_name NRBoard
extends RefCounted
## Installed-card enumeration and server lists. Port of game.core.board.

static func _hosted_walk(cards: Array, pred: Callable) -> Array:
	var installed: Array = []
	var unchecked: Array = cards.duplicate()
	while not unchecked.is_empty():
		var card = unchecked.pop_front()
		if card is Dictionary:
			if pred.call(card):
				installed.append(card)
			for h in card.get("hosted", []):
				unchecked.append(h)
	return installed


static func corp_servers_cards(state: NRState) -> Array:
	var out: Array = []
	var servers: Dictionary = state.get_in(["corp", "servers"], {})
	for sk in servers:
		var srv = servers[sk]
		if srv is Dictionary:
			out.append_array(srv.get("content", []))
			out.append_array(srv.get("ices", []))
	return out


static func runner_rig_cards(state: NRState) -> Array:
	var out: Array = []
	var rig: Dictionary = state.get_in(["runner", "rig"], {})
	for rowk in rig:
		out.append_array(rig[rowk] if rig[rowk] is Array else [])
	return out


static func get_all_cards(state: NRState) -> Array:
	var installed_corp = corp_servers_cards(state)
	var installed_runner = runner_rig_cards(state)
	var zone_cards: Array = []
	for side in ["corp", "runner"]:
		for zone in ["deck", "hand", "discard", "current", "scored", "play-area", "rfg", "set-aside"]:
			zone_cards.append_array(state.get_in([side, zone], []))
	var identities: Array = [state.get_in(["corp", "identity"]), state.get_in(["runner", "identity"])]
	return _hosted_walk(installed_corp + installed_runner + zone_cards + identities, func(c): return c != null)


static func all_installed_runner(state: NRState) -> Array:
	var hosted_on_corp: Array = []
	for c in corp_servers_cards(state):
		if c is Dictionary:
			hosted_on_corp.append_array(c.get("hosted", []))
	return _hosted_walk(runner_rig_cards(state) + hosted_on_corp, func(c):
		return c is Dictionary and NRCard.runner(c) and NRCard.installed(c)
	)


static func all_installed_corp(state: NRState) -> Array:
	var hosted_on_runner: Array = []
	for c in runner_rig_cards(state):
		if c is Dictionary:
			hosted_on_runner.append_array(c.get("hosted", []))
	return _hosted_walk(corp_servers_cards(state) + hosted_on_runner, func(c):
		return c is Dictionary and NRCard.corp(c) and NRCard.installed(c)
	)


static func all_installed(state: NRState, side: Variant) -> Array:
	return all_installed_runner(state) if NRUtil.to_side(side) == "runner" else all_installed_corp(state)


static func all_installed_and_scored(state: NRState, side: Variant) -> Array:
	return all_installed(state, side) + state.get_in([NRUtil.to_side(side), "scored"], [])


static func get_all_installed(state: NRState) -> Array:
	return _hosted_walk(runner_rig_cards(state) + corp_servers_cards(state), func(c):
		return c is Dictionary and NRCard.installed(c)
	)


static func all_installed_runner_type(state: NRState, card_type: String) -> Array:
	var out: Array = []
	for c in all_installed(state, "runner"):
		if NRCard.is_type(c, card_type) and not NRCard.facedown(c):
			out.append(c)
	return out


static func all_active_installed(state: NRState, side: Variant) -> Array:
	var installed = all_installed(state, side)
	if NRUtil.to_side(side) == "runner":
		var out: Array = []
		for c in installed:
			if not NRCard.facedown(c):
				out.append(c)
		return out
	var out2: Array = []
	for c in installed:
		if NRCard.rezzed(c):
			out2.append(c)
	return out2


static func all_active(state: NRState, side: Variant) -> Array:
	var s = NRUtil.to_side(side)
	var cards: Array = [state.get_in([s, "identity"])]
	cards.append_array(all_active_installed(state, s))
	cards.append_array(state.get_in([s, "current"], []))
	for c in state.get_in([s, "play-area"], []):
		if c is Dictionary and ((s == "corp" and NRCard.operation(c)) or (s == "runner" and NRCard.event(c))):
			cards.append(c)
	if s == "corp":
		cards.append_array(state.get_in(["corp", "scored"], []))
	var out: Array = []
	for c in cards:
		if c is Dictionary and not NRUtil.truthy(c.get("disabled", false)):
			out.append(c)
	return out


static func installed_byname(state: NRState, side: Variant, title: String) -> Variant:
	for c in all_active_installed(state, side):
		if str(c.get("title")) == title:
			return c
	return null


static func in_play(state: NRState, card: Dictionary) -> Variant:
	return installed_byname(state, NRUtil.to_side(card.get("side")), str(card.get("title")))


static func get_zones(state: NRState) -> Array:
	var servers: Dictionary = state.get_in(["corp", "servers"], {})
	return servers.keys()


static func get_remote_zones(state: NRState) -> Array:
	var out: Array = []
	for z in get_zones(state):
		if NRServers.is_remote(z):
			out.append(z)
	return out


static func get_remotes(state: NRState) -> Dictionary:
	var alls: Dictionary = state.get_in(["corp", "servers"], {})
	var out = {}
	for z in get_remote_zones(state):
		if alls.has(z):
			out[z] = alls[z]
	return out


static func get_remote_names(state: NRState) -> Array:
	return NRServers.zones_to_sorted_names(get_remote_zones(state))


static func server_list(state: NRState) -> Array:
	return NRServers.zones_to_sorted_names(get_zones(state))


static func server_list_exclude(state: NRState, exclude_list: Array) -> Array:
	var zs: Array = []
	for z in get_zones(state):
		if not (z in exclude_list):
			zs.append(z)
	return NRServers.zones_to_sorted_names(zs)


static func installable_servers(state: NRState, card: Dictionary) -> Array:
	var max_servers = null
	var id: Dictionary = state.get_in(["corp", "identity"], {})
	var cdef = NRCardDefs.card_def(id)
	if cdef.has("flags") and cdef["flags"] is Dictionary:
		max_servers = cdef["flags"].get("server-limit")
	var at_remote_limit = max_servers != null and get_remotes(state).size() >= int(max_servers)
	var hosts: Array = []
	for c in all_installed(state, "corp"):
		var hdef = NRCardDefs.card_def(c)
		if hdef.has("can-host") and NRCard.rezzed(c) and NRUtil.is_fn(hdef["can-host"]):
			if hdef["can-host"].call(state, "corp", NREid.make_eid(state), c, [card]):
				hosts.append(c)
	var base_list: Array = hosts + server_list(state)
	if not at_remote_limit:
		base_list.append("New remote")
	var install_req = cdef.get("install-req", NRCardDefs.card_def(card).get("install-req", NRCardDefs.card_def(card).get("legal-zones")))
	if NRUtil.is_fn(install_req):
		return install_req.call(state, "corp", card, NREid.make_eid(state), base_list)
	if NRCard.agenda(card) or NRCard.asset(card):
		var filtered: Array = []
		for s in base_list:
			if not (s in ["HQ", "R&D", "Archives"]):
				filtered.append(s)
		return filtered
	return base_list


static func server_to_zone(state: NRState, server: Variant) -> Array:
	if server is Array:
		return ["servers"] + server
	if server is Dictionary and server.has("cid"):
		return ["onhost"]
	match str(server):
		"HQ":
			return ["servers", "hq"]
		"R&D":
			return ["servers", "rd"]
		"Archives":
			return ["servers", "archives"]
		"New remote":
			var rid: int = int(state.getv("rid", 1))
			return ["servers", "remote%d" % rid]
		_:
			var parts = str(server).split(" ")
			return ["servers", "remote" + str(parts[parts.size() - 1])]


static func card_to_server(state: NRState, card: Dictionary) -> Variant:
	var z: Array = NRUtil.zone_as_array(card.get("zone", []))
	if z.size() < 2:
		return null
	return state.get_in(["corp", "servers", z[1]])


static func clear_empty_remotes(state: NRState) -> void:
	for remote in get_remotes(state):
		var zone = ["corp", "servers", remote]
		var content: Array = state.get_in(zone + ["content"], [])
		var ices: Array = state.get_in(zone + ["ices"], [])
		if content.is_empty() and ices.is_empty():
			var servers: Dictionary = state.get_in(["corp", "servers"], {})
			servers.erase(remote)
			state.assoc_in(["corp", "servers"], servers)
