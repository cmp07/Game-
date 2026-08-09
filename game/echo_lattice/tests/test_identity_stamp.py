#!/usr/bin/env python3
"""Headless acceptance tests for identity boss portrait / ledger stamps.

Mirrors IdentityStamp contracts without Godot.
Run: python3 game/echo_lattice/tests/test_identity_stamp.py
"""

from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHAMBERS = ROOT / "content" / "chambers"
SCRIPT = ROOT / "scripts" / "identity_stamp.gd"
WON = ROOT / "scripts" / "chamber_won.gd"
SCENE_HUD = ROOT / "scripts" / "chamber_scene.gd"


def _axis_match(cells: set[tuple[int, int]], vertical: bool) -> float:
    if not cells:
        return 0.0
    xs = [c[0] for c in cells]
    ys = [c[1] for c in cells]
    mid_x = (min(xs) + max(xs)) * 0.5
    mid_y = (min(ys) + max(ys)) * 0.5
    hits = 0
    for x, y in cells:
        if vertical:
            dx = x - mid_x
            mirror = (int(round(mid_x - dx)), y)
        else:
            dy = y - mid_y
            mirror = (x, int(round(mid_y - dy)))
        if mirror in cells:
            hits += 1
    return hits / len(cells)


def _largest_component(cells: set[tuple[int, int]]) -> int:
    seen: set[tuple[int, int]] = set()
    best = 0
    for start in cells:
        if start in seen:
            continue
        q = [start]
        seen.add(start)
        count = 0
        while q:
            cur = q.pop(0)
            count += 1
            x, y = cur
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (x + dx, y + dy)
                if n in cells and n not in seen:
                    seen.add(n)
                    q.append(n)
        best = max(best, count)
    return best


def evaluate(
    echo_cells: list[tuple[int, int]],
    transform_name: str,
    path_unique: int,
    move_count: int,
) -> dict:
    cells = set(echo_cells)
    if not cells:
        symmetry = 0.0
        negative = 0.0
    else:
        want_v = transform_name in (
            "mirror_v",
            "mirror_v_then_h",
            "rotate_180",
            "thicken",
            "invert",
            "none",
        )
        want_h = transform_name in (
            "mirror_h",
            "mirror_v_then_h",
            "rotate_180",
            "thicken",
            "invert",
        )
        if transform_name == "mirror_v":
            want_h = False
        scores = []
        if want_v:
            scores.append(_axis_match(cells, True))
        if want_h:
            scores.append(_axis_match(cells, False))
        symmetry = sum(scores) / len(scores) if scores else 0.0

        xs = [c[0] for c in cells]
        ys = [c[1] for c in cells]
        bw = max(1, max(xs) - min(xs) + 1)
        bh = max(1, max(ys) - min(ys) + 1)
        fill = len(cells) / float(bw * bh)
        fill_score = 1.0 - min(1.0, abs(fill - 0.38) / 0.38)
        cohesion = _largest_component(cells) / float(len(cells))
        aspect = min(bw, bh) / float(max(bw, bh))
        negative = max(0.0, min(1.0, 0.45 * fill_score + 0.40 * cohesion + 0.15 * aspect))

    if move_count <= 0:
        non_thrash = 0.0
    else:
        ratio = path_unique / float(move_count)
        non_thrash = max(0.0, min(1.0, (ratio - 0.35) / 0.55))

    portrait = max(0.0, min(1.0, 0.42 * symmetry + 0.33 * negative + 0.25 * non_thrash))
    if portrait >= 0.72:
        grade = "signed"
        stars = 3
    elif portrait >= 0.45:
        grade = "readable"
        stars = 2
    else:
        grade = "scribble"
        stars = 1
    return {
        "symmetry": symmetry,
        "negative_space": negative,
        "non_thrash": non_thrash,
        "portrait": portrait,
        "grade": grade,
        "portrait_stars": stars,
    }


def merge_stars(move_stars: int, portrait_stars: int) -> int:
    return max(max(1, min(3, move_stars)), max(1, min(3, portrait_stars)))


class IdentityStampTests(unittest.TestCase):
    def test_scripts_present(self) -> None:
        self.assertTrue(SCRIPT.is_file())
        self.assertTrue(WON.is_file())
        self.assertTrue(SCENE_HUD.is_file())
        src = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("class_name IdentityStamp", src)
        self.assertIn("merge_stars", src)
        hud = SCENE_HUD.read_text(encoding="utf-8")
        self.assertIn("habit_sealed", hud)
        self.assertIn("is_habit_identity_visible", hud)
        won = WON.read_text(encoding="utf-8")
        self.assertIn("StampCard", won)
        self.assertIn("last_identity_stamp", won)

    def test_identity_boss_chambers_tagged(self) -> None:
        bosses = [
            "08_identity_induction.json",
            "17_identity_reflection.json",
            "26_identity_pressure.json",
            "33_nameplate.json",
        ]
        for name in bosses:
            path = CHAMBERS / name
            self.assertTrue(path.is_file(), name)
            data = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(data.get("teaches"), "identity", name)
            self.assertTrue(data.get("identity"), name)

    def test_mirror_birth_present(self) -> None:
        path = CHAMBERS / "02_mirror_birth.json"
        self.assertTrue(path.is_file())
        data = json.loads(path.read_text(encoding="utf-8"))
        self.assertEqual(data["slug"], "mirror_birth")

    def test_symmetric_portrait_outranks_scribble(self) -> None:
        # Vertically symmetric face-like blot (~35% bbox fill, one component).
        intentional = [
            (2, 1), (4, 1),
            (1, 2), (2, 2), (4, 2), (5, 2),
            (1, 3), (3, 3), (5, 3),
            (1, 4), (5, 4),
            (2, 5), (3, 5), (4, 5),
            (2, 6), (4, 6),
        ]
        scribble = [(0, 0), (3, 1), (7, 4), (2, 6), (11, 2), (1, 9), (8, 8)]
        good = evaluate(intentional, "mirror_v", path_unique=18, move_count=20)
        bad = evaluate(scribble, "mirror_v", path_unique=8, move_count=28)
        self.assertGreater(good["portrait"], bad["portrait"])
        self.assertGreaterEqual(good["portrait_stars"], 2)
        self.assertEqual(bad["grade"], "scribble")

    def test_merge_stars_takes_better_of_route_and_portrait(self) -> None:
        self.assertEqual(merge_stars(1, 3), 3)
        self.assertEqual(merge_stars(3, 1), 3)
        self.assertEqual(merge_stars(2, 2), 2)

    def test_playable_loader_keeps_identity_fields(self) -> None:
        loader = (ROOT / "scripts" / "chamber_loader.gd").read_text(encoding="utf-8")
        self.assertIn('"identity"', loader)
        self.assertIn('"teaches"', loader)
        self.assertIn('"slug"', loader)

    def test_game_state_wires_stamp(self) -> None:
        gs = (ROOT / "scripts" / "game_state.gd").read_text(encoding="utf-8")
        self.assertIn("last_identity_stamp", gs)
        self.assertIn("habit_identity_unlocked", gs)
        self.assertIn("IdentityStamp.merge_stars", gs)
        chamber = (ROOT / "scripts" / "chamber.gd").read_text(encoding="utf-8")
        self.assertIn("IdentityStamp.should_stamp", chamber)
        self.assertIn("_maybe_reveal_habit_identity", chamber)


if __name__ == "__main__":
    unittest.main()
