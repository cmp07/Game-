#!/usr/bin/env python3
"""Premium Field Index menu feel — AUDIO_V3 select / hover / confirm wiring."""

from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
CATALOG = ROOT / "audio" / "events" / "audio_events.json"


class TestMenuFeelAudioCatalog(unittest.TestCase):
    def test_ui_events_and_assets(self) -> None:
        data = json.loads(CATALOG.read_text(encoding="utf-8"))
        events = data["events"]
        for eid, rel in (
            ("ui.select", "audio/ui/ui_select_placeholder.ogg"),
            ("ui.hover", "audio/ui/ui_hover_placeholder.ogg"),
            ("ui.click", "audio/ui/ui_click_placeholder.ogg"),
        ):
            self.assertIn(eid, events)
            self.assertEqual(events[eid]["bus"], "UI")
            self.assertEqual(events[eid]["stream"], f"res://{rel}")
            ogg = ROOT / rel
            wav = ogg.with_suffix(".wav")
            self.assertTrue(ogg.is_file() or wav.is_file(), msg=rel)

    def test_generator_emits_paper_ink_ui(self) -> None:
        gen = (REPO / "tools" / "audio" / "generate_echo_lattice_placeholders.py").read_text(
            encoding="utf-8"
        )
        self.assertIn("def ui_select()", gen)
        self.assertIn("def ui_hover()", gen)
        self.assertIn("ui/ui_select_placeholder.wav", gen)
        self.assertIn("ui/ui_hover_placeholder.wav", gen)
        self.assertIn("paper_crease", gen)
        self.assertIn("Confirm stinger", gen)


class TestMenuFeelAudioWiring(unittest.TestCase):
    def test_director_silence_gaps(self) -> None:
        director = (ROOT / "scripts" / "audio" / "audio_director.gd").read_text(encoding="utf-8")
        self.assertIn("func arm_ui_feel", director)
        self.assertIn("func on_ui_select", director)
        self.assertIn("func on_ui_hover", director)
        self.assertIn("func on_ui_confirm", director)
        self.assertIn("UI_SELECT_GAP_MS", director)
        self.assertIn("UI_HOVER_GAP_MS", director)
        self.assertIn('fire("ui.select")', director)
        self.assertIn('fire("ui.hover")', director)
        self.assertIn('fire("ui.click")', director)

    def test_ledger_chrome_wire_index_feel(self) -> None:
        chrome = (ROOT / "scripts" / "ui" / "ledger_chrome.gd").read_text(encoding="utf-8")
        self.assertIn("func wire_index_feel", chrome)
        self.assertIn("on_ui_select", chrome)
        self.assertIn("on_ui_hover", chrome)
        self.assertIn("on_ui_confirm", chrome)
        self.assertIn("_ledger_feel_wired", chrome)

    def test_menu_silent_boot_wires_feel(self) -> None:
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        self.assertIn("arm_ui_feel", menu)
        self.assertIn("_wire_index_feel", menu)
        self.assertIn("wire_index_feel", menu)
        # Confirm comes from IndexAction pressed — not a leftover settings-only click.
        self.assertNotIn('AudioDirector.fire("ui.click")', menu)
        # Arm before grab_focus() so open cannot tick.
        ready = menu.split("func _ready")[1].split("\nfunc ")[0]
        self.assertLess(ready.find("arm_ui_feel"), ready.find("grab_focus()"))

    def test_pause_and_colophon_silent_open(self) -> None:
        pause = (ROOT / "scripts" / "ui" / "pause_index.gd").read_text(encoding="utf-8")
        colo = (ROOT / "scripts" / "ui" / "credits_colophon.gd").read_text(encoding="utf-8")
        self.assertIn("wire_index_feel", pause)
        self.assertIn("arm_ui_feel", pause)
        self.assertNotIn('AudioDirector.fire("ui.click")', pause)
        self.assertIn("wire_index_feel", colo)
        self.assertIn("arm_ui_feel", colo)
        self.assertNotIn('AudioDirector.fire("ui.click")', colo)

    def test_no_layout_fight_in_menu_feel(self) -> None:
        """Audio PR must not own Field Index plate geometry (layout branch)."""
        menu = (ROOT / "scripts" / "menu.gd").read_text(encoding="utf-8")
        # Layout helpers remain; feel only adds audio wiring helpers.
        self.assertIn("func field_index_card_rect", menu)
        self.assertIn("func _wire_index_feel", menu)
        self.assertIn("func _index_action_buttons", menu)


if __name__ == "__main__":
    unittest.main()
