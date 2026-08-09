# Capture sequences — Godot headless

All Gate A trailer stills come from the playable project via `--screenshot` (see `main.gd`). SEC-03: `--out` must resolve under the Godot project root; the capture script stages under `game/echo_lattice/.capture_staging/` then copies into this pack.

## One-shot

```bash
export PATH="$HOME/bin:$PATH"
export GODOT="${GODOT:-godot}"   # Godot 4.3 stable
./game/echo_lattice/tools/capture_gate_a_trailer.sh
python3 tools/release/generate_trailer_text_cards.py
```

Requires: `xvfb-run`, Godot 4.3, writable project dir.

## Sequence map

| Pack | Screenshot kinds | Chamber | Purpose |
|---|---|---|---|
| `01_open_corridor` | `chamber:0` | 0 | Mute-safe clean ledger |
| `02_habit_trail` | `walk_only:2:{14,9,5,2}` | 2 | Trail densifies toward checkpoint |
| `03_rewrite_slam` | `rewrite:12:{0.05,0.20,0.40,0.55,0.70,0.90}` | 12 | Hero origami phases |
| `04_after_fossil` | `walk_only:12:3`, `rewrite:12:0.55`, `rewrite_done:12` | 12 | Before / mid / after triptych |
| `05_prove_depth` | `chamber:18`, `won:2`, `daily` | 18 / 2 / menu | Mid-act, stars, daily |
| `06_title_cta` | `menu`, `end` | — | Brand lockup + wing clear |
| `poster_slam.png` | copy of slam `04_slot` | 12 | Thumb / news still |

Machine map: [`capture_manifest.json`](capture_manifest.json).

## Slam phase legend

| File | Freeze t | Phase |
|---|---|---|
| `01_heartbeat.png` | 0.05 | Cadmium margin heartbeat |
| `02_creases.png` | 0.20 | Ink creases on doomed floors |
| `03_lift.png` | 0.40 | Paper lift + cast shadow |
| `04_slot.png` | 0.55 | Trailer still — slot into fossil |
| `05_overshoot.png` | 0.70 | Overshoot bounce |
| `06_rust_bleed.png` | 0.90 | Rust bleed from joins |

## Manual single-shot (debug)

```bash
STAGING="game/echo_lattice/.capture_staging"
mkdir -p "$STAGING"
xvfb-run -a -s "-screen 0 1152x672x24" \
  godot --path game/echo_lattice -- --screenshot "rewrite:12:0.55" --out "$STAGING"
```

## Related capture tools

| Script | Output |
|---|---|
| `tools/capture_gate_a_trailer.sh` | **This pack** |
| `tools/capture_press_gifs.sh` | `presskit/images/gif_sequences/` (social GIFs) |
| `tools/capture_v2_complete.sh` | `docs/ECHO_LATTICE/screenshots/v2_complete/` |

Prefer regenerating **this** pack when cutting the 30s master so timings stay aligned with [`TIMING.md`](TIMING.md).
