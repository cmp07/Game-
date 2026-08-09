#!/usr/bin/env python3
"""Static Steam Deck prep checks for Echo Lattice (no Godot binary required).

Validates joypad bindings, stretch/aspect expand, Deck autoloads, and the
absence of text-entry controls in packed scenes.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # game/echo_lattice
PROJECT = ROOT / "project.godot"
SCENES = ROOT / "scenes"
SCRIPTS = ROOT / "scripts"

REQUIRED_ACTIONS = {
    "move_up": {"joy_buttons": {11}, "joy_axes": {(1, -1.0)}},  # DPAD_UP, LEFT_Y -
    "move_down": {"joy_buttons": {12}, "joy_axes": {(1, 1.0)}},
    "move_left": {"joy_buttons": {13}, "joy_axes": {(0, -1.0)}},
    "move_right": {"joy_buttons": {14}, "joy_axes": {(0, 1.0)}},
    "undo": {"joy_buttons": {2}, "joy_axes": set()},  # X
    "restart": {"joy_buttons": {3}, "joy_axes": set()},  # Y
    "pause_menu": {"joy_buttons": {6, 1}, "joy_axes": set()},  # Start + B
    "confirm": {"joy_buttons": {0}, "joy_axes": set()},  # A
}


def _parse_actions(text: str) -> dict[str, str]:
    """Return action_name -> raw events block body."""
    actions: dict[str, str] = {}
    # Each action is name={ ... }
    for match in re.finditer(
        r"^([A-Za-z0-9_]+)=\{\n(.*?)^\}$",
        text,
        flags=re.MULTILINE | re.DOTALL,
    ):
        actions[match.group(1)] = match.group(2)
    return actions


def _joy_buttons(block: str) -> set[int]:
    return {
        int(m.group(1))
        for m in re.finditer(
            r'Object\(InputEventJoypadButton,.*?button_index":(\d+)',
            block,
        )
    }


def _joy_axes(block: str) -> set[tuple[int, float]]:
    out: set[tuple[int, float]] = set()
    for m in re.finditer(
        r'Object\(InputEventJoypadMotion,.*?axis":(\d+),"axis_value":(-?\d+(?:\.\d+)?)',
        block,
    ):
        out.add((int(m.group(1)), float(m.group(2))))
    return out


def check_project() -> list[str]:
    errors: list[str] = []
    text = PROJECT.read_text(encoding="utf-8")

    if 'window/stretch/aspect="expand"' not in text:
        errors.append('display stretch aspect must be "expand" for 16:10 Deck fill')
    if "InputGlyphs=" not in text:
        errors.append("InputGlyphs autoload missing")
    if "DeckProfile=" not in text:
        errors.append("DeckProfile autoload missing")
    if "window/vsync/vsync_mode=1" not in text:
        errors.append("vsync must be enabled by default")

    # Slice the [input] section only.
    input_section = text.split("[input]", 1)
    if len(input_section) < 2:
        errors.append("no [input] section in project.godot")
        return errors
    rest = input_section[1]
    next_header = re.search(r"^\[", rest, flags=re.MULTILINE)
    body = rest[: next_header.start()] if next_header else rest
    actions = _parse_actions(body)

    for name, expect in REQUIRED_ACTIONS.items():
        block = actions.get(name)
        if block is None:
            errors.append(f"missing input action: {name}")
            continue
        buttons = _joy_buttons(block)
        axes = _joy_axes(block)
        missing_btn = expect["joy_buttons"] - buttons
        if missing_btn:
            errors.append(f"{name}: missing joy buttons {sorted(missing_btn)}")
        missing_axes = expect["joy_axes"] - axes
        if missing_axes:
            errors.append(f"{name}: missing joy axes {sorted(missing_axes)}")
    return errors


def check_no_text_entry() -> list[str]:
    errors: list[str] = []
    for path in list(SCENES.rglob("*.tscn")) + list(SCRIPTS.rglob("*.gd")):
        text = path.read_text(encoding="utf-8")
        if "LineEdit" in text or "TextEdit" in text:
            # Allow mentions in comments within the layout checker only.
            if path.name == "main.gd" and "LineEdit" in text:
                # main.gd intentionally scans for these types.
                if re.search(r'type="LineEdit"|LineEdit\.new|TextEdit\.new', text):
                    errors.append(f"{path.relative_to(ROOT)}: instantiates text entry")
                continue
            if path.suffix == ".tscn":
                errors.append(f"{path.relative_to(ROOT)}: contains text-entry control")
            elif re.search(r"LineEdit\.new|TextEdit\.new|type=\"LineEdit\"", text):
                errors.append(f"{path.relative_to(ROOT)}: instantiates text entry")
    return errors


def check_support_scripts() -> list[str]:
    errors: list[str] = []
    for rel in ("scripts/input_glyphs.gd", "scripts/deck_profile.gd"):
        if not (ROOT / rel).is_file():
            errors.append(f"missing {rel}")
    glyphs = (ROOT / "scripts/input_glyphs.gd").read_text(encoding="utf-8")
    if "D-Pad" not in glyphs and "D-Pad / Stick" not in glyphs:
        errors.append("input_glyphs.gd missing D-Pad/Stick labels")
    deck = (ROOT / "scripts/deck_profile.gd").read_text(encoding="utf-8")
    if "1280" not in deck or "TARGET_FPS_VERIFIED" not in deck:
        errors.append("deck_profile.gd missing Deck resolution / FPS targets")
    main = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
    if "--deck-layout-check" not in main:
        errors.append("main.gd missing --deck-layout-check entry point")
    return errors


def main() -> int:
    errors: list[str] = []
    errors.extend(check_project())
    errors.extend(check_no_text_entry())
    errors.extend(check_support_scripts())
    if errors:
        print("Deck binding check FAILED:")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("Deck binding check OK")
    print("  joypad actions bound (D-Pad/stick + A/B/X/Y/Start)")
    print("  stretch aspect=expand, vsync on, Deck autoloads present")
    print("  no LineEdit/TextEdit in play scenes (OSK not required)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
