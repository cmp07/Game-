# Echo Lattice — Feature Backlog ×1000 (Pure Fantasy Expansions)

**Status:** vision backlog (cloud-only; no code in this PR)  
**Source branch:** `cursor/echo-lattice-rc1` playable Field Ledger  
**Authority:** [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) · [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) · [`../AUDIT/DESIGN_GAMEPLAY.md`](../AUDIT/DESIGN_GAMEPLAY.md) · [`../AUDIT/PRODUCT_UPGRADES.md`](../AUDIT/PRODUCT_UPGRADES.md)  
**Product fantasy (locked):** habit → geometry. A Field Ledger that fossilizes how you walk. Escape by rewriting your own habits — not RNG, combat, loot, or horror stakes.

---

## 0. Thesis gate

Every feature below must pass:

```
Walk → trail → checkpoint → walls become your handwriting → walk differently.
```

| Keep | Reject |
|---|---|
| Ghosts as **chalk handwriting** of past walks | Ghosts as enemies / PvP / race ladder |
| Weather as **habit climate** on paper (rust humidity, silence fronts) | Weather as elemental combat or survival meters |
| Ledger annotations as **diegetic margin ink** | Journal RPG text walls / dialogue trees |
| Rewrite dialects as **accents of the same transforms** | Deckbuilder cards, spell loadouts, skill trees |
| Museum / stamp / archetype already in code | Cosmetics shop, battle pass, AI dungeon |

**Non-goals:** Act V content mountain, online leaderboards, multiplayer, genre mash, live-service economy.

---

## 1. Scoring method

Each expansion is scored **1–5** on three axes, then ranked by composite.

| Axis | 5 means | 1 means |
|---|---|---|
| **Impact (I)** | Players *feel* the thesis harder (retention, Mirror Birth kinship, “it answered me”) | Cosmetic or niche |
| **Effort (E)** | Large systems / content / art mountain | Hours–day wire of existing hooks |
| **Purity (P)** | Indistinguishable from Field Ledger fantasy; zero mash risk | Touches adjacent genres or dilutes the verb |

**Composite (higher = do first):**

```
Score = (Impact × Purity) ÷ Effort
```

Secondary “bang” when both impact and purity are high even if effort is medium:

```
Bang = Impact × Purity × (6 − Effort)
```

Tables are sorted by **Score** descending, then Bang, then Impact.

**Hooks already in tree (expand, don’t invent parallel systems):**

| Hook | Path |
|---|---|
| Habit signature / archetypes | `scripts/habit_signature.gd`, `habit_archetype.gd` |
| Habit → rewrite lever (thin wire) | `scripts/habit_rewrite_lever.gd`, `rewrite_score_bias.gd` |
| Museum of Selves + ghost path | `scripts/museum_of_selves.gd`, `museum_screen.gd` |
| Identity / birth stamps | `scripts/identity_stamp.gd`, `identity_stamp_card.gd` |
| Ghost assist (a11y chalk) | `scripts/a11y/ghost_path_assist.gd` |
| Habit replay vignette | `scripts/habit_replay_vignette.gd` |
| Balance modes / soft-hard bias | `config/balance_v2.json`, `balance_tuning.gd` |
| Forced transforms + telegraph | `scripts/chamber.gd`, content `transform` |
| PA / adaptive music | `scripts/audio/*` |
| Daily calendar / variations | `daily_calendar.gd`, `daily_variation.gd` |

---

## 2. Ranked backlog (32 features)

### Tier S — Ship next (Score ≥ 4.0)

| ID | Feature | I | E | P | Score | Bang | One-line |
|---|---|---|---|---|---|---|---|
| **F01** | **Ghost of Past Self (Museum race chalk)** | 5 | 2 | 5 | **12.5** | 100 | Overlay a cleared Self’s compact path as slate chalk; optional; never blocks clear. Extends `MuseumOfSelves.unpack_path` + chamber draw role `GHOST`. |
| **F02** | **Ledger Annotations (margin footnotes)** | 5 | 2 | 5 | **12.5** | 100 | After first rewrite / softlock recovery / identity clear, print 1–2 ink lines in the page margin (“Right-lean fossilized.”). Diegetic captions from existing archetype + stamp grades — not a quest log. |
| **F03** | **Habit Archetype → Visible Counter (once/chamber)** | 5 | 2 | 5 | **12.5** | 100 | On remix/daily (lessons stay forced), let `HabitRewriteLever` place 1–3 soft counter cells under BFS net; win screen names the archetype. Closes the critical thesis gap in DESIGN audit §I1. |
| **F04** | **Identity Stamp Gallery (plaque wall)** | 5 | 2 | 5 | **12.5** | 100 | Museum page of `IdentityStamp` masks for Who Walked / Portrait / Calcify / Nameplate + birth ceremonies. Same card language as `identity_stamp_card.gd`. |
| **F05** | **Rewrite Dialects (transform accents)** | 5 | 3 | 5 | **8.3** | 75 | Soft variants of the same op: *thin mirror* / *heavy mirror* / *offset rotate* / *bleed thicken* — pedagogy still teaches the family; dialect chosen by seed + soft_hard_bias, never a loadout menu. |
| **F06** | **Habit Weather (paper climate)** | 4 | 2 | 5 | **10.0** | 80 | Chamber atmosphere from live habit metrics: silence front (low tension), rust humidity (high revisit), chalk drought (straight streaks). Visual/audio only at first — no HP, no wet/dry combat. |

### Tier A — Deepen the verb (Score 2.5–3.9)

| ID | Feature | I | E | P | Score | Bang | One-line |
|---|---|---|---|---|---|---|---|
| **F07** | **Yesterday’s Daily Ghost** | 4 | 2 | 5 | **10.0** | 80 | On today’s Daily, optional chalk of *your* yesterday clear path (same wing grammar). Offline, single-player authorship social. |
| **F08** | **Annotation Ink that Fossilizes** | 4 | 2 | 5 | **10.0** | 80 | Margin notes from F02 that reference hot cells briefly highlight those fossils in rust_deep — cartographer’s honesty (art bible P5). |
| **F09** | **Dialect Earprints (audio)** | 4 | 2 | 5 | **10.0** | 80 | Map dialect accents → existing rewrite stinger aliases + one overtone layer; looper vs zigzagger get distinct PA board tones without new genre. |
| **F10** | **Portrait Star Fold** | 4 | 2 | 5 | **10.0** | 80 | Wire `IdentityStamp.affects_stars` into ★ for identity bosses only (scribble/readable/signed). Births stay ceremony, not gate. |
| **F11** | **Field Notes Tutorial (Echo Plate preview)** | 4 | 2 | 5 | **10.0** | 80 | Echo Plate shows a *ghost rewrite* telegraph without commit; first annotation teaches checkpoint literacy before Mirror Birth. |
| **F12** | **Cross-run Best-Clear Ghost** | 4 | 3 | 5 | **6.7** | 60 | Optional overlay of personal best path for current chamber (star chase). Distinct from a11y assist (once) and Museum race (any Self). |
| **F13** | **Habit Climate Season (streak)** | 4 | 3 | 5 | **6.7** | 60 | Daily streak length shifts paper tint / HVAC bed within ledger family (wet season = more rust grain). Pure retention climate, not a season pass. |
| **F14** | **Dialect Remix Chambers** | 4 | 3 | 5 | **6.7** | 60 | 4–6 remix JSON that keep parent `transform` family but author a dialect flag (`bleed`, `offset`, `thin`). Teach-then-remix rule preserved. |
| **F15** | **Softlock Footnotes** | 3 | 1 | 5 | **15.0** | 75 | When softlock recovery fires, stamp a single margin annotation + chalk flash on the illegal echo — turns fairness into ledger voice. |
| **F16** | **Archetype Title on Win / Museum** | 3 | 1 | 5 | **15.0** | 75 | Surface `MuseumOfSelves.title_for` strings on chamber-won and plaque; “The Looper of Cement Trail” must be readable without HUD jargon. |
| **F17** | **Cadmium Weather Heartbeat** | 3 | 1 | 5 | **15.0** | 75 | Near-checkpoint warn intensity scales with habit weather (F06) — still ≤1% cadmium screen budget; no new warn color. |
| **F18** | **Assist Ghost Prefers Past Self** | 3 | 2 | 5 | **7.5** | 60 | If Museum has a Self for this chamber, a11y ghost assist draws *your* chalk first; else BFS suggestion. Keeps assist pure. |

### Tier B — Authorship toys (Score 1.5–2.4)

| ID | Feature | I | E | P | Score | Bang | One-line |
|---|---|---|---|---|---|---|---|
| **F19** | **Dual-Self Overlay** | 4 | 3 | 4 | **5.3** | 48 | Race two archived Selves’ chalk at once (e.g. first clear vs 3★). Clarity risk → cap at 2; slate vs chalk_white roles. |
| **F20** | **Ledger Colophon (Act clear)** | 3 | 2 | 5 | **7.5** | 60 | End-of-Act page: transform census, dominant archetype, stamp grades, rust coverage %. Document ending, not credits crawl only. |
| **F21** | **Invert Dialect Lesson (Mastery)** | 4 | 3 | 5 | **6.7** | 60 | Ship `invert` as a true Mastery lesson chamber; fix Invert Ballet naming lie. Dialect family completes the grammar. |
| **F22** | **Fossil Aging Layers** | 3 | 2 | 5 | **7.5** | 60 | Echo walls from earlier checkpoints tint toward rust_deep; latest rewrite stays rust_fossil. Time = accretion (art bible P3). |
| **F23** | **Weather Seed from Habit Fingerprint** | 3 | 2 | 4 | **6.0** | 48 | Endless / Open Lattice optional: seed salt from last chamber’s habit fingerprint so climate continues across wing — still deterministic. |
| **F24** | **Annotation Bookmark (Museum)** | 3 | 2 | 5 | **7.5** | 60 | Pin one margin line onto a Self plaque; shows on ghost race intro. Offline scrapbook, not social feed. |
| **F25** | **Reader / Cold as Ledger Modes** | 3 | 3 | 4 | **4.0** | 36 | Surface balance `reader` / `cold` as paper modes (wide margins vs cramped ink) — undo/rewind budgets as ledger rules, not difficulty skins named after combat. |
| **F26** | **Dialect Purity Score (win)** | 3 | 2 | 4 | **6.0** | 48 | Win screen metric: how cleanly the fossil matches the taught dialect (vs safety-net drops). Optional ★ pad — never softlocks. |
| **F27** | **Habit Fog (loop haze)** | 3 | 2 | 4 | **6.0** | 48 | High backtrack_rate softens distant telegraph ticks (ink_soft wash) — readable warning that loops blur foresight; reduce-motion skips. |
| **F28** | **Wing Weather Fronts** | 3 | 3 | 5 | **5.0** | 45 | Act paper tints (Blueprint / Newsprint / Slate) *plus* weather overlays that escalate Pressure→Mastery humidity. Art bible wings made playable. |

### Tier C — Stretch / post-1.0 fence (still pure)

| ID | Feature | I | E | P | Score | Bang | One-line |
|---|---|---|---|---|---|---|---|
| **F29** | **Friend Annotation String** | 3 | 3 | 4 | **4.0** | 36 | Extend Daily friend-code paste with a short archetype + dialect glyph (`L/mirr⊕`). Comparable offline; no leaderboard. |
| **F30** | **Workshop Stamp Share (offline import)** | 3 | 4 | 4 | **3.0** | 24 | Import/export identity silhouette masks as ledger cards between saves — only if still offline-first and schema-versioned. |
| **F31** | **Endless Monsoon Bias** | 4 | 4 | 4 | **4.0** | 32 | Endless depth raises soft_hard_bias + habit-weather intensity using `balance_v2` endless mode; grammar stays transform dialects, not new verbs. |
| **F32** | **Census of Selves (compare)** | 3 | 3 | 5 | **5.0** | 45 | Museum view: histogram of archetype titles across cap-48 archive — “you were a Looper for 11 clears.” Retention mirror, not stats bloat. |

---

## 3. Sorted master table (by Score)

| Rank | ID | Feature | I | E | P | Score | Bang |
|---|---|---|---|---|---|---|---|
| 1 | F15 | Softlock Footnotes | 3 | 1 | 5 | 15.0 | 75 |
| 2 | F16 | Archetype Title on Win / Museum | 3 | 1 | 5 | 15.0 | 75 |
| 3 | F17 | Cadmium Weather Heartbeat | 3 | 1 | 5 | 15.0 | 75 |
| 4 | F01 | Ghost of Past Self | 5 | 2 | 5 | 12.5 | 100 |
| 5 | F02 | Ledger Annotations | 5 | 2 | 5 | 12.5 | 100 |
| 6 | F03 | Habit Archetype → Visible Counter | 5 | 2 | 5 | 12.5 | 100 |
| 7 | F04 | Identity Stamp Gallery | 5 | 2 | 5 | 12.5 | 100 |
| 8 | F06 | Habit Weather | 4 | 2 | 5 | 10.0 | 80 |
| 9 | F07 | Yesterday’s Daily Ghost | 4 | 2 | 5 | 10.0 | 80 |
| 10 | F08 | Annotation Ink that Fossilizes | 4 | 2 | 5 | 10.0 | 80 |
| 11 | F09 | Dialect Earprints | 4 | 2 | 5 | 10.0 | 80 |
| 12 | F10 | Portrait Star Fold | 4 | 2 | 5 | 10.0 | 80 |
| 13 | F11 | Field Notes Tutorial | 4 | 2 | 5 | 10.0 | 80 |
| 14 | F05 | Rewrite Dialects | 5 | 3 | 5 | 8.3 | 75 |
| 15 | F18 | Assist Ghost Prefers Past Self | 3 | 2 | 5 | 7.5 | 60 |
| 16 | F20 | Ledger Colophon | 3 | 2 | 5 | 7.5 | 60 |
| 17 | F22 | Fossil Aging Layers | 3 | 2 | 5 | 7.5 | 60 |
| 18 | F24 | Annotation Bookmark | 3 | 2 | 5 | 7.5 | 60 |
| 19 | F12 | Cross-run Best-Clear Ghost | 4 | 3 | 5 | 6.7 | 60 |
| 20 | F13 | Habit Climate Season | 4 | 3 | 5 | 6.7 | 60 |
| 21 | F14 | Dialect Remix Chambers | 4 | 3 | 5 | 6.7 | 60 |
| 22 | F21 | Invert Dialect Lesson | 4 | 3 | 5 | 6.7 | 60 |
| 23 | F23 | Weather Seed from Habit Fingerprint | 3 | 2 | 4 | 6.0 | 48 |
| 24 | F26 | Dialect Purity Score | 3 | 2 | 4 | 6.0 | 48 |
| 25 | F27 | Habit Fog | 3 | 2 | 4 | 6.0 | 48 |
| 26 | F19 | Dual-Self Overlay | 4 | 3 | 4 | 5.3 | 48 |
| 27 | F28 | Wing Weather Fronts | 3 | 3 | 5 | 5.0 | 45 |
| 28 | F32 | Census of Selves | 3 | 3 | 5 | 5.0 | 45 |
| 29 | F25 | Reader / Cold as Ledger Modes | 3 | 3 | 4 | 4.0 | 36 |
| 30 | F29 | Friend Annotation String | 3 | 3 | 4 | 4.0 | 36 |
| 31 | F31 | Endless Monsoon Bias | 4 | 4 | 4 | 4.0 | 32 |
| 32 | F30 | Workshop Stamp Share | 3 | 4 | 4 | 3.0 | 24 |

*Note:* F15–F17 top the Score table because they are tiny wires with full purity — they are **not** the product headline. Headline fantasy pack is **F01–F06** (highest Bang among Impact-5 / Impact-4 thesis pieces).

---

## 4. Recommended packs (how to ship without sprawl)

### Pack A — “It answered you” (1.0 thesis)

1. F03 Habit counter visible  
2. F16 Archetype titles  
3. F02 + F08 Ledger annotations  
4. F10 Portrait stars  
5. F11 Field Notes tutorial  

**Acceptance:** Blind tester says *“it punished my looping”* (or kin) after Act II without reading design docs.

### Pack B — “Race your handwriting” (retention)

1. F01 Ghost of Past Self  
2. F04 Stamp gallery  
3. F07 Yesterday’s Daily Ghost  
4. F12 Best-clear ghost  
5. F18 Assist prefers past self  

**Acceptance:** Trailer still of chalk-on-chalk; Museum race optional; deaths never archive.

### Pack C — “Dialect & climate” (post-thesis depth)

1. F05 Rewrite dialects  
2. F06 + F17 Habit weather  
3. F09 Dialect earprints  
4. F14 Dialect remixes  
5. F21 Invert lesson  
6. F13 / F28 climate + wing fronts  

**Acceptance:** Lessons still force a transform *family*; dialects never become a loadout screen; weather never becomes a survival meter.

### Pack D — Fence (post-1.0)

F19, F23, F25, F26, F27, F29–F32 — only after Packs A–C acceptance tests stay green.

---

## 5. Explicit rejects (so scope doesn’t crawl)

| Temptation | Why rejected |
|---|---|
| Ghost enemies / “hunt your past self” combat | Mash; ghosts are chalk, not antagonists |
| Weather damage / cold meter / wet tiles that kill | Survival mash; climate is paper atmosphere |
| Annotation quests / NPC surveyor dialogue | RPG mash; margin ink only |
| Dialect spellbook / equip three transforms | Deckbuilder mash; dialects are accents of forced ops |
| Procedural “AI wrote the maze” marketing | Kills authorship moat |
| Cosmetics MX for ghost skins as monetization | Live-service drift; chalk roles stay a11y/info |
| Pulsars / geometric enemies from stale juice docs | Superseded; not product fantasy |

---

## 6. Traceability to audits

| Vision feature | Pays down |
|---|---|
| F03, F16 | DESIGN §I1 habit systems do not author geometry |
| F04, F10 | DESIGN §I4 identity bosses under-deliver |
| F01, F07, F12, F18 | PRODUCT U13 / U20 Museum + cross-run ghost |
| F05, F14, F21 | DESIGN §I8 invert lie + transform fatigue relief via accents |
| F06, F13, F17, F28 | ART bible wing tints + fossilization without glow |
| F02, F08, F11, F15 | DESIGN §I7 onboarding / unused hints |
| F25 | DESIGN U13 Reader/Cold delete-or-ship |
| F31 | DESIGN U20 endless congruence after habit wire |

---

## 7. Doc contract

- This file invents **expansions**, not a second game.  
- Implementation PRs should cite feature IDs (`F0x`) and keep `Score`/`Purity` gates in the PR body.  
- If a proposal drops **Purity below 4**, it does not belong in this backlog — open a separate research note instead.  
- Cloud-only vision PR: no gameplay code required to land this document.

---

*End of FEATURE_BACKLOG_1000X. 32 expansions ranked Impact × Effort × Purity for pure Field Ledger fantasy.*
