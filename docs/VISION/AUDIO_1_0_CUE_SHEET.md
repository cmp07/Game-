# Echo Lattice — AUDIO 1.0 Cue Sheet

**Companion to:** [`AUDIO_V3.md`](AUDIO_V3.md)  
**Catalog IDs:** [`game/echo_lattice/audio/events/audio_events.json`](../../game/echo_lattice/audio/events/audio_events.json)  
**Purpose:** Production checklist for the authored 1.0 mix — replace every procedural placeholder with Field Ledger material.  
**Status:** Cue lock · assets not yet authored

---

## How to read this sheet

| Column | Meaning |
|---|---|
| **Cue ID** | Stable production id (maps to catalog `event` when applicable) |
| **Event / stem** | Runtime id or file family |
| **Trigger** | When it fires |
| **Duration** | Target length (composer guidance) |
| **Musical brief** | What it must *do* under AUDIO v3 pillars |
| **Bus** | Godot bus |
| **Pri** | P0 trailer/demo · P1 campaign 1.0 · P2 polish |

Acceptance for every P0/P1 row: laptop speakers + earbuds + one headset; Music-mute still teaches telegraph/slam; no VO.

---

## A. Shared grammar — rewrite slam phrase

These are the **musical event** stages. Prefer delivering A1–A5 as one streamed phrase per operator (B-series endings baked in), or as phase-synced layers. Listener must hear one sentence.

| Cue ID | Event / stem | Trigger | Duration | Musical brief | Bus | Pri |
|---|---|---|---|---|---|---|
| **A0** | `sfx.rewrite_warn` | Unused checkpoint ≤3 Manhattan | 180–320 ms | Rising chalk scrape / dry tension — **not** a beep ladder; duck Music ≤ −2 dB | SFX | P0 |
| **A1** | slam.heartbeat | Slam t≈0.00 | 40–70 ms + **≥80 ms rest** | Single cadmium body hit; no sustain; rest is mandatory | SFX | P0 |
| **A2** | slam.crease | Slam t≈0.08–0.35 | ~270 ms | Staggered paper percussion; micro-gaps between creases | SFX | P0 |
| **A3** | slam.lift | Slam t≈0.35–0.55 | ~200 ms | Spectral / pitch lift; air without library whoosh; hush underneath | SFX | P0 |
| **A4** | slam.slot | Slam t≈0.55–0.70 | 80–120 ms | Downbeat low plate + tonic land; loudest point; Music duck ≈ −4 dB / 400 ms | SFX | P0 |
| **A5** | slam.bleed + op ending | Slam t≈0.70–0.90 | ~200 ms | Rust grit settles **into** operator consonant (B-series) | SFX | P0 |

**Sync note:** Visual `REWRITE_DURATION = 0.90s`. If reduce-motion shortens slam, drop whole stages — never time-stretch the phrase ugly.

**Trailer alias:** Beat sheet Act 1 (≈0:06–0:07.5) must use A1–A5 masters, not a separate marketing riser.

---

## B. Operator endings (earprints)

Shared A1–A3; unique A4–A5 consonants. Catalog events already exist.

| Cue ID | Event | Operator | Ending consonant | Pri |
|---|---|---|---|---|
| **B1** | `sfx.rewrite.fossilize_hot_cell` | `fossilize_hot_cell` | Descending lock → cold plate | P1 |
| **B2** | `sfx.rewrite.place_deflector` | `place_deflector` | Lateral shove (M2 sideways) + metallic edge | P1 |
| **B3** | `sfx.rewrite.carve_shortcut` | `carve_shortcut` | Air gate → bright click; shortest bleed | P1 |
| **B4** | `sfx.rewrite.grow_wall_far_from_path` | `grow_wall_far_from_path` | Stacked rising fifths (accretion) | P1 |
| **B5** | `sfx.rewrite.widen_hot_corridor` | `widen_hot_corridor` | Detuned open fifth bloom | P1 |
| **B6** | `sfx.rewrite.mirror` | `mirror` (+ `mirror_v` / `mirror_h` / `mirror_v_then_h`) | Motif then **exact reverse** | **P0** (Mirror Birth / trailer) |
| **B7** | `sfx.rewrite.rotate` | `rotate` (+ `rotate_180`) | Pivot around center tone | P1 |
| **B8** | `sfx.rewrite.thicken` | `thicken` | Low stack grows harmonics | P1 |
| **B9** | `sfx.rewrite.invert` | `invert` | High tick → submerged inverse | P2 (content unlock) |
| **B0** | `sfx.rewrite` | unknown / fallback | Neutral slot+bleed without strong consonant | P1 |

---

## C. Habit motif stems (Ledger Cell)

One cell, four transformations. Intensity gates unchanged from v2.

| Cue ID | Event / file | Gate | Motif job | Duration | Bus | Pri |
|---|---|---|---|---|---|---|
| **C0** | `music.layer.L0` / `L0_bed.ogg` | silence cap > 0 | Pedal / HVAC hum — root of Ledger Cell only | Loop | Music | P0 |
| **C1** | `music.layer.L1` / `L1_lattice.ogg` | ≥ 0.25 | Cell as sparse LED ticks with rests | Loop | Music | P0 |
| **C2** | `music.layer.L2` / `L2_habit.ogg` | ≥ 0.55 | Full cell; ♭2 / dissonant fifth heat | Loop | Music | P1 |
| **C3** | `music.layer.L3` / `L3_rewrite.ogg` | ≥ 0.80 or pulse | Compressed / answering cell; slam rhyme | Loop | Music | P1 |
| **C4** | `AdaptiveMusic.pulse_rewrite` answer | On rewrite | 0.5–0.7 s L3 motif answer — not volume-only spike | — | Music | P1 |

**Ledger Cell contour (normative):** scale degrees `1 → 5 → ♭2 → 1'` (see AUDIO_V3 §4). Composer may retune absolute pitch; contour and hunger-on-1' stay.

**Silence caps still apply:** chamber 0 = no C0–C3 audible.

---

## D. Locomotion & telegraph body

| Cue ID | Event | Trigger | Duration | Musical brief | Bus | Pri |
|---|---|---|---|---|---|---|
| **D1** | `sfx.footstep` | Successful grid step | 40–80 ms | Dry paper/ledger click; ±4% jitter; habit pitch lerp | SFX | P0 |
| **D2** | `sfx.footstep_blocked` | Walk into wall | 60–100 ms | Lower, duller ink thud | SFX | P1 |
| **D3** | footstep overtone layer | `habit_tension ≥ 0.7` for 2+ steps | with D1 | +7 st, −18 dB metallic chalk edge | SFX | P2 |

---

## E. Diegetic PA (no VO)

| Cue ID | Event | Trigger | Duration | Musical brief | Bus | Pri |
|---|---|---|---|---|---|---|
| **E1** | `pa.attention` | Boot / rewrite fired / death | 400–700 ms | Institutional two-tone; duck Music −2 dB; **200–400 ms hush after** | PA | P0 |
| **E2** | `pa.board_tick` | Board / matched / ghost literacy | 40–80 ms | LED board tick — dry | PA | P1 |
| **E3** | `pa.rewrite_armed` | Checkpoint armed | 500–900 ms | Armed chime; duck −2 dB / ~900 ms; hush after | PA | P0 |
| **E4** | `pa.wing_clear` | Wing filed | 800–1200 ms | Filing stamp / clear tone; duck −3 dB | PA | P1 |

Copy stays on-screen. Audio = institution only.

---

## F. Win / open-loop addiction

| Cue ID | Event | Trigger | Duration | Musical brief | Bus | Pri |
|---|---|---|---|---|---|---|
| **F1** | `win.chamber` | Chamber clear | 400–700 ms | Resolve via Ledger Cell 1→5; satisfaction without brass | SFX | P0 |
| **F2** | `win.queue_next` | follow_up ~80 ms after F1 | 300–500 ms **cut early** | Rising fourth → sharp leading tone; **hunger**, not cadence close | SFX | P0 |
| **F3** | `win.fanfare` | Compat / single-file path | F1+F2 concat | Same open loop as one file | SFX | P2 |
| **F4** | `win.wing` | Wing clear | 1.0–1.6 s | Longer dry stamp; still Field Ledger | SFX | P1 |

---

## G. UI & shell

| Cue ID | Event | Trigger | Duration | Musical brief | Bus | Pri |
|---|---|---|---|---|---|---|
| **G1** | `ui.click` | Confirm IndexAction (not boot) | 45–90 ms | Soft ledger stamp stinger; silence tail; never vs rewrite/PA | UI | P1 |
| **G1b** | `ui.select` | Focus move / selection | 25–45 ms | Paper/ink tick; gaps between nav (AUDIO_V3 silence tool) | UI | P1 |
| **G1c** | `ui.hover` | Mouse hover (unfocused) | 15–30 ms | Extremely soft fiber brush; omit if noisy | UI | P2 |
| **G2** | pause duck | Pause menu | — | Music −8 dB; SFX/PA unchanged | Music | P1 |
| **G3** | title bed | Main menu | Loop or silence | L0 whisper **or** authored silence — no trailer swell | Music | P1 |

---

## H. Trailer / store cue strip (Gate A announce)

Maps to [`../RELEASE/trailer/BEAT_SHEET.md`](../RELEASE/trailer/BEAT_SHEET.md). Use in-game masters.

| t | Picture beat | Audio cues | Silence tool |
|---|---|---|---|
| 0:00–0:05 | Clean corridor → habit trail | D1 soft; **no music swell** | Policy silence under |
| 0:05–0:06 | Approach checkpoint | A0 warn; hush | Cadmium-adjacent air |
| 0:06–0:07.5 | Heartbeat → crease → lift → slot → bleed | **A1–A5 + B6 (mirror)** | Post-heartbeat rest; post-hit silence tail |
| 0:07.5–0:12 | `IT LEARNED YOU` hold | — | **Silence tail** after slot |
| 0:12–0:25 | Prove depth | Sparse C1 fragments / E hush | No bed wall |
| 0:25–0:30 | Brand / wishlist | Soft logo hit optional | **0.4–0.6 s silence tail** |

P0 gate: first rewrite + queue-next must not sound like DSP beeps in any public encode.

---

## I. Delivery package (per cue family)

For each authored asset set, deliver:

1. **Master** `.wav` 48 kHz / 24-bit (archive) + game `.ogg` (vorbis).  
2. Peak / LUFS consistent with AUDIO bible mix table.  
3. Filename matching catalog `stream` paths (drop `_placeholder` suffix).  
4. Note of slam-stage markers if delivering split layers.  
5. Mute-Music and Chamber-0 check signed off.

Regenerate / validate:

```bash
# After replacing files — do not re-run placeholder generator over finals
python3 tools/audio/validate_audio_events.py
```

---

## J. Priority burn-down

### P0 — Before Coming Soon / announce trailer

- [ ] A0–A5 slam grammar  
- [ ] B6 mirror phrase (Mirror Birth)  
- [ ] C0–C1 stems (enough for Identity under silence caps)  
- [ ] D1 footsteps  
- [ ] E1 + E3 PA  
- [ ] F1 + F2 win open loop  
- [ ] Trailer strip H using the same masters  

### P1 — Campaign 1.0 mix complete

- [ ] B1–B5, B7–B8, B0 fallback  
- [ ] C2–C3 + C4 pulse answer  
- [ ] D2, E2, E4, F4, G1–G3  
- [ ] Full silence-cap playtest Wing I–II  

### P2 — Polish

- [ ] B9 invert  
- [ ] D3 overtone layer  
- [ ] F3 fanfare concat convenience  
- [ ] Bias-colored habit cell tilts (AUDIO_V3 §4.3 optional)  

---

## K. Sign-off

| Gate | Owner | Pass criteria |
|---|---|---|
| Identity listen | Audio + Design | Stranger describes “paper maze that learned me” from audio-only 30s clip |
| Slam phrase | Audio + Art | Five stages clap-able; matches origami staging |
| Motif | Audio | L0–L3 audible as one cell transforming |
| Silence | Design + Audio | Chamber 0 black; rests inside slam/PA/win intentional |
| Compliance | Release | No public asset marketed as final while placeholders remain |

**Vision authority:** [`AUDIO_V3.md`](AUDIO_V3.md)  
**Wiring authority:** [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md)
