# Echo Lattice — art assets

Working directory for Echo Lattice art. **The art bible is the source of truth.**

- **Read first:** [`docs/ECHO_LATTICE/05_ART_BIBLE.md`](../../../docs/ECHO_LATTICE/05_ART_BIBLE.md)
- **Palette (single source of truth):** [`palette/echo_lattice.palette.json`](palette/echo_lattice.palette.json)
- **Palette preview:** [`palette/palette_strip.png`](palette/palette_strip.png)

## Layout

```
art/
├── palette/       ← palette JSON + preview strip
├── tiles/         ← 32 px reference tiles (floors, walls, door, key, player stamp)
├── decals/        ← rust decals, chalk footprint
├── ui/            ← HUD elements (seed header, punch-card cells)
├── keyart/        ← capsule / marketing placeholders
└── generate_placeholders.py  ← reproducible placeholder generator
```

## Regenerating placeholders

The PNGs in this tree are **placeholders**, generated deterministically from
`palette/echo_lattice.palette.json`. Do not hand-edit them; edit the palette
or the generator and re-run:

```bash
python3 -m pip install --user Pillow
python3 game/echo_lattice/art/generate_placeholders.py
```

Final production art should replace these files in place, keeping the same
paths and sizes so wiring in `game/` does not have to move.

## Non-negotiables (see §2 and §8 of the art bible)

- **No** pure `#000000` or pure `#FFFFFF` in production art.
- **No** neon purple / cyan / magenta. **No** rainbow gradients. **No** bloom.
- Base substrate is warm printed paper. Ink is deep sepia black.
- The habit accent is rust; it never appears on unwalked tiles.
- Every visual element carries information — see pillar 5 in the bible.
