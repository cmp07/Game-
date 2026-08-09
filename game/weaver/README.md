# The Weaver — prototype loop (W1)

Extends the Godot **4.3** MVP scaffold with a playable **gather → combine → weave → emit** vertical.

Design authority:

- [`docs/WEAVER/32_FIRST_FIVE.md`](../../docs/WEAVER/32_FIRST_FIVE.md) — spike clocks
- [`docs/WEAVER/17_MVP.md`](../../docs/WEAVER/17_MVP.md) · [`02_CORE_LOOP.md`](../../docs/WEAVER/02_CORE_LOOP.md)

**Echo Lattice is untouched** under `game/echo_lattice/`.

## Loop

1. **Gather** — move in the East Post Gap void field; collect **Anchor** / **Span** (walk over or `E`)
2. **Combine** — press `C` for the combine UI; bind two Fragments into a **Brace Thread**
3. **Weave** — stand in the void, press `Space` to seat a **Span Structure**
4. **Emit** — standing Structure sheds Fragments on a timer (loop closes)

## Stack

| Lock | Choice |
|---|---|
| Engine | Godot 4.3 (GL Compatibility) |
| Language | GDScript |
| Sim fence | **2D** placeholder (no dual-stack 3D) |
| Network | None |

## Open / run

```bash
godot --path game/weaver
```

Or Godot → Import → `game/weaver/project.godot` → F5.

## Headless selftest

```bash
godot --headless --path game/weaver -- --selftest
```

## Screenshots

```bash
xvfb-run -a godot --path game/weaver -- --selftest --screenshot
# → docs/WEAVER/screenshots/01_void_field.png
# → docs/WEAVER/screenshots/02_structure_standing.png
```

## Python contracts

```bash
python3 game/weaver/tests/test_prototype_loop.py
```

## Controls

| Input | Action |
|---|---|
| WASD / arrows | Move |
| E / walk-over | Gather Fragment |
| C | Open combine UI |
| Space | Weave Structure (in void) |
| Esc | Close UI / return to title |

## Layout

```
game/weaver/
  project.godot
  content/recipes.json      # Anchor+Span → Brace → emit
  scenes/field.tscn         # void gap playfield
  scenes/ui/combine_panel.tscn
  scripts/loom/loom_state.gd
  tests/test_prototype_loop.py
```
