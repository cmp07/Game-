# Can “Game Shapes Around Players” Work in Co-op / Friendslop?

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Research date:** August 2026  
**Audience:** First-product decision for a solo/small-team Steam desktop game ($0.99–$10)  
**Related plan:** [`docs/GAME_PLAN.md`](../GAME_PLAN.md), [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## Executive verdict (read this first)

**Deep “game shapes around players” personalization and friendslop co-op pull in opposite directions.** Friendslop wins when friends share one chaotic stage; personalization wins when one mind’s behavior quietly rewrites content, pacing, or narrative. Stacking both for a first Steam product multiplies netcode, authority, content branching, QA, and (if LLM-backed) inference cost—while the hot co-op market rewards **simple shared toys**, not adaptive worlds.

**First-product recommendation for this repo:** Keep Game 1 **single-player** and, if you want “shapes around the player,” use a **local, rule-based adaptive layer** (stress/pacing director or light profiling)—**not** online co-op, **not** friendslop, **not** cloud LLM world-gen as a launch dependency. That aligns with the existing plan’s hard constraint: *“Not for v1: … multiplayer netcode”* ([`GAME_PLAN.md`](../GAME_PLAN.md)).

| Ambition | Fit for first $0.99–$10 ship | Why |
|---|---|---|
| Single-player adaptive tension vignette | **Best** | One player → one truth; no sync; matches ranked Game 1 lane |
| Friendslop without deep personalization | Later / separate product | Market is huge but MP-first; different skill stack |
| Co-op + shared team Director (L4D-style pacing) | Later mid-scope | Proven pattern; still needs solid netcode |
| Co-op + per-player world/narrative morphing | **Avoid as Game 1** | Conflicting player signals; content × N; sync hell |
| Generative / LLM world that reshapes per session for a party | Research / sequel fantasy | Consistency + latency + “success tax” on API bills |

---

## 1. What the two ideas actually mean

### 1.1 “Game shapes around players”

In design literature this is the **AI Director / adaptive experience** family: a runtime supervisor watches player state (stress, skill, attention, choices) and modulates spawns, drops, pacing, presentation, or story so the session stays in a target band ([Socratopia — AI Director pattern](https://www.socratopia.app/library/game-ai-patterns-en/chapter-21); [HP explainer on adaptive AI](https://www.hp.com/us-en/tech-takes/gaming/explainer/adaptive-ai-in-games-explained.html)).

Concrete shipped flavors:

| Flavor | Example | What “shapes” |
|---|---|---|
| **Team pacing director** | *Left 4 Dead* | Spawn timing / intensity valleys; tracks max survivor stress ([Booth PDF](https://cdn.fastly.steamstatic.com/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf)) |
| **Single hunter + director** | *Alien: Isolation* | Menace gauge; alien “frontstage/backstage” ([Game Developer](https://www.gamedeveloper.com/design/revisiting-the-ai-of-alien-isolation)) |
| **Psychological profile → content** | *Silent Hill: Shattered Memories* | Personality inventory alters cast, look, ending ([GamesIndustry](https://www.gamesindustry.biz/silent-hill-shattered-memories-details-disclosed-on-the-elaborate-psychological-profiling-system); [Nintendo Life interview](https://www.nintendolife.com/news/2010/01/interview_climax_silent_hill_shattered_memories)) |
| **Party-size / hazard scaling** | *Deep Rock Galactic* | Static multipliers by hazard + player count—not live psychologizing ([DRG wiki](https://deeprockgalactic.wiki.gg/wiki/Difficulty_Scaling)) |
| **LLM / generative reshape** | Prototypes, AI NPCs, world models | Dialogue, quests, or world state rewritten from prompts (see §5) |

The hard design rule: **if players notice the Director gaming them, they game the Director** ([Socratopia](https://www.socratopia.app/library/game-ai-patterns-en/chapter-21)).

### 1.2 Friendslop

**Friendslop** is the 2025–2026 meme-turned-market label for cheap, low-friction **social co-op**: short sessions, silly physics or pressure, proximity chat, friend-group purchases, often ≤ ~$20 ([Wikipedia: Friendslop](https://en.wikipedia.org/wiki/Friendslop); [Adventure Gamers explainer](https://adventuregamers.com/article/what-does-friendslop-mean); [CBC](https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208)).

Canon examples commonly cited: *Lethal Company*, *Content Warning*, *R.E.P.O.*, *Peak*, *Webfishing*, *RV There Yet?*, *Meccha Chameleon*, *Big Walk* ([Wikipedia list](https://en.wikipedia.org/wiki/Friendslop)).

Aggro Crab art director Galen Drew’s definition of the fun: *“stupid stuff you and your friends do… driven by the mistakes you make”*—failure as comedy, items with built-in failure points so friends yell at each other ([Game Developer, Aug 2025](https://www.gamedeveloper.com/design/what-developers-can-learn-from-the-indie-social-co-op-games-topping-the-steam-charts)).

**Friendslop’s product is the friend group’s performance.** The game is a stage. It does **not** need to secretly rewrite itself around each friend’s psychology.

---

## 2. Market reality: friendslop is huge—and shallow on retention

Commercial signal (2025):

- *Peak* ~10M+ copies within months of June 2025 launch; *R.E.P.O.* in the same “budget indie” mega-hit tier ([Game Developer](https://www.gamedeveloper.com/design/what-developers-can-learn-from-the-indie-social-co-op-games-topping-the-steam-charts); [CBC](https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208)).
- AppMagic-summarized unit estimates place *R.E.P.O.* ~18.5M and *Peak* ~15.4M among 2025 Steam best-sellers; four of the year’s top ten unit sellers fell in the friendslop bucket ([Game Industry Library / AppMagic](https://gameindustrylibrary.com/documents/appmagic-friendslop-games-in-2025-and-their-retention)).
- Co-op Steam revenue H1 2025 cited at ~$4.1B—“highest six-month total ever” for the genre ([Game Developer / Alinea](https://www.gamedeveloper.com/design/what-developers-can-learn-from-the-indie-social-co-op-games-topping-the-steam-charts)).
- Typical price band: roughly **$5–$20**, optimized for whole-squad buy-in ([AppMagic summary](https://gameindustrylibrary.com/documents/appmagic-friendslop-games-in-2025-and-their-retention); [Wikipedia](https://en.wikipedia.org/wiki/Friendslop)).

Retention reality:

- Average **D30 ≈ 3%** for friendslop titles; *Dead by Daylight* ~11.3%, *Phasmophobia* ~5.3% for contrast ([AppMagic](https://gameindustrylibrary.com/documents/appmagic-friendslop-games-in-2025-and-their-retention)).
- Analysts treat churn as **feature of the model**: binge with friends → move on → next cheap social toy—not a failure of meta-progression.

**Implication for “shapes around players”:** The market is **not** asking for a persistent personalized AI world. It is asking for **immediate, shareable chaos** with a low skill floor. Spending scarce solo-dev months on adaptive narrative trees or LLM directors does not buy the viral loop that sold *Peak*.

---

## 3. The composition problem: N players ≠ N personalized games

### 3.1 One shared world needs one shared truth

Personalization assumes a **single preference/stress vector**. Co-op injects N vectors that disagree:

- Ace player wants pressure; terrified friend wants quiet.
- Explorer wants occult lore branches; speedrunner wants loot routes.
- One player’s flirt/aggression profile (*Shattered Memories*-style) would rewrite NPCs for everyone—or fork reality.

Valve’s *Left 4 Dead* answer is instructive: estimate intensity **per survivor**, then drive pacing from the **maximum** intensity across the team; adjust **pacing frequency**, not difficulty amplitude ([Booth, “The AI Systems of Left 4 Dead”](https://cdn.fastly.steamstatic.com/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf); [L4D wiki Director](https://left4deadwiki.com/wiki/The_Director)). That is **shared-session shaping**, not “four Silent Hills in one lobby.”

### 3.2 Competitive / unfairness research carries over to co-op

Multiplayer dynamic difficulty (MDDA) research shows balancing skill gaps can work mechanically but is **not a guaranteed fun win**; awareness, fairness feelings, and high-skill resentment matter ([Baldwin thesis](https://eprints.qut.edu.au/102669/1/Alexander_Baldwin_Thesis.pdf); [Crowd-Pleaser CHI](https://dl.acm.org/doi/10.1145/2967934.2968100)). Rubber-banding debates (*Mario Kart* item economy) show players notice when the world “helps” someone ([Shin analysis](https://www.audreyhshin.com/assets/papers/CS_231_Final_Paper-5.pdf)).

In friendslop, **noticeable** per-player buffs kill the joke: the comedy is *“we’re all idiots under the same rules.”* Handicapping the skilled friend so the scared friend “has their own story arc” fights the genre’s social contract.

### 3.3 What *does* compose cleanly in co-op

Patterns that ship without per-player world forks:

1. **Shared stage + emergent player chaos** — friendslop default (*Peak*, *Lethal Company*).
2. **Information / role asymmetry** — *Keep Talking and Nobody Explodes*: difficulty is the communication channel, not an adaptive AI ([GDC Vault](https://www.gdcvault.com/play/1023113/Designing-Asymmetric-Gameplay-For-Keep)).
3. **Mandatory interdependence** — *It Takes Two*: one authored duo challenge, no solo AI stand-in ([Accel artisan note](https://artisan.accel.com/it-takes-two-a-deep-dive-into-local-co-op-gameplay)).
4. **Team Director / menace pacing** — L4D, Alien Isolation’s director half.
5. **Explicit party-size scaling** — DRG hazard × player count ([wiki](https://deeprockgalactic.wiki.gg/wiki/Difficulty_Scaling)).

None of these require generative “the mountain rearranges for Chad’s fear of heights while Dana’s greed tree blooms.”

---

## 4. Netcode cost: why co-op alone is a second game

This repo’s stack assumption is **Godot 4 + Windows Steam** ([`GAME_PLAN.md`](../GAME_PLAN.md)). Multiplayer on that stack is viable for small sessions, but it is **not free**:

| Cost center | Reality check | Sources |
|---|---|---|
| Engine primitives | Godot gives RPC + replication; **no** built-in client prediction / rollback / lag compensation | [Rivet comparison](https://rivet.dev/blog/godot-multiplayer-compared-to-unity/); [Ziva Godot MP 2026](https://ziva.sh/blogs/godot-multiplayer) |
| Steam plumbing | GodotSteam / Steam Networking Sockets for lobbies, NAT, relays—extra integration surface | [Ziva](https://ziva.sh/blogs/godot-multiplayer); [Cooties tutorial stack](https://github.com/bearlikelion/cooties) |
| Friendslop expectations | Proximity voice, physics toys, desync-sensitive ragdolls/items | Genre hallmarks ([Wikipedia](https://en.wikipedia.org/wiki/Friendslop); [CBC](https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208)) |
| Production evidence | Small teams *can* ship MP in ~6 months—*if MP is the whole product* (e.g. Pratfall / Quad Head) | [80.lv Godot MP case](https://80.lv/articles/indie-team-breaks-down-shipping-multiplayer-game-with-godot-4-6-using-c) |
| Category ranking in-repo | Platform fighters / MP-heavy genres already scored as early traps for netcode + live ops | [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) |

**Additive cost of adaptation on top of MP:**

- Authoritative server must own Director decisions (clients cannot privately rewrite shared spawns).
- Every adaptive branch is a **sync + replay/debug** surface (“why did the horde spawn for us?”).
- Generative assets need **authoritative shared state** separate from per-client visuals—active research, not a weekend plugin ([MultiGen / external memory for multiplayer world models](https://arxiv.org/html/2603.06679); [MASS shared-state summary](https://paperium.net/article/en/22339/mass-multiplayer-world-models-with-authoritative-shared-state); [Hybrid Server–AI architecture paper](https://digitalcommons.lindenwood.edu/cgi/viewcontent.cgi?article=1808&context=faculty-research-papers)).

For a first $3–$8 vignette, that is the wrong mountain to climb.

---

## 5. AI / LLM cost: personalization’s “success tax”

If “shapes around players” means **cloud models rewriting content in session**, costs and latency dominate design.

### 5.1 Latency budgets

A 60 fps frame is ~16.7 ms. Cloud LLM time-to-first-token commonly sits in **hundreds of ms to multiple seconds**—so inference must be **off the render loop**, with UX that tolerates wait ([MysticStage latency budget](https://mst-sg.com/latency-budget-in-game-ai-edge-inference-matters/); [Edge AI gaming “success tax”](https://veriprajna.com/blog/edge-ai-gaming-local-models-latency)).

March 2026 NPC dialogue benchmark (end-to-end including TTS) ([Nic Cusworth](https://niccusworth.com/articles/every-npc-has-a-price-benchmarking-the-latest-llms-for-real-time-npc-dialogue/)):

| Model tier | Perceived latency (approx.) | Cost / exchange (approx.) |
|---|---|---|
| Fast flash (Qwen-class) | ~3–7 s | ~$0.0001 |
| Mid flash (Gemini-class) | ~4–8 s | ~$0.0004 |
| Sonnet-class | ~8.6 s | ~$0.01 |
| Opus-class | ~9.5–10+ s (spikes worse) | ~$0.05 |

Frontier quality at ~$0.05/exchange → **~$1 per 20-line conversation**—called “untenable” for shipped real-time games in that writeup. Indie NPC platforms often budget **hundreds $/month in development alone** for cloud character APIs ([StraySpark Inworld/Convai comparison](https://www.strayspark.studio/blog/ai-npcs-persistent-memory-inworld-convai-nvidia-ace-mcp)).

### 5.2 Multiplayer multiplies spend and failure modes

- **N talkers** ≈ N streams of tokens (or one shared narrator fighting for attention).
- Party sessions create **thundering-herd** spikes when everyone triggers generation together ([Veriprajna](https://veriprajna.com/blog/edge-ai-gaming-local-models-latency)).
- Stochastic generation fights **deterministic netcode fairness**—middleware research explicitly flags this gap ([Hybrid Server–AI paper](https://digitalcommons.lindenwood.edu/cgi/viewcontent.cgi?article=1808&context=faculty-research-papers)).
- Vendor lock / pricing pivots become **gameplay bus factor** if the core fantasy is the live model.

### 5.3 What stays cheap

| Approach | Marginal cost | Co-op suitability |
|---|---|---|
| Rule-based Director (L4D-style numbers) | ~$0 | Excellent if shared metrics |
| Authored branches + light profiling (Shattered Memories-scale, single-player) | Content authoring cost, not API | Poor fit for 4-player shared story |
| Local small models on player GPU | ~$0 inference; hardware variance | Hard to guarantee on Steam’s long-tail PCs |
| Offline LLM for *content authoring only* | Dev-time API spend | Fine—does not reshape live MP |

**Rule of thumb:** If adaptation can be expressed as **floats and enums** (stress, menace, spawn budget), ship it. If it needs **paragraphs and meshes on the fly**, do not put it on the critical path of a first co-op product.

---

## 6. Worked examples: when shaping + multiplayer coexist (and when they don’t)

### 6.1 Works: shared Director / shared stage

| Title | Adaptation type | Why it works with multiple humans |
|---|---|---|
| *Left 4 Dead* | Team intensity → pacing | One shared threat schedule; max-stress gate; invisible knobs ([Booth PDF](https://cdn.fastly.steamstatic.com/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf)) |
| *Alien: Isolation* | Menace director + hunter AI | Primarily **solo**; director keeps one prey under pressure ([GDC-style writeups](https://www.gamedeveloper.com/design/revisiting-the-ai-of-alien-isolation)) |
| *Deep Rock Galactic* | Hazard × player count | Transparent scaling; Ghost Ship explicitly wanted even footing for mixed skill groups (contrast to L4D newbie crush) |
| Friendslop hits (*Peak*, *R.E.P.O.*, etc.) | Almost no personalization | Physics + social pressure create variance; map rotations / simple loops refresh sessions ([Game Developer](https://www.gamedeveloper.com/design/what-developers-can-learn-from-the-indie-social-co-op-games-topping-the-steam-charts)) |

### 6.2 Works best alone: deep personal shaping

| Title | Why single-player |
|---|---|
| *Silent Hill: Shattered Memories* | Personality Inventory needs one subject; unused content per path is already expensive ([Climax interview](https://www.nintendolife.com/news/2010/01/interview_climax_silent_hill_shattered_memories)) |
| Horror adaptive-narrative research | Personalized fear targeting assumes one affective profile ([Kepes 2025 AI-as-director paper](https://doi.org/10.17151/kepes.2025.22.32.3)) |
| Repo Game 1 recommendation | Tension vignette / Buckshot-*format* — short, clip-friendly, **demoable solo** ([`GAME_PLAN.md`](../GAME_PLAN.md)) |

### 6.3 “Works” only as research demos today

- LLM mystery parties / AI dungeon masters with co-op on the roadmap ([Case Vault Devpost](https://devpost.com/software/infinite-mysteries); various hackathon repos)—latency, hallucination control, and host authority still dominate.
- Diffusion / world-model multiplayer requires **external authoritative memory** to stop players from seeing different realities ([MultiGen](https://arxiv.org/html/2603.06679)).

These validate the *ambition*, not a 2026 first-Steam-ship plan for a solo Godot team.

---

## 7. Why most first games should stay single-player adaptive

Arguments ranked for **this repo’s constraints** (solo/small, Godot, desktop Steam, $0.99–$10, sequential small releases):

1. **One player = one consistent adaptation target.** No max/min/average debate; no fairness optics.
2. **Ship speed.** Existing ranking already puts tension vignette first and marks MP genres as early traps ([`CATEGORY_RANKING.md`](CATEGORY_RANKING.md)).
3. **Demo & short-form discovery.** Solo horror/tension clips do not require “gather three friends + voice chat.”
4. **Content leverage.** Personalization that swaps lighting, antagonist timing, or ending flags is cheap; personalization that regenerates levels for four viewpoints is not.
5. **Margin.** A $2.99–$7.99 game cannot absorb per-session LLM bills or dedicated-server opex if virality hits (friendslop’s own unit volumes make cloud-AI COGS terrifying).
6. **Learning order.** Prove the adaptive fantasy offline → later add **shared** Director over a thin co-op layer if data says squads want it.
7. **Genre honesty.** Friendslop buyers want *friends*; adaptive-horror buyers want *the game reading them*. Mashups break both store-page promises—and this repo’s hard rule against genre mash first products ([`GAME_PLAN.md`](../GAME_PLAN.md)).

---

## 8. Decision matrix for cmp07/Game-

| Option | Build now? | Notes |
|---|---|---|
| **A. SP tension vignette + light local Director** | **Yes (recommended)** | Stress/menace pacing; optional light profiling; pure category; matches Game 1 |
| **B. SP adaptive with offline LLM-authored content** | Optional | Use models in production pipeline, not runtime |
| **C. Friendslop physics toy, no AI Director** | Game 2+ only if you commit to MP as the product | Compete on feel/chaos, not personalization |
| **D. Co-op + team Director** | After one SP ship | Copy L4D lesson: shared metrics only |
| **E. Co-op + per-player generative reshape** | No for v1–v3 | Research debt + COGS + sync |

**Compatibility cheat sheet**

```
Friendslop fun      ∝  shared rules + visible chaos + voice
Personalization fun ∝  private model of one player + invisible edits

Intersection that ships:  SHARED, SHALLOW adaptation
                          (team stress → spawn budget)
Intersection that stalls: PRIVATE, DEEP adaptation × N players
                          (per-player story/world forks + netcode + LLM)
```

---

## 9. Practical architecture notes (if you later add co-op)

Keep these constraints if Game 2+ becomes social:

1. **Host/server authority** for all Director outputs.
2. **Aggregate signals only** (max stress, average downs, party distance)—never silent per-player story forks.
3. **Deterministic catalogs**—spawn from authored tables; do not stream unique geometry per client.
4. **No gameplay-critical cloud LLM** at $5–$15 price points; optional cosmetic narrator with hard offline fallback.
5. **Design failure as comedy**, not as compensation—friendslop’s own creators optimize items to *cause* yellable mistakes ([Game Developer](https://www.gamedeveloper.com/design/what-developers-can-learn-from-the-indie-social-co-op-games-topping-the-steam-charts)).

---

## 10. Sources

### Friendslop / co-op market
- [Wikipedia — Friendslop](https://en.wikipedia.org/wiki/Friendslop)
- [Adventure Gamers — Friendslop explained](https://adventuregamers.com/article/what-does-friendslop-mean)
- [Game Developer — Indie social co-op topping Steam (Nicole Carpenter, Aug 2025)](https://www.gamedeveloper.com/design/what-developers-can-learn-from-the-indie-social-co-op-games-topping-the-steam-charts)
- [CBC — Friendslop trend / Big Walk (2026)](https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208)
- [AppMagic via Game Industry Library — Friendslop 2025 retention](https://gameindustrylibrary.com/documents/appmagic-friendslop-games-in-2025-and-their-retention)

### Adaptive / Director systems
- [Michael Booth — The AI Systems of Left 4 Dead (Valve PDF)](https://cdn.fastly.steamstatic.com/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf)
- [Left 4 Dead Wiki — The Director](https://left4deadwiki.com/wiki/The_Director)
- [Game Developer — Why Left 4 Dead Works](https://www.gamedeveloper.com/design/why-i-left-4-dead-i-works)
- [Socratopia — Adaptive Difficulty / AI Director pattern](https://www.socratopia.app/library/game-ai-patterns-en/chapter-21)
- [Game Developer — Revisiting the AI of Alien: Isolation](https://www.gamedeveloper.com/design/revisiting-the-ai-of-alien-isolation)
- [GamesIndustry — Silent Hill: Shattered Memories psychological profiling](https://www.gamesindustry.biz/silent-hill-shattered-memories-details-disclosed-on-the-elaborate-psychological-profiling-system)
- [Nintendo Life — Climax interview on Shattered Memories profiling](https://www.nintendolife.com/news/2010/01/interview_climax_silent_hill_shattered_memories)
- [Kepes (2025) — AI as director / personalized horror](https://doi.org/10.17151/kepes.2025.22.32.3)
- [Deep Rock Galactic Wiki — Difficulty Scaling](https://deeprockgalactic.wiki.gg/wiki/Difficulty_Scaling)

### Multiplayer DDA / fairness
- [Baldwin — Balancing Act (MDDA thesis)](https://eprints.qut.edu.au/102669/1/Alexander_Baldwin_Thesis.pdf)
- [Baldwin et al. — Crowd-Pleaser (CHI EA)](https://dl.acm.org/doi/10.1145/2967934.2968100)

### Netcode / Godot
- [Rivet — Godot multiplayer vs Unity](https://rivet.dev/blog/godot-multiplayer-compared-to-unity/)
- [Ziva — Godot 4 multiplayer best practices (2026)](https://ziva.sh/blogs/godot-multiplayer)
- [80.lv — Shipping multiplayer in Godot 4 (Pratfall / Quad Head)](https://80.lv/articles/indie-team-breaks-down-shipping-multiplayer-game-with-godot-4-6-using-c)

### AI cost / generative multiplayer
- [Nic Cusworth — Every NPC Has a Price (Mar 2026 benchmark)](https://niccusworth.com/articles/every-npc-has-a-price-benchmarking-the-latest-llms-for-real-time-npc-dialogue/)
- [MysticStage — In-game AI latency budget](https://mst-sg.com/latency-budget-in-game-ai-edge-inference-matters/)
- [Veriprajna — Edge AI gaming / cloud LLM success tax](https://veriprajna.com/blog/edge-ai-gaming-local-models-latency)
- [StraySpark — Inworld / Convai / ACE cost notes](https://www.strayspark.studio/blog/ai-npcs-persistent-memory-inworld-convai-nvidia-ace-mcp)
- [MultiGen — Editable multiplayer worlds / external memory (arXiv)](https://arxiv.org/html/2603.06679)
- [Lindenwood / ISAR — Hybrid Server–AI for generative worlds](https://digitalcommons.lindenwood.edu/cgi/viewcontent.cgi?article=1808&context=faculty-research-papers)

### Designed co-op (non-adaptive contrast)
- [GDC Vault — Designing Asymmetric Gameplay for Keep Talking…](https://www.gdcvault.com/play/1023113/Designing-Asymmetric-Gameplay-For-Keep)
- [Accel artisan — It Takes Two local co-op deep dive](https://artisan.accel.com/it-takes-two-a-deep-dive-into-local-co-op-gameplay)

### In-repo strategy
- [`docs/GAME_PLAN.md`](../GAME_PLAN.md)
- [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## 11. Bottom line

**Can it work?**  
Yes—in the **narrow** sense Valve already shipped: a **shared** director that paces one party.  
No—in the **marketing fantasy** sense of a generative world that intimately reshapes around each friend inside a friendslop lobby. That fantasy fights shared truth, fairness, netcode, and COGS.

**First product:** Stay **single-player adaptive** (or even non-adaptive but tightly authored tension). Treat friendslop as a **later, separate** Steam SKU if you want social virality—and keep its systems **shallow and shared**, not deeply personalized.
