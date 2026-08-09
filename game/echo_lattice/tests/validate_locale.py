#!/usr/bin/env python3
"""Validate Echo Lattice localization CSV (en + zh_Hans).

Checks:
  - header / required locales
  - unique keys, non-empty en + zh_Hans
  - placeholder parity (%s / %%)
  - every chamber JSON has title + caption keys
  - UI key prefixes expected by scripts exist

Stdlib only. Exit 0 on success.
"""
from __future__ import annotations

import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "locale" / "echo_lattice.csv"
CHAMBERS_DIR = ROOT / "content" / "chambers"

REQUIRED_LOCALES = ("en", "zh_Hans")
REQUIRED_UI_KEYS = {
    "brand.title",
    "brand.tagline",
    "brand.blurb",
    "boot.wing_line",
    "menu.continue",
    "menu.start_new",
    "menu.daily",
    "menu.endless",
    "menu.hard",
    "menu.hard_count",
    "menu.museum",
    "menu.museum_meta",
    "menu.quit",
    "menu.subtitle_fresh",
    "menu.subtitle_progress",
    "menu.subtitle_demo",
    "menu.daily_meta",
    "menu.demo_daily_meta_code",
    "menu.daily_endless_meta_code",
    "menu.daily_endless_meta",
    "menu.controls_hint_remap",
    "menu.daily_meta_code",
    "hud.moves",
    "hud.habit",
    "hud.habit_unwritten",
    "hud.habit_sealed",
    "hud.habit_leaning",
    "hud.habit_leaning_pct",
    "hud.seed",
    "hud.habit_identity",
    "hud.habit_identity_pct",
    "hud.restart",
    "hud.menu",
    "hud.daily_tag",
    "hud.daily_tag_code",
    "hud.endless_tag",
    "hud.endless_depth",
    "hud.restart_fmt",
    "hud.menu_fmt",
    "habit.up",
    "habit.down",
    "habit.left",
    "habit.right",
    "habit.hand_right_leaner",
    "habit.hand_looper",
    "habit.hand_zigzagger",
    "habit.hand_balanced",
    "won.title",
    "won.next_chamber",
    "won.finish_wing",
    "won.next_daily",
    "won.daily_complete",
    "won.next_endless",
    "won.daily_line",
    "won.daily_line_code",
    "won.endless_line",
    "won.replay",
    "won.menu",
    "won.stats",
    "won.stamp_birth",
    "won.stamp_boss",
    "won.stamp_grade_scribble",
    "won.stamp_grade_readable",
    "won.stamp_grade_signed",
    "won.museum_archive",
    "museum.title",
    "museum.blurb",
    "museum.empty",
    "museum.back",
    "museum.replay",
    "museum.race",
    "museum.detail",
    "museum.vignette_empty",
    "hud.ghost_tag",
    "hud.ghost_tag_plain",
    "won.back_museum",
    "won.ghost_line",
    "end.title",
    "end.tagline",
    "end.new_run",
    "end.menu",
    "end.summary",
    "end.header_endless",
    "end.header_wing",
    "end.header_daily",
    "end.header_daily_code",
    "end.demo_title",
    "end.demo_tagline",
    "end.demo_footer",
    "end.demo_footer_no_wishlist",
    "end.demo_replay",
    "locale.language",
    "locale.en",
    "locale.zh_Hans",
    "locale.system",
    "settings.title",
    "settings.a11y_reset",
    "settings.bindings_saved",
    "settings.rebind_prompt",
    "settings.subtitle_background",
    "settings.status_press_key",
    "colorblind.default",
    "colorblind.protanopia",
    "input.undo",
    "input.ghost_assist",
    "subtitle.rewrite_begin",
    "subtitle.pa.checkpoint.armed",
    "glyphs.controls_gamepad",
    "glyphs.controls_keyboard",
}

# SubtitleOverlay.STUB_LINES ids — each must have subtitle.<id> in the CSV.
SUBTITLE_STUB_IDS = {
    "rewrite_begin",
    "rewrite_mirror",
    "rewrite_rotate",
    "rewrite_thicken",
    "checkpoint",
    "habit_warn_loop",
    "habit_warn_dash",
    "ghost_assist",
    "undo",
    "win",
    "pa.ghost.floor",
    "pa.ghost.race",
    "pa.checkpoint.armed",
    "pa.rewrite.fired",
    "pa.boot.lattice_online",
    "pa.wing.clear",
    "tutorial_buffer",
}

# Hard-coded English that must not remain in player-facing scripts.
FORBIDDEN_LITERALS = {
    "scripts/a11y/settings_menu.gd": (
        "Press key… (Esc cancel)",
        "Bindings saved.",
        "Accessibility reset to defaults.",
    ),
    "scripts/end_screen.gd": (
        "DEMO COMPLETE",
        "Wishlist on Steam",
        "Replay Act I",
    ),
    "scripts/menu.gd": (
        "Demo — Act I · Mirror Birth. Ink on paper.",
    ),
    "scripts/input_glyphs.gd": (
        "Move  WASD / Arrows     Undo  Z",
    ),
}

PLACEHOLDER_RE = re.compile(r"%(?![%s])|%s|%%")


def placeholder_signature(text: str) -> tuple[int, int]:
    """Return (%s count, %% count) — ignore other %. """
    s_count = len(re.findall(r"%s", text))
    pct_count = len(re.findall(r"%%", text))
    # stray % that is not %s or %%
    stripped = re.sub(r"%%", "", text)
    stripped = re.sub(r"%s", "", stripped)
    stray = stripped.count("%")
    return s_count, pct_count, stray


def load_csv(path: Path) -> tuple[list[str], dict[str, dict[str, str]]]:
    with path.open(encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows: dict[str, dict[str, str]] = {}
        for row in reader:
            if not row or not row[0].strip():
                continue
            key = row[0]
            entry = {}
            for i, col in enumerate(header[1:], start=1):
                entry[col] = row[i] if i < len(row) else ""
            rows[key] = entry
    return header, rows


def main() -> int:
    errors: list[str] = []
    if not CSV_PATH.is_file():
        print(f"FAIL: missing {CSV_PATH}", file=sys.stderr)
        return 1

    header, rows = load_csv(CSV_PATH)
    if not header or header[0] != "keys":
        errors.append(f"bad header: {header!r} (expected keys,...)")
    for loc in REQUIRED_LOCALES:
        if loc not in header:
            errors.append(f"missing locale column: {loc}")

    if len(rows) != len(set(rows)):
        errors.append("duplicate keys detected")

    for key, entry in rows.items():
        for loc in REQUIRED_LOCALES:
            val = entry.get(loc, "")
            if not str(val).strip():
                errors.append(f"{key}: empty {loc}")
        if "en" in entry and "zh_Hans" in entry:
            en_sig = placeholder_signature(entry["en"])
            zh_sig = placeholder_signature(entry["zh_Hans"])
            if en_sig[0] != zh_sig[0]:
                errors.append(
                    f"{key}: %s count mismatch en={en_sig[0]} zh_Hans={zh_sig[0]}"
                )
            if en_sig[2] or zh_sig[2]:
                errors.append(f"{key}: stray % (use %% for literals)")

    missing_ui = sorted(REQUIRED_UI_KEYS - set(rows))
    if missing_ui:
        errors.append(f"missing UI keys: {', '.join(missing_ui)}")

    for stub_id in sorted(SUBTITLE_STUB_IDS):
        key = f"subtitle.{stub_id}"
        if key not in rows:
            errors.append(f"missing subtitle stub key: {key}")

    for rel, needles in FORBIDDEN_LITERALS.items():
        src = ROOT / rel
        if not src.is_file():
            errors.append(f"missing script for literal scan: {rel}")
            continue
        body = src.read_text(encoding="utf-8")
        for needle in needles:
            if needle in body:
                errors.append(f"{rel}: hard-coded EN still present: {needle!r}")

    settings_tscn = ROOT / "scenes" / "ui" / "settings_menu.tscn"
    if settings_tscn.is_file():
        tscn = settings_tscn.read_text(encoding="utf-8")
        for needle in ("LanguageOption", "SubtitleBackgroundCheck", "_on_language_selected"):
            if needle not in tscn:
                errors.append(f"settings_menu.tscn missing {needle}")

    chamber_ids = []
    for path in sorted(CHAMBERS_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        cid = data.get("id") or path.stem
        chamber_ids.append(cid)
        for kind in ("title", "caption"):
            key = f"chamber.{cid}.{kind}"
            if key not in rows:
                errors.append(f"missing {key} for {path.name}")
            else:
                # English column should match JSON source (warn-level as error for drift).
                en = rows[key].get("en", "")
                src = str(data.get(kind, ""))
                if en != src:
                    errors.append(
                        f"{key}: en CSV {en!r} != JSON {src!r}"
                    )

    if not chamber_ids:
        errors.append("no chamber JSON found")

    if errors:
        print(f"FAIL: {len(errors)} locale issue(s)", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    print(
        f"OK: {len(rows)} keys, locales={REQUIRED_LOCALES}, "
        f"chambers={len(chamber_ids)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
