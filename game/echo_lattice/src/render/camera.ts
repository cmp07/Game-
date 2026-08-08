// Camera easing — spring-damper follow with velocity lookahead + shake hook.
//
// Feel notes:
//  - Springs (vs. exp damp) let us tune "snap" vs "float" separately via a
//    stiffness/damping pair. Critical damping is the AAA-indie default.
//  - Lookahead biases the camera toward player velocity so the world reads
//    ahead of you rather than lagging behind.

import { clamp, damp, v2, type Vec2 } from "../engine/math";
import type { ScreenShake } from "../juice/screenshake";

export class Camera {
  pos: Vec2 = v2(0, 0);
  vel: Vec2 = v2(0, 0);
  target: Vec2 = v2(0, 0);
  lookahead: Vec2 = v2(0, 0);
  zoom = 1;
  targetZoom = 1;

  // Spring params — critically damped (2*sqrt(k)).
  stiffness = 90;
  damping = 20;
  lookaheadGain = 0.14;
  lookaheadEase = 6;

  constructor(private width: number, private height: number) {}

  follow(target: Vec2, playerVel: Vec2, dt: number): void {
    this.target.x = target.x;
    this.target.y = target.y;

    // Ease lookahead toward player velocity direction.
    this.lookahead.x = damp(
      this.lookahead.x,
      playerVel.x * this.lookaheadGain,
      this.lookaheadEase,
      dt,
    );
    this.lookahead.y = damp(
      this.lookahead.y,
      playerVel.y * this.lookaheadGain,
      this.lookaheadEase,
      dt,
    );

    const goalX = this.target.x + this.lookahead.x;
    const goalY = this.target.y + this.lookahead.y;

    // Spring integration (semi-implicit Euler).
    const ax = (goalX - this.pos.x) * this.stiffness - this.vel.x * this.damping;
    const ay = (goalY - this.pos.y) * this.stiffness - this.vel.y * this.damping;
    this.vel.x += ax * dt;
    this.vel.y += ay * dt;
    this.pos.x += this.vel.x * dt;
    this.pos.y += this.vel.y * dt;

    this.zoom = damp(this.zoom, this.targetZoom, 6, dt);
  }

  /** Recenter kick — small overshoot when the world "commits". */
  punch(zoomOut = 0.06, decay = 3.5, dt = 1 / 60): void {
    this.targetZoom = clamp(this.targetZoom - zoomOut, 0.75, 1.15);
    // Auto-recover:
    this.targetZoom = damp(this.targetZoom, 1, decay, dt);
  }

  /** Apply the camera + optional shake to a 2D context. */
  applyTo(
    ctx: CanvasRenderingContext2D,
    shake?: ScreenShake,
  ): void {
    const [sx, sy, sr] = shake ? shake.offset() : [0, 0, 0];
    ctx.setTransform(
      this.zoom,
      0,
      0,
      this.zoom,
      Math.round(this.width / 2 + sx - this.pos.x * this.zoom),
      Math.round(this.height / 2 + sy - this.pos.y * this.zoom),
    );
    if (sr !== 0) {
      // Rotate about the screen center visually — approximate by nudging.
      ctx.rotate(sr);
    }
  }

  screenToWorld(x: number, y: number): Vec2 {
    return v2(
      (x - this.width / 2) / this.zoom + this.pos.x,
      (y - this.height / 2) / this.zoom + this.pos.y,
    );
  }
}
