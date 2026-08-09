# Echo Lattice — Master Vision 1000×

**Role:** Executive synthesis of sibling `cursor/vision-*` docs + [`../BACKUP/`](../BACKUP/) Steam freeze.  
**Product:** Echo Lattice — pure **habit → geometry** Field Ledger puzzle.  
**Base:** `cursor/echo-lattice-rc1` @ `5f0d463`  
**Synthesis branch:** `cursor/vision-1000x-synthesis-cd8d`  
**Date:** 2026-08-09  
**Mode:** Cloud-only. **No genre mash. No invented AppIDs.**

**Companions:** [`ROADMAP_EXECUTE.md`](ROADMAP_EXECUTE.md) · [`DESIGN_1000X.md`](DESIGN_1000X.md) · [`SYSTEMS_TRUTH.md`](SYSTEMS_TRUTH.md) · [`FEELS_PROTOTYPE.md`](FEELS_PROTOTYPE.md) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) · [`../AUDIT/ULTRA_AUDIT_RC1.md`](../AUDIT/ULTRA_AUDIT_RC1.md)

---

## 0. Decision (read this first)

| Field | Lock |
|---|---|
| **What we are shipping** | One Steam product: a **2D habit→geometry authorship puzzle** |
| **What we are pausing** | Steam Partner / Coming Soon / AppID / trailer encode / depot upload |
| **Why pause** | In-repo Steam pack is frozen and shippable enough; **game-feel is not** |
| **What we deepen next** | V3 vertical feel → content quality → audio/art earprint → meta retention — **then** resume Steam |
| **Hard fences** | No horror mash · no coin/idle mash · no combat · no deckbuilder transforms · no AI dungeon · no AppID invention |

**Steam pack frozen; next focus = game depth.** Resume Partner only when depth gates in [`ROADMAP_EXECUTE.md`](ROADMAP_EXECUTE.md) §Gates pass. Freeze ref: [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md).

---

## 1. One sentence

A Field Ledger labyrinth that **fossilizes how you walk into walls** — you escape by rewriting your own habits, not by beating RNG, combat, or loot.

```
Walk → trail → checkpoint → walls become your handwriting → walk differently.
```

That sentence is the product. 1000× means making it **undeniable** in demo minutes 0–3, campaign climax, Daily return, and Museum retention — not bolting on a second genre.

---

## 2. Fantasy pillars (locked)

| # | Pillar | Player promise | Ship test |
|---|---|---|---|
| 1 | **Habit → geometry** | My path becomes architecture | Blind player names the loop from one still of a rewrite slam |
| 2 | **Reactive authorship** | The lattice answers my *style*, not only this path | After Act II: “it punished my looping” without HUD jargon |
| 3 | **Field Ledger look** | Ink on paper, rust calcification — never glow-on-void | Frame reads as a document; no purple bloom / combat juice |
| 4 | **Fair toy** | Deterministic, softlock-safe, short retries | Same seed → same rules; BFS net; undo; stars never gate story |
| 5 | **Offline first** | Campaign / Daily / Endless without network | Steam optional; friend-code compare without ranked ladders |

### Category purity

| Shelf | Echo Lattice |
|---|---|
| Primary | **Puzzle** · Minimalist · Singleplayer · Replay Value |
| Session | Short deterministic wing; GIF-able rewrite slam |
| Price band | **$4.99–$9.99** (list **$6.99**) |
| Explicitly not | Horror vignette · coin machine · idle tycoon · deckbuilder · combat arena · AI dungeon |

Older research in [`../GAME_PLAN.md`](../GAME_PLAN.md) ranked tension/horror for *format economics*. Echo Lattice **kept the economics** (short, clip-friendly, low-$ band) and **resolved into pure puzzle**. That resolution is final. Sibling products (coin / idle) stay **separate Steam apps later**.

---

## 3. Scorecard — game-feel vs target

Two different scores; do not confuse them.

| Score | Value | Measures |
|---|---:|---|
| **Ship-readiness (Steam pack)** | **78 / 100** | In-repo Partner pack, offline bar, Gate A media — [`ULTRA_AUDIT_RC1`](../AUDIT/ULTRA_AUDIT_RC1.md) |
| **Game-feel vs finished-indie target** | **41 / 100** | Sensory authorship + thesis bite + shell craft vs Witness/Baba/Cocoon *craft* ceiling ([`QUALITY_BAR.md`](QUALITY_BAR.md)) |

### Game-feel breakdown (0–100 per axis → weighted 41)

| Axis | W | Score | Why |
|---|---:|---:|---|
| Core verb / Mirror Birth recognition | 20 | **72** | Path→walls + origami slam are real and demoable |
| Reactive habit “it answered you” | 15 | **34** | Lever/bias wired but shallow; forced transform still owns the story ([`SYSTEMS_TRUTH`](SYSTEMS_TRUTH.md)) |
| Rewrite juice / telegraph / fail clarity | 12 | **52** | Slam ceremony exists; document defaults incomplete ([`FEEL_JUICE_V3`](FEEL_JUICE_V3.md)) |
| Production audio earprint | 12 | **14** | Buses real; streams are procedural beepware ([`AUDIO_V3`](AUDIO_V3.md), [`FEELS_PROTOTYPE`](FEELS_PROTOTYPE.md) P0) |
| Production art / type / tiles | 12 | **22** | Palette language real; tileset/type still generator + Godot fallback |
| Shell craft (boot / title / end / pause) | 10 | **28** | Menu scaffold OK; “END OF SLICE,” ASCII stars, default splash ([`PRODUCTION_CRAFT`](PRODUCTION_CRAFT.md)) |
| First-ten-minutes premium path | 10 | **48** | Teach path gated; premium silence/earprint/ceremony not landed ([`FIRST_TEN_MINUTES`](FIRST_TEN_MINUTES.md)) |
| Meta retention cohesion | 9 | **38** | Daily strong; Museum thin (no race); modes feel add-on ([`META_LOOPS_V3`](META_LOOPS_V3.md)) |

**Interpretation:** Upper-70s ship pack + low-40s feel = **pause Steam, deepen game**. Marketing a Coming Soon page before feel gates pass burns the first impression the pack was built to convert.

**Target (100):** Blind cold player describes habit→walls; Act II player feels style counter; demo Mirror Birth lands under 3:30 with authored audio/type; Museum race chalk ships; no player-facing “slice” language; store stills match play.

---

## 4. What we have vs what we need

### 4.1 Have (do not rebuild)

| Owned | Evidence |
|---|---|
| Core walk → checkpoint → forced transform → fossil walls → stars | `chamber.gd` / juice / VISUAL v2 |
| Act I → Mirror Birth demo spine + 0–3 min teach gate | `DEMO_SPEC` · onboarding · `test_onboarding_path.py` |
| 35 + 4 hard chambers, four Acts authored | `content/acts.json` + chamber JSON |
| Field Ledger materials language (palette, menu scaffold) | Art bible + palette autoload |
| HabitRewriteLever + RewriteScoreBias (thin) | `fix-habit-wire` |
| IdentityStamp code + sealed habit HUD until birth | `form-identity-ledger` |
| Daily calendar/catalog + friend codes | `fix-daily-calendar` |
| Endless thin climb + Hard+ wing | `fix-endless` / `fix-remaining-p1` |
| Thin Museum archive + chalk replay | `upgrade-museum` |
| Offline ship bar + Steam stub + Gate A media pack | RC1 README · VIEW_MEDIA · capsules/screenshots/trailer editor pack |
| Store freeze + legal paste + AppID placeholder policy | Gate A docs — **placeholders only** |
| Frozen Steam snapshot | [`../BACKUP/`](../BACKUP/) · tag/branch `backup/echo-lattice-rc1-steam-pack` |

### 4.2 Need (finished indie — depth before Steam resume)

| Need | Why | Vision authority |
|---|---|---|
| **Legible habit answer** on remix/Daily/Endless | Tagline “It learned you” is half-true | [`HABIT_SYSTEMS_V3`](HABIT_SYSTEMS_V3.md) · F03/F16 |
| **Kill prototype tells** (END OF SLICE, ASCII stars, default font, beepware, generator tiles) | First 15 min files the build as a jam | [`FEELS_PROTOTYPE`](FEELS_PROTOTYPE.md) |
| **Feel V3** step/buffer/slam/win/fail punctuation | Document game, not combat juice | [`FEEL_JUICE_V3`](FEEL_JUICE_V3.md) |
| **Shell craft** boot/title/transitions/pause/fail/credits | “Real game” trust in first 10s | [`PRODUCTION_CRAFT`](PRODUCTION_CRAFT.md) · [`UI_DIEGETIC_V3`](UI_DIEGETIC_V3.md) |
| **Authored audio** rewrite phrase + operator earprints | Trailer/demo cannot ship DSP beeps as final | [`AUDIO_V3`](AUDIO_V3.md) · cue sheet |
| **Authored art/type** MVP tiles + latin display stack | Type is half a document game | [`ART_DIRECTION_V3`](ART_DIRECTION_V3.md) · [`TECH_ART_V3`](TECH_ART_V3.md) |
| **Denser Acts I–IV + honest Hard track** | Volume without clone bloat; bosses as portraits | [`CONTENT_EXPANSION`](CONTENT_EXPANSION.md) · [`CHAMBER_STANDARD`](CHAMBER_STANDARD.md) |
| **Museum race + Habit Ledger meta loop** | Retention without mash | [`META_LOOPS_V3`](META_LOOPS_V3.md) · F01/F04 |
| **Claim hygiene** | Drop race/streak claims until code ships | [`SYSTEMS_TRUTH`](SYSTEMS_TRUTH.md) |
| **Only then: Steam resume** | Real AppID / encode / Partner paste — human | [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |

### 4.3 Explicitly refuse

| Refuse | Reason |
|---|---|
| Mash horror / coin / idle into Echo Lattice | Breaks shelf + Field Ledger honesty |
| Invent AppIDs / DepotIDs in git | Partner is source of truth |
| Act V / Workshop / cosmetics MX as 1.0 blockers | Fence — deepen the verb’s home first |
| Online ranked ladders / battle pass / AI dungeon | Out of fantasy + scope |
| Resume Coming Soon before feel/depth gates | Burns first impression |

---

## 5. Execution spine (summary)

Full waves and gates: [`ROADMAP_EXECUTE.md`](ROADMAP_EXECUTE.md).

```
Phase 0  Steam pack FROZEN (backup/echo-lattice-rc1-steam-pack)
Phase 1  V3 vertical — feel · habit bite · shell · first-10 ceremony
Phase 2  Content — chamber standard · denser I–IV · identity portraits
Phase 3  Audio / art — authored earprint · tiles · type · tech-art
Phase 4  Meta — Museum race · Habit Ledger loop · streak honesty
Phase 5  Steam resume — AppID · encode · Partner paste · Coming Soon
```

Do **not** reorder Steam ahead of Phases 1–4. Do **not** mash genres to chase conversion.

---

## 6. Sibling vision corpus (ingested)

| Branch | Doc |
|---|---|
| `cursor/vision-design-1000x` | [`DESIGN_1000X.md`](DESIGN_1000X.md) |
| `cursor/vision-feel-v3` | [`FEEL_JUICE_V3.md`](FEEL_JUICE_V3.md) |
| `cursor/vision-systems-truth-dbd9` | [`SYSTEMS_TRUTH.md`](SYSTEMS_TRUTH.md) |
| `cursor/vision-quality-bar` | [`QUALITY_BAR.md`](QUALITY_BAR.md) |
| `cursor/vision-first-10` | [`FIRST_TEN_MINUTES.md`](FIRST_TEN_MINUTES.md) |
| `cursor/vision-meta-v3` | [`META_LOOPS_V3.md`](META_LOOPS_V3.md) |
| `cursor/vision-habit-v3` | [`HABIT_SYSTEMS_V3.md`](HABIT_SYSTEMS_V3.md) |
| `cursor/vision-content-xp` | [`CONTENT_EXPANSION.md`](CONTENT_EXPANSION.md) |
| `cursor/vision-craft` | [`PRODUCTION_CRAFT.md`](PRODUCTION_CRAFT.md) |
| `cursor/vision-audio-v3` | [`AUDIO_V3.md`](AUDIO_V3.md) · [`AUDIO_1_0_CUE_SHEET.md`](AUDIO_1_0_CUE_SHEET.md) |
| `cursor/vision-art-v3` | [`ART_DIRECTION_V3.md`](ART_DIRECTION_V3.md) |
| `cursor/vision-chambers` | [`CHAMBER_STANDARD.md`](CHAMBER_STANDARD.md) |
| `cursor/vision-features` | [`FEATURE_BACKLOG_1000X.md`](FEATURE_BACKLOG_1000X.md) |
| `cursor/vision-narrative` | [`NARRATIVE_ARC.md`](NARRATIVE_ARC.md) |
| `cursor/vision-tech-art` | [`TECH_ART_V3.md`](TECH_ART_V3.md) |
| `cursor/vision-ui-v3` | [`UI_DIEGETIC_V3.md`](UI_DIEGETIC_V3.md) |
| `cursor/vision-prototype-tells` | [`FEELS_PROTOTYPE.md`](FEELS_PROTOTYPE.md) |
| `cursor/backup-rc1-freeze` | [`../BACKUP/`](../BACKUP/) |

Lane detail stays in sibling docs. **This file + [`ROADMAP_EXECUTE.md`](ROADMAP_EXECUTE.md) win on priority and phase order.**

---

## 7. Doc contract

| Question | Answer lives in |
|---|---|
| Executive decision / scores / have-vs-need | **This file** |
| Ordered PR waves + depth gates before Steam | [`ROADMAP_EXECUTE.md`](ROADMAP_EXECUTE.md) |
| Fantasy / fences / finished-indie bar | [`DESIGN_1000X.md`](DESIGN_1000X.md) |
| Lived vs claim systems truth | [`SYSTEMS_TRUTH.md`](SYSTEMS_TRUTH.md) |
| Ranked pure-fantasy features | [`FEATURE_BACKLOG_1000X.md`](FEATURE_BACKLOG_1000X.md) |
| Steam pack freeze / resume | [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |
| Chamber format / Acts (authoring) | [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) |
| Ship integration / offline bar | [`../RELEASE/RC1_README.md`](../RELEASE/RC1_README.md) |

If code disagrees with **fantasy purity**, vision + Content/Art bibles win.  
If vision asks for scope outside the 1.0 fence, the fence wins until a post-1.0 PR reopens it.  
If anyone proposes inventing AppIDs or mashing genres to “unblock,” reject.

---

## 8. Change log

| Date | Note |
|---|---|
| 2026-08-09 | Initial MASTER_1000X — poll/merge vision siblings + BACKUP freeze; game-feel **41/100**; Steam paused for depth |

---

*End of master vision. Habit → geometry. Field Ledger. Pause Steam. Deepen game. No mash. No invented AppIDs.*
