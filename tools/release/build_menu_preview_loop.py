#!/usr/bin/env python3
"""Build the title-menu gameplay preview loop assets (offline).

Sources trailer frame packs (habit walk + rewrite slam), writes:
  game/echo_lattice/media/menu_preview/frame_XX.png
  game/echo_lattice/media/menu_preview/menu_preview.ogv
  game/echo_lattice/media/menu_preview/menu_preview_loop.gif

Requires ffmpeg on PATH. Live SubViewport preview is preferred at runtime;
these assets are the VideoStreamPlayer / frame-strip fallback + docs gif.

Usage:
  python3 tools/release/build_menu_preview_loop.py
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRAILER = ROOT / "docs" / "RELEASE" / "trailer" / "frame_packs"
OUT = ROOT / "game" / "echo_lattice" / "media" / "menu_preview"


def _run(cmd: list[str]) -> None:
    print("+", " ".join(cmd))
    subprocess.check_call(cmd)


def main() -> int:
    walk = sorted((TRAILER / "02_habit_trail").glob("*.png"))
    slam = sorted((TRAILER / "03_rewrite_slam").glob("0*.png"))
    srcs = walk + slam
    if len(srcs) < 6:
        print("error: missing trailer frame packs under", TRAILER, file=sys.stderr)
        return 1
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("frame_*.png"):
        old.unlink()
    for i, src in enumerate(srcs):
        dest = OUT / f"frame_{i:02d}.png"
        _run(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(src),
                "-vf",
                "crop=1000:560:76:56,scale=480:270",
                "-compression_level",
                "9",
                str(dest),
            ]
        )
    gif = OUT / "menu_preview_loop.gif"
    _run(
        [
            "ffmpeg",
            "-y",
            "-framerate",
            "5",
            "-i",
            str(OUT / "frame_%02d.png"),
            "-vf",
            "fps=5,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=96[p];[s1][p]paletteuse=dither=bayer",
            "-loop",
            "0",
            str(gif),
        ]
    )
    ogv = OUT / "menu_preview.ogv"
    _run(
        [
            "ffmpeg",
            "-y",
            "-framerate",
            "6",
            "-i",
            str(OUT / "frame_%02d.png"),
            "-c:v",
            "libtheora",
            "-q:v",
            "6",
            "-an",
            str(ogv),
        ]
    )
    total = sum(p.stat().st_size for p in OUT.iterdir())
    print(f"wrote {OUT} ({total // 1024} KiB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
