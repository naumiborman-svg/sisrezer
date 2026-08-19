extends RefCounted
class_name CorpAI
## Simple but competent Corp: score, protect agendas, rez economy, tax the Runner.

static func pick(gs: GameState, acts: Array) -> Dictionary:
	if acts.is_empty():
		return {}
	var best: Dictionary = acts[0]
	var best_s := -99999
	for a in acts:
		var s := _score(gs, a)
		if s > best_s:
			best_s = s
			best = a
	return best


static func _score(gs: GameState, a: Dictionary) -> int:
	var t := str(a.get("type", ""))
	var label := str(a.get("label", ""))
	match t:
		"pending":
			return _pending(gs, a)
		"score":
			return 10000
		"rez":
			var card: NRCard = a.get("card")
			if card == null:
				return 0
			if card.card_type() == "asset":
				return 800 + card.hosted_credits
			if card.card_type() == "upgrade":
				return 500
			if card.card_type() == "ice":
				return 200
			return 100
		"advance":
			var c2: NRCard = a.get("card")
			if c2 == null:
				return 0
			if c2.card_type() == "agenda":
				var need := c2.advancement_requirement() - c2.advancement
				if need <= 1:
					return 9000
				if need <= 2:
					return 1200
				return 700
			if c2.card_type() == "asset" and c2.has_subtype("Ambush"):
				return 400 if c2.advancement < 3 else 50
			return 80
		"play":
			var c3: NRCard = a.get("card")
			if c3 == null:
				return 200
			if c3.title().find("Hedge Fund") >= 0:
				return 850 if gs.corp.credits >= 5 and gs.corp.credits < 14 else 200
			if c3.title().find("Government Subsidy") >= 0:
				return 900 if gs.corp.credits >= 10 else 0
			if c3.title().find("Seamless") >= 0:
				return 1500
			if c3.title().find("Retribution") >= 0:
				return 1100 if gs.runner.tags > 0 else 0
			if c3.title().find("Public Trail") >= 0:
				return 600
			return 250
		"install":
			return _install(gs, a)
		"draw":
			return 150 if gs.hq.cards.size() < 5 else 40
		"credit":
			return 120 if gs.corp.credits < 6 else 50
		"trash_resource":
			return 650
		"purge":
			return 5
		"end_phase":
			return 10 if gs.corp.clicks == 0 else -20
		"rez_approached":
			var ice: NRCard = a.get("card")
			if ice == null:
				return 400
			## rez if we can and it would hurt
			if gs.corp.credits >= gs.rez_cost_now(ice) + 1:
				return 700
			if ice.has_subtype("AP") or ice.has_subtype("Barrier"):
				return 600
			return 300
		"no_rez":
			return 20
		"begin_enc":
			return 500
		_:
			return 1 if label != "" else 0


static func _install(gs: GameState, a: Dictionary) -> int:
	var card: NRCard = a.get("card")
	var srv: NRServer = a.get("server")
	if card == null or srv == null:
		return 50
	if card.card_type() == "agenda":
		if srv.is_central:
			return -100
		if srv.ice_count() >= 1:
			return 1400
		return 500
	if card.card_type() == "ice":
		if srv.server_name.begins_with("Remote") and (srv.has_agenda() or srv.has_asset()):
			return 1000 + (3 - srv.ice_count()) * 80
		if srv.server_name == "HQ" or srv.server_name == "R&D":
			return 450 + (2 - srv.ice_count()) * 40
		if srv.server_name == "Archives":
			return 80
		if srv.id == -99:
			return 200
		return 180
	if card.card_type() == "asset":
		if card.has_subtype("Ambush"):
			return 350 if srv.ice_count() > 0 else 180
		if srv.is_central:
			return -50
		return 600 if srv.ice_count() > 0 else 280
	if card.card_type() == "upgrade":
		if srv.has_agenda():
			return 900
		return 200
	return 40


static func _pending(gs: GameState, a: Dictionary) -> int:
	var label := str(a.get("label", "")).to_lower()
	if label.find("decline") >= 0:
		return 5
	if label.find("draw 4") >= 0:
		## Wildcat: make the runner draw if they are poor, else credits
		return 80 if gs.runner.credits > 8 else 20
	if label.find("gain 6") >= 0:
		return 90 if gs.runner.credits <= 8 else 30
	if label.find("rez") >= 0:
		return 400
	if label.find("trash") >= 0:
		return 500
	if label.find("install") >= 0:
		return 350
	if label.find("trace") >= 0:
		var spent := int(a.get("spent", 0))
		## spend a little, not bankrupt
		if spent <= 2 and spent <= gs.corp.credits / 3:
			return 100 - spent
		return 10 - spent
	if label.find("advancement") >= 0 or a.has("card"):
		var c = a.get("card")
		if c is NRCard and c.card_type() == "agenda":
			return 800
		return 200
	if label.find("draw") >= 0:
		return 120
	return 50
