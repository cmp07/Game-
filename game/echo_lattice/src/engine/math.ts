// Small math grab-bag. Kept intentionally tight; anything used more than twice
// lives here so tuning is one edit.

export const TAU = Math.PI * 2;

export function clamp(v: number, lo: number, hi: number): number {
  return v < lo ? lo : v > hi ? hi : v;
}

export function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

/** Frame-rate independent lerp. `speed` in units of 1/second. */
export function damp(a: number, b: number, speed: number, dt: number): number {
  return lerp(a, b, 1 - Math.exp(-speed * dt));
}

export function smoothstep(edge0: number, edge1: number, x: number): number {
  const t = clamp((x - edge0) / (edge1 - edge0), 0, 1);
  return t * t * (3 - 2 * t);
}

export function easeOutCubic(t: number): number {
  const u = 1 - t;
  return 1 - u * u * u;
}

export function easeOutQuint(t: number): number {
  const u = 1 - t;
  return 1 - u * u * u * u * u;
}

export function easeInOutSine(t: number): number {
  return -(Math.cos(Math.PI * t) - 1) / 2;
}

export interface Vec2 {
  x: number;
  y: number;
}

export function v2(x = 0, y = 0): Vec2 {
  return { x, y };
}

export function v2set(out: Vec2, x: number, y: number): Vec2 {
  out.x = x;
  out.y = y;
  return out;
}

export function v2copy(out: Vec2, a: Vec2): Vec2 {
  out.x = a.x;
  out.y = a.y;
  return out;
}

export function v2add(out: Vec2, a: Vec2, b: Vec2): Vec2 {
  out.x = a.x + b.x;
  out.y = a.y + b.y;
  return out;
}

export function v2sub(out: Vec2, a: Vec2, b: Vec2): Vec2 {
  out.x = a.x - b.x;
  out.y = a.y - b.y;
  return out;
}

export function v2scale(out: Vec2, a: Vec2, s: number): Vec2 {
  out.x = a.x * s;
  out.y = a.y * s;
  return out;
}

export function v2len(a: Vec2): number {
  return Math.hypot(a.x, a.y);
}

export function v2dist(a: Vec2, b: Vec2): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

export function v2norm(out: Vec2, a: Vec2): Vec2 {
  const l = Math.hypot(a.x, a.y);
  if (l < 1e-8) {
    out.x = 0;
    out.y = 0;
  } else {
    out.x = a.x / l;
    out.y = a.y / l;
  }
  return out;
}

/** Distance from point p to segment ab. Also returns closest point via `out`. */
export function distPointSegment(
  p: Vec2,
  a: Vec2,
  b: Vec2,
  out?: Vec2,
): number {
  const abx = b.x - a.x;
  const aby = b.y - a.y;
  const apx = p.x - a.x;
  const apy = p.y - a.y;
  const ab2 = abx * abx + aby * aby;
  const t = ab2 > 1e-8 ? clamp((apx * abx + apy * aby) / ab2, 0, 1) : 0;
  const cx = a.x + abx * t;
  const cy = a.y + aby * t;
  if (out) {
    out.x = cx;
    out.y = cy;
  }
  return Math.hypot(p.x - cx, p.y - cy);
}
