#!/usr/bin/env python3
"""Regression: title stage must not instance or draw chamber HUD.

BUFFER / SAVED / Moves / Restart / Move-footer chrome belongs on chamber.tscn
(and Pause Index). The Field Ledger title shell mounts Menu only.
"""

from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

MENU_GD = ROOT / "scripts" / "menu.gd"
MENU_TSCN = ROOT / "scenes" / "menu.tscn"
MAIN_GD = ROOT / "scripts" / "main.gd"
CHAMBER_TSCN = ROOT / "scenes" / "chamber.tscn"
BOOT_GD = ROOT / "scripts" / "boot_title.gd"

# Chamber HUD tells that must never appear on the title shell.
HUD_STRINGS = (
    "BUFFER",
    "SAVED",
    "Moves:",
    "Restart (R)",
    "Move  WASD",
)

HUD_NODE_NAMES = (
    "BufferLabel",
    "PunchcardCells",
    "MovesLabel",
    "RestartButton",
    "HabitLabel",
    "TopBar",
    "BottomBar",
    "UndoHint",
)

MENU_HUD_DRAW_APIS = (
    "_draw_punchcard_ribbon",
    "_footer_controls_hint",
    '_controls_hint(',
    'tr("menu.buffer")',
    'tr("menu.controls_hint")',
    'tr("menu.controls_hint_remap")',
    'tr("hud.moves")',
    'tr("hud.restart")',
    'tr("hud.restart_fmt")',
    "punchcard_cell_empty",
    "punchcard_cell_filled",
    "InputGlyphs.controls_line",
)


class TestTitleMenuSceneHasNoHudNodes(unittest.TestCase):
    def test_menu_tscn_has_no_chamber_hud_nodes(self) -> None:
        tscn = MENU_TSCN.read_text(encoding="utf-8")
        for name in HUD_NODE_NAMES:
            self.assertNotIn(
                f'name="{name}"',
                tscn,
                msg=f"menu.tscn must not declare chamber HUD node {name}",
            )
        for needle in HUD_STRINGS:
            self.assertNotIn(needle, tscn)

    def test_chamber_still_owns_hud(self) -> None:
        ## Guard against "fix" that deletes HUD from the game entirely.
        tscn = CHAMBER_TSCN.read_text(encoding="utf-8")
        for name in ("BufferLabel", "PunchcardCells", "MovesLabel", "RestartButton"):
            self.assertIn(f'name="{name}"', tscn)


class TestTitleMenuScriptDrawsNoHud(unittest.TestCase):
    def test_menu_gd_has_no_chamber_hud_draw(self) -> None:
        menu = MENU_GD.read_text(encoding="utf-8")
        for api in MENU_HUD_DRAW_APIS:
            self.assertNotIn(api, menu, msg=f"title menu must not call/draw {api}")
        # Strip comments so explanatory notes cannot false-fail the string ban.
        code = "\n".join(
            ln for ln in menu.splitlines() if not ln.lstrip().startswith("#")
        )
        for needle in ("BUFFER", "SAVED", "Moves:", "Restart (R)"):
            self.assertNotIn(needle, code)

    def test_boot_title_has_no_chamber_hud(self) -> None:
        boot = BOOT_GD.read_text(encoding="utf-8")
        for api in MENU_HUD_DRAW_APIS:
            self.assertNotIn(api, boot)
        for name in HUD_NODE_NAMES:
            self.assertNotIn(name, boot)


class TestTitleStageDoesNotInstanceChamberHud(unittest.TestCase):
    def test_show_menu_only_instances_menu_scene(self) -> None:
        main = MAIN_GD.read_text(encoding="utf-8")
        # Extract show_menu body up to the next top-level func.
        m = re.search(
            r"func show_menu\(\) -> void:\n(?P<body>(?:^\t.*\n)+)",
            main,
            flags=re.MULTILINE,
        )
        self.assertIsNotNone(m, msg="show_menu() missing in main.gd")
        body = m.group("body")
        self.assertIn("MENU_SCENE.instantiate()", body)
        self.assertNotIn("CHAMBER_SCENE.instantiate()", body)
        self.assertNotIn('load("res://scenes/chamber.tscn")', body)
        self.assertIn("_clear_stage()", body)

    def test_clear_stage_detaches_before_free(self) -> None:
        ## Deferred free without remove_child leaves HUD parented until idle.
        main = MAIN_GD.read_text(encoding="utf-8")
        m = re.search(
            r"func _clear_stage\(\) -> void:\n(?P<body>(?:^\t.*\n)+)",
            main,
            flags=re.MULTILINE,
        )
        self.assertIsNotNone(m, msg="_clear_stage() missing in main.gd")
        body = m.group("body")
        # Ignore comments — only the executable loop order matters.
        code = "\n".join(
            ln for ln in body.splitlines() if not ln.lstrip().startswith("#")
        )
        self.assertIn("remove_child", code)
        self.assertIn("queue_free", code)
        loop = re.search(
            r"for c in kids:\n(?P<loop>(?:^\t\t.*\n)+)",
            code + ("\n" if not code.endswith("\n") else ""),
            flags=re.MULTILINE,
        )
        self.assertIsNotNone(loop, msg="_clear_stage loop over kids missing")
        loop_body = loop.group("loop")
        self.assertLess(
            loop_body.find("remove_child"),
            loop_body.find("queue_free"),
            msg="remove_child must run before queue_free inside the kids loop",
        )

    def test_boot_handoff_mounts_menu_not_chamber(self) -> None:
        main = MAIN_GD.read_text(encoding="utf-8")
        m = re.search(
            r"func _show_boot_title_if_needed\(\) -> bool:\n(?P<body>(?:^\t.*\n)+)",
            main,
            flags=re.MULTILINE,
        )
        self.assertIsNotNone(m)
        body = m.group("body")
        self.assertIn("MENU_SCENE.instantiate()", body)
        self.assertNotIn("CHAMBER_SCENE.instantiate()", body)


class TestTitleMenuScreenshotHasNoBufferRibbon(unittest.TestCase):
    def test_release_brand_menu_has_no_punchcard_ribbon(self) -> None:
        """Pixel gate on the store slate — no 30-cell punch-card strip at the foot.

        Matches the Field Index juice gate: 30× ~12px cells on a 14px pitch
        near the page foot (y 990–1040 at 1080p).
        """
        try:
            from PIL import Image
        except ImportError:
            self.skipTest("Pillow not installed")
        path = ROOT.parents[1] / "docs" / "RELEASE" / "screenshots" / "02_brand_main_menu.png"
        if not path.is_file():
            self.skipTest("release brand menu screenshot missing")
        im = Image.open(path).convert("L")
        w, h = im.size
        self.assertEqual((w, h), (1920, 1080))

        def lum(x: int, y: int) -> int:
            return int(im.getpixel((x, y)))

        # Continuous letterpress foot rules / silhouette plate edges are not
        # punch-card cells — require light gutters between dark hits (same as
        # test_field_ledger_juice) so page-foot ink is not a false positive.
        ribbon = 0
        for y in range(990, 1040, 2):
            cells = 0
            x = 100
            while x < 520:
                dark = lum(x, y) < 100 and lum(x + 6, y) < 100
                gap = lum(x + 11, y) > 150
                if dark and gap:
                    cells += 1
                x += 14
            if cells >= 12:
                ribbon += 1
        self.assertEqual(ribbon, 0, msg="punch-card ribbon still on title menu slate")


def main() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
