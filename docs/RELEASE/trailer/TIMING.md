# Timing chart — 30 fps master

All times are **timecode @ 30 fps** (`mm:ss:ff`). Source stills are 1152×672; timeline is 1920×1080.

## Top-level spine

| In | Out | Frames | Beat | Primary media |
|---|---|---|---|---|
| 00:00:00 | 00:02:00 | 60 | Clean ledger | `01_open_corridor/01_clean_ledger` |
| 00:02:00 | 00:04:00 | 60 | Habit far→mid | `02_habit_trail/01_far`, `02_mid` (30f each) |
| 00:04:00 | 00:05:00 | 30 | Near + seed card | `02_habit_trail/03_near` + `card_same_seed` |
| 00:05:00 | 00:06:00 | 30 | Approach | `02_habit_trail/04_approach` + `card_hit_checkpoint` |
| 00:06:00 | 00:07:15 | ~38 | **Rewrite slam punch** | See slam sub-timeline |
| 00:07:15 | 00:12:00 | 142 | Slot hold / after fossil + `IT LEARNED YOU` | `03_rewrite_slam/04_slot` → `04_after_fossil/03_after_fossil` |
| 00:12:00 | 00:15:00 | 90 | Before / mid / after | `04_after_fossil/*` (30f each) |
| 00:15:00 | 00:18:00 | 90 | Mid-act pressure | `05_prove_depth/01_mid_act` |
| 00:18:00 | 00:21:00 | 90 | Stars clear | `05_prove_depth/02_stars_clear` |
| 00:21:00 | 00:25:00 | 120 | Daily | `05_prove_depth/03_daily_select` |
| 00:25:00 | 00:30:00 | 150 | Title + CTA | `06_title_cta/01_main_menu` + end cards |

**Total:** 900 frames / 30.00 s.

## Slam sub-timeline (hero punch @ 00:06:00)

Slam runtime in-game = **0.90 s**. Trailer compresses phases into ~1.15 s of picture, then holds slot/fossil.

| In (rel) | Frames @ 30fps | Slam t | Phase file | Note |
|---|---|---|---|---|
| +0:00 | 4–5 | 0.05 | `01_heartbeat` | Cadmium margin — one beat only |
| +0:05 | 8–10 | 0.20 | `02_creases` | Ink creases on doomed floors |
| +0:15 | 8–10 | 0.40 | `03_lift` | Paper lift + cast shadow |
| +0:25 | 10–12 | 0.55 | `04_slot` | **Hard cut in** — poster still |
| +0:37 | 6–8 | 0.70 | `05_overshoot` | 1 px bounce feel |
| +0:45 | 8–10 | 0.90 | `06_rust_bleed` | Rust from joins |
| +0:55 | hold | — | `04_slot` or after fossil | Plate `IT LEARNED YOU` |

Assembly tip: treat the six slam PNGs as an **8–10 fps** sequence (≈9 frames each if stretched), not 30 fps strobe.

## Text card in/out

| Card file | In | Out | Safe area |
|---|---|---|---|
| `card_deterministic` | 00:00:15 | 00:02:00 | Lower third |
| `card_footsteps_draft` | 00:02:00 | 00:04:00 | Lower third |
| `card_same_seed` | 00:04:00 | 00:05:00 | Lower third |
| `card_hit_checkpoint` | 00:05:00 | 00:06:00 | Lower third |
| *(none during slam)* | 00:06:00 | 00:07:15 | — |
| `card_it_learned_you` | 00:07:15 | 00:12:00 | Center plate |
| `card_maze_wears_you` | 00:12:00 | 00:15:00 | Lower third |
| `card_thirty_five` | 00:15:00 | 00:18:00 | Lower third |
| `card_four_acts` | 00:18:00 | 00:21:00 | Lower third |
| `card_daily_seed` | 00:21:00 | 00:25:00 | Lower third |
| `card_title_lockup` | 00:25:00 | 00:27:15 | Center |
| `card_wishlist_cta` | 00:27:15 | 00:30:00 | Center |

## Audio markers (mix target −14 LUFS)

| TC | Event |
|---|---|
| 00:00:08 | Soft footstep (under) |
| 00:02:00 | Chalk / buffer ticks |
| 00:06:00 | Cadmium heartbeat (single) |
| 00:06:08 | Paper crease bed |
| 00:06:20 | **Slot hit** (hero transient) |
| 00:06:28 | Rust bleed / chalk-scuff |
| 00:07:10 | Silence pocket before plate |
| 00:25:00 | Logo hit |
| 00:29:10–00:30:00 | Silence tail |
