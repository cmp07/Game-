# Echo Lattice — RC Bug Bash

**Build:** `game/echo_lattice/` (Godot 4.3) · config version `0.2.0`  
**Branch:** `cursor/release-polish-rc`  
**Scope:** Softlocks, UI/Continue, save integrity, input (KB + gamepad), juice consistency.

Use this sheet for a live play pass. Items marked **FIXED** shipped as code on this branch — verify they stay fixed; do not treat the checklist as documentation-only.

---

## Automated gates (run before bash)

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/test_rc_polish.py
python3 game/echo_lattice/tests/test_balance_v2.py
# Prefer headless Godot when available:
godot4 --headless --path game/echo_lattice -- --selftest
```

| Gate | Expect |
|---|---|
| Chamber JSON validate | `result: OK` (39 chambers) |
| `test_rc_polish.py` | all tests OK |
| `test_balance_v2.py` | all tests OK |
| `--selftest` | `result: OK`, exit 0 |

---

## Softlocks — FIXED in code

| ID | Case | Fix | Manual verify |
|---|---|---|---|
| SL-1 | Walk during rewrite slam onto pending echo cells | Movement / undo blocked while `pending_echoes` active; restart still allowed | Trigger a checkpoint rewrite; mash WASD — player must not move until slam settles |
| SL-2 | Fossilize under player / goal | Flush skips `player_pos` and `goal_pos` | Visual: slam never paints the tile you stand on |
| SL-3 | Safety-net miss leaves goal unreachable | `_recover_softlock` strips newest echoes; telemetry `softlock_assert_failed` | Should never trap; if recovery fires, check `user://telemetry/` |
| SL-4 | Esc / scene tear-down mid-slam | Chamber flushes on exit; HUD Esc flushes before menu | Esc mid-rewrite → menu → Continue loads a solvable chamber |
| SL-5 | Continue replays a cleared room | `continue_run()` skips completed queue entries | Clear chamber 1, quit to menu, Continue → chamber 2 |
| SL-6 | Continue after wing finish soft-loops last room | `can_continue()` false when `queue_pos >= run_queue.size()` | Finish a Daily wing → menu Continue disabled |

---

## Save — FIXED in code

| ID | Case | Fix | Manual verify |
|---|---|---|---|
| SV-1 | Crash / kill mid-write corrupts save | Atomic `save.json.tmp` → rename; rotates `save.json.bak` | Play 2 chambers, force-quit, relaunch → Continue works |
| SV-2 | Corrupt `save.json` bricks progress | Load falls back to `.bak` | (Optional) truncate save.json; boot should restore |
| SV-3 | Legacy empty `run_queue` softlocks Continue | Rebuild standard queue on load | Old save without queue still Continues |
| SV-4 | `run_started` lost across sessions | Persisted in save v2 | Start run, quit before first clear, relaunch → Continue if `run_started` |
| SV-5 | Quit without flush | `WM_CLOSE_REQUEST` + `_exit_tree` save | Alt-F4 from chamber keeps progress |

Save path: `user://save.json` (+ `.bak`). Wipe removes path, tmp, and bak.

---

## Input / UI — FIXED in code

| ID | Case | Fix | Manual verify |
|---|---|---|---|
| IN-1 | No gamepad bindings | D-Pad + left stick; Y restart, X undo, B/Start menu, A confirm | Full chamber on a pad |
| IN-2 | OS key-repeat floods moves | Ignore `InputEventKey` echoes; hold-to-walk repeat (220 ms / 80 ms) | Hold D — steady walk, not a stutter-burst |
| IN-3 | Menu hint omitted pad | Footer lists pad glyphs | Main menu footer readable |
| UI-1 | Continue enabled after wing clear | Disabled + subtitle “Wing complete…” | After end screen → menu |
| UI-2 | Continue with no progress | Disabled / dimmed | Fresh wipe boot |

---

## Juice consistency — FIXED in code

| ID | Case | Fix | Manual verify |
|---|---|---|---|
| JX-1 | Rewrite flash used raw hex, not palette | `Juice.flash` / `rewrite_punch` use `Palette.CADMIUM_WARN` | Rewrite slam reads cadmium, not random red |
| JX-2 | Hitstop ease used hardcoded 0.09 s | Tracks `hitstop_duration` | Wall bump vs rewrite punch feel distinct |
| JX-3 | Wall bump had shake only | Short cadmium flash on blocked move | Nudge a wall |
| JX-4 | Win beat sparse vs rewrite | Win: hitstop + slate flash + copper burst | Clear any chamber |

---

## Manual smoke matrix (must pass for RC)

Play these on keyboard **and** gamepad:

1. **Boot → Start New Run → chamber 0** — focus, caption, habit “unwritten”.
2. **Hold-to-walk** across a long corridor.
3. **Checkpoint rewrite** — telegraph → slam → fossils; no input during slam.
4. **Undo** across a non-rewrite move; undo does nothing during slam.
5. **Restart (R / Y)** mid-slam — chamber resets cleanly.
6. **Esc / B** to menu mid-chamber → **Continue** resumes correct index.
7. **Daily** five-chamber wing → end screen → menu Continue off.
8. **Quit / relaunch** after clearing ≥1 chamber — stars + Continue intact.
9. **Wall bump juice** + **win juice** visible with audio if device unmuted.
10. **Act transition** (chambers 8→9 / 17→18 / 26→27) — title/HUD update, no black screen.

---

## Known non-blockers (out of this RC pass)

- Full Settings / Accessibility shell from UI scaffold PR (not merged into playable tree).
- Cross-run ghost replay; Steam Cloud; localisation.
- Mid-chamber tile-exact resume (Continue reloads chamber layout; intentional for puzzles).
- Controller glyph art in HUD (text hints only).

---

## Sign-off

| Role | Name | Date | Build / commit | Result |
|---|---|---|---|---|
| Dev selftest | | | | ☐ pass |
| Bug bash lead | | | | ☐ pass |
| RC candidate | | | | ☐ ship / ☐ hold |

Log blockers with chamber id, input device, and whether `softlock_assert_failed` appeared in local telemetry.
