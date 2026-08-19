class_name NRThreat
extends RefCounted

## Port of game.core.threat.


static func threat_level(state: NRState, _side: Variant = "corp") -> int:
	return int(state.get_in(["corp", "agenda-point"], 0))


static func threat(state: NRState, n: int) -> bool:
	return threat_level(state) >= n
