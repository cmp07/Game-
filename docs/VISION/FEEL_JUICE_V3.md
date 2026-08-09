# Feel Juice V3 — Interaction Feel Bible

**Product:** Echo Lattice (Field Ledger)  
**Branch:** `cursor/vision-feel-v3`  
**Status:** Vision authority for *how interactions should feel* — frame-by-frame, expensive, document-game honest  
**Supersedes for feel intent:** historical Vite arena rules in [`../ECHO_LATTICE/07_JUICE.md`](../ECHO_LATTICE/07_JUICE.md) (keep that file as implementation archaeology; **this doc wins on feel**)  
**Companions:** [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) · [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md) · [`../ECHO_LATTICE/14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md)  
**Code anchors (today):** `game/echo_lattice/scripts/chamber.gd`, `juice.gd`, `audio/audio_director.gd`

---

## 0. North star

Echo Lattice is a **document game**, not a combat juice machine. Expensive feel comes from *punctuation with restraint*: every verb lands with weight, foreshadow, ceremony, and consequence — never from glow, shake spam, or slot-machine particles.

**Target read after one chamber:** *“This was authored.”* Not *“This was filtered.”*

### Five feel pillars (V3)

| # | Pillar | Player should feel | Fail state (cheap) |
|---|---|---|---|
| 1 | **Step weight** | Each grid step is a stamped decision on paper | Floaty WASD; silent tiles; same click for success and wall |
| 2 | **Buffer telegraph** | The last 30 moves are a readable promise before commit | Surprise walls; mystery HUD; cadmium everywhere |
| 3 | **Rewrite anticipation** | “It learned you” arrives *before* the slam | Instant fossil pop; warn only at impact; full-screen flash |
| 4 | **Win ecstasy** | Clear = resolve + hunger for the next page | Confetti; closed brass fanfare; dead end-card |
| 5 | **Fail clarity** | Softlocks, blocked steps, and bad rewrites explain themselves in ≤3 frames | Vague red flash; silent bump; “you died” without why |

### Non-negotiables (Field Ledger)

1. **No default screen-shake on rewrite.** Document games settle; physics games shake. Opt-in shake stays subtle.
2. **Cadmium ≤1%.** Reserved for ≤3-step warn ticks + single-frame margin heartbeat at slam start. Far telegraph = slate/chalk. Blocked-step flash = ink soft.
3. **Hitstop OK; bloom warp forbidden.** Short timescale dip sells mass; chromatic energy pulses do not.
4. **Dual channel always.** Sight + sound (or sight + pattern for a11y). Audio never sole telegraph.
5. **Reduce-motion / reduce-flash honor.** Skip heartbeat, shorten slam, keep outcome readable.

### Timing base

Assume **60 fps presentation**, **sim may run faster**. Slam is authored as **12 beats × 75 ms = 900 ms** (`REWRITE_DURATION = 0.90`). Frame tables below use **F0…** at 60 fps unless marked as slam beats.

| Unit | Duration | Use |
|---|---|---|
| Frame (60 Hz) | 16.67 ms | Step / UI / fail flashes |
| Slam beat | 75 ms (~4.5 frames) | Origami staging |
| Hitstop rewrite | 90 ms @ floor 0.06 | Held breath on commit |
| Commit cool-down | ≥350 ms | Anti-mash (do not shorten for “juice”) |

**Invariant:** VFX that sell *reaction* advance on **wall-clock**; board commit may pause under hitstop. Frozen VFX reads as lag.

---

## 1. Step weight

### Intent

A successful step should feel like a **rubber stamp hitting ledger paper** — dry, short, directional. A blocked step should feel like **bone against binding** — duller, lower, no chalk stamp.

### Frame chart — successful step (accept)

| Frame | Visual | Audio | Input / sim |
|---|---|---|---|
| **F0** | Player glyph snaps to new cell (no lerp >1 frame unless a11y hold-walk). Chalk footprint S0 stamps underfoot. | `sfx.footstep` — dry click; pitch jitter ±4%; habit pitch `lerp(1.0, 1.18, tension)` | Consume move; append buffer cell |
| **F1** | Floor underfoot commits S1 (`paper_deep` + faint stipple) if not already walked. Punch-card ribbon fills one cell. | Footstep tail already gone (<40 ms) | — |
| **F2–F3** | Ghost path dash extends one segment (1 px chalk, 60% opacity). Optional ink-dust: ≤3 particles, life ≤180 ms, **no additive glow**. | If `habit_tension ≥ 0.7` for 2+ consecutive steps: metallic overtone +7 st, −18 dB | — |
| **F4+** | Still paper. No pulse. No halo breathe. | Silence between steps is designed | Hold-to-walk: first repeat at 220 ms, then 80 ms |

### Frame chart — blocked step (reject)

| Frame | Visual | Audio | Juice |
|---|---|---|---|
| **F0** | Player stays put. **No** chalk stamp. Target wall cell gets 1-frame ink-soft edge flash (not cadmium). | `sfx.footstep_blocked` — lower, duller, −3 to −5 dB vs success | Optional micro-nudge ≤1 px toward wall, recover by F3 |
| **F1–F2** | Flash decays (`easeOutQuad`). Punch-card does **not** advance. | — | Trauma bump **forbidden** by default |
| **F3** | Board fully quiet again | — | If this is a self-trap after rewrite, arm undo teach toast (existing path) |

### Tuning knobs

| Knob | Expensive | Cheap |
|---|---|---|
| Step SFX length | 18–35 ms transient | >80 ms “thud carpet” |
| Success vs blocked | Distinct samples + pitch class | Same sample quieter |
| Particle count | 0–3 ink scuffs | Spark bursts / rings |
| Motion | Snap + optional 1 px settle | Smooth 120 ms slide every step |

### Acceptance — step weight

- [ ] Eyes closed: success vs blocked identifiable in one tap.
- [ ] Eyes open, muted: chalk stamp + ribbon fill vs ink edge flash still reads.
- [ ] 10 steps in a row never mask a rewrite warn.
- [ ] Grayscale: footprint / walked / wall / player remain distinct.

---

## 2. Buffer telegraph

### Intent

The move buffer is the **promise of the next fossil geometry**. Players should be able to pause mid-chamber and predict *where* the maze will thicken before a checkpoint fires.

### Layers (always co-present when buffer non-empty)

| Layer | Where | What it sells |
|---|---|---|
| **A. On-floor foreshadow** | Transformed buffer cells | Slate corner ticks (far); cadmium ticks only at ≤3 Manhattan to unused checkpoint |
| **B. Ghost path** | Dashed chalk of last ≤30 moves | Shape of authorship — diagram, not smear |
| **C. Punch-card ribbon** | Bottom page margin | Ordered verb history; warn cells escalate with tension |
| **D. Habit colonization** | Over-walked floors | Rust accrues between rewrites — ambient story, not telegraph of the *next* slam |

### Frame chart — buffer cell append (on each accepted step)

| Frame | Ribbon | Floor / ghost |
|---|---|---|
| **F0** | Next empty punch-card cell → filled (discrete stamp, not roll) | Ghost dash segment appears |
| **F1** | Cell ink settles (no bounce) | Telegraph cell list dirty-refresh; slate ticks if transform preview active |
| **F2+** | Static | No sin-pulse on ticks — tension via opacity / fill only |

### Frame chart — proximity arming (enter ≤3 steps of unused checkpoint)

| Frame | Visual | Audio | Notes |
|---|---|---|---|
| **F0** | Far slate ticks on doomed cells escalate: nearest ring → cadmium corner ticks | `sfx.rewrite_warn` (arm once per entry; re-arm on leave+reenter OK) | Dual channel mandatory |
| **F1–F6** | Ribbon warn cells engage; tension opacity climbs with distance 3→1 | Footstep pitch already rising with habit | No full-screen flash |
| **Hold** | Cadmium remains only on warn ticks + (later) slam heartbeat | Warn must not loop-spam; one-shot or ≥400 ms debounce if player dances the ring | Music may lean L2/L3; never mute SFX/PA |

### Distance → signal table

| Manhattan to unused checkpoint | Floor ticks | Ribbon | Audio |
|---|---|---|---|
| >3 | Slate / chalk foreshadow | Filled cells | Footsteps only |
| 3 | Cadmium corners appear | Warn cells | `rewrite_warn` on enter |
| 2 | Cadmium + slightly higher opacity | Warn | — |
| 1 | Max tension opacity (still no pulse) | Warn | Optional `pa.rewrite_armed` when checkpoint actually arms |
| 0 (on checkpoint) | Hand off to **Rewrite anticipation** | Seal / stamp | Checkpoint PA + stinger path |

### Acceptance — buffer telegraph

- [ ] Mute Music: warn + ribbon + ticks still teach the rewrite.
- [ ] Colorblind roles: player / floor / wall / fossil / checkpoint / goal / telegraph distinct.
- [ ] Cadmium pixel budget on a mid-buffer still ≈ ≤1% of frame.
- [ ] Ghost is 1 px dashed diagram — never a particle trail.

---

## 3. Rewrite anticipation

### Intent

The trailer beat. Anticipation is **longer than impact**. Players should feel the maze inhale before paper becomes stone.

### Phases

```
[proximity warn] → [checkpoint seal] → [heartbeat] → [12-beat origami slam] → [rust settle]
     ≥3 steps         ~1–3 frames         1 beat           900 ms                  hold
```

### Frame chart — checkpoint seal → slam start

| Time | Beat / frames | Visual | Audio / juice |
|---|---|---|---|
| **T+0 ms** | Seal | Checkpoint stamp prints on tile (`slate_teal`, faint rotation). Buffer ribbon locks (no new punches). Movement input hard-locks (restart still allowed). | `pa.rewrite_armed` / checkpoint line; Music duck begins |
| **T+0–70 ms** | Heartbeat (beat 0 / `REWRITE_HEARTBEAT`) | **One** cadmium paper-margin flash only — not full-screen, not tile flood. | Hitstop 90 ms @ 0.06 begins with punch; **no** default shake; **no** full-screen rewrite flash |
| **Beats 1–3** (0–225 ms) | Crease | S2 origami crease on doomed tiles; diagonal ink folds stagger per cell (~1 beat offset max) | Operator stinger earprint (`mirror` / `rotate` / …) — unique, laptop-readable |
| **Beats 4–6** (225–450 ms) | Lift | Cast shadow under lifting paper (**no rim light**). Title plate may show quiet `IT LEARNED YOU`. | Stinger body; Music ducked −3.5 to −4.5 dB ~400 ms |
| **Beats 7–9** (450–675 ms) | Slot | Walls slot to fossil; **1 px overshoot** then settle. Collision commits as solidity completes. | Soft paper-slot click (optional layer under stinger) |
| **Beats 10–12** (675–900 ms) | Rust bleed | Rust decals from joins; S3 persistent fossil walls. | Stinger tail dead; Music unduck |
| **T+900 ms** | Done | Slam pose clears; input unlocks; habit telegraph may update | `Juice.hitstop_ended` path free for next verb |

### Anticipation rules

1. **Wind-up ≥ impact.** Proximity warn (seconds of play) + heartbeat + crease outlast the slot bounce.
2. **Never glowy warp.** No screen-space distortion, colored energy pulse, or time-freeze bloom.
3. **Operator identity is audible.** Visual slam can be shared; earprint must differ per transform family.
4. **Shake is opt-in and tiny** (`rewrite_punch` segment-scaled, capped). Default trauma = 0 path.
5. **Reduce-flash:** skip heartbeat, keep crease→slot readable. **Reduce-motion:** skip/shorten slam; commit fossils immediately with a single discrete stamp frame.

### Acceptance — rewrite anticipation

- [ ] Trailer cut readable muted *and* with headphones: warn → heartbeat → slam.
- [ ] Cadmium appears at heartbeat and ≤3 warn — nowhere else in the slam.
- [ ] Self-made walls never trap via premature collision (spawn/solidity gate).
- [ ] Mid-slam only restart is legal (anti-softlock).

---

## 4. Win ecstasy

### Intent

Clearing a chamber is **filing a page**, not detonating a loot piñata. Ecstasy = short major resolve + an **open hungry interval** that makes Continue feel inevitable.

Art bible forbids confetti / juice fireworks on completion. The reward is the **shape you authored** + audio open loop.

### Frame chart — chamber clear

| Frame / time | Visual | Audio | Shell |
|---|---|---|---|
| **F0** | Goal tile accepts player. Goal copper plate may hold a **discrete stamp** (no breathe). Board freezes authorship silhouette (fossils + ghost remain). | `win.chamber` — short major resolve | `chamber_won` signal |
| **F1–F5** (≈80 ms) | Optional seed-header micro-stamp (discrete numeral for stars / par — stamped increments, not odometer). **No** particle fountain. | Gap before follow-up (~80 ms) | Input: advance / continue armed, not mash-fire restart |
| **F5+** | Queue-next visual: Continue affordance underlines rust; next chamber name as wayfinding type | `win.queue_next` — rising fourth → sharp leading tone that **cuts early** | Hunger, not brass |
| **≤1.2 s** | End card / next index-card paper-turn (never cross-fade through black) | Fanfare concat path (`win.fanfare`) only as compat | Wing clear uses longer `win.wing` + `pa.wing_clear` |

### Ecstasy do / don't

| Do | Don't |
|---|---|
| Resolve then open interval | Fully closed cadence that feels like “album over” |
| Show the fossil geometry you made | Hide the board behind a modal trophy |
| Stamp stars as discrete ink | Rolling score fireworks |
| Paper-turn to next chamber | Fade-to-purple void |

### Acceptance — win ecstasy

- [ ] First-time clear on laptop speakers: resolve readable; queue-next quieter/shorter than resolve.
- [ ] Muted: board silhouette + stamped stars + Continue still sell completion.
- [ ] No cadmium, no shake, no confetti on win path.
- [ ] Streamer Music-mute: win SFX still plays.

---

## 5. Fail clarity

### Intent

Failure is a **legible diagram correction**, not a jump-scare. In ≤3 frames the player should know: *what failed*, *why*, and *what verb undoes it*.

### Fail classes

| Class | Example | Must communicate |
|---|---|---|
| **Micro-fail** | Walk into wall | Blocked, not committed |
| **Soft fail** | Rewrite seals a dead-end; undo teach | You authored the trap; undo/restart available |
| **Hard fail / death** (if present in mode) | Hazards / quota blow | Cause + recovery; PA attention tone |
| **System fail** | Softlock assert recovery | Honest recovery; never silent teleport without signal |

### Frame chart — micro-fail (blocked step)

See §1 blocked chart. Clarity test: **cause cell** highlighted, **buffer unchanged**, **distinct SFX**.

### Frame chart — soft fail (self-trap after rewrite)

| Frame | Visual | Audio / UI |
|---|---|---|
| **F0** | First blocked step against self-fossil: ink-soft flash on contact cell | `sfx.footstep_blocked` |
| **F1** | Undo affordance arms (diegetic hint / toast — institutional, not cartoon) | Optional `pa.undo.hint` / subtitle |
| **F2–F3** | Hint stable; no red full-screen; no trauma spam | Player can undo or restart; slam lock already released |

### Frame chart — hard fail / attention (when mode uses it)

| Time | Visual | Audio |
|---|---|---|
| **F0** | Ink veil or stamp — **not** neon death; keep paper substrate | `pa.attention` |
| **F1–F8** | Cause glyph (quota / hazard) stamped once | Short sting <200 ms |
| **≤400 ms** | Recovery verbs highlighted (retry / load) | Music duck only; SFX/PA clear |

### Clarity rules

1. **Never cadmium for failure.** Cadmium means rewrite imminent, not pain.
2. **Never rely on shake** to signal fail (a11y + document tone).
3. **One cause, one highlight.** Multi-flash lists feel like bugs.
4. **Recovery verb ≤1 glance away** (undo, restart, continue). Softlock recovery must emit an honest signal (assert path / telemetry OK; player-facing: board returns to solvable with a stamp, not a silent edit).

### Acceptance — fail clarity

- [ ] New player hits a post-rewrite trap: understands undo without reading a wiki.
- [ ] Colorblind + muted: blocked vs warn vs win still distinct by pattern/placement.
- [ ] Fail flash peak ≤ ink soft; duration ≤3 frames at full strength.
- [ ] No fail path reintroduces full-screen cadmium.

---

## 6. Composite timeline — “expensive chamber second”

Ideal one-second slice crossing warn → step → (not yet slam):

| ms | Pillar | Event |
|---|---|---|
| 0 | Buffer | Cadmium tick visible; ribbon warn cell lit |
| 0–35 | Step | Footstep success + chalk stamp |
| 35–80 | Buffer | Ghost + ribbon update settle |
| 80–200 | Anticipation | Tension held — paper still, music lean |
| — | — | *(checkpoint later triggers §3 full slam)* |

Ideal clear slice:

| ms | Pillar | Event |
|---|---|---|
| 0 | Win | Goal stamp + `win.chamber` |
| 80 | Win | `win.queue_next` cuts early |
| 80–400 | Win | Continue underline; fossils held |

---

## 7. Global order of operations (feel-critical)

Align implementation with this ownership (Godot RC1):

```
on_input_step:
  1. reject if slam-locked / won-locked
  2. blocked? → fail clarity micro path → return
  3. accept step → step weight (audio + chalk + ribbon)
  4. dirty telegraph → buffer telegraph refresh
  5. proximity ≤3? → arm warn (once) 
  6. checkpoint? → rewrite anticipation → juice.rewrite_punch + slam

on_win:
  1. freeze authorship silhouette
  2. win ecstasy audio follow-up chain
  3. paper-turn shell — no confetti

render (wall-clock):
  1. juice particles / flash / optional shake decay
  2. chamber draw: paper → walls → fossils → ghost → telegraph → player
  3. diegetic margins: seed header + punch-card
  4. slam overlay only while pending_echoes settle
```

---

## 8. Relationship to older juice docs

| Source | Treat as |
|---|---|
| [`07_JUICE.md`](../ECHO_LATTICE/07_JUICE.md) Vite pulsar arena | Historical; hitstop/trauma math still useful; enemy telegraphs **not** product |
| Art bible §5 rewrite moment | Visual law — V3 adds frame clocks + fail/win pillars |
| Audio bible §8 | Ear law — V3 binds them to frames |
| `juice.gd` Field Ledger punch | Implementation — change numbers here first when feel drifts |

**Conflict rule:** If a juice impulse fights ink-on-paper, **paper wins**.

---

## 9. Implementation checklist (when leaving cloud-only)

Cloud agents authoring this bible do **not** require code lands. When a feel pass ships:

1. Diff `chamber.gd` slam phases against §3 beat table.
2. Diff footstep / blocked / warn / win events against §1 / §2 / §4.
3. Confirm cadmium reserve with a grayscale + palette audit capture.
4. Play Mirror Birth muted and with Music muted separately.
5. Update [`07_JUICE.md`](../ECHO_LATTICE/07_JUICE.md) header to point here as feel authority (keep Vite section labeled historical).

---

## 10. One-line tuning mantra

> **Stamp the step, publish the buffer, inhale before the fold, resolve then hunger, and when it fails, circle the cause.**
