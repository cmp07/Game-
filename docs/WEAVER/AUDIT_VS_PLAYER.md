# Weaver docs — audit vs player (latest words)

**Status:** CLOUD ONLY · durable audit · not a redesign  
**Branch:** `cursor/weaver-audit-vs-player-f0a0`  
**Base:** `cursor/weaver-visual-lock`  
**Date:** 2026-08-15  
**Job:** Score every `docs/WEAVER/**/*.md` against the player's latest correction. Table only — keep / rewrite / kill. Does not invent AppIDs or delete files in this PR.

**Sibling north docs (expected / landing elsewhere):** `TRUE_NORTH.md` · `GENERATIVE_VOID.md` · `PLAYER_SHAPED.md` — this audit does not replace them; it grades the *existing* corpus so those locks know what to supersede.

---

## 0. Player words (highest priority)

Quoted from the user's correction that overrides shed-yard elevations:

> The Weaver is **NOT** a shed workshop with prescribed gather→combine→weave recipes.

User wants:

| Lock | Player meaning |
|---|---|
| **Void origin** | Start from **nothing / the void** — how the world started, then evolve |
| **Type / speak** | Jump in, **SPEAK or TYPE**, see what happens |
| **Generative** | World/game comes alive from **this player's** actions — weaving a **game** that generates around you |
| **No shed** | Timber-shed / Yard Folio / workshop look is **wrong** |
| **No prescribed path** | Component-based infinite creation — build anything; **no particular steps** or one true path |

**Anti-drift (what we wrongly became):** Shed Yard hub · ports/recipes · Coach/hint ladders · Field Ledger habit→geometry mash · anti-generative store bans that kill the new fantasy · gather→combine→weave as the only verb.

---

## 1. Rubric

Each doc gets one verdict:

| Verdict | Meaning |
|---|---|
| **KEEP** | Still true under the new north (usually product-line / tree / offline fences). May need a one-line “superseded fantasy” pointer later — not rewritten in this PR. |
| **REWRITE** | Durable bones (authorship, offline, friction, components) but framed as shed / recipe / anti-void / anti-generative. Must be rewritten to void origin + type/speak + generative + open path. |
| **KILL** | Live authority that *actively fights* the player words (shed visual lock, anti-cosmic-void art bible, prescribed Yard pedagogy, gather→combine→weave proof as north). Retire as historical drift; do not cite as shipping north. |

**Score axes** (pass = aligns; fail = contradicts):

1. Void origin  
2. Type / speak  
3. Generative around this player  
4. No shed  
5. No prescribed path  

---

## 2. Executive counts

| Verdict | Count |
|---|---|
| KEEP | 8 |
| REWRITE | 41 |
| KILL | 19 |
| **Total audited** | **68** |

**Pattern:** Product-line and archive fences mostly **KEEP**. Almost the entire systems / craft / 1000× fantasy stack is **REWRITE** or **KILL**. Media that proves the shed visual lock is **KILL** as north-star evidence.

---

## 3. Full table — every `docs/WEAVER/**/*.md`

### 3.1 Pivot, master, index

| Doc | Verdict | Why vs player words |
|---|---|---|
| [`PIVOT.md`](PIVOT.md) | **KEEP** | EL frozen · Weaver ships · tree kept. Fantasy-agnostic product-line lock. |
| [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) | **KEEP** | Ship-as-Weaver · archive · Steam rename. Does not lock shed. |
| [`MASTER_GDD.md`](MASTER_GDD.md) | **REWRITE** | Locks Shed Yard hub, Recover→Bind→Tension recipe, bans purple-void / generative AI lead. Must become void-origin generative north. |
| [`README.md`](README.md) | **REWRITE** | Indexes shed elevations, Yard Folio photos, gather→combine→weave media as start-here. |
| [`ROADMAP.md`](ROADMAP.md) | **REWRITE** | Gates assume Yard craft slice and shed visual lock. |
| [`CHANGELOG_DESIGN.md`](CHANGELOG_DESIGN.md) | **KEEP** | Historical ledger of design waves — keep as archaeology; stop treating entries as live north. |
| [`BUILD_ON_LATTICE.md`](BUILD_ON_LATTICE.md) | **REWRITE** | Hybrid launch path still useful; “Enter the Yard” + gather→combine→weave CTA must retarget void boot + type/speak. |
| [`AUDIT_VS_PLAYER.md`](AUDIT_VS_PLAYER.md) | **KEEP** | This file — audit instrument only. |

### 3.2 `01`–`08` systems / world

| Doc | Verdict | Why vs player words |
|---|---|---|
| [`01_CONCEPT.md`](01_CONCEPT.md) | **REWRITE** | Field Ledger / habit→geometry Weaver mash; bans generative-AI dungeon; not void origin or type/speak. |
| [`02_CORE_LOOP.md`](02_CORE_LOOP.md) | **REWRITE** | Prescribed Survey→Recover→Bind→Tension→Inhabit chain — the exact “one true path” player rejected. |
| [`03_FRAGMENTS.md`](03_FRAGMENTS.md) | **REWRITE** | Typed ports / families usable as *open components*, but framed as shed craft atoms + recipe literacy. |
| [`04_THREADS.md`](04_THREADS.md) | **REWRITE** | Closed Brace/Feed/Oppose/Echo grammar + designer cheatsheet — prescribed chemistry, not speak/type intent. |
| [`05_STRUCTURES.md`](05_STRUCTURES.md) | **REWRITE** | Seated graphs OK as outcomes; job archetypes / recipe stamps prescribe paths. |
| [`06_WORLD.md`](06_WORLD.md) | **KILL** | Shed Yard hub + authored job board is the wrong world model. Replace, do not patch. |
| [`07_ECONOMY.md`](07_ECONOMY.md) | **REWRITE** | No-player-trade fence **KEEP-worthy**; scarcity table tied to ports/jobs → rewrite for generative void. |
| [`08_LEGACY.md`](08_LEGACY.md) | **REWRITE** | Local residue / gallery can serve player-shaped memory; shed gallery framing must go. |

### 3.3 `09`–`19` craft / biz / MVP pack

| Doc | Verdict | Why vs player words |
|---|---|---|
| [`09_VISUAL.md`](09_VISUAL.md) | **KILL** | Material bible is timber/shed; bans cosmic void clear — opposite of void origin. |
| [`10_AUDIO.md`](10_AUDIO.md) | **KILL** | Shed air / kiln / timber knock earprint; anti-void-drone as title bed. |
| [`11_PROGRESSION.md`](11_PROGRESSION.md) | **REWRITE** | Literacy unlocks / recipe stamps = prescribed path pedagogy. |
| [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) | **KEEP** | MVP singleplayer + offline-first still fits generative-local; no shed lock. |
| [`13_MONETIZATION.md`](13_MONETIZATION.md) | **KEEP** | Premium paid band / no F2P — fantasy-agnostic. |
| [`14_TECH.md`](14_TECH.md) | **REWRITE** | Godot offline stack KEEP-worthy; explicitly cuts LLM / online generative dungeon — conflicts with generative north (local generative still needed). |
| [`15_MARKET.md`](15_MARKET.md) | **REWRITE** | Sells fair loom / puzzle shelf; must re-pitch void generative authorship without AI-slop. |
| [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) | **REWRITE** | Scripted Yard teach to first Structure — prescribed first half-hour. |
| [`17_MVP.md`](17_MVP.md) | **REWRITE** | MVP sentence is gather Fragments / Yard jobs; cuts “generative AI world” marketing. |
| [`18_RISKS.md`](18_RISKS.md) | **REWRITE** | Useful risk register; D5/D10 treat purple-void / generative as identity failure — retarget risks to empty chatbot & shed relapse. |
| [`19_NAMES.md`](19_NAMES.md) | **REWRITE** | Avoid list bans Void / Generative — now core fantasy words. |

### 3.4 Elevations `20`–`35`

| Doc | Verdict | Why vs player words |
|---|---|---|
| [`20_ELEVATIONS_V2.md`](20_ELEVATIONS_V2.md) | **KILL** | Elevates shed loom feel as product bet; locks anti-purple-void stills. |
| [`21_FRAGMENT_FEEL.md`](21_FRAGMENT_FEEL.md) | **REWRITE** | Hand-feel of components may survive; shed-light / port literacy framing must open up. |
| [`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md) | **KILL** | Coach / hint ladder / recipe stamps = prescribed path machine. |
| [`23_WEAVE_VERB.md`](23_WEAVE_VERB.md) | **REWRITE** | Slack→taut motion language salvageable; bind to speak/type→emergence, not Yard stitch ceremony. |
| [`24_STRUCTURE_ECOLOGY.md`](24_STRUCTURE_ECOLOGY.md) | **REWRITE** | Ecology of living structures can serve generative world; job archetypes / recipes out. |
| [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) | **KILL** | Explicit job: make void read as **physical gap in a worked shed** — direct contradiction of void origin. |
| [`26_AUDIO_V2.md`](26_AUDIO_V2.md) | **KILL** | Shed / kiln / fiber earprint expansion of `10`. |
| [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md) | **REWRITE** | Solo-satisfying scarcity fence good; Yard job sinks / recipe budgets out. |
| [`28_LEGACY_V2.md`](28_LEGACY_V2.md) | **REWRITE** | Offline Structure evolution ≈ player-shaped growth — rewrite away from shed gallery / pre-authored variants only. |
| [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) | **KEEP** | Post-1.0 co-op fence; not shed-fantasy lock. |
| [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) | **REWRITE** | Pitch sells shed loom + “no generative AI”; must become void generative without chatbot fraud. |
| [`31_NAME_LOCK.md`](31_NAME_LOCK.md) | **REWRITE** | Threadfall / Yard-adjacent shortlist; reopen for void/generative title temperature. |
| [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) | **KILL** | Beat script for prescribed gather→combine→weave teach. |
| [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) | **KEEP** | Archive-move plan; tree policy still required. |
| [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md) | **REWRITE** | Death mode “empty void” treats cosmic nothing as fail — player wants void origin; retarget adversarial to chatbot mush + shed relapse + prescribed wiki. |
| [`35_JUICE.md`](35_JUICE.md) | **REWRITE** | Juice for fragment suck / weave pulse on wrong loop — retarget to type/speak sparks in void. |

### 3.5 `1000X/` deepen pack

| Doc | Verdict | Why vs player words |
|---|---|---|
| [`1000X/README.md`](1000X/README.md) | **REWRITE** | Indexes shed-yard 1000× as live deepen — demote to drift archive or retitle. |
| [`1000X/MASTER_1000X.md`](1000X/MASTER_1000X.md) | **REWRITE** | Executive 1000× locks shed-yard · slack→taut · anti-purple-void. |
| [`1000X/00_MASTER_VISION.md`](1000X/00_MASTER_VISION.md) | **KILL** | Ambition lock: Shed Yard craft DNA must survive — opposite of player correction. |
| [`1000X/01_CORE_LOOP.md`](1000X/01_CORE_LOOP.md) | **REWRITE** | Same prescribed craft cycle at every timescale. |
| [`1000X/02_FRAGMENTS.md`](1000X/02_FRAGMENTS.md) | **REWRITE** | Deep port families / grades — open-component salvage possible. |
| [`1000X/03_THREADS.md`](1000X/03_THREADS.md) | **REWRITE** | Heavy recipe / chemistry / anti-wiki still prescription-shaped. |
| [`1000X/04_STRUCTURES.md`](1000X/04_STRUCTURES.md) | **REWRITE** | Classes/ecosystems useful for generative growth; Yard job framing out. |
| [`1000X/05_WORLD.md`](1000X/05_WORLD.md) | **KILL** | Procgen **yards**, shed layers, seed-as-cloth-panel — wrong world. |
| [`1000X/06_PROGRESSION.md`](1000X/06_PROGRESSION.md) | **REWRITE** | Literacy / stamp progression = prescribed path. |
| [`1000X/07_MODES.md`](1000X/07_MODES.md) | **KILL** | Mode set built around Yard jobs / shed return loop. |
| [`1000X/08_JUICE.md`](1000X/08_JUICE.md) | **KILL** | Juice bible for shed craft micro-beats. |
| [`1000X/09_AUDIO.md`](1000X/09_AUDIO.md) | **KILL** | Full shed earprint expansion. |
| [`1000X/10_ART.md`](1000X/10_ART.md) | **KILL** | Anti-AI-slop art bible = shed materials + ban cosmic void. |
| [`1000X/11_NARRATIVE.md`](1000X/11_NARRATIVE.md) | **REWRITE** | Diegetic mythos can serve void speech; Yard workshop voice out. |
| [`1000X/12_UI.md`](1000X/12_UI.md) | **KILL** | Yard Folio / shed chalk UI system. |
| [`1000X/13_TECH.md`](1000X/13_TECH.md) | **REWRITE** | Hybrid Godot + data content OK; bans runtime generative — reopen for local generative. |
| [`1000X/14_FEATURE_BACKLOG.md`](1000X/14_FEATURE_BACKLOG.md) | **KILL** | Backlog of shed elevations / recipe pedagogy features. |
| [`1000X/15_POSITIONING.md`](1000X/15_POSITIONING.md) | **REWRITE** | Vs-cosmic section refuses generative void shelf — rewrite category story. |
| [`1000X/16_ROADMAP_1000X.md`](1000X/16_ROADMAP_1000X.md) | **REWRITE** | Prototype→indie path assumes shed slice proof. |

### 3.6 Media / galleries

| Doc | Verdict | Why vs player words |
|---|---|---|
| [`VIEW_PHOTOS_V2.md`](VIEW_PHOTOS_V2.md) | **KILL** | Visual-lock proof of Yard Folio + shed field — evidence of wrong drift, not north. |
| [`VIEW_SCREENSHOTS.md`](VIEW_SCREENSHOTS.md) | **REWRITE** | Gallery hub; demote shed packs to “historical drift,” point to future void stills. |
| [`media/README.md`](media/README.md) | **REWRITE** | Indexes Shed Yard teaching loop as gameplay pack. |
| [`media/VIDEO.md`](media/VIDEO.md) | **KILL** | Capture bible for gather→combine→weave as the product loop. |
| [`media/photos_v2/README.md`](media/photos_v2/README.md) | **KILL** | Stills after shed-yard visual lock. |
| [`screenshots/README.md`](screenshots/README.md) | **REWRITE** | Legacy void/structure pair — keep as archaeology; stop preferring shed pack. |

---

## 4. Axis heat map (corpus-level)

| Axis | Corpus status |
|---|---|
| **Void origin** | **Fail** — “void” redefined as physical shed gap; cosmic / from-nothing start banned (`09`, `25`, `34`, `1000X/00`). |
| **Type / speak** | **Fail** — almost no diegetic type/speak input; verbs are Recover/Bind/Tension and Coach hints. |
| **Generative** | **Fail** — store + tech docs ban generative AI / LLM content; “generative” treated as identity poison (`14`, `17`, `19`, `30`, `1000X/13`). |
| **No shed** | **Fail** — Shed Yard is hub law across MASTER, `06`, elevations, 1000×, photos_v2. |
| **No prescribed path** | **Fail** — gather→combine→weave, job boards, recipe stamps, hint ladders (`02`, `22`, `32`, media video). |

---

## 5. What to KEEP using tomorrow (short list)

Do **not** throw away these fences while rewriting fantasy:

1. [`PIVOT.md`](PIVOT.md) / [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) — EL frozen; Weaver ships; no EL wipe.  
2. [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) — archive move gates.  
3. [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) / [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) — offline-first; no always-online MVP.  
4. [`13_MONETIZATION.md`](13_MONETIZATION.md) — premium paid, no F2P gacha.  
5. Anti-chatbot friction (physics/consequences) — salvage from adversarial / fair-toy language, **without** banning void generative.

---

## 6. Kill first (stop citing as north)

Highest-damage live authorities to demote immediately when `TRUE_NORTH` / `GENERATIVE_VOID` land:

1. [`MASTER_GDD.md`](MASTER_GDD.md) shed hub + recipe loop *(rewrite, but until then treat as superseded)*  
2. [`06_WORLD.md`](06_WORLD.md) · [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) · [`09_VISUAL.md`](09_VISUAL.md)  
3. [`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md) · [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md)  
4. [`1000X/00_MASTER_VISION.md`](1000X/00_MASTER_VISION.md) · [`1000X/05_WORLD.md`](1000X/05_WORLD.md) · [`1000X/12_UI.md`](1000X/12_UI.md)  
5. [`VIEW_PHOTOS_V2.md`](VIEW_PHOTOS_V2.md) · [`media/photos_v2/README.md`](media/photos_v2/README.md) · [`media/VIDEO.md`](media/VIDEO.md)

---

## 7. Agent policy after this audit

| Do | Do not |
|---|---|
| Cite **player words in §0** over any shed elevation | Cite photos_v2 / Yard Folio as visual north |
| Prefer upcoming `TRUE_NORTH` / `GENERATIVE_VOID` / `PLAYER_SHAPED` | Treat `1000X/00_MASTER_VISION` as ambition lock |
| Keep EL tree / offline / no-trade fences | Delete EL or invent AppIDs |
| Implement void boot + type/speak spikes | Ship another gather→combine→weave teach as product proof |

---

## 8. Version

| Field | Value |
|---|---|
| **Audit version** | v1 |
| **Files scored** | 68 |
| **KEEP / REWRITE / KILL** | 8 / 41 / 19 |
| **Authority** | Player correction > this audit > prior MASTER / 1000× / elevations |
