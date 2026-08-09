# Echo Lattice RC1 — Ultra Audit (Executive Synthesis)

| Field | Value |
|---|---|
| **Product** | Echo Lattice (Godot 4.3 · `game/echo_lattice/`) |
| **Base audited** | `cursor/echo-lattice-rc1` @ `03e9a7a` |
| **Synthesis branch** | `cursor/audit-ultra-synthesis` |
| **Date** | 2026-08-09 |
| **Mode** | Cloud-only merge of sibling `cursor/audit-*` findings + RC1 tree spot-checks |
| **Ship-readiness score** | **54 / 100** |

---

## 0. Executive summary

RC1 is a **real offline playable Steam candidate**, not a paper prototype. The habit→geometry loop (walk → checkpoint → authored transform → origami slam → stars → next), Act I → **Mirror Birth** demo spine, Field Ledger visual language, atomic local saves, and offline Steam stub are coherent and largely gated by Python validators that already pass on this tree.

It is **not** Partner-ready and **not** thesis-complete. Steam Partner readiness sits at **~38%** (placeholders, Windows-only depots, no CI workflows, stamped capsules). Habit archetypes, rewrite-score bias, DailyCalendar/seeds, Endless, hard-variant UI, and CrashLogHook autoload are **documented or authored but unwired**. RELEASE “✅ ship” language overstates a11y/l10n end-to-end (CJK font missing; settings/subtitles largely unkeyed). Production audio/art are still procedural placeholders.

**Bottom line:** Safe to treat RC1 as the **integration line for Coming Soon prep**, provided Partner identity + final store assets land first. **Do not** claim Next Fest Verified / paid 1.0 until the gates in §5 are green. Merge sibling **P0 code fixes** (`audit-bugs-core`, `audit-bugs-meta`, `audit-adversarial`) into RC1 before any public build.

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
| Sibling P0 **code** fixes | Landed on #82 / #87 / #88 — **not yet merged into RC1** at synthesis time |

---

## 2. Scorecard (weighted → 54/100)

| Pillar | Weight | Score | Evidence |
|---|---:|---:|---|
| Offline playable loop & softlock bar | 20 | **16** | BUGBASH FIXED set + validators green; Continue/save P0s fixed on sibling PRs |
| Demo / content spine (Act I → Mirror Birth) | 15 | **11** | Demo preset + filter solid; map clones + unwired daily hurt depth |
| Thesis reactivity (habit → authorship) | 10 | **4** | Path→geometry yes; archetype/bias/adaptation mostly sidecar |
| Store & Steam Partner | 20 | **8** | Partner readiness **38%**; placeholders dominate |
| Compat (Win / Linux / Deck / mac) | 10 | **6** | Win primary + Linux preset OK; mac stub; Deck needs device QA + Linux depot |
| Security & privacy | 10 | **7** | 0 Critical; 3 High (Spacewar, cloud save trust, CLI `--out`) |
| A11y / l10n | 8 | **4** | Services exist; CJK font + settings/subtitle `tr()` holes |
| Perf / juice / production audio-art | 7 | **3** | Full-grid redraw + grain; placeholder SFX/stems; capsules stamped |

**Interpretation:** Mid-50s = “ship the **integration branch** and Coming Soon scaffolding,” not “upload depots tomorrow.”

---

## 3. Top 20 risks

Ranked by ship damage × likelihood for Coming Soon → Next Fest → 1.0.

| # | Risk | Sev | Source |
|---:|---|---|---|
| 1 | **Partner identity still placeholders** (`YOUR_APP_ID`, studio/legal, demo wishlist URL) — public CTA / depots cannot go live | P0 | Steam #80, Meta #82, Product #79 |
| 2 | **No export CI / Godot workflows** — every build is manual; checksum/pinning guidance missing | P0 | Architecture #86, Steam #80, Security #76 |
| 3 | **Daily Challenge authority orphaned** — FAQ/calendar claim UTC friend-code ritual; runtime Fisher–Yates ignores `DailyCalendar` / `DailySeeds` | P0 | Bugs-core #87, Adversarial #88, Design #83 |
| 4 | **Continue / save P0s exist on RC1 until sibling merges** — lifetime `completed` skip, wing-complete park, bak destruction, cloud-before-commit, demo↔full queue bleed | P0 | #87, #82, #88 |
| 5 | **Spacewar `480` fallback** if Steam enabled without real AppID | High | Security SEC-01 |
| 6 | **Steam Cloud pull writes unvalidated remote bytes** once flag flips | High | Security SEC-02, Meta P1-06 |
| 7 | **Linux depot + demo depot missing** — Deck Verified / Next Fest upload blocked | High | Compat platforms #75, Steam #80 |
| 8 | **Production audio/art placeholders** — beeps + PLACEHOLDER capsules kill conversion | High | Audio/art #84, Product U01/U07 |
| 9 | **Trailer / final capsules absent** — Coming Soon page cannot convert | High | Product #79, Steam #80 |
| 10 | **Habit systems unwired** — store promise “It learned you” overclaims style reactivity | High | Design #83, Bugs-core CORE-05/06 |
| 11 | **Chamber map clones** (exact Hamming-0 triples) — late-act / hard / Daily novelty collapse | High | Content #85 |
| 12 | **Perf: per-frame full redraw + paper grain spam** — Deck 60 fps @ 7 W at risk | High | Perf #81 |
| 13 | **CJK font not vendored** — zh_Hans tofu on Deck / minimal Windows | High | A11y/l10n #77, Compat #75 |
| 14 | **CrashLogHook not autoloaded** — live-ops crash packs unavailable in RC1 builds | P1 | Meta #82, Architecture #86 |
| 15 | **Docs / code drift** (Endless, Forward+, META APIs, store “keyboard required”) — trust & support landmines | P1 | Architecture #86, Compat #75 |
| 16 | **A11y RELEASE overclaims** — flash double-gate, remap prompts desync, subtitle EN stubs, no gamepad rebind | P1 | A11y #77 |
| 17 | **macOS unsigned stub** — do not list as public SKU | P1 | Desktop compat #78 |
| 18 | **CLI `--screenshot --out` unconstrained paths** in release binaries | High→P1 process | Security SEC-03 |
| 19 | **Parallel-PR residue into `main`** — stale echo-lattice-* PRs risk reintroducing deleted paths | P1 | Architecture #86 |
| 20 | **Hard variants + Endless advertised / authored but not offered** — store/meta honesty risk | P1 | Design #83, Bugs-core CORE-04, Content #85 |

---

## 4. Top 20 upgrades

Merged from Product #79, Audio/art upgrade list #84, Content #85, Design #83, Perf #81 — ordered for **conversion first, thesis second**.

| # | Upgrade | Phase | Why |
|---:|---|---|---|
| 1 | **Replace `YOUR_*` / AppIDs / legal** across store, demo wishlist, VDF, compliance | Coming Soon | Unblocks every Partner action |
| 2 | **Final capsules + 1920×1080 screenshot slate** (no PLACEHOLDER) | Coming Soon | Browse CTR neck |
| 3 | **30s announce trailer** (slam mid-point, muted-safe open) + 15s vertical | Coming Soon | Funnel watch-through |
| 4 | **Live Coming Soon page** (surveys, sysreqs, price band, AI = No) | Coming Soon | Calendar gate |
| 5 | **Merge audit P0 code** (#82 / #87 / #88) into RC1 + re-run BUGBASH | Pre-demo | Session integrity |
| 6 | **Wire DailyCalendar / DailySeeds / `daily_eligible`** | Next Fest | Honest daily + friend-code |
| 7 | **Author rewrite SFX + L0–L3 stems**; map transforms → stingers | Next Fest | Premium feel / trailer audio |
| 8 | **Demo minutes 0–3 → Mirror Birth** cold-player polish | Next Fest | Fest conversion |
| 9 | **Commit `.github` export + selftest CI** (pin Godot + checksums) | Pre-fest | Repeatable builds |
| 10 | **Linux + demo SteamPipe depots**; pin GodotSteam | Next Fest / Deck | Upload + Verified path |
| 11 | **Dirty redraw + bake paper grain**; pool juice particles | Next Fest | Deck 60 fps / slam hitch |
| 12 | **Vendor CJK font**; key Settings / subtitles / demo strings | Next Fest | zh_Hans + a11y honesty |
| 13 | **Autoload CrashLogHook** + Support export pack UI | Next Fest | Live-ops readiness |
| 14 | **De-clone / rewrite** Hamming-0 chamber pairs; fix hard-variant honesty | 1.0 | Late-act novelty |
| 15 | **Wire habit archetype → rewrite bias** on remix/daily (lessons stay forced) | 1.0 | Thesis delivery |
| 16 | **Identity boss portrait readability** (signature fossils) | 1.0 | Boss promise |
| 17 | **META v2 Museum of Selves + self-ghost race** | 1.0 | Retention without mash |
| 18 | **Short Run (3-chamber) + Reader/Cold modes** from balance_v2 | 1.0 | Audience widen |
| 19 | **Steam achievements + optional Cloud** (fail closed AppID; validate cloud saves) | 1.0 | Partner features |
| 20 | **Deck device Verified pass** (7 W / 4 W, suspend, glyphs, UI scale 1.25) | Next Fest→1.0 | Store controller claim |

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
| High | **3** | Spacewar AppID fallback; unvalidated Cloud→save; unconstrained screenshot `--out` |
| Medium | **7** | Telemetry path allowlist, save schema weakness, PII flag not enforced, CI supply chain, PCK encryption posture, stub cloud flags, loader path trust |
| Low | **6** | Export console wrapper, wishlist `shell_open`, crash-pack dest, etc. |

**Security verdict:** **Acceptable for offline stub / Coming Soon** if Steam remains disabled and retail builds fail-closed on AppID. **Not acceptable to enable Steam Cloud / Steam init** until SEC-01/02/03 and cloud conflict policy are closed. Privacy story (local JSONL, opt-in upload no-op) is directionally right but needs in-game opt-out + enforced `include_pii: false`.

---

## 7. Ship-readiness score & milestone gates

### Score: **54 / 100**

| Band | Meaning |
|---|---|
| 80–100 | Paid 1.0 candidate |
| 65–79 | Next Fest demo upload candidate |
| 50–64 | **← RC1 now** — Coming Soon prep / integration line |
| 35–49 | Vertical slice only |
| <35 | Prototype |

### Gate A — Steam Coming Soon (must be green)

- [ ] Real **AppID** + studio/legal names; zero `YOUR_*` in live store/compliance paste
- [ ] Final **capsules** + ≥5 non-placeholder screenshots (≥1080p preferred)
- [ ] **Trailer** (30s) encoded; muted-safe first 5s; AI disclosure **No** submitted
- [ ] Content Survey draft pasted into Partner; privacy URL live
- [ ] Windows export reproducible (CI or checklist) with `steam_enabled=false` for page-only phase OK
- [ ] Merge **audit P0 save/Continue/demo** fixes into RC1
- [ ] Store copy freeze (primary short/long from `STEAM_STORE_FINAL.md`); no horror/AI/loot lead

**Coming Soon readiness estimate after Gate A only:** ~70 partner-page / ~60 overall.

### Gate B — Next Fest demo

- [ ] All Gate A items
- [ ] Demo AppID + depot; wishlist URL real; Act I allow-list verified on exported PCK
- [ ] Cold-player Mirror Birth path; BUGBASH matrix green on Win + Deck (native or documented Proton)
- [ ] Daily wired to calendar **or** store/FAQ copy corrected to actual shuffle semantics (prefer wire)
- [ ] Placeholder audio replaced for warn/slam/footstep + trailer mix
- [ ] Perf pass: bake grain / dirty redraw; slam hitch acceptable on Deck TDP target
- [ ] CJK font vendored if zh_Hans claimed; Settings/demo strings keyed
- [ ] CrashLogHook autoloaded; Support export path documented
- [ ] Linux depot if Deck Verified / Linux demo promised

**Next Fest readiness estimate after Gate B:** ~72–78.

### Gate C — Paid 1.0

- [ ] All Gate B items
- [ ] Habit bias / adaptation on remix+daily; identity boss portraits legible
- [ ] Chamber clone rewrite + hard-variant honesty; Endless **shipped or removed from copy**
- [ ] META retention (Museum / streaks / short run) without breaking offline purity
- [ ] Steam achievements live; Cloud optional with schema validation + conflict policy
- [ ] Security High findings closed; Spacewar impossible in retail
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
1. Merge #87 + #82 + #88 into RC1 → re-run python gates + BUGBASH
2. Partner: AppID / legal / capsules / trailer / Coming Soon page (Gate A)
3. Wire Daily calendar; autoload CrashLogHook; fail-closed AppID
4. Audio identity + grain/dirty-draw perf; demo cold-path polish (Gate B)
5. Content de-clone + habit bias + META Museum (Gate C)
6. Device QA Deck → Verified; only then widen storefronts
```

---

## 10. Method notes

- Synthesized **2026-08-09** from remote branches listed in §1 after poll/fetch; adversarial (#88) and bugs-core (#87) arrived in the same wave as architecture/content.
- Python gates re-run on synthesis workspace: `validate_chambers.py`, `test_rc_polish.py`, `test_balance_v2.py`, `test_release_liveops.py` → **OK** (RC1 tip; does not include sibling code fixes until merged).
- This document is executive-only; detail, repros, and file citations live in the linked sibling audit markdown files on their PRs.
- Re-synthesize if Partner AppID lands or after P0 merges change the Continue/Daily/security posture.
