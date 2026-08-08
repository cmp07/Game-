# Generative Concept Space — Pure Directions

**Repo:** [cmp07/game-](https://github.com/cmp07/game-)  
**Research date:** August 2026  
**Lens:** User vision only — *creation from nothing*, *physics play*, *simple-but-unique mechanics*, *outside-the-box*, especially **generative gaming / generative reality** (“jump in and the game shapes around you”).  
**Hard rule (aligned with [`GAME_PLAN.md`](../GAME_PLAN.md)):** each direction is **one coherent product**, not a mashup. Do **not** fold this space into the separate Steam-catalog path (tension vignette / coin-machine / idle-particle). Those are other products.

---

## 0. How to read this document

This is a **concept-space map**, not a production GDD and not a ranking of what to ship next week. The goal is to separate *fantasy families* that all rhyme with the vision, so a future product choice can be *pure* rather than a Frankenstein of “Spore + Noita + LLM + Tiny Glade.”

For each of **10 directions**:

| Field | Meaning |
|---|---|
| **Fantasy** | The one-sentence itch the store page sells |
| **Core loop** | What you do every 30–90 seconds |
| **Shapes around you** | The concrete generative contract (not vibes) |
| **AI vs non-AI** | What must be ML vs what should be simulation/rules |
| **Solo ship risk** | Honest difficulty for one skilled Godot solo / tiny team |
| **Steam comps** | Nearest commercial neighbors (affinity, not clones) |
| **Inventiveness** | 1–10 relative novelty *if executed as a pure product* |

**Inventiveness scale (local to this report):**

| Score | Meaning |
|---|---|
| 1–3 | Crowded lane; need a razor hook to matter |
| 4–6 | Known family with room for a sharp twist |
| 7–8 | Distinct product fantasy; few clean Steam neighbors |
| 9–10 | Category-defining if shipped; also demoware-magnet |

---

## 1. Vision distillation (do not dilute)

The vision is **not** “games I liked on Steam.” It is a cluster of *player feelings*:

1. **Ex nihilo** — start with emptiness or near-emptiness; *making* is the point.
2. **Physics as language** — the world answers with bodies, fluids, constraints, not menus.
3. **One weird verb** — simple rules that generate surprising sentences (Baba / Noita energy without copying them).
4. **Outside the box** — the product should feel like it shouldn’t exist as a normal genre slot.
5. **Generative reality** — the world *reconfigures around the player’s presence, habits, and authorship*, not merely “procedural map seed.”

### What “shapes around you” is *not*

| Trap | Why it fails the vision |
|---|---|
| Infinite LLM chat with a wallpaper | Shapes *text*, not *reality* |
| Roguelike RNG seed | Novelty without authorship |
| Open-world survival checklist | Content mountain wearing a generative mask |
| “AI everything” store page | Steam backlash + demoware smell ([Next Fest AI disclosure wave](https://www.pcgamesn.com/steam/next-fest-generative-ai)) |
| Mash of coin + idle + horror + creation | Violates pure-product rule in this repo |

### Two generative stacks (keep them separate)

| Stack | What generates | Trust model | Best use in this vision |
|---|---|---|---|
| **Simulation generative** | Physics, automata, grammar, ecology rules | Offline, deterministic-ish, clip-friendly | Default for shipped “reality” |
| **Model generative** | LLM / image / audio models | Online cost, variance, policy risk | Optional *authoring layer*, not the whole game |

**Honest bias of this report:** the vision’s strongest commercial + craft fits are usually **simulation-first** with optional light AI. Pure “AI is the game” is high inventiveness and high demoware risk.

---

## 2. Competitive landscape (comps used below)

### A. World grows / adapts around presence

| Title | Affinity | Notes |
|---|---|---|
| [Shape of the World](https://store.steampowered.com/app/611800/Shape_of_the_World/) | Presence → flora/terrain populates | Calm explorer; world materializes near you |
| [Bililitz](https://store.steampowered.com/app/4079270/Bililitz/) | Presence awakens land | Metroidvania framing; growth-as-progress |
| [Drift](https://store.steampowered.com/app/4379180/Drift/) | Session-unique procedural haze world | Atmosphere > systems depth |
| [Tiny Glade](https://store.steampowered.com/app/2198150/Tiny_Glade/) | Builder input → procedural adornment | Overwhelmingly Positive; *chemistry*, not sim depth |
| [Grow Home](https://store.steampowered.com/app/323320/Grow_Home/) | Grow plant = make path | Creation-as-traversal |

### B. Physics play / creation toys

| Title | Affinity | Notes |
|---|---|---|
| [Noita](https://store.steampowered.com/app/881100/Noita/) | Pixel sim as magic | High bar; every pixel is the joke |
| [People Playground](https://store.steampowered.com/app/1118200/People_Playground/) | Detailed toy physics + workshop | Emergent sandbox dopamine |
| [Teardown](https://store.steampowered.com/app/1167630/Teardown/) | Destructible voxels + mission verbs | Freedom with structure |
| [Besiege](https://store.steampowered.com/app/346010/Besiege/) | Build machine → physics trial | Constrained creation + goals |
| [Primordialis](https://store.steampowered.com/app/3011360/Primordialis/) | Body-as-contraption | Creation *is* the avatar |
| [World of Goo 2](https://store.steampowered.com/app/3385670/World_of_Goo_2/) | Soft-body / fluid puzzle | Physics as puzzle language |
| [Plasma](https://store.steampowered.com/app/1409160/Plasma/) | Engineering sandbox | Creative ceiling, soft structure |

### C. Unique-mechanic / outside-the-box

| Title | Affinity | Notes |
|---|---|---|
| [Baba Is You](https://store.steampowered.com/app/736260/Baba_Is_You/) | Rules as physical objects | Peak “simple unique verb” |
| [Patrick’s Parabox](https://store.steampowered.com/app/1260520/Patricks_Parabox/) | Recursive space | One idea, deep pedagogy |
| [Everything](https://store.steampowered.com/app/582270/Everything/) | Scale-shift ontology | Philosophical toy, weak “game” loop |
| [Outer Wilds](https://store.steampowered.com/app/753640/Outer_Wilds/) | Knowledge as progress; world-time | Studio-scale; taste signal only |
| [WorldBox](https://store.steampowered.com/app/1206560/WorldBox__God_Simulator/) | God sandbox + living systems | Creation + watching |

### D. Generative AI products (cautionary comps)

| Title | Affinity | Notes |
|---|---|---|
| [DREAMIO](https://store.steampowered.com/app/2795060/DREAMIO_AIPowered_Adventures/) | Live gen story + images | API / model dependency front-and-center |
| [Saga & Seeker](https://store.steampowered.com/app/3522640/Saga__Seeker/) | Freeform storycrafting | Metered “Ink” economy for AI cost |
| [Book of Infinity: 1001 Nights](https://store.steampowered.com/app/2542850/Book_of_Infinity_1001_Nights/) | Stories become game objects | Stronger *game* framing than pure chat |
| [AI Script](https://store.steampowered.com/app/3991060/AI_Script_Infinite_Text_Adventures/) | Infinite TRPG text | Content infinity ≠ mechanical depth |

### E. Historical warnings

- **Spore** — creature creator ecstasy vs overpromised “generative universe” ([Chris Hecker liner notes](http://www.chrishecker.com/My_Liner_Notes_for_Spore); [Gamedeveloper oral history](https://www.gamedeveloper.com/audio/developing-i-spore-i-an-oral-sporal-history-10-years-on)).
- **No Man’s Sky launch** — procedural vastness without enough *authored verbs* ([developer reactions](https://www.gamedeveloper.com/design/what-game-developers-are-saying-about-i-no-man-s-sky-i-)).
- **Steam Next Fest AI wave** — disclosure + “slop” perception risk even when tech is real ([PCGamesN](https://www.pcgamesn.com/steam/next-fest-generative-ai), [Insider Gaming](https://insider-gaming.com/steam-next-fest-great-but-ai-games-is-not/), [Technobezz](https://www.technobezz.com/news/steam-next-fest-faces-criticism-over-influx-of-ai-generated-demos)).

---

## 3. Demoware traps (read before falling in love)

These kill generative pitches more often than “bad art”:

1. **Infinity without verbs** — endless worlds/text, three verbs (walk, look, pick up).
2. **Trailer lies** — Spore/NMS-class promise gap; Steam reviews never forget.
3. **API as gameplay** — latency, cost spikes, offline failure, ToS/content filters mid-session.
4. **Model as designer** — LLM invents quests that break your ruleset; you spend the project writing guardrails.
5. **Procgen sameness** — variety that players perceive as repetition (NMS lesson).
6. **Sandbox with no share loop** — People Playground / Besiege thrive partly because Workshop makes content *infinite without you*.
7. **“AI art” store stigma** — even good loops get painted as slop if the page smells generated.
8. **Scope cosplay** — Outer Wilds / Dreams / Spore fantasies dressed as a $5 solo game.

**Rule of thumb:** if the vertical slice cannot demo the *shape-around-you moment* in **60–90 seconds offline**, it is demoware.

---

## 4. Ten pure directions

---

### Direction 1 — Presence Bloom (non-AI ecology that materializes around you)

**Fantasy:** You are the weather front of life. Empty land only becomes real where you have been — and *how* you move chooses what grows.

**Core loop:** Move with intent (linger / sprint / circle / climb) → local ecosystem instantiates with rules tied to your motion signature → harvest a scarce “seed of place” → spend it to *lock* a biome patch permanently → push into the next blank frontier.

**How it shapes around you:** Not a static seed. A **behavior → biome grammar**: circling births spirals; stillness grows towers; falling creates canyons. Retracing steps can *regrow differently* unless locked (Shape of the World’s “regrows when you pass” dialed into a *skillful* language).

**AI vs non-AI:**
- **Non-AI (core):** motion classifiers, WFC / grammar biomes, particle flora, simple animal FSMs.
- **AI (optional later):** name locked places; generate postcard lore. Not required to ship.

**Solo ship risk:** **Medium.** Tech is classic procedural + juice. Hard part is making motion→biome readable and not mush. Art direction must sell “blank → alive” in the first minute.

**Steam comps:** Shape of the World, Bililitz, Drift, Grow Home, Tiny Glade (adornment chemistry, not the loop).

**Inventiveness:** **7/10** — presence-growth exists, but *motion-as-biome-language with lock/frontier tension* is a clean pure product.

**Demoware watch:** Pretty fog + random trees ≠ product. If players can’t *author* the land with their body, it’s a walking sim.

---

### Direction 2 — Ex Nihilo Architect (create a place from absolute nothing)

**Fantasy:** The void is your clay. You place the first stone — and the game’s only job is to make that stone feel like a world answering back.

**Core loop:** Place / extrude / cut a primitive → game auto-completes structural “chemistry” (supports, openings, materials) → inhabit first-person → discover a need (light, water, path, sound) → place the next primitive that solves it → optional photo / seed share.

**How it shapes around you:** The world is empty until you author topology. Generative layer is **reactive detailing + constraint solving** (Tiny Glade’s “path punches a door” philosophy), plus soft simulation (light, drip, wind resonance) so the void *feels* physical.

**AI vs non-AI:**
- **Non-AI (core):** CSG/voxels, procedural mesh adornment, constraint solvers, baked light probes.
- **AI (avoid for v1):** “describe a castle” text-to-3D. That is a different, heavier product and a demoware magnet.

**Solo ship risk:** **Medium–high.** Tiny Glade proved the market; competing on beauty is brutal. Survive by being *void-first* and physics-forward (collapse, drip, echo) rather than cozy diorama clone.

**Steam comps:** Tiny Glade, WorldBox (god tools), Plasma (creative ceiling), Teardown sandbox mode (matter as toy).

**Inventiveness:** **5/10** as cozy builder; **7/10** if void + physics consequences are the brand (creation that can fail spectacularly).

**Demoware watch:** Asset-flip town builder; AI screenshot store page; “infinite build” with no feel of matter.

---

### Direction 3 — One-Law Physics Toy (a single physical law you rewrite)

**Fantasy:** The universe has one editable constant. Change it — and the room becomes a new instrument.

**Core loop:** Enter a chamber with a goal (reach, rescue, destroy, transmit) → tweak one exposed law (gravity vector, restitution, time rate, friction field, link distance) → play the consequences → collect a “law shard” → compose 2–3 laws in later chambers → sandbox lab unlock.

**How it shapes around you:** The level geometry can stay fixed; **reality’s parameters** reshape the playable space around your choices. Generative *feel* comes from continuous physics, not LLM content. Optional: chambers mutate layout based on which laws you’ve mastered (capability-gated generation).

**AI vs non-AI:**
- **Non-AI (core):** rock-solid 2D or 3D physics, deterministic replays, clever level grammar.
- **AI:** none required. Level gen can be grammars / constraint search.

**Solo ship risk:** **Medium.** Closest to “simple unique mechanic” shipping path (Baba energy without word blocks). Needs excellent pedagogy and a killer trailer verb.

**Steam comps:** Baba Is You (rule edit fantasy), Patrick’s Parabox (one idea deep), World of Goo 2 (physics as puzzle), Besiege (physics trial), Teardown (environment as tool).

**Inventiveness:** **8/10** if the *one-law* framing stays pure; drops if it becomes a kitchen-sink sandbox.

**Demoware watch:** Twenty half-working constants. Ship **one** law brilliantly, then expand.

---

### Direction 4 — Sand-Reality Descent (falling-sand world that is the dungeon)

**Fantasy:** You don’t cast spells — you *pour laws* into a world where every grain is real.

**Core loop:** Enter a column of matter → mix elements with a tiny verb set (dig, pour, ignite, freeze, bridge) → open a route or neutralize a hazard → grab a new element recipe → deeper biome with nastier interactions → die to a chain reaction you caused → knowledge persists.

**How it shapes around you:** The “level” is an unstable material simulation. Your digs and pours permanently rewrite topology; later areas can ingest your leftover materials as seeds (your mess becomes the next generative input).

**AI vs non-AI:**
- **Non-AI (core):** cellular automata + rigid bodies; recipe graph; performance budgeting.
- **AI:** recipe naming / bestiary blurbs optional.

**Solo ship risk:** **High.** Noita’s shadow is enormous; performance and content readability are graveyards. Viable only with a *narrower* fantasy (e.g. vertical descent, 8 elements, no full spell RPG).

**Steam comps:** Noita, People Playground (systems emergence), World of Goo 2 (fluids), Terra Physics & Money–class voxel fluid toys.

**Inventiveness:** **6/10** in open sand genre; **8/10** if “your residue seeds the next floor” is the generative hook and scope stays ruthless.

**Demoware watch:** Tech demo of pretty powder. Without a tense loop and readable recipes, it’s screensaver.

---

### Direction 5 — Body is the World Seed (creature/contraption creation as generative key)

**Fantasy:** You build a body from almost nothing — and the planet that sprouts is the ecological answer to *that* body.

**Core loop:** Assemble a creature/machine from few parts → drop into a void capsule → world generates biomes, hazards, and affordances matched to your morphology → survive / explore / collect new parts → rebuild → new world answers the new body.

**How it shapes around you:** Generative contract is explicit: **morphology → world grammar**. Wings bias toward updraft canyons; drills bias toward sediment layers; wheels bias toward hardpan. This is Spore’s *creator ecstasy* without promising a galactic 4X.

**AI vs non-AI:**
- **Non-AI (core):** part graph, procedural animation lite, world templates parameterized by part tags.
- **AI (optional):** creature portraits, discovered-species encyclopedia text.

**Solo ship risk:** **High.** Spore’s lesson: creator tools are a game; everything around them can drown you. Ship as **creator → matched pocket world → part unlock**, not as life sim.

**Steam comps:** Spore (creator taste + warning), Primordialis, Besiege, Plasma, Everything (ontology toy).

**Inventiveness:** **8/10** — “body seeds the planet” is a strong pure fantasy if not bloated into Palworld/Spore-scale.

**Demoware watch:** Creature editor trailer that never shows the generative answer. If the world doesn’t *clearly* reflect the body, the pitch collapses.

---

### Direction 6 — Echo Cartography (the map is your behavioral fossil)

**Fantasy:** The dungeon is made of *you* — your habits, hesitations, and routes fossilize into architecture.

**Core loop:** Run a short expedition in a sparse template → game records path heat, combat panics, camps, deaths → between runs, those traces crystallize into halls, shrines, traps, NPCs → re-enter a world that has become a museum of your play → choose to reinforce or erase fossils → push toward a “self-made” apex.

**How it shapes around you:** Literal generative reality: **telemetry → architecture**. Not “AI dungeon master,” more like a compiler from play traces to geometry and encounters.

**AI vs non-AI:**
- **Non-AI (core):** trace logging, geometry extrusion, encounter tags from events.
- **AI (optional, careful):** NPC dialogue that comments on your fossilized habits. Cool, not load-bearing.

**Solo ship risk:** **Medium–high.** Systems are doable; the design risk is making fossils *legible and fair*. Players must feel authorship, not random punishment.

**Steam comps:** roguelike meta-progression cousins; Outer Wilds (knowledge/world coupling as *taste*); Shape of the World (presence mark); no perfect 1:1 Steam twin — that’s the point.

**Inventiveness:** **9/10** — scarce clean comps; easy to undersell or overcomplicate.

**Demoware watch:** Invisible stats dressed as “the game knows you.” Must show fossils forming on-screen.

---

### Direction 7 — Mythographic Physics (naming / drawing summons real matter)

**Fantasy:** Language and sketch are engineering. What you name into being must obey — and can betray — physics.

**Core loop:** Face a physics puzzle void → summon an object by **word, stamp, or glyph** from a limited lexicon → object appears with material properties → solve via emergent interactions → unlock lexicon entries that combine (steam, rope, magnet…) → optional daily seed / share glyph solutions.

**How it shapes around you:** The blank stage fills with *your* ontology. Generative layer is **lexeme → prefab/material graph**, not free LLM objects (Scribblenauts lesson: curated dictionary beats infinite nonsense).

**AI vs non-AI:**
- **Non-AI (recommended core):** hand-authored lexicon + combo table + physics.
- **AI (high risk mode):** open vocabulary → generated meshes/behaviors. Spectacular demos, miserable edge cases, moderation hell.

**Solo ship risk:** **Medium** with closed lexicon; **extreme** with open generative summoning.

**Steam comps:** Scribblenauts lineage (summon fantasy), Baba Is You (language as mechanism), 1001 Nights (stories→objects, AI-assisted), World of Goo (objects as verbs).

**Inventiveness:** **7/10** closed lexicon; **9/10** open AI summoning (and **demoware likelihood also 9/10**).

**Demoware watch:** “Type anything” trailers. Prefer **closed lexicon with surprising combos** for a shippable pure product.

---

### Direction 8 — Recursive Pocket Worlds (space that contains space you author)

**Fantasy:** You carry boxes of reality. Inside each box is a world you can enter — and those worlds can contain you.

**Core loop:** Solve a spatial goal → earn a pocket → enter pocket to rearrange its local physics/layout → exit to use the pocket as a tool in the outer world → discover recursion gags (world-in-world) → assemble a personal nested atlas.

**How it shapes around you:** Generative reality is **hierarchical authorship**. The outer world stays lean; depth comes from nested spaces you configure. Later outer rooms can spawn topology based on which pockets you carry (inventory as worldgen seed).

**AI vs non-AI:**
- **Non-AI (core):** portal/recursion tech, sokoban-grade clarity, editor-grade pocket tools.
- **AI:** unnecessary.

**Solo ship risk:** **Medium.** Parabox proved recursion sells; you must differentiate (physics toys inside pockets, not pure puzzle clones).

**Steam comps:** Patrick’s Parabox, Baba Is You, COCOON-like nesting fantasies, Dreams (creation platform — scope warning).

**Inventiveness:** **7/10** — recursion is known; *pockets as physics instruments that seed the outer map* stays distinct if pure.

**Demoware watch:** Tech demo of portals without a crystal-clear verb and campaign pedagogy.

---

### Direction 9 — God Petri Dish (create laws, then watch + poke)

**Fantasy:** You are not the hero. You are the author of a tiny universe’s physics and hungers — then you interfere.

**Core loop:** Paint terrain from void → sprinkle agents with needs → set 1–2 laws (predator rule, growth rule, worship rule) → observe → poke with disasters/gifts → unlock new law cards → chase emergent stories you can screenshot/share.

**How it shapes around you:** The dish reorganizes around the laws *you* enacted and the disasters *you* choose. Generative story is emergence, not script.

**AI vs non-AI:**
- **Non-AI (core):** agent sim, law cards, readable debug-as-juice.
- **AI (optional):** auto-narrate an emergent chronicle from event logs (post-hoc, not live GM). This is the *good* AI use: storytelling about what already happened.

**Solo ship risk:** **Medium.** WorldBox exists; differentiation must be **fewer agents, sharper laws, better readable emergence**, not bigger maps.

**Steam comps:** WorldBox, Everything, People Playground (systems toy), RimWorld (aspiration/warning — do not chase depth).

**Inventiveness:** **5/10** crowded god-game shelf; **7/10** if marketed as *law-crafting instrument* with exquisite minimal agents.

**Demoware watch:** Fake “AI life” claims; invisible needs; laggy 10k units. Keep the dish small enough to *feel*.

---

### Direction 10 — Generative Reality Runtime (AI as world compiler — ambitious / hazardous)

**Fantasy:** Jump into a premise — a sentence, a sketch, a photo — and play inside a world compiled to fit you, live.

**Core loop:** Offer a seed (prompt / sketch / play-style quiz) → system compiles a playable pocket (layout, goals, materials) → you play 5–15 minutes → system recompiles the next pocket from your outcomes and preferences → collect “reality cards” that constrain future compiles (so infinity gains grammar).

**How it shapes around you:** Strongest literal reading of “generative reality.” The product *is* adaptation. Without **reality cards** (hard constraints), it collapses into DREAMIO-class content firehose.

**AI vs non-AI:**
- **AI (core):** layout/content proposal, maybe texture/music variants.
- **Non-AI (must be core too):** physics validation, playable prefab library, solvers that reject impossible compiles, offline fallback pockets.
- **Economic design:** metered generation (see Saga & Seeker’s Ink) or local-only models — both are product decisions, not afterthoughts.

**Solo ship risk:** **Extreme.** This is studio research dressed as an indie pitch unless ruthlessly capped (one biome grammar, fifty prefabs, offline-first).

**Steam comps:** DREAMIO, Saga & Seeker, 1001 Nights, AI Script; also the cautionary shadows of Spore promises and Next Fest AI fatigue.

**Inventiveness:** **9/10** (category heat) with **honesty score: demoware until proven otherwise**.

**Demoware watch:** Everything. Ship only if the slice shows: seed → *playable physics pocket* → visible recompile that respects a reality card — offline.

---

## 5. Cross-cut matrix

| # | Direction | Ex nihilo | Physics play | Simple unique verb | Shapes around you | Solo risk | Inventiveness |
|---|---|---|---|---|---|---|---|
| 1 | Presence Bloom | Medium | Low–Med | Motion→biome | Presence/behavior | Medium | 7 |
| 2 | Ex Nihilo Architect | **Max** | Medium | Place/cut + chemistry | Authored topology | Med–High | 5–7 |
| 3 | One-Law Physics Toy | Low | **Max** | **Max** | Law parameters | Medium | 8 |
| 4 | Sand-Reality Descent | Medium | **Max** | Element verbs | Residue→next floor | High | 6–8 |
| 5 | Body is World Seed | High | High | Build body | Morphology→world | High | 8 |
| 6 | Echo Cartography | Medium | Low–Med | Expedition→fossil | Play traces→map | Med–High | 9 |
| 7 | Mythographic Physics | High | High | Summon lexicon | Ontology fills void | Med / Extreme* | 7–9 |
| 8 | Recursive Pockets | Medium | Medium | Enter/configure pocket | Nested authorship | Medium | 7 |
| 9 | God Petri Dish | High | Medium | Law cards | Laws→emergence | Medium | 5–7 |
| 10 | Generative Runtime | High | Low–Med† | Seed→compile | Full adaptive compile | **Extreme** | 9 |

\*Extreme if open-vocabulary AI summoning.  
†Physics only stays strong if compiles emit *simulated prefabs*, not narrative rooms.

---

## 6. Alignment with repo strategy (without mashing)

[`GAME_PLAN.md`](../GAME_PLAN.md) commits to **sequential small Steam products** and **pure categories**. This concept space is a **parallel aspiration lane**, not a reason to abandon the fast catalog path.

Practical reading:

| If you want… | Prefer |
|---|---|
| Fastest credible “vision-shaped” experiment | **Direction 3 (One-Law)** or **1 (Presence Bloom)** |
| Strongest “creation from nothing” brand | **2 (Ex Nihilo)** or **5 (Body Seed)** with brutal scope caps |
| Strongest literal “shapes around you” | **6 (Echo Cartography)** or **1 (Presence Bloom)** |
| Maximum ambition / maximum demoware gravity | **10 (Generative Runtime)** — research prototype, not Game 1 |
| Do **not** combine with | Coin-pusher, idle tycoon, Buckshot-format vignette |

The catalog games (tension / coin / idle) can fund the weird game. The weird game should not be asked to fund itself *and* prove three genres at once.

---

## 7. Recommended “pure shortlist” (still not a ship order)

If forced to keep only three directions alive as *possible* future products:

1. **One-Law Physics Toy (#3)** — best marriage of inventiveness, trailer clarity, solo odds, physics play.  
2. **Echo Cartography (#6)** — purest “shapes around you” that isn’t an LLM wrapper.  
3. **Body is World Seed (#5)** — purest “creation from nothing” with generative answer — *only* with Spore-scope discipline.

Honorable non-AI presence pick: **Presence Bloom (#1)** if the emotional target is wonder over puzzle mastery.

Park **#10** behind a tech prototype gate: *offline compile of a physics pocket from a seed + one reality card*. No gate pass → no production.

---

## 8. Sources

### Steam / product pages

- Shape of the World — https://store.steampowered.com/app/611800/Shape_of_the_World/ (also covered via retailer/IndieDB descriptions of presence-driven procedural population)
- Bililitz — https://store.steampowered.com/app/4079270/Bililitz/
- Drift — https://store.steampowered.com/app/4379180/Drift/
- Tiny Glade — https://store.steampowered.com/app/2198150/Tiny_Glade/
- Grow Home — https://store.steampowered.com/app/323320/Grow_Home/
- Noita — https://store.steampowered.com/app/881100/Noita/
- People Playground — https://store.steampowered.com/app/1118200/People_Playground/
- Teardown — https://coffeestain.com/game/teardown/ · Steam app 1167630
- Besiege — https://store.steampowered.com/app/346010/Besiege/
- Primordialis — https://store.steampowered.com/app/3011360/Primordialis/
- World of Goo 2 — https://store.steampowered.com/app/3385670/World_of_Goo_2/
- Plasma — https://store.steampowered.com/app/1409160/Plasma/
- Baba Is You — https://store.steampowered.com/app/736260/Baba_Is_You/
- Patrick’s Parabox — https://store.steampowered.com/app/1260520/Patricks_Parabox/
- Everything — https://store.steampowered.com/app/582270/Everything/
- Outer Wilds — https://store.steampowered.com/app/753640/Outer_Wilds/
- WorldBox — https://store.steampowered.com/app/1206560/WorldBox__God_Simulator/
- DREAMIO — https://store.steampowered.com/app/2795060/DREAMIO_AIPowered_Adventures/
- Saga & Seeker — https://store.steampowered.com/app/3522640/Saga__Seeker/
- Book of Infinity: 1001 Nights — https://store.steampowered.com/app/2542850/Book_of_Infinity_1001_Nights/
- AI Script — https://store.steampowered.com/app/3991060/AI_Script_Infinite_Text_Adventures/
- Lay of the Land — https://store.steampowered.com/app/2776090/Lay_of_the_Land/
- Terra Physics & Money — https://store.steampowered.com/app/4983940/Terra_Physics__Money/

### Design / industry commentary

- Chris Hecker — Spore liner notes: http://www.chrishecker.com/My_Liner_Notes_for_Spore
- GameDeveloper — Spore oral history: https://www.gamedeveloper.com/audio/developing-i-spore-i-an-oral-sporal-history-10-years-on
- GameDeveloper — What developers said about No Man’s Sky: https://www.gamedeveloper.com/design/what-game-developers-are-saying-about-i-no-man-s-sky-i-
- GameDeveloper — Designing Baba Is You’s rule system: https://www.gamedeveloper.com/design/designing-i-baba-is-you-i-s-delightfully-innovative-rule-writing-system
- IDA Journal — procedural design / NMS player perception study: https://idajournal.com/index.php/ida/article/view/466
- PCGamesN — Next Fest generative AI demos: https://www.pcgamesn.com/steam/next-fest-generative-ai
- Insider Gaming — Next Fest gen-AI critique: https://insider-gaming.com/steam-next-fest-great-but-ai-games-is-not/
- Technobezz — Next Fest AI demo influx: https://www.technobezz.com/news/steam-next-fest-faces-criticism-over-influx-of-ai-generated-demos
- IndieDB — Shape of the World feature description: https://www.indiedb.com/games/shape-of-the-world

### Internal

- [`docs/GAME_PLAN.md`](../GAME_PLAN.md) — multi-game Steam plan; pure-category rule
- [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md) — separate catalog-lane ranking (do not mash into this space)

---

## 9. Closing stance

The vision is real and commercially adjacent to proven feelings (presence-growth, physics toys, one-verb indies, creator tools). It is also surrounded by **false friends**: infinite AI adventures, vast procedural tourism, and Spore-shaped promises.

**Ambitious:** Echo Cartography, Body-Seed worlds, One-Law physics, and a tightly gated Generative Runtime all deserve prototypes.  
**Honest:** most “generative reality” Steam pages today are either walking sims, god sandboxes, or metered chat wrappers. The winning move is a **single readable generative contract** you can show in one clip — preferably offline, preferably physical — and a refusal to mash that contract with the catalog genres that pay the rent.
