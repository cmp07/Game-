# Echo Lattice — config

## Balance v2

Authoritative tuning file: [`balance_v2.json`](balance_v2.json)  
Design contract: [`docs/ECHO_LATTICE/14_BALANCE_V2.md`](../../../docs/ECHO_LATTICE/14_BALANCE_V2.md)

Four balance acts map onto content acts:

| Balance | Codename | Content |
|---|---|---|
| 1 | SEED | Induction |
| 2 | GROWTH | Reflection |
| 3 | PRISM | Pressure |
| 4 | MASTERY | Mastery |

Load at runtime via `BalanceTuning.load_default()` (`scripts/balance_tuning.gd`).

```bash
python3 game/echo_lattice/tests/test_balance_v2.py
```

## Accessibility defaults

Player-facing defaults: [`default_settings.json`](default_settings.json)  
Release checklist: [`docs/RELEASE/ACCESSIBILITY.md`](../../../docs/RELEASE/ACCESSIBILITY.md)

```bash
python3 game/echo_lattice/tests/test_a11y_settings.py
```
