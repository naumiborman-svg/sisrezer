class_name EnemyTank
extends Tank

enum Kind { BASIC, FAST, ARMOR }

var kind: Kind = Kind.BASIC
var _think := 0.0
var _player: PlayerTank


func configure(enemy_kind: Kind) -> void:
	kind = enemy_kind
	team = 1
	add_to_group("enemies")
	match kind:
		Kind.FAST:
			move_speed = 110.0
			fire_cooldown = 1.15
			max_hp = 1
			setup_visual(GameArt.enemy_fast_tex)
		Kind.ARMOR:
			move_speed = 58.0
			fire_cooldown = 1.45
			max_hp = 3
			setup_visual(GameArt.enemy_armor_tex)
		_:
			move_speed = 70.0
			fire_cooldown = 1.35
			max_hp = 1
			setup_visual(GameArt.enemy_basic_tex)
	hp = max_hp
	set_heading(Heading.DOWN)
	_think = randf_range(0.4, 1.4)


func _physics_process(delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		return
	_player = get_tree().get_first_node_in_group("player") as PlayerTank
	_think -= delta
	if _think <= 0.0:
		_choose_heading()
		_think = randf_range(0.8, 2.2)
	if _can_see_player() and global_position.distance_to(_player.global_position) < 180.0:
		_face_player()
		try_fire()
	elif randf() < 0.006:
		try_fire()
	var before := global_position
	velocity = heading_vector() * move_speed
	move_and_slide()
	if global_position.distance_to(before) < 0.2:
		_choose_heading()
		_think = randf_range(0.25, 0.7)


func _choose_heading() -> void:
	if _player and randf() < 0.22:
		_face_player()
		return
	set_heading(randi() % 4 as Heading)


func _face_player() -> void:
	if _player == null:
		return
	var delta := _player.global_position - global_position
	if absf(delta.x) > absf(delta.y):
		set_heading(Heading.RIGHT if delta.x > 0.0 else Heading.LEFT)
	else:
		set_heading(Heading.DOWN if delta.y > 0.0 else Heading.UP)


func _can_see_player() -> bool:
	if _player == null:
		return false
	var delta := _player.global_position - global_position
	var aligned := absf(delta.x) < 10.0 or absf(delta.y) < 10.0
	if not aligned:
		return false
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, _player.global_position)
	query.collision_mask = 1 | 8
	query.exclude = [self]
	var hit := space.intersect_ray(query)
	return hit.is_empty()


func die() -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("spawn_explosion"):
		game.spawn_explosion(global_position)
	GameArt.play(GameArt.sfx_boom, -2.0)
	var points := 100
	match kind:
		Kind.FAST:
			points = 200
		Kind.ARMOR:
			points = 300
	if game and game.has_method("on_enemy_destroyed"):
		game.on_enemy_destroyed(points)
	queue_free()
