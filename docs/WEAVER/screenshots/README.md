# Weaver prototype screenshots

Captured from `game/weaver/` via headless selftest (`--selftest --screenshot`).

| File | Beat |
|---|---|
| `01_void_field.png` | East Post Gap void + Anchor/Span Fragments |
| `02_thread_ready.png` | Brace Thread after combine (provisional span) |
| `03_structure_standing.png` | Span Structure seated after weave |

Gallery (embeds + GitHub URLs): [`../VIEW_SCREENSHOTS.md`](../VIEW_SCREENSHOTS.md)

Regenerate:

```bash
xvfb-run -a godot --path game/weaver -- --selftest --screenshot
```
