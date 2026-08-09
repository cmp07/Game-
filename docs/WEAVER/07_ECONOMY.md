# Weaver — Economy

**Doc:** `docs/WEAVER/07_ECONOMY.md`  
**Status:** Archive systems lock — scarcity spine + **player-trade critique** (CLOUD ONLY)  
**Live authority (feel / solo satisfaction):** [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md)  
**Product line:** Weaver  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`06_WORLD.md`](06_WORLD.md) · [`08_LEGACY.md`](08_LEGACY.md) · [`13_MONETIZATION.md`](13_MONETIZATION.md) · [`17_MVP.md`](17_MVP.md) · [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md)

---

## 0. One sentence

Weaver’s economy is **craft scarcity** — Fragment slots, Thread budget, Tension commits, and residue marks — not a marketplace, not a soft currency treadmill, and not other players’ inventories.

```
Scarcity = ports + spans + collapse risk  (not gold + stalls + fees)
```

**V2 note:** For solo-satisfying scarcity design (feel, sinks, tuning rubric), prefer [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md). This file remains the trade pre-mortem and original loop table.

---

## 1. Loop economy (the real one)

Borrowed and locked from [`02_CORE_LOOP.md`](02_CORE_LOOP.md) §4 — this is the only economy the vertical slice may ship:

| Resource | Source | Sink | Cap (MVP intuition) | Player read |
|---|---|---|---|---|
| **Fragment slots** | Field pool / recover | Seat into Structure; abandon loose | 3–5 carry | “I can’t pocket the whole yard.” |
| **Thread budget** | Field grant | Draw length + count; illegal snaps refund | Teach ~4 / mastery ~8 | “Each stitch costs span.” |
| **Tension commits** | Field grant | Stand / failed stand (refund on fail) | 1–2 per field | “Commit is scarce; chalk is cheap.” |
| **Residue marks** | Clear | Bias next field; gallery stamp | 1 signature ± scrap | “The loom kept my hand.” |

**No parallel currencies** in MVP: no gems, stamina bars, premium fiber, battle-pass tokens, or reputation ledgers that gate jobs.

Stars / ranks (if any) score **Thread elegance** and graph clarity — never a speed tax as the only grade, never a pay wall.

---

## 2. Soft material costs (authored, not simulated town)

| Layer | Policy |
|---|---|
| **Job costs** | A field may withhold a Fragment family until a prior job clears — unlock order, not shop price |
| **Recipe stamps** | Structure archetypes unlock by teaching jobs, not by gold sinks |
| **Scrap Fragment** | Optional Legacy leftover ([`08_LEGACY.md`](08_LEGACY.md)) — one family, never a trade good |
| **Sandbox** | Free-build dessert may relax caps; campaign jobs keep them honest |

If designers need a number-go-up sheet to balance a field, the field’s scarcity is wrong — tighten ports and budgets, don’t invent coin.

---

## 3. Critique — player-to-player trade

### 3.1 Verdict

| Decision | Lock |
|---|---|
| **MVP** | **No player trade.** No auction house, direct trade window, shared stash, or “stall” in the Yard. |
| **1.0** | Still **no** human-to-human item/currency exchange. |
| **Post-1.0** | Only reconsider under the narrow fence in §3.5 — default remains **no**. |

Player trade is not a feature gap. It is a **different product** (MMO / extraction / live economy) wearing Weaver’s nouns.

### 3.2 Why trade attacks the fantasy

| Claim for trade | What it actually does to Weaver |
|---|---|
| “Players will help each other” | Optimal Fragments become **meta imports**; Recover stops teaching |
| “Endgame sinks” | Creates dual economy: craft skill vs **market access** |
| “Legacy feels shared” | Turns silhouettes into **assets**; gallery becomes inventory flex |
| “Retention / social” | Pulls design toward fees, fraud, moderation, always-online |
| “Cosmetic only trade” | Cosmetics become the real progression signal; craft pride dilutes |

The dopamine Weaver sells is **“I wove that — and I have to live in it.”** Trade relocates dopamine to **“I acquired that.”** Those are incompatible north stars on one store page.

### 3.3 Failure modes (pre-mortem)

| Mode | Tell | Cost |
|---|---|---|
| **RMT / gray market** | Discord price lists for rare scraps | Trust + legal surface; support load |
| **Alt farming** | Multibox recovers for main | Forces anti-farm systems Weaver doesn’t want |
| **Pay-adjacent pressure** | “Just sell cosmetics that trade” | Soft P2W perception even if stats equal |
| **Design gravity** | Docs start with stalls before First Stand sings | Verb mud; delayed prototype ([`18_RISKS.md`](18_RISKS.md) D4) |
| **Category mush** | Tags pick up Multiplayer + Economy | Trailer and reviews fight the craft toy |

### 3.4 What people usually meant (better substitutes)

| Desire | Weaver-native answer |
|---|---|
| Share pride | Local gallery + optional **share code / ghost Structure** (async, no inventory move) |
| Help a friend | Seed codes / same job seed — same loom, different hands |
| Long-term goals | Recipe stamps, residue bias mastery, elegant clears |
| “Living world” | Authored job reactions + material tells — not NPC price curves |
| Monetization | Upfront paid game / honest DLC packs — see monetization doc; **never** trade fees |

### 3.5 Narrow post-MVP fence (only if ever)

Revisit trade **only if all** are true:

1. Vertical slice and MVP prove the craft loop without social features.  
2. The ask is **cosmetic silhouette frames** or **share-code remix**, not Fragment/Thread items.  
3. Offline campaign remains 100% complete without network.  
4. No currency, no fees, no scarcity created for trade’s sake.  
5. Moderation / inventory security cost is explicitly budgeted.

Until then, any PR that adds stalls, wallets, or “just a simple trade window” **fails review against this doc**.

### 3.6 Explicit non-goals (economy)

| Out | Why |
|---|---|
| Auction house / player stalls | Market game |
| Soft/hard currency sinks tied to other humans | Live-service spine |
| Tradable Legacy monuments as NFT-like flex | Wrong pride; platform risk |
| Energy / login calendars | Offline-first breach |
| Gacha Fragment rarity | Banned with purple loot ladders ([`03_FRAGMENTS.md`](03_FRAGMENTS.md)) |
| Echo Lattice meta currencies bolted on | EL frozen; different product |

---

## 4. Monetization boundary (pointer)

Ship economy ≠ store economy.

| Layer | Owner |
|---|---|
| In-run scarcity | **This doc** |
| Price band / DLC fence / no MX | [`13_MONETIZATION.md`](13_MONETIZATION.md) · [`17_MVP.md`](17_MVP.md) |
| Multiplayer ambition | [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) — default none; never gates SP |

Paid game may sell **the toy**. It must not sell **win-relevant Fragment packs** that mimic a trade meta.

---

## 5. Designer checklist

Before adding any “economy” feature, answer:

1. Does it tighten **ports / budget / collapse readability**?  
2. Can a blind 60s clip still show authorship without a wallet UI?  
3. Does it work **fully offline**?  
4. Does it create value that would be **more fun to trade than to weave**? If yes → cut.  
5. Would removing other players make the feature pointless? If yes → it is not Weaver MVP.

---

## 6. Acceptance tests

| Gate | Pass |
|---|---|
| **Scarcity test** | A mastery field is hard because of graph skill, not because of missing coin |
| **Trade absence test** | Grep of MVP scope: no trade window, stall, AH, wallet |
| **Offline test** | Campaign clearable with network killed |
| **Pride test** | Players screenshot Structures, not inventories |
| **Critique test** | This §3 remains the cited authority when someone proposes “light trading” |

---

## 7. Lock line

Weaver is rich when **stitches are scarce** and poor when **markets are busy**. Player trade is declined — not deferred as inevitable — because authorship is the product.

**Superseding feel doc:** [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md) — solo-satisfying scarcity replaces trade fantasy as the economy center of gravity.
