# Echo Lattice — VISUAL v2

**Branch:** `cursor/echo-lattice-art-v2`  
**Authority:** [`05_ART_BIBLE.md`](05_ART_BIBLE.md) + [`art/palette/echo_lattice.palette.json`](../../game/echo_lattice/art/palette/echo_lattice.palette.json)

## What changed

The playable slice shipped as **flat purple boxes on a near-black void**. VISUAL v2 replaces that look with the locked art bible:

| Before (v1 slice) | After (VISUAL v2) |
|---|---|
| `#0c0c11` void + `#3b3b52` purple walls | `paper_bone` ledger + `ink_black` walls |
| Solid neon-orange echo squares | Fossilized rust walls with seam decals |
| Instant echo flash | 12-beat origami slam (crease → lift → slot → rust bleed) |
| Dark glass menu | Index-card on lightbox — Steam-hit title lockup |

## Pillars enforced in code

1. **Legibility** — chamber still reads as a diagram; ghost path is a dashed chalk line.
2. **Ink on paper** — viewport clear color, page margin, print grain, ledger grid.
3. **Fossilization** — rewrite never blooms; walls harden with `rust_fossil` / `rust_deep`.
4. **One habit accent** — rust colonization on over-walked floors only.
5. **Cartographer honesty** — seed header + punch-card ribbon on the title card.

## Rewrite slam (the trailer beat)

Timed in `Chamber._draw_rewrite_slam()` against `REWRITE_DURATION = 0.90s`:

1. **Heartbeat** — single-frame `cadmium_warn` on the paper margin only.
2. **Creases** — `wall_folding_32` + diagonal ink folds, staggered per cell.
3. **Lift** — cast shadow (no rim light), paper rises.
4. **Slot** — fossil wall lands with a 1 px overshoot bounce.
5. **Rust bleed** — decals fade in from the joins.

Screenshot mode `rewrite:N` freezes the slam at **t = 0.55** (lift/slot) via `freeze_rewrite_at()`.

## Key files

- `game/echo_lattice/scripts/palette.gd` — swatch autoload
- `game/echo_lattice/scripts/art_kit.gd` — headless-safe PNG loader + grain/grid/dash helpers
- `game/echo_lattice/scripts/chamber.gd` — materials + slam
- `game/echo_lattice/scripts/menu.gd` — Steam-hit title card
- `game/echo_lattice/art/**` — palette, tiles, decals, UI (from art bible PR)

## Regenerate screenshots

```bash
GODOT=/path/to/Godot_v4.3-stable_linux.x86_64 \
  ./game/echo_lattice/tools/capture_tour.sh
```

Outputs land in `docs/ECHO_LATTICE/screenshots/tour/`.
