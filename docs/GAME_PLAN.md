# Steam Desktop Game Plan

**Repo:** [cmp07/sandpile-tycoon](https://github.com/cmp07/sandpile-tycoon)  
**Date:** August 2026  
**Goal:** Ship real desktop Steam games (Windows `.exe`, not browser) quickly at **$0.99–$10**.

---

## Hard rule: do not mash genres

Each Steam product is **one pure category**. No hybrid “first game” pitches (e.g. coin pusher + horror + idle + cards). Shared taste across games is fine; shared mechanics in one store page is not.

| Coin-machine games sell | Idle / particle tycoons sell | Tension vignettes sell |
|---|---|---|
| Arcade physics + payout dopamine | Automation / number-go-up over time | Short, clip-friendly stakes + readable rules |

Same “simple systems” family — **different loops, art, pacing, and marketing**.

---

## Name resolutions (from play history)

| You said | Means | Notes |
|---|---|---|
| Raccoin / rack a coin | **[RACCOIN: Coin Pusher Roguelike](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/)** | Coin-pusher + run upgrades; breakout 2026 title |
| Winrose | **[Windrose](https://store.steampowered.com/app/3041230/Windrose/)** *or* **[Wildfrost](https://store.steampowered.com/app/1811990/Wildfrost/)** | Windrose = pirate survival (scope signal, not a first game). Wildfrost = deckbuilder (phonetic fit among StS-likes) |
| Rollerhalla | **[Brawlhalla](https://store.steampowered.com/app/291550/Brawlhalla/)** | No Steam title “Rollerhalla”; platform-fighter taste, wrong first product |
| Particool screenshots | **[Particul](https://store.steampowered.com/app/4273120/Particul/)** | $1.99 particle mine → sell → automate idle |

Full scores and comps: [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md).  
Inventiveness by dimension/presentation: [`docs/research/DIMENSION_CONCEPT_MAP.md`](research/DIMENSION_CONCEPT_MAP.md).

---

## Ranking for FAST first ship (pure categories)

Ranked for solo/small team + desktop Steam + $0.99–$10.

| Priority | Pure category | Verdict |
|---|---|---|
| **1** | Tension / horror vignette (Buckshot-like **format**) | **Build first** — fastest ship + proven ~$3 band |
| **2** | Coin machine (RACCOIN / Coin Game lane) | **Game 2** — hot market; post-RACCOIN clones struggle |
| **3** | Idle / particle tycoon (Particul-like) | **Game 3** — fastest to code; solid, smaller ceiling |
| **4** | Classic tower defense | Strong later evergreen |
| — | Offline geo / trivia | Maybe (not Street View) |
| — | Full StS deckbuilder, RimWorld, Cities-depth, Palworld-scale, platform fighter | **Do not make first** |

---

## Multi-game path (separate Steam products)

### Game 1 — Tension / horror vignette (recommended first)

- **Format:** Short paid vignette — one space, escalating pressure, readable rules, replay via modifiers/challenges.
- **Premise:** **Original** ritual / stakes / antagonist. Learn from Buckshot’s *structure* (clip length, tension, demoability) — do **not** clone shotgun roulette.
- **Price band:** **$2.99–$7.99**
- **Why first:** Smallest content mountain, strong short-form discovery, proven breakouts in-band ([Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) ~$2.99).
- **Adjacent taste (separate category):** [CloverPit](https://store.steampowered.com/app/3314790/CloverPit/) is slot/debt tension — signal for *stakes*, not a mash into Game 1.

### Game 2 — Coin-machine game

- Standalone arcade coin-pusher / coin-machine fantasy.
- Comps: [RACCOIN](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/), [The Coin Game](https://store.steampowered.com/app/598980/The_Coin_Game/).
- Differentiate with a sharp hook + demo; treat RACCOIN-scale returns as unlikely for a thin clone.
- Target roughly **$5–$10** lean MVP after Game 1 lessons.

### Game 3 — Idle / particle tycoon (Particul-like)

- Standalone particle/automation tycoon. This is where Particul-style screenshots belong — **not** Game 1.
- Comp: [Particul](https://store.steampowered.com/app/4273120/Particul/) (~$1.99).
- Target **$1.99–$4.99**; catalog filler and systems practice; distinct loop from Game 2.

### Later (not Games 1–3)

Tower defense if you want a mid-scope evergreen. Base-building / colony / city only after several small paid ships.

---

## Avoid first (scope / market traps)

| Avoid as first product | Why |
|---|---|
| **RimWorld-depth colony sim** | Multi-year AI, content, UI; usually $20–$40 ambition |
| **Cities-depth city builder** | Content mountain; wrong price band for first ship |
| **Palworld-scale creature survival** | Open world + collection + combat (+ MP expectations) |
| **Platform fighter** (Brawlhalla / “Rollerhalla”) | Netcode, cast, live ops; F2P giants dominate |
| **Full Slay the Spire deckbuilder** | Saturated; balance + card volume kills “fast”; often priced above band |
| **Genre mashups** | Explicitly out of scope |

Windrose-scale survival is a **taste signal**, not a schedule for product #1.

---

## Decision gate (user must confirm)

**Recommended default:** Game 1 = tension/horror vignette with an original premise.

Before production starts, confirm one of:

1. **Game 1 — tension/horror vignette** (recommended), or  
2. **Start with coin-machine** instead (Game 2 first), or  
3. **Start with idle/particle** instead (Game 3 first — closest to current Particul interest / this repo’s original scaffold name).

Until that choice is locked, do not scaffold conflicting GDDs or mash systems.

---

## Tech stack (lean)

- **Engine:** [Godot 4](https://godotengine.org/) — desktop export, Steam-friendly, free, fast iteration.
- **Target:** Windows-first Steam build (real `.exe` + `.pck`); Mac/Linux optional later.
- **Not for v1:** Web/HTML5 as the primary product, multiplayer netcode, live-service economies.

---

## Next steps

1. **User confirms** Game 1 lane (tension vs coin vs idle).
2. Write a **one-page GDD** for that product only (loop, win/lose, session length, art direction, original hook).
3. Godot 4 vertical slice (desktop) — one complete loop, no feature sprawl.
4. Steamworks setup: page, tags, capsule art, **demo**, wishlist push.
5. Price in-band; launch small; capture reviews → fund the next **separate** product.

---

## Related docs

- [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md) — condensed scores, comps, Steam links  
- [`docs/research/DIMENSION_CONCEPT_MAP.md`](research/DIMENSION_CONCEPT_MAP.md) — 1D→3D / UI / diorama / desktop-hybrid concept map  
- Repo layout: `game/` (Godot), `docs/` (plans), `research/` (scratch notes)
