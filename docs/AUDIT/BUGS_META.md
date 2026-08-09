# Echo Lattice — Meta / UI / Save Bug Audit

**Scope:** SaveManager atomicity, Continue, settings persistence, menus, demo flags, Steam stub, locale, a11y settings, crash-log hooks  
**Code base:** `game/echo_lattice/` on `cursor/echo-lattice-rc1`  
**Audit branch:** `cursor/audit-bugs-meta`  
**Date:** 2026-08-09  

Severity:

| Sev | Meaning |
|---|---|
| **P0** | Progress loss, softlock, or ship-blocker for demo/cloud/Continue |
| **P1** | Clear functional gap players will hit before/at launch |
| **P2** | Incorrect UX / i18n / docs drift; workaround exists |
| **P3** | Polish, latent, or test-only |

Fixes landed on this branch are marked **FIXED**.

---

## Summary

| Sev | Open | Fixed this PR |
|---|---|---|
| P0 | 0 | 3 |
| P1 | 6 | 0 |
| P2 | 9 | 0 |
| P3 | 5 | 0 |

---

## P0

### META-P0-01 — Bak recovery then next save destroys the good backup
**Status:** FIXED  
**Where:** `scripts/save_manager.gd` (`load_from_disk`, `save_to_disk`)  
**Was:** Corrupt `save.json` + good `save.json.bak` → load applies bak in memory but left corrupt primary on disk → next `save_to_disk` rotated corrupt primary **over** `.bak`, leaving only one good copy. A second primary corruption with no successful intervening save wiped progress.  
**Fix:** (1) On bak restore, rewrite primary in place from the parsed dict (no rotate). (2) Refuse to promote a non-JSON primary into `.bak`; delete corrupt primary instead.

### META-P0-02 — Cloud push ran before atomic commit
**Status:** FIXED  
**Where:** `scripts/save_manager.gd` → `SteamCloudSave.push_local`  
**Was:** `push_cloud_save()` ran after writing `.tmp` but **before** rename into `save.json`, so Steam Cloud uploaded the previous (or missing) primary. Latent while `cloud_save_enabled` is false; regresses multi-device sync the moment the flag flips.  
**Fix:** Push only after successful rename/direct write (`_push_cloud_after_commit`).

### META-P0-03 — Full-game save under demo opens empty chambers
**Status:** FIXED  
**Where:** `scripts/save_manager.gd` `_apply_save` / `_sanitize_queue_for_demo`; consumer `chamber.gd` `load_chamber` early-returns on `{}`  
**Was:** Shared `user://save.json` from the full campaign (queue indices ≥ demo `chamber_count()`) + `--demo` / `demo` feature → `Continue` / boot could set `current_chamber` out of range → blank chamber (no map, no goal).  
**Fix:** When `DemoBuild.is_demo()`, filter `run_queue` and clamp `current_chamber` to the demo book before Continue math.

---

## P1

### META-P1-01 — SettingsStore writes are not atomic
**Where:** `scripts/a11y/settings_store.gd` `save_settings`  
**Issue:** Direct `FileAccess.WRITE` to `user://echo_lattice_settings.json` with no tmp/rename/bak. Power loss or kill mid-write truncates the file; next boot treats it as empty and silently resets to defaults (a11y + remaps lost).  
**Suggested:** Mirror SaveManager (`*.tmp` + rename + optional `.bak`).

### META-P1-02 — Audio section persisted but never applied
**Where:** `config/default_settings.json` `audio.*`; `scripts/audio/audio_manager.gd`  
**Issue:** `master_volume` / `sfx_volume` / `music_volume` / `pa_volume` live in SettingsStore defaults, but no boot path calls `AudioManager.set_bus_linear`, and the settings UI has no audio sliders. Values are dead weight; any future UI would still need a wire-up.  
**Suggested:** Apply on `SettingsStore` reload + add volume rows (or drop keys until wired).

### META-P1-03 — CrashLogHook not autoloaded; no engine/error capture
**Where:** `scripts/ops/crash_log_hook.gd`, `project.godot.crash_log.fragment`, `project.godot`  
**Issue:** Fragment documents `CrashLogHook=…` but it is **not** merged into `[autoload]`. No boot breadcrumb, no `report_engine_error` sink, no `mark_clean_shutdown` on quit, no Settings → Support → export pack UI. Local crash packs from the design doc cannot be produced in RC1 builds.  
**Suggested:** Merge fragment; call `configure` / `mark_clean_shutdown` from main; add export affordance.

### META-P1-04 — Demo wishlist URL still `YOUR_APP_ID`
**Where:** `scripts/demo_build.gd` `WISHLIST_URL`  
**Issue:** `open_wishlist()` opens a non-existent Steam store page (warns only). Next Fest / demo CTA is a ship gate per `DEMO_SPEC.md`.  
**Suggested:** Replace placeholder before any public demo build; fail selftest when placeholder remains in demo exports.

### META-P1-05 — Locale has no in-game control and is split from SettingsStore
**Where:** `scripts/locale/locale_manager.gd` (`user://locale.cfg`); settings menu  
**Issue:** Locale is OS/Steam-detected + `locale.cfg` only. Settings overlay cannot change language; zh_Hans users who boot with an English Steam overlay locale cannot switch without hand-editing cfg. Also duplicates persistence away from `echo_lattice_settings.json`.  
**Suggested:** Language row in settings; optionally migrate `locale.code` into SettingsStore.

### META-P1-06 — Steam Cloud conflict policy keeps local forever
**Where:** `scripts/steam/steam_cloud_save.gd` `pull_if_newer`  
**Issue:** Comment claims mtime / last-write-wins, but any non-empty differing local file wins and cloud is ignored. A newer cloud save (other device) never overwrites. Combined with historical pre-commit pushes (P0-02), machines can diverge permanently.  
**Suggested:** Compare timestamps or schema `updated_at`; document Partner conflict policy; force-pull path for “cloud newer”.

---

## P2

### META-P2-01 — Hardcoded English demo subtitle
**Where:** `scripts/menu.gd` `_ready`  
**Issue:** `"Demo — Act I · Mirror Birth. Ink on paper."` bypasses `tr()`; zh_Hans catalog has no matching key (`menu.subtitle_demo` missing).

### META-P2-02 — Remapped controls footer not localized
**Where:** `scripts/menu.gd` `_controls_hint`  
**Issue:** Builds `"Move  %s… Restart …"` in English when ActionRemap is present; only the no-remap path uses `tr("menu.controls_hint")`.

### META-P2-03 — Settings menu chrome not localized
**Where:** `scenes/ui/settings_menu.tscn`, `scripts/a11y/settings_menu.gd`  
**Issue:** Labels / status strings (`"Settings — Accessibility"`, `"Press key…"`, reset copy) are English-only; `ActionRemap.DISPLAY_NAMES` likewise.

### META-P2-04 — Crash pack `save_head` schema does not match SaveManager v2
**Where:** `scripts/ops/crash_log_hook.gd` `_redacted_save_head`  
**Issue:** Expects META-doc fields (`unlocks`, `museum`, `stats.last_daily_date`). Live saves use `version` / `current_chamber` / `completed` / `daily_*`. Export always reports empty unlocks — useless for triage.  
**Suggested:** Redact against SaveManager v2 keys (chamber counts, run_mode, daily_label, queue_pos).

### META-P2-05 — `mark_clean_shutdown` / last-session unclean detection unused
**Where:** `crash_log_hook.gd` `LAST_SESSION_PATH`  
**Issue:** API exists; nothing writes clean shutdown or reads unclean boot. Design CL checklist in `CRASH_LOG_HOOK.md` unmet.

### META-P2-06 — Stub backend reports cloud enabled while Steam unavailable
**Where:** `scripts/steam/steam_stub_backend.gd`  
**Issue:** `is_steam_available() == false` but `cloud_enabled_for_account() == true`. Enabling `cloud_save_enabled` with stub silently “syncs” to in-memory dict only — easy to mistake for real Steam Cloud in manual QA.

### META-P2-07 — Accessibility doc vs InputMap: ghost assist button
**Where:** `docs/RELEASE/ACCESSIBILITY.md` vs `project.godot` `ghost_assist` / `pause_menu`  
**Issue:** Doc says ghost assist on gamepad **B**; project binds ghost to button 9 and **B (1)** to `pause_menu`. ACR matrix claims “B assist” — wrong for current bindings; pad B opens/backs menu, not ghost.

### META-P2-08 — `can_continue()` true from `current_chamber > 0` alone
**Where:** `scripts/game_state.gd`  
**Issue:** Continue affordance can light for odd partial state (`current_chamber > 0` with `run_started == false` and empty `completed`). Normal play always sets `run_started`; still a brittle Continue predicate vs `run_started || queue_pos > 0 || completed`.

### META-P2-09 — CJK font optional; zh_Hans may tofu
**Where:** `locale_manager.gd` `_apply_font_for_locale`; `fonts/cjk/`  
**Issue:** Documented, but shipping zh_Hans without vendored Noto/Source Han shows missing glyphs on all `draw_string` / Label paths using ThemeDB fallback. No settings warning surface for players.

---

## P3

### META-P3-01 — Overlay pause vs AdaptiveMusic edge
**Where:** `steam_service.gd` `_on_overlay_toggled`  
**Issue:** On overlay close, music unpauses whenever tree was not paused at open — even if music was paused for another reason.

### META-P3-02 — `reload_features()` does not re-init Steam
**Where:** `steam_service.gd`  
**Issue:** Swaps backend pointer without `shutdown_steam` / `init_steam`; fine for boot-time flags, unsafe if called live.

### META-P3-03 — Settings: `subtitle_background` has no UI
**Where:** defaults + `AccessibilityService` vs `settings_menu`  
**Issue:** Key exists and is snapshotted; no checkbox. Players cannot toggle.

### META-P3-04 — Rebind mode ignores gamepad; Start may close settings
**Where:** `action_remap.gd` `_input` (keys only); `settings_menu.gd` `_unhandled_input`  
**Issue:** During “Press key…”, a Start / B `pause_menu` event can close the overlay instead of cancelling rebind.

### META-P3-05 — ECHO_LATTICE_META.md describes a different SaveManager
**Where:** `docs/ECHO_LATTICE_META.md`  
**Issue:** Documents unlocks/museum/stats schema and debounced autosave; runtime SaveManager is the lean v2 chamber/run JSON. Audit/tooling that trusts the META doc will mis-handle saves (same root cause as META-P2-04).

---

## Continue / menu notes (no new bug IDs)

Verified against prior bugbash (`BUGBASH.md` SL-5/SL-6, UI-1/UI-2):

- Wing-complete → `can_continue()` false; Continue disabled + dimmed.
- `continue_run()` skips completed queue entries.
- Menu settings overlay is local to `menu.gd` (Main need not connect `settings_pressed`).
- Wishlist button only when `DemoBuild.is_demo()`; focus chain inserts it above Quit.
- Esc from chamber flushes rewrite then returns to menu (not settings).

---

## Fix verification

```bash
# Static gates (no Godot required)
python3 game/echo_lattice/tests/test_steamworks.py
python3 game/echo_lattice/tests/test_a11y_settings.py
python3 game/echo_lattice/tests/test_demo_spec.py
python3 game/echo_lattice/tests/validate_locale.py

# Prefer when Godot 4.3 is available:
godot4 --headless --path game/echo_lattice -- --selftest
godot4 --headless --path game/echo_lattice -- --demo --selftest
```

Manual checks for FIXED P0s:

1. Corrupt `user://save.json`, keep good `.bak`, boot, quit, corrupt primary again → progress still loads from bak.  
2. With `cloud_save_enabled` + stub, save then inspect stub `cloud_files` — bytes match new primary.  
3. Play full game far enough that `queue_pos >= 9`, relaunch with `--demo`, Continue → Act I chamber only (never blank).
