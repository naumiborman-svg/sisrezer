class_name NRAgendas
extends RefCounted
## Advancement requirements and agenda points. Port of game.core.agendas.

static func advancement_requirement(state: NRState, card: Dictionary) -> Variant:
	if not NRCard.agenda(card):
		return null
	var base: int = int(card.get("advancementcost", 0))
	var cdef := NRCardDefs.card_def(card)
	if cdef.get("advancement-requirement") is Callable:
		base += int(cdef["advancement-requirement"].call(state, "corp", NREid.make_eid(state), card, null))
	base += NREffects.sum_effects(state, "corp", "advancement-requirement", card)
	return maxi(base, 0)


static func update_advancement_requirement(state: NRState, agenda: Dictionary) -> bool:
	var prev = agenda.get("current-advancement-requirement")
	var new_req = advancement_requirement(state, agenda)
	if prev != new_req:
		var c := agenda.duplicate(true)
		c["current-advancement-requirement"] = new_req
		NRUpdate.update_card(state, "corp", c)
		return true
	return false


static func update_all_advancement_requirements(state: NRState, _side: Variant = null) -> bool:
	var changed := false
	for c in NRBoard.get_all_cards(state):
		if c is Dictionary and NRCard.agenda(c):
			if update_advancement_requirement(state, c):
				changed = true
	return changed


static func agenda_points(state: NRState, side: Variant, card: Dictionary) -> int:
	var base: int = int(card.get("agendapoints", 0))
	var cdef := NRCardDefs.card_def(card)
	var points_fn = cdef.get("agendapoints-corp") if NRUtil.to_side(side) == "corp" else cdef.get("agendapoints-runner")
	if points_fn is Callable:
		return int(points_fn.call(state, side, null, card, null)) + NREffects.sum_effects(state, side, "agenda-value", card)
	return base + NREffects.sum_effects(state, side, "agenda-value", card)


static func update_all_agenda_points(state: NRState, _side: Variant = null) -> bool:
	var changed := false
	for side in ["corp", "runner"]:
		for agenda in state.get_in([side, "scored"], []):
			if agenda is Dictionary:
				var prev = agenda.get("current-points")
				var np := agenda_points(state, side, agenda)
				if prev != np:
					var c := agenda.duplicate(true)
					c["current-points"] = np
					NRUpdate.update_card(state, side, c)
					changed = true
		var user_adj := NREffects.sum_effects(state, side, "user-agenda-points", side)
		var scored_pts := 0
		for agenda in state.get_in([side, "scored"], []):
			if agenda is Dictionary:
				scored_pts += int(agenda.get("current-points", agenda.get("agendapoints", 0)))
		var total := user_adj + scored_pts
		if int(state.get_in([side, "agenda-point"], 0)) != total:
			state.assoc_in([side, "agenda-point"], total)
			changed = true
	return changed
