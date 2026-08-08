import "./style.css";

type Point = { x: number; y: number };
type Direction = "up" | "down" | "left" | "right";
type GameState = "ready" | "running" | "paused" | "over";

const GRID = 20; // 20 x 20 cells
const TICK_MS = 110;
const BEST_KEY = "snake.best";

const canvas = document.getElementById("game") as HTMLCanvasElement;
const ctx = canvas.getContext("2d")!;
const scoreEl = document.getElementById("score") as HTMLElement;
const bestEl = document.getElementById("best") as HTMLElement;
const overlay = document.getElementById("overlay") as HTMLElement;
const overlayTitle = document.getElementById("overlay-title") as HTMLElement;
const overlayHint = document.getElementById("overlay-hint") as HTMLElement;
const startButton = document.getElementById("start") as HTMLButtonElement;

const cell = canvas.width / GRID;

const DIRECTIONS: Record<Direction, Point> = {
  up: { x: 0, y: -1 },
  down: { x: 0, y: 1 },
  left: { x: -1, y: 0 },
  right: { x: 1, y: 0 },
};

const OPPOSITE: Record<Direction, Direction> = {
  up: "down",
  down: "up",
  left: "right",
  right: "left",
};

let snake: Point[] = [];
let direction: Direction = "right";
let queuedDirection: Direction = "right";
let food: Point = { x: 0, y: 0 };
let score = 0;
let best = Number(localStorage.getItem(BEST_KEY) ?? 0);
let state: GameState = "ready";
let lastTick = 0;

bestEl.textContent = String(best);

function resetGame(): void {
  snake = [
    { x: 8, y: 10 },
    { x: 7, y: 10 },
    { x: 6, y: 10 },
  ];
  direction = "right";
  queuedDirection = "right";
  score = 0;
  scoreEl.textContent = "0";
  placeFood();
}

function placeFood(): void {
  let candidate: Point;
  do {
    candidate = {
      x: Math.floor(Math.random() * GRID),
      y: Math.floor(Math.random() * GRID),
    };
  } while (snake.some((seg) => seg.x === candidate.x && seg.y === candidate.y));
  food = candidate;
}

function setOverlay(title: string, hint: string, buttonLabel: string): void {
  overlayTitle.textContent = title;
  overlayHint.textContent = hint;
  startButton.textContent = buttonLabel;
  overlay.classList.remove("is-hidden");
}

function hideOverlay(): void {
  overlay.classList.add("is-hidden");
}

function startGame(): void {
  if (state === "running") return;
  if (state === "over" || state === "ready") {
    resetGame();
  }
  state = "running";
  hideOverlay();
  lastTick = performance.now();
  requestAnimationFrame(loop);
}

function pauseGame(): void {
  if (state !== "running") return;
  state = "paused";
  setOverlay("Paused", "Press Space to resume", "Resume");
}

function gameOver(): void {
  state = "over";
  if (score > best) {
    best = score;
    localStorage.setItem(BEST_KEY, String(best));
    bestEl.textContent = String(best);
  }
  setOverlay("Game Over", `You scored ${score}. Press Space to try again.`, "Play again");
}

function step(): void {
  direction = queuedDirection;
  const delta = DIRECTIONS[direction];
  const head = snake[0];
  const next: Point = { x: head.x + delta.x, y: head.y + delta.y };

  const hitWall = next.x < 0 || next.y < 0 || next.x >= GRID || next.y >= GRID;
  const hitSelf = snake.some((seg) => seg.x === next.x && seg.y === next.y);
  if (hitWall || hitSelf) {
    gameOver();
    return;
  }

  snake.unshift(next);

  if (next.x === food.x && next.y === food.y) {
    score += 10;
    scoreEl.textContent = String(score);
    placeFood();
  } else {
    snake.pop();
  }
}

function drawRoundedCell(px: number, py: number, color: string, inset = 1): void {
  const radius = 5;
  const x = px * cell + inset;
  const y = py * cell + inset;
  const size = cell - inset * 2;
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.roundRect(x, y, size, size, radius);
  ctx.fill();
}

function draw(): void {
  ctx.fillStyle = "#0b1220";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.strokeStyle = "rgba(148, 163, 184, 0.08)";
  ctx.lineWidth = 1;
  for (let i = 1; i < GRID; i++) {
    ctx.beginPath();
    ctx.moveTo(i * cell, 0);
    ctx.lineTo(i * cell, canvas.height);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(0, i * cell);
    ctx.lineTo(canvas.width, i * cell);
    ctx.stroke();
  }

  drawRoundedCell(food.x, food.y, "#f472b6", 3);

  snake.forEach((seg, index) => {
    drawRoundedCell(seg.x, seg.y, index === 0 ? "#22c55e" : "#4ade80");
  });
}

function loop(now: number): void {
  if (state !== "running") return;
  if (now - lastTick >= TICK_MS) {
    lastTick = now;
    step();
  }
  draw();
  if (state === "running") {
    requestAnimationFrame(loop);
  }
}

function queueDirection(next: Direction): void {
  if (next === OPPOSITE[direction]) return;
  queuedDirection = next;
}

const KEY_MAP: Record<string, Direction> = {
  ArrowUp: "up",
  ArrowDown: "down",
  ArrowLeft: "left",
  ArrowRight: "right",
  w: "up",
  s: "down",
  a: "left",
  d: "right",
  W: "up",
  S: "down",
  A: "left",
  D: "right",
};

window.addEventListener("keydown", (event) => {
  if (event.key === " " || event.code === "Space") {
    event.preventDefault();
    if (state === "running") {
      pauseGame();
    } else {
      startGame();
    }
    return;
  }

  const dir = KEY_MAP[event.key];
  if (dir) {
    event.preventDefault();
    if (state === "running") {
      queueDirection(dir);
    }
  }
});

startButton.addEventListener("click", () => {
  if (state === "running") {
    pauseGame();
  } else {
    startGame();
  }
});

resetGame();
draw();
setOverlay("Ready?", "Press Space or tap Start to play", "Start");
