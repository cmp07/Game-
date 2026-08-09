# The Weaver — Product identity & rename strategy

**Status:** Shipping identity lock — **The Weaver** is the product we ship; Echo Lattice is not a forever side project.  
**Authority peers:** [`PIVOT.md`](PIVOT.md) (product-line) · [`MASTER_GDD.md`](MASTER_GDD.md) (design) · [`19_NAMES.md`](19_NAMES.md) (title shortlist) · [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) (EL Steam freeze)  
**Mode:** Cloud-only durable docs. **No AppID invention. No Partner paste mutation in this PR.**

| Field | Value |
|---|---|
| **Identity date** | 2026-08-09 |
| **RC1 tip at identity lock** | `a1f49a3b613dff4565cd7ba309f463c883df4707` |
| **Identity branch** | `cursor/weaver-identity` |
| **Integration line** | `cursor/echo-lattice-rc1` |
| **Playable root (new)** | `game/weaver/` |
| **Echo Lattice live path (today)** | `game/echo_lattice/` |
| **Echo Lattice archive path (later)** | `game/_archive/echo_lattice/` |

---

## 0. Decision (read this first)

| Lock | Meaning |
|---|---|
| **Ship as The Weaver** | Store, trailer, capsules, and build branding default to **The Weaver** (or a locked successor from [`19_NAMES.md`](19_NAMES.md) after human legal check). |
| **Not a side project** | Weaver is the **shipping north star**, not an eternal research lane beside Echo Lattice 1.0. |
| **Echo Lattice → archive** | Echo Lattice remains a **frozen** vertical slice + Steam pack record. Code may later move under `game/_archive/echo_lattice/` — **not** deleted, **not** overwritten as Weaver. |
| **New playable root** | All new Godot work lands in `game/weaver/`. Do not grow features inside `game/echo_lattice/` “until we rename.” |
| **Steam rename is planned** | Existing Echo Lattice Partner / Coming Soon surface (if any) is **renamed or retired** per the plan below — not silently dual-branded forever. |

**One line:** We ship **The Weaver**; Echo Lattice becomes an in-repo archive path and freeze record, not the forever product name.

---

## 1. Rename strategy (product → The Weaver)

### 1.1 What “rename” means

| Layer | Policy |
|---|---|
| **Product name** | Public product is **The Weaver** (working title until [`19_NAMES.md`](19_NAMES.md) locks). |
| **Fantasy / systems** | Fragment → Thread → Structure yard craft per [`MASTER_GDD.md`](MASTER_GDD.md) — **not** habit→geometry Field Ledger copy. |
| **Code tree** | Greenfield `game/weaver/`; Echo Lattice stays readable under `game/echo_lattice/` until an archive move. |
| **Docs** | Live design under `docs/WEAVER/`; EL vision / RELEASE / AUDIT remain historical. |
| **Steam** | One public page story: Weaver. Do not keep “Echo Lattice” as the forever store title while shipping Weaver content. |

### 1.2 What rename is *not*

- Not “open `game/echo_lattice/` and search-replace Echo Lattice → Weaver.”  
- Not inventing AppIDs, depot IDs, or claiming Partner uploads from cloud agents.  
- Not mashing frozen EL store paste into Weaver capsules without a dedicated rewrite.  
- Not deleting RELEASE / AUDIT / BACKUP freeze artifacts.  
- Not dual-SKU forever (“EL on Steam + Weaver as side demo”) unless a human explicitly reopens that plan.

### 1.3 Internal vs store title

| Surface | Until name lock | After human lock |
|---|---|---|
| Docs / branches / `game/weaver/` | **The Weaver** | Locked store title |
| Steam page title / capsules | Blocked on vertical-slice exit + legal check | Locked title only |
| Echo Lattice freeze docs | Keep historical name **Echo Lattice** | Still historical — do not rewrite freeze as if EL never existed |

---

## 2. Echo Lattice archive path

### 2.1 Today (pre-archive move)

| Path | Role |
|---|---|
| `game/echo_lattice/` | Frozen playable — **kept in place** until an explicit archive PR |
| `docs/ECHO_LATTICE/` · `docs/VISION/` · `docs/RELEASE/` · `docs/AUDIT/` | Historical + freeze archaeology |
| `steam/echo_lattice/` | Frozen Partner scaffolding |
| `backup/echo-lattice-rc1-steam-pack` | Durable branch + tag — see freeze doc |

### 2.2 Later (allowed archive move)

When a human/agent lands an **archive migration PR** (separate from this identity lock):

| From | To | Rules |
|---|---|---|
| `game/echo_lattice/` | `game/_archive/echo_lattice/` | **Move** (git history preserved). Update CI / path indexes / BACKUP pointers in the same PR. |
| Freeze docs / Steam pack paths | Stay unless paths break | Do **not** delete; rewrite links only. |
| `steam/echo_lattice/` | Optional later `steam/_archive/echo_lattice/` | Only with Partner checklist; no AppID invention. |

**Hard rules for the archive move:**

1. **No wipe** — refuse delete-only PRs against the EL tree.  
2. **No in-place rebrand** — do not rename the folder to `game/weaver/` or overwrite EL scenes as Weaver.  
3. **Weaver already exists beside it** — `game/weaver/` is created as the playable root *before or with* the archive move, never by overwriting EL.  
4. **Cite this doc + [`PIVOT.md`](PIVOT.md)** in the archive PR body.

### 2.3 Borrow policy after archive

Weaver may copy **patterns** (determinism, fail-closed Steam, Python contracts, ceremony scarcity). It must not ship EL chamber UI, habit archetypes, or frozen store sentences as Weaver.

---

## 3. Playable root — `game/weaver/`

| Lock | Meaning |
|---|---|
| **Canonical path** | `game/weaver/` is the only new playable Godot root for this product. |
| **Bootstrap** | `project.godot` + content/scripts per [`14_TECH.md`](14_TECH.md); throwaway spike allowed per [`ROADMAP.md`](ROADMAP.md) W1. |
| **CI** | Point Weaver jobs at `game/weaver/` when the project exists; keep EL archive jobs read-only / historical. |
| **Naming** | Folder stays `weaver` even if store title later changes (update display strings, not path thrash). |

---

## 4. Steam page rename plan

**Goal:** Public Steam presence matches **The Weaver**, without inventing AppIDs or mutating Partner from this docs PR.

### Phase A — Docs & freeze (now)

| Step | Owner | Done when |
|---|---|---|
| Identity + pivot lock land on RC1 | Cloud docs PR | This file + strengthened [`PIVOT.md`](PIVOT.md) merged |
| EL Steam pack remains frozen | Human / freeze policy | [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) still authoritative for EL archaeology |
| Weaver Coming Soon **blocked** | Design | Vertical slice passes MVP exit criteria ([`MASTER_GDD.md`](MASTER_GDD.md) §8 / [`17_MVP.md`](17_MVP.md)) |

### Phase B — Title lock (human)

| Step | Owner | Done when |
|---|---|---|
| Legal / Steam search on **The Weaver** or Tier A alt | Human | [`19_NAMES.md`](19_NAMES.md) §7 checklist green |
| Store sentence rewrite for Yard craft (not EL maze) | Human + docs | Align [`15_MARKET.md`](15_MARKET.md) to MASTER fantasy |
| Capsule / trailer brief for Weaver only | Human | No “Echo Lattice” wordmark on Weaver art |

### Phase C — Partner surface (human, AppID-aware)

Pick **one** path; do not run both forever:

| Option | When to use | Actions |
|---|---|---|
| **C1 — Rename existing app** | An Echo Lattice app already exists in Partner and wishlists/page equity should transfer | Rename app title → locked Weaver title; replace library capsule, header, screenshots, short/long description; retire EL habit/maze copy; keep freeze docs as history |
| **C2 — New Weaver app + retire EL** | Cleaner identity, or EL page never published / zero equity | Create Weaver app (human AppID); unpublish or mark EL page historical / never ship; do not claim EL wishlists as Weaver without honesty |

**Cloud agents:** document the choice; **do not** invent AppIDs, upload builds, or paste Partner legal packs as “done.”

### Phase D — In-repo Steam scaffolding

| Path | Policy |
|---|---|
| `steam/echo_lattice/` | Remains freeze archaeology until archive or Weaver pack lands |
| Future `steam/weaver/` (or successor) | New store pack only — capsules, copy, achievement seeds for Weaver |
| RELEASE / AUDIT EL trees | Keep; label as Echo Lattice history when linking from Weaver hubs |

### Phase E — Communication

| Audience | Message |
|---|---|
| Wishlist / page visitors (if C1) | Short, honest rename note: product continues as **The Weaver** (craft / tension toy); Echo Lattice name retired |
| Internal / agents | Cite this file; stop opening EL feature PRs as the shipping line |
| Press kit | Weaver-only once Phase B art exists; EL media stays under freeze paths |

---

## 5. Agent / PR checklist

| Do | Do not |
|---|---|
| Land Weaver playable work under `game/weaver/` | Feature-wave `game/echo_lattice/` toward EL 1.0 |
| Plan archive moves to `game/_archive/echo_lattice/` with link fixes | Delete EL tree or freeze backups |
| Rewrite store copy for Weaver fantasy before Partner paste | Mash frozen EL store sentences into Weaver |
| Link this file from pivot / README when identity questions arise | Claim Steam rename or AppID assignment from cloud |
| Keep **The Weaver** until [`19_NAMES.md`](19_NAMES.md) locks | Ship as “Echo Weaver” / “Lattice Weaver” mash |

---

## 6. Related entry points

| Doc | Role |
|---|---|
| **This file** | Shipping identity · archive path · Steam rename plan |
| [`PIVOT.md`](PIVOT.md) | Product-line lock (strengthened archive + `game/weaver/` root) |
| [`MASTER_GDD.md`](MASTER_GDD.md) | Design synthesis |
| [`19_NAMES.md`](19_NAMES.md) | Title shortlist + legal gate |
| [`15_MARKET.md`](15_MARKET.md) | Shelf / discovery (align store sentence to MASTER) |
| [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) | Frozen EL Steam pack |

---

## Doc status

**v1.0** — Identity lock: ship as The Weaver; EL archive path reserved; Steam rename phased. No Partner mutation in this revision.
