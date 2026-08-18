class_name EnemyTank
extends Tank

enum Kind { BASIC, FAST, POWER, ARMOR }

var kind: Kind = Kind.BASIC
var with_power_up := false
var dropped_power_up := false
var _think := 0.0
var _player: PlayerTank


func configure(enemy_kind: Kind, drops_item: bool = false) -> void:
	kind = enemy_kind
	with_power_up = drops_item
	team = 1
	add_to_group("enemies")
	match kind:
		Kind.FAST:
			move_speed = 120.0
			fire_cooldown = 0.55
			bullet_speed = 340.0
			bullet_power = 1
			max_hp = 1
			setup_visual(GameArt.enemy_fast_tex)
		Kind.POWER:
			move_speed = 88.0
			fire_cooldown = 0.4
			bullet_speed = 400.0
			bullet_power = 2
			max_hp = 1
			setup_visual(GameArt.enemy_power_tex)
		Kind.ARMOR:
			move_speed = 80.0
			fire_cooldown = 0.55
			bullet_speed = 300.0
			bullet_power = 1
			max_hp = 4
			setup_visual(GameArt.enemy_armor_tex)
		_:
			move_speed = 64.0
			fire_cooldown = 0.65
			bullet_speed = 240.0
			bullet_power = 1
			max_hp = 1
			setup_visual(GameArt.enemy_basic_tex)
	hp = max_hp
	set_heading(Heading.DOWN)
	_think = randf_range(0.4, 1.4)
	if with_power_up:
		_flash_power()


func _flash_power() -> void:
	if sprite == null:
		return
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "modulate", Color(2.2, 1.6, 0.4), 0.12)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.12)


func take_hit(from_team: int, power: int = 1) -> bool:
	if from_team == team:
		return false
	if with_power_up and not dropped_power_up:
		dropped_power_up = true
		var game := get_tree().get_first_node_in_group("game")
		if game and game.has_method("spawn_power_up"):
			game.spawn_power_up()
	return super.take_hit(from_team, power)


func _physics_process(delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		return
	_player = get_tree().get_first_node_in_group("player") as PlayerTank
	_think -= delta
	if _think <= 0.0:
		_choose_heading()
		_think = randf_range(0.7, 1.8)
	if _can_see_player():
		_face_player()
		try_fire()
	elif randf() < 0.01:
		try_fire()
	var before := global_position
	velocity = heading_vector() * move_speed
	move_and_slide()
	if global_position.distance_to(before) < 0.2:
		_choose_heading()
		_think = randf_range(0.2, 0.6)


func _choose_heading() -> void:
	if _player and randf() < 0.28:
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
	if absf(delta.x) >= 10.0 and absf(delta.y) >= 10.0:
		return false
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, _player.global_position)
	query.collision_mask = 1 | 8
	query.exclude = [self]
	return space.intersect_ray(query).is_empty()


func score_value() -> int:
	match kind:
		Kind.FAST:
			return 200
		Kind.POWER:
			return 300
		Kind.ARMOR:
			return 400
		_:
			return 100


func die() -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("spawn_explosion"):
		game.spawn_explosion(global_position)
	GameArt.play(GameArt.sfx_boom, -2.0)
	if game and game.has_method("on_enemy_destroyed"):
		game.on_enemy_destroyed(score_value())
	queue_free()
