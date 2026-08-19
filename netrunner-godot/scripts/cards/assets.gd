class_name NRCardsAssets
extends RefCounted

## Printed card data from game.cards.assets (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Adonis Campaign", {
			"title": "Adonis Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "Put 12[credit] from the bank on Adonis Campaign when rezzed. When there are no credits left on Adonis Campaign, trash it.\nTake 3[credit] from Adonis Campaign when your turn begins."
		})

	NRCardDefs.defcard("Advanced Assembly Lines", {
			"title": "Advanced Assembly Lines",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "When you rez Advanced Assembly Lines, gain 3[credit].\n[trash]: Install a non-agenda card from HQ (paying the install cost). You cannot use this ability during a run."
		})

	NRCardDefs.defcard("Aggressive Secretary", {
			"title": "Aggressive Secretary",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "Aggressive Secretary can be advanced.\nIf you pay 2[credit] when the Runner accesses Aggressive Secretary, trash 1 program for each advancement token on Aggressive Secretary."
		})

	NRCardDefs.defcard("Alexa Belsky", {
			"title": "Alexa Belsky",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "[trash]: Shuffle all cards in HQ into R&D. The Runner may pay any number of credits to prevent 1 random card in HQ from being shuffled into R&D for every 2[credit] spent."
		})

	NRCardDefs.defcard("Alix T4LB07", {
			"title": "Alix T4LB07",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "Place 1 power counter on Alix T4LB07 whenever you install a card.\n[click],[trash]: Gain 2[credit] for each power counter on Alix T4LB07."
		})

	NRCardDefs.defcard("Allele Repression", {
			"title": "Allele Repression",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 3,
			"text": "Allele Repression can be advanced.\n[trash]: Swap 1 card in HQ with 1 card in Archives for each advancement token on Allele Repression."
		})

	NRCardDefs.defcard("Amani Senai", {
			"title": "Amani Senai",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 4,
			"factioncost": 4,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever an agenda is scored or stolen, you may trace[X]. If successful, add an installed Runner card to the grip. X is the advancement requirement of the scored or stolen agenda."
		})

	NRCardDefs.defcard("Anson Rose", {
			"title": "Anson Rose",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 1,
			"trash": 4,
			"factioncost": 1,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "When your turn begins, place 1 advancement token on Anson Rose.\nWhenever you rez a piece of ice, you may move any number of advancement tokens from Anson Rose to that ice."
		})

	NRCardDefs.defcard("Anthill Excavation Contract", {
			"title": "Anthill Excavation Contract",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Industrial",
			"subtypes": ["Industrial"],
			"text": "When you rez this asset, load 8[credit] onto it. When it is empty, trash it.\nWhen your turn begins, take 4[credit] from this asset and draw 1 card."
		})

	NRCardDefs.defcard("API-S Keeper Isobel", {
			"title": "API-S Keeper Isobel",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "When your turn begins, you may remove an advancement token from an installed card to gain 3[credit]."
		})

	NRCardDefs.defcard("Aryabhata Tech", {
			"title": "Aryabhata Tech",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Ritzy",
			"subtypes": ["Ritzy"],
			"text": "Whenever there is a successful trace, gain 1[credit] and the Runner loses 1[credit]."
		})

	NRCardDefs.defcard("B-1001", {
			"title": "B-1001",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 0,
			"keywords": "Bioroid - Enforcer",
			"subtypes": ["Bioroid", "Enforcer"],
			"text": "<strong>Remove 1 tag:</strong> End the run. Use this ability only during a run against another server."
		})

	NRCardDefs.defcard("Balanced Coverage", {
			"title": "Balanced Coverage",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Seedy",
			"subtypes": ["Seedy"],
			"text": "When your turn begins, you may choose a card type to look at the top card of R&D. If that card has the chosen type, you may reveal it and gain 2[credit]."
		})

	NRCardDefs.defcard("Bass CH1R180G4", {
			"title": "Bass CH1R180G4",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "[click], <strong>[trash]:</strong> Gain [click][click]."
		})

	NRCardDefs.defcard("Behold!", {
			"title": "Behold!",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset anywhere except in Archives, you may pay 4[credit] to give them 2 tags."
		})

	NRCardDefs.defcard("Bio-Ethics Association", {
			"title": "Bio-Ethics Association",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political",
			"subtypes": ["Political"],
			"text": "When your turn begins, do 1 net damage if there is no ice protecting this server."
		})

	NRCardDefs.defcard("Bioroid Work Crew", {
			"title": "Bioroid Work Crew",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 4,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "<strong>[trash]:</strong> Install 1 card from HQ. Use this ability only during the next paid ability window after playing and resolving an operation."
		})

	NRCardDefs.defcard("Blacklist", {
			"title": "Blacklist",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"text": "Cards cannot leave the Runner's heap for any reason."
		})

	NRCardDefs.defcard("Bladderwort", {
			"title": "Bladderwort",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "When your turn begins, gain 1[credit]. Then, if you have 4[credit] or less, do 1 net damage."
		})

	NRCardDefs.defcard("Brain-Taping Warehouse", {
			"title": "Brain-Taping Warehouse",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 4,
			"factioncost": 1,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "The rez cost of <strong>bioroid</strong> ice is lowered by 1 for each unspent click the Runner has."
		})

	NRCardDefs.defcard("Breached Dome", {
			"title": "Breached Dome",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, do 1 meat damage and trash the top card of the stack."
		})

	NRCardDefs.defcard("Broadcast Square", {
			"title": "Broadcast Square",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "[interrupt] → Whenever you would take bad publicity, trace[3]. If successful, prevent all of that bad publicity."
		})

	NRCardDefs.defcard("Byte!", {
			"title": "Byte!",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset anywhere except in Archives, you may pay 4[credit]. If you do, give the Runner 1 tag and do 3 net damage."
		})

	NRCardDefs.defcard("C.I. Fund", {
			"title": "C.I. Fund",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"text": "When your turn begins, you may move up to 3[credit] from your credit pool to C.I. Fund.\nWhen your turn begins, place 2[credit] on C.I. Fund from the bank if there are at least 6[credit] on it.\n2[credit],[trash]: Take all credits from C.I. Fund."
		})

	NRCardDefs.defcard("Calvin B4L3Y", {
			"title": "Calvin B4L3Y",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "Once per turn → [click]<strong>:</strong> Draw 2 cards.\nWhen the Runner trashes this asset, you may draw 2 cards."
		})

	NRCardDefs.defcard("Capital Investors", {
			"title": "Capital Investors",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"text": "[click]: Gain 2[credit]."
		})

	NRCardDefs.defcard("Cerebral Overwriter", {
			"title": "Cerebral Overwriter",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "You can advance this asset.\nWhen the Runner accesses this asset while it is installed, you may pay 3[credit] to do X core damage. X is equal to the number of hosted advancement counters."
		})

	NRCardDefs.defcard("Chairman Hiro", {
			"title": "Chairman Hiro",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 6,
			"factioncost": 5,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "The Runner gets -2 maximum hand size.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
		})

	NRCardDefs.defcard("Charlotte Caçador", {
			"title": "Charlotte Caçador",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "You can advance this asset.\nWhen your turn begins, you may remove 1 hosted advancement counter to gain 4[credit] and draw 1 card.\n[trash], <strong>hosted advancement counter:</strong> Gain 3[credit]."
		})

	NRCardDefs.defcard("Chekist Scion", {
			"title": "Chekist Scion",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "You can advance this asset.\nWhen the Runner accesses this asset while it is installed, give them 1 tag plus 1 tag for each hosted advancement counter."
		})

	NRCardDefs.defcard("Chief Slee", {
			"title": "Chief Slee",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever an encounter with a piece of ice ends, place 1 power counter on Chief Slee for each unbroken subroutine on the encountered piece of ice.\n[click], <strong>5 hosted power counters</strong>: Do 5 meat damage."
		})

	NRCardDefs.defcard("City Surveillance", {
			"title": "City Surveillance",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"trash": 3,
			"factioncost": 4,
			"text": "When the Runner's turn begins, give them 1 tag unless they pay 1[credit]."
		})

	NRCardDefs.defcard("Clearinghouse", {
			"title": "Clearinghouse",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "You can advance this asset.\nWhen your turn begins, you may trash this asset to do 1 meat damage for each hosted advancement counter."
		})

	NRCardDefs.defcard("Clone Suffrage Movement", {
			"title": "Clone Suffrage Movement",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political",
			"subtypes": ["Political"],
			"text": "When your turn begins, you may add 1 operation from Archives to HQ if there is no ice protecting this server."
		})

	NRCardDefs.defcard("Clyde Van Rite", {
			"title": "Clyde Van Rite",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "When your turn begins, the Runner must pay 1[credit] or trash the top card of the stack."
		})

	NRCardDefs.defcard("Cohort Guidance Program", {
			"title": "Cohort Guidance Program",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "When your turn begins, you may resolve 1 of the following:<ul><li>Trash 1 card from HQ. If you do, gain 2[credit] and draw 1 card.</li><li>Turn 1 facedown card in Archives faceup. If you do, place 1 advancement counter on an installed card.</li></ul>"
		})

	NRCardDefs.defcard("Commercial Bankers Group", {
			"title": "Commercial Bankers Group",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political",
			"subtypes": ["Political"],
			"text": "When your turn begins, gain 3[credit] if there is no ice protecting this server."
		})

	NRCardDefs.defcard("Constellation Protocol", {
			"title": "Constellation Protocol",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 2,
			"text": "When your turn begins, you may move an advancement token from a piece of ice to an installed piece of ice that can be advanced."
		})

	NRCardDefs.defcard("Contract Killer", {
			"title": "Contract Killer",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "Contract Killer can be advanced.\nIf there are at least 2 advancement tokens on Contract Killer, it gains: \"[click], [trash]: Trash a <strong>connection</strong> or do 2 meat damage.\""
		})

	NRCardDefs.defcard("Corporate Town", {
			"title": "Corporate Town",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"text": "As an additional cost to rez this asset, forfeit 1 agenda.\nWhen your turn begins, you may trash 1 installed resource. Trashing a resource this way cannot be prevented."
		})

	NRCardDefs.defcard("CPC Generator", {
			"title": "CPC Generator",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "The first time the Runner spends [click] to gain 1[credit] each turn (not through a card effect), gain 1[credit]."
		})

	NRCardDefs.defcard("CSR Campaign", {
			"title": "CSR Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When your turn begins, you may draw 1 card."
		})

	NRCardDefs.defcard("Cybernetics Court", {
			"title": "Cybernetics Court",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 0,
			"trash": 5,
			"factioncost": 5,
			"keywords": "Facility - Ritzy",
			"subtypes": ["Facility", "Ritzy"],
			"text": "Your maximum hand size is increased by 4."
		})

	NRCardDefs.defcard("Cybersand Harvester", {
			"title": "Cybersand Harvester",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 2,
			"text": "Whenever you rez a piece of ice, place 2[credit] on this asset.\nYou can spend hosted credits to pay install costs.\n[trash]<strong>:</strong> Take all credits from this asset."
		})

	NRCardDefs.defcard("Daily Business Show", {
			"title": "Daily Business Show",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 1,
			"keywords": "Cast",
			"subtypes": ["Cast"],
			"text": "[interrupt] → The first time each turn you would draw any number of cards, increase the number of cards you will draw by 1. When you draw those cards, add 1 of them to the bottom of R&D."
		})

	NRCardDefs.defcard("Daily Quest", {
			"title": "Daily Quest",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"text": "Rez only during your action phase.\nWhenever the Runner makes a successful run on this server, they gain 2[credit].\nWhen your turn begins, if the Runner did not make a successful run on this server during their last turn, gain 3[credit]."
		})

	NRCardDefs.defcard("Dedicated Response Team", {
			"title": "Dedicated Response Team",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "If the Runner is tagged, Dedicated Response Team gains \"Whenever a successful run ends, do 2 meat damage.\""
		})

	NRCardDefs.defcard("Dedicated Server", {
			"title": "Dedicated Server",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "2[recurring-credit]\nUse these credits to rez ice."
		})

	NRCardDefs.defcard("Director Haas", {
			"title": "Director Haas",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"trash": 5,
			"factioncost": 5,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "You get +1 allotted [click] for each of your turns.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
		})

	NRCardDefs.defcard("Docklands Crackdown", {
			"title": "Docklands Crackdown",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 0,
			"text": "[click], [click]: Place 1 power counter on Docklands Crackdown.\nThe install cost of the first card the Runner installs each turn is increased by 1 for each power counter on Docklands Crackdown."
		})

	NRCardDefs.defcard("Dr. Vientiane Keeling", {
			"title": "Dr. Vientiane Keeling",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 3,
			"trash": 4,
			"factioncost": 4,
			"keywords": "Academic",
			"subtypes": ["Academic"],
			"text": "When you rez this asset and when your turn begins, place 1 power counter on this asset.\nThe Runner gets -1 maximum hand size for each hosted power counter."
		})

	NRCardDefs.defcard("Drago Ivanov", {
			"title": "Drago Ivanov",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 0,
			"trash": 1,
			"factioncost": 4,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "You can advance this asset.\n<strong>2 hosted advancement counters:</strong> Give the Runner 1 tag. Use this ability only during your turn."
		})

	NRCardDefs.defcard("Drudge Work", {
			"title": "Drudge Work",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"text": "Place 3 power counters on Drudge Work when it is rezzed. When there are no power counters left on Drudge Work, trash it.\n[click], <strong>hosted power counter</strong>: Reveal an agenda in HQ or Archives. Gain credits equal to its agenda points, then shuffle it into R&D."
		})

	NRCardDefs.defcard("Early Premiere", {
			"title": "Early Premiere",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 3,
			"text": "When your turn begins, you may pay 1[credit]. If you do, place 1 advancement counter on a card you can advance in the root of a server."
		})

	NRCardDefs.defcard("Echo Chamber", {
			"title": "Echo Chamber",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"trash": 1,
			"factioncost": 4,
			"text": "[click], [click], [click]: Add Echo Chamber to your score area as an agenda worth 1 agenda point."
		})

	NRCardDefs.defcard("Edge of World", {
			"title": "Edge of World",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "When the Runner accesses this asset while it is installed, you may pay 3[credit]. If you do, do 1 core damage for each piece of ice protecting this server."
		})

	NRCardDefs.defcard("Eliza's Toybox", {
			"title": "Eliza's Toybox",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 4,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Ritzy",
			"subtypes": ["Ritzy"],
			"text": "[click],[click],[click]: Rez a card, ignoring all costs."
		})

	NRCardDefs.defcard("Elizabeth Mills", {
			"title": "Elizabeth Mills",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Executive - Liability",
			"subtypes": ["Executive", "Liability"],
			"text": "When you rez this asset, remove 1 bad publicity.\n[click], [trash]<strong>:</strong> Trash 1 installed <strong>location</strong> resource. Take 1 bad publicity."
		})

	NRCardDefs.defcard("Encryption Protocol", {
			"title": "Encryption Protocol",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"text": "The trash cost of all installed cards is increased by 1."
		})

	NRCardDefs.defcard("Esca", {
			"title": "Esca",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they lose 1[credit]. If they are tagged, do 1 net damage."
		})

	NRCardDefs.defcard("Estelle Moon", {
			"title": "Estelle Moon",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Whenever you install a card in the root of a remote server, place 1 power counter on this asset.\n<strong>[trash]:</strong> For each power counter on this asset, gain 2[credit] and draw 1 card."
		})

	NRCardDefs.defcard("Eve Campaign", {
			"title": "Eve Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "Place 16[credit] from the bank on Eve Campaign when it is rezzed. When there are no credits left on Eve Campaign, trash it.\nWhen your turn begins, take 2[credit] from Eve Campaign."
		})

	NRCardDefs.defcard("Executive Boot Camp", {
			"title": "Executive Boot Camp",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"text": "When your turn begins, you may rez a card, lowering the rez cost by 1[credit].\n1[credit],[trash]: Search R&D for an asset, reveal it, and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Executive Search Firm", {
			"title": "Executive Search Firm",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Alliance - Ritzy",
			"subtypes": ["Alliance", "Ritzy"],
			"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [weyland-consortium] cards in your deck.\n[click]: Search R&D for an <strong>executive</strong>, <strong>sysop</strong>, or <strong>character</strong>, reveal it, and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Exposé", {
			"title": "Exposé",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"text": "You can advance this asset.\n[trash]<strong>:</strong> Remove 1 bad publicity for each hosted advancement counter."
		})

	NRCardDefs.defcard("False Flag", {
			"title": "False Flag",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "False Flag can be advanced.\nWhen the Runner accesses False Flag, give the Runner 1 tag for every 2 advancement tokens on False Flag.\n[click], <strong>7 hosted advancement tokens</strong>: add False Flag to your score area as an agenda worth 3 agenda points."
		})

	NRCardDefs.defcard("Federal Fundraising", {
			"title": "Federal Fundraising",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political - Ritzy",
			"subtypes": ["Political", "Ritzy"],
			"text": "When your turn begins, you may look at the top 3 cards of R&D and arrange them in any order. Then, if this server is not protected by ice, you may draw 1 card."
		})

	NRCardDefs.defcard("Franchise City", {
			"title": "Franchise City",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"trash": 2,
			"factioncost": 5,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "While the Runner is accessing an agenda in R&D, they must reveal it.\nWhen the Runner accesses an agenda, add this asset to your score area as an agenda worth 1 agenda point."
		})

	NRCardDefs.defcard("Front Company", {
			"title": "Front Company",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political - Seedy",
			"subtypes": ["Political", "Seedy"],
			"text": "Rez only during your turn.\nThe first run each turn cannot be made against a remote server.\nThe first time each turn a run on Archives begins, if this server is not protected by ice, do 2 net damage."
		})

	NRCardDefs.defcard("Full Immersion RecStudio", {
			"title": "Full Immersion RecStudio",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "Full Immersion RecStudio can host up to 2 assets and/or agendas.\nThe trash cost of Full Immersion RecStudio is increased by 3 for each card hosted on it."
		})

	NRCardDefs.defcard("Fumiko Yamamori", {
			"title": "Fumiko Yamamori",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 4,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever you and the Runner reveal secretly spent credits, do 1 meat damage if you and the Runner spent a different number of credits."
		})

	NRCardDefs.defcard("Gaslight", {
			"title": "Gaslight",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"text": "When your turn begins, you may trash this asset. If you do, search R&D for an operation and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that operation to HQ."
		})

	NRCardDefs.defcard("Gene Splicer", {
			"title": "Gene Splicer",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "Gene Splicer can be advanced.\nWhen the Runner accesses Gene Splicer, do 1 net damage for each advancement token on Gene Splicer.\n<strong>[click], 3 hosted advancement tokens:</strong> Add Gene Splicer to your score area as an agenda worth 1 agenda point."
		})

	NRCardDefs.defcard("Genetics Pavilion", {
			"title": "Genetics Pavilion",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 5,
			"factioncost": 5,
			"keywords": "Facility - Ritzy",
			"subtypes": ["Facility", "Ritzy"],
			"text": "The Runner cannot draw more than 2 cards during each of their turns."
		})

	NRCardDefs.defcard("Ghost Branch", {
			"title": "Ghost Branch",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 1,
			"keywords": "Ambush - Facility",
			"subtypes": ["Ambush", "Facility"],
			"text": "Ghost Branch can be advanced.\nWhen the Runner accesses Ghost Branch, you may give the Runner 1 tag for each advancement token on Ghost Branch."
		})

	NRCardDefs.defcard("GRNDL Refinery", {
			"title": "GRNDL Refinery",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "GRNDL Refinery can be advanced.\n[click], [trash]: Gain 4[credit] for each advancement token on GRNDL Refinery."
		})

	NRCardDefs.defcard("Haas Arcology AI", {
			"title": "Haas Arcology AI",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 1,
			"factioncost": 4,
			"text": "You can advance this asset if it is unrezzed.\nOnce per turn → [click], <strong>hosted advancement counter:</strong> Gain [click][click]."
		})

	NRCardDefs.defcard("Hearts and Minds", {
			"title": "Hearts and Minds",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Political",
			"subtypes": ["Political"],
			"text": "When your turn begins, you may move 1 advancement counter from an installed card to an installed card you can advance. If this server is not protected by ice, you may also place 1 advancement counter on an installed card you can advance."
		})

	NRCardDefs.defcard("Honeyfarm", {
			"title": "Honeyfarm",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they lose 1[credit]."
		})

	NRCardDefs.defcard("Hostile Architecture", {
			"title": "Hostile Architecture",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 5,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "The first time each turn the Runner trashes any of your installed cards <em>(including this asset)</em>, do 2 meat damage."
		})

	NRCardDefs.defcard("Hostile Infrastructure", {
			"title": "Hostile Infrastructure",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"trash": 5,
			"factioncost": 2,
			"text": "Whenever the Runner trashes a Corp card (including Hostile Infrastructure), do 1 net damage."
		})

	NRCardDefs.defcard("Humanoid Resources", {
			"title": "Humanoid Resources",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 2,
			"text": "[click][click][click], [trash]<strong>:</strong> Gain 4[credit] and draw 3 cards. Install up to 2 cards from HQ <em>(one at a time)</em>. You may play 1 operation from HQ."
		})

	NRCardDefs.defcard("Hyoubu Research Facility", {
			"title": "Hyoubu Research Facility",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "The first time each turn you reveal secretly spent credits, gain that many credits."
		})

	NRCardDefs.defcard("Ibrahim Salem", {
			"title": "Ibrahim Salem",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Alliance - Character",
			"subtypes": ["Alliance", "Character"],
			"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [nbn] cards in your deck.\nAs an additional cost to rez Ibrahim Salem, forfeit an agenda.\nWhen your turn begins, name a card type. Look at the Runner's grip and trash 1 card in it of the named type."
		})

	NRCardDefs.defcard("Idiosyncresis", {
			"title": "Idiosyncresis",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "You can advance this asset.\nWhen your turn begins, you may trash this asset. If you do, for each hosted advancement counter, gain 3[credit] and the Runner loses 2[credit]."
		})

	NRCardDefs.defcard("Illegal Arms Factory", {
			"title": "Illegal Arms Factory",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"trash": 6,
			"factioncost": 2,
			"keywords": "Facility - Liability",
			"subtypes": ["Facility", "Liability"],
			"text": "When your turn begins, gain 1[credit] and draw 1 card.\nWhen the Runner trashes this asset <em>(while it is rezzed)</em>, take 1 bad publicity."
		})

	NRCardDefs.defcard("Indian Union Stock Exchange", {
			"title": "Indian Union Stock Exchange",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"text": "Whenever you rez or play an out-of-faction card (including Indian Union Stock Exchange), gain 1[credit]."
		})

	NRCardDefs.defcard("Investigator Inez Delgado A", {
			"title": "Investigator Inez Delgado A",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 0,
			"trash": 5,
			"factioncost": 0,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever you score an agenda, you may swap it with an agenda in the Runner's score area worth at least 1 point, then resolve the \"when scored\" ability on that agenda."
		})

	NRCardDefs.defcard("Investigator Inez Delgado A 2", {
			"title": "Investigator Inez Delgado A 2",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 0,
			"trash": 5,
			"factioncost": 0,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever the Runner steals an agenda, you may resolve the \"when scored\" ability on that agenda, then swap it with an agenda in your scored area."
		})

	NRCardDefs.defcard("Isabel McGuire", {
			"title": "Isabel McGuire",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "[click]: Add 1 of your installed cards to HQ."
		})

	NRCardDefs.defcard("IT Department", {
			"title": "IT Department",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 1,
			"text": "[click]: Place 1 power counter on IT Department.\n<strong>Hosted power counter:</strong> Choose a rezzed piece of ice. That ice has +1 strength until the end of the turn for each power counter (including the one spent) on IT Department."
		})

	NRCardDefs.defcard("Jackson Howard", {
			"title": "Jackson Howard",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "[click]: Draw 2 cards.\n<strong>Remove Jackson Howard from the game:</strong> Shuffle up to 3 cards from Archives into R&D."
		})

	NRCardDefs.defcard("Janaína \"JK\" Dumont Kindelán", {
			"title": "Janaína \"JK\" Dumont Kindelán"
		})

	NRCardDefs.defcard("Jeeves Model Bioroids", {
			"title": "Jeeves Model Bioroids",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 5,
			"factioncost": 3,
			"keywords": "Alliance",
			"subtypes": ["Alliance"],
			"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [haas-bioroid] cards in your deck.\nThe first time you spend 3[click] on the same action each turn, gain [click]."
		})

	NRCardDefs.defcard("Kala Ghoda Real TV", {
			"title": "Kala Ghoda Real TV",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 1,
			"keywords": "Cast",
			"subtypes": ["Cast"],
			"text": "When your turn begins, you may look at the top card of the stack.\n<strong>[trash]:</strong> The Runner trashes the top card of the stack."
		})

	NRCardDefs.defcard("Kuwinda K4H1U3", {
			"title": "Kuwinda K4H1U3",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "When your turn begins, you may trace[X], where X is equal to the number of hosted power counters. If successful, do 1 core damage and trash this asset. If unsuccessful, place 1 power counter on this asset."
		})

	NRCardDefs.defcard("Lady Liberty", {
			"title": "Lady Liberty",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 5,
			"trash": 4,
			"factioncost": 0,
			"keywords": "Region - Ritzy",
			"subtypes": ["Region", "Ritzy"],
			"text": "When your turn begins, place 1 power counter on Lady Liberty.\n[click], [click], [click]: Add an agenda from HQ to your score area worth agenda points equal to the exact number of hosted power counters.\nLimit 1 <strong>region</strong> per server.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Lakshmi Smartfabrics", {
			"title": "Lakshmi Smartfabrics",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"text": "Whenever you rez a card, place 1 power counter on Lakshmi Smartfabrics.\n<strong>X hosted power counters:</strong> Reveal an agenda worth X points from HQ. The Runner cannot steal copies of that agenda for the remainder of this turn."
		})

	NRCardDefs.defcard("Launch Campaign", {
			"title": "Launch Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "Place 6[credit] from the bank on Launch Campaign when it is rezzed. When there are no credits left on Launch Campaign, trash it.\nWhen your turn begins, take 2[credit] from Launch Campaign."
		})

	NRCardDefs.defcard("Levy University", {
			"title": "Levy University",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 3,
			"trash": 1,
			"factioncost": 0,
			"keywords": "Ritzy",
			"subtypes": ["Ritzy"],
			"text": "[click], 1[credit]: Search R&D for a piece of ice, reveal it, and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Lily Lockwell", {
			"title": "Lily Lockwell",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "When you rez Lily Lockwell, draw 3 cards.\n[click], <strong>remove 1 tag:</strong> Search R&D for an operation, reveal it, and shuffle the rest of R&D. Add the operation to the top of R&D."
		})

	NRCardDefs.defcard("Long-Term Investment", {
			"title": "Long-Term Investment",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 0,
			"text": "When your turn begins, place 2[credit] on Long-Term Investment. If there are at least 8[credit] on Long-Term Investment, it gains \"[click]: Take any number of credits from Long-Term Investment.\""
		})

	NRCardDefs.defcard("Lt. Todachine", {
			"title": "Lt. Todachine",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 3,
			"trash": 5,
			"factioncost": 0,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever you rez a piece of ice, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Lt. Todachine 2", {
			"title": "Lt. Todachine 2",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 3,
			"trash": 5,
			"factioncost": 0,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Whenever you rez a piece of ice, give the Runner 1 tag.\nWhenever the Runner accesses cards, he or she accesses 1 fewer card if he or she is tagged (to a minimum of 1 card)."
		})

	NRCardDefs.defcard("Luana Campos", {
			"title": "Luana Campos",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Executive - Liability",
			"subtypes": ["Executive", "Liability"],
			"text": "When your turn begins, you may host 1 of your bad publicity counters on this asset. <em>(It has no effect while hosted.)</em> If you do, gain 3[credit] and draw 1 card.\n[interrupt] → When this asset would be uninstalled, take all hosted bad publicity."
		})

	NRCardDefs.defcard("Magistrate Revontulet", {
			"title": "Magistrate Revontulet",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 2,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "As an additional cost to steal an agenda, the Runner must pay 3[credit].\nWhenever you score an agenda, the Runner loses 3[credit]."
		})

	NRCardDefs.defcard("Malia Z0L0K4", {
			"title": "Malia Z0L0K4",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "When you rez this asset, choose 1 installed non-<strong>virtual</strong> resource.\nThe chosen resource loses its printed abilities."
		})

	NRCardDefs.defcard("Marilyn Campaign", {
			"title": "Marilyn Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When you rez this asset, load 8[credit] onto it. When it is empty, trash it.\nWhen your turn begins, take 2[credit] from this asset.\n[interrupt] → When this asset would be trashed, you may shuffle it into R&D instead of adding it to Archives. <em>(It is still considered trashed.)</em>"
		})

	NRCardDefs.defcard("Mark Yale", {
			"title": "Mark Yale",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Whenever you spend an agenda counter, gain 1[credit].\n[trash] or <strong>any agenda counter:</strong> Gain 2[credit]."
		})

	NRCardDefs.defcard("Marked Accounts", {
			"title": "Marked Accounts",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 5,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "When your turn begins, take 1[credit] from Marked Accounts, if able.\n[click]: Place 3[credit] from the bank on Marked Accounts."
		})

	NRCardDefs.defcard("MCA Austerity Policy", {
			"title": "MCA Austerity Policy",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"text": "Once per turn → [click]<strong>:</strong> Place 1 power counter on this asset. When the Runner's next turn begins, they lose [click].\n[click], [trash], <strong>3 hosted power counters:</strong> Gain [click][click][click][click]."
		})

	NRCardDefs.defcard("Melange Mining Corp.", {
			"title": "Melange Mining Corp.",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 0,
			"text": "[click], [click], [click]: Gain 7[credit]."
		})

	NRCardDefs.defcard("Mental Health Clinic", {
			"title": "Mental Health Clinic",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "Gain 1[credit] when your turn begins.\nThe Runner's maximum hand size is increased by 1."
		})

	NRCardDefs.defcard("Moon Pool", {
			"title": "Moon Pool",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "<strong>Remove this asset from the game:</strong> Trash up to 2 cards from HQ. Reveal up to 2 facedown cards in Archives and shuffle them into R&D. For each agenda revealed this way, you may place 1 advancement counter on an installed card."
		})

	NRCardDefs.defcard("Mr. Stone", {
			"title": "Mr. Stone",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 4,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Whenever the Runner takes 1 or more tags, do 1 meat damage."
		})

	NRCardDefs.defcard("Mumba Temple", {
			"title": "Mumba Temple",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Alliance - Facility",
			"subtypes": ["Alliance", "Facility"],
			"text": "This card costs 0 influence if you have 15 or fewer ice in your deck.\n2[recurring-credit]\nUse these credits to rez cards."
		})

	NRCardDefs.defcard("Mumbad City Hall", {
			"title": "Mumbad City Hall",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Facility - Government",
			"subtypes": ["Facility", "Government"],
			"text": "[click]: Search R&D for an <strong>alliance</strong> card, reveal it, and play or install it (paying all costs). Shuffle R&D."
		})

	NRCardDefs.defcard("Mumbad Construction Co.", {
			"title": "Mumbad Construction Co.",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"trash": 3,
			"factioncost": 3,
			"text": "When your turn begins, place 1 advancement token on Mumbad Construction Co.\n2[credit]: Move 1 advancement token from Mumbad Construction Co. to a faceup card."
		})

	NRCardDefs.defcard("Museum of History", {
			"title": "Museum of History",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Alliance - Ritzy",
			"subtypes": ["Alliance", "Ritzy"],
			"text": "This asset costs 0 influence if you have 50 or more cards in your deck.\nWhen your turn begins, you may shuffle 1 card from Archives into R&D."
		})

	NRCardDefs.defcard("Nanoetching Matrix", {
			"title": "Nanoetching Matrix",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Industrial",
			"subtypes": ["Industrial"],
			"text": "Once per turn → [click]<strong>:</strong> Gain 2[credit].\nWhen the Runner trashes this asset, you may gain 2[credit]."
		})

	NRCardDefs.defcard("NASX", {
			"title": "NASX",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 2,
			"trash": 4,
			"factioncost": 0,
			"text": "Gain 1[credit] when your turn begins.\nWhenever you gain credits through a card ability other than from NASX, you may spend up to 2[credit] to place that many power counters on NASX.\n[click],[trash]: Gain 2[credit] for each power counter on NASX."
		})

	NRCardDefs.defcard("Net Analytics", {
			"title": "Net Analytics",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"text": "Whenever the Runner avoids or removes 1 or more tags, you may draw 1 card."
		})

	NRCardDefs.defcard("Net Police", {
			"title": "Net Police",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 1,
			"factioncost": 2,
			"text": "X[recurring-credit]\nUse these credits during traces. X is the number of links the Runner has."
		})

	NRCardDefs.defcard("Neurostasis", {
			"title": "Neurostasis",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "Neurostasis can be advanced.\nIf you pay 3[credit] when the Runner accesses Neurostasis, choose 1 installed Runner card for each advancement token on Neurostasis. The Runner must shuffle the chosen cards into the stack."
		})

	NRCardDefs.defcard("News Team", {
			"title": "News Team",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they must either take 2 tags or add this asset to their score area as an agenda worth -1 agenda point."
		})

	NRCardDefs.defcard("NGO Front", {
			"title": "NGO Front",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 1,
			"factioncost": 0,
			"text": "NGO Front can be advanced.\n[trash],<strong>1 hosted advancement token</strong>: Gain 5[credit].\n[trash],<strong>2 hosted advancement tokens</strong>: Gain 8[credit]."
		})

	NRCardDefs.defcard("Nico Campaign", {
			"title": "Nico Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When you rez this asset, load 9[credit] onto it. When it is empty, trash it and draw 1 card.\nWhen your turn begins, take 3[credit] from this asset."
		})

	NRCardDefs.defcard("Nightmare Archive", {
			"title": "Nightmare Archive",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 4,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, they may add it to their score area as an agenda worth -1 agenda point. If they do not, do 1 core damage and remove this asset from the game."
		})

	NRCardDefs.defcard("Nihilo Agent", {
			"title": "Nihilo Agent",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Enforcer - Liability",
			"subtypes": ["Enforcer", "Liability"],
			"text": "When you rez this asset, load 3 power counters onto it. When it is empty, trash it.\nWhen your turn begins, remove 1 tag and 1 bad publicity.\nWhen your discard phase ends, give the Runner 1 tag, take 1 bad publicity, and remove 1 hosted power counter."
		})

	NRCardDefs.defcard("Open Forum", {
			"title": "Open Forum",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"text": "After your mandatory draw, reveal the top card of R&D and add it to HQ. Add 1 card from HQ to the top of R&D."
		})

	NRCardDefs.defcard("Otto Campaign", {
			"title": "Otto Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When you rez this asset, load 6[credit] onto it. When it is empty, trash it and gain [click][click].\nWhen your turn begins, take 2[credit] from this asset."
		})

	NRCardDefs.defcard("PAD Campaign", {
			"title": "PAD Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 0,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When your turn begins, gain 1[credit]."
		})

	NRCardDefs.defcard("PAD Factory", {
			"title": "PAD Factory",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Alliance - Facility",
			"subtypes": ["Alliance", "Facility"],
			"text": "This card costs 0 influence if you have 3 PAD Campaigns in your deck.\n[click]: Place 1 advancement token on a card. You cannot score that card until your next turn begins."
		})

	NRCardDefs.defcard("Pālanā Agroplex", {
			"title": "Pālanā Agroplex",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "When your turn begins, each player draws 1 card. "
		})

	NRCardDefs.defcard("Personalized Portal", {
			"title": "Personalized Portal",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"text": "When your turn begins, the Runner draws 1 card. You may gain 1[credit] for every 2 cards in the grip."
		})

	NRCardDefs.defcard("Phật Gioan Baotixita", {
			"title": "Phật Gioan Baotixita",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "When your discard phase ends, place 1 power counter on this asset.\nThe first time each turn an agenda is scored or stolen, you may remove up to 2 hosted power counters. Do 1 net damage plus 1 net damage for each power counter removed this way."
		})

	NRCardDefs.defcard("Plan B", {
			"title": "Plan B",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 1,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "Plan B can be advanced.\nIf the Runner accesses Plan B, you may reveal and score an agenda from HQ with an advancement requirement equal to or less than the number of advancement tokens on Plan B."
		})

	NRCardDefs.defcard("Plutus", {
			"title": "Plutus",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Deep Net",
			"subtypes": ["Deep Net"],
			"text": "As an additional cost to rez this asset, forfeit 1 agenda or reveal and trash 3 cards from HQ.\nWhen your turn begins, you may play 1 <strong>transaction</strong> operation from Archives. After it resolves, remove it from the game."
		})

	NRCardDefs.defcard("Political Dealings", {
			"title": "Political Dealings",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Seedy",
			"subtypes": ["Seedy"],
			"text": "Whenever you draw an agenda, you may reveal and install it."
		})

	NRCardDefs.defcard("Prāna Condenser", {
			"title": "Prāna Condenser",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 4,
			"factioncost": 3,
			"text": "[interrupt] → Whenever you would do 1 or more net damage, you may prevent 1 net damage. If you do, place 1 power counter on this asset and gain 3[credit].\n[click][click], <strong>[trash]:</strong> Do 1 net damage for each hosted power counter."
		})

	NRCardDefs.defcard("Primary Transmission Dish", {
			"title": "Primary Transmission Dish",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Beanstalk",
			"subtypes": ["Beanstalk"],
			"text": "3[recurring-credit]\nUse these credits during traces."
		})

	NRCardDefs.defcard("Private Contracts", {
			"title": "Private Contracts",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"trash": 5,
			"factioncost": 0,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Place 14[credit] from the bank on Private Contracts when it is rezzed. When there are no credits left on Private Contracts, trash it.\n[click]: Take 2[credit] from Private Contracts."
		})

	NRCardDefs.defcard("Project Junebug", {
			"title": "Project Junebug",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 1,
			"keywords": "Ambush - Research",
			"subtypes": ["Ambush", "Research"],
			"text": "Project Junebug can be advanced.\nIf you pay 1[credit] when the Runner accesses Project Junebug, do 2 net damage for each advancement token on Project Junebug."
		})

	NRCardDefs.defcard("Psychic Field", {
			"title": "Psychic Field",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Ambush - Psi",
			"subtypes": ["Ambush", "Psi"],
			"text": "If the Runner exposes or accesses Psychic Field while installed, you and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, do 1 net damage for each card in the Runner's grip."
		})

	NRCardDefs.defcard("Public Access Plaza", {
			"title": "Public Access Plaza",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 1,
			"text": "When your turn begins, gain 1[credit].\nThreat 2 → When the Runner trashes this asset <em>(while it is rezzed)</em>, give them 1 tag."
		})

	NRCardDefs.defcard("Public Health Portal", {
			"title": "Public Health Portal",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "When your turn begins, reveal the top card of R&D and gain 2[credit]."
		})

	NRCardDefs.defcard("Public Support", {
			"title": "Public Support",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 3,
			"text": "Place 3 power counters on Public Support when it is rezzed. When there are no power counters left on Public Support, add it to your score area as an agenda worth 1 agenda point.\nWhen your turn begins, remove 1 power counter from Public Support."
		})

	NRCardDefs.defcard("Quarantine System", {
			"title": "Quarantine System",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 4,
			"text": "<strong>Forfeit an agenda</strong>: Rez up to 3 pieces of ice, lowering the cost of each by 2[credit] for each printed agenda point on the forfeited agenda."
		})

	NRCardDefs.defcard("Raman Rai", {
			"title": "Raman Rai",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Alliance - Executive",
			"subtypes": ["Alliance", "Executive"],
			"text": "This asset costs 0 influence if you have 6 or more non-<strong>alliance</strong> [jinteki] cards in your deck.\nOnce per turn → When you draw a card, you may lose [click]. If you do, reveal that card and 1 card in Archives of the same type. Swap those cards."
		})

	NRCardDefs.defcard("Rashida Jaheem", {
			"title": "Rashida Jaheem",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 0,
			"trash": 1,
			"factioncost": 0,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "When your turn begins, you may trash Rashida Jaheem to gain 3[credit] and draw 3 cards."
		})

	NRCardDefs.defcard("Reality Threedee", {
			"title": "Reality Threedee",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 6,
			"factioncost": 2,
			"keywords": "Liability",
			"subtypes": ["Liability"],
			"text": "When you rez this asset, take 1 bad publicity.\nWhen your turn begins, if the Runner is tagged, gain 2[credit]. Otherwise, gain 1[credit]."
		})

	NRCardDefs.defcard("Reaper Function", {
			"title": "Reaper Function",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "When your turn begins, you may trash this asset to do 2 net damage."
		})

	NRCardDefs.defcard("Reconstruction Contract", {
			"title": "Reconstruction Contract",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 4,
			"factioncost": 4,
			"text": "Whenever the Runner suffers any amount of meat damage, you may place 1 advancement token on Reconstruction Contract.\n[trash]: Move any number of advancement tokens from Reconstruction Contract to a card that can be advanced."
		})

	NRCardDefs.defcard("Refuge Campaign", {
			"title": "Refuge Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When your turn begins, gain 2[credit]."
		})

	NRCardDefs.defcard("Regolith Mining License", {
			"title": "Regolith Mining License",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 0,
			"text": "When you rez this asset, load 15[credit] onto it. When it is empty, trash it.\n[click]<strong>:</strong> Take 3[credit] from this asset."
		})

	NRCardDefs.defcard("Reversed Accounts", {
			"title": "Reversed Accounts",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "You can advance this asset.\n[click], [trash]<strong>:</strong> The Runner loses 4[credit] for each hosted advancement counter."
		})

	NRCardDefs.defcard("Rex Campaign", {
			"title": "Rex Campaign",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When you rez this asset, load 3 power counters onto it. When it is empty, trash it and either remove 1 bad publicity or gain 5[credit].\nWhen your turn begins, remove 1 hosted power counter."
		})

	NRCardDefs.defcard("Ronald Five", {
			"title": "Ronald Five",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "Whenever the Runner trashes a Corp card <em>(including this asset)</em>, they lose [click]."
		})

	NRCardDefs.defcard("Ronin", {
			"title": "Ronin",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 4,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "You can advance this asset.\n[click], [trash]<strong>:</strong> Do 3 net damage. Use this ability only if there are 4 or more hosted advancement counters."
		})

	NRCardDefs.defcard("Roughneck Repair Squad", {
			"title": "Roughneck Repair Squad",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Industrial",
			"subtypes": ["Industrial"],
			"text": "[click][click][click]<strong>:</strong> Gain 6[credit]. You may remove 1 bad publicity."
		})

	NRCardDefs.defcard("Sandburg", {
			"title": "Sandburg",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 0,
			"trash": 4,
			"factioncost": 0,
			"text": "If you have at least 10[credit], each piece of ice has +1 strength for every 5[credit] in your credit pool."
		})

	NRCardDefs.defcard("Sealed Vault", {
			"title": "Sealed Vault",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 8,
			"factioncost": 1,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "<strong>1[credit]:</strong> Move any number of credits from your credit pool to this asset.\n<strong>[click]:</strong> Take any number of credits from this asset.\n<strong>[trash]:</strong> Take any number of credits from this asset."
		})

	NRCardDefs.defcard("Security Subcontract", {
			"title": "Security Subcontract",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "[click], <strong>trash a rezzed piece of ice:</strong> Gain 4[credit]."
		})

	NRCardDefs.defcard("Sensie Actors Union", {
			"title": "Sensie Actors Union",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political",
			"subtypes": ["Political"],
			"text": "When your turn begins, you may draw 3 cards if there is no ice protecting this server. If you do, add 1 card from HQ to the bottom of R&D."
		})

	NRCardDefs.defcard("Server Diagnostics", {
			"title": "Server Diagnostics",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"trash": 2,
			"factioncost": 0,
			"text": "Gain 2[credit] when your turn begins.\nTrash Server Diagnostics when you install a piece of ice."
		})

	NRCardDefs.defcard("Shannon Claire", {
			"title": "Shannon Claire",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 0,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "[click]: Draw 1 card from the bottom of R&D.\n[trash]: Search R&D or Archives for an agenda and reveal it. Shuffle the rest of R&D if you searched it. Add the agenda to the bottom of R&D."
		})

	NRCardDefs.defcard("Shattered Remains", {
			"title": "Shattered Remains",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "Shattered Remains can be advanced.\nIf you pay 1[credit] when the Runner accesses Shattered Remains, trash 1 piece of hardware for each advancement token on Shattered Remains."
		})

	NRCardDefs.defcard("Shi.Kyū", {
			"title": "Shi.Kyū",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 4,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "When the Runner accesses this asset anywhere except in R&D, spend any number of credits. The Runner suffers 1 net damage for each credit spent this way unless they add this asset to their score area as an agenda worth −1 agenda point."
		})

	NRCardDefs.defcard("Shock!", {
			"title": "Shock!",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, do 1 net damage."
		})

	NRCardDefs.defcard("SIU", {
			"title": "SIU",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 3,
			"trash": 1,
			"factioncost": 3,
			"text": "When your turn begins, you may trash SIU to Trace[3]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Snare!", {
			"title": "Snare!",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset anywhere except in Archives, you may pay 4[credit]. If you do, give the Runner 1 tag and do 3 net damage."
		})

	NRCardDefs.defcard("Space Camp", {
			"title": "Space Camp",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this asset in R&D, they must reveal it.\nWhen the Runner accesses this asset, you may place 1 advancement counter on an installed card you can advance."
		})

	NRCardDefs.defcard("Spin Doctor", {
			"title": "Spin Doctor",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 0,
			"trash": 2,
			"factioncost": 1,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "When you rez this asset, draw 2 cards.\n<strong>Remove this asset from the game:</strong> Shuffle up to 2 cards from Archives into R&D."
		})

	NRCardDefs.defcard("Storgotic Resonator", {
			"title": "Storgotic Resonator",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "The first time each turn you trash a card that matches the faction of the Runnerʼs identity <em>(from any location)</em>, place 1 power counter on this asset.\n[click], <strong>hosted power counter:</strong> Do 1 net damage. "
		})

	NRCardDefs.defcard("Student Loans", {
			"title": "Student Loans",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"text": "As an additional cost to play an event, if there is a copy of that event in the heap, the Runner must pay 2[credit]."
		})

	NRCardDefs.defcard("Superdeep Borehole", {
			"title": "Superdeep Borehole",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"trash": 6,
			"factioncost": 5,
			"keywords": "Industrial - Liability",
			"subtypes": ["Industrial", "Liability"],
			"text": "When you rez this asset, load 6 bad publicity counters onto it. When it is empty, you win the game.\nWhen your turn begins, take 1 bad publicity from this asset."
		})

	NRCardDefs.defcard("Synchrocyclotron", {
			"title": "Synchrocyclotron",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "The first <strong>double</strong> operation you play each turn costs [click] less to play."
		})

	NRCardDefs.defcard("Sundew", {
			"title": "Sundew",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 3,
			"text": "The first time the Runner spends 1 or more [click] during their turn, gain 2[credit]. If those [click] were spent to take an action, the first time during that action a run on this server begins, pay 2[credit]."
		})

	NRCardDefs.defcard("Svyatogor Excavator", {
			"title": "Svyatogor Excavator",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 1,
			"keywords": "Industrial",
			"subtypes": ["Industrial"],
			"text": "When your turn begins, you may trash 1 of your other installed cards. If you do, gain 3[credit]."
		})

	NRCardDefs.defcard("Synth DNA Modification", {
			"title": "Synth DNA Modification",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 1,
			"text": "The first time a subroutine on a piece of <strong>AP</strong> ice is broken each turn, do 1 net damage."
		})

	NRCardDefs.defcard("Team Sponsorship", {
			"title": "Team Sponsorship",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 4,
			"factioncost": 1,
			"text": "Whenever you score an agenda, you may install a card from Archives or HQ, ignoring the install cost."
		})

	NRCardDefs.defcard("Tech Startup", {
			"title": "Tech Startup",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 1,
			"factioncost": 0,
			"text": "When your turn begins, you may trash Tech Startup. If you do, search R&D for an asset, reveal it, and install it. Shuffle R&D."
		})

	NRCardDefs.defcard("TechnoCo", {
			"title": "TechnoCo",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 2,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Corporation",
			"subtypes": ["Corporation"],
			"text": "The install cost of each program, piece of hardware, and <strong>virtual</strong> resource is increased by 1.\nWhenever the Runner installs a program, piece of hardware, or <strong>virtual</strong> resource, you may gain 1[credit]."
		})

	NRCardDefs.defcard("Tenma Line", {
			"title": "Tenma Line",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "[click]: Swap 2 pieces of installed ice."
		})

	NRCardDefs.defcard("Test Ground", {
			"title": "Test Ground",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"text": "Test Ground can be advanced.\n[trash]: Derez 1 card for each advancement token on Test Ground."
		})

	NRCardDefs.defcard("The Board", {
			"title": "The Board",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 3,
			"trash": 7,
			"factioncost": 5,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Each agenda in the Runner's score area is worth 1 less agenda point.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
		})

	NRCardDefs.defcard("The News Now Hour", {
			"title": "The News Now Hour",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Cast",
			"subtypes": ["Cast"],
			"text": "The Runner cannot play <strong>current</strong> events."
		})

	NRCardDefs.defcard("The Powers That Be", {
			"title": "The Powers That Be",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Ritzy",
			"subtypes": ["Ritzy"],
			"text": "Whenever you score an agenda, you may install 1 card from HQ or Archives, ignoring all costs."
		})

	NRCardDefs.defcard("The Root", {
			"title": "The Root",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 6,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Beanstalk",
			"subtypes": ["Beanstalk"],
			"text": "3[recurring-credit]\nUse these credits to advance, install, and rez cards."
		})

	NRCardDefs.defcard("Thomas Haas", {
			"title": "Thomas Haas",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 1,
			"factioncost": 1,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Thomas Haas can be advanced.\n[trash]: Gain 2[credit] for each advancement token on Thomas Haas."
		})

	NRCardDefs.defcard("Tiered Subscription", {
			"title": "Tiered Subscription",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 1,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "The first time each turn a run begins, gain 1[credit]."
		})

	NRCardDefs.defcard("Toshiyuki Sakai", {
			"title": "Toshiyuki Sakai",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Toshiyuki Sakai can be advanced.\nIf Toshiyuki Sakai is accessed while installed, you may swap him with an agenda or asset from HQ. The new agenda or asset is installed unrezzed, and keeps all advancement tokens on Toshiyuki Sakai. The Runner can choose not to access the new card."
		})

	NRCardDefs.defcard("Trieste Model Bioroids", {
			"title": "Trieste Model Bioroids",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "When you rez this asset, choose 1 rezzed piece of <strong>bioroid</strong> ice.\nRunner card abilities cannot break subroutines on the chosen ice."
		})

	NRCardDefs.defcard("Trojan", {
			"title": "Trojan",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 0,
			"factioncost": 0,
			"text": "If Trojan is accessed from R&D, then Runner must reveal it.\nWhen the Runner accesses Trojan, lose 2[credit], trash 1 card from HQ at random, and destroy Trojan. Ignore this ability if the Runner accesses Trojan from Archives."
		})

	NRCardDefs.defcard("Turtlebacks", {
			"title": "Turtlebacks",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 4,
			"factioncost": 1,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "Gain 1[credit] whenever you create a server."
		})

	NRCardDefs.defcard("Ubiquitous Vig", {
			"title": "Ubiquitous Vig",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "You can advance this asset.\nWhen your turn begins, gain 1[credit] for each hosted advancement counter."
		})

	NRCardDefs.defcard("Urban Renewal", {
			"title": "Urban Renewal",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "Place 3 power counters on Urban Renewal when it is rezzed. When there are no power counters left on Urban Renewal, trash it and do 4 meat damage.\nWhen your turn begins, remove 1 power counter from Urban Renewal."
		})

	NRCardDefs.defcard("Urtica Cipher", {
			"title": "Urtica Cipher",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "You can advance this asset.\nWhen the Runner accesses this asset while it is installed, do 2 net damage plus 1 net damage for each hosted advancement counter."
		})

	NRCardDefs.defcard("Vaporframe Fabricator", {
			"title": "Vaporframe Fabricator",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Industrial",
			"subtypes": ["Industrial"],
			"text": "Once per turn → [click]<strong>:</strong> Install 1 card from HQ, ignoring all costs.\nWhen the Runner trashes this asset, you may install 1 card from HQ, ignoring all costs. You cannot install that card in the root of this server."
		})

	NRCardDefs.defcard("Vera Ivanovna Shuyskaya", {
			"title": "Vera Ivanovna Shuyskaya",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 3,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "Whenever an agenda is scored or stolen, you may reveal the grip. Trash 1 card revealed this way."
		})

	NRCardDefs.defcard("Victoria Jenkins", {
			"title": "Victoria Jenkins",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 3,
			"trash": 5,
			"factioncost": 5,
			"keywords": "Executive",
			"subtypes": ["Executive"],
			"text": "The Runner gets -1 allotted [click] for each of their turns.\nWhen this asset is trashed from anywhere while being accessed, add it to the Runner's score area as an agenda worth 2 agenda points."
		})

	NRCardDefs.defcard("Wage Workers", {
			"title": "Wage Workers",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 2,
			"trash": 4,
			"factioncost": 2,
			"keywords": "Bioroid - Clone - Industrial",
			"subtypes": ["Bioroid", "Clone", "Industrial"],
			"text": "Whenever you finish taking an action, if you have taken that action exactly 3 times this turn, gain [click]."
		})

	NRCardDefs.defcard("Wall to Wall", {
			"title": "Wall to Wall",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 1,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Advertisement",
			"subtypes": ["Advertisement"],
			"text": "When your turn begins, if you have any other rezzed assets, resolve 1 of the following; otherwise, resolve up to 3 in any order:<ul><li>Draw 1 card.</li><li>Gain 1[credit].</li><li>Place 1 advancement counter on an installed piece of ice.</li><li>Add this asset to HQ.</li></ul>"
		})

	NRCardDefs.defcard("Warden Fatuma", {
			"title": "Warden Fatuma",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 1,
			"trash": 5,
			"factioncost": 2,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Each rezzed piece of <strong>bioroid</strong> ice gains \"[subroutine] The Runner loses [click].\" before its other subroutines."
		})

	NRCardDefs.defcard("Warm Reception", {
			"title": "Warm Reception",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Political - Ritzy",
			"subtypes": ["Political", "Ritzy"],
			"text": "When your turn begins, you may install 1 card from HQ. You cannot score that card this turn. If this server is not protected by ice, you may derez this asset to derez another installed card."
		})

	NRCardDefs.defcard("Watchdog", {
			"title": "Watchdog",
			"type": "Asset",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 1,
			"text": "The rez cost of the first piece of ice you rez each turn is lowered by 1 for each tag the Runner has."
		})

	NRCardDefs.defcard("Whampoa Reclamation", {
			"title": "Whampoa Reclamation",
			"type": "Asset",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Corporation",
			"subtypes": ["Corporation"],
			"text": "Once per turn → <strong>Trash 1 card from HQ:</strong> Add 1 card from Archives to the bottom of R&D."
		})

	NRCardDefs.defcard("Working Prototype", {
			"title": "Working Prototype",
			"type": "Asset",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Hostile",
			"subtypes": ["Hostile"],
			"text": "Whenever you rez a card <em>(including this asset)</em>, place 1 power counter on this asset.\n[click], <strong>hosted power counter:</strong> Gain 3[credit].\n[click], <strong>5 hosted power counters:</strong> Gain 6[credit]. Add 1 installed resource to the top of the stack."
		})

	NRCardDefs.defcard("Worlds Plaza", {
			"title": "Worlds Plaza",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 2,
			"trash": 5,
			"factioncost": 5,
			"keywords": "Facility",
			"subtypes": ["Facility"],
			"text": "Worlds Plaza can host up to 3 assets.\n[click]: Install an asset from HQ on Worlds Plaza and rez it, lowering its rez cost by 2, if able."
		})

	NRCardDefs.defcard("Zaibatsu Loyalty", {
			"title": "Zaibatsu Loyalty",
			"type": "Asset",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 1,
			"text": "[interrupt] → When a card would be exposed, you may rez this asset.\n[interrupt] → <strong>1[credit]</strong> or <strong>[trash]:</strong> Prevent 1 card from being exposed."
		})

	NRCardDefs.defcard("Zealous Judge", {
			"title": "Zealous Judge",
			"type": "Asset",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Character",
			"subtypes": ["Character"],
			"text": "Zealous Judge can only be rezzed if the Runner is tagged.\n[click], 1[credit]: Give the Runner 1 tag."
		})
