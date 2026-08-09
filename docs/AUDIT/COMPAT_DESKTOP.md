# Echo Lattice — Desktop compatibility audit

**Product:** Echo Lattice (`game/echo_lattice/`)  
**Engine:** Godot **4.3** · GDScript · `gl_compatibility` renderer  
**Audit scope:** Windows 10/11, Linux distros, macOS (Intel / Apple Silicon), filesystem case, paths, display scale / HiDPI, VSync, controllers, keyboards, missing GodotSteam, unsigned macOS, export presets vs shipping reality  
**Authority date:** 2026-08-09 · branch base `cursor/echo-lattice-rc1`  
**Method:** Cloud-only static audit of committed presets, autoloads, and release docs (no device farm). Hardware QA still required before claiming Verified / public mac.

Companions: [`../RELEASE/PLATFORMS.md`](../RELEASE/PLATFORMS.md) · [`../RELEASE/CI_BUILDS.md`](../RELEASE/CI_BUILDS.md) · [`../RELEASE/STEAM_DECK.md`](../RELEASE/STEAM_DECK.md) · [`../RELEASE/STEAMWORKS.md`](../RELEASE/STEAMWORKS.md) · [`../RELEASE/ACCESSIBILITY.md`](../RELEASE/ACCESSIBILITY.md)

---

## 1. Executive verdict

| Platform | Ship posture | Confidence |
|---|---|---|
| **Windows 10/11 x86_64** | **Supported — shipping primary** | High for offline puzzle loop; Steamworks still stubbed |
| **Linux x86_64 (SteamOS / Ubuntu-class)** | **Supported — Steam Linux + Deck path** | Medium–high for native export; Wayland / exotic glibc unproven |
| **macOS universal (Intel + Apple Silicon)** | **Stub only — not public-ready** | Low until codesign + notarization + hardware smoke |
| **Steam Deck (native Linux)** | **Prep complete — needs device QA** | See Deck doc; prefer native over Proton |
| **itch DRM-free (Win/Linux)** | **Supported** when `steam_enabled` stays false | High (same presets, no Steam DLLs) |
| **Win32 / Linux arm64 / macOS Intel-only SKU** | **Out of scope** | No presets |

**Bottom line:** The desktop loop is built around portable `res://` / `user://` I/O, forced VSync, Compatibility renderer, and a keyboard + Xbox/Deck gamepad map. The largest ship gaps are **unsigned macOS**, **missing GodotSteam binaries**, and several **preset/doc mismatches** (renderer feature tag, macOS minimum OS, controller store copy, FAQ `--windowed`).

---

## 2. Supported configuration matrix

Legend: **Ship** = intended public artifact · **QA** = must pass before store claim · **Stub** = preset exists, not public · **N/A** = not offered · **Risk** = known gap

### 2.1 OS × arch × store

| Config | Arch | Export preset | Artifact | Steam | itch | Status |
|---|---|---|---|---|---|---|
| Windows 10 64-bit | x86_64 | `Windows Desktop` | `builds/windows/EchoLattice.exe` + `.pck` | **Ship primary** | Ship | **Supported** |
| Windows 11 64-bit | x86_64 | `Windows Desktop` | same | **Ship primary** | Ship | **Supported** |
| Windows Demo (Next Fest) | x86_64 | `Windows Demo` (`custom_features=demo`) | `builds/windows_demo/EchoLatticeDemo.exe` | Demo AppID | Optional | **Supported** (scoped PCK) |
| SteamOS 3 / Steam Deck | x86_64 | `Linux/X11` | `EchoLattice.x86_64` + `.pck` | Deck launch option | N/A | **QA** (native preferred) |
| Ubuntu 22.04+ / similar glibc | x86_64 | `Linux/X11` | same | Linux depot | Ship | **Supported*** |
| Fedora / Arch / immutable gaming | x86_64 | `Linux/X11` | same | Best-effort | Best-effort | **Risk** — smoke only |
| Linux arm64 / Raspberry / Asahi | arm64 | — | — | N/A | N/A | **Out of scope** |
| macOS 12+ Apple Silicon | arm64 (universal binary) | `macOS` | `builds/macos/EchoLattice.zip` | Depot after notarize | After notarize | **Stub** |
| macOS 12+ Intel | x86_64 (universal binary) | `macOS` | same | same | same | **Stub** |
| macOS unsigned local | universal | `macOS` (`codesign=0`, `notarization=0`) | same | **Do not ship** | **Do not ship** | CI/dev smoke only |
| Proton (Windows on Deck) | x86_64 | Windows build under Proton | `.exe` | Fallback only | N/A | Acceptable fallback, not Verified path |
| Win32 (x86) | x86 | — | — | N/A | N/A | **Out of scope** |

\*“Supported” Linux means: glibc-based x86_64 desktop with OpenGL 3.3, executable bit set, and side-by-side `.pck`. Not a guarantee for every rolling distro.

### 2.2 Runtime / display matrix

| Concern | Windows | Linux desktop | Steam Deck | macOS (stub) |
|---|---|---|---|---|
| Renderer | `gl_compatibility` (OpenGL / ANGLE stack per Godot) | OpenGL 3.3 path | GLES-style Compatibility | Metal via Godot mac export; `high_res=true` |
| Base viewport | 960×560, stretch `canvas_items` / `expand` | same | logical ~960×600 @ 1280×800 | same |
| VSync | On (`project.godot` + `DeckProfile`) | On | On + `max_fps` 60 (40 w/ `--battery`) | On (expected) |
| UI scale | Settings `ui_scale` 0.85–1.5 → `content_scale_factor` | same | QA @ 1.0 and 1.25 | same |
| HiDPI / Retina | OS scale + Godot stretch; no custom DPI math | Fractional scaling **Risk** | Native 1280×800 | `display/high_res=true` |
| Fullscreen policy | Default windowed overrides 1152×672 | Windowed | Forced fullscreen when Deck detected | Unknown until QA |
| Headless CI | DisplayServer `headless` skips display mutators | same | `--deck-layout-check` needs display | mac export can smoke on Linux as non-shipping |

### 2.3 Input matrix

| Input | Supported configs | Notes |
|---|---|---|
| Keyboard (US QWERTY) | All desktop | Defaults use `physical_keycode` (WASD / arrows / Z / R / Esc) |
| Keyboard (AZERTY / QWERTZ) | Expected via physical keys | Remap path prefers `keycode` then physical — **Risk** after first rebind |
| Mouse | Menus / Settings | Not required for a full run |
| Xbox / XInput pads | Win / Linux / Deck | Canonical glyph language (A/B/X/Y) |
| Steam Deck controls | Native Linux | D-Pad + left stick; Start/B menu; X undo; Y restart |
| DualSense / Switch Pro | Via Steam Input / SDL mapping | No DualSense-specific glyphs; treat as Xbox labels |
| Touch / gyro | Out of scope | Not primary move |
| On-screen keyboard | Not required | No `LineEdit` / `TextEdit` on play path |

### 2.4 Steamworks / offline matrix

| Build | GodotSteam present? | `steam_enabled` | Expected backend | Achievements / Cloud / Overlay |
|---|---|---|---|---|
| Editor / CI / itch | No (`addons/` absent) | `false` (default) | `SteamStubBackend` | Stub records / local save only |
| Steam retail (today) | **Missing** | still `false` in repo | Stub | Offline play OK; no real Steam API |
| Steam retail (target) | GDExtension + redistribs | `true` on Steam export only | `SteamGodotSteamBackend` | Soft-fail if init fails |
| Missing / failed Steam init | N/A | any | Stay / fall back inert | Gameplay must continue |

### 2.5 Export preset ↔ reality checklist

| Preset claim | Committed reality | Verdict |
|---|---|---|
| Godot 4.3 desktop exports | `config/features` includes `"4.3"`; templates expected `4.3.stable` | OK |
| Rendering = Compatibility | `renderer/rendering_method=gl_compatibility` | OK |
| Feature tag `"Forward Plus"` | Still in `config/features` despite Compatibility renderer | **Mismatch** (editor tag only; fix recommended) |
| Windows x86_64, PCK external, no rcedit | `architecture=x86_64`, `embed_pck=false`, `modify_resources=false` | OK |
| Windows ANGLE / D3D12 multiarch | `export_angle=0`, `export_d3d12=0` | Reality: OpenGL Compatibility path only |
| Linux/X11 x86_64 | Preset name/platform `Linux/X11` | OK for Deck/SteamOS; Wayland hosts use Godot’s SDL backend — **smoke needed** |
| macOS `universal` | `binary_format/architecture=universal` | OK intent |
| macOS `min_macos_version=10.12` | Preset says 10.12; store copy says macOS **12** | **Mismatch** — raise preset floor to match Godot 4.3 / store |
| macOS codesign / notarization | Both **disabled** | **Unsigned** — Gatekeeper blocks public users |
| macOS `display/high_res=true` | Set | Good for Retina; still needs notarized binary |
| Demo exclude filters | Drops chambers `09_*` and `1*_*` / `2*_*` / `3*_*` | Matches demo scope docs |
| Retail `custom_features` | Empty string (not `steam`) | Matches offline-first; Steam feature tag not yet wired |
| Steam depot templates | Windows VDF only under `steam/echo_lattice/` | Linux/mac depots documented, not templated |

---

## 3. Platform deep dives

### 3.1 Windows 10 / 11

**In scope:** 64-bit only. Store minimums in [`STEAM_STORE_FINAL.md`](../RELEASE/STEAM_STORE_FINAL.md) (OpenGL 3.3 / D3D11-capable GPU, 4 GB RAM).

| Topic | Finding |
|---|---|
| Binary | `EchoLattice.exe` + `EchoLattice.pck` side by side; console wrapper enabled in preset |
| Codesign | `codesign/enable=false` — fine for Steam; SmartScreen reputation builds via Steam distribution |
| Save / logs | `%APPDATA%\Godot\app_userdata\Echo Lattice\` (`user://`) |
| Atomic save | `DirAccess.rename_absolute` with copy fallback if rename fails (cross-volume / AV) |
| Controllers | XInput / Steam Input; project joy buttons match Xbox layout |
| Known doc drift | Support FAQ suggests `--windowed` launch option — **not implemented** in `main.gd` / `DeckProfile` |

**QA focus:** Win10 clean profile boot, Win11 125%/150% display scale, Alt+Tab mid-rewrite, gamepad + keyboard remaps, antivirus locking `save.json.tmp`.

### 3.2 Linux distros

**Primary targets:** SteamOS 3 (Deck), Ubuntu 22.04 LTS class for desktop Steam.

| Topic | Finding |
|---|---|
| Preset | `Linux/X11` → `EchoLattice.x86_64` |
| Permissions | Ship `chmod +x`; document for itch tarballs |
| Case sensitivity | Ext4/Btrfs/XFS are case-sensitive — see §4 (repo currently clean) |
| Libraries | Godot 4.3 export is largely self-contained; still smoke Mesa / proprietary NVIDIA |
| Wayland | Preset label is X11; modern Godot/SDL often runs under Wayland — treat as **unverified** |
| Flatpak / Steam Runtime | Deck detection also checks `BOARD_NAME` / `SteamDeck` env |
| Userdata | `~/.local/share/godot/app_userdata/Echo Lattice/` |

**Distro matrix (policy):**

| Distro class | Policy |
|---|---|
| SteamOS 3 | **Must pass** before Deck Verified claim |
| Ubuntu 22.04 / 24.04 | **Should pass** for Steam Linux depot |
| Debian stable | Best-effort |
| Fedora / Arch / Gentoo | Best-effort; player-supported |
| musl (Alpine) | **Unsupported** |

### 3.3 macOS (Intel + Apple Silicon)

| Topic | Finding |
|---|---|
| Arch | `universal` — one zip covers Intel + Apple Silicon |
| Bundle ID | `com.echolattice.app` |
| HiDPI | `display/high_res=true` |
| Signing | `codesign/codesign=0`, empty identity / team |
| Notarization | `notarization/notarization=0` |
| Public install | Gatekeeper + quarantine will block; users need right-click Open or `xattr -d com.apple.quarantine` — **unacceptable for Steam/itch public** |
| Min OS conflict | Preset `10.12` vs store doc macOS 12 vs Godot 4.3 practical floor — **align to ≥12 before ship** |
| Steamworks | Same stub policy; GodotSteam mac dylibs not in repo |

**Ship gate for mac:** macOS runner export → Developer ID sign → notarize → staple → smoke Intel (or Rosetta) + Apple Silicon → then Steam depot 3 / itch `osx`.

---

## 4. Filesystem case sensitivity

| Check | Result |
|---|---|
| Case-colliding names under `game/echo_lattice/` | **None** found (cloud scan) |
| Content IDs / chamber files | Lowercase snake_case (`00_quiet_span.json`, …) |
| Script / scene `res://` paths | Forward-slash Godot paths; no `C:\` literals in GDScript |
| Risk pattern | Developing on Windows/mac and renaming only by case → Linux/Deck break |

**Policy:** Never rely on case-insensitive FS. CI on Linux (already the natural export host) is the case oracle. When adding assets, keep filenames lowercase ASCII.

---

## 5. Paths and userdata

All gameplay persistence goes through Godot virtual paths — good for cross-OS.

| Virtual path | Purpose |
|---|---|
| `user://save.json` (+ `.tmp` / `.bak`) | Campaign / daily progress (`SaveManager`) |
| `user://echo_lattice_settings.json` | Accessibility / audio / bindings |
| `user://locale.cfg` | Locale override |
| `user://logs/*` | Crash / session hooks |
| `user://telemetry/*` | Local balance JSONL (no network by default) |
| `res://content/**` | Chambers, acts, daily calendar (read-only in export) |

| OS | Typical userdata root |
|---|---|
| Windows | `%APPDATA%\Godot\app_userdata\Echo Lattice\` |
| Linux / Steam Deck | `~/.local/share/godot/app_userdata/Echo Lattice/` |
| macOS | `~/Library/Application Support/Godot/app_userdata/Echo Lattice/` |

**Path hygiene observed:**

- `String.path_join` / `ProjectSettings.globalize_path` used for absolute ops.
- `ArtKit` loads PNGs via `FileAccess` + `globalize_path` (headless-safe; does not depend on `.import` alone).
- `steam_appid.txt` resolved beside `OS.get_executable_path()` — correct for Win/Linux; mac `.app` layout needs QA once signed.
- Atomic save rename has a Windows-friendly copy fallback.

**Risks:**

- App folder name includes a **space** (`Echo Lattice`) — fine for Godot, brittle if external tools quote poorly.
- Steam Cloud (when enabled) must map the same `user://` root per OS; remote name is `save.json` only.
- Crash-pack export writing to a player-chosen folder must remain sandbox-friendly on notarized mac (sandbox currently **off** in preset).

---

## 6. Display scale, HiDPI, VSync

### Display pipeline

```
project.godot
  viewport 960×560
  window override 1152×672
  stretch: canvas_items + expand
  vsync_mode = 1
        │
        ▼
DeckProfile.apply_runtime_defaults()
  VSYNC_ENABLED always (non-headless)
  Deck → fullscreen + max_fps 60|40
  Desktop → max_fps 0 (monitor refresh via VSync)
        │
        ▼
AccessibilityService.apply_ui_scale()
  content_scale_factor ∈ [0.85, 1.5]
```

| Topic | Status |
|---|---|
| VSync | **Forced on** at runtime — good for Deck Verified pacing; no in-game VSync toggle |
| HiDPI Windows | Relies on OS scaling + stretch; QA 100/125/150/200% |
| Linux fractional scale (125%/150% Wayland) | **Risk** — bitmap UI may blur; exercise `ui_scale` |
| macOS Retina | `high_res=true` expected; verify crisp ledger lines |
| 32:9 / ultrawide | `expand` fills; chrome uses layout report margins on Deck path |
| 4K | Use UI scale ≥1.25; no separate 4K HUD assets |

**Doc vs code:** Support FAQ `--windowed` is aspirational. Implemented CLI flags today: `--battery`, `--deck-layout-check`, `--selftest`, `--demo` (see `main.gd` / `demo_build.gd`).

---

## 7. Controllers

Authoritative map (from `project.godot` + Deck docs):

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD / Arrows | D-Pad or Left Stick |
| Confirm | Enter / Space | **A** |
| Menu / Back | Esc | **B** and/or **Start** |
| Undo | Z | **X** |
| Restart | R | **Y** |
| Ghost assist | G | **Left shoulder** (button 9) in `project.godot` |

| Finding | Severity |
|---|---|
| Full pad path implemented for menu → chamber → won → end | OK |
| `InputGlyphs` uses Xbox / Deck face labels | OK for Steam |
| `ActionRemap.GAMEPAD_DEFAULTS` sets pause=`Start` only and ghost_assist=`B`, **dropping** project.godot’s B-as-pause + LS ghost | **Medium** — first keyboard remap / reset can change pad feel |
| DualSense / Switch glyphs not localized | Low — Steam Input remaps to Xbox semantics |
| Store copy still says “keyboard/mouse required until glyphs land” | **Doc drift** vs Deck/a11y work |
| Support FAQ still downplays controllers | **Doc drift** |

---

## 8. Keyboards

| Topic | Finding |
|---|---|
| Default bindings | `physical_keycode` — layout-stable for WASD cluster |
| Echo / key-repeat | Chamber ignores key echoes; hold-to-walk is opt-in |
| Remap persistence | `user://echo_lattice_settings.json` → `ActionRemap` rebuilds `InputMap` |
| Remap encoding | Saves `OS.get_keycode_string(keycode)` preferring **keycode** over physical | **Risk** on AZERTY: rebound keys may follow labels, not positions |
| Gamepad preservation | Remap erases action events then re-adds joy events (or defaults) | See §7 drift |
| IME / text entry | None required | Good for Deck OSK policy |

---

## 9. Missing GodotSteam

Repo state (audit):

- No `game/echo_lattice/addons/godotsteam/` (or any `addons/`).
- `steam_features.json`: `steam_enabled: false`, `prefer_godotsteam_when_present: true`.
- `SteamGodotSteamBackend.is_godotsteam_present()` probes `Engine` singleton / `ClassDB` / autoload node — safe no-op when absent.
- Redistributables (`steam_api64.dll`, `libsteam_api.so`, mac dylib) **not** staged in `steam/echo_lattice/depot_build/`.

| Scenario | Result |
|---|---|
| itch / CI / editor | Stub backend; offline puzzle OK |
| Steam build without GDExtension | Same — **no crash**, no real achievements/overlay/cloud |
| Steam build with GodotSteam + `steam_enabled` | Real backend; soft-fail if Steam client/API missing |
| Wrong GodotSteam version vs Godot 4.3 | Init fail → inert / stub behavior; pin versions in release notes |

**Bring-up checklist** (from [`STEAMWORKS.md`](../RELEASE/STEAMWORKS.md), condensed): install matching GodotSteam → enable flag on Steam export only → per-OS redistribs in depots → never ship `steam_appid.txt` / AppID `480` retail → smoke overlay pause + one achievement.

---

## 10. Unsigned macOS

| Gate | Current | Public ship requirement |
|---|---|---|
| Export zip | Yes (preset) | Yes |
| Codesign (Developer ID Application) | **Off** | **Required** |
| Notarization + staple | **Off** | **Required** |
| Hardened Runtime / entitlements | Defaults / sandbox off | Review when enabling network/cloud |
| Apple Silicon + Intel smoke | Not done in this audit | Required |
| Steam mac depot / itch `osx` | Blocked | After gates green |

Until then: treat mac artifacts as **non-shipping**, matching [`PLATFORMS.md`](../RELEASE/PLATFORMS.md) / [`CI_BUILDS.md`](../RELEASE/CI_BUILDS.md) / RC1 non-goals.

---

## 11. Findings register (actionable)

| ID | Area | Finding | Severity | Suggested action |
|---|---|---|---|---|
| CD-1 | macOS | Unsigned / non-notarized preset | **Blocker for mac ship** | CI secrets + enable codesign/notarization on mac runner |
| CD-2 | Steamworks | GodotSteam + redistribs absent; `steam_enabled` false | High for Steam features; **non-blocking** for offline | Pin addon; Steam-only feature flag / export |
| CD-3 | Presets | `config/features` still lists `Forward Plus` while renderer is Compatibility | Low | Change feature tag to Compatibility / remove misleading tag |
| CD-4 | macOS | `min_macos_version=10.12` vs store macOS 12 | Medium | Align preset + store + Godot 4.3 floor |
| CD-5 | Input | `ActionRemap` gamepad defaults ≠ `project.godot` (B / shoulder) | Medium | Unify defaults; keep B=back/menu + separate assist |
| CD-6 | Docs | FAQ `--windowed` not implemented | Low | Implement flag or remove FAQ line |
| CD-7 | Docs | Store / FAQ controller copy lags Deck + a11y work | Low | Update Steam copy when claiming Full Controller Support |
| CD-8 | Linux | Wayland / fractional scaling untested | Medium | Add Ubuntu Wayland + Deck smoke to QA |
| CD-9 | Depots | Only Windows SteamPipe templates committed | Medium | Add Linux/mac depot VDFs when those SKUs ship |
| CD-10 | Paths | Userdata dir has space (`Echo Lattice`) | Info | Keep quoting in scripts; document for support |
| CD-11 | Case | No collisions today | Info | Keep Linux CI as case gate |
| CD-12 | Demo | Demo preset is Windows-only | Info | Add Linux demo export if Next Fest Deck promo needs it |

---

## 12. Manual QA matrix (before store claims)

Run on **exported** binaries, not only the editor.

| # | Config | Checks |
|---|---|---|
| Q1 | Win10 + Win11, 100% & 150% scale | Boot, one chamber, save/quit/continue, settings UI scale 1.25 |
| Q2 | Win11 + Xbox pad | Full run without keyboard; glyph footer swaps |
| Q3 | Win11 AZERTY | Defaults still move on physical WASD positions; remap Undo once |
| Q4 | Ubuntu 22.04 X11 + Wayland | `chmod +x`, `.pck` adjacent, VSync tear-free, fractional 125% |
| Q5 | Steam Deck native | Checklist in [`STEAM_DECK.md`](../RELEASE/STEAM_DECK.md); `--deck-layout-check` |
| Q6 | Deck Proton fallback | Boot Windows build once; do **not** claim Verified on this path if native works |
| Q7 | macOS unsigned | Confirm Gatekeeper block (expected) |
| Q8 | macOS notarized (when ready) | Intel + Apple Silicon: boot, Retina sharpness, pad, save path |
| Q9 | No Steam client | Offline campaign; stub backend; no modal hard-fail |
| Q10 | Steam client without GodotSteam | Same as Q9 today |
| Q11 | itch zip Win/Linux | No `steam_api*` DLLs; `steam_enabled` false |

Automated gates (no hardware):

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/check_deck_bindings.py
python3 game/echo_lattice/tests/test_steamworks.py
python3 game/echo_lattice/tests/test_a11y_settings.py
# when Godot available:
godot --headless --path game/echo_lattice -- --selftest
```

---

## 13. Code & doc map

| Piece | Path |
|---|---|
| Export presets | `game/echo_lattice/export_presets.cfg` |
| Project display / input / renderer | `game/echo_lattice/project.godot` |
| Deck detect / VSync / FPS | `game/echo_lattice/scripts/deck_profile.gd` |
| Glyphs | `game/echo_lattice/scripts/input_glyphs.gd` |
| UI scale | `game/echo_lattice/scripts/a11y/accessibility_service.gd` |
| Remap | `game/echo_lattice/scripts/a11y/action_remap.gd` |
| Saves | `game/echo_lattice/scripts/save_manager.gd` |
| Steam facade / stub / GodotSteam | `game/echo_lattice/scripts/steam/` |
| Feature flags | `game/echo_lattice/config/steam_features.json` |
| SteamPipe (Windows) | `steam/echo_lattice/` |
| Platform strategy | `docs/RELEASE/PLATFORMS.md` |
| CI sketch | `docs/RELEASE/CI_BUILDS.md` |

---

## 14. Explicit non-goals (this audit)

- Console ports (Switch / Xbox / PlayStation)
- HTML5 / mobile exports
- Declaring Steam Deck **Verified** without hardware
- Shipping unsigned mac builds to paying players
- Inventing a real Steam AppID or committing Valve redistributables

---

*Cloud-only audit. Re-run after GodotSteam bring-up, mac notarization, or any export_presets.cfg change.*
