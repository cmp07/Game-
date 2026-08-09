# Echo Lattice — Audio Bible (AUDIO v2)

**Doc:** `06_AUDIO_BIBLE`  
**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4.3+  
**Status:** AUDIO v2 — adaptive habit layers, operator stingers, diegetic PA, silence policy, structured events  
**Companion assets:** [`game/echo_lattice/audio/`](../../game/echo_lattice/audio/)  
**Tone companion:** [`12_TONE_AND_TUTORIAL.md`](12_TONE_AND_TUTORIAL.md) (PA copy; this doc owns PA *sound*)

---

## 1. Intent (addiction / emotion)

Audio is a **primary readability channel** and the game’s **habit-addiction instrument**. The lattice rebuilds from the player’s habits; sound must:

1. Telegraph rewrite *before* walls move (“it learned you” as skill, not RNG).
2. **Intensify as habit solidifies** — music layers accrue the way rust accrues on over-walked tiles.
3. Give each rewrite operator a **unique earprint** so authorship is audible.
4. Speak in **brutalist transit PA tones** (no VO) matching the tone bible.
5. Treat **silence as a designed material** in early Induction chambers.
6. End clears with a **win fanfare that opens a loop** — resolve, then a hungry interval that makes queuing the next chamber feel inevitable.

Cold/abstract risk → **commit hard to audio identity** (subway map / maintenance PA, not fantasy dungeon kitbash).

---

## 2. Bus layout (Godot)

Buses live in [`game/echo_lattice/default_bus_layout.tres`](../../game/echo_lattice/default_bus_layout.tres). Wire via `audio/buses/default_bus_layout` in `project.godot` (see [`project.godot.audio.fragment`](../../game/echo_lattice/project.godot.audio.fragment)).

| Bus | Send | Role | Default volume |
|---|---|---|---|
| **Master** | — | Final mix / mute-all | `0 dB` |
| **SFX** | Master | Footsteps, rewrite stingers, win fanfare | `0 dB` |
| **Music** | Master | L0–L3 adaptive habit layers | `-6 dB` |
| **UI** | Master | Menus, pause, confirm/cancel | `-3 dB` |
| **PA** | Master | Diegetic transit attention tones (no speech) | `-2 dB` |

```
Master
├── SFX
├── Music
├── UI
└── PA
```

### Rules

1. Every `AudioStreamPlayer` sets `bus` explicitly. PA never rides the UI bus.
2. Settings sliders map 1:1 to bus volume (`AudioServer.set_bus_volume_db`). Persist under `user://settings.cfg`.
3. Mute Music independently for streamers; **never** mute SFX/PA when Music is muted (rewrite telegraphs + PA stay audible).
4. PA events may duck Music −2 to −3 dB for 0.8–1.2 s (see event catalog). Rewrite stingers duck Music −3.5 to −4.5 dB for ~400 ms.
5. No FX on Master for MVP. Optional later: soft limiter on Master; short reverb send on **SFX** only for rewrite/win.

---

## 3. Asset folders

```
game/echo_lattice/audio/
  events/audio_events.json   # structured event catalog (source of truth for IDs)
  sfx/
    footstep_*.ogg
    rewrite_*.ogg            # generic + warn
    rewrite/<operator>.ogg   # unique stingers
    pa/*.ogg                 # diegetic transit tones → bus PA
    win/*.ogg                # chamber resolve + queue-next
  music/
    L0_bed.ogg … L3_rewrite.ogg
    bed_placeholder.ogg      # v1 alias of L0 (compat)
  ui/
  README.md
```

Regenerate placeholders:

```bash
python3 tools/audio/generate_echo_lattice_placeholders.py
python3 tools/audio/validate_audio_events.py
```

---

## 4. Structured audio events (Godot)

Gameplay should **not** hardcode file paths. Fire named events through `AudioDirector`.

| Autoload | Script | Role |
|---|---|---|
| `AudioManager` | `scripts/audio/audio_manager.gd` | SFX/UI/PA pools, Music ducking, bus API |
| `AdaptiveMusic` | `scripts/audio/adaptive_music.gd` | L0–L3 stems + habit solidify intensity |
| `SilenceDirector` | `scripts/audio/silence_director.gd` | Early-chamber Music caps |
| `PaAnnouncer` | `scripts/audio/pa_announcer.gd` | Tone-bible line id → PA event |
| `AudioDirector` | `scripts/audio/audio_director.gd` | Gameplay facade |

Catalog: [`audio/events/audio_events.json`](../../game/echo_lattice/audio/events/audio_events.json)

### Playback conventions

```gdscript
AudioDirector.set_chamber(chamber_index)  # applies silence policy
AudioDirector.update_habit_audio(dominant_bias, repetition, fossil_density, rewrite_norm, proximity)
AudioDirector.on_footstep()
AudioDirector.on_rewrite_warn()
AudioDirector.on_rewrite("fossilize_hot_cell")  # unique stinger
AudioDirector.on_pa_line("pa.checkpoint.armed")  # chime only; copy is UI
AudioDirector.on_chamber_won()  # resolve + queue-next open loop
```

`SfxCatalog` still exposes path constants for tools and fallbacks.

---

## 5. Adaptive music — habit solidification layers

Music is a **layered bed**, not a playlist. Intensity tracks how *solid* the player’s habit has become — the same emotional arc as rust colonization in the art bible.

### 5.1 Signals

| Signal | Range | Meaning |
|---|---|---|
| `habit_solidify` | 0..1 | Dominant bias + repetition + fossil density + rewrite count |
| `rewrite_tension` | 0..1 | Buffer proximity to next transform + fail pressure |
| `music_intensity` | 0..1 | Smoothed blend, then **clamped by SilenceDirector** |

```
habit_solidify = clamp(
    0.40 * dominant_bias
  + 0.30 * repetition_score
  + 0.20 * fossil_density
  + 0.10 * rewrite_count_norm
, 0, 1)

music_target = clamp(0.65 * habit_solidify + 0.35 * rewrite_tension, 0, 1)
music_intensity += (min(music_target, silence_cap) - music_intensity) * (1 - exp(-dt / 0.35))
```

API: `AdaptiveMusic.set_habit_solidify`, `set_rewrite_tension`, `compute_solidify_from_metrics`, plus v1 alias `set_habit_tension` → rewrite component.

### 5.2 Layers (stems)

| Layer | File | When audible | Character / emotion |
|---|---|---|---|
| **L0 Bed** | `music/L0_bed.ogg` | When silence cap > 0 | HVAC / transformer pulse — institutional calm |
| **L1 Lattice** | `music/L1_lattice.ogg` | `intensity ≥ 0.25` | Sparse LED-board ticks — map awareness |
| **L2 Habit** | `music/L2_habit.ogg` | `intensity ≥ 0.55` | Dissonant fifths — habit locking in (addiction heat) |
| **L3 Rewrite** | `music/L3_rewrite.ogg` | `intensity ≥ 0.80` or rewrite pulse | Narrow swell — commit / punish imminent |

Crossfade via volume automation (200–400 ms). Prefer never stopping streams mid-chamber (avoids gaps). When silence cap is `0`, **all layers including L0 mute** — true silence.

### 5.3 Event overrides

| Game event | Music response |
|---|---|
| Rewrite fires | Spike toward L3 for 0.6 s (`pulse_rewrite`) |
| Chamber win | Drop L2/L3; leave a warm L0 whisper under queue-next sting |
| Death / reset | Hard cut L3; intensity → 0; rebuild with player |
| Pause / UI | Duck Music bus −8 dB |
| Title / map | L0 only or silence per shell design |

### 5.4 What not to do

- No full orchestral stingers that drown SFX/PA.
- No vocals / dialogue / VO tutorials (tone bible + this doc).
- No randomized generative MIDI that breaks deterministic demos — intensity is a **function of habit metrics + buffer**.
- No “always-on trailer music” in Wing 0 Quiet Span.

---

## 6. Unique stingers per rewrite operator

Each operator in the habit engine / transform pack has a dedicated one-shot. Players should learn operators by ear the way they learn tile shapes by eye.

| Operator | Event id | Sonic identity |
|---|---|---|
| `fossilize_hot_cell` | `sfx.rewrite.fossilize_hot_cell` | Descending lock → cold plate |
| `place_deflector` | `sfx.rewrite.place_deflector` | Lateral shove + metallic edge |
| `carve_shortcut` | `sfx.rewrite.carve_shortcut` | Air rush → bright gate click |
| `grow_wall_far_from_path` | `sfx.rewrite.grow_wall_far_from_path` | Stacked rising fifths (accretion) |
| `widen_hot_corridor` | `sfx.rewrite.widen_hot_corridor` | Detuned open / lateral bloom |
| `mirror` | `sfx.rewrite.mirror` | Motif then exact reverse |
| `rotate` | `sfx.rewrite.rotate` | Pivot around a center tone |
| `thicken` | `sfx.rewrite.thicken` | Low stack grows harmonics |
| `invert` | `sfx.rewrite.invert` | High tick → submerged inverse |

Unknown operator → `sfx.rewrite` generic. Always call `AdaptiveMusic.pulse_rewrite()` alongside the stinger (`AudioDirector.on_rewrite` does this).

Warn telegraph remains shared: `sfx.rewrite_warn` when habit tension crosses threshold (footstep pitch still rises with tension — §8).

---

## 7. Silence as a feature (early chambers)

Induction teaches with **space**, not score. Music is withheld so footsteps, ghost, and the first rewrite sting imprint harder.

| Chamber index | Max `music_intensity` | Intent |
|---|---|---|
| `0` Quiet Span | **0.0** | Designed silence — locomotion only |
| `1` Echo Plate | 0.10 | Barely-there air |
| `2` Mirror Birth | 0.25 | L0+L1 may breathe under first rewrite |
| `3` Break the Loop | 0.45 | Habit heat begins |
| `4+` | 1.0 | Full adaptive stack |

Source of truth: `silence_policy` in `audio_events.json`, enforced by `SilenceDirector.set_chamber_index` → `AdaptiveMusic.set_max_intensity`.

**Rules**

- Silence never mutes SFX or PA.
- Chamber 0 must pass acceptance with Music bus effectively empty.
- Returning players still honor silence caps (identity, not tutorial-only).

---

## 8. SFX catalog (MVP+)

### 8.1 Footsteps

| Event | Trigger | Notes |
|---|---|---|
| `sfx.footstep` | Successful grid step | Dry click; pitch jitter ±4%; habit pitch `lerp(1.0, 1.18, t)` |
| `sfx.footstep_blocked` | Walk into wall | Lower, duller |

When `habit_tension ≥ 0.7` for 2+ steps, layer a thin metallic overtone (same file, +7 semitones, −18 dB) — polish pass; placeholders may omit the overtone layer.

### 8.2 Win / queue-next (addiction beat)

| Event | Role |
|---|---|
| `win.chamber` | Short major resolve (satisfaction) |
| `win.queue_next` | Unresolved rising fourth → sharp leading tone that **cuts early** |
| `win.fanfare` | Concatenated resolve + queue-next (single file / v1 compat path) |
| `win.wing` | Longer wing clear |

`AudioDirector.on_chamber_won()` fires `win.chamber`, which **follow_up**s `win.queue_next` (~80 ms). The open loop is intentional: dopamine for “one more chamber,” not a fully closed cadence.

### 8.3 UI

| Event | Bus | Notes |
|---|---|---|
| `ui.click` | UI | Soft ticks; never compete with rewrite/PA |
| Pause | — | Music ducks −8 dB; SFX/PA unchanged |

---

## 9. Diegetic PA / brutalist transit tone

Matches [`12_TONE_AND_TUTORIAL`](12_TONE_AND_TUTORIAL.md) §2: **brutalist transit authority** — subway LED boards, maintenance chimes, institutional two-tones. **No speech, no VO, no robot quips.**

| Event | Use |
|---|---|
| `pa.attention` | General PA strip attention (boot, rewrite fired, death) |
| `pa.board_tick` | Board / matched / ghost literacy ticks |
| `pa.rewrite_armed` | Checkpoint armed |
| `pa.wing_clear` | Wing filed |

`PaAnnouncer.play_line("pa.checkpoint.armed")` maps tone-bible line ids → events. On-screen text carries meaning; audio carries **institution**.

Mixing: PA sits slightly under rewrite stingers, above Music bed. Duck Music on attention/armed/wing_clear.

---

## 10. Mixing targets (desktop MVP)

| Bus / class | Peak guidance |
|---|---|
| Master integrated | ≈ −14 LUFS gameplay |
| Footsteps | Spam-safe; never mask rewrite warn |
| Operator stinger | Loudest one-shots; laptop-speaker readable |
| Queue-next sting | Clear but shorter/quieter than resolve — hunger, not brass |
| Music bed | Under SFX/PA; L3 may approach but not exceed rewrite |
| PA | Institutional, dry, never cute |
| Early silence | Chamber 0 Music ≈ digital black |

Test on: laptop speakers, cheap earbuds, one reference headset.

---

## 11. Accessibility

| Need | Response |
|---|---|
| Deaf / hard of hearing | Visual habit-tension + rewrite flash; audio never sole channel |
| Photosensitive | No strobing audio-synced flashes required |
| Separate mute | Music mute ≠ SFX mute ≠ PA mute |
| Silence chambers | Visual teach still complete (tone bible A1) |

---

## 12. Implementation map

| Path | Role |
|---|---|
| `default_bus_layout.tres` | Master / SFX / Music / UI / PA |
| `audio/events/audio_events.json` | Event IDs, streams, ducks, silence policy |
| `scripts/audio/audio_director.gd` | Gameplay API |
| `scripts/audio/audio_manager.gd` | Pools + ducks |
| `scripts/audio/adaptive_music.gd` | L0–L3 + solidify |
| `scripts/audio/silence_director.gd` | Early-chamber caps |
| `scripts/audio/pa_announcer.gd` | Line id → PA tone |
| `scripts/audio/sfx_catalog.gd` | Path constants |
| `scripts/audio/audio_events.gd` | Catalog loader |
| `tools/audio/generate_echo_lattice_placeholders.py` | Procedural WAV/OGG v2 |
| `tools/audio/validate_audio_events.py` | Catalog + asset CI check |

---

## 13. Production checklist

- [x] Bus layout Master / SFX / Music / UI / **PA**
- [x] Structured `audio_events.json` + `AudioDirector`
- [x] Adaptive L0–L3 stems driven by **habit solidify**
- [x] Unique stingers for all baseline + transform operators
- [x] Diegetic PA attention / board / armed / wing tones
- [x] Silence policy for chambers 0–3
- [x] Win resolve + **queue-next** open-loop fanfare
- [x] Placeholder generator v2 + validator
- [ ] Replace placeholders with authored one-shots / stems
- [ ] Wire autoloads into playable `project.godot` merge
- [ ] Settings sliders → bus dB (incl. PA)
- [ ] Trailer pass: first rewrite + queue-next audible in 15 s cut

---

## 14. Changelog

| Ver | Notes |
|---|---|
| **v1** | Buses, generic placeholders, intensity stub |
| **v2** | Habit-solidify layers, per-operator stingers, PA bus + tones, silence policy, structured events, queue-next win fanfare |

---

## 15. References

- Tone / PA copy: [`12_TONE_AND_TUTORIAL.md`](12_TONE_AND_TUTORIAL.md)
- Art material notes (paper-crease, chalk-scuff): [`05_ART_BIBLE.md`](05_ART_BIBLE.md)
- Operators: habit engine `rewrite_operators.gd` + systems transform packs
- Risk note: cold/abstract → audio identity is load-bearing for Steam page and demo feel
