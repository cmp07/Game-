#!/usr/bin/env python3
"""Headless contract tests for thin Endless mode (catalog + rewrite pressure).

Mirrors ChamberBook.endless_* helpers without Godot.
Run: python3 game/echo_lattice/tests/test_endless_mode.py
"""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = Path(__file__).resolve().parents[3]
SCRIPTS = ROOT / "scripts"
SEEDS = ROOT / "content" / "daily" / "seeds.json"
ACTS = ROOT / "content" / "acts.json"
BALANCE = ROOT / "config" / "balance_v2.json"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def rewrite_pressure(depth: int) -> float:
    return max(0.18, min(0.95, 0.18 + max(0, depth) * 0.055))


def min_act_for_pressure(pressure: float) -> int:
    if pressure >= 0.72:
        return 3
    if pressure >= 0.48:
        return 2
    return 1


class EndlessModeContractTests(unittest.TestCase):
    def test_gamestate_exposes_endless_entrypoints(self) -> None:
        gs = _read(SCRIPTS / "game_state.gd")
        self.assertIn('run_mode: String = "standard"', gs)
        self.assertIn("func start_endless_run", gs)
        self.assertIn("func rewrite_pressure", gs)
        self.assertIn("func endless_transform_for", gs)
        self.assertIn('run_mode == "endless"', gs)
        self.assertIn("endless_seed", gs)
        self.assertIn("endless_depth", gs)
        self.assertIn("endless_best_depth", gs)

    def test_chamber_book_catalog_batch_helpers(self) -> None:
        book = _read(SCRIPTS / "chamber_book.gd")
        self.assertIn("func endless_chamber_batch", book)
        self.assertIn("func campaign_index_for_content_id", book)
        self.assertIn("static func endless_rewrite_pressure", book)
        self.assertIn("static func endless_pressure_transform", book)
        self.assertIn("DailySeeds.load_catalog", book)

    def test_menu_and_main_wire_endless(self) -> None:
        menu = _read(SCRIPTS / "menu.gd")
        main = _read(SCRIPTS / "main.gd")
        tscn = _read(ROOT / "scenes" / "menu.tscn")
        self.assertIn("signal endless_pressed", menu)
        self.assertIn("EndlessButton", tscn)
        self.assertIn("_on_menu_endless", main)
        self.assertIn("start_endless_run", main)

    def test_save_persists_endless_fields(self) -> None:
        save = _read(SCRIPTS / "save_manager.gd")
        for key in (
            "endless_seed",
            "endless_depth",
            "endless_best_depth",
            "endless_label",
        ):
            self.assertIn(f'"{key}"', save)

    def test_chamber_applies_pressure_transform(self) -> None:
        chamber = _read(SCRIPTS / "chamber.gd")
        self.assertIn("endless_transform_for", chamber)
        self.assertIn('run_mode == "endless"', chamber)

    def test_balance_has_endless_mode(self) -> None:
        data = json.loads(BALANCE.read_text(encoding="utf-8"))
        self.assertIn("endless", data["modes"])
        self.assertGreaterEqual(float(data["modes"]["endless"]["soft_hard_bias"]), 0.5)

    def test_pressure_curve_and_act_floor(self) -> None:
        self.assertAlmostEqual(rewrite_pressure(0), 0.18, places=3)
        self.assertGreater(rewrite_pressure(8), rewrite_pressure(0))
        self.assertEqual(min_act_for_pressure(0.2), 1)
        self.assertEqual(min_act_for_pressure(0.5), 2)
        self.assertEqual(min_act_for_pressure(0.8), 3)

    def test_catalog_resolves_into_campaign(self) -> None:
        seeds = json.loads(SEEDS.read_text(encoding="utf-8"))["seeds"]
        campaign = set(json.loads(ACTS.read_text(encoding="utf-8"))["campaign_order"])
        resolved = [s["chamber_id"] for s in seeds if s["chamber_id"] in campaign]
        self.assertGreaterEqual(len(resolved), 10, "endless needs a usable catalog pool")
        # Hard variants may appear in catalog but are skipped by campaign index lookup.
        hard = [s["chamber_id"] for s in seeds if s["chamber_id"] not in campaign]
        self.assertTrue(any(h.endswith("_hard") for h in hard))

    def test_rc1_readme_still_claims_endless(self) -> None:
        readme = _read(REPO / "docs" / "RELEASE" / "RC1_README.md")
        self.assertIn("Endless", readme)

    def test_pressure_transform_contract_in_source(self) -> None:
        book = _read(SCRIPTS / "chamber_book.gd")
        self.assertIsNotNone(
            re.search(r'mirror_v_then_h', book),
            "high pressure should escalate mirrors",
        )


if __name__ == "__main__":
    unittest.main()
