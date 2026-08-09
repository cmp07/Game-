#!/usr/bin/env python3
"""Generate Field Ledger text cards for the Gate A 30s trailer.

Writes PNGs under docs/RELEASE/trailer/text_cards/.
Palette tokens match docs/ECHO_LATTICE/05_ART_BIBLE.md §2.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).resolve().parents[2]
OUT = REPO / "docs" / "RELEASE" / "trailer" / "text_cards"

PAPER = (0xEF, 0xE6, 0xD2, 255)
INK = (0x14, 0x12, 0x10, 255)
RUST = (0x8B, 0x3A, 0x1F, 255)
TEAL = (0x2D, 0x4A, 0x55, 255)
PAPER_DEEP = (0xD9, 0xCD, 0xB0, 255)

W, H = 1920, 1080


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    ]
    for path in candidates:
        if Path(path).is_file():
            return ImageFont.truetype(path, size=size)
    return ImageFont.load_default()


def _paper_bg() -> Image.Image:
    img = Image.new("RGBA", (W, H), PAPER)
    draw = ImageDraw.Draw(img)
    # Subtle ledger margin rules — atmosphere without clutter.
    draw.rectangle((72, 64, W - 72, H - 64), outline=PAPER_DEEP, width=2)
    draw.line((96, H - 140, W - 96, H - 140), fill=PAPER_DEEP, width=1)
    return img


def _center_text(
    img: Image.Image,
    lines: list[str],
    *,
    fill=INK,
    size: int = 72,
    y: int | None = None,
    tracking_note: str | None = None,
    underline: tuple[int, int, int, int] | None = None,
) -> None:
    draw = ImageDraw.Draw(img)
    font = _font(size, bold=True)
    small = _font(36, bold=False)
    ascent, descent = font.getmetrics()
    line_h = ascent + descent
    gap = 22
    total_h = line_h * len(lines) + gap * (len(lines) - 1)
    cy = (H - total_h) // 2 if y is None else y
    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=font, anchor="lt")
        tw = bbox[2] - bbox[0]
        x = (W - tw) // 2
        draw.text((x, cy), line, font=font, fill=fill, anchor="lt")
        if underline is not None and i == len(lines) - 1:
            uy = cy + line_h + 20
            pad = 28
            draw.line((x - pad, uy, x + tw + pad, uy), fill=underline, width=4)
        cy += line_h + gap
    if tracking_note:
        bbox = draw.textbbox((0, 0), tracking_note, font=small, anchor="lt")
        tw = bbox[2] - bbox[0]
        draw.text(((W - tw) // 2, H - 120), tracking_note, font=small, fill=TEAL, anchor="lt")


def lower_third(text: str, *, fill=INK, name: str) -> None:
    img = _paper_bg()
    draw = ImageDraw.Draw(img)
    font = _font(56, bold=True)
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (W - tw) // 2
    y = H - 220
    # Soft paper plate behind type (not a UI card chrome).
    pad_x, pad_y = 48, 28
    draw.rectangle(
        (x - pad_x, y - pad_y, x + tw + pad_x, y + th + pad_y),
        fill=(0xEF, 0xE6, 0xD2, 230),
        outline=PAPER_DEEP,
        width=2,
    )
    draw.text((x, y), text, font=font, fill=fill)
    img.save(OUT / name)


def plate(lines: list[str], *, fill=TEAL, name: str, underline=RUST) -> None:
    img = _paper_bg()
    _center_text(img, lines, fill=fill, size=96 if len(lines) == 1 else 80, underline=underline)
    img.save(OUT / name)


def title_lockup(name: str) -> None:
    img = _paper_bg()
    _center_text(
        img,
        ["ECHO LATTICE"],
        fill=INK,
        size=110,
        underline=RUST,
        tracking_note="IT LEARNED YOU",
    )
    img.save(OUT / name)


def wishlist_cta(name: str) -> None:
    img = _paper_bg()
    _center_text(img, ["Wishlist", "Coming Soon"], fill=INK, size=72, underline=RUST)
    img.save(OUT / name)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    lower_third("Deterministic.", name="card_deterministic.png")
    lower_third("Your footsteps are a draft.", name="card_footsteps_draft.png")
    lower_third("Same seed. Different you.", name="card_same_seed.png")
    lower_third("Hit a checkpoint…", name="card_hit_checkpoint.png")
    plate(["IT LEARNED YOU"], fill=TEAL, name="card_it_learned_you.png")
    lower_third("The maze wears you.", fill=RUST, name="card_maze_wears_you.png")
    lower_third("Thirty-five chambers.", name="card_thirty_five.png")
    lower_third("Four acts.", name="card_four_acts.png")
    lower_third("Daily seed.", fill=TEAL, name="card_daily_seed.png")
    title_lockup("card_title_lockup.png")
    wishlist_cta("card_wishlist_cta.png")
    print(f"wrote {len(list(OUT.glob('*.png')))} cards under {OUT}")


if __name__ == "__main__":
    main()
