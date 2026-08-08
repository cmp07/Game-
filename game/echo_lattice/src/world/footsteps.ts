// Footsteps trail — the *echo lattice* mechanic.
//
// While walking, a footstep is dropped every FOOTSTEP_DIST world units on the
// alternating side of the player's velocity. Each footstep is a floating
// "ghost" glyph. They shimmer softly.
//
// On REWRITE (Space), every consecutive pair of footsteps is *committed*
// into a wall segment (with a per-segment birth animation, see Walls).
// After rewrite the trail is cleared so the player can lay a new lattice.

import { clamp, TAU, v2, type Vec2 } from "../engine/math";
import type { Particles } from "../render/particles";
import type { Walls } from "./walls";

export interface Footstep {
  pos: Vec2;
  side: 1 | -1;
  bornAt: number;
  angle: number;
}

const FOOTSTEP_DIST = 26;   // world units between prints
const MAX_STEPS = 64;

export class Footsteps {
  steps: Footstep[] = [];
  private lastDropAt: Vec2 | null = null;
  private toggle: 1 | -1 = 1;

  drop(pos: Vec2, velAngle: number, now: number): boolean {
    if (this.lastDropAt) {
      const dx = pos.x - this.lastDropAt.x;
      const dy = pos.y - this.lastDropAt.y;
      if (dx * dx + dy * dy < FOOTSTEP_DIST * FOOTSTEP_DIST) return false;
    }
    // Offset perpendicular to velocity so prints stagger left/right.
    const perpX = Math.cos(velAngle + Math.PI / 2) * 5 * this.toggle;
    const perpY = Math.sin(velAngle + Math.PI / 2) * 5 * this.toggle;
    this.steps.push({
      pos: v2(pos.x + perpX, pos.y + perpY),
      side: this.toggle,
      bornAt: now,
      angle: velAngle,
    });
    if (this.steps.length > MAX_STEPS) this.steps.shift();
    this.lastDropAt = v2(pos.x, pos.y);
    this.toggle = this.toggle === 1 ? -1 : 1;
    return true;
  }

  clear(): void {
    this.steps.length = 0;
    this.lastDropAt = null;
    this.toggle = 1;
  }

  /**
   * Commit trail into walls. Pairs consecutive footsteps into segments and
   * emits echo particles at each footstep on the way.
   */
  commit(walls: Walls, particles: Particles, now: number, hue = 210): number {
    if (this.steps.length < 2) return 0;
    let count = 0;
    for (let i = 0; i < this.steps.length - 1; i++) {
      const a = this.steps[i];
      const b = this.steps[i + 1];
      walls.add(a.pos, b.pos, now + i * 0.02, hue); // slight cascade
      particles.burstEcho(a.pos.x, a.pos.y, "170,235,255");
      count++;
    }
    particles.burstEcho(
      this.steps[this.steps.length - 1].pos.x,
      this.steps[this.steps.length - 1].pos.y,
      "170,235,255",
    );
    this.clear();
    return count;
  }

  draw(ctx: CanvasRenderingContext2D, now: number): void {
    for (const s of this.steps) {
      const age = now - s.bornAt;
      // Steps pulse in on birth, hold, then breathe.
      const born = clamp(age / 0.2, 0, 1);
      const breathe = 0.85 + Math.sin(now * 3 + s.pos.x * 0.05) * 0.15;

      ctx.save();
      ctx.translate(s.pos.x, s.pos.y);
      ctx.rotate(s.angle);
      const alpha = 0.55 * born * breathe;
      ctx.strokeStyle = `rgba(160,220,255,${alpha.toFixed(3)})`;
      ctx.fillStyle = `rgba(140,210,255,${(alpha * 0.25).toFixed(3)})`;
      ctx.lineWidth = 1;
      // Diamond-shaped print
      ctx.beginPath();
      ctx.moveTo(0, -4);
      ctx.lineTo(3, 0);
      ctx.lineTo(0, 4);
      ctx.lineTo(-3, 0);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Inner tick
      ctx.strokeStyle = `rgba(200,240,255,${(alpha * 1.1).toFixed(3)})`;
      ctx.beginPath();
      ctx.moveTo(-1.2, 0);
      ctx.lineTo(1.2, 0);
      ctx.stroke();

      ctx.restore();
    }

    // Faint connecting thread (the "lattice ghost" — foreshadows what will
    // become walls). This is the AAA-indie tell: previewing the commit.
    if (this.steps.length >= 2) {
      ctx.save();
      ctx.setLineDash([3, 5]);
      const dashPhase = (now * 40) % 8;
      ctx.lineDashOffset = -dashPhase;
      ctx.strokeStyle = "rgba(160,220,255,0.22)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(this.steps[0].pos.x, this.steps[0].pos.y);
      for (let i = 1; i < this.steps.length; i++) {
        ctx.lineTo(this.steps[i].pos.x, this.steps[i].pos.y);
      }
      ctx.stroke();

      // A guide-dot at the tail, gently pulsing.
      const last = this.steps[this.steps.length - 1];
      const pulse = 3 + Math.sin(now * 6) * 1.2;
      ctx.setLineDash([]);
      ctx.fillStyle = "rgba(190,235,255,0.5)";
      ctx.beginPath();
      ctx.arc(last.pos.x, last.pos.y, pulse, 0, TAU);
      ctx.fill();
      ctx.restore();
    }
  }
}
