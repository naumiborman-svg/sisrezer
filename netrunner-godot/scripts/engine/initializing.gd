class_name NRInitializing
extends RefCounted
## Card construction and init/deactivate. Port of game.core.initializing.

static func subroutines_init(card: Dictionary, cdef: Dictionary) -> Array:
	var ice := NRUtil.dissoc(card, ["subroutines"])
	ice["cid"] = card.get("cid")
	for sub in cdef.get("subroutines", []):
		if sub is Dictionary:
			ice = NRIce.add_sub(ice, sub, ice.get("cid"), {"printed": true})
	return ice.get("subroutines", [])


static func ability_init(cdef: Dictionary) -> Array:
	var out: Array = []
	for ab in cdef.get("abilities", []):
		if ab is Dictionary:
			var a := ab.duplicate(true)
			a["label"] = NRUtil.make_label(a)
			out.append(NRPayment.add_cost_label_to_ability(a))
	return out


static func corp_ability_init(cdef: Dictionary) -> Array:
	var out: Array = []
	for ab in cdef.get("corp-abilities", []):
		if ab is Dictionary:
			var a := {"cost": ab.get("cost"), "label": NRUtil.make_label(ab)}
			out.append(NRPayment.add_cost_label_to_ability(a))
	return out


static func runner_ability_init(cdef: Dictionary) -> Array:
	var out: Array = []
	for ab in cdef.get("runner-abilities", []):
		if ab is Dictionary:
			var a := {"cost": ab.get("cost"), "break-cost": ab.get("break-cost"), "label": NRUtil.make_label(ab)}
			out.append(NRPayment.add_cost_label_to_ability(a, ab.get("break-cost", ab.get("cost"))))
	return out


static func card_implemented(card: Dictionary) -> Variant:
	var cdef := NRCardDefs.card_def(card)
	if cdef.is_empty() and not NRCardDefs.implemented(str(card.get("title", ""))):
		# empty def is still "implemented" if registered as {}
		if card.get("title") in ["Corp Basic Action Card", "Runner Basic Action Card"]:
			return "full"
		if NRCardDefs._defs.has(card.get("title", "")):
			pass
		else:
			return null
	var impl = cdef.get("implementation")
	if impl != null:
		return impl
	return "full"


static func make_card(card: Dictionary, cid: String = "") -> Dictionary:
	if cid == "":
		cid = NRUtil.make_cid()
	var cdef := NRCardDefs.card_def(card)
	var c := card.duplicate(true)
	c["cid"] = cid
	c["implementation"] = card_implemented(c)
	c["subroutines"] = subroutines_init(NRUtil.merge(c, {"cid": cid}), cdef)
	c["abilities"] = ability_init(cdef)
	c["x-fn"] = cdef.get("x-fn")
	c["timestamp"] = NRUtil.make_timestamp()
	c["poison"] = cdef.get("poison")
	c["highlight-in-discard"] = cdef.get("highlight-in-discard")
	c["printed-title"] = card.get("title")
	if c.has("subtype") and not c.has("subtypes"):
		var st = c["subtype"]
		c["subtypes"] = st.split(" - ") if st is String else (st if st is Array else [])
	for k in ["setname", "text", "_id", "influence", "number", "influencelimit", "images", "previous-versions", "rotated", "image_url", "factioncost", "format", "quantity"]:
		c.erase(k)
	return c


static func deactivate(state: NRState, side: Variant, card: Dictionary, keep_counter: bool = false) -> Dictionary:
	NREngine.unregister_events(state, side, card)
	NREffects.unregister_static_abilities(state, side, card)
	var leave = NRCardDefs.card_def(card).get("leave-play")
	if leave is Callable and not bool(card.get("disabled", false)):
		leave.call(state, side, NREid.make_eid(state), card, null)
	var cdef := NRCardDefs.card_def(card)
	var c := NRUtil.dissoc(card, ["current-strength", "current-advancement-requirement", "current-points", "runner-abilities", "corp-abilities", "rezzed", "new", "subtype-target", "card-target", "extra-advance-counter", "special"])
	c["subroutines"] = subroutines_init(c, cdef)
	c["abilities"] = ability_init(cdef)
	if not keep_counter:
		c.erase("counter")
		c.erase("advance-counter")
	return c


static func card_init(state: NRState, side: Variant, card: Dictionary, args: Dictionary = {}) -> Dictionary:
	var eid := NREid.make_eid(state)
	var resolve_effect := args.get("resolve-effect", true)
	var init_data := args.get("init-data", true)
	var cdef := NRCardDefs.card_def(card)
	var c := card.duplicate(true)
	c["runner-abilities"] = runner_ability_init(cdef)
	c["corp-abilities"] = corp_ability_init(cdef)
	c["special"] = NRUtil.merge(c.get("special", {}) if c.get("special") is Dictionary else {}, cdef.get("special", {}) if cdef.get("special") is Dictionary else {})
	NRUpdate.update_card(state, side, c)
	c = NRCard.get_card(state, c)
	if c == null:
		c = card
	if cdef.has("data") and init_data:
		var data = cdef["data"].get("counter", {}) if cdef["data"] is Dictionary else {}
		if data is Dictionary:
			for ct in data:
				NRProps.add_counter(state, side, NREid.make_eid(state), c, str(ct), int(data[ct]), {"placed": true, "suppress-checkpoint": true})
	NREngine.register_default_events(state, side, c)
	NREffects.register_static_abilities(state, side, c)
	if NRCard.program(c) and not bool(args.get("no-mu", false)):
		NRMemory.init_mu_cost(state, c)
	if resolve_effect and NREngine.is_ability(cdef):
		NREngine.resolve_ability(state, side, eid, NRUtil.dissoc(cdef, ["cost", "additional-cost"]), c, null)
	else:
		NREid.effect_completed(state, side, eid)
	var in_play = cdef.get("in-play")
	if in_play is Array and in_play.size() >= 2:
		NRGaining.gain(state, side, str(in_play[0]), in_play[1])
	return NRCard.get_card(state, c) if NRCard.get_card(state, c) != null else c


static func update_abilities_cost_str(state: NRState, side: Variant, card: Dictionary) -> Dictionary:
	var c := card.duplicate(true)
	for kw in ["abilities", "corp-abilities", "runner-abilities"]:
		var arr: Array = []
		for ab in c.get(kw, []):
			if ab is Dictionary:
				var cost = ab
				if ab.has("break-cost"):
					cost = NRUtil.merge(ab, {"cost": NRCostFns.break_sub_ability_cost(state, side, ab, card)})
				arr.append(NRPayment.add_cost_label_to_ability(ab, NRCostFns.card_ability_cost(state, side, cost, card)))
		c[kw] = arr
	return c


static func update_all_card_labels(state: NRState) -> bool:
	var changed := false
	for card in NRBoard.all_active(state, "corp") + NRBoard.all_active(state, "runner"):
		if not (card is Dictionary):
			continue
		var side := NRUtil.to_side(card.get("side"))
		var new_card := update_abilities_cost_str(state, side, card)
		if str(new_card.get("abilities")) != str(card.get("abilities")):
			NRUpdate.update_card(state, side, new_card)
			changed = true
	return changed


static func reset_card(state: NRState, side: Variant, card: Dictionary) -> void:
	state.dissoc_in(["per-turn", card.get("cid")])
	var s_card := NRCardDefs.server_card(str(card.get("printed-title", card.get("title"))))
	var new_card := make_card(s_card, str(card.get("cid")))
	new_card["persistent"] = card.get("persistent")
	new_card["previous-zone"] = card.get("previous-zone")
	new_card["seen"] = card.get("seen")
	new_card["zone"] = card.get("zone")
	NRUpdate.update_card(state, side, new_card)
