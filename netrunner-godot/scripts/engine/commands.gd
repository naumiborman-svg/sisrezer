class_name NRCommands
extends RefCounted

## Port of game.core.commands — /slash commands used in playtesting.


static func command_parser(state: NRState, user: Dictionary, text: String) -> void:
	if not text.begins_with("/"):
		return
	var parts: PackedStringArray = text.substr(1).strip_edges().split(" ", false)
	if parts.is_empty():
		return
	var cmd: String = str(parts[0]).to_lower()
	var rest: String = " ".join(parts.slice(1)) if parts.size() > 1 else ""
	var side: String = NRUtil.to_side(user.get("side", state.getv("active-player", "corp")))
	match cmd:
		"credit", "c":
			NRChangeVals.change(state, side, {"key": "credit", "delta": int(rest) if rest.is_valid_int() else 1})
		"click":
			NRChangeVals.change(state, side, {"key": "click", "delta": int(rest) if rest.is_valid_int() else 1})
		"tag":
			NRChangeVals.change(state, side, {"key": "tag", "delta": int(rest) if rest.is_valid_int() else 1})
		"bp":
			NRChangeVals.change(state, side, {"key": "bad-publicity", "delta": int(rest) if rest.is_valid_int() else 1})
		"mu":
			NRChangeVals.change(state, side, {"key": "memory", "delta": int(rest) if rest.is_valid_int() else 1})
		"handsize":
			NRChangeVals.change(state, side, {"key": "hand-size", "delta": int(rest) if rest.is_valid_int() else 1})
		"close":
			NRPrompts.clear_wait_prompt(state, side)
		"draw":
			NRDrawing.draw(state, side, NREid.make_eid(state), int(rest) if rest.is_valid_int() else 1)
		"undo-click", "rfg", "discard", "rez", "trace", "psi":
			NRToasts.toast(state, side, "/%s is not implemented in this port" % cmd, "warning")
		_:
			NRToasts.toast(state, side, "Unknown command: /%s" % cmd, "error")
