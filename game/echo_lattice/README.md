# Echo Lattice

> **Core fantasy.** The player's movement habits *fossilize* into architecture.
> The maze changes between segments in response to how you moved through it.
> The engine guarantees the maze stays solvable, so every rewrite is fair.

Echo Lattice is a self-contained, unit-testable GDScript module. It has no
scene-tree dependencies and no assets. Drop it into any Godot 4 project and
consume the API from your own scenes.

```
game/echo_lattice/
├── lattice.gd              # 2D grid + Cell enum + ASCII I/O + fingerprint
├── bfs.gd                  # is_solvable, shortest_path, reachable_distances
├── path_recorder.gd        # append-only log of player positions
├── habit_signature.gd      # aggregate movement fingerprint (bias, streaks, wall-hug…)
├── rewrite_operators.gd    # pure functions: (lattice, sig) -> [Rewrite]
├── rewrite_engine.gd       # score-order + BFS-guarded rewrite application
├── demo/
│   ├── chamber.tscn        # Interactive demo. Move with WASD/arrows, SPACE rewrites.
│   ├── chamber.gd
│   └── demo_smoke.gd       # Headless before/after diff, runs in CI.
└── tests/
    ├── test_framework.gd   # Minimal xUnit-style base class
    ├── test_lattice.gd
    ├── test_bfs.gd
    ├── test_path_recorder.gd
    ├── test_habit_signature.gd
    ├── test_rewrite_operators.gd
    ├── test_rewrite_engine.gd
    └── run_tests.gd        # Headless test runner
```

## Data model

### `Lattice`
A row-major 2D grid of `Cell` ints. Cells:

| Cell     | ASCII | Passable | Notes                                |
|----------|-------|----------|--------------------------------------|
| `FLOOR`  | `.`   | yes      | Default walkable tile.               |
| `WALL`   | `#`   | no       | Standard impassable wall.            |
| `START`  | `S`   | yes      | Player spawn. Single per lattice.    |
| `GOAL`   | `G`   | yes      | Success terminal.                    |
| `FOSSIL` | `*`   | no       | Ex-floor frozen by player habit.     |
| `SOFT`   | `:`   | yes      | Decorative walkable overlay.         |

Lattices are cheap to `clone()`, ASCII round-trip via `to_ascii()` /
`Lattice.from_ascii(text)`, and expose a stable `fingerprint()` (FNV-1a-style)
for cache keys and equality checks.

Patches are applied atomically through `apply_patches(Array<{pos,cell}>)`,
which refuses to overwrite the START or GOAL tiles.

### `PathRecorder`
Append-only positional log. Idle ticks collapse. `strict_adjacency` (default
`true`) asserts on non-4-adjacent jumps so downstream signatures don't get
corrupted by teleport bugs. Direct helpers: `directions()`, `visit_counts()`,
`unique_cells()`, `to_data()` / `from_data(dict)`.

### `HabitSignature`
Computed from a recorder + a lattice:

| Field              | Meaning                                                        |
|--------------------|----------------------------------------------------------------|
| `dir_bias`         | Probability distribution over the 4 cardinal directions.       |
| `dominant_dir`     | Argmax of `dir_bias` (deterministic tie-break: U > D > L > R). |
| `dominant_bias`    | Probability mass of `dominant_dir` (0..1).                     |
| `turn_rate`        | Fraction of transitions where direction changed.               |
| `backtrack_rate`   | Fraction of transitions that reversed the previous direction.  |
| `wall_hug`         | Fraction of unique visited cells touching a `WALL` / `FOSSIL`. |
| `hot_cells(k)`     | Top-k visited cells, excluding start/goal, count-desc sorted.  |
| `visit_counts`     | `Dictionary[Vector2i, int]`.                                   |
| `straight_streaks` | Descending lengths of maximal same-direction runs.             |

The signature is read-only after construction and JSON-serializable via
`to_data()`.

### `RewriteOperators`
Each operator is a pure static function `(Lattice, HabitSignature) -> Array<Rewrite>`.
A `Rewrite` is a small dict:

```gdscript
{
    "name": String,          # human-readable operator label
    "score": float,          # higher = more desired
    "patches": Array,        # atomic edits: [{ pos: Vector2i, cell: int }, …]
    "meta": Dictionary,      # diagnostics
}
```

Shipped operators:

| Operator                  | Effect                                                              |
|---------------------------|---------------------------------------------------------------------|
| `fossilize_hot_cell`      | Freezes the player's favourite floor cell into a `FOSSIL`.          |
| `place_deflector`         | Places a `WALL` just past the end of a dominant-direction streak.   |
| `carve_shortcut`          | Opens a `WALL` bordering the dominant axis to reward commitment.    |
| `grow_wall_far_from_path` | Grows walls in unused corridors, away from hot cells.               |
| `widen_hot_corridor`      | If the player hugs walls, opens a perpendicular gap next to hot cells. |

`RewriteOperators.propose_all(lat, sig)` returns the union sorted by score
descending.

### `RewriteEngine`
```gdscript
var res := RewriteEngine.apply(lattice, sig, rng, config)
if res.applied:
    lattice = res.lattice   # a *clone* — input is never mutated
```

The engine:

1. Asks `RewriteOperators.propose_all` for candidates.
2. Filters by `Config.enabled_ops` and `min_score`.
3. Adds a small deterministic jitter (`Config.score_jitter`) for tie-breaks so
   fixed seeds reproduce exactly.
4. Tries candidates in score order. For each:
    * Applies to a *clone*.
    * Rejects if `apply_patches` refuses (start/goal overwrite, OOB, …).
    * Rejects if `LatticeBFS.is_solvable(clone)` is false.
    * Optionally rejects if the new BFS length exceeds the baseline
      (`Config.require_shorter_or_equal`).
5. Commits the first survivor and returns an `EngineResult` describing the
   choice and everything it rejected.

`apply_repeated(...)` chains applications for "age the maze between runs"
scenarios.

## Solvability invariant

Every rewrite that reaches the player has been proved BFS-solvable on a clone
before commit. The engine never mutates the input lattice; on a 1-wide
corridor with no safe edits, `apply()` returns `applied = false` and the
lattice is unchanged.

## Determinism

Given a fixed lattice, a fixed path, and a `RandomNumberGenerator` with a
fixed seed, `RewriteEngine.apply` returns byte-identical output. Operators
themselves are RNG-free; only the engine's tie-break jitter uses the RNG.

## Running

### Interactive demo

```bash
godot --path game
```

Controls:

* **WASD / arrows** – move.
* **SPACE** – hand your current segment's habit to the rewrite engine and
  respawn on a visibly-different chamber.
* **R** – reset the chamber to its authored ASCII.

The HUD shows your current `HabitSignature.summary()` and the list of applied
rewrites. The last rewrite's cells get a red outline.

### Unit tests (headless)

```bash
godot --headless --path game --script res://echo_lattice/tests/run_tests.gd
```

Expect `~167 passed, 0 failed`. Exit code is `0` on success, `1` on any
failure.

### Demo smoke (headless before/after diff)

```bash
godot --headless --path game --script res://echo_lattice/demo/demo_smoke.gd
```

Prints the lattice before and after, plus BFS path length delta. Fails if the
chamber does not change or becomes unsolvable.

## Wiring into your own game

```gdscript
const Lattice          := preload("res://echo_lattice/lattice.gd")
const PathRecorder     := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature   := preload("res://echo_lattice/habit_signature.gd")
const RewriteEngine    := preload("res://echo_lattice/rewrite_engine.gd")

var lattice: Lattice = Lattice.from_ascii(MY_CHAMBER)
var recorder := PathRecorder.new()

# Feed movement:
recorder.record_step(player_grid_pos)

# At the end of a segment / room / run:
var sig := HabitSignature.extract(recorder, lattice)
var res := RewriteEngine.apply(lattice, sig, rng)
if res.applied:
    lattice = res.lattice
    # Re-render the chamber; player spawns at lattice.start.
```

## Design notes

* **Pure data core, thin runtime.** All modules extend `RefCounted`. There
  is nothing to instantiate on the scene tree.
* **Fail loudly, recover cheaply.** `apply_patches` is all-or-nothing.
  `PathRecorder` asserts on non-adjacent jumps in strict mode.
* **Habit → geometry, not habit → dice.** Rewrites are deterministic
  functions of the signature. The RNG only breaks ties.
* **Solvability is a hard invariant.** The engine never lands you in an
  unsolvable state, even under adversarial habit inputs.
