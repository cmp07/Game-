#!/usr/bin/env python3
"""Cloud-safe TECH ART v3 contract checks (no Godot binary)."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]


class TestTechArtV3Surface(unittest.TestCase):
    REQUIRED = [
        "shaders/paper_grain.gdshader",
        "shaders/ink_bleed.gdshader",
        "materials/paper_grain_page.tres",
        "materials/paper_grain_menu.tres",
        "materials/ink_bleed_slam.tres",
        "art/noise/paper_grain_512.png",
        "art/noise/bleed_edge_lut.png",
        "scripts/tech_art/tech_art.gd",
        "scripts/tech_art/paper_grain_layer.gd",
        "scripts/tech_art/slam_shader_driver.gd",
        "scripts/tech_art/ink_bleed_overlay.gd",
    ]

    def test_files_exist(self) -> None:
        missing = [p for p in self.REQUIRED if not (ROOT / p).is_file()]
        self.assertEqual(missing, [])

    def test_flag_defaults_off(self) -> None:
        data = json.loads((ROOT / "config" / "default_settings.json").read_text())
        self.assertIn("graphics", data)
        self.assertFalse(bool(data["graphics"]["tech_art_v3"]))

    def test_settings_store_builtin_default(self) -> None:
        src = (ROOT / "scripts" / "a11y" / "settings_store.gd").read_text()
        self.assertIn('"tech_art_v3": false', src)
        self.assertIn('"graphics"', src)

    def test_paper_grain_shader_contract(self) -> None:
        src = (ROOT / "shaders" / "paper_grain.gdshader").read_text()
        self.assertIn("shader_type canvas_item", src)
        self.assertIn("render_mode unshaded, blend_mix", src)
        self.assertIn("uniform sampler2D grain_tex", src)
        self.assertIn("battery_scale", src)
        self.assertIn("FRAGCOORD", src)
        # Opacity hint must stay ≤ 8%.
        self.assertRegex(src, r"opacity\s*:\s*hint_range\(0\.0,\s*0\.08\)")

    def test_ink_bleed_shader_contract(self) -> None:
        src = (ROOT / "shaders" / "ink_bleed.gdshader").read_text()
        self.assertIn("shader_type canvas_item", src)
        self.assertIn("max_uv_warp", src)
        self.assertIn("join_mask", src)
        self.assertIn("rust_fossil", src)
        # Ban spectacle distortion — warp capped at 0.04 in the hint.
        self.assertRegex(src, r"max_uv_warp\s*:\s*hint_range\(0\.0,\s*0\.04\)")

    def test_grain_material_opacity_cap(self) -> None:
        for rel in ("materials/paper_grain_page.tres", "materials/paper_grain_menu.tres"):
            text = (ROOT / rel).read_text()
            m = re.search(r"shader_parameter/opacity\s*=\s*([0-9.]+)", text)
            self.assertIsNotNone(m, rel)
            self.assertLessEqual(float(m.group(1)), 0.08 + 1e-6, rel)

    def test_hosts_gate_on_flag(self) -> None:
        chamber = (ROOT / "scripts" / "chamber.gd").read_text()
        menu = (ROOT / "scripts" / "menu.gd").read_text()
        scene = (ROOT / "scripts" / "chamber_scene.gd").read_text()
        self.assertIn("TechArt.v3_enabled()", chamber)
        self.assertIn("TechArt.v3_enabled()", menu)
        self.assertIn("PaperGrainLayer.attach_to", scene)
        self.assertIn("PaperGrainLayer.attach_to", menu)
        self.assertIn("InkBleedOverlay", chamber)
        self.assertIn("SlamShaderDriver", chamber)

    def test_selftest_hook(self) -> None:
        main = (ROOT / "scripts" / "main.gd").read_text()
        self.assertIn("func _selftest_tech_art_v3", main)
        self.assertIn("_selftest_tech_art_v3()", main)

    def test_vision_doc_authority(self) -> None:
        doc = REPO / "docs" / "VISION" / "TECH_ART_V3.md"
        self.assertTrue(doc.is_file())
        text = doc.read_text()
        self.assertIn("tech_art_v3", text)
        self.assertIn("paper_grain.gdshader", text)
        self.assertIn("ink_bleed.gdshader", text)


if __name__ == "__main__":
    raise SystemExit(unittest.main())
