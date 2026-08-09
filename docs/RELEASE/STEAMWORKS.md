# Echo Lattice — Steamworks readiness

**Product:** Echo Lattice  
**Engine:** Godot 4.3 desktop  
**Status:** Offline-first stub + feature flags landed; real AppID / GodotSteam pin still placeholders.

This is the release-facing Steamworks guide. Store/capsule checklist remains in the parallel Steam readiness doc (`docs/ECHO_LATTICE/08_STEAM_CHECKLIST.md` when merged). Achievement API names: [`ACHIEVEMENTS.json`](ACHIEVEMENTS.json).

---

## 1. Goals

| Goal | Policy |
|------|--------|
| Offline without Steam | Default. Puzzle loop never requires `steam_api` or a running Steam client. |
| Feature flags | `game/echo_lattice/config/steam_features.json` gates Steam init, achievements, rich presence, cloud, overlay pause. |
| Soft failure | Missing GodotSteam / failed init → stub backend; no hard crash. |
| Depot hygiene | Retail uploads omit `steam_appid.txt`, editor trees, and secrets. |

---

## 2. Runtime architecture

```
SteamService (autoload)
├── steam_features.json          # flags + presence copy
├── SteamStubBackend             # default — offline / CI / itch
├── SteamGodotSteamBackend       # when steam_enabled + GodotSteam present
├── SteamAchievements            # rules → setAchievement / storeStats
└── SteamCloudSave               # optional user://save.json ↔ Cloud
```

| Path | Role |
|------|------|
| `scripts/steam/steam_service.gd` | Facade autoload |
| `scripts/steam/steam_stub_backend.gd` | No-op / in-memory backend |
| `scripts/steam/steam_godotsteam_backend.gd` | Thin GodotSteam adapter |
| `scripts/steam/steam_achievements.gd` | Rule eval vs `GameState` |
| `scripts/steam/steam_cloud_save.gd` | Optional Cloud pull/push |
| `config/steam_features.json` | Feature flags |
| `config/achievements_steam.json` | Runtime catalog (mirrors `docs/RELEASE/ACHIEVEMENTS.json`) |

Autoload order (see `project.godot.steamworks.fragment`):

`SaveManager` → `SteamService` (optional Cloud pull) → `ChamberBook` → `GameState` (local load).

### Feature flags

| Flag | Default | Meaning |
|------|---------|---------|
| `steam_enabled` | `false` | Attempt GodotSteam init |
| `achievements_enabled` | `true` | Evaluate + unlock (stub records locally when Steam off) |
| `rich_presence_enabled` | `true` | Menu / chamber / won / end status strings |
| `cloud_save_enabled` | `false` | Optional Cloud sync of `save.json` |
| `overlay_pause_enabled` | `true` | Pause tree when overlay opens |
| `prefer_godotsteam_when_present` | `true` | Use real backend only if singleton exists |
| `allow_spacewar_dev` | `false` | **SEC-01:** Permit AppID `480` only in editor/debug when explicitly true. Shipping builds never fall back to Spacewar. |

**itch / DRM-free:** leave `steam_enabled` false (default). Do not ship Steam DLLs in itch zips.

**AppID fail-closed (SEC-01):** `_resolve_app_id()` requires a positive non-Spacewar AppID from `steam_appid.txt` or a numeric `app_id_placeholder`. Missing/invalid → AppID `0`, Steam init skipped while `steam_enabled` is true.

---

## 3. Achievements

Authoritative Partner list: [`ACHIEVEMENTS.json`](ACHIEVEMENTS.json).

1. Steamworks → Stats & Achievements → create each `api_name`.
2. Upload icons (64×64 + 256×256).
3. Keep `api_name` stable; wire already uses those strings.
4. Demo AppID: either omit achievements or ship only `mvp: true` rows.

Unlock hooks:

- `GameState.record_chamber_win` → `SteamService.notify_chamber_cleared`
- Rules include chamber counts, act clears, stars, daily clear

Stub mode still evaluates rules and records unlocks on the stub backend so headless tests and offline play stay consistent.

---

## 4. Rich presence

When `rich_presence_enabled` is true, `SteamService` sets:

| Context | Default status |
|---------|----------------|
| Menu | `At the Field Ledger` |
| Chamber | `Chamber {n}: {title}` |
| Daily | `Daily {label}` |
| Cleared | `Cleared {title}` |
| Wing end | `Wing complete` |

Copy is overridable under `presence` in `steam_features.json`. Wired from `main.gd` scene transitions.

---

## 5. Optional Cloud save

**MVP default: off.** Local `user://save.json` via `SaveManager` is enough.

When enabling for 1.0:

1. Steamworks → Steam Cloud → enable; quota **10–50 MB** (saves are tiny JSON).
2. Set `cloud_save_enabled: true`.
3. Map root path to Godot userdata (`%APPDATA%\Godot\app_userdata\Echo Lattice\` on Windows, or a custom `user://` override).
4. Remote file name: `save.json` (`cloud_remote_path`).
5. Conflict policy today: **prefer local if both differ**; pull only when local missing/empty. Revisit before marketing Cloud as a feature.
6. **SEC-02:** Cloud pulls run `SaveManager.validate_save_text` (version bounds, allowlisted keys, size/queue caps) before atomic write to `user://save.json`. Invalid remotes are refused.

Exclude: crash dumps, screenshots, `telemetry/`, editor scratch.

---

## 6. Overlay pause

When `overlay_pause_enabled` is true and the backend emits overlay open:

1. Remember prior `get_tree().paused`.
2. Pause the scene tree (`SteamService` uses `PROCESS_MODE_ALWAYS`).
3. Duck adaptive music if `AdaptiveMusic` is present.
4. On overlay close, restore prior pause state.

Stub testing: `SteamService.debug_simulate_overlay(true|false)`.

---

## 7. GodotSteam bring-up (when leaving stub)

1. Install GodotSteam GDExtension matching Godot **4.3.x** into `game/echo_lattice/addons/godotsteam/` (do not commit Valve redistributables without license review).
2. Pin the exact GodotSteam + Godot version pair in release notes.
3. Set `steam_enabled: true` for Steam export presets only (`custom_features` may include `steam`).
4. Local exported testing: `steam_appid.txt` beside the exe with the **real** AppID. Spacewar `480` only with `allow_spacewar_dev: true` in editor/debug — never as a silent fallback. **Never ship `480` or `steam_appid.txt` in retail depots.**
5. Smoke: init → unlock one achievement → Shift+Tab overlay pause → quit flush.

---

## 8. Depot export notes

Windows-first SteamPipe layout (templates under [`steam/echo_lattice/`](../../steam/echo_lattice/)):

```text
steam/echo_lattice/
  app_build.vdf
  depot_windows.vdf
  depot_build/
    windows/                 # upload root
      EchoLattice.exe
      EchoLattice.pck
      steam_api64.dll        # only if GodotSteam redistrib required
      LICENSE.txt
  README.md
```

### Export → stage → upload

1. Export Windows release (Godot preset `Windows Desktop` → `builds/windows/EchoLattice.exe`, or `scripts/echo_lattice/export_windows.sh` when present).
2. Copy artifacts into `steam/echo_lattice/depot_build/windows/`.
3. **Strip** `steam_appid.txt`, `*.pdb`, `.godot/`, source trees, and any CI secrets.
4. Replace `YOUR_APP_ID` / `YOUR_DEPOT_ID` in the VDF files.
5. SteamCMD:
   ```bash
   steamcmd +login <user> +run_app_build <abs>/steam/echo_lattice/app_build.vdf +quit
   ```
6. Set the build live on a Steam branch (`beta` for QA, then `default`).

### Depot rules

| Rule | Detail |
|------|--------|
| Launch option | `EchoLattice.exe` (working dir = install dir) |
| No editor | Never upload `.godot/`, `.tscn` source trees, export cache |
| No secrets | No Steam Guard ma-files, passwords, or shipping keys in git |
| `steam_appid.txt` | Dev only — listed in `FileExclusion` |
| Demo | Separate demo depot / AppID; prefer demo wing content only |
| Linux / macOS | Add depots when multi-OS presets are shipping (see `docs/RELEASE/PLATFORMS.md` when merged) |

### Retail vs dev

| | Dev / local export | Retail Steam build |
|--|--------------------|--------------------|
| AppID source | `steam_appid.txt` | Steam client |
| Overlay | If Steam running | On |
| Achievements | Test app / Spacewar | Real AppID |
| Stub flags | `steam_enabled` false in editor | true only in Steam-branded export |

---

## 9. Verification

```bash
# Catalog + flag + doc acceptance (no Godot / no Steam required)
python3 game/echo_lattice/tests/test_steamworks.py
# SEC-01 / SEC-02 / SEC-03 contracts
python3 game/echo_lattice/tests/test_security_high.py
```

Manual (Steam branch build):

- [ ] Boot without Steam client → plays offline
- [ ] Boot with Steam + `steam_enabled` → init ok
- [ ] Clear chamber 0 → `EL_BOOT_CLEARED` / `EL_FIRST_STEPS`
- [ ] Overlay Shift+Tab pauses gameplay
- [ ] Rich presence shows chamber title
- [ ] If Cloud on: save on A, read on B

---

## 10. Related

| Doc / path | Role |
|------------|------|
| [`ACHIEVEMENTS.json`](ACHIEVEMENTS.json) | Partner achievement table |
| [`PLATFORMS.md`](PLATFORMS.md) | Store priority (when merged) |
| [`CI_BUILDS.md`](CI_BUILDS.md) | Export CI sketch (when merged) |
| `game/echo_lattice/config/steam_features.json` | Runtime flags |
| `steam/echo_lattice/` | SteamPipe VDF templates |

*AppID still placeholder — do not invent a real AppID in-repo.*
