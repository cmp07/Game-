# CI builds (Godot desktop)

Automates the matrix in [`PLATFORMS.md`](PLATFORMS.md).  
**Windows (+ Demo) deep dive:** [`BUILD_WINDOWS.md`](BUILD_WINDOWS.md) · script [`tools/release/export_windows.sh`](../../tools/release/export_windows.sh)

**Committed workflow:** [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)

| Job | Required? | Notes |
|---|---|---|
| `validate` | **Yes** | Chamber validate + Python gates (Steamworks, demo, Windows export contract, Deck, locale, a11y) |
| `export-linux` / `export-windows` / `export-windows-demo` | Soft gate | Godot **4.3** via digest-pinned `barichello/godot-ci:4.3@sha256:8d3a9fc…`; Windows jobs stamp `BUILD_STAMP.json` + `SHA256SUMS.txt` + `ARTIFACTS.md`. `continue-on-error` until trusted as merge-blocking |

macOS notarization / SteamCMD / itch butler publish remain manual (secrets checklist below). AppID / depot placeholders: [`APPID_PLACEHOLDER_GATES.md`](APPID_PLACEHOLDER_GATES.md).

**Engine:** Godot **4.3-stable**  
**Project:** `game/echo_lattice`  
**Presets:** `Windows Desktop` · `Linux/X11` · `macOS` · `Windows Demo`  
**Toolchain pin:** [`tools/release/godot_toolchain.json`](../../tools/release/godot_toolchain.json)

---

## Goals

1. Every tag / release branch produces **Win + Linux** artifacts suitable for Steam depots and itch butler.
2. **macOS** zip is produced on a macOS runner (or unsigned on Linux for smoke only); notarization is a gated job.
3. Headless **self-test** and chamber validation gate exports.
4. No store credentials in the repo — Steam / itch / Apple secrets live in CI.

---

## Job graph

```text
validate ──┬── export-windows ──┐
           ├── export-linux ────┼── package ── upload-artifacts
           └── export-macos* ───┘
                                └── (manual) publish-steam / publish-itch
```

\* `export-macos` public signing requires `macos-latest` + Apple secrets. A Linux job may still run `--export-release "macOS"` as a **preset smoke** if templates are present; treat that artifact as **non-shipping**.

---

## Validate job

Implemented in `.github/workflows/ci.yml` (`validate`). Python-only; no Godot required for merge gate:

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/test_steamworks.py
python3 game/echo_lattice/tests/test_demo_spec.py
python3 game/echo_lattice/tests/check_deck_bindings.py
python3 game/echo_lattice/tests/validate_locale.py
python3 game/echo_lattice/tests/test_a11y_settings.py
```

Optional Godot headless self-test (local or future hard gate once the container job is merge-blocking):

```bash
godot --headless --path game/echo_lattice -- --selftest
```

Fail the pipeline if validate ≠ `result: OK` / unittest OK.

---

## Export templates

Install once per job (cache by version):

```bash
# templates archive: Godot_v4.3-stable_export_templates.tpz
mkdir -p "$HOME/.local/share/godot/export_templates/4.3.stable"
# extract .tpz (zip) contents into that directory so linux_release.x86_64 etc. resolve
```

Windows runner: `%APPDATA%\Godot\export_templates\4.3.stable\`  
macOS runner: `~/Library/Application Support/Godot/export_templates/4.3.stable/`

---

## Export jobs

```yaml
export-linux:
  needs: validate
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    # install Godot + templates (or restore cache)
    - name: Export Linux
      working-directory: game/echo_lattice
      run: |
        mkdir -p builds/linux
        godot --headless --export-release "Linux/X11" builds/linux/EchoLattice.x86_64
    - uses: actions/upload-artifact@v4
      with:
        name: echo-lattice-linux-x86_64
        path: game/echo_lattice/builds/linux/

export-windows:
  needs: validate
  runs-on: windows-latest   # or linux + mingw templates if you standardize on Linux exporters
  steps:
    - uses: actions/checkout@v4
    - name: Export Windows
      working-directory: game/echo_lattice
      run: |
        mkdir builds\windows
        godot --headless --export-release "Windows Desktop" builds/windows/EchoLattice.exe
    - uses: actions/upload-artifact@v4
      with:
        name: echo-lattice-windows-x86_64
        path: game/echo_lattice/builds/windows/

export-macos:
  needs: validate
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - name: Export macOS (unsigned stub OK in CI)
      working-directory: game/echo_lattice
      run: |
        mkdir -p builds/macos
        godot --headless --export-release "macOS" builds/macos/EchoLattice.zip
      env:
        # When ready to ship mac publicly, set codesign/notarization in the preset
        # or override via Godot env vars, e.g.:
        # GODOT_MACOS_CODESIGN_CERTIFICATE_FILE: ${{ secrets.MAC_CERT_P12 }}
        # GODOT_MACOS_CODESIGN_CERTIFICATE_PASSWORD: ${{ secrets.MAC_CERT_PASSWORD }}
        # GODOT_MACOS_NOTARIZATION_API_UUID: ${{ secrets.APPLE_API_UUID }}
        # GODOT_MACOS_NOTARIZATION_API_KEY_ID: ${{ secrets.APPLE_API_KEY_ID }}
        # GODOT_MACOS_NOTARIZATION_API_KEY: ${{ secrets.APPLE_API_KEY_P8 }}
    - uses: actions/upload-artifact@v4
      with:
        name: echo-lattice-macos-universal
        path: game/echo_lattice/builds/macos/
```

### Preset → artifact map

| Preset | Artifact name | Consumers |
|---|---|---|
| Windows Desktop | `echo-lattice-windows-x86_64` | Steam depot 1, itch channel `windows` (+ stamp/sums) |
| Windows Demo | `echo-lattice-windows-demo-x86_64` | Demo depot / Next Fest |
| Linux/X11 | `echo-lattice-linux-x86_64` | Steam depot 2, Deck QA, itch `linux` |
| macOS | `echo-lattice-macos-universal` | Steam depot 3 (after notarize), itch `osx` |

---

## Packaging sketch

```bash
# after downloads
VERSION="${GITHUB_REF_NAME:-0.2.0}"
mkdir -p dist
(
  cd windows_artifact && zip -r "../dist/EchoLattice-${VERSION}-windows-x86_64.zip" .
)
(
  cd linux_artifact && tar -czf "../dist/EchoLattice-${VERSION}-linux-x86_64.tar.gz" .
)
cp macos_artifact/EchoLattice.zip "dist/EchoLattice-${VERSION}-macos-universal.zip"
```

**itch DRM-free:** upload the same zips via [butler](https://itch.io/docs/butler/); do not inject Steam DLLs.  
**Steam:** push with `steamcmd` + an app build VDF (depots per OS). Keep the VDF and Steamworks scripts out of public forks if they embed app IDs you want private — app IDs alone are not secrets, but login tokens are.

---

## Steam Deck smoke (manual or device job)

Not fully automatable without hardware. Minimum release checklist:

1. Install Linux build via sideload or Steam branch.
2. Boot to menu; complete one chamber with **Deck controls**.
3. Suspend / resume once; confirm save intact.
4. Confirm text legible at 100% / 150% UI scale.

Optional CI proxy: run the exported Linux binary under `xvfb-run` with `--selftest` (already covered in validate if you also execute the **exported** binary, not only the editor build).

```bash
chmod +x builds/linux/EchoLattice.x86_64
xvfb-run -a builds/linux/EchoLattice.x86_64 --headless -- --selftest
# only if the export forwards CLI; otherwise keep editor self-test as the gate
```

---

## Secrets checklist

| Secret | Used by |
|---|---|
| (none for unsigned Win/Linux export) | default CI |
| `MAC_CERT_P12` + password | macOS codesign |
| Apple Notary API key fields | macOS notarization |
| `STEAM_USERNAME` / `STEAM_PASSWORD` or Build account + TOTP | `steamcmd` deploy |
| `ITCH_API_KEY` | butler push |

Never commit certificates or Steam Guard ma-files.

---

## Local parity

Developers should be able to run the same commands as CI:

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/test_windows_export.py
godot --headless --path game/echo_lattice -- --selftest
./tools/release/export_windows.sh --all
godot --headless --path game/echo_lattice --export-release "Linux/X11" builds/linux/EchoLattice.x86_64
```

See [`BUILD_WINDOWS.md`](BUILD_WINDOWS.md) and [`docs/ECHO_LATTICE/13_VERTICAL_SLICE_README.md`](../ECHO_LATTICE/13_VERTICAL_SLICE_README.md) § Building.

---

## Out of scope for this sketch

- Console builder images (Switch/Xbox/PS) — port partner pipelines only  
- Epic / GOG upload automation — add when those stores are greenlit  
- HTML5 export — not a Steam primary artifact
