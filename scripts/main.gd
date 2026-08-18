extends Node2D

const PLAY_SIZE := 416
const MAX_ALIVE := 4
const STAGE_COUNT := 35
const FLASH_SPAWNS := [3, 10, 17]
const CLOCK_TIME := 10.0
const SHOVEL_TIME := 18.0
const HELMET_TIME := 10.5

var stage := 1
var lives := 3
var score := 0
var next_life := 20000
var ended := false
var paused := false
var spawn_queue: Array[int] = []
var spawn_points: Array[Vector2] = []
var spawn_cursor := 0
var spawned_count := 0
var player_spawn := Vector2(208, 384)
var eagle_pos := Vector2(208, 360)
var world: Node2D
var map: MapBuilder
var hud: HUD
var player: PlayerTank
var spawn_timer: Timer
var clock_left := 0.0
var shovel_left := 0.0
var shovel_active := false
var active_pickup: PowerUp


func _ready() -> void:
	GameArt.setup()
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game")
	randomize()
	_draw_ground()
	world = Node2D.new()
	world.name = "World"
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	hud = HUD.new()
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.4
	spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	spawn_timer.timeout.connect(_spawn_enemy)
	add_child(spawn_timer)
	start_stage(1)


func _draw_ground() -> void:
	var ground := ColorRect.new()
	ground.color = Color("0d0d10")
	ground.size = Vector2(PLAY_SIZE, PLAY_SIZE)
	ground.z_index = -10
	add_child(ground)
	var frame := ColorRect.new()
	frame.color = Color("2a2a30")
	frame.position = Vector2(-4, -4)
	frame.size = Vector2(PLAY_SIZE + 8, PLAY_SIZE + 8)
	frame.z_index = -11
	add_child(frame)


func _process(delta: float) -> void:
	if paused or ended:
		return
	if clock_left > 0.0:
		clock_left = maxf(clock_left - delta, 0.0)
		if clock_left <= 0.0:
			_set_enemies_frozen(false)
	if shovel_left > 0.0:
		shovel_left = maxf(shovel_left - delta, 0.0)
		if shovel_left <= 0.0 and shovel_active:
			shovel_active = false
			if map:
				map.restore_fortress()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not ended:
		paused = not paused
		get_tree().paused = paused
		if paused:
			hud.show_banner("暂停", "按 P 继续")
		else:
			hud.hide_banner()
		return
	if ended and event.is_action_pressed("start"):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/title.tscn")


func start_stage(next_stage: int) -> void:
	ended = false
	paused = false
	get_tree().paused = false
	stage = next_stage
	clock_left = 0.0
	shovel_left = 0.0
	shovel_active = false
	active_pickup = null
	spawned_count = 0
	spawn_cursor = 0
	hud.hide_banner()
	for child in world.get_children():
		child.queue_free()
	map = MapBuilder.new()
	map.name = "MapBuilder"
	world.add_child(map)
	var built: Dictionary = map.build(stage - 1)
	player_spawn = built["player"]
	spawn_points.clear()
	for p in built["spawns"]:
		spawn_points.append(p)
	eagle_pos = built["eagle"]
	var eagle := Eagle.new()
	eagle.position = eagle_pos
	world.add_child(eagle)
	spawn_queue = StageBook.bot_queue(stage - 1)
	_spawn_player()
	spawn_timer.start()
	_spawn_enemy()
	_refresh_hud()
	hud.show_banner("第 %02d 关" % stage, "")
	get_tree().create_timer(1.1).timeout.connect(func() -> void:
		if not ended and not paused:
			hud.hide_banner()
	)


func _spawn_player() -> void:
	player = PlayerTank.new()
	player.position = player_spawn
	world.add_child(player)


func spawn_bullet(origin: Vector2, dir: Vector2, shooter: Tank, shot_speed: float = 260.0, shot_power: int = 1) -> void:
	var bullet := Bullet.new()
	world.add_child(bullet)
	bullet.setup(origin, dir, shooter, shot_speed, shot_power)


func spawn_explosion(origin: Vector2) -> void:
	var boom := Explosion.new()
	boom.position = origin
	world.add_child(boom)


func _spawn_enemy() -> void:
	if ended or spawn_queue.is_empty():
		return
	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ALIVE:
		return
	if spawn_points.is_empty():
		return
	var origin := _next_spawn_point()
	if origin == Vector2.INF:
		return
	var kind: int = spawn_queue.pop_front()
	var drops := spawned_count in FLASH_SPAWNS
	var enemy := EnemyTank.new()
	world.add_child(enemy)
	enemy.position = origin
	enemy.configure(kind as EnemyTank.Kind, drops)
	if clock_left > 0.0:
		enemy.frozen = true
	spawned_count += 1
	_flash_spawn(origin)
	_refresh_hud()


func _next_spawn_point() -> Vector2:
	for _i in spawn_points.size():
		var origin: Vector2 = spawn_points[spawn_cursor]
		spawn_cursor = (spawn_cursor + 1) % spawn_points.size()
		if not _spawn_blocked(origin):
			return origin
	return Vector2.INF


func _spawn_blocked(pos: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D and (node as Node2D).global_position.distance_to(pos) < 28.0:
			return true
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is Node2D and (node as Node2D).global_position.distance_to(pos) < 28.0:
			return true
	return false


func _flash_spawn(origin: Vector2) -> void:
	var marker := Sprite2D.new()
	marker.texture = GameArt.spawn_tex
	marker.position = origin
	world.add_child(marker)
	var tw := create_tween()
	tw.tween_property(marker, "modulate:a", 0.0, 0.45)
	tw.tween_callback(marker.queue_free)


func on_enemy_destroyed(points: int) -> void:
	if ended:
		return
	add_score(points)
	await get_tree().process_frame
	if spawn_queue.is_empty() and get_tree().get_nodes_in_group("enemies").is_empty():
		_on_stage_cleared()


func on_player_destroyed() -> void:
	if ended:
		return
	lives -= 1
	player = null
	_refresh_hud()
	if lives <= 0:
		_finish(false)
		return
	await get_tree().create_timer(1.0).timeout
	if ended:
		return
	_spawn_player()


func on_eagle_destroyed() -> void:
	_finish(false)


func on_power_tank_hit(_tank: EnemyTank) -> void:
	pass


func spawn_power_up() -> void:
	if ended:
		return
	if active_pickup and is_instance_valid(active_pickup):
		active_pickup.queue_free()
	var drop := PowerUp.new()
	world.add_child(drop)
	drop.position = _random_item_cell()
	drop.configure((randi() % 6) as PowerUp.Kind)
	drop.tree_exited.connect(func() -> void:
		if active_pickup == drop:
			active_pickup = null
	, CONNECT_ONE_SHOT)
	active_pickup = drop


func collect_power_up(kind: int) -> void:
	add_score(500)
	GameArt.play(GameArt.sfx_power, -2.0)
	match kind:
		PowerUp.Kind.LIFE:
			lives += 1
			_refresh_hud()
		PowerUp.Kind.STAR:
			if player:
				player.upgrade()
		PowerUp.Kind.GRENADE:
			_grenade()
		PowerUp.Kind.TIMER:
			clock_left = CLOCK_TIME
			_set_enemies_frozen(true)
		PowerUp.Kind.HELMET:
			if player:
				player.grant_invincible(HELMET_TIME)
		PowerUp.Kind.SHOVEL:
			shovel_left = SHOVEL_TIME
			shovel_active = true
			if map:
				map.steel_fortress()


func add_score(amount: int) -> void:
	score += amount
	while score >= next_life:
		lives += 1
		next_life += 20000
		GameArt.play(GameArt.sfx_power, -1.0)
	_refresh_hud()


func _grenade() -> void:
	var victims: Array[EnemyTank] = []
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is EnemyTank:
			victims.append(node)
	for enemy in victims:
		if is_instance_valid(enemy):
			enemy.die()


func _set_enemies_frozen(value: bool) -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is Tank:
			(node as Tank).frozen = value


func _random_item_cell() -> Vector2:
	for _i in 48:
		var pos := Vector2(float(randi_range(1, 24) * 16 + 8), float(randi_range(1, 24) * 16 + 8))
		if pos.distance_to(eagle_pos) < 36.0:
			continue
		if pos.distance_to(player_spawn) < 28.0:
			continue
		if _item_blocked(pos):
			continue
		return pos
	return Vector2(208, 208)


func _item_blocked(pos: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 | 8 | 16
	return not space.intersect_point(query, 1).is_empty()


func _on_stage_cleared() -> void:
	if ended:
		return
	if stage >= STAGE_COUNT:
		_finish(true)
		return
	hud.show_banner("关卡完成", "准备第 %02d 关" % (stage + 1))
	await get_tree().create_timer(1.6).timeout
	if ended:
		return
	start_stage(stage + 1)


func _finish(won: bool) -> void:
	if ended:
		return
	ended = true
	spawn_timer.stop()
	_set_enemies_frozen(true)
	if player:
		player.frozen = true
	if won:
		hud.show_banner("全关卡完成", "按 Enter 返回标题  得分 %d" % score)
	else:
		hud.show_banner("失败", "按 Enter 返回标题  得分 %d" % score)


func _refresh_hud() -> void:
	var enemy_count := 0
	if is_inside_tree():
		enemy_count = get_tree().get_nodes_in_group("enemies").size()
	hud.refresh(stage, lives, score, spawn_queue.size(), enemy_count)
