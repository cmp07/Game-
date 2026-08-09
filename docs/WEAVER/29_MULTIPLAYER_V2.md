# The Weaver — Multiplayer V2 (post-1.0 co-op fence)

**Doc:** `docs/WEAVER/29_MULTIPLAYER_V2.md`  
**Status:** Post-1.0 research fence — **not** MVP scope  
**Supersedes for post-ship MP:** ladder tiers D–E in [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md)  
**Does not reopen:** MVP singleplayer lock in [`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) · [`17_MVP.md`](17_MVP.md) · [`MASTER_GDD.md`](MASTER_GDD.md)  
**Peers:** [`14_TECH.md`](14_TECH.md) · [`15_MARKET.md`](15_MARKET.md) · [`ROADMAP.md`](ROADMAP.md) · [`07_ECONOMY.md`](07_ECONOMY.md)

---

## 0. Verdict (read this first)

| Lock | Meaning |
|---|---|
| **MVP = still zero realtime MP** | No lobbies, sync, chat, servers, or online tags at 1.0 |
| **Seamless competitive = killed** | No invade / rival-in-your-yard / PvP race / grief overlays — not for MVP, not as a “thin” post hook |
| **Post-1.0 realtime path = co-op only** | If humans reopen netcode after G7, the only allowed shape is **optional shared loom co-op** |
| **Competitive stays a different product** | Ranked boards-as-combat, sabotage weaves, and friendslop PvP are out of Weaver’s shelf |

**One line:** Ship a quiet solo loom first; if friends ever sit the same cloth, they **build with** each other — never against, and never by surprise.

---

## 1. Why this doc exists

[`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) correctly cut all realtime MP for MVP and left a vague post ladder (leaderboards → Workshop → ghost rival → hotseat → co-op). That ladder still smuggled **competitive** shapes (rival ghosts, invade fantasy) next to co-op.

V2 collapses the post-1.0 story to one honest bet:

1. **MVP / 1.0:** social residue only (seeds, local ghosts, manual share) — unchanged.  
2. **Post-1.0 (optional):** one co-op loom mode — or nothing.  
3. **Never:** seamless competitive injection into the solo Yard.

---

## 2. Kill list — seamless competitive (MVP and beyond)

“Seamless competitive” means any design where another human’s presence (live or async) **enters your session as opposition** without an explicit, separate mode select.

| Temptation | Why it dies | If someone asks again |
|---|---|---|
| Live invade / rival walker in your field | Softlocks, grief, moderation, always-online pressure | Different SKU |
| Async “enemy ghost” that races or sabotages | Encodes PvP in a craft toy; confuses Museum pedagogy | Keep **self** ghosts only |
| Drop-in matchmaking into Campaign / Daily | Trains always-online expectation; review bombs on disconnect | Invite-only co-op later, never drop-in |
| Ranked daily as primary retention | Cheat surface; category mush with Online Competitive | Cosmetic opt-in board only (tier A in `12`) — not “PvP” |
| Structure grief / cut-their-threads | Combat juice; Concept forbids conquest fantasy | Out |
| Voice proximity / toxic chat as “social” | Moderation cost for a quiet craft fantasy | Out |
| Stub “Versus” / “Invade” menus in 1.0 build | Reviewers click; support debt (`12` §4) | Out |

### MVP acceptance (competitive kill)

1. No UI string, Steam tag, or trailer beat implies PvP, invade, or rival sabotage.  
2. Ghost systems remain **your** prior weaves (or friend seed handoff you chose) — never hostile strangers.  
3. Airplane-mode Campaign + Daily still pass ([`12_MULTIPLAYER.md`](12_MULTIPLAYER.md) §2).  
4. Store tags stay Singleplayer / Puzzle — **not** Online Competitive, PvP, or MMO.

---

## 3. Post-1.0 co-op only (the allowed reopen)

### 3.1 Gate before any netcode staff

All must be true:

| # | Gate |
|---|---|
| G7 | MVP 1.0 shipped; [`17_MVP.md`](17_MVP.md) §8 exit criteria held in the wild |
| Solo praise | Players cite authorship / tension feel — not “needs friends” |
| Human reopen | Explicit product decision — not a trailer whim |
| Budget | Separate design + QA budget; not stolen from job content |

Until then: **do not** scaffold Multiplayer menus, lobby scenes, or Steam networking calls in `game/weaver/`.

### 3.2 Fantasy fit (co-op that is still Weaver)

Co-op is allowed only if it preserves **shared authorship**, not parallel shooters on one map.

| Role pattern | Allowed? | Notes |
|---|---|---|
| **Two hands, one cloth** — both may pin / tension; one shared graph | **Yes (primary)** | Deterministic sim host; clear “who holds the pin” rules |
| **Split literacy** — one recovers Fragments, one tensions Threads | Soft yes | Needs a *second role* that isn’t “also walk” (`12` tier D lesson) |
| **Hotseat / Remote Play** — same machine or Steam Remote Play | Prefer first | Zero Weaver netcode; validate fantasy before online |
| Same job, separate Structures, score race | **No** | Competitive — killed |
| Shared yard, private inventories, trade | **No** | Economy doc forbids player trade |

**Target party size:** 2 (hard cap for first co-op ship). 3+ is a different product.

### 3.3 Session shape (when built)

| Surface | Rule |
|---|---|
| Entry | Explicit **Co-op Loom** mode from menu — never silently joins Campaign |
| Invite | Friend invite / lobby code only — no public matchmaking for v1 co-op |
| Host | Listen-server or Steam P2P; **no dedicated Weaver fleet** for this price band |
| Save | Host save authoritative; guest can leave without bricking host campaign |
| Chat | Text pings / ready checks only — no free text required |
| Offline | Solo Campaign remains complete without co-op installed or online |

### 3.4 Tech fence (post-1.0 only)

Align with [`14_TECH.md`](14_TECH.md); reopen only the rows below:

| Choice | Post-1.0 co-op stance |
|---|---|
| Transport | Steam Networking / Godot multiplayer API — fail closed if Steam missing |
| Sim | Host-authoritative tension solver; guests send intents (pin, cut, tension) |
| Determinism | Shared seed + ordered intent log; desync → soft reset to last seat, not silent drift |
| Servers | **Still no** rented shard fleet / MMO relay |
| Cross-play | Out until Steam PC co-op is boring-reliable |
| Anti-cheat | Not required if no ranked competitive stakes |

### 3.5 Content that may be co-op

| Content | Co-op? |
|---|---|
| Authored co-op Yard jobs (few, designed for two roles) | Yes — after solo job mountain is praised |
| Entire Campaign forced co-op | **No** |
| Daily seed as optional co-op sit | Soft yes — same seed, shared cloth; no ranked PvP |
| Trade / stalls / player housing districts | **No** ([`07_ECONOMY.md`](07_ECONOMY.md)) |

---

## 4. Relationship to `12_MULTIPLAYER` ladder

| Old tier (`12` §3) | V2 verdict |
|---|---|
| A — Opt-in daily stars board | Still OK post-1.0; cosmetic; **not** competitive MP |
| B — Workshop / seed browser | Still OK; still not realtime |
| C — Async “ghost rival” download | **Killed** as rival/opposition; self/friend ghosts only |
| D — 2P hotseat | Preferred **prototype** for co-op fantasy before online |
| E — Online co-op loom | **Only** realtime reopen path — this doc |

Social MVP residue in `12` §2 remains law for 1.0.

---

## 5. Market & store honesty

| Do | Do not |
|---|---|
| Ship 1.0 as Singleplayer craft toy | Promise “Online Co-Op Coming Soon” on the 1.0 page |
| If co-op ships later, add tags only then | Lead wishlist trailer with two-cursor friendslop |
| Price band stays premium paid ([`13_MONETIZATION.md`](13_MONETIZATION.md)) | Use co-op as live-ops / battle-pass excuse |
| Keep Remote Play as passive Steam feature | Advertise Remote Play as Weaver netcode |

Anti-audience reminder ([`15_MARKET.md`](15_MARKET.md)): do not chase friendslop seekers as the primary buyer.

---

## 6. Explicit non-goals (print this)

1. Do not staff seamless competitive for MVP “because Dark Souls invasions are cool.”  
2. Do not implement lobby chrome before G7 + human reopen.  
3. Do not gate Fragments, jobs, or endings on owning a friend.  
4. Do not merge player trade into co-op “for something to do.”  
5. Do not delete or weaken airplane-mode solo to make netcode look necessary.  
6. Do not edit `game/echo_lattice/` to prototype Weaver co-op.

---

## 7. Agent / PR integration policy

| Do | Do not |
|---|---|
| Link this doc when proposing any Weaver netcode | Schedule co-op inside W1–W4 slice milestones ([`ROADMAP.md`](ROADMAP.md)) |
| Keep `12` as MVP social authority | Treat rival ghosts or invade as “easy MP” |
| Prefer hotseat / Remote Play spikes first | Open dedicated servers “just in case” |
| Open post-1.0 co-op as its own milestone PR | Slip Versus menus into demo builds |

---

## 8. Lock line

**MVP kills seamless competitive.** Post-1.0 multiplayer, if ever, is **optional invite-only co-op on one shared cloth** — never invade, never ranked PvP, never a server you must rent to finish the Yard.
