class_name NRCardsIce
extends RefCounted

## Printed card data from game.cards.ice (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Ablative Barrier", {
			"title": "Ablative Barrier",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Threat 3 → When you rez this ice during a run against this server, you may install 1 non-agenda card from HQ or Archives in the root of or protecting another server. <em>(This ability is active if any player has 3 or more agenda points.)</em>\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Anemone", {
			"title": "Anemone",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "When you rez this ice during a run against this server, you may trash 1 card from HQ to do 2 net damage.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Ansel 1.0", {
			"title": "Ansel 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Sentry - Bioroid - Destroyer",
			"subtypes": ["Sentry", "Bioroid", "Destroyer"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] You may install 1 card from HQ or Archives.\n[subroutine] The Runner cannot steal or trash Corp cards for the remainder of this run."
		})

	NRCardDefs.defcard("Ansel 2.0", {
			"title": "Ansel 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 4,
			"keywords": "Sentry - Bioroid - Destroyer",
			"subtypes": ["Sentry", "Bioroid", "Destroyer"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] Remove 1 card in the heap from the game.\n[subroutine] You may install 1 card from HQ or Archives.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Anvil", {
			"title": "Anvil",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters this ice, you may trash 1 of your other installed cards. If you do, the Runner cannot break this iceʼs printed subroutines for the remainder of this encounter.\n[subroutine] Gain 1[credit]. The Runner loses 1[credit].\n[subroutine] The Runner trashes 1 of their installed cards."
		})

	NRCardDefs.defcard("Afshar", {
			"title": "Afshar",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "While this ice is protecting HQ, the Runner cannot break more than 1 of its printed subroutines during each encounter.\n[subroutine] The Runner loses 2[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Aiki", {
			"title": "Aiki",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - Psi - AP",
			"subtypes": ["Code Gate", "Psi", "AP"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, the Runner draws 2 cards.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Aimor", {
			"title": "Aimor",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] Trash the top 3 cards of the stack. Trash Aimor."
		})

	NRCardDefs.defcard("Akhet", {
			"title": "Akhet",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "You can advance this ice.\nWhile there are 3 or more hosted advancement counters, this ice gets +3 strength and the Runner cannot break more than 1 of its printed subroutines during each encounter.\n[subroutine] Gain 1[credit]. Place 1 advancement counter on an installed card.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Anansi", {
			"title": "Anansi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 4,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "Whenever an encounter with this ice ends, if the Runner did not fully break it, do 3 net damage.\n[subroutine] Look at the top 5 cards of R&D and arrange them in any order.\n[subroutine] You may draw 1 card. The Runner may pay 2[credit] to draw 1 card.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Archangel", {
			"title": "Archangel",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 6,
			"factioncost": 4,
			"keywords": "Code Gate - Tracer - Ambush",
			"subtypes": ["Code Gate", "Tracer", "Ambush"],
			"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, you may pay 3[credit]. If you do, they encounter it.\n[subroutine] Trace[6]. If successful, add 1 installed Runner card to the grip."
		})

	NRCardDefs.defcard("Archer", {
			"title": "Archer",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "As an additional cost to rez this ice, forfeit 1 agenda.\n[subroutine] Gain 2[credit].\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Architect", {
			"title": "Architect",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "Players cannot trash this ice.\n[subroutine] Look at the top 5 cards of R&D. You may install 1 of those cards, ignoring the install cost.\n[subroutine] You may install 1 card from Archives or HQ."
		})

	NRCardDefs.defcard("Ashigaru", {
			"title": "Ashigaru",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 9,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "This ice gains \"[subroutine] End the run.\" for each card in HQ."
		})

	NRCardDefs.defcard("Assassin", {
			"title": "Assassin",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 0,
			"keywords": "Sentry - Destroyer - AP - Tracer",
			"subtypes": ["Sentry", "Destroyer", "AP", "Tracer"],
			"text": "[subroutine] Trace[5]. If successful, do 3 net damage.\n[subroutine] Trace[4]. If successful, trash 1 program."
		})

	NRCardDefs.defcard("Asteroid Belt", {
			"title": "Asteroid Belt",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 9,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Asteroid Belt can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Attini", {
			"title": "Attini",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 6,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "Threat 3 → The Runner cannot spend credits while subroutines on this ice are resolving. <em>(This ability is active if any player has 3 or more agenda points.)</em>\n[subroutine] Do 1 net damage unless the Runner pays 2[credit].\n[subroutine] Do 1 net damage unless the Runner pays 2[credit].\n[subroutine] Do 1 net damage unless the Runner pays 2[credit]."
		})

	NRCardDefs.defcard("Authenticator", {
			"title": "Authenticator",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters this ice, they may take 1 tag to bypass it.\n[subroutine] The Corp gains 2[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Bailiff", {
			"title": "Bailiff",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Whenever the Runner breaks a subroutine on Bailiff, gain 1[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Ballista", {
			"title": "Ballista",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "[subroutine] Trash 1 installed program or end the run."
		})

	NRCardDefs.defcard("Bandwidth", {
			"title": "Bandwidth",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] Give the Runner 1 tag. If this run is successful, the Runner removes 1 tag."
		})

	NRCardDefs.defcard("Bastion", {
			"title": "Bastion",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] End the run."
		})

	NRCardDefs.defcard("Bathynomus", {
			"title": "Bathynomus",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 3,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "While this ice is protecting Archives, it gets +3 strength.\n[subroutine] Do 3 net damage."
		})

	NRCardDefs.defcard("Battlement", {
			"title": "Battlement",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"factioncost": 4,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine]End the run.\n[subroutine]End the run."
		})

	NRCardDefs.defcard("Blockchain", {
			"title": "Blockchain",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 7,
			"strength": 4,
			"factioncost": 4,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "This ice gains \"[subroutine] Gain 1[credit] and the Runner loses 1[credit].\" before its other subroutines for every 2 faceup <strong>transaction</strong> operations in Archives.\n[subroutine] Gain 1[credit] and the Runner loses 1[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Bloodletter", {
			"title": "Bloodletter",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "[subroutine] The Runner must trash either 1 installed program or the top 2 cards of the stack."
		})

	NRCardDefs.defcard("Bloom", {
			"title": "Bloom",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - Observer",
			"subtypes": ["Code Gate", "Observer"],
			"text": "[subroutine] You may install 1 piece of ice from HQ protecting another server, ignoring all costs.\n[subroutine] You may install 1 piece of ice from HQ directly inward from this ice, ignoring all costs."
		})

	NRCardDefs.defcard("Bloop", {
			"title": "Bloop",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - AP - Destroyer - Harmonic",
			"subtypes": ["Sentry", "AP", "Destroyer", "Harmonic"],
			"text": "As an additional cost to rez this ice, derez another piece of <strong>harmonic</strong> ice.\n[subroutine] Do 1 core damage.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Border Control", {
			"title": "Border Control",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 1,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[trash]: End the run. Use this ability only during a run on this server.\n[subroutine] Gain 1[credit] for each piece of ice protecting this server.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Boto", {
			"title": "Boto",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "Threat 4 → This ice gets +2 strength. <em>(This ability is active if any player has 4 or more agenda points.)</em>\n[subroutine] Do 2 net damage.\n[subroutine] You may trash 1 card from HQ to end the run.\n[subroutine] You may trash 1 card from HQ to end the run."
		})

	NRCardDefs.defcard("Brainstorm", {
			"title": "Brainstorm",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 9,
			"strength": 2,
			"factioncost": 4,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "When the Runner encounters this ice, it gains X \"[subroutine] Do 1 core damage.\" subroutines for the remainder of this run. X is equal to the number of cards in the grip."
		})

	NRCardDefs.defcard("Builder", {
			"title": "Builder",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[click]: Move this piece of ice to the outermost position protecting any server.\n[subroutine] Place 1 advancement token on a piece of ice protecting this server that can be advanced.\n[subroutine] Place 1 advancement token on a piece of ice protecting this server that can be advanced."
		})

	NRCardDefs.defcard("Bumi 1.0", {
			"title": "Bumi 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Sentry - Bioroid - AP - Destroyer",
			"subtypes": ["Sentry", "Bioroid", "AP", "Destroyer"],
			"text": "When you rez this ice during a run against this server, you may trash 1 installed <strong>trojan</strong> program.\n<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Do 1 core damage."
		})

	NRCardDefs.defcard("Brân 1.0", {
			"title": "Brân 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Barrier - Bioroid",
			"subtypes": ["Barrier", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] You may install 1 piece of ice from HQ or Archives directly inward from this ice, ignoring all costs.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Bullfrog", {
			"title": "Bullfrog",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate - Deflector - Psi",
			"subtypes": ["Code Gate", "Deflector", "Psi"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit] or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits and this ice is installed, move this ice to the outermost position protecting another server. <em>(The run continues from this new position.)</em>"
		})

	NRCardDefs.defcard("Bulwark", {
			"title": "Bulwark",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 10,
			"strength": 8,
			"factioncost": 3,
			"keywords": "Barrier - Liability",
			"subtypes": ["Barrier", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\nWhen the Runner encounters this ice, if there is an installed <strong>AI</strong> program, gain 2[credit].\n[subroutine] The Runner trashes 1 installed program.\n[subroutine] Gain 2[credit]. End the run.\n[subroutine] Gain 2[credit]. End the run."
		})

	NRCardDefs.defcard("Burke Bugs", {
			"title": "Burke Bugs",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "[subroutine] Trace[0]. If successful, the Runner trashes 1 program."
		})

	NRCardDefs.defcard("Caduceus", {
			"title": "Caduceus",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] Trace[3]. If successful, the Corp gains 3[credit].\n[subroutine] Trace[2]. If successful, end the run."
		})

	NRCardDefs.defcard("Capacitor", {
			"title": "Capacitor",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "While the Runner is tagged, this ice gets +2 strength.\n[subroutine] Gain 1[credit] for each tag the Runner has.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Cell Portal", {
			"title": "Cell Portal",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"strength": 7,
			"factioncost": 2,
			"keywords": "Code Gate - Deflector",
			"subtypes": ["Code Gate", "Deflector"],
			"text": "[subroutine] The Runner moves to the outermost position of the attacked server. They may jack out. Derez this ice."
		})

	NRCardDefs.defcard("Changeling", {
			"title": "Changeling",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Barrier - Morph",
			"subtypes": ["Barrier", "Morph"],
			"text": "Changeling can be advanced.\nWhile Changeling has an odd number of advancement tokens on it, it gains <strong>sentry</strong> and loses <strong>barrier</strong>.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Checkpoint", {
			"title": "Checkpoint",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 7,
			"factioncost": 2,
			"keywords": "Code Gate - Tracer - Liability",
			"subtypes": ["Code Gate", "Tracer", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trace[5]. If successful, do 3 meat damage when this run becomes successful."
		})

	NRCardDefs.defcard("Chetana", {
			"title": "Chetana",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - AP - Psi",
			"subtypes": ["Sentry", "AP", "Psi"],
			"text": "[subroutine] Each player gains 2[credit].\n[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, do 1 net damage for each card in the Runner's grip."
		})

	NRCardDefs.defcard("Chimera", {
			"title": "Chimera",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Mythic",
			"subtypes": ["Mythic"],
			"text": "When you rez Chimera, choose <strong>sentry</strong>, <strong>code gate</strong>, or <strong>barrier</strong>. Chimera gains that subtype until derezzed.\nWhen a turn ends, derez Chimera.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Chiyashi", {
			"title": "Chiyashi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 12,
			"strength": 8,
			"factioncost": 2,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "Whenever the Runner breaks a subroutine on Chiyashi while there is an <strong>AI</strong> installed, trash the top 2 cards of the Runner's stack.\n[subroutine] Do 2 net damage.\n[subroutine] Do 2 net damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Chrysalis", {
			"title": "Chrysalis",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, they encounter it.\n[subroutine] Do 2 net damage."
		})

	NRCardDefs.defcard("Chum", {
			"title": "Chum",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The next piece of ice the Runner encounters during this run gets +2 strength. When that encounter ends, if the Runner did not fully break that ice, do 3 net damage."
		})

	NRCardDefs.defcard("Clairvoyant Monitor", {
			"title": "Clairvoyant Monitor",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - Psi",
			"subtypes": ["Code Gate", "Psi"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, place 1 advancement token on an installed card and end the run."
		})

	NRCardDefs.defcard("Cloud Eater", {
			"title": "Cloud Eater",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 10,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - AP - Destroyer - Observer",
			"subtypes": ["Sentry", "AP", "Destroyer", "Observer"],
			"text": "Whenever an encounter with this ice ends, if it was rezzed this turn, trash 1 installed Runner card unless the Runner takes 2 tags or suffers 3 net damage.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] Give the Runner 2 tags.\n[subroutine] Do 3 net damage."
		})

	NRCardDefs.defcard("Cobra", {
			"title": "Cobra",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"strength": 1,
			"factioncost": 0,
			"keywords": "Sentry - Destroyer - AP",
			"subtypes": ["Sentry", "Destroyer", "AP"],
			"text": "[subroutine] Trash 1 program.\n[subroutine] Do 2 net damage."
		})

	NRCardDefs.defcard("Colossus", {
			"title": "Colossus",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "You can advance this ice. It gets +1 strength for each hosted advancement counter.\n[subroutine] Give the Runner 1 tag. If there are 3 or more hosted advancement counters, instead give the Runner 2 tags.\n[subroutine] Trash 1 installed program. If there are 3 or more hosted advancement counters, instead trash 1 installed program and 1 installed resource."
		})

	NRCardDefs.defcard("Congratulations!", {
			"title": "Congratulations!",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - Advertisement",
			"subtypes": ["Code Gate", "Advertisement"],
			"text": "When the Runner passes this ice, gain 1[credit].\n[subroutine] Gain 2[credit]. The Runner gains 1[credit]."
		})

	NRCardDefs.defcard("Conundrum", {
			"title": "Conundrum",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 8,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "Conundrum has +3 strength if there is an installed <strong>AI</strong>.\n[subroutine] The Runner trashes an installed program.\n[subroutine] The Runner loses [click], if able.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Cortex Lock", {
			"title": "Cortex Lock",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 1 net damage for each unused MU the Runner has."
		})

	NRCardDefs.defcard("Crick", {
			"title": "Crick",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "Crick has +3 strength while protecting Archives.\n[subroutine] Install a card from Archives (paying its install cost)."
		})

	NRCardDefs.defcard("Curtain Wall", {
			"title": "Curtain Wall",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 14,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "If Curtain Wall is the outermost piece of ice protecting a server, it has +4 strength.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Data Hound", {
			"title": "Data Hound",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Sentry - Tracer - Observer",
			"subtypes": ["Sentry", "Tracer", "Observer"],
			"text": "[subroutine] Trace[2]. If successful, look at the top X cards of the stack, where X is equal to the amount by which your trace strength exceeded the Runner's link strength. Trash 1 of those cards and arrange the rest in any order."
		})

	NRCardDefs.defcard("Data Loop", {
			"title": "Data Loop",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 7,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner encounters this ice, they add 2 cards from the grip to the top of the stack.\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Data Mine", {
			"title": "Data Mine",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Trap - AP",
			"subtypes": ["Trap", "AP"],
			"text": "[subroutine] Do 1 net damage. Trash Data Mine."
		})

	NRCardDefs.defcard("Data Raven", {
			"title": "Data Raven",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Tracer - Observer",
			"subtypes": ["Sentry", "Tracer", "Observer"],
			"text": "When the Runner encounters this ice, they must take 1 tag or end the run.\n<strong>Hosted power counter:</strong> Give the Runner 1 tag.\n[subroutine] Trace[3]. If successful, place 1 power counter on this ice."
		})

	NRCardDefs.defcard("Data Ward", {
			"title": "Data Ward",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"strength": 8,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner encounters this ice, they take 1 tag unless they pay 3[credit].\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged."
		})

	NRCardDefs.defcard("Datapike", {
			"title": "Datapike",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner must pay 2[credit], if able. If the Runner cannot pay 2[credit], end the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Diviner", {
			"title": "Diviner",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "[subroutine] Do 1 net damage. If you trash a card this way with a printed play or install cost that is an odd number, end the run. <em>(0 is not odd.)</em>"
		})

	NRCardDefs.defcard("DNA Tracker", {
			"title": "DNA Tracker",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 8,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "[subroutine] Do 1 net damage. The Runner loses 2[credit].\n[subroutine] Do 1 net damage. The Runner loses 2[credit].\n[subroutine] Do 1 net damage. The Runner loses 2[credit]."
		})

	NRCardDefs.defcard("Doomscroll", {
			"title": "Doomscroll",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - AP - Observer",
			"subtypes": ["Sentry", "AP", "Observer"],
			"text": "[subroutine] Give the Runner 1 tag.\n[subroutine] Do 1 net damage.\n[subroutine] Do 2 net damage if the Runner has at least 2 tags."
		})

	NRCardDefs.defcard("Dracō", {
			"title": "Dracō",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "When you rez this ice, you may spend any number of credits to place that many power counters on it.\nThis ice gets +1 strength for each hosted power counter.\n[subroutine] Trace[2]. If successful, give the Runner 1 tag and end the run."
		})

	NRCardDefs.defcard("Drafter", {
			"title": "Drafter",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "[subroutine] You may add 1 card from Archives to HQ.\n[subroutine] You may install 1 card from Archives or HQ, ignoring all costs."
		})

	NRCardDefs.defcard("Echo", {
			"title": "Echo",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Barrier - Harmonic",
			"subtypes": ["Barrier", "Harmonic"],
			"text": "Whenever you rez a piece of <strong>harmonic</strong> ice, place 1 power counter on this ice.\nThis ice gains \"[subroutine] End the run.\" for each hosted power counter."
		})

	NRCardDefs.defcard("Eli 1.0", {
			"title": "Eli 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Barrier - Bioroid",
			"subtypes": ["Barrier", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Eli 2.0", {
			"title": "Eli 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Barrier - Bioroid",
			"subtypes": ["Barrier", "Bioroid"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] You may draw 1 card.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Empiricist", {
			"title": "Empiricist",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Sentry - AP - Observer",
			"subtypes": ["Sentry", "AP", "Observer"],
			"text": "[subroutine] Draw 1 card. You may add 1 card from HQ to the top of R&D.\n[subroutine] Do 1 net damage. Give the Runner 1 tag.\n[subroutine] Do 2 net damage."
		})

	NRCardDefs.defcard("Endless EULA", {
			"title": "Endless EULA",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit].\n[subroutine]End the run unless the Runner pays 1[credit]."
		})

	NRCardDefs.defcard("Enforcer 1.0", {
			"title": "Enforcer 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Bioroid - Destroyer - AP",
			"subtypes": ["Sentry", "Bioroid", "Destroyer", "AP"],
			"text": "As an additional cost to rez this ice, forfeit 1 agenda.\n<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Do 1 core damage.\n[subroutine] Trash 1 installed <strong>console</strong>.\n[subroutine] Trash all installed <strong>virtual</strong> resources."
		})

	NRCardDefs.defcard("Engram Flush", {
			"title": "Engram Flush",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate - Observer",
			"subtypes": ["Code Gate", "Observer"],
			"text": "When the Runner encounters this ice, choose a card type. For the remainder of the encounter, whenever you reveal the grip with a subroutine on this ice, you may trash 1 revealed card of the chosen type.\n[subroutine] Reveal the grip.\n[subroutine] Reveal the grip."
		})

	NRCardDefs.defcard("Enigma", {
			"title": "Enigma",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner loses [click].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Envelopment", {
			"title": "Envelopment",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When you rez this ice, place 4 power counters on it.\nWhen your turn begins, remove 1 hosted power counter.\nThis ice gains \"[subroutine] End the run.\" before its other subroutines for each hosted power counter.\n[subroutine] Trash this ice."
		})

	NRCardDefs.defcard("Envelope", {
			"title": "Envelope",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "[subroutine] Do 1 net damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Errand Boy", {
			"title": "Errand Boy",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 1,
			"factioncost": 1,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "[subroutine] The Corp gains 1[credit] or draws 1 card.\n[subroutine] The Corp gains 1[credit] or draws 1 card.\n[subroutine] The Corp gains 1[credit] or draws 1 card."
		})

	NRCardDefs.defcard("Event Horizon", {
			"title": "Event Horizon",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 0,
			"factioncost": 3,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "[trash]<strong>:</strong> End the run. Use this ability only during a run against this server.\n[subroutine] Trash 1 installed program unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner pays 3[credit]."
		})

	NRCardDefs.defcard("Excalibur", {
			"title": "Excalibur",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 2,
			"strength": 3,
			"factioncost": 0,
			"keywords": "Mythic - Grail",
			"subtypes": ["Mythic", "Grail"],
			"text": "[subroutine] The Runner cannot make another run this turn."
		})

	NRCardDefs.defcard("Executive Functioning", {
			"title": "Executive Functioning",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 3,
			"keywords": "Code Gate - AP - Tracer",
			"subtypes": ["Code Gate", "AP", "Tracer"],
			"text": "[subroutine] Trace[4]. If successful, do 1 core damage."
		})

	NRCardDefs.defcard("ezaM", {
			"title": "ezaM",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[click]<strong>:</strong> Swap this ice with another installed piece of ice.\n[subroutine] Look at the top card of R&D. You may add that card to the bottom of R&D.\n[subroutine] Each piece of ice gets +1 strength for the remainder of this run."
		})

	NRCardDefs.defcard("F2P", {
			"title": "F2P",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "<strong>2[credit]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability, and only if they are not tagged.\n[subroutine] Add 1 installed Runner card to the grip.\n[subroutine] Give the Runner 1 tag."
		})

	NRCardDefs.defcard("Fairchild", {
			"title": "Fairchild",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 9,
			"strength": 8,
			"factioncost": 5,
			"keywords": "Code Gate - Bioroid - AP",
			"subtypes": ["Code Gate", "Bioroid", "AP"],
			"text": "[subroutine] End the run unless the Runner pays 4[credit].\n[subroutine] End the run unless the Runner pays 4[credit].\n[subroutine] End the run unless the Runner trashes 1 of their installed cards.\n[subroutine] End the run unless the Runner suffers 1 core damage."
		})

	NRCardDefs.defcard("Fairchild 1.0", {
			"title": "Fairchild 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Code Gate - Bioroid",
			"subtypes": ["Code Gate", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner must pay 1[credit] or trash 1 of their installed cards.\n[subroutine] The Runner must pay 1[credit] or trash 1 of their installed cards."
		})

	NRCardDefs.defcard("Fairchild 2.0", {
			"title": "Fairchild 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - Bioroid - AP",
			"subtypes": ["Code Gate", "Bioroid", "AP"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] The Runner must pay 2[credit] or trash 1 of their installed cards.\n[subroutine] The Runner must pay 2[credit] or trash 1 of their installed cards.\n[subroutine] Do 1 core damage."
		})

	NRCardDefs.defcard("Fairchild 3.0", {
			"title": "Fairchild 3.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Code Gate - Bioroid - AP",
			"subtypes": ["Code Gate", "Bioroid", "AP"],
			"text": "<strong>Lose [click][click][click]:</strong> Break up to 3 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] The Runner must pay 3[credit] or trash 1 of their installed cards.\n[subroutine] The Runner must pay 3[credit] or trash 1 of their installed cards.\n[subroutine] Do 1 core damage or end the run."
		})

	NRCardDefs.defcard("Fenris", {
			"title": "Fenris",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - AP - Liability",
			"subtypes": ["Sentry", "AP", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Do 1 core damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Fire Wall", {
			"title": "Fire Wall",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Fire Wall can be advanced and gains +1 strength for each advancement token on it.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Flare", {
			"title": "Flare",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 9,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - Tracer - AP",
			"subtypes": ["Sentry", "Tracer", "AP"],
			"text": "[subroutine]Trace[6]. If successful, trash 1 piece of hardware, do 2 meat damage (cannot be prevented), and end the run."
		})

	NRCardDefs.defcard("Flyswatter", {
			"title": "Flyswatter",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When you rez this ice during a run against this server, purge virus counters.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Flywheel", {
			"title": "Flywheel",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "[subroutine] Gain 1[credit]. You may draw 1 card.\n[subroutine] Gain 1[credit]. You may draw 1 card."
		})

	NRCardDefs.defcard("Formicary", {
			"title": "Formicary",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "Whenever the Runner approaches a server, you may rez this ice. If you do, move this ice to the innermost position protecting the approached server. The Runner moves to this ice and encounters it.\n[subroutine] End the run unless the Runner suffers 2 net damage."
		})

	NRCardDefs.defcard("Free Lunch", {
			"title": "Free Lunch",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "<strong>Hosted power counter:</strong> The Runner loses 1[credit].\n[subroutine] Place 1 power counter on Free Lunch.\n[subroutine] Place 1 power counter on Free Lunch."
		})

	NRCardDefs.defcard("Funhouse", {
			"title": "Funhouse",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters this ice, end the run unless the Runner takes 1 tag.\n[subroutine] Give the Runner 1 tag unless they pay 4[credit]."
		})

	NRCardDefs.defcard("Galahad", {
			"title": "Galahad",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 1,
			"keywords": "Barrier - Grail",
			"subtypes": ["Barrier", "Grail"],
			"text": "When the Runner encounters this ice, you may reveal up to 2 pieces of <strong>grail</strong> ice in HQ. For the remainder of this run, this ice gains the subroutines of each revealed piece of ice in the order of your choice.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Gatekeeper", {
			"title": "Gatekeeper",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "Gatekeeper has +6 strength if you rezzed it this turn.\n[subroutine] Draw up to 3 cards. Reveal up to 3 agendas in HQ and/or Archives, then shuffle those agendas into R&D.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Gemini", {
			"title": "Gemini",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Tracer - AP",
			"subtypes": ["Sentry", "Tracer", "AP"],
			"text": "[subroutine] Trace[2]. If successful, do 1 net damage. If your trace strength is 5 or greater, do 1 net damage."
		})

	NRCardDefs.defcard("Gold Farmer", {
			"title": "Gold Farmer",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Whenever the Runner breaks a printed subroutine on this ice, they lose 1[credit].\n[subroutine] End the run unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner pays 3[credit]."
		})

	NRCardDefs.defcard("Grim", {
			"title": "Grim",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 0,
			"keywords": "Sentry - Destroyer - Liability",
			"subtypes": ["Sentry", "Destroyer", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Grubber", {
			"title": "Grubber",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Barrier - Liability",
			"subtypes": ["Barrier", "Liability"],
			"text": "When you rez this ice, if it is protecting a central server, take 1 bad publicity.\n[subroutine] End the run unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner pays 3[credit]."
		})

	NRCardDefs.defcard("Guard", {
			"title": "Guard",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 0,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "Guard cannot be bypassed.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Gutenberg", {
			"title": "Gutenberg",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "Gutenberg has +3 strength while protecting R&D.\n[subroutine] Trace[7]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Gyri Labyrinth", {
			"title": "Gyri Labyrinth",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner's maximum hand size is reduced by 2 until the beginning of the Corp's next turn."
		})

	NRCardDefs.defcard("Hadrian's Wall", {
			"title": "Hadrian's Wall",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 10,
			"strength": 7,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Hadrian's Wall can be advanced and has +1 strength for each advancement token on it.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Hafrún", {
			"title": "Hafrún",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Barrier - Code Gate",
			"subtypes": ["Barrier", "Code Gate"],
			"text": "When you rez this ice during a run against this server, you may trash 1 card from HQ. If you do, choose 1 installed Runner card. That cardʼs abilities cannot break subroutines for the remainder of that run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Hákarl 1.0", {
			"title": "Hákarl 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Barrier - Bioroid - AP",
			"subtypes": ["Barrier", "Bioroid", "AP"],
			"text": "When you rez this ice during a run against this server, you may derez another installed card. If you do, the Runner cannot use paid abilities printed on <strong>bioroid</strong> ice for the remainder of this turn.\n<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Hagen", {
			"title": "Hagen",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Barrier - Destroyer",
			"subtypes": ["Barrier", "Destroyer"],
			"text": "This ice gets −1 strength for each installed <strong>icebreaker</strong>.\n[subroutine] Trash 1 installed program that is not a <strong>decoder</strong>, <strong>fracter</strong>, or <strong>killer</strong>.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Hailstorm", {
			"title": "Hailstorm",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"strength": 5,
			"factioncost": 4,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] Remove a card in the heap from the game.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Hammer", {
			"title": "Hammer",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer - Observer",
			"subtypes": ["Sentry", "Destroyer", "Observer"],
			"text": "During each encounter with this ice, the Runner cannot break more than 1 of its printed subroutines except using <strong>killers</strong>.\n[subroutine] Give the Runner 1 tag.\n[subroutine] Trash 1 installed resource or piece of hardware.\n[subroutine] Trash 1 installed program that is not a <strong>decoder</strong>, <strong>fracter</strong>, or <strong>killer</strong>."
		})

	NRCardDefs.defcard("Descent", {
			"title": "Descent",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Code Gate - Expendable",
			"subtypes": ["Code Gate", "Expendable"],
			"text": "[click], <strong>1[credit]</strong>, <strong>reveal and trash this ice from HQ:</strong> Draw 1 card. Reveal up to 2 agendas in HQ and/or Archives and shuffle them into R&D.\nWhen your turn begins, you may add this ice to HQ.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Harvester", {
			"title": "Harvester",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner draws 3 cards and then discards down to their maximum hand size.\n[subroutine] The Runner draws 3 cards and then discards down to their maximum hand size."
		})

	NRCardDefs.defcard("Heimdall 1.0", {
			"title": "Heimdall 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 8,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Barrier - Bioroid - AP",
			"subtypes": ["Barrier", "Bioroid", "AP"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Heimdall 2.0", {
			"title": "Heimdall 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 11,
			"strength": 7,
			"factioncost": 3,
			"keywords": "Barrier - Bioroid - AP",
			"subtypes": ["Barrier", "Bioroid", "AP"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage and end the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Herald", {
			"title": "Herald",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"trash": 1,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, they encounter it.\n[subroutine] Gain 2[credit].\n[subroutine] You may pay up to 2[credit] to place that many advancement counters on 1 installed card you can advance."
		})

	NRCardDefs.defcard("Himitsu-Bako", {
			"title": "Himitsu-Bako",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "1[credit]: Add Himitsu-Bako to HQ.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Hive", {
			"title": "Hive",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "This ice loses 1 of its printed \"[subroutine] End the run.\" subroutines for each agenda point in your score area.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Holmegaard", {
			"title": "Holmegaard",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Tracer - Destroyer",
			"subtypes": ["Sentry", "Tracer", "Destroyer"],
			"text": "[subroutine] Trace[4]. If successful, the Runner cannot access cards or breach the attacked server for the remainder of this run.\n[subroutine] Trash 1 installed <strong>icebreaker</strong>."
		})

	NRCardDefs.defcard("Hortum", {
			"title": "Hortum",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "You can advance this ice. If there are 3 or more hosted advancement counters, the Runner cannot break subroutines on this ice using <strong>AI</strong> programs.\n[subroutine] Gain 1[credit]. If there are 3 or more hosted advancement counters, instead gain 4[credit].\n[subroutine] End the run. If there are 3 or more hosted advancement counters, instead search R&D for up to 2 cards. Add those cards to HQ, then end the run."
		})

	NRCardDefs.defcard("Hourglass", {
			"title": "Hourglass",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner loses [click], if able.\n[subroutine] The Runner loses [click], if able.\n[subroutine] The Runner loses [click], if able."
		})

	NRCardDefs.defcard("Howler", {
			"title": "Howler",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] You may install and rez 1 piece of <strong>bioroid</strong> ice from HQ or Archives directly inward from this ice, ignoring all costs. When this run ends, if you installed a piece of ice this way, trash this ice and derez the ice you installed."
		})

	NRCardDefs.defcard("Hudson 1.0", {
			"title": "Hudson 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate - Bioroid",
			"subtypes": ["Code Gate", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner cannot access more than 1 card during this run.\n[subroutine] The Runner cannot access more than 1 card during this run."
		})

	NRCardDefs.defcard("Hunter", {
			"title": "Hunter",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Sentry - Tracer - Observer",
			"subtypes": ["Sentry", "Tracer", "Observer"],
			"text": "[subroutine] Trace[3]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Hydra", {
			"title": "Hydra",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 10,
			"strength": 6,
			"factioncost": 4,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 3 net damage if the Runner is tagged; otherwise, give the Runner 1 tag.\n[subroutine] Gain 5[credit] if the Runner is tagged; otherwise, give the Runner 1 tag.\n[subroutine] End the run if the Runner is tagged; otherwise, give the Runner 1 tag.\n"
		})

	NRCardDefs.defcard("Ice Wall", {
			"title": "Ice Wall",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"strength": 1,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "You can advance this ice. It gets +1 strength for each hosted advancement counter.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Ichi 1.0", {
			"title": "Ichi 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Bioroid - Tracer - Destroyer",
			"subtypes": ["Sentry", "Bioroid", "Tracer", "Destroyer"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program.\n[subroutine] Trace[1]. If successful, do 1 core damage and give the Runner 1 tag."
		})

	NRCardDefs.defcard("Ichi 2.0", {
			"title": "Ichi 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Sentry - Bioroid - Destroyer - Tracer",
			"subtypes": ["Sentry", "Bioroid", "Destroyer", "Tracer"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program.\n[subroutine] Trace[3]. If successful, do 1 core damage and give the Runner 1 tag."
		})

	NRCardDefs.defcard("Inazuma", {
			"title": "Inazuma",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] During the next encounter this run, the Runner cannot break subroutines on the encountered ice.\n[subroutine] The Runner cannot jack out this run until after their next encounter with a piece of ice begins."
		})

	NRCardDefs.defcard("Information Overload", {
			"title": "Information Overload",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "When the Runner encounters this ice, Trace[1]. If successful, give them 1 tag.\nThis ice gains \"[subroutine] The Runner trashes 1 of their installed cards.\" for each tag the Runner has."
		})

	NRCardDefs.defcard("Interrupt 0", {
			"title": "Interrupt 0",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] For the remainder of this run, as an additional cost to use an <strong>icebreaker</strong> ability to break subroutines, the Runner must pay 1[credit].\n[subroutine] For the remainder of this run, as an additional cost to use an <strong>icebreaker</strong> ability to break subroutines, the Runner must pay 1[credit]"
		})

	NRCardDefs.defcard("IP Block", {
			"title": "IP Block",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Barrier - Tracer",
			"subtypes": ["Barrier", "Tracer"],
			"text": "When the Runner encounters this ice, give them 1 tag if there is an installed <strong>AI</strong> program.\n[subroutine] Trace[3]. If successful, give the Runner 1 tag.\n[subroutine] End the run if the Runner is tagged."
		})

	NRCardDefs.defcard("IQ", {
			"title": "IQ",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 0,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "The rez cost of IQ is increased by 1 for each card in HQ.\nIQ has +1 strength for each card in HQ.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Ireress", {
			"title": "Ireress",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 0,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "This ice gains \"[subroutine] The Runner loses 1[credit].\" for each bad publicity you have."
		})

	NRCardDefs.defcard("It's a Trap!", {
			"title": "It's a Trap!",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 3,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "Whenever this ice is exposed, do 2 net damage.\n[subroutine] The Runner trashes 1 of their installed cards. Trash this ice."
		})

	NRCardDefs.defcard("Ivik", {
			"title": "Ivik",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "The rez cost of this ice is lowered by 1[credit] for each rezzed piece of <strong>code gate</strong> ice.\n[subroutine] Do 2 net damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Jaguarundi", {
			"title": "Jaguarundi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "Threat 4 → When the Runner encounters this ice, give them 1 tag unless they spend [click]. <em>(This ability is active if any player has 4 or more agenda points.)</em>\n[subroutine] Give the Runner 1 tag.\n[subroutine] If the Runner is tagged, do 1 core damage."
		})

	NRCardDefs.defcard("Janus 1.0", {
			"title": "Janus 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 15,
			"strength": 8,
			"factioncost": 3,
			"keywords": "Sentry - Bioroid - AP",
			"subtypes": ["Sentry", "Bioroid", "AP"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage."
		})

	NRCardDefs.defcard("Jua", {
			"title": "Jua",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "When the Runner encounters this ice, they cannot install cards for the remainder of the turn.\n[subroutine] Choose 2 installed Runner cards, if able. The Runner must add 1 of the chosen cards to the top of the stack."
		})

	NRCardDefs.defcard("Kakugo", {
			"title": "Kakugo",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 1,
			"factioncost": 3,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "When the Runner passes Kakugo, do 1 net damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Kamali 1.0", {
			"title": "Kamali 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 3,
			"factioncost": 4,
			"keywords": "Sentry - Bioroid - Destroyer - AP",
			"subtypes": ["Sentry", "Bioroid", "Destroyer", "AP"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage unless the Runner trashes 1 installed resource.\n[subroutine] Do 1 core damage unless the Runner trashes 1 installed piece of hardware.\n[subroutine] Do 1 core damage unless the Runner trashes 1 installed program."
		})

	NRCardDefs.defcard("Karunā", {
			"title": "Karunā",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 2 net damage. The Runner may jack out.\n[subroutine] Do 2 net damage."
		})

	NRCardDefs.defcard("Kessleroid", {
			"title": "Kessleroid",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "The Runner cannot trash this ice <em>(while it is rezzed)</em>.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Kitsune", {
			"title": "Kitsune",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Mythic - Trap",
			"subtypes": ["Mythic", "Trap"],
			"text": "[subroutine] You may choose 1 card in HQ. If you do, the Runner breaches HQ. During this breach, the Runner cannot access cards in the root of HQ, and the first card they access must be the chosen card. When the breach ends, trash this ice."
		})

	NRCardDefs.defcard("Klevetnik", {
			"title": "Klevetnik",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When you rez this ice during a run against this server, you may have the Runner gain 2[credit]. If you do, choose 1 installed resource. That resource loses all abilities until your next turn ends.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Knowledge Seeker", {
			"title": "Knowledge Seeker",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "Whenever an encounter with this ice ends, if it has 3 or more hosted virus counters, purge virus counters and derez this ice.\n[subroutine] Place 1 virus counter on this ice.\n[subroutine] Look at the top 4 cards of R&D and arrange them in any order.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Komainu", {
			"title": "Komainu",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"strength": 1,
			"factioncost": 4,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "When the Runner encounters this ice, it gains X \"[subroutine] Do 1 net damage.\" subroutines for the remainder of this run. X is equal to the number of cards in the grip."
		})

	NRCardDefs.defcard("Konjin", {
			"title": "Konjin",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 3,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Mythic - Psi",
			"subtypes": ["Mythic", "Psi"],
			"text": "When the Runner encounters this ice, play a Psi Game. <em>(Players secretly bid 0–2[credit]. Then each player reveals and spends their bid.)</em> If the bids differ, you may choose another rezzed piece of ice. The Runner encounters that ice. <em>(When that encounter ends, if the run has not ended, finish encountering this ice.)</em>"
		})

	NRCardDefs.defcard("Lab Dog", {
			"title": "Lab Dog",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] The Runner trashes an installed piece of hardware. Trash Lab Dog."
		})

	NRCardDefs.defcard("Lamplighter", {
			"title": "Lamplighter",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 0,
			"keywords": "Sentry - Observer",
			"subtypes": ["Sentry", "Observer"],
			"text": "When an agenda is scored or stolen from this server or its root, trash this ice.\n[subroutine] Give the Runner 1 tag unless they pay 3[credit].\n[subroutine] End the run if the Runner is tagged."
		})

	NRCardDefs.defcard("Lancelot", {
			"title": "Lancelot",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Sentry - Grail - Destroyer",
			"subtypes": ["Sentry", "Grail", "Destroyer"],
			"text": "When the Runner encounters this ice, you may reveal up to 2 pieces of <strong>grail</strong> ice in HQ. For the remainder of this run, this ice gains the subroutines of each revealed piece of ice in the order of your choice.\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Lethe", {
			"title": "Lethe",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 9,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Sentry - Observer",
			"subtypes": ["Sentry", "Observer"],
			"text": "Whenever the Runner bypasses or fully breaks this ice, give them 1 tag.\n[subroutine] You may add 1 card from Archives to the top or bottom of R&D.\n[subroutine] Add 1 installed Runner card to the grip."
		})

	NRCardDefs.defcard("Lionsmane", {
			"title": "Lionsmane",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 2 net damage.\n[subroutine] Do 2 net damage unless the Runner pays 3[credit].\n[subroutine] Do 2 net damage unless the Runner jacks out."
		})

	NRCardDefs.defcard("Little Engine", {
			"title": "Little Engine",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 7,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] The Runner gains 5[credit]."
		})

	NRCardDefs.defcard("Lockdown", {
			"title": "Lockdown",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner cannot draw cards for the remainder of this turn."
		})

	NRCardDefs.defcard("Logjam", {
			"title": "Logjam",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "You can advance this ice. It gets +1 strength for each hosted advancement counter.\nWhen you rez this ice, place 1 advancement counter on it plus 1 advancement counter for each card type among faceup cards in Archives.\n[subroutine] Gain 2[credit]. End the run.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Loki", {
			"title": "Loki",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 6,
			"strength": 3,
			"factioncost": 5,
			"keywords": "Bioroid",
			"subtypes": ["Bioroid"],
			"text": "When the Runner encounters this ice, choose another rezzed piece of ice. For the remainder of this run, this ice gains the subtypes of the chosen ice and gains the subroutines of that ice in order before its other subroutines.\n[subroutine] End the run unless the Runner shuffles all cards from the grip into the stack."
		})

	NRCardDefs.defcard("Loot Box", {
			"title": "Loot Box",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] End the run unless the Runner pays 2[credit].\n[subroutine] Reveal the top 3 cards of the stack. Add 1 of those cards to the grip and gain X[credit], where X is equal to that cardʼs play or install cost. The Runner shuffles the stack. Trash this ice."
		})

	NRCardDefs.defcard("Lotus Field", {
			"title": "Lotus Field",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "The strength of this ice cannot be lowered.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Lycan", {
			"title": "Lycan",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 6,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer - Morph",
			"subtypes": ["Sentry", "Destroyer", "Morph"],
			"text": "Lycan can be advanced.\nWhile Lycan has an odd number of advancement tokens on it, it gains <strong>code gate</strong> and loses <strong>sentry</strong>.\n[subroutine] Trash 1 program."
		})

	NRCardDefs.defcard("Lycian Multi-Munition", {
			"title": "Lycian Multi-Munition",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 3,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Mythic - Destroyer",
			"subtypes": ["Mythic", "Destroyer"],
			"text": "When you rez this ice, choose 1 or more subtypes among <strong>barrier</strong>, <strong>code gate</strong>, and <strong>sentry</strong>. This ice gains the chosen subtypes while it remains rezzed.\nWhen a turn ends, derez this ice.\n[subroutine] If this ice is a <strong>code gate</strong>, the Runner loses [click] and 1[credit].\n[subroutine] If this ice is a <strong>sentry</strong>, trash 1 installed program.\n[subroutine] If this ice is a <strong>barrier</strong>, gain 1[credit] and end the run."
		})

	NRCardDefs.defcard("M.I.C.", {
			"title": "M.I.C.",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[trash]<strong>:</strong> End the run unless the Runner spends [click]. Use this ability only during a run on this server.\n[subroutine] The Runner loses [click].\n[subroutine] The Runner loses [click].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Machicolation A", {
			"title": "Machicolation A",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Code Gate - Destroyer",
			"subtypes": ["Code Gate", "Destroyer"],
			"text": "[subroutine] Trash 1 program.\n[subroutine] Trash 1 program.\n[subroutine] Trash 1 piece of hardware.\n[subroutine] The Runner loses 3[credit], if able. End the run."
		})

	NRCardDefs.defcard("Machicolation B", {
			"title": "Machicolation B",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Code Gate - Destroyer - AP",
			"subtypes": ["Code Gate", "Destroyer", "AP"],
			"text": "[subroutine] Trash 1 resource.\n[subroutine] Trash 1 resource.\n[subroutine] Do 1 net damage.\n[subroutine] The Runner loses [click], if able. End the run."
		})

	NRCardDefs.defcard("Macrophage", {
			"title": "Macrophage",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 7,
			"factioncost": 0,
			"keywords": "Code Gate - Tracer",
			"subtypes": ["Code Gate", "Tracer"],
			"text": "[subroutine] Trace[4]. If successful, purge virus counters.\n[subroutine] Trace[3]. If successful, trash 1 <strong>virus</strong>.\n[subroutine] Trace[2]. If successful, remove a <strong>virus</strong> in the heap from the game.\n[subroutine] Trace[1]. If successful, end the run."
		})

	NRCardDefs.defcard("Magnet", {
			"title": "Magnet",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When you rez this ice, choose 1 installed program hosted on a piece of ice. Host that program on this ice.\nEach hosted program loses all abilities and cannot gain abilities.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Mamba", {
			"title": "Mamba",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Psi - AP",
			"subtypes": ["Sentry", "Psi", "AP"],
			"text": "<strong>Hosted power counter:</strong> Do 1 net damage. Use this ability only during a run.\n[subroutine] Do 1 net damage.\n[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, place 1 power counter on Mamba."
		})

	NRCardDefs.defcard("Marker", {
			"title": "Marker",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The next piece of ice the Runner encounters during this run gains \"[subroutine] End the run.\" after its other subroutines for the remainder of that run."
		})

	NRCardDefs.defcard("Markus 1.0", {
			"title": "Markus 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Barrier - Bioroid",
			"subtypes": ["Barrier", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner trashes 1 of their installed cards.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Maskirovka", {
			"title": "Maskirovka",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] Gain 2[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Masvingo", {
			"title": "Masvingo",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "You can advance this ice.\nWhen you rez this ice, place 1 advancement counter on it.\nThis ice gains \"[subroutine] End the run.\" for each hosted advancement counter."
		})

	NRCardDefs.defcard("Matrix Analyzer", {
			"title": "Matrix Analyzer",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - Tracer - Observer",
			"subtypes": ["Sentry", "Tracer", "Observer"],
			"text": "When the Runner encounters Matrix Analyzer, you may pay 1[credit] to place 1 advancement token on a card that can be advanced.\n[subroutine] Trace[2]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Mausolus", {
			"title": "Mausolus",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "You can advance this ice.\n[subroutine] Gain 1[credit]. If there are 3 or more hosted advancement counters, instead gain 3[credit].\n[subroutine] Do 1 net damage. If there are 3 or more hosted advancement counters, instead do 3 net damage.\n[subroutine] Give the Runner 1 tag. If there are 3 or more hosted advancement counters, instead give the Runner 1 tag and end the run."
		})

	NRCardDefs.defcard("Meridian", {
			"title": "Meridian",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] Gain 4[credit] and end the run unless the Runner adds this ice to their score area as an agenda worth -1 agenda point."
		})

	NRCardDefs.defcard("Merlin", {
			"title": "Merlin",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate - Grail - AP",
			"subtypes": ["Code Gate", "Grail", "AP"],
			"text": "When the Runner encounters this ice, you may reveal up to 2 pieces of <strong>grail</strong> ice in HQ. For the remainder of this run, this ice gains the subroutines of each revealed piece of ice in the order of your choice.\n[subroutine] Do 2 net damage."
		})

	NRCardDefs.defcard("Meru Mati", {
			"title": "Meru Mati",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Meru Mati has +3 strength while protecting HQ.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Metamorph", {
			"title": "Metamorph",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate - Observer",
			"subtypes": ["Code Gate", "Observer"],
			"text": "[subroutine] Swap 2 other installed pieces of ice or 2 of your installed non-ice cards."
		})

	NRCardDefs.defcard("Mestnichestvo", {
			"title": "Mestnichestvo",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "You can advance this ice.\nWhen the Runner encounters this ice, you may remove 1 hosted advancement counter. If you do, the Runner loses 3[credit].\n[subroutine] The Runner loses 3[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Mganga", {
			"title": "Mganga",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Trap - Psi - AP",
			"subtypes": ["Trap", "Psi", "AP"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit] or 2[credit]. Reveal spent credits. If you and the Runner spend a different number of credits, do 2 net damage; otherwise do 1 net damage. Trash Mganga."
		})

	NRCardDefs.defcard("Mind Game", {
			"title": "Mind Game",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate - Psi - Deflector",
			"subtypes": ["Code Gate", "Psi", "Deflector"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, choose another server. The Runner moves to the outermost position of that server instead of passing this ice. For the remainder of this run, the Runner must add 1 installed Runner card to the bottom of their stack as an additional cost to jack out. The Runner may jack out."
		})

	NRCardDefs.defcard("Minelayer", {
			"title": "Minelayer",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] You may install 1 piece of ice from HQ protecting this server, ignoring the install cost."
		})

	NRCardDefs.defcard("Mirāju", {
			"title": "Mirāju",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate - Deflector",
			"subtypes": ["Code Gate", "Deflector"],
			"text": "Whenever an encounter with this ice ends, if the Runner broke its printed subroutine, the Runner moves to the outermost position of Archives instead of passing this ice. They may jack out. Derez this ice.\n[subroutine] You may draw 1 card. Then, shuffle 1 card from HQ into R&D."
		})

	NRCardDefs.defcard("Mlinzi", {
			"title": "Mlinzi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 1 net damage unless the Runner trashes the top 2 cards of the stack.\n[subroutine] Do 2 net damage unless the Runner trashes the top 3 cards of the stack.\n[subroutine] Do 3 net damage unless the Runner trashes the top 4 cards of the stack."
		})

	NRCardDefs.defcard("Mother Goddess", {
			"title": "Mother Goddess",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": true,
			"cost": 4,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Mythic",
			"subtypes": ["Mythic"],
			"text": "Mother Goddess gains the subtypes of all other rezzed ice.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Muckraker", {
			"title": "Muckraker",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Sentry - Tracer - Liability",
			"subtypes": ["Sentry", "Tracer", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trace[1]. If successful, give the Runner 1 tag.\n[subroutine] Trace[2]. If successful, give the Runner 1 tag.\n[subroutine] Trace[3]. If successful, give the Runner 1 tag.\n[subroutine] End the run if the Runner is tagged."
		})

	NRCardDefs.defcard("Mycoweb", {
			"title": "Mycoweb",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] You may install 1 piece of ice from Archives, ignoring all costs.\n[subroutine] You may rez 1 installed piece of ice, paying 2[credit] less.\n[subroutine] Resolve 1 subroutine on a rezzed <strong>sentry</strong>.\n[subroutine] Resolve 1 subroutine on another rezzed <strong>code gate</strong>."
		})

	NRCardDefs.defcard("N-Pot", {
			"title": "N-Pot",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "<strong>3[credit]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] End the run.\n[subroutine] If the threat level is 2 or greater, end the run.\n[subroutine] If the threat level is 4 or greater, end the run."
		})

	NRCardDefs.defcard("Najja 1.0", {
			"title": "Najja 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Barrier - Bioroid",
			"subtypes": ["Barrier", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Nebula", {
			"title": "Nebula",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 9,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "Nebula can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] Trash 1 program."
		})

	NRCardDefs.defcard("Negotiator", {
			"title": "Negotiator",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "2[credit]: Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Gain 2[credit].\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Nerine 2.0", {
			"title": "Nerine 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate - Bioroid - AP",
			"subtypes": ["Code Gate", "Bioroid", "AP"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage. You may draw 1 card.\n[subroutine] Do 1 core damage. You may draw 1 card."
		})

	NRCardDefs.defcard("Neural Katana", {
			"title": "Neural Katana",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 3 net damage."
		})

	NRCardDefs.defcard("News Hound", {
			"title": "News Hound",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] Trace[3]. If successful, give the Runner 1 tag.\nIf a <strong>current</strong> is active, this ice gains \"[subroutine] End the run.\" after its other subroutines."
		})

	NRCardDefs.defcard("NEXT Bronze", {
			"title": "NEXT Bronze",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate - NEXT",
			"subtypes": ["Code Gate", "NEXT"],
			"text": "NEXT Bronze has +1 strength for each rezzed piece of <strong>NEXT</strong> ice.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("NEXT Diamond", {
			"title": "NEXT Diamond",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 10,
			"strength": 6,
			"factioncost": 4,
			"keywords": "Sentry - NEXT - Destroyer - AP",
			"subtypes": ["Sentry", "NEXT", "Destroyer", "AP"],
			"text": "The rez cost of this ice is lowered by 1[credit] for each other rezzed piece of <strong>NEXT</strong> ice.\n[subroutine] Do 1 core damage.\n[subroutine] Do 1 core damage.\n[subroutine] Trash 1 installed Runner card."
		})

	NRCardDefs.defcard("NEXT Gold", {
			"title": "NEXT Gold",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 8,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Sentry - NEXT - AP - Destroyer",
			"subtypes": ["Sentry", "NEXT", "AP", "Destroyer"],
			"text": "X is the number of rezzed <strong>NEXT</strong> ice.\n[subroutine] Do X net damage.\n[subroutine] Trash X programs."
		})

	NRCardDefs.defcard("NEXT Opal", {
			"title": "NEXT Opal",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Code Gate - Observer - NEXT",
			"subtypes": ["Code Gate", "Observer", "NEXT"],
			"text": "This ice gains \"[subroutine] You may install 1 card from HQ.\" for each rezzed piece of <strong>NEXT</strong> ice."
		})

	NRCardDefs.defcard("NEXT Sapphire", {
			"title": "NEXT Sapphire",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Code Gate - NEXT",
			"subtypes": ["Code Gate", "NEXT"],
			"text": "X is the number of rezzed <strong>NEXT</strong> ice.\n[subroutine] Draw up to X cards.\n[subroutine] Add up to X cards from Archives to HQ.\n[subroutine] Shuffle up to X cards from HQ into R&D."
		})

	NRCardDefs.defcard("NEXT Silver", {
			"title": "NEXT Silver",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Barrier - NEXT",
			"subtypes": ["Barrier", "NEXT"],
			"text": "This ice gains \"[subroutine] End the run.\" for each rezzed piece of <strong>NEXT</strong> ice."
		})

	NRCardDefs.defcard("Nightdancer", {
			"title": "Nightdancer",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner loses [click], if able. You have an additional [click] to spend during your next turn.\n[subroutine] The Runner loses [click], if able. You have an additional [click] to spend during your next turn."
		})

	NRCardDefs.defcard("Oduduwa", {
			"title": "Oduduwa",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 7,
			"strength": 5,
			"factioncost": 5,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters Oduduwa, place 1 advancement token on it. You may place X advancement tokens on another piece of ice. X is the number of advancement tokens on Oduduwa.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Orion", {
			"title": "Orion",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": true,
			"cost": 15,
			"strength": 8,
			"factioncost": 3,
			"keywords": "Sentry - Code Gate - Barrier",
			"subtypes": ["Sentry", "Code Gate", "Barrier"],
			"text": "Orion can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] Trash 1 program.\n[subroutine] Resolve a subroutine on another piece of rezzed ice.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Otoroshi", {
			"title": "Otoroshi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "[subroutine] You may place up to 3 advancement counters on 1 card installed in the root of a remote server. If you do, the Runner accesses that card unless they pay 3[credit]."
		})

	NRCardDefs.defcard("Owl", {
			"title": "Owl",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 0,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "[subroutine] Add 1 installed program to the top of the stack."
		})

	NRCardDefs.defcard("Pachinko", {
			"title": "Pachinko",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] End the run if the Runner is tagged.\n[subroutine] End the run if the Runner is tagged."
		})

	NRCardDefs.defcard("Palisade", {
			"title": "Palisade",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "While this ice is protecting a remote server, it gets +2 strength.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Paper Wall", {
			"title": "Paper Wall",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"strength": 1,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner fully breaks this ice, trash it.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Paywall", {
			"title": "Paywall",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 1,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner encounters this ice, they lose 1[credit].\n[subroutine] End the run unless the Runner pays 1[credit]."
		})

	NRCardDefs.defcard("Peeping Tom", {
			"title": "Peeping Tom",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters this ice, choose a card type, then reveal all cards in the grip. For the remainder of this run, this ice gains \"[subroutine] End the run unless the Runner takes 1 tag.\" for each revealed card of the chosen type."
		})

	NRCardDefs.defcard("Pharos", {
			"title": "Pharos",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "You can advance this ice. It gets +5 strength while there are 3 or more hosted advancement counters.\n[subroutine] Give the Runner 1 tag.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Phoneutria", {
			"title": "Phoneutria",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - AP - Observer",
			"subtypes": ["Sentry", "AP", "Observer"],
			"text": "When the Runner passes this ice, if there are 4 or more cards in the grip, give them 1 tag.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Ping", {
			"title": "Ping",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When you rez this ice during a run against this server, give the Runner 1 tag.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Piranhas", {
			"title": "Piranhas",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Code Gate - AP - Liability",
			"subtypes": ["Code Gate", "AP", "Liability"],
			"text": "As an additional cost to rez this ice, take 1 bad publicity or remove 1 tag.\n[subroutine] You may draw 1 card.\n[subroutine] Do 1 net damage.\n[subroutine] End the run if there are more cards in HQ than in the grip."
		})

	NRCardDefs.defcard("Pop-up Window", {
			"title": "Pop-up Window",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Code Gate - Advertisement",
			"subtypes": ["Code Gate", "Advertisement"],
			"text": "When the Runner encounters this ice, gain 1[credit].\n[subroutine] End the run unless the Runner pays 1[credit]."
		})

	NRCardDefs.defcard("Biawak", {
			"title": "Biawak",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 14,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "You can forfeit 1 agenda as you rez this ice to pay for 10[credit] of its rez cost.\n[subroutine] Trash 1 installed program or end the run.\n[subroutine] Trash 1 installed resource or end the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Pulse", {
			"title": "Pulse",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Code Gate - Harmonic",
			"subtypes": ["Code Gate", "Harmonic"],
			"text": "When you rez this ice during a run against this server, the Runner loses [click].\n[subroutine] The Runner loses 1[credit] for each rezzed piece of <strong>harmonic</strong> ice.\n[subroutine] End the run unless the Runner spends [click]."
		})

	NRCardDefs.defcard("Pup", {
			"title": "Pup",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 1 net damage unless the Runner pays 1[credit].\n[subroutine] Do 1 net damage unless the Runner pays 1[credit]."
		})

	NRCardDefs.defcard("Quandary", {
			"title": "Quandary",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] End the run."
		})

	NRCardDefs.defcard("Quicksand", {
			"title": "Quicksand",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner encounters Quicksand, place 1 power counter on Quicksand.\nQuicksand has +1 strength for each power counter on it.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Rainbow", {
			"title": "Rainbow",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 0,
			"keywords": "Sentry - Code Gate - Barrier",
			"subtypes": ["Sentry", "Code Gate", "Barrier"],
			"text": "[subroutine] End the run."
		})

	NRCardDefs.defcard("Ravana 1.0", {
			"title": "Ravana 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate - Bioroid",
			"subtypes": ["Code Gate", "Bioroid"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Resolve 1 subroutine on another rezzed <strong>bioroid</strong> ice.\n[subroutine] Resolve 1 subroutine on another rezzed <strong>bioroid</strong> ice."
		})

	NRCardDefs.defcard("Red Tape", {
			"title": "Red Tape",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] All ice has +3 strength for the remainder of this run."
		})

	NRCardDefs.defcard("Resistor", {
			"title": "Resistor",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 0,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Barrier - Tracer",
			"subtypes": ["Barrier", "Tracer"],
			"text": "Resistor has +1 strength for each tag the Runner has.\n[subroutine] Trace[4]. If successful, end the run."
		})

	NRCardDefs.defcard("Reverb", {
			"title": "Reverb",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Barrier - Harmonic",
			"subtypes": ["Barrier", "Harmonic"],
			"text": "The rez cost of this ice is lowered by 1[credit] for each other unrezzed piece of ice.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Rime", {
			"title": "Rime",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Mythic",
			"subtypes": ["Mythic"],
			"text": "During runs against this server, you can rez this ice any time you could rez non-ice cards.\nEach piece of ice protecting this server gets +1 strength.\n[subroutine] The Runner loses 1[credit]."
		})

	NRCardDefs.defcard("Rototurret", {
			"title": "Rototurret",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "[subroutine] Trash 1 installed program.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("RSVP", {
			"title": "RSVP",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner cannot spend any credits for the remainder of this run."
		})

	NRCardDefs.defcard("Sadaka", {
			"title": "Sadaka",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] Look at the top 3 cards of R&D and either arrange them in any order or shuffle R&D. You may draw 1 card.\n[subroutine] You may trash 1 card in HQ. If you do, trash 1 resource. Trash Sadaka."
		})

	NRCardDefs.defcard("Sagittarius", {
			"title": "Sagittarius",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Tracer - Destroyer",
			"subtypes": ["Sentry", "Tracer", "Destroyer"],
			"text": "[subroutine] Trace[2]. If successful, trash 1 program. If your trace strength is 5 or greater, trash 1 program."
		})

	NRCardDefs.defcard("Saisentan", {
			"title": "Saisentan",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 5,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Sentry - AP - Observer",
			"subtypes": ["Sentry", "AP", "Observer"],
			"text": "When the Runner encounters this ice, choose a card type. For the remainder of the encounter, whenever you trash a card of the chosen type with net damage from a subroutine on this ice, do 1 net damage.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Salvage", {
			"title": "Salvage",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate - Tracer",
			"subtypes": ["Code Gate", "Tracer"],
			"text": "You can advance this ice if it is rezzed. It gains \"[subroutine] Trace[2]. If successful, give the Runner 1 tag.\" for each hosted advancement counter."
		})

	NRCardDefs.defcard("Sand Storm", {
			"title": "Sand Storm",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Trap - Deflector",
			"subtypes": ["Trap", "Deflector"],
			"text": "[subroutine] If this ice is installed, move it to the outermost position protecting another server. <em>(The run continues from this new position.)</em> Trash this ice."
		})

	NRCardDefs.defcard("Sandman", {
			"title": "Sandman",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine]Add an installed Runner card to the grip.\n[subroutine]Add an installed Runner card to the grip."
		})

	NRCardDefs.defcard("Sandstone", {
			"title": "Sandstone",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner encounters this ice, place 1 virus counter on it.\nThis ice gets −1 strength for each hosted virus counter.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Sapper", {
			"title": "Sapper",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"trash": 2,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "While the Runner is accessing this ice in R&D, they must reveal it.\nWhen the Runner accesses this ice anywhere except in Archives, they encounter it.\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Scatter Field", {
			"title": "Scatter Field",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "While this ice is the only piece of ice protecting this server, it gets +4 strength.\n[subroutine] You may install 1 card from HQ.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Searchlight", {
			"title": "Searchlight",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Sentry - Tracer - Observer",
			"subtypes": ["Sentry", "Tracer", "Observer"],
			"text": "Searchlight can be advanced. X is the number of advancement tokens on Searchlight.\n[subroutine]Trace[X]. If successful, give the Runner 1 tag.\n[subroutine]Trace[X]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Seidr Adaptive Barrier", {
			"title": "Seidr Adaptive Barrier",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "Seidr Adaptive Barrier has +1 strength for each piece of ice protecting this server.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Self-Adapting Code Wall", {
			"title": "Self-Adapting Code Wall",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "The strength of Self-Adapting Code Wall cannot be lowered.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Semak-samun", {
			"title": "Semak-samun",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "The Runner cannot break the printed subroutine on this ice except using a <strong>fracter</strong>.\n[subroutine] End the run unless the Runner suffers 3 net damage."
		})

	NRCardDefs.defcard("Sensei", {
			"title": "Sensei",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] For the remainder of this run, while the Runner is encountering another piece of ice, it gains \"[subroutine] End the run.\" after its other subroutines."
		})

	NRCardDefs.defcard("Seraph", {
			"title": "Seraph",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 10,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Sentry - AP - Observer - Deep Net",
			"subtypes": ["Sentry", "AP", "Observer", "Deep Net"],
			"text": "When the Runner encounters this ice, they lose 3[credit] unless they suffer 2 net damage or take 1 tag.\n[subroutine] The Runner loses 3[credit].\n[subroutine] Do 2 net damage.\n[subroutine] Give the Runner 1 tag."
		})

	NRCardDefs.defcard("Shadow", {
			"title": "Shadow",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 3,
			"strength": 1,
			"factioncost": 1,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "Shadow can be advanced and has +1 strength for each advancement token on it.\n[subroutine] The Corp gains 2[credit].\n[subroutine] Trace[3]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Sherlock 1.0", {
			"title": "Sherlock 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Bioroid - Tracer",
			"subtypes": ["Sentry", "Bioroid", "Tracer"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Trace[4]. If successful, add 1 installed program to the top of the Runner's stack.\n[subroutine] Trace[4]. If successful, add 1 installed program to the top of the Runner's stack."
		})

	NRCardDefs.defcard("Sherlock 2.0", {
			"title": "Sherlock 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 7,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - Bioroid - Tracer",
			"subtypes": ["Sentry", "Bioroid", "Tracer"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trace[4]. If successful, add 1 installed program to the bottom of the Runner's stack.\n[subroutine] Trace[4]. If successful, add 1 installed program to the bottom of the Runner's stack.\n[subroutine] Give the Runner 1 tag."
		})

	NRCardDefs.defcard("Shinobi", {
			"title": "Shinobi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 7,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Sentry - Tracer - AP - Liability",
			"subtypes": ["Sentry", "Tracer", "AP", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trace[1]. If successful, do 1 net damage.\n[subroutine] Trace[2]. If successful, do 2 net damage.\n[subroutine] Trace[3]. If successful, do 3 net damage and end the run."
		})

	NRCardDefs.defcard("Shiro", {
			"title": "Shiro",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 6,
			"strength": 5,
			"factioncost": 4,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] Look at the top 3 cards of R&D and arrange them in any order.\n[subroutine] You may pay 1[credit]. If you do not, the Runner breaches R&D. They cannot access cards in the root of R&D during that breach."
		})

	NRCardDefs.defcard("Sleipnir", {
			"title": "Sleipnir",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] You may draw 1 card.\n[subroutine] You may shuffle 1 card from HQ or Archives into R&D.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Slot Machine", {
			"title": "Slot Machine",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters this ice, they put the top card of the stack on the bottom, then you reveal the top 3 cards of the stack.\n[subroutine] The Runner loses 3[credit].\n[subroutine] If you revealed 2 or more cards that share a type when this encounter began, gain 3[credit].\n[subroutine] If you revealed 3 or more cards that share a type when this encounter began, place 3 advancement tokens on an installed card."
		})

	NRCardDefs.defcard("Snoop", {
			"title": "Snoop",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"strength": 6,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "When the Runner encounters Snoop, reveal all cards in the Runner's grip.\n<strong>Hosted power counter:</strong> Reveal all cards in the Runner's grip. Trash 1 of those cards.\n[subroutine] Trace[3]. If successful, place 1 power counter on Snoop."
		})

	NRCardDefs.defcard("Snowflake", {
			"title": "Snowflake",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Barrier - Psi",
			"subtypes": ["Barrier", "Psi"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. End the run if you and the Runner spent a different number of credits."
		})

	NRCardDefs.defcard("Sorocaban Blade", {
			"title": "Sorocaban Blade",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "You cannot trash more than 1 installed Runner card with this ice during each encounter.\n[subroutine] Trash 1 installed resource.\n[subroutine] Trash 1 installed piece of hardware.\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Special Offer", {
			"title": "Special Offer",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Trap - Advertisement",
			"subtypes": ["Trap", "Advertisement"],
			"text": "[subroutine] The Corp gains 5[credit]. Trash Special Offer."
		})

	NRCardDefs.defcard("Spiderweb", {
			"title": "Spiderweb",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] End the run.\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Starlit Knight", {
			"title": "Starlit Knight",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Sentry - Observer",
			"subtypes": ["Sentry", "Observer"],
			"text": "Threat 4 → When the Runner encounters this ice, it gains X \"[subroutine] End the run.\" subroutines for the remainder of this run, after its other subroutines. X is equal to the number of tags the Runner has.\n[subroutine] Give the Runner 1 tag.\n[subroutine] Give the Runner 1 tag."
		})

	NRCardDefs.defcard("Stavka", {
			"title": "Stavka",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - Destroyer",
			"subtypes": ["Sentry", "Destroyer"],
			"text": "When you rez this ice, you may trash 1 of your other installed cards. If you do, this ice gets +5 strength for the remainder of the run.\n[subroutine] Trash 1 installed program.\n[subroutine] Trash 1 installed program."
		})

	NRCardDefs.defcard("Surveyor", {
			"title": "Surveyor",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "X is twice the number of ice protecting this server.\n[subroutine]Trace[X]. If successful, give the Runner 2 tags.\n[subroutine]Trace[X]. If successful, end the run."
		})

	NRCardDefs.defcard("Susanoo-no-Mikoto", {
			"title": "Susanoo-no-Mikoto",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 9,
			"strength": 7,
			"factioncost": 3,
			"keywords": "Sentry - Deflector",
			"subtypes": ["Sentry", "Deflector"],
			"text": "[subroutine] If the attacked server is not Archives, the Runner moves to the outermost position of Archives instead of passing this ice. The Runner cannot jack out this run until after they encounter a piece of ice."
		})

	NRCardDefs.defcard("Swarm", {
			"title": "Swarm",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 4,
			"keywords": "Sentry - Destroyer - Liability",
			"subtypes": ["Sentry", "Destroyer", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\nYou can advance this ice. It gains \"[subroutine] Trash 1 installed program unless the Runner pays 3[credit].\" for each hosted advancement counter."
		})

	NRCardDefs.defcard("Swordsman", {
			"title": "Swordsman",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Sentry - AP - Destroyer",
			"subtypes": ["Sentry", "AP", "Destroyer"],
			"text": "The Runner cannot break subroutines on this ice using <strong>AI</strong> programs.\n[subroutine] Trash 1 installed <strong>AI</strong> program.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("SYNC BRE", {
			"title": "SYNC BRE",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] Trace[4]. If successful, give the Runner 1 tag.\n[subroutine] Trace[2]. If successful, whenever the Runner breaches a server for the remainder of this run, they access 1 fewer card."
		})

	NRCardDefs.defcard("Syailendra", {
			"title": "Syailendra",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "You can advance this ice.\nWhen the Runner encounters this ice, if it has 3 or more hosted advancement counters, you may place 1 advancement counter on an installed card you can advance.\n[subroutine] You may place 1 advancement counter on an installed card you can advance.\n[subroutine] The Runner loses 2[credit].\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Tapestry", {
			"title": "Tapestry",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 6,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner loses [click], if able.\n[subroutine] The Corp may draw 1 card.\n[subroutine] The Corp may add 1 card from HQ to the top of R&D."
		})

	NRCardDefs.defcard("Tatu-Bola", {
			"title": "Tatu-Bola",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When the Runner passes this ice, you may swap it with a piece of ice from HQ. If you do, gain 4[credit]. <em>(The new ice is installed unrezzed. You do not pay an install cost.)</em>\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Taurus", {
			"title": "Taurus",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] Trace[2]. If successful, trash 1 piece of hardware. If your trace strength is 5 or greater, trash 1 piece of hardware."
		})

	NRCardDefs.defcard("Thimblerig", {
			"title": "Thimblerig",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When your turn begins and whenever the Runner passes this ice, you may swap this ice with another installed piece of ice.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Thoth", {
			"title": "Thoth",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": true,
			"cost": 7,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "When the Runner encounters this ice, give them 1 tag.\n[subroutine] Trace[4]. If successful, do 1 net damage for each tag the Runner has.\n[subroutine] Trace[4]. If successful, the Runner loses 1[credit] for each tag they have."
		})

	NRCardDefs.defcard("Tithe", {
			"title": "Tithe",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 1,
			"strength": 1,
			"factioncost": 0,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] Do 1 net damage.\n[subroutine] Gain 1[credit]."
		})

	NRCardDefs.defcard("Tithonium", {
			"title": "Tithonium",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 9,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Barrier - Destroyer",
			"subtypes": ["Barrier", "Destroyer"],
			"text": "You may forfeit an agenda to rez Tithonium instead of paying its rez cost.\nTithonium cannot host cards.\n[subroutine] Trash 1 program.\n[subroutine] Trash 1 program.\n[subroutine] Trash 1 resource and end the run."
		})

	NRCardDefs.defcard("TL;DR", {
			"title": "TL;DR",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The next time the Runner encounters a piece of ice during this run, that ice gains a second copy of each of its subroutines <em>(after the original subroutine)</em> for the remainder of that encounter."
		})

	NRCardDefs.defcard("TMI", {
			"title": "TMI",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 3,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "When you rez TMI, Trace[2]. If unsuccessful, derez TMI.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Tocsin", {
			"title": "Tocsin",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Code Gate - Expendable",
			"subtypes": ["Code Gate", "Expendable"],
			"text": "[click], <strong>1</strong>[credit], <strong>reveal and trash this ice from HQ:</strong> Search R&D for up to 1 <strong>barrier</strong> and up to 1 <strong>sentry</strong> and reveal them. <em>(Shuffle R&D after searching it.)</em> Add those cards to HQ.\n[subroutine] The Runner loses 2[credit].\n[subroutine] End the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Tollbooth", {
			"title": "Tollbooth",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner encounters this ice, they must pay 3[credit], if able. If they do not, end the run.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Tour Guide", {
			"title": "Tour Guide",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "This ice gains \"[subroutine] End the run.\" for each rezzed asset."
		})

	NRCardDefs.defcard("Trebuchet", {
			"title": "Trebuchet",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 7,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Sentry - Destroyer - Tracer - Liability",
			"subtypes": ["Sentry", "Destroyer", "Tracer", "Liability"],
			"text": "When you rez this ice, take 1 bad publicity.\n[subroutine] Trash 1 installed Runner card.\n[subroutine] Trace[6]. If successful, the Runner cannot steal or trash Corp cards for the remainder of this run."
		})

	NRCardDefs.defcard("Tree Line", {
			"title": "Tree Line",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Barrier - Expendable",
			"subtypes": ["Barrier", "Expendable"],
			"text": "[click], <strong>1</strong>[credit], <strong>reveal and trash this ice from HQ:</strong> Place 3 advancement counters on 1 installed piece of ice.\nYou can advance this ice. It gets +1 strength for each hosted advancement counter.\n[subroutine] Gain 1[credit]. End the run."
		})

	NRCardDefs.defcard("Tribunal", {
			"title": "Tribunal",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 7,
			"strength": 3,
			"factioncost": 0,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "[subroutine] The Runner trashes 1 of their installed cards.\n[subroutine] The Runner trashes 1 of their installed cards.\n[subroutine] The Runner trashes 1 of their installed cards."
		})

	NRCardDefs.defcard("Tributary", {
			"title": "Tributary",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": true,
			"cost": 3,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "The first time each turn a run begins, you may move this ice to the outermost position protecting the attacked server. <em>(The Runner will approach this ice.)</em>\n[subroutine] You may draw 1 card. You may install 1 piece of ice from HQ protecting another server, ignoring all costs.\n[subroutine] Each piece of ice gets +2 strength for the remainder of this run."
		})

	NRCardDefs.defcard("Troll", {
			"title": "Troll",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 1,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry",
			"subtypes": ["Sentry"],
			"text": "When the Runner encounters Troll, Trace[2]. If successful, the Runner must lose [click] or end the run."
		})

	NRCardDefs.defcard("Tsurugi", {
			"title": "Tsurugi",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 6,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "[subroutine] End the run unless the Corp pays 1[credit].\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Turing", {
			"title": "Turing",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "Turing has +3 strength while protecting a remote server.\nThe Runner cannot use <strong>AI</strong> programs to break subroutines on Turing.\n[subroutine] End the run unless the Runner spends [click][click][click]."
		})

	NRCardDefs.defcard("Turnpike", {
			"title": "Turnpike",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "When the Runner encounters this ice, they lose 1[credit].\n[subroutine] Trace[5]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Týr", {
			"title": "Týr",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 10,
			"strength": 7,
			"factioncost": 5,
			"keywords": "Sentry - Bioroid - AP - Destroyer",
			"subtypes": ["Sentry", "Bioroid", "AP", "Destroyer"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. The Corp gets +1 allotted [click] for their next turn. Only the Runner can use this ability.\n[subroutine] Do 2 core damage.\n[subroutine] Trash 1 installed Runner card. Gain 3[credit].\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Tyrant", {
			"title": "Tyrant",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 7,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "You can advance this ice if it is rezzed. It gains \"[subroutine] End the run.\" for each hosted advancement counter."
		})

	NRCardDefs.defcard("Universal Connectivity Fee", {
			"title": "Universal Connectivity Fee",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 1,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] If the Runner is not tagged, they lose 1[credit]. If the Runner is tagged, they lose all credits in their credit pool and you trash this ice."
		})

	NRCardDefs.defcard("Unsmiling Tsarevna", {
			"title": "Unsmiling Tsarevna",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "When you rez this ice during a run against this server, you may have the Runner gain 2[credit]. If you do, during each encounter with this ice for the remainder of that run, the Runner cannot break more than 1 of its printed subroutines.\n[subroutine] Give the Runner 1 tag.\n[subroutine] Do 2 net damage.\n[subroutine] You may draw 2 cards."
		})

	NRCardDefs.defcard("Upayoga", {
			"title": "Upayoga",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate - Psi",
			"subtypes": ["Code Gate", "Psi"],
			"text": "[subroutine] You and the Runner secretly spend 0[credit], 1[credit], or 2[credit]. Reveal spent credits. If you and the Runner spent a different number of credits, the Runner loses 2[credit].\n[subroutine] Resolve a subroutine on a piece of rezzed <strong>psi</strong> ice."
		})

	NRCardDefs.defcard("Uroboros", {
			"title": "Uroboros",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] Trace[4]. If successful, the Runner cannot make another run this turn.\n[subroutine] Trace[4]. If successful, end the run."
		})

	NRCardDefs.defcard("Valentão", {
			"title": "Valentão",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 5,
			"strength": 6,
			"factioncost": 3,
			"keywords": "Code Gate - Liability",
			"subtypes": ["Code Gate", "Liability"],
			"text": "As an additional cost to rez this ice, take 1 bad publicity or remove 1 tag.\n[subroutine] Gain 2[credit].\n[subroutine] The Runner loses 2[credit].\n[subroutine] End the run if you have more credits than the Runner."
		})

	NRCardDefs.defcard("Vampyronassa", {
			"title": "Vampyronassa",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 7,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "[subroutine] The Runner loses 2[credit].\n[subroutine] Gain 2[credit].\n[subroutine] Do 2 net damage.\n[subroutine] You may draw 1 or 2 cards."
		})

	NRCardDefs.defcard("Vanilla", {
			"title": "Vanilla",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 0,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] End the run."
		})

	NRCardDefs.defcard("Vasilisa", {
			"title": "Vasilisa",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Sentry - Observer",
			"subtypes": ["Sentry", "Observer"],
			"text": "When the Runner encounters this ice, you may pay 1[credit]. If you do, place 1 advancement counter on an installed card you can advance.\n[subroutine] Give the Runner 1 tag."
		})

	NRCardDefs.defcard("Veritas", {
			"title": "Veritas",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] The Corp gains 2[credit].\n[subroutine] The Runner loses 2[credit].\n[subroutine] Trace[2]. If successful, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Vertigo", {
			"title": "Vertigo",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 1,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "When the Runner passes this ice, if they have no [click] remaining, they cannot steal or trash Corp cards for the remainder of this run.\n[subroutine] The Runner loses [click]."
		})

	NRCardDefs.defcard("Vicsek", {
			"title": "Vicsek",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Trap - AP - Observer",
			"subtypes": ["Trap", "AP", "Observer"],
			"text": "[subroutine] Do X net damage and give the Runner X tags. X is equal to the number of tags the Runner has.\n[subroutine] Give the Runner 1 tag. Trash this ice."
		})

	NRCardDefs.defcard("Vikram 1.0", {
			"title": "Vikram 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Bioroid - Tracer - AP",
			"subtypes": ["Sentry", "Bioroid", "Tracer", "AP"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] The Runner cannot use programs for the remainder of this run.\n[subroutine] Trace[4]. If successful, do 1 core damage.\n[subroutine] Trace[4]. If successful, do 1 core damage."
		})

	NRCardDefs.defcard("Viktor 1.0", {
			"title": "Viktor 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 2,
			"keywords": "Code Gate - Bioroid - AP",
			"subtypes": ["Code Gate", "Bioroid", "AP"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] Do 1 core damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Viktor 2.0", {
			"title": "Viktor 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 3,
			"keywords": "Code Gate - Bioroid - Tracer - AP",
			"subtypes": ["Code Gate", "Bioroid", "Tracer", "AP"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n<strong>Hosted power counter:</strong> Do 1 core damage.\n[subroutine] Trace[2]. If successful, place 1 power counter on this ice.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Viper", {
			"title": "Viper",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 3,
			"strength": 4,
			"factioncost": 1,
			"keywords": "Code Gate - Tracer",
			"subtypes": ["Code Gate", "Tracer"],
			"text": "[subroutine] Trace[3]. If successful, the Runner loses [click], if able.\n[subroutine] Trace[3]. If successful, end the run."
		})

	NRCardDefs.defcard("Virgo", {
			"title": "Virgo",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 4,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Sentry - Tracer",
			"subtypes": ["Sentry", "Tracer"],
			"text": "[subroutine] Trace[2]. If successful, give the Runner 1 tag. If your trace strength is 5 or greater, give the Runner 1 tag."
		})

	NRCardDefs.defcard("Virtual Service Agent", {
			"title": "Virtual Service Agent",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 2,
			"factioncost": 2,
			"keywords": "Code Gate - Observer",
			"subtypes": ["Code Gate", "Observer"],
			"text": "Whenever the Runner passes this ice after encountering it, if they did not break its printed subroutine with a <strong>decoder</strong> during that encounter, give them 1 tag.\n[subroutine] The Runner loses 1[credit]."
		})

	NRCardDefs.defcard("Waiver", {
			"title": "Waiver",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 5,
			"strength": 5,
			"factioncost": 2,
			"keywords": "Code Gate - Tracer",
			"subtypes": ["Code Gate", "Tracer"],
			"text": "[subroutine] Trace[5]. If successful, the Runner reveals the grip. Trash each card revealed this way with a play or install cost of X or less. X is equal to the amount by which your trace strength exceeded the Runner's link strength."
		})

	NRCardDefs.defcard("Wall of Static", {
			"title": "Wall of Static",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 0,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "[subroutine] End the run."
		})

	NRCardDefs.defcard("Wall of Thorns", {
			"title": "Wall of Thorns",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 8,
			"strength": 5,
			"factioncost": 1,
			"keywords": "Barrier - AP",
			"subtypes": ["Barrier", "AP"],
			"text": "[subroutine] Do 2 net damage.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Watchtower", {
			"title": "Watchtower",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 3,
			"factioncost": 3,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] Search R&D for a card and add it to HQ. Shuffle R&D."
		})

	NRCardDefs.defcard("Wave", {
			"title": "Wave",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 3,
			"factioncost": 1,
			"keywords": "Code Gate - Harmonic",
			"subtypes": ["Code Gate", "Harmonic"],
			"text": "When you rez this ice during a run against this server, you may search R&D for a piece of ice and reveal it. <em>(Shuffle R&D after searching it.)</em> Add that ice to HQ.\n[subroutine] Gain 1[credit] for each rezzed piece of <strong>harmonic</strong> ice."
		})

	NRCardDefs.defcard("Weir", {
			"title": "Weir",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 3,
			"strength": 3,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner loses [click].\n[subroutine] The Runner trashes 1 card from their grip."
		})

	NRCardDefs.defcard("Wendigo", {
			"title": "Wendigo",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 2,
			"strength": 4,
			"factioncost": 2,
			"keywords": "Code Gate - Morph",
			"subtypes": ["Code Gate", "Morph"],
			"text": "Wendigo can be advanced.\nWhile Wendigo has an odd number of advancement tokens on it, it gains <strong>barrier</strong> and loses <strong>code gate</strong>.\n[subroutine] Choose a program. The Runner cannot use the chosen program for the remainder of this run."
		})

	NRCardDefs.defcard("Whirlpool", {
			"title": "Whirlpool",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 0,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Trap",
			"subtypes": ["Trap"],
			"text": "[subroutine] The Runner cannot jack out for the remainder of this run. Trash Whirlpool."
		})

	NRCardDefs.defcard("Whitespace", {
			"title": "Whitespace",
			"type": "ICE",
			"side": "Corp",
			"faction": "Neutral",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 0,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "[subroutine] The Runner loses 3[credit].\n[subroutine] If the Runner has 6[credit] or less, end the run."
		})

	NRCardDefs.defcard("Winchester", {
			"title": "Winchester",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 4,
			"factioncost": 4,
			"keywords": "Sentry - Destroyer - Tracer",
			"subtypes": ["Sentry", "Destroyer", "Tracer"],
			"text": "[subroutine] Trace[4]. If successful, trash 1 installed program.\n[subroutine] Trace[3]. If successful, trash 1 installed piece of hardware.\nWhile this ice is protecting HQ, it gains “[subroutine] Trace[3]. If successful, end the run.” after its other subroutines."
		})

	NRCardDefs.defcard("Woodcutter", {
			"title": "Woodcutter",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 4,
			"strength": 2,
			"factioncost": 3,
			"keywords": "Sentry - AP",
			"subtypes": ["Sentry", "AP"],
			"text": "You can advance this ice if it is rezzed. It gains \"[subroutine] Do 1 net damage.\" for each hosted advancement counter."
		})

	NRCardDefs.defcard("Wormhole", {
			"title": "Wormhole",
			"type": "ICE",
			"side": "Corp",
			"faction": "Weyland Consortium",
			"uniqueness": false,
			"cost": 9,
			"strength": 7,
			"factioncost": 2,
			"keywords": "Code Gate",
			"subtypes": ["Code Gate"],
			"text": "Wormhole can be advanced and its rez cost is lowered by 3 for each advancement token on it.\n[subroutine] Resolve a subroutine on another piece of rezzed ice."
		})

	NRCardDefs.defcard("Wotan", {
			"title": "Wotan",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": true,
			"cost": 14,
			"strength": 10,
			"factioncost": 5,
			"keywords": "Barrier - Bioroid",
			"subtypes": ["Barrier", "Bioroid"],
			"text": "[subroutine] End the run unless the Runner spends [click][click].\n[subroutine] End the run unless the Runner pays 3[credit].\n[subroutine] End the run unless the Runner trashes 1 installed program.\n[subroutine] End the run unless the Runner suffers 1 core damage."
		})

	NRCardDefs.defcard("Wraparound", {
			"title": "Wraparound",
			"type": "ICE",
			"side": "Corp",
			"faction": "NBN",
			"uniqueness": false,
			"cost": 2,
			"strength": 0,
			"factioncost": 1,
			"keywords": "Barrier",
			"subtypes": ["Barrier"],
			"text": "While there are no installed <strong>fracter</strong> programs, this ice gets +7 strength.\n[subroutine] End the run."
		})

	NRCardDefs.defcard("Yagura", {
			"title": "Yagura",
			"type": "ICE",
			"side": "Corp",
			"faction": "Jinteki",
			"uniqueness": false,
			"cost": 1,
			"strength": 0,
			"factioncost": 2,
			"keywords": "Code Gate - AP",
			"subtypes": ["Code Gate", "AP"],
			"text": "[subroutine] Look at the top card of R&D. You may add that card to the bottom of R&D.\n[subroutine] Do 1 net damage."
		})

	NRCardDefs.defcard("Zed 1.0", {
			"title": "Zed 1.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 2,
			"strength": 1,
			"factioncost": 2,
			"keywords": "Sentry - Bioroid - AP",
			"subtypes": ["Sentry", "Bioroid", "AP"],
			"text": "<strong>Lose [click]:</strong> Break 1 subroutine on this ice. Only the Runner can use this ability.\n[subroutine] If the Runner has lost [click] to break a subroutine during this run, do 1 core damage.\n[subroutine] If the Runner has lost [click] to break a subroutine during this run, do 1 core damage."
		})

	NRCardDefs.defcard("Zed 2.0", {
			"title": "Zed 2.0",
			"type": "ICE",
			"side": "Corp",
			"faction": "Haas-Bioroid",
			"uniqueness": false,
			"cost": 6,
			"strength": 4,
			"factioncost": 3,
			"keywords": "Sentry - Bioroid - AP - Destroyer",
			"subtypes": ["Sentry", "Bioroid", "AP", "Destroyer"],
			"text": "<strong>Lose [click][click]:</strong> Break up to 2 subroutines on this ice. Only the Runner can use this ability.\n[subroutine] Trash 1 installed piece of hardware.\n[subroutine] Trash 1 installed piece of hardware.\n[subroutine] If the Runner has lost [click] to break a subroutine during this run, do 2 core damage."
		})
