#!/usr/bin/env python3
"""Contract tests for SECURITY.md High findings SEC-01 / SEC-02 / SEC-03.

Stdlib only — no Godot binary required.
Run: python3 game/echo_lattice/tests/test_security_high.py
"""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
SCRIPTS = ROOT / "scripts"
STEAM = SCRIPTS / "steam"
FEATURES = ROOT / "config" / "steam_features.json"
AUDIT_NOTE = REPO / "docs" / "AUDIT" / "SECURITY_HIGH_FIXES.md"
MAIN = SCRIPTS / "main.gd"
SAVE = SCRIPTS / "save_manager.gd"
CLOUD = STEAM / "steam_cloud_save.gd"
SERVICE = STEAM / "steam_service.gd"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# --- Python mirror of SaveManager.validate_save_dict (keep in sync) ---

SAVE_VERSION = 2
SAVE_VERSION_MIN = 1
SAVE_MAX_BYTES = 262144
SAVE_MAX_MAP_ENTRIES = 256
SAVE_MAX_QUEUE_LEN = 128
SAVE_MAX_CHAMBER_INDEX = 1023
SAVE_MAX_STRING_LEN = 256
SAVE_ALLOWED_KEYS = {
    "version",
    "updated_at",
    "build_flavor",
    "current_chamber",
    "best_moves",
    "best_stars",
    "completed",
    "run_cleared",
    "habit_profile",
    "run_mode",
    "run_queue",
    "queue_pos",
    "daily_seed",
    "daily_label",
    "daily_friend_code",
    "daily_chamber_id",
    "daily_source",
    "daily_variation",
    "daily_best_stars",
    "endless_seed",
    "endless_depth",
    "endless_best_depth",
    "endless_label",
    "run_started",
    "habit_identity_unlocked",
    "identity_stamps",
    "tutorial_flags",
}


def validate_save_text(text: str) -> dict:
    if len(text) > SAVE_MAX_BYTES:
        return {"ok": False, "reason": "payload_too_large"}
    stripped = text.strip()
    if not stripped:
        return {"ok": False, "reason": "empty"}
    try:
        parsed = json.loads(stripped)
    except json.JSONDecodeError:
        return {"ok": False, "reason": "not_object"}
    if not isinstance(parsed, dict):
        return {"ok": False, "reason": "not_object"}
    return validate_save_dict(parsed)


def validate_save_dict(data: dict) -> dict:
    if "version" not in data:
        return {"ok": False, "reason": "missing_version"}
    version = int(data.get("version", -1))
    if version < SAVE_VERSION_MIN or version > SAVE_VERSION:
        return {"ok": False, "reason": "version_out_of_range"}
    for key in data:
        if str(key) not in SAVE_ALLOWED_KEYS:
            return {"ok": False, "reason": f"unknown_key:{key}"}
    if "build_flavor" in data:
        flavor = str(data.get("build_flavor", ""))
        if len(flavor) > SAVE_MAX_STRING_LEN:
            return {"ok": False, "reason": "build_flavor_too_long"}
        if flavor and flavor not in ("demo", "full"):
            return {"ok": False, "reason": "build_flavor_invalid"}
    if "run_mode" in data:
        mode = str(data.get("run_mode", ""))
        if len(mode) > SAVE_MAX_STRING_LEN:
            return {"ok": False, "reason": "run_mode_too_long"}
        if mode and mode not in ("standard", "daily", "endless"):
            return {"ok": False, "reason": "run_mode_invalid"}
    if "daily_label" in data and len(str(data.get("daily_label", ""))) > SAVE_MAX_STRING_LEN:
        return {"ok": False, "reason": "daily_label_too_long"}
    if "current_chamber" in data:
        cc = int(data["current_chamber"])
        if cc < 0 or cc > SAVE_MAX_CHAMBER_INDEX:
            return {"ok": False, "reason": "current_chamber_out_of_range"}
    if "queue_pos" in data:
        qp = int(data["queue_pos"])
        if qp < 0 or qp > SAVE_MAX_QUEUE_LEN:
            return {"ok": False, "reason": "queue_pos_out_of_range"}
    for map_key in ("best_moves", "best_stars", "completed", "run_cleared", "daily_best_stars"):
        if map_key not in data:
            continue
        if not isinstance(data[map_key], dict):
            return {"ok": False, "reason": f"{map_key}_not_object"}
        if len(data[map_key]) > SAVE_MAX_MAP_ENTRIES:
            return {"ok": False, "reason": f"{map_key}_too_many_keys"}
        if map_key != "daily_best_stars":
            for mk in data[map_key]:
                idx = int(mk)
                if idx < 0 or idx > SAVE_MAX_CHAMBER_INDEX:
                    return {"ok": False, "reason": f"{map_key}_bad_index"}
    if "habit_profile" in data:
        habit = data["habit_profile"]
        if not isinstance(habit, dict):
            return {"ok": False, "reason": "habit_profile_not_object"}
        for hk in habit:
            if str(hk) not in ("up", "down", "left", "right"):
                return {"ok": False, "reason": "habit_profile_unknown_key"}
    if "run_queue" in data:
        rq = data["run_queue"]
        if not isinstance(rq, list):
            return {"ok": False, "reason": "run_queue_not_array"}
        if len(rq) > SAVE_MAX_QUEUE_LEN:
            return {"ok": False, "reason": "run_queue_too_long"}
        for idx_v in rq:
            if not isinstance(idx_v, (int, float)):
                return {"ok": False, "reason": "run_queue_entry_not_number"}
            qi = int(idx_v)
            if qi < 0 or qi > SAVE_MAX_CHAMBER_INDEX:
                return {"ok": False, "reason": "run_queue_index_out_of_range"}
    return {"ok": True, "data": data, "reason": ""}


def resolve_screenshot_out_dir(out_dir: str, project_root: str) -> str:
    """Mirror main.gd `_resolve_screenshot_out_dir` (user:// → sentinel)."""
    raw = out_dir.strip()
    if not raw or ".." in raw:
        return ""
    if raw.startswith("user://"):
        rest = raw[len("user://") :]
        if ".." in rest or rest.startswith("/") or rest.startswith("\\"):
            return ""
        return f"USER::{rest}"
    root = project_root.rstrip("/\\")
    if raw.startswith("/") or (len(raw) > 1 and raw[1] == ":"):
        abs_out = raw
    else:
        abs_out = str(Path(root) / raw)
    abs_norm = str(Path(abs_out).resolve()) if Path(abs_out).exists() else str(Path(abs_out))
    # Normalize without requiring the path to exist.
    abs_norm = str(Path(abs_out))
    parts = []
    for part in Path(abs_norm).parts:
        if part == "..":
            if parts:
                parts.pop()
        elif part != ".":
            parts.append(part)
    abs_norm = str(Path(*parts)) if parts else ""
    root_norm = str(Path(root))
    if abs_norm == root_norm or abs_norm.startswith(root_norm.rstrip("/\\") + "/"):
        return abs_norm
    return ""


class TestSec01AppIdFailClosed(unittest.TestCase):
    def test_features_disallow_spacewar_by_default(self) -> None:
        feats = json.loads(_read(FEATURES))
        self.assertFalse(feats.get("allow_spacewar_dev", True))
        self.assertEqual(feats.get("spacewar_dev_app_id"), 480)

    def test_service_has_fail_closed_helpers(self) -> None:
        gd = _read(SERVICE)
        self.assertIn("func _is_allowed_app_id", gd)
        self.assertIn("func _spacewar_dev_allowed", gd)
        self.assertIn("allow_spacewar_dev", gd)
        self.assertIn("refusing Spacewar fallback", gd)
        # Must not silently return spacewar when steam_enabled without gate.
        self.assertNotRegex(
            gd,
            r'if bool\(features\.get\("steam_enabled".*\)\):\s*\n\s*return int\(features\.get\("spacewar_dev_app_id"',
        )

    def test_init_skipped_when_app_id_zero_and_steam_enabled(self) -> None:
        gd = _read(SERVICE)
        self.assertIn("if app_id > 0:", gd)
        self.assertIn("Steam stays disabled", gd)


class TestSec02CloudSaveSchema(unittest.TestCase):
    def test_save_manager_exposes_validator(self) -> None:
        gd = _read(SAVE)
        self.assertIn("func validate_save_text", gd)
        self.assertIn("func validate_save_dict", gd)
        self.assertIn("SAVE_ALLOWED_KEYS", gd)
        self.assertIn("SAVE_MAX_BYTES", gd)

    def test_cloud_pull_validates_before_write(self) -> None:
        gd = _read(CLOUD)
        self.assertIn("SaveManager.validate_save_text", gd)
        self.assertIn("refusing pull", gd)
        self.assertIn("save.json.cloud.tmp", gd)
        m = re.search(
            r"func pull_if_newer\(.*?\n(.*?)(?=\nfunc |\Z)",
            gd,
            re.S,
        )
        self.assertIsNotNone(m)
        body = m.group(1)
        val_at = body.find("validate_save_text")
        write_at = body.find("_atomic_write_local")
        self.assertGreaterEqual(val_at, 0)
        self.assertGreaterEqual(write_at, 0)
        self.assertLess(val_at, write_at, "validate before writing local save")

    def test_python_validator_accepts_minimal_valid(self) -> None:
        ok = validate_save_dict(
            {
                "version": 2,
                "build_flavor": "full",
                "current_chamber": 0,
                "run_mode": "standard",
                "run_queue": [0, 1, 2],
                "best_moves": {"0": 12},
                "habit_profile": {"up": 1, "down": 0, "left": 0, "right": 2},
                "run_started": True,
            }
        )
        self.assertTrue(ok["ok"], ok)

    def test_python_validator_rejects_hostile_shapes(self) -> None:
        cases = [
            ({}, "missing_version"),
            ({"version": 99}, "version_out_of_range"),
            ({"version": 2, "evil": 1}, "unknown_key"),
            ({"version": 2, "run_queue": ["nope"]}, "run_queue_entry"),
            ({"version": 2, "run_queue": [99999]}, "run_queue_index"),
            ({"version": 2, "best_moves": {str(i): 1 for i in range(300)}}, "too_many"),
            ({"version": 2, "run_mode": "pwn"}, "run_mode_invalid"),
            ({"version": 2, "habit_profile": {"teleport": 1}}, "habit_profile"),
        ]
        for payload, needle in cases:
            with self.subTest(needle=needle):
                result = validate_save_dict(payload)
                self.assertFalse(result["ok"], payload)
                self.assertIn(needle, result["reason"])

    def test_python_validator_rejects_huge_payload(self) -> None:
        huge = '{"version":2,"daily_label":"' + ("x" * (SAVE_MAX_BYTES)) + '"}'
        result = validate_save_text(huge)
        self.assertFalse(result["ok"])
        self.assertEqual(result["reason"], "payload_too_large")


class TestSec03ScreenshotOutPath(unittest.TestCase):
    def test_resolver_present_in_main(self) -> None:
        gd = _read(MAIN)
        self.assertIn("func _resolve_screenshot_out_dir", gd)
        self.assertIn("func _safe_screenshot_filename", gd)
        self.assertIn("screenshot --out rejected", gd)

    def test_capture_scripts_use_project_staging(self) -> None:
        for name in (
            "capture_tour.sh",
            "capture_v2_complete.sh",
            "capture_press_gifs.sh",
        ):
            text = _read(ROOT / "tools" / name)
            self.assertIn(".capture_staging", text, name)
            self.assertNotIn("mktemp -d", text, name)

    def test_path_allowlist_python_model(self) -> None:
        root = "/workspace/game/echo_lattice"
        self.assertTrue(resolve_screenshot_out_dir("user://shots", root).startswith("USER::"))
        self.assertEqual(
            resolve_screenshot_out_dir(".capture_staging", root),
            f"{root}/.capture_staging",
        )
        self.assertEqual(
            resolve_screenshot_out_dir(f"{root}/.capture_staging", root),
            f"{root}/.capture_staging",
        )
        self.assertEqual(resolve_screenshot_out_dir("/tmp/evil", root), "")
        self.assertEqual(resolve_screenshot_out_dir("../escape", root), "")
        self.assertEqual(resolve_screenshot_out_dir("user://../x", root), "")
        self.assertEqual(resolve_screenshot_out_dir("", root), "")


class TestSecurityHighDocs(unittest.TestCase):
    def test_fix_note_exists(self) -> None:
        self.assertTrue(AUDIT_NOTE.is_file(), f"missing {AUDIT_NOTE}")
        text = _read(AUDIT_NOTE)
        for needle in ("SEC-01", "SEC-02", "SEC-03", "allow_spacewar_dev", "validate_save"):
            self.assertIn(needle, text)


if __name__ == "__main__":
    unittest.main()
