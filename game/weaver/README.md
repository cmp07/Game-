# The Weaver — Godot prototype (W1)

Offline craft vignette for **The Weaver** (north-star product after Echo Lattice freeze).

Design authority: [`docs/WEAVER/MASTER_GDD.md`](../../docs/WEAVER/MASTER_GDD.md) · [`docs/WEAVER/17_MVP.md`](../../docs/WEAVER/17_MVP.md) · [`docs/WEAVER/32_FIRST_FIVE.md`](../../docs/WEAVER/32_FIRST_FIVE.md) · [`docs/WEAVER/35_JUICE.md`](../../docs/WEAVER/35_JUICE.md).

**Echo Lattice is untouched.** This project lives beside `game/echo_lattice/` and must not replace it.

## Stack

| Lock | Choice |
|---|---|
| Engine | **Godot 4.3** (GL Compatibility) |
| Language | **GDScript** |
| Network | None — offline stub |
| Sim | 2D placeholder (void gap → collect → combine → weave) |

## Open / run

1. Install [Godot 4.3](https://godotengine.org/download/archive/4.3-stable/) (standard / GDScript).
2. Open Godot → **Import** → select `game/weaver/project.godot`.
3. Press **F5**. Default main scene: `scenes/main.tscn` (prototype loop).

Juice feel demo: open / set main to `scenes/demo_field.tscn`.

```bash
godot --path game/weaver
godot --path game/weaver --quit-after 1
python3 game/weaver/tests/test_weaver_juice.py
python3 game/weaver/tests/test_prototype_loop.py
```

## Playable surfaces

### Juice spike (`scenes/demo_field.tscn`)

| Verb | Feel | Keys |
|---|---|---|
| Recover | Fragment suck — chalk/fiber into hand | **E** |
| Bind | Combine flash — local paper press | **F** |
| Tension | Weave pulse — copper crest on Thread | **Q** |
| Reset | — | **R** |

Authority: [`docs/WEAVER/35_JUICE.md`](../../docs/WEAVER/35_JUICE.md).

### Prototype loop (`scenes/main.tscn`)

1. **Void** — frayed gap in the Shed Yard field (physical missing span, not cosmic purple).
2. **Recover** — walk into Fragments (Span / Anchor / …) to collect them.
3. **Bind** — combine two Fragments into a **Brace Thread** (combine panel / **C**).
4. **Tension / weave** — seat a placeholder **Span Structure** across the gap (**Space**).

Controls (loop): **WASD** move · **E** collect · **C** combine · **Space** weave · **Esc** title.

Screenshots: [`docs/WEAVER/screenshots/`](../../docs/WEAVER/screenshots/).

## Layout

```
game/weaver/
  project.godot
  README.md
  content/           # fragments, recipes, palette
  scenes/            # main, field, demo_field, player, fragment, structure, ui/
  scripts/
    juice/           # WeaverJuice + palette
    loom/            # session state
    field/           # demo field controller
  tests/             # python smoke (juice + loop)
```

## Non-goals

- No Steam AppID, no online, no trade, no Echo Lattice renames or deletes.
- No full soft-body / verlet loom — placeholder Structure seat + juice punctuation.
- Art is procedural / palette-driven for legibility; identity follows workshop / fiber language from `09_VISUAL.md` + `25_VOID_ART_V2.md`.
