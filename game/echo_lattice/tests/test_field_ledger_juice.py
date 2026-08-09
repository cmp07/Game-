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


class TestFeelQuickWins(unittest.TestCase):
    """QW-1..5 from docs/VISION/QUICK_WINS_SPEC.md — static feel gates."""

    def test_boot_title_scene_and_main_gate(self) -> None:
        boot = (ROOT / "scripts" / "boot_title.gd").read_text()
        self.assertIn("boot.wing_line", boot)
        self.assertIn("signal finished", boot)
        main = (ROOT / "scripts" / "main.gd").read_text()
        self.assertIn("boot_title.tscn", main)
        self.assertIn("_show_boot_title_if_needed", main)
        self.assertIn("_boot_shown", main)
        self.assertTrue((ROOT / "scenes" / "boot_title.tscn").is_file())

    def test_menu_silent_boot_and_discrete_fold(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn("Cold boot stays silent", menu)
        self.assertNotIn('AudioDirector.fire("ui.click")\n\n\nfunc _localize_chrome', menu)
        # Fold tease must not breathe.
        self.assertNotIn("sin(_t * 2.0)", menu)
        self.assertIn("fold_on", menu)
        self.assertIn("Binder holes", menu)

    def test_settings_index_card_chrome(self) -> None:
        settings = (ROOT / "scripts" / "a11y" / "settings_menu.gd").read_text()
        self.assertIn("_style_as_index_card", settings)
        self.assertIn("LedgerChrome.paper_plate_style", settings)
        self.assertIn("paper_wash_color", settings)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text()
        self.assertIn("PAPER_BONE", chrome)
        self.assertIn("shadow_size = 0", chrome)

    def test_chamber_page_framing(self) -> None:
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        self.assertIn("const PAGE_PAD", chamber)
        self.assertIn("_draw_page_registration", chamber)
        self.assertIn("Binding wash", chamber)

    def test_rewrite_warn_hysteresis(self) -> None:
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        self.assertIn("WARN_ARM_DIST", chamber)
        self.assertIn("WARN_DISARM_DIST", chamber)
        self.assertIn("_update_rewrite_warn_state", chamber)
        self.assertIn("is_rewrite_warn_active", chamber)
        # Goal plate no longer breathes.
        self.assertNotIn("sin(goal_pulse_t * 2.0)", chamber)
        scene = (ROOT / "scripts" / "chamber_scene.gd").read_text()
        self.assertIn("is_rewrite_warn_active", scene)

    def test_boot_locale_key(self) -> None:
        csv = (ROOT / "locale" / "echo_lattice.csv").read_text()
        self.assertIn("boot.wing_line,", csv)
        vision = REPO / "docs" / "VISION" / "QUICK_WINS_SPEC.md"
        self.assertTrue(vision.is_file())
        self.assertIn("QW-1", vision.read_text())


class TestDiegeticShellMvp(unittest.TestCase):
    """MVP shell: Pause Index, Colophon, boot splash, paper polish."""

    def test_pause_index_scene_and_chamber_wiring(self) -> None:
        self.assertTrue((ROOT / "scenes" / "ui" / "pause_index.tscn").is_file())
        pause = (ROOT / "scripts" / "ui" / "pause_index.gd").read_text()
        self.assertIn("signal resume_pressed", pause)
        self.assertIn("signal abandon_pressed", pause)
        self.assertIn("open_pause", pause)
        self.assertIn("PROCESS_MODE_WHEN_PAUSED", pause)
        scene = (ROOT / "scripts" / "chamber_scene.gd").read_text()
        self.assertIn("pause_index.tscn", scene)
        self.assertIn("_open_pause_index", scene)
        # Esc must not dump straight to title.
        unhandled = scene.split("func _unhandled_input")[1].split("\nfunc ")[0]
        self.assertIn("_open_pause_index", unhandled)
        self.assertNotIn('emit_signal("menu_requested")', unhandled)

    def test_credits_colophon_and_menu_entry(self) -> None:
        self.assertTrue((ROOT / "scenes" / "ui" / "credits_colophon.tscn").is_file())
        colo = (ROOT / "scripts" / "ui" / "credits_colophon.gd").read_text()
        self.assertIn("open_colophon", colo)
        self.assertIn("colophon.file_away", colo)
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn("credits_colophon.tscn", menu)
        self.assertIn("_open_colophon", menu)
        tscn = (ROOT / "scenes" / "menu.tscn").read_text()
        self.assertIn("ColophonButton", tscn)

    def test_boot_splash_enabled(self) -> None:
        proj = (ROOT / "project.godot").read_text()
        self.assertIn("boot_splash/show_image=true", proj)
        self.assertIn('boot_splash/image="res://art/ui/boot_splash.png"', proj)
        self.assertIn("boot_splash/bg_color=Color(0.937255, 0.901961, 0.823529, 1)", proj)
        self.assertTrue((ROOT / "art" / "ui" / "boot_splash.png").is_file())
        gen = (ROOT / "art" / "generate_placeholders.py").read_text()
        self.assertIn("ui_boot_splash", gen)

    def test_title_settings_paper_polish(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn("menu.folio_mark", menu)
        self.assertIn("_card_slot_t", menu)
        self.assertIn("PAPER_DEEP", menu)
        self.assertIn("LedgerChrome", menu)
        settings = (ROOT / "scripts" / "a11y" / "settings_menu.gd").read_text()
        self.assertIn("settings.folio_mark", settings)
        self.assertIn("_style_folio_controls", settings)
        self.assertIn("LedgerChrome.paper_plate_style", settings)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text()
        self.assertIn("class_name LedgerChrome", chrome)

    def test_locale_shell_keys(self) -> None:
        csv = (ROOT / "locale" / "echo_lattice.csv").read_text()
        for key in (
            "menu.colophon,",
            "menu.folio_mark,",
            "pause.resume,",
            "pause.abandon,",
            "colophon.heading,",
            "colophon.file_away,",
            "settings.folio_mark,",
        ):
            self.assertIn(key, csv)


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
