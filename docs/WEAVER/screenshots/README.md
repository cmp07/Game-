# Weaver prototype screenshots

Legacy void / structure pair. Prefer the 1920×1080 gameplay pack under [`../media/photos/`](../media/photos/) — gallery: [`../VIEW_SCREENSHOTS.md`](../VIEW_SCREENSHOTS.md).

| File | Beat |
|---|---|
| `01_void_field.png` | East Post Gap void + Anchor/Span Fragments |
| `02_structure_standing.png` | Span Structure seated after weave |

Regenerate (with the full photo pack):

```bash
git lfs pull --include "game/echo_lattice/fonts/**"
GODOT=/path/to/godot ./game/echo_lattice/tools/capture_weaver_photos.sh
```

Standalone stub (older 2-shot path):

```bash
xvfb-run -a godot --path game/weaver -- --selftest --screenshot
```
