# Trailers

Finished encodes (G1 look — recaptured after `execute-g1`):

| File | Spec | Status |
|---|---|---|
| `echo_lattice_30s.mp4` | 16:9, 1920×1080, 30 fps, H.264 + silent AAC — Gate A / Clip B | **Present** |
| `echo_lattice_15s_vertical.mp4` | 9:16, 1080×1920, 30 fps — Clip A Shorts/Reels | **Present** |
| `echo_lattice_store_loop.mp4` | 60–90s optional | Missing |
| `poster_slam.png` | Poster frame at slam t≈0.55 | **Present** |

**Rebuild** (Godot 4.3 + xvfb + ffmpeg + Pillow):

```bash
export PATH="$HOME/bin:$PATH"
./game/echo_lattice/tools/capture_gate_a_trailer.sh
python3 tools/release/generate_trailer_text_cards.py
python3 tools/release/encode_trailer_mp4.py
```

**Editor pack (beat sheet, frame packs, VO/cards, SRT):** [`../../trailer/`](../../trailer/).  
Scripts: [`../../SOCIAL_CLIP_SCRIPTS.md`](../../SOCIAL_CLIP_SCRIPTS.md).

Audio: encodes ship with a silent stereo AAC bed. Authored SFX / −14 LUFS mix is a follow-up before Partner upload.
