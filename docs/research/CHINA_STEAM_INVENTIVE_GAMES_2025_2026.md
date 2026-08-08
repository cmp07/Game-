# Inventive / Small Steam Games & Chinese Audiences (2025–2026)

**Repo:** [cmp07/Game-](https://github.com/cmp07/Game-) · planning workspace `sandpile-tycoon`  
**Compiled:** August 2026  
**Lens:** What inventive, small, or systems-forward Steam titles succeed with Chinese players — and what that implies for generative / physics / creation games, plus localization, tags, and price.  
**Companion docs:** [`GAME_PLAN.md`](../GAME_PLAN.md) · [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md)

---

## Executive summary

China is no longer an optional Steam region. Simplified Chinese is roughly tied with (or ahead of) English as a primary Steam language on a full-year basis, and Chinese players routinely decide whether a mid-size or indie hit becomes a global smash or a regional miss. In 2025–2026, the inventive small games that win Chinese audiences share a clear pattern:

1. **A one-sentence hook that travels in clips** (cute ducks × Tarkov; coin pusher × roguelike; card sultan × dark agency).
2. **Ship-day Simplified Chinese on the store page and in UI** — missing it can leave China under ~5% of players even on a global mega-hit (R.E.P.O.).
3. **Regional RMB pricing in the “indie comfort band”** — often ~30–55% below naive USD→RMB FX, with many successful indies at **≤¥100**, and several breakouts in the **¥45–¥80** band for substantial content.
4. **Discovery off-Steam first** — Bilibili, Heybox, Douyin, Xiaohongshu (RED), TapTap — then Steam conversion.
5. **Readable systems over prestige production** — Chinese Steam buyers punish tech/optimization failures (WUCHANG) and reward “fun first” buyout games with almost no paid UA (Sultan’s Game).

For this repo’s lanes (tension vignette → coin machine → particle/idle tycoon), China is **highly aligned** with Games 2 and 3, and **viable** for Game 1 if Chinese localization and short-form demos are day-one.

---

## 1. Market context: why China matters on Steam now

### Scale

| Signal | Figure / claim | Source |
|---|---|---|
| China Steam audience (end 2025) | **~42.4 million** players | Asia Game Buzz / GameDev Reports (Jun 2026) |
| Steam share of China PC/console MAU | **~87%** | Same |
| China client PC games | **~$11–12B** (~22% of national games market) | Same |
| National games market | **~$51.8B**; **~683M** players (end 2025) | Same |
| Average China Steam prices vs West | **~20–37% lower** | Asia Game Buzz; Game Industry Library |

Steam dominates China’s premium/PC discovery surface. Console remains secondary; Windows + Steam is the default path for inventive paid indies.

### Language share (treat spikes carefully)

- **Valve GDC 2025 internal (full year 2024):** Simplified Chinese **33.7%**, English **33.5%**, Russian **8.2%** (LingoBright summary of Valve data).
- **Steam Hardware Survey Feb 2025:** Simplified Chinese spiked to **50.06%** during Chinese New Year (Automaton, Gaming.news, GameLook). This is a holiday-biased voluntary survey — use it as “China can dominate concurrent activity,” not as a permanent 50% ownership share.
- Post–*Black Myth: Wukong* (2024), Steam became more mainstream among Chinese players; major Chinese publishers (NetEase, Tencent, Papergames, Bilibili) now treat Steam as a primary or co-primary launch.

**Implication:** A Western-only store page is leaving the largest single language cohort on the table.

---

## 2. What “success with Chinese audiences” looks like in 2025–2026

### Pattern A — China-native inventive smash

These are small/medium teams, high invention density, China-first or China-majority audiences.

#### Escape from Duckov (《逃离鸭科夫》) — Oct 2025

| Field | Detail |
|---|---|
| Hook | Cute ducks × Escape from Tarkov–style extraction, rebuilt as **PvE / single-player-friendly** |
| Team | Team Soda (~4–5 people), published by **Bilibili** |
| China price | **¥58** (launch ~¥51 with 12% discount) |
| Traction | 500K first week → **2M+** global copies in ~2 weeks; Steam CCU peak **~300K+**; ~**64%** Chinese player share reported in China press synthesizing Alinea |
| Reviews | Very Positive / ~95–96% positive; Simplified Chinese review volume dominates English on the store page |
| Why it worked | Inventive but instantly explainable; lowers hardcore friction; Bilibili community flywheel; demo-led wishlist; “fun, light, replayable” at a price far below AAA |

Sources: TechNode (22 Oct 2025); Game Developer (30 Oct 2025); 17173 / Alinea China press roundups; Steam store language breakdown.

**Lesson for inventive design:** China rewards **genre remixes with a friendly face**, not pure novelty for its own sake. The systems must be deep enough for guides and clip culture, soft enough for a broad audience.

#### Sultan’s Game (《苏丹的游戏》) — Mar 2025

| Field | Detail |
|---|---|
| Hook | Card strategy RPG with dark agency, power, and branching narrative |
| Team | Double Cross Studio (~dozen), published by **2P Games** |
| China price | **¥80** (launch **¥72**) |
| Traction | **250K in week one**; later **~660K+** copies / **~$12.4M** (VG Insights via KrASIA / 36Kr) |
| Marketing | Publisher reported **almost no paid UA**; viral on Xiaohongshu + Bilibili |
| Why it worked | High writing density + distinctive art; Steam buyout model matched maturing Chinese willingness to pay; platform timing (SC language share rising) |

Sources: TechNode (10 Apr 2025); KrASIA / 36Kr feature; Steam news (250K update).

**Lesson:** Chinese Steam players will pay for **dense single-player invention** when the fantasy is clear. Paid acquisition is optional if the game is clip-/note-friendly on RED and Bilibili.

#### RACCOIN: Coin Pusher Roguelike (《浣熊推币机》) — Mar 2026

| Field | Detail |
|---|---|
| Hook | Arcade coin pusher × roguelike deckbuilding (“Balatro energy” in Chinese coverage) |
| Team | Chinese **3-person** studio (浣犬游戏 / Huanquan), published by Playstack |
| China price | **¥45** (first-week ~**¥36.9** at 18% off / “82折”) |
| Traction | **100K units in 24 hours**; Steam CCU peak reported **~110K** in China press |
| Localization | Simplified + Traditional Chinese day one (among ~9 languages) |
| Why it worked | Instant cultural familiarity (claw/coin arcade nostalgia) + modern roguelike depth; aggressive indie price; dopamine-readable in 15-second clips |

Sources: gamemaidong release coverage; NetEase/163 feature; Steam store + Steam news (100K/24h).

**Lesson for this repo’s Game 2:** The coin-machine lane is **already China-proven at the source**. Differentiation vs RACCOIN is mandatory; thin clones will face a Chinese audience that already owns the category king.

### Pattern B — Global smash that *under*-indexes China (localization tax)

#### R.E.P.O. (2025)

- Global unit monster (Alinea: **~14.4M** Steam copies by May 2025; later coverage higher).
- **&lt;5% of players in China** while Chinese localization was missing.
- Alinea explicitly flagged Chinese language + sub-$10 pricing as the unlock.

Source: [Alinea Analytics — May 2025 Steam copies sold](https://alineaanalytics.com/blog/steam_may_2025/).

**Lesson:** Invention + co-op virality is not enough. **No Simplified Chinese ≈ China barely shows up.**

### Pattern C — Creation / home / sandbox viral without a finished ship

#### Homespace (wishlist viral, 2026)

- Photoreal home-building / social space sim (PC-first; VR later).
- Organic Chinese coverage on Xiaohongshu, Douyin, Bilibili, Tieba drove wishlists from **~2,500 → ~49,700** in ~3 months (including Heybox wishlists in some tallies); **~7,000 wishlists overnight** after one wave of Chinese videos.
- European developer engaged via **machine translation** on Tieba / Heybox / Bilibili; Chinese feedback shaped systems (fishing, farming, CAD import, water sim).

Sources: 36Kr; NewsGlobeNow; developer community posts.

**Lesson for generative/creation games:** China can mint a creation game’s audience **before launch** if the fantasy is “build a beautiful persistent space and show it.” Engagement quality beats perfect Chinese fluency.

### Pattern D — Evergreen physics / sandbox with durable Chinese reviews

| Title | Signal | Notes |
|---|---|---|
| **Besiege** | ~**9.7K** Simplified Chinese reviews, Overwhelmingly Positive (~96%); strong share of ~47K total | Medieval physics building; Chinese UI; Gcores longform praise for creation + Workshop |
| **People Playground** | ~**4–5K** Simplified Chinese reviews, Overwhelmingly Positive; ~$9.99 USD band | Physics sandbox / ragdoll lab; English-primary but still earns Chinese goodwill |
| **Sandboxels** (May 2025) | Falling-sand chemistry sandbox; **Simplified + Traditional Chinese** listed | Tags: Sandbox, Physics, Simulation, Casual, God Game — template for particle toys |
| **Buckshot Roulette** | Simplified Chinese reviews **Very Positive** (~8–10% of review language share in public breakdowns) | Proves short tension vignettes travel; not China-majority, but China-viable with SC support |

Physics sandboxes that succeed long-term with Chinese players tend to offer: **immediate toy feedback**, **shareable creations**, and **low text load** (or full SC UI).

### Pattern E — China-skewed mid-tier / niche hits

- **Revenge on Gold Diggers** (Chinese-language FMV dating sim): ~**1.3M** copies in Jun 2025 window coverage; **~73%** China sales (GAMES.GG / Alinea June roundups).
- **FANTASY LIFE i**: ~**half** of Steam players in China (Alinea May 2025) — cozy sim + RPG travels when Asia-facing.
- **Stellar Blade** (AA/AAA reference): **&gt;50%** of Steam copies from China with full Chinese audio + aggressive RMB pricing vs $60 West (GAMES.GG; Alinea).

These show the ceiling when localization and regional pricing are treated as first-class.

---

## 3. Discovery stack (more important than Steam tags alone)

Asia Game Buzz (2025–2026) and long-standing indie China FAQs converge on the same stack:

| Layer | Platforms | Role |
|---|---|---|
| **Core PC discovery** | **Heybox (小黑盒)**, Steam store, SteamCN | Keys, deals, wishlists, Chinese reviews |
| **Video / viral** | **Bilibili**, Douyin | Clip loops, UP主 demos, let’s plays |
| **Lifestyle / notes** | **Xiaohongshu (RED)** | Aesthetic screenshots, “is it worth ¥X?” notes (Sultan, Homespace) |
| **Game-centric social** | **TapTap**, Weibo | Scores, soft launch, community |
| **Secondary keys** | Sonkwo, etc. | Regional distribution volume |
| **Events** | ChinaJoy, Bilibili World; indie-leaning WePlay / G-Fusion | Awareness (expensive; optional for micro-indies) |

**Operational takeaway for a $0.99–$10 solo/small ship:**

1. Simplified Chinese store page (title, short desc, capsules with readable Chinese or language-light art).
2. 30–90s vertical + horizontal trailers that work muted (physics payouts, fail states, builds).
3. Demo timed for Chinese evening / weekend windows.
4. Heybox presence + reply to Chinese comments (MT is acceptable early — Homespace proof).
5. Do **not** rely on Western TikTok/YouTube alone.

---

## 4. Localization: minimum viable vs high-ROI

### Minimum for inventive systems games (physics / idle / coin / vignette)

| Asset | Priority | Why |
|---|---|---|
| Simplified Chinese **UI** | **P0** | R.E.P.O. cautionary tale |
| Simplified Chinese **store page** | **P0** | Discovery + review language |
| Traditional Chinese UI | P1 | Taiwan/HK/overseas Chinese; cheap if SC exists |
| Chinese subtitles for any VO | P1 if narrative |
| Full Chinese dub | P2 for vignette/systems toys; P0 for story-AA |
| Chinese-friendly fonts / no clipped glyphs | P0 | Common Godot/Unity failure mode |
| Culturally sane defaults (gore toggles, gambling framing) | P1 | Store/compliance + audience comfort |

### Soft localization that moves wishlists

- Chinese **short title** that states the fantasy (e.g. RACCOIN’s 《浣熊推币机》 is clearer than an English pun alone).
- Capsule art that reads at phone size on Heybox/Bilibili.
- Patch notes in SC — Chinese players reward live responsiveness (WUCHANG inverse: punish silence + poor perf).

### Performance is localization

WUCHANG’s launch showed Chinese review scores collapsing vs English when PC optimization failed expectations (Alinea). For physics/particle games, **stable frame time on mid-range NVIDIA laptops common in China** is part of “speaking the market’s language.”

---

## 5. Tags & store taxonomy that fit Chinese inventive tastes

Steam’s global tag set is English, but Chinese players still filter with it — and Chinese store text carries the sell.

### High-fit tag clusters for this repo

| Lane | Primary tags | Secondary tags | Chinese-facing notes |
|---|---|---|---|
| **Tension vignette** | Indie, Horror, Psychological Horror, Singleplayer | Minimalist, Dark Humor, Choices Matter | Short sessions fit Bilibili “one more round” clips; SC UI mandatory |
| **Coin machine** | Casual, Simulation, Indie, Strategy | Physics, Arcade, Roguelike, Funny | RACCOIN already owns “pusher + roguelike”; differentiate fantasy |
| **Particle / idle tycoon** | Simulation, Casual, Indie, Idle | Management, 2D, Relaxing, Sandbox | Aligns with China’s solid **simulation/management** appetite (~16% of title mix in Asia Game Buzz compile) |
| **Physics / creation sandbox** | Sandbox, Physics, Simulation, Building | God Game, Level Editor, Moddable | Besiege / Sandboxels / Homespace pattern; Workshop is a force multiplier |

### Genre mix context (directional)

Asia Game Buzz compile of public data for China-facing Steam tastes: **action/shooters ~33%**, **RPG/adventure ~24%**, **simulation/management ~16%**. Simulation is not the largest bucket — but it is large enough, and inventive sims punch above weight when priced and clipped well.

### Tag hygiene

- Prefer **one pure fantasy** on the page (matches this repo’s anti-mashup rule). Chinese buyers are sophisticated about “fake tag stuffing.”
- Use **Funny / Cute / Relaxing** only if the first 10 seconds of trailer prove it (Duckov, RACCOIN).
- Avoid leading with Western meme tags that don’t translate; lead with **verb + toy** (“推币 / 建造 / 沙盒物理”).

---

## 6. Pricing: RMB bands that actually sell

### Macro rules (2025 studies)

From Evolve PR’s China regional pricing study (May 2025) and Asia Game Buzz:

- Steam’s recommended China price is roughly **~50% below** naive USD→RMB FX (example: $29.99 → recommended **¥108** vs ~¥210 FX).
- Empirical success band: **~30–55% below FX**.
- **Indies** cluster at the **cheaper** end (≥50% off FX); some Chinese publishers go **below** Steam rec.
- Informal **mass acceptance** for many indies: **≤¥100**; AAA cultural hits can break far higher (*Black Myth*).
- Older indie China FAQ guidance (indienova / A MAZE): often **~half Western USD**, prefer prices ending in **9** (¥19 / ¥29 / ¥39).

### Observed breakout prices (China store)

| Game | RMB | Approx USD list | Content weight |
|---|---|---|---|
| RACCOIN | **¥45** (launch ~¥37) | mid–high single digits | Short-session dopamine + meta |
| Escape from Duckov | **¥58** | ~$8 | 50h+ progression claims in press |
| Sultan’s Game | **¥80** (launch ¥72) | ~$11 | Very high text/content density |
| Indie comfort ceiling (study commentary) | **≤¥100** | — | Psychological threshold cited for many indies |
| Stellar Blade (AA reference) | **¥268** vs $60 West | — | Premium + full CN audio |

### Suggested RMB mapping for this repo’s $0.99–$10 band

Assume Steam recommendation ≈ **0.45–0.55 × (USD × 7.2)** as a planning heuristic; then bias **down** for unknown Western indies.

| USD target | Planning RMB | Notes |
|---|---|---|
| $0.99–$1.99 | **¥6–¥14** | Impulse / catalog (Particul-like) |
| $2.99–$4.99 | **¥18–¥36** | Tension vignette sweet spot (Buckshot-class) |
| $5.99–$7.99 | **¥32–¥48** | Lean coin-machine MVP |
| $8.99–$10.99 | **¥45–¥68** | Only if content density matches Duckov/RACCOIN bar |
| Launch discount | **−10% to −20%** for 1–2 weeks | Standard China expectation |

**Do not** price a thin Western clone at RACCOIN’s ¥45 hoping for RACCOIN’s sales. Price for **impulse + goodwill**, then earn reviews.

---

## 7. Implications for generative / physics / creation games

### What Chinese audiences already buy in this neighborhood

1. **Physics toys with agency** — Besiege-like building, People Playground-like labs, falling-sand chemistry (Sandboxels / “Wuli Sandbox” class wishlists).
2. **Creation + social exhibition** — Homespace’s viral loop is “look what I built / live in,” not tech demo generative AI for its own sake.
3. **Arcade-physical dopamine** — coin pushers, particle cascades, payout machines — extremely legible on Douyin/Bilibili.
4. **Automation / number-go-up** — idle and management sims sit in a proven demand bucket if the first minute shows a clear loop.

### What “generative” should mean for China GTM (2025–2026)

Chinese coverage of Homespace explicitly framed **AI generative tools as a future competitor**, not the product’s selling point. Players celebrated **authored tools + player creativity**.

**Position generative features as:**

- **Amplifier of player intent** (smarter brushes, auto-rigging, layout assist), or  
- **Physics/content multiplicity** (emergent reactions, sandpile cascades, recipe discovery),  

**Not as:**

- “AI made this game,” or  
- unbounded UGC that looks samey / spammy on store pages.

### Product implications by repo lane

| Planned product | China fit | Concrete implications |
|---|---|---|
| **Game 1 — Tension / horror vignette** | Good if SC + demo | Keep sessions clip-length; SC UI day one; price **¥18–¥36**; expect solid but not Duckov-scale China % unless marketing is China-aware |
| **Game 2 — Coin machine** | **Excellent / contested** | RACCOIN set the China meta at ¥45 / 3-person team. Need a **sharper pure-arcade or pure-fantasy** hook; avoid “RACCOIN but worse.” Demo physics readability &gt; lore |
| **Game 3 — Idle / particle tycoon** | Strong catalog fit | Simulation tags + low text load travel well; price **¥8–¥28**; emphasize automation spectacle in trailers; Heybox “relax/addictive” framing |
| **Future — Creation / generative sandbox** | High upside, higher scope | Homespace shows wishlist can explode from China alone; plan Workshop/sharing, SC onboarding, and mid-PC performance before marketing spend |

### Design principles that transfer

1. **One visible toy in five seconds** (coin drop, particle sell, shotgun click, wall collapse).
2. **Shareable outcomes** (funny fails, mega payouts, screenshots of builds).
3. **Depth after delight** (Duckov’s progression; Sultan’s branches; RACCOIN’s synergies).
4. **Respect buyout norms** — Chinese Steam converts hate feeling like a skinned mobile IAP funnel when they paid already.
5. **Ship Chinese before scaling ads** — organic China can outpace paid West (Homespace, Sultan).

---

## 8. Risk register (China-specific)

| Risk | Evidence | Mitigation |
|---|---|---|
| Missing SC localization | R.E.P.O. &lt;5% China | SC UI + store before launch trailer push |
| Overpricing unknown indie | Evolve: indie mass comfort ≤¥100; aggressive discounts common | Follow Steam rec or slightly under; end in 9 |
| Clone fatigue post-RACCOIN | Category heat + Chinese originator | Differentiate fantasy; consider Game 1 first per plan |
| Optimization backlash | WUCHANG CN review crater | Mid-tier laptop QA; honest system reqs |
| Discovery only on Steam | Market is community-led | Bilibili/Heybox/RED plan; MT community replies OK |
| Genre mash on store page | Repo rule + Chinese tag skepticism | One pure category per SKU |
| License / domestic store complexity | Domestic ISBN still hard; many indies Steam-only | Steam-global is a valid path (Sultan, RACCOIN); WeGame optional later |

---

## 9. Action checklist for cmp07/Game- products

**Before any Steam page goes live**

- [ ] Simplified Chinese store strings (title, short, long).
- [ ] SC UI pass (menus, settings, common errors).
- [ ] Capsules that work without English wordmarks.
- [ ] RMB price set via Steam recommendations, then sanity-check vs table in §6.
- [ ] Demo build; schedule visibility for China evening (CST).

**Marketing (cheap path)**

- [ ] 15s physics/payout clip + 60s loop explanation.
- [ ] Heybox developer account; answer comments.
- [ ] 1–3 Bilibili UP主 keys (gameplay-focused, not paid essay ads).
- [ ] Xiaohongshu screenshot note template (“¥X 值不值”).

**Analytics to watch**

- Wishlist velocity by region (Steamworks).
- Review language mix (SC share).
- Heybox wishlists / ratings vs Steam.
- Refund rate after Chinese peak hours (perf + clarity bugs).

---

## 10. Source list

### Market size, language, platforms

1. Asia Game Buzz × GameDev Reports — *China’s Steam & PC Gaming Market in 2025* (9 Jun 2026): https://gamedevreports.substack.com/p/exclusive-asia-game-buzz-and-gamedev  
2. Game Industry Library summary of same report: https://gameindustrylibrary.com/documents/china-s-steam-pc-gaming-market-in-2025  
3. Automaton — Steam Chinese users spike Feb 2025: https://automaton-media.com/en/news/steam-saw-chinese-users-spike-and-exceed-50-of-worldwide-playerbase-in-february-2025/  
4. Gaming.news — SC &gt;50% hardware survey: https://gaming.news/news/2025-03-07/the-number-of-chinese-users-on-steam-has-exceeded-50-of-the-total-player-base/  
5. GameLook — Chinese coverage of Feb 2025 survey: http://www.gamelook.com.cn/2025/03/566009/  
6. LingoBright — Steam language statistics (Valve GDC 2025 year averages): https://www.lingobright.com/statistics/steam-language-statistics/  

### Pricing

7. Evolve PR — *Regional Pricing Study – China* (27 May 2025): https://www.evolve-pr.com/2025/05/27/regional-pricing-study-china/  
8. GameDiscoverCo — Steam regional pricing recommendations analysis: https://newsletter.gamediscover.co/p/does-steam-have-its-regional-pricing  
9. indienova — *A MAZE FAQ: China for indie game developers*: https://ld0.indienova.com/en/indie-game-news/a-maze-faq-china-for-indie-game-developers/  

### Case studies — China inventive / indie hits

10. TechNode — Escape from Duckov 500K week one: https://technode.com/2025/10/22/bilibilis-duck-themed-shooter-escape-from-duckov-sells-500000-copies-in-first-week-on-steam/  
11. Game Developer — Behind Duckov’s Steam chart rise: https://www.gamedeveloper.com/business/behind-escape-from-duckov-s-unlikely-rise-to-the-top-of-the-steam-charts  
12. TechNode — Sultan’s Game 250K debut week: https://technode.com/2025/04/10/norm-defying-chinese-indie-title-sultans-game-hits-250000-steam-sales-in-debut-week/  
13. KrASIA / 36Kr — Sultan’s Game breakout feature: https://kr-asia.com/indie-no-more-sultans-game-becomes-chinas-breakout-steam-hit  
14. 17173 — Alinea 2025 Steam report China roundup (Duckov 64% CN): https://news.17173.com/content/12302025/102643237.shtml  
15. gamemaidong — RACCOIN Steam launch / ¥45 pricing: https://gamemaidong.com/console/raccoon-coin-pusher-steam-release  
16. NetEase/163 feature — RACCOIN 100K/24h, ¥45, ~110K CCU claims: https://3g.163.com/dy/article/KPUFBNSN0511CVBI.html  
17. Steam news — RACCOIN 100,000 units / 24 hours: https://store.steampowered.com/news/app/3784030/view/538883150377386558  

### Case studies — localization gap, AAA China share, creation viral

18. Alinea Analytics — May 2025 Steam copies sold (R.E.P.O. &lt;5% China w/o CN loc): https://alineaanalytics.com/blog/steam_may_2025/  
19. Alinea / Substack — Chinese audiences in 2025 bestsellers + WUCHANG: https://alineaanalytics.substack.com/p/chinese-audiences-have-been-a-huge  
20. GAMES.GG — China’s role in Steam best-sellers (Stellar Blade, Split Fiction): https://games.gg/news/china-role-in-steam-best-sellers/  
21. GAMES.GG — PEAK / Revenge on Gold Diggers June sales notes: https://games.gg/news/peak-makes-17-million-in-revenue/  
22. 36Kr — Homespace China wishlist surge: https://www.36kr.com/p/3868539445040131  
23. NewsGlobeNow — Homespace ~49.7K wishlists: https://www.newsglobenow.com/new387237.html  

### Physics / sandbox / vignette store references

24. Besiege Steam (SC reviews): https://store.steampowered.com/app/346010/Besiege/  
25. Gcores — Besiege creation/destruction essay: https://www.gcores.com/articles/180342  
26. People Playground Steam: https://store.steampowered.com/app/1118200/People_Playground/  
27. Sandboxels Steam: https://store.steampowered.com/app/3664820/Sandboxels/  
28. Buckshot Roulette Steam: https://store.steampowered.com/app/2835570/Buckshot_Roulette/  
29. Escape from Duckov Steam: https://store.steampowered.com/app/3167020/Escape_from_Duckov/  
30. RACCOIN Steam: https://store.steampowered.com/app/3784030/RACCOIN_Coin_Pusher_Roguelike/  
31. Homespace Steam: https://store.steampowered.com/app/2508170/Homespace/  
32. Sultan’s Game Steam news (250K): https://store.steampowered.com/news/app/3117820/view/543353773096961413  

### Internal planning links

33. [`docs/GAME_PLAN.md`](../GAME_PLAN.md) — multi-game pure-category plan  
34. [`docs/research/CATEGORY_RANKING.md`](CATEGORY_RANKING.md) — scoreboard for $0.99–$10 desktop ships  

---

## 11. Bottom line for this workspace

Chinese Steam players in 2025–2026 reward **inventive but instantly legible toys**, priced in the **¥20–¥80** indie band, with **Simplified Chinese as a launch requirement**, discovered via **Bilibili / Heybox / RED**. Global hits without Chinese localization can leave China near zero; China-native inventive games can outsell Western expectations on Steam alone.

For generative / physics / creation work: sell **player-visible systems and shareable outcomes**, not “AI” as brand. For the planned sequence, **treat China as a primary launch region on every SKU** — especially coin-machine and particle/idle products — and assume RACCOIN has already educated the market on what a great ¥45 dopamine machine feels like.
