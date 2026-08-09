# Windows (+ Demo) export — reproducible builds

**Gate A** Windows shipping primary for Echo Lattice.  
**Engine:** Godot **4.3-stable** · **Project:** `game/echo_lattice`  
**Presets:** `Windows Desktop` · `Windows Demo`  
**Automation:** [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) (`export-windows`, `export-windows-demo`)  
**Local script:** [`tools/release/export_windows.sh`](../../tools/release/export_windows.sh)  
**Toolchain pin:** [`tools/release/godot_toolchain.json`](../../tools/release/godot_toolchain.json)

Companion: [`CI_BUILDS.md`](CI_BUILDS.md) · [`DEMO_SPEC.md`](DEMO_SPEC.md) · [`PLATFORMS.md`](PLATFORMS.md) · [`steam/echo_lattice/README.md`](../../steam/echo_lattice/README.md)

---

## Goals

1. Same commands locally and in CI produce Windows **full** and **demo** artifacts.
2. Every artifact directory carries a **version stamp** + **SHA-256 checksums** + short **ARTIFACTS.md** notes.
3. Coming Soon / page-only phase keeps `steam_enabled=false` (offline OK).
4. No store credentials in the repo; SteamPipe staging stays manual after AppIDs land.

---

## Preset contract

| Preset | Output | Features | Notes |
|---|---|---|---|
| `Windows Desktop` | `builds/windows/EchoLattice.exe` (+ `.pck`) | _(none)_ | Steam / itch Windows primary |
| `Windows Demo` | `builds/windows_demo/EchoLatticeDemo.exe` (+ `.pck`) | `demo` | Act I + Mirror Birth; late chambers excluded from PCK |

Shared hardening (both Windows presets):

| Setting | Value | Why |
|---|---|---|
| `binary_format/architecture` | `x86_64` | Steam Win64 |
| `binary_format/embed_pck` | `false` | Smaller depot diffs |
| `encrypt_pck` | `false` | DRM-free / itch friendly |
| `application/modify_resources` | `false` | CI/container needs **no rcedit** |
| `application/file_version` | `0.2.1.0` | Keep aligned with `project.godot` `config/version` |
| `application/product_version` | `0.2.1.0` | Same; PE write still off until modify_resources |
| `codesign/enable` | `false` | No Authenticode in CI yet |

**Version stamp authority in CI:** sidecar `BUILD_STAMP.json` (not PE resources). When you later enable `modify_resources`, install `rcedit` and keep the four-part version in lockstep with `godot_toolchain.json`.

---

## Toolchain pin + checksum notes

Pinned in `tools/release/godot_toolchain.json`:

| Item | Pin |
|---|---|
| Godot | `4.3-stable` / templates dir `4.3.stable` |
| CI image | `barichello/godot-ci:4.3@sha256:8d3a9fc683fcaa5b7d8b1c90fa94318402ebb00edeb5f6e2df4bac46665b98ff` |
| Linux editor zip SHA-256 | `7de56444b130b10af84d19c7e0cf63cf9e9937ee4ba94364c3b7dd114253ca21` |
| Export templates `.tpz` | Official Godot release asset (~1.07 GiB); **hash-check after download** before installing |

Local editor install (Linux example):

```bash
curl -L -o Godot_v4.3-stable_linux.x86_64.zip \
  https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
echo "7de56444b130b10af84d19c7e0cf63cf9e9937ee4ba94364c3b7dd114253ca21  Godot_v4.3-stable_linux.x86_64.zip" | sha256sum -c -
```

Templates (after download):

```bash
sha256sum Godot_v4.3-stable_export_templates.tpz   # record digest in release notes
mkdir -p "$HOME/.local/share/godot/export_templates/4.3.stable"
# extract .tpz (zip) so windows_release_x86_64 etc. resolve
```

**Artifact checksums** (post-export) live next to the binaries as `SHA256SUMS.txt`. Always re-verify after downloading a CI artifact or copying into `depot_build/`:

```bash
cd game/echo_lattice/builds/windows   # or windows_demo
sha256sum -c SHA256SUMS.txt
```

---

## Local export (parity with CI)

```bash
# From repo root — exports full + demo, stamps + checksums each out dir
./tools/release/export_windows.sh

# Or one target:
./tools/release/export_windows.sh --full
./tools/release/export_windows.sh --demo

# Custom binary:
GODOT=/path/to/Godot_v4.3-stable_linux.x86_64 ./tools/release/export_windows.sh --all
```

Equivalent headless commands (script wraps these + stamp):

```bash
cd game/echo_lattice
godot --headless --path . --export-release "Windows Desktop" builds/windows/EchoLattice.exe
godot --headless --path . --export-release "Windows Demo"    builds/windows_demo/EchoLatticeDemo.exe

# Prefer Python locally; CI uses the POSIX .sh helper (godot-ci has no python3).
python3 ../../tools/release/stamp_export_artifacts.py \
  --out-dir builds/windows \
  --preset "Windows Desktop" \
  --artifact-name echo-lattice-windows-x86_64 \
  --exe-name EchoLattice.exe

sh ../../tools/release/stamp_export_artifacts.sh \
  --out-dir builds/windows_demo \
  --preset "Windows Demo" \
  --artifact-name echo-lattice-windows-demo-x86_64 \
  --exe-name EchoLatticeDemo.exe \
  --custom-features demo
```

Each output directory should contain:

| File | Role |
|---|---|
| `EchoLattice.exe` / `EchoLatticeDemo.exe` | Launch binary |
| `EchoLattice.pck` / `EchoLatticeDemo.pck` | Game data (not embedded) |
| `BUILD_STAMP.json` | Version, git SHA, Godot, features, checksum map |
| `SHA256SUMS.txt` | `sha256sum -c` friendly |
| `ARTIFACTS.md` | Human notes for release ops |

---

## CI / container export

Jobs `export-windows` and `export-windows-demo` in `.github/workflows/ci.yml`:

1. Run after `validate` (Python gates).
2. Use the **digest-pinned** `barichello/godot-ci:4.3` image (templates preinstalled).
3. Move templates into the Actions user home (godot-ci layout).
4. `godot --headless --export-release …`
5. Stamp with `tools/release/stamp_export_artifacts.py`
6. Upload GitHub Actions artifacts:
   - `echo-lattice-windows-x86_64`
   - `echo-lattice-windows-demo-x86_64`

Export jobs use `continue-on-error: true` until the image/digest is trusted as a merge gate; `validate` remains the required ship gate. Confirm a green export run on the PR before SteamPipe staging.

### Download artifacts from Actions

GitHub → Actions → run → Artifacts. After unzip:

```bash
sha256sum -c SHA256SUMS.txt
cat BUILD_STAMP.json   # confirm product_version + git_sha
cat ARTIFACTS.md
```

---

## SteamPipe staging

```bash
# Full game Windows depot
mkdir -p steam/echo_lattice/depot_build/windows
cp -a game/echo_lattice/builds/windows/. steam/echo_lattice/depot_build/windows/
rm -f steam/echo_lattice/depot_build/windows/steam_appid.txt

# Demo Windows depot
mkdir -p steam/echo_lattice/depot_build/windows_demo
cp -a game/echo_lattice/builds/windows_demo/. steam/echo_lattice/depot_build/windows_demo/
rm -f steam/echo_lattice/depot_build/windows_demo/steam_appid.txt
```

Keep stamp + sums in the staging folder for ops audit; they are harmless for players if accidentally shipped, but you may exclude `*.md` / `BUILD_STAMP.json` via depot VDF if you want a minimal install. **Never** ship `steam_appid.txt` in retail.

Then follow [`STEAMWORKS.md`](STEAMWORKS.md) / [`steam/echo_lattice/README.md`](../../steam/echo_lattice/README.md) (`run_app_build` after real AppIDs).

---

## Version bump checklist

When bumping the product version:

1. `game/echo_lattice/project.godot` → `config/version="X.Y.Z"`
2. `tools/release/godot_toolchain.json` → `product_version` + `windows_file_version` (`X.Y.Z.0`)
3. `export_presets.cfg` → both Windows presets `application/file_version` + `product_version`
4. Re-export; confirm `BUILD_STAMP.json` `product_version` matches

Python gate: `python3 game/echo_lattice/tests/test_windows_export.py`

---

## Acceptance (Gate A Windows export)

- [ ] `./tools/release/export_windows.sh --all` (or CI artifacts) produces exe + pck for full and demo
- [ ] `BUILD_STAMP.json` + `SHA256SUMS.txt` + `ARTIFACTS.md` present in both out dirs
- [ ] `sha256sum -c` passes after a fresh download
- [ ] Demo PCK excludes late-act chambers (`test_demo_spec.py` green)
- [ ] `steam_enabled` remains `false` for Coming Soon page-only builds
- [ ] CI container image pinned by digest in `ci.yml` / `godot_toolchain.json`
- [ ] Staging copies omit `steam_appid.txt`
