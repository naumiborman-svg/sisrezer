class_name NRCardsResources
extends RefCounted

## Printed card data from game.cards.resources (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Aaron Marrón", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever an agenda is scored or stolen, place 2 power counters on Aaron Marrón.\n<strong>Hosted power counter:</strong> Remove 1 tag and draw 1 card.",
			"code": "11106",
			"title": "Aaron Marrón",
		})

	NRCardDefs.defcard("Access to Globalsec", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Link",
			"subtypes": ["Link"],
			"text": "+1[link]",
			"code": "01052",
			"title": "Access to Globalsec",
		})

	NRCardDefs.defcard("Activist Support", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When the Corp's turn begins, take 1 tag if you have no tags.\nWhen your turn begins, give the Corp 1 bad publicity if they have no bad publicity.",
			"code": "04062",
			"title": "Activist Support",
		})

	NRCardDefs.defcard("Adjusted Chronotype", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Genetics",
			"subtypes": ["Genetics"],
			"text": "The first time each turn you lose [Click] except by paying the trigger cost of a paid ability, gain [Click].",
			"code": "08003",
			"title": "Adjusted Chronotype",
		})

	NRCardDefs.defcard("Aeneas Informant", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever you access a card with a trash cost not in Archives and do not trash it, you may reveal it and gain 1[Credits].",
			"code": "12044",
			"title": "Aeneas Informant",
		})

	NRCardDefs.defcard("Aesop's Pawnshop", {
			"title": "Aesop's Pawnshop",
		})

	NRCardDefs.defcard("Akshara Sareen", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Each player gets +1 allotted [Click] for each of their turns.",
			"code": "10046",
			"title": "Akshara Sareen",
		})

	NRCardDefs.defcard("Algo Trading", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When your turn begins, you may move up to 3[Credits] from your credit pool to Algo Trading.\nWhen your turn begins, place 2[Credits] on Algo Trading from the bank if there are at least 6[Credits] on it.\n[Click],[Trash]: Take all credits from Algo Trading.",
			"code": "11029",
			"title": "Algo Trading",
		})

	NRCardDefs.defcard("All-nighter", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "[Click], [Trash]: Gain [Click][Click].",
			"code": "20053",
			"title": "All-nighter",
		})

	NRCardDefs.defcard("Always Be Running", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Adam",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Directive - Virtual",
			"subtypes": ["Directive", "Virtual"],
			"text": "The first [Click] you spend each turn must be spent to take the basic action to play an event or the basic action to run a server. You cannot take the action to play an event this way except if you play a <strong>run</strong> event.\nOnce per turn → <strong>Lose [Click][Click]:</strong> Break 1 subroutine.",
			"code": "09041",
			"title": "Always Be Running",
		})

	NRCardDefs.defcard("Amelia Earhart", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Virtual - Companion",
			"subtypes": ["Virtual", "Companion"],
			"text": "Whenever a run on HQ or R&D ends, if you accessed 3 or more cards during that run, place 1 power counter on this resource.\nWhen your turn begins, you may remove 3 hosted power counters and trash this resource. If you do, the Corp loses 10[Credits].",
			"code": "34083",
			"title": "Amelia Earhart",
		})

	NRCardDefs.defcard("Angel Arena", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "Place X power counters on Angel Arena when it is installed. When there are no power counters left on Angel Arena, trash it.\n<strong>Hosted power counter:</strong> Reveal the top card of your stack. You may add that card to the bottom of your stack.",
			"code": "06080",
			"title": "Angel Arena",
		})

	NRCardDefs.defcard("Armitage Codebusting", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "Place 12[Credits] from the bank on Armitage Codebusting when it is installed. When there are no credits left on Armitage Codebusting, trash it.\n[Click]: Take 2[Credits] from Armitage Codebusting.",
			"code": "25062",
			"title": "Armitage Codebusting",
		})

	NRCardDefs.defcard("Artist Colony", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "<strong>Forfeit 1 agenda:</strong> Search your stack for 1 program, resource, or piece of hardware. Install that card.",
			"code": "10009",
			"title": "Artist Colony",
		})

	NRCardDefs.defcard("Arruaceiras Crew", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "Once per turn → <strong>Take 1 tag:</strong> The ice you are encountering gets –2 strength for the remainder of this encounter.\n[Trash], <strong>2[Credits]:</strong> Trash the ice you are encountering if its strength is 0 or less.",
			"code": "34073",
			"title": "Arruaceiras Crew",
		})

	NRCardDefs.defcard("Asmund Pudlat", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "When you install this resource, search your stack for up to 2 <strong>virus</strong> or <strong>weapon</strong> cards with different names. Host those cards faceup on this resource. <em>(They are not installed.)</em>\nWhen your turn begins, you may add 1 hosted card to your grip. If there are no more hosted cards, trash this resource.",
			"code": "33082",
			"title": "Asmund Pudlat",
		})

	NRCardDefs.defcard("Assimilator", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Apex",
			"cost": 5,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Click],[Click]: Turn one of your facedown installed cards faceup. If that card is an event, trash it.",
			"code": "21008",
			"title": "Assimilator",
		})

	NRCardDefs.defcard("Avgustina Ivanovskaya", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The first time each turn you install a <strong>virus</strong> program, sabotage 1. <em>(The Corp trashes 1 card of their choice from HQ or the top of R&D.)</em>",
			"code": "33008",
			"title": "Avgustina Ivanovskaya",
		})

	NRCardDefs.defcard("Backstitching", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "When your turn begins, identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nWhenever you encounter a piece of ice during a run on your mark, you may trash this resource to bypass that ice.",
			"code": "33019",
			"title": "Backstitching",
		})

	NRCardDefs.defcard("\"Baklan\" Bochkin", {
			"title": "\"Baklan\" Bochkin",
		})

	NRCardDefs.defcard("Bank Job", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When you install this resource, load 8[Credits] on it. When it is empty, trash it.\nWhenever you make a successful run on a remote server, instead of breaching that server, you may take any number of credits from this resource.",
			"code": "25038",
			"title": "Bank Job",
		})

	NRCardDefs.defcard("Bazaar", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "Whenever you install a piece of hardware from your grip, you may install another copy of that hardware from your grip (paying all costs).",
			"code": "10065",
			"title": "Bazaar",
		})

	NRCardDefs.defcard("Beach Party", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "When your turn begins, lose [Click].\nYour maximum hand size is increased by 5.",
			"code": "08031",
			"title": "Beach Party",
		})

	NRCardDefs.defcard("Beatriz Friere Gonzalez", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click][Click]<strong>:</strong> Run HQ. If successful, instead of breaching HQ, breach R&D. When you do, access 1 additional card.",
			"code": "34028",
			"title": "Beatriz Friere Gonzalez",
		})

	NRCardDefs.defcard("Beth Kilrain-Chang", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "If the Corp has 5-9[Credits] when your turn begins, gain 1[Credits].\nIf the Corp has 10-14[Credits] when your turn begins, draw 1 card.\nIf the Corp has at least 15[Credits] when your turn begins, gain [Click].",
			"code": "11030",
			"title": "Beth Kilrain-Chang",
		})

	NRCardDefs.defcard("Bhagat", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The first time you make a successful run on HQ each turn, force the Corp to trash the top card of R&D.",
			"code": "10098",
			"title": "Bhagat",
		})

	NRCardDefs.defcard("Bio-Modeled Network", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent all but 1 net damage.",
			"code": "12006",
			"title": "Bio-Modeled Network",
		})

	NRCardDefs.defcard("Biometric Spoofing", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent 2 damage.",
			"code": "13026",
			"title": "Biometric Spoofing",
		})

	NRCardDefs.defcard("Blockade Runner", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click],[Click]: Draw 3 cards. Shuffle 1 card from your grip into your stack.",
			"code": "11065",
			"title": "Blockade Runner",
		})

	NRCardDefs.defcard("Bloo Moose", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 4,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location - Seedy",
			"subtypes": ["Location", "Seedy"],
			"text": "When your turn begins, you may remove 1 card in the heap from the game. If you do, gain 2[Credits].",
			"code": "12089",
			"title": "Bloo Moose",
		})

	NRCardDefs.defcard("Borrowed Satellite", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Link",
			"subtypes": ["Link"],
			"text": "+1[link]\nYour maximum hand size is increased by 1.",
			"code": "03050",
			"title": "Borrowed Satellite",
		})

	NRCardDefs.defcard("Bug Out Bag", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"factioncost": 2,
			"uniqueness": false,
			"text": "When you install this resource, place X power counters on it.\nWhen your turn ends, if you have no cards in your grip, draw 1 card for each hosted power counter, then trash this resource.",
			"code": "12064",
			"title": "Bug Out Bag",
		})

	NRCardDefs.defcard("Caldera", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[interrupt] → <strong>3[Credits]:</strong> Prevent 1 core damage or 1 net damage.",
			"code": "12105",
			"title": "Caldera",
		})

	NRCardDefs.defcard("Cacophony", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The first time each turn you steal or trash a Corp card, place 1 power counter on this resource.\nWhen your action phase ends, you may remove 2 hosted power counters to sabotage 3. <em>(The Corp trashes 3 cards of their choice from HQ and/or the top of R&D.)</em>",
			"code": "35010",
			"title": "Cacophony",
		})

	NRCardDefs.defcard("Charlatan", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "<strong>[Click][Click]:</strong> Run any server. The first time you approach a rezzed piece of ice during this run, you may pay credits equal to the strength of that ice. If you do, when you encounter that ice after this approach, bypass it.",
			"code": "13010",
			"title": "Charlatan",
		})

	NRCardDefs.defcard("Chatterjee University", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "[Click]: Place 1 power counter on Chatterjee University.\n[Click]: Install a program from your grip, lowering the install cost by 1 for each power counter on Chatterjee University. Remove 1 hosted power counter.",
			"code": "10010",
			"title": "Chatterjee University",
		})

	NRCardDefs.defcard("Chrome Parlor", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "[interrupt] → Whenever you would suffer damage from a \"when installed\" ability on a piece of <strong>cybernetic</strong> hardware, prevent all of that damage.",
			"code": "08044",
			"title": "Chrome Parlor",
		})

	NRCardDefs.defcard("Citadel Sanctuary", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "When your discard phase ends while you are tagged, the Corp must trace[1]. If unsuccessful, remove 1 tag.\n[interrupt] → [Trash], <strong>trash all cards from your grip:</strong> Prevent all meat damage.",
			"code": "11070",
			"title": "Citadel Sanctuary",
		})

	NRCardDefs.defcard("Clan Vengeance", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Clan",
			"subtypes": ["Clan"],
			"text": "Whenever you suffer any amount of damage, place 1 power counter on Clan Vengeance.\n[Trash]: Trash 1 card from HQ at random for each power counter on Clan Vengeance.",
			"code": "12022",
			"title": "Clan Vengeance",
		})

	NRCardDefs.defcard("Climactic Showdown", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 5,
			"uniqueness": true,
			"text": "When your turn begins, remove this resource from the game. Choose a server protected by ice. The Corp may trash 1 piece of ice protecting that server. If they do not, the first time this turn you breach either R&D or HQ, access 2 additional cards.",
			"code": "26006",
			"title": "Climactic Showdown",
		})

	NRCardDefs.defcard("Compromised Employee", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection - Link",
			"subtypes": ["Connection", "Link"],
			"text": "1[recurring-credit]\nUse this credit during traces.\nGain 1[Credits] whenever the Corp rezzes a piece of ice.",
			"code": "02025",
			"title": "Compromised Employee",
		})

	NRCardDefs.defcard("Cookbook", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever you install a <strong>virus</strong> program, you may place 1 virus counter on it.",
			"code": "30009",
			"title": "Cookbook",
		})

	NRCardDefs.defcard("Corporate Defector", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever the Corp draws a card with the basic action, reveal that card.",
			"code": "12109",
			"title": "Corporate Defector",
		})

	NRCardDefs.defcard("Councilman", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever the Corp rezzes an asset or upgrade, you may pay credits equal to its rez cost and trash Councilman. If you do, derez that asset or upgrade. The Corp cannot rez it for the remainder of this turn.",
			"code": "10047",
			"title": "Councilman",
		})

	NRCardDefs.defcard("Counter Surveillance", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Clan",
			"subtypes": ["Clan"],
			"text": "<strong>[Click]</strong>, <strong>[Trash]:</strong> Run any server. If successful, instead of breaching the attacked server, pay X[Credits] if able, where X is equal to the number of tags you have. If you do, choose a number less than or equal to X. Access that many cards in and/or in the root of the attacked server. <em>(If you cannot pay, you will not access anything.)</em>",
			"code": "12023",
			"title": "Counter Surveillance",
		})

	NRCardDefs.defcard("Crash Space", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "2[recurring-credit]\nYou can spend hosted credits to take the basic action to remove 1 tag.\n[interrupt] → [Trash]<strong>:</strong> Prevent up to 3 meat damage.",
			"code": "20034",
			"title": "Crash Space",
		})

	NRCardDefs.defcard("Crowdfunding", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Seedy - Virtual",
			"subtypes": ["Seedy", "Virtual"],
			"text": "When you install this resource, load 3[Credits] onto it. When it is empty, trash it and draw 1 card.\nWhen your turn begins, take 1[Credits] from this resource.\nWhen your turn ends, if you made at least 3 successful runs this turn and this card is in your heap, you may install it, ignoring all costs.",
			"code": "28002",
			"title": "Crowdfunding",
		})

	NRCardDefs.defcard("Crypt", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever you make a successful run on Archives, you may place 1 virus counter on Crypt.\n[Click], [Trash], <strong>3 hosted virus counters</strong>: Search your stack for a <strong>virus</strong> program and install it (paying its install cost), then shuffle your stack.",
			"code": "21043",
			"title": "Crypt",
		})

	NRCardDefs.defcard("Cybertrooper Talut", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection - Virtual",
			"subtypes": ["Connection", "Virtual"],
			"text": "+1[link]\nWhenever you install a non-<strong>AI</strong> <strong>icebreaker</strong>, that <strong>icebreaker</strong> gets +2 strength for the remainder of the turn.",
			"code": "27003",
			"title": "Cybertrooper Talut",
		})

	NRCardDefs.defcard("Dadiana Chacon", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, gain 1[Credits] if you have fewer than 6[Credits].\nWhenever you have 0[Credits], trash Dadiana Chacon and take 3 meat damage.",
			"code": "12049",
			"title": "Dadiana Chacon",
		})

	NRCardDefs.defcard("Daily Casts", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"text": "When you install this resource, load 8[Credits] onto it. When it is empty, trash it.\nWhen your turn begins, take 2[Credits] from this resource.",
			"code": "26094",
			"title": "Daily Casts",
		})

	NRCardDefs.defcard("Daeg, First Net-Cat", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Companion - Virtual",
			"subtypes": ["Companion", "Virtual"],
			"text": "Whenever an agenda is scored or stolen, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>",
			"code": "33028",
			"title": "Daeg, First Net-Cat",
		})

	NRCardDefs.defcard("Data Dealer", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "<strong>[Click]</strong>, <strong>forfeit 1 agenda:</strong> Gain 9[Credits].",
			"code": "25039",
			"title": "Data Dealer",
		})

	NRCardDefs.defcard("Data Folding", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "When your turn begins, gain 1[Credits] if you have 2 or more unused MU.",
			"code": "07055",
			"title": "Data Folding",
		})

	NRCardDefs.defcard("Data Leak Reversal", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual - Sabotage",
			"subtypes": ["Virtual", "Sabotage"],
			"text": "Install only if you made a successful run on a central server this turn.\nIf you are tagged, Data Leak Reversal gains \"[Click]: The Corp trashes the top card of R&D.\"",
			"code": "02103",
			"title": "Data Leak Reversal",
		})

	NRCardDefs.defcard("DDoS", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Trash]: The Corp cannot rez the outermost piece of ice during a run on any server this turn.",
			"code": "08103",
			"title": "DDoS",
		})

	NRCardDefs.defcard("Dean Lister", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Trash]: Choose an <strong>icebreaker</strong>. Until the end of the run, that <strong>icebreaker</strong> has +1 strength for each card in your grip.",
			"code": "13025",
			"title": "Dean Lister",
		})

	NRCardDefs.defcard("Debbie \"Downtown\" Moreira", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Threat 4 → When you install this resource, place 2[Credits] on it. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nWhenever you play a <strong>run</strong> event, place 1[Credits] on this resource.\n[Click]<strong>:</strong> Run any server. You can spend hosted credits during that run.",
			"code": "34019",
			"title": "Debbie \"Downtown\" Moreira",
		})

	NRCardDefs.defcard("Decoy", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent 1 tag.",
			"code": "01032",
			"title": "Decoy",
		})

	NRCardDefs.defcard("District 99", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Location - Seedy",
			"subtypes": ["Location", "Seedy"],
			"text": "The first time each turn a program or a piece of hardware is trashed (from any location), you may place 1 power counter on District 99.\n[Click], <strong>3 hosted power counters</strong>: Add a card that matches the faction of your identity from your heap to your grip.",
			"code": "22007",
			"title": "District 99",
		})

	NRCardDefs.defcard("DJ Fenris", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Host a <strong>g-mod</strong> identity that does not match the faction of your identity on DJ Fenris when he is installed. Remove hosted identity from the game if DJ Fenris is uninstalled.\nDJ Fenris gains the text of hosted identity.\nLimit 1 per deck.",
			"code": "22025",
			"title": "DJ Fenris",
		})

	NRCardDefs.defcard("Donut Taganes", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The play cost of operations and events is increased by 1.",
			"code": "05055",
			"title": "Donut Taganes",
		})

	NRCardDefs.defcard("Dr. Lovegood", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Adam",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, choose 1 of your installed cards. That card loses its printed abilities for the remainder of the turn.",
			"code": "09042",
			"title": "Dr. Lovegood",
		})

	NRCardDefs.defcard("Dr. Nuka Vrolyck", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you install this resource, load 2 power counters onto it. When it is empty, trash it.\n[Click], <strong>hosted power counter:</strong> Draw 3 cards.",
			"code": "33092",
			"title": "Dr. Nuka Vrolyck",
		})

	NRCardDefs.defcard("DreamNet", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The first time each turn you make a successful run, draw 1 card. If your identity is <strong>digital</strong> or you have at least 2[link], also gain 1[Credits].",
			"code": "26095",
			"title": "DreamNet",
		})

	NRCardDefs.defcard("Drug Dealer", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, lose 1[Credits].\nWhen the Corp's turn begins, draw 1 card.",
			"code": "08083",
			"title": "Drug Dealer",
		})

	NRCardDefs.defcard("Duggar's", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Location - Seedy",
			"subtypes": ["Location", "Seedy"],
			"text": "[Click],[Click],[Click],[Click]: Draw 10 cards.",
			"code": "06054",
			"title": "Duggar's",
		})

	NRCardDefs.defcard("Dummy Box", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[interrupt] → <strong>Trash 1 card from your grip:</strong> Prevent the Corp from trashing 1 installed card of the same type.",
			"code": "12108",
			"title": "Dummy Box",
		})

	NRCardDefs.defcard("Earthrise Hotel", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 4,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "When you install this resource, load 3 power counters onto it. When it is empty, trash it.\nWhen your turn begins, remove 1 hosted power counter and draw 2 cards.",
			"code": "31039",
			"title": "Earthrise Hotel",
		})

	NRCardDefs.defcard("Eden Shard", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 7,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Virtual - Source",
			"subtypes": ["Virtual", "Source"],
			"text": "Whenever you make a successful run on R&D, instead of breaching R&D, you may install this resource from your grip, ignoring all costs.\n<strong>[Trash]:</strong> The Corp draws 2 cards.\nLimit 1 per deck.",
			"code": "06020",
			"title": "Eden Shard",
		})

	NRCardDefs.defcard("Emptied Mind", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"text": "When your turn begins, gain [Click] if you have no cards in your grip.",
			"code": "10078",
			"title": "Emptied Mind",
		})

	NRCardDefs.defcard("Enhanced Vision", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Genetics",
			"subtypes": ["Genetics"],
			"text": "The first time you make a successful run each turn, the Corp reveals 1 card at random from HQ.",
			"code": "08005",
			"title": "Enhanced Vision",
		})

	NRCardDefs.defcard("Environmental Testing", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you install a program or piece of hardware, place 1 power counter on this resource.\nWhen there are 4 or more hosted power counters, trash this resource and gain 9[Credits].",
			"code": "33029",
			"title": "Environmental Testing",
		})

	NRCardDefs.defcard("Eru Ayase-Pessoa", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection - Clone",
			"subtypes": ["Connection", "Clone"],
			"text": "Once per turn → [Click], <strong>take 1 tag:</strong> Run Archives. If successful, instead of breaching Archives, breach R&D.\nThreat 3 → Whenever you breach R&D during a run on Archives, access 1 additional card. <em>(This ability is active if any player has 3 or more agenda points.)</em>",
			"code": "34007",
			"title": "Eru Ayase-Pessoa",
		})

	NRCardDefs.defcard("Fall Guy", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent a player from trashing another installed resource.\n[Trash]<strong>:</strong> Gain 2[Credits].",
			"code": "20035",
			"title": "Fall Guy",
		})

	NRCardDefs.defcard("Fan Site", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever the Corp scores an agenda, add Fan Site to your score area as an agenda worth 0 agenda points.",
			"code": "08085",
			"title": "Fan Site",
		})

	NRCardDefs.defcard("Fencer Fueno", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Companion - Virtual",
			"subtypes": ["Companion", "Virtual"],
			"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nWhenever you make a successful run, you can spend hosted credits for the remainder of that run.\nWhen your turn ends, if there are 3 or more hosted credits, you must pay 1[Credits] or trash this resource.",
			"code": "26007",
			"title": "Fencer Fueno",
		})

	NRCardDefs.defcard("Fester", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever the Corp purges virus counters, if the Corp has at least 2[Credits], they lose 2[Credits].",
			"code": "06075",
			"title": "Fester",
		})

	NRCardDefs.defcard("Film Critic", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Film Critic can host a single agenda.\nWhenever you access an agenda, you may host that agenda on Film Critic (the agenda is no longer being accessed and is uninstalled).\n[Click],[Click]: Add an agenda hosted on Film Critic to your score area.",
			"code": "08086",
			"title": "Film Critic",
		})

	NRCardDefs.defcard("Find the Truth", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Adam",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Directive - Virtual",
			"subtypes": ["Directive", "Virtual"],
			"text": "Whenever you draw a card, reveal that card.\nThe first time each turn you make a successful run, you may look at the top card of R&D.",
			"code": "11047",
			"title": "Find the Truth",
		})

	NRCardDefs.defcard("First Responders", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "2[Credits]: Draw 1 card. Use this ability only if you have suffered damage from a Corp card ability this turn.",
			"code": "11048",
			"title": "First Responders",
		})

	NRCardDefs.defcard("Fransofia Ward", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The rez cost of each piece of ice is increased by 1[Credits].\nWhenever you encounter a piece of ice, if the Corp has 15[Credits] or more, you may trash this resource to bypass that ice. <em>(Pass that ice. No subroutines or further \"when encountered\" abilities resolve.)</em>",
			"code": "35021",
			"title": "Fransofia Ward",
		})

	NRCardDefs.defcard("Friend of a Friend", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click], [Trash]<strong>:</strong> Gain 5[Credits] and remove 1 tag.\n[Click], [Trash]<strong>:</strong> Gain 9[Credits] and take 1 tag. Use this ability only if you are not tagged.",
			"code": "34074",
			"title": "Friend of a Friend",
		})

	NRCardDefs.defcard("Gang Sign", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever the Corp scores an agenda, breach HQ. You cannot access cards in the root of HQ during this breach.",
			"code": "08067",
			"title": "Gang Sign",
		})

	NRCardDefs.defcard("Gbahali", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Trash]: Break the last subroutine on the encountered piece of ice.",
			"code": "21047",
			"title": "Gbahali",
		})

	NRCardDefs.defcard("Gene Conditioning Shoppe", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "<strong>Genetics</strong> also trigger the second time each turn their trigger condition is met.",
			"code": "08006",
			"title": "Gene Conditioning Shoppe",
		})

	NRCardDefs.defcard("Ghost Runner", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Stealth - Virtual",
			"subtypes": ["Stealth", "Virtual"],
			"text": "Place 3[Credits] on Ghost Runner when it is installed. When there are no credits left on Ghost Runner, trash it.\nYou can use the credits on Ghost Runner during a run.",
			"code": "06040",
			"title": "Ghost Runner",
		})

	NRCardDefs.defcard("Globalsec Security Clearance", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Install only if you have at least 2[link].\nWhen your turn begins, you may lose [Click]. If you do, look at the top card of R&D.",
			"code": "09051",
			"title": "Globalsec Security Clearance",
		})

	NRCardDefs.defcard("Grifter", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "When your turn ends, gain 1[Credits] if you made a successful run this turn; otherwise, trash Grifter.",
			"code": "04046",
			"title": "Grifter",
		})

	NRCardDefs.defcard("Guru Davinder", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[interrupt] → Whenever you would take net or meat damage, prevent all of that damage.\nWhenever this resource prevents 1 or more damage, trash it unless you pay 4[Credits].",
			"code": "10084",
			"title": "Guru Davinder",
		})

	NRCardDefs.defcard("Hackerspace", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "You can install unique <em>(♦)</em> <strong>companion</strong> resources and unique <em>(♦)</em> <strong>connection</strong> resources onto this resource. Each resource installed this way costs 1[Credits] less to install.\nWhile this resource has a hosted <strong>companion</strong> and a hosted <strong>connection</strong>, you get +2 maximum hand size.",
			"code": "36006",
			"title": "Hackerspace",
		})

	NRCardDefs.defcard("Hades Shard", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 7,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Virtual - Source",
			"subtypes": ["Virtual", "Source"],
			"text": "Whenever you make a successful run on Archives, instead of breaching Archives, you may install this resource from your grip, ignoring all costs.\n<strong>[Trash]:</strong> Breach Archives. You cannot access cards in the root of Archives during this breach.\nLimit 1 per deck.",
			"code": "06059",
			"title": "Hades Shard",
		})

	NRCardDefs.defcard("Hannah \"Wheels\" Pilintra", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Once per turn → [Click]<strong>:</strong> Gain [Click]. Run a remote server. When that run ends, if it was unsuccessful, take 1 tag.\n[Click], [Trash]<strong>:</strong> Gain [Click][Click]. Remove 1 tag.",
			"code": "34008",
			"title": "Hannah \"Wheels\" Pilintra",
		})

	NRCardDefs.defcard("Hard at Work", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When your turn begins, gain 2[Credits] and lose [Click].",
			"code": "04023",
			"title": "Hard at Work",
		})

	NRCardDefs.defcard("Hernando Cortez", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "If the Corp has at least 10[Credits], as an additional cost to rez each piece of ice, the Corp must spend credits equal to the number of subroutines on that ice.",
			"code": "11004",
			"title": "Hernando Cortez",
		})

	NRCardDefs.defcard("Human First", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever an agenda is scored or stolen, gain credits equal to the agenda points on that agenda.",
			"code": "07048",
			"title": "Human First",
		})

	NRCardDefs.defcard("Hunting Grounds", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Apex",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Location - Virtual",
			"subtypes": ["Location", "Virtual"],
			"text": "[interrupt], once per turn → <strong>0[Credits]:</strong> Prevent a \"when encountered\" ability on a piece of ice.\n[Trash]<strong>:</strong> Install the top 3 cards of your stack facedown.",
			"code": "09035",
			"title": "Hunting Grounds",
		})

	NRCardDefs.defcard("Ice Analyzer", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever the Corp rezzes a piece of ice, place 1[Credits] on Ice Analyzer.\nYou may use credits on Ice Analyzer to install programs.",
			"code": "25057",
			"title": "Ice Analyzer",
		})

	NRCardDefs.defcard("Ice Carver", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "While you are encountering a piece of ice, it gets −1 strength.",
			"code": "31009",
			"title": "Ice Carver",
		})

	NRCardDefs.defcard("Info Bounty", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When your turn begins, identify your mark. <em>(If you donʼt have a mark, a random central server becomes your mark for this turn.)</em>\nThe first time each turn a run on your mark ends, gain 2[Credits] if you breached that server during that run.",
			"code": "33083",
			"title": "Info Bounty",
		})

	NRCardDefs.defcard("Inside Man", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "2[recurring-credit]\nUse these credits to install hardware.",
			"code": "02068",
			"title": "Inside Man",
		})

	NRCardDefs.defcard("Investigative Journalism", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Install only if the Corp has at least 1 bad publicity.\n[Click][Click][Click][Click], [Trash]<strong>:</strong> Give the Corp 1 bad publicity.",
			"code": "07049",
			"title": "Investigative Journalism",
		})

	NRCardDefs.defcard("Investigator Inez Delgado", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you win a game with Investigator Inez Delgado in your score area, reveal set 2.\n<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Expose all cards in a remote server. Use this only if you have stolean an agenda this turn.",
			"code": "14014",
			"title": "Investigator Inez Delgado",
		})

	NRCardDefs.defcard("Investigator Inez Delgado 2", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you win a game with Investigator Inez Delgado in your score area, reveal set 5.\n<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Reveal the top 3 cards in R&D. Use this only if you have stolean an agenda this turn.",
			"code": "14015",
			"title": "Investigator Inez Delgado 2",
		})

	NRCardDefs.defcard("Investigator Inez Delgado 3", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you win a game with Investigator Inez Delgado in your score area, reveal set 8.\n<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Reveal each card in HQ. Use this only if you have stolean an agenda this turn.",
			"code": "14016",
			"title": "Investigator Inez Delgado 3",
		})

	NRCardDefs.defcard("Investigator Inez Delgado 4", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "<strong>Add Investigator Inez Delgado to your score area as an agenda worth 0 agenda points:</strong> Reveal each card in HQ and the top card of R&D. Use this only if you have stolean an agenda this turn.",
			"code": "14017",
			"title": "Investigator Inez Delgado 4",
		})

	NRCardDefs.defcard("Jackpot!", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "When your turn begins, you may place 1[Credits] on Jackpot!.\nWhenever an agenda is added to your score area, you may take any number of credits from Jackpot!. If you do, trash Jackpot!.",
			"code": "21090",
			"title": "Jackpot!",
		})

	NRCardDefs.defcard("Jak Sinclair", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Reduce the cost to install Jak Sinclair by 1 for each [link] you have.\nWhen your turn begins, you may make a run. You cannot use programs during this run.",
			"code": "09052",
			"title": "Jak Sinclair",
		})

	NRCardDefs.defcard("Jarogniew Mercs", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Clan - Connection",
			"subtypes": ["Clan", "Connection"],
			"text": "When you install this resource, take 1 tag. Load X power counters onto this resource, where X is equal to the number of tags you have plus 3. When this resource is empty, trash it.\nThe Corp cannot trash this resource while there is another resource installed.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent 1 meat damage.",
			"code": "12062",
			"title": "Jarogniew Mercs",
		})

	NRCardDefs.defcard("John Masanori", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The first time you make a successful run each turn, draw 1 card.\nThe first time you make an unsuccessful run each turn, take 1 tag.",
			"code": "25064",
			"title": "John Masanori",
		})

	NRCardDefs.defcard("Joshua B.", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, you may gain [Click]. If you do, take 1 tag when this turn ends.",
			"code": "02042",
			"title": "Joshua B.",
		})

	NRCardDefs.defcard("Juli Moreira Lee", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you install this resource, load 4 power counters onto it. When it is empty, trash it.\nThe first time each turn you take an action on an installed resource, remove 1 hosted power counter and gain [Click].",
			"code": "34084",
			"title": "Juli Moreira Lee",
		})

	NRCardDefs.defcard("Kasi String", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The first time each turn a successful run on a remote server ends, if you breached the server but stole no agendas, you may place 1 power counter on this resource.\nWhen this resource has 4 or more hosted power counters, add it to your score area as an agenda worth 1 agenda point.",
			"code": "21111",
			"title": "Kasi String",
		})

	NRCardDefs.defcard("Kati Jones", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "You cannot use this resource more than once per turn.\n[Click]<strong>:</strong> Place 3[Credits] on this resource.\n[Click]<strong>:</strong> Take all credits from this resource.",
			"code": "25065",
			"title": "Kati Jones",
		})

	NRCardDefs.defcard("Keros Mcintyre", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The first time you derez a piece of ice each turn, gain 2[Credits].",
			"code": "12065",
			"title": "Keros Mcintyre",
		})

	NRCardDefs.defcard("\"Knickknack\" O'Brian", {
			"title": "\"Knickknack\" O'Brian",
		})

	NRCardDefs.defcard("Kongamato", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Trash]: Break the first subroutine on the encountered piece of ice.",
			"code": "21027",
			"title": "Kongamato",
		})

	NRCardDefs.defcard("Lago Paranoá Shelter", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection - Location",
			"subtypes": ["Connection", "Location"],
			"text": "The first time each turn the Corp installs a card in the root of a server, you may trash the top card of your stack to draw 1 card.",
			"code": "34009",
			"title": "Lago Paranoá Shelter",
		})

	NRCardDefs.defcard("Laguna Velasco District", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "Whenever you take the basic action to draw cards, increase the number of cards you draw by 1.",
			"code": "13022",
			"title": "Laguna Velasco District",
		})

	NRCardDefs.defcard("Levy Advanced Research Lab", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "[Click]: Reveal the top 4 cards of your stack. If any of those cards are programs, you may add 1 to your grip. Add the rest of the cards to the bottom of your stack in any order.",
			"code": "13021",
			"title": "Levy Advanced Research Lab",
		})

	NRCardDefs.defcard("Lewi Guilherme", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, either lose 1[Credits] or trash Lewi Guilherme.\nThe Corp's maximum hand size is reduced by 1.",
			"code": "21005",
			"title": "Lewi Guilherme",
		})

	NRCardDefs.defcard("Liberated Account", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 6,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When you install this resource, load 16[Credits] onto it. When it is empty, trash it.\n[Click]<strong>:</strong> Take 4[Credits] from this resource.",
			"code": "31010",
			"title": "Liberated Account",
		})

	NRCardDefs.defcard("Liberated Chela", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click][Click][Click][Click][Click], <strong>forfeit an agenda:</strong> The Corp may forfeit an agenda to remove this resource from the game. If they do not, add this resource to your score area as an agenda worth 2 agenda points.",
			"code": "10081",
			"title": "Liberated Chela",
		})

	NRCardDefs.defcard("Light the Fire!", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Sabotage",
			"subtypes": ["Sabotage"],
			"text": "[Click], [Trash], <strong>suffer 1 core damage:</strong> Run a remote server. During that run, cards in the root of the attacked server lose all abilities. When that run is successful, trash all cards in the root of the attacked server.",
			"code": "33009",
			"title": "Light the Fire!",
		})

	NRCardDefs.defcard("Logic Bomb", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Adam",
			"cost": 0,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Trash]: Bypass a piece of ice you are currently encountering. Lose any remaining clicks.",
			"code": "21089",
			"title": "Logic Bomb",
		})

	NRCardDefs.defcard("London Library", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "Trash all programs hosted on London Library when your turn ends.\n[Click]: Install a non-<strong>virus</strong> program from your grip on London Library, ignoring the install cost.\n[Click]: Add a program on London Library to your grip.",
			"code": "08029",
			"title": "London Library",
		})

	NRCardDefs.defcard("Manuel Lattes de Moura", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever you breach HQ or R&D while you are tagged, access 1 additional card.\nThreat 3 → As an additional cost to trash this resource with the basic action, the Corp must trash 1 card from HQ. <em>(This ability is active if any player has 3 or more agenda points.)</em>",
			"code": "34075",
			"title": "Manuel Lattes de Moura",
		})

	NRCardDefs.defcard("\"Pretty\" Mary da Silva", {
			"title": "\"Pretty\" Mary da Silva",
		})

	NRCardDefs.defcard("Maxwell James", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "+1[link]\n[Trash]: Derez a piece of ice protecting a remote server. Use this ability only during the next paid ability window after a successful run on HQ ends.",
			"code": "13011",
			"title": "Maxwell James",
		})

	NRCardDefs.defcard("Miss Bones", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Place 12[Credits] from the bank on Miss Bones when she is installed. When there are no credits left on Miss Bones, trash her.\nUse these credits to trash installed cards.",
			"code": "22014",
			"title": "Miss Bones",
		})

	NRCardDefs.defcard("Motivation", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "When your turn begins, you may look at the top card of your stack.",
			"code": "04008",
			"title": "Motivation",
		})

	NRCardDefs.defcard("Mr. Li", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "<strong>[Click]:</strong> Draw 2 cards. When you do, add 1 of those cards to the bottom of your stack.",
			"code": "20036",
			"title": "Mr. Li",
		})

	NRCardDefs.defcard("Muertos Gang Member", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you install Muertos Gang Member, the Corp must derez a card.\nWhen Muertos Gang Member is uninstalled, the Corp may rez a card, ignoring the rez cost.\n[Trash]: Draw 1 card.",
			"code": "08068",
			"title": "Muertos Gang Member",
		})

	NRCardDefs.defcard("Mystic Maemi", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Companion - Virtual",
			"subtypes": ["Companion", "Virtual"],
			"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nYou can spend hosted credits to play events.\nWhen your turn ends, if there are 3 or more hosted credits, you must trash 1 card from your grip at random or trash this resource.",
			"code": "27001",
			"title": "Mystic Maemi",
		})

	NRCardDefs.defcard("Net Mercur", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Stealth - Virtual",
			"subtypes": ["Stealth", "Virtual"],
			"text": "The first time you spend credits from a <strong>stealth</strong> card during each run, place 1[Credits] on this resource or draw 1 card.\nYou can spend hosted credits for anything.",
			"code": "11046",
			"title": "Net Mercur",
		})

	NRCardDefs.defcard("Network Exchange", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The install cost of each piece of ice that is not installed in the innermost position is increased by 1.",
			"code": "12007",
			"title": "Network Exchange",
		})

	NRCardDefs.defcard("Neutralize All Threats", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Adam",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Directive - Virtual",
			"subtypes": ["Directive", "Virtual"],
			"text": "The first time each turn you access a card with a trash cost, reveal it. You must trash that card by paying its trash cost, if able.\nWhenever you breach HQ, access 1 additional card.",
			"code": "09043",
			"title": "Neutralize All Threats",
		})

	NRCardDefs.defcard("New Angeles City Hall", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location - Government",
			"subtypes": ["Location", "Government"],
			"text": "[interrupt] → <strong>2[Credits]:</strong> Prevent 1 tag.\nWhen you steal an agenda, trash this resource.",
			"code": "02109",
			"title": "New Angeles City Hall",
		})

	NRCardDefs.defcard("Nurse Hạnh", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever 2 or more facedown cards in Archives are turned faceup, draw 2 cards.",
			"code": "36007",
			"title": "Nurse Hạnh",
		})

	NRCardDefs.defcard("No Free Lunch", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[Trash]<strong>:</strong> Gain 3[Credits].\n[Trash]<strong>:</strong> Remove 1 tag.",
			"code": "33020",
			"title": "No Free Lunch",
		})

	NRCardDefs.defcard("No One Home", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[interrupt] → The first time each turn you would take tags or suffer net damage, you may trash this resource to have the Corp trace[0]. If unsuccessful, prevent all tags or all net damage.",
			"code": "21045",
			"title": "No One Home",
		})

	NRCardDefs.defcard("Off-Campus Apartment", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "Off-Campus Apartment can host any number of <strong>connections</strong>.\nWhenever you install a <strong>connection</strong> on Off-Campus Apartment, draw 1 card.",
			"code": "08022",
			"title": "Off-Campus Apartment",
		})

	NRCardDefs.defcard("Officer Frank", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Trash], 1[Credits]: The Corp trashes 2 cards from HQ at random. Use this ability only if you suffered meat damage this turn.",
			"code": "13024",
			"title": "Officer Frank",
		})

	NRCardDefs.defcard("Open Market", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Job - Location",
			"subtypes": ["Job", "Location"],
			"text": "When you install this resource, load 6[Credits] onto it. When it is empty, trash it.\nYou can spend hosted credits to install <strong>connection</strong> and <strong>job</strong> resources.\nWhen your turn begins, take 1[Credits] from this resource.",
			"code": "35022",
			"title": "Open Market",
		})

	NRCardDefs.defcard("Oracle May", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "You cannot use this resource more than once per turn.\n[Click]<strong>:</strong> Choose a card type. Reveal the top card of your stack. If that card has the chosen type, draw it and gain 2[Credits]. Otherwise, trash it.",
			"code": "05054",
			"title": "Oracle May",
		})

	NRCardDefs.defcard("Order of Sol", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "The first time you have no credits in your credit pool each turn, gain 1[Credits].",
			"code": "06058",
			"title": "Order of Sol",
		})

	NRCardDefs.defcard("PAD Tap", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "The first time the Corp gains credits through a card ability each turn, you may gain 1[Credits].\n[Click], 3[Credits]: Trash PAD Tap. Only the Corp can use this ability.",
			"code": "21106",
			"title": "PAD Tap",
		})

	NRCardDefs.defcard("Paige Piper", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The first time you install a card each turn (including Paige Piper), you may search your stack for any number of copies of that card and add them to your heap. Shuffle your stack.",
			"code": "08002",
			"title": "Paige Piper",
		})

	NRCardDefs.defcard("Paladin Poemu", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Companion - Virtual",
			"subtypes": ["Companion", "Virtual"],
			"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nYou can spend hosted credits to install non-<strong>connection</strong> cards.\nWhen your turn ends, if there are 3 or more hosted credits, trash 1 of your installed cards.",
			"code": "26073",
			"title": "Paladin Poemu",
		})

	NRCardDefs.defcard("Paparazzi", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "You are tagged.\n[interrupt] → Whenever you would take meat damage, prevent all of that damage.",
			"code": "08087",
			"title": "Paparazzi",
		})

	NRCardDefs.defcard("Patron", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, you may choose a server.\nThe first time each turn you make a successful run on the chosen server, instead of breaching it, draw 2 cards.",
			"code": "10063",
			"title": "Patron",
		})

	NRCardDefs.defcard("Paule's Café", {
			"title": "Paule's Café",
		})

	NRCardDefs.defcard("Penumbral Toolkit", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Stealth - Virtual",
			"subtypes": ["Stealth", "Virtual"],
			"text": "If you made a successful run on HQ this turn, this resource costs 2[Credits] less to install.\nWhen you install this resource, load 4[Credits] onto it. When it is empty, trash it.\nYou can spend hosted credits during runs.",
			"code": "26081",
			"title": "Penumbral Toolkit",
		})

	NRCardDefs.defcard("Personal Workshop", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "[Click]: Host a program or piece of hardware from your grip on Personal Workshop and place power counters on it equal to its install cost.\n1[Credits]: Remove 1 power counter from a hosted card.\nWhen your turn begins, remove 1 power counter from a hosted card.\nWhen there are no power counters left on a hosted card, install it, ignoring all costs.",
			"code": "02049",
			"title": "Personal Workshop",
		})

	NRCardDefs.defcard("Political Operative", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Install only if you made a successful run on HQ this turn.\n<strong>[Trash]</strong>, <strong>X[Credits]:</strong> Trash 1 rezzed card with trash cost equal to X.",
			"code": "10043",
			"title": "Political Operative",
		})

	NRCardDefs.defcard("Power Tap", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Gain 1[Credits] whenever a trace is initiated.",
			"code": "06016",
			"title": "Power Tap",
		})

	NRCardDefs.defcard("Professional Contacts", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click]<strong>:</strong> Gain 1[Credits] and draw 1 card.",
			"code": "31036",
			"title": "Professional Contacts",
		})

	NRCardDefs.defcard("Psych Mike", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The first time each turn a successful run on R&D ends, you may gain 1[Credits] for each time you accessed a card in R&D during that run.",
			"code": "22021",
			"title": "Psych Mike",
		})

	NRCardDefs.defcard("Public Sympathy", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Your maximum hand size is increased by 2.",
			"code": "02050",
			"title": "Public Sympathy",
		})

	NRCardDefs.defcard("Rachel Beckman", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 8,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "You get +1 allotted [Click] for each of your turns.\nIf you are tagged, trash this resource.",
			"code": "06060",
			"title": "Rachel Beckman",
		})

	NRCardDefs.defcard("Raymond Flint", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever the Corp takes bad publicity, breach HQ. You cannot access cards in the root of HQ during this breach.\n<strong>[Trash]:</strong> Expose 1 card.",
			"code": "04049",
			"title": "Raymond Flint",
		})

	NRCardDefs.defcard("Reclaim", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "[Click], [Trash], <strong>trash a card from your grip</strong>: Install a program, piece of hardware, or <strong>virtual</strong> resource from your heap, paying its install cost.",
			"code": "21107",
			"title": "Reclaim",
		})

	NRCardDefs.defcard("Red Team", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When you install this resource, load 12[Credits] onto it. When it is empty, trash it.\n[Click]<strong>:</strong> Run a central server you have not run this turn. If successful, take 3[Credits] from this resource.",
			"code": "30018",
			"title": "Red Team",
		})

	NRCardDefs.defcard("Rent Rioters", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "[Click][Click][Click],[Trash]<strong>:</strong> Gain 9[Credits].",
			"code": "35011",
			"title": "Rent Rioters",
		})

	NRCardDefs.defcard("Rogue Trading", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "Place 18[Credits] from the bank on Rogue Trading when it is installed. When there are no credits left on Rogue Trading, trash it.\n[Click], [Click]: Take 6[Credits] from Rogue Trading and take 1 tag.",
			"code": "21065",
			"title": "Rogue Trading",
		})

	NRCardDefs.defcard("Rolodex", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "When you install Rolodex, look at the top 5 cards of your stack and arrange them in any order.\nWhen Rolodex is trashed, trash the top 3 cards of your stack.",
			"code": "08084",
			"title": "Rolodex",
		})

	NRCardDefs.defcard("Rosetta 2.0", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Click], <strong>remove an installed program from the game</strong>: Search your stack for a non-<strong>virus</strong> program, shuffle your stack, then install that program, lowering the install cost by the cost of the program removed from the game.",
			"code": "12045",
			"title": "Rosetta 2.0",
		})

	NRCardDefs.defcard("Sacrificial Clone", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent all damage. Trash all installed hardware, all installed non-<strong>virtual</strong> resources, and all cards from your grip. Lose all credits in your credit pool. Remove all tags.",
			"code": "07050",
			"title": "Sacrificial Clone",
		})

	NRCardDefs.defcard("Sacrificial Construct", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Remote",
			"subtypes": ["Remote"],
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent a player from trashing 1 installed program or piece of hardware.",
			"code": "20054",
			"title": "Sacrificial Construct",
		})

	NRCardDefs.defcard("Safety First", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Adam",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Directive - Virtual",
			"subtypes": ["Directive", "Virtual"],
			"text": "Your maximum hand size is reduced by 2.\nWhen your turn ends, draw 1 card if you do not have cards in your grip equal to or greater than your maximum hand size.",
			"code": "09044",
			"title": "Safety First",
		})

	NRCardDefs.defcard("Salsette Slums", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Location - Seedy",
			"subtypes": ["Location", "Seedy"],
			"text": "Access, once per turn → <strong>Pay the trash cost of the card you are accessing:</strong> Remove that card from the game.",
			"code": "10059",
			"title": "Salsette Slums",
		})

	NRCardDefs.defcard("Salvaged Vanadis Armory", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Clan",
			"subtypes": ["Clan"],
			"text": "<strong>[Trash]:</strong> The Corp trashes the top X cards of R&D. X is equal to the amount of damage you have suffered this turn. Use this ability only during the next paid ability window after suffering any amount of damage.",
			"code": "12103",
			"title": "Salvaged Vanadis Armory",
		})

	NRCardDefs.defcard("Same Old Thing", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "[Click], [Click], [Trash]: Play an event from your heap (paying its play cost).",
			"code": "03054",
			"title": "Same Old Thing",
		})

	NRCardDefs.defcard("Scrubber", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "2[recurring-credit] <em>(When you install this card and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to pay trash costs.",
			"code": "31011",
			"title": "Scrubber",
		})

	NRCardDefs.defcard("Security Testing", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When your turn begins, you may choose a server.\nThe first time each turn you make a successful run on the chosen server, instead of breaching it, gain 2[Credits].",
			"code": "31024",
			"title": "Security Testing",
		})

	NRCardDefs.defcard("Shadow Team", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever you draw a Shadow Team, immediately install it.\nWhenever you initiate a run, trash a card from your grip, if able. When you make a successful run on a central server, destroy Shadow Team.",
			"code": "14022",
			"title": "Shadow Team",
		})

	NRCardDefs.defcard("Side Hustle", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When you install this resource and whenever a run begins, place 1[Credits] on this resource.\nWhen there are 6 or more hosted credits, take all credits from this resource, trash it, and draw 1 card.",
			"code": "35034",
			"title": "Side Hustle",
		})

	NRCardDefs.defcard("Smartware Distributor", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click]<strong>:</strong> Place 3[Credits] on this resource.\nWhen your turn begins, take 1[Credits] from this resource.",
			"code": "30033",
			"title": "Smartware Distributor",
		})

	NRCardDefs.defcard("Slipstream", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever you pass a rezzed piece of ice, you may trash this resource. If you do, choose 1 piece of ice protecting a central server in the same position as the passed ice. Move to that ice and approach it. You may jack out.",
			"code": "21085",
			"title": "Slipstream",
		})

	NRCardDefs.defcard("Spoilers", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever the Corp scores an agenda, they trash the top card of R&D.",
			"code": "08082",
			"title": "Spoilers",
		})

	NRCardDefs.defcard("Starlight Crusade Funding", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"text": "When your turn begins, lose [Click].\nIgnore any additional costs on each <strong>double</strong> event you play.",
			"code": "04069",
			"title": "Starlight Crusade Funding",
		})

	NRCardDefs.defcard("Stick and Poke", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Companion - Virtual",
			"subtypes": ["Companion", "Virtual"],
			"text": "The first time each turn you encounter a piece of ice, it gains “[subroutine] Do 1 net damage. The Runner draws 1 card.”, before its other subroutines, for the remainder of that encounter.",
			"code": "36008",
			"title": "Stick and Poke",
		})

	NRCardDefs.defcard("Stim Dealer", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, if there are 2 or more hosted power counters, remove all of them and suffer 1 core damage. This damage cannot be prevented. Otherwise, place 1 power counter on this resource and gain [Click].",
			"code": "07051",
			"title": "Stim Dealer",
		})

	NRCardDefs.defcard("Stoneship Chart Room", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "[Trash]<strong>:</strong> Draw 2 cards.\n[Trash]<strong>:</strong> Charge 1 of your installed cards.",
			"code": "33030",
			"title": "Stoneship Chart Room",
		})

	NRCardDefs.defcard("Street Magic", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Unbroken subroutines resolve in the order of your choice.",
			"code": "10003",
			"title": "Street Magic",
		})

	NRCardDefs.defcard("Street Peddler", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "When you install Street Peddler, host the top 3 cards of your stack facedown on Street Peddler (you may look at these cards at any time).\n[Trash]: Install 1 card hosted on Street Peddler, lowering its install cost by 1.",
			"code": "08062",
			"title": "Street Peddler",
		})

	NRCardDefs.defcard("Symmetrical Visage", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Genetics",
			"subtypes": ["Genetics"],
			"text": "The first time you spend [Click] to draw 1 card (not through a card ability) each turn, gain 1[Credits].",
			"code": "08009",
			"title": "Symmetrical Visage",
		})

	NRCardDefs.defcard("Synthetic Blood", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Genetics",
			"subtypes": ["Genetics"],
			"text": "The first time you take damage each turn, draw 1 card.",
			"code": "08007",
			"title": "Synthetic Blood",
		})

	NRCardDefs.defcard("Tallie Perrault", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever a <strong>gray ops</strong> or <strong>black ops</strong> operation is trashed after resolving, you may give the Corp 1 bad publicity and take 1 tag.\n[Trash]<strong>:</strong> Draw 1 card for each bad publicity the Corp has.",
			"code": "04083",
			"title": "Tallie Perrault",
		})

	NRCardDefs.defcard("Tech Trader", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever you use a [Trash] ability, gain 1[Credits].",
			"code": "10023",
			"title": "Tech Trader",
		})

	NRCardDefs.defcard("Technical Writer", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Whenever you install a piece of hardware or a program, place 1[Credits] from the bank on Technical Writer.\n[Click],[Trash]: Take all credits from Technical Writer.",
			"code": "09055",
			"title": "Technical Writer",
		})

	NRCardDefs.defcard("Telework Contract", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "When you install this resource, load 9[Credits] onto it. When it is empty, trash it.\nOnce per turn → [Click]<strong>:</strong> Take 3[Credits] from this resource.",
			"code": "30027",
			"title": "Telework Contract",
		})

	NRCardDefs.defcard("Temple of the Liberated Mind", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "[Click]<strong>:</strong> Place 1 power counter on this resource.\nOnce per turn → <strong>Hosted power counter:</strong> Gain [Click]. Use this ability only during your turn.",
			"code": "10082",
			"title": "Temple of the Liberated Mind",
		})

	NRCardDefs.defcard("Temüjin Contract", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "Choose a server and place 20[Credits] from the bank on Temüjin Contract when you install it. When there are no credits left on Temüjin Contract, trash it.\nWhenever you make a successful run on the chosen server, take 4[Credits] from Temüjin Contract.",
			"code": "11026",
			"title": "Temüjin Contract",
		})

	NRCardDefs.defcard("The Archivist", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "+1[link]\nWhenever the Corp scores an <strong>initiative</strong> or <strong>security</strong> agenda, they must trace[1]. If unsuccessful, give them 1 bad publicity.",
			"code": "12003",
			"title": "The Archivist",
		})

	NRCardDefs.defcard("The Artist", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 5,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Once per turn → [Click]<strong>:</strong> Gain 2[Credits].\nOnce per turn → [Click]<strong>:</strong> Install 1 program or piece of hardware from your grip, paying 1[Credits] less.",
			"code": "26027",
			"title": "The Artist",
		})

	NRCardDefs.defcard("The Back", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Job - Location",
			"subtypes": ["Job", "Location"],
			"text": "The first time each turn you use a piece of hardware during a run, place 1 power counter on this resource.\n[Click], <strong>remove this resource from the game:</strong> For each hosted power counter, choose up to 2 cards in your heap with [Trash] abilities. Shuffle the chosen cards into your stack.",
			"code": "26082",
			"title": "The Back",
		})

	NRCardDefs.defcard("The Black File", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The Corp cannot win the game except if you are flatlined.\nWhen your turn begins, place 1 power counter on this resource. If there are 3 or more hosted power counters, remove this resource from the game.\nLimit 1 per deck.",
			"code": "10099",
			"title": "The Black File",
		})

	NRCardDefs.defcard("The Class Act", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 5,
			"uniqueness": true,
			"keywords": "Connection - Ritzy",
			"subtypes": ["Connection", "Ritzy"],
			"text": "When a discard phase ends, if you installed this resource this turn, draw 4 cards.\n[interrupt] → The first time each turn you would draw any number of cards, look at the top X cards of your stack. Add 1 of those cards to the bottom of your stack. X is equal to the number of cards you would draw plus 1.",
			"code": "26018",
			"title": "The Class Act",
		})

	NRCardDefs.defcard("The Helpful AI", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection - Link - Virtual",
			"subtypes": ["Connection", "Link", "Virtual"],
			"text": "+1[link]\n[Trash]: Choose an <strong>icebreaker</strong>. That <strong>icebreaker</strong> has +2 strength until the end of the turn.",
			"code": "02008",
			"title": "The Helpful AI",
		})

	NRCardDefs.defcard("The Masque A", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click],[Trash]: Make a run and gain [Click]. If successful, draw 1 card.",
			"code": "14024",
			"title": "The Masque A",
		})

	NRCardDefs.defcard("The Masque B", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click],[Trash]: Make a run and gain [Click]. If that run is successful when it ends, you may immediately make another run on another server.",
			"code": "14025",
			"title": "The Masque B",
		})

	NRCardDefs.defcard("The Nihilist", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 5,
			"uniqueness": true,
			"keywords": "Connection - Seedy",
			"subtypes": ["Connection", "Seedy"],
			"text": "The first time each turn you install a <strong>virus</strong> program, place 2 virus counters on this resource.\nWhen your turn begins, you may remove any 2 virus counters from your installed cards. If you do, draw 2 cards unless the Corp trashes the top card of R&D.",
			"code": "26008",
			"title": "The Nihilist",
		})

	NRCardDefs.defcard("The Shadow Net", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "[Click]<strong>, forfeit an agenda:</strong> Play an event from your heap, ignoring all costs.",
			"code": "13027",
			"title": "The Shadow Net",
		})

	NRCardDefs.defcard("The Source", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "The advancement requirement of all agendas is increased by 1.\nAs an additional cost to steal an agenda, you must pay 3[Credits].\nTrash The Source when an agenda is scored or stolen.",
			"code": "03055",
			"title": "The Source",
		})

	NRCardDefs.defcard("The Supplier", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "[Click]: Host a resource or piece of hardware from your grip on The Supplier.\nWhen your turn begins, you may install a hosted card, lowering the install cost by 2.",
			"code": "06056",
			"title": "The Supplier",
		})

	NRCardDefs.defcard("The Turning Wheel", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "Whenever a run on HQ or R&D ends, place 1 power counter on this resource if you stole no agendas during that run.\n<strong>2 hosted power counters:</strong> Choose HQ or R&D. For the remainder of this run, access 1 additional card whenever you breach that server.",
			"code": "10085",
			"title": "The Turning Wheel",
		})

	NRCardDefs.defcard("The Twinning", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The first time each turn you spend credits from an installed card, place 1 power counter on this resource.\nWhenever you breach HQ or R&D, you may remove up to 2 hosted power counters to access that many additional cards.",
			"code": "33010",
			"title": "The Twinning",
		})

	NRCardDefs.defcard("Theophilius Bagbiter", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When you install Theophilius Bagbiter, lose all credits in your credit pool.\nYour maximum hand size is equal to the number of credits in your credit pool.",
			"code": "05049",
			"title": "Theophilius Bagbiter",
		})

	NRCardDefs.defcard("Thunder Art Gallery", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Location - Ritzy",
			"subtypes": ["Location", "Ritzy"],
			"text": "The first time you avoid or remove a tag each turn, you may install a card from your grip, lowering its install cost by 1.",
			"code": "22013",
			"title": "Thunder Art Gallery",
		})

	NRCardDefs.defcard("Tri-maf Contact", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "You cannot use this resource more than once per turn.\n[Click]<strong>:</strong> Gain 2[Credits].\nWhen this resource is trashed, suffer 3 meat damage.",
			"code": "05050",
			"title": "Tri-maf Contact",
		})

	NRCardDefs.defcard("Trickster Taka", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Companion - Stealth - Virtual",
			"subtypes": ["Companion", "Stealth", "Virtual"],
			"text": "When your turn begins and whenever you steal an agenda, place 1[Credits] on this resource.\nYou can spend hosted credits to use programs during runs.\nWhen your turn ends, if there are 3 or more hosted credits, you must take 1 tag or trash this resource.",
			"code": "26009",
			"title": "Trickster Taka",
		})

	NRCardDefs.defcard("Tsakhia \"Bankhar\" Gantulga", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, you may choose a server.\nDuring the first encounter each turn with a piece of ice protecting the chosen server, whenever the Corp would resolve a subroutine, instead they resolve \"[subroutine] Do 1 net damage.\".",
			"code": "33074",
			"title": "Tsakhia \"Bankhar\" Gantulga",
		})

	NRCardDefs.defcard("Tyson Observatory", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "[Click], [Click]: Search your stack for a piece of hardware, reveal it, and add it to your grip. Shuffle your stack.",
			"code": "08030",
			"title": "Tyson Observatory",
		})

	NRCardDefs.defcard("Underdome Irregulars", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your action phase ends, if a piece of ice was rezzed this turn, draw 2 cards or remove 1 tag. If no ice was rezzed this turn, trash this resource.",
			"code": "36016",
			"title": "Underdome Irregulars",
		})

	NRCardDefs.defcard("Underworld Contact", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "When your turn begins, gain 1[Credits] if you have at least 2[link].",
			"code": "20060",
			"title": "Underworld Contact",
		})

	NRCardDefs.defcard("Urban Art Vernissage", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Job - Ritzy",
			"subtypes": ["Job", "Ritzy"],
			"text": "When your turn begins, you may add 1 installed non-<strong>virus</strong> <strong>trojan</strong> program to your grip. If you do, place 2[Credits] on this resource.\nYou can spend hosted credits to install cards.",
			"code": "34029",
			"title": "Urban Art Vernissage",
		})

	NRCardDefs.defcard("Utopia Shard", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 7,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Virtual - Source",
			"subtypes": ["Virtual", "Source"],
			"text": "Whenever you make a successful run on HQ, instead of breaching HQ, you may install this resource from your grip, ignoring all costs.\n<strong>[Trash]:</strong> The Corp discards 2 cards from HQ at random.\nLimit 1 per deck.",
			"code": "06100",
			"title": "Utopia Shard",
		})

	NRCardDefs.defcard("Valentina Ferreira Carvalho", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever you remove 1 or more tags, gain 1[Credits].\nThreat 3 → When you install this resource during your turn, you may remove 1 tag or gain 2[Credits]. <em>(This ability is active if any player has 3 or more agenda points.)</em>",
			"code": "34095",
			"title": "Valentina Ferreira Carvalho",
		})

	NRCardDefs.defcard("Verbal Plasticity", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Genetics",
			"subtypes": ["Genetics"],
			"text": "The first time each turn you take the basic action to draw 1 card, instead draw 2 cards.",
			"code": "30034",
			"title": "Verbal Plasticity",
		})

	NRCardDefs.defcard("Virus Breeding Ground", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "When your turn begins, place 1 virus counter on Virus Breeding Ground.\n[Click]: Move 1 virus counter on Virus Breeding Ground to another card with at least 1 virus counter on it.",
			"code": "07052",
			"title": "Virus Breeding Ground",
		})

	NRCardDefs.defcard("Wasteland", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Apex",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Location - Virtual",
			"subtypes": ["Location", "Virtual"],
			"text": "The first time each turn you trash 1 of your installed cards, gain 1[Credits].",
			"code": "09036",
			"title": "Wasteland",
		})

	NRCardDefs.defcard("Whistleblower", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Connection",
			"subtypes": ["Connection"],
			"text": "Whenever you make a successful run, you may trash this resource to choose a card name. The next time this run you access an agenda with the chosen name, steal it, ignoring all costs. <em>(You are no longer accessing it.)</em>",
			"code": "26030",
			"title": "Whistleblower",
		})

	NRCardDefs.defcard("Wireless Net Pavilion", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Location",
			"subtypes": ["Location"],
			"text": "As an additional cost to take the basic action to trash 1 installed resource, the Corp must pay 2[Credits].",
			"code": "08108",
			"title": "Wireless Net Pavilion",
		})

	NRCardDefs.defcard("Woman in the Red Dress", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Connection - Virtual",
			"subtypes": ["Connection", "Virtual"],
			"text": "When your turn begins, reveal the top card of R&D. The Corp may draw that card.",
			"code": "04048",
			"title": "Woman in the Red Dress",
		})

	NRCardDefs.defcard("Word on the Street", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"text": "As an additional cost to score an agenda the Corp installed this turn, they must add this resource to their score area as an agenda worth −1 agenda points with “You cannot forfeit this agenda.”.\nWhen the Corp scores an agenda they did not install this turn, trash this resource, gain 4[Credits], and draw 1 card.",
			"code": "36025",
			"title": "Word on the Street",
		})

	NRCardDefs.defcard("Wyldside", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Location - Seedy",
			"subtypes": ["Location", "Seedy"],
			"text": "When your turn begins, draw 2 cards and lose [Click].",
			"code": "01016",
			"title": "Wyldside",
		})

	NRCardDefs.defcard("Xanadu", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Virtual",
			"subtypes": ["Virtual"],
			"text": "The rez cost of each piece of ice is increased by 1[Credits].",
			"code": "31012",
			"title": "Xanadu",
		})

	NRCardDefs.defcard("Zona Sul Shipping", {
			"type": "Resource",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Place 1[Credits] on Zona Sul Shipping when your turn begins.\n[Click]: Take all credits from Zona Sul Shipping.\nTrash Zona Sul Shipping if you are tagged.",
			"code": "06097",
			"title": "Zona Sul Shipping",
		})
