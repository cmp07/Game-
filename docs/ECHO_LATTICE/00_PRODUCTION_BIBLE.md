# Echo Lattice — Production Bible

**Status:** LOCKED — Game 1  
**Product:** Echo Lattice  
**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Branch of record (v1 coordination):** `cursor/echo-lattice-v1`  
**Authority:** This document is the production constitution for Echo Lattice. Concept source: [`docs/FIVE_GAMES_TO_BUILD.md`](../FIVE_GAMES_TO_BUILD.md). Index: [`docs/GAME_PLAN.md`](../GAME_PLAN.md).  
**Date locked:** August 2026  
**Owner role:** Production Lead (process, ownership, DoD — not gameplay implementation in this PR)

---

## 1. Locked decision

| Field | Value |
|---|---|
| **Game 1** | **Echo Lattice** (locked) |
| **Pure category** | Adaptive labyrinth puzzle (reactive authorship toy) |
| **Pitch** | A labyrinth that rebuilds from your last thirty moves — you escape by rewriting your own habits, not by beating RNG. |
| **Fantasy** | The dungeon is a function of *me*. Same seed, different player → different building. |
| **Engine / ship form** | Godot 4 · Windows-first Steam `.exe` (+ `.pck`) |
| **Price band (1.0)** | **$5.99–$8.99** |
| **Primary tags** | Puzzle, Procedural Generation, Minimalist, Replay Value, Singleplayer, 2D (Roguelike *light* only if honest) |

**Decision gate closed.** Do not scaffold conflicting GDDs, mash Residue / Quench / Stillroom into this SKU, or reopen tension → coin → idle as Game 1. Games 2–5 (Edgewright, Quench, Black Plinth, Stillroom) remain catalog — separate Steam products, later.

---

## 2. Vision

Echo Lattice sells the *feeling* of generative reality with **offline, deterministic systems**. Adaptation is the spectacle: architecture is a readable transcript of player behavior.

- **Verbs (teach in ≤30s):** four directions + one interact.
- **Spectacle beat:** checkpoint → lattice regenerates from a transform of the move buffer → “wait, *I* made that?”
- **Depth model:** combinatorial (player habits × transform grammar), not a content mountain.
- **Longevity path:** grammar packs, editor / Workshop, seasonal seeds, habit leagues — after the chamber loop is undeniable.
- **No runtime LLM / online worldgen.** Move buffer → hash → authored tile grammar (WFC / rewrite rules). Ghost + seed string always visible so “random” never wins the narrative.

**Aesthetic north star (cheap but strong):** monochrome lattice + one accent that infects overused tiles; modular corridor kit; brutalist subway-map identity; footstep materials that telegraph rewrite punishment; no dialogue essay.

---

## 3. Non-goals (explicit)

| Out of scope for Echo Lattice | Why |
|---|---|
| Genre mashups (coin + horror + idle + cards, etc.) | Hard repo rule; kills store clarity |
| Coin-pusher / slot / debt loops | Separate later catalog; clone-crowded |
| Particle idle / prestige trees | Separate catalog |
| Residue habit-physics chambers *merged into this page* | Sibling alternate — do not mash |
| LLM NPCs, chat dungeons, cloud world models as the loop | Cost, consistency, gameslop stigma |
| Multiplayer-first / friendslop netcode | Wrong product; async ghosts only if scoped |
| Open sandbox / Minecraft survival craft | Chambers first; editor later |
| Full StS deckbuilder, colony/city sims, platform fighter | Scope traps |
| Web/HTML5 as primary SKU | Desktop Steam `.exe` is the product |
| Fake AAA content volume | AAA-indie *quality* + Fortune-500 *process*, not AAA *scope* |
| Prototype-slop vertical slices | No greybox “it technically runs” demos sold as progress |

---

## 4. Quality bar — AAA-indie / 10/10

We judge against **shipped inventive indies**, not AAA headcount.

| Pillar | Bar |
|---|---|
| **Readability** | A stranger understands the rewrite after one checkpoint without a wiki. |
| **Determinism trust** | Same seed + same inputs → same lattice. Ghost + seed always on screen. |
| **Feel** | Every step, fail, rewrite, and door has intentional juice (anim/SFX/haptics plan) — no silent failures. |
| **Session craft** | Demo and first wing feel *finished*: pacing, fail recovery, undo, no softlocks. |
| **Art/audio identity** | Instantly recognizable still; audio is a system cue, not wallpaper. |
| **Accessibility** | Colorblind lattice, hold-to-walk, remappable input, visual channels for critical audio cues — designed in, not bolted on. |
| **Performance** | Stable desktop targets on mid-low Windows hardware for target chamber sizes (see Perf owner). |
| **Steam craft** | Capsule, trailer hook (“It learned you.”), tags, demo = the loop — store page quality matches game quality. |
| **Anti-slop** | No AI-disclosed shovelware patterns: no unedited asset spam, no LLM lore walls, no “infinite content” lies. |

**Process discipline (Fortune-500 studio, not fake AAA scope):**

- Clear **file ownership** (below) — one writer of record per path; others PR with review from owner.
- Specs before sprawl: GDD / systems / tech must exist before content mass-production.
- Acceptance criteria on every milestone (Alpha / Demo / 1.0).
- Parallel agents do not invent competing product truths — they implement against this bible + locked GDD.

---

## 5. Milestone plan — Alpha → Demo → 1.0

Milestones are **quality gates**, not calendar promises. Do not advance without meeting DoD.

### M0 — Production lock *(this document)*

- [x] Game 1 locked as Echo Lattice
- [x] Ownership map published
- [x] Non-goals + quality bar written
- [ ] Sibling agents land specs under `docs/ECHO_LATTICE/` without contradicting this bible

### M1 — Alpha (vertical slice)

**Goal:** One complete, juiced loop a stranger can feel in <5 minutes.

Must include:

- Grid mover + move buffer + **one** rewrite transform (mirror baseline)
- ≥1 handmade chamber with teach → checkpoint → rewrite → key/door
- Ghost path viz + seed string
- Undo / fail-reset that never softlocks
- Desktop Godot export runnable on Windows
- Placeholder art OK if **identity** (mono + accent) and audio stubs telegraph rewrite

**Exit:** Vertical Slice DoD (Section 7) signed off by Production + Design + Tech owners.

### M2 — Demo (Steam-ready first wing)

**Goal:** First wing ships as the marketing truth.

Must include:

- 6–10 chambers, grammar v1, fail/reset juice, ghost replay
- Meta: at least one additional transform unlock path *or* clear vertical progression within the wing
- Steam demo build + page draft (capsules, tags, short description)
- Accessibility pass v1 (colorblind, hold-to-walk, remaps)
- Trailer beat validated: clean hall → rewrite into player’s loop → “It learned you.”

**Exit:** Demo DoD checklist (owner: QA + Marketing + Steam Export) green; wishlist/Next Fest path unblocked.

### M3 — 1.0 (launch candidate)

**Goal:** Paid SKU that earns reviews without apology.

Must include:

- ~12 handmade chambers (MVP floor from five-games doc) + readable transform set (mirror, rotate, thicken, invert — or justified cut with Design Lead sign-off)
- Habit profile bias *or* documented deferral to post-1.0 with compensating depth
- Offline save, achievements, Steam Cloud (as scoped by Steam Export owner)
- Controller glyphs, full accessibility package, performance budget met
- Polish pass: UI, juice, audio identity, tutorial narrative without dialogue essay
- No critical/high bugs open; medium bugs triaged with waivers

**Exit:** 1.0 DoD (Section 7). Post-1.0 (editor, Workshop, daily seeds, habit leagues) stays backlog unless pulled in with explicit scope change.

```mermaid
flowchart LR
  M0[M0 Production lock] --> M1[M1 Alpha vertical slice]
  M1 --> M2[M2 Steam demo wing]
  M2 --> M3[M3 1.0 launch]
  M3 --> Post[Post-1.0 UGC / seasons]
```

---

## 6. File ownership map (parallel agents)

**Rule:** The listed owner is **writer of record**. Other agents may propose diffs via PR; they must not silently overwrite owned paths. Shared roots require coordination notes in the PR body.

| Lane / agent role | Owns (write) | Reads / must not contradict |
|---|---|---|
| **Production Lead** | `docs/ECHO_LATTICE/00_PRODUCTION_BIBLE.md`, lock language in `docs/GAME_PLAN.md`, coordination index | All specs |
| **GDD** | `docs/ECHO_LATTICE/01_GDD.md` (or equivalent GDD path) | Production bible, FIVE_GAMES Game 1 |
| **Systems Design** | `docs/ECHO_LATTICE/02_SYSTEMS.md`, transform/grammar specs | GDD |
| **Habit Engine** | `docs/ECHO_LATTICE/03_HABIT_ENGINE.md` + `game/**/habit*` (when code exists) | Systems, GDD |
| **Tech Architecture** | `docs/ECHO_LATTICE/10_TECH_ARCHITECTURE.md` | Production, Systems |
| **Godot Scaffold** | `game/` project bootstrap (`project.godot`, autoloads, folders) | Tech arch |
| **Game Core** | `game/**` grid, buffer, rewrite runtime, chamber flow | Systems, Tech, Scaffold |
| **Chamber Content** | `docs/ECHO_LATTICE/20_CHAMBERS.md`, chamber data under `game/**/chambers*` | GDD, Systems |
| **Tutorial / Narrative** | `docs/ECHO_LATTICE/21_TUTORIAL_NARRATIVE.md` | GDD (no dialogue essay without sign-off) |
| **Art Bible** | `docs/ECHO_LATTICE/30_ART_BIBLE.md`, art source paths | Production aesthetic north star |
| **Audio Bible** | `docs/ECHO_LATTICE/31_AUDIO_BIBLE.md`, audio source paths | Systems cue requirements |
| **UI Polish** | `docs/ECHO_LATTICE/32_UI.md`, UI scenes/themes | GDD, Accessibility |
| **Juice** | `docs/ECHO_LATTICE/33_JUICE.md`, VFX/feel hooks | Art, Audio, Core |
| **Accessibility** | `docs/ECHO_LATTICE/40_ACCESSIBILITY.md` + a11y settings | UI, Audio, Core |
| **Performance** | `docs/ECHO_LATTICE/41_PERFORMANCE.md`, budgets, profiling notes | Tech, Core |
| **QA** | `docs/ECHO_LATTICE/50_QA.md`, test plans, bug templates | All DoDs |
| **Steam Export** | `docs/ECHO_LATTICE/60_STEAM_EXPORT.md`, export presets, build scripts | Tech, QA |
| **Metadata / Store** | `docs/ECHO_LATTICE/61_STEAM_METADATA.md` (tags, copy, achievements list) | Marketing, GDD |
| **Marketing** | `docs/ECHO_LATTICE/70_MARKETING.md` (trailer beat, capsules brief, wishlist plan) | Metadata, Art |

**Repo-wide shared docs**

| Path | Owner | Notes |
|---|---|---|
| `docs/FIVE_GAMES_TO_BUILD.md` | Concept archive (Five Games PR) | Echo Lattice **locked** here; do not rewrite Games 2–5 casually |
| `docs/GAME_PLAN.md` | Production Lead for Game 1 lock language | Research agents may append *related docs* links |
| `docs/research/**` | Research agents | Context only — cannot unlock/relock Game 1 |
| `README.md` | Production may update “start here” pointers | Keep factual |

**Conflict protocol:** Product truth conflicts → Production Lead. Mechanics conflicts → Systems + GDD. Engine/folder layout → Tech + Scaffold. Store promise vs build → Marketing + Steam Export + Production.

---

## 7. Definition of Done

### 7.1 Vertical slice (Alpha) DoD

All must be true:

1. **Loop complete:** move → buffer ghost visible → checkpoint → **one** deterministic rewrite → obtain objective → exit chamber.
2. **Teach without essay:** first contact conveys authorship of walls within one rewrite; no wall-of-text tutorial required.
3. **Trust:** seed displayed; replay of inputs reproduces lattice; softlock impossible with undo/reset.
4. **Feel:** step / rewrite / fail each have audio+visual acknowledgment (stubs allowed if intentional).
5. **Ship form:** Windows desktop export runs from a clean machine path documented by Scaffold/Steam Export.
6. **Spec sync:** GDD + Systems + Tech docs describe what the slice *actually* does (no aspirational lies).
7. **QA:** written test script executed; no Critical bugs; High bugs waived only in writing by Production.
8. **Anti-slop:** no mashup features, no LLM runtime, no second genre bolted on “for fun.”

### 7.2 Demo DoD

Alpha DoD **plus**:

1. Full first wing (6–10 chambers) paced for 15–40 minute honest session estimate.
2. Steam demo build uploaded or packable; store metadata draft complete.
3. Trailer hook reproducibly capturable from the build.
4. Accessibility v1 checklist green.
5. Performance budget for demo wing met on reference hardware (Perf doc).

### 7.3 1.0 DoD

Demo DoD **plus**:

1. MVP systems floor met (or Design Lead–signed scope cut with compensating clarity).
2. Save/Cloud/Achievements as scoped; controller support; full a11y package.
3. Marketing package final: capsules, trailer, page copy, tags — consistent with shipped build.
4. QA release candidate: zero Critical/High open; Medium backlog accepted.
5. Known limitations documented for patch 1.0.1 — no silent debt.
6. Post-1.0 items (Workshop, dailies, habit leagues) explicitly **not** required unless scheduled.

---

## 8. Working agreements for agents

1. **No gameplay implementation in production-lock PRs** — specs and ownership only until Scaffold/Core lanes open against this bible.
2. **One product truth** — if research PRs disagree, this bible + locked GDD win for Echo Lattice.
3. **Pure category** — when unsure whether a feature belongs, default to **cut**.
4. **Chambers before editor** — UGC is longevity, not Alpha.
5. **Show determinism** — if a feature hides why the lattice changed, it is incomplete.
6. **PR hygiene** — state owned paths touched; link acceptance criteria; do not rewrite other lanes’ bibles.

---

## 9. Restated product spine (from FIVE_GAMES)

Condensed for agents who have not read the full five-games doc:

| Layer | Content |
|---|---|
| Second | Step; hear tile; see ghost of recent moves |
| Minute | Checkpoint → lattice regenerates from move-buffer transform → key/door |
| Session | Wing of 6–10 chambers; unlock transforms (mirror, rotate, thicken, invert) |
| Meta | Habit profile biases packs; daily shared seed; ghost races vs prior self |
| MVP systems | Move buffer, 1 rewrite grammar, 12 handmade chambers, ghost replay, undo, demo wing, offline save |
| Risks | Feels random → show ghost+seed; cold → audio identity; scope creep → chambers first |

Full writeup: [`docs/FIVE_GAMES_TO_BUILD.md`](../FIVE_GAMES_TO_BUILD.md) § Game 1.

---

## 10. Immediate next specs (ordered)

1. GDD lock (`01_GDD.md`) — loop, win/lose, session, original hook  
2. Systems + Habit Engine — buffer, transforms, determinism contract  
3. Tech Architecture + Godot Scaffold — folders, autoloads, export  
4. Art / Audio / UI / A11y bibles — identity before content flood  
5. Chamber plan + Tutorial narrative — teach the rewrite beat  
6. QA + Perf + Steam/Marketing — Demo path instrumentation  

**Gameplay code starts only after** GDD + Systems + Tech agree on the Alpha slice contract.
