# Security High fixes (SEC-01 / SEC-02 / SEC-03)

| Field | Value |
|---|---|
| **Base** | `cursor/echo-lattice-rc1` |
| **Branch** | `cursor/fix-sec-high` |
| **Date** | 2026-08-09 |
| **Audit** | [`SECURITY.md`](SECURITY.md) |

Closes the three **High** findings before Steam init / Cloud enablement.

| ID | Fix |
|---|---|
| **SEC-01** | AppID resolution fail-closed. Spacewar `480` only when `allow_spacewar_dev` is true **and** editor/debug. No silent fallback when `steam_enabled` lacks a real AppID. |
| **SEC-02** | `SaveManager.validate_save_text` / `validate_save_dict` gate Steam Cloud pulls; write via `user://save.json.cloud.tmp` then rename. Invalid remote blobs never replace `save.json`. |
| **SEC-03** | `--screenshot --out` allowlisted to `user://` or paths under the Godot project root; capture tools stage in `.capture_staging/`. |

**Tests:** `python3 game/echo_lattice/tests/test_security_high.py`

**Release note:** see also [`../RELEASE/STEAMWORKS.md`](../RELEASE/STEAMWORKS.md) (AppID / Cloud sections).
