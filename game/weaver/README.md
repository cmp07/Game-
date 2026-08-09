# The Weaver — W1 juice spike

Throwaway Godot 4.3 feel proof for **The Weaver** (north star SKU).  
**Does not modify** `game/echo_lattice/`.

## Juice verbs

| Verb | Feel | API |
|---|---|---|
| Recover | Fragment suck — chalk/fiber into hand | `WeaverJuice.fragment_suck` |
| Bind | Combine flash — local paper press | `WeaverJuice.combine_flash` |
| Tension | Weave pulse — copper crest on Thread | `WeaverJuice.weave_pulse` |

Authority: [`docs/WEAVER/20_JUICE.md`](../../docs/WEAVER/20_JUICE.md).

## Run

```bash
godot --path game/weaver
# keys: E recover · F combine · Q weave · R reset

godot --path game/weaver --headless -- --selftest
```

## Tests (no editor)

```bash
python3 game/weaver/tests/test_weaver_juice.py
```

## Layout

```
game/weaver/
  project.godot
  content/palette.json
  scenes/demo_field.tscn
  scripts/juice/weaver_juice.gd
  scripts/juice/weaver_palette.gd
  scripts/field/demo_field.gd
  tests/test_weaver_juice.py
```
