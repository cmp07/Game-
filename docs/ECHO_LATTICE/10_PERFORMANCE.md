# Echo Lattice — Performance Plan

**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4.x · Windows Steam desktop  
**Doc index:** `00_PRODUCTION_BIBLE` · `03_TECH_ARCHITECTURE` · **`10_PERFORMANCE`**  
**Code:** `game/echo_lattice/src/{perf,vfx,grid,util}/`  
**Status:** Budget + pooling lock for 60 fps @ 1080p low-end  
**Last updated:** August 2026

---

## 1. Goal

Ship a habit-lattice puzzle that stays **≥ 60 fps** on low-end Windows at **1920×1080**, with **near-zero steady-state allocations** and hard caps on path fossils / VFX / grid bake cost.

Adaptation is the spectacle — rewrite juice and path fossils must never tank the frame that teaches “it learned you.”

---

## 2. Target hardware (floor)

| Spec | Floor |
|---|---|
| GPU | Intel UHD 620-class / GT 1030-class |
| CPU | Dual-core ~2.5 GHz (2017–2019 laptop OK) |
| RAM | 8 GB system |
| Display | **1080p** (primary validation); 720p stretch fallback |
| OS | Windows 10 x64 |
| Renderer | **Compatibility** default (`03_TECH_ARCHITECTURE` §8) |

**Frame budget:** 16.67 ms hard. Soft warn if script+physics > **12 ms**. Rewrite compute ≤ **4 ms** on floor CPU (else staged bake with input lock).

---

## 3. Budgets (hard caps)

| Budget | Limit | Owner / enforcement |
|---|:---:|---|
| Logical grid | ≤ **64×64** (prefer ≤ 32×48) | `LogicalGrid` assert |
| Visible wall cells | ≤ **2 000** | chamber authoring + bake |
| Active `Entities` nodes | ≤ **64** | pool pickups; no spawn spam |
| Path fossils live | ≤ **256** | `FossilPool` (steal-oldest) |
| Ghost trail points | ≤ **256** | decimate older samples |
| VFX sprites / bursts live | ≤ **200** particles equiv. / ≤ **48** pooled burst nodes | `VfxPool` |
| Rewrite burst duration | ≤ **0.6 s** | juice + `reduce_fx` |
| Audio voices | ≤ **24** | `ELAudio` steal-oldest |
| GDScript alloc / steady frame | **~0** | prealloc; no per-frame `Dictionary` in hot path |
| Rewrite compute | ≤ **4 ms** | dirty-rect bake / stage |
| Save hitch | ≤ **50 ms** | never mid-tween without pause |
| Working set | ≤ **400 MB** typical | atlas discipline |
| Cold start → Title | ≤ **3 s** HDD | small `res://` |

Constants live in `game/echo_lattice/src/perf/perf_budget.gd` (`PerfBudget`) so juice / core / a11y cannot silently drift.

### 3.1 Degradation (`settings.reduce_fx`)

When reduce-FX (or a11y reduce-motion) is on:

| Keep | Disable / soften |
|---|---|
| Tiles, player, HUD, rewrite **correctness** | Particles, camera shake, accent pulse shader, fossil soft glow |
| Fossil **positions** (gameplay-readable) | Fossil spawn rate / decorative overuse sparkles |
| Solvability + determinism | Full-screen flash spam (use `FlashGate`) |

---

## 4. Object pooling — path fossils & VFX

### 4.1 Why pool

Path **fossils** (move-buffer heat marks / ghost trail stamps) and rewrite **VFX** churn every step and every checkpoint. `instantiate()` / `queue_free()` per step causes GC spikes on low-end UHD laptops — the exact hardware we must hold 60 fps on.

### 4.2 Architecture

```text
Run/World/FX
├── FossilPool (Node2D)     # prewarm N FossilStamp nodes
└── VfxPool (Node2D)        # prewarm rewrite bursts + footstep decals

ObjectPool[T] (generic util)
  acquire() → reset + show
  release(item) → hide + deactivate + push free list
  steal_oldest() when at cap
```

| Pool | Prefab | Prewarm | Cap | Acquire triggers |
|---|---|---|---|---|
| Fossils | `PooledFossil` (`Sprite2D` / `Node2D`) | 64 | **256** | each committed step; ghost assist paint |
| VFX — footstep | `PooledVfx` kind `FOOTSTEP` | 24 | 48 | step (optional under reduce_fx) |
| VFX — rewrite | `PooledVfx` kind `REWRITE_BURST` | 4 | 8 | checkpoint rewrite |
| VFX — overuse spark | `PooledVfx` kind `OVERUSE` | 8 | 24 | habit-infection pulse |

### 4.3 Fossil pooling rules

1. **Never** hardcode fossil colors — style via `AccessibilityService.fossil_style(FossilPalette.FossilRole.*)` (see a11y sibling).  
2. On acquire: set cell, role (`FRESH`/`WARM`/`COLD`/`GHOST`/`OVERUSE`/`CHECKPOINT`), color, pattern, TTL.  
3. On release: clear tween, hide, reset modulate, return to free list.  
4. At cap: **steal-oldest** active fossil (ring eviction) — prefer dropping `COLD` before `FRESH` / `CHECKPOINT`.  
5. Chamber restart / rewrite bake: `FossilPool.release_all()` then repaint from move buffer in one pass (no per-cell alloc).  
6. Roles age in place when possible (`promote_role`) instead of release+acquire.

### 4.4 VFX pooling rules

1. One-shot bursts auto-release on `finished` / TTL.  
2. `reduce_fx` → rewrite burst uses **1** pooled flash node, 0 particles.  
3. No nested `CPUParticles2D` trees spawned per event — reuse configured emitters on pooled nodes.  
4. Particle live count must stay ≤ 200; if juice wants more, **reject** in `VfxPool.try_acquire` and log once per session in debug.

### 4.5 Code map

| File | Role |
|---|---|
| `src/util/object_pool.gd` | Generic acquire/release/steal |
| `src/vfx/pooled_fossil.gd` | Fossil stamp node |
| `src/vfx/fossil_pool.gd` | Fossil pool + role aging |
| `src/vfx/pooled_vfx.gd` | Footstep / rewrite / overuse node |
| `src/vfx/vfx_pool.gd` | VFX pool + reduce_fx gate |
| `src/perf/perf_budget.gd` | Shared caps |
| `src/perf/frame_profiler.gd` | Scope timers + budget asserts |

---

## 5. Grid optimizations

Source of truth is the **logical grid** (`PackedByteArray` / typed cells). TileMap is a **view** baked from dirty regions — never the rewrite mutator.

### 5.1 Logical grid

| Technique | Detail |
|---|---|
| Flat `PackedByteArray` | `index = y * width + x`; no nested arrays |
| Cell enum in `grid_types.gd` | `EMPTY/FLOOR/WALL/KEY/DOOR/CHECKPOINT/...` as `int` |
| Double buffer on rewrite | `cells` + `scratch`; swap refs after operator |
| Dirty AABB | Track min/max mutated cells per rewrite |
| Hash for determinism | FNV-1a / xxHash-style over bytes for golden tests |
| Bounds asserts | Debug-only; release clamps |

### 5.2 Bake (`grid_bake.gd`)

1. If dirty rect empty → no-op.  
2. Only set TileMap cells inside dirty AABB (+ 1-cell halo for autotile if needed).  
3. If rewrite compute > 4 ms → **stage**: apply operator to logical grid this frame; bake halves of dirty rect across next 1–2 frames while input locked.  
4. Never call `clear()` on full TileMap for a local rewrite.  
5. Debug: assert logical hash == expected fixture after bake.

### 5.3 Query hot path

| Avoid | Prefer |
|---|---|
| `Dictionary` keys per neighbor | 4-offset table `[(0,-1),(1,0),(0,1),(-1,0)]` |
| Allocating `Array` of walkables each step | Write into pre-sized `PackedInt32Array` |
| String tile names in rewrite | Integer cell kinds |
| Full-grid scan for “any key?” | Maintain counters (`key_count`, `door_count`) on mutate |

### 5.4 Code map

| File | Role |
|---|---|
| `src/grid/grid_types.gd` | Cell kinds + neighbor offsets |
| `src/grid/logical_grid.gd` | Storage, get/set, dirty, hash, double-buffer |
| `src/grid/grid_bake.gd` | Dirty-rect → TileMapLayer bake + staging |

---

## 6. Profiling checklist

Run before Demo lock and after any juice / rewrite change that touches FX or bake.

### 6.1 Editor monitors (every PR that touches hot path)

- [ ] **FPS** ≥ 60 at 1080p on floor GPU (or CI laptop proxy) during rewrite spam  
- [ ] **Process** + **Physics** time steady < 12 ms  
- [ ] **Draw calls** stable (no per-fossil material unique)  
- [ ] **Video mem** / texture count not climbing across chamber restarts  
- [ ] **Object count** — fossils + VFX nodes flat after prewarm (pool working)  
- [ ] **Memory** — no sawtooth from instantiate/free during 5-min soak  

### 6.2 Micro-benches (debug builds)

- [ ] `FrameProfiler.scope("rewrite")` — p95 ≤ 4 ms on floor  
- [ ] `FrameProfiler.scope("bake")` — dirty-rect only; full-map bake forbidden in logs  
- [ ] `FossilPool.stats()` — `acquired` ≈ `released` after chamber clear; `live` ≤ 256  
- [ ] `VfxPool.stats()` — no `rejected_budget` spam in normal play  
- [ ] Determinism: replay fixture → `LogicalGrid.hash_cells()` matches golden  

### 6.3 Playtest scenarios

| Scenario | Pass criteria |
|---|---|
| Dash through 12 chambers, rewrite each checkpoint | No hitch > 1 frame drop visible; FPS ≥ 55 worst |
| Ghost assist paints full path | ≤ 256 fossils; no hitch |
| Spam undo / restart | Pool stats reset clean; no leaks |
| `reduce_fx` on | Still 60 fps; fossils readable via a11y palette |
| 1080p windowed + border | Same budgets |
| Steam Deck / UHD laptop | Manual soak 10 min |

### 6.4 Tools

| Tool | Use |
|---|---|
| Godot Debugger → Monitors | FPS, process, physics, draw calls |
| Godot Profiler | Script hotspots in rewriter / bake |
| `FrameProfiler` overlay (`ELDebug`) | On-device ms readouts |
| Headless tests | `tests/test_perf_pools.py`, grid hash fixtures |

---

## 7. 60 fps acceptance gates

| Gate | Requirement |
|---|---|
| G1 | 1080p, Compatibility renderer, vsync on → **avg ≥ 60 fps**, 1% lows ≥ 55 in rewrite-heavy wing |
| G2 | Fossil pool prewarmed; **zero** `instantiate` in steady step loop (debug counter) |
| G3 | Rewrite+bake p95 ≤ 4 ms logical; staged bake if exceeded |
| G4 | `reduce_fx` path validated |
| G5 | Working set ≤ 400 MB after wing clear |
| G6 | No gameplay bug when pools steal-oldest under cap stress |

---

## 8. Integration contracts

| Peer | Contract |
|---|---|
| Tech (`03_TECH_ARCHITECTURE`) | Budgets here supersede sketch numbers if they diverge — keep in sync |
| Core / scaffold | Parent `FossilPool` + `VfxPool` under `Run/World/FX`; call acquire on step/rewrite |
| Juice | Must go through pools; no ad-hoc particle trees |
| Accessibility | Fossil colors/patterns from `FossilPalette` / `AccessibilityService` |
| Systems / Habit | Move buffer length drives fossil count; cap still 256 |
| Audio | Voice steal separate; footstep SFX not tied to VFX node lifetime |

---

## 9. Implementation sequence (perf-owned)

1. Land `PerfBudget` + `ObjectPool` + fossil/VFX pools.  
2. Land `LogicalGrid` dirty + hash + double-buffer; `GridBake` dirty-rect.  
3. Wire pools into Run scene when scaffold lands.  
4. Add headless pool/grid tests.  
5. Profile rewrite spam on low-end before Demo.

---

## 10. Related documents

| Doc | Role |
|---|---|
| `docs/ECHO_LATTICE/03_TECH_ARCHITECTURE.md` | Runtime shape, §9 budget sketch |
| `docs/ECHO_LATTICE/00_PRODUCTION_BIBLE.md` | Production lock / ownership |
| Accessibility settings (sibling) | Fossil palettes, reduce flash/motion |
| Juice / Art bibles (siblings) | Visual identity within these caps |

---

## 11. Decision log

| Decision | Choice | Rationale |
|---|---|---|
| Fossil eviction | Steal-oldest, prefer COLD | Keeps recent habit readable |
| Grid storage | `PackedByteArray` flat | Cache-friendly, zero nested alloc |
| Bake | Dirty AABB + optional staging | Protects 16.6 ms frame |
| Caps in code | `PerfBudget` constants | Prevent juice regressions |
| Validation res | 1080p primary | Matches Steam laptop norm |
