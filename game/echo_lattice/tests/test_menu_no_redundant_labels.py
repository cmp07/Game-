#!/usr/bin/env python3
"""CI gate: title menu must not repeat Field Index / Wing labels.

Fails if:
  - FIELD INDEX is drawn twice (recto micro mark + card title)
  - WING appears ≥3 times across title draw / quiet meta copy
  - Dual seal captions (SURVEY SEAL + HABIT SILHOUETTE) still ink the verso
"""

from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MENU = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
LOCALE = (ROOT / "locale" / "echo_lattice.csv").read_text(encoding="utf-8")


def _draw_body() -> str:
    m = re.search(r"func _draw\(\) -> void:\n([\s\S]*?)\nfunc ", MENU)
    assert m, "menu.gd _draw() missing"
    return m.group(1)


def _refresh_body() -> str:
    m = re.search(r"func _refresh_progress_copy\(\) -> void:\n([\s\S]*?)\nfunc ", MENU)
    assert m, "menu.gd _refresh_progress_copy() missing"
    return m.group(1)


class TestMenuNoRedundantLabels(unittest.TestCase):
    def test_one_field_index_title_draw(self) -> None:
        body = _draw_body()
        # One draw_string site for the card title (demo ternary still counts as one title).
        title_sites = len(
            re.findall(
                r'draw_string\(\s*_type\("tagline"\),\s*card\.position',
                body,
            )
        )
        self.assertEqual(title_sites, 1, msg="FIELD INDEX must be drawn once on the card")
        self.assertIn('tr("menu.field_index")', body)
        # Recto micro header duplicates the card title — ban it on the title shell.
        self.assertNotIn('tr("menu.recto_mark")', body)
        self.assertIn('menu.field_index,FIELD INDEX,', LOCALE)

    def test_wing_not_restated_on_fresh_card(self) -> None:
        body = _draw_body()
        refresh = _refresh_body()
        # Verso keeps ONE folio mark with WING I.
        self.assertIn('tr("menu.folio_mark")', body)
        folio = re.search(r"menu\.folio_mark,([^,\n]+),", LOCALE)
        self.assertIsNotNone(folio)
        self.assertIn("WING", folio.group(1).upper())
        # Fresh title hides the wing/chamber subtitle — wing must not reappear on the card.
        self.assertIn("subtitle.visible = false", refresh)
        self.assertNotIn('tr("menu.subtitle_fresh")', refresh)
        # Count WING mentions in title draw + fresh-path locale keys that still ink.
        wing_hits = 0
        wing_hits += body.upper().count("WING")
        wing_hits += len(re.findall(r"WING", folio.group(1).upper()))
        # Locale key text for folio_mark already counted via folio; draw body should not
        # hardcode additional WING strings.
        self.assertLess(
            wing_hits,
            3,
            msg=f"WING appears too often on title shell (hits={wing_hits})",
        )

    def test_single_film_plate_no_dual_seal_captions(self) -> None:
        body = _draw_body()
        # One gameplay film plate under the brand — no dual seal/maze captions.
        self.assertIn("ArtKit.draw_ledger_film_plate", body)
        self.assertNotIn("ArtKit.draw_habit_silhouette", body)
        self.assertNotIn("ArtKit.draw_seal_stamp", body)
        self.assertNotIn('tr("menu.seal_caption")', body)
        self.assertNotIn('tr("menu.habit_silhouette")', body)
        self.assertIn("SPECIMEN_GAP", MENU)
        self.assertIn("PREVIEW_VERSO_FRAC", MENU)
        gap = re.search(r"const SPECIMEN_GAP: float = ([0-9.]+)", MENU)
        self.assertIsNotNone(gap)
        self.assertLessEqual(float(gap.group(1)), 16.0)
        preview = re.search(r"const PREVIEW_VERSO_FRAC: float = ([0-9.]+)", MENU)
        self.assertIsNotNone(preview)
        self.assertGreaterEqual(float(preview.group(1)), 0.55)
        self.assertLessEqual(float(preview.group(1)), 0.70)

    def test_quiet_meta_is_single_date_line(self) -> None:
        refresh = _refresh_body()
        self.assertIn('tr("menu.daily_meta_quiet_code")', refresh)
        # Quiet locale lines are date · code — no Sheet / Wing prefix restating folio.
        quiet = re.search(r"menu\.daily_meta_quiet_code,([^,\n]+),", LOCALE)
        self.assertIsNotNone(quiet)
        self.assertNotIn("Wing", quiet.group(1))
        self.assertNotIn("Sheet", quiet.group(1))
        self.assertIn("%s", quiet.group(1))


if __name__ == "__main__":
    unittest.main()
