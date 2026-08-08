#!/usr/bin/env python3
"""Emit Godot 4 .tres mirrors of every chamber JSON.

JSON stays the authoring source of truth. The `.tres` files are a mechanical
mirror so Godot's editor can load chambers as first-class `Chamber` resources
(with proper inspector integration) once a `project.godot` exists next to
`game/`.

Run:

    python3 game/echo_lattice/tests/generate_tres.py

The script is idempotent and only writes files when the encoded output would
change, so it's safe to re-run in CI to check for drift.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[3]
CHAMBERS_DIR = REPO_ROOT / "game" / "echo_lattice" / "content" / "chambers"
TRES_DIR = REPO_ROOT / "game" / "echo_lattice" / "content" / "tres"
CHAMBER_SCRIPT = "res://game/echo_lattice/scripts/chamber.gd"


def _tres_encode(value: Any) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        parts = [_tres_encode(v) for v in value]
        return "[" + ", ".join(parts) + "]"
    if isinstance(value, dict):
        parts = []
        for k, v in value.items():
            parts.append(f"{json.dumps(k, ensure_ascii=False)}: {_tres_encode(v)}")
        return "{" + ", ".join(parts) + "}"
    raise TypeError(f"cannot encode value of type {type(value).__name__}")


def _packed_string(values: list[str]) -> str:
    parts = [json.dumps(v, ensure_ascii=False) for v in values]
    return "PackedStringArray(" + ", ".join(parts) + ")"


def _tres_for(chamber: dict) -> str:
    lattice = chamber.get("lattice", {})
    rows = int(lattice.get("rows", 0))
    cols = int(lattice.get("cols", 0))
    cells = list(lattice.get("cells", []))

    ordered_fields: list[tuple[str, str]] = [
        ("id",           _tres_encode(chamber.get("id", ""))),
        ("title",        _tres_encode(chamber.get("title", ""))),
        ("subtitle",     _tres_encode(chamber.get("subtitle", ""))),
        ("teaches",      _tres_encode(chamber.get("teaches", ""))),
        ("difficulty",   _tres_encode(int(chamber.get("difficulty", 0)))),
        ("tick_budget",  _tres_encode(int(chamber.get("tick_budget", 1)))),
        ("par_ticks",    _tres_encode(chamber.get("par_ticks"))),
        ("par_tiles",    _tres_encode(chamber.get("par_tiles"))),
        ("source_dir",   _tres_encode(chamber.get("source_dir", "S"))),
        ("rows",         _tres_encode(rows)),
        ("cols",         _tres_encode(cols)),
        ("cells",        _packed_string(cells)),
        ("legend",       _tres_encode(chamber.get("legend", {}))),
        ("goal",         _tres_encode(chamber.get("goal", {}))),
        ("player_tools", _tres_encode(chamber.get("player_tools", {}))),
        ("hints",        _packed_string(list(chamber.get("hints", [])))),
        ("intro",        _tres_encode(chamber.get("intro", ""))),
        ("outro",        _tres_encode(chamber.get("outro", ""))),
        ("music_cue",    _tres_encode(chamber.get("music_cue"))),
        ("tags",         _packed_string(list(chamber.get("tags", [])))),
        ("variations",   _tres_encode(chamber.get("variations", {}))),
    ]

    body = "\n".join(f"{k} = {v}" for k, v in ordered_fields)

    return (
        '[gd_resource type="Resource" script_class="Chamber" load_steps=2 format=3]\n'
        "\n"
        f'[ext_resource type="Script" path="{CHAMBER_SCRIPT}" id="1_chamber"]\n'
        "\n"
        "[resource]\n"
        'script = ExtResource("1_chamber")\n'
        f"{body}\n"
    )


def main() -> int:
    TRES_DIR.mkdir(parents=True, exist_ok=True)
    changed = 0
    total = 0
    for path in sorted(CHAMBERS_DIR.glob("*.json")):
        total += 1
        with path.open("r", encoding="utf-8") as f:
            chamber = json.load(f)
        out_path = TRES_DIR / (path.stem + ".tres")
        encoded = _tres_for(chamber)
        existing = out_path.read_text(encoding="utf-8") if out_path.exists() else ""
        if existing != encoded:
            out_path.write_text(encoded, encoding="utf-8")
            changed += 1
            print(f"wrote {out_path.relative_to(REPO_ROOT)}")
        else:
            print(f"unchanged {out_path.relative_to(REPO_ROOT)}")
    print(f"\n{changed}/{total} .tres files rewritten")
    return 0


if __name__ == "__main__":
    sys.exit(main())
