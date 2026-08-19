class_name NRIdentities
extends RefCounted

## Port of game.core.identities.


static func initialize_identity(state: NRState, side: Variant) -> void:
	var s = NRUtil.to_side(side)
	var ident: Dictionary = state.get_in([s, "identity"], {})
	if ident.is_empty():
		return
	ident = ident.duplicate(true)
	ident["zone"] = ["identity"]
	ident["installed"] = true
	ident["rezzed"] = true
	NRUpdate.update_card(state, s, ident)
	NRInitializing.card_init(state, s, ident)


static func is_type(card: Dictionary, typ: String) -> bool:
	return NRCard.has_subtype(card, typ)
