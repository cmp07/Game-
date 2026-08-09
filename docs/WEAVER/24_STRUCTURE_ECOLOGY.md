# Weaver — Structure Ecology

**Doc:** `docs/WEAVER/24_STRUCTURE_ECOLOGY.md`  
**Status:** Systems lock — Structure classes that answer each other (CLOUD ONLY)  
**Product line:** Weaver (north star; Echo Lattice frozen — see [`PIVOT.md`](PIVOT.md))  
**Branch:** `cursor/weaver-ecology`  
**Peers:** [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`04_THREADS.md`](04_THREADS.md) · [`06_WORLD.md`](06_WORLD.md) · [`08_LEGACY.md`](08_LEGACY.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) · [`17_MVP.md`](17_MVP.md) · [`MASTER_GDD.md`](MASTER_GDD.md)

---

## 0. One sentence

**Structure Ecology** is how stood graphs *answer* each other in a field — Beacons call, Recorders keep beat, Gateways threshold — so authorship becomes a living yard grammar, not a pile of one-off recipes.

```
Structure Ecology = class roles + adaptation rules over seated graphs
```

`05_STRUCTURES` owns *what a Structure is*. This doc owns *how classes coexist, cue, and adapt*.

---

## 1. Why ecology (not a bigger catalog)

MVP archetypes (Span, Culvert, Kiln, Gate, Scaffold, Loom-mark) teach **one rewrite channel** at a time. Ecology starts when composition fields need Structures that **signal**, **remember**, and **threshold** without becoming prefab buildings or EL habit-maze dials.

| Promise | Ship test |
|---|---|
| Classes read as craft roles | Mute still: Beacon / Recorder / Gateway silhouettes distinct |
| Adaptation is pedagogy | Next-field bias answers your hand — never softlocks or loot RNG |
| Composition stays sparse | Ecology jobs use ≤2 stood Structures; no base-building island |
| Offline fair toy | Deterministic seed + same graph → same class behavior |

**Player line:** *“My beacon called the gate; the recorder kept the beat I had to walk.”*

---

## 2. Authority & milestone fence

| Layer | When | Notes |
|---|---|---|
| **MVP archetypes** (`05` §4) | Vertical slice + Demo | Ecology classes **out** of first-thirty spine |
| **Ecology teach** | Late MVP 1.0 jobs (after Gate + Echo literacy) | One class per teach job |
| **Composition ecology** | End of 1.0 / post-MVP pick | Beacon↔Gateway or Recorder↔Gate pairs only |
| **Hard out** | Always | Prefab “place Beacon from menu”; EL adaptation dials; combat aggro towers |

Catalog budget still obeys [`17_MVP.md`](17_MVP.md): ≤20 Structure recipes at 1.0. Ecology **reuses** Fragment families + Thread types — it does not add a second encyclopedia.

---

## 3. Structure class taxonomy

Every stood Structure may wear **one primary class**. Archetype (Span, Culvert, …) names the *craft shape*; class names the *ecological role*.

| Class | Role in the yard | Primary rewrite channel | Typical Fragments | Typical Threads |
|---|---|---|---|---|
| **Work** *(baseline)* | Does the job body — span, vent, route | Topology / flow / load / pulse / vent | Span, Anchor, Channel, Charge, Filter, Pulse | Brace, Feed, Oppose, Echo |
| **Beacon** | Marks a locus; calls attention / Fragment recover | Sense → Survey tell (soft topology) | Filter (`sense`), Anchor, Pulse | Echo, Brace |
| **Recorder** | Holds a beat or state the field must answer | Pulse / Echo memory | Pulse, Filter, Charge | Echo, Feed |
| **Gateway** | Thresholds passage between zones or beats | Topology + Pulse (gated) | Filter, Span, Pulse, Anchor | Brace, Echo, Oppose |

**Naming rule:** craft nouns (beacon pole, ledger drum, threshold loom) — not myth towers, radar UI chrome, or “AI sentinel.”

### Class vs archetype (examples)

| Stood graph | Archetype (`05`) | Ecology class |
|---|---|---|
| Anchor–Span–Anchor bridge | Span | Work |
| Pulse + Filter timed door | Gate | Gateway *(or Work if no zone split)* |
| Sense-lit peg that reveals a frayed shelf | Loom-mark / custom | Beacon |
| Pendulum ledger that stamps a beat residue | — | Recorder |
| Scaffold that only enables Structure #2 | Scaffold | Work (load class stays Work) |

A Gate archetype **may** promote to Gateway when the field authors a true threshold (two zones, clear predicate needs crossing). Otherwise keep it Work to avoid vocabulary bloat in teach jobs.

---

## 4. Class specs

### 4.1 Beacon

**Fantasy:** A seated tell — peg, flag-fiber, knocker post — that makes a scarce locus *readable* and may bias Recover.

| Spec | Lock |
|---|---|
| **Stand condition** | Filter/`sense` or Pulse/`beat` grounded; at least one Echo Thread legal |
| **Field rewrite** | Soft Survey tell: highlights recover slots, fray seams, or goal anchors in radius — **not** fog-of-war combat vision |
| **Inhabit** | Player must *use* the tell (walk the revealed path / recover the called Fragment) — building alone does not clear |
| **Residue** | Bias tag `beacon` — next field may hide a slot until a Beacon stands, *or* punish Beacon spam with a quiet field that needs Work first |
| **Juice** | Dust mote drift toward the locus; fiber lift; quiet knocker — no neon ping, no minimap icon swarm |

**Non-goals:** Aggro radius, XP shrines, multiplayer rally flags, purple void lighthouses.

### 4.2 Recorder

**Fantasy:** A ledger drum / bellows stamp that *keeps* a beat or state so a later inhabit can match it.

| Spec | Lock |
|---|---|
| **Stand condition** | Pulse Fragment seated; Echo Thread to a `sense`/`beat` port; optional Charge Feed for sustained stamp |
| **Field rewrite** | Writes a **beat latch** or **state latch** into the field (open window, flow phase, load permission) — oscillation craft, never rewind / slow-mo |
| **Inhabit** | Clear requires acting *on* the latched beat/state (cross while open, release while charged) |
| **Residue** | Bias tag `recorder` / `pulse` — next field may require matching a stamped silhouette beat, or starve Echo comfort |
| **Juice** | Audible seat phrase (see [`10_AUDIO.md`](10_AUDIO.md)); chalk tick on latch; rust if desynced |

**Non-goals:** VCR time-travel, ghost replay as a Structure class (Legacy owns ghosts), combat cooldown meters.

### 4.3 Gateway

**Fantasy:** A threshold you authored — cloth door, pendulum stile, braced hatch — that splits the field into zones until the graph allows passage.

| Spec | Lock |
|---|---|
| **Stand condition** | Filter + (Pulse **or** Oppose vent) + braced Anchors; ports legal per [`04_THREADS.md`](04_THREADS.md) |
| **Field rewrite** | Topology edge(s) appear/disappear on latch — primary channel still **one** (Pulse *or* Topology; pick per recipe) |
| **Inhabit** | Must cross (or send flow) through the threshold after stand — looking at it is not enough |
| **Composition** | May listen to a Beacon (reveal which stile) or a Recorder (when to cross) |
| **Residue** | Bias tag `gateway` / `pulse` — next field favors dual-zone jobs or counters with a single-zone Work teach |
| **Juice** | Crease → lift → seat; stile open reads as cloth parting — not sci-fi hard-light doors |

**Non-goals:** Fast-travel hubs, loading-screen portals between biomes, MMO instance gates, NFT door keys.

---

## 5. Ecology interactions (composition grammar)

Composition fields may seat **at most two** Structures. Legal ecology pairs for 1.0:

| Pair | Player fantasy | Clear predicate sketch |
|---|---|---|
| **Beacon → Work** | Tell reveals the scarce recover; Work spans/vents the answer | Recover called Fragment → stand Work → inhabit |
| **Beacon → Gateway** | Beacon marks which stile; Gateway opens that edge | Survey tell → threshold stand → cross |
| **Recorder → Gateway** | Recorder latches beat; Gateway opens on that beat | Latch → timed cross |
| **Recorder → Work (Kiln/Culvert)** | Latch permits release/flow phase | Latch → vent/route → inhabit |
| **Work → Work** | Existing `05` composition (Scaffold→Span) | Unchanged — no ecology class required |

### Illegal / deferred pairs

| Pair | Why deferred |
|---|---|
| Beacon + Recorder + Gateway (three stands) | Breaks Structure-slot cap; demoware |
| Beacon → Beacon chains | Minimap meta; deletes Survey skill |
| Recorder → Recorder stacks | Chrono kit smell; desync hell |
| Gateway → Gateway maze | Habit-maze gravity ([`PIVOT.md`](PIVOT.md) — wrong SKU) |

---

## 6. Adaptation rules

Adaptation is **how the Yard answers your ecological hand** across jobs. It extends residue bias ([`08_LEGACY.md`](08_LEGACY.md) §4) with class-aware tags. It is **not** Echo Lattice soft/hard habit adaptation and must never import mode dials from `game/echo_lattice/`.

### 6.1 Bias tags (ecology set)

| Tag | Emitted when | Next-field answer (pick one authored beat) |
|---|---|---|
| `beacon` | Cleared with a Beacon stand | Hidden recover until Beacon; **or** “Work first, tell later” counter |
| `recorder` | Cleared with a Recorder latch used | Beat-match Gateway; **or** starve Echo / forbid latch comfort |
| `gateway` | Cleared via threshold inhabit | Dual-zone Gap/Beat; **or** single-zone Span teach that strips thresholds |
| `work` | Cleared with baseline archetype only | Stay on `05` bias table (`span`, `scaffold`, `culvert`, …) |
| `composition` | Cleared with a legal ecology pair | Offer a harder pair; never force three Structures |

Caps (law):

1. **One primary tag per clear** — ecology tags compete with archetype tags; content picks the teach focus.  
2. **No softlock bias** — every biased field remains solvable with refund / undo ([`02_CORE_LOOP.md`](02_CORE_LOOP.md)).  
3. **No loot bias** — tags never roll rarity, currency, or trade goods ([`07_ECONOMY.md`](07_ECONOMY.md)).  
4. **Determinism** — seed + prior tag + player graph → same field grammar.  
5. **Abandon is quiet** — leaving a job emits no punishment tag.

### 6.2 In-field adaptation (during a job)

While a Structure stands, the field may **adapt locally** under authored rules:

| Stimulus | Allowed adaptation | Forbidden |
|---|---|---|
| Beacon stands | Reveal authored recover slots / fray glyphs in radius | Spawn infinite Fragments; reveal whole map |
| Recorder latches | Open a timed topology/flow window; desync Frays the Recorder | Rewind player position; slow-mo the sim |
| Gateway opens | Enable zone edge; optional Fray if held open past stress | Teleport; load another scene as “portal” |
| Work Frays | Local stress / collapse culprit | Enemy DPS chip damage |
| Collapse | Refund per Fragment rules; latches clear | Keep hidden softlock state |

**Readability law:** every adaptation must have a spatial tell (fiber lift, chalk tick, stile crease) within one glance — no spreadsheet meters.

### 6.3 Session adaptation curve (designer cheatsheet)

| Session beat | Ecology exposure |
|---|---|
| First thirty / Demo | **None** — Work archetypes only |
| Mid 1.0 | Teach Beacon alone → Recorder alone → Gateway alone |
| Late 1.0 | One composition pair job; gallery may stamp class silhouette |
| Post-MVP | Optional second pair type; still ≤2 stands per field |

Progression voice stays literacy stamps ([`11_PROGRESSION.md`](11_PROGRESSION.md)) — not XP for “Beacon Level 3.”

---

## 7. Solver & implementation contracts

| Check | On Tension | On fail / Fray |
|---|---|---|
| Class legality | Graph matches class recipe ports | Snap highlight class-missing port |
| Single primary class | Exactly one class flag per stood Structure | Authoring error — reject stand |
| Latch budget | ≤1 active Recorder latch per field | Second latch illegal or Oppose-vents the first |
| Beacon radius | Authored cells only (mask), not flood-fill whole field | Over-claim → coach chalk warn (soft) |
| Gateway edge | Claimed edges must exist in field topology table | Floating stile → grounding fail |
| Goal relevance | Soft warn if class cannot touch clear predicate | Never auto-build |

Determinism: same field seed + same graphs + same latch timeline → same adaptation outcome. No hidden rolls.

Python/GDScript later: treat class as an enum on the seated Structure; adaptation as pure functions of `(seed, bias_tag, stands[])`.

---

## 8. Juice & art contract

| Class | Still read | Motion |
|---|---|---|
| Beacon | Peg / flag-fiber / knocker — ink & rust, not neon ping | Mote drift + quiet knocker |
| Recorder | Drum / bellows / ledger stamp | Chalk tick on latch; seat phrase |
| Gateway | Cloth stile / hatch / pendulum door | Crease → lift → part |
| Ecology pair | Two silhouettes that *point* at each other | Call → answer (Beacon dust → Gateway crease) |

Materials follow [`09_VISUAL.md`](09_VISUAL.md): paper-textile, kiln copper, chalk — **not** purple void monuments, hard-light portals, or radar UI.

---

## 9. Acceptance tests

| Gate | Pass |
|---|---|
| **Class still test** | Greyscale: Beacon / Recorder / Gateway readable without labels |
| **Inhabit test** | Standing any ecology class without using its tell/latch/threshold cannot clear |
| **Pair test** | One authored Beacon→Gateway job clears only when both roles fire in order |
| **Bias test** | Emitting `recorder` changes the next job’s teach focus; never softlocks |
| **Fence test** | First-thirty spine has zero ecology class requirements |
| **Anti-EL test** | No habit mode dials, rewind latches, or purple chronomancy language |
| **Cap test** | Ecology recipes fit inside ≤20 Structure recipes at MVP 1.0 |

---

## 10. Non-goals

| Out | Why |
|---|---|
| Prefab place-from-menu Beacons | Deletes Fragment/Thread skill |
| Ecology as combat towers / aggro | Genre mash |
| Three-Structure ecosystems | Slot & readability breach |
| Server-synced “living” ecology | Online gravity; Legacy stays local |
| EL soft/hard adaptation import | Wrong product line |
| Time-travel Recorders | Banned with Time Fragments ([`03_FRAGMENTS.md`](03_FRAGMENTS.md)) |
| Gateway fast-travel / biome hubs | Open-world tourism ([`06_WORLD.md`](06_WORLD.md)) |

---

## 11. Conflict resolution

| Conflict | Winner |
|---|---|
| Recipe fantasy vs class role | Class role for ecology jobs; archetype name may stay for Work |
| This doc vs `05_STRUCTURES` lifecycle | `05` lifecycle wins; ecology only adds class + adaptation |
| Bias tag clash (`pulse` vs `recorder`) | Content author picks **one** primary tag per clear |
| Catalog hunger vs MVP caps | Caps win — cut recipes, don’t expand encyclopedia |
| MASTER glossary silence on class nouns | This doc defines Beacon / Recorder / Gateway until MASTER absorbs them |

---

## 12. Lock line

Structure Ecology is **Beacon, Recorder, Gateway** — craft classes that call, latch, and threshold — adapted across jobs by honest residue bias. If it didn’t stand from your graph, it isn’t ecology; if it needs purple time-magic or a third Structure, it isn’t Weaver.
