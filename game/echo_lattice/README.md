# game/echo_lattice

Echo Lattice — a small deterministic puzzle where you route pulses across a lattice of glyphs and rewrite them. **Not yet wired to a Godot project.** This folder ships the content, the schema, and the reference loaders so a Godot 4 project can consume them.

## Where things live

```
game/echo_lattice/
├── README.md                    (this file)
├── content/
│   ├── chambers/                Authored chambers, one JSON per lesson
│   ├── grammar/                 Variation grammar + rewrite vocabulary
│   ├── schema/                  JSON Schema for chambers (draft-07)
│   └── tres/                    Godot 4 .tres mirrors (mechanical, do not hand-edit)
├── scripts/
│   ├── chamber.gd               Chamber Resource (Godot 4)
│   ├── chamber_loader.gd        JSON -> Chamber loader
│   └── variation_grammar.gd     Applies a variation sequence to a base chamber
└── tests/
    ├── validate_chambers.py     Reference validator (runs in CI, no Godot needed)
    ├── test_validator.py        Negative-tests for the validator
    └── generate_tres.py         Regenerates content/tres/ from content/chambers/
```

## Authoring workflow

Everything about how to author a chamber, and every field it accepts, is in [`docs/ECHO_LATTICE/04_CONTENT_BIBLE.md`](../../docs/ECHO_LATTICE/04_CONTENT_BIBLE.md). Read that before editing chambers.

Short version:

1. Copy the nearest existing chamber JSON as a template.
2. Draw the lattice as ASCII. 5×5 or 6×6 is almost always enough for one lesson.
3. Run the validator:
   ```bash
   python3 game/echo_lattice/tests/validate_chambers.py
   python3 game/echo_lattice/tests/test_validator.py
   ```
4. Regenerate the .tres mirrors if you touched a chamber:
   ```bash
   python3 game/echo_lattice/tests/generate_tres.py
   ```
5. Open a PR.

## What ships in v1

Ten authored chambers. The tutorial teaches emission; the capstone composes several primitives.

| # | Slug | Teaches |
|---|---|---|
| 00 | `first_echo` | emit |
| 01 | `plain_rewrite` | rewrite |
| 02 | `turn` | turn |
| 03 | `fork` | fork |
| 04 | `merge` | merge |
| 05 | `filter` | filter |
| 06 | `delay` | delay |
| 07 | `silence` | silence |
| 08 | `resonance` | resonance |
| 09 | `bloom` | composition (capstone) |

Any variation on top of those is generated at runtime via the variation grammar in `content/grammar/variations.json` — variations do **not** ship as extra JSON files.

## Once a Godot project exists

The GDScript files under `scripts/` are usable as-is. To wire them up:

1. Create `project.godot` at the repo root or under `game/`.
2. Ensure `res://game/echo_lattice/scripts/chamber.gd` resolves — the `.tres` files reference this path.
3. Load a chamber:
   ```gdscript
   var chamber := ChamberLoader.load_from_path("res://game/echo_lattice/content/chambers/00_first_echo.json")
   ```
4. Or scan the whole roster:
   ```gdscript
   var chambers := ChamberLoader.load_all()
   ```
5. Apply a variation:
   ```gdscript
   var variant := VariationGrammar.apply(chamber, [{"reflect": "vertical"}, {"palette": "cool"}])
   ```
