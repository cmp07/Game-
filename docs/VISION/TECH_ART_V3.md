# Echo Lattice — Technical Art Plan v3

**Product:** Echo Lattice (Game 1 — Field Ledger)  
**Engine:** Godot 4.3 · GDScript · `gl_compatibility`  
**Branch:** `cursor/vision-tech-art`  
**Mode:** **Cloud-only** — shader contracts, material graphs, and Deck budgets. No Godot binary / no Deck hardware in this pass; validate gates on device before Verified submit.  
**Status:** Implementation authority for the next tech-art wave (beyond VISUAL v2 CPU canvas).  
**Last updated:** 2026-08-09

---

## 0. Purpose

VISUAL v2 locked the Field Ledger look with CPU canvas draws (`ArtKit` grain blits, slam blit phases, Juice SoA particles). **TECH ART v3** upgrades the four signature systems into **shader-backed** pipelines that stay inside Steam Deck budgets and never drift toward glow-on-void.

| System | Look verb (art bible) | RC1 baseline | v3 target |
|---|---|---|---|
| Paper grain | Print noise on ledger | Baked `ImageTexture` tiled blit | Fullscreen / page `canvas_item` grain shader |
| Ink bleed | Rust / ink seeps from joins | Slam-phase texture fade + line ink | Edge-driven bleed shader + staged UV warp |
| Crease deform | Origami fold, cast shadow | `_draw_rewrite_slam` rect lift | Vertex crease deform + shadow offset |
| Fossil particles | Calcification speckles | Juice SoA pool (cap 200) | Typed fossil pool + optional MultiMesh |

**Authorities (do not contradict):**

| Doc | Owns |
|---|---|
| [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) | Pillars, palette, materials, rewrite VFX language |
| [`../ECHO_LATTICE/14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) | Playable ink-on-paper notes |
| [`../ECHO_LATTICE/07_JUICE.md`](../ECHO_LATTICE/07_JUICE.md) | Hitstop / Field Ledger juice overrides |
| [`../AUDIT/PERFORMANCE.md`](../AUDIT/PERFORMANCE.md) | RC1 cost model (grain, slam, particles, Deck) |
| [`../RELEASE/STEAM_DECK.md`](../RELEASE/STEAM_DECK.md) | 7 W / 4 W Verified targets |

**Hard bans (shader edition):** no bloom, no volumetric fog, no god-rays, no screen-space distortion as spectacle, no purple emissive, no particle glow. Distortion is **paper crease only**, local to doomed tiles, during the slam window.

---

## 1. Renderer & file layout

### 1.1 Engine constraints

| Knob | Value | Why |
|---|---|---|
| Renderer | `gl_compatibility` | Deck / low-end; no Forward+ feature dependence |
| Viewport base | 960×560 (`expand` → ≈960×600 @ 16:10) | Existing art / Deck layout |
| Shader language | Godot 4.3 `canvas_item` | 2D ledger; avoid Spatial |
| Precision | `mediump` defaults; no dependent texture loops on Deck | Fill-rate safety |
| Post stack | ≤ **2** fullscreen passes (grain + optional sepia LUT) | Budget §5 |

### 1.2 Proposed `res://` map

```text
game/echo_lattice/
  shaders/
    paper_grain.gdshader          # §2
    ink_bleed.gdshader            # §3
    crease_deform.gdshader        # §4
    fossil_particle.gdshader      # §5 (optional per-instance)
  materials/
    paper_grain_page.tres
    paper_grain_menu.tres
    ink_bleed_slam.tres
    crease_fold_tile.tres
  art/
    noise/
      paper_grain_512.png         # tiled, ink_soft on transparent (bible §4)
      bleed_edge_lut.png          # 1D or 64×64 soft edge falloff
  scripts/
    tech_art/
      paper_grain_layer.gd        # ColorRect / BackBufferCopy host
      slam_shader_driver.gd       # feeds crease + bleed uniforms from slam t
      fossil_vfx_host.gd          # MultiMeshInstance2D or CanvasItem draw bridge
```

RC1 keepers until shaders land: `ArtKit.draw_paper_grain`, `_draw_rewrite_slam`, `Juice.draw_particles`. Feature-flag via `settings.tech_art_v3` (default **off** in CI; **on** for Deck QA once green).

---

## 2. Paper grain shader

### 2.1 Intent

One cohesive print grain across viewport + page margin. Screen-locked (not world-locked). Opacity ≤ **8%** (`ink_soft` family). Cohesion via constraint — one noise, everywhere (art bible §4).

### 2.2 Shader contract (`paper_grain.gdshader`)

```glsl
shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D grain_tex : source_color, filter_nearest, repeat_enable;
uniform vec4 ink_soft : source_color = vec4(0.227, 0.204, 0.173, 1.0); // #3A342C
uniform float opacity : hint_range(0.0, 0.08) = 0.07;
uniform float tile_px = 512.0;
uniform vec2 scroll_px = vec2(0.0); // normally 0 — screen-locked
uniform float battery_scale : hint_range(0.0, 1.0) = 1.0; // Deck 4 W → 0.5

void fragment() {
    vec2 px = FRAGCOORD.xy + scroll_px;
    vec2 uv = px / tile_px;
    float g = texture(grain_tex, uv).a; // alpha = speck mask
    float a = g * opacity * battery_scale;
    COLOR = vec4(ink_soft.rgb, a);
}
```

### 2.3 Host rules

| Rule | Spec |
|---|---|
| Texture | Single 512×512 PNG, nearest, repeat; generate once offline or warm from `ArtKit.grain_texture` |
| Layers | **One** fullscreen page grain under tiles; menu uses same material, different seed offset in UV |
| Draw cost | **1** textured quad (or ColorRect) per layer — never N×1×1 rects |
| Dirtying | Grain layer is static; chamber dirty-redraw must **not** force grain re-bake |
| Accessibility | `reduce_fx` / battery → `battery_scale = 0.5` or disable second (viewport) pass |
| Ban | Animated UV crawl, chromatic aberration, scanlines-as-default |

### 2.4 Migration from RC1

1. Keep `ArtKit.grain_texture(seed)` as the offline bake source for `paper_grain_512.png` variants (seeds 3 / 11 / 19 / 42).  
2. Replace `draw_paper_grain` call sites in `chamber.gd` / `menu.gd` with a child `PaperGrainLayer` when `tech_art_v3`.  
3. Selftest: assert grain material present + opacity ≤ 0.08; screenshot stills must still read paper (not flat).

**Acceptance:** Deck logical 960×600 steady chamber: grain contribution ≤ **0.2 ms** GPU / ≤ **0.1 ms** script; zero per-frame RNG.

---

## 3. Ink bleed

### 3.1 Intent

Rust and ink **seep** from joins — geology and print, not emission. Used in:

1. Rewrite slam frames 10–12 (art bible §5) — rust bleed from fossil joins.  
2. Post-MVP water / quench puddles (material table) — ink bleed slows lantern; not MVP-blocking.  
3. Habit colonization micro-bleeds when a rust decal lands (optional, ≤1 frame pulse).

### 3.2 Shader contract (`ink_bleed.gdshader`)

```glsl
shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D base_tex : source_color, filter_nearest;
uniform sampler2D rust_decal : source_color, filter_nearest;
uniform sampler2D edge_lut : source_color, filter_linear;
uniform vec4 rust_fossil : source_color = vec4(0.545, 0.227, 0.122, 1.0); // #8B3A1F
uniform vec4 rust_deep : source_color = vec4(0.369, 0.141, 0.071, 1.0);   // #5E2412
uniform float bleed : hint_range(0.0, 1.0) = 0.0;   // slam local_t mapped
uniform float join_mask = 1.0; // 1 at edges, 0 at tile center (CPU or SDF)
uniform float max_uv_warp : hint_range(0.0, 0.04) = 0.02; // paper soak, not psychedelia

void fragment() {
    // Soft UV pull toward tile center as ink soaks — tiny, readability-safe.
    vec2 to_c = vec2(0.5) - UV;
    vec2 uv = UV + to_c * (bleed * max_uv_warp * join_mask);
    vec4 base = texture(base_tex, uv);
    float edge = texture(edge_lut, vec2(join_mask, bleed)).r;
    vec4 rust = texture(rust_decal, UV);
    vec3 ink = mix(rust_deep.rgb, rust_fossil.rgb, rust.r);
    float a = rust.a * edge * bleed;
    COLOR = vec4(mix(base.rgb, ink, a), clamp(base.a + a, 0.0, 1.0));
}
```

### 3.3 Driver timing (slam)

Map existing `_draw_rewrite_slam` phases → uniforms (wall-clock, not hitstop-sim):

| `local_t` | Phase | `bleed` | Notes |
|---|---|---|---|
| 0.00–0.25 | Crease | 0 | Crease shader owns tile |
| 0.25–0.50 | Lift | 0 | Cast shadow CPU or crease shadow uniform |
| 0.50–0.78 | Slot | 0 → 0.15 | Hint of join darkening only |
| 0.78–1.00 | Rust bleed | 0.15 → 1.0 | Full bleed; decal variants by cell hash |

Deterministic rust variant: `(x * 3 + y * 7) % rust_count` — same as RC1.

### 3.4 Budgets & bans

| Keep | Ban |
|---|---|
| Edge-weighted alpha from joins | Additive glow / bloom composite |
| Palette-locked rust | Animated noise that reads as fire/magic |
| ≤ 0.02 UV warp | Fullscreen wet-lens / heat haze |
| One bleed material instance reused | Per-tile `ShaderMaterial.duplicate()` in hot path |

**Acceptance:** slam stills at `rewrite:N` / `t=0.55` and `t=0.90` match Field Ledger (crease → fossil → rust), no cadmium outside margin heartbeat.

---

## 4. Crease deform

### 4.1 Intent

12-beat origami slam: creases appear, paper lifts with a **cast shadow** (no rim light), walls slot with 1 px overshoot, then hand off to ink bleed. Sound-first (~240 ms audio); VFX follows (art bible §5).

### 4.2 Shader contract (`crease_deform.gdshader`)

Vertex deform on a per-tile quad (or small MultiMesh). Compatibility-safe: modify `VERTEX` in canvas_item space only.

```glsl
shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D fold_tex : source_color, filter_nearest;
uniform float crease : hint_range(0.0, 1.0) = 0.0;   // 0..1 in crease phase
uniform float lift : hint_range(0.0, 1.0) = 0.0;     // 0..1 in lift phase
uniform float slot : hint_range(0.0, 1.0) = 0.0;     // 0..1 in slot phase
uniform float fold_axis = 0.0; // 0 = diag NW-SE, 1 = NE-SW (from cell hash)
uniform float shadow_strength : hint_range(0.0, 0.5) = 0.35;
uniform vec4 paper_deep : source_color = vec4(0.851, 0.804, 0.690, 1.0);
uniform vec4 ink_soft : source_color = vec4(0.227, 0.204, 0.173, 1.0);

void vertex() {
    // Lift in canvas Y; overshoot bounce on slot (mirrors chamber.gd bounce).
    float bounce = sin(slot * 3.14159) * (1.0 - slot) * 3.0;
    VERTEX.y -= lift * 4.0 + bounce;
    // Crease pinch toward fold axis — ≤ 2 px equivalent at 32px tile.
    float axis = mix(UV.x - UV.y, UV.x + UV.y - 1.0, fold_axis);
    VERTEX.xy += normalize(vec2(axis, axis)) * crease * 1.5;
}

void fragment() {
    vec4 fold = texture(fold_tex, UV);
    vec3 rgb = mix(paper_deep.rgb, fold.rgb, clamp(crease + lift, 0.0, 1.0));
    // Ink crease lines (diag) as alpha from fold green or procedural.
    float line = smoothstep(0.02, 0.0, abs(mix(UV.x - UV.y, UV.x + UV.y - 1.0, fold_axis)));
    rgb = mix(rgb, ink_soft.rgb, line * crease * 0.85);
    COLOR = vec4(rgb, 1.0);
}
```

Cast shadow: either a second pass quad offset by `vec2(3+5*lift, 4+6*lift)` at `ink_black` α 0.28–0.50, or a `shadow_offset` uniform on a sibling mesh. **No rim light.**

### 4.3 Staging under load

| Pending echoes N | Draw strategy |
|---|---|
| ≤ 24 | One MultiMesh (or N quads) full crease shader |
| 25–40 | Stagger subsets already in slam; skip per-tile unique materials |
| > 40 / battery | LOD: CPU blit path (`wall_folding_32`) or 2-atlas batches; shorten slam when `DeckProfile.battery_mode` |

Cadmium warn stays **CPU margin rects** (or a 1-frame ColorRect) — never inside the crease shader.

### 4.4 Motion / a11y

| Setting | Behavior |
|---|---|
| Default | Full 0.90 s slam, crease → lift → slot → bleed |
| `reduce_motion` | Snap to fossil (RC1 0.05 s path); shaders skip lift/bounce |
| `reduce_flash` | No cadmium heartbeat |
| `reduce_fx` | No fossil particles; crease may use blit LOD |

**Acceptance:** trailer beat remains readable as paper folding; no screen shake on rewrite (default); commit + first slam frame script ≤ **4 ms** p95 on Deck CPU (same gate as PERFORMANCE.md).

---

## 5. Fossil particles

### 5.1 Intent

Particles encode **calcification**, not sparkle. On rewrite: sparse rust/chalk grit from doomed cells. Ghost paths stay dashed lines — **no** particle trails (art bible §5).

### 5.2 Data & pool (align RC1 Juice + perf draft)

| Budget | Cap | Enforcement |
|---|---:|---|
| Live fossil / grit particles | **200** | steal-oldest ring (`Juice.PARTICLE_CAP`) |
| Rewrite burst / cell | **6** default · **2** reduce_motion · **0–1** battery+reduce_fx | `spawn_burst` |
| Pooled burst nodes (if MultiMesh host) | **8** rewrite · **24** overuse | `VfxPool` draft |
| Path fossil stamps (decals) | **256** | separate from grit; steal `COLD` first |
| Alloc in hot path | **0** after warm | SoA `PackedFloat32Array` only |

### 5.3 Look parameters

| Field | Range | Notes |
|---|---|---|
| Color | `rust_fossil` / `rust_deep` / `chalk_white` only | Via `FossilPalette` / a11y roles |
| Size | 2.0–4.5 px | Hard pixels; no soft glow sprites |
| Life | 0.25–0.55 s | Real-time (survives hitstop) |
| Velocity | 40–120 px/s, gravity-ish settle | Fall onto paper, don't orbit |
| Blend | `mix` / alpha | Never additive |

Optional `fossil_particle.gdshader`: sample a 4×4 chalk grit atlas; modulate by role color; fade by `life/max_life`. Prefer MultiMeshInstance2D with one material over per-speck `draw_rect`.

### 5.4 Lifecycle

1. Warm pool at boot / chamber enter.  
2. Rewrite commit: stage spawns across **2–3 frames** (avoid commit hitch).  
3. `Juice.reset_transient()` on every stage swap (already required by PERFORMANCE.md §7).  
4. Win burst (+10) uses copper grit once; no confetti.

**Acceptance:** rewrite never grows past 200; Dictionary particle path retired from hot draw; stage soak 100× menu↔chamber shows flat live count after clear.

---

## 6. Performance budgets — Steam Deck

Cloud-modeled from [`PERFORMANCE.md`](../AUDIT/PERFORMANCE.md) + [`STEAM_DECK.md`](../RELEASE/STEAM_DECK.md) + `DeckProfile`. **Device QA still required.**

### 6.1 Profile table

| Profile | FPS | SteamOS TDP guidance | Tech-art LOD |
|---|---:|---:|---|
| **Verified** | 60 | **7 W** | Grain shader on; crease MultiMesh ≤24; particles ≤200; full slam |
| **Battery** (`--battery`) | 40 | **4 W** | Grain `battery_scale=0.5`; slam LOD / shorter; particles ≤8 / rewrite; pause silent music layers |
| Desktop QA | uncapped + vsync | n/a | Same materials; profiler HUD optional |

### 6.2 Hard frame budgets

| Scope | Limit | Owner |
|---|---:|---|
| Frame total (Verified) | ≤ **16.67 ms** p95 | Deck 7 W native Linux |
| Frame total (Battery) | ≤ **25 ms** p95 | 4 W / 40 fps |
| Script + physics soft warn | ≤ **12 ms** | `FrameProfiler` |
| Rewrite commit compute | ≤ **4 ms** | ≤1 BFS-equivalent + staged particles |
| Any slam frame spike | ≤ **33 ms** | No multi-frame hitch |
| Fullscreen shader passes | ≤ **2** | Grain + optional LUT |
| Canvas draw items steady | Prefer dirty-rect; idle pulse ≤ **12–15 Hz** | Chamber / menu |
| GDScript alloc steady | **~0** Dictionary / frame | Prealloc pools |
| Working set | ≤ **400 MB** typical | Atlas discipline |
| Audio voices | ≤ **24** | Existing bus steal |

### 6.3 Tech-art cost envelopes (modeled)

| System | Verified cost envelope | Battery |
|---|---|---|
| Paper grain | 1 blit / pass ≪ 0.3 ms | Half opacity or off second pass |
| Ink bleed | N tile quads in last 22% of slam | Blit rust fade only |
| Crease deform | N vertex quads 0.08–0.78 | Blit `wall_folding` LOD |
| Fossil particles | ≤200 MultiMesh instances | ≤8 specks; or off |

### 6.4 Validation checklist (device — not this cloud pass)

- [ ] 40 min daily wing @ 7 W — locked 60, no thermal slide.  
- [ ] Same @ 4 W + `--battery` — readable slam, input edge-triggered.  
- [ ] `--perf-hud` / `FrameProfiler`: grain + slam scopes under §6.2.  
- [ ] `godot -- --selftest` includes grain bake, particle cap, slam freeze stills.  
- [ ] `reduce_motion` / `reduce_fx` / `reduce_flash` matrix still Field Ledger–legible.  
- [ ] Overlay open/close mid-slam — no stuck trauma / particles after resume.

---

## 7. Integration sequence

Ordered for Deck safety; each step shippable alone behind `tech_art_v3`.

| Step | Deliverable | Risk if skipped |
|---|---|---|
| **A** | Paper grain shader + retire per-frame grain work on any remaining CPU path | Fill-rate / CPU canvas regression |
| **B** | Fossil particle MultiMesh host on existing SoA pool | Draw-call churn on rewrite |
| **C** | Crease deform MultiMesh driven by slam `local_t` | Trailer beat quality |
| **D** | Ink bleed handoff from crease at `local_t ≥ 0.78` | Rust story softens |
| **E** | Battery / reduce_fx LOD table wired through `DeckProfile` + a11y | Verified 4 W fail |
| **F** | Capture suite stills + Gate A trailer re-freeze | Store drift |

**Non-goals for v3:** Forward+ lights, CRT filter as default, world-space 3D folds, GPU particles with trails, post bloom “just for trailer.”

---

## 8. Quality bar / sniff tests

Before merging any shader or material:

1. Frame still reads as a **document** (P1) with grain ≤ 8%.  
2. No bloom / purple / additive sparkle (P2–P3).  
3. Rewrite is crease → cast shadow → slot → rust bleed — not a warp flash.  
4. Ghost path remains a dashed chalk line (no particle smear).  
5. Deck battery LOD still communicates “it learned you.”  
6. Colorblind / grayscale: fossil vs fresh wall vs floor still distinct (`FossilPalette` patterns stay).

---

## 9. Cloud-only caveat

This document is authored for the **Cloud Agent lane**: contracts, budgets, and migration order only. It does **not** claim on-device fps, GPU ms, or Verified sign-off. Implementation PRs must attach profiler notes or Deck QA traces against §6 before release docs mark performance ✅.
