# Echo Lattice — Production Audio Debt

**Branch / PR context:** `cursor/g1-audio-lift` → `cursor/echo-lattice-rc1`  
**Vision authority:** [`../VISION/AUDIO_V3.md`](../VISION/AUDIO_V3.md)  
**Cue sheet:** [`../VISION/AUDIO_1_0_CUE_SHEET.md`](../VISION/AUDIO_1_0_CUE_SHEET.md)  
**Wiring:** [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md) + `audio_events.json`

---

## What this lift shipped (procedural, not final)

Generator `tools/audio/generate_echo_lattice_placeholders.py` is now **v3**. Within DSP / procedural limits it:

| Pillar | Procedural lift |
|---|---|
| **P1 Slam as musical event** | Per-operator streams are ~0.90s multi-stage phrases: heartbeat → ≥80 ms rest → crease cascade → lift → slot downbeat → operator bleed ending |
| **P2 Habit as motif** | L0–L3 stems share the Ledger Cell contour (`1 → 5 → ♭2 → 1'`) as pedal / sparse ticks / full cell / compressed answer |
| **P3 Silence as tool** | Quieter L0; authored rests inside slam; post-PA hush baked into PA tails; win open-loop cuts into air |
| **Win / fail** | `win.chamber` resolves via cell 1→5; `win.queue_next` rising fourth cuts early; new `fail.reset` dry institutional restart cue |

Catalog version is **3**. `AudioDirector.on_fail_reset()` fires on chamber restart.

**This is still not production audio.** Compliance still forbids marketing these as “final mix.”

---

## Remaining debt (must clear before “final mix” / announce trailer)

### Authored asset debt (P0)

| ID | Debt | Why it still matters |
|---|---|---|
| **PAD-01** | Replace every stream under `game/echo_lattice/audio/**` with recorded / designed hybrids (paper, rust plate, chalk, transit PA) | Procedural phrase grammar is correct; material dictionary is not — ears still date the build as synth |
| **PAD-02** | Author Mirror Birth phrase (cue **B6**) + shared A0–A5 stems for trailer | Announce / 15s–30s cuts cannot ship DSP identity ([cue sheet §J P0](../VISION/AUDIO_1_0_CUE_SHEET.md)) |
| **PAD-03** | Author L0–L1 stems at minimum for silence-capped Identity wing | Chamber 0–2 must feel intentional hush + sparse cell, not generator HVAC |
| **PAD-04** | Author footsteps + warn as paper/chalk (drop `*_placeholder` filenames) | Continuous channel; first thing players hear |
| **PAD-05** | Author win open-loop (F1/F2) + PA attention/armed (E1/E3) | Addiction beat + institution must survive Music-mute |

### Wiring / polish debt

| ID | Debt | Notes |
|---|---|---|
| **PAD-06** | Reduce-motion slam should **truncate phrase at stage boundaries** (not play full 0.90s under a 50 ms visual stamp) | AUDIO_V3 §3.4; currently one streamed file plays in full |
| **PAD-07** | Optional staged oneshot callbacks synced to visual slam phases | Preferred if trailer needs stems; keep listener experience as one phrase |
| **PAD-08** | Warn hysteresis (UPGRADE P1-06) so `sfx.rewrite_warn` does not re-spam at dist=3 | Still open |
| **PAD-09** | Habit footstep metallic overtone layer at high tension | Bible §8 polish; generator still omits |
| **PAD-10** | Bias-colored habit cell tilts (AUDIO_V3 §4.3 optional) | Post-1.0 stretch |
| **PAD-11** | Drop or wire leftover catalog operators without live call sites | UPGRADE P4-04 |
| **PAD-12** | Credits / compliance line: remove “procedural placeholders” only after PAD-01 lands | COMPLIANCE C9 |

### Explicit non-debt (already OK)

- Bus layout, `AudioDirector`, silence caps, operator aliases, event IDs — keep stable.
- Do **not** re-run the placeholder generator over authored finals.
- Validate with `python3 tools/audio/validate_audio_events.py` after asset swaps.

---

## Acceptance gates still open

From AUDIO_V3 + cue sheet — unchecked until authored assets:

- [ ] Stranger can clap five-stage slam rhythm after Mirror Birth (headphones)
- [ ] Mute Music: phrase + telegraph + PA still teach the loop
- [ ] Chamber 0: Music digitally black
- [ ] Trailer uses the **same** phrase stems as in-game
- [ ] No public encode markets procedural output as final mix

---

## Regenerating the procedural lift (dev only)

```bash
python3 tools/audio/generate_echo_lattice_placeholders.py
python3 tools/audio/validate_audio_events.py
```
