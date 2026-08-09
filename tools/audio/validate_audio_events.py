#!/usr/bin/env python3
"""Validate Echo Lattice AUDIO v2 event catalog + asset presence."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "game" / "echo_lattice" / "audio" / "events" / "audio_events.json"
AUDIO_ROOT = ROOT / "game" / "echo_lattice"


def res_to_path(res: str) -> Path:
    assert res.startswith("res://")
    return AUDIO_ROOT / res[len("res://") :]


def main() -> int:
    data = json.loads(CATALOG.read_text())
    errors: list[str] = []
    if int(data.get("version", 0)) < 2:
        errors.append("catalog version must be >= 2")

    buses = set(data.get("buses", []))
    for required in ("Master", "SFX", "Music", "UI", "PA"):
        if required not in buses:
            errors.append(f"missing bus {required}")

    events = data.get("events", {})
    required_events = [
        "sfx.footstep",
        "sfx.rewrite",
        "win.chamber",
        "win.queue_next",
        "pa.attention",
        "music.layer.L0",
        "music.layer.L1",
        "music.layer.L2",
        "music.layer.L3",
    ]
    for eid in required_events:
        if eid not in events:
            errors.append(f"missing event {eid}")

    for op in data.get("operators", []):
        eid = f"sfx.rewrite.{op}"
        if eid not in events:
            errors.append(f"missing operator stinger event {eid}")

    for eid, ev in events.items():
        bus = ev.get("bus")
        if bus not in buses:
            errors.append(f"{eid}: unknown bus {bus}")
        stream = ev.get("stream", "")
        if not stream:
            errors.append(f"{eid}: empty stream")
            continue
        wav = res_to_path(stream).with_suffix(".wav")
        ogg = res_to_path(stream).with_suffix(".ogg")
        if not wav.exists() and not ogg.exists():
            errors.append(f"{eid}: missing asset for {stream}")
        follow = ev.get("follow_up")
        if follow and follow not in events:
            errors.append(f"{eid}: follow_up {follow} not in catalog")

    silence = data.get("silence_policy", {})
    if "early_chambers_max_intensity" not in silence:
        errors.append("silence_policy.early_chambers_max_intensity missing")

    if errors:
        print("AUDIO v2 validation FAILED:")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(
        f"AUDIO v2 OK: {len(events)} events, "
        f"{len(data.get('operators', []))} operator stingers, "
        f"silence policy present."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
