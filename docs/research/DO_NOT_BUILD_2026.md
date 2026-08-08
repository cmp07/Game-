# What NOT to Build in Late 2026

**Repo:** [cmp07/Game-](https://github.com/cmp07/game-)  
**Compiled:** August 2026  
**Lens:** Solo / small team wanting a **living, simple** paid Steam desktop game (~$0.99–$10), not a studio career piece.  
**Stance:** Adversarial — this document is a kill list. It is deliberately biased toward *declining* ideas that look tempting in Discord pitches and AI brainstorms.

Companion docs (pro-build / ranking): [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) · [`../GAME_PLAN.md`](../GAME_PLAN.md). Sibling deep dives (same research wave): AI gameslop, Steam indie trend map, creation-genre dive — cited where they converge.

---

## Executive kill list

| Trap | One-line reason | Small-team risk |
|---|---|---|
| **Clone graveyards** | Hits mint a tag; the next 200 reskins compete for the same week of attention and lose | High |
| **AI / gameslop store products** | ~31% of 2026 Steam releases disclose AI; they convert worse and train buyers to bounce | High |
| **Overscoped sims** | RimWorld / Cities / Palworld fantasies are multi-year content mountains priced above your band | Existential |
| **Saturated tags with hungry *median* failure** | Tag demand ≠ your odds; cozy / idle / Survivors-like / StS-like / Buckshot-format supply is brutal | High |

**Living simple game test:** If the pitch needs *more systems than verbs*, *more content than one readable loop*, or *“like X but…”* as the store sentence — kill it for Game 1.

---

## Macro context (why the traps bite harder now)

Steam is not “dead for indies.” It is **hit-skewed and release-flooded**.

| Signal (order-of-magnitude) | Figure | Source |
|---|---|---|
| Steam releases 2025 | ~19.6k–21k (trackers disagree; all say record / near-record) | Epiction (~19,606); Indie Launch Lab (~21,273); Alinea-derived ~20k |
| Median revenue (all new releases) | ~$250–$320 | Epiction ~$318; Steam Paradox / Gamalytic chain ~$249 |
| Near-zero traction | ~half under ~10 reviews; ~28% zero reviews in AI census window | Epiction; Haro census |
| Hit concentration | Top ~1% ≈ ~94% of estimated revenue; ~300 titles >$1M in 2025 | Haro; Alinea via trend coverage |
| AI-disclosed share of *new* releases | ~10.9% (2024) → ~19.9% (2025) → ~**30.8%** (2026 YTD) | Sulka Haro, full census ~53.6k titles |
| AI share of monthly *growth* | ~60–90% of release growth is AI-flagged | Same |
| AI vs non-AI modest success (≥100 reviews) | AI reaches that tier at ~**55%** the non-AI rate (flat ~2 years) | Same |

Implication for a living simple game: you are not competing with “19,000 peers equally.” You are competing with **discovery noise** (including gameslop) *and* with a handful of legible hits that suck attention. The failure modes below are how small teams volunteer to join the ghost market.

---

## 1. Clone graveyards

### 1.1 Pattern

1. A breakout invents (or crystallizes) a legible fantasy at a fair price.  
2. Press and store tags rename the pile (“Survivors-like” → Steam **Bullet Heaven**; “Balatro-like”; “Lethal Company-like” / friendslop).  
3. Hundreds of near-copies ship in the next 12–24 months.  
4. A few differentiated successors win; the median clone dies in Early Access or the discount bin.

This is not new (Doom-likes, Souls-likes). What *is* new for late 2026 is **how cheaply** a thin clone can be generated and how fast players learn to smell “format clone” in trailers and Next Fest hubs.

### 1.2 Active graveyards (do not enter as a thin clone)

| Graveyard | Breakout that minted demand | Why a small team dies here | Evidence anchors |
|---|---|---|---|
| **Bullet Heaven / Survivors-like** | Vampire Survivors (~$5, enormous review pile) | Steam **canonized the tag** (May 2026); weekly releases; reskins called out as trash by genre curators | Steam Bullet Heaven tag; GamesRadar / TweakTown tag coverage; Choost “clone graveyard is enormous” |
| **Balatro-likes / number-go-up toys** | Balatro (2024) | Next Fest repeatedly “flooded” with poker + non-poker multiplier toys; only sharp *verb* invents survive | No Small Games Next Fest roundups; Nexus Titan Feb 2026 fest note; press “long line of Balatro clones” |
| **Buckshot-format vignettes** | Buckshot Roulette (~$2.99) | Format fatigue; reviewers already name “Buckshot clones” as a known pile | Repo market dive; CloverPit / horror clone commentary |
| **StS deckbuilder clones** | Slay the Spire (+ StS2 gravity in 2026) | Card volume + balance kills “fast”; ceiling real, median brutal | Repo `CATEGORY_RANKING`; StS2 review turbulence coverage |
| **Coin-pusher after RACCOIN** | RACCOIN (100k+ copies day-1 reports) | Heat is real; thin physics clones inherit RNG complaints without the breakout novelty | RACCOIN launch coverage; repo Game 2 warning |
| **Lethal Company skin-swaps** | Lethal Company → R.E.P.O. / PEAK wave | Audience is hungry for *new friend toys*, not another flashlight scavenger with different monsters | Friendslop analysis (Zukowski); Epiction 2025 hits |

### 1.3 Clone vs. invent (the only escape hatch)

Clones that work change the **verb**, **failure mode**, or **social contract** — not the sprites.

| Fail (graveyard) | Pass (same family, different product) |
|---|---|
| “Vampire Survivors but cyberpunk sprites” | Auto-attack loop transplanted into a *different* structure (e.g. deck/dungeon hybrid with a new decision layer) — still hard; still not Game 1 unless the hook is original |
| “Balatro but poker art” | Synergy toy with a non-poker base verb (still crowded — needs a crystal-clear demo in 30 seconds) |
| “Buckshot but different gun” | Short tension vignette with **original stakes / ritual / antagonist** |
| “Lethal Company but ducks” | Only if the *physics/social joke* is the product and you can ship netcode — usually wrong for first paid solo ship |

**Repo rule (unchanged):** learn structure from hits; do **not** ship format clones. See [`GAME_PLAN.md`](../GAME_PLAN.md).

### 1.4 Special case: friendslop is not “saturated,” but still a trap for *this* team

Chris Zukowski’s mid-2026 read: friendslop audience is **hungry** (rolling peaks to ~350k concurrent across titles; hits take ~50% share then fade in months). Release *count* is the wrong saturation metric — idle had **1,087** 2026 releases and still produced ~$4M outliers.

That does **not** mean “build friendslop as Game 1.” For a small team optimizing a living *simple* **first** product:

- Multiplayer is the product (netcode, voice, session UX, cheat/grief edges).  
- Hits are stream-native chaos toys; thin clones of last quarter’s PEAK/R.E.P.O. fantasy die quietly.  
- Wrong stack for a Godot Windows `.exe` catalog starter if the goal is a fast pure single-player loop.

**Verdict:** Do not build Lethal Company / PEAK / R.E.P.O. clones as Game 1. Revisit co-op only after single-player Steam craft exists.

---

## 2. AI slop / gameslop (do not ship a content-farm product)

### 2.1 Definitions that matter

- **AI slop** — high-volume generative media with low craft/intent (wider internet; Word-of-the-Year discourse in 2025).  
- **Gameslop** — Steam specialization: Midjourney capsules, LLM blurbs, asset-flip loops, no authorial POV — shipped because tools made *something* possible.

**Tool use ≠ slop. Absence of taste = slop.** Coding assistants and other efficiency tools are explicitly **out of scope** for Steam’s Jan 2026 disclosure rewrite (player-consumed content is in scope).

### 2.2 What the census says (not vibes)

Sulka Haro’s mid-2023→mid-2026 census (~53,597 Games-category releases):

- AI disclosure share climbed to ~**one in three** new 2026 releases.  
- Non-AI launches grew modestly (~1,030 → ~1,320/month); AI-flagged launches grew to ~**530/month**.  
- Economics stayed hit-driven; AI’s rising sales share is largely a **volume** story.  
- Flops skew toward bare AI-art disclosures (median ~13 words; 72% of flopped AI games mention AI art).  
- AI-native *gameplay* is a tiny minority of ~9,400+ flagged titles.

Secondary controlled analysis (Game Oracle / Ross Burton, paid 2025 releases): AI disclosure associated with ~**53%** fewer first-month reviews after controls — stigma is real for games that *would* have had a chance.

GameDiscoverCo Steam Fan Snapshot (Jun–Jul 2026, ~3.8k engaged fans): ~31% negative toward buying AI-disclosed games; **8%** hard boycott; ~89% at least notice the disclosure block; freeform rejects AI replacing art/writing/voice.

### 2.3 Kill list — AI product patterns

| Do NOT build / ship | Why |
|---|---|
| Store page led by generative capsule/header art with artifacts | Instant gameslop pattern-match; trailer amplifies it |
| “Prompt-to-product” loop with no human design thesis | Answers “can we generate?” not “what fantasy do they buy?” |
| LLM-written store copy + keyword stuffing | Looks like the flood; harms wishlist conversion |
| Runtime generative NPC soup as a *first* product without guardrails, fantasy, and craft | Disclosure + guardrails + cost + trust; exceptions are not a plan |
| Hiding player-facing AI | Jan 2026 rewrite + player outrage risk > disclosure stigma for mid-profile launches |
| Using AI to *design* the game (homogeneous mechanics) | Gameslop feel even when art is OK |

### 2.4 Allowed vs forbidden for *this* repo (operational)

| Use | Do it? | Notes |
|---|---|---|
| Code helpers, debugging, internal tools | Yes | No disclosure under Jan 2026 efficiency carve-out |
| Player-facing gen art/audio/text that ships | Default **no** for Game 1 | Atmosphere-sensitive lanes punish this hardest |
| Marketing / capsule AI art | Default **no** | Highest stigma surface |
| AI as the *mechanic* of an inventive toy | Only as a separate product thesis | Not a mash into idle/coin/vignette Game 1 |

Longer treatment: sibling report `AI_STEAM_GAMESLOP_REPORT.md` (branch research wave).

---

## 3. Overscoped sims (do not start your living game here)

### 3.1 The aspiration trap

Small teams love sims because Steam *pays* systems fantasies (Schedule I, factory games, colony kings). That revenue is real — and **orthogonal** to whether *you* can finish a RimWorld-depth product at $3–$10 before burning out.

| Aspiration | Reality check | Evidence |
|---|---|---|
| **RimWorld-depth colony** | ~5.5 years to 1.0 (2012→2018); tiny team, then years of DLC; priced ~$35 band | Ludeon blog; Wikipedia / Eurogamer development arc |
| **Cities-depth city builder** | Content + tooling + UI mountain; wrong first-ship price | Repo ranking; Generation Exile cautionary |
| **Palworld-scale creature survival** | Open world + collection + combat (+ MP expectations) | Studio-scale comps |
| **“My first game is a living world sim”** | Scope creep feels like good ideas until NPCs need portraits need dialogue need seasons… | Solo postmortems (Polylusion, etc.) |

### 3.2 Documented failure shapes (2025–2026)

| Case | What happened | Lesson |
|---|---|---|
| **Generation Exile** (Nels Anderson / Sonderlust) | Years of work; trailers; Next Fest demo traction; **35k+ wishlists** → **&lt;300** Early Access sales in first week reporting | Wishlist ≠ sales for mid-scope city builders; “strange but not strange enough” kills conversion |
| **Ascent of Ashes** (RimWorld-adjacent EA, 2025) | Press: feels like unfinished RimWorld cousin; $15 questioned for alpha depth | Colony-sim expectations are set by genre kings; “almost RimWorld” is a curse |
| Generic Early Access survival / dino / open-world abandonments | Multi-system products become trust contracts you cannot service | If updates stop, reputation dies with the game |

### 3.3 Scope kill rules for sims

Do **not** greenlight Game 1 if any of these are true:

1. Honest Steam tags would include **Colony Sim** / deep **City Builder** / open-world **Survival** without a radical slice.  
2. Fun requires **autonomous agents + economy + combat + narrative** in v1.  
3. Price band to match comps is **$25–$40**, but you plan $5 “because indie.”  
4. Vertical slice cannot demonstrate the fantasy in **&lt;20 minutes** without “imagine the other systems.”  
5. Pitch is a mashup (“factory colony crafting survival with friends”).

**Allowed sim-adjacent shapes** (only if ruthlessly sliced): one workplace loop, one factory material invention, one tidy/organization toy — still crowded; still not RimWorld.

---

## 4. Saturated tags (supply vs hunger)

### 4.1 How to read “saturated”

Zukowski’s useful correction: **release count ≠ death**. Idle can ship 1,000+ titles in a year and still mint outliers. Saturation for a *small team* means:

- Design space feels paved (quality arms race).  
- Audience punishes jank / experimentation.  
- Competitors are better funded or already own the mindshare.  
- Store pages look interchangeable in Next Fest grids.

Tag-trend work (Jiahua / Medium, May 2026; SteamDB cozy tallies) and GameDiscoverCo keyword studies agree on directional weather:

| Tag / lane | Mid-2026 weather | Small-team read |
|---|---|---|
| **Cozy** / farming-adjacent | 2025 cozy releases alone rivaled *all prior years* combined (~543 vs ~698 prior cumulative in reported SteamDB chains); keyword “cozy” exploded in successful copy | Demand real; **median supply brutal** — do not pitch “cozy farm” as differentiation |
| **Idle / incremental** | ~5× supply in two years (App2top/WN Hub reporting); 1,087 idlers in 2026 YTD (Zukowski) | OK as cheap catalog systems practice; **bad** as lottery ticket |
| **Walking sim / cozy-cats style piles** | Tagged “saturated” (supply &gt; attention) in tag-momentum framing | Skip unless a sharp non-mood hook |
| **Bullet Heaven** | Official Steam genre tag; mature clone pile | Only with a new verb |
| **Roguelike / deckbuilder** | Genre prints money at the top (Alinea: huge 2026 roguelike revenue); median is a content meat grinder | Not a *fast* $3–$10 first ship |
| **Base-building** | Sometimes flagged “underserved” on attention/supply charts | Underserved often means **hard to make** — scope risk |
| **Friendslop / co-op chaos** | Audience hungry; hits huge | Wrong first product for netcode-light solo plan |

### 4.2 Tags that are “hot” but still bad *first* bets

Hot money can be a trap:

- **Roguelikes ~$500M** Steam gross talk for 2026 windows does not mean your StS-like clears $5k.  
- **Schedule I–style crime/management** validates systems fantasy — cloning the *drug* novelty without one tight city loop is how you get a half-sim.  
- **Extraction-lite** after Duckov/R.E.P.O. invites duck clones and flashlight swaps.

### 4.3 Practical tag hygiene for this repo

| Do | Don’t |
|---|---|
| Pick **one pure category** tag stack that matches the loop | Mash Indie+Roguelike+Horror+Simulation+AI disclosure as a strategy |
| Use tags players search for *after* the verb is unique | Lead with Cozy / Cute / Cats as the product |
| Budget demo + wishlist work equal to build time | Assume tag browsing finds you among 50 daily releases |

---

## 5. Combined anti-patterns (common pitch failures)

These show up constantly in AI ideation and Discord “what if we…” threads. Instant no for late-2026 Game 1:

1. **“Like Buckshot + Balatro + Vampire Survivors”** — mashup graveyard; violates pure-category rule.  
2. **“AI generates infinite content so scope is free”** — gameslop + disclosure stigma + no fantasy.  
3. **“RimWorld but multiplayer and cute”** — overscope × friendslop × art mountain.  
4. **“Cozy idle cozy farm cozy cats”** — saturated mood tags stacked.  
5. **“Open world crafting survival with friends, Early Access forever”** — trust-contract suicide for a tiny team.  
6. **“Platform fighter / Rollerhalla”** — F2P giants + netcode + cast.  
7. **“Full Slay the Spire at $4.99 in three months”** — content math does not work.  
8. **“Asset-store fantasy RPG”** — ghost-market classic; AI made it worse, not better.

---

## 6. Decision checklist (print before any GDD)

Answer **yes** to all before production:

- [ ] Can you state the game in **one sentence** without naming another game?  
- [ ] Is there **one** pure category on the store page?  
- [ ] Can a stranger understand the verb from a **30-second** silent clip?  
- [ ] Is v1 content a **loop**, not a world?  
- [ ] Is price honest for that loop ($0.99–$10 for a toy/vignette; not $5 for a colony)?  
- [ ] Would removing AI art/audio still leave a distinctive game?  
- [ ] Are you *outside* the active clone graveyards in §1, or inventing a new verb inside a family?  
- [ ] Can you ship a demo that is **not** embarrassed by Next Fest AI-hunting journalists?

If any checkbox fails — **do not build it** (yet). Park the fantasy for Game 4+ after catalog muscles exist.

---

## 7. What this repo should still avoid (cross-walk)

Aligns with [`GAME_PLAN.md`](../GAME_PLAN.md) / [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md):

| Already flagged | Reinforced by 2026 evidence |
|---|---|
| RimWorld / Cities / Palworld-scale first | Generation Exile; RimWorld timeline; EA colony critiques |
| Platform fighter | Unchanged |
| Full StS deckbuilder first | StS2 gravity + content volume |
| Genre mashups | Clone + tag noise multipies |
| Thin RACCOIN / Buckshot / Survivors clones | Explicit graveyards above |
| AI-led store presentation | Haro + Game Oracle + fan snapshot |

**Positive space (not this doc’s job, but the door left open):** short original tension toys, inventively scoped systems/idle *as catalog craft*, coin-machine with a sharp hook — always as **separate** pure products, never a mash.

---

## Sources

### Market volume, medians, concentration

1. Epiction Interactive — *2025 Game Dev Report* (19,606 launches; median ~$318; ghost vs active market). https://epiction.co/2025-game-dev-report/  
2. Indie Launch Lab — *Steam Game Releases 2025* (~21,273 analyzed). https://indielaunchlab.com/analytics/steam-reports/2025  
3. Robin Fredericksen — *STEAM 2025 By The Numbers* (~20.6k published; AI disclosure notes). https://fredericksen.substack.com/p/steam-2025-and-game-publication-rates  
4. Game-Developers.org — *The Steam Paradox 2025* (revenue vs median; visibility crisis synthesis). https://game-developers.org/steam-paradox-2025-revenue-volume  
5. Sulka Haro — *Three years of AI on Steam* (53,597-game census; AI share, revenue concentration, flop vs hit disclosure text). https://fragwyz.substack.com/p/three-years-of-ai-on-steam  
6. Yahoo / tech syndication of Haro — 60–90% of release growth AI-flagged. https://tech.yahoo.com/gaming/articles/steam-study-over-53-000-160050011.html  
7. GAMES.GG — AI disclosure trajectory toward majority of new games. https://games.gg/news/steam-ai-disclosure-games-2028-trend/

### AI policy, stigma, player attitudes

8. VGC — Valve rewritten Steam AI disclosure rules (Jan 2026). https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-much-disclose-ai-use/  
9. PC Gamer — disclosure focused on player-consumed content, not efficiency tools. https://www.pcgamer.com/software/ai/steam-updates-ai-disclosure-form-to-specify-that-its-focused-on-ai-generated-content-that-is-consumed-by-players-not-efficiency-tools-used-behind-the-scenes/  
10. Eurogamer — same policy amendment. https://www.eurogamer.net/valve-amends-ai-disclosure-policy-but-still-stresses-players-need-to-be-informed-if-genai-is-used  
11. GamesRadar — efficiency gains vs shipped content. https://www.gamesradar.com/games/valve-softens-steam-ai-disclosure-to-distinguish-efficiency-gains-from-the-use-of-ai-in-creating-content-that-is-shipped-with-your-game/  
12. StraySpark — *Steam’s 2026 AI Disclosure Rules* + gameslop framing. https://www.strayspark.studio/blog/steam-ai-disclosure-rules-2026-indie-developer-guide  
13. Indie-cent Exposure — “proudly human-made” + Haro sales-share summary. https://www.indie-exposure.com/proudly-human-made-indie-games-ai/  
14. Wikipedia — *AI slop* (terminology). https://en.wikipedia.org/wiki/AI_slop  

### Clone graveyards & genre crystallization

15. TweakTown — Steam adds **Bullet Heaven** genre tag (May 2026). https://www.tweaktown.com/news/111680/steam-has-finally-given-vampire-survivors-and-similar-games-its-own-genre-tag/index.html  
16. GamesRadar — Steam canonizes Vampire Survivors subgenre / clone wave. https://www.gamesradar.com/games/roguelike/steam-canonizes-the-vampire-survivors-subgenre-thats-spawned-a-million-clones/  
17. Steam store — Bullet Heaven tag hub. https://store.steampowered.com/tags/en/Bullet%20Heaven/  
18. Choost Games — *Games Like Vampire Survivors That Aren’t Just Clones* (clone graveyard framing). https://choostgames.com/blog/games-like-vampire-survivors-not-clones/  
19. Choost Games — *Best New Survivors-Like Games in 2026* (weekly release cadence / maturity). https://choostgames.com/blog/new-survivors-like-games-2026/  
20. No Small Games — Balatro-like Next Fest roundups. https://nosmallgames.com/2025/06/i-tried-every-balatro-like-game-i-could-find-in-steam-next-fest-again/  
21. Nexus Titan — Next Fest flooded with Balatro-likes (Feb 2026). https://nexustitan.net/2026/02/25/steam-next-fest-flooded-with-balatro-likes-seven-demos-to-watch/  
22. GameXplore — “long line of Balatro clones” framing. https://gamexplore.net/dont-let-it-starve-is-the-latest-in-a-long-line-of-balatro-clones-with-a-retro-horror-twist/  
23. WutsHot / launch coverage — RACCOIN 100k copies / 24h reports. https://www.wutshot.com/a/coin-pusher-roguelike-raccoin-sells-over-100k-units-on-steam-in-24-hours  
24. BestFingGames — Vampire Survivors clone cemetery + Vampire Crawlers contrast. https://bestfinggames.com/news/vampire-crawlers-hits-overwhelmingly-positive-rating-with-4600-steam-reviews/

### Friendslop / co-op wave (hungry ≠ easy clone)

25. CBC — What is friendslop? https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208  
26. Yahoo / tech — friendslop taking over in 2026. https://tech.yahoo.com/gaming/articles/friendslop-why-taking-over-2026-090000445.html  
27. How To Market A Game (Chris Zukowski) — *Is Friendslop saturated?* (hunger model; 2026 genre release counts). https://howtomarketagame.com/2026/07/30/is-friendslop-saturated/  
28. Game World Observer — analyst summary of Zukowski friendslop piece. https://gameworldobserver.com/2026/08/03/analyst-there-are-many-games-in-the-friendslap-niche-but-it-is-not-oversaturated  

### Overscoped sims & postmortems

29. Ludeon — RimWorld 1.0 after five and a half years. https://ludeon.com/blog/2018/10/rimworld-1-0-will-be-released-october-17/  
30. Eurogamer — RimWorld final stretch / multi-year development. https://www.eurogamer.net/after-five-years-in-development-sci-fi-colony-sim-rimworld-is-on-the-final-stretch-to-release  
31. Wikipedia — *RimWorld* (timeline, team size notes). https://en.wikipedia.org/wiki/RimWorld  
32. Yahoo / PC Gamer syndication — Generation Exile wishlist vs sales. https://tech.yahoo.com/gaming/articles/city-builder-flopped-early-access-235543317.html  
33. Game8 — Ascent of Ashes Early Access critique (RimWorld-adjacent). https://game8.co/articles/reviews/ascent-of-ashes-review-early-access  
34. Digitec — Ascent of Ashes vs RimWorld expectations. https://www.digitec.ch/en/page/rimworld-was-yesterday-this-is-how-ascent-of-ashes-fares-38952  
35. Polylusion — solo scope-creep lessons. https://polylusion.com/blog/solo-game-development-lessons  
36. Birdor — Early Access abandonment / multi-system survival case study framing. https://blog.birdor.com/the-stomping-land-early-access-abandonment-case-study/

### Tag weather, cozy/idle, genre money

37. PC Gamer — cozy keyword boom (GameDiscoverCo data). https://www.pcgamer.com/games/life-sim/the-cozy-game-boom-is-the-clearest-trend-on-steam-over-five-years-of-data/  
38. Jiahua — Steam genre trend analysis via store tags (May 2026). https://medium.com/@jiahua1023/steam-genre-trend-analysis-and-forecasting-using-store-tags-to-understand-the-pc-game-market-08ac4a6827da  
39. Shahriyar Shahrabi — Steam 2026 indie market deep dive (middle market / tags). https://shahriyarshahrabi.medium.com/deep-dive-in-steam-2026-indie-market-4c0aec5c0533  
40. Tech4Gamers — roguelikes ~$500M Steam 2026 window (Alinea). https://tech4gamers.com/roguelikes-steam-500m-2026/  
41. Alinea Analytics — roguelike DLC attach rates 2026. https://alineaanalytics.substack.com/p/steam-dlc-data-high-attach-rates  
42. Steam Page Analyzer — revenue-by-genre notes (crowding vs hard-to-build genres). https://www.steampageanalyzer.com/blog/steam-revenue-by-genre  

### Store comps referenced in-repo

43. Buckshot Roulette — https://store.steampowered.com/app/2835570/Buckshot_Roulette/  
44. CloverPit — https://store.steampowered.com/app/3314790/CloverPit/  
45. RACCOIN — https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/  
46. Particul — https://store.steampowered.com/app/4273120/Particul/  
47. RimWorld — https://store.steampowered.com/app/294100/RimWorld/  
48. Palworld — https://store.steampowered.com/app/1623730/Palworld/  
49. Slay the Spire — https://store.steampowered.com/app/646570/Slay_the_Spire/  
50. Vampire Survivors — https://store.steampowered.com/app/1794680/Vampire_Survivors/  

### Internal cross-links

51. [`docs/GAME_PLAN.md`](../GAME_PLAN.md) — multi-game sequence + avoid-first table.  
52. [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md) — pure-category scores.  

**Caveats:** Revenue figures from third parties are estimates (review×price methods, scrape windows). AI disclosure is self-reported. “2026 YTD” figures depend on each author’s cutoff (often mid-year). Use this doc to *kill bad bets*, not to forecast a specific title’s gross.

---

*End of adversarial brief. If an idea survives §6, write a one-page GDD for that pure category only — then build the vertical slice.*
