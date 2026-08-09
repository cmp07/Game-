# Echo Lattice — AUDIO v3 (Vision)

**Doc:** `docs/VISION/AUDIO_V3.md`  
**Product:** Echo Lattice (Game 1) · Field Ledger  
**Status:** Vision lock for 1.0 authored mix — **not** implementation yet  
**Supersedes (identity layer):** procedural / DSP placeholder earprint of AUDIO v2  
**Keeps (architecture):** buses, `AudioDirector`, event catalog, silence caps, PA bus — see [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md)  
**1.0 cue sheet:** [`AUDIO_1_0_CUE_SHEET.md`](AUDIO_1_0_CUE_SHEET.md)

---

## 0. Why AUDIO v3 exists

AUDIO v2 shipped the **plumbing**: Master / SFX / Music / UI / PA, habit-intensity stems, per-operator event IDs, SilenceDirector, win open-loop. Every stream under `game/echo_lattice/audio/**` is still a **procedural beep / tone** from `tools/audio/generate_echo_lattice_placeholders.py`.

That architecture is load-bearing. The *earprint* is not.

AUDIO v3 is the **identity rewrite**: stop sounding like a synth test harness; start sounding like a **printed document that learned you**. Visual already says ink / paper / rust / origami. Audio must say the same sentence without words.

| Layer | Owner | Ship gate |
|---|---|---|
| Architecture + event IDs | AUDIO v2 bible + `audio_events.json` | Wired on RC1 |
| Sonic identity + 1.0 cue sheet | **This doc + cue sheet** | Authored mix before Coming Soon trailer / final store audio |
| Placeholders in marketing | Forbidden | [`COMPLIANCE_FINAL`](../RELEASE/COMPLIANCE_FINAL.md) — never call DSP beeps “final mix” |

**One-line brief:** *A brutalist transit ledger that scores your habits — paper percussion, rust intervals, institutional hush. No fantasy orchestra. No cute UI chirps. Silence is an instrument.*

---

## 1. Three pillars (non-negotiable)

Any cue that fails two pillars goes back. These replace “more SFX polish” as the acceptance language.

### P1 · Rewrite slam is a musical event

The origami slam (`Chamber` ~0.90s: heartbeat → crease → lift → slot → rust bleed) is **not** a one-shot SFX with a Music duck. It is a **scored phrase** — five beats with pitch, rhythm, and silence between them — that resolves into the operator’s earprint.

Players should be able to clap the slam phrase after three hearings. Trailer cut and in-game must share the same phrase.

### P2 · Habit is a motif, not a volume fader

Habit solidify must not only *get louder*. It must **state a motif**, then **vary** it (register, density, interval quality) as the player fossilizes a bias. L0–L3 remain stems; each stem is now a **transformation of one habit cell**, not four unrelated beds.

### P3 · Silence is a tool

Silence is not “music not ready yet.” It is composition: negative space that teaches locomotion, telegraph, and the first rewrite. Cap tables from v2 stay; v3 adds **authored rests inside loud events** (slam air gaps, queue-next cut, post-PA hush) so the mix never fills every millisecond.

---

## 2. Sonic world (Field Ledger ear)

### 2.1 Material dictionary

Map art bible materials → sound materials. Prefer recorded / designed hybrids over pure oscillators.

| Visual material | Sonic material | Ban |
|---|---|---|
| Paper bone / ledger page | Dry paper crease, page turn, soft fiber brush | Wet reverb halls, cinematic whoosh libraries |
| Ink stroke | Short stick-on-wood tick, pencil tip | Laser blips, 8-bit coin |
| Chalk ghost | Soft chalk scrape, dust hiss (very low) | White-noise sweeps as “magic” |
| Rust fossil | Oxidized metal scrape, grit, low plate | Shimmer pads, angelic choirs |
| Cadmium heartbeat | Single dry thud + micro silence after | Alarm sirens, UI error buzzers |
| Transit PA | Institutional two-tone / board chime (no VO) | Robot voice, quips, speech synthesis |
| HVAC bed (L0) | Transformer hum, duct air — felt more than heard | Trailer epic drone under Induction |

### 2.2 Pitch & tuning

| Rule | Spec |
|---|---|
| Home interval | Perfect fifth + minor second clash = “habit locking” (L2 character) |
| Lattice grid | Think in **semitone steps on a muted piano / prepared plate**, not lush chords |
| Operator family | Each operator owns a **gesture** (see §4), not a random timbre |
| Slam tonic | Chamber keeps a soft tonic from L0; slam phrase lands **into** that tonic on slot |
| No vocals | Ever — meaning stays on-screen (tone bible) |

### 2.3 Tempo feel (not a metronome HUD)

| Context | Feel |
|---|---|
| Footsteps | Player-driven; dry; slight habit pitch rise only (v2 law) |
| Slam phrase | Fixed **~0.90s** musical bar aligned to visual staging |
| Habit bed | Slow institutional pulse ≈ 60–72 BPM felt, not clicked |
| Queue-next | Rising fourth that **cuts before resolution** (addiction open loop) |

---

## 3. Pillar deep-dive — Slam as musical event

### 3.1 Phrase map (aligned to visual staging)

`REWRITE_DURATION = 0.90s`. Audio owns the same five stages. **Do not** fire a single `sfx.rewrite` blob and call it done.

| Stage | t (approx) | Visual | Musical job | Silence job |
|---|---|---|---|---|
| **0 Warn** (pre) | ≤3 steps to unused checkpoint | Cadmium ticks / margin arming | Shared warn cell — rising chalk scrape, not a beep ladder | Leave Music almost untouched (−2 dB duck max) |
| **1 Heartbeat** | 0.00–0.08 | Cadmium margin flash only | One dry hit (cadmium body). No sustain. | **≥80 ms rest after** — the ear must notice the blank |
| **2 Crease** | 0.08–0.35 | Folding tiles, diagonal ink | Paper percussion cascade, staggered like cells | Micro-gaps between creases (not a noise wall) |
| **3 Lift** | 0.35–0.55 | Cast shadow, paper rise | Pitch / spectral lift — air without whoosh library | Hold one breath of hush under the lift |
| **4 Slot** | 0.55–0.70 | Fossil lands + 1 px overshoot | **Downbeat** — low plate + tonic confirmation | No layering under the hit; Music ducks hard ~400 ms |
| **5 Bleed** | 0.70–0.90 | Rust joins fade in | Operator motif fragment settles into rust grit | Tail dies into room tone or true silence (early chambers) |

### 3.2 Operator earprint lives in stages 4–5

Stages 1–3 are **shared grammar** (everyone hears the same origami sentence). Stages 4–5 carry the **operator consonant** — the unique earprint from v2’s table, rewritten as motif endings:

| Operator | Ending consonant (musical) |
|---|---|
| `fossilize_hot_cell` | Descending lock into cold plate |
| `place_deflector` | Lateral shove interval (major 2nd sideways) |
| `carve_shortcut` | Air gate → bright click (shortest bleed) |
| `grow_wall_far_from_path` | Stacked rising fifths (accretion arpeggio) |
| `widen_hot_corridor` | Detuned open fifth bloom |
| `mirror` | Motif then **exact reverse** (literal) |
| `rotate` | Pivot around a center tone |
| `thicken` | Low stack grows harmonics |
| `invert` | High tick → submerged inverse |

Campaign aliases (`mirror_v` → `mirror`, etc.) stay in `audio_events.json`.

### 3.3 Implementation sketch (when authored)

Prefer **one streamed phrase per operator** (`rewrite/<op>_phrase.ogg` ~900 ms) **or** staged oneshots fired by slam phase callbacks — but the **listener experience must be one phrase**. Generic `sfx.rewrite` remains fallback only.

`AdaptiveMusic.pulse_rewrite()` becomes a **motif answer** on L3 (see §4), not a volume spike alone.

### 3.4 Acceptance — slam

- [ ] Headphones: stranger can tap the five-stage rhythm after one Mirror Birth clear.
- [ ] Mute Music: phrase still complete and operator-distinct.
- [ ] Chamber 0 / early silence caps: phrase never pulls in a music swell under it.
- [ ] Trailer 30s cut uses the **same** phrase stems as in-game (no separate “trailer synth”).
- [ ] Reduce-motion / shortened slam: phrase truncates at stage boundaries — never a sped-up chipmunk.

---

## 4. Pillar deep-dive — Habit as motif

### 4.1 The habit cell

One 2–4 note **habit cell** is the game’s leitmotif. Working name: **Ledger Cell**.

Suggested contour (composer may retune; contour is normative):

```
scale degree:  1  →  5  →  ♭2  →  1'
register:      mid    mid+   tense    resolve-ish (never fully)
```

- **1→5:** institutional calm (transit / HVAC honesty).  
- **♭2:** the grit — habit wrongness / addiction heat.  
- **1':** almost home; leaves hunger (same psychology as queue-next).

### 4.2 Stem roles = motif transformations

| Stem | Intensity gate (v2) | Motif job |
|---|---|---|
| **L0 Bed** | always when silence cap > 0 | Pedal / hum under the cell — often **partial** (root only) |
| **L1 Lattice** | ≥ 0.25 | Cell as sparse ticks — LED board rhythm, notes separated by rests |
| **L2 Habit** | ≥ 0.55 | Cell with ♭2 emphasized; dissonant fifths; density up |
| **L3 Rewrite** | ≥ 0.80 or pulse | Cell compressed / inverted / answered at slam — commit heat |

Crossfades stay 200–400 ms. Prefer continuous stems; **orchestration changes**, not playlist jumps.

### 4.3 Habit solidify still drives intensity

Keep the v2 metrics (`dominant_bias`, `repetition`, `fossil_density`, `rewrite_count_norm`, `rewrite_tension`). AUDIO v3 adds:

| Solidify band | Motif behavior |
|---|---|
| 0.00–0.25 | Cell almost absent; L0 air only (or silence) |
| 0.25–0.55 | L1 states cell in fragments |
| 0.55–0.80 | L2 completes cell; ♭2 becomes noticeable |
| 0.80–1.00 | L3 answers cell; slam phrase rhymes with it |

**Bias color (1.0 stretch, optional):** dominant walk bias may tilt cell mode (e.g. more rising = thicken-ish; lateral = deflector-ish) — never a second unrelated theme.

### 4.4 What habit must never become

- Four loopable “zones” that ignore player metrics.  
- Always-on trailer music in Wing 0 Quiet Span.  
- Melodic earworms that drown footsteps / telegraph.  
- Randomized generative MIDI that breaks deterministic demo captures.

---

## 5. Pillar deep-dive — Silence as tool

### 5.1 Policy silence (chamber caps) — kept from v2

| Chamber index | Max `music_intensity` | Intent |
|---|---|---|
| `0` Quiet Span | **0.0** | Designed silence — locomotion + first identity |
| `1` Echo Plate | 0.10 | Barely-there air |
| `2` Mirror Birth | 0.25 | L0+L1 may breathe under first rewrite phrase |
| `3` Break the Loop | 0.45 | Habit heat begins |
| `4+` | 1.0 | Full adaptive stack |

Silence never mutes SFX or PA. Returning players still honor caps.

### 5.2 Authored rests (new in v3)

| Rest | Duration | Where |
|---|---|---|
| Post-heartbeat air | ≥80 ms | Inside every slam phrase |
| Post-slot breath | 40–80 ms | Before bleed grit |
| Post-PA hush | 200–400 ms | After `pa.attention` / `pa.rewrite_armed` |
| Queue-next cut | Phrase ends early on leading tone | Win open loop |
| Title / wishlist trailer tail | 0.4–0.6 s | Beat sheet Act 3 |
| After first Mirror Birth slam | Optional extra 0.3 s Music hold-down | Pedagogy — let fossils read |

### 5.3 Silence acceptance

- [ ] Chamber 0: Music bus digitally black; footsteps readable; no accidental L0 bleed.  
- [ ] First rewrite: silence *around* the phrase makes the phrase feel bigger than louder mixes.  
- [ ] Streamer Music-mute: telegraph + slam + PA still teach the loop.  
- [ ] No “silence fear” filler — if the design is quiet, stay quiet.

---

## 6. Supporting systems (v2 retained, v3 voiced)

### 6.1 Footsteps

Dry paper/ledger clicks. Pitch jitter ±4%. Habit pitch lerp `1.0 → 1.18`. At high tension, thin metallic overtone (+7 st, −18 dB) — chalk-on-ink, not arcade coin.

### 6.2 Diegetic PA

Brutalist transit authority. No speech. Events: `pa.attention`, `pa.board_tick`, `pa.rewrite_armed`, `pa.wing_clear`. On-screen text carries meaning; PA carries institution. Duck Music −2 to −3 dB; leave authored hush after.

### 6.3 Win / addiction open loop

| Event | Musical job |
|---|---|
| `win.chamber` | Short major-ish resolve using Ledger Cell’s 1→5 |
| `win.queue_next` | Rising fourth → sharp leading tone **cut early** |
| `win.wing` | Longer filing stamp — still dry, not brass fanfare |

### 6.4 UI

Soft ledger ticks. Never compete with rewrite/PA. No menu boot chirp as branding.

### 6.5 Buses & mix targets

Unchanged from v2 bible §2 / §10. Master ≈ −14 LUFS gameplay. Operator/slam phrase = loudest one-shots. Early silence = digital black on Music.

---

## 7. Relationship to other docs

| Doc | Relationship |
|---|---|
| [`06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md) | Implementation authority for buses, APIs, catalog IDs |
| [`AUDIO_1_0_CUE_SHEET.md`](AUDIO_1_0_CUE_SHEET.md) | Production cue list + acceptance for authored 1.0 assets |
| [`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) | Material + slam staging — audio must rhyme |
| [`14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) | Code-timed slam phases |
| [`../RELEASE/trailer/BEAT_SHEET.md`](../RELEASE/trailer/BEAT_SHEET.md) | Trailer audio column must use v3 phrases |
| [`../AUDIT/AUDIO_ART_UX.md`](../AUDIT/AUDIO_ART_UX.md) | Placeholder inventory — v3 is the remediation vision |

When vision and bible conflict on *identity*, **AUDIO v3 wins**. When they conflict on *wiring*, **AUDIO v2 bible + JSON win** until an implementation PR updates them together.

---

## 8. Production order (docs → assets → wire)

1. Lock this vision + cue sheet (this PR).  
2. Author Ledger Cell + slam shared grammar + nine operator endings.  
3. Author L0–L3 stems as motif transforms.  
4. Replace placeholders; keep event IDs stable.  
5. Validate with `tools/audio/validate_audio_events.py`.  
6. Trailer pass: warn → heartbeat → phrase → silence tail → queue-next.  
7. Update AUDIO bible checklist: “authored one-shots / stems” checked only after real assets land.

---

## 9. Ban list (audio-direction enforceable)

- Procedural sine / square “placeholder” character in any public trailer or store loop.  
- Fantasy orchestra stingers, choir, trailer percussion beds under Induction.  
- VO / speech synthesis / robot quips.  
- Purple-void synth pads, shimmer risers, generic UI sparkle packs.  
- Filling silence with bed noise because “it feels empty.”  
- Separate “marketing mix” that contradicts in-game earprints.

---

## 10. Changelog

| Ver | Notes |
|---|---|
| **v1** | Buses, generic placeholders |
| **v2** | Habit-solidify layers, operator stingers, PA, silence policy, structured events |
| **v3** | Identity lock — slam as musical event, habit as motif (Ledger Cell), silence as tool; 1.0 cue sheet |
| **v3.1** | Procedural lift in-repo: generator v3 multi-stage slam phrases, Ledger Cell stems, quieter rests, win/fail stingers, catalog v3 + `fail.reset`; authored asset debt tracked in [`../AUDIT/PRODUCTION_AUDIO_DEBT.md`](../AUDIT/PRODUCTION_AUDIO_DEBT.md) |
