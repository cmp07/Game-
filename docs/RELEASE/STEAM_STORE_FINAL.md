# Echo Lattice — Steam Store Ship Package (Final)

**Product:** Echo Lattice  
**Engine:** Godot 4.3 desktop (Windows primary; Linux / macOS per platforms plan)  
**Doc:** `docs/RELEASE/STEAM_STORE_FINAL.md`  
**Status:** Paste-ready store copy + asset slate for Coming Soon → Next Fest → launch  
**AppID:** `YOUR_APP_ID` *(do not invent)*  

**Siblings (do not conflict — stay in this ship lane):**

| Doc | PR / role |
|---|---|
| [`PLATFORMS.md`](PLATFORMS.md) | #63 — store priority, build matrix, regional pricing notes |
| [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) | #64 — Content Survey, ratings, privacy, AI survey **No** |
| [`capsules/`](capsules/) | Capsule briefs + size-correct placeholders |
| [`screenshots/`](screenshots/) | Steam Partner slate (1920×1080, store order) |
| [`../ECHO_LATTICE/screenshots/v2_complete/`](../ECHO_LATTICE/screenshots/v2_complete/) | Lower-res loop-proof tour (not Partner upload) |

This file is the **store page package**. Compliance answers live in #64; depot/CI live in #63. Marketing thesis: sell recognition — *the maze is a transcript of how I walked* — not mystery, not AI, not loot.

---

## 1. Identity

| Field | Value |
|---|---|
| Store name | Echo Lattice |
| Developer / publisher | `YOUR_STUDIO_NAME` |
| Release state (target) | Coming Soon → demo @ Next Fest → paid 1.0 |
| Tagline | **It learned you.** |
| Hook sentence | A labyrinth that rebuilds from your last thirty moves. |

---

## 2. Short description (≤ 300 characters)

Steam search / header blurb. Paste verbatim.

**Primary (ship this):**

> A labyrinth that studies your last thirty moves and rebuilds itself in that shape. To escape, change how you walk. No dice, no combat, no story — only your own footprints, learning back.

Character count: **219**.

**Alternate A (trailer / A-B):**

> Walk thirty tiles. At the thirty-first, the walls slam into the shape of your path. Escape by rewriting your own habits. A deterministic puzzle labyrinth with a memory.

**Alternate B (genre-explicit):**

> A top-down puzzle where the maze is a transcript of how you walked. Every checkpoint reads your last thirty moves and rebuilds the walls. The only way out is to walk differently.

**Do not** lead with “In Echo Lattice, you will…” or “Explore a mysterious…”.

---

## 3. Long description (About This Game)

BBCode-ready. Line breaks intentional. Chamber count matches v2 complete (**35** campaign chambers + hard variants; four acts). Workshop / full editor remain post-launch — do not over-promise in the live page until shipped.

### 3.1 Master copy

```
[b]A labyrinth that learns your handwriting.[/b]

You walk. Thirty tiles later, a checkpoint flashes and the walls close on the exact shape of your path. The corridor you paced twice is a wall now. The maze is a transcript of how you walked, and the only way out is to walk differently.

[b]What you do[/b]

Four directions and undo. That is the control set. There are no weapons, no dice, and no story to grind. There is a chamber, a checkpoint, a goal, and the record of your last thirty moves. Hit a checkpoint and the room rewrites itself from that record — paper folding into ink walls — then asks you to try again as a slightly different person.

[b]Why it is not another random maze[/b]

Echo Lattice is deterministic. Same seed, same thirty moves, same maze. Two players on the same seed build two different levels because they walked differently. Your chalk habit trail stays visible, so you can see what the room is about to punish before it punishes you.

[b]Features[/b]

[list]
[*] A move-buffer engine that turns your last thirty inputs into authored geometry. Deterministic. Offline. No network calls, no generative AI.
[*] Thirty-five handmade campaign chambers across four acts (Induction → Reflection → Pressure → Mastery), plus hard variants.
[*] Origami rewrite slam — the spectacle beat when the lattice agrees with your footprints.
[*] Stars (1–3★) against par; bests remembered.
[*] Daily Challenge — a shared UTC seed, five chambers, everyone on the same day.
[*] Field Ledger look: paper, ink, rust fossils. Clean, diagrammatic, readable.
[*] Keyboard-first; controller path as it lands. English UI for v1.
[/list]

[b]What Echo Lattice is not[/b]

Not a roguelike loot crawl. Not a dungeon RPG. Not a chatbot dungeon. There is no combat, no inventory, and no procedurally generated story. The maze adapts; the writing does not.

[b]Sessions[/b]

A wing takes a short evening sitting. The campaign is a focused puzzle run; Daily Challenge and star-chasing extend it without a grind treadmill.

[b]The line the game keeps saying to you:[/b]

[i]It learned you.[/i]
```

### 3.2 Standalone feature bullets (keys / press)

- Walk thirty tiles. The thirty-first is your own path, weaponized.
- Deterministic rebuilds from your last thirty moves. Same seed, different walkers, different maze.
- 35 handmade chambers across four acts; Daily Challenge on a shared seed.
- Origami rewrite slam + chalk habit trail — see the habit before it eats you.
- No dice, no combat, no generative AI worldbuilding.

---

## 4. Tags & categories

### 4.1 Primary tags (≤5 most important, locked order)

1. **Puzzle**  
2. **Procedural Generation** *(authored grammar + habit hash — still the discovery claim)*  
3. **Minimalist**  
4. **Singleplayer**  
5. **Replay Value**

### 4.2 Supporting tags (fill remaining slots)

- Indie  
- 2D  
- Atmospheric  
- Abstract  
- Logic  
- Difficult *(light — prefer only if reviews support)*  
- Controllers *(enable when glyphs ship)*  
- Roguelike *(optional, light framing only — chambers + rewrites, not loot)*  

### 4.3 Steamworks feature / category checkboxes

| Feature | Ship answer |
|---|---|
| Single-player | **Yes** |
| Multi-player / co-op / MMO | **No** |
| Steam Achievements | Yes at launch candidate *(wire later)* |
| Steam Cloud | Optional *(local saves default — see compliance)* |
| Steam Workshop | **No** for v1 |
| Steam Leaderboards | **No** for v1 |
| Steam Trading Cards | Optional later |
| In-App Purchases | **No** |
| HDR / Ray tracing / VR | **No** |
| Remote Play Together | **No** |
| Steam Deck | Target Playable → Verified *(desktop Linux path — see PLATFORMS)* |

### 4.4 Store genre / category labels

- **Primary genre:** Puzzle  
- **Secondary:** Indie  
- **Player:** Single-player  

---

## 5. Pricing

**USD list band for this SKU:** **$4.99 – $9.99**.

| Anchor | When to pick |
|---|---|
| **$4.99** | Thin content perception risk / aggressive wishlist conversion; vignette framing |
| **$6.99** *(recommended default)* | 35-chamber campaign + daily + polish matches peer puzzle shelves |
| **$7.99 – $8.99** | Strong demo conversion + Next Fest heat + review score confidence |
| **$9.99** | Only if launch trailer + deck Verified + clear content depth beat comps |

**Do not** price above $9.99 for v1. Regional / CNY guidance lives in [`PLATFORMS.md`](PLATFORMS.md) (§ Pricing). Launch discount ≤10–20% week one; avoid training 50% waits.

**Recommended ship price:** **$6.99 USD** list, revisit after Next Fest demo metrics.

---

## 6. System requirements (Steam fields)

Godot 4.3 2D puzzle — light GPU load. Numbers are honest floors, not marketing flex.

### Windows (primary)

| | Minimum | Recommended |
|---|---|---|
| OS | Windows 10 64-bit | Windows 10/11 64-bit |
| Processor | Dual-core 2.0 GHz | Quad-core 2.5 GHz |
| Memory | 4 GB RAM | 8 GB RAM |
| Graphics | OpenGL 3.3 / Direct3D 11 capable GPU | Dedicated GPU with 1 GB VRAM |
| DirectX | Version 11 | Version 11 |
| Storage | 500 MB available space | 1 GB available space |
| Additional | — | Steam Deck / 1280×800 friendly UI scale |

### SteamOS / Linux *(when depot live)*

| | Minimum | Recommended |
|---|---|---|
| OS | Ubuntu 22.04 LTS or SteamOS 3 (64-bit) | Same |
| Processor | Dual-core 2.0 GHz | Quad-core 2.5 GHz |
| Memory | 4 GB RAM | 8 GB RAM |
| Graphics | OpenGL 3.3 compatible | Vulkan-capable GPU |
| Storage | 500 MB | 1 GB |

### macOS *(unsigned stub → notarize before public)*

| | Minimum | Recommended |
|---|---|---|
| OS | macOS 12 (Monterey) 64-bit | macOS 13+ |
| Processor | Apple Silicon or Intel dual-core | Apple Silicon |
| Memory | 4 GB RAM | 8 GB RAM |
| Graphics | Metal-capable | Metal-capable |
| Storage | 500 MB | 1 GB |

**Controller:** keyboard/mouse required for v1 copy until gamepad glyphs land; then add Full controller support.

---

## 7. Capsule assets

Briefs + placeholders: **[`capsules/README.md`](capsules/README.md)**.

Upload checklist:

- [ ] Header 460×215  
- [ ] Main 616×353  
- [ ] Small 231×87  
- [ ] Vertical 374×448  
- [ ] Library hero 1920×620+  
- [ ] Library logo 1280×720 transparent  
- [ ] Community icon 184×184  
- [ ] Client icon / `.ico` set  
- [ ] Optional page background 1438×810  

---

## 8. Screenshot slate (Steam Partner — 1920×1080)

**Upload folder:** [`screenshots/`](screenshots/)  
**Captions:** [`screenshots/TOUR.md`](screenshots/TOUR.md)  
**Capture tool:** [`../../game/echo_lattice/tools/capture_steam_store.sh`](../../game/echo_lattice/tools/capture_steam_store.sh)

Steam wants ≥5; we ship **eight** native **1920×1080** (16:9) candidates in Partner upload order. The older [`v2_complete`](../ECHO_LATTICE/screenshots/v2_complete/) tour (1152×672) stays as loop-proof reference only — do **not** upload it to Partner.

| # | Store job | File | Silent-legible claim |
|---|---|---|---|
| 1 | Hook / header still | [`01_hook_rewrite_slam.png`](screenshots/01_hook_rewrite_slam.png) | Origami rewrite — walls agreeing with the habit |
| 2 | Brand / tone | [`02_brand_main_menu.png`](screenshots/02_brand_main_menu.png) | Field Ledger title card — paper, ink, rust |
| 3 | Clean chamber read | [`03_chamber_start.png`](screenshots/03_chamber_start.png) | Ink walls, copper goal, habit unwritten |
| 4 | Habit forming | [`04_walking_trail.png`](screenshots/04_walking_trail.png) | Chalk trail writing toward checkpoint |
| 5 | Depth / pressure | [`05_mid_act_chamber.png`](screenshots/05_mid_act_chamber.png) | Later-act chamber, same materials under pressure |
| 6 | Meta / stars | [`06_win_stars.png`](screenshots/06_win_stars.png) | 1–3★ clear, moves vs par |
| 7 | Modes | [`07_daily_select.png`](screenshots/07_daily_select.png) | Daily Challenge on the ledger menu |
| 8 | Run close | [`08_wing_clear.png`](screenshots/08_wing_clear.png) | End-of-run ledger / habit signature |

**Rules:** no debug overlays, no Discord watermarks, no fake combat key art. Regenerate with `./game/echo_lattice/tools/capture_steam_store.sh` (writes a temporary 1920×1080 `override.cfg`, then removes it).

---

## 9. Trailer beat sheet

Two cuts. Visual language = Field Ledger (paper/ink/rust), not purple glow. First five seconds must read **muted**.

### 9.1 Announce / wishlist cut (~30 s)

| Time | Picture | On-screen text | Audio |
|---|---|---|---|
| 0:00–0:03 | Clean ledger corridor, overhead; one chalk footprint drops | `Deterministic.` | Soft paper / footstep; no music swell yet |
| 0:03–0:06 | Punch-card / habit buffer filling; seed header visible | `Same seed. Different you.` | Buffer ticks |
| 0:06–0:12 | Checkpoint → **origami rewrite slam** (hero spectacle) | *(none — let it land)* | Slam + cadmium heartbeat |
| 0:12–0:18 | Rust colonization on over-walked tiles; second run | `The maze wears you.` | Rust crunch / PA hush |
| 0:18–0:25 | Quick cuts: trail → mid-act chamber → stars clear | `Thirty-five chambers.` / `Daily seed.` | Sparse stingers |
| 0:25–0:30 | Title card on paper: **ECHO LATTICE** · `IT LEARNED YOU` · Wishlist | Wishlist / Coming Soon | Logo hit, silence tail |

### 9.2 Next Fest / broadcast cut (~45–60 s)

Extend announce with:

| Time | Picture | Text |
|---|---|---|
| 0:30–0:40 | Daily Challenge menu + shared seed | `Same day. Same seed.` |
| 0:40–0:50 | Ghost/habit trail race energy (even if async-self) | `Race your handwriting.` |
| 0:50–0:60 | Demo badge + Next Fest mark + wishlist | `Play the demo.` |

### 9.3 Delivery specs

- Master: 1920×1080, 30 fps, H.264 MP4, stereo −14 LUFS  
- Muted-safe first 5 seconds (approval gate)  
- Closed captions `.srt` for all baked text  
- Thumbnail: rewrite-slam frame; minimal or no baked text  

Longer ~90 s launch trailer can reuse the same spine with one full chamber solve — cut later.

---

## 10. AI disclosure (store + survey)

**Gameplay / ship content: none.** Aligns with [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) §1.3 and Steam checklist policy.

| Content | Generative AI? | Steam answer |
|---|---|---|
| Habit → rewrite geometry | **No** — deterministic offline rules | Do **not** list as AI |
| Chambers | **No** — hand-authored JSON | No |
| Runtime LLM / chatbot | **No** — forbidden v1 | No |
| Store capsules / trailer frames | Only if a model was used for *marketing art* | Disclose **asset** path only; never imply the labyrinth is AI-driven |
| Code assistants in production | Dev tooling | Not a store AI feature |

**Public line (if asked):**

> Echo Lattice adapts geometry with deterministic, offline rules from your recent moves. No generative AI models create art, audio, text, or levels in the shipping game.

Store copy, tags, and trailer must say **systems / habits / deterministic** — never “AI dungeon.”

---

## 11. Coming Soon → Next Fest calendar

Target fest: **Steam Next Fest — October 2026**  
*(February / June 2026 editions are closed; Oct is the open runway.)*

Official window: **19 Oct 2026 10:00 PDT → 26 Oct 2026 10:00 PDT**.  
Partner doc: [Steam Next Fest: October 2026](https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/2026october).

### 11.1 Milestone calendar

| Date (2026) | Gate | Owner notes |
|---|---|---|
| **ASAP / pre–Aug 31** | **Coming Soon page live** — capsules (placeholders OK if labeled internally), short+long copy, ≥5 screenshots, announce trailer, AI survey **No**, pricing set | Wishlist baseline |
| **18 Aug** | Valve Next Fest participant Zoom Q&A (optional) | Calendar block |
| **31 Aug 23:59 PDT** | **Next Fest registration closes** + official marketing materials cutoff | Hard gate |
| **7 Sep** | Steam pulls trailers for official Next Fest reel | Trailer must be on store page |
| **21 Sep** | **Demo build** submitted for Press Preview inclusion | Build review takes days — submit early |
| **5 Oct** | All required Next Fest items submitted for review | Final participation gate |
| **8 Oct 10:00 PDT** | Press Preview starts; trailer opt-out deadline | Creators get demo access |
| **1–8 Oct** | Autumn Sale overlap — Coming Soon traffic, not a sales event for us | Keep page sharp |
| **19 Oct 10:00 PDT** | **Next Fest opens** — demo live before open | Livestream / chat optional |
| **26 Oct 10:00 PDT** | Next Fest ends; wrap-up featuring top demos | Patch demo ≤7 days if needed |
| **Post-fest → launch** | Read demo conversion + wishlists; lock **$4.99–$9.99** final; ship 1.0 when gates clear | See pricing §5 |

### 11.2 Coming Soon checklist (page publish)

- [ ] Short description (primary) pasted  
- [ ] Long description pasted  
- [ ] Tags + categories set  
- [ ] Capsules uploaded (final or clearly temporary)  
- [ ] Screenshot slate uploaded (`docs/RELEASE/screenshots/` 1920×1080)  
- [ ] Trailer uploaded (announce cut)  
- [ ] Sysreqs filled  
- [ ] Price in band $4.99–$9.99 (recommend $6.99)  
- [ ] AI / Content Survey aligned with compliance pack (**No** gameplay AI)  
- [ ] Release date: Coming Soon *(or quarter when confident)*  
- [ ] Demo AppID linked when ready  

### 11.3 Next Fest demo scope (honest)

Demo = core loop in ≤3 minutes: silent teaching chambers → first rewrite slam → “wait, I did that.” Prefer Act I / Induction wing, not a trailer-only tease. Daily can be demo-gated or included if seed UX is solid.

---

## 12. Related paths

| Path | Role |
|---|---|
| [`capsules/`](capsules/) | Capsule briefs + placeholders |
| [`screenshots/`](screenshots/) | Steam Partner 1920×1080 slate |
| [`PLATFORMS.md`](PLATFORMS.md) | Multi-store + Deck + regional pricing (#63) |
| [`COMPLIANCE_FINAL.md`](COMPLIANCE_FINAL.md) | Survey / ratings / privacy (#64) |
| [`../ECHO_LATTICE/screenshots/v2_complete/`](../ECHO_LATTICE/screenshots/v2_complete/) | Lower-res tour reference |
| [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) §7 | Capsule / trailer still language |
| [`../ECHO_LATTICE/08_STEAM_CHECKLIST.md`](../ECHO_LATTICE/08_STEAM_CHECKLIST.md) | Depot / GodotSteam checklist *(when merged)* |

---

*Last updated: 2026-08 — AppID still placeholder. Store package only; no depot binaries in this PR.*
