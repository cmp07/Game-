#!/usr/bin/env python3
"""Contracts for Weaver gather → open combine → weave → emit prototype loop."""

from __future__ import annotations

import json
import unittest
from itertools import combinations_with_replacement
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RECIPES = ROOT / "content" / "recipes.json"
FRAGMENTS = ROOT / "content" / "fragments.json"
ATOMS = ROOT / "content" / "atoms.json"
SCRIPTS = ROOT / "scripts"
SCENES = ROOT / "scenes"
PROJECT = ROOT / "project.godot"
FIRST_FIVE = ROOT.parents[1] / "docs" / "WEAVER" / "32_FIRST_FIVE.md"
OPEN_GRAMMAR = ROOT.parents[1] / "docs" / "WEAVER" / "36_OPEN_COMPONENT_GRAMMAR.md"


def _pair_key(a: str, b: str) -> tuple[str, str]:
    return tuple(sorted((a, b)))


class PrototypeLoopTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.recipes = json.loads(RECIPES.read_text(encoding="utf-8"))
        cls.fragments = json.loads(FRAGMENTS.read_text(encoding="utf-8"))
        cls.atoms = json.loads(ATOMS.read_text(encoding="utf-8"))

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

    def test_open_grammar_doc_present(self) -> None:
        self.assertTrue(OPEN_GRAMMAR.is_file())
        body = OPEN_GRAMMAR.read_text(encoding="utf-8")
        for atom in ("Light", "Matter", "Energy", "Time", "Space"):
            self.assertIn(atom, body)
        self.assertIn("any two", body.lower())
        self.assertIn("interesting", body.lower())
        self.assertIn("recipe wiki", body.lower())

    def test_five_starting_atoms(self) -> None:
        ids = {a["id"] for a in self.atoms["atoms"]}
        self.assertEqual(ids, {"Light", "Matter", "Energy", "Time", "Space"})

    def test_craft_aliases_map_first_five(self) -> None:
        aliases = self.atoms["craft_aliases"]
        self.assertEqual(aliases["Anchor"], "Matter")
        self.assertEqual(aliases["Span"], "Space")

    def test_fragment_kinds_include_atoms_and_skins(self) -> None:
        kinds = {k["id"] for k in self.recipes["fragment_kinds"]}
        self.assertTrue({"Light", "Matter", "Energy", "Time", "Space"} <= kinds)
        self.assertTrue({"Anchor", "Span"} <= kinds)

    def test_open_combine_affinity_covers_all_pairs(self) -> None:
        atom_ids = [a["id"] for a in self.atoms["atoms"]]
        covered = {
            _pair_key(str(e["inputs"][0]), str(e["inputs"][1]))
            for e in self.atoms["combine_affinity"]
        }
        expected = {_pair_key(a, b) for a, b in combinations_with_replacement(atom_ids, 2)}
        self.assertEqual(covered, expected)

    def test_affinity_has_interesting_failures(self) -> None:
        outcomes = {e["outcome"] for e in self.atoms["combine_affinity"]}
        self.assertIn("bind", outcomes)
        self.assertTrue({"strain", "snap"} & outcomes)
        fails = [e for e in self.atoms["combine_affinity"] if e["outcome"] != "bind"]
        self.assertGreaterEqual(len(fails), 3)
        for entry in fails:
            self.assertTrue(entry.get("tell"))
            self.assertEqual(entry.get("consume"), "refund")

    def test_matter_space_still_braces(self) -> None:
        def find(a: str, b: str) -> dict:
            for entry in self.atoms["combine_affinity"]:
                i0, i1 = entry["inputs"]
                if (i0 == a and i1 == b) or (i0 == b and i1 == a):
                    return entry
            return {}

        ms = find("Matter", "Space")
        self.assertEqual(ms["outcome"], "bind")
        self.assertEqual(ms["output_thread"], "Brace")

    def test_no_purple_chronomancy_in_content(self) -> None:
        blob = (
            json.dumps(self.recipes) + json.dumps(self.fragments) + json.dumps(self.atoms)
        ).lower()
        for banned in ("purple", "chrono", "hourglass", "aether", "rewind"):
            self.assertNotIn(banned, blob)
        # Time atom is beat/dwell — ban note may mention chronomancy as refusal.
        time_atom = next(a for a in self.atoms["atoms"] if a["id"] == "Time")
        self.assertIn("beat", time_atom["role"].lower())

    def test_combine_rule_is_open_attempt(self) -> None:
        rule = self.fragments["combine_rule"]
        self.assertTrue(rule.get("any_pair_may_try"))
        self.assertTrue(rule.get("failures_are_interesting"))
        self.assertEqual(rule.get("mode"), "open_attempt")

    def test_brace_compat_recipes_remain(self) -> None:
        thread_ids = {t["id"] for t in self.recipes["thread_types"]}
        self.assertIn("Brace", thread_ids)
        brace_recipes = [
            r for r in self.recipes["combine_recipes"] if r["output_thread"] == "Brace"
        ]
        self.assertGreaterEqual(len(brace_recipes), 1)

    def test_structure_emits_fragments(self) -> None:
        structure = self.recipes["structure"]
        self.assertEqual(structure["id"], "span_structure")
        emit = set(structure["emit_kinds"])
        self.assertTrue(emit & {"Anchor", "Span", "Matter", "Space"})
        self.assertGreater(float(structure["emit_interval_sec"]), 0.0)

    def test_loom_api_covers_open_bind(self) -> None:
        src = (SCRIPTS / "loom" / "loom_state.gd").read_text(encoding="utf-8")
        for name in (
            "func add_fragment(",
            "func attempt_bind(",
            "func resolve_atom(",
            "func combine_indices(",
            "func request_combine_ui(",
            "func seat_structure(",
            "func emit_from_structure(",
            "func selftest_loop(",
            "func load_atoms(",
        ):
            self.assertIn(name, src)
        self.assertIn("bind_attempted", src)
        self.assertIn("failed_interestingly", src)

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
        self.assertIn("any two", combine.lower())

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

    def test_echo_lattice_untouched_tree(self) -> None:
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

    def test_no_building_step_wiki_in_atoms(self) -> None:
        blob = json.dumps(self.atoms).lower()
        for banned in ("step-by-step", "how to build", "building steps"):
            self.assertNotIn(banned, blob)


if __name__ == "__main__":
    unittest.main()
