#!/usr/bin/env python3
"""Contract tests for post-launch live ops: 90-day calendar + release docs."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from collections import Counter
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CALENDAR = ROOT / "game/echo_lattice/content/daily/calendar_90.json"
CATALOG = ROOT / "game/echo_lattice/content/daily/seeds.json"
GEN = ROOT / "tools/release/generate_calendar_90.py"
RELEASE_DOCS = [
    ROOT / "docs/RELEASE/README.md",
    ROOT / "docs/RELEASE/POSTLAUNCH.md",
    ROOT / "docs/RELEASE/CRASH_LOG_HOOK.md",
    ROOT / "docs/RELEASE/ROADMAP.md",
    ROOT / "docs/RELEASE/SUPPORT_FAQ.md",
]
HOOK_GD = ROOT / "game/echo_lattice/scripts/ops/crash_log_hook.gd"
CAL_GD = ROOT / "game/echo_lattice/scripts/daily_calendar.gd"

PASS = 0
FAIL = 0


def check(name: str, cond: bool, detail: str = "") -> None:
    global PASS, FAIL
    if cond:
        PASS += 1
        print(f"  PASS  {name}")
    else:
        FAIL += 1
        print(f"  FAIL  {name} — {detail}")


def test_docs_present() -> None:
    print("docs")
    for p in RELEASE_DOCS:
        check(p.name, p.is_file(), f"missing {p}")
    post = (ROOT / "docs/RELEASE/POSTLAUNCH.md").read_text(encoding="utf-8")
    for needle in ["Day 0", "Week-1", "Community", "S0", "Rollback"]:
        check(f"POSTLAUNCH has {needle}", needle in post)
    roadmap = (ROOT / "docs/RELEASE/ROADMAP.md").read_text(encoding="utf-8")
    check("roadmap fences 1.0", "1.0 scope fence" in roadmap or "scope fence" in roadmap.lower())
    check("roadmap Act V", "Act V" in roadmap)
    check("roadmap Museum cosmetics", "Museum" in roadmap and "cosmetic" in roadmap.lower())
    check("roadmap bans MX", "microtransaction" in roadmap.lower())
    faq = (ROOT / "docs/RELEASE/SUPPORT_FAQ.md").read_text(encoding="utf-8")
    check("FAQ daily UTC", "UTC" in faq)
    check("FAQ crash pack", "crash pack" in faq.lower() or "Crash pack" in faq)
    crash = (ROOT / "docs/RELEASE/CRASH_LOG_HOOK.md").read_text(encoding="utf-8")
    check("crash local default", "off by default" in crash.lower() or "Default: OFF" in crash)
    check("crash no network 1.0", "local" in crash.lower())


def test_code_stubs() -> None:
    print("code stubs")
    check("crash_log_hook.gd", HOOK_GD.is_file())
    check("daily_calendar.gd", CAL_GD.is_file())
    hook = HOOK_GD.read_text(encoding="utf-8")
    for fn in [
        "configure",
        "breadcrumb",
        "report_engine_error",
        "report_softlock",
        "export_crash_pack",
        "maybe_upload_latest",
    ]:
        check(f"hook has {fn}", f"func {fn}" in hook)
    check("upload no-op without client", "upload_client_not_bundled" in hook)
    check("redacts profile.name", "profile.name intentionally omitted" in hook or "profile.name" in hook)
    cal = CAL_GD.read_text(encoding="utf-8")
    check("calendar fallback source", "catalog_hash" in cal)
    check("calendar path", "calendar_90.json" in cal)


def test_calendar_schema() -> None:
    print("calendar schema")
    check("calendar exists", CALENDAR.is_file())
    data = json.loads(CALENDAR.read_text(encoding="utf-8"))
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    seeds_by_code = {s["friend_code"]: s for s in catalog["seeds"]}
    chamber_ids = {s["chamber_id"] for s in catalog["seeds"]}

    check("format 2", data.get("format") == 2)
    check("timezone UTC", data.get("timezone") == "UTC")
    check("day_count 90", data.get("day_count") == 90)
    days = data.get("days") or []
    check("days length 90", len(days) == 90)

    start = date.fromisoformat(data["start_date"])
    end = date.fromisoformat(data["end_date"])
    check("end = start+89", end == start + timedelta(days=89))

    dates = [d["date"] for d in days]
    check("dates unique", len(dates) == len(set(dates)))
    check("dates contiguous", dates == [(start + timedelta(days=i)).isoformat() for i in range(90)])

    required = {
        "date",
        "day_index",
        "seed",
        "chamber_id",
        "slug",
        "friend_code",
        "variation",
        "act",
        "tag",
        "label",
    }
    bad_rows = 0
    for d in days:
        if not required.issubset(d.keys()):
            bad_rows += 1
            continue
        if d["chamber_id"] not in chamber_ids:
            bad_rows += 1
            continue
        if d["friend_code"] not in seeds_by_code:
            bad_rows += 1
            continue
        var = d["variation"]
        if not isinstance(var, dict) or "hard" not in var:
            bad_rows += 1
    check("rows valid vs catalog", bad_rows == 0, f"{bad_rows} bad rows")

    tags = Counter(d["tag"] for d in days)
    check("has launch_soft", tags.get("launch_soft", 0) >= 3)
    check("has weekend tags", tags.get("weekend_portrait", 0) >= 8 and tags.get("weekend_hard", 0) >= 8)
    check("unique chambers >= 15", data.get("coverage", {}).get("unique_chambers", 0) >= 15)

    # No two identical chamber_id on consecutive days (generator de-dupe).
    consecutive = sum(
        1 for i in range(1, len(days)) if days[i]["chamber_id"] == days[i - 1]["chamber_id"]
    )
    check("no consecutive duplicate chambers", consecutive == 0, f"{consecutive} pairs")


def test_generator_roundtrip() -> None:
    print("generator")
    with tempfile.TemporaryDirectory() as td:
        out = Path(td) / "calendar_90.json"
        proc = subprocess.run(
            [sys.executable, str(GEN), "--start", "2026-09-01", "--days", "90", "--out", str(out)],
            capture_output=True,
            text=True,
            check=False,
        )
        check("generator exit 0", proc.returncode == 0, proc.stderr)
        if proc.returncode == 0:
            regen = json.loads(out.read_text(encoding="utf-8"))
            shipped = json.loads(CALENDAR.read_text(encoding="utf-8"))
            check(
                "shipped matches generator",
                regen["days"] == shipped["days"] and regen["start_date"] == shipped["start_date"],
                "re-run tools/release/generate_calendar_90.py",
            )


def main() -> int:
    print("test_release_liveops")
    test_docs_present()
    test_code_stubs()
    test_calendar_schema()
    test_generator_roundtrip()
    print(f"\n{PASS} passed, {FAIL} failed")
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
