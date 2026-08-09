#!/usr/bin/env python3
"""Generate a pre-authored 90-day UTC daily calendar for Echo Lattice.

Reads the daily seed catalog and emits content/daily/calendar_90.json with
intentional pacing (tutorial-soft open, weekend portrait/hard tags, act rotation).
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG_PATH = ROOT / "game/echo_lattice/content/daily/seeds.json"
OUT_PATH = ROOT / "game/echo_lattice/content/daily/calendar_90.json"

# Launch epoch for the authored window (UTC). Ops may rebase with --start.
DEFAULT_START = date(2026, 9, 1)

WEEKEND = {5, 6}  # Sat/Sun in date.weekday()


def load_catalog() -> list[dict]:
    data = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    seeds = data.get("seeds") or []
    if len(seeds) < 10:
        raise SystemExit(f"catalog too small: {len(seeds)}")
    return seeds


def act_of(chamber_id: str) -> str:
    try:
        idx = int(chamber_id.split("_", 1)[0])
    except ValueError:
        return "unknown"
    if idx <= 8:
        return "induction"
    if idx <= 17:
        return "reflection"
    if idx <= 26:
        return "pressure"
    if idx <= 34:
        return "mastery"
    return "hard"


def is_boss(entry: dict) -> bool:
    slug = entry.get("slug", "")
    return "identity" in slug or slug in {"nameplate", "nameplate_hard", "open_lattice"}


def is_hardish(entry: dict) -> bool:
    if entry.get("variation", {}).get("hard"):
        return True
    cid = entry.get("chamber_id", "")
    return cid.startswith("3") and int(cid.split("_", 1)[0]) >= 35


def pick_pool(catalog: list[dict]) -> dict[str, list[dict]]:
    pools = {
        "soft": [],
        "mid": [],
        "hard": [],
        "boss": [],
    }
    for e in catalog:
        if is_boss(e):
            pools["boss"].append(e)
        elif is_hardish(e):
            pools["hard"].append(e)
        elif act_of(e["chamber_id"]) in {"induction", "reflection"}:
            pools["soft"].append(e)
        else:
            pools["mid"].append(e)
    # Fallbacks so generation never dies on a thin pool.
    for key in list(pools):
        if not pools[key]:
            pools[key] = list(catalog)
    return pools


def choose(pools: dict[str, list[dict]], day_index: int, d: date) -> tuple[dict, str]:
    """Return (catalog_entry, tag)."""
    wd = d.weekday()
    # Opening week: keep it welcoming.
    if day_index < 5:
        return pools["soft"][day_index % len(pools["soft"])], "launch_soft"
    # Weekend portrait / hard showcase.
    if wd in WEEKEND:
        if wd == 5:
            return pools["boss"][day_index % len(pools["boss"])], "weekend_portrait"
        return pools["hard"][day_index % len(pools["hard"])], "weekend_hard"
    # Midweek rotation: soft / mid / mid / hard-lite pattern.
    lane = day_index % 4
    if lane == 0:
        return pools["soft"][day_index % len(pools["soft"])], "weekday_soft"
    if lane == 3:
        # Prefer mid with hard variation flag when available.
        mid = pools["mid"][day_index % len(pools["mid"])]
        return mid, "weekday_pressure"
    return pools["mid"][day_index % len(pools["mid"])], "weekday_standard"


def build(start: date, days: int = 90) -> dict:
    catalog = load_catalog()
    pools = pick_pool(catalog)
    out_days = []
    used: dict[str, int] = {}
    for i in range(days):
        d = start + timedelta(days=i)
        entry, tag = choose(pools, i, d)
        # Mild de-dupe: if same chamber_id as yesterday, step one in its pool.
        if out_days and out_days[-1]["chamber_id"] == entry["chamber_id"]:
            pool_name = (
                "boss"
                if tag.startswith("weekend_portrait")
                else "hard"
                if "hard" in tag
                else "soft"
                if "soft" in tag
                else "mid"
            )
            pool = pools[pool_name]
            entry = pool[(i + 1) % len(pool)]
        cid = entry["chamber_id"]
        used[cid] = used.get(cid, 0) + 1
        var = dict(entry.get("variation") or {})
        out_days.append(
            {
                "date": d.isoformat(),
                "day_index": i,
                "seed": entry["seed"],
                "chamber_id": cid,
                "slug": entry.get("slug", ""),
                "friend_code": entry.get("friend_code", f"EL-{entry['seed']}"),
                "variation": {
                    "rotate": int(var.get("rotate", 0)),
                    "reflect": var.get("reflect", "none"),
                    "palette": var.get("palette", "default"),
                    "hard": bool(var.get("hard", False)),
                },
                "act": act_of(cid),
                "tag": tag,
                "label": f"daily/{entry.get('slug', cid)}",
            }
        )

    return {
        "format": 2,
        "game": "echo_lattice",
        "doc": "docs/RELEASE/POSTLAUNCH.md",
        "timezone": "UTC",
        "start_date": start.isoformat(),
        "end_date": (start + timedelta(days=days - 1)).isoformat(),
        "day_count": days,
        "note": (
            "Pre-authored Daily Challenge calendar. Runtime prefers an exact date hit; "
            "otherwise falls back to content/daily/seeds.json via fnv1a32(date)%len."
        ),
        "fallback": {
            "catalog": "content/daily/seeds.json",
            "hash": "fnv1a32(YYYY-MM-DD) % len(seeds)",
        },
        "coverage": {
            "unique_chambers": len(used),
            "uses_by_chamber": dict(sorted(used.items())),
        },
        "days": out_days,
    }


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--start", default=DEFAULT_START.isoformat(), help="UTC start YYYY-MM-DD")
    ap.add_argument("--days", type=int, default=90)
    ap.add_argument("--out", type=Path, default=OUT_PATH)
    args = ap.parse_args(argv)
    start = date.fromisoformat(args.start)
    payload = build(start, args.days)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {args.out} ({payload['day_count']} days, {payload['coverage']['unique_chambers']} chambers)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
