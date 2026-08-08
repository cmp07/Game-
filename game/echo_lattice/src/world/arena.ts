// Arena — the ambient stage: grid, boundary, subtle depth. Purely visual;
// keeps the empty world feeling composed instead of hollow.

import { TAU, clamp } from "../engine/math";

export interface ArenaBounds {
  minX: number;
  minY: number;
  maxX: number;
  maxY: number;
}

export class Arena {
  constructor(public bounds: ArenaBounds) {}

  clampCircle(x: number, y: number, r: number): { x: number; y: number } {
    return {
      x: clamp(x, this.bounds.minX + r, this.bounds.maxX - r),
      y: clamp(y, this.bounds.minY + r, this.bounds.maxY - r),
    };
  }

  draw(ctx: CanvasRenderingContext2D, now: number, camX: number, camY: number): void {
    const { minX, minY, maxX, maxY } = this.bounds;
    const w = maxX - minX;
    const h = maxY - minY;

    // Floor gradient (deep indigo center).
    ctx.save();
    const cx = (minX + maxX) / 2;
    const cy = (minY + maxY) / 2;
    const g = ctx.createRadialGradient(cx, cy, 8, cx, cy, Math.hypot(w, h) * 0.55);
    g.addColorStop(0, "#0a1030");
    g.addColorStop(0.5, "#070b22");
    g.addColorStop(1, "#04050f");
    ctx.fillStyle = g;
    ctx.fillRect(minX, minY, w, h);
    ctx.restore();

    // Parallax grid — coarser layer + finer layer. Slight scroll = life.
    this.drawGrid(ctx, camX, camY, 64, "rgba(80,110,180,0.05)", 1);
    this.drawGrid(ctx, camX, camY, 16, "rgba(80,110,180,0.035)", 1);

    // Diagonal shimmer bands (very faint) — pulls the eye.
    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    const bandY = ((now * 12) % 40) - 40;
    ctx.strokeStyle = "rgba(120,170,255,0.03)";
    ctx.lineWidth = 8;
    for (let i = -2; i < 40; i++) {
      const y = minY + bandY + i * 40;
      ctx.beginPath();
      ctx.moveTo(minX, y);
      ctx.lineTo(maxX, y + 20);
      ctx.stroke();
    }
    ctx.restore();

    // Boundary frame — inset rounded corners.
    ctx.save();
    ctx.strokeStyle = "rgba(140,180,255,0.35)";
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    this.roundedRect(ctx, minX, minY, w, h, 14);
    ctx.stroke();

    // Outer glow line
    ctx.strokeStyle = "rgba(140,180,255,0.09)";
    ctx.lineWidth = 8;
    ctx.beginPath();
    this.roundedRect(ctx, minX, minY, w, h, 14);
    ctx.stroke();

    // Corner runes
    const rune = 12;
    ctx.strokeStyle = "rgba(180,220,255,0.55)";
    ctx.lineWidth = 1.4;
    for (const [x, y] of [
      [minX + 8, minY + 8],
      [maxX - 8, minY + 8],
      [minX + 8, maxY - 8],
      [maxX - 8, maxY - 8],
    ]) {
      ctx.beginPath();
      ctx.arc(x, y, rune * 0.5, 0, TAU);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(x - rune * 0.7, y);
      ctx.lineTo(x + rune * 0.7, y);
      ctx.moveTo(x, y - rune * 0.7);
      ctx.lineTo(x, y + rune * 0.7);
      ctx.stroke();
    }
    ctx.restore();
  }

  private drawGrid(
    ctx: CanvasRenderingContext2D,
    _camX: number,
    _camY: number,
    cell: number,
    color: string,
    width: number,
  ): void {
    const { minX, minY, maxX, maxY } = this.bounds;
    ctx.save();
    ctx.strokeStyle = color;
    ctx.lineWidth = width;
    ctx.beginPath();
    for (let x = Math.ceil(minX / cell) * cell; x <= maxX; x += cell) {
      ctx.moveTo(x, minY);
      ctx.lineTo(x, maxY);
    }
    for (let y = Math.ceil(minY / cell) * cell; y <= maxY; y += cell) {
      ctx.moveTo(minX, y);
      ctx.lineTo(maxX, y);
    }
    ctx.stroke();
    ctx.restore();
  }

  private roundedRect(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    w: number,
    h: number,
    r: number,
  ): void {
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
  }
}
