#!/usr/bin/env python3
"""Dump mtgred/netrunner cards + official precons into Godot JSON."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import edn_format

KEEP = (
    "code",
    "title",
    "type",
    "side",
    "faction",
    "text",
    "cost",
    "strength",
    "agendapoints",
    "advancementcost",
    "trash",
    "memoryunits",
    "deck-limit",
    "uniqueness",
    "subtype",
    "subtypes",
    "set_code",
    "setname",
    "minimumdecksize",
    "influencelimit",
    "baselink",
    "factioncost",
)


def convert(x):
    if isinstance(x, edn_format.Keyword):
        return x.name
    name = type(x).__name__
    if isinstance(x, dict) or name == "ImmutableDict":
        return {convert(k): convert(v) for k, v in dict(x).items()}
    if isinstance(x, (list, tuple)) or name == "ImmutableList":
        return [convert(i) for i in list(x)]
    if isinstance(x, (set, frozenset)):
        return [convert(i) for i in x]
    return x


def slim(card: dict) -> dict:
    out = {}
    for key in KEEP:
        if key in card and card[key] not in (None, "", []):
            out[key] = card[key]
    if "subtypes" in out and isinstance(out["subtypes"], str):
        out["subtypes"] = [s.strip() for s in out["subtypes"].split(" - ")]
    return out


def _unescape(s: str) -> str:
    return s.replace('\\"', '"').replace("\\\\", "\\")


def parse_qty_cards(blob: str) -> list[dict]:
    return [
        {"qty": int(q), "title": t}
        for q, t in re.findall(r'\{:qty (\d+) :card "((?:\\.|[^"\\])*)"\}', blob)
    ]


def parse_gateway_maps(src: str) -> dict:
    decks = {}
    for m in re.finditer(
        r"\(def (gateway-\S+)\s+"
        r"\{:format \"[^\"]+\"\s+"
        r":identity \{:title \"([^\"]+)\" :side \"([^\"]+)\" :code \"([^\"]+)\"\}\s+"
        r":name \"([^\"]+)\"\s+"
        r":cards \[(.*?)\]\}",
        src,
        re.S,
    ):
        name, title, side, code, deck_name, cards = m.groups()
        decks[name] = {
            "name": deck_name,
            "identity": code,
            "identity_title": title,
            "side": side.lower(),
            "cards": parse_qty_cards(cards),
        }
    return decks


def parse_precons_in_matchups(src: str) -> dict:
    """Map def-name -> precons and gateway refs."""
    by_def = {}
    chunks = re.split(r"\n\(def ", src)
    for chunk in chunks[1:]:
        name_m = re.match(r"([A-Za-z0-9-]+)", chunk)
        if not name_m or "(matchup" not in chunk[:200]:
            continue
        name = name_m.group(1)
        precons = []
        for p in re.finditer(
            r'\(precon\s+"((?:\\.|[^"\\])*)"\s+'
            r'\{:title\s+"((?:\\.|[^"\\])*)"\s+:side\s+"([^"]+)"\s+:code\s+"([^"]+)"\}\s+'
            r"\[(.*?)\]",
            chunk,
            re.S,
        ):
            precons.append(
                {
                    "name": _unescape(p.group(1)),
                    "identity_title": _unescape(p.group(2)),
                    "side": p.group(3).lower(),
                    "identity": p.group(4),
                    "cards": parse_qty_cards(p.group(5)),
                }
            )
        refs = re.findall(r"gateway-[a-z-]+", chunk)
        by_def[name] = {"precons": precons, "refs": refs}
    return by_def


def parse_matchup_keys(src: str) -> list[tuple[str, str]]:
    block = src.split("(defn matchup-by-key", 1)[1].split("(def all-matchups", 1)[0]
    return re.findall(r":([a-z0-9-]+)\s+([a-z0-9-]+)", block)


def tr_label(src: str, def_name: str) -> str:
    m = re.search(rf"\n\(def {re.escape(def_name)}\s+\(matchup", src)
    if not m:
        return def_name
    snippet = src[m.start() : m.start() + 1200]
    tags = re.findall(r'\[[^\]]+ "([^"]+)"\]', snippet)
    if len(tags) >= 2:
        return tags[1]
    return tags[0] if tags else def_name


def resolve_cards(entries: list[dict], by_title: dict) -> dict[str, int]:
    out: dict[str, int] = {}
    missing = []
    for item in entries:
        title = _unescape(item["title"])
        card = by_title.get(title)
        if not card:
            missing.append(title)
            continue
        code = str(card["code"])
        out[code] = out.get(code, 0) + int(item["qty"])
    return out, missing


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "/home/ubuntu/netrunner")
    dest = Path(sys.argv[2] if len(sys.argv) > 2 else "/workspace/data/jinteki")
    dest.mkdir(parents=True, exist_ok=True)

    raw = (root / "data" / "cards.edn").read_text()
    parsed = convert(edn_format.loads(raw))
    cards = []
    by_title = {}
    by_code = {}
    for card in parsed:
        if not isinstance(card, dict) or "code" not in card:
            continue
        s = slim(card)
        s["code"] = str(s["code"])
        cards.append(s)
        by_code[s["code"]] = s
        title = s.get("title")
        if title:
            by_title[title] = s
    cards.sort(key=lambda c: c["code"])
    (dest / "cards.json").write_text(json.dumps(cards, ensure_ascii=False, indent=2) + "\n")

    src = (root / "src/cljc/jinteki/preconstructed.cljc").read_text()
    gateway = parse_gateway_maps(src)
    defs = parse_precons_in_matchups(src)
    missing_all = []
    matchups = []
    for key, def_name in parse_matchup_keys(src):
        info = defs.get(def_name, {"precons": [], "refs": []})
        decks = list(info["precons"])
        if len(decks) < 2:
            for ref in info.get("refs", []):
                if ref in gateway:
                    decks.append(gateway[ref])
        if len(decks) < 2:
            missing_all.append(f"matchup {key} incomplete")
            continue
        corp = next((d for d in decks if d["side"] == "corp"), decks[0])
        runner = next((d for d in decks if d["side"] == "runner"), decks[1])
        corp_cards, miss_c = resolve_cards(corp["cards"], by_title)
        runner_cards, miss_r = resolve_cards(runner["cards"], by_title)
        missing_all.extend(miss_c + miss_r)
        agenda = 6 if key == "beginner" else 7
        matchups.append(
            {
                "key": key,
                "label": tr_label(src, def_name),
                "agenda_goal": agenda,
                "corp": {
                    "name": corp["name"],
                    "identity": corp["identity"],
                    "identity_title": corp["identity_title"],
                    "faction": by_code.get(corp["identity"], {}).get("faction", ""),
                    "cards": corp_cards,
                    "card_count": sum(corp_cards.values()),
                },
                "runner": {
                    "name": runner["name"],
                    "identity": runner["identity"],
                    "identity_title": runner["identity_title"],
                    "faction": by_code.get(runner["identity"], {}).get("faction", ""),
                    "cards": runner_cards,
                    "card_count": sum(runner_cards.values()),
                },
            }
        )
    (dest / "matchups.json").write_text(json.dumps(matchups, ensure_ascii=False, indent=2) + "\n")
    print(f"cards={len(cards)} matchups={len(matchups)} missing={len(missing_all)}")
    for item in missing_all[:20]:
        print(" missing", item)
    return 0 if matchups and len(cards) > 2000 else 1


if __name__ == "__main__":
    raise SystemExit(main())
