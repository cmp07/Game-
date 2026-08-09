# Weaver — Legacy

**Doc:** `docs/WEAVER/08_LEGACY.md`  
**Status:** Systems lock — what persists after a field (CLOUD ONLY)  
**Product line:** Weaver  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`06_WORLD.md`](06_WORLD.md) · [`07_ECONOMY.md`](07_ECONOMY.md) · [`17_MVP.md`](17_MVP.md)

---

## 0. One sentence

**Legacy** is the loom remembering your hand — local silhouettes, residue bias, and optional scraps — not server monuments, housing districts, or tradable flex inventory.

```
Clear → stamp silhouette → bias tag (± scrap) → gallery / next field
```

---

## 1. Fantasy

| Layer | Promise |
|---|---|
| **Recognition** | “That span is mine” without a leaderboard novel |
| **Continuity** | The next field answers *how* you weave, not your wallet |
| **Archive** | A Yard gallery of cloth panels you stood — quiet museum, not social feed |
| **Fairness** | Legacy never softlocks; abandon never shames |

**Player line:** *“The yard kept my seam.”*

---

## 2. Legacy unit

The unit of Legacy is a **stood Structure** (or an authored teach that explicitly marks a Loom-mark residue). Loose Fragments and chalk plans do not persist as Legacy.

| Field | Meaning |
|---|---|
| **Silhouette stamp** | Compact readable outline of the standing graph — gallery / share still |
| **Bias tag** | Small enum: `scaffold`, `pulse`, `culvert`, `kiln`, `span`, `vent`, … |
| **Scrap (optional)** | At most one Fragment family leftover for the next field — never a trade good |
| **Seed linkage** | Which job/field/seed produced it (for ghost replay) |
| **Elegance score (optional)** | Thread count / stress peak — for stars, not for market rank |

---

## 3. Persistence layers

| Layer | MVP | 1.0 | Post (fence) |
|---|---|---|---|
| **Run residue** | Bias next field in the session / campaign queue | Same | Same |
| **Local gallery** | Yard wall of silhouettes + ghost replay | Curated shelves / filters | — |
| **Save file** | Offline JSON/bin under user data | Cloud save optional (Steam) | — |
| **Share code** | Out of MVP | Optional export of silhouette + seed | Async ghost Structures |
| **Server monuments** | **Out** | **Out** | Only if multiplayer doc reopens — never item trade |

MVP Legacy is **thin and local** ([`17_MVP.md`](17_MVP.md) §3.5). That is a feature, not a stub waiting for an MMO.

---

## 4. Residue bias (how the world answers)

On clear, the field may emit one bias tag that reshapes the **next** field’s teach:

| Your hand | Next-field answer (examples) |
|---|---|
| Scaffold-heavy | Longer gap that *expects* a lattice — or a field that punishes over-bracing |
| Pulse / Gate | Beat-literacy job — or a starve job that forbids Echo comfort |
| Culvert | Spill variant with tighter Filter ports |
| Kiln | Seal that needs clean venting |
| Elegant low-Thread clear | Optional praise stamp; not a currency |

Bias is **pedagogy**, not RNG loot. Caps: one primary tag per clear; scrap is rare and never required for campaign completion.

---

## 5. Gallery (Yard wall)

| Rule | Spec |
|---|---|
| **Place** | Shed Yard wall ([`06_WORLD.md`](06_WORLD.md)) |
| **Entry** | Auto on clear when a Structure stood; player may pin favorites |
| **Read** | Silhouette + job name + optional elegance — dry cartographer voice |
| **Ghost replay** | Local playback of pin/draw/tension — teach and pride |
| **Privacy** | Default local-only; share is explicit opt-in later |
| **Not** | Friends list, likes, marketplace, housing plot |

Gallery dopamine must survive with the network cable pulled.

---

## 6. What Legacy must never become

| Drift | Why it fails |
|---|---|
| **Tradable Legacy items** | Converts authorship into AH inventory — banned in [`07_ECONOMY.md`](07_ECONOMY.md) §3 |
| **Housing districts** | Base-building meta island; wrong session shape |
| **Seasonal wipe FOMO** | Live-service spine; offline-first breach |
| **Power Legacy** | Permanent damage/HP buffs from old Structures | Wrong fantasy; gates fairness |
| **Shame archive** | Public fail reels / unpaid debts | Toxicity without craft |

Legacy may **bias teaching** and **store pride**. It may not **buy wins** or **sell flex**.

---

## 7. Campaign & meta hooks

| Mode | Legacy role |
|---|---|
| **Job ladder / campaign** | Residue links panels; gallery fills as cloth diary |
| **Sandbox** | Optional save slots for free Structures — dessert |
| **Daily / shared seed (later)** | Same seed, different hands — compare silhouettes, don’t trade parts |
| **Museum taste (from EL lesson)** | Quiet archive of selves/weaves — ceremony scarce |

Echo Lattice’s Museum is a **craft lesson** (recognition over loot), not a subsystem to copy wholesale.

---

## 8. Save / migration (implementation-facing)

| Contract | Spec |
|---|---|
| **Offline-first** | All MVP Legacy in local save |
| **Schema** | Versioned; missing keys deep-merge; never crash on old gallery |
| **Cap** | Soft cap gallery entries (e.g. 50–100) with pin + LRU for unpinned |
| **Determinism** | Ghost replay uses stored inputs + seed; not a video file requirement |
| **Privacy** | No silent upload; share codes are player-initiated |

---

## 9. Acceptance tests

| Gate | Pass |
|---|---|
| **Residue test** | After two linked jobs, player feels the second answered the first |
| **Gallery test** | Network off: gallery and ghost replay still work |
| **Still test** | Silhouette alone reads as a Structure archetype |
| **Power test** | Removing all Legacy scraps does not block campaign clears |
| **Trade test** | No Legacy object appears in any trade/AH UI (none should exist) |

---

## 10. Non-goals

| Out | Why |
|---|---|
| Server-side shared world monuments as MVP | Online gravity; moderation |
| Player housing / plot claiming | Wrong genre |
| NFT / blockchain “provenance” | Reject |
| Cross-game Echo Lattice save mash | Separate products; EL frozen |
| Legacy as battle-pass track | Live-service |

---

## 11. Lock line

Legacy is **memory of seams** — stamps, bias, and a local gallery — so the yard can answer your hand. It is not a marketplace of past selves.
