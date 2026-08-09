# Echo Lattice — First Ten Minutes (Vision)

**Authority:** cold-player / Next Fest demo experience for `game/echo_lattice/`.  
**Product surface:** **Echo Lattice Demo** (Act I — Induction through **Who Walked**).  
**Companions:** [`../RELEASE/DEMO_SPEC.md`](../RELEASE/DEMO_SPEC.md) · [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) · [`../ECHO_LATTICE/07_JUICE.md`](../ECHO_LATTICE/07_JUICE.md) · [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md)

This doc is the **premium path** — not average playtime, not speedrun. It is the second-resolution script a cold player *should* feel when juice, silence, PA, and chamber pedagogy all land. Code/content that fights this timeline is a bug against vision.

---

## 1. Thesis

> In ten minutes the lattice does not *explain* itself — it **learns you once**, then asks you to walk cleaner.

| Beat | Time | Feeling |
|---|---|---|
| Silence literacy | 0:00–1:30 | Paper, ink, four directions. No lecture. |
| Buffer arm | 1:30–2:15 | Checkpoint is a plate, not a trap. |
| **Mirror Birth** | 2:15–3:30 | Authorship ceremony. “It matches you.” |
| Operator literacy | 3:30–7:30 | Cleaner walk · horizontal · dual commit · rotate · thicken |
| Identity close | 7:30–9:45 | **Who Walked** — leave a readable signature |
| Wishlist breath | 9:45–10:00 | One CTA. No spoilers. Desire, not dump |

**Hard gates already shipped**

- Quiet Span → Echo Plate → Mirror Birth shortest-path sum ≤ **90** steps (`tests/test_onboarding_path.py`).
- Demo allow-list = Act I only (`DemoBuild` + Windows Demo exclude filters).
- Wishlist CTA only when `DemoBuild.wishlist_cta_enabled()`.

---

## 2. Premium feel contract

Field Ledger language. Brutalist transit PA. Paper origami slam. Silence as material.

| Do | Don’t |
|---|---|
| One job per chamber; caption teaches, hint coaches once | Wall-of-text tutorials, floating tip spam |
| Hold after first slam so orange = *your* mirror reads | Smash-cut into the next chamber mid-awe |
| Operator earprints + PA duck Music on rewrite | Generic UI beeps for authorship |
| Cadmium ≤1% — single heartbeat at slam start | Constant glow, shake-as-default, slot-machine juice |
| Chamber-won as punch-card stamp, then hungry queue | Meta screens, Act names beyond Induction, hard-mode tease |
| Undo teach on first self-wall (Z), once | Nagging undo reminders every bump |

**Motion budget (first 10 min):** ≥3 intentional motions that sell authorship — (1) chalk habit trail grow, (2) origami rewrite slam (crease → lift → slot → rust), (3) chamber-won stamp / star settle. Footstep weight and PA attention tones are supporting, not spectacle.

---

## 3. Demo path spine (chamber order)

Exact campaign order from `content/acts.json` Act **induction**:

| # | Id | Title | Transform | Role | Par | Target clock |
|---|---|---|---|---|---|---|
| 0 | `00_quiet_span` | Quiet Span | `none` | lesson | 12 | 0:20–1:20 |
| 1 | `01_echo_plate` | Echo Plate | `none` | literacy | 14 | 1:20–2:10 |
| 2 | `02_mirror_birth` | **Mirror Birth** | `mirror_v` | lesson / hook | 28 | 2:10–3:30 |
| 3 | `03_break_the_loop` | Break the Loop | `mirror_v` | remix | 48 | 3:30–4:40 |
| 4 | `04_ceiling_first` | Ceiling First | `mirror_h` | lesson | 42 | 4:40–5:35 |
| 5 | `05_two_glances` | Two Glances | `mirror_v` | remix | 55 | 5:35–6:40 |
| 6 | `06_far_side` | Far Side | `rotate_180` | lesson | 44 | 6:40–7:30 |
| 7 | `07_first_thicken` | First Thicken | `thicken` | lesson | 46 | 7:30–8:25 |
| 8 | `08_identity_induction` | Who Walked | `mirror_v` | boss | 70 | 8:25–9:45 |
| — | end screen | DEMO COMPLETE | — | CTA | — | 9:45–10:00 |

**Out of path:** Acts II–IV, hard variants (`Mirror Birth+`), Daily Challenge as the cold-start route, Museum, achievements, late-act names.

**Pacing math (premium, deliberate):** ~0.7–1.0 intentional steps/sec + 2–4 s telegraph/commit + 3–5 s won-screen. Par sum Act I ≈ 359 steps → ~6–7 min pure walk + ceremony ≈ **9–10 min** for a guided cold clear. Stuck loops push past 10 — undo teach and generous Mirror Birth floor exist so the *first authorship* still lands under 3:30.

---

## 4. Second-by-second timeline

Clock starts at **first interactive frame** after boot fade (menu already settled). Times are **target**, not hard fails — Mirror Birth must still land by **3:30**.

### 0:00–0:20 · Boot & brand (menu is the lobby, not the game)

| t | Event |
|---|---|
| 0:00–0:02 | Black → Field Ledger grain. No logo sting louder than paper. |
| 0:02–0:06 | **ECHO LATTICE** lockup hero-level; demo subtitle: `Demo — Act I · Mirror Birth. Ink on paper.` |
| 0:06–0:12 | Cursor/gamepad focus on **Begin** (or Continue if save). Music = SilenceDirector Induction cap (near silence). |
| 0:12–0:18 | Confirm. UI click on UI bus only. Brief punch-card wipe into chamber. |
| 0:18–0:20 | Quiet Span seed header + bottom ribbon settle. Caption: *Walk the span.* |

### 0:20–1:20 · Quiet Span — four directions, green seal

| t | Event |
|---|---|
| 0:20–0:28 | Player idle allowed. No HUD lecture. Hint available but not auto-shoved. |
| 0:28–0:50 | First steps. Soft footstep SFX only. Chalk trail begins — readable, not neon. |
| 0:50–1:05 | Corridor literacy: walls are ink, goal is green seal. No checkpoint. |
| 1:05–1:12 | Reach `G`. Win fanfare (resolve → hungry interval). Stars optional / soft. |
| 1:12–1:20 | Chamber-won stamp → auto or confirm **Next**. No meta divert. |

**Chamber job:** prove the verb is *walk*. Silence is the brand.

### 1:20–2:10 · Echo Plate — buffer without fossils

| t | Event |
|---|---|
| 1:20–1:28 | Caption: *Step the plate. Still asleep.* Motif banner aligns. |
| 1:28–1:45 | Walk toward `C`. Trail arms; PA may tick once on plate approach (attention tone, no VO). |
| 1:45–1:55 | Step `C`. **Literacy beat:** buffer / path-arms (`_teach_checkpoint_armed`). `rewrite.cap: 0` — **no fossils**. Hint: *The plate arms your buffer. No walls yet.* |
| 1:55–2:05 | Continue to `G` with armed trail still ghost, not wall. |
| 2:05–2:10 | Clear → Next. Player now knows plates matter before the slam. |

**Chamber job:** checkpoint literacy without spectacle theft.

### 2:10–3:30 · Mirror Birth — the product

| t | Event |
|---|---|
| 2:10–2:18 | Chamber load. Caption: *Cross the checkpoint. Your path becomes wall.* Spectacle tag live. |
| 2:18–2:50 | Deliberate corridor walk. Telegraph ghost of mirrored cells intensifies near `C`. Music still restrained; rewrite-warn tension allowed. |
| 2:50–2:52 | Enter `C`. Cadmium **single** margin heartbeat (≤1%). Hitstop-light begins. |
| 2:52–3:01 | **Origami slam (~0.90 s):** creases → paper lift → slot → 1 px overshoot → rust bleed. Operator stinger `mirror_v`. Music duck −3.5…−4.5 dB. |
| 3:01–3:08 | Hold. PA / subtitle: **It matches you.** (`pa.rewrite.matched`). Chamber hint surfaces: *The orange walls are a mirror of where you walked.* |
| 3:08–3:22 | Player reads the parallel orange scribble, paths to `G` through authored geometry. |
| 3:22–3:30 | Clear. Stars settle. Queue hunger high. This is the clip / trailer kinship beat. |

**Chamber job:** first authorship ceremony. If this fails, the demo fails.

### 3:30–4:40 · Break the Loop — walk cleaner

| t | Event |
|---|---|
| 3:30–3:38 | Caption: *A loop prints a dense mirror. Walk cleaner.* |
| 3:38–4:05 | Player may thrash a loop → dense mirror → softlock feel. |
| 4:05–4:12 | First echo-wall bump arms **undo teach** once (`pa.undo.hint` / Z). Never spam. |
| 4:12–4:30 | Cleaner re-walk, single `mirror_v` commit, exit. |
| 4:30–4:40 | Won screen. Lesson internalized: *habits print density*. |

### 4:40–5:35 · Ceiling First — horizontal birth

| t | Event |
|---|---|
| 4:40–4:48 | Caption teaches axis flip without menu text. |
| 4:48–5:15 | Path along floor; telegraph shows roof imprint. |
| 5:15–5:18 | `mirror_h` slam — distinct earprint from vertical. |
| 5:18–5:35 | Read ceiling dashes → goal → Next. |

**Chamber job:** second operator identity. Axes are not cosmetics.

### 5:35–6:40 · Two Glances — dual commit

| t | Event |
|---|---|
| 5:35–5:45 | Caption: *Two checkpoints, two rewrites. Vary your route.* Cap ≥ 2. |
| 5:45–6:05 | First `C` — short mirror of approach path. |
| 6:05–6:25 | Second segment only feeds second rewrite (hint: *The second mirror uses only the path after the first.*). |
| 6:25–6:40 | Clear. Player owns **buffer windows**, not one global scribble. |

### 6:40–7:30 · Far Side — rotate 180

| t | Event |
|---|---|
| 6:40–6:50 | Caption: *Rotation. Your path prints on the opposite corner.* |
| 6:50–7:15 | Commit `rotate_180`; diagonal opposite fossils; new earprint. |
| 7:15–7:30 | Navigate inverse geography → clear. |

### 7:30–8:25 · First Thicken — habits underfoot

| t | Event |
|---|---|
| 7:30–7:40 | Caption: *Habits solidify where you stepped. Do not re-tread.* Fantasy shift from mirror to cement. |
| 7:40–8:05 | `thicken` slam — trail becomes wall in place. Distinct stinger + denser rust read. |
| 8:05–8:25 | Path around solidified self → goal. Sets Act III pressure fantasy without naming it. |

### 8:25–9:45 · Who Walked — Induction identity boss

| t | Event |
|---|---|
| 8:25–8:40 | Boss framing: *Leave a signature the lattice can read.* Slightly longer seed-header settle. Music may lift one layer (still Induction-safe). |
| 8:40–9:10 | First mirror commit — establish a readable half. |
| 9:10–9:35 | Second path answers the first (hint coaching). Intended solve leaves a legible portrait, not thrash. |
| 9:35–9:45 | Clear. Identity stamp / star beat. **Finish Demo** affordance (not “Act II”). |

### 9:45–10:00 · End breath & wishlist

| t | Event |
|---|---|
| 9:45–9:50 | End title: `DEMO COMPLETE`. Tagline: *You met Mirror Birth. The full lattice waits.* |
| 9:50–9:56 | Focus **Wishlist on Steam** iff CTA gated on; else quiet quit/restart. No Reflection/Pressure/Mastery names. |
| 9:56–10:00 | Idle hold on ledger. Desire > dump. Session ends or returns to DEMO INDEX. |

---

## 5. Chamber-by-chamber beats (author checklist)

Each row is the **one job**, the **ceremony**, and the **failure mode** to design against.

### 00 — Quiet Span
- **Teach:** move + green seal.
- **Ceremony:** none — silence *is* the juice.
- **Fail if:** first-frame tip cards, music bed, or checkpoint appears.
- **Copy:** caption *Walk the span.* / hint *Four directions. Reach the green seal.*

### 01 — Echo Plate
- **Teach:** plates arm buffer; `cap: 0` forbids fossils.
- **Ceremony:** PA attention on arm only.
- **Fail if:** any orange wall prints, or player skips plate without noticing.
- **Copy:** *Step the plate. Still asleep.* / *The plate arms your buffer. No walls yet.*

### 02 — Mirror Birth
- **Teach:** `mirror_v` authorship.
- **Ceremony:** full slam + **It matches you.** + hint surface. Trailer kinship.
- **Fail if:** slam unreadably fast, no post-hold, or path >3:30 cold.
- **Copy:** *Cross the checkpoint. Your path becomes wall.* / *The orange walls are a mirror of where you walked.*

### 03 — Break the Loop
- **Teach:** thrash density; undo as skill.
- **Ceremony:** first undo teach, once.
- **Fail if:** undo nag loops or remix is harder than boss.
- **Copy:** *A loop prints a dense mirror. Walk cleaner.*

### 04 — Ceiling First
- **Teach:** `mirror_h` as new operator.
- **Ceremony:** horizontal earprint + roof telegraph.
- **Fail if:** feels like reskin of Mirror Birth.
- **Copy:** *The mirror is horizontal — dashes imprint the roof.*

### 05 — Two Glances
- **Teach:** dual checkpoints = dual buffers.
- **Ceremony:** two smaller slams > one big.
- **Fail if:** second rewrite consumes pre-first path.
- **Copy:** *Two checkpoints, two rewrites. Vary your route.*

### 06 — Far Side
- **Teach:** `rotate_180`.
- **Ceremony:** opposite-corner reveal.
- **Fail if:** safety-net deletes the readable rotate so the lesson vanishes.
- **Copy:** *Rotation. Your path prints on the opposite corner.*

### 07 — First Thicken
- **Teach:** `thicken` / do not re-tread.
- **Ceremony:** cement fantasy; rust denser, less “origami mirror,” more “habit sets.”
- **Fail if:** identical slam VFX to mirrors (operator identity dies).
- **Copy:** *Habits solidify where you stepped. Do not re-tread.*

### 08 — Who Walked
- **Teach:** identity — intentional mirrored answer.
- **Ceremony:** boss settle + signature-readable clear (ledger stamp when U3 ships).
- **Fail if:** clear UX identical to remix with no portrait moment.
- **Copy:** *Boss. Leave a signature the lattice can read.*

---

## 6. Audio / juice / PA map (first 10)

| Window | Music | SFX / slam | PA / subtitle |
|---|---|---|---|
| Menu → Quiet Span | Near silence | UI only | — |
| Quiet Span | SilenceDirector hard cap | Footsteps | — |
| Echo Plate | Cap holds | Plate arm tick | Optional attention tone |
| Mirror Birth | Duck on slam | Full `mirror_v` stinger + origami | **It matches you.** |
| Break the Loop | Soft lift OK | `mirror_v` | Undo hint once |
| Ceiling First | — | `mirror_h` earprint | — |
| Two Glances | — | Two stingers | — |
| Far Side | — | `rotate_180` earprint | — |
| First Thicken | Habit layer +1 allowed | `thicken` earprint | — |
| Who Walked | Boss lift (still Induction) | Dual `mirror_v` | Identity settle |
| End | Resolve → hush | Fanfare → silence tail | Wishlist focus (gated) |

Shake default **off**. Cadmium only at slam warn/heartbeat. No screen-flash spam on footstep.

---

## 7. Influencer / capture path (same 10 minutes)

For clip scripts and trailer kinship, the **recordable spine** is:

1. **0:40** — Quiet Span footsteps only (ASMR / brand).  
2. **2:50–3:10** — Mirror Birth slam + “It matches you.” (hero clip).  
3. **5:15** — Ceiling First roof imprint (axis twist).  
4. **7:50** — First Thicken cement (fantasy shift).  
5. **9:35–10:00** — Who Walked clear → DEMO COMPLETE → wishlist.

Do not open Daily or late chambers on stream overlays during Next Fest cold path.

---

## 8. Acceptance (vision gate)

Cold player / QA against this doc:

- [ ] Fresh demo boot → Mirror Birth authorship by **≤ 3:30** without a text wall
- [ ] Echo Plate arms buffer with **zero** fossils
- [ ] Post-slam hold + **It matches you.** + Mirror Birth hint visible
- [ ] Undo teach arms on first self-wall in Break the Loop (or earlier bump), once
- [ ] Each Act I transform (`mirror_v`, `mirror_h`, `rotate_180`, `thicken`) has a distinct earprint in the 10-minute path
- [ ] Who Walked is reachable inside the 10-minute premium path for a guided player
- [ ] End screen copy matches `DEMO_SPEC.md`; wishlist only when gated
- [ ] No Reflection / Pressure / Mastery names, hard variants, or Act II chambers in the path
- [ ] `python3 game/echo_lattice/tests/test_onboarding_path.py` and `test_demo_spec.py` green

---

## 9. Change log

| Date | Change |
|---|---|
| 2026-08-09 | Initial vision: second-resolution first 10 minutes, premium demo path, Act I chamber-by-chamber beats. |
