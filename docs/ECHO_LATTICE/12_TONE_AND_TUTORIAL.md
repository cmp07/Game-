# Echo Lattice — Tone & Tutorial

**Doc:** `12_TONE_AND_TUTORIAL`  
**Product:** Echo Lattice (Game 1)  
**Lane:** Tutorial / Narrative (writer of record for diegetic copy + teach script)  
**Status:** Spec + runtime data tables  
**Last updated:** August 2026  

**Companions (runtime):** [`game/echo_lattice/data/tutorial/`](../../game/echo_lattice/data/tutorial/)  
**Reads / must not contradict:** [`00_PRODUCTION_BIBLE`](00_PRODUCTION_BIBLE.md) · [`01_GDD`](01_GDD.md) · [`02_SYSTEMS`](02_SYSTEMS.md) · [`06_AUDIO_BIBLE`](06_AUDIO_BIBLE.md) · [`docs/FIVE_GAMES_TO_BUILD.md`](../FIVE_GAMES_TO_BUILD.md)

> Production note: the ownership map in `00_PRODUCTION_BIBLE` listed this lane as `21_TUTORIAL_NARRATIVE.md`. This file is the canonical path for that lane under the numbered doc set (`00`…`12`…). Treat `21_TUTORIAL_NARRATIVE` as a deprecated alias if referenced elsewhere.

---

## 1. Intent

Echo Lattice teaches **rewrite authorship** — not lore. The fantasy lands when the player walks a clean hall, hits a checkpoint, and watches walls slam into the shape of their own loop.

| Must | Must not |
|---|---|
| Spectacle teaches (“I made that”) | Walls of tutorial text |
| Diegetic **readouts** (station board / lattice PA) | Character dialogue, named NPCs, VO essays |
| Short lines (≤ ~12 words; prefer ≤ 8) | Quest-log novels, AI lore dumps |
| Silent teaching beats preferred | Modal popups that steal agency |
| Audio + ghost + geometry as primary channels | Tooltips that explain the whole grammar |

Audio bible rule preserved: **no vocals / spoken VO tutorials**. Copy is on-screen diegetic text only.

---

## 2. Tone bible

### 2.1 Voice

**Register:** Brutalist transit authority meets forensic readout.  
Think subway LED boards, maintenance tickets, and a corridor that files paperwork on your footsteps — not a fantasy dungeon guide, not a cozy narrator, not a snarky robot sidekick.

| Axis | Lean toward | Avoid |
|---|---|---|
| Temperature | Cool, precise, slightly ominous | Warm coach, meme snark, horror gore |
| Agency | Second person implied (“your loop”) | Named protagonist biography |
| Metaphor | Transit / lattice / echo / habit | Magic schools, corporate dystopia essays |
| Humor | Dry, rare, structural | Quip every beat |
| Certainty | Deterministic (“REPLAY MATCHES”) | “Maybe”, RNG language |

**Brand test:** If you strip the product name and the copy could sit in a generic sci-fi horror game, rewrite it. Echo Lattice copy should smell like **maps, loops, and blame**.

### 2.2 Lexicon (preferred / banned)

| Prefer | Ban / defer |
|---|---|
| lattice, wing, chamber, checkpoint | level, stage, dungeon master |
| rewrite, transform, buffer, ghost | AI, neural, generated story |
| habit, loop, echo, trace | destiny, chosen one, corruption lore |
| door, key, plate, corridor | quest, objective complete essay |
| seed, replay, match | random, luck, RNG (except debug) |

Steam trailer line stays sacred: **“It learned you.”** In-game diegesis may echo that idea without repeating the marketing sentence every chamber.

### 2.3 Line budget rules

1. **Hard cap:** 14 words. Soft target: 8.  
2. **One job per line.** Never teach two systems in one toast.  
3. **ALL CAPS** only for station-board / PA style (`BOARDING`, `REWRITE ARMED`). HUD prompts use Title Case or short sentence case.  
4. **No paragraphs.** If you need a paragraph, the beat is wrong — fix the chamber.  
5. **Skipable / non-modal.** Lines appear as toasts, plate inscriptions, or ChamberLabel subtitles — never pause the sim for reading homework.  
6. **Repeat sparingly.** First-time only flags live in save meta (`tutorial_flags`).

### 2.4 Presentation channels

| Channel | Use for | Max on screen |
|---|---|---|
| `ChamberLabel` title | Wing + chamber name | 1 title |
| Plate inscription | Local teach cue at interactables | 1 line |
| Toast / PA strip | Event lines (rewrite, undo unlock) | 1 line, ≤ 3.5 s |
| Loading tip | Between scenes / boot | 1 tip |
| MoveBufferStrip | Glyphs of recent moves | Visual, no prose |
| Ghost trail | Authorship proof | Visual |

---

## 3. Diegetic fiction (lightweight)

Enough fiction to flavor copy — not a novella.

- The playable space is a **lattice**: sealed transit wings that rebuild geometry from recorded motion.  
- The player is an unnamed **walker**. No backstory dump.  
- The lattice is not a character with feelings; it is a **system that mirrors**. Blame language is procedural (“LOOP ARCHIVED”), not emotional.  
- Checkpoints are **plates**. Keys/doors are mechanical.  
- Ghosts are **echoes** of the buffer — your prior path, not spirits.

If GDD later adds a stronger myth, this doc still forbids dialogue essays. Myth stays in chamber titles, optional gallery cards, and Steam copy.

---

## 4. Tutorial philosophy

### 4.1 The one spectacle

> First chamber: **no rewrite**.  
> First checkpoint: **mirror your path into walls**.  
> The “wait — *I* made that?” beat **is** the tutorial.

Everything else (undo, key-after-rewrite, second transform) hangs off that recognition.

### 4.2 Pedagogy rules

1. **Show, then name.** Geometry moves before the PA names it.  
2. **Rule of threes:** introduce → force reuse → twist (Miyamoto). Never front-load the transform deck.  
3. **Failure teaches a reusable rule.** Softlocks forbidden; undo/reset always available after beat `T03`.  
4. **One new idea per chamber.** Mirror is enough for the opening wing’s first half.  
5. **Veterans skip cleanly.** Clearing `wing_00` sets `tutorial_complete`; never re-toast on New Run unless Settings → Replay Tutorial.  
6. **Accessibility:** every critical diegetic line has a visual channel; nothing exclusive to VO (there is no VO).

### 4.3 Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Modal “How to play” binder | Cut; put verbs in chamber geometry |
| Lore terminal with 3 screens | One plate line or delete |
| Explaining mirror math in prose | Ghost overlay + rewrite FX |
| Teaching rotate/thicken/invert in wing 0 | Unlock later; titles can foreshadow only |
| Snarky failure (“skill issue”) | Neutral PA: `PATH CLOSED — REPLAY HABIT` |

---

## 5. Tutorial beat script (Wing 0 — Induction)

Runtime table: [`tutorial_beats.json`](../../game/echo_lattice/data/tutorial/tutorial_beats.json).

Design targets: **≤ ~8–12 minutes** for a new player; each beat ≤ ~90 s median. Controllers and keyboard share the same lines (glyphs come from UI, not this doc).

| Beat | Chamber | Teach | Player action | Fail / recover | Diegetic cue (first time) | Silent proof |
|---|---|---|---|---|---|---|
| **T00** | `ch_w0_00_quiet_span` | Move | Reach door; no checkpoint rewrite | Walls only block; no death | Plate: `WALK THE SPAN` | Clean hall; buffer glyphs appear |
| **T01** | `ch_w0_01_echo_plate` | Checkpoint arms buffer | Step on plate after a short path | Plate idle until stepped | PA: `CHECKPOINT — BUFFER ARMED` | Plate ring SFX; buffer highlight |
| **T02** | **Spectacle** `ch_w0_02_mirror_birth` | **Rewrite = your path** | Take a visible loop/corridor → plate → walls become mirrored habit | If confused: ghost pulses on your loop | PA: `REWRITE FROM YOUR TRACE` then `IT MATCHES YOU` | Walls = ghost; seed string visible |
| **T03** | `ch_w0_03_break_the_loop` | Change habit to pass | Old loop now blocked; path differently to door | Undo unlocked if stuck mid-habit | Toast: `UNDO CLEARS A STEP` (on first blocked sequence) | Forced path diversity |
| **T04** | `ch_w0_04_key_after` | Interact + rewrite order | Rewrite may seal key; re-route; pick key; door | Reset chamber if key soft-locked (guard) | Plate near key: `TAKE · THEN EXIT` | Key only after understanding space |
| **T05** | `ch_w0_05_ghost_witness` | Ghost literacy | Optional ghost replay toggle / automatic echo on plate | — | PA: `ECHO ON THE FLOOR` | Ghost race against last attempt |
| **T06** | `ch_w0_06_wing_seal` | Wing clear / meta tease | Clear final Induction door | — | PA: `WING CLEAR — TRACE FILED` | Unlock note for first transform pack *name only* |

**Spectacle staging notes (T02):**

1. Layout is an obvious U-turn or rectangle — the mirrored walls must be *legible* as the player’s route.  
2. Pre-rewrite: ghost trail at 40% opacity following the buffer.  
3. On plate: 0.4–0.7 s hold → rewrite sting (audio bible) → walls bake.  
4. Only then fire PA line `IT MATCHES YOU` (or toast variant).  
5. Door opens on the *new* geometry’s readable path — not a free teleport.

**Graduation:** After T06, `tutorial_flags.induction_complete = true`. Wing 1+ uses chamber titles + rare tips; no more compulsory PA teaching unless a **new transform** is introduced (one line at first use).

---

## 6. Transform introduction lines (post-tutorial)

When Systems unlocks a new operator, fire **one** first-time line — never a wiki card.

| Transform | First-use PA / toast |
|---|---|
| Mirror | `REWRITE · MIRROR` |
| Rotate | `REWRITE · ROTATE BUFFER` |
| Thicken | `REWRITE · THICKEN TRACE` |
| Invert | `REWRITE · INVERT TRACE` |

Longer explanations live in optional Meta gallery blurbs (≤ 20 words), not during chambers.

---

## 7. Chamber titles

Runtime table: [`chamber_titles.json`](../../game/echo_lattice/data/tutorial/chamber_titles.json).

### 7.1 Title craft

- **2–4 words.** Evocative, not instructional.  
- Prefer concrete transit/lattice imagery over abstract emotion.  
- Subtitle (optional, ≤ 6 words) may hint the teach without spoiling the spectacle.  
- Demo / marketing may show titles; do not put mechanics equations in titles.

### 7.2 Wing 0 (Induction) titles

| ID | Title | Subtitle |
|---|---|---|
| `ch_w0_00_quiet_span` | Quiet Span | No rewrite yet |
| `ch_w0_01_echo_plate` | Echo Plate | Buffer arms here |
| `ch_w0_02_mirror_birth` | Mirror Birth | Your loop, made solid |
| `ch_w0_03_break_the_loop` | Break the Loop | Habit is a wall |
| `ch_w0_04_key_after` | Latch Remains | Order matters |
| `ch_w0_05_ghost_witness` | Ghost Witness | Echo on the floor |
| `ch_w0_06_wing_seal` | Wing Seal | Trace filed |

### 7.3 Wing 1 (first paid wing — starter set)

Used so Chamber Content / Core have consistent naming even before `20_CHAMBERS` lands. Titles only — layouts owned by Chamber Content.

| ID | Title | Subtitle |
|---|---|---|
| `ch_w1_00_service_entrance` | Service Entrance | Same seed, new blame |
| `ch_w1_01_double_rail` | Double Rail | Two habits, one plate |
| `ch_w1_02_turnout` | Turnout | Leave a kinder corridor |
| `ch_w1_03_underpass` | Underpass | Low ceiling, long memory |
| `ch_w1_04_switchback` | Switchback | Hesitation thickens |
| `ch_w1_05_platform_edge` | Platform Edge | Do not loop the lip |
| `ch_w1_06_transfer_hall` | Transfer Hall | Ghost crosses first |
| `ch_w1_07_signal_bridge` | Signal Bridge | Cross only once |
| `ch_w1_08_yard_limit` | Yard Limit | Buffer ends at red |
| `ch_w1_09_terminus` | Terminus | Wing files you |

---

## 8. Loading tips

Runtime table: [`loading_tips.json`](../../game/echo_lattice/data/tutorial/loading_tips.json).

### 8.1 Rules

- Tips are **optional literacy**, never required for the next chamber.  
- Mix: 50% systems clarity, 30% tone, 20% practical UX (undo, seed, accessibility).  
- No spoilers for transforms the player has not unlocked (`min_unlock` field).  
- No jokes that undermine determinism trust.  
- Weight field allows rare legendary tips without flooding.

### 8.2 Starter pool (see JSON for full set)

Examples:

- `The lattice rebuilds from your last moves — not from luck.`  
- `Same seed. Different walker. Different building.`  
- `If a wall feels personal, check your ghost.`  
- `Undo is not shame. It is editing.`  
- `Seed stays on screen so trust stays intact.`

---

## 9. Diegetic lines catalog

Runtime table: [`diegetic_lines.json`](../../game/echo_lattice/data/tutorial/diegetic_lines.json).

Keyed by `line_id` for Core / UI binders. Fields:

| Field | Meaning |
|---|---|
| `id` | Stable string id |
| `text` | Display string |
| `channel` | `pa` · `toast` · `plate` · `title_card` |
| `when` | Event enum (`on_enter`, `on_checkpoint`, `on_rewrite`, …) |
| `once_flag` | Optional meta flag name |
| `priority` | Higher wins if two fire together |

### 9.1 Core event lines (excerpt)

| ID | Text |
|---|---|
| `pa.boot.lattice_online` | `LATTICE ONLINE` |
| `pa.checkpoint.armed` | `CHECKPOINT — BUFFER ARMED` |
| `pa.rewrite.fired` | `REWRITE FROM YOUR TRACE` |
| `pa.rewrite.matched` | `IT MATCHES YOU` |
| `pa.undo.hint` | `UNDO CLEARS A STEP` |
| `pa.death.habit` | `PATH CLOSED — REPLAY HABIT` |
| `pa.wing.clear` | `WING CLEAR — TRACE FILED` |
| `plate.walk_span` | `WALK THE SPAN` |
| `plate.take_exit` | `TAKE · THEN EXIT` |
| `pa.ghost.floor` | `ECHO ON THE FLOOR` |

Full set + variants live in the JSON (including rare lines and transform first-use).

---

## 10. Runtime integration contract

For Game Core / UI / Scaffold agents:

1. Load JSON from `res://data/tutorial/` (Godot project root = `game/echo_lattice/`).  
2. Do not hardcode English strings in GDScript if an id exists here.  
3. `ELSave` meta should persist `tutorial_flags: Dictionary` (string → bool).  
4. Fire lines through a single `DiegeticCopy.play(id)` (or UI toast service) so Audio can duck Music −2 dB for PA channel if desired — **still no VO**.  
5. If a beat chamber id changes in Chamber Content, update `tutorial_beats.json` in the same PR.  
6. Localization: later wrap `text` through `tr()`; keep ids stable. CSV under `data/localization/` may mirror these tables post-MVP.

---

## 11. Acceptance tests (copy + teach)

| # | Test | Pass |
|---|---|---|
| A1 | Muted audio, first-time player | Completes T02 and verbalizes “the walls are my path” without reading a paragraph |
| A2 | No line exceeds 14 words | Automated count on JSON |
| A3 | T00 has zero rewrite | Systems assert |
| A4 | T02 rewrite deterministic | Same buffer → same walls; ghost overlays path |
| A5 | Returning player | No compulsory Induction PA spam when `induction_complete` |
| A6 | Tone pass | No “AI”, no NPC names, no quest-log voice in tutorial pool |
| A7 | Accessibility | Lines readable at 125% UI scale; not sole carrier of fail state |

---

## 12. Related documents

| Doc | Role |
|---|---|
| `00_PRODUCTION_BIBLE` | Lock, DoD (“teach without essay”) |
| `01_GDD` | Loop / session fantasy |
| `02_SYSTEMS` | Operators named in §6 |
| `03_TECH_ARCHITECTURE` / `10_TECH_*` | Shell HUD channels, data folders |
| `06_AUDIO_BIBLE` | No VO; rewrite sting timing vs PA |
| `20_CHAMBERS` | Layout ownership for titled chambers |
| `32_UI` / UI polish | Toast / plate widgets |
| `40_ACCESSIBILITY` | Hold-to-walk, colorblind — copy must remain secondary |
| `70_MARKETING` | Trailer line “It learned you.” — keep in sync |

---

## 13. Decision log

| Decision | Choice | Rationale |
|---|---|---|
| Dialogue | **None** (diegetic text only) | Matches audio bible + production north star |
| Tutorial structure | Wing 0 Induction, spectacle at T02 | FIVE_GAMES teach beat |
| Doc path | `12_TONE_AND_TUTORIAL.md` | Numbered Echo Lattice set; fulfills Tutorial/Narrative lane |
| Runtime data | JSON under `game/echo_lattice/data/tutorial/` | Tech folder layout; parallel-agent safe |
| Transform teaching | One PA line on first use | No deck binder mid-run |
