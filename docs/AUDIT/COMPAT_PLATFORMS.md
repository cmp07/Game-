# Compatibility & platforms audit

**Product:** Echo Lattice (`game/echo_lattice/`)  
**Scope:** Steam Deck Verified gaps · Proton vs native · itch DRM-free · GOG/Epic readiness · Steamworks feature flags · demo depot differences · regional / China  
**Method:** RELEASE authority docs vs committed code / presets / SteamPipe templates on `cursor/echo-lattice-rc1`  
**Date:** 2026-08-09  
**Verdict:** **Prep-strong on Deck input + offline Steam stub; ship-blocked on real AppID, Linux/demo depots, GodotSteam pin, CJK font vendoring, and storefront packaging scripts.**

---

## 1. Sources

| Authority (docs) | Code / artifacts checked |
|---|---|
| [`docs/RELEASE/PLATFORMS.md`](../RELEASE/PLATFORMS.md) | `export_presets.cfg`, CI sketch |
| [`docs/RELEASE/STEAM_DECK.md`](../RELEASE/STEAM_DECK.md) | `deck_profile.gd`, `input_glyphs.gd`, `check_deck_bindings.py`, `project.godot` |
| [`docs/RELEASE/STEAMWORKS.md`](../RELEASE/STEAMWORKS.md) | `config/steam_features.json`, `scripts/steam/*`, `steam/echo_lattice/*.vdf` |
| [`docs/RELEASE/DEMO_SPEC.md`](../RELEASE/DEMO_SPEC.md) | `demo_build.gd`, Windows Demo preset, `test_demo_spec.py` |
| [`docs/RELEASE/CI_BUILDS.md`](../RELEASE/CI_BUILDS.md) | No committed `.github/workflows/export.yml` |
| [`docs/RELEASE/STEAM_STORE_FINAL.md`](../RELEASE/STEAM_STORE_FINAL.md) | Feature checkboxes vs runtime flags |
| [`docs/RELEASE/LOCALIZATION.md`](../RELEASE/LOCALIZATION.md) | `locale_manager.gd`, `locale/echo_lattice.csv`, `fonts/cjk/` |
| [`docs/RELEASE/SUPPORT_FAQ.md`](../RELEASE/SUPPORT_FAQ.md) · [`ROADMAP.md`](../RELEASE/ROADMAP.md) | Doc drift vs Deck / glyph code |

Static gates that already pass on this tree:

```bash
python3 game/echo_lattice/tests/check_deck_bindings.py   # OK
python3 game/echo_lattice/tests/test_steamworks.py       # OK
python3 game/echo_lattice/tests/test_demo_spec.py        # OK
python3 game/echo_lattice/tests/validate_locale.py       # OK (141 keys, en + zh_Hans)
```

Hardware / Partner gates (Deck device, SteamCMD live branch, notarized mac, butler/GOG/EGS upload) are **not** exercised here.

---

## 2. Executive matrix

| Area | Doc target | Code / pipeline reality | Gap severity |
|---|---|---|---|
| Steam Deck Verified prep | Native Linux, full pad, no OSK, 1280×800 | Implemented + static checks green | **Medium** — hardware QA + Linux depot still open |
| Proton vs native | Native primary; Proton fallback only | Linux preset exists; SteamPipe only Windows | **High** for Verified claim |
| itch DRM-free | Same presets, no Steam DLLs, no Steam CTAs | Defaults offline-safe; no `itch` feature / packaging script; demo wishlist is Steam-hardcoded | **Medium** |
| GOG / Epic | Optional after Steam proof | Zero SDK / upload / store packaging | **Low** (correctly deferred) · **ops not ready** |
| Steamworks flags | Offline stub + flags | `steam_enabled: false`; no GodotSteam addon; AppID placeholder | **High** for Steam-branded retail |
| Demo depots | Separate demo AppID / Act I PCK | Windows Demo preset + runtime filter; no demo VDF / Linux demo | **High** for Next Fest upload |
| Regional / China | Explicit CNY + `zh_Hans` | Locale CSV + aliases; no CJK font file; no store CNY automation | **Medium** for China Steam |

---

## 3. Steam Deck Verified — gaps

### 3.1 What matches the docs

| Pillar ([`STEAM_DECK.md`](../RELEASE/STEAM_DECK.md)) | Evidence |
|---|---|
| Native Linux export preferred | `export_presets.cfg` → `Linux/X11` → `builds/linux/EchoLattice.x86_64`; comment cites Deck Verified |
| Full controller map | `project.godot` joypad bindings; `check_deck_bindings.py` asserts D-Pad/stick + A/B/X/Y/Start |
| Glyphs on Deck | `InputGlyphs` + `DeckProfile` force gamepad device on Deck detect |
| No OSK path | Static scan: no `LineEdit` / `TextEdit` in play scenes |
| 16:10 / 1280×800 | `stretch/aspect=expand`; `--deck-layout-check` + `DeckProfile.layout_report` |
| Battery / FPS caps | `DeckProfile`: 60 default, `--battery` → 40; VSync on |
| Deck detect | `SteamDeck` / `STEAMDECK`, `/home/deck`, Jupiter/Galileo `BOARD_NAME` |
| Renderer | `gl_compatibility` in `project.godot` (matches Deck GLES-friendly path) |

### 3.2 Remaining Verified blockers

| Gap | Doc says | Code / ops |
|---|---|---|
| **Linux Steam depot** | Deck launch option = native binary | `steam/echo_lattice/` has **Windows-only** `app_build.vdf` + `depot_windows.vdf`. No `depot_linux.vdf`. CI sketch assigns Linux to “depot 2” but nothing is committed. |
| **Hardware checklist** | Boots, glyphs, full run, 60 FPS @ ≤7 W, suspend/resume | Unchecked boxes in `STEAM_DECK.md` § submit; no device evidence in-repo |
| **Suspend / resume** | Smoke required for Verified | No `NOTIFICATION_APPLICATION_*` / focus handlers dedicated to SteamOS suspend; relies on Godot defaults + local save |
| **Official Steam Input config** | Explicitly out of scope until AppID | Still out of scope — fine, but store “Full controller support” cannot be claimed Partner-side until uploaded |
| **Proton not required** | Do not mark Verified on Proton if native passes | Demo acceptance still lists “Steam Deck **Proton**” (`DEMO_SPEC.md` §6) — conflicts with Deck authority |
| **Doc drift (support / store)** | Deck pack claims glyphs Implemented | `SUPPORT_FAQ.md` A3 still says glyphs are Week-1; `STEAM_STORE_FINAL.md` §6 still says “keyboard/mouse required until gamepad glyphs land”; `ROADMAP.md` Free Update #1 still lists “controller glyphs”. **Store copy + FAQ lag the Deck code.** |

### 3.3 Verified questionnaire readiness (prep only)

Copy from `STEAM_DECK.md` with audit status:

| Item | Prep status |
|---|---|
| Boots without extra launch options (native) | Code ready; **needs Linux depot + device** |
| Controller glyphs default | **Code ready** |
| Full run pad-only | **Code ready**; device QA open |
| OSK never required | **Code ready** (static) |
| UI at 1280×800 | **Code ready**; device QA open |
| 60 FPS ≤ 7 W | Targets documented; **device profile open** |
| Proton not required | Policy clear; **depot config missing** |

---

## 4. Proton vs native

| Path | Policy | Reality |
|---|---|---|
| **Native Linux x86_64** | Default Deck / SteamOS launch | Export preset present; **not** wired into SteamPipe |
| **Windows under Proton** | Fallback / desktop Windows depot only | Windows depot templates exist; demo fest path still QA’d on Proton per `DEMO_SPEC.md` |

**Why the gap matters:** Claiming Deck Verified while only shipping a Windows depot forces Proton. That contradicts `STEAM_DECK.md` (“Do **not** mark Verified on Proton if the native build passes”) and `PLATFORMS.md` (native primary).

**Minimum close-out:**

1. Add `depot_linux.vdf` + app build depot entry.  
2. Steam launch option → `EchoLattice.x86_64` for SteamOS.  
3. Keep Windows depot for desktop; do not point Deck default at `.exe`.  
4. Reconcile demo Deck QA language to “native preferred; Proton smoke optional.”

---

## 5. itch.io DRM-free

### 5.1 Aligned

| Concern | Doc | Code |
|---|---|---|
| No Steam required | Offline-first | `steam_enabled: false` default; stub backend |
| No `encrypt_pck` | DRM-free friendly | All presets `encrypt_pck=false` |
| Same Godot presets | Win / Linux / macOS | Shared presets; no project fork |
| CI packaging | butler upload, no Steam DLLs | Sketch in `CI_BUILDS.md` (not automated yet) |

### 5.2 Gaps

| Gap | Detail |
|---|---|
| **No `itch` custom feature** | `PLATFORMS.md` prefers `custom_features` include `itch` (or omit). All shipping presets use `custom_features=""` (demo uses `demo` only). No runtime branch on `OS.has_feature("itch")`. |
| **Steam-only CTAs** | Demo menu / end screen hardcode **Wishlist on Steam** + `store.steampowered.com` URL (`demo_build.gd`, locale `menu.wishlist`). Full itch zip of a demo build would still push Steam. Docs say avoid Steam-only CTAs in itch binaries. |
| **No packaging script** | “Store-specific packaging scripts” promised; repo has SteamPipe under `steam/` only — no butler push helper, no strip-Steam-DLL step as code. |
| **Achievements branding** | Stub still evaluates Steam achievement rules locally when `achievements_enabled` is true. Harmless offline, but itch should not surface Steam achievement UX if/when UI is added. |
| **macOS** | itch `osx` channel listed in CI matrix; mac preset is unsigned stub — same notarize gate as Steam. |

**itch readiness:** binary-compatible **yes** (leave Steam off, zip Win/Linux); storefront-clean packaging **no**.

---

## 6. GOG / Epic readiness

| Store | Doc posture | Code / ops | Audit |
|---|---|---|---|
| **GOG** | Optional after Steam reviews; Galaxy SDK skippable | No Galaxy, no GOG build script, no page pack beyond asset reuse table | **Policy only** — correctly gated; not launch-blocking |
| **Epic** | Opportunistic; never block Steam; EOS non-trivial | No EOS / EGS artifacts; CI explicitly out of scope | **Do not start** until Steam velocity + owner named |

Shared prerequisites both stores still need from this repo:

- Stable Win (+ ideally Linux) export CI (sketch only).  
- Same DRM-free packaging discipline as itch (`steam_enabled` false, no Steam redistributables).  
- Store asset recrops (table in `PLATFORMS.md` — masters live under `docs/RELEASE/capsules/`).  
- Support capacity called out as the real cost — not engine work.

---

## 7. Steamworks feature flags

### 7.1 Flag table — doc vs committed defaults

Source: `game/echo_lattice/config/steam_features.json` ↔ [`STEAMWORKS.md`](../RELEASE/STEAMWORKS.md) §2.

| Flag | Default | Runtime effect | Ship note |
|---|---|---|---|
| `steam_enabled` | `false` | No GodotSteam init; stub backend | Must flip **only** on Steam-branded exports |
| `achievements_enabled` | `true` | Rules eval + stub/local unlocks | OK offline; Partner defs still need AppID |
| `rich_presence_enabled` | `true` | Status strings via facade | No-op without real backend |
| `cloud_save_enabled` | `false` | Local `user://save.json` only | Matches MVP / FAQ “Cloud not in 1.0” |
| `overlay_pause_enabled` | `true` | Pause + music duck on overlay | Needs real backend to fire |
| `prefer_godotsteam_when_present` | `true` | Use GodotSteam if singleton exists | **Addon absent** (`addons/godotsteam/` not in tree) |
| `app_id_placeholder` | `YOUR_APP_ID` | Dev / resolve path | Blocks retail + wishlist URLs |

### 7.2 Architecture fidelity

Doc diagram matches code:

`SteamService` → stub | GodotSteam backend · `SteamAchievements` · `SteamCloudSave` · flags JSON.

Soft-fail behavior is implemented (`steam_godotsteam_backend.gd` thin adapter; init only when enabled + present).

### 7.3 Gaps vs store / Partner expectations

| Topic | Store / STEAMWORKS intent | Gap |
|---|---|---|
| Achievements at launch | `STEAM_STORE_FINAL` “Yes at launch candidate” | Catalog + rules exist; **no Partner AppID**, no icons pipeline in depot, GodotSteam not pinned |
| Cloud | Optional / off | Flag off — **aligned** with FAQ B1 |
| Workshop / leaderboards / IAP / RPT | No | No code paths — **aligned** |
| Overlay pause | On when Steam | Code ready; untested without SDK |
| Export `custom_features=steam` | Recommended for Steam builds | **Not set** on Windows/Linux/mac presets |
| Retail hygiene | Strip `steam_appid.txt`, no `480` | VDF `FileExclusion` lists `steam_appid.txt`; good. Spacewar `480` remains as `spacewar_dev_app_id` in JSON (dev only — do not ship enabled) |
| Linux / mac depots | “Add when multi-OS shipping” | Still Windows-only SteamPipe |

### 7.4 Store checkbox inconsistency

`STEAM_STORE_FINAL.md` §4.3 wants Achievements “Yes” and Deck Playable→Verified, while runtime `steam_enabled` is false and Linux depot missing. Treat store checkboxes as **Partner intent**, not current binary capability, until AppID + GodotSteam + Linux depot land.

---

## 8. Demo depot differences

### 8.1 Implemented (matches `DEMO_SPEC.md`)

| Item | Evidence |
|---|---|
| Feature tag `demo` | Windows Demo preset `custom_features="demo"`; `DemoBuild.is_demo()` also accepts `--demo` |
| Content in | Act I ids `00_`–`08_` including `02_mirror_birth` |
| Content out | `exclude_filter` drops `09_*` / `1*_` / `2*_` / `3*_` chamber JSON; runtime `filter_campaign_ids` |
| Wishlist CTA | Menu + end screen; URL placeholder |
| Self-tests | `test_demo_spec.py` green |

### 8.2 Demo vs full — depot / packaging gaps

| Dimension | Full game (docs) | Demo (docs) | Reality |
|---|---|---|---|
| AppID | `YOUR_APP_ID` | Separate demo AppID | **Neither** assigned; wishlist still full-game placeholder |
| SteamPipe | `steam/echo_lattice/` Windows | Separate demo depot | **No** `app_build_demo.vdf` / demo staging tree |
| OS matrix | Win + Linux (+ mac later) | Fest: **Windows first**; Deck via Proton in acceptance | **Windows Demo only** — no `Linux Demo` preset |
| Achievements | Full catalog | Omit or `mvp: true` only | Runtime loads **full** `achievements_steam.json`; **no `mvp` filter** in `SteamAchievements` |
| Steam DLLs / flags | Steam export may enable Steam | Demo should stay light | Demo preset does not set `steam`; good default |
| Spoiler copy | Four acts | No late-act names | Demo UI copy gated; full tree still in non-demo builds |

### 8.3 Close-out for Next Fest upload

1. Real full-game + demo AppIDs; fix `DemoBuild.WISHLIST_URL`.  
2. Demo SteamPipe VDF + staging (`EchoLatticeDemo.exe` + `.pck`).  
3. Optionally filter achievements to `mvp: true` (or disable Steam achievements on demo AppID).  
4. Decide Deck demo path: native Linux demo export vs Proton of Windows demo — update `DEMO_SPEC.md` to match `STEAM_DECK.md`.

---

## 9. Regional / China considerations

### 9.1 Pricing (docs only)

[`PLATFORMS.md`](../RELEASE/PLATFORMS.md) § Pricing:

- Explicit **CNY / 人民币** on Steam — do not leave USD-only conversion.  
- Band examples: ~$4.99 → **¥18–¥28**; ~$2.99 → **¥12–¥18**; prefer clean ¥21 / ¥28.  
- `STEAM_STORE_FINAL.md` recommends **$6.99 USD** list — CNY should be set deliberately for that anchor (not auto-FX).

**Code:** no pricing/SKU logic (correct — Steamworks Partner). **Gap:** Partner pricing worksheet not in-repo; easy to forget at store setup.

### 9.2 Localization — docs vs code

| Item | Doc | Code |
|---|---|---|
| Shipping locales | `en` + `zh_Hans` | `LocaleManager.SUPPORTED`; CSV columns match; `validate_locale.py` OK |
| OS aliases | `zh`, `zh_CN`, `zh_SG`, … | Implemented in `LOCALE_ALIASES` |
| CJK font | Mandatory vendored Noto/Source Han under `res://fonts/cjk/` | Directory is **empty** (`.gitkeep` only) — tofu risk; warning path exists |
| In-game language dropdown | Deferred | Keys in CSV (`locale.zh_Hans`); settings row not shipped |
| Steam store SC text | Separate marketing track | Not in this audit’s code surface |
| Achievements localization | Display strings later | English-only catalog |

### 9.3 Support FAQ drift (China / language)

`SUPPORT_FAQ.md` A2: “1.0 ships English UI. Other languages are post-1.0.”  
That **contradicts** `LOCALIZATION.md` (shipping `zh_Hans`) and the live CSV. China Steam players hitting FAQ would get wrong guidance.

### 9.4 China Steam extras (not coded; track in Partner)

- Simplified Chinese store description + capsules (art bible SC lockup).  
- Community hub language = player choice; default English OK.  
- Compliance / content survey already framed for puzzle product (`COMPLIANCE_FINAL.md`) — no China-specific content fork in code (good for a non-narrative vignette).  
- No separate China build flavor in export presets (appropriate unless ICP/other channel appears later — out of scope).

---

## 10. Cross-cutting contradictions to resolve

| # | Conflict | Prefer |
|---|---|---|
| C1 | Deck glyphs **Implemented** vs FAQ/store/roadmap “glyphs later” | Update FAQ + store sysreq + roadmap — code already ships glyphs |
| C2 | Demo Deck QA via **Proton** vs Deck authority **native only** | Native Linux demo (or full Linux) for Verified; Proton optional smoke |
| C3 | FAQ “English only 1.0” vs l10n **zh_Hans shipping** | FAQ → English + Simplified Chinese |
| C4 | Store Achievements “Yes” vs `steam_enabled` false + no SDK | Keep stub until AppID; don’t check Partner Achievements live until wired |
| C5 | `PLATFORMS` “Linux stub → Deck” vs Deck doc “Ready to QA” | Linux **export** ready; Linux **depot** still stub |

---

## 11. Priority close-out list

### P0 — blocks honest store / Deck claims

1. Real Steam AppID(s); replace `YOUR_APP_ID` in features, achievements, wishlist, VDFs.  
2. Linux Steam depot + Deck launch option → native `EchoLattice.x86_64`.  
3. GodotSteam 4.3 pin + Steam-only export with `steam_enabled` true / `custom_features=steam`.  
4. Device Deck Verified checklist (60 FPS @ 7 W, suspend/resume, pad-only full run).  
5. Demo depot VDF + separate demo AppID for Next Fest.

### P1 — DRM-free / regional polish

6. itch packaging path (butler sketch → script); optional `itch` feature; suppress Steam wishlist CTA on itch/demo-non-Steam builds.  
7. Vendor CJK font under `fonts/cjk/` (license + size) so `zh_Hans` is shippable on China Steam decks/PCs.  
8. Set explicit CNY price with $6.99 USD anchor.  
9. Fix SUPPORT_FAQ / STEAM_STORE_FINAL / ROADMAP controller + language drift.

### P2 — optional stores

10. GOG page + Win zip after Steam review score gate.  
11. Epic only with funded distribution reason — no EOS work until then.  
12. macOS notarization before public mac on any store.

---

## 12. Related paths (quick index)

```
docs/RELEASE/PLATFORMS.md
docs/RELEASE/STEAM_DECK.md
docs/RELEASE/STEAMWORKS.md
docs/RELEASE/DEMO_SPEC.md
docs/RELEASE/CI_BUILDS.md
docs/RELEASE/LOCALIZATION.md
docs/RELEASE/STEAM_STORE_FINAL.md
game/echo_lattice/export_presets.cfg
game/echo_lattice/config/steam_features.json
game/echo_lattice/scripts/deck_profile.gd
game/echo_lattice/scripts/demo_build.gd
game/echo_lattice/scripts/steam/
steam/echo_lattice/
```

---

*Audit only — no gameplay or export behavior changed in the producing PR.*
