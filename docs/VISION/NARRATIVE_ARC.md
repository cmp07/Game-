# Echo Lattice — Narrative Arc (Vision)

**Product:** Echo Lattice (Field Ledger labyrinth)  
**Doc:** `docs/VISION/NARRATIVE_ARC.md`  
**Status:** Vision lock for 1.0 emotional authorship — not a lore bible  
**Authority peers:** [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) · Museum thin archive (`museum_of_selves.gd`) · locale `end.*` / `museum.*` / `act.*`

---

## 0. One-line thesis

The story is **you meeting the handwriting you leave behind** — a short emotional authorship toy, told only through captions, act titles, Museum selves, and the ending.

No quest log. No antagonist. No cutscene. The lattice does not speak in plot; it **prints you back as architecture** until you choose a different stroke.

```
Walk → trail → checkpoint → walls become your draft → walk differently → leave a fossil → read who you were.
```

---

## 1. Hard rule — narrative without RPG mash

Echo Lattice keeps one pure fantasy: **habit → geometry**. Narrative must intensify that fantasy. It must never borrow RPG scaffolding to feel “deeper.”

| Allowed (authorship toy) | Forbidden (RPG / mash) |
|---|---|
| One-line chamber captions that name a feeling or craft move | Dialogue trees, NPC guides, companion banter |
| Act titles + one-sentence blurbs as chapter breath | Quest markers, faction lore, world map chapters |
| Identity bosses as **portrait ceremonies** (Who Walked → Portrait → Calcify → Nameplate) | Boss lore dump, HP bars, named villains |
| Museum plaques + chalk handwriting fossils | Character creator, class/loadout story, achievement lore novels |
| Ending that names the habit and invites the Museum | Multi-ending moral quizzes, credit-scroll mythology |
| PA / rewrite teach lines as diegetic stamps (“It matches you”) | Cutscenes, voice-acted exposition, journal codex |

**Store congruence:** short description may say “no story to grind” meaning *no RPG narrative grind*. This doc is the **emotional story** that already lives in the toy — not a second genre glued on.

---

## 2. Emotional spine (four beats)

The campaign is one feeling arc in four breaths. Pedagogy (teach → remix → boss) stays in the Content Bible; this spine is what the player should *feel*.

| Beat | Act title | Emotional job | Player should leave feeling… |
|---|---|---|---|
| **1 — First draft** | **Induction** | Discover that the room can wear you | Curious, slightly exposed — “it can read me” |
| **2 — Facing the copy** | **Reflection** | See your route become a face / twin | Self-conscious craft — “I am drawing myself” |
| **3 — Cost of habit** | **Pressure** | Learn that messy handwriting traps you | Urgency without horror — “hesitation fills cells” |
| **4 — Signature** | **Mastery** | Compose on purpose; sign; open the book | Quiet authorship pride — “I chose this stroke” |

**Through-line phrase (internal, not always on screen):** *Stop walking like yourself — then leave a self worth keeping.*

Boss identity chambers close each beat as a **portrait**, not a plot twist:

| Act | Boss title | Identity tag | Ceremony |
|---|---|---|---|
| Induction | Who Walked | `induction_signature` | First readable signature |
| Reflection | Portrait | `reflection_portrait` | Dual-axis face / negative space |
| Pressure | Calcify | `pressure_calcify` | Habits as the only walls left |
| Mastery | Nameplate | `mastery_nameplate` | Final sign — nameplate on the ledger |

---

## 3. Delivery channel A — Captions

Captions are the **only continuous narration**. Cap ~160 chars (schema). Voice: dry cartographer / Field Ledger — craft instruction with emotional aftertaste. Never joke-RPG, never horror stinger, never AI-dungeon mystique.

### 3.1 Caption jobs by role

| Role | Caption job | Pattern |
|---|---|---|
| `lesson` | Name the verb + the feeling of first contact | Imperative + one consequence |
| `remix` | Tighten craft without new lore | Warning about a bad habit shape |
| `boss` | Ceremony — ask for a portrait, not a kill | “Boss.” + identity ask |
| `hard` | Respect + less forgiveness | “Hard.” + same lesson, thinner mercy |
| `daily_showcase` | Epilogue / shareable openness | “Epilogue.” + friend-seed social |

### 3.2 Locked emotional landmarks (shipped captions — keep / polish, do not replace with lore)

| Chamber | Caption (emotional landmark) |
|---|---|
| Quiet Span | Walk the span. |
| Echo Plate | Step the plate. Still asleep. |
| Mirror Birth | Cross the checkpoint. Your path becomes wall. |
| Who Walked | Boss. Leave a signature the lattice can read. |
| Portrait | Boss. Both axes. Your path becomes a face. |
| Calcify | Boss. Your habits become the only walls left. |
| Nameplate | Boss. Final identity — sign the lattice. |
| Open Lattice | Epilogue. Same seed a friend can share. |

**Mirror Birth post-slam teach line** (`It matches you`) is part of the caption system’s *ceremony punctuation* — keep it short, diegetic, non-RPG.

### 3.3 Caption craft rules (authoring)

1. **One job.** Teach or warn or ceremonialize — never two.
2. **Second person craft, not plot.** “Your path…” / “Do not re-tread” — not “The Overseer demands…”
3. **No proper nouns of fiction.** Chamber titles may be poetic; captions stay procedural-emotional.
4. **Boss captions start with `Boss.`** so the ceremony reads in skim.
5. **Prefer verbs of writing/printing:** imprint, seal, fold, sign, fossilize — not fight, loot, survive.
6. **Localization:** English JSON remains design-source; display via `chamber.<id>.caption`.

### 3.4 Soft upgrade targets (copy only — no systems mash)

Captions that are purely mechanical may gain a single emotional clause **without** becoming story:

| Example direction | Avoid |
|---|---|
| “Thicken under pressure. One path, no return.” (already good) | “The Warden seals your fate.” |
| “Symmetry lies. Choose which half becomes wall.” (already good) | “Betray your twin self in cutscene.” |

Do **not** add subtitle lore paragraphs (`intro`/`outro` walls). Optional `subtitle` stays UI-ignored unless a future thin interstitial uses one line max.

---

## 4. Delivery channel B — Act titles

Act titles are **chapter cards**, not world regions.

| Id | Title | Blurb (emotional read) | Must not become… |
|---|---|---|---|
| `induction` | Induction | Learn the rewrite without a lecture. | “Tutorial Kingdom” |
| `reflection` | Reflection | See the lattice become a portrait of your route. | Mirror-dimension lore |
| `pressure` | Pressure | Habits harden. Escape by changing how you move. | Survival horror act |
| `mastery` | Mastery | Compose transforms. Sign your identity. | Prestige rank / skill tree act |

**Presentation vision:** when an Act begins, show **title + blurb only** (Field Ledger page turn). No map pin, no NPC briefing, no “objectives.” Demo may end after Induction’s first authorship beat without spoiling Mastery titles in store art.

**Locale keys:** `act.induction` … `act.mastery` — titles stay abstract nouns; blurbs carry the feeling.

---

## 5. Delivery channel C — Museum of Selves

The Museum is the **memoir layer** of the narrative — retention as emotional authorship, not a cosmetic shop or race ladder.

### 5.1 What a Self is (story object)

On clear (never on death), archive a compact fossil:

- Archetype title (“The Looper of Mirror Birth”, “The Right-Leaner of Calcify”, …)
- Habit snapshot (dominant, bias, turn/backtrack rates)
- Chalk path (handwriting replay)
- Optional identity stamp plaque (grade / portrait / birth / boss flags)

**Emotional read:** you are not collecting loot; you are **shelving drafts of yourself**.

### 5.2 Narrative jobs

| Moment | Story function |
|---|---|
| Post-clear plaque + handwriting vignette | Immediate “I left a mark” aftertaste |
| Museum browse | Quiet gallery — compare early Induction selves to Nameplate |
| Replay handwriting | Re-watch the draft without re-entering combat fantasy |
| Wipe Field Notes | Irreversible memoir erase — treat copy with gravity, not gag |

### 5.3 Voice for Museum chrome (locked direction)

Shipped tone to preserve:

- Title: **Museum of Selves**
- Blurb: *Each clear leaves a fossil. Browse who you were — handwriting on paper.*
- Empty: *No selves archived yet. Clear a chamber.*

**Upgrade vision (still no mash):**

1. Act filters / archetype filters as **exhibit labels**, not RPG bestiary tabs.
2. Identity-boss selves get a quieter plaque frame (ink rule, not trophy case flex).
3. After Nameplate, a single pinned exhibit line: *Signed.* — no cutscene.
4. Ghost race (META v2) stays **async handwriting race**, never PvP lore.

DLC pedestals/frames (post-1.0) must remain **plaque cosmetics** — they must not gate endings or invent character wardrobe story.

---

## 6. Delivery channel D — Ending

The ending is a **ledger close**, not a credits mythology.

### 6.1 Campaign close sequence (vision)

```
Nameplate clear
  → identity stamp + Museum archive (“Signed.”)
  → Open Lattice (epilogue showcase / friend seed)
  → End screen: wing complete + habit summary
  → soft CTA into Museum of Selves (browse the selves you became)
```

**Emotional target:** relief + authorship pride + invitation to re-read yourself — not victory fanfare over a villain.

### 6.2 End-screen copy spine

| Slot | Shipped / direction | Emotional job |
|---|---|---|
| Title | END OF SLICE → vision: **LEDGER CLOSED** or keep slice title until 1.0 freeze | Ceremony, not “You Win” |
| Tagline | *The lattice remembers you.* | Reciprocal authorship — the toy answers |
| Summary | Chambers beat, stars, dominant habit counts | Facts of your handwriting |
| Footer | Field Ledger / ink on paper identity | Brand congruence |
| Demo variant | *You met Mirror Birth. The full lattice waits.* | Promise without Mastery spoilers |

**Do not add:** lore crawl, character epilogues, “years later,” multiple moral endings, New Game+ plot sequel text inside 1.0.

### 6.3 Ending variants (same fantasy, different door)

| Gate | Ending emphasis |
|---|---|
| Demo | Mirror Birth remembered → wishlist |
| Daily | Datestamp + friend code — shared day, different selves |
| Endless | Depth number as endurance draft, not prestige rank story |
| Campaign | Nameplate → Open Lattice → Museum |

All variants share the tagline idea: **the lattice remembers you** — memory is mechanical (fossils, saves, stamps), not mystical lore.

### 6.4 Post-ending loop (story continues as toy)

After the ledger closes, narrative return is:

1. Museum (read old selves)  
2. Daily (same seed, new handwriting)  
3. Hard+ / stars (cleaner drafts of the same chambers)  

No Act V myth in 1.0. If Act V ships later, it extends **authorship craft**, not a new saga.

---

## 7. Full-arc beat sheet (player-facing, skimable)

Use this as the emotional QA checklist. If a build needs a cutscene to explain a beat, the beat failed.

1. **Quiet Span** — blank paper; you are only a walker.  
2. **Echo Plate** — the ledger is armed but asleep.  
3. **Mirror Birth** — first authorship slam; *it matches you.*  
4. Induction remixes — clean your draft; learn thicken / rotate.  
5. **Who Walked** — leave a signature someone could recognize.  
6. Act card **Reflection** — portrait anxiety begins.  
7. Dual-axis craft → **Portrait** — your path becomes a face.  
8. Act card **Pressure** — mercy thins; habits hurt.  
9. **Calcify** — the walls are only what you kept doing.  
10. Act card **Mastery** — compose on purpose.  
11. **Nameplate** — sign the lattice.  
12. **Open Lattice** — epilogue; share the seed.  
13. End screen — *The lattice remembers you.*  
14. Museum — shelve and re-watch the selves.

---

## 8. Voice bank (approved emotional lines)

Reusable across captions, act cards, ending, Museum, trailer — same toy, same mouth.

| Line | Use |
|---|---|
| It learned you. | Slam / trailer / social |
| It matches you. | Mirror Birth teach |
| The lattice remembers you. | Ending tagline |
| Your footsteps are a draft. | Trailer / interstitial |
| Stop walking like yourself. | Social / Pressure breath |
| Sign the lattice. | Nameplate |
| Handwriting on paper. | Museum |
| Same seed. Different you. | Daily / Open Lattice |

**Banned flavors:** “chosen one,” “dark labyrinth awakens,” “AI that dreams,” “survive the night,” “loot your past self,” “level up your echo.”

---

## 9. Gaps vs RC1 (vision debt — copy & ceremony only)

Honest snapshot so implementation PRs stay thin:

| Channel | RC1 reality | Vision ask |
|---|---|---|
| Captions | Strong craft one-liners; some purely mechanical | Keep landmarks; lightly warm a few remix lines; never add lore |
| Act titles | Titles + blurbs in `acts.json` / locale | Ensure Act card breath exists in UI (title + blurb only) |
| Museum | Thin archive + replay vignette shipped | Pin Nameplate exhibit; exhibit filters later; no shop story |
| Ending | Slice end + habit summary + demo wishlist | Campaign path Nameplate → Open Lattice → Museum CTA; tagline locked |
| Identity stamps | Stamp card / plaque plumbing exists | Make boss clears *feel* like ceremonies in UI copy, not new systems genres |

If a proposal needs combat, dialogue, or lore codex to “finish the story,” it is out of scope for this vision.

---

## 10. Acceptance tests (cloud / design)

- [ ] A stranger can retell the story using only captions + act titles + Museum + ending — no wiki.  
- [ ] Removing all narrative still leaves a complete puzzle game; narrative only **names the feeling of the verb**.  
- [ ] No PR adds RPG mash to satisfy this doc.  
- [ ] Nameplate / Open Lattice / end tagline / Museum blurb stay emotionally congruent with Field Ledger art/audio.  
- [ ] Demo ending still stops at Mirror Birth promise without Mastery spoilers.  
- [ ] Store line “no story to grind” remains true (no grindable lore).

---

## 11. Non-goals

- Visual novel layers, comic interludes, character bible  
- Procedural generated “narrative events”  
- Multiplayer story, seasonal lore passes  
- Horror vignette re-mash from early `GAME_PLAN.md` research lane  
- Using Act V / DLC to invent a sequel plot inside 1.0 endings  

---

## 12. Change log

| Date | Change |
|---|---|
| 2026-08-09 | Initial vision — emotional authorship toy via captions, act titles, Museum selves, ending; explicit no-RPG-mash lock. |
