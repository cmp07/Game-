# The Weaver — Master GDD v2

**Role:** Executive synthesis of sibling `cursor/weaver-*` docs into one durable **product lock**.  
**Version:** **v2** — product replace Lattice (shipping identity = Weaver)  
**Working title:** The Weaver  
**Branch:** `cursor/weaver-master-v2`  
**Base:** `cursor/echo-lattice-rc1`  
**Date:** 2026-08-09  
**Mode:** Cloud-only. **No AppID invention. No Echo Lattice deletion in this PR.**

**Companions:** [`ROADMAP.md`](ROADMAP.md) · [`CHANGELOG_DESIGN.md`](CHANGELOG_DESIGN.md) · [`README.md`](README.md) · [`PIVOT.md`](PIVOT.md) · [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) · [`17_MVP.md`](17_MVP.md)

---

## 0. Decision (read this first)

| Field | Lock |
|---|---|
| **North star** | **The Weaver** — offline craft / physics-puzzle toy we **ship** |
| **Echo Lattice** | **Frozen** product line; `game/echo_lattice/` **kept beside** `game/weaver/` until a human-approved migrate execute PR ([`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) is **plan only**) |
| **Core verb** | Recover **Fragments** → draw **Threads** → tension **Structures** → inhabit what you wove |
| **Hub** | One **Shed Yard** + authored fields/jobs (not open-world, not MMO) |
| **Economy** | Solo-satisfying craft scarcity — **no player trade** at MVP or 1.0 ([`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md)) |
| **Multiplayer** | **None** at MVP; post-1.0 co-op fence only ([`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md)) |
| **Monetization** | Paid premium **$4.99–$8.99** (plan **$6.99**); no F2P / battle pass / gacha ([`30_STEAM_PITCH.md`](30_STEAM_PITCH.md)) |
| **Tech** | Godot 4 · offline-first · playable root **`game/weaver/`** (scaffold present) · do not overwrite EL |
| **Look / ear** | Fiber, dust, timber, wire, chalk, kiln copper — **ban purple-void AI look** and chronomancy ([`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) · [`26_AUDIO_V2.md`](26_AUDIO_V2.md)) |
| **Coming Soon** | Blocked until vertical slice passes MVP exit criteria |

**One line:** Echo Lattice stays a frozen archive **in place**; **The Weaver** is the product we design and prototype next — a fair loom where physics judges your stitches.

### v1 → v2 product replace

| v1 (Master GDD wave-1) | v2 (this document) |
|---|---|
| Weaver as design north star; EL frozen & kept | Same — plus **shipping identity** locked ([`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md)) |
| Docs `01`–`19` only | Docs `01`–`19` + elevations **`20`–`34`** |
| `game/weaver/` future | `game/weaver/` **Godot 4.3 MVP stub present** (placeholder loop) |
| Economy critique in `07` | Live feel authority → [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md) |
| Thin legacy in `08` | Post-slice evolution → [`28_LEGACY_V2.md`](28_LEGACY_V2.md) (MVP thin residue still law) |
| No migrate contract | Plan-only migrate → [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md); **no move in this PR** |

---

## 1. Authority & conflict resolution

When sibling docs disagree, win order is:

1. [`PIVOT.md`](PIVOT.md) — product-line decision (EL frozen · Weaver north star · tree kept)  
2. [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) — ship-as-Weaver · archive intent · Steam rename  
3. [`17_MVP.md`](17_MVP.md) — honest cut list  
4. Systems core [`02`](02_CORE_LOOP.md)–[`08`](08_LEGACY.md) — verb grammar  
5. Elevations [`20`](20_ELEVATIONS_V2.md)–[`34`](34_ADVERSARIAL.md) — feel / pedagogy / fences (must not reopen bans)  
6. Craft [`09`](09_VISUAL.md)–[`11`](11_PROGRESSION.md) — base look / ear / unlock voice  
7. Biz/tech [`12`](12_MULTIPLAYER.md)–[`15`](15_MARKET.md) — fences  
8. [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) · [`18_RISKS.md`](18_RISKS.md) · [`19_NAMES.md`](19_NAMES.md) · [`31_NAME_LOCK.md`](31_NAME_LOCK.md)  
9. [`01_CONCEPT.md`](01_CONCEPT.md) — fantasy language **only where it does not contradict 1–5**

### Resolved conflict — what Weaver *is*

| Claim | Source | Verdict |
|---|---|---|
| Weaver elevates EL habit→geometry; no second SKU | `01_CONCEPT` (parts of `15_MARKET`) | **Superseded** as product identity |
| Weaver is the shipping product; EL frozen & kept (archive later) | `PIVOT`, `PRODUCT_IDENTITY`, `17_MVP`, elevations | **Wins** |
| Player trade / marketplace as endgame | Soft reading of `07` | **Killed** — [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md) |
| Realtime / seamless competitive MP | Soft reading of `12` | **Killed for MVP**; post-1.0 co-op only — [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) |
| Delete EL now that Weaver scaffold exists | Temptation | **Out** — migrate is plan-only until human gates |

**Fantasy elevation (MASTER lock):** You are a craftsperson in a worked yard. You recover material atoms (**Fragments**), stitch typed relations (**Threads**), and seat graphs into place-changing **Structures**. Pride is recognition — “that span is mine” — not loot, kill-feed, or trade flex.

---

## 2. One sentence & loop

> Offline craft vignette: gather a tiny set of **Fragments**, spin **Threads**, tension them into **Structures** that solve short Yard jobs — physics is the judge; no trade, no MMO, no purple time-magic.

```
Survey → Recover → Bind → Tension → Inhabit → Residue → next field
```

| Beat | Player verb | System answer |
|---|---|---|
| Survey | Enter a frayed field; read scarcity | Authored gap / load / flow / beat problem |
| Recover | Pick Fragments | Typed atoms with ports (tiny carry) |
| Bind | Draw Threads between ports | Brace / Feed / Oppose / Echo legality |
| Tension | Commit the graph | Solver seats or collapses with a readable why |
| Inhabit | Use the Structure to clear the job | Topology / flow / load / pulse / vent rewrite |
| Residue | Leave the field | Local silhouette + bias (± scrap); gallery stamp |

**Prototype timing:** [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) (Structure ≤3:40; clear ≤4:30).  
**Product spine:** [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) (first useful Structure ≤24:00).  
Feel clocks: [`23_WEAVE_VERB.md`](23_WEAVE_VERB.md). Trailer verb inside **60–90 seconds**.

---

## 3. Glossary (MVP vocabulary wins)

| Term | Meaning |
|---|---|
| **Fragment** | Portable atom of matter / pressure / behavior with typed ports — **not** a time shard, rarity gem, or lore trinket |
| **Thread** | Typed relation between ports (Brace, Feed, Oppose, Echo) |
| **Structure** | Seated Fragment–Thread graph that rewrites the field |
| **Field** | One deterministic play space with a solvable scarcity |
| **Shed Yard** | Hub — job board, fragment shelf, gallery wall |
| **Tension** | Commit check that stands or collapses a graph |
| **Residue / Legacy** | Local silhouette, bias tag, optional scrap — not server monuments or trade goods |
| **Void (allowed)** | Physical frayed gap in a field — torn span, starved basin — **never** cosmic purple emptiness |

### Fragment families (MVP six)

Span · Anchor · Channel · Charge · Filter · (+ Pulse/Pendulum only as craft beat tool — never rewind)  
Feel authority: [`21_FRAGMENT_FEEL.md`](21_FRAGMENT_FEEL.md)

### Thread types (MVP four)

Brace · Feed · Oppose · Echo

### Hard bans (print on the wall)

- Purple-void / neon chronomancy / “Fragments of Time”  
- Player-to-player trade / auction / stalls  
- Realtime multiplayer at MVP  
- F2P, battle pass, gacha, energy meters  
- Besiege-scale part encyclopedia before jobs exist  
- Deleting or rebranding `game/echo_lattice/` as Weaver in-place  
- LLM runtime / “AI worldbuilder” marketing  

---

## 4. Pillars (locked)

| # | Pillar | Ship test |
|---|---|---|
| 1 | **Parts → relations → place** | Mute still: stranger sees “parts became a bridge/gate” |
| 2 | **Craft, not conquest** | Goals are spatial/systems — never kill-count |
| 3 | **Fair toy** | Deterministic seed; readable collapse; short retries; undo tension |
| 4 | **Material identity** | Fiber/dust/timber/wire/chalk/kiln — no purple bloom default |
| 5 | **Offline first** | Full loop with Steam disabled |
| 6 | **Category purity** | Craft / physics puzzle toy — not cozy-MMO, horror, idle, coin, deckbuilder |

Elevations that sharpen these: [`20_ELEVATIONS_V2.md`](20_ELEVATIONS_V2.md). Discovery without wiki: [`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md). Structure classes: [`24_STRUCTURE_ECOLOGY.md`](24_STRUCTURE_ECOLOGY.md).

---

## 5. World, economy, legacy

| System | MVP lock | Authority |
|---|---|---|
| **World** | One Shed Yard hub; authored fields; 12–20 slice jobs → 40–60 at 1.0 | [`06_WORLD.md`](06_WORLD.md) |
| **Economy** | Ports, thread budget, tension commits, residue — **no human trade** | [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md) *(live)* · [`07_ECONOMY.md`](07_ECONOMY.md) *(trade pre-mortem)* |
| **Legacy** | Local gallery + ghost replay + next-field bias | [`08_LEGACY.md`](08_LEGACY.md) · deepen post-slice [`28_LEGACY_V2.md`](28_LEGACY_V2.md) |
| **Progression** | Literacy → catalog → authorship → memory (job stamps, not XP theater) | [`11_PROGRESSION.md`](11_PROGRESSION.md) |

---

## 6. Craft bar (visual / audio / first thirty)

| Layer | Lock | Authority |
|---|---|---|
| Visual | Workshop page / textile loom; kill circles-on-black; Tension seat is the signature still | [`09_VISUAL.md`](09_VISUAL.md) · [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) |
| Audio | Slack / taut / snap / seat; Fragment/Thread/Structure leitmotifs; workshop hush | [`10_AUDIO.md`](10_AUDIO.md) · [`26_AUDIO_V2.md`](26_AUDIO_V2.md) |
| First five (spike) | Recover → Bind → Tension → Inhabit inside five minutes | [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) |
| First thirty | Material → line → Structure → world answer → one CTA | [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) |

**Motion budget (≥3):** Fragment settle with weight · Thread tension climb · Structure seat (dust/joints).

---

## 7. Biz / tech fences

| Area | MVP | Authority |
|---|---|---|
| Multiplayer | Singleplayer only; optional later async ghosts / share codes; post-1.0 co-op fence | [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) · [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) |
| Monetization | Premium paid; demo as marketing; DLC fence post-1.0 | [`13_MONETIZATION.md`](13_MONETIZATION.md) · [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) |
| Tech | Godot 4; pick **one** sim fence (2D *or* constrained 3D) before art ramp; no game server | [`14_TECH.md`](14_TECH.md) |
| Market | Demo + mute-legible trailer; pure puzzle/craft tags; no AI-dungeon heat | [`15_MARKET.md`](15_MARKET.md) · [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) |
| Name | **The Weaver** working title; ship recommend in names lock; human legal check before Partner | [`19_NAMES.md`](19_NAMES.md) · [`31_NAME_LOCK.md`](31_NAME_LOCK.md) |

---

## 8. Content mountain & prototype status

| Milestone | Proof | Content cap | Status (2026-08-09) |
|---|---|---|---|
| **Docs seal v2** | MASTER v2 + `20`–`34` + CHANGELOG | Full design corpus | **This PR** |
| **Scaffold** | `game/weaver/` imports; placeholder recover→bind→tension | Stub scenes + loom state | **Landed** ([`game/weaver/README.md`](../../game/weaver/README.md)) |
| **W1 Spike** | First-five clear; Tension seat still-test | Anchor+Span+Brace + juice verbs | **In progress** — loop + juice merged (`main.tscn` · `demo_field.tscn` · [`35_JUICE.md`](35_JUICE.md)) |
| **Vertical slice** | First-thirty spine complete | 1 Yard, ≤6 Fragment families, ≤8 Structures, 8–12 jobs | Not started |
| **Demo** | Wishlistable clip loop | Slice + polish + CTA | Blocked on slice |
| **MVP 1.0** | ~3–5 h Yard jobs + light sandbox | ≤12 Fragments, ≤20 Structures, 40–60 jobs | Blocked on demo gates |

### Exit criteria (MVP is real)

1. Cold player completes first Structure job in ≤24 minutes without a human coach.  
2. Collapse clips are fair and shareable; wins feel elegant.  
3. Zero mandatory online features.  
4. Non-generic art/audio identity (no purple-void default).  
5. ~60 FPS on mid-tier Windows laptop in Yard scenes.  
6. Store explainer fits one trailer shot: hands, thread, structure, consequence.  
7. Adversarial kill-tests K1–K6 green ([`34_ADVERSARIAL.md`](34_ADVERSARIAL.md)).

---

## 9. Relationship to Echo Lattice

| Echo Lattice | The Weaver |
|---|---|
| Habit → geometry Field Ledger maze | Fragment → Thread → Structure yard craft |
| Steam pack frozen (~78 ship-ready) | Shipping identity; Coming Soon blocked on slice |
| `game/echo_lattice/` **kept in this PR** | Playable root `game/weaver/` **present** |
| Later archive via migrate execute PR | Prefer `archive/echo_lattice/` per [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) *(plan)*; PRODUCT_IDENTITY also allows `game/_archive/…` — **human picks in execute PR** |
| `docs/VISION/*` historical | `docs/WEAVER/*` live |
| Do not delete RELEASE / AUDIT / BACKUP | Separate store pack / Partner rename when ready |

**This PR keeps both trees.** Migrate is **not** user-ready until §6 gates in the migrate plan are green.

Freeze / pivot / identity / migrate: [`PIVOT.md`](PIVOT.md) · [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) · [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md)

---

## 10. Sibling merge inventory (v2 wave)

### Wave-1 (already on RC1 via #172)

| Branch | PR | Files |
|---|---|---|
| `cursor/weaver-pivot` | #166 | `PIVOT.md` + BACKUP hub links |
| `cursor/weaver-01-concept` | #165 | `01_CONCEPT.md` |
| `cursor/weaver-systems-core` | #169 | `02`–`05` |
| `cursor/weaver-world-econ` | #171 | `06`–`08` |
| `cursor/weaver-craft` | #168 | `09`–`11` |
| `cursor/weaver-biz-tech` | #170 | `12`–`15` |
| `cursor/weaver-mvp-pack` | #167 | `16`–`19` |
| `cursor/weaver-master` | #172 | MASTER v1 · ROADMAP · README |

### Wave-2 (merged into `cursor/weaver-master-v2`)

| Branch | PR | Files |
|---|---|---|
| `cursor/weaver-identity` | #183 | `PRODUCT_IDENTITY.md` + pivot/MASTER identity pass |
| `cursor/weaver-elevations-v2` | #177 | `20_ELEVATIONS_V2.md` |
| `cursor/weaver-fragment-feel` | #174 | `21_FRAGMENT_FEEL.md` |
| `cursor/weaver-discovery` | #181 | `22_DISCOVERY_UX.md` |
| `cursor/weaver-weave-verb` | #178 | `23_WEAVE_VERB.md` |
| `cursor/weaver-ecology` | #184 | `24_STRUCTURE_ECOLOGY.md` |
| `cursor/weaver-void-art` | #185 | `25_VOID_ART_V2.md` |
| `cursor/weaver-audio-v2` | #187 | `26_AUDIO_V2.md` |
| `cursor/weaver-solo-econ` | #179 | `27_SOLO_ECONOMY_V2.md` |
| `cursor/weaver-legacy-v2` | #188 | `28_LEGACY_V2.md` |
| `cursor/weaver-mp-v2` | #182 | `29_MULTIPLAYER_V2.md` |
| `cursor/weaver-steam-pitch` | #176 | `30_STEAM_PITCH.md` |
| `cursor/weaver-name-lock` | #173 | `31_NAME_LOCK.md` |
| `cursor/weaver-first-five` | #175 | `32_FIRST_FIVE.md` |
| `cursor/weaver-migrate-plan` | #186 | `33_MIGRATE_FROM_LATTICE.md` |
| `cursor/weaver-adversarial` | #190 | `34_ADVERSARIAL.md` |
| `cursor/weaver-godot-scaffold` | #189 | `game/weaver/` Godot MVP stub |
| `cursor/weaver-prototype-loop` | #192 | gather→combine→weave loop + screenshots + tests |
| `cursor/weaver-juice` | #191 | juice spike + `35_JUICE.md` *(renumbered from colliding `20_JUICE`)* |

**Coverage:** `PIVOT` + `PRODUCT_IDENTITY` + `01`–`34` + `35_JUICE` + MASTER v2 + ROADMAP + CHANGELOG_DESIGN + `game/weaver/` scaffold/loop/juice — **complete v2 set.**  
`game/echo_lattice/` **unchanged / kept.**

**Numbering note:** Juice landed as `20_JUICE.md` on its branch; synthesis renumbered to [`35_JUICE.md`](35_JUICE.md) so [`20_ELEVATIONS_V2.md`](20_ELEVATIONS_V2.md) keeps the elevations slot.

---

## 11. Gaps & follow-ups

| Gap | Severity | Notes |
|---|---|---|
| `01_CONCEPT` still frames Weaver as EL fantasy / “no second SKU” | **H** | Needs elevation rewrite (keep temperature) |
| `15_MARKET` / root GAME_PLAN still path→older research lanes | **M** | Align store sentence to Yard craft; update catalog Game 1 separately |
| `14_TECH` module sketch still names chambers / daily / endless EL-style | **M** | Retarget to fields / jobs / gallery against live `game/weaver/` |
| Scaffold / juice ≠ first-five cold clear | **H** | Loop + juice landed; still need cold timing + Tension still-test ([`32_FIRST_FIVE.md`](32_FIRST_FIVE.md)) |
| Sim fence unset (2D vs constrained 3D) | **H** | Stub is 2D placeholder — pick fence before art ramp |
| Legal name check | **M** | Human before Partner ([`31_NAME_LOCK.md`](31_NAME_LOCK.md)) |
| Archive path string (`archive/` vs `game/_archive/`) | **L** | Resolve in migrate execute PR; keep both trees until then |
| Soft readings → idle / spreadsheet / empty void | **H** | Fixes locked in [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md) |

---

## 12. Top risks (weekly watch)

From [`18_RISKS.md`](18_RISKS.md) + [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md):

1. **Verb mud** — poetic nouns, unclear buttons  
2. **Besiege gravity** — catalog before jobs  
3. **Economy creep** — player trade as “legacy”  
4. **Docs without playable feel** — scaffold without Tension juice  
5. **Early Coming Soon** / **delete Echo Lattice** temptation  

| Adversarial mode | Soft gravity | Hard fence |
|---|---|---|
| **Boring idle** | Residue / gallery become wait-loops | No offline accrual; Survey ≤3s to a hand |
| **Combo spreadsheet** | 6×4×recipes → wiki matrix | Jobs constrain chemistry; spike 4×2 first |
| **Empty void** | Blank fray → cosmos or nothing | Fray/gap/seam copy; material tells; density budget |

---

## 13. Lock line

**The Weaver** is the product we ship: a fair, offline shed-loom toy — recover Fragments, stitch Threads, seat Structures, inhabit your seams — while **Echo Lattice remains frozen and present** at `game/echo_lattice/` until a separate, human-gated migrate PR.
