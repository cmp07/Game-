# Echo Lattice — Windows desktop export

Produce a real Steam-ready **Windows x86_64 `.exe` + `.pck`** (not HTML5).  
Steam depot upload and store checklist: [`08_STEAM_CHECKLIST.md`](08_STEAM_CHECKLIST.md).

---

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **Godot 4.3+** standard (or .NET if the project switches — default is GDScript) | Same minor version as `game/echo_lattice/project.godot` |
| **Windows desktop export templates** | Editor → Manage Export Templates → install matching version |
| Project path | `game/echo_lattice/` (created by Godot scaffold branch) |
| Export preset | Name must be **`Windows Desktop`** (scripts look up this preset name) |

Optional for Steam overlay testing: Steam client + GodotSteam binaries (see checklist §8).

---

## One-command export

### Linux / macOS / CI

```bash
# From repository root
export GODOT_BIN=/path/to/godot   # optional if `godot` is on PATH
./scripts/echo_lattice/export_windows.sh
```

### Windows (PowerShell)

```powershell
# From repository root
$env:GODOT_BIN = "C:\Path\To\Godot_v4.x_win64.exe"  # optional
.\scripts\echo_lattice\export_windows.ps1
```

### Outputs

```text
dist/echo_lattice/windows/
  EchoLattice.exe
  EchoLattice.pck
```

Exit code non-zero if Godot missing, project missing, or export fails.

---

## First-time editor setup (human)

1. Open `game/echo_lattice/project.godot` in Godot 4.3+.  
2. **Project → Export → Add… → Windows Desktop.**  
3. Preset name: `Windows Desktop`.  
4. **Export Path:** `res://../../dist/echo_lattice/windows/EchoLattice.exe`  
   (or any path; scripts override via CLI `--export-release` output argument).  
5. Options (recommended MVP):  
   - Architecture: **x86_64**  
   - Embed PCK: **off** (separate `.pck` is easier for SteamPipe diffs)  
   - Texture Format: S3TC / BPTC as Godot defaults for desktop  
   - Application → Product/Company/File description: `Echo Lattice`  
   - Icons: set Windows `.ico` when art exists  
6. Save presets. Commit an **example** only if the team agrees — this repo gitignores `export_presets.cfg` by default (machine-local paths). Use [`export_presets.cfg.example`](../../game/echo_lattice/export_presets.cfg.example) as the shared template.

---

## Headless / CI invocation

Scripts wrap:

```bash
"$GODOT_BIN" --headless --path game/echo_lattice \
  --export-release "Windows Desktop" \
  dist/echo_lattice/windows/EchoLattice.exe
```

Notes:

- Run from **repo root** so relative output paths stay stable.  
- Export templates must already be installed for that Godot version on the agent image.  
- For SteamQA, prefer `--export-release` over `--export-debug`.

---

## Post-export acceptance checks

| Check | Pass criteria |
|-------|----------------|
| Files present | `.exe` + `.pck` both non-empty |
| Boots | Double-click / CLI runs to main menu or boot scene |
| No editor deps | Runs on a machine **without** Godot installed |
| Input | Keyboard move works in chamber 0 / stub scene |
| Logging | No spam of missing Steam DLL if Steam optional (stub OK) |
| Retail strip | Before depot upload: remove `steam_appid.txt` if present |
| Size | MVP target well under ~500 MB installed |

Copy into SteamPipe staging:

```bash
mkdir -p steam/echo_lattice/depot_build/windows
cp dist/echo_lattice/windows/EchoLattice.exe \
   dist/echo_lattice/windows/EchoLattice.pck \
   steam/echo_lattice/depot_build/windows/
# + steam_api64.dll when GodotSteam is integrated
```

Then follow depot VDFs under `steam/echo_lattice/`.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Godot binary not found` | Set `GODOT_BIN` or install Godot and add to `PATH` |
| `Export template not found` | Install templates for the **exact** Godot version |
| `Preset not found` | Create preset named exactly `Windows Desktop` |
| `project.godot not found` | Ensure Godot scaffold is merged / present under `game/echo_lattice/` |
| Blank window / immediate quit | Run with console: `EchoLattice.exe` from terminal; check `user://logs` |
| Steam overlay missing | Launch via Steam client install, not raw folder copy (or place valid `steam_appid.txt` for local) |

---

## Related

- [`08_STEAM_CHECKLIST.md`](08_STEAM_CHECKLIST.md) — AppID, tags, capsules, AI disclosure, achievements, Cloud, depots, GodotSteam  
- [`scripts/echo_lattice/`](../../scripts/echo_lattice/) — export scripts  
- [`steam/echo_lattice/`](../../steam/echo_lattice/) — SteamPipe templates  
