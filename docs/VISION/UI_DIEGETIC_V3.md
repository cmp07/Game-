# Echo Lattice — UI Diegetic v3 · Field Ledger

**Status:** vision lock (implementation brief) · **Branch:** `cursor/vision-ui-v3` · **Scope:** CLOUD ONLY (docs)  
**Authority chain:** [`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) §6 → this doc → scene/theme implementation  
**Supersedes for shell UX:** ad-hoc Godot `PanelContainer` / `OptionButton` / `CheckButton` chrome in RC1 overlays  
**Does not supersede:** palette tokens, rewrite slam, fossilization verb, accessibility *behavior* contracts

**One-line brief:** Every interactive surface is a page, card, stamp, or punch-card in the surveyor’s Field Ledger — never a translucent Godot menu.

---

## 0. Why v3 exists

RC1 already sells the Field Ledger on the **title card** and **chamber margins**. Secondary shells still read as engine UI:

| Surface today | Drift |
|---|---|
| Settings (`settings_menu.tscn`) | Dim overlay + `PanelContainer` + stock sliders / option buttons |
| Subtitles | `PanelContainer` caption bar |
| Chamber won / end / museum | Functional labels + flat buttons; less “loose ledger page” than title |
| Pause (Esc / Start / B) | Returns to menu — no in-run Field Index leaf |

v3 redesigns **all** UI into one diegetic system so a screenshot of any shell still passes the art-bible brand test: remove chrome chrome-labels and the frame still says *Echo Lattice / Field Ledger*.

---

## 1. Hard rules (non-negotiable)

### 1.1 Diegesis

1. **No glass.** No translucent panels, blur, drop shadows, or frosted overlays.
2. **No Godot chrome.** Default `Button` fills, `OptionButton` popups, `CheckButton` toggles, `HSlider` grooves, `PopupMenu`, `AcceptDialog`, and `TabContainer` skins are **forbidden in the final look**. Nodes may remain under the hood; they must be fully restyled or replaced by ledger components (§5).
3. **Paper substrate always visible.** Lightbox / ledger grid / grain behind every shell. Edge-to-edge paper plane — not an inset modal floating on void.
4. **One card per job.** One index card (or one bound page) owns the interaction. Split to a new page-turn rather than stacking panels.
5. **Type is the control.** Primary actions are underlined type (focus = rust rule, hover = slate rule). Never a filled rectangle CTA.
6. **Numbers stamp.** Discrete ink stamps, not rolling odometers. No breathing/`sin` pulses on chrome (ambient chalk path on title may move; UI chrome stays still).
7. **Transitions are paper turns.** Card-to-card = page flip or slide on the lightbox. No cross-fade through black. No 1-frame black-on-black.
8. **Cadmium ≤1%.** Reserved for rewrite-imminent warn + slam margin heartbeat. UI never uses cadmium fills.
9. **Icons are etched glyphs.** Single-weight, single-color (`ink_black` / `slate_teal`). No emoji, no multi-color icons, no neon.

### 1.2 Brand / composition (shells)

- Brand-first on title; secondary shells carry a small **FIELD LEDGER** folio mark (mono, top margin) so they remain on-world documents.
- First viewport of title: brand, one tagline, one CTA group, one dominant paper plane (ambient chalk path). No stat strips.
- Cards: only as the interaction container (index card). Removing border/shadow/radius must not break understanding — prefer hairline ink rule + slight paper lift (`paper_deep` backer), corner radius ≤ 2 px.

### 1.3 Ban list (UI-specific)

- Hex HUD frames, sci-fi brackets, progress rings, “XP bars”
- Modal dim that reads as game-pause blur (use **paper wash** / page underneath instead)
- Purple / neon / glow / bloom on any control
- Rounded-full pills, multi-layer shadows, glassmorphism
- Engine default Inter-as-identity (ship condensed grotesk + newsprint serif + mono per art bible)

---

## 2. Information architecture

```
Field Ledger (shell root — lightbox paper)
├── Title Card …………………… Field Index (main menu)
│   ├── Continue / Open new survey / Daily / Endless / Hard
│   ├── Museum of Selves
│   ├── Instruments (settings) ──→ Instrument Folio (multi-leaf)
│   ├── Credits Colophon ────────→ Colophon page
│   └── Close ledger (quit)
├── Chamber Page ……………… in-run diegetic margins (not a menu)
│   ├── Esc / Start / B ─────────→ Pause Index Card (over chamber page)
│   └── Instruments leaf (from pause) → same folio as title
├── Clear Stamp ………………… chamber-won ledger leaf
├── Wing Colophon …………… end / demo-complete leaf
└── Museum Drawer …………… archive browser (bound samples)
```

**Pause** is a first-class leaf in v3 (missing as styled UI today): resume, restart chamber, instruments, abandon to Field Index.

---

## 3. Shared layout grammar

All shells share this page anatomy (1080p reference; scale with `ui_scale`):

```
┌──────────────────────────────────────────────────────────────────┐
│  FIELD LEDGER · WING I                              seed ####-…  │  ← 24px mono header band
│  ──────────────────────────────────────────────────────────────  │  ← 1px ink_soft rule
│                                                                  │
│                     ┌────────────────────────┐                   │
│                     │   INDEX CARD / PAGE    │                   │
│                     │   (interaction body)   │                   │
│                     └────────────────────────┘                   │
│                                                                  │
│  [glyph footer: Confirm · Back · …]          buffer ▓▓▓░░░░░░░   │  ← punch-card or glyphs
└──────────────────────────────────────────────────────────────────┘
     paper_bone lightbox + 4px ledger grid + ≤8% print grain
```

**Grid:** 4 px baseline. Card content inset ≥ 24 px. Chamber world keeps ≥ 2-tile paper margin (art bible); shell cards sit inside a generous lightbox margin (≥ 10% viewport).

**Type roles**

| Role | Face | Use |
|---|---|---|
| Display | Condensed grotesk, small caps OK | Brand, leaf titles |
| Body | Newsprint serif | Blurbs, credits, museum detail |
| Mono | Grotesk mono | Seeds, buffer, build id, bindings |
| Action | Display or body + **underline** | All primary/secondary actions |

---

## 4. Wireframes (markdown)

Legend: `══` rust focus underline · `──` slate hover · `··` idle ink · `▓` punch filled · `░` punch empty · `§` stamp.

### 4.1 Title Card — Field Index

**Job:** Enter a run. Teach seed + buffer diegetically.  
**Scene today:** `scenes/menu.tscn` + `menu.gd` (keep structure; harden grammar).

```
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│                         E C H O   L A T T I C E                          │
│                         ──────────────────────                           │  rust_fossil rule
│                           IT LEARNED YOU                                 │  slate_teal small caps
│                                                                          │
│                    ┌────────────────────────────────┐                    │
│                    │  FIELD INDEX                   │                    │
│                    │                                │                    │
│                    │  Open new survey ════════════  │  ← focus           │
│                    │  Continue  ··················  │                    │
│                    │  Daily sheet  ···············  │                    │
│                    │  Endless corridor  ··········  │                    │
│                    │  Hard binding  ···············  │                    │
│                    │  Museum of Selves  ··········  │                    │
│                    │  Instruments  ···············  │                    │
│                    │  Colophon  ··················  │  ← NEW credits     │
│                    │  Close ledger  ··············  │                    │
│                    │                                │                    │
│                    │  progress: Wing I · § 03       │  mono/meta         │
│                    └────────────────────────────────┘                    │
│                                                                          │
│  seed  A1B2-C3D4-E5F6-7890          buffer  ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░  │
│  A Confirm   B Back   Y Restart(n/a)              wishlist ····· (demo)  │
│                                                                          │
│  ····· ambient chalk ghost path on lightbox (teaching, not chrome) ····· │
└──────────────────────────────────────────────────────────────────────────┘
```

**Motion:** card settles with a single paper-slot (≤180 ms). Ambient path advances in discrete chalk stamps. No fold-tease breathe.

### 4.2 Instruments Folio — Settings (replaces Godot settings panel)

**Job:** Language, buses, a11y, remap, support — as survey instruments on indexed leaves.  
**Scene today:** `scenes/ui/settings_menu.tscn` — **full visual replace**.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FIELD LEDGER · INSTRUMENTS                              build 0.x.y-rc  │
│  ──────────────────────────────────────────────────────────────────────  │
│                                                                          │
│   leaves:  [ Language ]  [ Sound ]  [ Sight ]  [ Hands ]  [ Support ]    │  ← etched tabs = ink stamps
│            ═══════                                                       │    (not TabContainer skin)
│                                                                          │
│            ┌──────────────────────────────────────────────────┐          │
│            │  SIGHT                                           │          │
│            │                                                  │          │
│            │  Color reading ……… Field Ledger ▸ / Protan …     │  ← FolioSelect (not OptionButton)
│            │  Fossil patterns …… [■] stamped  / [ ] blank     │  ← FolioToggle
│            │  Reduce flash ……… [■]                            │
│            │  Reduce motion …… [ ]                            │
│            │  Screen shake ……… [ ]   intensity  ┄●──────      │  ← FolioSlider = ink rule + stamp knob
│            │  Subtitles ……… [■]  size Medium ▸                │
│            │  Subtitle plate …… [■]                           │
│            │  Type scale ……… ┄────●──  1.25×                  │
│            │  Ghost assist …… [ ]                             │
│            │  Hold to walk …… [ ]                             │
│            └──────────────────────────────────────────────────┘          │
│                                                                          │
│  Reset sight ·····   Reset hands ·····              File away ════════   │
│  A Confirm   B File away                                                 │
└──────────────────────────────────────────────────────────────────────────┘
```

**Leaf map**

| Leaf | Contents |
|---|---|
| Language | System / EN / 简体 — FolioSelect |
| Sound | Master / SFX / Music / PA — FolioSliders (bus labels as serif) |
| Sight | Colorblind, patterns, flash, motion, shake, subtitles, UI scale, ghost, hold-walk |
| Hands | Binding rows: action name (serif) · current glyph (mono) · **Rebind** underline |
| Support | Build id, Export crash pack, links copy |

**Behavior preserved:** all `AccessibilityService` / `ActionRemap` / `SettingsStore` contracts in [`ACCESSIBILITY.md`](../RELEASE/ACCESSIBILITY.md). Vision changes skin + IA only.

### 4.3 Pause Index Card (new leaf)

**Job:** Interrupt a chamber without dumping to title. Sits **on** the chamber page (paper still visible around card).

```
┌──────────────────────────────────────────────────────────────────────────┐
│  (chamber page desaturated 1 step → paper_deep; world still legible)     │
│                                                                          │
│                 ┌────────────────────────────────┐                       │
│                 │  PAUSE · FIELD INDEX           │                       │
│                 │  chamber  Quiet Span           │                       │
│                 │  seed  A1B2-…                  │                       │
│                 │                                │                       │
│                 │  Resume survey ════════════    │                       │
│                 │  Restart chamber ··········    │                       │
│                 │  Instruments ··············    │                       │
│                 │  Abandon to Field Index ···    │                       │
│                 └────────────────────────────────┘                       │
│                                                                          │
│  buffer (live)  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░                             │
└──────────────────────────────────────────────────────────────────────────┘
```

### 4.4 Chamber Page — diegetic HUD (in-run)

**Job:** Cartographer honesty. No overlay widgets.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  seed  A1B2-C3D4-E5F6-7890          Quiet Span · § 02     habit MIR ▸…   │  top margin print
│  ························· paper margin ································ │
│  ·                                                                      ·│
│  ·              ┌─────────────────────────────┐                         ·│
│  ·              │  maze tiles (diagram)       │                         ·│
│  ·              │  ghost chalk path           │                         ·│
│  ·              │  telegraph ticks (slate /   │                         ·│
│  ·              │   cadmium only at warn)     │                         ·│
│  ·              └─────────────────────────────┘                         ·│
│  ·                                                                      ·│
│  ························· paper margin ································ │
│  buffer ▓▓▓▓▓▓▓▓░░░░… (30)     X Undo  Y Restart  LB Ghost  Start Pause │  bottom margin
└──────────────────────────────────────────────────────────────────────────┘
```

Caption / habit identity: printed in the **top margin** as small serif/mono — never a floating toast panel. Subtitles (§4.8) replace the only non-margin text band when enabled.

### 4.5 Clear Stamp — chamber won

**Job:** Stars + habit beat + museum archive note as a stamped leaf.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FIELD LEDGER · CLEAR STAMP                                              │
│  ──────────────────────────────────────────────────────────────────────  │
│                                                                          │
│         ┌──────── paper plate vignette (chalk replay) ────────┐          │
│         │         ·  ·   dashed habit path   ·                │          │
│         └─────────────────────────────────────────────────────┘          │
│                                                                          │
│              CHAMBER CLEARED                                             │
│              Quiet Span                                                  │
│              ★★★  moves 42  best 38                                      │  stamp numerals
│                                                                          │
│              ┌─ identity stamp card ─┐                                   │
│              │  § MIRROR BIRTH       │                                   │
│              │  archetype: Folder    │                                   │
│              └───────────────────────┘                                   │
│                                                                          │
│              archived to Museum ·····                                    │
│                                                                          │
│              Next chamber ════════════                                   │
│              Replay ················                                     │
│              Field Index ···········                                     │
└──────────────────────────────────────────────────────────────────────────┘
```

### 4.6 Wing Colophon — end / demo complete

**Job:** Close the wing; demo wishlist without late-act spoilers.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FIELD LEDGER · COLOPHON                                                 │
│                                                                          │
│              WING I  ·  FILED                                            │
│              IT LEARNED YOU                                              │
│                                                                          │
│              surveys filed …… 12                                         │
│              rewrites ……… 47                                            │
│              dominant habit … Folder                                     │
│                                                                          │
│              Wishlist on Steam ════════   (demo, gated)                  │
│              New survey ··············                                   │
│              Field Index ·············                                   │
│                                                                          │
│              printed for the Next Fest shelf ·····                       │
└──────────────────────────────────────────────────────────────────────────┘
```

### 4.7 Museum Drawer — Museum of Selves

**Job:** Browse archived selves; replay chalk vignette. No shop / ladder.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  FIELD LEDGER · MUSEUM DRAWER                                            │
│  ──────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  ┌─ sample index ──────┐   ┌─ open sample ───────────────────────────┐   │
│  │ ★★★ Quiet Span ═══  │   │  vignette plate                         │   │
│  │ ★★- Daily 08-08 ··· │   │  ··· chalk path ···                     │   │
│  │ ★-- Endless ······· │   │                                         │   │
│  │                     │   │  stamp card · archetype · fingerprint   │   │
│  │ (empty drawer copy  │   │  detail serif blurb                     │   │
│  │  when none filed)   │   │                                         │   │
│  └─────────────────────┘   │  Replay chalk ════════                  │   │
│                            └─────────────────────────────────────────┘   │
│  Back to Field Index ·····                                               │
└──────────────────────────────────────────────────────────────────────────┘
```

List rows = underlined type buttons (same as Field Index), not `ItemList` skins.

### 4.8 PA Strip — subtitles

**Job:** Accessibility captions as a **diegetic PA / teletype strip** on the bottom margin — not a floating glass bar.

```
│  ························· maze ········································ │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │  PA  ·  REWRITE ARMED  ·  mirror_v                                 │  │  ink on paper_deep
│  └────────────────────────────────────────────────────────────────────┘  │  optional plate fill
│  buffer ▓▓▓…                                                             │
```

Sizes small/medium/large scale type only; background plate = `paper_deep` hairline box (never black translucent).

### 4.9 Colophon — credits (new)

**Job:** Compliance credits surface from Field Index.

```
│            ┌────────────────────────────────┐                            │
│            │  COLOPHON                      │                            │
│            │                                │                            │
│            │  Echo Lattice                  │                            │
│            │  a Field Ledger survey         │                            │
│            │                                │                            │
│            │  design / code / …             │  serif body                │
│            │  fonts · licenses              │                            │
│            │  third-party notices           │                            │
│            │                                │                            │
│            │  File away ················    │                            │
│            └────────────────────────────────┘                            │
```

### 4.10 Rebind moment (Hands leaf detail)

```
│  Undo ………………… [X]  Rebind ──                            │
│                                                         │
│         ┌─ waiting for ink ──────────────┐              │
│         │  Press a key · Esc cancels     │  index card  │
│         │  gamepad bindings preserved    │              │
│         └────────────────────────────────┘              │
```

No OS/`AcceptDialog` chrome — same card language, mono instruction line.

### 4.11 Mobile / Deck (1280×800 @ ui_scale 1.25)

```
┌────────────────────────────────────────┐
│ FIELD LEDGER              seed ####    │
│ ┌────────────────────────────────────┐ │
│ │  INDEX CARD (full width − margins) │ │
│ │  actions stack vertically          │ │
│ │  underline hit targets ≥ 36 px     │ │
│ └────────────────────────────────────┘ │
│ A Confirm  B Back     buffer ▓▓▓░░░    │
└────────────────────────────────────────┘
```

Single column; punch-card may compress to 20 visible cells + “+10” mono note if needed — **logic buffer stays 30**.

---

## 5. Component inventory

Implementation names are suggested Godot scripts/scenes under `game/echo_lattice/ui/ledger/` (future code PR). Vision-stable IDs in **bold**.

### 5.1 Foundations

| ID | Component | Role | Replaces |
|---|---|---|---|
| **LedgerLightbox** | Full-bleed `paper_bone` + grid + grain | Shell substrate | Raw ColorRect / void |
| **LedgerPage** | Margin anatomy (header band, body, footer) | Shared chrome | Ad-hoc anchors |
| **LedgerHeader** | `FIELD LEDGER · {LEAF}` + optional seed/build | Folio mark | Random Labels |
| **IndexCard** | Interaction container; hairline + `paper_deep` | Card body | `PanelContainer` skins |
| **InkRule** | 1 px horizontal rule (ink / rust / slate) | Dividers & underlines | StyleBox flat bars |
| **PaperTurn** | Transition player (slot / flip, no black frame) | Nav between leaves | `Tween` fade-to-black |

### 5.2 Controls (diegetic)

| ID | Component | Behavior | Replaces |
|---|---|---|---|
| **IndexAction** | Underlined type button; idle/hover/focus/disabled opacities | Activate | Stock `Button` |
| **FolioToggle** | Blank square vs ink-stamped square + label | Bool | `CheckButton` |
| **FolioSelect** | Label + current value + `▸` cycles or opens **StampList** | Enum | `OptionButton` |
| **StampList** | Vertical index of underlined options on a card | Dropdown | `PopupMenu` |
| **FolioSlider** | Ink track + square stamp thumb; mono value | Float range | `HSlider` |
| **BindingRow** | Action · glyph · Rebind IndexAction | Remap | Ad-hoc HBox+Button |
| **GlyphFooter** | Confirm/Back/… from `InputGlyphs` | Discovery | Drawn strings only |
| **StampNumeral** | Discrete count-up for moves/stars | Feedback | Instant Label set (optional juice) |

### 5.3 Diegetic data widgets

| ID | Component | Data | Assets |
|---|---|---|---|
| **SeedHeader** | Mono grouped seed | `GameState` / chamber seed | `ui/seed_header_256x24.png` |
| **PunchRibbon** | 30-cell move buffer | `moves_since_checkpoint` | punchcard_cell_{empty,filled,rust,warn} |
| **HabitMarginalia** | Dominant habit / archetype print | After identity unlock | Type only |
| **IdentityStampCard** | Rubber-stamp portrait leaf | Boss / birth clears | `identity_stamp_card.gd` |
| **ChalkVignette** | Paper plate + dashed path | Museum / won | `habit_replay_vignette.gd` |
| **WayfindingLine** | Chamber title + § index | Content bible titles | Type |
| **PAStrip** | Subtitle / PA line | `SubtitleOverlay` | Restyle of overlay |
| **StarStamp** | ★ / ★★ / ★★★ ink marks | Clear stars | Glyphs, not UI hearts |

### 5.4 Shell leaves (screens)

| ID | Leaf | Scene (target) | Signals (preserve) |
|---|---|---|---|
| **FieldIndex** | Title | `menu.tscn` | start/continue/daily/endless/hard/museum/settings/quit/wishlist |
| **InstrumentFolio** | Settings | `ui/settings_menu.tscn` | `closed` + existing setters |
| **PauseIndex** | Pause | **new** `ui/pause_index.tscn` | resume/restart/instruments/abandon |
| **ChamberPage** | In-run | `chamber.tscn` margins | caption_changed, etc. |
| **ClearStamp** | Won | `chamber_won.tscn` | next/replay/menu |
| **WingColophon** | End | `end_screen.tscn` | restart/menu/wishlist |
| **MuseumDrawer** | Museum | `museum_screen.tscn` | back |
| **CreditsColophon** | Credits | **new** `ui/credits_colophon.tscn` | closed |

### 5.5 Etched icon set (MVP art — from art bible §9.1)

| Glyph ID | Meaning | Where |
|---|---|---|
| `glyph_undo` | Undo | Chamber footer, Hands |
| `glyph_restart` | Restart | Pause, chamber |
| `glyph_seed` | Seed / daily | Field Index meta |
| `glyph_ghost` | Ghost assist | Chamber |
| `glyph_transform` | Rewrite / habit | Marginalia |
| `glyph_instruments` | Settings | Field Index, Pause |
| `glyph_museum` | Archive | Field Index |
| `glyph_file_away` | Close / back | Folio footer |
| `glyph_wishlist` | Steam CTA | Demo only |

Single-weight etched PNGs or font ligatures; color via modulate (`ink_black` / `slate_teal` / `rust_fossil` for focus).

### 5.6 Theme tokens (CSS-like → Godot Theme / Palette)

Map 1:1 to [`echo_lattice.palette.json`](../../game/echo_lattice/art/palette/echo_lattice.palette.json):

| Token | Hex | UI use |
|---|---|---|
| `--paper-bone` | `#EFE6D2` | Lightbox |
| `--paper-deep` | `#D9CDB0` | Card back / PA plate |
| `--ink-black` | `#141210` | Type, glyphs |
| `--ink-soft` | `#3A342C` | Rules, idle underlines |
| `--slate-teal` | `#2D4A55` | Hover underline, signage |
| `--rust-fossil` | `#8B3A1F` | Focus underline, brand rule |
| `--cadmium-warn` | `#D6432B` | **Not for controls** |
| `--copper-key` | `#B8763A` | Rare interactable accents only |

**Theme resource target:** `game/echo_lattice/ui/ledger/field_ledger.theme` (future) — empty StyleBoxes / flat fonts wired to IndexAction etc.

### 5.7 Audio hooks (UI bus)

| Event | When | Bible |
|---|---|---|
| `ui.select` | Focus move / selection | Paper/ink tick; silence gaps via `AudioDirector.on_ui_select` |
| `ui.hover` (optional) | Mouse hover (unfocused) | Extremely soft fiber; omit if noisy |
| `ui.click` | Confirm IndexAction / toggle stamp | Soft ledger confirm stinger — **not** on shell `_ready` |
| `ui.turn` | PaperTurn between leaves | Paper crease |
| `ui.stamp` | FolioToggle on / star stamp | Rubber stamp |

### 5.8 Localization / a11y inventory

| Concern | Ledger rule |
|---|---|
| Strings | All leaves via `tr()` keys; no art-baked English except brand lockup |
| CJK | Body/display fonts from `fonts/` vendor slots; mono may stay Latin for seeds |
| Focus | Full gamepad neighbor graph per leaf; initial focus = primary IndexAction |
| UI scale | Layout in margins survives 0.85–1.5; punch-card + seed must remain readable |
| Colorblind | Controls use underline position + stamp fill, not hue alone |
| Reduce motion | PaperTurn becomes instant cut (still no black frame); no ambient path animation |

---

## 6. Mapping: current Godot → Ledger

| Current | v3 target | Priority |
|---|---|---|
| `menu.gd` title card | **FieldIndex** polish (fonts, no ready-click, no breathe) | P0 |
| `settings_menu.tscn` Panel + sliders | **InstrumentFolio** + Folio* controls | P0 |
| No pause leaf | **PauseIndex** | P0 |
| `chamber.gd` margins | Keep; formalize **ChamberPage** + HabitMarginalia | P1 |
| `subtitle_overlay.tscn` | **PAStrip** | P1 |
| `chamber_won.tscn` | **ClearStamp** visual pass | P1 |
| `end_screen.tscn` | **WingColophon** visual pass | P1 |
| `museum_screen.tscn` | **MuseumDrawer** visual pass | P1 |
| Missing credits | **CreditsColophon** | P1 |
| Fallback fonts | Bundle display/body/mono | P0 (identity) |
| Etched glyphs | Ship 9 glyphs §5.5 | P1 |

---

## 7. Motion & juice (UI only)

| Verb | Spec |
|---|---|
| Paper slot | Card Y+6 → 0, 120–180 ms, easeOut; opacity 0→1 |
| Page turn | Horizontal shear ≤8 px + paper_deep undercard reveal; ≤220 ms |
| Underline draw | Focus: rule width 0→100% in 80 ms |
| Stamp toggle | 1-frame ink appear + `ui.stamp` |
| Numeral stamp | +1 per 30 ms until target (skip if reduce motion) |
| Forbidden | Fade through black, screen shake on UI, cadmium on focus, continuous pulse |

---

## 8. Acceptance tests (vision QA)

Silent-legible stills (no audio):

1. **Title** — brand survives without reading button labels; seed + buffer visible.  
2. **Instruments** — stranger does not identify “Godot settings”; folio leaves read as documents.  
3. **Pause** — chamber page still readable around card; no blur glass.  
4. **Chamber** — seed + punch-card only chrome; caption in margin.  
5. **Clear / Colophon / Museum** — same underline + stamp language as title.  
6. **Grayscale** — focus/hover still parse via underline weight/position.  
7. **Deck 1280×800 @ 1.25** — all Instrument leaves reachable; no clipped File away.  
8. **Ban sniff** — no purple, bloom, pill CTA, or default gray Panel.

Automated (future code PR): extend `tests/test_field_ledger_juice.py` with theme/ban assertions where feasible; screenshot tour gains `09_instruments.png`, `10_pause_index.png`, `11_colophon.png`.

---

## 9. Implementation order (for follow-up code PR — not this doc)

1. Theme + fonts + **IndexAction** / **IndexCard** / **LedgerLightbox** shared kit.  
2. Restyle **FieldIndex** (remove `_ready` ui.click; kill breathe).  
3. Rebuild **InstrumentFolio** leaves (behavior parity).  
4. Add **PauseIndex**.  
5. **PAStrip**, **ClearStamp**, **WingColophon**, **MuseumDrawer**, **CreditsColophon**.  
6. Glyph art + PaperTurn polish.  
7. Capture screenshot tour + update [`AUDIO_ART_UX.md`](../AUDIT/AUDIO_ART_UX.md) scorecard.

---

## 10. Doc map links

| Doc | Relationship |
|---|---|
| [`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) | Visual pillars, palette, §6 HUD/menus — parent authority |
| [`14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) | What already shipped in playable v2 |
| [`06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md) | UI bus + paper sounds |
| [`ACCESSIBILITY.md`](../RELEASE/ACCESSIBILITY.md) | Behavior contracts Instruments must preserve |
| [`AUDIO_ART_UX.md`](../AUDIT/AUDIO_ART_UX.md) | Gap list this vision closes |
| [`00_OVERVIEW.md`](../ECHO_LATTICE/00_OVERVIEW.md) | Echo Lattice doc map |

---

## 11. Decision log

| Decision | Choice | Rejected |
|---|---|---|
| Settings IA | Multi-leaf folio (stamped tabs) | Single endless scroll panel |
| Dropdowns | StampList card | Native OptionButton popup |
| Pause | Index card over live chamber paper | Immediate hard return to title only |
| Subtitles | PA strip in margin | Floating glass caption |
| Credits | Colophon leaf from Field Index | Buried only in README |
| Engine widgets | Allowed as invisible hosts if fully skinned | Visible default Godot theme |

**Lock statement:** If a control would look at home in a stock Godot project template, it is wrong for Echo Lattice. Redesign it as ledger paper, or cut it.
