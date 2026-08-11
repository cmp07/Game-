# Five Games to Build — Master Decision Document

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Compiled:** August 2026  
**Role:** Consolidated product decision document — deep market research + inventive synthesis.  
**Supersedes as decision authority:** prior lane rankings that treated tension / coin / idle as the only first-ship frame, and prior **Residue-only** Game 1 tunnel vision. Residue remains a strong *alternate* habit-physics vignette (see sibling PRs); it is **not** one of the five products below.  
**Hard rules:** one **pure** Steam category per SKU · no mashups of library tastes (coin + horror + idle + cards) · Windows Steam `.exe` · Godot 4–feasible · inventiveness over trend-clone · simplicity of *verbs*, not of ambition.

**Mix constraint honored:** Games **1–4** are “simple forever” toys/systems; Game **5** is a sharp short vignette (≤2 vignettes).

---

## Predicted next wave

The commercially hot *types* of 2025 through mid-2026 are already named and crowded: **friendslop** physics co-op (R.E.P.O., PEAK and their clone wave), **gambling-adjacent synergy toys** (Balatro → Nubby’s Number Factory → CloverPit → RACCOIN), and a brutal **idle/incremental supply flood**. Indie expert Chris Zukowski’s “Great Conjunction” framing is useful here: multiple rough-but-fun genres are simultaneously playable for small teams — friendslop, idle, horror (including “horror casino”), rage toys — while Survivors-likes have largely matured into a high-bar niche ([How To Market A Game, Nov 2025](https://howtomarketagame.com/2025/11/04/the-optimistic-case-that-indie-games-are-in-a-golden-age-right-now/); [GamesRadar on Zukowski’s multi-genre boom](https://www.gamesradar.com/games/steams-new-golden-age-is-special-because-so-many-genres-are-popping-off-at-once-indie-expert-says-its-almost-like-the-player-base-was-drinking-and-their-inhibitions-lowered/); [Yahoo / Zukowski on fun-first rough games](https://tech.yahoo.com/gaming/articles/steam-expert-hails-pc-gaming-164447275.html)). Macro cash still concentrates: Steam ~$17.7B in 2025 with indie ~$4.5B / ~25% under Alinea’s stricter cut, ~20k releases, ~300 titles clearing $1M ([GAMES.GG / Alinea summary](https://games.gg/news/indie-games-on-steam-make-4-billion/); [ShaneTheGamer indie stats](https://www.shanethegamer.com/research/indie-games-statistics/)). Q1’26 medians near ~$250 remind us that “genre is hot” ≠ “your clone sells” ([Games-Stats framing via trend-map research](https://github.com/cmp07/Game-/pull/13)).

The **next** wave — the one that has capital narrative + player hunger + room for pure solo SKUs that are *not* “another coin pusher / another Lethal clone / another idle” — is **reactive authorship toys**: single-player games where a tiny, teachable verb set produces a world that is visibly *yours* through **authored simulation and grammars**, not through LLM worldgen. Parallel evidence lines up: (1) players reward “one invented engine taken seriously” (Balatro’s ~7M-unit case study; Nubby’s Overwhelmingly Positive plinko engine at ~$5 — [Deconstructor of Fun / Playstack](https://www.deconstructoroffun.com/blog/2025/10/06/how-do-you-find-and-scale-an-indie-hit-like-balatro), [GamesRadar on Nubby](https://www.gamesradar.com/games/roguelike/its-balatro-all-over-again-a-usd5-plinko-roguelike-from-a-new-solo-dev-is-one-of-the-top-rated-steam-releases-of-2025-and-10-000-reviews-agree-looking-like-a-pre-installed-windows-xp-game-is-a-plus/)); (2) creation toys with reactive detailing convert hard (Tiny Glade ~600k+ early units / Overwhelmingly Positive — [GameDiscoverCo](https://newsletter.gamediscover.co/p/how-tiny-glade-built-its-way-to-600k), [Steam](https://store.steampowered.com/app/2198150/Tiny_Glade/)); (3) industry capital is pouring into **world models / spatial intelligence** (Genie 3, World Labs Marble, Oasis lineage) while Steam **AI-disclosed** shovelware under-converts — Haro’s ~53.6k-title census shows AI flags rising to ~1 in 3 new releases by mid-2026 while success rates lag non-AI peers ([Haro Substack](https://fragwyz.substack.com/p/three-years-of-ai-on-steam); [GamesRadar / Yahoo summaries](https://tech.yahoo.com/gaming/articles/steam-study-over-53-000-160050011.html)). The commercial hole: sell the *feeling* of generative reality (“it shaped around me”) with **offline, deterministic systems** players trust — Director/memory/grammar/physics patterns that research already validates without runtime LLMs ([FBCA / Bayesian content adaptation](https://ar5iv.labs.arxiv.org/html/2105.08484); classical DDA / experience-management lineage).

**Confidence: ~70% (medium-high).** The *demand* for personal, clippable, simple-deep systems is well evidenced; the *label* “reactive authorship toy” is a synthesis, not a Steam tag yet. Risks to the prediction: friendslop and gambling-toys may absorb another year of clone money; cozy-builder saturation could punish soft toys without goals; Valve discovery remains brutal (only hundreds of 2025 releases cleared ~1k reviews — [Yahoo / Zukowski 20k-release note](https://tech.yahoo.com/gaming/articles/terrifying-20-282-games-were-181346503.html)). Mitigation for this repo: ship **pure** products with GIF-obvious verbs, demos that *are* the loop, and longevity paths (level grammar / Workshop / DLC packs) rather than chasing RACCOIN’s 100k-in-24h lottery ([Polygon / Steam news](https://www.polygon.com/raccoin-steam-sales/); [dev Steam news](https://store.steampowered.com/news/app/3784030/view/538883150377386558)).

**What we are explicitly *not* predicting as Game 1–5:** Minecraft clones or survival-craft mashes; post-RACCOIN coin-pusher clones; Buckshot shotgun clones; CloverPit slot-horror clones; Particul idle clones; friendslop MP-first; LLM “infinite world” store fantasies. Minecraft appears below only as a **simplicity-of-verbs → years-of-play** analogy.

---

## Game 1

- **Working title:** Echo Lattice  
- **One-sentence pitch:** A labyrinth that rebuilds from your last thirty moves — you escape by rewriting your own habits, not by beating RNG.  
- **Player fantasy:** The dungeon is a function of *me*. Same seed, different player → different building. Mastery is becoming a person who leaves kinder corridors behind.  
- **Dimension:** 2D top-down (grid + soft parallax); optional fake-3D presentation later, not required for MVP.  
- **Why it’s easy to learn in 30 seconds:** Four directions + one interact. First chamber has no rewrite — then checkpoint one mirrors your path into walls. The “wait, *I* made that?” beat is the tutorial.  
- **Core loop:**  
  - **Second:** Step; hear tile; see ghost of recent moves.  
  - **Minute:** Hit checkpoint → lattice regenerates from a transform of your move buffer → collect key / reach door.  
  - **Session (15–40 min):** Clear a wing of 6–10 chambers; unlock a new transform (mirror, rotate, thicken, invert).  
  - **Meta:** Habit profile (dash-heavy / loopy / hesitant) biases which transform packs appear; daily “same seed as a friend” challenge; ghost races against your prior self.  
- **Unique inventiveness (what’s outside the box):** Most “adaptive” games hide a difficulty slider. Echo Lattice makes adaptation the *spectacle* — the architecture is a readable transcript of your behavior. Deterministic from input → streamer science content (“watch the maze become a different person”).  
- **How it can “shape around the player” WITHOUT requiring LLM worldgen:** Move buffer → hash → authored tile grammar (WFC / rewrite rules). Optional Markov thicken from your last session’s turn rate. No text model, no online API. Academic cousin: player-conditioned PCG / Bayesian content adaption for targeting feel without inventing lore ([arXiv FBCA](https://ar5iv.labs.arxiv.org/html/2105.08484); WFC+GA adaptive dungeon work cited in prior concept research).  
- **Systems list:**  
  - **MVP:** Move buffer, 1 rewrite grammar, 12 handmade chambers, ghost path replay, undo, Steam demo of first wing, offline save.  
  - **Later:** Transform deck, daily seed, habit profile UI, level editor + Workshop, accessibility (colorblind lattice, hold-to-walk), controller glyphs, leaderboards for ghost races.  
- **Art/audio direction (cheap but strong):** Monochrome lattice + one accent color that “infects” tiles you overuse. Modular corridor kits (8 tiles). Audio: footstep materials that pitch-shift when a rewrite is about to punish a habit; no dialogue. Think brutalist subway map, not fantasy dungeon kitbash.  
- **Why it can live for years:** Grammar packs, editor, Workshop, seasonal seeds, “habit leagues.” Depth is combinatorial (player × transform), not content mountain — same longevity logic as Baba / simple-deep engines ([simple-deep research framing](https://github.com/cmp07/Game-/pull/17)).  
- **Price, Steam tags, trailer hook (first 5 seconds):** **$5.99–$8.99**. Tags: Puzzle, Roguelike (*light*), Procedural Generation, Minimalist, Replay Value, Singleplayer, 2D. Trailer: player walks a clean hall → checkpoint flashes → walls slam into the exact shape of their last loop → on-screen text: “It learned you.”  
- **Solo Godot 8–16 week MVP milestone plan:**  
  - **W1–2:** Grid mover, buffer, one mirror rewrite, debug viz.  
  - **W3–4:** Grammar v1, 6 chambers, fail/reset juice.  
  - **W5–6:** Ghost replay, 12 chambers, meta transform unlock.  
  - **W7–8:** Demo build, Steam page, capsule, Next Fest checklist.  
  - **W9–12:** Polish readability, accessibility, 4 more chambers, controller.  
  - **W13–16:** Wishlist push, trailer, Achievements, Cloud, launch candidate.  
- **Risks & mitigations:** Feels “random” if determinism isn’t communicated → show ghost + seed string always. Cold/abstract → commit hard to audio identity. Scope into open sandbox → **chambers first**, editor later.  
- **Closest comps (and how we are NOT a clone):** Adaptive/PCG discourse and vignette pacing lessons from short-session hits ([Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) as *format*, not theme); contrast API chat titles like [AI Roguelite](https://store.steampowered.com/app/1889620/AI_Roguelite/). Not a roguelike loot crawl, not an AI chatbot dungeon, not Residue’s physics-law patches.  
- **Why THIS fits 2026–27 prediction:** Purest non-LLM “shapes around you” product on this list — sells generative-reality fantasy while Haro’s data says AI-flagged shovelware underperforms ([Haro](https://fragwyz.substack.com/p/three-years-of-ai-on-steam)).

---

## Game 2

- **Working title:** Edgewright  
- **One-sentence pitch:** You are not inside the shape — you *are* the edge; walk a living polygon until its silhouette becomes a door, a cage, or a keyhole.  
- **Player fantasy:** God of outlines. Space is clay and your footsteps are the knife.  
- **Dimension:** 2D vector silhouette world (true 2D); presentation can fake depth with shadows.  
- **Why it’s easy to learn in 30 seconds:** Left/right along the perimeter; one “pin” button freezes a vertex. First level: stretch a blob until it covers a star silhouette. Instant readability.  
- **Core loop:**  
  - **Second:** Slide along edge; feel lengthen/shorten/fold.  
  - **Minute:** Spend pins; match silhouette / contain the red / thread a doorway.  
  - **Session:** 8–15 handmade glyphs; introduce one new edge verb (bevel, zip, mirror-pin).  
  - **Meta:** Gallery of player silhouettes; weekly glyph; editor for community packs.  
- **Unique inventiveness (what’s outside the box):** Almost every puzzle puts you *in* space. Edgewright makes the player the boundary operator — the maze is the creature you sculpt. Signed-distance interiors rewrite walkable space as you move.  
- **How it can “shape around the player” WITHOUT requiring LLM worldgen:** Geometry is a direct function of input; optional “habit bias” slightly softens edges you historically pin (comfort) or hardens them (challenge packs). Pure math, offline.  
- **Systems list:**  
  - **MVP:** Edge walker, pin, 20 levels, undo, ghost silhouette, demo of first 8.  
  - **Later:** Editor, Workshop, daily glyph, new edge verbs DLC, speedrun ghosts, colorblind modes.  
- **Art/audio direction (cheap but strong):** High-contrast ink on paper; one ink color per world. Sound: taut-string friction when edges stretch; paper-tear on fail. Extremely cheap asset surface — identity is motion, not spritesheets.  
- **Why it can live for years:** Level-authoring runway is infinite; editor/UGC is the Minecraft-style *longevity pattern* (simple verbs → community content), without being a voxel sandbox. Prestige puzzle comps often price $15–$20 ([Baba Is You](https://store.steampowered.com/app/736260/Baba_Is_You/), [Patrick’s Parabox](https://store.steampowered.com/app/1260520/Patricks_Parabox/)); we stay in-band with packable sessions.  
- **Price, Steam tags, trailer hook (first 5 seconds):** **$6.99–$9.99**. Tags: Puzzle, Minimalist, Abstract, Singleplayer, Indie, Level Editor (post-MVP). Trailer: a messy blot walks itself into a perfect keyhole in five seconds flat.  
- **Solo Godot 8–16 week MVP milestone plan:**  
  - **W1–3:** Perimeter controller + SDF containment tests.  
  - **W4–6:** Pin verb, 12 levels, undo.  
  - **W7–9:** 20 levels, juice, demo.  
  - **W10–12:** Capsule/trailer, Steamworks, polish.  
  - **W13–16:** Buffer levels + accessibility + launch.  
- **Risks & mitigations:** Reads as “too abstract” → open with figurative glyphs (animals, keys, faces). Math bugs → golden replay tests. Premium-puzzle expectation creep → keep sessions short; sell packs later.  
- **Closest comps:** Baba / Parabox as *one-idea depth* culture, not clones; [Is This Seat Taken?](https://store.steampowered.com/app/3035120/Is_This_Seat_Taken/) as proof simple constraint comedy sells in-band. We are not a word-block game and not seating.  
- **Why THIS fits 2026–27 prediction:** “One weird verb” inventiveness is what clip culture and Zukowski’s fun-first window reward ([GamesRadar](https://www.gamesradar.com/games/steams-new-golden-age-is-special-because-so-many-genres-are-popping-off-at-once-indie-expert-says-its-almost-like-the-player-base-was-drinking-and-their-inhibitions-lowered/)); pure category clarity beats mashup store pages.

---

## Game 3

- **Working title:** Quench  
- **One-sentence pitch:** Your only tools are a heat brush and a quench — cook stone, glaze, and crack until the level itself becomes the path.  
- **Player fantasy:** Blacksmith-sorcerer. Temperature is time; cooling is authorship; the terrain remembers every stroke.  
- **Dimension:** 2D grid thermal/material simulation (side or top-down).  
- **Why it’s easy to learn in 30 seconds:** Paint heat (hold LMB); quench (space). Soft rock darkens, flows, then freezes into a bridge. Fail = crack into the void. One verb pair.  
- **Core loop:**  
  - **Second:** Paint / quench; watch diffusion.  
  - **Minute:** Open an exit channel or fill a vessel to tolerance.  
  - **Session:** 10–20 puzzles introducing wind advection, dual materials, quench timing windows.  
  - **Meta:** Beauty score from glaze patterns; photo mode; “kiln diary” of past strokes as gallery; later sandbox plaque.  
- **Unique inventiveness (what’s outside the box):** Falling-sand chemistry usually sells *chaos toys* ([Sandboxels](https://store.steampowered.com/app/3664820/Sandboxels/), [Stardust Sandbox](https://store.steampowered.com/app/4348740/Stardust_Sandbox/)) or *factory logistics* ([Sandustry](https://store.steampowered.com/app/2764460/Sandustry/)). Quench scopes the same material fantasy into **authored puzzle pedagogy** — heat history *is* the level. Not Noita’s action-roguelite; not Particul’s idle spreadsheet with sand cosmetics ([Particul](https://store.steampowered.com/app/4273120/Particul/) ~$1.99, modest catalog economics per third-party estimates).  
- **How it can “shape around the player” WITHOUT requiring LLM worldgen:** Heat history is permanent material memory. Optional adaptive wind fields advect heat along your preferred stroke direction (tracked locally). Your past play literally becomes terrain bias.  
- **Systems list:**  
  - **MVP:** Grid diffusion, 3 materials, quench, 15 levels, false-color thermal readability, undo snapshot.  
  - **Later:** Sandbox kiln, Workshop stamps, beauty challenges, DLC material packs (obsidian, sugar-glass, frozen brine), replay scrubber.  
- **Art/audio direction (cheap but strong):** Thermal false-color that players learn like a legend; cooled forms render as ceramic/ink. Audio: kiln roar low-pass when painting; glass ping on quench. Cheap: tile shaders + particles, not character animation.  
- **Why it can live for years:** Material packs + sandbox + UGC stamps; “simple forever” in the World of Goo sense — physics toy with infinite authored challenges ([World of Goo](https://store.steampowered.com/app/22000/World_of_Goo/), [World of Goo 2](https://store.steampowered.com/app/3385670/World_of_Goo_2/)).  
- **Price, Steam tags, trailer hook (first 5 seconds):** **$7.99–$9.99**. Tags: Puzzle, Physics, Simulation, Pixel Graphics, Singleplayer, Atmospheric. Trailer: glowing brush stroke → quench → glowing ribbon freezes into a bridge a marble rolls across — smash cut to a failed quench shattering into the abyss.  
- **Solo Godot 8–16 week MVP milestone plan:**  
  - **W1–3:** Diffusion sim + materials + readability.  
  - **W4–6:** Quench, undo, 8 levels.  
  - **W7–9:** 15 levels, wind, demo.  
  - **W10–12:** Juice, Steam page, trailer.  
  - **W13–16:** Buffer content, Achievements, launch.  
- **Risks & mitigations:** Unreadable heat → mandatory legend + colorblind palettes. Scope toward Noita → **freeze feature list** at 3 materials until 15 levels sing. Feels like a tech demo → every level needs a one-line poetic goal.  
- **Closest comps:** Noita (material fantasy, scoped down); Sandboxels / Stardust (toy chemistry); World of Goo 2 (physics-as-puzzle language). Not an idle particle tycoon and not an action roguelite.  
- **Why THIS fits 2026–27 prediction:** Physics-as-authorship is the clip-native half of reactive toys ([physics-forward research](https://github.com/cmp07/Game-/pull/8)); material memory is generative feel without world-model APIs.

---

## Game 4

- **Working title:** Black Plinth  
- **One-sentence pitch:** An empty plinth over an infinite sea — place colorless blocks and watch a rewrite grammar turn emptiness into architecture that can drip, lean, and fail.  
- **Player fantasy:** Ex nihilo architect. You place the first stone; the void answers with placehood — and sometimes with collapse.  
- **Dimension:** 3D diorama (low-poly / CSG-friendly) OR 2.5D tile extrusion; Godot CSG/GridMap feasible. Prefer **3D diorama camera**, not open-world.  
- **Why it’s easy to learn in 30 seconds:** Click to place, right-click erase. First block sprouts a pier. No menus, no resources, no combat.  
- **Core loop:**  
  - **Second:** Place/erase; watch neighbor rewrite (arch, stair, buttress).  
  - **Minute:** Sculpt a silhouette; optional physics integrity check (cantilever sag).  
  - **Session:** Build a “postcard” under a weather pack; screenshot / seed share.  
  - **Meta:** Grammar packs, daily silhouette challenge (optional goals for players who hate pure toys), Workshop seeds.  
- **Unique inventiveness (what’s outside the box):** Townscaper / Tiny Glade proved reactive architecture chemistry sells ([Townscaper](https://store.steampowered.com/app/1291340/Townscaper/); Tiny Glade’s early >600k sales / Overwhelmingly Positive — [GameDiscoverCo](https://newsletter.gamediscover.co/p/how-tiny-glade-built-its-way-to-600k)). Black Plinth differentiates by being **void-first** and **physics-consequential** (structures can fail) rather than Hallmark-cozy meadow. Creation-from-nothing is the brand, not cottagecore.  
- **How it can “shape around the player” WITHOUT requiring LLM worldgen:** Configuration-sensitive rewrite grammar (same block → balcony vs buttress by neighborhood). Optional weather packs bias rules from last session’s density (sparse → cliffs; dense → compact towns). Seed strings for shareable worlds.  
- **Systems list:**  
  - **MVP:** One grammar, place/erase, 3 materials, orbit camera, screenshot, seed export, 5 “silhouette challenge” cards for players who want goals.  
  - **Later:** Grammar DLC, Workshop, physics stress viz, day/night, photo mode suite, collab ghost build (async, not MP-first).  
- **Art/audio direction (cheap but strong):** Black void + bone-white stone + one weather tint. Avoid cream/terracotta cozy defaults. Audio: distant tide + masonry clicks; collapse has a long reverb. Strong screenshot marketing > expensive animation.  
- **Why it can live for years:** Toy longevity (Tiny Glade / Townscaper pattern) + grammar packs + UGC. Honest store copy: it is a **toy** with optional challenges — Tiny Glade’s own page owns “no management, combat or goals” ([Steam](https://store.steampowered.com/app/2198150/Tiny_Glade/)).  
- **Price, Steam tags, trailer hook (first 5 seconds):** **$7.99–$12.99** (toy beauty tax; still near band). Tags: Casual, Building, Sandbox, Relaxing, Singleplayer, Design & Illustration. Trailer: absolute black → one click → a cantilever pier blooms over white sea → a second click too far → it calmly collapses.  
- **Solo Godot 8–16 week MVP milestone plan:**  
  - **W1–4:** Grid place/erase + grammar v1 + camera.  
  - **W5–7:** Materials, weather tint, screenshot/seed.  
  - **W8–10:** 5 challenges + soft integrity lite + demo.  
  - **W11–14:** Capsule beauty pass, trailer, Steam page.  
  - **W15–16:** Polish + launch prep.  
- **Risks & mitigations:** Beauty competition with Tiny Glade → void/physics brand, not meadow clone. Soft conversion → ship challenges day one. 3D scope creep → GridMap/CSG only; no open world. Cozy saturation ([Steam cozy supply wave reporting](https://howtomarketagame.com/2025/11/04/the-optimistic-case-that-indie-games-are-in-a-golden-age-right-now/)) → do not market as “cozy”; market as **void architecture**.  
- **Closest comps:** Tiny Glade, Townscaper, Summerhouse. We are not a management city builder and not Minecraft survival.  
- **Why THIS fits 2026–27 prediction:** Creation toys with reactive systems already proved unit volume; the next differentiator is **authorship + consequence** (collapse) while avoiding AI text-to-3D demoware ([world-model capital vs Steam SKU gap — Naavik / DeepMind Genie discourse synthesized in prior generative research](https://github.com/cmp07/Game-/pull/20)).

---

## Game 5

- **Working title:** Stillroom  
- **One-sentence pitch:** A sealed listening room where sound is scarce, every noise spends your remaining silence, and something in the walls answers only if you stay quiet long enough — or break the quiet on purpose.  
- **Player fantasy:** Acoustic predator/prey. You are a careful animal in a machine that hates noise — and loves the moment you crack.  
- **Dimension:** 1st-person 3D vignette (one room + antechamber) **or** tight 2.5D side view; prefer **one architectural volume** for scope.  
- **Why it’s easy to learn in 30 seconds:** WASD + hold Breath (shift) to damp footfall. UI: a single Silence meter. Footstep → meter drops → wall-thing stirs. No inventory essay.  
- **Core loop:**  
  - **Second:** Move/listen; meter ticks.  
  - **Minute:** Cross the room to fetch a spool / mute a pipe / close a vent without emptying Silence.  
  - **Session (20–50 min):** Escalating “shifts” with modifiers (wet floor, ticking heater, visitor knock); 3 endings.  
  - **Meta (light):** Challenge modifiers and ghost noise overlays — not a live-service.  
- **Unique inventiveness (what’s outside the box):** Tension vignettes work (Buckshot’s ~$2.99-band breakout; CloverPit’s debt/slot stakes — [Steam Buckshot](https://store.steampowered.com/app/2835570/Buckshot_Roulette/), [Escapist / CloverPit](https://www.escapistmagazine.com/news-cloverpit-launch-success-indie-hit/)). Stillroom rejects shotgun roulette *and* slot machines. The invented verb is **budgeted silence** — audio design *is* the game system. Clip-native: the moment someone sneezes / drops a tray.  
- **How it can “shape around the player” WITHOUT requiring LLM worldgen:** Director-lite: if you play aggressively loud, the room introduces earlier “answer” events; if you play hyper-stealth, it stretches scarcity and adds false-quiet traps. Classic Left 4 Dead–style pacing signals, offline ([adaptive design research lineage](https://github.com/cmp07/Game-/pull/15)). No generative dialogue.  
- **Systems list:**  
  - **MVP:** One room, Silence meter, 3 noise sources, 2 antagonist response states, 3 shifts, 2 endings, demo = shift 1.  
  - **Later:** Modifier cards, photo-mode “sound print,” short DLC room, accessibility (visual noise meter always on, screen-shake off).  
- **Art/audio direction (cheap but strong):** Peeling institutional green + brass dampers; diegetic UI. Audio budget is the product — hire/contract a sound designer even if art is kit. Foley > polygons.  
- **Why it’s a sharp short hit:** Intentionally finite vignette — reviews and clips in week one, then catalog long-tail. Expansion optional (second room DLC), not required for “complete.” Matches proven short-session discovery economics without becoming a multi-year sim.  
- **Price, Steam tags, trailer hook (first 5 seconds):** **$3.99–$6.99**. Tags: Horror, Atmospheric, Short, Singleplayer, First-Person, Psychological Horror. Trailer: black screen, a single swallowed footstep, meter blips, something in the wall knocks back *in rhythm* — cut to title.  
- **Solo Godot 8–16 week MVP milestone plan:**  
  - **W1–2:** Room blockout, meter, footfall noise model.  
  - **W3–5:** Antagonist FSM, shift 1–2, fail states.  
  - **W6–8:** Shift 3, endings, audio pass, demo.  
  - **W9–12:** Trailer, Steam page, influencer keys, polish.  
  - **W13–16:** Modifier mode + launch.  
- **Risks & mitigations:** “Walking sim” reviews → hard fail states and readable meter. Accessibility needs (deaf players) → full visual channel for every audio beat. Comparison to Buckshot → never show guns or gambling iconography. Scope into multi-room mansion → **one room**.  
- **Closest comps:** Buckshot Roulette / short horror vignettes for *session shape*; alien-isolation menace pacing as design kinship; **not** a gambling game, **not** a shotgun ritual, **not** CloverPit.  
- **Why THIS fits 2026–27 prediction:** Horror remains a Zukowski evergreen that tolerates rough edges ([How To Market A Game](https://howtomarketagame.com/2025/11/04/the-optimistic-case-that-indie-games-are-in-a-golden-age-right-now/)); a pure acoustic vignette rides the short-hit discovery lane while the other four own the forever reactive-toy wave.

---

## Sequencing recommendation (not a mashup)

| Build order | Product | Role |
|---|---|---|
| **First** | **Echo Lattice** or **Edgewright** | Fastest inventive pure puzzle; demoable; offline generative feel |
| **Second** | **Quench** | Physics authorship catalog depth |
| **Third** | **Black Plinth** | Beauty/UGC long-tail (higher art bar) |
| **Wildcard short** | **Stillroom** | Cash/reviews sprint between systems games — or first if you need the absolute smallest content mountain |

**Explicit non-goals for these five SKUs:** coin-pusher systems, slot/debt loops, particle idle prestige trees, deckbuilders, platform fighters, Minecraft-like survival craft, LLM NPCs as the loop.

**Prior Residue note:** Habit-conditioned physics-law chambers (Residue) remain a strong *sixth* alternate if you want physics-puzzle vignette energy overlapping Echo Lattice’s adaptive fantasy. Do not merge Residue + Echo + Quench into one store page.

---

## Sources (selected)

| Claim area | Sources |
|---|---|
| Indie Steam revenue / concentration 2025 | [GAMES.GG / Alinea](https://games.gg/news/indie-games-on-steam-make-4-billion/), [ShaneTheGamer stats](https://www.shanethegamer.com/research/indie-games-statistics/) |
| Multi-genre “golden age” / conjunction | [Zukowski HTMAG](https://howtomarketagame.com/2025/11/04/the-optimistic-case-that-indie-games-are-in-a-golden-age-right-now/), [GamesRadar](https://www.gamesradar.com/games/steams-new-golden-age-is-special-because-so-many-genres-are-popping-off-at-once-indie-expert-says-its-almost-like-the-player-base-was-drinking-and-their-inhibitions-lowered/), [Yahoo fun-first](https://tech.yahoo.com/gaming/articles/steam-expert-hails-pc-gaming-164447275.html) |
| AI disclosure / under-conversion | [Haro census](https://fragwyz.substack.com/p/three-years-of-ai-on-steam), [Yahoo summary](https://tech.yahoo.com/gaming/articles/steam-study-over-53-000-160050011.html), [GamesRadar AI share](https://www.gamesradar.com/games/half-of-all-games-released-on-steam-will-use-ai-by-2028-study-predicts-ai-lowers-the-barrier-not-just-to-make-a-game-but-to-make-several/) |
| Gambling-toy / synergy lane | [Balatro scale-up](https://www.deconstructoroffun.com/blog/2025/10/06/how-do-you-find-and-scale-an-indie-hit-like-balatro), [Nubby GamesRadar](https://www.gamesradar.com/games/roguelike/its-balatro-all-over-again-a-usd5-plinko-roguelike-from-a-new-solo-dev-is-one-of-the-top-rated-steam-releases-of-2025-and-10-000-reviews-agree-looking-like-a-pre-installed-windows-xp-game-is-a-plus/), [RACCOIN 100k/24h](https://www.polygon.com/raccoin-steam-sales/), [CloverPit](https://www.escapistmagazine.com/news-cloverpit-launch-success-indie-hit/) |
| Creation-toy proof | [Tiny Glade GameDiscoverCo](https://newsletter.gamediscover.co/p/how-tiny-glade-built-its-way-to-600k), [Tiny Glade Steam](https://store.steampowered.com/app/2198150/Tiny_Glade/), [Townscaper](https://store.steampowered.com/app/1291340/Townscaper/) |
| Non-LLM adaptation | [FBCA arXiv](https://ar5iv.labs.arxiv.org/html/2105.08484) |
| Sibling repo research (parallel agents) | PRs on trend map, inventiveness, generative reality, physics-forward, seeds — see [cmp07/Game- pulls](https://github.com/cmp07/Game-/pulls) |

---

## Decision gate

Confirm **one** product to scaffold in `game/` next:

1. Echo Lattice (recommended systems-first)  
2. Edgewright  
3. Quench  
4. Black Plinth  
5. Stillroom (short-hit first)  
6. Decline → pick a documented alternate (e.g. Residue) in a separate one-pager — still pure, still not a mashup.
