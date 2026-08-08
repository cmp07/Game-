# 11 — Echo Lattice: Store & Trailer

**Product:** Echo Lattice (working title, safe to launch under)
**Category:** Puzzle / adaptive labyrinth · singleplayer · Windows Steam · Godot 4
**Design source of truth:** [`docs/FIVE_GAMES_TO_BUILD.md` — Game 1](../FIVE_GAMES_TO_BUILD.md)
**Owner:** marketing (this document); design owns loop/verbs; audio owns identity
**Status:** ready to hand to store-page builder, illustrator, and trailer editor
**Doc position:** file 11 of the Echo Lattice workstream. It is self-contained; sibling files may add art bibles, PR kits, and post-launch cadence.

This is the store & trailer package. It is not the pitch deck, not the GDD, and not the community plan. Everything here is meant to survive contact with real assets: a Steam page builder pastes the copy blocks verbatim, an illustrator executes the capsule from the brief, a video editor cuts the trailer to the beat sheet, and the producer runs the wishlist and demo plans against the checkboxes below.

Two rules govern every line of copy in this file:

1. **One concrete image per paragraph.** If a paragraph has no specific verb or visible object, cut it.
2. **The mechanic is the marketing.** Echo Lattice sells the sentence *the maze is a transcript of how I walked*. Every asset must earn that sentence, not decorate it.

The anti-slop policy at the end is not decorative. It is the acceptance test.

---

## 1. Positioning (internal)

Echo Lattice is a top-down puzzle labyrinth where the level rebuilds itself, deterministically, from a hash of the player's last thirty moves. It is not a roguelike loot crawl, not a generative AI toy, and not a rhythm game. It reads on screen as: walk a clean corridor; hit a checkpoint; the walls slam into the shape of your own footprints.

The commercial claim we are testing: players will pay $5.99–$8.99 for a puzzle whose main character is their own habit. The proof is not in adjectives; it is in a demo where a stranger walks two chambers and, at the second checkpoint, says *wait, I did that*.

Everything else — the tagline, the capsule, the trailer, the tag order — exists to protect that ten-second moment on the store page and in the first minute of the demo.

Do not sell mystery, lore, story, or difficulty. Sell recognition.

---

## 2. Short description (Steam, ≤ 300 characters)

Steam displays this under the header capsule and in search rows. It is the single most-read sentence in the product's life. It must land the mechanic without asking the reader to guess.

**Primary (chosen):**

> A labyrinth that studies your last thirty moves and rebuilds itself in that shape. To escape, change how you walk. No dice, no combat, no story — only your own footprints, learning back.

Character count: 219. Room to grow if legal or localization needs it.

**Alternate A (punchier, for A/B test after page live):**

> Walk thirty tiles. At the thirty-first, the walls slam into the shape of your path. Escape by rewriting your own habits. A deterministic puzzle labyrinth with a memory.

Character count: 176.

**Alternate B (more explicit about genre, for markets where "puzzle" underindexes):**

> A top-down puzzle where the maze is a transcript of how you walked. Every checkpoint reads your last thirty moves and rebuilds the walls. The only way out is to walk differently.

Character count: 192.

**Why the primary wins.** It contains the whole game: (a) a specific number ("thirty"), (b) a specific action ("walk"), (c) a specific twist ("rebuilds itself in that shape"), (d) a promise ("change how you walk"), and (e) the honesty triplet ("no dice, no combat, no story") that pre-qualifies the audience and blocks a class of refund-inducing wrong expectations. Alternate A is stronger for trailers and thumbnails; alternate B is stronger for non-English markets where "puzzle" already signals the shelf.

**Do not** ship a short description that begins with "In Echo Lattice, you will…" or "Explore a mysterious…" or any sentence that could describe a different game.

---

## 3. Long description (Steam "About This Game")

Steam's long description is one block with a small amount of BBCode. It should read top-down: hook, mechanic, honesty, features, tagline. The player should be able to stop reading at any paragraph and still know whether to buy.

The copy below is the master. It is written to be pasted, not edited. Line breaks are intentional.

### 3.1 Master long description

> **A labyrinth that learns your handwriting.**
>
> You walk. Thirty tiles later, a checkpoint flashes and the walls close on the exact shape of your path. The corridor you paced twice is a wall now. The dash you leaned on is a spike. The maze is a transcript of how you walked, and the only way out is to walk differently.
>
> **What you do**
>
> Four directions and one interact. That is the whole control set. There are no weapons, no dice, and no story to read. There is a chamber, a checkpoint, a door, and the record of your last thirty moves. Every chamber ends with the room rewriting itself from that record and asking you to try again as a slightly different person.
>
> **Why it is not another random maze**
>
> Echo Lattice is deterministic. Same seed, same thirty moves, same maze. Two players in the same seed will build two different levels because they walked differently. A ghost of your last run stays on screen, so you can see the habit the room is about to punish before it punishes you. Screenshots are worth the same to you as they are to a streamer, because the wall on screen is a signature.
>
> **Features**
>
> [list]
> [*] A move-buffer engine that hashes your last thirty inputs into an authored tile grammar. Deterministic. Offline. No network calls, no generative AI, no lore engine.
> [*] Forty-eight handmade chambers across four wings, each wing introducing one new transform: mirror, rotate, thicken, invert.
> [*] Ghost replay of your previous attempt, always on. Race yourself, or watch yourself lose and pick a different verb next time.
> [*] A habit profile that reads how you tend to move (dash-heavy, loopy, hesitant, orthogonal) and biases which transform packs the game offers next.
> [*] A daily seed shared with everyone on Steam. Same room signature, thousands of different rebuilds.
> [*] Full keyboard and controller support, one-handed and hold-to-walk options, colorblind lattice palettes, and a mandatory readability legend.
> [*] Level editor and Steam Workshop after launch, so the community can author chambers that talk back to their own habits.
> [/list]
>
> **What Echo Lattice is not**
>
> It is not a roguelike loot crawl. It is not a dungeon RPG. There is no combat, no inventory, no dialogue, and no procedurally generated story. The maze is generative; the writing is not. If you want a chatbot dungeon, this is not that game.
>
> **Sessions**
>
> A wing takes fifteen to forty minutes. Most players finish the campaign in six to nine hours. The daily seed, ghost races, and the editor extend that indefinitely without asking you to grind.
>
> **The line the game keeps saying to you:**
>
> *It learned you.*

Word count: ~320. Length is deliberate. Steam's own conversion data has consistently favored short, front-loaded "About This Game" blocks over the twenty-bullet wall.

### 3.2 The "About This Game" alternative for reserved markets

Some region storefronts strip BBCode differently. Ship a plain-text version of the same block with hyphen bullets and no bold. Do not translate the tagline "It learned you." word-for-word in every locale; give localizers three permitted variants (see §11).

### 3.3 Feature bullets, standalone (for keys / press one-pagers)

These are the reusable bullets. They must survive being read alone.

- Walk thirty tiles. The thirty-first is your own path, weaponized.
- Deterministic rebuilds from your last thirty moves. Two people, same seed, different mazes.
- Four directions, one interact, forty-eight handmade chambers.
- Ghost of your last run always on screen. See the habit before it eats you.
- Daily seed shared with everyone on Steam.
- Level editor and Workshop after launch.
- No dice, no combat, no story engine, no generative AI worldbuilding.

Rule: never ship a bullet that could describe another game on Steam. If it could describe *Hades*, cut it.

---

## 4. What Echo Lattice is not (public + internal)

Steam refunds cluster around expectation mismatch. We front-load the "not" list because the demo will show fewer minutes than the store page will be read, and one wrong assumption ruins a review. This block belongs at the bottom of the store description and in the demo's title screen.

Public copy (repeatable in press kit):

- Not a roguelike loot crawl. There is no gear, no run-based DPS, no boss.
- Not a horror game. There is tension, not jump scares.
- Not a chat-based AI dungeon. The maze is generative; the writing is not.
- Not a rhythm game, though the audio pitches with your step cadence.
- Not multiplayer. Ghost races are asynchronous, against yourself or a friend's seed.
- Not a cozy toy. It reads clean, but it will grade you.

Internal-only:

- Not sold on lore. If the wiki team gets ahead of the design team, that is a marketing failure, not a community win.
- Not sold on difficulty. "Hard" is a subtype; "revealing" is the pitch.
- Not sold on "one more run" language. Meta is a byproduct, not the hook.

---

## 5. Tags

Steam gives twenty tag slots. The top five drive the discovery queues. Tag order is a marketing decision, not a fandom vote; we lock the first ten before page publish and let the community reorder from eleven onward.

### 5.1 Locked top five (in order)

1. **Puzzle** — home shelf. Non-negotiable.
2. **Procedural Generation** — the mechanical claim. Distinctive in a shelf otherwise dominated by handcraft.
3. **Minimalist** — visual identity signal. Blocks readers who bounce off maximalist pixel art.
4. **Singleplayer** — pre-empts the co-op / multiplayer expectation created by "labyrinth."
5. **Atmospheric** — the audio identity. Also carries readers over from short-vignette shelves.

### 5.2 Slots six through ten (locked at launch)

6. **2D** — filter accuracy.
7. **Top-Down** — filter accuracy; also a strong subgenre.
8. **Difficult** — honest signal; keeps the wrong player away.
9. **Replay Value** — the daily seed, ghost races, and grammar packs earn it.
10. **Score Attack** — earned by ghost race and daily seed leaderboards. Add on the day leaderboards ship.

### 5.3 Slots eleven through twenty (community-editable pool)

Ordered by our preferred priority; Steam users will reorder, and that is fine:

11. **Level Editor** (add the day the editor ships)
12. **Choices Matter**
13. **Abstract**
14. **Indie**
15. **Psychological**
16. **Turn-Based Strategy** (only if the movement is committed grid-step; leave off if the final feel is real-time)
17. **Perma Death** (only if the campaign uses run-fail; else omit)
18. **Short** (only if median session ≤ 45 min after tuning)
19. **Dark**
20. **Cerebral**

### 5.4 Tags we deliberately reject

- **Roguelike / Roguelite.** Bait. Purist subreddits will punish the page. The design is habit-conditioned PCG, not run-based meta-progression.
- **Dungeon Crawler.** Wrong shelf. Recruits players who want combat.
- **RPG.** Wrong shelf entirely.
- **Story Rich.** There is no story engine. Do not lie.
- **Casual.** Understates the game and pulls the wrong buyer.
- **Adventure.** Too broad to help; dilutes puzzle signal.
- **Horror.** There is dread, not horror. Wrong reviewers show up if we claim it.
- **AI Generated Content.** Not applicable. Do not claim it even ironically.

### 5.5 Tag audit cadence

- **Pre-page publish:** lock tags 1–10.
- **Two weeks after page live:** review incoming user tags; keep the pool at twenty; remove any tag that pushes us into a shelf we don't want.
- **Next Fest week:** freeze the tag list. No experiments during the fest.
- **Launch week:** freeze again.
- **Every eight weeks post-launch:** re-audit.

---

## 6. Trailer beat sheets

Steam autoplays trailers **muted** by default, so the first five seconds must sell without audio. We are shipping three cuts, each with a different job.

### 6.1 Announce trailer — 60 seconds

Job: introduce the mechanic and earn a wishlist. Assumes the viewer has never heard of Echo Lattice.

| Time | On screen | Audio | On-screen text |
|---|---|---|---|
| 0:00–0:03 | Black frame. A single ghost trace draws itself across the screen, left to right, one tile per beat. | Silence except a single wooden footstep tick per tile. No music. | none |
| 0:03–0:05 | Cut to a top-down white lattice. One dot enters from the left and walks four tiles. | First quiet ambient tone enters, low. | Small lower-left, one line: **"You walk."** |
| 0:05–0:12 | The dot continues; the trace we saw in 0:00–0:03 overlays as a faint ghost line. Camera holds. | Ambient tone builds one octave. Still no music. | none |
| 0:12–0:15 | A checkpoint square pulses under the dot. **One frame of white.** Walls slam inward, forming a corridor identical to the ghost trace. | Single low percussive hit at the frame of white. Silence after. | Center, held for one second: **"It learned you."** |
| 0:15–0:25 | Split screen, three panels. Three different runs in the same seed. Three different mazes at collapse. | Ambient bed returns, one instrument added. | Small lower-left, sequential: **"Same seed."** → **"Different walkers."** → **"Different maze."** |
| 0:25–0:35 | Transform reveal. One dot per shot. Mirror transform: the trace flips before it becomes wall. Rotate: it turns ninety degrees. Thicken: it doubles. Invert: the trace becomes open, everything else closes. | Music sits under, no melody yet. Each transform gets its own foley note (metallic click, paper crease, glass tap, low bell). | Small, one word per shot: **"Mirror." · "Rotate." · "Thicken." · "Invert."** |
| 0:35–0:45 | Ghost race. Two dots on the same lattice: today's you and yesterday's you. Yesterday runs into a wall shaped like yesterday's habit. Today edits and passes. | Music resolves into a single sustained chord. First and only melodic beat. | Small lower-left: **"Race yourself."** |
| 0:45–0:55 | Static shot: a finished chamber whose walls spell, unmistakably, a looping path signature. Camera holds. No motion. | Chord holds. One footstep. | Center, held: **"A puzzle labyrinth about the way you walk."** |
| 0:55–0:60 | Logo lockup, single accent-color pixel drips from the L in Lattice. Steam wishlist prompt. | Chord decays. | **Echo Lattice** · wishlist mark · "2026" |

Rules for the editor:

- No text on frames 0:00–0:03. The ghost trace does the work.
- The word "**learned**" must land on the exact frame of collapse. Do not soften with a fade.
- Do not use any voiceover. This game has no dialogue.
- No music with a hook. The chord in 0:35 is the entire melodic budget.
- No footage of menus, tutorials, or numbers going up. Ever.

### 6.2 Launch trailer — 90 seconds

Job: convert wishlists to sales. Assumes the viewer has seen the announce cut or the mechanic once.

| Time | Shot | Notes |
|---|---|---|
| 0:00–0:05 | The 0:12–0:15 collapse from the announce trailer, extended by one frame. Cold cold cold open. | Muted-safe. Text: **"It learned you."** |
| 0:05–0:20 | Fifteen-second supercut: fifteen collapses, one per second. Each collapse is a different habit; each wall shape is recognizably geometric. | Rhythm carries. No text. |
| 0:20–0:35 | Habit profile UI reveal, thirty seconds of legibility: dash bar filling, loop bar filling, hesitancy bar filling, transform pack shifts on screen in response. | Text bottom: **"The maze reads how you move."** |
| 0:35–0:55 | Two-player daily seed. Split screen of two anonymous ghost paths on the same daily. Two visibly different rebuilds. Cut to a leaderboard tile. | Text: **"Daily seed, shared with Steam."** |
| 0:55–1:05 | Editor tease. A designer hand places three tiles; the grammar completes a chamber. Fast. | Text: **"Level editor at launch."** |
| 1:05–1:20 | Three critic-style quote frames (real quotes only, no fabricated pull quotes). | Only include quotes that mention the mechanic. No adjective-only quotes. |
| 1:20–1:28 | Beauty pass: three static chambers, one per accent color option. Held on the last for two beats. | Text: **"Six wings. Forty-eight chambers."** *(Adjust to shipped count.)* |
| 1:28–1:30 | Logo. Price. Date. Wishlist / buy. | Center-lock. |

### 6.3 Next Fest cut — 30 seconds

Job: run inside the Steam Next Fest event during the fest livestream slot. Assumes the viewer will not click through to read.

| Time | Shot | Text |
|---|---|---|
| 0:00–0:05 | The collapse (same as announce 0:12–0:15). | **"It learned you."** |
| 0:05–0:15 | Three chambers, three collapses, one seed. | **"Same seed. Different walkers. Different maze."** |
| 0:15–0:25 | Ghost race, ten seconds. | **"Race yourself."** |
| 0:25–0:30 | Logo. Demo-live badge. Wishlist mark. | **"Play the demo. Steam Next Fest."** |

### 6.4 Trailer specifications (delivery)

- Master: 1920×1080, 30 fps, MP4 H.264, ≤ 100 MB, stereo 48kHz AAC at −14 LUFS integrated.
- Muted-safe first five seconds: verified by turning system audio off before final approval.
- Captions: full closed-caption `.srt` for all on-screen text and any diegetic sound cues. This is the accessibility floor, not a nice-to-have.
- Thumbnail: single frame from the collapse (0:12 in the announce cut). No text baked into the thumbnail.

---

## 7. Capsule and screenshot brief

This section is written for the illustrator and screenshot editor. It is a specification, not a mood board.

### 7.1 Visual system

- **Palette.** Deep near-black background `#0B0B0D`. Lattice white `#F2F0E8`. One accent color, "signal orange" `#FF5F1F`. A single desaturated grey for ghost trace `#7C7C82`. That is the entire palette. Every asset uses these four values and nothing else.
- **Type.** Title lockup in a geometric sans (e.g. an open-source face like *Space Grotesk* or *Inter Display*), tight tracking, all lowercase for the wordmark, uppercase for section labels. Never use an ornate or "mysterious" typeface. This is a diagram, not a poster.
- **Motif.** A grid, four directions, one accent element that "infects" the tiles the player overused. The infection is the brand.
- **Do not.** Do not depict a character face. Do not depict weapons. Do not use fog, particles, blood, chains, runes, or crystals. Do not put a "TRY AGAIN" graphic on the capsule. Do not put review scores on the capsule.

### 7.2 Capsule specifications

Steam capsule slot inventory (all required for a full page):

| Slot | Size (px) | Focal element | Text plate |
|---|---|---|---|
| Small capsule | 231×87 | Corner of a grid with three signal-orange tiles snapping into a wall diagonal. | Wordmark only, right-aligned, single line. |
| Header capsule | 460×215 | Half-open lattice on the left; walls collapsing into the ghost's zigzag on the right. Player dot mid-frame. | Wordmark lower-left; no tagline. |
| Main capsule | 616×353 | Full grid interior. Left half: player mid-stride with ghost trace behind them. Right half: walls collapsed into the exact silhouette of the ghost trace. Signal orange drips from three overused tiles. | Wordmark lower-right; tagline `it learned you.` half-size beneath. |
| Library capsule (vertical) | 600×900 | Portrait rotation of the main capsule motif: player-dot top-third; wall bloom bottom-third; ghost trace connects them like handwriting. | Wordmark mid-height, centered. |
| Library hero | 3840×1240 | Panoramic corridor of three chambers wide. Chamber one: open. Chamber two: transformed (mirror). Chamber three: collapsed. Player-dot walking from chamber one into chamber two. | No text; hero uses separate logo overlay. |
| Library logo | 1280×720 | Wordmark on transparent, safe area centered. | Wordmark only. |
| Page background | 1438×810 | Full-bleed lattice at 30% opacity, no player, no collapse; pure texture. | None. |
| Community icon | 184×184 | A single signal-orange tile embedded in a monochrome grid. | None. |
| Broadcast image | 1080×1080 | Same as main capsule composition, recomposed square. | Wordmark bottom. |
| Screenshots | 1920×1080 ×6 | See §7.3. | None on any screenshot. |

Delivery format: PNG-24 with transparency where required, sRGB, no ICC profile embedded. Provide layered PSD or `.aseprite` source for the main capsule and library capsule.

### 7.3 Screenshot slate

Six screenshots, in this exact order on the page. Each one earns a specific claim.

1. **The collapse.** A wide chamber shot at the frame the walls slam. Ghost trace faintly visible. This is the header image and the whole pitch.
2. **The habit profile.** A clean HUD screen with four bars (dash, loop, hesitate, orthogonal) and the current transform pack. Legible from a Steam thumbnail.
3. **Ghost race.** Two dots on the same lattice, one player color, one grey, mid-run.
4. **A transform reveal.** Before/after of a mirror transform, split by a thin accent-color hairline.
5. **The daily seed.** Two chamber miniatures with the same seed string overlaid, side-by-side, so the reader sees "same seed, different maze" without a caption.
6. **The editor.** A single tile being placed by the cursor and the grammar completing the surrounding three tiles automatically.

Each screenshot must survive at 128×72 thumbnail size in the Steam library. If a screenshot depends on a caption to read, it is disqualified.

### 7.4 GIFs for social

- **10-second collapse loop.** Walk in, checkpoint, collapse, hold on the shape. Perfect loop back to the walking-in frame.
- **6-second ghost race.** Two dots, one dies on a wall, the other threads through. No text.
- **8-second transform.** Same chamber, mirror → rotate → thicken → invert, hard cut between each.

Each GIF ≤ 2 MB, ≤ 480 px on the long edge, 24 fps. Ship as MP4 alternates for Twitter, Bluesky, and Discord embeds.

---

## 8. Wishlist plan

The plan below is a runway, not a schedule. Its unit of time is *milestone shipped*, not calendar week. Every milestone has a wishlist gate — if we do not clear the gate, we do not advance to the next milestone until we understand why. The absolute numeric targets below are calibrated to a solo Godot puzzle in the $5.99–$8.99 band; they will be tuned once the demo has one week of live data.

### 8.1 Milestones

| Milestone | Gate condition | Wishlist target |
|---|---|---|
| **M0 — Coming Soon page live** | Store page passes internal review against §1–§7 and §11. Announce trailer approved. | 0 (baseline) |
| **M1 — Announce week** | Public announce trailer live for seven days; three targeted communities posted (see §8.2). | ≥ 2,000 wishlists |
| **M2 — First playable clip week** | A single ten-second collapse GIF (§7.4) tests above baseline on at least one channel. | ≥ 5,000 cumulative |
| **M3 — Demo private beta** | Twenty external playtesters complete wing one; twelve of them describe the mechanic unprompted using the word *my* or *me*. | ≥ 8,000 cumulative |
| **M4 — Steam Next Fest opens** | Demo build passes §9 acceptance. Broadcast trailer (§6.3) submitted to Valve on time. | ≥ 15,000 cumulative before the fest, +10,000 during |
| **M5 — Next Fest close** | Post-fest survey run. Streamer picks harvested. Demo v1.1 patched inside seven days. | +10,000 cumulative |
| **M6 — Launch day** | Launch trailer (§6.2) live; six screenshots refreshed; press embargo lifted. | ≥ 40,000 cumulative |
| **M7 — First patch week** | Editor beta rolls to owners; first Workshop chambers featured. | +5,000 |

The M6 target is not a promise. It is a decision point: below 25,000 cumulative wishlists at launch, we defer the launch trailer's paid promotion by two weeks and audit the store page before spending on discovery.

### 8.2 Channels (owned and targeted)

Owned:

- Steam page (single greatest wishlist driver by an order of magnitude — nothing beats being on Steam).
- Devlog on the studio site with an RSS the Steam page links to.
- Discord for playtesters; kept small and focused on chamber testing, not community management theater.
- Bluesky and Mastodon for the collapse GIF cadence. Twitter/X is optional; do not chase engagement metrics there — it does not move Steam wishlists for a puzzle at this price point.

Targeted (posted intentionally, not sprayed):

- **r/PuzzleGames** for the mechanic reveal. Post the collapse GIF and a single sentence: *deterministic maze rewritten from your last thirty moves*. No self-promotion tone. Respond to every comment for the first six hours.
- **r/IndieDev** for the transform reveal, framed as a devlog on the grammar system.
- **r/proceduralgeneration** for a technical write-up of the move-buffer → grammar pipeline. This audience will spot AI-slop and reject us; write it straight.
- **Hacker News** for the technical write-up, timed to a Tuesday morning US time. Do not include marketing language in the title.
- **Discord servers** with puzzle-friendly moderators (curated list, five servers). Ask before posting.
- **YouTube devlog** cross-post if a devlog exists. Do not make a devlog for the sake of it.

Do not:

- Do not buy TikTok engagement.
- Do not seed reviews.
- Do not use "wishlist us!" language in every post. Every third post is the ceiling.
- Do not ask streamers for coverage before the demo is stable.

### 8.3 Curator and press outreach

- Send fifty Steam keys before Next Fest to curators whose most recent five reviews include one of: minimalist puzzle, procedural generation, or short session games. Do not include curators whose feed reads as key-farming.
- Send twenty press-list emails at announce, twenty at demo, and forty at launch. Each email includes: one line pitch, one collapse GIF, one screenshot slate, the press kit URL, and one honest sentence about who this game is not for. No exclusives; no embargo unless a specific outlet earns one.
- Do not use PR services that mail-merge. This is a small game with a specific hook; a mail-merge send will be ignored by exactly the desks we want.

### 8.4 Wishlist quality signal

Wishlist count alone is a vanity number. Track three signal metrics weekly from the moment the page is live:

- **Deletes-to-adds ratio.** A healthy puzzle sits under 10% weekly. Above 20% for two consecutive weeks means the page is over-promising.
- **Median country distribution.** If more than 60% is one country in month one, we are only visible to one algorithm slice. Diversify posts.
- **Add-source mix (Steam page vs external).** After Next Fest, the mix should shift toward Steam-page-driven. If it does not, our on-Steam visualization is not converting; audit the capsule.

---

## 9. Next Fest demo scope

Steam Next Fest is a one-week fest window with a demo playable to anyone. The demo is a marketing surface. It is not a preview build, not a beta, and not a slice of the campaign. It is its own product with its own acceptance criteria.

### 9.1 Scope — what is in the demo

- **Wing 1 in full.** Twelve chambers. Introduces walking, checkpointing, the collapse, and the mirror transform. No later transforms.
- **The habit profile UI in read-only form.** The player sees the bars fill but does not spend anything.
- **Ghost of last run**, on by default. This is the mechanic's proof.
- **One daily seed** during the fest week, shared with everyone who has the demo. The seed rotates at 10:00 UTC.
- **Exit survey**, four questions, one screen (see §9.4).
- **Localization: English + one European language + one CJK language** (choose the CJK language whose Q1 wishlist traffic ranks highest at demo time).
- **Full keyboard, controller, colorblind palette, and hold-to-walk.**
- **Wishlist prompt on completion** of wing 1, once, non-annoying.

### 9.2 Cut — what is not in the demo

The following are deliberately withheld, and cutting them is a marketing choice, not a scope failure:

- Wings 2–4.
- Rotate, thicken, invert transforms.
- Level editor.
- Workshop.
- Leaderboards beyond the daily seed's own top-100 view.
- Achievements. Demos should not grant campaign achievements.
- Any "coming soon" splash for post-launch content.
- Any storefront links other than the wishlist button.

### 9.3 Acceptance criteria

The demo does not ship until every one of the below is true. This is the actual acceptance list, not a wish list.

- Ten external playtesters walk the first two chambers cold. At least seven of the ten, without prompting, use the word *my* or *me* to describe what happened at the first collapse.
- Median completion time for wing 1 lands between 22 and 35 minutes across those playtests. Under 15 means the mechanic is not landing; over 45 means the puzzles are unclear.
- Crash-free session rate ≥ 99.5% across 100 sessions on a Windows 10 baseline, a Windows 11 baseline, and a Steam Deck baseline.
- Save/load survives an alt-tab, a system sleep, and a controller unplug.
- All on-screen text passes the anti-slop review in §10.
- Trailer 6.3 cut is ready and captioned.
- Store page reflects the demo as playable and the exit survey is live.

### 9.4 Exit survey (in-game, four questions, one screen)

The survey opens once, on the final door of wing 1, and never again. It is skippable. Data goes to a local file, uploaded only with an explicit "send" click.

1. **In one sentence, what does Echo Lattice do?** (free text, 240 char)
2. **Would you buy this at $6.99?** (Yes / No / Maybe / I need to try more)
3. **What was the moment you understood the game?** (choose one: first walk, first collapse, first transform, first ghost race, I did not)
4. **What would have made you close the demo?** (choose up to two: too abstract, too hard, too easy, controls, art, audio, nothing)

Q1 is the only one that matters. If most players' answers do not contain a variant of *the maze copies me* or *my walking builds the level*, the whole marketing package failed and the store page needs a rewrite before launch. Q3 tells us which trailer beat to lead with post-fest.

### 9.5 During-fest cadence

- **Day 0 (fest opens).** Broadcast trailer live in the fest's featured slot. One reddit devlog post about the fest launch. Discord AMA that evening.
- **Day 2.** Post the top three exit-survey Q1 answers, unedited, on the store page as a "what players said" pinned news post. No adjective-added quotes.
- **Day 4.** Livestream a developer play-through, unnarrated except for showing off the ghost race and the daily seed. No sales pitch.
- **Day 7 (fest closes).** Publish a one-page post-mortem: wishlists gained, survey Q1 summary, top three bugs. Ship a demo patch inside seven days.

### 9.6 Success metrics

The fest is judged one week after it closes, not on the day it closes.

- **Primary:** demo-to-wishlist conversion ≥ industry median for puzzle games in the fest cohort (self-benchmarked from Steamworks; do not chase a fixed absolute number).
- **Primary:** ≥ 60% of Q1 survey answers contain a *my/me* variant.
- **Secondary:** ≥ 25% median session length above the wing 1 average. This is a proxy for players re-running the wing to hunt the daily seed.
- **Secondary:** ≥ 20 curator reviews requested unprompted.

Failure modes and responses:

- If demo-to-wishlist is < 50% of median: page is over-promising; rework the capsule and short description before launch.
- If Q1 miss is severe: the mechanic is not legible in-game; rework the first two chambers, not the copy.
- If crash rate is worse than 1%: hold the launch trailer.

---

## 10. Anti-slop policy (acceptance test for every asset)

Every line of copy, every trailer beat, every capsule variant, every social post must pass all fifteen tests below before it ships. This is an actual gate.

1. **No unearned superlatives.** Cut *stunning*, *breathtaking*, *unique*, *revolutionary*, *iconic*, *legendary*, *epic*, *ultimate*, *definitive*, *masterpiece*.
2. **No filler intensifiers.** Cut *truly*, *utterly*, *literally*, *wholly*, *simply*, *just*, *absolutely*, *completely*, *incredibly*, *insanely*.
3. **No AI-marketing verbs.** Cut *unleash*, *harness*, *empower*, *elevate*, *reimagine*, *redefine*, *transform your experience*, *seamlessly*, *effortlessly*, *dive into*, *embark on*, *step into*, *immerse yourself*, *lose yourself*, *prepare to*.
4. **No hedged claims.** *A kind of*, *something like*, *sort of*, *a bit of a* are banned. Say the thing.
5. **No adjective towers.** Two adjectives in a row is the maximum. Three is a rewrite.
6. **One concrete image per paragraph.** If a paragraph has no visible object or specific verb, delete it.
7. **No em-dashes as commas.** An em-dash indicates a specific rhetorical break, not a rhythm crutch. Two per paragraph is the ceiling. Use commas and periods first.
8. **No sentence begins with *In [game name]*.** It is a lazy opener and a slop tell.
9. **No "features" bullet consists only of adjectives.** Every feature bullet contains a verb the player performs or a specific noun the game contains.
10. **No fabricated critic quotes.** Ever. Only quotes that exist, from named reviewers, in writing.
11. **No numbers without units.** "Hundreds of hours" is banned. "Six to nine hours to finish" is fine.
12. **No genre bait.** If the tag is not accurate, do not use it, even if it drives clicks.
13. **No apologetic language.** Cut *just a puzzle*, *only a small game*, *humble*, *tiny*, *little*.
14. **Read aloud.** Every finished asset is read aloud by one person other than the writer. If the reader stumbles at the same clause twice, that clause is rewritten.
15. **The one-sentence test.** Every asset must survive being reduced to one sentence. If the one-sentence version is not the mechanic, the asset is decoration and gets cut.

Additionally, the following slop signals mean the asset is rejected on sight:

- Every paragraph the same length.
- Every sentence the same length.
- Feature list of exactly six bullets, each starting with a gerund.
- Any use of the phrase *a game where*.
- Any use of the phrase *your imagination is the limit*.
- Any use of the phrase *for the first time*.
- Any use of the phrase *at its core*.
- Any use of the phrase *in today's world*.

---

## 11. Voice, style, and localization notes

- **Voice.** Restrained, specific, second-person when necessary, third-person when the game speaks about itself. The narrator is a designer, not a storyteller.
- **Vocabulary we keep.** *Walk, tile, chamber, checkpoint, ghost, seed, wing, transform, habit, path, corridor, lattice, wall, collapse, rewrite, buffer, signature.* These words are the game.
- **Vocabulary we avoid.** *Dungeon, quest, adventure, journey, hero, magic, foe, curse, rune, crystal, portal, realm.* These words are not the game.
- **Punctuation.** Serial commas. Periods over em-dashes. No exclamation marks outside dialogue we do not have. No ellipses in store copy.
- **Numerals.** *Thirty* in the short description (rhythm). *48 chambers*, *4 transforms*, *6–9 hours* (specificity) in the long description. Consistency inside a paragraph is more important than a house rule across paragraphs.

### 11.1 Localization

Provide localizers the master English + three permitted tagline variants for *It learned you.* Localizers pick one; do not force a literal translation.

- *It learned you.* (default; short, cold, ambiguous verb tense on purpose)
- *The maze remembers.* (safer, more literal, use where "learned" reads clinical)
- *You built these walls.* (accusatory; use where the second person reads punchier than the first, e.g. some Romance languages)

The store page long description translates as-is. The trailer's on-screen text is captioned, not baked in — localize captions, keep the English frames untouched.

Locales to launch with: English (source), French, German, Spanish (Spain + Latin America split), Simplified Chinese, Japanese, Brazilian Portuguese, Russian. Korean and Turkish added after Next Fest if wishlist signal justifies it.

---

## 12. Press kit checklist

Ship a press kit at announce, not at launch. The kit is a single static page (or `presskit()`-style folder) with:

- The short description (§2, primary + both alternates).
- The long description (§3.1).
- The feature bullets (§3.3).
- The "what it is not" block (§4).
- Six screenshots (§7.3) at 1920×1080.
- Three GIFs (§7.4).
- Announce trailer (§6.1) direct MP4 download + YouTube link.
- Logo pack (transparent PNG, black-on-white PNG, monochrome SVG).
- Studio one-liner. Founder name. Contact email. Steam page link. Wishlist link. Discord invite link.
- A single "fact sheet" table: engine, platform, price band, planned launch quarter, tags top five, single-player only, offline only, no ads, no microtransactions, no generative AI content in the game.

Do not include:

- A "story synopsis." There isn't one.
- A "world lore" paragraph. There isn't one.
- Roadmap graphics. They age badly. Ship them in devlog, not in the press kit.

---

## 13. Owner sign-off

Before the store page publishes, these three sign-offs are recorded in this doc:

- **Design:** the copy in §3.1 is truthful. The demo scope in §9 is buildable. — signed / date
- **Art:** the capsule spec in §7 is executable. — signed / date
- **Marketing:** every asset passes §10. — signed / date

If any of the three is unsigned, the page does not publish.

---

## Appendix A — Rejected copy, kept as anti-examples

These were considered, then cut. Kept here so the pattern is legible to whoever writes the next version.

**Rejected short descriptions:**

- *Embark on an unforgettable journey through a mysterious ever-changing labyrinth where every step matters and no two runs are ever the same.* — Every clause is decoration; no mechanic; two AI-slop verbs; unearned "unforgettable"; unearned "no two runs are ever the same" (they are, deterministically).
- *A stunning minimalist puzzle roguelike where the maze adapts to you in real time using cutting-edge generative systems.* — Adjective tower; *stunning*; *cutting-edge*; misuses *roguelike*; misuses *real time*; misuses *generative* (implies LLMs to a modern reader).
- *Echo Lattice is a labyrinth like no other, blending puzzle, roguelike, and adaptive systems into a truly unique experience.* — *Like no other*; *blending*; *truly unique*; opens with the game name; sells no image.

**Rejected feature bullets:**

- *Stunning minimalist visuals that captivate.* — Two banned words; no verb; no player action.
- *Countless hours of engaging replayable content.* — *Countless*; *engaging*; *content*.
- *Powered by advanced AI to shape a world just for you.* — Untrue; slop verb; misclaims the tech; will draw negative reviews.
- *An unforgettable soundtrack you'll never forget.* — Yes, we noticed.

**Rejected taglines:**

- *A maze that adapts. A puzzle that thinks. A game that learns.* — Triplet cliché; personifies the wrong actor (the *game* does not learn — the *player's behavior* becomes the level).
- *Where every step tells a story.* — There is no story.
- *Discover the maze inside you.* — Cursed.

The winning line — *It learned you.* — is three words, past tense, second person, and unambiguously about the mechanic. That is the bar.

---

## Appendix B — Reference documents

- Design master: [`docs/FIVE_GAMES_TO_BUILD.md`](../FIVE_GAMES_TO_BUILD.md) — Game 1, Echo Lattice.
- Prior repo plan: [`docs/GAME_PLAN.md`](../GAME_PLAN.md).
- Sibling agent research relevant to positioning: PRs on trend map ([#13](https://github.com/cmp07/Game-/pull/13)), inventiveness checklist ([#18](https://github.com/cmp07/Game-/pull/18)), simple-deep design ([#17](https://github.com/cmp07/Game-/pull/17)), and physics-forward research ([#8](https://github.com/cmp07/Game-/pull/8)).

End of document.
