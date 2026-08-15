#!/usr/bin/env python3
"""Contracts: Weaver loop content + scripts are hosted under game/echo_lattice/."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content" / "weaver"
SCRIPTS = ROOT / "scripts" / "weaver"
SCENES = ROOT / "scenes" / "weaver"
PROJECT = ROOT / "project.godot"


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}", file=sys.stderr)
    raise SystemExit(1)


def test_project_branding() -> None:
    text = PROJECT.read_text(encoding="utf-8")
    if 'config/name="The Weaver"' not in text:
        _fail("project.godot must name The Weaver")
    if "Loom=" not in text or "weaver/loom/loom_state.gd" not in text:
        _fail("Loom autoload missing")
    if 'run/main_scene="res://scenes/main.tscn"' not in text:
        _fail("main scene must remain Lattice Main router")


def test_recipes_first_five() -> None:
    data = json.loads((CONTENT / "recipes.json").read_text(encoding="utf-8"))
    kinds = {k["id"] for k in data.get("fragment_kinds", [])}
    if kinds != {"Anchor", "Span"}:
        _fail(f"FIRST_FIVE fragment kinds expected Anchor+Span, got {kinds}")
    recipes = data.get("combine_recipes", [])
    if not recipes:
        _fail("combine_recipes empty")
    brace = [r for r in recipes if r.get("output_thread") == "Brace"]
    if not brace:
        _fail("need Brace thread recipe")
    structure = data.get("structure", {})
    if structure.get("id") != "span_structure":
        _fail("structure must be span_structure")


def test_host_files_exist() -> None:
    required = [
        SCRIPTS / "loom" / "loom_state.gd",
        SCRIPTS / "field.gd",
        SCRIPTS / "fragment.gd",
        SCRIPTS / "structure.gd",
        SCRIPTS / "player.gd",
        SCRIPTS / "ui" / "combine_panel.gd",
        SCRIPTS / "juice" / "weaver_juice.gd",
        SCRIPTS / "juice" / "weaver_palette.gd",
        SCENES / "field.tscn",
        SCENES / "fragment.tscn",
        SCENES / "player.tscn",
        SCENES / "structure.tscn",
        SCENES / "ui" / "combine_panel.tscn",
        CONTENT / "recipes.json",
        CONTENT / "fragments.json",
        CONTENT / "palette.json",
    ]
    for path in required:
        if not path.is_file():
            _fail(f"missing {path.relative_to(ROOT)}")


def test_field_returns_via_signal() -> None:
    field = (SCRIPTS / "field.gd").read_text(encoding="utf-8")
    if "signal menu_requested" not in field:
        _fail("field.gd must emit menu_requested for Lattice Main")
    if "change_scene_to_file" in field:
        _fail("field.gd must not hard-swap main scene away from Lattice router")


def test_main_routes_weaver() -> None:
    main = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
    if "show_weaver_field" not in main:
        _fail("main.gd missing show_weaver_field")
    if "WEAVER_FIELD_SCENE" not in main:
        _fail("main.gd missing WEAVER_FIELD_SCENE")
    if "_on_menu_archive_chambers" not in main:
        _fail("main.gd missing archive chambers callback")
    if "--weaver-selftest" not in main:
        _fail("main.gd missing --weaver-selftest hook")
    if "--weaver-photos" not in main:
        _fail("main.gd missing --weaver-photos hook")
    if "_run_weaver_photos" not in main:
        _fail("main.gd missing _run_weaver_photos")
    field = (SCRIPTS / "field.gd").read_text(encoding="utf-8")
    if "func run_photo_beats(" not in field:
        _fail("field.gd missing run_photo_beats")


def test_locale_brand() -> None:
    csv = (ROOT / "locale" / "echo_lattice.csv").read_text(encoding="utf-8")
    if "brand.title,THE WEAVER," not in csv:
        _fail("locale brand.title must be THE WEAVER")
    if "menu.start_new,Enter the Yard," not in csv:
        _fail("locale start CTA must be Enter the Yard")
    if "menu.archive_chambers," not in csv:
        _fail("locale missing archive chambers label")
    if "FIELD INDEX" in csv:
        _fail("player-facing FIELD INDEX still in locale")
    if "menu.folio_mark,YARD FOLIO" not in csv:
        _fail("folio mark must be YARD FOLIO")
    if "pause.title,PAUSE · YARD INDEX," not in csv:
        _fail("pause title must not say FIELD INDEX")


def test_visual_lock_no_maze_film_or_discs() -> None:
    menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
    if "draw_yard_field_plate" not in menu:
        _fail("menu must draw Yard field plate")
    if "draw_ledger_film_plate" in menu:
        _fail("menu still draws Lattice film plate")
    if "_demote_archive_actions" not in menu:
        _fail("archive CTAs must be demoted")
    frag = (SCRIPTS / "fragment.gd").read_text(encoding="utf-8")
    if "draw_circle" in frag:
        _fail("fragments must not default to discs")
    if "T-post" not in frag and "plank" not in frag.lower() and "Anchor" not in frag:
        _fail("fragments need family silhouettes")
    field = (SCRIPTS / "field.gd").read_text(encoding="utf-8")
    if "nest  " not in field:
        _fail("field HUD must be diegetic nest stamps")
    if "Fragments:" in field:
        _fail("field HUD still says Fragments:")
    struct = (SCRIPTS / "structure.gd").read_text(encoding="utf-8")
    if "Crease" not in struct and "rest_y" not in struct:
        _fail("structure seat must crease/lift/seat")
    proj = PROJECT.read_text(encoding="utf-8")
    if 'config/name="The Weaver"' not in proj:
        _fail("window/product name must be The Weaver")
    main = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
    if 'window_set_title("The Weaver")' not in main:
        _fail("main must set window title The Weaver")
    gap = (SCRIPTS / "gap_art.gd").read_text(encoding="utf-8")
    if "shed_air" not in gap and "0.165" not in gap:
        _fail("gap art must show shed-air depth")


def test_loom_logic_mirror() -> None:
    """Lightweight gather→combine→weave→emit using recipes.json (mirrors Loom)."""
    data = json.loads((CONTENT / "recipes.json").read_text(encoding="utf-8"))
    inv = ["Anchor", "Span"]
    recipes = data["combine_recipes"]
    matched = None
    for entry in recipes:
        inputs = entry.get("inputs", [])
        if sorted(inputs) == sorted(inv):
            matched = entry
            break
    if matched is None:
        _fail("no recipe for Anchor+Span")
    thread = matched["output_thread"]
    if thread != "Brace":
        _fail(f"expected Brace, got {thread}")
    emit_kinds = data["structure"].get("emit_kinds", [])
    if not emit_kinds:
        _fail("structure emit_kinds empty")
    print("loom-mirror: gather→combine→weave→emit OK")


def main() -> None:
    test_project_branding()
    test_recipes_first_five()
    test_host_files_exist()
    test_field_returns_via_signal()
    test_main_routes_weaver()
    test_locale_brand()
    test_visual_lock_no_maze_film_or_discs()
    test_loom_logic_mirror()
    print("test_weaver_on_lattice: PASS")


if __name__ == "__main__":
    main()
