# Echo Lattice — Content (v2)

Playable chamber format from [PR #48](https://github.com/cmp07/Game-/pull/48), expanded to **39 authored chambers** across four Acts.

| Path | Purpose |
|---|---|
| `chambers/*.json` | Authored chambers (source of truth) |
| `acts.json` | Act roster + campaign / hard order |
| `daily/seeds.json` | Daily-ready seed catalog (hash fallback) |
| `daily/calendar_90.json` | Pre-authored UTC Daily calendar (launch → +89) |
| `grammar/` | Variation + rewrite vocabulary |
| `schema/chamber.schema.json` | JSON Schema draft-07 |

Authoritative design doc: [`docs/ECHO_LATTICE/04_CONTENT_BIBLE.md`](../../../docs/ECHO_LATTICE/04_CONTENT_BIBLE.md).  
Post-launch ops: [`docs/RELEASE/`](../../../docs/RELEASE/).

## Validate

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/author_chambers_v2.py   # regenerate from roster
python3 game/echo_lattice/tests/test_release_liveops.py
python3 tools/release/generate_calendar_90.py           # regenerate calendar_90.json
python3 game/echo_lattice/tests/validate_locale.py      # EN + zh_Hans catalog parity
```

Chamber `title` / `caption` stay English in JSON; localized display strings live in [`locale/echo_lattice.csv`](../locale/echo_lattice.csv) (`chamber.<id>.title` / `.caption`). See [`docs/RELEASE/LOCALIZATION.md`](../../../docs/RELEASE/LOCALIZATION.md).

## Acts

1. **Induction** — learn the rewrite  
2. **Reflection** — both axes / portraits  
3. **Pressure** — habits harden  
4. **Mastery** — compose + identity nameplate  

Balance codenames (see `config/balance_v2.json`): SEED / GROWTH / PRISM / MASTERY.

## CONTENT notes (P0 — RC1)

Shipped on branch `cursor/fix-content-clones` against audit [`CONTENT_CHAMBERS.md`](../../../docs/AUDIT/CONTENT_CHAMBERS.md):

| Item | Resolution |
|---|---|
| Exact clones `04==09`, `18==35`, `19==27` | Rebuilt distinct teach/test maps: Twin Rail (Reflection spine lesson), Mirror Birth+ (true hard of `02`, less floor), Conductor's Cut (Mastery baton carve). Author source: `tests/author_chambers_v2.py`. |
| Dead `rewrite.cap` | Wired in `chamber.gd` (enforce + undo). Caps raised on `05` / `08` so dual checkpoints match captions. Author formula: `max(act_default, checkpoint_count)`. Validator fails if `cap < C` or Hamming==0 clones. |
| Balance 3-act drift | Retargeted to **4 acts**: SEED→Induction, GROWTH→Reflection, **PRISM→Pressure**, **MASTERY→Mastery**. `ChamberBook` no longer clamps Act IV into PRISM. |
