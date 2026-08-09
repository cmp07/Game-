# Echo Lattice — Launch Playbook

**Product:** Echo Lattice (Godot 4.3 desktop / Steam)  
**Pitch:** A labyrinth that rebuilds from your last thirty moves — you escape by rewriting your own habits, not by beating RNG.  
**Hero visual beat:** the origami **rewrite slam** (crease → lift → slot → rust bleed).  
**Companion kit:** [`presskit/`](presskit/), [`SOCIAL_CLIP_SCRIPTS.md`](SOCIAL_CLIP_SCRIPTS.md), [`INFLUENCER_OUTREACH.md`](INFLUENCER_OUTREACH.md), [`WISHLIST_MILESTONES.md`](WISHLIST_MILESTONES.md).

Use **L** = Steam release day (00:00 store timezone you ship under). Work backward; do not slip store-page assets past T−4 without a named owner.

---

## North-star launch goals

| Metric | Target by L+14 |
|---|---|
| Wishlists at L−1 | Hit the tier you chose in [`WISHLIST_MILESTONES.md`](WISHLIST_MILESTONES.md) |
| Launch-week review velocity | Enough verified playtime reviews to clear “Overwhelmingly / Very Positive” risk early |
| Trailer retention | ≥45% watch-through past the first rewrite slam (≈0:08–0:12) |
| Demo → wishlist conversion | Track; aim ≥15% of unique demo starters |

---

## T−8 weeks — lock the story

**Owner focus:** narrative, store positioning, capture pipeline.

- [ ] Freeze one-liner + short/long Steam descriptions (presskit `factsheet.md`).
- [ ] Lock capsule art direction to Field Ledger (paper / ink / rust — **no purple void**).
- [ ] Confirm Steam tags: Puzzle, Atmospheric, Minimalist, Singleplayer, Indie, … (max 5 primary + discovery).
- [ ] Schedule capture day: rewrite slam GIF sequences via `game/echo_lattice/tools/capture_press_gifs.sh`.
- [ ] Draft 15s / 30s social scripts ([`SOCIAL_CLIP_SCRIPTS.md`](SOCIAL_CLIP_SCRIPTS.md)).
- [ ] Build influencer long-list template ([`INFLUENCER_OUTREACH.md`](INFLUENCER_OUTREACH.md)).
- [ ] Decide price band ($4.99–$9.99 recommended for this density) + launch discount policy.
- [ ] Open Steamworks page in **Coming Soon**; upload placeholder capsule if needed.

**Exit:** store page can be described without inventing features that are not in the build.

---

## T−6 weeks — store page that converts

- [ ] Final header capsule, library capsule, small capsule, page background.
- [ ] 5–8 screenshots in store order: menu lockup → walk trail → **rewrite slam** → mid-act pressure → stars clear.
- [ ] Upload GIF-ready frame packs from `presskit/images/gif_sequences/` (or compiled GIFs/WebM).
- [ ] Short description ≤300 chars ending on the habit hook (“it learned you”).
- [ ] About-this-game: one paragraph pitch, then bullets (35 chambers / 4 acts, daily, stars, offline).
- [ ] System requirements from a real Windows export of `game/echo_lattice/`.
- [ ] Set release date window (or “coming soon” with dated wishlist push).
- [ ] Enable wishlist notifications; verify store URL in outreach docs.

**Exit:** stranger can wishlist from page alone; rewrite slam is visible above the fold (gif or screenshot #3).

---

## T−4 weeks — trailer + demo gate

- [ ] Cut **30s** trailer from social script B (slam is the mid-point punch).
- [ ] Cut **15s** vertical + square variants for Shorts / Reels / TikTok.
- [ ] Optional **60–90s** gameplay loop for Steam page (menu → chamber → slam → stars).
- [ ] Demo build: Act I teaching arc through first identity beat (or first 5–8 chambers); no spoilers for Act IV Nameplate.
- [ ] Demo depot + Steam Playtest / demo landing tested on clean Windows machine.
- [ ] Presskit zip draft: factsheet + logos + screenshots + trailer links.
- [ ] Soft outreach to 5 warm contacts (no embargo yet).

**Exit:** demo installs and returns to menu; trailer ends on title lockup + wishlist CTA.

---

## T−2 weeks — amplification

- [ ] Embargoed press mailer (presskit link + key policy) to shortlist.
- [ ] Influencer keys queued (Steam keys, not shared single key).
- [ ] Community posts: Steam news “How the rewrite slam works” with GIF sequence 01.
- [ ] Social cadence locked (3 posts/week until L−3, daily from L−3).
- [ ] Wishlist milestone creative ready (thresholds in milestones doc).
- [ ] Localization pass on store text (EN first; optional EN-GB polish only).
- [ ] Crash / performance smoke on min-spec + mid-spec Windows.

**Exit:** keys allocated; at least one external creator has the build.

---

## T−1 week — launch readiness

- [ ] Gold candidate build uploaded to Steam (default branch staged, not live).
- [ ] Achievements / cloud deferred OK — do not block launch on them (see changelog known gaps).
- [ ] Launch-day Steam news drafted + scheduled.
- [ ] Social posts scheduled for L−24h, L−1h, L+0, L+4h, L+24h.
- [ ] Discord / community Q&A slot booked for L+1 evening.
- [ ] Review-bomb / support triage rota (who answers Steam discussions).
- [ ] Pricing + any launch discount confirmed in Steamworks.
- [ ] Final legal: age rating questionnaire, privacy if needed, third-party notices.

**Exit:** “ship button” is a checklist of three human confirmations, not a surprise.

---

## Launch day (L)

**Hour −6 to 0**

- [ ] Set build live; verify download on clean account.
- [ ] Publish Steam news + store “Released” state.
- [ ] Pin wishlist→purchase thank-you + trailer on community hub.

**Hour 0–12**

- [ ] Post 15s slam clip + “Out now” on all channels (scripts in social doc).
- [ ] Notify creators under embargo; flip public tags.
- [ ] Monitor crash reports / first reviews; hotfix branch standing by (`week2` patch lane).

**Hour 12–24**

- [ ] Mid-day “IT LEARNED YOU” still (rewrite slam frame t≈0.55).
- [ ] Reply to every early review that asks a good-faith question.
- [ ] Capture 3 fresh community clips for quote-retweets (ask permission).

---

## L+1 → L+7 — hold the curve

- [ ] Daily: Steam discussions + review replies (30–45 min).
- [ ] Mid-week patch if blockers: save, input, softlock, slam readability.
- [ ] One “developer deep dive” post: Field Ledger art rules (link art bible pillars).
- [ ] Second influencer wave (puzzle / cozy-adjacent / short-form editors).
- [ ] Wishlist remnants → sale conversion creative (owners vs wishers).

---

## L+8 → L+14 — week-2 patches

**Patch philosophy:** fix friction that blocks the slam reading. Do not add Act V.

| Priority | Examples |
|---|---|
| P0 | Softlocks, broken checkpoint, missing save, black screen on boot |
| P1 | Slam timing illegible on low-end, star math confusion, daily seed timezone bugs |
| P2 | Juice polish, caption typos, accessibility (screen shake toggle if missing) |

- [ ] Ship **0.2.x** week-2 patch notes (3 bullets max public).
- [ ] Update presskit “Build” line + known issues.
- [ ] Plan first post-launch content teaser only if review score + wishlists support it (hard variants / daily cosmetics — not new genre systems).
- [ ] Retro: which social script won (15s vs 30s); archive losers.

**Exit:** build stable; playbook annotated with actual dates/owners for the next title in the sandbox.

---

## Asset map (this repo)

| Need | Path |
|---|---|
| Factsheet / boilerplate | [`presskit/factsheet.md`](presskit/factsheet.md) |
| Presskit tree | [`presskit/README.md`](presskit/README.md) |
| Social A/V scripts | [`SOCIAL_CLIP_SCRIPTS.md`](SOCIAL_CLIP_SCRIPTS.md) |
| Outreach CRM template | [`INFLUENCER_OUTREACH.md`](INFLUENCER_OUTREACH.md) |
| Wishlist tiers | [`WISHLIST_MILESTONES.md`](WISHLIST_MILESTONES.md) |
| GIF frame sequences | [`presskit/images/gif_sequences/`](presskit/images/gif_sequences/) |
| Capture tool | [`../../game/echo_lattice/tools/capture_press_gifs.sh`](../../game/echo_lattice/tools/capture_press_gifs.sh) |
| Design authority | [`../ECHO_LATTICE/00_OVERVIEW.md`](../ECHO_LATTICE/00_OVERVIEW.md), [`../ECHO_LATTICE/14_VISUAL_V2.md`](../ECHO_LATTICE/14_VISUAL_V2.md) |

---

## Roles (fill names)

| Role | Name | Backup |
|---|---|---|
| Release captain | | |
| Store page / capsules | | |
| Trailer editor | | |
| Community / reviews | | |
| Build / Steamworks | | |
| Press / keys | | |
