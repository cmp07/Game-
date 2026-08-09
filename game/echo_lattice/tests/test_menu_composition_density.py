#!/usr/bin/env python3
"""CI gate: title menu dense composition @ 1920×1080.

Fails if:
  - Brand column / Field Index anchors drift off the 52/42 hard spec
  - Measured empty (no ink/ui layout mass) ≥ 28% of the inner page
  - LEFT (verso) pixel empty mass ≥ 22%
  - Gameplay film plate missing / too short on the verso
  - Preview media rect area < 18% of viewport (postage-stamp regression)
  - SubViewport stays board-native while the plate Control is larger (hollow plate)
  - Same seed string drawn twice on the title (header + film-plate footer)
  - Field Index rows stretch with sparse leading
  - Store slate 02_brand_main_menu.png lacks brand + film preview + Field Index
    or shows cream hollow inside the plate (>8% empty-inside-plate)
"""

from __future__ import annotations

import re
import struct
import unittest
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MENU = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
ART = (ROOT / "scripts" / "art_kit.gd").read_text(encoding="utf-8")
BOOT = (ROOT / "scripts" / "boot_title.gd").read_text(encoding="utf-8")
LOCALE = (ROOT / "locale" / "echo_lattice.csv").read_text(encoding="utf-8")
PREVIEW = (ROOT / "scripts" / "ui" / "menu_gameplay_preview.gd").read_text(encoding="utf-8")
SHOT = ROOT.parents[1] / "docs" / "RELEASE" / "screenshots" / "02_brand_main_menu.png"

VP_W, VP_H = 1920.0, 1080.0


def _const_float(name: str, src: str = MENU) -> float:
    m = re.search(rf"const {name}: float = ([0-9.]+)", src)
    assert m, f"missing const {name}"
    return float(m.group(1))


def _const_int(name: str, src: str = MENU) -> int:
    m = re.search(rf"const {name}: int = ([0-9]+)", src)
    assert m, f"missing const {name}"
    return int(m.group(1))


def _layout_rects() -> dict:
    """Mirror menu.gd composition_layout math at 1920×1080 (no Godot required)."""
    verso = _const_float("VERSO_FRAC")
    recto = _const_float("RECTO_FRAC")
    brand_min = _const_int("BRAND_MIN_PX")
    mx = _const_float("PAGE_MARGIN_X")
    my = _const_float("PAGE_MARGIN_Y")
    specimen_gap = _const_float("SPECIMEN_GAP")
    outer = (mx, my, VP_W - 2 * mx, VP_H - 2 * my)
    left_w = outer[2] * verso
    right_w = outer[2] * recto
    gutter = max(12.0, outer[2] - left_w - right_w)
    left = (outer[0], outer[1], left_w, outer[3])
    right = (outer[0] + outer[2] - right_w, outer[1], right_w, outer[3])
    brand_px = max(brand_min, 92)
    brand_x = left[0] + 36.0
    brand_top = left[1] + 56.0
    brand_w = min(560.0, left[2] - 72.0)
    brand_block = (brand_x, brand_top, brand_w, float(brand_px) + 62.0)
    plate_x = brand_x - 4.0
    plate_w = max(200.0, left[0] + left[2] - plate_x - 20.0)
    preview_top = brand_block[1] + brand_block[3] + specimen_gap
    preview_h = max(200.0, left[1] + left[3] - preview_top - 14.0)
    preview = (plate_x, preview_top, plate_w, preview_h)
    side_pad, top_pad, bot_pad = 16.0, 20.0, 18.0
    card = (
        right[0] + side_pad,
        right[1] + top_pad,
        max(240.0, right[2] - side_pad * 2.0),
        max(300.0, right[3] - top_pad - bot_pad),
    )

    def area(r: tuple[float, float, float, float]) -> float:
        return r[2] * r[3]

    occupied = area(brand_block) + area(preview) + area(card) + gutter * outer[3] * 0.35
    empty = 1.0 - occupied / max(1.0, area(outer))
    verso_empty = 1.0 - (area(brand_block) + area(preview)) / max(1.0, area(left))
    return {
        "outer": outer,
        "left": left,
        "right": right,
        "brand_block": brand_block,
        "preview": preview,
        "field_index": card,
        "brand_px": brand_px,
        "verso_frac": left_w / outer[2],
        "recto_frac": right_w / outer[2],
        "index_width_frac": card[2] / VP_W,
        "empty_frac": empty,
        "verso_empty_frac": verso_empty,
        "specimen_gap": specimen_gap,
        "preview_verso_frac": preview[3] / left[3],
    }


def _read_png_luma(path: Path) -> tuple[int, int, list[bytearray], int]:
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    idat = b""
    w = h = bpp = 0
    off = 8
    while off < len(data):
        ln = struct.unpack(">I", data[off : off + 4])[0]
        typ = data[off + 4 : off + 8]
        chunk = data[off + 8 : off + 8 + ln]
        off += 12 + ln
        if typ == b"IHDR":
            w, h = struct.unpack(">II", chunk[:8])
            bpp = {2: 3, 6: 4}[chunk[9]]
        elif typ == b"IDAT":
            idat += chunk
        elif typ == b"IEND":
            break
    raw = zlib.decompress(idat)
    stride = w * bpp
    rows: list[bytearray] = []
    i = 0
    prev = bytearray(stride)
    for _y in range(h):
        filt = raw[i]
        i += 1
        row = bytearray(raw[i : i + stride])
        i += stride
        if filt == 1:
            for x in range(stride):
                row[x] = (row[x] + (row[x - bpp] if x >= bpp else 0)) & 255
        elif filt == 2:
            for x in range(stride):
                row[x] = (row[x] + prev[x]) & 255
        elif filt == 3:
            for x in range(stride):
                left = row[x - bpp] if x >= bpp else 0
                row[x] = (row[x] + ((left + prev[x]) // 2)) & 255
        elif filt == 4:
            for x in range(stride):
                a = row[x - bpp] if x >= bpp else 0
                b = prev[x]
                c = prev[x - bpp] if x >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                row[x] = (row[x] + pr) & 255
        rows.append(row)
        prev = row
    return w, h, rows, bpp


class TestMenuCompositionDensity(unittest.TestCase):
    def test_hard_anchors_present(self) -> None:
        for token in (
            "const VERSO_FRAC",
            "const RECTO_FRAC",
            "const BRAND_MIN_PX",
            "const MAX_EMPTY_FRAC",
            "const MAX_VERSO_EMPTY_FRAC",
            "const SPECIMEN_GAP",
            "const PREVIEW_VERSO_FRAC",
            "const INDEX_ROW_H",
            "func composition_layout",
            'tr("brand.title")',
            'tr("brand.tagline")',
            '"sharp_edge": true',
            "ArtKit.draw_ledger_film_plate",
            "_ensure_gameplay_preview",
        ):
            self.assertIn(token, MENU, msg=token)
        self.assertLessEqual(_const_float("MAX_EMPTY_FRAC"), 0.28)
        self.assertLessEqual(_const_float("MAX_VERSO_EMPTY_FRAC"), 0.22)
        self.assertGreaterEqual(_const_int("BRAND_MIN_PX"), 72)
        self.assertGreaterEqual(_const_float("INDEX_ROW_H"), 36.0)
        self.assertLessEqual(_const_float("INDEX_ROW_H"), 44.0)
        self.assertLessEqual(_const_float("SPECIMEN_GAP"), 16.0)
        self.assertGreaterEqual(_const_float("PREVIEW_VERSO_FRAC"), 0.55)
        self.assertLessEqual(_const_float("PREVIEW_VERSO_FRAC"), 0.70)
        verso = _const_float("VERSO_FRAC")
        recto = _const_float("RECTO_FRAC")
        self.assertGreaterEqual(verso, 0.48)
        self.assertLessEqual(verso, 0.56)
        self.assertGreaterEqual(recto, 0.40)
        self.assertLessEqual(recto, 0.48)

    def test_layout_rects_density_under_28(self) -> None:
        lay = _layout_rects()
        self.assertGreaterEqual(lay["brand_px"], 72)
        self.assertGreaterEqual(lay["verso_frac"], 0.48)
        self.assertLessEqual(lay["verso_frac"], 0.56)
        self.assertGreaterEqual(lay["recto_frac"], 0.40)
        self.assertLessEqual(lay["recto_frac"], 0.48)
        self.assertGreaterEqual(lay["index_width_frac"], 0.40)
        self.assertLessEqual(lay["index_width_frac"], 0.48)
        self.assertLess(
            lay["empty_frac"],
            _const_float("MAX_EMPTY_FRAC"),
            msg=f"empty_frac={lay['empty_frac']:.3f} — title still a cream void",
        )
        self.assertLess(
            lay["verso_empty_frac"],
            _const_float("MAX_VERSO_EMPTY_FRAC"),
            msg=f"verso_empty_frac={lay['verso_empty_frac']:.3f} — left leaf still empty",
        )
        self.assertLessEqual(lay["specimen_gap"], 16.0)
        preview = lay["preview"]
        self.assertGreaterEqual(preview[2], 700.0, msg="film plate too narrow")
        self.assertGreaterEqual(preview[3], 520.0, msg="film plate too short — cream band remains")
        self.assertGreaterEqual(lay["preview_verso_frac"], 0.55)
        self.assertLessEqual(lay["preview_verso_frac"], 0.80)
        card = lay["field_index"]
        self.assertGreaterEqual(card[3], 900.0)

    def test_dense_row_pitch_not_stretched(self) -> None:
        """Actions pack as a compact block — never SIZE_EXPAND_FILL stretch."""
        self.assertIn("Control.SIZE_SHRINK_BEGIN", MENU)
        self.assertIn("INDEX_ROW_H", MENU)
        self.assertIn("_field_index_block_height", MENU)
        self.assertNotIn("SIZE_EXPAND_FILL if compact else Control.SIZE_EXPAND_FILL", MENU)
        apply = re.search(
            r"func _apply_index_row_metrics\([\s\S]*?\nfunc ",
            MENU,
        )
        self.assertIsNotNone(apply)
        body = apply.group(0)
        self.assertNotIn("size_flags_vertical = Control.SIZE_EXPAND_FILL", body)
        self.assertIn("SIZE_SHRINK_BEGIN", body)
        self.assertNotIn("clampf(even,", body)

    def test_film_plate_and_preview_hooks(self) -> None:
        """Gameplay preview is the left visual anchor — no giant static maze specimen."""
        self.assertIn("func draw_ledger_film_plate", ART)
        self.assertIn("registration", ART.lower())
        self.assertIn("func film_plate_media_rect", ART)
        self.assertIn("menu_preview_mode", PREVIEW)
        self.assertIn("pause_preview", PREVIEW)
        self.assertIn("MOUSE_FILTER_IGNORE", PREVIEW)
        self.assertIn("SubViewport", PREVIEW)
        self.assertIn("sync_media_rect", PREVIEW)
        self.assertIn("_cover_scale_chamber", PREVIEW)
        self.assertIn("sync_media_rect", MENU)
        # Must not FULL_RECT the preview Control against the menu (fought media sizing).
        self.assertNotIn(
            "set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)",
            PREVIEW.split("func _build_chrome")[0],
            msg="GameplayPreview self must stay top-left; menu drives media well size",
        )
        # Giant static habit silhouette must not own the title verso anymore.
        self.assertNotIn("ArtKit.draw_habit_silhouette", MENU)
        self.assertNotIn("ArtKit.draw_seal_stamp", MENU)
        for src, label in ((MENU, "menu"), (BOOT, "boot")):
            self.assertNotIn('"caption": "FIELD"', src, msg=label)
            self.assertNotIn("SURVEY SEAL", src, msg=label)
        self.assertNotIn("SURVEY SEAL", LOCALE)

    def test_preview_media_area_and_no_twin_seed(self) -> None:
        """Preview must dominate the verso; seed strip once on the title."""
        lay = _layout_rects()
        preview = lay["preview"]
        media_w = max(20.0, preview[2] - 20.0)
        media_h = max(20.0, preview[3] - 32.0)
        media_frac = (media_w * media_h) / (VP_W * VP_H)
        self.assertGreaterEqual(
            media_frac,
            0.18,
            msg=f"preview media area frac={media_frac:.3f} < 0.18 — postage stamp",
        )
        # Board-native SubViewport must be cover-scaled into the well (not left at 768×448).
        self.assertIn("BOARD_W", PREVIEW)
        self.assertIn("_cover_scale_chamber", PREVIEW)
        self.assertIn("sync_media_rect", PREVIEW)
        # ONE seed line — micro header only; film plate must not reprint menu.seed_strip.
        draw = re.search(r"func _draw\(\) -> void:\n([\s\S]*?)\nfunc ", MENU)
        self.assertIsNotNone(draw)
        body = draw.group(1)
        seed_hits = len(re.findall(r'tr\("menu\.seed_strip"\)', body))
        self.assertEqual(
            seed_hits,
            1,
            msg=f"menu.seed_strip drawn {seed_hits}× on title — twin seed bars",
        )
        plate_call = re.search(
            r"ArtKit\.draw_ledger_film_plate\([\s\S]*?\)",
            body,
        )
        self.assertIsNotNone(plate_call)
        self.assertNotIn(
            "seed_strip",
            plate_call.group(0),
            msg="film plate footer must not repeat the header seed strip",
        )

    def test_brand_slate_shows_brand_film_preview_and_field_index(self) -> None:
        if not SHOT.is_file():
            self.skipTest("02_brand_main_menu.png missing — capture before merge")
        w, h, rows, bpp = _read_png_luma(SHOT)
        self.assertEqual((w, h), (1920, 1080))

        def rgb(x: int, y: int) -> tuple[int, int, int]:
            r = rows[y]
            j = x * bpp
            return r[j], r[j + 1], r[j + 2]

        def lum(x: int, y: int) -> int:
            r, g, b = rgb(x, y)
            return (r + g + b) // 3

        brand = sum(
            1
            for y in range(60, 220, 2)
            for x in range(50, 720, 2)
            if lum(x, y) < 150
        )
        self.assertGreater(brand, 400, msg="ECHO LATTICE brand ink missing on left")

        paper_ref = (239, 230, 209)
        tile = 20
        empty_tiles = 0
        total_tiles = 0
        for y0 in range(14, 1060, tile):
            for x0 in range(20, 960, tile):
                total_tiles += 1
                samples: list[int] = []
                near_paper = 0
                n = 0
                for y in range(y0, min(y0 + tile, 1066), 2):
                    for x in range(x0, min(x0 + tile, 980), 2):
                        n += 1
                        samples.append(lum(x, y))
                        r, g, b = rgb(x, y)
                        dist = (
                            abs(r - paper_ref[0])
                            + abs(g - paper_ref[1])
                            + abs(b - paper_ref[2])
                        )
                        if dist < 50 and lum(x, y) > 195:
                            near_paper += 1
                if not samples:
                    continue
                spread = max(samples) - min(samples)
                if near_paper / max(1, n) > 0.85 and spread < 40:
                    empty_tiles += 1
        empty_frac = empty_tiles / max(1, total_tiles)
        # Brand type sits on paper by design; film plate has paper floors between ink walls.
        # Gate hollowness looser than the old solid-maze specimen, but reject cream voids.
        self.assertLess(
            empty_frac,
            0.42,
            msg=f"verso tile empty_mass={empty_frac:.3f} ≥ 0.42 — left page still hollow",
        )

        # Film-plate / gameplay zone (lower ~60%) must carry board ink (walls / player / fossils).
        maze_empty = 0
        maze_total = 0
        for y in range(400, 1040, 2):
            for x in range(60, 940, 2):
                maze_total += 1
                r, g, b = rgb(x, y)
                dist = abs(r - paper_ref[0]) + abs(g - paper_ref[1]) + abs(b - paper_ref[2])
                if dist < 45 and lum(x, y) > 190:
                    maze_empty += 1
        self.assertLess(
            maze_empty / max(1, maze_total),
            0.55,
            msg="gameplay film plate zone still cream-hollow",
        )
        # Empty-inside-plate gate: cream tiles inside the media well must stay < 8%.
        plate_empty = 0
        plate_total = 0
        for y in range(270, 1020, 3):
            for x in range(70, 900, 3):
                plate_total += 1
                r, g, b = rgb(x, y)
                dist = abs(r - paper_ref[0]) + abs(g - paper_ref[1]) + abs(b - paper_ref[2])
                if dist < 40 and lum(x, y) > 200:
                    plate_empty += 1
        plate_empty_frac = plate_empty / max(1, plate_total)
        self.assertLess(
            plate_empty_frac,
            0.08,
            msg=f"empty-inside-plate={plate_empty_frac:.3f} > 0.08 — hollow cream well",
        )
        # Preview rect must own ≥18% of the full frame (not a 768×448 stamp).
        dark_cells = [
            (x, y)
            for y in range(240, 1040, 2)
            for x in range(50, 960, 2)
            if lum(x, y) < 90
        ]
        self.assertGreater(len(dark_cells), 2000, msg="preview board ink missing")
        xs = [p[0] for p in dark_cells]
        ys = [p[1] for p in dark_cells]
        island_w = max(xs) - min(xs)
        island_h = max(ys) - min(ys)
        island_frac = (island_w * island_h) / (w * h)
        self.assertGreaterEqual(
            island_frac,
            0.18,
            msg=f"preview island area frac={island_frac:.3f} < 0.18 (w={island_w} h={island_h})",
        )
        # Native board stamp regression — must not remain ~768×448 in a tall plate.
        self.assertFalse(
            island_w < 820 and island_h < 500,
            msg=f"preview still board-native stamp {island_w}×{island_h}",
        )
        preview_ink = sum(
            1
            for y in range(280, 1020, 3)
            for x in range(80, 900, 3)
            if lum(x, y) < 120
        )
        self.assertGreater(preview_ink, 3500, msg="gameplay preview optical weight missing on verso")

        # Twin seed bars: footer band under the plate must not reprint header seed ink.
        header_seed = sum(
            1 for y in range(18, 40) for x in range(40, 720, 2) if lum(x, y) < 130
        )
        footer_seed = sum(
            1 for y in range(1035, 1065) for x in range(40, 720, 2) if lum(x, y) < 130
        )
        self.assertGreater(header_seed, 20, msg="verso micro header seed line missing")
        self.assertLess(
            footer_seed,
            header_seed * 0.85 + 30,
            msg=f"twin seed bars — footer ink={footer_seed} vs header={header_seed}",
        )

        left = None
        for x in range(1040, 1280):
            if lum(x, 220) < 100:
                left = x
                break
        self.assertIsNotNone(left, msg="Field Index left edge missing")
        self.assertLess(left, 1180, msg="Field Index crammed to far corner")
        self.assertGreaterEqual(left, 1040, msg="Field Index spilled into brand leaf")

        runs: list[tuple[int, int]] = []
        run_a: int | None = None
        for y in range(40, 1050):
            dark = any(lum(left + dx, y) < 130 for dx in range(0, 3))
            if dark and run_a is None:
                run_a = y
            elif not dark and run_a is not None:
                runs.append((run_a, y - 1))
                run_a = None
        if run_a is not None:
            runs.append((run_a, 1049))
        self.assertTrue(runs, msg="Field Index card edge missing")
        top, bottom = max(runs, key=lambda r: r[1] - r[0])
        self.assertGreater(bottom - top, 780, msg="Field Index plate too short")

        text_hits = sum(
            1
            for y in range(top + 40, bottom - 40, 2)
            for x in range(left + 40, min(left + 520, w - 4), 2)
            if lum(x, y) < 100
        )
        self.assertGreater(text_hits, 700, msg="Field Index actions missing / off-screen")
        ink_ys = [
            y
            for y in range(top + 40, bottom - 40, 2)
            if any(lum(x, y) < 100 for x in range(left + 40, min(left + 420, w - 4), 2))
        ]
        self.assertGreaterEqual(len(ink_ys), 30, msg="Field Index action ink too sparse")
        span = (max(ink_ys) - min(ink_ys)) if ink_ys else 0
        self.assertGreaterEqual(span, 240, msg="Field Index actions collapsed")
        self.assertLessEqual(span, 560, msg="Field Index actions still stretched with air")
        mid = top + int((bottom - top) * 0.55)
        lower = sum(1 for y in ink_ys if y > mid)
        upper = sum(1 for y in ink_ys if y <= mid)
        self.assertGreater(upper, lower, msg="actions not packed into upper 2/3")


if __name__ == "__main__":
    unittest.main()
