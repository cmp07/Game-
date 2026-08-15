#!/usr/bin/env python3
"""Contracts for Weaver gather → combine → weave → emit prototype loop."""

from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RECIPES = ROOT / "content" / "recipes.json"
FRAGMENTS = ROOT / "content" / "fragments.json"
SCRIPTS = ROOT / "scripts"
SCENES = ROOT / "scenes"
PROJECT = ROOT / "project.godot"
FIRST_FIVE = ROOT.parents[1] / "docs" / "WEAVER" / "32_FIRST_FIVE.md"


class PrototypeLoopTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.recipes = json.loads(RECIPES.read_text(encoding="utf-8"))
        cls.fragments = json.loads(FRAGMENTS.read_text(encoding="utf-8"))

    def test_project_is_godot_43_weaver(self) -> None:
        text = PROJECT.read_text(encoding="utf-8")
        self.assertIn('config/name="The Weaver"', text)
        self.assertIn("4.3", text)
        self.assertIn("Loom=", text)

    def test_first_five_doc_present(self) -> None:
        self.assertTrue(FIRST_FIVE.is_file())
        body = FIRST_FIVE.read_text(encoding="utf-8")
        self.assertIn("Anchor", body)
        self.assertIn("Span", body)
        self.assertIn("Brace", body)

    def test_first_five_fragment_fence(self) -> None:
        kinds = {k["id"] for k in self.recipes["fragment_kinds"]}
        self.assertEqual(kinds, {"Anchor", "Span"})
        families = {f["id"] for f in self.fragments["families"]}
        self.assertEqual(families, {"span", "anchor"})

    def test_brace_only_threads(self) -> None:
        thread_ids = {t["id"] for t in self.recipes["thread_types"]}
        self.assertEqual(thread_ids, {"Brace"})
        for recipe in self.recipes["combine_recipes"]:
            self.assertEqual(recipe["output_thread"], "Brace")

    def test_structure_emits_fragments(self) -> None:
        structure = self.recipes["structure"]
        self.assertEqual(structure["id"], "span_structure")
        emit = set(structure["emit_kinds"])
        self.assertTrue(emit.issubset({"Anchor", "Span"}))
        self.assertGreater(float(structure["emit_interval_sec"]), 0.0)

    def test_no_purple_time_in_content(self) -> None:
        blob = (json.dumps(self.recipes) + json.dumps(self.fragments)).lower()
        for banned in ("purple", "chrono", "hourglass", "aether"):
            self.assertNotIn(banned, blob)

    def test_loom_api_covers_loop(self) -> None:
        src = (SCRIPTS / "loom" / "loom_state.gd").read_text(encoding="utf-8")
        for name in (
            "func add_fragment(",
            "func combine_indices(",
            "func request_combine_ui(",
            "func seat_structure(",
            "func seat_play_structure(",
            "func has_verb(",
            "func emit_from_structure(",
            "func selftest_loop(",
        ):
            self.assertIn(name, src)

    def test_combine_ui_and_emit_wired(self) -> None:
        field = (SCRIPTS / "field.gd").read_text(encoding="utf-8")
        self.assertIn("CombinePanelScene", field)
        self.assertIn("request_combine_ui", field)
        self.assertIn("_on_structure_emit", field)
        self.assertIn("_run_field_selftest", field)
        structure = (SCRIPTS / "structure.gd").read_text(encoding="utf-8")
        self.assertIn("request_spawn_fragment", structure)
        self.assertIn("emit_from_structure", structure)
        combine = (SCRIPTS / "ui" / "combine_panel.gd").read_text(encoding="utf-8")
        self.assertIn("combine_ui_requested", combine)

    def test_scenes_exist(self) -> None:
        for rel in (
            "main.tscn",
            "field.tscn",
            "player.tscn",
            "fragment.tscn",
            "structure.tscn",
            "ui/combine_panel.tscn",
        ):
            self.assertTrue((SCENES / rel).is_file(), rel)

    def test_echo_lattice_untouched(self) -> None:
        self.assertEqual(ROOT.name, "weaver")
        self.assertTrue((ROOT.parent / "echo_lattice" / "project.godot").is_file())

    def test_recipe_lookup_anchor_span(self) -> None:
        def find(a: str, b: str) -> dict:
            for entry in self.recipes["combine_recipes"]:
                i0, i1 = entry["inputs"]
                if (i0 == a and i1 == b) or (i0 == b and i1 == a):
                    return entry
            return {}

        self.assertEqual(find("Anchor", "Span")["output_thread"], "Brace")
        self.assertEqual(find("Span", "Anchor")["id"], find("Anchor", "Span")["id"])


if __name__ == "__main__":
    unittest.main()
