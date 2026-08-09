# Title menu gameplay preview

Diegetic Field Ledger **film plate** media for the brand verso (under ECHO LATTICE).

## Runtime preference (Godot 4.3, offline)

1. **Live SubViewport** — silent scripted walk + rewrite slam on chamber 2 (`menu_gameplay_preview.gd` + `Chamber.menu_preview_mode`)
2. **`menu_preview.ogv`** — Theora loop via `VideoStreamPlayer` (muted)
3. **`frame_XX.png` strip** — animated fallback / reduce-motion still

## Regenerate fallback loop

From repo root (requires `ffmpeg`):

```bash
python3 tools/release/build_menu_preview_loop.py
```

Sources: `docs/RELEASE/trailer/frame_packs/02_habit_trail` + `03_rewrite_slam`.

Optional gif for docs / press: `menu_preview_loop.gif`.
