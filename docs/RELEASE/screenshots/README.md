# Echo Lattice — Steam store screenshot slate

**Size:** 1920×1080 (16:9)  
**Count:** 8 (Steam minimum 5)  
**Tool:** [`../../../game/echo_lattice/tools/capture_steam_store.sh`](../../../game/echo_lattice/tools/capture_steam_store.sh)  
**Store order / captions:** [`../STEAM_STORE_FINAL.md`](../STEAM_STORE_FINAL.md) §8 · [`TOUR.md`](TOUR.md)

**G1 slate (2026-08-09):** regenerated from `cursor/execute-g1` @ `26ae974` so Partner stills show diegetic UI, paper framing, and habit beats.  
**Menu 1000× (2026-08-09):** slots `02_brand_main_menu` / `07_daily_select` + [`menu_1000x/`](menu_1000x/) focus-row variants after `cursor/menu-1000x` landed on RC1. See [`TOUR.md`](TOUR.md).

Lower-res loop-proof tour (1152×672) remains at [`../../ECHO_LATTICE/screenshots/v2_complete/`](../../ECHO_LATTICE/screenshots/v2_complete/). **Upload this folder to Steam Partner**, not the tour folder.

## Regenerate

```bash
export PATH="$HOME/bin:$PATH"   # or GODOT=/path/to/Godot_v4.3
# Prefer a G1 tip (execute-g1 or RC1 after G1 merge) so stills match diegetic shell.
./game/echo_lattice/tools/capture_steam_store.sh
```

Optional size override: `CAPTURE_WIDTH=2560 CAPTURE_HEIGHT=1440 ./game/echo_lattice/tools/capture_steam_store.sh`

## Rules

- No debug overlays, Discord watermarks, or fake combat key art
- Field Ledger palette only (paper / ink / rust — not purple glow)
- Files are numbered in **Partner upload order**
