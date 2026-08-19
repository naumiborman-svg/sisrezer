class_name NRCardDefs
extends RefCounted
## Card-def registry. Port of game.core.card_defs + server-card lookup.
## Cards are dictionaries with title/type/cost/faction/text/keywords plus effect hooks (Callables).

static var _defs: Dictionary = {}
static var _server_cards: Dictionary = {}


static func defcard(title: String, cdef: Dictionary) -> void:
	_defs[title] = cdef
	if not _server_cards.has(title):
		var sc: Dictionary = cdef.duplicate(true)
		sc["title"] = title
		_server_cards[title] = sc


static func register_server_card(card: Dictionary) -> void:
	if card.has("title"):
		_server_cards[card["title"]] = card


static func card_def(card: Variant) -> Dictionary:
	if not (card is Dictionary):
		push_error("Tried to select card-def for non-existent card.")
		return {}
	var title = card.get("title", card.get("printed-title"))
	if title == null or str(title) == "":
		push_error("Tried to select card-def for non-existent card.")
		return {}
	if _defs.has(title):
		return _defs[title]
	return {}


static func server_card(title: String, strict: bool = false) -> Dictionary:
	if _server_cards.has(title):
		return _server_cards[title]
	if title == "Corp Basic Action Card" or title == "Runner Basic Action Card":
		return {}
	if _defs.has(title):
		var d: Dictionary = _defs[title].duplicate(true)
		d["title"] = title
		return d
	if strict:
		push_error("Tried to select server-card for %s" % title)
	return {"title": title}


static func server_cards() -> Array:
	return _server_cards.values()


static func all_titles() -> Array:
	return _defs.keys()


static func implemented(title: String) -> bool:
	return _defs.has(title)
