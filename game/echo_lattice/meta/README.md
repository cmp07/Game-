# Echo Lattice — META v2

Retention layer: stars ledger, daily/weekly seeds, Museum of Selves, streaks, 35 achievements, NG+, short-run pacing.

## Spec

[`docs/ECHO_LATTICE/15_META_V2.md`](../../../docs/ECHO_LATTICE/15_META_V2.md)

## Layout

```
config/meta_v2.json              # tunables, pools, NG+, pacing
config/achievements_v2.json      # 35 milestone achievements
scripts/meta/                    # services (SeedClock, StarLedger, …)
scripts/meta/meta_v2.gd          # facade autoload candidate
scripts/meta/ui/                 # Hub, Museum, Achievements, Weekly, NG+
scenes/meta/*.tscn               # thin scene shells
tests/test_meta_v2.py            # headless acceptance tests
```

## Wire into `project.godot`

```ini
[autoload]
MetaV2="*res://scripts/meta/meta_v2.gd"
```

Fragment also at [`project.godot.meta_v2.fragment`](../project.godot.meta_v2.fragment).

Boot tip: instance `res://scenes/meta/meta_hub.tscn` from the main menu.

## Tests

```bash
python3 game/echo_lattice/tests/test_meta_v2.py
```
