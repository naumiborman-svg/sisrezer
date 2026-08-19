class_name NRBadPublicity
extends RefCounted
## Corp bad publicity. Port of game.core.bad_publicity.

static func bad_publicity_available(state: NRState, side: Variant) -> int:
	if NRUtil.to_side(side) == "runner":
		return int(state.get_in(["run", "bad-publicity-available"], 0))
	return 0


static func gain_bad_publicity(state: NRState, side: Variant, eid: Dictionary, n: int, args: Dictionary = {}) -> void:
	NREid.wait_for(state, eid, func(pe):
		NRPrevention.resolve_bad_pub_prevention(state, side, pe, n, args)
	, func(async_result):
		var remaining := n
		if async_result is Dictionary:
			remaining = int(async_result.get("remaining", n))
		if remaining > 0:
			NRGaining.gain(state, "corp", "bad-publicity", remaining)
			NRToasts.toast(state, "corp", "Took %d bad publicity!" % remaining, "info")
			NREngine.queue_event(state, "corp-gain-bad-publicity", {"amount": remaining})
			if bool(args.get("suppress-checkpoint", false)):
				NREid.effect_completed(state, side, eid)
			else:
				NREngine.checkpoint(state, eid)
		else:
			NREid.effect_completed(state, side, eid)
	)


static func lose_bad_publicity(state: NRState, side: Variant, eid: Dictionary, n: Variant, args: Dictionary = {}) -> void:
	if NRUtil.kw_eq(n, "all") or str(n) == "all":
		n = int(state.get_in(["corp", "bad-publicity", "base"], 0))
	n = mini(int(n), int(state.get_in(["corp", "bad-publicity", "base"], 0)))
	NRGaining.lose(state, "corp", "bad-publicity", n)
	if bool(args.get("no-event", false)):
		NREid.effect_completed(state, side, eid)
	else:
		NREngine.trigger_event_sync(state, side, eid, "corp-lose-bad-publicity", {"amount": n, "side": side})


static func spend_bad_publicity(state: NRState, side: Variant, amt: int) -> void:
	if NRUtil.to_side(side) == "runner" and bad_publicity_available(state, side) > 0:
		state.update_in(["run", "bad-publicity-available"], func(v): return int(v) - amt, 0)
