# The Weaver — Design Changelog

**Role:** Durable record of design corpus landings and product-identity locks.  
**Authority:** [`MASTER_GDD.md`](MASTER_GDD.md) (v2) · [`ROADMAP.md`](ROADMAP.md) · [`PIVOT.md`](PIVOT.md)  
**Mode:** Docs history only. No AppID invention.

---

## 2026-08-09 — Master GDD v2 (product replace Lattice)

**Branch:** `cursor/weaver-master-v2` · **Base:** `cursor/echo-lattice-rc1`  
**PR title:** The Weaver Master GDD v2 — product replace Lattice

### Product

- **Ship identity:** The Weaver (not Echo Lattice forever side-project) — [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md)
- **Echo Lattice:** frozen & **kept** at `game/echo_lattice/`; migrate is **plan only** — [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md)
- **Playable root:** `game/weaver/` Godot 4.3 MVP stub landed (placeholder loop)

### Corpus

| Range | Topic |
|---|---|
| `01`–`19` | Wave-1 fantasy / systems / world / craft / biz / MVP (already on RC1 via #172) |
| `20` | Elevations V2 — 25 concrete design bets |
| `21` | Fragment feel — juice, silhouettes, brass beat |
| `22` | Discovery UX — combinations without spoiler wiki |
| `23` | Weave verb — second-by-second feel |
| `24` | Structure ecology — answering Structure classes |
| `25` | Void art V2 — kill circles-on-black |
| `26` | Audio V2 — Fragment / Thread / Structure leitmotifs |
| `27` | Solo economy V2 — kill player-trade fantasy |
| `28` | Legacy V2 — offline Structure evolution |
| `29` | Multiplayer V2 — post-1.0 co-op fence only |
| `30` | Steam pitch + pricing rethink |
| `31` | Name lock recommendation |
| `32` | First-five prototype beat script |
| `33` | Migrate-from-Lattice plan (no tree move) |
| `34` | Adversarial GDD — idle / spreadsheet / empty void |

### Synthesis artifacts

- [`MASTER_GDD.md`](MASTER_GDD.md) → **v2**
- [`ROADMAP.md`](ROADMAP.md) → scaffold status + W0.5
- This changelog
- [`README.md`](README.md) → full `01`–`34` index

### Explicit non-changes

- Did **not** delete or `git mv` `game/echo_lattice/`
- Did **not** invent Steam AppIDs
- Did **not** mutate Echo Lattice Partner freeze paste into Weaver store copy

---

## 2026-08-09 — Master GDD v1 (wave-1 seal)

**Branch:** `cursor/weaver-master` · **PR:** #172 (merged to RC1)

- Pivot lock: Echo Lattice frozen; Weaver north star — [`PIVOT.md`](PIVOT.md)
- Docs `01`–`19` merged from sibling `cursor/weaver-*` packs
- Initial [`MASTER_GDD.md`](MASTER_GDD.md) · [`ROADMAP.md`](ROADMAP.md) · index README
- No `game/weaver/` yet (docs-only)

---

## How to append

Add a dated section at the top when a design wave lands. Link branch + PR. Note any product-identity or ban-list changes in a short table. Keep AppID / Partner claims out of this file.
