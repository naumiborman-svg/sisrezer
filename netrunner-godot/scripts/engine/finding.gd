class_name NRFinding
extends RefCounted
## Card lookup helpers. Port of game.core.finding.

static func find_card(title: String, from_seq: Array) -> Variant:
	for c in from_seq:
		if c is Dictionary and str(c.get("title")) == title:
			return c
	return null


static func find_cid(cid: Variant, from_seq: Array) -> Variant:
	for c in from_seq:
		if c is Dictionary and c.get("cid") == cid:
			return c
	return null


static func find_latest(state: NRState, card: Dictionary) -> Variant:
	var side := NRUtil.to_side(card.get("side"))
	var pool: Array = NRBoard.all_installed(state, side)
	for zone in ["hand", "discard", "deck", "rfg", "scored"]:
		pool.append_array(state.get_in(["corp", zone], []))
		pool.append_array(state.get_in(["runner", zone], []))
	return find_cid(card.get("cid"), pool)


static func get_scoring_owner(state: NRState, card: Dictionary) -> Variant:
	var cid = card.get("cid")
	if find_cid(cid, state.get_in(["corp", "scored"], [])) != null:
		return "corp"
	if find_cid(cid, state.get_in(["runner", "scored"], [])) != null:
		return "runner"
	return null
