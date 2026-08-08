# Echo Lattice — Accessibility & Settings Completeness

Ship-blocking settings surface for Game 1 (**Echo Lattice**): path fossils must stay readable under color vision deficiency, rewrite juice must not strobe, input must remappable, and difficulty assists stay optional.

## Settings checklist

| Setting | Default | Where | Runtime hook |
|---|---|---|---|
| Path fossil palette (default / protanopia / deuteranopia / tritanopia / high contrast / mono+patterns) | `default` | Settings → Accessibility | `FossilPalette` + `AccessibilityService.fossil_style()` |
| Fossil pattern cues (second channel) | on | Settings → Accessibility | `fossil_use_patterns` |
| Reduce flash | off | Settings → Accessibility | `FlashGate.request_flash()` |
| Screen shake toggle | on | Settings → Accessibility | `ScreenShake` |
| Screen shake intensity | 100% | Settings → Accessibility | `screen_shake_intensity` |
| Reduce motion | off | Settings → Accessibility | disables shake; softens flashes |
| Subtitles (system stubs) | on | Settings → Accessibility | `SubtitleOverlay` / `subtitle_stub.gd` |
| Subtitle size | medium | Settings → Accessibility | `subtitle_size` |
| Show ghost path once (assist) | off | Settings → Accessibility | `GhostPathAssist.try_reveal()` |
| Hold to walk | off | Settings → Accessibility | movement controller (consume flag) |
| Remappable input | WASD / arrows / E / Z / Esc / G | Settings → Input | `ActionRemap` |

Persistence: `user://echo_lattice_settings.json` via `SettingsStore` (defaults in `game/echo_lattice/config/default_settings.json`).

## Autoload registration

Assume Godot project root is `game/` (scripts at `res://echo_lattice/...`). In `project.godot`:

```ini
[autoload]

SettingsStore="*res://echo_lattice/autoload/settings_store.gd"
AccessibilityService="*res://echo_lattice/autoload/accessibility_service.gd"
ActionRemap="*res://echo_lattice/input/action_remap.gd"
```

Scenes to instance from UI / gameplay roots:

- `res://echo_lattice/ui/settings_menu.tscn`
- `res://echo_lattice/ui/subtitle_overlay.tscn`

## Integration notes for core / juice agents

1. **Path fossils** — never hardcode cyan/red. Ask `AccessibilityService.fossil_style(FossilPalette.FossilRole.*)` for `{color, pattern}`.
2. **Checkpoint rewrite flash** — call `FlashGate.request_rewrite_flash()`; do not paint full-screen white directly.
3. **Camera trauma** — use `ScreenShake.bump()`; honor suppressed signal when shake is off.
4. **Ghost assist** — per chamber: `assist.begin_chamber(id)`; on `ghost_assist` action, `assist.try_reveal(path_cells)` once.
5. **Subtitles** — MVP has no dialogue; stub IDs cover rewrite / habit / checkpoint lines for future VO or localization.

## Acceptance

- [x] Colorblind options for path fossils (6 palettes + optional patterns)
- [x] Reduce flash gate
- [x] Remappable input with conflict steal + reset
- [x] Subtitle stubs + overlay
- [x] Difficulty assist: show ghost path once per chamber
- [x] Screen shake toggle (+ intensity, reduce-motion override)
