#!/usr/bin/env python3
"""Contract tests for remaining RC1 code P1s (hard UI, save schema, telemetry, settle).

Stdlib only — no Godot binary required.
Run: python3 game/echo_lattice/tests/test_remaining_p1.py
"""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
SCRIPTS = ROOT / "scripts"
CHAMBERS = ROOT / "content" / "chambers"
LOCALE = ROOT / "locale" / "echo_lattice.csv"
AUDIT = REPO / "docs" / "AUDIT"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def sanitize_telemetry_path(raw: str) -> str:
    """Mirror LocalTelemetry.sanitize_path."""
    p = raw.strip().replace("\\", "/")
    prefix = "user://telemetry/"
    default = "user://telemetry/echo_lattice_balance.jsonl"
    if not p or ".." in p:
        return default
    if not p.startswith(prefix):
        return default
    rest = p[len(prefix) :]
    if not rest or rest.endswith("/"):
        return default
    return p


class HardVariantMenuTests(unittest.TestCase):
    def test_menu_and_gamestate_wire_hard(self) -> None:
        menu = _read(SCRIPTS / "menu.gd")
        main = _read(SCRIPTS / "main.gd")
        gs = _read(SCRIPTS / "game_state.gd")
        book = _read(SCRIPTS / "chamber_book.gd")
        tscn = _read(ROOT / "scenes" / "menu.tscn")
        self.assertIn("signal hard_pressed", menu)
        self.assertIn("HardButton", tscn)
        self.assertIn("_on_menu_hard", main)
        self.assertIn("func start_hard_run", gs)
        self.assertIn("func can_start_hard_run", gs)
        self.assertIn("func unlocked_hard_variant_indices", book)
        self.assertIn("hard_variant_of", book)

    def test_hard_variant_of_plumbs_to_playable(self) -> None:
        loader = _read(SCRIPTS / "chamber_loader.gd")
        self.assertIn('"hard_variant_of"', loader)
        # Authored parents exist for all four hards.
        for slug, parent in (
            ("35_mirror_birth_hard", "mirror_birth"),
            ("36_looking_glass_hard", "looking_glass"),
            ("37_cement_trail_hard", "cement_trail"),
            ("38_nameplate_hard", "nameplate"),
        ):
            raw = json.loads((CHAMBERS / f"{slug}.json").read_text(encoding="utf-8"))
            self.assertEqual(raw.get("hard_variant_of"), parent)
            self.assertEqual(raw.get("role"), "hard")

    def test_locale_keys(self) -> None:
        csv = _read(LOCALE)
        self.assertIn("menu.hard,", csv)
        self.assertIn("menu.hard_count,", csv)
        self.assertIn("hud.hard_tag,", csv)
        # Smashed rows from prior merges must stay split.
        self.assertNotIn("15menu.demo_daily_meta", csv)
        self.assertNotIn("%shud.chamber_fallback", csv)


class SaveSchemaDriftTests(unittest.TestCase):
    def test_allowed_keys_cover_save_to_disk(self) -> None:
        save = _read(SCRIPTS / "save_manager.gd")
        # Keys written by save_to_disk must be allowlisted for Cloud validate.
        for key in (
            "updated_at",
            "daily_friend_code",
            "daily_chamber_id",
            "daily_source",
            "daily_variation",
            "endless_seed",
            "endless_depth",
            "endless_best_depth",
            "endless_label",
            "habit_identity_unlocked",
            "identity_stamps",
        ):
            self.assertIn(f'"{key}"', save)
        self.assertIn('"hard"', save)
        self.assertIn('"endless"', save)
        modes = re.search(r"SAVE_RUN_MODES: Array\[String\] = \[([\s\S]*?)\]", save)
        self.assertIsNotNone(modes)
        body = modes.group(1)
        for mode in ("standard", "daily", "endless", "hard", "ghost"):
            self.assertIn(f'"{mode}"', body)


class TelemetryPathTests(unittest.TestCase):
    def test_sanitize_rejects_escape(self) -> None:
        safe = "user://telemetry/echo_lattice_balance.jsonl"
        self.assertEqual(sanitize_telemetry_path(safe), safe)
        self.assertEqual(sanitize_telemetry_path("user://telemetry/ok.jsonl"), "user://telemetry/ok.jsonl")
        self.assertEqual(sanitize_telemetry_path("/tmp/evil.jsonl"), safe)
        self.assertEqual(sanitize_telemetry_path("user://../x"), safe)
        self.assertEqual(sanitize_telemetry_path("user://telemetry/../save.json"), safe)
        self.assertEqual(sanitize_telemetry_path("res://config/balance_v2.json"), safe)
        self.assertEqual(sanitize_telemetry_path("user://telemetry/"), safe)

    def test_gd_has_sanitize_and_pii_scrub(self) -> None:
        tel = _read(SCRIPTS / "local_telemetry.gd")
        self.assertIn("func sanitize_path", tel)
        self.assertIn("SAFE_PATH_PREFIX", tel)
        self.assertIn("include_pii", tel)
        self.assertIn("_scrub_pii", tel)
        self.assertIn("steam_id", tel)


class HabitModeAndSettleTests(unittest.TestCase):
    def test_chamber_uses_active_balance_mode(self) -> None:
        chamber = _read(SCRIPTS / "chamber.gd")
        self.assertIn("active_balance_mode", chamber)
        self.assertIn("_rewrite_settle_start_msec", chamber)
        self.assertIn("Time.get_ticks_msec", chamber)

    def test_audit_docs_note_closures(self) -> None:
        bugs = _read(AUDIT / "BUGS_CORE.md")
        ultra = _read(AUDIT / "ULTRA_AUDIT_RC1.md")
        self.assertIn("CORE-05", bugs)
        self.assertIn("cursor/fix-remaining-p1", ultra)


if __name__ == "__main__":
    unittest.main()
