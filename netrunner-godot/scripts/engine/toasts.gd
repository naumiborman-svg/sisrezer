class_name NRToasts
extends RefCounted
## Toast notifications. Port of game.core.toasts.

static func toast(state: NRState, side: Variant, message: String, msg_type: String = "warning", options: Dictionary = {}) -> void:
	if message == "":
		return
	var s = NRUtil.to_side(side)
	var toasts: Array = state.get_in([s, "toast"], [])
	toasts.append({"msg": message, "type": msg_type, "options": options, "id": NRUtil.make_uuid()})
	state.assoc_in([s, "toast"], toasts)


static func ack_toast(state: NRState, side: Variant, args: Dictionary) -> void:
	var id = args.get("id")
	var s = NRUtil.to_side(side)
	var toasts: Array = state.get_in([s, "toast"], [])
	var out: Array = []
	for t in toasts:
		if not (t is Dictionary) or t.get("id") != id:
			out.append(t)
	state.assoc_in([s, "toast"], out)


static func show_error_toast(state: NRState, side: Variant) -> void:
	toast(state, side, "Your last action caused a game error on the server. You can keep playing, but there may be errors in the game's current state.", "exception")
