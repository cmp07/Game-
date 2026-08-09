# Weaver — Legacy v2 (Offline Structure Evolution)

**Doc:** `docs/WEAVER/28_LEGACY_V2.md`  
**Status:** Systems deepen — Structure evolution without always-online (CLOUD ONLY)  
**Product line:** Weaver  
**Branch:** `cursor/weaver-legacy-v2`  
**Supersedes / deepens:** [`08_LEGACY.md`](08_LEGACY.md) *(MVP thin residue remains law; this doc adds post-slice evolution)*  
**Peers:** [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`06_WORLD.md`](06_WORLD.md) · [`07_ECONOMY.md`](07_ECONOMY.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) · [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) · [`14_TECH.md`](14_TECH.md) · [`17_MVP.md`](17_MVP.md) · [`MASTER_GDD.md`](MASTER_GDD.md)

---

## 0. One sentence

**Legacy v2** is how stood Structures *evolve the loom across sessions* — local pedigrees, yard weathering, and residue chains — with the network cable pulled. No server monuments. No seasonal wipes. No appointment world.

```
Stand → stamp → local evolve tick → yard / next field answers your corpus
```

---

## 1. Why v2 exists (gap from 08)

[`08_LEGACY.md`](08_LEGACY.md) locks the **thin MVP**: silhouette stamp, one bias tag, optional scrap, local gallery + ghost replay. That is enough for vertical slice and demo.

Players who stay will ask: *“Does the yard ever change because of what I wove?”*  
Live-service games answer with always-online shared worlds. Weaver answers with **offline Structure evolution** — the save file is the world clock.

| Layer | `08` MVP | `28` v2 deepen |
|---|---|---|
| Unit | Stood Structure stamp | Same unit + **pedigree** (how stamps chain) |
| Bias | One tag → next field | **Residue chain** across a campaign arc |
| Gallery | Wall of stills | Wall that **weathers / rearranges** from your corpus |
| Persistence | Local save | Local save + deterministic **evolve ticks** |
| Social | Out / share later | Still offline-first; share remains opt-in codes ([`12_MULTIPLAYER.md`](12_MULTIPLAYER.md)) |

**Authority:** MVP cuts in [`17_MVP.md`](17_MVP.md) §3.5 win until slice metrics land. Schedule v2 evolution for **W4 MVP 1.0 / post-slice**, not W1 spike. Do not staff a game server to fake this fantasy.

---

## 2. Fantasy

| Layer | Promise |
|---|---|
| **Continuity** | The yard remembers *how* you weave across weeks of local play |
| **Authorship** | Old Structures leave readable scars and soft invitations — not loot power |
| **Quiet growth** | Evolution feels like cloth aging and seams teaching — not season pass ranks |
| **Fairness** | Airplane mode never softlocks; wiping Legacy never blocks campaign clears |
| **Honesty** | “Offline evolution” means local sim — never a fake online village |

**Player line:** *“The shed learned my hand — and it never needed the cloud.”*

---

## 3. Hard fence — no always-online

| Ban | Why |
|---|---|
| **Server-authoritative world state** | Ops, latency, moderation; wrong price band |
| **Login / account required to evolve** | Offline-first breach ([`14_TECH.md`](14_TECH.md)) |
| **Daily appointment ticks that punish absence** | Live-service FOMO; shame archive |
| **Shared monuments other players edit** | MMO gravity; trade/flex surface ([`07_ECONOMY.md`](07_ECONOMY.md)) |
| **Seasonal wipe of Legacy** | Deletes authorship pride for retention theater |
| **Power Legacy from evolution** | Permanent damage/HP/meta buffs from old Structures |
| **Tradable evolved stamps** | Gallery becomes AH inventory |

**Acceptance bar:** Full campaign + Legacy evolution must complete with Steam disabled and network killed ([`MASTER_GDD.md`](MASTER_GDD.md) pillar 5).

Steam Cloud *optional sync of the local save* (post-1.0) is **not** always-online evolution — it is backup. Evolution logic must run identically with Cloud off.

---

## 4. Evolution unit & pedigree

The unit remains a **stood Structure** ([`05_STRUCTURES.md`](05_STRUCTURES.md), [`08_LEGACY.md`](08_LEGACY.md) §2). Loose Fragments and chalk plans still do not evolve.

### 4.1 Pedigree record (local)

On clear, when a Structure stood and was inhabited, write a compact pedigree entry:

| Field | Meaning |
|---|---|
| **silhouette_id** | Compact outline / archetype hash for gallery |
| **bias_tag** | Primary craft tag (`scaffold`, `pulse`, `culvert`, `kiln`, `span`, `vent`, …) |
| **channel** | Primary rewrite channel (topology / flow / load / pulse / vent) |
| **seed_link** | Job / field / seed that produced it |
| **elegance** | Optional Thread-count / stress-peak vector (stars, not market rank) |
| **parent_refs** | Up to N prior silhouette_ids that biased this clear (chain) |
| **session_tick** | Monotonic local counter — **not** UTC server day |
| **weather_flags** | Soft yard answers earned (see §6) |

Cap pedigree rows (e.g. 50–100) with pin + LRU for unpinned — same soft-cap spirit as [`08_LEGACY.md`](08_LEGACY.md) §8.

### 4.2 What “evolve” means (three verbs only)

Keep the vocabulary tight so implementation stays honest:

| Verb | Player feels | System |
|---|---|---|
| **Chain** | “This field answered my last kiln” | Residue bias accumulates along `parent_refs` |
| **Weather** | “The yard wall shifted toward my spans” | Hub cosmetics + job-board ordering soft-bias |
| **Scar** | “That gap still remembers a fallen scaffold” | Optional authored field variants unlocked by tags |

No fourth verb called “sync,” “season,” or “claim plot.”

---

## 5. Residue chains (cross-field evolution)

### 5.1 Chain rules

1. Each clear emits **one primary bias tag** (MVP rule preserved).  
2. v2 may keep a short **rolling window** of tags (e.g. last 3–5 clears) as a *hand signature*.  
3. The next authored field may read the window to pick among **pre-authored** teach variants — never generative online content.  
4. Chains are **pedagogy**, not RNG loot tables. Caps: scrap still rare; never required for campaign completion.  
5. Abandon / fail does **not** write shame pedigree; optional private fail chalk stays local and off by default.

### 5.2 Hand signature (examples)

| Rolling tags | Field answer (authored) |
|---|---|
| scaffold-heavy | Longer gap *or* over-brace punish variant |
| pulse / gate | Beat-literacy job *or* Echo-starve job |
| culvert ×2 | Spill with tighter Filter ports |
| kiln → vent | Seal that needs clean Oppose path |
| mixed elegant clears | Optional praise stamp; still not currency |

Determinism: same save pedigree + same next job seed → same variant pick.

---

## 6. Yard weathering (hub evolution)

The Shed Yard ([`06_WORLD.md`](06_WORLD.md)) may quietly reflect the corpus — offline, cosmetic-forward, literacy-second.

| Weathering | Allowed | Forbidden |
|---|---|---|
| Gallery wall layout | Re-sort by archetype, pin shelves, dust on old panels | Likes, friends feed, housing plots |
| Shed props | Cloth scraps / chalk marks matching dominant bias | NPC market stalls, tradable décor SKUs |
| Job board order | Soft-suggest next literacy from hand signature | Locked online dailies; FOMO timers |
| Light / dust | Material identity tells (fiber, kiln copper) | Purple “prestige glow,” season chrome |

Weathering must remain **readable offline after months away**. Absence never decays power — at most dust settles (pride patina), never punishment.

---

## 7. Structure scars (field memory)

Optional 1.0+ deepen for authored fields:

| Scar type | Effect | Fence |
|---|---|---|
| **Topology scar** | A prior Span clear unlocks an alternate approach ledge on a remix job | Pre-authored geometry only |
| **Flow scar** | Culvert mastery enables a harder spill teach | Never a permanent HP buff |
| **Load scar** | Scaffold pedigree allows a longer second-Structure teach sooner | Still Thread-budget honest |
| **Ghost scar** | Local ghost of *your* prior graph as chalk — pedagogy | No rival download required |

Scars are **literacy doors**, not power creep. Removing all Legacy data must leave the base campaign solvable ([`08_LEGACY.md`](08_LEGACY.md) power test preserved).

---

## 8. Evolve ticks (when the loom updates)

Evolution runs on **local events**, never on a remote schedule:

| Tick trigger | What may update |
|---|---|
| Field clear (Structure stood) | Pedigree write, bias window, gallery stamp |
| Return to Shed Yard | Weathering pass from current corpus |
| Campaign panel advance | Optional scar unlock checks |
| Manual gallery pin / unpin | Shelf layout only |
| Share-code import (opt-in, later) | *Ghost compare only* — never inventory merge |

**Not triggers:** UTC midnight, Steam login, “season start,” push notification, other players’ clears.

Wall-clock may tint dust cosmetics if desired; it must **never** gate jobs, Fragments, or clears.

---

## 9. Save / schema (implementation-facing)

Extends [`08_LEGACY.md`](08_LEGACY.md) §8 and [`14_TECH.md`](14_TECH.md) offline save:

| Contract | Spec |
|---|---|
| **Offline-first** | All v2 evolution state in local user data |
| **Schema** | Versioned (`legacy_v2`); deep-merge missing keys; never crash on `08`-only saves |
| **Migration** | `08` gallery stamps → pedigree rows with empty `parent_refs` |
| **Determinism** | Variant picks = f(pedigree, job seed, content table) — no hidden rolls |
| **Cap** | Soft cap pedigree + pinned set; LRU unpinned |
| **Privacy** | No silent upload; share codes player-initiated |
| **Atomic write** | Temp file + rename; corrupt save → recover last good + empty evolve window |
| **Cloud save** | Optional Steam Cloud mirrors the same blob; logic must not require it |

Suggested module home (greenfield): `game/weaver/scripts/meta/legacy_evolve.gd` (+ Python contract tests for variant pick tables).

---

## 10. Relationship to social residue

| Feature | Owner | Online? |
|---|---|---|
| Local ghost replay | This doc + `08` | Never |
| Daily shared seed | [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) | Seed string only |
| Friend paste / compare stills | `12` | Manual, offline |
| Async rival ghost download | `12` post ladder | Optional CDN — **not required for evolution** |
| Evolved yard / scars / chains | **This doc** | **Never** |

Evolution must feel complete if the player never shares a code. Social features decorate Legacy; they do not *drive* it.

---

## 11. Content & schedule fences

| Milestone | Legacy depth |
|---|---|
| **W1 spike** | None (loop only) |
| **W2 vertical slice** | `08` thin: one stamp + one bias + gallery stub OK |
| **W3 demo** | Gallery pride readable; no evolve meta dump |
| **W4 MVP 1.0** | Pedigree + residue chains + light yard weathering |
| **Post-MVP** | Scars + richer shelves; still no server world |

Do not let this doc pull netcode onto the roadmap ([`18_RISKS.md`](18_RISKS.md) P3 / D4).

---

## 12. Acceptance tests

| Gate | Pass |
|---|---|
| **Airplane test** | Campaign + gallery + evolve ticks with network off |
| **Absence test** | Leave save untouched 30+ days (simulated clock): no softlock, no forced wipe, jobs still clearable |
| **Chain test** | After three linked clears, player can name how the third answered the first two |
| **Weather test** | Mute Yard screenshot differs recognizably after a scaffold-heavy corpus vs kiln-heavy corpus |
| **Power test** | Delete pedigree / scraps → campaign still completable |
| **Trade test** | No evolved Legacy object appears in any trade UI (none should exist) |
| **Cloud-off test** | Steam disabled: identical evolve behavior |
| **Migration test** | Old `08` save opens; gallery intact; v2 fields default safely |

---

## 13. Non-goals

| Out | Why |
|---|---|
| Always-online shared Structure world | Different product |
| Player housing districts / plot claims | Wrong session shape |
| NFT / blockchain provenance | Reject |
| Battle-pass Legacy tracks | Live-service |
| Cross-save mash with Echo Lattice | Separate SKUs ([`PIVOT.md`](PIVOT.md)) |
| LLM “world evolves for you” runtime | Banned AI-dungeon lead |
| Server-side anti-cheat for gallery stars | Cosmetic local pride only |

---

## 14. Conflict resolution

| Clash | Winner |
|---|---|
| This doc fantasizes server monuments | [`08_LEGACY.md`](08_LEGACY.md) + [`17_MVP.md`](17_MVP.md) — local only |
| This doc schedules evolve in W1 | [`ROADMAP.md`](ROADMAP.md) — spike is loop-only |
| Share / ghosts need CDN | [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) — optional post; evolution stays local |
| Evolved scraps become trade goods | [`07_ECONOMY.md`](07_ECONOMY.md) §3 — ban |
| `01_CONCEPT` maze-legacy wording | MASTER / systems vocabulary wins |

---

## 15. Lock line

Legacy v2 is **offline Structure evolution** — pedigrees, residue chains, and yard weathering that answer your hand across local sessions. The loom may remember you for years without ever phoning home. If it needs a server to grow, it is not Weaver Legacy.
