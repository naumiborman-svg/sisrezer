class_name NRCostFns
extends RefCounted
## State-aware cost calculations. Port of game.core.cost_fns.

static func play_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Variant:
	if not card.has("cost") or card["cost"] == null:
		return null
	var total: int = int(card.get("cost", 0)) + int(args.get("cost-bonus", 0))
	var playfun = NRUtil.get_in(NRCardDefs.card_def(card), ["on-play", "play-cost-bonus"])
	if playfun is Callable:
		total += int(playfun.call(state, side, NREid.make_eid(state), card, null))
	total += NREffects.sum_effects(state, side, "play-cost", card)
	return maxi(total, 0)


static func base_play_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Array:
	var special = NRUtil.get_in(NRCardDefs.card_def(card), ["on-play", "base-play-cost"])
	if special is Array:
		return special
	var pc = play_cost(state, side, card, args)
	return [NRPayment.to_c("credit", int(pc) if pc != null else 0)]


static func play_additional_cost_bonus(state: NRState, side: Variant, card: Dictionary) -> Array:
	return NRPayment.merge_costs([
		NRUtil.get_in(NRCardDefs.card_def(card), ["on-play", "additional-cost"]),
		NREffects.get_effects(state, side, "play-additional-cost", card),
	])


static func rez_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Variant:
	if not card.has("cost") or card["cost"] == null:
		return null
	var total: int = int(card.get("cost", 0)) + int(args.get("cost-bonus", 0))
	var rezfun = NRCardDefs.card_def(card).get("rez-cost-bonus")
	if rezfun is Callable and not NREffects.is_disabled_reg(state, card):
		total += int(rezfun.call(state, side, NREid.make_eid(state), card, null))
	total += NREffects.sum_effects(state, side, "rez-cost", card)
	return maxi(total, 0)


static func rez_additional_cost_bonus(state: NRState, side: Variant, card: Dictionary, pred: Callable = Callable()) -> Array:
	var extra = NRCardDefs.card_def(card).get("additional-cost") if not NREffects.is_disabled_reg(state, card) else null
	var costs := NRPayment.merge_costs([extra, NREffects.get_effects(state, side, "rez-additional-cost", card)])
	if pred.is_valid():
		var out: Array = []
		for c in costs:
			if pred.call(c):
				out.append(c)
		return out
	return costs


static func score_additional_cost_bonus(state: NRState, side: Variant, card: Dictionary) -> Array:
	return NRPayment.merge_costs([
		NRCardDefs.card_def(card).get("additional-cost"),
		NREffects.get_effects(state, side, "score-additional-cost", card),
	])


static func trash_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Variant:
	if not card.has("trash") or card["trash"] == null:
		return null
	var total: int = int(card.get("trash", 0)) + int(args.get("cost-bonus", 0))
	var trashfun = NRCardDefs.card_def(card).get("trash-cost-bonus")
	if trashfun is Callable:
		total += int(trashfun.call(state, side, NREid.make_eid(state), card, null))
	total += NREffects.sum_effects(state, side, "trash-cost", card)
	return maxi(total, 0)


static func install_cost(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}, targets: Variant = null) -> int:
	var total := 0
	if NRCard.runner(card):
		total += int(card.get("cost", 0))
	total += int(args.get("cost-bonus", 0))
	var instfun = NRCardDefs.card_def(card).get("install-cost-bonus")
	if instfun is Callable:
		total += int(instfun.call(state, side, NREid.make_eid(state), card, null))
	total += NREffects.sum_effects(state, side, "install-cost", card, targets)
	return maxi(total, 0)


static func install_additional_cost_bonus(state: NRState, side: Variant, card: Dictionary) -> Array:
	return NRPayment.merge_costs([
		NRCardDefs.card_def(card).get("additional-cost"),
		NREffects.get_effects(state, side, "install-additional-cost", card),
	])


static func ignore_install_cost(state: NRState, side: Variant, card: Dictionary) -> bool:
	return NREffects.any_effects(state, side, "ignore-install-cost", func(v): return v == true, card)


static func run_cost(state: NRState, side: Variant, card: Variant, args: Dictionary = {}, targets: Variant = null) -> int:
	var total: int = int(args.get("cost-bonus", 0))
	total += NREffects.sum_effects(state, side, "run-cost", card, targets)
	return maxi(total, 0)


static func run_additional_cost_bonus(state: NRState, side: Variant, card: Variant, targets: Variant = null) -> Array:
	return NRPayment.merge_costs(NREffects.get_effects(state, side, "run-additional-cost", card, targets))


static func has_trash_ability(card: Dictionary) -> bool:
	var cdef := NRCardDefs.card_def(card)
	var pools: Array = [cdef.get("abilities", []), cdef.get("events", []), [NRUtil.get_in(cdef, ["interactions", "access-ability"])]]
	for pool in pools:
		if not (pool is Array):
			continue
		for ab in pool:
			if ab is Dictionary:
				for c in NRUtil.flatten([ab.get("cost"), ab.get("fake-cost")]):
					if c is Dictionary and str(c.get("cost/type")) == "trash-can":
						return true
	return false


static func card_ability_cost(state: NRState, side: Variant, ability: Dictionary, card: Dictionary, targets: Variant = null) -> Array:
	var bonus = ability.get("cost-bonus")
	var bonus_v = bonus.call(state, side, NREid.make_eid(state), card, targets) if bonus is Callable else bonus
	return NRPayment.merge_costs([
		ability.get("cost"),
		bonus_v,
		NREffects.get_effects(state, side, "card-ability-cost", {"card": card, "ability": ability, "targets": targets}),
		ability.get("additional-cost"),
		NREffects.get_effects(state, side, "card-ability-additional-cost", {"card": card, "ability": ability, "targets": targets}),
	])


static func break_sub_ability_cost(state: NRState, side: Variant, ability: Dictionary, card: Dictionary, targets: Variant = null) -> Array:
	var bonus = ability.get("break-cost-bonus")
	var bonus_v = bonus.call(state, side, NREid.make_eid(state), card, targets) if bonus is Callable else null
	return NRPayment.merge_costs([
		ability.get("break-cost"),
		ability.get("additional-cost"),
		bonus_v,
		NREffects.get_effects(state, side, "break-sub-additional-cost", {"card": card, "ability": ability, "targets": targets}),
	])


static func jack_out_cost(state: NRState, side: Variant) -> Array:
	return NREffects.get_effects(state, side, "jack-out-additional-cost")


static func steal_cost(state: NRState, side: Variant, eid: Dictionary, card: Dictionary) -> Array:
	var costfun = NRCardDefs.card_def(card).get("steal-cost-bonus")
	var steal = costfun.call(state, side, eid, card, null) if costfun is Callable else null
	return NRPayment.merge_costs([steal, NREffects.get_effects(state, side, "steal-additional-cost", card)])
