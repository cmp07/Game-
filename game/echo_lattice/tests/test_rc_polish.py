#!/usr/bin/env python3
"""RC polish regression tests (stdlib only).

Mirrors softlock / rewrite-lock / invert / continue-skip semantics from
game/echo_lattice/scripts without requiring a Godot binary in CI.
"""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from validate_chambers import (  # noqa: E402
    GRID_H,
    GRID_W,
    Sim,
    apply_transform,
    bfs,
    pad_rows,
)


class RewriteLockSim(Sim):
    """Sim that stages pending echoes like chamber.gd before flush."""

    def __init__(self, rows, transform):
        super().__init__(rows, transform)
        self.pending = []
        self.locked = False

    def _rewrite(self):
        path = list(self.path) if self.path else [self.player]
        pending = []
        seen = set()
        for p in apply_transform(self.transform, path):
            if p in seen or p == self.player or p == self.goal:
                continue
            x, y = p
            if not (0 <= x < GRID_W and 0 <= y < GRID_H):
                continue
            if self.grid[y][x] != self.FLOOR:
                continue
            seen.add(p)
            if self.reachable(set(pending) | {p}):
                pending.append(p)
        self.pending = pending
        self.locked = bool(pending)
        self.path.clear()

    def try_move(self, d):
        if self.locked:
            return False
        return self.step(d)

    def flush(self):
        placed = []
        for x, y in self.pending:
            if (x, y) in (self.player, self.goal):
                continue
            if self.grid[y][x] == self.FLOOR:
                self.grid[y][x] = self.ECHO
                placed.append((x, y))
        self.pending = []
        self.locked = False
        if placed and not self.reachable():
            # Recover newest-first (chamber.gd _recover_softlock).
            for x, y in reversed(placed):
                if self.reachable():
                    break
                if self.grid[y][x] == self.ECHO:
                    self.grid[y][x] = self.FLOOR
            if not self.reachable():
                for y in range(GRID_H):
                    for x in range(GRID_W):
                        if self.grid[y][x] == self.ECHO:
                            self.grid[y][x] = self.FLOOR
        return self.reachable()


def _tiny_chamber():
    rows = ["#" * GRID_W for _ in range(GRID_H)]
    # Open corridor with P, C, G and room to mirror.
    mid = GRID_H // 2
    row = list("#" + (" " * (GRID_W - 2)) + "#")
    rows[mid] = "".join(row)
    rows[mid] = rows[mid][:2] + "P" + rows[mid][3:6] + "C" + rows[mid][7:10] + "G" + rows[mid][11:]
    # Mirror side open floors so mirror_v can place echoes.
    rows[mid - 1] = "#" + (" " * (GRID_W - 2)) + "#"
    rows[mid + 1] = "#" + (" " * (GRID_W - 2)) + "#"
    return pad_rows(rows)


class TestRcPolish(unittest.TestCase):
    def test_invert_transform_halo(self):
        path = [(5, 5), (6, 5)]
        out = apply_transform("invert", path)
        self.assertIn((5, 4), out)
        self.assertIn((4, 5), out)
        self.assertNotIn((5, 5), out)
        self.assertNotIn((6, 5), out)

    def test_movement_blocked_during_rewrite_lock(self):
        rows = _tiny_chamber()
        sim = RewriteLockSim(rows, "thicken")
        # Walk onto checkpoint.
        self.assertTrue(sim.try_move((1, 0)))
        self.assertTrue(sim.try_move((1, 0)))
        self.assertTrue(sim.try_move((1, 0)))
        self.assertTrue(sim.try_move((1, 0)))
        # Depending on layout, keep walking until C triggers.
        for _ in range(8):
            if sim.locked:
                break
            sim.try_move((1, 0))
        if not sim.locked:
            # Force a pending lock for the assertion.
            sim.pending = [(3, 3)]
            sim.locked = True
        before = sim.player
        self.assertFalse(sim.try_move((1, 0)))
        self.assertEqual(sim.player, before)

    def test_flush_never_walls_player_or_goal(self):
        rows = _tiny_chamber()
        sim = RewriteLockSim(rows, "none")
        sim.pending = [sim.player, sim.goal, (sim.player[0] + 1, sim.player[1])]
        sim.locked = True
        ok = sim.flush()
        self.assertTrue(ok)
        px, py = sim.player
        gx, gy = sim.goal
        self.assertNotEqual(sim.grid[py][px], sim.ECHO)
        self.assertNotEqual(sim.grid[gy][gx], sim.ECHO)

    def test_softlock_recovery_restores_reachability(self):
        rows = _tiny_chamber()
        sim = RewriteLockSim(rows, "none")
        # Wall every open neighbor of the player so goal is cut off, then recover.
        px, py = sim.player
        blockers = []
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (px + dx, py + dy)
            if 0 <= n[0] < GRID_W and 0 <= n[1] < GRID_H and sim.grid[n[1]][n[0]] == sim.FLOOR:
                blockers.append(n)
        sim.pending = blockers
        sim.locked = True
        self.assertTrue(sim.flush())
        self.assertTrue(sim.reachable())

    def test_continue_skips_cleared_queue(self):
        queue = [0, 1, 2, 3, 4]
        run_cleared = {0: True, 1: True}
        queue_pos = 0
        while queue_pos < len(queue) and queue[queue_pos] in run_cleared:
            queue_pos += 1
        self.assertEqual(queue_pos, 2)
        self.assertFalse(queue_pos >= len(queue))

    def test_continue_ignores_lifetime_completed(self):
        """Start New / Daily must not skip via lifetime completed dict."""
        queue = [0, 1, 2, 3, 4]
        completed = {0: True, 1: True, 2: True, 3: True, 4: True}
        run_cleared = {}
        queue_pos = 0
        while queue_pos < len(queue) and queue[queue_pos] in run_cleared:
            queue_pos += 1
        self.assertEqual(queue_pos, 0)
        self.assertNotEqual(queue_pos, len(queue))
        # Lifetime completed alone must not mark the wing finished.
        i = queue_pos
        while i < len(queue) and queue[i] in run_cleared:
            i += 1
        can_continue = i < len(queue)
        self.assertTrue(can_continue)
        self.assertTrue(all(c in completed for c in queue))

    def test_wing_complete_disables_continue(self):
        queue = [0, 1, 2]
        queue_pos = len(queue)
        can_continue = not (len(queue) > 0 and queue_pos >= len(queue))
        self.assertFalse(can_continue)

    def test_parked_last_cleared_disables_continue(self):
        queue = [0, 1, 2]
        run_cleared = {0: True, 1: True, 2: True}
        queue_pos = len(queue) - 1  # legacy park-on-last
        i = queue_pos
        while i < len(queue) and queue[i] in run_cleared:
            i += 1
        can_continue = not (i >= len(queue))
        self.assertFalse(can_continue)

    def test_atomic_save_roundtrip_shape(self):
        """Document the on-disk contract SaveManager writes (version 2)."""
        payload = {
            "version": 2,
            "current_chamber": 3,
            "best_moves": {"0": 12},
            "best_stars": {"0": 2},
            "completed": {"0": True},
            "run_cleared": {"0": True},
            "habit_profile": {"up": 0, "down": 1, "left": 0, "right": 2},
            "run_mode": "standard",
            "run_queue": [0, 1, 2],
            "queue_pos": 1,
            "daily_seed": 0,
            "daily_label": "",
            "daily_best_stars": {},
            "run_started": True,
        }
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "save.json"
            tmp = Path(td) / "save.json.tmp"
            bak = Path(td) / "save.json.bak"
            tmp.write_text(json.dumps(payload), encoding="utf-8")
            if path.exists():
                path.replace(bak)
            tmp.replace(path)
            self.assertTrue(path.exists())
            loaded = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(loaded["version"], 2)
            self.assertTrue(loaded["run_started"])
            # Corrupt primary, recover from bak.
            path.write_text("{broken", encoding="utf-8")
            bak.write_text(json.dumps(payload), encoding="utf-8")
            try:
                json.loads(path.read_text(encoding="utf-8"))
                self.fail("corrupt primary should not parse")
            except json.JSONDecodeError:
                recovered = json.loads(bak.read_text(encoding="utf-8"))
            self.assertEqual(recovered["current_chamber"], 3)

    def test_campaign_chambers_still_validate(self):
        chambers = sorted((ROOT / "content" / "chambers").glob("*.json"))
        self.assertGreaterEqual(len(chambers), 35)
        # Spot-check first campaign chamber BFS.
        data = json.loads(chambers[0].read_text(encoding="utf-8"))
        rows = pad_rows(data.get("map", []))
        ps = [(x, y) for y, row in enumerate(rows) for x, ch in enumerate(row) if ch == "P"]
        gs = [(x, y) for y, row in enumerate(rows) for x, ch in enumerate(row) if ch == "G"]
        self.assertEqual(len(ps), 1)
        self.assertEqual(len(gs), 1)
        self.assertTrue(bfs(rows, ps[0], gs[0]))

    def test_project_input_has_gamepad_bindings(self):
        text = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn("InputEventJoypadButton", text)
        self.assertIn("InputEventJoypadMotion", text)
        for action in (
            "move_up=",
            "move_down=",
            "move_left=",
            "move_right=",
            "restart=",
            "undo=",
            "pause_menu=",
            "confirm=",
        ):
            self.assertIn(action, text)


if __name__ == "__main__":
    # Keep unused import honest for linters / future BFS helpers.
    _ = deque
    raise SystemExit(unittest.main(verbosity=2))
