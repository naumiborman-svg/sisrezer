#!/usr/bin/env node
"use strict";

const fs = require("fs");
const http = require("http");
const path = require("path");
const { JSDOM, VirtualConsole } = require("jsdom");
const gauntletHub = require("./gauntlet-hub");

const ENGINE = path.resolve(__dirname, "../chiriboga-engine");
const PORT = Number(process.env.CHIRIBOGA_PORT || 1043);

const STARTER_RUNNER =
  "N4IglgJgpgdgLmOBPEAuAzABkwdgGwA0IAxgIYBOEAzmgNpbaEOZPYCMATAQ59++n0xsALILYBWMZJ4AOQR0zzFDDm3lqVrTBy0cc8-SrlH5x7BwCc8qwyyC7t5dnRdbr5wNufnwgLoBfIA";
const STARTER_CORP =
  "N4IglgJgpgdgLmOBPEAuAzABkwdhwGhAGMBDAJwgGc0BtLTdA+x-ZgTle3Q-oBZNOmfoN4AmEQFZJIgGyyRTbL0WYZvQWo0qZ27T2wz9uAfRwnsOAIyCrN8afsXHudDden1Hm1NM+LEgF0AXyA";

const CORE_SCRIPTS = [
  "jquery/jquery-3.2.1.min.js",
  "deck/lz-string.min.js",
  "deck/seedrandom.min.js",
  "config.js",
  "init.js",
  "phase.js",
  "command.js",
  "checks.js",
  "mechanics.js",
  "utility.js",
];

const ENGINE_ONLY_SETS = ["gauntlet", "tutorial"];
const AFTER_SETS = ["decks.js", "runcalculator.js", "ai_corp.js", "ai_runner.js"];

const games = new Map();
const campaigns = new Map();
let catalogCache = null;

function setFiles() {
  const names = [];
  const dir = path.join(ENGINE, "sets");
  for (const name of fs.readdirSync(dir).sort()) {
    if (!name.endsWith(".js")) continue;
    if (name === "cheat.js") continue;
    names.push(name.replace(/\.js$/, ""));
  }
  return names;
}

function preconFiles() {
  const dir = path.join(ENGINE, "precons");
  return fs
    .readdirSync(dir)
    .filter((n) => n.endsWith(".js"))
    .sort()
    .map((n) => path.join("precons", n));
}

function evalFile(window, rel) {
  const full = path.join(ENGINE, rel);
  if (!fs.existsSync(full)) throw new Error("missing " + rel);
  let extra = "";
  if (rel === "ai_corp.js") extra = "\nwindow.CorpAI = CorpAI;";
  if (rel === "ai_runner.js") extra = "\nwindow.RunnerAI = RunnerAI;";
  window.eval(fs.readFileSync(full, "utf8") + extra + "\n//# sourceURL=" + rel);
}

function evalBridgeFile(window, name) {
  const full = path.join(__dirname, name);
  window.eval(fs.readFileSync(full, "utf8") + "\n//# sourceURL=" + name);
}

function dummySprite() {
  return {
    x: 0,
    y: 0,
    addChild() {},
    removeChild() {},
    visible: true,
    scale: { x: 1, y: 1 },
    anchor: { set() {} },
    texture: {},
  };
}

function makeCardRenderer() {
  const CreateCard = function (card) {
    return {
      card,
      sprite: dummySprite(),
      glowSprite: dummySprite(),
      destinationPosition: { x: 0, y: 0 },
      faceUp: !!card.faceUp,
      Destroy() {},
      Extents() {
        return { l: 0, r: 0, t: 0, b: 0 };
      },
      ToggleZoom() {},
      UpdateGlow() {},
      SetRotation() {},
    };
  };
  class Renderer {
    constructor() {
      this.tutorialText = { text: "", x: 0, y: 0, rotation: 0 };
      this.archivesIndicator = dummySprite();
      this.newRemoteIndicator = dummySprite();
      this.serverSelector = dummySprite();
      this.serverText = { x: 0, y: 0, rotation: 0, text: "" };
      this.app = {
        view: { nodeName: "CANVAS", style: {} },
        renderer: { plugins: { sprite: { sprites: [] } }, resize() {} },
        stage: { addChild() {}, removeChild() {}, pivot: { x: 0, y: 0 }, x: 0, y: 0 },
        ticker: { add() {} },
      };
    }
    LoadTexture() {
      return {};
    }
    CreateCard(card) {
      return CreateCard(card);
    }
    CreateCounter() {
      return {
        sprite: dummySprite(),
        richText: { text: "" },
        SetPosition() {},
        SetValue() {},
      };
    }
    UpdateGlow() {}
    UpdateCounters() {}
    HideParticleContainers() {}
    ShowParticleContainers() {}
    MousePosition() {
      return { x: 0, y: 0 };
    }
    ChangeSide() {}
    RenderSubroutineChoices() {}
    Render() {}
    Particle() {}
  }
  return { Renderer, CreateCard, Cascade: class {} };
}

function injectStubs(window) {
  window.accessibilityMode = "text";
  window.versionReference = "godot_bridge";
  window.cardSet = window.cardSet || [];
  window.setIdentifiers = window.setIdentifiers || [];
  window.gtag = function () {};
  window.CardRenderer = makeCardRenderer();
  window.ResizeCardRenderer = function () {};
  window.Resize = function () {};
  window.tryShowHostileTakeover = function (cb) {
    if (typeof cb === "function") cb();
  };
  window.UpdateCounters = function () {};
  window.Render = function () {};
  window.cardRenderer = {
    tutorialText: { text: "" },
    RenderCards: function () {},
    RenderField: function () {},
    Render: function () {},
    UpdateGlow: function () {},
    UpdateCounters: function () {},
  };
  window.preconDecks = [];
  window.registerPrecon = function (deck) {
    window.preconDecks.push(deck);
  };
}

function loadEngineScripts(window, withPrecons) {
  for (const rel of CORE_SCRIPTS) evalFile(window, rel);
  const registry = window.setRegistry && window.setRegistry.availableSets;
  const sets = registry ? Object.keys(registry).map((k) => registry[k].file) : setFiles();
  const unique = [...new Set([...sets, ...ENGINE_ONLY_SETS])];
  for (const name of unique) evalFile(window, path.join("sets", name + ".js"));
  for (const rel of AFTER_SETS) evalFile(window, rel);
  if (withPrecons) {
    for (const rel of preconFiles()) evalFile(window, rel);
  }
}

function makeDom(query) {
  const html = `<!DOCTYPE html><html><body>
    <div id="contentcontainer"><div id="output"></div></div>
    <div id="footer"></div><div id="menu"></div><div id="loading"></div>
    <div id="thinking"></div><div id="header"></div><div id="history"></div>
    <select id="rewind-select"></select>
    <button id="editdeck"></button><button id="randomdeck"></button>
    <button id="menubutton"></button><button id="exittomenu"></button>
    <input id="card-search"><p id="search-result"></p>
    <form id="cmdform"><input type="text"><input type="submit"></form>
    <input id="narration" type="checkbox">
    <canvas></canvas>
    <div class="netrunner-bg-watermark"></div>
    <div id="modal"><div id="modalcontent"></div></div>
    <div id="hostile-takeover-modal"><div id="hostile-takeover-perks"></div></div>
    <label><input id="debugmenu-toggle" type="checkbox"></label>
  </body></html>`;
  const virtualConsole = new VirtualConsole();
  virtualConsole.sendTo(console, { omitJSDOMErrors: true });
  return new JSDOM(html, {
    url: "http://127.0.0.1:" + PORT + "/engine.php?" + (query || ""),
    runScripts: "outside-only",
    pretendToBeVisual: true,
    virtualConsole,
  });
}

function cardSide(window, id) {
  const card = window.cardSet[Number(id)];
  if (!card) return "";
  if (card.player === window.runner) return "runner";
  if (card.player === window.corp) return "corp";
  return "";
}

function preconToLz(window, precon) {
  const json = {
    identity: parseInt(precon.identity, 10),
    cards: [],
    name: precon.name,
  };
  if (precon.notes) json.notes = precon.notes;
  if (precon.URL) json.url = precon.URL;
  for (const [id, count] of Object.entries(precon.cards || {})) {
    for (let i = 0; i < Number(count); i++) json.cards.push(parseInt(id, 10));
  }
  return window.LZString.compressToEncodedURIComponent(JSON.stringify(json));
}

function summarizePrecon(window, precon) {
  const id = Number(precon.identity);
  const card = window.cardSet[id] || {};
  let count = 0;
  for (const n of Object.values(precon.cards || {})) count += Number(n) || 0;
  return {
    name: precon.name,
    identity: id,
    identity_title: card.title || "",
    faction: card.faction || "",
    side: cardSide(window, id),
    deck_set: precon.deck_set || "",
    notes: precon.notes || "",
    url: precon.URL || "",
    card_count: count,
    image: card.imageFile || "",
    useForQuickGame: !!precon.useForQuickGame,
    useForGauntlet: !!precon.useForGauntlet,
    useForCustomGame: precon.useForCustomGame !== false,
    useAsCustomDefault: !!precon.useAsCustomDefault,
  };
}

function buildCatalog() {
  const dom = makeDom("catalog=1");
  const { window } = dom;
  injectStubs(window);
  loadEngineScripts(window, true);
  const precons = window.preconDecks.map((p) => summarizePrecon(window, p));
  const sets = [];
  if (window.setRegistry && window.setRegistry.availableSets) {
    for (const [key, info] of Object.entries(window.setRegistry.availableSets)) {
      sets.push({
        key,
        file: info.file,
        code: info.code,
        name: info.name,
        hidden: !!info.hidden,
        untested: !!info.untested,
      });
    }
  }
  catalogCache = {
    ok: true,
    engine: "chiriboga",
    version: "0.6.13-BETA",
    source: "https://chiriboga.cronbach.com",
    sets,
    precons,
    tutorials: [
      { mentor: 0, label: "CLICKS & RUNS" },
      { mentor: 1, label: "CREDITS & CARD TYPES" },
      { mentor: 2, label: "ICE & ICEBREAKERS" },
      { mentor: 3, label: "ASSETS & TRASH COSTS" },
      { mentor: 4, label: "ADVANCING & SCORING" },
      { mentor: 5, label: "UPGRADES & ROOT" },
      { mentor: 6, label: "VS CORP STARTER DECK" },
      { mentor: 7, label: "VS RUNNER STARTER DECK" },
    ],
    achievements: [
      { id: "getHighScore", name: "High Scorer", description: "Record a High Score." },
      { id: "beat4gauntlet", name: "Complete a short Gauntlet", description: "Survive a Gauntlet of 4 opponents." },
      { id: "beat8gauntlet", name: "Complete a regular Gauntlet", description: "Survive a Gauntlet of 8 opponents." },
      { id: "beat12gauntlet", name: "Complete a long Gauntlet", description: "Survive a Gauntlet of 12 opponents." },
    ],
    gauntlet: {
      startingCredits: (window.gauntletConfig && window.gauntletConfig.startingCredits) || 30,
      length: (window.gauntletConfig && window.gauntletConfig.gauntletLength) || 8,
      shop: (window.gauntletConfig && window.gauntletConfig.shop) || {},
      packs: ((window.gauntletConfig && window.gauntletConfig.cardPacks) || []).map((p) => ({
        name: p.name,
        cost: p.cost,
        cardQuantity: p.cardQuantity,
      })),
    },
    _window: window,
  };
  return catalogCache;
}

function catalog() {
  if (!catalogCache) buildCatalog();
  const { _window, ...pub } = catalogCache;
  return pub;
}

function catalogWindow() {
  if (!catalogCache) buildCatalog();
  return catalogCache._window;
}

function findPrecon(name) {
  const w = catalogWindow();
  return w.preconDecks.find((p) => p.name === name) || null;
}

function pickRandom(list) {
  return list[Math.floor(Math.random() * list.length)];
}

function randomQuickPair(preferSide) {
  const w = catalogWindow();
  const runners = w.preconDecks.filter((p) => p.useForQuickGame && cardSide(w, p.identity) === "runner");
  const corps = w.preconDecks.filter((p) => p.useForQuickGame && cardSide(w, p.identity) === "corp");
  const runner = pickRandom(runners.length ? runners : w.preconDecks.filter((p) => cardSide(w, p.identity) === "runner"));
  const corp = pickRandom(corps.length ? corps : w.preconDecks.filter((p) => cardSide(w, p.identity) === "corp"));
  let playerIsRunner = preferSide ? preferSide === "runner" : Math.random() < 0.5;
  if (!preferSide && Math.random() < 0.5) playerIsRunner = !playerIsRunner;
  return {
    player: playerIsRunner ? runner : corp,
    ai: playerIsRunner ? corp : runner,
    side: playerIsRunner ? "runner" : "corp",
  };
}

function gauntletOpponents(length) {
  const w = catalogWindow();
  const corps = w.preconDecks.filter((p) => p.useForGauntlet && cardSide(w, p.identity) === "corp");
  const byFaction = {};
  for (const p of corps) {
    const faction = (w.cardSet[Number(p.identity)] || {}).faction || "Other";
    (byFaction[faction] || (byFaction[faction] = [])).push(p);
  }
  const factions = ["Jinteki", "Haas-Bioroid", "NBN", "Weyland Consortium"];
  const out = [];
  let guard = 0;
  while (out.length < length && guard < 64) {
    const faction = factions[out.length % factions.length];
    const pool = byFaction[faction] && byFaction[faction].length ? byFaction[faction] : corps;
    if (!pool || !pool.length) break;
    out.push(pickRandom(pool));
    guard++;
  }
  return out;
}

function queryFromBody(body) {
  const params = new URLSearchParams();
  const w = catalogWindow();
  const mode = body.mode || "quick";
  const requestedSide = body.side === "corp" ? "corp" : "runner";
  if (body.ap) params.set("ap", String(body.ap));

  if (mode === "tutorial") {
    const mentor = Number(body.mentor ?? 0);
    const tutorials = [
      { side: "r", mentor: 0 },
      { side: "r", mentor: 1 },
      { side: "r", mentor: 2 },
      { side: "r", mentor: 3 },
      { side: "r", mentor: 4 },
      { side: "c", mentor: 5 },
    ];
    if (mentor === 6) {
      params.set("ap", "6");
      params.set("p", "r");
      params.set("r", STARTER_RUNNER);
      params.set("c", STARTER_CORP);
      params.set("t", "1");
    } else if (mentor === 7) {
      params.set("ap", "6");
      params.set("p", "c");
      params.set("c", STARTER_CORP);
      params.set("r", STARTER_RUNNER);
      params.set("t", "1");
    } else {
      const t = tutorials[mentor] || tutorials[0];
      params.set("p", t.side);
      params.set("mentor", String(t.mentor));
      params.set("t", "1");
    }
    return { query: params.toString(), meta: { mode, mentor } };
  }

  if (mode === "starter") {
    params.set("ap", String(body.ap || 6));
    params.set("p", requestedSide === "corp" ? "c" : "r");
    params.set("r", STARTER_RUNNER);
    params.set("c", STARTER_CORP);
    params.set("t", "1");
    return { query: params.toString(), meta: { mode, side: requestedSide } };
  }

  let player = null;
  let ai = null;
  let side = requestedSide;
  if (body.player_deck) player = findPrecon(body.player_deck);
  if (body.ai_deck) ai = findPrecon(body.ai_deck);
  if (mode === "quick" && (!player || !ai)) {
    const pair = randomQuickPair(body.side);
    player = player || pair.player;
    ai = ai || pair.ai;
    side = pair.side;
  }
  if (mode === "custom") {
    if (!player) player = findPrecon("Gateway Runner") || findPrecon("My First Runner");
    if (!ai) ai = findPrecon("Gateway Corp") || findPrecon("My First Corp");
    if (player) side = cardSide(w, player.identity) || side;
  }
  if (mode === "watch") {
    params.set("faceoff", "1");
    if (!player || !ai) {
      const pair = randomQuickPair();
      player = pair.player;
      ai = pair.ai;
    }
    side = requestedSide;
  }
  if (mode === "gauntlet") {
    if (body.campaign_id) {
      const campaign = campaigns.get(body.campaign_id);
      if (!campaign) return { query: "", meta: { mode, error: "unknown campaign" } };
      const fight = gauntletHub.fightPayload(w, campaign, Number(body.opponent_index || 0));
      if (!fight.ok) return { query: "", meta: { mode, error: fight.error } };
      params.set("p", "r");
      params.set("r", fight.r);
      params.set("c", fight.c);
      params.set("g", fight.g);
      return {
        query: params.toString(),
        meta: {
          mode,
          side: "runner",
          campaign_id: body.campaign_id,
          opponent_index: Number(body.opponent_index || 0),
          gauntlet: {
            length: campaign.length,
            defeated: campaign.defeated,
            opponents: campaign.opponents.map((o) => ({ name: o.gauntletCorpName || o.name })),
            hub: true,
          },
        },
      };
    }
    const length = Number(body.gauntlet_length || body.length || 4);
    const opponents = gauntletOpponents(length);
    player = findPrecon("Gateway Runner") || findPrecon("My First Runner");
    ai = opponents[0] || findPrecon("Gateway Corp");
    side = "runner";
    const meta = {
      mode,
      side,
      gauntlet: {
        length,
        defeated: 0,
        opponents: opponents.map((p) => ({ name: p.name, lz: preconToLz(w, p) })),
        runner_lz: player ? preconToLz(w, player) : STARTER_RUNNER,
      },
    };
    params.set("p", "r");
    params.set("r", meta.gauntlet.runner_lz);
    params.set("c", meta.gauntlet.opponents[0] ? meta.gauntlet.opponents[0].lz : STARTER_CORP);
    return { query: params.toString(), meta };
  }

  const rDeck = body.r || (side === "runner" ? (player ? preconToLz(w, player) : "") : ai ? preconToLz(w, ai) : "");
  const cDeck = body.c || (side === "corp" ? (player ? preconToLz(w, player) : "") : ai ? preconToLz(w, ai) : "");
  params.set("p", side === "corp" ? "c" : "r");
  if (rDeck) params.set("r", rDeck);
  if (cDeck) params.set("c", cDeck);
  if (mode === "watch") params.set("faceoff", "1");
  return {
    query: params.toString(),
    meta: {
      mode,
      side,
      player_deck: player ? player.name : "",
      ai_deck: ai ? ai.name : "",
    },
  };
}

function createSession(query) {
  const dom = makeDom(query);
  const { window } = dom;
  injectStubs(window);
  loadEngineScripts(window, false);
  window.godotLog = [];
  const origLog = window.Log;
  window.Log = function (src) {
    try {
      window.godotLog.push(String(src));
    } catch (e) {}
    try {
      return origLog.apply(this, arguments);
    } catch (e) {
      console.log(src);
    }
  };
  evalBridgeFile(window, "gauntlet-perks.js");
  window.Init();
  return { window, created: Date.now() };
}

function slimCard(card) {
  if (!card) return null;
  return {
    setNumber: card.setNumber,
    title: card.title,
    type: card.cardType,
    rez: !!card.rezzed,
    faceUp: !!card.faceUp,
    cost: card.playCost ?? card.installCost ?? card.rezCost ?? null,
    strength: card.strength,
    advancement: card.advancement || 0,
    agenda_points: card.agendaPoints,
    trash: card.trashCost,
    subtypes: card.subTypes || [],
    image: card.imageFile || "",
  };
}

function slimServer(server) {
  if (!server) return { ice: [], content: [] };
  return {
    name: server.serverName || "",
    ice: (server.ice || []).map(slimCard),
    content: (server.root || []).map(slimCard),
  };
}

function playerView(window, who) {
  const p = who === "corp" ? window.corp : window.runner;
  if (!p) return {};
  const view = {
    identity: slimCard(p.identityCard),
    credits: p.creditPool || 0,
    clicks: p.clickTracker || 0,
    agenda_points: window.AgendaPoints
      ? window.AgendaPoints(p)
      : (p.scoreArea || []).reduce((n, c) => n + (c.agendaPoints || 0), 0),
    scored: (p.scoreArea || []).map(slimCard),
    max_hand: p.maxHandSize,
  };
  if (who === "corp") {
    view.hand = (p.HQ.cards || []).map(slimCard);
    view.hand_count = (p.HQ.cards || []).length;
    view.deck_count = (p.RnD.cards || []).length;
    view.discard = (p.archives.cards || []).map(slimCard);
    view.bad_publicity = p.badPublicity || 0;
  } else {
    view.hand = (p.grip || []).map(slimCard);
    view.hand_count = (p.grip || []).length;
    view.deck_count = (p.stack || []).length;
    view.discard = (p.heap || []).map(slimCard);
    view.tags = p.tags || 0;
    view.mu = typeof window.MemoryUnits === "function" ? window.MemoryUnits() : p.startingMU;
    view.rig = {
      program: (p.rig.programs || []).map(slimCard),
      hardware: (p.rig.hardware || []).map(slimCard),
      resource: (p.rig.resources || []).map(slimCard),
    };
  }
  return view;
}

function optionLabel(window, command, opt) {
  const pretty = window.NicelyFormatCommand(command);
  if (opt && opt.card && opt.card.title) return pretty + "  " + opt.card.title;
  if (opt && opt.server && opt.server.serverName) return pretty + "  " + opt.server.serverName;
  if (opt && opt.label) return String(opt.label);
  if (opt && opt.subroutine && opt.subroutine.label) return pretty + "  " + opt.subroutine.label;
  return pretty;
}

function collectActions(window) {
  const actions = [];
  const phaseOptions = window.phaseOptions || {};
  for (const command of Object.keys(phaseOptions)) {
    const list = phaseOptions[command] || [];
    list.forEach((opt, idx) => {
      actions.push({
        command,
        index: idx,
        label: optionLabel(window, command, opt),
        card: opt && opt.card ? slimCard(opt.card) : null,
        server: opt && opt.server ? opt.server.serverName || "" : "",
      });
    });
  }
  if (window.validOptions && window.validOptions.length > 1 && window.executingCommand) {
    return window.validOptions.map((opt, idx) => ({
      command: window.executingCommand,
      index: idx,
      label: optionLabel(window, window.executingCommand, opt),
      card: opt && opt.card ? slimCard(opt.card) : null,
      server: opt && opt.server ? opt.server.serverName || "" : "",
      choice: true,
    }));
  }
  return actions;
}

function detectWinner(w) {
  let win = "";
  let reason = "";
  if (typeof w.gameEnded !== "undefined" && w.gameEnded) {
    win = w.lastWinner || "";
    reason = w.lastWinReason || "";
  }
  if (w.corp && w.corp.AI === "won") {
    win = "corp";
    reason = reason || "Corp wins";
  }
  if (w.runner && w.runner.AI === "won") {
    win = "runner";
    reason = reason || "Runner wins";
  }
  if (w.corp && w.runner && typeof w.AgendaPoints === "function") {
    const need = w.AgendaPointsToWin ? w.AgendaPointsToWin() : w.globalProperties.agendaPointsToWin;
    if (w.AgendaPoints(w.corp) >= need) {
      win = "corp";
      reason = "Agenda";
    }
    if (w.AgendaPoints(w.runner) >= need) {
      win = "runner";
      reason = "Agenda";
    }
  }
  return { win, reason };
}

function gameView(id, session) {
  const w = session.window;
  const { win, reason } = detectWinner(w);
  const active = w.activePlayer === w.corp ? "corp" : "runner";
  const viewing = w.viewingPlayer === w.corp ? "corp" : "runner";
  const actions = humanActions(w);
  if (win && session.meta && session.meta.campaign_id) {
    session._winner = win;
    const campaign = campaigns.get(session.meta.campaign_id);
    if (campaign) gauntletHub.resolveFight(catalogWindow(), campaign, session, id);
    actions.push({
      command: "return_gauntlet",
      index: 0,
      label: "RETURN TO GAUNTLET",
    });
  } else if (win && session.meta && session.meta.gauntlet && !session.meta.gauntlet.hub) {
    const g = session.meta.gauntlet;
    if (win === "runner" && g.defeated + 1 < g.length) {
      actions.push({
        command: "next_gauntlet",
        index: 0,
        label: "NEXT OPPONENT  (" + (g.defeated + 1) + "/" + g.length + ")",
      });
    }
  }
  return {
    ok: true,
    id,
    engine: "chiriboga",
    mode: session.meta ? session.meta.mode : "",
    player_deck: session.meta ? session.meta.player_deck || "" : "",
    ai_deck: session.meta ? session.meta.ai_deck || "" : "",
    phase: w.currentPhase ? w.currentPhase.title || w.currentPhase.identifier : "",
    identifier: w.currentPhase ? w.currentPhase.identifier : "",
    active,
    viewing,
    agenda_goal: w.globalProperties ? w.globalProperties.agendaPointsToWin : 7,
    winner: win,
    reason,
    corp: playerView(w, "corp"),
    runner: playerView(w, "runner"),
    servers: {
      hq: slimServer(w.corp.HQ),
      rd: slimServer(w.corp.RnD),
      archives: slimServer(w.corp.archives),
      remotes: (w.corp.remoteServers || []).map(slimServer),
    },
    run: w.attackedServer
      ? { server: w.attackedServer.serverName || "", ice: w.approachIce, encountering: !!w.encountering }
      : null,
    log: (w.godotLog || []).slice(-40),
    tutorial: (w.cardRenderer && w.cardRenderer.tutorialText && w.cardRenderer.tutorialText.text) || "",
    actions,
    gauntlet: session.meta && session.meta.campaign_id
      ? campaignSummary(session.meta.campaign_id)
      : session.meta && session.meta.gauntlet
        ? {
            length: session.meta.gauntlet.length,
            defeated: session.meta.gauntlet.defeated,
            opponent: session.meta.gauntlet.opponents[session.meta.gauntlet.defeated]
              ? session.meta.gauntlet.opponents[session.meta.gauntlet.defeated].name
              : "",
          }
        : null,
    campaign_id: session.meta ? session.meta.campaign_id || "" : "",
  };
}

function campaignSummary(campaignId) {
  const campaign = campaigns.get(campaignId);
  if (!campaign) return { id: campaignId };
  const opp = campaign.opponents[campaign.currentOpponentIndex || 0] || {};
  return {
    id: campaignId,
    hub: true,
    length: campaign.length,
    defeated: campaign.defeated,
    credits: campaign.credits,
    complete: !!campaign.complete,
    lost: !!campaign.lost,
    opponent: opp.gauntletCorpName || opp.name || "",
  };
}

function waitTicks(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isContinueAction(act) {
  const command = String(act.command || "");
  const label = String(act.label || "").toLowerCase();
  return command === "n" || label === "continue" || label.startsWith("continue ");
}

function shouldAutoContinue(session, actions) {
  if (!actions.length || !actions.every(isContinueAction)) return false;
  const w = session.window;
  const phase = w.currentPhase ? w.currentPhase.title || "" : "";
  if (phase === "Tutorial") return false;
  return true;
}

function aiIsActing(window) {
  return !!(window.activePlayer && window.activePlayer.AI != null);
}

function humanActions(window) {
  const actions = collectActions(window);
  if (aiIsActing(window)) return actions.filter(isContinueAction);
  return actions;
}

async function autoContinue(session) {
  const w = session.window;
  for (let i = 0; i < 36; i++) {
    try {
      w.EnumeratePhase();
    } catch (e) {}
    const { win } = detectWinner(w);
    if (win) return;
    const actions = humanActions(w);
    if (shouldAutoContinue(session, actions)) {
      try {
        w.ExecuteChosen(actions[0].command || "n");
      } catch (e) {
        return;
      }
      await waitTicks(40);
      continue;
    }
    if (aiIsActing(w)) {
      await waitTicks(70);
      continue;
    }
    return;
  }
}

async function settle(session, loops = 80) {
  const w = session.window;
  for (let i = 0; i < loops; i++) {
    await waitTicks(40);
    const { win } = detectWinner(w);
    if (win) return;
    try {
      w.EnumeratePhase();
    } catch (e) {
      /* still settling */
    }
    const actions = humanActions(w);
    if (shouldAutoContinue(session, actions)) {
      await autoContinue(session);
      return;
    }
    if (aiIsActing(w)) continue;
    if (actions.length > 0) return;
  }
  await autoContinue(session);
}

async function newGame(body) {
  const { query, meta } = queryFromBody(body || {});
  if (meta && meta.error) return { ok: false, error: meta.error };
  if (!query) return { ok: false, error: "could not build match" };
  const session = createSession(query);
  session.meta = meta || {};
  const id = Math.random().toString(36).slice(2, 12);
  games.set(id, session);
  await settle(session);
  return gameView(id, session);
}

function newCampaign(body) {
  const w = catalogWindow();
  const campaign = gauntletHub.newCampaign(w, body || {});
  const id = Math.random().toString(36).slice(2, 12);
  campaigns.set(id, campaign);
  return gauntletHub.publicView(w, id, campaign);
}

function campaignAction(body) {
  const id = body.id || body.campaign_id;
  const campaign = campaigns.get(id);
  if (!campaign) return { ok: false, error: "unknown campaign" };
  body.campaign_id = id;
  return gauntletHub.applyAction(catalogWindow(), campaign, body);
}

async function nextGauntlet(id, session) {
  const g = session.meta && session.meta.gauntlet;
  if (!g) return { ok: false, error: "not a gauntlet", ...gameView(id, session) };
  g.defeated += 1;
  const next = g.opponents[g.defeated];
  if (!next) return gameView(id, session);
  const params = new URLSearchParams();
  params.set("p", "r");
  params.set("r", g.runner_lz);
  params.set("c", next.lz);
  const fresh = createSession(params.toString());
  fresh.meta = session.meta;
  games.set(id, fresh);
  await settle(fresh);
  return gameView(id, fresh);
}

async function applyAction(id, body) {
  const session = games.get(id);
  if (!session) return { ok: false, error: "unknown game" };
  const w = session.window;
  const command = String(body.command || "");
  if (!command) return { ok: false, error: "missing command", ...gameView(id, session) };
  if (command === "next_gauntlet") return nextGauntlet(id, session);
  if (command === "return_gauntlet") {
    return {
      ok: true,
      return_gauntlet: true,
      campaign_id: session.meta ? session.meta.campaign_id : "",
      ...gameView(id, session),
    };
  }
  const index = Number(body.index || 0);
  try {
    if (body.choice === true || body.resolve === true) {
      w.ResolveChoice(index);
    } else {
      w.ExecuteChosen(command);
      if (w.validOptions && w.validOptions.length > 1 && w.executingCommand === command) {
        w.ResolveChoice(index);
      }
    }
  } catch (e) {
    return { ok: false, error: e.message, ...gameView(id, session) };
  }
  await settle(session);
  return gameView(id, session);
}

function json(res, code, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(code, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Content-Length": Buffer.byteLength(body),
  });
  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (c) => {
      data += c;
      if (data.length > 2e6) req.destroy();
    });
    req.on("end", () => {
      if (!data) return resolve({});
      try {
        resolve(JSON.parse(data));
      } catch (e) {
        reject(e);
      }
    });
    req.on("error", reject);
  });
}

function previewPair() {
  const pair = randomQuickPair();
  const w = catalogWindow();
  return {
    ok: true,
    player: summarizePrecon(w, pair.player),
    ai: summarizePrecon(w, pair.ai),
    side: pair.side,
  };
}

const server = http.createServer(async (req, res) => {
  if (req.method === "OPTIONS") {
    res.writeHead(204, {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    });
    return res.end();
  }
  const url = new URL(req.url, "http://127.0.0.1");
  try {
    if (url.pathname === "/chiriboga/status" && req.method === "GET") {
      return json(res, 200, {
        ok: true,
        engine: "chiriboga",
        version: "0.6.13-BETA",
        source: "https://chiriboga.cronbach.com",
        games: games.size,
        campaigns: campaigns.size,
        port: PORT,
      });
    }
    if (url.pathname === "/chiriboga/catalog" && req.method === "GET") {
      return json(res, 200, { ...catalog(), preview: previewPair() });
    }
    if (url.pathname === "/chiriboga/preview" && req.method === "GET") {
      return json(res, 200, previewPair());
    }
    if (url.pathname === "/chiriboga/new" && (req.method === "POST" || req.method === "GET")) {
      const body = req.method === "POST" ? await readBody(req) : Object.fromEntries(url.searchParams);
      const view = await newGame(body);
      return json(res, 200, view);
    }
    if (url.pathname === "/chiriboga/state" && req.method === "GET") {
      const id = url.searchParams.get("id");
      const session = games.get(id);
      if (!session) return json(res, 404, { ok: false, error: "unknown game" });
      return json(res, 200, gameView(id, session));
    }
    if (url.pathname === "/chiriboga/action" && req.method === "POST") {
      const body = await readBody(req);
      const out = await applyAction(body.id, body);
      return json(res, out.ok === false && out.error === "unknown game" ? 404 : 200, out);
    }
    if (url.pathname === "/chiriboga/gauntlet/new" && (req.method === "POST" || req.method === "GET")) {
      const body = req.method === "POST" ? await readBody(req) : Object.fromEntries(url.searchParams);
      return json(res, 200, newCampaign(body));
    }
    if (url.pathname === "/chiriboga/gauntlet/state" && req.method === "GET") {
      const id = url.searchParams.get("id");
      const campaign = campaigns.get(id);
      if (!campaign) return json(res, 404, { ok: false, error: "unknown campaign" });
      return json(res, 200, gauntletHub.publicView(catalogWindow(), id, campaign));
    }
    if (url.pathname === "/chiriboga/gauntlet/action" && req.method === "POST") {
      const body = await readBody(req);
      const out = campaignAction(body);
      return json(res, out.ok === false && out.error === "unknown campaign" ? 404 : 200, out);
    }
    json(res, 404, { ok: false, error: "not found" });
  } catch (e) {
    console.error(e);
    json(res, 500, { ok: false, error: e.message });
  }
});

if (require.main === module) {
  try {
    catalog();
    console.log("CHIRIBOGA_CATALOG precons=" + catalogCache.precons.length + " sets=" + catalogCache.sets.length);
  } catch (e) {
    console.error("catalog failed", e);
  }
  server.listen(PORT, "127.0.0.1", () => {
    console.log("CHIRIBOGA_BRIDGE_OK port=" + PORT);
  });
}

module.exports = { createSession, newGame, queryFromBody, catalog, previewPair, newCampaign, campaignAction };
