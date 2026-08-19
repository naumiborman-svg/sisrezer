class_name NRVirus
extends RefCounted
## Virus counters. Port of game.core.virus.

static func get_virus_counters(state: NRState, card: Dictionary) -> int:
	var cards: Array = [card]
	if NRCard.virus_program(card):
		for c in NRBoard.all_active_installed(state, "runner"):
			if str(c.get("title")) == "Hivemind":
				cards.append(c)
	var n := 0
	for c in cards:
		n += NRCard.get_counters(c, "virus")
	return n


static func count_virus_programs(state: NRState) -> int:
	var n := 0
	for c in NRBoard.all_active_installed(state, "runner"):
		if NRCard.virus_program(c):
			n += 1
	return n


static func number_of_virus_counters(state: NRState) -> int:
	var n := 0
	for c in NRBoard.get_all_installed(state):
		n += NRCard.get_counters(c, "virus")
	return n


static func number_of_runner_virus_counters(state: NRState) -> int:
	var n := 0
	for c in NRBoard.all_installed(state, "runner"):
		n += NRCard.get_counters(c, "virus")
	return n
