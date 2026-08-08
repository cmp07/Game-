// Hitstop-light: global timescale drop on impact, ramping back with easing.
//
// "Light" = short (60–140 ms), never fully zero. AAA games freeze fully; a
// small residual scale keeps things feeling alive without dropping input.

import { clamp, easeOutCubic } from "../engine/math";
import type { Timescale } from "../engine/loop";

export class Hitstop {
  private t = 0;
  private duration = 0;
  private floor = 0.06; // never fully zero: preserves particle continuity
  private queued = 0;

  constructor(private timescale: Timescale) {}

  /**
   * Request a hitstop.
   * @param seconds  duration of the freeze
   * @param floor    minimum timescale during freeze (0..1)
   */
  hit(seconds: number, floor = 0.06): void {
    // If a new hit is bigger, replace; otherwise stack a little.
    if (seconds > this.duration - this.t) {
      this.duration = seconds;
      this.t = 0;
      this.floor = floor;
    } else {
      this.queued = Math.min(0.08, this.queued + seconds * 0.4);
    }
  }

  /** Called every render frame with real (unscaled) dt. */
  update(realDt: number): void {
    if (this.duration <= 0 && this.queued > 0) {
      this.duration = this.queued;
      this.queued = 0;
      this.t = 0;
    }
    if (this.duration <= 0) {
      this.timescale.value = 1;
      return;
    }
    this.t += realDt;
    const p = clamp(this.t / this.duration, 0, 1);
    // Ease back from floor -> 1 with a small settle overshoot removed.
    const eased = easeOutCubic(p);
    this.timescale.value = this.floor + (1 - this.floor) * eased;
    if (p >= 1) {
      this.duration = 0;
      this.timescale.value = 1;
    }
  }
}
