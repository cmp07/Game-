#!/usr/bin/env python3
"""Contracts for Weaver void speak/type spike — words become matter, not commands."""

from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEXICON = ROOT / "content" / "speak_lexicon.json"
SCRIPTS = ROOT / "scripts" / "speak"
SCENES = ROOT / "scenes"
PROJECT = ROOT / "project.godot"
DOC = ROOT.parents[1] / "docs" / "WEAVER" / "36_SPEAK_TYPE.md"


def _classify(lex: dict, utterance: str) -> dict:
    cleaned = utterance.strip().lower()
    for ch in ",.!?":
        cleaned = cleaned.replace(ch, " ")
    while "  " in cleaned:
        cleaned = cleaned.replace("  ", " ")
    if not cleaned:
        return {}
    words = [w for w in cleaned.split(" ") if w]
    laws = lex["laws"]
    threads = lex["threads"]
    fragments = lex["fragments"]
    if cleaned in laws:
        return {"kind": "law", "label": laws[cleaned]}
    if cleaned in threads:
        return {"kind": "thread", "label": threads[cleaned]}
    if cleaned in fragments:
        return {"kind": "fragment", "label": fragments[cleaned]}
    for w in words:
        if w in laws:
            return {"kind": "law", "label": laws[w]}
    for w in words:
        if w in threads:
            return {"kind": "thread", "label": threads[w]}
    for w in words:
        if w in fragments:
            return {"kind": "fragment", "label": fragments[w]}
    label = words[0].capitalize() if len(words) == 1 else cleaned.capitalize()
    return {"kind": "fragment", "label": label}


class SpeakTypeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.lex = json.loads(LEXICON.read_text(encoding="utf-8"))

    def test_project_boots_void_speak(self) -> None:
        text = PROJECT.read_text(encoding="utf-8")
        self.assertIn('run/main_scene="res://scenes/void_speak.tscn"', text)
        self.assertIn("speak_stub=", text)
        self.assertIn("4.3", text)

    def test_scene_and_scripts_present(self) -> None:
        self.assertTrue((SCENES / "void_speak.tscn").is_file())
        for name in (
            "void_speak.gd",
            "starry_void.gd",
            "utterance_lexicon.gd",
            "voice_stub.gd",
            "spoken_matter.gd",
        ):
            self.assertTrue((SCRIPTS / name).is_file(), name)

    def test_no_shed_ui_in_void_scene(self) -> None:
        scene = (SCENES / "void_speak.tscn").read_text(encoding="utf-8")
        script = (SCRIPTS / "void_speak.gd").read_text(encoding="utf-8")
        blob = (scene + script).lower()
        for banned in ("combine_panel", "yard_art", "timber deck", "combinepanel"):
            self.assertNotIn(banned, blob)
        self.assertIn("VoidFill", scene)
        self.assertIn("StarryVoid", scene)
        self.assertIn("type into the void", script.lower())
        self.assertNotIn("Color(0.86, 0.8, 0.7, 1)", scene)
        self.assertIn("FILL_OVERSCAN", script)
        self.assertIn("_fill_window_with_field", script)

    def test_not_a_command_console(self) -> None:
        script = (SCRIPTS / "void_speak.gd").read_text(encoding="utf-8")
        lex = (SCRIPTS / "utterance_lexicon.gd").read_text(encoding="utf-8")
        self.assertNotIn("LineEdit", script)
        self.assertNotIn("TextEdit", script)
        self.assertIn("diegetic", script.lower())
        self.assertIn("not a command", lex.lower())
        self.assertIn("_spawn_from_text", script)

    def test_lexicon_has_three_matter_kinds(self) -> None:
        self.assertIn("anchor", self.lex["fragments"])
        self.assertIn("brace", self.lex["threads"])
        self.assertIn("law", self.lex["laws"])
        self.assertGreaterEqual(len(self.lex["voice_stub_phrases"]), 5)

    def test_classify_fragment_thread_law(self) -> None:
        self.assertEqual(_classify(self.lex, "anchor")["kind"], "fragment")
        self.assertEqual(_classify(self.lex, "brace")["kind"], "thread")
        self.assertEqual(_classify(self.lex, "hold")["kind"], "law")
        self.assertEqual(_classify(self.lex, "hold the span")["kind"], "law")
        self.assertEqual(_classify(self.lex, "mystery")["kind"], "fragment")

    def test_no_purple_chrono_in_lexicon(self) -> None:
        blob = json.dumps(self.lex).lower()
        for banned in ("purple", "chrono", "aether", "nebula"):
            self.assertNotIn(banned, blob)

    def test_voice_stub_feeds_same_pipeline(self) -> None:
        voice = (SCRIPTS / "voice_stub.gd").read_text(encoding="utf-8")
        void = (SCRIPTS / "void_speak.gd").read_text(encoding="utf-8")
        self.assertIn("phrase_ready", voice)
        self.assertIn("typewrite_into", voice)
        self.assertIn("_on_voice_phrase", void)
        self.assertIn("complete_listen", void)

    def test_design_doc_present(self) -> None:
        self.assertTrue(DOC.is_file())
        body = DOC.read_text(encoding="utf-8")
        self.assertIn("diegetic", body.lower())
        self.assertIn("voice", body.lower())
        self.assertIn("not a command console", body.lower())
        self.assertIn("void_speak", body)
    def test_loom_flags_void_speak(self) -> None:
        loom = (ROOT / "scripts" / "loom" / "loom_state.gd").read_text(encoding="utf-8")
        self.assertIn("pending_void_speak", loom)
        self.assertIn("--void-speak", loom)


if __name__ == "__main__":
    unittest.main()
