#!/usr/bin/env python3
"""Headless tests for Echo Lattice performance pools + grid (no Godot required)."""

from __future__ import annotations

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # game/echo_lattice
REPO = ROOT.parents[1]
DOC = REPO / "docs" / "ECHO_LATTICE" / "10_PERFORMANCE.md"


# --- Pure-Python mirrors of hot-path algorithms ---------------------------------

class ObjectPoolPy:
    def __init__(self, factory, cap: int, prewarm: int = 0) -> None:
        self.cap = max(1, cap)
        self.factory = factory
        self.free: list = []
        self.live: list = []
        self.instantiate_count = 0
        self.acquire_count = 0
        self.release_count = 0
        self.steal_count = 0
        while len(self.free) + len(self.live) < prewarm and self.total() < self.cap:
            self.free.append(self._create())

    def total(self) -> int:
        return len(self.free) + len(self.live)

    def _create(self):
        self.instantiate_count += 1
        return self.factory()

    def acquire(self):
        if self.free:
            item = self.free.pop()
        elif self.total() < self.cap:
            item = self._create()
        else:
            item = self.live.pop(0)
            self.steal_count += 1
        self.live.append(item)
        self.acquire_count += 1
        return item

    def release(self, item) -> None:
        if item not in self.live:
            return
        self.live.remove(item)
        self.free.append(item)
        self.release_count += 1

    def release_all(self) -> None:
        while self.live:
            self.release(self.live[-1])


class LogicalGridPy:
    EMPTY, FLOOR, WALL, KEY = 0, 1, 2, 3

    def __init__(self, w: int, h: int, fill: int = 0) -> None:
        assert 0 < w <= 64 and 0 < h <= 64
        self.width = w
        self.height = h
        self.cells = bytearray([fill] * (w * h))
        self.scratch = bytearray(self.cells)
        self.dirty_min = (0, 0)
        self.dirty_max = (-1, -1)
        self.key_count = 0

    def idx(self, x: int, y: int) -> int:
        return y * self.width + x

    def has_dirty(self) -> bool:
        return self.dirty_max[0] >= self.dirty_min[0] and self.dirty_max[1] >= self.dirty_min[1]

    def _mark(self, x: int, y: int) -> None:
        if not self.has_dirty():
            self.dirty_min = (x, y)
            self.dirty_max = (x, y)
            return
        self.dirty_min = (min(self.dirty_min[0], x), min(self.dirty_min[1], y))
        self.dirty_max = (max(self.dirty_max[0], x), max(self.dirty_max[1], y))

    def set_cell(self, x: int, y: int, kind: int) -> None:
        i = self.idx(x, y)
        prev = self.cells[i]
        if prev == kind:
            return
        if prev == self.KEY:
            self.key_count -= 1
        if kind == self.KEY:
            self.key_count += 1
        self.cells[i] = kind
        self._mark(x, y)

    def dirty_rect(self):
        if not self.has_dirty():
            return None
        x0, y0 = self.dirty_min
        x1, y1 = self.dirty_max
        return (x0, y0, x1 - x0 + 1, y1 - y0 + 1)

    def clear_dirty(self) -> None:
        self.dirty_min = (0, 0)
        self.dirty_max = (-1, -1)

    def begin_rewrite(self) -> None:
        self.scratch = bytearray(self.cells)

    def set_scratch(self, x: int, y: int, kind: int) -> None:
        self.scratch[self.idx(x, y)] = kind
        self._mark(x, y)

    def commit_rewrite(self) -> None:
        self.cells, self.scratch = self.scratch, self.cells
        self.key_count = sum(1 for b in self.cells if b == self.KEY)

    def hash_cells(self) -> int:
        h = 2166136261
        for b in self.cells:
            h ^= b
            h = (h * 16777619) & 0xFFFFFFFF
        h ^= self.width
        h = (h * 16777619) & 0xFFFFFFFF
        h ^= self.height
        h = (h * 16777619) & 0xFFFFFFFF
        return h

    def bake_dirty(self, sink: dict) -> int:
        rect = self.dirty_rect()
        if not rect:
            return 0
        x0, y0, w, h = rect
        n = 0
        for y in range(y0, y0 + h):
            for x in range(x0, x0 + w):
                sink[(x, y)] = self.cells[self.idx(x, y)]
                n += 1
        self.clear_dirty()
        return n


# --- Tests --------------------------------------------------------------------

class TestSourceSurface(unittest.TestCase):
    REQUIRED = [
        "src/perf/perf_budget.gd",
        "src/perf/frame_profiler.gd",
        "src/util/object_pool.gd",
        "src/vfx/pooled_fossil.gd",
        "src/vfx/fossil_pool.gd",
        "src/vfx/pooled_vfx.gd",
        "src/vfx/vfx_pool.gd",
        "src/grid/grid_types.gd",
        "src/grid/logical_grid.gd",
        "src/grid/grid_bake.gd",
    ]

    def test_files_exist(self) -> None:
        missing = [p for p in self.REQUIRED if not (ROOT / p).is_file()]
        self.assertEqual(missing, [])

    def test_doc_exists(self) -> None:
        self.assertTrue(DOC.is_file())
        text = DOC.read_text()
        for needle in (
            "60 fps",
            "1080p",
            "FossilPool",
            "VfxPool",
            "LogicalGrid",
            "Profiling checklist",
            "steal-oldest",
            "Dirty AABB",
            "PerfBudget",
        ):
            self.assertIn(needle, text)


class TestPerfBudgetConstants(unittest.TestCase):
    def setUp(self) -> None:
        self.src = (ROOT / "src" / "perf" / "perf_budget.gd").read_text()

    def test_caps(self) -> None:
        def const_int(name: str) -> int:
            m = re.search(rf"const {name} := (\d+)", self.src)
            self.assertIsNotNone(m, name)
            return int(m.group(1))

        self.assertEqual(const_int("TARGET_FPS"), 60)
        self.assertEqual(const_int("MAX_FOSSILS_LIVE"), 256)
        self.assertEqual(const_int("MAX_PARTICLES_LIVE"), 200)
        self.assertEqual(const_int("MAX_GRID_WIDTH"), 64)
        self.assertEqual(const_int("MAX_GRID_HEIGHT"), 64)
        self.assertEqual(const_int("FOSSIL_PREWARM"), 64)


class TestObjectPoolPy(unittest.TestCase):
    def test_prewarm_and_reuse_without_extra_instantiate(self) -> None:
        pool = ObjectPoolPy(factory=dict, cap=8, prewarm=4)
        self.assertEqual(pool.instantiate_count, 4)
        a = pool.acquire()
        pool.release(a)
        b = pool.acquire()
        self.assertIs(a, b)
        self.assertEqual(pool.instantiate_count, 4)

    def test_steal_oldest_at_cap(self) -> None:
        seq = {"n": 0}

        def factory():
            seq["n"] += 1
            return {"id": seq["n"]}

        pool = ObjectPoolPy(factory=factory, cap=3, prewarm=0)
        x = pool.acquire()
        y = pool.acquire()
        z = pool.acquire()
        self.assertEqual(pool.instantiate_count, 3)
        stolen = pool.acquire()
        self.assertEqual(pool.steal_count, 1)
        self.assertIs(stolen, x)
        self.assertEqual(pool.live[0], y)
        self.assertIn(z, pool.live)


class TestLogicalGridPy(unittest.TestCase):
    def test_dirty_rect_is_local(self) -> None:
        g = LogicalGridPy(16, 16, fill=LogicalGridPy.FLOOR)
        g.clear_dirty()
        g.set_cell(4, 5, LogicalGridPy.WALL)
        g.set_cell(6, 7, LogicalGridPy.WALL)
        self.assertEqual(g.dirty_rect(), (4, 5, 3, 3))
        sink: dict = {}
        written = g.bake_dirty(sink)
        self.assertEqual(written, 9)
        self.assertFalse(g.has_dirty())
        self.assertEqual(sink[(4, 5)], LogicalGridPy.WALL)
        self.assertNotIn((0, 0), sink)

    def test_double_buffer_rewrite(self) -> None:
        g = LogicalGridPy(4, 4, fill=LogicalGridPy.FLOOR)
        g.set_cell(1, 1, LogicalGridPy.WALL)
        g.clear_dirty()
        g.begin_rewrite()
        # mirror walls horizontally into scratch
        for y in range(4):
            for x in range(4):
                src = g.cells[g.idx(x, y)]
                g.set_scratch(3 - x, y, src)
        g.commit_rewrite()
        self.assertEqual(g.cells[g.idx(2, 1)], LogicalGridPy.WALL)
        self.assertEqual(g.cells[g.idx(1, 1)], LogicalGridPy.FLOOR)

    def test_hash_stable(self) -> None:
        a = LogicalGridPy(3, 2, fill=1)
        b = LogicalGridPy(3, 2, fill=1)
        self.assertEqual(a.hash_cells(), b.hash_cells())
        b.set_cell(0, 0, LogicalGridPy.WALL)
        self.assertNotEqual(a.hash_cells(), b.hash_cells())

    def test_key_counter(self) -> None:
        g = LogicalGridPy(4, 4, fill=LogicalGridPy.FLOOR)
        g.set_cell(0, 0, LogicalGridPy.KEY)
        g.set_cell(1, 0, LogicalGridPy.KEY)
        self.assertEqual(g.key_count, 2)
        g.set_cell(0, 0, LogicalGridPy.FLOOR)
        self.assertEqual(g.key_count, 1)


class TestFossilPoolContract(unittest.TestCase):
    def test_fossil_pool_mentions_a11y_provider(self) -> None:
        src = (ROOT / "src" / "vfx" / "fossil_pool.gd").read_text()
        self.assertIn("set_style_provider", src)
        self.assertIn("steal", (ROOT / "src" / "util" / "object_pool.gd").read_text().lower())
        self.assertIn("MAX_FOSSILS_LIVE", src)

    def test_vfx_reduce_fx_gate(self) -> None:
        src = (ROOT / "src" / "vfx" / "vfx_pool.gd").read_text()
        self.assertIn("reduce_fx", src)
        self.assertIn("MAX_PARTICLES_LIVE", src)
        self.assertIn("play_rewrite", src)


class TestGridBakeContract(unittest.TestCase):
    def test_staged_bake_api(self) -> None:
        src = (ROOT / "src" / "grid" / "grid_bake.gd").read_text()
        for needle in ("begin_staged", "poll_stage", "dirty", "PerfBudget.REWRITE_COMPUTE_MS"):
            self.assertIn(needle, src)


if __name__ == "__main__":
    raise SystemExit(unittest.main())
