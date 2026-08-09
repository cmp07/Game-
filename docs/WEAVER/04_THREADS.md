# Weaver — Threads

**Doc:** `docs/WEAVER/04_THREADS.md`  
**Status:** Systems lock — typed relations (CLOUD ONLY)  
**Product line:** Weaver  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md)

---

## 0. One sentence

A **Thread** is a typed relation you draw between Fragment ports — the stitch that turns atoms into a graph the loom can tension.

```
Thread = (type, from_port, to_port, span_cost, stress)
```

---

## 1. Why Threads exist

Without Threads, Fragments are inventory trash.  
Without typed Threads, the game becomes “stick any two parts together.”  
Threads are the **skill surface**: legality, load, and elegance live here.

| Promise | Ship test |
|---|---|
| Relations are verbs | Player says “I braced it” / “I fed the kiln” — not “I linked node A–B” |
| Mistakes are readable | Illegal snap names the port conflict in one glyph flash |
| Mastery is sparse graphs | Best clears use fewer, smarter Threads |

---

## 2. Thread types (MVP)

Ship **four** types. Resist a toolbox of twelve.

| Type | Ports it respects | What it means in play | Failure mode |
|---|---|---|---|
| **Brace** | `brace` ↔ `brace` or `brace` → `ground` | Holds load; makes spans stand | Overload tear |
| **Feed** | `out` → `in` (or `release` → `in`) | Moves flow / charge / material | Starve or burst |
| **Oppose** | `out`/`release` → stressed port | Cancels or vents excess | Blowback if mis-aimed |
| **Echo** | `sense`/`beat` → `sense`/`beat`/`in` | Copies rhythm or state; no mass transfer | Desync chatter / false beat |

### Non-goals for v1 Thread types

| Out | Why |
|---|---|
| Damage / aggro Threads | Combat mash |
| Trade / market Threads | Economy doc may cover exchange — not a bind verb |
| Chrono / rewind Threads | Banned with Time Fragments |
| Friendship / faction Threads | Social sim mash |
| Freeform “any to any” | Deletes skill |

---

## 3. Drawing rules

| Rule | Spec |
|---|---|
| **Port match** | Type + port compatibility required or the Thread snaps |
| **Span cost** | Longer draws spend more of the field’s Thread budget |
| **Budget** | Soft cap per field (teach 4 / mastery 8 as intuition) |
| **Planarity soft-rule** | Crossing Threads raise stress; not always illegal |
| **One commit language** | Draw is provisional chalk; Tension seats ink |
| **Undo** | Last Thread always removable before Tension |

Drawing should feel like **pulling fiber across a page**, not placing RTS power lines.

---

## 4. Stress & readability

| Signal | Player read |
|---|---|
| Slack fiber (dashed chalk) | Provisional / under-loaded |
| Taut ink | Seated, healthy |
| Rust creep along a Thread | Approaching overload |
| Snap white → settle | Illegal bind |
| Tear gap | Collapse culprit |

Stress is **spatial** (thickness, rust, slack) — not a floating DPS number.

---

## 5. Chemistry cheatsheet (designers)

Useful legal patterns for content authors:

| Pattern | Threads | Resulting Structure fantasy |
|---|---|---|
| Simple bridge | Span `brace`—Anchor `ground` ×2 | Walkable span |
| Irrigated path | Channel Feed chain → Filter | Route water / dust aside |
| Beating gate | Pulse Echo → Filter sense; Charge Feed → release | Timed open (oscillation, not time-travel) |
| Vent kiln | Charge Feed → Channel; Oppose vent to ground | Safe dump of excess |
| Scaffold then span | Anchor brace grid → longer Span | Two-step Tension teach |

Content bible (later) owns field scripts; this table is the **legal grammar**.

---

## 6. Tension handoff

When the player **Tensions**:

1. Graph freezes provisional chalk.  
2. Solver checks: port legality · load ≤ capacity · no illegal cycles for Feed · goal-relevant connectivity.  
3. On pass: Threads become seated seams; Fragments become a Structure ([`05_STRUCTURES.md`](05_STRUCTURES.md)).  
4. On fail: highlight the minimum failing set (one Thread or one Fragment); refund budget.

Threads never “upgrade” via XP. Mastery is **which** Thread you choose.

---

## 7. UX copy (diegetic)

| Event | Line temperature |
|---|---|
| Legal brace | “Seam holds.” |
| Illegal port | “That edge won’t take this stitch.” |
| Overload | “Too much on one fiber.” |
| Starve | “Nothing reaches the far port.” |
| Elegant clear (few Threads) | “Tight weave.” |

Dry cartographer voice. No LOOT / CRIT / TIME SHARD banners.

---

## 8. Acceptance tests

| Gate | Pass |
|---|---|
| **Four-type test** | All MVP fields solvable with Brace/Feed/Oppose/Echo only |
| **Snap test** | Illegal bind understood without opening a manual |
| **Culprit test** | Collapse highlights ≤2 graph elements |
| **Elegance test** | A 3-Thread clear and a 7-Thread clear are both valid; stars prefer 3 |
| **Purity test** | Threads remain meaningful in singleplayer offline |

---

## 9. Lock line

Threads are the **stitches** — Brace, Feed, Oppose, Echo — scarce, typed, and honest. They are how Fragments become cloth, not how the game pretends to be a skill tree.
