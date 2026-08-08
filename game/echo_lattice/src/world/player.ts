// Player — top-down capsule with dash, i-frames, and step cadence hook.

import { clamp, TAU, damp, v2, type Vec2 } from "../engine/math";

export class Player {
  pos: Vec2 = v2(0, 0);
  vel: Vec2 = v2(0, 0);
  facing = 0;
  radius = 8;
  speed = 190;
  dashSpeed = 620;
  dashTime = 0;
  dashCd = 0;
  iframes = 0;
  hp = 3;

  dash(dirX: number, dirY: number): boolean {
    if (this.dashCd > 0 || this.dashTime > 0) return false;
    const l = Math.hypot(dirX, dirY);
    if (l < 1e-3) {
      dirX = Math.cos(this.facing);
      dirY = Math.sin(this.facing);
    } else {
      dirX /= l;
      dirY /= l;
    }
    this.vel.x = dirX * this.dashSpeed;
    this.vel.y = dirY * this.dashSpeed;
    this.dashTime = 0.14;
    this.dashCd = 0.55;
    this.iframes = 0.16;
    return true;
  }

  update(dt: number, inputX: number, inputY: number): void {
    this.dashCd = Math.max(0, this.dashCd - dt);
    this.iframes = Math.max(0, this.iframes - dt);

    if (this.dashTime > 0) {
      this.dashTime -= dt;
      // decay velocity toward normal-speed limit while dashing.
    } else {
      const targetVX = inputX * this.speed;
      const targetVY = inputY * this.speed;
      this.vel.x = damp(this.vel.x, targetVX, 22, dt);
      this.vel.y = damp(this.vel.y, targetVY, 22, dt);
    }

    if (Math.abs(this.vel.x) + Math.abs(this.vel.y) > 8) {
      this.facing = Math.atan2(this.vel.y, this.vel.x);
    }

    this.pos.x += this.vel.x * dt;
    this.pos.y += this.vel.y * dt;
  }

  isMoving(): boolean {
    return Math.hypot(this.vel.x, this.vel.y) > 40;
  }

  velAngle(): number {
    return this.facing;
  }

  hit(): boolean {
    if (this.iframes > 0) return false;
    this.hp = Math.max(0, this.hp - 1);
    this.iframes = 1.2;
    return true;
  }

  draw(ctx: CanvasRenderingContext2D, now: number): void {
    // Under-halo
    ctx.save();
    const halo = 22 + Math.sin(now * 2.2) * 2;
    const grad = ctx.createRadialGradient(
      this.pos.x,
      this.pos.y,
      2,
      this.pos.x,
      this.pos.y,
      halo,
    );
    grad.addColorStop(0, "rgba(190,230,255,0.35)");
    grad.addColorStop(1, "rgba(190,230,255,0)");
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(this.pos.x, this.pos.y, halo, 0, TAU);
    ctx.fill();
    ctx.restore();

    // i-frame flicker
    const visible = this.iframes <= 0 || Math.floor(now * 30) % 2 === 0;
    if (!visible) return;

    ctx.save();
    ctx.translate(this.pos.x, this.pos.y);
    ctx.rotate(this.facing);

    // Body
    ctx.fillStyle = "#dfe9ff";
    ctx.strokeStyle = "#7ea8ff";
    ctx.lineWidth = 1.4;
    ctx.beginPath();
    ctx.moveTo(this.radius, 0);
    ctx.lineTo(-this.radius * 0.7, this.radius * 0.75);
    ctx.lineTo(-this.radius * 0.4, 0);
    ctx.lineTo(-this.radius * 0.7, -this.radius * 0.75);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Eye
    ctx.fillStyle = "#0a1230";
    ctx.beginPath();
    ctx.arc(this.radius * 0.25, 0, 1.5, 0, TAU);
    ctx.fill();

    ctx.restore();

    // HP pips
    ctx.save();
    for (let i = 0; i < 3; i++) {
      const x = this.pos.x - 10 + i * 10;
      const y = this.pos.y - this.radius - 10;
      ctx.strokeStyle = "rgba(220,235,255,0.7)";
      ctx.fillStyle = i < this.hp ? "rgba(120,220,255,0.9)" : "rgba(30,45,80,0.4)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.arc(x, y, 2.2, 0, TAU);
      ctx.fill();
      ctx.stroke();
    }
    ctx.restore();
    void clamp;
  }
}
