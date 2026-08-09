# Echo Lattice — 07 · JUICE (v2 · Godot)

**Status:** JUICE v2 ships inside the Godot 4.3 playable vertical slice at [`game/echo_lattice/`](../../game/echo_lattice/).
**Target feel:** AAA-indie — every input has a punctuated, layered response
(sight + weight + timescale) without becoming a slot machine.
**Engine:** Godot 4.3 (GDScript). The earlier Vite/TS juice pass
(`cursor/echo-lattice-juice-946c`) locked the ratios; this document is the
Godot port + playable-loop wiring.

This document is the tuning rulebook. When something feels off, the fix is
almost always in here: change a number, don't invent a new system.

---

## 0. What changed in v2

| | Vite juice pass (v1) | Godot JUICE v2 |
|---|---|---|
| Host | Vite + canvas-2D demo | Godot 4.3 desktop project |
| Loop | Free-roam arena + Space rewrite | Playable chambers: move → checkpoint → rewrite → goal |
| Footsteps → walls | Distance-gated trail, Space commit | Ghost path since checkpoint → telegraph foreshadow → echo walls |
| Telegraph | Pulsar enemies | Wall-birth foreshadow + ambient lattice pulses in rewrite chambers |
| Modules | `src/juice/*`, `src/render/*` | `scripts/juice/*` + `JuiceDirector` autoload |

Run:

```bash
cd game/echo_lattice
godot --path .
# headless:
godot --headless --path . -- --selftest
```

---

## 1. The six juice pillars

| # | Pillar | Module(s) | What it sells |
|---|---|---|---|
| 1 | **Screen feel** | [`screenshake.gd`](../../game/echo_lattice/scripts/juice/screenshake.gd), [`flash.gd`](../../game/echo_lattice/scripts/juice/flash.gd) | Trauma² shake + event-driven full-screen flash |
| 2 | **Particles on rewrite** | [`particles.gd`](../../game/echo_lattice/scripts/juice/particles.gd) | Shockwave rings, spark bursts, per-cell echo glyphs on wall birth |
| 3 | **Telegraph foreshadow** | [`telegraphs.gd`](../../game/echo_lattice/scripts/juice/telegraphs.gd) | Three-phase wind-up → strike on pending echo cells + ambient lattice pulses |
| 4 | **Hitstop-light** | [`hitstop.gd`](../../game/echo_lattice/scripts/juice/hitstop.gd) | `Engine.time_scale` floor ≈0.06 for 60–140 ms, `easeOutCubic` recovery |
| 5 | **Camera ease** | [`camera_spring.gd`](../../game/echo_lattice/scripts/juice/camera_spring.gd) | Critically-damped spring + velocity lookahead + zoom-punch on rewrite |
| 6 | **Footstep-trail → walls** | [`chamber.gd`](../../game/echo_lattice/scripts/chamber.gd) + JuiceDirector | Ghost trail commits through telegraphed cascade into echo walls |

Coordinator: [`juice_director.gd`](../../game/echo_lattice/scripts/juice/juice_director.gd) (autoload `JuiceDirector`).

---

## 2. Timescale architecture (why hitstop is *the* pillar)

`JuiceDirector` separates **sim time** from **real time**.

- `Engine.time_scale` is driven by `JuiceHitstop.timescale` every frame.
- Chamber `_process(delta)` receives **scaled** dt → wall birth / telegraphs / particles slow with the freeze.
- Shake, flash, and camera spring advance on **wall-clock** dt from `Time.get_ticks_usec()` so the frame keeps breathing during hitstop.

Hitstop budgets (same as v1):

| Event | duration | floor | flash | shake |
|---|---|---|---|---|
| Rewrite commit | 0.09 s | 0.06 | 0.28 s / 0.55 | 0.20 + 0.03 × segments (cap 0.55) |
| Player struck (lattice pulse) | 0.12 s | 0.05 | 0.20 s / 0.80 (red) | 0.55 |
| Near-miss | 0.03–0.06 s | 0.15 | 0.09 s / 0.15–0.30 (amber) | 0.06–0.16 |
| Footstep dust | — | — | — | — (tiny particle only) |

Rule of thumb: **hitstop scales with intent, not damage.** A rewrite is the
player's authored moment; it earns a mid-tier freeze even without an enemy.

---

## 3. Screen shake — trauma model

Squirrel Eiserloh's *trauma* model. `trauma ∈ [0, 1]`, decays at 1.35 /s;
amplitude is `trauma² × maxAmplitude × noise`. Max translation 14 px, max
rotation 3°. Applied in `Chamber._draw` as a view transform.

---

## 4. Particles on rewrite

800-slot ring pool, three primitives: **dot / ring / glyph**.

On rewrite commit (`JuiceDirector.on_rewrite_commit`):

1. Two nested shockwave rings at the player (320 / 220 px/s growth).
2. 22 high-speed sparks.
3. Per wall-birth strike: `burst_echo` (5 glyphs + ring) at that cell.

Footsteps also emit a tiny dust dot so movement itself has a heartbeat.

---

## 5. Telegraph foreshadow — three-phase

| Phase | Duration | Visual |
|---|---|---|
| **Wind-up** | 0.22 + 0.02×index s (walls) / 0.75 s (ambient pulse) | Dim radial, rotating dashed ring, filling arc, crosshair jitter in last 15% |
| **Strike** | 0.22 / 0.28 s | Solid disc + outgoing ring |
| **Done** | — | Removed |

**Wall birth:** each pending echo cell gets a staggered telegraph; on strike the
cell becomes `ECHO_WALL` (non-solid during wind-up so the player can't trap
themselves mid-ceremony).

**Ambient lattice pulses:** in chambers with a non-`none` transform, a pulse
telegraphs near the player on a ~2.6 s cadence. Hit → red flash + hard hitstop;
near-miss → amber micro-stop. Disabled under `DisplayServer == headless` so
self-tests stay deterministic.

---

## 6. Camera ease — spring-damper + lookahead

```
stiffness = 90
damping   = 20          # critically damped ≈ 2*sqrt(k)
lookahead_gain = 0.14
```

Discrete grid moves synthesize a short-lived velocity for lookahead.
Rewrite sets `target_zoom = 0.94` and recovers with `damp(_, 1, 4, dt)`.

Camera runs on **real** dt (see §2).

---

## 7. Footstep-trail → walls — the diegetic loop

In the playable Godot loop:

1. Every successful step appends to `moves_since_checkpoint` (ghost trail).
2. Crossing a checkpoint runs the chamber transform on that path.
3. Solvable candidates become `pending_echoes`.
4. Juice fires rewrite commit FX; each candidate gets a telegraph.
5. On telegraph strike → `ECHO_WALL` + `burst_echo` particles.
6. Fallback settle (0.55 s) solidifies any leftover cells (self-test / undo call `_flush_pending_echoes` immediately).

This is the mechanic-that-is-juice: the world's geometry is a fossil of the
player's path, and commit is a costed ceremony.

---

## 8. Global order of operations (per frame)

```
JuiceDirector._process (real dt):
  hitstop.update → Engine.time_scale
  shake.update → flash.update
  camera.recover_zoom → camera.follow(player)

Chamber._process (scaled dt):
  JuiceDirector.update_sim → telegraphs + particles
  handle fired telegraphs → birth walls / pulse hit tests
  fallback pending-echo settle
  ambient lattice pulse cadence
  queue_redraw

Chamber._draw:
  bg wash
  apply camera zoom/pos + shake (+ small rot)
  tiles → ghost trail → pending fills → player
  JuiceDirector.draw_fx (telegraphs + particles)
  flash overlay
```

---

## 9. Tuning surface (single place)

| Knob | Where | Default |
|---|---|---|
| Hitstop rewrite | `juice_director.gd` `on_rewrite_commit` | 0.09 / 0.06 |
| Shake decay | `screenshake.gd` | 1.35 /s |
| Shake max | `screenshake.offset` | 14 px / 3° |
| Camera spring | `camera_spring.gd` | k=90, d=20 |
| Lookahead | `camera_spring.gd` | 0.14 |
| Wall telegraph wind-up | `foreshadow_wall_birth` | 0.22 + 0.02×i |
| Particle pool | `particles.gd` | 800 |
| Ambient pulse cadence | `chamber.gd` `_pulse_cooldown` | 2.6 s |

---

## 10. Verification

```bash
cd game/echo_lattice
godot --headless --path . -- --selftest
# must print juice unit result: OK and result: OK
```

Unit coverage in [`scripts/tests/test_juice.gd`](../../game/echo_lattice/scripts/tests/test_juice.gd):
hitstop floor/recovery, trauma decay, flash envelope, camera spring + punch,
particle bursts, telegraph three-phase, easings.

---

## 11. What this is *not*

- Not the Vite demo (that PR stays historical).
- Not audio (AUDIO v2 owns buses/stingers; trim flash strength when SFX land).
- Not a full content expansion — juice rides the existing 10-chamber playable loop.
