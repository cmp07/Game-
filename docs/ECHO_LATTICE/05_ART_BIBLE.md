# Echo Lattice — 05 · Art Bible

**Status:** v0.1 (MVP-locking draft) · **Owner:** art direction · **Depends on:** the Echo Lattice concept + design docs authored on sibling branches — the game pitch in [`docs/FIVE_GAMES_TO_BUILD.md` (PR #29)](https://github.com/cmp07/Game-/blob/cursor/five-games-deep-dive-93f7/docs/FIVE_GAMES_TO_BUILD.md) and the direction shortlist in [`docs/research/INVENTIVE_DIRECTION_SHORTLIST.md` (PR #20)](https://github.com/cmp07/Game-/blob/cursor/generative-reality-master-synthesis-0ab6/docs/research/INVENTIVE_DIRECTION_SHORTLIST.md). Docs `01–04` of this folder are expected to land on their own branches; this doc does not block on them.

**One-line art brief:** _A brutalist subway map that watches you walk and calcifies your habits into architecture. Ink on paper, not glow on void._

Every rule below exists to prevent the game from looking like an AI-generated Discord banner. If a decision reduces cohesion or drifts toward generic "mystical purple glow," it is wrong for Echo Lattice, no matter how pretty in isolation.

---

## 1. Visual pillars

Five pillars. Any asset that fails two of them ships back to the drawing board.

### P1 · Legibility above spectacle
The maze is a **document you can read**. Every wall exists because the player made it; the frame is a diagram, not a mood-piece. Diagrammatic clarity always beats painterly murk. If a first-time viewer cannot tell in five seconds that "the walls are the player's own footprints," we have failed pillar one.

### P2 · Ink on paper, not glow on void
Base material is warm printed paper. Ink is dense sepia black, not gamer-black. Line quality is drawn, not lasered — a soft tremor in the stroke is welcome. No bloom, no lens flare, no volumetric fog, no god-rays. Light is diegetic (chest lantern, ledger lamp) or absent.

### P3 · Fossilization, not radiance
Old paths do not **glow** — they **harden**. Rust veins, silt, calcified stone growing out of clean paper. Time in Echo Lattice is entropy, not enchantment. The visual verb is *accretion*, not *emission*.

### P4 · One person's color
Each run has a single **habit accent** (rust). It doesn't decorate the world — it **colonizes** the tiles the player over-walks. The player's behavior wears the maze. This is the anti-slop moat: cohesion is enforced by *player behavior*, so the aesthetic can never devolve into a paint-by-numbers glow soup.

### P5 · Cartographer's honesty
Every visual element carries information — seed, buffer, transform kind, ghost path, distance to next rewrite. No decorative flourishes without a job. If a designer wants to add a particle, they must name what data it encodes. HUD is diegetic (page header, punch-card ribbon, wayfinding signage), not a translucent overlay.

**Pillar test one-liner:** show a frame with no audio; if you cannot describe the game's core loop from that frame in one sentence, we owe pillar one more work.

---

## 2. Palette (single source of truth)

Machine-readable version: [`game/echo_lattice/art/palette/echo_lattice.palette.json`](../../game/echo_lattice/art/palette/echo_lattice.palette.json). Preview strip: [`game/echo_lattice/art/palette/palette_strip.png`](../../game/echo_lattice/art/palette/palette_strip.png).

### Core swatches

| Token              | Hex        | Role                                                                        |
|--------------------|------------|-----------------------------------------------------------------------------|
| `paper_bone`       | `#EFE6D2`  | Base surface — printer-warm cream. **Never pure white.**                    |
| `paper_deep`       | `#D9CDB0`  | Walked-on floor, worn ledger page.                                          |
| `ink_black`        | `#141210`  | Walls, glyphs, type — deep sepia black. **Never pure `#000000`.**           |
| `ink_soft`         | `#3A342C`  | Secondary line weight, halftone, print grain.                               |
| `chalk_white`      | `#F5EFDD`  | Ghost trails, footprints, buffer stamps.                                    |
| `rust_fossil`      | `#8B3A1F`  | The habit accent. Fossilized paths, hardened tiles.                         |
| `rust_deep`        | `#5E2412`  | Old rust seams; joins between fossilized tiles.                             |
| `slate_teal`       | `#2D4A55`  | Cold accent — signage, keys, doors. **The anti-purple.**                    |
| `slate_teal_soft`  | `#4A6D77`  | Ghost path dash, informational HUD.                                         |
| `cadmium_warn`     | `#D6432B`  | Rewrite-imminent flash. One heartbeat only.                                 |
| `copper_key`       | `#B8763A`  | Keys, doors, tactile interactables — dry-plate etch.                        |

### Ratio law (per screen, per chamber)

- **~65%** paper family (`paper_bone` + `paper_deep`).
- **~20%** ink family (`ink_black` + `ink_soft`).
- **~10%** habit accent (`rust_fossil` + `rust_deep`) — starts near 0% early-run, ends near 15% late-run. Rust growth is the visual dopamine of the game; do not front-load it.
- **~4%** slate (`slate_teal` family) for signage and interactables.
- **≤1%** cadmium warn — reserved exclusively for the rewrite-imminent heartbeat and death-adjacent feedback.

### Wing tints (1.0, not MVP)

Each wing of the game is a chapter of the ledger and gets a paper tint shift, still inside the ledger family. **Never** invent new hues — only shift `paper_bone` and `paper_deep`.

| Wing | Codename          | Paper shift                          | Ink shift            |
|------|-------------------|--------------------------------------|----------------------|
| I    | Field Ledger      | Baseline bone                        | Baseline sepia       |
| II   | Blueprint         | Bone → cool cyanotype tint           | Ink → prussian sepia |
| III  | Newsprint Red     | Bone → warm off-yellow               | Ink → carbon black   |
| IV   | Slate & Chalk     | Bone → slate paper                   | Ink → chalk-inverted |

### Ban list (art-direction enforceable)

Do not commit assets containing any of these. Ever.

- Neon purple (`#7F00FF`, `#B026FF`, `#8A2BE2`, or any "cosmic mystery" saturated violet).
- Neon cyan, cyberpunk pink, hot magenta.
- Rainbow gradients, holographic gradients, "vaporwave" grids.
- Lava orange on pure black. TV-scanline green as accent.
- Generic bloom halos, lens flares, purple particle sparkle.
- Hexagonal HUD frames, glass-morphism / frosted panels.
- Fantasy runes, arcane sigils, glowing eldritch dust.
- AI-illustration painterly blur (soft-focus non-diegetic haze).
- Pure `#000000` and pure `#FFFFFF` anywhere in production art.

---

## 3. Silhouette rules

**Player character — "the surveyor":**

- Hooded figure with a **chest lantern** (not a floating orb, not a wand). One ink stroke on paper.
- Silhouette must read at **32×32 px** with no color detail: triangular torso, soft head, faint lantern warm spot on the chest.
- The lantern is a **single-frequency warm light** (`copper_key`). It illuminates a small circle of the current tile. It is **not** a magical aura and it never emits particles.
- The lantern is the **only** persistent light source in the frame. UI is unlit.
- Reference stamp shipped as [`game/echo_lattice/art/tiles/player_stamp_24.png`](../../game/echo_lattice/art/tiles/player_stamp_24.png).

**Enemies (post-MVP only):** geometric mistakes. A rectangle that turned wrong. A hexagon missing a wall. Never anthropomorphic. Never faced.

**The lattice:**

- 1-tile-thick walls in MVP.
- **Right angles only in MVP.** Diagonals are gated behind the `bevel` transform pack (v1.0 asset lane).
- Chamber width **≤ 32 tiles** and height **≤ 20 tiles**. Chambers must sit inside a **≥ 2-tile paper margin** — the frame is *always* visibly ledger paper. No edge-bleed.

**Legibility contract:**

- At 100% zoom on a 1080p display, the player silhouette occupies **~28×28 px** actual. A player with only rod-cell vision (grayscale) must be able to distinguish player / wall / floor / fossilized wall / door / key without color cues.
- We validate this by shipping a `--art-grayscale-audit` runtime flag from day one.

---

## 4. Materials

Materials are named the way a printmaker would name them — the process and the substrate — not the way a shader engineer would.

| Material                  | Substrate                                     | Behavior                                                                                   | Reference                                                                                                       |
|---------------------------|-----------------------------------------------|--------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| **Fresh paper floor**     | `paper_bone` w/ faint 4px ledger sub-grid     | Static, warm, slightly noisy.                                                              | [`tiles/floor_fresh_32.png`](../../game/echo_lattice/art/tiles/floor_fresh_32.png)                              |
| **Walked paper floor**    | `paper_deep` w/ halftone footfall             | Muddied by traffic; darkens with each step over threshold.                                 | [`tiles/floor_walked_32.png`](../../game/echo_lattice/art/tiles/floor_walked_32.png)                            |
| **Fresh ink wall**        | `ink_black` bordered onto `paper_bone`        | Static, sharp; edge tremor allowed (≤1 px).                                                | [`tiles/wall_fresh_32.png`](../../game/echo_lattice/art/tiles/wall_fresh_32.png)                                |
| **Fossilized wall**       | `rust_fossil` + `rust_deep` seams on paper    | Emerges only after a rewrite. Cannot appear from nothing.                                  | [`tiles/wall_fossilized_32.png`](../../game/echo_lattice/art/tiles/wall_fossilized_32.png)                      |
| **Folding / rewrite wall**| Origami crease overlay on paper               | Transient (~600 ms). Never a persistent material.                                          | [`tiles/wall_folding_32.png`](../../game/echo_lattice/art/tiles/wall_folding_32.png)                            |
| **Door**                  | `slate_teal` inset frame w/ `copper_key` bolt | Silhouette-diagnostic against wall.                                                        | [`tiles/door_32.png`](../../game/echo_lattice/art/tiles/door_32.png)                                            |
| **Key**                   | `copper_key` etched glyph                     | Reads at 12 px.                                                                            | [`tiles/key_32.png`](../../game/echo_lattice/art/tiles/key_32.png)                                              |
| **Water / quench zone**   | Ink bleed puddle on paper (1.0 asset)         | Slows lantern light; ghost path bends around it.                                           | *(post-MVP)*                                                                                                     |

**Shader/material rules the engine must respect:**

1. **No screen-space bloom.** Ever. Lantern light is a hard 1-tile falloff with a soft-dither edge.
2. **No global fog.** Ever.
3. **Post-processing is limited to:** paper-grain noise (very light), subtle chromatic sepia LUT, optional CRT-style paper filter as a **diegetic** accessibility option.
4. **Print grain**: a single 512×512 tiled grain texture, `ink_soft` on transparent, 8% opacity max, screen-locked (not world-locked). One noise, everywhere. Cohesion via constraint.

---

## 5. VFX language — fossilized paths

This is the game's signature. Everything else in the art bible defers to it.

### The core visual verb: **calcification, not radiance**

When the player walks a tile, it does **not** light up. Nothing pulses. Nothing hums with energy. The tile picks up chalk dust from the surveyor's shoes, and if the player revisits or over-uses it, the dust settles, silts in, and eventually **fossilizes into stone**.

The animation is print, physics, and geology — not magic.

### Four stages of a fossilized path

Every walked tile passes through up to four visible states. Each state has a shipped placeholder tile.

| Stage | Trigger                                     | Look                                                             | Duration     | Substrate reference                                                                                     |
|-------|---------------------------------------------|------------------------------------------------------------------|--------------|---------------------------------------------------------------------------------------------------------|
| S0    | Player enters tile                          | **Chalk footprint** stamp (`chalk_white`) on `paper_bone`.       | Instant.     | [`decals/chalk_footprint.png`](../../game/echo_lattice/art/decals/chalk_footprint.png)                  |
| S1    | Tile in move buffer                         | Floor darkens to `paper_deep`, faint halftone stipple.           | Persistent while in buffer. | [`tiles/floor_walked_32.png`](../../game/echo_lattice/art/tiles/floor_walked_32.png)  |
| S2    | Checkpoint fires, tile chosen for rewrite   | **Paper origami crease** overlays tile.                          | ~600 ms.     | [`tiles/wall_folding_32.png`](../../game/echo_lattice/art/tiles/wall_folding_32.png)                    |
| S3    | Rewrite complete → wall                     | Rust veins into stone at edges; `rust_fossil` interior.          | Persistent.  | [`tiles/wall_fossilized_32.png`](../../game/echo_lattice/art/tiles/wall_fossilized_32.png) + rust decals in [`decals/`](../../game/echo_lattice/art/decals/) |

Rust decal set (four rotational variants): [`decals/rust_01.png`](../../game/echo_lattice/art/decals/rust_01.png), [`_02`](../../game/echo_lattice/art/decals/rust_02.png), [`_03`](../../game/echo_lattice/art/decals/rust_03.png), [`_04`](../../game/echo_lattice/art/decals/rust_04.png).

### The rewrite moment (the "It learned you" beat)

This is the trailer. Get it right.

- **Sound-first design.** Ink-pop + paper-crease + a single deep chalk-scuff. Roughly 240 ms of audio; the VFX is timed to it.
- **12-frame paper origami slam:** walls fold up out of the floor in the exact shape of the last 30 moves.
  - **Frames 1–3:** creases appear along the doomed tiles (S2).
  - **Frames 4–6:** paper lifts a shadow (no rim light — a *cast shadow*).
  - **Frames 7–9:** walls slot into place with a 1-pixel over-shoot bounce.
  - **Frames 10–12:** rust bleeds in from the joins (S3).
- **Never a glowy warp effect.** No screen-space distortion, no colored energy pulse, no time-freeze bloom.
- **One heartbeat of `cadmium_warn`** at frame 1 — a single-frame paper-margin flash — telegraphs the rewrite. Nowhere else in the game uses this color.

### Habit colonization (accretive rust)

Between rewrites, tiles the player over-uses **slowly gain rust decals** — one every N traversals. This is the ambient story of a run:

- A run that starts as clean paper ends as a rust-veined ledger.
- The rust pattern is a **deterministic function of the move buffer** (mirrored in the design doc): a streamer can look at a mid-run frame and *read* which direction that player has abused.
- Rust never appears on the floor of an un-walked tile. If a tile has rust on it, the player put it there.

### Ghost paths

- Ghost of your last 30 moves = **thin dashed chalk line** in `chalk_white` at 60% opacity.
- Ghost of a previous run (or a friend, or your best time) = same dash pattern in `slate_teal_soft`.
- Ghosts do **not** particle-trail. They do not smear. They are a **1-pixel dashed diagram line** over the paper.

### What we are explicitly not doing

- No screen-shake on rewrite. Screen-shake belongs to physics games; Echo Lattice is a document game.
- No confetti / juice VFX on completion. The reward is the *shape* of what you made.
- No arcane sigils under the player. No glowing eldritch dust around the lantern. No purple.
- No "checkpoint aura." The checkpoint is a **stamp** printed on the paper. See §7 for the stamp mark.

---

## 6. UI look

**North star:** a cartographer's field notebook clipped inside a brutalist wayfinding sign.

**Universal rules:**

- HUD is **diegetic wherever possible**. It is printed onto the paper of the world.
- No translucent panels. No blur. No drop shadows. No rounded corners > 2 px.
- All UI type sits on a 4 px baseline grid.
- One display font (geometric grotesk), one body font (newsprint serif), one mono font (grotesk mono). No fourth font. No script or display face.
- Icons are **etched glyphs**, single-weight, single-color. Reference weight matches `ink_black`.

### HUD elements (MVP)

| Element              | Where                                             | What it shows                                                                          | Style                                                                                                     |
|----------------------|---------------------------------------------------|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| **Seed header**      | Printed onto the top page margin, ~24 px          | Seed string in mono, four groups of four                                               | [`ui/seed_header_256x24.png`](../../game/echo_lattice/art/ui/seed_header_256x24.png)                      |
| **Move-buffer ribbon** | Bottom page margin                             | Punch-card of the last 30 moves; each cell = one direction                             | Cells: [`ui/punchcard_cell_empty.png`](../../game/echo_lattice/art/ui/punchcard_cell_empty.png) → [`_filled`](../../game/echo_lattice/art/ui/punchcard_cell_filled.png) → [`_rust`](../../game/echo_lattice/art/ui/punchcard_cell_rust.png) → [`_warn`](../../game/echo_lattice/art/ui/punchcard_cell_warn.png) |
| **Ghost path**       | On-world                                           | Thin dashed line of last 30 moves                                                      | See §5, "Ghost paths"                                                                                     |
| **Checkpoint stamp** | Prints onto the tile the checkpoint fires on      | A rubber-stamp mark ("§ 03", "§ 04"…) in `slate_teal`, faintly rotated                 | *(1.0 asset; MVP uses simple square)*                                                                     |
| **Wayfinding sign**  | On specific walls, diegetic                        | Chamber name & direction in condensed grotesk                                          | Brutalist arrow-and-word only                                                                             |

### Menus / index-card typography

- Menus feel like **loose index cards on a lightbox**.
- One card per screen. If the design needs more than one card, split the screen.
- Buttons are underlined type. Selection state = a rust underline. Hover = a slate underline. Never a colored fill.
- No modal shadows; cards sit on the paper.

### Typography stack

- **Display:** Akkurat / Inter Tight / IBM Plex Sans Condensed (small caps, tight tracking).
- **Body:** IBM Plex Serif or PT Serif.
- **Mono (seed strings, buffer):** IBM Plex Mono.
- **Fallback for MVP builds:** ship Godot's default Inter as display and Noto Serif as body, then swap in final licenses before store page.

### Motion rules for UI

- Menu transitions are **paper turns**, never fades. 1 frame black-on-black between cards is forbidden.
- Numbers count up in **discrete stamped increments**, not rolling odometers.
- Nothing pulses. Nothing "breathes." The paper is still.

---

## 7. Capsule & trailer stills

Written as brief shots. All frames obey the palette ratio law (§2) and pillars P1–P5.

### Steam capsule set

- **Header capsule (460×215).** *"Mid-step, the walls agreeing."* A surveyor mid-step in a clean, right-angled corridor. Behind them, three walls are visibly folding up from the floor in origami creases — in the exact shape of a doorway shaped like their footprints. Rust creeps along one wall. Type: `ECHO LATTICE` in tall condensed grotesk, `ink_black` on `paper_bone`. Tagline (small caps, `slate_teal`): `IT LEARNED YOU`. Placeholder thumb: [`keyart/capsule_header_460x215_thumb.png`](../../game/echo_lattice/art/keyart/capsule_header_460x215_thumb.png).
- **Main capsule (616×353).** Same key visual, low 3/4 angle. Chest lantern lit; chalk footprints receding behind player; chalk ghost of the player's previous route visible as a dashed line arcing across the room; a checkpoint stamp (`§ 04`) printed on the tile the player is about to step onto.
- **Small capsule (231×87).** Silhouette of surveyor stepping through a folded-paper doorway. Zero background detail. Title lockup on a single line.
- **Library hero (3840×1240).** Wide overhead diagrammatic view of a full wing. Chambers rendered as **pages in a bound ledger** — the spine is visible down the middle. Three chambers show heavy rust colonization, three are clean paper. Ghost path threads all six. Motto: `IT LEARNED YOU`.

### Trailer stills — five beats (0–15 s)

1. **T=0–3s · First step.** Clean ledger corridor, camera flat overhead. Surveyor takes one step; a chalk footprint drops behind them. **Text:** `Deterministic.`
2. **T=3–6s · Buffer fills.** Camera pulls back to reveal the punch-card ribbon on the bottom margin filling in real time, and the seed header printed on the top margin. **Text:** `Same seed. Different you.`
3. **T=6–9s · Checkpoint fires.** Paper origami slam. Walls fold up in the exact shape of the last 30 moves. Single `cadmium_warn` heartbeat on frame 1. **Text:** *(none — let the sound land)*
4. **T=9–12s · Rust colonization.** A second, later run: tiles the player over-walks turn rusty in front of the camera. Rust decals accumulate on tiles matching the buffer's dominant direction. **Text:** `The maze wears you.`
5. **T=12–15s · Habit ghost race.** Two chalk-ghost silhouettes racing themselves through mirrored geometry. Title card: `ECHO LATTICE` · `IT LEARNED YOU` · `Wishlist on Steam`.

### Screenshot brief (for the Steam page)

Ship these five screenshots. Each must be silent-legible.

1. **Reading the maze.** Overhead of a mid-run chamber; rust colonization on the west corridor tells the story.
2. **The rewrite.** Mid-slam frame — walls folding, `cadmium_warn` margin heartbeat.
3. **Ghost race.** Two dashed chalk lines through the same chamber; one `chalk_white`, one `slate_teal_soft`.
4. **The habit profile.** End-of-wing screen: index-card stamp readout of the player's dominant transforms.
5. **The ledger.** Library hero-style wide of a wing; six chambers, three rusted, three clean.

---

## 8. Anti-slop guardrails (human taste, on the record)

The prompt-space reflex for "adaptive maze game" is neon purple, arcane sigils, and a soft cosmic glow. **We are the opposite of that game.** These references are the human vocabulary we're drawing from — read them, don't just paste them into a moodboard.

### References (design + illustration)

- **Massimo Vignelli, NYC subway diagram (1972).** Diagrammatic clarity as *the* fantasy.
- **Dieter Rams, Ten Principles.** Restraint. If a decoration doesn't have a job, kill it.
- **Peter Saville, Unknown Pleasures cover (1979).** One iconic mark on a huge margin. Confidence.
- **Chip Kidd, book jackets.** Typography as image. Wit through restraint.
- **Alexey Brodovitch, Harper's Bazaar spreads.** Editorial pacing — the margin *is* the design.
- **Bruno Munari, playful geometric primers.** Warmth without cuteness. Systems as toys.
- **Christoph Niemann, Sunday Sketching.** Visual wit at the size of an icon.
- **Louise Bourgeois's spider drawings.** Skittering line quality, hand tremor.

### Game references (aesthetic siblings, not clones)

- **Baba Is You** (rule as image; restraint; the world is language).
- **Return of the Obra Dinn** (single dominant palette; diagrammatic UI; a chalk-and-ink identity that a solo dev could ship).
- **Mini Metro / Mini Motorways** (diagrammatic, informational, one accent).
- **Downwell** (constraint palette; the color *is* the identity).
- **Papers, Please** (paper substrate; stamp aesthetics; menu-is-diegetic).

### Explicit "not like these" list

We are **not** trying to look like:

- Any AI-generated "mystical dungeon" moodboard.
- Cyberpunk 2077 fan art (neon on black).
- Fantasy roguelike storefronts (Slay-the-Spire-style painted characters).
- Generic Unity asset packs with normal-mapped stone and bloom.
- Rain-World-style biology-organic (adjacent taste, wrong substrate — Echo Lattice is paper, not flesh).

### Failure sniff-test (before merging any asset)

Ask, in order:

1. Would this frame look at home on a Vignelli-branded transit poster? *(If yes → good.)*
2. Could a stranger describe the game's loop from this frame in one sentence? *(If yes → good.)*
3. Is there a saturated purple, cyan, or magenta anywhere? *(If yes → reject.)*
4. Is there bloom, lens flare, or non-diegetic glow? *(If yes → reject.)*
5. If I remove every visual element, does the seed / buffer / rust story still land? *(If no → the frame is decoration; cut it.)*

---

## 9. Asset list

Two lists. **MVP** is what ships for the Next-Fest-quality demo. **1.0** is what ships for launch. Anything past 1.0 is out of scope for this bible.

### 9.1 · MVP asset list (demo-ready, ~4–6 art weeks equivalent)

**Tiles (32 px, PNG, no premultiplied alpha):**

- `floor_fresh_32.png` · `floor_walked_32.png` (placeholder shipped)
- `wall_fresh_32.png` · `wall_fossilized_32.png` · `wall_folding_32.png` (placeholder shipped)
- `door_32.png` · `key_32.png` (placeholder shipped)
- `wall_corner_ne/se/nw/sw.png` × 4 (**MVP task**)
- `wall_tjunction_n/e/s/w.png` × 4 (**MVP task**)
- `floor_checkpoint_32.png` (**MVP task**) — a printed stamp on the paper
- `floor_start_32.png`, `floor_goal_32.png` (**MVP task**)

**Character:**

- `player_stamp_24.png` idle (placeholder shipped)
- Player 4-direction walk cycle, 4 frames/direction (**MVP task**) — 16 frames total, silhouette-first
- Chest lantern light mask (1 sprite, 3-tile-radius, hard falloff)

**Decals:**

- `chalk_footprint.png` (placeholder shipped)
- `rust_01..04.png` (placeholder shipped) — extend to 8 variants (**MVP task**)
- Origami crease overlay (12 frames) — for wall_folding animation (**MVP task**)

**HUD / UI:**

- `seed_header_256x24.png` (placeholder shipped)
- Punch-card cells: empty / filled / rust / warn (placeholder shipped)
- Ghost path shader (1 material) (**MVP task**)
- Index-card menu backer (**MVP task**)
- Icon set: undo, restart, seed, ghost, transform, options (6 glyphs) (**MVP task**)

**VFX:**

- Rewrite-slam 12-frame sequence (**MVP task**)
- Chalk footprint stamp (procedural placement; art ships as decal above)
- `cadmium_warn` margin heartbeat (1 frame, screen-locked) (**MVP task**)

**Audio-facing material notes (for the audio bible, not this doc):** paper-crease, ink-pop, chalk-scuff, rust-crunch, ledger-turn.

**Store / marketing MVP:**

- Steam header capsule (460×215) — polish pass of the shipped thumb
- Main capsule (616×353)
- Small capsule (231×87)
- 5 screenshots (see §7)
- ~30 s wishlist trailer using the five beats in §7

### 9.2 · 1.0 asset list (launch-ready)

Adds, roughly in shipping order:

**Content packs:**

- Wings II–IV paper/ink tint packs (Blueprint, Newsprint Red, Slate & Chalk).
- 4 wayfinding sign variants per wing (16 total).
- Diagonal ("bevel") wall tileset (32 tiles) — unlocks with the bevel transform pack.
- Water/quench ink-bleed tile set (12 tiles).

**Transform VFX (12 total, each a paper-fold variant):**

- MVP-baseline: mirror, rotate, thicken, invert.
- 1.0 adds: bevel, zip, mirror-pin, decay, tessellate, braid, halve, echo.

**Character:**

- 8-direction walk cycle for surveyor.
- Idle "listening" pose (subtle 2-frame breathe).
- Ghost skins: chalk (baseline), silverpoint, blueprint, negative, coffee-stain.

**HUD / meta:**

- Habit profile printout (end-of-wing loose page).
- Achievement stamps (24 rubber-stamp glyphs).
- Editor UI (index-card panels, punch-card ribbon, snap grid).
- Controller-glyph overlay set (Xbox / PS / Switch / generic).

**Store / marketing 1.0:**

- Library hero (3840×1240).
- Library logo (transparent), library capsule, library icon.
- 4 language title lockups (EN, JP, KR, SC).
- Long-form gameplay trailer (~90 s).

**Localization asset kit:**

- Title lockup templates per language, all within the paper/ink family.
- Fallback CJK fonts vetted against the display + body stack.

**Alt palette packs (all human-referenced, all inside the substrate identity):**

- Field Ledger (baseline).
- Blueprint Cyanotype.
- Newsprint Red.
- Slate & Chalk.
- Colorblind Assist (protanopia + deuteranopia + tritanopia checked; rust replaced by high-value crosshatch).

**Explicit 1.0 non-additions:**

- No character customization (violates P4 — the game colors *itself*).
- No cosmetic microtransactions.
- No cross-promo skins from other Steam titles.
- No shaders that require SM 6.0 features; the game must run on integrated graphics.

---

## 10. Change log

- **v0.1** (this file) — initial MVP-locking draft. Palette locked. Rewrite VFX language locked. Placeholder textures shipped under [`game/echo_lattice/art/`](../../game/echo_lattice/art/).

---

## 11. Referenced files in this repo

- Palette source of truth: [`game/echo_lattice/art/palette/echo_lattice.palette.json`](../../game/echo_lattice/art/palette/echo_lattice.palette.json)
- Palette preview: [`game/echo_lattice/art/palette/palette_strip.png`](../../game/echo_lattice/art/palette/palette_strip.png)
- Placeholder generator (reproducible): [`game/echo_lattice/art/generate_placeholders.py`](../../game/echo_lattice/art/generate_placeholders.py)
- Tile placeholders: [`game/echo_lattice/art/tiles/`](../../game/echo_lattice/art/tiles/)
- Decal placeholders: [`game/echo_lattice/art/decals/`](../../game/echo_lattice/art/decals/)
- UI placeholders: [`game/echo_lattice/art/ui/`](../../game/echo_lattice/art/ui/)
- Keyart placeholder: [`game/echo_lattice/art/keyart/capsule_header_460x215_thumb.png`](../../game/echo_lattice/art/keyart/capsule_header_460x215_thumb.png)
