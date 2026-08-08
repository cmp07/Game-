// Fixed-step accumulator loop with support for a global timescale.
//
// Timescale is how hitstop is implemented: dt fed to sim is scaled by
// `scale.value`. Rendering interpolates and uses real dt so effects (screen
// shake, post) keep animating even when sim is frozen.

export interface Timescale {
  value: number;
}

export interface LoopFns {
  fixed: (dt: number) => void;
  render: (alpha: number, realDt: number) => void;
}

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
    let safety = 8;
    while (acc >= STEP && safety-- > 0) {
      fns.fixed(STEP);
      acc -= STEP;
    }
    const alpha = acc / STEP;
    fns.render(alpha, realDt);
    raf = requestAnimationFrame(frame);
  };

  raf = requestAnimationFrame(frame);
  return () => {
    stopped = true;
    cancelAnimationFrame(raf);
  };
}
