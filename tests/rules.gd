extends SceneTree


func _initialize() -> void:
	GameArt.setup()
	_check_stage_book()
	_check_tiles()
	_check_tanks()
	await _check_match()
	print("RULES_OK")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _check_stage_book() -> void:
	if StageBook.COUNT != 35:
		_fail("expected 35 stages")
	var stage1 := StageBook.bot_queue(0)
	if stage1 != [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1]:
		_fail("stage 1 bot queue mismatch")
	if not StageBook.map_text(0).contains("EE"):
		_fail("stage 1 missing eagle")


func _check_tiles() -> void:
	var steel := MapTile.new()
	root.add_child(steel)
	steel.configure(MapTile.Kind.STEEL, GameArt.steel_tex)
	if steel.take_hit(1):
		_fail("steel should survive power 1")
	if not is_instance_valid(steel):
		_fail("steel was freed by weak shot")
	if not steel.take_hit(3):
		_fail("steel should fall to power 3")
	var ice := MapTile.new()
	root.add_child(ice)
	ice.configure(MapTile.Kind.ICE, GameArt.ice_tex)
	if ice.collision_layer != 0:
		_fail("ice should not block tanks")


func _check_tanks() -> void:
	var player := PlayerTank.new()
	root.add_child(player)
	player.apply_stars(0)
	if player.max_shots != 1 or player.bullet_power != 1:
		_fail("star 0 stats")
	player.apply_stars(2)
	if player.max_shots != 2:
		_fail("star 2 should double-shot")
	player.apply_stars(3)
	if player.bullet_power < 3:
		_fail("star 3 should break steel")
	var armor := EnemyTank.new()
	root.add_child(armor)
	armor.configure(EnemyTank.Kind.ARMOR, true)
	if armor.max_hp != 4 or not armor.with_power_up:
		_fail("armor flashing tank")


func _check_match() -> void:
	var main_ps := load("res://scenes/main.tscn") as PackedScene
	var main := main_ps.instantiate()
	root.add_child(main)
	await create_timer(0.3).timeout
	if main.stage != 1 or main.spawn_queue.size() != 19:
		_fail("stage 1 should spawn one of twenty")
	var lives_before: int = main.lives
	main.collect_power_up(PowerUp.Kind.LIFE)
	if main.lives != lives_before + 1:
		_fail("life pickup")
	main.collect_power_up(PowerUp.Kind.TIMER)
	if main.clock_left <= 0.0:
		_fail("clock pickup")
	main.collect_power_up(PowerUp.Kind.SHOVEL)
	if not main.shovel_active:
		_fail("shovel pickup")
	main.spawn_power_up()
	if main.active_pickup == null:
		_fail("power-up spawn")
	main.collect_power_up(PowerUp.Kind.GRENADE)
	await create_timer(0.1).timeout
	if not main.get_tree().get_nodes_in_group("enemies").is_empty():
		_fail("grenade should clear the field")
