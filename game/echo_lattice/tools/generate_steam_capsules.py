#!/usr/bin/env python3
"""Generate Field Ledger–faithful Steam capsule finals for Echo Lattice (G1).

Outputs exact Steam pixel sizes under docs/RELEASE/capsules/.
Palette locked to game/echo_lattice/art/palette/echo_lattice.palette.json.
Typography: IBM Plex Sans Condensed (ART_DIRECTION_V3 / art bible display stack).
Materials: print-shop process (fiber paper, letterpress tremor, rubber stamp,
origami crease + contact shadow, stepped lantern — no purple / neon / bloom).
No PLACEHOLDER stamp.
"""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "docs" / "RELEASE" / "capsules"
FONT_DIR = Path(__file__).resolve().parent / "fonts"

# Field Ledger — single source of truth (palette.json)
PAPER = (0xEF, 0xE6, 0xD2, 255)
PAPER_DEEP = (0xD9, 0xCD, 0xB0, 255)
PAPER_MARGIN = (0xE0, 0xD6, 0xC0, 255)  # bone darkened ~8% toward ink (desk/lightbox)
INK = (0x14, 0x12, 0x10, 255)
INK_SOFT = (0x3A, 0x34, 0x2C, 255)
CHALK = (0xF5, 0xEF, 0xDD, 255)
RUST = (0x8B, 0x3A, 0x1F, 255)
RUST_DEEP = (0x5E, 0x24, 0x12, 255)
SLATE = (0x2D, 0x4A, 0x55, 255)
SLATE_SOFT = (0x4A, 0x6D, 0x77, 255)
COPPER = (0xB8, 0x76, 0x3A, 255)
TRANSPARENT = (0, 0, 0, 0)

FONT_DISPLAY = "IBMPlexSansCondensed-Bold.ttf"
FONT_TAG = "IBMPlexSansCondensed-Medium.ttf"


def with_alpha(c: tuple[int, ...], a: int) -> tuple[int, int, int, int]:
    return c[0], c[1], c[2], a


def load_font(name: str, size: int) -> ImageFont.FreeTypeFont:
    path = FONT_DIR / name
    if path.exists():
        return ImageFont.truetype(str(path), size=size)
    for fb in (
        "/usr/share/fonts/truetype/liberation/LiberationSansNarrow-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ):
        if Path(fb).exists():
            return ImageFont.truetype(fb, size=size)
    return ImageFont.load_default()


def paper_base(w: int, h: int, seed: int = 1, grain: float = 0.045) -> Image.Image:
    """Warm printer stock: vertical wash + fiber streaks + micro grain (no pure white)."""
    rng = random.Random(seed)
    img = Image.new("RGBA", (w, h), PAPER)
    px = img.load()
    # Precompute a few fiber strands (print-shop residue)
    fibers = []
    for _ in range(max(8, (w * h) // 18000)):
        fx = rng.uniform(0, w)
        fy = rng.uniform(0, h)
        fl = rng.uniform(18, 55)
        fang = rng.uniform(-0.35, 0.35)
        fibers.append((fx, fy, fl, fang, rng.uniform(-4.5, -1.5)))

    for y in range(h):
        for x in range(w):
            wash = (x / max(w - 1, 1) - 0.5) * 5.5 + (y / max(h - 1, 1) - 0.5) * 3.5
            # Cooler desk bleed near edges (lightbox under paper)
            edge = min(x, y, w - 1 - x, h - 1 - y)
            desk = max(0.0, 1.0 - edge / 28.0) * 3.0
            n = rng.gauss(0, grain * 255)
            # Sparse fiber hits
            fiber = 0.0
            for fx, fy, fl, fang, strength in fibers:
                dx = x - fx
                dy = y - fy
                along = dx * math.cos(fang) + dy * math.sin(fang)
                across = -dx * math.sin(fang) + dy * math.cos(fang)
                if 0 <= along <= fl and abs(across) < 0.9:
                    fiber = strength
                    break
            r = int(max(0, min(255, PAPER[0] + wash + n + fiber - desk * 0.35)))
            g = int(max(0, min(255, PAPER[1] + wash * 0.85 + n + fiber - desk * 0.2)))
            b = int(max(0, min(255, PAPER[2] + wash * 0.7 + n * 0.8 + fiber * 0.7 + desk * 0.15)))
            px[x, y] = (r, g, b, 255)
    return img


def draw_grid(
    draw: ImageDraw.ImageDraw,
    w: int,
    h: int,
    step: int,
    color: tuple[int, int, int, int],
    origin: tuple[int, int] = (0, 0),
) -> None:
    ox, oy = origin
    x = ox % step
    while x < w:
        draw.line([(x, 0), (x, h - 1)], fill=color, width=1)
        x += step
    y = oy % step
    while y < h:
        draw.line([(0, y), (w - 1, y)], fill=color, width=1)
        y += step


def draw_ledger_subgrid(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    step: int = 4,
    color: tuple[int, int, int, int] | None = None,
) -> None:
    """Faint 4 px ledger sub-grid inside a page region (ART_DIRECTION_V3 §2.1)."""
    if color is None:
        color = with_alpha(INK_SOFT, 16)
    x0, y0, x1, y1 = box
    x = x0
    while x <= x1:
        draw.line([(x, y0), (x, y1)], fill=color, width=1)
        x += step
    y = y0
    while y <= y1:
        draw.line([(x0, y), (x1, y)], fill=color, width=1)
        y += step


def draw_tracked_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[float, float],
    text: str,
    font: ImageFont.ImageFont,
    fill: tuple[int, ...],
    tracking: float = 0.0,
    anchor: str = "lt",
) -> tuple[float, float, float, float]:
    """Draw text with letter-spacing; returns ink bbox (l,t,r,b)."""
    widths = []
    for ch in text:
        bbox = font.getbbox(ch)
        widths.append(max(1, bbox[2] - bbox[0]))
    total = sum(widths) + tracking * max(len(text) - 1, 0)
    hb = font.getbbox("Hg")
    th = hb[3] - hb[1]
    x, y = float(xy[0]), float(xy[1])
    if anchor in ("mm", "mt", "mb"):
        x -= total / 2
    elif anchor in ("rm", "rt", "rb"):
        x -= total
    if anchor in ("lm", "mm", "rm"):
        y -= th / 2
    elif anchor in ("lb", "mb", "rb"):
        y -= th

    cursor = x
    for i, ch in enumerate(text):
        draw.text((cursor, y), ch, font=font, fill=fill, anchor="lt")
        cursor += widths[i] + tracking

    right = cursor - (tracking if len(text) > 1 else 0)
    top = y
    try:
        tb = draw.textbbox((x, y), text.replace(" ", "i"), font=font, anchor="lt")
        top, bottom = tb[1], tb[3]
    except Exception:
        ascent = -font.getbbox("Hg")[1]
        descent = font.getbbox("Hg")[3]
        bottom = y + (ascent + descent)
    return (x, top, right, bottom)


def surveyor(
    draw: ImageDraw.ImageDraw,
    cx: float,
    cy: float,
    scale: float = 1.0,
    lantern: bool = True,
) -> None:
    """Hooded surveyor stamp — triangular torso, soft head, copper chest lantern."""
    s = scale
    head_r = 5.5 * s
    draw.ellipse(
        [cx - head_r, cy - 14 * s - head_r, cx + head_r, cy - 14 * s + head_r],
        fill=INK,
    )
    draw.polygon(
        [
            (cx - 9 * s, cy - 12 * s),
            (cx + 9 * s, cy - 12 * s),
            (cx + 6 * s, cy - 4 * s),
            (cx - 6 * s, cy - 4 * s),
        ],
        fill=INK,
    )
    draw.polygon(
        [
            (cx, cy - 6 * s),
            (cx + 11 * s, cy + 16 * s),
            (cx - 11 * s, cy + 16 * s),
        ],
        fill=INK,
    )
    draw.rectangle([cx - 8 * s, cy + 15 * s, cx - 2 * s, cy + 18 * s], fill=INK)
    draw.rectangle([cx + 2 * s, cy + 15 * s, cx + 8 * s, cy + 18 * s], fill=INK)
    if lantern:
        lr = 2.8 * s
        draw.ellipse(
            [cx - lr, cy + 1 * s - lr, cx + lr, cy + 1 * s + lr],
            fill=COPPER,
        )
        cr = 1.1 * s
        draw.ellipse(
            [cx - cr, cy + 1 * s - cr, cx + cr, cy + 1 * s + cr],
            fill=with_alpha(CHALK, 230),
        )


def footprint(draw: ImageDraw.ImageDraw, x: float, y: float, scale: float = 1.0, fill=CHALK) -> None:
    s = scale
    draw.ellipse([x - 3 * s, y - 5 * s, x + 3 * s, y + 2 * s], fill=fill)
    draw.ellipse([x - 1.5 * s, y + 2 * s, x + 1.5 * s, y + 5 * s], fill=fill)


def dashed_polyline(
    draw: ImageDraw.ImageDraw,
    pts: list[tuple[float, float]],
    fill,
    width: int = 2,
    dash: float = 8,
    gap: float = 5,
) -> None:
    for i in range(len(pts) - 1):
        x0, y0 = pts[i]
        x1, y1 = pts[i + 1]
        dist = math.hypot(x1 - x0, y1 - y0)
        if dist < 1:
            continue
        ux, uy = (x1 - x0) / dist, (y1 - y0) / dist
        t = 0.0
        drawing = True
        while t < dist:
            seg = dash if drawing else gap
            t2 = min(dist, t + seg)
            if drawing:
                draw.line(
                    [(x0 + ux * t, y0 + uy * t), (x0 + ux * t2, y0 + uy * t2)],
                    fill=fill,
                    width=width,
                )
            t = t2
            drawing = not drawing


def ink_wall_rect(
    draw: ImageDraw.ImageDraw,
    box: tuple[float, float, float, float],
    seed: int = 1,
    paper_side: str = "right",
) -> None:
    """Letterpress ink wall: dense fill + 1 px ink_soft hairline with edge tremor."""
    x0, y0, x1, y1 = box
    draw.rectangle([x0, y0, x1, y1], fill=INK)
    rng = random.Random(seed)
    # Hairline on the paper-facing edge
    if paper_side == "right":
        hx = x1 + 1
        y = y0
        while y < y1:
            tremor = rng.choice([-1, 0, 0, 0, 1])
            draw.point((hx + tremor, y), fill=with_alpha(INK_SOFT, 200))
            y += 1
    elif paper_side == "left":
        hx = x0 - 1
        y = y0
        while y < y1:
            tremor = rng.choice([-1, 0, 0, 0, 1])
            draw.point((hx + tremor, y), fill=with_alpha(INK_SOFT, 200))
            y += 1
    elif paper_side == "bottom":
        hy = y1 + 1
        x = x0
        while x < x1:
            tremor = rng.choice([-1, 0, 0, 0, 1])
            draw.point((x, hy + tremor), fill=with_alpha(INK_SOFT, 200))
            x += 1


def origami_wall_panel(
    draw: ImageDraw.ImageDraw,
    base: tuple[float, float],
    w: float,
    h: float,
    lean: float = 0.0,
    rust_edge: bool = False,
) -> None:
    """Folding paper wall — light face + ink edge + crease + contact shadow (no glow)."""
    bx, by = base
    # Contact shadow (multiply toward ink, α ≤ 0.35) — offset bottom-right
    draw.polygon(
        [
            (bx + 3, by + 4),
            (bx + w + 5, by + 4),
            (bx + w + lean + 4, by - h + 6),
            (bx + lean * 0.2 + 3, by - h + 6),
        ],
        fill=with_alpha(INK, 70),
    )
    # Floor hinge
    draw.polygon(
        [
            (bx - 2, by + 2),
            (bx + w + 2, by + 2),
            (bx + w + lean * 0.2, by - 4),
            (bx + lean * 0.1, by - 4),
        ],
        fill=with_alpha(INK_SOFT, 55),
    )
    face = [
        (bx, by),
        (bx + w, by),
        (bx + w + lean, by - h),
        (bx + lean * 0.25, by - h),
    ]
    draw.polygon(face, fill=PAPER_DEEP)
    edge = [
        (bx + w, by),
        (bx + w + 5, by - 2),
        (bx + w + lean + 5, by - h - 2),
        (bx + w + lean, by - h),
    ]
    draw.polygon(edge, fill=INK)
    draw.line(
        [(bx + lean * 0.25, by - h), (bx + w + lean, by - h)],
        fill=INK,
        width=2,
    )
    # Crease valley + secondary fold
    draw.line(
        [(bx + w * 0.4, by), (bx + w * 0.4 + lean * 0.55, by - h)],
        fill=with_alpha(INK_SOFT, 150),
        width=1,
    )
    draw.line(
        [(bx + w * 0.72, by), (bx + w * 0.72 + lean * 0.4, by - h * 0.85)],
        fill=with_alpha(INK_SOFT, 90),
        width=1,
    )
    draw.line([face[0], face[3]], fill=with_alpha(INK, 200), width=1)
    if rust_edge:
        rust_pts = [
            (bx, by),
            (bx + w * 0.6, by),
            (bx + w * 0.5 + lean * 0.25, by - h * 0.4),
            (bx + lean * 0.12, by - h * 0.32),
        ]
        draw.polygon(rust_pts, fill=with_alpha(RUST, 215))
        draw.polygon(
            [
                (bx + w * 0.1, by),
                (bx + w * 0.38, by),
                (bx + w * 0.3 + lean * 0.1, by - h * 0.2),
            ],
            fill=with_alpha(RUST_DEEP, 190),
        )


def stamp_mark(
    _draw: ImageDraw.ImageDraw,
    cx: float,
    cy: float,
    text: str = "§ 04",
    scale: float = 1.0,
    rotation_deg: float = -3.0,
) -> Image.Image:
    """Circular rubber stamp with slight rotation + ink unevenness (returns layer)."""
    font = load_font(FONT_TAG, max(10, int(12 * scale)))
    pad = int(28 * scale)
    layer = Image.new("RGBA", (pad * 2, pad * 2), TRANSPARENT)
    ld = ImageDraw.Draw(layer)
    lcx, lcy = pad, pad
    r = 16 * scale
    # Uneven ring: draw arc segments with gaps
    rng = random.Random(int(cx * 7 + cy * 13))
    for a0 in range(0, 360, 12):
        if rng.random() < 0.18:
            continue  # ink skip
        a1 = a0 + 11
        ld.arc(
            [lcx - r, lcy - r, lcx + r, lcy + r],
            start=a0,
            end=a1,
            fill=SLATE,
            width=max(1, int(1.6 * scale)),
        )
    # Inner hairline
    ld.arc(
        [lcx - r + 3 * scale, lcy - r + 3 * scale, lcx + r - 3 * scale, lcy + r - 3 * scale],
        start=20,
        end=340,
        fill=with_alpha(SLATE, 180),
        width=1,
    )
    bbox = font.getbbox(text)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    ld.text((lcx - tw / 2, lcy - th / 2 - 1), text, font=font, fill=SLATE)
    if abs(rotation_deg) > 0.01:
        layer = layer.rotate(rotation_deg, resample=Image.Resampling.BICUBIC, expand=False)
    return layer


def paste_centered(base: Image.Image, layer: Image.Image, cx: float, cy: float) -> None:
    x = int(cx - layer.width / 2)
    y = int(cy - layer.height / 2)
    base.alpha_composite(layer, (x, y))


def lantern_disk(
    w: int,
    h: int,
    cx: float,
    cy: float,
    radius: float,
) -> Image.Image:
    """Hard copper lantern disk with ordered dither falloff (no Gaussian bloom)."""
    layer = Image.new("RGBA", (w, h), TRANSPARENT)
    px = layer.load()
    # 4×4 Bayer matrix
    bayer = [
        [0, 8, 2, 10],
        [12, 4, 14, 6],
        [3, 11, 1, 9],
        [15, 7, 13, 5],
    ]
    r2 = radius * 2.75
    x0 = max(0, int(cx - r2 - 2))
    x1 = min(w, int(cx + r2 + 3))
    y0 = max(0, int(cy - r2 - 2))
    y1 = min(h, int(cy + r2 + 3))
    for y in range(y0, y1):
        for x in range(x0, x1):
            d = math.hypot(x - cx, y - cy) / max(radius, 1e-3)
            if d <= 0.55:
                intensity = 1.0
            elif d <= 1.5:
                t = (d - 0.55) / (1.5 - 0.55)
                intensity = 1.0 * (1 - t) + 0.35 * t
            elif d <= 2.75:
                t = (d - 1.5) / (2.75 - 1.5)
                intensity = 0.35 * (1 - t)
            else:
                continue
            thr = (bayer[y & 3][x & 3] + 0.5) / 16.0
            # Keep core solid; dither the outer ring only
            if d <= 0.55 or intensity > thr * 0.85:
                a = int(38 * intensity)
                if a > 0:
                    px[x, y] = (COPPER[0], COPPER[1], COPPER[2], a)
    return layer


def rust_veins(
    draw: ImageDraw.ImageDraw,
    origin: tuple[float, float],
    seed: int,
    count: int = 8,
    spread: float = 40,
) -> None:
    """Oxide veins from a join inward — matte, dusty, zero emissive."""
    rng = random.Random(seed)
    ox, oy = origin
    for i in range(count):
        x, y = ox, oy
        length = rng.randint(10, int(spread))
        angle = rng.uniform(-math.pi * 0.7, math.pi * 0.7)
        for _ in range(length):
            angle += rng.uniform(-0.35, 0.35)
            x += math.cos(angle) * 1.4
            y += math.sin(angle) * 1.1
            rw = rng.randint(2, 5)
            rh = rng.randint(1, 3)
            col = RUST if rng.random() > 0.35 else RUST_DEEP
            draw.ellipse(
                [x, y, x + rw, y + rh],
                fill=with_alpha(col, 130 + rng.randint(0, 70)),
            )


def wordmark_block(
    draw: ImageDraw.ImageDraw,
    x: float,
    y: float,
    title_size: int,
    tag_size: int,
    tracking: float,
    underline: bool = True,
    tagline: bool = True,
    align: str = "left",
) -> None:
    title_font = load_font(FONT_DISPLAY, title_size)
    tag_font = load_font(FONT_TAG, tag_size)
    title = "ECHO LATTICE"
    tag = "IT LEARNED YOU"
    anchor = "lt" if align == "left" else "mt"
    bb = draw_tracked_text(draw, (x, y), title, title_font, INK, tracking=tracking, anchor=anchor)
    uh = max(3, title_size // 12)
    if underline:
        uy0 = bb[3] + max(2, title_size // 20)
        draw.rectangle([bb[0], uy0, bb[2], uy0 + uh], fill=RUST)
    if tagline:
        ty = (bb[3] + max(2, title_size // 20) + uh) + max(6, title_size // 10)
        draw_tracked_text(
            draw,
            (bb[0] if align == "left" else x, ty),
            tag,
            tag_font,
            SLATE,
            tracking=tracking * 0.55,
            anchor=anchor,
        )


# ---------------------------------------------------------------------------
# Capsules
# ---------------------------------------------------------------------------


def make_header() -> Image.Image:
    w, h = 460, 215
    img = paper_base(w, h, seed=11, grain=0.04)
    overlay = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(overlay)
    draw_grid(d, w, h, 16, with_alpha(INK_SOFT, 28))
    draw_ledger_subgrid(d, (24, 48, 436, 168), step=4, color=with_alpha(INK_SOFT, 14))

    d.rectangle([24, 48, 436, 168], fill=with_alpha(PAPER_DEEP, 70))
    d.rectangle([24, 48, 436, 168], outline=with_alpha(INK_SOFT, 90), width=1)

    ink_wall_rect(d, (24, 48, 40, 168), seed=101, paper_side="right")
    ink_wall_rect(d, (24, 48, 280, 62), seed=102, paper_side="bottom")
    ink_wall_rect(d, (400, 48, 436, 168), seed=103, paper_side="left")

    trail = [
        (56, 150),
        (96, 150),
        (96, 120),
        (140, 120),
        (140, 96),
        (196, 96),
        (196, 128),
        (248, 128),
        (248, 88),
        (300, 88),
    ]
    for i in range(len(trail) - 1):
        d.line([trail[i], trail[i + 1]], fill=with_alpha(INK_SOFT, 50), width=5)
    for i in range(len(trail) - 1):
        d.line([trail[i], trail[i + 1]], fill=with_alpha(CHALK, 245), width=3)
    for p in trail:
        footprint(d, p[0], p[1] + 2, scale=0.9, fill=with_alpha(CHALK, 235))

    origami_wall_panel(d, (168, 150), 36, 52, lean=-6, rust_edge=False)
    origami_wall_panel(d, (210, 150), 40, 68, lean=4, rust_edge=True)
    origami_wall_panel(d, (258, 150), 34, 46, lean=10, rust_edge=False)

    surveyor(d, 312, 118, scale=1.35, lantern=True)
    rust_veins(d, (400, 70), seed=404, count=12, spread=55)
    for i in range(8):
        yy = 72 + i * 10
        ww = 6 + (i % 3) * 3
        d.rectangle([400 - ww, yy, 436, yy + 5], fill=with_alpha(RUST, 150 + (i % 3) * 18))

    overlay = Image.alpha_composite(overlay, lantern_disk(w, h, 312, 120, 14))
    img = Image.alpha_composite(img, overlay)
    d2 = ImageDraw.Draw(img)
    # Plex Condensed is already narrow — slight negative tracking (V3 tight)
    wordmark_block(d2, 28, 172, title_size=28, tag_size=11, tracking=-0.6, underline=True, tagline=True)
    return img.convert("RGB")


def make_main() -> Image.Image:
    w, h = 616, 353
    img = paper_base(w, h, seed=22, grain=0.038)
    overlay = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(overlay)
    draw_grid(d, w, h, 18, with_alpha(INK_SOFT, 26))

    d.polygon([(40, 80), (560, 70), (580, 280), (28, 290)], fill=with_alpha(PAPER_DEEP, 85))
    d.line([(40, 80), (560, 70), (580, 280), (28, 290), (40, 80)], fill=with_alpha(INK_SOFT, 100), width=1)
    draw_ledger_subgrid(d, (100, 100, 500, 260), step=4, color=with_alpha(INK_SOFT, 12))

    d.polygon([(40, 80), (120, 80), (100, 290), (28, 290)], fill=INK)
    d.polygon([(480, 72), (560, 70), (580, 280), (500, 282)], fill=INK)
    # Letterpress hairlines on paper-facing edges
    for y in range(90, 280, 1):
        t = random.Random(5000 + y).choice([-1, 0, 0, 1])
        d.point((120 + t, y), fill=with_alpha(INK_SOFT, 190))
        d.point((480 + t, y - 4), fill=with_alpha(INK_SOFT, 190))

    ghost = [(90, 250), (160, 250), (160, 200), (240, 200), (240, 150), (340, 150), (340, 210), (420, 210)]
    dashed_polyline(d, ghost, with_alpha(SLATE_SOFT, 160), width=2, dash=7, gap=5)

    chalk_path = [(120, 260), (180, 260), (180, 220), (250, 220), (250, 170), (330, 170), (330, 140)]
    for i in range(len(chalk_path) - 1):
        d.line([chalk_path[i], chalk_path[i + 1]], fill=with_alpha(CHALK, 235), width=4)
    for p in chalk_path:
        footprint(d, p[0], p[1], scale=1.0, fill=with_alpha(CHALK, 220))

    origami_wall_panel(d, (200, 255), 48, 78, lean=-10, rust_edge=True)
    origami_wall_panel(d, (260, 255), 52, 96, lean=2, rust_edge=False)
    origami_wall_panel(d, (320, 255), 46, 70, lean=12, rust_edge=True)

    stamp = stamp_mark(d, 390, 155, "§ 04", scale=1.35, rotation_deg=-2.5)
    paste_centered(overlay, stamp, 390, 155)

    surveyor(d, 370, 125, scale=1.85, lantern=True)
    overlay = Image.alpha_composite(overlay, lantern_disk(w, h, 370, 128, 16))

    rust_veins(ImageDraw.Draw(overlay), (100, 270), seed=606, count=14, spread=70)
    rd = ImageDraw.Draw(overlay)
    for i in range(6):
        rx, ry = 70 + i * 18, 255 + (i % 3) * 6
        rd.rectangle([rx, ry, rx + 14, ry + 10], fill=with_alpha(RUST, 140 + i * 8))

    img = Image.alpha_composite(img, overlay)
    d2 = ImageDraw.Draw(img)
    wordmark_block(d2, 36, 300, title_size=36, tag_size=13, tracking=-0.8, underline=True, tagline=True)
    return img.convert("RGB")


def make_small() -> Image.Image:
    w, h = 231, 87
    img = paper_base(w, h, seed=33, grain=0.03)
    d = ImageDraw.Draw(img, "RGBA")
    d.polygon([(8, 78), (38, 78), (34, 18), (12, 22)], fill=INK)
    d.polygon([(38, 78), (62, 78), (58, 16), (34, 18)], fill=INK_SOFT)
    d.line([(38, 78), (34, 18)], fill=with_alpha(PAPER_DEEP, 120), width=1)
    # Contact shadow under doorway
    d.polygon([(10, 80), (60, 80), (58, 84), (12, 84)], fill=with_alpha(INK, 40))
    surveyor(d, 48, 48, scale=1.15, lantern=False)
    font = load_font(FONT_DISPLAY, 22)
    bb = draw_tracked_text(d, (74, 28), "ECHO LATTICE", font, INK, tracking=-0.4, anchor="lt")
    d.rectangle([bb[0], bb[3] + 3, bb[2], bb[3] + 6], fill=RUST)
    return img.convert("RGB")


def make_vertical() -> Image.Image:
    w, h = 374, 448
    img = paper_base(w, h, seed=44, grain=0.04)
    overlay = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(overlay)
    draw_grid(d, w, h, 17, with_alpha(INK_SOFT, 24))
    draw_ledger_subgrid(d, (48, 36, 326, 170), step=4, color=with_alpha(INK_SOFT, 14))

    d.rectangle([48, 36, 326, 170], fill=with_alpha(PAPER_DEEP, 60))
    ink_wall_rect(d, (48, 36, 64, 170), seed=701, paper_side="right")
    ink_wall_rect(d, (310, 36, 326, 170), seed=702, paper_side="left")
    surveyor(d, 187, 95, scale=2.2, lantern=True)
    overlay = Image.alpha_composite(overlay, lantern_disk(w, h, 187, 98, 18))

    path = [
        (187, 130),
        (187, 180),
        (140, 180),
        (140, 230),
        (220, 230),
        (220, 280),
        (160, 280),
        (160, 340),
        (240, 340),
        (240, 390),
    ]
    dashed_polyline(d, path[:4], with_alpha(CHALK, 220), width=3, dash=9, gap=4)
    for i in range(3, len(path) - 1):
        d.line([path[i], path[i + 1]], fill=with_alpha(CHALK, 230), width=3)

    img = Image.alpha_composite(img, overlay)
    d2 = ImageDraw.Draw(img)
    wordmark_block(
        d2, w / 2, 195, title_size=34, tag_size=12, tracking=-0.7, underline=True, tagline=True, align="center"
    )

    bloom = Image.new("RGBA", (w, h), TRANSPARENT)
    bd = ImageDraw.Draw(bloom)
    bd.rectangle([48, 300, 326, 420], fill=with_alpha(INK, 230))
    rust_veins(bd, (48, 340), seed=808, count=20, spread=90)
    for i in range(14):
        rng = random.Random(90 + i)
        rx = 60 + rng.randint(0, 240)
        ry = 310 + rng.randint(0, 90)
        rw = rng.randint(20, 70)
        rh = rng.randint(12, 40)
        bd.ellipse([rx, ry, rx + rw, ry + rh], fill=with_alpha(RUST, 120 + rng.randint(0, 80)))
    for i in range(8):
        rng = random.Random(200 + i)
        rx = 80 + rng.randint(0, 200)
        ry = 330 + rng.randint(0, 60)
        bd.ellipse([rx, ry, rx + 24, ry + 16], fill=with_alpha(RUST_DEEP, 160))
    bd.line([(48, 340), (326, 355)], fill=with_alpha(PAPER_DEEP, 50), width=1)
    bd.line([(48, 380), (326, 370)], fill=with_alpha(PAPER_DEEP, 40), width=1)

    img = Image.alpha_composite(img, bloom)
    return img.convert("RGB")


def make_library_hero() -> Image.Image:
    w, h = 1920, 620
    img = paper_base(w, h, seed=55, grain=0.035)
    overlay = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(overlay)
    draw_grid(d, w, h, 24, with_alpha(INK_SOFT, 22))

    margin_x, margin_y = 56, 70
    spine_w = 30
    gutter = 20
    page_gap = 18
    per_side = 3
    spine_x = w // 2
    side_w = spine_x - margin_x - gutter - spine_w // 2
    page_w = (side_w - page_gap * (per_side - 1)) // per_side
    page_h = h - 2 * margin_y

    rust_indices = {1, 3, 5}
    ghost: list[tuple[float, float]] = []

    def draw_page(index: int, x0: int) -> None:
        y0 = margin_y
        # Page thickness / contact shadow
        d.rectangle(
            [x0 + 4, y0 + 5, x0 + page_w + 4, y0 + page_h + 5],
            fill=with_alpha(INK, 45),
        )
        d.rectangle([x0, y0, x0 + page_w, y0 + page_h], fill=PAPER, outline=INK, width=3)
        d.line([(x0 + 14, y0 + 12), (x0 + 14, y0 + page_h - 12)], fill=with_alpha(INK_SOFT, 80), width=1)
        draw_ledger_subgrid(
            d,
            (x0 + 24, y0 + 10, x0 + page_w - 10, y0 + page_h - 10),
            step=4,
            color=with_alpha(INK_SOFT, 14),
        )
        step = 22
        for gx in range(x0 + 24, x0 + page_w - 8, step):
            d.line([(gx, y0 + 10), (gx, y0 + page_h - 10)], fill=with_alpha(INK_SOFT, 30), width=1)
        for gy in range(y0 + 10, y0 + page_h - 8, step):
            d.line([(x0 + 24, gy), (x0 + page_w - 10, gy)], fill=with_alpha(INK_SOFT, 30), width=1)

        rng = random.Random(3000 + index)
        for _ in range(16):
            tx = x0 + 26 + rng.randint(0, 5) * step
            ty = y0 + 16 + rng.randint(0, 12) * step
            if ty > y0 + page_h - 20:
                continue
            if rng.random() < 0.5:
                d.rectangle(
                    [tx, ty, min(tx + step * rng.randint(1, 3), x0 + page_w - 10), ty + 6],
                    fill=INK,
                )
            else:
                d.rectangle(
                    [tx, ty, tx + 6, min(ty + step * rng.randint(1, 3), y0 + page_h - 10)],
                    fill=INK,
                )

        if index in rust_indices:
            rust_veins(d, (x0 + 30, y0 + page_h * 0.45), seed=9000 + index, count=18, spread=page_w * 0.55)
            for _ in range(18):
                rx = x0 + 18 + rng.randint(0, max(1, page_w - 50))
                ry = y0 + 14 + rng.randint(0, max(1, page_h - 40))
                d.ellipse(
                    [rx, ry, rx + rng.randint(18, 50), ry + rng.randint(12, 30)],
                    fill=with_alpha(RUST, 110 + rng.randint(0, 85)),
                )
        ghost.append((x0 + page_w * 0.5, y0 + page_h * (0.35 + 0.1 * (index % 3))))

    for i in range(per_side):
        draw_page(i, margin_x + i * (page_w + page_gap))
    right0 = spine_x + spine_w // 2 + gutter
    for i in range(per_side):
        draw_page(per_side + i, right0 + i * (page_w + page_gap))

    d.rectangle([spine_x - spine_w // 2, margin_y - 28, spine_x + spine_w // 2, h - margin_y + 28], fill=INK)
    d.rectangle([spine_x - 4, margin_y - 28, spine_x + 4, h - margin_y + 28], fill=RUST_DEEP)
    for yy in range(margin_y, h - margin_y, 26):
        d.line([(spine_x - 10, yy), (spine_x + 10, yy)], fill=with_alpha(PAPER_DEEP, 100), width=1)

    if len(ghost) == 6:
        dashed_polyline(d, ghost, with_alpha(SLATE_SOFT, 195), width=3, dash=14, gap=8)
        for p in ghost:
            d.ellipse([p[0] - 5, p[1] - 5, p[0] + 5, p[1] + 5], fill=with_alpha(CHALK, 230))

    img = Image.alpha_composite(img, overlay)
    return img.convert("RGB")


def make_library_logo() -> Image.Image:
    w, h = 1280, 720
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(img)
    wordmark_block(
        d,
        w / 2,
        h / 2 - 40,
        title_size=96,
        tag_size=28,
        tracking=-1.5,
        underline=True,
        tagline=True,
        align="center",
    )
    return img


def make_community_icon() -> Image.Image:
    w, h = 184, 184
    img = paper_base(w, h, seed=66, grain=0.02)
    d = ImageDraw.Draw(img, "RGBA")
    cells = 7
    pad = 10
    cell = (w - 2 * pad) / cells
    for i in range(cells + 1):
        x = pad + i * cell
        d.line([(x, pad), (x, h - pad)], fill=with_alpha(INK_SOFT, 160), width=1)
        d.line([(pad, x), (h - pad, x)], fill=with_alpha(INK_SOFT, 160), width=1)

    def cell_rect(cx: int, cy: int):
        x0 = pad + cx * cell
        y0 = pad + cy * cell
        return [x0 + 1, y0 + 1, x0 + cell - 1, y0 + cell - 1]

    d.rectangle(cell_rect(3, 2), fill=INK)
    d.rectangle(cell_rect(2, 3), fill=RUST)
    d.rectangle(cell_rect(3, 3), fill=with_alpha(RUST_DEEP, 200))
    r = cell_rect(2, 3)
    d.ellipse([r[0] - 3, r[3] - 6, r[2] + 6, r[3] + 8], fill=with_alpha(RUST, 120))
    rust_veins(d, (r[0], r[1]), seed=77, count=5, spread=22)
    return img.convert("RGB")


def make_page_background() -> Image.Image:
    w, h = 1438, 810
    img = paper_base(w, h, seed=77, grain=0.05)
    overlay = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(overlay)
    draw_grid(d, w, h, 28, with_alpha(INK_SOFT, 18))
    draw_ledger_subgrid(d, (40, 40, w - 40, h - 40), step=4, color=with_alpha(INK_SOFT, 10))
    sx = w // 2
    d.rectangle([sx - 6, 40, sx + 6, h - 40], fill=with_alpha(INK_SOFT, 55))
    d.rectangle([sx - 2, 40, sx + 2, h - 40], fill=with_alpha(RUST, 40))
    for i in range(40):
        a = max(0, 28 - i)
        d.line([(sx - 20 - i, 0), (sx - 20 - i, h)], fill=with_alpha(INK_SOFT, a), width=1)
        d.line([(sx + 20 + i, 0), (sx + 20 + i, h)], fill=with_alpha(INK_SOFT, a), width=1)
    d.line([(80, 64), (w - 80, 64)], fill=with_alpha(INK_SOFT, 50), width=1)
    d.line([(80, h - 64), (w - 80, h - 64)], fill=with_alpha(INK_SOFT, 40), width=1)
    img = Image.alpha_composite(img, overlay)
    return img.filter(ImageFilter.GaussianBlur(radius=0.4)).convert("RGB")


def assert_no_purple(img: Image.Image, name: str) -> None:
    """Reject assets that drift into purple/magenta territory."""
    sample = img.convert("RGBA").resize((64, 64), Image.Resampling.BOX)
    px = sample.load()
    for y in range(sample.height):
        for x in range(sample.width):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            if r > 90 and b > 90 and g < r * 0.75 and g < b * 0.75 and (r + b) > 220:
                raise SystemExit(f"Purple/magenta detected in {name} at sample ({x},{y})={(r,g,b)}")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    jobs = [
        ("header_460x215.png", make_header, (460, 215)),
        ("main_616x353.png", make_main, (616, 353)),
        ("small_231x87.png", make_small, (231, 87)),
        ("vertical_374x448.png", make_vertical, (374, 448)),
        ("library_hero_1920x620.png", make_library_hero, (1920, 620)),
        ("library_logo_1280x720.png", make_library_logo, (1280, 720)),
        ("community_icon_184x184.png", make_community_icon, (184, 184)),
        ("page_background_1438x810.png", make_page_background, (1438, 810)),
    ]
    for name, fn, size in jobs:
        im = fn()
        if im.size != size:
            raise SystemExit(f"{name}: got {im.size}, want {size}")
        assert_no_purple(im, name)
        path = OUT / name
        im.save(path, "PNG", optimize=True)
        print(f"wrote {path.relative_to(ROOT)} {im.size} {im.mode}")


if __name__ == "__main__":
    main()
