# Menu Type System — Field Ledger Title Shell

**Status:** vision + wire authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Owns:** title-menu typography roles · tracking · line-height · 1080p scale · selection ink grammar  
**Coordinates with:** `cursor/menu-premium-v1` (composition / materials) · [`ART_DIRECTION_V3.md`](ART_DIRECTION_V3.md) §3 · [`UI_DIEGETIC_V3.md`](UI_DIEGETIC_V3.md) · [`PRODUCTION_CRAFT.md`](PRODUCTION_CRAFT.md)  
**Implementation:** `game/echo_lattice/scripts/ledger_type.gd` · consumers `ledger_chrome.gd` · `menu.gd`

---

## 0. Thesis

The title menu elevates **through type alone** when composition is already Field Ledger. Brand owns the left plane; the Field Index is an underlined-type ledger, not a widget panel. This doc locks the role ladder so premium-menu materials and type PRs merge without fighting sizes, faces, or selection chrome.

**Hard fences**

- Actions **never** use mono.
- Meta **may** use mono only at **≤ 13 px** (1080p). Above that, body serif.
- Selection = **margin tick + baseline rule**. No full-width underline under every idle row.
- Three faces max (display / body / mono). No fourth face. No tracking-expand cinema.
- Cadmium reserved for rewrite warn — never selection ink.

---

## 1. Roles

| Role | Face | 1080p size | Tracking¹ | Line-height | Where |
|---|---|---|---|---|---|
| **Brand** | Display (condensed grotesk) | **92** | −3.0 px (−~33/1000 em) | 1.00 | `ECHO LATTICE` lockup |
| **Tagline** | Display | **24** | +1.5 px (small-caps air) | 1.15 | `IT LEARNED YOU` under rust rule |
| **Deck** | Body (newsprint serif) | **17** | 0 | 1.35 | Brand blurb / one supporting sentence |
| **Action** | Display | **20** (primary **24**) | 0 | 1.20 | Field Index rows (Start / Continue / …) |
| **ActionDisabled** | Display | same as Action | 0 | 1.20 | Continue w/ no save; locked modes — ink α ≈ 0.32 |
| **Meta** | Mono **iff** size ≤ 13; else body | **13** | 0 | 1.25 | Card subtitle, stats strip, quiet ledger lines |
| **Micro** | Mono | **12** | +0.5 px | 1.20 | Folio mark, seed strip, card foot, seal caption |

¹ Tracking values are Godot `letter_spacing` / `FontVariation.spacing_glyph` pixels at the 1080p size. Scale tracking with the same factor as size (see §3).

### Face hard rules

| Role | Allowed faces | Forbidden |
|---|---|---|
| Brand / Tagline / Action / ActionDisabled | Display only | Mono, body |
| Deck | Body only | Mono, display |
| Meta | Mono ≤ 13 px; body if scaled above 13 | Display |
| Micro | Mono | Display as body copy |

---

## 2. 1080p reference table (published)

Reference viewport: **1920×1080**. Page height for scale math ≈ **1024** (after desk margin); role sizes below are the **published constants**, not derived mid-flight.

| Token | px @ 1080p | Role |
|---|---|---|
| `TYPE_BRAND` | 92 | Brand |
| `TYPE_TAGLINE` | 24 | Tagline |
| `TYPE_DECK` | 17 | Deck (blurb) |
| `TYPE_ACTION` | 20 | Action |
| `TYPE_ACTION_PRIMARY` | 24 | Action (Start New Survey) |
| `TYPE_ACTION_DISABLED` | 20 | ActionDisabled |
| `TYPE_META` | 13 | Meta |
| `TYPE_MICRO` | 12 | Micro (folio) |

Legacy aliases kept in `LedgerChrome` for merge safety: `TYPE_BLURB` → Deck, `TYPE_INDEX` → Action, `TYPE_INDEX_PRIMARY` → Action primary, `TYPE_FOLIO` / `TYPE_SEED` / `TYPE_CARD_HEADER` → Micro band (12–14).

---

## 3. Scale factors

`LedgerType.scale_factor(page_h)` maps page height → multiplier. Sizes round to int; tracking scales linearly; line-height ratios stay constant.

| Context | `page_h` | Factor | Notes |
|---|---|---|---|
| **Deck / short** | `< 700` | **0.62** | Steam Deck / editor short page — Field Index must stay plate-hug |
| **1080p published** | `700…1199` | **1.00** | Constants in §2 |
| **1440p+** | `≥ 1200` | **`clamp(page_h / 1080, 1.0, 1.15)`** | Soft lift only — brand must not swallow the page |

Compact absolute sizes (factor 0.62, matches current Deck path):

| Role | Compact px |
|---|---|
| Brand | 56 |
| Tagline | 18 |
| Deck | 14 |
| Action / ActionDisabled | 15 |
| Action primary | 17 |
| Meta | 11 |
| Micro | 10 |

Brand rule geometry scales with type: rule width 4 → 2.5; rule length 560 → 340 on compact.

---

## 4. Selection grammar (typography-adjacent ink)

Selection is **not** a StyleBox and **not** a full-row underline chorus.

| State | Ink | Geometry |
|---|---|---|
| **Focused** | `rust_fossil` | Margin **tick** (left of row, ~11 px out) + **baseline rule** under the label advance (text width + 8 px, capped ~220 px) |
| **Hover** (unfocused) | `slate_teal` | Baseline rule only — same text-width budget, no tick |
| **Idle** | — | **No rule.** Rows stay quiet type on paper |
| **Disabled** | — | No rule; type uses ActionDisabled α |

Draw-in: focus baseline eases in ≤ 80 ms (existing `FOCUS_UNDERLINE_SEC`). Tick fades after the rule passes ~55% length.

**Anti-patterns**

- Hairline under every idle index row (“underline spam”)
- Rules clamped to nearly full card width (reads as chrome bar)
- Filled pills, focus rings, cadmium ticks

---

## 5. Wire contract (`LedgerType`)

Autoload API (canonical):

| Method | Contract |
|---|---|
| `role_face(role) -> String` | `"display"` / `"body"` / `"mono"` per §1 |
| `role_size(role, page_h, primary=false) -> int` | Scaled px |
| `role_tracking(role, page_h) -> float` | Scaled glyph spacing px |
| `role_line_height(role) -> float` | Multiplier |
| `font_for_role(role, size_px) -> Font` | Face + meta mono gate (≤ 13) |
| `apply_role(control, role, page_h, primary=false)` | Font, size, letter_spacing when supported |
| `title_role_scale(page_h) -> Dictionary` | Published token map for menu draw / chrome |

`LedgerChrome.style_index_button` must call Action / ActionDisabled via `LedgerType` (display face).  
`LedgerChrome.style_ink_label` at meta sizes must honor the mono ≤ 13 gate.  
`LedgerChrome.draw_index_underlines` implements §4 only.

---

## 6. Merge notes (`menu-premium-v1`)

| Lane | Owns | Must not regress |
|---|---|---|
| **This PR / type system** | Roles, sizes, tracking, selection grammar | Action≠mono; idle rows unruled |
| **Premium menu** | Desk, blotter, seal, card materials, layout | Brand hero plane; Field Index plate geometry |

Merge order preference: type system → premium materials, or rebase premium onto type roles. Both land on `cursor/echo-lattice-rc1`.

---

## 7. Acceptance

1. Brand at 1080p is 92 px display; survives nav-removal brand test.  
2. Field Index actions are display face at 20/24 — grep-clean of mono on action styling.  
3. Meta at 13 uses mono; if a caller requests meta > 13, face falls back to body.  
4. Screenshot / draw pass: only focused (and hover) rows show baseline ink; idle list is clean type.  
5. Deck compact page_h < 700 uses factor 0.62 sizes without clipping the index plate.
