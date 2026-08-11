# Next Wave Prediction — Small Steam Games, 2026–2027

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Compiled:** August 2026  
**Lens:** Solo / tiny team, desktop Steam, **simple to play**, roughly **$0.99–$10**, shippable in months not years.  
**Related:** [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) · [`GAME_PLAN.md`](../GAME_PLAN.md)

---

## Verdict (read this first)

Steam’s 2025–2026 “great conjunction” is **not one genre** — it is several **hungry, omnivorous, jank-tolerant** audiences buying short, clippy, low-polish games on a 3–9 month refresh cycle (Zukowski; Epiction). The Vampire Survivors wave matured; **friendslop is still expanding**, not closed. The **next solo-friendly money** is less “another Lethal Company” and more:

1. **Arcade dopamine machines** (physics casino / gambling-toys)  
2. **Authored micro-horror / stakes rituals** (anti-slop craft signal)  
3. **Cute soft-extraction solo loops** (China-primary, accessible hardcore)  
4. **Interruptible competence toys** (Deck + short sessions)  
5. **Post-friendslop clip engines** (solo/duo physics failure comedies)

**Explicit reject:** “AI slop infinite world” is **not** the default next hit pattern. Evidence through mid-2026 shows AI-disclosed launches are a **volume boom with worse per-game conversion**, stigma on store pages, and almost no commercial proof for open-ended generative worlds. Constrained local-AI toys can exist as a niche experiment — they are not the wave to bet a first Steam product on.

---

## Method

| Input | What we used it for |
|---|---|
| Saturation / hunger cycles | VS → Survivors-likes → friendslop audience dynamics (Zukowski HTMAG + GamesRadar) |
| AI backlash | Steam disclosure rules; census of ~53.6k releases (Haro); stigma study (Game Oracle / Burton) |
| China Steam | Alinea / Asia Game Buzz / Duckov case |
| Steam Deck | Monthly most-played charts; interruptible-session fit |
| Short-form video | Wishlist-source mixes; REPO / Fallen Aces view→wishlist ratios |
| Early Access patterns | Manor Lords / Hades II lessons; co-op causal lift; launch-month data |
| Underserved tags | Attention vs supply studies; management / base-building / cooking / LGBTQ+ notes |
| Tech readiness | Godot Steam growth + StS2; Jolt physics default; local LLM Steam experiments |

**Confidence scale:** High ≥75 · Medium 55–74 · Speculative <55.  
These are **forecasts**, not guarantees. Steam remains hit-driven (top ~1% capture most revenue).

---

## Saturation map: VS → friendslop → ?

```
2021–23  Vampire Survivors conjunction
           └─ Survivors-likes flood → mature / “gen-2” (Megabonk etc.)

2023–26  Friendslop / social physics conjunction
           Lethal Company → Content Warning → R.E.P.O. → PEAK → RV There Yet → Meccha Chameleon
           Audience still growing (CCU stack ~197k → ~281k → ~350k+)
           Hits take ~50% of niche then fade to ~10% in 3–9 months → voracious buyers

2025–27  Parallel “Little League” conjunctions (same era, not sequential replacements)
           Idle / incremental · Horror · Horror-casino · Arcade gambling-toys · Cute soft-extraction
```

**Key correction to naive “what’s after friendslop?” thinking:**  
Zukowski’s 2026 framing is a **multi-genre golden age**, not a single baton pass. Friendslop stays hungry; the **solo/small-team next bets** are the parallel lanes that share its virtues (short build cycles, clip discovery, jank tolerance) **without requiring four Discord friends and netcode on day one**.

| Audience trait | Friendslop | Best solo successors |
|---|---|---|
| Omnivorous (buy every few months) | Yes | Casino toys, micro-horror, soft-extraction skins |
| Jank-tolerant | Yes | Physics toys, lo-fi horror |
| Clip / short-form native | Yes | All five waves below |
| Needs multiplayer | Usually | Prefer solo/duo unless you can ship local/online cheaply |

---

## Rejected default: “AI infinite world”

| Claim | Evidence | Implication |
|---|---|---|
| AI games will dominate Steam sales | By mid-2026 ~1/3 of **new launches** disclose AI; AI share of **sales** lags launches (~10–27% vs ~33% launch share). AI games reach ≥100 reviews at ~55% the rate of non-AI peers (Haro census). | Volume ≠ winners. |
| GenAI art is a solo shortcut to hits | Flops disproportionately disclose AI **art**; successes use AI more carefully (voice/loc) and hedge language (Haro). Game Oracle: after controls, ~53% fewer reviews / estimated 40–60% sales hit for disclosed AI on higher-potential titles. | Disclosure stigma is real for commercial intent. |
| Infinite generative worlds are the product | Player-facing generative sandboxes exist (AI Society, Life of an NPC, etc.) but remain experimental / EA curios relative to Buckshot, REPO, Duckov, Nubby, RACCOIN-scale outcomes. | Do not stake Game 1 on LLM open world. |
| Valve policy | Jan 2026 rewrite: disclose **shipped player-facing gen content**, not internal coding assistants. | Tooling ≠ store badge; shipped AI content still labels you. |

**Constrained AI form that *might* work later (not a primary wave):** finite authored loop + **one** local model feature (e.g. a single interrogable NPC, offline, with hard rules and a win condition). Treat as R&D after a non-AI commercial ship. Confidence: **Speculative (35%)**.

---

## Five predicted waves

### Wave 1 — Arcade dopamine machines (physics casino / gambling-toys)

**Thesis:** The Balatro → Nubby → CloverPit → RACCOIN lineage is the clearest **solo-scalable** conjunction still early enough for 2026–27 entries with sharp hooks.  
**Confidence:** **High (85%)**

| Factor | Evidence |
|---|---|
| Hits | [Nubby’s Number Factory](https://store.steampowered.com/app/3191030/) (~$5 plinko roguelike, Overwhelmingly Positive, 2025 breakout); [CloverPit](https://store.steampowered.com/app/3314790/); [RACCOIN](https://store.steampowered.com/app/3784030/) (100k+ day-one reports); Balatro’s long shadow |
| Analyst | Zukowski explicitly lists **horror / horror-casino** beside idle + friendslop as concurrent VS-like windows |
| Discovery | Pegboard / coin drop / slot spin = instant silent TikTok/Shorts hook |
| Tech | Godot 4 + rigid-body / Jolt stacking; readable 2D/2.5D; Deck-friendly |
| Risk | Post-RACCOIN thin clones already struggle — **hook differentiation** is the product |

**What a solo/small team should build (simple to play):**

- One **arcade machine fantasy** players understand in 2 seconds: coin pusher, plinko, claw, pachinko, ticket redemption, or “cursed slot.”  
- One **run structure**: meet quota → upgrade → escalate → die funny.  
- **No** deckbuilder content mountain unless the machine *is* the entire game (Nubby-scale item synergies, not StS card volume).  
- Price **$4.99–$9.99**; demo that is the first 10 minutes of dopamine.  
- Hand-authored juiciness; avoid AI-art “casino skin” stigma.

**Repo fit:** Aligns with **Game 2 (coin-machine)** in [`GAME_PLAN.md`](../GAME_PLAN.md) — still valid; enter with a **non-RACCOIN** machine premise.

---

### Wave 2 — Authored micro-horror & stakes rituals

**Thesis:** Short, readable tension games remain evergreen *and* get a relative boost from AI-slop fatigue: players reward **authored atmosphere + finite rules**.  
**Confidence:** **High (80%)**

| Factor | Evidence |
|---|---|
| Hits | [Buckshot Roulette](https://store.steampowered.com/app/2835570/) — multi-million sales (reports of ~8M copies), ~$3 band, clip-native, Deck-strong |
| Analyst | Zukowski: horror is evergreen for small teams — short by design, lo-fi OK, emotional impact carries |
| Anti-AI | Craft-forward tags (hand-drawn, atmospheric, horror vignette) under-index on AI flags (Haro part 2); stigma studies punish disclosed gen assets on high-potential pages |
| Shorts | 15–20 minute “one more round” sessions map to Shorts/TikTok reaction content |
| EA | Prefer **1.0 polished vignette** over long EA — Pacific Drive–style “ship finished, iterate” fits better than Manor Lords scope |

**What a solo/small team should build (simple to play):**

- **One room / one ritual / one antagonist.** Rules learnable in 60 seconds.  
- Escalation via modifiers, not open world. Session target **10–25 minutes**.  
- Original premise (do **not** clone shotgun roulette). Steal Buckshot’s *format*: stakes, items that bend odds, clip endings.  
- Price **$2.99–$7.99**.  
- Explicitly market as **human-authored**; no generative store art.

**Repo fit:** Aligns with recommended **Game 1 (tension / horror vignette)** in the category ranking.

---

### Wave 3 — Cute soft-extraction (accessible hardcore, China-aware)

**Thesis:** Hard systems + soft aesthetics + **solo PvE risk/reward** is a proven 2025 pattern ([Escape from Duckov](https://store.steampowered.com/app/3167020/)); 2026–27 winners will be **smaller-scope** “loot → extract → upgrade base” loops with mascot readability for Bilibili/Douyin/TikTok.  
**Confidence:** **Medium–High (70%)**

| Factor | Evidence |
|---|---|
| Hits | Duckov: 500k in days, multi-million copies, 64% China player share in Alinea notes; top-down PvE extraction with ducks — hardcore under cute skin |
| China | Steam’s largest user market (~42M CN players cited for end-2025); discovery via Bilibili / Douyin / Heybox; regional pricing 20–37% lower |
| Epiction | “Accessible depth” = one of three 2026 survival needs alongside shared panic & competence |
| Deck | Duckov heavily scrutinized for Deck performance — handheld + potato GPU is revenue |
| Solo risk | Full Tarkov / Arc Raiders is studio scope; **soft-extraction** must stay single-player or tiny co-op |

**What a solo/small team should build (simple to play):**

- **Top-down or side-view** raid → loot → extract → spend at a **one-screen hideout**.  
- Cute / absurd skin on tense decisions (not grim milsim).  
- **No** open-world creature survival; **no** mandatory PvP.  
- Content budget: 2–4 maps, readable enemy telegraphs, strong juice on successful extracts.  
- Ship **Simplified Chinese** at launch; price CN-aware (often ~$8–$16 band — stretch past $10 only if content depth justifies).  
- For *this repo’s* $0.99–$10 constraint: aim a **micro soft-extraction** (15-minute raids, tiny map pool) at **$7.99–$9.99**.

**Repo fit:** New lane beyond Games 1–3 — candidate for a later product after vignette/coin practice.

---

### Wave 4 — Interruptible competence toys (Deck-native systems)

**Thesis:** Deck charts keep rewarding games you can **suspend mid-run** and reopen without rebuilding context: turn-based systems, tidy-ups, light idles, short automation fantasies. This is the durable **solo** cousin of friendslop’s social dopamine.  
**Confidence:** **Medium (65%)**

| Factor | Evidence |
|---|---|
| Deck charts | Persistent: Slay the Spire / StS2, Balatro, Brotato, Stardew, Isaac; tidy/management titles (e.g. Librarian) appear in Deck most-played lists |
| Analyst | Idle called out as “Little League” practice lane; 1,087 incrementals in 2026 YTD still produced ~$4M outliers (Scritchy Scratchy) — hungry despite volume |
| Competence fantasy | Schedule I–class “optimize a system” demand (Epiction) — but solo teams should **miniaturize** that fantasy |
| Underserved-ish | Management / base-building / cooking show attention≥supply in tag studies — **scope-cut** versions beat full colony sims for this price band |
| Shorts caveat | Pure idles convert worse on TikTok than casino/horror; compensate with **visual number juice** or tidy ASMR clips |

**What a solo/small team should build (simple to play):**

- One screen, one job: tidy a space, run a tiny shop, route a desk factory, grow a number with **visible** machines.  
- Runs or days that survive **Steam Deck sleep**. Controller-first UI.  
- Prefer **active toys** (Particul-like particles, tidy physics, short automation puzzles) over dead clicker skins.  
- Price **$1.99–$6.99**.  
- EA only if you can patch every 4–8 weeks with a public roadmap; else ship 1.0 + post-launch ops.

**Repo fit:** Aligns with **Game 3 (idle / particle tycoon)** — keep it visually distinctive and Deck-verified.

---

### Wave 5 — Post-friendslop clip engines (solo / duo physics failure)

**Thesis:** Friendslop’s hunger continues, but the **median solo team cannot win REPO’s game**. The adjacent 2026–27 opening is **physics failure comedy that generates the same clips** with 1–2 players (or local-first 2–4) — “friendslop energy without friendslop payroll.”  
**Confidence:** **Medium (60%)**

| Factor | Evidence |
|---|---|
| Friendslop not closed | Stacked CCU new highs into mid-2026 (Meccha Chameleon era); mid-share games still clear mid-six / low-seven figure revenue |
| Co-op lever | Causal benchmarks: co-op/MP median ~×1.26 week-1 revenue, yet only ~15% of launches ship it — undersupplied *if* you can afford it |
| Solo constraint | Netcode + voice + live ops is the kill shot for first products in this repo’s band |
| Tech | Godot 4.6 Jolt default for 3D rigid bodies; potato GPU targets (REPO/PEAK era) |
| Shorts | Physics fails are the native language of TikTok game discovery (~35% of indie wishlists attributed to short-form in industry roundups) |

**What a solo/small team should build (simple to play):**

- **One verb + gravity:** drag, balance, stack, tow, lower, fling. Failure must be funny on mute.  
- Modes: **solo challenge** + optional **2P local/online**. Avoid 4P voice-required as v1.  
- Session length **5–20 minutes**; daily seed optional (PEAK’s Wordle-ish retention, miniaturized).  
- Price **$4.99–$9.99**.  
- If you cannot ship netcode in <8 weeks, ship **single-player physics comedy** that still clips (ghost replay / async sabotage), not a broken co-op EA.

**Repo fit:** Optional Game 4+ only after shipping a solo product; do not start here as Game 1 unless co-op is already a solved skill for the team.

---

## Confidence scoreboard

| # | Wave | Solo fitness | Clip / shorts | Deck | China leverage | Confidence |
|---|---|---|---|---|---|---|
| 1 | Arcade dopamine machines | Excellent | Excellent | Strong | Good (arcade culture + juice) | **85%** |
| 2 | Authored micro-horror | Excellent | Excellent | Excellent | Good with CN loc | **80%** |
| 3 | Cute soft-extraction | Medium (scope risk) | Strong | Strong if optimized | **Excellent** | **70%** |
| 4 | Interruptible competence toys | Excellent | Medium | **Excellent** | Medium | **65%** |
| 5 | Post-friendslop clip engines | Medium (MP tax) | Excellent | Medium | Medium | **60%** |

---

## Cross-cutting build rules (2026–2027)

1. **Hungry ≠ empty.** Count how many *makeable* comps earned real money — not how few tags exist (Zukowski “hungriness” test).  
2. **Design for mute 6-second hooks.** Short-form is the largest external wishlist pipe for many indies; Steam then amplifies conversion rate, not raw views.  
3. **Potato + Deck.** Target GTX 1060-class / Deck Verified early; suspend-friendly loops beat launch-gravity open worlds on handheld charts.  
4. **China is not DLC.** Simplified Chinese + fair CN price + Bilibili/Heybox presence changes outcomes; Duckov / Split Fiction / Stellar Blade patterns show CN can be primary, not afterthought.  
5. **EA is a job.** Use EA for systems games with 12–24 months of updates; use **finished vignette / arcade toy** launches for Waves 1–2.  
6. **Godot is ready.** StS2-scale commercial proof + exponential Godot Steam releases; Jolt for 3D physics toys. Stay in 2D/2.5D unless 3D is the joke.  
7. **Do not mash waves** into one store page (repo hard rule). One pure fantasy per product.  
8. **Do not lead with generative store content.** Internal assistants are fine under Valve’s 2026 wording; **shipped** AI art/audio still paints a stigma tax.

---

## What this means for *this* repo

| Priority | Action |
|---|---|
| Still best first ship | **Wave 2** — original tension vignette ($2.99–$7.99), matching [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) #1 |
| Strong second | **Wave 1** — differentiated arcade machine (not a RACCOIN clone) |
| Catalog / systems practice | **Wave 4** — Particul-like competence toy, Deck-first |
| Stretch / later | **Wave 3** micro soft-extraction if CN loc + top-down combat is in skill set |
| Only with co-op skill | **Wave 5** clip-engine physics |
| Avoid as default bet | AI infinite world, full friendslop 4P, StS-depth, RimWorld/Cities/Palworld scope |

---

## Selected sources (heavy)

### Saturation cycles / friendslop / conjunction
- Chris Zukowski — [Is Friendslop saturated?](https://howtomarketagame.com/2026/07/30/is-friendslop-saturated/) (2026-07-30)  
- GamesRadar — [Steam’s new “golden age”…](https://www.gamesradar.com/games/steams-new-golden-age-is-special-because-so-many-genres-are-popping-off-at-once-indie-expert-says-its-almost-like-the-player-base-was-drinking-and-their-inhibitions-lowered/) (Zukowski multi-genre thesis)  
- GamesRadar — [“Little League” idle + friendslop](https://www.gamesradar.com/games/roguelike/steam-expert-advises-devs-stick-to-the-little-league-section-of-idle-games-and-friendslop-before-attempting-anything-like-binding-of-isaac-or-mewgenics-then-you-can-make-your-dream/)  
- Game World Observer — [Friendslop not oversaturated](https://gameworldobserver.com/2026/08/03/analyst-there-are-many-games-in-the-friendslap-niche-but-it-is-not-oversaturated)  
- Epiction Interactive — [2025 Game Dev Report](https://epiction.co/2025-game-dev-report/) (19,606 launches; friendslop / Duckov / potato standard)  
- Thomas Brush Show ep. 057 transcript notes — Zukowski on concurrent idle / horror / horror-casino windows  

### AI backlash / disclosure
- Sulka Haro — [Three years of AI on Steam](https://fragwyz.substack.com/p/three-years-of-ai-on-steam) (~53.6k-game census, mid-2023→mid-2026)  
- Sulka Haro — [AI flagged games on Steam, Part 2](https://fragwyz.substack.com/p/ai-on-steam-part-2)  
- VGC — [Valve rewrites Steam AI disclosure rules](https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-much-disclose-ai-use/) (2026-01)  
- GamesRadar — [Valve softens disclosure: efficiency vs shipped content](https://www.gamesradar.com/games/valve-softens-steam-ai-disclosure-to-distinguish-efficiency-gains-from-the-use-of-ai-in-creating-content-that-is-shipped-with-your-game/)  
- PC Gamer — [AI stigma ~53% fewer reviews](https://www.pcgamer.com/software/ai/data-analyst-finds-ai-stigma-on-steam-can-reduce-the-number-of-reviews-a-game-gets-by-around-53-percent-and-the-reviews-it-does-get-are-more-negative/) (Game Oracle / Ross Burton)  
- Windows Central / Lumnix summaries of Game Oracle sales impact estimates  

### China Steam
- Alinea Analytics coverage via [17173](https://news.17173.com/content/12302025/102643237.shtml) / [Sina](https://finance.sina.com.cn/tech/digi/2025-12-29/doc-inhenaui7979818.shtml) — China as largest Steam user market; Duckov CN share  
- Asia Game Buzz / GameDev Reports — [China’s Steam & PC Gaming Market in 2025](https://gamedevreports.substack.com/p/exclusive-asia-game-buzz-and-gamedev)  
- TechNode / PC Gamer / GameDeveloper / Polygon — Escape from Duckov sales & design coverage  
- Games.gg — [China’s role in Steam bestsellers](https://games.gg/news/china-role-in-steam-best-sellers/)  

### Deck / short sessions
- Steam Hardware Hub — [Top 25 Steam Deck games, May 2026](https://steamhardware.io/articles/steam-deck/top-25-steam-deck-games-may-2026/) · [June 2026](https://steamhardware.io/articles/steam-deck/top-25-steam-deck-games-june-2026/)  
- GamingOnLinux — [Most played Steam Deck games, June 2026](https://www.gamingonlinux.com/2026/06/heres-the-most-played-steam-deck-games-for-june-2026/)  

### Short-form discovery
- Game-Developers.org — [Indie Steam wishlist sources](https://game-developers.org/indie-game-steam-wishlists-sources) (~35% short-form creators)  
- TrapPlan — [TikTok/Shorts → wishlists](https://www.trapplan.com/en/blog/can-tiktok-and-youtube-shorts-increase-steam-wishlists) (REPO / Fallen Aces view→wishlist examples)  

### Early Access / launch levers
- StraySpark — [Indie Early Access in 2026](https://www.strayspark.studio/blog/early-access-strategy-indie-2026)  
- SteamForecast — [Launch levers from 10,403 launches](https://steamforecast.app/reports/steam-launch-lever-benchmarks) (co-op ×1.26 median)  
- Alinea Analytics — [Co-op $4B+ H1; REPO / Schedule I / PEAK](https://alineaanalytics.substack.com/p/games-with-co-op-generated-over-4)  
- SteamData.AI — [Best month to launch (2026)](https://steamdata.ai/en-US/blog/best-month-to-launch-game-on-steam)  

### Underserved tags / genre economics
- Steam Page Analyzer — [Best Steam Tags 2026](https://www.steampageanalyzer.com/blog/best-steam-tags-2026) · [Revenue by genre](https://www.steampageanalyzer.com/blog/steam-revenue-by-genre)  
- Medium / Jiahua — [Steam genre trend analysis via tags](https://medium.com/@jiahua1023/steam-genre-trend-analysis-and-forecasting-using-store-tags-to-understand-the-pc-game-market-08ac4a6827da) (underserved: LGBTQ+, base-building, cooking, etc.)  

### Tech readiness (Godot / physics / local AI)
- GamesRadar — [Godot Steam release growth; StS2](https://www.gamesradar.com/games/roguelike/steam-stats-for-slay-the-spire-2s-engine-godot-show-strong-signs-of-exponential-growth/)  
- Ziva — [Slay the Spire 2 on Godot](https://ziva.sh/blogs/slay-the-spire-2-godot) (Godot commercial ceiling notes)  
- GamingOnLinux — [StS2 3M+ sales on Godot](https://www.gamingonlinux.com/2026/03/the-godot-powered-slay-the-spire-2-has-already-hit-over-3-million-sales/)  
- Godot 4.6 Jolt-as-default physics documentation / community guides  
- Eurogamer — [RACCOIN 100k day-one](https://www.eurogamer.net/coin-pusher-roguelike-raccoin-sells-100k-copies-on-steam-during-its-first-day)  
- GamesRadar / PCGamesN — Nubby’s Number Factory coverage  
- Steam store examples of local-AI experiments: [AI Society](https://store.steampowered.com/app/4468180/AI_Society/), [Life of an NPC](https://store.steampowered.com/app/3489080/Life_of_an_NPC/) (existence proof, not hit proof)

### Comps also used in-repo
- Buckshot Roulette, CloverPit, Particul, The Coin Game — see [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## Changelog

| Date | Note |
|---|---|
| 2026-08-08 | Initial forecast for 2026–2027 small Steam waves; heavy external sourcing |
