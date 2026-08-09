#!/usr/bin/env python3
"""Headless acceptance tests for Echo Lattice Balance v2.

Mirrors BalanceTuning / HabitArchetype / StarRater contracts without Godot.
Run: python3 game/echo_lattice/tests/test_balance_v2.py
"""

from __future__ import annotations

import json
import math
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = ROOT / "config" / "balance_v2.json"
DOC_PATH = Path(__file__).resolve().parents[3] / "docs" / "ECHO_LATTICE" / "14_BALANCE_V2.md"


def load() -> dict:
    with JSON_PATH.open(encoding="utf-8") as f:
        return json.load(f)


class BalanceV2Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.data = load()

    def test_schema_and_doc_exist(self) -> None:
        self.assertEqual(self.data.get("schema_version"), 2)
        self.assertTrue(JSON_PATH.is_file())
        self.assertTrue(DOC_PATH.is_file(), f"missing {DOC_PATH}")
        doc = DOC_PATH.read_text(encoding="utf-8")
        self.assertIn("one more run", doc.lower())
        self.assertIn("BFS", doc)

    def test_acts_and_escalation(self) -> None:
        acts = self.data["acts"]
        self.assertEqual(set(acts), {"1", "2", "3", "4"})
        expected = {
            "1": ("SEED", "induction", 9),
            "2": ("GROWTH", "reflection", 9),
            "3": ("PRISM", "pressure", 9),
            "4": ("MASTERY", "mastery", 8),
        }
        for aid, (name, content_act, chambers) in expected.items():
            act = acts[aid]
            self.assertEqual(act["name"], name)
            self.assertEqual(act["content_act"], content_act)
            self.assertEqual(act["chambers"], chambers)
            self.assertIn("habit_window", act)
            self.assertIn("rewrite_cap", act)
        # Mastery must not share PRISM numbers with Pressure.
        self.assertNotEqual(acts["3"]["habit_window"], acts["4"]["habit_window"])
        self.assertGreater(acts["4"]["soft_hard_bias"], acts["3"]["soft_hard_bias"])
        esc = self.data["difficulty_curve"]["chamber_escalation"]
        pairs = {(e["act"], e["index"]) for e in esc}
        for act, count in ((1, 9), (2, 9), (3, 9), (4, 8)):
            for idx in range(count):
                self.assertIn((act, idx), pairs)
        # Monotone non-decreasing within each act
        for act in (1, 2, 3, 4):
            rels = [e["relative"] for e in esc if e["act"] == act]
            self.assertEqual(rels, sorted(rels))
        rates = self.data["difficulty_curve"]["ideal_clear_rate_by_act"]
        self.assertEqual(set(rates), {"1", "2", "3", "4"})
        self.assertGreater(rates["3"], rates["4"])

    def test_modes_budgets(self) -> None:
        modes = self.data["modes"]
        self.assertEqual(modes["reader"]["undo_budget_per_chamber"], -1)
        self.assertEqual(modes["reader"]["rewind_budget_per_chamber"], -1)
        self.assertEqual(modes["standard"]["rewind_budget_per_chamber"], 5)
        self.assertEqual(modes["cold"]["rewind_budget_per_chamber"], 2)
        self.assertLess(
            modes["cold"]["tempo_multiplier"], modes["standard"]["tempo_multiplier"]
        )

    def test_archetypes_present(self) -> None:
        arch = self.data["habit_archetypes"]
        for key in ("right_leaner", "looper", "zigzagger", "balanced"):
            self.assertIn(key, arch)
            self.assertTrue(arch[key]["counters"])
            ops = {c["op"] for c in arch[key]["counters"]}
            self.assertTrue(ops)

    def test_classify_right_leaner(self) -> None:
        self.assertEqual(
            classify(
                {
                    "total_steps": 20,
                    "unique_cells": 16,
                    "dominant_bias": 0.6,
                    "turn_rate": 0.2,
                    "backtrack_rate": 0.05,
                    "straight_streaks": [8, 3, 2],
                },
                self.data,
            ),
            "right_leaner",
        )

    def test_classify_looper(self) -> None:
        self.assertEqual(
            classify(
                {
                    "total_steps": 30,
                    "unique_cells": 12,
                    "dominant_bias": 0.3,
                    "turn_rate": 0.4,
                    "backtrack_rate": 0.25,
                    "straight_streaks": [3, 2, 2],
                },
                self.data,
            ),
            "looper",
        )

    def test_classify_zigzagger(self) -> None:
        self.assertEqual(
            classify(
                {
                    "total_steps": 24,
                    "unique_cells": 20,
                    "dominant_bias": 0.28,
                    "turn_rate": 0.7,
                    "backtrack_rate": 0.1,
                    "straight_streaks": [2, 2, 1],
                },
                self.data,
            ),
            "zigzagger",
        )

    def test_classify_short_path_balanced(self) -> None:
        self.assertEqual(
            classify(
                {
                    "total_steps": 4,
                    "unique_cells": 4,
                    "dominant_bias": 0.9,
                    "turn_rate": 0.0,
                    "backtrack_rate": 0.0,
                    "straight_streaks": [4],
                },
                self.data,
            ),
            "balanced",
        )

    def test_stars_ordering(self) -> None:
        three, two = star_cuts(bfs_len=20, act_id=1, mode_id="standard", data=self.data)
        self.assertLessEqual(three, two)
        self.assertEqual(rate_stars(5, 20, 1, "standard", self.data), 3)
        self.assertEqual(rate_stars(two, 20, 1, "standard", self.data), 2)
        self.assertEqual(rate_stars(two + 50, 20, 1, "standard", self.data), 1)

    def test_tempo_formula(self) -> None:
        # act2, 2 checkpoints, standard
        act = self.data["acts"]["2"]
        mode = self.data["modes"]["standard"]
        expected = math.floor(
            (act["tempo_base"] + act["tempo_per_checkpoint"] * 2 + 12 * (2 - 1))
            * mode["tempo_multiplier"]
        )
        self.assertEqual(tempo_for(2, 2, "standard", self.data), expected)

    def test_anti_frustration_bfs_invariant(self) -> None:
        af = self.data["anti_frustration"]
        self.assertTrue(af["no_game_over"])
        ns = af["never_softlock"]
        self.assertTrue(ns["reject_unsolvable"])
        self.assertEqual(ns["fallback_when_exhausted"], "keep_previous_lattice")
        self.assertIn("LatticeBFS.is_solvable", ns["invariant"])

    def test_telemetry_local_only(self) -> None:
        tel = self.data["telemetry"]
        self.assertTrue(tel["path"].startswith("user://"))
        self.assertEqual(tel["sink"], "local_jsonl")
        self.assertFalse(tel["include_pii"])
        self.assertIn("softlock_assert_failed", tel["events"])
        self.assertIn("one_more_run_proxy", tel["aggregates_for_tuning"])

    def test_hard_ops_act1_gated(self) -> None:
        act1 = self.data["acts"]["1"]
        self.assertFalse(act1["hard_ops_enabled"])
        self.assertEqual(act1["hard_ops_unlock_chamber_index"], 4)
        hard = set(self.data["rewrite_engine"]["hard_ops"])
        self.assertIn("fossilize_hot_cell", hard)


def classify(sig: dict, data: dict) -> str:
    cfg = data["habit_archetypes"]
    min_steps = cfg["classifier_window_min_steps"]
    margin = cfg["confidence_margin"]
    total = sig["total_steps"]
    if total < min_steps:
        return "balanced"
    unique = sig["unique_cells"]
    feats = {
        "dominant_bias": sig["dominant_bias"],
        "turn_rate": sig["turn_rate"],
        "backtrack_rate": sig["backtrack_rate"],
        "longest_streak": sig["straight_streaks"][0] if sig["straight_streaks"] else 0,
        "unique_ratio": unique / total if total else 1.0,
        "revisit_ratio": max(0, total - unique) / total if total else 0.0,
    }
    scores = {
        "right_leaner": _score_right(feats, cfg["right_leaner"]["detect"]),
        "looper": _score_looper(feats, cfg["looper"]["detect"]),
        "zigzagger": _score_zig(feats, cfg["zigzagger"]["detect"]),
    }
    ordered = sorted(scores.items(), key=lambda kv: kv[1], reverse=True)
    best_id, best = ordered[0]
    second = ordered[1][1] if len(ordered) > 1 else 0.0
    if best < 1.0 or (best - second) < margin:
        return "balanced"
    return best_id


def _score_right(f: dict, d: dict) -> float:
    s = 0.0
    if f["dominant_bias"] >= d["dominant_bias_min"]:
        s += 0.45
    if f["turn_rate"] <= d["turn_rate_max"]:
        s += 0.25
    if f["backtrack_rate"] <= d["backtrack_rate_max"]:
        s += 0.15
    if f["longest_streak"] >= d["longest_streak_min"]:
        s += 0.25
    return s


def _score_looper(f: dict, d: dict) -> float:
    s = 0.0
    if f["unique_ratio"] <= d["unique_ratio_max"]:
        s += 0.35
    if f["revisit_ratio"] >= d["revisit_ratio_min"]:
        s += 0.35
    if f["backtrack_rate"] >= d["backtrack_rate_min"]:
        s += 0.2
    if f["turn_rate"] >= d["turn_rate_min"]:
        s += 0.15
    return s


def _score_zig(f: dict, d: dict) -> float:
    s = 0.0
    if f["turn_rate"] >= d["turn_rate_min"]:
        s += 0.4
    if f["dominant_bias"] <= d["dominant_bias_max"]:
        s += 0.25
    if f["backtrack_rate"] <= d["backtrack_rate_max"]:
        s += 0.15
    if f["longest_streak"] <= d["longest_streak_max"]:
        s += 0.25
    return s


def star_cuts(bfs_len: int, act_id: int, mode_id: str, data: dict) -> tuple[int, int]:
    stars = data["stars"]
    padding = stars["bfs_par_padding"]
    bfs_par = max(1, bfs_len) + padding
    act_mult = data["acts"][str(act_id)]["star_par_multiplier"]
    mode_slack = data["modes"][mode_id]["star_slack"]
    three_m = stars["thresholds"]["three_star_mult"]
    two_m = stars["thresholds"]["two_star_mult"]
    three = math.ceil(bfs_par * three_m * act_mult * mode_slack)
    two = math.ceil(bfs_par * two_m * act_mult * mode_slack)
    if three > two:
        three = two
    return three, two


def rate_stars(moves: int, bfs_len: int, act_id: int, mode_id: str, data: dict) -> int:
    three, two = star_cuts(bfs_len, act_id, mode_id, data)
    stars = 1
    if moves <= two:
        stars = 2
    if moves <= three:
        stars = 3
    return stars


def tempo_for(act_id: int, checkpoint_count: int, mode_id: str, data: dict) -> int:
    act = data["acts"][str(act_id)]
    mode = data["modes"][mode_id]
    return math.floor(
        (act["tempo_base"] + act["tempo_per_checkpoint"] * checkpoint_count + 12 * (act_id - 1))
        * mode["tempo_multiplier"]
    )


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(BalanceV2Tests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    sys.exit(0 if result.wasSuccessful() else 1)
