"use strict";

const PERK_NAMES = {
  1: "Additional Funds",
  2: "Pre-Installed Neutral Ice",
  3: "Holdover Directive",
  4: "Liquidated Assets",
  5: "Pre-Installed Faction Ice",
  6: "Subsidiary Gains",
};

const LEET_NAMES = [
  "xX_C0rP", "D4t4.VuL", "n3X7~g3N", "SyS7_c0r",
  "m3G4::Cp", "Zer0_D4w", "c0D3.r3D", "H4cK~Pr0",
  "F1r3|W4L", "d4Rk_N0d", "Gh0s7.N3", "V1rU5~Fr",
  "cR4sH_73", "r007|4cC", "5yS.0v3R", "gL17cH_F",
  "4p3X~C0r", "N0v4_53c", "Ph4n70M.", "cYb3R|L0",
  "7r4C3_Nu", "pR070~M4", "Qu4n7uM.", "5734L7H_",
  "bL4cK|1c", "R3d_Qu33", "5p1D3r.A", "v3C70R~9",
  "Null.p7R", "w4RM_h0L", "1c3~Br34", "Pr0Xy|99",
  "d33P_w3B", "n0D3.x3C", "Z3r0|d4Y", "C0r3~DmP",
];

function perkName(id) {
  const base = id > 6 ? id - 6 : id;
  return PERK_NAMES[base] || "Unknown Perk";
}

function isBossPerk(id) {
  const base = id > 6 ? id - 6 : id;
  return base >= 4 && base <= 6;
}

function makeRng(window, seed) {
  if (window.Math && typeof window.Math.seedrandom === "function") {
    const rng = new window.Math.seedrandom(String(seed));
    return () => rng();
  }
  let h = 2166136261;
  const s = String(seed);
  for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619);
  return () => {
    h = Math.imul(h ^ (h >>> 13), 1274126177);
    return ((h >>> 0) % 1000000) / 1000000;
  };
}

function shuffle(list, rng) {
  const out = list.slice();
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    const t = out[i];
    out[i] = out[j];
    out[j] = t;
  }
  return out;
}

function cardTitle(window, id) {
  const card = window.cardSet[Number(id)];
  return card && card.title ? card.title : "Unknown Card";
}

function cardMatchesRequirement(window, cardId, matchSubtypes, excludeSubtypes) {
  const card = window.cardSet[cardId];
  if (!card || !card.subTypes) return false;
  const subtypes = card.subTypes || [];
  if (excludeSubtypes && excludeSubtypes.length) {
    for (const sub of excludeSubtypes) {
      if (subtypes.indexOf(sub) !== -1) return false;
    }
  }
  if (!matchSubtypes || !matchSubtypes.length) return true;
  for (const sub of matchSubtypes) {
    if (subtypes.indexOf(sub) === -1) return false;
  }
  return true;
}

function isRunnerCard(window, card) {
  return card && card.player === window.runner;
}

function buildStarterPool(window, rng, config) {
  const pool = {};
  const excluded = {};
  if (config.lockedFixedCards && config.fixedCards) {
    for (const c of config.fixedCards) excluded[c.id] = true;
  }
  if (config.fixedCards) {
    for (const fixed of config.fixedCards) {
      const id = Number(fixed.id);
      const qty = Number(fixed.quantity || 1);
      pool[id] = (pool[id] || 0) + qty;
    }
  }
  const useBalanced = config.balancedFactions !== false;
  const runnerFactions = ["Anarch", "Criminal", "Shaper", "Neutral"];
  for (const requirement of config.randomCardRequirements || []) {
    const quantity = requirement.quantity || 0;
    const cardType = requirement.cardType;
    const matchSubtypes = requirement.matchSubtypes || [];
    const excludeSubtypes = requirement.excludeSubtypes || [];
    if (useBalanced) {
      const cardsByFaction = {};
      for (const f of runnerFactions) cardsByFaction[f] = [];
      for (const key of Object.keys(window.cardSet)) {
        const cardId = parseInt(key, 10);
        const card = window.cardSet[cardId];
        if (!card || !isRunnerCard(window, card)) continue;
        if (card.cardType !== cardType || card.cardType === "identity") continue;
        if (excluded[cardId]) continue;
        if (!cardMatchesRequirement(window, cardId, matchSubtypes, excludeSubtypes)) continue;
        const faction = card.faction || "Neutral";
        if (cardsByFaction[faction]) cardsByFaction[faction].push(cardId);
      }
      const factionsWithCards = runnerFactions.filter((f) => cardsByFaction[f].length > 0);
      if (!factionsWithCards.length) continue;
      factionsWithCards.sort((a, b) => cardsByFaction[a].length - cardsByFaction[b].length);
      const basePerFaction = Math.floor(quantity / factionsWithCards.length);
      const remainder = quantity % factionsWithCards.length;
      for (let f = 0; f < factionsWithCards.length; f++) {
        const faction = factionsWithCards[f];
        let pile = cardsByFaction[faction].slice();
        const target = basePerFaction + (f < remainder ? 1 : 0);
        for (let s = 0; s < target; s++) {
          if (!pile.length) pile = cardsByFaction[faction].slice();
          const idx = Math.floor(rng() * pile.length);
          const selected = pile.splice(idx, 1)[0];
          pool[selected] = (pool[selected] || 0) + 1;
        }
      }
    } else {
      const matching = [];
      for (const key of Object.keys(window.cardSet)) {
        const cardId = parseInt(key, 10);
        const card = window.cardSet[cardId];
        if (!card || !isRunnerCard(window, card)) continue;
        if (card.cardType !== cardType || card.cardType === "identity") continue;
        if (excluded[cardId]) continue;
        if (cardMatchesRequirement(window, cardId, matchSubtypes, excludeSubtypes)) matching.push(cardId);
      }
      for (let s = 0; s < quantity && matching.length; s++) {
        const selected = matching[Math.floor(rng() * matching.length)];
        pool[selected] = (pool[selected] || 0) + 1;
      }
    }
  }
  return pool;
}

function deckFromPool(pool) {
  const deck = {};
  for (const [id, count] of Object.entries(pool)) {
    deck[id] = Math.min(3, Number(count) || 0);
  }
  return deck;
}

function cardsArray(counts) {
  const cards = [];
  for (const [id, count] of Object.entries(counts || {})) {
    for (let i = 0; i < Number(count); i++) cards.push(parseInt(id, 10));
  }
  return cards;
}

function pickOpponents(window, length, rng, config) {
  const precons = (window.preconDecks || []).filter((d) => d.useForGauntlet === true);
  const corpPrecons = precons.filter((d) => {
    const identity = window.cardSet[Number(d.identity)];
    return identity && identity.player === window.corp;
  });
  const regularPerks = [];
  for (let cluster = 0; cluster < 3; cluster++) {
    regularPerks.push(...shuffle([1, 2, 3], rng));
  }
  const bossPerks = shuffle([4, 5, 6], rng);
  function startingPerk(n) {
    if ([1, 2, 3, 5, 6, 7, 9, 10, 11].indexOf(n) !== -1) return regularPerks.length ? regularPerks.shift() : 0;
    if (n === 4 || n === 8 || n === 12) return bossPerks.length ? bossPerks.shift() : 0;
    return 0;
  }
  const alternate = config.alternateFactions !== false;
  const selected = [];
  if (alternate) {
    const allFactions = ["Jinteki", "Haas-Bioroid", "NBN", "Weyland Consortium"];
    const factions = [];
    for (let cluster = 0; cluster < Math.ceil(length / 4); cluster++) {
      factions.push(...shuffle(allFactions, rng));
    }
    const chosenFactions = factions.slice(0, length);
    for (const faction of chosenFactions) {
      const candidates = corpPrecons.filter((d) => (window.cardSet[Number(d.identity)] || {}).faction === faction);
      const pool = candidates.length ? candidates : corpPrecons;
      if (!pool.length) continue;
      selected.push(preconToOpponent(window, pool[Math.floor(rng() * pool.length)]));
    }
    const chance = typeof config.neutralBossChance === "number" ? config.neutralBossChance : 0;
    if (selected.length === length && rng() < chance) {
      const neutrals = corpPrecons.filter((d) => (window.cardSet[Number(d.identity)] || {}).faction === "Neutral");
      if (neutrals.length) selected[selected.length - 1] = preconToOpponent(window, neutrals[Math.floor(rng() * neutrals.length)]);
    }
  } else {
    const available = corpPrecons.slice();
    for (let i = 0; i < length && available.length; i++) {
      const idx = Math.floor(rng() * available.length);
      selected.push(preconToOpponent(window, available.splice(idx, 1)[0]));
      if (!available.length) available.push(...corpPrecons);
    }
  }
  const names = shuffle(LEET_NAMES, rng);
  for (let i = 0; i < selected.length; i++) {
    selected[i].startingPerk = startingPerk(i + 1);
    selected[i].gauntletCorpName = names[i % names.length];
    selected[i].hasbeendefeated = false;
    selected[i].perkRevealed = false;
    selected[i].perkDisabled = false;
    selected[i].decklistRevealed = false;
  }
  return selected;
}

function preconToOpponent(window, precon) {
  const identity = parseInt(precon.identity, 10);
  const card = window.cardSet[identity] || {};
  const cards = [];
  for (const [id, count] of Object.entries(precon.cards || {})) {
    for (let q = 0; q < Number(count); q++) cards.push(parseInt(id, 10));
  }
  return {
    identity,
    cards,
    name: precon.name || "Unknown Deck",
    faction: card.faction || "Unknown",
    URL: precon.URL || "",
  };
}

function selectShopPacks(config, seed, purchaseCount, window) {
  const packs = config.cardPacks || [];
  if (purchaseCount === 0) {
    const factionPacks = [];
    for (const name of ["Anarch", "Criminal", "Shaper"]) {
      const pack = packs.find((p) => p.name && p.name.indexOf(name) !== -1);
      if (pack) factionPacks.push(pack);
    }
    if (factionPacks.length === 3) return factionPacks.map(slimPack);
  }
  const rng = makeRng(window, seed + "_packs_" + purchaseCount);
  const indices = [];
  while (indices.length < 3 && indices.length < packs.length) {
    const n = Math.floor(rng() * packs.length);
    if (indices.indexOf(n) === -1) indices.push(n);
  }
  return indices.map((i) => slimPack(packs[i]));
}

function slimPack(pack) {
  return { name: pack.name, cost: pack.cost || 10, cardQuantity: pack.cardQuantity || 5, _full: pack };
}

function generatePackCards(window, pack, rng, strictPacks) {
  const cfg = pack._full || pack;
  let strictFaction = null;
  let strictType = null;
  if (strictPacks && cfg.name) {
    const n = cfg.name.toLowerCase();
    if (n.indexOf("anarch") !== -1) strictFaction = "anarch";
    else if (n.indexOf("criminal") !== -1) strictFaction = "criminal";
    else if (n.indexOf("shaper") !== -1) strictFaction = "shaper";
    if (n.indexOf("program") !== -1) strictType = "program";
    else if (n.indexOf("hardware") !== -1) strictType = "hardware";
    else if (n.indexOf("event") !== -1) strictType = "event";
    else if (n.indexOf("resource") !== -1) strictType = "resource";
  }
  const weighted = [];
  for (let cardId = 0; cardId < window.cardSet.length; cardId++) {
    const card = window.cardSet[cardId];
    if (!card || !isRunnerCard(window, card) || card.cardType === "identity") continue;
    const cardType = String(card.cardType || "").toLowerCase();
    const cardFaction = String(card.faction || "").toLowerCase();
    let factionKey = null;
    if (cardFaction.indexOf("anarch") === 0) factionKey = "anarch";
    else if (cardFaction.indexOf("criminal") === 0) factionKey = "criminal";
    else if (cardFaction.indexOf("shaper") === 0) factionKey = "shaper";
    else if (cardFaction.indexOf("neutral") === 0) factionKey = "neutral";
    if (strictPacks) {
      if (strictFaction && factionKey !== strictFaction && factionKey !== "neutral") continue;
      if (strictType && cardType !== strictType) continue;
    }
    const typeWeight = (cfg.typeFactors && cfg.typeFactors[cardType]) || 0;
    const factionWeight = factionKey ? (cfg.factionFactors && cfg.factionFactors[factionKey]) || 0 : 0;
    if (typeWeight <= 0 || factionWeight <= 0) continue;
    weighted.push({ cardId, weight: typeWeight * factionWeight });
  }
  if (!weighted.length) return [];
  const total = weighted.reduce((n, c) => n + c.weight, 0);
  const cards = [];
  for (let i = 0; i < (cfg.cardQuantity || 5); i++) {
    let roll = rng() * total;
    for (const item of weighted) {
      roll -= item.weight;
      if (roll <= 0) {
        cards.push(item.cardId);
        break;
      }
    }
  }
  return cards;
}

function allowedRunnerIdentities(window, config) {
  const allowed = (config.allowedIdentities && config.allowedIdentities.runnerIds) || [];
  const out = [];
  for (const id of allowed) {
    const card = window.cardSet[id];
    if (card && card.cardType === "identity" && isRunnerCard(window, card)) {
      out.push({ id, title: card.title, faction: card.faction || "" });
    }
  }
  return out;
}

function compressDeck(window, identity, cards, extra) {
  const json = Object.assign({ identity: Number(identity), cards: cards.slice() }, extra || {});
  return window.LZString.compressToEncodedURIComponent(JSON.stringify(json));
}

function newCampaign(window, opts) {
  const config = window.gauntletConfig || {};
  const length = Math.max(4, Math.min(12, Number(opts.length || config.gauntletLength || 8)));
  const seed = opts.seed || Math.random().toString(36).slice(2, 15);
  const rng = makeRng(window, seed);
  const pool = buildStarterPool(window, rng, config);
  const identities = allowedRunnerIdentities(window, config);
  const identity = identities.length ? identities[Math.floor(rng() * identities.length)].id : 30001;
  const campaign = {
    seed,
    length,
    credits: config.startingCredits || 30,
    creditsWon: 0,
    creditsWonText: "",
    pool,
    deck: deckFromPool(pool),
    identity,
    identityLocked: true,
    opponents: pickOpponents(window, length, rng, config),
    defeated: 0,
    defeatOrder: [],
    agendaScored: 0,
    agendaStolen: 0,
    shopPurchaseCount: 0,
    shopPacks: [],
    strictPacks: !!opts.strictPacks || !!config.strictPacks,
    prepareHackBonus: 0,
    hackAttempts: {},
    failedHackChances: {},
    complete: false,
    lost: false,
    lastMessage: "WELCOME TO THE GAUNTLET. Buy packs, then fight.",
    lastPack: [],
    resolvedGames: {},
  };
  campaign.shopPacks = selectShopPacks(config, seed, 0, window);
  return campaign;
}

function poolSize(pool) {
  return Object.values(pool || {}).reduce((n, c) => n + Number(c || 0), 0);
}

function publicView(window, id, campaign) {
  const config = window.gauntletConfig || {};
  const hack = config.hackOpponent || {};
  const shop = config.shop || {};
  const identities = allowedRunnerIdentities(window, config);
  const identityCard = window.cardSet[campaign.identity] || {};
  return {
    ok: true,
    id,
    mode: "gauntlet",
    credits: campaign.credits,
    credits_won: campaign.creditsWon,
    credits_won_text: campaign.creditsWonText,
    length: campaign.length,
    defeated: campaign.defeated,
    complete: !!campaign.complete,
    lost: !!campaign.lost,
    identity: campaign.identity,
    identity_title: identityCard.title || "",
    identity_faction: identityCard.faction || "",
    identity_locked: !!campaign.identityLocked,
    identities,
    deck_size: poolSize(campaign.deck),
    pool_size: poolSize(campaign.pool),
    extra_sellable: Object.values(campaign.pool).some((n) => n > 3),
    last_message: campaign.lastMessage,
    last_pack: (campaign.lastPack || []).map((cardId) => ({
      id: cardId,
      title: cardTitle(window, cardId),
    })),
    shop: {
      reroll_cost: shop.rerollPacksCost || 5,
      unlock_cost: shop.unlockIdentityCost || 50,
      packs: campaign.shopPacks.map((p, index) => ({
        index,
        name: p.name,
        cost: p.cost,
        card_quantity: p.cardQuantity,
      })),
    },
    hack: {
      view_decklist_cost: hack.viewDecklistCost || 5,
      view_perk_cost: hack.viewPerkCost || 5,
      disable_perk_cost: hack.disablePerkCost || 15,
      disable_boss_perk_cost: hack.disableBossPerkCost || 30,
      prepare_cost: hack.prepareHackCost || 3,
      prepare_bonus: campaign.prepareHackBonus || 0,
    },
    opponents: campaign.opponents.map((opp, index) => summarizeOpponent(window, campaign, index, hack)),
  };
}

function summarizeOpponent(window, campaign, index, hack) {
  const opp = campaign.opponents[index];
  const card = window.cardSet[opp.identity] || {};
  const isBoss = (index + 1) % 4 === 0;
  const hasPerk = opp.startingPerk > 0;
  const revealed = !!opp.perkRevealed;
  return {
    index,
    name: opp.gauntletCorpName || card.title || "Unknown",
    deck_name: opp.name,
    faction: opp.faction || card.faction || "",
    identity: opp.identity,
    identity_title: card.title || "",
    defeated: !!opp.hasbeendefeated,
    is_boss: isBoss,
    has_perk: hasPerk,
    perk_revealed: revealed,
    perk_disabled: !!opp.perkDisabled,
    perk_name: revealed || opp.perkDisabled ? perkName(opp.startingPerk) : hasPerk ? "???" : "None",
    decklist_revealed: !!opp.decklistRevealed,
    decklist: opp.decklistRevealed ? countTitles(window, opp.cards) : [],
    chances: {
      decklist: effectiveChance(window, campaign, index, "decklist", hack),
      perk: effectiveChance(window, campaign, index, "perk", hack),
      disable: effectiveChance(window, campaign, index, isBossPerk(opp.startingPerk) ? "disableBossPerk" : "disablePerk", hack),
    },
  };
}

function countTitles(window, cards) {
  const counts = {};
  for (const id of cards || []) counts[id] = (counts[id] || 0) + 1;
  return Object.keys(counts)
    .map((id) => ({ id: Number(id), title: cardTitle(window, id), count: counts[id] }))
    .sort((a, b) => a.title.localeCompare(b.title));
}

function attemptNumber(campaign, opponentIndex, actionType) {
  const key = opponentIndex + "_" + actionType;
  return campaign.hackAttempts[key] || 0;
}

function hackChance(window, campaign, opponentIndex, actionType, hack) {
  const seed = campaign.seed + "_hack_" + opponentIndex + "_" + actionType + "_" + attemptNumber(campaign, opponentIndex, actionType);
  const rng = makeRng(window, seed);
  let min = 10;
  let max = 90;
  if (actionType === "decklist") {
    min = hack.viewDecklistChanceMin || 25;
    max = hack.viewDecklistChanceMax || 75;
  } else if (actionType === "perk") {
    min = hack.viewPerkChanceMin || 75;
    max = hack.viewPerkChanceMax || 95;
  } else if (actionType === "disablePerk") {
    min = hack.disablePerkChanceMin || 50;
    max = hack.disablePerkChanceMax || 75;
  } else if (actionType === "disableBossPerk") {
    min = hack.disableBossPerkChanceMin || 25;
    max = hack.disableBossPerkChanceMax || 50;
  }
  let base = Math.floor(rng() * (max - min + 1)) + min;
  const failKey = opponentIndex + "_" + actionType;
  if (campaign.failedHackChances[failKey] !== undefined) {
    const recoveryRng = makeRng(window, campaign.seed + "_recovery_" + opponentIndex + "_" + actionType + "_" + attemptNumber(campaign, opponentIndex, actionType));
    const bonusMin = hack.failureRecoveryBonusMin || 5;
    const bonusMax = hack.failureRecoveryBonusMax || 15;
    const recovery = Math.floor(recoveryRng() * (bonusMax - bonusMin + 1)) + bonusMin;
    base = Math.max(base, campaign.failedHackChances[failKey] + recovery);
  }
  return Math.min(base, 95);
}

function effectiveChance(window, campaign, opponentIndex, actionType, hack) {
  return Math.min(hackChance(window, campaign, opponentIndex, actionType, hack) + (campaign.prepareHackBonus || 0), 95);
}

function addCardsToPool(campaign, cardIds) {
  for (const id of cardIds) {
    campaign.pool[id] = (campaign.pool[id] || 0) + 1;
    campaign.deck[id] = Math.min(3, (campaign.deck[id] || 0) + 1);
  }
}

function spend(campaign, cost) {
  if (campaign.credits < cost) return false;
  campaign.credits -= cost;
  return true;
}

function applyAction(window, campaign, body) {
  const config = window.gauntletConfig || {};
  const hack = config.hackOpponent || {};
  const shop = config.shop || {};
  const action = String(body.action || body.command || "");
  if (campaign.complete || campaign.lost) {
    campaign.lastMessage = campaign.complete ? "Gauntlet complete." : "Gauntlet lost.";
    return publicView(window, body.campaign_id, campaign);
  }
  if (action === "buy") {
    const pack = campaign.shopPacks[Number(body.index || 0)];
    if (!pack) return fail(window, campaign, body, "unknown pack");
    if (!spend(campaign, pack.cost)) return fail(window, campaign, body, "not enough credits");
    const rng = makeRng(window, campaign.seed + "_buy_" + campaign.shopPurchaseCount + "_" + pack.name);
    const cards = generatePackCards(window, pack, rng, campaign.strictPacks);
    addCardsToPool(campaign, cards);
    campaign.lastPack = cards;
    campaign.lastMessage = "Opened " + pack.name + ": " + cards.map((id) => cardTitle(window, id)).join(", ");
    return publicView(window, body.campaign_id, campaign);
  }
  if (action === "reroll") {
    const cost = shop.rerollPacksCost || 5;
    if (!spend(campaign, cost)) return fail(window, campaign, body, "not enough credits");
    campaign.shopPurchaseCount += 1;
    campaign.shopPacks = selectShopPacks(config, campaign.seed, campaign.shopPurchaseCount, window);
    campaign.lastMessage = "Shop packs re-rolled.";
    return publicView(window, body.campaign_id, campaign);
  }
  if (action === "sell") {
    let gained = 0;
    for (const [id, count] of Object.entries(campaign.pool)) {
      if (count > 3) {
        const extra = count - 3;
        campaign.pool[id] = 3;
        if ((campaign.deck[id] || 0) > 3) campaign.deck[id] = 3;
        gained += extra;
      }
    }
    campaign.credits += gained;
    campaign.lastMessage = gained ? "Sold extras for " + gained + " credits." : "No extras to sell.";
    return publicView(window, body.campaign_id, campaign);
  }
  if (action === "unlock") {
    const cost = shop.unlockIdentityCost || 50;
    if (!campaign.identityLocked) {
      campaign.lastMessage = "Identity already unlocked.";
      return publicView(window, body.campaign_id, campaign);
    }
    if (!spend(campaign, cost)) return fail(window, campaign, body, "not enough credits");
    campaign.identityLocked = false;
    campaign.lastMessage = "Identity unlocked.";
    return publicView(window, body.campaign_id, campaign);
  }
  if (action === "set_identity") {
    if (campaign.identityLocked) return fail(window, campaign, body, "identity locked");
    const next = Number(body.identity);
    const allowed = allowedRunnerIdentities(window, config).some((i) => i.id === next);
    if (!allowed) return fail(window, campaign, body, "identity not allowed");
    campaign.identity = next;
    campaign.lastMessage = "Identity set to " + cardTitle(window, next) + ".";
    return publicView(window, body.campaign_id, campaign);
  }
  if (action === "prepare" || action === "hack_decklist" || action === "hack_perk" || action === "disable_perk") {
    return applyHack(window, campaign, body, action, hack);
  }
  return fail(window, campaign, body, "unknown action");
}

function fail(window, campaign, body, error) {
  campaign.lastMessage = error;
  const view = publicView(window, body.campaign_id, campaign);
  view.ok = false;
  view.error = error;
  return view;
}

function applyHack(window, campaign, body, action, hack) {
  const index = Number(body.opponent_index ?? body.index ?? 0);
  const opp = campaign.opponents[index];
  if (!opp || opp.hasbeendefeated) return fail(window, campaign, body, "invalid opponent");
  if (action === "prepare") {
    const cost = hack.prepareHackCost || 3;
    if (!spend(campaign, cost)) return fail(window, campaign, body, "not enough credits");
    const rng = makeRng(window, campaign.seed + "_prepare_" + index + "_" + campaign.credits);
    const bonusMin = hack.prepareHackBonusMin || 5;
    const bonusMax = hack.prepareHackBonusMax || 15;
    const bonus = Math.floor(rng() * (bonusMax - bonusMin + 1)) + bonusMin;
    campaign.prepareHackBonus = (campaign.prepareHackBonus || 0) + bonus;
    campaign.lastMessage = "Hack prepared: +" + bonus + "% (now +" + campaign.prepareHackBonus + "%).";
    return publicView(window, body.campaign_id, campaign);
  }
  const kind = action === "hack_decklist" ? "decklist" : action === "hack_perk" ? "perk" : isBossPerk(opp.startingPerk) ? "disableBossPerk" : "disablePerk";
  const cost =
    kind === "decklist"
      ? hack.viewDecklistCost || 5
      : kind === "perk"
        ? hack.viewPerkCost || 5
        : kind === "disableBossPerk"
          ? hack.disableBossPerkCost || 30
          : hack.disablePerkCost || 15;
  if (kind === "decklist" && opp.decklistRevealed) {
    campaign.lastMessage = "Decklist already revealed.";
    return publicView(window, body.campaign_id, campaign);
  }
  if (kind === "perk" && (!opp.startingPerk || opp.perkRevealed)) {
    campaign.lastMessage = opp.startingPerk ? "Perk already revealed." : "No perk.";
    return publicView(window, body.campaign_id, campaign);
  }
  if ((kind === "disablePerk" || kind === "disableBossPerk") && (!opp.startingPerk || opp.perkDisabled)) {
    campaign.lastMessage = "No perk to disable.";
    return publicView(window, body.campaign_id, campaign);
  }
  if (!spend(campaign, cost)) return fail(window, campaign, body, "not enough credits");
  const attemptNum = attemptNumber(campaign, index, kind);
  const chance = effectiveChance(window, campaign, index, kind, hack);
  campaign.prepareHackBonus = 0;
  campaign.hackAttempts[index + "_" + kind] = attemptNum + 1;
  const rollRng = makeRng(window, campaign.seed + "_hackroll_" + kind + "_" + index + "_" + attemptNum);
  const roll = Math.floor(rollRng() * 100) + 1;
  let lost = [];
  if (kind === "disablePerk" || kind === "disableBossPerk") {
    lost = applyCardLoss(window, campaign, index, attemptNum, kind === "disableBossPerk", hack);
  }
  const success = roll <= chance;
  if (!success) campaign.failedHackChances[index + "_" + kind] = chance;
  else delete campaign.failedHackChances[index + "_" + kind];
  if (success && kind === "decklist") opp.decklistRevealed = true;
  if (success && kind === "perk") opp.perkRevealed = true;
  if (success && (kind === "disablePerk" || kind === "disableBossPerk")) {
    opp.perkDisabled = true;
    opp.perkRevealed = true;
  }
  campaign.lastMessage = success
    ? kind === "decklist"
      ? "DECKLIST REVEALED."
      : kind === "perk"
        ? "PERK REVEALED: " + perkName(opp.startingPerk)
        : "PERK DISABLED: " + perkName(opp.startingPerk)
    : "HACK FAILED (" + chance + "%).";
  if (lost.length) campaign.lastMessage += " Lost: " + lost.join(", ") + ".";
  return publicView(window, body.campaign_id, campaign);
}

function applyCardLoss(window, campaign, opponentIndex, attemptNum, isBoss, hack) {
  const pct = isBoss ? hack.bossHackCardLossPercentage || 40 : hack.regularHackCardLossPercentage || 25;
  const each = isBoss ? hack.bossHackIndividualCardLossPercentage || 60 : hack.regularHackIndividualCardLossPercentage || 50;
  const max = isBoss ? hack.bossHackCardLossMaxQuantity || 3 : hack.regularHackCardLossMaxQuantity || 2;
  const rng = makeRng(window, campaign.seed + "_cardloss_" + opponentIndex + "_" + attemptNum);
  if (Math.floor(rng() * 100) + 1 > pct) return [];
  const lost = [];
  for (let i = 0; i < max; i++) {
    if (Math.floor(rng() * 100) + 1 > each) continue;
    const deckIds = Object.keys(campaign.deck).filter((id) => campaign.deck[id] > 0);
    const poolIds = Object.keys(campaign.pool).filter((id) => campaign.pool[id] > 0);
    const pickFrom = deckIds.length ? deckIds : poolIds;
    if (!pickFrom.length) break;
    const id = pickFrom[Math.floor(rng() * pickFrom.length)];
    if (campaign.deck[id]) campaign.deck[id] -= 1;
    if (campaign.pool[id]) campaign.pool[id] -= 1;
    lost.push(cardTitle(window, id));
  }
  return lost;
}

function fightPayload(window, campaign, opponentIndex) {
  const opp = campaign.opponents[opponentIndex];
  if (!opp || opp.hasbeendefeated) return { ok: false, error: "invalid opponent" };
  campaign.currentOpponentIndex = opponentIndex;
  const gauntletState = {
    subset: campaign.pool,
    opponents: campaign.opponents,
    defeated: campaign.defeated,
    defeatOrder: campaign.defeatOrder.slice(),
    agendaScored: campaign.agendaScored,
    agendaStolen: campaign.agendaStolen,
    credits: campaign.credits,
    creditsWon: campaign.creditsWon,
    creditsWonText: campaign.creditsWonText,
    gauntletLength: campaign.length,
    allowedSets: [],
    strictPacks: campaign.strictPacks,
    seed: campaign.seed,
    shopPurchaseCount: campaign.shopPurchaseCount,
    currentOpponentIndex: opponentIndex,
    runnerIdentity: campaign.identity,
    hackAttempts: campaign.hackAttempts,
  };
  return {
    ok: true,
    r: compressDeck(window, campaign.identity, cardsArray(campaign.deck)),
    c: compressDeck(window, opp.identity, opp.cards, {
      name: opp.name,
      faction: opp.faction,
      URL: opp.URL,
      hasbeendefeated: false,
      startingPerk: opp.startingPerk,
      gauntletCorpName: opp.gauntletCorpName,
      perkDisabled: !!opp.perkDisabled,
    }),
    g: window.LZString.compressToEncodedURIComponent(JSON.stringify(gauntletState)),
    opponent: opp.gauntletCorpName || opp.name,
  };
}

function resolveFight(window, campaign, session, gameId) {
  if (!campaign || campaign.resolvedGames[gameId]) return campaign;
  const w = session.window;
  const winner = session._winner || "";
  if (!winner) return campaign;
  campaign.resolvedGames[gameId] = winner;
  const index = campaign.currentOpponentIndex || 0;
  const opp = campaign.opponents[index];
  const config = window.gauntletConfig || {};
  const rewards = (config.matchRewards || {});
  if (winner === "runner" && opp && !opp.hasbeendefeated) {
    opp.hasbeendefeated = true;
    campaign.defeatOrder.push(index);
    campaign.defeated += 1;
    const runnerPoints = w.AgendaPoints ? w.AgendaPoints(w.runner) : 0;
    const corp = w.corp;
    let corpEx = 0;
    if (corp && corp.scoreArea) {
      for (const agenda of corp.scoreArea) {
        if (agenda.setNumber !== 10 && agenda.setNumber !== 11) corpEx += agenda.agendaPoints || 0;
      }
    }
    campaign.agendaStolen += runnerPoints;
    campaign.agendaScored += w.AgendaPoints ? w.AgendaPoints(corp) : 0;
    const victory = rewards.victory !== undefined ? rewards.victory : 5;
    const stolen = rewards.agendaPointStolen !== undefined ? rewards.agendaPointStolen : 3;
    const scored = rewards.agendaPointScored !== undefined ? rewards.agendaPointScored : -2;
    const boss = rewards.bossBeaten !== undefined ? rewards.bossBeaten : 10;
    const floor = rewards.minimalCredits !== undefined ? rewards.minimalCredits : 10;
    const isBoss = (index + 1) % 4 === 0;
    let gained = victory + stolen * runnerPoints + scored * corpEx + (isBoss ? boss : 0);
    if (gained < floor) gained = floor;
    campaign.credits += gained;
    campaign.creditsWon += gained;
    campaign.creditsWonText = "Victory: +" + victory + "\nTotal: " + gained + " credits";
    campaign.lastMessage = opp.gauntletCorpName + " defeated. +" + gained + " credits.";
    if (campaign.defeated >= campaign.opponents.length) {
      campaign.complete = true;
      campaign.lastMessage = "GAUNTLET COMPLETE. Score credits " + campaign.credits + ".";
    }
  } else if (winner === "corp") {
    campaign.lost = true;
    campaign.lastMessage = "GAUNTLET LOST against " + (opp ? opp.gauntletCorpName : "corp") + ".";
  }
  return campaign;
}

module.exports = {
  newCampaign,
  publicView,
  applyAction,
  fightPayload,
  resolveFight,
  perkName,
};
