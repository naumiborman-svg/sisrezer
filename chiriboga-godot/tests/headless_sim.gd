extends Node
## Headless simulation scene: Runner AI vs Corp AI.
## Run: godot --headless --path chiriboga-godot res://tests/headless_sim.tscn


func _ready() -> void:
	print("=== Chiriboga headless sim ===")
	var failed := 0
	failed += _run_seed(42)
	failed += _run_seed(7)
	failed += _run_seed(99)
	if failed > 0:
		print("FAILURES: ", failed)
		get_tree().quit(1)
	else:
		print("All simulations completed without engine errors.")
		get_tree().quit(0)


func _run_seed(seed: int) -> int:
	print("\n-- seed %d --" % seed)
	var gs := GameState.new()
	gs.start_new_game({"runner_ai": true, "corp_ai": true, "seed": seed, "ap": 7})
	var steps := 0
	var stuck := 0
	var last_log := gs.log_lines.size()
	while not gs.is_over() and steps < 1800:
		var acts := gs.legal_actions()
		gs.ai_tick()
		steps += 1
		if gs.log_lines.size() == last_log:
			stuck += 1
		else:
			stuck = 0
			last_log = gs.log_lines.size()
		if stuck > 40:
			print("STUCK phase=", gs.phase_name(), " pending=", gs._pending_kind, " acts=", acts.size())
			for a in acts:
				print("  action: ", a.get("label"))
			print("Runner $", gs.runner.credits, " clicks ", gs.runner.clicks, " grip ", gs.runner.grip.size())
			print("Corp $", gs.corp.credits, " clicks ", gs.corp.clicks, " HQ ", gs.hq.cards.size())
			return 1
	print("steps=", steps, " over=", gs.is_over(), " winner=", gs.winner, " reason=", gs.win_reason)
	print("AP runner=", gs.runner.scored_points(), " corp=", gs.corp.scored_points(), " tags=", gs.runner.tags)
	print("turn=", gs.turn_number, " runner credits=", gs.runner.credits, " corp credits=", gs.corp.credits)
	print("log_lines=", gs.log_lines.size())
	if gs.log_lines.size() < 8:
		print("Sim produced too little activity.")
		return 1
	if not gs.is_over() and steps >= 1800:
		print("Reached step cap (game still in progress — acceptable).")
	return 0
