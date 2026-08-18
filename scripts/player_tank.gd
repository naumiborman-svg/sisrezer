class_name PlayerTank
extends Tank

var star_level := 0
var _slide := Vector2.ZERO


func _ready() -> void:
	team = 0
	add_to_group("player")
	apply_stars(0)
	set_heading(Heading.UP)
	grant_invincible(2.25)


func apply_stars(level: int) -> void:
	star_level = clampi(level, 0, 3)
	move_speed = 96.0
	max_hp = 1
	hp = 1
	match star_level:
		0:
			fire_cooldown = 0.3
			bullet_speed = 260.0
			bullet_power = 1
			max_shots = 1
			setup_visual(GameArt.player_tex)
		1:
			fire_cooldown = 0.2
			bullet_speed = 340.0
			bullet_power = 1
			max_shots = 1
			setup_visual(GameArt.player_star_tex)
		2:
			fire_cooldown = 0.2
			bullet_speed = 340.0
			bullet_power = 1
			max_shots = 2
			setup_visual(GameArt.player_star_tex)
		_:
			fire_cooldown = 0.2
			bullet_speed = 340.0
			bullet_power = 3
			max_shots = 2
			setup_visual(GameArt.player_star_tex)
			if sprite:
				sprite.modulate = Color(1.15, 1.15, 0.75)


func upgrade() -> void:
	if star_level >= 3:
		var game := get_tree().get_first_node_in_group("game")
		if game and game.has_method("add_score"):
			game.add_score(5000)
		return
	apply_stars(star_level + 1)


func _on_ice() -> bool:
	for node in get_tree().get_nodes_in_group("ice"):
		if node is Node2D and global_position.distance_to((node as Node2D).global_position) < 14.0:
			return true
	return false


func _physics_process(_delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		return
	var next := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		set_heading(Heading.UP)
		next = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		set_heading(Heading.DOWN)
		next = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		set_heading(Heading.LEFT)
		next = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		set_heading(Heading.RIGHT)
		next = Vector2.RIGHT
	if next != Vector2.ZERO:
		_slide = next
		velocity = next * move_speed
	elif _on_ice():
		velocity = _slide * move_speed
	else:
		velocity = Vector2.ZERO
		_slide = Vector2.ZERO
	move_and_slide()
	if Input.is_action_just_pressed("fire"):
		try_fire()


func die() -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game and game.has_method("spawn_explosion"):
		game.spawn_explosion(global_position)
	GameArt.play(GameArt.sfx_boom, -2.0)
	if game and game.has_method("on_player_destroyed"):
		game.on_player_destroyed()
	queue_free()
