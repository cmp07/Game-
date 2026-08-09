#!/usr/bin/env python3
"""Encode Gate A trailer MP4s from frame packs + text cards (BEAT_SHEET / TIMING).

Outputs:
  docs/RELEASE/presskit/trailers/echo_lattice_30s.mp4
  docs/RELEASE/presskit/trailers/echo_lattice_15s_vertical.mp4  (Clip A, 9:16)

Requires: ffmpeg, Pillow. Source stills are 1152×672; masters are 1920×1080 (30s)
or 1080×1920 (15s vertical).
"""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[2]
PACKS = REPO / "docs" / "RELEASE" / "trailer" / "frame_packs"
CARDS = REPO / "docs" / "RELEASE" / "trailer" / "text_cards"
OUT_DIR = REPO / "docs" / "RELEASE" / "presskit" / "trailers"

FPS = 30
W30, H30 = 1920, 1080
W15, H15 = 1080, 1920

PAPER = (0xEF, 0xE6, 0xD2, 255)


def _load(path: Path) -> Image.Image:
    if not path.is_file():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGBA")


def _fit_cover(src: Image.Image, tw: int, th: int) -> Image.Image:
    """Scale source to cover target, center-crop."""
    sw, sh = src.size
    scale = max(tw / sw, th / sh)
    nw, nh = max(1, int(round(sw * scale))), max(1, int(round(sh * scale)))
    resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return resized.crop((left, top, left + tw, top + th))


def _fit_letterbox(src: Image.Image, tw: int, th: int, fill=PAPER) -> Image.Image:
    """Scale source to fit inside target, paper letterbox."""
    sw, sh = src.size
    scale = min(tw / sw, th / sh)
    nw, nh = max(1, int(round(sw * scale))), max(1, int(round(sh * scale)))
    resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (tw, th), fill)
    canvas.paste(resized, ((tw - nw) // 2, (th - nh) // 2), resized)
    return canvas


def _composite(base: Image.Image, overlay: Image.Image | None, mode: str = "lower_third") -> Image.Image:
    out = base.copy()
    if overlay is None:
        return out
    ov = overlay
    if ov.size != out.size:
        ov = ov.resize(out.size, Image.Resampling.LANCZOS)
    if mode == "full":
        # Prefer opaque card when it's a full paper plate.
        return Image.alpha_composite(out, ov)
    if mode == "plate":
        return Image.alpha_composite(out, ov)
    # lower_third: keep only the bottom band from the card so gameplay stays visible.
    band_top = int(out.height * 0.72)
    mask = Image.new("L", out.size, 0)
    from PIL import ImageDraw

    draw = ImageDraw.Draw(mask)
    draw.rectangle((0, band_top, out.width, out.height), fill=255)
    cut = Image.new("RGBA", out.size, (0, 0, 0, 0))
    cut.paste(ov, (0, 0), mask)
    return Image.alpha_composite(out, cut)


def _hold(frames: list[Image.Image], img: Image.Image, n: int) -> None:
    for _ in range(max(0, n)):
        frames.append(img.copy())


def build_30s() -> list[Image.Image]:
    p = PACKS
    c = CARDS
    frames: list[Image.Image] = []

    def pic(rel: str) -> Image.Image:
        return _fit_letterbox(_load(p / rel), W30, H30)

    def card(name: str) -> Image.Image:
        return _load(c / name)

    # 0:00–0:02 clean ledger + Deterministic
    img = _composite(pic("01_open_corridor/01_clean_ledger.png"), card("card_deterministic.png"), "lower_third")
    _hold(frames, img, 60)

    # 0:02–0:04 far / mid + footsteps draft (30f each)
    img = _composite(pic("02_habit_trail/01_far.png"), card("card_footsteps_draft.png"), "lower_third")
    _hold(frames, img, 30)
    img = _composite(pic("02_habit_trail/02_mid.png"), card("card_footsteps_draft.png"), "lower_third")
    _hold(frames, img, 30)

    # 0:04–0:05 near + same seed
    img = _composite(pic("02_habit_trail/03_near.png"), card("card_same_seed.png"), "lower_third")
    _hold(frames, img, 30)

    # 0:05–0:06 approach + hit checkpoint
    img = _composite(pic("02_habit_trail/04_approach.png"), card("card_hit_checkpoint.png"), "lower_third")
    _hold(frames, img, 30)

    # Slam punch ~1.15s (~35 frames) @ ~8–10 fps pacing of 6 phases
    slam = [
        "03_rewrite_slam/01_heartbeat.png",
        "03_rewrite_slam/02_creases.png",
        "03_rewrite_slam/03_lift.png",
        "03_rewrite_slam/04_slot.png",
        "03_rewrite_slam/05_overshoot.png",
        "03_rewrite_slam/06_rust_bleed.png",
    ]
    slam_holds = [5, 6, 6, 8, 5, 5]  # ~35 frames
    for rel, n in zip(slam, slam_holds):
        _hold(frames, pic(rel), n)

    # 0:07:15–0:12 slot → after fossil + IT LEARNED YOU (~142f)
    slot = pic("03_rewrite_slam/04_slot.png")
    after = pic("04_after_fossil/03_after_fossil.png")
    plate = card("card_it_learned_you.png")
    _hold(frames, _composite(slot, plate, "plate"), 70)
    _hold(frames, _composite(after, plate, "plate"), 72)

    # 0:12–0:15 before/mid/after triptych (30f each) + maze wears you
    maze = card("card_maze_wears_you.png")
    for rel in (
        "04_after_fossil/01_before_trail.png",
        "04_after_fossil/02_mid_slam.png",
        "04_after_fossil/03_after_fossil.png",
    ):
        _hold(frames, _composite(pic(rel), maze, "lower_third"), 30)

    # 0:15–0:18 mid-act + thirty-five
    _hold(
        frames,
        _composite(pic("05_prove_depth/01_mid_act.png"), card("card_thirty_five.png"), "lower_third"),
        90,
    )
    # 0:18–0:21 stars + four acts
    _hold(
        frames,
        _composite(pic("05_prove_depth/02_stars_clear.png"), card("card_four_acts.png"), "lower_third"),
        90,
    )
    # 0:21–0:25 daily + daily seed
    _hold(
        frames,
        _composite(pic("05_prove_depth/03_daily_select.png"), card("card_daily_seed.png"), "lower_third"),
        120,
    )

    # 0:25–0:27.5 title lockup over menu
    title = card("card_title_lockup.png")
    menu = pic("06_title_cta/01_main_menu.png")
    _hold(frames, _composite(menu, title, "plate"), 75)
    # 0:27.5–0:30 wishlist CTA
    _hold(frames, _composite(menu, card("card_wishlist_cta.png"), "plate"), 75)

    # Exact 900 frames
    if len(frames) < 900:
        _hold(frames, frames[-1], 900 - len(frames))
    elif len(frames) > 900:
        frames = frames[:900]
    return frames


def build_15s_vertical() -> list[Image.Image]:
    """Clip A — 9:16, 15s @ 30fps = 450 frames (SOCIAL_CLIP_SCRIPTS)."""
    p = PACKS
    c = CARDS
    frames: list[Image.Image] = []

    def pic(rel: str) -> Image.Image:
        return _fit_cover(_load(p / rel), W15, H15)

    def card_fit(name: str) -> Image.Image:
        return _fit_cover(_load(c / name), W15, H15)

    # 0:00–0:02 trail mid
    _hold(frames, _composite(pic("02_habit_trail/02_mid.png"), card_fit("card_footsteps_draft.png"), "lower_third"), 60)
    # 0:02–0:04 denser + heartbeat
    _hold(frames, pic("02_habit_trail/04_approach.png"), 30)
    _hold(frames, pic("03_rewrite_slam/01_heartbeat.png"), 30)
    # 0:04–0:07 creases + lift
    _hold(frames, pic("03_rewrite_slam/02_creases.png"), 45)
    _hold(frames, pic("03_rewrite_slam/03_lift.png"), 45)
    # 0:07–0:11 slot + rust + IT LEARNED YOU
    _hold(frames, pic("03_rewrite_slam/04_slot.png"), 40)
    _hold(frames, pic("03_rewrite_slam/05_overshoot.png"), 20)
    _hold(frames, pic("03_rewrite_slam/06_rust_bleed.png"), 20)
    _hold(frames, _composite(pic("04_after_fossil/03_after_fossil.png"), card_fit("card_it_learned_you.png"), "plate"), 40)
    # 0:11–0:15 title + CTA
    menu = pic("06_title_cta/01_main_menu.png")
    _hold(frames, _composite(menu, card_fit("card_title_lockup.png"), "plate"), 60)
    _hold(frames, _composite(menu, card_fit("card_wishlist_cta.png"), "plate"), 60)

    if len(frames) < 450:
        _hold(frames, frames[-1], 450 - len(frames))
    elif len(frames) > 450:
        frames = frames[:450]
    return frames


def encode_frames(frames: list[Image.Image], out_mp4: Path, size: tuple[int, int]) -> None:
    if shutil.which("ffmpeg") is None:
        raise RuntimeError("ffmpeg not found on PATH")
    out_mp4.parent.mkdir(parents=True, exist_ok=True)
    tw, th = size
    with tempfile.TemporaryDirectory(prefix="echo_trailer_") as tmp:
        tmp_path = Path(tmp)
        for i, frame in enumerate(frames):
            if frame.size != (tw, th):
                frame = frame.resize((tw, th), Image.Resampling.LANCZOS)
            # Write RGB PNG sequence
            frame.convert("RGB").save(tmp_path / f"f_{i:05d}.png")
        # Silent stereo AAC so Steam accepts; mix target placeholder (-14 LUFS later with real SFX).
        cmd = [
            "ffmpeg",
            "-y",
            "-framerate",
            str(FPS),
            "-i",
            str(tmp_path / "f_%05d.png"),
            "-f",
            "lavfi",
            "-i",
            "anullsrc=channel_layout=stereo:sample_rate=48000",
            "-c:v",
            "libx264",
            "-pix_fmt",
            "yuv420p",
            "-profile:v",
            "high",
            "-level",
            "4.1",
            "-crf",
            "18",
            "-preset",
            "medium",
            "-c:a",
            "aac",
            "-b:a",
            "192k",
            "-shortest",
            "-movflags",
            "+faststart",
            str(out_mp4),
        ]
        subprocess.run(cmd, check=True)


def main() -> int:
    out30 = OUT_DIR / "echo_lattice_30s.mp4"
    out15 = OUT_DIR / "echo_lattice_15s_vertical.mp4"
    print("building 30s master…")
    frames30 = build_30s()
    print(f"  {len(frames30)} frames → {out30}")
    encode_frames(frames30, out30, (W30, H30))
    print("building 15s vertical…")
    frames15 = build_15s_vertical()
    print(f"  {len(frames15)} frames → {out15}")
    encode_frames(frames15, out15, (W15, H15))
    for path in (out30, out15):
        sz = path.stat().st_size
        print(f"wrote {path} ({sz / 1024 / 1024:.2f} MiB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
