# Echo Lattice audio (AUDIO v3 procedural lift)

Structured event wiring + procedural streams lifted toward AUDIO v3 identity (multi-stage slam phrases, Ledger Cell habit stems, quieter rests, win/fail stingers). **Not** the authored 1.0 mix — see [`docs/AUDIT/PRODUCTION_AUDIO_DEBT.md`](../../../docs/AUDIT/PRODUCTION_AUDIO_DEBT.md).

- **Vision:** [`docs/VISION/AUDIO_V3.md`](../../../docs/VISION/AUDIO_V3.md)
- **Bible (wiring):** [`docs/ECHO_LATTICE/06_AUDIO_BIBLE.md`](../../../docs/ECHO_LATTICE/06_AUDIO_BIBLE.md)
- **Event catalog:** [`events/audio_events.json`](events/audio_events.json) (version 3)
- **Buses:** [`../default_bus_layout.tres`](../default_bus_layout.tres) — Master / SFX / Music / UI / **PA**
- **Regenerate:** `python3 tools/audio/generate_echo_lattice_placeholders.py`
- **Validate:** `python3 tools/audio/validate_audio_events.py`

| Path | Bus |
|---|---|
| `sfx/*` (except `sfx/pa`) | SFX |
| `sfx/pa/*` | PA |
| `sfx/rewrite/*` | SFX (per-operator ~0.90s slam phrases) |
| `sfx/win/*` | SFX |
| `sfx/fail/*` | SFX (restart / recover) |
| `music/L0…L3_*` | Music (Ledger Cell transforms) |
| `ui/*` | UI (`ui.select` / `ui.hover` / `ui.click` confirm) |

## Gameplay entry points

Prefer `AudioDirector` (autoload) over raw paths:

```gdscript
AudioDirector.set_chamber(GameState.current_chamber) # silence cap
AudioDirector.update_habit_audio(bias, rep, fossils, rewrites, proximity)
AudioDirector.on_footstep()
AudioDirector.on_rewrite("fossilize_hot_cell")
AudioDirector.on_pa_line("pa.checkpoint.armed")
AudioDirector.on_chamber_won() # resolve + queue-next open loop
AudioDirector.on_fail_reset()  # chamber restart
# Field Index feel (silence gaps + arm after grab_focus):
AudioDirector.arm_ui_feel()
AudioDirector.on_ui_select()
AudioDirector.on_ui_hover()
AudioDirector.on_ui_confirm()  # catalog ui.click stinger
```

Replace procedural streams with authored Field Ledger material before marketing a final mix.
