class_name NRShuffling
extends RefCounted
## Deck shuffling. Port of game.core.shuffling.

static func shuffle_coll(c: Array) -> Array:
	return NRUtil.shuffle_array(c)


static func shuffle_zone(state: NRState, side: Variant, kw: String, args: Dictionary = {}) -> void:
	var s := NRUtil.to_side(side)
	if kw not in ["deck", "hand", "discard"]:
		return
	if kw == "deck":
		NREngine.trigger_event(state, s, ("corp-shuffle-deck" if s == "corp" else "runner-shuffle-deck"), null)
		if s == "corp":
			state.assoc_in(["breach", "known-cids", "deck"], [])
			if state.getv("access") and state.getv("run"):
				state.assoc_in(["run", "shuffled-during-access", "rd"], true)
	if not bool(args.get("no-sfx", false)):
		NRSay.play_sfx(state, s, "shuffle")
	state.update_in(["stats", s, "shuffle-count"], NRUtil.inc_n(1), 0)
	var coll: Array = state.get_in([s, kw], [])
	state.assoc_in([s, kw], shuffle_coll(coll))


static func shuffle_into_deck(state: NRState, side: Variant, zones: Array = ["hand"]) -> void:
	var s := NRUtil.to_side(side)
	for zone in zones:
		NRMoving.move_zone(state, s, NRUtil.to_kw(zone), "deck")
	shuffle_zone(state, s, "deck")


static func shuffle_cards_into_deck(state: NRState, from_side: Variant, card: Dictionary, targets: Array, shuffle_side: Variant = null) -> void:
	var ss := NRUtil.to_side(shuffle_side if shuffle_side != null else from_side)
	var cards: Array = []
	for t in NRUtil.flatten(targets):
		var c = NRCard.get_card(state, t) if t is Dictionary else null
		if c is Dictionary:
			cards.append(c)
	for t in cards:
		if NRUtil.zone_as_array(t.get("zone")) != ["deck"]:
			NRMoving.move(state, ss, t, "deck")
	NRSay.system_msg(state, from_side, "uses %s to shuffle cards into %s" % [card.get("title", "a card"), "R&D" if ss == "corp" else "the Stack"])
	shuffle_zone(state, ss, "deck")


static func shuffle_deck(state: NRState, side: Variant, args: Dictionary = {}) -> void:
	var s := NRUtil.to_side(side)
	var deck: Array = state.get_in([s, "deck"], [])
	state.assoc_in([s, "deck"], shuffle_coll(deck))
	NRSay.play_sfx(state, s, "shuffle")
	if bool(args.get("close", false)):
		var p: Dictionary = state.player(s)
		p.erase("view-deck")
		state.side_set(s, "view-deck", null)
		NRSay.system_msg(state, s, "stops looking at [pronoun] deck and shuffles it")
	else:
		NRSay.system_msg(state, s, "shuffles [pronoun] deck")
