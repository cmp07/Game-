# Echo Lattice — Balance v2 (“One More Run”)

**Doc ID:** `docs/ECHO_LATTICE/14_BALANCE_V2.md`  
**Status:** Implementation-ready balance contract for the 2D habit→geometry slice.  
**Authority:** Numbers live in [`game/echo_lattice/config/balance_v2.json`](../../game/echo_lattice/config/balance_v2.json). This doc explains *why* and *how* they are used. If JSON and this doc disagree on a value, the JSON wins; if they disagree on intent, this doc wins and the JSON is a bug.  
**Companions:** [`01_GDD.md`](01_GDD.md) (fantasy / acts), [`02_SYSTEMS.md`](02_SYSTEMS.md) (habit + rewrite + BFS), habit engine PR (`habit_signature.gd`, `rewrite_engine.gd`, `bfs.gd`).  
**North star:** After a clear *or* a stall, the player should feel “I know what to try differently” — not “the game cheated.” That feeling is the **one more run** loop.

---

## 0. TL;DR

Balance v2 tunes five levers so Echo Lattice sells session addiction without softlocks:

1. **Act curve** — SEED → GROWTH → PRISM escalate window size, rewrite cap, hardness, and BFS-par length — never HP or damage.
2. **Habit archetypes** — classify right-leaners / loopers / zigzaggers from `HabitSignature`, then bias rewrite operator scores toward counters.
3. **Stars** — 1★ for any legal clear; 2★ / 3★ from moves vs BFS par (mode + act slack). Progression never gates on ★.
4. **Anti-frustration** — undo + rewind budgets by mode; STALLED never Game Over; **BFS solvability invariant** after every commit.
5. **Local telemetry** — JSONL under `user://telemetry/` for offline tuning; no network.

Runtime entry points:

| Module | Role |
|---|---|
| `scripts/balance_tuning.gd` | Load / query `balance_v2.json` |
| `scripts/habit_archetype.gd` | Classify signature → archetype + counter weights |
| `scripts/local_telemetry.gd` | Append-only local JSONL events |
| `scripts/star_rater.gd` | Compute ★ from moves vs BFS par |

---

## 1. Design goals for “one more run”

| Goal | Metric (local telemetry) | Target |
|---|---|---|
| Easy start | Act I clear rate | ≥ 0.90 |
| Growing bite | Act II clear rate | ~0.75–0.80 |
| Mastery wall | Act III clear rate | ~0.55–0.65 |
| Fairness trust | `softlock_assert_failed` count | **0** |
| Retry hunger | `one_more_run_proxy` after clear/stall | ≥ 0.50 |
| Star chase | Share of clears with 2★+ | Act I ≥ 0.55; Act III ≥ 0.25 |

Diegetic difficulty only (GDD P3): denser geometry, tighter habit windows, harder rewrite caps — never stat inflation.

---

## 2. Difficulty curve across acts

Three acts × seven chambers = 21 authored clears. Relative difficulty is a unitless scalar applied to maze density / BFS-par targets (see JSON `difficulty_curve.chamber_escalation`).

### 2.1 Act table

| Act | Name | Window `W` | Rewrite cap | Soft/hard bias | Hard ops | Tempo base | ★ par mult | Session (min) |
|---|---|---|---|---|---|---|---|---|
| I | **SEED** | 32 | 1 | 0.25 | Off until chamber index ≥ 4 | 72 | 1.15 | 18–28 |
| II | **GROWTH** | 48 | 2 | 0.50 | On | 84 | 1.00 | 22–36 |
| III | **PRISM** | 64 | 3 | 0.72 | On | 96 | 0.92 | 28–45 |

Tempo formula (also in JSON):

```
tempo = floor((tempo_base + tempo_per_checkpoint * C + 12 * (act - 1)) * mode.tempo_multiplier)
```

### 2.2 Escalation shape

```
relative difficulty
2.5 |                                              *
2.0 |                                 *  *  *  *
1.5 |                    *  *  *  *  *
1.0 |        *  *  *  *
0.5 |  *  *
    +----------------------------------------------→ chamber
      A1................ A2................ A3....
```

- **Act I** teaches: walk → checkpoint → one soft rewrite. Chambers 0–3 forbid hard ops (`fossilize_hot_cell`, `thicken_walked`).
- **Act II** introduces counters that *feel personal* (archetype bias blend 0.65).
- **Act III** stacks cap=3 + higher bias so players must break habits on purpose.

### 2.3 Mode presets (Reader / Standard / Cold)

| Mode | Bias | Magnitude | Undo / chamber | Rewind / chamber | Tempo × | ★ slack |
|---|---|---|---|---|---|---|
| Reader | 0.15 | 0.5 | unlimited (−1) | unlimited (−1) | 1.35 | 1.25 |
| Standard | 0.50 | 1.0 | 24 | 5 | 1.00 | 1.00 |
| Cold | 0.85 | 1.35 | 10 | 2 | 0.85 | 0.90 |

`-1` budgets mean unlimited. Mode multiplies act defaults; it does not rewrite chamber authorship.

---

## 3. Habit archetypes → counters

Classification runs on a `HabitSignature` with ≥ `classifier_window_min_steps` (12) steps. First matching rule wins; else `balanced`. Confidence requires beating the next candidate by `confidence_margin` (0.08) on the dominant feature — otherwise stay `balanced` to avoid noisy counters.

### 3.1 Right-leaner

**Play pattern:** Long cardinal streaks; high `dominant_bias`; low `turn_rate`.

| Detect | Threshold |
|---|---|
| `dominant_bias` | ≥ 0.42 |
| `turn_rate` | ≤ 0.35 |
| `backtrack_rate` | ≤ 0.18 |
| longest straight streak | ≥ 4 |

**Counters (score weights):**

| Operator | Weight | Intent |
|---|---|---|
| `place_deflector` | 1.35 | Wall ahead of the dominant streak |
| `fossilize_hot_cell` | 1.10 | Freeze the overused lane |
| `grow_wall_far_from_path` | 0.85 | Seal unused exits |

**Relief (keep available):** `carve_shortcut`, `widen_hot_corridor` — commitment still pays.

### 3.2 Looper

**Play pattern:** Circles / revisits; low unique-cell ratio; elevated backtracks.

| Detect | Threshold |
|---|---|
| `unique_cells / total_steps` | ≤ 0.55 |
| revisit ratio `(steps − unique) / steps` | ≥ 0.35 |
| `backtrack_rate` | ≥ 0.12 |
| `turn_rate` | ≥ 0.28 |

**Counters:**

| Operator | Weight | Intent |
|---|---|---|
| `fossilize_hot_cell` | 1.40 | Collapse the loop hinge |
| `thicken_walked` | 1.15 | Solidify dense rings (hard; Act II+) |
| `mirror_walked_v` | 0.95 | Duplicate the loop into a trap |

### 3.3 Zigzagger

**Play pattern:** High turn chatter; low directional commitment.

| Detect | Threshold |
|---|---|
| `turn_rate` | ≥ 0.55 |
| `dominant_bias` | ≤ 0.40 |
| `backtrack_rate` | ≤ 0.22 |
| longest streak | ≤ 3 |

**Counters:**

| Operator | Weight | Intent |
|---|---|---|
| `grow_wall_far_from_path` | 1.20 | Seal unexplored noise |
| `mirror_walked_h` | 1.05 | Reflect noisy paths into blocks |
| `widen_hot_corridor` | 0.70 | Soft reward when turns are intentional |

### 3.4 Score blending

When the rewrite engine ranks candidates:

```
final_score = base_score * (1 - blend) + base_score * blend * archetype_weight(op)
```

with `archetype_weight_blend = 0.65` (JSON `rewrite_engine`). Missing weight defaults to `1.0`. BFS rejection still wins over any score.

---

## 4. Star thresholds

Stars measure **route efficiency vs shortest path**, not deaths (there are none).

```
bfs_par = LatticeBFS.shortest_path(lattice_seed).size() + stars.bfs_par_padding
act_mult = acts[act].star_par_multiplier
mode_slack = modes[mode].star_slack

three_cut = ceil(bfs_par * three_star_mult * act_mult * mode_slack)
two_cut   = ceil(bfs_par * two_star_mult   * act_mult * mode_slack)

★ = 1
if moves <= two_cut:   ★ = 2
if moves <= three_cut: ★ = 3
```

Defaults: `three_star_mult = 1.15`, `two_star_mult = 1.55`, `bfs_par_padding = 2`.

| ★ | Meaning |
|---|---|
| 1 | Legal clear (always). Unlocks next chamber. |
| 2 | Competent, not optimal — “I can tighten this.” |
| 3 | Near-BFS with habit tax paid — chase bait for one more run. |

**Non-goals:** No ★ gates on story unlocks. No death bonus. No forced habit-variety ★ (variety is taught by counters, not grades).

After clear, UI may show archetype hint (`display.show_archetype_hint_after_clear`) — silent play still holds; hint is optional glyph / color, not a lecture.

---

## 5. Anti-frustration

### 5.1 Never softlock — BFS invariant

**Invariant (normative):**

> After every chamber load and every committed rewrite, `LatticeBFS.is_solvable(lattice)` is `true`.

Enforcement (matches `RewriteEngine`):

1. Apply patches on a **clone** only.
2. Reject `invalid_patch` (start/goal overwrite, OOB).
3. Reject `unsolvable` via BFS.
4. Cap attempts (`max_attempts = 32`).
5. On exhaust: **keep previous lattice** (`applied = false`). Never ship an unsolvable commit.
6. `assert_on_load`: seed chambers that fail BFS fail closed in CI / loader.

Telemetry event `softlock_assert_failed` must remain at zero. Any firing is a release blocker.

### 5.2 Undo

| Rule | Value |
|---|---|
| Enabled | yes |
| Tempo cost | 1 (Forgive Field waives up to 3) |
| Counts toward H7 | yes (thrash is a habit) |
| Debounce | 120 ms |
| Across checkpoint | no — undo stack clears on rewrite commit |
| Budget | Reader ∞ · Standard 24 · Cold 10 |

Undo appends a mirrored step (systems §3.4) so H7 still sees thrash.

### 5.3 Rewind budgets

Snapshots on `chamber_enter` and `checkpoint_commit`. Rewind restores lattice, path recorder, tempo, and active rewrites.

| Mode | Rewinds / chamber |
|---|---|
| Reader | unlimited |
| Standard | 5 |
| Cold | 2 |

### 5.4 STALLED ≠ Game Over

When tempo hits 0, offer only: **Rewind**, **Reset** (seed lattice; unlocks kept), **Exit** (resume from latest snapshot). `no_game_over: true` is normative.

---

## 6. Telemetry hooks (local)

Sink: `user://telemetry/echo_lattice_balance.jsonl` (append-only JSON Lines). Default **on** for dev/demo builds; settings may disable. **No network upload.**

### 6.1 Events

`run_start`, `chamber_enter`, `move`, `undo`, `checkpoint`, `rewrite_applied`, `rewrite_rejected`, `archetype_classified`, `star_awarded`, `rewind`, `reset`, `stalled`, `chamber_clear`, `run_end`, `softlock_assert_failed`.

Each line includes: `t_ms` (logical or wall for audit only), `schema_version`, `mode`, `act`, `chamber_id`, `seed`, and event-specific payload. No account IDs.

### 6.2 Aggregates for tuning

Offline scripts (or a future editor panel) roll up:

| Aggregate | Use |
|---|---|
| `clear_rate_by_chamber` | Spot spikes vs ideal curve |
| `median_retries_by_chamber` | Frustration hotspots |
| `star_distribution` | Adjust `*_star_mult` / padding |
| `archetype_share` | Retune detect thresholds |
| `rewrite_reject_reasons` | Operator / maze authorship bugs |
| `undo_per_clear` / `rewind_per_clear` | Budget sizing |
| `one_more_run_proxy` | Primary KPI (retry/next within 90s) |

### 6.3 Tuning loop

1. Play / CI smoke → JSONL.  
2. Compare aggregates to §1 targets.  
3. Edit **only** `balance_v2.json`.  
4. Note change in balance changelog section below.  
5. Re-run habit + BFS tests.

---

## 7. Runtime API (contract)

```gdscript
var bal := BalanceTuning.load_default()
var act := bal.act(2)
var mode := bal.mode("standard")
var tempo := bal.tempo_for(act_id, checkpoint_count, "standard")

var arch := HabitArchetype.classify(sig, bal)
var weights := HabitArchetype.counter_weights(arch, bal)
# feed weights into RewriteEngine candidate scoring

var stars := StarRater.rate(moves, bfs_len, act_id, "standard", bal)

LocalTelemetry.emit("chamber_clear", {
  "chamber_id": id,
  "stars": stars,
  "archetype": arch.id,
  "moves": moves,
  "bfs_par": bfs_len,
})
```

Load path: `res://config/balance_v2.json` when the Godot project root is `game/echo_lattice/`. Fallback: `res://echo_lattice/config/balance_v2.json` for monorepo mounts.

---

## 8. Acceptance checks

| ID | Check |
|---|---|
| B2-1 | JSON parses; `schema_version == 2`. |
| B2-2 | All three acts define 7 chambers worth of escalation entries. |
| B2-3 | Archetypes `right_leaner`, `looper`, `zigzagger`, `balanced` present with counters. |
| B2-4 | Star formula awards 1★ on any clear; 3★ cut ≤ 2★ cut. |
| B2-5 | Undo/rewind budgets match mode table; −1 = unlimited. |
| B2-6 | Softlock invariant documented + engine `max_attempts` / fallback match JSON. |
| B2-7 | Telemetry path is `user://` only; event list non-empty. |
| B2-8 | Headless: `BalanceTuning`, `HabitArchetype`, `StarRater` unit tests pass. |

---

## 9. Changelog

| Date | Change |
|---|---|
| 2026-08-09 | Balance v2 initial: act curve, archetypes→counters, stars, anti-frustration, local telemetry + JSON + loaders. |
