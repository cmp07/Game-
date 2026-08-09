# GodotSteam optional integration

**Product:** Echo Lattice  
**Engine:** Godot **4.3.x**  
**Policy:** Offline-first. GodotSteam is optional. Missing SDK / invalid AppID / Spacewar in release are **fail-closed**.

Related: [`STEAMWORKS.md`](STEAMWORKS.md) · [`APPID_PLACEHOLDER_GATES.md`](APPID_PLACEHOLDER_GATES.md) · [`steam/echo_lattice/`](../../steam/echo_lattice/)

---

## 1. Defaults (no SDK required)

| Surface | Default |
|---------|---------|
| `config/steam_features.json` → `steam_enabled` | `false` |
| Backend | `SteamStubBackend` (offline; `is_steam_available() == false`) |
| Cloud on stub | Disabled (`cloud_enabled_for_account() == false`) |
| CI / itch / editor | Never requires `steam_api` or a Steam client |
| Spacewar `480` | Dev-only behind `allow_spacewar_dev` + editor/debug — **never release** |

Gameplay, saves, Daily, and Endless must work with GodotSteam absent.

---

## 2. Install (local / private builder)

Do **not** invent AppIDs. Do **not** commit Valve redistributables without license review.
Binaries under `addons/godotsteam/` (except this README) are gitignored.

1. Download a **GodotSteam GDExtension** build that matches Godot **4.3.x** from the GodotSteam project releases (same minor as the editor/export templates used in CI: `4.3`).
2. Extract into:
   ```text
   game/echo_lattice/addons/godotsteam/
   ```
   Keep `README.md`. Expected artifacts include `godotsteam.gdextension` plus platform folders (`win64`, `linuxbsd`, …).
3. Open `game/echo_lattice` once in the Godot **4.3** editor so the `Steam` class/singleton registers.
4. Pin the exact pair in release notes when leaving stub:
   - Godot version (e.g. `4.3.stable`)
   - GodotSteam release tag / commit
5. Copy required Steamworks redistributables beside exported binaries when GodotSteam docs require them (`steam_api64.dll`, `libsteam_api.so`). Prefer Partner-licensed copies; do not commit them to this public tree without review.
6. For **local exported** testing only, place `steam_appid.txt` beside the executable with the **real** Partner AppID (copy from `steam_appid.txt.example`).  
   - Spacewar `480` only if `allow_spacewar_dev: true` **and** editor/debug.  
   - **Never** stage `steam_appid.txt` into retail depots (VDF `FileExclusion` + `verify_retail_staging.py`).

### Enable Steam only on Steam exports

1. Set `steam_enabled: true` in the Steam-branded config used for those exports (keep itch / DRM-free at `false`).
2. Add `steam` to `custom_features` on Steam export presets so shipping context is detectable.
3. Leave `prefer_godotsteam_when_present: true` (default).

Smoke after enable: init → unlock one MVP achievement → Shift+Tab overlay pause → quit flush.

---

## 3. Fail-closed contracts

| Condition | Behavior |
|-----------|----------|
| `steam_enabled` + GodotSteam **missing** | Stub stays loaded; `_steam_sdk_fail_closed` — no fake unlocks / cloud / presence; `push_error` in shipping/`steam` builds |
| `steam_enabled` + no valid AppID | Init skipped; AppID `0`; warning; **no** Spacewar fallback |
| AppID `480` without `allow_spacewar_dev` + editor/debug | Rejected |
| AppID `480` in release / `steam` feature | Always rejected (even if flag mis-set) |
| Depot render with unset `STEAM_*` env | Script exits non-zero |
| Depot render / staging with `480` | Script exits non-zero |

Adapter: `scripts/steam/steam_godotsteam_backend.gd`  
Facade: `scripts/steam/steam_service.gd`

---

## 4. Depot scripts + real AppID env vars

Committed VDFs under `steam/echo_lattice/` keep `YOUR_*` placeholders (Gate A — no invented IDs).

When Partner assigns IDs, export them in the shell (or CI secrets) and render:

```bash
export STEAM_APP_ID=<partner full-game app id>           # never 480
export STEAM_DEPOT_ID_WINDOWS=<windows depot id>         # alias: STEAM_DEPOT_ID
export STEAM_DEPOT_ID_LINUX=<linux depot id>
export STEAM_DEMO_APP_ID=<demo app id>                   # optional for --demo
export STEAM_DEMO_DEPOT_ID=<demo windows depot id>

# Validate env (fail-closed if missing / Spacewar)
python3 steam/echo_lattice/render_vdf_from_env.py --check

# Write rendered VDFs to dist/echo_lattice/steampipe_rendered/ (gitignored)
python3 steam/echo_lattice/render_vdf_from_env.py --write

# After staging binaries into steam/echo_lattice/depot_build/{windows,linux,...}
python3 steam/echo_lattice/verify_retail_staging.py
```

Then `steamcmd +run_app_build` against the **rendered** `app_build.vdf` (paths inside rendered copies still point at `depot_*.vdf` beside them — copy the whole rendered dir or re-point ContentRoot as needed).

| Env var | Replaces |
|---------|----------|
| `STEAM_APP_ID` | `YOUR_APP_ID` |
| `STEAM_DEPOT_ID_WINDOWS` / `STEAM_DEPOT_ID` | `YOUR_DEPOT_ID` |
| `STEAM_DEPOT_ID_LINUX` | `YOUR_DEPOT_ID_LINUX` |
| `STEAM_DEMO_APP_ID` | `YOUR_DEMO_APP_ID` |
| `STEAM_DEMO_DEPOT_ID` | `YOUR_DEMO_DEPOT_ID` |

---

## 5. Verification

```bash
python3 game/echo_lattice/tests/test_steamworks.py
python3 game/echo_lattice/tests/test_security_high.py
python3 game/echo_lattice/tests/test_godotsteam_gate.py
python3 steam/echo_lattice/verify_retail_staging.py
# Expect exit 2 until Partner env is set:
python3 steam/echo_lattice/render_vdf_from_env.py --check || true
```

---

*No AppIDs invented in this document. Spacewar is never a release AppID.*
