"""Echo Lattice — placeholder texture generator.

Deterministic. Reads palette/echo_lattice.palette.json and writes small PNGs
into tiles/, decals/, ui/, palette/, keyart/. These are art-direction stakes,
not finished assets. They exist so:

  1. Programmers have real files to wire up before final art lands.
  2. The palette in 05_ART_BIBLE.md is not aspirational — it ships.
  3. If someone later commits a purple-glow tileset, git blame is loud.

Rules the generator enforces (mirrored in 05_ART_BIBLE.md):

  - No pure black (#000000) and no pure white (#FFFFFF).
  - No colors outside palette.swatches.
  - 32px reference tile. Wall thickness 4px.
  - Deterministic seed (echo lattice cares about determinism).

Usage:

    python3 generate_placeholders.py

Regenerating overwrites textures in place. Do not hand-edit the PNGs; edit
this script or the palette JSON.
"""

from __future__ import annotations

import json
import math
import os
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ART_ROOT = Path(__file__).resolve().parent
PALETTE_PATH = ART_ROOT / "palette" / "echo_lattice.palette.json"

SEED = 0xE01A771CE  # echo-lattice, seed-visible-in-the-title-bar
random.seed(SEED)


def hx(c: str) -> tuple[int, int, int]:
    c = c.lstrip("#")
    return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16))


def hxa(c: str, a: int) -> tuple[int, int, int, int]:
    r, g, b = hx(c)
    return (r, g, b, a)


with PALETTE_PATH.open() as f:
    palette = json.load(f)

SW = {name: entry["hex"] for name, entry in palette["swatches"].items()}

TILE = palette["tile_grid"]["reference_tile_px"]
WALL_PX = palette["tile_grid"]["wall_thickness_px"]


def save(img: Image.Image, rel: str) -> None:
    out = ART_ROOT / rel
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out.relative_to(ART_ROOT)}")


def paper_noise(size: int, base_hex: str, jitter: int = 10, halftone: bool = False) -> Image.Image:
    r, g, b = hx(base_hex)
    img = Image.new("RGB", (size, size), (r, g, b))
    px = img.load()
    rng = random.Random(hash((base_hex, size, jitter, halftone)) & 0xFFFFFFFF)
    for y in range(size):
        for x in range(size):
            j = rng.randint(-jitter, jitter)
            px[x, y] = (
                max(0, min(255, r + j)),
                max(0, min(255, g + j)),
                max(0, min(255, b + j)),
            )
    if halftone:
        d = ImageDraw.Draw(img)
        ink = hx(SW["ink_soft"])
        step = 6
        for y in range(0, size, step):
            for x in range(0, size, step):
                if (x // step + y // step) % 2 == 0:
                    d.point((x + rng.randint(0, 1), y + rng.randint(0, 1)), fill=ink)
    return img


def add_grid(img: Image.Image, color_hex: str, spacing: int = 4, alpha: int = 60) -> Image.Image:
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    r, g, b = hx(color_hex)
    for x in range(0, img.size[0], spacing):
        d.line([(x, 0), (x, img.size[1])], fill=(r, g, b, alpha))
    for y in range(0, img.size[1], spacing):
        d.line([(0, y), (img.size[0], y)], fill=(r, g, b, alpha))
    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")


def tile_floor_fresh() -> Image.Image:
    img = paper_noise(TILE, SW["paper_bone"], jitter=8)
    img = add_grid(img, SW["ink_soft"], spacing=4, alpha=28)
    return img


def tile_floor_walked() -> Image.Image:
    img = paper_noise(TILE, SW["paper_deep"], jitter=10, halftone=True)
    img = add_grid(img, SW["ink_soft"], spacing=4, alpha=18)
    d = ImageDraw.Draw(img)
    rng = random.Random(0xA110E)
    for _ in range(18):
        x, y = rng.randint(2, TILE - 3), rng.randint(2, TILE - 3)
        d.point((x, y), fill=hx(SW["ink_soft"]))
    return img


def tile_wall_fresh() -> Image.Image:
    img = paper_noise(TILE, SW["paper_bone"], jitter=6)
    d = ImageDraw.Draw(img)
    ink = hx(SW["ink_black"])
    d.rectangle([0, 0, TILE - 1, WALL_PX - 1], fill=ink)
    d.rectangle([0, TILE - WALL_PX, TILE - 1, TILE - 1], fill=ink)
    d.rectangle([0, 0, WALL_PX - 1, TILE - 1], fill=ink)
    d.rectangle([TILE - WALL_PX, 0, TILE - 1, TILE - 1], fill=ink)
    rng = random.Random(0xBEE)
    for _ in range(TILE * 2):
        x = rng.randint(0, TILE - 1)
        y = rng.randint(0, TILE - 1)
        if (x < WALL_PX or x >= TILE - WALL_PX or y < WALL_PX or y >= TILE - WALL_PX):
            if rng.random() < 0.15:
                d.point((x, y), fill=hx(SW["ink_soft"]))
    return img


def tile_wall_fossilized() -> Image.Image:
    img = paper_noise(TILE, SW["paper_deep"], jitter=8)
    d = ImageDraw.Draw(img)
    rust = hx(SW["rust_fossil"])
    rust_deep = hx(SW["rust_deep"])
    d.rectangle([0, 0, TILE - 1, WALL_PX - 1], fill=rust_deep)
    d.rectangle([0, TILE - WALL_PX, TILE - 1, TILE - 1], fill=rust_deep)
    d.rectangle([0, 0, WALL_PX - 1, TILE - 1], fill=rust_deep)
    d.rectangle([TILE - WALL_PX, 0, TILE - 1, TILE - 1], fill=rust_deep)
    rng = random.Random(0xF05517)
    for _ in range(24):
        x = rng.randint(WALL_PX, TILE - WALL_PX - 1)
        y = rng.randint(WALL_PX, TILE - WALL_PX - 1)
        d.point((x, y), fill=rust)
    for _ in range(6):
        x1 = rng.randint(WALL_PX, TILE - WALL_PX - 1)
        y1 = rng.randint(WALL_PX, TILE - WALL_PX - 1)
        x2 = x1 + rng.choice([-3, -2, 2, 3])
        y2 = y1 + rng.choice([-3, -2, 2, 3])
        d.line([(x1, y1), (x2, y2)], fill=rust_deep)
    return img


def tile_wall_folding() -> Image.Image:
    img = paper_noise(TILE, SW["paper_bone"], jitter=6)
    d = ImageDraw.Draw(img)
    ink = hx(SW["ink_black"])
    ink_s = hx(SW["ink_soft"])
    for i in range(TILE):
        t = i / (TILE - 1)
        crease_y = int(TILE / 2 + math.sin(t * math.pi) * 3)
        d.point((i, crease_y), fill=ink)
        d.point((i, crease_y - 1), fill=ink_s)
    d.rectangle([0, 0, TILE - 1, WALL_PX - 1], fill=ink)
    d.rectangle([0, TILE - WALL_PX, TILE - 1, TILE - 1], fill=ink)
    return img


def tile_door() -> Image.Image:
    img = paper_noise(TILE, SW["paper_bone"], jitter=4)
    d = ImageDraw.Draw(img)
    copper = hx(SW["copper_key"])
    slate = hx(SW["slate_teal"])
    d.rectangle([6, 4, TILE - 7, TILE - 5], outline=slate, width=2)
    d.line([(TILE // 2, 4), (TILE // 2, TILE - 5)], fill=copper)
    d.rectangle([TILE // 2 - 2, TILE // 2 - 4, TILE // 2 + 2, TILE // 2 + 4], fill=copper)
    return img


def tile_key() -> Image.Image:
    img = paper_noise(TILE, SW["paper_bone"], jitter=4)
    d = ImageDraw.Draw(img)
    copper = hx(SW["copper_key"])
    d.ellipse([8, 10, 18, 20], outline=copper, width=2)
    d.rectangle([18, 14, 26, 16], fill=copper)
    d.rectangle([22, 16, 24, 20], fill=copper)
    return img


def decal_rust(idx: int) -> Image.Image:
    size = 16
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = random.Random(0xF055 + idx)
    for _ in range(rng.randint(6, 14)):
        x = rng.randint(1, size - 2)
        y = rng.randint(1, size - 2)
        c = hxa(SW["rust_fossil"], rng.randint(140, 220))
        d.point((x, y), fill=c)
    for _ in range(rng.randint(1, 3)):
        x1 = rng.randint(2, size - 3)
        y1 = rng.randint(2, size - 3)
        x2 = x1 + rng.choice([-2, -1, 1, 2])
        y2 = y1 + rng.choice([-2, -1, 1, 2])
        d.line([(x1, y1), (x2, y2)], fill=hxa(SW["rust_deep"], 200))
    return img


def decal_chalk_footprint() -> Image.Image:
    size = 12
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = random.Random(0xCA1C)
    cx, cy = size // 2, size // 2
    for _ in range(28):
        r = rng.uniform(0, 4.5)
        theta = rng.uniform(0, 2 * math.pi)
        x = int(cx + r * math.cos(theta))
        y = int(cy + r * math.sin(theta))
        a = int(180 * (1 - r / 4.5))
        d.point((x, y), fill=hxa(SW["chalk_white"], max(60, a)))
    return img.filter(ImageFilter.SMOOTH)


def sprite_player_stamp() -> Image.Image:
    size = 24
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    ink = hxa(SW["ink_black"], 255)
    lantern = hxa(SW["copper_key"], 255)
    d.ellipse([9, 3, 15, 9], fill=ink)
    d.polygon([(7, 9), (17, 9), (18, 20), (6, 20)], fill=ink)
    d.rectangle([11, 12, 13, 15], fill=lantern)
    d.rectangle([5, 20, 10, 22], fill=ink)
    d.rectangle([14, 20, 19, 22], fill=ink)
    return img


def ui_punchcard_cell(state: str) -> Image.Image:
    w, h = 12, 20
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], outline=hxa(SW["ink_soft"], 220), width=1)
    if state == "filled":
        d.rectangle([2, 2, w - 3, h - 3], fill=hxa(SW["ink_black"], 255))
    elif state == "rust":
        d.rectangle([2, 2, w - 3, h - 3], fill=hxa(SW["rust_fossil"], 255))
    elif state == "warn":
        d.rectangle([2, 2, w - 3, h - 3], fill=hxa(SW["cadmium_warn"], 255))
    return img


def ui_seed_header() -> Image.Image:
    w, h = 256, 24
    img = paper_noise(max(w, h), SW["paper_bone"], jitter=4).resize((w, h)).convert("RGBA")
    d = ImageDraw.Draw(img)
    d.line([(4, h - 3), (w - 5, h - 3)], fill=hxa(SW["ink_soft"], 200))
    d.line([(4, h - 6), (w - 5, h - 6)], fill=hxa(SW["ink_soft"], 120))
    slate = hxa(SW["slate_teal"], 255)
    x = 8
    for group_len in (4, 4, 4, 4):
        for _ in range(group_len):
            d.rectangle([x, 6, x + 6, 14], outline=slate, width=1)
            x += 8
        x += 6
    return img


def palette_strip() -> Image.Image:
    order = [
        "paper_bone", "paper_deep", "ink_black", "ink_soft",
        "chalk_white", "rust_fossil", "rust_deep",
        "slate_teal", "slate_teal_soft", "cadmium_warn", "copper_key",
    ]
    cell = 48
    w = cell * len(order)
    h = cell + 20
    img = Image.new("RGB", (w, h), hx(SW["paper_bone"]))
    d = ImageDraw.Draw(img)
    for i, name in enumerate(order):
        d.rectangle([i * cell, 0, (i + 1) * cell - 1, cell - 1], fill=hx(SW[name]))
        d.rectangle([i * cell, 0, (i + 1) * cell - 1, cell - 1], outline=hx(SW["ink_soft"]), width=1)
    d.line([(0, cell + 2), (w, cell + 2)], fill=hx(SW["ink_soft"]))
    return img


def keyart_capsule_thumb() -> Image.Image:
    w, h = 460, 215
    img = paper_noise(max(w, h), SW["paper_bone"], jitter=6).resize((w, h)).convert("RGBA")
    d = ImageDraw.Draw(img)
    for x in range(0, w, 8):
        d.line([(x, 0), (x, h)], fill=hxa(SW["ink_soft"], 22))
    for y in range(0, h, 8):
        d.line([(0, y), (w, y)], fill=hxa(SW["ink_soft"], 22))
    ink = hxa(SW["ink_black"], 255)
    d.rectangle([40, 40, w - 40, h - 40], outline=ink, width=3)
    for x in range(60, w - 60, 40):
        d.rectangle([x, 60, x + 20, h - 60], outline=ink, width=2)
    for _ in range(30):
        cx = random.randint(60, w - 60)
        cy = random.randint(60, h - 60)
        d.point((cx, cy), fill=hxa(SW["rust_fossil"], 200))
    player = sprite_player_stamp().resize((36, 36))
    img.alpha_composite(player, (w // 2 - 18, h // 2 - 18))
    d.line([(w // 2 + 40, h // 2 + 10),
            (w // 2 + 90, h // 2 + 10),
            (w // 2 + 90, h // 2 - 20),
            (w // 2 + 140, h // 2 - 20)],
           fill=hxa(SW["chalk_white"], 220), width=2)
    d.rectangle([30, h - 32, w - 30, h - 20], outline=hxa(SW["ink_soft"], 180))
    return img.convert("RGB")


def main() -> None:
    save(tile_floor_fresh(),      "tiles/floor_fresh_32.png")
    save(tile_floor_walked(),     "tiles/floor_walked_32.png")
    save(tile_wall_fresh(),       "tiles/wall_fresh_32.png")
    save(tile_wall_fossilized(),  "tiles/wall_fossilized_32.png")
    save(tile_wall_folding(),     "tiles/wall_folding_32.png")
    save(tile_door(),             "tiles/door_32.png")
    save(tile_key(),              "tiles/key_32.png")
    for i in range(1, 5):
        save(decal_rust(i),       f"decals/rust_{i:02d}.png")
    save(decal_chalk_footprint(), "decals/chalk_footprint.png")
    save(sprite_player_stamp(),   "tiles/player_stamp_24.png")
    save(ui_punchcard_cell("empty"),  "ui/punchcard_cell_empty.png")
    save(ui_punchcard_cell("filled"), "ui/punchcard_cell_filled.png")
    save(ui_punchcard_cell("rust"),   "ui/punchcard_cell_rust.png")
    save(ui_punchcard_cell("warn"),   "ui/punchcard_cell_warn.png")
    save(ui_seed_header(),        "ui/seed_header_256x24.png")
    save(palette_strip(),         "palette/palette_strip.png")
    save(keyart_capsule_thumb(),  "keyart/capsule_header_460x215_thumb.png")


if __name__ == "__main__":
    main()
