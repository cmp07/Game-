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

    def test_ledgertype_pins_font_oversampling(self) -> None:
        """oversampling=0 (import default) can yield ~3× get_height and break Deck Field Index."""
        src = (ROOT / "scripts" / "ledger_type.gd").read_text(encoding="utf-8")
        self.assertIn("oversampling = 1.0", src)
        self.assertIn('ResourceLoader.load(path, "FontFile")', src)
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn("title_type_scale(560.0 if compact else 1080.0)", menu)
        self.assertNotIn("load_dynamic_font", menu)

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
            "draw_desk_vignette",
            "draw_fiber_streaks",
            "draw_letterpress_rule",
            "draw_oxide_flecks",
            "draw_ledger_page",
            "draw_open_folio",
            "draw_habit_silhouette",
            "draw_index_card",
            "draw_seal_stamp",
            "draw_binder_clip",
        ):
            self.assertIn(f"func {name}", art)
        # Desk vignette + blotter; seal is imperfect rubber ink; card has thickness.
        self.assertIn("blotter", art.lower())
        self.assertIn("vignette", art.lower())
        self.assertIn("Imperfect rubber ink", art)
        self.assertIn("binder_holes", art)
        self.assertIn("contact wash", art.lower())
        self.assertIn('"thickness"', art)
        self.assertIn("Open two-leaf Field Ledger", art)
        self.assertIn("never an empty dashed box", art)

    def test_ledger_chrome_title_type_scale(self) -> None:
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn("func title_type_scale", chrome)
        self.assertIn("const TYPE_BRAND := 92", chrome)
        self.assertIn("const TYPE_INDEX := 20", chrome)
        self.assertIn("_draw_ink_rule", chrome)
        self.assertNotIn("CADMIUM_WARN", chrome)
        self.assertIn("func draw_binder_clip", (ROOT / "scripts" / "art_kit.gd").read_text(encoding="utf-8"))
        self.assertIn("TYPE_TAGLINE", chrome)
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn("ArtKit.draw_desk_margin", menu)
        self.assertIn("ArtKit.draw_open_folio", menu)
        self.assertIn("ArtKit.draw_habit_silhouette", menu)
        self.assertIn("ArtKit.draw_index_card", menu)
        self.assertIn("ArtKit.draw_seal_stamp", menu)
        self.assertIn('"hero": true', menu)
        self.assertIn("ArtKit.draw_oxide_flecks", menu)
        self.assertIn("LedgerChrome.title_type_scale", menu)
        # Field Index enclosure must stay on shared card geometry helpers.
        self.assertIn("field_index_card_rect(vp, y_off)", menu)
        self.assertIn("func verify_field_index_layout", menu)
        self.assertIn("func folio_leaves", menu)
        # Large seal — composition art (menu-premium-v1).
        self.assertIn("168.0", menu)


if __name__ == "__main__":
    unittest.main()
