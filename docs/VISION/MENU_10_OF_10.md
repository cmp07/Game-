# Menu 10/10 — Title Shell Acceptance (LEFT PAGE FINAL)

**Status:** integration authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Branch:** `cursor/menu-left-page-final` → RC1 · not `main`  
**Supersedes** sparse #160 packing + hollow #161 specimen (layout claimed fill; pixels were cream).

---

## 0. Thesis

One composed Field Ledger folio. **ECHO LATTICE** owns the verso; **one** wide rectangular letterpress seal sits at the top of the specimen stack; a **dense** habit maze fills the remaining verso height. Field Index owns the recto with a compact action block. Zero chamber HUD. **No dashed concentric circle seal. No FIELD / SURVEY SEAL watermark. No hollow cream specimen frame.**

---

## 1. Hard composition @ 1920×1080 (fail CI if unmet)

| Zone | Must |
|---|---|
| **Micro header** | ONE quiet line: `FIELD LEDGER · WING I · seed` |
| **Brand column LEFT ~52%** | `ECHO LATTICE` ≥ **72px**; tagline `IT LEARNED YOU` rust; one Serif blurb |
| **Seal** | ONE wide rectangular letterpress plate at top of specimen (no circles, no caption watermark) |
| **Maze** | Habit specimen immediately under seal (gap ≤16px), fills to bottom margin — ink walls + rust accents |
| **Field Index RIGHT ~42%** | Sharp card, all actions, row pitch ~36–44px, compact upper 2/3; width 40–48% |
| **Empty region** | Page layout empty_frac < 28%; **LEFT tile empty mass < 22%**; maze-zone cream < 18% |
| **Chamber HUD** | **Forbidden** |
| **Capture** | `02_brand_main_menu.png` MUST show brand + dense left specimen + full Field Index |

Rejected forever: dashed circle seal · FIELD / SURVEY SEAL watermark · dual seal+maze with void band · hollow perimeter-only maze · stretched sparse action leading · brand collapsed so tagline reads as hero.

---

## 2. Diagnosis (#161 failure — why the left page looked empty)

1. **Specimen code existed** (`ArtKit.draw_habit_silhouette`) and `composition_layout` counted the silhouette **rect** as occupied ink.
2. **Draw was sparse:** soft caps (`cols≤36`, `rows≤28`) + perimeter/rib-only walls left the tall plate as a cream frame with a few ink lines — optically an empty bottom half.
3. **Seal was a tiny corner inset** on that hollow plate (read as a small die / “circle” at thumbnail scale), not a wide letterpress plate above a dense maze.
4. **Screenshot pipeline** (`capture_steam_store.sh` → `--screenshot menu`) captures the live menu after settle frames — it matched runtime; the bug was draw density, not a wrong scene / feature flag / pre-layout snap.
5. **Cloud captures without `git lfs pull`** render LFS font pointers as missing type (FreeType errors) — brand ink vanishes and the left leaf looks even emptier. Always `git lfs pull` before slate capture.

---

## 3. Seal (eradicate circle paths)

- `ArtKit.draw_seal_stamp` draws a **rectangular letterpress plate** + habit-maze mark only.
- Ban: `TAU` ring segments, `inner_ring`, `ring_w`, `draw_circle`, `draw_arc`, caption `"FIELD"` / `"FIELD LEDGER"` / SURVEY SEAL draw.
- Caption (if any) sits **under** the plate — never a watermark inside the die.
- Menu draws seal **above** the maze (`SEAL_PLATE_H` + `SEAL_MAZE_GAP≤16`), not as a third competing seal.

---

## 4. Acceptance checklist

- [x] No dashed / skipped-segment **circle** seal on title or boot
- [x] Seal is rectangular letterpress plate + habit-maze mark
- [x] Dense habit maze fills remaining verso (tile empty mass < 22% on LEFT)
- [x] `ECHO LATTICE` is the largest type; tagline secondary rust
- [x] Field Index ~40–48% width, full height, all actions visible
- [x] No redundant Field Index / Wing labels
- [x] Sharp folio edges — no torn deckle / black bar foot junk
- [x] Zero chamber HUD on title stage
- [x] Recaptured `docs/RELEASE/screenshots/02_brand_main_menu.png` @ 1920×1080
- [x] Gates: `test_menu_composition_density` · `test_menu_no_redundant_labels` · `test_menu_type_system` · `test_title_menu_no_hud` · `test_field_ledger_juice`

---

## 5. Media

| Asset | Role |
|---|---|
| [`../RELEASE/screenshots/02_brand_main_menu.png`](../RELEASE/screenshots/02_brand_main_menu.png) | Partner brand slate |

Raw (after branch push):  
`https://github.com/cmp07/Game-/raw/cursor/menu-left-page-final/docs/RELEASE/screenshots/02_brand_main_menu.png`
