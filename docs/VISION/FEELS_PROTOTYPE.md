# Echo Lattice — Why It Still Feels Like a 12-Hour Prototype

**Branch:** `cursor/vision-prototype-tells`  
**Base:** `cursor/echo-lattice-rc1`  
**Mode:** Cloud-only playthrough of code · content · UI · art · audio (screenshots in `docs/ECHO_LATTICE/screenshots/v2_complete/` + static inspection of `game/echo_lattice/`)  
**Non-goals:** Steam Partner packing, AppID gates, trailer encode, capsule uploads, Coming Soon checklist.

---

## Verdict

RC1 has **real systems**: forced transforms, origami slam, habit lever, stars, Daily/Endless/Hard+, Museum archive, PA buses, adaptive music hooks, identity stamps, a11y gates. That is more machinery than a jam build.

It still **plays and looks like a vertical-slice prototype** because the player-facing surface is almost entirely **scaffolding wearing bible vocabulary**. The fantasy (“a Field Ledger that fossilizes how you walk — it learned you”) is sold in copy and architecture diagrams, then delivered as: snap-to-grid stamp, procedural beep, Godot default type, ASCII stars, and a victory screen that literally says **END OF SLICE**.

**Core mismatch:** systems density ≠ sensory authorship. A stranger’s first fifteen minutes read the beeps, the empty beige margins, the `Habit: right-leaning (63%)` HUD, and the mirrored corridor — not `HabitRewriteLever` or `RewriteScoreBias`.

---

## Ranking method

| Axis | Meaning |
|---|---|
| **Player impact** | How fast a cold player (or streamer) files the game as “unfinished jam” vs “authored product” |
| **Evidence** | In-tree screenshots, locale strings, generators, chamber JSON, runtime scripts |
| **Out of scope here** | Store assets, AppIDs, CI, Partner surveys (those are ship ops, not play feel) |

Impact scale used below: **P0** = ruins first-session trust · **P1** = keeps “prototype” label after the slam lands · **P2** = expert/late-act tell.

---

## Top 25 prototype tells (by player impact)

### 1. The entire audio identity is still procedural (lifted, not authored) — **P0**

**Tell:** Footsteps, rewrite slam phrases, win/fail stingers, L0–L3 beds, PA, and UI clicks are still DSP from `tools/audio/generate_echo_lattice_placeholders.py` (now v3: multi-stage ~0.90s slam, Ledger Cell stems, quieter rests). Many filenames still contain `_placeholder`. Material dictionary (paper / rust / chalk recordings) is absent.

**Why it kills:** Sound is the cheapest way humans date a build. Buses + `AudioDirector` + silence policy + phrase *grammar* are real; the *materials* are still a tone generator. Trailer / store must not call this final mix.

**Evidence:** `docs/AUDIT/PRODUCTION_AUDIO_DEBT.md`; `audio/sfx/*_placeholder.*`; `sfx/rewrite/*.ogg` still generator output; compliance forbids marketing a “final mix.”

---

### 2. Tileset is a deterministic placeholder generator, not art — **P0**

**Tell:** Floors, walls, fossils, folding slam tile, player stamp, rust decals, punch-card cells, and capsule thumb are produced by `art/generate_placeholders.py` from palette JSON. Art README: *“These are art-direction stakes, not finished assets.”* Player stamp is a 24×24 (~200-byte) silhouette; door/key tiles exist and are unused.

**Why it kills:** Field Ledger fantasy needs ink, grain, crease, surveyor craft. What ships is noise-jittered 32px rectangles. The slam re-blits one `wall_folding_32` — there is no 12-frame crease strip.

**Evidence:** `game/echo_lattice/art/README.md`; missing bible MVP (walk cycle, checkpoint/start/goal tiles, corner/T junctions) still drawn procedurally in `chamber.gd`.

---

### 3. Typography is Godot’s fallback font — **P0**

**Tell:** Brand lockup, captions, HUD, Museum, win, and end screens all `draw_string(..., ThemeDB.fallback_font, ...)` or default Labels. `fonts/latin/` is empty; CJK slot is `.gitkeep` + fetch script. Art bible asks for display grotesk + newsprint serif + mono; runtime is engine default.

**Why it kills:** On a document game, **type is half the product**. Default Inter-like UI type on beige paper reads as “Godot template,” not ledger.

**Evidence:** `menu.gd` brand draw; `habit_replay_vignette.gd`; `fonts/README.md` (“MVP fallback: Godot default”).

---

### 4. Victory explicitly brands the build as a slice — **P0**

**Tell:** Campaign clear title is `END OF SLICE`. Footer: `Vertical slice · Echo Lattice · VISUAL v2 · ink on paper`.

**Why it kills:** No audit needed — the game tells the player it is unfinished. Internal milestone language on a player-facing screen is the purest prototype tell in the tree.

**Evidence:** `locale/echo_lattice.csv` keys `end.title`, `end.footer`; screenshot `08_wing_clear.png`.

---

### 5. Stars are ASCII `***` / `---` — **P0**

**Tell:** Chamber-won and Museum render star ratings as asterisk/dash strings (`_stars_glyph`, Museum `*-` rows), then inconsistently also print `★` elsewhere.

**Why it kills:** After a “spectacular” slam, the reward screen looks like a terminal self-test. Rating fantasy collapses into monospace accounting.

**Evidence:** `chamber_won.gd` `_stars_glyph`; `museum_screen.gd` row builder; screenshot `07_win_stars.png`.

---

### 6. End screen dumps raw direction counters — **P0**

**Tell:** Wing summary includes `(u:%s  d:%s  l:%s  r:%s)` straight from `habit_profile`.

**Why it kills:** Reads as debug overlay left on. Habit “signature” should be a portrait or ledger stamp — not a struct printout.

**Evidence:** `end.summary` locale; `end_screen.gd` `_summary()`; screenshot `08_wing_clear.png`.

---

### 7. “IT LEARNED YOU” is a tagline; play teaches a mirror of *this path* — **P0**

**Tell:** Menu brand tagline claims personal learning. Authored chambers force a single `transform` string (`mirror_v`, `thicken`, …). `HabitRewriteLever` only **adds** a few softlock-safe cells under score bias. HUD reports `Habit: right-leaning (63%)` — a classifier label, not a felt counter-operator.

**Why it kills:** The pitch and the verb disagree. Players experience geometry photocopy, then a percentage. The expensive habit stack (archetype, bias, balance_v2 counters, audio stingers for `place_deflector`) rarely becomes the *story of the room*.

**Evidence:** `brand.tagline`; `chamber.gd` `_trigger_rewrite()` (forced `_apply_transform` then additive habit cells); transform mix **13/39 `mirror_v`**.

---

### 8. Movement is instant cell teleport; avatar is a glowing stamp — **P0**

**Tell:** No walk tween, no facing frames, no lantern mask asset — `player_pos` snaps, `player_stamp_24` blits, code draws an orange lantern circle each frame.

**Why it kills:** Body feel is the first continuous channel. Snap + procedural halo says “grid prototype,” even when walls fossilize correctly.

**Evidence:** `chamber.gd` move apply + `_draw` lantern circles; art bible walk-cycle still missing.

---

### 9. Clear / win / end screens are sparse Label stacks on flat beige — **P0**

**Tell:** `Chamber Cleared` is centered default type, stats as a text block, Next button low-contrast (light fill + light label), Replay as naked text, Menu crowding the bottom edge. No page-turn, seal, or ledger flourish between chambers.

**Why it kills:** The loop’s resting screens (where streamers talk) look less authored than the slam. Contrast bugs read as “not art-directed.”

**Evidence:** screenshots `07_win_stars.png`, `08_wing_clear.png`; `chamber_won.tscn` / `end_screen.tscn` Control+Label layouts.

---

### 10. Chamber HUD is programmer chrome — **P1**

**Tell:** Top bar: `3 / 35 — Mirror Birth` · `Moves: 10` · `Habit: right-leaning (60%)` · `Restart (R)` · `Menu (Esc)`. Seed row defaults include `SEED  0000 · 0000 · 0000 · 0000` in the scene. Bottom caption is a single centered string.

**Why it kills:** Diegetic “punch-card / seed header” systems exist, but the dominant read is still a debug HUD. Hotkeys printed as UI is jam vocabulary.

**Evidence:** `scenes/chamber.tscn` placeholder labels; screenshots `03`–`06`.

---

### 11. Content silhouette is samey: mirror corridors + hollow floors — **P1**

**Tell:** Transform dominance (`mirror_v` 13, `mirror_v_then_h` 8, `thicken` 7). Many maps are horizontal rail stacks; Quiet Span / Echo Plate leave most of the 24×14 lattice as solid `#` void (8–11 solid bottom rows). Late acts still remix the same family of shapes.

**Why it kills:** After Mirror Birth, novelty is mostly “which transform string?” not “what place is this?” Template geometry makes a 35-chamber book feel like a 12-hour level kit.

**Evidence:** chamber JSON inventory; `02_mirror_birth.json` map; content audit clone/near-clone history; screenshot `03_chamber_start.png` empty corridors.

---

### 12. Identity bosses do not change the win condition — **P1**

**Tell:** Induction / Reflection / Pressure / Mastery identity chambers tag `identity: *_signature|portrait|calcify|nameplate` and may stamp a mask grade on clear — but resonance stays `REACH_GOAL`. No fail-forward critique, no portrait gate, no “sign your name or loop.”

**Why it kills:** Act structure promises authorship exams; play delivers denser mazes with the same clear rule. Boss fantasy stays in captions.

**Evidence:** chamber JSON `resonance`; `identity_stamp.gd` (ceremony / partial ★ fold); design audit I4.

---

### 13. Pedagogy is caption-thin; hints are mostly empty — **P1**

**Tell:** 24/39 chambers have empty `hints[]`. First hint surfaces late via teach flags / rewrite settle — not as a reliable diegetic tutor. Hard variants ship with empty hints. Captions are one imperative line.

**Why it kills:** After Act I, players who soft-bump fossils get silence + undo toast, not craft. Systems for teaching exist; content does not feed them.

**Evidence:** chamber JSON `hints`; `chamber.gd` `_surface_first_hint()`; content audit §2.2.

---

### 14. Wide dead margins: the stage never owns the screen — **P1**

**Tell:** Fixed 24×14 × 32px grid centered on warm flat `ColorRect` paper. Large empty side bands on 1152×672 captures. No desk, binding, blotter, or environmental frame beyond thin page logic.

**Why it kills:** “Document game” without a document object — just a floating maze on filler paper. Looks like a UI kit waiting for art direction pass #2.

**Evidence:** screenshots `03`–`06`; `chamber.tscn` Background ColorRect.

---

### 15. PA “announcer” is four chimes mapped to many line IDs — **P1**

**Tell:** `PaAnnouncer.LINE_TO_EVENT` collapses boot / checkpoint / matched / undo / death / ghost into `pa.attention` / `board_tick` / `rewrite_armed` / `wing_clear`. No VO (intentional), but also no authored institutional *texture* — same stub tones.

**Why it kills:** Diegetic voice is a pillar in the audio bible; players hear one office beep reused. Subtitles carry the character; speakers do not.

**Evidence:** `pa_announcer.gd`; `audio/sfx/pa/*` placeholder set.

---

### 16. Juice is conflicted: impact-game punctuation on a document fantasy — **P1**

**Tell:** Hitstop + particle bursts on rewrite/win remain. Art bible wants calcification, not radiance; older `07_JUICE.md` still documents a TS arena with enemies. Reduce-motion helps; default still sprays rust “smoke” that reads as cheap VFX on placeholder tiles.

**Why it kills:** Neither pure ledger restraint nor premium impact juice — the uncanny middle where effects highlight asset poverty.

**Evidence:** `juice.gd` `rewrite_punch`; screenshot `05_rewrite_slam.png` particles; art bible vs juice overrides table.

---

### 17. Menu sells systems cosplay before play — **P1**

**Tell:** Decorative BUFFER ribbon (thirty boxes, one rust cell), seed glyphs, “Four Acts — 35 chambers. Ink on paper.”, tagline **IT LEARNED YOU** — all before a single fossil. Ambient chalk path is a nice touch; the rest is dashboard for a toy you have not touched.

**Why it kills:** Brand-first is correct; **systems-first chrome** under the brand makes the title card feel like a debug front-matter page.

**Evidence:** screenshot `01_main_menu.png`; `menu.gd` ambient path + index card.

---

### 18. Museum of Selves looks like a debug browser — **P1**

**Tell:** Flat button list: `Title · ***- · archetype`. Detail line is stats prose. Vignette is a small chalk polyline Control. No gallery lighting, no plaque, no ghost race.

**Why it kills:** Retention feature is present as data wiring, absent as place. Players archive “selves” into a settings-adjacent list.

**Evidence:** `museum_screen.gd`; META docs promise more than RC1 ships.

---

### 19. Checkpoint / goal iconography is procedural geometry — **P1**

**Tell:** Checkpoint reads as a blue/teal plus in a box; goal as concentric copper squares — drawn in code, not authored tiles (`floor_checkpoint_32` / `floor_goal_32` missing).

**Why it kills:** The two most important board nouns look like programmer markers. Habit trail + fossil walls do the real storytelling; motifs look temporary.

**Evidence:** `chamber.gd` draw paths; art bible MVP gaps; screenshots `04`/`05`.

---

### 20. Scarcity / tempo fantasy is inert — **P1**

**Tell:** Nearly every chamber ships `tempo_start: 9999`. Balance v2 tempo curves, Reader/Cold modes, and rewrite pressure fiction barely touch standard campaign feel. Rewrite cap is easy to miss as a pressure fantasy when safety nets erase punishing walls.

**Why it kills:** Docs describe a living clock and scarce authorship; play is a relaxed BFS puzzle with a slam cutscene. “Systems” again outrun sensation.

**Evidence:** chamber JSON `tempo_start`; `balance_tuning.gd` tempo helpers underused in the live loop.

---

### 21. Operator earprints do not read as distinct characters — **P2**

**Tell:** Catalog has per-op stingers; runtime aliases transforms into those events — but sources are still short placeholder tones. Habit counter ops may fire a second rewrite SFX the player cannot parse as a new character.

**Why it kills:** Audio bible’s strongest differentiator (each operator has an earprint) never lands in memory. Slam always “sounds like the beep pack.”

**Evidence:** `AudioDirector.on_rewrite`; `sfx/rewrite/*.ogg` sizes/genesis; audio/art audit §3.

---

### 22. Onboarding rooms look unfinished on purpose — and play like it — **P2**

**Tell:** Quiet Span / Echo Plate are pedagogically silent (`transform: none`) but visually barren: long empty halls, tiny stamp, copper goal, caption “Walk. Nothing here learns you yet.”

**Why it kills:** Correct teach structure; wrong first impression. Cold players judge production value before the Mirror Birth hook. Minutes 0–2 look like a missing tileset.

**Evidence:** screenshots `03_chamber_start.png`; `00_quiet_span.json` / `01_echo_plate.json`.

---

### 23. No authored chamber transition — only state swap — **P2**

**Tell:** Win overlay → button → next `load_chamber`. No page flip, stamp press, seed advance animation, or diegetic “next card” ritual despite punch-card UI language.

**Why it kills:** Meta metaphor (ledger / index) never structures time. The product feels like a level select loop with extra JSON.

**Evidence:** `main.gd` flow; `chamber_won.gd` signals; absence of transition scene.

---

### 24. Meta modes share one menu voice — **P2**

**Tell:** Daily / Endless / Hard+ / Museum are additional underlined index rows + meta label stats (`best 0★ / 15`, endless depth). No distinct board, date card, or pressure frame at entry — mode identity is copy in `meta_label`.

**Why it kills:** Systems exist; places do not. Modes feel like flags on the same prototype front-end.

**Evidence:** `menu.gd` `_refresh_progress_copy`; screenshot `02_daily_select.png` (same ledger, different highlight).

---

### 25. Documentation and dead systems outnumber felt verbs — **P2**

**Tell:** Balance archetypes, tempo, invert ballet naming, unused door/key art, stale juice TS paths, dual act ontologies (historical), Reader/Cold modes, workshop-shaped content grammar — much of it **sidecar**. The only verb that always fires is: walk → forced transform → REACH_GOAL.

**Why it kills:** For makers, the repo feels deep. For players, depth that never touches the controller is indistinguishable from absence — except when HUD/end screens leak the unfinished wiring (`Habit: unwritten`, raw u/d/l/r, empty hints).

**Evidence:** design audit I1–I3; `door_32`/`key_32` unused; `28_invert_ballet` still `rotate_180`; this document’s tells 7, 12, 20.

---

## Scoreboard (feel only)

| Channel | Systems present? | Feels shipped? | Prototype tell #s |
|---|---|---|---|
| Audio | Yes (buses, director, catalog) | **No** | 1, 15, 21 |
| Art / avatar | Yes (palette, kit, slam staging) | **No** | 2, 8, 14, 19, 22 |
| Type / UI | Yes (index-card layout, a11y) | **No** | 3, 4, 5, 6, 9, 10, 17 |
| Content / bosses | Yes (39 JSON, acts, hard+) | **Partial** | 11, 12, 13 |
| Habit thesis | Yes (lever, bias, stamps, museum) | **Partial / overclaimed** | 7, 18, 20, 24, 25 |
| Juice / transitions | Yes (hitstop, particles, telegraph) | **Conflicted** | 16, 23 |

**Player-facing grade:** systems-rich prototype · authorship-poor product surface.

---

## What would stop the “12-hour” read fastest (feel-only)

Ordered for *sensation*, not Partner ops:

1. **Replace beep identity** with authored footstep / three operator earprints / one win open-loop / one bed — even a tiny real set beats the generator.  
2. **Ship type** (display + body + mono) and kill `END OF SLICE` / VISUAL v2 footer / ASCII stars / u-d-l-r dump in one pass.  
3. **Author the surveyor** (4-dir walk, no procedural halo) + checkpoint/goal tiles + one crease strip.  
4. **Make habit visible in geometry** once per act (forced op yields to a readable counter the HUD can name in plain speech — not `(63%)`).  
5. **Rebuild minutes 0–2 and the clear screen** as ledger objects (page, stamp, stars as punched marks) so the slam is not the only non-prototype frame.

Do these and the existing systems finally have a body. Until then, RC1 remains a brilliant machine demonstration that still *feels* like it was stood up in a long day.

---

## Method notes

- Play surface inspected via `docs/ECHO_LATTICE/screenshots/v2_complete/` (Godot `--screenshot` tour) plus chamber/menu/win/end/museum scripts and all 39 chamber JSON files.  
- No Godot binary in this cloud environment; conclusions that depend on timing (slam length, hold-to-walk) follow code constants (`REWRITE_DURATION = 0.90`, hold delays) and captures.  
- Sibling audits (`docs/AUDIT/*`) were used as cross-checks; this doc deliberately **excludes** Steam packing and re-ranks purely by **player-felt prototype tells**.
