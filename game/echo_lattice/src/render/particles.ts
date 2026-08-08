// Pooled particle system tuned for readable, layered VFX bursts.
//
// Two kinds of primitives are enough for the whole game:
//   - "dot"   : soft additive circles (sparks, embers, dust)
//   - "ring"  : expanding stroked circles (shockwaves)
//   - "glyph" : small rotating quad (echo mote / rune fragment)
//
// AAA-indie feel comes from mixing 3–5 tiny bursts per event with different
// lifetimes, sizes, and easing — never a single monolithic puff.

import { clamp, TAU } from "../engine/math";
import { rng } from "../engine/random";

export type ParticleKind = "dot" | "ring" | "glyph";

export interface Particle {
  alive: boolean;
  kind: ParticleKind;
  x: number;
  y: number;
  vx: number;
  vy: number;
  drag: number;
  life: number;
  maxLife: number;
  size: number;
  sizeGrow: number;
  rot: number;
  vrot: number;
  color: string; // "r,g,b"
  glow: number;  // additive multiplier (0..1)
}

const POOL_SIZE = 800;

export class Particles {
  private pool: Particle[] = [];
  private cursor = 0;

  constructor() {
    for (let i = 0; i < POOL_SIZE; i++) {
      this.pool.push({
        alive: false,
        kind: "dot",
        x: 0,
        y: 0,
        vx: 0,
        vy: 0,
        drag: 0,
        life: 0,
        maxLife: 0,
        size: 0,
        sizeGrow: 0,
        rot: 0,
        vrot: 0,
        color: "255,255,255",
        glow: 1,
      });
    }
  }

  private next(): Particle {
    // Ring-allocate — oldest slots recycled first when saturated.
    for (let i = 0; i < POOL_SIZE; i++) {
      this.cursor = (this.cursor + 1) % POOL_SIZE;
      const p = this.pool[this.cursor];
      if (!p.alive) return p;
    }
    return this.pool[this.cursor];
  }

  spawnDot(opts: Partial<Particle>): void {
    const p = this.next();
    p.alive = true;
    p.kind = "dot";
    p.x = opts.x ?? 0;
    p.y = opts.y ?? 0;
    p.vx = opts.vx ?? 0;
    p.vy = opts.vy ?? 0;
    p.drag = opts.drag ?? 2;
    p.maxLife = opts.maxLife ?? 0.5;
    p.life = p.maxLife;
    p.size = opts.size ?? 2;
    p.sizeGrow = opts.sizeGrow ?? 0;
    p.rot = 0;
    p.vrot = 0;
    p.color = opts.color ?? "220,230,255";
    p.glow = opts.glow ?? 1;
  }

  spawnRing(opts: Partial<Particle>): void {
    const p = this.next();
    p.alive = true;
    p.kind = "ring";
    p.x = opts.x ?? 0;
    p.y = opts.y ?? 0;
    p.vx = 0;
    p.vy = 0;
    p.drag = 0;
    p.maxLife = opts.maxLife ?? 0.6;
    p.life = p.maxLife;
    p.size = opts.size ?? 4;
    p.sizeGrow = opts.sizeGrow ?? 180;
    p.rot = 0;
    p.vrot = 0;
    p.color = opts.color ?? "180,220,255";
    p.glow = opts.glow ?? 0.9;
  }

  spawnGlyph(opts: Partial<Particle>): void {
    const p = this.next();
    p.alive = true;
    p.kind = "glyph";
    p.x = opts.x ?? 0;
    p.y = opts.y ?? 0;
    p.vx = opts.vx ?? 0;
    p.vy = opts.vy ?? 0;
    p.drag = opts.drag ?? 1.2;
    p.maxLife = opts.maxLife ?? 0.7;
    p.life = p.maxLife;
    p.size = opts.size ?? 4;
    p.sizeGrow = opts.sizeGrow ?? -4;
    p.rot = rng.angle();
    p.vrot = rng.range(-6, 6);
    p.color = opts.color ?? "200,240,255";
    p.glow = opts.glow ?? 1;
  }

  /** Convenience — burst of sparks. */
  burstSparks(
    x: number,
    y: number,
    n: number,
    speed: number,
    color = "230,240,255",
  ): void {
    for (let i = 0; i < n; i++) {
      const a = rng.angle();
      const s = rng.range(speed * 0.5, speed);
      this.spawnDot({
        x,
        y,
        vx: Math.cos(a) * s,
        vy: Math.sin(a) * s,
        maxLife: rng.range(0.3, 0.6),
        size: rng.range(1.4, 2.6),
        sizeGrow: -3,
        drag: 3,
        color,
        glow: 1,
      });
    }
  }

  /** Convenience — echo mote burst (used on rewrite at each footstep). */
  burstEcho(x: number, y: number, color = "170,230,255"): void {
    for (let i = 0; i < 5; i++) {
      const a = rng.angle();
      const s = rng.range(40, 110);
      this.spawnGlyph({
        x,
        y,
        vx: Math.cos(a) * s,
        vy: Math.sin(a) * s,
        maxLife: rng.range(0.35, 0.7),
        size: rng.range(3, 5),
        color,
      });
    }
    this.spawnRing({
      x,
      y,
      size: 3,
      sizeGrow: 130,
      maxLife: 0.4,
      color,
    });
  }

  update(dt: number): void {
    for (let i = 0; i < POOL_SIZE; i++) {
      const p = this.pool[i];
      if (!p.alive) continue;
      p.life -= dt;
      if (p.life <= 0) {
        p.alive = false;
        continue;
      }
      // Semi-implicit drag.
      const d = Math.exp(-p.drag * dt);
      p.vx *= d;
      p.vy *= d;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.vrot * dt;
      p.size += p.sizeGrow * dt;
      if (p.size < 0) p.size = 0;
    }
  }

  draw(ctx: CanvasRenderingContext2D): void {
    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    for (let i = 0; i < POOL_SIZE; i++) {
      const p = this.pool[i];
      if (!p.alive) continue;
      const t = clamp(p.life / p.maxLife, 0, 1);
      const alpha = (t < 0.2 ? t / 0.2 : 1) * (0.85 * t + 0.15);
      const a = alpha * p.glow;
      const rgb = p.color;

      if (p.kind === "dot") {
        const g = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.size * 3);
        g.addColorStop(0, `rgba(${rgb},${(a * 0.95).toFixed(3)})`);
        g.addColorStop(0.4, `rgba(${rgb},${(a * 0.35).toFixed(3)})`);
        g.addColorStop(1, `rgba(${rgb},0)`);
        ctx.fillStyle = g;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size * 3, 0, TAU);
        ctx.fill();
      } else if (p.kind === "ring") {
        ctx.strokeStyle = `rgba(${rgb},${a.toFixed(3)})`;
        ctx.lineWidth = Math.max(0.5, 2 * t);
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, TAU);
        ctx.stroke();
      } else {
        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.rot);
        ctx.fillStyle = `rgba(${rgb},${a.toFixed(3)})`;
        ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size);
        ctx.strokeStyle = `rgba(${rgb},${(a * 0.6).toFixed(3)})`;
        ctx.lineWidth = 1;
        ctx.strokeRect(-p.size / 2, -p.size / 2, p.size, p.size);
        ctx.restore();
      }
    }
    ctx.restore();
  }
}
