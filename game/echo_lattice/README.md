# Echo Lattice — juice showcase

A tiny top-down arena vignette focused on **feel**. The player walks; walking
drops echo footsteps. Press **Space** to *rewrite* — every consecutive pair of
footsteps solidifies into a wall segment, spraying particles and shocking the
screen. Enemy pulsars telegraph strikes; hits use hitstop and screen shake.

Design doc: [`docs/ECHO_LATTICE/07_JUICE.md`](../../docs/ECHO_LATTICE/07_JUICE.md).

## Run

```
cd game/echo_lattice
npm install
npm run dev
```

Open `http://localhost:5173`.

## Controls

- `WASD` / arrow keys — move
- `Space` — REWRITE (commit trail into walls)
- `Shift` — dash (i-frames)
- `R` — reset arena
- `P` — toggle post-processing (chromatic aberration / vignette / grain)

## Files

- `src/engine/` — loop (fixed-step, hitstop-aware), input, math, RNG
- `src/juice/` — hitstop, screen shake, flash
- `src/render/` — camera (spring-damper), particles, post-fx
- `src/world/` — arena, walls, footsteps, telegraphs, enemy, player

## Notes

- 120 Hz fixed simulation timestep; rendering interpolates.
- Timescale is a shared object; hitstop scales sim time only — VFX keep
  breathing so the freeze reads as *punctuation*, not *lag*.
- All post-fx are canvas-2D (no WebGL) so the demo runs anywhere.

This is a **juice pass** — no meta layer, no level progression, no run
economy. It exists to lock in feel before the real Echo Lattice loop is
wired on top.
