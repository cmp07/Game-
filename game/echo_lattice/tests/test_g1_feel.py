#!/usr/bin/env python3
"""G1 / W1A feel gates — kill prototype tells, pack type, habit answer, shell."""

from __future__ import annotations

import csv
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
CSV_PATH = ROOT / "locale" / "echo_lattice.csv"


def load_locale() -> dict[str, dict[str, str]]:
    with CSV_PATH.open(encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows: dict[str, dict[str, str]] = {}
        for row in reader:
            if not row or not row[0].strip():
                continue
            key = row[0]
            entry = {}
            for i, col in enumerate(header[1:], start=1):
                entry[col] = row[i] if i < len(row) else ""
            rows[key] = entry
    return rows


class TestW1AEndLanguage(unittest.TestCase):
    def test_no_player_facing_slice(self) -> None:
        rows = load_locale()
        self.assertEqual(rows["end.title"]["en"], "LEDGER CLOSED")
        self.assertNotIn("SLICE", rows["end.title"]["en"].upper())
        self.assertNotIn("slice", rows["end.footer"]["en"].lower())
        self.assertNotIn("VISUAL v2", rows["end.footer"]["en"])
        blob = CSV_PATH.read_text(encoding="utf-8").lower()
        self.assertNotIn("end of slice", blob)
        self.assertNotIn("vertical slice", blob)
        tscn = (ROOT / "scenes" / "end_screen.tscn").read_text()
        self.assertNotIn("END OF SLICE", tscn)
        self.assertNotIn("Vertical slice", tscn)

    def test_end_summary_no_debug_counters(self) -> None:
        rows = load_locale()
        summary = rows["end.summary"]["en"]
        self.assertNotIn("u:%s", summary)
        self.assertNotIn("d:%s", summary)
        self.assertIn("Handwriting:", summary)


class TestW1AStarsInk(unittest.TestCase):
    def test_stars_glyph_helper(self) -> None:
        ledger = (ROOT / "scripts" / "ledger_type.gd").read_text()
        self.assertIn("func stars_ink", ledger)
        self.assertIn("★", ledger)
        self.assertIn("☆", ledger)
        won = (ROOT / "scripts" / "chamber_won.gd").read_text()
        self.assertIn("stars_ink", won)
        self.assertNotIn('out += "*" if i < n else "-"', won)
        museum = (ROOT / "scripts" / "museum_screen.gd").read_text()
        self.assertIn("stars_ink", museum)
        self.assertNotIn('star_s += "*" if i < stars else "-"', museum)


class TestW1ALatinType(unittest.TestCase):
    def test_latin_faces_vendored(self) -> None:
        latin = ROOT / "fonts" / "latin"
        for name in (
            "IBMPlexSansCondensed-Regular.ttf",
            "IBMPlexSansCondensed-SemiBold.ttf",
            "IBMPlexSansCondensed-Medium.ttf",
            "IBMPlexSansCondensed-Bold.ttf",
            "IBMPlexSerif-Regular.ttf",
            "IBMPlexMono-Regular.ttf",
            "OFL.txt",
        ):
            self.assertTrue((latin / name).is_file(), name)

    def test_ledger_type_autoload(self) -> None:
        project = (ROOT / "project.godot").read_text()
        self.assertIn('LedgerType="*res://scripts/ledger_type.gd"', project)
        self.assertTrue((ROOT / "scripts" / "ledger_type.gd").is_file())
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        self.assertIn('_type("brand")', menu)
        self.assertIn('_type("display")', menu)
        self.assertIn("LedgerType.font_or_fallback", menu)


class TestW1ABootSplash(unittest.TestCase):
    def test_custom_boot_splash(self) -> None:
        project = (ROOT / "project.godot").read_text()
        self.assertIn('boot_splash/image="res://art/ui/boot_splash.png"', project)
        self.assertIn("boot_splash/show_image=true", project)
        self.assertIn("0.894118", project)  # paper_bone
        self.assertTrue((ROOT / "art" / "ui" / "boot_splash.png").is_file())


class TestDiegeticClearScreens(unittest.TestCase):
    def test_won_and_end_draw_plates(self) -> None:
        won = (ROOT / "scripts" / "chamber_won.gd").read_text()
        end = (ROOT / "scripts" / "end_screen.gd").read_text()
        for src in (won, end):
            self.assertIn("func _draw", src)
            self.assertIn("folio_mark", src.lower())
            self.assertIn("PAPER_BONE", src)
            self.assertIn("_draw_button_underlines", src)
        # Flat ColorRect chrome removed from clear/colophon scenes.
        for scene in ("chamber_won.tscn", "end_screen.tscn"):
            tscn = (ROOT / "scenes" / scene).read_text()
            self.assertNotIn("Background", tscn)
            self.assertNotIn("AccentBar", tscn)


class TestHabitAnswerReadability(unittest.TestCase):
    def test_habit_answer_wiring(self) -> None:
        gs = (ROOT / "scripts" / "game_state.gd").read_text()
        self.assertIn("last_habit_answer", gs)
        self.assertIn("func note_habit_answer", gs)
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        self.assertIn("note_habit_answer", chamber)
        won = (ROOT / "scripts" / "chamber_won.gd").read_text()
        self.assertIn("_habit_answer_line", won)
        self.assertIn("habit.read.", won)
        rows = load_locale()
        for key in (
            "habit.read.looper",
            "habit.read.right_leaner",
            "won.habit_answer",
            "habit.answer.counter",
        ):
            self.assertIn(key, rows)
            self.assertTrue(rows[key]["en"].strip())

    def test_screenshot_seeds_habit_answer(self) -> None:
        main = (ROOT / "scripts" / "main.gd").read_text()
        self.assertIn('note_habit_answer("looper"', main)
        # Tooling paths must still skip boot title wait.
        self.assertIn("--screenshot", main)
        self.assertIn("_show_boot_title_if_needed", main)


class TestRoadmapG1Checklist(unittest.TestCase):
    def test_roadmap_marks_w1a_progress(self) -> None:
        roadmap = (REPO / "docs" / "VISION" / "ROADMAP_EXECUTE.md").read_text()
        self.assertIn("Wave 1A", roadmap)
        # Execution lead updates these as waves land.
        self.assertRegex(roadmap, r"W1A\.1|end language|END OF SLICE")


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
