class_name NRCardsUpgrades
extends RefCounted

## Printed card data from game.cards.upgrades (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Adrian Seis", {
			"title": "Adrian Seis",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 2,
			"factioncost": 4,
			"keywords": "Psi - Clone - Sysop",
			"subtypes": ["Psi", "Clone", "Sysop"],
			"text": "Whenever the Runner makes a successful run on this server, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, the Runner cannot access cards other than this upgrade for the remainder of that run. If the bids match, the Runner cannot access this upgrade for the remainder of that run.\nWhen your turn ends, you may move this upgrade to the root of another server."
		})

	NRCardDefs.defcard("Akitaro Watanabe", {
			"title": "Akitaro Watanabe",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Sysop - Unorthodox",
			"subtypes": ["Sysop", "Unorthodox"],
			"text": "The rez cost of ice protecting this server is lowered by 2."
		})

	NRCardDefs.defcard("AMAZE Amusements", {
			"title": "AMAZE Amusements",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"text": "Persistent → Whenever a run on this server ends, if the Runner stole any agendas during that run, give the Runner 2 tags. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
		})

	NRCardDefs.defcard("Amazon Industrial Zone", {
			"title": "Amazon Industrial Zone",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever you install a piece of ice protecting this server, you may immediately rez it, lowering its rez cost by 3.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Angelique Garza Correa", {
			"title": "Angelique Garza Correa",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 0,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Ambush - Enforcer - Expendable",
			"subtypes": ["Ambush", "Enforcer", "Expendable"],
			"text": "Threat 3 → [click], <strong>1</strong>[credit], <strong>reveal and trash this upgrade from HQ:</strong> Do 1 meat damage. <em>(This ability is active if any player has 3 or more agenda points.)</em>\nWhen the Runner accesses this upgrade while it is rezzed, you may pay 2[credit] to do 2 meat damage."
		})

	NRCardDefs.defcard("Anoetic Void", {
			"title": "Anoetic Void",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 1,
			"factioncost": 4,
			"text": "Whenever the Runner approaches this server, you may pay 2[credit] and trash 2 cards from HQ. If you do, end the run."
		})

	NRCardDefs.defcard("Arella Salvatore", {
			"title": "Arella Salvatore",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever an agenda is scored from this server, you may install a card from HQ, ignoring all costs, and place 1 advancement token on it."
		})

	NRCardDefs.defcard("Ash 2X3ZB9CY", {
			"title": "Ash 2X3ZB9CY",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "Whenever there is a successful run on this server, Trace[4]. If successful, the Runner cannot access any cards other than Ash 2X3ZB9CY for the remainder of this run."
		})

	NRCardDefs.defcard("Awakening Center", {
			"title": "Awakening Center",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 1,
			"text": "You can install <strong>bioroid</strong> ice onto this upgrade at no install cost.\nWhenever the Runner passes all of the ice protecting this server, you may rez 1 hosted piece of ice, paying 7[credit] less. If you do, the Runner encounters that ice. When this run ends, trash that ice."
		})

	NRCardDefs.defcard("Bamboo Dome", {
			"title": "Bamboo Dome",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Install only in the root of R&D.\n[click]: Reveal the top 3 cards of R&D. Secretly choose 1 to add to HQ. Return the others to the top of R&D, in any order.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Ben Musashi", {
			"title": "Ben Musashi",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "Persistent → As an additional cost to steal an agenda from this server or its root, the Runner must suffer 2 net damage. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
		})

	NRCardDefs.defcard("Bernice Mai", {
			"title": "Bernice Mai",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever there is a successful run on this server, Trace[5]. If successful, give the Runner 1 tag. If unsuccessful, trash Bernice Mai."
		})

	NRCardDefs.defcard("Bio Vault", {
			"title": "Bio Vault",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Off-site",
			"subtypes": ["Off-site"],
			"text": "Remote server only.\nYou can advance this upgrade.\n[trash], <strong>2 hosted advancement counters:</strong> End the run. Use this ability only during a run."
		})

	NRCardDefs.defcard("Black Level Clearance", {
			"title": "Black Level Clearance",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"trash": 1,
			"factioncost": 5,
			"keywords": "Security Protocol",
			"subtypes": ["Security Protocol"],
			"text": "Whenever the Runner makes a successful run on this server, they must either suffer 1 core damage or jack out. If the Runner jacks out this way, gain 5[credit], draw 1 card, and trash this upgrade."
		})

	NRCardDefs.defcard("Brasília Government Grid", {
			"title": "Brasília Government Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Once per turn → When you rez a piece of ice during a run against this server, you may derez another installed piece of ice. If you do, the rezzed ice gets +3 strength for the remainder of that run.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Breaker Bay Grid", {
			"title": "Breaker Bay Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "The rez cost of each card in the root of this server is lowered by 5.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Bryan Stinson", {
			"title": "Bryan Stinson",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "While the Runner has fewer than 6[credit], Bryan Stinson gains \"[click]: Play a <strong>transaction</strong> operation from Archives, ignoring all costs. Remove that <strong>transaction</strong> from the game instead of trashing it.\""
		})

	NRCardDefs.defcard("Calibration Testing", {
			"title": "Calibration Testing",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Off-site",
			"subtypes": ["Off-site"],
			"text": "Remote server only.\n<strong>[trash]:</strong> Place 1 advancement counter on a card installed in the root of this server."
		})

	NRCardDefs.defcard("Caprice Nisei", {
			"title": "Caprice Nisei",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 1,
			"factioncost": 4,
			"keywords": "Clone - Psi",
			"subtypes": ["Clone", "Psi"],
			"text": "Whenever the Runner passes all of the ice protecting this server, you and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, end the run."
		})

	NRCardDefs.defcard("Cayambe Grid", {
			"title": "Cayambe Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "When your turn begins, place 1 advancement counter on a piece of ice protecting this server.\nWhenever the Runner approaches this server, end the run unless they pay 2[credit] for each advanced piece of ice protecting this server.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("ChiLo City Grid", {
			"title": "ChiLo City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"trash": 6,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever there is a successful trace during a run on this server, give the Runner 1 tag.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Code Replicator", {
			"title": "Code Replicator",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"text": "Whenever the Runner passes a rezzed piece of ice protecting this server, you may trash this upgrade. If you do, the Runner must approach that ice again. They may jack out."
		})

	NRCardDefs.defcard("Cold Site Server", {
			"title": "Cold Site Server",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "<strong>[click]:</strong> Place 1 power counter on this upgrade.\nAs an additional cost to run this server, the Runner must spend [click] and 1[credit] for each hosted power counter.\nWhen your turn begins, remove all hosted power counters."
		})

	NRCardDefs.defcard("Corporate Troubleshooter", {
			"title": "Corporate Troubleshooter",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"text": "<strong>X</strong>[credit], [trash]<strong>:</strong> Choose 1 rezzed piece of ice protecting this server. That ice gets +X strength for the remainder of the turn."
		})

	NRCardDefs.defcard("Crisium Grid", {
			"title": "Crisium Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"trash": 5,
			"factioncost": 1,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Runs against this server cannot be declared successful. <em>(This effect does not cause runs to become unsuccessful.)</em>\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Cyberdex Virus Suite", {
			"title": "Cyberdex Virus Suite",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"trash": 1,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may purge virus counters.\n<strong>[trash]:</strong> Purge virus counters."
		})

	NRCardDefs.defcard("Daniela Jorge Inácio", {
			"title": "Daniela Jorge Inácio",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "As an additional cost to trash this upgrade, the Runner must add 2 cards from the grip at random to the bottom of the stack.\nPersistent → As an additional cost to steal an agenda from this server or its root, the Runner must add 2 cards from the grip at random to the bottom of the stack."
		})

	NRCardDefs.defcard("Daruma", {
			"title": "Daruma",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 3,
			"text": "When the Runner approaches this server, you may trash this upgrade. If you do, choose 1 card in the root of another server or 1 agenda, asset, or upgrade in HQ. Swap that card with 1 card in the root of this server. If you swap cards this way, the Runner may jack out."
		})

	NRCardDefs.defcard("Dedicated Technician Team", {
			"title": "Dedicated Technician Team",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 0,
			"text": "2[recurring-credit]\nUse these credits to install ice protecting this server."
		})

	NRCardDefs.defcard("Defense Construct", {
			"title": "Defense Construct",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 0,
			"factioncost": 3,
			"text": "Defense Construct can be advanced.\n[trash]: Add 1 facedown card from Archives to HQ for each advancement token on Defense Construct. Use this ability only during a run on Archives."
		})

	NRCardDefs.defcard("Disposable HQ", {
			"title": "Disposable HQ",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 5,
			"factioncost": 1,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may add any number of cards from HQ to the bottom of R&D."
		})

	NRCardDefs.defcard("Djupstad Grid", {
			"title": "Djupstad Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"trash": 4,
			"factioncost": 4,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever you score an agenda from the root of this server, do 1 core damage.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Drone Screen", {
			"title": "Drone Screen",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 4,
			"factioncost": 2,
			"text": "If the Runner is tagged, Drone Screen gains \"Whenever the Runner initiates a run on this server, Trace[3]. If successful, do 1 meat damage (cannot be prevented).\""
		})

	NRCardDefs.defcard("Embolus", {
			"title": "Embolus",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 1,
			"text": "When your turn begins, you may pay 1[credit] to place 1 power counter on this upgrade.\nWhenever the Runner makes a successful run, remove 1 power counter from this upgrade.\n<strong>Hosted power counter</strong>: End the run. Use this ability only during a run on this server."
		})

	NRCardDefs.defcard("Experiential Data", {
			"title": "Experiential Data",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 1,
			"text": "All ice protecting this server has +1 strength."
		})

	NRCardDefs.defcard("Expo Grid", {
			"title": "Expo Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "When your turn begins, gain 1[credit] if there is a rezzed asset installed in the root of this server.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Forced Connection", {
			"title": "Forced Connection",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, Trace[3]. If successful, give the Runner 2 tags."
		})

	NRCardDefs.defcard("Flagship", {
			"title": "Flagship",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 3,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Ritzy",
			"subtypes": ["Ritzy"],
			"text": "HQ or R&D only.\nRuns against this server cannot be declared successful. <em>(This effect does not cause runs to become unsuccessful.)</em>\nPersistent → During each run against this server, the Runner cannot access more than 1 card other than this upgrade."
		})

	NRCardDefs.defcard("Fractal Threat Matrix", {
			"title": "Fractal Threat Matrix",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Security Protocol",
			"subtypes": ["Security Protocol"],
			"text": "Each time all the subroutines are broken on a piece of ice protecting this server, trash the top 2 cards of the stack."
		})

	NRCardDefs.defcard("Ganked!", {
			"title": "Ganked!",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may trash it to choose a rezzed piece of ice protecting this server. The Runner encounters that ice."
		})

	NRCardDefs.defcard("Georgia Emelyov", {
			"title": "Georgia Emelyov",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever the Runner makes an unsuccessful run on this server, do 1 net damage.\n2[credit]: Move Georgia Emelyov to another server."
		})

	NRCardDefs.defcard("Giordano Memorial Field", {
			"title": "Giordano Memorial Field",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "Whenever the Runner makes a successful run on this server, end the run unless they pay 2[credit] for each agenda in their score area."
		})

	NRCardDefs.defcard("Heinlein Grid", {
			"title": "Heinlein Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever the Runner loses or spends [click] during a run on this server, they lose all credits in their credit pool.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Helheim Servers", {
			"title": "Helheim Servers",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "<strong>Trash 1 card from HQ</strong>: All ice protecting this server has +2 strength until the end of the run. Use this ability only during a run on this server."
		})

	NRCardDefs.defcard("Henry Phillips", {
			"title": "Henry Phillips",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever the Runner breaks a subroutine during a run on this server, gain 2[credit] if they are tagged."
		})

	NRCardDefs.defcard("Hired Help", {
			"title": "Hired Help",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Orgcrime - Enforcer",
			"subtypes": ["Orgcrime", "Enforcer"],
			"text": "As an additional cost to run this server, the Runner must trash 1 agenda from their score area. Ignore this ability if the Runner made a successful run on HQ this turn.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Hokusai Grid", {
			"title": "Hokusai Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever the Runner makes a successful run on this server, do 1 net damage.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Hype Machine", {
			"title": "Hype Machine",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "As long as an agenda was scored or stolen this turn, the rez cost of this upgrade is lowered by 6[credit].\n[trash]<strong>:</strong> Place 1 advancement counter on a card you can advance in the root of this server."
		})

	NRCardDefs.defcard("Increased Drop Rates", {
			"title": "Increased Drop Rates",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, remove 1 bad publicity unless they take 1 tag."
		})

	NRCardDefs.defcard("Intake", {
			"title": "Intake",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 3,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, Trace[4]. If successful, add 1 installed program or <strong>virtual</strong> resource to the grip."
		})

	NRCardDefs.defcard("Isaac Liberdade", {
			"title": "Isaac Liberdade",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 3,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Bioroid - Sysop",
			"subtypes": ["Bioroid", "Sysop"],
			"text": "Each advanced piece of ice protecting this server gets +2 strength.\nWhenever this upgrade moves to the root of a server, you may place 1 advancement counter on a piece of ice protecting that server that has no advancement counters.\nWhen your turn ends, you may move this upgrade to the root of another server."
		})

	NRCardDefs.defcard("Jinja City Grid", {
			"title": "Jinja City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever you draw a piece of ice, you may reveal it and install it protecting this server, paying 4[credit] less.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("K. P. Lynn", {
			"title": "K. P. Lynn",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Whenever the Runner passes all of the ice protecting this server, they must take 1 tag or end the run."
		})

	NRCardDefs.defcard("Keegan Lane", {
			"title": "Keegan Lane",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "[trash], <strong>remove 1 tag:</strong> Trash 1 program. Use this ability only during a run on this server."
		})

	NRCardDefs.defcard("Khondi Plaza", {
			"title": "Khondi Plaza",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 3,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Ritzy",
			"subtypes": ["Ritzy"],
			"text": "X[recurring-credit]\nUse these credits to rez ice protecting this server. X is the number of remote servers."
		})

	NRCardDefs.defcard("La Costa Grid", {
			"title": "La Costa Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Region - Seedy",
			"subtypes": ["Region", "Seedy"],
			"text": "Remote server only.\nWhen your turn begins, place 1 advancement counter on a card in the root of this server.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Letheia Nisei", {
			"title": "Letheia Nisei",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Psi - Clone",
			"subtypes": ["Psi", "Clone"],
			"text": "The first time the Runner approaches this server during each run, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, you may trash this upgrade. If you do, the Runner moves to the outermost position of this server. They may jack out."
		})

	NRCardDefs.defcard("Mahkota Langit Grid", {
			"title": "Mahkota Langit Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "2[recurring-credit] <em>(When you rez this upgrade and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to rez assets in the root of this server and ice protecting this server.\nPersistent → The trash cost of each asset in the root of this server is increased by 2[credit].\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Malapert Data Vault", {
			"title": "Malapert Data Vault",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 1,
			"trash": 4,
			"factioncost": 3,
			"text": "Whenever you score an agenda from the root of this server, you may search R&D for 1 non-agenda card and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that card to HQ."
		})

	NRCardDefs.defcard("Manegarm Skunkworks", {
			"title": "Manegarm Skunkworks",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 3,
			"text": "Whenever the Runner approaches this server, end the run unless they either spend [click][click] or pay 5[credit]."
		})

	NRCardDefs.defcard("Manta Grid", {
			"title": "Manta Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "If the Runner has fewer than 6[credit] or no unspent clicks when a successful run on this server ends, you have 1 additional [click] to spend your next turn.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Marcus Batty", {
			"title": "Marcus Batty",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 1,
			"factioncost": 3,
			"keywords": "Sysop - Psi",
			"subtypes": ["Sysop", "Psi"],
			"text": "[trash]: You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, resolve 1 subroutine on a rezzed piece of ice protecting this server. Use this ability only during a run on this server."
		})

	NRCardDefs.defcard("Mason Bellamy", {
			"title": "Mason Bellamy",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever an encounter with a piece of ice protecting this server ends, if the Runner broke at least 1 subroutine during that encounter, they lose [click]."
		})

	NRCardDefs.defcard("Mavirus", {
			"title": "Mavirus",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 0,
			"factioncost": 1,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade, you may purge virus counters. If this upgrade is rezzed, do 1 net damage.\n[trash]<strong>:</strong> Purge virus counters."
		})

	NRCardDefs.defcard("Mercia B4LL4RD", {
			"title": "Mercia B4LL4RD",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Bioroid - Academic",
			"subtypes": ["Bioroid", "Academic"],
			"text": "When your action phase ends, you may install 1 piece of ice from HQ, paying 1[credit] less. If you do, move this upgrade to the root of the server that piece of ice is protecting."
		})

	NRCardDefs.defcard("Midori", {
			"title": "Midori",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever the Runner approaches a piece of ice protecting this server, you may swap that ice with 1 piece of ice from HQ. <em>(The new ice is installed unrezzed.)</em> If you do, the Runner may jack out. Use this ability only once per run."
		})

	NRCardDefs.defcard("Midway Station Grid", {
			"title": "Midway Station Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"trash": 4,
			"factioncost": 4,
			"keywords": "Beanstalk - Region",
			"subtypes": ["Beanstalk", "Region"],
			"text": "During runs on this server, the Runner must pay 1[credit] as an additional cost to use an <strong>icebreaker</strong> ability to break subroutines.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Mitra Aman", {
			"title": "Mitra Aman",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "Whenever the Runner approaches a piece of ice protecting this server, you may trash this upgrade. If you do, gain 3[credit] and you may swap the ice being approached with a piece of ice from Archives or HQ."
		})

	NRCardDefs.defcard("Mr. Hendrik", {
			"title": "Mr. Hendrik",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Ambush - Sysop",
			"subtypes": ["Ambush", "Sysop"],
			"text": "When the Runner accesses this upgrade while it is installed, you may pay 2[credit] to do 1 core damage. If the Runner has any [click] remaining, they may lose all their [click] to prevent this damage."
		})

	NRCardDefs.defcard("Mumbad City Grid", {
			"title": "Mumbad City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever the Runner passes a piece of ice protecting this server, you may swap that ice with another piece of ice protecting this server.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Mumbad Virtual Tour", {
			"title": "Mumbad Virtual Tour",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Alliance",
			"subtypes": ["Alliance"],
			"text": "This upgrade costs 0 influence if you have 7 or more assets in your deck.\nWhen the Runner accesses this upgrade while it is installed, they must trash it, if able."
		})

	NRCardDefs.defcard("Mwanza City Grid", {
			"title": "Mwanza City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 5,
			"factioncost": 1,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Root of HQ or R&D only.\nWhenever the Runner breaches this server, they access 3 additional cards. When the breach ends, gain 2[credit] for each time the Runner accessed a card during that breach.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Nanisivik Grid", {
			"title": "Nanisivik Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever the Runner approaches this server, you may turn 1 facedown piece of ice in Archives faceup. If you do, resolve 1 subroutine on that ice.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Navi Mumbai City Grid", {
			"title": "Navi Mumbai City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "During runs on this server, the Runner cannot use paid abilities on their installed cards except for mid-access abilities and abilities on <strong>icebreakers</strong>.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("NeoTokyo Grid", {
			"title": "NeoTokyo Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "The first time each turn an advancement counter is placed on a card in the root of this server, gain 1[credit].\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Nihongai Grid", {
			"title": "Nihongai Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever the Runner makes a successful run on this server, if they do not have at least 2 cards in the grip and 6[credit], you may look at the top 5 cards of R&D and swap 1 of those cards with 1 card in HQ.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Oaktown Grid", {
			"title": "Oaktown Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "The trash cost of each card in the root of this server is increased by 3.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Oberth Protocol", {
			"title": "Oberth Protocol",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 4,
			"text": "As an additional cost to rez this upgrade, forfeit 1 agenda.\nThe first time each turn you advance a card in the root of or protecting this server, place 1 more advancement counter on that card."
		})

	NRCardDefs.defcard("Off the Grid", {
			"title": "Off the Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"trash": 0,
			"factioncost": 3,
			"text": "Install only in a remote server.\nThe Runner cannot initiate a run on this server.\nWhenever the Runner makes a successful run on HQ, trash Off the Grid."
		})

	NRCardDefs.defcard("Old Hollywood Grid", {
			"title": "Old Hollywood Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Persistent → The Runner cannot steal agendas from this server or its root. Ignore this ability for any agenda the Runner has a copy of in their score area. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Overseer Matrix", {
			"title": "Overseer Matrix",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 4,
			"text": "Persistent → Whenever the Runner trashes a card from this server or its root, you may pay 1[credit] to give the Runner 1 tag. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
		})

	NRCardDefs.defcard("Panic Button", {
			"title": "Panic Button",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 1,
			"text": "Install only in the root of HQ.\n1[credit]: Draw 1 card. Use this ability only during a run on HQ."
		})

	NRCardDefs.defcard("Perfect Recall", {
			"title": "Perfect Recall",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"text": "When you rez this upgrade and whenever an agenda is scored or stolen from this server or its root, place 1 power counter on this upgrade.\n<strong>Hosted power counter:</strong> Reveal 1 card in HQ. The Runner cannot steal or trash copies of that card for the remainder of this run. Use this ability only during a run."
		})

	NRCardDefs.defcard("Port Anson Grid", {
			"title": "Port Anson Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "As an additional cost to jack out during a run on this server, the Runner must trash 1 installed program.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Prisec", {
			"title": "Prisec",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "If the Runner accesses Prisec while installed, you may pay 2[credit] to give the Runner 1 tag and do 1 meat damage."
		})

	NRCardDefs.defcard("Product Placement", {
			"title": "Product Placement",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, gain 2[credit]."
		})

	NRCardDefs.defcard("Red Herrings", {
			"title": "Red Herrings",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 2,
			"text": "Persistent → As an additional cost to steal an agenda from this server or its root, the Runner must pay 5[credit]. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
		})

	NRCardDefs.defcard("Reduced Service", {
			"title": "Reduced Service",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 0,
			"trash": 2,
			"factioncost": 3,
			"text": "When you rez this upgrade, you may pay up to 4[credit] to place that many power counters on it.\nAs an additional cost to run this server, the Runner must pay 2[credit] for each hosted power counter.\nWhenever the Runner makes a successful run on a central server, remove 1 hosted power counter."
		})

	NRCardDefs.defcard("Research Station", {
			"title": "Research Station",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "Install only in the root of HQ.\nYour maximum hand size is +2."
		})

	NRCardDefs.defcard("Ruhr Valley", {
			"title": "Ruhr Valley",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "As an additional cost to make a run on this server, the Runner must spend [click].\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Rutherford Grid", {
			"title": "Rutherford Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "The base trace strength of each trace during a run on this server is increased by 2.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Ryon Knight", {
			"title": "Ryon Knight",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "[trash]: Do 1 core damage. Use this ability only during a run against this server and only if the Runner has no unspent [click]."
		})

	NRCardDefs.defcard("SanSan City Grid", {
			"title": "SanSan City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Each agenda in the root of this server gets −1 advancement requirement.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Satellite Grid", {
			"title": "Satellite Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Each piece of ice protecting this server is considered to have 1 additional advancement token on it.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Self-destruct", {
			"title": "Self-destruct",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 0,
			"factioncost": 0,
			"text": "Remote server only.\n<strong>[trash]:</strong> Trash all cards installed in the root of or protecting this server. Trace[X], where X is equal to the number of cards trashed. If successful, do 3 net damage. Use this ability only during a run on this server."
		})

	NRCardDefs.defcard("Shackleton Grid", {
			"title": "Shackleton Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Once per turn → When the Runner spends credits from outside their credit pool during a run against this server, you may do 4 meat damage.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Shell Corporation", {
			"title": "Shell Corporation",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 0,
			"text": "You cannot use this upgrade more than once per turn.\n[click]<strong>:</strong> Place 3[credit] on this upgrade.\n[click]<strong>:</strong> Take all credits from this upgrade."
		})

	NRCardDefs.defcard("Signal Jamming", {
			"title": "Signal Jamming",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 0,
			"text": "[trash]: Cards cannot be installed until the end of the run. Use this ability only during a run on this server."
		})

	NRCardDefs.defcard("Simone Diego", {
			"title": "Simone Diego",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 4,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "2[recurring-credit]\nYou can spend hosted credits to take the basic action to advance cards in the root of or protecting this server."
		})

	NRCardDefs.defcard("Strongbox", {
			"title": "Strongbox",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"trash": 1,
			"factioncost": 2,
			"text": "Persistent → As an additional cost to steal an agenda from this server or its root, the Runner must spend [click]. <em>(If the Runner trashes this card while accessing it, this ability still applies for the remainder of this run.)</em>"
		})

	NRCardDefs.defcard("Surat City Grid", {
			"title": "Surat City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever you rez another card in the root of or protecting this server, you may rez 1 card, paying 2[credit] less.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Tempus", {
			"title": "Tempus",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 3,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this upgrade in R&D, they must reveal it.\nWhen the Runner accesses this upgrade anywhere except in Archives, Trace[3]. If successful, the Runner must lose [click][click] or suffer 1 core damage."
		})

	NRCardDefs.defcard("The Holo Man", {
			"title": "The Holo Man",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Academic - Executive - Sysop",
			"subtypes": ["Academic", "Executive", "Sysop"],
			"text": "When your turn begins, you may move this upgrade to the root of another server.\nOnce per turn → [click], <strong>4[credit]:</strong> Place 2 advancement counters on 1 card in the root of or protecting this server. If you have not installed any cards from HQ this turn, instead place 3 advancement counters on that card."
		})

	NRCardDefs.defcard("The Red Room", {
			"title": "The Red Room",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "Central server only.\nThe first time each turn an agenda is scored or stolen, place 1 power counter on this upgrade.\n<strong>Hosted power counter:</strong> End the run. Use this ability only during a run against another server."
		})

	NRCardDefs.defcard("The Twins", {
			"title": "The Twins",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "Whenever the Runner passes a rezzed piece of ice protecting this server, you may reveal and trash another copy of that ice from HQ to force the Runner to encounter the piece of ice just passed again."
		})

	NRCardDefs.defcard("Tori Hanzō", {
			"title": "Tori Hanzō",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 3,
			"trash": 2,
			"factioncost": 4,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "[interrupt] → The first time you would do 1 or more net damage during each run against this server, instead you may pay 2[credit] to do 1 core damage."
		})

	NRCardDefs.defcard("Traffic Analyzer", {
			"title": "Traffic Analyzer",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"text": "Whenever you rez a piece of ice protecting this server, Trace[2]. If successful, the Corp gains 1[credit]."
		})

	NRCardDefs.defcard("Tranquility Home Grid", {
			"title": "Tranquility Home Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Remote server only.\nThe first time each turn you install a card in the root of this server, gain 2[credit] or draw 1 card.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Tucana", {
			"title": "Tucana",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 1,
			"factioncost": 3,
			"text": "Remote server only.\nPersistent → Whenever an agenda is scored or stolen from the root of this server, you may search R&D for 1 piece of ice. <em>(Shuffle R&D after searching it.)</em> Install and rez that ice, paying a total of 3[credit] less."
		})

	NRCardDefs.defcard("Tyr's Hand", {
			"title": "Tyr's Hand",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 1,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "[interrupt] → When a subroutine would be broken on a piece of <strong>bioroid</strong> ice protecting this server, you may rez this upgrade.\n[interrupt] → <strong>[trash]:</strong> Prevent 1 subroutine from being broken on a piece of <strong>bioroid</strong> ice protecting this server."
		})

	NRCardDefs.defcard("Underway Grid", {
			"title": "Underway Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 0,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Ice protecting this server cannot be bypassed.\nCards in the root of and/or protecting this server cannot be exposed.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Valley Grid", {
			"title": "Valley Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Whenever the Runner fully breaks a piece of ice protecting this server, they get -1 maximum hand size until the beginning of your next turn.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Vladisibirsk City Grid", {
			"title": "Vladisibirsk City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"trash": 4,
			"factioncost": 4,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "You can advance this upgrade.\nOnce per turn → <strong>2 hosted advancement counters:</strong> Place 2 advancement counters on another card you can advance in the root of this server.\nLimit 1 <strong>region</strong> per server."
		})

	NRCardDefs.defcard("Vovô Ozetti", {
			"title": "Vovô Ozetti",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Sysop",
			"subtypes": ["Sysop"],
			"text": "The rez cost of each piece of ice protecting this server is lowered by 2[credit].\nThreat 4 → The rez cost of each card in the root of this server is lowered by 2[credit]. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nWhen your turn ends, you may move this upgrade to the root of another server."
		})

	NRCardDefs.defcard("Warroid Tracker", {
			"title": "Warroid Tracker",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "Whenever the Runner trashes at least 1 card from this server, from its root, or protecting it, Trace[4]. If successful, the Runner trashes 2 of their installed cards."
		})

	NRCardDefs.defcard("Will-o'-the-Wisp", {
			"title": "Will-o'-the-Wisp",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"trash": 1,
			"factioncost": 0,
			"text": "Whenever the Runner makes a successful run on this server, you may trash this upgrade. If you do, choose 1 installed <strong>icebreaker</strong> that was used to break at least 1 subroutine during this run. The Runner adds that <strong>icebreaker</strong> to the bottom of the stack."
		})

	NRCardDefs.defcard("Yakov Erikovich Avdakov", {
			"title": "Yakov Erikovich Avdakov",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Whenever a player trashes a card <em>(including this upgrade)</em> from the root of this server or protecting it, except during installation, gain 2[credit]."
		})

	NRCardDefs.defcard("ZATO City Grid", {
			"title": "ZATO City Grid",
			"type": "Upgrade",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Region",
			"subtypes": ["Region"],
			"text": "Remote server only.\nEach piece of ice protecting this server gains \"When the Runner encounters this ice, choose 1 subroutine on it. You may trash this ice to resolve that subroutine.\".\nLimit 1 <strong>region</strong> per server."
		})
