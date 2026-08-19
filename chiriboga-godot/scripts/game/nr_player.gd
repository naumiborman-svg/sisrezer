extends RefCounted
class_name NRPlayer
## Runner or Corp player state.

var side: String = "" ## "runner" or "corp"
var identity: NRCard = null
var credits: int = 5
var clicks: int = 0
var tags: int = 0
var bad_publicity: int = 0
var brain_damage: int = 0
var score_area: Array = []
## Runner-only zones / rig
var grip: Array = []
var stack: Array = []
var heap: Array = []
var programs: Array = []
var hardware: Array = []
var resources: Array = []
var link: int = 0
var base_max_hand: int = 5
var base_mu: int = 4
## Cards installed this turn (corp Seamless Launch tracking).
var installed_this_turn: Array = []
var successful_run_this_turn: bool = false
var centrals_run_this_turn: Dictionary = {"HQ": false, "R&D": false, "Archives": false}


func scored_points() -> int:
	var n := 0
	for c in score_area:
		n += c.agenda_points()
	return n


func identity_title() -> String:
	if identity == null:
		return side.capitalize()
	return identity.title()
