class_name NRCardsHardware
extends RefCounted

## Printed card data from game.cards.hardware (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Acacia", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Whenever the Corp purges virus counters, you may gain 1[Credits] for each virus counter removed and trash Acacia.",
			"code": "21021",
			"title": "Acacia",
		})

	NRCardDefs.defcard("Adjusted Matrix", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Install only on an <strong>icebreaker</strong>.\nHost <strong>icebreaker</strong> gains <strong>AI</strong> and \"Interface → <strong>Lose [Click]:</strong> Break 1 subroutine.\"",
			"code": "12046",
			"title": "Adjusted Matrix",
		})

	NRCardDefs.defcard("AirbladeX (JSRF Ed.)", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Vehicle",
			"subtypes": ["Vehicle"],
			"text": "When you install this hardware, load 3 power counters onto it. When it is empty, trash it.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent 1 net damage. Use this ability only during a run.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent a \"when encountered\" ability on a piece of ice.",
			"code": "34022",
			"title": "AirbladeX (JSRF Ed.)",
		})

	NRCardDefs.defcard("Akamatsu Mem Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+1[Memory Unit]",
			"code": "25048",
			"title": "Akamatsu Mem Chip",
		})

	NRCardDefs.defcard("Alarm Clock", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": true,
			"text": "When your turn begins, you may run HQ. The first time you encounter a piece of ice during that run, you may spend [Click][Click] to bypass it.",
			"code": "34078",
			"title": "Alarm Clock",
		})

	NRCardDefs.defcard("Amanuensis", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhen your turn ends, place 1 power counter on this hardware if you are tagged.\nWhenever you remove 1 or more tags, you may remove 1 hosted power counter to draw 2 cards.\nLimit 1 <strong>console</strong> per player.",
			"code": "34069",
			"title": "Amanuensis",
		})

	NRCardDefs.defcard("Aniccam", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nThe first time each turn an event is trashed <em>(from any location)</em>, draw 1 card.\nLimit 1 <strong>console</strong> per player.",
			"code": "26084",
			"title": "Aniccam",
		})

	NRCardDefs.defcard("Archives Interface", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"text": "[interrupt] → Whenever you would access a card in Archives, you may instead remove it from the game. Use this ability only once each time you breach Archives.",
			"code": "07044",
			"title": "Archives Interface",
		})

	NRCardDefs.defcard("Astrolabe", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nDraw 1 card whenever the Corp creates a server.\nLimit 1 <strong>console</strong> per player.",
			"code": "06079",
			"title": "Astrolabe",
		})

	NRCardDefs.defcard("Autoscripter", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"text": "The first time you install a program from your grip during your turn, gain [Click].\nTrash Autoscripter if you make an unsuccessful run.",
			"code": "06076",
			"title": "Autoscripter",
		})

	NRCardDefs.defcard("Basilar Synthgland 2KVJ", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, suffer 2 core damage.\nYou get +1 allotted [Click] for each of your turns.",
			"code": "33086",
			"title": "Basilar Synthgland 2KVJ",
		})

	NRCardDefs.defcard("Blackguard", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 11,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nWhenever you expose a card, the Corp must rez it by paying its rez cost, if able.\nLimit 1 <strong>console</strong> per player.",
			"code": "04085",
			"title": "Blackguard",
		})

	NRCardDefs.defcard("Bling", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever you install a card without spending credits, you may host the top card of your stack faceup on this hardware. <em>(It is not installed.)</em>\nYou can play or install hosted cards as if they were in your grip.\nWhen your discard phase ends, trash all hosted cards.\nLimit 1 <strong>console</strong> per player.",
			"code": "35006",
			"title": "Bling",
		})

	NRCardDefs.defcard("BMI Buffer", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Whenever a program is trashed from your grip, host it on BMI Buffer instead of adding it to your heap.\n[Click][Click]: Install 1 hosted program (paying all costs).",
			"code": "14020",
			"title": "BMI Buffer",
		})

	NRCardDefs.defcard("BMI Buffer 2", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Whenever a program is trashed from your grip, host it on BMI Buffer instead of adding it to your heap.\n[Click][Click]: Install 1 hosted program, ignoring all costs.",
			"code": "14021",
			"title": "BMI Buffer 2",
		})

	NRCardDefs.defcard("Bookmark", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "<strong>[Click]:</strong> Host up to 3 cards from your grip facedown on this hardware <em>(you may look at these cards at any time)</em>.\n<strong>[Click]:</strong> Add all hosted cards to your grip.\n<strong>[Trash]:</strong> Add all hosted cards to your grip.",
			"code": "08106",
			"title": "Bookmark",
		})

	NRCardDefs.defcard("Boomerang", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"text": "When you install this hardware, choose 1 installed piece of ice. Use this hardware only during encounters with that ice.\n<strong>[Trash]:</strong> Break up to 2 subroutines. When this run ends, if it was successful, you may shuffle 1 copy of Boomerang from your heap into your stack.",
			"code": "26075",
			"title": "Boomerang",
		})

	NRCardDefs.defcard("Borrowed Goods", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+1[Memory Unit]\nWhen you install this hardware, if you are not tagged, take 1 tag.",
			"code": "36013",
			"title": "Borrowed Goods",
		})

	NRCardDefs.defcard("Box-E", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nYour maximum hand size is increased by 2.\nLimit 1 <strong>console</strong> per player.",
			"code": "06055",
			"title": "Box-E",
		})

	NRCardDefs.defcard("Brain Cage", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "You get +3 maximum hand size.\nWhen you install this hardware, suffer 1 core damage.",
			"code": "08049",
			"title": "Brain Cage",
		})

	NRCardDefs.defcard("Brain Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Adam",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+X[Memory Unit]\nYour maximum hand size is increased by X.\nX is equal to the number of agenda points you have.\nLimit 1 <strong>console</strong> per player.",
			"code": "09039",
			"title": "Brain Chip",
		})

	NRCardDefs.defcard("Buffer Drive", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": true,
			"text": "The first time each turn 1 or more cards are trashed from your grip or stack, you may add 1 of those cards to the bottom of your stack.\n<strong>Remove this hardware from the game:</strong> Add 1 card from your heap to the top of your stack.",
			"code": "26093",
			"title": "Buffer Drive",
		})

	NRCardDefs.defcard("Capstone", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"text": "[Click]: Trash any number of cards from your grip. For each trashed card of which you have another copy installed, draw 1 card.",
			"code": "04068",
			"title": "Capstone",
		})

	NRCardDefs.defcard("Capybara", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"text": "Whenever you bypass a piece of ice, you may remove this hardware from the game to derez that ice.",
			"code": "34013",
			"title": "Capybara",
		})

	NRCardDefs.defcard("Carnivore", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nAccess, once per turn → <strong>Trash 2 cards from your grip:</strong> Trash the card you are accessing.\nLimit 1 <strong>console</strong> per player.",
			"code": "30003",
			"title": "Carnivore",
		})

	NRCardDefs.defcard("Cataloguer", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": false,
			"text": "When you install this hardware, load 2 power counters onto it. When it is empty, trash it.\nWhenever you make a successful run on R&D, instead of breaching R&D, you may remove 1 hosted power counter to look at the top 4 cards of R&D and arrange them in any order.\n[Click], <strong>hosted power counter:</strong> Breach R&D. Use this ability only if you made a successful run on R&D this turn.",
			"code": "34088",
			"title": "Cataloguer",
		})

	NRCardDefs.defcard("Chop Bot 3000", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"text": "When your turn begins, you may trash another of your installed cards. If you do, draw 1 card or remove 1 tag.",
			"code": "07045",
			"title": "Chop Bot 3000",
		})

	NRCardDefs.defcard("Clone Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "[Trash]: Install a program from your heap (paying the install cost).",
			"code": "03038",
			"title": "Clone Chip",
		})

	NRCardDefs.defcard("Comet", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nThe first time you play an event each turn, you may play another event (without spending a click) after the first one resolves.\nLimit 1 <strong>console</strong> per player.",
			"code": "08027",
			"title": "Comet",
		})

	NRCardDefs.defcard("Cortez Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "[Trash]: Choose a piece of ice. The Corp must pay 2[Credits] as an additional cost to rez that ice until the end of the turn.",
			"code": "02005",
			"title": "Cortez Chip",
		})

	NRCardDefs.defcard("Cyberdelia", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+1[Memory Unit]\nThe first time each turn you fully break a piece of ice, gain 1[Credits].",
			"code": "21006",
			"title": "Cyberdelia",
		})

	NRCardDefs.defcard("Cyberfeeder", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "1[recurring-credit]\nUse this credit to pay for using <strong>icebreakers</strong> or for installing <strong>virus</strong> programs.",
			"code": "25008",
			"title": "Cyberfeeder",
		})

	NRCardDefs.defcard("CyberSolutions Mem Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+2[Memory Unit]",
			"code": "04086",
			"title": "CyberSolutions Mem Chip",
		})

	NRCardDefs.defcard("Cybsoft MacroDrive", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "1[recurring-credit]\nUse this credit to install programs.",
			"code": "06098",
			"title": "Cybsoft MacroDrive",
		})

	NRCardDefs.defcard("Daredevil", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nThe first time you initiate a run on a server protected by 2 or more pieces of ice each turn, draw 2 cards.\nLimit 1 <strong>console</strong> per player.",
			"code": "12066",
			"title": "Daredevil",
		})

	NRCardDefs.defcard("Dedicated Processor", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Install Dedicated Processor on a non-<strong>AI icebreaker</strong>.\nHost <strong>icebreaker</strong> gains \"2[Credits]: +4 strength.\"",
			"code": "12047",
			"title": "Dedicated Processor",
		})

	NRCardDefs.defcard("Deep Red", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+3[Memory Unit]\nUse the MU on Deep Red only for <strong>Caïssa</strong> programs.\nWhenever you install a <strong>Caïssa</strong> program, you may trigger its [Click] ability without spending [Click].\nLimit 1 <strong>console</strong> per player.",
			"code": "04042",
			"title": "Deep Red",
		})

	NRCardDefs.defcard("Demolisher", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nThe trash cost of each Corp card is lowered by 1[Credits].\nThe first time each turn you trash a Corp card, gain 1[Credits].\nLimit 1 <strong>console</strong> per player.",
			"code": "26002",
			"title": "Demolisher",
		})

	NRCardDefs.defcard("Desperado", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nGain 1[Credits] whenever you make a successful run.\nLimit 1 <strong>console</strong> per player.",
			"code": "01024",
			"title": "Desperado",
		})

	NRCardDefs.defcard("Detente", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nThe first time each turn you make a successful run on HQ, you may host 1 card from HQ at random faceup on this hardware. <em>(It is not installed or rezzed.)</em>\n[Click], <strong>add 2 hosted cards to HQ:</strong> The Runner may access 1 card in HQ at random. Any player can use this ability.\nLimit 1 <strong>console</strong> per player.",
			"code": "35018",
			"title": "Detente",
		})

	NRCardDefs.defcard("Devil Charm", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "Whenever you encounter a piece of ice, you may remove this hardware from the game. If you do, that ice gets −6 strength for the remainder of this run.",
			"code": "26068",
			"title": "Devil Charm",
		})

	NRCardDefs.defcard("Dinosaurus", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "Dinosaurus can host a single non-<strong>AI icebreaker</strong>. The memory cost of the hosted <strong>icebreaker</strong> does not count against your memory limit.\nHosted <strong>icebreaker</strong> has +2 strength.\nLimit 1 <strong>console</strong> per player.",
			"code": "25049",
			"title": "Dinosaurus",
		})

	NRCardDefs.defcard("Docklands Pass", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"text": "The first time each turn you breach HQ, access 1 additional card.",
			"code": "30013",
			"title": "Docklands Pass",
		})

	NRCardDefs.defcard("Doppelgänger", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nOnce per turn → When a successful run ends, you may run any server.\nLimit 1 <strong>console</strong> per player.",
			"code": "20025",
			"title": "Doppelgänger",
		})

	NRCardDefs.defcard("Dorm Computer", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "When you install this hardware, place 4 power counters on it.\n[Click], <strong>hosted power counter:</strong> Run any server. Whenever you would take tags during that run, prevent all of those tags.",
			"code": "08024",
			"title": "Dorm Computer",
		})

	NRCardDefs.defcard("Dyson Fractal Generator", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Chip - Stealth",
			"subtypes": ["Chip", "Stealth"],
			"text": "1[recurring-credit]\nUse this credit to pay for using <strong>fracters</strong>.",
			"code": "04103",
			"title": "Dyson Fractal Generator",
		})

	NRCardDefs.defcard("Dyson Mem Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Chip - Link",
			"subtypes": ["Chip", "Link"],
			"text": "+1[Memory Unit], +1[link]",
			"code": "20057",
			"title": "Dyson Mem Chip",
		})

	NRCardDefs.defcard("DZMZ Optimizer", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "+1[Memory Unit]\nThe first program you install each turn costs 1[Credits] less to install.",
			"code": "30022",
			"title": "DZMZ Optimizer",
		})

	NRCardDefs.defcard("e3 Feedback Implants", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Whenever you break a subroutine on a piece of ice, you may pay 1[Credits] to break 1 subroutine on that ice.",
			"code": "29003",
			"title": "e3 Feedback Implants",
		})

	NRCardDefs.defcard("Ekomind", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "Your memory limit is equal to the number of cards in your grip.\nLimit 1 <strong>console</strong> per player.",
			"code": "06093",
			"title": "Ekomind",
		})

	NRCardDefs.defcard("EMP Device", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "[Trash]: The Corp cannot rez more than 1 piece of ice for the remainder of this run. Use this ability only during a run.",
			"code": "10020",
			"title": "EMP Device",
		})

	NRCardDefs.defcard("Endurance", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 8,
			"factioncost": 5,
			"uniqueness": true,
			"keywords": "Console - Vehicle",
			"subtypes": ["Console", "Vehicle"],
			"text": "+2[Memory Unit]\nWhen you install this hardware, place 3 power counters on it.\nThe first time each turn you make a successful run, place 1 power counter on this hardware.\n<strong>2 hosted power counters:</strong> Break up to 2 subroutines.\nLimit 1 <strong>console</strong> per player.",
			"code": "33025",
			"title": "Endurance",
		})

	NRCardDefs.defcard("Feedback Filter", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Gear",
			"subtypes": ["Gear"],
			"text": "[interrupt] → <strong>3[Credits]:</strong> Prevent 1 net damage.\n[interrupt] → <strong>[Trash]:</strong> Prevent up to 2 core damage.",
			"code": "03037",
			"title": "Feedback Filter",
		})

	NRCardDefs.defcard("Flame-out", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Flame-out can host a single program.\nWhen you install Flame-out, place 9[Credits] on it. Use these credits to pay for using hosted program.\nWhen a turn ends in which you used credits on Flame-out, trash hosted program.",
			"code": "21109",
			"title": "Flame-out",
		})

	NRCardDefs.defcard("Flip Switch", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Use this hardware only during your turn.\n[Trash]<strong>:</strong> Jack out.\n[Trash]<strong>:</strong> Remove 1 tag.\n[interrupt] → [Trash]<strong>:</strong> Reduce the base trace strength of a trace to 0.",
			"code": "26013",
			"title": "Flip Switch",
		})

	NRCardDefs.defcard("Forger", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[link]\n[interrupt] → <strong>[Trash]:</strong> Prevent 1 tag.\n<strong>[Trash]:</strong> Remove 1 tag.\nLimit 1 <strong>console</strong> per player.",
			"code": "08065",
			"title": "Forger",
		})

	NRCardDefs.defcard("Friday Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "Whenever you trash a Corp card, you may place 1 virus counter on Friday Chip.\nWhen your turn begins, you may move 1 hosted virus counter to a <strong>virus</strong> program.",
			"code": "21042",
			"title": "Friday Chip",
		})

	NRCardDefs.defcard("Gachapon", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "<strong>[Trash]:</strong> Set aside the top 6 cards of your stack faceup. You may install 1 program or <strong>virtual</strong> resource from among those cards, paying 2[Credits] less. Shuffle 3 of the remaining cards into your stack, then remove the rest from the game.",
			"code": "26069",
			"title": "Gachapon",
		})

	NRCardDefs.defcard("GAMEDRAGON™ Pro", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "When you install this hardware and when your turn begins, you may host this hardware on an installed non-<strong>AI</strong> <strong>icebreaker</strong>.\nHost <strong>icebreaker</strong> gets +1 strength. Abilities that increase its strength last for the remainder of the run <em>(instead of any shorter duration)</em>.",
			"code": "35027",
			"title": "GAMEDRAGON™ Pro",
		})

	NRCardDefs.defcard("Gebrselassie", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "[Click]: Host this hardware on an installed non-AI <strong>icebreaker</strong>.\nAbilities that increase host icebreaker's strength last for the remainder of the turn <em>(instead of any shorter duration)</em>.",
			"code": "21087",
			"title": "Gebrselassie",
		})

	NRCardDefs.defcard("Ghosttongue", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, suffer 1 core damage.\nThe play cost of each event is lowered by 1[Credits].",
			"code": "33005",
			"title": "Ghosttongue",
		})

	NRCardDefs.defcard("GPI Net Tap", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you approach a piece of ice, you may expose it. You may then trash GPI Net Tap to jack out.",
			"code": "11003",
			"title": "GPI Net Tap",
		})

	NRCardDefs.defcard("Grimoire", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nWhenever you install a <strong>virus</strong> program, place 1 virus counter on that program.\nLimit 1 <strong>console</strong> per player.",
			"code": "01006",
			"title": "Grimoire",
		})

	NRCardDefs.defcard("Heartbeat", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Apex",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\n[interrupt] → <strong>Trash 1 of your installed cards:</strong> Prevent 1 damage.\nLimit 1 <strong>console</strong> per player.",
			"code": "09032",
			"title": "Heartbeat",
		})

	NRCardDefs.defcard("Hermes", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever an agenda is scored or stolen, add 1 unrezzed card to HQ.\nLimit 1 <strong>console</strong> per player.",
			"code": "34014",
			"title": "Hermes",
		})

	NRCardDefs.defcard("Hijacked Router", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"text": "Whenever the Corp creates a server, they lose 1[Credits].\nWhenever you make a successful run on Archives, you may trash this hardware. If you do, the Corp loses 3[Credits].",
			"code": "22005",
			"title": "Hijacked Router",
		})

	NRCardDefs.defcard("Hippo", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 5,
			"uniqueness": true,
			"text": "The first time each turn you fully break the outermost piece of ice protecting the attacked server during a run, you may remove this hardware from the game to trash that ice.",
			"code": "21103",
			"title": "Hippo",
		})

	NRCardDefs.defcard("Hippocampic Mechanocytes", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, place 2 power counters on it and suffer 1 meat damage.\nYou get +1 maximum hand size for each hosted power counter.",
			"code": "33085",
			"title": "Hippocampic Mechanocytes",
		})

	NRCardDefs.defcard("HQ Interface", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you breach HQ, access 1 additional card.",
			"code": "25031",
			"title": "HQ Interface",
		})

	NRCardDefs.defcard("Jeitinho", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "When your turn ends, if you made a successful run on HQ, R&D, and Archives this turn, you may add this hardware to your score area as an <strong>assassination</strong> agenda worth 0 agenda points. Then, if you have 3 <strong>assassination</strong> agendas in your score area, you win the game.\nThreat 3 → Whenever you bypass a piece of ice, you may spend [Click] to install this hardware from your heap.",
			"code": "34079",
			"title": "Jeitinho",
		})

	NRCardDefs.defcard("Keiko", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console - Companion",
			"subtypes": ["Console", "Companion"],
			"text": "+2[Memory Unit]\nThe first time each turn you install a <strong>companion</strong> card or spend credits from an installed <strong>companion</strong> card, gain 1[Credits].\nLimit 1 <strong>console</strong> per player.",
			"code": "26070",
			"title": "Keiko",
		})

	NRCardDefs.defcard("Knobkierie", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+3[Memory Unit]\nUse the MU on Knobkierie only for <strong>virus</strong> programs.\nThe first time you make a successful run each turn, you may place 1 virus counter on an installed <strong>virus</strong> program.\nLimit 1 <strong>console</strong> per player.",
			"code": "21062",
			"title": "Knobkierie",
		})

	NRCardDefs.defcard("Lemuria Codecracker", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[Click], 1[Credits]: Expose 1 card. Use this ability only if you have made a successful run on HQ this turn.",
			"code": "01023",
			"title": "Lemuria Codecracker",
		})

	NRCardDefs.defcard("LilyPAD", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nThe first time each turn you install a program, you may draw 1 card.\nLimit 1 <strong>console</strong> per player.",
			"code": "34023",
			"title": "LilyPAD",
		})

	NRCardDefs.defcard("LLDS Memory Diamond", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "+1[Memory Unit], +1[link]\nYour maximum hand size is increased by 1.",
			"code": "13015",
			"title": "LLDS Memory Diamond",
		})

	NRCardDefs.defcard("LLDS Processor", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "Whenever you install an <strong>icebreaker</strong>, that <strong>icebreaker</strong> has +1 strength until the end of the turn.",
			"code": "04066",
			"title": "LLDS Processor",
		})

	NRCardDefs.defcard("Lockpick", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Chip - Stealth",
			"subtypes": ["Chip", "Stealth"],
			"text": "1[recurring-credit]\nUse this credit to pay for using <strong>decoders</strong>.",
			"code": "04006",
			"title": "Lockpick",
		})

	NRCardDefs.defcard("Logos", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nYour maximum hand size is increased by 1.\nWhenever the Corp scores an agenda, you may search your stack for a card and add it to your grip. Shuffle your stack.\nLimit 1 <strong>console</strong> per player.",
			"code": "05037",
			"title": "Logos",
		})

	NRCardDefs.defcard("Lucky Charm", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "[interrupt] → <strong>Remove this hardware from the game:</strong> Prevent a Corp card ability from ending the run. Use this ability only if you made a successful run on HQ this turn.",
			"code": "26014",
			"title": "Lucky Charm",
		})

	NRCardDefs.defcard("Mâché", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"text": "The first time you trash an accessed card each turn, you may place power counters on Mâché equal to that card's trash cost.\n<strong>3 hosted power counters</strong>: Draw 1 card.",
			"code": "22018",
			"title": "Mâché",
		})

	NRCardDefs.defcard("Madani", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "[Click]<strong>:</strong> Host any number of programs from your grip faceup on this hardware. <em>(They are not installed.)</em>\nOnce per turn → <strong>0[Credits]:</strong> Install 1 hosted program <em>(paying its install cost)</em>.\nLimit 1 <strong>console</strong> per player.",
			"code": "35028",
			"title": "Madani",
		})

	NRCardDefs.defcard("Maglectric Rapid (748 Mod)", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "Whenever you make a successful run on HQ, you may trash this hardware to derez 1 installed Corp card.",
			"code": "35019",
			"title": "Maglectric Rapid (748 Mod)",
		})

	NRCardDefs.defcard("Marrow", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console - Cybernetic",
			"subtypes": ["Console", "Cybernetic"],
			"text": "+1[Memory Unit]\nYou get +3 maximum hand size.\nWhen you install this hardware, suffer 1 core damage.\nWhenever the Corp scores an agenda, sabotage 1. <em>(The Corp trashes 1 card of their choice from HQ or the top of R&D.)</em>\nLimit 1 <strong>console</strong> per player.",
			"code": "33006",
			"title": "Marrow",
		})

	NRCardDefs.defcard("Masterwork (v37)", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nThe first time each turn you install a piece of hardware, draw 1 card.\nWhenever a run begins, you may install 1 piece of hardware from your grip, paying 1[Credits] more.\nLimit 1 <strong>console</strong> per player.",
			"code": "26015",
			"title": "Masterwork (v37)",
		})

	NRCardDefs.defcard("Māui", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nX[recurring-credit]\nUse these credits during runs on HQ. X is the number of pieces of ice protecting HQ.\nLimit 1 <strong>console</strong> per player.",
			"code": "12063",
			"title": "Māui",
		})

	NRCardDefs.defcard("Maw", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 6,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nThe first time each turn you access a card not in Archives and do not steal or trash it, the Corp must trash 1 card from HQ at random.\nLimit 1 <strong>console</strong> per player.",
			"code": "12002",
			"title": "Maw",
		})

	NRCardDefs.defcard("Maya", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nOnce per turn → When you finish accessing a card in R&D, you may add that card to the bottom of R&D. If you do, take 1 tag.\nLimit 1 <strong>console</strong> per player.",
			"code": "10007",
			"title": "Maya",
		})

	NRCardDefs.defcard("MemStrips", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+3[Memory Unit]\nUse the MU on MemStrips only for <strong>virus</strong> programs.",
			"code": "07046",
			"title": "MemStrips",
		})

	NRCardDefs.defcard("Methuselah", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console - Stealth",
			"subtypes": ["Console", "Stealth"],
			"text": "+1[Memory Unit]\nWhenever a run begins, you may trash 1 piece of hardware from your grip to place 2[Credits] on this hardware.\nYou can spend hosted credits during runs.\nLimit 1 <strong>console</strong> per player.",
			"code": "36020",
			"title": "Methuselah",
		})

	NRCardDefs.defcard("Mind's Eye", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever you make a successful run on R&D, you may place 1 power counter on this hardware.\n<strong>[Click]</strong>, <strong>3 hosted power counters:</strong> Breach R&D. You cannot access cards in the root of R&D during this breach.\nLimit 1 <strong>console</strong> per player.",
			"code": "22017",
			"title": "Mind's Eye",
		})

	NRCardDefs.defcard("Mirror", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nWhenever you make a successful run on R&D, you may replace 1 spent recurring credit.\nLimit 1 <strong>console</strong> per player.",
			"code": "11005",
			"title": "Mirror",
		})

	NRCardDefs.defcard("Monolith", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 18,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+3[Memory Unit]\nWhen you install this hardware, install up to 3 programs from your grip, paying 4[Credits] less for each.\n[interrupt] → <strong>Trash 1 program from your grip:</strong> Prevent 1 core damage or 1 net damage.\nLimit 1 <strong>console</strong> per player.",
			"code": "03036",
			"title": "Monolith",
		})

	NRCardDefs.defcard("Mu Safecracker", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"text": "Spend credits only from <strong>stealth</strong> cards to use this hardware.\nWhenever you make a successful run on HQ, you may pay 1[Credits] to access 1 additional card when you breach HQ.\nWhenever you make a successful run on R&D, you may pay 2[Credits] to access 1 additional card when you breach R&D.",
			"code": "26076",
			"title": "Mu Safecracker",
		})

	NRCardDefs.defcard("Muresh Bodysuit", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Gear",
			"subtypes": ["Gear"],
			"text": "[interrupt] → The first time each turn you would suffer meat damage, prevent 1 meat damage.",
			"code": "02044",
			"title": "Muresh Bodysuit",
		})

	NRCardDefs.defcard("Net-Ready Eyes", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install Net-Ready Eyes, suffer 2 meat damage.\nWhenever you initiate a run, choose an <strong>icebreaker</strong>. That <strong>icebreaker</strong> has +1 strength for the remainder of the run.",
			"code": "08047",
			"title": "Net-Ready Eyes",
		})

	NRCardDefs.defcard("NetChip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Consumer-grade - Chip",
			"subtypes": ["Consumer-grade", "Chip"],
			"text": "NetChip can host a program with a memory cost less than or equal to the number of copies of NetChip installed. The memory cost of the hosted program does not count against your memory limit.\nLimit 6 per deck.",
			"code": "10024",
			"title": "NetChip",
		})

	NRCardDefs.defcard("Obelus", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nYou get +1 maximum hand size for each tag you have.\nThe first time each turn a successful run on HQ or R&D ends, draw 1 card for each time you accessed a card during that run.\nLimit 1 <strong>console</strong> per player.",
			"code": "11041",
			"title": "Obelus",
		})

	NRCardDefs.defcard("Omni-drive", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Gear",
			"subtypes": ["Gear"],
			"text": "Omni-drive can host a single program of 1[Memory Unit] or less. The memory cost of the hosted program does not count against your memory limit.\n1[recurring-credit]\nUse this credit to pay for using the hosted program.",
			"code": "03039",
			"title": "Omni-drive",
		})

	NRCardDefs.defcard("PAN-Weave", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, suffer 1 meat damage.\nThe first time each turn you make a successful run on HQ, the Corp loses 1[Credits]. If they do, gain 1[Credits].",
			"code": "33014",
			"title": "PAN-Weave",
		})

	NRCardDefs.defcard("Pantograph", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever an agenda is scored or stolen, gain 1[Credits]. Then, you may install 1 card from your grip.\nLimit 1 <strong>console</strong> per player.",
			"code": "30023",
			"title": "Pantograph",
		})

	NRCardDefs.defcard("Paragon", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nThe first time you make a successful run each turn, you may gain 1[Credits] and look at the top card of your stack. If you do, you may add that card to the bottom of your stack.\nLimit 1 <strong>console</strong> per player.",
			"code": "25032",
			"title": "Paragon",
		})

	NRCardDefs.defcard("Patchwork", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\n[interrupt], once per turn → When you would play or install a card, you may trash 1 card from your grip. If you do, instead play or install that card paying 2[Credits] less.\nLimit 1 <strong>console</strong> per player.",
			"code": "25009",
			"title": "Patchwork",
		})

	NRCardDefs.defcard("Pennyshaver", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever you make a successful run, place 1[Credits] on this hardware.\n[Click]<strong>:</strong> Place 1[Credits] on this hardware, then take all credits from it.\nLimit 1 <strong>console</strong> per player.",
			"code": "30014",
			"title": "Pennyshaver",
		})

	NRCardDefs.defcard("Plascrete Carapace", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Gear",
			"subtypes": ["Gear"],
			"text": "When you install this hardware, load 4 power counters onto it. When it is empty, trash it.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent 1 meat damage.",
			"code": "02009",
			"title": "Plascrete Carapace",
		})

	NRCardDefs.defcard("Poison Vial", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "When you install this hardware, load 3 power counters onto it. When it is empty, trash it.\n<strong>Hosted power counter:</strong> Break up to 2 subroutines. Use this ability only if you have already broken a subroutine during this encounter.",
			"code": "33077",
			"title": "Poison Vial",
		})

	NRCardDefs.defcard("Polyhistor", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit], +1[link]\nThe first time each turn you pass all of the ice protecting HQ, you may draw 1 card to force the Corp to draw 1 card.\nLimit 1 <strong>console</strong> per player.",
			"code": "13005",
			"title": "Polyhistor",
		})

	NRCardDefs.defcard("Prepaid VoicePAD", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Gear",
			"subtypes": ["Gear"],
			"text": "1[recurring-credit] <em>(When you install this card and before your turn begins, refill to 1 hosted credit.)</em>\nYou can spend hosted credits to play events.",
			"code": "31038",
			"title": "Prepaid VoicePAD",
		})

	NRCardDefs.defcard("Prognostic Q-Loop", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "The first time each turn a run begins, you may look at the top 2 cards of your stack.\nOnce per turn → <strong>1[Credits]:</strong> Reveal the top card of your stack. If that card is a program or piece of hardware, you may install it.",
			"code": "26077",
			"title": "Prognostic Q-Loop",
		})

	NRCardDefs.defcard("Public Terminal", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "1[recurring-credit]\nUse this credit to play <strong>run</strong> events.",
			"code": "05038",
			"title": "Public Terminal",
		})

	NRCardDefs.defcard("Q-Coherence Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+1[Memory Unit]\nWhen an installed program is trashed, trash this hardware.",
			"code": "05052",
			"title": "Q-Coherence Chip",
		})

	NRCardDefs.defcard("Qianju PT", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Vehicle",
			"subtypes": ["Vehicle"],
			"text": "When your turn begins, you may lose [Click]. If you do, the first time you would take tags from now until your next turn begins, prevent 1 tag.",
			"code": "07054",
			"title": "Qianju PT",
		})

	NRCardDefs.defcard("R&D Interface", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you breach R&D, access 1 additional card.",
			"code": "25050",
			"title": "R&D Interface",
		})

	NRCardDefs.defcard("Rabbit Hole", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Link",
			"subtypes": ["Link"],
			"text": "+1[link]\nWhen Rabbit Hole is installed, you may search your stack for another copy of Rabbit Hole and install it by paying its install cost. Shuffle your stack.",
			"code": "20046",
			"title": "Rabbit Hole",
		})

	NRCardDefs.defcard("Ramujan-reliant 550 BMI", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Consumer-grade",
			"subtypes": ["Consumer-grade"],
			"text": "[interrupt] → [Trash]<strong>:</strong> Prevent up to X core damage or net damage. Trash cards from the top of your stack equal to the amount of damage prevented. X is equal to the number of other installed copies of Ramujan-reliant 550 BMI plus 1.\nLimit 6 per deck.",
			"code": "10002",
			"title": "Ramujan-reliant 550 BMI",
		})

	NRCardDefs.defcard("Recon Drone", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "[interrupt] → <strong>X[Credits]</strong>, [Trash]<strong>:</strong> Prevent X damage from a card you are accessing.",
			"code": "11103",
			"title": "Recon Drone",
		})

	NRCardDefs.defcard("Record Reconstructor", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Whenever you make a successful run on Archives, instead of breaching Archives, you may add 1 faceup card from Archives to the top of R&D.",
			"code": "04028",
			"title": "Record Reconstructor",
		})

	NRCardDefs.defcard("Reflection", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": " +1[Memory Unit] +1[link]\nWhenever you jack out, the Corp reveals 1 card from HQ at random.\nLimit 1 <strong>console</strong> per player.",
			"code": "10041",
			"title": "Reflection",
		})

	NRCardDefs.defcard("Replicator", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you install a piece of hardware (including Replicator), you may search your stack for another copy of that hardware, reveal it, and add it your grip. Shuffle your stack.",
			"code": "02088",
			"title": "Replicator",
		})

	NRCardDefs.defcard("Respirocytes", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, suffer 1 meat damage.\nThe first time each turn you have no cards in your grip, draw 1 card and place 1 power counter on this hardware.\nWhen this hardware has 3 or more hosted power counters, trash it.",
			"code": "12102",
			"title": "Respirocytes",
		})

	NRCardDefs.defcard("Rotary", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever you breach HQ or R&D, you may take 1 tag to access 1 additional card.\n[Click], <strong>2[Credits]:</strong> Trash this hardware. Only the Corp can use this ability, and only if the Runner is tagged.\nLimit 1 <strong>console</strong> per player.",
			"code": "36014",
			"title": "Rotary",
		})

	NRCardDefs.defcard("Rubicon Switch", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"text": "Once per turn → [Click], <strong>X[Credits]:</strong> Derez 1 piece of ice with a printed rez cost of X[Credits] that was rezzed this turn.",
			"code": "12043",
			"title": "Rubicon Switch",
		})

	NRCardDefs.defcard("Security Chip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "[Trash]: Choose an <strong>icebreaker</strong> (or any number of <strong>cloud icebreakers</strong>). Each chosen <strong>icebreaker</strong> has +1 strength for each [link] you have for the remainder of this run. Use this ability only during a run.",
			"code": "09046",
			"title": "Security Chip",
		})

	NRCardDefs.defcard("Security Nexus", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 8,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit], +1[link]\nOnce per turn → When you encounter a piece of ice, you may have the Corp trace[5]. If successful, they give you 1 tag and end the run. If unsuccesful, bypass the encountered ice.\nLimit 1 <strong>console</strong> per player.",
			"code": "09047",
			"title": "Security Nexus",
		})

	NRCardDefs.defcard("Severnius Stim Implant", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "<strong>[Click]:</strong> Trash 2 or more cards from your grip. Run HQ or R&D. Whenever you breach that server during this run, access 1 additional card for every 2 cards you trashed.",
			"code": "12021",
			"title": "Severnius Stim Implant",
		})

	NRCardDefs.defcard("Şifr", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nOnce per turn → When you encounter a piece of ice, you may get –1 maximum hand size until your next turn begins. If you do, the strength of that ice is lowered to 0 for the remainder of the encounter.\nLimit 1 <strong>console</strong> per player.",
			"code": "11101",
			"title": "Şifr",
		})

	NRCardDefs.defcard("Silencer", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Chip - Stealth",
			"subtypes": ["Chip", "Stealth"],
			"text": "1[recurring-credit]\nUse this credit to pay for using <strong>killers</strong>.",
			"code": "04104",
			"title": "Silencer",
		})

	NRCardDefs.defcard("Simulchip", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "As an additional cost to use this hardware, trash 1 installed program. Ignore this cost if an installed program has already been trashed this turn.\n<strong>[Trash]:</strong> Install 1 program from your heap, paying 3[Credits] less.",
			"code": "26085",
			"title": "Simulchip",
		})

	NRCardDefs.defcard("Skulljack", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, suffer 1 core damage.\nThe trash cost of each Corp card is lowered by 1.",
			"code": "08042",
			"title": "Skulljack",
		})

	NRCardDefs.defcard("Solidarity Badge", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "The first time each turn you trash a Corp card, place 1 power counter on this hardware.\nWhen your turn begins, you may remove 1 hosted power counter to draw 1 card or remove 1 tag.",
			"code": "34003",
			"title": "Solidarity Badge",
		})

	NRCardDefs.defcard("Spinal Modem", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit], 2[recurring-credit]\nYou can spend hosted credits to use <strong>icebreakers</strong>.\nWhenever there is a successful trace during a run, suffer 1 core damage.\nLimit 1 <strong>console</strong> per player.",
			"code": "20007",
			"title": "Spinal Modem",
		})

	NRCardDefs.defcard("Sports Hopper", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Vehicle",
			"subtypes": ["Vehicle"],
			"text": " +1[link]\n[Trash]: Draw 3 cards.",
			"code": "10064",
			"title": "Sports Hopper",
		})

	NRCardDefs.defcard("Spy Camera", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Consumer-grade",
			"subtypes": ["Consumer-grade"],
			"text": "[Click]: Look at the top X cards of your stack and arrange them in any order. X is the number of copies of Spy Camera installed.\n[Trash]: Look at the top card of R&D.\nLimit 6 per deck.",
			"code": "10042",
			"title": "Spy Camera",
		})

	NRCardDefs.defcard("Supercorridor", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nYou get +1 maximum hand size.\nWhen your turn ends, if you and the Corp have the same number of credits, you may gain 2[Credits].\nLimit 1 <strong>console</strong> per player.",
			"code": "26023",
			"title": "Supercorridor",
		})

	NRCardDefs.defcard("Swift", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console - Vehicle",
			"subtypes": ["Console", "Vehicle"],
			"text": "+1[Memory Unit]\nThe first time each turn you play a <strong>run</strong> event, gain [Click].\nLimit 1 <strong>console</strong> per player.",
			"code": "27002",
			"title": "Swift",
		})

	NRCardDefs.defcard("T400 Memory Diamond", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Chip",
			"subtypes": ["Chip"],
			"text": "+1[Memory Unit]\nYou get +1 maximum hand size.",
			"code": "30031",
			"title": "T400 Memory Diamond",
		})

	NRCardDefs.defcard("The Gauntlet", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nWhenever you breach HQ during a run, access 1 additional card for each piece of ice protecting HQ that you fully broke during that run.\nLimit 1 <strong>console</strong> per player.",
			"code": "11063",
			"title": "The Gauntlet",
		})

	NRCardDefs.defcard("The Personal Touch", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Install The Personal Touch only on an <strong>icebreaker.</strong>\nHost <strong>icebreaker</strong> has +1 strength.",
			"code": "20047",
			"title": "The Personal Touch",
		})

	NRCardDefs.defcard("The Toolbox", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 9,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit] +2[link]\n2[recurring-credit]\nUse these credits to pay for using <strong>icebreakers</strong>.\nLimit 1 <strong>console</strong> per player.",
			"code": "01041",
			"title": "The Toolbox",
		})

	NRCardDefs.defcard("The Tungsten Tailor", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": true,
			"text": "Each piece of ice gets −1 strength.\nThe first time each turn you break a subroutine on a piece of ice with 0 or less strength, gain 1[Credits].",
			"code": "36003",
			"title": "The Tungsten Tailor",
		})

	NRCardDefs.defcard("The Wizard's Chest", {
			"title": "The Wizard's Chest",
		})

	NRCardDefs.defcard("Time Bomb", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "Install only if you made a successful run on a central server this turn. When you install this hardware, place 1 power counter on it.\nWhen your turn begins, if there are 3 or more hosted power counters, trash this hardware and sabotage 3. <em>(The Corp trashes 3 cards of their choice from HQ and/or the top of R&D.)</em> Otherwise, place 1 power counter on this hardware.",
			"code": "33069",
			"title": "Time Bomb",
		})

	NRCardDefs.defcard("Titanium Ribs", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install Titanium Ribs, suffer 2 meat damage.\nYou choose the card(s) from your grip to trash whenever you take damage (including the damage taken by installing Titanium Ribs).",
			"code": "08045",
			"title": "Titanium Ribs",
		})

	NRCardDefs.defcard("Top Hat", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Whenever you make a successful run on R&D, instead of breaching R&D, you may choose 1 of the top 5 cards in R&D and access it.",
			"code": "11067",
			"title": "Top Hat",
		})

	NRCardDefs.defcard("Touchstone", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Stealth",
			"subtypes": ["Stealth"],
			"text": "The first time each turn you play an event, place 1[Credits] on this hardware.\nYou can spend hosted credits during runs.",
			"code": "36021",
			"title": "Touchstone",
		})

	NRCardDefs.defcard("Turntable", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhenever you steal an agenda, you may swap that agenda with an agenda in the Corp's score area.\nLimit 1 <strong>console</strong> per player.",
			"code": "08043",
			"title": "Turntable",
		})

	NRCardDefs.defcard("Ubax", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhen your turn begins, draw 1 card.\nLimit 1 <strong>console</strong> per player.",
			"code": "13016",
			"title": "Ubax",
		})

	NRCardDefs.defcard("Unregistered S&W '35", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "Use this hardware only if you have made a successful run on HQ this turn.\n<strong>[Click][Click]:</strong> Trash 1 rezzed <strong>bioroid</strong>, <strong>clone</strong>, <strong>executive</strong>, or <strong>sysop</strong> in the root of a remote server.",
			"code": "05039",
			"title": "Unregistered S&W '35",
		})

	NRCardDefs.defcard("Vigil", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhen your turn begins, if the Corp has cards in HQ equal to their maximum hand size, draw 1 card.\nLimit 1 <strong>console</strong> per player.",
			"code": "07047",
			"title": "Vigil",
		})

	NRCardDefs.defcard("Virtuoso", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 4,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+1[Memory Unit]\nWhen your turn begins, identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nThe first time each turn you make a successful run on your mark, if that server is HQ, access 1 additional card when you breach HQ. Otherwise, breach HQ when the run ends.\nLimit 1 <strong>console</strong> per player.",
			"code": "33015",
			"title": "Virtuoso",
		})

	NRCardDefs.defcard("WAKE Implant v2A-JRJ", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Cybernetic",
			"subtypes": ["Cybernetic"],
			"text": "When you install this hardware, suffer 1 meat damage.\nWhenever you make a successful run on HQ, place 1 power counter on this hardware.\nWhenever you breach R&D, you may remove up to 3 hosted power counters to access that many additional cards.",
			"code": "33078",
			"title": "WAKE Implant v2A-JRJ",
		})

	NRCardDefs.defcard("Window", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[Click]: Draw 1 card from the bottom of your stack.",
			"code": "05040",
			"title": "Window",
		})

	NRCardDefs.defcard("Zamba", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": true,
			"keywords": "Console",
			"subtypes": ["Console"],
			"text": "+2[Memory Unit]\nWhenever a Corp card is exposed, you may gain 1[Credits].\nLimit 1 <strong>console</strong> per player.",
			"code": "21003",
			"title": "Zamba",
		})

	NRCardDefs.defcard("Zenit Chip JZ-2MJ", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Cybernetic - Chip",
			"subtypes": ["Cybernetic", "Chip"],
			"text": "When you install this hardware, suffer 1 core damage.\nThe first time each turn you make a successful run on a central server, draw 1 card.",
			"code": "33079",
			"title": "Zenit Chip JZ-2MJ",
		})

	NRCardDefs.defcard("Zer0", {
			"type": "Hardware",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": true,
			"text": "Once per turn → [Click], <strong>suffer 1 net damage:</strong> Gain 1[Credits] and draw 2 cards.",
			"code": "21101",
			"title": "Zer0",
		})
