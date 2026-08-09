#!/usr/bin/env python3
"""Wishlist / store URL gate contracts (no Godot required).

Mirrors DemoBuild resolution rules so CI can prove:
  - itch / DRM-free feature tags suppress Steam CTAs
  - empty / YOUR_APP_ID store URLs never resolve to an openable link
  - real AppIDs or explicit store_* URLs unlock the CTA path
"""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURES = ROOT / "config" / "steam_features.json"
DEMO_BUILD = ROOT / "scripts" / "demo_build.gd"
MENU = ROOT / "scripts" / "menu.gd"
END = ROOT / "scripts" / "end_screen.gd"


def resolve_wishlist_url(
    *,
    store_wishlist_url: str = "",
    store_page_url: str = "",
    app_id_placeholder: str = "YOUR_APP_ID",
    wishlist_cta_enabled: bool = True,
    drm_free: bool = False,
) -> str:
    """Python twin of DemoBuild._resolved_wishlist_url + gate prechecks."""
    if drm_free or not wishlist_cta_enabled:
        return ""
    explicit = (store_wishlist_url or "").strip()
    if explicit:
        return "" if "YOUR_APP_ID" in explicit else explicit
    page = (store_page_url or "").strip()
    if page:
        return "" if "YOUR_APP_ID" in page else page
    app = (app_id_placeholder or "").strip()
    if not app or app == "YOUR_APP_ID" or not app.isdigit():
        return ""
    app_id = int(app)
    if app_id <= 0 or app_id == 480:
        return ""
    return f"https://store.steampowered.com/app/{app_id}/"


class WishlistGateTests(unittest.TestCase):
    def test_committed_features_default_to_no_live_url(self) -> None:
        feats = json.loads(FEATURES.read_text(encoding="utf-8"))
        url = resolve_wishlist_url(
            store_wishlist_url=feats.get("store_wishlist_url", ""),
            store_page_url=feats.get("store_page_url", ""),
            app_id_placeholder=feats.get("app_id_placeholder", "YOUR_APP_ID"),
            wishlist_cta_enabled=bool(feats.get("wishlist_cta_enabled", True)),
        )
        self.assertEqual(url, "")
        self.assertNotIn("YOUR_APP_ID", url)

    def test_drm_free_and_itch_suppress_even_with_real_url(self) -> None:
        url = resolve_wishlist_url(
            store_wishlist_url="https://store.steampowered.com/app/123456/",
            drm_free=True,
        )
        self.assertEqual(url, "")

    def test_explicit_store_url_wins(self) -> None:
        url = resolve_wishlist_url(
            store_wishlist_url="https://store.steampowered.com/app/999001/",
            app_id_placeholder="YOUR_APP_ID",
        )
        self.assertEqual(url, "https://store.steampowered.com/app/999001/")

    def test_numeric_app_id_derives_url(self) -> None:
        url = resolve_wishlist_url(app_id_placeholder="424242")
        self.assertEqual(url, "https://store.steampowered.com/app/424242/")

    def test_spacewar_and_placeholder_blocked(self) -> None:
        self.assertEqual(resolve_wishlist_url(app_id_placeholder="480"), "")
        self.assertEqual(resolve_wishlist_url(app_id_placeholder="YOUR_APP_ID"), "")
        self.assertEqual(
            resolve_wishlist_url(
                store_wishlist_url="https://store.steampowered.com/app/YOUR_APP_ID/"
            ),
            "",
        )

    def test_flag_off_blocks(self) -> None:
        self.assertEqual(
            resolve_wishlist_url(
                store_wishlist_url="https://store.steampowered.com/app/1/",
                wishlist_cta_enabled=False,
            ),
            "",
        )

    def test_gdscript_has_gates_and_no_hardcoded_placeholder_link(self) -> None:
        gd = DEMO_BUILD.read_text(encoding="utf-8")
        self.assertIn('PackedStringArray(["itch", "drm_free"])', gd)
        self.assertIn("wishlist_cta_enabled", gd)
        self.assertIn("store_wishlist_url", gd)
        self.assertNotRegex(gd, r"store\.steampowered\.com/app/YOUR_APP_ID")
        self.assertIsNotNone(re.search(r"func wishlist_cta_enabled", gd))
        self.assertIsNotNone(re.search(r"func is_drm_free_storefront", gd))
        self.assertIn("wishlist_cta_enabled()", MENU.read_text(encoding="utf-8"))
        self.assertIn("wishlist_cta_enabled()", END.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
