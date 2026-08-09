# Echo Lattice — Execution Roadmap (Depth First)

**Role:** Ordered phase plan + PR waves after Steam pack freeze.  
**Authority peers:** [`MASTER_1000X.md`](MASTER_1000X.md) · [`FEATURE_BACKLOG_1000X.md`](FEATURE_BACKLOG_1000X.md) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md)  
**Base integration line:** `cursor/echo-lattice-rc1`  
**Policy:** **Pause Steam. Deepen game.** Resume Partner only after §Gates.  
**Hard rules:** No genre mash. No invented AppIDs / DepotIDs.

---

## 0. Phase order (locked)

```
0. Steam pack FROZEN     → docs/BACKUP + tag backup/echo-lattice-rc1-steam-pack
1. V3 vertical           → feel · habit bite · shell · first-10 ceremony
2. Content               → chamber standard · denser I–IV · identity portraits
3. Audio / art           → authored earprint · tiles · type · tech-art
4. Meta                  → Museum race · Habit Ledger loop · streak honesty
5. Steam resume          → AppID · encode · Partner paste · Coming Soon
```

| Do | Do not |
|---|---|
| Land Phases 1–4 on RC1 (or short-lived `cursor/v3-*` / `cursor/depth-*` PRs into RC1) | Open Coming Soon / invent AppIDs during 1–4 |
| Keep `docs/RELEASE/`, `steam/`, Gate A media intact | Delete Steam pack “to focus” |
| Delete-or-ship dead dials (Reader/Cold, race claims) | Sell Museum race / streaks before code |
| Expand **same verb** | Mash horror / coin / idle / combat / cards |

---

## 1. Phase 0 — Steam pack freeze (done)

| Item | Ref |
|---|---|
| Freeze tip | `5f0d463` |
| Branch + tag | `backup/echo-lattice-rc1-steam-pack` |
| Index | [`../BACKUP/README.md`](../BACKUP/README.md) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |
| Ship-readiness | **78 / 100** (pack) — game-feel **41 / 100** ([`MASTER_1000X.md`](MASTER_1000X.md) §3) |

**Exit:** Durable snapshot exists; agents treat Steam work as **parked**, not deleted.

---

## 2. Phase 1 — V3 vertical (feel the verb)

**Goal:** One cold session stops reading as a 12-hour prototype and starts reading as a document game — without new genres.

### Wave 1A — Kill prototype tells (P0 surface)

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W1A.1** | `cursor/v3-end-language-*` | Rename `END OF SLICE` → product end card; purge “vertical slice” from player strings | No player-facing “slice” |
| **W1A.2** | `cursor/v3-stars-ink-*` | Replace ASCII `***` / `---` with ink stamp ★ glyphs (won + Museum) | Win screen looks authored |
| **W1A.3** | `cursor/v3-type-latin-*` | Vendor latin display + mono per art bible; stop ThemeDB-only brand | Brand lockup uses ledger type |
| **W1A.4** | `cursor/v3-shell-boot-*` | Custom boot splash (`paper_bone` / ink stamp); quiet cold boot | No Godot robot / grey flash |

**Docs:** [`FEELS_PROTOTYPE.md`](FEELS_PROTOTYPE.md) · [`PRODUCTION_CRAFT.md`](PRODUCTION_CRAFT.md)

### Wave 1B — Feel juice V3 (punctuation)

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W1B.1** | `cursor/v3-step-weight-*` | Distinct success vs blocked footstep; chalk stamp vs ink bump | Eyes-closed success/block identifiable |
| **W1B.2** | `cursor/v3-telegraph-*` | Buffer foreshadow layers; style cells vs path echoes differentiated | Pause mid-chamber → predict fossil zone |
| **W1B.3** | `cursor/v3-slam-defaults-*` | Paper-fold slam defaults; shake/bloom opt-in Impact; hitstop wall-clock VFX | Slam reads as document crease |
| **W1B.4** | `cursor/v3-fail-clarity-*` | Softlock / blocked / bad-rewrite readable in ≤3 frames + footnote hook (F15) | Fail explains itself |

**Docs:** [`FEEL_JUICE_V3.md`](FEEL_JUICE_V3.md)

### Wave 1C — Habit bite (thesis oxygen)

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W1C.1** | `cursor/v3-habit-counter-*` | Remix/Daily/Endless: 1–3 soft counter cells + win names archetype (F03/F16) | Blind Act II: “it punished my looping” |
| **W1C.2** | `cursor/v3-annotations-*` | Margin footnotes after rewrite / softlock / identity (F02/F08) | Ledger voice, not quest log |
| **W1C.3** | `cursor/v3-birth-ceremony-*` | Mirror Birth + Looking Glass setpiece contract (hold, PA, coach line) | First authorship lands ≤3:30 premium path |
| **W1C.4** | `cursor/v3-claim-hygiene-*` | Soften FAQ/ROADMAP race & streak claims until Phase 4 | Claims ≤ code ([`SYSTEMS_TRUTH`](SYSTEMS_TRUTH.md)) |

**Docs:** [`HABIT_SYSTEMS_V3.md`](HABIT_SYSTEMS_V3.md) · [`FIRST_TEN_MINUTES.md`](FIRST_TEN_MINUTES.md) · backlog Pack A

### Wave 1D — Diegetic shell / UI

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W1D.1** | `cursor/v3-ui-diegetic-*` | Punch-card pause / settings-as-object / transitions as page turns | No frosted-glass OS prefs |
| **W1D.2** | `cursor/v3-first-10-polish-*` | Quiet Span → Mirror Birth premium timing + undo teach once | Matches [`FIRST_TEN_MINUTES`](FIRST_TEN_MINUTES.md) spine |

**Docs:** [`UI_DIEGETIC_V3.md`](UI_DIEGETIC_V3.md) · [`NARRATIVE_ARC.md`](NARRATIVE_ARC.md)

**Phase 1 exit gate (G1):** Game-feel score **≥ 55 / 100** on re-score rubric in [`MASTER_1000X.md`](MASTER_1000X.md) §3 (same axes). Prototype P0 tells 1–5 closed. Habit answer legible on at least one remix clear.

---

## 3. Phase 2 — Content (authored depth)

**Goal:** Denser four Acts + honest Hard track + identity portraits — **not** Act V yet.

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W2.1** | `cursor/depth-chamber-standard-*` | Enforce [`CHAMBER_STANDARD`](CHAMBER_STANDARD.md) validators (clone Hamming, hard parent honesty, role tags) | Detector green on roster |
| **W2.2** | `cursor/depth-declone-*` | Finish remaining near-clone / boss footprint debt | No Hamming-0 campaign pairs |
| **W2.3** | `cursor/depth-denser-4-*` | +2–4 unique chambers/act (protect demo `00`–`08`); setpiece pass | ~44–46 campaign clears band |
| **W2.4** | `cursor/depth-hard-track-*` | Hard ×3–4/act with measurable tighten vs parent | Hard is a second track, not a par lie |
| **W2.5** | `cursor/depth-identity-portrait-*` | Boss stamps drama + Portrait Star Fold (F10); gallery hooks | Boss clear leaves readable silhouette |
| **W2.6** | `cursor/depth-dialects-*` | Soft rewrite dialects (F05/F14) — family still taught; never loadout | Lessons force family; dialects on remix |

**Docs:** [`CONTENT_EXPANSION.md`](CONTENT_EXPANSION.md) · [`CHAMBER_STANDARD.md`](CHAMBER_STANDARD.md) · Content Bible

**Fence:** Act V Afterimage / `invert` lesson stay **post-1.0** unless leadership reopens ([`../RELEASE/ROADMAP.md`](../RELEASE/ROADMAP.md)).

**Phase 2 exit gate (G2):** Clone detector green; four identity bosses leave distinct stamps; denser-4 targets met or explicitly deferred with issue list; Hard parents honest.

---

## 4. Phase 3 — Audio / art (earprint + page)

**Goal:** Stop sounding/looking like placeholder generators on the hero path.

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W3.1** | `cursor/depth-audio-slam-phrase-*` | Authored 5-beat rewrite phrase; replace placeholder rewrite OGGs | Clappable slam phrase; no `_placeholder` on hero SFX |
| **W3.2** | `cursor/depth-audio-earprints-*` | Per-operator stingers + L0–L3 habit motif stems ([`AUDIO_1_0_CUE_SHEET`](AUDIO_1_0_CUE_SHEET.md)) | Blind ID of mirror vs thicken by ear |
| **W3.3** | `cursor/depth-audio-silence-*` | Authored rests; Induction silence policy honored | Silence is composition, not missing file |
| **W3.4** | `cursor/depth-art-mvp-tiles-*` | Handed MVP tiles (player, checkpoint, goal, wall junctions, fold strip) | Generator not sole hero tileset |
| **W3.5** | `cursor/depth-art-wing-tints-*` | Act paper tints + fossil aging (F22) within ledger family | Wings readable without neon |
| **W3.6** | `cursor/depth-tech-art-*` | Grain bake / dirty redraw / slam strip performance on Deck targets | [`TECH_ART_V3`](TECH_ART_V3.md) budgets held |

**Docs:** [`AUDIO_V3.md`](AUDIO_V3.md) · [`ART_DIRECTION_V3.md`](ART_DIRECTION_V3.md) · [`TECH_ART_V3.md`](TECH_ART_V3.md)

**Phase 3 exit gate (G3):** Demo hero path has **zero** `_placeholder` audio filenames in use; latin type + MVP tiles on Act I; mute-safe Mirror Birth still sells authorship; compliance never calls DSP “final mix.”

---

## 5. Phase 4 — Meta (Habit Ledger retention)

**Goal:** Modes compose one loop — *walk → fossilize → name → pressure → archive → race*.

| PR wave | Branch pattern | Scope | Acceptance |
|---|---|---|---|
| **W4.1** | `cursor/depth-museum-race-*` | Ghost of Past Self race chalk (F01); optional; never blocks clear | Trailer chalk-on-chalk still possible |
| **W4.2** | `cursor/depth-stamp-gallery-*` | Identity stamp gallery in Museum (F04) | Births + bosses browsable |
| **W4.3** | `cursor/depth-daily-ghost-*` | Yesterday’s Daily Ghost (F07) + assist prefers past self (F18) | Offline authorship social |
| **W4.4** | `cursor/depth-streaks-truth-*` | Soft daily streak **or** permanently delete streak claims | FAQ matches save schema |
| **W4.5** | `cursor/depth-meta-loop-ui-*` | Field Index session intent → mode roles per [`META_LOOPS_V3`](META_LOOPS_V3.md) | Modes feel like stations, not add-ons |
| **W4.6** | `cursor/depth-balance-truth-*` | Ship Reader/Cold **or** delete dead dials from balance_v2 | No fake mode UI |

**Docs:** [`META_LOOPS_V3.md`](META_LOOPS_V3.md) · backlog Pack B

**Phase 4 exit gate (G4):** Museum race ships; claims congruent; game-feel re-score **≥ 70 / 100**; systems-truth “Museum race / streaks” bars no longer claim-only.

---

## 6. Phase 5 — Steam resume (only then)

**Prerequisite:** G1–G4 green (or explicit written waiver from product owner).  
**Source of truth for pack files:** [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) @ `5f0d463` (merge forward if RC1 tip moved).

| PR wave / human step | Scope | Notes |
|---|---|---|
| **W5.0 Human** | Create real AppID + DepotIDs + demo AppID in Partner | **Do not invent in git** |
| **W5.1** | `cursor/steam-resume-ids-*` | Replace `YOUR_*` tokens after Partner assign | Follow [`APPID_PLACEHOLDER_GATES`](../RELEASE/APPID_PLACEHOLDER_GATES.md) |
| **W5.2** | Re-capture screenshots / trailer encode from **deepened** build | Editor pack may need refresh post art/audio |
| **W5.3** | Partner paste: store freeze, legal, survey, AI=No, privacy HTTPS | Human console |
| **W5.4** | Capsule / screenshot / trailer upload + depot bake | Coming Soon unblocked |
| **W5.5** | Deck device Verified pass | Never proven in cloud-only |

**Phase 5 exit gate (G5):** Public Coming Soon live with real AppID; demo wishlist CTA points at full game; no Spacewar in retail.

---

## 7. Parallelism rules

| Parallel OK | Serialize |
|---|---|
| W1A.* docs/string PRs alongside W1B feel | Habit counter (W1C.1) before selling “style learning” |
| Content validators (W2.1) early anytime | Act V / invert behind 1.0 fence |
| Tech-art perf spikes during Phase 3 | Steam resume before G1–G4 |
| Claim hygiene (W1C.4) immediately | Inventing AppIDs “for CI” |

Suggested agent naming: `cursor/v3-*` (Phase 1), `cursor/depth-*` (Phases 2–4), `cursor/steam-resume-*` (Phase 5 only).

---

## 8. Depth gates checklist (Steam stays frozen until)

- [ ] **G1** V3 vertical — prototype P0 tells closed; habit answer legible; feel ≥55  
- [ ] **G2** Content — clone-free denser-4 path; honest Hard; identity stamps  
- [ ] **G3** Audio/art — hero-path authored earprint + MVP tiles/type  
- [ ] **G4** Meta — Museum race; claim hygiene; feel ≥70  
- [ ] **G5** Steam resume — human AppID + uploads (after G1–G4)

Until G1–G4 are checked, agents opening Steam Partner / Coming Soon work should stop and point here.

---

## 9. Out of scope for this roadmap

- Merging RC1 → `main`  
- Inventing AppIDs  
- Genre mash “to raise conversion”  
- Act V / Workshop / cosmetics MX / online ladders as launch blockers  
- Estimating calendar weeks — sequence by gates and PR waves only  

---

## 10. Change log

| Date | Note |
|---|---|
| 2026-08-09 | Initial ROADMAP_EXECUTE — V3 → content → audio/art → meta → Steam resume |

---

*Pause Steam. Deepen game. Same verb. Ordered waves. No mash. No invented AppIDs.*
