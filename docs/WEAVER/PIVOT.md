# Weaver pivot — durable north star

**Status:** Echo Lattice product line is **frozen**. **Weaver** is the active north star.  
**Hard rule:** Do **not** delete Echo Lattice. Keep `game/echo_lattice/` and its docs / Steam pack freeze as durable reference.  
**Mode:** Cloud-only durable docs. No AppID invention. No genre mash into Weaver from abandoned pitches.

| Field | Value |
|---|---|
| **Pivot date** | 2026-08-09 |
| **RC1 tip at pivot** | `a1f49a3b613dff4565cd7ba309f463c883df4707` |
| **Integration line (docs land here)** | `cursor/echo-lattice-rc1` |
| **Pivot branch** | `cursor/weaver-pivot` |
| **Echo Lattice tree** | `game/echo_lattice/` — **kept** |
| **Steam pack freeze** | [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |

---

## 1. Decision (read this first)

| Lock | Meaning |
|---|---|
| **Echo Lattice is frozen** | Stop treating Echo Lattice as the shipping north star. No new feature waves aimed at Echo Lattice 1.0 unless explicitly reopened. |
| **Weaver is the north star** | New product vision, design, prototype, and Steam planning default to **Weaver**. |
| **Keep the tree** | `game/echo_lattice/` stays in-repo. Do not delete, rename away, or strip Steam / RELEASE / AUDIT / BACKUP artifacts that document the freeze. |
| **Reuse is optional** | Weaver may borrow engines, tooling, or craft lessons from Echo Lattice, but it is a **separate product identity** — not a rebrand of Echo Lattice store copy. |

**One line:** Echo Lattice remains a frozen vertical slice + Steam pack archive; Weaver is what we build next.

---

## 2. What stays (Echo Lattice)

Do **not** delete these. They are the resume / archaeology surface if Steam or craft work returns to Field Ledger:

| Area | Path / ref |
|---|---|
| Godot project | `game/echo_lattice/` |
| Product docs | `docs/ECHO_LATTICE/` · [`../ECHO_LATTICE_META.md`](../ECHO_LATTICE_META.md) |
| Vision corpus (historical for EL) | `docs/VISION/` |
| Steam / RELEASE / AUDIT pack | `docs/RELEASE/` · `docs/AUDIT/` · `steam/echo_lattice/` |
| Durable Steam freeze | branch + tag `backup/echo-lattice-rc1-steam-pack` — see [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) |
| Python contracts | `game/echo_lattice/tests/test_*.py` |

Frozen means **no deletion and no Partner invention**, not “empty the folder.” Agents must refuse wipe requests against this tree unless a human explicitly supersedes this pivot in a later docs PR.

---

## 3. What moves (Weaver)

| Area | Policy |
|---|---|
| **North star docs** | Live under `docs/WEAVER/` — this file is the pivot lock; add design / systems / roadmap siblings here as Weaver matures |
| **Prototype / game code** | Prefer a future `game/weaver/` (or successor path) rather than overwriting `game/echo_lattice/` |
| **Steam / store work** | New Coming Soon / store copy for Weaver is a **separate** pack; do not mutate frozen Echo Lattice Partner paste as if it were Weaver |
| **Depth gates** | Echo Lattice G1–G4 Steam-resume gates in [`../VISION/ROADMAP_EXECUTE.md`](../VISION/ROADMAP_EXECUTE.md) §8 remain EL history; Weaver defines its own ship gates when ready |

Weaver’s fantasy, category, and craft bar are intentionally **not** fully specified in this pivot PR — only the **product-line decision** is durable here. Follow-on Weaver design docs should link back to this file.

---

## 4. Agent / PR policy

| Do | Do not |
|---|---|
| Land Weaver docs and prototypes on branches targeting the active integration line | Delete `game/echo_lattice/` or freeze backups |
| Link this pivot from BACKUP / RELEASE hubs when changing product focus | Invent Steam AppIDs or claim Partner uploads |
| Preserve Echo Lattice screenshots, capsules, and contracts | Mash Echo Lattice store copy into Weaver without a dedicated rewrite |
| Cite freeze tip + this pivot when pausing EL work | Treat `docs/VISION/MASTER_1000X.md` as the live shipping north star after this pivot |

---

## 5. Related entry points

| Doc | Role after pivot |
|---|---|
| **This file** | Product-line lock: EL frozen · Weaver north star · tree kept |
| [`../BACKUP/RC1_STEAM_PACK_FREEZE.md`](../BACKUP/RC1_STEAM_PACK_FREEZE.md) | Echo Lattice Steam pack freeze / resume |
| [`../BACKUP/README.md`](../BACKUP/README.md) | Backup index |
| [`../VISION/MASTER_1000X.md`](../VISION/MASTER_1000X.md) | Historical Echo Lattice 1000× vision (superseded as north star by Weaver) |
| [`../RELEASE/RC1_README.md`](../RELEASE/RC1_README.md) | RC1 integration hub for the frozen EL line |
| [`../GAME_PLAN.md`](../GAME_PLAN.md) | Multi-game catalog research (update separately if Weaver becomes Game 1) |
