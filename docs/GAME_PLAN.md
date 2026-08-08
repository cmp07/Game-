# Steam Desktop Game Plan

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Date:** August 2026  
**Goal:** Ship real desktop Steam games (Windows `.exe`, not browser) quickly at roughly **$0.99–$12**.

---

## Decision document (start here)

**Authoritative product decision doc:** [`docs/FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md)

That document contains:

1. A sourced **2026–27 next-wave prediction** (reactive authorship toys — generative *feel* without LLM worldgen).  
2. **Five fully written, pure-category game concepts** to build (4 forever systems/toys + 1 short vignette).  
3. Per-game loops, MVP/later systems, Godot milestone plans, prices, tags, comps, risks.

Do **not** treat older “tension → coin → idle” sequencing or Residue-only Game 1 recommendations as the decision authority anymore. Those remain useful *context* and *catalog alternatives*; the five concepts reconsider the full board.

---

## Hard rule: do not mash genres

Each Steam product is **one pure category**. No hybrid “first game” pitches (e.g. coin pusher + horror + idle + cards). Shared taste across games is fine; shared mechanics in one store page is not.

| Coin-machine games sell | Idle / particle tycoons sell | Tension vignettes sell | Reactive authorship toys sell |
|---|---|---|---|
| Arcade physics + payout dopamine | Automation / number-go-up over time | Short, clip-friendly stakes + readable rules | One verb → world visibly shaped by *you* (offline systems) |

Same “simple systems” family — **different loops, art, pacing, and marketing**.

---

## Name resolutions (from play history)

| You said | Means | Notes |
|---|---|---|
| Raccoin / rack a coin | **[RACCOIN: Coin Pusher Roguelike](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/)** | Coin-pusher + run upgrades; breakout 2026 title — **taste signal, not a clone target for the five** |
| Winrose | **[Windrose](https://store.steampowered.com/app/3041230/Windrose/)** *or* **[Wildfrost](https://store.steampowered.com/app/1811990/Wildfrost/)** | Scope / deckbuilder taste — not first products in the five |
| Rollerhalla | **[Brawlhalla](https://store.steampowered.com/app/291550/Brawlhalla/)** | Platform-fighter taste; wrong first product |
| Particool screenshots | **[Particul](https://store.steampowered.com/app/4273120/Particul/)** | Particle idle — catalog filler later, **not** mashed into Games 1–5 |

Condensed historical scores: [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md).

---

## The five (summary)

Full writeups: [`FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md).

| # | Working title | Pure category | Longevity |
|---|---|---|---|
| 1 | **Echo Lattice** | Adaptive labyrinth puzzle | Forever systems / UGC |
| 2 | **Edgewright** | Spatial edge-sculpting puzzle | Forever + editor |
| 3 | **Quench** | Thermal material physics puzzle | Forever + material packs |
| 4 | **Black Plinth** | Ex nihilo architecture toy | Forever toy / grammar packs |
| 5 | **Stillroom** | Acoustic tension vignette | Sharp short hit |

**Recommended first scaffold:** Echo Lattice or Edgewright (see decision gate in the five-games doc).

---

## Explicitly out of the five (still valid later catalog)

| Lane | Why deferred |
|---|---|
| Coin-machine (RACCOIN-adjacent) | Hot but clone-crowded; keep as separate later SKU if desired |
| Idle / particle tycoon (Particul-like) | Fast to code, modest ceiling; separate catalog product |
| Residue (habit-physics chambers) | Strong inventive alternate from generative synthesis — **not** merged into Echo Lattice |
| Full StS deckbuilder, RimWorld, Cities-depth, Palworld-scale, platform fighter | Scope / band traps |

---

## Avoid first (scope / market traps)

| Avoid as first product | Why |
|---|---|
| **RimWorld-depth colony sim** | Multi-year AI, content, UI; usually $20–$40 ambition |
| **Cities-depth city builder** | Content mountain; wrong price band for first ship |
| **Palworld-scale creature survival** | Open world + collection + combat (+ MP expectations) |
| **Minecraft-like survival craft** | Simplicity *analogy* only — do not clone |
| **Platform fighter** (Brawlhalla / “Rollerhalla”) | Netcode, cast, live ops; F2P giants dominate |
| **Full Slay the Spire deckbuilder** | Saturated; balance + card volume kills “fast” |
| **LLM / world-model runtime as the game** | Cost, consistency, gameslop stigma ([Haro AI Steam census](https://fragwyz.substack.com/p/three-years-of-ai-on-steam)) |
| **Genre mashups** | Explicitly out of scope |

---

## Tech stack (lean)

- **Engine:** [Godot 4](https://godotengine.org/) — desktop export, Steam-friendly, free, fast iteration.
- **Target:** Windows-first Steam build (real `.exe` + `.pck`); Mac/Linux optional later.
- **Not for v1:** Web/HTML5 as the primary product, multiplayer netcode, live-service economies, runtime LLM worldgen.

---

## Next steps

1. **User confirms** one of the five (or a documented alternate) via the decision gate in [`FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md).  
2. Write a **one-page GDD** for that product only.  
3. Godot 4 vertical slice (desktop) — one complete loop, no feature sprawl.  
4. Steamworks setup: page, tags, capsule art, **demo**, wishlist push.  
5. Price in-band; launch small; capture reviews → fund the next **separate** product.

---

## Related docs

- [`docs/FIVE_GAMES_TO_BUILD.md`](FIVE_GAMES_TO_BUILD.md) — **decision document** (prediction + five full concepts)  
- [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md) — condensed historical scores / comps  
- Sibling research PRs (trend map, inventiveness, generative reality, physics, seeds) — see open PRs on the repo  
- Repo layout: `game/` (Godot), `docs/` (plans), `research/` (scratch notes)
