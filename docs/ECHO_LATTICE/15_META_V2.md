# Echo Lattice — Meta Retention v2

**Codename:** Echo Lattice  
**Document:** `15_META_V2.md`  
**Milestone:** Meta Retention (post M0 shell)  
**Companions:** [`14_BALANCE_V2.md`](14_BALANCE_V2.md) (★ thresholds), M0 shell (`SaveService` contract), [`02_SYSTEMS.md`](02_SYSTEMS.md) §9–10

This document is the source of truth for **META v2**: the retention layer that turns a single vignette into a habit of short returns — without live-service economy, grind achievements, or online leaderboards.

---

## 0. Goals

1. **Stars** persist per chamber and fuel milestone achievements — never gate progression.
2. **Daily + weekly seeds** give shared offline challenges (friend-comparable, no network).
3. **Museum of Selves** archives prior-run habit fossils so ghost races and self-comparison are first-class.
4. **Streaks** reward showing up (play / daily clear / weekly clear) with soft, non-punitive breaks.
5. **35 achievements** — milestone-based only (GDD §15 A26).
6. **NG+** reopens the wing with tighter habit pressure after Act I clear.
7. **Short-run pacing** targets an 8–15 minute “one more wing slice” so sessions fit Steam Deck / evening play.

Non-goals: cloud leaderboards, battle pass, cosmetic gacha, achievement grind loops, forcing daily play for unlocks.

---

## 1. Save schema (version 2)

Path: `user://save.json` (same as M0). `version` bumps to **2**. Migration deep-merges missing keys from a fresh v2 template.

```jsonc
{
  "version": 2,
  "profile": { "name": "Operator", "ng_plus_unlocked": false, "ng_plus_cycles": 0 },
  "unlocks": {
    "chambers": ["ec_01_boot"],
    "modifiers": [],
    "cosmetics": [],
    "runes": [],
    "achievements": []
  },
  "stars": {
    // chamber_id -> best stars earned (1..3). Absent = never cleared.
    "best": {},
    "total_earned": 0
  },
  "streaks": {
    "play_current": 0, "play_best": 0, "play_last_date": "",
    "daily_clear_current": 0, "daily_clear_best": 0, "daily_last_date": "",
    "weekly_clear_current": 0, "weekly_clear_best": 0, "weekly_last_id": ""
  },
  "seeds": {
    "last_daily_date": "",
    "last_daily_outcome": "",
    "last_weekly_id": "",
    "last_weekly_outcome": ""
  },
  "museum": {
    // newest-first ring buffer; see §4
    "selves": [],
    "cap": 48
  },
  "ng_plus": {
    "active": false,
    "cycle": 0,
    "modifiers": []
  },
  "pacing": {
    "short_runs_completed": 0,
    "last_session_sec": 0.0,
    "best_short_run_sec": 0.0
  },
  "stats": { /* M0 counters + */ "ghost_races": 0 },
  "runs": [],
  "active_run": {},
  "settings": {}
}
```

Authoritative tunables + achievement catalog live in:

- [`game/echo_lattice/config/meta_v2.json`](../../game/echo_lattice/config/meta_v2.json)
- [`game/echo_lattice/config/achievements_v2.json`](../../game/echo_lattice/config/achievements_v2.json)

---

## 2. Stars

Stars are **awarded at run clear** by the Balance v2 `StarRater` (or a caller-supplied rating). META v2 only **ledgers** them.

| Rule | Behavior |
|---|---|
| Store | `stars.best[chamber_id] = max(previous, awarded)` |
| Totals | `stars.total_earned` sums best-of across chambers (not cumulative attempts) |
| Progression | Never required to unlock chambers or NG+ |
| Modes | Best is tracked per `chamber_id` only (mode-agnostic) unless `run_stats.track_mode_stars` is set |
| UI | Chamber cards show `★` / `★★` / `★★★`; Museum entries store the star of that run |

Acceptance:

- **S2-1** Clear with 2★ then 3★ → best becomes 3; total reflects 3 for that chamber.
- **S2-2** Death / abandon never writes stars.
- **S2-3** Re-clear with fewer stars does not lower best.

---

## 3. Daily & weekly seeds

Deterministic 64-bit FNV-1a over a namespaced string (pure GDScript / mirrored Python — not `hash()`).

| Mode | Namespace | Key | Chamber pick |
|---|---|---|---|
| Daily | `echo-lattice/daily/v2` | `YYYY-MM-DD` UTC | `DAILY_POOL[seed % len]` |
| Weekly | `echo-lattice/weekly/v2` | ISO `YYYY-Www` UTC | `WEEKLY_POOL[seed % len]` |

Chamber RNG seed: `fnv1a(key + ":" + chamber_id)`.

Attempt policy:

- **Daily:** one *recorded* attempt per UTC day. Retries overwrite the same ledger row. Streak (§5) only extends on `clear`.
- **Weekly:** one recorded attempt per ISO week. Same overwrite rule. Weekly streak extends only on clear of that week’s challenge.

Sharing string (clipboard, offline):  
`EL D 2026-08-09 · <chamber> · <moves>m · ★<n> · fp 0x…`

Acceptance:

- **DW-1** Same UTC date → identical daily seed on Windows/Linux.
- **DW-2** Same ISO week → identical weekly seed.
- **DW-3** Midnight / week rollover does not mutate an in-progress run’s captured seed.

---

## 4. Museum of Selves

The Museum archives a **Self** — a compact fossil of who you were on a clear — so the lattice’s “transcript of behavior” is browsable between runs.

### 4.1 Self record

```jsonc
{
  "id": "self_20260809_0012",
  "created_at": "2026-08-09T01:22:00Z",
  "chamber_id": "ec_03_signal",
  "mode": "standard",
  "seed": 123456789,
  "stars": 2,
  "moves": 48,
  "undos": 1,
  "outcome": "clear",
  "ng_plus": false,
  "habit": {
    "dominant": "right",
    "dominant_bias": 0.62,
    "turn_rate": 0.21,
    "backtrack_rate": 0.04,
    "archetype": "right_leaner",
    "fingerprint": 0
  },
  "ghost": {
    // optional compact path: array of [x,y] every Nth step (stride from config)
    "stride": 2,
    "path": [[1,1],[3,1],[3,4]]
  },
  "title": "The Right-Leaner of Signal Bleed"
}
```

### 4.2 Rules

- Only `clear` outcomes archive (config: `museum.archive_on_clear = true`).
- Ring buffer capped at `museum.cap` (default 48); oldest dropped.
- Titles are generated from archetype + chamber display name (deterministic).
- **Ghost race:** starting a run with `mode = "ghost"` and `modifiers` including `museum:<self_id>` loads that path for overlay. Completing increments `stats.ghost_races`.
- Museum UI is read-only browsing + “Race this self”.

Acceptance:

- **M-1** Clear → museum count +1; fields persist across save/load.
- **M-2** Cap enforced (49th clear drops oldest).
- **M-3** Death does not archive.

---

## 5. Streaks

Three independent streaks. All date math is **UTC**.

| Streak | Extends when | Breaks when |
|---|---|---|
| `play_*` | Any run ends on a new UTC day contiguous with `play_last_date` | Gap ≥ 2 days |
| `daily_clear_*` | Daily-mode **clear** contiguous with yesterday | Missed day **or** non-clear daily |
| `weekly_clear_*` | Weekly-mode **clear** for consecutive ISO weeks | Missed week **or** non-clear weekly |

Soft policy: missing a day zeroes current but **never** erases best. Achievements listen to best and current.

Acceptance:

- **ST-1** Clear daily Mon + Tue → current = 2.
- **ST-2** Death on Wednesday daily → current = 0; best unchanged.
- **ST-3** Play streak counts abandons (showing up matters).

---

## 6. Achievements (35)

Catalog: `achievements_v2.json`. Each entry:

```jsonc
{
  "id": "daily_week",
  "title": "Seven Echoes",
  "desc": "Hold a 7-day daily clear streak.",
  "icon": "streak",
  "secret": false,
  "rule": { "kind": "streak_at_least", "streak": "daily_clear_best", "value": 7 }
}
```

Rule kinds (evaluated after every `record_run_end` and museum write):

| kind | Fields | Meaning |
|---|---|---|
| `stat_at_least` | `stat`, `value` | `stats[stat] >= value` |
| `stars_total_at_least` | `value` | total best stars |
| `stars_chamber_at_least` | `chamber_id`, `value` | best for chamber |
| `chambers_cleared_at_least` | `value` | distinct chambers with ≥1 clear |
| `streak_at_least` | `streak`, `value` | named streak field |
| `museum_count_at_least` | `value` | selves length |
| `flag_true` | `path` | dotted path into save is true |
| `ng_plus_cycle_at_least` | `value` | `profile.ng_plus_cycles` |
| `short_runs_at_least` | `value` | pacing counter |
| `all_of` / `any_of` | `rules` | compose |

Unlocks are idempotent; emit `achievement_unlocked(id)`. Steam mapping is a later export concern — local ids are stable.

Full roster (35): see config file. Categories: onboarding, stars, daily/weekly, museum, streaks, NG+, pacing/modes, mastery.

---

## 7. NG+

**Unlock:** clear every chamber in `ng_plus.unlock_chambers` (default Act I roster of 7) at least once on any mode.

**Activate:** toggle on Meta Hub → NG+ panel. Sets `ng_plus.active = true`, increments `cycle` on each full-wing clear while active.

**Modifiers** (stacked from config, scaled by `min(cycle, max_cycle_scale)`):

| id | Effect |
|---|---|
| `tighter_window` | Habit window −8 steps / cycle (floor 24) |
| `harder_bias` | `soft_hard_bias + 0.08` / cycle |
| `strict_stars` | Star slack × 0.9 / cycle |
| `ghost_pressure` | Start each chamber with a random Museum self overlay if any exist |

NG+ clears archive Museum selves with `ng_plus: true`. Deactivating NG+ does not wipe cycle count.

Acceptance:

- **NG-1** Unlock fires exactly when the unlock set is covered.
- **NG-2** Active NG+ tags runs and museum entries.
- **NG-3** Cycle increments only on full-wing clear while active.

---

## 8. Short-run pacing

Design target: a **Short Run** is a queued micro-session players can finish in one sitting.

| Beat | Target |
|---|---|
| Queue length | 3 chambers (or 1 daily / 1 weekly) |
| Per-chamber aspirational | 2–4 minutes |
| Interstitial (meta between) | ≤ 15 seconds |
| Total short-run envelope | **8–15 minutes** |
| Soft overage warn | > 18 minutes (telemetry only; no punishment) |

`ShortRunPacing` exposes:

- `plan_short_run(kind)` → `{ chambers[], seed_mode, budget_sec }`
- `mark_session(elapsed_sec, completed: bool)` → updates `pacing.*`
- HUD helper copy: “Short Run · ~12 min”

Acceptance:

- **P-1** Daily short-run plan length = 1; standard short-run = 3.
- **P-2** Completing within budget increments `short_runs_completed`.

---

## 9. Runtime map (Godot)

| Script | Role |
|---|---|
| `scripts/meta/meta_v2.gd` | Facade autoload candidate — wires services |
| `scripts/meta/meta_save.gd` | Load/save/migrate v2 |
| `scripts/meta/seed_clock.gd` | Daily/weekly FNV seeds |
| `scripts/meta/star_ledger.gd` | Best-star bookkeeping |
| `scripts/meta/streak_service.gd` | Play/daily/weekly streaks |
| `scripts/meta/museum_of_selves.gd` | Archive + query selves |
| `scripts/meta/achievement_service.gd` | Rule eval + unlock |
| `scripts/meta/ng_plus_service.gd` | Unlock / modifiers / cycle |
| `scripts/meta/short_run_pacing.gd` | Session plans + budgets |
| `scripts/meta/ui/*` | Hub, Museum, Achievements, Weekly, NG+ screens |

Scenes under `scenes/meta/` are thin shells; UI is built in script (M0 style) for easy reskin.

---

## 10. Testing

```bash
python3 game/echo_lattice/tests/test_meta_v2.py
```

Covers schema, FNV seeds, star ledger, streaks, museum cap, all 32 achievements’ rule shapes, NG+ unlock, short-run plans, and doc presence.

Optional (when Godot is on PATH):

```bash
godot --headless --path game/echo_lattice -s tests/run_meta_v2_gd.gd
```

---

## 11. Acceptance matrix (MR-*)

| ID | Claim |
|---|---|
| MR-1 | Fresh save migrates to version 2 with empty museum and zero streaks |
| MR-2 | Daily/weekly seeds stable across platforms for fixed dates |
| MR-3 | Stars never decrease; deaths write none |
| MR-4 | Museum archives clears only; enforces cap |
| MR-5 | ≥30 achievements defined; each has a known rule kind |
| MR-6 | NG+ unlocks after Act I coverage; modifiers scale with cycle |
| MR-7 | Short-run plan budgets fall in 8–15 minutes for standard kind |
| MR-8 | Streak best survives a break |

---

## 12. Changelog

| Date | Note |
|---|---|
| 2026-08-09 | META v2 initial: stars ledger, daily/weekly seeds, Museum of Selves, streaks, 35 achievements, NG+, short-run pacing + Godot services + JSON + tests. |
