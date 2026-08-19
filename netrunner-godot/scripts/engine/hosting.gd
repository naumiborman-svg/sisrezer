class_name NRHosting
extends RefCounted
## Hosting cards on other cards. Port of game.core.hosting.

static func remove_from_host(state: NRState, side: Variant, card: Dictionary) -> void:
	var host = NRCard.get_card(state, card.get("host"))
	if host is Dictionary:
		var hosted: Array = host.get("hosted", [])
		host = host.duplicate(true)
		host["hosted"] = NRUtil.remove_once(hosted, func(h): return h is Dictionary and h.get("cid") == card.get("cid"))
		NRUpdate.update_hosted(state, side, host)
		var hosted_lost = NRCardDefs.card_def(host).get("hosted-lost")
		if hosted_lost is Callable:
			hosted_lost.call(state, side, NREid.make_eid(state), NRCard.get_card(state, host), NRUtil.dissoc(card, ["host"]))


static func has_ancestor(card: Dictionary, target: Dictionary) -> bool:
	if NRUtil.same_card(card, target):
		return true
	if card.get("host") is Dictionary:
		return has_ancestor(card["host"], target)
	return false


static func host(state: NRState, side: Variant, card: Dictionary, target: Dictionary, args: Dictionary = {}) -> Dictionary:
	if card.get("cid") == target.get("cid"):
		return target
	if target.get("host"):
		remove_from_host(state, side, target)
	else:
		NRMoving.remove_old_card(state, side, target)
	var host_card = NRCard.get_card(state, card)
	if not (host_card is Dictionary):
		host_card = card
	var hosted = target.duplicate(true)
	hosted["host"] = NRUtil.dissoc(host_card, ["hosted"])
	hosted["facedown"] = NRUtil.truthy(args.get("facedown", false))
	hosted["zone"] = ["onhost"]
	hosted["timestamp"] = NRUtil.make_timestamp()
	hosted["previous-zone"] = target.get("zone")
	host_card = host_card.duplicate(true)
	var hlist: Array = host_card.get("hosted", [])
	hlist.append(hosted)
	host_card["hosted"] = hlist
	NRUpdate.update_card(state, side, host_card)
	if NRCard.program(hosted) and not NRUtil.truthy(args.get("no-mu", false)):
		NRMemory.init_mu_cost(state, hosted)
	return hosted
