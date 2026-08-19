class_name NRPsi
extends RefCounted
## Psi games. Port of game.core.psi.

static func psi_game(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, psi: Dictionary, targets: Variant = null) -> void:
	state.setv("psi", {})
	NREngine.register_once(state, side, psi, card)
	for s in ["corp", "runner"]:
		var max_amt := mini(2, NRCosts.total_available_credits(state, s, eid, card))
		var choices: Array = []
		for i in range(max_amt + 1):
			choices.append("%d [Credits]" % i)
		NRPrompts.show_prompt_with_dice(state, s, card, "Choose an amount to spend for %s" % card.get("title"), choices, func(choice):
			_resolve_psi(state, s, eid, card, psi, _parse_bet(choice), targets)
		, {"prompt-type": "psi"})


static func _parse_bet(choice: Variant) -> int:
	var val = choice.get("value") if choice is Dictionary else choice
	return int(str(val).split(" ")[0])


static func _resolve_psi(state: NRState, side: Variant, eid: Dictionary, card: Dictionary, psi: Dictionary, bet: int, targets: Variant) -> void:
	state.assoc_in(["psi", NRUtil.to_side(side)], bet)
	var opponent := NRUtil.other_side(side)
	var opp_bet = state.get_in(["psi", opponent])
	if opp_bet == null:
		NRPrompts.show_wait_prompt(state, side, "%s to choose psi game credits" % NRUtil.side_str(opponent))
		return
	NREid.wait_for(state, eid, func(pe):
		NREngine.pay(state, opponent, pe, card, [NRPayment.to_c("credit", int(opp_bet))])
	, func(_p1):
		NREid.wait_for(state, eid, func(pe2):
			NREngine.pay(state, side, pe2, card, [NRPayment.to_c("credit", bet)])
		, func(_p2):
			NRPrompts.clear_wait_prompt(state, opponent)
			var equal := int(opp_bet) == bet
			var ability = psi.get("equal") if equal else psi.get("not-equal")
			if ability is Dictionary:
				NREngine.continue_ability(state, NRUtil.to_side(card.get("side")), NRUtil.merge(ability, {"async": true}), card, targets)
			else:
				NREid.effect_completed(state, side, eid)
		)
	)


static func check_psi(state: NRState, side: Variant, ability: Dictionary, card: Dictionary, targets: Variant) -> void:
	var psi: Dictionary = ability.get("psi", {})
	if NREngine.can_trigger(state, side, ability.get("eid"), psi, card, targets):
		NREngine.resolve_ability(state, side, ability.get("eid"), {
			"async": true,
			"effect": func(st, sd, e, c, t): psi_game(st, sd, e, c, psi, t),
		}, card, targets)
	else:
		NREid.effect_completed(state, side, ability.get("eid"))
