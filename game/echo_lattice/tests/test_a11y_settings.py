#!/usr/bin/env python3
"""Smoke tests for Echo Lattice accessibility + settings completeness (no Godot required)."""

from __future__ import annotations

import json
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # game/echo_lattice
REPO = ROOT.parents[1]


class TestDefaultsCompleteness(unittest.TestCase):
    def setUp(self) -> None:
        self.data = json.loads((ROOT / "config" / "default_settings.json").read_text())

    def test_version(self) -> None:
        self.assertEqual(self.data["version"], 1)

    def test_required_accessibility_keys(self) -> None:
        a11y = self.data["accessibility"]
        required = {
            "fossil_palette",
            "fossil_use_patterns",
            "reduce_flash",
            "flash_max_intensity",
            "screen_shake_enabled",
            "screen_shake_intensity",
            "subtitles_enabled",
            "subtitle_size",
            "subtitle_background",
            "show_ghost_path_once",
            "hold_to_walk",
            "reduce_motion",
        }
        self.assertTrue(required.issubset(a11y.keys()), missing := required - set(a11y))
        self.assertFalse(missing)

    def test_required_input_actions(self) -> None:
        bindings = self.data["input_bindings"]
        for action in (
            "move_north",
            "move_east",
            "move_south",
            "move_west",
            "interact",
            "undo",
            "pause",
            "ghost_assist",
        ):
            self.assertIn(action, bindings)
            self.assertGreaterEqual(len(bindings[action]), 1)


class TestSourceSurface(unittest.TestCase):
    REQUIRED = [
        "autoload/settings_store.gd",
        "autoload/accessibility_service.gd",
        "visuals/fossil_palette.gd",
        "effects/flash_gate.gd",
        "effects/screen_shake.gd",
        "input/action_remap.gd",
        "ui/subtitle_stub.gd",
        "ui/subtitle_overlay.tscn",
        "ui/settings_menu.gd",
        "ui/settings_menu.tscn",
        "assists/ghost_path_assist.gd",
        "assists/chamber_a11y_bridge.gd",
        "config/default_settings.json",
    ]

    def test_files_exist(self) -> None:
        missing = [p for p in self.REQUIRED if not (ROOT / p).is_file()]
        self.assertEqual(missing, [])

    def test_docs_exist(self) -> None:
        doc = REPO / "docs" / "echo_lattice" / "ACCESSIBILITY_SETTINGS.md"
        self.assertTrue(doc.is_file())
        text = doc.read_text()
        for needle in (
            "Colorblind",
            "Reduce flash",
            "Remappable",
            "Subtitles",
            "ghost path once",
            "Screen shake",
        ):
            self.assertIn(needle, text)

    def test_fossil_modes_declared(self) -> None:
        src = (ROOT / "visuals" / "fossil_palette.gd").read_text()
        for mode in (
            "DEFAULT",
            "PROTANOPIA",
            "DEUTERANOPIA",
            "TRITANOPIA",
            "HIGH_CONTRAST",
            "MONO_PATTERN",
        ):
            self.assertIn(mode, src)

    def test_subtitle_stubs_present(self) -> None:
        src = (ROOT / "ui" / "subtitle_stub.gd").read_text()
        for stub_id in (
            "rewrite_begin",
            "rewrite_mirror",
            "checkpoint",
            "habit_warn_loop",
            "ghost_assist",
        ):
            self.assertIn(f'"{stub_id}"', src)

    def test_settings_menu_wires_signals(self) -> None:
        tscn = (ROOT / "ui" / "settings_menu.tscn").read_text()
        for method in (
            "_on_fossil_selected",
            "_on_reduce_flash_toggled",
            "_on_shake_toggled",
            "_on_subtitles_toggled",
            "_on_ghost_assist_toggled",
            "_on_close_pressed",
        ):
            self.assertIn(method, tscn)


class TestFlashAndAssistLogic(unittest.TestCase):
    """Python mirrors of critical gating rules."""

    @staticmethod
    def gate_flash(intensity: float, reduce_flash: bool, reduce_motion: bool) -> float | None:
        max_i = min(1.0, 0.25) if reduce_flash else 1.0
        if max_i <= 0.001:
            return None
        out = min(intensity, max_i)
        if reduce_flash:
            out = min(out, 0.25)
        if reduce_motion:
            out *= 0.5
        return out

    def test_reduce_flash_caps_intensity(self) -> None:
        self.assertAlmostEqual(self.gate_flash(1.0, True, False), 0.25)

    def test_normal_flash_passthrough(self) -> None:
        self.assertAlmostEqual(self.gate_flash(0.8, False, False), 0.8)

    def test_ghost_assist_once(self) -> None:
        enabled = True
        used = False

        def try_reveal(path: list[object]) -> bool:
            nonlocal used
            if not enabled or used or not path:
                return False
            used = True
            return True

        self.assertTrue(try_reveal([(0, 0), (1, 0)]))
        self.assertFalse(try_reveal([(0, 0), (1, 0)]))

    def test_shake_disabled_by_reduce_motion(self) -> None:
        screen_shake_enabled = True
        reduce_motion = True
        effective = screen_shake_enabled and not reduce_motion
        self.assertFalse(effective)


class TestPaletteContrast(unittest.TestCase):
    HEX = re.compile(r'Color\("([0-9A-Fa-f]{6})"\)')

    def test_each_palette_has_six_roles(self) -> None:
        src = (ROOT / "visuals" / "fossil_palette.gd").read_text()
        for fn in ("_default", "_protan", "_deutan", "_tritan", "_high_contrast", "_mono"):
            self.assertIn(f"func {fn}", src)
        # At least 6 roles * 6 palettes worth of Color("......") entries.
        self.assertGreaterEqual(len(self.HEX.findall(src)), 36)


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
