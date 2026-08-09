# Echo Lattice — Systems Depth v2 (deltas)

**Doc ID:** `docs/ECHO_LATTICE/02_SYSTEMS_V2.md`  
**Status:** Implementation-ready delta over [`02_SYSTEMS.md`](02_SYSTEMS.md) v1.0.  
**Code authority:** `game/echo_lattice/` on branch `cursor/echo-lattice-systems-v2`.  
**Provenance:** Extends habit engine (PR #47) operators/engine and the playable slice (PR #48) transform fantasy (`mirror_*`, `rotate_180`, `thicken`). Does **not** mash other genres — every addition is habit → geometry.

If this delta and `02_SYSTEMS.md` disagree on a v2 topic below, **this delta wins**. Everything not listed here still follows v1.0.

---

## 0. Why v2

v1 shipped five habit operators + four transform specs, BFS solvability, and a soft/hard dial on paper. Systems Depth v2 makes the addiction/mastery loop *feelable*:

1. **Readable foreshadow** — every rewrite carries a telegraph.
2. **Learnable counterplay** — soft rewrites reverse under observable play.
3. **Combo chains** — a second rewrite can react to the first in one motif beat.
4. **Anti softlock BFS** — solvability plus bottleneck / player-exit / path-growth ceilings.
5. **Greedy risk/reward** — `greed_index` densifies scars when the player farms habits.

Tagline unchanged: **Habits fossilize into maze geometry.**

---

## 1. Operator catalog (11)

| # | Name | Hardness | Telegraph | Counterplay | `reacts_to` |
|---|---|---|---|---|---|
| O1 | `fossilize_hot_cell` | hard | cell(s) | none | — |
| O2 | `place_deflector` | soft | cell + arrow | 5 perp moves | — |
| O3 | `carve_shortcut` | soft | cell | 3 away-from-axis | `place_deflector` |
| O4 | `grow_wall_far_from_path` | soft | cell | 3 undos | — |
| O5 | `widen_hot_corridor` | soft | cell | re-enter widened cell ×3 | `fossilize_hot_cell` |
| O6 | `mirror_walked_v` | soft | cells → `ECHO_WALL` | into mirrored region ×3 | — |
| O7 | `mirror_walked_h` | soft | cells → `ECHO_WALL` | into mirrored region ×3 | — |
| O8 | `rotate_walked_180` | soft | cells → `ECHO_WALL` | into rotated region ×3 | — |
| O9 | `thicken_walked` | hard | cells → `FOSSIL` | none | — |
| O10 | `echo_wisp` | soft | cell → `WISP` | walk through ×1 | `place_deflector` |
| O11 | `seal_backtrack` | hard | cell → `ECHO_WALL` | none | — |

O6–O9 are the 2-D analogues of playable #48 transforms. O10–O11 are new habit-driven depth.

### 1.1 Rewrite value (v2 shape)

```
Rewrite := {
  name, score, patches, meta,          # v1 fields
  hardness: "soft"|"hard",
  telegraph: {kind, cells, dir?, banner},
  counterplay: {kind, threshold, axis?, cells?, cell?},
  reacts_to: PackedStringArray         # combo antecedents
}
```

### 1.2 Greedy magnitude (O1 / O9)

- `greed_index ≥ 0.65` may fossilize the **top-2** hot cells (O1).
- O9 `thicken_walked` keep-count scales with `greed_index` (low greed → hottest cell only; high greed → denser walk solidification).

---

## 2. Lattice cell additions

| Cell | ASCII | Passable | Role |
|---|---|---|---|
| `ECHO_WALL` | `E` | no | Mirror/rotate/seal scars (distinct from authored `#` and fossil `*`) |
| `CHECKPOINT` | `C` | yes | First entry fires rewrite pipeline |
| `CHECKPOINT_USED` | `c` | yes | Spent checkpoint |
| `WISP` | `w` | yes (once) | Dissolves to `FLOOR` on exit |

`Lattice.is_wall` treats `WALL | FOSSIL | ECHO_WALL` as wall-like. `fossil_density()` = FOSSIL + ECHO_WALL counts.

---

## 3. HabitSignature additions

| Field | Maps to | Notes |
|---|---|---|
| `density_slope` | H6 | New-cell discovery rate over the motif window |
| `undo_rate` | H7 | `undo_count / steps` via append-only undo trail |
| `echo_depth` | H8 | Longest consecutive backtrack streak |
| `hot_dominance` | D3 | Top visit count / total steps |
| `greed_index` | R1 | `0.25·tidy + 0.25·grow + 0.20·hot + 0.30·bias` ∈ [0,1] |
| `fingerprint()` | — | 64-bit FNV-1a over quantized fields |

`PathRecorder` gains `record_undo()`, `undo_count`, `undo_flags`, and `record_motif_boundary()`.

---

## 4. Anti softlock BFS oracle

`LatticeBFS` gains:

- `goal_bottleneck_width(L)` — reachable passable neighbours of goal
- `player_exits(L, pos)` — passable neighbours that still reach goal
- `safety(L, pos)` — `{path_len, bottleneck, player_exits}`

`RewriteEngine._check_safety` rejects a candidate when any of:

1. not `is_solvable`
2. player stranded (`shortest_path(player→goal)` empty)
3. `bottleneck < min_bottleneck`
4. `player_exits < min_player_exits`
5. `path_len > baseline_len * max_length_factor` (default 1.5)

**Near-miss:** a *committed* rewrite with `bottleneck ≤ 1` or `player_exits ≤ 1` sets `EngineResult.near_miss = true` (clip-worthy “almost sealed” beat). Softlock remains impossible: rejected candidates never commit.

Mode presets (`Config.for_mode`):

| Mode | `min_bottleneck` | `min_player_exits` | `max_length_factor` | `soft_hard_bias` |
|---|---|---|---|---|
| reader | 2 | 2 | 1.25 | 0.35 |
| standard | 1 | 1 | 1.5 | 0.5 |
| cold | 1 | 1 | 2.0 | 0.75 |

---

## 5. Soft / hard adaptation (runtime)

- Defaults from `RewriteOperators.HARDNESS`.
- Soft magnitude retention ≈ `soft_hard_bias` (+ reader/cold scale) + `0.3 * greed_index`, keeping top patches.
- Hard ops keep full magnitude.
- `ChamberRuntime` enforces active-rewrite **cap**: oldest soft auto-reverses; hard retires from counting but stays applied.
- Counterplay kinds: `perpendicular_moves`, `away_from_axis`, `undo_burst`, `re_enter`, `walk_through`, `into_region`, `none`.

Telegraph flow: `checkpoint()` → `signal_telegraph` + `pending_telegraph` → `commit_telegraphed()` (or auto-commit on next `move`). Always fair; never surprise.

---

## 6. Combo chains

After a primary commit, `_try_combo` scans remaining candidates whose `reacts_to` contains the applied name, boosts by `combo_bonus` (default 0.6), re-checks safety on the post-commit lattice, and commits at most **one** chain rewrite into `EngineResult.combo`.

Shipped react edges:

- `carve_shortcut` → after `place_deflector`
- `widen_hot_corridor` → after `fossilize_hot_cell`
- `echo_wisp` → after `place_deflector`

---

## 7. ChamberRuntime

New pure module `chamber_runtime.gd` stitches move / undo / checkpoint / telegraph / counterplay / wisp dissolve / win. Suitable for the playable vertical slice to adopt without scene-tree coupling.

---

## 8. Acceptance tests (v2)

Headless:

```bash
godot --headless --path game --script res://echo_lattice/tests/run_tests.gd
godot --headless --path game --script res://echo_lattice/demo/demo_smoke.gd
```

Suites cover: 11-op registry + telegraph/counterplay metadata, greed magnitude, combo react edges, safety rejection, near-miss flag, chamber telegraph → commit → reverse, determinism under fixed RNG seed.

---

## 9. File map

```
game/echo_lattice/
├── lattice.gd              # +ECHO_WALL/CHECKPOINT/WISP, fossil_density
├── bfs.gd                  # +goal_bottleneck_width, player_exits, safety
├── path_recorder.gd        # +undo trail, motif boundaries
├── habit_signature.gd      # +H6/H7/H8, greed_index, fingerprint
├── rewrite_operators.gd    # 11 ops + telegraph/counterplay/reacts_to
├── rewrite_engine.gd       # safety oracle, soft/hard scale, combo, near-miss
├── chamber_runtime.gd      # NEW — motif loop + counterplay
├── demo/                   # telegraph wash + greed/combo HUD
└── tests/                  # +test_chamber_runtime.gd
docs/ECHO_LATTICE/
├── 02_SYSTEMS.md           # v1.0 (unchanged contract for non-delta topics)
└── 02_SYSTEMS_V2.md        # this delta
```

---

## 10. Changelog

| Version | Notes |
|---|---|
| v2.0 | Systems Depth: 11 ops, telegraph + counterplay, combo chains, soft/hard runtime, anti-softlock BFS + near-miss, greed_index risk/reward. |
