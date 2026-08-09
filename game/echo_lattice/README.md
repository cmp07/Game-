# Echo Lattice (Godot 4.3)

Playable vertical slice with **JUICE v2** wired into the chamber loop.

## Run

```bash
godot --path .
```

Headless self-test (juice units + 10-chamber auto-solver):

```bash
godot --headless --path . -- --selftest
```

## Controls

| Action | Keys |
|---|---|
| Move | WASD / arrows |
| Undo | Z |
| Restart chamber | R |
| Pause / menu | Esc |

## JUICE v2

Autoload `JuiceDirector` (`scripts/juice/`) owns:

- trauma² screen shake + flash
- hitstop-light (`Engine.time_scale` floor ≈ 0.06)
- critically-damped camera spring + zoom-punch
- pooled particles (dot / ring / glyph)
- three-phase telegraphs (wall-birth foreshadow + ambient lattice pulses)

Design / tuning: [`docs/ECHO_LATTICE/07_JUICE.md`](../../docs/ECHO_LATTICE/07_JUICE.md).
