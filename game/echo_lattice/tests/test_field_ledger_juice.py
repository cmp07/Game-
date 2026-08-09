#!/usr/bin/env python3
"""Field Ledger juice / audio / chamber HUD alignment (no Godot required)."""

from __future__ import annotations

import json
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]


class TestRewriteStingerAliases(unittest.TestCase):
    def setUp(self) -> None:
        self.events_gd = (ROOT / "scripts" / "audio" / "audio_events.gd").read_text()
        self.catalog = json.loads(
            (ROOT / "audio" / "events" / "audio_events.json").read_text()
        )

    def test_alias_map_covers_content_transforms(self) -> None:
        for needle in (
            '"mirror_v": "mirror"',
            '"mirror_h": "mirror"',
            '"mirror_v_then_h": "mirror"',
            '"rotate_180": "rotate"',
        ):
            self.assertIn(needle, self.events_gd)

    def test_catalog_documents_aliases(self) -> None:
        aliases = self.catalog.get("operator_aliases", {})
        self.assertEqual(aliases.get("mirror_v"), "mirror")
        self.assertEqual(aliases.get("rotate_180"), "rotate")

    def test_catalog_has_target_stingers(self) -> None:
        events = self.catalog["events"]
        for op in ("mirror", "rotate", "thicken", "invert"):
            self.assertIn(f"sfx.rewrite.{op}", events)


class TestCadmiumReserve(unittest.TestCase):
    def test_blocked_step_not_cadmium(self) -> None:
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        # Wall bump juice must not spend cadmium_warn.
        self.assertIn("Juice.flash(0.05, 0.08, Palette.INK_SOFT)", chamber)
        self.assertNotIn("Juice.flash(0.06, 0.12, Palette.CADMIUM_WARN)", chamber)

    def test_telegraph_escalates_to_warn(self) -> None:
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        self.assertIn("near_warn", chamber)
        self.assertIn("FossilRole.CHECKPOINT", chamber)
        self.assertIn("FossilRole.WARN", chamber)
        # Continuous sin pulse on telegraph removed.
        self.assertNotIn("goal_pulse_t * 6.0", chamber)


class TestChamberDiegeticHud(unittest.TestCase):
    def test_scene_has_seed_and_punchcard(self) -> None:
        tscn = (ROOT / "scenes" / "chamber.tscn").read_text()
        for needle in ("SeedLabel", "SeedHeaderTex", "PunchcardCells", "BufferLabel"):
            self.assertIn(needle, tscn)

    def test_scene_script_wires_hud(self) -> None:
        gd = (ROOT / "scripts" / "chamber_scene.gd").read_text()
        self.assertIn("_refresh_seed_header", gd)
        self.assertIn("_refresh_punchcard", gd)
        self.assertIn("seed_display_string", gd)
        self.assertIn("buffer_fill_count", gd)

    def test_locale_seed_key(self) -> None:
        csv = (ROOT / "locale" / "echo_lattice.csv").read_text()
        self.assertIn("hud.seed,", csv)

    def test_seed_formatter_present(self) -> None:
        gs = (ROOT / "scripts" / "game_state.gd").read_text()
        self.assertIn("func seed_display_string", gs)
        self.assertIn("func format_seed_groups", gs)


class TestShakeDefaults(unittest.TestCase):
    def test_builtin_defaults_match_json(self) -> None:
        store = (ROOT / "scripts" / "a11y" / "settings_store.gd").read_text()
        self.assertIn('"screen_shake_enabled": false', store)
        self.assertIn('"screen_shake_intensity": 0.35', store)


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
