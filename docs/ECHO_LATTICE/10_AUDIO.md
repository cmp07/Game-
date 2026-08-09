# Echo Lattice — 10 · Audio Craft (Weaver)

**Status:** craft authority (CLOUD ONLY) · **Branch:** `cursor/weaver-craft`  
**Product:** Echo Lattice · Field Ledger  
**Job:** Weave AUDIO bible + AUDIO v3 + cue sheet into a **mix craft bar** so the game sounds like paper, rust, and institutional hush — not a synth test harness or fantasy trailer pack.  
**Does not replace:** [`06_AUDIO_BIBLE.md`](06_AUDIO_BIBLE.md) (buses / events / silence caps) · [`../VISION/AUDIO_V3.md`](../VISION/AUDIO_V3.md) (identity) · [`../VISION/AUDIO_1_0_CUE_SHEET.md`](../VISION/AUDIO_1_0_CUE_SHEET.md) (cue lock)  
**Companions:** [`09_VISUAL.md`](09_VISUAL.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) · [`07_JUICE.md`](07_JUICE.md) · catalog [`../../game/echo_lattice/audio/events/audio_events.json`](../../game/echo_lattice/audio/events/audio_events.json)

**Naming note:** An older unmerged draft used `10_PERFORMANCE.md` for frame budgets. Performance authority lives in [`../AUDIT/PERFORMANCE.md`](../AUDIT/PERFORMANCE.md). **This** `10_AUDIO.md` is the audio craft weaver for the Field Ledger trilogy (09 visual · 10 audio · 11 progression).

---

## 0. Thesis

Audio is a **readability channel** and the habit-addiction instrument. If the maze looks like a ledger but sounds like cosmic pads and UI chirps, players will not believe “it learned you.”

**One-line brief:** _A brutalist transit ledger that scores your habits — paper percussion, rust intervals, institutional hush. Silence is an instrument._

**Weaver rule:** visual slam stages and audio slam phrase are **one sentence**. Progression never celebrates clears with brass fanfare that breaks Field Ledger tone.

---

## 1. Hard ban — AI / trailer-slop ear

| Banned | Replace with |
|---|---|
| Epic orchestra risers, choir swells, “adventure” brass | Dry paper / plate / institutional bed |
| Cute UI blips, coin jingles, slot-machine confirm | Underlined-type ticks; soft fiber brush |
| Horror stingers, jumpscare risers, sirens | Cadmium dry thud + rest; PA two-tone |
| Fantasy magic whoosh / shimmer pads | Origami crease cascade + rust grit |
| Speech / VO / robot quips | On-screen tone bible copy only |
| Filling every millisecond with bed | Authored rests (Induction silence policy) |
| Calling procedural placeholders “final mix” | Honest colophon + cue-sheet replacement ([`COMPLIANCE_FINAL`](../RELEASE/COMPLIANCE_FINAL.md)) |

**Anti-purple-void audio analogue:** no “mystic void drone” under menus. Title bed is lightbox HVAC / transformer hush or true silence — never cosmic pad.

---

## 2. Authority stack

```
06_AUDIO_BIBLE              → buses, event IDs, duck rules, silence caps (plumbing law)
audio_events.json           → runtime IDs (machine truth)
AUDIO_V3 + cue sheet        → authored earprint + production checklist
10_AUDIO (this doc)         → craft gates, weaver sync, acceptance listening
```

Architecture stays; placeholders under `game/echo_lattice/audio/**` are **not** identity until cue-sheet P0/P1 rows are authored.

---

## 3. Three craft pillars (pass/fail)

| Pillar | Pass | Fail |
|---|---|---|
| **P1 Slam is a musical event** | Player can clap the ~0.90s phrase after three hearings; five stages audible | Single blob SFX; no rests; desynced from visual |
| **P2 Habit is a motif** | L0–L3 transform one habit cell (register/density/interval) | Only volume fader; four unrelated loops |
| **P3 Silence is a tool** | Induction hush teaches walk; rests inside slam; Music-mute still teaches telegraph | Wall-to-wall bed; mute Music → lose rewrite tells |

---

## 4. Slam phrase craft (must match visual)

`REWRITE_DURATION = 0.90s`. Stages lock to [`09_VISUAL.md`](09_VISUAL.md) §5 and cue sheet A0–A5.

| Stage | t | Sonic job | Silence job |
|---|---|---|---|
| Warn (pre) | ≤3 steps | Rising chalk scrape — not beep ladder; Music duck ≤ −2 dB | Keep bed almost untouched |
| Heartbeat | 0.00–0.08 | One dry cadmium body hit | **≥80 ms rest after** |
| Crease | 0.08–0.35 | Staggered paper percussion | Micro-gaps between creases |
| Lift | 0.35–0.55 | Spectral lift without library whoosh | Hush under the lift |
| Slot | 0.55–0.70 | Low plate + tonic land; loudest point; Music duck ≈ −4 dB / ~400 ms | No clutter under the hit |
| Bleed | 0.70–0.90 | Operator consonant + rust grit | Tail into room tone or true silence |

**Operator earprints:** shared A1–A3; unique endings (mirror reverse, rotate pivot, thicken stack, etc.) per cue sheet B-series. Mirror Birth / trailer = P0.

**Reduce-motion:** drop whole stages; never ugly time-stretch.

---

## 5. Bus & mix craft

From AUDIO bible — craft reminders for implementers and reviewers:

| Bus | Role | Craft note |
|---|---|---|
| Master | Final | No FX on Master for MVP |
| SFX | Footsteps, slam, win | Dry; rewrite is the loudest honest moment |
| Music | L0–L3 habit stems | Default quiet (−6 dB); institutional pulse 60–72 BPM felt |
| UI | Menu / pause | Soft; **no** SFX before first intentional input on cold boot |
| PA | Transit tones, no VO | Never rides UI bus; ducks Music −2…−3 dB briefly |

Rules that fail craft if broken:

1. Every player sets `bus` explicitly.  
2. Mute Music must **not** mute SFX/PA (telegraph stays).  
3. Settings map 1:1 to bus volumes; persist `user://settings.cfg`.  
4. Fail / softlock cues are dry institutional — not cartoon “game over.”

---

## 6. Material dictionary (ear ↔ eye)

| Visual | Sonic | Ban |
|---|---|---|
| Paper bone | Dry crease, page turn, fiber brush | Wet halls, cinematic whoosh |
| Ink stroke | Stick-on-wood tick, pencil tip | Laser blip, 8-bit coin |
| Chalk ghost | Soft scrape, dust hiss (very low) | White-noise “magic” sweeps |
| Rust fossil | Oxidized scrape, grit, low plate | Shimmer pads, choirs |
| Cadmium warn | Single dry thud + micro silence | Alarm sirens |
| Transit PA | Two-tone / board chime | Robot voice, quips |
| L0 bed | Transformer hum, duct air | Trailer epic drone under Induction |

---

## 7. Mode & progression voice (weaver)

Audio must support [`11_PROGRESSION.md`](11_PROGRESSION.md) without becoming live-service fanfare.

| Beat | Audio craft |
|---|---|
| Chamber clear | Resolve chord/plate → **hungry open interval** (queue-next); addiction without brass parade |
| Echo Card / archetype name | Soft stamp + short rest; motif fragment optional — no VO reading the title |
| Daily appointment | Same grammar as campaign; optional date-tick on menu focus — institutional, not calendar jingle |
| Museum browse | Near-silence + paper turn; ghost race uses chalk/slate ghost bed, not competitive anthem |
| Streak / stars | Numeral stamp tick only; **never** slot-machine cascade |
| Hard+ | Slightly tighter bed (less air), not “epic remix” |

---

## 8. RC1 honesty checklist

| # | Check | Notes |
|---|---|---|
| A1 | Buses wired Master/SFX/Music/UI/PA | Bible §2 |
| A2 | Event catalog IDs stable | `audio_events.json` |
| A3 | SilenceDirector / Induction policy respected | Cap tables from bible |
| A4 | Placeholders labeled in colophon | Not marketed as final |
| A5 | Slam stages phase-sync capable | Even if still DSP stubs |
| A6 | Cold boot quiet until intentional input | Production craft B5 |
| A7 | Cue-sheet P0 authored before Coming Soon trailer audio | Vision gate |
| A8 | Laptop + earbuds + headset accept passes | Cue sheet acceptance |

---

## 9. Acceptance listening (12 minutes)

1. **Boot → title** — hush or institutional bed; no chirp spam.  
2. **Quiet Span** — footsteps dry; silence teaches.  
3. **Telegraph** — warn readable with Music muted.  
4. **Mirror Birth slam** — clap the phrase; rests audible; visual lock-step.  
5. **Clear → queue-next** — resolve then open hunger; want Continue.  
6. **Pause** — Music ducks; UI ticks are paper, not candy.  
7. **Fail/restart** — institutional, not cartoon.

Fail slam sync or Music-mute telegraph → audio craft not done.

---

## 10. Non-goals

- Licensed trailer libraries as identity.  
- Dynamic music that fights the rewrite phrase.  
- Voice acting, radio hosts, or meme stingers.  
- Code/audio asset authorship in this PR — **CLOUD ONLY**.
