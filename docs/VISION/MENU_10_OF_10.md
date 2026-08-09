# Menu 10/10 — Title Shell Acceptance (LEFT PAGE FINAL)

**Status:** integration authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Branch:** `cursor/menu-gameplay-preview` → RC1 · not `main`  
**Supersedes** static seal+maze specimen (#161/#162) with a diegetic gameplay film plate.

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
| **Preview** | Silent scripted gameplay loop (or offline ogv/frames); no chamber HUD; does not block Field Index input |
| **Field Index RIGHT ~42%** | Sharp card, all actions, row pitch ~36–44px, compact upper 2/3; width 40–48% |
| **Empty region** | Page layout empty_frac < 28%; **LEFT tile empty mass < 22%** |
| **Chamber HUD** | **Forbidden** on title (tiny diegetic seed label on film plate OK) |
| **Capture** | `02_brand_main_menu.png` MUST show brand + gameplay film plate + full Field Index |

Rejected forever: dashed circle seal · FIELD / SURVEY SEAL watermark · dual seal+maze with void band · hollow perimeter-only maze · stretched sparse action leading · brand collapsed so tagline reads as hero · YouTube player chrome on the verso.

---

## 2. Diagnosis (#161 failure — why the left page looked empty)

1. **Specimen code existed** (`ArtKit.draw_habit_silhouette`) and `composition_layout` counted the silhouette **rect** as occupied ink.
2. **Draw was sparse:** soft caps (`cols≤36`, `rows≤28`) + perimeter/rib-only walls left the tall plate as a cream frame with a few ink lines — optically an empty bottom half.
3. **Seal was a tiny corner inset** on that hollow plate (read as a small die / “circle” at thumbnail scale), not a wide letterpress plate above a dense maze.
4. **Screenshot pipeline** (`capture_steam_store.sh` → `--screenshot menu`) captures the live menu after settle frames — it matched runtime; the bug was draw density, not a wrong scene / feature flag / pre-layout snap.
5. **Cloud captures without `git lfs pull`** render LFS font pointers as missing type (FreeType errors) — brand ink vanishes and the left leaf looks even emptier. Always `git lfs pull` before slate capture.

---

## 3. Film plate + preview (eradicate circle / empty maze)

- `ArtKit.draw_ledger_film_plate` frames the media well (paper, rust rule, registration marks).
- Runtime preference: live SubViewport (`menu_gameplay_preview.gd` + `Chamber.menu_preview_mode`) → muted `.ogv` → PNG frame strip.
- Ban: `TAU` ring seals, FIELD / SURVEY SEAL watermarks, chamber HUD overlays on the title preview, YouTube player chrome.
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
`https://github.com/cmp07/Game-/raw/cursor/menu-gameplay-preview/docs/RELEASE/screenshots/02_brand_main_menu.png`
