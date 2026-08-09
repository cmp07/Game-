#!/usr/bin/env python3
"""Cloud-safe gates for V3 latin type + paper page materials (LedgerType path)."""
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

    def test_ledgertype_autoload_before_locale(self) -> None:
        proj = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('LedgerType="*res://scripts/ledger_type.gd"', proj)
        self.assertNotIn('TypeKit="*res://scripts/type_kit.gd"', proj)
        type_i = proj.index("LedgerType=")
        locale_i = proj.index("LocaleManager=")
        self.assertLess(type_i, locale_i, "LedgerType must boot before LocaleManager")

    def test_menu_brand_uses_ledgertype_not_bare_themedb(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn("LedgerType", menu)
        brand = re.search(
            r"draw_string\(\s*([^\n,]+),\s*\n\s*Vector2\(brand_x, brand_y\)",
            menu,
        )
        self.assertIsNotNone(brand)
        # Brand lockup should go through LedgerType helper / display face.
        self.assertTrue(
            "LedgerType" in brand.group(1) or "_type(" in brand.group(1) or "display" in brand.group(1),
            brand.group(1),
        )

    def test_art_kit_page_materials(self) -> None:
        art = (ROOT / "scripts" / "art_kit.gd").read_text(encoding="utf-8")
        for name in (
            "draw_page_fiber_grid",
            "draw_desk_margin",
            "draw_ledger_page",
            "draw_index_card",
        ):
            self.assertIn(f"func {name}", art)


if __name__ == "__main__":
    unittest.main()
