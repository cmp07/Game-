// Game — glue module. Owns state, systems, and the frame lifecycle.
//
// The order-of-operations here is what sells the AAA-indie feel:
//
//   fixed(dt):
//     input → player.update → arena clamp → wall collision → footstep drop
//     → telegraph tick (fires impacts → hitstop + shake + flash) → enemies
//     → particles.update
//
//   render(alpha, realDt):
//     hitstop.update → screenshake.update → camera.follow
//     → scene.draw (arena → walls → footsteps → telegraphs → enemies → player → particles)
//     → post.present → flash.draw

import { endFrameInput, isDown, moveInput, pressed } from "./input";
import { startLoop, type Timescale } from "./loop";
import { Arena } from "../world/arena";
import { Player } from "../world/player";
import { Walls } from "../world/walls";
import { Footsteps } from "../world/footsteps";
import { Telegraphs, type Telegraph } from "../world/telegraph";
import { Pulsar } from "../world/enemy";
import { Particles } from "../render/particles";
import { Camera } from "../render/camera";
import { Post } from "../render/post";
import { Hitstop } from "../juice/hitstop";
import { ScreenShake } from "../juice/screenshake";
import { Flash } from "../juice/flash";
import { rng } from "./random";

export class Game {
  private ctx: CanvasRenderingContext2D;
  private width: number;
  private height: number;

  private timescale: Timescale = { value: 1 };
  private simTime = 0;
  private realTime = 0;

  private arena: Arena;
  private player: Player;
  private walls: Walls;
  private footsteps: Footsteps;
  private telegraphs: Telegraphs;
  private pulsars: Pulsar[] = [];
  private particles: Particles;

  private camera: Camera;
  private post: Post;
  private hitstop: Hitstop;
  private shake: ScreenShake;
  private flash: Flash;

  private stopLoop: (() => void) | null = null;
  private commitCooldown = 0;

  constructor(canvas: HTMLCanvasElement) {
    this.width = canvas.width;
    this.height = canvas.height;
    const c = canvas.getContext("2d", { alpha: false });
    if (!c) throw new Error("2d ctx unavailable");
    this.ctx = c;

    this.arena = new Arena({ minX: -420, minY: -240, maxX: 420, maxY: 240 });
    this.player = new Player();
    this.walls = new Walls();
    this.footsteps = new Footsteps();
    this.telegraphs = new Telegraphs();
    this.particles = new Particles();

    this.pulsars.push(new Pulsar(-260, -140, 2.6, 62, 180));
    this.pulsars.push(new Pulsar(260, 140, 2.9, 68, 190));
    this.pulsars.push(new Pulsar(240, -170, 3.4, 58, 160));

    this.camera = new Camera(this.width, this.height);
    this.camera.pos.x = 0;
    this.camera.pos.y = 0;
    this.post = new Post(this.width, this.height);
    this.hitstop = new Hitstop(this.timescale);
    this.shake = new ScreenShake();
    this.flash = new Flash();
  }

  start(): void {
    if (this.stopLoop) return;
    this.stopLoop = startLoop(
      {
        fixed: (dt) => this.fixed(dt),
        render: (a, rdt) => this.render(a, rdt),
      },
      this.timescale,
    );
  }

  stop(): void {
    if (this.stopLoop) this.stopLoop();
    this.stopLoop = null;
  }

  private reset(): void {
    this.player.pos.x = 0;
    this.player.pos.y = 0;
    this.player.vel.x = 0;
    this.player.vel.y = 0;
    this.player.hp = 3;
    this.walls.clear();
    this.footsteps.clear();
    this.telegraphs.clear();
    this.shake.bump(0.35);
    this.flash.fire(0.35, 0.5, "160,220,255");
    this.particles.burstEcho(0, 0);
  }

  private fixed(dt: number): void {
    this.simTime += dt;

    // === Input ===
    const mv = moveInput();
    const rewrite = pressed("Space");
    const dashPressed = pressed("ShiftLeft", "ShiftRight");
    const resetPressed = pressed("KeyR");
    const togglePost = pressed("KeyP");

    if (togglePost) this.post.enabled = !this.post.enabled;
    if (resetPressed) this.reset();

    if (dashPressed) {
      if (this.player.dash(mv.x, mv.y)) {
        this.shake.bump(0.16);
        this.particles.burstSparks(
          this.player.pos.x,
          this.player.pos.y,
          10,
          220,
          "170,220,255",
        );
      }
    }

    // === Player + collision ===
    this.player.update(dt, mv.x, mv.y);
    // Arena bounds
    const b = this.arena.clampCircle(this.player.pos.x, this.player.pos.y, this.player.radius);
    if (b.x !== this.player.pos.x) this.player.vel.x = 0;
    if (b.y !== this.player.pos.y) this.player.vel.y = 0;
    this.player.pos.x = b.x;
    this.player.pos.y = b.y;
    // Wall collision
    const resolved = this.walls.resolveCircle(this.player.pos, this.player.radius, this.simTime);
    this.player.pos.x = resolved.x;
    this.player.pos.y = resolved.y;

    // === Footsteps ===
    if (this.player.isMoving()) {
      const dropped = this.footsteps.drop(
        this.player.pos,
        this.player.velAngle(),
        this.simTime,
      );
      if (dropped) {
        // Tiny dust puff so movement itself has a heartbeat.
        this.particles.spawnDot({
          x: this.player.pos.x - Math.cos(this.player.velAngle()) * 6,
          y: this.player.pos.y - Math.sin(this.player.velAngle()) * 6,
          vx: -Math.cos(this.player.velAngle()) * 20 + rng.range(-10, 10),
          vy: -Math.sin(this.player.velAngle()) * 20 + rng.range(-10, 10),
          maxLife: 0.28,
          size: 1.2,
          sizeGrow: 2,
          drag: 5,
          color: "170,200,240",
          glow: 0.7,
        });
      }
    }

    // === Rewrite (commit trail → walls) ===
    this.commitCooldown = Math.max(0, this.commitCooldown - dt);
    if (rewrite && this.commitCooldown <= 0 && this.footsteps.steps.length >= 2) {
      const nSegs = this.footsteps.commit(this.walls, this.particles, this.simTime, 200);
      this.commitCooldown = 0.35;
      // Screen shake proportional to lattice size, but capped.
      this.shake.bump(Math.min(0.55, 0.2 + nSegs * 0.03));
      this.flash.fire(0.28, 0.55, "160,225,255");
      this.hitstop.hit(0.09, 0.06);
      // Camera zoom-punch (subtle out then recover — see camera.punch update).
      this.camera.targetZoom = 0.94;
      // Big shockwave ring
      this.particles.spawnRing({
        x: this.player.pos.x,
        y: this.player.pos.y,
        size: 6,
        sizeGrow: 320,
        maxLife: 0.55,
        color: "160,225,255",
        glow: 0.9,
      });
      this.particles.spawnRing({
        x: this.player.pos.x,
        y: this.player.pos.y,
        size: 6,
        sizeGrow: 220,
        maxLife: 0.7,
        color: "120,200,255",
        glow: 0.6,
      });
      this.particles.burstSparks(
        this.player.pos.x,
        this.player.pos.y,
        22,
        280,
        "200,240,255",
      );
    }

    // === Enemies + telegraphs ===
    for (const p of this.pulsars) {
      p.update(dt, this.player.pos, this.telegraphs);
    }
    this.telegraphs.update(dt, (z) => this.onTelegraphStrike(z));

    // === Particles ===
    this.particles.update(dt);

    endFrameInput();
  }

  private onTelegraphStrike(z: Telegraph): void {
    // At strike moment: shockwave + sparks always.
    this.particles.spawnRing({
      x: z.x,
      y: z.y,
      size: 8,
      sizeGrow: 260,
      maxLife: 0.45,
      color: "255,150,140",
    });
    this.particles.burstSparks(z.x, z.y, 16, 260, "255,180,150");

    // Hit test player at strike frame.
    const dx = this.player.pos.x - z.x;
    const dy = this.player.pos.y - z.y;
    const dist = Math.hypot(dx, dy);
    if (dist <= z.radius) {
      if (this.player.hit()) {
        this.shake.bump(0.55);
        this.flash.fire(0.2, 0.8, "255,120,120");
        this.hitstop.hit(0.12, 0.05);
        this.particles.burstSparks(this.player.pos.x, this.player.pos.y, 24, 340, "255,180,180");
      }
    } else {
      // Near-miss reward: small shake + flash so dodging feels felt.
      const miss = Math.max(0, 1 - (dist - z.radius) / 40);
      if (miss > 0) {
        this.shake.bump(0.06 + miss * 0.1);
        this.flash.fire(0.09, 0.15 + miss * 0.15, "255,220,180");
        this.hitstop.hit(0.03 + miss * 0.03, 0.15);
      }
    }
  }

  // --- Render pipeline ---
  private render(_alpha: number, realDt: number): void {
    this.realTime += realDt;
    this.hitstop.update(realDt);
    this.shake.update(realDt);
    this.flash.update(realDt);

    // Camera easing uses real dt so the world tracks even in hitstop.
    this.camera.follow(this.player.pos, this.player.vel, realDt);
    // Zoom recover
    this.camera.targetZoom = this.camera.targetZoom + (1 - this.camera.targetZoom) * Math.min(1, realDt * 4);

    const sctx = this.post.sceneCtx;
    this.post.clearScene("#03050d");

    this.camera.applyTo(sctx, this.shake);
    this.arena.draw(sctx, this.realTime, this.camera.pos.x, this.camera.pos.y);
    this.walls.draw(sctx, this.simTime);
    this.footsteps.draw(sctx, this.simTime);
    this.telegraphs.draw(sctx, this.simTime);
    for (const p of this.pulsars) p.draw(sctx, this.realTime);
    this.player.draw(sctx, this.realTime);
    this.particles.draw(sctx);

    // Reset transform for full-screen overlays.
    sctx.setTransform(1, 0, 0, 1, 0, 0);

    // Compose to main canvas with post-fx.
    // Extra chroma spikes on flash so impact really shivers.
    const extraChroma = Math.min(3, isDown("Space") ? 1.2 : 0);
    this.post.present(this.ctx, this.realTime, extraChroma);
    this.flash.draw(this.ctx, this.width, this.height);

    // Death veil
    if (this.player.hp <= 0) {
      this.ctx.save();
      this.ctx.fillStyle = "rgba(20,10,20,0.55)";
      this.ctx.fillRect(0, 0, this.width, this.height);
      this.ctx.fillStyle = "#f6e0e0";
      this.ctx.font = "700 32px ui-monospace, monospace";
      this.ctx.textAlign = "center";
      this.ctx.fillText("THE LATTICE FADED.", this.width / 2, this.height / 2 - 6);
      this.ctx.font = "500 12px ui-monospace, monospace";
      this.ctx.fillStyle = "rgba(220,200,220,0.85)";
      this.ctx.fillText("press R to rewrite", this.width / 2, this.height / 2 + 18);
      this.ctx.restore();
    }
  }
}
