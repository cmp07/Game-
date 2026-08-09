# Menu 10/10 — Title Shell Acceptance (LEFT PAGE FINAL)

**Status:** integration authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Branch:** `cursor/menu-preview-fill` → RC1 · not `main`  
**Supersedes** #163 postage-stamp SubViewport inside a hollow film plate.

---

## 0. Thesis

One composed Field Ledger folio. **ECHO LATTICE** owns the verso; under the brand stack a **gameplay film plate** (live SubViewport walk+slam loop, or ogv/frame-strip fallback) is the left visual anchor. Field Index owns the recto with a compact action block. Zero chamber HUD. **No dashed concentric circle seal. No FIELD / SURVEY SEAL watermark. No hollow cream specimen frame. No competing giant static maze.**

---

## 1. Hard composition @ 1920×1080 (fail CI if unmet)

| Zone | Must |
|---|---|
| **Micro header** | ONE quiet line: `FIELD LEDGER · WING I · seed` |
| **Brand column LEFT ~52%** | `ECHO LATTICE` ≥ **72px**; tagline `IT LEARNED YOU` rust; one Serif blurb |
| **Film plate** | Diegetic media window under brand (~≥55% verso height) — paper surround, registration marks, thin rust rule |
| **Preview** | Silent scripted loop **fills the media well** (cover-scaled SubViewport / ogv / frames); media area ≥ **18%** of viewport; empty-inside-plate < **8%** |
| **Field Index RIGHT ~42%** | Sharp card, all actions, row pitch ~36–44px, compact upper 2/3; width 40–48% |
| **Empty region** | Page layout empty_frac < 28%; **LEFT tile empty mass < 22%** |
| **Seed / meta** | **ONE** verso seed line in the micro header — never a second seed strip under the film plate |
| **Chamber HUD** | **Forbidden** on title |
| **Capture** | `02_brand_main_menu.png` MUST show big looping play left + Field Index right; no twin seed bars |

Rejected forever: dashed circle seal · FIELD / SURVEY SEAL watermark · dual seal+maze with void band · hollow perimeter-only maze · stretched sparse action leading · brand collapsed so tagline reads as hero · YouTube player chrome on the verso.

---

## 2. Diagnosis (#163 hollow plate — layout anchors vs SubViewport size)

1. `composition_layout` / `_sync_preview_layout` correctly sized the film **plate Control** to the verso media well (~876×784).
2. `MenuGameplayPreview` set `PRESET_FULL_RECT` on itself, then menu wrote `position`/`size` — fragile against the well.
3. Live `SubViewport` stayed **board-native 768×448**. `SubViewportContainer.stretch = true` did **not** cover-fill the well; PNG island measured **765×447** stamped top-left → giant cream double-border plate.
4. `draw_ledger_film_plate(..., label: seed_strip)` reprinted the header seed under the well (twin seed bars).
5. Fix: top-left anchors + `sync_media_rect` → resize SubViewport to the well + **cover-scale** the chamber board; drop plate seed label.

---

## 3. Film plate + preview (eradicate circle / empty maze)

- `ArtKit.draw_ledger_film_plate` frames the media well (paper, rust rule, registration marks) — **no seed footer label**.
- Runtime: live SubViewport sized to the well, board cover-scaled (`sync_media_rect` / `_cover_scale_chamber`) → muted `.ogv` → PNG frame strip.
- Ban: postage-stamp SubViewport, cream hollow inside the plate, twin seed strips, `TAU` ring seals, chamber HUD, YouTube chrome.
- Preview must `MOUSE_FILTER_IGNORE` and pause when leaving the menu / opening overlays.

---

## 4. Acceptance checklist

- [x] No dashed / skipped-segment **circle** seal on title or boot
- [x] Gameplay film plate is the left visual anchor under the brand
- [x] Preview is silent / non-blocking; no chamber HUD on title
- [x] `ECHO LATTICE` is the largest type; tagline secondary rust
- [x] Field Index ~40–48% width, full height, all actions visible
- [x] No redundant Field Index / Wing labels
- [x] Sharp folio edges — no torn deckle / black bar foot junk
- [x] Recaptured `docs/RELEASE/screenshots/02_brand_main_menu.png` @ 1920×1080
- [x] Gates: `test_menu_composition_density` · `test_menu_no_redundant_labels` · `test_menu_type_system` · `test_title_menu_no_hud` · `test_field_ledger_juice`

---

## 5. Media

| Asset | Role |
|---|---|
| [`../RELEASE/screenshots/02_brand_main_menu.png`](../RELEASE/screenshots/02_brand_main_menu.png) | Partner brand slate |
| [`../../game/echo_lattice/media/menu_preview/`](../../game/echo_lattice/media/menu_preview/) | ogv / frame-strip fallback + loop gif |

Regenerate fallback loop: `python3 tools/release/build_menu_preview_loop.py`

Raw (after branch push):  
`https://github.com/cmp07/Game-/raw/cursor/menu-preview-fill/docs/RELEASE/screenshots/02_brand_main_menu.png`
