#!/usr/bin/env python3
"""Validate Echo Lattice playable v2 chamber JSON.

Checks schema-ish structure, glyphs, BFS reachability, and rewrite playthrough
(mirrors chamber.gd safety-net semantics). Stdlib only.
"""
from __future__ import annotations

import json
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
CHAMBERS_DIR = CONTENT / "chambers"
GRID_W, GRID_H = 24, 14
TRANSFORMS = {
    "none",
    "mirror_v",
    "mirror_h",
    "rotate_180",
    "thicken",
    "mirror_v_then_h",
    "invert",
}
ACTS = {"induction", "reflection", "pressure", "mastery"}


def find_glyph(rows, glyph):
    return [(x, y) for y, row in enumerate(rows) for x, ch in enumerate(row) if ch == glyph]


def pad_rows(rows):
    out = []
    for r in rows:
        r = str(r)
        if len(r) < GRID_W:
            r = r + (" " * (GRID_W - len(r)))
        out.append(r[:GRID_W])
    return out


def bfs(rows, start, goal, blocked=None):
    blocked = blocked or set()
    q = deque([start])
    seen = {start}
    while q:
        x, y = q.popleft()
        if (x, y) == goal:
            return True
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if not (0 <= n[0] < GRID_W and 0 <= n[1] < GRID_H):
                continue
            if n in seen or n in blocked or rows[n[1]][n[0]] == "#":
                continue
            seen.add(n)
            q.append(n)
    return False


def apply_transform(name, path):
    out = []
    if name == "mirror_v":
        out = [(GRID_W - 1 - x, y) for x, y in path]
    elif name == "mirror_h":
        out = [(x, GRID_H - 1 - y) for x, y in path]
    elif name == "rotate_180":
        out = [(GRID_W - 1 - x, GRID_H - 1 - y) for x, y in path]
    elif name == "thicken":
        out = list(path)
    elif name == "mirror_v_then_h":
        for x, y in path:
            out.append((GRID_W - 1 - x, y))
            out.append((x, GRID_H - 1 - y))
    elif name == "invert":
        on_path = set(path)
        for x, y in path:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (x + dx, y + dy)
                if n not in on_path:
                    out.append(n)
    return out


class Sim:
    WALL, FLOOR, CP, CP_USED, GOAL, ECHO = range(6)

    def __init__(self, rows, transform):
        self.transform = transform
        self.grid = [[self.FLOOR] * GRID_W for _ in range(GRID_H)]
        self.player = (0, 0)
        self.goal = (0, 0)
        self.path = []
        self.triggered = set()
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch == "#":
                    self.grid[y][x] = self.WALL
                elif ch == "P":
                    self.player = (x, y)
                elif ch == "G":
                    self.grid[y][x] = self.GOAL
                    self.goal = (x, y)
                elif ch == "C":
                    self.grid[y][x] = self.CP

    def blocked(self, p, extra=None):
        x, y = p
        if not (0 <= x < GRID_W and 0 <= y < GRID_H):
            return True
        if extra and p in extra:
            return True
        return self.grid[y][x] in (self.WALL, self.ECHO)

    def reachable(self, extra=None):
        q = deque([self.player])
        seen = {self.player}
        while q:
            cur = q.popleft()
            if cur == self.goal:
                return True
            x, y = cur
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (x + dx, y + dy)
                if n in seen or self.blocked(n, extra):
                    continue
                seen.add(n)
                q.append(n)
        return False

    def step(self, d):
        nx, ny = self.player[0] + d[0], self.player[1] + d[1]
        if self.blocked((nx, ny)):
            return False
        self.player = (nx, ny)
        self.path.append(self.player)
        if self.grid[ny][nx] == self.CP and self.player not in self.triggered:
            self.triggered.add(self.player)
            self.grid[ny][nx] = self.CP_USED
            self._rewrite()
        return True

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
        for x, y in pending:
            self.grid[y][x] = self.ECHO
        self.path.clear()

    def bfs_next(self, target):
        if self.player == target:
            return None
        came = {self.player: self.player}
        q = deque([self.player])
        found = False
        while q:
            cur = q.popleft()
            if cur == target:
                found = True
                break
            x, y = cur
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (x + dx, y + dy)
                if n in came or self.blocked(n):
                    continue
                came[n] = cur
                q.append(n)
        if not found:
            return None
        cur = target
        while came[cur] != self.player:
            cur = came[cur]
        return (cur[0] - self.player[0], cur[1] - self.player[1])

    def nearest_cp(self):
        best, best_d = None, 10**9
        for y in range(GRID_H):
            for x in range(GRID_W):
                if self.grid[y][x] == self.CP:
                    d = abs(x - self.player[0]) + abs(y - self.player[1])
                    if d < best_d:
                        best_d, best = d, (x, y)
        return best

    def playthrough(self, max_moves=500):
        for _ in range(max_moves):
            if self.player == self.goal:
                return True
            target = self.nearest_cp() or self.goal
            step = self.bfs_next(target) or self.bfs_next(self.goal)
            if step is None:
                return self.player == self.goal
            if not self.step(step):
                return False
        return self.player == self.goal


def validate_one(path: Path) -> list[str]:
    errs = []
    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        return [f"{path.name}: JSON error {e}"]
    cid = data.get("id", path.stem)
    if cid != path.stem:
        errs.append(f"{path.name}: id {cid!r} != filename stem")
    if data.get("transform") not in TRANSFORMS:
        errs.append(f"{cid}: bad transform")
    if data.get("act") not in ACTS:
        errs.append(f"{cid}: bad act")
    rows = pad_rows(data.get("map") or data.get("lattice", {}).get("cells", []))
    if len(rows) != GRID_H:
        errs.append(f"{cid}: bad height")
        return errs
    ps, gs, cs = find_glyph(rows, "P"), find_glyph(rows, "G"), find_glyph(rows, "C")
    if len(ps) != 1 or len(gs) != 1:
        errs.append(f"{cid}: P/G count P={len(ps)} G={len(gs)}")
        return errs
    if not bfs(rows, ps[0], gs[0]):
        errs.append(f"{cid}: P→G unreachable")
    for c in cs:
        if not bfs(rows, ps[0], c):
            errs.append(f"{cid}: checkpoint {c} unreachable")
    if data.get("transform") != "none" and not cs:
        errs.append(f"{cid}: missing checkpoint")
    cap = int(data.get("rewrite", {}).get("cap", -1))
    # Literacy plates (transform none) may set rewrite.cap = 0 so C arms the
    # buffer without fossils. All other chambers still need cap >= C count.
    literacy_plate = data.get("transform") == "none" and cap == 0
    if cap >= 0 and len(cs) > cap and not literacy_plate:
        errs.append(f"{cid}: rewrite.cap {cap} < checkpoint count {len(cs)}")
    if not Sim(rows, data.get("transform", "none")).playthrough():
        errs.append(f"{cid}: playthrough failed")
    return errs


def hamming(a_rows, b_rows) -> int:
    a = pad_rows(a_rows)
    b = pad_rows(b_rows)
    dist = 0
    for y in range(GRID_H):
        for x in range(GRID_W):
            if a[y][x] != b[y][x]:
                dist += 1
    return dist


def detect_exact_clones(files: list[Path]) -> list[str]:
    """Fail if two distinct chamber ids share identical maps (Hamming 0)."""
    maps: list[tuple[str, list[str]]] = []
    for path in files:
        data = json.loads(path.read_text())
        rows = pad_rows(data.get("map") or data.get("lattice", {}).get("cells", []))
        maps.append((data.get("id", path.stem), rows))
    errs: list[str] = []
    for i, (aid, a) in enumerate(maps):
        for bid, b in maps[i + 1 :]:
            if hamming(a, b) == 0:
                errs.append(f"exact map clone: {aid} == {bid}")
    return errs


def main() -> int:
    files = sorted(CHAMBERS_DIR.glob("*.json"))
    if not files:
        print("no chambers found")
        return 1
    errors = []
    for f in files:
        errors.extend(validate_one(f))
    errors.extend(detect_exact_clones(files))
    # acts.json consistency
    acts_path = CONTENT / "acts.json"
    if acts_path.exists():
        acts = json.loads(acts_path.read_text())
        ids = {f.stem for f in files}
        for a in acts.get("acts", []):
            for cid in a.get("chambers", []) + a.get("hard_variants", []):
                if cid not in ids:
                    errors.append(f"acts.json references missing {cid}")
    daily_path = CONTENT / "daily" / "seeds.json"
    if daily_path.exists():
        daily = json.loads(daily_path.read_text())
        ids = {f.stem for f in files}
        for s in daily.get("seeds", []):
            if s.get("chamber_id") not in ids:
                errors.append(f"daily seed missing chamber {s.get('chamber_id')}")
    print(f"chambers: {len(files)}")
    if errors:
        print("FAIL")
        for e in errors:
            print(" ", e)
        return 1
    print("result: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
