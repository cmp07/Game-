#!/usr/bin/env python3
"""Cloud-safe gates for MENU_TYPE_SYSTEM / LedgerType title roles."""
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
            "menu-premium-v1",
            "Actions **never** use mono",
            "≤ 13",
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
            "SIZE_META_1080 := 13",
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
            'return 0.62',
        ):
            self.assertIn(needle, src)

    def test_actions_never_mono(self) -> None:
        src = (ROOT / "scripts" / "ledger_type.gd").read_text(encoding="utf-8")
        # Premium type seam: actions resolve to Medium ("action"), brand/tagline to Bold display.
        self.assertIn("ROLE_BRAND, ROLE_TAGLINE:", src)
        self.assertIn("ROLE_ACTION, ROLE_ACTION_DISABLED:", src)
        self.assertIn('return "action"', src)
        self.assertIn('return "display"', src)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn('lt.apply_to_control(btn, "action", px)', chrome)
        self.assertNotIn('apply_to_control(btn, "mono"', chrome)

    def test_meta_mono_gate(self) -> None:
        src = (ROOT / "scripts" / "ledger_type.gd").read_text(encoding="utf-8")
        self.assertIn("px <= META_MONO_MAX_PX", src)
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn("size <= 13", chrome)

    def test_selection_margin_tick_baseline_not_spam(self) -> None:
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn("SELECT_RULE_MAX := 220.0", chrome)
        self.assertIn("_selection_baseline_width", chrome)
        self.assertIn("margin tick + baseline rule", chrome)
        # Idle / disabled must not draw rules (no underline spam).
        self.assertIn("if disabled or (not focused and not hovered):", chrome)
        self.assertNotIn("minf(max_w, 280.0)", chrome)


class TestMenuWiresRoles(unittest.TestCase):
    def test_menu_uses_role_faces(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn('_type("brand")', menu)
        self.assertIn('_type("tagline")', menu)
        self.assertIn('_type("deck")', menu)
        self.assertIn('_type("meta")', menu)
        self.assertIn('_type("micro")', menu)
        self.assertIn('_type("display")', menu)
        self.assertIn("MENU_TYPE_SYSTEM", menu)
        self.assertIn('scale.get("action"', menu)


if __name__ == "__main__":
    unittest.main()
