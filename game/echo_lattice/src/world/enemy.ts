// Hazard node — a stationary "pulsar" that periodically telegraphs a strike
// zone at (or near) the player. It's just enough of an antagonist to sell
// the telegraph + hitstop cycle; not a full enemy AI.

import { TAU, v2, type Vec2 } from "../engine/math";
import { rng } from "../engine/random";
import type { Telegraphs } from "./telegraph";

export class Pulsar {
  pos: Vec2;
  private cooldown = 0;
  private cadence: number;
  private radius: number;
  private range: number;

  constructor(x: number, y: number, cadence = 2.6, radius = 70, range = 160) {
    this.pos = v2(x, y);
    this.cadence = cadence;
    this.radius = radius;
    this.range = range;
    this.cooldown = rng.range(0.6, cadence);
  }

  update(dt: number, playerPos: Vec2, telegraphs: Telegraphs): void {
    this.cooldown -= dt;
    if (this.cooldown <= 0) {
      // Aim near the player, with a small lead offset so dodging works.
      const dx = playerPos.x - this.pos.x;
      const dy = playerPos.y - this.pos.y;
      const l = Math.hypot(dx, dy);
      const nx = l > 1e-4 ? dx / l : 0;
      const ny = l > 1e-4 ? dy / l : 0;
      const d = Math.min(l, this.range);
      const tx = this.pos.x + nx * d + rng.range(-14, 14);
      const ty = this.pos.y + ny * d + rng.range(-14, 14);
      telegraphs.add(tx, ty, this.radius, 0.75, 0.28, 8);
      this.cooldown = this.cadence + rng.range(-0.35, 0.35);
    }
  }

  draw(ctx: CanvasRenderingContext2D, now: number): void {
    const r = 10 + Math.sin(now * 2.4) * 1.5;
    ctx.save();
    // Halo
    const grad = ctx.createRadialGradient(
      this.pos.x,
      this.pos.y,
      2,
      this.pos.x,
      this.pos.y,
      r * 3.2,
    );
    grad.addColorStop(0, "rgba(255,120,120,0.7)");
    grad.addColorStop(0.4, "rgba(255,80,80,0.25)");
    grad.addColorStop(1, "rgba(255,80,80,0)");
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(this.pos.x, this.pos.y, r * 3.2, 0, TAU);
    ctx.fill();

    // Core
    ctx.fillStyle = "rgba(255,220,220,0.95)";
    ctx.beginPath();
    ctx.arc(this.pos.x, this.pos.y, r * 0.55, 0, TAU);
    ctx.fill();

    // Iris ring
    ctx.strokeStyle = "rgba(255,180,180,0.85)";
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.arc(this.pos.x, this.pos.y, r, 0, TAU);
    ctx.stroke();
    ctx.restore();
  }
}
