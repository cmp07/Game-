#!/usr/bin/env python3
"""Headless acceptance tests for Echo Lattice META v2.

Mirrors SeedClock / StarLedger / Streaks / Museum / Achievements / NG+ / pacing
contracts without Godot.

Run: python3 game/echo_lattice/tests/test_meta_v2.py
"""

from __future__ import annotations

import json
import math
import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CFG_PATH = ROOT / "config" / "meta_v2.json"
ACH_PATH = ROOT / "config" / "achievements_v2.json"
DOC_PATH = Path(__file__).resolve().parents[3] / "docs" / "ECHO_LATTICE" / "15_META_V2.md"

FNV_OFFSET = 14695981039346656037
FNV_PRIME = 1099511628211
MASK64 = 0xFFFFFFFFFFFFFFFF


def fnv1a64(text: str) -> int:
    h = FNV_OFFSET
    for b in text.encode("utf-8"):
        h ^= b
        h = (h * FNV_PRIME) & MASK64
    return h & MASK64


def load_json(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def daily_datestamp(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%d")


def iso_week_id(dt: datetime) -> str:
    y, w, _ = dt.astimezone(timezone.utc).isocalendar()
    return f"{y:04d}-W{w:02d}"


def fresh_save(cfg: dict) -> dict:
    return {
        "version": int(cfg.get("save_version", 2)),
        "profile": {"name": "Operator", "ng_plus_unlocked": False, "ng_plus_cycles": 0},
        "unlocks": {
            "chambers": ["ec_01_boot"],
            "modifiers": [],
            "cosmetics": [],
            "runes": [],
            "achievements": [],
        },
        "stars": {"best": {}, "total_earned": 0},
        "streaks": {
            "play_current": 0,
            "play_best": 0,
            "play_last_date": "",
            "daily_clear_current": 0,
            "daily_clear_best": 0,
            "daily_last_date": "",
            "weekly_clear_current": 0,
            "weekly_clear_best": 0,
            "weekly_last_id": "",
        },
        "seeds": {
            "last_daily_date": "",
            "last_daily_outcome": "",
            "last_weekly_id": "",
            "last_weekly_outcome": "",
        },
        "museum": {"selves": [], "cap": int(cfg.get("museum", {}).get("cap", 48))},
        "ng_plus": {"active": False, "cycle": 0, "modifiers": []},
        "pacing": {
            "short_runs_completed": 0,
            "last_session_sec": 0.0,
            "best_short_run_sec": 0.0,
            "last_run_end_unix": 0,
        },
        "stats": {
            "runs_started": 0,
            "runs_completed": 0,
            "runs_failed": 0,
            "runs_abandoned": 0,
            "rewrites_committed": 0,
            "fossils_seen": 0,
            "daily_runs": 0,
            "daily_clears": 0,
            "weekly_runs": 0,
            "weekly_clears": 0,
            "ghost_races": 0,
            "ng_plus_clears": 0,
            "one_more_runs": 0,
            "no_undo_clears": 0,
            "cold_clears": 0,
            "reader_clears": 0,
            "triple_mode_chambers": 0,
            "soft_only_clears": 0,
        },
        "runs": [],
        "active_run": {},
        "settings": {},
    }


def apply_stars(save: dict, chamber_id: str, stars: int) -> None:
    awarded = max(1, min(3, stars))
    best = save["stars"].setdefault("best", {})
    prev = int(best.get(chamber_id, 0))
    if awarded > prev:
        best[chamber_id] = awarded
    save["stars"]["total_earned"] = sum(int(v) for v in best.values())


def yesterday(ds: str) -> str:
    d = datetime.strptime(ds, "%Y-%m-%d").replace(tzinfo=timezone.utc)
    return (d - timedelta(days=1)).strftime("%Y-%m-%d")


def touch_play(streaks: dict, date: str) -> None:
    last = streaks.get("play_last_date", "")
    if last == date:
        return
    if last == "" or last == yesterday(date):
        streaks["play_current"] = int(streaks.get("play_current", 0)) + 1
    else:
        streaks["play_current"] = 1
    streaks["play_last_date"] = date
    streaks["play_best"] = max(int(streaks.get("play_best", 0)), streaks["play_current"])


def extend_daily_clear(streaks: dict, date: str) -> None:
    last = streaks.get("daily_last_date", "")
    if last == date:
        return
    if last == yesterday(date):
        streaks["daily_clear_current"] = int(streaks.get("daily_clear_current", 0)) + 1
    else:
        streaks["daily_clear_current"] = 1
    streaks["daily_last_date"] = date
    streaks["daily_clear_best"] = max(
        int(streaks.get("daily_clear_best", 0)), streaks["daily_clear_current"]
    )


_SELF_SEQ = 0


def archive_self(save: dict, cfg: dict, chamber_id: str, stars: int = 2) -> dict:
    global _SELF_SEQ
    museum = save["museum"]
    _SELF_SEQ += 1
    row = {
        "id": f"self_{_SELF_SEQ:04d}",
        "chamber_id": chamber_id,
        "stars": stars,
        "moves": 40,
        "undos": 0,
        "outcome": "clear",
        "habit": {"archetype": "balanced", "fingerprint": 1},
        "ghost": {"stride": 2, "path": [[0, 0], [1, 0]]},
        "title": f"A Self from {chamber_id}",
    }
    museum["selves"].insert(0, row)
    cap = int(museum.get("cap", cfg.get("museum", {}).get("cap", 48)))
    while len(museum["selves"]) > cap:
        museum["selves"].pop()
    return row


KNOWN_RULE_KINDS = {
    "stat_at_least",
    "stars_total_at_least",
    "stars_chamber_at_least",
    "chambers_cleared_at_least",
    "streak_at_least",
    "museum_count_at_least",
    "flag_true",
    "ng_plus_cycle_at_least",
    "short_runs_at_least",
    "all_of",
    "any_of",
}


def rule_kinds(rule: dict) -> set[str]:
    kinds = {rule["kind"]}
    for child in rule.get("rules", []) or []:
        kinds |= rule_kinds(child)
    return kinds


def eval_rule(rule: dict, save: dict) -> bool:
    kind = rule["kind"]
    if kind == "stat_at_least":
        return int(save.get("stats", {}).get(rule["stat"], 0)) >= int(rule["value"])
    if kind == "stars_total_at_least":
        return sum(int(v) for v in save.get("stars", {}).get("best", {}).values()) >= int(
            rule["value"]
        )
    if kind == "stars_chamber_at_least":
        return int(save.get("stars", {}).get("best", {}).get(rule["chamber_id"], 0)) >= int(
            rule["value"]
        )
    if kind == "chambers_cleared_at_least":
        return sum(1 for v in save.get("stars", {}).get("best", {}).values() if int(v) >= 1) >= int(
            rule["value"]
        )
    if kind == "streak_at_least":
        return int(save.get("streaks", {}).get(rule["streak"], 0)) >= int(rule["value"])
    if kind == "museum_count_at_least":
        return len(save.get("museum", {}).get("selves", [])) >= int(rule["value"])
    if kind == "flag_true":
        cur: object = save
        for part in str(rule["path"]).split("."):
            if not isinstance(cur, dict) or part not in cur:
                return False
            cur = cur[part]
        return bool(cur)
    if kind == "ng_plus_cycle_at_least":
        return int(save.get("profile", {}).get("ng_plus_cycles", 0)) >= int(rule["value"])
    if kind == "short_runs_at_least":
        return int(save.get("pacing", {}).get("short_runs_completed", 0)) >= int(rule["value"])
    if kind == "all_of":
        return all(eval_rule(r, save) for r in rule["rules"])
    if kind == "any_of":
        return any(eval_rule(r, save) for r in rule["rules"])
    raise AssertionError(f"unknown rule kind {kind}")


def evaluate_achievements(catalog: list, save: dict) -> list[str]:
    have = list(save["unlocks"].get("achievements", []))
    newly = []
    for entry in catalog:
        aid = entry["id"]
        if aid in have:
            continue
        if eval_rule(entry["rule"], save):
            have.append(aid)
            newly.append(aid)
    save["unlocks"]["achievements"] = have
    return newly


def plan_short_run(cfg: dict, kind: str, dt: datetime) -> dict:
    spec = cfg["short_run"]["kinds"][kind]
    count = int(spec["chamber_count"])
    budget = int(spec["budget_sec"])
    seed_mode = spec.get("seed_mode", kind if kind in ("daily", "weekly") else "standard")
    chambers: list[str] = []
    if seed_mode == "daily":
        ds = daily_datestamp(dt)
        seed = fnv1a64(f"{cfg['daily']['namespace']}|{ds}")
        pool = cfg["daily"]["pool"]
        chambers = [pool[seed % len(pool)]]
    elif seed_mode == "weekly":
        wid = iso_week_id(dt)
        seed = fnv1a64(f"{cfg['weekly']['namespace']}|{wid}")
        pool = cfg["weekly"]["pool"]
        chambers = [pool[seed % len(pool)]]
    else:
        act1 = sorted(
            cid for cid, meta in cfg["chambers"].items() if int(meta.get("act", 1)) == 1
        )
        chambers = act1[:count]
    return {
        "kind": kind,
        "seed_mode": seed_mode,
        "chambers": chambers,
        "budget_sec": budget,
        "min_budget_sec": int(spec["min_budget_sec"]),
        "max_budget_sec": int(spec["max_budget_sec"]),
    }


class MetaV2Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.cfg = load_json(CFG_PATH)
        cls.ach = load_json(ACH_PATH)

    def test_schema_and_doc(self) -> None:
        self.assertEqual(self.cfg.get("schema_version"), 2)
        self.assertTrue(CFG_PATH.is_file())
        self.assertTrue(ACH_PATH.is_file())
        self.assertTrue(DOC_PATH.is_file(), f"missing {DOC_PATH}")
        doc = DOC_PATH.read_text(encoding="utf-8")
        for needle in (
            "Museum of Selves",
            "NG+",
            "Short-run",
            "daily",
            "weekly",
            "Stars",
            "Streaks",
            "Achievements",
        ):
            self.assertIn(needle, doc)

    def test_achievement_count_and_rule_kinds(self) -> None:
        catalog = self.ach["achievements"]
        self.assertGreaterEqual(len(catalog), 30)
        self.assertEqual(len(catalog), 35)
        ids = [a["id"] for a in catalog]
        self.assertEqual(len(ids), len(set(ids)), "duplicate achievement ids")
        for entry in catalog:
            kinds = rule_kinds(entry["rule"])
            self.assertTrue(kinds, entry["id"])
            self.assertTrue(kinds <= KNOWN_RULE_KINDS, f"{entry['id']} unknown {kinds}")

    def test_daily_weekly_seed_determinism(self) -> None:
        ds = "2026-08-09"
        a = fnv1a64(f"{self.cfg['daily']['namespace']}|{ds}")
        b = fnv1a64(f"{self.cfg['daily']['namespace']}|{ds}")
        self.assertEqual(a, b)
        self.assertNotEqual(a, fnv1a64(f"{self.cfg['daily']['namespace']}|2026-08-10"))
        wid = "2026-W32"
        wa = fnv1a64(f"{self.cfg['weekly']['namespace']}|{wid}")
        self.assertEqual(wa, fnv1a64(f"{self.cfg['weekly']['namespace']}|{wid}"))
        pool = self.cfg["daily"]["pool"]
        chamber = pool[a % len(pool)]
        self.assertIn(chamber, pool)

    def test_iso_week_helper(self) -> None:
        dt = datetime(2026, 8, 9, 12, 0, tzinfo=timezone.utc)
        self.assertEqual(iso_week_id(dt), "2026-W32")

    def test_stars_never_decrease(self) -> None:
        save = fresh_save(self.cfg)
        apply_stars(save, "ec_01_boot", 2)
        apply_stars(save, "ec_01_boot", 1)
        self.assertEqual(save["stars"]["best"]["ec_01_boot"], 2)
        apply_stars(save, "ec_01_boot", 3)
        self.assertEqual(save["stars"]["best"]["ec_01_boot"], 3)
        self.assertEqual(save["stars"]["total_earned"], 3)

    def test_streaks_daily_and_play(self) -> None:
        save = fresh_save(self.cfg)
        streaks = save["streaks"]
        d0 = datetime(2026, 8, 7, 12, tzinfo=timezone.utc)
        d1 = d0 + timedelta(days=1)
        d2 = d0 + timedelta(days=2)
        touch_play(streaks, daily_datestamp(d0))
        extend_daily_clear(streaks, daily_datestamp(d0))
        touch_play(streaks, daily_datestamp(d1))
        extend_daily_clear(streaks, daily_datestamp(d1))
        self.assertEqual(streaks["daily_clear_current"], 2)
        self.assertEqual(streaks["play_current"], 2)
        # Non-clear breaks daily current but not best / play
        streaks["daily_clear_current"] = 0
        streaks["daily_last_date"] = daily_datestamp(d2)
        touch_play(streaks, daily_datestamp(d2))
        self.assertEqual(streaks["daily_clear_best"], 2)
        self.assertEqual(streaks["play_current"], 3)

    def test_museum_cap_and_clear_only(self) -> None:
        global _SELF_SEQ
        _SELF_SEQ = 0
        save = fresh_save(self.cfg)
        save["museum"]["cap"] = 3
        for i in range(5):
            archive_self(save, self.cfg, f"ec_0{i%3+1}_x", stars=1)
        self.assertEqual(len(save["museum"]["selves"]), 3)
        # Newest first
        self.assertEqual(save["museum"]["selves"][0]["id"], "self_0005")
        ids = [s["id"] for s in save["museum"]["selves"]]
        self.assertEqual(ids, ["self_0005", "self_0004", "self_0003"])

    def test_ng_plus_unlock_and_modifiers(self) -> None:
        save = fresh_save(self.cfg)
        required = self.cfg["ng_plus"]["unlock_chambers"]
        self.assertEqual(len(required), 7)
        for cid in required[:-1]:
            apply_stars(save, cid, 1)
        self.assertFalse(save["profile"]["ng_plus_unlocked"])
        # Simulate unlock check
        if all(int(save["stars"]["best"].get(c, 0)) >= 1 for c in required):
            save["profile"]["ng_plus_unlocked"] = True
        self.assertFalse(save["profile"]["ng_plus_unlocked"])
        apply_stars(save, required[-1], 1)
        if all(int(save["stars"]["best"].get(c, 0)) >= 1 for c in required):
            save["profile"]["ng_plus_unlocked"] = True
        self.assertTrue(save["profile"]["ng_plus_unlocked"])
        save["ng_plus"]["active"] = True
        scale = 2
        mod = self.cfg["ng_plus"]["modifiers"][0]
        window = max(
            int(mod["habit_window_floor"]),
            48 + int(mod["habit_window_delta"]) * scale,
        )
        self.assertEqual(window, 32)
        slack = float(self.cfg["ng_plus"]["modifiers"][2]["star_slack_mult"]) ** scale
        self.assertAlmostEqual(slack, 0.81, places=5)

    def test_short_run_budgets(self) -> None:
        dt = datetime(2026, 8, 9, 15, tzinfo=timezone.utc)
        std = plan_short_run(self.cfg, "standard", dt)
        self.assertEqual(len(std["chambers"]), 3)
        self.assertGreaterEqual(std["budget_sec"], 480)
        self.assertLessEqual(std["budget_sec"], 900)
        daily = plan_short_run(self.cfg, "daily", dt)
        self.assertEqual(len(daily["chambers"]), 1)
        weekly = plan_short_run(self.cfg, "weekly", dt)
        self.assertEqual(len(weekly["chambers"]), 1)
        # Complete in budget
        save = fresh_save(self.cfg)
        elapsed = 600.0
        if elapsed <= std["max_budget_sec"]:
            save["pacing"]["short_runs_completed"] = 1
            save["pacing"]["best_short_run_sec"] = elapsed
        self.assertEqual(save["pacing"]["short_runs_completed"], 1)

    def test_achievement_evaluation_smoke(self) -> None:
        save = fresh_save(self.cfg)
        save["stats"]["runs_completed"] = 1
        apply_stars(save, "ec_01_boot", 1)
        archive_self(save, self.cfg, "ec_01_boot")
        newly = evaluate_achievements(self.ach["achievements"], save)
        self.assertIn("first_steps", newly)
        self.assertIn("boot_cleared", newly)
        self.assertIn("museum_first", newly)
        # Idempotent
        newly2 = evaluate_achievements(self.ach["achievements"], save)
        self.assertEqual(newly2, [])

    def test_godot_scripts_present(self) -> None:
        scripts = [
            "scripts/meta/meta_v2.gd",
            "scripts/meta/meta_save.gd",
            "scripts/meta/seed_clock.gd",
            "scripts/meta/star_ledger.gd",
            "scripts/meta/streak_service.gd",
            "scripts/meta/museum_of_selves.gd",
            "scripts/meta/achievement_service.gd",
            "scripts/meta/ng_plus_service.gd",
            "scripts/meta/short_run_pacing.gd",
            "scripts/meta/ui/meta_hub.gd",
            "scripts/meta/ui/museum_screen.gd",
            "scripts/meta/ui/achievements_screen.gd",
            "scripts/meta/ui/weekly_screen.gd",
            "scripts/meta/ui/ng_plus_screen.gd",
        ]
        for rel in scripts:
            self.assertTrue((ROOT / rel).is_file(), rel)
        for scene in (
            "scenes/meta/meta_hub.tscn",
            "scenes/meta/museum_screen.tscn",
            "scenes/meta/achievements_screen.tscn",
            "scenes/meta/weekly_screen.tscn",
            "scenes/meta/ng_plus_screen.tscn",
        ):
            self.assertTrue((ROOT / scene).is_file(), scene)


if __name__ == "__main__":
    # Quiet unused import lint for math in some environments
    _ = math
    result = unittest.main(verbosity=2, exit=False)
    sys.exit(0 if result.result.wasSuccessful() else 1)
