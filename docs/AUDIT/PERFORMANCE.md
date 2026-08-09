# Echo Lattice — Performance Audit (RC1)

**Scope:** `game/echo_lattice/` on `cursor/echo-lattice-rc1`  
**Engine:** Godot 4.3 · GDScript · `gl_compatibility`  
**Date:** 2026-08-09  
**Method:** Static code review + synthetic cost models. **No Godot binary / Deck hardware in this cloud agent**, so frame times are reasoned upper bounds, not on-device captures. Validate gates on device before Verified submit.

**Related (not merged into RC1):** draft plan + unused pool modules on `cursor/echo-lattice-perf` → `docs/ECHO_LATTICE/10_PERFORMANCE.md`. This audit is about **what ships today**.

---

## 0. Verdict

| Target | Status | Confidence |
|---|---|---|
| Desktop 60 fps @ 1080p Compatibility | **At risk** under steady chamber redraw + paper grain | High (code-path) |
| Deck Verified 60 fps @ **7 W** | **At risk** — grain + full-grid redraw dominate fill | Medium |
| Deck battery 40 fps @ **4 W** (`--battery`) | **Likely OK** if grain is baked / dirty-rect | Medium |
| Rewrite slam hitch ≤ 1 frame spike | **Failing intent** — O(candidates × BFS) + particle Dictionary burst | High |
| Near-zero steady-state GC | **Failing** — AdaptiveMusic + grain + Juice Dictionaries | High |
| Scene reload leak-free | **Mostly OK**; Juice / follow-up timers / menu signal lambdas need hygiene | Medium |

**Bottom line:** The play loop is a 24×14 ledger, so CPU/GPU *should* have headroom. The RC1 path burns that headroom by **redrawing the entire chamber every frame**, regenerating **thousands of 1×1 grain rects**, and allocating in hot audio/juice paths. Fix draw dirtying + grain first; then pool particles and cut rewrite BFS; then silence per-frame audio alloc.

---

## 1. 60 fps targets

### What exists

| Control | Location | Behavior |
|---|---|---|
| VSync | `project.godot` + `DeckProfile.apply_runtime_defaults` | On |
| Deck FPS cap | `DeckProfile.TARGET_FPS_VERIFIED = 60` | `Engine.max_fps = 60` on Deck |
| Battery cap | `--battery` → `TARGET_FPS_BATTERY = 40` | Documented 4 W path |
| Renderer | `gl_compatibility` | Correct for Deck / low-end |
| Viewport | 960×560 base, stretch `expand` | Deck logical ≈ 960×600 |

Authority for watts: [`docs/RELEASE/STEAM_DECK.md`](../RELEASE/STEAM_DECK.md) (7 W / 4 W).

### Measured / modeled frame cost (steady chamber)

Every `_process` in `chamber.gd` ends with unconditional `queue_redraw()`:

```111:121:game/echo_lattice/scripts/chamber.gd
func _process(delta: float) -> void:
	goal_pulse_t = fmod(goal_pulse_t + delta, TAU)
	lantern_t = fmod(lantern_t + delta * 1.7, TAU)
	# ...
	_refresh_telegraph()
	queue_redraw()
```

`_draw` then:

1. Full-viewport wash + **`ArtKit.draw_paper_grain`** (viewport).
2. Page grain again.
3. Full **24×14** tile pass (~336 cells × ~3–6 canvas ops).
4. Ghost trail, telegraph, player, Juice particles, flash.

**Paper grain cost model** (`draw_paper_grain`, step 6, p≈0.18):

| Viewport | Sample cells (vp+page) | Expected `draw_rect` / frame |
|---|---:|---:|
| 960×560 | ~26 032 | **~4 685** |
| Deck logical 960×600 | ~27 152 | **~4 887** |
| If grain ever saw 1280×800 panel size | ~39 481 | **~7 106** |

Plus ~1 300–2 000 tile/trail ops. That is **CPU canvas submission**, not a cheap clear — Compatibility on Deck is especially sensitive.

Menu is the same pattern: `_process` always `queue_redraw()` + grain (`menu.gd`).

### Fixes (priority order)

1. **Dirty redraw** — only `queue_redraw()` when pulse/slam/shake/particles/telegraph actually change; idle boards can tick pulse at 10–15 Hz or use a lightweight overlay node for lantern/goal pulse.
2. **Bake grain once** — replace per-frame 1×1 rect spam with a pre-generated `ImageTexture` (or shader) cached in `ArtKit`; modulate opacity only.
3. **Frame profiler gate** — port `FrameProfiler` / `PerfBudget` from the perf draft (or a thin `--perf-hud`) and fail CI selftest if script scope > 12 ms average over 120 frames in headless stub timing.
4. **Deck QA** — 40 min daily wing at 7 W; log `Performance.get_monitor(TIME_PROCESS)` / fps; same at 4 W + `--battery`.

**Acceptance:** p95 frame ≤ 16.67 ms at 7 W native Linux; p95 ≤ 25 ms at 4 W / 40 fps.

---

## 2. Rewrite slam cost

### What exists

- Slam window: `REWRITE_DURATION = 0.90` s (~54 frames @ 60 fps).
- Commit path: `_trigger_rewrite` → candidate filter via **per-cell BFS** → Juice punch + per-cell particle bursts → 0.9 s animated `_draw_rewrite_slam`.
- During slam, chamber still full-redraws every frame; each pending cell runs crease / lift / slot / rust phases with texture blits.

### Cost model

| Pending echoes N | Slam canvas ops / frame (≈) | Particles spawned (6×N) | BFS visits UB (N × 336) |
|---:|---:|---:|---:|
| 8 | ~50 + full board | 48 | ~2.7k |
| 16 | ~90 + full board | 96 | ~5.4k |
| 28 | ~150 + full board | 168 | ~9.4k |
| 40 (`mirror_v_then_h` / long buffer) | ~210 + full board | 240 | ~13k |
| Invert halo (~path×4) | same + denser | up to ~240+ | **~47k** visits UB |

Commit hitch is front-loaded: N sequential `_bfs_goal_open` calls before the first slam frame, plus `Juice.rewrite_punch` (hitstop timescale + flash) and N×`spawn_burst` Dictionary allocs.

Hitstop lowers `Engine.time_scale` to ~0.06 for 90 ms while Juice advances on wall-clock — good for feel, but the **draw path still runs every rendered frame** at full cost.

### Fixes

1. **Batch solvability** — one BFS / flood-fill coloring from player (or bidirectional) marking cells that are *bridge-critical*; accept candidates in one pass instead of N BFS. Target **≤ 1 BFS + O(candidates)** per rewrite (budget ≤ 4 ms on Deck CPU).
2. **Cap / stage slam draw** — if N > 24, draw staggered subsets or bake folding into 2–3 MultiMesh/texture passes; keep telegraph readable.
3. **Shorten or LOD slam under battery / reduce_motion** — already 0.05 s when reduce-motion; also shorten when `DeckProfile.battery_mode`.
4. **Defer particle spawn** across 2–3 frames (ring buffer) so commit frame stays under budget.
5. Softlock recovery already strips newest-first — keep, but reuse the same reachability scratch buffers (see §5).

**Acceptance:** rewrite commit script time ≤ 4 ms p95 on Deck; no frame > 33 ms during slam at 7 W.

---

## 3. Particles

### What exists

`Juice` keeps `particles: Array` of **Dictionaries**. Update path mutates by value copy + `remove_at` (O(n) shifts). No cap, no pool, no typed struct.

```112:156:game/echo_lattice/scripts/juice.gd
func spawn_burst(world_pos: Vector2, color: Color, count: int = 8) -> void:
	for i in range(count):
		particles.append({ ... })  # heap Dictionary per speck

func _update_particles(real_dt: float) -> void:
	# remove_at(i) while iterating — shifts tail each death
```

Spawn rates:

| Event | Count |
|---|---|
| Rewrite (default) | **6 × pending echoes** |
| Rewrite (reduce_motion) | 2 × N |
| Win | +10 |
| Blocked bump | flash/shake only |

Juice bible (`07_JUICE.md`) called for a **ring pool ≥ 800** with steal-oldest. RC1 Godot port did not implement that. Draft `VfxPool` on `cursor/echo-lattice-perf` is **not wired** into `chamber.gd`.

Particles live on the **Juice autoload**, so they outlive chamber `queue_free` and keep `_process` work until life expires (see §7).

### Fixes

1. Replace Dictionary particles with a **PackedFloat32Array / pool of structs** (pos, vel, life, color, size) + free-list index; cap **200** live (align with perf draft).
2. `remove` via swap-with-last (no `remove_at` shifts).
3. `Juice.clear_particles()` on stage change / chamber load.
4. Under battery / reduce_fx: max 1 burst node or ≤ 8 specks total per rewrite.
5. Optional: stop drawing particles in `chamber._draw` — give Juice a tiny CanvasItem child so chamber dirtying is independent.

**Acceptance:** rewrite never allocates in the particle hot path; live count ≤ 200; steal-oldest when capped.

---

## 4. BFS frequency

### Call sites (runtime)

| Site | When | Cost |
|---|---|---|
| `_would_still_be_reachable` | **Once per rewrite candidate** | Full grid BFS each |
| `_goal_reachable_now` / `_recover_softlock` | After flush / recovery loop | 1…N BFS |
| `_bfs_length` | On win (star par) | 1 BFS on **base map** (good) |
| `_compute_assist_path` | Ghost assist button | 1 BFS + path reconstruct |
| `_refresh_telegraph` | **Every frame** while buffer non-empty | Transform + scan; not BFS, but O(path + grid) |
| `_nearest_unused_checkpoint_dist` | Every telegraph refresh **and** every `_draw` telegraph | Full 24×14 scan **twice / frame** |

BFS implementation uses `Array.pop_front()` → **O(n)** per dequeue → effective queue ops can approach O(cells²) in adversarial fill order.

Assist / win BFS frequency is fine. **Rewrite candidate BFS** and **per-frame telegraph scans** are the problems.

### Fixes

1. Rewrite: single multi-source / bridge-finding pass (§2).
2. BFS queue: `PackedInt32Array` ring buffer (head/tail indices) encoding `y*W+x`; reuse `seen` as `PackedByteArray` cleared by generation counter (no Dictionary).
3. Cache `_nearest_unused_checkpoint_dist` until player moves or checkpoint fires.
4. Refresh telegraph **on move / undo / rewrite**, not every frame; pulse alpha can use `goal_pulse_t` without rebuilding cell lists.
5. Selftest already BFS-walks every chamber — keep; add a micro-bench that times `_trigger_rewrite` on a long invert path and asserts < 4 ms (skip if headless timing noisy).

**Acceptance:** zero BFS in steady `_process`; ≤ 1 BFS-equivalent per rewrite commit.

---

## 5. GC / allocations

### Hot allocators (steady or near-steady)

| Source | Rate | Notes |
|---|---|---|
| `ArtKit.draw_paper_grain` | 2× / redraw | `RandomNumberGenerator.new()` each call + thousands of rects |
| `AdaptiveMusic._process` | every frame | `layers_changed.emit(_layer_gains.duplicate())` + `intensity_changed` even when idle |
| `Juice.shake_offset` | every chamber draw | new `Dictionary` for dx/dy/rot |
| `Juice._update_particles` | while live | Dictionary value copy each particle |
| `AudioEvents.get_event` | every SFX | `.duplicate(true)` |
| `AudioManager._load_stream` | every play | `load(path)` with **no cache** (footsteps) |
| `_try_move` undo frame | each step | `checkpoints_triggered.duplicate(true)` + Dictionary frame |
| `_refresh_telegraph` | each process | new `seen` Dictionary + rebuilt `telegraph_cells` |
| `get_node_or_null("/root/…")` | juice/chamber helpers | pointer chase; cache in `_ready` |

### Fixes

1. Grain texture bake (§1) — largest win.
2. AdaptiveMusic: emit `layers_changed` / duplicate **only when gains change** by ε; skip `intensity_changed` if `|Δ| < 0.001`.
3. `shake_offset` → out-params or cached Vector3 / three floats.
4. Stream cache `Dictionary path → AudioStream` on `AudioManager` (and share with AdaptiveMusic).
5. `get_event` return const view or cache immutable copies; avoid deep duplicate per footstep.
6. Undo: store checkpoint snapshot only when a checkpoint state bit changes; otherwise store a generation id.
7. Preallocate BFS scratch on Chamber (`_bfs_seen`, `_bfs_q`, `_bfs_dist`).

**Acceptance:** after warm-up, 5 s idle chamber → ~0 Dictionary allocs / frame (Godot profiler / custom counter).

---

## 6. Deck 7 W / 4 W

### Spec (from `DeckProfile` + `STEAM_DECK.md`)

| Profile | FPS | TDP guidance | Code |
|---|---:|---:|---|
| Verified | 60 | **7 W** | `TARGET_FPS_VERIFIED`, vsync, fullscreen |
| Battery | 40 | **4 W** | `--battery` → `set_battery_mode(true)` |

TDP is **not** settable in-game (correct). Runtime caps FPS only.

### Risk assessment (reasoned)

- **7 W / 60:** Compatibility + thousands of CPU grain rects + full-grid redraw is the main threat to thermal headroom. Puzzle logic alone is cheap.
- **4 W / 40:** Cap helps; still want grain bake so clocks can drop without hitching on slam frames.
- Four always-decoding music layers (`AdaptiveMusic` L0–L3) add steady CPU; at silence-capped Induction chambers gains go to 0 but players may still be `playing` — verify streams pause when gain ≤ ε.
- Shipping **WAV + OGG** duplicates (~1.5 MB music WAV alone) inflates install; prefer OGG-only in release export.

### Fixes

1. Grain bake + dirty redraw (§1) before hardware Verified pass.
2. Pause muted music layers (`player.playing = false` when gain ≤ 0.001).
3. Export filter: exclude `*.wav` from Linux/Windows release when `.ogg` exists.
4. Optional Deck battery: further cut slam particles and disable menu ambient redraw when unfocused.
5. QA script: document `SteamDeck=1` + `--battery` fps log format in `STEAM_DECK.md` (link this audit).

**Acceptance:** same checklist as `STEAM_DECK.md` Verified section; attach fps/thermals traces to the release bugbash.

---

## 7. Memory leaks / scene reloads

### Scene graph

`Main._clear_stage` → `queue_free` all stage children, then **immediately** `instantiate` the next scene. One-frame overlap is normal; no `await` flush.

```744:747:game/echo_lattice/scripts/main.gd
func _clear_stage() -> void:
	for c in stage.get_children():
		c.queue_free()
```

### Findings

| Issue | Severity | Detail |
|---|---|---|
| Juice particles / trauma / flash survive stage swaps | Med | Autoload state; particles keep simulating; next chamber may draw stale specks if lifetimes overlap |
| `AudioDirector` follow-up `SceneTreeTimer` | Med | `fire(follow)` can run after leaving chamber (win queue-next, etc.) — usually desired, but can touch freed expectations |
| Menu `LocaleManager.locale_changed.connect(func…)` | Low–Med | Lambda each menu instance; Godot frees Object-bound callables on free, but prefer `CONNECT_ONE_SHOT` pattern or disconnect in `_exit_tree` |
| Settings overlay | OK | Child of menu/chamber; freed with parent |
| `ArtKit._cache` | OK | Bounded tile set; grows then stable |
| Chamber ↔ a11y `queue_redraw` signals | OK | Freed with chamber |
| AdaptiveMusic 4 players | OK | Intentional singletons |
| Undo stack / walked maps | OK | Cleared in `load_chamber` |
| Double catalog load | Low | `AudioEvents` parsed in AudioManager, AudioDirector, SilenceDirector separately |

Chamber `_exit_tree` correctly flushes pending echoes (anti-softlock) — good.

### Fixes

1. `Main._clear_stage`: call `Juice.reset_transient()` (clear particles, trauma, flash, hitstop restore).
2. `AudioDirector`: cancel / null-check follow-up timer on chamber change; keep win stingers explicit.
3. Menu / chamber_scene: disconnect locale / glyph signals in `_exit_tree`.
4. Optional: `await get_tree().process_frame` after free when swapping to heavy scenes (screenshot / QA paths already await).
5. Share one `AudioEvents` instance via autoload to avoid triple JSON parse.

**Acceptance:** 100× menu↔chamber↔won↔menu loop in `--selftest` (or dedicated `--reload-soak`) with stable `OS.get_static_memory_usage()` ± noise band.

---

## 8. Audio

### Architecture (good)

- Bus split Master / SFX / Music / UI / PA.
- SFX polyphony pool (10) + PA (3) + UI (1) — steal via ring index.
- Structured events in `audio_events.json`.
- SilenceDirector caps early-chamber intensity.

### Performance issues

1. **Uncached `load()` per SFX** — every footstep hits `ResourceLoader` path in `_load_stream`.
2. **`get_event` deep-duplicates** the JSON dictionary per fire (AudioDirector + AudioManager both may).
3. **AdaptiveMusic per-frame work** — recomputes gains, lerps volumes, emits signals + Dictionary duplicate even when intensity is flat.
4. **Four concurrent loop streams** — decode cost on Deck; muted layers should pause.
5. **WAV fallback path** allocates `PackedByteArray` + `AudioStreamWAV` when ogg missing — fine for tools, dangerous if release resolves to WAV often.
6. Habit audio: `_update_habit_audio` scans full grid for fossil density **every successful step** (O(cells)) — acceptable at step rate, not every frame (currently OK).

### Fixes

1. Stream cache + warm-load footstep / rewrite / UI set at boot.
2. Immutable event table; no per-play `duplicate(true)`.
3. Gate AdaptiveMusic emits; pause silent layers (§6).
4. Ensure export prefers `.ogg`; keep `.wav` as editor/tool only.
5. Consider footstep polyphony steal without restarting identical stream when pitch≈1 (optional).

**Acceptance:** 10 min play with music + footsteps shows flat SFX load time; Music callback CPU negligible in profiler.

---

## 9. Priority fix list

| P | Fix | Owner files | Unlocks |
|---|---|---|---|
| P0 | Bake paper grain; stop per-frame RNG rect spam | `art_kit.gd`, `chamber.gd`, `menu.gd` | 60 fps / 7 W |
| P0 | Dirty `queue_redraw` (chamber + menu) | `chamber.gd`, `menu.gd` | 60 fps idle |
| P1 | Rewrite single-pass solvability + ring BFS buffers | `chamber.gd` | Slam hitch |
| P1 | Juice particle pool + clear on stage swap | `juice.gd`, `main.gd` | GC + leaks |
| P1 | AdaptiveMusic emit/pause discipline | `adaptive_music.gd` | GC + 4 W CPU |
| P2 | Audio stream + event cache | `audio_manager.gd`, `audio_events.gd` | Footstep hitch |
| P2 | Telegraph / checkpoint dist cache | `chamber.gd` | Idle CPU |
| P2 | Reload soak + perf HUD / budgets | `main.gd`, optional `src/perf/*` | CI / Deck QA |
| P3 | Export strip WAVs; wire draft VfxPool if desired | export + optional merge from perf PR | Install size |

---

## 10. Validation plan (device / CI)

### Cloud / CI (no GPU)

- Extend `--selftest` with: grain texture present; rewrite on long-path chamber finishes &lt; timeout; Juice particle count ≤ cap after forced bursts; 50× stage swap memory sanity.
- Keep existing solvability BFS (correctness, not fps).

### Desktop

- Godot profiler: Script + CanvasItem on chamber idle, during rewrite, on menu.
- Watch `TIME_PROCESS`, `OBJECT_COUNT`, `MEMORY_STATIC`.

### Steam Deck

1. Native Linux, 7 W, vsync, 60 cap — daily wing; record fps min/avg.
2. `--battery`, 4 W — confirm no axis stick + readable slam.
3. Overlay open/close mid-slam — no softlock (already flushed on pause).
4. Compare before/after P0 grain bake (expected: largest fps lift).

---

## 11. Code map

| Area | Path |
|---|---|
| Chamber loop / slam / BFS | `game/echo_lattice/scripts/chamber.gd` |
| Stage reload | `game/echo_lattice/scripts/main.gd` |
| Juice / particles | `game/echo_lattice/scripts/juice.gd` |
| Grain helpers | `game/echo_lattice/scripts/art_kit.gd` |
| Deck FPS / TDP constants | `game/echo_lattice/scripts/deck_profile.gd` |
| Deck QA doc | `docs/RELEASE/STEAM_DECK.md` |
| Adaptive music | `game/echo_lattice/scripts/audio/adaptive_music.gd` |
| SFX pool | `game/echo_lattice/scripts/audio/audio_manager.gd` |
| Event catalog | `game/echo_lattice/scripts/audio/audio_events.gd` |
| Prior (unmerged) pool plan | `docs/ECHO_LATTICE/10_PERFORMANCE.md` on `cursor/echo-lattice-perf` |

---

## 12. Measurement appendix (synthetic)

```
grid                 24×14 = 336 cells
frame budget         16.67 ms @ 60 · 25 ms @ 40
grain rects / frame  ~4685 @ 960×560 (vp+page, p=0.18, step=6)
slam frames          0.90 × 60 ≈ 54
rewrite particles    6 × N Dictionaries (N pending echoes)
BFS UB               N × 336 cell visits (plus pop_front overhead)
AdaptiveMusic        ~60 Dictionary.duplicate/s from layers_changed alone
```

Re-run models after P0/P1 and replace this appendix with Deck traces.
