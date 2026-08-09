# Echo Lattice — Onboarding + Modes (v2)

**Branch:** `cursor/echo-lattice-onboard-modes-v2`  
**Base:** playable vertical slice ([PR #48](https://github.com/cmp07/Game-/pull/48))  
**Code:** `game/echo_lattice/`

---

## A) Onboarding — first 90s, “it learned me” by chamber 2

| Beat | Chamber | What happens |
|---|---|---|
| Quiet Span | `0` | Short hall. Plate line `WALK THE SPAN`. No rewrite. |
| Echo Plate | `1` | Step the yellow plate → `CHECKPOINT — BUFFER ARMED`. Still no walls. |
| Mirror Birth | `2` | Walk a legible path → plate → orange echo walls mirror you → `IT MATCHES YOU`. |

Guarantees:

- **Spectacle by chamber 2** — first `mirror_v` rewrite is chamber index 2 (`spectacle: true`).
- **≤90s path budget** — shortest-path sum across chambers 0–2 is self-tested under 90 steps (one step ≈ one second of deliberate play).
- **No text walls** — captions ≤ ~8 words; teach lines are diegetic PA/toasts from `data/tutorial/diegetic_lines.json`.
- **Undo on self-trap** — after a rewrite, bumping an echo wall arms `Z · UNDO` (`pa.undo.hint`). Undo reverts the step (and the rewrite if you undo across the plate).

Induction graduation: clearing chamber 2 sets `induction_complete` in the save.

---

## B) Modes — select UI wired

Menu → **Play** → **Select Mode**:

| Mode | Status | Behaviour |
|---|---|---|
| **Campaign** | Live | Chambers 0→9 sequential (induction first). |
| **Daily** | Live | UTC date → FNV seed → chamber from rewrite pool `[2..9]`. Result card + local best. |
| **Endless Shift** | Live | Cycle pool `[2..9]`; streak + best streak. |
| **Zen** | Stub | Local shell card only. |
| **Speedrun** | Stub | Local shell card only. |
| **Hotseat** | Stub | Local shell card only (no netcode). |

Autoload: `ModeService` (`scripts/mode_service.gd`).

---

## Verify

```bash
cd game/echo_lattice
godot --headless --path . -- --selftest
```

Expect `result: OK`, including induction budget, daily seed stability, mode routing, self-trap arm, and full 10-chamber playthrough.

---

## Gaps / known partials

1. **Zen / Speedrun / Hotseat** — UI stubs only; no timers, no turn passing, no calm-ruleset.
2. **Daily** — offline local only; no share string / leaderboard (by design for now).
3. **Endless** — cycles authored chambers; no procedural generator or difficulty ramp beyond pool order.
4. **Induction audio** — PA is text-only (audio lane is a separate PR).
5. **Returning-player skip** — `induction_complete` suppresses compulsory induction PA on later campaign enters for some lines (`once_flag`); Campaign still starts at chamber 0 (no wing-skip UI yet).
6. **Tutorial JSON** — beats/titles/tips are loaded as data; only diegetic lines are bound at runtime via `DiegeticPA`.
7. **Main `docs/FIVE_GAMES_TO_BUILD.md`** — still lives on the deep-dive branch; this lane stays pure Echo Lattice on the playable slice.

Co-authored with the failed separate onboarding/modes agents’ brief: one agent, two deliverables, ship the strongest playable partial.
