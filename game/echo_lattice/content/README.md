# Echo Lattice — Content (v2)

Playable chamber format from [PR #48](https://github.com/cmp07/Game-/pull/48), expanded to **39 authored chambers** across four Acts.

| Path | Purpose |
|---|---|
| `chambers/*.json` | Authored chambers (source of truth) |
| `acts.json` | Act roster + campaign / hard order |
| `daily/seeds.json` | Daily-ready seed catalog |
| `grammar/` | Variation + rewrite vocabulary |
| `schema/chamber.schema.json` | JSON Schema draft-07 |

Authoritative design doc: [`docs/ECHO_LATTICE/04_CONTENT_BIBLE.md`](../../../docs/ECHO_LATTICE/04_CONTENT_BIBLE.md).

## Validate

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/author_chambers_v2.py   # regenerate from roster
```

## Acts

1. **Induction** — learn the rewrite  
2. **Reflection** — both axes / portraits  
3. **Pressure** — habits harden  
4. **Mastery** — compose + identity nameplate  
