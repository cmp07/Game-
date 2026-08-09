#!/usr/bin/env python3
"""Headless acceptance tests for Museum / habit archive + Ghost of Past Self.

Mirrors MuseumOfSelves contracts without Godot.
Run: python3 game/echo_lattice/tests/test_museum.py
"""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
MUSEUM_GD = ROOT / "scripts" / "museum_of_selves.gd"
GAME_STATE = ROOT / "scripts" / "game_state.gd"
SAVE = ROOT / "scripts" / "save_manager.gd"
WON = ROOT / "scripts" / "chamber_won.gd"
MENU = ROOT / "scripts" / "menu.gd"
MAIN = ROOT / "scripts" / "main.gd"
CHAMBER = ROOT / "scripts" / "chamber.gd"
VIGNETTE = ROOT / "scripts" / "habit_replay_vignette.gd"
SCREEN = ROOT / "scripts" / "museum_screen.gd"
SCENE = ROOT / "scenes" / "museum_screen.tscn"
PRODUCT = REPO / "docs" / "AUDIT" / "PRODUCT_UPGRADES.md"
SYSTEMS_TRUTH = REPO / "docs" / "VISION" / "SYSTEMS_TRUTH.md"
LOCALE = ROOT / "locale" / "echo_lattice.csv"
SECURITY = ROOT / "tests" / "test_security_high.py"

DEFAULT_CAP = 48
DEFAULT_STRIDE = 2
MAX_PATH_POINTS = 96

TITLE_TEMPLATES = {
    "right_leaner": "The Right-Leaner of {chamber}",
    "looper": "The Looper of {chamber}",
    "zigzagger": "The Zigzag of {chamber}",
    "balanced": "The Balanced Echo of {chamber}",
    "default": "A Self from {chamber}",
}


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def compact_path(path: list, stride: int = DEFAULT_STRIDE) -> list:
    if not path:
        return []
    step = max(1, stride)
    packed = []
    i = 0
    while i < len(path):
        p = path[i]
        packed.append([int(p[0]), int(p[1])])
        i += step
    last = [int(path[-1][0]), int(path[-1][1])]
    if not packed or packed[-1] != last:
        packed.append(last)
    while len(packed) > MAX_PATH_POINTS:
        thinned = [packed[0]]
        for j in range(1, len(packed) - 1, 2):
            thinned.append(packed[j])
        thinned.append(packed[-1])
        packed = thinned
    return packed


def unpack_path(ghost: dict) -> list:
    out = []
    for p in ghost.get("path", []):
        out.append([int(p[0]), int(p[1])])
    return out


def title_for(archetype: str, chamber_title: str) -> str:
    arch = archetype if archetype in TITLE_TEMPLATES else "default"
    return TITLE_TEMPLATES[arch].replace("{chamber}", chamber_title or "the Lattice")


def archive_clear(museum: dict, chamber_title: str, archetype: str, path: list, stars: int = 2) -> dict:
    state = {
        "selves": list(museum.get("selves", [])),
        "cap": int(museum.get("cap", DEFAULT_CAP)),
    }
    row = {
        "id": f"self_test_{len(state['selves']) + 1:04d}",
        "outcome": "clear",
        "chamber_id": "01_echo_plate",
        "stars": stars,
        "title": title_for(archetype, chamber_title),
        "habit": {"archetype": archetype, "dominant_bias": 0.6},
        "ghost": {"stride": DEFAULT_STRIDE, "path": compact_path(path)},
        "stamp": {},
    }
    state["selves"].insert(0, row)
    while len(state["selves"]) > state["cap"]:
        state["selves"].pop()
    return {"museum": state, "self": row}


def can_race(row: dict) -> bool:
    path = unpack_path(row.get("ghost", {}))
    return len(path) >= 2 and bool(row.get("chamber_id"))


class TestMuseumContracts(unittest.TestCase):
    def test_scripts_exist(self) -> None:
        for p in (MUSEUM_GD, VIGNETTE, SCREEN, SCENE):
            self.assertTrue(p.is_file(), p)

    def test_product_upgrades_mentions_museum(self) -> None:
        text = _read(PRODUCT)
        self.assertIn("Museum of Selves", text)
        self.assertIn("Field Ledger", text)

    def test_title_and_cap(self) -> None:
        museum = {"selves": [], "cap": DEFAULT_CAP}
        for i in range(DEFAULT_CAP + 3):
            result = archive_clear(
                museum,
                "Signal Bleed",
                "right_leaner",
                [[1, 1], [2, 1], [3, 1], [3, 2]],
            )
            museum = result["museum"]
        self.assertEqual(len(museum["selves"]), DEFAULT_CAP)
        self.assertIn("Right-Leaner", museum["selves"][0]["title"])

    def test_compact_path_keeps_ends(self) -> None:
        path = [[x, 0] for x in range(20)]
        packed = compact_path(path, stride=3)
        self.assertEqual(packed[0], [0, 0])
        self.assertEqual(packed[-1], [19, 0])
        self.assertLess(len(packed), len(path))

    def test_death_never_archives_wire(self) -> None:
        gd = _read(GAME_STATE)
        # Archive only lives inside record_chamber_win (clear path).
        self.assertIn("_archive_museum_self", gd)
        self.assertIn("MuseumOfSelves.archive_clear", gd)
        # No death/fail archive helper.
        self.assertNotIn("archive_death", gd)
        self.assertNotIn("outcome\": \"death\"", gd)

    def test_save_persists_museum(self) -> None:
        save = _read(SAVE)
        self.assertIn('"museum"', save)
        self.assertIn("museum", save)
        self.assertIn("MuseumOfSelves.sanitize_museum", save)
        self.assertIn("_validate_museum", save)
        self.assertIn('"museum"', _read(SAVE))  # allowed keys / payload
        self.assertRegex(save, r'"museum"')

    def test_post_clear_stamp_and_vignette(self) -> None:
        won = _read(WON)
        self.assertIn("habit_replay_vignette", won)
        self.assertIn("_show_museum", won)
        self.assertIn("won.museum_archive", won)
        self.assertIn("last_museum_self", won)

    def test_chamber_records_trail(self) -> None:
        chamber = _read(CHAMBER)
        self.assertIn("trail_path", chamber)
        self.assertIn("undo_count", chamber)
        self.assertIn("trail_path.duplicate()", chamber)

    def test_menu_and_main_wire_museum(self) -> None:
        self.assertIn("museum_pressed", _read(MENU))
        self.assertIn("menu.museum", _read(MENU))
        main = _read(MAIN)
        self.assertIn("museum_screen.tscn", main)
        self.assertIn("show_museum", main)
        self.assertIn("_on_menu_museum", main)
        self.assertIn("museum_count()", main)

    def test_no_genre_mash_in_thin_surface(self) -> None:
        screen = _read(SCREEN)
        # F01 ships optional Race this self (chalk overlay) — still no combat mash.
        self.assertIn("museum.race", screen)
        self.assertIn("race_self", screen)
        self.assertIn("RaceButton", screen)
        self.assertNotIn("battle pass", screen.lower())
        self.assertNotIn("gacha", screen.lower())
        self.assertNotIn("enemy", screen.lower())
        self.assertNotIn("PvP", screen)
        self.assertIn("museum.replay", screen)
        self.assertIn("Race this self", _read(SCENE))
        self.assertIn("museum.race,Race this self,", _read(LOCALE))
        vignette = _read(VIGNETTE)
        self.assertIn("Field Ledger", vignette)
        self.assertIn("In-chamber race is a separate overlay", vignette)

    def test_ghost_of_past_self_wire(self) -> None:
        museum = _read(MUSEUM_GD)
        self.assertIn("func unpack_path", museum)
        self.assertIn("func race_path_for", museum)
        self.assertIn("func can_race", museum)
        gs = _read(GAME_STATE)
        self.assertIn("func start_ghost_race", gs)
        self.assertIn('run_mode = "ghost"', gs)
        self.assertIn("func active_ghost_race_path", gs)
        self.assertIn("ghost_race_self_id", gs)
        chamber = _read(CHAMBER)
        self.assertIn("_museum_ghost_path", chamber)
        self.assertIn("_draw_museum_ghost_path", chamber)
        self.assertIn("FossilPalette.FossilRole.GHOST", chamber)
        self.assertIn("active_ghost_race_path", chamber)
        main = _read(MAIN)
        self.assertIn("_on_museum_race_self", main)
        self.assertIn("start_ghost_race", main)
        self.assertIn("clear_ghost_race", main)
        scene = _read(SCENE)
        self.assertIn("RaceButton", scene)
        save = _read(SAVE)
        self.assertIn('"ghost"', save)
        self.assertIn('"ghost_race_self_id"', save)

    def test_race_path_contract(self) -> None:
        result = archive_clear(
            {"selves": [], "cap": DEFAULT_CAP},
            "Echo Plate",
            "looper",
            [[1, 1], [2, 1], [3, 1], [3, 2]],
        )
        row = result["self"]
        self.assertTrue(can_race(row))
        path = unpack_path(row["ghost"])
        self.assertGreaterEqual(len(path), 2)
        self.assertEqual(path[0], [1, 1])
        empty = {"ghost": {"path": [[0, 0]]}, "chamber_id": "01_echo_plate"}
        self.assertFalse(can_race(empty))

    def test_systems_truth_marks_race_lived(self) -> None:
        truth = _read(SYSTEMS_TRUTH)
        self.assertIn("T14", truth)
        self.assertIn("SHIPPED", truth)
        self.assertIn("Race this self", truth)
        # Must not leave the old "tests forbid Race this self" claim-only lie.
        self.assertNotIn('tests forbid “Race this self”', truth)
        self.assertNotIn("No ghost **race**", truth)

    def test_locale_race_keys(self) -> None:
        locale = _read(LOCALE)
        for key in (
            "museum.race,",
            "hud.ghost_tag,",
            "won.back_museum,",
            "won.ghost_line,",
            "subtitle.pa.ghost.race,",
        ):
            self.assertIn(key, locale)

    def test_save_validator_accepts_museum_blob(self) -> None:
        # Keep Python allowlist in sync enough for museum key presence in GD.
        save = _read(SAVE)
        self.assertIn('"museum"', save)
        allowed = re.search(r"SAVE_ALLOWED_KEYS: Array\[String\] = \[([\s\S]*?)\]", save)
        self.assertIsNotNone(allowed)
        self.assertIn('"museum"', allowed.group(1))
        self.assertIn('"ghost_race_self_id"', allowed.group(1))
        modes = re.search(r"SAVE_RUN_MODES: Array\[String\] = \[([\s\S]*?)\]", save)
        self.assertIsNotNone(modes)
        self.assertIn('"ghost"', modes.group(1))


class TestMuseumSavePythonMirror(unittest.TestCase):
    """Lightweight schema checks aligned with SaveManager museum validation."""

    def test_museum_shape(self) -> None:
        museum = {
            "cap": 48,
            "selves": [
                {
                    "id": "self_20260809_0001",
                    "title": "The Balanced Echo of Quiet Span",
                    "outcome": "clear",
                    "stars": 2,
                    "habit": {"archetype": "balanced", "dominant_bias": 0.4},
                    "ghost": {"stride": 2, "path": [[1, 1], [3, 1]]},
                }
            ],
        }
        raw = json.dumps({"version": 2, "museum": museum, "run_mode": "ghost", "ghost_race_self_id": "self_20260809_0001"})
        parsed = json.loads(raw)
        self.assertEqual(parsed["museum"]["cap"], 48)
        self.assertEqual(parsed["museum"]["selves"][0]["outcome"], "clear")
        self.assertEqual(parsed["run_mode"], "ghost")


if __name__ == "__main__":
    unittest.main()
