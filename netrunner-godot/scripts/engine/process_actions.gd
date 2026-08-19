class_name NRProcessActions
extends RefCounted
## Command dispatch. Port of game.core.process_actions.

static var COMMANDS: Dictionary = {}


static func _ensure_commands() -> void:
	if not COMMANDS.is_empty():
		return
	COMMANDS = {
		"ability": func(st, sd, a): NRActions.play_ability(st, sd, a),
		"advance": func(st, sd, a): NRActions.click_advance(st, sd, a),
		"bad-pub-choice": func(st, sd, a): NRActions.resolve_bad_pub_choice(st, sd, a),
		"change": func(st, sd, a): NRChangeVals.change(st, sd, a),
		"choice": func(st, sd, a): NRActions.resolve_prompt(st, sd, a),
		"close-deck": func(st, sd, a): NRActions.close_deck(st, sd, a),
		"concede": func(st, sd, a): NRWinning.concede(st, sd, a),
		"continue": func(st, sd, a): NRRuns.continue_run(st, sd, a),
		"corp-ability": func(st, sd, a): NRActions.play_corp_ability(st, sd, a),
		"credit": func(st, sd, a): NRActions.click_credit(st, sd, a),
		"derez": func(st, sd, a): NRRezzing.derez(st, sd, NREid.make_eid(st), a.get("card", {}), {"no-event": true}),
		"draw": func(st, sd, a): NRActions.click_draw(st, sd, a),
		"dynamic-ability": func(st, sd, a): NRActions.play_dynamic_ability(st, sd, a),
		"end-phase-12": func(st, sd, a): NRTurns.end_phase_12(st, sd, a),
		"phase-12-pass-priority": func(st, sd, a): NRTurns.phase_12_pass_priority(st, sd, a),
		"start-next-phase": func(st, sd, a): NRRuns.start_next_phase(st, sd, a),
		"end-turn": func(st, sd, a): NRTurns.end_turn(st, sd, a),
		"post-discard-pass-priority": func(st, sd, a): NRTurns.post_discard_pass_priority(st, sd, a),
		"end-post-discard": func(st, sd, a): NRTurns.end_turn_continue(st, sd),
		"generate-install-list": func(st, sd, a): NRActions.generate_install_list(st, sd, a),
		"generate-runnable-zones": func(st, sd, a): NRActions.generate_runnable_zones(st, sd, a),
		"indicate-action": func(st, sd, a): NRSay.indicate_action(st, sd, a),
		"jack-out": func(st, sd, a): NRRuns.jack_out(st, sd, a),
		"keep": func(st, sd, a): NRSetUp.keep_hand(st, sd, a),
		"move": func(st, sd, a): NRActions.move_card(st, sd, a),
		"mulligan": func(st, sd, a): NRSetUp.mulligan(st, sd, a),
		"play": func(st, sd, a): NRActions.play(st, sd, a),
		"purge": func(st, sd, a): NRActions.do_purge(st, sd, a),
		"remove-tag": func(st, sd, a): NRActions.remove_tag(st, sd, a),
		"rez": func(st, sd, a): NRRezzing.rez(st, sd, NREid.make_eid(st), a.get("card", {}), NRUtil.dissoc(a, ["card"])),
		"run": func(st, sd, a): NRActions.click_run(st, sd, a),
		"runner-ability": func(st, sd, a): NRActions.play_runner_ability(st, sd, a),
		"score": func(st, sd, a): NRActions.score(st, sd, NREid.make_eid(st), NRCard.get_card(st, a.get("card")) if a.get("card") is Dictionary else {}, {}),
		"select": func(st, sd, a): NRActions.select(st, sd, a),
		"set-property": func(st, sd, a): set_property(st, sd, a),
		"shuffle": func(st, sd, a): NRShuffling.shuffle_deck(st, sd, a),
		"start-turn": func(st, sd, a): NRTurns.start_turn(st, sd, a),
		"subroutine": func(st, sd, a): NRActions.play_subroutine(st, sd, a),
		"system-msg": func(st, sd, a): NRSay.system_msg(st, sd, str(a.get("msg", ""))),
		"toast": func(st, sd, a): NRToasts.ack_toast(st, sd, a),
		"toggle-auto-no-action": func(st, sd, a): NRRuns.toggle_auto_no_action(st, sd, a),
		"trash": func(st, sd, a): NRActions.trash_button(st, sd, NREid.make_eid(st), NRCard.get_card(st, a.get("card")) if a.get("card") is Dictionary else {}),
		"trash-resource": func(st, sd, a): NRActions.trash_resource(st, sd, a),
		"unbroken-subroutines": func(st, sd, a): NRActions.play_unbroken_subroutines(st, sd, a),
		"view-deck": func(st, sd, a): NRActions.view_deck(st, sd, a),
		"expend": func(st, sd, a): NRExpend.expend_ability(st, sd, a),
		"flashback": func(st, sd, a): NRActions.play(st, sd, a),
	}


static func set_property(state: NRState, side: Variant, args: Dictionary) -> void:
	var key = args.get("key")
	var value = args.get("value")
	var acceptable := ["trash-like-cards", "auto-purge", "force-phase-12-self", "force-phase-12-opponent", "force-post-discard-self", "force-post-discard-opponent"]
	if str(key) in acceptable:
		state.assoc_in([NRUtil.to_side(side), "properties", key], value)


static func process_action(command: String, state: NRState, side: Variant, args: Dictionary = {}) -> bool:
	_ensure_commands()
	var cmd := NRUtil.to_kw(command)
	if not COMMANDS.has(cmd):
		return false
	COMMANDS[cmd].call(state, NRUtil.to_side(side), args)
	checkpoint_cleanup(state)
	return true


static func checkpoint_cleanup(state: NRState) -> void:
	NREngine.fake_checkpoint(state)
	if NRRuns.check_for_empty_server(state) or bool(state.get_in(["end-run", "ended"])):
		NRRuns.handle_end_run(state, "corp", NREid.make_eid(state))
		NREngine.fake_checkpoint(state)


static func command_parser(state: NRState, side: Variant, args: Dictionary) -> void:
	NRSay.say(state, side, args)
	NRCommands.command_parser(state, {"side": side}, str(args.get("text", "")))
