# The Weaver — MVP Scope

**Working title:** The Weaver  
**Product stance:** North-star Steam desktop game after Echo Lattice freeze.  
**Code policy:** Do **not** delete `game/echo_lattice/`. New playable work targets a future `game/weaver/` (or rename when locked) — this doc is scope, not a migration plan.  
**Companions:** [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) · [`18_RISKS.md`](18_RISKS.md) · [`13_MONETIZATION.md`](13_MONETIZATION.md) · [`14_TECH.md`](14_TECH.md) · [`15_MARKET.md`](15_MARKET.md) (when present)

---

## 1. One-sentence MVP

> Offline craft vignette: gather a tiny set of **Fragments**, spin **Threads**, tension them into a handful of **Structures** that solve short Yard jobs — physics is the judge; no trade, no MMO, no purple time-magic.

---

## 2. Player fantasy (in) vs feature gravity (out)

| In (must feel) | Out (MVP cut) |
|---|---|
| Material → line → Structure authorship | Player-to-player marketplace |
| Readable tension / slack / snap | Full simulated town economy |
| Short job board / Yard contracts | Open-world biome tourism |
| Collapse comedy + elegant solves | Combat, stealth, dialogue RPG |
| Local save, offline-first | Always-online, seasons, battle pass |
| One visual identity (fiber, dust, hardware) | Generative “AI world” marketing |

---

## 3. Systems allowed in MVP

### 3.1 Fragments

- **Count:** 4–6 materials max at ship of vertical slice; ≤12 at 1.0 MVP.
- **Role:** Input stuff with physical character (soft / tensile / stiff / binder).
- **Ban:** Rarity rainbow, gacha boxes, “Time” / chronomancy Fragment skins.

### 3.2 Threads

- Pin, draw, tension, cut, re-pin.
- Load reading (color/thickness/sound) — no spreadsheet UI required.
- One failure language: slack, stretch, snap — fair and visible.

### 3.3 Structures

- **Catalog:** ≤8 Structure recipes in vertical slice; ≤20 in MVP 1.0.
- Each recipe: 3–8 parts, one primary job (bridge, brace, sail, bell frame, channel, shelter…).
- Blueprint + free-build lite OK; **no** Besiege-scale part encyclopedia.

### 3.4 World / jobs

- **One** hub: Shed Yard (+ optional second corner for 1.0).
- Job list: 12–20 authored contracts for slice; 40–60 for MVP 1.0.
- World answer: authored reactions, not a living MMO sim.

### 3.5 Progression / Legacy (thin)

- Unlock order: materials → joints → recipes → Yard corners.
- **Legacy at MVP:** local gallery of Structures + ghost replays — **not** server-side monuments or player housing districts.

### 3.6 Multiplayer

- **MVP default: none.**
- Optional later fence: async ghost Structures / share codes — see [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) when present.
- Never gate single-player content on multiplayer.

### 3.7 Economy

- Soft costs in materials only — **solo-satisfying scarcity** ([`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md)).
- **Critique / cut:** player trade, auction houses, currency sinks tied to other humans — fence in [`07_ECONOMY.md`](07_ECONOMY.md) §3. Those belong to a different product.

---

## 4. Content mountain (honest)

| Milestone | Playable proof | Content |
|---|---|---|
| **Vertical slice** | First thirty minutes spine complete | 1 Yard, 4 Fragments, Thread literacy, 3 Structures, 8–12 jobs |
| **Demo** | Wishlistable clip loop | Slice + polish pass + CTA; no meta dump |
| **MVP 1.0** | 3–5 hour campaign of Yard jobs + light sandbox | ≤12 Fragments, ≤20 Structures, 40–60 jobs, gallery |
| **Post-MVP** | Only after slice metrics | Second biome / async ghosts / co-op build — pick **one** |

---

## 5. Tech fence (MVP)

| Choice | MVP |
|---|---|
| Engine | Godot 4.x (repo already standardized) |
| Sim | 2D or constrained 3D tension/beam — **pick one** before art ramp; do not dual-stack |
| Online | None required |
| Mods / Workshop | Out |
| AI runtime / LLM | Out — offline authored content only |
| Platforms | Windows first; Linux nice; Deck after input parity |

---

## 6. Price & packaging (working)

- **Band:** $4.99–$9.99 (align with repo fast-ship band; finalize in market doc).
- **Demo:** free, first-thirty spine, wishlist CTA.
- **DLC fence:** post-1.0 material packs only after core jobs praised — no day-one DLC plan.

---

## 7. Relationship to Echo Lattice

| Echo Lattice | Weaver |
|---|---|
| Habit → geometry maze; Field Ledger | Fragment → Thread → Structure craft |
| Steam pack **frozen** for depth | Design north star for next product energy |
| `game/echo_lattice/` **kept** | New project path when prototype starts |
| Do not mash store pages | Pure category: craft / physics puzzle toy |

Shared taste (authorship, readable failure, clip moments) is fine. Shared mechanics on one store page is not.

---

## 8. Exit criteria — “MVP is real”

Ship-ready MVP only if **all** are true:

1. Cold player completes first Structure job in ≤24 minutes without a human coach.
2. Collapse clips are fair and shareable; wins feel elegant, not menu-solved.
3. Zero mandatory online features.
4. Art/audio identity is non-generic (no purple-void default).
5. Performance target: 60 FPS on mid-tier Windows laptop at target resolution for Yard scenes.
6. Store page can be explained in one trailer shot: hands, thread, structure, consequence.

---

## 9. Explicit non-goals (print this on the wall)

1. Do not build player trading “because legacy MMO fantasy.”
2. Do not expand the part catalog to compete with Besiege before 20 great jobs exist.
3. Do not rename Echo Lattice assets and call it Weaver.
4. Do not add a skill tree to paper over muddy verbs.
5. Do not schedule Coming Soon until the vertical slice passes §8.

---

## Doc status

**v0.1** — Honest cut list for the Weaver design wave. Sibling biz/tech docs may refine numbers; the cuts in §2 and §9 stay unless a human overrides.
