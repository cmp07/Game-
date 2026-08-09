# Echo Lattice — Steam Partner readiness audit

**Scope:** Cloud-only audit of shipped RELEASE docs + in-repo code/config vs Steam Partner ship gates.  
**Base:** `cursor/echo-lattice-rc1` (RC1 integration; all release packs merged).  
**Date:** 2026-08-09  
**Method:** Evidence from repo only — no Partner console login, no AppID invention, no depot upload.

---

## Overall readiness

| | |
|---|---|
| **Partner ship readiness** | **38%** |
| Verdict | Docs + offline Steam stub are strong; Partner identity, real depots, CI export, final capsules, and survey submission are still open. |

Weighted from the eight focus areas below (equal weight). Percentages score **Partner-actionable readiness**, not “doc exists.”

| Area | Score | One-line |
|---|---:|---|
| AppID placeholders | **15%** | `YOUR_APP_ID` hygiene is correct; no real AppID anywhere |
| Achievements JSON vs Partner | **42%** | Catalogs match + runtime wire; Partner rows / icons not created |
| Depots | **28%** | Windows VDF templates only; empty staging; no Linux/mac/demo |
| Capsules sizes | **58%** | All required PNG sizes correct; still placeholders; no `.ico` |
| AI disclosure | **72%** | Paste-ready **No**; not submitted in Partner |
| Content survey | **55%** | Full draft answers; Partner checkboxes + legal URLs open |
| Builds / CI gaps | **18%** | Sketch + presets; **no** `.github/workflows` |
| Demo AppID | **30%** | Demo code/preset green; wishlist + demo depot AppIDs missing |

---

## 1. AppID placeholders — 15%

### Checklist

| Done | Item | Evidence |
|:---:|---|---|
| [x] | Placeholder token is consistent (`YOUR_APP_ID`) — do not invent | Docs, JSON, VDF, demo wishlist |
| [x] | Spacewar `480` documented as **dev-only**; retail must not ship it | `steam_features.json`, `STEAMWORKS.md` |
| [x] | `steam_appid.txt.example` present; retail FileExclusion lists `steam_appid.txt` | `game/echo_lattice/steam_appid.txt.example`, `depot_windows.vdf` |
| [x] | Runtime resolves AppID from beside-exe file → placeholder → Spacewar fallback | `scripts/steam/steam_service.gd` `_resolve_app_id` |
| [ ] | Real full-game AppID assigned in Steamworks | — |
| [ ] | Replace placeholders in VDF / wishlist / catalogs / store docs | Still `YOUR_APP_ID` / `YOUR_DEPOT_ID` |
| [ ] | Studio / publisher legal names filled | `YOUR_STUDIO_NAME`, `[LEGAL_*]` in compliance |

### Hotspots still on placeholder

| Path | Token |
|---|---|
| `docs/RELEASE/ACHIEVEMENTS.json` · `game/echo_lattice/config/achievements_steam.json` | `app_id` |
| `game/echo_lattice/config/steam_features.json` | `app_id_placeholder` |
| `steam/echo_lattice/app_build.vdf` | `AppID` / depot key |
| `steam/echo_lattice/depot_windows.vdf` | `DepotID` |
| `game/echo_lattice/scripts/demo_build.gd` | `WISHLIST_URL` → `/app/YOUR_APP_ID/` |
| `docs/RELEASE/STEAM_STORE_FINAL.md` | header AppID + Coming Soon gates |
| `game/echo_lattice/steam_appid.txt.example` | `YOUR_APP_ID` |

**Gap:** Until Partner creates the app, nothing in-repo can leave placeholder mode. Code path is ready; identity is not.

---

## 2. Achievements JSON vs Partner — 42%

### In-repo parity (green)

| Done | Item | Evidence |
|:---:|---|---|
| [x] | Authoritative catalog = runtime mirror | `diff` empty: `docs/RELEASE/ACHIEVEMENTS.json` ≡ `config/achievements_steam.json` |
| [x] | 12 unique `EL_*` API names; unlock kinds known | `test_steamworks.py` |
| [x] | 7 MVP rows flagged for demo-safe subset | `mvp: true` on First Steps, Habit Seen, Wing One, Clean Signal, Daily, Boot, Star Nine |
| [x] | Stub + GodotSteam adapter + `SteamAchievements` rules | `scripts/steam/*` |
| [x] | Hooks from `GameState` / `main.gd` (clear + presence) | `notify_chamber_cleared`, presence setters |
| [x] | Offline default: `steam_enabled: false` | `steam_features.json` |

### Partner-side (red)

| Done | Item | Notes |
|:---:|---|---|
| [ ] | Create each `api_name` under Stats & Achievements | Doc instructs; no Partner proof in-repo |
| [ ] | Upload 64×64 + 256×256 icons per achievement | No achievement icon assets under `game/` or `docs/` |
| [ ] | Live unlock smoke on real AppID (`EL_BOOT_CLEARED` / `EL_FIRST_STEPS`) | Manual checklist in `STEAMWORKS.md` still open |
| [ ] | Pin GodotSteam GDExtension for Godot 4.3 | Adapter present; **no** `addons/godotsteam/` |
| [ ] | Demo AppID policy chosen (omit vs MVP-only) | Spec’d in `STEAMWORKS.md` §3; not applied in Partner |

**API name set (stable):**  
`EL_FIRST_STEPS`, `EL_HABIT_SEEN`, `EL_WING_ONE`, `EL_WING_TWO`, `EL_WING_THREE`, `EL_WING_FOUR`, `EL_CLEAN_SIGNAL`, `EL_CONSTELLATION`, `EL_FULL_LATTICE`, `EL_DAILY_SEED`, `EL_BOOT_CLEARED`, `EL_STAR_NINE`.

---

## 3. Depots — 28%

### Checklist

| Done | Item | Evidence |
|:---:|---|---|
| [x] | Windows SteamPipe templates | `steam/echo_lattice/app_build.vdf`, `depot_windows.vdf` |
| [x] | Staging dir + strip rules (`steam_appid.txt`, `*.pdb`, logs) | `depot_build/windows/.gitkeep`, FileExclusion |
| [x] | Export → stage → SteamCMD steps documented | `STEAMWORKS.md` §8, `steam/echo_lattice/README.md` |
| [x] | Launch binary name documented | `EchoLattice.exe` |
| [ ] | `YOUR_APP_ID` / `YOUR_DEPOT_ID` replaced | Still placeholders |
| [ ] | Any retail binary staged | Staging empty (`.gitkeep` only) |
| [ ] | Linux depot VDF | Missing (Deck path expects Linux — `STEAM_DECK.md` / `PLATFORMS.md`) |
| [ ] | macOS depot VDF | Missing (stub export only) |
| [ ] | Demo depot / separate AppID build script | Missing under `steam/` |
| [ ] | `THIRD_PARTY_NOTICES.txt` / Godot COPYRIGHT in depot | Compliance C10 open |
| [ ] | GodotSteam redistributable policy decided + licensed | Not in tree |

**Gap:** Windows-first template is enough to *start* SteamPipe after AppID exists; multi-OS + demo depots and actual artifacts are not.

---

## 4. Capsules sizes — 58%

Verified pixel sizes (IHDR) against Steam slots in `docs/RELEASE/capsules/`:

| File | Required | Actual | Status |
|---|---|---|---|
| `header_460x215.png` | 460×215 | 460×215 | OK |
| `main_616x353.png` | 616×353 | 616×353 | OK |
| `small_231x87.png` | 231×87 | 231×87 | OK |
| `vertical_374x448.png` | 374×448 | 374×448 | OK |
| `library_hero_1920x620.png` | 1920×620 | 1920×620 | OK |
| `library_logo_1280x720.png` | 1280×720 RGBA | 1280×720 RGBA | OK |
| `community_icon_184x184.png` | 184×184 | 184×184 | OK |
| `page_background_1438x810.png` | 1438×810 | 1438×810 | OK |

### Checklist

| Done | Item | Notes |
|:---:|---|---|
| [x] | Size-correct placeholder set in RELEASE capsules | README + PNGs |
| [x] | Library logo is RGBA | `file` confirms |
| [x] | Briefs + Field Ledger palette lock | `capsules/README.md` |
| [ ] | Final illustrator pass (not stamped placeholder) | Docs mark placeholders; tiny file sizes |
| [ ] | Client icon / `.ico` set | Listed in `STEAM_STORE_FINAL.md` §7 — **missing in repo** |
| [ ] | Presskit capsule copies filled | `presskit/images/capsules/` README only (also lists 600×900 library capsule — different slot naming) |
| [ ] | Uploaded to Partner store | Coming Soon checklist unchecked |
| [~] | Screenshot slate present | 8 shots in `docs/ECHO_LATTICE/screenshots/v2_complete/` at **1152×672** — below Steam preferred ≥1920×1080 |

---

## 5. AI disclosure — 72%

### Checklist

| Done | Item | Evidence |
|:---:|---|---|
| [x] | Store + survey policy: gameplay AI = **No** | `STEAM_STORE_FINAL.md` §10, `COMPLIANCE_FINAL.md` §1.3 |
| [x] | Habit→rewrite called deterministic / not generative | Same docs + long description BBCode |
| [x] | Runtime LLM / chatbot forbidden for v1 | Explicit **No** |
| [x] | Marketing-art exception path documented | Disclose asset path only if a model is used later |
| [x] | Public one-liner ready | “deterministic, offline rules…” |
| [ ] | Generative AI Content Survey submitted in Partner | C3 unchecked |
| [ ] | Coming Soon page live with matching copy | Store checklist open |

**Score note:** Content is paste-ready and internally consistent. Remaining weight is Partner submission + live page.

---

## 6. Content survey — 55%

### Checklist

| Done | Item | Evidence |
|:---:|---|---|
| [x] | General Content draft (all-ages puzzle, no violence/sex/etc.) | `COMPLIANCE_FINAL.md` §1.1 |
| [x] | Mature Content = No | §1.2 |
| [x] | Generative AI = No / No pre / No live | §1.3 |
| [x] | ESRB E / PEGI 3 expectation documented | §2 |
| [x] | Privacy stub for local-only telemetry | §3.1 |
| [ ] | Survey filled in Steamworks App Admin | C1–C3 open |
| [ ] | `[LEGAL_CONTACT_EMAIL]` / `[LEGAL_ENTITY_NAME]` replaced | Still tokens |
| [ ] | Privacy HTTPS URL hosted + linked on store Legal | C5 open |
| [ ] | Telemetry opt-out in Settings (if default on) | C7 open |
| [ ] | In-game Credits screen wired | C11 open |
| [ ] | Font OFL / `THIRD_PARTY_NOTICES.txt` in depot | C8 / C10 open |

---

## 7. Builds / CI gaps — 18%

### Present

| Done | Item | Evidence |
|:---:|---|---|
| [x] | Export presets: Windows Desktop, Linux/X11, macOS, **Windows Demo** | `export_presets.cfg` |
| [x] | CI sketch (validate → export → artifacts → manual publish) | `docs/RELEASE/CI_BUILDS.md` |
| [x] | Headless / Python gates exist locally | `validate_chambers.py`, `--selftest`, `test_steamworks.py`, `test_demo_spec.py` |
| [x] | Secrets checklist (Steam / itch / Apple) documented | `CI_BUILDS.md` |

### Gaps (material)

| Done | Item | Notes |
|:---:|---|---|
| [ ] | Committed workflow under `.github/workflows/` | **Absent** — no YAML CI in repo |
| [ ] | Automated Win + Linux artifacts on tag/release | Sketch only |
| [ ] | macOS notarization job | Documented; not wired |
| [ ] | SteamCMD / itch butler publish job | Manual / secrets not configured |
| [ ] | `export_windows.sh` (referenced by steam README) | Not present |
| [ ] | Exported binary self-test in CI | Optional note in sketch; unimplemented |
| [ ] | Demo export artifact channel | Preset exists; no CI job |

**Gap summary:** Platform matrix and commands are written; automation that Partner launch ops depends on is not in the tree.

---

## 8. Demo AppID — 30%

### Checklist

| Done | Item | Evidence |
|:---:|---|---|
| [x] | Demo product scope (Act I + Mirror Birth) | `DEMO_SPEC.md`, `DemoBuild` |
| [x] | `Windows Demo` preset + `custom_features=demo` + late-act exclude filters | `export_presets.cfg` |
| [x] | Runtime filter + wishlist CTA | `scripts/demo_build.gd` |
| [x] | Python demo gate green | `test_demo_spec.py` → `result: OK` |
| [ ] | Full-game AppID in `WISHLIST_URL` | Still `YOUR_APP_ID` (warns at open) |
| [ ] | Separate **Demo AppID** created in Partner | Not in repo |
| [ ] | Demo depot / SteamPipe VDF | `steam/echo_lattice/` is full-game Windows only |
| [ ] | Demo linked on store / Next Fest registration | Coming Soon checklist item open |
| [ ] | Demo achievement policy applied on demo AppID | Spec only |

---

## Related RELEASE map

| Doc | Role in this audit |
|---|---|
| [`docs/RELEASE/STEAMWORKS.md`](../RELEASE/STEAMWORKS.md) | Stub architecture, depot rules, manual Steam smoke |
| [`docs/RELEASE/STEAM_STORE_FINAL.md`](../RELEASE/STEAM_STORE_FINAL.md) | Store copy, capsules upload list, AI line, Coming Soon |
| [`docs/RELEASE/COMPLIANCE_FINAL.md`](../RELEASE/COMPLIANCE_FINAL.md) | Content Survey + privacy + legal gates |
| [`docs/RELEASE/ACHIEVEMENTS.json`](../RELEASE/ACHIEVEMENTS.json) | Partner achievement table |
| [`docs/RELEASE/CI_BUILDS.md`](../RELEASE/CI_BUILDS.md) | Export CI sketch (not committed workflow) |
| [`docs/RELEASE/DEMO_SPEC.md`](../RELEASE/DEMO_SPEC.md) | Next Fest demo + AppID placeholders |
| [`docs/RELEASE/capsules/`](../RELEASE/capsules/) | Size-correct capsule placeholders |
| [`docs/RELEASE/PLATFORMS.md`](../RELEASE/PLATFORMS.md) | Store priority + build matrix |
| [`steam/echo_lattice/`](../../steam/echo_lattice/) | SteamPipe VDF templates |

Referenced but **not merged:** `docs/ECHO_LATTICE/08_STEAM_CHECKLIST.md` (missing on this branch).

---

## Priority close-out order (Partner)

1. Create full-game AppID (+ Demo AppID); replace every `YOUR_APP_ID` / `YOUR_DEPOT_ID`.  
2. Submit Content Survey + Generative AI = **No**; publish privacy URL.  
3. Create Partner achievements from `ACHIEVEMENTS.json`; add icons.  
4. Finalize capsules (replace placeholders) + client `.ico`; recapture screenshots ≥1920×1080; upload Coming Soon.  
5. Land `.github/workflows` from `CI_BUILDS.md`; produce Windows (+ Linux) artifacts.  
6. Fill Windows depot; add demo depot; set Steam branch live for QA.  
7. Enable GodotSteam pin + `steam_enabled` only on Steam-branded exports; never ship `480` / `steam_appid.txt`.

---

## Verification commands (repo)

```bash
python3 game/echo_lattice/tests/test_steamworks.py
python3 game/echo_lattice/tests/test_demo_spec.py
```

Both were **OK** at audit time on `cursor/echo-lattice-rc1`.

---

*Audit only — no AppIDs invented, no Partner mutations, no depot binaries added.*
