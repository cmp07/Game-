# The Weaver (hosted on Echo Lattice)

**Product launch path.** Godot 4.3 project that reuses the Echo Lattice shell (fonts, audio bus, save, Steam stubs) and boots into a playable **VOID** first minutes — then keeps East Post Gap / chambers as archive tools.

Design: [`docs/WEAVER/MASTER_GDD.md`](../../docs/WEAVER/MASTER_GDD.md) · build contract: [`docs/WEAVER/BUILD_ON_LATTICE.md`](../../docs/WEAVER/BUILD_ON_LATTICE.md).

Standalone spike twin (temporary): [`../weaver/`](../weaver/).

## Run

1. Install [Godot 4.3](https://godotengine.org/download/archive/4.3-stable/) (GDScript).
2. Open / import `game/echo_lattice/project.godot`.
3. Press **F5**. Boot stamp → **VOID** (one drifting spark). No Yard Folio required.

```bash
godot --path game/echo_lattice
godot --path game/echo_lattice -- --void-boot-selftest
godot --path game/echo_lattice -- --weaver-selftest
python3 game/echo_lattice/tests/test_weaver_on_lattice.py
```

## First minutes (VOID)

1. **Boot** — cold stamp, then full-window void (no East Post Gap shed).
2. **Move** — **WASD** / arrows.
3. **Spark** — one kiln mote drifts in the drop.
4. **Speak** — type a word, **Enter**. The void answers (surface / lamp / chalk).
5. **Esc** — minimal **Begin** gate (restart the void). Not a folio menu.

## Archive loops

- **East Post Gap** (gather → combine → weave): still under `scenes/weaver/field.tscn`; used by `--weaver-selftest` / photo tools.
- **Chambers**: Folio / Archive routes remain in the Lattice shell when opened explicitly.

## Layout (Weaver additions)

```
game/echo_lattice/
  project.godot          # config/name = The Weaver
  content/weaver/        # recipes, fragments, palette
  scenes/weaver/         # void_boot (primary), field (archive), fragment, player, …
  scripts/weaver/        # void_boot, void_art, spark, loom, juice, …
  tests/test_weaver_on_lattice.py
```

## Non-goals

- No Steam AppID invention.
- No `git mv` archive of this tree until migrate gates in `docs/WEAVER/33_MIGRATE_FROM_LATTICE.md`.
- No deletion of chamber history.
