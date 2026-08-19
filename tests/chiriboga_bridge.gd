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
	var gain := _find_label(after, "Gain")
	if gain.is_empty():
		gain = _find_command(after, "gain")
	if gain.is_empty():
		push_error("no Gain after keep (phase=%s actions=%s)" % [after.get("phase", ""), after.get("actions", [])])
		quit(1)
		return
	after = await client.action(str(game["id"]), gain)
	if int(after.get("runner", {}).get("credits", 0)) < 6:
		push_error("gain did not add a credit")
		quit(1)
		return
	var catalog: Dictionary = await client.catalog()
	if (catalog.get("precons", []) as Array).is_empty():
		push_error("catalog missing precons")
		quit(1)
		return
	var hub: Dictionary = await client.gauntlet_new({"length": 4, "seed": "godot-test"})
	if not bool(hub.get("ok", false)) or str(hub.get("id", "")) == "":
		push_error("gauntlet new failed: %s" % hub.get("error", client.last_error))
		quit(1)
		return
	if int(hub.get("credits", 0)) != 30:
		push_error("gauntlet starting credits %s" % hub.get("credits", 0))
		quit(1)
		return
	if (hub.get("shop", {}).get("packs", []) as Array).size() != 3:
		push_error("gauntlet shop packs missing")
		quit(1)
		return
	if (hub.get("opponents", []) as Array).size() != 4:
		push_error("gauntlet opponents %s" % (hub.get("opponents", []) as Array).size())
		quit(1)
		return
	var before := int(hub.get("credits", 0))
	var bought: Dictionary = await client.gauntlet_action(str(hub["id"]), {"action": "buy", "index": 0})
	if int(bought.get("credits", before)) >= before:
		push_error("buy pack did not spend credits")
		quit(1)
		return
	if (bought.get("last_pack", []) as Array).is_empty():
		push_error("buy pack produced no cards")
		quit(1)
		return
	var fight: Dictionary = await client.new_game({
		"mode": "gauntlet",
		"campaign_id": str(hub["id"]),
		"opponent_index": 0,
		"side": "runner",
	})
	if not bool(fight.get("ok", false)) or str(fight.get("id", "")) == "":
		push_error("gauntlet fight failed: %s" % fight.get("error", client.last_error))
		quit(1)
		return
	print("CHIRIBOGA_BRIDGE_OK phase=%s actions=%s corp=%s runner=%s log=%s precons=%s gauntlet_credits=%s packs=%s opponents=%s fight_id=%s" % [
		after.get("phase", ""),
		(after.get("actions", []) as Array).size(),
		after.get("corp", {}).get("credits", 0),
		after.get("runner", {}).get("credits", 0),
		(after.get("log", []) as Array).size(),
		(catalog.get("precons", []) as Array).size(),
		bought.get("credits", 0),
		(bought.get("shop", {}).get("packs", []) as Array).size(),
		(bought.get("opponents", []) as Array).size(),
		fight.get("id", ""),
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
