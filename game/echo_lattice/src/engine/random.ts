// Seedable RNG. Deterministic seeds keep juice repeatable during tuning —
// change the seed and the whole particle spread reshuffles predictably.

export class Rng {
  private state: number;

  constructor(seed = 0x9e3779b9) {
    // xorshift32; avoid zero state.
    this.state = seed >>> 0 || 0x1;
  }

  next(): number {
    let x = this.state;
    x ^= x << 13;
    x ^= x >>> 17;
    x ^= x << 5;
    this.state = x >>> 0;
    return (this.state & 0xffffffff) / 0x100000000;
  }

  range(lo: number, hi: number): number {
    return lo + this.next() * (hi - lo);
  }

  angle(): number {
    return this.next() * Math.PI * 2;
  }

  sign(): number {
    return this.next() < 0.5 ? -1 : 1;
  }
}

export const rng = new Rng(0xc0ffee);
