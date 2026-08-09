# Echo Lattice — Release Accessibility Checklist

Certification-oriented pass for **Xbox Accessibility Certification Requirements (ACR)** themes and **Steam Deck** playability. Implementation lives under `game/echo_lattice/scripts/a11y/` and is wired into Juice, Chamber, Menu, and Settings.

Persistence: `user://echo_lattice_settings.json` (defaults in `game/echo_lattice/config/default_settings.json`).

---

## Ship features (must work end-to-end)

| Feature | Setting | Runtime path | Manual verify |
|---|---|---|---|
| **Colorblind** | Settings → Colorblind mode (+ pattern cues) | `AccessibilityService.role_color()` → chamber echo walls, fossils, telegraph, checkpoints | Switch to Protanopia; rewrite once — fossils must not rely on rust-vs-teal alone; patterns visible when cues on |
| **Reduce flash** | Settings → Reduce flash / Reduce motion | `FlashGate` ← `Juice.flash` / `rewrite_punch`; chamber skips margin heartbeat when reduce-flash; reduce-motion short-circuits slam | Toggle reduce flash; trigger checkpoint — full-screen flash peak ≤ 0.25, desaturated |
| **Remap** | Settings → Input rebind | `ActionRemap` ↔ `InputMap` (keyboard); **gamepad events preserved** | Rebind Undo to `U`; confirm chamber + Steam Deck / Xbox pad still undo on X |
| **Subtitles** | Settings → Subtitles + size | `SubtitleOverlay` lines on rewrite / PA / win / assist | Enable subtitles; cross checkpoint — line appears; size large readable at 1280×800 |
| **UI scale** | Settings → UI scale (0.85–1.5) | `AccessibilityService.apply_ui_scale()` → `Window.content_scale_factor` | Set 1.25 on Deck-like 1280×800; HUD / settings still fully reachable |

Additional assists (same Settings surface):

- Screen shake on/off + intensity (forced off under reduce motion)
- Hold to walk (key/stick hold repeats steps)
- Ghost path once per chamber (`G` / gamepad B when assist enabled)

---

## Xbox ACR–oriented matrix

Map to common ACR topic areas (not a substitute for the official questionnaire — use this as the pre-submit QA sheet).

| ACR theme | Echo Lattice response | Status |
|---|---|---|
| **Configurable controls** | Full keyboard remap; Xbox/Steam Deck defaults kept (D-pad + left stick, A confirm, B/Start pause, X undo, Y restart, LB ghost assist) | ✅ |
| **UI / text scale** | `ui_scale` 0.85–1.5 via content scale factor | ✅ |
| **Subtitles / captions** | System/PA/rewrite stubs with size + background; audio is never the sole channel | ✅ |
| **Colorblind support** | 6 modes (default Field Ledger, protan, deutan, tritan, high contrast, mono+patterns) + non-color pattern channel | ✅ |
| **Photosensitivity** | Reduce flash + reduce motion; rewrite heartbeat suppressible; slam can commit without long strobe | ✅ |
| **Motion sensitivity** | Reduce motion disables shake/hitstop slam pacing; screen shake toggle | ✅ |
| **Difficulty / assists** | Optional ghost path once; hold-to-walk; undo always available | ✅ |
| **Gamepad navigation** | Focused buttons on menu/settings; gamepad bindings on all core actions | ✅ |
| **No sole reliance on color** | Pattern cues for fossils / echo walls / assist path | ✅ (default patterns on) |
| **Save accessibility choices** | Persisted independently of campaign save | ✅ |
| **Screen narration / TTS** | Not required for this puzzle vignette; UI is text-first | N/A (document as out of scope for v1) |
| **Online multiplayer a11y** | Single-player only | N/A |

---

## Steam Deck checklist

Test on Deck OLED/LCD (or 1280×800 window at 100% / 125% scale):

- [ ] Boot → Menu: brand + primary actions readable at default and **UI scale 1.25**
- [ ] **Settings / Accessibility** reachable with trackpads + A; Close / Esc returns focus
- [ ] Left stick + D-pad move one tile per press/axis tick; hold-to-walk optional
- [ ] Start/B opens menu; Y restart; X undo; LB ghost assist (when enabled)
- [ ] Colorblind Protanopia + patterns: echo walls distinct from ink walls
- [ ] Reduce flash + reduce motion during a multi-checkpoint chamber — no white strobe
- [ ] Subtitles large: rewrite line clears above bottom deck bezel
- [ ] Performance: gl_compatibility renderer; no hitch from subtitle / settings overlay

---

## Autoloads (`project.godot`)

```ini
SettingsStore="*res://scripts/a11y/settings_store.gd"
AccessibilityService="*res://scripts/a11y/accessibility_service.gd"
ActionRemap="*res://scripts/a11y/action_remap.gd"
```

Scenes:

- `res://scenes/ui/settings_menu.tscn` — Menu + in-chamber Settings
- `res://scenes/ui/subtitle_overlay.tscn` — instanced by `main.gd`

---

## Automated checks

```bash
python3 game/echo_lattice/tests/test_a11y_settings.py
# With Godot 4.3+:
# godot --headless --path game/echo_lattice -- --selftest
```

Self-test asserts colorblind role colors change, FlashGate caps intensity, UI scale sticks, subtitle overlay exists, and ActionRemap exposes `ghost_assist` / undo labels.

---

## Sign-off

| Owner | Item | Date | Initials |
|---|---|---|---|
| Design | Colorblind modes playtested (protan/deutan/tritan) | | |
| Engineering | FlashGate + Juice path verified in shipping build | | |
| Engineering | Remap persistence across restart | | |
| QA | Steam Deck 1280×800 pass | | |
| QA | Xbox ACR questionnaire draft filled from this matrix | | |
| Release | Store page accessibility notes updated | | |
