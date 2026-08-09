# Echo Lattice — Steamworks readiness

**Product:** Echo Lattice  
**Engine:** Godot 4.3 desktop  
**Status:** Offline-first stub + feature flags landed; real AppID / GodotSteam pin still placeholders.

This is the release-facing Steamworks guide. **GodotSteam install + fail-closed SDK policy:** [`GODOTSTEAM.md`](GODOTSTEAM.md). Store/capsule checklist remains in the parallel Steam readiness doc (`docs/ECHO_LATTICE/08_STEAM_CHECKLIST.md` when merged). Achievement API names: [`ACHIEVEMENTS.json`](ACHIEVEMENTS.json).

---

## 1. Goals

| Goal | Policy |
|------|--------|
| Offline without Steam | Default. Puzzle loop never requires `steam_api` or a running Steam client. |
| Feature flags | `game/echo_lattice/config/steam_features.json` gates Steam init, achievements, rich presence, cloud, overlay pause. |
| Fail-closed without SDK | `steam_enabled` + missing GodotSteam → stub stays inert for Steam APIs (no fake unlocks/cloud); no hard crash. |
| No Spacewar in release | AppID `480` never resolves in shipping/`steam` builds; depot render rejects `480`. |
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
| `wishlist_cta_enabled` | `true` | Master switch for demo Steam wishlist buttons |
| `store_wishlist_url` | `""` | Explicit Steam wishlist/store URL (preferred when set) |
| `store_page_url` | `""` | Fallback store page URL if wishlist URL empty |
| `app_id_placeholder` | `YOUR_APP_ID` | Used to derive `https://store.steampowered.com/app/{id}/` only when numeric and not Spacewar `480` |

**Store CTAs:** `DemoBuild.wishlist_cta_enabled()` requires a demo build, a non-empty resolved store URL with no `YOUR_APP_ID` token, and must not run under export tags `itch` or `drm_free`. `open_wishlist()` never `shell_open`s placeholder links.

**itch / DRM-free:** leave `steam_enabled` false (default). Set `custom_features` to include `itch` or `drm_free`. Do not ship Steam DLLs in itch zips.

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
5. **Conflict policy (Partner-facing):**
   - Boot pull (`SteamCloudSave.pull_if_newer`) applies the remote file when local is **missing or empty**.
   - When both exist and differ, compare schema field `updated_at` (unix seconds, written by `SaveManager` on every commit). **Strictly newer cloud wins.**
   - If `updated_at` is missing on either side, or timestamps are equal: **prefer local** (safe default while Cloud is optional / unmarketed). Identical byte payloads are treated as already synced.
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

Step-by-step install, pin, and fail-closed behavior: **[`GODOTSTEAM.md`](GODOTSTEAM.md)**.

Summary:

1. Install GodotSteam GDExtension matching Godot **4.3.x** into `game/echo_lattice/addons/godotsteam/` (binaries gitignored; do not commit Valve redistributables without license review).
2. Pin the exact GodotSteam + Godot version pair in release notes.
3. Set `steam_enabled: true` for Steam export presets only (`custom_features` should include `steam`).
4. Local exported testing: `steam_appid.txt` beside the exe with the **real** AppID. Spacewar `480` only with `allow_spacewar_dev: true` in editor/debug — never as a silent fallback. **Never ship `480` or `steam_appid.txt` in retail depots.**
5. Smoke: init → unlock one achievement → Shift+Tab overlay pause → quit flush.

---

## 8. Depot export notes

Windows + Linux SteamPipe layout (templates under [`steam/echo_lattice/`](../../steam/echo_lattice/)).  
Placeholder gates: [`APPID_PLACEHOLDER_GATES.md`](APPID_PLACEHOLDER_GATES.md).

```text
steam/echo_lattice/
  app_build.vdf              # full game — Win + Linux depots
  depot_windows.vdf
  depot_linux.vdf
  app_build_demo.vdf         # demo AppID stub
  depot_windows_demo.vdf
  depot_build/
    windows/                 # EchoLattice.exe + .pck (+ steam_api64.dll if needed)
    linux/                   # EchoLattice.x86_64 + .pck (+ libsteam_api.so if needed)
    windows_demo/            # EchoLatticeDemo.exe + .pck
  README.md
```

### Export → stage → upload (full game)

1. Export Windows via [`tools/release/export_windows.sh`](../../tools/release/export_windows.sh) / [`BUILD_WINDOWS.md`](BUILD_WINDOWS.md) (or CI artifacts from [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)); Linux via preset `Linux/X11`.
2. Copy into `steam/echo_lattice/depot_build/windows/` and `depot_build/linux/`.
3. **Strip** `steam_appid.txt`, `*.pdb`, `.godot/`, source trees, and any CI secrets. Verify `SHA256SUMS.txt` from the artifact. Run:
   ```bash
   python3 steam/echo_lattice/verify_retail_staging.py
   ```
4. Render VDFs from real Partner env vars (do not invent IDs; never `480`):
   ```bash
   export STEAM_APP_ID=… STEAM_DEPOT_ID_WINDOWS=… STEAM_DEPOT_ID_LINUX=…
   python3 steam/echo_lattice/render_vdf_from_env.py --write --full
   ```
   Committed templates keep `YOUR_*` placeholders; rendered copies land under `dist/echo_lattice/steampipe_rendered/`.
5. SteamCMD against the **rendered** app build:
   ```bash
   steamcmd +login <user> +run_app_build <abs>/dist/echo_lattice/steampipe_rendered/app_build.vdf +quit
   ```
6. Set the build live on a Steam branch (`beta` for QA, then `default`).
7. Partner launch options: Windows → `EchoLattice.exe`; SteamOS/Deck → native `EchoLattice.x86_64`.

### Demo depot stub

1. Export preset `Windows Demo` → stage `depot_build/windows_demo/`.
2. `export STEAM_DEMO_APP_ID=… STEAM_DEMO_DEPOT_ID=…` then  
   `python3 steam/echo_lattice/render_vdf_from_env.py --write --demo`.
3. `steamcmd +run_app_build` on the rendered `app_build_demo.vdf`.

### Depot rules

| Rule | Detail |
|------|--------|
| Launch option (Win) | `EchoLattice.exe` (working dir = install dir) |
| Launch option (Linux/Deck) | `EchoLattice.x86_64` — prefer native over Proton |
| No editor | Never upload `.godot/`, `.tscn` source trees, export cache |
| No secrets | No Steam Guard ma-files, passwords, or shipping keys in git |
| `steam_appid.txt` | Dev only — listed in `FileExclusion` |
| Demo | Separate demo AppID + `app_build_demo.vdf`; Act I / demo wing only |
| macOS | Add depot when notarized mac preset is shipping (see `PLATFORMS.md`) |

### Retail vs dev

| | Dev / local export | Retail Steam build |
|--|--------------------|--------------------|
| AppID source | `steam_appid.txt` (real AppID) or editor Spacewar only if `allow_spacewar_dev` | Steam client (never `steam_appid.txt`, never `480`) |
| Overlay | If Steam running | On |
| Achievements | Real AppID preferred; Spacewar only with explicit dev flag | Real AppID only |
| Stub flags | `steam_enabled` false in editor | true only in Steam-branded export with GodotSteam installed |

---

## 9. Verification

```bash
# Catalog + flag + doc acceptance (no Godot / no Steam required)
python3 game/echo_lattice/tests/test_steamworks.py
# SEC-01 / SEC-02 / SEC-03 contracts
python3 game/echo_lattice/tests/test_security_high.py
# GodotSteam install docs + fail-closed SDK + depot env render
python3 game/echo_lattice/tests/test_godotsteam_gate.py
python3 steam/echo_lattice/verify_retail_staging.py
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
| [`GODOTSTEAM.md`](GODOTSTEAM.md) | Optional GodotSteam install + fail-closed SDK |
| [`PLATFORMS.md`](PLATFORMS.md) | Store priority (when merged) |
| [`CI_BUILDS.md`](CI_BUILDS.md) | Export CI sketch (when merged) |
| `game/echo_lattice/config/steam_features.json` | Runtime flags |
| `steam/echo_lattice/` | SteamPipe VDF templates + env render scripts |

*AppID still placeholder — do not invent a real AppID in-repo.*
