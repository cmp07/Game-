import { Game } from "./engine/game";

function boot(): void {
  const canvas = document.getElementById("game") as HTMLCanvasElement | null;
  if (!canvas) throw new Error("no #game canvas");
  const game = new Game(canvas);
  game.start();

  // Optional: keep canvas pixel-crisp on HiDPI while capping DPR to 2.
  const resize = () => {
    // We keep the game's internal resolution fixed; only visual scaling
    // is handled by CSS. This is intentional — juice tuning is resolution-
    // dependent and pinning the internal size keeps things consistent.
    void canvas;
  };
  window.addEventListener("resize", resize);
  resize();
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot, { once: true });
} else {
  boot();
}
