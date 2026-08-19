extends RefCounted
## Card definitions. Data-driven: add a Dictionary in `_register()` to ship a new card.
## Effect keys are interpreted by GameState — no per-card GDScript subclasses required.

var defs: Dictionary = {}


func _init() -> void:
	if defs.is_empty():
		_register()
		print("CardLibrary: %d cards loaded" % defs.size())


func get_def(id: int) -> Dictionary:
	if defs.has(id):
		return defs[id]
	push_error("Unknown card id %s" % id)
	return {"id": id, "title": "Unknown", "type": "event", "side": "runner", "cost": 0, "text": ""}


func has_def(id: int) -> bool:
	return defs.has(id)


func _add(d: Dictionary) -> void:
	defs[int(d.id)] = d


func _register() -> void:
	_register_runner()
	_register_corp()
	_register_extra()


func _register_runner() -> void:
	_add({
		"id": 30076,
		"title": "The Catalyst: Convention Breaker",
		"type": "identity",
		"side": "runner",
		"faction": "Neutral",
		"subtypes": ["Natural"],
		"deck_size": 30,
		"influence_limit": 9001,
		"link": 0,
		"text": "Starter identity. (Chiriboga / System Gateway tutorial.)",
	})
	_add({
		"id": 30030,
		"title": "Sure Gamble",
		"type": "event",
		"side": "runner",
		"faction": "Neutral",
		"influence": 0,
		"cost": 5,
		"text": "Gain 9[credit].",
		"on_play": [{"op": "gain_credits", "who": "runner", "n": 9}],
	})
	_add({
		"id": 30020,
		"title": "Creative Commission",
		"type": "event",
		"side": "runner",
		"faction": "Shaper",
		"influence": 2,
		"cost": 1,
		"text": "Gain 5[credit]. If you have any [click] remaining, lose [click].",
		"on_play": [{"op": "gain_credits", "who": "runner", "n": 5}, {"op": "lose_click_if_any"}],
	})
	_add({
		"id": 30021,
		"title": "VRcation",
		"type": "event",
		"side": "runner",
		"faction": "Shaper",
		"influence": 2,
		"cost": 1,
		"text": "Draw 4 cards. If you have any [click] remaining, lose [click].",
		"on_play": [{"op": "draw", "who": "runner", "n": 4}, {"op": "lose_click_if_any"}],
	})
	_add({
		"id": 30002,
		"title": "Wildcat Strike",
		"type": "event",
		"side": "runner",
		"faction": "Anarch",
		"influence": 1,
		"cost": 2,
		"text": "Resolve 1 of the following of the Corp's choice: Gain 6[credit] or Draw 4 cards.",
		"on_play": [{"op": "wildcat"}],
	})
	_add({
		"id": 30028,
		"title": "Jailbreak",
		"type": "event",
		"side": "runner",
		"faction": "Neutral",
		"influence": 0,
		"cost": 0,
		"subtypes": ["Run"],
		"text": "Run HQ or R&D. If successful, draw 1 card and when you breach the attacked server, access 1 additional card.",
		"run_targets": ["HQ", "R&D"],
		"on_successful_run": [{"op": "draw", "who": "runner", "n": 1}],
		"extra_access": 1,
	})
	_add({
		"id": 30029,
		"title": "Overclock",
		"type": "event",
		"side": "runner",
		"faction": "Neutral",
		"influence": 0,
		"cost": 1,
		"subtypes": ["Run"],
		"text": "Place 5[credit] on this event, then run any server. You can spend hosted credits during that run.",
		"run_targets": ["any"],
		"run_hosted_credits": 5,
	})
	_add({
		"id": 30012,
		"title": "Tread Lightly",
		"type": "event",
		"side": "runner",
		"faction": "Criminal",
		"influence": 1,
		"cost": 1,
		"subtypes": ["Run"],
		"text": "Run any server. During that run, the rez cost of each piece of ice is increased by 3[credit].",
		"run_targets": ["any"],
		"ice_rez_surcharge": 3,
	})
	_add({
		"id": 30006,
		"title": "Cleaver",
		"type": "program",
		"side": "runner",
		"faction": "Anarch",
		"influence": 2,
		"cost": 3,
		"memory_cost": 1,
		"strength": 3,
		"subtypes": ["Icebreaker", "Fracter"],
		"text": "Interface → 1[credit]: Break up to 2 barrier subroutines. 2[credit]: +1 strength.",
		"breaker": {"breaks": "Barrier", "break_cost": 1, "break_n": 2, "boost_cost": 2, "boost_n": 1},
	})
	_add({
		"id": 30015,
		"title": "Carmen",
		"type": "program",
		"side": "runner",
		"faction": "Criminal",
		"influence": 2,
		"cost": 5,
		"memory_cost": 1,
		"strength": 2,
		"subtypes": ["Icebreaker", "Killer"],
		"text": "If you made a successful run this turn, this program costs 2[credit] less to install. Interface → 1[credit]: Break 1 sentry subroutine. 2[credit]: +3 strength.",
		"install_discount_after_success": 2,
		"breaker": {"breaks": "Sentry", "break_cost": 1, "break_n": 1, "boost_cost": 2, "boost_n": 3},
	})
	_add({
		"id": 30026,
		"title": "Unity",
		"type": "program",
		"side": "runner",
		"faction": "Shaper",
		"influence": 2,
		"cost": 3,
		"memory_cost": 1,
		"strength": 1,
		"subtypes": ["Icebreaker", "Decoder"],
		"text": "Interface → 1[credit]: Break 1 code gate subroutine. 1[credit]: +X strength. X is the number of installed icebreakers (including this one).",
		"breaker": {"breaks": "Code Gate", "break_cost": 1, "break_n": 1, "boost_cost": 1, "boost_n": 1, "boost_per_breaker": true},
	})
	_add({
		"id": 30032,
		"title": "Mayfly",
		"type": "program",
		"side": "runner",
		"faction": "Neutral",
		"influence": 0,
		"cost": 1,
		"memory_cost": 2,
		"strength": 1,
		"subtypes": ["Icebreaker", "AI"],
		"text": "Interface → 1[credit]: Break 1 subroutine. When this run ends, trash this program. 1[credit]: +1 strength.",
		"breaker": {"breaks": "any", "break_cost": 1, "break_n": 1, "boost_cost": 1, "boost_n": 1},
		"trash_at_run_end_if_used": true,
	})
	_add({
		"id": 30014,
		"title": "Pennyshaver",
		"type": "hardware",
		"side": "runner",
		"faction": "Criminal",
		"influence": 3,
		"cost": 3,
		"unique": true,
		"memory_units": 1,
		"subtypes": ["Console"],
		"text": "+1[mu]. Whenever you make a successful run, place 1[credit] on this hardware. [click]: Place 1[credit] on this hardware, then take all credits from it. Limit 1 console per player.",
		"on_successful_run": [{"op": "place_credits", "n": 1}],
		"abilities": [{
			"text": "[click]: Place 1[credit], then take all credits.",
			"click_cost": 1,
			"ops": [{"op": "place_credits", "n": 1}, {"op": "take_all_credits"}],
		}],
	})
	_add({
		"id": 30013,
		"title": "Docklands Pass",
		"type": "hardware",
		"side": "runner",
		"faction": "Criminal",
		"influence": 2,
		"cost": 2,
		"unique": true,
		"text": "The first time each turn you breach HQ, access 1 additional card.",
		"first_hq_extra_access": 1,
	})
	_add({
		"id": 30027,
		"title": "Telework Contract",
		"type": "resource",
		"side": "runner",
		"faction": "Shaper",
		"influence": 2,
		"cost": 1,
		"subtypes": ["Job"],
		"text": "When you install this resource, load 9[credit] onto it. When it is empty, trash it. Once per turn → [click]: Take 3[credit] from this resource.",
		"on_install": [{"op": "load_credits", "n": 9}],
		"abilities": [{
			"text": "[click]: Take 3[credit] from this resource.",
			"click_cost": 1,
			"once_per_turn": true,
			"take_hosted": 3,
			"ops": [{"op": "take_credits", "n": 3}, {"op": "trash_if_empty"}],
		}],
	})
	_add({
		"id": 30033,
		"title": "Smartware Distributor",
		"type": "resource",
		"side": "runner",
		"faction": "Neutral",
		"influence": 0,
		"cost": 0,
		"subtypes": ["Connection"],
		"text": "[click]: Place 3[credit] on this resource. When your turn begins, take 1[credit] from this resource.",
		"on_runner_turn_begins": [{"op": "take_credits", "n": 1, "if_has": 1}],
		"abilities": [{
			"text": "[click]: Place 3[credit] on this resource.",
			"click_cost": 1,
			"ops": [{"op": "place_credits", "n": 3}],
		}],
	})
	_add({
		"id": 30034,
		"title": "Verbal Plasticity",
		"type": "resource",
		"side": "runner",
		"faction": "Neutral",
		"influence": 0,
		"cost": 3,
		"unique": true,
		"subtypes": ["Genetics"],
		"text": "The first time each turn you take the basic action to draw 1 card, instead draw 2 cards.",
		"double_first_basic_draw": true,
	})
	_add({
		"id": 30018,
		"title": "Red Team",
		"type": "resource",
		"side": "runner",
		"faction": "Criminal",
		"influence": 2,
		"cost": 5,
		"subtypes": ["Job"],
		"text": "When you install this resource, load 12[credit] onto it. When it is empty, trash it. [click]: Run a central server you have not run this turn. If successful, take 3[credit] from this resource.",
		"on_install": [{"op": "load_credits", "n": 12}],
		"abilities": [{
			"text": "[click]: Run a central you have not run this turn.",
			"click_cost": 1,
			"run_unrun_central": true,
			"on_success_take": 3,
		}],
	})


func _register_corp() -> void:
	_add({
		"id": 30077,
		"title": "The Syndicate: Profit over Principle",
		"type": "identity",
		"side": "corp",
		"faction": "Neutral",
		"subtypes": ["Megacorp"],
		"deck_size": 30,
		"influence_limit": 9001,
		"text": "Starter identity. (Chiriboga / System Gateway tutorial.)",
	})
	_add({
		"id": 30075,
		"title": "Hedge Fund",
		"type": "operation",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"cost": 5,
		"subtypes": ["Transaction"],
		"text": "Gain 9[credit].",
		"on_play": [{"op": "gain_credits", "who": "corp", "n": 9}],
	})
	_add({
		"id": 30064,
		"title": "Government Subsidy",
		"type": "operation",
		"side": "corp",
		"faction": "Weyland Consortium",
		"influence": 1,
		"cost": 10,
		"subtypes": ["Transaction"],
		"text": "Gain 15[credit].",
		"on_play": [{"op": "gain_credits", "who": "corp", "n": 15}],
	})
	_add({
		"id": 30040,
		"title": "Seamless Launch",
		"type": "operation",
		"side": "corp",
		"faction": "Haas-Bioroid",
		"influence": 2,
		"cost": 1,
		"text": "Place 2 advancement counters on 1 installed card that you did not install this turn.",
		"on_play": [{"op": "seamless_launch"}],
	})
	_add({
		"id": 30065,
		"title": "Retribution",
		"type": "operation",
		"side": "corp",
		"faction": "Weyland Consortium",
		"influence": 1,
		"cost": 1,
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner is tagged. Trash 1 installed program or piece of hardware.",
		"requires_tags": 1,
		"on_play": [{"op": "retribution"}],
	})
	_add({
		"id": 30067,
		"title": "Offworld Office",
		"type": "agenda",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"agenda_points": 2,
		"advancement_requirement": 4,
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, gain 7[credit].",
		"on_scored": [{"op": "gain_credits", "who": "corp", "n": 7}],
	})
	_add({
		"id": 30068,
		"title": "Orbital Superiority",
		"type": "agenda",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"agenda_points": 2,
		"advancement_requirement": 4,
		"subtypes": ["Security"],
		"text": "When you score this agenda, if the Runner is tagged, do 4 meat damage; otherwise, give the Runner 1 tag.",
		"on_scored": [{"op": "orbital"}],
	})
	_add({
		"id": 30069,
		"title": "Send a Message",
		"type": "agenda",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"agenda_points": 3,
		"advancement_requirement": 5,
		"subtypes": ["Security"],
		"text": "When this agenda is scored or stolen, you may rez 1 installed piece of ice, ignoring all costs.",
		"on_scored": [{"op": "send_a_message"}],
		"on_stolen": [{"op": "send_a_message"}],
	})
	_add({
		"id": 30070,
		"title": "Superconducting Hub",
		"type": "agenda",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"agenda_points": 1,
		"advancement_requirement": 3,
		"subtypes": ["Expansion"],
		"text": "When you score this agenda, you may draw 2 cards. You get +2 maximum hand size.",
		"max_hand_mod": 2,
		"on_scored": [{"op": "maybe_draw", "who": "corp", "n": 2}],
	})
	_add({
		"id": 30037,
		"title": "Nico Campaign",
		"type": "asset",
		"side": "corp",
		"faction": "Haas-Bioroid",
		"influence": 2,
		"cost": 2,
		"trash_cost": 2,
		"subtypes": ["Advertisement"],
		"text": "When you rez this asset, load 9[credit] onto it. When it is empty, trash it and draw 1 card. When your turn begins, take 3[credit] from this asset.",
		"on_rez": [{"op": "load_credits", "n": 9}],
		"on_corp_turn_begins": [{"op": "take_credits", "n": 3, "if_has": 3}, {"op": "trash_if_empty_draw"}],
	})
	_add({
		"id": 30071,
		"title": "Regolith Mining License",
		"type": "asset",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"cost": 2,
		"trash_cost": 3,
		"text": "When you rez this asset, load 15[credit] onto it. When it is empty, trash it. [click]: Take 3[credit] from this asset.",
		"on_rez": [{"op": "load_credits", "n": 15}],
		"abilities": [{
			"text": "[click]: Take 3[credit] from this asset.",
			"click_cost": 1,
			"take_hosted": 3,
			"ops": [{"op": "take_credits", "n": 3}, {"op": "trash_if_empty"}],
		}],
	})
	_add({
		"id": 30045,
		"title": "Urtica Cipher",
		"type": "asset",
		"side": "corp",
		"faction": "Jinteki",
		"influence": 2,
		"cost": 0,
		"trash_cost": 2,
		"can_advance": true,
		"subtypes": ["Ambush"],
		"text": "You can advance this asset. When the Runner accesses this asset while it is installed, do 2 net damage plus 1 net damage for each hosted advancement counter.",
		"never_rez_usability": true,
		"on_access_installed": [{"op": "urtica"}],
	})
	_add({
		"id": 30042,
		"title": "Manegarm Skunkworks",
		"type": "upgrade",
		"side": "corp",
		"faction": "Haas-Bioroid",
		"influence": 3,
		"cost": 2,
		"trash_cost": 3,
		"unique": true,
		"text": "Whenever the Runner approaches this server, end the run unless they either spend [click][click] or pay 5[credit].",
		"on_approach_server": [{"op": "manegarm"}],
	})
	_add({
		"id": 30072,
		"title": "Palisade",
		"type": "ice",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"cost": 3,
		"strength": 2,
		"subtypes": ["Barrier"],
		"text": "While this ice is protecting a remote server, it gets +2 strength. Subroutine End the run.",
		"strength_if_remote": 2,
		"subroutines": [{"text": "End the run.", "ops": [{"op": "end_the_run"}]}],
	})
	_add({
		"id": 30073,
		"title": "Tithe",
		"type": "ice",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"cost": 1,
		"strength": 1,
		"subtypes": ["Sentry", "AP"],
		"text": "Subroutine Do 1 net damage. Subroutine Gain 1[credit].",
		"subroutines": [
			{"text": "Do 1 net damage.", "ops": [{"op": "damage", "type": "net", "n": 1}]},
			{"text": "Gain 1[credit].", "ops": [{"op": "gain_credits", "who": "corp", "n": 1}]},
		],
	})
	_add({
		"id": 30074,
		"title": "Whitespace",
		"type": "ice",
		"side": "corp",
		"faction": "Neutral",
		"influence": 0,
		"cost": 2,
		"strength": 0,
		"subtypes": ["Code Gate"],
		"text": "Subroutine The Runner loses 3[credit]. Subroutine If the Runner has 6[credit] or less, end the run.",
		"subroutines": [
			{"text": "The Runner loses 3[credit].", "ops": [{"op": "lose_credits", "who": "runner", "n": 3}]},
			{"text": "If the Runner has 6[credit] or less, end the run.", "ops": [{"op": "etr_if_credits_le", "n": 6}]},
		],
	})
	_add({
		"id": 30046,
		"title": "Diviner",
		"type": "ice",
		"side": "corp",
		"faction": "Jinteki",
		"influence": 2,
		"cost": 2,
		"strength": 3,
		"subtypes": ["Code Gate", "AP"],
		"text": "Subroutine Do 1 net damage. If you trash a card this way with a printed play or install cost that is an odd number, end the run. (0 is not odd.)",
		"subroutines": [{"text": "Do 1 net damage. If the trashed card's printed cost is odd, end the run.", "ops": [{"op": "diviner"}]}],
	})
	_add({
		"id": 30047,
		"title": "Karunā",
		"type": "ice",
		"side": "corp",
		"faction": "Jinteki",
		"influence": 2,
		"cost": 4,
		"strength": 3,
		"subtypes": ["Sentry", "AP"],
		"text": "Subroutine Do 2 net damage. The Runner may jack out. Subroutine Do 2 net damage.",
		"subroutines": [
			{"text": "Do 2 net damage. The Runner may jack out.", "ops": [{"op": "damage", "type": "net", "n": 2}, {"op": "jack_out_optional"}]},
			{"text": "Do 2 net damage.", "ops": [{"op": "damage", "type": "net", "n": 2}]},
		],
	})
	_add({
		"id": 30039,
		"title": "Brân 1.0",
		"type": "ice",
		"side": "corp",
		"faction": "Haas-Bioroid",
		"influence": 2,
		"cost": 6,
		"strength": 6,
		"subtypes": ["Barrier", "Bioroid"],
		"text": "Lose [click]: Break 1 subroutine on this ice. Only the Runner can use this ability. Subroutine You may install 1 piece of ice from HQ or Archives directly inward from this ice, ignoring all costs. Subroutine End the run. Subroutine End the run.",
		"bioroid_break": true,
		"subroutines": [
			{"text": "You may install 1 ice from HQ or Archives inward of this ice, ignoring all costs.", "ops": [{"op": "bran_install"}]},
			{"text": "End the run.", "ops": [{"op": "end_the_run"}]},
			{"text": "End the run.", "ops": [{"op": "end_the_run"}]},
		],
	})
	_add({
		"id": 30054,
		"title": "Funhouse",
		"type": "ice",
		"side": "corp",
		"faction": "NBN",
		"influence": 2,
		"cost": 5,
		"strength": 4,
		"subtypes": ["Code Gate"],
		"text": "When the Runner encounters this ice, end the run unless the Runner takes 1 tag. Subroutine Give the Runner 1 tag unless they pay 4[credit].",
		"on_encounter": [{"op": "funhouse_encounter"}],
		"subroutines": [{"text": "Give the Runner 1 tag unless they pay 4[credit].", "ops": [{"op": "funhouse_sub"}]}],
	})
	_add({
		"id": 30055,
		"title": "Ping",
		"type": "ice",
		"side": "corp",
		"faction": "NBN",
		"influence": 2,
		"cost": 2,
		"strength": 1,
		"subtypes": ["Barrier"],
		"text": "When you rez this ice during a run against this server, give the Runner 1 tag. Subroutine End the run.",
		"tag_on_rez_during_run": true,
		"subroutines": [{"text": "End the run.", "ops": [{"op": "end_the_run"}]}],
	})


func _register_extra() -> void:
	## Core Set ice with a Trace subroutine — demonstrates the trace mechanic.
	_add({
		"id": 1112,
		"title": "Hunter",
		"type": "ice",
		"side": "corp",
		"faction": "Weyland Consortium",
		"influence": 1,
		"cost": 1,
		"strength": 4,
		"subtypes": ["Sentry", "Tracer", "Observer"],
		"text": "Subroutine Trace[3]. If successful, give the Runner 1 tag.",
		"subroutines": [{"text": "Trace[3]. If successful, give the Runner 1 tag.", "ops": [{"op": "trace", "base": 3, "on_success": [{"op": "add_tags", "n": 1}]}]}],
	})
	_add({
		"id": 30057,
		"title": "Public Trail",
		"type": "operation",
		"side": "corp",
		"faction": "NBN",
		"influence": 2,
		"cost": 4,
		"subtypes": ["Gray Ops"],
		"text": "Play only if the Runner made a successful run during their last turn. Give the Runner 1 tag.",
		"requires_runner_ran_last_turn": true,
		"on_play": [{"op": "add_tags", "n": 1}],
	})
