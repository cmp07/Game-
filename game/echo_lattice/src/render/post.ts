// Post-processing layer, canvas-2D style.
//
// We avoid WebGL for install-free portability, so post-fx are cheap fakes:
//   - chromatic aberration: draw the scene 3x with tinted composite offsets
//   - vignette: radial gradient overlay
//   - scanlines: 1px striped multiply overlay (very faint)
//   - grain: sparse per-pixel noise sample
//
// The scene is rendered into an offscreen canvas so we can layer these
// effects without paying pixel-manipulation costs on the main context.

export class Post {
  enabled = true;
  chroma = 1.4;      // px offset
  vignette = 0.55;   // 0..1 strength
  scanlines = 0.06;
  grain = 0.05;

  private scene: HTMLCanvasElement;
  private sctx: CanvasRenderingContext2D;
  private grainCanvas: HTMLCanvasElement | null = null;

  constructor(private width: number, private height: number) {
    this.scene = document.createElement("canvas");
    this.scene.width = width;
    this.scene.height = height;
    const c = this.scene.getContext("2d", { alpha: true });
    if (!c) throw new Error("no 2d context for scene buffer");
    this.sctx = c;
    this.buildGrain();
  }

  get sceneCtx(): CanvasRenderingContext2D {
    return this.sctx;
  }

  clearScene(bg: string): void {
    this.sctx.setTransform(1, 0, 0, 1, 0, 0);
    this.sctx.globalCompositeOperation = "source-over";
    this.sctx.globalAlpha = 1;
    this.sctx.fillStyle = bg;
    this.sctx.fillRect(0, 0, this.width, this.height);
  }

  private buildGrain(): void {
    const size = 128;
    const c = document.createElement("canvas");
    c.width = size;
    c.height = size;
    const g = c.getContext("2d");
    if (!g) return;
    const img = g.createImageData(size, size);
    for (let i = 0; i < img.data.length; i += 4) {
      const v = (Math.random() * 255) | 0;
      img.data[i] = v;
      img.data[i + 1] = v;
      img.data[i + 2] = v;
      img.data[i + 3] = 255;
    }
    g.putImageData(img, 0, 0);
    this.grainCanvas = c;
  }

  /**
   * Composite the scene into `dst` with post-fx.
   * @param extraChroma  additional chroma bump (e.g. from rewrite bursts)
   */
  present(
    dst: CanvasRenderingContext2D,
    time: number,
    extraChroma = 0,
  ): void {
    dst.setTransform(1, 0, 0, 1, 0, 0);
    dst.imageSmoothingEnabled = false;
    dst.clearRect(0, 0, this.width, this.height);

    if (!this.enabled) {
      dst.drawImage(this.scene, 0, 0);
      return;
    }

    const chroma = this.chroma + extraChroma;

    // Chromatic aberration — three tinted draws using "screen" compositing.
    dst.globalCompositeOperation = "source-over";
    dst.filter = "none";

    // Red offset left, blue offset right, green centered.
    dst.globalCompositeOperation = "lighter";
    this.drawTinted(dst, -chroma, 0, "rgba(255,80,80,1)");
    this.drawTinted(dst, chroma, 0, "rgba(80,140,255,1)");
    this.drawTinted(dst, 0, 0, "rgba(80,255,140,1)");

    // Vignette (multiply-ish via source-over with dark radial gradient).
    dst.globalCompositeOperation = "source-over";
    const cx = this.width / 2;
    const cy = this.height / 2;
    const grad = dst.createRadialGradient(
      cx,
      cy,
      Math.min(cx, cy) * 0.55,
      cx,
      cy,
      Math.hypot(cx, cy),
    );
    grad.addColorStop(0, "rgba(0,0,0,0)");
    grad.addColorStop(1, `rgba(0,0,0,${this.vignette.toFixed(3)})`);
    dst.fillStyle = grad;
    dst.fillRect(0, 0, this.width, this.height);

    // Scanlines
    if (this.scanlines > 0) {
      dst.globalAlpha = this.scanlines;
      dst.fillStyle = "#000";
      for (let y = 0; y < this.height; y += 2) {
        dst.fillRect(0, y, this.width, 1);
      }
      dst.globalAlpha = 1;
    }

    // Grain (scroll grain texture over frame — very cheap animated grain).
    if (this.grain > 0 && this.grainCanvas) {
      dst.globalAlpha = this.grain;
      dst.globalCompositeOperation = "overlay";
      const ox = ((time * 137) | 0) % 128;
      const oy = ((time * 89) | 0) % 128;
      for (let y = -oy; y < this.height; y += 128) {
        for (let x = -ox; x < this.width; x += 128) {
          dst.drawImage(this.grainCanvas, x, y);
        }
      }
      dst.globalAlpha = 1;
      dst.globalCompositeOperation = "source-over";
    }
  }

  private drawTinted(
    dst: CanvasRenderingContext2D,
    dx: number,
    dy: number,
    tint: string,
  ): void {
    // Draw scene tinted by using the channel as a mask via composite ops.
    // The cheap effective version: draw tinted rect through scene using
    // "destination-in" on an offscreen; we approximate with globalCompositeOperation "multiply"
    // sequence. To keep it fast we use a fill-then-mask pattern on a tmp.
    dst.save();
    dst.globalCompositeOperation = "lighter";
    dst.drawImage(this.scene, dx, dy);
    // A subtle tint pass — soft chromatic bleed.
    dst.globalCompositeOperation = "multiply";
    dst.fillStyle = tint;
    dst.globalAlpha = 0.06;
    dst.fillRect(0, 0, this.width, this.height);
    dst.globalAlpha = 1;
    dst.restore();
  }
}
