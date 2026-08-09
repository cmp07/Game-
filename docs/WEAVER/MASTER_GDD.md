# The Weaver — Master GDD

**Role:** Executive synthesis of sibling `cursor/weaver-*` docs into one durable product lock.  
**Working title:** The Weaver  
**Branch:** `cursor/weaver-master`  
**Base tip (RC1):** `a1f49a3`  
**Date:** 2026-08-09  
**Mode:** Cloud-only. **No AppID invention. No Echo Lattice code edits.**

**Companions:** [`ROADMAP.md`](ROADMAP.md) · [`README.md`](README.md) · [`PIVOT.md`](PIVOT.md) · [`17_MVP.md`](17_MVP.md)

---

## 0. Decision (read this first)

| Field | Lock |
|---|---|
| **North star** | **The Weaver** — offline craft / physics-puzzle toy |
| **Echo Lattice** | **Frozen** product line; `game/echo_lattice/` **kept**; Steam pack freeze stands |
| **Core verb** | Recover **Fragments** → draw **Threads** → tension **Structures** → inhabit what you wove |
| **Hub** | One **Shed Yard** + authored fields/jobs (not open-world, not MMO) |
| **Economy** | Craft scarcity only — **no player trade** at MVP or 1.0 |
| **Multiplayer** | **None** at MVP; social residue (seeds/ghosts) only as post fence |
| **Monetization** | Paid premium **$4.99–$8.99** (plan **$6.99**); no F2P / battle pass / gacha |
| **Tech** | Godot 4 · offline-first · future `game/weaver/` · do not overwrite EL |
| **Look / ear** | Fiber, dust, timber, wire, chalk, kiln copper — **ban purple-void AI look** and chronomancy |
| **Coming Soon** | Blocked until vertical slice passes MVP exit criteria |

**One line:** Echo Lattice stays a frozen archive; Weaver is what we design and prototype next — a fair loom where physics judges your stitches.

---

## 1. Authority & conflict resolution

Sibling docs arrived in parallel. When they disagree, win order is:

1. [`PIVOT.md`](PIVOT.md) — product-line decision  
2. [`17_MVP.md`](17_MVP.md) — honest cut list  
3. Systems core [`02`](02_CORE_LOOP.md)–[`08`](08_LEGACY.md) — verb grammar  
4. Craft [`09`](09_VISUAL.md)–[`11`](11_PROGRESSION.md) — feel / ear / unlock voice  
5. Biz/tech [`12`](12_MULTIPLAYER.md)–[`15`](15_MARKET.md) — fences  
6. [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) · [`18_RISKS.md`](18_RISKS.md) · [`19_NAMES.md`](19_NAMES.md)  
7. [`01_CONCEPT.md`](01_CONCEPT.md) — fantasy language **only where it does not contradict 1–3**

### Resolved conflict — what Weaver *is*

| Claim | Source | Verdict |
|---|---|---|
| Weaver elevates Echo Lattice habit→geometry; no second SKU | `01_CONCEPT` (and parts of `15_MARKET`) | **Superseded** as product identity |
| Weaver is separate north-star SKU; EL frozen & kept | `PIVOT`, `17_MVP`, systems + craft packs | **Wins** |
| Shared taste OK (authorship, readable failure, short sessions, offline) | All packs | **Keep** |
| Shared store copy / maze chrome / habit archetypes as Weaver meta | EL bleed | **Out** |

**Fantasy elevation (MASTER lock):** You are a craftsperson in a worked yard. You recover material atoms (**Fragments**), stitch typed relations (**Threads**), and seat graphs into place-changing **Structures**. Pride is recognition — “that span is mine” — not loot, kill-feed, or trade flex.

Useful lines kept from concept elevation (temperature only): quiet authorship; dry workshop voice; no combat juice; no neon “chosen one”; no “built by AI” store lead.

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

Target teach-field clear: **3–8 minutes**. Trailer verb inside **60–90 seconds**. First useful Structure in first-thirty spine by **≤24:00**.

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

### Thread types (MVP four)

Brace · Feed · Oppose · Echo

### Hard bans (print on the wall)

- Purple-void / neon chronomancy / “Fragments of Time”  
- Player-to-player trade / auction / stalls  
- Realtime multiplayer at MVP  
- F2P, battle pass, gacha, energy meters  
- Besiege-scale part encyclopedia before jobs exist  
- Deleting or rebranding `game/echo_lattice/` as Weaver  
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

---

## 5. World, economy, legacy (thin)

| System | MVP lock | Authority |
|---|---|---|
| **World** | One Shed Yard hub; authored fields; 12–20 slice jobs → 40–60 at 1.0 | [`06_WORLD.md`](06_WORLD.md) |
| **Economy** | Ports, thread budget, tension commits, residue — **no human trade** | [`07_ECONOMY.md`](07_ECONOMY.md) |
| **Legacy** | Local gallery + ghost replay + next-field bias | [`08_LEGACY.md`](08_LEGACY.md) |
| **Progression** | Literacy → catalog → authorship → memory (job stamps, not XP theater) | [`11_PROGRESSION.md`](11_PROGRESSION.md) |

---

## 6. Craft bar (visual / audio / first thirty)

| Layer | Lock | Authority |
|---|---|---|
| Visual | Workshop page / textile loom; Tension seat is the signature still | [`09_VISUAL.md`](09_VISUAL.md) |
| Audio | Slack / taut / snap / seat as audible sentences; workshop hush; Fragment/Thread/Structure leitmotifs | [`10_AUDIO.md`](10_AUDIO.md) · [`26_AUDIO_V2.md`](26_AUDIO_V2.md) |
| First thirty | Material → line → Structure → world answer → one CTA | [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) |

**Motion budget (≥3):** Fragment settle with weight · Thread tension climb · Structure seat (dust/joints).

---

## 7. Biz / tech fences

| Area | MVP | Authority |
|---|---|---|
| Multiplayer | Singleplayer only; optional later async ghosts / share codes | [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) |
| Monetization | Premium paid; demo as marketing; DLC fence post-1.0 | [`13_MONETIZATION.md`](13_MONETIZATION.md) |
| Tech | Godot 4; pick **one** sim fence (2D *or* constrained 3D) before art ramp; no game server | [`14_TECH.md`](14_TECH.md) |
| Market | Demo + mute-legible trailer; pure puzzle/craft tags; no AI-dungeon heat | [`15_MARKET.md`](15_MARKET.md) |
| Name | **The Weaver** working title; shortlist in names doc; human legal check before Partner | [`19_NAMES.md`](19_NAMES.md) |

---

## 8. Content mountain

| Milestone | Proof | Content cap |
|---|---|---|
| **Vertical slice** | First-thirty spine complete | 1 Yard, ≤6 Fragment families, Thread literacy, ≤8 Structures, 8–12 jobs |
| **Demo** | Wishlistable clip loop | Slice + polish + CTA |
| **MVP 1.0** | ~3–5 h Yard jobs + light sandbox | ≤12 Fragments, ≤20 Structures, 40–60 jobs, gallery |
| **Post-MVP** | Only after slice metrics | Pick **one**: second biome *or* async ghosts *or* co-op build |

### Exit criteria (MVP is real)

1. Cold player completes first Structure job in ≤24 minutes without a human coach.  
2. Collapse clips are fair and shareable; wins feel elegant.  
3. Zero mandatory online features.  
4. Non-generic art/audio identity (no purple-void default).  
5. ~60 FPS on mid-tier Windows laptop in Yard scenes.  
6. Store explainer fits one trailer shot: hands, thread, structure, consequence.

---

## 9. Relationship to Echo Lattice

| Echo Lattice | The Weaver |
|---|---|
| Habit → geometry Field Ledger maze | Fragment → Thread → Structure yard craft |
| Steam pack frozen (~78 ship-ready) | Design north star; Coming Soon blocked on slice |
| `game/echo_lattice/` **kept** | Future `game/weaver/` (or successor) |
| `docs/VISION/*` historical | `docs/WEAVER/*` live |
| Do not delete RELEASE / AUDIT / BACKUP | Separate store pack when ready |

Borrow **craft lessons** (determinism, fail-closed Steam, Python contracts, ceremony scarcity). Do **not** mash store pages, trailers, or chamber UI.

Freeze / pivot pointers: [`PIVOT.md`](PIVOT.md) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md)

---

## 10. Sibling merge inventory

Merged into `cursor/weaver-master` from remotes (2026-08-09 wave):

| Branch | PR | Files |
|---|---|---|
| `cursor/weaver-pivot` | #166 | `PIVOT.md` + BACKUP hub links |
| `cursor/weaver-01-concept` | #165 | `01_CONCEPT.md` |
| `cursor/weaver-systems-core` | #169 | `02`–`05` |
| `cursor/weaver-world-econ` | #171 | `06`–`08` |
| `cursor/weaver-craft` | #168 | `09`–`11` |
| `cursor/weaver-biz-tech` | #170 | `12`–`15` |
| `cursor/weaver-mvp-pack` | #167 | `16`–`19` |

**Coverage:** `PIVOT` + `01`–`19` + this MASTER + [`ROADMAP.md`](ROADMAP.md) + index README — **complete set present.**

---

## 11. Gaps & follow-ups

| Gap | Severity | Notes |
|---|---|---|
| `01_CONCEPT` still frames Weaver as EL fantasy / “no second SKU” | **H** | Needs elevation rewrite to Fragment→Thread→Structure + separate SKU (keep temperature) |
| `15_MARKET` store sentence / comps still path→cloth / Mirror Birth | **M** | Align to Yard craft trailer math; keep category purity |
| `14_TECH` module sketch still names chambers / daily / endless EL-style | **M** | Retarget modules to fields / jobs / gallery when `game/weaver/` spikes |
| No playable `game/weaver/` yet | **H** | Docs-only wave — schedule throwaway prototype before art ramp ([`18_RISKS.md`](18_RISKS.md) P2) |
| Sim fence unset (2D vs constrained 3D) | **H** | Pick in week-1 of prototype ([`17_MVP.md`](17_MVP.md) §5) |
| Legal name check | **M** | Human before Partner ([`19_NAMES.md`](19_NAMES.md)) |
| GAME_PLAN.md still lists older Game-1 research lanes | **L** | Update separately if Weaver becomes catalog Game 1 |

---

## 12. Top risks (weekly watch)

From [`18_RISKS.md`](18_RISKS.md):

1. **Verb mud** — poetic nouns, unclear buttons  
2. **Besiege gravity** — catalog before jobs  
3. **Economy creep** — player trade as “legacy”  
4. **Docs without playable** — no feel proof  
5. **Early Coming Soon** / **delete Echo Lattice** temptation  

---

## 13. Lock line

**The Weaver** is a fair, offline shed-loom toy: recover Fragments, stitch Threads, seat Structures, inhabit your seams, and leave a local cloth panel worth keeping — while Echo Lattice remains frozen and intact as archive.
