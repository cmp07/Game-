# Echo Lattice — Audio / Art / UX Upgrade List

**Parent audit:** [`AUDIO_ART_UX.md`](AUDIO_ART_UX.md)  
**Base:** Field Ledger vision on `cursor/echo-lattice-rc1`  
**How to use:** Work top-down within a priority band. Items are implementation-sized, not calendar estimates.

Status keys: `[ ]` open · `[~]` partial · `[x]` done.

---

## P0 — Identity & store blockers

Must clear before marketing “final mix,” Partner Coming Soon with non-temp art, or Next Fest trailer pull.

| ID | Upgrade | Owner lane | Acceptance |
|---|---|---|---|
| P0-01 | **Author rewrite warn + generic rewrite + footstep one-shots** (replace `*_placeholder.ogg`) — paper-crease / ink-pop / chalk-scuff language | Audio | Blind A/B: placeholder beep vs new; warn readable on laptop speakers. *[~] Procedural v3 lift: multi-stage slam phrases + chalkier warn — still DSP; see [`PRODUCTION_AUDIO_DEBT.md`](PRODUCTION_AUDIO_DEBT.md)* |
| P0-02 | **Author L0–L3 stems** (HVAC bed → lattice ticks → habit dissonance → rewrite swell); keep adaptive API | Audio | Chamber 0 stays silent; intensity rises with habit metrics. *[~] Procedural v3: Ledger Cell motif transforms on L0–L3 — not authored hybrids* |
| P0-03 | **Map content transforms → stinger events** (`mirror_v`/`mirror_h`/`mirror_v_then_h`→`mirror`, `rotate_180`→`rotate`, `thicken`, `invert`) in `AudioEvents.rewrite_event_id` | Audio/Code | [x] Alias map + catalog `operator_aliases`; campaign transforms hit unique stingers |
| P0-04 | **Trailer audio pass** — warn + slam + queue-next audible in 15s / 30s cuts; Music ducked; no DSP-beep identity | Audio/Mkt | Matches `STEAM_STORE_FINAL.md` §9 |
| P0-05 | **Final capsule set** (header/main/small/vertical/hero/logo/icon/background) — illustrator pass; remove PLACEHOLDER stamps; lock hex to `echo_lattice.palette.json` | Art/Mkt | Capsules README acceptance checklist 1–5 |
| P0-06 | **Encode trailers** into `docs/RELEASE/presskit/trailers/` (`15s` vertical, `30s`, optional store loop) + poster slam still | Mkt | Files exist; muted-safe first 5s; −14 LUFS |
| P0-07 | **Replace legal / AppID / studio placeholders** in store + compliance packs | Ops | No `YOUR_*` / `[LEGAL_*]` in ship docs |

---

## P1 — Telegraph readability & Field Ledger HUD

| ID | Upgrade | Owner lane | Acceptance |
|---|---|---|---|
| P1-01 | **Chamber diegetic punch-card ribbon** (last 30 moves) on page margin using existing punch-card cells | UX/Code | [x] Bottom-bar ribbon wired to `moves_since_checkpoint` |
| P1-02 | **Chamber seed header** printed on top margin (live seed / chamber id), not only menu décor | UX/Code | [x] Top-bar seed strip + `GameState.seed_display_string()` |
| P1-03 | **Cadmium reserve** — telegraph ticks use slate/chalk; escalate to cadmium only at ≤3 steps + slam heartbeat | Art/Code | [x] Far ticks slate; near + heartbeat cadmium; blocked flash ink |
| P1-04 | **Disable rewrite screen shake by default** (keep a11y slider); prefer origami motion + optional sparse particles | Juice/Code | [x] Shake default off / 0.35; rewrite_punch no forced trauma/full-screen flash |
| P1-05 | **Kill continuous pulse** on goal / telegraph / menu fold tease — discrete stamps or tension opacity | Art/Code | [~] Telegraph pulse removed (tension opacity); goal/menu still breathe |
| P1-06 | **Warn threshold UX** — hysteresis so warn SFX doesn’t re-spam when dancing dist=3 | Audio/Code | One arm per approach unless buffer changes shape |
| P1-07 | **Grayscale / colorblind capture audit** in CI or scripted screenshots | A11y | Player/wall/floor/fossil/door-goal/telegraph distinct without hue |
| P1-08 | **Recapture store screenshots ≥1920×1080** from `capture_v2_complete.sh`; keep tour captions | Mkt | Steam slate 8 shots meet resolution preference |

---

## P2 — Menu / shell polish

| ID | Upgrade | Owner lane | Acceptance |
|---|---|---|---|
| P2-01 | **Vendor Latin stack** (IBM Plex Sans Condensed + Serif + Mono or Inter Tight + OFL) under `fonts/latin/`; wire Theme + `draw_string` | Art/Code | Menu brand lockup uses display face; seed uses mono |
| P2-02 | **Settings as index-card** (paper plate, underline controls, paper-turn open) — retire dim glass panel look | UX | `[~]` Instrument Folio plate + ink sliders/options; full Folio* skins / PaperTurn still open |
| P2-03 | **Won / end / daily meta screens** restyled to loose ledger pages + stamp numerals | UX | Same underline button language as menu |
| P2-04 | **Credits scene** (menu entry) with engine/font/audio credits; temporary placeholder audio line until P0 mix | UX/Compliance | `[x]` Colophon stub on Field Index (`credits_colophon`) |
| P2-05 | **Stop `ui.click` on menu `_ready`**; play only on navigation/confirm | Audio/UX | `[x]` Cold boot silent except intentional title bed policy |
| P2-06 | **Align capsules README hex** + regenerate marketing placeholders from palette JSON | Art | Single palette table across game + store |
| P2-07 | **Demo wishlist + Settings** both present in screenshot tour captions when demo feature on | Docs/UX | Tour matches chrome |

---

## P3 — Art MVP completion (demo / launch craft)

| ID | Upgrade | Owner lane | Acceptance |
|---|---|---|---|
| P3-01 | Wall **corners + T-junctions** (8 tiles) — replace flat butt joins | Art | Clean right-angle lattice at 32px |
| P3-02 | `floor_checkpoint` / `start` / `goal` stamp tiles (replace procedural squares) | Art | Checkpoint reads as rubber stamp |
| P3-03 | Surveyor **4-direction walk** (16 frames) + idle stamp polish | Art | Silhouette legible at ~28px |
| P3-04 | Chest-lantern **hard-falloff mask** (1–3 tiles, no bloom) | Art/Code | Only persistent light; copper_key |
| P3-05 | Rust decals **05–08** + deterministic placement from buffer bias | Art | Streamer can read abused direction |
| P3-06 | **12-frame origami strip** (or atlas) driven by slam phases | Art/Code | Trailer still at t≈0.55 matches authored frames |
| P3-07 | Etched **icon set** (undo/restart/seed/ghost/transform/options) | Art | HUD glyphs single-weight ink |
| P3-08 | Index-card **menu backer** texture (optional once fonts land) | Art | Less flat `draw_rect` card |
| P3-09 | Decide door/key: **wire tiles into content** or drop from MVP list | Design | No orphan placeholders |
| P3-10 | Library hero **3840×1240** master (ledger spine, six chambers) | Art/Mkt | Art bible §7 |
| P3-11 | Client **`.ico` / community icon** final (rust infecting grid) | Art | Reads at 32×32 |

---

## P4 — Audio depth (post-identity)

| ID | Upgrade | Owner lane | Acceptance |
|---|---|---|---|
| P4-01 | Author **PA tones** (attention / board / armed / wing) to brutalist transit identity | Audio | No cute UI beeps; dry institutional. *[~] Procedural PA + post hush tails* |
| P4-02 | Author **win.chamber + win.queue_next** open-loop (resolve then hungry cut) | Audio | Players queue next; not brass fanfare. *[~] Ledger Cell 1→5 + cut-early fourth in generator; still DSP* |
| P4-03 | Habit footstep **metallic overtone** layer at high tension (bible §8 polish) | Audio | Optional; placeholders currently omit |
| P4-04 | Align leftover catalog operators (`fossilize_hot_cell`, …) with live rewrite grammar **or** mark post-1.0 | Design/Audio | No dead stinger ids without a call site |
| P4-05 | Settings sliders → **SFX / Music / UI / PA** bus dB (bible checklist) | Code | Music mute ≠ SFX/PA mute |
| P4-06 | Update credits when final mix lands; remove “procedural placeholders” marketing line | Compliance | COMPLIANCE C9 |
| P4-07 | **Reduce-motion truncates slam phrase at stage boundaries** (AUDIO_V3 §3.4) | Audio/Code | No full 0.90s phrase under 50 ms visual stamp |
| P4-08 | Wire / polish **`fail.reset`** against all recover paths (restart done; softlock / death PA as needed) | Audio/Code | [~] `AudioDirector.on_fail_reset` on chamber restart |

**Debt register:** [`PRODUCTION_AUDIO_DEBT.md`](PRODUCTION_AUDIO_DEBT.md)

---

## P5 — Nice-to-have / 1.0 lane (do not block demo)

| ID | Upgrade | Notes |
|---|---|---|
| P5-01 | Wing tint packs (Blueprint / Newsprint / Slate & Chalk) | Art bible §2 / §9.2 |
| P5-02 | Ghost skins + cross-run ghost race screenshot | Store still #3 |
| P5-03 | Achievement rubber-stamp glyphs | Meta |
| P5-04 | CJK font vendor (`NotoSansSC`) when zh-Hans ships | `fonts/README.md` |
| P5-05 | Long-form ~90s gameplay trailer | After announce cut |
| P5-06 | Language title lockups (EN/JP/KR/SC) | 1.0 store |

---

## Suggested sequencing (technical)

```
P0-03 (stinger aliases) ─┬─► P0-01/02 (author SFX/music) ─► P0-04/06 (trailer)
P1-01/02 (chamber HUD) ──┘
P1-03/04/05 (cadmium + shake + pulse) in parallel with art polish
P0-05 capsules ◄─ palette lock (P2-06)
P2-01 fonts before final capsule type lockups
P3-* tiles/character after telegraph HUD so captures stay stable
```

---

## Validation commands (after upgrades)

```bash
cd game/echo_lattice
godot --headless --path . -- --selftest
python3 ../../tools/audio/validate_audio_events.py
python3 art/generate_placeholders.py   # only while placeholders remain
./tools/capture_v2_complete.sh
./tools/capture_press_gifs.sh
```

Re-run this audit’s scorecard when P0 + P1 close; promote remaining P3 items into the art bible MVP checklist explicitly if demo scope slips.
