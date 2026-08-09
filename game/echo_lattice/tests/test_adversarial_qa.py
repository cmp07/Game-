#!/usr/bin/env python3
"""Adversarial QA contract tests (stdlib only, no Godot).

Locks mitigations from docs/AUDIT/ADVERSARIAL_QA.md, including the
DailyCalendar wiring (AQ-DAILY-01).
"""

from __future__ import annotations

import json
import re
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
SCRIPTS = ROOT / "scripts"
AUDIT = REPO / "docs" / "AUDIT" / "ADVERSARIAL_QA.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


class TestAdversarialAuditDoc(unittest.TestCase):
    def test_audit_doc_exists_and_covers_requested_edges(self) -> None:
        self.assertTrue(AUDIT.is_file(), f"missing {AUDIT}")
        text = _read(AUDIT)
        for needle in (
            "Rapid input",
            "Alt-tab",
            "Corrupt save",
            "Demo",
            "Daily",
            "Locale",
            "Gamepad",
            "Window resize",
            "Headless",
            "AQ-DAILY-01",
            "AQ-DEMO-01",
            "AQ-SAVE-02",
        ):
            self.assertIn(needle, text)


class TestSaveCloudOrdering(unittest.TestCase):
    """AQ-SAVE-02: Cloud must not read stale save.json before atomic rename."""

    def test_push_cloud_after_commit_helper_exists(self) -> None:
        gd = _read(SCRIPTS / "save_manager.gd")
        self.assertIn("func _push_cloud_after_commit", gd)
        self.assertIn("_push_cloud_after_commit()", gd)

    def test_push_not_called_before_rename(self) -> None:
        gd = _read(SCRIPTS / "save_manager.gd")
        # Extract save_to_disk body roughly.
        m = re.search(
            r"func save_to_disk\(\) -> bool:(.*?)(?=\nfunc |\Z)",
            gd,
            re.S,
        )
        self.assertIsNotNone(m, "save_to_disk not found")
        body = m.group(1)
        rename_at = body.find("rename_absolute(abs_tmp")
        push_at = body.find("_push_cloud_after_commit()")
        self.assertGreaterEqual(rename_at, 0, "atomic rename missing")
        self.assertGreaterEqual(push_at, 0, "cloud push helper call missing")
        self.assertLess(
            rename_at,
            push_at,
            "cloud push must happen after tmp→save rename",
        )
        # No direct push_cloud_save before rename in this function.
        pre = body[:rename_at]
        self.assertNotIn("push_cloud_save", pre)


class TestDemoFullSaveSanitize(unittest.TestCase):
    """AQ-DEMO-01: out-of-range queue indices must be clamped to active book."""

    def test_build_flavor_stamped(self) -> None:
        gd = _read(SCRIPTS / "save_manager.gd")
        self.assertIn('"build_flavor"', gd)
        self.assertIn('DemoBuild.is_demo()', gd)

    def test_sanitize_helper_present(self) -> None:
        gd = _read(SCRIPTS / "save_manager.gd")
        self.assertIn("func _sanitize_queue_against_book", gd)
        self.assertIn("_sanitize_queue_against_book()", gd)

    def test_python_model_of_sanitize(self) -> None:
        """Mirror the clamp logic for corrupt / full→demo queues."""

        def sanitize(run_queue: list[int], book_n: int) -> list[int]:
            return [i for i in run_queue if 0 <= int(i) < book_n]

        full_queue = list(range(35))
        demo_n = 9
        clamped = sanitize(full_queue, demo_n)
        self.assertEqual(clamped, list(range(9)))
        self.assertEqual(sanitize([0, 99, -1, 3], demo_n), [0, 3])
        self.assertEqual(sanitize([], demo_n), [])

    def test_corrupt_type_tables_reset_in_apply(self) -> None:
        gd = _read(SCRIPTS / "save_manager.gd")
        # After non-dict best_moves / completed, code must assign {}.
        self.assertRegex(
            gd,
            r'best_moves[\s\S]*?else:\s*\n\s*GameState\.best_moves = \{\}',
        )
        self.assertRegex(
            gd,
            r'run_queue[\s\S]*?else:\s*\n\s*GameState\.run_queue = \[\]',
        )

    def test_atomic_corrupt_primary_recovers_from_bak_shape(self) -> None:
        payload = {
            "version": 2,
            "build_flavor": "full",
            "current_chamber": 20,
            "best_moves": {"20": 12},
            "best_stars": {"20": 2},
            "completed": {"20": True},
            "habit_profile": {"up": 0, "down": 0, "left": 0, "right": 1},
            "run_mode": "standard",
            "run_queue": list(range(35)),
            "queue_pos": 20,
            "daily_seed": 0,
            "daily_label": "",
            "daily_best_stars": {},
            "run_started": True,
        }
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "save.json"
            bak = Path(td) / "save.json.bak"
            bak.write_text(json.dumps(payload), encoding="utf-8")
            path.write_text("{broken", encoding="utf-8")
            with self.assertRaises(json.JSONDecodeError):
                json.loads(path.read_text(encoding="utf-8"))
            recovered = json.loads(bak.read_text(encoding="utf-8"))
            self.assertEqual(recovered["build_flavor"], "full")
            demo_queue = [
                i for i in recovered["run_queue"] if 0 <= int(i) < 9
            ]
            self.assertEqual(len(demo_queue), 9)


class TestFocusAndPad(unittest.TestCase):
    def test_chamber_clears_hold_on_focus_out(self) -> None:
        gd = _read(SCRIPTS / "chamber.gd")
        self.assertIn("NOTIFICATION_APPLICATION_FOCUS_OUT", gd)
        self.assertIn("NOTIFICATION_WM_WINDOW_FOCUS_OUT", gd)
        self.assertIn("_hold_dir = Vector2i.ZERO", gd)

    def test_chamber_and_glyphs_handle_joy_disconnect(self) -> None:
        chamber = _read(SCRIPTS / "chamber.gd")
        glyphs = _read(SCRIPTS / "input_glyphs.gd")
        self.assertIn("joy_connection_changed", chamber)
        self.assertIn("joy_connection_changed", glyphs)
        self.assertIn("get_connected_joypads", glyphs)
        self.assertIn("Device.KEYBOARD", glyphs)


class TestLocaleMidRun(unittest.TestCase):
    def test_chamber_scene_listens_for_locale_changed(self) -> None:
        gd = _read(SCRIPTS / "chamber_scene.gd")
        self.assertIn("locale_changed", gd)
        self.assertIn("func _on_locale_changed", gd)
        self.assertIn("_refresh_title()", gd)


class TestDailyCalendarWired(unittest.TestCase):
    """AQ-DAILY-01 — Daily Challenge authority is calendar / catalog, not YYYYMMDD-only."""

    def test_calendar_module_exists(self) -> None:
        self.assertTrue((SCRIPTS / "daily_calendar.gd").is_file())
        self.assertTrue((ROOT / "content" / "daily" / "calendar_90.json").is_file())

    def test_gamestate_daily_uses_calendar(self) -> None:
        gs = _read(SCRIPTS / "game_state.gd")
        self.assertIn("func start_daily_run", gs)
        self.assertIn("get_datetime_dict_from_system(true)", gs)
        m = re.search(
            r"func start_daily_run\(\) -> void:(.*?)(?=\nfunc |\Z)",
            gs,
            re.S,
        )
        self.assertIsNotNone(m)
        body = m.group(1)
        self.assertIn("DailyCalendar", body)
        self.assertIn("daily_wing_for_entry", body)
        self.assertNotIn("daily_chamber_indices", body)
        self.assertNotIn("_today_seed()", body)

    def test_faq_still_promises_friend_code_calendar(self) -> None:
        faq = _read(REPO / "docs" / "RELEASE" / "SUPPORT_FAQ.md")
        self.assertIn("UTC", faq)
        self.assertIn("friend code", faq.lower())
        self.assertIn("calendar_90", faq)

    def test_calendar_seed_differs_from_yyyymmdd_shuffle_model(self) -> None:
        """Authored calendar rows carry friend_code; catalog seed ≠ YYYYMMDD int."""
        cal = json.loads(
            (ROOT / "content" / "daily" / "calendar_90.json").read_text(encoding="utf-8")
        )
        day0 = cal["days"][0]
        self.assertIn("friend_code", day0)
        self.assertIn("chamber_id", day0)
        y, m, d = (int(x) for x in day0["date"].split("-"))
        yyyymmdd = y * 10000 + m * 100 + d
        self.assertNotEqual(
            int(day0["seed"]),
            yyyymmdd,
            "calendar seed unexpectedly equals YYYYMMDD — revisit AQ-DAILY-01",
        )

    def test_menu_exposes_friend_code(self) -> None:
        menu = _read(SCRIPTS / "menu.gd")
        self.assertIn("friend_code", menu)
        self.assertIn("today_daily_entry", menu)


class TestHeadlessGuardsPresent(unittest.TestCase):
    def test_juice_and_ui_scale_skip_headless(self) -> None:
        juice = _read(SCRIPTS / "juice.gd")
        a11y = _read(SCRIPTS / "a11y" / "accessibility_service.gd")
        self.assertIn('DisplayServer.get_name() == "headless"', juice)
        self.assertIn('DisplayServer.get_name() == "headless"', a11y)


class TestRapidRewriteLockContract(unittest.TestCase):
    def test_rewrite_lock_blocks_move_and_undo(self) -> None:
        gd = _read(SCRIPTS / "chamber.gd")
        self.assertIn("func is_rewrite_locking", gd)
        # Movement + undo short-circuit while locking; restart remains available.
        self.assertIn("if is_rewrite_locking():", gd)
        self.assertIn('event.is_action_pressed("restart")', gd)


if __name__ == "__main__":
    raise SystemExit(unittest.main(verbosity=2))
