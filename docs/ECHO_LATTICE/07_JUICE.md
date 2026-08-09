# Echo Lattice — 07 · JUICE

**Status:** juice pass shipped as a runnable slice at [`game/echo_lattice/`](../../game/echo_lattice/).
**Target feel:** AAA-indie — every input has a punctuated, layered response
(sight + weight + timescale) without becoming a slot machine.

This document is the tuning rulebook. When something feels off, the fix is
almost always in here: change a number, don't invent a new system.

### Field Ledger overrides (Godot RC1 — authoritative)

The Vite/TS arena juice below is **historical**. Playable Godot Echo Lattice
follows [`05_ART_BIBLE.md`](05_ART_BIBLE.md) Wing I (Field Ledger):

| Rule | Godot behavior |
|---|---|
| No screen-shake on rewrite | `Juice.rewrite_punch` skips trauma unless the player opts into shake (default **off**, intensity **0.35**) |
| Cadmium ≤1% | Reserved for ≤3-step telegraph warn + slam **margin** heartbeat; telegraph far ticks are slate; blocked-step flash is ink |
| Operator earprints | `AudioEvents.rewrite_event_id` aliases `mirror_v` / `rotate_180` / … → catalog stingers |
| Diegetic HUD | Chamber top seed header + bottom punch-card ribbon (not glass overlays) |
| Hitstop OK | Rewrite still gets a short hitstop; origami slam carries the spectacle |

---

## 1. The six juice pillars

| # | Pillar | Module(s) | What it sells |
|---|---|---|---|
| 1 | **Screen feel** | [`juice/screenshake.ts`](../../game/echo_lattice/src/juice/screenshake.ts), [`render/post.ts`](../../game/echo_lattice/src/render/post.ts), [`juice/flash.ts`](../../game/echo_lattice/src/juice/flash.ts) | The frame *is* alive: subtle grain, vignette, chromatic bleed, and event-driven full-screen flash. |
| 2 | **Particles on rewrite** | [`render/particles.ts`](../../game/echo_lattice/src/render/particles.ts), [`world/footsteps.ts`](../../game/echo_lattice/src/world/footsteps.ts) | Every footstep pops when the lattice commits; a shockwave ring + spark burst punctuates the whole gesture. |
| 3 | **Telegraph foreshadow** | [`world/telegraph.ts`](../../game/echo_lattice/src/world/telegraph.ts), [`world/enemy.ts`](../../game/echo_lattice/src/world/enemy.ts) | Three-phase warning zones — wind-up → strike, with a rotating dashed ring, filling arc, pre-tick jitter, and a final flash. |
| 4 | **Hitstop-light** | [`juice/hitstop.ts`](../../game/echo_lattice/src/juice/hitstop.ts), [`engine/loop.ts`](../../game/echo_lattice/src/engine/loop.ts) | Global sim timescale drops to a floor (≈0.05–0.06) for 60–140 ms on impacts and eases back with `easeOutCubic`. Never fully zero. |
| 5 | **Camera ease** | [`render/camera.ts`](../../game/echo_lattice/src/render/camera.ts) | Critically-damped spring follow with velocity lookahead; small zoom-punch on rewrite. |
| 6 | **Footstep-trail → walls** | [`world/footsteps.ts`](../../game/echo_lattice/src/world/footsteps.ts), [`world/walls.ts`](../../game/echo_lattice/src/world/walls.ts) | The trail is diegetic memory. `Space` commits it into wall segments that unfurl from their midpoints. |

---

## 2. Timescale architecture (why hitstop is *the* pillar)

The loop separates **sim time** from **real time**.

```16:29:game/echo_lattice/src/engine/loop.ts
export function startLoop(fns: LoopFns, timescale: Timescale): () => void {
  const STEP = 1 / 120; // sim runs at 120 Hz for tight feel
  const MAX_ACCUM = 0.25; // spiral-of-death guard
  let last = performance.now() / 1000;
  let acc = 0;
  let raf = 0;
  let stopped = false;

  const frame = () => {
    if (stopped) return;
    const now = performance.now() / 1000;
    const realDt = Math.min(now - last, MAX_ACCUM);
    last = now;

    // Scale advances sim time; if scale is tiny (hitstop) accumulator moves
    // slowly so state updates stall while the render loop still ticks.
    acc += realDt * timescale.value;
```

- The fixed timestep is 1/120 s. High tick rate matters because footsteps drop
  based on distance and telegraphs strike on frame boundaries. At 60 Hz sim you
  can miss a single-frame telegraph strike from lag or hitstop; at 120 Hz you can't.
- `timescale.value` is written by [`Hitstop`](../../game/echo_lattice/src/juice/hitstop.ts).
  It never reaches 0; the *floor* keeps particles legible during the freeze and
  keeps the world feeling responsive if the user starts moving during a hit.
- **Real dt** is what drives shake, flash, post-fx, and the camera. That is the
  rule: **anything that reads as "the world reacts" must run on real time**.
  Hitstop that also freezes VFX reads as *lag*, not *impact*.

Recommended hitstop budgets (already in code):

| Event | duration | floor | flash | shake |
|---|---|---|---|---|
| Rewrite commit | 0.09 s | 0.06 | 0.28 s / 0.55 | 0.20 + 0.03 × segments (cap 0.55) |
| Player struck | 0.12 s | 0.05 | 0.20 s / 0.80 (red) | 0.55 |
| Near-miss | 0.03–0.06 s | 0.15 | 0.09 s / 0.15–0.30 (amber) | 0.06–0.16 |
| Dash | *(no hitstop)* | — | — | 0.16 |

Rule of thumb: **hitstop scales with intent, not damage.** A rewrite is the
player's authored moment; it earns a mid-tier freeze even without an enemy.

---

## 3. Screen shake — trauma model

Squirrel Eiserloh's *trauma* model. `trauma ∈ [0, 1]`, decays at a constant
rate; shake amplitude is `trauma² × maxAmplitude × noise`.

```24:34:game/echo_lattice/src/juice/screenshake.ts
  update(realDt: number): void {
    this.t += realDt;
    // Constant decay per second — feels punchy without lingering.
    this.trauma = clamp(this.trauma - realDt * 1.35, 0, 1);
  }

  /** Returns [dx, dy, rotationRadians] to apply pre-render. */
  offset(maxPx = 14, maxRotDeg = 3): [number, number, number] {
    const s = this.trauma * this.trauma; // exponent = 2 (feels less mushy)
    const f = this.t * 42;
    const dx = maxPx * s * noise1(this.seed + 1, f);
```

Why `trauma²`:
- Linear shake feels *soft* — it never quite calms down.
- Squared shake spends most of its energy in the first ~30% of decay and then
  dies fast. That reads as **snap**.

Tuning knobs:
- **`bump` amount** — the user-facing dial. Only touch this per-event.
- **Decay rate** (1.35 /s) — the "character" dial. Bigger = punchier and drier;
  smaller = looser and cinematic. AAA-indie sits around 1.2–1.5.
- **maxPx / maxRotDeg** — capped so even a full trauma of 1 doesn't nauseate.

Rotation ratio is deliberately small (3° max at trauma 1). Rotation is what
sells "impact" but is also what makes players motion-sick fastest.

---

## 4. Particles on rewrite

The particle system is dumb-fast — three primitives, ring-allocated pool,
`lighter` compositing so everything glows additively.

The **rewrite** moment is where particles peak. In one commit the game emits:

1. **Per-footstep**: 5 rotating glyphs + 1 small ring (via `burstEcho`) at
   *each* footstep. This is the "the past turns solid" beat.
2. **At the player**: two nested large rings (shockwave, 320 px/s and 220 px/s
   growth), plus 22 high-speed sparks.
3. **Cascade timing**: walls are added with a 20 ms stagger per index. The
   line sweeps forward from the player's start-of-trail instead of appearing
   all at once. This is why the moment reads *cinematic* rather than *flash-cut*.

```61:70:game/echo_lattice/src/world/footsteps.ts
  commit(walls: Walls, particles: Particles, now: number, hue = 210): number {
    if (this.steps.length < 2) return 0;
    let count = 0;
    for (let i = 0; i < this.steps.length - 1; i++) {
      const a = this.steps[i];
      const b = this.steps[i + 1];
      walls.add(a.pos, b.pos, now + i * 0.02, hue); // slight cascade
      particles.burstEcho(a.pos.x, a.pos.y, "170,235,255");
      count++;
    }
```

Design constraints:
- **Never one big puff.** AAA-indie feel comes from *layers*: a burst =
  sparks + glyphs + a ring, each with a different lifetime and easing.
- **Direction of travel.** Glyphs drift outward from footsteps; the shockwave
  ring expands from the player; sparks radiate. Three different motion
  vectors, one event.
- **Pool cap ≥ 800.** Under sustained mashing you should never see a burst
  drop particles. Recycle oldest-first (ring cursor).

---

## 5. Telegraph foreshadow — the three-phase attack

Every hostile action goes through the same anatomy. Consistency is what makes
readability *feel* fair.

| Phase | Duration | Visual | Audio-equivalent visual cue |
|---|---|---|---|
| **Wind-up** | 0.6–0.9 s (`0.75` default) | Dim radial gradient, rotating dashed outer ring, filling arc timer, center crosshair | *tick, tick, tick* — 15% pre-strike jitter on the crosshair |
| **Strike** | 0.2–0.35 s (`0.28` default) | Solid gradient disc that decays with `easeOutQuint`, outgoing ring | *thump* |
| **Done** | — | Removed from list | — |

```88:94:game/echo_lattice/src/world/telegraph.ts
      if (z.phase === "windup") {
        const wp = clamp(z.age / z.windUp, 0, 1);
        // Two overlapping rings: outer dashed rotating, inner filling.
        ctx.save();
        // Wind-up floor pulse
        const grad = ctx.createRadialGradient(z.x, z.y, 0, z.x, z.y, z.radius);
        grad.addColorStop(0, `hsla(${hue}, 90%, 60%, ${(0.06 + 0.18 * wp).toFixed(3)})`);
```

Rules:
1. **Wind-up ≥ 3× strike duration.** Players need time to plan, not to react.
2. **Wind-up must communicate three things**: *where* (position/shape), *how big*
   (radius), and *when* (progress). We do all three with one figure: a radial
   floor pulse (where + how big) and a filling arc (when).
3. **A pre-strike tick.** In the last 15% of wind-up the crosshair jitters. This
   is a purely visual "beat before the drop"; players start dodging on it.
4. **Even on a miss you get feedback.** [`onTelegraphStrike`](../../game/echo_lattice/src/engine/game.ts)
   fires a small shake + amber flash + micro-hitstop for near-misses. Rewarding
   the *dodge* is a major AAA-indie tell.

---

## 6. Camera ease — spring-damper + lookahead

The camera is a critically-damped spring targeting `player + lookahead(velocity)`.

```20:38:game/echo_lattice/src/render/camera.ts
  // Spring params — critically damped (2*sqrt(k)).
  stiffness = 90;
  damping = 20;
  lookaheadGain = 0.14;
  lookaheadEase = 6;

  constructor(private width: number, private height: number) {}

  follow(target: Vec2, playerVel: Vec2, dt: number): void {
    this.target.x = target.x;
    this.target.y = target.y;

    // Ease lookahead toward player velocity direction.
    this.lookahead.x = damp(
      this.lookahead.x,
      playerVel.x * this.lookaheadGain,
      this.lookaheadEase,
      dt,
    );
```

Why spring over exp-damp:
- **Two dials**: stiffness (how snappy) and damping (how much overshoot).
  Exponential damping only gives you one. Under-damping the camera by 15% is
  the difference between "professional" and "sluggish."
- **Velocity lookahead** puts the world *slightly* where the player is going.
  Gain of 0.14 = camera leads by ~14% of one second of velocity.

Zoom-punch on rewrite:
- On commit the target zoom drops to `0.94` (6% out).
- It recovers on `damp(_, 1, 4, dt)` per render frame — sub-second.
- The zoom-out is subtle enough to be subliminal; the *recovery back to 1.0*
  is what actually reads as the "settling breath" after the moment.

Camera runs on **real** dt, so it keeps easing even when the sim is frozen by
hitstop. That's why the world feels alive during the freeze.

---

## 7. Footstep-trail → walls — the diegetic loop

This is the mechanic-that-is-juice.

- The player drops a footstep every `FOOTSTEP_DIST = 26` world units, offset
  perpendicular to velocity (alternating side). Dropping is distance-gated,
  not time-gated, so slow walking and dashing produce the same footprint
  density.
- Between footsteps a faint dashed thread (`setLineDash([3, 5])`, phase
  animated) **previews** what will become walls. This is the *foreshadow of
  the foreshadow* — the player can see the shape of the lattice before
  committing it.
- The most recent footstep pulses (`arc` with `sin(now * 6)`), signaling
  "commit-anchor."
- On `Space` (rewrite), the segments cascade into life via [`Walls.add`](../../game/echo_lattice/src/world/walls.ts) with
  a 20 ms per-segment stagger. Each wall grows from its midpoint outward,
  eased with `easeOutCubic`. During that 0.35 s spawn animation the wall is
  **not collidable** — collision starts at solidity = 1. This prevents the
  player being popped out of a wall they created around themselves.

```20:32:game/echo_lattice/src/world/walls.ts
  add(a: Vec2, b: Vec2, now: number, hue = 210): void {
    this.segments.push({
      a: { x: a.x, y: a.y },
      b: { x: b.x, y: b.y },
      bornAt: now,
      spawnDur: 0.35,
      hue,
    });
  }

  clear(): void {
    this.segments.length = 0;
  }
```

Why footsteps → walls feels good:
- **The player is the author.** The world's geometry is a fossil of their
  path, not level design.
- **Commit is a costed verb.** Every rewrite blows out particles, shake,
  flash, and hitstop; you *feel* the mass being converted from memory to
  matter. This is the AAA-indie punctuation the mechanic needs.
- **The un-drawn thread is a promise.** Dashed connectors between footsteps
  read as "this will happen." Players build spatial plans in that preview,
  and rewrite becomes an act of commitment — juice earns its keep because it
  marks the ceremony.

Failure modes to guard against:
- **Ghost walls locking the player in.** Fixed by non-solid spawn animation.
- **Trail overrun.** `MAX_STEPS = 64` in [`world/footsteps.ts`](../../game/echo_lattice/src/world/footsteps.ts) — old prints
  quietly slide off. If you raise this, also raise particle pool.

---

## 8. Global order of operations (per frame)

```
fixed(dt):
  1. input polling                     (edges + held)
  2. dash                              → shake + particles
  3. player.update                     (movement)
  4. arena + wall collision            (positional projection)
  5. footsteps.drop (distance-gated)   → tiny dust particle
  6. rewrite (Space)                   → footsteps.commit
                                       → walls.add (staggered)
                                       → shake + flash + hitstop + zoom-punch
                                       → shockwave rings + spark burst
  7. pulsars.update                    → telegraphs.add on cadence
  8. telegraphs.update                 → onTelegraphStrike
                                         → sparks + ring
                                         → if hit: player.hit + big shake + red flash + hitstop
                                         → if near miss: micro-shake + amber flash + micro-stop
  9. particles.update

render(alpha, realDt):
  1. hitstop.update  (writes timescale)
  2. shake.update    (decay trauma)
  3. flash.update    (advance timer)
  4. camera.follow   (spring + lookahead, on real dt)
  5. scene.draw (arena → walls → footsteps → telegraphs → enemies → player → particles)
  6. post.present    (chroma + vignette + scanlines + grain)
  7. flash.draw      (full-screen additive pulse)
  8. death veil
```

Two invariants:
- **Simulation reads scaled dt; anything called from `render` reads real dt.**
- **Draw order is stage-back-to-front:** ambient (arena) → committed geometry
  (walls) → in-flight intent (footsteps + telegraphs) → actors (enemies + player)
  → sparks. Particles last so they blow over everything.

---

## 9. Tuning tables — the one place to change numbers

If you touch feel, prefer editing these constants over adding systems.

### 9.1 Time / cadence
| Constant | File | Value | Effect |
|---|---|---|---|
| Fixed sim step | `engine/loop.ts` | `1/120` | Higher = smoother telegraphs, more CPU. |
| Hitstop (rewrite) | `engine/game.ts` | `0.09 s @ floor 0.06` | Feel: rewrite as a *held breath*. |
| Hitstop (hit) | `engine/game.ts` | `0.12 s @ floor 0.05` | Feel: hard smack. |
| Wind-up default | `world/enemy.ts` | `0.75 s` | Larger = more forgiving. |
| Strike duration | `world/enemy.ts` | `0.28 s` | Danger frame window. |
| Wall spawn anim | `world/walls.ts` | `0.35 s` | Delay before collidable. |
| Footstep distance | `world/footsteps.ts` | `26 px` | Density of lattice ribs. |
| Commit cooldown | `engine/game.ts` | `0.35 s` | Prevents mashing. |

### 9.2 Amplitude
| Constant | File | Value | Effect |
|---|---|---|---|
| Shake decay | `juice/screenshake.ts` | `1.35 /s` | Snap vs. cinematic. |
| Shake max px | `juice/screenshake.ts` | `14` | Cap on nausea. |
| Shake max rot | `juice/screenshake.ts` | `3°` | Cap on nausea (mostly). |
| Chromatic aberration | `render/post.ts` | `1.4 px` | Ambient RGB split. |
| Vignette | `render/post.ts` | `0.55` | Focal darkness at edges. |
| Grain | `render/post.ts` | `0.05` | Film weight. |
| Camera stiffness | `render/camera.ts` | `90` | Snap. |
| Camera damping | `render/camera.ts` | `20` | Overshoot control. |
| Lookahead gain | `render/camera.ts` | `0.14` | Bias toward direction of travel. |
| Zoom-punch | `engine/game.ts` | `0.94` | Rewrite "breath." |

### 9.3 Palette
| Event | Color (r,g,b) | Rationale |
|---|---|---|
| Rewrite / footsteps / walls | `160,225,255` (cool cyan) | *You* — authored, memory, cold. |
| Player halo | `190,230,255` | Belongs to you. |
| Telegraphs / pulsars | `hsl(8..12, 90%, ~65%)` (orange-red) | Danger. |
| Near-miss flash | `255,220,180` (amber) | Praise for dodge without a full alarm. |
| Grain | overlay of gray noise | Filmic tension, not decoration. |

Never use the danger palette on player VFX. The **only** exception is a hit,
and that's a red flash — one frame's worth.

---

## 10. What's intentionally *not* here

- **Sound.** Real audio would land the feel much harder. Every visual "tick"
  (telegraph pre-shake, rewrite ring, wall birth, hit flash) is authored so
  a `<beep>` or `<thud>` can be dropped in without new logic. When audio
  lands, the flash strengths should probably drop 20% — audio subsumes some
  of the current visual load.
- **Rumble / controller vibration.** Same story: hooks are ready
  (`hitstop.hit`, `shake.bump`) — no new state needed.
- **Level design.** This slice is a bare arena. Once feel is locked, real
  Echo Lattice levels get authored on top of exactly this layer.
- **Enemy variety.** One `Pulsar` type is enough to test the telegraph +
  hitstop cycle. New enemies just push different telegraph shapes into the
  same three-phase pipeline; no new juice code.
- **Persistent player state / progression.** Out of scope for a juice pass.

---

## 11. Manual QA checklist

Run these before calling the juice pass "shipped." All should feel *good*, not
just work.

- [ ] **Rewrite feels like a decision, not a button.**
  Layered particles + hitstop + zoom + flash + shake fire together on Space.
- [ ] **A rewrite with 20+ footsteps doesn't produce twice the shake of one
      with 4.** Shake bump is capped at 0.55.
- [ ] **Player never gets trapped inside a wall they just made.** Walls are
      non-collidable during their 0.35 s spawn animation.
- [ ] **You can dodge a pulsar strike on reflex from the pre-strike jitter.**
      Last 15% of wind-up must telegraph audibly-visually.
- [ ] **Near-miss dodges are rewarded.** Micro-shake + amber flash + tiny hitstop.
- [ ] **Hit doesn't feel like a bug.** Red flash + big shake + 0.12 s freeze.
- [ ] **Post-fx toggle (`P`) makes the game look worse, not better.** If it
      doesn't, the raw scene rendering is over-styled — pull chroma/vignette
      strength down.
- [ ] **Sustained mashing of Space at max trail never drops particles.**
- [ ] **60 Hz monitor and 144 Hz monitor feel the same.** Fixed timestep +
      real-dt render decouples visuals from tick rate.

---

## 12. File map

```
game/echo_lattice/
  index.html
  package.json  tsconfig.json  vite.config.ts
  README.md     .gitignore
  src/
    main.ts
    engine/
      game.ts          # composition root + frame lifecycle
      loop.ts          # fixed-step + timescale-aware accumulator
      input.ts         # keyboard w/ semantic axes + edge detection
      math.ts          # vec2 + easings + segment distance
      random.ts        # seedable xorshift32
    juice/
      hitstop.ts       # sim timescale ramp
      screenshake.ts   # trauma model
      flash.ts         # full-screen additive pulse
    render/
      camera.ts        # spring-damper follow + lookahead + zoom punch
      particles.ts     # dot / ring / glyph pool
      post.ts          # chroma + vignette + scanlines + grain
    world/
      arena.ts         # floor + grid + boundary
      walls.ts         # segment birth + collision
      footsteps.ts     # trail + rewrite commit
      telegraph.ts     # three-phase warning zones
      enemy.ts         # pulsar hazard
      player.ts        # movement + dash + i-frames
```
