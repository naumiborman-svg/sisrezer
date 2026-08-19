class_name NRCardsIdentities
extends RefCounted

## Printed card data from game.cards.identities (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("419: Amoral Scammer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "The first time the Corp installs a card each turn, you may expose that card unless the Corp pays 1[Credits].",
			"code": "21063",
			"title": "419: Amoral Scammer",
		})

	NRCardDefs.defcard("A Teia: IP Recovery", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Limit 2 remote servers.\nThe first time each turn you install a card in the root of or protecting a remote server, you may install 1 card from HQ in the root of or protecting another remote server, ignoring all costs. You cannot score the second card this turn.",
			"code": "34039",
			"title": "A Teia: IP Recovery",
		})

	NRCardDefs.defcard("AU Co.: The Gold Standard in Clones", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever you do damage or trash 1 or more cards from HQ, place 1 power counter on this identity.\nWhen your turn begins, you may remove 2 hosted power counters to look at the top 3 cards of R&D. Trash 1 of those cards and add the rest to HQ.",
			"code": "35046",
			"title": "AU Co.: The Gold Standard in Clones",
		})

	NRCardDefs.defcard("Acme Consulting: The Truth You Need", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Subsidiary",
			"subtypes": ["Subsidiary"],
			"text": "The Runner is considered to have 1 additional tag (even if they have 0) during encounters with the outermost piece of ice protecting any server.",
			"code": "22042",
			"title": "Acme Consulting: The Truth You Need",
		})

	NRCardDefs.defcard("Adam: Compulsive Hacker", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Adam",
			"baselink": 0,
			"influencelimit": 25,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "You start the game with 3 different <strong>directive</strong> cards installed (these cards are not considered part of your deck).",
			"code": "09037",
			"title": "Adam: Compulsive Hacker",
		})

	NRCardDefs.defcard("AgInfusion: New Miracles for a New World", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 17,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Once per turn → <strong>Trash the unrezzed piece of ice the Runner is approaching:</strong> Choose a server other than the attacked server. The Runner moves to the outermost position of that server and encounters any ice there.",
			"code": "12052",
			"title": "AgInfusion: New Miracles for a New World",
		})

	NRCardDefs.defcard("Akiko Nisei: Head Case", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 1,
			"influencelimit": 12,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Clone",
			"subtypes": ["Clone"],
			"text": "Whenever you breach R&D, you and the Corp secretly spend 0[Credits], 1[Credits], or 2[Credits]. Reveal spent credits. If you and the Corp spent the same number of credits, access 1 additional card.",
			"code": "22015",
			"title": "Akiko Nisei: Head Case",
		})

	NRCardDefs.defcard("Alice Merchant: Clan Agitator", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 50,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "The first time you make a successful run on Archives each turn, the Corp must trash 1 card from HQ.",
			"code": "12061",
			"title": "Alice Merchant: Clan Agitator",
		})

	NRCardDefs.defcard("Ampère: Cybernetics For Anyone", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Neutral",
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "Your deck cannot include more than 1 copy of any card.\nYour deck may include up to 2 different agenda cards from each Corp faction.",
			"code": "33128",
			"title": "Ampère: Cybernetics For Anyone",
		})

	NRCardDefs.defcard("Andromeda: Dispossessed Ristie", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "You draw a starting hand of 9 cards.",
			"code": "02083",
			"title": "Andromeda: Dispossessed Ristie",
		})

	NRCardDefs.defcard("Apex: Invasive Predator", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Apex",
			"baselink": 0,
			"influencelimit": 25,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Digital",
			"subtypes": ["Digital"],
			"text": "You cannot install non-<strong>virtual</strong> resources.\nWhen your turn begins, you may install 1 card from your grip facedown.",
			"code": "09029",
			"title": "Apex: Invasive Predator",
		})

	NRCardDefs.defcard("Argus Security: Protection Guaranteed", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "Whenever the Runner steals an agenda, they must take 1 tag or suffer 2 meat damage.",
			"code": "07001",
			"title": "Argus Security: Protection Guaranteed",
		})

	NRCardDefs.defcard("Armand \"Geist\" Walker: Tech Lord", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "Whenever you use a [Trash] ability, draw 1 card.",
			"code": "08063",
			"title": "Armand \"Geist\" Walker: Tech Lord",
		})

	NRCardDefs.defcard("Arissana Rocha Nahu: Street Artist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Once per turn → <strong>0[Credits]:</strong> Install 1 program from your grip <em>(paying its install cost)</em>. Use this ability only during a run. When that run ends, trash that program if it is not a <strong>trojan</strong>.",
			"code": "34020",
			"title": "Arissana Rocha Nahu: Street Artist",
		})

	NRCardDefs.defcard("Asa Group: Security Through Vigilance", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn you install a card, you may install 1 non-agenda card from HQ in the root of or protecting the same server.",
			"code": "21009",
			"title": "Asa Group: Security Through Vigilance",
		})

	NRCardDefs.defcard("Ayla \"Bios\" Rahim: Simulant Specialist", {
			"title": "Ayla \"Bios\" Rahim: Simulant Specialist",
		})

	NRCardDefs.defcard("Az McCaffrey: Mechanical Prodigy", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "The first <strong>job</strong> resource, <strong>connection</strong> resource, or piece of hardware you install each turn costs 1[Credits] less to install.",
			"code": "26010",
			"title": "Az McCaffrey: Mechanical Prodigy",
		})

	NRCardDefs.defcard("Azmari EdTech: Shaping the Future", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "When your turn ends, you may name a card type. Gain 2[Credits] the first time each turn the Runner plays or installs a card that has the type you last named this way.",
			"code": "21054",
			"title": "Azmari EdTech: Shaping the Future",
		})

	NRCardDefs.defcard("Barry \"Baz\" Wong: Tri-Maf Veteran", {
			"title": "Barry \"Baz\" Wong: Tri-Maf Veteran",
		})

	NRCardDefs.defcard("BANGUN: When Disaster Strikes", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "You may install agendas faceup. <em>(This does not make their abilities active.)</em>\nWhenever the Runner accesses a faceup installed agenda, do 2 meat damage and give the Runner 1 tag.",
			"code": "35068",
			"title": "BANGUN: When Disaster Strikes",
		})

	NRCardDefs.defcard("Blue Sun: Powering the Future", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "When your turn begins, you may add 1 rezzed card to HQ and gain credits equal to its rez cost.",
			"code": "25123",
			"title": "Blue Sun: Powering the Future",
		})

	NRCardDefs.defcard("Boris \"Syfr\" Kovac: Crafty Veteran", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "Draft format only.\nIf you have more [criminal] cards installed than any other faction, when your turn begins, remove 1 tag.",
			"code": "00008",
			"title": "Boris \"Syfr\" Kovac: Crafty Veteran",
		})

	NRCardDefs.defcard("Captain Padma Isbister: Intrepid Explorer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "The first time each turn a run on R&D begins, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>",
			"code": "33021",
			"title": "Captain Padma Isbister: Intrepid Explorer",
		})

	NRCardDefs.defcard("Cerebral Imaging: Infinite Frontiers", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Your maximum hand size is equal to the number of credits in your credit pool.",
			"code": "03001",
			"title": "Cerebral Imaging: Infinite Frontiers",
		})

	NRCardDefs.defcard("Chaos Theory: Wünderkind", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "+1[Memory Unit]",
			"code": "25040",
			"title": "Chaos Theory: Wünderkind",
		})

	NRCardDefs.defcard("Chronos Protocol: Haas-Bioroid", {
			"title": "Chronos Protocol: Haas-Bioroid",
		})

	NRCardDefs.defcard("Chronos Protocol: Selective Mind-mapping", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "For the first net damage the Runner suffers each turn, you may look at the Runner's grip and select the card that is trashed.",
			"code": "08111",
			"title": "Chronos Protocol: Selective Mind-mapping",
		})

	NRCardDefs.defcard("Cybernetics Division: Humanity Upgraded", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Each player's maximum hand size is reduced by 1.",
			"code": "08050",
			"title": "Cybernetics Division: Humanity Upgraded",
		})

	NRCardDefs.defcard("Dewi Subrotoputri: Pedagogical Dhalang", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Whenever you make a successful run, if your [Memory Unit] is full, you may flip this identity and gain 1[Credits].\nFlip side:\nWhenever you make a successful run, if you have at least 1 unused [Memory Unit], you may flip this identity and draw 1 card.",
			"code": "35023",
			"title": "Dewi Subrotoputri: Pedagogical Dhalang",
		})

	NRCardDefs.defcard("Earth Station: SEA Headquarters", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Limit 1 remote server.\nAs an additional cost to run HQ, the Runner must pay 1[Credits].\n<strong>[Click]:</strong> Flip this identity.\nFlip side:\nLimit 1 remote server.\nAs an additional cost to run a remote server, the Runner must pay 6[Credits].\nWhen the Runner makes a successful run on HQ, flip this identity.",
			"code": "26120",
			"title": "Earth Station: SEA Headquarters",
		})

	NRCardDefs.defcard("Editorial Division: Ad Nihilum", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn you take bad publicity, you may search R&D for 1 non-agenda <strong>black ops</strong>, <strong>gray ops</strong>, or <strong>liability</strong> card and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that card to HQ.",
			"code": "36046",
			"title": "Editorial Division: Ad Nihilum",
		})

	NRCardDefs.defcard("Edward Kim: Humanity's Hammer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Trash the first operation you access each turn at no cost.",
			"code": "07028",
			"title": "Edward Kim: Humanity's Hammer",
		})

	NRCardDefs.defcard("Ele \"Smoke\" Scovak: Cynosure of the Net", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod - Stealth",
			"subtypes": ["G-mod", "Stealth"],
			"text": "1[recurring-credit]\nUse this credit to pay for using <strong>icebreakers</strong>.",
			"code": "11066",
			"title": "Ele \"Smoke\" Scovak: Cynosure of the Net",
		})

	NRCardDefs.defcard("Epiphany Analytica: Nations Undivided", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn the Runner steals or trashes a Corp card, place 1 power counter on this identity.\n[Click], <strong>hosted power counter:</strong> Look at the top 3 cards of R&D. You may install 1 of those cards.",
			"code": "34048",
			"title": "Epiphany Analytica: Nations Undivided",
		})

	NRCardDefs.defcard("Esâ Afontov: Eco-Insurrectionist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "The first time each turn you suffer core damage, you may draw 1 card and sabotage 2. <em>(The Corp trashes 2 cards of their choice from HQ and/or the top of R&D.)</em>",
			"code": "33001",
			"title": "Esâ Afontov: Eco-Insurrectionist",
		})

	NRCardDefs.defcard("Exile: Streethawk", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Whenever you install a program from your heap, draw 1 card.",
			"code": "03030",
			"title": "Exile: Streethawk",
		})

	NRCardDefs.defcard("Freedom Khumalo: Crypto-Anarchist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "Access, once per turn → <strong>Any X virus counters:</strong> Trash the non-agenda card you are accessing. X must be equal to that card's rez or play cost.",
			"code": "21081",
			"title": "Freedom Khumalo: Crypto-Anarchist",
		})

	NRCardDefs.defcard("Fringe Applications: Tomorrow, Today", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Draft format only.\nIf you have more [weyland-consortium] cards rezzed than any other faction, when the Runner's turn begins, place an advancement token on a piece of ice.",
			"code": "00013",
			"title": "Fringe Applications: Tomorrow, Today",
		})

	NRCardDefs.defcard("Gabriel Santiago: Consummate Professional", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "The first time you make a successful run on HQ each turn, gain 2[Credits].",
			"code": "25020",
			"title": "Gabriel Santiago: Consummate Professional",
		})

	NRCardDefs.defcard("Gagarin Deep Space: Expanding the Horizon", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "As an additional cost to access a card in the root of a remote server, the Runner must pay 1[Credits].",
			"code": "07002",
			"title": "Gagarin Deep Space: Expanding the Horizon",
		})

	NRCardDefs.defcard("GameNET: Where Dreams are Real", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 17,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever a Corp card ability causes the Runner to spend or lose at least 1[Credits] during a run, gain 1[Credits].",
			"code": "26113",
			"title": "GameNET: Where Dreams are Real",
		})

	NRCardDefs.defcard("GRNDL: Power Unleashed", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 10,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division - Liability",
			"subtypes": ["Division", "Liability"],
			"text": "You start the game with 10[Credits] and 1 bad publicity.",
			"code": "04097",
			"title": "GRNDL: Power Unleashed",
		})

	NRCardDefs.defcard("Haarpsichord Studios: Entertainment Unleashed", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The Runner cannot steal more than one agenda each turn.",
			"code": "08092",
			"title": "Haarpsichord Studios: Entertainment Unleashed",
		})

	NRCardDefs.defcard("Haas-Bioroid: Architects of Tomorrow", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 12,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "The first time each turn the Runner passes a rezzed piece of <strong>bioroid</strong> ice, you may rez 1 <strong>bioroid</strong> card, paying 4[Credits] less.",
			"code": "31040",
			"title": "Haas-Bioroid: Architects of Tomorrow",
		})

	NRCardDefs.defcard("Haas-Bioroid: Engineering the Future", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "The first time you install a card each turn, gain 1[Credits].",
			"code": "01054",
			"title": "Haas-Bioroid: Engineering the Future",
		})

	NRCardDefs.defcard("Haas-Bioroid: Precision Design", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "You get +1 maximum hand size.\nWhenever you score an agenda, you may add 1 card from Archives to HQ.",
			"code": "30035",
			"title": "Haas-Bioroid: Precision Design",
		})

	NRCardDefs.defcard("Haas-Bioroid: Stronger Together", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "All <strong>bioroid</strong> ice has +1 strength.",
			"code": "25066",
			"title": "Haas-Bioroid: Stronger Together",
		})

	NRCardDefs.defcard("Harishchandra Ent.: Where You're the Star", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 17,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "While the Runner is tagged, they play with the grip revealed.",
			"code": "10107",
			"title": "Harishchandra Ent.: Where You're the Star",
		})

	NRCardDefs.defcard("Harmony Medtech: Biomedical Pioneer", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 12,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Each player needs 1 fewer agenda point to win the game.",
			"code": "05001",
			"title": "Harmony Medtech: Biomedical Pioneer",
		})

	NRCardDefs.defcard("Hayley Kaplan: Universal Scholar", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "The first time you install a card each turn, you may install another card of the same type from your grip (paying its install cost).",
			"code": "08025",
			"title": "Hayley Kaplan: Universal Scholar",
		})

	NRCardDefs.defcard("Hiram \"0mission\" Svensson: Shadow of the Past", {
			"title": "Hiram \"0mission\" Svensson: Shadow of the Past",
		})

	NRCardDefs.defcard("Hoshiko Shiro: Untold Protagonist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "When your turn ends, if you accessed a card this turn, gain 2[Credits] and flip this identity.\nFlip side:\nWhen your turn begins, draw 1 card and lose 1[Credits].\nWhen your turn ends, if you did not access any cards this turn, flip this identity.",
			"code": "26066",
			"title": "Hoshiko Shiro: Untold Protagonist",
		})

	NRCardDefs.defcard("Hyoubu Institute: Absolute Clarity", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn you reveal a card, gain 1[Credits].\n<strong>[Click]:</strong> Reveal 1 card from the grip at random or the top card of the stack.",
			"code": "26039",
			"title": "Hyoubu Institute: Absolute Clarity",
		})

	NRCardDefs.defcard("Iain Stirling: Retired Spook", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 1,
			"influencelimit": 10,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "When your turn begins, gain 2[Credits] if the Corp has more scored agenda points than you.",
			"code": "05028",
			"title": "Iain Stirling: Retired Spook",
		})

	NRCardDefs.defcard("Industrial Genomics: Growing Solutions", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The trash cost of each card is increased by 1 for each facedown card in Archives.",
			"code": "06105",
			"title": "Industrial Genomics: Growing Solutions",
		})

	NRCardDefs.defcard("Information Dynamics: All You Need To Know", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Draft format only.\nIf you have more [nbn] cards rezzed than any other faction, whenever an agenda is scored or stolen, give the runner 1 tag.",
			"code": "00012",
			"title": "Information Dynamics: All You Need To Know",
		})

	NRCardDefs.defcard("Issuaq Adaptics: Sustaining Diversity", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever you score an agenda that you did not install or advance this turn, place 1 power counter on this identity.\nFor each hosted power counter, you need 1 less agenda point to win the game.",
			"code": "33104",
			"title": "Issuaq Adaptics: Sustaining Diversity",
		})

	NRCardDefs.defcard("Jamie \"Bzzz\" Micken: Techno Savant", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Draft format only.\nIf you have more [shaper] cards installed than any other faction, when you install a card the first time each turn, draw 1 card.",
			"code": "00009",
			"title": "Jamie \"Bzzz\" Micken: Techno Savant",
		})

	NRCardDefs.defcard("Jemison Astronautics: Sacrifice. Audacity. Success.", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "Whenever you forfeit an agenda, place X advancement counters on 1 installed card. X is equal to the agenda point value of the forfeited agenda plus 1.",
			"code": "12016",
			"title": "Jemison Astronautics: Sacrifice. Audacity. Success.",
		})

	NRCardDefs.defcard("Jesminder Sareen: Girl Behind the Curtain", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "[interrupt] → The first time each run you would take 1 or more tags, prevent 1 tag.",
			"code": "10006",
			"title": "Jesminder Sareen: Girl Behind the Curtain",
		})

	NRCardDefs.defcard("Jinteki Biotech: Life Imagined", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Before taking your first turn, you may switch this identity with any copy of Jinteki Biotech.\n<strong>[Click][Click][Click]:</strong> Flip this identity.\nSide 1: When you flip this identity, do 2 net damage.\nSide 2: When you flip this identity, shuffle all cards in Archives into R&D.\nSide 3: When you flip this identity, place 4 advancement counters on 1 installed card that you can advance.",
			"code": "08012",
			"title": "Jinteki Biotech: Life Imagined",
		})

	NRCardDefs.defcard("Jinteki: Personal Evolution", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Whenever an agenda is scored or stolen, do 1 net damage.",
			"code": "31050",
			"title": "Jinteki: Personal Evolution",
		})

	NRCardDefs.defcard("Jinteki: Potential Unleashed", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 12,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Whenever the Runner takes at least 1 net damage, trash the top card of the stack.",
			"code": "11054",
			"title": "Jinteki: Potential Unleashed",
		})

	NRCardDefs.defcard("Jinteki: Replicating Perfection", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "The Runner cannot run on remote servers. Ignore this ability until the end of the turn whenever the Runner runs on a central server.",
			"code": "25085",
			"title": "Jinteki: Replicating Perfection",
		})

	NRCardDefs.defcard("Jinteki: Restoring Humanity", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "When your discard phase ends, if there is a facedown card in Archives, gain 1[Credits].",
			"code": "30043",
			"title": "Jinteki: Restoring Humanity",
		})

	NRCardDefs.defcard("Kabonesa Wu: Netspace Thrillseeker", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "[Click]: Search your stack for a non-<strong>virus</strong> program and install it, lowering its install cost by 1[Credits], then shuffle your stack. If that program is still installed when your turn ends, remove it from the game.",
			"code": "21025",
			"title": "Kabonesa Wu: Netspace Thrillseeker",
		})

	NRCardDefs.defcard("Kate \"Mac\" McCaffrey: Digital Tinker", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Lower the install cost of the first program or piece of hardware you install each turn by 1.",
			"code": "01033",
			"title": "Kate \"Mac\" McCaffrey: Digital Tinker",
		})

	NRCardDefs.defcard("Ken \"Express\" Tenma: Disappeared Clone", {
			"title": "Ken \"Express\" Tenma: Disappeared Clone",
		})

	NRCardDefs.defcard("Khan: Savvy Skiptracer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 12,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "The first time you pass a piece of ice each turn, you may install an <strong>icebreaker</strong> from your hand, lowering the install cost by 1.",
			"code": "11027",
			"title": "Khan: Savvy Skiptracer",
		})

	NRCardDefs.defcard("Laramy Fisk: Savvy Investor", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "The first time you make a successful run on a central server each turn, you may force the Corp to draw 1 card.",
			"code": "08104",
			"title": "Laramy Fisk: Savvy Investor",
		})

	NRCardDefs.defcard("Lat: Ethical Freelancer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "When your discard phase ends, if you have the same number of cards in your grip as the Corp has in HQ, you may draw 1 card.",
			"code": "26019",
			"title": "Lat: Ethical Freelancer",
		})

	NRCardDefs.defcard("Leela Patel: Trained Pragmatist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Whenever an agenda is scored or stolen, add 1 unrezzed card to HQ.",
			"code": "25021",
			"title": "Leela Patel: Trained Pragmatist",
		})

	NRCardDefs.defcard("LEO Construction: Labor Solutions", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Once per turn → <strong>Trash 1 rezzed bioroid card in the root of or protecting the attacked server:</strong> End the run.",
			"code": "35035",
			"title": "LEO Construction: Labor Solutions",
		})

	NRCardDefs.defcard("Liza Talking Thunder: Prominent Legislator", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 50,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "The first time you make a successful run on a central server each turn, draw 2 cards and take 1 tag.",
			"code": "22008",
			"title": "Liza Talking Thunder: Prominent Legislator",
		})

	NRCardDefs.defcard("Los: Data Hijacker", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "The first time the Corp rezzes a piece of ice each turn, gain 2[Credits].",
			"code": "12025",
			"title": "Los: Data Hijacker",
		})

	NRCardDefs.defcard("Magdalene Keino-Chemutai: Cryptarchitect", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "Whenever you discard cards to reach your maximum hand size, you may install 1 program or piece of hardware from among those cards.",
			"code": "35024",
			"title": "Magdalene Keino-Chemutai: Cryptarchitect",
		})

	NRCardDefs.defcard("MaxX: Maximum Punk Rock", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "When your turn begins, trash the top 2 cards of your stack. Draw 1 card.",
			"code": "07029",
			"title": "MaxX: Maximum Punk Rock",
		})

	NRCardDefs.defcard("Méliès U: Only the Brightest", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "When your discard phase ends, secretly set your identity to any copy of Méliès U: Only the Brightest.\nWhen the Runner makes a successful run on a central server, flip this identity.\nWhen the Runner’s action phase ends, gain 1[Credits].\nSide 1: When you flip this identity to this side during a run on HQ, look at the top card of R&D. You may trash that card. If you do, add 1 card from Archives to HQ.\nWhen the Runner’s discard phase ends, flip this identity.\nSide 2: When you flip this identity to this side during a run on R&D, look at the top card of R&D. You may trash that card. If you do, add 1 card from Archives to HQ.\nWhen the Runner’s discard phase ends, flip this identity.\nSide 3: When you flip this identity to this side during a run on Archives, look at the top card of R&D. You may trash that card. If you do, add 1 card from Archives to HQ.\nWhen the Runner’s discard phase ends, flip this identity.",
			"code": "36036",
			"title": "Méliès U: Only the Brightest",
		})

	NRCardDefs.defcard("Mercury: Chrome Libertador", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "Once per turn → When you breach HQ or R&D during a run, if you did not break any subroutines during that run, you may access 1 additional card.",
			"code": "34010",
			"title": "Mercury: Chrome Libertador",
		})

	NRCardDefs.defcard("MirrorMorph: Endless Iteration", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "If the first, second, and third actions you take on your turn are each different from one another, when the third action completes, you may gain 1[Credits] or take another different action, paying [Click] less.",
			"code": "26031",
			"title": "MirrorMorph: Endless Iteration",
		})

	NRCardDefs.defcard("Mti Mwekundu: Life Improved", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Once per turn → When the Runner approaches a server, you may install 1 piece of ice from HQ in the innermost position protecting that server, ignoring all costs. The Runner moves to that ice and approaches it. If this is not the first time they have approached ice this run, they may jack out.",
			"code": "21114",
			"title": "Mti Mwekundu: Life Improved",
		})

	NRCardDefs.defcard("MuslihaT: Multifarious Marketeer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "When your turn begins, look at the top card of your stack. If that card is an <strong>icebreaker</strong> or a <strong>run</strong> event, you may reveal it and add it to your grip.",
			"code": "35013",
			"title": "MuslihaT: Multifarious Marketeer",
		})

	NRCardDefs.defcard("Nasir Meidan: Cyber Explorer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "Whenever you encounter a piece of ice after an approach during which that ice was rezzed, lose all credits in your credit pool. Gain credits equal to the rez cost of that ice.",
			"code": "06017",
			"title": "Nasir Meidan: Cyber Explorer",
		})

	NRCardDefs.defcard("Nathaniel \"Gnat\" Hall: One-of-a-Kind", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "When your turn begins, gain 1[Credits] if you have 2 or fewer cards in your grip.",
			"code": "22001",
			"title": "Nathaniel \"Gnat\" Hall: One-of-a-Kind",
		})

	NRCardDefs.defcard("NBN: Controlling the Message", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 12,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "The first time the Runner trashes an installed Corp card each turn, you may trace[4]. If successful, give the Runner 1 tag (cannot be avoided).",
			"code": "11017",
			"title": "NBN: Controlling the Message",
		})

	NRCardDefs.defcard("NBN: Making News", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "2[recurring-credit]\nUse these credits during trace attempts.",
			"code": "25104",
			"title": "NBN: Making News",
		})

	NRCardDefs.defcard("NBN: Reality Plus", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "The first time each turn the Runner takes a tag, gain 2[Credits] or draw 2 cards.",
			"code": "30051",
			"title": "NBN: Reality Plus",
		})

	NRCardDefs.defcard("NBN: The World is Yours*", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 12,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Your maximum hand size is increased by 1.",
			"code": "02114",
			"title": "NBN: The World is Yours*",
		})

	NRCardDefs.defcard("Near-Earth Hub: Broadcast Center", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 17,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn you create a remote server, draw 1 card.",
			"code": "31060",
			"title": "Near-Earth Hub: Broadcast Center",
		})

	NRCardDefs.defcard("Nebula Talent Management: Making Stars", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "When your action phase ends, if you played an operation this turn, gain 1[Credits] and flip this identity.\nFlip side:\nThe first time each turn you play an operation, gain [Click].\nWhen the Runner makes a successful run on HQ or R&D, flip this identity.",
			"code": "35057",
			"title": "Nebula Talent Management: Making Stars",
		})

	NRCardDefs.defcard("Nero Severn: Information Broker", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Once per turn → When you encounter a <strong>sentry</strong>, you may jack out.",
			"code": "10040",
			"title": "Nero Severn: Information Broker",
		})

	NRCardDefs.defcard("New Angeles Sol: Your News", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever an agenda is scored or stolen, you may play 1 <strong>current</strong> from HQ or Archives (paying its play cost).",
			"code": "09002",
			"title": "New Angeles Sol: Your News",
		})

	NRCardDefs.defcard("NEXT Design: Guarding the Net", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 12,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Before taking your first turn, you may install up to 3 pieces of ice, with no more than a single piece of ice per server. Draw until you have 5 cards in HQ.",
			"code": "03003",
			"title": "NEXT Design: Guarding the Net",
		})

	NRCardDefs.defcard("Nisei Division: The Next Generation", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever you and the Runner reveal secretly spent credits, gain 1[Credits].",
			"code": "05002",
			"title": "Nisei Division: The Next Generation",
		})

	NRCardDefs.defcard("Noise: Hacker Extraordinaire", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "Whenever you install a <strong>virus</strong> program, the Corp trashes the top card of R&D.",
			"code": "01001",
			"title": "Noise: Hacker Extraordinaire",
		})

	NRCardDefs.defcard("Null: Whistleblower", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Once per turn → When you encounter a piece of ice, you may trash 1 card from your grip. If you do, that ice gets –2 strength for the remainder of this run.",
			"code": "11002",
			"title": "Null: Whistleblower",
		})

	NRCardDefs.defcard("Nuvem SA: Law of the Land", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 50,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "Whenever you finish resolving an operation or an action on an <strong>expendable</strong> card, look at the top card of R&D. You may trash that card.\nThe first time you trash a card from R&D during each of your turns, gain 2[Credits].",
			"code": "34121",
			"title": "Nuvem SA: Law of the Land",
		})

	NRCardDefs.defcard("Nyusha \"Sable\" Sintashta: Symphonic Prodigy", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "When your turn begins, identify your mark. <em>(If you don’t have a mark, a random central server becomes your mark for this turn.)</em>\nThe first time each turn you make a successful run on your mark, gain [Click].",
			"code": "33011",
			"title": "Nyusha \"Sable\" Sintashta: Symphonic Prodigy",
		})

	NRCardDefs.defcard("Ob Superheavy Logistics: Extract. Export. Excel.", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "Once per turn → When you trash a rezzed card, except during installation, you may search R&D for 1 card with a printed rez cost exactly 1[Credits] less than the trashed card's printed rez cost. Install and rez the card you found, ignoring credit costs.",
			"code": "33057",
			"title": "Ob Superheavy Logistics: Extract. Export. Excel.",
		})

	NRCardDefs.defcard("Omar Keung: Conspiracy Theorist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 12,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Once per turn → [Click]<strong>:</strong> Run Archives. If that run would be declared successful, change the attacked server to HQ or R&D for the remainder of that run.",
			"code": "11043",
			"title": "Omar Keung: Conspiracy Theorist",
		})

	NRCardDefs.defcard("Nova Initiumia: Catalyst & Impetus", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Neutral",
			"baselink": 0,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Digital - Natural",
			"subtypes": ["Digital", "Natural"],
			"text": "Your deck cannot include more than 1 copy of any card.",
			"code": "33093",
			"title": "Nova Initiumia: Catalyst & Impetus",
		})

	NRCardDefs.defcard("Pālanā Foods: Sustainable Growth", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn the Runner draws a card, gain 1[Credits].",
			"code": "10030",
			"title": "Pālanā Foods: Sustainable Growth",
		})

	NRCardDefs.defcard("Poétrï Luxury Brands: All the Rage", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever you score an agenda, look at the top 3 cards of R&D. You may install 1 non-agenda card from among them.\nWhenever an agenda is stolen, you may install 1 non-agenda card from HQ.",
			"code": "35036",
			"title": "Poétrï Luxury Brands: All the Rage",
		})

	NRCardDefs.defcard("Pravdivost Consulting: Political Solutions", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn the Runner makes a successful run, you may place 1 advancement counter on an installed card you can advance.",
			"code": "33048",
			"title": "Pravdivost Consulting: Political Solutions",
		})

	NRCardDefs.defcard("PT Untaian: Life's Building Blocks", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "When your discard phase ends, if there are 3 or fewer cards in HQ, you may pay 1[Credits] to place 1 advancement counter on an unrezzed card you can advance. <em>(You cannot score that card this turn.)</em>",
			"code": "35047",
			"title": "PT Untaian: Life's Building Blocks",
		})

	NRCardDefs.defcard("Quetzal: Free Spirit", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "Once per turn → <strong>0[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.",
			"code": "31001",
			"title": "Quetzal: Free Spirit",
		})

	NRCardDefs.defcard("Reina Roja: Freedom Fighter", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 1,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg - G-mod",
			"subtypes": ["Cyborg", "G-mod"],
			"text": "The first piece of ice the Corp rezzes each turn costs 1[Credits] more to rez.",
			"code": "31002",
			"title": "Reina Roja: Freedom Fighter",
		})

	NRCardDefs.defcard("René \"Loup\" Arcemont: Party Animal", {
			"title": "René \"Loup\" Arcemont: Party Animal",
		})

	NRCardDefs.defcard("Rielle \"Kit\" Peddler: Transhuman", {
			"title": "Rielle \"Kit\" Peddler: Transhuman",
		})

	NRCardDefs.defcard("Ryō \"Phoenix\" Ōno: Out of the Ashes", {
			"title": "Ryō \"Phoenix\" Ōno: Out of the Ashes",
		})

	NRCardDefs.defcard("Saraswati Mnemonics: Endless Exploration", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "<strong>[Click]</strong>, <strong>1[Credits]:</strong> Install 1 card from HQ in the root of a remote server, then place 1 advancement counter on it. You cannot score or rez that card until your next turn begins.",
			"code": "22034",
			"title": "Saraswati Mnemonics: Endless Exploration",
		})

	NRCardDefs.defcard("Sebastião Souza Pessoa: Activist Organizer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "Whenever you take 1 or more tags, if you had no tags, you may install 1 <strong>connection</strong> resource from your grip, paying 2[Credits] less.\nAs an additional cost to trash a <strong>connection</strong> resource with the basic action, the Corp must trash 1 card from HQ.",
			"code": "34066",
			"title": "Sebastião Souza Pessoa: Activist Organizer",
		})

	NRCardDefs.defcard("Seidr Laboratories: Destiny Defined", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn the Runner loses or spends [Click] during a run, you may add 1 card from Archives to the top of R&D.",
			"code": "25067",
			"title": "Seidr Laboratories: Destiny Defined",
		})

	NRCardDefs.defcard("Silhouette: Stealth Operative", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "The first time you make a successful run on HQ each turn, you may expose 1 card.",
			"code": "05030",
			"title": "Silhouette: Stealth Operative",
		})

	NRCardDefs.defcard("Skorpios Defense Systems: Persuasive Power", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Subsidiary",
			"subtypes": ["Subsidiary"],
			"text": "[interrupt] → Whenever 1 or more Runner cards would be trashed <em>(from any location)</em>, set those cards aside instead of adding them to the heap. You can look at those cards. You may remove 1 of them from the game. Then, add all of those cards that are still set aside to the heap. Ignore this ability if you have already removed a card from the game with it this turn.",
			"code": "13041",
			"title": "Skorpios Defense Systems: Persuasive Power",
		})

	NRCardDefs.defcard("Spark Agency: Worldswide Reach", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn you rez an <strong>advertisement</strong>, the Runner loses 1[Credits].",
			"code": "25105",
			"title": "Spark Agency: Worldswide Reach",
		})

	NRCardDefs.defcard("Sportsmetal: Go Big or Go Home", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Subsidiary",
			"subtypes": ["Subsidiary"],
			"text": "Whenever an agenda is scored or stolen, gain 2[Credits] or draw 2 cards.",
			"code": "22026",
			"title": "Sportsmetal: Go Big or Go Home",
		})

	NRCardDefs.defcard("SSO Industries: Fueling Innovation", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "When your turn ends, you may choose a piece of ice with no advancement tokens on it. If you do, place 1 advancement token on that piece of ice for each agenda point on all installed faceup agendas.",
			"code": "21077",
			"title": "SSO Industries: Fueling Innovation",
		})

	NRCardDefs.defcard("Steve Cambridge: Master Grifter", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "The first time each turn you make a successful run on HQ, you may choose 2 cards in your heap. If you do, the Corp removes 1 of those cards from the game, then you add the other card to your grip.",
			"code": "31014",
			"title": "Steve Cambridge: Master Grifter",
		})

	NRCardDefs.defcard("Strategic Innovations: Future Forward", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Draft format only.\nIf you have more [haas-bioroid] cards rezzed than any other faction, when the Runner's turn ends, shuffle 1 card in Archives into R&D.",
			"code": "00010",
			"title": "Strategic Innovations: Future Forward",
		})

	NRCardDefs.defcard("Sunny Lebeau: Security Specialist", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"baselink": 2,
			"influencelimit": 25,
			"minimumdecksize": 50,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"code": "09045",
			"title": "Sunny Lebeau: Security Specialist",
		})

	NRCardDefs.defcard("SYNC: Everything, Everywhere", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "[Click]: Flip this identity.\nThe Runner pays 1[Credits] more when spending a [Click] to remove a tag (not through a card ability).\nFlip side:\n[Click]: Flip this identity.\nYou may pay 2[Credits] fewer when spending a [Click] to trash a resource (not through a card ability).",
			"code": "09001",
			"title": "SYNC: Everything, Everywhere",
		})

	NRCardDefs.defcard("Synapse Global: Faster than Thought", {
			"type": "Identity",
			"side": "Corp",
			"faction": "NBN",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time each turn a tag is removed, you may reveal and install 1 card from HQ, ignoring all costs.\n[Click], <strong>remove 1 tag:</strong> Gain 2[Credits].",
			"code": "35058",
			"title": "Synapse Global: Faster than Thought",
		})

	NRCardDefs.defcard("Synthetic Systems: The World Re-imagined", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Draft format only.\nIf you have more [jinteki] cards rezzed than any other faction, when your turn begins, you may swap 2 pieces of installed ice.",
			"code": "00011",
			"title": "Synthetic Systems: The World Re-imagined",
		})

	NRCardDefs.defcard("Tāo Salonga: Telepresence Magician", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Whenever an agenda is scored or stolen, you may swap 2 installed pieces of ice.",
			"code": "30019",
			"title": "Tāo Salonga: Telepresence Magician",
		})

	NRCardDefs.defcard("Tennin Institute: The Secrets Within", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Jinteki",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "When your turn begins, if the Runner did not make a successful run during their last turn, you may place 1 advancement counter on an installed card.",
			"code": "05003",
			"title": "Tennin Institute: The Secrets Within",
		})

	NRCardDefs.defcard("The Catalyst: Convention Breaker", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Neutral",
			"baselink": 0,
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Starter game only.",
			"code": "30076",
			"title": "The Catalyst: Convention Breaker",
		})

	NRCardDefs.defcard("The Collective: Williams, Wu, et al.", {
			"title": "The Collective: Williams, Wu, et al.",
		})

	NRCardDefs.defcard("The Foundry: Refining the Process", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "The first time you rez a piece of ice each turn, you may search R&D for another copy of that ice, reveal it, and add it to HQ. Shuffle R&D.",
			"code": "06021",
			"title": "The Foundry: Refining the Process",
		})

	NRCardDefs.defcard("The Masque: Cyber General", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Neutral",
			"baselink": 0,
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Draft format only.",
			"code": "00006",
			"title": "The Masque: Cyber General",
		})

	NRCardDefs.defcard("The Outfit: Family Owned and Operated", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Subsidiary",
			"subtypes": ["Subsidiary"],
			"text": "Whenever you take 1 or more bad publicity, gain 3[Credits].",
			"code": "22050",
			"title": "The Outfit: Family Owned and Operated",
		})

	NRCardDefs.defcard("The Professor: Keeper of Knowledge", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Shaper",
			"baselink": 0,
			"influencelimit": 1,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "The first copy of each program in this deck does not count against your influence limit.",
			"code": "03029",
			"title": "The Professor: Keeper of Knowledge",
		})

	NRCardDefs.defcard("The Shadow: Pulling the Strings", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Neutral",
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Draft format only.\nYou can use agendas from all factions in this deck.",
			"code": "00005",
			"title": "The Shadow: Pulling the Strings",
		})

	NRCardDefs.defcard("The Syndicate: Profit over Principle", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Neutral",
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Starter game only.",
			"code": "30077",
			"title": "The Syndicate: Profit over Principle",
		})

	NRCardDefs.defcard("The Zwicky Group: Invisible Hands", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Unsubstantiated",
			"subtypes": ["Unsubstantiated"],
			"text": "The first time each turn you gain credits through an ability on an agenda or operation, you may draw 1 card.",
			"code": "35069",
			"title": "The Zwicky Group: Invisible Hands",
		})

	NRCardDefs.defcard("Thule Subsea: Safety Below", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever the Runner steals an agenda, do 1 core damage unless they spend [Click] and 2[Credits].",
			"code": "33095",
			"title": "Thule Subsea: Safety Below",
		})

	NRCardDefs.defcard("Thunderbolt Armaments: Peace Through Power", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Division",
			"subtypes": ["Division"],
			"text": "Whenever you rez a piece of <strong>AP</strong> or <strong>destroyer</strong> ice during a run, that ice gets +1 strength and gains “[subroutine] End the run unless the Runner trashes 1 of their installed cards.” after its other subroutines for the remainder of that run.",
			"code": "34096",
			"title": "Thunderbolt Armaments: Peace Through Power",
		})

	NRCardDefs.defcard("Titan Transnational: Investing In Your Future", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 17,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Corp",
			"subtypes": ["Corp"],
			"text": "Whenever you score an agenda, you may place 1 agenda counter on it.",
			"code": "07003",
			"title": "Titan Transnational: Investing In Your Future",
		})

	NRCardDefs.defcard("Topan: Ormas Leader", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "Once per turn → [Click]<strong>:</strong> Install 1 card from your grip, paying 2[Credits] less. When you install that card, suffer 1 meat damage.",
			"code": "35002",
			"title": "Topan: Ormas Leader",
		})

	NRCardDefs.defcard("Valencia Estevez: The Angel of Cayambe", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 50,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "The Corp starts the game with 1 bad publicity.",
			"code": "07030",
			"title": "Valencia Estevez: The Angel of Cayambe",
		})

	NRCardDefs.defcard("Virtual Intelligence, P.I.: \"You Can Call Me Vic\"", {
			"title": "Virtual Intelligence, P.I.: \"You Can Call Me Vic\"",
		})

	NRCardDefs.defcard("Weyland Consortium: Because We Built It", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "1[recurring-credit]\nUse this credit to advance ice.",
			"code": "02076",
			"title": "Weyland Consortium: Because We Built It",
		})

	NRCardDefs.defcard("Weyland Consortium: Builder of Nations", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 12,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "The first time each turn an encounter with an advanced piece of ice ends, do 1 meat damage.",
			"code": "11038",
			"title": "Weyland Consortium: Builder of Nations",
		})

	NRCardDefs.defcard("Weyland Consortium: Building a Better World", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Whenever you play a <strong>transaction</strong> operation, gain 1[Credits].",
			"code": "31070",
			"title": "Weyland Consortium: Building a Better World",
		})

	NRCardDefs.defcard("Weyland Consortium: Built to Last", {
			"type": "Identity",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Megacorp",
			"subtypes": ["Megacorp"],
			"text": "Whenever you advance a card, gain 2[Credits] if it had no advancement counters.",
			"code": "30059",
			"title": "Weyland Consortium: Built to Last",
		})

	NRCardDefs.defcard("Whizzard: Master Gamer", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 45,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Natural",
			"subtypes": ["Natural"],
			"text": "3[recurring-credit]\nUse these credits to trash cards.",
			"code": "02001",
			"title": "Whizzard: Master Gamer",
		})

	NRCardDefs.defcard("Wyvern: Chemically Enhanced", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Anarch",
			"baselink": 0,
			"minimumdecksize": 30,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "G-mod",
			"subtypes": ["G-mod"],
			"text": "Draft format only.\nYou must maintain the order of your heap.\nWhenever you trash a Corp card, if you have more [anarch] cards installed than any other faction, shuffle the top card of your heap into your stack.",
			"code": "00007",
			"title": "Wyvern: Chemically Enhanced",
		})

	NRCardDefs.defcard("Zahya Sadeghi: Versatile Smuggler", {
			"type": "Identity",
			"side": "Runner",
			"faction": "Criminal",
			"baselink": 0,
			"influencelimit": 15,
			"minimumdecksize": 40,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Cyborg",
			"subtypes": ["Cyborg"],
			"text": "Once per turn → When a run on HQ or R&D ends, you may gain 1[Credits] for each time you accessed a card during that run.",
			"code": "30010",
			"title": "Zahya Sadeghi: Versatile Smuggler",
		})
