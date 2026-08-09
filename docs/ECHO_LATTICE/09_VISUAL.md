# Echo Lattice — 09 · Visual Craft (Weaver)

**Status:** craft authority (CLOUD ONLY) · **Branch:** `cursor/weaver-craft`  
**Product:** Echo Lattice · Field Ledger  
**Job:** Weave art bible + VISUAL v2 + Art Direction V3 into a **ship checklist** so every frame reads as ink on paper — never purple-void AI key art.  
**Does not replace:** [`05_ART_BIBLE.md`](05_ART_BIBLE.md) (pillars/palette) · [`14_VISUAL_V2.md`](14_VISUAL_V2.md) (what landed in code) · [`../VISION/ART_DIRECTION_V3.md`](../VISION/ART_DIRECTION_V3.md) (elevation plan)  
**Companions:** [`../VISION/PRODUCTION_CRAFT.md`](../VISION/PRODUCTION_CRAFT.md) · [`../VISION/QUALITY_BAR.md`](../VISION/QUALITY_BAR.md) · [`07_JUICE.md`](07_JUICE.md) · palette [`../../game/echo_lattice/art/palette/echo_lattice.palette.json`](../../game/echo_lattice/art/palette/echo_lattice.palette.json)

---

## 0. Thesis

Visual craft is how the player trusts authorship **before** they finish a chamber. Sound and progression deepen the habit fantasy; **pixels must already say** *surveyor's ledger, not mystical dungeon.*

**One-line brief:** _A brutalist subway map printed on warm paper that calcifies your footprints into rust — never glow on void._

**Weaver rule:** if visual, audio, and progression disagree about what the game is, **visual loses last** — the frame is the trailer. Fix the frame before adding systems.

---

## 1. Hard ban — purple-void AI look

Any of the following fails review. No exceptions for “placeholder,” “menu only,” or “just the trailer.”

| Banned | Why it fails Field Ledger |
|---|---|
| Near-black / void clear color (`#0c0c11`, pure `#000`, cosmic navy) | Kills paper substrate; reads as generic Godot / AI moodboard |
| Neon / cosmic purple, violet bloom, magenta cyber accents | Default AI fantasy palette; art bible ban list |
| Soft painterly haze, bloom halos, god-rays, volumetric fog | Emission / enchantment language — we fossilize, we do not radiate |
| Glassmorphism, frosted panels, multi-layer drop shadows | OS chrome, not a notebook |
| Floating HUD widgets with no paper substrate | Breaks object honesty (Art Direction V3 P6) |
| Glowing spawn pads, portal goals, rune circles | Wrong genre; cartographer honesty fails |
| Rainbow / holographic / vaporwave gradients | Slop cohesion destroyer |
| Default Inter/Roboto/Arial as brand display | Prototype typography signal |

**Acceptable substrate always:** `paper_bone` / `paper_deep` page on a slightly cooler lightbox margin. Ink is sepia (`ink_black`), habit is rust, info is slate teal.

**Brand test:** crop the nav. Mute audio. A stranger must still say “Echo Lattice / Field Ledger” — not “brown puzzle game on black.”

---

## 2. Authority stack (what wins)

```
05_ART_BIBLE          → pillars, palette tokens, ban list (law)
14_VISUAL_V2          → shipped Godot materials + slam staging (truth of code)
ART_DIRECTION_V3      → elevation past procedural boxes (ambition)
09_VISUAL (this doc)  → craft gates, frame audits, weaver sync with audio/progression
```

If JSON palette and this doc disagree on a hex, **palette JSON wins**. If intent disagrees, **art bible wins** and the JSON is a bug.

---

## 3. Craft pillars (ship language)

Carry Art Bible P1–P5 and Art Direction P6–P7. For craft reviews, score frames against these five gates:

| Gate | Pass | Fail |
|---|---|---|
| **G1 Legibility** | Mute clip: walls = footprints; goal/start/checkpoint readable in grayscale | Mood piece; cannot name the verb from the image |
| **G2 Ink on paper** | ≥60% paper family; margin visible; grain/grid subtle | Void backdrop, edge-bleed maze, pure white |
| **G3 Fossil not glow** | Rust matte; slam is origami; emissive = 0 | Bloom, neon seams, “energy” walls |
| **G4 One habit accent** | Rust only where the player earned it | Decorative rust everywhere / multi-hue accents |
| **G5 Cartographer honesty** | Every mark encodes seed, buffer, transform, or path | Ornaments with no job; stat-strip hero chrome |

---

## 4. Frame budgets (per viewport)

### 4.1 Ratio law (restated for QA)

| Family | Target share | Notes |
|---|---|---|
| Paper (`paper_bone` + `paper_deep`) | ~65% | Always show page margin |
| Ink (`ink_black` + `ink_soft`) | ~20% | Walls + type |
| Rust habit | 0% early → ≤15% late | Accretion is the dopamine; do not front-load |
| Slate teal | ~4% | Signage, stamps, info only |
| Cadmium warn | ≤1% | Telegraph heartbeat + slam margin only |

### 4.2 First viewport (shell)

Hero budget matches production craft / menu vision:

1. Brand (`ECHO LATTICE`) as dominant type  
2. One short verb line (`IT LEARNED YOU` or locked equivalent)  
3. One CTA column (underlined type, rust focus)  
4. One ambient teaching visual (seed + punch-card / chalk / film plate)  

**Not in first viewport:** stars, schedules, streak strips, promo chips, address blocks, multi-card dashboards.

### 4.3 In-chamber

Diegetic only: seed header, punch-card ribbon, ghost dash, checkpoint stamps. No floating glass meters. Lantern = single warm copper falloff — never a particle aura.

---

## 5. Signature moment — rewrite slam (visual half)

Aligned to `REWRITE_DURATION = 0.90s` in `chamber.gd` / VISUAL v2:

| Stage | t | Must show | Must not show |
|---|---|---|---|
| Heartbeat | 0.00–0.08 | One-frame `cadmium_warn` on **margin** | Full-screen flash, screen shake (default off) |
| Crease | 0.08–0.35 | Folding tile + diagonal ink, staggered | Glow warp, chromatic explosion |
| Lift | 0.35–0.55 | Cast shadow only (multiply, α ≤ 0.35) | Rim light, bloom lift |
| Slot | 0.55–0.70 | Fossil lands + 1 px overshoot | Portal swallow, particle fountain |
| Bleed | 0.70–0.90 | Rust from joins inward | Emissive veins |

**Weaver sync:** audio owns the same five stages ([`10_AUDIO.md`](10_AUDIO.md) §4). Visual never invents a sixth “magic” beat. Progression never tags the slam as loot/XP ([`11_PROGRESSION.md`](11_PROGRESSION.md) §2).

---

## 6. Materials checklist (RC1 → V3)

Status keys: `[x]` on-vision · `[~]` scaffold · `[ ]` missing / off-vision

| # | Check | Target |
|---|---|---|
| V1 | Clear color / page = paper family | No void flash on boot or scene change |
| V2 | Wall atlas uses joins (corner/T/cross), not stretched rect soup | Letterpress edge tremor ≤1 px |
| V3 | Fossil walls matte rust; seams `rust_deep` | Emissive = 0 |
| V4 | Ghost path = 1 px dashed chalk / slate | No particle trails |
| V5 | Checkpoint = rubber stamp (`slate_teal`), slight seed-locked rotation | Not a neon pad |
| V6 | Start / goal = copper dry-plate marks | Not glowing portals |
| V7 | Menu = index card on lightbox | No `PanelContainer` glass |
| V8 | Type stack: condensed grotesk + newsprint serif + mono | No ThemeDB-only brand |
| V9 | Transitions = paper turn / stamp | No fade-to-black as sole language |
| V10 | Demo / trailer frames pass ban list | Compliance: no purple-void in store art |

---

## 7. Motion craft (visual)

| Allowed | Forbidden |
|---|---|
| Paper turn, stamp-in, discrete numeral stamps | Fade-from-black, blur-in, tracking “cinematic” expands |
| Origami slam staging | Idle pulse / breathe on UI |
| Contact shadow under lifting paper | Multi-layer glam shadows |
| Reduce-motion → hard cut / shortened slam | Time-stretch that smears the phrase |

Ship **2–3 intentional motions** on shell surfaces (turn, stamp, underline settle). Do not add motion noise to prove “polish.”

---

## 8. Acceptance playtest (15 minutes, eyes only)

Mute speakers. Play Induction through Mirror Birth (or watch the screenshot tour).

1. **Cold boot** — first painted frame is paper, not grey/void.  
2. **Title** — brand dominates; remove labels mentally → still Echo Lattice.  
3. **Quiet Span** — diagram readable; chalk trail honest.  
4. **First rewrite** — origami + rust; zero bloom.  
5. **Pause / instruments** — paper objects, not glass.  
6. **Grayscale thought experiment** — player / wall / floor / fossil / goal still distinct.  
7. **Trailer crop** — any store frame would fail if purple or void appeared.

Fail any row → visual craft not done, regardless of chamber count.

---

## 9. Weaver links

| Layer | Doc | Contract with visual |
|---|---|---|
| Audio | [`10_AUDIO.md`](10_AUDIO.md) | Slam phrase stages lock-step; silence in Induction matches sparse paper |
| Progression | [`11_PROGRESSION.md`](11_PROGRESSION.md) | Stars/archetypes appear as ledger ink, never neon meters or battle-pass chrome |
| Shell | [`../VISION/PRODUCTION_CRAFT.md`](../VISION/PRODUCTION_CRAFT.md) | Boot / title / pause / credits obey same materials |
| Juice | [`07_JUICE.md`](07_JUICE.md) | Hitstop OK; default shake off; cadmium budget shared |

---

## 10. Non-goals

- New art styles, seasonal skins, or “premium dark mode.”  
- Genre mash visuals (horror blood, cyber grid, fantasy runes).  
- Replacing the playable slice’s palette tokens with a second system.  
- Implementation in this PR — **CLOUD ONLY**; code lands on art/UI branches against these gates.
