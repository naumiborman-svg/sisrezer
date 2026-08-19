extends RefCounted
class_name NRServer
## A Corp server: HQ, R&D, Archives, or a remote.

var id: int = 0
var server_name: String = ""
var is_central: bool = false
## Ice protecting this server. Index 0 is innermost; last index is outermost.
var ice: Array = []
## Root: agendas, assets, upgrades installed in this server.
var root: Array = []
## Central-only piles: HQ hand, R&D stack, Archives discard.
var cards: Array = []


func ice_count() -> int:
	return ice.size()


func outermost_index() -> int:
	return ice.size() - 1


func has_agenda() -> bool:
	for c in root:
		if c.card_type() == "agenda":
			return true
	return false


func has_asset() -> bool:
	for c in root:
		if c.card_type() == "asset":
			return true
	return false


func upgrades() -> Array:
	var out: Array = []
	for c in root:
		if c.card_type() == "upgrade":
			out.append(c)
	return out
