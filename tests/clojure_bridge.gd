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
	var catalog: Dictionary = await client.catalog()
	var matchups: Array = catalog.get("matchups", [])
	if matchups.is_empty():
		push_error("catalog missing matchups")
		quit(1)
		return
	var keys: PackedStringArray = PackedStringArray()
	for item: Variant in matchups:
		if item is Dictionary:
			keys.append(str(item.get("key", "")))
	if not keys.has("beginner") or not keys.has("worlds-2012-a"):
		push_error("catalog missing official matchups: %s" % ", ".join(keys))
		quit(1)
		return
	var beginner: Dictionary = await client.new_game({"mode": "beginner", "side": "runner"})
	if int(beginner.get("corp", {}).get("agenda_point_req", 0)) != 6:
		push_error("beginner agenda goal should be 6, got %s" % beginner.get("corp", {}).get("agenda_point_req", beginner.get("error")))
		quit(1)
		return
	var worlds: Dictionary = await client.new_game({"mode": "precon", "matchup": "worlds-2012-a", "side": "runner"})
	if not bool(worlds.get("ok", false)) or str(worlds.get("id", "")) == "":
		push_error("worlds matchup failed: %s" % worlds.get("error", client.last_error))
		quit(1)
		return
	if str(worlds.get("matchup", "")) != "worlds-2012-a":
		push_error("expected worlds-2012-a, got %s" % worlds.get("matchup"))
		quit(1)
		return
	print("CLOJURE_BRIDGE_OK cards=%s credits=%s steps=%s turn=%s log=%s matchups=%s worlds=%s" % [
		cards_n, credits, steps, cur.get("turn", 0), (cur.get("log", []) as Array).size(),
		matchups.size(), worlds.get("matchup_label", ""),
	])
	quit(0)


func _find_command(state: Dictionary, command: String, side: String) -> Dictionary:
	for item: Variant in state.get("actions", []):
		if item is Dictionary and str(item.get("command", "")) == command and str(item.get("side", "")) == side:
			return item
	return {}
