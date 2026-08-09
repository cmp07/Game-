# Echo Lattice audio (AUDIO v2)

Structured placeholders + Godot event wiring for habit addiction, operator identity, diegetic PA, early-chamber silence, and queue-next win fanfare.

- **Bible:** [`docs/ECHO_LATTICE/06_AUDIO_BIBLE.md`](../../../docs/ECHO_LATTICE/06_AUDIO_BIBLE.md)
- **Event catalog:** [`events/audio_events.json`](events/audio_events.json)
- **Buses:** [`../default_bus_layout.tres`](../default_bus_layout.tres) — Master / SFX / Music / UI / **PA**
- **Regenerate:** `python3 tools/audio/generate_echo_lattice_placeholders.py`
- **Validate:** `python3 tools/audio/validate_audio_events.py`

| Path | Bus |
|---|---|
| `sfx/*` (except `sfx/pa`) | SFX |
| `sfx/pa/*` | PA |
| `sfx/rewrite/*` | SFX (per-operator stingers) |
| `sfx/win/*` | SFX |
| `music/L0…L3_*` | Music |
| `ui/*` | UI |

## Gameplay entry points

Prefer `AudioDirector` (autoload) over raw paths:

```gdscript
AudioDirector.set_chamber(GameState.current_chamber) # silence cap
AudioDirector.update_habit_audio(bias, rep, fossils, rewrites, proximity)
AudioDirector.on_footstep()
AudioDirector.on_rewrite("fossilize_hot_cell")
AudioDirector.on_pa_line("pa.checkpoint.armed")
AudioDirector.on_chamber_won() # resolve + queue-next open loop
```

Replace placeholders before ship; do not ship beep identity as final mix.
