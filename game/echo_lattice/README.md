# The Weaver (hosted on Echo Lattice)

**Product launch path.** Godot 4.3 project that reuses the Echo Lattice shell (menu, fonts, audio bus, save, Steam stubs) and runs the Weaver gather→combine→weave loop as the primary experience.

Design: [`docs/WEAVER/MASTER_GDD.md`](../../docs/WEAVER/MASTER_GDD.md) · build contract: [`docs/WEAVER/BUILD_ON_LATTICE.md`](../../docs/WEAVER/BUILD_ON_LATTICE.md).

Standalone spike twin (temporary): [`../weaver/`](../weaver/).

## Run

1. Install [Godot 4.3](https://godotengine.org/download/archive/4.3-stable/) (GDScript).
2. Open / import `game/echo_lattice/project.godot`.
3. Press **F5**. Boot → **THE WEAVER** menu → **Enter the Yard**.

```bash
godot --path game/echo_lattice
godot --path game/echo_lattice -- --weaver-selftest
python3 game/echo_lattice/tests/test_weaver_on_lattice.py
```

## Loop (East Post Gap)

1. **Gather** — walk into Anchor / Span Fragments (E).
2. **Combine** — press **C**, pick two Fragments → Brace Thread.
3. **Weave** — stand in the void gap, press **Space** → Span Structure seats.
4. **Emit** — Structure sheds Fragments; Esc returns to menu.

**Archive:** menu **Archive · Chambers** (and Continue / Daily / Hard / Museum) still opens Echo Lattice chambers — not deleted.

## Layout (Weaver additions)

```
game/echo_lattice/
  project.godot          # config/name = The Weaver
  content/weaver/        # recipes, fragments, palette
  scenes/weaver/         # field, fragment, player, structure, ui/
  scripts/weaver/        # loom, juice, field controllers
  tests/test_weaver_on_lattice.py
  # … existing Lattice chambers, menu, audio, steam stubs …
```

## Non-goals

- No Steam AppID invention.
- No `git mv` archive of this tree until migrate gates in `docs/WEAVER/33_MIGRATE_FROM_LATTICE.md`.
- No deletion of chamber history.
