extends Control

const BG := Color(0.015, 0.035, 0.02)
const GREEN := Color(0.2, 1.0, 0.2)
const DIM := Color(0.35, 0.65, 0.35)
const MUTED := Color(0.28, 0.48, 0.28)

var client: ChiribogaClient
var jinteki: ClojureClient
var catalog: Dictionary = {}
var jinteki_catalog: Dictionary = {}
var preview: Dictionary = {}
var settings: Dictionary = {}
var _left: VBoxContainer
var _preview_box: VBoxContainer
var _host_ok := false
var _jinteki_ok := false
var _jinteki_cards := 0
var _threat := 1
var _campaign: Dictionary = {}
var _hack_index := -1


func _fill(node: Control, pad := Vector4.ZERO) -> void:
	node.anchor_left = 0.0
	node.anchor_top = 0.0
	node.anchor_right = 1.0
	node.anchor_bottom = 1.0
	node.offset_left = pad.x
	node.offset_top = pad.y
	node.offset_right = -pad.z
	node.offset_bottom = -pad.w
	node.grow_horizontal = Control.GROW_DIRECTION_BOTH
	node.grow_vertical = Control.GROW_DIRECTION_BOTH


func _ready() -> void:
	settings = ChiribogaSave.settings()
	_fill(self)
	var bg := ColorRect.new()
	_fill(bg)
	bg.color = BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_build_chrome()
	if bool(settings.get("crt", true)):
		_add_scanlines()
	client = ChiribogaClient.new()
	add_child(client)
	jinteki = ClojureClient.new()
	add_child(jinteki)
	if not client.is_node_ready():
		await client.ready
	if not jinteki.is_node_ready():
		await jinteki.ready
	_load_catalog()


func _add_scanlines() -> void:
	var overlay := ColorRect.new()
	_fill(overlay)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/crt_scanlines.gdshader")
	overlay.material = mat
	overlay.color = Color(1, 1, 1, 1)
	add_child(overlay)


func _build_chrome() -> void:
	var root := VBoxContainer.new()
	_fill(root, Vector4(36, 18, 36, 18))
	add_child(root)
	var top := HBoxContainer.new()
	root.add_child(top)
	top.add_child(_label("CH1R180G4 SYSTEMS v2.71 // NEURAL INTERFACE READY", 13, MUTED))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	top.add_child(_label("BUILD 0.6.13-BETA // 2077.08.19", 13, MUTED))
	root.add_child(_gap(8))
	root.add_child(_label("NETRUNNER", 56, GREEN))
	root.add_child(_label("$0LØ MOÐ3", 30, GREEN))
	root.add_child(_gap(10))
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 36)
	root.add_child(mid)
	_left = VBoxContainer.new()
	_left.custom_minimum_size = Vector2(420, 0)
	_left.add_theme_constant_override("separation", 8)
	mid.add_child(_left)
	_preview_box = VBoxContainer.new()
	_preview_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_box.alignment = BoxContainer.ALIGNMENT_CENTER
	mid.add_child(_preview_box)
	var bottom := HBoxContainer.new()
	root.add_child(bottom)
	var cred := _text_btn("CREDITS", func() -> void: _show_credits())
	bottom.add_child(cred)
	bottom.add_child(_gap_h(24))
	bottom.add_child(_label("THREAT LEVEL: %s" % _threat, 13, GREEN))
	bottom.add_child(_gap_h(24))
	bottom.add_child(_label("IP: 127.0.0.1", 13, MUTED))
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(fill)
	bottom.add_child(_text_btn("LEGACY JINTEKI", func() -> void: _legacy()))
	_show_main()


func _show_main() -> void:
	_clear(_left)
	_left.add_child(_menu_btn("QUICK GAME", func() -> void: _start_quick()))
	_left.add_child(_menu_btn("CUSTOM GAME", func() -> void: _show_custom()))
	_left.add_child(_menu_btn("GAUNTLET", func() -> void: _show_gauntlet()))
	_left.add_child(_menu_btn("TUTORIAL", func() -> void: _show_tutorial()))
	_left.add_child(_menu_btn("ACHIEVEMENTS [%s%%]" % ChiribogaSave.percent(), func() -> void: _show_achievements()))
	_left.add_child(_menu_btn("SETTINGS", func() -> void: _show_settings()))
	if _jinteki_ok:
		_left.add_child(_label("RULES  mtgred/netrunner  ·  %s cards" % _jinteki_cards, 12, DIM))
	else:
		_left.add_child(_label("RULES  Chiriboga JS  ·  start lein run for 2065-card engine", 12, MUTED))
	_paint_preview()


func _paint_preview() -> void:
	_clear(_preview_box)
	var title := _label("QUICK GAME\nINCOMING..", 20, GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_box.add_child(title)
	if preview.is_empty():
		_preview_box.add_child(_label("Connecting engines…" if not (_host_ok or _jinteki_ok) else "Rerolling pair…", 14, DIM))
		return
	var player: Dictionary = preview.get("player", {})
	var ai: Dictionary = preview.get("ai", {})
	_preview_box.add_child(_portrait("YOU", player))
	_preview_box.add_child(_label("VS", 28, GREEN))
	_preview_box.add_child(_portrait("CPU", ai))
	var reroll := _menu_btn("REROLL MATCHUP", func() -> void: _reroll())
	_preview_box.add_child(reroll)


func _portrait(who: String, deck: Dictionary) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_child(_label(who, 12, MUTED))
	var code := str(deck.get("identity", ""))
	var path := "res://assets/cards/%s.png" % code
	if ResourceLoader.exists(path):
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(160, 224)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.texture = load(path)
		box.add_child(tex)
	else:
		var rect := ColorRect.new()
		rect.custom_minimum_size = Vector2(160, 80)
		rect.color = Color(0.04, 0.12, 0.05)
		box.add_child(rect)
	box.add_child(_label(str(deck.get("name", "—")), 16, GREEN))
	box.add_child(_label(str(deck.get("identity_title", "")), 13, DIM))
	box.add_child(_label(str(deck.get("faction", "")), 12, MUTED))
	return box


func _load_catalog() -> void:
	var jt: Dictionary = await jinteki.status()
	_jinteki_ok = bool(jt.get("ok", false))
	_jinteki_cards = int(jt.get("cards", 0))
	var st: Dictionary = await client.status()
	_host_ok = bool(st.get("ok", false))
	if _jinteki_ok:
		jinteki_catalog = await jinteki.catalog()
		var jp: Dictionary = await jinteki.preview()
		if bool(jp.get("ok", false)):
			preview = jp
	if preview.is_empty() and _host_ok:
		catalog = await client.catalog()
		if catalog.has("preview"):
			var p: Variant = catalog["preview"]
			if p is Dictionary:
				preview = p
	var saved_id := str(settings.get("gauntlet_campaign_id", ""))
	if saved_id != "" and _host_ok:
		var hub: Dictionary = await client.gauntlet_state(saved_id)
		if bool(hub.get("ok", false)):
			_campaign = hub
			_show_gauntlet()
			return
		settings["gauntlet_campaign_id"] = ""
		ChiribogaSave.save_settings(settings)
	_show_main()


func _reroll() -> void:
	if _jinteki_ok:
		var jp: Dictionary = await jinteki.preview()
		if bool(jp.get("ok", false)):
			preview = jp
			_paint_preview()
			return
	var p: Dictionary = await client.preview()
	if bool(p.get("ok", false)):
		preview = p
	_paint_preview()


func _start_quick() -> void:
	if _jinteki_ok:
		var payload := {"engine": "jinteki", "mode": "quick", "agenda_goal": 7}
		if not preview.is_empty():
			payload["matchup"] = str(preview.get("matchup", ""))
			payload["side"] = str(preview.get("side", "runner"))
		_start(payload)
		return
	var payload := {"mode": "quick"}
	if not preview.is_empty():
		payload["player_deck"] = str(preview.get("player", {}).get("name", ""))
		payload["ai_deck"] = str(preview.get("ai", {}).get("name", ""))
		payload["side"] = str(preview.get("side", "runner"))
	_start(payload)


func _show_custom() -> void:
	_clear(_left)
	_left.add_child(_label("CUSTOM GAME", 22, GREEN))
	if _jinteki_ok:
		_left.add_child(_label("mtgred/netrunner preconstructed matchups", 13, DIM))
		var you_side := OptionButton.new()
		you_side.add_item("YOU  ·  RUNNER")
		you_side.set_item_metadata(0, "runner")
		you_side.add_item("YOU  ·  CORP")
		you_side.set_item_metadata(1, "corp")
		_left.add_child(you_side)
		var pick := OptionButton.new()
		for item: Variant in jinteki_catalog.get("matchups", []):
			if item is Dictionary:
				pick.add_item(str(item.get("label", item.get("key", "?"))))
				pick.set_item_metadata(pick.item_count - 1, item)
		_left.add_child(pick)
		_left.add_child(_menu_btn("LAUNCH", func() -> void:
			var mu: Variant = pick.get_selected_metadata()
			var payload := {"engine": "jinteki", "mode": "precon", "side": str(you_side.get_selected_metadata())}
			if mu is Dictionary:
				payload["matchup"] = str(mu.get("key", ""))
			_start(payload)
		))
		_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))
		return
	var runners := _precons("runner", true)
	var corps := _precons("corp", true)
	_left.add_child(_label("YOUR DECK", 13, MUTED))
	var you := OptionButton.new()
	for deck: Dictionary in runners + corps:
		you.add_item("%s  ·  %s" % [deck.get("name", ""), deck.get("faction", "")])
		you.set_item_metadata(you.item_count - 1, deck)
	_left.add_child(you)
	_left.add_child(_label("CPU DECK", 13, MUTED))
	var cpu := OptionButton.new()
	for deck: Dictionary in corps + runners:
		cpu.add_item("%s  ·  %s" % [deck.get("name", ""), deck.get("faction", "")])
		cpu.set_item_metadata(cpu.item_count - 1, deck)
	_left.add_child(cpu)
	_left.add_child(_menu_btn("LAUNCH", func() -> void:
		var a: Variant = you.get_selected_metadata()
		var b: Variant = cpu.get_selected_metadata()
		var payload := {"mode": "custom"}
		if a is Dictionary:
			payload["player_deck"] = str(a.get("name", ""))
			payload["side"] = str(a.get("side", "runner"))
		if b is Dictionary:
			payload["ai_deck"] = str(b.get("name", ""))
		_start(payload)
	))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_gauntlet() -> void:
	_clear(_left)
	_left.add_child(_label("GAUNTLET", 22, GREEN))
	if _campaign.is_empty():
		_left.add_child(_label("Build a runner from the Solo Mode pool, buy Aesop packs, hack corp perks, then fight. Length from settings.", 13, DIM, true))
		var length := int(settings.get("gauntlet_length", 4))
		_left.add_child(_label("LENGTH  %s" % length, 14, GREEN))
		_left.add_child(_menu_btn("NEW RUN", func() -> void: _gauntlet_new()))
		_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))
		return
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)
	if bool(_campaign.get("complete", false)):
		box.add_child(_label("GAUNTLET COMPLETE", 16, GREEN))
	elif bool(_campaign.get("lost", false)):
		box.add_child(_label("GAUNTLET LOST", 16, Color(1, 0.35, 0.35)))
	box.add_child(_label("%s  ·  %sc  ·  deck %s  ·  %s/%s" % [
		_campaign.get("identity_title", ""),
		_campaign.get("credits", 0),
		_campaign.get("deck_size", 0),
		_campaign.get("defeated", 0),
		_campaign.get("length", 0),
	], 13, GREEN, true))
	var msg := str(_campaign.get("last_message", ""))
	if msg != "":
		box.add_child(_label(msg, 12, DIM, true))
	var shop: Dictionary = _campaign.get("shop", {})
	box.add_child(_label("AESOP'S PAWN SHOP", 14, MUTED))
	for pack: Variant in shop.get("packs", []):
		if pack is Dictionary:
			var captured: Dictionary = pack
			box.add_child(_menu_btn("BUY %s  %sc" % [captured.get("name", ""), captured.get("cost", 10)], func() -> void:
				_gauntlet_act({"action": "buy", "index": int(captured.get("index", 0))})
			))
	box.add_child(_menu_btn("RE-ROLL PACKS  %sc" % shop.get("reroll_cost", 5), func() -> void:
		_gauntlet_act({"action": "reroll"})
	))
	if bool(_campaign.get("extra_sellable", false)):
		box.add_child(_menu_btn("SELL EXTRA CARDS", func() -> void: _gauntlet_act({"action": "sell"})))
	if bool(_campaign.get("identity_locked", true)):
		box.add_child(_menu_btn("UNLOCK IDENTITY  %sc" % shop.get("unlock_cost", 50), func() -> void:
			_gauntlet_act({"action": "unlock"})
		))
	else:
		for ident: Variant in _campaign.get("identities", []):
			if ident is Dictionary:
				var ident_id := int(ident.get("id", 0))
				box.add_child(_menu_btn("%s  %s" % [ident.get("title", ""), ident.get("faction", "")], func() -> void:
					_gauntlet_act({"action": "set_identity", "identity": ident_id})
				))
	box.add_child(_label("OPPONENTS", 14, MUTED))
	if _hack_index >= 0:
		_paint_hack(box)
	else:
		for opp: Variant in _campaign.get("opponents", []):
			if opp is Dictionary:
				_paint_opponent(box, opp)
	box.add_child(_menu_btn("ABANDON RUN", func() -> void:
		_campaign = {}
		_hack_index = -1
		settings["gauntlet_campaign_id"] = ""
		ChiribogaSave.save_settings(settings)
		_show_gauntlet()
	))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _paint_opponent(box: VBoxContainer, opp: Dictionary) -> void:
	var defeated := bool(opp.get("defeated", false))
	var color := MUTED if defeated else GREEN
	var perk := str(opp.get("perk_name", ""))
	var mark := "■" if defeated else ("★" if bool(opp.get("is_boss", false)) else "□")
	box.add_child(_label("%s  %s  ·  %s  ·  perk %s" % [
		mark, opp.get("name", ""), opp.get("faction", ""), perk
	], 13, color, true))
	if defeated or bool(_campaign.get("complete", false)) or bool(_campaign.get("lost", false)):
		return
	var idx := int(opp.get("index", 0))
	var row := HBoxContainer.new()
	var fight := _menu_btn("FIGHT", func() -> void: _gauntlet_fight(idx))
	fight.custom_minimum_size = Vector2(140, 32)
	var hack := _menu_btn("HACK", func() -> void:
		_hack_index = idx
		_show_gauntlet()
	)
	hack.custom_minimum_size = Vector2(140, 32)
	row.add_child(fight)
	row.add_child(hack)
	box.add_child(row)


func _paint_hack(box: VBoxContainer) -> void:
	var opp := _campaign_opponent(_hack_index)
	if opp.is_empty():
		_hack_index = -1
		return
	var hack: Dictionary = _campaign.get("hack", {})
	box.add_child(_label("HACK  %s" % opp.get("name", ""), 16, GREEN))
	box.add_child(_label("Prepare bonus +%s%%" % hack.get("prepare_bonus", 0), 12, DIM))
	var chances: Dictionary = opp.get("chances", {})
	box.add_child(_menu_btn("PREPARE HACK  %sc" % hack.get("prepare_cost", 3), func() -> void:
		_gauntlet_act({"action": "prepare", "opponent_index": _hack_index})
	))
	if bool(opp.get("decklist_revealed", false)):
		for card: Variant in opp.get("decklist", []):
			if card is Dictionary:
				box.add_child(_label("%sx  %s" % [card.get("count", 1), card.get("title", "")], 12, DIM))
	else:
		box.add_child(_menu_btn("VIEW DECKLIST  %sc  %s%%" % [hack.get("view_decklist_cost", 5), chances.get("decklist", 0)], func() -> void:
			_gauntlet_act({"action": "hack_decklist", "opponent_index": _hack_index})
		))
	if bool(opp.get("has_perk", false)) and not bool(opp.get("perk_revealed", false)):
		box.add_child(_menu_btn("VIEW PERK  %sc  %s%%" % [hack.get("view_perk_cost", 5), chances.get("perk", 0)], func() -> void:
			_gauntlet_act({"action": "hack_perk", "opponent_index": _hack_index})
		))
	elif bool(opp.get("has_perk", false)):
		box.add_child(_label("PERK  %s%s" % [opp.get("perk_name", ""), "  [DISABLED]" if bool(opp.get("perk_disabled", false)) else ""], 13, GREEN))
	if bool(opp.get("has_perk", false)) and not bool(opp.get("perk_disabled", false)):
		var cost := hack.get("disable_boss_perk_cost", 30) if bool(opp.get("is_boss", false)) else hack.get("disable_perk_cost", 15)
		box.add_child(_menu_btn("DISABLE PERK  %sc  %s%%" % [cost, chances.get("disable", 0)], func() -> void:
			_gauntlet_act({"action": "disable_perk", "opponent_index": _hack_index})
		))
	box.add_child(_menu_btn("BACK TO OPPONENTS", func() -> void:
		_hack_index = -1
		_show_gauntlet()
	))


func _campaign_opponent(index: int) -> Dictionary:
	for item: Variant in _campaign.get("opponents", []):
		if item is Dictionary and int(item.get("index", -1)) == index:
			return item
	return {}


func _gauntlet_new() -> void:
	var hub: Dictionary = await client.gauntlet_new({"length": int(settings.get("gauntlet_length", 4))})
	if not bool(hub.get("ok", false)):
		_campaign = {"last_message": str(hub.get("error", "gauntlet host unavailable"))}
		_show_gauntlet()
		return
	_campaign = hub
	settings["gauntlet_campaign_id"] = str(hub.get("id", ""))
	ChiribogaSave.save_settings(settings)
	_hack_index = -1
	_show_gauntlet()


func _gauntlet_act(payload: Dictionary) -> void:
	var id := str(_campaign.get("id", settings.get("gauntlet_campaign_id", "")))
	if id == "":
		return
	var hub: Dictionary = await client.gauntlet_action(id, payload)
	if hub.has("credits") or bool(hub.get("ok", false)):
		_campaign = hub
		_campaign["ok"] = true
	else:
		_campaign["last_message"] = str(hub.get("error", "action failed"))
	_show_gauntlet()


func _gauntlet_fight(index: int) -> void:
	var id := str(_campaign.get("id", ""))
	if id == "":
		return
	settings["gauntlet_campaign_id"] = id
	ChiribogaSave.save_settings(settings)
	_start({
		"mode": "gauntlet",
		"engine": "chiriboga",
		"side": "runner",
		"campaign_id": id,
		"opponent_index": index,
	})


func _show_tutorial() -> void:
	_clear(_left)
	_left.add_child(_label("TUTORIAL", 22, GREEN))
	var lessons := [
		"CLICKS & RUNS",
		"CREDITS & CARD TYPES",
		"ICE & ICEBREAKERS",
		"ASSETS & TRASH COSTS",
		"ADVANCING & SCORING",
		"UPGRADES & ROOT",
		"VS CORP STARTER DECK",
		"VS RUNNER STARTER DECK",
	]
	for i in lessons.size():
		var idx := i
		_left.add_child(_menu_btn("%s  %s" % [idx + 1, lessons[i]], func() -> void:
			_start({"mode": "tutorial", "mentor": idx})
		))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_achievements() -> void:
	_clear(_left)
	_left.add_child(_label("ACHIEVEMENTS", 22, GREEN))
	var data := ChiribogaSave.achievements()
	_left.add_child(_label("HIGH SCORES", 13, MUTED))
	for item: Variant in data.get("high_scores", []):
		if item is Dictionary:
			_left.add_child(_label("%s" % item.get("score", 0), 14, DIM))
	_left.add_child(_label("ACHIEVEMENTS", 13, MUTED))
	for item: Variant in data.get("achievements", []):
		if item is Dictionary:
			var mark := "■" if bool(item.get("achieved", false)) else "□"
			_left.add_child(_label("%s  %s" % [mark, item.get("name", "")], 14, GREEN if bool(item.get("achieved", false)) else MUTED))
			_left.add_child(_label(str(item.get("description", "")), 12, DIM))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_settings() -> void:
	_clear(_left)
	_left.add_child(_label("SETTINGS", 22, GREEN))
	_left.add_child(_label("GLOBAL SETTINGS", 13, MUTED))
	_left.add_child(_toggle("CRT EFFECTS", "crt"))
	_left.add_child(_label("GAUNTLET SETTINGS", 13, MUTED))
	var row := HBoxContainer.new()
	var minus := _menu_btn("−", func() -> void:
		settings["gauntlet_length"] = maxi(4, int(settings.get("gauntlet_length", 4)) - 4)
		ChiribogaSave.save_settings(settings)
		_show_settings()
	)
	minus.custom_minimum_size = Vector2(48, 32)
	var plus := _menu_btn("+", func() -> void:
		settings["gauntlet_length"] = mini(12, int(settings.get("gauntlet_length", 4)) + 4)
		ChiribogaSave.save_settings(settings)
		_show_settings()
	)
	plus.custom_minimum_size = Vector2(48, 32)
	row.add_child(minus)
	row.add_child(_label("  LENGTH  %s  " % settings.get("gauntlet_length", 4), 16, GREEN))
	row.add_child(plus)
	_left.add_child(row)
	_left.add_child(_label("Engine  mtgred/netrunner :1042  %s" % ("ON  %s cards" % _jinteki_cards if _jinteki_ok else "OFF"), 12, DIM))
	_left.add_child(_label("Engine  Chiriboga JS :1043  %s" % ("ON" if _host_ok else "OFF"), 12, DIM))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _show_credits() -> void:
	_clear(_left)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	box.add_child(_label("CREDITS", 22, GREEN))
	box.add_child(_label("This Netrunner Solo Mode extension for the Chiriboga engine is developed by DrBo6. It adds a more refined interface and game modes.", 13, DIM, true))
	box.add_child(_label("Chiriboga is a Netrunner engine developed by bobtheuberfish. It implements Android: Netrunner gameplay with an AI opponent.", 13, DIM, true))
	box.add_child(_label("Godot hosts the real drbo6/chiriboga JS Solo Mode (749 implemented cards, 71 precons). Gauntlet shop / hack / perks run on the Node host from gauntletConfig. Full 2065-card rules come from mtgred/netrunner when lein run is up on :1042.", 13, DIM, true))
	box.add_child(_label("GPL-3.0  ·  chiriboga.cronbach.com  ·  github.com/mtgred/netrunner  ·  github.com/bobtheuberfish/chiriboga", 12, MUTED, true))
	_left.add_child(_menu_btn("BACK", func() -> void: _show_main()))


func _toggle(label: String, key: String) -> Button:
	var on := bool(settings.get(key, false))
	return _menu_btn("%s  [%s]" % [label, "ON" if on else "OFF"], func() -> void:
		settings[key] = not bool(settings.get(key, false))
		ChiribogaSave.save_settings(settings)
		_show_settings()
	)


func _precons(side: String, custom_only: bool) -> Array:
	var out: Array = []
	for item: Variant in catalog.get("precons", []):
		if item is Dictionary:
			if str(item.get("side", "")) != side:
				continue
			if custom_only and not bool(item.get("useForCustomGame", true)):
				continue
			out.append(item)
	return out


func _label(text: String, size: int, color: Color, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _gap(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _gap_h(w: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, 0)
	return c


func _style_btn(b: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.03, 0.08, 0.04, 0.85)
	normal.border_color = Color(0.2, 0.55, 0.2)
	normal.set_border_width_all(1)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var hover := normal.duplicate()
	hover.bg_color = Color(0.06, 0.16, 0.07, 0.95)
	hover.border_color = GREEN
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", GREEN)
	b.add_theme_color_override("font_hover_color", Color(0.55, 1, 0.55))
	b.add_theme_font_size_override("font_size", 16)


func _menu_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 36)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_style_btn(b)
	b.pressed.connect(cb)
	return b


func _text_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.add_theme_color_override("font_color", DIM)
	b.pressed.connect(cb)
	return b


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _start(payload: Dictionary) -> void:
	var mode := str(payload.get("mode", ""))
	var mentor := int(payload.get("mentor", -1))
	if not payload.has("engine"):
		if mode == "tutorial" and mentor >= 0 and mentor < 6:
			payload["engine"] = "chiriboga"
		elif _jinteki_ok and mode != "gauntlet":
			payload["engine"] = "jinteki"
		else:
			payload["engine"] = "chiriboga"
	if str(payload.get("engine", "")) == "jinteki" and mode == "tutorial":
		payload["mode"] = "beginner"
		payload["agenda_goal"] = 6
		payload["side"] = "corp" if mentor == 7 else "runner"
	var packed := load("res://scenes/chiriboga_board.tscn") as PackedScene
	var board := packed.instantiate()
	board.set("payload", payload)
	get_tree().root.add_child(board)
	queue_free()


func _legacy() -> void:
	var packed := load("res://scenes/title.tscn") as PackedScene
	get_tree().root.add_child(packed.instantiate())
	queue_free()
