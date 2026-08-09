# The Weaver — gameplay video

Cloud capture of the W1 gather → combine → weave loop from `game/weaver/` (East Post Gap / Teaching Field).

| Asset | Duration | Notes |
|---|---|---|
| [`video/weaver_gameplay_30s.mp4`](video/weaver_gameplay_30s.mp4) | ~29 s · 1280×720 | Primary clip |
| [`video/weaver_gameplay_15s_vertical.mp4`](video/weaver_gameplay_15s_vertical.mp4) | 15 s · 720×1280 | Optional vertical crop |

**Status:** Live Godot capture (not a slideshow). Recorded under Xvfb with the paced `--gameplay-demo` driver.

## Beats shown

1. **Gather** — walk to Anchor, then Span (Fragments HUD rises).
2. **Combine** — combine panel opens; Anchor + Span → Brace Thread.
3. **Weave** — seat Span Structure across the void gap.

## GitHub links (branch `cursor/weaver-1000x-video`)

Replace `COMMIT` with the tip SHA of this branch if you need a frozen permalink.

### 30s landscape

| Kind | URL |
|---|---|
| Blob (download / view) | https://github.com/cmp07/game-/blob/cursor/weaver-1000x-video/docs/WEAVER/media/video/weaver_gameplay_30s.mp4 |
| Raw | https://github.com/cmp07/game-/raw/cursor/weaver-1000x-video/docs/WEAVER/media/video/weaver_gameplay_30s.mp4 |
| Raw (jsDelivr-style alternate) | https://raw.githubusercontent.com/cmp07/game-/cursor/weaver-1000x-video/docs/WEAVER/media/video/weaver_gameplay_30s.mp4 |

### 15s vertical

| Kind | URL |
|---|---|
| Blob (download / view) | https://github.com/cmp07/game-/blob/cursor/weaver-1000x-video/docs/WEAVER/media/video/weaver_gameplay_15s_vertical.mp4 |
| Raw | https://github.com/cmp07/game-/raw/cursor/weaver-1000x-video/docs/WEAVER/media/video/weaver_gameplay_15s_vertical.mp4 |
| Raw (alternate) | https://raw.githubusercontent.com/cmp07/game-/cursor/weaver-1000x-video/docs/WEAVER/media/video/weaver_gameplay_15s_vertical.mp4 |

## Recapture

Requires Godot **4.3** stable, `ffmpeg`, `xvfb-run` / `Xvfb`.

```bash
export PATH="$HOME/bin:$PATH"   # Godot 4.3 on PATH as `godot`
mkdir -p docs/WEAVER/media/video

# Paced demo (skips title; gather→combine→weave; holds for recorder)
DISPLAY_NUM=96
Xvfb :$DISPLAY_NUM -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
export DISPLAY=:$DISPLAY_NUM
ffmpeg -y -f x11grab -video_size 1280x720 -framerate 30 -i :$DISPLAY_NUM \
  -c:v libx264 -pix_fmt yuv420p -crf 18 /tmp/weaver_raw.mp4 &
FFMPEG_PID=$!
godot --path game/weaver --resolution 1280x720 --position 0,0 -- --gameplay-demo
# …or run godot in background and sleep ~28s, then:
kill -INT $FFMPEG_PID
ffmpeg -y -i /tmp/weaver_raw.mp4 -t 30 -c:v libx264 -pix_fmt yuv420p -crf 18 \
  docs/WEAVER/media/video/weaver_gameplay_30s.mp4
```

Headless contract (no video): `godot --path game/weaver --headless -- --selftest`.

## Related

- Screenshots: [`../screenshots/`](../screenshots/)
- Loop authority: [`../02_CORE_LOOP.md`](../02_CORE_LOOP.md) · [`../32_FIRST_FIVE.md`](../32_FIRST_FIVE.md)
- Project: [`../../../game/weaver/README.md`](../../../game/weaver/README.md)
