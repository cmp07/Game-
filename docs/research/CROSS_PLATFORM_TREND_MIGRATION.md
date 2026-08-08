# Cross-Platform Trend Migration — What Hits Steam Next

**Research window:** 2024–mid-2026 (compiled Aug 2026)  
**Lens:** Solo/small team, paid Windows `.exe` on Steam at **$0.99–$15**, not live-ops F2P.  
**Companion docs:** [`docs/GAME_PLAN.md`](../GAME_PLAN.md) · [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## Verdict (read this first)

**Most “trending outside Steam” content does *not* migrate as a 1:1 port.** Roblox/UEFN/WeChat often act as *clone sinks* after Steam hits, not as feeders. What *does* become a paid Steam success is usually:

1. A **simple, clip-legible loop** proven on a free/frictionless surface (itch, browser, mobile hypercasual, Discord Activity, web toy),  
2. **Reframed** with stakes, run structure, items/meta, or social embarrassment,  
3. Sold as a **short-session premium product** ($3–$12) that works **without** a platform social graph.

For this repo’s sequence: **itch/TikTok tension toys → Game 1**, **arcade/mobile dopamine machines → Game 2**, **web sand/particle toys + idle wrap → Game 3**. Treat Roblox/UEFN/CN mini-games as **demand sensors**, not source code to copy.

---

## Migration scoreboard

Relative fit for a solo/small Steam paid ship (1–10). “Outbound” = Steam hit gets cloned *onto* that platform.

| Source surface | Inbound → paid Steam | Outbound Steam→platform | Best migrateable idea type | Score |
|---|---|---|---|---|
| **itch.io / jam / browser prototype** | Excellent (proven pipeline) | N/A | Tension vignette, systemic jam hook, narrative puzzle | **9.5** |
| **TikTok / Shorts / Reels “toys”** | Strong (discovery engine) | Medium | Clip-length stakes, gambling-*feel*, reaction content | **9.0** |
| **Web sandbox toys** (Sandspiel, Powder Toy lineage) | Strong *if wrapped* | Weak | Particle/sand physics + goal/progression | **8.0** |
| **Mobile hypercasual / hybrid-casual** | Medium–strong *when flipped* | Strong reverse clones | One-verb loops + social/depth reframe | **7.5** |
| **Discord Activities** | Medium (companion / party) | Growing | Party rounds, sketch/guess, short lobby games | **6.5** |
| **Chinese mini-games** (WeChat / Douyin) | Selective | Very strong clone echo | Tidy/sort, merge→systems, idle loops *with* PC depth | **6.0** |
| **Fortnite UEFN** | Weak as ports; medium as signals | Strong clone sink | Prop-hunt/party fantasy, progression tycoon *ideas* | **5.0** |
| **Roblox experiences** | Weak as ports | Very strong clone sink | Social party / tidy / paint-hide *demand*, not assets | **4.0** |

---

## The real pipeline (direction matters)

```text
FREE / FRICTIONLESS SURFACES          PREMIUM STEAM .EXE
itch jam · browser demo · web toy  →  paid vignette / systemic game
mobile one-verb loop               →  flipped co-op or deep single-player
Discord Activity / party mini      →  Jackbox-like or companion + Steam SKU
TikTok clip toy                    →  $3–$10 stakes product

STEAM VIRAL HIT                    →  Roblox / UEFN / WeChat clones (days–weeks)
```

Kotaku’s reporting on *Meccha Chameleon* and *Librarian* makes the outbound path explicit: paid Steam breakouts are cloned onto Roblox/Fortnite within days; free clones can outpace the original’s concurrent players because friction and price collapse to zero ([Kotaku](https://kotaku.com/more-people-are-playing-meccha-chameleon-knock-offs-than-the-original-hit-steam-game-as-the-roblox-clone-machine-goes-into-overdrive-2000715371)). Newzoo-adjacent analysis argues the old “Roblox kids grow up into your midcore PC catalog” gateway theory is weak — players often stay in high-social UGC ecosystems ([Deconstructor of Fun on Newzoo](https://www.deconstructoroffun.com/blog/newzoos-inflection-point-report-three-things-worth-arguing-about)).

**Implication:** Do not wait for a Roblox chart-topper to “graduate” to Steam. Wait for a **mechanic fantasy** that is over-indexed on free platforms, then ship the **premium, original** version on Steam first (or validate on itch/browser, then Steam).

---

## Platform briefs

### 1) itch.io / game jams / browser prototypes — **best inbound path**

**What is trending as a *method*:** Ship a free browser or itch build → prove the hook → expand into a Steam paid product.

| Case | Path | Outcome |
|---|---|---|
| [Buckshot Roulette](https://store.steampowered.com/app/2835570/Buckshot_Roulette/) | itch (Dec 2023) → Steam (Apr 2024) | ~1M in ~2 weeks post-Steam; later reported multi-million ([Polygon](https://www.polygon.com/24148258/buckshot-roulette-steam-launch-multiplayer-mike-klubnika-success/); [GamesRadar](https://www.gamesradar.com/games/horror/he-made-a-viral-horror-game-in-2-months-it-sold-6-million-copies-and-now-he-can-make-whatever-he-wants-for-the-rest-of-his-life-my-final-theory-is-that-gambling-is-very-fun/); [Wikipedia](https://en.wikipedia.org/wiki/Buckshot_Roulette)) |
| [The King is Watching](https://store.steampowered.com/app/2753900/The_King_is_Watching/) | Ludum Dare jam → itch/browser → tinyBuild Steam | 500k–600k+ sales ([GamesIndustry.biz](https://www.gamesindustry.biz/how-steam-changes-and-a-china-strategy-helped-tinybuilds-the-king-is-watching-hit-500k-sales); [GameMaker / tinyBuild](https://gamemaker.io/en/blog/the-king-is-watching-tinybuild)) |
| *The Roottrees are Dead* | Free itch browser jam → remade Steam ~$20 | >$1M revenue case study ([How To Market A Game](https://howtomarketagame.com/2025/04/28/how-an-itch-io-game-became-a-million-dollar-hit-the-roottrees-are-dead/)) |

**What migrates successfully**

- One readable rule (“progress only where the king looks”; “Russian roulette with a shotgun + items”).
- Browser/itch removes install friction for press and playtesters.
- Steam version adds modes, polish, input, achievements — not a naked reupload.

**What fails**

- Jam novelty with no second-order systems.
- Ports that stay “web toy” length at Steam prices without replay/meta.

**Steam-ready ideas to watch on itch now:** short horror rituals, one-screen systemic toys, cozy tidy prototypes, particle sandboxes with a win condition.

---

### 2) TikTok / Reels / Shorts “toys” — **discovery → paid vignette**

**Pattern:** Games that generate 15–60s reaction clips (tension spike, funny fail, jackpot) get free marketing. Short-form is not the genre — it is the **distribution filter**.

| Signal | Role |
|---|---|
| Buckshot Roulette | itch→Steam + Twitch/TikTok amplification ([Polygon](https://www.polygon.com/24148258/buckshot-roulette-steam-launch-multiplayer-mike-klubnika-success/)) |
| [CloverPit](https://store.steampowered.com/app/3314790/CloverPit/) | Slot/debt roguelite; demo→organic creators; 750k+ copies in ~2 weeks; Reels outperformed TikTok/Shorts for the publisher’s own clips ([games.gg](https://games.gg/news/clover-pit-sells-750k-copies/); [GamesMarket](https://www.gamesmarket.global/750000-copies-sold-how-cloverpit-completely-beat-future-friends-best-case-predictions-6bf7f63be1546a7ae7f40eef3ef99379/)) |

**Migrates well to paid Steam**

- Gambling-*feel* without real-money gambling (Balatro / Buckshot / CloverPit family).
- Single-room stakes, readable UI at phone resolution when clipped.
- Demo that is already “the whole fantasy” in five minutes.

**Migrates poorly**

- Pure meme skins with no second layer.
- Live-service chase that needs constant content drops to stay clip-worthy.

**Repo fit:** Direct support for **Game 1 (tension / horror vignette)** in [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md).

---

### 3) Web sandbox toys (Sandspiel, Powder Toy, falling-sand lineage) — **wrap the toy**

**Source DNA**

- [Sandspiel](https://maxbittker.itch.io/sandspiel) / [Making Sandspiel](https://maxbittker.github.io/making-sandspiel/) — free web falling-sand creative toy.
- [The Powder Toy](https://store.steampowered.com/app/1148350/The_Powder_Toy/) — classic sandbox; Steam release June 2024 as **free** FOSS distribution ([Wikipedia](https://en.wikipedia.org/wiki/The_Powder_Toy)).
- [Noita](https://noitagame.com/) — paid proof that sand/pixel sim can carry a full commercial fantasy when every pixel serves combat/exploration.

**Paid Steam wraps that work**

| Wrap | Example | Why players pay |
|---|---|---|
| Action / roguelite over sim | Noita | Goals, death, builds |
| Idle / tycoon over particles | [Particul](https://store.steampowered.com/app/4273120/Particul/) (~$1.99) | Number-go-up + automate + ascend on top of satisfying fall physics |
| Puzzle / destruction with campaign | Besiege-adjacent physics toys | Levels + sandbox |

**Does not migrate as paid alone:** “paint sand forever” with no progression, win state, or collection fantasy — Powder Toy stays free for a reason.

**Repo fit:** Direct support for **Game 3 (idle / particle tycoon)**. Steal the *feel* of sand toys; sell the *loop* of automation/prestige.

---

### 4) Mobile hypercasual / midcore — **flip, don’t port**

**Failed default:** Screenshot-identical hypercasual with ads removed and a $4.99 tag. PC players reject timer gates and empty loops.

**Successful pattern A — mechanic flip**

- Mobile *Camo Sniper* (spot the camouflaged target) → Steam *Meccha Chameleon* (you *become* the camouflage in co-op hide-and-seek). Same perception verb; social/creative reframing. Reported multi-million unit sales and huge peak concurrency; Roblox clones followed ([Kotaku](https://kotaku.com/more-people-are-playing-meccha-chameleon-knock-offs-than-the-original-hit-steam-game-as-the-roblox-clone-machine-goes-into-overdrive-2000715371); industry commentary linking DNA to Camo Sniper via AppMagic comparisons on [LinkedIn / Anton Slashcev](https://www.linkedin.com/posts/aslashcev_meccha-chameleon-is-the-new-indie-super-hit-activity-7477662379808493569-mG9Q)).
- Mobile *Magic Survival* → Steam *Vampire Survivors*: deepen the auto-attack survivor loop, premium pricing, streamer-friendly ([Kotaku](https://kotaku.com/vampire-survivors-free-iphone-steam-mobile-smartphone-1849955308)).

**Successful pattern B — hybrid-casual rebuild**

- *My Little Universe*: 50M+ mobile downloads → Steam/console rebuild from scratch; strip predatory timers; add friction/challenge + local co-op; >50% wishlist→purchase in first month ([SayGames / Estoty](https://blog.say.games/posts/from-a-hybrid-casual-hit-to-an-indie-pc-title-the-story-of-my-little-universe)).

**Friendslop note:** 2025 Steam unit charts were dominated by cheap co-op “friendfarming” titles (R.E.P.O., Peak, etc.) with high sales and ~3% average D30 retention ([AppMagic summary](https://gamedevreports.substack.com/p/appmagic-friendslop-games-in-2025); [CBC](https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208)). Commentators frame this as hypercasual logic + Discord voice chat ([Slashcev](https://www.linkedin.com/posts/aslashcev_meccha-chameleon-is-the-new-indie-super-hit-activity-7477662379808493569-mG9Q)). Commercially huge — but **netcode + lobby product**, wrong as this repo’s *first* solo ship unless scope is tiny and original.

**Migrates well**

- One-verb loops that gain **items, runs, or co-op embarrassment**.
- Idle/arcade hybrids rebuilt without energy systems.

**Migrates poorly**

- Ad-break pacing kept intact.
- Games whose only retention is daily login / gacha.

**Repo fit:** Coin-pusher / claw / ticket machines are mobile+arcade dopamine natives — **Game 2** lane ([RACCOIN](https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/), [The Coin Game](https://store.steampowered.com/app/598980/The_Coin_Game/)).

---

### 5) Fortnite UEFN — **signal farm, bad port farm**

**What earns inside Fortnite (2026):** Tycoons/simulators (long session time), obbys/parkour, box fights, prop hunt / party hubs, horror/escape ([UEFN Central map ideas](https://uefncentral.com/uefn-map-ideas); [StraySpark on UEFN revenue](https://www.strayspark.studio/blog/uefn-revenue-stream-indie-studios-2026)). Engagement payouts and in-island V-Bucks keep creators **on-platform**.

**Inbound to Steam rarely means “ship the island.”** IP, Fortnite avatar context, and discovery are non-transferable. What transfers:

| UEFN heat | Steam translation that can sell |
|---|---|
| Prop hunt / paint-hide | Original social party SKU (Meccha-class) — crowded, needs a new verb |
| Tycoon plots | Offline or light-online idle/tycoon at $2–$10 (already Steam-native) |
| Horror escape rooms | Single-player or 2–4p tension product |
| Mini-game hubs | Jackbox-like party packs (scope trap for solo) |

**Honest takeaway:** Use UEFN Discover as a **taste radar**. Build the Steam game as a standalone fantasy. Do not plan UEFN→Steam as the business model; some studios even run the reverse (Steam income replaced by UEFN payouts) ([StraySpark](https://www.strayspark.studio/blog/uefn-revenue-stream-indie-studios-2026)).

---

### 6) Roblox — **demand sensor + clone sink**

**Business reality (2026):** Platform-native teams win with social play, weekly live-ops, and cosmetics. Copying non-Roblox hits onto Roblox often fails; copying Steam hits *onto* Roblox often “succeeds” as free clones ([Deconstructor of Fun](https://www.deconstructoroffun.com/blog/how-to-build-a-real-business-on-roblox-in-2026); [Kotaku clone pipeline](https://kotaku.com/more-people-are-playing-meccha-chameleon-knock-offs-than-the-original-hit-steam-game-as-the-roblox-clone-machine-goes-into-overdrive-2000715371)). Studios like Wonder Works pitch “feels like a Steam game, but free on Roblox” (*Duck Duck*) — i.e. **premium design staying on Roblox**, not migrating out ([GamesBeat](https://gamesbeat.com/team-behind-robloxs-top-earning-licensed-game-launchesd-duck-duck/)).

**What to steal as *research*, not as a port**

- Paint-to-hide / prop-hunt demand after Meccha.
- Tidy/organize demand after *Librarian* → Roblox *Clean the Library* (peak 80k+ CCU reported; Steam original ~1M copies) ([Kotaku](https://kotaku.com/more-people-are-playing-meccha-chameleon-knock-offs-than-the-original-hit-steam-game-as-the-roblox-clone-machine-goes-into-overdrive-2000715371); [Librarian Steam](https://store.steampowered.com/app/4197610/Librarian_Tidy_Up_the_Arcane_Library/)).
- Friendslop co-op as a youth taste language.

**What almost never migrates as a paid Steam .exe**

- Avatar-cosmetic live-ops economies.
- Experiences that only work because friends are already in Roblox.
- “Brain rot” hyper-casual that Roblox itself is trying to move past (per studio commentary around *Duck Duck*).

---

### 7) Chinese mini-games (WeChat / Douyin / Kuaishou) — **selective idea import**

**Scale:** WeChat + Douyin mini-games are a massive casual/midcore layer (hundreds of millions MAU in 2025–26 reporting) with genres skewed to MMORPG, Idle, Card, plus merge/TD hybrids and sim/management growth ([QuestMobile summary via LinkedIn](https://www.linkedin.com/posts/boris-anosov_mobilegaming-wechat-douyin-activity-7387016216357384192-pkla); [Meridian Play / JINKE 2026](https://gamedevreports.substack.com/p/meridian-play-and-jinke-chinas-wechat); [The World of Chinese](https://www.theworldofchinese.com/2026/05/rise-china-mini-game-industry/); [Insightrackr 2026 report overview](https://blog.insightrackr.com/en/docs/mini-game-report-2026)).

**Observed echo chamber:** When *Meccha Chameleon* (*超级变色龙*) exploded on Steam, WeChat saw a swarm of paint-hide mini-games — then a fast decay off the popularity charts ([36Kr](https://www.36kr.com/p/3925934786034057)). Same outbound clone dynamic as Roblox.

**Ideas that *can* become Steam paid products (if rebuilt)**

| Mini-game cluster | Steam-shaped product | Notes |
|---|---|---|
| Tidy / sort / shelf / clean | Cozy organization sim | Already proven (*Librarian*, PowerWash lineage) |
| Merge + systems | Premium merge-roguelite / merge-builder | Needs depth beyond ad-merge |
| Idle / extraction arcade | $2–$8 idle with offline respect | Strip energy; add endings/prestige clarity |
| Drawing / social party | Party pack or Discord+Steam | Graph-dependent on WeChat — redesign for Steam friends |
| Gambling-feel singleplayer | Slot/coin/deck stakes games | Aligns with CloverPit / RACCOIN taste |

**Ideas that stay stuck in mini-game world**

- Moments/share ladders and invite funnels.
- Midcore MMO/SLG that need UA spend and ops teams.
- Clones riding a 2-week overseas Steam meme.

**China as Steam *buyer* segment:** Separate from mini-game *design* import — *The King is Watching* explicitly benefited from China-focused publishing ([GamesIndustry.biz](https://www.gamesindustry.biz/how-steam-changes-and-a-china-strategy-helped-tinybuilds-the-king-is-watching-hit-500k-sales)). Localization/tags matter even for Western-made systemic games.

---

### 8) Discord Activities — **lobby lab + companion channel**

**What they are:** Web apps in an iframe via the Embedded App SDK; opened from voice/text; now more discoverable and monetizable (IAP, GDC 2026 Social Commerce / Game Shop) ([Discord docs](https://docs.discord.com/developers/activities/overview); [Discord GDC 2026 blog](https://www.discord.com/blog/building-on-the-social-layer-of-games-whats-new-from-gdc-2026); [StraySpark playbook](https://www.strayspark.studio/blog/discord-activities-embedded-app-sdk-indie-game-distribution-2026); [a16z](https://a16z.com/discord-activities-social-gaming/)).

**Formats that prove demand**

- Poker Night, Gartic Phone, Sketch Heads, Putt Party, word/trivia games ([Discord Activities overview posts](https://discord.com/blog/server-activities-games-voice-watch-together); third-party roundups e.g. [Peakbot guide](https://peakbot.pro/blog/discord-activities-apps-guide-2026)).
- Third-party hits reported with large play volumes (e.g. Chef Showdown, Death by AI, Krunker Strike commentary in [a16z](https://a16z.com/discord-activities-social-gaming/)).

**Migration to paid Steam .exe**

| Path | When it works |
|---|---|
| Activity → full Steam party game | Deeper modes, offline/private lobbies, cosmetics as DLC |
| Steam game → Discord companion Activity | Daily challenge / lobby mini used as marketing ([StraySpark multi-channel model](https://www.strayspark.studio/blog/discord-activities-embedded-app-sdk-indie-game-distribution-2026)) |
| Activity-only SKU | Weak as sole business — audiences still smaller than Steam launches |

**Fit for this repo:** Optional **discovery layer** around Games 1–3 (browser demo + Discord Activity), not a fourth genre mashup. Party-game full SKUs are a different product family (Jackbox competition).

---

## What successfully becomes a paid Steam `.exe`

### Checklist (must mostly pass)

| Gate | Pass means |
|---|---|
| **Hook in 10 seconds** | Trailer/clip teaches the verb without voiceover essay |
| **Works without platform graph** | Fun solo *or* with 2–4 Steam/Discord friends — not “only if 20 Roblox friends online” |
| **Depth beyond free clone** | Items, runs, modifiers, prestige, campaign, or creative tools with goals |
| **Session shape** | 5–40 minutes for vignette/party; longer OK for idle if progressive |
| **Price honesty** | $2.99–$12.99 for short systemic; higher only with content volume |
| **Demo = fantasy** | Demo sells the loop, not a truncated chapter of nothing |
| **Original expression** | Copyright does not protect “genre”; clones still die on Steam when they look and feel generic ([copyright framing in Kotaku](https://kotaku.com/more-people-are-playing-meccha-chameleon-knock-offs-than-the-original-hit-steam-game-as-the-roblox-clone-machine-goes-into-overdrive-2000715371)) |

### High-probability migration recipes (2026)

1. **Tension toy → paid vignette** (itch/TikTok → Steam) — Buckshot / CloverPit class.  
2. **One-verb hypercasual → social or deep flip** — Camo→Meccha; Magic Survival→VS.  
3. **Sandbox toy → goal wrapper** — sand/particles → Noita-depth *or* Particul-idle.  
4. **Arcade dopamine machine → roguelite framing** — coin pusher / claw / ticket → RACCOIN-class.  
5. **Jam systemic hook → published roguelite/strategy** — King is Watching class.  
6. **Tidy/ASMR labor fantasy → cozy sim** — PowerWash / Librarian class (watch saturation).

### Low-probability / trap recipes

| Trap | Why |
|---|---|
| Straight Roblox→Steam port | Wrong monetization, avatar dependency, younger free audience |
| UEFN island as Steam SKU | Fortnite context is the product |
| WeChat midcore MMO lite | Ops + UA, not solo Steam |
| Friendslop clone #N | Unit lottery; retention collapses; crowded |
| Pure web toy with tip jar expectations | Players already got it free in browser |
| Hypercasual + energy timers on PC | Review bomb territory |

---

## Implications for this repo’s multi-game plan

Aligned with pure-category rule in [`GAME_PLAN.md`](../GAME_PLAN.md):

| Planned game | External trend fuel | Do / Don’t |
|---|---|---|
| **Game 1 — Tension / horror vignette** | itch + TikTok toys; Buckshot/CloverPit discovery pattern | **Do** original ritual/stakes; clip-first demo. **Don’t** shotgun clone or mash slots into it. |
| **Game 2 — Coin-machine** | Mobile/arcade pusher dopamine; gambling-*feel* trend without real money | **Do** sharp physics + run structure. **Don’t** thin RACCOIN clone. |
| **Game 3 — Idle / particle tycoon** | Sandspiel/Powder Toy feel + Particul wrap; CN/mobile idle demand | **Do** sand satisfaction + automate/prestige. **Don’t** ship sandbox-only. |
| Later | Tidy/cozy organization; tower defense (UEFN/WeChat heat) | Only after 1–3; tidy lane already cloning hard. |
| Avoid as first | Friendslop netcode, Roblox-style live-ops, UEFN dependency | Wrong band for $0.99–$10 solo first ship. |

**Optional distribution stack** (not a mashup design): itch/browser demo → Steam paid `.exe` → Discord companion Activity for clips/community ([StraySpark](https://www.strayspark.studio/blog/discord-activities-embedded-app-sdk-indie-game-distribution-2026)).

---

## Watchlist — ideas likely to hit Steam next

Prioritized for *someone else* shipping soon (competitive awareness) and for *our* lane selection.

| Priority | Idea seed | Where it’s hot now | Steam form that can sell | Risk |
|---|---|---|---|---|
| P0 | New **stakes vignette** (not shotgun, not slots) | TikTok / itch | $3–$8 single-player tension | Clone wave after any hit |
| P0 | **Particle/sand + progression** | Web toys / Particul comps | $2–$5 idle or puzzle-sim | Needs ending/prestige clarity |
| P1 | **Arcade machine fantasy** (pusher/claw/ticket) | Mobile + RACCOIN heat | $5–$10 roguelite-framed | Post-RACCOIN crowding |
| P1 | **Tidy / sort / restore** | Steam *Librarian* + Roblox clones + CN sort games | Cozy FP organizer | Saturation + AI-asset backlash risk |
| P1 | **Paint / creative hide** | Meccha + Roblox/UEFN/WeChat clones | Only with a *new* verb | Extremely crowded |
| P2 | **Merge-roguelite / merge-builder** | WeChat merge growth | Premium single-player | Easy to feel mobile-ported |
| P2 | **Party lobby SKU** from Discord Activities | Gartic / sketch / trivia | Full Jackbox-like pack | Scope + marketing vs giants |
| P3 | Tycoon plot fantasy from UEFN | Fortnite Creative | Offline tycoon | Must beat Steam idle natives |

---

## Selected sources

### Pipelines & platform strategy
- Kotaku — Steam→Roblox clone pipeline (Meccha, Librarian): https://kotaku.com/more-people-are-playing-meccha-chameleon-knock-offs-than-the-original-hit-steam-game-as-the-roblox-clone-machine-goes-into-overdrive-2000715371  
- Deconstructor of Fun — Roblox business 2026: https://www.deconstructoroffun.com/blog/how-to-build-a-real-business-on-roblox-in-2026  
- Deconstructor of Fun — Newzoo inflection / gateway skepticism: https://www.deconstructoroffun.com/blog/newzoos-inflection-point-report-three-things-worth-arguing-about  
- StraySpark — Discord Activities + multi-channel distribution: https://www.strayspark.studio/blog/discord-activities-embedded-app-sdk-indie-game-distribution-2026  
- StraySpark — UEFN as indie revenue: https://www.strayspark.studio/blog/uefn-revenue-stream-indie-studios-2026  
- Discord — Activities overview: https://docs.discord.com/developers/activities/overview  
- Discord — GDC 2026 social layer: https://www.discord.com/blog/building-on-the-social-layer-of-games-whats-new-from-gdc-2026  
- a16z — Discord Activities: https://a16z.com/discord-activities-social-gaming/

### Case studies (inbound success)
- Polygon — Buckshot Roulette 1M: https://www.polygon.com/24148258/buckshot-roulette-steam-launch-multiplayer-mike-klubnika-success/  
- GamesRadar — Buckshot multi-million: https://www.gamesradar.com/games/horror/he-made-a-viral-horror-game-in-2-months-it-sold-6-million-copies-and-now-he-can-make-whatever-he-wants-for-the-rest-of-his-life-my-final-theory-is-that-gambling-is-very-fun/  
- games.gg / GamesMarket — CloverPit launch: https://games.gg/news/clover-pit-sells-750k-copies/ · https://www.gamesmarket.global/750000-copies-sold-how-cloverpit-completely-beat-future-friends-best-case-predictions-6bf7f63be1546a7ae7f40eef3ef99379/  
- GamesIndustry.biz / GameMaker — The King is Watching: https://www.gamesindustry.biz/how-steam-changes-and-a-china-strategy-helped-tinybuilds-the-king-is-watching-hit-500k-sales · https://gamemaker.io/en/blog/the-king-is-watching-tinybuild  
- How To Market A Game — Roottrees itch→Steam: https://howtomarketagame.com/2025/04/28/how-an-itch-io-game-became-a-million-dollar-hit-the-roottrees-are-dead/  
- SayGames — My Little Universe mobile→Steam: https://blog.say.games/posts/from-a-hybrid-casual-hit-to-an-indie-pc-title-the-story-of-my-little-universe  
- Kotaku — Vampire Survivors mobile DNA / clones: https://kotaku.com/vampire-survivors-free-iphone-steam-mobile-smartphone-1849955308  

### Friendslop / social party
- CBC — What is friendslop: https://www.cbc.ca/news/entertainment/friendslop-video-games-big-walk-review-9.7297208  
- AppMagic retention summary: https://gamedevreports.substack.com/p/appmagic-friendslop-games-in-2025  

### Web toys & particles
- Making Sandspiel: https://maxbittker.github.io/making-sandspiel/  
- Sandspiel itch: https://maxbittker.itch.io/sandspiel  
- The Powder Toy Steam: https://store.steampowered.com/app/1148350/The_Powder_Toy/  
- Noita: https://noitagame.com/  
- Particul Steam: https://store.steampowered.com/app/4273120/Particul/

### China mini-games
- The World of Chinese — mini-game industry: https://www.theworldofchinese.com/2026/05/rise-china-mini-game-industry/  
- Meridian Play — WeChat market 2026: https://gamedevreports.substack.com/p/meridian-play-and-jinke-chinas-wechat  
- 36Kr — Meccha-driven WeChat paint-hide swarm: https://www.36kr.com/p/3925934786034057  
- Insightrackr — 2026 Mini Games Growth Report: https://blog.insightrackr.com/en/docs/mini-game-report-2026  

### UEFN / Roblox product notes
- UEFN Central — map ideas 2026: https://uefncentral.com/uefn-map-ideas  
- GamesBeat — Wonder Works *Duck Duck*: https://gamesbeat.com/team-behind-robloxs-top-earning-licensed-game-launchesd-duck-duck/  

### Store comps (this repo)
- Buckshot Roulette: https://store.steampowered.com/app/2835570/Buckshot_Roulette/  
- CloverPit: https://store.steampowered.com/app/3314790/CloverPit/  
- RACCOIN: https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/  
- Particul: https://store.steampowered.com/app/4273120/Particul/  
- Librarian: https://store.steampowered.com/app/4197610/Librarian_Tidy_Up_the_Arcane_Library/  

---

*Sales and CCU figures above are as reported by linked sources at time of writing; treat headline unit counts as order-of-magnitude signals, not audited finance.*
