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


class TestAudioV3Lift(unittest.TestCase):
    """Procedural AUDIO v3 lift — phrase grammar + fail wiring (not authored mix)."""

    def setUp(self) -> None:
        self.catalog = json.loads(
            (ROOT / "audio" / "events" / "audio_events.json").read_text()
        )
        self.director = (ROOT / "scripts" / "audio" / "audio_director.gd").read_text()
        self.chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        self.generator = (REPO / "tools" / "audio" / "generate_echo_lattice_placeholders.py").read_text()

    def test_catalog_version_3_and_fail_event(self) -> None:
        self.assertGreaterEqual(int(self.catalog.get("version", 0)), 3)
        self.assertIn("fail.reset", self.catalog["events"])
        fail = self.catalog["events"]["fail.reset"]
        self.assertEqual(fail.get("bus"), "SFX")
        self.assertIn("fail/reset", fail.get("stream", ""))

    def test_fail_reset_wired_on_chamber_restart(self) -> None:
        self.assertIn("func on_fail_reset", self.director)
        self.assertIn('fire("fail.reset")', self.director)
        self.assertIn("on_fail_reset()", self.chamber)

    def test_generator_is_v3_multi_stage_phrase(self) -> None:
        self.assertIn("GENERATOR_VERSION = 3", self.generator)
        self.assertIn("REWRITE_DURATION = 0.90", self.generator)
        self.assertIn("def rewrite_phrase", self.generator)
        self.assertIn("CELL_FLAT2", self.generator)
        self.assertIn("def fail_reset", self.generator)

    def test_operator_slam_phrase_duration(self) -> None:
        import struct
        import wave

        mirror = ROOT / "audio" / "sfx" / "rewrite" / "mirror.wav"
        self.assertTrue(mirror.is_file())
        with wave.open(str(mirror), "rb") as wf:
            dur = wf.getnframes() / float(wf.getframerate())
            n = wf.getnframes()
            rate = wf.getframerate()
            samples = struct.unpack("<" + "h" * n, wf.readframes(n))

        self.assertAlmostEqual(dur, 0.90, places=2)

        def rms(t0: float, t1: float) -> float:
            a = int(t0 * rate)
            b = int(t1 * rate)
            chunk = samples[a:b]
            if not chunk:
                return 0.0
            return (sum(x * x for x in chunk) / len(chunk)) ** 0.5 / 32767.0

        # Post-heartbeat air should be quieter than the cadmium hit.
        self.assertLess(rms(0.06, 0.08), rms(0.0, 0.05) * 0.5)
        # Slot downbeat is the loudest stage region.
        self.assertGreater(rms(0.55, 0.70), rms(0.36, 0.50))


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
        self.assertIn("y_lift", boot)
        main = (ROOT / "scripts" / "main.gd").read_text()
        self.assertIn("boot_title.tscn", main)
        self.assertIn("_show_boot_title_if_needed", main)
        self.assertIn("_boot_shown", main)
        self.assertIn("begin_boot_handoff", main)
        self.assertIn("_connect_menu_signals", main)
        self.assertTrue((ROOT / "scenes" / "boot_title.tscn").is_file())

    def test_menu_silent_boot_and_discrete_fold(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn("Cold boot stays silent", menu)
        self.assertNotIn('AudioDirector.fire("ui.click")\n\n\nfunc _localize_chrome', menu)
        # Fold tease must not breathe.
        self.assertNotIn("sin(_t * 2.0)", menu)
        art = (ROOT / "scripts" / "art_kit.gd").read_text()
        # Discrete fossil fold in the habit silhouette — no sin breathe.
        self.assertIn("fold_on", art)
        self.assertIn("func draw_open_folio", art)
        self.assertIn("func draw_habit_silhouette", art)
        self.assertIn("binder_holes", menu)
        self.assertIn("ArtKit.draw_seal_stamp", menu)
        self.assertIn("ArtKit.draw_open_folio", menu)
        self.assertIn("ArtKit.draw_habit_silhouette", menu)
        self.assertIn("folio_leaves", menu)
        self.assertIn("LedgerChrome.title_type_scale", menu)
        # Cadmium reserved — selection is rust underline + ink tick.
        self.assertNotIn("CADMIUM_WARN", menu)
        self.assertIn("_draw_seal_lattice", menu)
        self.assertIn("begin_boot_handoff", menu)
        self.assertIn("ArtKit.draw_index_card", menu)
        self.assertIn('"hero": true', menu)
        self.assertIn("ArtKit.draw_oxide_flecks", menu)
        self.assertNotIn("_draw_specimen_lattice", menu)
        self.assertIn("Idle rows stay clean", (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text())
        self.assertIn("func draw_desk_vignette", art)
        self.assertIn("_draw_ink_rule", (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text())
        # Title shell is not a paused chamber.
        self.assertNotIn("_draw_punchcard_ribbon", menu)
        self.assertNotIn("_footer_controls_hint", menu)
        self.assertNotIn('tr("menu.buffer")', menu)
        self.assertNotIn('tr("menu.controls_hint")', menu)

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
        self.assertTrue(
            "boot_splash/bg_color=Color(0.894118, 0.847059, 0.737255, 1)" in proj
            or "boot_splash/bg_color=Color(0.937255, 0.901961, 0.823529, 1)" in proj,
            msg="boot splash bg must be paper_bone family",
        )
        self.assertTrue((ROOT / "art" / "ui" / "boot_splash.png").is_file())
        gen = (ROOT / "art" / "generate_placeholders.py").read_text()
        self.assertIn("ui_boot_splash", gen)

    def test_title_settings_paper_polish(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn("menu.folio_mark", menu)
        self.assertIn("_card_slot_t", menu)
        self.assertIn("LedgerChrome", menu)
        self.assertIn("draw_open_folio", menu)
        self.assertIn("_focus_underline_t", menu)
        self.assertIn("_style_meta_as_ledger_lines", menu)
        settings = (ROOT / "scripts" / "a11y" / "settings_menu.gd").read_text()
        self.assertIn("settings.folio_mark", settings)
        self.assertIn("_style_folio_controls", settings)
        self.assertIn("LedgerChrome.paper_plate_style", settings)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text()
        self.assertIn("class_name LedgerChrome", chrome)
        self.assertIn("focus_progress", chrome)
        self.assertIn("RUST_FOSSIL", chrome)
        self.assertNotIn("CADMIUM_WARN", chrome)
        art = (ROOT / "scripts" / "art_kit.gd").read_text()
        self.assertIn('opts.get("binder_holes"', art)
        self.assertIn('opts.get("header_rules"', art)
        self.assertIn("func draw_seal_stamp", art)

    def test_field_index_card_syncs_with_card_column(self) -> None:
        """Regression: drawn Field Index plate and CardColumn must share layout."""
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        tscn = (ROOT / "scenes" / "menu.tscn").read_text()
        main = (ROOT / "scripts" / "main.gd").read_text()
        self.assertIn("func field_index_card_rect", menu)
        self.assertIn("func field_index_content_rect", menu)
        self.assertIn("func _sync_field_index_layout", menu)
        self.assertIn("func verify_field_index_layout", menu)
        self.assertIn("field_index_card_rect(vp, y_off)", menu)
        self.assertIn("_sync_field_index_layout()", menu)
        # Broken float used right-center anchors + fixed 280×400 card — ban that pairing.
        self.assertNotIn("offset_left = -340.0", tscn)
        self.assertNotIn("anchor_left = 1.0", tscn)
        self.assertIn("func _selftest_field_index_layout", main)
        self.assertIn("_verify_menu_field_index_layout", main)

    def test_brand_main_menu_screenshot_frames_field_index(self) -> None:
        """Store slate 02: menu actions must sit inside the Field Index plate."""
        import struct
        import zlib
        from pathlib import Path

        shot = Path(__file__).resolve().parents[3] / "docs/RELEASE/screenshots/02_brand_main_menu.png"
        self.assertTrue(shot.is_file(), msg=str(shot))
        data = shot.read_bytes()
        assert data[:8] == b"\x89PNG\r\n\x1a\n"
        idat = b""
        w = h = bpp = 0
        off = 8
        while off < len(data):
            ln = struct.unpack(">I", data[off : off + 4])[0]
            typ = data[off + 4 : off + 8]
            chunk = data[off + 8 : off + 8 + ln]
            off += 12 + ln
            if typ == b"IHDR":
                w, h = struct.unpack(">II", chunk[:8])
                bpp = {2: 3, 6: 4}[chunk[9]]
            elif typ == b"IDAT":
                idat += chunk
            elif typ == b"IEND":
                break
        self.assertEqual((w, h), (1920, 1080))
        raw = zlib.decompress(idat)
        stride = w * bpp
        rows = []
        i = 0
        prev = bytearray(stride)
        for _y in range(h):
            filt = raw[i]
            i += 1
            row = bytearray(raw[i : i + stride])
            i += stride
            if filt == 1:
                for x in range(stride):
                    row[x] = (row[x] + (row[x - bpp] if x >= bpp else 0)) & 255
            elif filt == 2:
                for x in range(stride):
                    row[x] = (row[x] + prev[x]) & 255
            elif filt == 3:
                for x in range(stride):
                    left = row[x - bpp] if x >= bpp else 0
                    row[x] = (row[x] + ((left + prev[x]) // 2)) & 255
            elif filt == 4:
                for x in range(stride):
                    a = row[x - bpp] if x >= bpp else 0
                    b = prev[x]
                    c = prev[x - bpp] if x >= bpp else 0
                    p = a + b - c
                    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                    pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                    row[x] = (row[x] + pr) & 255
            rows.append(row)
            prev = row

        def lum(x: int, y: int) -> int:
            r = rows[y]
            j = x * bpp
            return (r[j] + r[j + 1] + r[j + 2]) // 3

        brand = sum(
            1
            for y in range(220, 360, 2)
            for x in range(80, 640, 2)
            if lum(x, y) < 160
        )
        self.assertGreater(brand, 280, msg="brand lockup missing on left")
        # Rich composition: Field Index owns the right ~45% (not a postage stamp at x≥1450).
        left = None
        for x in range(980, 1300):
            if lum(x, 200) < 90:
                left = x
                break
        self.assertIsNotNone(left, msg="Field Index left edge missing in right column")
        self.assertLess(left, 1200, msg="Field Index too narrow / pushed to corner")
        # Ink hairline on the plate — strict threshold so ledger fiber/grid
        # (lum ~190–210) does not inflate the card height.
        edge = [
            y
            for y in range(60, 1040)
            if any(lum(left + dx, y) < 130 for dx in range(0, 3))
        ]
        self.assertGreater(len(edge), 280, msg="Field Index left rule missing")
        # Longest contiguous ink run = physical card edge.
        runs: list[tuple[int, int]] = []
        run_a: int | None = None
        for y in range(60, 1040):
            dark = any(lum(left + dx, y) < 130 for dx in range(0, 3))
            if dark and run_a is None:
                run_a = y
            elif not dark and run_a is not None:
                runs.append((run_a, y - 1))
                run_a = None
        if run_a is not None:
            runs.append((run_a, 1039))
        self.assertTrue(runs, msg="Field Index card edge run missing")
        top, bottom = max(runs, key=lambda r: r[1] - r[0])
        self.assertGreater(bottom - top, 520, msg="Field Index plate too short")
        text_bottom = max(
            y
            for y in range(top, bottom + 20, 2)
            if sum(1 for x in range(left + 48, left + 360, 2) if lum(x, y) < 150) > 10
        )
        # Allow a hairline for contact shadow / underline below the ink rule.
        self.assertLessEqual(text_bottom, bottom + 16)
        orphan = sum(
            1
            for y in range(bottom + 28, 1040, 2)
            for x in range(left + 48, left + 360, 2)
            if lum(x, y) < 140
        )
        self.assertLess(orphan, 40, msg="menu rows orphaned below Field Index card")
        # Title shell must not carry the chamber punch-card ribbon
        # (30× ~12px cells on a 14px pitch near the page foot).
        ribbon = 0
        for y in range(990, 1040, 2):
            cells = 0
            x = 100
            while x < 520:
                if lum(x, y) < 100 and lum(x + 6, y) < 100:
                    cells += 1
                x += 14
            if cells >= 12:
                ribbon += 1
        self.assertEqual(ribbon, 0, msg="BUFFER punch-card ribbon still on title menu")

    def test_locale_shell_keys(self) -> None:
        csv = (ROOT / "locale" / "echo_lattice.csv").read_text()
        for key in (
            "menu.colophon,",
            "menu.folio_mark,",
            "menu.seal_caption,",
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
