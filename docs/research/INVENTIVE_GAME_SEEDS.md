# 20 Inventive Pure-Genre Game Seeds

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Date:** August 2026  
**Lens:** Solo / small team · Godot 4 · Windows-first Steam `.exe` · roughly **$0.99–$10**  
**Hard rules (from [`docs/GAME_PLAN.md`](../GAME_PLAN.md)):** one pure category per product · no mashups · sequential small ships  

**Creative brief for this doc:** seeds that lean into **creation from nothing**, **physics play**, **one simple unique mechanic**, and/or **generative-adaptive “shapes around you.”** Mix of **AI used inventively** and **generative feel without LLMs**.

**How scores work (1–10):**

| Field | Means |
|---|---|
| **Risk** | Tech + content + market risk for a first Steam ship (higher = scarier) |
| **Inventiveness** | How fresh / demoable the core idea feels vs. crowded Steam shelves |
| **Market fit** | Fit for *this* team’s first desktop Steam product at $0.99–$10 (not “can a studio make bank someday”) |

**Vertical slice weeks** assume one strong generalist (or two) on Godot 4, art placeholder-OK, one complete “wow” loop playable offline unless noted.

Companion docs: [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) (prior market lane ranking) · prior agent: [Market research game plan](https://cursor.com/agents/bc-2f2367d2-9b0d-4093-8ebf-352422ec4f9e).

---

## Executive take (read this first)

The prior plan correctly favored **tension vignette → coin machine → particle idle** for *speed and proven $3–$10 breakouts*. This document is a **creative parallel track**: twenty *distinct* inventive products that still obey pure-genre discipline.

For a **first** Steam desktop game under the repo constraints, inventive seeds win when they are:

1. **One verb** you can show in a 15-second clip  
2. **Offline / local** (no LLM API bill or policy risk on day one)  
3. **Goals or stakes** (toys sell, but “challenge pack + demo” sells easier at low price)  
4. **Physics or generative systems that stay small** (2D rigid body, grids, fields — not Teardown-scale voxels)

**Recommended first inventive pick:** **#08 Fulcrum Stairs** (physics balance puzzle).  
**Best “shapes around you” without LLM:** **#05 Echo Lattice**.  
**Best AI-inventive (as Game 1 only if you accept API risk):** **#13 The Confessor Room**.  
**Best creation-from-nothing toy:** **#01 Void Plinth**.

Full top-10 ranking for first Steam ship is at the end.

---

## Theme tags used below

- **CREATE** — start empty; something appears because of you  
- **PHYS** — physical simulation is the toy  
- **MECH** — one sharp unique rule is the whole game  
- **SHAPE** — world / level / rules adapt around the player  
- **AI** — large model or learned model is load-bearing (not just marketing paste)  
- **NO-LLM** — generative / adaptive without calling an LLM  

---

# The 20 seeds

---

## 01 — Void Plinth  
**Pure genre:** Creative building toy (architecture automaton)  
**Tags:** CREATE · SHAPE · NO-LLM  

### Pitch
An empty black plinth above an infinite sea. You place colorless blocks; a local **tile-rewrite / WFC-like** grammar turns neighbors into arches, stairs, gardens, and cantilevers. There is no economy, no combat, no narrative — only the pleasure of watching emptiness become place.

### Loop
Pick a material intent (stone / timber / glass) → place or erase a cell → watch the automaton resolve the silhouette → optionally photograph / export / share a seed string → start a new plinth with a different grammar pack.

### Shapes around you
The grammar is **configuration-sensitive**: the same block becomes a balcony, buttress, or bridge depending on your surrounding placements. Optional “weather packs” bias the rewrite rules toward your last session’s density (sparse → cliffs; dense → compact towns).

### Vertical slice
**3–5 weeks** — one grammar, place/erase, camera, 3 materials, screenshot.

### Scores
| Risk | Inventiveness | Market fit (as Game 1) |
|---:|---:|---:|
| 4 | 7 | 7 |

### Comps
- [Townscaper](https://store.steampowered.com/app/1291340/Townscaper/) (~$5.99, Overwhelmingly Positive; toy with transformative placement)  
- Oskar Stålberg / Bad North lineage for “placement becomes architecture”  
- Price-band signal: cozy creative toys clear at $4.99–$9.99 when the clip is gorgeous  

### Note
Strong taste fit for “creation from nothing.” Marketing must own **toy** honestly (Townscaper’s own store copy does). Pair with a tiny “daily silhouette challenge” if you need Steam feature checklist meat.

---

## 02 — Wellsinger  
**Pure genre:** Physics music sandbox  
**Tags:** PHYS · CREATE · NO-LLM  

### Pitch
You never place notes. You place **gravity wells** and **elastic membranes**. Falling beads and vibrating plates *become* the score. Composition is choreography of mass.

### Loop
Drop emitters → place / tune wells → scrub time → capture a loop → unlock new materials (glass rods, sand trays, magnetic rails) → challenge cards (“resolve a 4-bar lullaby with ≤3 wells”).

### Shapes around you
Optional adaptive mode retunes well falloff so your last take’s loudness/density stays in a target musical range — generative feel from DSP + physics, not text AI.

### Vertical slice
**5–7 weeks** — 2D physics, MIDI/audio mapping, 5 challenge cards, record GIF.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 6 | 8 | 5 |

### Comps
- Physics toys / sandbox audience overlapping [People Playground](https://store.steampowered.com/app/1118200/People_Playground/) (systems toys, Workshop culture)  
- Music-game discovery is thinner than pure puzzle; rely on audiovisual trailers  
- Adjacent “systems → unexpected beauty” pitch like Universe Sandbox’s spectacle, at micro scale: [Universe Sandbox](https://store.steampowered.com/app/230290/Universe_Sandbox/)  

### Note
Inventive and clip-friendly, but **music sandbox** is a narrower Steam tag cluster than puzzle/horror. Better as Game 2–3 unless you already have a strong audio identity.

---

## 03 — Perimeter  
**Pure genre:** Spatial puzzle (single mechanic)  
**Tags:** MECH · SHAPE · NO-LLM  

### Pitch
You are not inside the shape. **You are the edge.** Walk the perimeter of a living polygon; every step lengthens, shortens, or folds an edge. Goals are silhouettes, doorways, and “contain the red” targets.

### Loop
Enter level → walk edges with left/right → spend limited “pin” actions to freeze vertices → satisfy silhouette / containment → next glyph.

### Shapes around you
The polygon’s interior is a signed-distance field that **rewrites walkable space** as you move — the maze is the creature you are sculpting.

### Vertical slice
**4–6 weeks** — edge walker, 12 handmade levels, undo, ghost silhouette.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 3 | 9 | 8 |

### Comps
- Unique-mechanic puzzle sales culture of [Baba Is You](https://store.steampowered.com/app/736260/Baba_Is_You/) (Overwhelmingly Positive; “one idea, hundreds of levels”)  
- Compact puzzle packaging like Zachtronics clarity, e.g. [Opus Magnum](https://store.steampowered.com/app/558990/Opus_Magnum/) (open-ended solutions — different mechanic, same “clever systems” buyer)  
- Short-session discovery lessons from [Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) (not genre-alike — **format** lesson: readable rule, clip outcomes)  

### Note
Extremely strong **first-game** candidate: tiny art surface, infinite level design runway, trivial Steam demo.

---

## 04 — Kiln Contour  
**Pure genre:** Heat-sculpting puzzle  
**Tags:** PHYS · CREATE · MECH · NO-LLM  

### Pitch
Stone is frozen time. Your only tool is a **heat brush** and a **quench**. Temperature diffuses; materials crack, glaze, flow, and anneal. Carve a path or a vessel by cooking the level itself.

### Loop
Study material legend → paint heat → watch diffusion → quench to lock → meet tolerance (exit channel / bowl capacity / bridge integrity) → optional “beauty score” from glaze patterns.

### Shapes around you
Heat history becomes permanent material memory — your past strokes are the terrain. Later levels add wind fields that advect heat around your preferred stroke direction (tracked locally).

### Vertical slice
**5–8 weeks** — grid diffusion, 3 materials, 10 levels, thermal false-color readability.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 8 | 8 |

### Comps
- Pixel/material simulation fantasy of [Noita](https://store.steampowered.com/app/881100/Noita/) (scoped down to puzzle, not action-roguelite)  
- Falling-sand chemistry toy market: [Sandboxels](https://store.steampowered.com/app/3664820/Sandboxels/), [Stardust Sandbox](https://store.steampowered.com/app/4348740/Stardust_Sandbox/)  
- Goal-oriented physics puzzle sales of [World of Goo 2](https://store.steampowered.com/app/3385670/World_of_Goo_2/)  

### Note
Keep **2D grid**; do not chase Noita’s full pixel engine for v1.

---

## 05 — Echo Lattice  
**Pure genre:** Adaptive labyrinth puzzle  
**Tags:** SHAPE · MECH · NO-LLM  

### Pitch
A corridor that **remembers your last thirty moves** and rebuilds itself from that tape. You are not fighting RNG — you are fighting your own habits. Escape means learning to write a path that leaves behind a kinder maze.

### Loop
Enter lattice → move (N/E/S/W) → on each checkpoint, world regenerates from a transform of your move buffer → collect keys / reach exit → meta-unlock new transforms (mirror, rotate, Markov thicken).

### Shapes around you
Core fantasy: **the dungeon is a function of you**. Generation is deterministic from your input (hash → grammar), so streamers can show “same seed, different person → different building.”

### Vertical slice
**4–6 weeks** — move buffer, one rewrite grammar, 8 chambers, ghost path replay.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 9 | 8 |

### Comps
- Adaptive / PCG discourse (WFC + player-conditioned generation) — see hybrid WFC/GA literature and adaptive dungeon writeups ([ICCS 2025 WFC+GA paper](https://www.iccs-meeting.org/archive/iccs2025/papers/159090105.pdf); [AI dungeon generation overview](https://artificial-intelligence-wiki.com/industry-ai/ai-in-gaming/ai-dungeon-generation/))  
- Player-as-author feeling without LLM cost (contrast API titles like [AI Roguelite](https://store.steampowered.com/app/1889620/AI_Roguelite/))  
- Short-run structure comparable to vignette hits in pacing, not theme  

### Note
Best pure expression of **“shapes around you”** without AI disclosure baggage.

---

## 06 — Clingforge  
**Pure genre:** Adhesion physics builder  
**Tags:** PHYS · CREATE  

### Pitch
[Besiege](https://store.steampowered.com/app/346010/Besiege/)-adjacent fantasy, narrowed to **one physical truth: stickiness**. Build machines from gels, tapes, and magnetic putty. Strength is contact area and cure time, not hit points.

### Loop
Sandbox assemble → wait for cure → run scenario (bridge gap / climb wall / catch egg) → iterate blueprint → campaign island of sticky constraints.

### Shapes around you
Surface materials in each scenario are authored; optional mode grows “biofilm difficulty” that thickens where you repeatedly fail (local adaptive, not LLM).

### Vertical slice
**7–10 weeks** — 2D soft joints + cure timer, 6 parts, 6 scenarios, blueprint save.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 6 | 7 | 6 |

### Comps
- [Besiege](https://store.steampowered.com/app/346010/Besiege/) (~95% positive, large review base; physics building evergreen)  
- [World of Goo 2](https://store.steampowered.com/app/3385670/World_of_Goo_2/) (structural goo fantasy)  
- [KINETIKA](https://store.steampowered.com/app/2820090/KINETIKA/) (physics-body ambition — **scope warning**, not a clone target)  

### Note
Market exists; **scope creep** is the enemy. Stay 2D. Not ideal as absolute first ship unless you already love physics debugging.

---

## 07 — Void Verbs  
**Pure genre:** Rule-rewriting puzzle  
**Tags:** CREATE · MECH · NO-LLM  

### Pitch
Levels begin as **nearly empty boards**. The only nouns that exist are residues you scrape from the void. Combining residues writes verbs into the world (`EMPTY IS PUSH`, `VOID IS YOU`, `SILENCE IS WIN`). Creation *is* the ruleset.

### Loop
Scrape → compose rule sentence → test interactions → reach WIN condition → optional challenge: win with the shortest sentence.

### Shapes around you
Later chapters introduce “listener tiles” that rewrite rules based on which verbs you used most this session — still table-driven, not LLM.

### Vertical slice
**6–9 weeks** — parser for tile sentences, 20 levels, undo, level select.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 5 | 8 | 6 |

### Comps
- Direct lineage: [Baba Is You](https://store.steampowered.com/app/736260/Baba_Is_You/) (~$14.99 typical; Overwhelmingly Positive)  
- Design excellence bar is **extremely high**; buyers compare you to Hempuli immediately  

### Note
Inventive and on-theme (“from nothing”), but **crowded genius shelf**. Price may want $9.99–$14.99 — slightly above the repo’s comfort band for Game 1.

---

## 08 — Fulcrum Stairs  
**Pure genre:** Physics balance puzzle  
**Tags:** PHYS · MECH  

### Pitch
Every level is a staircase that **must not fall** while you climb it. You may shift masses, pour sand ballast, or snap struts — but your avatar’s weight is part of the equation. The joke and the terror is the same: *you are the load*.

### Loop
Survey unstable stair → place limited counterweights → climb step-by-step as simulation runs → reach door / retrieve bell → ghost replay of collapse for sharing.

### Shapes around you
Daily seed stairs are generated from a grammar of beams + joints; optional “habit mode” biases generation toward failure modes you trigger often (toe-edge slips, middle hinge breaks).

### Vertical slice
**3–5 weeks** — 2D rigid bodies, player mass, 15 levels, slow-mo collapse replay.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 3 | 8 | 9 |

### Comps
- Physics-consequence clarity of World of Goo / Besiege, but **vignette-sized** levels  
- Clip culture of collapse / near-miss (People Playground energy without gore)  
- Pricing/format lessons from short-session hits ([Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) ~$2.99 band; Meccha Chameleon–style “simple rule, huge shareability” — see [Polygon coverage of 2026 viral simple-mechanic sales](https://www.polygon.com/meccha-chameleon-sales-15-million/))  

### Note
**Best overall Game 1 inventive pick** for this repo: fast slice, obvious trailer, offline, pure category, room for $3.99–$7.99.

---

## 09 — Wakeherd  
**Pure genre:** Generative creature sandbox  
**Tags:** CREATE · SHAPE · NO-LLM  

### Pitch
A flock of agents that **build terrain in your wake**. Swim or walk; the herd deposits sediment, coral, and trails that become the next walkable world. No combat — husbandry of emergence.

### Loop
Guide herd with cursor / light → deposit materials → watch erosion / growth ticks → stamp a “preserve” → open a new biome rulecard.

### Shapes around you
Literally: landforms are a low-pass filter of your movement history + boid deposition rules.

### Vertical slice
**4–6 weeks** — boids, deposition, 3 biomes, timelapse export.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 7 | 6 |

### Comps
- Creature/physics sandbox appetite: [Primordialis](https://store.steampowered.com/app/3011360/Primordialis/) (physics creature engineering — different loop, same “alive systems” buyer)  
- Creative toy comps: Townscaper; sandbox sim comps: Sandboxels  
- AI-creature novelty competitors if you accidentally market this as AI: [GUG](https://store.steampowered.com/app/2824790/GUG/) (text→creature; LLM path — **do not collide**)  

### Note
Beautiful, but “no fail state” toys need exquisite presentation. Add optional herding challenges for Steam features.

---

## 10 — Caustic Brief  
**Pure genre:** Falling-sand puzzle campaign  
**Tags:** PHYS · MECH · NO-LLM  

### Pitch
Not an open toy box first — a **briefing folder** of sand chemistry puzzles. Each page: limited pixels, one reaction chain, one acceptance test (“fill the vial,” “cut the wire,” “grow a fuse”).

### Loop
Read brief → paint limited element budgets → simulate → meet sensors → unlock next dossier.

### Shapes around you
Practice range mode grows a “lab mess” that persists between puzzles (your leftover reactions become the next brief’s starting stain) — light SHAPE without changing pure puzzle identity.

### Vertical slice
**5–7 weeks** — 12 elements, reaction table, 15 briefs, scrub/reset.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 6 | 7 |

### Comps
- [Sandboxels](https://store.steampowered.com/app/3664820/Sandboxels/), [Stardust Sandbox](https://store.steampowered.com/app/4348740/Stardust_Sandbox/) (toy competitors — differentiate with **briefs/goals**)  
- [Noita](https://store.steampowered.com/app/881100/Noita/) as aspiration ceiling, not scope  
- Idle/particle adjacency in this repo’s taste: [Particul](https://store.steampowered.com/app/4273120/Particul/) (~$1.99) — **keep this seed a puzzle**, never an idle mashup  

### Note
Good catalog product; inventiveness is medium unless the briefing fiction is sharp.

---

## 11 — Threadfall  
**Pure genre:** Thread / tension physics puzzle  
**Tags:** PHYS · MECH  

### Pitch
Rain of beads. You may only pin and tension **threads**. Redirect flow into mouths, mills, and scales. No blocks, no guns — textile physics as routing.

### Loop
Pin threads → tension / cut → release rain → score throughput → optional “no cut” badge.

### Shapes around you
Wind fields slowly align to your dominant thread angles (local stats), teaching you to fight your own habits.

### Vertical slice
**4–6 weeks** — verlet ropes, emitters, 12 levels.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 3 | 7 | 8 |

### Comps
- [World of Goo](https://store.steampowered.com/app/92000/World_of_Goo/) / [World of Goo 2](https://store.steampowered.com/app/3385670/World_of_Goo_2/)  
- Structural puzzle buyers overlapping Besiege, without full vehicle scope  

### Note
Excellent demo GIF. Slightly less “new verb” than Perimeter/Fulcrum, but very shippable.

---

## 12 — Pruneclock  
**Pure genre:** Growth simulation / gardening puzzle  
**Tags:** CREATE · SHAPE · NO-LLM  

### Pitch
Time only advances when you **prune**. The plant is a L-system / space colonization tree that wants to smother the greenhouse. Your cuts are both clock and scalpel. Keep the fruiting window alive.

### Loop
Observe growth intent → prune (spending time) → harvest when fruiting nodes mature → survive seasonal pressure cards → next greenhouse.

### Shapes around you
Budding biases toward the hemisphere you prune least — the plant literally grows around your neglect.

### Vertical slice
**5–7 weeks** — growth model, prune tool, 3 plants, 1 season loop.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 8 | 6 |

### Comps
- Cozy/creative overlap with Townscaper buyers; farming fantasy without Stardew scope  
- Systems-gardening is less proven as a *short paid vignette* than tension/physics puzzles  

### Note
Strong SHAPE fantasy; market fit middling for Game 1 unless art is exceptional.

---

## 13 — The Confessor Room  
**Pure genre:** AI horror vignette  
**Tags:** AI · SHAPE · MECH  

### Pitch
One room. One chair. An entity that only understands **confession**. Everything you type becomes furniture, stains, and rules in the room (via LLM → constrained prop/grammar mapping). Lie, and the room tightens. Tell a costly truth, and a door appears — maybe.

### Loop
Sit → speak → watch room rewrite → manage stress / blasphemy meters → reach dawn or be entombed → modifiers (mute, one-word only, mirror mode).

### Shapes around you
Direct: **utterance → scene graph**. Inventive AI use is the *binding* of language to spatial grammar (not freeform AI Dungeon wandering).

### Vertical slice
**4–7 weeks** + API plumbing — prop catalog, constrained schema from model, 1 antagonist voice, 3 endings.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 8 | 9 | 7 |

### Comps
- Format/market: [Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) (8M sales reported 2025–26 press; short horror stakes)  
- AI content peers: [Haze](https://store.steampowered.com/app/4034940/Haze/), [AI Roguelite](https://store.steampowered.com/app/1889620/AI_Roguelite/), [Manifest Anything](https://store.steampowered.com/app/4335600/Manifest_Anything/)  
- Aligns with prior repo recommendation for tension vignette as Game 1 ([`CATEGORY_RANKING.md`](CATEGORY_RANKING.md)) **if** AI is the original hook — not a shotgun clone  

### Note
Highest AI inventiveness in the set. Risk stack: **cost, moderation, offline reviewers, Steam AI disclosure**. Prefer local small model or heavy constraint schema. Strong contender if you explicitly want AI as the headline.

---

## 14 — Soft Crown  
**Pure genre:** Soft-body physics sandbox / challenge pack  
**Tags:** PHYS · CREATE  

### Pitch
You rule a kingdom of **balloons**. Inflate, deflate, pinch, and knot soft bodies to bridge chasms and crown pedestals. Majesty is pressure.

### Loop
Inflate → knot / pinch → traverse → hold shape under wind → collect crown → workshop free play.

### Shapes around you
Wind and buoyancy tables slowly retarget to your average inflation (keep skilled players in the jank-sweet-spot).

### Vertical slice
**7–11 weeks** — stable soft bodies are the schedule risk.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 7 | 7 | 5 |

### Comps
- Soft/physics novelty buyers; Teardown-scale destruction ([Teardown](https://store.steampowered.com/app/1167630/Teardown/)) is the wrong scope north star  
- EXPHYSIA / KINETIKA as “physics as identity” warnings for over-scope  

### Note
Skip as Game 1; soft-body stability eats months.

---

## 15 — Orbit Ink  
**Pure genre:** Orbital mechanics drawing puzzle  
**Tags:** PHYS · MECH · CREATE  

### Pitch
Your pen is a thruster. Draw closed curves that must remain stable orbits around ink-masses you previously drew. Calligraphy meets patched conics.

### Loop
Place mass-blots → draw trajectory strokes → simulate → achieve closed loops / slingshot goals → gallery of failed roses.

### Shapes around you
“Constellation mode” freezes your last successful orbit family as the next level’s gravity sculpture.

### Vertical slice
**5–7 weeks** — 2D gravity, stroke sampling, 15 puzzles.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 8 | 7 |

### Comps
- [Universe Sandbox](https://store.steampowered.com/app/230290/Universe_Sandbox/) (spectacle gravity; this seed is puzzle-tight)  
- Educational physics toys; keep presentation artful to avoid “sim homework” trap  

### Note
Clear trailer math. Slightly more didactic than Fulcrum/Threadfall.

---

## 16 — Constraint Crypt  
**Pure genre:** Constraint-based dungeon crawler (tiny)  
**Tags:** SHAPE · NO-LLM · MECH  

### Pitch
Before each floor you play **constraint chips** (`no left turns`, `torches are doors`, `loops must be even`). A WFC/solver builds a crypt that obeys your chips *and* still contains a legal path. You chose your prison.

### Loop
Pick 1–3 chips → generate → explore with a single verb (place torch / walk) → retrieve relic → escalate chip pool.

### Shapes around you
The generative system is the product. Difficulty adapts by offering chip sets whose solution density matches your clear-time EMA.

### Vertical slice
**6–9 weeks** — WFC with path constraint, chip UI, 1 enemy type max (or zero — pure puzzle crypt).

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 5 | 8 | 6 |

### Comps
- PCG literature above; player-authored constraints echo Baba’s “change the rules” fantasy without sentence parsing  
- Avoid marketing as AI if no ML — Steam buyers are sensitive after AI-tagged dumps  

### Note
Keep combat out for purity; one relic-hunt verb is enough.

---

## 17 — Gargoyle Schema  
**Pure genre:** AI physics sculpture puzzle  
**Tags:** AI · PHYS · CREATE  

### Pitch
Type a material myth (“cold honey that hates iron”). A model emits a **parameter card** (density, friction, adhesion, melt). You must sculpt a gargoyle that stands for thirty seconds under wind. Language becomes constitutive physics.

### Loop
Prompt → receive schema (editable sliders; model is advisor not tyrant) → sculpt → simulate storm → museum shelf of survivors.

### Shapes around you
Schemas can be fine-tuned locally on which of *your* sculptures failed (tiny online/offline adaptation) — inventive beyond one-shot prompt art.

### Vertical slice
**7–10 weeks** + model path — sculpt tools, schema JSON, storm sim, 10 starter myths.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 8 | 9 | 4 |

### Comps
- [GUG](https://store.steampowered.com/app/2824790/GUG/) (text→creature behavior)  
- [Manifest Anything](https://store.steampowered.com/app/4335600/Manifest_Anything/) (AI creation platform; crowded “prompt to make stuff” perception risk)  
- Physics sculpture adjacent to Besiege stability challenges  

### Note
Wonderful research game; **poor first Steam product** due to AI + physics compound risk and confused store tags.

---

## 18 — Ripple Codex  
**Pure genre:** Field-equation physics puzzle  
**Tags:** PHYS · SHAPE · MECH · NO-LLM  

### Pitch
Each action emits a wave that **hardens into law**. Jump once, and a permanent sinusoidal force field is written into the stage. Levels are solved by composing a legal physics you can still walk through.

### Loop
Act → field bakes → adapt movement → reach exit without illegal resonance → codex entry of your personal physics.

### Shapes around you
Maximum SHAPE: the stage’s dynamics *are* your history.

### Vertical slice
**6–8 weeks** — one field type, bake visual, 12 levels, reset.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 5 | 9 | 6 |

### Comps
- High-concept puzzle shelf with Baba / Zachtronics buyers  
- Teaching cost is real — trailer must make the bake rule obvious in 5 seconds  

### Note
Inventiveness ceiling is huge; communication risk is the killer. Better after one shipped puzzle game.

---

## 19 — Chromafield  
**Pure genre:** Reaction-diffusion puzzle  
**Tags:** CREATE · MECH · NO-LLM · SHAPE  

### Pitch
Paint two reagents. They morph through Gray–Scott (or similar) patterns. Sensors win when a target morphology appears (spots, labyrinth, soliton bridge). You play gardener of math.

### Loop
Pick rates → paint seeds → simulate → steer with local catalyst stamps → match target micrograph → next specimen.

### Shapes around you
Target morphologies can be generated from a hash of your previous winning rate vector — a personal evolutionary museum.

### Vertical slice
**4–6 weeks** — shader/CPU RD, stamp tools, 15 targets.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 8 | 6 |

### Comps
- Generative-art toy audience; Sandboxels chemistry neighbors  
- Distinguish from idle/particle tycoon ([Particul](https://store.steampowered.com/app/4273120/Particul/)) — this is **morphology puzzle**, not number-go-up  

### Note
Gorgeous GIFs; niche scientific aesthetic may limit wishlists unless framing is visceral (“grow a living lockpick”).

---

## 20 — Stilts Protocol  
**Pure genre:** Stacking physics challenge toy  
**Tags:** PHYS · MECH · CREATE  

### Pitch
Build the tallest **personal stilts** from junk parts, then walk a protocol course. Building and walking are the same save file. Fall = comedy; finish = certification stamp.

### Loop
Stack / lash parts → test walk → redesign → certify on a seeded daily course → leaderboard of “boring but reliable” vs “chaotic beautiful.”

### Shapes around you
Daily courses bias obstacles opposite your last winning gait (tall vs wide stance), harvested from anonymous gait metrics — still non-LLM.

### Vertical slice
**5–7 weeks** — stacking, simple walker controller, 5 courses, daily seed.

### Scores
| Risk | Inventiveness | Market fit |
|---:|---:|---:|
| 4 | 7 | 7 |

### Comps
- Besiege / People Playground Workshop culture  
- Physics comedy clip market (strong TikTok/Shorts loop)  
- Low-price impulse band alongside Particul / vignette pricing  

### Note
Very shippable; slightly more “streamer physics” than elegant design-award puzzle.

---

# Comparison matrix (all 20)

| # | Seed | Pure genre | AI? | Slice wks | Risk | Inv. | Mkt fit |
|---|---|---|---|---:|---:|---:|---:|
| 01 | Void Plinth | Building toy | No | 3–5 | 4 | 7 | 7 |
| 02 | Wellsinger | Physics music | No | 5–7 | 6 | 8 | 5 |
| 03 | Perimeter | Spatial puzzle | No | 4–6 | 3 | 9 | 8 |
| 04 | Kiln Contour | Heat puzzle | No | 5–8 | 4 | 8 | 8 |
| 05 | Echo Lattice | Adaptive labyrinth | No | 4–6 | 4 | 9 | 8 |
| 06 | Clingforge | Adhesion builder | No | 7–10 | 6 | 7 | 6 |
| 07 | Void Verbs | Rule puzzle | No | 6–9 | 5 | 8 | 6 |
| 08 | Fulcrum Stairs | Balance puzzle | No | 3–5 | 3 | 8 | 9 |
| 09 | Wakeherd | Creature sandbox | No | 4–6 | 4 | 7 | 6 |
| 10 | Caustic Brief | Sand puzzle | No | 5–7 | 4 | 6 | 7 |
| 11 | Threadfall | Thread puzzle | No | 4–6 | 3 | 7 | 8 |
| 12 | Pruneclock | Growth puzzle | No | 5–7 | 4 | 8 | 6 |
| 13 | Confessor Room | AI horror vignette | **Yes** | 4–7 | 8 | 9 | 7 |
| 14 | Soft Crown | Soft-body sandbox | No | 7–11 | 7 | 7 | 5 |
| 15 | Orbit Ink | Orbital puzzle | No | 5–7 | 4 | 8 | 7 |
| 16 | Constraint Crypt | Constraint dungeon | No | 6–9 | 5 | 8 | 6 |
| 17 | Gargoyle Schema | AI sculpture puzzle | **Yes** | 7–10 | 8 | 9 | 4 |
| 18 | Ripple Codex | Field-law puzzle | No | 6–8 | 5 | 9 | 6 |
| 19 | Chromafield | RD morphology puzzle | No | 4–6 | 4 | 8 | 6 |
| 20 | Stilts Protocol | Stacking physics | No | 5–7 | 4 | 7 | 7 |

**AI inventive set:** 13, 17 (primary); optional later AI seasoning must not mash genres.  
**Generative-without-LLM set:** 01, 05, 09, 12, 16, 18, 19 (primary); others may use light adaptive bias.

---

# Top 10 ranking for FIRST Steam desktop game

Ranking criterion: **probability of a clean solo/small-team ship** that earns reviews in the $0.99–$10 band, with inventive identity, offline demo, and pure-genre store page — *not* maximum novelty for its own sake.

| Rank | Seed | Why here |
|---:|---|---|
| **1** | **08 Fulcrum Stairs** | Fastest inventive physics vignette; collapse clips; tiny content mountain; perfect $3.99–$7.99; offline |
| **2** | **03 Perimeter** | Highest “new verb” clarity; puzzle evergreen; demo writes itself |
| **3** | **05 Echo Lattice** | Best non-LLM “shapes around you”; deterministic shareable stories |
| **4** | **11 Threadfall** | Proven physics-puzzle buyer; lower novelty than #2–3 but very safe craft |
| **5** | **04 Kiln Contour** | Strong visuals + material sim fantasy without Noita scope |
| **6** | **01 Void Plinth** | Creation-from-nothing exemplar; Townscaper lane proven; needs art excellence |
| **7** | **20 Stilts Protocol** | Clip-native physics comedy; slightly broader / goofier brand |
| **8** | **15 Orbit Ink** | Distinct; readable; mild education stigma to manage in trailer |
| **9** | **10 Caustic Brief** | Solid catalog craft; inventiveness medium; differentiates from Particul by staying puzzle |
| **10** | **13 The Confessor Room** | Best AI-first option & aligns with prior tension-vignette strategy — **only if** you accept API/moderation/disclosure risk |

### Just outside the top 10 (and why)

| Seed | Hold-out reason |
|---|---|
| 07 Void Verbs | Baba comparisons + price band pressure |
| 16 Constraint Crypt | Solver reliability / UX risk |
| 18 Ripple Codex | Hard to market in one sentence |
| 19 Chromafield | Niche aesthetic |
| 09 Wakeherd / 12 Pruneclock | Toy/cozy without stakes unless challenges are strong |
| 06 Clingforge / 14 Soft Crown | Physics scope |
| 02 Wellsinger | Niche tags |
| 17 Gargoyle Schema | AI + physics compound failure mode |

---

# Relationship to the existing multi-game plan

From [`GAME_PLAN.md`](../GAME_PLAN.md) / [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md):

| Prior plan lane | Inventive seed that stays pure & compatible |
|---|---|
| Tension / horror vignette (was #1) | **#13 Confessor Room** (AI original premise) *or* a non-AI horror reskin of **#08 Fulcrum** / **#05 Echo** with dread framing — still one category |
| Coin-machine (was #2) | Not forced here; coin physics can remain a **separate later product** — do not mash into these seeds |
| Idle / particle (was #3) | Keep **Particul-like** separate; **#10 Caustic** and **#19 Chromafield** must not become idle hybrids |

**Decision gate (creative track):**

1. **Inventive Game 1 = Fulcrum Stairs** (recommended default on this track), or  
2. **Perimeter** (if you want pure puzzle prestige), or  
3. **Echo Lattice** (if “shapes around you” is the north-star pitch), or  
4. **Confessor Room** (if AI headline is mandatory), or  
5. Stay with prior plan’s non-inventive tension vignette lane  

Until one gate option is locked, do not scaffold multiple Godot projects.

---

# Sources & comps (web, Aug 2026 research pass)

### Creation / generative toys
- Townscaper — https://store.steampowered.com/app/1291340/Townscaper/  
- Townscaper review volume / score — https://steambase.io/games/townscaper/reviews  
- Manifest Anything (AI creation platform) — https://store.steampowered.com/app/4335600/Manifest_Anything/  

### Physics play
- Besiege — https://store.steampowered.com/app/346010/Besiege/  
- Besiege market estimates (reviews/sales context) — https://raijin.gg/app/346010/Besiege  
- World of Goo 2 — https://store.steampowered.com/app/3385670/World_of_Goo_2/  
- People Playground — https://store.steampowered.com/app/1118200/People_Playground/  
- Teardown (scope ceiling warning) — https://store.steampowered.com/app/1167630/Teardown/  
- Universe Sandbox — https://store.steampowered.com/app/230290/Universe_Sandbox/  
- Primordialis — https://store.steampowered.com/app/3011360/Primordialis/  
- KINETIKA — https://store.steampowered.com/app/2820090/KINETIKA/  
- EXPHYSIA — https://store.steampowered.com/app/2676790/EXPHYSIA/  

### Material / sand / particle
- Noita — https://store.steampowered.com/app/881100/Noita/  
- Sandboxels — https://store.steampowered.com/app/3664820/Sandboxels/  
- Stardust Sandbox — https://store.steampowered.com/app/4348740/Stardust_Sandbox/  
- Particul (repo-adjacent idle; do not mash) — https://store.steampowered.com/app/4273120/Particul/  

### Unique-mechanic / puzzle prestige
- Baba Is You — https://store.steampowered.com/app/736260/Baba_Is_You/  
- Opus Magnum — https://store.steampowered.com/app/558990/Opus_Magnum/  

### AI-inventive peers (competition + caution)
- GUG — https://store.steampowered.com/app/2824790/GUG/  
- AI Roguelite — https://store.steampowered.com/app/1889620/AI_Roguelite/  
- AI Roguelite 2D — https://store.steampowered.com/app/2800150/AI_Roguelite_2D/  
- Haze — https://store.steampowered.com/app/4034940/Haze/  

### Short-session / simple-rule market signal
- Buckshot Roulette — https://store.steampowered.com/app/2835570/Buckshot_Roulette/  
- Buckshot 8M sales reporting — https://techraptor.net/gaming/news/buckshot-roulette-sales-8m  
- Balatro (synergy / simple-rules depth; different genre) — https://store.steampowered.com/app/2379780/Balatro/  
- Meccha Chameleon viral simple-mechanic sales context — https://www.polygon.com/meccha-chameleon-sales-15-million/  

### Adaptive / generative without LLM (technical comps)
- Hybrid WFC + genetic algorithms (ICCS 2025) — https://www.iccs-meeting.org/archive/iccs2025/papers/159090105.pdf  
- AI / PCG dungeon generation overview — https://artificial-intelligence-wiki.com/industry-ai/ai-in-gaming/ai-dungeon-generation/  

### Repo-internal
- [`docs/GAME_PLAN.md`](../GAME_PLAN.md)  
- [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)  
- Prior cloud agent (market plan) — https://cursor.com/agents/bc-2f2367d2-9b0d-4093-8ebf-352422ec4f9e  
- This creative pass — https://cursor.com/agents/bc-ac7ac1e1-5da3-4ba7-97e0-4227f244efc5  

---

## Appendix A — One-line elevator pitches (sharing sheet)

1. **Void Plinth** — Place blocks in a void; grammar turns them into towns.  
2. **Wellsinger** — Compose music by placing gravity wells.  
3. **Perimeter** — You are the edge of a living polygon.  
4. **Kiln Contour** — Cook the level into a path.  
5. **Echo Lattice** — The maze rebuilds from your last thirty moves.  
6. **Clingforge** — Build machines that only know stickiness.  
7. **Void Verbs** — Scrape emptiness until the rules exist.  
8. **Fulcrum Stairs** — Climb the staircase you’re also unbalancing.  
9. **Wakeherd** — A flock that terraforms in your wake.  
10. **Caustic Brief** — Falling-sand chemistry with acceptance tests.  
11. **Threadfall** — Route the rain with tensioned threads.  
12. **Pruneclock** — Time moves only when you prune.  
13. **Confessor Room** — Your words rebuild the room that judges you.  
14. **Soft Crown** — Inflatable soft-body kingdom challenges.  
15. **Orbit Ink** — Calligraphy that must remain in orbit.  
16. **Constraint Crypt** — Choose the laws, then survive the dungeon they generate.  
17. **Gargoyle Schema** — Prompt a material; sculpt until it stands the storm.  
18. **Ripple Codex** — Every move bakes a new law of physics.  
19. **Chromafield** — Grow the winning pattern in living math.  
20. **Stilts Protocol** — Stack junk stilts and certify the walk.

---

## Appendix B — Suggested next artifact after lock

When a seed is confirmed:

1. One-page GDD (fantasy, verbs, fail, session length, art direction, Steam tags)  
2. Godot 4 vertical slice milestone list (≤ the weeks above)  
3. Capsule art brief + 15s trailer boards  
4. Explicit **non-goals** list (to protect pure-genre)  

Until then, this document is research — not production scope.
