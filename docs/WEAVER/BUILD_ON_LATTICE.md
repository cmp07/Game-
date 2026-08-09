# The Weaver — Build on Echo Lattice

**Status:** Active hybrid — Lattice Godot project is the **launch path**; Weaver loop is primary.  
**Mode:** Cloud-only. **No AppID invention. No `git mv` archive yet** ([`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) gates unmet).  
**Peers:** [`MASTER_GDD.md`](MASTER_GDD.md) · [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md) · [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) · [`35_JUICE.md`](35_JUICE.md)

| Field | Value |
|---|---|
| **Ship / window title** | **The Weaver** (internal; store name **Threadfall** remains NAME_LOCK recommend only) |
| **Launch project** | `game/echo_lattice/project.godot` |
| **Primary loop** | `scenes/weaver/field.tscn` via Main → Enter the Yard |
| **Prototype twin** | `game/weaver/` kept temporarily as standalone spike reference |
| **Lattice chambers** | Intact — menu **Archive · Chambers** / Continue / Daily / Hard / Museum |

**One line:** Play Weaver from the Echo Lattice shell; do not delete Lattice history; archive-move waits on human gates.

---

## 0. Decision

| Lock | Meaning |
|---|---|
| **Lattice hosts Weaver** | Autoloads, menu shell, fonts, audio bus, Steam stubs, save stack stay in `game/echo_lattice/`. |
| **Weaver is primary CTA** | Boot → menu brand **THE WEAVER** → **Enter the Yard** opens gather→combine→weave. |
| **No blind archive move** | `game/echo_lattice/` stays in place until [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) §6 is green. |
| **`game/weaver/` temporary** | Standalone Godot project remains for juice/loop spikes; product launch is Lattice. |
| **Chambers not deleted** | Echo Lattice wing reachable as **Archive · Chambers** (and existing modes). |

---

## 1. How to run

```bash
# Product launch path (Weaver on Lattice)
godot --path game/echo_lattice

# Headless Weaver loop contract
godot --path game/echo_lattice -- --weaver-selftest

# Optional: standalone spike project (temporary twin)
godot --path game/weaver

# Python contracts (no Godot binary required for Loom recipes / juice unit checks)
python3 game/echo_lattice/tests/test_weaver_on_lattice.py
python3 game/weaver/tests/test_prototype_loop.py
python3 game/weaver/tests/test_weaver_juice.py
```

**Editor:** Godot 4.3 → Import → `game/echo_lattice/project.godot` → F5.

**Controls (Yard):** WASD move · E gather · C combine · Space weave at void · Esc menu.

---

## 2. What was reused from Lattice

| Lattice asset | Weaver use |
|---|---|
| `project.godot` + GL Compatibility | Host project; window title / `config/name` → The Weaver |
| `scenes/main.tscn` + `scripts/main.gd` | Router; `show_weaver_field()` primary, chambers archive |
| `scenes/menu.tscn` + `scripts/menu.gd` + folio layout | Title shell; brand/CTA strings localized |
| `scenes/boot_title.tscn` | Cold-boot stamp (reads `brand.title`) |
| Autoloads: SaveManager, SteamService, Audio*, Juice, Palette, ArtKit, Locale, a11y | Unchanged shell services |
| `fonts/`, `default_bus_layout.tres`, `art/`, Steam stubs | Shared craft pipeline |
| Chamber scenes / ChamberBook / content maps | Archive wing only — not deleted |

| Weaver addition under Lattice | Role |
|---|---|
| `scripts/weaver/loom/loom_state.gd` (autoload `Loom`) | Session state gather→combine→weave→emit |
| `scripts/weaver/juice/*` | W1 juice + shed palette |
| `scenes/weaver/field.tscn` (+ fragment/player/structure/ui) | Playable East Post Gap |
| `content/weaver/*.json` | Recipes / fragments / palette |

---

## 3. Menu map

| Action | Destination |
|---|---|
| **Enter the Yard** | Weaver field (primary) |
| Continue archive | Lattice mid-run chambers |
| Daily sheet | Lattice daily wing |
| **Archive · Chambers** | Fresh Lattice campaign run |
| Hard binding / Museum | Lattice modes (unchanged) |

---

## 4. Relationship to migrate plan

[`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) remains **plan-only**. This hybrid **supersedes** the “never edit EL to bootstrap Weaver” agent fence for the **host shell + primary loop** only:

- Allowed: brand, main router, menu CTA, add `scenes/weaver/**` / `scripts/weaver/**` / `content/weaver/**`.
- Forbidden until migrate gates: `git mv` to `archive/`, deleting chambers, inventing AppIDs, wiping RELEASE/AUDIT/BACKUP.

When migrate execute lands, Weaver code already living under Lattice moves with the project (or is re-homed deliberately in that PR).

---

## 5. Name surfaces

| Surface | Value |
|---|---|
| Docs / code / window title | **The Weaver** |
| Store recommend ([`31_NAME_LOCK.md`](31_NAME_LOCK.md)) | **Threadfall** — not applied to Partner paste here |
| Historical freeze docs | Keep saying **Echo Lattice** |

---

## Doc status

**v0.1** — Hybrid build contract after Weaver master merge into RC1 line.
