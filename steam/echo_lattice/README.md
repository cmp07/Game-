# SteamPipe templates — Echo Lattice

Placeholder AppID / DepotID VDFs for **Windows + Linux** full-game uploads, plus a **Windows Demo** stub.

**Do not invent IDs.** Keep `YOUR_*` in git; render real IDs from env vars after Partner assign.  
**Never use Spacewar `480` for retail.**  
Gate list: [`docs/RELEASE/APPID_PLACEHOLDER_GATES.md`](../../docs/RELEASE/APPID_PLACEHOLDER_GATES.md).  
GodotSteam install: [`docs/RELEASE/GODOTSTEAM.md`](../../docs/RELEASE/GODOTSTEAM.md).

## Layout

```text
steam/echo_lattice/
  app_build.vdf              # full game — Windows + Linux depots (placeholders)
  depot_windows.vdf
  depot_linux.vdf
  app_build_demo.vdf         # demo AppID stub
  depot_windows_demo.vdf
  render_vdf_from_env.py     # STEAM_* env → dist/.../steampipe_rendered/
  verify_retail_staging.py   # refuse steam_appid.txt / Spacewar in staging
  depot_build/
    windows/                 # EchoLattice.exe + .pck
    linux/                   # EchoLattice.x86_64 + .pck
    windows_demo/            # EchoLatticeDemo.exe + .pck
  README.md
```

| Placeholder | Env var (render script) | Role |
|---|---|---|
| `YOUR_APP_ID` | `STEAM_APP_ID` | Full-game AppID |
| `YOUR_DEPOT_ID` | `STEAM_DEPOT_ID_WINDOWS` (alias `STEAM_DEPOT_ID`) | Windows content depot |
| `YOUR_DEPOT_ID_LINUX` | `STEAM_DEPOT_ID_LINUX` | Linux / Deck content depot |
| `YOUR_DEMO_APP_ID` | `STEAM_DEMO_APP_ID` | Separate demo AppID |
| `YOUR_DEMO_DEPOT_ID` | `STEAM_DEMO_DEPOT_ID` | Demo Windows depot |

## Full game (Windows + Linux)

1. Export Godot presets **Windows Desktop** and **Linux/X11** (or CI artifacts from `.github/workflows/ci.yml`).
2. Copy into `depot_build/windows/` and `depot_build/linux/`.
3. Strip `steam_appid.txt` for retail (also listed in each depot `FileExclusion`), then:
   ```bash
   python3 steam/echo_lattice/verify_retail_staging.py
   ```
4. Render VDFs from Partner env vars (fail-closed if unset or `480`):
   ```bash
   export STEAM_APP_ID=… STEAM_DEPOT_ID_WINDOWS=… STEAM_DEPOT_ID_LINUX=…
   python3 steam/echo_lattice/render_vdf_from_env.py --write --full
   ```
5. SteamCMD: `run_app_build` with `dist/echo_lattice/steampipe_rendered/app_build.vdf`.
6. Partner launch options: Windows → `EchoLattice.exe`; SteamOS/Deck → `EchoLattice.x86_64`.

## Demo stub

1. Export preset **Windows Demo** → `builds/windows_demo/EchoLatticeDemo.exe`.
2. Stage into `depot_build/windows_demo/`.
3. `export STEAM_DEMO_APP_ID=… STEAM_DEMO_DEPOT_ID=…` then  
   `python3 steam/echo_lattice/render_vdf_from_env.py --write --demo`.
4. SteamCMD `run_app_build` on the rendered `app_build_demo.vdf`.
5. Fix wishlist URL to the real **full-game** AppID before ship (not Spacewar).

Full Steamworks readiness guide: [`docs/RELEASE/STEAMWORKS.md`](../../docs/RELEASE/STEAMWORKS.md).  
Achievement API names: [`docs/RELEASE/ACHIEVEMENTS.json`](../../docs/RELEASE/ACHIEVEMENTS.json).  
CI sketch (committed): [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).
