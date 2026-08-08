# Echo Lattice — Overview

> **Status:** design + content scaffold. Not yet wired to a Godot project.
> **Slot:** candidate small paid puzzle (fits the repo's small-Steam-desktop plan). Target price band **$2.99–$4.99**.
> **Genre lane:** single-screen deterministic puzzle. **Not a genre mashup** — see [`docs/GAME_PLAN.md`](../GAME_PLAN.md).

## Pitch

You route pulses ("echoes") across a lattice of glyphs. Every cell is a token; every rewrite is a rule that transforms the token when an echo touches it. You solve a chamber by rewriting the lattice into a target configuration inside a **tick budget**.

The whole game is **string rewriting on a 2D grid**, dressed as a small quiet toy.

## Docs in this folder

| File | Purpose |
|---|---|
| `00_OVERVIEW.md` | This file. Elevator pitch + doc map. |
| `04_CONTENT_BIBLE.md` | **Authoring spec.** Chamber schema, rewrite grammar, variation grammar, chamber-by-chamber lesson plan. |

Numbering leaves room for a full doc suite later (01 vision, 02 systems, 03 art, 05 audio, etc.) without renumbering the content bible.

## Content lives in

```
game/echo_lattice/content/
  chambers/     # Authored chambers (one JSON per chamber)
  grammar/      # Variation grammar + rewrite vocabulary
  schema/       # JSON Schema for validation
  tres/         # Godot 4 .tres exports (generated / hand-mirrored)
game/echo_lattice/scripts/
  chamber.gd            # Godot 4 Resource class for a Chamber
  chamber_loader.gd     # Loads a chamber JSON at runtime → Chamber
  variation_grammar.gd  # Applies a variation to a base chamber
game/echo_lattice/tests/
  validate_chambers.py  # CI-friendly schema + semantic validator
```

## Why chambers as data

Chambers are pure data (JSON) so:

- Non-programmers can author.
- Content is diffable in PRs (ASCII grids review clean).
- The same chamber can be validated in CI (Python), rendered in Godot (GDScript), and remixed by a **variation grammar** without engine coupling.

`.tres` files are a mechanical mirror of the JSON so Godot's editor can inspect chambers as first-class resources; the JSON is the source of truth.
