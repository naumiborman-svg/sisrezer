class_name NRChangeVals
extends RefCounted

## Port of game.core.change_vals — admin / command value mutation.


static func change(state: NRState, side: Variant, args: Dictionary) -> void:
	var s = NRUtil.to_side(side)
	var key: String = NRUtil.to_kw(args.get("key", ""))
	var delta: int = int(args.get("delta", 0))
	var eid = NREid.make_eid(state)
	match key:
		"credit", "credits":
			if delta >= 0:
				NRGaining.gain_credits(state, s, eid, delta, {"suppress-checkpoint": true})
			else:
				NRGaining.lose_credits(state, s, eid, -delta, {"suppress-checkpoint": true})
		"click", "clicks":
			if delta >= 0:
				NRGaining.gain_clicks(state, s, delta)
			else:
				NRGaining.lose_clicks(state, s, -delta)
			NREid.effect_completed(state, s, eid)
		"tag", "tags":
			if delta >= 0:
				NRTags.gain_tags(state, s, eid, delta, {"suppress-checkpoint": true})
			else:
				NRTags.lose_tags(state, s, eid, -delta, {"suppress-checkpoint": true})
		"memory", "memory-units":
			var mu: Dictionary = state.get_in([s, "memory"], {})
			state.assoc_in([s, "memory", "available"], int(mu.get("available", 0)) + delta)
			NREid.effect_completed(state, s, eid)
		"hand-size":
			state.update_in([s, "hand-size", "mod"], func(v): return int(v) + delta, 0)
			NRHandSize.update_hand_size(state, s)
			NREid.effect_completed(state, s, eid)
		"agenda-point":
			state.update_in([s, "agenda-point"], func(v): return int(v) + delta, 0)
			NRWinning.check_win_by_agenda(state)
			NREid.effect_completed(state, s, eid)
		"bad-publicity":
			if delta >= 0:
				NRBadPublicity.gain_bad_publicity(state, s, eid, delta, {"suppress-checkpoint": true})
			else:
				NRBadPublicity.lose_bad_publicity(state, s, eid, -delta, {"no-event": true})
		"link":
			state.update_in([s, "link"], func(v): return int(v) + delta, 0)
			NREid.effect_completed(state, s, eid)
		"brain-damage":
			state.update_in([s, "brain-damage"], func(v): return maxi(0, int(v) + delta), 0)
			NREid.effect_completed(state, s, eid)
		_:
			state.update_in([s, key], func(v): return int(v) + delta, 0)
			NREid.effect_completed(state, s, eid)
