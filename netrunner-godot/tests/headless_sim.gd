extends Node
## Headless smoke test: boot engine, two stub players, start-turn / credit / install / run.

var _ok := true
var _failures: PackedStringArray = PackedStringArray()


func _ready() -> void:
	print("=== netrunner-godot headless smoke test ===")
	NRCardsBasic.register()
	_register_stubs()
	var state := NRSetUp.init_game({
		"gameid": "smoke-1",
		"skip-mulligan": true,
		"players": [
			{
				"side": "Corp",
				"user": {"username": "SmokeCorp"},
				"deck": {
					"identity": {"title": "Custom Biotics: Engineered for Success", "side": "Corp", "type": "Identity"},
					"cards": [
						{"qty": 6, "card": {"title": "Wall of Static"}},
						{"qty": 4, "card": {"title": "PAD Campaign"}},
						{"qty": 4, "card": {"title": "Hedge Fund"}},
					],
				},
			},
			{
				"side": "Runner",
				"user": {"username": "SmokeRunner"},
				"deck": {
					"identity": {"title": "The Professor: Keeper of Knowledge", "side": "Runner", "type": "Identity"},
					"cards": [
						{"qty": 6, "card": {"title": "Sure Gamble"}},
						{"qty": 4, "card": {"title": "Corroder"}},
						{"qty": 4, "card": {"title": "Easy Mark"}},
					],
				},
			},
		],
	})
	_expect(state != null, "init_game returned state")
	_expect(state.get_in(["corp", "hand"], []).size() == 5, "corp opening hand 5 (skip-mulligan)")
	_expect(state.get_in(["runner", "hand"], []).size() == 5, "runner opening hand 5")
	_expect(int(state.get_in(["corp", "credit"], 0)) == 5, "corp starts with 5 credits")
	_expect(int(state.get_in(["runner", "credit"], 0)) == 5, "runner starts with 5 credits")

	_expect(NRProcessActions.process_action("start-turn", state, "corp"), "start-turn corp")
	_expect(int(state.get_in(["corp", "click"], 0)) == 3, "corp has 3 clicks")
	var hq_after_draw: int = state.get_in(["corp", "hand"], []).size()
	_expect(hq_after_draw == 6, "corp mandatory draw -> 6 HQ (got %d)" % hq_after_draw)

	var credits_before: int = int(state.get_in(["corp", "credit"], 0))
	_expect(NRProcessActions.process_action("credit", state, "corp"), "click-credit")
	_expect(int(state.get_in(["corp", "credit"], 0)) == credits_before + 1, "corp gained 1 credit")
	_expect(int(state.get_in(["corp", "click"], 0)) == 2, "corp spent 1 click on credit")

	var ice = _find_in_hand(state, "corp", "Wall of Static")
	if ice == null:
		ice = _move_from_deck_to_hand(state, "corp", "Wall of Static")
	_expect(ice != null, "corp has Wall of Static in HQ")
	if ice != null:
		_expect(NRProcessActions.process_action("play", state, "corp", {"card": ice, "server": "HQ"}), "install ice on HQ")
		var ices: Array = state.get_in(["corp", "servers", "hq", "ices"], [])
		_expect(ices.size() == 1, "HQ has 1 ice")
		_expect(int(state.get_in(["corp", "click"], 0)) == 1, "install spent a click")

	_expect(NRProcessActions.process_action("end-turn", state, "corp"), "end-turn corp")
	_expect(NRProcessActions.process_action("start-turn", state, "runner"), "start-turn runner")
	_expect(int(state.get_in(["runner", "click"], 0)) == 4, "runner has 4 clicks")

	var r_credits: int = int(state.get_in(["runner", "credit"], 0))
	_expect(NRProcessActions.process_action("credit", state, "runner"), "runner click-credit")
	_expect(int(state.get_in(["runner", "credit"], 0)) == r_credits + 1, "runner gained 1 credit")

	var program = _find_in_hand(state, "runner", "Corroder")
	if program == null:
		program = _move_from_deck_to_hand(state, "runner", "Corroder")
	if program != null:
		NRProcessActions.process_action("play", state, "runner", {"card": program})
		var installed: Array = state.get_in(["runner", "rig", "program"], [])
		print("runner programs installed: %d" % installed.size())

	_expect(NRProcessActions.process_action("run", state, "runner", {"server": "hq"}), "click-run HQ")
	_expect(state.getv("run") is Dictionary, "run is active")
	print("run phase after initiation: %s" % str(state.get_in(["run", "phase"], "")))

	for i in range(16):
		if not (state.getv("run") is Dictionary):
			break
		NRProcessActions.process_action("continue", state, "corp")
		NRProcessActions.process_action("continue", state, "runner")
		# Access trash prompt, if any.
		_auto_resolve_prompts(state)

	print("run after continues: %s" % str(state.getv("run")))
	print("HQ ices: %d" % state.get_in(["corp", "servers", "hq", "ices"], []).size())
	print("--- last log lines ---")
	print(NRSay.n_last_logs(state, 20))
	print("corp credits=%d clicks=%d  runner credits=%d clicks=%d" % [
		int(state.get_in(["corp", "credit"], 0)),
		int(state.get_in(["corp", "click"], 0)),
		int(state.get_in(["runner", "credit"], 0)),
		int(state.get_in(["runner", "click"], 0)),
	])

	if _ok:
		print("SMOKE TEST PASSED")
		get_tree().quit(0)
	else:
		print("SMOKE TEST FAILED:")
		for f in _failures:
			print("  - %s" % f)
		get_tree().quit(1)


func _register_stubs() -> void:
	NRCardDefs.defcard("Wall of Static", {
		"title": "Wall of Static",
		"type": "ICE",
		"side": "Corp",
		"faction": "Neutral",
		"cost": 3,
		"strength": 3,
		"keywords": "Barrier",
		"subtypes": ["Barrier"],
		"subroutines": [
			NRDefHelpers.end_the_run(),
		],
	})
	NRCardDefs.defcard("PAD Campaign", {
		"title": "PAD Campaign",
		"type": "Asset",
		"side": "Corp",
		"faction": "Neutral",
		"cost": 2,
		"trash": 4,
		"keywords": "Advertisement",
		"subtypes": ["Advertisement"],
	})
	NRCardDefs.defcard("Hedge Fund", {
		"title": "Hedge Fund",
		"type": "Operation",
		"side": "Corp",
		"faction": "Neutral",
		"cost": 5,
		"on-play": NRDefHelpers.gain_credits_ability(9),
	})
	NRCardDefs.defcard("Sure Gamble", {
		"title": "Sure Gamble",
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 5,
		"on-play": NRDefHelpers.gain_credits_ability(9),
	})
	NRCardDefs.defcard("Corroder", {
		"title": "Corroder",
		"type": "Program",
		"side": "Runner",
		"faction": "Anarch",
		"cost": 2,
		"memoryunits": 1,
		"strength": 2,
		"keywords": "Icebreaker - Fracter",
		"subtypes": ["Icebreaker", "Fracter"],
	})
	NRCardDefs.defcard("Easy Mark", {
		"title": "Easy Mark",
		"type": "Event",
		"side": "Runner",
		"faction": "Neutral",
		"cost": 0,
		"on-play": NRDefHelpers.gain_credits_ability(3),
	})


func _find_in_hand(state: NRState, side: String, title: String) -> Variant:
	for c in state.get_in([side, "hand"], []):
		if c is Dictionary and str(c.get("title")) == title:
			return c
	return null


func _move_from_deck_to_hand(state: NRState, side: String, title: String) -> Variant:
	var deck: Array = state.get_in([side, "deck"], [])
	for c in deck:
		if c is Dictionary and str(c.get("title")) == title:
			return NRMoving.move(state, side, c, "hand")
	return null


func _auto_resolve_prompts(state: NRState) -> void:
	for side in ["corp", "runner"]:
		var prompts: Array = state.get_in([side, "prompt"], [])
		if prompts.is_empty():
			continue
		var p: Dictionary = prompts[0]
		if NRUtil.kw_eq(p.get("prompt-type"), "waiting"):
			continue
		var choices = p.get("choices", [])
		var choice = "No"
		if choices is Array and not choices.is_empty():
			var first = choices[0]
			choice = first.get("value") if first is Dictionary else first
		NRProcessActions.process_action("choice", state, side, {"choice": choice})


func _expect(cond: bool, msg: String) -> void:
	if cond:
		print("  ok  %s" % msg)
	else:
		_ok = false
		_failures.append(msg)
		print("  FAIL %s" % msg)
