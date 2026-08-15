# Weaver — Open Component Grammar

**Doc:** `docs/WEAVER/36_OPEN_COMPONENT_GRAMMAR.md`  
**Status:** Design + data lock — open atoms · free bind attempts · emergent Structures (CLOUD ONLY)  
**Product line:** Weaver  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`04_THREADS.md`](04_THREADS.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md) · [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md)

---

## 0. One sentence

Start from five **atoms** — Light, Matter, Energy, Time, Space — that may **attempt to bind with any other atom**; successful chemistry yields emergent Threads/Structures, and **failed binds are craft tells**, not a closed Brace/Span job menu or a recipe wiki.

```
Atom × Atom → try_bind → (Thread | Fray | Snap) → emergent Structure later
         (never: “open wiki → copy Span Structure steps”)
```

**Player line after a bad bind:** *“That pair won’t hold — and I felt why.”*

---

## 1. Why this doc exists

The W1 / FIRST_FIVE fence correctly teaches **one** honest loop: Anchor + Span → Brace → Span Structure. That fence is a **tutorial aperture**, not the product grammar.

| Closed job grammar (reject as the forever model) | Open component grammar (this doc) |
|---|---|
| Fixed pairs only (Anchor↔Span → Brace) | **Any two** atoms may attempt a bind |
| Success is a recipe hit; else soft-default Brace | Success / strain / snap from **affinity**, not a checklist |
| Structures are named jobs on a board | Structures **emerge** from seated chemistry |
| Skill = memorize legal recipes | Skill = feel which atoms quarrel |
| Wiki / adjacency matrix becomes the game ([`22`](22_DISCOVERY_UX.md)) | Hints stay in situ — port warmth, snap, fray |

This doc locks the **substrate**. Craft nouns (Anchor, Span, Channel, …) remain readable skins that **resolve onto atoms** — they do not replace the open try-bind law.

---

## 2. Hard bans (reaffirmed + new)

| Banned | Why |
|---|---|
| **In-game recipe wiki / step lists** (“how to build Span Structure”) | Spoils discovery ([`22`](22_DISCOVERY_UX.md)) |
| **Closed forever: only Brace/Span jobs** | Deletes chemistry; turns the yard into a three-card menu |
| **Silent illegal** (nothing happens) | Failures must be interesting |
| **Purple chronomancy Time** (rewind, slow-mo, time-stop, hourglass loot) | Still banned ([`03`](03_FRAGMENTS.md)) — see §3.1 |
| **Rarity / gacha atoms** | Wrong shelf |
| **Full adjacency spreadsheet UI** | Spreadsheet craft |

**Allowed:** earned stamps after honest clears (silhouette + one noun) — never step-by-step graphs.

---

## 3. Starting atoms (five)

Atoms are the smallest portable stuff the loom can try to stitch. Each owns a **tell** (silhouette + material) and a **temper** (how it usually fails).

| Atom | Craft reading | Tell (greyscale) | Typical temper |
|---|---|---|---|
| **Light** | Lamp wash, sight-line, chalk mark that *shows* | Soft disk / ray nick | Washout, glare |
| **Matter** | Mass, peg, timber body, weight that *pins* | Stake / block | Crush, pin overload |
| **Energy** | Push, kiln-heart, stored shove | Spring coil / bladder | Overload tear, burst |
| **Time** | **Beat / dwell / period** — workshop interval, not destiny | Pendulum arc / knocker | Stutter, desync |
| **Space** | Gap, span length, extent that *holds open* | Plank / strip | Slack, fiber shear |

```
Atom = (id, temper, ports_hint, tell)
```

### 3.1 Time is beat, not chronomancy

| Time means | Time never means |
|---|---|
| Oscillation, dwell, gate period, knocker interval | Rewind the field |
| “Hold three beats, then vent” | Slow-mo / time-stop power |
| Pulse-adjacent craft | Hourglass loot / purple shards |

If a mock needs a clock face or violet glow for Time to read, rewrite the tell — not the atom.

### 3.2 Craft skins (aliases)

FIRST_FIVE and MVP craft nouns map onto atoms so teach fields stay legible:

| Craft noun | Resolves to |
|---|---|
| Anchor | **Matter** |
| Span | **Space** |
| Charge (later) | **Energy** |
| Pulse (later) | **Time** |
| Lamp / Filter-sense (later) | **Light** |

Skins keep speech tests (“I braced the span to the stake”). Atoms keep the open chemistry.

---

## 4. Open bind law

### 4.1 Any two may try

```
attempt_bind(A, B) → BindResult
```

| Field | Meaning |
|---|---|
| `outcome` | `bind` · `strain` · `snap` |
| `thread?` | Present only on `bind` |
| `fray?` | Optional residue on `strain` / `snap` |
| `tell` | One short craft line (diegetic) |
| `consumed` | Which inputs leave the hand |

**Invariant:** the player can select any two carried pieces and press bind. The loom **always answers**. Refusing the attempt (UI lockout for “illegal pair”) is banned.

### 4.2 Outcomes that stay interesting

| Outcome | Hand | World | Feel |
|---|---|---|---|
| **bind** | Both consumed → Thread | Provisional chalk seam | Paper-press combine flash |
| **strain** | Usually refund both (scar optional) | Local crease / dust; no Thread | Almost — teach quarrel |
| **snap** | Refund both (or asymmetric sink if authored) | White snap → settle; optional Fray scrap | Funny / sharp craft tell |

Failures are **content**, not error toasts. Prefer one glyph + one chalk line over paragraphs.

### 4.3 Affinity (designers — not a player wiki)

Affinity is **data for the loom**, not a searchable catalog. Ship as compact tables under `game/*/content/weaver/` (or `game/weaver/content/`). Do not expose a full matrix in UI.

Symmetric examples (illustrative; code + JSON are authority):

| Pair | Lean | Emergent Thread lean | Failure lean |
|---|---|---|---|
| Matter × Space | bind | Brace / span seam | — |
| Matter × Matter | bind | Pin brace | Crush if over-mass |
| Space × Space | bind | Fiber tether | Slack shear |
| Light × Space | bind | Beam / sight-line | — |
| Light × Matter | bind | Lamp seat | — |
| Energy × Matter | bind | Charge cord | Burst |
| Energy × Space | bind | Feed / flow | Starve |
| Time × Energy | bind | Pulse / beat | Desync chatter |
| Time × Space | bind | Period gate | — |
| Time × Matter | strain | — | Dwell weight — won’t lift |
| Light × Energy | strain | — | Glare wash |
| Light × Time | snap | — | Afterimage stutter |
| Energy × Energy | snap | — | Overload tear |
| Time × Time | snap | — | Stutter desync |
| Light × Light | strain | — | Washout |

Authored overrides may promote a pair for a field seed; they must not collapse the open law back into “only three recipes exist.”

---

## 5. Emergent Structures

Structures are **not** a closed job board of Brace/Span prefabs. After Tension, the seated graph’s atom signature suggests an archetype:

| Dominant signature | Emergent lean | Inhabit read |
|---|---|---|
| Matter + Space braced | **Span** | Cross the gap |
| Light + Matter seated | **Lamp / Beacon** | Tell reveals a recover |
| Energy + Space fed | **Channel / Culvert** | Route flow |
| Time + Energy pulsed | **Gate / Kiln-beat** | Cross on the beat |
| Mixed / unstable | **Scaffold / Fray** | Hold briefly; teach collapse |

MVP may still ship a single Span Structure mesh for East Post Gap. The **grammar** must already allow other signatures without a new wiki page per job.

---

## 6. Relation to FIRST_FIVE / closed jobs

| Layer | Role |
|---|---|
| [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) | Timed teach script — still Anchor/Span speech |
| Closed Brace recipe | **Compatibility path** — Matter×Space bind still yields Brace |
| This doc | Forever law — open try-bind + interesting fail |

Conflict rule: FIRST_FIVE may **narrow the field pool** (only Matter/Space skins on the chalk). It may not change `attempt_bind` into “always Brace” or “reject unknown pairs.”

---

## 7. Runtime contract (prototype)

| Surface | Expectation |
|---|---|
| `content/atoms.json` (or recipes `atoms` block) | Five atoms + tempers + craft aliases |
| `combine_affinity` table | Pair → outcome / thread / tell / consume |
| `Loom.attempt_bind` / `combine_indices` | Uses affinity; never silent no-op |
| Combine UI | Preview can be uncertain (“may strain”) — not a wiki |
| Tests | Open pairs may bind or fail interestingly; Matter×Space still braces |

---

## 8. Acceptance

1. Cold reader names the five atoms without saying “purple time crystal.”  
2. Any two carried atoms can be selected; bind always returns a tell.  
3. At least three **failure** tells are distinguishable (strain vs snap vs overload).  
4. Matter × Space still produces a Brace-class Thread (FIRST_FIVE intact).  
5. No in-game recipe wiki, step list, or full adjacency matrix UI ships with this grammar.  
6. Greyscale: five atom tells remain distinct.

---

## 9. Non-goals

- Replacing all craft nouns with abstract physics jargon in player HUD  
- Procedural unique affix atoms  
- Network-synced discovery wiki  
- Expanding Thread types beyond MVP four in this PR  

---

Open component grammar is **Light · Matter · Energy · Time · Space**, freely attempted, with failures that teach. Closed Brace/Span jobs are a teach aperture and a compatibility lean — not the ceiling of the loom.
