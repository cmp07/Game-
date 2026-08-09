#!/usr/bin/env python3
"""Headless acceptance tests for Echo Lattice Steamworks readiness.

No Godot / Steam client required.
Run: python3 game/echo_lattice/tests/test_steamworks.py
"""

from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = Path(__file__).resolve().parents[3]
DOC = REPO / "docs" / "RELEASE" / "STEAMWORKS.md"
ACH_DOC = REPO / "docs" / "RELEASE" / "ACHIEVEMENTS.json"
ACH_RT = ROOT / "config" / "achievements_steam.json"
FEATURES = ROOT / "config" / "steam_features.json"
STEAM_SCRIPTS = ROOT / "scripts" / "steam"
STEAMPIPE = REPO / "steam" / "echo_lattice"


def load_json(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


class SteamworksTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.features = load_json(FEATURES)
        cls.ach_doc = load_json(ACH_DOC)
        cls.ach_rt = load_json(ACH_RT)

    def test_docs_exist(self) -> None:
        self.assertTrue(DOC.is_file(), f"missing {DOC}")
        text = DOC.read_text(encoding="utf-8")
        for needle in (
            "Offline without Steam",
            "Feature flags",
            "Rich presence",
            "Cloud save",
            "Overlay pause",
            "Depot export",
            "steam_appid.txt",
        ):
            self.assertIn(needle, text)

    def test_feature_flags_default_offline(self) -> None:
        self.assertEqual(self.features.get("schema_version"), 1)
        self.assertFalse(self.features.get("steam_enabled"))
        self.assertFalse(self.features.get("cloud_save_enabled"))
        self.assertFalse(self.features.get("allow_spacewar_dev", True))
        self.assertTrue(self.features.get("achievements_enabled"))
        self.assertTrue(self.features.get("rich_presence_enabled"))
        self.assertTrue(self.features.get("overlay_pause_enabled"))
        self.assertIn("presence", self.features)

    def test_store_url_feature_flags(self) -> None:
        self.assertTrue(self.features.get("wishlist_cta_enabled"))
        self.assertEqual(self.features.get("store_wishlist_url"), "")
        self.assertEqual(self.features.get("store_page_url"), "")
        self.assertEqual(self.features.get("app_id_placeholder"), "YOUR_APP_ID")
        demo = (ROOT / "scripts" / "demo_build.gd").read_text(encoding="utf-8")
        for needle in (
            "wishlist_cta_enabled",
            "store_wishlist_url",
            "is_drm_free_storefront",
            "STORE_WISHLIST_URL_TEMPLATE",
            "refusing to open placeholder",
        ):
            self.assertIn(needle, demo)
        self.assertNotIn("store.steampowered.com/app/YOUR_APP_ID", demo)
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        end = (ROOT / "scripts" / "end_screen.gd").read_text(encoding="utf-8")
        self.assertIn("wishlist_cta_enabled()", menu)
        self.assertIn("wishlist_cta_enabled()", end)

    def test_achievements_catalog_mirror(self) -> None:
        self.assertEqual(self.ach_doc, self.ach_rt, "docs and runtime achievement catalogs must match")
        ach = self.ach_doc.get("achievements", [])
        self.assertGreaterEqual(len(ach), 8)
        api_names = [a["api_name"] for a in ach]
        self.assertEqual(len(api_names), len(set(api_names)), "api_name must be unique")
        for a in ach:
            self.assertTrue(str(a["api_name"]).startswith("EL_"))
            self.assertIn("display_name", a)
            self.assertIn("description", a)
            self.assertIn("unlock", a)
            self.assertIn("kind", a["unlock"])
        mvp = [a for a in ach if a.get("mvp")]
        self.assertGreaterEqual(len(mvp), 5)
        self.assertIn("EL_FIRST_STEPS", api_names)
        self.assertIn("EL_DAILY_SEED", api_names)
        self.assertIn("EL_WING_ONE", api_names)

    def test_unlock_rule_kinds_known(self) -> None:
        known = {
            "chambers_completed_at_least",
            "chamber_completed",
            "act_cleared",
            "total_stars_at_least",
            "any_stars_at_least",
            "daily_cleared",
            "all_chambers_completed",
            "run_mode_is",
            "flag_true",
            "all_of",
            "any_of",
        }

        def walk(rule: dict) -> None:
            kind = rule.get("kind")
            self.assertIn(kind, known, f"unknown unlock kind {kind}")
            for child in rule.get("rules", []):
                walk(child)

        for a in self.ach_doc["achievements"]:
            walk(a["unlock"])

    def test_steam_scripts_present(self) -> None:
        for name in (
            "steam_service.gd",
            "steam_backend.gd",
            "steam_stub_backend.gd",
            "steam_godotsteam_backend.gd",
            "steam_achievements.gd",
            "steam_cloud_save.gd",
        ):
            path = STEAM_SCRIPTS / name
            self.assertTrue(path.is_file(), f"missing {path}")
            text = path.read_text(encoding="utf-8")
            self.assertTrue(len(text) > 40)

    def test_stub_mentions_offline(self) -> None:
        stub = (STEAM_SCRIPTS / "steam_stub_backend.gd").read_text(encoding="utf-8")
        self.assertIn("Offline", stub)
        service = (STEAM_SCRIPTS / "steam_service.gd").read_text(encoding="utf-8")
        self.assertIn("overlay", service.lower())
        self.assertIn("rich_presence", service)
        self.assertIn("cloud", service.lower())

    def test_project_autoload_steam_service(self) -> None:
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('SteamService="*res://scripts/steam/steam_service.gd"', project)
        # Cloud pull must run before GameState local load.
        steam_i = project.index("SteamService=")
        gs_i = project.index("GameState=")
        self.assertLess(steam_i, gs_i)

    def test_steampipe_templates(self) -> None:
        self.assertTrue((STEAMPIPE / "app_build.vdf").is_file())
        self.assertTrue((STEAMPIPE / "depot_windows.vdf").is_file())
        self.assertTrue((STEAMPIPE / "depot_build" / "windows" / ".gitkeep").is_file())
        app = (STEAMPIPE / "app_build.vdf").read_text(encoding="utf-8")
        depot = (STEAMPIPE / "depot_windows.vdf").read_text(encoding="utf-8")
        self.assertIn("YOUR_APP_ID", app)
        self.assertIn("YOUR_DEPOT_ID", depot)
        self.assertIn("steam_appid.txt", depot)
        self.assertIn("Echo Lattice", (STEAMPIPE / "README.md").read_text(encoding="utf-8"))

    def test_game_hooks_presence_and_achievements(self) -> None:
        main = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
        self.assertIn("set_menu_presence", main)
        self.assertIn("set_chamber_presence", main)
        self.assertIn("set_won_presence", main)
        gs = (ROOT / "scripts" / "game_state.gd").read_text(encoding="utf-8")
        self.assertIn("notify_chamber_cleared", gs)


if __name__ == "__main__":
    unittest.main()
