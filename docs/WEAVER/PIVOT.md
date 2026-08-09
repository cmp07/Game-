# Weaver pivot — durable north star

**Status:** Echo Lattice product line is **frozen**. **The Weaver** is the active shipping north star — **not** a forever side project.  
**Hard rule:** Do **not** delete Echo Lattice. Keep the tree (today under `game/echo_lattice/`; later may move to `game/_archive/echo_lattice/`) and its docs / Steam pack freeze as durable reference.  
**Mode:** Cloud-only durable docs. No AppID invention. No genre mash into Weaver from abandoned pitches.  
**Identity companion:** [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) — rename strategy, archive path, Steam page rename plan.

| Field | Value |
|---|---|
| **Pivot date** | 2026-08-09 |
| **RC1 tip at pivot** | `a1f49a3b613dff4565cd7ba309f463c883df4707` |
| **Integration line (docs land here)** | `cursor/echo-lattice-rc1` |
| **Pivot branch** | `cursor/weaver-pivot` |
| **Identity branch** | `cursor/weaver-identity` |
| **Echo Lattice tree (today)** | `game/echo_lattice/` — **kept** |
| **Echo Lattice archive (later, allowed)** | `game/_archive/echo_lattice/` — **move, do not delete** |
| **Weaver playable root** | `game/weaver/` — **canonical new code home** |
| **Steam pack freeze** | [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |

---

## 1. Decision (read this first)

| Lock | Meaning |
|---|---|
| **Echo Lattice is frozen** | Stop treating Echo Lattice as the shipping north star. No new feature waves aimed at Echo Lattice 1.0 unless explicitly reopened. |
| **The Weaver is the shipping product** | New product vision, design, prototype, Steam planning, and public name default to **The Weaver**. This is the line we ship — not an eternal research side lane beside EL. |
| **Keep the tree (archive-capable)** | Do not wipe EL. Today it stays at `game/echo_lattice/`. A later PR **may** relocate it to `game/_archive/echo_lattice/` with path/CI/BACKUP link updates. Do not strip Steam / RELEASE / AUDIT / BACKUP freeze artifacts. |
| **Playable root is `game/weaver/`** | All new Godot playable work targets `game/weaver/`. Do **not** overwrite `game/echo_lattice/` or rename that folder into Weaver. |
| **Reuse is optional** | Weaver may borrow engines, tooling, or craft lessons from Echo Lattice, but store copy and fantasy follow Weaver identity ([`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md)) — not a silent mash of frozen EL Partner paste. |
| **Steam rename is planned** | Public page story becomes Weaver per [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) §4 (human Partner steps; no AppID invention here). |

**One line:** Echo Lattice freezes into an archive path; **The Weaver** is what we ship from `game/weaver/`.

---

## 2. What stays (Echo Lattice)

Do **not** delete these. They are the resume / archaeology surface if craft lessons or freeze evidence are needed:

| Area | Path / ref |
|---|---|
| Godot project (today) | `game/echo_lattice/` |
| Godot project (later archive) | `game/_archive/echo_lattice/` — **allowed move**; same contents, new home |
| Product docs | `docs/ECHO_LATTICE/` · [`../ECHO_LATTICE_META.md`](../ECHO_LATTICE_META.md) |
| Vision corpus (historical for EL) | `docs/VISION/` |
| Steam / RELEASE / AUDIT pack | `docs/RELEASE/` · `docs/AUDIT/` · `steam/echo_lattice/` |
| Durable Steam freeze | branch + tag `backup/echo-lattice-rc1-steam-pack` — see [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |
| Python contracts | `game/echo_lattice/tests/test_*.py` (paths update if archived) |

Frozen means **no deletion and no Partner invention**, not “empty the folder.” Agents must refuse wipe requests against this tree unless a human explicitly supersedes this pivot in a later docs PR.

**Archive move (strengthened):** Relocating `game/echo_lattice/` → `game/_archive/echo_lattice/` is an **allowed** follow-on when `game/weaver/` is the live playable root. The move PR must preserve history, update indexes, and cite this file + [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md). Renaming EL in place to “weaver” remains **forbidden**.

---

## 3. What moves (Weaver)

| Area | Policy |
|---|---|
| **North star docs** | Live under `docs/WEAVER/` — this file is the pivot lock; [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) is the rename / Steam plan; design siblings stay here as Weaver matures |
| **Prototype / game code** | **Canonical root:** `game/weaver/`. Do not overwrite `game/echo_lattice/`. Optional later: archive EL under `game/_archive/echo_lattice/` |
| **Steam / store work** | Rename or retire the EL public page toward Weaver per [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) §4; new Coming Soon / store copy is a **Weaver** pack — do not mutate frozen Echo Lattice Partner paste as if it were already Weaver |
| **Depth gates** | Echo Lattice G1–G4 Steam-resume gates in [`../VISION/ROADMAP_EXECUTE.md`](../VISION/ROADMAP_EXECUTE.md) §8 remain EL history; Weaver defines its own ship gates ([`ROADMAP.md`](ROADMAP.md), [`17_MVP.md`](17_MVP.md)) |

Weaver’s fantasy and craft bar are synthesized in [`MASTER_GDD.md`](MASTER_GDD.md). This pivot locks the **product-line and tree policy**; identity / Steam rename detail lives in [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md).

---

## 4. Agent / PR policy

| Do | Do not |
|---|---|
| Land Weaver docs and prototypes on branches targeting the active integration line | Delete `game/echo_lattice/` or freeze backups |
| Create / grow `game/weaver/` as the playable root | Overwrite EL scenes or rebrand the EL folder as Weaver |
| Archive-move EL to `game/_archive/echo_lattice/` only with link/CI fixes | Treat archive as license to wipe RELEASE / AUDIT / BACKUP |
| Link this pivot + [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) when changing product focus | Invent Steam AppIDs or claim Partner uploads |
| Preserve Echo Lattice screenshots, capsules, and contracts as history | Mash Echo Lattice store copy into Weaver without a dedicated rewrite |
| Cite freeze tip + this pivot when pausing EL work | Treat `docs/VISION/MASTER_1000X.md` as the live shipping north star after this pivot |
| Treat Weaver as the shipping SKU identity | Park Weaver forever as “side research” while shipping EL |

---

## 5. Related entry points

| Doc | Role after pivot |
|---|---|
| **This file** | Product-line lock: EL frozen · Weaver ships · tree kept / archive-capable · `game/weaver/` root |
| [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) | Rename strategy · archive path · Steam page rename plan |
| [`MASTER_GDD.md`](MASTER_GDD.md) | Design synthesis |
| [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) | Echo Lattice Steam pack freeze / resume |
| [`../BACKUP/README.md`](../BACKUP/README.md) | Backup index |
| [`../VISION/MASTER_1000X.md`](../VISION/MASTER_1000X.md) | Historical Echo Lattice 1000× vision (superseded as north star by Weaver) |
| [`../RELEASE/RC1_README.md`](../RELEASE/RC1_README.md) | RC1 integration hub for the frozen EL line |
| [`../GAME_PLAN.md`](../GAME_PLAN.md) | Multi-game catalog research (update separately if Weaver becomes Game 1) |
