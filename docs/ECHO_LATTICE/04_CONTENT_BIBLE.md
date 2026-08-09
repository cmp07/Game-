# Echo Lattice — Content Bible (v2)

> **Doc contract:** this file is the single source of truth for chamber authoring against the **playable PR #48 chamber format** (24×14 ASCII maze, checkpoint rewrites, habit fossilization). If code and this doc disagree, this doc is right and the code is a bug.

- **Repo path for content:** `game/echo_lattice/content/`
- **Repo path for scripts:** `game/echo_lattice/scripts/`
- **Repo path for tests:** `game/echo_lattice/tests/`
- **JSON Schema (draft-07):** `game/echo_lattice/content/schema/chamber.schema.json`
- **Playable authority:** [`cursor/echo-lattice-playable`](https://github.com/cmp07/Game-/pull/48) — `ChamberBook` / `chamber.gd` transforms

**Supersedes:** the glyph/echo-propagation content bible from the earlier content PR. That rewrite language (emit / fork / merge) is archived design history; shipping content is the movement-fossilization maze.

---

## 1. Design in one page

The player walks a **24×14** grid. A ghost trail records every cell since the last checkpoint. Entering a **checkpoint** (`C`) commits a **transform** of that trail into orange **echo walls**. Reach the green **goal** (`G`) to clear the chamber.

Every chamber teaches **one rewrite idea**, then remixes it. Each Act ends with a boss **identity** chamber — a puzzle whose intended solve leaves a legible “portrait” of how you moved.

```
P  player start (floor)
G  goal
C  checkpoint (fires transform once)
#  authored wall
.  floor
```

Transforms (forced per chamber in v2):

| Transform | Effect on walked path |
|---|---|
| `none` | Tutorial — no rewrite |
| `mirror_v` | Mirror across vertical axis |
| `mirror_h` | Mirror across horizontal axis |
| `rotate_180` | Rotate 180° around chamber centre |
| `thicken` | Solidify the walked cells in place |
| `mirror_v_then_h` | Emit both vertical and horizontal mirrors |

A **solvability safety net** (BFS) drops any echo wall that would disconnect the player from the goal. Authors still must keep base layouts and intended paths fair — the net is a last resort, not a design crutch.

---

## 2. Four Acts

| Act | Id | Lesson arc | Rewrite cap | Chambers (campaign) |
|---|---|---|---|---|
| **I — Induction** | `induction` | Move → first mirror → thicken intro | 1 | Quiet Span … **Who Walked** |
| **II — Reflection** | `reflection` | See yourself on both axes | 2 | Twin Rail … **Portrait** |
| **III — Pressure** | `pressure` | Habits hurt; multi-commit nets | 3 | Cement Trail … **Calcify** |
| **IV — Mastery** | `mastery` | Compose transforms; sign identity | 3 | Conductor's Cut … **Nameplate** + Open Lattice |

Campaign order lives in `content/acts.json`. Hard variants are listed separately and do not block campaign progression.

### Boss identity chambers

| Act | Slug | Transform | Identity tag |
|---|---|---|---|
| Induction | `identity_induction` / Who Walked | `mirror_v` | `induction_signature` |
| Reflection | `identity_reflection` / Portrait | `mirror_v_then_h` | `reflection_portrait` |
| Pressure | `identity_pressure` / Calcify | `thicken` | `pressure_calcify` |
| Mastery | `nameplate` / Nameplate | `mirror_v_then_h` | `mastery_nameplate` |

Identity chambers should be solvable under the nearest-checkpoint auto-solver, but the *intended* human solve leaves a readable echo signature (loop, bar-code, face, negative space).

---

## 3. Chamber file format

**Filename:** `NN_slug.json` (zero-padded index, snake_case slug).

### Required fields

```jsonc
{
  "id": "02_mirror_birth",
  "index": 2,
  "slug": "mirror_birth",
  "title": "Mirror Birth",
  "caption": "Cross the checkpoint. Your path becomes wall.",
  "act": "induction",
  "act_index": 0,
  "act_title": "Induction",
  "teaches": "mirror_v",
  "transform": "mirror_v",
  "difficulty": 1,
  "role": "lesson",          // lesson | remix | boss | hard | daily_showcase
  "seed": 11003,
  "daily_eligible": false,
  "par_moves": 40,
  "tempo_start": 9999,
  "lattice": {
    "rows": 14,
    "cols": 24,
    "cells": [ "########################", "... 14 rows ..." ]
  },
  "map": [ "...same as lattice.cells..." ],
  "motifs": [
    { "id": "M1", "kind": "CHECKPOINT", "cell": [11, 6], "unique": true,
      "operator": "mirror_v", "banner": "..." }
  ],
  "resonance": { "kind": "REACH_GOAL" },
  "rewrite": {
    "cap": 1,
    "forced_op": "mirror_v",
    "soft_hard_bias": 0.25,
    "require_shorter_or_equal": false
  },
  "hints": ["The orange walls are a mirror of where you walked."],
  "variations": {
    "allow_rotate": false,
    "allow_reflect": false,
    "allow_palette_swap": true,
    "budget_deltas": [0],
    "hard_mode": { "tempo_delta": -4, "par_moves_mult": 0.85 }
  },
  "unlocks": [],
  "tags": ["induction", "mirror_v", "lesson"]
}
```

### Optional fields

| Field | Purpose |
|---|---|
| `identity` | Boss identity tag string |
| `hard_variant_of` | Slug of the lesson this hard remix tightens |
| `subtitle` / `intro` / `outro` | Flavor (UI may ignore in slice) |

### Constraints

- `lattice.rows == 14`, `lattice.cols == 24`; each cell row length ≤ 24 (short rows pad as floor — open right edge, PR #48 style).
- Exactly one `P`, exactly one `G`.
- If `transform != "none"`, at least one `C`.
- `P` must reach `G` and every `C` on the base layout (BFS).
- Auto-solver playthrough (nearest checkpoint → rewrite → goal) must clear the chamber with the safety-net rewrite semantics.
- `id` matches filename stem; `index` matches campaign/hard ordering in `acts.json`.

---

## 4. Roles & pedagogy

| Role | Count target | Rules |
|---|---|---|
| `lesson` | ~1 per new transform per Act | Teach one idea; generous floor |
| `remix` | majority | Recombine the idea; denser geometry |
| `boss` | 1 per Act | Identity portrait; `teaches: identity` |
| `hard` | 4+ | Marked `hard_variant_of`; daily-eligible |
| `daily_showcase` | ≥1 | Epilogue / friend-seed poster chamber |

**Teach-then-remix rule:** the first chamber that introduces a transform in an Act is `role: lesson`. Later chambers with the same transform in that Act are `remix` (or `boss` / `hard`).

---

## 5. Hard variants + daily seeds

### Hard variants

Shipped as full chamber JSON (not runtime-only). They tighten floor area / checkpoint count while preserving the parent lesson’s transform. Listed under each Act’s `hard_variants` in `acts.json`.

### Daily seeds

`content/daily/seeds.json` is a catalog of `{ seed, chamber_id, variation, friend_code }`.

Runtime pick:

```
idx = fnv1a32("YYYY-MM-DD") % len(seeds)
```

Same UTC date → same chamber + variation for every player (friend-code comparable). Variation axes (`rotate`, `reflect`, `palette`, `hard`) respect each chamber’s `variations.allow_*` gates.

Grammar file: `content/grammar/variations.json`.

---

## 6. Loader contract

1. Enumerate `res://content/chambers/*.json` (sorted by `index`).
2. Parse JSON → validate against schema + semantic rules (§3).
3. Fail closed: skip invalid files; never silently mutate.
4. Expose the PR #48 shape to the playable router:

```
{ id, title, caption, transform, map }
```

`ChamberBook` is a thin façade over the loader so existing scenes keep working. Authoring source of truth is JSON; the old inline `CHAMBERS` array is removed.

Python reference validator:

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/author_chambers_v2.py   # regenerate + playthrough
```

Godot self-test (when Godot 4.3 is available):

```bash
cd game/echo_lattice && godot --headless --path . -- --selftest
```

---

## 7. Authoring workflow

1. Prefer editing `tests/author_chambers_v2.py` (roster + map overrides), then regenerate.
2. Or hand-edit a JSON file and run the validator.
3. Draw on 24×14. Keep one lesson per chamber.
4. Place checkpoints on the natural path so nearest-checkpoint auto-solve stays honest.
5. Run validators before PR.

---

## 8. Roster (v2)

**39 authored chambers** — 35 campaign + 4 hard variants.

| # | Slug | Act | Transform | Role |
|---|---|---|---|---|
| 00 | quiet_span | Induction | none | lesson |
| 01 | echo_plate | Induction | none | lesson |
| 02 | mirror_birth | Induction | mirror_v | lesson |
| 03 | break_the_loop | Induction | mirror_v | remix |
| 04 | ceiling_first | Induction | mirror_h | lesson |
| 05 | two_glances | Induction | mirror_v | remix |
| 06 | far_side | Induction | rotate_180 | lesson |
| 07 | first_thicken | Induction | thicken | lesson |
| 08 | identity_induction | Induction | mirror_v | boss |
| 09–16 | … | Reflection | mix | lesson/remix |
| 17 | identity_reflection | Reflection | mirror_v_then_h | boss |
| 18–25 | … | Pressure | mix | lesson/remix |
| 26 | identity_pressure | Pressure | thicken | boss |
| 27–33 | … | Mastery | mix | lesson/remix |
| 34 | open_lattice | Mastery | mirror_v | daily_showcase |
| 35–38 | *_hard | mixed | parent | hard |

Full machine-readable index: `content/acts.json`.

---

## 9. Non-goals for content v2

- No procedural chamber generation (variations only).
- No glyph/echo-propagation puzzles (retired).
- No new transform ops beyond the six playable ones (invert remains a later unlock).
- No Steam Workshop editor in this PR.

---

## 10. Change log

| Date | Change |
|---|---|
| 2026-08-08 | v1 glyph bible + 10 echo chambers (superseded). |
| 2026-08-09 | **v2** — rebase on PR #48 playable format; 4 Acts; 39 chambers; hard variants; daily seeds; JSON loader. |
