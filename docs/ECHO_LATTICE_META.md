# Echo Lattice — Meta Shell Spec

**Codename:** Echo Lattice  
**Product slot:** Game 1 — tension / horror vignette (see [`GAME_PLAN.md`](GAME_PLAN.md))  
**Milestone:** M0 — meta shell only. No gameplay scene yet.

This document is the source of truth for how the Echo Lattice **meta layer** behaves. The meta layer is everything outside a live run: menus, save file, unlocks, stats, run history, and the daily seed.

Gameplay ("what happens inside a chamber") is intentionally out of scope for this document.

---

## Goals

The meta shell exists so that:

1. A single day-one player can boot the game, pick a chamber, play, die/clear, and see their run recorded — without any content beyond a run scene being wired up.
2. Every downstream design decision (unlock curve, daily leaderboard, seed sharing, cosmetics, achievements) has a stable API to hang off of. The `SaveService` shape is the contract.
3. The game can be tested headlessly on CI. All meta behaviour is covered by scripts under [`game/tests/`](../game/tests).

Non-goals for M0: cloud sync, Steam achievements, online leaderboards, cosmetics UI, controller remapping.

---

## Repo layout (this milestone)

```
game/
  project.godot                 # Godot 4 project; declares autoloads
  icon.svg
  scripts/
    save_service.gd             # autoload: /root/SaveService
    game_session.gd             # autoload: /root/GameSession
    chamber_catalog.gd          # static data + unlock rules
    meta_ui.gd                  # shared UI helpers (colors, buttons)
    meta_main_menu.gd
    meta_chamber_select.gd
    meta_daily_screen.gd
    meta_stats_screen.gd
    meta_run_history.gd
    meta_options_screen.gd
  scenes/
    meta/
      main_menu.tscn
      chamber_select.tscn
      daily_screen.tscn
      stats_screen.tscn
      run_history.tscn
      options_screen.tscn
    game/                       # run scene(s) live here in M1+
  tests/
    test_save_service.gd        # headless: godot -s tests/test_save_service.gd
    test_meta_menu.tscn         # headless: godot res://tests/test_meta_menu.tscn
    test_meta_menu.gd
```

`res://scenes/meta/main_menu.tscn` is the boot scene.

---

## SaveService — API contract

Autoloaded as `SaveService`. Signals are the primary integration point; UI screens re-render off them rather than polling.

### Signals

| Signal | Payload | Emitted when |
|---|---|---|
| `save_updated` | — | Any persistent field changed. Broadest signal; menus rebuild on this. |
| `stats_updated` | — | The `stats` block specifically changed. |
| `unlocks_changed` | `kind: String` in `{"chamber","modifier","cosmetic"}` | An unlock was granted for the first time. |
| `run_recorded` | `run: Dictionary` | A run row was appended to history. |
| `settings_changed` | — | An `settings.*` value changed. |
| `saved_to_disk` | `path: String` | Successful disk write. |
| `loaded_from_disk` | `path: String` | Successful disk read (including boot). |
| `save_error` | `reason: String` | I/O or parse failure. Debug/telemetry only. |

### Methods

Persistence:

- `load_from_disk() -> bool`
- `save_to_disk(force := false) -> bool` — writes atomically via `save.json.tmp` + `DirAccess.rename`, keeps `save.json.bak`.
- `wipe(reset_in_memory := true) -> void`

Unlocks:

- `is_chamber_unlocked(id) -> bool`
- `unlock_chamber(id) -> bool` — returns `true` iff newly unlocked
- `unlock_modifier(id) -> bool`
- `unlock_cosmetic(id) -> bool`
- `unlocked_chambers() -> Array`

Settings:

- `get_setting(key, default = null) -> Variant`
- `set_setting(key, value) -> void`

Runs:

- `record_run_start(chamber_id, seed, mode := "standard", modifiers := PackedStringArray()) -> Dictionary`
- `record_run_end(run, outcome, run_stats := {}) -> Dictionary` — `outcome` ∈ `{"clear","death","abandoned"}`
- `active_run() -> Dictionary`
- `has_active_run() -> bool`
- `clear_active_run() -> void`
- `run_history() -> Array`
- `stats() -> Dictionary`

Daily:

- `daily_datestamp(unix_secs := -1) -> String` — `YYYY-MM-DD`, UTC
- `daily_seed(datestamp := "") -> int` — deterministic 64-bit FNV-1a over `"echo-lattice/daily/v1|<date>"`
- `has_played_today() -> bool`

Autosave is a 0.5 s debounced write. `_notification(NOTIFICATION_WM_CLOSE_REQUEST | NOTIFICATION_EXIT_TREE)` forces a final flush.

### On-disk format (`user://save.json`)

```jsonc
{
  "version": 1,
  "created_at_utc": "2026-08-08T00:00:00",
  "updated_at_utc": "2026-08-08T00:12:34",
  "profile": { "name": "Operator" },
  "unlocks": {
    "chambers":   ["ec_01_boot", "ec_02_hum"],
    "modifiers":  [],
    "cosmetics":  []
  },
  "settings": {
    "master_volume": 1.0, "sfx_volume": 1.0, "music_volume": 0.8,
    "fullscreen": false, "reduce_motion": false, "screen_shake": true
  },
  "stats": {
    "runs_started": 12, "runs_completed": 5, "runs_failed": 6, "runs_abandoned": 1,
    "total_time_sec": 812.4,
    "best_time_per_chamber": { "ec_01_boot": 74.3 },
    "clears_per_chamber":    { "ec_01_boot": 4, "ec_02_hum": 1 },
    "deaths_per_chamber":    { "ec_01_boot": 1, "ec_02_hum": 5 },
    "daily_streak_current": 2, "daily_streak_best": 4,
    "last_daily_date": "2026-08-08", "last_daily_outcome": "clear"
  },
  "runs": [ /* newest-first, capped at RUN_HISTORY_CAP (50) */ ],
  "active_run": { /* {} unless a run is in progress */ }
}
```

### Migration policy

- `SAVE_VERSION` starts at `1`.
- On load, `_migrate()` deep-merges any missing keys against a fresh save so legacy files never crash the UI.
- Bump `SAVE_VERSION` and add a version-specific branch in `_migrate()` when the schema changes in a breaking way.
- Never remove fields; deprecate them by ignoring instead.

### Daily seed

- Computed as FNV-1a 64-bit of `"echo-lattice/daily/v1|YYYY-MM-DD"`.
- Deterministic across platforms and Godot builds (pure GDScript, no engine RNG).
- Namespace prefix (`DAILY_SEED_NAMESPACE`) is bumpable — bumping it resets everyone's daily.
- One recorded daily run per UTC day: `has_played_today()` returns true after any daily-mode run ends today.

Streak semantics:

- A `clear` extends `daily_streak_current` iff `last_daily_date == yesterday_utc`, otherwise resets to 1.
- Any non-clear outcome (`death` / `abandoned`) resets `daily_streak_current` to 0.
- `daily_streak_best` is a running max.

---

## ChamberCatalog

Static, in-code list of chambers (M0). Migrated to `.tres` resources later without breaking `SaveService`.

Unlock rule kinds:

| `kind` | Extra fields | Meaning |
|---|---|---|
| `always` | — | Available from first boot. |
| `chamber_cleared` | `chamber_id` | Available after ≥1 clear of that chamber. |
| `runs_completed` | `count` | Available after `runs_completed >= count`. |

`ChamberCatalog.refresh_unlocks(save)` is called after every run end and promotes any newly-satisfied chambers into the persistent unlock list.

Starter roster:

| id | Name | Difficulty | Unlock |
|---|---|---|---|
| `ec_01_boot` | Booting the Lattice | 1 | always |
| `ec_02_hum` | The Hum | 2 | clear `ec_01_boot` |
| `ec_03_signal` | Signal Bleed | 3 | clear `ec_02_hum` |
| `ec_04_silence` | Room 4 Is Silent | 4 | 5 runs completed |
| `ec_05_choir` | The Choir | 5 | clear `ec_04_silence` |

---

## Meta menu screens

All screens share [`meta_ui.gd`](../game/scripts/meta_ui.gd) for colors + typography and rebuild their view on `SaveService.save_updated` so unlocks and stats stay live.

| Scene | Purpose |
|---|---|
| `main_menu.tscn` | Boot. Continue/Quick Run, nav buttons, profile summary, today's daily card. |
| `chamber_select.tscn` | One card per chamber with clears/deaths/best. Locked cards show `unlock_hint()`. |
| `daily_screen.tscn` | Date, short-seed, picked chamber, streak, single-attempt gating. |
| `stats_screen.tscn` | Totals grid + per-chamber table (clears, deaths, best, par). |
| `run_history.tscn` | Last N runs — when, chamber, mode, seed, duration, outcome. |
| `options_screen.tscn` | Audio sliders, display/a11y toggles, force-save, wipe-save. |

Escape / `ui_meta_back` returns to the main menu from any subscreen.

---

## GameSession contract for the run scene (M1+)

`GameSession` (autoload) is the bridge between menu and gameplay. When gameplay lands, the run scene must:

1. Read `GameSession.active_chamber_id`, `active_seed`, `active_mode`, `active_modifiers`.
2. Seed all runtime randomness deterministically from `active_seed` (so daily-seed replays match across players).
3. Call `GameSession.end_run(outcome, run_stats)` exactly once when the run ends.
   - `outcome` ∈ `{"clear","death","abandoned"}`
   - `run_stats` is a free-form `Dictionary` of counters (kills, pickups, hits taken, …) that get merged into the run row for later stats rollups.

`GameSession` forwards the call to `SaveService`, runs unlock promotion, and switches back to the meta shell.

---

## Testing

Two headless harnesses:

```bash
# SaveService unit tests
godot --headless --path game -s tests/test_save_service.gd

# Meta menu instantiation smoke test
godot --headless --path game res://tests/test_meta_menu.tscn
```

Both exit 0 on success, non-zero on failure — safe to wire into CI.

The SaveService test covers:

- fresh-save defaults
- daily seed determinism (same date → same seed; different dates → different seeds)
- unlock semantics + signal emission + catalog gating
- full run lifecycle (start/end, per-chamber counters, best-time tracking, ring-buffer cap)
- save/load roundtrip
- migration of a legacy schema-less save

The meta menu test instantiates every screen against a pre-populated save to catch missing preloads, bad node paths, and signal typos.
