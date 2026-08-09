# Field Ledger — Feel Quick Wins Spec

**Branch:** `cursor/feel-quick-wins`  
**Base:** `cursor/echo-lattice-rc1`  
**Authority:** [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) · [`../AUDIT/AUDIO_ART_UX.md`](../AUDIT/AUDIO_ART_UX.md) · [`../AUDIT/UPGRADE_LIST.md`](../AUDIT/UPGRADE_LIST.md)  
**Scope rule:** Highest-impact *“stops looking basic”* feel wins that fit **Wing I Field Ledger** and do **not** need full V3 art (no new tiles, fonts, capsules, or authored audio). Pure habit→geometry fantasy only — no horror, combat, or glow-void drift.

---

## Notes (read before code)

Shipped RC1 already reads as ink-on-paper, but several surfaces still telegraph *prototype UI*:

| Surface | Why it still feels basic | Bible / audit hook |
|---|---|---|
| Cold boot | Instant menu + accidental `ui.click` | Art bible §6 motion; UPGRADE P2-05 |
| Menu Field Index | Flat card; fold tease *breathes* | §6 “paper is still”; P1-05 |
| Settings overlay | Dim glass + default panel | §6 no translucent panels; P2-02 |
| Chamber page | Thin 24 px pad, no ledger spine / registration | §3 ≥2-tile margin intent; P5 cartographer honesty |
| Rewrite approach | Warn re-arms at dist=3; little pre-slam page tension | Telegraph skill channel; P1-06 |

Full V3 (fonts, origami strip, wall junctions, final mix) is **out of scope**. This pass only stamps diegetic chrome and anticipation that code can own today.

---

## Selected wins (implement these five)

### QW-1 · Boot title (cold start)

**Feel:** Opening a field notebook, not spawning a UI root.  
**Ship:** Short diegetic title plate before first menu — paper wash, `ECHO LATTICE` lockup, rust rule, `FIELD LEDGER · WING I`. Paper-still hold (~1.1s), then hand off to menu.  
**Skip:** `--selftest`, `--screenshot`, `--deck-layout-check`, and any return-to-menu after the first boot.  
**Not:** Animated logo swirl, fade-from-black, or non-ledger copy.

### QW-2 · Diegetic menu chrome

**Feel:** Loose index card on a lightbox, not a game shell.  
**Ship:**
1. Stop `ui.click` on menu `_ready` (confirm/nav only).
2. Kill continuous fold-tease pulse — discrete stamp when the ambient buffer fills.
3. Field Index card gains binder holes + double header rule (drawn chrome; no new PNG).

### QW-3 · Settings as index card

**Feel:** Another ledger plate clipped over the page.  
**Ship:** Restyle Settings overlay — opaque paper dim (not charcoal glass), `PAPER_BONE` plate, ink rule, no modal shadow. Title keyed via existing `settings.title`.  
**Not:** Full settings IA rewrite or font vendoring (P2-01 stays open).

### QW-4 · Chamber page framing

**Feel:** Maze sits *inside* a bound ledger sheet.  
**Ship:** Wider page pad (40 px), left binding wash, corner registration ticks, double ink rule. Diegetic HUD bars unchanged.  
**Not:** Wing tint packs (P5-01) or new wayfinding wall signs.

### QW-5 · Rewrite anticipation

**Feel:** The page knows before the slam — skill-readable, cadmium-honest.  
**Ship:**
1. Warn **hysteresis** — arm at ≤3, disarm only at ≥5 (or empty buffer / no telegraph).
2. While armed/near: page-corner tension ticks (slate → cadmium by tension) + slightly heavier page rule.
3. Goal plate stops breathing (`sin` pulse → static copper stamp). Menu fold tease covered in QW-2.

Expose `is_rewrite_warn_active()` so the punch-card ribbon shares the same arm state.

---

## Explicitly deferred (not this PR)

- Vendored Latin/CJK fonts, capsule finals, trailer encodes, authored SFX/stems  
- 12-frame origami atlas, wall corners/T-junctions, player walk cycle  
- Won/end/daily restyle pass, Credits scene, wing tint chapters  
- Any genre mash or “premium glow” juice

---

## Acceptance (feel)

1. Cold boot shows brand plate once; tooling/screenshot paths never wait on it.  
2. Menu boot is silent until the player navigates; fold fossils do not pulse.  
3. Settings reads as paper-on-paper.  
4. Chamber stills show binding + registration without cluttering the diagram.  
5. Walking the checkpoint ring does not spam warn; approaching still escalates page tension.  
6. `python3 game/echo_lattice/tests/test_field_ledger_juice.py` and locale/chamber validators stay green.

---

## Files touched (expected)

| Path | Role |
|---|---|
| `docs/VISION/QUICK_WINS_SPEC.md` | This note |
| `game/echo_lattice/scripts/boot_title.gd` + `scenes/boot_title.tscn` | QW-1 |
| `game/echo_lattice/scripts/main.gd` | Cold-boot gate |
| `game/echo_lattice/scripts/menu.gd` | QW-2 |
| `game/echo_lattice/scripts/a11y/settings_menu.gd` | QW-3 |
| `game/echo_lattice/scripts/chamber.gd` | QW-4 / QW-5 |
| `game/echo_lattice/scripts/chamber_scene.gd` | Punch-card shares warn state |
| `game/echo_lattice/locale/echo_lattice.csv` | Boot wing line |
| `game/echo_lattice/tests/test_field_ledger_juice.py` | Static feel gates |
