# Echo Lattice — Art Direction V3

**Status:** vision lock (Field Ledger elevation)  
**Branch:** `cursor/vision-art-v3`  
**Owns:** materials · typography · lighting · fossil language · menu-as-object · chamber-as-page · asset + shader plan  
**Authorities it extends (does not replace):**  
[`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) · [`../ECHO_LATTICE/14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) · palette [`../../game/echo_lattice/art/palette/echo_lattice.palette.json`](../../game/echo_lattice/art/palette/echo_lattice.palette.json)

**One-line brief:** _Stop drawing boxes on cream. Build a document that remembers you — print shop, surveyor's kit, iron oxide on ledger paper._

VISUAL v2 retired the purple void. That was necessary. It is not sufficient. The playable slice still reads as **procedural rectangles wearing Field Ledger colors**. V3 is the elevation pass: every surface gets a material story, every UI piece becomes a physical object, every chamber reads as a **page in a bound field ledger**.

If a decision could be mistaken for generic AI fantasy-dungeon key art (cosmic violet, soft bloom, floating runes), it is wrong — even if it looks "premium" in isolation.

---

## 0. Diagnosis — why it still feels like boxes

| Layer | Shipped today (RC1 / VISUAL v2) | V3 target |
|---|---|---|
| Floors / walls | Palette-tinted `draw_rect` + a few 32px PNG stamps | Authored print materials with grain, edge tremor, join language |
| Checkpoint / start / goal | Nested rectangles drawn in `chamber.gd` | Rubber-stamp tiles with ink pressure + registration marks |
| Rewrite slam | Timed blit of one folding tile + code shadows | 12-frame origami atlas + cast-shadow shader |
| Menu | Index-card layout on paper clear-color | Physical card object: thickness, clip, punched holes, turned page |
| Type | `ThemeDB.fallback_font` (Inter-adjacent) | Condensed grotesk + newsprint serif + mono — licensed stack |
| Light | Flat fill; lantern mostly absent as a mask | Single chest-lantern hard falloff; page-edge ambient only |
| Fossil | Rust color on wall rects + 4 decals | Accretion language: silt → oxide veins → calcified join |

**Pillar test (unchanged, stricter):** mute the game, crop out chrome. A stranger must say: *"this maze is made of my footsteps on paper."* If they say *"puzzle game with brown walls,"* V3 has not landed.

---

## 1. Visual pillars (V3 restatement)

Carry Art Bible P1–P5. Add two enforcement rules for the elevation pass:

### P6 · Object honesty
UI and world share one physics of paper. Cards have edges and thickness. Pages cast soft contact shadows (ink-soft, not drop-shadow glow). Buttons are type on cardstock, not widgets. If an element floats with no substrate, reject it.

### P7 · Process visible
Every material should look like a **process** left a mark: letterpress crush, chalk scuff, oxide bloom, origami crease, rubber-stamp slap. Process is the anti-slop moat — AI moodboards emit glow; print shops leave residue.

---

## 2. Materials (print shop, not PBR fantasy)

Name materials the way a printmaker would. Engine shaders exist to **simulate process**, not to look like Unity stone packs.

### 2.1 Substrate stack (bottom → top)

| Layer | Material | Look | Engine note |
|---|---|---|---|
| **0 · Desk / lightbox** | Cool-neutral under-glow through paper | Barely cooler than `paper_bone`; never cyan neon | Clear color / margin: `paper_margin` ≈ bone darkened 8% toward ink |
| **1 · Ledger page** | Warm printer stock | Visible fiber, faint ledger sub-grid (4 px), deckled *suggestion* only at page edge | Tileable `paper_fiber_512.png` at ≤12% opacity, world-locked to page |
| **2 · Ink architecture** | Letterpress / ruling pen | Dense sepia; 0–1 px edge tremor; joins show butt or mitre stamps | Wall atlas with corner / T / cross, not stretched rects |
| **3 · Traffic** | Shoe chalk + graphite smear | Halftone stipple on walked floors; never wet mud | Decal stamps + `paper_deep` lerp by visit count |
| **4 · Fossil** | Iron oxide + silt | Veins from joins inward; matte, dusty, zero emissive | Rust atlas; colonization shader (see §8) |
| **5 · Apparatus** | Dry-plate copper / slate enamel | Keys, doors, wayfinding — tactile, etched | `copper_key` / `slate_teal` glyphs only |

### 2.2 Material cards (spec for artists)

**Fresh paper floor** — `paper_bone` base; 4 px ledger grid in `ink_soft` @ 6% opacity; micro fiber noise. No bevel. No AO puddle under the player.

**Walked paper floor** — same substrate shifted to `paper_deep`; elliptical chalk scuffs accumulate toward the tile center of mass of visits. Cap at 3 overlay stamps before fossil path takes over.

**Fresh ink wall** — fill `ink_black`; 1 px outer hairline in `ink_soft` on the paper side (letterpress squash). Corners use dedicated tiles — never two rects overlapping into a thicker join.

**Fossilized wall** — interior `rust_fossil`; join seams `rust_deep`; optional chalk dust on the top edge (surveyor's shoe kicked the ridge). Matte only. **Emissive = 0. Always.**

**Folding wall (transient)** — origami crease lines in `ink_soft`; paper lift shows contact shadow only (multiply toward `ink_black`, α ≤ 0.35). Lifetime ≤ slam duration.

**Checkpoint stamp** — circular / slightly oval rubber stamp in `slate_teal`, 2–4° random rotation locked per chamber seed, ink unevenness on 20% of the ring. Caption `§ NN` in condensed grotesk small caps.

**Start plate** — copper dry-plate rectangle, hairline rule, word `FIELD` or surveyor's mark — not a glowing spawn pad.

**Goal plate** — copper plate with open center (paper shows through); reads as a surveyor's bench mark, not a portal.

### 2.3 Ban list (materials)

- Normal-mapped dungeon stone, moss, blood, crystal, lava.
- Any emissive wall / floor / UI panel.
- Glass, frost, blur panels, neon tubes.
- Purple, magenta, holographic foil, rainbow gradients.
- Soft painterly AI haze as a "material."

---

## 3. Typography

Field Ledger is a **document game**. Type is half the art direction.

### 3.1 Locked stack

| Role | Face | Tracking / case | Where |
|---|---|---|---|
| **Display** | Condensed geometric grotesk (IBM Plex Sans Condensed **or** licensed Akkurat Condensed) | Tight (−40…−80); small caps for headers; title lockup may be full caps | Menu brand, chamber titles, wayfinding |
| **Body** | Newsprint serif (IBM Plex Serif / PT Serif) | Sentence case; 4 px baseline grid | Flavor, settings copy, habit profile |
| **Mono** | Grotesk mono (IBM Plex Mono) | Tabular figures; groups of four for seeds | Seed header, punch-card labels, debug |

**Hard rule:** three faces max. No fourth "cute" display. No script. No variable-font gimmick animation.

### 3.2 Hierarchy on a page

1. **Brand** — largest signal on shell screens (`ECHO LATTICE`). Must survive nav-removal brand test.
2. **Verb line** — one short sentence or motto (`IT LEARNED YOU`) in `slate_teal` small caps under a rust rule.
3. **Index** — underlined type list; selection = rust underline; hover = slate underline. No filled pills.
4. **Meta strip** — mono seed + punch-card on margins; never competing with brand size.

### 3.3 Motion of type

- Paper-turn or stamp-in. **No fade-from-black**, no blur-in, no tracking expand "cinematic" reveals.
- Numerals stamp in discrete increments (star count, chamber index).
- Nothing pulses or breathes. Paper is still; only the surveyor and chalk dust move.

### 3.4 Ship path

| Milestone | Action |
|---|---|
| V3-T0 | Vendor IBM Plex family (Sans Condensed + Serif + Mono) under `game/echo_lattice/fonts/latin/` with OFL notice |
| V3-T1 | Theme + `menu.gd` / chamber HUD stop using `ThemeDB.fallback_font` for brand & seed |
| V3-T2 | Capsule / trailer lockups re-exported from the same faces |

---

## 4. Lighting

Lighting sells **paper thickness** and **one human tool**. It must never sell magic.

### 4.1 Sources (complete list)

| Source | Color | Shape | Rules |
|---|---|---|---|
| **Page ambient** | Slightly cooler desk light through stock | Full page, nearly flat | ±4% value drift max; no vignette crush to black |
| **Chest lantern** | `copper_key` warm | Hard disk, 1–3 tile radius | **Only** persistent diegetic light on the playfield. Falloff is stepped/dithered, not soft bloom |
| **Cadmium heartbeat** | `cadmium_warn` | Page-margin flash, ≤1 frame / ≤`REWRITE_HEARTBEAT` | Exclusive to rewrite warn + slam open. Nowhere else |
| **UI** | Unlit | — | Cards sit on lightbox; no dynamic lights on menus |

### 4.2 Falloff law (lantern)

```
intensity(d) =
  1.0                     if d ≤ 0.55 tiles
  lerp(1, 0.35, t)        if 0.55 < d ≤ 1.5   (t linear)
  lerp(0.35, 0.0, t)      if 1.5 < d ≤ 2.75
  0                       beyond
```

Edge is **ordered dither** into paper (4×4 Bayer or blue-noise tile), never Gaussian glow. Outside the disk, paper remains readable — the lantern is accent, not a flashlight horror sim.

### 4.3 Explicit lighting bans

- Screen-space bloom, god-rays, volumetric fog, lens flare.
- Colored rim lights, purple bounce, neon fill.
- Full-screen rewrite white flash (removed; do not reintroduce).
- Ambient occlusion that turns corridors into caves.

---

## 5. Fossil language

Signature verb: **calcification, not radiance.** V3 makes the stages unmistakable at thumbnail size.

### 5.1 Stages (S0–S3) — production truth

| Stage | Name | Trigger | Read at 32 px | Asset / shader |
|---|---|---|---|---|
| **S0** | Chalk kiss | Enter tile | Pale heel/toe stamp | `decals/chalk_footprint_01..04.png` |
| **S1** | Traffic stain | In move buffer / revisit | Floor → `paper_deep` + halftone | `tiles/floor_walked_32` + `shader_traffic_stipple` |
| **S2** | Crease | Checkpoint commits tile | Origami fold lines, paper lifts | `vfx/origami_slam_12.tres` atlas |
| **S3** | Fossil wall | Rewrite complete | Rust body + deep seams | `wall_fossilized_*` + `decals/rust_01..08` |

### 5.2 Habit colonization (between rewrites)

Over-walked floors gain rust **before** they become walls:

- Every N traversals (design-tuned; deterministic from buffer bias) place one rust decal.
- Decal choice + rotation = hash(seed, cell, visit_bucket). Streamers can read abused corridors.
- Rust never appears on unwalked paper. **No ambient world rust.**

### 5.3 Ghost paths

- Self ghost: 1 px dashed `chalk_white` @ 60% opacity.
- Other / PB ghost: same dash in `slate_teal_soft`.
- No trails, smears, particles, or ribbons. Diagram line only (`ArtKit` dash helper or `shader_ghost_dash`).

### 5.4 Rewrite slam — trailer grammar (locked timing)

Total ≈ 0.90 s (`REWRITE_DURATION`). Sound-first (ink-pop → crease → chalk-scuff).

| Phase | t (norm) | Picture |
|---|---|---|
| Heartbeat | 0.00–0.06 | Cadmium on **page margin only** |
| Crease | 0.06–0.28 | Atlas frames 1–3; ink folds; no glow |
| Lift | 0.28–0.55 | Frames 4–6; cast shadow offset 2–4 px toward bottom-right |
| Slot | 0.55–0.78 | Frames 7–9; 1 px overshoot bounce |
| Bleed | 0.78–1.00 | Frames 10–12; rust from joins; emissive 0 |

Freeze hook for captures: `freeze_rewrite_at(0.55)` (lift/slot) remains the hero still.

### 5.5 Fossil anti-patterns

- Energy pulse, warp ripple, chromatic aberration burst, particle fountain.
- Purple / cyan "void cracks."
- Screen shake on rewrite (default off; document game).
- Confetti or juice fireworks on chamber clear — reward is the **shape you wrote**.

---

## 6. Menu as object

The shell is not a UI skin. It is a **loose field-index card clipped on a lightbox.**

### 6.1 Physical recipe

1. **Lightbox desk** — full-bleed paper field + ledger grid + screen-locked print grain (existing VISUAL v2).
2. **Index card** — single card per primary screen; 2–3 px contact shadow (`ink_black` @ 18–28% α, offset +5,+7); 1 px `ink_soft` border; optional corner radius ≤ 2 px.
3. **Clip / binding** — top edge suggests a binder clip or punched holes (subtle stamped marks, not skeuomorphic chrome photo).
4. **Brand block** — `ECHO LATTICE` as hero type; rust rule 2–3 px; motto in slate small caps.
5. **Field Index** — underlined entries only; focus rust / hover slate.
6. **Teaching strip** — seed mono + 30-cell punch-card on the card or page margin (diegetic loop lesson).
7. **Ambient chalk path** — optional dashed demo walk; discrete steps, no sin-α "breathe" on fossils.

### 6.2 Secondary shells

| Screen | Object treatment |
|---|---|
| Settings | Second index card slid over the first (paper turn), **not** dimmed `PanelContainer` glass |
| Won / end | Loose ledger leaf with stamp numerals for stars; same underline language |
| Credits | Column of condensed names on cardstock; mono roles |
| Pause | Half-height card; never full-screen darken > 35% |

### 6.3 Menu motion

- Enter: card slides 8–12 px from below + shadow settles (120–180 ms).
- Leave: paper turn (brief edge flip) or lateral slide — **no crossfade through black**.
- Confirm: rust underline stamps thicker for 1 frame; UI click tick (never on `_ready`).

### 6.4 Menu asset kit (concrete)

See §9.A. Minimum identity set: `ui/index_card_backer.png`, `ui/binder_clip_mark.png`, punch-card cells (shipped), etched icons ×6, font stack (§3).

---

## 7. Chamber as page

A chamber is not a "level in a frame." It is a **numbered leaf in the Field Ledger.**

### 7.1 Page anatomy

```
┌─ paper margin (desk) ─────────────────────────────────────┐
│  seed header (mono, printed)                              │
│  ┌─ page (bone) ─ ink rule ─────────────────────────────┐ │
│  │  chamber title / § index (display small caps)         │ │
│  │                                                       │ │
│  │     [ lattice diagram — walls, fossils, surveyor ]    │ │
│  │                                                       │ │
│  │  wayfinding marks on walls (slate, rare)              │ │
│  └───────────────────────────────────────────────────────┘ │
│  punch-card ribbon (30 cells) · habit caption             │
└───────────────────────────────────────────────────────────┘
```

Rules:

- ≥ 2-tile **visible** paper margin on all sides at reference zoom.
- Page always shows a soft contact shadow onto the desk.
- No edge-bleed maze into the void — if you see monitor bezel color, the margin failed.
- Cap chamber ≤ 32×20 tiles (Art Bible); diagram first, spectacle never.

### 7.2 Diegetic chrome (required)

| Element | Placement | Content |
|---|---|---|
| Seed header | Top margin | Seed in 4×4 mono groups |
| Punch-card | Bottom margin | Last ≤30 moves; empty → filled → rust → warn cells |
| Checkpoint | On tile | Rubber stamp (§5 / materials) |
| Habit caption | Bottom or side margin | Short plain sentence; serif or condensed; not a toast |

### 7.3 Surveyor on the page

- Silhouette-first 24–32 px stamp; hood + chest lantern warm point (`copper_key`).
- Walk cycle 4 directions × 4 frames; idle is still (2-frame "listen" only if it does not pulse scale).
- Lantern mask from §4; player remains legible in grayscale audit.

### 7.4 What chamber-as-page forbids

- Floating minimap orbs, XP bars, glass habit meters.
- Non-diegetic damage vignettes, blood overlays.
- Camera roll, dramatic perspective skew — keep orthographic diagram honesty (gentle parallax of shadow during slam lift is OK).

---

## 8. Shader & VFX plan

All shaders: Godot 4.x `CanvasItem` / screen blit friendly; **no SM 6.0 requirement**; integrated GPU target (Steam Deck class).

### 8.1 Shader inventory

| ID | Type | Purpose | Key uniforms | Priority |
|---|---|---|---|---|
| `shader_print_grain` | Screen / full-rect | Tiled grain, screen-locked, `ink_soft` @ ≤8% | `grain_tex`, `opacity`, `time` (static preferred) | **P0** (exists in spirit via ArtKit — formalize) |
| `shader_paper_fiber` | Page background | World-locked fiber + ledger grid | `fiber_tex`, `grid_px`, `grid_a` | P0 |
| `shader_lantern_mask` | Light overlay | Hard falloff disk + Bayer dither | `center`, `radius_tiles`, `copper`, `dither_tex` | **P0** |
| `shader_ghost_dash` | Line strip | Dashed chalk / slate path | `dash`, `gap`, `color`, `phase` | P1 |
| `shader_traffic_stipple` | Floor modulate | Halftone darken by visit weight | `visits`, `stipple_tex` | P1 |
| `shader_rust_colonize` | Decal / floor | Reveals rust atlas by bias hash | `atlas`, `threshold`, `seam_color` | P1 |
| `shader_origami_lift` | Slam cells | Contact shadow + UV lift without bloom | `lift`, `shadow_dir`, `shadow_a` | **P0** |
| `shader_stamp_ink` | Checkpoint / UI | Uneven ring opacity, micro rotation | `ink_noise`, `rot_deg`, `slate` | P1 |
| `shader_cadmium_margin` | Screen edge | Margin-only warn flash | `pulse` (0–1), `thickness_px` | P0 (code today → shader optional) |
| `shader_sepia_lut` | Optional post | Subtle chromatic sepia; off by default for a11y | `lut_tex`, `strength` | P2 |
| `shader_colorblind_patterns` | Role overlays | Existing pattern channel; keep non-color | `role_id`, `pattern_tex` | P0 (maintain) |

### 8.2 VFX clips (authored frames, not particles)

| Clip | Frames | Size | Notes |
|---|---|---|---|
| Origami slam strip | 12 | 32×32 per cell (atlas) | Drives S2→S3; replaces single `wall_folding` blit |
| Chalk stamp settle | 3 | 32×32 | Optional; can be instant S0 |
| Rubber stamp slap (UI / checkpoint) | 4 | 64×64 | Ink bloom **as transparency unevenness**, not glow |
| Page turn (menu) | 6 | 256×256 card | Edge flip; used in shell transitions |
| Punch-card punch | 2 | cell size | Empty → filled discrete |

**Particle policy:** prefer zero. If used, only chalk dust motes (≤8, `chalk_white`, no additive bloom) on slam slot — killable by reduce-motion.

### 8.3 Post stack (legal order)

```
page render → lantern multiply/dither → diegetic decals →
ghost dash → HUD margins → print grain (screen) → optional sepia LUT
```

Never insert bloom, glare, or full-screen color grade that violates palette ratio law (~65% paper / 20% ink / ≤15% rust late-run / ≤1% cadmium).

### 8.4 Performance budgets

| Effect | Cap |
|---|---|
| Grain | One 512×512 tile; full-screen blit ≤1 draw |
| Lantern | One overlay quad or tile-light pass |
| Slam | Only rewriting cells animate; others static |
| Decals | ≤3 chalk + ≤2 rust per cell; atlas batching |
| Reduce motion | Skip heartbeat, shorten slam, skip dust |

### 8.5 Implementation map (code)

| Concern | Likely home |
|---|---|
| Palette tokens | `scripts/palette.gd` |
| Texture helpers | `scripts/art_kit.gd` |
| Page + slam | `scripts/chamber.gd` → gradually replace `draw_rect` paths with atlas + shaders |
| Menu object | `scripts/menu.gd` + `ui/index_card_backer` |
| Capture freeze | existing `freeze_rewrite_at` |

---

## 9. Concrete asset list

Paths relative to `game/echo_lattice/art/` unless noted. **MVP = Next Fest / demo craft. V3 marks what elevates past procedural boxes.**

### 9.A · Shell / menu object

| Asset | Spec | Status target |
|---|---|---|
| `ui/index_card_backer.png` | 512×640, bone card, 1 px ink rule, subtle fiber | **V3 must** |
| `ui/index_card_backer_ruled.png` | Optional faint horizontal rules | V3 |
| `ui/binder_clip_mark.png` | 64×32 slate/ink stamp | V3 |
| `ui/punchcard_cell_{empty,filled,rust,warn}.png` | Shipped placeholders → inked finals | Polish |
| `ui/seed_header_256x24.png` | Mono ticket strip | Polish |
| `ui/icons/{undo,restart,seed,ghost,transform,options}.png` | 24×24 etched single-weight | **V3 must** |
| `ui/page_turn_01..06.png` | Menu transition | V3 |
| Fonts under `fonts/latin/` | Plex Condensed / Serif / Mono | **V3 must** |

### 9.B · Chamber page / tiles (32 px)

| Asset | Notes |
|---|---|
| `tiles/floor_fresh_32.png` | Fiber + grid (replace flat) |
| `tiles/floor_walked_32.png` | Traffic stain |
| `tiles/floor_checkpoint_32.png` | Rubber stamp — **kills procedural squares** |
| `tiles/floor_start_32.png` | Copper field plate |
| `tiles/floor_goal_32.png` | Open copper bench mark |
| `tiles/wall_fresh_32.png` | Letterpress edge |
| `tiles/wall_fossilized_32.png` | Oxide body |
| `tiles/wall_folding_32.png` | Crease still (atlas supersedes mid-slam) |
| `tiles/wall_corner_{ne,se,nw,sw}.png` ×4 | Clean joins |
| `tiles/wall_tjunction_{n,e,s,w}.png` ×4 | Clean joins |
| `tiles/wall_cross_32.png` | Optional |
| `tiles/door_32.png` / `tiles/key_32.png` | Wire into content **or** cut from MVP (no orphans) |

### 9.C · Character

| Asset | Notes |
|---|---|
| `tiles/player_stamp_24.png` | Idle final |
| `tiles/player_walk_{n,e,s,w}_{0..3}.png` | 16 frames silhouette-first |
| `lights/lantern_mask_96.png` | Hard falloff disk for §4 |

### 9.D · Decals & fossil

| Asset | Notes |
|---|---|
| `decals/chalk_footprint.png` (+ `_02..04`) | S0 variants |
| `decals/rust_01..08.png` | Extend past 04; deterministic pick |
| `decals/halftone_stipple_64.png` | Traffic shader support |
| `vfx/origami_slam_12.png` (atlas) | Trailer beat |

### 9.E · Page / grain / LUT

| Asset | Notes |
|---|---|
| `paper/fiber_512.png` | World-locked page noise |
| `paper/grain_512.png` | Screen-locked print grain (may already be generated) |
| `paper/ledger_grid_slice.png` | Optional; can be shader-drawn |
| `luts/sepia_soft_16.png` | Optional post; a11y-gated |

### 9.F · Shaders (`.gdshader` / `.tres`)

| Path | Ties to §8 |
|---|---|
| `shaders/print_grain.gdshader` | `shader_print_grain` |
| `shaders/paper_fiber.gdshader` | `shader_paper_fiber` |
| `shaders/lantern_mask.gdshader` | `shader_lantern_mask` |
| `shaders/ghost_dash.gdshader` | `shader_ghost_dash` |
| `shaders/traffic_stipple.gdshader` | `shader_traffic_stipple` |
| `shaders/rust_colonize.gdshader` | `shader_rust_colonize` |
| `shaders/origami_lift.gdshader` | `shader_origami_lift` |
| `shaders/stamp_ink.gdshader` | `shader_stamp_ink` |

### 9.G · Store / capture (art-direction facing)

| Asset | Spec |
|---|---|
| Capsules | Header 460×215, main 616×353, small 231×87 — Field Ledger finals, palette JSON hex only |
| Library hero | **3840×1240** ledger spine, six chambers, rust vs clean contrast |
| Screenshots | ≥1920×1080: reading maze / rewrite @0.55 / ghost race / habit profile / ledger |
| Client icon | Rust infecting grid; legible at 32×32 |

### 9.H · Explicit non-goals (V3)

- Character customization, cosmetic skins, battle-pass frames.
- Wing II–IV tint packs (Blueprint / Newsprint / Slate) — scheduled 1.0, not V3 blockers.
- Diagonal bevel tileset — gated on transform pack.
- AI upscales of placeholders as "finals."
- Any purple / bloom / glass revival.

---

## 10. Palette ratio law (unchanged, enforced in review)

Machine source: `echo_lattice.palette.json`.

| Family | Budget |
|---|---|
| Paper (`paper_bone` + `paper_deep`) | ~65% |
| Ink (`ink_black` + `ink_soft`) | ~20% |
| Rust habit | 0% → ~15% across a run |
| Slate signage | ~4% |
| Cadmium | **≤1%**, warn/heartbeat only |

**Anti-slop hex ban (non-exhaustive):** `#7F00FF`, `#B026FF`, `#8A2BE2`, neon cyan, hot magenta, vaporwave gradients, lava-on-black, TV green.

Marketing hex tables **must** match the JSON (fix capsule README drift).

---

## 11. Acceptance tests (V3 done means)

1. **Brand test** — main menu with nav labels removed still reads Echo Lattice / Field Ledger.
2. **Box test** — freeze a mid-run frame: walls show joins/tremor; checkpoint is a stamp; not nested `draw_rect` squares.
3. **Grayscale test** — player / floor / wall / fossil / door-or-goal / telegraph distinct without hue (`--art-grayscale-audit` or capture suite).
4. **Mute trailer test** — warn → margin heartbeat → crease → lift → rust readable silent.
5. **Menu object test** — settings is a card, not a frosted panel; no UI click on boot.
6. **Lantern test** — only copper hard disk; no bloom screenshot in press kit.
7. **Purple test** — automated or human: zero banned hues in `art/**` and capsules.
8. **Performance** — Deck-class target; grain + lantern + slam within §8.4 caps; reduce-motion path verified.

---

## 12. Sequencing (technical, not calendar)

```
Fonts (T0) ──┬──► Menu object backer + icons ──► Settings as card
             │
Tile joins + stamp floors ──► Replace procedural checkpoint/start/goal
             │
Origami 12-atlas + origami_lift shader ──► Trailer still @0.55 re-capture
             │
Lantern mask shader ──► Surveyor walk cycle
             │
Rust 05–08 + colonize shader ──► Habit-readability screenshot
             │
Capsule / hero / 1080p tour re-export from finals
```

Validation after each band:

```bash
cd game/echo_lattice
godot --headless --path . -- --selftest
python3 art/generate_placeholders.py   # only while placeholders remain
./tools/capture_v2_complete.sh         # or successor capture
```

---

## 13. References (human taste)

Keep Art Bible §8. Especially: Vignelli subway clarity, Rams restraint, Saville margin confidence, Obra Dinn / Papers, Please substrate honesty, Mini Metro informational color.

**Not references:** mystical dungeon AI boards, cyberpunk neon, painted fantasy roguelike heroes, Unity stone+bloom packs.

---

## 14. Change log

| Ver | Note |
|---|---|
| **V3.0** | Elevation vision: materials, type, light, fossil language, menu-as-object, chamber-as-page, concrete assets, shader/VFX plan. Extends Art Bible v0.1 + VISUAL v2; targets retirement of procedural box read. |

---

## 15. Doc map links

| Doc | Role after V3 |
|---|---|
| [`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) | Pillars, palette, MVP lists — still binding |
| [`14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) | Historical: purple→paper implementation notes |
| [`../AUDIT/AUDIO_ART_UX.md`](../AUDIT/AUDIO_ART_UX.md) | Gap scorecard vs placeholders |
| [`../AUDIT/UPGRADE_LIST.md`](../AUDIT/UPGRADE_LIST.md) | P3 art tickets map onto §9 |
| **This file** | Elevation authority for unmistakable Field Ledger craft |
