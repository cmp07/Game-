# Echo Lattice — Audio / Art / UX Consistency Audit

**Branch base:** `cursor/echo-lattice-rc1`  
**Audit date:** 2026-08-09  
**Scope:** Field Ledger vision vs shipped Godot RC1 slice — placeholder vs final, telegraph readability, menu polish, trailer/store asset readiness.  
**Companion backlog:** [`UPGRADE_LIST.md`](UPGRADE_LIST.md)

**Vision authorities**

| Doc | Owns |
|---|---|
| [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) | Field Ledger pillars, palette, materials, rewrite VFX, UI, capsules |
| [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md) | Buses, habit layers, operator stingers, PA, silence, win open-loop |
| [`../ECHO_LATTICE/14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) | Playable ink-on-paper implementation notes |
| [`../RELEASE/STEAM_STORE_FINAL.md`](../RELEASE/STEAM_STORE_FINAL.md) | Capsule / screenshot / trailer ship package |
| [`../RELEASE/capsules/README.md`](../RELEASE/capsules/README.md) | Size-correct capsule placeholders + briefs |

**Verdict:** Direction is locked and the playable loop already *reads* as Field Ledger (paper, ink, rust — not purple void). Almost every production audio/art file is still a **procedural placeholder**. Telegraph + slam systems exist, but several bible rules are diluted in code (operator earprints, diegetic chamber HUD, cadmium exclusivity, no rewrite shake). Store/trailer packs are scaffolded, not Partner-ready finals.

---

## 1. Scorecard (Field Ledger)

| Pillar / channel | Status | Notes |
|---|---|---|
| P1 Legibility (diagram, not murk) | **Mostly pass** | Chambers + screenshots read as a document maze; ghost trail + fossils tell the loop |
| P2 Ink on paper (no glow void) | **Pass with drift** | Viewport/menu are paper; slam stills can read “warm glow” on fold tiles; juice flash/particles risk spectacle |
| P3 Fossilization not radiance | **Pass** | Echo walls use rust materials; slam is crease → lift → slot → bleed |
| P4 One habit accent (rust) | **Pass** | Over-walk colonization + fossil walls; colorblind patterns exist |
| P5 Cartographer honesty | **Pass (scaffold)** | Chamber HUD now prints seed header + live punch-card ribbon on page margins |
| Audio as readability | **Wired, not authored** | `AudioDirector` + catalog + silence policy live; streams are DSP placeholders; content transforms alias to operator stingers |
| Menu Field Ledger polish | **Strong scaffold** | Brand-first title card, index-card column, underline selection — fonts still Godot fallback |
| Trailer / store readiness | **Scaffold only** | Capsules size-correct but stamped placeholders; no MP4s; screenshots 1152×672 |

Legend: **Pass** / **Partial** / **Fail** / **Scaffold**.

---

## 2. Placeholder vs final

### 2.1 Art — inventory

Shipped under `game/echo_lattice/art/` (generator: `generate_placeholders.py`):

| Set | Present | Role |
|---|---|---|
| Palette JSON + strip | Yes | Source of truth (`echo_lattice.palette.json`) |
| Core tiles | Yes | floor fresh/walked, wall fresh/fossil/folding, door, key, player stamp |
| Decals | Yes | chalk footprint + rust_01..04 |
| UI chrome PNGs | Yes | seed header + punch-card cells (empty/filled/rust/warn) |
| Keyart | Thumb only | `keyart/capsule_header_460x215_thumb.png` |

**Art bible §9.1 MVP still missing as files**

- Wall corners ×4, T-junctions ×4  
- `floor_checkpoint_32`, `floor_start_32`, `floor_goal_32` (checkpoint/goal are drawn procedurally in `chamber.gd`)  
- Player 4-dir walk cycle (16 frames) + lantern light mask  
- Rust variants 05–08  
- 12-frame origami crease strip (slam is code-timed blit of one `wall_folding` tile)  
- Index-card menu backer asset, etched icon set (undo/restart/seed/ghost/transform/options)  
- Ghost-path shader material (dashed chalk is code helper — OK for MVP, not “final”)

`door_32` / `key_32` placeholders exist but are **unused** by the chamber renderer (no door/key tiles in content).

### 2.2 Audio — inventory

All playable streams under `game/echo_lattice/audio/**` are **procedural** outputs of `tools/audio/generate_echo_lattice_placeholders.py` (many filenames still contain `_placeholder`). Catalog + buses are real:

| Layer | Files | Bible intent | Ship state |
|---|---|---|---|
| L0–L3 music | `music/L0_bed` … `L3_rewrite` (+ `bed_placeholder` alias) | Habit solidify stack | Placeholder stems |
| Footsteps / warn / generic rewrite | `sfx/*_placeholder.ogg` | Dry click + warn telegraph | Placeholder |
| Per-operator stingers | `sfx/rewrite/*.ogg` (9 ids) | Unique earprints | Placeholder tones; **mostly not selected at runtime** (see §3) |
| PA | `sfx/pa/*` | Brutalist transit, no VO | Placeholder chimes |
| Win open-loop | `win/chamber_resolve`, `queue_next`, `fanfare`, `wing_clear` | Resolve + hunger | Placeholder |
| UI | `ui/ui_click_placeholder.ogg` | Soft ticks | Placeholder |

Compliance already forbids marketing these as “final mix” ([`COMPLIANCE_FINAL.md`](../RELEASE/COMPLIANCE_FINAL.md) §4.3).

### 2.3 Typography / fonts

- Art bible: display grotesk + newsprint serif + mono.  
- Runtime: almost all `draw_string(..., ThemeDB.fallback_font, ...)` and Label defaults.  
- `fonts/latin/` empty; CJK vendor slot is `.gitkeep` only (`fonts/README.md`).  
- **Result:** Field Ledger *layout* is right; type identity is still engine-default.

### 2.4 Store / press placeholders

| Asset | State |
|---|---|
| `docs/RELEASE/capsules/*.png` | Correct Steam sizes; README stamps them as **PLACEHOLDER** — not final illustrator art |
| Capsule palette table in README | **Drifts** from palette JSON (`#F4EFE4` / `#1C1A18` / `#B04A2A` vs `#EFE6D2` / `#141210` / `#8B3A1F`) |
| Library hero | Placeholder **1920×620**; bible prefers **3840×1240** master |
| `presskit/trailers/` | README only — **no** `echo_lattice_15s_vertical.mp4` / `30s` / store loop |
| `presskit/images/gif_sequences/` | Still packs for slam / trail / before-after — good trailer *source*, not encodes |
| `screenshots/v2_complete/` | 8 tour shots @ **1152×672** — loop-proof, below Steam ≥1080p preference |
| Legal / AppID / studio name | Still `[LEGAL_*]` / `YOUR_APP_ID` / `YOUR_STUDIO_NAME` in release docs |

---

## 3. Telegraph readability

Telegraph is the skill channel: players must see/hear *where* the maze will rewrite before it does.

### 3.1 What works

| Signal | Implementation | Assessment |
|---|---|---|
| Visual foreshadow cells | `Chamber._refresh_telegraph()` + cadmium corner ticks in `_draw` | Transformed buffer cells on floor are marked — loop-readable |
| Proximity arming | Warn audio + tension when Manhattan dist to unused checkpoint ≤ 3 | Good “last steps” window |
| Cadmium margin heartbeat | Slam phase `t < REWRITE_HEARTBEAT` draws page-margin flash only | Matches art bible “one heartbeat” |
| Origami slam staging | Crease → cast-shadow lift → slot/overshoot → rust bleed (~0.9s) | Trailer beat is in-engine |
| Audio warn | `AudioDirector.on_rewrite_warn()` → `sfx.rewrite_warn` | Wired |
| A11y dual-channel | Colorblind roles + patterns; reduce-flash / reduce-motion skip heartbeat & shorten slam | Required; present |

### 3.2 Gaps / diluters

1. **Cadmium exclusivity — mitigated.** Far telegraph ticks are slate (checkpoint role); cadmium only at ≤3-step warn + slam margin heartbeat. Blocked-step juice uses ink soft. Full-screen rewrite flash removed from `rewrite_punch`.

2. **Diegetic move-buffer ribbon — landed.** Chamber bottom margin shows a live 30-cell punch-card of `moves_since_checkpoint`; top margin prints the seed header.

3. **Operator earprints — aliased.** Content transforms map through `AudioEvents.REWRITE_OPERATOR_ALIASES` (`mirror_v`→`mirror`, `rotate_180`→`rotate`, …) so campaign rewrites hit unique stingers instead of generic `sfx.rewrite`.

4. **Rewrite juice vs art bible — mitigated.** Shake defaults **off** (intensity 0.35 when enabled). `rewrite_punch` no longer forces trauma or full-screen cadmium; hitstop + origami slam remain.

5. **Pulse language — partial.** Telegraph ticks use tension opacity (no sin pulse). Goal copper plate / menu fold tease still breathe.

6. **Warn re-arm.** `rewrite_warn_armed` clears when leaving the ≤3 ring, so re-entering can re-fire warn SFX — OK for readability, but placeholder warn tone will spam if players dance the threshold.

### 3.3 Acceptance tests (telegraph)

- [ ] Grayscale / colorblind: player, floor, wall, fossil, checkpoint, goal, telegraph still distinct (`--art-grayscale-audit` still called out in art bible; confirm flag or capture suite).  
- [ ] Mute Music: warn + rewrite + PA still audible.  
- [ ] Chamber 0: Music intensity capped to silence; SFX/PA intact.  
- [ ] First rewrite in trailer cut: warn → heartbeat → slam readable muted **and** with headphones.

---

## 4. Menu / shell UX polish

### 4.1 Strengths (aligned with Field Ledger)

- Brand-first lockup (`ECHO LATTICE` + rust rule + `IT LEARNED YOU`) — passes the “remove the nav, still branded” test.  
- Index-card Field Index; buttons are underlined type (focus rust / hover slate) — matches art bible §6.  
- Lightbox paper + ledger grid + grain + ambient chalk path selling the verb.  
- Seed strip + 30-cell buffer ribbon on the title card (diegetic teaching).  
- Gamepad focus chain + glyph footer; demo wishlist slot.  
- Tour shot `01_main_menu.png` proves the look.

### 4.2 Polish gaps

| Issue | Evidence | Target |
|---|---|---|
| Default Inter-like type | `ThemeDB.fallback_font` in `menu.gd` | Condensed grotesk display + mono seed |
| `ui.click` on menu `_ready` | Fires once at boot | Only on confirm / navigation |
| Settings shell | Dim + `PanelContainer` overlay (`settings_menu.tscn`) | Index-card / paper-turn; no frosted-glass vibe |
| Won / end screens | Functional labels; less “loose ledger page” than title | Same underline index language + stamp numerals |
| Ambient fold tease pulses | `sin(_t)` alpha on menu fossils | Discrete stamp or paper-turn, not breathe |
| Credits surface | Compliance asks menu → Credits | Missing as first-class shell entry |
| Chamber chrome | [x] Seed header + punch-card on margins | Keep caption/habit readable at UI scale 1.25 |
| Capsule README hex drift | Marketing palette ≠ `palette.json` | One table; regenerate capsules from palette |

---

## 5. Trailer & store asset readiness

### 5.1 Ready enough for *internal* Coming Soon scaffolding

- Size-correct capsule PNGs in `docs/RELEASE/capsules/`.  
- Screenshot slate (8) + captions in `screenshots/v2_complete/TOUR.md`.  
- Slam frame packs + social scripts (`SOCIAL_CLIP_SCRIPTS.md`).  
- Paste-ready store copy in `STEAM_STORE_FINAL.md`.

### 5.2 Blockers before Partner “final” / Next Fest materials

| Gap | Severity | Detail |
|---|---|---|
| No trailer encodes | **P0** | `presskit/trailers/` empty of MP4; bible + store pack require ~15s / ~30s / optional 60–90s |
| Capsules still PLACEHOLDER | **P0** | Must not ship stamped temps; need illustrator pass per briefs (header/main/small/vertical/hero/logo/icon) |
| Screenshot resolution | **P1** | Recapture ≥1920×1080 (store preference); current 1152×672 is proof only |
| Library hero master | **P1** | Prefer 3840×1240 ledger-spine wide; current 1920×620 placeholder |
| Authored audio for trailer | **P0** | First rewrite + queue-next must not sound like DSP beeps in the announce cut |
| Hi-res silent-legible stills | **P1** | Art bible five stills: reading maze / rewrite / ghost race / habit profile / ledger — map tour shots → fill missing ghost-race & library-hero frames |
| Client `.ico` set | **P2** | Listed in store checklist; not in capsules folder |
| Legal / AppID / studio strings | **P0** (ops) | Block store publish, not art direction |

### 5.3 Trailer beat compliance (announce ~30s)

| Beat | Vision | Asset readiness |
|---|---|---|
| 0–3s first step | Clean corridor + chalk | In-game capturable; needs encode |
| 3–6s buffer fills | Punch-card + seed | **Menu** has ribbon; **chamber** does not — trailer may need HUD work or menu cutaway |
| 6–12s slam | Heartbeat + origami | Frame pack `01_rewrite_slam` ready |
| Rust colonization | Over-walk rust | In-game; needs edit |
| Title / wishlist | Field Ledger card | Menu shot ready; end-card logo still placeholder |

---

## 6. Consistency tensions (resolve explicitly)

These are not “bugs” until product picks a side — they are vision conflicts that currently ship as mixed signals.

| Tension | Art / Audio bible | Shipped behavior | Recommendation |
|---|---|---|---|
| Rewrite screen shake | Forbidden (document game) | [x] Default off; rewrite opt-in subtle only | Keep hitstop/particles sparse |
| Cadmium use | ≤1% heartbeat | [x] Slate far ticks; cadmium warn+heartbeat | Guard future juice from re-introducing warn flashes |
| Operator stingers | Unique per operator | [x] Alias map in `rewrite_event_id` | Author final one-shots (still placeholders) |
| Juice TS doc (`07_JUICE.md`) | Enemy pulsar telegraphs, bloom-ish post | Godot maze has checkpoint telegraph | Treat Vite juice as historical; Field Ledger juice rules win |
| Capsule hex table | Must match palette JSON | README approx hex drifted | Regenerate marketing placeholders from JSON |

---

## 7. What already matches the vision (do not regress)

- Purple void retired; paper margin + ink walls + rust fossils in playable v2.  
- Steam-hit menu composition (brand, one card, buffer teaching).  
- Structured audio architecture (buses Master/SFX/Music/UI/PA, silence policy, adaptive intensity API).  
- Slam staging and screenshot freeze hooks for marketing captures.  
- Accessibility: colorblind roles, reduce flash/motion, separate bus mutes path.  
- Release docs that correctly label placeholders and forbid AI-dungeon framing.

---

## 8. Related paths

| Path | Use |
|---|---|
| `game/echo_lattice/art/` | Placeholder textures + palette |
| `game/echo_lattice/audio/` | Placeholder streams + `events/audio_events.json` |
| `game/echo_lattice/scripts/chamber.gd` | Telegraph, slam, materials |
| `game/echo_lattice/scripts/menu.gd` | Title card |
| `game/echo_lattice/scripts/juice.gd` | Shake / hitstop / flash / particles |
| `docs/RELEASE/capsules/` | Store image scaffolding |
| `docs/RELEASE/presskit/` | Trailers (empty), GIF sequences, factsheet |
| [`UPGRADE_LIST.md`](UPGRADE_LIST.md) | Prioritized remediation backlog |
