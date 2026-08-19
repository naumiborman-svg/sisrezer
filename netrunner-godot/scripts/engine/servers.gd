class_name NRServers
extends RefCounted
## Server / zone name helpers. Port of game.core.servers.

static func target_server(run: Dictionary) -> Variant:
	return NRUtil.first_of(run.get("server", []))


static func remote_num_to_name(num: Variant) -> String:
	return "Server %s" % str(num)


static func remote_to_name(zone: Variant) -> Variant:
	var kw := ""
	if zone is Array:
		kw = str(NRUtil.last_of(zone))
	else:
		kw = str(zone)
	kw = NRUtil.to_kw(kw)
	if kw.begins_with("remote"):
		var num := kw.substr("remote".length())
		return remote_num_to_name(num)
	return null


static func central_to_name(zone: Variant) -> Variant:
	var kw := NRUtil.to_kw(zone if not (zone is Array) else NRUtil.last_of(zone))
	match kw:
		"hand", "hq":
			return "HQ"
		"deck", "rd":
			return "R&D"
		"discard", "archives":
			return "Archives"
		_:
			return null


static func zone_to_name(zone: Variant) -> String:
	var c = central_to_name(zone)
	if c != null:
		return str(c)
	var r = remote_to_name(zone)
	return str(r) if r != null else str(zone)


static func name_zone(side: Variant, zone: Variant) -> String:
	var s := NRUtil.side_str(side)
	var z: Array = NRUtil.zone_as_array(zone)
	if z == ["hand"]:
		return "the Grip" if s == "Runner" else "HQ"
	if z == ["discard"]:
		return "the Heap" if s == "Runner" else "Archives"
	if z == ["deck"]:
		return "the Stack" if s == "Runner" else "R&D"
	if z == ["set-aside"]:
		return "set-aside cards"
	if not z.is_empty() and z[0] == "rig":
		return "Rig"
	if z.size() >= 2 and z[0] == "servers" and z[1] == "hq":
		return "the root of HQ"
	if z.size() >= 2 and z[0] == "servers" and z[1] == "rd":
		return "the root of R&D"
	if z.size() >= 2 and z[0] == "servers" and z[1] == "archives":
		return "the root of Archives"
	return zone_to_name(z[1] if z.size() > 1 else z)


static func zone_to_sort_key(zone: Variant) -> int:
	var kw := NRUtil.to_kw(zone if not (zone is Array) else NRUtil.last_of(zone))
	match kw:
		"archives":
			return -3
		"rd":
			return -2
		"hq":
			return -1
		_:
			if kw.begins_with("remote"):
				return int(kw.substr("remote".length()))
			return 99


static func zones_to_sorted_names(zones: Array) -> Array:
	var copy := zones.duplicate()
	copy.sort_custom(func(a, b): return zone_to_sort_key(a) < zone_to_sort_key(b))
	var names: Array = []
	for z in copy:
		names.append(zone_to_name(z))
	return names


static func is_remote(zone: Variant) -> bool:
	return remote_to_name(zone) != null


static func is_central(zone: Variant) -> bool:
	return not is_remote(zone)


static func is_root(zone: Variant) -> bool:
	var z: Array = NRUtil.zone_as_array(zone)
	return z.size() >= 3 and is_central(z[1] if z.size() > 1 else z) and NRUtil.to_kw(z[z.size() - 1]) == "content"


static func central_to_zone(zone: Variant) -> Variant:
	var kw := NRUtil.to_kw(zone if not (zone is Array) else NRUtil.last_of(zone))
	match kw:
		"discard":
			return ["servers", "archives"]
		"hand":
			return ["servers", "hq"]
		"deck":
			return ["servers", "rd"]
		_:
			return null


static func type_to_rig_zone(typ: String) -> Array:
	return ["rig", typ.to_lower()]


static func get_server_type(zone: Variant) -> String:
	var kw := NRUtil.to_kw(zone)
	if kw in ["hq", "rd", "archives"]:
		return kw
	return "remote"


static func same_server(card1: Dictionary, card2: Dictionary) -> bool:
	var z1 := NRCard.get_zone(card1)
	var z2 := NRCard.get_zone(card2)
	if z1.size() < 2 or z2.size() < 2:
		return false
	return NRUtil.to_kw(z1[1]) == NRUtil.to_kw(z2[1])


static func protecting_same_server(card: Dictionary, ice: Dictionary) -> bool:
	var z1 := NRCard.get_zone(card)
	var z2 := NRCard.get_zone(ice)
	if z2.is_empty() or NRUtil.to_kw(z2[z2.size() - 1]) != "ices":
		return false
	var c1 = central_to_zone(z1)
	var srv1 = (c1[1] if c1 is Array else (z1[1] if z1.size() > 1 else null))
	var srv2 = z2[1] if z2.size() > 1 else null
	return srv1 != null and NRUtil.to_kw(srv1) == NRUtil.to_kw(srv2)


static func in_same_server(card1: Dictionary, card2: Dictionary) -> bool:
	var z1 := NRCard.get_zone(card1)
	var z2 := NRCard.get_zone(card2)
	return z1 == z2 and not z1.is_empty() and NRUtil.to_kw(z1[z1.size() - 1]) == "content"


static func unknown_to_kw(name_or_kw_or_zone: Variant) -> String:
	if name_or_kw_or_zone is Array:
		return NRUtil.to_kw(name_or_kw_or_zone[1] if name_or_kw_or_zone.size() > 1 else name_or_kw_or_zone[0])
	if name_or_kw_or_zone is String:
		match name_or_kw_or_zone:
			"HQ":
				return "hq"
			"R&D":
				return "rd"
			"Archives":
				return "archives"
			_:
				var parts := (name_or_kw_or_zone as String).split(" ")
				return "remote" + str(parts[parts.size() - 1])
	return NRUtil.to_kw(name_or_kw_or_zone)
