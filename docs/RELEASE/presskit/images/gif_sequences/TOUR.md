# Presskit GIF sequences

Frame packs for social GIFs / Shorts. Captured with `game/echo_lattice/tools/capture_press_gifs.sh`.

## 01 — Rewrite slam

Origami slam on chamber 12, frozen at slam progress t:

| Frame | t | Phase |
|---|---|---|
| `01_heartbeat.png` | 0.05 | Cadmium margin heartbeat |
| `02_creases.png` | 0.20 | Ink creases on doomed floors |
| `03_lift.png` | 0.40 | Paper lift + cast shadow |
| `04_slot.png` | 0.55 | Trailer still — slot into fossil |
| `05_overshoot.png` | 0.70 | Overshoot bounce |
| `06_rust_bleed.png` | 0.90 | Rust bleed from joins |

Assemble at ~8–10 fps for a ~0.7–0.9s punch, or hold the 0.55 frame as a still.

## 02 — Habit trail

Chamber 2 walk toward checkpoint, stopped early so the chalk trail grows:

`01_far` → `02_mid` → `03_near` → `04_approach`

## 03 — Before / after

| Frame | Beat |
|---|---|
| `01_before_trail.png` | Habit written, no rewrite |
| `02_mid_slam.png` | Lift/slot trailer still |
| `03_after_fossil.png` | Settled rust echo walls |

## Regenerate

```bash
export PATH="$HOME/bin:$PATH"
./game/echo_lattice/tools/capture_press_gifs.sh
```
