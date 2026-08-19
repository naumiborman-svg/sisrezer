#!/usr/bin/env python3
"""Generate Godot 4.3 global_script_class_cache.cfg so headless runs resolve class_name."""
from __future__ import annotations

import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    entries = []
    for path in ROOT.rglob("*.gd"):
        rel = path.relative_to(ROOT).as_posix()
        if rel.startswith(".godot/") or "/translated/" in ("/" + rel):
            continue
        text = path.read_text()
        cm = re.search(r"^class_name\s+(\w+)", text, re.M)
        if not cm:
            continue
        cls = cm.group(1)
        em = re.search(r"^extends\s+(\w+)", text, re.M)
        base = em.group(1) if em else "RefCounted"
        entries.append((cls, base, "res://" + rel))
    entries.sort()
    parts = []
    for cls, base, rel in entries:
        parts.append(
            "{\n"
            f"\"base\": &\"{base}\",\n"
            f"\"class\": &\"{cls}\",\n"
            "\"icon\": \"\",\n"
            "\"is_abstract\": false,\n"
            "\"is_tool\": false,\n"
            "\"language\": &\"GDScript\",\n"
            f"\"path\": \"{rel}\"\n"
            "}"
        )
    out_dir = ROOT / ".godot"
    out_dir.mkdir(exist_ok=True)
    (out_dir / "global_script_class_cache.cfg").write_text(
        "list=Array[Dictionary]([" + ", ".join(parts) + "])\n"
    )
    print("wrote", len(entries), "classes")


if __name__ == "__main__":
    main()
