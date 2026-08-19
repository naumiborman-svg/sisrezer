extends SceneTree


func _initialize() -> void:
	var client := ClojureClient.new()
	root.add_child(client)
	await process_frame
	var st: Dictionary = await client.status()
	if not bool(st.get("ok", false)):
		print("CLOJURE_BRIDGE_SKIP %s" % st.get("error", client.last_error))
		quit(0)
		return
	var cards_n := int(st.get("cards", 0))
	if cards_n < 70:
		push_error("engine card count too low: %s" % cards_n)
		quit(1)
		return
	var game: Dictionary = await client.new_game(6)
	if not bool(game.get("ok", false)) or str(game.get("id", "")) == "":
		push_error("new game failed: %s" % game.get("error", client.last_error))
		quit(1)
		return
	var gid := str(game["id"])
	var before := int(game.get("corp", {}).get("credits", -1))
	var credit_act := _find_command(game, "credit", "corp")
	if credit_act.is_empty():
		push_error("no corp credit action at start")
		quit(1)
		return
	var after: Dictionary = await client.action(gid, credit_act)
	var credits := int(after.get("corp", {}).get("credits", -1))
	if credits != before + 1:
		push_error("credit did not apply: %s -> %s" % [before, credits])
		quit(1)
		return
	var play_act := _find_command(after, "play", "corp")
	if not play_act.is_empty():
		var played: Dictionary = await client.action(gid, play_act)
		if str(played.get("error", "")) != "":
			push_error("play failed: %s" % played["error"])
			quit(1)
			return
		after = played
	var steps := 0
	var cur := after
	while steps < 10 and str(cur.get("winner", "")) == "":
		var side := ClojureAi.actor(cur)
		var act := ClojureAi.pick(cur, side)
		if act.is_empty():
			break
		cur = await client.action(gid, act)
		steps += 1
	if not cur.has("actions"):
		push_error("loop lost game state")
		quit(1)
		return
	var start_state := {
		"active": "corp",
		"actions": [{"command": "start-turn", "side": "runner", "label": "Start Runner turn"}],
	}
	if ClojureAi.actor(start_state) != "runner":
		push_error("start-turn should pass priority to runner")
		quit(1)
		return
	print("CLOJURE_BRIDGE_OK cards=%s credits=%s steps=%s turn=%s log=%s" % [
		cards_n, credits, steps, cur.get("turn", 0), (cur.get("log", []) as Array).size()
	])
	quit(0)


func _find_command(state: Dictionary, command: String, side: String) -> Dictionary:
	for item: Variant in state.get("actions", []):
		if item is Dictionary and str(item.get("command", "")) == command and str(item.get("side", "")) == side:
			return item
	return {}
