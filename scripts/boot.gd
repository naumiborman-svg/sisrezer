extends Node


func _ready() -> void:
	_bind("ui_confirm", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE])
	_bind("ui_cancel", [KEY_ESCAPE])


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode: int in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode as Key
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)
