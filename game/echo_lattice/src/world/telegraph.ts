// Telegraph / foreshadow zones.
//
// The three-phase attack telegraph is the AAA-indie readability trick:
//   1) WIND-UP  : draw dim outline that grows in weight
//   2) COMMIT   : outline snaps thick + pulsating, small pre-shake tick
//   3) STRIKE   : shape flashes solid, hitstop + shake + damage
//
// Each Telegraph shape is a circle at (x, y). Duration budget:
//   windUpTime + strikeTime = total lifetime. The zone auto-removes.

import { clamp, easeOutCubic, easeOutQuint, TAU } from "../engine/math";

export type TelegraphPhase = "windup" | "strike" | "done";

export interface Telegraph {
  x: number;
  y: number;
  radius: number;
  age: number;
  windUp: number;
  strike: number;
  phase: TelegraphPhase;
  fired: boolean;
  hue: number;
}

export class Telegraphs {
  zones: Telegraph[] = [];

  add(
    x: number,
    y: number,
    radius: number,
    windUp: number,
    strike: number,
    hue = 12,
  ): Telegraph {
    const z: Telegraph = {
      x,
      y,
      radius,
      age: 0,
      windUp,
      strike,
      phase: "windup",
      fired: false,
      hue,
    };
    this.zones.push(z);
    return z;
  }

  clear(): void {
    this.zones.length = 0;
  }

  /**
   * Advance zones. `onFire(z)` is called once when a zone enters STRIKE.
   * Zones remove themselves after strike ends.
   */
  update(
    dt: number,
    onFire: (z: Telegraph) => void,
  ): void {
    for (let i = this.zones.length - 1; i >= 0; i--) {
      const z = this.zones[i];
      z.age += dt;
      if (z.phase === "windup" && z.age >= z.windUp) {
        z.phase = "strike";
        z.fired = true;
        onFire(z);
      }
      if (z.phase === "strike" && z.age >= z.windUp + z.strike) {
        z.phase = "done";
      }
      if (z.phase === "done") {
        this.zones.splice(i, 1);
      }
    }
  }

  draw(ctx: CanvasRenderingContext2D, now: number): void {
    for (const z of this.zones) {
      const total = z.windUp + z.strike;
      const p = clamp(z.age / total, 0, 1);
      const hue = z.hue;

      if (z.phase === "windup") {
        const wp = clamp(z.age / z.windUp, 0, 1);
        // Two overlapping rings: outer dashed rotating, inner filling.
        ctx.save();
        // Wind-up floor pulse
        const grad = ctx.createRadialGradient(z.x, z.y, 0, z.x, z.y, z.radius);
        grad.addColorStop(0, `hsla(${hue}, 90%, 60%, ${(0.06 + 0.18 * wp).toFixed(3)})`);
        grad.addColorStop(1, `hsla(${hue}, 90%, 60%, 0)`);
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.arc(z.x, z.y, z.radius, 0, TAU);
        ctx.fill();

        // Outer rotating dashed ring
        ctx.setLineDash([6, 8]);
        ctx.lineDashOffset = -now * 30;
        ctx.strokeStyle = `hsla(${hue}, 90%, 70%, ${(0.35 + 0.4 * wp).toFixed(3)})`;
        ctx.lineWidth = 1.4;
        ctx.beginPath();
        ctx.arc(z.x, z.y, z.radius, 0, TAU);
        ctx.stroke();

        // Inner filling arc — visualizes the timer.
        ctx.setLineDash([]);
        ctx.strokeStyle = `hsla(${hue}, 90%, 78%, ${(0.5 + 0.4 * wp).toFixed(3)})`;
        ctx.lineWidth = 2 + wp * 2;
        ctx.beginPath();
        ctx.arc(z.x, z.y, z.radius * 0.78, -Math.PI / 2, -Math.PI / 2 + TAU * easeOutCubic(wp));
        ctx.stroke();

        // Center crosshair — pre-tick shudder in last 15%
        const sh = wp > 0.85 ? (wp - 0.85) / 0.15 : 0;
        const jx = sh * (Math.sin(now * 90) * 1.4);
        const jy = sh * (Math.cos(now * 87) * 1.4);
        ctx.strokeStyle = `hsla(${hue}, 90%, 88%, ${(0.4 + 0.5 * wp).toFixed(3)})`;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(z.x - 5 + jx, z.y + jy);
        ctx.lineTo(z.x + 5 + jx, z.y + jy);
        ctx.moveTo(z.x + jx, z.y - 5 + jy);
        ctx.lineTo(z.x + jx, z.y + 5 + jy);
        ctx.stroke();
        ctx.restore();
      } else if (z.phase === "strike") {
        const sp = clamp((z.age - z.windUp) / z.strike, 0, 1);
        const flash = 1 - easeOutQuint(sp);
        ctx.save();
        // Solid strike disc (fades quickly).
        const grad2 = ctx.createRadialGradient(z.x, z.y, 0, z.x, z.y, z.radius);
        grad2.addColorStop(0, `hsla(${hue}, 100%, 80%, ${(0.55 * flash).toFixed(3)})`);
        grad2.addColorStop(0.7, `hsla(${hue}, 100%, 60%, ${(0.35 * flash).toFixed(3)})`);
        grad2.addColorStop(1, `hsla(${hue}, 100%, 50%, 0)`);
        ctx.fillStyle = grad2;
        ctx.beginPath();
        ctx.arc(z.x, z.y, z.radius, 0, TAU);
        ctx.fill();

        // Outgoing ring
        ctx.strokeStyle = `hsla(${hue}, 100%, 88%, ${(0.9 * flash).toFixed(3)})`;
        ctx.lineWidth = 2 + 2 * flash;
        ctx.beginPath();
        ctx.arc(z.x, z.y, z.radius * (0.9 + 0.3 * sp), 0, TAU);
        ctx.stroke();

        ctx.restore();
      }
      // Cheat the compiler about `p` used only for future variants.
      void p;
    }
  }
}
