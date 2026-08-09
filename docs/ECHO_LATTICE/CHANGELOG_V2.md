# Echo Lattice — CHANGELOG vs playable v1

**Branch:** `cursor/echo-lattice-v2-playable-3621`  
**Baseline:** PR #48 / `cursor/echo-lattice-playable` (10-chamber vertical slice)

## Headline

v2 is one merged, playable Godot 4.3 build: full loop **menu → play → rewrite telegraph → win (stars) → next**, with daily challenge, Field Ledger art direction, Godot-native juice, Balance v2 stars, and Audio v2 hooks.

## Provenance

| Source | What landed |
|---|---|
| Playable v1 (#48) | Base game loop, chambers I–X, self-test, export presets |
| Balance v2 (#53) | `balance_v2.json`, `StarRater`, `BalanceTuning`, act windows |
| Audio v2 (#54) | Bus layout, adaptive stems, operator stingers, PA, `AudioDirector` |
| Art (#44) | Palette + placeholder tiles/decals + art bible |
| Juice (#46) | Design doc only — **Vite/TS juice reimplemented in Godot** (`Juice` autoload) |
| Meta (#42) | Daily seed + stars persistence (spec-driven, wired into playable shell) |
| Content v2 | No dedicated content-v2 branch — expanded in-integrator to **20 chambers** |

## Player-facing upgrades vs v1

1. **20 authored chambers** (was 10), acts SEED→GROWTH→PRISM, new `invert` transform.
2. **Rewrite telegraph** — cadmium corner-ticks preview where echoes will land; warn near checkpoints.
3. **Juice in Godot** — trauma shake, hitstop, rewrite flash, particle bursts on commit.
4. **Stars (1–3★)** via Balance v2 thresholds vs BFS par; shown on clear + persisted.
5. **Daily Challenge** — five seeded chambers / UTC day; daily best stars on menu.
6. **Field Ledger look** — art-bible palette (paper/ink/rust/slate) replacing v1 neon subway.
7. **Audio v2 wired** — footsteps, rewrite/warn stingers, PA ticks, win + wing-clear path.
8. **Version** `0.2.0`; end screen reports wing stars + habit signature.

## Loop

`Menu (Start | Continue | Daily) → Chamber → Checkpoint rewrite (telegraph → punch) → Goal → Stars clear → Next → Wing clear`

## Validation

```bash
cd game/echo_lattice
godot --headless --path . -- --selftest
python3 tests/test_balance_v2.py
python3 ../../tools/audio/validate_audio_events.py
```

## Known gaps (unchanged / deferred)

Steam Cloud/achievements, Workshop editor, full VO, cross-run ghost replay, controller glyphs, localisation.
