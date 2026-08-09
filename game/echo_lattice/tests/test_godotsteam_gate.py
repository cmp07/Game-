#!/usr/bin/env python3
"""Gate A — GodotSteam optional integration hardening.

No Godot / Steam client required.
Run: python3 game/echo_lattice/tests/test_godotsteam_gate.py
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = Path(__file__).resolve().parents[3]
FEATURES = ROOT / "config" / "steam_features.json"
SERVICE = ROOT / "scripts" / "steam" / "steam_service.gd"
GODOTSTEAM_BACKEND = ROOT / "scripts" / "steam" / "steam_godotsteam_backend.gd"
STUB = ROOT / "scripts" / "steam" / "steam_stub_backend.gd"
GODOTSTEAM_DOC = REPO / "docs" / "RELEASE" / "GODOTSTEAM.md"
ADDON_README = ROOT / "addons" / "godotsteam" / "README.md"
RENDER = REPO / "steam" / "echo_lattice" / "render_vdf_from_env.py"
VERIFY_STAGING = REPO / "steam" / "echo_lattice" / "verify_retail_staging.py"


class GodotSteamGateTests(unittest.TestCase):
    def test_install_docs_present(self) -> None:
        self.assertTrue(GODOTSTEAM_DOC.is_file(), f"missing {GODOTSTEAM_DOC}")
        text = GODOTSTEAM_DOC.read_text(encoding="utf-8")
        for needle in (
            "fail-closed",
            "Godot **4.3",
            "addons/godotsteam",
            "STEAM_APP_ID",
            "Spacewar",
            "never",
            "render_vdf_from_env.py",
        ):
            self.assertIn(needle, text)
        self.assertTrue(ADDON_README.is_file())

    def test_features_default_offline_no_spacewar(self) -> None:
        feats = json.loads(FEATURES.read_text(encoding="utf-8"))
        self.assertFalse(feats.get("steam_enabled"))
        self.assertFalse(feats.get("allow_spacewar_dev", True))
        self.assertEqual(feats.get("spacewar_dev_app_id"), 480)
        self.assertEqual(feats.get("app_id_placeholder"), "YOUR_APP_ID")

    def test_service_fail_closed_without_sdk(self) -> None:
        gd = SERVICE.read_text(encoding="utf-8")
        self.assertIn("_steam_sdk_fail_closed", gd)
        self.assertIn("GodotSteam SDK missing", gd)
        self.assertIn("func is_steam_sdk_fail_closed", gd)
        self.assertIn("_is_shipping_steam_context", gd)
        # Unlock / cloud / callbacks gated when SDK missing.
        self.assertIn("if _steam_sdk_fail_closed:", gd)
        self.assertIn("docs/RELEASE/GODOTSTEAM.md", gd)

    def test_no_spacewar_in_release_guards(self) -> None:
        gd = SERVICE.read_text(encoding="utf-8")
        self.assertIn("SPACEWAR_APP_ID", gd)
        self.assertIn("_is_shipping_steam_context", gd)
        self.assertIn("refusing Spacewar fallback", gd)
        backend = GODOTSTEAM_BACKEND.read_text(encoding="utf-8")
        self.assertIn("refusing Spacewar AppID 480 in release", backend)

    def test_stub_cloud_fail_closed(self) -> None:
        stub = STUB.read_text(encoding="utf-8")
        self.assertIn("func cloud_enabled_for_account", stub)
        # Must return false (fail-closed), not a bare `return true`.
        self.assertRegex(
            stub,
            r"func cloud_enabled_for_account\(\) -> bool:\s*\n(?:\s*#[^\n]*\n)*\s*return false",
        )

    def test_render_script_fail_closed_without_env(self) -> None:
        self.assertTrue(RENDER.is_file())
        env = {k: v for k, v in os.environ.items() if not k.startswith("STEAM_")}
        proc = subprocess.run(
            [sys.executable, str(RENDER), "--check", "--full"],
            cwd=REPO,
            env=env,
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc.returncode, 2, proc.stdout + proc.stderr)
        self.assertIn("missing env", proc.stderr.lower())

    def test_render_script_rejects_spacewar(self) -> None:
        env = {
            **os.environ,
            "STEAM_APP_ID": "480",
            "STEAM_DEPOT_ID_WINDOWS": "123",
            "STEAM_DEPOT_ID_LINUX": "456",
        }
        # Drop unrelated STEAM_ noise for clarity
        proc = subprocess.run(
            [sys.executable, str(RENDER), "--check", "--full"],
            cwd=REPO,
            env=env,
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc.returncode, 2, proc.stdout + proc.stderr)
        self.assertIn("Spacewar", proc.stderr)

    def test_render_script_writes_with_env(self) -> None:
        env = {
            **{k: v for k, v in os.environ.items() if not k.startswith("STEAM_")},
            "STEAM_APP_ID": "123456",
            "STEAM_DEPOT_ID_WINDOWS": "123457",
            "STEAM_DEPOT_ID_LINUX": "123458",
        }
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "rendered"
            proc = subprocess.run(
                [
                    sys.executable,
                    str(RENDER),
                    "--write",
                    "--full",
                    "--out",
                    str(out),
                ],
                cwd=REPO,
                env=env,
                capture_output=True,
                text=True,
            )
            self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)
            app = (out / "app_build.vdf").read_text(encoding="utf-8")
            self.assertIn('"AppID" "123456"', app)
            self.assertNotIn("YOUR_APP_ID", app)
            self.assertNotIn("480", app)
            depot = (out / "depot_windows.vdf").read_text(encoding="utf-8")
            self.assertIn('"DepotID" "123457"', depot)

    def test_verify_retail_staging_rejects_steam_appid(self) -> None:
        self.assertTrue(VERIFY_STAGING.is_file())
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "windows").mkdir()
            (root / "windows" / "steam_appid.txt").write_text("123456\n", encoding="utf-8")
            proc = subprocess.run(
                [sys.executable, str(VERIFY_STAGING), "--root", str(root)],
                cwd=REPO,
                capture_output=True,
                text=True,
            )
            self.assertEqual(proc.returncode, 2, proc.stdout + proc.stderr)
            self.assertIn("steam_appid.txt", proc.stderr)

    def test_verify_retail_staging_ok_empty(self) -> None:
        proc = subprocess.run(
            [sys.executable, str(VERIFY_STAGING)],
            cwd=REPO,
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)


if __name__ == "__main__":
    unittest.main()
