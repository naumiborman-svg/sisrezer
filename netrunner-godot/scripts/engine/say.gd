class_name NRSay
extends RefCounted
## Logging / system messages. Port of game.core.say.

static func make_message(user: Variant, text: Variant, timestamp: Variant = null) -> Dictionary:
	if timestamp == null:
		timestamp = NRUtil.make_timestamp()
	var u = user
	if user is Dictionary and str(user) != "__system__":
		u = NRUtil.select_keys(user, ["username", "emailhash"])
	return {
		"user": u if u != null else "__system__",
		"text": str(text).strip_edges() if text is String else text,
		"timestamp": timestamp,
	}


static func make_system_message(text: String) -> Dictionary:
	return make_message("__system__", text)


static func select_pronoun(user: Dictionary) -> String:
	var key = str(NRUtil.get_in(user, ["options", "pronouns"], "their"))
	match key:
		"he":
			return "his"
		"she":
			return "her"
		"it":
			return "its"
		_:
			return "their"


static func insert_pronouns(state: NRState, side: Variant, text: String) -> String:
	var corp_p = select_pronoun(state.get_in(["corp", "user"], {}))
	var runner_p = select_pronoun(state.get_in(["runner", "user"], {}))
	var user_p = corp_p if NRUtil.to_side(side) == "corp" else (runner_p if NRUtil.to_side(side) == "runner" else "their")
	var t = text.replace("[pronoun]", user_p).replace("[their]", user_p)
	t = t.replace("[corp-pronoun]", corp_p).replace("[runner-pronoun]", runner_p)
	return t


static func append_log(state: NRState, message: Dictionary) -> void:
	var lg: Variant = state.getv("log", [])
	if not (lg is Array):
		lg = []
	lg.append(message)
	state.setv("log", lg)


static func log(state: NRState, message: Dictionary) -> void:
	append_log(state, message)


static func say(state: NRState, side: Variant, args: Dictionary, log_side: Variant = "public") -> void:
	var author = args.get("user", state.get_in([NRUtil.to_side(side), "user"]))
	var message = make_message(author, insert_pronouns(state, side, str(args.get("text", ""))))
	var packed = {}
	for s in NRUtil.as_array(log_side):
		packed[NRUtil.to_kw(s)] = message
	append_log(state, packed)


static func system_say(state: NRState, side: Variant, text: String, args: Dictionary = {}) -> void:
	var hr = NRUtil.truthy(args.get("hr", false))
	var log_side = args.get("log-side", "public")
	say(state, side, make_system_message(text + ("[hr]" if hr else "")), log_side)


static func system_msg(state: NRState, side: Variant, text: String, args: Dictionary = {}) -> void:
	var username = str(state.get_in([NRUtil.to_side(side), "user", "username"], NRUtil.side_str(side)))
	system_say(state, side, "%s %s." % [username, text], args)


static func multi_msg(state: NRState, side: Variant, message_map: Dictionary) -> void:
	var username = str(state.get_in([NRUtil.to_side(side), "user", "username"], NRUtil.side_str(side)))
	var packed = {}
	for k in message_map:
		packed[k] = make_system_message("%s %s." % [username, str(message_map[k])])
	append_log(state, packed)


static func enforce_msg(state: NRState, card: Dictionary, text: String) -> void:
	system_say(state, null, "%s %s." % [card.get("title", "Card"), text])


static func implementation_msg(state: NRState, card: Dictionary) -> void:
	var impl = card.get("implementation")
	if impl != null and not NRUtil.kw_eq(impl, "full"):
		system_say(state, null, "[!] %s - %s" % [card.get("title", ""), str(impl)])


static func indicate_action(state: NRState, side: Variant, _args: Variant = null) -> void:
	system_say(state, side, "[!] Please pause, %s is acting." % NRUtil.side_str(side))
	NRToasts.toast(state, side, "You have indicated action to your opponent", "info")
	NRToasts.toast(state, NRUtil.other_side(side), "Pause please, opponent is acting", "info")


static func play_sfx(state: NRState, _side: Variant, sfx: String) -> void:
	var current_id: int = int(state.getv("sfx-current-id", 0))
	var queue: Array = state.getv("sfx", [])
	queue.append({"id": current_id + 1, "name": sfx})
	if queue.size() > 3:
		queue = queue.slice(queue.size() - 3)
	state.setv("sfx", queue)
	state.setv("sfx-current-id", current_id + 1)


static func n_last_logs(state: NRState, n: int, side: String = "public") -> String:
	var texts: Array = []
	for entry in state.getv("log", []):
		var msg = entry
		if entry is Dictionary and entry.has(side):
			msg = entry[side]
		if msg is Dictionary and str(msg.get("user")) == "__system__":
			texts.append(str(msg.get("text", "")))
	if texts.size() > n:
		texts = texts.slice(texts.size() - n)
	return "\n\t".join(texts)
