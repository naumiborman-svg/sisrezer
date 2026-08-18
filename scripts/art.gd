class_name GameArt
extends Object

const TILE := 16

static var player_tex: Texture2D
static var enemy_basic_tex: Texture2D
static var enemy_fast_tex: Texture2D
static var enemy_armor_tex: Texture2D
static var brick_tex: Texture2D
static var steel_tex: Texture2D
static var water_tex: Texture2D
static var bush_tex: Texture2D
static var eagle_tex: Texture2D
static var eagle_dead_tex: Texture2D
static var bullet_tex: Texture2D
static var spawn_tex: Texture2D
static var sfx_shoot: AudioStreamWAV
static var sfx_brick: AudioStreamWAV
static var sfx_steel: AudioStreamWAV
static var sfx_boom: AudioStreamWAV
static var sfx_power: AudioStreamWAV
static var _ready_done := false


static func setup() -> void:
	if _ready_done:
		return
	_ready_done = true
	player_tex = _tank(Color("3d8f3a"), Color("2a6b28"), Color("c8c86a"))
	enemy_basic_tex = _tank(Color("c8c2a0"), Color("8a8468"), Color("f0ead0"))
	enemy_fast_tex = _tank(Color("c44a3a"), Color("8a2a22"), Color("f0c070"))
	enemy_armor_tex = _tank(Color("4a6a9a"), Color("2a4068"), Color("d0d8e8"))
	brick_tex = _brick()
	steel_tex = _steel()
	water_tex = _water()
	bush_tex = _bush()
	eagle_tex = _eagle(false)
	eagle_dead_tex = _eagle(true)
	bullet_tex = _bullet()
	spawn_tex = _spawn()
	sfx_shoot = _beep(880.0, 0.05, 0.35)
	sfx_brick = _beep(180.0, 0.08, 0.4)
	sfx_steel = _beep(420.0, 0.04, 0.25)
	sfx_boom = _noise(0.18, 0.55)
	sfx_power = _beep(660.0, 0.12, 0.3)


static func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	tree.root.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


static func _px(img: Image, rect: Rect2i, color: Color) -> void:
	img.fill_rect(rect, color)


static func _tank(body: Color, cabin: Color, highlight: Color) -> Texture2D:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var tread := Color("1e1e18")
	var tread_hi := Color("3a3a30")
	_px(img, Rect2i(2, 3, 6, 26), tread)
	_px(img, Rect2i(24, 3, 6, 26), tread)
	for y in range(4, 28, 4):
		_px(img, Rect2i(3, y, 4, 2), tread_hi)
		_px(img, Rect2i(25, y, 4, 2), tread_hi)
	_px(img, Rect2i(8, 8, 16, 18), body)
	_px(img, Rect2i(9, 9, 14, 3), highlight)
	_px(img, Rect2i(10, 12, 12, 10), cabin)
	_px(img, Rect2i(14, 2, 4, 12), Color("2c2c24"))
	_px(img, Rect2i(15, 0, 2, 6), Color("4a4a3a"))
	_px(img, Rect2i(15, 14, 2, 4), highlight)
	return ImageTexture.create_from_image(img)


static func _brick() -> Texture2D:
	var img := Image.create(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color("6a2a18"))
	_px(img, Rect2i(0, 0, TILE, 1), Color("8a3c22"))
	_px(img, Rect2i(0, 7, TILE, 2), Color("3a160c"))
	_px(img, Rect2i(7, 0, 2, 7), Color("3a160c"))
	_px(img, Rect2i(3, 9, 2, 7), Color("3a160c"))
	_px(img, Rect2i(11, 9, 2, 7), Color("3a160c"))
	_px(img, Rect2i(1, 1, 5, 2), Color("c46838"))
	_px(img, Rect2i(10, 1, 5, 2), Color("c46838"))
	return ImageTexture.create_from_image(img)


static func _steel() -> Texture2D:
	var img := Image.create(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color("8c8c94"))
	_px(img, Rect2i(0, 0, TILE, 2), Color("d8d8e0"))
	_px(img, Rect2i(0, 0, 2, TILE), Color("d8d8e0"))
	_px(img, Rect2i(0, TILE - 2, TILE, 2), Color("3a3a44"))
	_px(img, Rect2i(TILE - 2, 0, 2, TILE), Color("3a3a44"))
	_px(img, Rect2i(5, 5, 6, 6), Color("b0b0ba"))
	return ImageTexture.create_from_image(img)


static func _water() -> Texture2D:
	var img := Image.create(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color("1a4a8c"))
	_px(img, Rect2i(0, 3, 10, 2), Color("2c6ab0"))
	_px(img, Rect2i(6, 8, 10, 2), Color("3a88cc"))
	_px(img, Rect2i(1, 12, 8, 2), Color("2c6ab0"))
	return ImageTexture.create_from_image(img)


static func _bush() -> Texture2D:
	var img := Image.create(TILE, TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var leaf_a := Color("1e7a28"); leaf_a.a = 0.92
	var leaf_b := Color("2a9a34"); leaf_b.a = 0.9
	var leaf_c := Color("166820"); leaf_c.a = 0.9
	var leaf_d := Color("28a038"); leaf_d.a = 0.88
	_px(img, Rect2i(2, 2, 5, 5), leaf_a)
	_px(img, Rect2i(8, 1, 6, 6), leaf_b)
	_px(img, Rect2i(1, 8, 7, 6), leaf_c)
	_px(img, Rect2i(9, 8, 5, 6), leaf_d)
	return ImageTexture.create_from_image(img)


static func _eagle(dead: bool) -> Texture2D:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	if dead:
		_px(img, Rect2i(6, 18, 20, 8), Color("3a2a22"))
		_px(img, Rect2i(10, 12, 4, 8), Color("5a4030"))
		_px(img, Rect2i(18, 10, 4, 10), Color("5a4030"))
		_px(img, Rect2i(12, 8, 8, 4), Color("8a3030"))
	else:
		_px(img, Rect2i(8, 20, 16, 8), Color("c9a227"))
		_px(img, Rect2i(12, 8, 8, 16), Color("e6c84a"))
		_px(img, Rect2i(6, 12, 6, 4), Color("e6c84a"))
		_px(img, Rect2i(20, 12, 6, 4), Color("e6c84a"))
		_px(img, Rect2i(14, 4, 4, 6), Color("f0e080"))
		_px(img, Rect2i(10, 14, 3, 3), Color("2a2a22"))
		_px(img, Rect2i(19, 14, 3, 3), Color("2a2a22"))
	return ImageTexture.create_from_image(img)


static func _bullet() -> Texture2D:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_px(img, Rect2i(2, 1, 4, 6), Color("f4f0c8"))
	_px(img, Rect2i(3, 0, 2, 8), Color("fff8d0"))
	return ImageTexture.create_from_image(img)


static func _spawn() -> Texture2D:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_px(img, Rect2i(4, 4, 24, 2), Color("d0a020"))
	_px(img, Rect2i(4, 26, 24, 2), Color("d0a020"))
	_px(img, Rect2i(4, 4, 2, 24), Color("d0a020"))
	_px(img, Rect2i(26, 4, 2, 24), Color("d0a020"))
	return ImageTexture.create_from_image(img)


static func _beep(freq: float, seconds: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count)
	for i in count:
		var t := float(i) / rate
		var env := 1.0 - float(i) / count
		var sample := int(sin(t * freq * TAU) * 127.0 * volume * env)
		data[i] = sample + 128
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream


static func _noise(seconds: float, volume: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in count:
		var env := 1.0 - float(i) / count
		var sample := int((rng.randf() * 2.0 - 1.0) * 127.0 * volume * env)
		data[i] = sample + 128
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = rate
	stream.data = data
	return stream
