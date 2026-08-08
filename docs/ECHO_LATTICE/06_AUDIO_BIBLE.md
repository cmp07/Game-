# Echo Lattice — Audio Bible

**Doc:** `06_AUDIO_BIBLE`  
**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4  
**Status:** Implementation stubs + placeholder SFX  
**Companion assets:** [`game/echo_lattice/audio/`](../../game/echo_lattice/audio/)

---

## 1. Intent

Audio is a **primary readability channel**, not decoration. The lattice rebuilds from the player’s habits; sound must telegraph that rewrite *before* walls move, so the fantasy (“it learned you”) lands as skill, not RNG.

From the concept brief:

- Footstep materials **pitch-shift when a rewrite is about to punish a habit**.
- **No dialogue.** Identity is modular corridor acoustics + adaptive music intensity.
- Cold/abstract risk → **commit hard to audio identity** (brutalist subway map, not fantasy dungeon kitbash).

---

## 2. Bus layout (Godot)

Buses live in [`game/echo_lattice/default_bus_layout.tres`](../../game/echo_lattice/default_bus_layout.tres). Wire via `audio/buses/default_bus_layout` in `project.godot`.

| Bus | Send | Role | Default volume |
|---|---|---|---|
| **Master** | — | Final mix / mute-all | `0 dB` |
| **SFX** | Master | Footsteps, rewrite stingers, world one-shots, win sting | `0 dB` |
| **Music** | Master | Bed + adaptive intensity layers | `-6 dB` |
| **UI** | Master | Menus, pause, confirm/cancel, settings ticks | `-3 dB` |

### Rules

1. Every `AudioStreamPlayer` / `AudioStreamPlayer2D` must set `bus` explicitly (`"SFX"`, `"Music"`, or `"UI"`). Never leave UI on SFX by accident.
2. Settings sliders map 1:1 to bus volume (`AudioServer.set_bus_volume_db`). Persist under `user://settings.cfg`.
3. No FX on Master for MVP. Optional later: soft limiter on Master; short reverb send only on **SFX** for rewrite/win.
4. Mute Music independently for streamers; never mute SFX when Music is muted (rewrite telegraphs stay audible).

```
Master
├── SFX
├── Music
└── UI
```

---

## 3. Asset folders

```
game/echo_lattice/audio/
  sfx/          # one-shots → bus SFX
  music/        # beds + intensity stems → bus Music
  ui/           # menu ticks → bus UI
  README.md
```

Placeholders (procedural beeps; replace before ship):

| File | Bus | Use |
|---|---|---|
| `sfx/footstep_placeholder.wav` (+ `.ogg`) | SFX | Grid step |
| `sfx/rewrite_placeholder.wav` (+ `.ogg`) | SFX | Checkpoint / lattice rewrite sting |
| `sfx/win_placeholder.wav` (+ `.ogg`) | SFX | Chamber / wing clear |
| `ui/ui_click_placeholder.wav` (+ `.ogg`) | UI | Confirm / focus |
| `music/bed_placeholder.ogg` | Music | Neutral low bed (loop stub) |

Regenerate with:

```bash
python3 tools/audio/generate_echo_lattice_placeholders.py
```

---

## 4. SFX catalog (MVP)

### 4.1 Footsteps

| Event | Trigger | Notes |
|---|---|---|
| `sfx.footstep` | Successful grid step | Short dry click; vary pitch ±4% per step |
| `sfx.footstep_blocked` | Walk into wall | Lower, duller than footstep |
| `sfx.footstep_ghost` | Ghost path tick (optional) | Quieter, band-passed copy of footstep |

**Habit-warn pitch shift (core identity):**

- Maintain a rolling **habit tension** `t ∈ [0, 1]` from the move buffer (see §5).
- Footstep playback pitch = `lerp(1.0, 1.18, t)` and mild high-shelf boost as `t` rises.
- When `t ≥ 0.7` for 2+ steps, layer a thin metallic overtone (same file, +7 semitones, −18 dB) — player should feel “the corridor is listening” before the rewrite fires.

Materials (later polish; MVP can use one sample + pitch):

| Tile family | Character |
|---|---|
| Concrete lattice | Dry, mid click |
| Accent-infected (overused habit tiles) | Slightly brighter / glassy |
| Checkpoint plate | Soft plate tap + short ring |

### 4.2 Rewrite

| Event | Trigger | Notes |
|---|---|---|
| `sfx.rewrite_warn` | `t` crosses warn threshold | Rising dissonant partial; 150–250 ms |
| `sfx.rewrite` | Grammar applies / walls regenerate | Harder impact + brief reverse whoosh; duck Music −4 dB for 400 ms |
| `sfx.undo` | Undo last step | Soft reverse of footstep |

Placeholder `rewrite_placeholder` covers warn+fire for vertical slice; split files in polish.

### 4.3 Win / progress

| Event | Trigger | Notes |
|---|---|---|
| `sfx.win_chamber` | Door / key clear | Short major arpeggio; clear and dry |
| `sfx.win_wing` | Wing complete | Longer resolve; may lift Music intensity then settle |
| `sfx.checkpoint` | Checkpoint armed | Soft latch click (can share rewrite warn family) |

### 4.4 UI

| Event | Bus | Notes |
|---|---|---|
| `ui.click` / `ui.cancel` | UI | Short ticks; never compete with rewrite sting |
| `ui.pause_open` | UI | One-shot; Music ducks −8 dB while paused |

---

## 5. Adaptive music — rewrite intensity

Music is a **layered bed**, not a playlist. Intensity tracks how close the lattice is to punishing the player’s current habit pattern.

### 5.1 Intensity signal

Compute once per successful step (or on buffer change):

```
habit_tension t = clamp(
    0.45 * repetition_score   # same relative turns / strafes repeating
  + 0.35 * rewrite_proximity  # distance-in-buffer to next transform fire
  + 0.20 * fail_pressure      # recent deaths / softlocks in chamber
, 0.0, 1.0)
```

Smooth with exponential approach: `music_intensity += (t - music_intensity) * (1 - exp(-dt / 0.35))`.

Stub: [`game/echo_lattice/scripts/audio/adaptive_music.gd`](../../game/echo_lattice/scripts/audio/adaptive_music.gd).

### 5.2 Layers (stems)

| Layer | Bus | When audible | Character |
|---|---|---|---|
| **L0 Bed** | Music | Always in chamber | Low pulse / soft drone; subway ventilation feel |
| **L1 Lattice** | Music | `intensity ≥ 0.25` | Sparse high ticks synced to step rate |
| **L2 Habit** | Music | `intensity ≥ 0.55` | Dissonant fifths; mirrors footstep warn band |
| **L3 Rewrite** | Music | `intensity ≥ 0.8` *or* rewrite firing | Narrow band swell; cuts on win |

Crossfade volumes with 200–400 ms tweens. Prefer volume/filter automation over starting/stopping streams (avoids gaps).

### 5.3 Event overrides

| Game event | Music response |
|---|---|
| Rewrite fires | Spike L3 0.6 s, then fall to `max(0.4, post_rewrite_t)` |
| Chamber win | Drop L2/L3 in 0.5 s; brief L0 major lift; settle |
| Death / reset | Hard cut L3; L0 −6 dB for 1 s; rebuild with player |
| Pause / UI | Duck entire Music bus −8 dB |
| Title / map | L0 only, lower tempo feel (or separate title bed later) |

### 5.4 Tempo / sync

MVP: free-running loops; footstep SFX stay diegetic and unsynced.  
Later: quantize rewrite sting to nearest 16th of L0 for polish trailers.

### 5.5 What not to do

- No full orchestral stingers that drown SFX.
- No randomized generative MIDI that breaks determinism demos — intensity is a **function of the move buffer**, same seed → same tension curve for a given play path.
- No vocals / dialogue / VO tutorials.

---

## 6. Implementation stubs

| Path | Role |
|---|---|
| `game/echo_lattice/default_bus_layout.tres` | Master / SFX / Music / UI |
| `game/echo_lattice/scripts/audio/audio_manager.gd` | Autoload stub: play SFX/UI on correct bus, volume API |
| `game/echo_lattice/scripts/audio/adaptive_music.gd` | Intensity → layer gains |
| `game/echo_lattice/scripts/audio/sfx_catalog.gd` | Path constants for placeholders |
| `tools/audio/generate_echo_lattice_placeholders.py` | Procedural WAV/OGG generator |

`AudioManager` should be registered as an autoload once the Godot scaffold lands (`AudioManager` → `res://scripts/audio/audio_manager.gd` or path under `echo_lattice/`).

### Playback conventions

```gdscript
# Footstep with habit warn
AudioManager.play_sfx(SfxCatalog.FOOTSTEP, pitch_scale = lerpf(1.0, 1.18, habit_t))

# Rewrite
AudioManager.play_sfx(SfxCatalog.REWRITE)
AdaptiveMusic.pulse_rewrite()

# Win
AudioManager.play_sfx(SfxCatalog.WIN)
AdaptiveMusic.on_chamber_win()
```

---

## 7. Mixing targets (desktop MVP)

| Bus / class | Peak guidance |
|---|---|
| Master integrated | ≈ −14 LUFS gameplay; avoid brickwalling |
| Footsteps | Quiet enough to spam; never mask rewrite warn |
| Rewrite sting | Loudest SFX; readable on laptop speakers |
| Music bed | Always under SFX; L3 may approach but not exceed rewrite |
| UI | Soft; pause duck Music, not SFX |

Test on: laptop speakers, cheap earbuds, one reference headset.

---

## 8. Accessibility

| Need | Response |
|---|---|
| Deaf / hard of hearing | Visual habit-tension meter + rewrite flash (systems/UI docs); audio never sole channel |
| Photosensitive | Rewrites must not require strobing audio-synced flashes |
| Separate mute | Music mute ≠ SFX mute |
| Pitch / warn | Colorblind-safe accent already carries habit infection; audio is redundant cue |

---

## 9. Production checklist

- [x] Bus layout Master / SFX / Music / UI
- [x] Placeholder footstep / rewrite / win (+ UI click)
- [x] Adaptive music intensity notes + script stub
- [ ] Replace placeholders with authored one-shots
- [ ] Record or commission L0–L3 stems (loop-safe)
- [ ] Wire `AudioManager` autoload in scaffold `project.godot`
- [ ] Settings sliders → bus dB
- [ ] Rewrite duck + pause duck verified in playable slice
- [ ] Trailer pass: first 5 s include rewrite audio identity

---

## 10. References

- Product pitch & art/audio line: sibling `docs/FIVE_GAMES_TO_BUILD.md` (Echo Lattice) / production bible when merged.
- Risk note: cold/abstract → audio identity is load-bearing for Steam page and demo feel.
