// Wall segments — line-segment collision + rendering.
//
// Walls have a birth time so we can animate them "in" on rewrite: a wall
// only reaches full solidity after its birth animation completes. This is
// what makes the moment of REWRITE feel like a real event, not a state flip.

import { clamp, distPointSegment, easeOutCubic, TAU, v2, type Vec2 } from "../engine/math";

export interface Wall {
  a: Vec2;
  b: Vec2;
  bornAt: number;
  spawnDur: number;
  hue: number;
}

export class Walls {
  segments: Wall[] = [];

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

  /** Solidity 0..1 based on age; walls are only collidable when solidity >= 1. */
  solidity(w: Wall, now: number): number {
    return clamp((now - w.bornAt) / w.spawnDur, 0, 1);
  }

  /**
   * Resolve a circle against wall segments — returns adjusted position.
   * Not perfect physics; a positional projection sufficient for a juice demo.
   */
  resolveCircle(pos: Vec2, radius: number, now: number): Vec2 {
    const out = v2(pos.x, pos.y);
    const closest = v2();
    for (const w of this.segments) {
      if (this.solidity(w, now) < 1) continue;
      const d = distPointSegment(out, w.a, w.b, closest);
      const min = radius + 2; // wall thickness fudge
      if (d < min) {
        const nx = out.x - closest.x;
        const ny = out.y - closest.y;
        const l = Math.hypot(nx, ny);
        if (l < 1e-6) continue;
        const push = min - d;
        out.x += (nx / l) * push;
        out.y += (ny / l) * push;
      }
    }
    return out;
  }

  draw(ctx: CanvasRenderingContext2D, now: number): void {
    for (const w of this.segments) {
      const s = this.solidity(w, now);
      const grow = easeOutCubic(s);

      // Extrude the segment from its midpoint so it "unfurls" on birth.
      const mx = (w.a.x + w.b.x) / 2;
      const my = (w.a.y + w.b.y) / 2;
      const ax = mx + (w.a.x - mx) * grow;
      const ay = my + (w.a.y - my) * grow;
      const bx = mx + (w.b.x - mx) * grow;
      const by = my + (w.b.y - my) * grow;

      const hue = w.hue;
      // Outer glow
      ctx.save();
      ctx.strokeStyle = `hsla(${hue}, 90%, 62%, ${(0.14 * s).toFixed(3)})`;
      ctx.lineWidth = 10;
      ctx.lineCap = "round";
      ctx.beginPath();
      ctx.moveTo(ax, ay);
      ctx.lineTo(bx, by);
      ctx.stroke();

      // Core line
      ctx.strokeStyle = `hsla(${hue}, 80%, 78%, ${(0.9 * s).toFixed(3)})`;
      ctx.lineWidth = 2.2;
      ctx.lineCap = "round";
      ctx.beginPath();
      ctx.moveTo(ax, ay);
      ctx.lineTo(bx, by);
      ctx.stroke();

      // Endcap nodes
      const r = 3;
      ctx.fillStyle = `hsla(${hue}, 90%, 82%, ${(0.9 * s).toFixed(3)})`;
      ctx.beginPath();
      ctx.arc(ax, ay, r, 0, TAU);
      ctx.arc(bx, by, r, 0, TAU);
      ctx.fill();
      ctx.restore();
    }
  }
}
