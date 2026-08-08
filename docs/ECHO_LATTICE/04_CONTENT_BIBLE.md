# Echo Lattice — Content Bible

> **Doc contract:** this file is the single source of truth for chamber authoring. Anything the loader, validator, or renderer needs to know about the file format lives here. If code and this doc disagree, this doc is right and the code is a bug.

- **Repo path for content:** `game/echo_lattice/content/`
- **Repo path for scripts:** `game/echo_lattice/scripts/`
- **Repo path for tests:** `game/echo_lattice/tests/`
- **JSON Schema (draft-07):** `game/echo_lattice/content/schema/chamber.schema.json`

---

## 1. Design in one page

The Echo Lattice is a small 2D grid (typically **5×5** to **9×9**). Cells hold **glyphs**. **Sources** emit **echoes** on tick 0. Every tick, each live echo advances **one cardinal step**. When an echo lands on a cell, the cell's **rewrite** fires:

```
pattern  ->  replacement + emitted_directions
```

The chamber is solved when the **goal predicate** is satisfied within the **tick budget**. That's the whole engine.

Every chamber teaches **one rewrite idea**. Chambers are ordered as a lesson plan (see §7). The tutorial teaches emission + propagation; the capstone composes several primitives.

## 2. Rewrite grammar (the puzzle language)

A rewrite is one of five forms. Formal EBNF:

```
rewrite      = pattern "->" replacement
pattern      = glyph
             | glyph "+" glyph                (co-arrival at same cell, same tick)
             | glyph "@" phase                (echo of matching phase only)
replacement  = glyph
             | glyph "," directions           (emit new echoes)
             | "∅"                            (silence: consume echo, keep glyph)
directions   = direction ( "," direction )*
direction    = "N" | "S" | "E" | "W"
phase        = "+" | "-"
glyph        = single printable char, defined in the chamber's `legend`
```

### The five rewrite ideas

Every chamber teaches exactly one:

| # | Name | Form | English |
|---|------|------|---------|
| 1 | **Emit / propagate** | `. -> .` (implicit relay) | Empty cells relay echoes; sources emit. |
| 2 | **Plain rewrite** | `A -> B` | Echo turns `A` into `B` and dies. |
| 3 | **Fork** | `A -> B, N, E` | Echo turns `A` into `B` and emits new echoes in listed directions. |
| 4 | **Merge** | `A + A -> B` | Two echoes arriving in the same tick coalesce; single-echo hit is a no-op. |
| 5 | **Silence / cancel** | `A@+ + A@- -> ∅` | Opposite-phase echoes annihilate at a junction. |

### Phase, derived from direction

Phase is not stored separately. **The phase of an echo equals its arrival direction.** Two arrivals are "opposite phase" iff their directions are `(N, S)` or `(E, W)`. This is what `A@+` / `A@-` mean in the rewrites above.

This is a deliberate simplification: authoring never has to spell out phases per-source, and every phase-sensitive rewrite (filter, cancel) reads phase from the direction the echo already carries.

### Two derived ideas (compositions)

Not new grammar — pre-baked useful compositions, given their own tile art:

| Name | Composed as |
|------|-------------|
| **Filter** (guard) | `A@+ -> B, forward` and `A@- -> ∅` |
| **Delay** | Fork into a self-loop that returns after N ticks |
| **Resonance** | Merge with `count >= 2 within window` semantic sugar |

The grammar itself does not need special cases for these; they are macros the authoring layer expands. The validator accepts the sugar too so authors can write `delay:2` without hand-rolling a loop.

## 3. Glyph legend (canonical)

Each chamber declares a `legend` block, but the canonical glyphs below are shared unless overridden:

| Char | Name | Semantics |
|---|---|---|
| `.` | empty | Relay only. Echo passes through, cell unchanged. |
| `#` | wall | Absorbs echoes. Impassable. |
| `S` | source | Emits **one** echo at tick 0. Direction is chamber's `source_dir`. |
| `G` | goal | Must be "lit" (see `goal.predicate`) to win. |
| `o` | dark glyph | Rewrite target: `o -> O` when hit. |
| `O` | lit glyph | Terminal / satisfied state. |
| `>` `<` `^` `v` | routers | Fixed direction rewrites: echo leaves in indicated direction. |
| `+` | merge | `A + A -> B` node. Requires two echoes same tick. |
| `x` | cancel | Silence node: `A@+ + A@- -> ∅`. |
| `~` | delay | Holds an echo for `delay_ticks` (default 1). |
| `?` | filter | Only phase-matching echoes pass; others are consumed. |
| `*` | resonance | Lights only after N hits within `resonance_window` ticks. |

Custom glyphs are allowed via `legend` overrides — the validator only requires that every glyph on the grid has a `legend` entry OR is one of the canonical set above.

## 4. Chamber file format

**Filename convention:** `NN_slug.json`, zero-padded (`00_first_echo.json`, `01_plain_rewrite.json`, …). Slug is lowercase snake_case.

### Required fields

```jsonc
{
  "id": "00_first_echo",            // matches filename slug (without extension)
  "title": "First Echo",            // display name, one line
  "teaches": "emit",                // one of: emit | rewrite | turn | fork | merge |
                                    //         filter | delay | silence | resonance | composition
  "difficulty": 0,                  // 0 = tutorial, 1-5 = campaign
  "tick_budget": 8,                 // hard cap on ticks before failure
  "source_dir": "S",                // N | S | E | W (direction sources emit at tick 0)
  "lattice": {
    "rows": 5,
    "cols": 5,
    "cells": [
      "..S..",
      ".....",
      ".....",
      ".....",
      "..G.."
    ]
  },
  "legend": {                       // overrides / extensions to the canonical set
    ".": "empty",
    "S": "source",
    "G": "goal"
  },
  "goal": {
    "predicate": "reach",           // reach | light_all | pattern | count
    "cells": [[4, 2]]               // required for `reach` and `pattern`
  },
  "player_tools": {                 // inventory of tiles the player may place
    "router":   { "count": 0 },
    "fork":     { "count": 0 },
    "merge":    { "count": 0 },
    "filter":   { "count": 0 },
    "delay":    { "count": 0 },
    "cancel":   { "count": 0 },
    "resonate": { "count": 0 }
  },
  "hints": [                        // short strings, shown on stall
    "The echo travels one cell per tick."
  ],
  "variations": {                   // which axes may generate variants (see §5)
    "allow_rotate":       false,
    "allow_reflect":      false,
    "allow_palette_swap": true,
    "budget_deltas":      [0, 2]
  }
}
```

### Optional fields

| Field | Default | Purpose |
|---|---|---|
| `subtitle` | `""` | Small sub-line under `title` in the chamber select menu. |
| `intro` | `""` | One-paragraph flavor text shown once. |
| `outro` | `""` | Post-solve flavor text. |
| `music_cue` | `null` | String key into the audio bank. |
| `par_ticks` | `null` | Aspirational tick count for a "perfect" solve. |
| `par_tiles` | `null` | Aspirational tile count for a "perfect" solve. |
| `tags` | `[]` | Free-form tags for filtering (`"quiet"`, `"loud"`, `"symmetric"`). |

### Constraints checked by the validator

- `rows` and `cols` are `>=3` and `<=12`.
- `cells` has exactly `rows` entries, each of length exactly `cols`.
- Every character in `cells` has an entry in `legend` OR is a canonical glyph.
- At least one `S` (source) in `cells`. Multiple sources are allowed; **all sources fire on tick 0 in the direction given by `source_dir`**. Chambers that need per-source direction should use routers on the sources' neighbor cells rather than adding a per-source direction field (kept out of v1 to keep the file format simple).
- At least one `G` in `cells` when `goal.predicate` is `reach` or `light_all`.
- `tick_budget >= 1` and `tick_budget <= 999`.
- `teaches` matches the chamber's actual rewrites where possible (the validator can only weakly check this; the human review catches the rest).
- `variations.budget_deltas` values, applied, never push `tick_budget` below 1.
- `id` matches the filename stem.
- Tutorial chambers (`difficulty == 0`) MUST set `variations.allow_rotate = false`, so the tutorial's cardinal directions stay stable across variants.

## 5. Variation grammar

Variations are how one authored chamber becomes many playable chambers without hand-authoring each. The grammar is a small **context-free** production over a fixed alphabet of transformations.

Full grammar file: `game/echo_lattice/content/grammar/variations.json`.

```
variant       ::= base transforms
transforms    ::= ε | transform transforms
transform     ::= rotate | reflect | palette | budget_delta | swap_glyph
rotate        ::= 0 | 90 | 180 | 270
reflect       ::= none | horizontal | vertical | diagonal
palette       ::= default | cool | warm | mono
budget_delta  ::= -2 | -1 | 0 | 1 | 2
swap_glyph    ::= { "from": <glyph>, "to": <glyph> }   // must preserve semantics
```

### Composition rules

1. Transforms apply **left-to-right**. `rotate 90` then `reflect horizontal` is **not** the same chamber as reflect-then-rotate. The validator does not care; the runtime honors order.
2. `swap_glyph` must not change **semantics**: if you swap `o` for `◦`, the legend entry moves with it. The validator enforces that both source and destination glyph have the same `class` in the canonical set.
3. Per-chamber, `variations.allow_*` gates say which transforms are legal for that chamber. A chamber whose lesson depends on left-vs-right MUST set `allow_reflect: false`. The tutorial MUST NOT be rotated.

### Sample variants of `01_plain_rewrite`

```
base                                        # difficulty 1, 6 ticks
base rotate:90                              # difficulty 1, 6 ticks (Steam achievement: same solve, sideways)
base palette:cool                           # difficulty 1, 6 ticks
base rotate:90 palette:cool budget_delta:-1 # difficulty 2, 5 ticks
```

Variations are **runtime-generated**. They do not live as new JSON files in `chambers/`. Only authored ("base") chambers ship as files.

## 6. Rewrite vocabulary

The set of rewrite tiles a player can wield. Each has a canonical glyph, a per-chamber inventory count, and a rewrite it plants on the cell where it's placed.

Full vocabulary file: `game/echo_lattice/content/grammar/rewrite_vocabulary.json`.

| Tile | Glyph | Rewrite planted | Notes |
|---|---|---|---|
| Router | `> < ^ v` | `. -> ., <dir>` | Redirects echo. |
| Fork | `Y` | `. -> ., <dir1>, <dir2>` | Fixed left/right split. |
| Merge | `+` | `A + A -> B` | Requires two same-tick echoes. |
| Filter | `?` | `A@<phase> -> A, forward` | Blocks off-phase echoes. |
| Delay | `~` | `A -> A after 1` | Holds for one tick (extendable). |
| Cancel | `x` | `A@+ + A@- -> ∅` | Annihilation. |
| Resonate | `*` | `A -> B if hits>=2 within window` | Amplification. |

## 7. Chamber roster (v1)

Ten authored chambers. The tutorial is `00_`; the capstone is `09_`. Every chamber below exists as a real JSON file in `game/echo_lattice/content/chambers/`.

| # | Slug | Teaches | One-line hook |
|---|---|---|---|
| 00 | `first_echo` | **emit** | The first pulse. Watch it travel. |
| 01 | `plain_rewrite` | **rewrite** | Turn dark cells lit as the echo passes. |
| 02 | `turn` | **turn** | Corners route the echo 90°. |
| 03 | `fork` | **fork** | One echo becomes two. |
| 04 | `merge` | **merge** | Two arrivals unlock the gate — timing matters. |
| 05 | `filter` | **filter** | Phase-locked doors: only matching echoes pass. |
| 06 | `delay` | **delay** | Hold and release. Rendezvous the pulses. |
| 07 | `silence` | **silence** | Opposite echoes cancel. Route them into each other. |
| 08 | `resonance` | **resonance** | Two hits within a window light the target. |
| 09 | `bloom` | **composition** | Capstone: fork → filter → merge → light every goal. |

Each chamber has:

- A single teaching moment.
- A visual "aha".
- A hint string list to soften stalls.
- Explicit `allow_*` gates for what its variation grammar may do.

## 8. Loader contract

Any loader (GDScript, Python, TypeScript) MUST implement:

1. **Parse** the JSON file at path `P` into an in-memory `Chamber` object.
2. **Validate** against `chamber.schema.json` (structural) and against the semantic rules in §4 (semantic).
3. **Expose** a stable read-only API: `id`, `title`, `teaches`, `tick_budget`, `lattice.rows`, `lattice.cols`, `cell(row, col)`, `legend`, `goal`, `player_tools`.
4. **Refuse to load** a chamber that fails validation (fail closed — never silently mutate a bad chamber).

The Godot reference loader lives at `game/echo_lattice/scripts/chamber_loader.gd` and reads JSON into a strongly-typed `Chamber` `Resource` (`chamber.gd`). The Python reference validator lives at `game/echo_lattice/tests/validate_chambers.py` and is what CI runs.

## 9. Authoring workflow

1. Copy the nearest existing chamber file as a template.
2. Draw the lattice as ASCII. Keep it small — 5×5 or 6×6 is almost always enough for one lesson.
3. Fill `goal.predicate` and `goal.cells`.
4. Set `player_tools` to the **minimum** inventory that lets the intended solution work. If the puzzle has multiple valid solutions, that is fine and often good; if it has multiple *lessons*, split it into two chambers.
5. Run the validator locally:
   ```bash
   python3 game/echo_lattice/tests/validate_chambers.py
   ```
6. Only then, open a PR.

## 10. Non-goals for v1

- No **procedural** chamber generation (variations are the closest we get).
- No **story mode** wrapper.
- No **online leaderboards**.
- No **puzzle editor UI** in-game. Authoring is text files + PRs; that is fine for a $2.99 game.

## 11. Change log

| Date | Change |
|---|---|
| 2026-08-08 | Initial content bible + 10 authored chambers + variation grammar (this PR). |
