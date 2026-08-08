# Echo Lattice audio

Placeholder procedural SFX/Music for vertical-slice wiring.

- **Bible:** [`docs/ECHO_LATTICE/06_AUDIO_BIBLE.md`](../../../docs/ECHO_LATTICE/06_AUDIO_BIBLE.md)
- **Buses:** [`../default_bus_layout.tres`](../default_bus_layout.tres) — Master / SFX / Music / UI
- **Regenerate:** `python3 tools/audio/generate_echo_lattice_placeholders.py`

| Path | Bus |
|---|---|
| `sfx/*` | SFX |
| `music/*` | Music |
| `ui/*` | UI |

Replace placeholders before ship; do not ship beep identity as final mix.
