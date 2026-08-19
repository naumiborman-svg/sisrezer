class_name NRToString
extends RefCounted
## Card string descriptions. Port of game.core.to_string.

static func card_str(state: NRState, card: Dictionary, args: Dictionary = {}) -> String:
	var visible := bool(args.get("visible", false))
	var maybe_visible := bool(args.get("maybe-visible", false))
	var host = card.get("host")
	var text := ""
	if NRCard.corp(card):
		var installed_ice := NRCard.ice(card) and NRCard.installed(card)
		if NRCard.rezzed(card) or bool(card.get("seen", false)) or visible:
			text = NRCard.get_title(card)
		elif maybe_visible:
			text = "facedown %s" % NRCard.get_title(card)
		else:
			text = "ice" if installed_ice else "a card"
		if host == null:
			var z := NRCard.get_zone(card)
			var loc := ""
			if installed_ice:
				loc = " protecting "
			elif NRServers.is_root(z):
				loc = " in the root of "
			else:
				loc = " in "
			var zn = z[1] if z.size() > 1 else (z[0] if not z.is_empty() else "")
			text += loc + NRServers.zone_to_name(zn)
			if installed_ice:
				var idx = NRCard.card_index(state, card)
				if idx != null:
					text += " at position %s" % str(idx)
	else:
		if bool(card.get("facedown", false)) or visible:
			text = "a facedown card"
		else:
			text = NRCard.get_title(card)
	if host is Dictionary:
		var host_now = NRCard.get_card(state, host)
		if host_now is Dictionary:
			text += " hosted on " + card_str(state, host_now)
	return text
