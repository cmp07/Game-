# Menu 10/10 — Title Shell Acceptance

**Status:** integration authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Branch:** `cursor/menu-10-of-10-afcb` → merge to `cursor/echo-lattice-rc1` (not `main`)  
**Reconciles:** `cursor/menu-seal-v2` · `cursor/menu-field-index-10` (intent) · #153 type · #154 no-HUD · #155 premium · #156 composition-art  
**Coordinates with:** [`MENU_TYPE_SYSTEM.md`](MENU_TYPE_SYSTEM.md) · [`ART_DIRECTION_V3.md`](ART_DIRECTION_V3.md) · [`UI_DIEGETIC_V3.md`](UI_DIEGETIC_V3.md) · [`QUALITY_BAR.md`](QUALITY_BAR.md)

---

## 0. Thesis

One composed Field Ledger folio. Brand + letterpress survey seal own the verso; a premium Field Index card owns the recto. Filled paper atmosphere. Zero chamber HUD. Craft density aimed at Witness / Obra Dinn / Gorogoa presentation discipline — still Field Ledger identity (paper, ink, rust, diegetic chrome).

**Rejected (3/10):** dashed circle seal · Field Index underline / ruled-fiber spam · sparse sketchy stock.

---

## 1. Composition (one viewport)

| Zone | Must |
|---|---|
| **Desk + open folio** | Full-bleed lightbox desk; verso \| spine \| recto fills the frame (no dead center void) |
| **Verso / brand** | Hero `ECHO LATTICE` (Bold condensed) + rust rule + tagline + one deck sentence |
| **Survey seal** | Rectangular letterpress plate with habit-maze mark (`menu-seal-v2`). **No dashed circle rings.** No “FIELD” watermark inside the plate |
| **Habit specimen** | Authored silhouette / chalk atmosphere under the brand — filled stock, not empty boxes |
| **Recto / Field Index** | One massy premium card (thickness, clip, binder holes, contact shadow) filling the right leaf |
| **Chamber HUD** | **Forbidden** — no BUFFER punch-card, Moves, Restart, Undo, or chamber foot chrome |

Brand test: remove the Field Index card — the verso still reads *Echo Lattice / Field Ledger*.

---

## 2. Type + selection (strict)

| Role | Face | Notes |
|---|---|---|
| Brand / Tagline | Display Bold | Brand owns the plane |
| Deck | Body serif | One supporting sentence |
| Actions | Display **Medium** | **Never mono** |
| Meta | Mono ≤ 13 px; else body | Quiet card header lines |
| Micro | Mono | Folio / seed / foot / seal caption |

**Selection grammar:** focused row = margin tick + text-width rust baseline only. Hover = slate baseline. Idle / disabled = **no rule**. No full-width underline spam. No cadmium on chrome.

---

## 3. Field Index premium card

- Shared geometry: `field_index_card_rect` / `field_index_content_rect` / `CardColumn` sync (Deck + 1080p + 1440).
- Stock: `ruled_stock: false` on the title card — dense 4 px fiber grids under actions are **reject** (reads as underline spam).
- Presence: thickness ≥ ~4.5, binder holes, clip, deep backer, quiet header band.
- Title on the plate uses display/tagline weight — not mono micro chrome competing with brand.
- Generous leading (`row_sep` / row heights from `LedgerChrome.title_type_scale`).

---

## 4. Craft density bar (comps as polish, not genre)

Pass if a still of the title shell feels closer to:

- **Witness** — quiet grammar, nothing ornamental without purpose  
- **Obra Dinn** — ledger / document certainty; type + plate as the interface  
- **Gorogoa** — composition *is* the object (open folio as one authored frame)

Fail if it reads as: spreadsheet UI, dashed preview widget, sparse Godot demo menu, or glow-on-void fantasy.

---

## 5. Acceptance checklist

- [x] No dashed / skipped-segment **circle** seal on title or boot
- [x] Seal is rectangular letterpress plate + habit-maze mark
- [x] Idle Field Index rows have **no** underlines; no dense ruled fiber under actions
- [x] Actions never use mono; meta mono only ≤ 13 px
- [x] Open folio fills 1920×1080; Field Index plate frames all actions (`verify_field_index_layout`)
- [x] Title stage mounts Menu only — abandon→title never leaves chamber HUD
- [x] Recaptured `docs/RELEASE/screenshots/02_brand_main_menu.png` @ 1920×1080
- [x] Cloud-safe gates: `test_menu_type_system` · `test_fonts_materials` · `test_title_menu_no_hud` · `test_field_ledger_juice`

---

## 6. Media

| Asset | Role |
|---|---|
| [`../RELEASE/screenshots/02_brand_main_menu.png`](../RELEASE/screenshots/02_brand_main_menu.png) | Partner brand slate |
| Trailer `06_title_cta/01_main_menu.png` | Keep in sync when composition moves |

Raw (after RC1 merge):  
`https://github.com/cmp07/Game-/raw/cursor/echo-lattice-rc1/docs/RELEASE/screenshots/02_brand_main_menu.png`
