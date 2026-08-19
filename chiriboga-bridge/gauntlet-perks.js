// Headless copy of engine.php gauntlet perk application (Solo Mode).
// Eval'd into the Chiriboga jsdom window after engine scripts so Init() can call applyGauntletPerks.

function getPerkName(perkNum) {
  var basePerk = perkNum > 6 ? perkNum - 6 : perkNum;
  var perkNames = {
    1: "Additional Funds",
    2: "Pre-Installed Neutral Ice",
    3: "Holdover Directive",
    4: "Liquidated Assets",
    5: "Pre-Installed Faction Ice",
    6: "Subsidiary Gains",
  };
  return perkNames[basePerk] || "Unknown Perk " + perkNum;
}

function isBossPerk(perkNum) {
  var basePerk = perkNum > 6 ? perkNum - 6 : perkNum;
  return basePerk >= 4 && basePerk <= 6;
}

function isDisabledPerk(perkNum) {
  return perkNum > 6;
}

function getGauntletState() {
  var gParam = "";
  try {
    var results = new RegExp("[?&]g=([^&#]*)").exec(window.location.href);
    gParam = results ? decodeURIComponent(results[1]) : "";
  } catch (e) {}
  if (!gParam) return null;
  try {
    return JSON.parse(LZString.decompressFromEncodedURIComponent(gParam));
  } catch (e) {
    return null;
  }
}

function getActivePerks() {
  var gauntletState = getGauntletState();
  if (!gauntletState) return [];
  var currentOpponentIndex = gauntletState.currentOpponentIndex || 0;
  var defeatOrder = gauntletState.defeatOrder || [];
  var activePerks = [];
  for (var i = 0; i < defeatOrder.length; i++) {
    var opponent = gauntletState.opponents[defeatOrder[i]];
    if (opponent && typeof opponent.startingPerk === "number" && opponent.startingPerk > 0) {
      activePerks.push(opponent.perkDisabled ? opponent.startingPerk + 6 : opponent.startingPerk);
    }
  }
  var currentOpponent = gauntletState.opponents[currentOpponentIndex];
  if (currentOpponent && typeof currentOpponent.startingPerk === "number" && currentOpponent.startingPerk > 0) {
    activePerks.push(currentOpponent.perkDisabled ? currentOpponent.startingPerk + 6 : currentOpponent.startingPerk);
  }
  return activePerks;
}

function _iceInAllowedSets(cardIdNum, allowedSets) {
  if (!allowedSets || allowedSets.length === 0) return true;
  for (var i = 0; i < allowedSets.length; i++) {
    var setCode = allowedSets[i];
    if (setCode === "sg" && cardIdNum >= 30000 && cardIdNum < 31000) return true;
    if (setCode === "su21" && cardIdNum >= 31000 && cardIdNum < 32000) return true;
    if (setCode === "ms" && cardIdNum >= 33000 && cardIdNum < 34000) return true;
    if (setCode === "el" && cardIdNum >= 34000 && cardIdNum < 35000) return true;
  }
  return false;
}

function findNeutralIce(allowedSets) {
  var neutralIce = [];
  for (var cardId in cardSet) {
    var card = cardSet[cardId];
    if (!card) continue;
    if (card.cardType !== "ice") continue;
    if (card.player !== corp) continue;
    if (card.faction !== "Neutral") continue;
    if (!_iceInAllowedSets(parseInt(cardId, 10), allowedSets)) continue;
    neutralIce.push(parseInt(cardId, 10));
  }
  return neutralIce;
}

function findFactionIce(allowedSets) {
  var factionIce = [];
  for (var cardId in cardSet) {
    var card = cardSet[cardId];
    if (!card) continue;
    if (card.cardType !== "ice") continue;
    if (card.player !== corp) continue;
    if (card.faction === "Neutral") continue;
    if (!_iceInAllowedSets(parseInt(cardId, 10), allowedSets)) continue;
    factionIce.push(parseInt(cardId, 10));
  }
  return factionIce;
}

function _installPerkIce(iceCard, outermost) {
  if (!iceCard) return;
  var centralServers = [corp.HQ, corp.RnD, corp.archives];
  var targetServer = centralServers[Math.floor(Math.random() * centralServers.length)];
  iceCard.cardLocation = targetServer.ice;
  iceCard.faceUp = false;
  iceCard.rezzed = false;
  if (outermost) targetServer.ice.push(iceCard);
  else targetServer.ice.push(iceCard);
  Log("Perk: " + iceCard.title + " pre-installed protecting " + ServerName(targetServer));
}

function applyPerk1_AdditionalFunds() {
  Log("Perk: Additional Funds");
  GainCredits(corp, 5);
}

function applyPerk2_PreInstalledNeutralIce() {
  var gauntletState = getGauntletState();
  var allowedSets = gauntletState ? gauntletState.allowedSets : [];
  var ids = findNeutralIce(allowedSets);
  if (!ids.length) return;
  var iceCard = InstanceCard(ids[Math.floor(Math.random() * ids.length)], cardBackTexturesCorp, glowTextures, strengthTextures);
  _installPerkIce(iceCard, false);
}

function applyPerk3_HoldoverDirective() {
  var agendaCard = InstanceCard(10, cardBackTexturesCorp, glowTextures, strengthTextures);
  if (!agendaCard) return;
  agendaCard.cardLocation = corp.scoreArea;
  agendaCard.faceUp = true;
  agendaCard.advancement = 0;
  corp.scoreArea.push(agendaCard);
  Log("Perk: Corp starts with " + agendaCard.title + " scored");
}

function applyPerk4_LiquidatedAssets() {
  Log("Perk: Liquidated Assets");
  GainCredits(corp, 10);
}

function applyPerk5_PreInstalledFactionIce() {
  var gauntletState = getGauntletState();
  var allowedSets = gauntletState ? gauntletState.allowedSets : [];
  var ids = findFactionIce(allowedSets);
  if (!ids.length) return;
  var iceCard = InstanceCard(ids[Math.floor(Math.random() * ids.length)], cardBackTexturesCorp, glowTextures, strengthTextures);
  _installPerkIce(iceCard, true);
}

function applyPerk6_SubsidiaryGains() {
  var agendaCard = InstanceCard(11, cardBackTexturesCorp, glowTextures, strengthTextures);
  if (!agendaCard) return;
  agendaCard.cardLocation = corp.scoreArea;
  agendaCard.faceUp = true;
  agendaCard.advancement = 0;
  corp.scoreArea.push(agendaCard);
  Log("Perk: Corp starts with " + agendaCard.title + " scored");
}

function applyGauntletPerks() {
  var activePerks = getActivePerks();
  if (!activePerks.length) return;
  for (var i = 0; i < activePerks.length; i++) {
    var perk = activePerks[i];
    if (perk > 6) continue;
    switch (perk) {
      case 1:
        applyPerk1_AdditionalFunds();
        break;
      case 2:
        applyPerk2_PreInstalledNeutralIce();
        break;
      case 3:
        applyPerk3_HoldoverDirective();
        break;
      case 4:
        applyPerk4_LiquidatedAssets();
        break;
      case 5:
        applyPerk5_PreInstalledFactionIce();
        break;
      case 6:
        applyPerk6_SubsidiaryGains();
        break;
    }
  }
}
