#!/usr/bin/env python3
"""Contract tests: Daily Challenge wires to DailyCalendar / seeds / daily_eligible.

Mirrors the GDScript authority path without requiring Godot:
  DailyCalendar.pick_for_date → calendar_90 hit else DailySeeds catalog hash
  ChamberBook.daily_wing_for_entry → featured + daily_eligible fillers
"""

from __future__ import annotations

import json
import random
import re
import unittest
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[1]
SCRIPTS = ROOT / "scripts"
CONTENT = ROOT / "content"
CHAMBERS = CONTENT / "chambers"
CALENDAR = CONTENT / "daily" / "calendar_90.json"
SEEDS = CONTENT / "daily" / "seeds.json"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def fnv1a32(text: str) -> int:
    h = 2166136261
    for ch in text:
        h ^= ord(ch)
        h = (h * 16777619) & 0xFFFFFFFF
    return h


def load_eligible_indices() -> dict[str, int]:
    """content_id -> authored index for daily_eligible chambers."""
    out: dict[str, int] = {}
    for path in sorted(CHAMBERS.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        if not data.get("daily_eligible", False):
            continue
        out[str(data["id"])] = int(data["index"])
    return out


def pick_for_date(date_yyyy_mm_dd: str) -> dict:
    cal = json.loads(CALENDAR.read_text(encoding="utf-8"))
    by_date = {d["date"]: d for d in cal["days"]}
    if date_yyyy_mm_dd in by_date:
        entry = dict(by_date[date_yyyy_mm_dd])
        entry["source"] = "calendar_90"
        return entry
    catalog = json.loads(SEEDS.read_text(encoding="utf-8"))
    seeds = catalog["seeds"]
    idx = fnv1a32(date_yyyy_mm_dd) % len(seeds)
    entry = dict(seeds[idx])
    entry["date"] = date_yyyy_mm_dd
    entry["source"] = "catalog_hash"
    return entry


def shuffle_pick(pool: list[int], seed_int: int, count: int, exclude: int = -1) -> list[int]:
    items = [i for i in pool if i != exclude]
    rng = random.Random(seed_int)
    # Match Godot RandomNumberGenerator Fisher–Yates (randi_range inclusive).
    for i in range(len(items) - 1, 0, -1):
        j = rng.randint(0, i)
        items[i], items[j] = items[j], items[i]
    return items[: min(count, len(items))]


def daily_wing_for_entry(entry: dict, eligible: dict[str, int], count: int = 5) -> list[int]:
    featured_cid = str(entry.get("chamber_id", ""))
    featured_idx = eligible.get(featured_cid)
    # Hard / eligible map uses content id keys from JSON `id` field.
    if featured_idx is None:
        # Resolve non-eligible featured (should not happen for catalog) via index file.
        path = CHAMBERS / f"{featured_cid}.json"
        if path.is_file():
            featured_idx = int(json.loads(path.read_text(encoding="utf-8"))["index"])
    pool = sorted(set(eligible.values()))
    if featured_idx is not None and featured_idx not in pool:
        pool.append(featured_idx)
        pool.sort()
    seed_int = int(entry.get("seed", 0)) or 1
    if featured_idx is None:
        return shuffle_pick(pool, seed_int, count)
    out = [featured_idx]
    for idx in shuffle_pick(pool, seed_int, count, exclude=featured_idx):
        if len(out) >= count:
            break
        if idx not in out:
            out.append(idx)
    return out


class TestGameStateWiresCalendar(unittest.TestCase):
    def test_start_daily_uses_daily_calendar(self) -> None:
        gs = _read(SCRIPTS / "game_state.gd")
        m = re.search(
            r"func start_daily_run\(\) -> void:(.*?)(?=\nfunc |\Z)",
            gs,
            re.S,
        )
        self.assertIsNotNone(m)
        body = m.group(1)
        self.assertIn("DailyCalendar.today_utc()", body)
        self.assertIn("daily_wing_for_entry", body)
        self.assertNotIn("daily_chamber_indices", body)
        self.assertNotIn("_today_seed()", body)

    def test_daily_meta_fields_present(self) -> None:
        gs = _read(SCRIPTS / "game_state.gd")
        for needle in (
            "daily_friend_code",
            "daily_chamber_id",
            "daily_source",
            "daily_variation",
            "daily_best_for_today",
        ):
            self.assertIn(needle, gs)

    def test_save_manager_persists_friend_code(self) -> None:
        sm = _read(SCRIPTS / "save_manager.gd")
        self.assertIn('"daily_friend_code"', sm)
        self.assertIn('"daily_chamber_id"', sm)
        self.assertIn('"daily_variation"', sm)


class TestChamberBookHonorsEligible(unittest.TestCase):
    def test_daily_wing_api_exists(self) -> None:
        book = _read(SCRIPTS / "chamber_book.gd")
        self.assertIn("func daily_wing_for_entry", book)
        self.assertIn("func daily_eligible_indices", book)
        self.assertIn("daily_eligible", book)

    def test_playable_preserves_daily_eligible(self) -> None:
        loader = _read(SCRIPTS / "chamber_loader.gd")
        self.assertIn('"daily_eligible"', loader)

    def test_ineligible_chambers_exist(self) -> None:
        """Quiet Span / Echo Plate / Mirror Birth / Ceiling First stay out of filler pool."""
        eligible = load_eligible_indices()
        for cid in (
            "00_quiet_span",
            "01_echo_plate",
            "02_mirror_birth",
            "04_ceiling_first",
        ):
            self.assertNotIn(cid, eligible)


class TestMenuSurfacesFriendCode(unittest.TestCase):
    def test_menu_reads_today_entry(self) -> None:
        menu = _read(SCRIPTS / "menu.gd")
        self.assertIn("today_daily_entry", menu)
        self.assertIn("friend_code", menu)
        self.assertTrue(
            "menu.daily_meta_code" in menu or "menu.daily_endless_meta_code" in menu,
            "menu should surface friend-code daily meta locale key",
        )

    def test_locale_keys(self) -> None:
        csv = _read(ROOT / "locale" / "echo_lattice.csv")
        self.assertIn("menu.daily_meta_code", csv)
        self.assertIn("hud.daily_tag_code", csv)


class TestPickAuthority(unittest.TestCase):
    def test_calendar_window_hit(self) -> None:
        cal = json.loads(CALENDAR.read_text(encoding="utf-8"))
        day0 = cal["days"][0]["date"]
        entry = pick_for_date(day0)
        self.assertEqual(entry["source"], "calendar_90")
        self.assertEqual(entry["friend_code"], cal["days"][0]["friend_code"])
        self.assertEqual(entry["chamber_id"], cal["days"][0]["chamber_id"])

    def test_catalog_hash_fallback_outside_window(self) -> None:
        cal = json.loads(CALENDAR.read_text(encoding="utf-8"))
        before = (date.fromisoformat(cal["start_date"]) - timedelta(days=1)).isoformat()
        entry = pick_for_date(before)
        self.assertEqual(entry["source"], "catalog_hash")
        self.assertTrue(str(entry.get("friend_code", "")).startswith("EL-"))
        catalog = json.loads(SEEDS.read_text(encoding="utf-8"))
        expect_idx = fnv1a32(before) % len(catalog["seeds"])
        self.assertEqual(entry["chamber_id"], catalog["seeds"][expect_idx]["chamber_id"])

    def test_wing_leads_with_featured_and_eligible_fillers(self) -> None:
        eligible = load_eligible_indices()
        cal = json.loads(CALENDAR.read_text(encoding="utf-8"))
        for day in cal["days"][:12]:
            entry = pick_for_date(day["date"])
            wing = daily_wing_for_entry(entry, eligible, 5)
            self.assertGreaterEqual(len(wing), 1)
            self.assertLessEqual(len(wing), 5)
            featured = eligible.get(entry["chamber_id"])
            if featured is None:
                path = CHAMBERS / f"{entry['chamber_id']}.json"
                featured = int(json.loads(path.read_text(encoding="utf-8"))["index"])
            self.assertEqual(wing[0], featured)
            for idx in wing[1:]:
                self.assertIn(idx, set(eligible.values()))

    def test_same_date_same_friend_code_and_wing(self) -> None:
        eligible = load_eligible_indices()
        d = "2026-09-15"
        a = pick_for_date(d)
        b = pick_for_date(d)
        self.assertEqual(a["friend_code"], b["friend_code"])
        self.assertEqual(
            daily_wing_for_entry(a, eligible),
            daily_wing_for_entry(b, eligible),
        )

    def test_yyyymmdd_is_not_catalog_seed(self) -> None:
        cal = json.loads(CALENDAR.read_text(encoding="utf-8"))
        day = cal["days"][0]
        y, m, d = (int(x) for x in day["date"].split("-"))
        yyyymmdd = y * 10000 + m * 100 + d
        self.assertNotEqual(int(day["seed"]), yyyymmdd)


class TestDailyVariationHelper(unittest.TestCase):
    def test_module_exists(self) -> None:
        path = SCRIPTS / "daily_variation.gd"
        self.assertTrue(path.is_file())
        text = _read(path)
        self.assertIn("class_name DailyVariation", text)
        self.assertIn("func apply_to_map", text)

    def test_chamber_applies_variation_on_featured(self) -> None:
        chamber = _read(SCRIPTS / "chamber.gd")
        self.assertIn("DailyVariation.apply_to_map", chamber)
        self.assertIn("daily_chamber_id", chamber)


class TestDailyCalendarGdContract(unittest.TestCase):
    def test_calendar_falls_back_to_seeds(self) -> None:
        cal = _read(SCRIPTS / "daily_calendar.gd")
        self.assertIn("DailySeeds.pick_for_date", cal)
        self.assertIn("catalog_hash", cal)
        self.assertIn("calendar_90.json", cal)


if __name__ == "__main__":
    unittest.main()
