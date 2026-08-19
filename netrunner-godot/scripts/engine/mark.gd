class_name NRMark
extends RefCounted

## Port of game.core.mark.


static func identify_mark(state: NRState) -> void:
	var options: Array = ["hq", "rd", "archives"]
	var remotes = NRBoard.get_remotes(state)
	if remotes is Dictionary:
		for k in remotes:
			options.append(k)
	elif remotes is Array:
		for s in remotes:
			if s is Dictionary and str(s.get("name", "")) != "":
				options.append(s.get("name"))
			elif s is String:
				options.append(s)
	if options.is_empty():
		return
	var pick: String = str(options[randi() % options.size()])
	state.setv("mark", pick)
	NRSay.system_say(state, null, "The mark is %s." % pick)


static func is_mark(state: NRState, server) -> bool:
	return str(state.getv("mark", "")) == str(NRServers.unknown_to_kw(server))
