# Echo Lattice — tutorial data

Runtime tables for diegetic copy and the Induction teach script.

**Spec:** [`docs/ECHO_LATTICE/12_TONE_AND_TUTORIAL.md`](../../../../docs/ECHO_LATTICE/12_TONE_AND_TUTORIAL.md)

| File | Role |
|---|---|
| `tutorial_beats.json` | Wing 0 beat script (T00–T06), chamber ids, line hooks |
| `diegetic_lines.json` | PA / toast / plate lines keyed by `id` |
| `loading_tips.json` | Loading / boot tips with unlock gates |
| `chamber_titles.json` | Wing 0 + Wing 1 titles / subtitles |

Godot project root is `game/echo_lattice/`, so load as `res://data/tutorial/*.json`.

Do not add VO assets here. Text only.
