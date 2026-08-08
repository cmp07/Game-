# Physics-Forward Inventive Steam Games — Deep Research

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-)  
**Compiled:** August 2026  
**Lens:** Solo / tiny team · inventive first Steam ship · **pure physics categories only** (no genre mashups) · Godot 4 / Unity feasibility  
**Companion:** [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) (non-physics product sequence) · [`GAME_PLAN.md`](../GAME_PLAN.md)

---

## Executive verdict

Physics sells on Steam when the simulation is the **verb**, not the **trailer effect**. Hits in 2023–2026 cluster into two shapes:

1. **One tactile verb + social/clip pressure** (PEAK, R.E.P.O., Chained Together) — cheap, short, streamable; physics creates comedy and tension.
2. **One deep simulation + authored goals** (Teardown lineage, Besiege, Sandustry-class) — longer builds; physics creates problem-solving authorship.

Content-farm sandboxes that only dump tools into a map (“nuke village / ragdoll gore / fluid demo”) mostly stall at Mixed / low review counts. Pure idle with sand *cosmetics* (Particul) can clear Very Positive at $2 but caps as a modest catalog product unless the simulation actually changes decisions.

**Best inventive first ship for solo (physics lane):** a **single-verb tactile climber / swing / carry** game with authored levels and honest failure — or a **2D constrained builder** where collapse teaches. Avoid Teardown-scale voxels, Noita-scale sand factories, and MP-first horror as product #1.

---

## Hard rule (same as repo plan)

Each product is **one pure category**. Lessons below are extracted per title; they are **not** invitations to mash sand + ragdoll + horror + idle into one store page.

| Physics family | Ships as |
|---|---|
| Climbing / limb / stamina physics | Climbing game |
| Carry / grab / fragile-object physics | Physics retrieval / heist-toy |
| Structural build–fail physics | Building / siege / bridge game |
| Voxel / material destruction with goals | Destruction puzzle / heist |
| Falling-sand as *resource logistics* | Sand factory / automation |
| Falling-sand as *idle spectacle* | Idle / particle tycoon |
| Open ragdoll / toybox sandbox | Physics sandbox (Workshop-dependent) |

---

## Cool & unique vs gimmick

### Cool (players keep inventing)

| Signal | Why it works |
|---|---|
| Physics is **necessary** for the win condition | Teardown: destruction is the shortcut system, not debris VFX ([Gamasutra / Game Developer](https://www.gamedeveloper.com/design/combining-bombastic-heists-with-a-fully-destructible-voxel-world-in-i-teardown-i-)) |
| Failure is **readable** | Besiege: the snapped beam shows *where* you were wrong ([GameGeeker](https://gamegeeker.com/games/besiege-346010/review)) |
| Simple rules → rich compounds | Atomic primitives (blocks, joints, materials) compose solutions the designer never scripted ([Game Developer](https://www.gamedeveloper.com/design/why-i-love-physics-based-games)) |
| Consistent world model | Same materials behave the same everywhere; players build mental models |
| Fast iteration | Reset → try again in seconds (PEAK stamina falls; slingshot puzzles; campaign retries) |
| Spectacle is a **side effect** of a correct plan | Collapse, pile-up, swing save — earned, not canned |

### Gimmick (novelty dies in 30–90 minutes)

| Anti-signal | Typical symptom |
|---|---|
| Physics is only trailer juice | Pre-fractured props; same break every time |
| Tool checklist with no goal pressure | “Sandbox playground” with nuke / gore / Titanic and no authored challenge |
| Inconsistent colliders | Invisible supports, sticky glue, “physics” that ignores its own rules |
| Chaos without authorship | QA cannot reproduce an intended solution; players blame the game |
| Feature soup on day one | Ice + TNT + wind + magnets + softbody before one verb is mastered |
| Engine tech demo as product | Unreal Chaos / FluidNinja showcases with thin loop ([Steam: Unreal Physics](https://store.steampowered.com/app/2837320/Unreal_Physics/)) |

**Design test:** If you muted the particle effects and still had a interesting decision every 10 seconds, it’s a game. If the decision disappears, it’s a screensaver with rigidbodies.

---

## Named titles — lessons (no mashups)

### Particul — sand as *idle skin*, not sand as *system*

| | |
|---|---|
| **Steam** | [Particul](https://store.steampowered.com/app/4273120/Particul/) · AppID 4273120 |
| **Released** | 10 Feb 2026 · MILLION PIXELS · ~$1.99 |
| **Reception** | Very Positive (~80–81%, ~600–720 reviews) |
| **Sales (est.)** | Roughly mid–high five figures units depending on estimator; lifetime gross often cited ~$25k–$120k (third-party models disagree — treat as **modest** catalog hit, not breakout) |

**What it is:** Click-mine particles → pile → sell → extractors → lab → marketplace → ascend. Falling sand is the **visual dopamine layer**; the loop is classic incremental.

**Lessons**

- Hypnotic particle piles sell screenshots and second-monitor sessions.
- Review split: “satisfying sand + solid pacing” vs “content padded with zeros / gambling wheels / broken ascend.”
- Physics tag alone does not create inventiveness — players invent *numbers*, not *structures*.
- Solo-feasible in weeks; ceiling limited unless simulation choices (flow, clogging, purity) matter to the economy.

**Pure category if shipping adjacent:** Idle / particle tycoon — already Game 3 in [`GAME_PLAN.md`](../GAME_PLAN.md).

---

### Sandustry — sand as *logistics & chemistry*

| | |
|---|---|
| **Steam** | [Sandustry](https://store.steampowered.com/app/2764460/Sandustry/) · Demo [3490390](https://store.steampowered.com/app/3490390/Sandustry_Demo/) |
| **Status** | Demo Jan 2025 (viral Trending Free); EA planned **13 Aug 2026** (Hooded Horse + Lantto) |
| **Reception (demo)** | Extremely positive early coverage; ~96% reported in early demo window ([Notebookcheck](https://www.notebookcheck.net/Mining-game-with-realistic-sand-physics-tops-Steam-s-Trending-Free-charts.955961.0.html)) |

**What it is:** Every pixel is a resource. Falling-sand CA + conveyors, pipes, drones, reactions (ice→water→steam→rain). Factory goals *because* matter misbehaves.

**Lessons**

- Invert Particul: simulation creates **problems** (sand everywhere, melts, floods) that automation solves.
- Demo-first discovery works when the physics toy is instantly visible.
- Scope is **not** a first solo ship: world gen, element reactions, factory UI, mod hooks, publisher localization stack.
- Press comps (Factorio × Terraria / Noita labyrinth) show the market frame — also the content mountain.

**Pure category:** Sand-factory / pixel automation. Watch EA; do not chase full Sandustry as product #1.

---

### Besiege — failure as tutor

| | |
|---|---|
| **Steam** | [Besiege](https://store.steampowered.com/app/346010/Besiege/) |
| **Era** | EA 2015 → 1.0 2020; still relevant through 2026 via Workshop longevity |
| **Reception** | Persistently Overwhelmingly / Very Positive; large Workshop long-tail |

**What it is:** Modular medieval machine builder; materials bend/snap; campaign objectives without a single intended machine.

**Lessons**

- Material honesty > part count: wood vs metal vs ballast tradeoffs teach engineering.
- Campaign + sandbox + Workshop is the longevity triangle for builders.
- “Crash is the tutorial” is the uniqueness moat — still hard for clones to steal ([GameGeeker](https://gamegeeker.com/games/besiege-346010/review)).
- Solo-feasible as a **2D constrained builder** with fewer parts; matching Besiege’s 70+ blocks + logic + MP is multi-year.

**Pure category:** Structural building / siege engineering.

---

### Teardown — destruction as gameplay author

| | |
|---|---|
| **Steam** | [Teardown](https://store.steampowered.com/app/1167630/Teardown/) |
| **Released** | EA Oct 2020 · 1.0 Apr 2022 · ~$29.99 |
| **Reception** | Overwhelmingly Positive (~95–96%, 100k+ reviews) |
| **Sales** | ~1.1M by Aug 2022; ~2.5M players after 2023 consoles ([Wikipedia](https://en.wikipedia.org/wiki/Teardown_(video_game))); Steam estimates later climb higher |

**What it is:** Fully destructible voxel volumes; plan phase → alarm timer heist. Custom engine (voxel volumes, CPU collision, GPU ray-march).

**Lessons (Dennis Gustafsson)**

- Destruction must be **useful and necessary**, not an effect ([80.lv](https://80.lv/articles/teardown-developer-breaks-down-multiplayer-and-voxel-destruction-tech)).
- Mesh fracture is a trap; voxels (or another volume representation) simplify break-up.
- Unlimited freedom breaks level design — Teardown solved with **open map + time pressure after alarm**, not stingy bomb counts ([Game Developer](https://www.gamedeveloper.com/design/combining-bombastic-heists-with-a-fully-destructible-voxel-world-in-i-teardown-i-)).
- Custom tech can create uniqueness, but it is a **career** bet, not a 12-week ship.
- Modding / Workshop extends life after campaign fatigue.

**Pure category:** Destruction-puzzle / voxel heist. Solo Godot/Unity clone of Teardown’s fidelity = poor bet; a **tiny** destructible-goal game with one material model can still learn the *design* lesson.

---

### PEAK — one meter, many friendships

| | |
|---|---|
| **Steam** | [PEAK](https://store.steampowered.com/app/3527290/PEAK/) (Landfall × Aggro Crab / “Landcrab”) |
| **Released** | ~16–17 Jun 2025 · ~$7.99 |
| **Reception** | Very / Overwhelmingly Positive (~93% in early windows) |
| **Sales** | **1M+ copies in ~6 days**; ~100k peak concurrent ([IGN](https://www.ign.com/articles/co-op-climbing-game-peak-takes-steam-by-storm-reaches-summit-of-top-sellers-chart)) |

**What it is:** Climb a daily/proc mountain through biomes; universal climb + **one stamina bar** (hunger, poison, injury carve it); rope/pitons as scarce tools; best as 1–4 co-op comedy.

**Lessons**

- Jam-like clarity: one verb, one meter, short runs (~1–2h) ([Eurogamer](https://www.eurogamer.net/budget-steam-smash-hit-peak-is-my-new-gaming-obsession)).
- Physics + **status pressure** creates stories without needing softbody liquids.
- Budget price + charm + stream clips >> systemic depth for breakout.
- Technical debt shows under viral load (AMD crash “grass,” lobby/voice issues) — ship small, patch fast.
- Solo mode works for some; marketing and retention lean co-op — netcode is the tax.

**Pure category:** Co-op / solo climbing survival-toy. Design lesson transferable to **solo climber** (see ADGAC below) without copying PEAK’s full MP stack.

---

### R.E.P.O. — physics as the punchline under horror pressure

| | |
|---|---|
| **Steam** | [R.E.P.O.](https://store.steampowered.com/app/3241660/REPO/) · Semiwork |
| **Released** | 26 Feb 2025 (EA) · ~$9.99 |
| **Reception** | Overwhelmingly Positive (~96%, **300k–400k+** reviews over 2025–26) |
| **Sales** | Reported among 2025’s top Steam sellers; public figures cite **10M+** units in mid-2025 coverage ([ValoSettings / SGF mentions](https://www.valosettings.com/news/repo-is-the-best-selling-steam-game-of-2025/)) |

**What it is:** Lethal Company–shaped extract loop; **grabber / carry physics** on valuables and monsters; proximity voice; quota pressure.

**Lessons**

- One awkward physical verb (carry fragile loot) × social fear × clips = mega hit ([Polygon](https://www.polygon.com/impressions/554398/repo-streamer-social-media-clips-game/), [GameRant](https://gamerant.com/repo-steam-hit-horror-physics-entertaining-indie/)).
- Physics uniqueness is the **grab/throw feel**, not a new engine paper.
- Host-authoritative physics feels laggy on clients — community mods exist to fake local feel ([RevivalSync](https://github.com/Vladtheosis/RevivalSync)); MP physics is a swamp for first ships.
- Formula familiarity helps discovery; pure “physics sandbox” without extract stakes would not have sold like this.

**Pure category:** Co-op physics-horror extract. **Avoid as first solo product** (netcode + content cadence). Steal only the lesson: *awkward carry under a timer*.

---

## Adjacent hits & flops (2023–2026 window + enduring comps)

### Hits / strong proofs

| Title | Window | Physics hook | Outcome signal | Takeaway |
|---|---|---|---|---|
| **Chained Together** | Jun 2024 | Shared chain wraps platforms | Very Positive, 50k–60k+ reviews; multi-million unit estimates at ~$5 | One constraint + co-op rage comedy ([Polygon](https://www.polygon.com/24185778/chained-together-co-op-platformer-steam/)) |
| **A Difficult Game About Climbing** | Mar 2024 | Dual-arm climb stamina | Very Positive ~87%; ~150k+ units est. at ~$10 | Solo PEAK DNA without MP ([Steam](https://store.steampowered.com/app/2497920/A_Difficult_Game_About_Climbing/)) |
| **People Playground** | 2019→still huge 2024–26 | Detailed ragdoll + systems | ~98%, 300k+ reviews; multi-million units est. | Toybox wins if systems are deep + Workshop |
| **Mind Over Magnet** | Nov 2024 | Magnet puzzle platformer | Very Positive (~89%, ~1.3k reviews) | Focused magnet *puzzles* > magnet sandbox ([Steam](https://store.steampowered.com/app/2685900/Mind_Over_Magnet/)) |
| **Noita** (pre-window, still the sand north star) | 2019/2021 | Pixel CA world | Enduring cult + design talks | Sand is a full custom engine job at scale ([80.lv](https://80.lv/articles/noita-a-game-based-on-falling-sand-simulation)) |

### Soft / flop / trap patterns

| Pattern | Examples | Why they fail inventiveness |
|---|---|---|
| **Asset-flip sandbox** | *Water Box*, thin “physics playground” ports | Mixed / tiny review counts; feature list ≠ loop ([Water Box](https://store.steampowered.com/app/3939240/Water_Box_Sandbox_Playground/)) |
| **Engine showcase** | *Unreal Physics* | ~74% / few hundred reviews — tech reel, not authorship ([Club 250](https://club.steam250.com/app/2837320)) |
| **Chaos with no rules** | *Ludicrum*-class “no limits” pages | Near-zero discovery without identity or goals |
| **Idle with fake depth** | Particul’s harsher reviews | Extra zeros, forced gambling, broken prestige — physics can’t save economy design |
| **DLC / side content under big brand** | Some Teardown add-ons ~50–60% | Brand ≠ automatic quality |
| **Clone of last viral co-op** | Post–Lethal / post–PEAK floods | Without a sharper physical verb, drown in tags |

---

## Solo feasibility matrix (Godot 4 vs Unity)

Scores: **S** shippable solo MVP · **M** medium (months, careful scope) · **H** hard / career · **X** avoid for first ship

| Format | Godot 4 | Unity | Notes |
|---|---|---|---|
| 2D rigidbody puzzles / coin-adjacent arcade | **S** | **S** | Built-in 2D physics both engines |
| Dual-hand / stamina climber (ADGAC-like) | **S–M** | **S–M** | Custom character controller; no need for softbody |
| 2D Verlet rope swing / grapple levels | **S–M** | **S–M** | Addons exist (Godot Verlet rope / CRope2D; Unity Burst jobs) |
| Magnet attract/repel puzzle rooms | **S** | **S** | Forces on rigidbodies; authored chambers |
| 2D structural builder (Poly Bridge / mini-Besiege) | **M** | **M** | Stress visualization is the craft |
| Falling-sand idle (Particul-like) | **S** | **S** | Image/byte grid + UI economy; C#/GDExtension for speed |
| Falling-sand factory (Sandustry-like) | **H** | **H** | Chunks, dirty rects, reactions, logistics UI |
| Active ragdoll platformer (Human: Fall Flat class) | **M–H** | **M** | Unity has more tutorials/PID samples; Godot possible but less cookbook |
| Open ragdoll gore sandbox (People Playground class) | **H** | **H** | Content + systems + Workshop expectations |
| Softbody cloth / jelly as *core* | **H** | **M–H** | Easy as VFX; hard as reliable gameplay |
| Liquid SPH / large fluid | **H–X** | **H** | Prefer CA water (Noita-style) or faked volumes |
| Full voxel destruction (Teardown class) | **X** | **X** | Custom engine territory |
| Online physics co-op (REPO/PEAK class) | **X** first | **X** first | Ship offline first; add MP only after a hit |

**Stack recommendation for this repo:** stay on **Godot 4** for desktop Steam (already in plan) unless choosing active-ragdoll 3D, where Unity’s PhysX + tutorial density shortens the road.

---

## Ranked pure physics formats — inventive first ship

Ranked for **solo inventive first Steam product** (not max theoretical revenue). Assumes $3–$15, Windows `.exe`, demoable in 5 minutes, **one** physics fantasy.

| Rank | Pure format | Why | Ship speed | Ceiling | Risk | Verdict |
|---|---|---|---|---|---|---|
| **1** | **Tactile climber (solo)** — dual grip / stamina / fall | Proven by ADGAC; PEAK proved demand without requiring MP day one; inventiveness = level + feel | Fast–medium | High if clips | Feel tuning | **Build this if physics is the lane** |
| **2** | **Constraint chain / rope swing campaign** — one rope model, authored vertical levels | Chained Together / rope climbers show the verb; solo = shorter maps + ghost times | Fast–medium | Medium–high | Rope collision jank | Strong alternate #1 |
| **3** | **Fragile-carry puzzle** — offline “extract” rooms, awkward grab, no monsters required | REPO’s physical joke without horror MP | Medium | Medium | Grabber feel | Distinct; market quieter solo |
| **4** | **2D structural builder** — stress, snap, campaign goals | Besiege lesson in miniature; Workshop later | Medium | Medium–high long-tail | Content + UX | Best “inventive engineering” lane |
| **5** | **Magnet chamber puzzles** | Mind Over Magnet proof; clear marketing | Fast | Modest–medium | Puzzle volume | Safe inventive craft |
| **6** | **Idle / particle tycoon** | Particul-proven; fastest code | Fastest | Modest | Economy padding backlash | Catalog product (aligns Game 3) |
| **7** | **Tiny destruction-goal levels** — one breakable material, timed routes | Teardown *design* without voxels | Medium | Medium | Compared to Teardown | Only if unique material hook |
| **8** | **Sand CA toy with goals** — reactions as puzzles, small maps | Noita/Sandustry taste, tiny scope | Medium–hard | Medium | Perf + content | Prototype carefully |
| **9** | **Active ragdoll traversal** | Human: Fall Flat evergreen | Hard | High with co-op later | Controller hell | Not first unless already skilled |
| **10** | **Open physics sandbox** | People Playground / content farms | Hard | Binary (hit or invisible) | Workshop tax / clones | Avoid first |
| **11** | **Softbody / liquid spectacle core** | Trailer candy | Hard | Low median | Feels like demo | Avoid as spine |
| **12** | **Online physics co-op horror / climb** | REPO / PEAK lottery | Hard + liveops | Extreme | Netcode, servers | Sequel / Game 4+, never first |

### Scoring rubric (relative 1–10)

| Format | Inventive clarity | Solo ship | Demoability | Market proof | Score |
|---|---|---|---|---|---|
| Solo tactile climber | 9 | 8 | 9 | 9 | **8.8** |
| Rope / chain constraint campaign | 8 | 8 | 9 | 8 | **8.3** |
| Fragile-carry puzzle (offline) | 8 | 7 | 8 | 7 | **7.5** |
| 2D structural builder | 9 | 6 | 7 | 8 | **7.5** |
| Magnet chambers | 7 | 9 | 8 | 6 | **7.5** |
| Idle particle tycoon | 4 | 10 | 8 | 6 | **7.0** |
| Tiny destruction goals | 7 | 6 | 7 | 7 | **6.8** |
| Small sand-CA puzzles | 8 | 5 | 7 | 7 | **6.5** |
| Active ragdoll traversal | 7 | 4 | 7 | 8 | **6.0** |
| Open sandbox | 5 | 3 | 6 | 7 | **5.0** |
| Softbody/liquid-as-core | 6 | 3 | 5 | 3 | **4.0** |
| Online physics co-op | 7 | 2 | 8 | 10 | **3.5** first-ship |

---

## Recommended physics product sequence (pure only)

If the studio chooses a **physics-forward track** instead of (or after) the tension-vignette track in `GAME_PLAN.md`:

| Slot | Pure category | Explicit non-goals |
|---|---|---|
| **Physics Game 1** | Solo tactile climber **or** rope/chain campaign | No horror extract, no sand factory, no Workshop sandbox |
| **Physics Game 2** | 2D structural builder **or** magnet chambers | No MP |
| **Physics Game 3** | Idle particle tycoon **or** fragile-carry puzzle pack | Do not merge with Game 1 systems |

Do **not** combine PEAK stamina + REPO loot + Sandustry belts + Besiege blocks into one pitch.

---

## Practical “inventiveness” checklist for a first ship

1. **One physical verb** on the store capsule (climb / swing / snap / carry / attract).
2. **Authored challenge** within 60 seconds of boot (not empty sandbox).
3. **Readable failure** (why you fell / snapped / dropped).
4. **Same rules everywhere** — no special-case glue for the tutorial.
5. **Clip length 8–20s** natural moments (save, collapse, near-miss).
6. **Demo** that is the game’s best 20 minutes.
7. **Price** $4.99–$12.99 for skill toys; $1.99–$4.99 for idlers.
8. **Offline first** — add co-op only after reviews prove the verb.

---

## Sources

### Named comps
- Particul — https://store.steampowered.com/app/4273120/Particul/ · review/sales estimators: [Raijin](https://raijin.gg/app/4273120/Particul), [SteamData.AI](https://steamdata.ai/en-US/game/4273120/particul)
- Sandustry — https://store.steampowered.com/app/2764460/Sandustry/ · demo news: [Notebookcheck](https://www.notebookcheck.net/Mining-game-with-realistic-sand-physics-tops-Steam-s-Trending-Free-charts.955961.0.html) · EA date: [Games Press](https://www.gamespress.com/en-US/sandustry-release-date-announcement) · itch: https://lanttogames.itch.io/sandustry
- Besiege — https://store.steampowered.com/app/346010/Besiege/ · design longevity: [GameGeeker](https://gamegeeker.com/games/besiege-346010/review)
- Teardown — https://store.steampowered.com/app/1167630/Teardown/ · [Wikipedia](https://en.wikipedia.org/wiki/Teardown_(video_game)) · [Game Developer heist design](https://www.gamedeveloper.com/design/combining-bombastic-heists-with-a-fully-destructible-voxel-world-in-i-teardown-i-) · [Game Developer voxels](https://www.gamedeveloper.com/design/how-beautiful-voxels-laid-the-way-for-i-teardown-s-i-heist-y-framework) · [80.lv multiplayer/tech](https://80.lv/articles/teardown-developer-breaks-down-multiplayer-and-voxel-destruction-tech)
- PEAK — https://store.steampowered.com/app/3527290/PEAK/ · [IGN sales](https://www.ign.com/articles/co-op-climbing-game-peak-takes-steam-by-storm-reaches-summit-of-top-sellers-chart) · [Eurogamer](https://www.eurogamer.net/budget-steam-smash-hit-peak-is-my-new-gaming-obsession) · [Game Informer](https://www.gameinformer.com/review/peak/a-brilliant-co-op-climbing-adventure)
- R.E.P.O. — https://store.steampowered.com/app/3241660/REPO/ · [Polygon](https://www.polygon.com/impressions/554398/repo-streamer-social-media-clips-game/) · [GameRant](https://gamerant.com/repo-steam-hit-horror-physics-entertaining-indie/) · [Steambase reviews](https://steambase.io/games/repo/reviews)

### Adjacent
- A Difficult Game About Climbing — https://store.steampowered.com/app/2497920/A_Difficult_Game_About_Climbing/
- Chained Together — https://store.steampowered.com/app/2567870/Chained_Together · [Polygon](https://www.polygon.com/24185778/chained-together-co-op-platformer-steam/)
- Mind Over Magnet — https://store.steampowered.com/app/2685900/Mind_Over_Magnet/
- People Playground — https://store.steampowered.com/app/1118200/People_Playground/
- Unreal Physics — https://store.steampowered.com/app/2837320/Unreal_Physics/
- Water Box — https://store.steampowered.com/app/3939240/Water_Box_Sandbox_Playground/
- Ludicrum — https://store.steampowered.com/app/4104910/Ludicrum/

### Design / tech
- “Why I love physics-based games” — https://www.gamedeveloper.com/design/why-i-love-physics-based-games
- Noita sand system — https://80.lv/articles/noita-a-game-based-on-falling-sand-simulation
- Godot sand sample — https://github.com/MathExpert/GodotSand
- Godot Verlet rope — https://github.com/Tshmofen/verlet-rope-4 · https://github.com/cuberact/godot-cuberact-library
- Unity rope / Verlet — https://toqoz.fyi/game-rope.html
- Human: Fall Flat design interviews — [TheGamer](https://www.thegamer.com/human-fall-flat-interview-tomas-sakalauskas/) · [RPS](https://www.rockpapershotgun.com/human-fall-flat-interview)

### Estimators caveat
Steam unit/revenue figures from Raijin, SteamData.AI, Steamograph, SteamScanner, etc. are **models**, not Valve disclosures. Use them for order-of-magnitude ranking only.

---

## Relation to existing repo plan

| Existing plan (`GAME_PLAN.md`) | This research |
|---|---|
| Game 1 tension vignette | Still the **fastest non-physics** ship |
| Game 2 coin-machine | Arcade physics adjacent; keep pure |
| Game 3 idle particle | Matches Particul lesson — **optics ≠ inventiveness** |
| **New optional track** | If prioritizing “physics feels cool,” swap Game 1 to **solo tactile climber** (Rank 1 above) instead of vignette — still one pure category |

**Decision gate:** Confirm whether first production is (A) tension vignette, (B) coin-machine, (C) idle particle, or (D) **solo tactile climber / rope campaign** from this ranking — then write one GDD only.
