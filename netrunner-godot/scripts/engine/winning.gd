class_name NRWinning
extends RefCounted
## Win / lose / concede / flatline / decked. Port of game.core.winning.

static func win(state: NRState, side: Variant, reason: String) -> bool:
	if state.getv("winner") != null:
		return false
	var s := NRUtil.to_side(side)
	NRSay.system_msg(state, s, "wins the game")
	NRSay.play_sfx(state, s, "game-end")
	var now := NRUtil.make_timestamp()
	state.assoc_in(["stats", "time", "ended"], now)
	state.setv("winner", s)
	state.setv("loser", NRUtil.other_side(s))
	state.setv("winning-user", state.get_in([s, "user", "username"]))
	state.setv("losing-user", state.get_in([NRUtil.other_side(s), "user", "username"]))
	state.setv("losing-score", state.get_in([NRUtil.other_side(s), "agenda-point"]))
	state.setv("reason", reason)
	state.setv("end-time", now)
	state.setv("winning-deck-id", state.get_in([s, "deck-id"]))
	state.setv("losing-deck-id", state.get_in([NRUtil.other_side(s), "deck-id"]))
	return true


static func tie(state: NRState, reason: String) -> bool:
	if state.getv("winner") != null:
		return false
	NRSay.system_say(state, null, "The game is a tie!")
	NRSay.play_sfx(state, null, "game-end")
	var now := NRUtil.make_timestamp()
	state.assoc_in(["stats", "time", "ended"], now)
	state.setv("reason", reason)
	state.setv("end-time", now)
	return true


static func win_decked(state: NRState) -> bool:
	NRSay.system_msg(state, "corp", "is decked")
	return win(state, "runner", "Decked")


static func flatline(state: NRState) -> void:
	if state.getv("winner") != null:
		return
	state.setv("winner-declared", true)
	NRSay.system_msg(state, "runner", "is flatlined")
	win(state, "corp", "Flatline")


static func concede(state: NRState, side: Variant, _args: Variant = null) -> void:
	NRSay.system_msg(state, side, "concedes")
	win(state, NRUtil.other_side(side), "Concede")


static func clear_win(state: NRState, side: Variant) -> void:
	state.assoc_in([NRUtil.to_side(side), "clear-win"], true)
	if state.get_in(["runner", "clear-win"]) and state.get_in(["corp", "clear-win"]):
		NRSay.system_msg(state, side, "cleared the win condition")
		state.dissoc_in(["runner", "clear-win"])
		state.dissoc_in(["corp", "clear-win"])
		for k in ["winner", "loser", "winning-user", "losing-user", "reason", "winning-deck-id", "losing-deck-id", "end-time", "winner-declared"]:
			state.data.erase(k)


static func agenda_points_required_to_win(state: NRState, side: Variant) -> int:
	return int(state.get_in([NRUtil.to_side(side), "agenda-point-req"], 7)) + NREffects.sum_effects(state, side, "agenda-point-req")


static func side_win(state: NRState, side: Variant) -> bool:
	return agenda_points_required_to_win(state, side) <= int(state.get_in([NRUtil.to_side(side), "agenda-point"], 0))


static func check_win_by_agenda(state: NRState, _side: Variant = null) -> bool:
	var corp_win := side_win(state, "corp") and not NREffects.any_effects(state, "corp", "cannot-win-on-points")
	var runner_win := side_win(state, "runner") and not NREffects.any_effects(state, "runner", "cannot-win-on-points")
	if corp_win and runner_win:
		return tie(state, "Tie")
	if corp_win:
		return win(state, "corp", "Agenda")
	if runner_win:
		return win(state, "runner", "Agenda")
	return false
