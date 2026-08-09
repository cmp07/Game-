# Echo Lattice — Steam Deck Verified Prep

**Product:** Echo Lattice (`game/echo_lattice/`)  
**Engine:** Godot 4.3 · GDScript · `gl_compatibility` renderer  
**Target store status:** Steam Deck **Verified** (prep checklist; submit after hardware QA)

This document is the release authority for Deck input, layout, performance, and Proton vs native decisions.

---

## Verdict (prep)

| Pillar | Status | Notes |
|---|---|---|
| Runs on SteamOS | Ready to QA | Prefer **native Linux x86_64** export |
| Full controller support | Implemented | D-Pad / left stick + A/B/X/Y/Start |
| Controller glyphs | Implemented | `InputGlyphs` swaps hints on Deck / after gamepad use |
| Default config playable | Implemented | No mouse/keyboard required for a full run |
| On-screen keyboard | **Not required** | No `LineEdit` / `TextEdit` anywhere in the play path |
| 1280×800 / 16:10 UI | Implemented | `stretch/aspect=expand` + `--deck-layout-check` |
| Performance @ 60 FPS | Target set | 2D Compatibility renderer; see TDP table |
| Battery-friendly defaults | Implemented | VSync on; Deck caps 60 FPS (`--battery` → 40) |

---

## Preferred runtime: native Linux (not Proton)

Echo Lattice is a Godot 4 project. **Ship and verify the Linux export first.**

| Path | When to use | Notes |
|---|---|---|
| **Native Linux x86_64** | Default Deck depot / launch option | `export_presets.cfg` → `Linux/X11` → `builds/linux/EchoLattice.x86_64` |
| Proton (Windows `.exe`) | Fallback only | Works for most Godot games, but adds translation overhead and complicates gamepad/glyph QA. Do **not** mark Verified on Proton if the native build passes. |

### Launch options (Steam)

**Native (recommended):**

```
./EchoLattice.x86_64
```

**Battery QA / longer sessions:**

```
./EchoLattice.x86_64 -- --battery
```

**Proton fallback (Windows depot):** leave blank or use `PROTON_LOG=1` only while debugging.

SteamOS should auto-detect the native binary when the Linux depot is mounted. Keep the Windows depot for desktop; Deck launch config should point at Linux.

### Why native over Proton

1. Godot’s Linux export talks to SDL/gamepads directly — Deck controls need no XInput translation.
2. Lower CPU overhead → easier 4–7 W TDP targets.
3. Saves land under `~/.local/share/godot/app_userdata/Echo Lattice/` (consistent with desktop Linux).
4. Compatibility renderer (`gl_compatibility`) maps cleanly to Deck’s GPU stack without D3D→Vulkan layers.

---

## Controller map (Xbox / Deck face buttons)

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD / Arrows | D-Pad or Left Stick |
| Confirm / select | Enter / Space | **A** |
| Back / Menu | Esc | **B** or **Start** |
| Undo | Z | **X** |
| Restart chamber | R | **Y** |

Bindings live in `game/echo_lattice/project.godot` (`InputEventJoypadButton` / `JoypadMotion`).  
On-screen hints resolve through the `InputGlyphs` autoload (Deck boots into gamepad glyphs).

### Full gamepad path (no OSK)

A complete session must be possible with only the Deck controls:

1. Boot → main menu focus on **Start New Run**
2. A → enter chamber
3. D-Pad / Stick → move; X undo; Y restart; Start/B → menu
4. Goal → chamber-won → A on **Next** / D-Pad to Replay or Menu
5. Wing clear → end screen → A / focus to **New Run** or Menu

There is **no text prompt**, rename field, or lobby code. Steam’s on-screen keyboard must never be required.

---

## Display / UI scale (16:10 · 1280×800)

| Setting | Value | Why |
|---|---|---|
| Base viewport | 960×560 | Existing art/screenshot baseline |
| Stretch mode | `canvas_items` | Crisp 2D |
| Stretch aspect | **`expand`** | Fills 16:10 without letterboxing; logical size ≈ 960×600 on Deck |
| VSync | On | Stable frame pacing |
| Deck window QA | 1280×800 | Matches Steam Deck native panel |

### Layout check

```bash
cd game/echo_lattice
godot --path . -- --deck-layout-check
```

This resizes to 1280×800, walks menu / chamber / won / end, asserts:

- Aspect near **16:10**
- Interactive `Button` / `Label` chrome stays inside a safe inset
- Gamepad glyph string is active (no WASD-only footer on Deck path)
- No text-entry controls exist (OSK not required)

Static binding check (no Godot binary needed):

```bash
python3 game/echo_lattice/tests/check_deck_bindings.py
```

---

## Performance & TDP targets

Echo Lattice is a low-fill 2D ledger puzzle (Compatibility / GLES-style path). It should hold Verified fps at modest watts.

| Profile | FPS cap | Suggested SteamOS TDP | Expected |
|---|---|---|---|
| **Verified default** | 60 | **7 W** | Locked 60 with headroom |
| Battery / couch | 40 (`--battery`) | **4 W** | Smooth step-based play |
| Stress ceiling | 60 uncapped desktop | 10–15 W | Not required for Verified |

### Runtime defaults (`DeckProfile` autoload)

When `SteamDeck=1`, `STEAMDECK=1`, `/home/deck` exists, or board name looks like Jupiter/Galileo:

- VSync enabled
- `Engine.max_fps = 60` (or `40` with `--battery`)
- Borderless/fullscreen window
- Gamepad glyphs preferred immediately

TDP itself is **not** settable from the game — publish the 7 W / 4 W guidance on the Steam support page and in this doc for QA.

### QA probes on device

1. 40-minute daily wing at 7 W — confirm no thermal clock-slide below 60.
2. Same wing at 4 W + `--battery` — confirm input stays edge-triggered and readable.
3. Overlay (Steam button) open/close mid-chamber — resume without stuck axes.

---

## Steam Deck Verified checklist (submit)

Copy into the partner questionnaire after hardware passes:

- [ ] Boots to menu on SteamOS without extra launch options (native Linux)
- [ ] All prompts show controller glyphs (A/B/X/Y/D-Pad), not keyboard-only
- [ ] Full run possible with Deck controls only
- [ ] OSK never invoked
- [ ] UI readable and unclipped at 1280×800 (16:10); no essential text in dead bezels
- [ ] Default config hits **60 FPS** at ≤ **7 W** TDP
- [ ] Battery profile documented (`--battery` → 40 FPS / 4 W guidance)
- [ ] Proton **not** required for the Deck launch option
- [ ] `godot -- --deck-layout-check` exits 0
- [ ] `python3 game/echo_lattice/tests/check_deck_bindings.py` exits 0

---

## Build

```bash
cd game/echo_lattice
godot --headless --export-release "Linux/X11" builds/linux/EchoLattice.x86_64
# optional desktop depot
godot --headless --export-release "Windows Desktop" builds/windows/EchoLattice.exe
```

Ship `EchoLattice.x86_64` + `EchoLattice.pck` side by side. Mark the Linux build executable (`chmod +x`).

---

## Code map

| Piece | Path |
|---|---|
| Input map (keyboard + joypad) | `game/echo_lattice/project.godot` |
| Glyph resolver | `game/echo_lattice/scripts/input_glyphs.gd` |
| Deck detect / FPS / layout report | `game/echo_lattice/scripts/deck_profile.gd` |
| Layout QA entry | `Main._run_deck_layout_check` (`--deck-layout-check`) |
| Binding linter | `game/echo_lattice/tests/check_deck_bindings.py` |
| Linux export preset | `game/echo_lattice/export_presets.cfg` (`Linux/X11`) |

---

## Out of scope (this prep)

- Steamworks achievements / Cloud (see Steam checklist PR if present)
- Official Steam Input official config upload (do after AppID exists)
- Gyro / touch trackpads as primary move (D-Pad/stick is enough for grid steps)
- Changing the art baseline resolution away from 960×560
