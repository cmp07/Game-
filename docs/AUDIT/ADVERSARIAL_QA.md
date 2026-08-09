# Echo Lattice — Adversarial QA Audit

**Scope:** Cloud-only static + contract audit of `game/echo_lattice/` on `cursor/echo-lattice-rc1`.  
**Mindset:** Break the player’s session with edge timing, bad disks, wrong builds, and device churn — not happy-path bugbash.  
**Companion:** [`docs/RELEASE/BUGBASH.md`](../RELEASE/BUGBASH.md) covers RC softlocks already marked FIXED; this doc hunts what that pass did **not** stress.  
**Automation:** `python3 game/echo_lattice/tests/test_adversarial_qa.py`

---

## Verdict

Ship-blocking product drift remains on **Daily Challenge authority** (FAQ / calendar vs live `GameState`). Several session-integrity edges (cloud push-before-commit, demo↔full save bleed, sticky hold after alt-tab / pad unplug, mid-run locale HUD stale) are **mitigated on this branch**. Remaining items need manual GUI / Deck / dual-install verification.

| Severity | Open | Mitigated this PR |
|---|---|---|
| P0 | 1 | 2 |
| P1 | 3 | 3 |
| P2 | 4 | 0 |

---

## Matrix (requested edges)

| Edge | ID | Severity | Status |
|---|---|---|---|
| Rapid input during rewrite / hold spam | AQ-INPUT-01 | P2 | Guarded by rewrite lock + key-echo ignore; stick spam still Deck-manual |
| Alt-tab mid-rewrite | AQ-FOCUS-01 | P1 | **Mitigated** — clear hold on focus-out; slam timer resumes on focus-in |
| Corrupt save | AQ-SAVE-01 | P1 | Bak recovery OK; **mitigated** type-coercion + OOB clamp; dual-corrupt still wipes to fresh |
| Demo ↔ full confusion | AQ-DEMO-01 | P0 | **Mitigated** — `build_flavor` + queue/score clamp; dual-install userdata still platform-dependent |
| Daily timezone | AQ-DAILY-01 | P0 | **OPEN** — UTC labels exist, but calendar / friend-code authority is orphaned |
| Locale switch mid-run | AQ-L10N-01 | P1 | **Mitigated** — chamber HUD listens to `locale_changed`; subtitles still English stubs |
| Gamepad disconnect | AQ-PAD-01 | P1 | **Mitigated** — glyph fallback + hold clear; menu focus restore still manual |
| Window resize | AQ-VIEW-01 | P2 | Stretch `canvas_items`/`expand` OK; extreme UI-scale + tiny window = Deck checklist |
| Headless vs GUI drift | AQ-HEAD-01 | P1 | **OPEN** — hitstop / UI-scale / Deck layout intentionally no-op headless; juice wall-clock differs |

---

## Findings

### AQ-DAILY-01 — Daily calendar is not the live Daily Challenge (P0 · OPEN)

**Claimed:** [`SUPPORT_FAQ.md`](../RELEASE/SUPPORT_FAQ.md) C1–C4 and [`POSTLAUNCH.md`](../RELEASE/POSTLAUNCH.md) say dailies are UTC, friend-code comparable, and driven by `calendar_90.json` via `DailyCalendar.pick_for_date`.

**Actual:** `GameState.start_daily_run()` ignores `DailyCalendar` / `DailySeeds`. It sets:

- `daily_seed = YYYYMMDD` (int from `Time.get_datetime_dict_from_system(true)`)
- `run_queue = ChamberBook.daily_chamber_indices(daily_seed, 5)` (Fisher–Yates over the **whole campaign book**)

So:

1. Two players on the same UTC date get the same *wing shuffle*, but **not** the authored calendar chamber / `friend_code` / variation.
2. FAQ “compare friend code on the Daily card” has **no runtime surface** wired to this path.
3. After day-90 “catalog hash fallback” never runs in play — only in unused helpers.
4. Demo Daily is Act-I-scoped only because the book is filtered, not because the calendar tags soft-launch days.

**Repro (cloud):** read `game_state.gd` `start_daily_run` vs `daily_calendar.gd`; `rg DailyCalendar game/echo_lattice/scripts` → only the calendar module itself.

**Fix direction (not in this PR — product decision):** either wire `DailyCalendar.today_utc()` into `start_daily_run` (and define how a single `chamber_id` becomes a five-chamber wing), or rewrite FAQ/liveops to match the YYYYMMDD shuffle and drop friend-code promises for 1.0.

**Timezone note:** date math *is* UTC (`true` on `get_datetime_dict_from_system`). Local-midnight confusion is documented correctly; the bug is authority, not tz.

---

### AQ-DEMO-01 — Demo ↔ full save bleed (P0 · mitigated)

**Attack:**

1. Play full game far into Act III; quit (writes `user://save.json` with large `run_queue` / `completed`).
2. Launch with `--demo` (editor / full tree) **or** share userdata with a demo build.
3. Continue → queue indices past Act I → empty chamber / softlock.

Inverse: demo clear saves a 9-chamber queue; full game Continue looks “finished” after Induction.

**Platform wrinkle:** Windows Demo export sets `product_name="Echo Lattice Demo"` (separate userdata). `project.godot` `config/name` stays `"Echo Lattice"`, so **editor `--demo` and non-Windows paths share the full-game folder**.

**Mitigation shipped:**

- Saves stamp `build_flavor: "demo"|"full"`.
- `_sanitize_queue_against_book()` drops OOB indices and prunes score tables to the active `ChamberBook` size.
- Warnings on flavor mismatch.

**Still open:** no forced “Start New Run” prompt on flavor mismatch; demo progress into full still truncates the Continue queue to Act I without migrating.

---

### AQ-SAVE-02 — Cloud push raced ahead of atomic rename (P0 · mitigated)

`SaveManager.save_to_disk()` previously called `SteamService.push_cloud_save()` **after writing `save.json.tmp` but before rotating into `save.json`**. `SteamCloudSave.push_local` reads `user://save.json` — so Cloud received the **previous** commit (or nothing).

**Mitigation:** push only via `_push_cloud_after_commit()` after successful rename/direct write.

**Residual:** Cloud still last-write-wins with “prefer local when both differ” (`steam_cloud_save.gd`) — fine for MVP-off, dangerous when `cloud_save_enabled` flips on without conflict UI. Settings JSON (`SettingsStore`) remains non-atomic (P2).

---

### AQ-FOCUS-01 — Alt-tab mid-rewrite / sticky hold (P1 · mitigated)

Rewrite slam advances on `_process` delta. Godot does **not** set `pause_on_focus_loss` in `project.godot`, so:

- Alt-tab during slam → timer keeps draining → player returns to **settled** fossils (usually OK).
- Hold-to-walk / stick edge could remain armed across focus gaps → surprise move on return (softlock-adjacent if that step hits a checkpoint).

Esc/menu mid-slam already flushes (`chamber_scene.gd` / `_exit_tree`) — covered by BUGBASH SL-4.

**Mitigation:** `NOTIFICATION_APPLICATION_FOCUS_OUT` / `WM_WINDOW_FOCUS_OUT` clears `_hold_dir`; focus-in clears stale hold if a slam is still pending.

**Manual:** Shift+Tab Steam overlay pause (`SteamService`) freezes the tree; confirm hitstop `Engine.time_scale` recovers after overlay+hitstop overlap on a GUI build.

---

### AQ-L10N-01 — Locale switch mid-run (P1 · partial)

Menu listens to `locale_changed`. Chamber HUD did **not** — title, caption, moves, habit stayed in the old language until the next signal.

**Mitigation:** `chamber_scene.gd` refreshes chrome on `locale_changed`.

**Still open:**

- `SubtitleOverlay.STUB_LINES` are hardcoded English — zh_Hans players see EN PA/rewrite lines after switch.
- Demo fresh subtitle `"Demo — Act I · Mirror Birth…"` is hardcoded EN in `menu.gd`.
- Rich presence chamber titles stay EN (`SteamService.set_chamber_presence`).

---

### AQ-PAD-01 — Gamepad disconnect (P1 · mitigated)

No prior `Input.joy_connection_changed` handling. Unplug could leave stick axes asserted and glyphs stuck on pad prompts while the player grabs keyboard.

**Mitigation:**

- `InputGlyphs` falls back to keyboard when joypad list empties.
- `Chamber` clears hold-to-walk on disconnect.

**Manual:** menu focus when the only gamepad drops mid-settings remap; Deck suspend/resume (see STEAM_DECK.md).

---

### AQ-HEAD-01 — Headless vs GUI drift (P1 · OPEN)

Intentional guards cause behavioral forks:

| Path | Headless | GUI |
|---|---|---|
| `Juice.hitstop` | no-op (keeps `time_scale`) | sets `Engine.time_scale` |
| `AccessibilityService.apply_ui_scale` | return | sets `content_scale_factor` |
| `DeckProfile` layout / fullscreen | skipped | mutates window |
| `Juice` VFX clock | wall-clock `get_ticks_msec` | same, but hitstop interaction differs |

`--selftest` can pass while a GUI-only hitstop/overlay interaction fails. Treat headless green as **necessary, not sufficient** for juice/overlay/focus.

---

### AQ-INPUT-01 — Rapid input (P2 · mostly guarded)

| Vector | Status |
|---|---|
| Keyboard OS repeat | Ignored via `event.is_echo()` |
| Hold-to-walk flood | 220 ms / 80 ms cadence |
| Move during slam | Blocked (`is_rewrite_locking`) |
| Undo during slam | Blocked |
| Restart during slam | Allowed (resets) — intentional |
| Double-activate Next on won screen | Godot button; no debounce — can double-advance if signals re-enter (manual) |
| Stick axis chatter | Deadzone 0.5; still mash-test on Deck |

---

### AQ-VIEW-01 — Window resize (P2 · OPEN)

`window/stretch/mode=canvas_items`, `aspect=expand`, base 960×560. Chamber recenters from viewport; menu redraws on `size`. Risk band: UI scale 1.5 + windowed 800×480 + settings overlay — use Deck layout probe, not assumed covered by selftest.

---

### AQ-SAVE-03 — Dual-corrupt / settings corrupt (P2 · OPEN)

If `save.json` **and** `save.json.bak` both fail JSON parse → load returns false → fresh state (progress lost; no user-facing recovery UI).  
`echo_lattice_settings.json` writes in place (no tmp/bak) — kill during settings save can brick a11y prefs until defaults merge.

---

## Mitigations on this branch (code)

| File | Change |
|---|---|
| `scripts/save_manager.gd` | Cloud push after commit; `build_flavor`; OOB queue/score sanitize; bad-type tables → `{}` |
| `scripts/chamber.gd` | Focus-out / joy-disconnect clears hold |
| `scripts/chamber_scene.gd` | `locale_changed` HUD refresh |
| `scripts/input_glyphs.gd` | Joy disconnect → keyboard glyphs |
| `tests/test_adversarial_qa.py` | Contract tests for the above + daily orphan characterization |

---

## Manual GUI checklist (cannot do cloud-only)

1. **Alt-tab mid-slam** on Windows/Linux GUI — return before and after settle; mash WASD.
2. **Shift+Tab overlay** during rewrite punch / hitstop — confirm time_scale and audio resume.
3. **Unplug Xbox pad** mid-corridor with stick held — no autopilot walk; glyphs flip to WASD.
4. **Install Demo + Full on same Windows machine** — confirm separate `%APPDATA%` folders; copy full `save.json` into demo folder and Continue.
5. **Settings → language** mid-chamber — HUD + subtitles (expect subtitle EN gap).
6. **Daily at 23:59 UTC → 00:01 UTC** — Continue yesterday vs Start Daily today; note friend-code absence (AQ-DAILY-01).
7. **Resize** while settings open at UI scale 1.5; Steam Deck 1280×800 path.
8. **Corrupt both save + bak** — boot reaches menu; no crash loop.

---

## Gate commands

```bash
python3 game/echo_lattice/tests/test_adversarial_qa.py
python3 game/echo_lattice/tests/test_rc_polish.py
python3 game/echo_lattice/tests/test_demo_spec.py
python3 game/echo_lattice/tests/test_release_liveops.py
# When Godot available:
godot4 --headless --path game/echo_lattice -- --selftest
```

---

## Sign-off

| Role | Result |
|---|---|
| Cloud adversarial (this doc) | Daily authority **hold**; session edges mitigated |
| GUI / Deck manual | ☐ pending |
| Daily product decision (calendar vs shuffle) | ☐ pending |
