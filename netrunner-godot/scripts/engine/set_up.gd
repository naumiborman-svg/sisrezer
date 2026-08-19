class_name NRSetUp
extends RefCounted
## Game creation, mulligan, keep. Port of game.core.set_up.

static func build_card(card: Dictionary) -> Dictionary:
	var s_card := NRCardDefs.server_card(str(card.get("title", "")), false)
	if s_card.is_empty():
		s_card = card
	else:
		s_card = NRUtil.merge(s_card, card)
	var made := NRInitializing.make_card(s_card)
	if card.has("art"):
		made["art"] = card["art"]
	return made


static func create_deck(deck: Dictionary) -> Array:
	var cards: Array = []
	for entry in deck.get("cards", []):
		if not (entry is Dictionary):
			continue
		var qty: int = int(entry.get("qty", 1))
		var base: Dictionary = entry.get("card", entry)
		if entry.has("art"):
			base = base.duplicate(true)
			base["art"] = entry["art"]
		for i in range(qty):
			cards.append(build_card(base))
	cards.shuffle()
	return cards


static func mulligan(state: NRState, side: Variant, _args: Variant = null) -> void:
	var s := NRUtil.to_side(side)
	NRShuffling.shuffle_into_deck(state, s, ["hand"])
	NRDrawing.draw(state, s, NREid.make_eid(state), 5, {"suppress-event": true, "no-update-draw-stats": true})
	var card: Dictionary = state.get_in([s, "identity"], {})
	var cdef := NRCardDefs.card_def(card)
	if cdef.get("mulligan") is Callable:
		cdef["mulligan"].call(state, s, NREid.make_eid(state), card, null)
	state.assoc_in([s, "keep"], "mulligan")
	NRSay.system_msg(state, s, "takes a mulligan")
	NREngine.trigger_event(state, s, "pre-first-turn", null)
	_mulligan_prompts(state, s)


static func keep_hand(state: NRState, side: Variant, _args: Variant = null) -> void:
	var s := NRUtil.to_side(side)
	state.assoc_in([s, "keep"], "keep")
	NRSay.system_msg(state, s, "keeps [their] hand")
	NREngine.trigger_event(state, s, "pre-first-turn", null)
	_mulligan_prompts(state, s)


static func _mulligan_prompts(state: NRState, side: String) -> void:
	if side == "corp" and str(state.get_in(["runner", "identity", "title"], "")) != "":
		NRPrompts.clear_wait_prompt(state, "runner")
		NRPrompts.show_wait_prompt(state, "corp", "Runner to keep hand or mulligan")
	if side == "runner" and str(state.get_in(["corp", "identity", "title"], "")) != "":
		NRPrompts.clear_wait_prompt(state, "corp")


static func init_hands(state: NRState) -> void:
	NRDrawing.draw(state, "corp", NREid.make_eid(state), 5, {"suppress-event": true})
	NRDrawing.draw(state, "runner", NREid.make_eid(state), 5, {"suppress-event": true})
	for side in ["corp", "runner"]:
		if str(state.get_in([side, "identity", "title"], "")) != "":
			NRPrompts.show_prompt(state, side, NREid.make_eid(state), null, "Keep hand?", ["Keep", "Mulligan"], func(choice):
				var val = choice.get("value") if choice is Dictionary else choice
				if str(val) == "Keep":
					keep_hand(state, side)
				else:
					mulligan(state, side)
			, {"prompt-type": "mulligan"})
	if str(state.get_in(["corp", "identity", "title"], "")) != "" and str(state.get_in(["runner", "identity", "title"], "")) != "":
		NRPrompts.show_wait_prompt(state, "runner", "Corp to keep hand or mulligan")


static func create_basic_action_cards(state: NRState) -> void:
	state.assoc_in(["corp", "basic-action-card"], NRInitializing.make_card({"side": "Corp", "type": "Basic Action", "title": "Corp Basic Action Card"}))
	state.assoc_in(["runner", "basic-action-card"], NRInitializing.make_card({"side": "Runner", "type": "Basic Action", "title": "Runner Basic Action Card"}))
	var corp_bac = state.get_in(["corp", "basic-action-card"])
	var runner_bac = state.get_in(["runner", "basic-action-card"])
	if corp_bac is Dictionary:
		NRInitializing.card_init(state, "corp", corp_bac, {"resolve-effect": false, "init-data": false})
	if runner_bac is Dictionary:
		NRInitializing.card_init(state, "runner", runner_bac, {"resolve-effect": false, "init-data": false})


static func init_game(game: Dictionary) -> NRState:
	NRCardsBasic.register()
	NREngine.register_ability_type("psi", func(st, sd, ab, c, t): NRPsi.check_psi(st, sd, ab, c, t))
	NREngine.register_ability_type("trace", func(st, sd, ab, c, t): NRTrace.check_trace(st, sd, ab, c, t))
	NREngine.register_ability_type("optional", func(st, sd, ab, c, t): NROptional.check_optional(st, sd, ab, c, t))
	var players: Array = game.get("players", [])
	var corp_p: Dictionary = {}
	var runner_p: Dictionary = {}
	for p in players:
		if p is Dictionary:
			if NRUtil.to_side(p.get("side")) == "corp" or str(p.get("side")).to_lower() == "corp":
				corp_p = p
			elif NRUtil.to_side(p.get("side")) == "runner" or str(p.get("side")).to_lower() == "runner":
				runner_p = p
	var corp_deck := create_deck(corp_p.get("deck", {}))
	var runner_deck := create_deck(runner_p.get("deck", {}))
	for c in corp_deck:
		c["zone"] = ["deck"]
	for c in runner_deck:
		c["zone"] = ["deck"]
	var corp_id_src: Dictionary = NRUtil.get_in(corp_p, ["deck", "identity"], {"side": "Corp", "type": "Identity", "title": "Custom Biotics: Engineered for Success"})
	var runner_id_src: Dictionary = NRUtil.get_in(runner_p, ["deck", "identity"], {"side": "Runner", "type": "Identity", "title": "The Professor: Keeper of Knowledge"})
	var corp_id := build_card(corp_id_src)
	var runner_id := build_card(runner_id_src)
	var options: Dictionary = {
		"timer": game.get("timer"),
		"spectatorhands": game.get("spectatorhands"),
		"api-access": game.get("api-access"),
		"replay-id": game.get("replay-id"),
		"save-replay": game.get("save-replay"),
	}
	var state := NRState.new_state(game.get("gameid"), game.get("room"), game.get("format", "standard"), NRUtil.make_timestamp(), options, NRPlayer.new_corp(corp_p.get("user", {"username": "Corp"}), corp_id, corp_p.get("options", {}), corp_deck, NRUtil.get_in(corp_p, ["deck", "_id"]), null), NRPlayer.new_runner(runner_p.get("user", {"username": "Runner"}), runner_id, runner_p.get("options", {}), runner_deck, NRUtil.get_in(runner_p, ["deck", "_id"]), null))
	state.setv("log", [])
	NRInitializing.card_init(state, "corp", corp_id, {"resolve-effect": true, "init-data": true})
	NRSay.implementation_msg(state, corp_id)
	NRInitializing.card_init(state, "runner", runner_id, {"resolve-effect": true, "init-data": true})
	NRSay.implementation_msg(state, runner_id)
	create_basic_action_cards(state)
	NREngine.fake_checkpoint(state)
	NREngine.trigger_event(state, "corp", "pre-start-game", null)
	NREngine.trigger_event(state, "runner", "pre-start-game", null)
	if not bool(game.get("skip-mulligan", false)):
		init_hands(state)
	else:
		NRDrawing.draw(state, "corp", NREid.make_eid(state), 5, {"suppress-event": true})
		NRDrawing.draw(state, "runner", NREid.make_eid(state), 5, {"suppress-event": true})
		state.assoc_in(["corp", "keep"], "keep")
		state.assoc_in(["runner", "keep"], "keep")
	NREngine.fake_checkpoint(state)
	return state
