#!/usr/bin/env python3
"""Cloud-safe gates for MENU_TYPE_SYSTEM / LedgerType title roles + Field Index 10/10."""
from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = Path(__file__).resolve().parents[3]
VISION = REPO / "docs" / "VISION"


class TestMenuTypeSystemDoc(unittest.TestCase):
    def test_vision_doc_exists(self) -> None:
        doc = (VISION / "MENU_TYPE_SYSTEM.md").read_text(encoding="utf-8")
        for needle in (
            "Brand",
            "Tagline",
            "Deck",
            "Action",
            "ActionDisabled",
            "Meta",
            "Micro",
            "1080p",
            "scale",
            "margin tick",
            "baseline",
            "Actions **never** use mono",
            "≤ 13",
            "IBM Plex Sans Condensed Medium",
            "solid",
        ):
            self.assertIn(needle, doc)
        readme = (VISION / "README.md").read_text(encoding="utf-8")
        self.assertIn("MENU_TYPE_SYSTEM.md", readme)


class TestLedgerTypeRoles(unittest.TestCase):
    def test_role_api_present(self) -> None:
        src = (ROOT / "scripts" / "ledger_type.gd").read_text(encoding="utf-8")
        for needle in (
            'ROLE_BRAND := "brand"',
            'ROLE_TAGLINE := "tagline"',
            'ROLE_DECK := "deck"',
            'ROLE_ACTION := "action"',
            'ROLE_ACTION_DISABLED := "action_disabled"',
            'ROLE_META := "meta"',
            'ROLE_MICRO := "micro"',
            "SIZE_BRAND_1080 := 92",
            "SIZE_ACTION_1080 := 20",
            "SIZE_META_1080 := 12",
            "TRACK_BRAND_1080",
            "func scale_factor",
            "func role_face",
            "func role_size",
            "func role_tracking",
            "func role_line_height",
            "func font_for_role",
            "func apply_role",
            "func title_role_scale",
            "META_MONO_MAX_PX := 13",
            "return 0.62",
            "IBMPlexSansCondensed-Medium.ttf",
            'return "action"',
        ):
            self.assertIn(needle, src)

    def test_actions_never_mono(self) -> None:
        src = (ROOT / "scripts" / "ledger_type.gd").read_text(encoding="utf-8")
        self.assertIn("ROLE_ACTION, ROLE_ACTION_DISABLED:", src)
        self.assertIn('return "action"', src)
        self.assertIn("ACTION_CANDIDATES", src)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn('lt.apply_role(btn, role, 1080.0, primary)', chrome)
        self.assertNotIn('apply_to_control(btn, "mono"', chrome)
        self.assertIn("NEVER mono", chrome)

    def test_meta_mono_gate(self) -> None:
        src = (ROOT / "scripts" / "ledger_type.gd").read_text(encoding="utf-8")
        self.assertIn("px <= META_MONO_MAX_PX", src)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn("size <= 13", chrome)

    def test_selection_margin_tick_baseline_not_spam(self) -> None:
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn("SELECT_RULE_MAX := 240.0", chrome)
        self.assertIn("_selection_baseline_width", chrome)
        self.assertIn("_draw_selection_baseline", chrome)
        self.assertIn("solid ink tick", chrome)
        self.assertIn("draw_rect(Rect2(tick_p.x - 2.0", chrome)
        # Idle / disabled must not draw rules (no underline spam).
        self.assertIn("if disabled or (not focused and not hovered):", chrome)
        self.assertNotIn("minf(max_w, 280.0)", chrome)
        # No jagged segmented letterpress selection rule.
        self.assertNotIn("Broken letterpress gap", chrome)


class TestMenuWiresRoles(unittest.TestCase):
    def test_menu_uses_role_faces(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn('_type("brand")', menu)
        self.assertIn('_type("tagline")', menu)
        self.assertIn('_type("deck")', menu)
        self.assertIn('_type("meta")', menu)
        self.assertIn('_type("micro")', menu)
        self.assertIn("MENU_TYPE_SYSTEM", menu)
        self.assertIn('scale.get("action"', menu)
        self.assertIn('"sharp_edge": true', menu)
        self.assertIn('"binder_holes": 0', menu)
        self.assertIn('"binder_clip": true', menu)


class TestFieldIndexBoutique(unittest.TestCase):
    def test_index_card_supports_sharp_boutique(self) -> None:
        art = (ROOT / "scripts" / "art_kit.gd").read_text(encoding="utf-8")
        self.assertIn("sharp_edge", art)
        self.assertIn("ruled_stock", art)
        self.assertIn("Sharp continuous ink edge", art)
        self.assertIn("var sharp_edge: bool", art)

    def test_medium_font_vendored(self) -> None:
        latin = ROOT / "fonts" / "latin"
        self.assertTrue((latin / "IBMPlexSansCondensed-Medium.ttf").is_file())
        self.assertTrue((latin / "IBMPlexSansCondensed-Bold.ttf").is_file())
        self.assertTrue((latin / "IBMPlexSansCondensed-Medium.ttf.import").is_file())


if __name__ == "__main__":
    unittest.main()
