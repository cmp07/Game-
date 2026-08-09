# Echo Lattice — Release index

Integration hub for Steam ship / RC packs. See also [`RC1_README.md`](RC1_README.md).

## Platforms & builds

| Doc | Purpose |
|---|---|
| [`PLATFORMS.md`](PLATFORMS.md) | Multi-platform release strategy + macOS/Linux stubs |
| [`CI_BUILDS.md`](CI_BUILDS.md) | CI / export build notes |

## Compliance

| Doc | Purpose |
|---|---|
| [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) | Final Steam compliance pack |


## Steam store / Steamworks / Deck / Demo

| Doc | Purpose |
|---|---|
| [`STEAM_STORE_FINAL.md`](STEAM_STORE_FINAL.md) | Coming Soon / Next Fest store package |
| [`STORE_COPY_FREEZE.md`](STORE_COPY_FREEZE.md) | Gate A freeze + change control (short/long, tags, sysreqs, categories, pricing) |
| [`capsules/`](capsules/) | Capsule art placeholders |
| [`STEAMWORKS.md`](STEAMWORKS.md) | Offline stub + achievements + depot notes |
| [`ACHIEVEMENTS.json`](ACHIEVEMENTS.json) | Achievement catalog |
| [`STEAM_DECK.md`](STEAM_DECK.md) | Deck Verified prep |
| [`DEMO_SPEC.md`](DEMO_SPEC.md) | Next Fest demo scope |
| [`LOCALIZATION.md`](LOCALIZATION.md) | EN + zh-Hans |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Colorblind, flash, remap, subtitles, UI scale |
| [`BUGBASH.md`](BUGBASH.md) | RC polish bugbash checklist |

## Marketing

| Doc | Purpose |
|---|---|
| [`LAUNCH_PLAYBOOK.md`](LAUNCH_PLAYBOOK.md) | T−8 weeks → launch day → week-2 patches |
| [`presskit/`](presskit/) | Factsheet, folder layout, GIF sequences, capsule/logo slots |
| [`SOCIAL_CLIP_SCRIPTS.md`](SOCIAL_CLIP_SCRIPTS.md) | 15s / 30s scripts keyed to the rewrite slam |
| [`INFLUENCER_OUTREACH.md`](INFLUENCER_OUTREACH.md) | Outreach CRM + email skeleton |
| [`WISHLIST_MILESTONES.md`](WISHLIST_MILESTONES.md) | Wishlist tiers + creative unlocks |

Regenerate GIF frame packs:

```bash
./game/echo_lattice/tools/capture_press_gifs.sh
```

## Live ops / post-launch

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
