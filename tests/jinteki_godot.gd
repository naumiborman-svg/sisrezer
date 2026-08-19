extends SceneTree

var failed := false


func _fail(msg: String) -> void:
	push_error(msg)
	failed = true


func _initialize() -> void:
	var defs := CardLibrary.jinteki_cards()
	var matchups := CardLibrary.matchups()
	if defs.size() < 2000:
		_fail("expected 2000+ mtgred cards, got %d" % defs.size())
	if matchups.size() < 40:
		_fail("expected official matchups, got %d" % matchups.size())
	var beginner := CardLibrary.matchup("beginner")
	if beginner.is_empty() or int(beginner.get("corp", {}).get("card_count", 0)) < 30:
		_fail("beginner matchup missing")
	var worlds := CardLibrary.decks_for("worlds-2012-a")
	if str(worlds.get("corp", {}).get("identity", "")) != "01054":
		_fail("worlds-2012-a corp should be ETF 01054")
	_test_hedge(defs, worlds)
	_test_enigma(defs)
	var title_ps := load("res://scenes/title.tscn") as PackedScene
	if title_ps == null:
		_fail("jinteki title scene missing")
	else:
		var title := title_ps.instantiate()
		root.add_child(title)
		await process_frame
		title.queue_free()
	if failed:
		quit(1)
		return
	print("JINTEKI_GODOT_OK cards=%s matchups=%s worlds_corp=%s" % [
		defs.size(), matchups.size(), worlds.get("corp", {}).get("identity", "")
	])
	quit(0)


func _test_hedge(defs: Dictionary, decks: Dictionary) -> void:
	var e := NREngine.new(defs)
	e.new_game(3, decks)
	var hf_code := ""
	for code: Variant in decks.get("corp", {}).get("cards", {}).keys():
		if str(defs.get(str(code), {}).get("title", "")) == "Hedge Fund":
			hf_code = str(code)
			break
	if hf_code == "":
		_fail("worlds deck missing Hedge Fund")
		return
	e.corp.hand.clear()
	e.corp.credits = 5
	e.corp.clicks = 1
	var card: Dictionary = e._make_card(hf_code)
	card.zone = "hand"
	e.corp.hand.append(card)
	if not e.apply({"op": "play", "uid": card.uid}):
		_fail("hedge fund play failed")
		return
	if e.corp.credits != 9:
		_fail("hedge fund should end at 9, got %d" % e.corp.credits)


func _test_enigma(defs: Dictionary) -> void:
	var code := ""
	for item: Variant in defs.values():
		if item is Dictionary and str(item.get("title", "")) == "Enigma":
			code = str(item.get("code", ""))
			break
	if code == "":
		_fail("Enigma missing from card pool")
		return
	var e := NREngine.new(defs)
	e.new_game(1, CardLibrary.decks_for("beginner"))
	var ice: Dictionary = e._make_card(code)
	var subs: Array = e._build_subs(ice)
	if subs.is_empty():
		_fail("Enigma should have subroutines")
		return
	var etr := false
	for sub: Variant in subs:
		if sub is Dictionary and str(sub.get("kind", "")) == "etr":
			etr = true
	if not etr:
		_fail("Enigma should end the run")
