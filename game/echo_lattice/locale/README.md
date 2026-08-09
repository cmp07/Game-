# Locale catalogs

| File | Role |
|---|---|
| `echo_lattice.csv` | Godot `TranslationServer` catalog — columns `keys,en,zh_Hans` |

Loaded at runtime by `scripts/locale/locale_manager.gd` (autoload). Do not commit generated `*.translation` binaries (gitignored).

Docs: [`docs/RELEASE/LOCALIZATION.md`](../../../docs/RELEASE/LOCALIZATION.md).  
Validate: `python3 game/echo_lattice/tests/validate_locale.py`.
