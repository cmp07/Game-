# Echo Lattice — Release index

Integration hub for Steam ship / RC packs. See also [`RC1_README.md`](RC1_README.md).

## Platforms & builds

| Doc | Purpose |
|---|---|
| [`PLATFORMS.md`](PLATFORMS.md) | Multi-platform release strategy + macOS/Linux stubs |
| [`BUILD_WINDOWS.md`](BUILD_WINDOWS.md) | Reproducible Windows (+ Demo) export, stamps, checksums |
| [`CI_BUILDS.md`](CI_BUILDS.md) | CI / export build notes |

## Compliance / Gate A Partner legal

| Doc | Purpose |
|---|---|
| [`legal/`](legal/) | **Gate A paste pack** — Content Survey, AI disclosure, privacy page, ratings notes |
| [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) | Full Steam compliance pack (credits, depot notices, C1–C12) |
| [`APPID_PLACEHOLDER_GATES.md`](APPID_PLACEHOLDER_GATES.md) | No fake AppID / DepotID policy |


## Steam store / Steamworks / Deck / Demo

| Doc | Purpose |
|---|---|
| [`STEAM_STORE_FINAL.md`](STEAM_STORE_FINAL.md) | Coming Soon / Next Fest store package |
| [`STORE_COPY_FREEZE.md`](STORE_COPY_FREEZE.md) | Gate A freeze + change control (short/long, tags, sysreqs, categories, pricing) |
| [`screenshots/`](screenshots/) | Steam Partner 1920×1080 screenshot slate |
| [`capsules/`](capsules/) | Capsule art Gate A finals (Field Ledger) |
| [`STEAMWORKS.md`](STEAMWORKS.md) | Offline stub + achievements + depot notes |
| [`GODOTSTEAM.md`](GODOTSTEAM.md) | Optional GodotSteam install (fail-closed without SDK) |
| [`APPID_PLACEHOLDER_GATES.md`](APPID_PLACEHOLDER_GATES.md) | AppID / DepotID placeholder ship gates |
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

Regenerate store screenshots (1920×1080) and GIF frame packs:

```bash
./game/echo_lattice/tools/capture_steam_store.sh
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
