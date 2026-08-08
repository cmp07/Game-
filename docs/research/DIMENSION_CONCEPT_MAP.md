# Dimension & Presentation Concept Map

**Repo:** [cmp07/game-](https://github.com/cmp07/game-)  
**Compiled:** August 2026  
**Lens:** Inventive concepts mapped by **spatial dimension / presentation**, not by genre mash.  
**Hard rule:** **One pure category per product** — no mashup pitches. Lessons are extracted per presentation family; they are not invitations to stack strip + diorama + desktop pet into one store page.

Companions: [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) · [`../GAME_PLAN.md`](../GAME_PLAN.md).  
Related research tracks (sibling PRs / may land separately): physics-forward games, outside-the-box indies, simple-deep inventiveness, Steam indie trend map 2025–mid-2026.

---

## 0. How to read this map

| Axis | Meaning |
|---|---|
| **Dimension** | How the playable space is framed: 1 axis, 2D plane, diorama/2.5D, full 3D, or OS/desktop as stage |
| **Presentation** | What the player *sees as the world* (strip, paper, UI, first-person table, overlay pet…) |
| **Hit / flop** | Commercial or cultural outcome — not “good/bad design.” Third-party sales figures are **estimates** unless developer-disclosed |
| **Solo cost** | Rough full-time-equivalent for a Godot-capable solo or tiny team to ship a **readable MVP** in the $0.99–$10 band (not AAA remasters) |
| **Easy to learn** | One verb or one readable rule that demos in &lt;60s |
| **White space 2026–27** | Under-supplied *pure* concepts relative to Steam attention — not “add three genres” |

**Inventiveness here** = a distinctive, teachable presentation constraint that the whole product is built around. Pixel art alone is not inventiveness. Dimension alone is not inventiveness. The win is when **dimension *is* the mechanic**.

---

## 1. Executive matrix (quick scan)

| Bucket | Hit pattern | Flop pattern | Solo MVP cost | Easy-learn exemplar | 2026–27 white space |
|---|---|---|---|---|---|
| **1D / strip / timeline / one-axis** | One input + ruthless timing; Workshop longevity | “1D gimmick” F2P with no score fantasy | **2–10 weeks** | [Super Hexagon](https://store.steampowered.com/app/221640/Super_Hexagon/), [A Dance of Fire and Ice](https://store.steampowered.com/app/977950/A_Dance_of_Fire_and_Ice/) | Paid one-axis *stakes* toy (not rhythm clone); time-as-axis puzzle vignette |
| **2D side / top-down / paper / UI-as-world** | One weird verb *or* UI *is* the fiction | Generic pixel platformer / cozy top-down | **1–6 months** (UI fiction can be longer) | [Papers, Please](https://store.steampowered.com/app/239030/Papers_Please/), [Unpacking](https://store.steampowered.com/app/1135690/Unpacking/), [ANIMAL WELL](https://store.steampowered.com/app/813230/ANIMAL_WELL/) | Short UI-job vignette; paper *as physics/material*, not skin; top-down without combat |
| **2.5D / diorama** | Toy clarity + “a lot from little effort” | HD-2D cosplay without systems; empty cozy builder | **3–18 months** (feel is expensive) | [Tiny Glade](https://store.steampowered.com/app/2198150/Tiny_Glade/), [Townscaper](https://store.steampowered.com/app/1291340/Townscaper/), [Bad North](https://store.steampowered.com/app/690830/Bad_North/) | Constraint diorama (stakes, not sandbox); miniature *failure* toys under $10 |
| **3D FP/TP · physics toys · walking · climbing** | One tactile verb + clip failure; fair impulse price | Asset-flip ascent; aimless walk; open sandbox day-1 | **1–4 months** (toy) · **6–24+ months** (authored world) | [Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/), [PEAK](https://store.steampowered.com/app/3527290/PEAK/), [Getting Over It](https://store.steampowered.com/app/240720/Getting_Over_It_with_Bennett_Foddy/) | Solo tactile climber / carry toy (see physics research); original tension vignette |
| **Hybrid: desktop overlay · browser/OS UI in `.exe`** | Desktop *is* the stage; OS fiction with a job | Wallpaper pet with no loop; Geocities cosplay with no cases | **2–12 weeks** (overlay) · **4–18 months** (OS fiction) | [Desktop Goose](https://samperson.itch.io/desktop-goose), [Hypnospace Outlaw](https://store.steampowered.com/app/844590/Hypnospace_Outlaw/), [Progressbar95](https://store.steampowered.com/app/1304550/Progressbar95/) | Paid desktop *game* (rules + win/lose), not pet cosmetics; modern-OS fiction with short cases |

**Repo-aligned takeaway:** For a first $0.99–$10 Steam ship, the highest *presentation leverage* sits in **UI-as-world vignettes**, **one-axis timing toys**, and **single-verb 3D tactile toys** — not in content-mountain 2D platformers or open diorama sandboxes.

---

## 2. Bucket A — 1D / strip / timeline / one-axis

### 2.1 What counts

Play is constrained to **one primary axis** or a **single path** the player advances along:

- Left/right only on a line ([Life Goals](https://store.steampowered.com/app/838360/Life_Goals/), coming-soon [Time, Line](https://store.steampowered.com/app/4900660/Time_Line/))
- Radial “one ring” / one-axis reaction ([Super Hexagon](https://store.steampowered.com/app/221640/Super_Hexagon/), [OUTL1NED](https://store.steampowered.com/app/3284530/OUTL1NED/))
- Auto-forward strip / runner ([BIT.TRIP RUNNER](https://store.steampowered.com/app/63710/BITTRIP_RUNNER/), Canabalt lineage)
- **Timeline as the track** — time advances with position or with a single beat input ([A Dance of Fire and Ice](https://store.steampowered.com/app/977950/A_Dance_of_Fire_and_Ice/), [Rhythm Doctor](https://store.steampowered.com/app/774181/Rhythm_Doctor/))
- Draw-a-path toys where the “level” is a polyline ([Line Rider](https://en.wikipedia.org/wiki/Line_Rider))

### 2.2 Hits

| Title | Presentation | Why it worked | Evidence |
|---|---|---|---|
| **Super Hexagon** | One-axis spin/strafe around a center | Instant readability; score attack; chip soundtrack identity | Long-tail Steam classic; Terry Cavanagh solo design language |
| **A Dance of Fire and Ice** | Planets on a winding beat-line | One button; ears &gt; eyes; Workshop | 2019 Steam release; large custom-level culture ([Steam](https://store.steampowered.com/app/977950/A_Dance_of_Fire_and_Ice/), [ADOFAI wiki](https://rhythmgames.wsx.moe/wiki/A_Dance_of_Fire_and_Ice)) |
| **Rhythm Doctor** | Beat on the 7th — hospital UI strip | Extreme subtractive control; years of EA → 1.0 Dec 2025 | [Wikipedia](https://en.wikipedia.org/wiki/Rhythm_Doctor); IGF history from 2012 Flash demo |
| **BIT.TRIP RUNNER** | Auto-runner strip + rhythm | Defined a runner subgenre; IGF Excellence in Visual Art | [Choice Provisions](https://choiceprovisions.com/game/bit-trip-runner/) |
| **Line Rider** | Drawn strip + physics sled | “Toy not game”; YouTube composition culture | Viral 2006+ ([Wikipedia](https://en.wikipedia.org/wiki/Line_Rider)) |
| **Flappy Bird** (mobile, instructive) | One-axis flap through gaps | One interaction tuned until dense | Bennett Foddy framing via [The Guardian, 2014](https://www.theguardian.com/technology/2014/feb/10/flappy-bird-is-dead-but-brilliant-mechanics-made-it-fly) |

**Pattern:** Hits sell **mastery density on a thin control surface**, not the novelty of “literally 1D graphics.”

### 2.3 Flops / weak outcomes

| Pattern | Example / signal | Lesson |
|---|---|---|
| Constraint without fantasy | [OUTL1NED](https://store.steampowered.com/app/3284530/OUTL1NED/) — F2P 1D shooter, ~17 reviews (Positive) as of research window | “Y/Z are overrated” is a tweet, not a product fantasy |
| Joke 1D without score/Workshop | [Life Goals](https://store.steampowered.com/app/838360/Life_Goals/) — conceptual gag, thin retention | Conceptual purity ≠ Steam discovery |
| Runner clones after Canabalt/Temple Run | Endless samey strip | Strip needs *rhythm, stakes, or authorship* |
| Hard-only rhythm without calibration | Strict timing + bad audio sync | Rhythm Doctor / ADOFAI invest heavily in calibration UX |

### 2.4 Solo cost

| Scope | FTE estimate | Notes |
|---|---|---|
| Arcade score-attack MVP | **2–6 weeks** | One scene, one enemy grammar, leaderboard |
| Authored campaign (30–60 patterns) | **2–4 months** | Content is the mountain, not the engine |
| Rhythm + Workshop | **4–12 months** | Editor + sync + moderation = product |
| Draw-path physics toy | **3–8 weeks** | Line Rider–class; sharing is external (video) unless you build UGC |

Godot 2D + simple physics is enough. Art can be geometric.

### 2.5 Easy to learn

- **Super Hexagon** — rotate left/right; don’t hit walls  
- **ADOFAI** — press on every beat  
- **Rhythm Doctor** — hit on beat 7  
- **Flappy / one-button runners** — one press = one jump  

### 2.6 White space 2026–27

| Opportunity (pure) | Why open | Avoid |
|---|---|---|
| **Paid one-axis *stakes* vignette** | Tension toys sell ($3 band); few couple *literal* one-axis control with escalating stakes | Cloning Buckshot’s shotgun fiction |
| **Time-moves-when-you-move line puzzle** | [Time, Line](https://store.steampowered.com/app/4900660/Time_Line/) shows appetite; room for sharper original premise | Braid cosplay |
| **Strip *job* fantasy** (inspector / sorter / cutter on a belt) | UI + strip merge; Papers Please DNA without full OS | Idle conveyor tycoon mash |
| **Authorable polyline toy with Steam UGC** | Line Rider never fully owned Steam Workshop | Feature-complete DAW-in-a-game |

**Solo-first pick in this bucket:** a **$2.99–$5.99 one-axis score/stakes toy** with ruthless feel and a demoable trailer — not a 12-hour narrative line-walk.

---

## 3. Bucket B — 2D: side, top-down, paper, UI-as-world

### 3.1 Sub-lanes (keep pure)

| Sub-lane | World is… | Inventive when… |
|---|---|---|
| **Side-view** | A silhouette / platform plane | Movement *or* secrets redefine the genre ([ANIMAL WELL](https://store.steampowered.com/app/813230/ANIMAL_WELL/), Celeste lineage) |
| **Top-down** | A map / room grid | Systems or jobs dominate combat ([Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) subtracts aiming; [Unpacking](https://store.steampowered.com/app/1135690/Unpacking/) is placement) |
| **Paper** | Cut/fold/tear fiction | Material properties are verbs ([Tearaway](https://en.wikipedia.org/wiki/Tearaway_(video_game)), Paper Mario *as craft*, not just art style) |
| **UI-as-world** | Forms, windows, databases, desks | The interface *is* the place you inhabit ([Papers, Please](https://store.steampowered.com/app/239030/Papers_Please/), [Her Story](https://store.steampowered.com/app/368370/Her_Story/), Inscryption Act 1 table) |

### 3.2 Hits

| Title | Lane | Hook | Outcome signals |
|---|---|---|---|
| **Papers, Please** | UI-as-world | Border desk = moral machine | Defining indie sim; still the reference UI-job |
| **Her Story** | UI-as-world | Police interview database search | Awards darling; Steam estimates ~400k+ units (third-party) |
| **Unpacking** | Top-down / domestic UI | Place objects; story via inventory | ~655k Steam units / ~$8.5M gross est. ([Raijin](https://raijin.gg/app/1135690/Unpacking), mid-2026) |
| **ANIMAL WELL** | Side-view puzzle-box | Dense secrets, CRT well, almost no combat | Solo-coded; &gt;300k Steam early est.; Overwhelmingly Positive ([Game Developer](https://www.gamedeveloper.com/design/why-animal-well-s-home-brewed-engine-was-key-to-its-success)) |
| **Vampire Survivors** | Top-down subtraction | Move only; weapons auto-fire | Genre-defining ~$3 EA breakout |
| **Balatro** | Card UI as world | Poker hands as scoring machine | 2024 mega-hit (store UI *is* the table) |
| **Inscryption** (Act 1 as presentation lesson) | Tabletop UI / cabin | Cards on wood = horror desk | 1M+ copies by early 2022 ([Birdor case study](https://blog.birdor.com/inscryption-horror-card-product-case-study/)) — *study presentation, do not mash card + escape + ARG as first ship* |
| **Tearaway** | Paper world | Vita as paper box; fingers poke through | Critically acclaimed craft presentation ([Polygon making-of](https://www.polygon.com/features/2013/11/18/5056096/making-tearaway/)) |

### 3.3 Flops / harsh medians

| Pattern | Evidence | Lesson |
|---|---|---|
| **Generic 2D platformer** | Saturated; even 97% review games can barely break even ([Windswept coverage](https://vgtimes.com/gaming-news/140478-the-harsh-reality-of-indie-development-dev-of-a-platformer-with-97-positive-steam-reviews-barely-managed-to-break-even.html); [Game Oracle saturation map](https://www.game-oracle.com/blog/2d-platformers-on-steam)) | Feel + content mountain without a one-sentence hook dies quietly |
| **Safe puzzle-platformer** | GMTK launch postmortem: “bland / unimaginative” reviews despite craft ([GMTK Substack](https://gmtk.substack.com/p/what-its-like-to-launch-a-game-on)) | Polish ≠ inventiveness |
| **Rage-physics platformer without brand** | [tilt frog](https://www.gamesmarket.global/numbers-facts-truths-an-indies-analysis-of-tilt-frog/) — streamers liked it; broader market didn’t | Clip bait ≠ purchase without clarity |
| **Pixel-art flood** | Steam pixel releases accelerated post-2020 ([Game Oracle](https://www.game-oracle.com/blog/deep-dive-2D-pixel-art-part-1)) | Art style is not a differentiator |
| **Paper *skin* only** | Paper Mario clones / papercraft shaders without material verbs | Aesthetic ≠ paper mechanic |

### 3.4 Solo cost

| Sub-lane | MVP FTE | Cost drivers |
|---|---|---|
| Side-view precision platformer | **4–12 months** | Feel tuning + level volume |
| Top-down one-verb (survivor-like / placement) | **6–16 weeks** | Content / balance after the verb works |
| UI-as-world vignette (one desk, one rule set) | **6–14 weeks** | Writing + UI state machines; art can be intentional ugliness |
| Full OS / website fiction | **6–18 months** | Content density (Hypnospace-scale) |
| Paper-material sim | **4–12 months** | Shader + interaction R&D |

### 3.5 Easy to learn

- **Papers, Please** — compare documents to rules; stamp  
- **Unpacking** — drag objects into rooms  
- **Vampire Survivors** — WASD; survive  
- **Her Story** — type words; watch clips  
- **Super Meat Boy / Celeste-class** — run, jump (easy enter; hard master)

### 3.6 White space 2026–27

| Opportunity (pure) | Fit for $0.99–$10 | Notes |
|---|---|---|
| **Short UI-job tension vignette** | **Excellent** | Aligns with repo Game 1 lane; original premise, not shotgun clone |
| **Domestic / office placement toy with stakes** | Strong | Unpacking proved placement; tension/time pressure is less mined |
| **Side-view *without* combat metroid** | Medium–hard | Animal Well bar is high; only if secrets system is the whole product |
| **Paper as *cutting / tearing economy*** | Medium | Desktop Steam + mouse is a better fit than Vita gimmicks |
| **Top-down auto-action after Survivor flood** | Weak unless radical subtraction | Saturated; needs a new subtraction, not a new skin |

**Solo-first pick in this bucket:** **UI-as-world vignette** (one desk, one escalating rule sheet) — matches [`GAME_PLAN.md`](../GAME_PLAN.md) Game 1 recommendation.

---

## 4. Bucket C — 2.5D / diorama

### 4.1 What counts

- Sprites or miniatures in a **tilted stage** with depth (HD-2D lineage)  
- **Tabletop diorama** builders / toys ([Tiny Glade](https://store.steampowered.com/app/2198150/Tiny_Glade/), [Townscaper](https://store.steampowered.com/app/1291340/Townscaper/))  
- Isometric / orthographic **miniature tactics** ([Bad North](https://store.steampowered.com/app/690830/Bad_North/), [Mini Metro](https://store.steampowered.com/app/287980/Mini_Metro/) as diagram-diorama)

HD-2D itself ([Octopath Traveler](https://lumnix.fr/en/article/hd-2d-octopath-traveler-origine-esthetique-team-asano) shipped 2.5M+ units) is a **studio art brand**, not a solo template.

### 4.2 Hits

| Title | Form | Why it worked | Evidence |
|---|---|---|---|
| **Tiny Glade** | Gridless diorama builder | “A lot from little effort”; no wrong answers; tactile materials | **616k copies in &lt;1 month** disclosed to GameDiscoverCo; ~1.37M wishlists; $14.99 ([GameDiscoverCo](https://newsletter.gamediscover.co/p/how-tiny-glade-built-its-way-to-600k)) |
| **Townscaper** | Instant town toy | One click → architecture grammar | ~380k Steam copies reported in 2021 interview ([MCV](https://mcvuk.com/business-news/when-we-made-townscaper/)) |
| **Octopath / HD-2D line** | Sprite diorama RPG | Differentiated nostalgia from generic pixel | 2.5M+ shipped ([VGChartz](https://www.vgchartz.com/article/447613/octopath-traveler-ships-25-million-units/)) |
| **Bad North** | Island diorama tactics | Readable miniature battles; procedural islands | Stålberg → Townscaper lineage |

**Pattern:** Diorama hits sell **immediate beauty + authorship**, or **readable tactics on a toy stage**. Goals are optional if the *feel* of making is elite.

### 4.3 Flops / traps

| Trap | Why it fails |
|---|---|
| “Townscaper but with quests” without chemistry | Adds goals that fight the toy; dilutes both |
| Cosplay HD-2D lighting on thin RPG | Players compare you to Square Enix production |
| Empty cozy builder at $15 without wishlist muscle | Tiny Glade spent **years** on feel + Next Fest velocity |
| Isometric pixel strategy without a new verb | Strategy content mountain; crowded tags |

### 4.4 Solo cost

| Scope | FTE | Reality check |
|---|---|---|
| Small constraint diorama *game* (win/lose on a stage) | **3–6 months** | Feasible if systems &gt; beauty |
| Townscaper-class toy | **6–24 months** | Procedural grammar + feel is the product |
| HD-2D RPG | **Multi-year / team** | Wrong band for this repo’s first ships |

Tiny Glade: two people, ~**2 years**, then massive wishlist — not a “fast first Steam” template even though the *loop* looks simple.

### 4.5 Easy to learn

- **Townscaper / Tiny Glade** — click / draw; beauty appears  
- **Mini Metro** — connect stations  
- **Bad North** — place squads on islands  

### 4.6 White space 2026–27

| Opportunity (pure) | Notes |
|---|---|
| **Diorama with honest failure under $10** | Cozy builders cluster at $15; a *tense miniature* (flood, siege, quarantine on a table) is less flooded than pure cozy |
| **One-material diorama** (only cardboard / only ice / only sand piles) | Material constraint = inventiveness without genre mash |
| **Diagram toys** (transit, wiring, blood-flow schematic) | Mini Metro proved abstract dioramas sell; new schemas still open |
| **Avoid:** “another castle doodle” | Post–Tiny Glade supply will spike |

**Solo-first pick:** only if you already have **procedural beauty chops**. Otherwise prefer Bucket A/B/E for speed; treat Tiny Glade as a *career* diorama, not Game 1.

---

## 5. Bucket D — 3D: first/third person, physics toys, walking, climbing

### 5.1 Sub-lanes (pure)

| Sub-lane | Verb | Recent signal |
|---|---|---|
| **Tension vignette (FP table / room)** | Sit, decide, survive | [Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) — **8M+ sales** reported; console ports into 2026 ([TechRaptor](https://techraptor.net/gaming/news/buckshot-roulette-sales-8m)) |
| **Climbing / ascent physics** | Climb, fall, recover | [PEAK](https://store.steampowered.com/app/3527290/PEAK/) — jam → **2M+ sales**, &lt;$200k spend ([Game Developer](https://www.gamedeveloper.com/production/how-co-op-climbing-hit-peak-achieved-2-million-sales-for-less-than-200-000-)); [Getting Over It](https://store.steampowered.com/app/240720/Getting_Over_It_with_Bennett_Foddy/) long-tail millions |
| **Physics toy / carry / ragdoll chaos** | Grab, throw, drop | R.E.P.O. / friendslop wave (see trend map & physics research) |
| **Walking / exploration narrative** | Walk, look, listen | [Firewatch](https://store.steampowered.com/app/383870/Firewatch/) ~1.3M Steam units est.; **walking-sim tag now supply-heavy** (2025–26 Steam tag weather) |
| **Perspective puzzle FP** | Photograph / reshape space | [Viewfinder](https://store.steampowered.com/app/1382070/Viewfinder/) — inventive camera verb; ~200–370k unit est. band |

### 5.2 Hits

| Title | Lane | Lesson |
|---|---|---|
| **Buckshot Roulette** | FP vignette | Short session, clip stakes, ~$3, expandable MP later |
| **PEAK** | Co-op climb | One stamina bar fantasy; impulse price; ship the jam |
| **Getting Over It** | Solo climb toy | One tool; authored mountain; rage = marketing |
| **Content Warning** | FP film toy | Social clip loop (Landfall) — *separate product category* from solo vignette |
| **Viewfinder** | FP photo-world | Presentation *is* the puzzle verb |
| **Firewatch** | Walking mystery | Radio relationship &gt; parkour; higher price band historically |

### 5.3 Flops / cautionary hits

| Case | What happened | Lesson |
|---|---|---|
| **Only Up!** | Twitch viral ascent; asset/NFT controversies; delisted by solo dev under stress ([Kotaku](https://kotaku.com/only-up-steam-twitch-removed-indiesolodev-platformer-1850817370)) | Virality without craft/IP hygiene burns the maker; clone flood followed |
| **Only Up clones** | Mostly Negative / low trust pages | Namejacking ≠ product |
| **Open physics sandbox day-1** | Trailer juice, Mixed reviews | Physics as trailer juice without authored goals (see physics-forward research track) |
| **Aimless walking sim (2025–26 supply)** | Tag saturated vs attention | Need a job or mystery engine, not “vibes hike” |
| **Teardown-scale voxels as first ship** | Content + tech mountain | Wrong for solo first product |

### 5.4 Solo cost

| Scope | FTE | Notes |
|---|---|---|
| FP tension vignette (one room/table) | **4–12 weeks** | Matches recommended Game 1 |
| Solo tactile climber (authored route) | **8–16 weeks** | PEAK was multi-studio jam; solo needs tighter mountain |
| Viewfinder-class perspective campaign | **9–18 months** | Puzzle authorship heavy |
| Firewatch-class narrative hike | **12–36 months** | Writing + world art; usually &gt;$10 ambition |
| Co-op physics (R.E.P.O. class) | **Not first solo** | Netcode + moderation + live expectation |

### 5.5 Easy to learn

- **Buckshot** — load, point, shoot / pass  
- **Getting Over It** — mouse swings hammer  
- **PEAK** — climb; manage stamina afflictions  
- **Viewfinder** — place photo; walk into it  

### 5.6 White space 2026–27

| Opportunity (pure) | Priority for this repo |
|---|---|
| **Original-stakes FP vignette** | **Highest** — format proven; premise must be original |
| **Solo climber / swing / carry with authored fails** | High — physics research ranks this inventive-first |
| **FP “tool that remaps space”** (not Viewfinder’s camera) | Medium — invent a *new* tool verb |
| **Walking sim** | Low — saturated supply |
| **Ascent parkour asset world** | Avoid — Only Up aftertaste |

---

## 6. Bucket E — Hybrid presentation (desktop toy overlay · browser/OS UI inside desktop `.exe`)

> **Note:** “Hybrid” here means **presentation stage** (your real desktop, or a fake OS), **not** genre mashups. A desktop pet that is also a deckbuilder+idle+horror is out of scope.

### 6.1 Sub-lanes

| Sub-lane | Stage | Product shape |
|---|---|---|
| **Desktop overlay toy** | Real Windows desktop | Pet, pest, companion ([Desktop Goose](https://samperson.itch.io/desktop-goose), [Desktop Pet Project](https://store.steampowered.com/app/2618940/Desktop_Pet_Project/), [MateEngine](https://store.steampowered.com/app/3625270/MateEngine/), [NeeNee Deskpals](https://store.steampowered.com/app/3863740/NeeNee_Deskpals/) 2026) |
| **Fake OS / browser fiction** | Simulated desktop *inside* the `.exe` | [Hypnospace Outlaw](https://store.steampowered.com/app/844590/Hypnospace_Outlaw/), [Progressbar95](https://store.steampowered.com/app/1304550/Progressbar95/), Pony Island / Inscryption meta-desktop moments |
| **Wallpaper / companion platform** | Always-on ambient | Wallpaper Engine ecosystem; VRM mates |

### 6.2 Hits

| Title | Lane | Why it worked | Evidence |
|---|---|---|---|
| **Desktop Goose** | Overlay pest | Instant comedy; Untitled Goose adjacency; mod hooks | 250k+ downloads in days of launch ([Hypertext](https://htxt.co.za/2020/02/desktop-goose-is-spreading-untitled-chaos-around-the-world/); [Verge](https://www.theverge.com/2020/1/30/21115103/untitled-goose-game-desktop-app-windows-memes-gifs)); built in ~couple days |
| **Hypnospace Outlaw** | Fake 90s web/OS | Enforcement *job* + dense diegetic websites | Cult classic; content-authored internet |
| **Progressbar95** | OS nostalgia toy | GUI chrome *is* the minigame material | Overwhelmingly Positive; ~$5; modest but durable long-tail (est. tens of k units depending on tracker) |
| **MateEngine / desk pet wave 2025–26** | 3D VRM overlay | Always-on anime companion demand | Growing Steam category; Workshop/custom models |

### 6.3 Flops / weak medians

| Pattern | Lesson |
|---|---|
| Pet with feed meter only | Competing with free Shimeji / browser pets |
| Geocities museum without cases | Hypnospace works because you have a **job** |
| Antivirus-scare / fake malware gags | Trust & platform risk; review bombs |
| “Desktop pet + RPG + gacha” | Mashup; store confusion; live-ops cost |
| Overlay that fights productivity without comedy | Uninstall in 10 minutes |

### 6.4 Solo cost

| Scope | FTE | Notes |
|---|---|---|
| Chaos overlay (Goose-class) | **3–14 days** prototype; **2–6 weeks** shippable | Win32 transparency / click-through quirks are the hard part |
| Care pet + Workshop | **2–4 months** | Content + import pipeline |
| Fake OS with 8–12 “sites/cases” | **4–10 months** | Writing + UI states dominate |
| Full Hypnospace-scale | **12–24+ months** | Small team content mountain |

### 6.5 Easy to learn

- **Desktop Goose** — install; goose appears; honk  
- **Progressbar95** — catch catchers; upgrade PC  
- **Hypnospace** — open mail; browse; report violations  

### 6.6 White space 2026–27

| Opportunity (pure) | Why |
|---|---|
| **Paid desktop *game* with win/lose** | Pets are crowded; a desktop *ruleset* (smuggle files, hide from boss, sort windows under timer) is rarer |
| **Modern OS fiction (2010s–2020s), not only Y2K** | 90s nostalgia is mined; smartphone/OS notification horror/office is less done as a full product |
| **Streamer-friendly overlay with Workshop** | MateEngine/NeeNee show demand; *gameplay* overlay still thin |
| **Short fake-intranet mystery ($3–$7)** | Her Story + Hypnospace intersection without 20-hour content |

**Solo-first pick:** either a **2–6 week desktop chaos/rule toy** (marketing via clips) **or** a **contained fake-OS vignette** — not a forever pet live service.

---

## 7. Cross-bucket lessons (still no mashups)

1. **Dimension is a marketing sentence.** “You only move on a line” / “the website is the dungeon” / “your desktop is the arena” must be visible in a 15s trailer.  
2. **Easy-to-learn ≠ easy-to-ship.** Tiny Glade and Animal Well are easy to *start* and brutal to *author*.  
3. **Saturation is presentation-specific.** Side-view pixel platformers and cozy dioramas are supply-heavy; **UI jobs**, **one-axis mastery**, and **single-verb tactile 3D** still clear when the premise is sharp.  
4. **Friendslop ≠ solo template.** PEAK/Content Warning prove social physics; your first product can still be **solo vignette / solo climber** without shipping netcode.  
5. **Price band fit:** Toys and vignettes live at **$2–$8**; diorama beauty toys often want **$12–$15**; narrative walks want **$15–$25**. Stay honest to band.

---

## 8. Ranking for *this* repo’s sequential ships

Mapped onto existing plan — presentation lens only:

| Priority | Presentation bucket | Pure product shape | Why |
|---|---|---|---|
| **1** | 3D FP vignette *or* 2D UI-as-world | Tension / horror **desk or table** | Fastest demoable stakes; Buckshot-format proof; aligns Game 1 |
| **2** | Hybrid overlay *or* one-axis strip | Desktop rule-toy **or** one-axis score/stakes | Fast ship; clip-native; distinct store page from Game 1 |
| **3** | 2D top-down systems / particle | Idle / particle tycoon (Particul lane) | Fastest code path among catalog fillers |
| **4** | 3D tactile climb/carry (solo) | Physics-forward climber | After physics research; optional track |
| **Later** | 2.5D diorama beauty toy | Tiny Glade–class | Wishlist + feel years |
| **Avoid early** | Generic 2D platformer, walking sim, open 3D sandbox, pet+RPG mash | — | Median death / scope / mashup |

---

## 9. Concept seeds by bucket (pure — one each)

Not a backlog commitment; prompts for GDD only after lane lock.

### 1D / strip
1. **Deadline Line** — every step right advances the clock; obstacles open only on certain seconds.  
2. **Belt Inspector** — stamp items on a conveyor; one axis of motion; rules escalate.  
3. **Fuse Walk** — walk a fuse cord; left/right only; cut branches before burn reaches you.

### 2D side / top-down / paper / UI
4. **Night Shift Forms** — one counter window; contradictory memos; 12-minute shifts.  
5. **Parcel Room** — top-down place packages by cryptic labels (Unpacking tension cousin — **placement game**, not narrative hike).  
6. **Cutwork** — paper doll world where scissors are the only verb (tear = travel).

### 2.5D / diorama
7. **Tide Table** — build a harbor diorama; tide eats bad foundations (failure-forward toy).  
8. **Quarantine Board** — isometric miniature town; place checkpoints; infection is the timer.

### 3D FP/TP / physics / climb
9. **Original stakes table** — FP seated contest with invented ritual (structure ≠ shotgun).  
10. **Chimney Kit** — solo hammer/rope climber up an industrial flue; authored falls.  
11. **Glass Carry** — third-person fragile object delivery through a short building (one verb).

### Hybrid desktop / OS-in-exe
12. **Boss Key** — desktop overlay: hide the game as spreadsheets when a timer “manager” appears.  
13. **Intranet Duty** — fake 2014 company portal; three cases; viruses as puzzles.  
14. **Cursor Pest** — paid Goose-like with score attack modes (not infinite pet care).

---

## 10. Sources

### Market & sales (primary / trade)

- Buckshot Roulette sales & ports: [TechRaptor](https://techraptor.net/gaming/news/buckshot-roulette-sales-8m), [Statista lifetime units](https://www.statista.com/statistics/1546866/buckshot-roulette-global-unit-sales/), [Steam](https://store.steampowered.com/app/2835570/Buckshot_Roulette/)  
- PEAK production & sales: [Game Developer, June 2025](https://www.gamedeveloper.com/production/how-co-op-climbing-hit-peak-achieved-2-million-sales-for-less-than-200-000-), [Eurogamer](https://www.eurogamer.net/charming-co-op-climbing-game-peak-takes-steam-by-storm-selling-one-million-copies-in-six-days-and-mounting-the-top-sellers-page)  
- Tiny Glade: [GameDiscoverCo newsletter](https://newsletter.gamediscover.co/p/how-tiny-glade-built-its-way-to-600k), [Game World Observer](https://gameworldobserver.com/2024/10/10/tiny-glade-500k-players-bonkers-pounce-light), [Steam](https://store.steampowered.com/app/2198150/Tiny_Glade/)  
- Townscaper: [MCV / Stålberg interview](https://mcvuk.com/business-news/when-we-made-townscaper/), [Steam](https://store.steampowered.com/app/1291340/Townscaper/)  
- Octopath / HD-2D: [Lumnix](https://lumnix.fr/en/article/hd-2d-octopath-traveler-origine-esthetique-team-asano), [VGChartz 2.5M](https://www.vgchartz.com/article/447613/octopath-traveler-ships-25-million-units/)  
- Animal Well: [Game Developer](https://www.gamedeveloper.com/design/why-animal-well-s-home-brewed-engine-was-key-to-its-success), [Time Extension](https://www.timeextension.com/features/best-of-2024-the-making-of-animal-well-2024s-most-unique-metroidvania), [Steam](https://store.steampowered.com/app/813230/ANIMAL_WELL/)  
- Unpacking / Her Story / Firewatch / Viewfinder estimates: [Raijin Unpacking](https://raijin.gg/app/1135690/Unpacking), [SteamData Her Story](https://steamdata.ai/en-US/game/368370/her-story), [SteamData Firewatch](https://steamdata.ai/en-US/game/383870/firewatch), [SteamData Viewfinder](https://steamdata.ai/en-US/game/1382070/viewfinder)  
- Only Up delist & clones: [Kotaku](https://kotaku.com/only-up-steam-twitch-removed-indiesolodev-platformer-1850817370), [Engadget](https://www.engadget.com/viral-indie-game-only-up-delisted-from-steam-171652546.html), [Automaton](https://automaton-media.com/en/news/20230927-21892/)  
- 2D platformer / pixel saturation: [Game Oracle — platformers](https://www.game-oracle.com/blog/2d-platformers-on-steam), [Game Oracle — pixel art](https://www.game-oracle.com/blog/deep-dive-2D-pixel-art-part-1), [GMTK launch postmortem](https://gmtk.substack.com/p/what-its-like-to-launch-a-game-on), [tilt frog postmortem](https://www.gamesmarket.global/numbers-facts-truths-an-indies-analysis-of-tilt-frog/)  
- Steam macro 2025–26: Alinea / Games-Stats tallies summarized in sibling Steam indie trend-map research (~20k releases / ~300 titles &gt;$1M in 2025; harsh medians)

### Design & presentation references

- Line Rider: [Wikipedia](https://en.wikipedia.org/wiki/Line_Rider)  
- Flappy / one-interaction density: [The Guardian / Foddy](https://www.theguardian.com/technology/2014/feb/10/flappy-bird-is-dead-but-brilliant-mechanics-made-it-fly)  
- Rhythm Doctor / ADOFAI: [Wikipedia Rhythm Doctor](https://en.wikipedia.org/wiki/Rhythm_Doctor), [Steam ADOFAI](https://store.steampowered.com/app/977950/A_Dance_of_Fire_and_Ice/), [Steam Rhythm Doctor](https://store.steampowered.com/app/774181/Rhythm_Doctor/)  
- Papers, Please: [Steam](https://store.steampowered.com/app/239030/Papers_Please/)  
- Hypnospace Outlaw: [Steam](https://store.steampowered.com/app/844590/Hypnospace_Outlaw/), [official site](https://www.hypnospace.net/index.html), [HG101](https://www.hardcoregaming101.net/hypnospace-outlaw/)  
- Progressbar95: [Steam](https://store.steampowered.com/app/1304550/Progressbar95/)  
- Desktop Goose: [itch.io](https://samperson.itch.io/desktop-goose), [Verge](https://www.theverge.com/2020/1/30/21115103/untitled-goose-game-desktop-app-windows-memes-gifs)  
- Desktop pets 2023–26: [Desktop Pet Project](https://store.steampowered.com/app/2618940/Desktop_Pet_Project/), [MateEngine](https://store.steampowered.com/app/3625270/MateEngine/), [NeeNee Deskpals](https://store.steampowered.com/app/3863740/NeeNee_Deskpals/)  
- Tearaway paper craft: [Polygon](https://www.polygon.com/features/2013/11/18/5056096/making-tearaway/), [Wikipedia](https://en.wikipedia.org/wiki/Tearaway_(video_game))  
- Inscryption presentation: [Wikipedia](https://en.wikipedia.org/wiki/Inscryption), [Birdor](https://blog.birdor.com/inscryption-horror-card-product-case-study/)  
- 1D experiments: [OUTL1NED](https://store.steampowered.com/app/3284530/OUTL1NED/), [Life Goals](https://store.steampowered.com/app/838360/Life_Goals/), [Time, Line](https://store.steampowered.com/app/4900660/Time_Line/)  
- Thomas Was Alone timeline: [Game Developer](https://www.gamedeveloper.com/business/-i-thomas-was-alone-i-from-24-hour-prototype-to-fully-fledged-game)  
- Celeste jam → full: [Nintendo Life](https://www.nintendolife.com/news/2018/01/feature_conquering_the_indie_mountain_with_celeste_creator_matt_makes_games)

### Internal companions

- [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) · [`../GAME_PLAN.md`](../GAME_PLAN.md)  
- Sibling research tracks (separate PRs): physics-forward games · outside-the-box indies · simple-deep inventiveness · Steam indie trend map 2025–mid-2026

---

## 11. Decision note

This map **does not** replace the Game 1 decision gate in [`GAME_PLAN.md`](../GAME_PLAN.md). It answers: *given inventiveness-by-presentation, which dimensions are fertile for a solo $0.99–$10 Steam exe?*

**Default alignment:** ship a **pure tension vignette** whose presentation is either **FP table/room** or **UI desk** — then a **separate** strip/overlay/coin/idle product later. Do not combine them.
