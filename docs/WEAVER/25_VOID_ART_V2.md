# The Weaver — 25 · Void Art V2

**Doc:** `docs/WEAVER/25_VOID_ART_V2.md`  
**Status:** Art elevation lock (CLOUD ONLY) · **Branch:** `cursor/weaver-void-art`  
**Product:** **The Weaver** (north star) — separate from frozen Echo Lattice  
**Job:** Kill the **circles-on-black** prototype look. Specify depth, materials, and lighting so the frayed-field void reads as a physical gap in a worked shed — never cosmic purple emptiness.  
**Extends (does not replace):** [`09_VISUAL.md`](09_VISUAL.md)  
**Peers:** [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`04_THREADS.md`](04_THREADS.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`06_WORLD.md`](06_WORLD.md) · [`10_AUDIO.md`](10_AUDIO.md) · [`MASTER_GDD.md`](MASTER_GDD.md) · [`PIVOT.md`](PIVOT.md)

**One-line brief:** _Stop drawing nodes in a black bag. Build a torn workshop page with timber grain, chalk slack, and a gap you could fall through._

---

## 0. Diagnosis — circles-on-black is not a look

Early void-weave sketches (and default “graph toy” prototypes) converge on the same dead end:

| Failure | Why it reads as slop |
|---|---|
| Flat discs / orbs as Fragments on `#000` or near-black | Node editor cosplay; no craft identity |
| Thin neon lines as Threads | RTS power-line / cyber circuit, not fiber |
| Empty chroma-void as the “gap” | Generative-fantasy key-art default |
| Uniform black clear color with no substrate | No page, no shed, no gravity |
| Soft purple bloom to “sell mystery” | Banned AI void — fights [`09_VISUAL.md`](09_VISUAL.md) §1 and MASTER hard bans |

[`09_VISUAL.md`](09_VISUAL.md) locked the **craft grammar** (fiber, chalk, timber, kiln copper). That was necessary. It is not sufficient for a playable still.

**V2 elevation:** every surface gets a **material story**, every gap gets **physical depth**, every Fragment gets a **workshop silhouette** — not a circle with a glow.

**Still test (stricter than 09):** mute audio, crop UI. A stranger must say *“someone stitched a plank across a torn shed floor”* — not *“graph nodes on black”* and not *“purple magic ruins.”*

---

## 1. What “void” means (locked)

| Allowed void | Forbidden void |
|---|---|
| Missing span / load path in a frayed field | Cosmic emptiness, nebula, starfield |
| Torn paper / cloth edge with fiber whiskers | Perfect geometric hole with rim-light |
| Open air over a drop (readable depth) | Infinite black bag with floating orbs |
| Dust fall, starved basin, missing planks | Portal iris, event-horizon disc |
| Shadow under a provisional Thread | Volumetric aether fog / god-rays |

The void is the **antagonist of scarcity** — a physical absence the player must bridge. It is never a mood plate.

---

## 2. Hard ban — AI purple void + circles-on-black

Carry every ban from [`09_VISUAL.md`](09_VISUAL.md) §1. V2 adds prototype-specific kills:

| Banned | Replacement |
|---|---|
| Circle / disc / orb as default Fragment mesh | Family silhouette (beam, peg, trough, spring, sieve, pendulum) |
| Black or near-black clear color as “space” | Warm bone paper / raw canvas substrate (`§4`) |
| Neon / cosmic purple, violet bloom, magenta cyber | Kiln rust / copper ≤10% of frame |
| Soft painterly haze, god-rays, volumetric fog | Single shed lamp / skylight; hard-ish falloff |
| Glow outlines, holographic rarity borders | Ink pressure, chalk dust, letterpress squash |
| Prefab hard-light bridges / sci-fi ghost builds | Provisional chalk / slack fiber |
| Echo Lattice maze chrome / film plates | Shed Yard loom ambient only |
| Multi-layer drop shadows + bloom stack | One contact shadow under lifted cloth/timber |

**Anti-slop hex ban (non-exhaustive):** `#7F00FF`, `#B026FF`, `#8A2BE2`, neon cyan, hot magenta, vaporwave gradients, lava-on-black, pure `#000000` clear.

---

## 3. Depth model — three planes, one composition

Depth is **authored layers**, not camera fog.

### 3.1 Plane stack (far → near)

| Plane | Content | Depth tells |
|---|---|---|
| **0 · Shed air / drop** | The physical void | Cooler value than page by ~8–12%; dust motes optional ≤2%; **no** stars |
| **1 · Substrate** | Page / cloth field surface | Warm bone or canvas grain; torn margin into plane 0 |
| **2 · Craft** | Fragments, Threads, Structures | Cast contact shadows onto plane 1; thickness reads capacity |
| **3 · Apparatus / shell** | Yard lamp, stamps, HUD-as-object | Material tags / underlines — never glass HUD |

### 3.2 Gap anatomy (how the void reads)

A frayed gap must show **at least three** of these tells in every trailer still:

1. **Torn edge** — fiber whiskers / deckled paper / splintered plank ends  
2. **Value step** — substrate → cooler drop (not pure black)  
3. **Occlusion** — Thread or Span casts a thin contact shadow across the tear  
4. **Scale cue** — dust, stitch length, or plank thickness that sells distance  
5. **Load path scar** — chalk survey marks or nail holes where a prior span failed  

If the gap is only a darker rectangle, V2 has not landed.

### 3.3 Parallax budget

| Motion | Allowed | Forbidden |
|---|---|---|
| Camera / page settle | ≤2% substrate drift; dust settle | Idle breathe, tracking cinematic orbit |
| Tension seat | Crease → lift → seat ([`09_VISUAL.md`](09_VISUAL.md) §5) | Screen warp bloom, portal swallow |
| Reduce-motion | Hard seat / cut | Ugly time-stretch of depth |

Ship **2–3 intentional motions** on shell + Tension. Physics readability > particle noise.

---

## 4. Material language V2 (workshop, not PBR fantasy)

Borrow craft warmth from Field Ledger lessons; **do not** inherit maze chrome or cream-purple AI defaults.

### 4.1 Substrate stack

| Layer | Material | Look | Notes |
|---|---|---|---|
| **Desk / shed under** | Cool-neutral air through drop | Slightly cooler than bone; never cyan neon | Clear behind torn margin only |
| **Page / cloth** | Warm printer stock or raw canvas | Visible fiber grain; faint weave | ~60% of frame |
| **Dust / chalk** | Provisional marks | Dashed slack fiber; survey ticks | Threads before Tension |
| **Ink / seated seam** | Ruling pen / waxed thread | Taut; matte | Passed Tension |
| **Timber / wire** | Span / Anchor bodies | Greyscale-readable silhouettes | Craft objects ~25% |
| **Kiln rust / copper** | Heat, Charge, stress creep | Matte oxide; **emissive = 0** | ≤10% of frame |
| **Shed light** | Single practical lamp / skylight | Hard-ish falloff; dithered edge | No bloom stack |

**Ratio intuition (per field frame):** ~60% substrate · ~25% craft objects · ~10% Threads · ≤5% kiln accent · ≤1% warn flash on illegal snap.

### 4.2 Material cards (spec for artists / tech art)

**Field page (healthy)** — warm bone or canvas; micro fiber noise; no bevel; no AO puddle under the player avatar.

**Frayed margin** — irregular tear into drop plane; fiber whiskers in ink-soft; occasional chalk tick from survey.

**Void drop** — value −8…−12% from substrate toward cool shed air; optional sparse dust; **never** starfield or purple nebula.

**Provisional Thread** — dashed chalk / slack fiber; slight sag; contact shadow only where it crosses the tear.

**Seated Thread** — taut ink or waxed seam; thickness encodes load; rust creep along the fiber when near overload.

**Span Fragment** — plank / cloth strip silhouette; end grain or weave visible; ports as stamped glyphs on the body — **not** glowing sockets.

**Anchor Fragment** — peg / stake / weight; grounded mass; short cast shadow on page.

**Channel / Charge / Filter / Pulse** — trough, spring/bladder/kiln-heart, sieve/flap, pendulum/bellows — one silhouette family each ([`03_FRAGMENTS.md`](03_FRAGMENTS.md) §3). **No discs.**

**Structure seat** — crease in cloth/page → brief lift with contact shadow → seat with quiet weight. Walkable/usable law; no confetti.

### 4.3 Process visible (anti-slop moat)

Every material should look like a **process** left a mark: chalk scuff, ink pressure, timber saw-cut, kiln oxide, fiber twist, stamp residue. AI moodboards emit glow; workshops leave residue.

---

## 5. Palette tokens (Weaver void — draft)

Machine palette may land later under `game/weaver/art/palette/`. Until then, these names are the authority for stills and spikes.

| Token | Hex (draft) | Role |
|---|---|---|
| `page_bone` | `#E8DFC8` | Field substrate |
| `page_deep` | `#D2C4A4` | Worn cloth / walked page |
| `canvas_raw` | `#CDBF9E` | Alternate substrate (Yard) |
| `ink_seat` | `#1C1814` | Seated seams, glyphs — never pure black |
| `ink_soft` | `#3E362C` | Edge tremor, print grain |
| `chalk_mark` | `#F3ECDA` | Provisional Threads, survey ticks |
| `timber_oak` | `#6B5340` | Span / Anchor body |
| `wire_cold` | `#4A5348` | Wire / brace secondary |
| `kiln_rust` | `#8B3A1F` | Stress creep, Charge heat |
| `kiln_copper` | `#B8763A` | Interactive apparatus ≤10% |
| `shed_air` | `#2A2E2C` | Void drop — cool neutral, **not** `#000` |
| `lamp_warm` | `#C4A46A` | Single practical light tint |
| `snap_warn` | `#D6432B` | Illegal snap flash only (≤1%) |

**Ratio law** matches §4.1. Wing/field tints (if any) shift `page_bone` / `page_deep` only — never invent purple or neon.

---

## 6. Object grammar elevation (beyond circles)

### 6.1 Fragments — silhouette first

| Family | V1 trap | V2 tell |
|---|---|---|
| **Span** | Horizontal capsule / bar circle ends | Beam / plank / cloth strip; length = capacity |
| **Anchor** | Dot / filled circle | Peg, stake, weight; grounded mass |
| **Channel** | Pipe drawn as two circles | Culvert / trough / duct; open section reads |
| **Charge** | Glowing orb | Spring, bladder, kiln-heart; stored push as compression |
| **Filter** | Ring / donut | Sieve, baffle, one-way flap |
| **Pulse** | Pulsing disc | Pendulum, bellows, knocker — beat tool, never rewind |

Ports = **glyphs stamped on the body**. Capacity = thickness / stitch density — not DPS numbers. Seat = press into cloth/page — never catch-beam VFX.

### 6.2 Threads — fiber, not neon

| State | Look |
|---|---|
| Provisional | Dashed chalk / slack fiber across the gap; sag readable |
| Healthy seated | Taut ink / waxed seam |
| Approaching overload | Rust creep along the Thread |
| Illegal snap | White/`snap_warn` flash → settle; name port conflict in one glyph |
| Tear | Gap at culprit — collapse comedy in one glance |

Drawing feels like **pulling fiber across a page**, not laying RTS power lines.

### 6.3 Structures — crease → lift → seat

Stood graphs only ([`05_STRUCTURES.md`](05_STRUCTURES.md)). Archetypes (Span, Culvert, Kiln, Gate, Scaffold, Loom-mark) remix families — no prefab house menu art, no hard-light ghosts.

---

## 7. Lighting — one lamp, paper thickness

Lighting sells **substrate thickness** and **one practical tool**. It must never sell magic.

| Source | Shape | Rules |
|---|---|---|
| **Page / shed ambient** | Nearly flat | ±4% value drift; no vignette crush to black |
| **Yard lamp / skylight** | Hard-ish disk or soft rectangle | **Only** persistent diegetic light; dithered falloff; no Gaussian bloom |
| **Snap warn** | Margin / culprit flash | ≤1 frame equivalent; nowhere else |
| **UI** | Unlit | Stamped tags on cardstock; no dynamic lights on menus |

**Falloff law:** stepped or ordered-dither into page; outside the lamp disk the page stays readable — accent, not horror flashlight.

**Explicit bans:** bloom stacks, rim-light magic, emissive Fragments, god-rays, purple fill light.

---

## 8. Shell craft (first viewport)

| Rule | Spec |
|---|---|
| Brand | **THE WEAVER** (or locked name from [`19_NAMES.md`](19_NAMES.md)) dominates |
| Composition | Brand · one craft line · one CTA · one ambient Yard/loom visual |
| Hero visual | Full-bleed shed / loom / torn-field atmosphere — not inset cards, not node-graph still |
| Not in hero | Job lists, streak strips, rarity showcases, EL maze film plates, stat strips |
| Type | Expressive workshop faces — not Inter/Roboto/Arial; three faces max |
| Buttons | Material objects (stamped tags, underlines) — not neon pills |

**Brand test:** remove nav labels → still obviously Weaver, not Echo Lattice, not generic puzzle UI, not circles-on-black.

---

## 9. Signature stills (trailer / acceptance frames)

Produce (or specify) these mute stills before art ramp:

| # | Frame | Must read |
|---|---|---|
| S1 | Frayed field before bind | Torn margin + drop; chalk survey ticks; **no** circles |
| S2 | Provisional Thread across void | Slack fiber + contact shadow over tear |
| S3 | Tension seat mid-lift | Cloth crease + cast shadow; Structure not yet law |
| S4 | Seated Span inhabited | Walkable plank/bridge; kiln accent ≤10% |
| S5 | Illegal snap settle | Culprit seam named; no full-screen glitch |
| S6 | Title / Yard | Brand-first; shed loom ambient; brand test pass |

---

## 10. Relationship to Echo Lattice & 09_VISUAL

| Source | Role |
|---|---|
| [`09_VISUAL.md`](09_VISUAL.md) | Craft grammar authority — V2 elevates execution depth |
| Echo Lattice Art Bible / VISUAL v2 / ART_DIRECTION_V3 | Borrow **process-visible** lessons (ink on paper, ban glow); **do not** mash maze UI or store plates |
| `game/echo_lattice/` | Frozen — **keep**; do not recolor into Weaver |

| Echo Lattice (frozen) | The Weaver (V2) |
|---|---|
| Habit path → fossil walls on Field Ledger | Fragment → Thread → Structure on shed/textile page |
| Purple boxes → paper elevation (done for EL) | Circles-on-black → workshop depth (this doc) |

---

## 11. Acceptance (eyes only, ~20 min)

1. Greyscale: six Fragment families distinguishable — **zero default circles**.  
2. Provisional vs seated Thread readable without color alone.  
3. Void gap shows torn edge + value step + occlusion (≤ misses one).  
4. No purple, no rarity rainbow, no chronoshard icons, no starfield.  
5. Clear color is never pure black; drop uses `shed_air` family.  
6. Mute still of seated Span across a gap sells void-weave authorship.  
7. Title composition passes brand test; no EL maze chrome; no node-editor plate.  
8. Emissive count on playfield materials = **0**.

---

## 12. Non-goals

- Full material bible atlas / every Structure recipe painted.  
- Dual 2D+3D art tracks before sim fence ([`ROADMAP.md`](ROADMAP.md) G1).  
- Code, shaders, or PNGs in this PR — **CLOUD ONLY**.  
- Recoloring or deleting `game/echo_lattice/`.  
- Store capsules / Partner paste (blocked until vertical slice).

---

## 13. Lock line

The Weaver’s void is a **torn shed gap** with fiber, timber, and chalk — depth from materials and occlusion, never from circles floating in a purple-black bag.
