class_name NRCardsCorp
extends RefCounted

## Registers all translated Corporation card files (ICE, assets, operations, agendas, upgrades).


static var _registered := false


static func register() -> void:
	if _registered:
		return
	_registered = true
	NRCardsIce.register()
	NRCardsAssets.register()
	NRCardsOperations.register()
	NRCardsAgendas.register()
	NRCardsUpgrades.register()
