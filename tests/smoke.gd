extends SceneTree


func _initialize() -> void:
	GameArt.setup()
	var title_ps := load("res://scenes/title.tscn") as PackedScene
	if title_ps == null:
		push_error("title.tscn failed to load")
		quit(1)
		return
	var main_ps := load("res://scenes/main.tscn") as PackedScene
	if main_ps == null:
		push_error("main.tscn failed to load")
		quit(1)
		return
	var main := main_ps.instantiate()
	root.add_child(main)
	await create_timer(1.4).timeout
	if not main.is_in_group("game"):
		push_error("main scene missing game group")
		quit(1)
		return
	if main.get_tree().get_nodes_in_group("player").is_empty():
		push_error("player missing")
		quit(1)
		return
	if main.get_tree().get_nodes_in_group("eagle").is_empty():
		push_error("eagle missing")
		quit(1)
		return
	if main.get_tree().get_nodes_in_group("enemies").is_empty():
		push_error("enemies missing")
		quit(1)
		return
	var has_map := false
	for child in main.get_children():
		if child.name == "World":
			for grand in child.get_children():
				if grand is MapBuilder:
					has_map = true
	if not has_map:
		push_error("map missing")
		quit(1)
		return
	print("SMOKE_OK")
	quit(0)
