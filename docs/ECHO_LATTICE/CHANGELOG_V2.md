# Echo Lattice — CHANGELOG vs playable v1

**Branch:** `cursor/echo-lattice-v2-complete-562a`  
**Baseline:** PR #48 / `cursor/echo-lattice-playable` (10-chamber vertical slice)

## Headline

v2 **complete** is one merged Godot 4.3 build: elevated playable loop (**menu → play → rewrite slam → win (stars) → next**), **35 campaign chambers + 4 hard variants** across four acts, Field Ledger VISUAL v2 (ink on paper), juice, daily challenge, and Audio v2 hooks.

## Provenance

| Source | What landed |
|---|---|
| Playable v2 (#58) | Loop, juice, stars, daily, self-test, Balance/Audio wiring |
| Content v2 (#61) | 39 authored chambers, `acts.json`, `ChamberLoader`, content bible |
| VISUAL v2 / art (#55) | Paper/ink/rust materials, origami rewrite slam, Steam-hit menu, ArtKit/Palette |
| Balance v2 (#53) | `balance_v2.json`, `StarRater`, act windows |
| Audio v2 (#54) | Buses, stems, stingers, PA, `AudioDirector` |
| Juice (#46) | Design — reimplemented in Godot (`Juice` autoload) |
| Meta (#42) | Daily seed + stars persistence |

## Player-facing upgrades vs v1

1. **35 campaign chambers** (39 authored incl. hard) across Induction → Reflection → Pressure → Mastery.
2. **Field Ledger look** — no purple boxes; paper page, ink walls, rust fossils, Steam-hit menu.
3. **Origami rewrite slam** + cadmium telegraph foreshadow + juice punch.
4. **Stars (1–3★)** vs BFS par; persisted bests.
5. **Daily Challenge** — five seeded chambers / UTC day.
6. **JSON content pipeline** — schema, grammar, validators, `ChamberBook` façade.
7. **Version** `0.2.0`.

## Loop

`Menu (Start | Continue | Daily) → Chamber → Checkpoint rewrite (telegraph → slam) → Goal → Stars clear → Next → Wing clear`

## Screenshots

See `docs/ECHO_LATTICE/screenshots/v2_complete/` + `TOUR.md`.

## Validation

```bash
cd game/echo_lattice
godot --headless --path . -- --selftest
python3 tests/validate_chambers.py
python3 tests/test_balance_v2.py
python3 tests/check_deck_bindings.py
python3 ../../tools/audio/validate_audio_events.py
./tools/capture_v2_complete.sh
# With a display / Godot window:
godot --path . -- --deck-layout-check
```

## Steam Deck prep

See [`docs/RELEASE/STEAM_DECK.md`](../RELEASE/STEAM_DECK.md) — controller glyphs, 16:10 / 1280×800 layout check, TDP/FPS defaults, native Linux preferred over Proton.

## Known gaps (unchanged / deferred)

Steam Cloud/achievements, Workshop editor, full VO, cross-run ghost replay, localisation.
