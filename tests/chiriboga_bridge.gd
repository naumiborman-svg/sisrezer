extends SceneTree


func _initialize() -> void:
	var client := ChiribogaClient.new()
	root.add_child(client)
	await process_frame
	var st: Dictionary = await client.status()
	if not bool(st.get("ok", false)):
		print("CHIRIBOGA_BRIDGE_SKIP %s" % st.get("error", client.last_error))
		quit(0)
		return
	var game: Dictionary = await client.new_game({"mode": "starter", "side": "runner", "ap": 6})
	if not bool(game.get("ok", false)) or str(game.get("id", "")) == "":
		push_error("new game failed: %s" % game.get("error", client.last_error))
		quit(1)
		return
	if int(game.get("runner", {}).get("hand_count", 0)) < 1:
		push_error("runner hand empty")
		quit(1)
		return
	var keep := _find_label(game, "Keep")
	if keep.is_empty():
		keep = _find_command(game, "m")
	if keep.is_empty():
		push_error("no Keep at mulligan")
		quit(1)
		return
	var after: Dictionary = await client.action(str(game["id"]), keep)
	if not after.has("actions"):
		push_error("keep lost state")
		quit(1)
		return
	var catalog: Dictionary = await client.catalog()
	if (catalog.get("precons", []) as Array).is_empty():
		push_error("catalog missing precons")
		quit(1)
		return
	print("CHIRIBOGA_BRIDGE_OK phase=%s actions=%s corp=%s runner=%s log=%s precons=%s" % [
		after.get("phase", ""),
		(after.get("actions", []) as Array).size(),
		after.get("corp", {}).get("credits", 0),
		after.get("runner", {}).get("credits", 0),
		(after.get("log", []) as Array).size(),
		(catalog.get("precons", []) as Array).size(),
	])
	quit(0)


func _find_label(state: Dictionary, label: String) -> Dictionary:
	for item: Variant in state.get("actions", []):
		if item is Dictionary and str(item.get("label", "")) == label:
			return item
	return {}


func _find_command(state: Dictionary, command: String) -> Dictionary:
	for item: Variant in state.get("actions", []):
		if item is Dictionary and str(item.get("command", "")) == command:
			return item
	return {}
