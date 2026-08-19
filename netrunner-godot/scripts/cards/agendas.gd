class_name NRCardsAgendas
extends RefCounted

## Printed card data from game.cards.agendas (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("15 Minutes", {
			"title": "15 Minutes",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"text": "[click]: Shuffle 15 Minutes into R&D. The Corp can trigger this ability while 15 Minutes is in the Runner's score area.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Above the Law", {
			"title": "Above the Law",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, you may trash 1 installed resource.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Accelerated Beta Test", {
			"title": "Accelerated Beta Test",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score Accelerated Beta Test, you may look at the top 3 cards of R&D. If any of those cards are ice, you may install and rez them, ignoring all costs. Trash the rest of the cards you looked at."
		})

	NRCardDefs.defcard("Advanced Concept Hopper", {
			"title": "Advanced Concept Hopper",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "The first time the Runner initiates a run each turn, you may draw 1 card or gain 1[credit]."
		})

	NRCardDefs.defcard("Aggressive Trendsetting", {
			"title": "Aggressive Trendsetting",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "The first time the Runner trashes an installed Corp card during each of their turns, they may spend [click]. If they do not, you get +1 allotted [click] for your next turn."
		})

	NRCardDefs.defcard("Ancestral Imager", {
			"title": "Ancestral Imager",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "Whenever the Runner jacks out, do 1 net damage."
		})

	NRCardDefs.defcard("AR-Enhanced Security", {
			"title": "AR-Enhanced Security",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "The first time each turn the Runner trashes a Corp card, give them 1 tag."
		})

	NRCardDefs.defcard("Architect Deployment Test", {
			"title": "Architect Deployment Test",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, look at the top 5 cards of R&D. You may install and rez 1 of those cards, ignoring all costs."
		})

	NRCardDefs.defcard("Armed Intimidation", {
			"title": "Armed Intimidation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Armed Intimidation, the Runner must either suffer 5 meat damage or take 2 tags."
		})

	NRCardDefs.defcard("Armored Servers", {
			"title": "Armored Servers",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> For the remainder of this run, the Runner must trash 1 card from the grip as an additional cost to jack out or break a subroutine. Use this ability only during a run."
		})

	NRCardDefs.defcard("Artificial Cryptocrash", {
			"title": "Artificial Cryptocrash",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, the Runner loses 7[credit]."
		})

	NRCardDefs.defcard("AstroScript Pilot Program", {
			"title": "AstroScript Pilot Program",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> Place 1 advancement counter on an installed card you can advance."
		})

	NRCardDefs.defcard("Award Bait", {
			"title": "Award Bait",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Sensie",
			"subtypes": ["Sensie"],
			"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda, you may place up to 2 advancement counters on 1 installed card you can advance."
		})

	NRCardDefs.defcard("Azef Protocol", {
			"title": "Azef Protocol",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "As an additional cost to score this agenda, trash 1 of your other installed cards.\nWhen you score this agenda, do 2 meat damage."
		})

	NRCardDefs.defcard("Bacterial Programming", {
			"title": "Bacterial Programming",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When Bacterial Programming is scored or stolen, you may look at the top 7 cards of R&D, add any number of them to HQ, trash any number of them, and arrange the rest in any order."
		})

	NRCardDefs.defcard("The Basalt Spire", {
			"title": "The Basalt Spire",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"text": "When the Runner steals this agenda, you may add 1 card from Archives to HQ.\nWhen you score this agenda, place 2 agenda counters on it.\nOnce per turn → <strong> Hosted agenda counter</strong>, <strong>trash the top card of R&D:</strong> Add 1 card from Archives to HQ."
		})

	NRCardDefs.defcard("Bellona", {
			"title": "Bellona",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "As an additional cost to steal this agenda, the Runner must pay 5[credit].\nWhen you score this agenda, gain 5[credit]."
		})

	NRCardDefs.defcard("Better Citizen Program", {
			"title": "Better Citizen Program",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "The first time the Runner plays a <strong>run</strong> event or installs an <strong>icebreaker</strong> program each turn, you may give the Runner 1 tag."
		})

	NRCardDefs.defcard("Bifrost Array", {
			"title": "Bifrost Array",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score Bifrost Array, you may trigger the \"when scored\" ability of another agenda that is not a copy of Bifrost Array in your score area."
		})

	NRCardDefs.defcard("Blood in the Water", {
			"title": "Blood in the Water",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "X is equal to the number of cards in the Runner's grip."
		})

	NRCardDefs.defcard("Brain Rewiring", {
			"title": "Brain Rewiring",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, you may spend any number of credits. If you do, the Runner adds that many cards from the grip to the bottom of the stack at random, then draws 1 card."
		})

	NRCardDefs.defcard("Braintrust", {
			"title": "Braintrust",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score Braintrust, place 1 agenda counter on it for every 2 advancement tokens on it over 3.\nThe rez cost of all ice is lowered by 1 for each agenda counter on Braintrust."
		})

	NRCardDefs.defcard("Breaking News", {
			"title": "Breaking News",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"text": "When you score this agenda, give the Runner 2 tags.\nWhen a discard phase ends, if you scored this agenda this turn, the Runner removes 2 tags."
		})

	NRCardDefs.defcard("Broad Daylight", {
			"title": "Broad Daylight",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security - Liability",
			"subtypes": ["Security", "Liability"],
			"text": "When you score this agenda, you may take 1 bad publicity. Place 1 agenda counter on this agenda for each bad publicity you have.\nOnce per turn → [click], <strong>hosted agenda counter:</strong> Do 2 meat damage."
		})

	NRCardDefs.defcard("CFC Excavation Contract", {
			"title": "CFC Excavation Contract",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"text": "When you score CFC Excavation Contract, gain 2[credit] for each rezzed <strong>bioroid</strong>."
		})

	NRCardDefs.defcard("Character Assassination", {
			"title": "Character Assassination",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Character Assassination, trash 1 resource (cannot be prevented)."
		})

	NRCardDefs.defcard("Chronos Project", {
			"title": "Chronos Project",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, the Runner removes all cards in the heap from the game."
		})

	NRCardDefs.defcard("City Works Project", {
			"title": "City Works Project",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Public",
			"subtypes": ["Public"],
			"text": "Install City Works Project faceup.\nWhen the Runner accesses City Works Project while it is installed, do 2 meat damage and 1 additional meat damage for each advancement token on it."
		})

	NRCardDefs.defcard("Clone Retirement", {
			"title": "Clone Retirement",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative - Liability",
			"subtypes": ["Initiative", "Liability"],
			"text": "When you score this agenda, you may remove 1 bad publicity.\nWhen the Runner steals this agenda, take 1 bad publicity."
		})

	NRCardDefs.defcard("Corporate Oversight A", {
			"title": "Corporate Oversight A",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 0,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score Corporate Oversight, you may search R&D for a piece of ice. Install and rez it protecting a remote server, ignoring all costs. Shuffle R&D.\nIf you win a game with Corporate Oversight in your score area, destroy it."
		})

	NRCardDefs.defcard("Corporate Oversight B", {
			"title": "Corporate Oversight B",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 0,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score Corporate Oversight, you may search R&D for a piece of ice. Install and rez it protecting a central server, ignoring all costs. Shuffle R&D.\nIf you win a game with Corporate Oversight in your score area, destroy it."
		})

	NRCardDefs.defcard("Corporate Sales Team", {
			"title": "Corporate Sales Team",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score Corporate Sales Team, place 10[credit] on it.\nWhen each player's turn begins, take 1[credit] from Corporate Sales Team."
		})

	NRCardDefs.defcard("Corporate War", {
			"title": "Corporate War",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "If you have at least 7[credit] when you score Corporate War, gain 7[credit]; otherwise, lose all credits in your credit pool."
		})

	NRCardDefs.defcard("Crisis Management", {
			"title": "Crisis Management",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "If the Runner is tagged, Crisis Management gains \"When your turn begins, do 1 meat damage.\""
		})

	NRCardDefs.defcard("Cyberdex Sandbox", {
			"title": "Cyberdex Sandbox",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "The first time each turn you purge virus counters, gain 4[credit].\nWhen you score this agenda, you may purge virus counters."
		})

	NRCardDefs.defcard("Dedicated Neural Net", {
			"title": "Dedicated Neural Net",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative - Psi",
			"subtypes": ["Initiative", "Psi"],
			"text": "The first time there is a successful run on HQ each turn, you and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, you choose which cards the Runner accesses from HQ for the remainder of this run."
		})

	NRCardDefs.defcard("Degree Mill", {
			"title": "Degree Mill",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "As an additional cost to steal Degree Mill, the Runner must shuffle 2 installed Runner cards into the stack."
		})

	NRCardDefs.defcard("Director Haas' Pet Project", {
			"title": "Director Haas' Pet Project",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, you may create a new remote server by installing up to 3 cards from HQ and/or Archives in the root of and/or protecting that server, ignoring all install costs.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Divested Trust", {
			"title": "Divested Trust",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"text": "Whenever the Runner steals another agenda, you may forfeit this agenda to gain 5[credit] and add the stolen agenda to HQ."
		})

	NRCardDefs.defcard("Domestic Sleepers", {
			"title": "Domestic Sleepers",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 0,
			"factioncost": 0,
			"text": "[click],[click],[click]: Place 1 agenda counter on Domestic Sleepers.\nDomestic Sleepers is worth 1 agenda point while it has at least 1 agenda counter on it."
		})

	NRCardDefs.defcard("Élivágar Bifurcation", {
			"title": "Élivágar Bifurcation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, you may derez 1 installed card."
		})

	NRCardDefs.defcard("Eden Fragment", {
			"title": "Eden Fragment",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Source",
			"subtypes": ["Source"],
			"text": "Ignore the install cost of the first piece of ice you install each turn.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Efficiency Committee", {
			"title": "Efficiency Committee",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Place 3 agenda counters on Efficiency Committee when you score it.\n[click], <strong>hosted agenda counter:</strong> Gain [click][click]. You cannot advance cards for the remainder of this turn."
		})

	NRCardDefs.defcard("Elective Upgrade", {
			"title": "Elective Upgrade",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, place 2 agenda counters on it.\nOnce per turn → [click], <strong>hosted agenda counter:</strong> Gain [click][click]."
		})

	NRCardDefs.defcard("Embedded Reporting", {
			"title": "Embedded Reporting",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Dividends 2 <em>(When you score this agenda, place 2 agenda counters on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to search R&D for 1 operation and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that operation to the top of R&D."
		})

	NRCardDefs.defcard("Eminent Domain", {
			"title": "Eminent Domain",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion - Expendable",
			"subtypes": ["Expansion", "Expendable"],
			"text": "[click], <strong>1[credit]</strong>, <strong>reveal and trash this agenda from HQ:</strong> Install and rez 1 card from HQ, paying a total of 5[credit] less.\nWhen you score this agenda, you may search R&D for 1 card. <em>(Shuffle R&D after searching it.)</em> Install and rez that card, ignoring all costs."
		})

	NRCardDefs.defcard("Encrypted Portals", {
			"title": "Encrypted Portals",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "All <strong>code gate</strong> ice have +1 strength.\nWhen you score Encrypted Portals, gain 1[credit] for each rezzed <strong>code gate</strong>."
		})

	NRCardDefs.defcard("Escalate Vitriol", {
			"title": "Escalate Vitriol",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Once per turn → [click]<strong>:</strong> Gain 1[credit] for each tag the Runner has."
		})

	NRCardDefs.defcard("Executive Retreat", {
			"title": "Executive Retreat",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"text": "When you score Executive Retreat, place 1 agenda counter on it and shuffle HQ into R&D.\n[click], <strong>hosted agenda counter:</strong> Draw 5 cards."
		})

	NRCardDefs.defcard("Explode-a-palooza", {
			"title": "Explode-a-palooza",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Sensie",
			"subtypes": ["Sensie"],
			"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda, you may gain 5[credit]."
		})

	NRCardDefs.defcard("Evidence Collection", {
			"title": "Evidence Collection",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you win a game with Evidence Collection in your score area, reveal set 2."
		})

	NRCardDefs.defcard("Evidence Collection 2", {
			"title": "Evidence Collection 2",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you win a game with Evidence Collection in your score area, reveal set 5."
		})

	NRCardDefs.defcard("Evidence Collection 3", {
			"title": "Evidence Collection 3",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you win a game with Evidence Collection in your score area, reveal set 8."
		})

	NRCardDefs.defcard("Evidence Collection 4", {
			"title": "Evidence Collection 4",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "Evidence Collection is worth 1 fewer agenda point while in the Runner's score area."
		})

	NRCardDefs.defcard("False Lead", {
			"title": "False Lead",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "<strong>Forfeit this agenda:</strong> If the Runner has 2 or more [click] remaining, they lose [click][click]."
		})

	NRCardDefs.defcard("Fetal AI", {
			"title": "Fetal AI",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda anywhere except in Archives, do 2 net damage.\nAs an additional cost to steal this agenda, the Runner must pay 2[credit]."
		})

	NRCardDefs.defcard("Firmware Updates", {
			"title": "Firmware Updates",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, place 3 agenda counters on it.\nOnce per turn → <strong>Hosted agenda counter:</strong> Place 1 advancement counter on an installed piece of ice you can advance."
		})

	NRCardDefs.defcard("Flower Sermon", {
			"title": "Flower Sermon",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"text": "When you score this agenda, place 5 agenda counters on it.\nOnce per turn → <strong>Hosted agenda counter:</strong> Reveal the top card of R&D. Draw 2 cards. Add 1 card from HQ to the top of R&D."
		})

	NRCardDefs.defcard("Fly on the Wall", {
			"title": "Fly on the Wall",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score Fly on the Wall, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Freedom of Information", {
			"title": "Freedom of Information",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "This agenda gets -1 advancement requirement for each tag the Runner has."
		})

	NRCardDefs.defcard("Fujii Asset Retrieval", {
			"title": "Fujii Asset Retrieval",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Ambush - Security",
			"subtypes": ["Ambush", "Security"],
			"text": "When this agenda is scored or stolen, do 2 net damage."
		})

	NRCardDefs.defcard("Genetic Resequencing", {
			"title": "Genetic Resequencing",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score Genetic Resequencing, you may place 1 agenda counter on an agenda in your score area."
		})

	NRCardDefs.defcard("Geothermal Fracking", {
			"title": "Geothermal Fracking",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion - Liability",
			"subtypes": ["Expansion", "Liability"],
			"text": "When you score this agenda, place 2 agenda counters on it.\n[click], <strong>hosted agenda counter:</strong> Gain 7[credit] and take 1 bad publicity."
		})

	NRCardDefs.defcard("Gila Hands Arcology", {
			"title": "Gila Hands Arcology",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "[click], [click]: Gain 3[credit]."
		})

	NRCardDefs.defcard("Glenn Station", {
			"title": "Glenn Station",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "Glenn Station can host a single card.\n[click]: Host a card from HQ facedown on Glenn Station.\n[click]: Add a card on Glenn Station to HQ."
		})

	NRCardDefs.defcard("Global Food Initiative", {
			"title": "Global Food Initiative",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 1,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Global Food Initiative is worth 1 fewer agenda point while in the Runner's score area."
		})

	NRCardDefs.defcard("Government Contracts", {
			"title": "Government Contracts",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"text": "[click], [click]: Gain 4[credit]."
		})

	NRCardDefs.defcard("Government Takeover", {
			"title": "Government Takeover",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"advancementcost": 9,
			"agendapoints": 6,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "[click]: Gain 3[credit].\nLimit 1 Government Takeover per deck."
		})

	NRCardDefs.defcard("Graft", {
			"title": "Graft",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"text": "When you score Graft, you may search your deck for up to 3 cards, reveal them, and add them to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Greenmail", {
			"title": "Greenmail",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, gain 2[credit].\nWhen you forfeit this agenda, gain 4[credit]."
		})

	NRCardDefs.defcard("Hades Fragment", {
			"title": "Hades Fragment",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Source",
			"subtypes": ["Source"],
			"text": "When your turn begins, you may add 1 card from Archives to the bottom of R&D.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Helium-3 Deposit", {
			"title": "Helium-3 Deposit",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"text": "When you score Helium-3 Deposit, place up to 2 power counters on a card with at least 1 power counter on it."
		})

	NRCardDefs.defcard("High-Risk Investment", {
			"title": "High-Risk Investment",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "Place 1 agenda counter on High-Risk Investment when you score it.\n[click], <strong>hosted agenda counter:</strong> Gain 1[credit] for each credit in the Runner's credit pool."
		})

	NRCardDefs.defcard("Hollywood Renovation", {
			"title": "Hollywood Renovation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative - Public",
			"subtypes": ["Initiative", "Public"],
			"text": "Install Hollywood Renovation faceup.\nWhenever you advance Hollywood Renovation, you may place 1 advancement token on another card that can be advanced (or 2 advancement tokens instead if there are 6 or more advancement tokens on Hollywood Renovation)."
		})

	NRCardDefs.defcard("Hostile Takeover", {
			"title": "Hostile Takeover",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion - Liability",
			"subtypes": ["Expansion", "Liability"],
			"text": "When you score this agenda, gain 7[credit] and take 1 bad publicity."
		})

	NRCardDefs.defcard("House of Knives", {
			"title": "House of Knives",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, place 3 agenda counters on it.\n<strong>Hosted agenda counter:</strong> Do 1 net damage. Use this ability only during a run and only once per run."
		})

	NRCardDefs.defcard("Hybrid Release", {
			"title": "Hybrid Release",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, you may install 1 facedown card from Archives."
		})

	NRCardDefs.defcard("Hyperloop Extension", {
			"title": "Hyperloop Extension",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When Hyperloop Extension is scored or stolen, the Corp gains 3[credit]."
		})

	NRCardDefs.defcard("Ikawah Project", {
			"title": "Ikawah Project",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "As an additional cost to steal Ikawah Project, the Runner must spend [click] and 2[credit]."
		})

	NRCardDefs.defcard("Illicit Sales", {
			"title": "Illicit Sales",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion - Liability",
			"subtypes": ["Expansion", "Liability"],
			"text": "When you score this agenda, you may take 1 bad publicity. Gain 3[credit] for each bad publicity you have."
		})

	NRCardDefs.defcard("Improved Protein Source", {
			"title": "Improved Protein Source",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When Improved Protein Source is scored or stolen, the Runner gains 4[credit]."
		})

	NRCardDefs.defcard("Improved Tracers", {
			"title": "Improved Tracers",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "All <strong>tracer</strong> ice have +1 strength.\nThe base trace strength of each subroutine is increased by 1."
		})

	NRCardDefs.defcard("Jumon", {
			"title": "Jumon",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 6,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When your turn ends, place 2 advancement counters on 1 card in the root of a remote server."
		})

	NRCardDefs.defcard("Kimberlite Field", {
			"title": "Kimberlite Field",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, you may trash 1 of your rezzed cards. If you do, trash 1 installed Runner card with a printed install cost equal to or less than the printed rez cost of the Corp card you trashed."
		})

	NRCardDefs.defcard("Kingmaking", {
			"title": "Kingmaking",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, draw up to 3 cards. You may add 1 agenda worth 1 or less agenda points from HQ to your score area."
		})

	NRCardDefs.defcard("Labyrinthine Servers", {
			"title": "Labyrinthine Servers",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, place 2 power counters on it.\n[interrupt] → <strong>Hosted power counter:</strong> Prevent the Runner from jacking out. The Runner cannot jack out for the remainder of this run."
		})

	NRCardDefs.defcard("Let Them Dream", {
			"title": "Let Them Dream",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 1,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, you may search HQ, R&D, or Archives for 1 agenda and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that agenda to HQ or the bottom of R&D.\nWhile this agenda is in the Runner’s score area, it is worth 1 less agenda point."
		})

	NRCardDefs.defcard("License Acquisition", {
			"title": "License Acquisition",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, you may install and rez 1 asset or upgrade from HQ or Archives, ignoring all costs."
		})

	NRCardDefs.defcard("Lightning Laboratory", {
			"title": "Lightning Laboratory",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, place 1 agenda counter on it.\nWhenever a run begins, you may remove 1 hosted agenda counter to rez up to 2 pieces of ice protecting the attacked server, ignoring all costs. When this turn ends, derez 2 pieces of ice protecting that server."
		})

	NRCardDefs.defcard("Longevity Serum", {
			"title": "Longevity Serum",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, trash any number of cards from HQ. Shuffle up to 3 cards from Archives into R&D.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Lotus Haze", {
			"title": "Lotus Haze",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, place 3 agenda counters on it.\n<strong>Hosted agenda counter:</strong> Move 1 rezzed upgrade to the root of another server."
		})

	NRCardDefs.defcard("Luminal Transubstantiation", {
			"title": "Luminal Transubstantiation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, gain [click][click][click]. You cannot score agendas for the remainder of the turn.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Mandatory Seed Replacement", {
			"title": "Mandatory Seed Replacement",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Mandatory Seed Replacement, rearrange any number of ice protecting all servers."
		})

	NRCardDefs.defcard("Mandatory Upgrades", {
			"title": "Mandatory Upgrades",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 6,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "You have 1 additional [click] to spend each turn."
		})

	NRCardDefs.defcard("Market Research", {
			"title": "Market Research",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "If the Runner is tagged when you score Market Research, place 1 agenda counter on it.\nMarket Research is worth 1 additional agenda point while it has an agenda counter on it."
		})

	NRCardDefs.defcard("Medical Breakthrough", {
			"title": "Medical Breakthrough",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "Lower the advancement requirement of each Medical Breakthrough by 1. This ability is active even while Medical Breakthrough is in the Runner's score area."
		})

	NRCardDefs.defcard("Méliès City Luxury Line", {
			"title": "Méliès City Luxury Line",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "As an additional cost to steal this agenda, the Runner must spend [click].\nWhen you score this agenda, gain [click]."
		})

	NRCardDefs.defcard("Megaprix Qualifier", {
			"title": "Megaprix Qualifier",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"text": "When you score this agenda, if there is another copy of Megaprix Qualifier in either playerʼs score area, place 1 agenda counter on this agenda.\nWhile this agenda has a hosted agenda counter, it is worth 1 more agenda point."
		})

	NRCardDefs.defcard("Merger", {
			"title": "Merger",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 1,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "Merger is worth 1 additional agenda point while in the Runner's score area."
		})

	NRCardDefs.defcard("Meteor Mining", {
			"title": "Meteor Mining",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 2,
			"factioncost": 0,
			"text": "When you score Meteor Mining, you may gain 7[credit]. If the Runner has at least 2 tags, you may do 7 meat damage instead."
		})

	NRCardDefs.defcard("Midnight-3 Arcology", {
			"title": "Midnight-3 Arcology",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, draw 3 cards. Skip your discard step this turn."
		})

	NRCardDefs.defcard("NAPD Contract", {
			"title": "NAPD Contract",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "This agenda gets +1 advancement requirement for each bad publicity you have.\nAs an additional cost to steal this agenda, the Runner must pay 4[credit]."
		})

	NRCardDefs.defcard("Net Quarantine", {
			"title": "Net Quarantine",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "For the first trace each turn, the Runner's [link] is treated as 0. <em>(They can still increase their link strength by spending credits.)</em>\nWhenever the Runner spends credits to increase their link strength, gain 1[credit] for every 2[credit] they spent."
		})

	NRCardDefs.defcard("New Construction", {
			"title": "New Construction",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Public",
			"subtypes": ["Public"],
			"text": "Install only faceup. <em>(This agenda is neither rezzed nor unrezzed.)</em>\nWhenever you advance this agenda, you may install 1 card from HQ in the root of a new server. If there are 5 or more hosted advancement counters, rez that card, ignoring all costs."
		})

	NRCardDefs.defcard("Next Big Thing", {
			"title": "Next Big Thing",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When this agenda is scored or stolen, place 1 agenda counter on it.\n<strong>[click]</strong>, <strong>hosted agenda counter:</strong> Draw 4 cards. Shuffle any number of cards from HQ into R&D. The Corp can use this ability even if this agenda is in the Runner's score area."
		})

	NRCardDefs.defcard("NEXT Wave 2", {
			"title": "NEXT Wave 2",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "NEXT",
			"subtypes": ["NEXT"],
			"text": "When you score this agenda, if there is a rezzed piece of <strong>NEXT</strong> ice, you may do 1 core damage."
		})

	NRCardDefs.defcard("Nisei MK II", {
			"title": "Nisei MK II",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> End the run."
		})

	NRCardDefs.defcard("Oaktown Renovation", {
			"title": "Oaktown Renovation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Public - Initiative",
			"subtypes": ["Public", "Initiative"],
			"text": "Install only faceup. <em>(This agenda is neither rezzed nor unrezzed.)</em>\nWhenever you advance this agenda, gain 2[credit]. If there are 5 or more hosted advancement counters <em>(including the counter just placed)</em>, gain 3[credit] instead."
		})

	NRCardDefs.defcard("Obokata Protocol", {
			"title": "Obokata Protocol",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "As an additional cost to steal Obokata Protocol, the Runner must suffer 4 net damage."
		})

	NRCardDefs.defcard("Offworld Office", {
			"title": "Offworld Office",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, gain 7[credit]."
		})

	NRCardDefs.defcard("Off the Books", {
			"title": "Off the Books",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Dividends 1 <em>(When you score this agenda, place 1 agenda counter on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to search R&D for 1 card and reveal it. <em>(Shuffle R&D after searching it.)</em> You may install that card, ignoring all costs. If you do not, add it to HQ."
		})

	NRCardDefs.defcard("Ontological Dependence", {
			"title": "Ontological Dependence",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "This agenda gets -1 advancement requirement for each core damage the Runner has taken this game."
		})

	NRCardDefs.defcard("Oracle Thinktank", {
			"title": "Oracle Thinktank",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When the Runner steals this agenda, give them 1 tag.\n[click], <strong>remove 1 tag:</strong> Shuffle this agenda into R&D. The Corp can use this ability only if this agenda is in the Runner's score area."
		})

	NRCardDefs.defcard("Orbital Superiority", {
			"title": "Orbital Superiority",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, if the Runner is tagged, do 4 meat damage; otherwise, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Paper Trail", {
			"title": "Paper Trail",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Paper Trail, Trace[6]. If successful, trash all <strong>connection</strong> and <strong>job</strong> resources."
		})

	NRCardDefs.defcard("Personality Profiles", {
			"title": "Personality Profiles",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "Whenever the Runner searches the stack or installs a card from the heap, they trash 1 card from the grip at random."
		})

	NRCardDefs.defcard("Philotic Entanglement", {
			"title": "Philotic Entanglement",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Philotic Entanglement, do 1 net damage for each agenda in the Runner's score area.\nLimit 1 Philotic Entanglement per deck."
		})

	NRCardDefs.defcard("Post-Truth Dividend", {
			"title": "Post-Truth Dividend",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, you may draw 1 card."
		})

	NRCardDefs.defcard("Posted Bounty", {
			"title": "Posted Bounty",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security - Liability",
			"subtypes": ["Security", "Liability"],
			"text": "When you score this agenda, you may forfeit it. If you do, give the Runner 1 tag and take 1 bad publicity."
		})

	NRCardDefs.defcard("Priority Requisition", {
			"title": "Priority Requisition",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Priority Requisition, you may rez a piece of ice ignoring all costs."
		})

	NRCardDefs.defcard("Private Security Force", {
			"title": "Private Security Force",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "If the Runner is tagged, Private Security Force gains: \"[click]: Do 1 meat damage.\""
		})

	NRCardDefs.defcard("Profiteering", {
			"title": "Profiteering",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Liability",
			"subtypes": ["Liability"],
			"text": "When you score this agenda, take up to 3 bad publicity. Gain 5[credit] for each bad publicity taken this way."
		})

	NRCardDefs.defcard("Project Ares", {
			"title": "Project Ares",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security - Liability",
			"subtypes": ["Security", "Liability"],
			"text": "When you score this agenda, the Runner trashes 1 of their installed cards for each hosted advancement counter past 4. If the Runner trashes at least 1 card this way, take 1 bad publicity."
		})

	NRCardDefs.defcard("Project Atlas", {
			"title": "Project Atlas",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, place 1 agenda counter on it for each hosted advancement counter past 3.\n<strong>Hosted agenda counter:</strong> Search R&D for 1 card and reveal it. Add it to HQ."
		})

	NRCardDefs.defcard("Project Beale", {
			"title": "Project Beale",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, place 1 agenda counter on it for every 2 hosted advancement counters past 3.\nThis agenda is worth 1 more agenda point for each hosted agenda counter."
		})

	NRCardDefs.defcard("Project Ingatan", {
			"title": "Project Ingatan",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "Dividends 1 <em>(When you score this agenda, place 1 agenda counter on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to install 1 card from Archives, ignoring all costs."
		})

	NRCardDefs.defcard("Project Kusanagi", {
			"title": "Project Kusanagi",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 0,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Project Kusanagi, place 1 agenda counter on it for each advancement token on it over 2.\n<strong>Hosted agenda counter:</strong> Choose 1 piece of ice to gain \"[subroutine] Do 1 net damage.\" after all its other subroutines for the remainder of this run."
		})

	NRCardDefs.defcard("Project Vacheron", {
			"title": "Project Vacheron",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "[interrupt] → When this agenda would be added to the Runnerʼs score area from anywhere except Archives, instead it is added to their score area with 4 hosted agenda counters.\nWhile this agenda is in the Runnerʼs score area with 1 or more hosted agenda counters, it is worth 0 agenda points and gains “When the Runnerʼs turn begins, remove 1 hosted agenda counter.“"
		})

	NRCardDefs.defcard("Project Vitruvius", {
			"title": "Project Vitruvius",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, place 1 agenda counter on it for each hosted advancement counter past 3.\n<strong>Hosted agenda counter:</strong> Add 1 card from Archives to HQ."
		})

	NRCardDefs.defcard("Project Wotan", {
			"title": "Project Wotan",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, place 3 agenda counters on it.\n<strong>Hosted agenda counter:</strong> The rezzed piece of <strong>bioroid</strong> ice the Runner is approaching gains \"[subroutine] End the run.\" after its other subroutines for the remainder of this run."
		})

	NRCardDefs.defcard("Project Yagi-Uda", {
			"title": "Project Yagi-Uda",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, place 1 agenda counter on it for each hosted advancement counter past 3.\n<strong>Hosted agenda counter:</strong> Swap 1 card from HQ with 1 card in the root of or protecting the attacked server. The Runner may jack out. Use this ability only during a run."
		})

	NRCardDefs.defcard("Puppet Master", {
			"title": "Puppet Master",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Whenever the Runner makes a successful run, you may place 1 advancement token on a card that can be advanced."
		})

	NRCardDefs.defcard("Proprionegation", {
			"title": "Proprionegation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> The Runner moves to the outermost position of Archives. <em>(They approach any ice in that position.)</em> Use this ability only during a run."
		})

	NRCardDefs.defcard("Quantum Predictive Model", {
			"title": "Quantum Predictive Model",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda while they are tagged, add it to your score area."
		})

	NRCardDefs.defcard("Rebranding Team", {
			"title": "Rebranding Team",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "All assets gain <strong>advertisement</strong>."
		})

	NRCardDefs.defcard("Reeducation", {
			"title": "Reeducation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, add any number of cards from HQ to the bottom of R&D. Draw X cards, where X is equal to the number of cards you added to R&D this way. If the Runner has at least X cards in the grip, they add X cards from the grip to the bottom of the stack at random."
		})

	NRCardDefs.defcard("Regenesis", {
			"title": "Regenesis",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score this agenda, if no Corp cards have been added to Archives this turn, you may reveal 1 facedown agenda in Archives and add it to your score area."
		})

	NRCardDefs.defcard("Regulatory Capture", {
			"title": "Regulatory Capture",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 6,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "For each bad publicity you have up to 4, this agenda gets −1 advancement requirement."
		})

	NRCardDefs.defcard("Remastered Edition", {
			"title": "Remastered Edition",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter:</strong> Place 1 advancement counter on an installed card."
		})

	NRCardDefs.defcard("Remote Data Farm", {
			"title": "Remote Data Farm",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "Your maximum hand size is increased by 2."
		})

	NRCardDefs.defcard("Remote Enforcement", {
			"title": "Remote Enforcement",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Remote Enforcement, you may search R&D for a piece of ice, install it protecting a remote server (paying its install cost), and rez it, ignoring its rez cost, then shuffle R&D."
		})

	NRCardDefs.defcard("Research Grant", {
			"title": "Research Grant",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score Research Grant, you may score another copy of Research Grant that is installed."
		})

	NRCardDefs.defcard("Restructured Datapool", {
			"title": "Restructured Datapool",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "[click]: Trace[2]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Sacrifice Zone Expansion", {
			"title": "Sacrifice Zone Expansion",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Public - Expansion",
			"subtypes": ["Public", "Expansion"],
			"text": "Install only faceup. <em>(This agenda is neither rezzed nor unrezzed.)</em>\nThe first time each turn you advance this agenda, gain 3[credit].\nOnce per turn → When the Runner makes a successful run on another server, you may remove 1 hosted advancement counter to do 1 meat damage."
		})

	NRCardDefs.defcard("Salvo Testing", {
			"title": "Salvo Testing",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "Whenever you score an agenda <em>(including this one)</em>, you may do 1 core damage."
		})

	NRCardDefs.defcard("SDS Drone Deployment", {
			"title": "SDS Drone Deployment",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "As an additional cost to steal this agenda, the Runner must trash 1 installed program.\nWhen you score this agenda, trash 1 installed program."
		})

	NRCardDefs.defcard("See How They Run", {
			"title": "See How They Run",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Psi - Security",
			"subtypes": ["Psi", "Security"],
			"text": "When you score this agenda, give the Runner 1 tag. Play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, do 1 core damage. If the bids match, do 1 net damage."
		})

	NRCardDefs.defcard("Self-Destruct Chips", {
			"title": "Self-Destruct Chips",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "The Runner's maximum hand size is reduced by 1."
		})

	NRCardDefs.defcard("Send a Message", {
			"title": "Send a Message",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When this agenda is scored or stolen, you may rez 1 installed piece of ice, ignoring all costs."
		})

	NRCardDefs.defcard("Sensor Net Activation", {
			"title": "Sensor Net Activation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "Place 1 agenda counter on Sensor Net Activation when you score it.\n<strong>Hosted agenda counter:</strong> Rez a <strong>bioroid</strong>, ignoring all costs. When the turn ends, derez that <strong>bioroid</strong>."
		})

	NRCardDefs.defcard("Sentinel Defense Program", {
			"title": "Sentinel Defense Program",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "Whenever the Runner suffers at least 1 core damage, do 1 net damage."
		})

	NRCardDefs.defcard("Sericulture Expansion", {
			"title": "Sericulture Expansion",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "Dividends 1 <em>(When you score this agenda, place 1 agenda counter on it for each excess advancement counter.)</em>\nWhen your discard phase ends, you may remove 1 hosted agenda counter to place 2 advancement counters on 1 installed card. <em>(You cannot score that card this turn.)</em>"
		})

	NRCardDefs.defcard("Show of Force", {
			"title": "Show of Force",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Show of Force, do 2 meat damage."
		})

	NRCardDefs.defcard("Sisyphus Protocol", {
			"title": "Sisyphus Protocol",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "The first time each turn the Runner passes a rezzed <strong>code gate</strong> or <strong>sentry</strong>, you may pay 1[credit] or trash 1 card from HQ. If you do, the Runner encounters that ice again."
		})

	NRCardDefs.defcard("Slash and Burn Agriculture", {
			"title": "Slash and Burn Agriculture",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Expansion - Expendable",
			"subtypes": ["Expansion", "Expendable"],
			"text": "[click], <strong>1</strong>[credit], <strong>reveal and trash this agenda from HQ:</strong> Place 2 advancement counters on 1 installed card that you can advance."
		})

	NRCardDefs.defcard("SSL Endorsement", {
			"title": "SSL Endorsement",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When this agenda is scored or stolen, place 9[credit] on it.\nWhen the Corp's turn begins, they may take 3[credit] from this agenda. This ability is active even while this agenda is in the Runner's score area."
		})

	NRCardDefs.defcard("Standoff", {
			"title": "Standoff",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 2,
			"agendapoints": 0,
			"factioncost": 0,
			"text": "When you score this agenda, the Runner may trash 1 of their installed cards. If they do not, draw 1 card and gain 5[credit]. Otherwise, you may trash 1 of your installed cards to repeat this process."
		})

	NRCardDefs.defcard("Stegodon MK IV", {
			"title": "Stegodon MK IV",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "Each run, as long as a piece of ice has been derezzed during that run, each installed <strong>icebreaker</strong> gets –2 strength.\nOnce per turn → When a run begins, you may derez 1 piece of ice not protecting the attacked server to gain 1[credit]."
		})

	NRCardDefs.defcard("Sting!", {
			"title": "Sting!",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "When a player scores or steals this agenda, do X net damage. X is equal to 1 plus the number of copies of Sting! in the other playerʼs score area."
		})

	NRCardDefs.defcard("Stoke the Embers", {
			"title": "Stoke the Embers",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, gain 3[credit] and place 1 advancement counter on an installed card.\nWhen you install this agenda from anywhere except HQ, you may reveal it. If you do, gain 2[credit] and place 1 advancement counter on an installed card."
		})

	NRCardDefs.defcard("Successful Field Test", {
			"title": "Successful Field Test",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "When you score Successful Field Test, install any number of cards from HQ, ignoring all costs."
		})

	NRCardDefs.defcard("Superconducting Hub", {
			"title": "Superconducting Hub",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Expansion",
			"subtypes": ["Expansion"],
			"text": "When you score this agenda, you may draw 2 cards.\nYou get +2 maximum hand size."
		})

	NRCardDefs.defcard("Superior Cyberwalls", {
			"title": "Superior Cyberwalls",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "All <strong>barrier</strong> ice have +1 strength.\nWhen you score Superior Cyberwalls, gain 1[credit] for each rezzed <strong>barrier</strong>."
		})

	NRCardDefs.defcard("TGTBT", {
			"title": "TGTBT",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "While the Runner is accessing this agenda in R&D, they must reveal it.\nWhen the Runner accesses this agenda, give them 1 tag."
		})

	NRCardDefs.defcard("The Cleaners", {
			"title": "The Cleaners",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "[interrupt] → Whenever you would do meat damage, increase that damage by 1."
		})

	NRCardDefs.defcard("The Future is Now", {
			"title": "The Future is Now",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score The Future is Now, search R&D for a card and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("The Future Perfect", {
			"title": "The Future Perfect",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative - Psi",
			"subtypes": ["Initiative", "Psi"],
			"text": "When the Runner accesses this agenda while it is not installed, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, the Runner cannot steal this agenda during this access."
		})

	NRCardDefs.defcard("Timely Public Release", {
			"title": "Timely Public Release",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, place 1 agenda counter on it.\n<strong>Hosted agenda counter</strong>: Install 1 piece of ice from HQ or Archives in any position protecting a server, ignoring all costs."
		})

	NRCardDefs.defcard("Tomorrow's Headline", {
			"title": "Tomorrow's Headline",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Ambush",
			"subtypes": ["Ambush"],
			"text": "When this agenda is scored or stolen, give the Runner 1 tag.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Transport Monopoly", {
			"title": "Transport Monopoly",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, place 2 agenda counters on it.\nOnce per turn → <strong>Hosted agenda counter:</strong> This run cannot be declared successful. <em>(This effect does not cause the run to become unsuccessful.)</em> Use this ability only during a run."
		})

	NRCardDefs.defcard("Underway Renovation", {
			"title": "Underway Renovation",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative - Public",
			"subtypes": ["Initiative", "Public"],
			"text": "Install Underway Renovation faceup.\nWhenever you advance Underway Renovation, trash the top card of the Runner's stack (or top 2 cards instead if there are 4 or more advancement tokens on Underway Renovation)."
		})

	NRCardDefs.defcard("Unorthodox Predictions", {
			"title": "Unorthodox Predictions",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security",
			"subtypes": ["Security"],
			"text": "When you score Unorthodox Predictions, choose <strong>sentry</strong>, <strong>code gate</strong> or <strong>barrier</strong>. Subroutines on ice of the chosen type cannot be broken until the beginning of your next turn."
		})

	NRCardDefs.defcard("Utopia Fragment", {
			"title": "Utopia Fragment",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Source",
			"subtypes": ["Source"],
			"text": "As an additional cost to steal an agenda, the Runner must pay 2[credit] for each advancement token on that agenda.\nLimit 1 per deck."
		})

	NRCardDefs.defcard("Vanity Project", {
			"title": "Vanity Project",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 6,
			"agendapoints": 4,
			"factioncost": 1
		})

	NRCardDefs.defcard("Veterans Program", {
			"title": "Veterans Program",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "When you score this agenda, you may remove up to 2 bad publicity."
		})

	NRCardDefs.defcard("Viral Weaponization", {
			"title": "Viral Weaponization",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Research - Security",
			"subtypes": ["Research", "Security"],
			"text": "When the turn on which you scored Viral Weaponization ends, do 1 net damage for each card in the grip."
		})

	NRCardDefs.defcard("Voting Machine Initiative", {
			"title": "Voting Machine Initiative",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"advancementcost": 5,
			"agendapoints": 3,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "Place 3 agenda counters on Voting Machine Initiative when you score it.\nWhen the Runner's turn begins, you may spend 1 hosted agenda counter. If you do, the Runner loses [click], if able."
		})

	NRCardDefs.defcard("Vulcan Coverup", {
			"title": "Vulcan Coverup",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Security - Liability",
			"subtypes": ["Security", "Liability"],
			"text": "When you score this agenda, do 2 meat damage.\nWhen the Runner steals this agenda, take 1 bad publicity."
		})

	NRCardDefs.defcard("Vulnerability Audit", {
			"title": "Vulnerability Audit",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 3,
			"factioncost": 1,
			"keywords": "Research",
			"subtypes": ["Research"],
			"text": "You cannot score this agenda if it was installed this turn."
		})

	NRCardDefs.defcard("Water Monopoly", {
			"title": "Water Monopoly",
			"type": "Agenda",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"advancementcost": 3,
			"agendapoints": 1,
			"factioncost": 0,
			"keywords": "Initiative",
			"subtypes": ["Initiative"],
			"text": "The install cost of each non-<strong>virtual</strong> resource is increased by 1."
		})

	NRCardDefs.defcard("Witch Hunt", {
			"title": "Witch Hunt",
			"type": "Agenda",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"advancementcost": 4,
			"agendapoints": 2,
			"factioncost": 0,
			"keywords": "Initiative - Liability",
			"subtypes": ["Initiative", "Liability"],
			"text": "When this agenda is scored or stolen, take 1 bad publicity.\nWhen your action phase ends, if you scored this agenda this turn, remove all tags, then give the Runner 3 tags."
		})
