# The Weaver — 1000× Tech Architecture

**Doc:** `docs/WEAVER/1000X/13_TECH.md`  
**Status:** Hybrid launch architecture + data-driven content law for 1000× features  
**Working title:** The Weaver  
**Branch:** `cursor/weaver-1000x-tech`  
**Base:** `cursor/echo-lattice-rc1`  
**Date:** 2026-08-09  
**Mode:** Cloud-only. **No AppID invention. No `git mv` archive. Prefer GDScript.**

**Authority peers:** [`../BUILD_ON_LATTICE.md`](../BUILD_ON_LATTICE.md) · [`../14_TECH.md`](../14_TECH.md) · [`../MASTER_GDD.md`](../MASTER_GDD.md) · [`../PIVOT.md`](../PIVOT.md) · [`../33_MIGRATE_FROM_LATTICE.md`](../33_MIGRATE_FROM_LATTICE.md) · [`00_MASTER_VISION.md`](00_MASTER_VISION.md) · [`../17_MVP.md`](../17_MVP.md)

**Supersedes for launch path:** greenfield-only reading of [`../14_TECH.md`](../14_TECH.md) §2 (“code home = `game/weaver/` only”). MVP stack locks (Godot 4, offline, fail-closed Steam) still hold. Hybrid contract in [`../BUILD_ON_LATTICE.md`](../BUILD_ON_LATTICE.md) wins for **where code runs today**.

---

## 0. Verdict (read this first)

| Lock | Meaning |
|---|---|
| **Engine** | **Godot 4.3** · `gl_compatibility` · **GDScript first** |
| **Launch project** | `game/echo_lattice/project.godot` — Lattice shell hosts Weaver |
| **Primary loop** | `scenes/weaver/field.tscn` via Main → **Enter the Yard** |
| **Content law** | Fragments / Threads / Structures / fields / recipes are **JSON (or Resources) + Python validators** — not hardcoded scene-only kits |
| **Language** | **GDScript** for gameplay, loom, juice, UI; C# / GDExtension only if a hire already owns that stack |
| **Network** | None required for core loop / 1000× solo features |
| **Archive** | Keep `game/echo_lattice/` in place; migrate remains plan-only |
| **Twin spike** | `game/weaver/` temporary reference — product ship path is Lattice host |

**One line:** Ship Weaver 1000× features as **data-driven GDScript modules under the Lattice host**, not as a second engine, a server, or a scene-only prototype forever.

---

## 1. Why hybrid (and what 1000× does not change)

1000× raises feel and content density. It does **not** reopen the host decision.

| Pressure | Hybrid answer |
|---|---|
| Need a real menu / fonts / audio buses / Steam stub / save stack | Reuse Lattice shell — do not rebuild |
| Need primary CTA for Weaver | Brand + **Enter the Yard** on Lattice menu |
| Need archive honesty for EL chambers | **Archive · Chambers** (and Daily / Hard / Museum) stay reachable |
| Need to deepen Fragments / Threads / Structures | Add under `content/weaver/**` + `scripts/weaver/**` |
| Temptation to `git mv` EL away mid-spike | Blocked until [`../33_MIGRATE_FROM_LATTICE.md`](../33_MIGRATE_FROM_LATTICE.md) §6 |

```
Boot → Lattice Main router → menu (THE WEAVER)
         ├─ Enter the Yard  → scenes/weaver/field.tscn   ← primary
         ├─ Archive · Chambers / Daily / Hard / Museum   ← EL wing
         └─ Settings / a11y / Steam stub                 ← shared shell
```

**Hybrid does not dilute ambition.** It accelerates proof of the verb while archive history stays intact ([`00_MASTER_VISION.md`](00_MASTER_VISION.md) §10).

---

## 2. Stack (1000× / ship)

| Layer | Choice | Cut / defer |
|---|---|---|
| Engine | Godot **4.3** (track studio skill; LTS-minded) | Unity/Unreal rewrite — no |
| Language | **GDScript 2.0** first | C# day-one rewrite — no; GDExtension only for proven hot paths |
| Rendering | 2D (shed materials / textile page) + `gl_compatibility` | Forward+/Nanite envy / RT — no |
| Physics | Grid + transforms for W1; verlet/beam only after G1 sim fence | Full soft-body / 3D cloth — not for slice |
| Content | JSON under `content/weaver/` + typed loaders | Runtime LLM / online generative dungeon — banned |
| Audio | Lattice buses + Weaver juice cues; authored stems as they land | Middleware suites — defer |
| Save | Lattice `SaveManager` + Weaver session keys (namespaced) | Cloud save — post-1.0 |
| Platform | GodotSteam **fail-closed** (optional) | Invented AppIDs — never |
| Tests | Python content contracts + `--weaver-selftest` headless | Claiming Deck CI farm in cloud — never |
| CI | Export Windows when runners allow; Python green without editor | Full console matrix — out of band |

---

## 3. Runtime architecture

### 3.1 Layers

```text
game/echo_lattice/project.godot
├─ Autoloads (Lattice shell)     SaveManager · SteamService · Audio* · Juice · Palette · …
├─ Autoloads (Weaver)            Loom · WeaverPalette · WeaverJuice
├─ scenes/main.tscn              Router (show_weaver_field / archive chambers)
├─ scenes/menu.tscn              Brand + Enter the Yard CTA
├─ scenes/weaver/**              Playable Yard field + fragment/player/structure/ui
├─ scripts/weaver/**             GDScript gameplay (loom, field, juice, ui)
├─ content/weaver/**             Data-driven recipes / fragments / palette / (future fields)
└─ tests/test_weaver_*.py        Host + content contracts
```

| Layer | Responsibility | Primary home |
|---|---|---|
| Shell | Boot, menu, settings, Steam stub, locale, a11y | Existing Lattice scripts (edit brand/CTA only) |
| Router | Stage swaps; `--weaver-selftest` / screenshot hooks | `scripts/main.gd` |
| Loom | Session: gather → combine → weave → emit | `scripts/weaver/loom/loom_state.gd` (autoload `Loom`) |
| Field | Authored play space; player + void + structure seat | `scripts/weaver/field.gd` + `scenes/weaver/field.tscn` |
| Content | Recipes, fragment families, structure emit rules | `content/weaver/*.json` |
| Juice | Recover suck / bind flash / tension pulse (W1) | `scripts/weaver/juice/*` |
| Archive wing | EL chambers — not deleted | Lattice chamber scenes + `ChamberBook` |

### 3.2 Autoload fence

| Autoload | Owns | Must not own |
|---|---|---|
| `Loom` | Inventory, recipes, combine legality, seat, emit, selftest API | Scene trees, Steam I/O, save disk format |
| `WeaverJuice` / `WeaverPalette` | Weaver-specific feel + shed colors | Global Lattice juice for chambers |
| Lattice `SaveManager` / `SteamService` / `Audio*` | Shell services | Weaver recipe grammar |

**Rule:** Weaver gameplay talks to shell through signals and small APIs (`menu_requested`, prompt text, namespaced save keys). Field scripts **must not** `change_scene_to_file` away from the Lattice router.

### 3.3 GDScript preference (hard)

| Prefer | Avoid unless forced |
|---|---|
| GDScript modules under `scripts/weaver/` | Porting the loom to C# “for speed” |
| `class_name` helpers + typed Dictionaries from JSON | Opaque Variant soup with no schema |
| Signal-driven UI (`combine_ui_requested`, `structure_seated`) | Polling globals from every node |
| Headless `Loom.selftest_loop(seed)` | Manual-only QA for determinism |

C# / native is a **hire-driven** exception, not a 1000× prerequisite.

---

## 4. Data-driven content law

1000× content volume dies if every Fragment family or field is a one-off scene. Author **data first**; scenes are views over data.

### 4.1 Content roots (today → 1000×)

| Path | Role today | 1000× expansion |
|---|---|---|
| `content/weaver/recipes.json` | Combine recipes, structure emit, caps | Full Thread type table; structure classes; channel tags |
| `content/weaver/fragments.json` | Family stubs | Six MVP families + ports + palm/settle metadata |
| `content/weaver/palette.json` | Shed material colors | Material tokens shared with juice / UI |
| *(future)* `content/weaver/fields/*.json` | — | Authored field scarcities, seed fragments, void geometry, win predicates |
| *(future)* `content/weaver/structures/*.json` | Inline in recipes | Ecology classes (topology / flow / load / pulse / vent) |
| *(future)* `content/weaver/jobs/*.json` | — | Yard job board rows (unlock nouns, not XP) |

### 4.2 Schema principles

1. **IDs are stable strings** (`Anchor`, `Brace`, `span_structure`) — scenes reference IDs, never the reverse.  
2. **Recipes are commutative where design says so** — loaders accept `[A,B]` or `[B,A]`.  
3. **Caps live in data** (`fragment_slots`, `thread_budget`) — not magic numbers alone in UI.  
4. **Defaults are teach-safe** — missing recipe may fall back to FIRST_FIVE Brace only in spike; 1000× validators **fail CI** on silent fallbacks for ship content.  
5. **Determinism** — same seed + same inputs → same weave/emit sequence (dailies, ghosts, selftest).  
6. **No runtime LLM** — grammars and tables are authored; generators (if any) are offline tools that write JSON.

### 4.3 Minimal recipe shape (current contract)

```json
{
  "version": 1,
  "fragment_kinds": [{ "id": "Anchor", "family": "anchor", "label": "Anchor", "role": "…" }],
  "thread_types": [{ "id": "Brace", "label": "Brace Thread", "failure": "overload tear" }],
  "combine_recipes": [
    { "id": "east_post_brace", "inputs": ["Anchor", "Span"], "output_thread": "Brace", "label": "Brace Thread" }
  ],
  "structure": {
    "id": "span_structure",
    "label": "Span Structure",
    "thread_cost": 1,
    "emit_interval_sec": 3.5,
    "emit_kinds": ["Anchor", "Span"],
    "channel": "topology"
  },
  "caps": { "fragment_slots": 4, "thread_budget": 3, "field_seed_fragments": 4 }
}
```

Python gate today: `game/echo_lattice/tests/test_weaver_on_lattice.py` (FIRST_FIVE kinds, Brace recipe, host files, locale brand).

### 4.4 Loader pattern (GDScript)

| Step | Owner |
|---|---|
| Parse JSON at boot / field enter | `Loom.load_recipes()` (extend for fragments/fields) |
| Validate required keys | Python tests pre-merge; optional soft assert in debug builds |
| Expose query API | `find_recipe`, future `get_fragment(id)`, `get_field(id)` |
| Keep scenes dumb | `fragment.tscn` instances read kind from spawn data |

**Anti-pattern:** duplicating recipe tables in `field.gd` and `combine_panel.gd`. One loader, many views.

---

## 5. Module map for 1000× features

Add features as **namespaced GDScript + JSON**, not as new autoload continents.

```
scripts/weaver/
  loom/                 # session + recipe queries + determinism
  field/                # field controllers / demo_field
  fragments/            # (future) port helpers, settle feel hooks
  threads/              # (future) slack→taut visuals driven by data
  structures/           # (future) channel behaviours keyed by structure.id
  jobs/                 # (future) yard board from jobs/*.json
  modes/                # (future) daily seed / endless / museum residue
  meta/                 # (future) gallery stamps — local only
  juice/                # feel punctuation (keep thin + a11y-aware)
  ui/                   # combine panel, prompts — signal bound
  platform/             # only if Weaver needs shell adapters beyond Lattice
```

| 1000× feature class | Data | Code | Shell touch |
|---|---|---|---|
| New Fragment family | `fragments.json` + recipe rows | spawn + juice settle | none |
| New Thread type | `thread_types` + combine rows | bind legality + strain tell | none |
| New Structure class | `structures/*.json` | seat/emit/channel behaviour | none |
| New field / job | `fields/*.json` + `jobs/*.json` | field loader | menu job board row (optional) |
| Daily / seed modes | seed table JSON | `modes/` + `Loom` seed API | menu CTA reuse |
| Gallery / residue | local save keys | `meta/` | Museum-style screen optional |
| Juice elevation | palette tokens | `juice/` only | a11y flash gates via Lattice |

**Shell edit budget:** brand, CTA, router entry points, locale strings. Do not turn `chamber.gd` into Weaver.

---

## 6. Twin project policy (`game/weaver/`)

| Path | Role | 1000× policy |
|---|---|---|
| `game/echo_lattice/` | **Product launch** | All ship features land here under `*/weaver/` |
| `game/weaver/` | Temporary spike / juice sandbox | May prototype feel; promote winners into Lattice host |
| Promote rule | Spike → host | Copy patterns + data; delete duplication when host owns it |
| Forbidden | Overwriting EL chambers to “become” Weaver | Migrate is rename-later, not in-place mash |

Headless / Python:

```bash
godot --path game/echo_lattice
godot --path game/echo_lattice -- --weaver-selftest
python3 game/echo_lattice/tests/test_weaver_on_lattice.py
python3 game/echo_lattice/tests/test_weaver_juice.py
# Optional twin:
godot --path game/weaver
python3 game/weaver/tests/test_prototype_loop.py
```

---

## 7. Determinism, saves, platform

### 7.1 Determinism

| Requirement | Implementation cue |
|---|---|
| Selftest / daily / ghost | Seeded `RandomNumberGenerator` on `Loom` (already used in `selftest_loop`) |
| Same seed → same emit | Emit kinds drawn from data + seeded RNG — never `randf()` unsourced |
| Collapse fairness | Culprit IDs from graph data, not frame-time noise |
| Softlock recovery | Authored escape in field JSON / BFS-style net where geometry needs it |

### 7.2 Saves

| Scope | Store |
|---|---|
| Lattice archive progress | Existing `SaveManager` / chamber continuum |
| Weaver yard progress | **Namespaced** keys (e.g. `weaver.*`) — never clobber EL campaign blobs |
| Settings / a11y / locale | Lattice stores unchanged |
| Cloud | Fail-closed optional; local atomic write is MVP law |

### 7.3 Steam / compliance

| Item | Law |
|---|---|
| AppID | Human Partner only — agents never invent |
| Offline bar | Full gather→combine→weave with Steam disabled |
| Achievements | Thin optional; stub unlocks in dev |
| AI disclosure | Runtime LLM cut; asset gen disclosed if used |
| Deck | Stretch after Windows export path is real |

---

## 8. Testing & quality gates

| Gate | Tool | Pass means |
|---|---|---|
| Host hybrid intact | `test_weaver_on_lattice.py` | Brand, Loom autoload, field files, locale CTA, router hooks |
| Recipe FIRST_FIVE / MVP | Same + future schema tests | Anchor+Span→Brace→span_structure (until data expands with tests) |
| Juice contracts | `test_weaver_juice.py` | Feel helpers present; no purple palette tokens |
| Runtime loop | `--weaver-selftest` | `Loom.selftest_loop` returns `ok` |
| Anti-scene-leak | Grep/contracts | Weaver field does not hard-swap away from Main |
| Perf (planning) | Manual + later meters | Seat/juice spike framed; 1080p / 60 comfort target |

**1000× test expansion (ordered):**

1. Schema validators per new JSON root (fragments / fields / jobs).  
2. Determinism golden logs for seeded loops.  
3. Softlock smoke per field JSON.  
4. Locale keys for every player-facing string added with content.

---

## 9. Performance & content budgets

| Budget | Guidance |
|---|---|
| Resolution / FPS | 1080p target; 60 FPS comfort mid-tier Windows |
| Juiciest frame | Tension seat / crease→lift→seat — budget hitstop, not hitch |
| Content volume | Prefer fewer **legible** fields over infinite PCG sludge |
| Carry / chemistry | Tiny carry + job-fenced recipes (spreadsheet death ban) |
| Install size | Lean materials; no 4K video walls |
| Autoload count | Prefer modules over new global singletons |

Exact numeric gates belong in later perf docs; this table stops gold-plating.

---

## 10. Honest cuts (tech temptations)

| Temptation | Cut | Revisit when… |
|---|---|---|
| Dedicated Weaver game server | **Cut** | Never for competitive; co-op only per MP v2 fence |
| Runtime LLM / AI dungeon | **Cut** | Fantasy forbids |
| C# rewrite of loom | **Cut** | Hire already C#-native *and* GDScript blocked |
| Extract shared framework day one | Soft cut | Copy patterns; don’t block on monorepo perfection |
| In-place EL → Weaver rename | **Cut** | Migrate execute PR only |
| Workshop UGC pipeline | **Cut** | Post-1.0 + moderation |
| Steam Cloud as MVP dependency | **Cut** | After local save boring-reliable |
| Dual physics stacks (2D + 3D) | **Cut** | Pick G1 sim fence once |

---

## 11. Relationship to sibling docs

| Doc | Wins on… |
|---|---|
| [`../BUILD_ON_LATTICE.md`](../BUILD_ON_LATTICE.md) | Host path, how to run, menu map |
| [`../14_TECH.md`](../14_TECH.md) | MVP offline stack, Steam fail-closed, platform minimums |
| **This file** | 1000× hybrid module map, **data-driven content law**, GDScript preference, feature plug-in rules |
| [`00_MASTER_VISION.md`](00_MASTER_VISION.md) | Ambition / feel / bans (not implementation) |
| [`../33_MIGRATE_FROM_LATTICE.md`](../33_MIGRATE_FROM_LATTICE.md) | Future archive rename — plan only |
| [`../ROADMAP.md`](../ROADMAP.md) | Wave order; Coming Soon still gated on slice |

When `14_TECH` says “prefer future `game/weaver/`,” read it as **eventual clean tree after migrate**, not as “do not host under Lattice today.”

---

## 12. Build / ship path (lean)

1. Keep hybrid green: Enter the Yard + Python host contracts.  
2. Grow `content/weaver/**` schemas with validators before art ramp.  
3. Promote spike juice into host `scripts/weaver/juice/` (GDScript).  
4. Vertical slice `.exe` from Lattice project (one ceremony, mute-legible).  
5. Demo export skinned from slice — no second codebase.  
6. Partner / AppID only after slice gates — human steps.

---

## 13. Lock line

**Weaver 1000× tech = Godot 4.3 GDScript on the Lattice host, offline, with content-as-data under `content/weaver/`.**  
New features extend JSON + thin modules — they do not invent a server, a second engine, or a purple void.

```
Shell hosts. Loom judges. Data authors. GDScript moves the hands.
```

---

## Doc status

**v1.0** — 1000× tech architecture for The Weaver hybrid. Cloud-only durable docs; no AppID invention; no archive move in this PR.
