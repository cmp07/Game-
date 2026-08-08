// Minimal keyboard input. Semantic axes so tuning doesn't ripple into gameplay.

const KEYS = new Set<string>();
const EDGES_DOWN = new Set<string>();

function key(code: string): string {
  return code.toLowerCase();
}

window.addEventListener("keydown", (e) => {
  const k = key(e.code);
  if (!KEYS.has(k)) EDGES_DOWN.add(k);
  KEYS.add(k);
  // Prevent page scroll on arrows/space/etc.
  if (
    [
      "arrowup",
      "arrowdown",
      "arrowleft",
      "arrowright",
      "space",
    ].includes(k)
  ) {
    e.preventDefault();
  }
});

window.addEventListener("keyup", (e) => {
  KEYS.delete(key(e.code));
});

window.addEventListener("blur", () => {
  KEYS.clear();
});

export function isDown(...codes: string[]): boolean {
  for (const c of codes) if (KEYS.has(c.toLowerCase())) return true;
  return false;
}

export function pressed(...codes: string[]): boolean {
  for (const c of codes) if (EDGES_DOWN.has(c.toLowerCase())) return true;
  return false;
}

/** Reset per-frame edges after game logic has consumed them. */
export function endFrameInput(): void {
  EDGES_DOWN.clear();
}

export function axis(neg: string[], pos: string[]): number {
  const n = isDown(...neg) ? 1 : 0;
  const p = isDown(...pos) ? 1 : 0;
  return p - n;
}

export function moveInput(): { x: number; y: number } {
  const x = axis(["ArrowLeft", "KeyA"], ["ArrowRight", "KeyD"]);
  const y = axis(["ArrowUp", "KeyW"], ["ArrowDown", "KeyS"]);
  // Normalize diagonals for consistent player speed.
  const l = Math.hypot(x, y);
  if (l > 1) return { x: x / l, y: y / l };
  return { x, y };
}
