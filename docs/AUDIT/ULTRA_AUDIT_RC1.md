# Echo Lattice RC1 — Ultra Audit (Executive Synthesis)

| Field | Value |
|---|---|
| **Product** | Echo Lattice (Godot 4.3 · `game/echo_lattice/`) |
| **Base audited** | `cursor/echo-lattice-rc1` @ `03e9a7a` |
| **Synthesis branch** | `cursor/audit-ultra-synthesis` |
| **Date** | 2026-08-09 |
| **Mode** | Cloud-only merge of sibling `cursor/audit-*` findings + RC1 tree spot-checks |
| **Ship-readiness score** | **70 / 100** (post–fix-remaining-p1; Partner/assets still dominate Gate A) |
| **P0 code landed** | **Yes — 2026-08-09** on `cursor/echo-lattice-rc1` (#82 / #87 / #88 + full `docs/AUDIT/`) |
| **Fix wave landed** | **Yes — 2026-08-09** `cursor/fix-*` + meta/identity/ci category lanes on RC1 tip `c5cb181` |
| **Remaining-P1 wave** | **Yes — 2026-08-09** `cursor/fix-remaining-p1` — Cloud save schema, hard-variant menu, telemetry path, rewrite wall-clock |

---

## 0. Executive summary

RC1 is a **real offline playable Steam candidate**, not a paper prototype. The habit→geometry loop (walk → checkpoint → authored transform → origami slam → stars → next), Act I → **Mirror Birth** demo spine, Field Ledger visual language, atomic local saves, and offline Steam stub are coherent and largely gated by Python validators that already pass on this tree.

**P0 code landed (2026-08-09):** SaveManager bak recovery / post-commit cloud push (#82), Continue/`run_cleared` lifetime-skip fix (#87), and adversarial session integrity (build_flavor + book sanitize, focus/pad hold clear, locale HUD refresh + tests) (#88) are merged into this RC1 tip. Full audit set `#75–#89` docs live under [`docs/AUDIT/`](.).

It is **not** Partner-ready. Steam Partner readiness remains **~45%** (real AppID/capsules/trailer still missing; CI + Linux/demo depots now scaffolded). **Landed on RC1 this wave:** SEC-01/02/03 High fixes; DailyCalendar friend-code wire; HabitRewriteLever + RewriteScoreBias; content clone rebuild + rewrite.cap; Endless thin vertical; Field Ledger juice; a11y/l10n tr()+CJK fetch; wishlist CTA gates; Deck GL Compatibility/7W; identity stamps + sealed habit HUD; CrashLogHook autoload; Steam CI workflow. **`cursor/fix-remaining-p1`:** Cloud save schema sync (endless/hard), hard-variant menu after parent clear, SEC-04 telemetry path + SEC-08 PII scrub, CORE-08 wall-clock rewrite settle, habit mode_id for Endless. Production audio/art + real AppID remain open.

**Bottom line:** Safe to treat RC1 as the **integration line for Coming Soon prep**, provided Partner identity + final store assets land first. **Do not** claim Next Fest Verified / paid 1.0 until the gates in §5 are green. Audit P0s + the fix-integration wave are on RC1; Gate A is still blocked on AppID / capsules / trailer / Partner paste.

---

## 1. Cross-linked audit PRs

| # | Branch | Title | Focus doc |
|---:|---|---|---|
| [#75](https://github.com/cmp07/Game-/pull/75) | `cursor/audit-compat-platforms-1749` | COMPAT_PLATFORMS — Deck / Proton / itch / Steamworks / China | [`COMPAT_PLATFORMS.md`](COMPAT_PLATFORMS.md) |
| [#76](https://github.com/cmp07/Game-/pull/76) | `cursor/audit-security` | Security audit (RC1) | [`SECURITY.md`](SECURITY.md) |
| [#77](https://github.com/cmp07/Game-/pull/77) | `cursor/audit-a11y-l10n-8e3d` | A11y + l10n vs RELEASE | [`A11Y_L10N.md`](A11Y_L10N.md) |
| [#78](https://github.com/cmp07/Game-/pull/78) | `cursor/audit-compat-desktop` | Desktop compatibility matrix | [`COMPAT_DESKTOP.md`](COMPAT_DESKTOP.md) |
| [#79](https://github.com/cmp07/Game-/pull/79) | `cursor/audit-product` | Product upgrades (Impact×Effort) | [`PRODUCT_UPGRADES.md`](PRODUCT_UPGRADES.md) |
| [#80](https://github.com/cmp07/Game-/pull/80) | `cursor/audit-steam` | Steam Partner readiness (38%) | [`STEAM_READINESS.md`](STEAM_READINESS.md) |
| [#81](https://github.com/cmp07/Game-/pull/81) | `cursor/audit-perf` | Performance audit | [`PERFORMANCE.md`](PERFORMANCE.md) |
| [#82](https://github.com/cmp07/Game-/pull/82) | `cursor/audit-bugs-meta` | Meta/UI/save bugs + SaveManager P0s | [`BUGS_META.md`](BUGS_META.md) |
| [#83](https://github.com/cmp07/Game-/pull/83) | `cursor/audit-design` | Design / gameplay deep audit | [`DESIGN_GAMEPLAY.md`](DESIGN_GAMEPLAY.md) |
| [#84](https://github.com/cmp07/Game-/pull/84) | `cursor/audit-audio-art` | Field Ledger audio/art/UX | [`AUDIO_ART_UX.md`](AUDIO_ART_UX.md) · [`UPGRADE_LIST.md`](UPGRADE_LIST.md) |
| [#85](https://github.com/cmp07/Game-/pull/85) | `cursor/audit-content` | Chamber content + upgrade backlog | [`CONTENT_CHAMBERS.md`](CONTENT_CHAMBERS.md) |
| [#86](https://github.com/cmp07/Game-/pull/86) | `cursor/audit-architecture` | Architecture & tech debt | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| [#87](https://github.com/cmp07/Game-/pull/87) | `cursor/audit-bugs-core` | Core gameplay bugs + Continue P0s | [`BUGS_CORE.md`](BUGS_CORE.md) |
| [#88](https://github.com/cmp07/Game-/pull/88) | `cursor/audit-adversarial` | Adversarial QA + session integrity | [`ADVERSARIAL_QA.md`](ADVERSARIAL_QA.md) |
| *(this PR)* | `cursor/audit-ultra-synthesis` | **Echo Lattice RC1 Ultra Audit** | [`ULTRA_AUDIT_RC1.md`](ULTRA_AUDIT_RC1.md) |

**Related (out of RC1 ultra set):** [#9](https://github.com/cmp07/Game-/pull/9) creator-project audit · [#68](https://github.com/cmp07/Game-/pull/68) RC1 integration · release packs [#63](https://github.com/cmp07/Game-/pull/63)–[#74](https://github.com/cmp07/Game-/pull/74).

### Coverage / gaps

| Lane | Status |
|---|---|
| Design, content, architecture, perf, security, Steam, desktop/platform compat, a11y/l10n, audio/art, product upgrades, bugs-core, bugs-meta, adversarial QA | **Ingested** (branches + PRs above) |
| Hardware Deck / Win / mac device farm | **Gap** — all audits cloud-static; Verified / notarization unproven |
| Partner console (live AppID, surveys, depots) | **Gap** — correctly not invented |
| Godot `--selftest` in this environment | **Gap** — no Godot binary; Python gates used as proxy |
| Sibling P0 **code** fixes | **Merged into RC1** (2026-08-09) — #82 / #87 / #88 + SaveManager union |
| Post-audit **fix-*** / category lanes | **Merged into RC1** (2026-08-09) — sec-high, daily, habit, content, meta, perf, a11y, endless, juice, identity, ci, wishlist, compat |

---

## 2. Scorecard (weighted → 70/100)

| Pillar | Weight | Score | Evidence |
|---|---:|---:|---|
| Offline playable loop & softlock bar | 20 | **18** | Continue/save P0s + Daily + Endless + Hard+ wing; rewrite settle wall-clock |
| Demo / content spine (Act I → Mirror Birth) | 15 | **13** | Clone maps rebuilt; rewrite.cap; identity stamps after Mirror Birth |
| Thesis reactivity (habit → authorship) | 10 | **8** | HabitRewriteLever + score bias + Endless mode floor; sealed habit HUD until birth |
| Store & Steam Partner | 20 | **10** | Wishlist CTA gates + CI/depot scaffolds; AppID/capsules/trailer still open (~45%) |
| Compat (Win / Linux / Deck / mac) | 10 | **7** | GL Compatibility tag; Deck 7W defaults; Linux/demo depot VDFs added |
| Security & privacy | 10 | **9** | SEC High closed; Cloud schema matches save_to_disk; telemetry path + PII scrub |
| A11y / l10n | 8 | **6** | Settings/demo/glyphs keyed; CJK fetch/OFL; subtitle background |
| Perf / juice / production audio-art | 7 | **5** | Baked grain + dirty redraw + particle pool; Field Ledger juice; stems still placeholder |

**Interpretation:** Low-70s = “integration line is playable + thesis-reactive,” still **not** Partner upload-ready until Gate A assets land.

---

## 3. Top 20 risks

Ranked by ship damage × likelihood for Coming Soon → Next Fest → 1.0.

| # | Risk | Sev | Source |
|---:|---|---|---|
| 1 | **Partner identity still placeholders** (`YOUR_APP_ID`, studio/legal, demo wishlist URL) — public CTA / depots cannot go live | P0 | Steam #80, Meta #82, Product #79 |
| 2 | ~~**No export CI / Godot workflows**~~ — **mitigated:** `.github/workflows/ci.yml` + Linux/demo depot VDFs on RC1; still needs green CI run + real AppIDs | P0 → P1 | Architecture #86, Steam #80, `cursor/steam-ci-depots` |
| 3 | ~~**Daily Challenge authority orphaned**~~ — **mitigated on RC1** via `cursor/fix-daily-calendar` (calendar_90 + friend codes) | ~~P0~~ → closed | Bugs-core #87, Adversarial #88 |
| 4 | ~~**Continue / save P0s on RC1**~~ — **LANDING NOTE:** lifetime `completed` skip, bak destruction, cloud-before-commit, demo↔full queue bleed **mitigated on RC1** via #82/#87/#88 merge | ~~P0~~ → closed | #87, #82, #88 |
| 5 | ~~**Spacewar `480` fallback**~~ — **mitigated** (`allow_spacewar_dev` fail-closed; SEC-01 tests green) | ~~High~~ → closed | Security SEC-01 / `cursor/fix-sec-high` |
| 6 | ~~**Steam Cloud pull unvalidated**~~ — **mitigated** (validate_save_text + updated_at + atomic write) | ~~High~~ → closed | SEC-02 / bugs-meta-p1 |
| 7 | ~~**Linux depot + demo depot missing**~~ — **mitigated** (VDF + CI scaffold on RC1); real AppIDs + upload still open | High → P1 | `cursor/steam-ci-depots` |
| 8 | **Production audio/art placeholders** — beeps + PLACEHOLDER capsules kill conversion | High | Audio/art #84, Product U01/U07 |
| 9 | **Trailer / final capsules absent** — Coming Soon page cannot convert | High | Product #79, Steam #80 |
| 10 | ~~**Habit systems unwired**~~ — **mitigated** (HabitRewriteLever + score bias + Endless mode floor); Hard+ menu landed | ~~High~~ → closed | Design #83 / `cursor/fix-habit-wire` + `fix-remaining-p1` |
| 11 | ~~**Chamber map clones**~~ — **mitigated** (Twin Rail / Conductor / Mirror Birth+ rebuilt) | ~~High~~ → closed | Content #85 / `cursor/fix-content-clones` |
| 12 | ~~**Perf: full redraw + grain spam**~~ — **mitigated** (bake + dirty redraw + particle pool); device Deck QA still open | High → P1 | Perf #81 / `cursor/fix-perf-grain` |
| 13 | ~~**CJK font not vendored**~~ — **mitigated** (fetch script + OFL + locale keys; binary via LFS) | High → P1 | `cursor/fix-a11y-l10n` |
| 14 | ~~**CrashLogHook not autoloaded**~~ — **mitigated** on RC1 via `cursor/bugs-meta-p1` | ~~P1~~ → closed | Meta #82 |
| 15 | ~~**Docs / code drift** (Endless, Forward+, store “keyboard required”)~~ — **partially mitigated** (store controller copy + audit stamps); META Museum still absent | P1 → P2 | Architecture #86 / `cursor/fix-remaining-p1` |
| 16 | ~~**A11y RELEASE overclaims**~~ — **partially mitigated** (tr()+glyphs+subtitle bg); flash/remap honesty still needs RELEASE sync | P1 | `cursor/fix-a11y-l10n` |
| 17 | **macOS unsigned stub** — do not list as public SKU | P1 | Desktop compat #78 |
| 18 | ~~**CLI `--screenshot --out` unconstrained**~~ — **mitigated** (SEC-03 path allowlist) | ~~High~~ → closed | `cursor/fix-sec-high` |
| 19 | **Parallel-PR residue into `main`** — stale echo-lattice-* PRs risk reintroducing deleted paths | P1 | Architecture #86 |
| 20 | ~~**Hard variants** unplayable from menu~~ — **mitigated** (Hard+ wing after parent clear); caption/map honesty polish remains | P1 → closed UI | Design #83 / `cursor/fix-remaining-p1` |
| 21 | ~~**Cloud save schema rejected real RC1 saves**~~ — **mitigated** (`SAVE_ALLOWED_KEYS` / `SAVE_RUN_MODES` sync) | ~~P1~~ → closed | SEC-02 drift / `cursor/fix-remaining-p1` |

---

## 4. Top 20 upgrades

Merged from Product #79, Audio/art upgrade list #84, Content #85, Design #83, Perf #81 — ordered for **conversion first, thesis second**.

| # | Upgrade | Phase | Why |
|---:|---|---|---|
| 1 | **Replace `YOUR_*` / AppIDs / legal** across store, demo wishlist, VDF, compliance | Coming Soon | Unblocks every Partner action |
| 2 | **Final capsules + 1920×1080 screenshot slate** (no PLACEHOLDER) | Coming Soon | Browse CTR neck |
| 3 | **30s announce trailer** (slam mid-point, muted-safe open) + 15s vertical | Coming Soon | Funnel watch-through |
| 4 | **Live Coming Soon page** (surveys, sysreqs, price band, AI = No) | Coming Soon | Calendar gate |
| 5 | ~~**Merge audit P0 code** (#82 / #87 / #88) into RC1~~ — **done 2026-08-09**; re-run BUGBASH on device | Pre-demo | Session integrity |
| 6 | ~~**Wire DailyCalendar / DailySeeds / `daily_eligible`**~~ — **done on RC1** (`cursor/fix-daily-calendar`) | Next Fest | Honest daily + friend-code |
| 7 | **Author rewrite SFX + L0–L3 stems**; map transforms → stingers | Next Fest | Premium feel / trailer audio |
| 8 | **Demo minutes 0–3 → Mirror Birth** cold-player polish | Next Fest | Fest conversion |
| 9 | ~~**Commit `.github` export + selftest CI**~~ — **scaffold landed** (`cursor/steam-ci-depots`); pin Godot checksums + green run | Pre-fest | Repeatable builds |
| 10 | ~~**Linux + demo SteamPipe depots**~~ — **VDF landed**; bake real AppIDs + pin GodotSteam | Next Fest / Deck | Upload + Verified path |
| 11 | ~~**Dirty redraw + bake paper grain**; pool juice~~ — **done on RC1** (`cursor/fix-perf-grain` + juice) | Next Fest | Deck 60 fps / slam hitch |
| 12 | ~~**Vendor CJK font**; key Settings / subtitles / demo~~ — **fetch+keys landed**; confirm LFS binary in exports | Next Fest | zh_Hans + a11y honesty |
| 13 | ~~**Autoload CrashLogHook** + Support export~~ — **done on RC1** (`cursor/bugs-meta-p1`) | Next Fest | Live-ops readiness |
| 14 | ~~**De-clone / rewrite** Hamming-0 chamber pairs~~ — **maps rebuilt**; hard-variant honesty polish remains | 1.0 | Late-act novelty |
| 15 | ~~**Wire habit archetype → rewrite bias**~~ — **done on RC1** (`cursor/fix-habit-wire`) | 1.0 | Thesis delivery |
| 16 | ~~**Identity boss portrait readability**~~ — **stamps + sealed habit HUD landed**; portrait polish open | 1.0 | Boss promise |
| 17 | **META v2 Museum of Selves + self-ghost race** | 1.0 | Retention without mash |
| 18 | **Short Run (3-chamber) + Reader/Cold modes** from balance_v2 | 1.0 | Audience widen |
| 19 | **Steam achievements + optional Cloud** (fail closed AppID; validate cloud saves) — Cloud validate landed; achievements open | 1.0 | Partner features |
| 20 | **Deck device Verified pass** (7 W / 4 W, suspend, glyphs, UI scale 1.25) — GL Compat + 7W defaults landed; device pass open | Next Fest→1.0 | Store controller claim |

Defer (fence): Workshop/editor, online leaderboards, Act V Afterimage DLC, cosmetics shop, GOG/Epic until Steam proof.

---

## 5. Compatibility verdict

| Surface | Verdict |
|---|---|
| **Windows 10/11 x86_64** | **Supported — shipping primary.** Offline loop portable; Steamworks stubbed by default. |
| **Linux x86_64 (SteamOS / Ubuntu-class)** | **Supported export; depot QA open.** Native preferred for Deck. |
| **Steam Deck** | **Prep-complete, device-unproven.** Input/glyphs/FPS caps/layout checks exist; Linux depot + hardware checklist still open. Proton = fallback only. |
| **macOS** | **Stub only.** Unsigned / un-notarized — do not sell. |
| **itch DRM-free** | **OK** while `steam_enabled` stays false; need itch packaging (no Steam CTA in binary). |
| **GOG / Epic / China ops** | Correctly deferred; zh_Hans strings exist but **font + CNY store automation** missing. |

**Compatibility verdict:** **Conditional pass for Windows Coming Soon / demo scaffolding; fail for multi-depot Verified claims until Linux depot + device QA + mac notarization policy are explicit.**

---

## 6. Security verdict

| Band | Count | Headline |
|---|---:|---|
| Critical | **0** | No secrets, no dynamic `Expression`/eval, no always-on network upload client |
| High | **0** (was 3) | SEC-01/02/03 mitigated on RC1 (`allow_spacewar_dev`, cloud validate+atomic+newer-wins, screenshot `--out` allowlist) |
| Medium | **5** open (+2 partial) | Telemetry path + PII scrub landed; residual: full event allowlist, CI pin, PCK encryption, stub cloud flags, loader path trust |
| Low | **6** | Export console wrapper, wishlist `shell_open`, crash-pack dest, etc. |

**Security verdict:** **Acceptable for offline stub / Coming Soon** with SEC High closed on RC1. Steam init / Cloud still require real AppID + Partner config before enabling in retail. Privacy story (local JSONL, opt-in upload no-op) is directionally right but needs in-game opt-out + enforced `include_pii: false`.

---

## 7. Ship-readiness score & milestone gates

### Score: **70 / 100**

| Band | Meaning |
|---|---|
| 80–100 | Paid 1.0 candidate |
| 65–79 | Next Fest demo upload candidate |
| 65–79 | **← RC1 now** — Next Fest demo upload candidate *if* Gate A Partner assets land |
| 50–64 | Coming Soon prep / integration line |
| 35–49 | Vertical slice only |
| <35 | Prototype |

### Gate A — Steam Coming Soon (must be green)

- [ ] Real **AppID** + studio/legal names; zero `YOUR_*` in live store/compliance paste
- [ ] Final **capsules** + ≥5 non-placeholder screenshots (≥1080p preferred)
- [ ] **Trailer** (30s) encoded; muted-safe first 5s; AI disclosure **No** submitted
- [ ] Content Survey draft pasted into Partner; privacy URL live
- [x] Windows export reproducible (CI or checklist) with `steam_enabled=false` for page-only phase OK — **CI workflow landed; confirm green run**
- [x] Merge **audit P0 save/Continue/demo** fixes into RC1 (**done 2026-08-09**)
- [ ] Store copy freeze (primary short/long from `STEAM_STORE_FINAL.md`); no horror/AI/loot lead

**Coming Soon readiness estimate after Gate A only:** ~70 partner-page / ~60 overall.

### Gate B — Next Fest demo

- [ ] All Gate A items
- [ ] Demo AppID + depot; wishlist URL real; Act I allow-list verified on exported PCK
- [ ] Cold-player Mirror Birth path; BUGBASH matrix green on Win + Deck (native or documented Proton)
- [x] Daily wired to calendar **or** store/FAQ copy corrected to actual shuffle semantics (prefer wire) — **wired on RC1**
- [ ] Placeholder audio replaced for warn/slam/footstep + trailer mix
- [x] Perf pass: bake grain / dirty redraw; slam hitch acceptable on Deck TDP target — **code landed; device QA open**
- [x] CJK font vendored if zh_Hans claimed; Settings/demo strings keyed — **fetch script + OFL + keyed strings; font binary via LFS**
- [x] CrashLogHook autoloaded; Support export path documented
- [x] Linux depot if Deck Verified / Linux demo promised — **VDF + CI scaffold; upload still needs AppIDs**

**Next Fest readiness estimate after Gate B:** ~72–78.

### Gate C — Paid 1.0

- [ ] All Gate B items
- [x] Habit bias / adaptation on remix+daily; identity boss portraits legible — **lever + stamps on RC1; polish open**
- [x] Chamber clone rewrite + hard-variant honesty; Endless **shipped or removed from copy** — **clones + thin Endless on RC1**
- [ ] META retention (Museum / streaks / short run) without breaking offline purity
- [ ] Steam achievements live; Cloud optional with schema validation + conflict policy
- [x] Security High findings closed; Spacewar impossible in retail
- [ ] Deck Verified questionnaire evidence; mac public only if notarized
- [ ] A11y RELEASE claims match runtime (flash, remap glyphs, subtitles, UI scale on Deck)
- [ ] Parallel stale PRs closed or rebased; `main` merge policy respected (RC1 review-only)

**1.0 readiness estimate after Gate C:** ≥85.

---

## 8. What is already strong (do not regress)

1. Pure fantasy cohesion — no combat/loot/horror mash in the playable product.
2. Act I pedagogy → Mirror Birth hook; demo feature filter + Windows Demo preset.
3. Field Ledger materials / palette / origami slam language (placeholders aside).
4. Atomic `user://save.json` design (+ sibling bak/cloud/demo hardenings).
5. Offline Steam stub + feature flags; gameplay never requires Steam API.
6. Chamber JSON pipeline + Python validators (39 chambers OK; balance/liveops/demo/locale/a11y smoke green).
7. Softlock recovery + rewrite input lock + gamepad defaults for Deck prep.
8. Compliance draft answers consistent with abstract puzzle content (AI = No).

---

## 9. Recommended studio sequence (next actions)

```text
1. ✅ Merge #87 + #82 + #88 into RC1
2. ✅ Land fix-* / category wave (sec/daily/habit/content/meta/perf/a11y/endless/juice/identity/ci/wishlist/compat)
3. ✅ Remaining code P1s (cloud save schema, Hard+ menu, telemetry path, rewrite wall-clock) — cursor/fix-remaining-p1
4. Partner: AppID / legal / capsules / trailer / Coming Soon page (Gate A — blocks public)
5. Confirm CI green; bake real AppIDs into VDFs; device BUGBASH Win+Deck
6. Audio identity + demo cold-path polish (Gate B remainder)
7. META Museum retention polish (Gate C remainder) → Deck Verified
```

---

## 10. Method notes

- Synthesized **2026-08-09** from remote branches listed in §1 after poll/fetch; adversarial (#88) and bugs-core (#87) arrived in the same wave as architecture/content.
- Python gates re-run on synthesis workspace: `validate_chambers.py`, `test_rc_polish.py`, `test_balance_v2.py`, `test_release_liveops.py` → **OK** (pre-merge tip).
- **P0 landing note (2026-08-09):** #82 / #87 / #88 code + #75–#81 / #83–#86 / #89 audit docs merged into `cursor/echo-lattice-rc1`; SaveManager conflicts resolved to keep bak recovery + `run_cleared` + book sanitize. Re-run full `game/echo_lattice/tests/` on the landed tip.
- This document is executive-only; detail, repros, and file citations live in the linked sibling audit markdown files on their PRs.
- **Fix-wave note (2026-08-09):** Integrated `cursor/fix-*` plus category lanes `bugs-meta-p1` / `form-identity-ledger` / `steam-ci-depots` into `cursor/echo-lattice-rc1` @ `c5cb181`. Python suite green (17/17). Score **54 → 68**. Re-synthesize when Partner AppID / capsules land.
- **Remaining-P1 note (2026-08-09):** `cursor/fix-remaining-p1` closes Cloud save-schema drift, Hard+ menu (U7), SEC-04/08 telemetry hardening, CORE-08 wall-clock settle, habit Endless mode floor. Score **68 → 70**. Real AppID / capsules / trailer still Gate A.
