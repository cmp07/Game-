#!/usr/bin/env python3
"""Onboarding path + teach-moment contracts (no Godot required).

Guarantees Quiet Span → Echo Plate → Mirror Birth is a 0–3 minute first-hook:
shortest-path sum ≤ 90 steps, Echo Plate literacy plate (C, rewrite.cap 0),
Mirror Birth spectacle + hints, wishlist CTA only behind DemoBuild gates.
"""

from __future__ import annotations

import json
import re
import unittest
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHAMBERS = ROOT / "content" / "chambers"
SCRIPTS = ROOT / "scripts"
DEMO_SPEC = ROOT.parents[1] / "docs" / "RELEASE" / "DEMO_SPEC.md"

ONBOARD_IDS = ("00_quiet_span", "01_echo_plate", "02_mirror_birth")
PATH_BUDGET = 90


def shortest_path(cells: list[str]) -> int:
    start = goal = None
    walk: set[tuple[int, int]] = set()
    for y, row in enumerate(cells):
        for x, ch in enumerate(row):
            if ch in ".PCG":
                walk.add((x, y))
            if ch == "P":
                start = (x, y)
            if ch == "G":
                goal = (x, y)
    assert start and goal
    q: deque[tuple[tuple[int, int], int]] = deque([(start, 0)])
    seen = {start}
    while q:
        (x, y), d = q.popleft()
        if (x, y) == goal:
            return d
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n in walk and n not in seen:
                seen.add(n)
                q.append((n, d + 1))
    return -1


def load_chamber(cid: str) -> dict:
    return json.loads((CHAMBERS / f"{cid}.json").read_text(encoding="utf-8"))


class OnboardingPathTests(unittest.TestCase):
    def test_path_budget_under_three_minutes(self) -> None:
        total = 0
        for cid in ONBOARD_IDS:
            data = load_chamber(cid)
            cells = data["map"]
            sp = shortest_path(cells)
            self.assertGreaterEqual(sp, 0, f"{cid} unreachable")
            total += sp
            self.assertTrue(data.get("hints"), f"{cid} missing hints[]")
            self.assertTrue(data.get("onboarding"), f"{cid} missing onboarding flag")
        self.assertLessEqual(
            total,
            PATH_BUDGET,
            f"shortest-path sum {total} exceeds {PATH_BUDGET}-move / ~3min budget",
        )

    def test_echo_plate_literacy_plate(self) -> None:
        data = load_chamber("01_echo_plate")
        cells = data["map"]
        self.assertGreaterEqual(sum(row.count("C") for row in cells), 1)
        self.assertEqual(data["transform"], "none")
        self.assertEqual(int(data["rewrite"]["cap"]), 0)
        self.assertIn("plate", data["hints"][0].lower())

    def test_mirror_birth_spectacle(self) -> None:
        data = load_chamber("02_mirror_birth")
        self.assertEqual(data["title"], "Mirror Birth")
        self.assertEqual(data["transform"], "mirror_v")
        self.assertTrue(data.get("spectacle"))
        self.assertGreaterEqual(sum(row.count("C") for row in data["map"]), 1)
        self.assertIn("mirror", data["hints"][0].lower())

    def test_runtime_teach_hooks_present(self) -> None:
        chamber = (SCRIPTS / "chamber.gd").read_text(encoding="utf-8")
        scene = (SCRIPTS / "chamber_scene.gd").read_text(encoding="utf-8")
        for needle in (
            "func _teach_checkpoint_armed",
            "func _teach_rewrite_settled",
            "func _arm_undo_teach",
            "func _begin_ceremony_hold",
            "func _announce_habit_hand",
            "signal teach_hint",
            "signal undo_hint_changed",
            "pa.rewrite.matched",
            "pa.rewrite.second_birth",
            "pa.undo.hint",
            "CEREMONY_HOLD_SEC",
        ):
            self.assertIn(needle, chamber)
        self.assertIn("_on_teach_hint", scene)
        self.assertIn("_on_undo_hint_changed", scene)
        self.assertIn("wishlist_cta_enabled()", (SCRIPTS / "menu.gd").read_text(encoding="utf-8"))
        self.assertIn("wishlist_cta_enabled()", (SCRIPTS / "end_screen.gd").read_text(encoding="utf-8"))

    def test_main_selftest_budget_gate(self) -> None:
        main = (SCRIPTS / "main.gd").read_text(encoding="utf-8")
        self.assertIsNotNone(re.search(r"func _selftest_onboarding_path", main))
        self.assertIn("90", main)
        self.assertIn("01_echo_plate", main)

    def test_demo_spec_mentions_budget(self) -> None:
        spec = DEMO_SPEC.read_text(encoding="utf-8")
        self.assertIn("0–3", spec.replace("0-3", "0–3"))
        self.assertIn("teach", spec.lower())


if __name__ == "__main__":
    unittest.main()
