# Echo Lattice — Design / Gameplay Audit (RC1)

**Branch audited:** `cursor/echo-lattice-rc1` (detached HEAD at merge of RC1 release packs)  
**Audit branch:** `cursor/audit-design`  
**Product fantasy (locked):** pure **habit → geometry** labyrinth — a Field Ledger that fossilizes how you walk. **No genre mash** (not horror vignette, not combat arena, not deckbuilder, not idle).  
**Sources of truth used:** `04_CONTENT_BIBLE.md`, `05_ART_BIBLE.md`, `14_BALANCE_V2.md`, `14_VISUAL_V2.md`, `07_JUICE.md`, `13_VERTICAL_SLICE_README.md`, `DEMO_SPEC.md`, `CHANGELOG_V2.md`, and the Godot project under `game/echo_lattice/` (content + scripts).

---

## 0. Verdict

**The shipped loop is a clean, demoable habit→geometry puzzle with a memorable Mirror Birth beat and a coherent Field Ledger look.**  
**The thesis gap is authorship reactivity:** the maze rewrites from *where you walked*, but almost never from *how you habitually play*. Balance archetypes, rewrite-score bias, tempo, Reader/Cold modes, hard variants, and the authored daily catalog are largely **sidecar systems** that do not drive the playable router.

If RC1 is “prove the verb,” it succeeds. If RC1 is “reactive authorship toy,” it is only half-built.

---

## 1. What “reactive authorship toy” means here

| Claim | Player should feel | Shipped reality |
|---|---|---|
| **Habit → geometry** | My path becomes architecture | **Yes** — checkpoint commits walked cells through a forced transform into echo/fossil walls (`chamber.gd` + content `transform`) |
| **Reactive** | The lattice *answers my style* (lean, loop, zigzag) | **Mostly no** — `HabitArchetype` / `RewriteScoreBias` / `balance_v2` counters (`place_deflector`, `fossilize_hot_cell`, …) are not wired into chamber commits |
| **Authorship** | I leave a legible signature; bosses judge the portrait | **Partial** — identity chambers *ask* for intentional shapes in captions/hints; clear condition is still only `REACH_GOAL` |
| **Toy** | Short retries, readable foreshadow, daily/endless share the same verb | **Partial** — telegraph + origami slam + stars + undo exist; **no endless**; daily ignores its own catalog |

North-star pitch (content bible / slice): *escape by rewriting your own habits, not by beating RNG.* Determinism and BFS safety nets honor that. Personalization does not yet.

---

## 2. Strengths

### 2.1 Pure fantasy cohesion (when ignoring stale docs)

- One verb: walk → checkpoint → transform → fossil walls → goal.
- No combat, HP, enemies, or loot — compliance pack correctly labels this a **2D puzzle / labyrinth**, not the older tension/horror research lane in `GAME_PLAN.md`.
- Teach-then-remix roster is real: 10 lessons, 20 remixes, 4 bosses, 4 hard, 1 daily showcase across four Acts (`acts.json` + 39 JSON chambers).

### 2.2 Act I / Mirror Birth onboarding

- **Quiet Span** / **Echo Plate** (`transform: none`) teach movement without a lecture.
- **Mirror Birth** is the product hook: first `mirror_v`, caption + motif banner aligned, demo-gated as the required beat (`DEMO_SPEC.md`).
- Silent early audio policy + PA “ghost floor” line supports Induction pedagogy without a wall of tutorial UI.

### 2.3 Fairness infrastructure

- Per-cell BFS solvability filter on echo placement; softlock recovery + telemetry assert.
- Undo across rewrites; hold-to-walk + reduce-motion / flash gate / colorblind fossil roles.
- Stars from moves vs BFS par without gating progression — good “one more run” bait without softlocks.

### 2.4 Field Ledger visual identity (play surface)

- VISUAL v2 replaced purple-void boxes with paper/ink/rust materials, punch-card/menu language, origami rewrite slam, cadmium telegraph.
- Palette autoload + art kit match `05_ART_BIBLE.md` tokens; screenshots in `screenshots/v2_complete/` read as one composition language.

### 2.5 Campaign structure as design document

- Four Acts with blurbs and identity bosses (`Who Walked` → `Portrait` → `Calcify` → `Nameplate`) give a clear mastery arc on paper.
- Hard variants and daily seed catalog are *authored* — the content pipeline is ahead of meta wiring.

---

## 3. Incongruences (ranked by damage to the thesis)

### I1 — Habit systems do not author geometry (critical)

**Docs / data:** Balance v2 defines archetypes → counter operators; `RewriteScoreBias` blends scores; audio even has stingers for `place_deflector` / `fossilize_hot_cell`.  
**Play:** Chambers force a single `transform` string. Habit profile is a direction counter shown in HUD / win screen and fed to adaptive music — **it never chooses or biases the rewrite**.

**Effect:** Players can believe “it learned you” from the *mirror of this path*, but not from a *style counter*. The toy is geometric, not reactive.

### I2 — Dual act ontologies (SEED/GROWTH/PRISM vs Induction→Mastery)

| Layer | Acts |
|---|---|
| Content / menu / demo | Induction, Reflection, Pressure, Mastery (4) |
| `balance_v2.json` | SEED, GROWTH, PRISM (3 × 7 chambers) |
| Runtime map | `ChamberBook._to_playable` clamps `act_index 0..3 → act 1..3` so **Mastery shares PRISM** with Pressure |

**Effect:** Star slack, habit window, and rewrite-cap *numbers* do not describe the four-Act story the player is sold. Tempo / rewrite_cap from balance are unused in chamber play (`tempo_start: 9999` everywhere).

### I3 — Daily / endless vs campaign incongruence

| Spec | Runtime |
|---|---|
| `DailySeeds` + `DailyCalendar` + `daily_eligible` + variations | **Wired** — calendar/catalog featured chamber + eligible fillers; geometry variation on featured |
| Content bible: one seeded chamber (+ variation) / day | Daily = featured calendar/catalog chamber leading a 5-chamber `daily_eligible` wing |
| Open Lattice as `daily_showcase` / friend-code poster | Not special-cased in daily route |
| Endless / infinite wing | **Does not exist** |
| Hard variants in `hard_order` | Loaded into `_playable` but **never offered** in campaign or daily UI |

**Effect:** Daily is “short campaign randomizer,” not the comparable friend-code ritual the content bible describes. Replay longevity leans on stars + full campaign only.

### I4 — Mirror Birth / identity bosses under-deliver on “portrait”

- Mirror Birth geometry is a generous corridor ladder — excellent first rewrite, weak as a *signature* moment (any path mirrors into a parallel scribble).
- Identity bosses tag `identity: *_signature|portrait|calcify|nameplate` and hint at intentional shapes, but **no portrait scoring, stamp readout, or fail-forward critique** exists. Boss = denser maze + same clear rule.

### I5 — Juice vs Field Ledger readability

| Art bible (document game) | Shipped juice (`juice.gd` + chamber) |
|---|---|
| No screen-shake on rewrite | Trauma shake + hitstop on rewrite/win |
| No confetti / particle spectacle | Burst particles on slam/win |
| Cadmium warn = one heartbeat | Also used in telegraph ticks + flash punches |
| Stale `07_JUICE.md` | Still documents **TS arena + pulsars + enemies** — wrong fantasy |

Reduce-motion / flash gate softens this, but default feel still borrows **impact-game punctuation** that fights “ink on paper, calcification not radiance.” Tour copy even sells “cadmium/rust particles” and “IT LEARNED YOU energy.”

### I6 — Difficulty curve: authored vs felt

- Difficulty / `par_moves` escalate across Acts (Induction 0–3 → Mastery 4–5). Good on spreadsheet.
- Felt difficulty is mostly **layout density + transform complexity**, not habit pressure: rewrite cap in JSON is not enforced as a scarce resource; safety net removes punishing walls; tempo never bites.
- Act II–IV remix volume (8–9 chambers each) risks **transform fatigue** before mastery feels earned — especially with `mirror_v` dominating the book (13/39).

### I7 — Tutorial / onboarding gaps after Act I

- Captions are one-liners; chamber `hints[]` are **not surfaced** in the HUD.
- No diegetic “what a checkpoint is” stamp beyond first Mirror Birth caption.
- No Reader mode UI despite balance defining Reader/Standard/Cold undo/rewind budgets (rewind itself is not a player verb in the chamber scene).

### I8 — Naming / content lies

- **Invert Ballet** uses `rotate_180`, not `invert` (invert code exists in `chamber.gd` but no campaign chamber teaches it).
- Vertical slice README still names old chamber titles (“It Learned You”) vs content bible slugs.
- Root `README.md` / `GAME_PLAN.md` still pitch tension/horror as Game 1 — marketing/onboarding trap for contributors.

### I9 — Meta shell drift

- Older `ECHO_LATTICE_META.md` (chamber select cards, streak semantics, modifier unlocks) describes a different shell than the VISUAL v2 single-card menu.
- Achievements / Steam rich presence mention daily and Field Ledger, but daily fairness/streak rules from the meta spec are not the playable path.

---

## 4. Act pacing (campaign)

| Act | Chambers | Pedagogic job | Pacing read |
|---|---|---|---|
| **I Induction** | 9 | Silence → Mirror Birth → thicken intro → identity | **Strong** — demo-sized wing, clear hook at chamber 3 |
| **II Reflection** | 9 | Dual-axis literacy (`mirror_v_then_h` lesson at Looking Glass) | **Good idea, soft bite** — many remixes before the portrait boss |
| **III Pressure** | 9 | Thicken as punishment fantasy | **Theme without teeth** — thicken is forced op, not habit-triggered calcify |
| **IV Mastery** | 8 + Open Lattice | Compose + sign | **Climax undercut** — no invert lesson; Open Lattice is epilogue but daily doesn’t showcase it; balance maps Act IV → Act III numbers |

**Session length risk:** 35 linear clears is long for a “toy” unless daily/endless and hard variants create legitimate short loops. Right now only Daily (5 random) shortens.

---

## 5. Tutorial / onboarding

**What works**

1. Two mute chambers before the first rewrite.
2. Caption-as-teacher (“Cross the checkpoint. Your path becomes wall.”).
3. Live telegraph of where echoes will land before commit.
4. Demo scope stops after Induction identity boss + wishlist — correct marketing funnel.

**What’s missing**

1. Explicit checkpoint literacy (stamp + one PA beat) before Mirror Birth — Echo Plate could preview a *ghost* rewrite without committing.
2. Post-rewrite coaching: first slam should freeze a beat and label “orange/rust = your mirror,” then release (hints exist in JSON unused).
3. Habit HUD appears before it matters — risk of noise; delay until first rewrite or first win screen.
4. No practice sandbox / Open Lattice from menu for “toy mode.”

---

## 6. Difficulty curve

**Strengths:** monotonic difficulty tags; bosses spike `par_moves`; BFS safety prevents rage softlocks; stars create optional mastery.

**Weaknesses:**

1. **Diegetic levers unused** — tempo, rewrite cap, soft/hard bias, mode budgets.
2. **Punishment is spatial only** — thickening denser layouts ≠ “habits hurt.”
3. **Star par uses base layout BFS**, ignoring echo tax — 3★ can undervalue intentional detours that *author* better geometry.
4. **Clear-rate targets** in balance (Act I ≥0.90, etc.) are not tied to the four-Act book or live telemetry dashboards in-product.

---

## 7. Mirror Birth moments

Treat “Mirror Birth” as both the chamber and the *class* of first-author moments.

| Moment | Intent | Audit |
|---|---|---|
| **Mirror Birth (02)** | First authorship ceremony | Hits trailer beat (telegraph → slam → fossils). Layout is forgiving; signature readability is low |
| **First thicken (07)** | Habit solidifies underfoot | Strong fantasy shift; still forced, not triggered by overuse |
| **Who Walked (08)** | Induction portrait | Needs a visible “signature score” or stamp gallery to land as boss |
| **Looking Glass (12)** | Dual-axis birth | True second birth; should get Mirror-Birth-tier ceremony (unique slam / PA) |
| **Calcify / Nameplate** | Identity climax | Same clear UX as any remix — climax is structural, not systemic |

---

## 8. Daily / endless vs campaign congruence

**Desired congruence:** same verb, same art language, comparable seeds, campaign teaches → daily tests → endless riffs.

**Actual:**

- Campaign = authored pedagogy.
- Daily = random 5 from full book (demo: Act I pool via chamber count filter only) — can front-load bosses or skip lessons.
- Endless = absent.
- Authored `seeds.json` / `calendar_90.json` / variations grammar = **content without a player door**.

Until daily uses the catalog (and variations), friend codes and “same day / same lattice” marketing are false.

---

## 9. Juice vs readability

**Keep (supports authorship readability)**

- Cadmium margin heartbeat at slam start.
- Staggered origami crease → lift → slot → rust bleed.
- Path telegraph before checkpoint.
- Audio rewrite-warn tension near unused checkpoints.

**Cut or demote (hurts document fantasy)**

- Default screen shake / hitstop on rewrite (art bible forbids; keep only as optional “Impact” accessibility, default off).
- Spark bursts that read as combat juice; replace with ink-dust / chalk scuff decals.
- Full-screen flash peak on win — prefer stamp print + paper turn.

**Doc debt:** rewrite `07_JUICE.md` against Godot Field Ledger reality; archive the TS pulsar arena as non-product.

---

## 10. Field Ledger art language consistency

| Surface | Consistency |
|---|---|
| Chamber materials / palette | **High** — paper, ink, rust, slate, copper |
| Main menu index card | **High** — brand-first ledger |
| Rewrite slam | **High** (visual) / **Mixed** (juice overlays) |
| HUD habit string + stars | **Medium** — functional, not yet diegetic punch-card / seed header in-chamber |
| Wing tints (Blueprint / Newsprint / Slate) | **Absent** — all Acts share Wing I Field Ledger paper |
| Capsule / trailer stills | Placeholders / tour shots; full marketing set still open |

**Consistency risk:** selling “no glow” while shipping particle bursts + shake teaches streamers the wrong visual verb.

---

## 11. Thesis vs shipped systems (checklist)

| System | Authored | Wired to play | Serves thesis |
|---|---|---|---|
| Forced path transforms | Yes | Yes | Core |
| Ghost trail + telegraph | Yes | Yes | Core |
| Origami slam + fossil tiles | Yes | Yes | Core fantasy |
| BFS safety net | Yes | Yes | Fair toy |
| Stars / best moves | Yes | Yes | Replay bait |
| Habit direction profile | Yes | HUD/audio only | Cosmetic |
| Habit archetypes → counters | Yes | **No** | Thesis gap |
| RewriteScoreBias | Yes | **No** | Thesis gap |
| Tempo / STALLED | Spec + JSON | **No** | Dead lever |
| Reader / Cold modes | JSON | **No** UI | Dead lever |
| Rewind budgets | JSON | **No** verb | Dead lever |
| DailySeeds / Calendar / variations | Yes | **No** | Meta gap |
| Hard variants | Yes | **No** entry | Content gap |
| Identity portrait scoring | Tags/hints | **No** | Boss gap |
| Invert transform | Code | **No** chamber | Naming trap |
| Endless mode | — | — | Missing loop |
| Enemies / pulsar arena (old juice doc) | Legacy doc | Not in Godot product | Reject mash |

---

## 12. Upgrade proposals (impact × effort)

Impact: **H** high / **M** medium / **L** low · Effort: **S** small / **M** medium / **L** large  
Sorted by **impact first**, then lower effort.

### P0 — Do next (thesis + congruence)

| ID | Proposal | Impact | Effort | Notes |
|---|---|---|---|---|
| **U1** | **Wire daily to `DailyCalendar` → `DailySeeds`, honor `daily_eligible`, apply variations** | H | S–M | **Done** on fix-daily-calendar — palette axis still cosmetic-only |
| **U2** | **Make habit reactivity visible once per chamber** — e.g. overuse rust raises thicken bias *or* archetype picks among legal soft ops when `forced_op` allows soft choice | H | M | Smallest honest “it answered you”; keep determinism via seed |
| **U3** | **Identity boss stamp** — on clear, render echo silhouette to a ledger card; optional 2★/3★ from signature metrics (symmetry, negative-space face, non-thrash) | H | M | Turns Who Walked / Nameplate into real Mirror Birth kin |
| **U4** | **Reconcile acts: either 4 balance acts or map Mastery uniquely; stop clamping 4→3** | H | S | Unblocks star/window truthfulness |
| **U5** | **Juice default = document** — shake/hitstop/particles off or microscopic; slam + cadmium heartbeat primary | H | S | Aligns art bible, readability, a11y |

### P1 — Pacing / onboarding / difficulty

| ID | Proposal | Impact | Effort | Notes |
|---|---|---|---|---|
| **U6** | Surface first hint after first failed-looking rewrite or on pause; Echo Plate ghost-preview | M–H | S | Cheap tutorial lift |
| **U7** | **Hard variants menu row** after parent clear (“Mirror Birth+”) | M | S | Uses existing JSON; daily spice |
| **U8** | **Open Lattice / sandbox from menu** as endless-lite (reroll seed, same transform grammar) | M–H | M | Supplies missing endless without a new genre |
| **U9** | Looking Glass second-ceremony (unique PA + slam chroma within ledger) | M | S | Marks dual-axis birth |
| **U10** | Trim or gate Act II–III remix count behind stars / optional wing (keep lessons+boss mandatory) | M | M | Fights fatigue; keeps pure fantasy |
| **U11** | Star par includes post-rewrite shortest path or “echo tax” pad | M | S–M | Rewards intentional authorship |

### P2 — Systems cleanup (stop lying)

| ID | Proposal | Impact | Effort | Notes |
|---|---|---|---|---|
| **U12** | Ship **invert** as Mastery lesson; rename Invert Ballet or retarget transform | M | S–M | Fixes content lie |
| **U13** | Either implement Reader/Cold + rewind **or** delete from balance JSON / docs | M | S or M | Dead dials erode trust |
| **U14** | Either implement tempo/STALLED **or** remove `tempo_*` from chambers/balance | L–M | S | Prefer remove for pure puzzle fantasy |
| **U15** | Rewrite `07_JUICE.md`; archive TS enemy slice; fix slice README titles | L | S | Doc hygiene |
| **U16** | Point root README / GAME_PLAN Game 1 at habit→geometry puzzle (keep horror as research history) | L | S | Contributor congruence |
| **U17** | Act paper tints (Blueprint / Newsprint / Slate) per art bible wings | M | M | Art language progression without new mechanics |

### P3 — Stretch (post-RC1, still pure)

| ID | Proposal | Impact | Effort | Notes |
|---|---|---|---|---|
| **U18** | Cross-run chalk ghost (your best / yesterday’s daily) | M | M | Authorship social without MP |
| **U19** | Workshop-lite: stamp share of identity silhouettes | M | L | Only if still offline-first |
| **U20** | True endless: grammar variations on daily_showcase pool with rising soft/hard bias | H | L | Only after U1–U2 so endless stays congruent |

---

## 13. Recommended sequencing (no mash)

1. **Truth pass:** U4, U5, U15, U16 — stop contradicting the Field Ledger fantasy.  
2. **Meta congruence:** U1, U7, U8 — daily/hard/sandbox match campaign verb.  
3. **Thesis pass:** U2, U3, U6, U9 — reactive authorship + Mirror Birth kinship.  
4. **Curve pass:** U10, U11, U12, then U13/U14 delete-or-ship.  
5. **Stretch:** U17–U20.

Avoid: reintroducing pulsars/enemies, horror stakes meters, deckbuilder transforms-as-cards, or idle automation — all violate the pure habit→geometry product.

---

## 14. Acceptance tests for “audit debt paid”

A future build can claim the thesis when:

1. A blind playtester can say *“it punished my looping”* (or similar) after Act II without reading HUD jargon.  
2. Two players on the same UTC daily get the **same chamber + variation** from the catalog/calendar.  
3. Identity bosses produce a **visible ledger stamp** that differs by route, not only move count.  
4. Default rewrite feel is paper-fold first; shake/particles are opt-in.  
5. No shipped doc describes enemies, SEED/GROWTH/PRISM-only arcs, or horror vignette as the live product fantasy without a “superseded” banner.

---

## 15. Evidence index

| Topic | Primary paths |
|---|---|
| Campaign / Acts | `game/echo_lattice/content/acts.json`, `content/chambers/*.json` |
| Play loop | `scripts/chamber.gd`, `game_state.gd`, `main.gd` |
| Habit unused counters | `scripts/habit_archetype.gd`, `rewrite_score_bias.gd`, `config/balance_v2.json` |
| Daily mismatch | `game_state.gd` `start_daily_run` vs `daily_seeds.gd` / `daily_calendar.gd` |
| Art language | `05_ART_BIBLE.md`, `palette.gd`, `14_VISUAL_V2.md` |
| Juice conflict | `07_JUICE.md` (stale), `scripts/juice.gd`, art bible §5 |
| Demo Mirror Birth | `docs/RELEASE/DEMO_SPEC.md`, `scripts/demo_build.gd` |

---

*End of audit. Cloud-only design/gameplay review; no gameplay code changes in this PR.*
