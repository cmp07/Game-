# Generative / Adaptive Game Design: What Ships vs What Stays in Papers

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-) (`sandpile-tycoon` planning workspace)  
**Date:** August 2026  
**Scope:** Academic + industry survey of AI Directors, dynamic difficulty, experience management, personalized levels, and “the game that learns you”—with concrete patterns a solo/small team can ship (no LLM required).  
**Lens:** Aligns with [`docs/GAME_PLAN.md`](../GAME_PLAN.md): pure-category Steam products at $0.99–$10; especially Game 1 (tension/horror vignette), Game 2 (coin-machine), Game 3 (idle/particle tycoon).

---

## 0. Verdict (read this first)

**What actually works in shipping games is almost never “the game learns you” as ML.** It is **authored systems that measure a few player signals and re-schedule pre-validated content** so pacing, threat, and surprise stay in a designed band.

| Claim | Reality in shipping titles |
|---|---|
| “AI Director” | Finite-state pacing + spawn budgets + intensity proxy (L4D, Alien Isolation director layer, Dead Space remake Intensity Director) |
| “Adaptive difficulty” | Hidden rank / inventory levers (RE4), visible meters (God Hand), rubber-band items (Mario Kart), opt-in assists (Celeste, Hades God Mode) |
| “Personalized levels” | Parameterized templates + player model search in research; **constrained room templates + rules** in Spelunky-likes that ship |
| “Shapes around you” | Memory + relationship graphs (Nemesis), weighted story beats (PaSSAGE-style), event decks with cooldowns—not generative world models |
| Full drama managers / EDPCG / RL directors | Strong papers, rare as product cores; too authoring-heavy or evaluation-heavy for small teams |

**For this repo’s first products:** ship a **Director Lite** (intensity meter + event deck + relax windows), not personalized ML level gen. Fake “learns you” with **short-horizon telemetry + hand-authored bricks**. Skip LLM narrative unless it is a deliberate later experiment.

---

## 1. Taxonomy: five things people confuse

Adaptive design is not one technology. Treat these as separate product bets.

### 1.1 Dynamic Difficulty Adjustment (DDA)

Change **challenge amplitude** (enemy HP/AI, resource density, timers) so the player stays near a target success rate or “flow channel.”

- Classic research: Hunicke & Chapman’s **Hamlet** on Half-Life—inventory-theory view of ammo/health supply vs demand ([Hamlet PDF](https://users.cs.northwestern.edu/~hunicke/pubs/Hamlet.pdf); Hunicke, ACE 2005, [DOI](https://doi.org/10.1145/1178477.1178573)).
- Shipping exemplars: Resident Evil 4 (hidden rank), God Hand (visible meter), Mario Kart (rubber banding / item bias).

### 1.2 Dramatic pacing / AI Director

Change **threat frequency and staging**, not necessarily “make it easier.” Booth’s L4D talk is explicit: **adjust pacing (frequency), not difficulty (amplitude)** ([Valve PDF](https://steamcdn-a.akamaihd.net/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf)).

### 1.3 Experience management / drama management

An omniscient manager steers **narrative beats** toward author goals while preserving agency (Laurel → Bates → Weyhrauch MOE → search-based DM). Survey framing: experience management as hypernym of DDA, adaptive mechanics, player-adaptive games (Thue & related AIIDE work; [Structured Analysis of EM Techniques](https://doi.org/10.1609/aiide.v15i1.5241); multiplayer challenges in [Ontañón & Zhu, arXiv:1907.02349](https://doi.org/10.48550/arxiv.1907.02349)).

### 1.4 Experience-driven PCG (EDPCG)

Generate or select **content** (levels, rules, events) using a model of player experience ([Yannakakis & Togelius, IEEE TAC 2011](https://doi.org/10.1109/t-affc.2011.6); [author PDF](https://yannakakis.net/wp-content/uploads/2019/02/EDPCG.pdf)). Related: personalized Super Mario levels ([Shaker et al., AIIDE 2010](https://doi.org/10.1609/aiide.v6i1.12399)).

### 1.5 Personalized identity / memory systems

Track **who you are to the world**—playstyle tags, rival NPCs, remembered insults—so the fiction feels bespoke (PaSSAGE player types; Mordor Nemesis). This is often the strongest “learns you” *feeling* per engineering dollar.

---

## 2. Theory that still earns its keep

### 2.1 Flow (challenge–skill channel)

Csikszentmihalyi’s flow: anxiety when challenge ≫ skill, boredom when skill ≫ challenge. Game design applications emphasize clear goals, immediate feedback, and a sense of control—not only numeric balance (Jenova Chen, *Flow in Games*, [PDF](https://jenovachen.com/flowingames/Flow_in_games_final.pdf); overview at [flowingames](http://www.jenovachen.com/flowingames/introduction.htm)).

**Product implication:** Adaptation that removes control (rubber band that steals a deserved win) violates flow even if the numbers look “balanced.” Prefer **pacing relief** and **player-owned difficulty** over silent score-nerfing.

### 2.2 Experience management stack

A practical EM loop (industry + academia converge here):

1. **Observe** cheap signals (damage, deaths, idle time, resources, distance to goal, input cadence).
2. **Estimate** a scalar (intensity, menace, game rank, heat).
3. **Act** by selecting from a **closed set** of designer-validated interventions.
4. **Cooldown** so interventions do not thrash.

Papers escalate this into search (SBDM), planning (PDDL mediation), RL, AlphaZero-style adversarial EM ([AIIDE 2025 AEM](https://doi.org/10.1609/aiide.v21i1.36828)). Shipping games almost always stop at step 3 with tables and FSMs.

### 2.3 EDPCG components (useful as a checklist, not a mandate)

Yannakakis & Togelius decompose EDPCG into: content representation → player experience model → evaluator → generator/search. Small teams can implement a **degenerate EDPCG**: skip learned models; use **hand rules** as the “model” and **weighted random from tagged bricks** as the “generator.”

### 2.4 Preference / playstyle modeling (lightweight)

PaSSAGE updates weights for Laws-style player types (Fighter, Tactician, Storyteller, …) from tagged choices, then picks storylets that match ([Thue et al., AIIDE 2007 PDF](https://www.cs.uky.edu/~sgware/reading/papers/thue2007interactive.pdf)). Evaluations of drama managers in Anchorhead stress that **player modeling + subtle hints** beat author-only interestingness rules ([Sharma et al.](https://sites.cc.gatech.edu/fac/ashwin/papers/er-07-15.pdf); [Computational Intelligence journal version](https://onlinelibrary.wiley.com/doi/10.1111/j.1467-8640.2010.00355.x)).

---

## 3. Shipping case studies: what worked and why

### 3.1 Left 4 Dead — Adaptive Dramatic Pacing (canonical Director)

**Source:** Michael Booth, “The AI Systems of Left 4 Dead,” Valve ([PDF](https://steamcdn-a.akamaihd.net/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf)); community synthesis on [L4D Wiki: The Director](https://left4deadwiki.com/wiki/The_Director).

**Mechanism (simplified):**

- Estimate each survivor’s **emotional intensity** (damage, incap, proximity to combat)—crude, by design.
- Track **max** intensity across the team.
- State machine roughly: **Build Up → Sustain Peak → Peak Fade → Relax** (~30–45s low threat).
- Peak Fade waits for a **natural combat break** before starting Relax (so the rest period is not eaten by mop-up).
- Populate threats procedurally; **same maps, different peaks**.

**Booth’s punchline that small teams should tattoo on the wall:**

- Algorithm adjusts **pacing, not difficulty**.
- **Simple algorithms** + crude intensity estimation still produce compelling schedules.
- Replayability comes from **where/when peaks land**, not from rewriting the campaign.

**L4D2 add-on:** limited **dynamic map mutations** (path/weather/event variants) when the Director judges team performance—still authored variants, not freeform gen.

**Steal for indie:** intensity scalar + phase FSM + spawn budget + relax timer. Do **not** start with full infected AI fidelity.

### 3.2 Resident Evil 4 — Invisible Game Rank

**Sources:** industry writeups summarizing datamined/community-known rank behavior ([Game Developer: Game Changers — Dynamic Difficulty](https://www.gamedeveloper.com/design/game-changers-dynamic-difficulty); [CBR on RE4 DDA](https://www.cbr.com/resident-evil-4-dynamic-difficulty-capcom/)).

**Mechanism pattern:**

- Maintain a hidden **rank** from recent performance (deaths, damage, accuracy proxies).
- Map rank → enemy aggression, group tactics, resource generosity.
- Players experience “the game is fair and scary,” not “a slider moved.”

**Why it ships well:** interventions are **local and deniable** (this encounter felt harder), and Capcom did not market it as adaptive AI—reducing betrayal risk.

**Risk:** hardcore players who detect the system may feel cheated if ease-downs are too large. Mitigate with **slow rank velocity** and **asymmetric easing** (help via resources more than by making enemies stupid).

### 3.3 God Hand — Visible DDA as a mechanic

**Sources:** [Game Developer DDA feature](https://www.gamedeveloper.com/design/game-changers-dynamic-difficulty); [Wikipedia: God Hand](https://en.wikipedia.org/wiki/God_Hand).

**Mechanism:** on-screen difficulty gauge fills on successful offense/defense, empties on taking hits; levels 1–3–**Die** change AI aggression and rewards.

**Lesson:** transparency can **increase** agency. Players *play the meter*. Contrast with RE4’s invisibility—same director (Mikami lineage), opposite UX philosophy. Choose based on fantasy: horror often wants invisibility; arcade fantasy wants the meter.

### 3.4 Alien: Isolation — Macro director + micro hunter (no cheating)

**Sources:** [Game Developer / AI and Games: Perfect Organism](https://www.gamedeveloper.com/design/the-perfect-organism-the-ai-of-alien-isolation); [Revisiting Isolation AI](https://www.gamedeveloper.com/design/revisiting-the-ai-of-alien-isolation); Hope, GDC “Building Fear in Alien: Isolation.”

**Architecture:**

| Layer | Knows player location? | Job |
|---|---|---|
| **Director (macro)** | Yes | Menace gauge; periodically bias alien toward player’s *region*; force backstage (vents) when menace peaks |
| **Alien (micro)** | No (sensors only) | Behaviour tree (~100+ nodes), search paths that are **deliberately sub-optimal**, learnable unlocks over campaign |

**Design slogans worth stealing:**

- **Psychopathic serendipity** — antagonist is “in the right place” without scripted jumpscares every time.
- Menace from **proximity / LOS / tracker pressure**, not only damage.
- Behaviour unlocks that feel like “it learned,” but **do not unlock from death causes** (avoids unfair secret punishment).
- Almost no teleport cheating across a long campaign.

**Small-team cut:** you do not need Isolation’s full sensor stack. You need **(a)** a pressure scheduler and **(b)** an agent that searches with imperfect information. For a vignette, (a) alone can carry.

### 3.5 Dead Space Remake — Intensity Director as scare deck

**Sources:** [Game Developer: nightmarish systems of the remake](https://www.gamedeveloper.com/design/diving-into-the-nightmarish-new-systems-of-the-dead-space-remake); [Destructoid Intensity Director explain](https://www.destructoid.com/dead-space-remakes-intensity-director-explained/).

**Mechanism pattern:**

- Library of **content bricks** (~hundreds): spawns, fake-outs, light/audio stings, environmental bursts.
- Bricks graded on a **stress scale** (reported ~1–11).
- Director spends stress budget to keep hallways from going “solved” during backtracking.
- Audio propagation makes empty ship feel occupied.

**Steal for tension vignette:** a **weighted event deck** with stress costs, fake-out ratio, and “one more enemy” tails beats writing a single scripted scare chain.

### 3.6 Middle-earth: Shadow of Mordor — Nemesis (personalized without ML)

**Sources:** [Game Developer: Designing Mordor’s Nemesis](https://www.gamedeveloper.com/design/designing-i-shadow-of-mordor-i-s-nemesis-system); Polygon/GDC coverage of orc “hideous snowflakes.”

**Mechanism pattern:**

- Procedural NPC traits + hierarchy.
- **Memory** of player actions (who killed whom, who fled, who was humiliated).
- Systems that **build on** player actions rather than reset them.
- Sports metaphor: framework for emergent stories; players fill blanks.

**Steal for small scope:** you do not need an orc army. One rival with 6 traits + 3 remembered events already sells “the game remembers me.”

### 3.7 Spelunky — Constrained PCG that feels authored

**Sources:** Derek Yu interviews; [tinysubversions Spelunky generator lessons](https://tinysubversions.com/spelunkyGen2/index.html); [Spelunky’s Procedural Space](https://tinysubversions.com/2009/09/spelunkys-procedural-space/index.html).

**Mechanism:**

- Level = grid of rooms; each room type has **hand templates**.
- Guaranteed path topology; probabilistic tiles + obstacle blocks.
- Enemies/traps placed by **rules**, not by freeform noise.
- Destructibility forgives generator imperfections.

**Research fork:** player-adaptive Spelunky generation exists ([IEEE CIG 2015](https://doi.org/10.1109/cig.2015.7317948)); users liked adaptation but were **especially critical of making the game easier**. That matches industry caution about silent easy-mode.

### 3.8 Hades — Authored rooms + player-facing adaptation

**Sources:** Supergiant designer notes via [Kotaku on Hades level design](https://kotaku.com/hades-level-design-is-less-random-than-it-seems-1845254545); [Heat/Pact](https://kotaku.com/everything-you-need-to-know-about-hades-endgame-1845239105); [God Mode interview](https://www.inverse.com/gaming/hades-god-mode-interview).

**Patterns:**

- Biomes have **design principles**; “random” rooms are curated sets.
- Difficulty ramps by depth + encounter templates.
- **Pact of Punishment / Heat:** player-owned challenge modifiers.
- **God Mode:** escalating damage resistance after deaths—adaptation as accessibility, not stealth.

**Steal:** for Game 1–3, prefer **opt-in heat / assists** over silent DDA when skill fantasy matters.

### 3.9 Mario Kart — Obvious rubber banding (anti-pattern and tool)

**Sources:** [Game Developer: Secrets of DDA](https://www.gamedeveloper.com/design/more-than-meets-the-eye-the-secrets-of-dynamic-difficulty-adjustment).

Rubber banding and position-biased items keep races close but are **legible as cheating**. Fine for party chaos; poison for “I mastered this.” Coin-pusher games can use **soft** payout variance; avoid hard “you were ahead so we steal your jackpot.”

### 3.10 Celeste Assist Mode — Transparency as trust

**Sources:** [Vice on Assist Mode copy](https://www.vice.com/en/article/celeste-assist-mode-change-and-accessibility/); UX analyses of Assist Mode trust.

Assist Mode shows that **player-authored difficulty** can be on-brand if copy respects the player. Pair with a default “designed” path. For a $3 horror vignette, a small Assist (longer timers, gentler tells) may retain more players than invisible crutches.

---

## 4. Research that is strong—but rarely your v1

| Research line | What it proves | Why small teams defer it |
|---|---|---|
| Search-based drama management (Anchorhead, SBDM) | Managers can improve rated experience | Needs story graph + evaluation function + playtest instrumentation |
| PaSSAGE-style story selection | Playstyle models can raise enjoyment for some players | Needs many tagged storylets |
| EDPCG Mario personalization | Levels can optimize predicted fun/challenge | Needs survey/preference data or proxy models |
| RL / AlphaZero experience managers | Better dead-end avoidance in intentional stories | Authoring PDDL/intent models; not Steam-demo scope |
| Biometric / affective DDA | Physiology can track stress | Hardware, privacy, calibration hell |
| LLM live narrative | Novel text/quests | Consistency, moderation, cost, determinism; poor fit for $3 offline vignette |

**Rule of thumb:** if the paper’s evaluation needs **N≥ dozens of players + questionnaires**, treat it as a **post-1.0 R&D track**, not a vertical-slice dependency.

---

## 5. How to fake “shapes around you” (no LLM)

Players say “it adapted to me” when they observe **contingency**: the world changed *because of what I did*, in a way that feels intentional.

### 5.1 Contingency > intelligence

| Cheap contingency | Feels like |
|---|---|
| Event that only fires if you camped / rushed / missed a tell | “It noticed my strategy” |
| Rival quotes your last failure | “It remembers me” |
| Second playthrough mutates one rule you exploited | “It learned” |
| Resource starvation after greedy spends | “The economy bites back” |
| Fake-out scare after you braced for a real spawn | “It’s toying with me” |

### 5.2 The four illusions

1. **Pacing illusion** — peaks and valleys (L4D).  
2. **Menace illusion** — presence without constant lethality (Isolation).  
3. **Memory illusion** — 3–7 sticky facts about the player (Nemesis-lite).  
4. **Variety illusion** — shuffle authored bricks so routes never feel solved (Dead Space / Spelunky).

You can ship all four without neural nets.

### 5.3 Signal set that is “good enough”

Track only what you will **act on** (Hamlet’s lesson: measure inventory pressure you can relieve).

**Universal (any genre):**

- Success streak / fail streak (last *k* challenges)
- Time since last meaningful progress
- Resource slack (ammo, coins, lives, sanity)
- Input entropy / idle (AFK or confused)
- Optional: explicit self-report (“Too hard / Fine / Too easy”) every N minutes—Jenova Chen’s active DDA idea

**Horror vignette extras:** time spent in safe vs unsafe zones; flashlight/torch uptime; consecutive successful hides; jump-scare desensitization (if player doesn’t flinch inputs, escalate *uncertainty*, not volume).

**Coin-machine extras:** session loss streak; time-to-jackpot; tilt/near-miss rate (ethical caution—see §8).

**Idle tycoon extras:** offline return satisfaction; upgrade click latency; prestige readiness.

---

## 6. Concrete design patterns a small team can ship

Each pattern lists: **intent**, **data**, **actuation**, **authoring cost**, **fit for this repo**.

### Pattern A — Intensity Phase Machine (Director Lite)

**Intent:** L4D-style drama without full spawn tech.  
**Data:** `intensity ∈ [0,1]` from damage, fails, proximity-to-threat, loud actions. Decay over time.  
**Actuation:** states `BUILD | PEAK | FADE | RELAX` with timers and spawn multipliers.  
**Authoring:** one tuning table; a few encounter prefabs.  
**Fit:** **Game 1 (primary)**. Also bosses in later TD experiments.

```text
each tick:
  intensity = max(intensity * decay, measure())
  if state==BUILD and intensity > peakEnter: state=PEAK; startPeakTimer()
  if state==PEAK and peakTimerDone: state=FADE
  if state==FADE and combatQuiet: state=RELAX; startRelaxTimer()
  if state==RELAX and relaxDone and intensity < peakEnter: state=BUILD
  spawnBudget = table[state] * difficultyKnob   // knob is NOT auto-amplitude by default
```

**Booth rule:** change **budgets/timing** first; keep enemy damage bands stable per difficulty mode.

### Pattern B — Stress Brick Deck (Dead Space Lite)

**Intent:** Unpredictable scares/events from authored cards.  
**Data:** stress budget; recent brick IDs (no immediate repeats); player “comfort” (time without event).  
**Actuation:** draw brick with `cost <= budget` and tags matching location/phase.  
**Authoring:** 20–40 bricks for a vignette is plenty (mix real threats, fake-outs, audio-only, light/environment).  
**Fit:** **Game 1**.

**Fake-out ratio:** keep ~30–50% non-lethal bricks so players cannot trust audio tells—this is the “director is toying with you” feeling.

### Pattern C — Hidden Rank with Slow Velocity (RE4 Lite)

**Intent:** Broaden skill band without marketing “easy mode.”  
**Data:** rank integer; update on encounter end, not every frame.  
**Actuation:** rank → resource drop bias, enemy count ±1, telegraph window ±100–200ms.  
**Authoring:** 3–5 rank bands, not 100 continuous parameters.  
**Fit:** Game 1 optional; **avoid** in competitive/skill-branded modes.

**Safeguards:**

- Cap how much rank can drop per death.
- Prefer **giving tools** over **nerfing enemies** when helping.
- Never undo a clearly earned victory mid-animation.

### Pattern D — Visible Heat Meter (God Hand / Hades Pact Lite)

**Intent:** Adaptation as gameplay.  
**Data:** meter from performance *or* player-selected modifiers.  
**Actuation:** enemy aggression, payout multipliers, unlockable “Die” tier.  
**Fit:** **Game 2** (arcade fantasy loves meters); challenge runs for Game 1 post-launch.

### Pattern E — Assist / God Mode Ladder (Celeste / Hades)

**Intent:** Retention + accessibility without silent betrayal.  
**Data:** death count or manual toggles.  
**Actuation:** damage resistance, slower timers, stronger tells—**player can see and disable**.  
**Fit:** all three games; especially Game 1 demos.

### Pattern F — Storylet / Beat Selector (PaSSAGE Lite)

**Intent:** “Personalized plot” from a tiny pool.  
**Data:** 3–5 playstyle weights updated by tagged actions.  
**Actuation:** choose next beat maximizing `dot(weights, beat.tags)` with cooldowns and hard plot constraints.  
**Authoring:** 12–20 beats beats 200 generated lines.  
**Fit:** Game 1 if the vignette has branching ritual stages; otherwise skip.

### Pattern G — Nemesis Postcard (Mordor Lite)

**Intent:** Memory illusion.  
**Data:** struct `{name, trait[3], last_insult, times_killed_you, times_you_fled}`.  
**Actuation:** taunt lines, modified AI (coward / bully), appearance in later scenes.  
**Authoring:** line templates + trait table.  
**Fit:** Game 1 antagonist; Game 2 “rival machine” / cursed coin persona.

### Pattern H — Template Rooms + Rule Population (Spelunky Lite)

**Intent:** Replayable spaces without EDPCG ML.  
**Data:** room templates, edge constraints, spawn rules.  
**Actuation:** stitch path-guaranteed layout; sprinkle threats by density knobs from Pattern A.  
**Fit:** only if a future product needs explorable space; **not required** for Buckshot-format vignette.

### Pattern I — Supply–Demand Hamlet Lever

**Intent:** Keep players in a resource “comfort/discomfort zone.”  
**Data:** predicted time-to-resource-empty (even a dumb heuristic).  
**Actuation:** spawn a drop, delay a shop price spike, or insert a risk/reward side option.  
**Fit:** RE-like resource horror; coin-machine ticket economy; idle prestige timing.

### Pattern J — Depth Ramp + Encounter Table (Hades Lite)

**Intent:** Escalation that feels designed.  
**Data:** `depth`, biome id, modifier flags.  
**Actuation:** `difficulty = base + depth*ramp + modifiers`.  
**Fit:** Game 2 run structure; Game 3 prestige tiers; any roguelite later.

### Pattern K — Soft Personalization via Daily Seeds / Challenges

**Intent:** “For you today” without profiling.  
**Data:** date seed + challenge modifiers.  
**Actuation:** fixed seed content; leaderboards optional.  
**Fit:** all Steam products for news/patch cadence; marketing without ML.

### Pattern L — Dual-Channel Adaptation (Isolation Lite)

**Intent:** Separate **fair agent** from **drama scheduler**.  
**Rule:** director may bias *where pressure goes*; agent may not omnisciently snap to player.  
**Fit:** Game 1 if you have a stalker entity; otherwise use Pattern B only.

---

## 7. Mapping patterns → this repo’s product sequence

From [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) / [`GAME_PLAN.md`](../GAME_PLAN.md):

### Game 1 — Tension / horror vignette (recommended first)

**Ship these:** A + B + E (+ G if one antagonist).  
**Maybe later:** C (hidden rank) if playtests show wide skill variance.  
**Do not ship in v1:** H (full PCG spaces), LLM dialogue, biometric dread, multiplayer EM.

**Session fantasy:** 10–25 minutes, readable rules, clip-friendly peaks. Director Lite creates **re-watchable variance** (“the ritual got mean after I stalled”) without a content mountain.

**Demo hook:** show two playthroughs with different scare timings from the same build—market the *system*, not a story dump.

### Game 2 — Coin-machine

**Ship:** D (visible heat/volatility meter), J (run depth), careful I (payout supply).  
**Avoid:** stealth DDA that claws back wins (feels like a crooked cabinet). Prefer **declared** volatility modes (“Warm / Hot / Inferno”).

### Game 3 — Idle / particle tycoon

**Ship:** J (prestige tiers), E (QoL assists), light I (offline return tuning).  
**Avoid:** AI Director cosplay—idle players want **predictable growth curves** with occasional events, not menace gauges.

---

## 8. Ethics, trust, and “feeling cheated”

1. **Invisible help is safer than invisible punishment** for skill fantasies—but horror can invert this carefully (Isolation raises competence of alien over time with campaign unlocks).  
2. **If players can detect the lever, either show it or slow it.** Rubber banding fails because it is both strong and obvious.  
3. **Gambling-adjacent products (Game 2):** adaptive systems that extend sessions via near-miss inflation are ethically and platform-risk sensitive. Prefer transparent math and player-chosen volatility.  
4. **Accessibility is adaptation.** Celeste/Hades show opt-in beats secret pity difficulty for trust.  
5. **Multiplayer EM is a different beast** (fairness across skill levels)—Ontañón & Zhu outline why; do not start there.

---

## 9. Implementation recipe (Godot 4, small team)

Minimal architecture that covers Patterns A–B–E:

```text
Autoload: Director
  - intensity: float
  - state: enum
  - stress_budget: float
  - brick_cooldowns: Dictionary
  - memory: Dictionary          # Nemesis postcard fields
  - settings: { assist: bool, heat: int, invisible_rank: int }

func register_signal(tag, weight):
  intensity = clamp(intensity + weight, 0, 1)
  maybe_update_rank(tag)

func tick(delta):
  intensity = max(0, intensity - decay * delta)
  update_state_machine()
  maybe_draw_brick()

func maybe_draw_brick():
  if state == RELAX: return
  if stress_budget < min_brick_cost: return
  var candidates = bricks.filter(eligible)
  var pick = weighted(candidates, intensity, memory)
  fire(pick)
  stress_budget -= pick.cost
  brick_cooldowns[pick.id] = pick.cooldown
```

**Tuning loop (do this, not ML):**

1. Record intensity traces from 5 playtests.  
2. Plot against designer-drawn “target drama curve.”  
3. Adjust decay, peak thresholds, brick weights.  
4. Freeze a **seeded** version for QA (determinism > cleverness).

**Telemetry (optional Steam):** anonymous histograms of deaths per phase, assist usage, brick fire rates—enough to retune without building a player-model pipeline.

---

## 10. What “good” looks like in playtests

Use these pass/fail questions:

1. Can a designer explain **why** an event fired from logs in 10 seconds?  
2. Do two playthroughs differ in **timing/order** without breaking fairness?  
3. When we disable the Director, is the game **noticeably flatter**?  
4. When we tell players the Director exists, do they feel **guided** or **cheated**?  
5. Does Assist Mode retain players who would else refund?  

If (3) is “no,” you do not have a Director—you have random noise.  
If (4) is “cheated,” reduce amplitude changes; keep pacing/variety.

---

## 11. Anti-patterns (common indie failure modes)

| Anti-pattern | Why it fails | Do this instead |
|---|---|---|
| “We’ll use an LLM to generate levels/story” | QA explosion; tone breaks; offline Steam pain | Storylets + templates |
| Full open PCG before verbs are fun | Generator amplifies bad mechanics | Spelunky rule: mechanics first, then constrained gen |
| Per-frame difficulty thrash | Feels drunk / unfair | Encounter-end updates |
| Adapting amplitude and pacing at once | Impossible to tune | Pick one primary axis (Booth: pacing) |
| Personalization that only eases | Players resent “baby mode” (adaptive Spelunky study) | Ease via resources/assists; harden via optional heat |
| Tracking 50 signals | No actuation plan | 5 signals max in v1 |
| Marketing “AI that learns you” before you have contingency | Expectation crash | Market replayability / Director / Nemesis moments |

---

## 12. Research vs shipping cheat sheet

| Technique | Research maturity | Ship maturity | Small-team ROI |
|---|---|---|---|
| Intensity FSM Director | Medium (described more in GDC than journals) | **Very high** (L4D lineage) | **Excellent** |
| Hidden rank DDA | High (Hamlet et al.) | **High** (RE4) | High if subtle |
| Visible DDA meter | Medium | **High** (God Hand) | Excellent for arcade |
| Stress brick intensity director | Low academic / high craft | **High** (Dead Space remake) | **Excellent** for horror |
| Behaviour-tree stalker + macro director | Medium | **High** (Isolation) | Medium (scope risk) |
| Nemesis memory graph | Low formal / high craft | **High** (Mordor) | High if scoped to 1 rival |
| Constrained template PCG | High | **Very high** (Spelunky) | High when exploration is the product |
| EDPCG learned models | High | Low–medium (demos, research games) | Poor for v1 |
| Search/planning drama managers | High | Low in commercial AA/indie | Poor for v1 |
| LLM live gen | Emerging | Mixed / risky | Poor for this price band |

---

## 13. Recommended build order for cmp07 (adaptive systems only)

Assuming Game 1 tension vignette is confirmed:

1. **Vertical slice without Director** — prove the core verb and stakes.  
2. **Pattern A** — phase machine with manual spawn calls.  
3. **Pattern B** — 15 stress bricks (include fake-outs).  
4. **Pattern E** — Assist toggles + honest copy.  
5. **Pattern G** — one rival/antagonist memory postcard.  
6. Playtest drama curves; only then consider **Pattern C**.  
7. Ship; use daily seed challenges (K) for post-launch freshness.

Games 2–3 reuse the **Director autoload** only where it maps to volatility/events—not as a cargo-cult “AI” feature.

---

## 14. Sources

### Industry / primary craft

1. Michael Booth — *The AI Systems of Left 4 Dead* (Valve) — https://steamcdn-a.akamaihd.net/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf  
2. Left 4 Dead Wiki — *The Director* — https://left4deadwiki.com/wiki/The_Director  
3. Tommy Thompson / Game Developer — *The Perfect Organism: The AI of Alien: Isolation* — https://www.gamedeveloper.com/design/the-perfect-organism-the-ai-of-alien-isolation  
4. Game Developer — *Revisiting the AI of Alien: Isolation* — https://www.gamedeveloper.com/design/revisiting-the-ai-of-alien-isolation  
5. Alistair Hope — GDC *Building Fear in Alien: Isolation* — https://www.gdcvault.com/play/1021852/Building-Fear-in-Alien  
6. Game Developer — *Diving into the nightmarish new systems of the Dead Space remake* — https://www.gamedeveloper.com/design/diving-into-the-nightmarish-new-systems-of-the-dead-space-remake  
7. Destructoid — *Dead Space Remake’s Intensity Director explained* — https://www.destructoid.com/dead-space-remakes-intensity-director-explained/  
8. Game Developer — *Designing Shadow of Mordor’s Nemesis system* — https://www.gamedeveloper.com/design/designing-i-shadow-of-mordor-i-s-nemesis-system  
9. Game Developer — *Game Changers: Dynamic Difficulty* — https://www.gamedeveloper.com/design/game-changers-dynamic-difficulty  
10. Game Developer — *More Than Meets the Eye: The Secrets of Dynamic Difficulty Adjustment* — https://www.gamedeveloper.com/design/more-than-meets-the-eye-the-secrets-of-dynamic-difficulty-adjustment  
11. tinysubversions — *Spelunky Generator Lessons* — https://tinysubversions.com/spelunkyGen2/index.html  
12. tinysubversions — *Spelunky’s Procedural Space* — https://tinysubversions.com/2009/09/spelunkys-procedural-space/index.html  
13. Kotaku — *Hades’ Level Design Is Less Random Than It Seems* — https://kotaku.com/hades-level-design-is-less-random-than-it-seems-1845254545  
14. Kotaku — *Everything You Need To Know About Hades’ Endgame* (Heat) — https://kotaku.com/everything-you-need-to-know-about-hades-endgame-1845239105  
15. Inverse — Hades God Mode interview — https://www.inverse.com/gaming/hades-god-mode-interview  
16. Vice — Celeste Assist Mode — https://www.vice.com/en/article/celeste-assist-mode-change-and-accessibility/  
17. Wikipedia — *God Hand* (visible difficulty gauge) — https://en.wikipedia.org/wiki/God_Hand  
18. CBR — *Resident Evil 4’s Most Important Feature Is Its Dynamic Difficulty* — https://www.cbr.com/resident-evil-4-dynamic-difficulty-capcom/

### Academic / foundational

19. Hunicke & Chapman — *AI for Dynamic Difficulty Adjustment in Games* (Hamlet) — https://users.cs.northwestern.edu/~hunicke/pubs/Hamlet.pdf  
20. Hunicke — *The case for dynamic difficulty adjustment in games* — https://doi.org/10.1145/1178477.1178573  
21. Yannakakis & Togelius — *Experience-Driven Procedural Content Generation* — https://doi.org/10.1109/t-affc.2011.6 — PDF https://yannakakis.net/wp-content/uploads/2019/02/EDPCG.pdf  
22. Shaker, Yannakakis, Togelius — *Towards Automatic Personalized Content Generation for Platform Games* — https://doi.org/10.1609/aiide.v6i1.12399  
23. Thue et al. — *Interactive Storytelling: A Player Modelling Approach* (PaSSAGE) — https://www.cs.uky.edu/~sgware/reading/papers/thue2007interactive.pdf  
24. Sharma et al. — *Drama Management Evaluation for Interactive Fiction Games* — https://sites.cc.gatech.edu/fac/ashwin/papers/er-07-15.pdf  
25. Sharma et al. — *Drama Management and Player Modeling for Interactive Fiction Games* — https://onlinelibrary.wiley.com/doi/10.1111/j.1467-8640.2010.00355.x  
26. Ontañón & Zhu — *Experience Management in Multi-player Games* — https://doi.org/10.48550/arxiv.1907.02349  
27. AIIDE — *A Structured Analysis of Experience Management Techniques* — https://doi.org/10.1609/aiide.v15i1.5241  
28. AIIDE — *Adversarial Strong Story Experience Management* — https://doi.org/10.1609/aiide.v21i1.36828  
29. Player-adaptive Spelunky level generation — https://doi.org/10.1109/cig.2015.7317948  
30. Togelius et al. — *Search-Based Procedural Content Generation: A Taxonomy and Survey* — https://doi.org/10.1109/tciaig.2011.2148116  
31. Jenova Chen — *Flow in Games* — https://jenovachen.com/flowingames/Flow_in_games_final.pdf  
32. Zook et al. / NeurIPS-adjacent line — *Predicting Dynamic Difficulty* — https://proceedings.neurips.cc/paper_files/paper/2011/file/7c9d0b1f96aebd7b5eca8c3edaa19ebb-Paper.pdf  
33. Engagement-Oriented DDA (EDDA) — https://www.mdpi.com/2076-3417/15/10/5610  

### Internal repo context

34. [`docs/GAME_PLAN.md`](../GAME_PLAN.md) — multi-game Steam plan, pure categories  
35. [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md) — category scores and comps  

---

## 15. One-page takeaway

**Shipping adaptive games is craft scheduling, not magic learning.**

- Measure a few signals.  
- Spend a stress budget on authored bricks.  
- Alternate pressure and relief.  
- Remember a handful of facts.  
- Let players own difficulty when trust matters.  

Do that well and players will swear the game “learned them.” Build an LLM world model first and you will still need all of the above—only with a larger blast radius.
