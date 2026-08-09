# Weaver — Fragments

**Doc:** `docs/WEAVER/03_FRAGMENTS.md`  
**Status:** Systems lock — atomic craft units (CLOUD ONLY)  
**Product line:** Weaver  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`04_THREADS.md`](04_THREADS.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`21_FRAGMENT_FEEL.md`](21_FRAGMENT_FEEL.md) (recover juice · silhouette · beat color)

---

## 0. One sentence

A **Fragment** is a portable atom of *matter, pressure, or behavior* with typed ports — not a shard of time, not a purple power-up, not a lore trinket.

```
Fragment = (kind, ports, capacity, tell)
```

---

## 1. Hard ban — no purple Time cliché

| Banned | Why |
|---|---|
| **“Fragments of Time” / chronoshards / hourglass drops** | Default AI pitch; hollow fantasy |
| **Purple / violet neon as Fragment identity** | Gameslop signal; fights Field-craft materials |
| **Rewind, slow-mo, time-stop as the Fragment verb** | Chronomancy kit masquerading as systems craft |
| **Rarity rainbow (grey→purple) loot ladder** | Slot dopamine; wrong shelf |
| **Mystery-AI “memory fragments”** | Store stigma + empty verbs |

If a design doc needs purple glow or a clock metaphor to make Fragments exciting, the Fragment set is wrong — rewrite the kinds, not the VFX.

**Allowed clock-adjacent only as diegetic craft tools** (e.g. a **Pendulum** Fragment that sets *oscillation / beat* for a bridge) — never as “collect time to rewind the level.”

---

## 2. What a Fragment is

| Field | Meaning |
|---|---|
| **Kind** | Authored family (see §3) |
| **Ports** | Sockets Threads may attach to (`in`, `out`, `brace`, `sense`, …) |
| **Capacity** | How much load / flow / stress it can hold before a Structure collapses |
| **Tell** | One readable silhouette + material (ink, rust, fiber, chalk) — no rarity border |
| **Stance** | `loose` (carried) → `seated` (in a standing Structure) |

Fragments are **legible toys**. A player should name a kind from silhouette alone after the teach set.

---

## 3. Kind families (MVP set)

Keep the first ship to **six families**. Depth comes from Thread chemistry, not a encyclopedia.

| Family | Fantasy | Example ports | Capacity reads as… |
|---|---|---|---|
| **Span** | Beam / plank / cloth strip | `brace`, `brace` | How long a gap it can hold |
| **Anchor** | Peg, stake, weight | `brace`, `ground` | How hard it pins a graph |
| **Channel** | Culvert, trough, duct | `in`, `out` | How much flow it may pass |
| **Charge** | Spring, bladder, kiln-heart | `in`, `out`, `release` | Stored push before dump |
| **Filter** | Sieve, baffle, one-way flap | `in`, `out`, `sense` | What it refuses / sorts |
| **Pulse** | Pendulum, bellows, knocker | `beat`, `out` | Tempo it imposes on linked parts |

**Naming rule:** materials and craft nouns (stake, culvert, bellows) — not myth nouns (chrono, void, aether).

### Explicitly deferred families

| Deferred | Reason |
|---|---|
| Creature / NPC Fragments | Becomes pet collection |
| Weapon / damage Fragments | Combat mash |
| Time / fate / soul Fragments | Banned cliché lane |
| Procedural “unique” affix Fragments | Diablo ladder |

---

## 4. Ports (the only inventory that matters)

| Port | Direction | Typical Thread |
|---|---|---|
| `brace` | undirected / mutual | Brace |
| `ground` | sink | Brace → world |
| `in` / `out` | directed | Feed |
| `release` | directed dump | Feed or Oppose |
| `sense` | read-only | Echo |
| `beat` | clocking (oscillation, not time-travel) | Echo / Feed |

Port mismatch is the primary teachable mistake. UI shows **port glyphs**, not paragraph tooltips.

---

## 5. Recover rules

| Rule | Spec |
|---|---|
| **Field-local** | Most Fragments spawn as field content; not a global loot table |
| **Carry cap** | MVP: 3–5 loose Fragments |
| **No rarity** | Variants are size / capacity tiers (S/M/L), named plainly |
| **Refund on collapse** | Loose + seated Fragments from *your* failed tension return to hand unless the field authors a sink |
| **Residue** | Cleared fields may leave one scrap Fragment kind as bias — never a purple drop |

---

## 6. Tells (art / UX contract)

| Do | Don’t |
|---|---|
| Paper, fiber, rust, chalk, timber, kiln-orange accent | Purple void glow, holographic rarity |
| One silhouette language per family | Affix stars / skull icons |
| Seat animation = press into cloth/page | Pokemon catch beam |
| Capacity as thickness / stitch density | Numeric DPS |

Accent color, if needed: **kiln rust / copper** — shared craft warmth with Field Ledger lessons — not chroma-purple.

---

## 7. Design tests

| Gate | Pass |
|---|---|
| **Silhouette test** | Six MVP families distinguishable in greyscale |
| **Cliché test** | Doc + mock contain zero “time fragment” / purple loot framing |
| **Port test** | New player explains one illegal bind after F1 |
| **Speech test** | “I needed a bigger Span” — not “I needed a rare” |
| **Shelf test** | Fragments still make sense if multiplayer and monetization docs are deleted |

---

## 8. Relationship to Structures

Fragments do nothing permanent until Threads bind them and Tension seats a Structure ([`05_STRUCTURES.md`](05_STRUCTURES.md)). A pile of Fragments in hand is **yarn**, not cloth.

---

## 9. Feel deepen (pointer)

Hand-feel beyond this systems lock — recover settle phrase, greyscale silhouette grammar, and **brass/patina Pulse beat color (never purple)** — lives in [`21_FRAGMENT_FEEL.md`](21_FRAGMENT_FEEL.md).

---

## 10. Lock line

Fragments are **craft atoms with ports** — span, anchor, channel, charge, filter, pulse — recovered and spent to weave Structures. They are never purple time.
