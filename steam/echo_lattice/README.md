# SteamPipe templates — Echo Lattice

Placeholder AppID / DepotID VDFs for **Windows + Linux** full-game uploads, plus a **Windows Demo** stub.

**Do not invent IDs.** Replace tokens only after Steamworks Partner creates the apps/depots.  
Gate list: [`docs/RELEASE/APPID_PLACEHOLDER_GATES.md`](../../docs/RELEASE/APPID_PLACEHOLDER_GATES.md).

## Layout

```text
steam/echo_lattice/
  app_build.vdf              # full game — Windows + Linux depots
  depot_windows.vdf
  depot_linux.vdf
  app_build_demo.vdf         # demo AppID stub
  depot_windows_demo.vdf
  depot_build/
    windows/                 # EchoLattice.exe + .pck
    linux/                   # EchoLattice.x86_64 + .pck
    windows_demo/            # EchoLatticeDemo.exe + .pck
  README.md
```

| Placeholder | Role |
|---|---|
| `YOUR_APP_ID` | Full-game AppID |
| `YOUR_DEPOT_ID` | Windows content depot |
| `YOUR_DEPOT_ID_LINUX` | Linux / Deck content depot |
| `YOUR_DEMO_APP_ID` | Separate demo AppID |
| `YOUR_DEMO_DEPOT_ID` | Demo Windows depot |

## Full game (Windows + Linux)

1. Export Windows via [`tools/release/export_windows.sh`](../../tools/release/export_windows.sh) (or CI artifacts from `.github/workflows/ci.yml`). Linux: preset **Linux/X11**. Guide: [`docs/RELEASE/BUILD_WINDOWS.md`](../../docs/RELEASE/BUILD_WINDOWS.md).
2. Copy into `depot_build/windows/` and `depot_build/linux/`.
3. Strip `steam_appid.txt` for retail (also listed in each depot `FileExclusion`). Verify `SHA256SUMS.txt` before upload.
4. Replace `YOUR_APP_ID` / `YOUR_DEPOT_ID` / `YOUR_DEPOT_ID_LINUX` in the VDF files.
5. SteamCMD: `run_app_build` with `app_build.vdf`.
6. Partner launch options: Windows → `EchoLattice.exe`; SteamOS/Deck → `EchoLattice.x86_64`.

## Demo stub

1. `./tools/release/export_windows.sh --demo` (or CI artifact `echo-lattice-windows-demo-x86_64`) → `builds/windows_demo/EchoLatticeDemo.exe`.
2. Stage into `depot_build/windows_demo/`.
3. Replace `YOUR_DEMO_APP_ID` / `YOUR_DEMO_DEPOT_ID` in `app_build_demo.vdf` + `depot_windows_demo.vdf`.
4. SteamCMD `run_app_build` with `app_build_demo.vdf`.
5. Fix wishlist URL (`DemoBuild.WISHLIST_URL`) to the real **full-game** AppID before ship.

Full Steamworks readiness guide: [`docs/RELEASE/STEAMWORKS.md`](../../docs/RELEASE/STEAMWORKS.md).  
Achievement API names: [`docs/RELEASE/ACHIEVEMENTS.json`](../../docs/RELEASE/ACHIEVEMENTS.json).  
CI workflow: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).
