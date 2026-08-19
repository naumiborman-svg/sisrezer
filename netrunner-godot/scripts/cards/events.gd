class_name NRCardsEvents
extends RefCounted

## Printed card data from game.cards.events (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Account Siphon", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, you may force the Corp to lose up to 5[Credits], then you gain 2[Credits] for each credit lost and take 2 tags.",
			"code": "01018",
			"title": "Account Siphon",
		})

	NRCardDefs.defcard("Aircheck", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run - Stealth",
			"subtypes": ["Run", "Stealth"],
			"text": "Place 4[Credits] on this event. While this event is active, you can spend hosted credits, and you cannot lose or spend credits from your credit pool.\nRun HQ or R&D.\nWhen that run ends, if it was successful, you may run a remote server.",
			"code": "36018",
			"title": "Aircheck",
		})

	NRCardDefs.defcard("Always Have a Backup Plan", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. When that run ends, if it was unsuccessful, you may run the attacked server again, ignoring any additional costs to run. During the second run, whenever you encounter the last piece of ice you encountered during the first run, bypass it.",
			"code": "26011",
			"title": "Always Have a Backup Plan",
		})

	NRCardDefs.defcard("Amped Up", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Gain [Click][Click][Click] and suffer 1 core damage. This damage cannot be prevented.",
			"code": "07031",
			"title": "Amped Up",
		})

	NRCardDefs.defcard("Another Day, Another Paycheck", {
			"type": "Event",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhenever you steal an agenda, force the Corp to \"Trace[0]. If unsuccessful, the Runner gains credits equal to the number of agenda points in both players' score areas.\"",
			"code": "11007",
			"title": "Another Day, Another Paycheck",
		})

	NRCardDefs.defcard("Apocalypse", {
			"type": "Event",
			"side": "Runner",
			"faction": "Apex",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Play only if you made a successful run on HQ, R&D and Archives this turn.\nTrash all installed Corp cards. Turn all installed Runner cards facedown.",
			"code": "09030",
			"title": "Apocalypse",
		})

	NRCardDefs.defcard("Ashen Epilogue", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 5,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Shuffle your grip and heap into your stack, then remove the top 5 cards of your stack from the game. Draw 5 cards.\nRemove this event from the game.",
			"code": "34094",
			"title": "Ashen Epilogue",
		})

	NRCardDefs.defcard("Bahia Bands", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. If successful, resolve 2 of the following in any order:<ul><li>Draw 2 cards.</li><li>Install 1 card from your grip, paying 1[Credits] less.</li><li>Remove 1 tag.</li><li>Place 4[Credits] on this event. You can spend hosted credits to pay trash costs for the remainder of this run.</li></ul>",
			"code": "34030",
			"title": "Bahia Bands",
		})

	NRCardDefs.defcard("Because I Can", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run a remote server. If successful, instead of breaching that server, you may force the Corp to shuffle all cards in the root of that server into R&D.",
			"code": "21066",
			"title": "Because I Can",
		})

	NRCardDefs.defcard("Beta Build", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Search your stack for 1 non-<strong>virus</strong> program. Install it, ignoring all costs. <em>(Shuffle your stack after searching it.)</em>\nRun any server. When that run ends, if that program has not been uninstalled, add it to the top of your stack.",
			"code": "36019",
			"title": "Beta Build",
		})

	NRCardDefs.defcard("Black Hat", {
			"type": "Event",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 2,
			"factioncost": 5,
			"uniqueness": false,
			"text": "The Corp must trace[4]. If unsuccessful, for the remainder of the turn, access 2 additional cards whenever you breach HQ or R&D.",
			"code": "21110",
			"title": "Black Hat",
		})

	NRCardDefs.defcard("Blackmail", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Play only if the Corp has at least 1 bad publicity.\nRun any server. The Corp cannot rez ice during that run.",
			"code": "04089",
			"title": "Blackmail",
		})

	NRCardDefs.defcard("Blueberry!™ Diesel", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Look at the top 2 cards of your stack. You may add 1 of those cards to the bottom of your stack. Draw 2 cards.",
			"code": "26012",
			"title": "Blueberry!™ Diesel",
		})

	NRCardDefs.defcard("Bravado", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run a server protected by ice. When that run ends, gain 6[Credits] plus 1[Credits] for each piece of ice you passed during that run.",
			"code": "26074",
			"title": "Bravado",
		})

	NRCardDefs.defcard("Bribery", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. During this run, the Corp must pay X[Credits] as an additional cost to rez the first unrezzed piece of ice approached.",
			"code": "06118",
			"title": "Bribery",
		})

	NRCardDefs.defcard("Brute-Force-Hack", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nDerez a piece of ice that has a rez cost of X or lower.",
			"code": "13002",
			"title": "Brute-Force-Hack",
		})

	NRCardDefs.defcard("Build Script", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Gain 1[Credits] and draw 2 cards.",
			"code": "12028",
			"title": "Build Script",
		})

	NRCardDefs.defcard("Burner", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. If successful, instead of breaching HQ, reveal 3 cards in HQ at random. Add 2 of the revealed cards to the top and/or bottom of R&D.",
			"code": "34085",
			"title": "Burner",
		})

	NRCardDefs.defcard("By Any Means", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Priority - Sabotage",
			"subtypes": ["Priority", "Sabotage"],
			"text": "Play only as your first [Click].\nFor the remainder of the turn, whenever you access a card not in Archives, trash it and suffer 1 meat damage.",
			"code": "21001",
			"title": "By Any Means",
		})

	NRCardDefs.defcard("Calling in Favors", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Gain 1[Credits] for each installed <strong>connection</strong> resource.",
			"code": "05031",
			"title": "Calling in Favors",
		})

	NRCardDefs.defcard("Career Fair", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Install 1 resource from your grip, paying 3[Credits] less.",
			"code": "31015",
			"title": "Career Fair",
		})

	NRCardDefs.defcard("Careful Planning", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nChoose 1 card installed in the root of or protecting a remote server. That card cannot be rezzed this turn.",
			"code": "13013",
			"title": "Careful Planning",
		})

	NRCardDefs.defcard("Carpe Diem", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nGain 4[Credits]. You may run your mark.",
			"code": "33012",
			"title": "Carpe Diem",
		})

	NRCardDefs.defcard("CBI Raid", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, the Corp adds all cards in HQ to the top of R&D in the order of their choice.",
			"code": "10022",
			"title": "CBI Raid",
		})

	NRCardDefs.defcard("Chain Reaction", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 5,
			"uniqueness": false,
			"text": "Play only if you made a successful run on HQ, R&D, and Archives this turn.\nTrash 2 installed Corp cards. The Corp trashes 1 installed Runner card.",
			"code": "36001",
			"title": "Chain Reaction",
		})

	NRCardDefs.defcard("Charm Offensive", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run Archives. When that run ends, you may trash 1 rezzed copy of a card you accessed in Archives during that run.",
			"code": "35003",
			"title": "Charm Offensive",
		})

	NRCardDefs.defcard("Chastushka", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, sabotage 4. <em>(The Corp trashes 4 cards of their choice from HQ and/or the top of R&D.)</em>",
			"code": "33002",
			"title": "Chastushka",
		})

	NRCardDefs.defcard("Chrysopoeian Skimming", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "The Corp may reveal an agenda from HQ. If they do, gain [Click] and draw 1 card. Otherwise, look at the top 3 cards of R&D.",
			"code": "34011",
			"title": "Chrysopoeian Skimming",
		})

	NRCardDefs.defcard("Clean Getaway", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. If successful, gain 6[Credits].",
			"code": "35014",
			"title": "Clean Getaway",
		})

	NRCardDefs.defcard("Code Siphon", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, instead of breaching R&D, you may search your stack for 1 program. Install it, paying 3[Credits] less for each piece of ice protecting R&D, and then take 1 tag.",
			"code": "06115",
			"title": "Code Siphon",
		})

	NRCardDefs.defcard("Cold Read", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run - Stealth",
			"subtypes": ["Run", "Stealth"],
			"text": "Place 4[Credits] on this event, then run any server. You can spend hosted credits during that run. When that run ends, trash 1 installed program you used during that run. Trashing a program this way cannot be prevented.",
			"code": "11083",
			"title": "Cold Read",
		})

	NRCardDefs.defcard("Compile", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. The first time you encounter a piece of ice during this run, you may search your stack or heap for a program and install it, ignoring all costs. When the run ends, add that program to the bottom of your stack if it is still installed.",
			"code": "21088",
			"title": "Compile",
		})

	NRCardDefs.defcard("Concerto", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Reveal the top card of your stack and place credits equal to its printed play or install cost on this event. Add the revealed card to your grip.\nRun any server. You can spend hosted credits during that run.",
			"code": "33075",
			"title": "Concerto",
		})

	NRCardDefs.defcard("Contaminate", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Place 3 virus counters on an installed Runner card with no hosted virus counters.",
			"code": "21083",
			"title": "Contaminate",
		})

	NRCardDefs.defcard("Corporate \"Grant\"", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe first time you install a card each turn, the Corp loses 1[Credits].",
			"code": "21044",
			"title": "Corporate \"Grant\"",
		})

	NRCardDefs.defcard("Corporate Scandal", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp is considered to have 1 additional bad publicity <em>(even if they had no bad publicity)</em>.",
			"code": "10025",
			"title": "Corporate Scandal",
		})

	NRCardDefs.defcard("Creative Commission", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Gain 5[Credits]. If you have any [Click] remaining, lose [Click].",
			"code": "30020",
			"title": "Creative Commission",
		})

	NRCardDefs.defcard("Credit Crash", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. Trash the first non-agenda card you access during this run at no cost. The Corp can spend credits equal to the rez or play cost of the accessed card to prevent this trash.",
			"code": "11021",
			"title": "Credit Crash",
		})

	NRCardDefs.defcard("Credit Kiting", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Play only if you made a successful run on a central server this turn.\nInstall a card from your grip, lowering its install cost by 8[Credits], and take 1 tag.",
			"code": "21023",
			"title": "Credit Kiting",
		})

	NRCardDefs.defcard("Cyber Threat", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nChoose a server. The Corp may rez 1 piece of ice protecting that server. If they do not, run that server. The Corp cannot rez ice during that run.",
			"code": "06013",
			"title": "Cyber Threat",
		})

	NRCardDefs.defcard("Data Breach", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, when that run ends, you may run R&D again.",
			"code": "11028",
			"title": "Data Breach",
		})

	NRCardDefs.defcard("Day Job", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "As an additional cost to play this event, spend [Click][Click][Click].\nGain 10[Credits].",
			"code": "07036",
			"title": "Day Job",
		})

	NRCardDefs.defcard("Deep Data Mining", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, access X additional cards when you breach R&D. X is equal to your unused MU or 4, whichever is less.",
			"code": "13014",
			"title": "Deep Data Mining",
		})

	NRCardDefs.defcard("Deep Dive", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 5,
			"uniqueness": false,
			"text": "Play only if you made a successful run on HQ, R&D, and Archives this turn.\nThe Corp must set aside the top 8 cards of R&D faceup. Access 1 of those cards. You may spend [Click] to access another 1 of those cards. Then, the Corp shuffles the set-aside cards into R&D.",
			"code": "33022",
			"title": "Deep Dive",
		})

	NRCardDefs.defcard("Déjà Vu", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Add 1 card (or up to 2 <strong>virus</strong> cards) from your heap to your grip.",
			"code": "01002",
			"title": "Déjà Vu",
		})

	NRCardDefs.defcard("Demolition Run", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ or R&D.\nAccess → <strong>0[Credits]:</strong> Trash the card you are accessing.",
			"code": "20002",
			"title": "Demolition Run",
		})

	NRCardDefs.defcard("Deuces Wild", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Resolve two of the following in any order:<ul><li>Gain 3[Credits].</li><li>Draw 2 cards.</li><li>Remove 1 tag.</li><li>Expose 1 piece of ice, then make a run.</li></ul>",
			"code": "11008",
			"title": "Deuces Wild",
		})

	NRCardDefs.defcard("Diana's Hunt", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. Whenever you encounter a piece of ice during that run, you may install 1 program from your grip, ignoring all costs. When that run ends, trash all programs installed this way.",
			"code": "12106",
			"title": "Diana's Hunt",
		})

	NRCardDefs.defcard("Diesel", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Draw 3 cards.",
			"code": "31027",
			"title": "Diesel",
		})

	NRCardDefs.defcard("Direct Access", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "While you are resolving this event, each playerʼs identity loses all abilities.\nRun any server. When that run ends, you may shuffle this event into your stack.",
			"code": "26028",
			"title": "Direct Access",
		})

	NRCardDefs.defcard("Dirty Laundry", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. When that run ends, if it was successful, gain 5[Credits].",
			"code": "31037",
			"title": "Dirty Laundry",
		})

	NRCardDefs.defcard("Diversion of Funds", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Double - Run - Sabotage",
			"subtypes": ["Double", "Run", "Sabotage"],
			"text": "As an additional cost to play this event, spend [Click].\nRun HQ. If successful, instead of breaching HQ, you may force the Corp to lose up to 5[Credits], then you gain 1[Credits] for each credit lost.",
			"code": "21105",
			"title": "Diversion of Funds",
		})

	NRCardDefs.defcard("Divide and Conquer", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run Archives. If successful, after breaching Archives, breach HQ, then breach R&D. You cannot access cards in the root of HQ or R&D during these breaches.",
			"code": "22002",
			"title": "Divide and Conquer",
		})

	NRCardDefs.defcard("Drive By", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nExpose 1 card installed in the root of a remote server. If you do and that card is an asset or upgrade, trash it.",
			"code": "08064",
			"title": "Drive By",
		})

	NRCardDefs.defcard("Early Bird", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority - Run",
			"subtypes": ["Priority", "Run"],
			"text": "Play only as your first click.\nGain [Click]. Run any server.",
			"code": "05032",
			"title": "Early Bird",
		})

	NRCardDefs.defcard("Easy Mark", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "Gain 3[Credits].",
			"code": "25023",
			"title": "Easy Mark",
		})

	NRCardDefs.defcard("Embezzle", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, name asset, ice, operation or upgrade, then reveal 2 cards from HQ at random. Trash each revealed card that has the named type, then gain 4[Credits] for each card trashed this way.",
			"code": "21084",
			"title": "Embezzle",
		})

	NRCardDefs.defcard("Emergency Shutdown", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Sabotage",
			"subtypes": ["Sabotage"],
			"text": "Play only if you made a successful run on HQ this turn.\nDerez 1 installed piece of ice.",
			"code": "31016",
			"title": "Emergency Shutdown",
		})

	NRCardDefs.defcard("Emergent Creativity", {
			"type": "Event",
			"side": "Runner",
			"faction": "Adam",
			"cost": 2,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nTrash any number of programs and/or pieces of hardware from your grip. Search your stack for 1 program or piece of hardware. Install it, paying X[Credits] less. X is equal to the total install cost of the trashed cards.",
			"code": "21028",
			"title": "Emergent Creativity",
		})

	NRCardDefs.defcard("Employee Strike", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp's identity loses its printed abilities.",
			"code": "09053",
			"title": "Employee Strike",
		})

	NRCardDefs.defcard("En Passant", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Sabotage",
			"subtypes": ["Sabotage"],
			"text": "Play only if you made a successful run this turn.\nTrash 1 unrezzed piece of ice you passed during your last run.",
			"code": "31003",
			"title": "En Passant",
		})

	NRCardDefs.defcard("Encore", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": false,
			"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nTake an additional turn after this one. Remove Encore from the game instead of trashing it.",
			"code": "11107",
			"title": "Encore",
		})

	NRCardDefs.defcard("Escher", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. If successful, instead of breaching HQ, rearrange any number of ice protecting all servers. <em>(Do not rez or derez any ice or change the number of ice protecting any server.)</em>",
			"code": "03031",
			"title": "Escher",
		})

	NRCardDefs.defcard("Eureka!", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nReveal the top card of your stack. You may install that card, lowering the install cost by 10[Credits], if able; otherwise, trash it.",
			"code": "04027",
			"title": "Eureka!",
		})

	NRCardDefs.defcard("Exclusive Party", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Draw 1 card. Gain 1[Credits] for each copy of Exclusive Party in your heap.\nLimit 6 per deck.",
			"code": "10060",
			"title": "Exclusive Party",
		})

	NRCardDefs.defcard("Executive Wiretaps", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nReveal all cards in HQ.",
			"code": "04084",
			"title": "Executive Wiretaps",
		})

	NRCardDefs.defcard("Exploit", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nDerez up to 3 pieces of ice.",
			"code": "12004",
			"title": "Exploit",
		})

	NRCardDefs.defcard("Exploratory Romp", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. If successful, instead of breaching that server, remove up to 3 advancement counters from 1 card in the root of or protecting the attacked server.",
			"code": "03032",
			"title": "Exploratory Romp",
		})

	NRCardDefs.defcard("Express Delivery", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Look at the top 4 cards of your stack and add 1 of those cards to your grip. Shuffle your stack.",
			"code": "05033",
			"title": "Express Delivery",
		})

	NRCardDefs.defcard("Eye for an Eye", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Play only if you are not tagged.\nRun HQ. If successful, take 1 tag and access 1 additional card when you breach HQ.\nAccess → <strong>Trash 1 card from your grip:</strong> Trash the card you are accessing.",
			"code": "34067",
			"title": "Eye for an Eye",
		})

	NRCardDefs.defcard("Falsified Credentials", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Name a card type. Expose a card in a remote server, then gain 5[Credits] if the exposed card has the named card type.",
			"code": "21064",
			"title": "Falsified Credentials",
		})

	NRCardDefs.defcard("Fear the Masses", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, reveal any number of copies of Fear the Masses from your grip. The Corp trashes X cards from the top of R&D, where X is equal to 1 plus the number of cards you revealed.\nLimit 6 per deck.",
			"code": "10096",
			"title": "Fear the Masses",
		})

	NRCardDefs.defcard("Feint", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. The first 2 times this run you encounter a piece of ice, bypass that ice. If successful, you cannot breach HQ.",
			"code": "05034",
			"title": "Feint",
		})

	NRCardDefs.defcard("Finality", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "As an additional cost to play this event, suffer 1 core damage.\nRun R&D. If successful, access 3 additional cards when you breach R&D.",
			"code": "33066",
			"title": "Finality",
		})

	NRCardDefs.defcard("Fisk Investment Seminar", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nEach player draws 3 cards.",
			"code": "08105",
			"title": "Fisk Investment Seminar",
		})

	NRCardDefs.defcard("Forged Activation Orders", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Sabotage",
			"subtypes": ["Sabotage"],
			"text": "Choose 1 unrezzed piece of ice. The Corp may rez that ice. If they do not, they trash it.",
			"code": "31017",
			"title": "Forged Activation Orders",
		})

	NRCardDefs.defcard("Forked", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run any server. The first time you fully break a <strong>sentry</strong> during that run, trash that <strong>sentry</strong>.",
			"code": "07037",
			"title": "Forked",
		})

	NRCardDefs.defcard("Frame Job", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nForfeit 1 agenda. If you do, give the Corp 1 bad publicity.",
			"code": "04001",
			"title": "Frame Job",
		})

	NRCardDefs.defcard("Frantic Coding", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Look at the top 10 cards of your stack. If any of those cards are programs, you may install one of them, lowering the install cost by 5. Trash the rest of those cards.",
			"code": "11062",
			"title": "Frantic Coding",
		})

	NRCardDefs.defcard("\"Freedom Through Equality\"", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhen you steal an agenda, add \"Freedom Through Equality\" to your score area as an agenda worth 1 agenda point.",
			"code": "10045",
			"title": "\"Freedom Through Equality\"",
		})

	NRCardDefs.defcard("Freelance Coding Contract", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "Trash up to 5 programs from your grip. Gain 2[Credits] for each program trashed.",
			"code": "03033",
			"title": "Freelance Coding Contract",
		})

	NRCardDefs.defcard("Game Day", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nIf you have fewer cards in your grip than your maximum hand size, draw cards until you have cards in your grip equal to your maximum hand size.",
			"code": "08026",
			"title": "Game Day",
		})

	NRCardDefs.defcard("Glut Cipher", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run Archives. If successful, instead of breaching Archives, the Corp adds exactly 5 cards from Archives to HQ, if able. If they do, they trash 5 cards from HQ at random.",
			"code": "21061",
			"title": "Glut Cipher",
		})

	NRCardDefs.defcard("Government Investigations", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhile secretly spending credits, players cannot spend 2[Credits].",
			"code": "11069",
			"title": "Government Investigations",
		})

	NRCardDefs.defcard("Guinea Pig", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Trash your grip.\nGain 10[Credits].",
			"code": "22003",
			"title": "Guinea Pig",
		})

	NRCardDefs.defcard("Hacktivist Meeting", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nAs an additional cost to rez non-ice cards, the Corp must randomly trash a card from HQ.",
			"code": "08021",
			"title": "Hacktivist Meeting",
		})

	NRCardDefs.defcard("Harmony AR Therapy", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Choose up to 5 cards with different names in your heap. Shuffle those cards into your stack.\nRemove this event from the game.",
			"code": "26083",
			"title": "Harmony AR Therapy",
		})

	NRCardDefs.defcard("High-Stakes Job", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 6,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Job",
			"subtypes": ["Run", "Job"],
			"text": "Make a run on a server with at least 1 piece of unrezzed ice. When the run ends, gain 12[Credits] if it was successful.",
			"code": "10004",
			"title": "High-Stakes Job",
		})

	NRCardDefs.defcard("Hostage", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nSearch your stack for a <strong>connection</strong>, reveal it, and add it to your grip. You may install that <strong>connection</strong> (paying its install cost). Shuffle your stack.",
			"code": "25025",
			"title": "Hostage",
		})

	NRCardDefs.defcard("Hot Pursuit", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run on HQ. If successful, gain 9[Credits] and take 1 tag.",
			"code": "22009",
			"title": "Hot Pursuit",
		})

	NRCardDefs.defcard("I've Had Worse", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Draw 3 cards.\nWhenever I've Had Worse is trashed by taking net or meat damage, draw 3 cards.",
			"code": "07032",
			"title": "I've Had Worse",
		})

	NRCardDefs.defcard("Illumination", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, install up to 3 cards from your grip <em>(one at a time)</em>, paying 1[Credits] less for each.",
			"code": "35025",
			"title": "Illumination",
		})

	NRCardDefs.defcard("Immolation Script", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run Archives. If successful, whenever you would access a faceup piece of ice in Archives this run, you may instead trash 1 rezzed copy of that ice. Use this ability only once this run.",
			"code": "08041",
			"title": "Immolation Script",
		})

	NRCardDefs.defcard("In the Groove", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nFor the remainder of this turn, whenever you install a card with a printed install cost of 1[Credits] or greater, draw 1 card or gain 1[Credits].",
			"code": "26020",
			"title": "In the Groove",
		})

	NRCardDefs.defcard("Independent Thinking", {
			"type": "Event",
			"side": "Runner",
			"faction": "Adam",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Trash up to 5 of your installed cards. Draw 1 card for each card trashed (or 2 cards for each card trashed if you trashed at least 1 <strong>directive</strong>).",
			"code": "09038",
			"title": "Independent Thinking",
		})

	NRCardDefs.defcard("Indexing", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, instead of breaching R&D, you may look at the top 5 cards of R&D and arrange them in any order.",
			"code": "29005",
			"title": "Indexing",
		})

	NRCardDefs.defcard("Infiltration", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Gain 2[Credits] or expose 1 card.",
			"code": "20055",
			"title": "Infiltration",
		})

	NRCardDefs.defcard("Information Sifting", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. If successful, instead of breaching HQ, the Corp separates all cards in HQ into 2 facedown piles. Choose 1 of the piles. Access each card in the chosen pile.",
			"code": "10079",
			"title": "Information Sifting",
		})

	NRCardDefs.defcard("Inject", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Reveal the top 4 cards of your stack and trash all programs revealed. Gain 1[Credits] for each program trashed, and add the rest of the revealed cards to your grip.",
			"code": "06073",
			"title": "Inject",
		})

	NRCardDefs.defcard("Injection Attack", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Choose 1 installed <strong>icebreaker</strong> and run any server. During that run, the chosen <strong>icebreaker</strong> gets +2 strength.",
			"code": "11009",
			"title": "Injection Attack",
		})

	NRCardDefs.defcard("Inside Job", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. The first time you encounter a piece of ice during that run, bypass it.",
			"code": "31018",
			"title": "Inside Job",
		})

	NRCardDefs.defcard("Insight", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nThe Corp may look at the top 4 cards of R&D and arrange them in any order.\nReveal the top 4 cards of R&D.",
			"code": "22016",
			"title": "Insight",
		})

	NRCardDefs.defcard("Interdiction", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp cannot rez non-ice cards during the Runner's turn.",
			"code": "11087",
			"title": "Interdiction",
		})

	NRCardDefs.defcard("Into the Depths", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. If successful, for each time you passed ice this run, resolve 1 of the following that you have not yet resolved this run:<ul><li>Gain 4[Credits].</li><li>Search your stack for a program. Install it. <em>(Shuffle your stack after searching it.)</em></li><li>Charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em></li></ul>",
			"code": "33023",
			"title": "Into the Depths",
		})

	NRCardDefs.defcard("Isolation", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "As an additional cost to play this event, trash 1 installed resource.\nGain 7[Credits].",
			"code": "26001",
			"title": "Isolation",
		})

	NRCardDefs.defcard("Itinerant Protesters", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp gets −1 maximum hand size for each bad publicity they have.",
			"code": "07033",
			"title": "Itinerant Protesters",
		})

	NRCardDefs.defcard("Jailbreak", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ or R&D. If successful, draw 1 card and when you breach the attacked server, access 1 additional card.",
			"code": "30028",
			"title": "Jailbreak",
		})

	NRCardDefs.defcard("Joy Ride", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, draw 5 cards.",
			"code": "34021",
			"title": "Joy Ride",
		})

	NRCardDefs.defcard("Katorga Breakout", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. If successful, add 1 card from your heap to your grip.",
			"code": "33067",
			"title": "Katorga Breakout",
		})

	NRCardDefs.defcard("Khusyuk", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, instead of breaching R&D, choose an install cost greater than 0[Credits]. The Corp sets aside the top X cards of R&D faceup, where X is equal to the number of your installed cards with that printed install cost, up to 6. Access 1 of the set-aside cards. The Corp shuffles the set-aside cards into R&D.",
			"code": "26021",
			"title": "Khusyuk",
		})

	NRCardDefs.defcard("Knifed", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run any server. The first time you fully break a <strong>barrier</strong> during that run, trash that <strong>barrier</strong>.",
			"code": "07038",
			"title": "Knifed",
		})

	NRCardDefs.defcard("Kompromat", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run a server protected by ice. When that run ends, if it was successful, give the Corp 1 bad publicity unless they derez 1 piece of ice protecting the attacked server.\nRemove this event from the game.",
			"code": "36010",
			"title": "Kompromat",
		})

	NRCardDefs.defcard("Kraken", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Play only if you stole an agenda this turn.\nChoose a server. The Corp trashes 1 piece of ice protecting that server.",
			"code": "02090",
			"title": "Kraken",
		})

	NRCardDefs.defcard("Labor Rights", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Trash the top 3 cards of your stack. Shuffle 3 cards from your heap into your stack. Draw 1 card. Remove this event from the game instead of trashing it.",
			"code": "28001",
			"title": "Labor Rights",
		})

	NRCardDefs.defcard("Lawyer Up", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nRemove up to 2 tags and draw 3 cards.",
			"code": "04063",
			"title": "Lawyer Up",
		})

	NRCardDefs.defcard("Lean and Mean", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. If you have 3 or fewer programs installed, all <strong>icebreakers</strong> have +2 strength during this run.",
			"code": "12086",
			"title": "Lean and Mean",
		})

	NRCardDefs.defcard("Leave No Trace", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. When the run ends, derez all ice that was rezzed during this run.",
			"code": "12083",
			"title": "Leave No Trace",
		})

	NRCardDefs.defcard("Legwork", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. If successful, access 2 additional cards when you breach HQ.",
			"code": "31019",
			"title": "Legwork",
		})

	NRCardDefs.defcard("Leverage", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Play only if you made a successful run on HQ this turn.\nThe Corp may take 2 bad publicity. If they do not, whenever you would take damage until your next turn begins, prevent all of that damage.",
			"code": "04064",
			"title": "Leverage",
		})

	NRCardDefs.defcard("Levy AR Lab Access", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Shuffle your grip and heap into your stack. Draw 5 cards. Remove Levy AR Lab Access from the game instead of trashing it.",
			"code": "03035",
			"title": "Levy AR Lab Access",
		})

	NRCardDefs.defcard("Lie Low", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nResolve 1 of the following:<ul><li>Draw 4 cards.</li><li>Remove up to 2 tags.</li></ul>",
			"code": "35015",
			"title": "Lie Low",
		})

	NRCardDefs.defcard("Lucky Find", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nGain 9[Credits].",
			"code": "29007",
			"title": "Lucky Find",
		})

	NRCardDefs.defcard("Mad Dash", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. When that run ends, if you stole an agenda during that run, add this event to your score area as an agenda worth 1 agenda point. Otherwise, suffer 1 meat damage.",
			"code": "12008",
			"title": "Mad Dash",
		})

	NRCardDefs.defcard("Maintenance Access", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Double",
			"subtypes": ["Run", "Double"],
			"text": "As an additional cost to play this event, spend [Click].\nRun Archives. When you would approach Archives <em>(after passing all ice)</em>, instead change the attacked server to HQ and approach HQ.",
			"code": "35016",
			"title": "Maintenance Access",
		})

	NRCardDefs.defcard("Making an Entrance", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nLook at the top 6 cards of your stack. You may trash any of those cards and arrange the rest in any order.",
			"code": "10058",
			"title": "Making an Entrance",
		})

	NRCardDefs.defcard("Marathon", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run on a remote server. When the run ends, gain [Click] and add Marathon to your grip instead of trashing it if the run was successful. You may not make another run on that server for the remainder of this turn.",
			"code": "21046",
			"title": "Marathon",
		})

	NRCardDefs.defcard("Mars for Martians", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nDraw 1 card for each installed <strong>clan</strong> resource. Gain 1[Credits] for each tag you have.",
			"code": "12081",
			"title": "Mars for Martians",
		})

	NRCardDefs.defcard("Mass Install", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Install up to 3 programs from your grip (paying the install costs).",
			"code": "05051",
			"title": "Mass Install",
		})

	NRCardDefs.defcard("Meeting of Minds", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Choose <strong>connection</strong> or <strong>virtual</strong>. You may search your stack for 1 resource with the chosen subtype and reveal it. Add that card to your grip.\nReveal any number of cards with the chosen subtype in your grip. Gain 1[Credits] for each card revealed this way.",
			"code": "34076",
			"title": "Meeting of Minds",
		})

	NRCardDefs.defcard("Mining Accident", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Play only if you made a successful run on a central server this turn.\nGive the Corp 1 bad publicity unless they pay 5[Credits].\nRemove this event from the game.",
			"code": "12101",
			"title": "Mining Accident",
		})

	NRCardDefs.defcard("Möbius", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, when that run ends, you may run R&D again. If the second run is successful, gain 4[Credits].",
			"code": "12024",
			"title": "Möbius",
		})

	NRCardDefs.defcard("Modded", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Install a program or piece of hardware, lowering the install cost by 3.",
			"code": "25043",
			"title": "Modded",
		})

	NRCardDefs.defcard("Moshing", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"text": "As an additional cost to play this event, trash 3 cards from your grip.\nGain 3[Credits] and draw 3 cards.",
			"code": "26067",
			"title": "Moshing",
		})

	NRCardDefs.defcard("Mutual Favor", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Search your stack for 1 <strong>icebreaker</strong> and reveal it. <em>(Shuffle your stack after searching it.)</em> If you made a successful run this turn, you may install that program. If you do not, add it to your grip.",
			"code": "30011",
			"title": "Mutual Favor",
		})

	NRCardDefs.defcard("Net Celebrity", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\n1[recurring-credit]\nUse this credit during a run.",
			"code": "06038",
			"title": "Net Celebrity",
		})

	NRCardDefs.defcard("Networking", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Remove 1 tag. Then, you may pay 1[Credits] to add this event to your grip.",
			"code": "31020",
			"title": "Networking",
		})

	NRCardDefs.defcard("Notoriety", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nAdd Notoriety to your score area as an agenda worth 1 agenda point.",
			"code": "25044",
			"title": "Notoriety",
		})

	NRCardDefs.defcard("Office Supplies", {
			"type": "Event",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Reduce the play cost of Office Supplies by 1 for each [link] you have.\nGain 4[Credits] or draw 4 cards.",
			"code": "22024",
			"title": "Office Supplies",
		})

	NRCardDefs.defcard("On the Lam", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Host this event on an installed resource as a condition counter with \"[interrupt] → [Trash]<strong>:</strong> Prevent up to 3 tags or up to 3 damage.\"",
			"code": "11082",
			"title": "On the Lam",
		})

	NRCardDefs.defcard("Out of the Ashes", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run.\nWhen your turn begins, if Out of the Ashes is in your heap, you may remove it from the game to make a run.\nLimit 6 per deck.",
			"code": "10080",
			"title": "Out of the Ashes",
		})

	NRCardDefs.defcard("Overclock", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Place 5[Credits] on this event, then run any server. You can spend hosted credits during that run.",
			"code": "30029",
			"title": "Overclock",
		})

	NRCardDefs.defcard("Paper Tripping", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nRemove all tags.",
			"code": "06015",
			"title": "Paper Tripping",
		})

	NRCardDefs.defcard("Peace in Our Time", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click] and only if the Corp scored no agendas during their last turn.\nGain 10[Credits]. The Corp gains 5[Credits]. You cannot make any runs this turn.",
			"code": "11109",
			"title": "Peace in Our Time",
		})

	NRCardDefs.defcard("Pinhole Threading", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. If successful, instead of breaching the attacked server, access 1 card in the root of another server. If that card is an agenda, you cannot steal or trash it during this access.",
			"code": "33013",
			"title": "Pinhole Threading",
		})

	NRCardDefs.defcard("Planned Assault", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nSearch your stack for a <strong>run</strong> event and play that <strong>run</strong> event (paying its play cost), ignoring any additional costs. Shuffle your stack.",
			"code": "05036",
			"title": "Planned Assault",
		})

	NRCardDefs.defcard("Political Graffiti", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run Archives. If successful, instead of breaching Archives, host this event on an agenda in the Corp's score area as a condition counter with \"Host agenda is worth 1 less agenda point. When the Corp purges virus counters, trash this counter.\"",
			"code": "10039",
			"title": "Political Graffiti",
		})

	NRCardDefs.defcard("Populist Rally", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Play only if you have a <strong>seedy</strong> card installed.\nThe Corp gets -1 allotted [Click] for their next turn.",
			"code": "10026",
			"title": "Populist Rally",
		})

	NRCardDefs.defcard("Power Nap", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nGain 2[Credits]. Gain an additional 1[Credits] for each <strong>double</strong> event in your heap.",
			"code": "04107",
			"title": "Power Nap",
		})

	NRCardDefs.defcard("Power to the People", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nThe first time you access an agenda this turn, gain 7[Credits].",
			"code": "08101",
			"title": "Power to the People",
		})

	NRCardDefs.defcard("Prey", {
			"type": "Event",
			"side": "Runner",
			"faction": "Apex",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. Once during this run, when you pass a piece of ice, you may trash a number of your installed cards equal to the strength of that ice. If you do, trash that ice.",
			"code": "09031",
			"title": "Prey",
		})

	NRCardDefs.defcard("Privileged Access", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Play only if you are not tagged.\nRun Archives. If successful, instead of breaching Archives, take 1 tag.\nWhen you take a tag with this event, you may install 1 resource from your heap, paying 2[Credits] less.\nThreat 3 → When you take a tag with this event, you may install 1 program from your heap.",
			"code": "34068",
			"title": "Privileged Access",
		})

	NRCardDefs.defcard("Process Automation", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Gain 2[Credits] and draw 1 card.",
			"code": "13023",
			"title": "Process Automation",
		})

	NRCardDefs.defcard("Push Your Luck", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Secretly spend any number of credits. The Corp guesses if you spent an even or odd amount. Reveal spent credits. If the Corp guessed incorrectly, gain credits equal to twice the amount spent.",
			"code": "05047",
			"title": "Push Your Luck",
		})

	NRCardDefs.defcard("Pushing the Envelope", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. If you have 2 or fewer cards in your grip, each installed <strong>icebreaker</strong> has +2 strength until the end of the run.",
			"code": "12001",
			"title": "Pushing the Envelope",
		})

	NRCardDefs.defcard("Quality Time", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Draw 5 cards.",
			"code": "02087",
			"title": "Quality Time",
		})

	NRCardDefs.defcard("Queen's Gambit", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nPlace up to 3 advancement counters on 1 unrezzed card in the root of a remote server. Gain 2[Credits] for each counter placed this way. You cannot access that card for the remainder of the turn.",
			"code": "25003",
			"title": "Queen's Gambit",
		})

	NRCardDefs.defcard("Quest Completed", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Play only if you made a successful run on R&D, HQ, and Archives this turn.\nAccess 1 installed card (non-ice).",
			"code": "25004",
			"title": "Quest Completed",
		})

	NRCardDefs.defcard("Raindrops Cut Stone", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. Whenever a subroutine resolves during that run <em>(including a subroutine that ends the run)</em>, place 1 power counter on this event.\nWhen that run ends, draw 1 card for each hosted power counter and gain 3[Credits].",
			"code": "33068",
			"title": "Raindrops Cut Stone",
		})

	NRCardDefs.defcard("Rebirth", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Switch your identity with another identity from the same faction. Remove Rebirth from the game instead of trashing it.\nLimit 1 per deck.",
			"code": "10083",
			"title": "Rebirth",
		})

	NRCardDefs.defcard("Reboot", {
			"type": "Event",
			"side": "Runner",
			"faction": "Apex",
			"cost": 1,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run Archives. If successful, instead of breaching Archives, install up to 5 cards from your heap facedown.\nRemove this event from the game.",
			"code": "22023",
			"title": "Reboot",
		})

	NRCardDefs.defcard("Recon", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. You may jack out when you encounter the first piece of ice.",
			"code": "04024",
			"title": "Recon",
		})

	NRCardDefs.defcard("Rejig", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "As an additional cost to play this event, add 1 installed program or piece of hardware to your grip.\nInstall 1 program or piece of hardware from your grip, paying X[Credits] less. X is equal to the printed install cost of the card you added to your grip.",
			"code": "26029",
			"title": "Rejig",
		})

	NRCardDefs.defcard("Reprise", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Play only if you stole an agenda this turn.\nAdd 1 installed Corp card to HQ. You may run any server.",
			"code": "33076",
			"title": "Reprise",
		})

	NRCardDefs.defcard("Reshape", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 4,
			"uniqueness": false,
			"text": "Swap 2 pieces of unrezzed ice.",
			"code": "12107",
			"title": "Reshape",
		})

	NRCardDefs.defcard("Retrieval Run", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run Archives. If successful, instead of breaching Archives, you may install 1 program from your heap, ignoring all costs.",
			"code": "31004",
			"title": "Retrieval Run",
		})

	NRCardDefs.defcard("Rigged Results", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Secretly spend up to 2[Credits]. The Corp guesses how much you spent. Reveal spent credits. If the Corp guessed incorrectly, choose a piece of ice protecting a server and run that server. The first time during this run you encounter the chosen ice, bypass it.",
			"code": "10102",
			"title": "Rigged Results",
		})

	NRCardDefs.defcard("Rigging Up", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Install 1 program or piece of hardware from your grip, paying 3[Credits] less. You may charge that card if able. <em>(If it has a power counter on it, add another.)</em>",
			"code": "33024",
			"title": "Rigging Up",
		})

	NRCardDefs.defcard("Rip Deal", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. If successful, when you determine the number of cards in HQ you are allowed to access during this run's breach of HQ, you may add that many cards from your heap to your grip. If you do, you cannot access any cards in HQ during this breach. <em>(You can still access cards in the root of HQ.)</em>\nWhen the run ends, remove this event from the game.",
			"code": "12084",
			"title": "Rip Deal",
		})

	NRCardDefs.defcard("Ritual", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Draw 1 card for each [Click] you have remaining.",
			"code": "35026",
			"title": "Ritual",
		})

	NRCardDefs.defcard("Rumor Mill", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nEach unique (♦) non-<strong>region</strong> asset and upgrade loses its printed abilities.",
			"code": "11022",
			"title": "Rumor Mill",
		})

	NRCardDefs.defcard("Run Amok", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Make a run. When the run ends, trash 1 piece of ice that was rezzed during this run.",
			"code": "25006",
			"title": "Run Amok",
		})

	NRCardDefs.defcard("Running Hot", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "As an additional cost to play this event, suffer 1 core damage.\nGain [Click][Click][Click].",
			"code": "33003",
			"title": "Running Hot",
		})

	NRCardDefs.defcard("Running Interference", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Double - Run",
			"subtypes": ["Double", "Run"],
			"text": "As an additional cost to play this event, spend [Click].\nMake a run. During this run, the Corp must pay X[Credits] as an additional cost to rez each piece of ice, where X is the rez cost of that ice.",
			"code": "04044",
			"title": "Running Interference",
		})

	NRCardDefs.defcard("S-Dobrado", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run a central server. The first time you encounter a piece of ice during that run, bypass it.\nThreat 4 → The second time you encounter a piece of ice during that run, you may spend [Click] to bypass it. <em>(This ability is active if any player has 4 or more agenda points.)</em>",
			"code": "34012",
			"title": "S-Dobrado",
		})

	NRCardDefs.defcard("Satellite Uplink", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Expose up to 2 cards.",
			"code": "02023",
			"title": "Satellite Uplink",
		})

	NRCardDefs.defcard("Scavenge", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "As an additional cost to play this event, trash 1 installed program.\n Install 1 program from your grip or heap, paying X[Credits] less. X is equal to the install cost of the program you trashed.",
			"code": "03034",
			"title": "Scavenge",
		})

	NRCardDefs.defcard("Scrounge", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nInstall 1 program from your heap. You may add 1 program from your heap to the bottom of your stack.",
			"code": "35004",
			"title": "Scrounge",
		})

	NRCardDefs.defcard("Scrubbed", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe first piece of ice encountered each turn has -2 strength for the remainder of the run.",
			"code": "06034",
			"title": "Scrubbed",
		})

	NRCardDefs.defcard("Security Leak", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nAs an additional cost to advance a card, the Corp must pay 1[Credits].",
			"code": "14009",
			"title": "Security Leak",
		})

	NRCardDefs.defcard("Sell Out", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "As an additional cost to play this event, trash 1 installed resource.\nGain 4[Credits] and draw 2 cards.",
			"code": "36011",
			"title": "Sell Out",
		})

	NRCardDefs.defcard("Shred", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. The first time the Corp would end that run, prevent the run from ending unless the Corp reveals and trashes X cards from HQ at random. X is equal to the number of cards in the root of the attacked server.",
			"code": "35005",
			"title": "Shred",
		})

	NRCardDefs.defcard("Showing Off", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run R&D. If successful, when you breach R&D, access cards from the bottom of R&D instead of the top.",
			"code": "07034",
			"title": "Showing Off",
		})

	NRCardDefs.defcard("Singularity", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Double - Run",
			"subtypes": ["Double", "Run"],
			"text": "As an additional cost to play this event, spend [Click].\nRun a remote server. If successful, instead of breaching that server, trash all cards installed in the root of that server.",
			"code": "20004",
			"title": "Singularity",
		})

	NRCardDefs.defcard("Social Engineering", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nChoose an unrezzed piece of ice. If the Corp rezzes that piece of ice this turn, gain credits equal to its rez cost.",
			"code": "06018",
			"title": "Social Engineering",
		})

	NRCardDefs.defcard("Spark of Inspiration", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Set aside cards from the top of your stack faceup until you set aside a program. You may install that program, paying 10[Credits] less. Shuffle the set-aside cards into your stack.",
			"code": "33084",
			"title": "Spark of Inspiration",
		})

	NRCardDefs.defcard("Spear Phishing", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Make a run. When you encounter the innermost piece of ice protecting that server, bypass it.",
			"code": "25029",
			"title": "Spear Phishing",
		})

	NRCardDefs.defcard("Spec Work", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Job",
			"subtypes": ["Job"],
			"text": "As an additional cost to play this event, trash 1 installed program.\nGain 4[Credits] and draw 2 cards.",
			"code": "26022",
			"title": "Spec Work",
		})

	NRCardDefs.defcard("Special Order", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Search your stack for an <strong>icebreaker</strong>, reveal it, and add it to your grip. Shuffle your stack.",
			"code": "25030",
			"title": "Special Order",
		})

	NRCardDefs.defcard("Spooned", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run any server. The first time you fully break a <strong>code gate</strong> during that run, trash that <strong>code gate</strong>.",
			"code": "07039",
			"title": "Spooned",
		})

	NRCardDefs.defcard("Spot the Prey", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Expose 1 non-ice card, then make a run.",
			"code": "12005",
			"title": "Spot the Prey",
		})

	NRCardDefs.defcard("Spree", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Place 3 power counters on this event, then run any server.\n<strong>Hosted power counter:</strong> Host 1 installed <strong>trojan</strong> program on a piece of ice protecting the attacked server.",
			"code": "34086",
			"title": "Spree",
		})

	NRCardDefs.defcard("Steelskin Scarring", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Draw 3 cards.\nWhen this event is trashed from your grip or stack, you may draw 2 cards.",
			"code": "33004",
			"title": "Steelskin Scarring",
		})

	NRCardDefs.defcard("Stimhack", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Place 9[Credits] on this event, then run any server. During that run, hosted credits are considered to be in your credit pool. When that run ends, suffer 1 core damage. This damage cannot be prevented.",
			"code": "25007",
			"title": "Stimhack",
		})

	NRCardDefs.defcard("Strike Fund", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Gain 4[Credits].\nWhen this event is trashed from your grip or stack, you may gain 2[Credits].",
			"code": "34001",
			"title": "Strike Fund",
		})

	NRCardDefs.defcard("Sure Gamble", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 5,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Gain 9[Credits].",
			"code": "30030",
			"title": "Sure Gamble",
		})

	NRCardDefs.defcard("Surge", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Play only if you placed at least 1 virus counter on a program this turn.\nPlace 2 virus counters on that program.",
			"code": "02081",
			"title": "Surge",
		})

	NRCardDefs.defcard("SYN Attack", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this event, spend [Click].\nThe Corp must either discard 2 cards or draw 4 cards.",
			"code": "13004",
			"title": "SYN Attack",
		})

	NRCardDefs.defcard("System Outage", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\nWhenever the Corp draws 1 or more cards, if it is not the first time they have drawn cards this turn, they lose 1[Credits].",
			"code": "11001",
			"title": "System Outage",
		})

	NRCardDefs.defcard("System Seizure", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This event is not trashed until another <strong>current</strong> is played or an agenda is scored.\n[interrupt] → The first time each turn you would increase the strength of an <strong>icebreaker</strong>, for the remainder of the run that <strong>icebreaker</strong> gains \"Abilities that increase this program's strength last for the remainder of the run <em>(instead of any shorter duration)</em>.\"",
			"code": "12026",
			"title": "System Seizure",
		})

	NRCardDefs.defcard("Tailgate", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "The play cost of this event is lowered by 1[Credits] for each piece of ice protecting HQ.\nRun HQ. If successful, access 2 additional cards when you breach HQ.",
			"code": "36012",
			"title": "Tailgate",
		})

	NRCardDefs.defcard("Take a Dive", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ or R&D. If successful, and if a subroutine resolved during this run, give the Corp 1 bad publicity.\nRemove this event from the game.",
			"code": "36002",
			"title": "Take a Dive",
		})

	NRCardDefs.defcard("Test Run", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Search either your stack or your heap for 1 program. <em>(Shuffle your stack after searching it.)</em> Install that program, ignoring all costs. When your turn ends, if that program has not been uninstalled, add it to the top of your stack.",
			"code": "31028",
			"title": "Test Run",
		})

	NRCardDefs.defcard("The Maker's Eye", {
			"title": "The Maker's Eye",
		})

	NRCardDefs.defcard("The Noble Path", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Trash all cards from your grip. Run any server. Whenever you would take damage during that run, prevent all of that damage.",
			"code": "10077",
			"title": "The Noble Path",
		})

	NRCardDefs.defcard("The Price", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Trash the top 4 cards of your stack. You may install 1 of those cards, paying 3[Credits] less.",
			"code": "34002",
			"title": "The Price",
		})

	NRCardDefs.defcard("The Price of Freedom", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"text": "As an additional cost to play this event, trash 1 installed <strong>connection</strong> resource.\nThe Corp cannot advance cards during their next turn.\nRemove this event from the game.",
			"code": "10100",
			"title": "The Price of Freedom",
		})

	NRCardDefs.defcard("Three Steps Ahead", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Priority",
			"subtypes": ["Priority"],
			"text": "Play only as your first [Click].\nWhen this turn ends, gain 2[Credits] for each successful run you made during it.",
			"code": "06035",
			"title": "Three Steps Ahead",
		})

	NRCardDefs.defcard("Tinkering", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Mod",
			"subtypes": ["Mod"],
			"text": "Choose a piece of ice. That ice gains <strong>sentry</strong>, <strong>code gate</strong>, and <strong>barrier</strong> until the end of the turn.",
			"code": "25047",
			"title": "Tinkering",
		})

	NRCardDefs.defcard("Trade-In", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "As an additional cost to play this event, trash an installed piece of hardware.\nGain credits equal to half the install cost of the trashed hardware (rounded down) and search your stack for a piece of hardware, reveal it, and add it to your grip. Shuffle your stack.",
			"code": "06078",
			"title": "Trade-In",
		})

	NRCardDefs.defcard("Traffic Jam", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe advancement requirement of each agenda is increased by 1 for each copy of that agenda in the Corp's score area.",
			"code": "08008",
			"title": "Traffic Jam",
		})

	NRCardDefs.defcard("Transfer of Wealth", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run HQ. If successful, take 1 tag and the Corp loses 3[Credits]. Gain 2[Credits] for each credit lost this way.",
			"code": "35017",
			"title": "Transfer of Wealth",
		})

	NRCardDefs.defcard("Tread Lightly", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Run any server. During that run, the rez cost of each piece of ice is increased by 3[Credits].",
			"code": "30012",
			"title": "Tread Lightly",
		})

	NRCardDefs.defcard("Trick Shot", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "Place 4[Credits] on this event. You can spend hosted credits during runs.\nRun R&D. If successful, place 2[Credits] on this event and access 1 additional card when you breach R&D.\nWhen that run ends, you may run a remote server.",
			"code": "34087",
			"title": "Trick Shot",
		})

	NRCardDefs.defcard("Uninstall", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Add an installed program or piece of hardware to your grip.",
			"code": "07053",
			"title": "Uninstall",
		})

	NRCardDefs.defcard("Unscheduled Maintenance", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is scored.\nThe Corp cannot install more than 1 piece of ice each turn.",
			"code": "06036",
			"title": "Unscheduled Maintenance",
		})

	NRCardDefs.defcard("Vamp", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, you may spend X[Credits]. If you do, the Corp loses X[Credits]. If you spent credits, take 1 tag.",
			"code": "02021",
			"title": "Vamp",
		})

	NRCardDefs.defcard("VRcation", {
			"type": "Event",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Draw 4 cards. If you have any [Click] remaining, lose [Click].",
			"code": "30021",
			"title": "VRcation",
		})

	NRCardDefs.defcard("Wanton Destruction", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Run - Sabotage",
			"subtypes": ["Run", "Sabotage"],
			"text": "Run HQ. If successful, instead of breaching HQ, you may spend any number of [Click] to force the Corp to trash that many cards from HQ at random.",
			"code": "07035",
			"title": "Wanton Destruction",
		})

	NRCardDefs.defcard("Watch the World Burn", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Orgcrime - Run - Terminal",
			"subtypes": ["Orgcrime", "Run", "Terminal"],
			"text": "After you resolve this event, end your action phase.\nMake a run on a remote server. If successful, remove the first non-agenda card that you access from the game.\nUntil the game ends, whenever you access a copy of that card, remove it from the game.\nLimit 1 per deck.",
			"code": "23100",
			"title": "Watch the World Burn",
		})

	NRCardDefs.defcard("White Hat", {
			"type": "Event",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 0,
			"factioncost": 5,
			"uniqueness": false,
			"text": "Play only if you made a successful run on a central server this turn.\nForce the Corp to \"Trace[3]. If unsuccessful, reveal all cards in HQ. The Runner may choose up to 2 of the revealed cards. Shuffle those cards into R&D.\"",
			"code": "21048",
			"title": "White Hat",
		})

	NRCardDefs.defcard("Wildcat Strike", {
			"type": "Event",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Resolve 1 of the following of the Corpʼs choice:<ul><li>Gain 6[Credits].</li><li>Draw 4 cards.</li></ul>",
			"code": "30002",
			"title": "Wildcat Strike",
		})

	NRCardDefs.defcard("Windfall", {
			"type": "Event",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Shuffle your stack. Trash the top card of your stack. Gain X[Credits] where X is equal to the install cost of that card.",
			"code": "09054",
			"title": "Windfall",
		})

	NRCardDefs.defcard("Window of Opportunity", {
			"type": "Event",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Run",
			"subtypes": ["Run"],
			"text": "You may install 1 program or piece of hardware from your grip.\nRun any server. When that run begins, derez 1 piece of ice protecting that server. When that run ends, the Corp may rez the ice derezzed this way, ignoring all costs.",
			"code": "34077",
			"title": "Window of Opportunity",
		})
