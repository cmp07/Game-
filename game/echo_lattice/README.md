# Echo Lattice — Godot 4 test bed

This directory holds the **MVP-of-the-MVP** for Echo Lattice: just
enough Godot 4 project scaffolding to house the pure-logic modules
(`src/`) and the automated QA suite (`tests/`). No scenes, art, or
input maps live here yet — those land once the product lane is locked
per [`docs/GAME_PLAN.md`](../../docs/GAME_PLAN.md).

The single source of truth for what these modules are *for* is
[`docs/ECHO_LATTICE/09_QA.md`](../../docs/ECHO_LATTICE/09_QA.md).

## Layout

| Path | Purpose |
|---|---|
| `project.godot` | Minimal Godot 4 project so `class_name` and imports resolve. |
| `src/lattice.gd` | Grid data structure with glyph I/O and structural validation. |
| `src/move_buffer.gd` | Bounded ring of recent moves; canonical hash + habit stats. |
| `src/habit_profile.gd` | Classifies a `MoveBuffer` into DASH_HEAVY / LOOPY / HESITANT / NEUTRAL. |
| `src/solver.gd` | BFS reachability and shortest-path over a `Lattice`. |
| `src/grammar.gd` | Pure rewrite transforms + `safe_apply` / `apply_deck` wrappers. |
| `src/generator.gd` | (seed, buffer) → solvable `Lattice`. |
| `tests/test_base.gd` | Tiny assertion + reporting harness; GUT-shaped API. |
| `tests/test_runner.gd` | Headless entry point; walks the manifest, exits non-zero on failure. |
| `tests/run_tests.sh` | Shell wrapper that runs the headless suite. |
| `tests/test_*.gd` | The actual test cases — see `09_QA.md` §3 for the matrix. |

## Running the tests

```bash
# One time: build the global class cache.
godot4 --headless --import .

# Any time thereafter.
./tests/run_tests.sh
```

Expected tail:

```
Totals: 42/42 passed (0 failed) in ~0.4s
```

Exit code is `0` on green, `1` on any failure. Set `GODOT` in the
environment to point at a specific Godot binary if `godot4` is not on
`PATH`.

## Optional: running under GUT

The tests are written to be portable to [GUT](https://github.com/bitwes/Gut).
See `09_QA.md` §2.2 for the two-line switch.
