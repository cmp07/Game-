# Echo Lattice — Systems Depth v2

> **Core fantasy.** The player's movement habits *fossilize* into architecture.
> The maze changes between segments in response to how you moved through it.
> Every rewrite is BFS-proved fair — solvable, with bottleneck / exit ceilings —
> and soft rewrites advertise telegraph + counterplay before they stick.

Pure-GDScript module (no scene-tree dependencies, no assets). Drop into any
Godot 4.3 project. Base: habit engine (PR #47) + playable transforms (PR #48).
Design deltas: [`docs/ECHO_LATTICE/02_SYSTEMS_V2.md`](../../docs/ECHO_LATTICE/02_SYSTEMS_V2.md).

```
game/echo_lattice/
├── lattice.gd              # grid + Cell enum (+ECHO_WALL/CHECKPOINT/WISP)
├── bfs.gd                  # solvability + bottleneck/exit safety oracle
├── path_recorder.gd        # append-only log (+undo trail, motif boundaries)
├── habit_signature.gd      # H2–H8 + greed_index + fingerprint
├── rewrite_operators.gd    # 11 pure operators w/ telegraph + counterplay
├── rewrite_engine.gd       # score + soft/hard scale + combo + BFS guard
├── chamber_runtime.gd      # move/undo/checkpoint/telegraph/reverse loop
├── demo/
│   ├── chamber.tscn        # interactive demo (WASD, SPACE rewrite, R reset)
│   ├── chamber.gd
│   └── demo_smoke.gd       # headless before/after + greed/combo print
└── tests/                  # headless suites via run_tests.gd
```

## Operator catalog (11)

| Op | Hard | Telegraph | Counterplay |
|---|---|---|---|
| `fossilize_hot_cell` | hard | cell | — |
| `place_deflector` | soft | cell+arrow | 5 perp moves |
| `carve_shortcut` | soft | cell | 3 away-axis |
| `grow_wall_far_from_path` | soft | cell | 3 undos |
| `widen_hot_corridor` | soft | cell | re-enter ×3 |
| `mirror_walked_v` | soft | cells | into region ×3 |
| `mirror_walked_h` | soft | cells | into region ×3 |
| `rotate_walked_180` | soft | cells | into region ×3 |
| `thicken_walked` | hard | cells | — |
| `echo_wisp` | soft | WISP cell | walk through |
| `seal_backtrack` | hard | echo wall | — |

Combo edges: `carve_shortcut`←`place_deflector`, `widen_hot_corridor`←`fossilize_hot_cell`, `echo_wisp`←`place_deflector`.

## Guarantees

1. **Solvability + anti softlock.** Commit requires `is_solvable`, live player→goal path, `goal_bottleneck_width ≥ min_bottleneck`, `player_exits ≥ min_player_exits`, and path length ≤ `baseline * max_length_factor`.
2. **No input mutation.** Engine/operators clone; callers swap results in.
3. **Determinism.** Fixed lattice + path + RNG seed → byte-identical output.
4. **Fair telegraph.** Soft commits expose telegraph cells; `ChamberRuntime` can delay commit until the next move.
5. **Greedy risk/reward.** High `greed_index` densifies fossils / thicken magnitude.

## Running

```bash
# Unit tests
godot --headless --path game --script res://echo_lattice/tests/run_tests.gd

# Headless before/after smoke
godot --headless --path game --script res://echo_lattice/demo/demo_smoke.gd

# Or via wrapper
./game/echo_lattice/check.sh /path/to/godot

# Interactive demo
godot --path game
```
