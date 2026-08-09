#!/usr/bin/env python3
"""Cloud-safe gates for V3 latin type + paper page materials."""
from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = Path(__file__).resolve().parents[3]
LATIN = ROOT / "fonts" / "latin"


class TestFontsMaterials(unittest.TestCase):
    def test_latin_faces_committed(self) -> None:
        required = [
            "IBMPlexSansCondensed-SemiBold.ttf",
            "IBMPlexSansCondensed-Regular.ttf",
            "IBMPlexSerif-Regular.ttf",
            "IBMPlexMono-Regular.ttf",
            "OFL.txt",
        ]
        for name in required:
            path = LATIN / name
            self.assertTrue(path.is_file(), f"missing {path}")
            if name.endswith(".ttf"):
                self.assertGreater(path.stat().st_size, 10_000)
                self.assertIn(path.read_bytes()[:4], (b"\x00\x01\x00\x00", b"OTTO"))
        ofl = (LATIN / "OFL.txt").read_text(encoding="utf-8", errors="replace")
        self.assertIn("SIL OPEN FONT LICENSE", ofl.upper())
        self.assertIn("Plex", ofl)

    def test_latin_not_gitignored(self) -> None:
        gi = (REPO / ".gitignore").read_text(encoding="utf-8")
        self.assertNotIn("fonts/latin/*.ttf", gi)
        self.assertNotIn("fonts/latin/*.otf", gi)

    def test_typekit_autoload_before_locale(self) -> None:
        proj = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('TypeKit="*res://scripts/type_kit.gd"', proj)
        type_i = proj.index("TypeKit=")
        locale_i = proj.index("LocaleManager=")
        self.assertLess(type_i, locale_i, "TypeKit must boot before LocaleManager")

    def test_menu_brand_uses_typekit_not_themedb(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn("TypeKit.display_font()", menu)
        self.assertIn("TypeKit.mono_font()", menu)
        # Brand lockup must not hard-wire ThemeDB.fallback_font.
        brand = re.search(
            r'draw_string\(\s*([^\n,]+),\s*\n\s*Vector2\(brand_x, brand_y\)',
            menu,
        )
        self.assertIsNotNone(brand)
        self.assertNotIn("ThemeDB.fallback_font", brand.group(1))
        # Remaining ThemeDB mentions are only fallbacks when TypeKit missing.
        themedb_lines = [ln for ln in menu.splitlines() if "ThemeDB.fallback_font" in ln]
        self.assertGreater(len(themedb_lines), 0)
        for line in themedb_lines:
            self.assertIn("TypeKit", line)

    def test_artkit_letterpress_helpers(self) -> None:
        art = (ROOT / "scripts" / "art_kit.gd").read_text(encoding="utf-8")
        for name in (
            "draw_letterpress_wall",
            "draw_ledger_page",
            "draw_desk_margin",
            "draw_page_fiber_grid",
            "draw_index_card",
        ):
            self.assertIn(f"func {name}", art)
        chamber = (ROOT / "scripts" / "chamber.gd").read_text(encoding="utf-8")
        self.assertIn("draw_letterpress_wall", chamber)
        self.assertIn("draw_ledger_page", chamber)
        self.assertIn("_paper_sides_for", chamber)

    def test_fetch_script_exists(self) -> None:
        script = REPO / "tools" / "fonts" / "fetch_ibm_plex_latin.py"
        self.assertTrue(script.is_file())
        text = script.read_text(encoding="utf-8")
        self.assertIn("IBMPlexSansCondensed-SemiBold.ttf", text)


if __name__ == "__main__":
    unittest.main()
