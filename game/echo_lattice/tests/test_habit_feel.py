#!/usr/bin/env python3
"""Static gates for habit-answer feel (Systems Truth T6–T8 / Habit V3 §6).

No Godot required. Locks split telegraph, post-rewrite hand line, and
Mirror Birth / Looking Glass ceremony hold wiring.

Run: python3 game/echo_lattice/tests/test_habit_feel.py
"""

from __future__ import annotations

import csv
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
LOCALE = ROOT / "locale" / "echo_lattice.csv"
CHAMBERS = ROOT / "content" / "chambers"


def _csv_keys() -> set[str]:
    with LOCALE.open(encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        next(reader)
        return {row[0] for row in reader if row and row[0].strip()}


class TestSplitTelegraph(unittest.TestCase):
    def setUp(self) -> None:
        self.chamber = (SCRIPTS / "chamber.gd").read_text(encoding="utf-8")

    def test_habit_cells_not_merged_into_forced_telegraph(self) -> None:
        # Habit foreshadow must stay on habit_telegraph_cells only (T7).
        refresh = self.chamber.split("func _refresh_telegraph")[1].split("func _update_rewrite_warn")[0]
        self.assertIn("telegraph_cells.append(p)", refresh)
        self.assertIn("habit_telegraph_cells.append(hp)", refresh)
        self.assertEqual(refresh.count("telegraph_cells.append(p)"), 1)
        self.assertEqual(refresh.count("habit_telegraph_cells.append(hp)"), 1)
        # Forced chalk set must not also absorb habit cells.
        self.assertNotRegex(refresh, r"(?<!habit_)telegraph_cells\.append\(hp\)")

    def test_distinct_draw_paths(self) -> None:
        self.assertIn("func _draw_forced_telegraph", self.chamber)
        self.assertIn("func _draw_habit_telegraph", self.chamber)
        self.assertIn("FossilRole.OVERUSE", self.chamber)
        self.assertIn("_draw_forced_telegraph(offset)", self.chamber)
        self.assertIn("_draw_habit_telegraph(offset)", self.chamber)

    def test_warn_counts_habit_telegraph(self) -> None:
        self.assertIn(
            "telegraph_cells.size() > 0 or habit_telegraph_cells.size() > 0",
            self.chamber,
        )


class TestHabitHandFeedback(unittest.TestCase):
    def setUp(self) -> None:
        self.chamber = (SCRIPTS / "chamber.gd").read_text(encoding="utf-8")
        self.stubs = (SCRIPTS / "a11y" / "subtitle_overlay.gd").read_text(encoding="utf-8")
        self.keys = _csv_keys()

    def test_announce_hook_present(self) -> None:
        self.assertIn("func _announce_habit_hand", self.chamber)
        self.assertIn("func _habit_op_subtitle_id", self.chamber)
        self.assertIn("_begin_post_rewrite_feedback", self.chamber)

    def test_op_locale_and_stubs(self) -> None:
        for key in (
            "subtitle.habit.op.deflector",
            "subtitle.habit.op.fossilize",
            "subtitle.habit.answer.hand",
            "habit.hand_looper",
            "habit.hand_right_leaner",
        ):
            self.assertIn(key, self.keys)
        for stub in (
            '"habit.op.deflector": "Corridor sealed."',
            '"habit.op.fossilize": "Loop calcified."',
            '"habit.answer.hand": "Answered your %s."',
        ):
            self.assertIn(stub, self.stubs)

    def test_last_habit_op_only_when_cells_land(self) -> None:
        self.assertIn("if not pending_habit_echoes.is_empty():", self.chamber)
        self.assertIn('last_habit_op = str(habit_pick.get("op", ""))', self.chamber)


class TestMirrorBirthCeremony(unittest.TestCase):
    def setUp(self) -> None:
        self.chamber = (SCRIPTS / "chamber.gd").read_text(encoding="utf-8")
        self.keys = _csv_keys()
        self.pa = (SCRIPTS / "audio" / "pa_announcer.gd").read_text(encoding="utf-8")

    def test_ceremony_hold_constant_and_lock(self) -> None:
        self.assertIn("const CEREMONY_HOLD_SEC", self.chamber)
        self.assertIn("_ceremony_hold_remaining", self.chamber)
        self.assertIn(
            "pending_echoes.size() > 0 or _ceremony_hold_remaining > 0.0",
            self.chamber,
        )
        self.assertIn("func _begin_ceremony_hold", self.chamber)
        self.assertIn("func _draw_ceremony_freeze_label", self.chamber)
        self.assertIn("func _draw_ceremony_slam_plate", self.chamber)

    def test_reduce_motion_skips_hold(self) -> None:
        hold = self.chamber.split("func _begin_ceremony_hold")[1].split("func _end_ceremony_hold")[0]
        self.assertIn("_reduce_motion()", hold)
        self.assertIn("_ceremony_hold_remaining = 0.0", hold)

    def test_second_birth_voicing(self) -> None:
        self.assertIn("pa.rewrite.second_birth", self.chamber)
        self.assertIn("pa.rewrite.second_birth", self.pa)
        self.assertIn("subtitle.pa.rewrite.second_birth", self.keys)
        self.assertIn("ceremony.mirror_birth.plate", self.keys)
        self.assertIn("ceremony.looking_glass.plate", self.keys)

    def test_birth_chambers_marked(self) -> None:
        mb = json.loads((CHAMBERS / "02_mirror_birth.json").read_text(encoding="utf-8"))
        lg = json.loads((CHAMBERS / "12_looking_glass.json").read_text(encoding="utf-8"))
        self.assertTrue(mb.get("spectacle"))
        self.assertTrue(lg.get("spectacle"))
        self.assertIn("spectacle", lg.get("tags", []))


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
