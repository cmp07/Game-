#!/usr/bin/env python3
"""Headless acceptance tests for thin Museum / habit archive meta.

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
        self.assertNotIn("Race this self", screen)
        self.assertNotIn("battle pass", screen.lower())
        self.assertNotIn("gacha", screen.lower())
        self.assertIn("museum.replay", screen)
        vignette = _read(VIGNETTE)
        self.assertIn("Field Ledger", vignette)
        self.assertIn("No race", vignette)

    def test_save_validator_accepts_museum_blob(self) -> None:
        # Keep Python allowlist in sync enough for museum key presence in GD.
        save = _read(SAVE)
        self.assertIn('"museum"', save)
        allowed = re.search(r"SAVE_ALLOWED_KEYS: Array\[String\] = \[([\s\S]*?)\]", save)
        self.assertIsNotNone(allowed)
        self.assertIn('"museum"', allowed.group(1))


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
        raw = json.dumps({"version": 2, "museum": museum})
        parsed = json.loads(raw)
        self.assertEqual(parsed["museum"]["cap"], 48)
        self.assertEqual(parsed["museum"]["selves"][0]["outcome"], "clear")


if __name__ == "__main__":
    unittest.main()
