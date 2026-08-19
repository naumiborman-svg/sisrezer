class_name NRTags
extends RefCounted
## Runner tags. Port of game.core.tags.

static func sum_tag_effects(state: NRState) -> int:
	return int(state.get_in(["runner", "tag", "base"], 0)) + NREffects.sum_effects(state, "runner", "user-tags") + NREffects.sum_effects(state, "runner", "tags")


static func update_tag_status(state: NRState, _side: Variant = null) -> bool:
	var old_total: int = int(state.get_in(["runner", "tag", "total"], 0))
	var new_total := sum_tag_effects(state)
	var is_tagged := NREffects.any_effects(state, "runner", "is-tagged") or new_total > 0
	var changed := old_total != new_total or bool(state.get_in(["runner", "tag", "is-tagged"], false)) != is_tagged
	if changed:
		var tag: Dictionary = state.get_in(["runner", "tag"], {})
		tag["total"] = new_total
		tag["is-tagged"] = is_tagged
		state.assoc_in(["runner", "tag"], tag)
		NREngine.trigger_event(state, "runner", "tags-changed", {"new-total": new_total, "old-total": old_total, "is-tagged": is_tagged})
	return changed


static func gain_tags(state: NRState, side: Variant, eid: Dictionary, n: int, args: Dictionary = {}) -> void:
	NREid.wait_for(state, eid, func(pe):
		NRPrevention.resolve_tag_prevention(state, side, pe, n, args)
	, func(async_result):
		var remaining := n
		if async_result is Dictionary:
			remaining = int(async_result.get("remaining", n))
		if remaining > 0:
			NRGaining.gain(state, "runner", "tag", {"base": remaining})
			NRToasts.toast(state, "runner", "Took %s!" % NRUtil.quantify(remaining, "tag"), "info")
			update_tag_status(state)
			NREngine.queue_event(state, "runner-gain-tag", {"side": side, "amount": remaining, "cause-card": NRUtil.select_keys(args.get("card", {}), ["cid", "title"]) if args.get("card") is Dictionary else {}})
		else:
			NREngine.queue_event(state, "runner-prevents-all-tags", {"side": side})
		if bool(args.get("suppress-checkpoint", false)):
			NREid.effect_completed(state, null, eid)
		else:
			NREngine.checkpoint(state, eid)
	)


static func gain_tags_ability(n: int) -> Dictionary:
	return {
		"msg": "take %s" % NRUtil.quantify(n, "tag"),
		"async": true,
		"effect": func(state, side, eid, _c, _t): gain_tags(state, side, eid, n),
	}


static func lose_tags(state: NRState, side: Variant, eid: Dictionary, n: Variant, args: Dictionary = {}) -> void:
	if NRUtil.kw_eq(n, "all") or str(n) == "all":
		n = int(state.get_in(["runner", "tag", "base"], 0))
	n = mini(int(n), int(state.get_in(["runner", "tag", "base"], 0)))
	state.update_in(["stats", "runner", "lose", "tag"], NRUtil.inc_n(int(n)), 0)
	NRGaining.deduct(state, "runner", "tag", {"base": n})
	update_tag_status(state)
	NREngine.queue_event(state, "runner-lose-tag", {"amount": n, "side": side})
	if bool(args.get("suppress-checkpoint", false)):
		NREid.effect_completed(state, null, eid)
	else:
		NREngine.checkpoint(state, eid)
