class_name NRCardsBasic
extends RefCounted

## Port of game.cards.basic — Corp and Runner basic action cards.
## Call register() before NRSetUp.init_game (init_game also calls it).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_corp()
	_register_runner()
	NRCardDefs.defcard("Custom Biotics: Engineered for Success", {
		"type": "Identity", "side": "Corp", "faction": "Haas-Bioroid",
		"baselink": 0, "influencelimit": 15, "minimumdecksize": 45,
	})
	NRCardDefs.defcard("The Professor: Keeper of Knowledge", {
		"type": "Identity", "side": "Runner", "faction": "Shaper",
		"baselink": 0, "influencelimit": 1, "minimumdecksize": 45,
	})


static func _ctx(targets: Variant) -> Dictionary:
	return NRUtil.ability_context(targets)


static func _target_card(state: NRState, targets: Variant) -> Variant:
	var ctx = NRCardsBasic._ctx(targets)
	var c = ctx.get("card")
	if c is Dictionary:
		var latest = NRCard.get_card(state, c)
		return latest if latest != null else c
	return null


static func _register_corp() -> void:
	NRCardDefs.defcard("Corp Basic Action Card", {
		"type": "Basic Action",
		"side": "Corp",
		"abilities": [
			{
				"action": true,
				"label": "Gain 1 [Credits]",
				"cost": [NRPayment.to_c("click")],
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, _card, _t):
					state.update_in(["stats", NRUtil.to_side(side), "click", "credit"], NRUtil.inc_n(1), 0)
					NRSay.play_sfx(state, side, "click-credit")
					NRGaining.gain_credits(state, side, eid, 1, {"action": "corp-click-credit"}),
			},
			{
				"action": true,
				"label": "Draw 1 card",
				"req": func(state, side, _eid, _c, _t):
					return not state.get_in([NRUtil.to_side(side), "deck"], []).is_empty(),
				"cost": [NRPayment.to_c("click")],
				"msg": "draw 1 card",
				"async": true,
				"effect": func(state, side, eid, _card, _t):
					var deck: Array = state.get_in([NRUtil.to_side(side), "deck"], [])
					var top = deck[0] if not deck.is_empty() else {}
					NREngine.trigger_event(state, side, "corp-click-draw", {"card": top})
					state.update_in(["stats", NRUtil.to_side(side), "click", "draw"], NRUtil.inc_n(1), 0)
					NRSay.play_sfx(state, side, "click-card")
					NRDrawing.draw(state, side, eid, 1),
			},
			{
				"action": true,
				"label": "Install 1 agenda, asset, upgrade, or piece of ice from HQ",
				"async": true,
				"req": func(state, side, eid, _card, targets):
					var target_card = NRCardsBasic._target_card(state, targets)
					if not (target_card is Dictionary) or not NRCard.in_hand(target_card):
						return false
					if not (NRCard.agenda(target_card) or NRCard.asset(target_card) or NRCard.ice(target_card) or NRCard.upgrade(target_card)):
						return false
					var args = {"base-cost": [NRPayment.to_c("click", 1)], "ignore-ice-cost": true, "action": "corp-click-install", "no-toast": true}
					var server = NRCardsBasic._ctx(targets).get("server")
					if server != null:
						return NRInstalling.corp_can_pay_and_install(state, side, eid, target_card, server, args)
					for sv in NRBoard.installable_servers(state, target_card):
						if NRInstalling.corp_can_pay_and_install(state, side, eid, target_card, sv, args):
							return true
					return false,
				"effect": func(state, side, eid, _card, targets):
					var target_card = NRCardsBasic._target_card(state, targets)
					var server = NRCardsBasic._ctx(targets).get("server")
					NRInstalling.corp_install(state, side, eid, target_card, server, {
						"base-cost": [NRPayment.to_c("click", 1)],
						"action": "corp-click-install",
					}),
			},
			{
				"action": true,
				"label": "Play 1 operation",
				"async": true,
				"req": func(state, side, eid, _card, targets):
					var target_card = NRCardsBasic._target_card(state, targets)
					if not (target_card is Dictionary) or not NRCard.in_hand(target_card) or not NRCard.operation(target_card):
						return false
					return NRPlayInstants.can_play_instant(state, "corp", eid, target_card, {"base-cost": [NRPayment.to_c("click", 1)]}),
				"effect": func(state, side, eid, _card, targets):
					NRPlayInstants.play_instant(state, "corp", eid, NRCardsBasic._target_card(state, targets), {"base-cost": [NRPayment.to_c("click", 1)]}),
			},
			{
				"action": true,
				"label": "Advance 1 installed card",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 1)],
				"async": true,
				"msg": func(state, _side, _eid, _card, targets):
					var tc = NRCardsBasic._target_card(state, targets)
					return "advance %s" % (NRToString.card_str(state, tc) if tc is Dictionary else "a card"),
				"effect": func(state, side, eid, _card, targets):
					var tc = NRCardsBasic._target_card(state, targets)
					if tc is Dictionary:
						NRAgendas.update_advancement_requirement(state, tc)
						NRSay.play_sfx(state, side, "click-advance")
						NRProps.add_prop(state, side, eid, tc, "advance-counter", 1)
					else:
						NREid.effect_completed(state, side, eid),
			},
			{
				"action": true,
				"label": "Trash 1 resource if the Runner is tagged",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)],
				"async": true,
				"req": func(state, _s, _e, _c, _t):
					return NRUtil.is_tagged(state),
				"prompt": "Choose a resource to trash",
				"choices": {"req": func(state, _s, _e, _c, targets):
					var t = targets[0] if targets is Array and targets.size() > 0 else targets
					if not (t is Dictionary) or not NRCard.resource(t):
						return false
					if NRFlags.untrashable_while_resources(t):
						var n = 0
						for c in NRBoard.all_active_installed(state, "runner"):
							if c is Dictionary and NRCard.resource(c):
								n += 1
						return n >= 2
					return true},
				"msg": func(_s, _sd, _e, _c, targets):
					var t = targets[0] if targets is Array and targets.size() > 0 else {}
					return "trash %s" % (t.get("title") if t is Dictionary else "a resource"),
				"effect": func(state, side, eid, _card, targets):
					var t = targets[0] if targets is Array and targets.size() > 0 else null
					if t is Dictionary:
						NRMoving.trash(state, side, eid, t)
					else:
						NREid.effect_completed(state, side, eid),
			},
			{
				"action": true,
				"label": "Purge virus counters",
				"cost": [NRPayment.to_c("click", 3)],
				"msg": "purge all virus counters",
				"async": true,
				"effect": func(state, side, eid, _c, _t):
					NRSay.play_sfx(state, side, "virus-purge")
					NRPurging.purge(state, side, eid),
			},
		],
	})


static func _register_runner() -> void:
	NRCardDefs.defcard("Runner Basic Action Card", {
		"type": "Basic Action",
		"side": "Runner",
		"abilities": [
			{
				"action": true,
				"label": "Gain 1 [Credits]",
				"cost": [NRPayment.to_c("click")],
				"msg": "gain 1 [Credits]",
				"async": true,
				"effect": func(state, side, eid, _card, _t):
					state.update_in(["stats", NRUtil.to_side(side), "click", "credit"], NRUtil.inc_n(1), 0)
					NRSay.play_sfx(state, side, "click-credit")
					NRGaining.gain_credits(state, side, eid, 1, {"action": "runner-click-credit"}),
			},
			{
				"action": true,
				"label": "Draw 1 card",
				"req": func(state, side, _eid, _c, _t):
					return not state.get_in([NRUtil.to_side(side), "deck"], []).is_empty(),
				"cost": [NRPayment.to_c("click")],
				"msg": "draw 1 card",
				"async": true,
				"effect": func(state, side, eid, _card, _t):
					var deck: Array = state.get_in([NRUtil.to_side(side), "deck"], [])
					var top = deck[0] if not deck.is_empty() else {}
					NREngine.trigger_event(state, side, "runner-click-draw", {"card": top})
					state.update_in(["stats", NRUtil.to_side(side), "click", "draw"], NRUtil.inc_n(1), 0)
					NRSay.play_sfx(state, side, "click-card")
					NRDrawing.draw(state, side, eid, 1 + NRDrawing.use_bonus_click_draws(state)),
			},
			{
				"action": true,
				"label": "Install 1 program, resource, or piece of hardware from the grip",
				"async": true,
				"req": func(state, side, eid, _card, targets):
					var target_card = NRCardsBasic._target_card(state, targets)
					if not (target_card is Dictionary) or not NRCard.in_hand(target_card):
						return false
					if not (NRCard.hardware(target_card) or NRCard.program(target_card) or NRCard.resource(target_card)):
						return false
					return NRInstalling.runner_can_pay_and_install(state, "runner", eid, target_card, {"base-cost": [NRPayment.to_c("click", 1)]}),
				"effect": func(state, side, eid, _card, targets):
					NRInstalling.runner_install(state, "runner", eid, NRCardsBasic._target_card(state, targets), {
						"base-cost": [NRPayment.to_c("click", 1)],
						"no-toast": true,
					}),
			},
			{
				"action": true,
				"label": "Play 1 event",
				"async": true,
				"req": func(state, side, eid, _card, targets):
					var target_card = NRCardsBasic._target_card(state, targets)
					if not (target_card is Dictionary) or not NRCard.in_hand(target_card) or not NRCard.event(target_card):
						return false
					return NRPlayInstants.can_play_instant(state, "runner", eid, target_card, {"base-cost": [NRPayment.to_c("click", 1)]}),
				"effect": func(state, side, eid, _card, targets):
					NRPlayInstants.play_instant(state, "runner", eid, NRCardsBasic._target_card(state, targets), {"base-cost": [NRPayment.to_c("click", 1)]}),
			},
			{
				"action": true,
				"label": "Run any server",
				"async": true,
				"effect": func(state, side, eid, _card, targets):
					var server = NRCardsBasic._ctx(targets).get("server")
					NRRuns.make_run(state, side, eid, server, null, {"click-run": true}),
			},
			{
				"action": true,
				"label": "Remove 1 tag",
				"cost": [NRPayment.to_c("click", 1), NRPayment.to_c("credit", 2)],
				"msg": "remove 1 tag",
				"req": func(state, _s, _e, _c, _t):
					return NRUtil.is_tagged(state),
				"async": true,
				"effect": func(state, side, eid, _c, _t):
					NRSay.play_sfx(state, side, "click-remove-tag")
					NRTags.lose_tags(state, side, eid, 1),
			},
		],
	})
