# Steam Desktop Game Plan (REVISED)

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Date:** August 2026 (revised)  
**Goal:** Ship real desktop Steam games (Windows `.exe`, not browser) quickly at **$2.99–$9.99**.  
**Market basis:** [`docs/research/MARKET_DEEP_DIVE.md`](research/MARKET_DEEP_DIVE.md)

---

## Hard rule: do not mash genres

Each Steam product is **one pure category**. No hybrid first-game pitches (e.g. coin pusher + horror + idle + cards). Shared taste across games is fine; shared mechanics on one store page is not.

---

## What changed vs the old plan

| Slot | **Old plan** | **Revised (market-first)** | Why |
|---|---|---|---|
| **Game 1** | Tension / horror vignette (Buckshot-*format*) | **Idle / incremental** | Idle is Steam “Little League” for solo ship practice; Buckshot-format fatigue is rising; no netcode |
| **Game 2** | Coin-machine (RACCOIN lane) | **Systems / automation** (TFWR lane) | 2025 automation breakouts (esp. TFWR ~$9.99) show a clearer offline ceiling than thin coin clones |
| **Game 3** | Idle / particle tycoon (Particul-like) | **Non-poker synergy toy** *or* coin-machine | Idle moved to Game 1; Game 3 picks the remaining taste lane after two ships |
| Stack | Godot 4 desktop | **Unchanged** — Godot 4, Windows-first Steam | — |

**Still true from the old plan:** no mashups; avoid RimWorld/Cities/Palworld/platform-fighter first; Particul/RACCOIN/Buckshot are comps, not templates to copy.

**Explicitly demoted:** “Build a Buckshot-like tension vignette first.” Short original horror can still be a later catalog title — not the default Game 1.

---

## Name resolutions (from play history)

| You said | Means | Notes |
|---|---|---|
| Raccoin / rack a coin | **[RACCOIN: Coin Pusher Roguelike](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/)** | Coin-pusher + run upgrades; breakout 2026 title — **Game 3 option**, not mashed into idle |
| Winrose | **[Windrose](https://store.steampowered.com/app/3041230/Windrose/)** *or* **[Wildfrost](https://store.steampowered.com/app/1811990/Wildfrost/)** | Scope / deckbuilder taste signals — not Game 1 |
| Rollerhalla | **[Brawlhalla](https://store.steampowered.com/app/291550/Brawlhalla/)** | Platform-fighter — avoid early |
| Particool screenshots | **[Particul](https://store.steampowered.com/app/4273120/Particul/)** | Particle mine → sell → automate — **aligns with revised Game 1** |

Full market write-up: [`docs/research/MARKET_DEEP_DIVE.md`](research/MARKET_DEEP_DIVE.md). Condensed scores: [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md).

---

## Ranking for FAST first ship (pure categories)

Ranked for solo/small team + desktop Steam + **$2.99–$9.99**.

| Priority | Pure category | Verdict |
|---|---|---|
| **1** | **Idle / incremental** | **Build first** — fastest honest ship + Little League fit |
| **2** | **Systems / automation** (TFWR-adjacent, scoped) | **Game 2** — higher ceiling, offline SP |
| **3** | Non-poker synergy toy *or* coin-machine | **Game 3** — pick by taste after reviews from 1–2 |
| — | Short horror (original premise only) | Later catalog; **not** Buckshot clones |
| — | Organization / tidy sims | Crowded 2026; optional filler |
| — | Co-op friendslop | Highest upside; **netcode** → not Game 1 |
| — | StS clones, VS clones, open-world | **Do not make** in this band as first ships |

---

## Multi-game path (separate Steam products)

### Game 1 — Idle / incremental (**recommended first**)

- **Pure genre:** Idle / incremental only. No horror stakes, no coin physics, no card synergies on the same page.
- **Loop sketch:** gather → sell/convert → unlock automation → prestige/ascend. Visible juice (particles, layout, machines) preferred over pure UI clicker.
- **Comps:** [Particul](https://store.steampowered.com/app/4273120/Particul/) (~$1.99); broader idle boom as practice league ([Zukowski / GamesRadar](https://www.gamesradar.com/games/roguelike/steam-expert-advises-devs-stick-to-the-little-league-section-of-idle-games-and-friendslop-before-attempting-anything-like-binding-of-isaac-or-mewgenics-then-you-can-make-your-dream/)).
- **Price band:** **$2.99–$4.99**
- **Why first (vs old vignette plan):**
  1. Solo-friendly offline SP — no lobbies/netcode.
  2. Matches stated Particul interest without waiting for “Game 3.”
  3. Market experts explicitly place idle in Steam’s training league; friendslop is the other half of that advice but fails the solo-netcode test.
  4. Buckshot-*format* horror is fatigued; original horror is still possible later.

### Game 2 — Systems / automation

- Standalone automation fantasy. Learn from [The Farmer Was Replaced](https://store.steampowered.com/app/2060160/The_Farmer_Was_Replaced/) (~$9.99) demand — do **not** clone its Python drone 1:1.
- Prefer a scoped hook: visual blocks, tiny opcode language, or one-biome factory — **not** Factorio/Satisfactory scope.
- Target **$6.99–$9.99** after Game 1 taught Steam page, demo, and patch habits.

### Game 3 — Synergy toy *or* coin-machine (choose one)

Pick **one** pure lane after Games 1–2:

| Option A | Option B |
|---|---|
| **Non-poker synergy toy** — Balatro-like score engines on dice/tiles/memory/etc. ([Balatro-like context](https://www.howtogeek.com/how-balatro-spawned-its-own-genre/)) | **Coin-machine** — arcade pusher/payout fantasy; comps [RACCOIN](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/), [The Coin Game](https://store.steampowered.com/app/598980/The_Coin_Game/) |

Price roughly **$4.99–$9.99**. Never combine A+B.

### Later (not Games 1–3)

- Original short horror vignette (**non-roulette** premise) if you want clip-driven SP horror.
- Friendslop co-op only after deliberately investing in netcode.
- Classic TD as mid-scope evergreen.
- Base-building / colony / city only after several small paid ships.

---

## Avoid first (scope / market traps)

| Avoid as first product | Why |
|---|---|
| **Buckshot Roulette clones** | Format fatigue; old Game 1 default demoted for this reason |
| **Slay the Spire clones** | Saturated; balance + card volume |
| **Vampire Survivors clones** | Crowded survivors-like wave |
| **Open-world / survival-crafting** | Wrong scope and price expectations |
| **Friendslop as Game 1** | Upside real; multiplayer is the product |
| **RimWorld / Cities / Palworld-scale** | Multi-year content mountains |
| **Platform fighter** (Brawlhalla / “Rollerhalla”) | Netcode, cast, F2P giants |
| **Genre mashups** | Explicitly out of scope |

---

## Decision gate (user must confirm)

**Recommended default (revised):** Game 1 = **idle / incremental** (pure), Godot 4 desktop Steam.

Before production starts, confirm one of:

1. **Game 1 — idle / incremental** (recommended), or  
2. **Start with systems / automation** instead (old “Game 2” first — higher design bar), or  
3. **Revert to short original horror** (old plan) — only with a **non-Buckshot** premise.

Until that choice is locked, do not scaffold conflicting GDDs or mash systems.

---

## Tech stack (lean)

- **Engine:** [Godot 4](https://godotengine.org/) — desktop export, Steam-friendly, free, fast iteration.
- **Target:** Windows-first Steam build (real `.exe` + `.pck`); Mac/Linux optional later.
- **Not for v1:** Web/HTML5 as the primary product, multiplayer netcode, live-service economies.

---

## Next steps

1. **User confirms** Game 1 = idle / incremental (or explicitly overrides).
2. Write a **one-page GDD** for that product only (loop, prestige, session length, art direction, original hook).
3. Godot 4 vertical slice (desktop) — one complete idle loop, no feature sprawl.
4. Steamworks setup: page, tags, capsule art, **demo**, wishlist push.
5. Price in-band; launch small; capture reviews → fund **Game 2 automation** as a separate app.

---

## Related docs

- [`docs/research/MARKET_DEEP_DIVE.md`](research/MARKET_DEEP_DIVE.md) — market-first 2025–2026 Steam analysis  
- [`docs/research/CATEGORY_RANKING.md`](research/CATEGORY_RANKING.md) — condensed scores / comps  
- Repo layout: `game/` (Godot), `docs/` (plans), `research/` (scratch notes)
