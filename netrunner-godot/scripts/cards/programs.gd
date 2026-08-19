class_name NRCardsPrograms
extends RefCounted

## Printed card data from game.cards.programs (ability lambdas live in scripts/cards/translated/).

static var _registered = false


static func register() -> void:
	if _registered:
		return
	_registered = true
	_register_all()


static func _register_all() -> void:
	NRCardDefs.defcard("Abaasy", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "The first time each turn this program fully breaks a piece of ice, you may trash 1 card from your grip to draw 1 card.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "33070",
			"title": "Abaasy",
		})

	NRCardDefs.defcard("Abagnale", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.\n[Trash]<strong>:</strong> Bypass the <strong>code gate</strong> you are encountering.",
			"code": "31021",
			"title": "Abagnale",
		})

	NRCardDefs.defcard("Adept", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter - Killer",
			"subtypes": ["Icebreaker", "Fracter", "Killer"],
			"text": "This program gets +1 strength for each unused MU.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> or <strong>barrier</strong> subroutine.",
			"code": "13017",
			"title": "Adept",
		})

	NRCardDefs.defcard("Afterimage", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Once per turn → When you encounter a <strong>sentry</strong>, you may pay 2[Credits] to bypass it. Spend credits only from <strong>stealth</strong> cards to use this ability.\nInterface → <strong>1[Credits]:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>1[Credits]:</strong> +2 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "26079",
			"title": "Afterimage",
		})

	NRCardDefs.defcard("Aghora", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Icebreaker - AI - Deva",
			"subtypes": ["Icebreaker", "AI", "Deva"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice that has a rez cost of 5 or greater.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>2[Credits]:</strong> Swap this program with a <strong>deva</strong> program from your grip.",
			"code": "10097",
			"title": "Aghora",
		})

	NRCardDefs.defcard("Algernon", {
			"type": "Program",
			"side": "Runner",
			"faction": "Adam",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 5,
			"uniqueness": true,
			"text": "When your turn begins, you may pay 2[Credits] to gain [Click]. If you do, trash Algernon when your turn ends if you did not make a successful run this turn.",
			"code": "22022",
			"title": "Algernon",
		})

	NRCardDefs.defcard("Alias", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.\nThis program cannot interface with ice protecting a remote server.",
			"code": "05041",
			"title": "Alias",
		})

	NRCardDefs.defcard("Alpha", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 7,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nThis program can only interface with the outermost piece of ice protecting a server.",
			"code": "04087",
			"title": "Alpha",
		})

	NRCardDefs.defcard("Amina", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 7,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>2[Credits]:</strong> Break up to 3 <strong>code gate</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.\nThe first time each turn this program fully breaks a piece of ice, the Corp loses 1[Credits].",
			"code": "21104",
			"title": "Amina",
		})

	NRCardDefs.defcard("Analog Dreamers", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "<strong>[Click]:</strong> Run R&D. If successful, instead of breaching R&D, you may choose 1 unrezzed non-ice card with no advancement counters on it. The Corp shuffles that card into R&D.",
			"code": "08048",
			"title": "Analog Dreamers",
		})

	NRCardDefs.defcard("Ankusa", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 6,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Whenever this program fully breaks a <strong>barrier</strong>, add that <strong>barrier</strong> to HQ.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "10101",
			"title": "Ankusa",
		})

	NRCardDefs.defcard("Atman", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "When you install this program, you may spend any number of credits to place that many power counters on it.\nThis program gets +1 strength for each hosted power counter, and it can only interface with ice of exactly equal strength.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine.",
			"code": "31030",
			"title": "Atman",
		})

	NRCardDefs.defcard("Au Revoir", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Gain 1[Credits] whenever you jack out.",
			"code": "06119",
			"title": "Au Revoir",
		})

	NRCardDefs.defcard("Audrey v2", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 0,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Virus",
			"subtypes": ["Icebreaker", "AI", "Virus"],
			"text": "Whenever you trash a card you are accessing, place 1 virus counter on this program.\nInterface → <strong>Hosted virus counter:</strong> Break up to 2 subroutines.\n<strong>Trash 1 card from your grip:</strong> +3 strength.",
			"code": "34004",
			"title": "Audrey v2",
		})

	NRCardDefs.defcard("Aumakua", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Virus",
			"subtypes": ["Icebreaker", "AI", "Virus"],
			"text": "This program gets +1 strength for each hosted virus counter.\nWhenever you expose a card, place 1 virus counter on this program.\nWhenever you finish breaching a server, if you did not steal or trash any accessed cards, place 1 virus counter on this program.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine.",
			"code": "12104",
			"title": "Aumakua",
		})

	NRCardDefs.defcard("Aurora", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "20027",
			"title": "Aurora",
		})

	NRCardDefs.defcard("Azimat", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 2,
			"factioncost": 1,
			"uniqueness": false,
			"text": "2[recurring-credit] <em>(When you install this program and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to pay trash costs.",
			"code": "35029",
			"title": "Azimat",
		})

	NRCardDefs.defcard("Baba Yaga", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 5,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "You may host any number of non-<strong>AI</strong> <strong>icebreaker</strong> programs on this program.\nThis program gains the paid abilities of all hosted <strong>icebreaker</strong> programs.",
			"code": "11088",
			"title": "Baba Yaga",
		})

	NRCardDefs.defcard("Baker", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Once per turn → [Click]<strong>:</strong> Run Archives. When you would approach Archives <em>(after passing all ice)</em>, you may pay 1[Credits] to instead change the attacked server to HQ or R&D and approach that server. Spend credits only from <strong>stealth</strong> cards to pay this cost.",
			"code": "36015",
			"title": "Baker",
		})

	NRCardDefs.defcard("Bankroll", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you make a successful run, you may place 1[Credits] from the bank on Bankroll.\n[Trash]: Take all credits from Bankroll.",
			"code": "22011",
			"title": "Bankroll",
		})

	NRCardDefs.defcard("Banner", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 5,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter - Weapon",
			"subtypes": ["Icebreaker", "Fracter", "Weapon"],
			"text": "Interface → <strong>2[Credits]:</strong> Subroutines on the <strong>barrier</strong> you are encountering cannot end the run for the remainder of this encounter.",
			"code": "34005",
			"title": "Banner",
		})

	NRCardDefs.defcard("Battering Ram", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"strength": 3,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength for the remainder of this run.",
			"code": "25052",
			"title": "Battering Ram",
		})

	NRCardDefs.defcard("Begemot", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "When you install this program, suffer 1 core damage.\nThis program gets +1 strength for each core damage you have taken this game.\nInterface → <strong>1[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.",
			"code": "33007",
			"title": "Begemot",
		})

	NRCardDefs.defcard("Berserker", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Whenever you encounter a <strong>barrier</strong>, for the remainder of that encounter this program gets +1 strength for each subroutine on that <strong>barrier</strong>.\nInterface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.",
			"code": "12041",
			"title": "Berserker",
		})

	NRCardDefs.defcard("Bishop", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Caïssa - Trojan",
			"subtypes": ["Caïssa", "Trojan"],
			"text": "Host ice gets -2 strength.\n[Click]: Host this program on a piece of ice that is not hosting a <strong>Caïssa</strong> program.\nIf this program is hosted on ice protecting a central server, its [Click] ability can only be used to host it on ice protecting a remote server. If this program is hosted on ice protecting a remote server, its [Click] ability can only be used to host it on ice protecting a central server.",
			"code": "04021",
			"title": "Bishop",
		})

	NRCardDefs.defcard("Black Orchestra", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Whenever you encounter a <strong>code gate</strong>, you may install this program from your heap.\n<strong>3[Credits]:</strong> +2 strength. Then, if this program can interface with the <strong>code gate</strong> you are encountering, break up to 2 subroutines.",
			"code": "11042",
			"title": "Black Orchestra",
		})

	NRCardDefs.defcard("BlacKat", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine. If you spent a credit from a <strong>stealth</strong> card to use this ability, instead break up to 3 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +1 strength. If you spent at least 1 credit from a <strong>stealth</strong> card to use this ability, instead +2 strength.",
			"code": "06053",
			"title": "BlacKat",
		})

	NRCardDefs.defcard("Blackstone", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>3[Credits]:</strong> +4 strength for the remainder of this run. Use this ability only by spending at least 1[Credits] from a <strong>stealth</strong> card.",
			"code": "11068",
			"title": "Blackstone",
		})

	NRCardDefs.defcard("Boi-tatá", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "If you trashed any of your installed cards this turn, paid abilities on this program cost 1[Credits] less to use.\nInterface → <strong>2[Credits]:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>3[Credits]:</strong> +3 strength.",
			"code": "34071",
			"title": "Boi-tatá",
		})

	NRCardDefs.defcard("Botulus", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus - Trojan",
			"subtypes": ["Virus", "Trojan"],
			"text": "Install only on a piece of ice. <em>(If the host ice is uninstalled, this program is trashed.)</em>\nWhen you install this program and when your turn begins, place 1 virus counter on this program.\n<strong>Hosted virus counter:</strong> Break 1 subroutine on host ice.",
			"code": "30004",
			"title": "Botulus",
		})

	NRCardDefs.defcard("Brahman", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 3,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 subroutines.\n<strong>2[Credits]:</strong> +1 strength.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, add 1 installed non-<strong>virus</strong> program to the top of your stack.",
			"code": "10062",
			"title": "Brahman",
		})

	NRCardDefs.defcard("Breach", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>2[Credits]:</strong> Break up to 3 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +4 strength.\nThis program cannot interface with ice protecting a remote server.",
			"code": "05042",
			"title": "Breach",
		})

	NRCardDefs.defcard("Bug", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Install only if you made a successful run on HQ this turn.\nWhenever the Corp draws a card, you may pay 2[Credits] to reveal that card.",
			"code": "05043",
			"title": "Bug",
		})

	NRCardDefs.defcard("Bukhgalter", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nThe first time each turn this program fully breaks a piece of ice, gain 2[Credits].",
			"code": "26016",
			"title": "Bukhgalter",
		})

	NRCardDefs.defcard("Buzzsaw", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>3[Credits]:</strong> +1 strength.",
			"code": "30005",
			"title": "Buzzsaw",
		})

	NRCardDefs.defcard("Cache", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Place 3 virus counters on Cache when it is installed.\n<strong>Hosted virus counter:</strong> Gain 1[Credits].",
			"code": "29004",
			"title": "Cache",
		})

	NRCardDefs.defcard("Carmen", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "If you made a successful run this turn, this program costs 2[Credits] less to install.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "30015",
			"title": "Carmen",
		})

	NRCardDefs.defcard("Cerberus \"Cuj.0\" H3", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>Hosted power counter:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "06094",
			"title": "Cerberus \"Cuj.0\" H3",
		})

	NRCardDefs.defcard("Cerberus \"Lady\" H1", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>Hosted power counter:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "29006",
			"title": "Cerberus \"Lady\" H1",
		})

	NRCardDefs.defcard("Cerberus \"Rex\" H2", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>Hosted power counter:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "06096",
			"title": "Cerberus \"Rex\" H2",
		})

	NRCardDefs.defcard("Cezve", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "2[recurring-credit] <em>(When you install this card and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits during runs on central servers.",
			"code": "33017",
			"title": "Cezve",
		})

	NRCardDefs.defcard("Chakana", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on R&D, place 1 virus counter on Chakana.\nIf there are at least 3 virus counters on Chakana, the advancement requirement of all agendas is increased by 1.",
			"code": "03043",
			"title": "Chakana",
		})

	NRCardDefs.defcard("Chameleon", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker",
			"subtypes": ["Icebreaker"],
			"text": "When you install this program, choose <strong>barrier</strong>, <strong>code gate</strong>, or <strong>sentry</strong>.\nWhen your discard phase ends, add this program to your grip.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice that has the chosen subtype.",
			"code": "31031",
			"title": "Chameleon",
		})

	NRCardDefs.defcard("Chisel", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Virus - Trojan",
			"subtypes": ["Virus", "Trojan"],
			"text": "Install only on a piece of ice.\nHost ice gets −1 strength for each hosted virus counter.\nWhenever you encounter host ice, if its strength is 0 or less, trash it. Otherwise, place 1 virus counter on this program.",
			"code": "26003",
			"title": "Chisel",
		})

	NRCardDefs.defcard("Chromatophores", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nHost ice gains <strong>barrier</strong>, <strong>code gate</strong>, and <strong>sentry</strong>.",
			"code": "35030",
			"title": "Chromatophores",
		})

	NRCardDefs.defcard("Cat's Cradle", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "The rez cost of each piece of <strong>code gate</strong> ice is increased by 1[Credits].\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "33016",
			"title": "Cat's Cradle",
		})

	NRCardDefs.defcard("Cleaver", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +1 strength.",
			"code": "30006",
			"title": "Cleaver",
		})

	NRCardDefs.defcard("Cloak", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Stealth",
			"subtypes": ["Stealth"],
			"text": "1[recurring-credit]\nUse this credit to pay for using <strong>icebreakers</strong>.",
			"code": "03041",
			"title": "Cloak",
		})

	NRCardDefs.defcard("Clot", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "The Corp cannot score an agenda during the same turn they installed that agenda.\nWhen the Corp purges virus counters, trash this program.",
			"code": "31005",
			"title": "Clot",
		})

	NRCardDefs.defcard("Coalescence", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When you install this program, place 2 power counters on it.\n<strong>Hosted power counter:</strong> Gain 2[Credits]. Use this ability only during your turn.",
			"code": "34089",
			"title": "Coalescence",
		})

	NRCardDefs.defcard("Collective Consciousness", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Draw 1 card whenever the Corp rezzes a piece of ice.",
			"code": "06116",
			"title": "Collective Consciousness",
		})

	NRCardDefs.defcard("Conduit", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever a successful run on R&D ends, you may place 1 virus counter on this program.\n[Click]<strong>:</strong> Run R&D. If successful, access X additional cards when you breach R&D. X is equal to the number of hosted virus counters.",
			"code": "30024",
			"title": "Conduit",
		})

	NRCardDefs.defcard("Consume", {
			"type": "Program",
			"side": "Runner",
			"faction": "Apex",
			"cost": 2,
			"memoryunits": 0,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you trash a Corp card, you may place 1 virus counter on Consume.\n[Click]: Gain 2[Credits] for each hosted virus counter, then remove all virus counters from Consume.",
			"code": "21068",
			"title": "Consume",
		})

	NRCardDefs.defcard("Copycat", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "Whenever you pass a piece of ice, you may trash Copycat. If you do, choose another rezzed copy of that piece of ice protecting any server. The run continues as if you had just passed the chosen piece of ice (you are now running from the new position).",
			"code": "04025",
			"title": "Copycat",
		})

	NRCardDefs.defcard("Cordyceps", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When you install this program, place 2 virus counters on it.\nOnce per turn → When you make a successful run on a central server, you may remove 1 hosted virus counter to swap 1 piece of ice protecting that server with another installed piece of ice.",
			"code": "26086",
			"title": "Cordyceps",
		})

	NRCardDefs.defcard("Corroder", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "31006",
			"title": "Corroder",
		})

	NRCardDefs.defcard("Corsair", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> The <strong>barrier</strong> you are encountering gets −3 strength for the remainder of this encounter. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "36004",
			"title": "Corsair",
		})

	NRCardDefs.defcard("Cradle", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 5,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "This program gets -1 strength for each card in your grip.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>code gate</strong> subroutines.",
			"code": "22006",
			"title": "Cradle",
		})

	NRCardDefs.defcard("Creeper", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Cloud",
			"subtypes": ["Icebreaker", "Killer", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "02089",
			"title": "Creeper",
		})

	NRCardDefs.defcard("Crescentus", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "<strong>[Trash]:</strong> Derez 1 piece of ice you fully broke during this encounter.",
			"code": "02065",
			"title": "Crescentus",
		})

	NRCardDefs.defcard("Crowbar", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Cloud",
			"subtypes": ["Icebreaker", "Decoder", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nThis program gets +1 strength for each installed <strong>icebreaker</strong>.\nInterface → <strong>[Trash]:</strong> Break up to 3 <strong>code gate</strong> subroutines.",
			"code": "08046",
			"title": "Crowbar",
		})

	NRCardDefs.defcard("Crypsis", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 5,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Virus",
			"subtypes": ["Icebreaker", "AI", "Virus"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>[Click]:</strong> Place 1 virus counter on this program.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, remove 1 hosted virus counter or trash this program.",
			"code": "25061",
			"title": "Crypsis",
		})

	NRCardDefs.defcard("Cupellation", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Limit 1 hosted card.\nAccess → <strong>1[Credits]:</strong> Host the non-agenda card you are accessing faceup on this program. <em>(If it was installed, it becomes uninstalled.)</em>\nWhenever you breach HQ, if this program has a hosted Corp card, you may pay 1[Credits] and trash this program to access 2 additional cards.",
			"code": "34080",
			"title": "Cupellation",
		})

	NRCardDefs.defcard("Curupira", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Whenever you encounter a <strong>barrier</strong>, you may spend 3 hosted power counters to bypass it.\nWhenever this program fully breaks a piece of ice, place 1 power counter on this program.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "34015",
			"title": "Curupira",
		})

	NRCardDefs.defcard("Customized Secretary", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When you install Customized Secretary reveal the top 5 cards of the stack. You may host any number of revealed programs from your stack on it. Shuffle your stack.\n[Click]: Install a hosted program, paying all install costs.",
			"code": "12027",
			"title": "Customized Secretary",
		})

	NRCardDefs.defcard("Cyber-Cypher", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"strength": 4,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "When you install this program, choose a server. Use this program only during runs on the chosen server.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "03044",
			"title": "Cyber-Cypher",
		})

	NRCardDefs.defcard("D4v1d", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"text": "Place 3 power counters on D4v1d when it is installed.\n<strong>Hosted power counter:</strong> Break ice subroutine on a piece of ice that has a strength of 5 or greater.",
			"code": "06033",
			"title": "D4v1d",
		})

	NRCardDefs.defcard("Dagger", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +5 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "03042",
			"title": "Dagger",
		})

	NRCardDefs.defcard("Dai V", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 6,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>2[Credits]:</strong> Break all subroutines. Spend credits only from <strong>stealth</strong> cards to use this ability.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "11006",
			"title": "Dai V",
		})

	NRCardDefs.defcard("Darwin", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Virus",
			"subtypes": ["Icebreaker", "AI", "Virus"],
			"text": "Interface → 2[Credits]: Break 1 subroutine.\nX is equal to the number of hosted virus counters.\nWhen your turn begins, you may pay 1[Credits] to place 1 virus counter on this program.",
			"code": "20008",
			"title": "Darwin",
		})

	NRCardDefs.defcard("Datasucker", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on a central server, place 1 virus counter on Datasucker.\n<strong>Hosted virus counter:</strong> Rezzed piece of ice currently being encountered has -1 strength until the end of the encounter.",
			"code": "25011",
			"title": "Datasucker",
		})

	NRCardDefs.defcard("DaVinci", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you make a successful run, place 1 power counter on DaVinci.\n[Trash]: Install a card from your grip with an install cost equal to or less than the number of power counters on DaVinci, ignoring the install cost.",
			"code": "08107",
			"title": "DaVinci",
		})

	NRCardDefs.defcard("Deep Thought", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on R&D, place 1 virus counter on Deep Thought.\nIf there are at least 3 virus counters on Deep Thought, it gains \"When your turn begins, you may look at the top card of R&D.\"",
			"code": "02108",
			"title": "Deep Thought",
		})

	NRCardDefs.defcard("Demara", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.\n<strong>[Trash]:</strong> Bypass the <strong>barrier</strong> you are encountering.",
			"code": "25034",
			"title": "Demara",
		})

	NRCardDefs.defcard("Deus X", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 10,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker",
			"subtypes": ["Icebreaker"],
			"text": "Interface → <strong>[Trash]:</strong> Break any number of <strong>AP</strong> subroutines.\n[interrupt] → <strong>[Trash]:</strong> Prevent any amount of net damage.",
			"code": "25053",
			"title": "Deus X",
		})

	NRCardDefs.defcard("Devadatta Drone", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "When you install this program, place 2 power counters on it.\nWhenever you breach R&D, you may remove 1 hosted power counter to access 1 additional card.",
			"code": "35031",
			"title": "Devadatta Drone",
		})

	NRCardDefs.defcard("Dhegdheer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Daemon",
			"subtypes": ["Daemon"],
			"text": "You can install other programs onto this program. Each program installed this way costs 1[Credits] less to install. Limit 1 hosted program.\nThe memory cost of the hosted program does not count against your memory limit.",
			"code": "13020",
			"title": "Dhegdheer",
		})

	NRCardDefs.defcard("Disrupter", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[interrupt] → [Trash]: Reduce the base trace strength of a trace to 0.",
			"code": "02061",
			"title": "Disrupter",
		})

	NRCardDefs.defcard("Diwan", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When you install this program, choose a server. As an additional cost to install a card in the root of or protecting that server, the Corp must pay 1[Credits].\nWhen the Corp purges virus counters, trash this program.",
			"code": "10021",
			"title": "Diwan",
		})

	NRCardDefs.defcard("Djinn", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Daemon",
			"subtypes": ["Daemon"],
			"text": "Djinn can host up to 3[Memory Unit] of non-<strong>icebreaker</strong> programs.\nThe memory costs of hosted programs do not count against your memory limit.\n[Click], 1[Credits]: Search your stack for a <strong>virus</strong> program, reveal it, and add it to your grip. Shuffle your stack.",
			"code": "01009",
			"title": "Djinn",
		})

	NRCardDefs.defcard("Eater", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine. You cannot access cards for the remainder of this run.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "07040",
			"title": "Eater",
		})

	NRCardDefs.defcard("Echelon", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "This program gets +1 strength for each installed <strong>icebreaker</strong> <em>(including this one)</em>.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +2 strength.",
			"code": "30025",
			"title": "Echelon",
		})

	NRCardDefs.defcard("Egret", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a rezzed piece of ice.\nHost ice gains <strong>barrier</strong>, <strong>code gate</strong>, and <strong>sentry</strong>.",
			"code": "31032",
			"title": "Egret",
		})

	NRCardDefs.defcard("Endless Hunger", {
			"type": "Program",
			"side": "Runner",
			"faction": "Apex",
			"cost": 0,
			"strength": 11,
			"memoryunits": 4,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker",
			"subtypes": ["Icebreaker"],
			"text": "Interface → <strong>Trash 1 installed card:</strong> Break 1 \"[subroutine] End the run.\" subroutine.",
			"code": "09033",
			"title": "Endless Hunger",
		})

	NRCardDefs.defcard("Engolo", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Once per turn → When you encounter a piece of ice, you may pay 2[Credits]. If you do, it gains <strong>code gate</strong> for the remainder of that encounter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +4 strength.",
			"code": "21108",
			"title": "Engolo",
		})

	NRCardDefs.defcard("Equivocation", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": true,
			"text": "Whenever you make a successful run on R&D, you may reveal the top card of R&D. If you do, you may force the Corp to draw that card.",
			"code": "11084",
			"title": "Equivocation",
		})

	NRCardDefs.defcard("Euler", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>0[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine. Use this ability only if this program was installed this turn.\nInterface → <strong>2[Credits]:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "26087",
			"title": "Euler",
		})

	NRCardDefs.defcard("eXer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you breach R&D, access 1 additional card.\nWhen the Corp purges virus counters, trash this program.",
			"code": "21041",
			"title": "eXer",
		})

	NRCardDefs.defcard("Expert Schedule Analyzer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "<strong>[Click]:</strong> Run HQ. If successful, instead of breaching HQ, you may reveal all cards in HQ.",
			"code": "04045",
			"title": "Expert Schedule Analyzer",
		})

	NRCardDefs.defcard("Faerie", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → 0[Credits]: Break 1 <strong>sentry</strong> subroutine.\n1[Credits]: +1 strength.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, trash this program.",
			"code": "25035",
			"title": "Faerie",
		})

	NRCardDefs.defcard("False Echo", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Whenever you pass a piece of unrezzed ice, you may trash False Echo. If you do, the Corp must rez that ice or add it to HQ.",
			"code": "04007",
			"title": "False Echo",
		})

	NRCardDefs.defcard("Faust", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>Trash a card from your grip:</strong> Break 1 subroutine.\n<strong>Trash a card from your grip:</strong> +2 strength.",
			"code": "08061",
			"title": "Faust",
		})

	NRCardDefs.defcard("Fawkes", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>X[Credits]:</strong> +X strength for the remainder of this run. Use this ability only by spending at least 1 credit from a <strong>stealth</strong> card.",
			"code": "11108",
			"title": "Fawkes",
		})

	NRCardDefs.defcard("Femme Fatale", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 9,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength.\nWhen you install this program, choose 1 installed piece of ice.\nWhenever you encounter the chosen ice, you may pay 1[Credits] for each subroutine it has. If you do, bypass that ice.",
			"code": "31022",
			"title": "Femme Fatale",
		})

	NRCardDefs.defcard("Fermenter", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When you install this program and when your turn begins, place 1 virus counter on this program.\n[Click], [Trash]<strong>:</strong> Gain 2[Credits] for each hosted virus counter.",
			"code": "30007",
			"title": "Fermenter",
		})

	NRCardDefs.defcard("Flashbang", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>6[Credits]:</strong> Derez the <strong>sentry</strong> you are encountering.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "12085",
			"title": "Flashbang",
		})

	NRCardDefs.defcard("Flux Capacitor", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nThe first time you break a subroutine during each encounter with host ice, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>",
			"code": "33087",
			"title": "Flux Capacitor",
		})

	NRCardDefs.defcard("Force of Nature", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>code gate</strong> subroutines.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "25012",
			"title": "Force of Nature",
		})

	NRCardDefs.defcard("Garrote", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 7,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "04065",
			"title": "Garrote",
		})

	NRCardDefs.defcard("Gauss", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "When you install this program, it gets +3 strength for the remainder of the turn.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "26024",
			"title": "Gauss",
		})

	NRCardDefs.defcard("Gingerbread", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker",
			"subtypes": ["Icebreaker"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>tracer</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "05044",
			"title": "Gingerbread",
		})

	NRCardDefs.defcard("God of War", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Virus",
			"subtypes": ["Icebreaker", "AI", "Virus"],
			"text": "When your turn begins, you may take 1 tag to place 2 virus counters on this program.\nInterface → <strong>Hosted virus counter:</strong> Break 1 subroutine.\n<strong>2[Credits]:</strong> +1 strength.",
			"code": "12082",
			"title": "God of War",
		})

	NRCardDefs.defcard("Golden", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → 2[Credits]: Break up to 2 <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +4 strength.\n<strong>2[Credits]</strong>, <strong>add this program to your grip:</strong> Derez 1 <strong>sentry</strong> this program fully broke during this encounter.",
			"code": "11025",
			"title": "Golden",
		})

	NRCardDefs.defcard("Gordian Blade", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength for the remainder of this run.",
			"code": "31033",
			"title": "Gordian Blade",
		})

	NRCardDefs.defcard("Gorman Drip v1", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever the Corp spends a [Click] to draw 1 card or gain 1[Credits] (not through a card ability), place 1 virus counter on Gorman Drip v1.\n[Click], [Trash]: Gain 1[Credits] for each virus counter on Gorman Drip v1.",
			"code": "04005",
			"title": "Gorman Drip v1",
		})

	NRCardDefs.defcard("Gourmand", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Access → [Trash]<strong>:</strong> Trash the non-agenda card you are accessing. If you do, draw 1 card.",
			"code": "35007",
			"title": "Gourmand",
		})

	NRCardDefs.defcard("Grappling Hook", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "[Trash]: Break all but 1 subroutine on a piece of ice.",
			"code": "05045",
			"title": "Grappling Hook",
		})

	NRCardDefs.defcard("Gravedigger", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever an installed Corp card is trashed, place 1 virus counter on Gravedigger.\n[Click], <strong>hosted virus counter:</strong> The Corp trashes the top card of R&D.",
			"code": "07041",
			"title": "Gravedigger",
		})

	NRCardDefs.defcard("GS Sherman M3", {
			"type": "Program",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter - Cloud",
			"subtypes": ["Icebreaker", "Fracter", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "09050",
			"title": "GS Sherman M3",
		})

	NRCardDefs.defcard("GS Shrike M2", {
			"type": "Program",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 5,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Cloud",
			"subtypes": ["Icebreaker", "Killer", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "09049",
			"title": "GS Shrike M2",
		})

	NRCardDefs.defcard("GS Striker M1", {
			"type": "Program",
			"side": "Runner",
			"faction": "Sunny Lebeau",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Cloud",
			"subtypes": ["Icebreaker", "Decoder", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>code gate</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "09048",
			"title": "GS Striker M1",
		})

	NRCardDefs.defcard("Harbinger", {
			"type": "Program",
			"side": "Runner",
			"faction": "Apex",
			"cost": 0,
			"memoryunits": 0,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[interrupt] → When this program would be trashed, turn it facedown instead of adding it to your heap. <em>(It is still considered trashed.)</em>",
			"code": "09034",
			"title": "Harbinger",
		})

	NRCardDefs.defcard("Heliamphora", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "[interrupt] → Whenever you would access a card in Archives, you may host it faceup on this program instead. <em>(It is not installed.)</em> Use this ability only once each time you breach Archives.\nWhen the Corp purges virus counters, they trash 2 cards from HQ at random. Trash this program.",
			"code": "34072",
			"title": "Heliamphora",
		})

	NRCardDefs.defcard("Hantu", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Virus",
			"subtypes": ["Icebreaker", "Killer", "Virus"],
			"text": "When you install this program, place 2 virus counters on it.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>Hosted virus counter:</strong> +2 strength.",
			"code": "35008",
			"title": "Hantu",
		})

	NRCardDefs.defcard("Hemorrhage", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run, place 1 virus counter on Hemorrhage.\n[Click], <strong>2 hosted virus counters:</strong> The Corp trashes 1 card from HQ.",
			"code": "20012",
			"title": "Hemorrhage",
		})

	NRCardDefs.defcard("Hivemind", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 2,
			"factioncost": 5,
			"uniqueness": true,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Place 1 virus counter on Hivemind when it is installed.\nVirus counters on Hivemind are considered to be hosted on all other <strong>virus</strong> programs for the purposes of card effects (and can be spent as if on them).",
			"code": "07042",
			"title": "Hivemind",
		})

	NRCardDefs.defcard("Houdini", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +4 strength for the remainder of this run. Use this ability only by spending at least 1 credit from a <strong>stealth</strong> card.",
			"code": "11045",
			"title": "Houdini",
		})

	NRCardDefs.defcard("Hush", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nHost ice cannot gain abilities and loses all abilities except its printed subroutines.\n<strong>[Click]:</strong> Host this program on another installed piece of ice.",
			"code": "33071",
			"title": "Hush",
		})

	NRCardDefs.defcard("Hyperbaric", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "When you install this program, place 1 power counter on it.\nThis program gets +1 strength for each hosted power counter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> Place 1 power counter on this program.",
			"code": "33026",
			"title": "Hyperbaric",
		})

	NRCardDefs.defcard("Hyperdriver", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 3,
			"factioncost": 3,
			"uniqueness": false,
			"text": "When your turn begins, you may remove Hyperdriver from the game and gain [Click][Click][Click].",
			"code": "08070",
			"title": "Hyperdriver",
		})

	NRCardDefs.defcard("Ika", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Trojan",
			"subtypes": ["Icebreaker", "Killer", "Trojan"],
			"text": "<strong>2[Credits]:</strong> Host this program on a piece of ice.\nInterface → <strong>1[Credits]:</strong> Break up to 2 subroutines on host <strong>sentry</strong>.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "22019",
			"title": "Ika",
		})

	NRCardDefs.defcard("Imp", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When you install this program, place 2 virus counters on it.\nAccess, once per turn → <strong>Hosted virus counter:</strong> Trash the card you are accessing.",
			"code": "31007",
			"title": "Imp",
		})

	NRCardDefs.defcard("Incubator", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When your turn begins, place 1 virus counter on Incubator.\n[Click], [Trash]: Move all virus counters from Incubator to another installed <strong>virus</strong> program.",
			"code": "06113",
			"title": "Incubator",
		})

	NRCardDefs.defcard("Inti", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength for the remainder of this run.",
			"code": "03048",
			"title": "Inti",
		})

	NRCardDefs.defcard("Inversificator", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 6,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "The first time each turn you pass a piece of ice after an encounter during which this program fully broke that ice, you may swap it with another installed piece of ice.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "12048",
			"title": "Inversificator",
		})

	NRCardDefs.defcard("Ixodidae", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever the Corp loses at least 1[Credits], gain 1[Credits].\nTrash Ixodidae if the Corp purges virus counters.",
			"code": "06114",
			"title": "Ixodidae",
		})

	NRCardDefs.defcard("K2CP Turbine", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"text": "Each installed non-<strong>AI</strong> <strong>icebreaker</strong> gets +2 strength.",
			"code": "33090",
			"title": "K2CP Turbine",
		})

	NRCardDefs.defcard("Keyhole", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "<strong>[Click]:</strong> Run R&D. If successful, instead of breaching R&D, look at the top 3 cards of R&D. Trash 1 of those cards, then the Corp shuffles R&D.\n",
			"code": "04061",
			"title": "Keyhole",
		})

	NRCardDefs.defcard("Knight", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"strength": 7,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Caïssa - Trojan",
			"subtypes": ["Icebreaker", "AI", "Caïssa", "Trojan"],
			"text": "Interface → <strong>2[Credits]:</strong> Break 1 subroutine on host ice.\n<strong>[Click]:</strong> Host this program on a piece of ice that is not hosting a <strong>Caïssa</strong> program.\nIf this program is hosted on ice, its [Click] ability cannot be used to host it on the next inward or outward piece of ice.",
			"code": "04043",
			"title": "Knight",
		})

	NRCardDefs.defcard("Kyuban", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nWhenever you pass host ice, gain 2[Credits].",
			"code": "22020",
			"title": "Kyuban",
		})

	NRCardDefs.defcard("Laamb", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Once per turn → When you encounter a piece of ice, you may pay 2[Credits]. If you do, it gains <strong>barrier</strong> for the remainder of that encounter.\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.\n<strong>3[Credits]:</strong> +6 strength.",
			"code": "21086",
			"title": "Laamb",
		})

	NRCardDefs.defcard("Lampades", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When you install this program, place 3 power counters on it.\nAccess → <strong>Hosted power counter</strong>, <strong>pay the printed rez or play cost of the card you are accessing:</strong> Trash that card. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "36005",
			"title": "Lampades",
		})

	NRCardDefs.defcard("Lamprey", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on HQ, the Corp loses 1[Credits].\nTrash Lamprey if the Corp purges virus counters.",
			"code": "25014",
			"title": "Lamprey",
		})

	NRCardDefs.defcard("Laser Pointer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Weapon",
			"subtypes": ["Weapon"],
			"text": "Whenever you encounter a piece of <strong>AP</strong>, <strong>destroyer</strong>, or <strong>observer</strong> ice, you may trash this program to bypass that ice.",
			"code": "34016",
			"title": "Laser Pointer",
		})

	NRCardDefs.defcard("Leech", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on a central server, place 1 virus counter on this program.\n<strong>Hosted virus counter:</strong> The ice you are encountering gets -1 strength for the remainder of this encounter.",
			"code": "30008",
			"title": "Leech",
		})

	NRCardDefs.defcard("Leprechaun", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Daemon",
			"subtypes": ["Daemon"],
			"text": "Leprechaun can host up to 2 programs. The memory costs of hosted programs do not count against your memory limit.",
			"code": "06019",
			"title": "Leprechaun",
		})

	NRCardDefs.defcard("Leviathan", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 6,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>3[Credits]:</strong> Break up to 3 <strong>code gate</strong> subroutines.\n<strong>3[Credits]:</strong> +5 strength.",
			"code": "04026",
			"title": "Leviathan",
		})

	NRCardDefs.defcard("Living Mural", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Trojan",
			"subtypes": ["Icebreaker", "Killer", "Trojan"],
			"text": "Install only on a piece of ice.\nThreat 4 → When you install this program, it gets +3 strength for the remainder of the turn. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine on a <strong>sentry</strong> protecting this server.\n<strong>1[Credits]:</strong> +2 strength.",
			"code": "34024",
			"title": "Living Mural",
		})

	NRCardDefs.defcard("LLDS Energy Regulator", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[interrupt] → <strong>3[Credits]</strong> or [Trash]<strong>:</strong> Prevent a player from trashing 1 installed piece of hardware.",
			"code": "06039",
			"title": "LLDS Energy Regulator",
		})

	NRCardDefs.defcard("Lobisomem", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 8,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Fracter",
			"subtypes": ["Icebreaker", "Decoder", "Fracter"],
			"text": "When you install this program and whenever it fully breaks a <strong>code gate</strong>, place 1 power counter on this program.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\nInterface → <strong>X[Credits]</strong>, <strong>hosted power counter:</strong> Break X <strong>barrier</strong> subroutines.\n<strong>1[Credits]:</strong> +2 strength.",
			"code": "34090",
			"title": "Lobisomem",
		})

	NRCardDefs.defcard("Lustig", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +5 strength.\n<strong>[Trash]:</strong> Bypass the <strong>sentry</strong> you are encountering.",
			"code": "13007",
			"title": "Lustig",
		})

	NRCardDefs.defcard("Magnum Opus", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "[Click]: Gain 2[Credits].",
			"code": "20050",
			"title": "Magnum Opus",
		})

	NRCardDefs.defcard("Makler", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>2[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +2 strength.\nThe first time each turn this program fully breaks a piece of ice, gain 1[Credits].",
			"code": "26080",
			"title": "Makler",
		})

	NRCardDefs.defcard("Malandragem", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"text": "When you install this program, load 2 power counters onto it. When it is empty, remove it from the game.\nOnce per turn → When you encounter a piece of ice, if its strength is 3 or less, you may remove 1 hosted power counter to bypass it.\nThreat 4 → Whenever you encounter a piece of ice, you may remove this program from the game to bypass it.",
			"code": "34081",
			"title": "Malandragem",
		})

	NRCardDefs.defcard("Mammon", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "When your turn begins, you may spend any number of credits to place that many power counters on this program.\nWhen your discard phase ends, remove all hosted power counters.\nInterface → <strong>Hosted power counter:</strong> Break 1 subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "13009",
			"title": "Mammon",
		})

	NRCardDefs.defcard("Mantle", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Stealth",
			"subtypes": ["Stealth"],
			"text": "1[recurring-credit]\nYou can spend hosted credits to use hardware and programs.",
			"code": "26088",
			"title": "Mantle",
		})

	NRCardDefs.defcard("Marjanah", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine. If you made a successful run this turn, this ability costs 1[Credits] less to use.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "30016",
			"title": "Marjanah",
		})

	NRCardDefs.defcard("Mass-Driver", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 8,
			"strength": 1,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Whenever this program fully breaks a piece of ice, the first 3 subroutines of the next encounter this run do not resolve.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "12067",
			"title": "Mass-Driver",
		})

	NRCardDefs.defcard("Matryoshka", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 3,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "When your turn begins, turn each hosted card faceup.\n[Click]<strong>:</strong> Host a copy of Matryoshka from your grip faceup on this program. <em>(It is not installed.)</em>\nInterface → <strong>X[Credits]</strong>, <strong>turn 1 hosted copy of Matryoshka facedown:</strong> Break X subroutines.\n<strong>1[Credits]:</strong> +1 strength.\nLimit 6 per deck.",
			"code": "33094",
			"title": "Matryoshka",
		})

	NRCardDefs.defcard("Maven", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 5,
			"strength": 0,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "This program gets +1 strength for each installed program.\nInterface → <strong>2[Credits]:</strong> Break 1 subroutine.",
			"code": "12087",
			"title": "Maven",
		})

	NRCardDefs.defcard("Mayfly", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 1,
			"strength": 1,
			"memoryunits": 2,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine. When this run ends, trash this program.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "30032",
			"title": "Mayfly",
		})

	NRCardDefs.defcard("Medium", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on R&D, place 1 virus counter on this program.\nWhenever you breach R&D, choose a number less than the number of hosted virus counters. Access that many additional cards.",
			"code": "29001",
			"title": "Medium",
		})

	NRCardDefs.defcard("Mimic", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.",
			"code": "31008",
			"title": "Mimic",
		})

	NRCardDefs.defcard("Misdirection", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "[Click], [Click], X[Credits]: Remove X tags.",
			"code": "11085",
			"title": "Misdirection",
		})

	NRCardDefs.defcard("MKUltra", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Whenever you encounter a <strong>sentry</strong>, you may install this program from your heap.\n<strong>3[Credits]:</strong> +2 strength. Then, if this program can interface with the <strong>sentry</strong> you are encountering, break up to 2 subroutines.",
			"code": "11081",
			"title": "MKUltra",
		})

	NRCardDefs.defcard("Mongoose", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "You cannot use this program to break subroutines on more than one ice per run.\nInterface → <strong>1[Credits]:</strong> Break up to 2 <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "10005",
			"title": "Mongoose",
		})

	NRCardDefs.defcard("Monkeywrench", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nHost ice gets −2 strength. Each other piece of ice protecting this server gets −1 strength.",
			"code": "34006",
			"title": "Monkeywrench",
		})

	NRCardDefs.defcard("Morning Star", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 8,
			"strength": 5,
			"memoryunits": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break any number of <strong>barrier</strong> subroutines.",
			"code": "20014",
			"title": "Morning Star",
		})

	NRCardDefs.defcard("Multithreader", {
			"type": "Program",
			"side": "Runner",
			"faction": "Adam",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "2[recurring-credit]\nUse these credits to pay for using programs.",
			"code": "09040",
			"title": "Multithreader",
		})

	NRCardDefs.defcard("Musaazi", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"strength": 1,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Virus",
			"subtypes": ["Icebreaker", "Killer", "Virus"],
			"text": "Whenever you make a successful run, you may place 1 virus counter on this program.\nInterface → <strong>Any virus counter:</strong> Break <strong>sentry</strong> subroutine.\n<strong>Any virus counter:</strong> +1 strength.",
			"code": "21102",
			"title": "Musaazi",
		})

	NRCardDefs.defcard("Muse", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Daemon",
			"subtypes": ["Daemon"],
			"text": "When you install this program, search your stack, heap, or grip for 1 non-<strong>daemon</strong> program. <em>(Shuffle your stack after searching it.)</em> If that program is a <strong>trojan</strong>, install it on a piece of ice. Otherwise, install it on this program.",
			"code": "34091",
			"title": "Muse",
		})

	NRCardDefs.defcard("Na'Not'K", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "During runs, this program gets +1 strength for each piece of ice protecting the attacked server.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +2 strength.",
			"code": "12088",
			"title": "Na'Not'K",
		})

	NRCardDefs.defcard("Nanuq", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 3,
			"memoryunits": 2,
			"factioncost": 5,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "When this program is uninstalled, remove it from the game.\nWhen an agenda is scored or stolen, remove this program from the game.\nInterface → <strong>2[Credits]:</strong> Break up to 2 subroutines.\n1[Credits]: +1 strength.",
			"code": "33088",
			"title": "Nanuq",
		})

	NRCardDefs.defcard("Nerve Agent", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Whenever you make a successful run on HQ, place 1 virus counter on this program.\nWhenever you breach HQ, choose a number less than the number of hosted virus counters. Access that many additional cards.",
			"code": "02041",
			"title": "Nerve Agent",
		})

	NRCardDefs.defcard("Net Shield", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "[interrupt] → The first time each turn you would suffer net damage, you may pay 1[Credits] to prevent 1 net damage.",
			"code": "01045",
			"title": "Net Shield",
		})

	NRCardDefs.defcard("Nfr", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Whenever this program fully breaks a piece of ice, place 1 power counter on this program.\nThis program gets +1 strength for each power counter on it.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.",
			"code": "11023",
			"title": "Nfr",
		})

	NRCardDefs.defcard("Nga", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": true,
			"text": "When you install this program, load 3 power counters onto it. When it is empty, trash it.\nThe first time each turn you make a successful run, you may remove 1 hosted power counter to sabotage 1. <em>(The Corp trashes 1 card of their choice from HQ or the top of R&D.)</em>",
			"code": "33072",
			"title": "Nga",
		})

	NRCardDefs.defcard("Ninja", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>3[Credits]:</strong> +5 strength.",
			"code": "01027",
			"title": "Ninja",
		})

	NRCardDefs.defcard("Num", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 8,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.",
			"code": "33073",
			"title": "Num",
		})

	NRCardDefs.defcard("Nyashia", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "When you install this program, place 3 power counters on it.\nWhenever you breach R&D, you may remove 1 hosted power counter to access 1 additional card.",
			"code": "21067",
			"title": "Nyashia",
		})

	NRCardDefs.defcard("Odore", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>2[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines.\nInterface → <strong>0[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine. Use this ability only if you have 3 or more installed <strong>virtual</strong> resources.\n<strong>3[Credits]:</strong> +3 strength.",
			"code": "26071",
			"title": "Odore",
		})

	NRCardDefs.defcard("Omega", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 7,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nThis program can only interface with the innermost piece of ice protecting a server.",
			"code": "04088",
			"title": "Omega",
		})

	NRCardDefs.defcard("Orca", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 10,
			"strength": 3,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "The first time each turn this program fully breaks a piece of ice, you may charge 1 of your installed cards. <em>(Add 1 power counter to a card that already has one.)</em>\nInterface → <strong>2[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "33089",
			"title": "Orca",
		})

	NRCardDefs.defcard("Origami", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Your maximum hand size is increased by 1 for each copy of Origami installed.",
			"code": "06074",
			"title": "Origami",
		})

	NRCardDefs.defcard("Overmind", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 4,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 0,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "When you install this program, place 1 power counter on it for each unused MU. <em>(Place counters after this program's MU cost applies.)</em>\nInterface → <strong>Hosted power counter:</strong> Break 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "05053",
			"title": "Overmind",
		})

	NRCardDefs.defcard("Paintbrush", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"memoryunits": 2,
			"factioncost": 4,
			"uniqueness": false,
			"text": "[Click]: Choose a rezzed piece of ice. That ice gains <strong>sentry</strong>, <strong>code gate</strong> or <strong>barrier</strong> until the end of the next run this turn.",
			"code": "04108",
			"title": "Paintbrush",
		})

	NRCardDefs.defcard("Panchatantra", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Once per turn → When you encounter a piece of ice, you may choose 1 subtype that is not <strong>barrier</strong>, <strong>code gate</strong>, or <strong>sentry</strong>. That ice gains the chosen subtype for the remainder of this run.",
			"code": "10008",
			"title": "Panchatantra",
		})

	NRCardDefs.defcard("Paperclip", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Whenever you encounter a <strong>barrier</strong>, you may install this program from your heap.\n<strong>X[Credits]:</strong> +X strength. Then, if this program can interface with the <strong>barrier</strong> you are encountering, break up to X subroutines.",
			"code": "11024",
			"title": "Paperclip",
		})

	NRCardDefs.defcard("Parasite", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus - Trojan",
			"subtypes": ["Virus", "Trojan"],
			"text": "Install only on a rezzed piece of ice.\nWhen your turn begins, place 1 virus counter on this program.\nHost ice gets -1 strength for each hosted virus counter.\nWhen the strength of host ice is 0 or less, trash it.",
			"code": "29002",
			"title": "Parasite",
		})

	NRCardDefs.defcard("Paricia", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "2[recurring-credit] <em>(When you install this card and before your turn begins, refill to 2 hosted credits.)</em>\nYou can spend hosted credits to pay trash costs of assets.",
			"code": "31034",
			"title": "Paricia",
		})

	NRCardDefs.defcard("Passport", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.\nThis program cannot interface with ice protecting a remote server.",
			"code": "05046",
			"title": "Passport",
		})

	NRCardDefs.defcard("Pawn", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"memoryunits": 0,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Caïssa - Trojan",
			"subtypes": ["Caïssa", "Trojan"],
			"text": "[Click]: Host this program on the outermost piece of ice protecting a central server.\nWhenever you make a successful run while this program is hosted on a piece of ice, host it on the next inward piece of ice. If you cannot, trash this program and install 1 other <strong>Caïssa</strong> program from your grip or heap, ignoring all costs.",
			"code": "04002",
			"title": "Pawn",
		})

	NRCardDefs.defcard("Peacock", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "20030",
			"title": "Peacock",
		})

	NRCardDefs.defcard("Pelangi", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When you install this program, place 2 virus counters on it.\nOnce per turn → <strong>Hosted virus counter:</strong> Choose an ice subtype. The ice you are encountering gains that subtype for the remainder of this encounter.",
			"code": "26025",
			"title": "Pelangi",
		})

	NRCardDefs.defcard("Penrose", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Fracter",
			"subtypes": ["Icebreaker", "Decoder", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine. Use this ability only if this program was installed this turn.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +3 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "26089",
			"title": "Penrose",
		})

	NRCardDefs.defcard("Peregrine", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 5,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → 1[Credits]: Break 1 <strong>code gate</strong> subroutine.\n<strong>3[Credits]:</strong> +3 strength.\n<strong>2[Credits]</strong>, </strong>add this program to your grip:</strong> Derez 1 <strong>code gate</strong> this program fully broke during this encounter.",
			"code": "11044",
			"title": "Peregrine",
		})

	NRCardDefs.defcard("Persephone", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"strength": 1,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nWhenever you pass a <strong>sentry</strong> after encountering it, you may trash the top card of your stack. If you do, trash 1 card from the top of R&D for each subroutine on that <strong>sentry</strong> that resolved during that encounter.",
			"code": "12042",
			"title": "Persephone",
		})

	NRCardDefs.defcard("Pheromones", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "X[recurring-credit]\nUse these credits during runs on HQ. X is the number of virus counters on Pheromones.\nWhenever you make a successful run on HQ, place 1 virus counter on Pheromones.",
			"code": "20031",
			"title": "Pheromones",
		})

	NRCardDefs.defcard("Physarum Entangler", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus - Trojan",
			"subtypes": ["Virus", "Trojan"],
			"text": "Install only on a piece of ice.\nWhenever you encounter host ice, if it is not a <strong>barrier</strong>, you may pay 1[Credits] for each subroutine it has. If you do, bypass that ice.\nWhen the Corp purges virus counters, trash this program.",
			"code": "34082",
			"title": "Physarum Entangler",
		})

	NRCardDefs.defcard("Pichação", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nWhenever you pass host ice, you may gain [Click]. If this is not the first time you gained [Click] during a run this turn, add this program to your grip.",
			"code": "34025",
			"title": "Pichação",
		})

	NRCardDefs.defcard("Pipeline", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength for the remainder of this run.",
			"code": "25055",
			"title": "Pipeline",
		})

	NRCardDefs.defcard("Plague", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "When you install Plague, choose a server.\nWhenever you make a successful run on the chosen server, you may place 2 virus counters on Plague.",
			"code": "21022",
			"title": "Plague",
		})

	NRCardDefs.defcard("Pressure Spike", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.\nThreat 4 → <strong>2[Credits]:</strong> +9 strength. Use this ability only once per run. <em>(This ability is active if any player has 4 or more agenda points.)</em>",
			"code": "34092",
			"title": "Pressure Spike",
		})

	NRCardDefs.defcard("Principia", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "This program costs 1[Credits] less to install for each other installed <strong>icebreaker</strong>. <em>(Programs trashed as part of installing this program don’t count.)</em>\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "35032",
			"title": "Principia",
		})

	NRCardDefs.defcard("Progenitor", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"memoryunits": 0,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Daemon",
			"subtypes": ["Daemon"],
			"text": "You can install <strong>virus</strong> programs onto this program. Limit 1 hosted program.\nThe memory cost of the hosted program does not count against your memory limit.\n[interrupt] → Whenever virus counters would be purged, prevent 1 virus counter on the hosted program from being removed.",
			"code": "07043",
			"title": "Progenitor",
		})

	NRCardDefs.defcard("Propeller", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "When you install this program, place 4 power counters on it.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>Hosted power counter:</strong> +2 strength.",
			"code": "33027",
			"title": "Propeller",
		})

	NRCardDefs.defcard("Puffer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "This program gets +1 strength and costs +1[Memory Unit] for each hosted power counter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +1 strength.\n<strong>[Click]:</strong> Place 1 power counter on this program or remove 1 hosted power counter.",
			"code": "21004",
			"title": "Puffer",
		})

	NRCardDefs.defcard("Read-Write Share", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Limit 4 hosted cards.\nWhen you install this program and when your turn begins, you may host 1 card from your grip facedown on this program to draw 1 card.\n[Trash]<strong>:</strong> Shuffle all hosted cards into your stack.",
			"code": "36022",
			"title": "Read-Write Share",
		})

	NRCardDefs.defcard("Reaver", {
			"type": "Program",
			"side": "Runner",
			"faction": "Apex",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"text": "The first time you trash an installed card each turn, draw 1 card.",
			"code": "11086",
			"title": "Reaver",
		})

	NRCardDefs.defcard("Refractor", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +3 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "06057",
			"title": "Refractor",
		})

	NRCardDefs.defcard("Revolver", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Weapon",
			"subtypes": ["Icebreaker", "Killer", "Weapon"],
			"text": "When you install this program, place 6 power counters on it.\nInterface → [Trash] or <strong>hosted power counter:</strong> Break 1 <strong>sentry</strong> subroutine.\n<strong>2[Credits]:</strong> +3 strength.",
			"code": "33018",
			"title": "Revolver",
		})

	NRCardDefs.defcard("Rezeki", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"text": "When your turn begins, gain 1[Credits].",
			"code": "26026",
			"title": "Rezeki",
		})

	NRCardDefs.defcard("Rising Tide", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "This program gets +1 strength for each <strong>fracter</strong> in your heap.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "35009",
			"title": "Rising Tide",
		})

	NRCardDefs.defcard("RNG Key", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 0,
			"uniqueness": true,
			"text": "The first time you make a successful run on HQ or R&D each turn, you may name a number. If you do, reveal the next card that you access this run. If it has a rez cost, play cost, or advancement requirement equal to the named number, either gain 3[Credits] or draw 2 cards.",
			"code": "21029",
			"title": "RNG Key",
		})

	NRCardDefs.defcard("Rook", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Caïssa - Trojan",
			"subtypes": ["Caïssa", "Trojan"],
			"text": "While this program is hosted on ice, the rez cost of each piece of ice protecting this server is increased by 2.\n[Click]: Host this program on a piece of ice that is not hosting a <strong>Caïssa</strong> program.\nIf this program is hosted on ice, its [Click] ability can only be used to host it on ice protecting the same server or in the same position as its current host ice. <em>(Count positions from the innermost ice.)</em>",
			"code": "04003",
			"title": "Rook",
		})

	NRCardDefs.defcard("Saci", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nWhenever host ice is rezzed or derezzed, gain 3[Credits].",
			"code": "34017",
			"title": "Saci",
		})

	NRCardDefs.defcard("Sadyojata", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Icebreaker - AI - Deva",
			"subtypes": ["Icebreaker", "AI", "Deva"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice with 3 or more subtypes.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>2[Credits]:</strong> Swap this program with a <strong>deva</strong> program from your grip.",
			"code": "10044",
			"title": "Sadyojata",
		})

	NRCardDefs.defcard("Sage", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 0,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Fracter",
			"subtypes": ["Icebreaker", "Decoder", "Fracter"],
			"text": "This program gets +1 strength for each unused MU.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>code gate</strong> or 1 <strong>barrier</strong> subroutine.",
			"code": "06117",
			"title": "Sage",
		})

	NRCardDefs.defcard("Sahasrara", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "2[recurring-credit]\nUse these credits to install programs (you cannot use Sahasrara to install a program that trashes Sahasrara).",
			"code": "03047",
			"title": "Sahasrara",
		})

	NRCardDefs.defcard("Saker", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.\n<strong>2[Credits]</strong>, <strong>add this program to your grip:</strong> Derez 1 <strong>barrier</strong> this program fully broke during this encounter.",
			"code": "11064",
			"title": "Saker",
		})

	NRCardDefs.defcard("Sang Kancil", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>3[Credits]:</strong> +2 strength. If a <strong>run</strong> event is active, this ability costs 2[Credits] less to use.",
			"code": "35020",
			"title": "Sang Kancil",
		})

	NRCardDefs.defcard("Savant", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 1,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Decoder",
			"subtypes": ["Icebreaker", "Killer", "Decoder"],
			"text": "This program gets +1 strength for each unused MU.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> or 2 <strong>code gate</strong> subroutines.",
			"code": "13018",
			"title": "Savant",
		})

	NRCardDefs.defcard("Savoir-faire", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "You cannot use Savoir-faire more than once each turn.\n2[Credits]: Install a program from your grip, paying the install cost.",
			"code": "04105",
			"title": "Savoir-faire",
		})

	NRCardDefs.defcard("Scheherazade", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 0,
			"memoryunits": 0,
			"factioncost": 1,
			"uniqueness": true,
			"keywords": "Daemon",
			"subtypes": ["Daemon"],
			"text": "Scheherazade can host any number of programs.\nWhenever you install a program on Scheherazade, gain 1[Credits].",
			"code": "04022",
			"title": "Scheherazade",
		})

	NRCardDefs.defcard("Self-modifying Code", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "<strong>2[Credits]</strong>, <strong>[Trash]:</strong> Search your stack for 1 program. Install it. <em>(Shuffle your stack after searching it.)</em>",
			"code": "26090",
			"title": "Self-modifying Code",
		})

	NRCardDefs.defcard("Sharpshooter", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker",
			"subtypes": ["Icebreaker"],
			"text": "Interface → <strong>[Trash]:</strong> Break any number of <strong>destroyer</strong> subroutines.\n<strong>1[Credits]:</strong> +2 strength.",
			"code": "04067",
			"title": "Sharpshooter",
		})

	NRCardDefs.defcard("Shibboleth", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Threat 4 → This program gets −2 strength. <em>(This ability is active if any player has 4 or more agenda points.)</em>\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "34018",
			"title": "Shibboleth",
		})

	NRCardDefs.defcard("Shiv", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer - Cloud",
			"subtypes": ["Icebreaker", "Killer", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nThis program gets +1 strength for each installed <strong>icebreaker</strong>.\nInterface → <strong>[Trash]:</strong> Break up to 3 <strong>sentry</strong> subroutines.",
			"code": "08066",
			"title": "Shiv",
		})

	NRCardDefs.defcard("Sipa", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "The first time each turn you pass the outermost piece of ice protecting a server after fully breaking it, you may swap it with another installed piece of ice.",
			"code": "36023",
			"title": "Sipa",
		})

	NRCardDefs.defcard("Slap Vandal", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"strength": 6,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - AI - Trojan",
			"subtypes": ["Icebreaker", "AI", "Trojan"],
			"text": "Install only on a piece of ice.\nInterface → <strong>1[Credits]:</strong> Break 1 subroutine on host ice. Use this ability only once per encounter.",
			"code": "34026",
			"title": "Slap Vandal",
		})

	NRCardDefs.defcard("Sneakdoor Beta", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 4,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "[Click]<strong>:</strong> Run Archives. If that run would be declared successful, change the attacked server to HQ for the remainder of that run.",
			"code": "31023",
			"title": "Sneakdoor Beta",
		})

	NRCardDefs.defcard("Sneakdoor Prime A", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 6,
			"memoryunits": 2,
			"factioncost": 0,
			"uniqueness": false,
			"text": "[Click],[Click]: Make a run on a remote server. If successful, instead treat it as a successful run on a central server.",
			"code": "14026",
			"title": "Sneakdoor Prime A",
		})

	NRCardDefs.defcard("Sneakdoor Prime B", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 6,
			"memoryunits": 2,
			"factioncost": 0,
			"uniqueness": false,
			"text": "[Click],[Click]: Make a run on a central server. If successful, instead treat it as a successful run on a remote server.",
			"code": "14027",
			"title": "Sneakdoor Prime B",
		})

	NRCardDefs.defcard("Snitch", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"text": "Once per run, you may expose an unrezzed piece of ice when you approach it. You may then jack out.",
			"code": "02045",
			"title": "Snitch",
		})

	NRCardDefs.defcard("Snowball", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 4,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.\nWhenever you use this program to break a subroutine, this program gets +1 strength for the remainder of this run.",
			"code": "02027",
			"title": "Snowball",
		})

	NRCardDefs.defcard("Spike", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter - Cloud",
			"subtypes": ["Icebreaker", "Fracter", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nThis program gets +1 strength for each installed <strong>icebreaker</strong>.\nInterface → <strong>[Trash]:</strong> Break up to 3 <strong>barrier</strong> subroutines.",
			"code": "08004",
			"title": "Spike",
		})

	NRCardDefs.defcard("Stargate", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 4,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Once per turn → [Click]<strong>:</strong> Run R&D. If successful, instead of breaching R&D, reveal the top 3 cards of R&D. Trash 1 of the revealed cards.",
			"code": "26004",
			"title": "Stargate",
		})

	NRCardDefs.defcard("Stowaway", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Trojan",
			"subtypes": ["Trojan"],
			"text": "Install only on a piece of ice.\nWhenever you make a successful run on this server, gain 2[Credits].",
			"code": "36024",
			"title": "Stowaway",
		})

	NRCardDefs.defcard("Study Guide", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "This program gets +1 strength for each hosted power counter.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>2[Credits]:</strong> Place 1 power counter on this program.",
			"code": "08028",
			"title": "Study Guide",
		})

	NRCardDefs.defcard("Sūnya", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Whenever this program fully breaks a piece of ice, place 1 power counter on this program.\nThis program gets +1 strength for each power counter on it.\nInterface → <strong>2[Credits]:</strong> Break 1 <strong>sentry</strong> subroutine.",
			"code": "11102",
			"title": "Sūnya",
		})

	NRCardDefs.defcard("Surfer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "2[Credits]: Swap a piece of <strong>barrier</strong> ice currently being encountered with a piece of ice directly before or after it. The run continues from this new position. You are still encountering that ice.",
			"code": "08102",
			"title": "Surfer",
		})

	NRCardDefs.defcard("Surveillance Network Key", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Whenever the Corp spends [Click] to draw 1 or more cards (including through a card ability), reveal the first card drawn.",
			"code": "14018",
			"title": "Surveillance Network Key",
		})

	NRCardDefs.defcard("Surveillance Network Key 2", {
			"type": "Program",
			"side": "Runner",
			"faction": "Neutral",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 0,
			"uniqueness": false,
			"text": "Whenever the Corp spends [Click] to draw 1 or more cards (including through a card ability), reveal the first card drawn.\n2[Credits]: For the remainder of this run, access 1 additional card whenever you access cards from HQ or R&D. Use this ability only once per turn.",
			"code": "14019",
			"title": "Surveillance Network Key 2",
		})

	NRCardDefs.defcard("Switchblade", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Killer",
			"subtypes": ["Icebreaker", "Killer"],
			"text": "Interface → <strong>1[Credits]:</strong> Break any number of <strong>sentry</strong> subroutines. Spend credits only from <strong>stealth</strong> cards to use this ability.\n<strong>1[Credits]:</strong> +7 strength. Spend credits only from <strong>stealth</strong> cards to use this ability.",
			"code": "06077",
			"title": "Switchblade",
		})

	NRCardDefs.defcard("Takobi", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": true,
			"text": "Whenever you fully break a piece of ice, you may place 1 power counter on this program.\n<strong>2 hosted power counters:</strong> Choose 1 installed non-<strong>AI</strong> <strong>icebreaker</strong>. That <strong>icebreaker</strong> gets +3 strength for the remainder of the current encounter.",
			"code": "21026",
			"title": "Takobi",
		})

	NRCardDefs.defcard("Tapwrm", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Virus",
			"subtypes": ["Virus"],
			"text": "Install only if you made a successful run on a central server this turn.\nWhen your turn begins, gain 1[Credits] for every 5[Credits] in the Corp's credit pool.\nTrash Tapwrm if the Corp purges virus counters.",
			"code": "11104",
			"title": "Tapwrm",
		})

	NRCardDefs.defcard("Torch", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 9,
			"strength": 4,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "04047",
			"title": "Torch",
		})

	NRCardDefs.defcard("Tracker", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 0,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"text": "When your turn begins, you may choose a server.\n<strong>[Click]</strong>, <strong>2[Credits]:</strong> Run the chosen server. The first time a subroutine would resolve during that run, prevent it from resolving.",
			"code": "11105",
			"title": "Tracker",
		})

	NRCardDefs.defcard("Tranquilizer", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus - Trojan",
			"subtypes": ["Virus", "Trojan"],
			"text": "Install only on a piece of ice. <em>(If the host ice is uninstalled, this program is trashed.)</em>\nWhen you install this program and when your turn begins, place 1 virus counter on this program. Then, if there are 3 or more hosted virus counters, derez host ice.",
			"code": "30017",
			"title": "Tranquilizer",
		})

	NRCardDefs.defcard("Tremolo", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 3,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>3[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines. This ability costs 1[Credits] less to use for each installed piece of <strong>cybernetic</strong> hardware.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "33080",
			"title": "Tremolo",
		})

	NRCardDefs.defcard("Trope", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "When your turn begins, place 1 power counter on Trope.\n[Click], <strong>remove Trope from the game:</strong> Shuffle 1 card from your heap into your stack for each power counter on Trope.",
			"code": "08081",
			"title": "Trope",
		})

	NRCardDefs.defcard("Trypano", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Virus - Trojan",
			"subtypes": ["Virus", "Trojan"],
			"text": "Install only on a piece of ice.\nWhen your turn begins, you may place 1 virus counter on this program.\nWhen there are 5 or more hosted virus counters, trash host ice.",
			"code": "21082",
			"title": "Trypano",
		})

	NRCardDefs.defcard("Tunnel Vision", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 2,
			"strength": 2,
			"memoryunits": 2,
			"factioncost": 3,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "When your turn begins, identify your mark. <em>(If you donʼt have a mark, a random central server becomes your mark for this turn.)</em>\nInterface → <strong>2[Credits]:</strong> Break up to 2 subroutines on a piece of ice protecting your mark.\n<strong>2[Credits]:</strong> +2 strength.",
			"code": "33081",
			"title": "Tunnel Vision",
		})

	NRCardDefs.defcard("Tycoon", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter",
			"subtypes": ["Icebreaker", "Fracter"],
			"text": "Interface → <strong>1[Credits]:</strong> Break up to 2 <strong>barrier</strong> subroutines.\n<strong>2[Credits]:</strong> +3 strength.\nWhenever an encounter ends, if you used this program to break a subroutine during that encounter, the Corp gains 2[Credits].",
			"code": "22012",
			"title": "Tycoon",
		})

	NRCardDefs.defcard("Umbrella", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 5,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Weapon",
			"subtypes": ["Icebreaker", "Decoder", "Weapon"],
			"text": "This program can only interface with ice hosting a <strong>trojan</strong> program.\nInterface → <strong>2[Credits]:</strong> Break up to 3 <strong>code gate</strong> subroutines. If at least 1 subroutine was broken this way, each player may draw 1 card.",
			"code": "34027",
			"title": "Umbrella",
		})

	NRCardDefs.defcard("Unity", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 3,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +X strength. X is equal to the number of installed <strong>icebreakers</strong> <em>(including this one)</em>.",
			"code": "30026",
			"title": "Unity",
		})

	NRCardDefs.defcard("Upya", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 0,
			"memoryunits": 1,
			"factioncost": 3,
			"uniqueness": false,
			"text": "Whenever you make a successful run on R&D, you may place 1 power counter on this program.\nOnce per turn → [Click], <strong>3 hosted power counters:</strong> Gain [Click][Click].",
			"code": "21007",
			"title": "Upya",
		})

	NRCardDefs.defcard("Utae", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 2,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>X[Credits]:</strong> Break X <strong>code gate</strong> subroutines. Use this ability only once per run.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine. Use this ability only if you have 3 or more installed <strong>virtual</strong> resources.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "26005",
			"title": "Utae",
		})

	NRCardDefs.defcard("Vamadeva", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 6,
			"strength": 2,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": true,
			"keywords": "Icebreaker - AI - Deva",
			"subtypes": ["Icebreaker", "AI", "Deva"],
			"text": "Interface → <strong>1[Credits]:</strong> Break 1 subroutine on a piece of ice with exactly 1 subroutine.\n<strong>1[Credits]:</strong> +1 strength.\n<strong>2[Credits]:</strong> Swap this program with a <strong>deva</strong> program from your grip.",
			"code": "10061",
			"title": "Vamadeva",
		})

	NRCardDefs.defcard("Wari", {
			"type": "Program",
			"side": "Runner",
			"faction": "Criminal",
			"cost": 1,
			"memoryunits": 1,
			"factioncost": 4,
			"uniqueness": true,
			"text": "The first time you make a successful run on HQ each turn, you may trash Wari to name <strong>sentry</strong>, <strong>code gate</strong> or <strong>barrier</strong>. Expose a piece of ice, then add it to HQ if it has the named subtype.",
			"code": "21024",
			"title": "Wari",
		})

	NRCardDefs.defcard("World Tree", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 6,
			"memoryunits": 2,
			"factioncost": 4,
			"uniqueness": false,
			"keywords": "Deep Net",
			"subtypes": ["Deep Net"],
			"text": "The first time each turn you make a successful run, you may trash 1 of your other installed cards to search your stack for 1 card of the same type. <em>(Shuffle your stack after searching it.)</em> Install the card you found, paying 3[Credits] less.",
			"code": "33091",
			"title": "World Tree",
		})

	NRCardDefs.defcard("Wyrm", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - AI",
			"subtypes": ["Icebreaker", "AI"],
			"text": "Interface → <strong>3[Credits]:</strong> Break 1 subroutine on a piece of ice with 0 or less strength.\nInterface → <strong>1[Credits]:</strong> The ice you are encountering gets -1 strength for the remainder of this encounter.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "01013",
			"title": "Wyrm",
		})

	NRCardDefs.defcard("Yog.0", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 5,
			"strength": 3,
			"memoryunits": 1,
			"factioncost": 1,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder",
			"subtypes": ["Icebreaker", "Decoder"],
			"text": "Interface → <strong>0[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.",
			"code": "01014",
			"title": "Yog.0",
		})

	NRCardDefs.defcard("Yusuf", {
			"type": "Program",
			"side": "Runner",
			"faction": "Anarch",
			"cost": 1,
			"strength": 3,
			"memoryunits": 2,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Fracter - Virus",
			"subtypes": ["Icebreaker", "Fracter", "Virus"],
			"text": "Whenever you make a successful run, you may place 1 virus counter on this program.\nInterface → <strong>Any virus counter:</strong> Break 1 <strong>barrier</strong> subroutine.\n<strong>Any virus counter:</strong> +1 strength.",
			"code": "21002",
			"title": "Yusuf",
		})

	NRCardDefs.defcard("ZU.13 Key Master", {
			"type": "Program",
			"side": "Runner",
			"faction": "Shaper",
			"cost": 1,
			"strength": 1,
			"memoryunits": 1,
			"factioncost": 2,
			"uniqueness": false,
			"keywords": "Icebreaker - Decoder - Cloud",
			"subtypes": ["Icebreaker", "Decoder", "Cloud"],
			"text": "If you have at least 2[link], the memory cost of this program is 0[Memory Unit], even if it is not installed.\nInterface → <strong>1[Credits]:</strong> Break 1 <strong>code gate</strong> subroutine.\n<strong>1[Credits]:</strong> +1 strength.",
			"code": "02007",
			"title": "ZU.13 Key Master",
		})
