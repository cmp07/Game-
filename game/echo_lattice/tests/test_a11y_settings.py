#!/usr/bin/env python3
"""Smoke tests for Echo Lattice release accessibility (no Godot required)."""

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
        self.assertEqual(self.data["version"], 2)

    def test_required_accessibility_keys(self) -> None:
        a11y = self.data["accessibility"]
        required = {
            "colorblind_mode",
            "fossil_use_patterns",
            "reduce_flash",
            "flash_max_intensity",
            "screen_shake_enabled",
            "screen_shake_intensity",
            "subtitles_enabled",
            "subtitle_size",
            "subtitle_background",
            "ui_scale",
            "show_ghost_path_once",
            "hold_to_walk",
            "reduce_motion",
        }
        missing = required - set(a11y)
        self.assertFalse(missing, missing)

    def test_ui_scale_range_default(self) -> None:
        self.assertAlmostEqual(float(self.data["accessibility"]["ui_scale"]), 1.0)

    def test_shake_defaults_field_ledger(self) -> None:
        # Document game: shake off / subtle unless the player opts in.
        a11y = self.data["accessibility"]
        self.assertFalse(bool(a11y["screen_shake_enabled"]))
        self.assertLessEqual(float(a11y["screen_shake_intensity"]), 0.4)

    def test_required_input_actions(self) -> None:
        bindings = self.data["input_bindings"]
        for action in (
            "move_up",
            "move_down",
            "move_left",
            "move_right",
            "undo",
            "restart",
            "pause_menu",
            "ghost_assist",
            "confirm",
        ):
            self.assertIn(action, bindings)
            self.assertGreaterEqual(len(bindings[action]), 1)


class TestSourceSurface(unittest.TestCase):
    REQUIRED = [
        "scripts/a11y/settings_store.gd",
        "scripts/a11y/accessibility_service.gd",
        "scripts/a11y/fossil_palette.gd",
        "scripts/a11y/flash_gate.gd",
        "scripts/a11y/action_remap.gd",
        "scripts/a11y/subtitle_overlay.gd",
        "scripts/a11y/settings_menu.gd",
        "scripts/a11y/ghost_path_assist.gd",
        "scenes/ui/subtitle_overlay.tscn",
        "scenes/ui/settings_menu.tscn",
        "config/default_settings.json",
    ]

    def test_files_exist(self) -> None:
        missing = [p for p in self.REQUIRED if not (ROOT / p).is_file()]
        self.assertEqual(missing, [])

    def test_release_doc_exists(self) -> None:
        doc = REPO / "docs" / "RELEASE" / "ACCESSIBILITY.md"
        self.assertTrue(doc.is_file(), doc)
        text = doc.read_text()
        for needle in (
            "Colorblind",
            "Reduce flash",
            "Remap",
            "Subtitles",
            "UI scale",
            "Xbox",
            "Steam Deck",
            "ACR",
        ):
            self.assertIn(needle, text)

    def test_project_autoloads_a11y(self) -> None:
        proj = (ROOT / "project.godot").read_text()
        for name in ("SettingsStore", "AccessibilityService", "ActionRemap"):
            self.assertIn(name, proj)
        self.assertIn("ghost_assist", proj)

    def test_juice_routes_flash_gate(self) -> None:
        juice = (ROOT / "scripts" / "juice.gd").read_text()
        self.assertIn("FlashGate.gate", juice)
        self.assertIn("_shake_intensity", juice)

    def test_rewrite_punch_no_forced_cadmium_flash(self) -> None:
        juice = (ROOT / "scripts" / "juice.gd").read_text()
        # Field Ledger: rewrite_punch must not full-screen flash cadmium.
        start = juice.index("func rewrite_punch")
        end = juice.index("\nfunc ", start + 1)
        body = juice[start:end]
        self.assertNotIn("request_rewrite_flash", body)
        self.assertNotIn("FlashGate.gate", body)
        self.assertIn("hitstop", body)

    def test_subtitle_background_setter_exists(self) -> None:
        src = (ROOT / "scripts" / "a11y" / "accessibility_service.gd").read_text()
        self.assertIn("func set_subtitle_background", src)

    def test_settings_has_locale_and_subtitle_background(self) -> None:
        tscn = (ROOT / "scenes" / "ui" / "settings_menu.tscn").read_text()
        for needle in (
            "LanguageOption",
            "SubtitleBackgroundCheck",
            "_on_language_selected",
            "_on_subtitle_background_toggled",
        ):
            self.assertIn(needle, tscn)
        menu = (ROOT / "scripts" / "a11y" / "settings_menu.gd").read_text()
        self.assertIn("apply_locale", menu)
        self.assertIn('tr("settings.title")', menu)

    def test_input_glyphs_use_remap_and_tr(self) -> None:
        src = (ROOT / "scripts" / "input_glyphs.gd").read_text()
        self.assertIn("ActionRemap", src)
        self.assertIn("get_binding_labels", src)
        self.assertIn('tr("glyphs.controls_keyboard")', src)
        self.assertIn('tr("hud.restart_fmt")', src)

    def test_menu_footer_uses_gamepad_not_last_device_ge_zero(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn("using_gamepad()", menu)
        self.assertNotIn("last_device >= 0", menu)
        self.assertIn('tr("menu.controls_hint_remap")', menu)

    def test_cjk_fetch_script_and_ofl(self) -> None:
        script = REPO / "tools" / "fonts" / "fetch_noto_sans_sc.py"
        ofl = ROOT / "fonts" / "cjk" / "OFL.txt"
        self.assertTrue(script.is_file(), script)
        self.assertTrue(ofl.is_file(), ofl)
        self.assertIn("SIL OPEN FONT LICENSE", ofl.read_text())
        self.assertIn("NotoSansSC", script.read_text())
        gitattributes = (REPO / ".gitattributes").read_text()
        self.assertIn("fonts/cjk/*.otf", gitattributes)
        self.assertIn("filter=lfs", gitattributes)

    def test_chamber_uses_role_colors(self) -> None:
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        for needle in (
            "_role_color",
            "GhostPathAssist",
			"_update_hold_to_walk",
			"_hold_to_walk_enabled",

            "_subtitle_line",
            "FossilRole.ECHO_WALL",
        ):
            self.assertIn(needle, chamber)

    def test_fossil_modes_declared(self) -> None:
        src = (ROOT / "scripts" / "a11y" / "fossil_palette.gd").read_text()
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
        src = (ROOT / "scripts" / "a11y" / "subtitle_overlay.gd").read_text()
        for stub_id in (
            "rewrite_begin",
            "rewrite_mirror",
            "checkpoint",
            "ghost_assist",
            "pa.checkpoint.armed",
        ):
            self.assertIn(f'"{stub_id}"', src)

    def test_settings_menu_wires_signals(self) -> None:
        tscn = (ROOT / "scenes" / "ui" / "settings_menu.tscn").read_text()
        for method in (
            "_on_language_selected",
            "_on_colorblind_selected",
            "_on_reduce_flash_toggled",
            "_on_shake_toggled",
            "_on_subtitles_toggled",
            "_on_subtitle_background_toggled",
            "_on_ui_scale_changed",
            "_on_ghost_assist_toggled",
            "_on_close_pressed",
        ):
            self.assertIn(method, tscn)

    def test_menu_has_settings_button(self) -> None:
        menu = (ROOT / "scenes" / "menu.tscn").read_text()
        self.assertIn("SettingsButton", menu)


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

    def test_reduce_motion_halves(self) -> None:
        self.assertAlmostEqual(self.gate_flash(1.0, False, True), 0.5)

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

    def test_ui_scale_clamped(self) -> None:
        def clamp_scale(v: float) -> float:
            return max(0.85, min(1.5, v))

        self.assertAlmostEqual(clamp_scale(0.5), 0.85)
        self.assertAlmostEqual(clamp_scale(2.0), 1.5)
        self.assertAlmostEqual(clamp_scale(1.1), 1.1)


class TestPaletteContrast(unittest.TestCase):
    HEX = re.compile(r'Color\("#([0-9A-Fa-f]{6})"\)')

    def test_each_palette_has_roles(self) -> None:
        src = (ROOT / "scripts" / "a11y" / "fossil_palette.gd").read_text()
        for fn in ("_default", "_protan", "_deutan", "_tritan", "_high_contrast", "_mono"):
            self.assertIn(f"func {fn}", src)
        # 8 roles * 6 palettes
        self.assertGreaterEqual(len(self.HEX.findall(src)), 48)


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
