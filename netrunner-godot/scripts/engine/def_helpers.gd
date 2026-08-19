class_name NRDefHelpers
extends RefCounted

## Port of game.core.def-helpers — helpers used when defining card abilities.
## Future card translations should import these rather than inlining engine calls.


static func corp_install_ability(cost = null, extra: Dictionary = {}) -> Dictionary:
	var ab: Dictionary = {
		"async": true,
		"effect": extra.get("effect", func(state, side, eid, card, targets):
			NRInstalling.corp_install(state, side, eid, card, extra.get("server"))),
	}
	if cost != null:
		ab["cost"] = cost
	ab.merge(extra, true)
	return ab


static func runner_install_ability(cost = null, extra: Dictionary = {}) -> Dictionary:
	var ab: Dictionary = {
		"async": true,
		"effect": extra.get("effect", func(state, side, eid, card, _t):
			NRInstalling.runner_install(state, side, eid, card, extra)),
	}
	if cost != null:
		ab["cost"] = cost
	ab.merge(extra, true)
	return ab


static func trash_on_breach_ability() -> Dictionary:
	return {
		"async": true,
		"effect": func(state, side, eid, card, _t):
			NRMoving.trash(state, side, eid, card),
	}


static func gain_credits_ability(n: int) -> Dictionary:
	return {
		"msg": "gain %d [Credits]" % n,
		"async": true,
		"effect": func(state, side, eid, _c, _t):
			NRGaining.gain_credits(state, side, eid, n),
	}


static func draw_ability(n: int) -> Dictionary:
	return {
		"msg": "draw %d card%s" % [n, "s" if n != 1 else ""],
		"async": true,
		"effect": func(state, side, eid, _c, _t):
			NRDrawing.draw(state, side, eid, n),
	}


static func do_net_damage(n: int) -> Dictionary:
	return {
		"async": true,
		"msg": "do %d net damage" % n,
		"effect": func(state, side, eid, _c, _t):
			NRDamage.damage(state, side, eid, "net", n),
	}


static func do_meat_damage(n: int) -> Dictionary:
	return {
		"async": true,
		"msg": "do %d meat damage" % n,
		"effect": func(state, side, eid, _c, _t):
			NRDamage.damage(state, side, eid, "meat", n),
	}


static func do_brain_damage(n: int) -> Dictionary:
	return {
		"async": true,
		"msg": "do %d core damage" % n,
		"effect": func(state, side, eid, _c, _t):
			NRDamage.damage(state, side, eid, "brain", n),
	}


static func give_tags(n: int) -> Dictionary:
	return {
		"async": true,
		"msg": "give the Runner %d tag%s" % [n, "s" if n != 1 else ""],
		"effect": func(state, _side, eid, _c, _t):
			NRTags.gain_tags(state, "runner", eid, n),
	}


static func take_credits(n: int) -> Dictionary:
	return gain_credits_ability(n)


static func end_the_run() -> Dictionary:
	return {
		"async": true,
		"msg": "end the run",
		"effect": func(state, side, eid, card, _t):
			NRRuns.end_run(state, side, eid, {"card": card}),
	}


static func runner_ends_the_run() -> Dictionary:
	return {
		"async": true,
		"msg": "end the run",
		"effect": func(state, _side, eid, card, _t):
			NRRuns.end_run(state, "runner", eid, {"card": card}),
	}


static func add_counter(typ: String, n: int) -> Dictionary:
	return {
		"async": true,
		"effect": func(state, side, eid, card, _t):
			NRProps.add_counter(state, side, eid, card, typ, n),
	}


static func rez_ability(cost = null, extra: Dictionary = {}) -> Dictionary:
	var ab: Dictionary = {
		"async": true,
		"effect": extra.get("effect", func(state, side, eid, card, _t):
			NRRezzing.rez(state, side, eid, card)),
	}
	if cost != null:
		ab["cost"] = cost
	ab.merge(extra, true)
	return ab


static func offer_jack_out() -> Dictionary:
	return {
		"optional": {
			"prompt": "Jack out?",
			"waiting-prompt": true,
			"yes-ability": {
				"async": true,
				"effect": func(state, _side, _eid, _c, _t):
					NRRuns.jack_out(state, "runner", {}),
			},
		}
	}


static func continue_ability(ability: Dictionary, card: Dictionary = {}, targets: Array = []) -> Dictionary:
	return {
		"async": true,
		"effect": func(state, side, _eid, c, t):
			NREngine.continue_ability(state, side, ability, card if not card.is_empty() else c, targets if not targets.is_empty() else t),
	}
