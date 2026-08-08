# SteamPipe templates — Echo Lattice

Placeholder AppID / DepotID VDFs for Windows content upload.

1. Export the game: `scripts/echo_lattice/export_windows.sh` (or `.ps1`).  
2. Copy `dist/echo_lattice/windows/*` into `depot_build/windows/`.  
3. Replace `YOUR_APP_ID` / `YOUR_DEPOT_ID` in the VDF files.  
4. Run SteamCMD `run_app_build` with `app_build.vdf`.

Full checklist: [`docs/ECHO_LATTICE/08_STEAM_CHECKLIST.md`](../../docs/ECHO_LATTICE/08_STEAM_CHECKLIST.md).
