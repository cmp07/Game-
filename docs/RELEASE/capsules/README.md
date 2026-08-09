# Echo Lattice — Steam capsule finals (Field Ledger · G1)

**Product:** Echo Lattice (Game 1)  
**Look:** Field Ledger — paper bone / ink / rust ([`ART_DIRECTION_V3.md`](../../VISION/ART_DIRECTION_V3.md) materials + typography; palette from `echo_lattice.palette.json`). Not neon, not purple, not fantasy key art.  
**Status:** **G1 regenerated finals** — size-correct sRGB PNGs from the briefs below. No `PLACEHOLDER` stamp.  
**Generator:** [`../../../game/echo_lattice/tools/generate_steam_capsules.py`](../../../game/echo_lattice/tools/generate_steam_capsules.py)  
**Master package:** [`../STEAM_STORE_FINAL.md`](../STEAM_STORE_FINAL.md)

Palette lock (must match in-game ArtKit / `palette.json`):

| Token | Hex | Job |
|---|---|---|
| `paper_bone` | `#EFE6D2` | Substrate / background |
| `paper_deep` | `#D9CDB0` | Walked floor / folded faces |
| `ink_black` | `#141210` | Walls, wordmark |
| `ink_soft` | `#3A342C` | Grid / secondary line |
| `rust_fossil` | `#8B3A1F` | Habit fossil / accent underline |
| `rust_deep` | `#5E2412` | Old rust seams |
| `slate_teal` | `#2D4A55` | Tagline / secondary type |
| `chalk_white` | `#F5EFDD` | Habit trail / ghost |
| `copper_key` | `#B8763A` | Chest lantern |

**Type (V3 display stack):** IBM Plex Sans Condensed Bold / Medium (SIL OFL) under [`../../../game/echo_lattice/tools/fonts/`](../../../game/echo_lattice/tools/fonts/) — replaces the earlier Oswald lockup so capsules match art-bible / V3-T2.

**Materials (print-shop process):** fiber paper + faint 4 px ledger sub-grid, letterpress edge tremor on ink walls, circular rubber-stamp checkpoints, origami crease with contact shadow, Bayer-dithered copper lantern disk, rust veins from joins. No bloom / purple / emissive.

---

## Inventory (finals in this folder)

| File | Size (px) | Steam slot |
|---|---|---|
| [`header_460x215.png`](header_460x215.png) | 460×215 | Header capsule |
| [`main_616x353.png`](main_616x353.png) | 616×353 | Main capsule |
| [`small_231x87.png`](small_231x87.png) | 231×87 | Small capsule |
| [`vertical_374x448.png`](vertical_374x448.png) | 374×448 | Vertical / library capsule |
| [`library_hero_1920x620.png`](library_hero_1920x620.png) | 1920×620 | Library hero *(2× master optional later)* |
| [`library_logo_1280x720.png`](library_logo_1280x720.png) | 1280×720 | Library logo (transparent RGBA) |
| [`community_icon_184x184.png`](community_icon_184x184.png) | 184×184 | Community icon |
| [`page_background_1438x810.png`](page_background_1438x810.png) | 1438×810 | Store page background (optional) |

Regenerate:

```bash
python3 game/echo_lattice/tools/generate_steam_capsules.py
```

Older keyart thumb (historical):  
[`game/echo_lattice/art/keyart/capsule_header_460x215_thumb.png`](../../../game/echo_lattice/art/keyart/capsule_header_460x215_thumb.png)

---

## Briefs (what these finals encode)

### Header capsule — 460×215

**Title:** *Mid-step, the walls agreeing.*  
Surveyor mid-step in a right-angled ledger corridor. Behind them, three walls fold up from the floor in origami creases shaped like their footprints. Rust creeps along one wall. Wordmark `ECHO LATTICE` in IBM Plex Sans Condensed, ink on paper. Tagline small-caps teal: `IT LEARNED YOU`. Safe margin: keep wordmark clear at 50% scale.

### Main capsule — 616×353

Same key visual, low 3/4 angle. Chest lantern (copper dither disk). Chalk footprints receding; dashed chalk ghost of previous route. Checkpoint rubber stamp (`§ 04`) on the tile ahead. Wordmark lower-left; tagline under rust underline. No review scores, no “OUT NOW” banners.

### Small capsule — 231×87

Silhouette of surveyor stepping through a folded-paper doorway. Zero background detail. Title lockup on one line. Must read at search-list size.

### Vertical capsule — 374×448

Portrait crop of main motif: player stamp in upper third, rust wall bloom in lower third, chalk habit path connecting them like handwriting. Wordmark mid-height.

### Library hero — 1920×620 (prefer 3840×1240 master later)

Wide overhead of a wing as **pages in a bound ledger** (spine visible). Three chambers clean paper, three rust-colonized. Ghost path threads all six. No baked-in text — library logo overlays separately.

### Library logo — 1280×720 transparent

Wordmark + rust underline + `IT LEARNED YOU`. No busy background. Centered safe area.

### Community icon — 184×184

One rust tile infecting a monochrome grid. No wordmark. Must read at 32×32.

### Page background — 1438×810 (optional)

Full-bleed ledger grid at low contrast; spine suggestion; no player; no collapse. Atmosphere only.

---

## Acceptance

1. Would this frame look at home on a Vignelli transit poster?  
2. Can a stranger name the loop from the still (“maze rebuilds from my walk”)?  
3. No saturated purple / cyan / magenta, no bloom, no lens flare.  
4. Wordmark legible on small capsule.  
5. Delivery: sRGB PNG-24 (RGBA for logo), no embedded ICC drama.  
6. Exact Steam pixel sizes (IHDR) match the inventory table.  
7. No `PLACEHOLDER` stamp in any PNG.  
8. Typeface is IBM Plex Sans Condensed (not engine default / not Oswald).

---

## Related

- Art bible capsule section: [`../../ECHO_LATTICE/05_ART_BIBLE.md`](../../ECHO_LATTICE/05_ART_BIBLE.md) §7  
- Art direction V3 (materials + type): [`../../VISION/ART_DIRECTION_V3.md`](../../VISION/ART_DIRECTION_V3.md)  
- Screenshot slate + trailer: [`../STEAM_STORE_FINAL.md`](../STEAM_STORE_FINAL.md)  
- Platform asset reuse: [`../PLATFORMS.md`](../PLATFORMS.md)
