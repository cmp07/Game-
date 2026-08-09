#!/usr/bin/env python3
"""Weaver W1 juice contracts — no Godot required."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
JUICE_GD = ROOT / "scripts" / "juice" / "weaver_juice.gd"
PALETTE_GD = ROOT / "scripts" / "juice" / "weaver_palette.gd"
DEMO_GD = ROOT / "scripts" / "field" / "demo_field.gd"
PALETTE_JSON = ROOT / "content" / "palette.json"
PROJECT = ROOT / "project.godot"
JUICE_DOC = REPO / "docs" / "WEAVER" / "20_JUICE.md"

# Saturated purples / violets — must never appear as juice colors.
BANNED_HEX = {
    "7F00FF",
    "B026FF",
    "8A2BE2",
    "9B59B6",
    "6B2D8B",
    "A020F0",
    "9400D3",
    "8B00FF",
    "BF40BF",
}


class TestProjectScaffold(unittest.TestCase):
    def test_project_names_weaver_not_echo(self) -> None:
        text = PROJECT.read_text()
        self.assertIn('config/name="The Weaver"', text)
        self.assertIn("res://scenes/demo_field.tscn", text)
        self.assertIn("WeaverJuice=", text)
        self.assertIn("WeaverPalette=", text)
        # Product name must be Weaver; EL may appear only as a "do not overwrite" fence.
        self.assertNotRegex(text, r'config/name\s*=\s*"Echo Lattice"')

    def test_echo_lattice_untouched_marker(self) -> None:
        # Spike lives under game/weaver only.
        self.assertTrue((ROOT / "scripts" / "juice" / "weaver_juice.gd").is_file())
        self.assertTrue((REPO / "game" / "echo_lattice" / "project.godot").is_file())


class TestPalette(unittest.TestCase):
    def setUp(self) -> None:
        self.data = json.loads(PALETTE_JSON.read_text())
        self.swatches = self.data["swatches"]

    def test_required_swatches(self) -> None:
        for key in (
            "cloth_bone",
            "chalk_dust",
            "chalk_bright",
            "kiln_copper",
            "ink_seat",
            "gap_void",
            "timber",
        ):
            self.assertIn(key, self.swatches)
            hex_v = self.swatches[key]["hex"].lstrip("#").upper()
            self.assertRegex(hex_v, r"^[0-9A-F]{6}$")

    def test_no_banned_purple_swatches(self) -> None:
        for name, entry in self.swatches.items():
            hex_v = entry["hex"].lstrip("#").upper()
            self.assertNotIn(hex_v, BANNED_HEX, msg=f"{name} is banned purple")

    def test_kiln_copper_is_warm(self) -> None:
        h = self.swatches["kiln_copper"]["hex"].lstrip("#")
        r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
        self.assertGreater(r, b, "kiln_copper must stay warm (R > B)")
        self.assertGreater(r, 120)

    def test_gap_void_not_near_black_cosmos(self) -> None:
        h = self.swatches["gap_void"]["hex"].lstrip("#")
        r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
        # Torn cloth gap — sepia dark, not #000 void.
        self.assertGreater(r + g + b, 60)
        self.assertLess(abs(r - b), 40)

    def test_juice_timings_in_json(self) -> None:
        juice = self.data["juice"]
        self.assertEqual(juice["fragment_suck"]["duration_ms"], 320)
        self.assertEqual(juice["combine_flash"]["duration_ms"], 140)
        self.assertEqual(juice["weave_pulse"]["duration_ms"], 480)
        self.assertEqual(juice["weave_pulse"]["cycles"], 2)

    def test_banlist_mentions_purple_and_catch_beam(self) -> None:
        blob = json.dumps(self.data["banlist"]).lower()
        self.assertIn("purple", blob)
        self.assertIn("catch beam", blob)


class TestJuiceApi(unittest.TestCase):
    def setUp(self) -> None:
        self.juice = JUICE_GD.read_text()
        self.demo = DEMO_GD.read_text()

    def test_three_public_verbs(self) -> None:
        for fn in (
            "func fragment_suck(",
            "func combine_flash(",
            "func weave_pulse(",
        ):
            self.assertIn(fn, self.juice)

    def test_signals_exist(self) -> None:
        for sig in (
            "signal fragment_suck_finished",
            "signal combine_flash_finished",
            "signal weave_pulse_finished",
        ):
            self.assertIn(sig, self.juice)

    def test_durations_match_doc_contract(self) -> None:
        self.assertIn("const SUCK_DURATION: float = 0.32", self.juice)
        self.assertIn("const COMBINE_DURATION: float = 0.14", self.juice)
        self.assertIn("const WEAVE_DURATION: float = 0.48", self.juice)
        self.assertIn("const WEAVE_CYCLES: float = 2.0", self.juice)

    def test_wisp_cap_and_count_budget(self) -> None:
        self.assertIn("const WISP_CAP: int = 48", self.juice)
        self.assertIn("for i in range(6):", self.juice)

    def test_reduce_motion_path(self) -> None:
        self.assertIn("var reduce_motion: bool = false", self.juice)
        self.assertIn("if reduce_motion", self.juice)

    def test_no_purple_glow_language(self) -> None:
        # Strip comment lines — ban docs may name the forbidden look; code must not.
        code_lines = []
        for line in self.juice.splitlines():
            stripped = line.strip()
            if stripped.startswith("#"):
                continue
            code_lines.append(line.split("#", 1)[0])
        lowered = "\n".join(code_lines).lower()
        for needle in ("purple", "violet", "magenta", "bloom", "neon", "chroma"):
            self.assertNotIn(needle, lowered)

    def test_combine_flash_is_local_not_fullscreen(self) -> None:
        # Flash API takes an anchor + radius — never a viewport-covering helper.
        self.assertIn("func combine_flash(at: Vector2, radius: float", self.juice)
        self.assertNotIn("full_screen", self.juice.lower())
        self.assertNotIn("fullscreen", self.juice.lower())

    def test_weave_pulse_uses_polyline_path(self) -> None:
        self.assertIn("func weave_pulse(path: PackedVector2Array", self.juice)
        self.assertIn("draw_polyline(path", self.juice)
        self.assertIn("kiln_copper", self.juice)

    def test_demo_wires_three_verbs(self) -> None:
        self.assertIn("WeaverJuice.fragment_suck(", self.demo)
        self.assertIn("WeaverJuice.combine_flash(", self.demo)
        self.assertIn("WeaverJuice.weave_pulse(", self.demo)

    def test_demo_brand_lockup(self) -> None:
        self.assertIn("THE WEAVER", self.demo)
        self.assertIn("Stitch the gap", self.demo)

    def test_demo_selftest_hook(self) -> None:
        self.assertIn("func _selftest(", self.demo)
        self.assertIn("--selftest", self.demo)

    def test_no_banned_hex_literals_in_scripts(self) -> None:
        blob = (self.juice + PALETTE_GD.read_text() + self.demo).upper()
        for hx in BANNED_HEX:
            self.assertNotIn(hx, blob)


class TestJuiceDoc(unittest.TestCase):
    def test_doc_exists_and_points_at_code(self) -> None:
        text = JUICE_DOC.read_text()
        self.assertIn("fragment_suck", text)
        self.assertIn("combine_flash", text)
        self.assertIn("weave_pulse", text)
        self.assertIn("game/weaver/scripts/juice/weaver_juice.gd", text)
        self.assertIn("cursor/weaver-juice", text)
        self.assertIn("diegetic", text.lower())
        self.assertRegex(text, re.compile(r"purple", re.I))


if __name__ == "__main__":
    raise SystemExit(unittest.main(verbosity=2))
