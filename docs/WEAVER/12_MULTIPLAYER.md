# The Weaver — Multiplayer

**Doc:** `docs/WEAVER/12_MULTIPLAYER.md`  
**Status:** Honest MVP cut — social surface only  
**Peers:** [`01_CONCEPT.md`](01_CONCEPT.md) · [`PIVOT.md`](PIVOT.md) · [`14_TECH.md`](14_TECH.md) · [`17_MVP.md`](17_MVP.md)  
**Post-1.0 reopen:** [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) — co-op only; seamless competitive killed

---

## 0. Verdict (read this first)

| Lock | Meaning |
|---|---|
| **MVP ships singleplayer-only** | No realtime co-op, PvP, lobbies, chat, or dedicated servers at 1.0 |
| **“Multiplayer” = social residue** | Seeds, ghosts, and compare-weaves — offline-first, optional Steam when present |
| **Netcode is a post-1.0 maybe** | Do not staff or schedule realtime MP until the solo loom is undeniable |

**One line:** The Weaver’s loom remembers *you*; it does not need another player in the room to ship.

---

## 1. Why realtime MP is cut for MVP

| Temptation | Honest cost | Cut reason |
|---|---|---|
| Co-op loom (two walkers, one cloth) | Sync, host migration, softlock doubles, tutorial rewrite | Fantasy is authorship of *your* habits — a second walker dilutes the mirror |
| Asynchronous “invade” / rival weaves live | Matchmaking, moderation, always-online expectation | Live-service ops for a $5–$10 puzzle — wrong band |
| Leaderboards as primary retention | Cheat surface, Steamworks dependency, review bombs on reset | Stars / Museum already retain offline |
| Voice / text chat | Moderation, ratings, ToS | Zero upside for a quiet craft fantasy |

Repo hard rule ([`../GAME_PLAN.md`](../GAME_PLAN.md)): **no multiplayer netcode for v1.** Weaver inherits that cut.

---

## 2. MVP social surface (ship this, call it enough)

These are **not** multiplayer modes. They are shareable singleplayer artifacts.

| Feature | MVP? | Notes |
|---|---|---|
| **Daily shared seed** | **Yes** | Same loom, different hands — already the Concept north-star line |
| **Seed string copy/paste** | **Yes** | Offline: clipboard / file; optional Steam overlay paste |
| **Ghost self replay** | **Yes (local)** | Your prior weave as chalk/thread ghost — no network |
| **Friend seed handoff** | **Yes (manual)** | Discord/Steam chat paste; no in-game friends UI required |
| **Compare-weave stills** | Soft yes | Screenshot / Museum export; no server gallery |
| Steam Remote Play Together | **Passive** | Works without Weaver netcode; do not advertise as a feature pillar |
| Steam Leaderboards | **No for MVP** | Revisit only if dailies need a thin optional board *after* feel locks |
| Realtime co-op / PvP | **No** | Post-1.0 research only |
| Dedicated servers / relay | **No** | Never for this price band unless product identity changes |

### MVP acceptance tests

1. A player can finish Campaign + Daily with **airplane mode** on.  
2. Two friends can play the **same daily seed** the same UTC day without any Weaver backend.  
3. Store page does **not** list Online Co-op, MMO, or always-online.

---

## 3. Post-MVP ladder (only if solo lands)

Ordered by honesty of effort vs fantasy fit — not a commitment:

| Tier | Idea | Gate before building |
|---|---|---|
| A | Steam leaderboard for daily stars (opt-in) | 1.0 shipped; anti-cheat not required if scores are cosmetic |
| B | Workshop / shared seed browser | Moderation plan + AppID; still no realtime |
| C | Async “ghost rival” download | **Killed** as opposition — see [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md); self/friend ghosts only |
| D | 2P hotseat / same-machine pass | Preferred co-op fantasy spike before online |
| E | Online co-op loom | Only realtime reopen — [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md); never seamless competitive |

**Do not** skip to online co-op because a trailer “would look cool with two cursors.” Competitive invade / rival-in-yard stays dead.

---

## 4. What we refuse to fake

| Anti-pattern | Why it dies |
|---|---|
| “Online features coming soon” on the store at Early Access / 1.0 | Trains distrust; Concept forbids live-service FOMO |
| Stub multiplayer menus in the shipping build | Reviewers click them; support debt |
| Friendslop pitch (“play with your friends!”) as lead marketing | Wrong shelf — Weaver is quiet authorship puzzle |
| Reusing Echo Lattice Steam pack categories without audit | EL freeze pack is offline-only; copy that honesty |

---

## 5. Relationship to Echo Lattice

Echo Lattice already proved **offline Campaign / Daily / Endless** and ghost-path pedagogy. Weaver’s social MVP should **steal that lesson**, not the store identity:

- Keep: deterministic seeds, local ghosts, no chat.  
- Drop: any implication that wishlist or achievement catalogs transfer.  
- New Steam product = new AppID when humans create it — see [`14_TECH.md`](14_TECH.md).

---

## 6. Lock line

**MVP multiplayer = none.** Social proof is a shared seed and a cloth you can show — not a server you must rent.
