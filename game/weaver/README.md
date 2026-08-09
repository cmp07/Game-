# The Weaver — Godot MVP stub

Offline craft vignette scaffold for **The Weaver** (north-star product after Echo Lattice freeze).

Design authority: [`docs/WEAVER/17_MVP.md`](../../docs/WEAVER/17_MVP.md) · [`docs/WEAVER/MASTER_GDD.md`](../../docs/WEAVER/MASTER_GDD.md) · [`docs/WEAVER/14_TECH.md`](../../docs/WEAVER/14_TECH.md).

**Echo Lattice is untouched.** This project lives beside `game/echo_lattice/` and must not replace it.

## Stack

| Lock | Choice |
|---|---|
| Engine | **Godot 4.3** (GL Compatibility) |
| Language | **GDScript** (matches repo + TECH: GDScript first; C# only if a hire already lives there) |
| Network | None — offline stub |
| Sim | 2D placeholder (void gap → collect → combine → weave) |

## Open / run

1. Install [Godot 4.3](https://godotengine.org/download/archive/4.3-stable/) (standard build; GDScript — not .NET required).
2. Open Godot → **Import** → select `game/weaver/project.godot`.
3. Press **F5** (or Play). Main scene: `scenes/main.tscn`.

Headless smoke (optional, if `godot` is on `PATH`):

```bash
godot --path game/weaver --quit-after 1
```

## Playable stub loop

Teaching field proves the vertical-slice verbs without full physics:

1. **Void** — frayed gap in the Shed Yard field (physical missing span, not cosmic purple).
2. **Recover** — walk into Fragments (Span / Anchor / Channel / Charge) to collect them.
3. **Bind** — press **C** with two Fragments to spin one **Brace Thread**.
4. **Tension / weave** — stand in the void zone, press **Space** to seat a placeholder **Span Structure** across the gap.

Controls: **WASD** move · **E** collect · **C** combine · **Space** weave · **Esc** title.

## Layout

```
game/weaver/
  project.godot
  README.md
  icon.svg
  content/           # authored fragment data (JSON seed)
  scenes/            # main, field, player, fragment, structure
  scripts/
    loom/            # session state (combine → thread → seat)
```

## Non-goals (this PR)

- No Steam AppID, no online, no trade, no Echo Lattice renames.
- No full soft-body / verlet loom — placeholder Structure seat only.
- Art is procedural polygons for legibility; visual identity follows workshop / fiber language from `09_VISUAL.md`.
