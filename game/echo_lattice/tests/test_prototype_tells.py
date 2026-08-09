#!/usr/bin/env python3
"""Static gates for P0 prototype-tell kills (win/end/museum surface)."""

from __future__ import annotations

import csv
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]


def _load_locale() -> dict[str, dict[str, str]]:
    with (ROOT / "locale" / "echo_lattice.csv").open(encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows: dict[str, dict[str, str]] = {}
        for row in reader:
            if not row or not row[0].strip():
                continue
            rows[row[0]] = {
                header[i]: row[i] if i < len(row) else "" for i in range(1, len(header))
            }
        return rows


class TestEndLanguage(unittest.TestCase):
    def setUp(self) -> None:
        self.rows = _load_locale()
        self.end_gd = (ROOT / "scripts" / "end_screen.gd").read_text(encoding="utf-8")
        self.end_tscn = (ROOT / "scenes" / "end_screen.tscn").read_text(encoding="utf-8")

    def test_no_slice_branding_in_player_strings(self) -> None:
        banned = ("END OF SLICE", "Vertical slice", "VISUAL v2", "切片终章", "可玩切片")
        for key in ("end.title", "end.footer", "end.summary", "end.header_wing"):
            entry = self.rows[key]
            blob = f"{entry.get('en', '')}\n{entry.get('zh_Hans', '')}"
            for needle in banned:
                self.assertNotIn(needle, blob, msg=f"{key} still contains {needle!r}")

        for needle in ("END OF SLICE", "Vertical slice", "VISUAL v2"):
            self.assertNotIn(needle, self.end_tscn)
            self.assertNotIn(needle, self.end_gd)

    def test_ledger_closed_copy(self) -> None:
        self.assertEqual(self.rows["end.title"]["en"], "LEDGER CLOSED")
        self.assertIn("lattice remembers you", self.rows["end.tagline"]["en"].lower())
        self.assertIn("Field Ledger", self.rows["end.footer"]["en"])
        self.assertIn("ink on paper", self.rows["end.footer"]["en"])
        self.assertEqual(self.rows["end.header_wing"]["en"], "Wing filed.")

    def test_summary_has_no_raw_direction_dump(self) -> None:
        summary = self.rows["end.summary"]["en"]
        self.assertNotIn("u:%s", summary)
        self.assertNotIn("d:%s", summary)
        self.assertNotIn("(上:", self.rows["end.summary"]["zh_Hans"])
        self.assertIn("Handwriting:", summary)
        self.assertEqual(summary.count("%s"), 6)
        self.assertIn("_handwriting_line", self.end_gd)
        # Player-facing format no longer interpolates raw u/d/l/r counters.
        self.assertNotIn(
            "int(hp.get(\"up\", 0)), int(hp.get(\"down\", 0))",
            self.end_gd,
        )

    def test_colophon_chrome_and_museum_cta(self) -> None:
        self.assertIn("func _draw", self.end_gd)
        self.assertIn("end.folio_mark", self.end_gd)
        self.assertIn("museum_pressed", self.end_gd)
        self.assertIn("end.museum", self.end_gd)
        self.assertIn("draw_circle", self.end_gd)
        self.assertIn("_draw_button_underlines", self.end_gd)
        self.assertNotIn("Background", self.end_tscn)
        self.assertNotIn("AccentBar", self.end_tscn)
        main = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("_on_end_museum", main)
        self.assertIn("museum_pressed", main)


class TestInkStars(unittest.TestCase):
    def setUp(self) -> None:
        self.won = (ROOT / "scripts" / "chamber_won.gd").read_text(encoding="utf-8")
        self.museum = (ROOT / "scripts" / "museum_screen.gd").read_text(encoding="utf-8")

    def test_won_uses_ink_star_glyphs(self) -> None:
        self.assertIn('"★"', self.won)
        self.assertIn('"☆"', self.won)
        self.assertNotRegex(self.won, r'out \+= "\*" if')
        self.assertNotRegex(self.won, r'out \+= "-" if')

    def test_museum_uses_ink_star_glyphs(self) -> None:
        self.assertIn('"★"', self.museum)
        self.assertIn('"☆"', self.museum)
        self.assertNotRegex(self.museum, r'star_s \+= "\*" if')
        self.assertNotRegex(self.museum, r'star_s \+= "-" if')


class TestClearStampLeaf(unittest.TestCase):
    def setUp(self) -> None:
        self.won = (ROOT / "scripts" / "chamber_won.gd").read_text(encoding="utf-8")
        self.tscn = (ROOT / "scenes" / "chamber_won.tscn").read_text(encoding="utf-8")
        self.rows = _load_locale()

    def test_diegetic_draw_chrome(self) -> None:
        self.assertIn("func _draw", self.won)
        self.assertIn("won.folio_mark", self.won)
        self.assertIn("CLEAR STAMP", self.rows["won.folio_mark"]["en"])
        self.assertIn("draw_circle", self.won)
        self.assertIn("_draw_button_underlines", self.won)
        # Flat ColorRect stack removed — page is drawn.
        self.assertNotIn("Background", self.tscn)
        self.assertNotIn("AccentBar", self.tscn)

    def test_locale_corruption_fixed(self) -> None:
        self.assertEqual(self.rows["won.daily_line_code"]["zh_Hans"], "\n每日 %s · %s")
        self.assertEqual(self.rows["end.header_daily_code"]["zh_Hans"], "每日 %s · %s 完成。")
        self.assertNotIn("won.stars_glyph", self.rows["won.daily_line_code"]["zh_Hans"])
        self.assertNotIn("end.summary", self.rows["end.header_daily_code"]["zh_Hans"])


class TestNarrativeArcCongruence(unittest.TestCase):
    def test_vision_doc_locked_lines_present(self) -> None:
        arc = (REPO / "docs" / "VISION" / "NARRATIVE_ARC.md").read_text(encoding="utf-8")
        self.assertIn("LEDGER CLOSED", arc)
        self.assertIn("The lattice remembers you.", arc)
        rows = _load_locale()
        self.assertEqual(rows["end.title"]["en"], "LEDGER CLOSED")
        self.assertEqual(rows["end.tagline"]["en"], "The lattice remembers you.")


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
