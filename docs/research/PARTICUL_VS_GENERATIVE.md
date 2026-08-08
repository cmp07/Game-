# Particul-like Particle Idle vs Generative / Adaptive Games

**Research date:** August 2026  
**Repo context:** [cmp07/Game-](https://github.com/cmp07/Game-) / sandpile-tycoon planning workspace  
**Lens:** Separate product philosophies (no mashup pitch). First-ship fit for a maker who wants **generative reality + physics + inventiveness**.  
**Companion plan:** [`docs/GAME_PLAN.md`](../GAME_PLAN.md) (pure categories; Particul screenshots map to idle/particle tycoon as a catalog product, not a hybrid).

---

## Verdict (read this first)

These are **two different product contracts**, not two skins of the same game.

| If your north star is… | Better philosophy |
|---|---|
| Number-go-up, automation dopamine, cheap Steam catalog ship | **Particul-like particle idle** |
| Generative reality + physics + inventiveness as the *reason to buy* | **True generative / adaptive** |

**Recommendation for first ship under the stated taste:** choose the **generative / adaptive philosophy**, scoped as a **deterministic systems toy** (emergent physics + player invention), **not** as an LLM-runtime “anything can happen” product and **not** as a Particul clone.

- Particul-like **fails the taste test**: physics is mostly *spectacle wrapping* for incremental math; inventiveness is thin (optimize extractors / odds / prestige).
- Full generative-adaptive (LLM runtime behaviors, adaptive directors, unbounded content) **passes the taste test** but **fails the first-ship test** (guardrails, latency/cost, fairness, Steam AI disclosure stigma, content QA).
- The shippable generative lane is the middle that still stays *inside* generative philosophy: **authored rules that generate unauthored situations** (falling-sand / sandbox / inventiveness toys), with a sharp win condition or challenge layer — still a pure category, still not an idle tycoon.

Do **not** “solve” this by bolting idle progression onto a generative sandbox (or vice versa). That is the mashup trap already banned in [`GAME_PLAN.md`](../GAME_PLAN.md).

---

## 1. Philosophy A — Particul-like particle idle

### What it is

**[Particul](https://store.steampowered.com/app/4273120/Particul/)** (Million Pixels, Feb 2026, ~$1.99): click to mine particles that fall into a pile → sell → buy extractors → lab upgrades → traders / marketplace → gamble odds → mine the rarest particle / ascend.

Steam framing: casual simulation / incremental / idler with physics *as a tag*, not as the design center of gravity ([Steam store](https://store.steampowered.com/app/4273120/Particul/)).

### Product contract

> Progress continues (and compounds) even when you are mostly watching. Your job is to unlock, automate, and optimize a predetermined tech curve until a rarity / prestige end-state.

**Core loop:** gather → convert → automate → multiply → prestige.  
**Player fantasy:** “My machine grows while I glance.”  
**Failure mode when hollow:** screensaver with buttons; late-game waiting / RNG walls (common Particul review theme: short idler value at $2, end-game spin-and-wait, ascension friction).

### Where physics sits

Physics is **presentation and juice**:

- Particles fall, pile, look “alive.”
- Satisfying sand/pile visuals are a major reason players recommend it (“falling sand + incremental”).
- Simulation depth is bounded so the *economy* stays tunable.

Adjacent comps that clarify the philosophy:

- Classic idle design: exponential curves, generators, prestige, anti-idle paradox ([idle design overview](https://solana.garden/guides/game-idle-game-design-explained/)).
- **[Falling Sand Idle](https://store.steampowered.com/app/3714750/Falling_Sand_Idle/)** (~$1.99 EA): “part incremental, part art project / screensaver you progress through” — makes the hybrid temptation explicit; also shows thin execution risk (tiny review count, mostly negative at research time).
- Mobile/particle idlers like ISEPS-style systems: particle *types* as upgrade graph nodes more than open invention.

### What “creation / spectacle” means here

Creation = **growth theater**:

- The pile getting taller / rarer.
- Extractors firing without you.
- Visual density as a progress bar.

Spectacle is **earned by time and upgrades**, not by inventing a new law of the world.

### Strengths for a small Steam ship

- Fastest code path among the repo’s top catalog ideas ([`CATEGORY_RANKING.md`](CATEGORY_RANKING.md)).
- Clear store tags (Idle, Incremental, Automation).
- Proven price band (~$1.99–$4.99).
- Demoable in seconds (click → pile → sell).
- Offline-friendly, no model API bill.

### Weaknesses vs inventiveness taste

- Inventiveness is mostly **build-order / economy inventiveness**, not “I made a new reality.”
- Adaptive systems (if any) are usually **odds / prices / prestige modifiers**, not world generation.
- Generative *feeling* saturates once the pile aesthetic is understood; retention is math, not discovery of systems.
- Ceiling is modest; plan already ranks this as **Game 3 / catalog filler**, not breakout vehicle.

---

## 2. Philosophy B — True generative / adaptive games

### What it is

A family of products where **the world or the rules keep producing situations the author did not hand-place**, and the player’s inventiveness is the skill:

| Sub-lane | Mechanism | Example anchors |
|---|---|---|
| **Systems emergence** | Local rules → global surprises | Falling sand toys → **[Noita](https://store.steampowered.com/app/881100/Noita/)**; **[People Playground](https://store.steampowered.com/app/1118200/People_Playground/)**; [Sandspiel](https://maxbittker.github.io/making-sandspiel/) / Powder Game lineage |
| **Inventiveness toys** | Player composes tools/objects; game honors combinations | **[Scribblenauts Unlimited](https://store.steampowered.com/app/218680/Scribblenauts_Unlimited/)**; Infinite Craft-style combiners |
| **Adaptive challenge** | Game retunes difficulty / director to the player | Dynamic difficulty adjustment (DDA) research; AI directors |
| **Runtime generative AI** | LLM/model invents content or *behaviors* during play | UIST’24 GROMIT / runtime behavior generation; UNBOUNDED-style mechanic generation; AI NPCs |

“True” generative/adaptive here means: **novelty is the product**, not a skin over a spreadsheet.

### Product contract

> The world answers inventions. You explore a possibility space; the game stays interesting because interactions cascade, not because a number doubled.

**Core loop:** propose / poke → world reacts → learn systems → invent harder.  
**Player fantasy:** “I discovered a trick the designer didn’t script as a quest.”  
**Failure mode when hollow:** chaos without legibility; unfair deaths; “AI slop”; unfinishable scope.

### Where physics sits

Physics (or rule simulation) is the **truth engine**:

- Noita: every pixel simulated; fun came from *taming* emergence into a roguelite, not from the sim alone ([RPS on Noita](https://www.rockpapershotgun.com/the-noita-devs-on-how-to-make-a-fun-game-when-everything-is-falling); [80.lv tech notes](https://80.lv/articles/noita-a-game-based-on-falling-sand-simulation); [IGF interview](https://www.gamedeveloper.com/game-platforms/road-to-the-igf-nolla-games-i-noita-i-)).
- People Playground: heat / electricity / rigid bodies → emergent contraptions; no campaign required ([Steam](https://store.steampowered.com/app/1118200/People_Playground/)).
- Sandspiel lineage: creation/spectacle *is* the game ([Making Sandspiel](https://maxbittker.github.io/making-sandspiel/); [falling sand → Noita lineage](https://www.rockpapershotgun.com/from-falling-sand-to-falling-everything-the-simulation-games-that-inspired-noita)).

### Adaptive vs generative (related, not identical)

- **Adaptive** (DDA / directors): retunes challenge to keep flow ([DDA pattern work](https://doi.org/10.1109/icmctc62214.2025.11196653); [expressivity of DDA](https://doi.org/10.1609/aiide.v21i1.36835); [LLM+DDA experiments](https://doi.org/10.5753/sbgames_estendido.2024.241217)).
- **Generative**: invents content, rules, or behaviors.
- You can have generative without adaptive (Noita runs), and adaptive without generative (rubber-band racing). Ambition stacks when you want both.

### Runtime AI generative — research reality check

[UIST 2024 — “What’s the Game, then? Opportunities and Challenges for Runtime Behavior Generation”](https://people.eecs.berkeley.edu/~bjoern/papers/jennings-gromit-uist2024.pdf) (GROMIT):

- Distinguishes **devtime** vs **runtime** generation; notes behaviors historically hard for PCG.
- Demos: fully generative / partially generative / generative mechanics.
- Developer interviews: quality, community expectations, workflow fit; need **guardrails**; downstream gameplay changes sometimes unwanted.
- Practical implication: moment-to-moment play must stay on traditional code; LLM cannot own the whole realtime loop.

Shipping practitioners converge on the same architecture:

- **AI proposes → code verifies → game decides** ([shipping runtime AI guardrails](https://dev.to/exoa/shipping-runtime-ai-in-unity-build-guardrails-before-prompts-279g)).
- Schema-governed pipelines / offline fallbacks ([generative-gaming pattern](https://github.com/KeigoShimadaCC/generative-gaming); [G-KMS narrative pipeline](https://www.mdpi.com/2079-8954/14/2/175)).
- On-device inference to avoid per-action cloud burn ([AI-first studio economics](https://mobidictum.com/studio-atelico-piero-molino-ai-first-game-studio/)).
- Multi-level authorization / pre-play heavy gen vs runtime light gen ([OzLand](https://doi.org/10.1145/3746058.3758392)).

Playability research still flags **interactive mechanics fidelity** as harder than pretty frames ([Playable Game Generation](https://arxiv.org/pdf/2412.00887)).

### Steam / market friction for AI-runtime products

- Valve disclosure focuses on AI content **consumed by players** (store + runtime), not silent coding helpers ([VGC](https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-must-disclose-ai-use/); [PC Gamer](https://www.pcgamer.com/software/ai/steam-updates-ai-disclosure-form-to-specify-that-its-focused-on-ai-generated-content-that-is-consumed-by-players-not-efficiency-tools-used-behind-the-scenes/)).
- Sentiment split: many players OK with AI assist; a large minority hostile to AI-consumed content ([GameDiscoverCo snapshot coverage](https://otakukart.com/steam-survey-finds-majority-players-accept-ai-in-game-development-but-31-still-oppose-ai-generated-content/)).
- Matched analysis reports material **“AI stigma”** on review volume/ratings for disclosed titles ([Game Oracle via PC Gamer](https://www.pcgamer.com/software/ai/data-analyst-finds-ai-stigma-on-steam-can-reduce-the-number-of-reviews-a-game-gets-by-around-53-percent-and-the-reviews-it-does-get-are-more-negative/)).

Systems-emergence generative products avoid that stigma entirely.

---

## 3. Overlap in “creation / spectacle” (without merging products)

Both philosophies sell a moment that looks similar in a screenshot:

> Colorful particles / objects cascade; the screen fills; something I did caused a satisfying physical reaction.

That is why Particul screenshots feel adjacent to sand toys — and why the repo’s original “sandpile” naming is seductive.

| Shared surface | Idle philosophy uses it for… | Generative philosophy uses it for… |
|---|---|---|
| Falling matter | Readable production / inventory | Material truth + chain reactions |
| Hypnotic motion | Retention while AFK / semi-AFK | Invitation to poke and invent |
| “I made that” | I built an *economy* | I built a *situation / machine / spell* |
| Chaos | Gambling / rarity spice | Emergence to master |

**Important separation:** shared *spectacle* ≠ shared *product*.  
Idle converts spectacle into **currency**. Generative converts spectacle into **possibility space**.

Overlapping taste is fine across a **multi-game catalog** (Game Plan already allows shared taste, forbids shared mash mechanics on one store page). Overlapping taste is **not** a reason to ship “idle + generative reality” as one SKU.

---

## 4. Long compare / contrast

| Dimension | Particul-like idle | Generative / adaptive |
|---|---|---|
| **Promise on the store page** | Automate mining & ascend | Invent inside a living system |
| **Primary dopamine** | Number go up / unlock tree | Surprise → mastery → remix |
| **Session shape** | Check-in, optimize, leave running | Active experiments, clip-friendly chaos |
| **Content mountain** | Curves, upgrades, prestige balance | Interaction matrix, legibility, edge cases |
| **Physics role** | Juice / metaphor | Ruleset / identity |
| **“Generative reality”** | Weak (pre-authored drops + VFX) | Strong (emergence or runtime invent) |
| **Inventiveness** | Optimization inventiveness | Compositional inventiveness |
| **Adaptivity** | Optional economy knobs | Core (DDA / director / generative response) |
| **Solo first-ship risk** | Low–medium | Medium (systems) → very high (LLM runtime) |
| **Price band fit ($0.99–$10)** | Excellent | Systems toys: good; Noita-depth: usually higher ambition; AI-runtime: ops cost |
| **Demo clarity** | Instant | Instant if toy-clear; muddy if “AI does stuff” |
| **Review risk** | Balance / grind / bugs | Unfair chaos / shallow sandbox / AI stigma |
| **Catalog role in this repo** | Planned Game 3 | Not yet a named slot; taste-aligned aspirational lane |

### What each optimizes against the user’s three keywords

| Keyword | Idle fit | Generative fit |
|---|---|---|
| Generative reality | Low | High |
| Physics | Medium (as spectacle) | High (as truth) |
| Inventiveness | Low–medium | High |
| First ship | High | Medium if systems-scoped; Low if AI-runtime |

---

## 5. First-ship recommendation (with tradeoffs)

### Choose generative / adaptive philosophy — but ship the *systems* sub-lane first

**Why this beats Particul for the stated taste**

1. Particul’s contract will constantly pull design toward extractors, sell buttons, and prestige — inventiveness becomes optional chrome.
2. A systems-generative toy can still be small: limited materials, one arena, one challenge mode (escape / survive / build-a-device goals) without becoming Noita.
3. Screenshots that excited “Particool” interest can belong to **sand spectacle**, but the *product* should honor poke → cascade → invent, not mine → sell → automate.

**Why not full runtime-AI generative as Game 1**

1. Guardrail + evaluation burden dominates ([GROMIT interviews](https://people.eecs.berkeley.edu/~bjoern/papers/jennings-gromit-uist2024.pdf); [shipping checklist](https://dev.to/exoa/shipping-runtime-ai-in-unity-build-guardrails-before-prompts-279g)).
2. Cloud costs / latency break $0.99–$10 unit economics unless local models are solved.
3. Steam disclosure + stigma are real discovery taxes.
4. Playability of generated mechanics is still a research frontier, not a solved indie template.

**Tradeoffs of rejecting Particul-as-first**

| You give up | You gain |
|---|---|
| Fastest idle code path | Taste integrity (generative reality) |
| Clearest “idle” tags & comps | Differentiated inventiveness fantasy |
| Easy AFK retention loops | Higher design difficulty (legible emergence) |
| Catalog filler economics | Harder balance / QA of interactions |

**Tradeoffs of rejecting AI-runtime-as-first**

| You give up | You gain |
|---|---|
| “Infinite” marketing language | Deterministic debugging |
| Personalized narrative/behaviors | No per-session AI bill |
| Cutting-edge pitch | Cleaner Steam positioning |

### How this relates to the existing multi-game plan

[`GAME_PLAN.md`](../GAME_PLAN.md) currently recommends:

1. Tension vignette → 2. Coin-machine → 3. Particul-like idle  

That sequence optimizes **fast Steam learning + pure categories**, not the inventiveness north star.

If **generative reality + physics + inventiveness** is the true first-ship north star, treat Particul-like as **still a later catalog product** (Game 3+), and treat Game 1 as a **pure generative-systems / inventiveness toy** — *or* keep tension vignette as the commercial trainer and accept that inventiveness waits. Do not satisfy inventiveness by smuggling it into an idle page.

Decision gate (aligned with plan style):

1. **Commercial trainer first** — tension vignette (plan default); inventiveness later.  
2. **Taste-true first** — lean generative physics / inventiveness toy (systems, not LLM-runtime).  
3. **Catalog idle first** — Particul-like (only if you explicitly deprioritize inventiveness for ship #1).

---

## 6. Sources

### Products / design practice

- Particul — [Steam](https://store.steampowered.com/app/4273120/Particul/), [Game Brain summary](https://gamebrain.co/game/particul), [Wasdland review excerpts](https://www.wasdland.com/game/particul-4273120/)
- Falling Sand Idle — [Steam](https://store.steampowered.com/app/3714750/Falling_Sand_Idle/)
- Noita — [Steam](https://store.steampowered.com/app/881100/Noita/); [RPS design](https://www.rockpapershotgun.com/the-noita-devs-on-how-to-make-a-fun-game-when-everything-is-falling); [80.lv](https://80.lv/articles/noita-a-game-based-on-falling-sand-simulation); [Gamasutra/IGF](https://www.gamedeveloper.com/game-platforms/road-to-the-igf-nolla-games-i-noita-i-); [falling sand lineage](https://www.rockpapershotgun.com/from-falling-sand-to-falling-everything-the-simulation-games-that-inspired-noita)
- People Playground — [Steam](https://store.steampowered.com/app/1118200/People_Playground/)
- Sandspiel — [Making Sandspiel](https://maxbittker.github.io/making-sandspiel/)
- Scribblenauts Unlimited — [Steam](https://store.steampowered.com/app/218680/Scribblenauts_Unlimited/)
- Idle structure — [Idle Game Design Explained](https://solana.garden/guides/game-idle-game-design-explained/)

### Generative / adaptive research

- Jennings et al., UIST 2024 — [Runtime Behavior Generation (GROMIT PDF)](https://people.eecs.berkeley.edu/~bjoern/papers/jennings-gromit-uist2024.pdf)
- UNBOUNDED (ICLR 2025) — [PDF](https://proceedings.iclr.cc/paper_files/paper/2025/file/da2411768acb844b255bb6770e5a71c7-Paper-Conference.pdf)
- Playable Game Generation — [arXiv](https://arxiv.org/pdf/2412.00887)
- UnrealLLM — [ACL Anthology PDF](https://aclanthology.org/2025.findings-acl.994.pdf)
- LatticeWorld — [arXiv HTML](https://arxiv.org/html/2509.05263v2)
- OzLand generative authorization — [ACM](https://doi.org/10.1145/3746058.3758392)
- DDA framework — [IEEE](https://doi.org/10.1109/icmctc62214.2025.11196653); DDA expressivity — [AIIDE](https://doi.org/10.1609/aiide.v21i1.36835); LLM+DDA — [SBGames](https://doi.org/10.5753/sbgames_estendido.2024.241217)
- Shipping guardrails — [DEV](https://dev.to/exoa/shipping-runtime-ai-in-unity-build-guardrails-before-prompts-279g); schema pattern — [generative-gaming](https://github.com/KeigoShimadaCC/generative-gaming)

### Market / policy

- Steam AI disclosure rewrite — [VGC](https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-must-disclose-ai-use/), [PC Gamer](https://www.pcgamer.com/software/ai/steam-updates-ai-disclosure-form-to-specify-that-its-focused-on-ai-generated-content-that-is-consumed-by-players-not-efficiency-tools-used-behind-the-scenes/)
- Player sentiment / stigma — [OtakuKart / GameDiscoverCo snapshot](https://otakukart.com/steam-survey-finds-majority-players-accept-ai-in-game-development-but-31-still-oppose-ai-generated-content/), [PC Gamer on AI stigma](https://www.pcgamer.com/software/ai/data-analyst-finds-ai-stigma-on-steam-can-reduce-the-number-of-reviews-a-game-gets-by-around-53-percent-and-the-reviews-it-does-get-are-more-negative/)
- AI-first studio economics — [Mobidictum / Atelico](https://mobidictum.com/studio-atelico-piero-molino-ai-first-game-studio/)

### Internal

- [`docs/GAME_PLAN.md`](../GAME_PLAN.md)
- [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)
