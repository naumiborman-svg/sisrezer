extends Node2D

const PLAY_SIZE := 416
const MAX_ALIVE := 4

var stage := 1
var lives := 3
var score := 0
var ended := false
var paused := false
var spawn_queue: Array[int] = []
var spawn_points: Array[Vector2] = []
var player_spawn := Vector2(208, 384)
var eagle_pos := Vector2(208, 360)
var world: Node2D
var map: MapBuilder
var hud: HUD
var player: PlayerTank
var spawn_timer: Timer


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


func _stage_kinds(stage_index: int) -> Array[int]:
	match stage_index:
		0:
			return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2]
		1:
			return [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2]
		_:
			return [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 0, 0, 1, 2]


func start_stage(next_stage: int) -> void:
	ended = false
	paused = false
	get_tree().paused = false
	stage = next_stage
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
	spawn_queue = _stage_kinds(stage - 1)
	_spawn_player()
	spawn_timer.start()
	_spawn_enemy()
	_spawn_enemy()
	_refresh_hud()
	hud.show_banner("第 %d 关" % stage, "")
	get_tree().create_timer(1.1).timeout.connect(func() -> void:
		if not ended and not paused:
			hud.hide_banner()
	)


func _spawn_player() -> void:
	player = PlayerTank.new()
	player.position = player_spawn
	world.add_child(player)


func spawn_bullet(origin: Vector2, dir: Vector2, shooter: Tank) -> void:
	var bullet := Bullet.new()
	world.add_child(bullet)
	bullet.setup(origin, dir, shooter)


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
	var kind: int = spawn_queue.pop_front()
	var origin: Vector2 = spawn_points[randi() % spawn_points.size()]
	var enemy := EnemyTank.new()
	world.add_child(enemy)
	enemy.position = origin
	enemy.configure(kind as EnemyTank.Kind)
	_flash_spawn(origin)
	_refresh_hud()


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
	score += points
	_refresh_hud()
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


func _on_stage_cleared() -> void:
	if ended:
		return
	if stage >= 3:
		_finish(true)
		return
	hud.show_banner("关卡完成", "准备下一关")
	await get_tree().create_timer(1.6).timeout
	if ended:
		return
	start_stage(stage + 1)


func _finish(won: bool) -> void:
	if ended:
		return
	ended = true
	spawn_timer.stop()
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is Tank:
			(node as Tank).frozen = true
	if player:
		player.frozen = true
	if won:
		hud.show_banner("胜利", "按 Enter 返回标题  得分 %d" % score)
	else:
		hud.show_banner("失败", "按 Enter 返回标题  得分 %d" % score)


func _refresh_hud() -> void:
	hud.refresh(
		stage,
		lives,
		score,
		spawn_queue.size(),
		get_tree().get_nodes_in_group("enemies").size()
	)
