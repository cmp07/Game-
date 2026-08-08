#!/usr/bin/env python3
"""Validate Echo Lattice chambers against the schema and the semantic rules.

This is the CI-friendly reference validator. Run:

    python3 game/echo_lattice/tests/validate_chambers.py

It fails-closed: any chamber that does not match the JSON Schema OR any
semantic rule from `docs/ECHO_LATTICE/04_CONTENT_BIBLE.md` causes a non-zero
exit code and a clear error report.

Depends only on the Python 3 standard library so it runs on a fresh CI box
without a Godot install.
"""

from __future__ import annotations

import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

REPO_ROOT = Path(__file__).resolve().parents[3]
CHAMBERS_DIR = REPO_ROOT / "game" / "echo_lattice" / "content" / "chambers"
SCHEMA_PATH = REPO_ROOT / "game" / "echo_lattice" / "content" / "schema" / "chamber.schema.json"
GRAMMAR_PATH = REPO_ROOT / "game" / "echo_lattice" / "content" / "grammar" / "variations.json"

CANONICAL_GLYPHS = set(".#SGoO><^v+x~?*Y")
DIRECTIONS = {"N", "S", "E", "W"}
PREDICATES = {"reach", "light_all", "pattern", "count"}
TEACHES = {
    "emit", "rewrite", "turn", "fork", "merge",
    "filter", "delay", "silence", "resonance", "composition",
}
TOOL_NAMES = {"router", "fork", "merge", "filter", "delay", "cancel", "resonate"}
ID_PATTERN = re.compile(r"^[0-9]{2}_[a-z][a-z0-9_]*$")


@dataclass
class Report:
    ok: list[str] = field(default_factory=list)
    fail: list[tuple[str, list[str]]] = field(default_factory=list)

    def add_ok(self, path: str) -> None:
        self.ok.append(path)

    def add_fail(self, path: str, errors: Iterable[str]) -> None:
        self.fail.append((path, list(errors)))

    @property
    def failed(self) -> bool:
        return bool(self.fail)


def _load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


# -----------------------------------------------------------------------------
# Minimal JSON Schema subset checker
# -----------------------------------------------------------------------------
# We deliberately avoid pulling in `jsonschema` so this validator runs in any
# minimal Python environment. The subset below covers every construct actually
# used in `chamber.schema.json`.

def _schema_check(instance: Any, schema: dict, path: str, root: dict) -> list[str]:
    errs: list[str] = []
    if "$ref" in schema:
        target = _resolve_ref(schema["$ref"], root)
        return _schema_check(instance, target, path, root)

    t = schema.get("type")
    if t is not None:
        if not _type_ok(instance, t):
            errs.append(f"{path}: expected type {t}, got {type(instance).__name__}")
            return errs

    if "enum" in schema and instance not in schema["enum"]:
        errs.append(f"{path}: value {instance!r} not in enum {schema['enum']}")

    if "pattern" in schema and isinstance(instance, str):
        if not re.search(schema["pattern"], instance):
            errs.append(f"{path}: {instance!r} does not match pattern {schema['pattern']}")

    if "minimum" in schema and isinstance(instance, (int, float)):
        if instance < schema["minimum"]:
            errs.append(f"{path}: {instance} < minimum {schema['minimum']}")
    if "maximum" in schema and isinstance(instance, (int, float)):
        if instance > schema["maximum"]:
            errs.append(f"{path}: {instance} > maximum {schema['maximum']}")

    if "minLength" in schema and isinstance(instance, str):
        if len(instance) < schema["minLength"]:
            errs.append(f"{path}: length {len(instance)} < minLength {schema['minLength']}")
    if "maxLength" in schema and isinstance(instance, str):
        if len(instance) > schema["maxLength"]:
            errs.append(f"{path}: length {len(instance)} > maxLength {schema['maxLength']}")

    if "minItems" in schema and isinstance(instance, list):
        if len(instance) < schema["minItems"]:
            errs.append(f"{path}: items {len(instance)} < minItems {schema['minItems']}")
    if "maxItems" in schema and isinstance(instance, list):
        if len(instance) > schema["maxItems"]:
            errs.append(f"{path}: items {len(instance)} > maxItems {schema['maxItems']}")
    if schema.get("uniqueItems") and isinstance(instance, list):
        seen: list[Any] = []
        for x in instance:
            if x in seen:
                errs.append(f"{path}: duplicate item {x!r}")
                break
            seen.append(x)

    if isinstance(instance, dict):
        for req in schema.get("required", []):
            if req not in instance:
                errs.append(f"{path}: missing required field {req!r}")
        props = schema.get("properties", {})
        additional = schema.get("additionalProperties", True)
        for k, v in instance.items():
            if k in props:
                errs.extend(_schema_check(v, props[k], f"{path}.{k}", root))
            elif additional is False:
                errs.append(f"{path}: unexpected property {k!r}")
            elif isinstance(additional, dict):
                errs.extend(_schema_check(v, additional, f"{path}.{k}", root))

    if isinstance(instance, list) and "items" in schema:
        for i, x in enumerate(instance):
            errs.extend(_schema_check(x, schema["items"], f"{path}[{i}]", root))

    if "oneOf" in schema:
        matches = 0
        subs: list[list[str]] = []
        for i, sub in enumerate(schema["oneOf"]):
            sub_errs = _schema_check(instance, sub, path, root)
            subs.append(sub_errs)
            if not sub_errs:
                matches += 1
        if matches != 1:
            errs.append(f"{path}: expected exactly one oneOf branch to match, got {matches}")
    return errs


def _type_ok(instance: Any, t: Any) -> bool:
    if isinstance(t, list):
        return any(_type_ok(instance, sub) for sub in t)
    mapping = {
        "string": str,
        "integer": int,
        "number": (int, float),
        "boolean": bool,
        "array": list,
        "object": dict,
        "null": type(None),
    }
    if t == "integer":
        return isinstance(instance, int) and not isinstance(instance, bool)
    if t == "boolean":
        return isinstance(instance, bool)
    py = mapping.get(t)
    if py is None:
        return True
    return isinstance(instance, py)


def _resolve_ref(ref: str, root: dict) -> dict:
    assert ref.startswith("#/"), f"only local refs supported, got {ref}"
    node: Any = root
    for part in ref[2:].split("/"):
        node = node[part]
    return node


# -----------------------------------------------------------------------------
# Semantic checks (mirror of what Godot's Chamber.validate() enforces)
# -----------------------------------------------------------------------------


def _semantic_check(chamber: dict, path: Path) -> list[str]:
    errs: list[str] = []

    file_stem = path.stem
    if chamber.get("id") != file_stem:
        errs.append(f"id {chamber.get('id')!r} does not match filename stem {file_stem!r}")

    if chamber.get("teaches") not in TEACHES:
        errs.append(f"teaches must be one of {sorted(TEACHES)}")
    if chamber.get("source_dir") not in DIRECTIONS:
        errs.append(f"source_dir must be one of {sorted(DIRECTIONS)}")

    lattice = chamber.get("lattice", {})
    rows = lattice.get("rows")
    cols = lattice.get("cols")
    cells = lattice.get("cells", [])
    if not (isinstance(rows, int) and 3 <= rows <= 12):
        errs.append("lattice.rows must be an integer in [3, 12]")
    if not (isinstance(cols, int) and 3 <= cols <= 12):
        errs.append("lattice.cols must be an integer in [3, 12]")
    if isinstance(rows, int) and len(cells) != rows:
        errs.append(f"lattice.cells has {len(cells)} rows, expected {rows}")
    for i, row in enumerate(cells):
        if not isinstance(row, str):
            errs.append(f"lattice.cells[{i}] not a string")
            continue
        if isinstance(cols, int) and len(row) != cols:
            errs.append(f"lattice.cells[{i}] length {len(row)}, expected {cols}")

    legend = chamber.get("legend", {})
    source_count = 0
    goal_count = 0
    for row in cells:
        if not isinstance(row, str):
            continue
        for ch in row:
            if ch not in CANONICAL_GLYPHS and ch not in legend:
                errs.append(f"glyph {ch!r} not in legend or canonical set")
            if ch == "S":
                source_count += 1
            if ch == "G":
                goal_count += 1
    if source_count < 1:
        errs.append("chamber must contain at least one source (S)")

    goal = chamber.get("goal", {})
    predicate = goal.get("predicate")
    if predicate not in PREDICATES:
        errs.append(f"goal.predicate must be one of {sorted(PREDICATES)}")
    if predicate in {"reach", "light_all"} and goal_count < 1:
        errs.append(f"goal.predicate={predicate} requires at least one G on the grid")
    if predicate == "reach" and not goal.get("cells"):
        errs.append("goal.predicate=reach requires goal.cells")
    if predicate == "pattern" and not goal.get("pattern"):
        errs.append("goal.predicate=pattern requires goal.pattern")
    if predicate == "count" and not isinstance(goal.get("count"), int):
        errs.append("goal.predicate=count requires integer goal.count")
    if isinstance(goal.get("cells"), list) and isinstance(rows, int) and isinstance(cols, int):
        for gc in goal["cells"]:
            if not (isinstance(gc, list) and len(gc) == 2):
                errs.append(f"goal.cells entry {gc!r} not a [row,col] pair")
                continue
            r, c = gc
            if not (isinstance(r, int) and isinstance(c, int)):
                errs.append(f"goal.cells entry {gc!r} not integer coords")
                continue
            if not (0 <= r < rows and 0 <= c < cols):
                errs.append(f"goal.cells entry {gc!r} out of bounds for {rows}x{cols}")

    tools = chamber.get("player_tools", {})
    for name in tools:
        if name not in TOOL_NAMES:
            errs.append(f"player_tools.{name} not in canonical tool names {sorted(TOOL_NAMES)}")

    variations = chamber.get("variations", {})
    tick_budget = chamber.get("tick_budget", 0)
    for delta in variations.get("budget_deltas", []):
        if isinstance(tick_budget, int) and tick_budget + int(delta) < 1:
            errs.append(f"variations.budget_delta={delta} would push tick_budget below 1")

    tutorial = chamber.get("difficulty", -1) == 0
    if tutorial and variations.get("allow_rotate", False):
        errs.append("tutorial chambers must not allow_rotate (see §5.3 of the Content Bible)")

    return errs


# -----------------------------------------------------------------------------
# Grammar-file checks
# -----------------------------------------------------------------------------


def _grammar_check(grammar: dict) -> list[str]:
    errs: list[str] = []
    g = grammar.get("grammar", {})
    prods = g.get("productions", {})
    required = {"variant", "transforms", "transform", "rotate", "reflect", "palette", "budget_delta"}
    missing = required - set(prods)
    if missing:
        errs.append(f"variations.json missing productions: {sorted(missing)}")
    for palette_name in ("default", "cool", "warm", "mono"):
        if palette_name not in grammar.get("palettes", {}):
            errs.append(f"variations.json palettes.{palette_name} missing")
    for i, v in enumerate(grammar.get("example_variants", [])):
        if "chamber" not in v or "sequence" not in v:
            errs.append(f"example_variants[{i}] missing chamber/sequence")
    return errs


# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------


def validate_all() -> Report:
    schema = _load_json(SCHEMA_PATH)
    report = Report()

    chamber_files = sorted(CHAMBERS_DIR.glob("*.json"))
    if not chamber_files:
        report.add_fail(str(CHAMBERS_DIR), ["no chamber JSON files found"])
        return report

    for path in chamber_files:
        errs: list[str] = []
        try:
            data = _load_json(path)
        except json.JSONDecodeError as e:
            report.add_fail(str(path), [f"JSON parse error: {e}"])
            continue
        errs.extend(_schema_check(data, schema, path.name, schema))
        errs.extend(_semantic_check(data, path))
        if errs:
            report.add_fail(str(path.relative_to(REPO_ROOT)), errs)
        else:
            report.add_ok(str(path.relative_to(REPO_ROOT)))

    try:
        grammar = _load_json(GRAMMAR_PATH)
    except FileNotFoundError:
        report.add_fail(str(GRAMMAR_PATH), ["grammar file missing"])
    except json.JSONDecodeError as e:
        report.add_fail(str(GRAMMAR_PATH), [f"JSON parse error: {e}"])
    else:
        errs = _grammar_check(grammar)
        if errs:
            report.add_fail(str(GRAMMAR_PATH.relative_to(REPO_ROOT)), errs)
        else:
            report.add_ok(str(GRAMMAR_PATH.relative_to(REPO_ROOT)))

    return report


def main() -> int:
    report = validate_all()
    for p in report.ok:
        print(f"OK    {p}")
    for p, errs in report.fail:
        print(f"FAIL  {p}")
        for e in errs:
            print(f"        - {e}")
    total = len(report.ok) + len(report.fail)
    print(f"\n{len(report.ok)}/{total} passed")
    return 1 if report.failed else 0


if __name__ == "__main__":
    sys.exit(main())
