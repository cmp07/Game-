# Menu 10/10 — Title Shell Acceptance (HARD RESET)

**Status:** integration authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Branch:** `cursor/menu-dense-craft` (on RC1 tip after #160 hard-reset) · not `main`  
**Supersedes soft passes after #158 / sparse #160 packing** — dense authored ledger page is the fail-CI bar.

---

## 0. Thesis

One composed Field Ledger folio. **ECHO LATTICE** owns the verso as the largest type; **one** mid-page habit specimen (small letterpress seal inset) sits tight under the blurb; a full-height Field Index owns the recto with a **compact** action block. Filled paper atmosphere (Obra Dinn / Gorogoa craft density — still ink/paper/rust Field Ledger). Zero chamber HUD. **No dashed concentric circle seal. No FIELD watermark. No duplicate Field Index / Wing labels.**

---

## 1. Hard composition @ 1920×1080 (fail CI if unmet)

| Zone | Must |
|---|---|
| **Brand column LEFT ~52%** | `ECHO LATTICE` ≥ **72px** Condensed Bold; tagline `IT LEARNED YOU` secondary rust; one Serif sentence; **one** habit specimen under blurb (gap ≤40px) with integrated letterpress seal |
| **Field Index RIGHT ~42%** | Sharp card, **all 8 actions** visible, Plex Condensed Medium actions, selection tick+baseline only; row pitch **~36–44px**; compact block in upper 2/3 (not stretched); card width **40–48%** |
| **Copy** | ONE `FIELD INDEX` title; ONE `FIELD LEDGER · WING I` micro header; meta = single quiet `date · EL-#####` line |
| **Empty region** | Measured empty (no ink/ui layout mass) **< 28%** of inner page — `test_menu_composition_density.py` |
| **Chamber HUD** | **Forbidden** |
| **Capture** | `02_brand_main_menu.png` MUST show BOTH brand and full Field Index in one frame |

Rejected forever: dashed circle seal · FIELD watermark · dual seal+maze with void band · duplicate Field Index/Wing labels · stretched sparse action leading · brand collapsed so tagline reads as hero · torn paper / black bar foot junk · Field Index off-screen.

---

## 2. Type + selection (strict)

| Role | Face | Notes |
|---|---|---|
| Brand | Display Bold Condensed ≥72 | Owns the plane — never secondary to tagline |
| Tagline | Display | Rust; ≤ ~30% of brand size |
| Deck | Body serif | One supporting sentence |
| Actions | Display **Medium** | **Never mono** |
| Meta / Micro | Mono ≤ 13 px | Quiet chrome only |

**Selection grammar:** focused row = margin tick + text-width rust baseline only.

---

## 3. Seal (eradicate circle paths)

- `ArtKit.draw_seal_stamp` draws a **rectangular letterpress plate** + habit-maze mark only.
- Ban: `TAU` ring segments, `inner_ring`, `ring_w`, caption `"FIELD"` / `"FIELD LEDGER"`.
- Caption (if any) sits **under** the plate — never a watermark inside the die.
- Applies to menu + boot + any ArtKit caller.

---

## 4. Acceptance checklist

- [ ] No dashed / skipped-segment **circle** seal on title or boot
- [ ] Seal is rectangular letterpress plate + habit-maze mark
- [ ] `ECHO LATTICE` is the largest type; tagline secondary rust
- [ ] Field Index ~40–48% width, full height, all actions visible
- [ ] Layout empty_frac < 0.28 (`composition_layout` + density test)
- [ ] No redundant Field Index / Wing labels (`test_menu_no_redundant_labels`)
- [ ] Sharp folio edges — no torn deckle / black bar foot junk
- [ ] Zero chamber HUD on title stage
- [ ] Recaptured `docs/RELEASE/screenshots/02_brand_main_menu.png` @ 1920×1080
- [ ] Gates: `test_menu_composition_density` · `test_menu_no_redundant_labels` · `test_menu_type_system` · `test_fonts_materials` · `test_title_menu_no_hud` · `test_field_ledger_juice`

---

## 5. Media

| Asset | Role |
|---|---|
| [`../RELEASE/screenshots/02_brand_main_menu.png`](../RELEASE/screenshots/02_brand_main_menu.png) | Partner brand slate |

Raw (after branch push):  
`https://github.com/cmp07/Game-/raw/cursor/echo-lattice-rc1/docs/RELEASE/screenshots/02_brand_main_menu.png`
