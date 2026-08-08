# Steam Desktop Game Plan

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Date:** August 2026  
**Goal:** Ship real desktop Steam games (Windows `.exe`, not browser) at roughly **$0.99–$12**, with AAA-indie quality and clear production ownership — not prototype slop, not fake AAA scope.

---

## LOCKED — Game 1 is Echo Lattice

| Field | Value |
|---|---|
| **Status** | **LOCKED** |
| **Product** | **Echo Lattice** |
| **Pure category** | Adaptive labyrinth puzzle (reactive authorship toy) |
| **Pitch** | A labyrinth that rebuilds from your last thirty moves — you escape by rewriting your own habits, not by beating RNG. |
| **Production constitution** | [`docs/ECHO_LATTICE/00_PRODUCTION_BIBLE.md`](ECHO_LATTICE/00_PRODUCTION_BIBLE.md) |
| **Concept source** | [`docs/FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md) § Game 1 |
| **Engine** | Godot 4 · Windows-first Steam `.exe` |
| **Price band** | **$5.99–$8.99** |

The prior decision gate (tension vs coin vs idle, or “pick one of five”) is **closed** for Game 1. Do not scaffold conflicting GDDs. Do not mash Residue, coin-pusher, idle, or horror vignette systems into this Steam page.

Parallel agents implement against the Production Bible ownership map. **No gameplay implementation in the production-lock PR** — standards and specs coordination only until Core/Scaffold lanes open.

---

## Decision documents

| Doc | Role |
|---|---|
| [`docs/ECHO_LATTICE/00_PRODUCTION_BIBLE.md`](ECHO_LATTICE/00_PRODUCTION_BIBLE.md) | **Production authority** for Echo Lattice (vision, non-goals, quality bar, milestones, ownership, DoD) |
| [`docs/FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md) | Five-product concept archive + next-wave prediction; Game 1 text is source material now locked |
| [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md) | Historical category scores (tension / coin / idle framing) — context only |

Older “tension → coin → idle” sequencing and Residue-only Game 1 recommendations are **superseded as decision authority**. They remain useful research context and later-catalog ideas.

---

## Hard rule: do not mash genres

Each Steam product is **one pure category**. No hybrid “first game” pitches (e.g. coin pusher + horror + idle + cards). Shared taste across games is fine; shared mechanics in one store page is not.

| Coin-machine games sell | Idle / particle tycoons sell | Tension vignettes sell | Reactive authorship toys sell |
|---|---|---|---|
| Arcade physics + payout dopamine | Automation / number-go-up over time | Short, clip-friendly stakes + readable rules | One verb → world visibly shaped by *you* (offline systems) |

---

## Name resolutions (from play history)

| You said | Means | Notes |
|---|---|---|
| Raccoin / rack a coin | **[RACCOIN: Coin Pusher Roguelike](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/)** | Taste signal — **not** a clone target for Echo Lattice |
| Winrose | **[Windrose](https://store.steampowered.com/app/3041230/Windrose/)** *or* **[Wildfrost](https://store.steampowered.com/app/1811990/Wildfrost/)** | Scope / deckbuilder taste — not Game 1 |
| Rollerhalla | **[Brawlhalla](https://store.steampowered.com/app/291550/Brawlhalla/)** | Platform-fighter taste; wrong product |
| Particool screenshots | **[Particul](https://store.steampowered.com/app/4273120/Particul/)** | Particle idle — later catalog, **not** mashed into Echo Lattice |

---

## Catalog sequence (separate Steam products)

| Slot | Product | Pure category | Status |
|---|---|---|---|
| **Game 1** | **Echo Lattice** | Adaptive labyrinth puzzle | **LOCKED — in production coordination** |
| Game 2 | Edgewright | Spatial edge-sculpting puzzle | Catalog (after Game 1 lessons) |
| Game 3 | Quench | Thermal material physics puzzle | Catalog |
| Game 4 | Black Plinth | Ex nihilo architecture toy | Catalog |
| Game 5 | Stillroom | Acoustic tension vignette | Catalog / wildcard short hit |
| Alternate | Residue | Habit-physics chambers | Documented alternate — **do not merge** into Echo Lattice |
| Later | Coin-machine / idle particle | Arcade payout / automation | Deferred separate SKUs |

Full concept writeups: [`docs/FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md).

---

## Echo Lattice — spine (restated)

- **Fantasy:** Same seed, different player → different building. Mastery is leaving kinder corridors behind.
- **Learn in 30s:** Four directions + one interact; first rewrite mirrors your path into walls.
- **Loop:** Step + ghost buffer → checkpoint rewrite → key/door → wing of chambers → unlock transforms (mirror, rotate, thicken, invert).
- **Offline generative feel:** Move buffer → hash → authored tile grammar. No LLM worldgen.
- **MVP floor:** Move buffer, 1 rewrite grammar, ~12 handmade chambers, ghost replay, undo, Steam demo of first wing, offline save.
- **Milestones:** Alpha (vertical slice) → Demo (first wing) → 1.0 — see Production Bible DoDs.
- **Quality bar:** AAA-indie readability, determinism trust, juice, a11y, Steam craft — see Production Bible §4.

---

## Explicitly out of Game 1

| Out | Why |
|---|---|
| Coin-machine / slot-debt / particle idle | Separate SKUs; crowded or wrong loop |
| Residue physics chambers on this page | Sibling alternate — mashup ban |
| LLM / world-model runtime as the game | Gameslop risk; offline systems only |
| Multiplayer-first friendslop | Wrong product |
| Open sandbox / editor-before-chambers | Chambers first |
| Fake AAA scope / prototype-slop demos | Process yes, content mountain no |

---

## Avoid early (scope / market traps)

| Avoid | Why |
|---|---|
| RimWorld-depth colony / Cities-depth builder / Palworld-scale survival | Multi-year / wrong band |
| Minecraft-like survival craft | Simplicity analogy only — do not clone |
| Platform fighter / full StS deckbuilder | Netcode/cast or saturation + content volume |
| Genre mashups | Explicitly out of scope |

---

## Tech stack (lean)

- **Engine:** [Godot 4](https://godotengine.org/) — desktop export, Steam-friendly, free, fast iteration.
- **Target:** Windows-first Steam build (real `.exe` + `.pck`); Mac/Linux optional later.
- **Not for v1:** Web/HTML5 as the primary product, multiplayer netcode, live-service economies, runtime LLM worldgen.

---

## Next steps (post-lock)

1. Land sibling specs under `docs/ECHO_LATTICE/` per ownership map (GDD, Systems, Tech, Art, Audio, QA, Steam, …).
2. Godot 4 Alpha vertical slice — one complete rewrite loop, no feature sprawl.
3. Steamworks: page, tags, capsule art, **demo** = first wing, wishlist push.
4. Ship 1.0 in-band; capture reviews → fund the next **separate** product (Edgewright / Quench / etc.).

---

## Related docs

- [`docs/ECHO_LATTICE/00_PRODUCTION_BIBLE.md`](ECHO_LATTICE/00_PRODUCTION_BIBLE.md) — **start here for production**
- [`docs/FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md) — five concepts + prediction
- [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md) — historical scores / comps
- Sibling research PRs (trend map, inventiveness, generative reality, physics, seeds) — see open PRs on the repo
- Repo layout: `game/` (Godot), `docs/` (plans + Echo Lattice specs), `research/` (scratch notes)
