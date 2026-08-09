# Echo Lattice RC1 — Steam ship candidate

**Branch:** `cursor/echo-lattice-rc1`  
**Base:** `main` (v2 complete vertical slice already merged)  
**Policy:** Integration-only. **Do not merge this branch to `main`.** Open as a review PR against `main` for ship gating; keep RC1 as the Steam candidate line.

**Offline playable:** Campaign / Daily / Endless run entirely offline. Saves, telemetry, and crash logs are local (`user://`). Steamworks / network features are optional and must degrade gracefully when offline or unavailable.

**Endless (thin vertical):** Menu → Endless starts a seeded climb through the daily chamber catalog. Depth raises rewrite pressure (higher act floor + stacked mirror transforms). Best depth persists in `user://save.json`.

---

## What RC1 is

RC1 is the **Steam ship candidate integration branch**. Release-lane agents land packs on `cursor/release-*`; this branch merges those packs, resolves conflicts, and documents the ship bar.

Playable product root: `game/echo_lattice/` (Godot 4.3, GDScript).

---

## Merged release packs

| Pack | Branch | PR | Status |
|---|---|---|---|
| Platforms | `cursor/release-platforms` | #63 | Merged into RC1 |
| Compliance | `cursor/release-compliance` | #64 | Merged into RC1 |
| Live ops | `cursor/release-liveops-2a83` | #65 | Merged into RC1 |
| Marketing | `cursor/release-marketing` | #66 | Merged into RC1 |
| Steam Deck | `cursor/release-deck` | #67 | Merged into RC1 |
| Steam store | `cursor/release-steam-store` | #69 | Merged into RC1 |
| Accessibility | `cursor/release-a11y` | #70 | Merged into RC1 |
| Localization | `cursor/release-l10n` | #71 | Merged into RC1 |
| Demo | `cursor/release-demo` | #72 | Merged into RC1 |
| Steamworks | `cursor/release-steamworks` | #73 | Merged into RC1 |
| Polish | `cursor/release-polish-rc` | #74 | Merged into RC1 |

All requested `cursor/release-*` packs present at integration time are merged above.

### Ultra Audit P0 code landed (2026-08-09)

| Source | PR | Landed |
|---|---|---|
| SaveManager bak recovery / cloud-after-commit | [#82](https://github.com/cmp07/Game-/pull/82) `audit-bugs-meta` | Yes |
| Continue / `run_cleared` lifetime-skip fix | [#87](https://github.com/cmp07/Game-/pull/87) `audit-bugs-core` | Yes |
| Demo clamp, focus/pad, locale refresh + tests | [#88](https://github.com/cmp07/Game-/pull/88) `audit-adversarial` | Yes |
| Full audit corpus under [`docs/AUDIT/`](../AUDIT/) | [#75](https://github.com/cmp07/Game-/pull/75)–[#81](https://github.com/cmp07/Game-/pull/81), [#83](https://github.com/cmp07/Game-/pull/83)–[#86](https://github.com/cmp07/Game-/pull/86), [#89](https://github.com/cmp07/Game-/pull/89) | Yes |

Executive synthesis: [`../AUDIT/ULTRA_AUDIT_RC1.md`](../AUDIT/ULTRA_AUDIT_RC1.md) (ship-readiness **54/100**; Gate A still blocked on AppID / capsules / trailer).

### Security High code landed (2026-08-09)

SEC-01 / SEC-02 / SEC-03 from [`../AUDIT/SECURITY.md`](../AUDIT/SECURITY.md) — fail-closed AppID (no Spacewar fallback), Cloud pull schema validation before `save.json` write, and constrained `--screenshot --out` paths. Note: [`../AUDIT/SECURITY_HIGH_FIXES.md`](../AUDIT/SECURITY_HIGH_FIXES.md). Tests: `python3 game/echo_lattice/tests/test_security_high.py`.

---

## Doc map

| Area | Entry |
|---|---|
| Release index | [`README.md`](README.md) |
| Ultra audit (ship score / gates) | [`../AUDIT/ULTRA_AUDIT_RC1.md`](../AUDIT/ULTRA_AUDIT_RC1.md) |
| Platforms / stores | [`PLATFORMS.md`](PLATFORMS.md) |
| Windows (+ Demo) export | [`BUILD_WINDOWS.md`](BUILD_WINDOWS.md) |
| CI / exports | [`CI_BUILDS.md`](CI_BUILDS.md) |
| Compliance (Content Survey, privacy, credits) | [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) |
| Launch marketing | [`LAUNCH_PLAYBOOK.md`](LAUNCH_PLAYBOOK.md) · [`presskit/`](presskit/) |
| Post-launch / live ops | [`POSTLAUNCH.md`](POSTLAUNCH.md) · [`ROADMAP.md`](ROADMAP.md) · [`SUPPORT_FAQ.md`](SUPPORT_FAQ.md) |
| Crash / logs | [`CRASH_LOG_HOOK.md`](CRASH_LOG_HOOK.md) |
| Playable slice | [`../ECHO_LATTICE/13_VERTICAL_SLICE_README.md`](../ECHO_LATTICE/13_VERTICAL_SLICE_README.md) |
| Changelog (v2) | [`../ECHO_LATTICE/CHANGELOG_V2.md`](../ECHO_LATTICE/CHANGELOG_V2.md) |

---

## Offline ship bar (must stay green)

1. **No always-online gate.** Boot → menu → chamber works with network disabled.
2. **Local saves.** Progress under Godot `user://` (see vertical-slice README paths).
3. **Daily mode offline.** UTC calendar from `content/daily/calendar_90.json` (or catalog hash fallback) — no server seed fetch required.
4. **Telemetry / crash upload opt-in only.** Default is local JSONL; upload is a no-op without an explicit client + opt-in.
5. **Steam optional.** Achievements / Cloud / overlay may be present later; gameplay must not require Steam API success.

Quick contract check (no Godot binary required):

```bash
python3 game/echo_lattice/tests/test_release_liveops.py
python3 game/echo_lattice/tests/test_rc_polish.py
python3 game/echo_lattice/tests/test_adversarial_qa.py
```

Editor play:

```bash
# Import game/echo_lattice/project.godot in Godot 4.3, then F5
```

Headless export sketch: see [`CI_BUILDS.md`](CI_BUILDS.md) and `game/echo_lattice/export_presets.cfg` (Windows primary, Linux/Deck, macOS stub).

---

## Integration lead procedure

1. `git fetch origin --prune`
2. For each new `origin/cursor/release-*` not yet in RC1 history:
   - `git merge --no-ff origin/<branch> -m "Merge <branch>: …"`
   - Resolve conflicts in favor of **offline playability** and a single coherent `docs/RELEASE/` index.
3. Refresh the status table above.
4. Push `cursor/echo-lattice-rc1` and update the RC1 PR description.
5. **Never** merge RC1 (or individual release PRs en masse) into `main` from this lane.

---

## Explicit non-goals for RC1 integration

- Merging to `main`
- Live-service economy / mandatory telemetry
- Blocking ship on unsigned macOS notarization (stub export is documented)
- Replacing the playable v2 loop already on `main` with a networking rewrite
