# Echo Lattice — Systems Design (v1.0)

**Doc ID:** `docs/ECHO_LATTICE/02_SYSTEMS.md`
**Status:** Implementation-ready. Every subsystem below has: (a) a formal model, (b) reference pseudocode, (c) a serialization schema, (d) numbered acceptance tests.
**Depth v2 delta:** See [`02_SYSTEMS_V2.md`](02_SYSTEMS_V2.md) for the 11-operator catalog with telegraph/counterplay, combo chains, soft/hard runtime, anti-softlock BFS, and greed risk/reward. On v2 topics, the delta wins.
**Companion docs:** [`01_GDD.md`](01_GDD.md) (fantasy, pillars, chamber catalog, tuning surface), [`04_CONTENT_BIBLE.md`](04_CONTENT_BIBLE.md) (chamber authoring). This document is the systems‑layer contract that both stand on.
**Target engine:** Godot 4.3, pure GDScript, headless‑testable. No LLM, no network, no wall‑clock reads inside the sim.
**Design contract:** if this doc and code disagree, this doc is right and the code is a bug. If this doc and the GDD disagree on a *system* detail, this doc wins (systems detail is downstream of fantasy detail). If this doc and `04_CONTENT_BIBLE.md` disagree on chamber file format, the content bible wins.

---

## 0. TL;DR

The player walks a small 2D grid. A **PathRecorder** logs every occupied cell in order. When a **Motif** is completed (a checkpoint reached, a route closed, or a chamber cleared), the **HabitSignature** subsystem reads the last `W` recorded cells and produces an immutable, hashable fingerprint of *how* the player moved. The **RewriteEngine** turns that fingerprint into a small set of candidate lattice edits — walls fossilized, corridors carved, ghosts of the path solidified — proposes them in score order, and applies the first candidate that keeps the maze **solvable** under a BFS solvability oracle. Adaptation strength is throttled by a **soft/hard** knob and a per‑chamber **active‑rewrite cap**. Meta progression is a pure state machine over run records; a **daily seed** mode reroutes the same subsystem stack from a date‑derived deterministic seed. Every subsystem in this document is a **pure function of a bounded input**; there is no wall‑clock, no floating hidden state, no engine coupling.

The tagline the whole document defends is:

> **Habits fossilize into maze geometry.**

Nothing in this document contradicts that. Everything in this document exists to make that literally true, deterministically, in code.

---

## 1. Alignment with the GDD & Habit Engine

This document is deliberately narrower than the GDD's fantasy layer and deliberately wider than the shipped Habit Engine slice. The mapping is spelled out here so no reader has to reconstruct it.

### 1.1 Operational substrate

The GDD (`01_GDD.md §5.6`) enumerates five substrates (Cubic, FCC, Hex‑prism, Diamond, Icosahedral) for a 3‑D crystal fantasy. The **v1.0 playable slice** — the version this document specifies for shipping — runs on **the 2‑D grid substrate** implemented in `game/echo_lattice/lattice.gd`. The 3‑D substrates from the GDD are declared **post‑v1.0**; they are not systems in this document, only reserved names.

The GDD's six verbs (PLACE, EXTEND, ROTATE, PRUNE, ANCHOR, ECHO) collapse cleanly onto the 2‑D walking substrate:

| GDD verb | 2‑D operational equivalent | Notes |
|---|---|---|
| PLACE | *(reserved for level editor only)* | Not a play verb in v1.0. |
| EXTEND | **MOVE (step)** — the player walks one 4‑adjacent cell. | Direction is one of {UP, DOWN, LEFT, RIGHT}. |
| ROTATE | *(reserved)* | No rotation verb in v1.0; rotations occur only in `rotate_180` rewrite operators. |
| PRUNE | **UNDO** — retract the last MOVE. | Costs Tempo; counts against H7 THRASH. |
| ANCHOR | **CHECKPOINT ENTER** (implicit) | Not a player‑chosen verb; automatic on stepping on a `C` cell. |
| ECHO | **REPLAY** (post‑v1.0) | Reserved. Not shipped in v1.0. |

The GDD's H1–H8 metric names are preserved verbatim. Their formulas are re‑expressed against the 2‑D substrate in `§4` below and are **numerically equivalent** on the operational subset the v1.0 slice covers. Nothing that ships as H1 in this document contradicts H1 in the GDD; the formula body is what changes.

### 1.2 Habit Engine (PR #47) authority

The shipped code in `game/echo_lattice/` — `path_recorder.gd`, `habit_signature.gd`, `lattice.gd`, `rewrite_operators.gd`, `rewrite_engine.gd`, `bfs.gd` — is the ground truth for API shape, determinism guarantees, and the five baseline rewrite operators. This document specifies the *systems* those files implement and any extensions (mirror/rotate/thicken operators, chamber grammar loader, meta unlock ledger, daily seed) that will land in follow‑up PRs.

### 1.3 Vertical Slice (PR #48) authority

The shipped scenes in `game/echo_lattice/scenes/` and `game/echo_lattice/scripts/chamber_book.gd` fix the operational fantasy: the player is a small square that walks the grid; walking traces a **ghost trail**; entering a **checkpoint** commits a rewrite; entering the **goal** wins the chamber. This document treats that fantasy as fixed. Any system below that would violate it is a bug.

### 1.4 Content Bible (PR #41) authority

`04_CONTENT_BIBLE.md` owns the chamber file format. This document specifies a **superset** of that format for the movement‑fossilization slice, marked in `§6.4` as backwards‑compatible additions (`transform`, `motifs`, `resonance`, `tempo_start`, `soft_hard_bias`). Chambers authored against the bible schema without those fields load with sensible defaults.

---

## 2. System Overview

### 2.1 Dataflow diagram (text)

```
                +-----------------+           +----------------------+
      input --> |  InputRouter    | --moves-->|   PathRecorder       |
                |  (KBM/gamepad)  |           |  append-only log     |
                +-----------------+           +----------+-----------+
                                                         |
                                                         |  window W
                                                         v
                                              +----------+-----------+
                                              |  HabitSignature      |
                                              |  H1..H8 + derived    |
                                              +----+---------------+-+
                                                   |               ^
                                                   |               | (read-only)
                                                   v               |
                        +--------------------------+---+   +-------+-------+
                        |  RewriteOperators             |   |  Lattice      |
                        |  propose_all() -> candidates  |<--+  (grid data)  |
                        +--------------+----------------+   +-------+-------+
                                       |                            ^
                                       v                            |
                        +---------------------------+               |
                        |  RewriteEngine.apply()    |---clone-------+
                        |  ranks + BFS-verifies     |
                        +--------------+------------+
                                       |
                                       v
                        +------------------------------+
                        |  Chamber (scene)             |
                        |  swaps in new lattice,       |
                        |  clears window, autosaves    |
                        +--------------+---------------+
                                       |
                                       v
                        +------------------------------+
                        |  RunRecord -> SaveService    |
                        |  ledger, unlocks, history    |
                        +------------------------------+
```

Every arrow above is a synchronous function call. Nothing polls, nothing reads wall‑clock time, nothing depends on frame rate.

### 2.2 Simulation ticks

The systems layer runs on **logical ticks**, not frames. A tick is a discrete event, one of:

- `MOVE(dir)` — player commits a step; PathRecorder appends; HabitWindow re‑hashes lazily.
- `UNDO` — retract the last MOVE; PathRecorder pops; undo counter increments.
- `CHECKPOINT(pos)` — automatic on stepping onto a `C` cell; runs the rewrite pipeline.
- `RESET` — restore the chamber to its seed; clear PathRecorder and window.
- `REWIND(snapshot_id)` — restore a prior snapshot.
- `WIN` — goal reached; commit the run to SaveService.
- `TIMEOUT` — Tempo hit zero; chamber enters STALLED.

Frames are irrelevant to logic. The renderer interpolates the visible state; the sim state advances only on the ticks above.

### 2.3 Purity & side‑effect budget

| Layer | Reads | Writes | Wall‑clock | RNG source |
|---|---|---|---|---|
| PathRecorder | prior positions | own positions array | never | never |
| HabitSignature | PathRecorder + Lattice | own fields | never | never |
| RewriteOperators | Lattice + HabitSignature | none (proposes) | never | never |
| RewriteEngine | Lattice + HabitSignature + Config | clone of Lattice | never | injected `RandomNumberGenerator` |
| Chamber scene | Lattice + inputs | own tile grid | never for logic; only for visuals | injected per-chamber |
| SaveService | file | file | never for game logic; only for `audit.last_played_at` | never |
| DailyMode | date string | derived seed | reads system date **once at menu boot** to compute the date; date is then a stable string for the whole day | never |

Only two subsystems ever touch wall‑clock: the audit field in the save (`audit.last_played_at`, never read by the sim) and the DailyMode date resolver (which converts today's date to a seed string once). Neither ever feeds the physics/habit/rewrite loop.

### 2.4 Determinism guarantees (system‑wide)

**Determinism claim:** For any (`Lattice`, `RunSeed`, sequence of `MOVE`/`UNDO` ticks), the final Lattice and final run record are bit‑identical across machines, OS builds, and Godot patch versions ≥ 4.3.

The claim rests on:

- Integer coordinates only. No float coordinates in game logic.
- Deterministic iteration orders (Godot Dictionaries preserve insertion order since 4.2).
- All PRNG usage flows through an injected `RandomNumberGenerator` seeded from the chamber seed (`§10.3`).
- Floats appear only in **scores** (never in state). Scores are compared with `>`, never for equality. Ties break on integer keys (see §4.6, §5.7).
- No transcendentals in the hot path. `sqrt`, `sin`, `cos`, etc. are barred from PathRecorder, HabitSignature, RewriteOperators, RewriteEngine, and LatticeBFS.
- Time is measured in **logical action time**, not milliseconds, for all habit metrics that the GDD wrote in ms. See §4.2.

Every acceptance test at the end of each section includes a **determinism test** that runs the same inputs twice and asserts the outputs are equal.

---

## 3. Path Logging System

### 3.0 System goal

Record, in order, every distinct cell the player occupies during a chamber run, in a shape that is (i) cheap to append, (ii) trivially serialisable, (iii) losslessly reconstructible from disk, and (iv) validated against the substrate (no diagonal jumps, no teleports).

### 3.1 Formal model

Let a **Chamber** be a tuple `(width, height, start, goal, cells)` where `cells: {0,…,width−1}×{0,…,height−1} → CellKind` and `CellKind ∈ { FLOOR, WALL, START, GOAL, FOSSIL, SOFT, CHECKPOINT, CHECKPOINT_USED, ECHO_WALL }`.

A **Path** is a finite sequence `p = ⟨p₀, p₁, …, pₙ⟩` of positions in `ℤ²` satisfying:

1. **Origin.** `p₀ = start` (once the chamber has begun; empty path is legal pre‑move).
2. **Contiguity.** For all `i < n`, `‖pᵢ₊₁ − pᵢ‖₁ = 1` (4‑adjacent step).
3. **No idle duplicates.** For all `i < n`, `pᵢ₊₁ ≠ pᵢ` (idle frames collapse; a paused player does not produce log entries).
4. **Passability.** For all `i`, `cells(pᵢ) ∈ { FLOOR, START, GOAL, SOFT, CHECKPOINT, CHECKPOINT_USED }`. Walking onto `WALL`, `FOSSIL`, or `ECHO_WALL` is rejected by the input router before it reaches PathRecorder.

The **Path Log** is the pair `(p, u)` where `u ∈ ℕ` is the running count of **undo** ticks recorded during the chamber. Undo ticks do not reduce `|p|` (see §3.4 for the rationale on cannonical vs. mutable histories).

### 3.2 Contract (`PathRecorder`)

```
class PathRecorder:
  strict_adjacency: bool                # default true
  positions:        Array<Vector2i>     # append-only; monotonically grows

  clear() -> void
  length() -> int                       # |positions|
  step_count() -> int                   # max(0, |positions| - 1)
  last() -> Vector2i                    # or (-1,-1) if empty
  positions() -> Array<Vector2i>        # defensive copy

  record_step(pos: Vector2i) -> bool
    # Returns true iff a new entry was appended.
    # Panics (assert-fires) if strict_adjacency and step is non-4-adjacent.

  record_move(from: Vector2i, to: Vector2i) -> void
    # Convenience: seeds path[0] if empty, then record_step(to).

  directions() -> Array<Vector2i>
  visit_counts() -> Dictionary<Vector2i,int>
  unique_cells() -> Array<Vector2i>

  to_data() -> Dictionary               # JSON-friendly
  static from_data(d: Dictionary) -> PathRecorder
```

Invariants:

- `positions[i+1] − positions[i]` is one of the four unit vectors when `strict_adjacency` is true.
- `positions` never shrinks except via `clear()`.
- `to_data()` round‑trips: `from_data(r.to_data()).positions() == r.positions()`.

### 3.3 Reference pseudocode

```gdscript
# record_step (from game/echo_lattice/path_recorder.gd; canonical)

func record_step(pos: Vector2i) -> bool:
    if _positions.is_empty():
        _positions.append(pos)
        return true
    var prev := _positions[_positions.size() - 1]
    if prev == pos:
        return false
    if strict_adjacency:
        var d := pos - prev
        assert(absi(d.x) + absi(d.y) == 1, "non-adjacent step")
    _positions.append(pos)
    return true
```

### 3.4 Undo semantics

Undo does **not** delete entries from `positions`. It appends a mirrored step *backwards* to the previous cell, and increments `u` in the containing `PathLog`. Two arguments motivate this:

1. **Habit truth.** A player who thrashes with undo is expressing a habit (H7 THRASH). Erasing undos from the path would erase that signal.
2. **Determinism.** Append‑only logs are easier to replay and hash. A mutable log needs snapshot indexing for equality tests; an append‑only log's hash is a single running FNV.

The chamber may render the visible cursor differently when consecutive undos are detected (subtle red tint), but the recorder is agnostic.

### 3.5 Serialization schema (JSON)

```json
{
  "$schema": "path_log.schema.json",
  "type": "object",
  "required": ["positions", "strict"],
  "properties": {
    "positions": {
      "type": "array",
      "items": {
        "type": "array",
        "minItems": 2,
        "maxItems": 2,
        "items": { "type": "integer" }
      }
    },
    "strict": { "type": "boolean", "default": true },
    "undo_count": { "type": "integer", "minimum": 0, "default": 0 }
  },
  "additionalProperties": false
}
```

Note the shipped `PathRecorder.to_data()` omits `undo_count`; the `PathLog` wrapper (§3.6) adds it.

### 3.6 `PathLog` wrapper resource

`PathRecorder` is intentionally minimal. Higher layers wrap it in a `PathLog` Godot Resource so save‑files and telemetry have a single serializable unit:

```gdscript
class_name PathLog
extends Resource

@export var recorder_data: Dictionary = {}   # PathRecorder.to_data()
@export var undo_count: int = 0
@export var chamber_id: String = ""
@export var run_seed: int = 0
@export var motif_boundaries: PackedInt32Array = PackedInt32Array()
    # indices in positions[] where a motif (checkpoint) fired; used by ledger
```

`motif_boundaries` is the append‑only trail of *when* the habit window was consumed by a rewrite. Length equals the number of rewrites fired in the run.

### 3.7 Determinism & performance

- Append is O(1) amortised (Godot `Array.append`).
- `visit_counts()` is O(|positions|) and cached only by callers.
- `directions()` allocates one array of length `|positions|−1`; callers may reuse.
- No allocation happens per movement frame; the recorder allocates only on actual steps.

Budget: on a 24×14 board with 10 000 steps, PathRecorder occupies ≤ 96 KB and `visit_counts()` runs in ≤ 1 ms.

### 3.8 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| `assert` fires in `record_step` | Non‑adjacent step reached the recorder | Loud in dev, guarded by input router in ship. In ship builds, `strict_adjacency=false` is set only at load time in `from_data`. |
| `from_data` receives out‑of‑bounds coord | Corrupted save | Loader clamps to grid bounds and marks the save `dirty`; user is prompted to Rewind. |
| Recorder overflows `Array` max size | Impossible in practice (Godot int64 index) | Not handled. |

### 3.9 Acceptance tests (PL‑*)

Each test has `input`, `expected`, and `assertion`. Every test is deterministic and headless.

**PL‑1 — Empty log.**
```
Given: r = PathRecorder.new()
When:  r.length()
Then:  r.length() == 0 and r.step_count() == 0 and r.last() == Vector2i(-1,-1)
```

**PL‑2 — Idle collapse.**
```
Given: r seeded with (2,2)
When:  r.record_step(2,2) called 5 times
Then:  r.length() == 1
```

**PL‑3 — Contiguity assertion.**
```
Given: r seeded with (2,2) and strict_adjacency = true
When:  r.record_step(4,4)  # diagonal jump
Then:  assert fires; in a release build, the input router prevents this from reaching the recorder
```

**PL‑4 — Round‑trip.**
```
Given: r with positions [(0,0),(0,1),(1,1),(1,0)]
When:  r2 = PathRecorder.from_data(r.to_data())
Then:  r2.positions() == r.positions()
```

**PL‑5 — visit_counts correctness.**
```
Given: r with [(0,0),(0,1),(0,0),(0,1),(0,0)]  # ping-pong
When:  r.visit_counts()
Then:  {(0,0):3, (0,1):2}
```

**PL‑6 — Undo tracked externally.**
```
Given: PathLog wrapping recorder [(0,0),(0,1)], undo_count = 0
When:  Player undo: recorder.record_step(0,0), log.undo_count += 1
Then:  recorder.length() == 3 and log.undo_count == 1
```

**PL‑7 — Motif boundary logging.**
```
Given: PathLog wrapping recorder, chamber with checkpoint at (5,5)
When:  Player reaches (5,5) at recorder length 12
Then:  log.motif_boundaries.append(12); subsequent rewrites can consult it
```

**PL‑8 — Determinism.**
```
Given: two PathRecorders r1, r2 each fed the same sequence of steps
Then:  r1.to_data() == r2.to_data() and r1.visit_counts() == r2.visit_counts()
```

---

## 4. Habit Signature System

### 4.0 System goal

Turn a `PathLog` + `Lattice` into a bounded, immutable, JSON‑serialisable **fingerprint** of the player's movement style over the current habit window. The fingerprint is what the rewrite operators read; nothing else in the game may read it. This is the whole "the lattice is learning who I am" claim, made mechanical.

### 4.1 Habit Window

Let `W ∈ ℕ` be the window size. Given the current `positions[]` of length `n`:

- If `n ≤ W + 1`, the window is the entire path.
- If `n > W + 1`, the window is `positions[n−W−1 .. n−1]` (i.e. the last `W` steps).

The default `W` values (from the GDD; tunable in `§12.1`):

| Substrate tier | `W` |
|---|---|
| Tutorial (chambers 1–2) | 16 |
| Act I (Cubic / grid) | 32 |
| Act II | 48 |
| Act III | 64 |
| Free / Daily | 32 (overridable) |

The recorder itself is always append‑only over the whole run; the *window* is a view into it. HabitSignature never mutates the recorder.

### 4.2 Metric formulas (H1–H8) on the 2‑D grid

Each metric consumes the same **windowed** slice of the path. The GDD's textual definitions are preserved; the operational formulas below are precisely those that ship in `game/echo_lattice/habit_signature.gd` unless a v1.0 extension is noted.

Let `pos[i]` be windowed positions, `dirs[i] = pos[i+1] − pos[i]`, `N = |dirs|`, `V = unique_cells()`, `visits[c]` the count map.

| ID | Name | Formula (2‑D) | Buckets |
|---|---|---|---|
| **H1** | Cadence | `median(Δt_action)` where `Δt_action = 1` for a move that immediately follows another move, `2` for one preceded by an undo, `k` for `k−1` idle ticks (see §4.2.1). Expressed in **logical action units**, not ms. | FAST ≤ 1; MID = 2; SLOW ≥ 3 |
| **H2** | Directionality | `dir_bias[d] = |{i : dirs[i]==d}| / N` over `d ∈ {UP,DOWN,LEFT,RIGHT}`; `s = max_d dir_bias[d]`. | DIFFUSE `s<0.30`; TILTED `0.30–0.55`; BIASED `s≥0.55` |
| **H3** | Verb Mix | 2‑vector `(p_move, p_undo)` with `p_move = 1 − p_undo`. Dominant verb is MOVE unless `p_undo ≥ 0.40`. | Trigger‑checked per rule. |
| **H4** | Run Length | Median length of maximal same‑direction runs in `dirs`. | STACCATO 1; REGULAR 2–3; LONG ≥ 4 |
| **H5** | Symmetry (proxy) | Wall‑hug fraction `wall_hug = |{c ∈ V : ∃d, is_wall(c+d)}| / |V|`. This is the 2‑D projection of the GDD's mirror‑plane metric; it captures the same "does the player hug edges" signal. | LOOSE `<0.30`; MID `0.30–0.60`; HUG `≥0.60` |
| **H6** | Density Slope | `(|V_end| − |V_start|) / (W/2)` where `V_start` is `visited` at the halfway point of the window, `V_end` at the end. Effectively: how fast are new cells being discovered? | SHRINK `<−0.05`; STEADY `−0.05…+0.05`; GROW `>+0.05` |
| **H7** | Undo Rate | `undo_count_in_window / N` | TIDY `<0.05`; TRIAL `0.05–0.20`; THRASH `≥0.20` |
| **H8** | Echo Depth | Length of the longest **backtrack streak** — consecutive dirs where `dirs[i] = −dirs[i−1]`. (2‑D proxy for GDD's ECHO verb chain length.) | NONE 0; LIGHT 1–2; REFRAIN ≥ 3 |

**Derived signals (D‑series):**

| ID | Name | Formula |
|---|---|---|
| **D1** | Turn Rate | `|{i>0 : dirs[i] ≠ dirs[i−1]}| / (N−1)` |
| **D2** | Backtrack Rate | `|{i>0 : dirs[i] == −dirs[i−1]}| / (N−1)` |
| **D3** | Hot‑cell dominance | `max_visits / N` where `max_visits = max_c visits[c]` |
| **D4** | Straight streaks | sorted lengths of maximal same‑direction runs (desc) |

`D1` and `D2` are already shipped as `turn_rate` and `backtrack_rate` in `habit_signature.gd`. `D3` and `D4` are computed lazily by operators that request them.

#### 4.2.1 Logical action time

Because the sim runs on ticks not frames, `Δt` in H1 must be defined in terms of ticks. The rule is:

```
For dirs[i] between pos[i] and pos[i+1]:
  Δt_action[i] = 1 + (number of undo ticks between them)
              + (number of idle ticks between them, if the input router logs idle ticks)
```

Idle ticks are optional: the shipped router does not log them. For the v1.0 slice, `Δt_action[i] = 1 + undo_intervening`. This preserves the GDD's H1 semantic (fast player = short Δt) without inviting float ms into the hot path.

### 4.3 Dominant direction and hot cells

```
dominant_dir = argmax_d dir_bias[d]
  tie-break order: UP > DOWN > LEFT > RIGHT   # canonical (matches shipped code)

dominant_bias = dir_bias[dominant_dir]

hot_cells(k) = top-k visited cells, excluding start and goal
  sort by: visits desc, then y asc, then x asc  # stable
```

The **tie‑break order** is a normative choice, not a suggestion. Every derived operator relies on it. Changing it is a save‑format‑incompatible change.

### 4.4 HabitSignature contract

```
class HabitSignature:
  dir_bias:         Dictionary<Vector2i,float>   # sums to 1.0 (or all-zero on empty)
  dominant_dir:     Vector2i
  dominant_bias:    float                        # in [0,1]
  turn_rate:        float                        # D1
  backtrack_rate:   float                        # D2
  wall_hug:         float                        # H5
  visit_counts:     Dictionary<Vector2i,int>
  straight_streaks: Array<int>                   # D4
  total_steps:      int                          # N
  unique_cell_count:int                          # |V|

  static extract(recorder: PathRecorder, lattice: Lattice) -> HabitSignature
  hot_cells(k: int) -> Array<Vector2i>
  bucket(H_id: String) -> String                 # e.g. bucket("H2") -> "TILTED"
  to_data() -> Dictionary
  fingerprint() -> int                           # 64-bit FNV over all fields
```

Invariants:

- `dir_bias` values sum to `1.0` if `total_steps > 0`, else all zero.
- `dominant_bias == dir_bias[dominant_dir]`.
- `wall_hug ∈ [0,1]` regardless of `total_steps`.
- Read‑only after construction. The type has no mutating methods.

`fingerprint()` is used by the ledger and by regression tests to assert a chamber replay produced the exact same signature.

### 4.5 Reference pseudocode

```gdscript
# HabitSignature.extract (compressed; canonical body lives in habit_signature.gd)

static func extract(recorder, lattice) -> HabitSignature:
    var sig := HabitSignature.new()
    var positions := recorder.positions()
    sig.visit_counts = recorder.visit_counts()
    sig.unique_cell_count = sig.visit_counts.size()
    if positions.size() < 2:
        sig.dir_bias = _zero_bias()
        sig._compute_wall_hug(lattice)
        sig._compute_hot_cells(lattice)
        return sig
    sig._compute_direction_stats(recorder)   # H2, H4, H8, D1, D2, D4
    sig._compute_wall_hug(lattice)           # H5
    sig._compute_hot_cells(lattice)          # D3-input
    return sig
```

Additional v1.0 extensions (specified here, not yet in shipped code):

```gdscript
func bucket(id: String) -> String:
    match id:
        "H1": return _bucket_cadence()
        "H2": return _bucket_directionality()
        "H3": return _bucket_verb_mix()
        "H4": return _bucket_run_length()
        "H5": return _bucket_wall_hug()
        "H6": return _bucket_density_slope()
        "H7": return _bucket_undo_rate()
        "H8": return _bucket_echo_depth()
    push_error("unknown metric: " + id)
    return "?"

func fingerprint() -> int:
    # FNV-1a over a canonical byte encoding of every field, integer-quantised
    var h := 1469598103934665603
    var prime := 1099511628211
    h = _mix(h, prime, total_steps)
    h = _mix(h, prime, unique_cell_count)
    h = _mix(h, prime, _quantise(dominant_bias, 1000))
    h = _mix(h, prime, _quantise(turn_rate, 1000))
    h = _mix(h, prime, _quantise(backtrack_rate, 1000))
    h = _mix(h, prime, _quantise(wall_hug, 1000))
    for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
        h = _mix(h, prime, _quantise(dir_bias.get(d, 0.0), 1000))
    for s in straight_streaks:
        h = _mix(h, prime, s)
    return h
```

Quantisation to milliparts removes float non‑determinism from the hash without affecting any downstream decision.

### 4.6 Habit signature schema (JSON)

```json
{
  "$schema": "habit_signature.schema.json",
  "type": "object",
  "required": [
    "dir_bias", "dominant_dir", "dominant_bias",
    "turn_rate", "backtrack_rate", "wall_hug",
    "total_steps", "unique_cells", "streaks"
  ],
  "properties": {
    "dir_bias": {
      "type": "object",
      "additionalProperties": { "type": "number", "minimum": 0, "maximum": 1 }
    },
    "dominant_dir":  { "type": "array", "items": { "type": "integer" }, "minItems": 2, "maxItems": 2 },
    "dominant_bias": { "type": "number", "minimum": 0, "maximum": 1 },
    "turn_rate":     { "type": "number", "minimum": 0, "maximum": 1 },
    "backtrack_rate":{ "type": "number", "minimum": 0, "maximum": 1 },
    "wall_hug":      { "type": "number", "minimum": 0, "maximum": 1 },
    "total_steps":   { "type": "integer", "minimum": 0 },
    "unique_cells":  { "type": "integer", "minimum": 0 },
    "streaks":       { "type": "array", "items": { "type": "integer", "minimum": 1 } },
    "buckets":       {
      "type": "object",
      "properties": {
        "H1": { "type": "string", "enum": ["FAST","MID","SLOW"] },
        "H2": { "type": "string", "enum": ["DIFFUSE","TILTED","BIASED"] },
        "H3": { "type": "string", "enum": ["MOVE","UNDO"] },
        "H4": { "type": "string", "enum": ["STACCATO","REGULAR","LONG"] },
        "H5": { "type": "string", "enum": ["LOOSE","MID","HUG"] },
        "H6": { "type": "string", "enum": ["SHRINK","STEADY","GROW"] },
        "H7": { "type": "string", "enum": ["TIDY","TRIAL","THRASH"] },
        "H8": { "type": "string", "enum": ["NONE","LIGHT","REFRAIN"] }
      }
    },
    "fingerprint":   { "type": "integer" }
  },
  "additionalProperties": false
}
```

### 4.7 Determinism & performance

- `extract()` is O(N + |V|). For N ≤ 64 and |V| ≤ 336 (24×14 grid), ≤ 60 μs on target hardware.
- All fields are computed once, then read‑only.
- The tie‑break order in `dominant_dir` is fixed at `[UP, DOWN, LEFT, RIGHT]` per shipped code.
- Sorting `straight_streaks` uses `Array.sort()` on ints — deterministic.
- Sorting hot cells uses a custom comparator on `(visits desc, y asc, x asc)` — deterministic.

### 4.8 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| `wall_hug == 0` on non‑empty path | All visited cells are internal | Legal. LOOSE bucket. Deflector/carve operators may skip. |
| All four `dir_bias` entries equal `0.25` | Perfectly diffuse | `dominant_dir` = UP by tie‑break. Ops using `dominant_bias < 0.35` skip themselves. |
| `total_steps == 0` | Window is empty | All numeric fields are zero. Every operator falls back to a no‑op. RewriteEngine returns `no_candidates`. |

### 4.9 Acceptance tests (HS‑*)

**HS‑1 — Empty path.**
```
Given: PathRecorder with 0 positions, arbitrary lattice
When:  HabitSignature.extract(...)
Then:  total_steps == 0
       dir_bias == {UP:0, DOWN:0, LEFT:0, RIGHT:0}
       wall_hug == 0.0
       dominant_dir == Vector2i(0,0)
```

**HS‑2 — Single direction.**
```
Given: PathRecorder with 5 moves all RIGHT
When:  extract
Then:  dir_bias[RIGHT] == 1.0, others 0.0
       dominant_dir == RIGHT, dominant_bias == 1.0
       turn_rate == 0.0
       backtrack_rate == 0.0
       straight_streaks == [4]
```

**HS‑3 — Perfect ping‑pong.**
```
Given: PathRecorder with 6 positions producing dirs = [R, L, R, L, R]  (5 dirs)
When:  extract
Then:  turn_rate == 1.0
       backtrack_rate == 1.0
       straight_streaks == [1,1,1,1,1]
       H8 max backtrack streak == 4  (i=1..4 each satisfy dirs[i] == -dirs[i-1])
       H8 bucket == REFRAIN
```

**HS‑3b — Backtrack streak of length two.**
```
Given: dirs = [R, L, R, U, U]   (backtrack at i=1, i=2; then non-backtrack at i=3, i=4)
When:  extract
Then:  H8 max backtrack streak == 2
       H8 bucket == LIGHT
```

**HS‑4 — Tie‑break UP > DOWN > LEFT > RIGHT.**
```
Given: dir_bias with all four keys at 0.25
When:  extract
Then:  dominant_dir == UP
```

**HS‑5 — Wall‑hug.**
```
Given: Lattice with WALL around edges, path only along top row
When:  extract
Then:  wall_hug == 1.0 (every visited cell touches a wall)
```

**HS‑6 — Hot cells exclude start/goal.**
```
Given: Path that revisits start 3 times, goal 2 times, cell (5,5) 4 times
When:  hot_cells(3)
Then:  first entry is (5,5); start and goal absent
```

**HS‑7 — Fingerprint stability.**
```
Given: identical path replayed twice
When:  extract twice
Then:  sig1.fingerprint() == sig2.fingerprint()
```

**HS‑8 — Bucket stability under bias jitter.**
```
Given: two paths whose dir_bias values differ by < 0.001
When:  bucket("H2") on each
Then:  results identical whenever both fall inside the same bucket band; if
       one straddles a boundary (e.g., 0.30 or 0.55), test is skipped as
       intentionally ambiguous
```

**HS‑9 — H6 GROW/STEADY/SHRINK.**
```
Given: window of 32 steps discovering 16 new cells in first half, 0 in second
When:  extract
Then:  H6 bucket == SHRINK
```

**HS‑10 — Determinism.**
```
Given: two HabitSignatures extracted from equal PathRecorders and equal lattices
Then:  fingerprint() equal and to_data() equal
```

---

## 5. Lattice Rewrite Operators

### 5.0 System goal

Given a Lattice + HabitSignature, produce a set of candidate lattice edits — each a value dictionary with score + patches + meta — that plausibly express *how the player's habit fossilises into the maze*. Operators never mutate inputs. Ranking and solvability are the RewriteEngine's job (`§7`).

### 5.1 Rewrite value type

```
Rewrite := {
  "name":    String,            # canonical operator name; identifies the class
  "score":   float,             # higher = more desired
  "patches": Array<Patch>,      # atomic cell edits; applied together
  "meta":    Dictionary         # diagnostics + reason strings + provenance
}

Patch := {
  "pos":  Vector2i,             # target cell, must be in-bounds
  "cell": int                   # Lattice.Cell enum value
}
```

**Contract on patches:**

- Every patch is in‑bounds (validated at `apply_patches`).
- No patch writes `START` or `GOAL`. A patch attempting to overwrite the start or goal cell is rejected and the whole rewrite fails atomically (see §7.3).
- A patch may set `FLOOR → WALL`, `FLOOR → FOSSIL`, `WALL → FLOOR`, `FLOOR → SOFT`, but the operators below never emit a `WALL → FOSSIL` transition (that would violate the fossilization‑by‑habit fantasy; fossils only ever arise from a hot cell that was walked).

### 5.2 Operator catalog

Nine operators ship in v1.0. Five are already in `rewrite_operators.gd` (canonical); four are extensions specified here and are the direct 2‑D analogues of the playable slice's `chamber_book.gd` transforms (`mirror_v`, `mirror_h`, `rotate_180`, `thicken`).

| # | Name | Fantasy | Kind | Triggers on |
|---|---|---|---|---|
| O1 | `fossilize_hot_cell` | "Your favourite cell freezes." | HARD (leaves permanent scar) | high `visit_counts[c]` |
| O2 | `place_deflector` | "The lattice objects to a long straight." | SOFT | dominant streak ≥ 3, `dominant_bias ≥ 0.35` |
| O3 | `carve_shortcut` | "The lattice rewards commitment." | SOFT | wall between two visited cells along dominant axis |
| O4 | `grow_wall_far_from_path` | "Unused space calcifies." | SOFT | unvisited floor adjacent to wall, far from any hot cell |
| O5 | `widen_hot_corridor` | "Wall‑hugging invites a doorway." | SOFT | `wall_hug ≥ 0.60`, wall adjacent to hot cell |
| O6 | `mirror_walked_v` | "The lattice mirrors your path vertically." | HARD/SOFT (magnitude‑gated) | any completed motif |
| O7 | `mirror_walked_h` | "The lattice mirrors your path horizontally." | HARD/SOFT | any completed motif |
| O8 | `rotate_walked_180` | "Turn." | HARD/SOFT | any completed motif |
| O9 | `thicken_walked` | "Habits solidify in place." | HARD | any completed motif; the walked cells become FOSSIL |

O1–O5 are **habit‑driven** — they read the signature and select cells with high semantic content. O6–O9 are **transform‑driven** — they act on the walked path itself, regardless of habit; the chamber picks one to teach a specific transform lesson.

### 5.3 Operator semantics (formal)

Notation: `L` is the current Lattice, `S` the HabitSignature, `P` the current `PathRecorder.positions()`. `WALK(P) := {p ∈ P : p ≠ start ∧ p ≠ goal}` is the walked set excluding terminals.

**O1 `fossilize_hot_cell`.**

```
candidates := {}
for pos in S.hot_cells(6):
    if L.cell(pos) != FLOOR: continue
    if pos == start or pos == goal: continue
    v := S.visits[pos]
    if v < 2: continue
    score := 1.0 + v + 0.5 * S.dominant_bias
    candidates.add(Rewrite("fossilize_hot_cell", score, [Patch(pos, FOSSIL)], meta))
return candidates
```

**O2 `place_deflector`.**

```
if S.total_steps == 0 or S.dominant_bias < 0.35: return {}
dom := S.dominant_dir
candidates := {}
for pos in S.visit_counts.keys():
    back := pos - dom
    ahead := pos + dom
    if back not in visits: continue           # not the leading end of a streak
    if ahead in visits: continue              # streak not yet ended
    if not L.in_bounds(ahead): continue
    if L.cell(ahead) != FLOOR: continue
    if ahead == start or ahead == goal: continue
    streak := _measure_back_streak(pos, -dom, visits)
    if streak < 3: continue
    score := 0.5 + streak + 1.5 * S.dominant_bias
    candidates.add(Rewrite("place_deflector", score, [Patch(ahead, WALL)], meta))
return candidates
```

**O3 `carve_shortcut`.**

```
if S.total_steps == 0: return {}
axes := _dominant_axis_dirs(S.dominant_dir)     # [E,W] or [N,S]
candidates := {}
for pos in S.visit_counts.keys():
    for axis in axes:
        cand := pos + axis
        if not L.in_bounds(cand): continue
        if L.cell(cand) != WALL: continue        # never carve fossils
        beyond := cand + axis
        if beyond not in visits and not L.is_passable(beyond): continue
        score := 0.75 + 1.5 * S.dominant_bias + (0.5 if beyond in visits else 0.0)
        candidates.add(Rewrite("carve_shortcut", score, [Patch(cand, FLOOR)], meta))
return candidates
```

**O4 `grow_wall_far_from_path`.**

```
hot := S.hot_cells(8)
candidates := {}
for pos in every floor cell not visited and not start/goal:
    wall_neigh := |{d ∈ DIRS_4 : L.is_wall(pos + d)}|
    if wall_neigh == 0: continue            # avoid loose walls
    d_hot := min_manhattan(pos, hot)
    if d_hot < 2: continue
    score := 0.2 + 0.6 * wall_neigh + 0.15 * d_hot
    candidates.add(Rewrite("grow_wall_far_from_path", score, [Patch(pos, WALL)], meta))
return candidates
```

**O5 `widen_hot_corridor`.**

```
if S.wall_hug < 0.60: return {}
hot := S.hot_cells(6)
perp := _perpendicular_dirs(S.dominant_dir)     # opposite axis to dom
candidates := {}
for pos in hot:
    for d in perp:
        tgt := pos + d
        if not L.in_bounds(tgt): continue
        if L.cell(tgt) != WALL: continue
        score := 0.4 + 0.6 * S.wall_hug
        candidates.add(Rewrite("widen_hot_corridor", score, [Patch(tgt, FLOOR)], meta))
return candidates
```

**O6 `mirror_walked_v` (mirror across the vertical centre line of the grid).**

```
patches := []
for pos in WALK(P):
    mp := Vector2i(L.width - 1 - pos.x, pos.y)   # exact reflection; parity-safe
    if not L.in_bounds(mp): continue
    c := L.cell(mp)
    if c in [WALL, FOSSIL]: continue              # do not touch existing walls
    if mp == start or mp == goal: continue
    patches.append(Patch(mp, ECHO_WALL))
if patches.empty(): return {}
score := 1.0 + 0.2 * |WALK(P)|
return { Rewrite("mirror_walked_v", score, patches, {mode:"transform", axis:"x"}) }
```

`mirror_walked_h`, `rotate_walked_180`, `thicken_walked` follow the same shape; the only differences are the coordinate transform and the target cell kind:

| Op | Coord transform | Target cell |
|---|---|---|
| O6 mirror_v | `(x,y) → (W − 1 − x, y)` | `ECHO_WALL` |
| O7 mirror_h | `(x,y) → (x, H − 1 − y)` | `ECHO_WALL` |
| O8 rotate_180 | `(x,y) → (W − 1 − x, H − 1 − y)` | `ECHO_WALL` |
| O9 thicken | identity (same cell) | `FOSSIL` |

The `(W − 1 − x)` form (rather than `2·⌊(W−1)/2⌋ − x`) is used deliberately: it maps `[0, W−1]` onto itself for every `W`, whether `W` is even or odd, without ever escaping the grid. Every patch is guaranteed in‑bounds and the reflection is exact.

`ECHO_WALL` in the shipped slice is drawn as an orange wall; here it is a distinct enum value so the visual layer can render it differently from a hand‑authored wall while the sim treats them identically for solvability (both impassable).

### 5.4 Score aggregation

`propose_all(L, S) -> Array<Rewrite>`:

```
all := []
for op in enabled_ops(config):
    all.extend(op(L, S))
sort_stable_by(all, key = a -> -a.score)   # score desc, tie-break by insertion order
return all
```

Stable sort is important: it means identical scores from the same operator preserve their internal deterministic order (which is scan order of the lattice / visits keys).

### 5.5 Determinism & performance

| Op | Complexity | Notes |
|---|---|---|
| O1 fossilize_hot_cell | O(|V|) | reads `hot_cells(6)`; cached in signature |
| O2 place_deflector | O(|V|) | streak measure is O(streak) but sum bounded by N |
| O3 carve_shortcut | O(|V|) | 2 axes, O(1) per (cell,axis) |
| O4 grow_wall_far_from_path | O(W·H) | full grid scan; ok for ≤ 400 cells |
| O5 widen_hot_corridor | O(hot·2) | trivial |
| O6–O9 transform ops | O(|WALK(P)|) | one patch per walked cell (dedup by dict) |

Total budget: ≤ 500 μs per call on target hardware for a 24×14 grid.

### 5.6 Serialization schema (Rewrite JSON)

```json
{
  "$schema": "rewrite.schema.json",
  "type": "object",
  "required": ["name", "score", "patches"],
  "properties": {
    "name":  { "type": "string" },
    "score": { "type": "number" },
    "patches": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["pos", "cell"],
        "properties": {
          "pos":  {
            "type": "array",
            "items": { "type": "integer" },
            "minItems": 2, "maxItems": 2
          },
          "cell": { "type": "integer" }
        }
      }
    },
    "meta": { "type": "object" }
  }
}
```

### 5.7 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| No candidates returned | Empty path, or all operators short‑circuited | RewriteEngine returns `no_candidates`; chamber shows no rewrite banner; play continues. |
| Two candidates with equal score | Common (e.g., symmetric board) | Score jitter in engine breaks ties deterministically per‑seed. |
| Patch overwrites start/goal | Bug in operator | `apply_patches` rejects; engine records `invalid_patch` and moves to next candidate. |
| Patch out‑of‑bounds | Bug in operator | `apply_patches` rejects. |

### 5.8 Acceptance tests (RO‑*)

**RO‑1 — Empty signature yields no candidates.**
```
Given: empty PathRecorder, arbitrary lattice
When:  propose_all(L, S)
Then:  returns [] and reason == "no_candidates" downstream
```

**RO‑2 — Fossilize picks the true hot cell.**
```
Given: path revisiting (5,5) 4 times, other cells at most twice
When:  fossilize_hot_cell(L, S)
Then:  a candidate exists with patches == [{(5,5), FOSSIL}] and highest score
```

**RO‑3 — Deflector requires streak >= 3.**
```
Given: path R R R R (streak 4) along y=3, ahead is FLOOR
When:  place_deflector
Then:  a candidate exists with a wall patch at the cell one past the last step
```

**RO‑4 — Deflector rejected when dominant_bias < 0.35.**
```
Given: uniform ergodic path (dominant_bias 0.25)
When:  place_deflector
Then:  candidates == []
```

**RO‑5 — Carve never touches FOSSIL.**
```
Given: L has FOSSIL between two visited cells along dominant axis
When:  carve_shortcut
Then:  no patch targets that FOSSIL; the visited pair is left un‑bridged
```

**RO‑6 — Grow_wall stays far from hot cells.**
```
Given: hot cell at (5,5), unvisited floor at (5,6) adjacent to a wall
When:  grow_wall_far_from_path
Then:  (5,6) rejected (manhattan distance 1 < 2); a farther candidate wins
```

**RO‑7 — Widen fires only under wall_hug >= 0.60.**
```
Given: wall_hug = 0.4
When:  widen_hot_corridor
Then:  candidates == []
```

**RO‑8 — Mirror_v reflects along W−1−x.**
```
Given: lattice 24 wide; path visits (2,3), (2,4), (2,5); those cells are FLOOR
When:  mirror_walked_v
Then:  patches include ECHO_WALL at (21,3), (21,4), (21,5)   # 24-1-2 = 21
       All patches are in-bounds; no patch targets START or GOAL
```

**RO‑9 — Rotate_180 reflects along both axes.**
```
Given: lattice 5x5; path visits (1,1), (1,2)
When:  rotate_walked_180
Then:  patches at (3,3), (3,2)                                # 5-1-1 = 3
       No patch targets START or GOAL
```

**RO‑10 — Thicken produces FOSSIL not ECHO_WALL.**
```
Given: any walked path
When:  thicken_walked
Then:  every patch has cell == FOSSIL
```

**RO‑11 — Determinism.**
```
Given: same L, same S, two calls to propose_all
Then:  arrays are element-wise equal (names + patches + scores)
```

**RO‑12 — Score jitter is deterministic per RNG seed.**
```
Given: same L, S, rng seed=42
When:  RewriteEngine.apply twice
Then:  same rewrite chosen both times
```

---

## 6. Chamber Grammars

### 6.0 System goal

Define the **on‑disk** format of a chamber and the **runtime** transform that expands a chamber into a live Lattice + Motif set + Resonance predicate + Tempo budget + rewrite config. Chambers are pure data. The engine has no hardcoded chamber content.

### 6.1 Chamber file: shape

```
game/echo_lattice/content/chambers/NN_slug.json
```

Every chamber is a single JSON object matching the schema in §6.4. The v1.0 slice adds five backwards‑compatible fields to the content bible base schema:

| Field | Type | Purpose | Default |
|---|---|---|---|
| `motifs` | array of Motif | Explicit sub‑goals to complete; each triggers one rewrite | `[]` (goal‑only chamber) |
| `resonance` | Resonance object | Global constraint that must hold at goal | `{ "kind": "REACH_GOAL" }` |
| `tempo_start` | int | Move budget | `9999` (uncapped) |
| `rewrite` | Rewrite config | which operators, cap, magnitudes | see §6.5 |
| `soft_hard_bias` | float in `[0,1]` | 0 = all soft, 1 = all hard | `0.5` |

### 6.2 ASCII grid legend

The ASCII lattice re‑uses the canonical glyphs from `Lattice.from_ascii`:

| Glyph | Cell | Notes |
|---|---|---|
| `.` | FLOOR | Walkable. |
| ` ` | FLOOR | Alias for readability. |
| `#` | WALL | Impassable, hand‑authored. |
| `S` | START | Walkable; player spawn. Exactly one per chamber. |
| `G` | GOAL | Walkable; success terminal. Exactly one per chamber. |
| `*` | FOSSIL | Impassable, presented as authored fossil. |
| `:` | SOFT | Walkable overlay (e.g., decorative moss). |

Extension glyphs added by v1.0 systems doc:

| Glyph | Cell | Notes |
|---|---|---|
| `C` | CHECKPOINT | Walkable; entering the first time fires a rewrite. See §6.6. |
| `c` | CHECKPOINT_USED | Walkable; visually spent. Loader treats identically to `C` but flagged. |
| `E` | ECHO_WALL | Impassable; visually distinct from `#`. Rare in authored input; usually appears only via O6–O8 rewrites. |

Any glyph not in the canonical or extension table is a load error; the loader rejects the chamber with a precise diagnostic.

### 6.3 Motif model

A **Motif** is a sub‑goal completed *inside* a chamber. Reaching it fires the rewrite pipeline. In the v1.0 slice, motifs are exactly checkpoint entries; in later slices they may be authored subgraphs.

```
Motif := {
  "id":       String,             # unique within chamber, e.g. "M1"
  "kind":     String,             # "CHECKPOINT" (v1.0 slice)
  "cell":     Vector2i,           # coordinates of the checkpoint tile
  "unique":   bool,               # if true, first entry only; if false, every entry
  "operator": String or null,     # which operator to run; null = engine picks
  "banner":   String              # short, silent-play-compatible caption
}
```

Ordering: motifs may be completed in any order. Reaching goal without completing all `mandatory=true` motifs is allowed **iff** the Resonance predicate permits it.

### 6.4 Chamber JSON Schema

```json
{
  "$schema": "chamber.schema.json",
  "type": "object",
  "required": ["id", "title", "lattice"],
  "properties": {
    "id":         { "type": "string", "pattern": "^[0-9]{2}_[a-z0-9_]+$" },
    "title":      { "type": "string", "maxLength": 60 },
    "caption":    { "type": "string", "maxLength": 120 },
    "teaches":    {
      "type": "string",
      "enum": ["intro","fossilize","deflect","carve","grow_wall","widen",
               "mirror_v","mirror_h","rotate_180","thicken","composition","free"]
    },
    "difficulty": { "type": "integer", "minimum": 0, "maximum": 5 },
    "act":        { "type": "integer", "minimum": 1, "maximum": 3 },
    "tempo_start":{ "type": "integer", "minimum": 1, "default": 9999 },
    "lattice": {
      "type": "object",
      "required": ["rows", "cols", "cells"],
      "properties": {
        "rows": { "type": "integer", "minimum": 3 },
        "cols": { "type": "integer", "minimum": 3 },
        "cells":{
          "type": "array",
          "items": { "type": "string" }
        }
      }
    },
    "motifs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id","kind","cell"],
        "properties": {
          "id":       { "type": "string" },
          "kind":     { "type": "string", "enum": ["CHECKPOINT"] },
          "cell":     { "type": "array", "items": {"type":"integer"}, "minItems": 2, "maxItems": 2 },
          "unique":   { "type": "boolean", "default": true },
          "operator": { "type": ["string","null"], "default": null },
          "banner":   { "type": "string", "default": "" }
        }
      }
    },
    "resonance": {
      "type": "object",
      "required": ["kind"],
      "properties": {
        "kind": {
          "type": "string",
          "enum": ["REACH_GOAL","REACH_GOAL_AND_ALL_MOTIFS","MASS","DIAMETER","MIRROR","TONAL","PLANAR","ISOL"]
        },
        "params": { "type": "object" }
      }
    },
    "rewrite": {
      "type": "object",
      "properties": {
        "cap":            { "type": "integer", "minimum": 0, "default": 1 },
        "enabled_ops":    { "type": "array", "items": { "type": "string" }, "default": ["fossilize_hot_cell","place_deflector","carve_shortcut","grow_wall_far_from_path","widen_hot_corridor"] },
        "forced_op":      { "type": ["string","null"], "default": null },
        "score_jitter":   { "type": "number", "default": 0.05 },
        "min_score":      { "type": "number", "default": 0.0 },
        "soft_hard_bias": { "type": "number", "default": 0.5, "minimum": 0, "maximum": 1 },
        "require_shorter_or_equal": { "type": "boolean", "default": false }
      }
    },
    "unlocks": {
      "type": "array",
      "items": { "type": "object",
        "properties": {
          "kind": { "type": "string", "enum": ["chamber","modifier","cosmetic","daily"] },
          "id":   { "type": "string" }
        },
        "required": ["kind","id"]
      }
    }
  },
  "additionalProperties": false
}
```

### 6.5 Rewrite config semantics

- `cap` — max simultaneously active rewrites in this chamber. GDD default: 1 in Act I, 2 in Act II, 3 in Act III. Overridden per chamber.
- `enabled_ops` — whitelist of operator names.
- `forced_op` — if non‑null, the engine bypasses `propose_all` and directly generates candidates from this operator only. Used by chambers whose lesson *is* a specific operator (e.g., tutorial chapter `mirror_walked_v`).
- `score_jitter` — magnitude of tie‑break jitter (`§7.4`).
- `min_score` — filter cutoff.
- `soft_hard_bias` — see §8.2.
- `require_shorter_or_equal` — if true, engine only commits rewrites that do not increase BFS shortest‑path length. Used by chambers that must remain generous.

### 6.6 Chamber loader — pseudocode

```gdscript
static func load_chamber(path: String) -> Chamber:
    var text := FileAccess.get_file_as_string(path)
    var raw  := JSON.parse_string(text)
    _validate_against_schema(raw)                          # rejects on schema violation

    var lat_text := "\n".join(raw["lattice"]["cells"])
    var lattice  := Lattice.from_ascii(lat_text)           # handles S/G/#/./*/:
    _apply_extension_glyphs(lattice, raw["lattice"]["cells"])  # C, c, E

    var motifs := []
    for m_raw in raw.get("motifs", []):
        var m := Motif.from_dict(m_raw)
        assert(lattice.in_bounds(m.cell))
        motifs.append(m)

    var res_kind := raw.get("resonance", {"kind":"REACH_GOAL"})
    var resonance := Resonance.from_dict(res_kind)

    var rc := RewriteConfig.from_dict(raw.get("rewrite", {}))
    var tempo := int(raw.get("tempo_start", 9999))

    return Chamber.new({
        "id": raw["id"], "title": raw["title"],
        "lattice": lattice, "motifs": motifs,
        "resonance": resonance, "rewrite_config": rc,
        "tempo_start": tempo,
        "unlocks": raw.get("unlocks", []),
        "soft_hard_bias": rc.soft_hard_bias
    })
```

### 6.7 Chamber runtime state

```
class ChamberRuntime:
    chamber:            Chamber
    lattice:            Lattice           # mutable working copy
    recorder:           PathRecorder
    log:                PathLog
    active_rewrites:    Array<Rewrite>    # up to chamber.rewrite_config.cap
    motifs_satisfied:   Dictionary<String,bool>
    tempo_left:         int
    snapshots:          Array<ChamberSnapshot>  # ring buffer size 16
    rng:                RandomNumberGenerator
```

A `ChamberSnapshot` captures `{lattice.clone(), recorder.to_data(), motifs_satisfied.duplicate(), tempo_left, active_rewrites.duplicate()}`. Snapshots are taken (i) at chamber start, (ii) after each committed rewrite, (iii) on `WIN`. The ring buffer retains at most 16.

### 6.8 Motif satisfaction rules

For `kind: CHECKPOINT`:

- On `MOVE` that lands on `cell` for the first time (or every time if `unique == false`), fire the rewrite. Emit `motif_satisfied` signal. Mark the tile `CHECKPOINT_USED` visually; do not un‑walk the player.
- If the chamber `resonance` requires all motifs, un‑satisfied motifs prevent `WIN` from firing even when the player stands on `G`.

### 6.9 Resonance predicates

Every predicate is a pure function over `(lattice, path, motifs_satisfied)`:

| Kind | Predicate |
|---|---|
| REACH_GOAL | `path.last() == goal` |
| REACH_GOAL_AND_ALL_MOTIFS | above ∧ `all(m in motifs: motifs_satisfied[m.id])` |
| MASS | `params.min ≤ |V| ≤ params.max` (unique cells walked) |
| DIAMETER | shortest‑path length across `walked ∪ goal` ≤ `params.d` |
| MIRROR | `wall_hug ≥ params.min` (2‑D proxy for GDD mirror plane) |
| TONAL | reserved for audio slice; always returns true in v1.0 |
| PLANAR | trivially true for a 2‑D lattice; kept as an alias for `REACH_GOAL` |
| ISOL | count of unreachable regions after committing ≥ `params.k` |

### 6.10 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| Chamber lacks `S` or `G` | Authoring error | Loader raises with file+line pointer; chamber not registered. |
| Motif cell not walkable | Authoring error | Loader raises. |
| `enabled_ops` references unknown operator | Authoring error | Loader raises. |
| Chamber unsolvable at seed | Authoring error | `check.sh` solver refuses to certify; content PR blocked. See §7.5. |

### 6.11 Acceptance tests (CH‑*)

**CH‑1 — Load canonical chamber.**
```
Given: JSON with S/G and 3-line lattice
When:  load_chamber
Then:  Chamber returned; lattice.width/height match; motifs.length == 0
```

**CH‑2 — Reject missing terminal.**
```
Given: JSON with only S
When:  load_chamber
Then:  raises "chamber lacks GOAL"
```

**CH‑3 — Motif in wall.**
```
Given: motif cell coincides with a WALL glyph
When:  load_chamber
Then:  raises "motif cell not walkable"
```

**CH‑4 — Unknown operator.**
```
Given: rewrite.enabled_ops includes "explode_maze"
When:  load_chamber
Then:  raises "unknown operator"
```

**CH‑5 — REACH_GOAL_AND_ALL_MOTIFS gating.**
```
Given: two motifs, one unmet, player reaches G
When:  Chamber.evaluate_win
Then:  returns false; game stays in-chamber
```

**CH‑6 — Extension glyph C.**
```
Given: a row with "C"
When:  load_chamber
Then:  lattice.cell(C_position) == CHECKPOINT; motif auto-inferred if motifs empty
```

**CH‑7 — Backwards compatibility.**
```
Given: chamber from 04_CONTENT_BIBLE.md examples (no motifs/resonance)
When:  load_chamber
Then:  loads with defaults; resonance kind == REACH_GOAL
```

**CH‑8 — Determinism of loader.**
```
Given: same file loaded twice
Then:  Chamber.equal(a, b) is true (deep equal of lattice, motifs, resonance, config)
```

---

## 7. Solvability Constraints (BFS)

### 7.0 System goal

Given any candidate rewrite, decide in bounded time whether applying it leaves the chamber **solvable** — i.e., whether a 4‑connected path from `start` to `goal` still exists through passable cells. Never commit a rewrite that traps the player. Also expose the solver to authors so chambers can be certified before ship.

### 7.1 Formal model

Let `L` be a Lattice. `is_passable(c) := L.cell(c) ∈ {FLOOR, START, GOAL, SOFT, CHECKPOINT, CHECKPOINT_USED}`.

The **passable graph** `G(L) = (V,E)` has `V = {c : is_passable(c)}` and `E = {(c, c+d) : d ∈ DIRS_4 ∧ c ∈ V ∧ c+d ∈ V}`.

`L` is **solvable** iff `start` and `goal` are in the same connected component of `G(L)`.

BFS decides this in `O(|V| + |E|) = O(W·H)` time, `O(W·H)` memory.

### 7.2 API (`LatticeBFS`)

Canonical implementation ships in `game/echo_lattice/bfs.gd`:

```
static is_solvable(L) -> bool
static has_path(L, from, to) -> bool
static shortest_path(L, from, to) -> Array<Vector2i>
static reachable_distances(L, origin) -> Dictionary<Vector2i,int>
static is_reachable(L, from, to) -> bool
```

Contract:

- Deterministic 4‑direction enumeration in `[UP, DOWN, LEFT, RIGHT]` order (matches `Lattice.DIRS_4`).
- `shortest_path` returns `[]` on unreachable; otherwise inclusive of both endpoints.
- Neither `is_solvable` nor `shortest_path` mutate the lattice.

### 7.3 RewriteEngine pipeline

The engine's job is to pick the first candidate that keeps the maze solvable, tie‑broken deterministically. Reference flow:

```
apply(L, S, rng, cfg) -> EngineResult:
    result := EngineResult()
    result.lattice := L.clone()

    candidates := RewriteOperators.propose_all(L, S)
    if candidates.empty(): return result.with_reason("no_candidates")

    filtered := [c for c in candidates
                  if c.name in cfg.enabled_ops and c.score >= cfg.min_score]
    if filtered.empty(): return result.with_reason("no_enabled_candidates")

    for c in filtered:
        c._jittered := c.score + rng.randf_range(-cfg.score_jitter, +cfg.score_jitter)
    stable_sort(filtered, key = -c._jittered)

    baseline_len := if cfg.require_shorter_or_equal
                      then |LatticeBFS.shortest_path(L, L.start, L.goal)|
                      else null
    if baseline_len == 0: return result.with_reason("baseline_unsolvable")

    for c in filtered[:cfg.max_attempts]:
        cand := L.clone()
        if not cand.apply_patches(c.patches):
            result.rejected.append({c, "invalid_patch"})
            continue
        if not LatticeBFS.is_solvable(cand):
            result.rejected.append({c, "unsolvable"})
            continue
        if baseline_len != null:
            new_len := |LatticeBFS.shortest_path(cand, cand.start, cand.goal)|
            if new_len > baseline_len:
                result.rejected.append({c, "longer_than_baseline"})
                continue
        result.applied := true
        result.rewrite := c
        result.lattice := cand
        return result

    return result.with_reason("exhausted")
```

### 7.4 Score jitter as tie‑break

Two candidates with identical `score` are common. The engine adds a per‑candidate uniform jitter in `[−ε, +ε]` (default `ε = 0.05`) drawn from the injected RNG. Given a fixed RNG seed:

- The same ordered set of candidates always produces the same tie‑break.
- Callers who care can set `score_jitter = 0.0` to preserve strict operator/insertion order.

The jitter is a **local** float; it never enters the Lattice or the ledger. Determinism is preserved via the fingerprinted seed.

### 7.5 Author‑time solver

Every chamber must be certified solvable *at the seed lattice, before any rewrites fire*. This is enforced by a small helper the CI runs:

```
static certify(chamber: Chamber) -> Report:
    lat := chamber.lattice.clone()
    if not LatticeBFS.is_solvable(lat):
        return Report.fail("seed unsolvable")
    path := LatticeBFS.shortest_path(lat, lat.start, lat.goal)
    if path.size() == 0:
        return Report.fail("no path")
    return Report.ok(path_len = path.size(), tempo_margin = chamber.tempo_start - path.size())
```

A chamber ships if `certify` returns `ok` with `tempo_margin ≥ 0` and, for each motif in `motifs`, `LatticeBFS.has_path(lat, start, motif.cell)` and `LatticeBFS.has_path(lat, motif.cell, goal)`. The check runs headlessly in `game/echo_lattice/check.sh`.

### 7.6 Progressive checking after rewrite

After the engine commits a rewrite, `chamber_runtime.on_rewrite_committed(cand)` calls a **soft** check to warn (not fail) if the new shortest path exceeds `1.5 × previous shortest path`. This is telemetry only; it never blocks.

### 7.7 Determinism & performance

- `is_solvable`: O(W·H) time, ~40 μs on 24×14.
- `shortest_path`: O(W·H) time, ~50 μs on 24×14.
- BFS uses a FIFO `Array` queue in shipped code. Alternative: `PackedInt32Array` for tighter memory; deferred until profiling demands it.
- Neighbour enumeration order is `Lattice.DIRS_4 == [UP, DOWN, LEFT, RIGHT]`. Do not reorder.

### 7.8 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| `is_solvable == false` at seed | Authoring bug | Certifier blocks the chamber; PR fails CI. |
| Every candidate `unsolvable` | Habits force locked geometry | Engine returns `exhausted`; chamber shows no rewrite; player continues; motif still marked satisfied. |
| BFS runs out of memory | Grid too large | Only relevant post‑v1.0; v1.0 grids ≤ 100×100. |

### 7.9 Acceptance tests (BF‑*)

**BF‑1 — Solvable identity.**
```
Given: open 3x3 lattice, S at (0,0), G at (2,2)
When:  is_solvable
Then:  true
```

**BF‑2 — Walled off.**
```
Given: lattice with a full column of walls between S and G
When:  is_solvable
Then:  false
```

**BF‑3 — Shortest path length equals Manhattan on open grid.**
```
Given: 5x5 open grid, S=(0,0), G=(4,4)
When:  shortest_path
Then:  length == 9  (including endpoints)
```

**BF‑4 — Deterministic tie-break.**
```
Given: two paths tied in length
When:  shortest_path
Then:  the returned path takes UP before DOWN before LEFT before RIGHT
       at every branch
```

**BF‑5 — Engine rejects candidate that traps.**
```
Given: candidate that walls the only corridor
When:  RewriteEngine.apply
Then:  result.rejected includes it with reason "unsolvable"; another candidate applied
```

**BF‑6 — Baseline check on shorter_or_equal.**
```
Given: config.require_shorter_or_equal, baseline_len = 12
When:  candidate that would produce shortest_path length 13
Then:  rejected with reason "longer_than_baseline"
```

**BF‑7 — Certification of shipped chambers.**
```
For every chamber JSON in game/echo_lattice/content/chambers/:
  certify(chamber) returns ok and tempo_margin >= 0
```

**BF‑8 — Determinism.**
```
Given: same lattice
When:  is_solvable, shortest_path called twice
Then:  bit-identical outputs
```

---

## 8. Soft / Hard Adaptation

### 8.0 System goal

Give designers a single dial (`soft_hard_bias ∈ [0,1]`) that continuously scales the *magnitude* of adaptation without changing the *logic*. Zero = every rewrite is soft (reversible, cosmetic); one = every rewrite is hard (permanent, semantic). Also expose the difficulty modes from the GDD (Reader, Standard, Cold) as pre‑baked bias + cap presets.

### 8.1 Definitions

- **Soft** rewrite: the patch may be undone by a designated **reversal action** (see §8.4) without cost; visual weight is muted.
- **Hard** rewrite: the patch survives Reset (but not Rewind); visual weight is prominent; the rewrite is added to the chamber's `active_rewrites` and counts against the cap.

Every operator declares its **default hardness**:

| Operator | Default hardness |
|---|---|
| O1 fossilize_hot_cell | hard |
| O2 place_deflector | soft |
| O3 carve_shortcut | soft |
| O4 grow_wall_far_from_path | soft |
| O5 widen_hot_corridor | soft |
| O6–O8 mirror/rotate | soft |
| O9 thicken_walked | hard |

Under the `soft_hard_bias` dial, an operator's effective hardness is computed as:

```
effective_hardness(op) := ("hard"
                           if rng.randf() < clamp(soft_hard_bias + delta(op), 0, 1)
                           else "soft")

delta(op) := +0.4 if op default == hard,  -0.4 if op default == soft
```

At `bias = 0.5`, defaults are honoured. At `bias = 0.0`, defaults collapse toward soft (except O1/O9 remain hard with probability 0.1). At `bias = 1.0`, defaults collapse toward hard (except O2–O8 remain soft with probability 0.1). This preserves system character while giving designers a smooth knob.

### 8.2 Magnitude scaling

A soft rewrite emits **half** the patch count where feasible, chosen by keeping the highest‑`score` patches. Specifically:

- O1 (single‑patch) is untouched (soft = normal walls not fossils).
- O2 (single‑patch) is untouched.
- O3 (single‑patch) is untouched.
- O4 (multi‑candidate) reduces the number of candidates offered by half (top half retained).
- O5 (multi‑candidate) reduces by half.
- O6–O8 reduce the walked cells they mirror by half (every second cell, deterministically).
- O9 reduces to a single patch: the hottest walked cell only.

Under **Reader** mode (GDD §9.3), the magnitude scale is halved again; under **Cold** mode, it is doubled up to the operator's natural maximum.

Formal scaling function:

```
magnitude_scale(mode, hardness):
  if mode == "reader":   return 0.5 * (hardness == "hard" ? 1.0 : 0.5)
  if mode == "standard": return       hardness == "hard" ? 1.0 : 0.5
  if mode == "cold":     return min(1.0, 2.0 * (hardness == "hard" ? 1.0 : 0.5))
```

`magnitude_scale` is applied to *patch retention*, not to score. Scoring is untouched.

### 8.3 Active rewrite cap

The `cap` in `Chamber.rewrite_config.cap` is enforced at commit time:

```
on_rewrite_commit(cand):
    active_rewrites.append(cand)
    if len(active_rewrites) > cap:
        oldest_soft := first soft in active_rewrites
        if oldest_soft:
            reverse(oldest_soft)
            active_rewrites.remove(oldest_soft)
        else:
            oldest_hard := first hard in active_rewrites
            # HARD rewrites are not auto-reversible; they remain but stop
            # counting against the cap. Their patches stay applied.
            oldest_hard.retired := true
```

Hard rewrites are permanent scars; they age *out of counting* but not *out of effect*. Only Rewind (§8.4) undoes them.

### 8.4 Reversal actions

Reversal is the mechanism by which soft rewrites can be un‑committed by play. Each operator declares a reversal predicate:

| Operator | Reversal predicate (from GDD §5.4, adapted) |
|---|---|
| O1 fossilize_hot_cell | (none; hard) |
| O2 place_deflector | 5 MOVEs strictly perpendicular to the deflector's axis within one motif |
| O3 carve_shortcut | 3 MOVEs strictly away from the carved axis within one motif |
| O4 grow_wall_far_from_path | 3 undos within one motif |
| O5 widen_hot_corridor | 3 MOVEs onto the widened cell within one motif |
| O6/O7 mirror | 3 MOVEs strictly along the mirror axis within one motif |
| O8 rotate | 3 MOVEs into the rotated region within one motif |
| O9 thicken | (none; hard) |

The runtime maintains a small counter per active soft rewrite; incrementing counters is O(1) per MOVE. When the counter meets the threshold, the rewrite is reversed:

```
reverse(rewrite):
    for patch in rewrite.patches:
        lattice.set_cell(patch.pos, previous_cell_at[patch.pos])
    active_rewrites.remove(rewrite)
    emit signal rewrite_reversed(rewrite)
```

`previous_cell_at` is stored in `rewrite.meta.snapshot` at commit time.

### 8.5 Rewind

Rewind is a chamber‑global time machine to the previous **snapshot**. It undoes every rewrite (soft or hard) since that snapshot, restores the lattice, restores the PathRecorder, and restores tempo.

Rewind is subject to a per‑mode budget:

| Mode | Rewinds / chamber |
|---|---|
| Reader | unlimited |
| Standard | 5 |
| Cold | 2 |

The budget is enforced at the UI layer; the underlying `chamber_runtime.rewind(snapshot_id)` never rejects a valid snapshot id.

### 8.6 Serialization

Every active rewrite is serialised as part of `ChamberSnapshot`:

```json
{
  "rewrite": { "name": "...", "score": 1.2, "patches": [...], "meta": {"previous_cells": {...}, "hardness": "soft"} },
  "reversal_progress": { "kind": "perp_moves", "count": 2, "threshold": 5 }
}
```

### 8.7 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| Cap reached and every active is hard | Chamber accepted too many hard rewrites | New rewrite proposals still ranked, but a warning telemetry event fires; new rewrites still commit (cap enforcement is retire‑oldest, not block‑new). |
| Reversal threshold ambiguous (mirror on centreline) | Rare | Threshold treats centreline as satisfying either axis; the counter increments. |

### 8.8 Acceptance tests (SH‑*)

**SH‑1 — Bias 0.5 preserves defaults.**
```
Given: soft_hard_bias = 0.5, 1000 draws over each operator
When:  effective_hardness sampled with rng seeded from 0
Then:  each op's default hardness is chosen ≥ 90% of the time
```

**SH‑2 — Bias 0.0 nearly all soft.**
```
Given: soft_hard_bias = 0.0
Then:  O1 hard rate drops to ~10%; O2 hard rate ~0%
```

**SH‑3 — Reader halves magnitude of soft O6.**
```
Given: mode Reader, O6 mirror with 12 walked cells, hardness soft
Then:  ceil(12 * 0.25) = 3 patches applied  (0.5 * 0.5 = 0.25)
```

**SH‑4 — Cap enforcement retires oldest soft.**
```
Given: cap = 2, active = [soft_A, soft_B]
When:  soft_C committed
Then:  soft_A reversed and removed; active = [soft_B, soft_C]
```

**SH‑5 — Reversal by perpendicular moves.**
```
Given: active O2 deflector along X axis; player commits 5 vertical moves in one motif window
Then:  deflector reversed; wall patch reverted to FLOOR
```

**SH‑6 — Rewind restores exact snapshot.**
```
Given: snapshot at motif 1; player commits O1, O3; rewinds
Then:  lattice equal to snapshot; recorder equal to snapshot; active_rewrites empty
```

**SH‑7 — Rewind budget respected.**
```
Given: Cold mode, 2 rewinds used
When:  third rewind requested
Then:  UI rejects; underlying runtime.rewind API is not called
```

**SH‑8 — Determinism of hardness draws.**
```
Given: same rng seed, same bias
Then:  effective_hardness sequence identical across runs
```

---

## 9. Meta Unlocks

### 9.0 System goal

Persist across sessions: which chambers are unlocked, which runes (verb modifiers) are earned, which cosmetic knobs are enabled, which options are set. The meta layer is a *pure state machine* over run records; it never depends on wall‑clock (except the audit field).

### 9.1 Save file shape

Save lives at `%APPDATA%/Godot/app_userdata/Echo Lattice/save.json` (Windows) or `~/.local/share/godot/app_userdata/Echo Lattice/save.json` (Linux/Steam Deck).

Top‑level schema:

```json
{
  "$schema": "save.schema.json",
  "type": "object",
  "required": ["version", "slot", "unlocks", "settings", "stats", "runs"],
  "properties": {
    "version":  { "type": "integer", "minimum": 1 },
    "slot":     { "type": "integer", "minimum": 1, "maximum": 3 },
    "unlocks": {
      "type": "object",
      "properties": {
        "chambers":   { "type": "array", "items": { "type": "string" } },
        "modifiers":  { "type": "array", "items": { "type": "string" } },
        "cosmetics":  { "type": "array", "items": { "type": "string" } },
        "runes":      { "type": "array", "items": { "type": "string" } }
      },
      "required": ["chambers","modifiers","cosmetics","runes"]
    },
    "settings": {
      "type": "object",
      "properties": {
        "difficulty":        { "type": "string", "enum": ["reader","standard","cold"] },
        "reduced_motion":    { "type": "boolean" },
        "flatten_shimmer":   { "type": "boolean" },
        "palette":           { "type": "string" },
        "text_scale":        { "type": "number" },
        "icon_scale":        { "type": "number" },
        "audio":             { "type": "object" }
      }
    },
    "stats": {
      "type": "object",
      "properties": {
        "chambers_cleared":  { "type": "integer", "minimum": 0 },
        "chambers_stalled":  { "type": "integer", "minimum": 0 },
        "moves_total":       { "type": "integer", "minimum": 0 },
        "undos_total":       { "type": "integer", "minimum": 0 },
        "rewrites_committed":{ "type": "integer", "minimum": 0 },
        "rewrites_rejected": { "type": "integer", "minimum": 0 },
        "hist_H1":           { "type": "object" },
        "hist_H2":           { "type": "object" },
        "hist_H3":           { "type": "object" },
        "hist_H4":           { "type": "object" },
        "hist_H5":           { "type": "object" },
        "hist_H6":           { "type": "object" },
        "hist_H7":           { "type": "object" },
        "hist_H8":           { "type": "object" },
        "rewrite_counts":    { "type": "object" }
      }
    },
    "runs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["chamber_id","result","seed","moves","undos","fingerprint"],
        "properties": {
          "chamber_id":  { "type": "string" },
          "result":      { "type": "string", "enum": ["cleared","stalled","exited","reset"] },
          "seed":        { "type": "integer" },
          "moves":       { "type": "integer" },
          "undos":       { "type": "integer" },
          "fingerprint": { "type": "integer" },
          "recorded_at": { "type": "string" }
        }
      }
    },
    "audit": {
      "type": "object",
      "properties": {
        "created_at":    { "type": "string" },
        "last_played_at":{ "type": "string" },
        "playtime_seconds": { "type": "integer" }
      }
    }
  }
}
```

### 9.2 Unlock rules

Unlocks are declared per‑chamber in the chamber JSON (`unlocks` field, §6.4). At the moment a run's `result == "cleared"`, the runtime performs:

```
for u in chamber.unlocks:
    match u.kind:
        "chamber":  SaveService.unlock_chamber(u.id)
        "modifier": SaveService.unlock_modifier(u.id)
        "cosmetic": SaveService.unlock_cosmetic(u.id)
        "daily":    SaveService.enable_daily()
```

Each `unlock_*` method:

- Is idempotent (returns `false` if already unlocked).
- Emits `unlocks_changed(kind)`.
- Writes to disk atomically (`save.json.tmp` + rename).

### 9.3 Chamber gating

A chamber is **playable** iff it appears in `unlocks.chambers` or is a mandatory root chamber. Root chambers are declared by `chamber_catalog.gd`:

```
ROOTS := ["00_first_step"]   # always playable
```

Chamber catalog is data, not code: it reads every JSON in `content/chambers/`, sorts by `id`, and returns metadata for the UI. Unlock progression is *not* strictly linear; a chamber may declare multiple `unlocks` and be declared as a prerequisite for multiple downstream chambers.

### 9.4 Runes

A Rune modifies **one operator or verb**. Runes are declared per‑chamber via `unlocks[].kind == "modifier"` with a distinct `id`. Once unlocked, a rune is **always active** across every subsequent chamber (P4: silent play means no equip screen).

Rune registry (subset for v1.0; full list mirrors GDD §8.3):

| ID | Chamber unlocked in | Effect | Applies to |
|---|---|---|---|
| `pale_placer` | 01 | tempo cost of first MOVE per motif reduced by 1 | Chamber runtime |
| `whorl` | 02 | rewrite preview time reduced 40% (Reader remains 6s min) | UI |
| `refrain_b` | 03 | O8 rotate default hardness → soft | RewriteEngine |
| `green_prune` | 04 | undo cost = 0 for the first undo per motif | Chamber runtime |
| `iron_anchor` | 05 | checkpoint tiles cannot be reversed by any operator | RewriteEngine.pre_commit |
| `snap_extend` | 06 | O3 carve preferred over O2 deflector on ties | RewriteEngine tie-break |
| `chord` | 07 | +1 tempo every 4th MOVE | Chamber runtime |

Runes stack additively. Conflict resolution is documented per‑pair in the GDD; when two runes affect the same score, priority is by unlock order (older wins), overridable per chamber.

### 9.5 Ledger

The Ledger is a read‑only view over `stats.hist_H*` and `stats.rewrite_counts`. It never mutates state. UI (`meta_stats_screen.gd`) computes histograms on demand.

Buckets stored per H metric use the enum strings from §4.6 (`FAST`, `MID`, `SLOW`, …). Each `hist_H*` is a `{bucket_name: count}` map.

Ledger update after a run:

```
on_run_cleared(run):
    stats.chambers_cleared += 1
    stats.moves_total   += run.moves
    stats.undos_total   += run.undos
    stats.rewrites_committed += run.rewrites_committed
    for h in [H1..H8]:
        b := run.final_signature.bucket(h)
        stats.hist_H[h][b] = stats.hist_H[h].get(b, 0) + 1
    for r in run.applied_rewrites:
        stats.rewrite_counts[r.name] = stats.rewrite_counts.get(r.name, 0) + 1
    save_to_disk()
```

### 9.6 Save migrations

Every save has a `version` integer. Migrations are pure functions:

```
migrations := [
  {from:0, to:1, run: migrate_0_to_1},
  {from:1, to:2, run: migrate_1_to_2},
  ...
]

func load_and_migrate(path):
    raw := read_json(path)
    while raw.version < CURRENT_VERSION:
        m := find_migration(raw.version)
        raw := m.run(raw)
    validate_schema(raw)
    return raw
```

Each migration is idempotent; running it twice on the same input produces the same output. Migrations are numbered 0→1, 1→2, … and shipped in `game/save/migrations/*.gd`.

Backup: the previous `save.json` is copied to `save.json.bak` before migration. On any migration error, the loader restores from `.bak` and raises `save_error`.

### 9.7 Autosave

`SaveService.save_to_disk` is called:

- On every unlock event.
- On every setting change.
- On every run recorded.
- Idempotently on every 30 seconds of active play (the only wall‑clock‑adjacent behaviour, and even that is throttled to logical time only).

Atomicity: write `save.json.tmp`, `sync`, `DirAccess.rename(tmp → save.json)`. On Windows, `rename` may fail if the target exists; fall back to `remove(save.json) + rename`.

### 9.8 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| Save corrupt on load | Partial write, disk error | Fall back to `.bak`; if that fails, present a "corrupt save" screen with export option. |
| Two writers | Multiple game instances | Lock file `.lock` sentinel; second instance is read‑only. |
| Migration fails | Schema mismatch | Restore `.bak`; refuse to boot with a diagnostic. |
| Unlocking an already‑unlocked chamber | Common | Idempotent no‑op; still emits `unlocks_changed` for UI refresh. |

### 9.9 Acceptance tests (MU‑*)

**MU‑1 — Idempotent unlock.**
```
Given: chamber "02_ceiling" already unlocked
When:  unlock_chamber("02_ceiling")
Then:  returns false; unlocks_changed still emitted (UI hint); disk not rewritten
```

**MU‑2 — Fresh boot loads root chambers only.**
```
Given: no save file exists
When:  SaveService.load_from_disk
Then:  unlocks.chambers == ["00_first_step"]; unlocks.runes empty
```

**MU‑3 — Rune unlock persists.**
```
Given: run clears chamber "03_first_rewrite" with unlocks.modifier "refrain_b"
When:  save + reload
Then:  unlocks.runes contains "refrain_b"
```

**MU‑4 — Ledger histogram accumulates.**
```
Given: 3 runs, H2 buckets [TILTED, TILTED, BIASED]
When:  ledger read
Then:  hist_H2 == {TILTED: 2, BIASED: 1}
```

**MU‑5 — Migration 0→1.**
```
Given: save.json with version=0 and no "runs" field
When:  load_and_migrate
Then:  save.json normalised to version=1 with runs=[]; .bak created
```

**MU‑6 — Atomic write.**
```
Given: save write interrupted mid-file
When:  next boot
Then:  save.json.bak restored; boot succeeds
```

**MU‑7 — Two-writer lock.**
```
Given: instance A holds .lock
When:  instance B boots
Then:  instance B is read-only; UI shows a subtle "read-only" badge
```

**MU‑8 — Determinism of stats update.**
```
Given: two runs with identical fingerprints
When:  stats updated
Then:  hist_H* deltas equal
```

---

## 10. Daily Seed Mode

### 10.0 System goal

Give the player a single, community‑shared "chamber of the day" that everyone plays on the same seed. Determinism guarantees that the exact same lattice, motif set, and habit‑signature‑driven rewrite pipeline behave identically for every player on the same date. There is no leaderboard, no rewards; only a private daily ledger entry in the local save.

### 10.1 Date → seed

The date resolver is the only wall‑clock touch in the whole subsystem:

```
static func today_seed_string(tz := "local") -> String:
    var d := Time.get_date_dict_from_system(tz == "utc")
    return "%04d-%02d-%02d" % [d.year, d.month, d.day]

static func today_seed_int() -> int:
    return _fnv1a(today_seed_string())
```

The system date is read **once** on Daily menu entry. If the player crosses midnight during a run, the run's seed does not change (the seed is captured at chamber start).

`_fnv1a` is the 64‑bit FNV‑1a hash. It is stable across processes and OSs. It is *not* the Godot `hash()` built‑in.

### 10.2 Daily chamber selection

The daily chamber pool is a whitelist:

```
DAILY_POOL := ["10_daily_bloom", "11_daily_wren", "12_daily_diamond"]
```

Selection is:

```
i := today_seed_int() mod DAILY_POOL.length
daily_chamber_id := DAILY_POOL[i]
```

Each daily chamber is authored with `resonance.kind == MASS` or `DIAMETER` to reward efficient play. Their `rewrite.cap` is fixed at 2. `soft_hard_bias = 0.6`.

### 10.3 Chamber seed derivation

The **chamber seed** is derived from the daily seed to produce a distinct RNG stream per‑chamber even when the same chamber is picked on different days:

```
chamber_rng_seed := _fnv1a(today_seed_string() + ":" + daily_chamber_id)
```

The chamber's RewriteEngine uses a `RandomNumberGenerator` seeded to this integer. Ties, jitter, and any future randomised elements are stable and reproducible.

### 10.4 Daily result recording

A daily run appends a special row to the `runs` array with `chamber_id = "daily:" + daily_chamber_id + ":" + today_seed_string()`. This is what surfaces the "you played today" indicator in the menu.

Only **one** daily run per date is recorded, even if the player retries; retries overwrite the same record in place (indexed by chamber_id).

### 10.5 Sharing

The daily seed is intrinsically shareable: two players on the same UTC date get the same chamber, same seed, same signature‑driven outcomes for the same play. No network round‑trip is required. Post‑v1.0, a "share result" button copies a short string like `EL 2026-08-08 · 42 moves · 1 hard rewrite · fingerprint 0x81a…` to the clipboard.

### 10.6 Serialisation

Daily runs use the same run schema as regular runs; the `chamber_id` prefix `"daily:"` differentiates them.

### 10.7 Failure modes

| Symptom | Cause | Handling |
|---|---|---|
| System clock rolled backward mid‑session | Timezone change, DST | Daily seed is captured on menu entry and does not re‑resolve until menu is re‑entered. |
| Player crosses midnight | Normal | Current run keeps its seed; menu greys the "daily" tile the next time it's opened until the new day. |
| No network | Fine | Daily is offline‑complete. |

### 10.8 Acceptance tests (DL‑*)

**DL‑1 — Same date → same seed.**
```
Given: Time.get_date_dict_from_system returns 2026-08-08
When:  today_seed_int called twice
Then:  same integer
```

**DL‑2 — Chamber selection stable per day.**
```
Given: seed for 2026-08-08 maps to index 1 of DAILY_POOL
When:  select_daily_chamber() called any number of times on that date
Then:  always DAILY_POOL[1]
```

**DL‑3 — Cross-machine parity.**
```
Given: same date, same DAILY_POOL, same content files
On:    machine A and machine B (Windows and Linux)
Then:  chamber_rng_seed equal; daily run fingerprint equal after identical inputs
```

**DL‑4 — Midnight rollover doesn't corrupt an active run.**
```
Given: player enters chamber at 23:59 local
When:  clock rolls to 00:00
Then:  chamber_rng_seed unchanged; run completes; record stored under original date
```

**DL‑5 — Retry overwrites.**
```
Given: two daily runs on same date
When:  second run recorded
Then:  runs[] contains exactly one entry with that chamber_id
```

**DL‑6 — No leaderboard write.**
```
Given: any daily run
Then:  no network calls; no cloud writes (verified with a global "no I/O outside save.json" watchdog in tests)
```

**DL‑7 — Determinism.**
```
Given: two players with identical setups on identical dates producing identical inputs
Then:  final lattices bit-identical; fingerprints equal
```

---

## 11. Cross‑system Acceptance Tests

Beyond the per‑system tests above, the following integration tests must pass at gold master. They exercise the full pipeline and lock in the invariants the whole document depends on.

### 11.1 X‑1 Full replay parity

```
Given: chamber "03_first_rewrite" with fixed seed = 42
When:  Player plays input sequence I; save recorded run R1
       Chamber reset; same input sequence I replayed
Then:  Final lattice fingerprints equal (R1 vs R2)
       Habit signature fingerprints equal
       Applied rewrites identical (names + patches + order)
```

### 11.2 X‑2 Habits actually fossilise

```
Given: chamber that accepts fossilize_hot_cell; player revisits (5,5) 4 times
When:  motif triggers
Then:  Rewrite committed with a patch (5,5) → FOSSIL
       Post-rewrite lattice.cell((5,5)) == FOSSIL
       Ledger stats.rewrite_counts["fossilize_hot_cell"] incremented
       Save persisted
```

### 11.3 X‑3 Trap-safety

```
Given: contrived path such that O3/O4 both propose walling the only corridor
When:  RewriteEngine.apply
Then:  every candidate that traps the player is rejected with reason "unsolvable"
       result.reason == "exhausted"
       lattice unchanged
       game continues normally
```

### 11.4 X‑4 Cap enforcement

```
Given: cap = 2; two soft rewrites already active
When:  third rewrite committed
Then:  oldest soft reversed; two active remain
       Save reflects only the two active
```

### 11.5 X‑5 Rewind restores exact state

```
Given: three snapshots S0, S1, S2 across a run
When:  rewind(S1)
Then:  lattice fingerprint == S1.lattice fingerprint
       recorder positions == S1.recorder positions
       active_rewrites == S1.active_rewrites
```

### 11.6 X‑6 Daily determinism

```
For every day in 2026-01-01 .. 2027-12-31:
  today_seed_int(day) is stable across machines
  select_daily_chamber(day) is stable
  Given identical scripted inputs, final fingerprint equal across machines
```

### 11.7 X‑7 Save migration reproducibility

```
Given: a corpus of `save.v0.json` fixtures
When:  migrate_all
Then:  every fixture migrates to CURRENT_VERSION without loss
       Round-tripped save equals the migrated save
```

### 11.8 X‑8 Silent-play compliance

```
Given: every chamber in game/echo_lattice/content/chambers/
Then:  chamber can be cleared without reading any UI text longer than 3 lines
       (verified by removing all UI text overlays and running the shipped solver)
```

### 11.9 X‑9 Accessibility default parity

```
Given: identical inputs
When:  played under Reader mode vs Standard mode
Then:  same *set* of rewrites triggered (equivalence up to magnitude scaling);
       final lattice equal under Reader-scaled magnitudes vs Standard magnitudes
       (Reader-scaled ⊆ Standard-scaled)
```

### 11.10 X‑10 Performance

```
Given: 24x14 grid, W=32, 500 motif triggers in sequence
Then:  extract + propose_all + apply ≤ 1 ms per motif on target hardware
       No frame drop below 60 fps during rewrite commit animation
```

---

## 12. Data & Tuning Constants

All constants live in `game/echo_lattice/config/tuning.json` and are hot‑reloadable in dev builds. In ship builds they load once at boot and are read‑only.

### 12.1 Window & buckets

```json
{
  "habit_window": { "act1": 32, "act2": 48, "act3": 64, "tutorial": 16, "daily": 32 },
  "H1_bucket": { "fast_max": 1, "slow_min": 3 },
  "H2_bucket": { "diffuse_max": 0.30, "biased_min": 0.55 },
  "H3_bucket": { "undo_dominant_min": 0.40 },
  "H4_bucket": { "long_min": 4 },
  "H5_bucket": { "loose_max": 0.30, "hug_min": 0.60 },
  "H6_bucket": { "shrink_max": -0.05, "grow_min": 0.05 },
  "H7_bucket": { "tidy_max": 0.05, "thrash_min": 0.20 },
  "H8_bucket": { "refrain_min": 3 }
}
```

### 12.2 Operator gates

```json
{
  "O1_min_visits": 2,
  "O2_min_streak": 3,
  "O2_min_dominant_bias": 0.35,
  "O3_score_bump_if_beyond_visited": 0.5,
  "O4_min_manhattan_from_hot": 2,
  "O5_min_wall_hug": 0.60,
  "O6_target_cell": "ECHO_WALL",
  "O7_target_cell": "ECHO_WALL",
  "O8_target_cell": "ECHO_WALL",
  "O9_target_cell": "FOSSIL"
}
```

### 12.3 Engine

```json
{
  "max_attempts": 32,
  "score_jitter": 0.05,
  "min_score": 0.0,
  "default_soft_hard_bias": 0.5,
  "reader_magnitude_scale": 0.5,
  "cold_magnitude_scale":   2.0,
  "reader_rewinds_per_chamber": 999,
  "standard_rewinds_per_chamber": 5,
  "cold_rewinds_per_chamber": 2,
  "snapshot_ring_size": 16
}
```

### 12.4 Save

```json
{
  "save_version": 1,
  "autosave_interval_seconds": 30,
  "keep_backups": 1,
  "max_run_history": 500
}
```

### 12.5 Daily

```json
{
  "daily_pool": ["10_daily_bloom", "11_daily_wren", "12_daily_diamond"],
  "daily_rewrite_cap": 2,
  "daily_soft_hard_bias": 0.6,
  "daily_uses_utc": false
}
```

### 12.6 Substrate expansion (v1.0 reserved, post-v1.0 populated)

```json
{
  "substrates": {
    "cubic":        { "dims": 2, "rotation_step_deg": 90, "shipped_in_v1_0": true },
    "fcc":          { "dims": 3, "rotation_step_deg": 60, "shipped_in_v1_0": false },
    "hex_prism":    { "dims": 3, "rotation_step_deg": 60, "shipped_in_v1_0": false },
    "diamond":      { "dims": 3, "rotation_step_deg": 120, "shipped_in_v1_0": false },
    "icosahedral":  { "dims": 3, "rotation_step_deg": 72, "shipped_in_v1_0": false }
  }
}
```

---

## 13. Godot Resource / JSON Schemas (Index)

Every schema referenced above is filed under `game/echo_lattice/content/schema/`. All are JSON Schema draft‑07 for portability with the Python validator used in CI. Godot equivalents (Resource classes) live in `game/echo_lattice/scripts/`.

| Schema file | Godot Resource | Owner section |
|---|---|---|
| `path_log.schema.json` | `PathLog` (script class) | §3.5, §3.6 |
| `habit_signature.schema.json` | `HabitSignature` (RefCounted) | §4.6 |
| `rewrite.schema.json` | `Rewrite` (Dictionary) | §5.6 |
| `chamber.schema.json` | `Chamber` (Resource) | §6.4 |
| `motif.schema.json` | `Motif` (Resource) | §6.3 |
| `resonance.schema.json` | `Resonance` (Resource) | §6.9 |
| `save.schema.json` | `SaveState` (Resource) | §9.1 |
| `daily.schema.json` | `DailyRun` (row inside SaveState.runs) | §10.6 |

All Godot Resource classes derive from `Resource` and use `@export` typed properties. They are the on‑disk `.tres` mirrors of the JSON schemas, generated by a headless converter (`game/echo_lattice/scripts/build_tres.gd`). If the JSON changes, the `.tres` is rebuilt; the JSON is source of truth.

---

## 14. Change Log & Open Questions

### 14.1 Change log

| Version | Notes |
|---|---|
| v1.0 | Initial systems doc. Aligns with GDD v1.0 vocabulary, encodes Habit Engine v1 semantics, incorporates playable slice's mirror/rotate/thicken operators. |

### 14.2 Open questions (systems‑side)

- **SO‑1** Whether O6/O7/O8 should be replaced or complemented by a habit‑driven mirror operator that reads `dominant_dir` rather than the walked path. Default v1.0: keep both; `forced_op` selects.
- **SO‑2** Whether Rewind should replay the recorder incrementally rather than restore a snapshot, to preserve H7 THRASH history. Default v1.0: snapshot restore, thrash history discarded.
- **SO‑3** Whether the fingerprint should include `rewrite.applied` provenance. Default v1.0: no, to keep signature independent of rewrite path.
- **SO‑4** Whether daily mode should surface a per‑day leaderboard even offline (local cross‑chamber comparison). Default v1.0: no. Ledger only.
- **SO‑5** Whether solvability should be replaced by *walk‑solvability* (reachable within `tempo_start` moves) rather than just BFS reachable. Default v1.0: strict BFS reachable; tempo is decoupled from the solvability oracle.

None of these are blockers. Each has a documented default that ships.

---

## 15. Glossary

| Term | Definition |
|---|---|
| **Lattice** | 2‑D grid substrate; `Lattice` class in `game/echo_lattice/lattice.gd`. |
| **Path** | Sequence of 4‑adjacent cell positions the player has occupied. |
| **PathRecorder** | Class that append‑only records the Path. |
| **PathLog** | Godot Resource wrapping a PathRecorder + undo counter + chamber id + motif boundaries. |
| **Habit Window** | The rolling last `W` steps of the Path used for habit metrics. |
| **HabitSignature** | Immutable fingerprint (H1–H8 + derived) computed from PathRecorder + Lattice. |
| **Rewrite** | Value dict `{name,score,patches,meta}` describing a proposed lattice edit. |
| **Patch** | Atomic `{pos,cell}` edit; multiple patches make one Rewrite. |
| **Operator** | Pure function producing an array of Rewrites from `(Lattice, HabitSignature)`. |
| **RewriteEngine** | Ranks candidates, tie‑breaks with jitter, filters unsolvable, commits the first survivor. |
| **BFS** | Breadth‑first search over the passable graph; `LatticeBFS` in `bfs.gd`. |
| **Solvable** | `start` and `goal` in the same connected component of the passable graph. |
| **Chamber** | One playable puzzle unit; data in `content/chambers/*.json`. |
| **Motif** | Sub‑goal inside a chamber; in v1.0 always a checkpoint entry. |
| **Resonance** | Global constraint that must hold for the chamber to be won. |
| **Tempo** | Move budget for the chamber. |
| **Rune** | Permanent modifier unlocked by clearing a chamber. |
| **Hold** | Once‑per‑chamber token to defer an incoming rewrite (GDD; reserved for v1.0). |
| **Snapshot** | `{lattice, recorder, motifs_satisfied, tempo_left, active_rewrites}` captured at motif commit or chamber start. |
| **Rewind** | Restore a prior Snapshot; consumes a rewind budget entry. |
| **Reset** | Restore the Chamber seed; discards all rewrites; Tempo restored. |
| **Soft rewrite** | Reversible by a designated in‑motif reversal action. |
| **Hard rewrite** | Permanent within a chamber; only Rewind removes it. |
| **Fingerprint** | 64‑bit FNV‑1a hash over a canonical representation; used for determinism assertions. |
| **Daily seed** | Deterministic per‑date seed used by the Daily mode. |
| **Ledger** | Local, private, per‑save histogram of H1–H8 and rewrite counts. |
| **Certifier** | Author‑time solvability + tempo margin checker; runs in CI. |

---

*End of Systems Design v1.0. Next document: `03_TECH_ARCHITECTURE.md` (Godot node layout, autoloads, scene routing, save/IO plumbing). Implementation may begin against this document as‑is; every constant, contract, and pseudocode block is normative.*
