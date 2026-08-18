extends Node


func _ready() -> void:
	GameArt.setup()
	_bind("move_up", [KEY_W, KEY_UP])
	_bind("move_down", [KEY_S, KEY_DOWN])
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("fire", [KEY_SPACE, KEY_J])
	_bind("start", [KEY_ENTER, KEY_KP_ENTER])
	_bind("pause", [KEY_ESCAPE, KEY_P])


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode: int in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode as Key
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)
