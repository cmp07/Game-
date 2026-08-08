# Simple to Play, Deep / Unique to Master — Research Report

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-) (workspace: sandpile-tycoon / multi-game Steam plan)  
**Date:** August 2026  
**Lens:** Solo / small-team **desktop Steam** products priced roughly **$3–$10**, with **short rules** and **emergent or exploratory depth**.  
**Related:** [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) · [`GAME_PLAN.md`](../GAME_PLAN.md)

---

## 1. Executive verdict

“Simple but outside the box” is **not** a genre tag. Commercially it means:

1. **Legible in under 30 seconds** (GIF / trailer / demo: one verb, one stakes fantasy).  
2. **One invented system** that players cannot substitute with “generic puzzle / generic roguelike / generic physics.”  
3. **Depth from interaction density**, not from content volume (fewer verbs × richer side-effects).  
4. **Price that matches perceived content hours** — many prestige “simple-deep” puzzles **price above $10**; the **$3–$10** band rewards **sessionable inventions**, **clip virality**, and **fast mastery loops**, not 350-level opus puzzles.

For this repo’s constraints, the commercially strongest “simple + inventive” shapes at **$3–$10** are **tension vignettes**, **one-control physics toys**, **constraint solvers with personality**, and **one-verb build engines** — not Baba-/Parabox-scale prestige puzzles as a first ship (those are design gold standards and often **$15–$20** products).

---

## 2. What “simple but outside the box” means commercially

### 2.1 Player-facing definition

| Axis | Simple | Outside the box |
|---|---|---|
| Rules | 1–3 verbs; teachable in a tweet | The *thing you do* is unfamiliar or reframes a known toy |
| First minute | Success/fail is readable | Surprise arrives from system interaction, not tutorial text |
| Mastery | Skill or insight scales for dozens of hours | Community invents strategies / secrets / clips |
| Store page | Capsule + 15s trailer sell the fantasy | Cannot be described as “puzzle game, but nicer art” alone |

Bennett Foddy’s framing of Flappy Bird is the commercial kernel: eliminate extraneous complexity, then **tune one interaction** until decisions inside that interaction become dense ([The Guardian, 2014](https://www.theguardian.com/technology/2014/feb/10/flappy-bird-is-dead-but-brilliant-mechanics-made-it-fly)).

### 2.2 Design definition (subtractive / interaction depth)

Puzzle and systems designers repeatedly describe the same pattern:

- **Subtractive design:** fewer verbs, higher resolution on side-effects of the remaining verb (Sokoban → Snakebird → Stephen’s Sausage Roll → Baba Is You) ([Puzzlebyrinth](https://puzzlebyrinth.com/en/articles/subtractive-design-fewer-verbs)).  
- **Width vs depth:** adding disconnected content grows *width*; connecting systems grows *depth* exponentially ([Rexcellent Games](https://rexcellentgames.com/width-vs-depth/)).  
- **System-first level design:** find an amusing interaction, then reverse-engineer a level that *requires* it (Hempuli on Baba) ([Game Developer, 2019](https://www.gamedeveloper.com/design/designing-i-baba-is-you-i-s-delightfully-innovative-rule-writing-system)).

Commercial translation: buyers do not pay for your design essay. They pay for a **hook that demos itself** and a **loop that keeps revealing consequences**.

### 2.3 Store / discovery definition

Hits in this family share marketing physics:

| Property | Why it sells |
|---|---|
| **Demoable novelty** | “Rules are blocks you push” / “poker, but jokers break math” / “boxes contain boxes” / “climb with a hammer in a pot” |
| **Clip economy** | Failure, absurd scores, or “wait what?” moments travel on Twitch/TikTok/Shorts |
| **Low commitment price** | Impulse buy removes hesitation; Balatro case study stresses price + clarity of promise ([Birdor](https://blog.birdor.com/balatro-product-loop-success-case-study/)) |
| **Session shape** | 5–30 minute runs or bite-sized puzzles fit “one more” |
| **Portability** | Controller-readable, small install → consoles/mobile amplify PC breakouts |

### 2.4 What it is *not* (common false positives)

- **Cute + short ≠ inventive.** Minimal art without a system invention competes with thousands of $1–$5 puzzle packs.  
- **Hard ≠ deep.** Arbitrary friction without a learnable model burns reviews.  
- **Genre mash ≠ outside the box.** This repo’s hard rule (pure category per product) aligns with store clarity: one fantasy per page ([`GAME_PLAN.md`](../GAME_PLAN.md)).  
- **Prestige puzzle ≠ $5 product.** Hand-authored hundreds of levels of recursive / linguistic depth often justify **$15–$20**, not the hobbyist under-$10 band.

---

## 3. Design taxonomy — families of “short rules, emergent depth”

### A. Rule-rewriting / meta systems

**Archetype:** Baba Is You  
**Rules surface:** push words → sentences become laws.  
**Depth source:** combinatorial grammar + player-authored interactions; objects have no intrinsic meaning except via rules ([Puzzlebyrinth on Hempuli](https://puzzlebyrinth.com/en/articles/designer-teikari); [Game Developer](https://www.gamedeveloper.com/design/designing-i-baba-is-you-i-s-delightfully-innovative-rule-writing-system)).  
**Commercial note:** Steam list historically around **$14.99**; SteamSpy owner band **1M–2M** ([SteamSpy](https://www.steamspy.com/app/736260)). Prestige + long content mountain. **Above this repo’s default band** as a first product.

### B. Recursive / spatial invention

**Archetype:** Patrick’s Parabox  
**Rules surface:** Sokoban push + enter/exit boxes; boxes can contain themselves.  
**Depth source:** edge cases of infinity / recursion become mechanics ([Game Developer interview](https://www.gamedeveloper.com/design/patrick-s-parabox-); [Wikipedia](https://en.wikipedia.org/wiki/Patrick%27s_Parabox)).  
**Commercial note:** ~**$19.99**; IGF Excellence in Design; SteamPulse-scale estimates on order of **~170k units / ~$2.5M VGI** (estimate tools vary) ([SteamPulse](https://steampulse.org/game/1260520)). Critical darling, **premium puzzle pricing**, slow authorship (350+ no-filler levels).

### C. Familiar toy + broken scoring (combo engines)

**Archetype:** Balatro  
**Rules surface:** make poker hands; jokers rewrite scoring.  
**Depth source:** public vocabulary (poker) + private escalation (multipliers, synergies); endless “one more run.”  
**Commercial note:** **$14.99**; **$1M in ~8 hours**; **250k in 3 days**; **5M+ copies** by Jan 2025 ([GamesIndustry.biz archive](https://web.archive.org/web/20240521174217/https:/www.gamesindustry.biz/balatro-grossed-1m-in-eight-hours); [The Verge](https://www.theverge.com/2025/1/21/24348727/balatro-5-million-copies-the-game-awards); [PocketGamer.biz](https://www.pocketgamer.biz/how-playstack-bet-on-balatro-and-won-big/)). Design template is gold; **price/content volume sit above fast $3–$10 first ship** for most solos (also crowded post-Balatro).

### D. Physics toys / one-control inventions

**Archetypes:** Getting Over It, QWOP lineage, World of Goo–class construction toys, coin-pusher machines.  
**Rules surface:** one continuous control (mouse hammer, awkward limbs, fling, drop).  
**Depth source:** skill ceiling + physics consistency + stakes of progress loss; clips of rage/triumph.  
**Commercial note:** Getting Over It ~**$7.99**, multi-million unit phenomenon / streamer fuel ([Steam](https://store.steampowered.com/app/240720/Getting_Over_It_with_Bennett_Foddy/); [Vulture interview](https://www.vulture.com/article/getting-over-it-with-bennett-foddy-interview-fun-failure.html)). **Inside $3–$10.** High marketing variance: either explodes via clips or dies quietly.

### E. One-button / minimal-input skill games

**Archetypes:** Flappy Bird, many jam one-buttoners, rhythm one-input titles.  
**Rules surface:** press → commit.  
**Depth source:** timing windows, route reading, choke under pressure ([Guardian / Foddy](https://www.theguardian.com/technology/2014/feb/10/flappy-bird-is-dead-but-brilliant-mechanics-made-it-fly)).  
**Commercial note:** mobile free/IAP history differs from Steam paid; on Steam, pure one-button skill games need **strong identity + leaderboards/challenges** or they read as tech demos. Better as **a verb inside a larger fantasy** (tension game, physics climb) than as bare endless runner clones.

### F. One-verb action + build/meta progression

**Archetype:** Vampire Survivors  
**Rules surface:** move; weapons fire automatically; choose upgrades.  
**Depth source:** build space, synergies, collection, short runs.  
**Commercial note:** ~**$4.99** base — textbook **$3–$10** smash; genre now **heavily saturated** with survivors-likes. Invention bar is higher than 2022.

### G. Constraint solvers with social/cozy personality

**Archetype:** Is This Seat Taken?  
**Rules surface:** seat people by preferences/pet peeves.  
**Depth source:** constraint satisfaction + readable character comedy; low pressure.  
**Commercial note:** **$9.99**; strong review score; third-party estimates ~**160k+ units / ~$1.4M+** gross (tool-dependent) ([Steam](https://store.steampowered.com/app/3035120/Is_This_Seat_Taken/); [Raijin](https://raijin.gg/app/3035120/Is_This_Seat_Taken)). Proves **simple rules + sharp fantasy** can clear seven figures without horror virality.

### H. Tension / stakes vignettes

**Archetype:** Buckshot Roulette  
**Rules surface:** short high-stakes rounds; items modify odds; ~15–20 minute arc.  
**Depth source:** probability theater + item interactions + atmosphere; clip-native.  
**Commercial note:** **$2.99**; **1M Steam in ~1–2 weeks**; later milestones **2M / 4M+** copies announced through 2024 ([GamesRadar](https://www.gamesradar.com/games/horror/team-behind-steams-latest-mega-hit-was-just-joking-when-it-said-it-would-double-our-sales-but-then-its-horror-gambling-game-actually-sold-1-million-copies/); [WN Hub](https://wnhub.io/news/investment/item-46509)). **Best in-band proof** for this repo’s recommended Game 1 format — *structure*, not shotgun clone ([`GAME_PLAN.md`](../GAME_PLAN.md)).

### I. “Bretzel?” — unresolved reference

No widely recognized Steam prestige title named **Bretzel** matching the Baba / Parabox peer set. Nearby hits:

- **Bretzel Games** — Android casual/puzzle portfolio studio ([bretzelgames.com](https://bretzelgames.com/)).  
- Jam/itch titles (*Où est ma bretzel ?*, *Hansel & Bretzel*).  
- Fighting-game slang (“pretzel motion”) — unrelated product.

Treat “Bretzel?” as **uncertain oral reference**. Candidates to re-prompt the user: a jam physics/puzzle toy, a misheard prestige title, or a private prototype name. Do **not** block strategy on it.

---

## 4. Market reality at $3–$10

### 4.1 The band’s job

| Price | Typical buyer expectation | Best product shapes |
|---|---|---|
| **$2.99–$4.99** | Impulse; “evening toy”; high clip potential | Vignettes, survivors-likes, tiny physics toys, idle toys |
| **$5–$7.99** | Short campaign or strong skill toy | One-control inventions, compact puzzle packs, arcade machines |
| **$8–$10** | “Real game, small” | Cozy constraint puzzles, lean coin-machine, polished short adventures |

Hobbyist/indie pricing research consistently places **hobbyist titles under $10** and broader indie under $20 ([OP Game Marketing 2024 analysis summary](https://opgamemarketing.substack.com/p/the-2024-indie-and-aa-game-market)).

### 4.2 Power-law honesty

Steam indie revenue is **extremely top-heavy**:

- Indie approached ~**48%** of Steam full-game revenue YTD 2024, but growth was dominated by mega-outliers; most other 2024 indies combined earned less than the top titles ([VG Insights / Sensor Tower report coverage](https://wnhub.io/news/stores-and-publishing/item-45826); [GameDevReports](https://gamedevreports.substack.com/p/video-game-insights-indie-games-on)).  
- Among 2024 AA/Indie/Hobbyist titles clearing even a tiny revenue floor, **~85% of indie revenue sat in the top 10%** of titles; self-published median revenue in one 5k+ game dataset was on the order of a few thousand dollars vs higher medians with publishers ([Josh Hardy summary of IndiegameJordan dataset](https://www.joshhardy.co.uk/post/indie-game-revenue-on-steam-key-insights-from-2024-data-analysis)).

**Implication for inventive simple games:** novelty raises *ceiling* and *wishlist conversion*, but does not cancel the lottery. Strategy should optimize for **demo clarity + clip moments + review score**, then **sequence multiple small ships** (this repo’s multi-game plan), not bet the farm on one Baba-scale opus.

### 4.3 Price–ambition mismatch (critical for “simple-deep”)

| Title | Approx. list | Rough commercial signal | Fit for $3–$10 first ship |
|---|---|---|---|
| Buckshot Roulette | $2.99 | Multi-million units | **Excellent format reference** |
| Vampire Survivors | $4.99 | Genre-defining smash | Format strong; lane crowded |
| Getting Over It | $7.99 | Multi-million / streamer classic | Strong if clip identity is sharp |
| Particul (repo comp) | ~$1.99 | Modest idle toy | Catalog / practice ship |
| Is This Seat Taken? | $9.99 | ~mid-six-figures+ gross (est.) | Strong cozy-constraint pattern |
| Balatro | $14.99 | 5M+ units | Design idol; **above band** |
| Baba Is You | ~$14.99 | 1M–2M owners (SteamSpy band) | Design idol; **above band / slow** |
| Patrick’s Parabox | ~$19.99 | ~hundreds of k units (est.) | Design idol; **premium / slow** |

**Rule of thumb:** if your depth requires **hundreds of hand-authored levels** to feel “complete,” you are usually building a **$15–$25** product. If depth comes from **runs, physics mastery, or combinatorial builds**, you can honestly sit at **$3–$10**.

### 4.4 Median vs breakout inside the band

Third-party snapshots of small physics/puzzle titles at $2–$10 show **wide dispersion** — e.g. tiny pool-physics toys in the low tens of thousands of dollars gross versus magnet/platformer puzzles in the mid six figures ([SteamData.AI POOOOL](https://steamdata.ai/en-US/game/2935840/pooool); [Raijin Mind Over Magnet](https://raijin.gg/app/2685900/Mind_Over_Magnet/sales-revenue)).  

**Outside-the-box is necessary but not sufficient.** The differentiating commercial ingredients are:

1. Instantly understandable invention  
2. Emotional spike (fear, absurdity, cozy delight, rage-climb)  
3. Demo that *is* the game  
4. Trailer that teaches in silence  

---

## 5. Case lessons (compressed)

### Baba Is You — invent the ontology

- Meaning only from interactable rules (no intrinsic ice/fire defaults) expands possibility space ([Puzzlebyrinth](https://puzzlebyrinth.com/en/articles/designer-teikari)).  
- Level design: interaction first → reverse-engineer level ([Game Developer](https://www.gamedeveloper.com/design/designing-i-baba-is-you-i-s-delightfully-innovative-rule-writing-system)).  
- Support player surprise (stacked words) even when expensive to implement.  
- **Ship lesson:** jam prototype → years of level craft → premium price.

### Patrick’s Parabox — one recursive axiom

- Single structural idea (boxes contain spaces / self) generates mechanics from consequences ([Game Developer](https://www.gamedeveloper.com/design/patrick-s-parabox-)).  
- “No filler” level ethic → high craft cost.  
- **Ship lesson:** excellence award path; slow; price up.

### Balatro — public language + private chaos

- Poker supplies vocabulary; jokers supply personality and discovery ([Birdor](https://blog.birdor.com/balatro-product-loop-success-case-study/)).  
- Easy first yes; second run almost inevitable.  
- Publisher + multiplatform mattered for scale.  
- **Ship lesson:** steal the *product loop*, not the poker skin; expect content/balance load.

### Getting Over It / Foddy toys — emotion as system

- One control scheme; stakes from lost progress; commentary frames frustration ([Game Developer](https://www.gamedeveloper.com/design/designer-interview-the-aesthetics-of-frustration-in-i-getting-over-it-i-); [Vulture](https://www.vulture.com/article/getting-over-it-with-bennett-foddy-interview-fun-failure.html)).  
- **Ship lesson:** in-band pricing works when the fantasy is a **verb people want to watch**.

### Buckshot Roulette — vignette stakes

- Short rules, escalating items, horror theater, streamer-native.  
- **Ship lesson:** best alignment with this repo’s $2.99–$7.99 Game 1 recommendation — **original premise**, same *format*.

### Vampire Survivors — subtract action verbs, add build verbs

- Remove aiming/shooting micro; keep movement + draft choices.  
- **Ship lesson:** $5 miracles create clone markets; invent a new *fantasy*, not another garlic aura.

---

## 6. Ranked templates — inventive simple games for $3–$10 Steam

Scoring lens (relative 1–10): **invention clarity**, **ship speed for solo**, **sales plausibility @ $3–$10**, **demo/clip fitness**, **saturation risk**.  
Aligned with repo hard rule: **one pure category per product**.

| Rank | Template | Score | Price band | Verdict |
|---|---|---|---|---|
| **1** | **Stakes vignette** — one room, one readable invention, escalating modifiers | **9.1** | $2.99–$7.99 | **Best first ship** (matches existing Game 1 plan) |
| **2** | **One-control physics toy** — continuous control + progress stakes + identity | **8.4** | $4.99–$9.99 | Strong if trailer is a joke people retell |
| **3** | **Constraint theater** — place/assign under witty rules (seat/schedule/pack) | **8.0** | $6.99–$9.99 | High review potential; softer virality |
| **4** | **Arcade machine fantasy** — coin pusher / claw / ticket physics (pure) | **7.9** | $5–$10 | Hot lane; differentiate or die (Game 2) |
| **5** | **One-verb build engine** — auto-action + draft synergies (non-survivors fantasy) | **7.2** | $3.99–$7.99 | Ceiling high; saturation high |
| **6** | **Idle particle / automation toy** | **6.8** | $1.99–$4.99 | Fastest code; modest ceiling (Game 3) |
| **7** | **Micro puzzle-invention pack** — one new axiom, 40–80 levels | **6.5** | $4.99–$9.99 | Viable if axiom is GIF-obvious |
| **8** | **Rule-rewriting / linguistic meta-puzzle** | **5.2** | often $12–$20 honest | Design peak; wrong first-band ambition |
| **9** | **Recursive spatial opus** (Parabox-class) | **4.6** | often $15–$20 | Years of levels; prestige, not fast catalog |
| **10** | **Balatro-class combo deckbuilder** | **4.3** | often $12–$20 | Ceiling legendary; content + saturation kill “fast” |
| **11** | **Bare one-button endless** | **3.5** | $0.99–$3.99 | Needs extraordinary tuning + identity |
| **12** | **Genre mash “simple systems kitchen sink”** | **2.0** | any | Violates store clarity & repo rule |

---

### Template details (how to build / how to sell)

#### T1 — Stakes vignette (Rank 1)

- **Loop:** Enter → learn 1 system → escalate via items/modifiers → win/lose in 10–25 min → optional challenge modes.  
- **Invention test:** Can a muted 12s video teach the fantasy?  
- **Do:** Original ritual/stakes/antagonist.  
- **Don’t:** Clone shotgun roulette rules.  
- **Why commercial “outside the box”:** Familiar *shape* (gamble/duel/ritual), unfamiliar *machine*.  
- **Repo mapping:** Recommended Game 1.

#### T2 — One-control physics toy (Rank 2)

- **Loop:** Master awkward consistent physics; optional ghosts/times/checkpoints philosophy is a design choice (Foddy: loss creates stakes).  
- **Invention test:** Is the control scheme itself the joke *and* the skill?  
- **Do:** Strong character silhouette + fail montage trailer.  
- **Don’t:** Generic ragdoll without a mountain to climb (literal or metaphorical).  
- **Repo mapping:** Adjacent to coin-machine physics taste; keep as **separate** product if pursued.

#### T3 — Constraint theater (Rank 3)

- **Loop:** Read constraints → arrange entities → satisfy → new cast/scenario.  
- **Invention test:** Constraints are funny/human, not abstract sudoku.  
- **Do:** Scenario variety as content; cozy or dark-comedy tone commitment.  
- **Don’t:** Dry logic without personality (competes with free web puzzles).  

#### T4 — Arcade machine fantasy (Rank 4)

- **Loop:** Insert → physics → payout dopamine → meta upgrades *or* pure sandbox (pick one identity).  
- **Comps:** RACCOIN, The Coin Game, adjacent gambling-feel (CloverPit is *not* a pusher).  
- **Risk:** Post-RACCOIN clone blindness.  
- **Repo mapping:** Game 2.

#### T5 — One-verb build engine (Rank 5)

- **Loop:** Survive/score via automatic systems; player chooses synergies.  
- **Invention test:** Fantasy ≠ “survive waves in a field.” Need a new verb/fantasy frame.  
- **Risk:** Survivors-like fatigue.

#### T6 — Idle particle tycoon (Rank 6)

- **Loop:** Emit → collect → automate → prestige.  
- **Invention test:** Particles must *feel* unique; numbers alone are commodity.  
- **Repo mapping:** Game 3 / Particul-like.

#### T7 — Micro puzzle-invention pack (Rank 7)

- **Loop:** Teach one axiom in 5 levels; twist for 40–80.  
- **Honest pricing:** $4.99–$9.99 only if axiom is novel; else dies in wishlist void.  
- **Ship tip:** Jam the axiom hard before writing 80 levels.

#### T8–T10 — Prestige systems (Ranks 8–10)

Study relentlessly; **do not schedule as first $5 Steam exe** unless willing to price up and spend years. Use as **design schooling** for how to reverse-engineer levels from interactions.

---

## 7. Practical checklist — “is this outside the box enough to sell?”

Score each 0–2. **Ship only if ≥ 8/12** and trailer works silent.

1. **One-sentence invention** a stranger repeats correctly.  
2. **GIF test:** novelty visible without UI dump.  
3. **Verb count ≤ 3** for core play.  
4. **Depth from interactions**, not new buttons every hour.  
5. **Emotional spike** identifiable (dread / absurd / cozy / triumph).  
6. **Session** fits commute/evening (or clear “short campaign”).  
7. **Price honesty** vs content hours.  
8. **Pure category** on Steam page.  
9. **Demo = vertical slice of the real loop.**  
10. **Clip moment** exists by week 2 of production.  
11. **Not a thin clone** of the current chart darling.  
12. **Solo finishable** without a content mountain that forces $20 pricing.

---

## 8. Implications for this repository

Existing plan already points at the highest-EV in-band inventive shapes:

| Slot | Plan category | Simple-deep reading |
|---|---|---|
| Game 1 | Tension / horror vignette | **T1** — invent a *new* stakes machine |
| Game 2 | Coin-machine | **T4** — physics toy with arcade fantasy |
| Game 3 | Idle / particle tycoon | **T6** — automation depth, modest ceiling |

**Do not** pivot Game 1 into Baba/Parabox/Balatro clones to chase “prestige inventiveness.” Chase **invention clarity at vignette scope**. Use Baba/Parabox as craft references for *how systems teach themselves*; use Buckshot/Getting Over It/Vampire Survivors/Is This Seat Taken as **pricing and session** references.

Optional later catalog experiments if Games 1–3 fund them: **T3 constraint theater** or a **T7 micro-axiom puzzle** priced honestly.

---

## 9. Ranked “invention sparks” (prompt seeds, not GDDs)

Use as jam prompts; keep pure category.

1. **Ritual machine** — one table, one resource (not shells), items rewrite odds.  
2. **Office physics climb** — one tool, open map of mundane objects, no checkpoints.  
3. **Preference packing** — seat/stack/schedule chaotic humans or creatures.  
4. **Ticket carnival** — pure pusher/claw with one meta twist (not roguelike kitchen sink).  
5. **Factory bloodlight** — survivors-like fantasy that is *not* horde survival (e.g. you are the environment).  
6. **Sentence toys (micro)** — 40 levels, one linguistic axiom — only if priced/scoped as micro.  
7. **Particle cathedral** — idle where aesthetics *are* the progression flex.

---

## 10. Sources

### Design & interviews
- Hempuli / Baba rule system: [Game Developer — Designing Baba Is You’s rule-writing system](https://www.gamedeveloper.com/design/designing-i-baba-is-you-i-s-delightfully-innovative-rule-writing-system)  
- Hempuli philosophy: [Puzzlebyrinth — Inside Arvi Teikari’s Philosophy](https://puzzlebyrinth.com/en/articles/designer-teikari)  
- Subtractive design lineage: [Puzzlebyrinth — When Fewer Verbs Make a Richer Game](https://puzzlebyrinth.com/en/articles/subtractive-design-fewer-verbs)  
- Patrick Traynor: [Game Developer — Designing Patrick’s Parabox](https://www.gamedeveloper.com/design/patrick-s-parabox-) · [patricksparabox.com](https://www.patricksparabox.com/) · [Wikipedia](https://en.wikipedia.org/wiki/Patrick%27s_Parabox)  
- Width vs depth: [Rexcellent Games](https://rexcellentgames.com/width-vs-depth/)  
- Foddy / Flappy tuning: [The Guardian](https://www.theguardian.com/technology/2014/feb/10/flappy-bird-is-dead-but-brilliant-mechanics-made-it-fly)  
- Getting Over It: [Game Developer interview](https://www.gamedeveloper.com/design/designer-interview-the-aesthetics-of-frustration-in-i-getting-over-it-i-) · [Vulture](https://www.vulture.com/article/getting-over-it-with-bennett-foddy-interview-fun-failure.html)

### Commercial / sales / pricing
- Balatro launch: [GamesIndustry.biz (archive)](https://web.archive.org/web/20240521174217/https:/www.gamesindustry.biz/balatro-grossed-1m-in-eight-hours) · [Birdor case study](https://blog.birdor.com/balatro-product-loop-success-case-study/) · [PocketGamer.biz / Playstack](https://www.pocketgamer.biz/how-playstack-bet-on-balatro-and-won-big/) · [The Verge — 5M](https://www.theverge.com/2025/1/21/24348727/balatro-5-million-copies-the-game-awards) · [Steam](https://store.steampowered.com/app/2379780/Balatro/)  
- Baba owners/price bands: [SteamSpy](https://www.steamspy.com/app/736260) · [SteamPulse metadata](https://steampulse.org/game/736260/metadata)  
- Patrick’s Parabox estimates: [SteamPulse](https://steampulse.org/game/1260520) · [Steam](https://store.steampowered.com/app/1260520/Patricks_Parabox/)  
- Buckshot Roulette: [GamesPress 1M](https://www.gamespress.com/Viral-Horror-Hit-Buckshot-Roulette-Crosses-1-Million-Copies-Sold-on-St) · [GamesRadar](https://www.gamesradar.com/games/horror/team-behind-steams-latest-mega-hit-was-just-joking-when-it-said-it-would-double-our-sales-but-then-its-horror-gambling-game-actually-sold-1-million-copies/) · [WN Hub 4M](https://wnhub.io/news/investment/item-46509) · [Steam](https://store.steampowered.com/app/2835570/Buckshot_Roulette/)  
- Vampire Survivors price: [Steam](https://store.steampowered.com/app/1794680/Vampire_Survivors/) · [Steambase](https://steambase.io/games/vampire-survivors/price)  
- Getting Over It price/sales tools: [Steam](https://store.steampowered.com/app/240720/Getting_Over_It_with_Bennett_Foddy/) · [Steamograph](https://steamograph.com/games/240720) · [Raijin](https://raijin.gg/app/240720/Getting_Over_It_with_Bennett_Foddy)  
- Is This Seat Taken?: [Steam](https://store.steampowered.com/app/3035120/Is_This_Seat_Taken/) · [Raijin sales](https://raijin.gg/app/3035120/Is_This_Seat_Taken/sales-revenue)  
- Indie market concentration: [WN Hub on VG Insights 2024](https://wnhub.io/news/stores-and-publishing/item-45826) · [GameDevReports](https://gamedevreports.substack.com/p/video-game-insights-indie-games-on) · [Sensor Tower VGI PDF](https://app.sensortower.com/vgi/assets/reports/VGI_Global_Indie_Games_Market_Report_2024.pdf) · [Josh Hardy / 2024 dataset summary](https://www.joshhardy.co.uk/post/indie-game-revenue-on-steam-key-insights-from-2024-data-analysis) · [OP Game Marketing](https://opgamemarketing.substack.com/p/the-2024-indie-and-aa-game-market)  
- Small-title dispersion examples: [SteamData.AI POOOOL](https://steamdata.ai/en-US/game/2935840/pooool) · [Raijin Mind Over Magnet](https://raijin.gg/app/2685900/Mind_Over_Magnet/sales-revenue)

### Bretzel ambiguity
- [Bretzel Games](https://bretzelgames.com/) · [Où est ma bretzel ? (itch)](https://projetbretzel.itch.io/ouestmabretzel) · [Hansel & Bretzel (itch)](https://tobler0ne.itch.io/hansel-bretzel)

### Internal
- [`docs/GAME_PLAN.md`](../GAME_PLAN.md)  
- [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## 11. One-line strategy

**Sell a legible invention at vignette or toy scope for $3–$10; study Baba/Parabox/Balatro for depth craft, not for first-product scope or price.**
