# Echo Lattice — Core Gameplay Bug Audit

**Branch audited:** `cursor/echo-lattice-rc1` @ playable root `game/echo_lattice/`  
**Audit branch:** `cursor/audit-bugs-core`  
**Scope:** habit rewrite, BFS solvability, soft/hard adaptation, chamber transitions, softlocks, input locks during juice, goal/player corruption, endless/daily/campaign modes  
**Method:** static read of GDScript + content; Python gates (`validate_chambers.py`, `test_rc_polish.py`, `test_balance_v2.py`, `test_release_liveops.py`). Godot binary not available in this cloud environment — `--selftest` not executed here.

Severity: **P0** ship-blocker / broken progression · **P1** major mode or fairness gap · **P2** incorrect but playable · **P3** polish / edge.

---

## Summary

| ID | Sev | Area | Status |
|---|---|---|---|
| CORE-01 | P0 | Campaign / Daily Continue vs lifetime `completed` | **Fixed** on this branch |
| CORE-02 | P0 | Wing-complete Continue parks on last chamber (SL-6 regress) | **Fixed** on this branch |
| CORE-03 | P1 | Daily ignores `DailyCalendar` / `DailySeeds` / `daily_eligible` | Open |
| CORE-04 | P1 | Endless mode advertised, not implemented | Open |
| CORE-05 | P1 | Soft/hard adaptation + RewriteEngine unwired from playable loop | Open |
| CORE-06 | P1 | Habit archetypes / score bias never affect rewrites | Open |
| CORE-07 | P2 | Stars always rated as mode `"standard"` (ignores daily/reader/cold) | Open |
| CORE-08 | P2 | Hitstop (`Engine.time_scale`) stretches rewrite input lock | Open |
| CORE-09 | P2 | Undo across checkpoint clears *all* echoes (vs balance “no undo across CP”) | Open |
| CORE-10 | P2 | `_recover_softlock` can strip puzzle-critical fossils | Open |
| CORE-11 | P3 | Screenshot helpers set `queue_pos = chamber_id` | Open |
| CORE-12 | P3 | Empty `get_chamber` leaves prior grid loaded | Open |

Python gates after the P0 fix: **OK** (chambers validate; rc polish + balance_v2 + liveops green).

---

## P0 — Fixed

### CORE-01 — Continue skips using lifetime `completed`

**Repro**

1. Clear the campaign (or any set of chamber indices).
2. Menu → **Start New Run** (queue resets to head; habit resets).
3. Immediately **Continue** (or quit/relaunch and Continue without playing).
4. Observe: Continue jumps to the first index *not* in lifetime `completed`, or to the wing tail — not chamber 0 of the new run.
5. Variant: clear campaign chambers `{0,2,4}`, start **Daily** whose queue includes those ids, Continue without playing → Daily skips campaign-cleared rooms.

**Root cause**

`continue_run()` skipped with `completed.has(...)`, but `completed` is lifetime and is **not** cleared by `start_new_run()` / `start_daily_run()`. Per-run progress and lifetime clears were the same dictionary.

**Fix (landed)**

- Added `GameState.run_cleared` (per-wing clears).
- `record_chamber_win` sets both `completed` and `run_cleared`.
- New runs clear `run_cleared` only.
- `continue_run` / `can_continue` consult `run_cleared`.
- Save v2 persists `run_cleared`; legacy loads seed it from `completed` once, then Start New / Daily wipe it.

**Files:** `scripts/game_state.gd`, `scripts/save_manager.gd`, `scripts/main.gd`, `tests/test_rc_polish.py`.

---

### CORE-02 — Finished wing still allows Continue into last room

**Repro**

1. Clear every chamber in the active queue (wins) without pressing Next on the last win, **or** load a legacy save parked at `queue_pos = len-1` with all cleared.
2. Return to menu — Continue stays enabled (BUGBASH SL-6 claimed otherwise).
3. Continue reloads the last chamber forever.

**Root cause**

When the skip loop exhausted the queue, `continue_run()` **parked** `queue_pos` on the last index, so `is_run_complete()` (`queue_pos >= size`) stayed false. Menu Continue then called `show_chamber()` unconditionally.

**Fix (landed)**

- Do not clamp `queue_pos` backward past end of queue.
- `can_continue()` returns false if every remaining queue entry is `run_cleared`.
- `_on_menu_continue` routes to end screen when `is_run_complete()` after `continue_run()`.

---

## P1 — Open (document only)

### CORE-03 — Daily mode does not use authored daily pipeline

**Repro**

1. Inspect `GameState.start_daily_run()` → `ChamberBook.daily_chamber_indices(seed, 5)`.
2. Compare with `DailyCalendar.today_utc()` / `DailySeeds.pick_for_date()` and chamber `daily_eligible` flags.
3. Ship bar in `docs/RELEASE/RC1_README.md` requires UTC calendar / catalog hash; runtime never calls those classes.

**Root cause**

Daily wing is a Fisher–Yates shuffle of **all** campaign indices from `YYYYMMDD`, then sorted. `content/daily/calendar_90.json`, `seeds.json`, and `daily_eligible` are unused by the playable path (only by release/liveops tests).

**Recommended fix**

Wire `start_daily_run` through `DailyCalendar.pick_for_date` (fallback `DailySeeds`), resolve `chamber_id` / slug via `ChamberBook.get_chamber_by_content_id`, build a 5-chamber wing from eligible content, keep UTC date label/seed for meta + Steam presence.

---

### CORE-04 — Endless mode missing

**Repro**

1. RC1 README: “Campaign / Daily / Endless run entirely offline.”
2. Menu exposes Start / Continue / Daily only — no endless entry, no `run_mode == "endless"`.

**Root cause**

Mode never implemented in `GameState` / `menu.gd` / `main.gd`.

**Recommended fix**

Either implement a seeded endless queue (reuse daily catalog + rising acts) or remove Endless from ship-facing copy until it exists.

---

### CORE-05 — Soft/hard adaptation unwired

**Repro**

1. `BalanceTuning.soft_hard_bias` / `hard_ops_allowed` / `enabled_ops` / `rewrite_cap` load from `config/balance_v2.json`.
2. Playable `chamber.gd` rewrite path only applies authored `transform` to `moves_since_checkpoint` — never reads those dials.
3. Chamber JSON `identity.soft_hard_bias` is loaded into records but dropped by `ChamberLoader.to_playable`.

**Root cause**

Balance v2 / RewriteEngine design was never connected to the elevated path-transform loop. Soft vs hard ops exist only as config + unit tests.

**Recommended fix**

Either (a) implement a minimal RewriteEngine that filters/candidates ops with `enabled_ops` + `soft_hard_bias`, or (b) mark balance soft/hard as design-only until wired and stop claiming runtime adaptation in balance docs for RC1.

---

### CORE-06 — Habit rewrite does not use archetypes

**Repro**

1. Move enough to bias `habit_profile` / `move_ring`.
2. Trigger checkpoints — fossils follow geometric transforms of the move buffer only.
3. `HabitArchetype` + `RewriteScoreBias` have no callers from `chamber.gd` / `main.gd`. There is no `HabitSignature` / `RewriteEngine` script in tree.

**Root cause**

Classifier helpers are orphaned relative to the playable rewrite. Habit HUD/audio read direction counts; fossils do not.

**Recommended fix**

Build a `HabitSignature` from `move_ring` + path cells; pass through `RewriteScoreBias.apply` when selecting fossil candidates (or bias which transform / magnitude). Until then, treat “habit rewrite” as path echo only.

---

## P2 — Open

### CORE-07 — Star rating ignores active mode

**Repro / cause**

`GameState.record_chamber_win` / `last_stars` call `StarRater.rate(..., "standard")` even when `run_mode == "daily"`. Balance modes `reader` / `cold` slack never apply.

**Fix**

Pass `run_mode` (and map daily → configured mode id) into `StarRater`.

---

### CORE-08 — Juice hitstop extends rewrite input lock

**Repro / cause**

`Juice.rewrite_punch` → `hitstop` sets `Engine.time_scale` ~0.06. Chamber `_process` advances `pending_echo_timer` with **scaled** `delta`, while Juice restores timescale on wall-clock. Slam duration and movement lock stretch beyond `REWRITE_DURATION` (0.90s). Restart still works; undo/move stay blocked longer than the art beat.

**Fix**

Advance rewrite settle on wall-clock (mirror Juice), or skip hitstop while rewrite-locking, or drive slam with `Engine.get_process_delta_time()` unscaled via `Time.get_ticks_msec()`.

---

### CORE-09 — Undo vs checkpoint contract mismatch

**Repro / cause**

`balance_v2.json` / `14_BALANCE_V2.md`: cannot undo across checkpoint. Vertical slice README allows undo that reverts rewrite. Runtime: undo past a CP restore sets that CP live again and `_clear_all_echoes()` wipes **every** fossil (including earlier CPs).

**Fix**

Pick one contract. If no undo across CP: clear undo stack on rewrite commit. If undo across CP: store per-rewrite echo deltas and restore only those.

---

### CORE-10 — Softlock recovery may delete intended walls

**Repro / cause**

Incremental `_would_still_be_reachable` should keep cumulative sets solvable; recovery is a belt-and-suspenders path. When it fires, newest-first strip / full echo clear can remove authored difficulty. Telemetry `softlock_assert_failed` is the signal.

**Fix**

Keep recovery; add CI assert that auto-solver playthroughs never emit recovery; investigate any chamber that does.

---

## P3 — Open

### CORE-11 — Screenshot `queue_pos = chamber_id`

`main.gd` `--screenshot chamber:N` sets `queue_pos = cidx`. Harmless for capture; wrong if that path is reused for play.

### CORE-12 — Invalid chamber id keeps old grid

`load_chamber` returns early on empty book entry without clearing `grid` / `player_pos` — stale board if `GameState.current_chamber` is corrupt.

---

## Systems notes (no bug id)

| System | Playable behavior | Design / config |
|---|---|---|
| Habit rewrite | Path buffer → transform → pending echoes → slam → ECHO_WALL | Archetypes, rewrite ops, caps |
| BFS solvability | Per-candidate + post-flush BFS; recover; Python + `--selftest` playthrough | `LatticeBFS.is_solvable` name in balance JSON only |
| Softlocks | Movement/undo locked while `pending_echoes`; flush skips player/goal; Esc flushes | Matches BUGBASH SL-1..4 |
| Goal/player corruption | Flush never fossils `player_pos` / `goal_pos`; win path separate | OK at P0 |
| Campaign | `acts.json` order via `ChamberBook` | OK |
| Daily | Shuffle of campaign indices | Calendar/seeds unused (CORE-03) |
| Endless | — | Missing (CORE-04) |

---

## Test evidence

```text
python3 game/echo_lattice/tests/validate_chambers.py          → result: OK (39 chambers)
python3 -m unittest tests.test_rc_polish tests.test_balance_v2 → OK (24 tests)
python3 game/echo_lattice/tests/test_release_liveops.py       → 45 passed
godot4 --headless --path game/echo_lattice -- --selftest      → NOT RUN (no Godot in env)
```

Manual still recommended: Start New after full clear → Continue stays on queue head; Daily after campaign clears; rewrite mash during slam; win→menu→Continue skip; wing finish disables Continue.
