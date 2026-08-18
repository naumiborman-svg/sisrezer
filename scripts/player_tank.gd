class_name PlayerTank
extends Tank


func _ready() -> void:
	team = 0
	move_speed = 96.0
	fire_cooldown = 0.38
	max_hp = 1
	hp = 1
	add_to_group("player")
	setup_visual(GameArt.player_tex)
	set_heading(Heading.UP)


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
	velocity = next * move_speed
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
