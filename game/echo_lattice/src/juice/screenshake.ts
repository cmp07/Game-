// Trauma-model screen shake (Squirrel Eiserloh style):
// perturbation = trauma^exponent * maxAmplitude * noise
// Trauma decays at a constant rate. Angle + offset both driven by noise.

import { clamp } from "../engine/math";

function noise1(seed: number, t: number): number {
  // Cheap 1D value noise using sines; deterministic and smooth-enough for
  // a shake. Real perlin/simplex is overkill here.
  const s = Math.sin(seed * 12.9898 + t * 78.233) * 43758.5453;
  return (s - Math.floor(s)) * 2 - 1;
}

export class ScreenShake {
  private trauma = 0;
  private t = 0;
  private seed = Math.random() * 1000;

  /** Add trauma (0..1). Additive; clamps at 1. */
  bump(amount: number): void {
    this.trauma = clamp(this.trauma + amount, 0, 1);
  }

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
    const dy = maxPx * s * noise1(this.seed + 2, f);
    const r = ((maxRotDeg * Math.PI) / 180) * s * noise1(this.seed + 3, f);
    return [dx, dy, r];
  }
}
