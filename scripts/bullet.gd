class_name Bullet
extends Area2D

var direction := Vector2.UP
var speed := 260.0
var power := 1
var team := 0
var owner_tank: Tank
var spent := false


func _init() -> void:
	collision_layer = 4
	collision_mask = 1 | 2 | 4 | 8
	monitoring = true
	monitorable = true


func setup(origin: Vector2, dir: Vector2, shooter: Tank, shot_speed: float, shot_power: int) -> void:
	global_position = origin
	direction = dir.normalized()
	owner_tank = shooter
	team = shooter.team
	speed = shot_speed
	power = shot_power
	rotation = dir.angle() + PI * 0.5
	var sprite := Sprite2D.new()
	sprite.texture = GameArt.bullet_tex
	add_child(sprite)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(6, 8)
	shape.shape = rect
	add_child(shape)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	tree_exited.connect(_notify_owner)


func _physics_process(delta: float) -> void:
	if spent:
		return
	global_position += direction * speed * delta
	if not Rect2(Vector2(-8, -8), Vector2(432, 432)).has_point(global_position):
		queue_free()


func _on_body_entered(body: Node) -> void:
	if spent:
		return
	if body == owner_tank:
		return
	if body is Tank:
		var tank := body as Tank
		if team == 1 and tank.team == 1:
			return
		if tank.take_hit(team, power):
			var game := get_tree().get_first_node_in_group("game")
			if tank is EnemyTank and game and game.has_method("on_power_tank_hit"):
				game.on_power_tank_hit(tank)
		_explode()
		return
	if body is MapTile:
		var tile := body as MapTile
		if tile.kind == MapTile.Kind.WATER or tile.kind == MapTile.Kind.ICE:
			return
		if tile.take_hit(power):
			GameArt.play(GameArt.sfx_brick, -8.0)
		else:
			GameArt.play(GameArt.sfx_steel, -10.0)
		_explode()
		return
	if body is Eagle:
		(body as Eagle).destroy()
		_explode()


func _on_area_entered(area: Area2D) -> void:
	if spent:
		return
	if area is Bullet:
		var other := area as Bullet
		if other.team != team:
			other._explode()
			_explode()


func _explode() -> void:
	if spent:
		return
	spent = true
	queue_free()


func _notify_owner() -> void:
	if owner_tank and is_instance_valid(owner_tank):
		owner_tank.bullet_freed()
