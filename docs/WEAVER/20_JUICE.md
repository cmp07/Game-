# The Weaver — 20 · Juice (feel)

**Doc:** `docs/WEAVER/20_JUICE.md`  
**Status:** Feel authority for W1 spike (CLOUD ONLY) · **Branch:** `cursor/weaver-juice`  
**Code:** `game/weaver/scripts/juice/weaver_juice.gd` · demo `game/weaver/scenes/demo_field.tscn`  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`09_VISUAL.md`](09_VISUAL.md) · [`10_AUDIO.md`](10_AUDIO.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`ROADMAP.md`](ROADMAP.md)

---

## 0. Thesis

Weaver juice is **workshop punctuation**, not combat spectacle. Three intentional motions sell Recover → Bind → Tension without purple glow spam.

**One-line brief:** _Chalk fiber suck, paper-press flash, copper weave pulse — diegetic or cut._

**Still test:** mute audio; crop HUD. A stranger must see *parts gather → seam press → cord load* — not loot beams or neon rings.

---

## 1. Hard ban

| Banned | Why |
|---|---|
| Cosmic purple / violet bloom / magenta cyber flash | Gameslop; fights fragment ban ([`03_FRAGMENTS.md`](03_FRAGMENTS.md)) |
| Full-screen energy wash on combine or seat | Document/textile game settles; physics games explode |
| Magnet / Pokémon catch beam on Recover | Fragments are craft atoms, not orbs |
| Idle UI breathe/pulse chrome | Motion budget is for verbs ([`09_VISUAL.md`](09_VISUAL.md) §6) |
| Confetti, portal swallow, rarity sparkle | Wrong shelf |

**Allowed accent:** kiln copper ≤10% of frame, riding **Thread body** during weave pulse — never a detached glow halo.

---

## 2. Three motions (ship these)

| # | API | Loop beat | Diegetic read | Timing |
|---|---|---|---|---|
| 1 | `fragment_suck(id, from, to, tint)` | Recover | Chalk/fiber wisps + plank silhouette ease-in to hand | ~320 ms (80 ms reduce-motion) |
| 2 | `combine_flash(at, radius, peak)` | Bind | Local chalk-bright paper press + crease cross at seam | ~140 ms |
| 3 | `weave_pulse(path, tension)` | Tension | Ink seam + kiln-copper crest along Thread polyline | ~480 ms · 2 cycles |

Aligned to MASTER motion budget: Fragment settle · Thread tension climb · Structure seat ([`MASTER_GDD.md`](MASTER_GDD.md)).

### 2.1 Fragment suck

- **Must:** fiber strand back to origin; ≤6 chalk wisps; silhouette shrinks into hand shelf.  
- **Must not:** homing beam, additive bloom, screen trauma.  
- **Signal:** `fragment_suck_finished(id)`.

### 2.2 Combine flash

- **Must:** local disc at bind point; peak uses `chalk_bright` (paper), ink crease cross.  
- **Must not:** full-viewport flash; cadmium spam; purple.  
- **Signal:** `combine_flash_finished`.

### 2.3 Weave pulse

- **Must:** pulse is **width/alpha on the Thread path** (cord load).  
- **Must not:** expanding neon ring, radial blur, chromatic aberration.  
- **Signal:** `weave_pulse_finished` → demo seats Structure (quiet timber/ink span).

---

## 3. Palette lock

Source: `game/weaver/content/palette.json` via `WeaverPalette`.

| Swatch | Juice job |
|---|---|
| `chalk_dust` | Suck wisps |
| `chalk_bright` | Combine flash peak |
| `kiln_copper` | Weave pulse crest |
| `ink_seat` / `timber` | Seated seam / Fragment body |
| `gap_void` | Frayed physical gap (torn cloth — not cosmos) |

Banlist colors in JSON are CI-enforced by `game/weaver/tests/test_weaver_juice.py`.

---

## 4. Reduce motion

When `WeaverJuice.reduce_motion = true`:

- Suck / flash / pulse durations collapse to hard cuts (≤100 ms).  
- Wisp spawn skipped.  
- Flash peak capped.  
- Outcome readability preserved (hand gains Fragment; seam presses; Thread seats).

---

## 5. Demo proof

`game/weaver/` Godot 4.3 project — **does not touch** `game/echo_lattice/`.

| Key | Verb |
|---|---|
| E / Space | Recover (fragment suck) |
| F | Bind (combine flash) |
| Q | Tension (weave pulse) |
| R | Reset field |

Headless: `godot --path game/weaver -- --selftest` (when editor available).  
CI without Godot: Python contracts in `game/weaver/tests/test_weaver_juice.py`.

---

## 6. Acceptance (~15 min eyes + CI)

1. Greyscale: suck / flash / pulse still distinguishable by shape, not hue alone.  
2. No purple hex in juice scripts or palette swatches.  
3. Combine flash never covers full viewport.  
4. Weave pulse is a property of the Thread polyline.  
5. Mute still of seated span across gap sells void-weave authorship.  
6. Echo Lattice tree untouched.

---

## 7. Non-goals

- Full Structure crease → lift → seat ceremony (follow-on; demo seats quietly after pulse).  
- Authored audio stems (wire to [`10_AUDIO.md`](10_AUDIO.md) seat phrase next).  
- Hub / Yard / gallery meta.  
- Sharing juice autoload with Echo Lattice.
