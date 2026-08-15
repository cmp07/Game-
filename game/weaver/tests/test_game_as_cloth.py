#!/usr/bin/env python3
"""Contracts for Game-as-Cloth metaphor lock + play-structure verb unlock stub."""

from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RECIPES = ROOT / "content" / "recipes.json"
CLOTH_GD = ROOT / "scripts" / "loom" / "game_as_cloth.gd"
LOOM_GD = ROOT / "scripts" / "loom" / "loom_state.gd"
DOC = ROOT.parents[1] / "docs" / "WEAVER" / "GAME_AS_CLOTH.md"


class GameAsClothTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.recipes = json.loads(RECIPES.read_text(encoding="utf-8"))
        cls.cloth_src = CLOTH_GD.read_text(encoding="utf-8")
        cls.loom_src = LOOM_GD.read_text(encoding="utf-8")
        cls.doc = DOC.read_text(encoding="utf-8")

    def test_metaphor_doc_present(self) -> None:
        self.assertTrue(DOC.is_file())
        for needle in (
            "weaving the game",
            "structures of play",
            "new verbs appear because you wove them",
            "not building a shed",
            "echo_loom",
        ):
            self.assertIn(needle, self.doc.lower() if needle != "echo_loom" else self.doc)

    def test_doc_bans_shed_builder_fantasy(self) -> None:
        lower = self.doc.lower()
        self.assertIn("not building a shed", lower)
        self.assertIn("structures of play", lower)
        self.assertIn("skill tree", lower)

    def test_play_structure_in_recipes(self) -> None:
        plays = self.recipes.get("play_structures", [])
        self.assertTrue(plays, "recipes.json must list play_structures")
        echo = next(p for p in plays if p["id"] == "echo_loom")
        self.assertEqual(echo["unlocks_verb"], "echo")
        self.assertEqual(echo["kind"], "play")
        self.assertEqual(echo["channel"], "play_grammar")

    def test_stub_script_exists(self) -> None:
        self.assertTrue(CLOTH_GD.is_file())
        for name in (
            "PLAY_STRUCTURE_VERBS",
            "echo_loom",
            "func seat_play_structure(",
            "func has_verb(",
            "func selftest(",
            "GAME_AS_CLOTH.md",
        ):
            self.assertIn(name, self.cloth_src)

    def test_loom_wires_cloth(self) -> None:
        for name in (
            "GameAsClothScript",
            "func seat_play_structure(",
            "func has_verb(",
            "verb_unlocked",
            "GAME_AS_CLOTH.md",
        ):
            self.assertIn(name, self.loom_src)

    def test_first_five_fence_still_brace_only(self) -> None:
        """Play-structure stub keeps FIRST_FIVE skins; open atoms may coexist."""
        kinds = {k["id"] for k in self.recipes["fragment_kinds"]}
        self.assertTrue({"Anchor", "Span"} <= kinds)
        thread_ids = {t["id"] for t in self.recipes["thread_types"]}
        self.assertIn("Brace", thread_ids)
        # FIRST_FIVE compatibility recipe remains
        brace = next(
            r
            for r in self.recipes["combine_recipes"]
            if set(r["inputs"]) == {"Anchor", "Span"}
        )
        self.assertEqual(brace["output_thread"], "Brace")

    def test_echo_locked_until_woven_contract_in_source(self) -> None:
        # Stub maps echo_loom → echo and starts without echo in BASE_VERBS.
        self.assertIn('"echo_loom": "echo"', self.cloth_src)
        self.assertIn("BASE_VERBS", self.cloth_src)
        self.assertNotIn('"echo"', self.cloth_src.split("BASE_VERBS")[1].split("]")[0])


if __name__ == "__main__":
    unittest.main()
