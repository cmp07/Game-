#!/usr/bin/env python3
"""Self-test for Echo Lattice Next Fest demo scope (no Godot required).

Validates docs/RELEASE/DEMO_SPEC.md against content + export + DemoBuild script.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # game/echo_lattice
REPO = ROOT.parents[1]
ACTS_PATH = ROOT / "content" / "acts.json"
CHAMBERS_DIR = ROOT / "content" / "chambers"
EXPORT_PRESETS = ROOT / "export_presets.cfg"
DEMO_BUILD_GD = ROOT / "scripts" / "demo_build.gd"
DEMO_SPEC = REPO / "docs" / "RELEASE" / "DEMO_SPEC.md"

# Keep in sync with DemoBuild.allowed_campaign_ids()
ALLOWED = [
    "00_quiet_span",
    "01_echo_plate",
    "02_mirror_birth",
    "03_break_the_loop",
    "04_ceiling_first",
    "05_two_glances",
    "06_far_side",
    "07_first_thicken",
    "08_identity_induction",
]

SPOILER_PREFIXES = ("09_", "1", "2", "3")  # late campaign + hard (filenames)


def fail(msg: str) -> None:
    print(f"FAIL: {msg}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    print("== Echo Lattice demo spec self-test ==")

    if not DEMO_SPEC.is_file():
        fail(f"missing {DEMO_SPEC}")
    if not DEMO_BUILD_GD.is_file():
        fail(f"missing {DEMO_BUILD_GD}")
    if not EXPORT_PRESETS.is_file():
        fail(f"missing {EXPORT_PRESETS}")

    acts = json.loads(ACTS_PATH.read_text(encoding="utf-8"))
    campaign = list(acts.get("campaign_order", []))
    induction = None
    for act in acts.get("acts", []):
        if act.get("id") == "induction":
            induction = act
            break
    if induction is None:
        fail("acts.json missing induction act")

    act_chambers = list(induction.get("chambers", []))
    if act_chambers != ALLOWED:
        fail(f"Induction chambers != demo allow-list\n  acts: {act_chambers}\n  allow: {ALLOWED}")

    # Demo allow-list must be a prefix of full campaign (no reordering surprises).
    if campaign[: len(ALLOWED)] != ALLOWED:
        fail("demo allow-list is not the campaign_order prefix")

    # Mirror Birth must exist and teach mirror_v.
    mb_path = CHAMBERS_DIR / "02_mirror_birth.json"
    if not mb_path.is_file():
        fail("missing 02_mirror_birth.json")
    mb = json.loads(mb_path.read_text(encoding="utf-8"))
    if mb.get("title") != "Mirror Birth":
        fail(f"Mirror Birth title mismatch: {mb.get('title')!r}")
    if mb.get("transform") != "mirror_v":
        fail(f"Mirror Birth transform expected mirror_v got {mb.get('transform')!r}")
    if mb.get("act") != "induction":
        fail("Mirror Birth must be in induction")

    for cid in ALLOWED:
        path = CHAMBERS_DIR / f"{cid}.json"
        if not path.is_file():
            fail(f"demo chamber missing on disk: {cid}")
        data = json.loads(path.read_text(encoding="utf-8"))
        if int(data.get("act_index", -1)) != 0:
            fail(f"{cid} act_index != 0 (late-act leak into allow-list)")

    # Allow-list is Act I only (00–08); anything else is a late-act spoiler.
    for cid in ALLOWED:
        if not re.match(r"^0[0-8]_", cid):
            fail(f"allow-list contains non-Act-I id {cid}")
    late = [c for c in campaign if c not in ALLOWED]
    if not late:
        fail("expected late-act chambers in full campaign_order")
    for cid in late:
        if cid in ALLOWED:
            fail(f"spoiler id leaked into allow-list: {cid}")

    # DemoBuild.gd contracts.
    gd = DEMO_BUILD_GD.read_text(encoding="utf-8")
    if 'FEATURE_TAG := "demo"' not in gd:
        fail("DemoBuild missing FEATURE_TAG demo")
    if "02_mirror_birth" not in gd:
        fail("DemoBuild missing Mirror Birth id")
    if "WISHLIST_URL" not in gd or "store.steampowered.com" not in gd:
        fail("DemoBuild missing Steam wishlist URL")
    for cid in ALLOWED:
        if cid not in gd:
            fail(f"DemoBuild.allowed_campaign_ids missing {cid}")

    # Export preset.
    presets = EXPORT_PRESETS.read_text(encoding="utf-8")
    if 'name="Windows Demo"' not in presets:
        fail("export_presets.cfg missing Windows Demo preset")
    if 'custom_features="demo"' not in presets:
        fail("Windows Demo preset missing custom_features=demo")
    if "EchoLatticeDemo.exe" not in presets:
        fail("Windows Demo export_path missing EchoLatticeDemo.exe")
    for pattern in (
        "content/chambers/09_*.json",
        "content/chambers/1*_*.json",
        "content/chambers/2*_*.json",
        "content/chambers/3*_*.json",
    ):
        if pattern not in presets:
            fail(f"Windows Demo exclude_filter missing {pattern}")

    # Spec doc mentions the key surfaces.
    spec = DEMO_SPEC.read_text(encoding="utf-8")
    for needle in ("Mirror Birth", "Windows Demo", "wishlist", "Act I", "--demo", "test_demo_spec.py"):
        if needle.lower() not in spec.lower():
            fail(f"DEMO_SPEC.md missing mention of {needle!r}")

    print(f"  Act I chambers: {len(ALLOWED)}")
    print("  Mirror Birth: OK")
    print("  Windows Demo preset: OK")
    print("  wishlist URL: present (placeholder AppID expected pre-Partner)")
    print("result: OK")


if __name__ == "__main__":
    main()
