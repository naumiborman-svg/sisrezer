class_name NRCardsOperations
extends RefCounted

## Printed card data from game.cards.operations (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("24/7 News Cycle", {
			"title": "24/7 News Cycle",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"text": "As an additional cost to play 24/7 News Cycle, forfeit an agenda.\nResolve the \"when scored\" ability on an agenda in your score area."
		})

	NRCardDefs.defcard("Accelerated Diagnostics", {
			"title": "Accelerated Diagnostics",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"text": "Look at the top 3 cards of R&D. If any of those cards are operations, you may play them (paying their play cost), ignoring any additional costs. Trash the rest of the unplayed cards you looked at."
		})

	NRCardDefs.defcard("Active Policing", {
			"title": "Active Policing",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"keywords": "Terminal - Gray Ops",
			"subtypes": ["Terminal", "Gray Ops"],
			"text": "Play only if the Runner stole or trashed a Corp card during their last turn.\nAfter you resolve this operation, your action phase ends.\nYou may install 1 card from HQ. The Runner gets −1 allotted [click] for their next turn.\nThreat 3 → You may pay 2[credit]. If you do, the Runner gets −1 allotted [click] for their next turn. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
		})

	NRCardDefs.defcard("Ad Blitz", {
			"title": "Ad Blitz",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"factioncost": 1,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nInstall and rez (paying all costs) X <strong>advertisements</strong> from Archives and/or HQ, if able."
		})

	NRCardDefs.defcard("Aggressive Negotiation", {
			"title": "Aggressive Negotiation",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"text": "Play only if you scored an agenda this turn.\nSearch R&D for 1 card and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("An Offer You Can't Refuse", {
			"title": "An Offer You Can't Refuse",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 3,
			"text": "Choose a central server. The Runner may run that server. They cannot jack out during that run. If no run is made this way, add this operation to your score area as an agenda worth 1 agenda point."
		})

	NRCardDefs.defcard("Anonymous Tip", {
			"title": "Anonymous Tip",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Draw 3 cards."
		})

	NRCardDefs.defcard("Archived Memories", {
			"title": "Archived Memories",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"text": "Add 1 card from Archives to HQ."
		})

	NRCardDefs.defcard("Argus Crackdown", {
			"title": "Argus Crackdown",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Lockdown - Gray Ops",
			"subtypes": ["Lockdown", "Gray Ops"],
			"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nWhenever the Runner makes a successful run on a server protected by ice, do 2 meat damage."
		})

	NRCardDefs.defcard("Ark Lockdown", {
			"title": "Ark Lockdown",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"text": "Name a card. Remove all copies of that card in the heap from the game."
		})

	NRCardDefs.defcard("Armed Asset Protection", {
			"title": "Armed Asset Protection",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 3[credit]. Gain 1[credit] for each card type among faceup cards in Archives. If any of those cards are agendas, gain another 2[credit]."
		})

	NRCardDefs.defcard("Attitude Adjustment", {
			"title": "Attitude Adjustment",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"text": "Draw 2 cards. Reveal up to 2 agendas in HQ and/or Archives. Gain 2[credit] for each agenda revealed, then shuffle those agendas into R&D."
		})

	NRCardDefs.defcard("Audacity", {
			"title": "Audacity",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 4,
			"text": "Play only if there are at least 2 other cards in HQ.\nTrash all cards from HQ. Place a total of 2 advancement counters on installed cards you can advance."
		})

	NRCardDefs.defcard("Back Channels", {
			"title": "Back Channels",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Choose 1 card in the root of a remote server. Gain 3[credit] for each advancement counter on that card, then trash it."
		})

	NRCardDefs.defcard("Backroom Machinations", {
			"title": "Backroom Machinations",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "As an additional cost to play this operation, remove 1 tag.\nAdd this operation to your score area as an agenda worth 1 agenda point."
		})

	NRCardDefs.defcard("Bad Times", {
			"title": "Bad Times",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 0,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nThe Runner's memory limit is reduced by 2 until the end of the turn."
		})

	NRCardDefs.defcard("Beanstalk Royalties", {
			"title": "Beanstalk Royalties",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 3[credit]."
		})

	NRCardDefs.defcard("Best Defense", {
			"title": "Best Defense",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 0,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Trash 1 installed card with an install cost equal to or less than the number of tags the Runner has."
		})

	NRCardDefs.defcard("Biased Reporting", {
			"title": "Biased Reporting",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"text": "Choose resource, hardware, or program. The Runner may trash any of their installed cards of the chosen type and gain 1[credit] for each card trashed this way. Gain 2[credit] for each card of the chosen type that is still installed."
		})

	NRCardDefs.defcard("Big Brother", {
			"title": "Big Brother",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nGive the Runner 2 tags."
		})

	NRCardDefs.defcard("Big Deal", {
			"title": "Big Deal",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 17,
			"trash": 3,
			"factioncost": 5,
			"keywords": "Terminal",
			"subtypes": ["Terminal"],
			"text": "After you resolve this operation, your action phase ends.\nPlace 4 advancement counters on 1 installed card. You may score that card, if able.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Bigger Picture", {
			"title": "Bigger Picture",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nResolve 1 of the following:<ul><li>Give the Runner 1 tag.</li><li>Remove any number of tags. The Runner loses 5[credit] for each tag removed this way. Gain credits equal to the number of credits the Runner lost.</li></ul>"
		})

	NRCardDefs.defcard("Bioroid Efficiency Research", {
			"title": "Bioroid Efficiency Research",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Rez a piece of <strong>bioroid</strong> ice, ignoring all costs, and install Bioroid Efficiency Research on that ice as a hosted condition counter with the text \"Trash Bioroid Efficiency Research and derez host ice if all of its subroutines are broken during a single encounter.\""
		})

	NRCardDefs.defcard("Biotic Labor", {
			"title": "Biotic Labor",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 4,
			"text": "Gain [click][click]."
		})

	NRCardDefs.defcard("Blue Level Clearance", {
			"title": "Blue Level Clearance",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Double - Transaction",
			"subtypes": ["Double", "Transaction"],
			"text": "As an additional cost to play this operation, spend [click].\nGain 5[credit] and draw 2 cards."
		})

	NRCardDefs.defcard("BOOM!", {
			"title": "BOOM!",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"trash": 1,
			"factioncost": 3,
			"keywords": "Double - Black Ops",
			"subtypes": ["Double", "Black Ops"],
			"text": "Play only if the Runner has at least 2 tags.\nAs an additional cost to play this operation, spend [click].\nDo 7 meat damage."
		})

	NRCardDefs.defcard("Bring Them Home", {
			"title": "Bring Them Home",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Terminal - Black Ops",
			"subtypes": ["Terminal", "Black Ops"],
			"text": "Play only if the Runner stole or trashed a Corp card during their last turn.\nAfter you resolve this operation, your action phase ends.\nReveal and add 2 cards at random from the grip to the top of the stack.\nThreat 3 → You may pay 2[credit] to reveal 1 card in the grip at random. The Runner shuffles it into the stack."
		})

	NRCardDefs.defcard("Building Blocks", {
			"title": "Building Blocks",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 4,
			"text": "Reveal a <strong>barrier</strong> from HQ. Install and rez it, ignoring all costs."
		})

	NRCardDefs.defcard("Business As Usual", {
			"title": "Business As Usual",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Resolve 1 of the following:<ul><li>Place 1 advancement counter on each of up to 2 installed cards you can advance.</li><li>Remove all virus counters from 1 installed card.</li></ul>\nThreat 3 → You may also resolve the other mode. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
		})

	NRCardDefs.defcard("Casting Call", {
			"title": "Casting Call",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Install 1 agenda from HQ faceup and host this operation on that agenda as a condition counter with \"Whenever the Runner accesses host agenda, they take 2 tags.\""
		})

	NRCardDefs.defcard("Caveat Emptor", {
			"title": "Caveat Emptor",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 3,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Resolve 1 of the following:\n<ul><li>Gain 6[credit]. The Runner gets −1 allotted [click] for their next turn.</li><li>Gain 10[credit]. The Runner gets +1 allotted [click] for their next turn.</li></ul>"
		})

	NRCardDefs.defcard("Cultivate", {
			"title": "Cultivate",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Look at the top 5 cards of R&D. Trash 1 of those cards, add 1 of them to HQ, and arrange the rest in any order."
		})

	NRCardDefs.defcard("Celebrity Gift", {
			"title": "Celebrity Gift",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nReveal up to 5 cards in HQ. Gain 2[credit] for each card you revealed this way."
		})

	NRCardDefs.defcard("Cerebral Cast", {
			"title": "Cerebral Cast",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Gray Ops - Psi",
			"subtypes": ["Gray Ops", "Psi"],
			"text": "Play only if the Runner made a successful run during their last turn.\nYou and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, they must suffer 1 core damage or take 1 tag."
		})

	NRCardDefs.defcard("Cerebral Static", {
			"title": "Cerebral Static",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner's identity loses its printed abilities."
		})

	NRCardDefs.defcard("\"Clones are not People\"", {
			"title": "\"Clones are not People\"",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhen you score an agenda, add \"Clones are not People\" to your score area as an agenda worth 1 agenda point."
		})

	NRCardDefs.defcard("Closed Accounts", {
			"title": "Closed Accounts",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nThe Runner loses all credits in their credit pool."
		})

	NRCardDefs.defcard("Commercialization", {
			"title": "Commercialization",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Choose a piece of ice. Gain 1[credit] for each advancement token on that ice."
		})

	NRCardDefs.defcard("Complete Image", {
			"title": "Complete Image",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"trash": 2,
			"factioncost": 4,
			"keywords": "Terminal - Gray Ops",
			"subtypes": ["Terminal", "Gray Ops"],
			"text": "Play only if the Runner has 3 or more agenda points and they made a successful run during their last turn.\nAfter you resolve this operation, your action phase ends.\nChoose a card name, then do 1 net damage. If you trash a card with the chosen name this way, repeat this process."
		})

	NRCardDefs.defcard("Consulting Visit", {
			"title": "Consulting Visit",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Alliance - Double",
			"subtypes": ["Alliance", "Double"],
			"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [weyland-consortium] cards in your deck.\nAs an additional cost to play this operation, spend [click].\nSearch R&D for an operation and play it (paying all costs). Shuffle R&D."
		})

	NRCardDefs.defcard("Corporate Hospitality", {
			"title": "Corporate Hospitality",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Double - Transaction",
			"subtypes": ["Double", "Transaction"],
			"text": "As an additional cost to play this operation, spend [click].\nGain 6[credit] and draw 2 cards. Add 1 card from Archives to HQ."
		})

	NRCardDefs.defcard("Corporate Shuffle", {
			"title": "Corporate Shuffle",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nShuffle all cards in HQ into R&D. Draw 5 cards."
		})

	NRCardDefs.defcard("Cyberdex Trial", {
			"title": "Cyberdex Trial",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"text": "Purge virus counters."
		})

	NRCardDefs.defcard("Death and Taxes", {
			"title": "Death and Taxes",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Current - Transaction",
			"subtypes": ["Current", "Transaction"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhenever the Runner installs a card or trashes an installed card, you may gain 1[credit]."
		})

	NRCardDefs.defcard("Dedication Ceremony", {
			"title": "Dedication Ceremony",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"text": "Place 3 advancement tokens on a faceup card. You cannot score that card until your next turn begins."
		})

	NRCardDefs.defcard("Defective Brainchips", {
			"title": "Defective Brainchips",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 1,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\n[interrupt] → The first time each turn the Runner would suffer core damage, increase that damage by 1."
		})

	NRCardDefs.defcard("Digital Rights Management", {
			"title": "Digital Rights Management",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"text": "Play only if the Runner did not make a successful run on HQ during their last turn.\nSearch R&D for 1 agenda and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that agenda to HQ. You may install 1 card from HQ in the root of a remote server.\nYou cannot score agendas for the remainder of the turn."
		})

	NRCardDefs.defcard("Distract the Masses", {
			"title": "Distract the Masses",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"text": "The Runner gains 2[credit]. Trash up to 2 cards from HQ, then shuffle up to 2 cards from Archives into R&D. Remove Distract the Masses from the game instead of trashing it."
		})

	NRCardDefs.defcard("Distributed Tracing", {
			"title": "Distributed Tracing",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 4,
			"keywords": "Double - Gray Ops",
			"subtypes": ["Double", "Gray Ops"],
			"text": "As an additional cost to play this operation, spend [click].\nPlay only if the Runner stole an agenda during their last turn.\nGive the Runner 1 tag."
		})

	NRCardDefs.defcard("Diversified Portfolio", {
			"title": "Diversified Portfolio",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 0,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 1[credit] for each remote server with a card in its root."
		})

	NRCardDefs.defcard("Divert Power", {
			"title": "Divert Power",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 1,
			"text": "Derez any number of cards. You may rez a card, lowering its rez cost by 3 for each card that you derezzed this way."
		})

	NRCardDefs.defcard("Door to Door", {
			"title": "Door to Door",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Current - Black Ops",
			"subtypes": ["Current", "Black Ops"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhen the Runner's turn begins, Trace[1]. If successful, do 1 meat damage if the Runner is tagged; otherwise, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Eavesdrop", {
			"title": "Eavesdrop",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Gray Ops - Condition",
			"subtypes": ["Gray Ops", "Condition"],
			"text": "Install Eavesdrop on a piece of ice as a hosted condition counter with the text \"Whenever the Runner encounters host ice, Trace[3]. If successful, give the Runner 1 tag.\""
		})

	NRCardDefs.defcard("Economic Warfare", {
			"title": "Economic Warfare",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner made a successful run during their last turn.\nIf the Runner has at least 4[credit], they lose 4[credit]."
		})

	NRCardDefs.defcard("Election Day", {
			"title": "Election Day",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"text": "Trash all cards in HQ (minimum of 1). Draw 5 cards."
		})

	NRCardDefs.defcard("End of the Line", {
			"title": "End of the Line",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 4,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "As an additional cost to play this operation, remove 1 tag.\nDo 4 meat damage."
		})

	NRCardDefs.defcard("Enforced Curfew", {
			"title": "Enforced Curfew",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner's maximum hand size is reduced by 1."
		})

	NRCardDefs.defcard("Enforcing Loyalty", {
			"title": "Enforcing Loyalty",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"trash": 1,
			"factioncost": 1,
			"keywords": "Double - Gray Ops",
			"subtypes": ["Double", "Gray Ops"],
			"text": "As an additional cost to play this operation, spend [click].\nTrace[3]. If successful, trash an installed card that does not match the faction of the Runner's identity."
		})

	NRCardDefs.defcard("Enhanced Login Protocol", {
			"title": "Enhanced Login Protocol",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAs an additional cost to take the basic action to run a server for the first time each turn, the Runner must spend [click]."
		})

	NRCardDefs.defcard("Exchange of Information", {
			"title": "Exchange of Information",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nSwap an agenda in your score area with an agenda in the Runner's score area."
		})

	NRCardDefs.defcard("Extract", {
			"title": "Extract",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 6[credit]. You may trash 1 of your installed cards to gain 3[credit]."
		})

	NRCardDefs.defcard("Fast Break", {
			"title": "Fast Break",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 3,
			"text": "Gain X[credit]. Draw up to X cards. Install up to X cards in the root of and/or protecting a single remote server. X is equal to the number of agendas in the Runner's score area."
		})

	NRCardDefs.defcard("Fast Track", {
			"title": "Fast Track",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"text": "Search R&D for an agenda, reveal it, and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Financial Collapse", {
			"title": "Financial Collapse",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"text": "Play only if the Runner has at least 6[credit].\nThe Runner loses 2[credit] for each installed resource. The Runner can trash a resource to prevent this."
		})

	NRCardDefs.defcard("Flood the Market", {
			"title": "Flood the Market",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nChoose 1 installed card you can advance. Place 1 advancement counter on that card for each remote server that has a card in its root and is protected by ice."
		})

	NRCardDefs.defcard("Focus Group", {
			"title": "Focus Group",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"text": "Play only if the Runner made a successful run during their last turn.\nChoose a card type, then reveal the grip. Choose a value for X equal to or less than the number of revealed cards of the chosen type. You may pay X[credit] to place X advancement counters on 1 installed card."
		})

	NRCardDefs.defcard("Foxfire", {
			"title": "Foxfire",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"text": "Trace[7]. If successful, trash 1 <strong>virtual</strong> resource or 1 <strong>link</strong>."
		})

	NRCardDefs.defcard("Freelancer", {
			"title": "Freelancer",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nTrash up to 2 resources."
		})

	NRCardDefs.defcard("Friends in High Places", {
			"title": "Friends in High Places",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 1,
			"keywords": "Terminal",
			"subtypes": ["Terminal"],
			"text": "After you resolve this operation, end your action phase.\nInstall up to 2 cards from Archives (paying all install costs)."
		})

	NRCardDefs.defcard("Fully Operational", {
			"title": "Fully Operational",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"text": "Gain 2[credit] or draw 2 cards. Repeat this process for each remote server that has a card in its root and is protected by ice."
		})

	NRCardDefs.defcard("Game Changer", {
			"title": "Game Changer",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"trash": 2,
			"factioncost": 5,
			"text": "Gain [click] for each agenda in the Runner's score area. Remove Game Changer from the game instead of trashing it."
		})

	NRCardDefs.defcard("Game Over", {
			"title": "Game Over",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 3,
			"keywords": "Gray Ops - Liability",
			"subtypes": ["Gray Ops", "Liability"],
			"text": "Play only if the Runner stole an agenda during their last turn.\nChoose a Runner card type. Trash all installed non-<strong>icebreaker</strong> cards of the chosen type. For each card that would be trashed this way, the Runner may pay 3[credit] to prevent that card from being trashed.\nTake 1 bad publicity."
		})

	NRCardDefs.defcard("Genotyping", {
			"title": "Genotyping",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"text": "Trash the top 2 cards of R&D, then shuffle up to 4 cards from Archives into R&D. Remove Genotyping from the game instead of trashing it."
		})

	NRCardDefs.defcard("Government Subsidy", {
			"title": "Government Subsidy",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 10,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 15[credit]."
		})

	NRCardDefs.defcard("Greasing the Palm", {
			"title": "Greasing the Palm",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 5[credit]. You may install 1 card from HQ. You may remove 1 tag to place 1 advancement counter on that card."
		})

	NRCardDefs.defcard("Green Level Clearance", {
			"title": "Green Level Clearance",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 3[credit] and draw 1 card."
		})

	NRCardDefs.defcard("Hangeki", {
			"title": "Hangeki",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Reprisal - Gray Ops",
			"subtypes": ["Reprisal", "Gray Ops"],
			"text": "Play only if the Runner trashed a Corp card during their last turn and you have at least 1 installed card.\nChoose 1 of your installed cards. The Runner may access that card. If they do, remove this operation from the game; otherwise, add this operation to the Runner's score area as an agenda worth -1 agenda point."
		})

	NRCardDefs.defcard("Hansei Review", {
			"title": "Hansei Review",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 10[credit]. If there are any cards in HQ, trash 1 of them."
		})

	NRCardDefs.defcard("Hard-Hitting News", {
			"title": "Hard-Hitting News",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Terminal",
			"subtypes": ["Terminal"],
			"text": "After you resolve this operation, your action phase ends.\nPlay only if the Runner made a run during their last turn.\nTrace[4]. If successful, give the Runner 4 tags."
		})

	NRCardDefs.defcard("Hasty Relocation", {
			"title": "Hasty Relocation",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"text": "As an additional cost to play this operation, trash the top card of R&D.\nDraw 3 cards. Add 3 cards from HQ to the top of R&D in any order."
		})

	NRCardDefs.defcard("Hatchet Job", {
			"title": "Hatchet Job",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"trash": 0,
			"factioncost": 2,
			"keywords": "Double - Gray Ops",
			"subtypes": ["Double", "Gray Ops"],
			"text": "As an additional cost to play this operation, spend [click].\nTrace[5]. If successful, add an installed non-<strong>virtual</strong> card to the Runner's grip."
		})

	NRCardDefs.defcard("Hedge Fund", {
			"title": "Hedge Fund",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 0,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 9[credit]."
		})

	NRCardDefs.defcard("Hellion Alpha Test", {
			"title": "Hellion Alpha Test",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Black Ops - Liability",
			"subtypes": ["Black Ops", "Liability"],
			"text": "Play only if the Runner installed a resource during their last turn.\nTrace[2]. If successful, add 1 installed resource to the top of the stack. If unsuccessful, take 1 bad publicity."
		})

	NRCardDefs.defcard("Hellion Beta Test", {
			"title": "Hellion Beta Test",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Black Ops - Liability",
			"subtypes": ["Black Ops", "Liability"],
			"text": "Play only if the Runner trashed a card while accessing it during their last turn.\nTrace[2]. If successful, trash 2 installed non-program cards. If unsuccessful, take 1 bad publicity."
		})

	NRCardDefs.defcard("Heritage Committee", {
			"title": "Heritage Committee",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Alliance",
			"subtypes": ["Alliance"],
			"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [jinteki] cards in your deck.\nDraw 3 cards. Add 1 card from HQ to the top of R&D."
		})

	NRCardDefs.defcard("High-Profile Target", {
			"title": "High-Profile Target",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 5,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "Play only if the Runner is tagged.\nDo 2 meat damage for each tag the Runner has."
		})

	NRCardDefs.defcard("Housekeeping", {
			"title": "Housekeeping",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Current - Gray Ops",
			"subtypes": ["Current", "Gray Ops"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe first time each turn the Runner installs a card, they trash 1 card from the grip."
		})

	NRCardDefs.defcard("Hunter Seeker", {
			"title": "Hunter Seeker",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Double - Gray Ops",
			"subtypes": ["Double", "Gray Ops"],
			"text": "As an additional cost to play this operation, spend [click].\nPlay only if the Runner stole an agenda during their last turn.\nTrash 1 installed card."
		})

	NRCardDefs.defcard("Hyoubu Precog Manifold", {
			"title": "Hyoubu Precog Manifold",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Lockdown - Psi",
			"subtypes": ["Lockdown", "Psi"],
			"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nWhen you play this operation, choose a server.\nWhenever the Runner makes a successful run on the chosen server, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, end the run."
		})

	NRCardDefs.defcard("Hypoxia", {
			"title": "Hypoxia",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "Play only if the Runner is tagged.\nDo 1 core damage. The Runner gets -1 allotted [click] for their next turn.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Interns", {
			"title": "Interns",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nInstall a non-operation card from Archives or HQ, ignoring the install cost."
		})

	NRCardDefs.defcard("Invasion of Privacy", {
			"title": "Invasion of Privacy",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Double - Gray Ops - Liability",
			"subtypes": ["Double", "Gray Ops", "Liability"],
			"text": "As an additional cost to play this operation, spend [click].\nTrace[2]. If successful, reveal the grip. Trash up to X resources and/or events revealed this way, where X is equal to the amount by which your trace strength exceeded the Runner's link strength. If unsuccessful, take 1 bad publicity."
		})

	NRCardDefs.defcard("IP Enforcement", {
			"title": "IP Enforcement",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"trash": 5,
			"factioncost": 5,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "As an additional cost to play this operation, remove X tags.\nInstall 1 agenda from the Runner’s score area with a printed agenda point value equal to X. If the Runner is still tagged, place 1 advancement counter on that agenda."
		})

	NRCardDefs.defcard("IPO", {
			"title": "IPO",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 8,
			"factioncost": 0,
			"keywords": "Terminal - Transaction",
			"subtypes": ["Terminal", "Transaction"],
			"text": "After you resolve this operation, end your action phase.\nGain 13[credit]."
		})

	NRCardDefs.defcard("Kakurenbo", {
			"title": "Kakurenbo",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Triple",
			"subtypes": ["Triple"],
			"text": "As an additional cost to play this operation, spend [click][click].\nTrash any number of cards from HQ. Turn all cards in Archives facedown. You may install 1 card from Archives in the root of a remote server and place 2 advancement counters on it.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Key Performance Indicators", {
			"title": "Key Performance Indicators",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Resolve 2 of the following in any order:<ul><li>Draw 1 card. Shuffle 1 card from HQ into R&D.</li><li>Install 1 piece of ice from HQ, ignoring all costs.</li><li>Place 1 advancement counter on an installed card you can advance.</li><li>Gain 2[credit].</li></ul>"
		})

	NRCardDefs.defcard("Kill Switch", {
			"title": "Kill Switch",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 5,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nWhile the Runner is accessing an agenda in R&D, they must reveal it.\nWhenever an agenda is accessed or scored, Trace[3]. If successful, do 1 core damage."
		})

	NRCardDefs.defcard("Lag Time", {
			"title": "Lag Time",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 0,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAll <strong>ice</strong> have +1 strength."
		})

	NRCardDefs.defcard("Lateral Growth", {
			"title": "Lateral Growth",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 4[credit]. You may install 1 card (paying the install cost)."
		})

	NRCardDefs.defcard("Liquidation", {
			"title": "Liquidation",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"keywords": "Double - Gray Ops - Transaction",
			"subtypes": ["Double", "Gray Ops", "Transaction"],
			"text": "As an additional cost to play this operation, spend [click].\nTrash any number of your rezzed cards and gain 3[credit] for each card trashed."
		})

	NRCardDefs.defcard("Load Testing", {
			"title": "Load Testing",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 5,
			"text": "When the Runner's next turn begins, they lose [click]."
		})

	NRCardDefs.defcard("Localized Product Line", {
			"title": "Localized Product Line",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 3,
			"text": "Search R&D for any number of copies of a card, reveal them, and add them to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Manhunt", {
			"title": "Manhunt",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe first time the Runner makes a successful run each turn, Trace[2]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Market Forces", {
			"title": "Market Forces",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nThe Runner loses 3[credit] for each tag they have, then you gain 1[credit] for each credit lost this way."
		})

	NRCardDefs.defcard("Mass Commercialization", {
			"title": "Mass Commercialization",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 2[credit] for each card with at least 1 advancement token on it."
		})

	NRCardDefs.defcard("MCA Informant", {
			"title": "MCA Informant",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 2,
			"keywords": "Terminal",
			"subtypes": ["Terminal"],
			"text": "After you resolve this operation, your action phase ends.\nHost this operation on an installed <strong>connection</strong> resource as a condition counter with \"The Runner is considered to have 1 additional tag. Host resource gains '<strong>[click]</strong>, <strong>2[credit]:</strong> Trash this resource.'\""
		})

	NRCardDefs.defcard("Measured Response", {
			"title": "Measured Response",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"trash": 3,
			"factioncost": 4,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "Play only if the threat level is 4 or greater, and only if the Runner made a successful run during their last turn.\nDo 4 meat damage unless the Runner pays 8[credit]."
		})

	NRCardDefs.defcard("Media Blitz", {
			"title": "Media Blitz",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nChoose an agenda in the Runner's score area. Media Blitz gains the text of that agenda."
		})

	NRCardDefs.defcard("Medical Research Fundraiser", {
			"title": "Medical Research Fundraiser",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 8[credit]. The Runner gains 3[credit]."
		})

	NRCardDefs.defcard("Midseason Replacements", {
			"title": "Midseason Replacements",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 4,
			"text": "Play only if the Runner stole an agenda during their last turn.\nTrace[6]. If successful, give the Runner X tags. X is equal to the amount by which your trace strength exceeded their link strength."
		})

	NRCardDefs.defcard("Mindscaping", {
			"title": "Mindscaping",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Resolve 1 of the following:<ul><li>Gain 4[credit] and draw 2 cards. Add 1 card from HQ to the top of R&D.</li><li>Do X net damage. X is equal to the number of tags the Runner has, up to 3.</li></ul>"
		})

	NRCardDefs.defcard("Mitosis", {
			"title": "Mitosis",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 4,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nInstall up to 2 cards from HQ, creating a new remote server each time. Place 2 advancement counters on each of those cards. You cannot score or rez either of those cards this turn."
		})

	NRCardDefs.defcard("Mushin No Shin", {
			"title": "Mushin No Shin",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nInstall 1 asset, agenda, or upgrade from HQ in the root of a new server. Place 3 advancement counters on that card. You cannot score or rez that card until your next turn begins."
		})

	NRCardDefs.defcard("Mutate", {
			"title": "Mutate",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"text": "As an additional cost to play this operation, trash a rezzed piece of ice.\nReveal cards from the top of R&D until you reveal a piece of ice. Install and rez that ice in the same position as the ice that was trashed, ignoring all costs. Shuffle R&D."
		})

	NRCardDefs.defcard("Mutually Assured Destruction", {
			"title": "Mutually Assured Destruction",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 4,
			"keywords": "Triple",
			"subtypes": ["Triple"],
			"text": "As an additional cost to play this operation, spend [click][click].\nTrash any number of your rezzed cards. Give the Runner 1 tag for each card trashed this way."
		})

	NRCardDefs.defcard("Myōshu", {
			"title": "Myōshu",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 10,
			"factioncost": 4,
			"text": "Play only if you scored an agenda this turn that you did not install this turn.\nAdd this operation to your score area as an agenda worth 2 agenda points."
		})

	NRCardDefs.defcard("Nanomanagement", {
			"title": "Nanomanagement",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 4,
			"text": "Gain [click][click]."
		})

	NRCardDefs.defcard("NAPD Cordon", {
			"title": "NAPD Cordon",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"trash": 2,
			"factioncost": 0,
			"keywords": "Lockdown",
			"subtypes": ["Lockdown"],
			"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nAs an additional cost to steal an agenda, the Runner must pay 4[credit] plus 2[credit] for each advancement counter on that agenda."
		})

	NRCardDefs.defcard("Net Watchlist", {
			"title": "Net Watchlist",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner must pay 2[credit] as an additional cost to use an icebreaker."
		})

	NRCardDefs.defcard("Neural EMP", {
			"title": "Neural EMP",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner made a run during their last turn.\nDo 1 net damage."
		})

	NRCardDefs.defcard("Neurospike", {
			"title": "Neurospike",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Do X net damage, where X is equal to the sum of the printed agenda points on agendas you scored this turn."
		})

	NRCardDefs.defcard("NEXT Activation Command", {
			"title": "NEXT Activation Command",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"trash": 4,
			"factioncost": 3,
			"keywords": "Lockdown",
			"subtypes": ["Lockdown"],
			"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nEach piece of ice gets +2 strength.\nThe Runner cannot use non-<strong>icebreaker</strong> cards to break subroutines."
		})

	NRCardDefs.defcard("Nonequivalent Exchange", {
			"title": "Nonequivalent Exchange",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 5[credit]. You may have each player gain 2[credit]."
		})

	NRCardDefs.defcard("O₂ Shortage", {
			"title": "O₂ Shortage",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"text": "The Runner may trash 1 card from the grip at random. If they do not, gain [click][click]."
		})

	NRCardDefs.defcard("Observe and Destroy", {
			"title": "Observe and Destroy",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner has fewer than 6[credit].\nAs an additional cost to play this operation, remove 1 tag.\nTrash 1 installed card."
		})

	NRCardDefs.defcard("Oppo Research", {
			"title": "Oppo Research",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Terminal - Gray Ops",
			"subtypes": ["Terminal", "Gray Ops"],
			"text": "Play only if the Runner stole or trashed a Corp card during their last turn.\nAfter you resolve this operation, your action phase ends.\nGive the Runner 2 tags.\nThreat 3 → You may pay 5[credit] to give the Runner 2 tags. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
		})

	NRCardDefs.defcard("Oversight AI", {
			"title": "Oversight AI",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Rez a piece of ice, ignoring all costs, and install Oversight AI on that ice as a hosted condition counter with the text \"Trash host ice if all its subroutines are broken during a single encounter.\""
		})

	NRCardDefs.defcard("Patch", {
			"title": "Patch",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Install Patch on a rezzed piece of ice as a hosted condition counter with the text \"Host ice has +2 strength.\""
		})

	NRCardDefs.defcard("Paywall Implementation", {
			"title": "Paywall Implementation",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Current - Transaction",
			"subtypes": ["Current", "Transaction"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nGain 1[credit] whenever the Runner makes a successful run."
		})

	NRCardDefs.defcard("Peak Efficiency", {
			"title": "Peak Efficiency",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"text": "Gain 1[credit] for each rezzed piece of ice."
		})

	NRCardDefs.defcard("Peer Review", {
			"title": "Peer Review",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Reveal all but 1 card in HQ.\nGain 7[credit]. You may install 1 card from HQ in the root of a remote server."
		})

	NRCardDefs.defcard("Petty Cash", {
			"title": "Petty Cash",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 0,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Play only if you have not finished an action yet this turn.\nGain 5[credit]. If you played this operation from anywhere except HQ, gain [click].\n[click]<strong>:</strong> Play this operation from Archives. After it resolves, remove it from the game."
		})

	NRCardDefs.defcard("Pivot", {
			"title": "Pivot",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"trash": 3,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nSearch R&D for 1 operation or agenda and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that card to HQ.\nThreat 3 → You may play or install 1 card from HQ. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
		})

	NRCardDefs.defcard("Power Grid Overload", {
			"title": "Power Grid Overload",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"text": "Play only if the Runner made a successful run during their last turn.\nTrace[2]. If successful, trash 1 installed piece of hardware with an install cost of X or less, where X is equal to the amount by which your trace strength exceeded the Runner's link strength."
		})

	NRCardDefs.defcard("Power Shutdown", {
			"title": "Power Shutdown",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner made a run during their last turn.\nTrash any number of cards from the top of R&D. The Runner trashes an installed program or piece of hardware with an install cost equal to or less than the number of cards you trashed this way."
		})

	NRCardDefs.defcard("Precognition", {
			"title": "Precognition",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"text": "Look at the top 5 cards of R&D and arrange them in any order."
		})

	NRCardDefs.defcard("Predictive Algorithm", {
			"title": "Predictive Algorithm",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAs an additional cost to steal an agenda, the Runner must pay 2[credit]."
		})

	NRCardDefs.defcard("Predictive Planogram", {
			"title": "Predictive Planogram",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Resolve 1 of the following. If the Runner is tagged, you may resolve both instead.<ul><li>Gain 3[credit].</li><li>Draw 3 cards.</li></ul>"
		})

	NRCardDefs.defcard("Preemptive Action", {
			"title": "Preemptive Action",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Terminal",
			"subtypes": ["Terminal"],
			"text": "After you resolve this operation, end your action phase.\nShuffle 3 cards from Archives into R&D. Remove Preemptive Action from the game instead of trashing it."
		})

	NRCardDefs.defcard("Priority Construction", {
			"title": "Priority Construction",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nInstall a piece of ice from HQ protecting a remote server (ignoring all costs). Place 3 advancement tokens on that ice."
		})

	NRCardDefs.defcard("Product Recall", {
			"title": "Product Recall",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Alliance",
			"subtypes": ["Alliance"],
			"text": "This card costs 0 influence if you have 6 or more non-<strong>alliance</strong> [haas-bioroid] cards in your deck.\nTrash a rezzed asset or upgrade. If you do, gain credits equal to its trash cost."
		})

	NRCardDefs.defcard("Psychographics", {
			"title": "Psychographics",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"factioncost": 3,
			"text": "X must be equal to or less than the number of tags the Runner has.\nPlace X advancement counters on 1 installed card you can advance."
		})

	NRCardDefs.defcard("Psychokinesis", {
			"title": "Psychokinesis",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Terminal",
			"subtypes": ["Terminal"],
			"text": "After you resolve this operation, end your action phase.\nLook at the top 5 cards of R&D. If any of those cards are agendas, assets, or upgrades, you may install 1 of those cards in a remote server."
		})

	NRCardDefs.defcard("Public Trail", {
			"title": "Public Trail",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner made a successful run during their last turn.\nGive the Runner 1 tag unless they pay 8[credit]."
		})

	NRCardDefs.defcard("Punitive Counterstrike", {
			"title": "Punitive Counterstrike",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "Trace[5]. If successful, do X meat damage. X is equal to the sum of the printed agenda points on all agendas the Runner stole during their last turn."
		})

	NRCardDefs.defcard("realloc()", {
			"title": "realloc()",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nChoose 2 rezzed pieces of ice. For each chosen piece of ice, gain credits equal to its printed rez cost, then derez it."
		})

	NRCardDefs.defcard("Reanimation Protocol", {
			"title": "Reanimation Protocol",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Liability",
			"subtypes": ["Liability"],
			"text": "Install and rez 1 piece of ice from Archives, paying a total of 10[credit] less. If you rezzed a piece of non-<strong>liability</strong> ice this way, take 1 bad publicity."
		})

	NRCardDefs.defcard("Reclamation Order", {
			"title": "Reclamation Order",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nName a card other than Reclamation Order. Reveal any number of copies of the named card from Archives and add them to HQ."
		})

	NRCardDefs.defcard("Recruiting Trip", {
			"title": "Recruiting Trip",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"factioncost": 1,
			"text": "Search R&D for up to X different <strong>sysops</strong> (by title), reveal them, and add them to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Red Level Clearance", {
			"title": "Red Level Clearance",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Resolve 2 of the following in any order:<ul><li>Draw 2 cards.</li><li>Gain 2[credit].</li><li>Install 1 non-agenda card from HQ.</li><li>Gain [click].</li></ul>"
		})

	NRCardDefs.defcard("Red Planet Couriers", {
			"title": "Red Planet Couriers",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 4,
			"keywords": "Triple",
			"subtypes": ["Triple"],
			"text": "As an additional cost to play this operation, spend [click], [click].\nMove all advancement tokens from all installed cards to 1 card that can be advanced."
		})

	NRCardDefs.defcard("Replanting", {
			"title": "Replanting",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nAdd one of your installed cards to HQ. Install 2 cards from HQ, ignoring all costs."
		})

	NRCardDefs.defcard("Restore", {
			"title": "Restore",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"text": "Install and rez 1 card from Archives (paying all costs). Remove all other copies of that card in Archives from the game."
		})

	NRCardDefs.defcard("Restoring Face", {
			"title": "Restoring Face",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"text": "Reveal and trash 1 of your installed <strong>sysop</strong>, <strong>executive</strong>, or <strong>clone</strong> cards. If you do, remove up to 2 bad publicity."
		})

	NRCardDefs.defcard("Restructure", {
			"title": "Restructure",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 10,
			"factioncost": 0,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 15[credit]."
		})

	NRCardDefs.defcard("Retirement Plan", {
			"title": "Retirement Plan",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nInstall 1 agenda, asset, or piece of ice from Archives."
		})

	NRCardDefs.defcard("Retribution", {
			"title": "Retribution",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nTrash 1 installed program or piece of hardware."
		})

	NRCardDefs.defcard("Reuse", {
			"title": "Reuse",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nTrash any number of cards from HQ. Gain 2[credit] for each card trashed."
		})

	NRCardDefs.defcard("Reverse Infection", {
			"title": "Reverse Infection",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Choose one:<ul><li>Purge virus counters. Trash 1 card from the top of the stack for every 3 virus counters removed.</li><li>Gain 2[credit].</li></ul>"
		})

	NRCardDefs.defcard("Rework", {
			"title": "Rework",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Shuffle 1 card from HQ into R&D."
		})

	NRCardDefs.defcard("Riot Suppression", {
			"title": "Riot Suppression",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 4,
			"keywords": "Reprisal - Gray Ops",
			"subtypes": ["Reprisal", "Gray Ops"],
			"text": "Play only if the Runner trashed a Corp card during their last turn.\nThe Runner may suffer 1 core damage. If they do not, they get -3 allotted [click] for their next turn.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Rolling Brownout", {
			"title": "Rolling Brownout",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 1,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe play cost of each operation and event is increased by 1.\nThe first time the Runner plays an event each turn, gain 1[credit]."
		})

	NRCardDefs.defcard("Rover Algorithm", {
			"title": "Rover Algorithm",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 0,
			"text": "Install Rover Algorithm on a rezzed piece of ice as a hosted condition counter with the text \"Host ice has +1 strength for each power counter on Rover Algorithm. Whenever the Runner passes host ice, place 1 power counter on Rover Algorithm.\""
		})

	NRCardDefs.defcard("Sacrifice", {
			"title": "Sacrifice",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "As an additional cost to play this operation, forfeit 1 agenda.\nRemove X bad publicity. X is equal to the agenda point value of the forfeited agenda. Gain 1[credit] for each bad publicity removed this way."
		})

	NRCardDefs.defcard("Salem's Hospitality", {
			"title": "Salem's Hospitality",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 4,
			"keywords": "Alliance - Gray Ops",
			"subtypes": ["Alliance", "Gray Ops"],
			"text": "This operation costs 0 influence if you have 6 or more non-<strong>alliance</strong> [nbn] cards in your deck.\nChoose a card name. The Runner reveals the grip and trashes all cards with the chosen name revealed this way."
		})

	NRCardDefs.defcard("Scapegoat", {
			"title": "Scapegoat",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Resolve 1 of the following of the Runner’s choice:<ul><li>Remove 2 bad publicity.</li><li>Choose 1 installed Runner card. The Runner shuffles it into the stack.</li></ul>"
		})

	NRCardDefs.defcard("Scapenet", {
			"title": "Scapenet",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner made a successful run during their last turn.\nTrace[7]. If successful, remove 1 installed <strong>chip</strong> or <strong>virtual</strong> card from the game."
		})

	NRCardDefs.defcard("Scarcity of Resources", {
			"title": "Scarcity of Resources",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 0,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe install cost of each resource is increased by 2."
		})

	NRCardDefs.defcard("Scorched Earth", {
			"title": "Scorched Earth",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 4,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "Play only if the Runner is tagged.\nDo 4 meat damage."
		})

	NRCardDefs.defcard("SEA Source", {
			"title": "SEA Source",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"text": "Play only if the Runner made a successful run during their last turn.\nTrace[3]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Seamless Launch", {
			"title": "Seamless Launch",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"text": "Place 2 advancement counters on 1 installed card that you did not install this turn."
		})

	NRCardDefs.defcard("Secure and Protect", {
			"title": "Secure and Protect",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nSearch R&D for 1 piece of ice and reveal it. <em>(Shuffle R&D after searching it.)</em> Install that ice protecting a central server, paying 3[credit] less."
		})

	NRCardDefs.defcard("Self-Growth Program", {
			"title": "Self-Growth Program",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nAdd 2 installed Runner cards to the grip."
		})

	NRCardDefs.defcard("Service Outage", {
			"title": "Service Outage",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This operation is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nAs an additional cost to run for the first time during their turn, the Runner must spend 1[credit]."
		})

	NRCardDefs.defcard("Shipment from Kaguya", {
			"title": "Shipment from Kaguya",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Place 1 advancement token on each of up to 2 different installed cards that can be advanced."
		})

	NRCardDefs.defcard("Shipment from MirrorMorph", {
			"title": "Shipment from MirrorMorph",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"text": "Install up to 3 cards from HQ (one at a time and paying all install costs)."
		})

	NRCardDefs.defcard("Shipment from SanSan", {
			"title": "Shipment from SanSan",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nPlace up to 2 advancement tokens on a card that can be advanced."
		})

	NRCardDefs.defcard("Shipment from Tennin", {
			"title": "Shipment from Tennin",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"text": "Play only if the Runner did not make a successful run during their last turn.\nPlace 2 advancement counters on 1 installed card."
		})

	NRCardDefs.defcard("Shipment from Vladisibirsk", {
			"title": "Shipment from Vladisibirsk",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner has at least 2 tags.\nPlace a total of 4 advancement counters on installed cards you can advance."
		})

	NRCardDefs.defcard("Shoot the Moon", {
			"title": "Shoot the Moon",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nRez 1 piece of ice for each tag the Runner has, ignoring all costs."
		})

	NRCardDefs.defcard("Simulation Reset", {
			"title": "Simulation Reset",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"text": "Trash up to 5 cards from HQ. Shuffle that many cards from Archives into R&D. Draw that many cards.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Snatch and Grab", {
			"title": "Snatch and Grab",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Trace[3]. If successful, trash 1 <strong>connection</strong>. The Runner can take 1 tag to prevent this."
		})

	NRCardDefs.defcard("Special Report", {
			"title": "Special Report",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"text": "Shuffle any number of cards from HQ into R&D. Draw that number of cards."
		})

	NRCardDefs.defcard("Sprint", {
			"title": "Sprint",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Draw 3 cards. Shuffle 2 cards from HQ into R&D."
		})

	NRCardDefs.defcard("Standard Procedure", {
			"title": "Standard Procedure",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"text": "Play only if the Runner made a successful run during their last turn.\nChoose a card type, then reveal the grip. Gain 2[credit] for each card of the chosen type revealed this way."
		})

	NRCardDefs.defcard("Stock Buy-Back", {
			"title": "Stock Buy-Back",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Terminal - Transaction",
			"subtypes": ["Terminal", "Transaction"],
			"text": "After you resolve this operation, end your action phase.\nGain 3[credit] for each agenda in the Runner's score area."
		})

	NRCardDefs.defcard("Sudden Commandment", {
			"title": "Sudden Commandment",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"trash": 2,
			"factioncost": 3,
			"keywords": "Mandate",
			"subtypes": ["Mandate"],
			"text": "Draw 2 cards. You may play 1 non-<strong>terminal</strong> operation from HQ.\nThreat 3 → If this operation is the first <strong>mandate</strong> you played this turn, you may pay 3[credit] to gain [click]. <em>(This ability is active if any player has 3 or more agenda points.)</em>"
		})

	NRCardDefs.defcard("Sub Boost", {
			"title": "Sub Boost",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Host this operation on a rezzed piece of ice as a condition counter with \"Host ice gains <strong>barrier</strong> and gains '[subroutine] End the run.' after its other subroutines.\""
		})

	NRCardDefs.defcard("Subcontract", {
			"title": "Subcontract",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nPlay up to 2 operations from HQ (paying all costs), resolving them one at a time."
		})

	NRCardDefs.defcard("Subliminal Messaging", {
			"title": "Subliminal Messaging",
			"type": "Operation",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 0,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Gain 1[credit].\nThe first time each turn you play a copy of Subliminal Messaging, gain [click].\nWhen your turn begins, if this card is in Archives and the Runner did not initiate any runs during their last turn, you may reveal this card and add it to HQ."
		})

	NRCardDefs.defcard("Success", {
			"title": "Success",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Triple",
			"subtypes": ["Triple"],
			"text": "As an additional cost to play this operation, forfeit an agenda and spend [click][click].\nAdvance a card X times. X equals the advancement requirement of the agenda just forfeited."
		})

	NRCardDefs.defcard("Successful Demonstration", {
			"title": "Successful Demonstration",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 1,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Play only if the Runner made an unsuccessful run during their last turn.\nGain 7[credit]."
		})

	NRCardDefs.defcard("Sunset", {
			"title": "Sunset",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"text": "Choose a server. Arrange the ice protecting that server in any order."
		})

	NRCardDefs.defcard("Surveillance Sweep", {
			"title": "Surveillance Sweep",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nThe Runner must spend credits first for each trace attempt during a run."
		})

	NRCardDefs.defcard("Sweeps Week", {
			"title": "Sweeps Week",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"text": "Gain 1[credit] for each card in the Runner's grip."
		})

	NRCardDefs.defcard("SYNC Rerouting", {
			"title": "SYNC Rerouting",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"trash": 3,
			"factioncost": 3,
			"keywords": "Lockdown",
			"subtypes": ["Lockdown"],
			"text": "Play only if there is no active <strong>lockdown</strong>. This operation is not trashed until your next turn begins.\nWhenever a run begins, give the Runner 1 tag unless they pay 4[credit]."
		})

	NRCardDefs.defcard("Targeted Marketing", {
			"title": "Targeted Marketing",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Current",
			"subtypes": ["Current"],
			"text": "This card is not trashed until another <strong>current</strong> is played or an agenda is stolen.\nName a card. Gain 10[credit] whenever the Runner plays or installs a copy of that card."
		})

	NRCardDefs.defcard("The All-Seeing I", {
			"title": "The All-Seeing I",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 1,
			"text": "Play only if the Runner is tagged.\nTrash all installed resources unless the Runner removes 1 bad publicity."
		})

	NRCardDefs.defcard("Threat Assessment", {
			"title": "Threat Assessment",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Reprisal - Gray Ops",
			"subtypes": ["Reprisal", "Gray Ops"],
			"text": "Play only if the Runner trashed a Corp card during their last turn and the Runner has at least 1 installed card.\nChoose 1 installed Runner card. The Runner must take 2 tags or add that card to the top of the stack.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Threat Level Alpha", {
			"title": "Threat Level Alpha",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"factioncost": 2,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nTrace[1]. If successful, give the Runner 1 tag for each tag they have or, if the Runner has no tags, give them 1 tag."
		})

	NRCardDefs.defcard("Too Big to Fail", {
			"title": "Too Big to Fail",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"trash": 5,
			"factioncost": 4,
			"keywords": "Transaction - Liability",
			"subtypes": ["Transaction", "Liability"],
			"text": "Play only if you have less than 10[credit].\nGain 7[credit] and take 1 bad publicity."
		})

	NRCardDefs.defcard("Top-Down Solutions", {
			"title": "Top-Down Solutions",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"text": "Draw 2 cards. Install up to 2 cards from HQ <em>(one at a time)</em>."
		})

	NRCardDefs.defcard("Traffic Accident", {
			"title": "Traffic Accident",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 1,
			"keywords": "Black Ops",
			"subtypes": ["Black Ops"],
			"text": "Play only if the Runner has at least 2 tags.\nDo 2 meat damage."
		})

	NRCardDefs.defcard("Transparency Initiative", {
			"title": "Transparency Initiative",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 4,
			"text": "Turn an agenda faceup and install Transparency Initiative on that agenda as a hosted condition counter with the text \"Host agenda gains <strong>public</strong>. Whenever you advance host agenda, gain 1[credit].\""
		})

	NRCardDefs.defcard("Trick of Light", {
			"title": "Trick of Light",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"text": "Choose 1 installed card you can advance. Move up to 2 advancement counters from 1 other card to the chosen card."
		})

	NRCardDefs.defcard("Trojan Horse", {
			"title": "Trojan Horse",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner accessed a card during their last turn.\nTrace[4]. If successful, trash 1 installed program with an install cost of X or less, where X is equal to the amount by which your trace strength exceeded the Runner's link strength."
		})

	NRCardDefs.defcard("Trust Operation", {
			"title": "Trust Operation",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 3,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "Play only if the Runner is tagged.\nTrash 1 installed resource. Install and rez 1 card from Archives, ignoring all costs."
		})

	NRCardDefs.defcard("Touch-ups", {
			"title": "Touch-ups",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 3,
			"keywords": "Double",
			"subtypes": ["Double"],
			"text": "As an additional cost to play this operation, spend [click].\nPlace 2 advancement counters on 1 installed card you can advance. If you do, choose a card type and reveal the grip. Choose up to 2 revealed cards of that type. The Runner shuffles those cards into the stack."
		})

	NRCardDefs.defcard("Ultraviolet Clearance", {
			"title": "Ultraviolet Clearance",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"factioncost": 4,
			"keywords": "Transaction - Triple",
			"subtypes": ["Transaction", "Triple"],
			"text": "As an additional cost to play this operation, spend [click][click].\nGain 10[credit] and draw 4 cards. You may install 1 card from HQ."
		})

	NRCardDefs.defcard("Under the Bus", {
			"title": "Under the Bus",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Gray Ops - Liability",
			"subtypes": ["Gray Ops", "Liability"],
			"text": "Play only if the Runner accessed a card during their last turn.\nTrash 1 installed <strong>connection</strong> resource and take 1 bad publicity."
		})

	NRCardDefs.defcard("Unleash", {
			"title": "Unleash",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"factioncost": 2,
			"keywords": "Gray Ops",
			"subtypes": ["Gray Ops"],
			"text": "As an additional cost to play this operation, remove 1 tag.\nRez 1 installed piece of ice, ignoring all costs. You may resolve 1 subroutine on that ice."
		})

	NRCardDefs.defcard("Violet Level Clearance", {
			"title": "Violet Level Clearance",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"trash": 1,
			"factioncost": 3,
			"keywords": "Terminal - Transaction",
			"subtypes": ["Terminal", "Transaction"],
			"text": "After you resolve this operation, end your action phase.\nGain 8[credit] and draw 4 cards."
		})

	NRCardDefs.defcard("Voter Intimidation", {
			"title": "Voter Intimidation",
			"type": "Operation",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Gray Ops - Psi",
			"subtypes": ["Gray Ops", "Psi"],
			"text": "Play only if there is an agenda in the Runner's score area.\nYou and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, trash 1 resource."
		})

	NRCardDefs.defcard("Vulture Fund", {
			"title": "Vulture Fund",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 7,
			"factioncost": 2,
			"keywords": "Transaction - Liability",
			"subtypes": ["Transaction", "Liability"],
			"text": "Gain 14[credit] and take 1 bad publicity."
		})

	NRCardDefs.defcard("Wake Up Call", {
			"title": "Wake Up Call",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 3,
			"keywords": "Reprisal - Gray Ops",
			"subtypes": ["Reprisal", "Gray Ops"],
			"text": "Play only if the Runner trashed a Corp card during their last turn and the Runner has at least 1 installed piece of hardware or non-<strong>virtual</strong> resource.\nChoose 1 installed piece of hardware or non-<strong>virtual</strong> resource. The Runner must either trash that card or suffer 4 meat damage.\nRemove this operation from the game."
		})

	NRCardDefs.defcard("Wetwork Refit", {
			"title": "Wetwork Refit",
			"type": "Operation",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"factioncost": 2,
			"keywords": "Condition",
			"subtypes": ["Condition"],
			"text": "Host this operation on a rezzed piece of <strong>bioroid</strong> ice as a condition counter with \"Host ice gains '[subroutine] Do 1 core damage.' before all its other subroutines.\""
		})

	NRCardDefs.defcard("Witness Tampering", {
			"title": "Witness Tampering",
			"type": "Operation",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"factioncost": 1,
			"keywords": "Double - Gray Ops",
			"subtypes": ["Double", "Gray Ops"],
			"text": "As an additional cost to play this operation, spend [click].\nRemove up to 2 bad publicity."
		})

	NRCardDefs.defcard("Your Digital Life", {
			"title": "Your Digital Life",
			"type": "Operation",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"factioncost": 2,
			"keywords": "Transaction",
			"subtypes": ["Transaction"],
			"text": "Gain 1[credit] for each card in HQ."
		})
