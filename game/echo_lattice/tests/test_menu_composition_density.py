#!/usr/bin/env python3
"""CI gate: title menu dense composition @ 1920×1080.

Fails if:
  - Brand column / Field Index anchors drift off the 52/42 hard spec
  - Measured empty (no ink/ui layout mass) ≥ 28% of the inner page
  - Dashed concentric circle seal / FIELD watermark code paths return
  - Field Index rows stretch with sparse leading
  - Store slate 02_brand_main_menu.png lacks brand + full Field Index
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
    brand_top = left[1] + 88.0
    brand_w = min(560.0, left[2] - 72.0)
    brand_block = (brand_x, brand_top, brand_w, float(brand_px) + 62.0)
    sil_top = brand_block[1] + brand_block[3] + specimen_gap
    sil = (
        brand_x - 4.0,
        sil_top,
        max(200.0, left[0] + left[2] - (brand_x - 4.0) - 20.0),
        max(160.0, left[1] + left[3] - sil_top - 16.0),
    )
    seal_half = min(38.0, sil[2] * 0.10)
    seal = (
        sil[0] + 12.0,
        sil[1] + 12.0,
        seal_half * 2.0,
        seal_half * 2.0,
    )
    side_pad, top_pad, bot_pad = 16.0, 20.0, 18.0
    card = (
        right[0] + side_pad,
        right[1] + top_pad,
        max(240.0, right[2] - side_pad * 2.0),
        max(300.0, right[3] - top_pad - bot_pad),
    )

    def area(r: tuple[float, float, float, float]) -> float:
        return r[2] * r[3]

    # Seal lives inside specimen — do not double-count.
    occupied = area(brand_block) + area(sil) + area(card) + gutter * outer[3] * 0.35
    empty = 1.0 - occupied / max(1.0, area(outer))
    return {
        "outer": outer,
        "left": left,
        "right": right,
        "brand_block": brand_block,
        "seal": seal,
        "silhouette": sil,
        "field_index": card,
        "brand_px": brand_px,
        "verso_frac": left_w / outer[2],
        "recto_frac": right_w / outer[2],
        "index_width_frac": card[2] / VP_W,
        "empty_frac": empty,
        "specimen_gap": specimen_gap,
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
            "const SPECIMEN_GAP",
            "const INDEX_ROW_H",
            "func composition_layout",
            'tr("brand.title")',
            'tr("brand.tagline")',
            '"caption": ""',
            '"sharp_edge": true',
        ):
            self.assertIn(token, MENU, msg=token)
        self.assertLessEqual(_const_float("MAX_EMPTY_FRAC"), 0.28)
        self.assertGreaterEqual(_const_int("BRAND_MIN_PX"), 72)
        self.assertGreaterEqual(_const_float("INDEX_ROW_H"), 36.0)
        self.assertLessEqual(_const_float("INDEX_ROW_H"), 44.0)
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
        self.assertLessEqual(lay["specimen_gap"], 40.0)
        self.assertGreaterEqual(lay["specimen_gap"], 24.0)
        # Specimen fills remaining verso — no mid-leaf void band after brand.
        sil = lay["silhouette"]
        self.assertGreaterEqual(sil[3], 420.0, msg="specimen too short — cream band remains")
        # Integrated seal is a small letterpress inset, not a second maze plane.
        seal = lay["seal"]
        self.assertLessEqual(seal[2], 100.0)
        self.assertLessEqual(seal[3], 100.0)
        self.assertGreaterEqual(seal[2], 48.0)
        # Field Index full readable height.
        card = lay["field_index"]
        self.assertGreaterEqual(card[3], 900.0)

    def test_dense_row_pitch_not_stretched(self) -> None:
        """Actions pack as a compact block — never SIZE_EXPAND_FILL stretch."""
        self.assertIn("Control.SIZE_SHRINK_BEGIN", MENU)
        self.assertIn("INDEX_ROW_H", MENU)
        self.assertIn("_field_index_block_height", MENU)
        # Stretch path must stay gone on the title shell.
        self.assertNotIn("SIZE_EXPAND_FILL if compact else Control.SIZE_EXPAND_FILL", MENU)
        apply = re.search(
            r"func _apply_index_row_metrics\([\s\S]*?\nfunc ",
            MENU,
        )
        self.assertIsNotNone(apply)
        body = apply.group(0)
        # Horizontal fill is fine; vertical stretch is the sparse-list failure mode.
        self.assertNotIn("size_flags_vertical = Control.SIZE_EXPAND_FILL", body)
        self.assertIn("SIZE_SHRINK_BEGIN", body)
        self.assertNotIn("clampf(even,", body)

    def test_no_circle_seal_code_paths(self) -> None:
        """Dashed concentric circle seal + FIELD watermark must stay eradicated."""
        # Extract draw_seal_stamp body only.
        m = re.search(
            r"func draw_seal_stamp\([\s\S]*?\nfunc ",
            ART,
        )
        self.assertIsNotNone(m)
        body = m.group(0)
        # Old circle seal used TAU ring segments — ban that grammar in the seal.
        self.assertNotIn("TAU * float(i)", body)
        self.assertNotIn("inner_ring", body)
        self.assertNotIn("ring_w", body)
        self.assertIn("rectangular", body.lower())
        self.assertIn('caption.to_upper() == "FIELD"', body)
        # Call sites must never pass FIELD watermark.
        for src, label in ((MENU, "menu"), (BOOT, "boot")):
            self.assertNotIn('"caption": "FIELD"', src, msg=label)
            self.assertNotIn('"caption": "field"', src, msg=label)
        # Title / boot must call the rectangular plate path.
        self.assertIn("ArtKit.draw_seal_stamp", MENU)
        self.assertIn("ArtKit.draw_seal_stamp", BOOT)
        self.assertIn("plate_w", MENU)
        self.assertIn("plate_h", MENU)

    def test_brand_slate_shows_brand_and_field_index(self) -> None:
        if not SHOT.is_file():
            self.skipTest("02_brand_main_menu.png missing — capture before merge")
        w, h, rows, bpp = _read_png_luma(SHOT)
        self.assertEqual((w, h), (1920, 1080))

        def lum(x: int, y: int) -> int:
            r = rows[y]
            j = x * bpp
            return (r[j] + r[j + 1] + r[j + 2]) // 3

        # Brand ink on the left leaf (ECHO LATTICE zone — largest type, upper verso).
        brand = sum(
            1
            for y in range(60, 220, 2)
            for x in range(50, 720, 2)
            if lum(x, y) < 150
        )
        self.assertGreater(brand, 400, msg="ECHO LATTICE brand ink missing on left")

        # Field Index left edge in the right ~42% column — skip spine trough ink.
        left = None
        for x in range(1040, 1280):
            if lum(x, 220) < 100:
                left = x
                break
        self.assertIsNotNone(left, msg="Field Index left edge missing")
        self.assertLess(left, 1180, msg="Field Index crammed to far corner")
        self.assertGreaterEqual(left, 1040, msg="Field Index spilled into brand leaf")

        # Full-height plate edge.
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

        # Action ink inside the plate — Condensed Medium strokes are thin; sample densely.
        text_hits = sum(
            1
            for y in range(top + 40, bottom - 40, 2)
            for x in range(left + 40, min(left + 520, w - 4), 2)
            if lum(x, y) < 100
        )
        self.assertGreater(text_hits, 700, msg="Field Index actions missing / off-screen")
        # Compact block in upper 2/3 — not stretched top-to-bottom with sparse air.
        ink_ys = [
            y
            for y in range(top + 40, bottom - 40, 2)
            if any(lum(x, y) < 100 for x in range(left + 40, min(left + 420, w - 4), 2))
        ]
        self.assertGreaterEqual(len(ink_ys), 30, msg="Field Index action ink too sparse")
        span = (max(ink_ys) - min(ink_ys)) if ink_ys else 0
        self.assertGreaterEqual(span, 240, msg="Field Index actions collapsed")
        self.assertLessEqual(span, 560, msg="Field Index actions still stretched with air")
        # Bottom fifth of the plate should be quieter than the action block.
        mid = top + int((bottom - top) * 0.55)
        lower = sum(1 for y in ink_ys if y > mid)
        upper = sum(1 for y in ink_ys if y <= mid)
        self.assertGreater(upper, lower, msg="actions not packed into upper 2/3")

        # No concentric dashed-circle seal: polar ring score around brand seal zone.
        # Rectangular plate has ink on flats; a circle seal spikes at constant radius.
        cx, cy = 170, 360
        ring_scores = []
        for radius in (70, 95, 120):
            dark = 0
            total = 0
            for deg in range(0, 360, 6):
                import math

                x = int(cx + math.cos(math.radians(deg)) * radius)
                y = int(cy + math.sin(math.radians(deg)) * radius)
                if 0 <= x < w and 0 <= y < h:
                    total += 1
                    if lum(x, y) < 140:
                        dark += 1
            if total:
                ring_scores.append(dark / total)
        # A dashed double-ring seal lights ≥2 radii heavily; rectangular die does not.
        hot = sum(1 for s in ring_scores if s > 0.42)
        self.assertLess(hot, 2, msg=f"concentric circle seal returned (scores={ring_scores})")


if __name__ == "__main__":
    unittest.main()
