# SteamPipe templates — Echo Lattice

Placeholder AppID / DepotID VDFs for Windows content upload.

1. Export the game (Godot preset **Windows Desktop**, or `scripts/echo_lattice/export_windows.sh` when available).
2. Copy `builds/windows/*` (or `dist/echo_lattice/windows/*`) into `depot_build/windows/`.
3. Strip `steam_appid.txt` for retail.
4. Replace `YOUR_APP_ID` / `YOUR_DEPOT_ID` in the VDF files.
5. Run SteamCMD `run_app_build` with `app_build.vdf`.

Full Steamworks readiness guide: [`docs/RELEASE/STEAMWORKS.md`](../../docs/RELEASE/STEAMWORKS.md).  
Achievement API names: [`docs/RELEASE/ACHIEVEMENTS.json`](../../docs/RELEASE/ACHIEVEMENTS.json).
