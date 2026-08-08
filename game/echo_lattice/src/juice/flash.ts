// Full-screen impact flash. Short additive-white pulse on impact/rewrite.
// Uses easeOutQuint so it lands hard, then fades fast.

import { clamp, easeOutQuint } from "../engine/math";

export class Flash {
  private t = 0;
  private duration = 0;
  private strength = 0;
  private color = "255,255,255";

  fire(seconds: number, strength: number, rgb?: string): void {
    if (seconds > this.duration - this.t || strength > this.currentAlpha()) {
      this.duration = seconds;
      this.t = 0;
      this.strength = strength;
      if (rgb) this.color = rgb;
    }
  }

  update(realDt: number): void {
    if (this.duration <= 0) return;
    this.t += realDt;
    if (this.t >= this.duration) {
      this.duration = 0;
      this.t = 0;
    }
  }

  private currentAlpha(): number {
    if (this.duration <= 0) return 0;
    const p = clamp(this.t / this.duration, 0, 1);
    return this.strength * (1 - easeOutQuint(p));
  }

  draw(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    const a = this.currentAlpha();
    if (a <= 0.001) return;
    ctx.save();
    ctx.globalCompositeOperation = "screen";
    ctx.fillStyle = `rgba(${this.color}, ${a.toFixed(3)})`;
    ctx.fillRect(0, 0, w, h);
    ctx.restore();
  }
}
