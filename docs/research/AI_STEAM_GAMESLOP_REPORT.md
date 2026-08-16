# Why AI-Generated Steam Games Fail — and How Inventive AI Games Escape the Slop Label

**Repo:** cmp07/Game-  
**Research window:** 2024–mid-2026 (compiled August 2026)  
**Audience:** Solo/small-team Steam shippers considering AI tooling or AI-native design  
**Related:** [`CATEGORY_RANKING.md`](CATEGORY_RANKING.md) · [`../GAME_PLAN.md`](../GAME_PLAN.md)

---

## Executive verdict

AI did not invent Steam failure. Steam was already brutally hit-driven: the top ~1% of titles capture ~94% of estimated revenue; the median reviewed game makes on the order of hundreds of dollars; ~28% get zero reviews. What generative AI *did* invent is **volume without vision** — a flood of disclosed (and undisclosed) titles that look shippable, compete for the same discovery slots, and train players to treat the “AI Generated Content Disclosure” block as a quality hazard.

**Gameslop** is not “any AI use.” It is high-volume, low-intent product: generated filler assets, vague store copy, template loops, no distinctive taste, shipped because the tools made *something* possible. Players and press now use that word as a shorthand for that failure mode.

Data through mid-2026 says:

| Signal | Finding | Source class |
|---|---|---|
| Share of new releases with AI disclosure | ~11% (2024) → ~20% (2025) → ~31% (2026 YTD) | Full census (~53.6k titles) |
| Share of monthly *growth* in releases | ~60–90% attributed to AI-flagged games | Same census |
| Commercial conversion | AI-flagged games reach ≥100 reviews at ~55% the non-AI rate; ratio flat ~2 years | Same census |
| Controlled stigma effect (2025 paid games) | ~53% fewer first-month reviews after controls | Game Oracle study |
| Next Fest visibility | ~10% of top-100 demos disclose AI; ~19–20% of all fest demos tagged | Press audits, SteamDB |
| Player attitudes (core Steam fans) | 43% OK / 26% neutral / 31% negative; **8% hard boycott** | GameDiscoverCo ~3.8k survey |
| What players accept | Code helpers, placeholders, tedious tasks — **not** replacing art/writing/voice | Same survey freeform |

**Bottom line for this repo’s small paid Steam products:** AI as an *invisible efficiency tool* (exempt from disclosure after Valve’s Jan 2026 rewrite) is low political risk. AI as *shipped player-facing content* or *runtime generation* is a marketing and trust problem you must design for. Inventive AI-involving games survive when AI is the **mechanic or amplifier of a human vision**, not the substitute for one — and when disclosure is specific, bounded, and backed by obvious craft.

---

## 1. What “gameslop” means

### 1.1 From “AI slop” to “gameslop”

**AI slop** (broader internet term; Merriam-Webster / American Dialect Society Word of the Year for 2025 in several summaries) means high-volume generative content perceived as low effort, low meaning, optimized for attention or monetization rather than craft. **Gameslop** is the games-storefront specialization: titles that feel like content-farm products — Midjourney capsule art with broken anatomy, LLM store blurbs, asset-flip loops, zero authorial point of view.

Critical distinction that recurs across 2025–2026 commentary:

- **Tool use ≠ slop.** Solo developers have always used helpers (middleware, asset stores, procedural systems).
- **Absence of taste / curation / intent = slop.** The tell is not “AI was used”; it is “nobody was steering.”

Chandler Thompson’s framing (“gameslop is a taste problem”) and industry blogs converge: AI removed the *excuse* of scarce production capacity; it did not remove the need for design judgment. Discovery still suffers because tasteful and tasteless titles share the same shelf.

### 1.2 Why these games fail commercially (mechanisms)

Failure is usually overdetermined. Stack these:

1. **No product vision.** Prompt-to-product games answer “can we generate assets?” not “what fantasy does the player buy?”
2. **Store-page tells.** Capsule/header art with AI artifacts; keyword-stuffed descriptions; trailers that overpromise vs. the loop.
3. **Disclosure stigma as a proxy for quality.** Many buyers never read the full paragraph — they pattern-match “AI disclosure + cheap price + weak trailer” and bounce.
4. **Discovery crowding.** More shots on goal for everyone else means more noise for you; AI lowered the cost of firing blanks.
5. **Steam’s hit curve unchanged.** AI did not move the top-1% revenue concentration. More releases ≠ more winners.
6. **Review culture.** Negative reviews increasingly call out AI as a *reason* to refund/avoid, not only as a quality note — creating review-bomb-adjacent piles-on when a mid-profile title is caught with undisclosed or heavy AI art.
7. **Honest disclosers punished relative to cheaters.** Enforcement of false/missing disclosure is widely described as weak; players notice the incentive to hide.

Haro’s census punchline: AI tooling has **not** been a silver bullet. It enabled a large influx of small productions that still struggle like other small productions — while training the market to discount the AI flag.

---

## 2. Steam policy timeline & Content Survey (legal / compliance notes)

This section is **operational notes for Steamworks**, not formal legal advice. IP/copyright outcomes vary by jurisdiction and by how much human authorship remains in the work.

### 2.1 Policy arc

| When | Change |
|---|---|
| Early 2024 | Valve opens Steam more widely to AI-using games if developers promise content is not illegal/infringing; Content Survey gains Generative AI section; store shows **AI Generated Content Disclosure**. |
| 2024–2025 | Pre-generated vs live-generated split; live AI requires describing **guardrails**; player reporting path for illegal live AI output; **hard ban** on Adult Only Sexual Content that is live-generated. |
| Jan 16–17, 2026 (approx.) | Significant rewrite: focus is content **shipped and consumed by players**, not “efficiency gains” from AI-powered **dev tools** (e.g. coding assistants). |
| Mid-2026 | Retroactive flagging spike around the rewrite (~22% of significant-revenue AI games added the flag post-release in Haro’s Wayback analysis). |

### 2.2 Content Survey structure (official Steamworks)

Three mandatory sections before store/build review:

1. **General Content** — feeds rating-board style signals.
2. **Mature Content** — honesty required for customer preference filtering; disclose adult content even if inaccessible in build.
3. **Generative Artificial Intelligence Content** — player-facing AI content only (post-2026 clarification).

Official framing (paraphrase of Steamworks docs): modern engines have AI tools; **efficiency gains are not the focus**. Focus is AI used to create content that **ships with the game and is consumed by players** (artwork, sound, narrative, localization, etc.).

#### Pre-Generated

Any content created with AI help during development that ships and is player-consumed. Under the Steam Distribution Agreement you promise:

- No illegal or infringing content.
- Game consistent with marketing materials.

Valve evaluates AI output in prerelease review **the same way** as non-AI content against those promises.

#### Live-Generated

Content created with AI help **while the game is running**. Same rules as pre-generated, **plus** you must describe **guardrails** that prevent illegal content generation. Steam provides overlay reporting for suspected illegal live AI output.

#### Explicit hard line

**Adult Only Sexual Content + Live-Generated AI** — Valve states they will not ship this combination at this time (legal + customer-expectation risk).

#### Monetization note (official FAQ)

If live AI incurs per-call costs, you must manage access and collect payment via Steam-supported methods (bake into price, microtransactions, subscription, or DLC unlock) — you cannot offload that casually outside Steam’s commerce rules.

### 2.3 What requires disclosure vs. what does not (2026 practice)

| Use | Disclose? | Notes |
|---|---|---|
| AI art / audio / narrative / localization that ships | **Yes** | Pre-generated |
| AI store page, marketing, Steam Community assets | **Yes** | Explicitly in scope historically and still treated as player-facing |
| Live NPC dialogue / image / audio generation | **Yes** | Guardrails description required |
| AI-generated **code that ships as game content** | **Treat as disclosable** | Survey examples shifted; secondary legal summaries say Valve still treats shipped AI code as something players care about — when in doubt, ask Steamworks Support and disclose |
| Coding assistants, debugging, internal tools | **No** (Jan 2026) | “Efficiency gains” carve-out |
| Concept ideation that never ships | **No** | If it never becomes player-facing content |

### 2.4 Legal / IP risk notes (developer-facing)

- **Attestation shifts risk to you.** Checking disclosure boxes is a contractual promise to Valve that content is legal/non-infringing. Valve’s posture has long been: they will ship AI games *if you stand behind legality*.
- **Copyrightability of pure AI assets is weak.** U.S. Copyright Office guidance (2024–2025) repeatedly ties protection to human authorship. Purely generative assets with minimal human creative control may be unprotectable — competitors can copy them; your moat cannot be “we generated unique Midjourney characters.”
- **Training-data / likeness / trademark risk** remains on the developer. Guardrails matter for live gen; curation matters for pre-gen.
- **Lying on the survey** is a Steam Distribution Agreement problem (delisting / account risk), separate from copyright fights. Player trust collapses faster than Valve enforcement.
- **Survey edits after approval** require contacting Steam Support with what changed and how testers can access it.

---

## 3. Scale of the flood (2025–2026 data)

### 3.1 Sulka Haro census (~53,597 Games-category releases, mid-2023 → mid-2026)

Key quantitative picture:

- AI disclosure share of new releases: **~10.9% (2024) → ~19.9% (2025) → ~30.8% (2026)**.
- Non-AI monthly launches grew modestly (~1,030 → ~1,320); AI-flagged launches grew from ~0 to ~**530/month**.
- **60–90% of growth** in monthly releases is AI-flagged games (window-dependent).
- Trajectory scenario: AI-disclosed share could approach ~50% of releases around **2027–2028** if trends hold (not a prophecy — Haro frames it as scenario).
- Economics: top 1% ≈ **94%** of estimated revenue; median reviewed game ≈ **~$300** estimated; ~**28%** zero reviews.
- AI share of *sales* rose on **volume**, not per-game skill; within-cohort, AI games hit modest-success (≥100 reviews) at ~**55%** the non-AI rate, **flat for ~2 years**.
- Disclosed AI is overwhelmingly **visual** among flops (72% of flopped AI games mention AI art vs 57% of successes). Successes more often use voice/localization/text and write longer, hedging disclosures with human-oversight language.
- Truly AI-native gameplay (player-facing generation as the product) is a **tiny minority** of ~9,400+ flagged titles.

### 3.2 Game Oracle (Ross Burton) — stigma on paid 2025 releases

Sample: **9,879** paid games, Jan–Oct 2025, spam/high-frequency publishers filtered; **17.9%** AI disclosure.

Raw correlations:

| Metric | AI disclosed | Not |
|---|---|---|
| Median first-month reviews | 4 | 7 |
| Zero reviews | 19.8% | 15.2% |
| Median % positive (≥100 reviews) | 84.6% | 88.3% |

Causal-style result after controlling for publisher backing, developer experience proxy, game type, release month:

- **~53% reduction** in first-month reviews associated with AI disclosure (~47–58% CI in their writeup).
- Effect described as worse for **high-potential / experienced** teams (roughly **40–60%** sales-proxy hit in secondary coverage) — i.e. AI stigma hurts games that *would have* succeeded more than it explains why trash fails.

Caveats the authors own: disclosure is self-reported; reviews ≠ sales; unmeasured marketing/skill still bias; binary “any AI” flag mixes one AI painting with heavy gen pipelines.

### 3.3 Next Fest as the public flashpoint (esp. June 2026)

Press consensus mid-2026:

- SteamDB / Eurogamer-style counts: on the order of **~1,700 / ~8,700** fest titles tagged with generative AI ≈ **~19.5%**.
- PCGamesN audit of Valve’s **Top 100 demos**: **~10%** disclosed AI.
- Kotaku / Indiecator / Engadget narrative: hub pages and algo slots feel flooded; players want **native Steam filters**; honest disclosers feel punished; “resources excuse” disclosure language reads poorly.

Implication for demos: Next Fest is where the AI stigma is **most emotionally activated**. A thin AI-art demo is competing against thousands of peers in a week when journalists are actively hunting for slop.

---

## 4. Player sentiment (not a monolith)

### 4.1 GameDiscoverCo Steam Fan Snapshot AI module (fielded June 25–July 2, 2026)

~3,800 relatively committed Steam fans (biased toward engaged players — authors caveat this):

| Attitude to buying AI-disclosed games | Share |
|---|---|
| No big issues | ~43% |
| Neutral | ~26% |
| Negative | ~31% |
| …of which hard “won’t buy” | **8%** |

Disclosure attention:

- 44% read in detail, 45% glance, 11% ignore → **~89%** at least notice the block.

Trust:

- Only **17%** believe developers fully disclose audiovisual AI use; plurality think only “some” do.

Policy gap:

- **56%** want coding helpers (e.g. Claude Code) disclosed even though Valve’s 2026 rewrite exempts them; 8% say no; 37% neutral.

Freeform (~2,100 analyzable answers): **conditional acceptance** dominates (~51%). Acceptable cluster: coding/programming helpers, prototyping/placeholders, tedious/repetitive tasks. Strongest rejection: AI replacing human creativity in art, writing, voice, music.

### 4.2 How this reconciles with “review bombs” and outrage media

- Social media and journalist Next Fest pieces over-index the **angry minority + taste makers**.
- Survey data says most players are **conditional**, not absolutist — but **31% negative + 8% boycott** is still a large commercial tax on a small indie.
- Review bombs (coordinated pile-ons) are more likely when:
  - AI use was **hidden** then exposed;
  - AI replaces a **high-salience creative surface** (key art, voices, main quest writing);
  - The studio is **big enough to “owe” craft** (AAA / beloved indies get harsher moral accounting than anonymous $2 experiments);
  - Store presentation already looks like slop (artifacts, generic trailer).

Game Oracle’s finding that stigma hurts high-potential games more matches this moral accounting: players forgive (or ignore) trash either way; they punish betrayal of expected craft.

---

## 5. Discovery filters & storefront mechanics

### 5.1 What Valve shows today

- Public **AI Generated Content Disclosure** section on the store page (often below the fold).
- Content Survey + prerelease review.
- Mature-content preference systems are separate; AI is not currently a first-class “exclude from my Steam” preference in the same consumer-friendly way players demand.

### 5.2 What players / press demand

Repeated ask in 2025–2026 coverage:

- Native Steam search/browse filter: hide or show AI-disclosed titles.
- More prominent labeling (capsule badge) — controversial even among anti-AI players because it also marks careful AI-assisted games.
- Stronger enforcement against non-disclosers.

### 5.3 SteamDB stopgap

Since early 2025, SteamDB has supported filtering on the AI disclosure tag (commonly cited as excluding tag id **1368160** via URL params). Power users and journalists use this during Next Fest; casual Steam browsers mostly do not.

### 5.4 Practical discovery math for a small paid game

Steam still routes attention through wishlists, followers, review velocity, demo playtime, and editorial/algorithmic features. AI stigma hits several of those:

- Lower followers pre-release (Game Oracle: median followers ~half for AI-flagged).
- Lower first-month reviews → weaker algorithmic snowball.
- Next Fest demo browse polluted → higher CAC for attention even if your demo is good.

Counter-levers that still work (and matter more under flood conditions):

- **Pure category clarity** (this repo’s hard rule).
- Obsessive **gameplay footage** on the store (not AI key art as the hero).
- Demo that teaches the loop in &lt;3 minutes.
- Influencer/clip culture for vignette/horror (Game 1 lane).
- Specific, opinionated store copy (anti-LLM voice).

---

## 6. How an inventive AI-involving game avoids the slop label

“Inventive AI-involving” means AI is part of the **designed experience or production craft**, not a cost-cutting afterthought. Patterns that survive scrutiny in 2025–2026 discourse:

### 6.1 Make AI the *point*, or keep it invisible

Two viable strategies — mixing them poorly creates the worst of both worlds:

| Strategy | When it works | Disclosure posture |
|---|---|---|
| **AI-native fantasy** | The pitch is “talk to NPCs,” “generate your colony’s myths,” “AI dungeon master with rules,” etc. Players bought the AI. | Maximal, proud, specific; show guardrails and failure modes. |
| **Human-crafted product, quiet tools** | AI never appears as a creative surface; helpers stay in exempt tooling or heavily curated pipelines. | Minimal truthful survey answers; marketing leads with design, not AI. |

**Avoid:** “Handcrafted indie vibes” marketing + obvious AI capsule art + one-line disclosure. That reads as deceit.

### 6.2 Taste tests players already use

Players may not articulate model names, but they bounce on:

1. Capsule art anatomy / physics nonsense.
2. Same “AI sheen” lighting across unrelated assets.
3. LLM store description cadence (empty superlatives, no mechanics).
4. Voice lines with dead affect or inconsistent casting.
5. Narrative that loops, hedges, or contradicts itself.
6. Trailers that cannot show a coherent verb (“what do I *do*?”).

Your job is to fail those tests on purpose — in the good direction.

### 6.3 Human authorship must be legible

Signals that consistently reduce “slop” attribution:

- Named art direction / consistent palette and shape language.
- One sharp mechanical hook explained in one sentence.
- Devlogs, process clips, sketch → final comparisons.
- “We used X for Y; humans did A/B/C” disclosure.
- Patch notes that replace temporary AI assets rather than defending them forever.

Haro’s text scrape: successful AI-flagged games write **longer**, more minimizing, more “human-reviewed” disclosures than flops. That is not magic wording — it correlates with teams who treat the store page as reputation management.

### 6.4 Especially for live generation

If AI runs at runtime:

- Constrain outputs to a **designed possibility space** (schemas, tools, validated moves) rather than free chatbox chaos.
- Ship visible **guardrails** you can describe to Valve and to players.
- Budget for infra + Steam commerce for API costs.
- Never combine with Adult Only Sexual Content.
- Design for memorable *authored* moments; use genAI for variation inside a ruled system (the “AI DM with a rulebook” pattern), not as a substitute for level design.

### 6.5 Fit to this repo’s product sequence

Given [`GAME_PLAN.md`](../GAME_PLAN.md) priorities:

| Planned product | AI risk profile | Recommendation |
|---|---|---|
| **Game 1 — Tension / horror vignette** | High sensitivity to art/atmosphere authenticity; clip culture will amplify any AI tell | Prefer **no shipped AI art/audio**. If any AI used, keep it exempt tooling or fully redrawn. Do not lead with AI. |
| **Game 2 — Coin machine** | Physics/feel is the product; AI art stigma unnecessary | Same — human/readable arcade fantasy; AI not the pitch. |
| **Game 3 — Idle / particle tycoon** | Systems/juice matter; generative art more tempting and more “slop-coded” | Dangerous lane for AI key art. If AI ever appears, make it a *system* (e.g. generative particle recipes) with authorship, not Midjourney store dressing. |

Across all three: **do not mash “AI experiment” into a pure-category first game** unless the category *is* the AI experiment — and that would be a different product than the current plan.

---

## 7. Do / Don’t — AI-powered inventive games on Steam

### DO

1. **Start from a player fantasy and verb**, then decide if AI belongs. If you cannot pitch the game without mentioning Midjourney, you do not have a game yet.
2. **Treat Valve’s Content Survey as a contract.** Disclose pre-generated and live-generated uses accurately; describe live guardrails concretely (filters, classifiers, allowlists, human escalation, logging).
3. **Separate tooling from content.** Prefer AI for code assistance, debugging, production chores (often non-disclosable after Jan 2026) over shipping raw generative art.
4. **If you ship AI content, curate ruthlessly.** AI output is a draft. Style-lock, repaint, re-voice, rewrite until artifacts are gone.
5. **Write a specific disclosure.** Name modalities (“background textures only,” “localization drafts”), state human review, and state what is **not** AI. Successful pages do this; flop pages write 10 words.
6. **Lead the store with real gameplay video.** Capsule can be stylized, but the trailer must show the loop.
7. **Sound like a human in store copy.** Mechanics, stakes, tone — not SEO porridge.
8. **For AI-native designs, sell the fantasy honestly.** Players who want generative NPCs will tolerate disclosure; players who wanted hand-painted indie will not convert anyway — stop targeting them with confusing branding.
9. **Plan IP assuming pure AI assets are weak.** Put protectable originality in systems, characters with human authorship, audio direction, and code.
10. **Budget trust work:** playtests with AI-skeptical players; replace placeholder gen assets before wishlist pushes; prepare a factual response if someone screenshots an artifact.
11. **Use Next Fest only when the demo is crisp.** A sloppy AI-looking demo in a 19% AI fest is advertising the wrong cohort.
12. **Keep categories pure.** Flood conditions punish confused mashup pages harder.

### DON’T

1. **Don’t ship unedited generative key art** as the face of the product.
2. **Don’t use the “we’re a small team, please understand” disclosure.** It reads as an excuse for slop.
3. **Don’t hide AI and hope.** Exposure risk + review pile-on &gt; disclosure stigma for many mid-profile launches.
4. **Don’t claim “no AI” while shipping AI.** Instant credibility death.
5. **Don’t put live generative sexual content on Steam.** Hard policy wall.
6. **Don’t confuse procedural content with generative AI in the survey** — but also don’t play word games if an LLM/diffusion model produced shipped assets.
7. **Don’t assume AI volume is a business model.** Extra releases from the industry mostly raise *your* discovery noise floor.
8. **Don’t let AI write the design.** Homogeneous mechanics are how gameslop feels even when art is OK.
9. **Don’t rely on SteamDB-only audiences.** Most buyers never apply anti-AI filters — but journalists and activists do, and they shape early review narratives.
10. **Don’t treat Arc Raiders–scale exceptions as a plan.** Hits dominate AI revenue slices; your median outcome is still the median.
11. **Don’t outsource voice/music/main quest prose to raw models** if you care about the 31% negative cohort — those are the third rails in freeform answers.
12. **Don’t ship a “temporary AI asset” you will not replace.** Temporary becomes permanent under crunch, then becomes a patch-day apology.

---

## 8. Practical checklist before you touch Steamworks

- [ ] One-sentence fantasy + one-sentence verb (no AI required to explain).
- [ ] Inventory every AI touch: tool / asset / runtime.
- [ ] Map each to: exempt tool vs pre-generated vs live-generated.
- [ ] For each pre-generated item: human edit path documented; IP risk accepted.
- [ ] For live-generated: guardrails paragraph ready for Content Survey + public disclosure.
- [ ] Store capsule & trailer pass “no AI artifact” smell test with cold eyes.
- [ ] Disclosure draft: specific, bounded, names what humans made.
- [ ] Marketing does not imply a fully hand-painted atelier if that is false.
- [ ] Demo plan that showcases inventiveness (systems/feel), not asset quantity.
- [ ] Legal: trademarks/likeness; no infringing generations; adult-content rules checked.

---

## 9. Sources

### Primary / official

1. Valve — *Content Survey* (Steamworks Documentation). https://partner.steamgames.com/doc/gettingstarted/contentsurvey  
2. Valve historical AI-on-Steam policy coverage (GameDeveloper / GamesIndustry.biz, 2024) summarizing pre-generated vs live-generated, guardrails, and Adult Only Sexual Content prohibition — e.g. https://www.gamedeveloper.com/business/valve-welcomes-ai-games-onto-steam-but-only-if-devs-promise-they-aren-t-doing-anything-illegal-

### Data studies

3. Sulka Haro — *Three years of AI on Steam* (July 13, 2026). Census of ~53,597 releases. https://fragwyz.substack.com/p/three-years-of-ai-on-steam  
4. Sulka Haro — *AI flagged games on Steam, Part 2* (July 2026). https://fragwyz.substack.com/p/ai-on-steam-part-2  
5. Ross Burton / Game Oracle — *AI in Games: The Impact On Sales* (Dec 2025). ~53% review reduction after controls. https://www.game-oracle.com/blog/ai-part2  
6. Secondary summaries of Haro: Yahoo Tech / Games.gg coverage of 60–90% growth and 2024→2026 share ramp.

### Player research

7. Simon Carless / GameDiscoverCo — *What do Steam fans really think about AI in games?* (July 7, 2026). https://newsletter.gamediscover.co/p/what-do-steam-fans-really-think-about  

### Policy rewrite (Jan 2026)

8. PC Gamer — Steam AI disclosure form focused on player-consumed content, not efficiency tools. https://www.pcgamer.com/software/ai/steam-updates-ai-disclosure-form-to-specify-that-its-focused-on-ai-generated-content-that-is-consumed-by-players-not-efficiency-tools-used-behind-the-scenes/  
9. VGC — Valve significantly rewritten disclosure rules. https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-much-disclose-ai-use/  
10. GamesRadar — efficiency gains vs shipped content distinction. https://www.gamesradar.com/games/valve-softens-steam-ai-disclosure-to-distinguish-efficiency-gains-from-the-use-of-ai-in-creating-content-that-is-shipped-with-your-game/  

### Next Fest / press sentiment (2025–2026)

11. PCGamesN — ~10% of top Steam Next Fest demos disclose generative AI (2026). https://www.pcgamesn.com/steam/next-fest-2026-generative-ai  
12. Kotaku — *Steam Next Fest Is Flooded With AI Games And It Sucks* (June 15, 2026). https://kotaku.com/exploring-steam-next-fest-with-an-ai-blocking-extension-is-very-depressing-2000706695  
13. Indiecator — ~19.5% of Next Fest titles with AI disclosure; filter demand (June 16, 2026). https://indiecator.org/2026/06/16/steam-next-fest-has-an-ai-problem-and-players-cant-filter-it-out/  
14. Engadget — ~one fifth of Next Fest demos disclose generative AI (June 16, 2026).  

### Discovery / stigma / terminology

15. SteamDB AI disclosure filtering coverage (e.g. GamesCensor, Feb 2025) — tag exclusion workflow for generative AI disclosures.  
16. GameRant — indie discoverability under AI content wave. https://gamerant.com/steam-indie-games-ai-generated-content-discoverability/  
17. PC Gamer summary of Game Oracle stigma findings. https://www.pcgamer.com/software/ai/data-analyst-finds-ai-stigma-on-steam-can-reduce-the-number-of-reviews-a-game-gets-by-around-53-percent-and-the-reviews-it-does-get-are-more-negative/  
18. Wikipedia — *AI slop* (terminology, Word of the Year context, games shovelware note). https://en.wikipedia.org/wiki/AI_slop  
19. Chandler Thompson — *Gameslop is a taste problem*. https://chandlerthompson.dev/posts/gameslop-is-a-taste-problem/  
20. Goomba Stomp — *“Gameslop” vs. Greatness* (20% wave framing). https://goombastomp.com/gameslop-vs-greatness-navigating-the-20-ai-generated-steam-wave/  

### Practitioner / legal secondary (use with caution; verify against Steamworks)

21. Legal Moves Law Firm — *Steam AI Policy: What Every Game Developer Needs to Know* (survey mechanics, Jan 2026 rewrite notes, copyrightability pointers). https://legalmoveslawfirm.com/steam-ai-policy/  
22. StraySpark studio essays (disclosure tactics, gameslop framing, marketing “death note”) — practitioner opinion, not official Valve policy.

---

## 10. One-page takeaway for cmp07/Game-

You are planning **small, pure-category, paid desktop Steam games**. In that lane, the winning move under the 2026 AI climate is usually:

1. **Ship inventiveness in systems and feel**, not in generative asset volume.  
2. **Keep player-facing generative AI out of Games 1–2** unless the product is explicitly AI-native (currently it is not).  
3. If AI is used at all, prefer **exempt production tools**, then **obsessive human curation** for anything that ships.  
4. Write disclosures like a grown-up: specific, bounded, human-owned.  
5. Assume ~**30%+** of new neighbors on the store are AI-flagged and that journalists will hunt slop at Next Fest — so your store page must look *hand-steered* at a glance.

AI is not a cheat code for Steam revenue. It is a **credibility tax** unless your game’s inventiveness is obvious within seconds of the trailer.
