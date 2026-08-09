# Echo Lattice — Release / Live Ops

Post-launch operations pack for shipping Echo Lattice like a small studio: hotfix playbooks, crash/log hooks, a pre-authored daily calendar, a fenced DLC roadmap, and player support copy.

| Doc | Purpose |
|---|---|
| [`POSTLAUNCH.md`](POSTLAUNCH.md) | Day-0 hotfix plan, Week-1 patch, community response scripts |
| [`CRASH_LOG_HOOK.md`](CRASH_LOG_HOOK.md) | Local crash/log design + optional opt-in upload contract |
| [`ROADMAP.md`](ROADMAP.md) | Free updates + paid DLC (Act V, Museum cosmetics) — **1.0 scope fence** |
| [`SUPPORT_FAQ.md`](SUPPORT_FAQ.md) | Steam / Discord / email support FAQ |

| Content / code | Purpose |
|---|---|
| `game/echo_lattice/content/daily/calendar_90.json` | Pre-authored UTC daily calendar (launch day → +89) |
| `game/echo_lattice/scripts/daily_calendar.gd` | Date → calendar entry (falls back to catalog hash) |
| `game/echo_lattice/scripts/ops/crash_log_hook.gd` | Local crash/log JSONL sink |
| `tools/release/generate_calendar_90.py` | Regenerator for the 90-day calendar |
| `game/echo_lattice/tests/test_release_liveops.py` | Calendar + hook contract tests |

**1.0 non-goals** (see Roadmap): no live-service economy, no cosmetic microtransactions, no Act V in the launch build, no mandatory telemetry upload.
