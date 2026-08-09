# Gate A — 30s rewrite slam trailer pack

Editor-ready package for the Steam Coming Soon **announce trailer** (Gate A item: 30s encode, muted-safe first 5s).

**Branch intent:** G1 recapture + MP4 encode via `cursor/media-g1-trailer` (originally Gate A pack on `cursor/gate-a-trailer`).  
**Visual authority:** origami rewrite slam in `Chamber._draw_rewrite_slam()` — heartbeat → creases → lift → slot → rust bleed (`REWRITE_DURATION = 0.90s`).  
**Palette:** Field Ledger only (`paper_bone` / `ink_black` / `rust_fossil` / `cadmium_warn`). **No neon purple.**

| File | Role |
|---|---|
| [`BEAT_SHEET.md`](BEAT_SHEET.md) | Picture / VO / text / SFX per second — paste into the NLE |
| [`TIMING.md`](TIMING.md) | Frame-accurate (30 fps) cut list + slam sub-timeline |
| [`VO_TEXT_CARDS.md`](VO_TEXT_CARDS.md) | Dry cartographer VO + on-screen card copy |
| [`CAPTURE_SEQUENCES.md`](CAPTURE_SEQUENCES.md) | Godot headless capture recipe per pack |
| [`capture_manifest.json`](capture_manifest.json) | Machine-readable capture → frame map |
| [`frame_packs/`](frame_packs/) | Still packs + poster slam + slam ref GIF |
| [`frame_packs/TOUR.md`](frame_packs/TOUR.md) | Per-pack captions |
| [`text_cards/`](text_cards/) | PNG overlays (ink on paper) |
| [`srt/echo_lattice_30s.srt`](srt/echo_lattice_30s.srt) | Closed captions for baked / Partner upload |

Finished encodes drop in [`../presskit/trailers/`](../presskit/trailers/) per that README (`echo_lattice_30s.mp4`, poster).

## Regenerate captures

```bash
export PATH="$HOME/bin:$PATH"   # Godot 4.3 stable
./game/echo_lattice/tools/capture_gate_a_trailer.sh
python3 tools/release/generate_trailer_text_cards.py
python3 tools/release/encode_trailer_mp4.py   # → presskit/trailers/*.mp4
```

Related scripts: [`SOCIAL_CLIP_SCRIPTS.md`](../SOCIAL_CLIP_SCRIPTS.md) Clip A/B · store §9 [`STEAM_STORE_FINAL.md`](../STEAM_STORE_FINAL.md).

## Delivery specs (Gate A accept)

- Master: **1920×1080**, 30 fps, H.264 MP4, stereo **−14 LUFS**
- First **5 seconds muted-safe** (readable without audio)
- Slam lands mid-cut (~0:06–0:12); hard cut into slot — no dissolve
- End card: **ECHO LATTICE** · `IT LEARNED YOU` · Wishlist / Coming Soon
- Thumbnail: `frame_packs/poster_slam.png` (slot t≈0.55), minimal baked text
