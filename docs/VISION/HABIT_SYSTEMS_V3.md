# Echo Lattice — Habit Systems V3

**Doc ID:** `docs/VISION/HABIT_SYSTEMS_V3.md`  
**Status:** Vision / implementation contract (CLOUD ONLY — no gameplay code in this PR)  
**Compiled:** 2026-08-09  
**Product fantasy (locked):** pure **habit → geometry** Field Ledger labyrinth. No genre mash.  
**Ground truth:** `HabitSignature` · `HabitArchetype` · `HabitRewriteLever` · `RewriteScoreBias` · `IdentityStamp` · `balance_v2.json` · chamber `rewrite{}` · RC1 audit U2/U3  
**Companions:** [`../ECHO_LATTICE/14_BALANCE_V2.md`](../ECHO_LATTICE/14_BALANCE_V2.md) · [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) · [`../AUDIT/DESIGN_GAMEPLAY.md`](../AUDIT/DESIGN_GAMEPLAY.md) · [`../AUDIT/PRODUCT_UPGRADES.md`](../AUDIT/PRODUCT_UPGRADES.md)

---

## 0. Verdict (read this first)

| Question | Answer |
|---|---|
| What is Habit V3? | The layer that makes the lattice **answer how you walk**, not only **where you walked**. |
| What ships today (RC1)? | Forced transforms + additive habit lever (`place_deflector` / `fossilize_hot_cell`) + IdentityStamp code — **thin bite**, ceremony incomplete. |
| What V3 demands? | Archetypes that **READ**, soft/hard that **TEACH**, Mirror Birth **setpieces**, identity scoring as **drama** (not HUD spam). |
| North-star player line | *“It punished my looping.”* — said after Act II, without reading jargon. |
| Hard rule | Deterministic · BFS-safe · offline · Field Ledger voice · stars never gate story. |

**One sentence:** Habit V3 turns the rewrite commit into a **readable critique** of the player's handwriting — taught by bias, staged by ceremony, scored as portrait — while forced transforms remain the pedagogic spine.

```
Walk → signature READ → soft/hard TEACH → operator pick →
forced transform + habit cells → telegraph / slam →
(birth / identity?) ceremony stamp → ledger memory
```

---

## 1. Why V3 exists

### 1.1 Thesis gap (from RC1 audit)

| Claim | Player should feel | V2 / RC1 reality |
|---|---|---|
| Habit → geometry | My path becomes architecture | **Yes** — forced transform fossils |
| Reactive authorship | The lattice answers my *style* | **Thin** — lever exists; few ops propose; feedback is mostly HUD/audio |
| Soft/hard as pedagogy | Bias *introduces* counters, then *tightens* them | **Numbers only** — bias gates cell count / hard ops, does not teach |
| Mirror Birth kinship | First authorship + Looking Glass + bosses are ceremonies | **Partial** — slam exists; setpiece contract incomplete |
| Identity as drama | Bosses judge the portrait | **Code present** — stamp grades exist; drama framing under-specified |

V3 does **not** replace forced transforms. It specifies how habit reactivity, teaching bias, ceremony, and portrait drama sit *beside* the content bible spine so the toy stops lying about “it learned you.”

### 1.2 Design laws

1. **Read before punish.** Classification with low confidence must stay `balanced` and soft.  
2. **Teach before harden.** Soft ops appear as coaching; hard ops arrive after the lesson is legible.  
3. **Geometry is the sentence.** If feedback needs a stat strip to be understood, rewrite the operator or the telegraph.  
4. **Ceremony is scarce.** Mirror Birth–class beats are authored setpieces, not every remix.  
5. **Portrait ≠ grade spam.** Identity scores become ink, pause, PA — never a live DPS meter.  
6. **BFS wins.** Score bias never overrides solvability.  
7. **Determinism.** Same seed + same walk + same mode → same habit cells and stamp.

---

## 2. Vocabulary

| Term | Means | Not |
|---|---|---|
| **HabitSignature** | Features from move ring + visit histogram | A personality quiz |
| **Archetype** | Stable play pattern with counters (`right_leaner`, `looper`, `zigzagger`, `balanced`) | A character class the player picks |
| **READ** | Features → archetype with confidence + diegetic *evidence cells* | Showing `turn_rate: 0.61` in HUD |
| **Operator** | Named rewrite atom that proposes cells (`place_deflector`, …) | A card / ability button |
| **Forced op** | Chamber-authored transform (`mirror_v`, `thicken`, …) | Habit counter |
| **Habit cells** | Additive echo cells from `HabitRewriteLever` after forced candidates | Replacing the forced transform |
| **Soft / hard** | Coaching vs calcifying counter families | Easy / hard difficulty modes |
| **Soft/hard bias** | `[0,1]` teaching pressure: how many habit cells, whether hard ops unlock | HP or damage |
| **Mirror Birth setpiece** | Authored first-author (or dual-axis) ceremony with freeze / label / stamp | Any `mirror_v` remix |
| **Identity stamp** | Echo silhouette + portrait metrics + grade (`scribble` / `readable` / `signed`) | Live ★ counter mid-chamber |
| **Drama beat** | Timed, scarce presentation of critique | Always-on HUD chrome |

---

## 3. Archetypes that READ

Classification already lives in `habit_archetype.gd` + `balance_v2.json`. V3 adds a **reading contract**: every classification must produce player-legible *evidence*, not just an id string.

### 3.1 Feature vector (normative inputs)

From `HabitSignature` (window = act `habit_window`, min classify steps = 12):

| Feature | Intuition | Used by |
|---|---|---|
| `dominant_bias` / `dominant_dir` | Cardinal commitment | right_leaner |
| `turn_rate` | Direction chatter | zigzagger / leaner |
| `backtrack_rate` | Reverse thrash | looper / leaner |
| `unique_ratio` / `revisit_ratio` | Exploration vs circling | looper |
| `longest_streak` | Corridor addiction | leaner / zig |
| `hot_cells(k)` | Overused floor hinges | fossilize / thicken |

### 3.2 Archetype table (detect → counter → read aloud)

| Id | Detect (summary) | Primary counters | READ aloud (player language) | Evidence cells |
|---|---|---|---|---|
| `right_leaner` | High dominant bias, long streaks, low turns | `place_deflector`, `fossilize_hot_cell`, `grow_wall_far_from_path` | “You kept one heading.” | Tip of dominant streak; hot lane cell |
| `looper` | Low unique ratio, high revisit / backtrack | `fossilize_hot_cell`, `thicken_walked`, `mirror_walked_v` | “You circled the same hinge.” | Loop hinge (max visits ≥ 2) |
| `zigzagger` | High turn rate, low bias, short streaks | `grow_wall_far_from_path`, `mirror_walked_h`, soft `widen_hot_corridor` | “You never committed a line.” | Sealed far floor; optional widen on intentional corridor |
| `balanced` | Below margin / mixed | Soft `carve_shortcut`, mild `place_deflector` | Silence, or “Mixed ink.” | Shortcut mouth only when relief fires |

**Confidence rule (unchanged numbers, stronger product rule):**

- Require `confidence_margin` (0.08) over second place **and** ≥ 1.0 raw score.  
- Else `balanced` with `confidence` retained for telemetry only.  
- **Player-visible archetype name appears only when confidence ≥ act reveal threshold** (§9.3). Until then: evidence telegraph without naming.

### 3.3 Reading pipeline (runtime)

```
dirs + visits
  → HabitSignature
  → HabitArchetype.classify
  → ReadingBundle {
        id, confidence,
        evidence_cells[],          # 1–3 cells that justify the read
        reason_key,                # locale: habit.read.looper etc.
        counter_weights,
      }
  → RewriteScoreBias.apply(candidates)
  → HabitRewriteLever cell pick (soft/hard gated)
```

`ReadingBundle` is the V3 contract object. Code today returns `{cells, op, archetype, confidence, …}`; V3 adds `evidence_cells` + `reason_key` so UI/PA never invents a lecture from bare ids.

### 3.4 Anti-patterns for “READ”

| Forbidden | Why |
|---|---|
| Live “Looper 73%” meter | HUD spam; psychology jargon |
| Reclass every step with popup | Noise destroys Field Ledger calm |
| Counters without evidence cells | Feels random, not personal |
| Naming archetype before first successful counter lands | Spoils the “it answered you” beat |

**Reveal timing:** classify continuously for scoring; **name** at most once per chamber — at first habit-cell commit that used a counter weight ≠ 1.0, or on win card if never revealed.

---

## 4. Soft / hard that TEACH

Bias is not difficulty flavor text. It is a **syllabus**.

### 4.1 Soft vs hard families

| Family | Operators | Pedagogy | Player feel |
|---|---|---|---|
| **Soft** | `place_deflector`, `carve_shortcut`, `grow_wall_far_from_path`, `widen_hot_corridor`, soft mirrors as bias-only | Coach / redirect / reward intentional ink | “The page nudged me.” |
| **Hard** | `fossilize_hot_cell`, `thicken_walked` | Calcify overuse; scarce | “My habit became wall underfoot.” |

Aligned with `HabitRewriteLever.HARDNESS` + `rewrite_engine.hard_ops`. Forced chamber transforms (`thicken`, `mirror_v`, …) are **authored lessons**, not soft/hard family members — they may *stage* the same fantasy.

### 4.2 Bias as teaching phases

| Bias band | Habit cells (max) | Hard ops | Teaching job | Typical act |
|---|---|---|---|---|
| `0.00–0.19` | 0 | Off | Observe only — signature builds, no habit walls | Quiet Span / Echo Plate |
| `0.20–0.44` | 1 | Off | Soft deflector / grow / carve as first “answer” | Mirror Birth → mid Induction |
| `0.45–0.69` | 1 | On if act unlock | First fossilize / thicken habit bite | Late Induction / Reflection |
| `0.70–0.84` | 2 | On | Stacked counters under pressure | Pressure |
| `0.85–1.00` | 2 | On | Mastery pressure; identity signing | Mastery / Cold / Endless climb |

Matches lever floors (`HARD_BIAS_FLOOR = 0.45`, `_max_habit_cells`) and act defaults in Balance v2 — V3 **names the pedagogy**, not new magic numbers.

### 4.3 Mode lenses (how bias teaches differently)

| Mode | Bias role | Teaching promise |
|---|---|---|
| **Reader** | Low bias, hard ops delayed | “Learn the handwriting; the lattice is gentle.” |
| **Standard** | Act curve as written | Campaign syllabus |
| **Cold** | High bias early | “Same chambers, sterner critique.” |
| **Endless** | Bias floor climbs with depth | Syllabus without new verbs |

Modes multiply act bias; chamber `rewrite.soft_hard_bias` is a **floor** (`max(act_mode_bias, chamber_bias)` when authored ≥ 0). Authors raise floors to force a teaching beat inside a specific room.

### 4.4 Teach-then-harden chamber grammar

For each new counter family in an Act:

1. **Ghost** — telegraph evidence / soft preview without committing hard cells (Echo Plate pattern).  
2. **Soft land** — one soft op fires; PA / subtitle names the *geometry*, not the archetype.  
3. **Name** — optional archetype glyph on win or after first personal counter.  
4. **Harden** — later chamber raises bias past 0.45 so the same evidence can fossilize.  
5. **Remix** — denser layout; same family; no new lecture.

Hard variants (`mirror_birth_hard`, …) jump to step 4 of a parent lesson without skipping BFS fairness.

---

## 5. Operator specification

Two layers share the word “operator” in content today. V3 keeps both, with a hard boundary.

### 5.1 Layer A — Forced transforms (content bible)

Authored on the chamber; always the primary fossilization of the path.

| Op | Geometry | Pedagogy beat |
|---|---|---|
| `none` | No rewrite | Movement literacy |
| `mirror_v` | Mirror path across vertical axis | Mirror Birth |
| `mirror_h` | Mirror across horizontal | Axis literacy |
| `mirror_v_then_h` | Both axes | Looking Glass / portraits |
| `rotate_180` | Rotate about centre | Invert Ballet lineage (teach honestly) |
| `thicken` | Walked cells become walls | Calcify fantasy |
| `invert` *(Mastery lesson target)* | Path ↔ complementary floor rule per systems | Close content lie vs Invert Ballet |

### 5.2 Layer B — Habit counters (reactive)

Proposed by `HabitRewriteLever` / future engine; scored by `RewriteScoreBias`; gated by soft/hard + act unlock.

| Op | Family | Propose rule (normative) | Score seeds | Archetype affinity |
|---|---|---|---|---|
| `place_deflector` | Soft | Cell **ahead** of a dominant streak (≥3) that is floor and unvisited | `0.5 + streak + 1.5 * dominant_bias` | right_leaner ↑ |
| `fossilize_hot_cell` | Hard | Hot cell with visits ≥ 2, not blocked | `1.0 + visits + 0.5 * dominant_bias` | looper ↑, leaner mid |
| `thicken_walked` | Hard | Subset of walked / high-revisit ring cells (Act II+) | Density × revisit | looper ↑ |
| `grow_wall_far_from_path` | Soft | Floor far from path bbox / unvisited pocket | Distance × (1 − unique focus) | zigzagger ↑ |
| `carve_shortcut` | Soft (relief) | Opens a 1-cell notch that shortens BFS without erasing portrait | Relief weight | balanced ↑ |
| `widen_hot_corridor` | Soft (relief) | Clears a neighbor of a hot intentional corridor | Soft reward | zig intentional |
| `mirror_walked_v` | Soft/bias | Extra vertical echo of loop hinge (not full forced mirror) | Loop score | looper |
| `mirror_walked_h` | Soft/bias | Extra horizontal echo of noisy path | Zig score | zigzagger |

**Commit rules (all Layer B):**

1. Candidate list → archetype blend (`archetype_weight_blend = 0.65`).  
2. Filter by enabled ops + hard gate.  
3. Take top cells up to bias max; skip cells already claimed by forced transform.  
4. Per-cell BFS reject; never softlock.  
5. Emit telemetry `rewrite_applied` with `{forced_op, habit_op, archetype, confidence, soft_hard_bias, evidence_cells}`.

### 5.3 Operator identity (audio / ink)

Each Layer B op owns a **diegetic identity** (already sketched in audio events):

| Op | Ink cue | Audio cue | Subtitle key |
|---|---|---|---|
| `place_deflector` | Cadmium tooth ahead of streak | Soft chalk tick | `habit.op.deflector` |
| `fossilize_hot_cell` | Rust blot on hinge | Low paper stamp | `habit.op.fossilize` |
| `thicken_walked` | Corridor fills in place | Thick fold | `habit.op.thicken` |
| `grow_wall_far_from_path` | Distant margin darkens | Far scrape | `habit.op.grow` |
| `carve_shortcut` | Hairline door of bone paper | Soft tear | `habit.op.carve` |
| `widen_hot_corridor` | Margin breathes | Air release | `habit.op.widen` |

Forced transforms keep origami slam chroma; habit ops are **secondary ink** — never a second full-screen spectacle on the same commit (reduce-motion: skip bursts, keep cell role colors).

### 5.4 Score blending (normative)

```
final = base * (1 - blend) + base * blend * weight(op, archetype)
```

Missing weight = `1.0`. Relief ops stay available even when counters dominate so commitment still pays (Balance v2). BFS rejection > any score. `score_jitter` stays tiny and seeded.

---

## 6. Mirror Birth setpieces

“Mirror Birth” is both chamber `02_mirror_birth` and a **class of ceremony**. V3 specifies the class so Looking Glass and identity bosses feel like kin, not denser remixes.

### 6.1 Setpiece roster (authored)

| Beat | Chamber / slug | Transform | Ceremony tier | Job |
|---|---|---|---|---|
| **First Birth** | `mirror_birth` | `mirror_v` | S | Product hook — path becomes wall |
| **Ghost Preview** | `echo_plate` (pre-birth) | `none` + ghost | A | Checkpoint literacy without commit |
| **Second Birth** | `looking_glass` | `mirror_v_then_h` | S | Dual-axis authorship |
| **Hard Birth** | `mirror_birth_hard` / `looking_glass_hard` | parent | A | Optional stern remix |
| **Induction Portrait** | `identity_induction` | `mirror_v` | S | Who Walked stamp |
| **Reflection Portrait** | `identity_reflection` | `mirror_v_then_h` | S | Portrait boss |
| **Calcify** | `identity_pressure` | `thicken` | S | Habit solidifies as judgment |
| **Nameplate** | `nameplate` | `mirror_v_then_h` | S | Final sign |

Tier **S** = full ceremony script (§6.2). Tier **A** = shortened (telegraph + stamp or ghost only).

### 6.2 Ceremony script (S-tier)

Timed beats; skip micro-pauses under reduce-motion / flash gate.

| Step | Timing | Player-visible | Systems |
|---|---|---|---|
| 1. Approach | On enter C radius | Cadmium margin heartbeat; telegraph forced + habit evidence (distinct tint roles) | Existing telegraph + `habit_telegraph_cells` |
| 2. Commit | On C | Origami slam for forced fossils | `Juice` document defaults |
| 3. Habit ink | +0–120 ms | Habit cells settle with operator identity (§5.3), not a second slam | `last_habit_op` |
| 4. Freeze label | +200–400 ms hold | One Field Ledger line: geometry truth (“orange/rust = your mirror”) | Caption / PA; **not** archetype % |
| 5. Release | Hold end | Control returns; buffer clear | — |
| 6. Clear stamp | On goal | Birth: ceremony stamp only. Identity: stamp + optional ★ merge | `IdentityStamp` |
| 7. Ledger tuck | Win card | Silhouette plate + one grade word (`Signed` / `Readable` / `Scribble`) | `identity_stamp_card.gd` |

**Looking Glass** uses a unique slam chroma / PA line within ledger language (audit U9) — same script, second-birth voicing.

### 6.3 What Mirror Birth must *not* do

- Host stat strips, schedules, or “habit radar” widgets in the first viewport of the ceremony.  
- Overlay detached badges on hero fossil media.  
- Require a correct portrait to clear (resonance stays `REACH_GOAL`).  
- Fire hard habit ops at bias `< 0.45` (First Birth stays soft / forced-only unless author floor says otherwise — shipped `soft_hard_bias: 0.25`).

### 6.4 Authoring flags

```jsonc
{
  "spectacle": true,          // existing — marks birth-class presentation
  "onboarding": true,         // existing
  "ceremony": {
    "tier": "S",              // S | A | none
    "pause_ms": 320,
    "label_key": "ceremony.mirror_birth.label",
    "stamp_on_clear": true,
    "second_birth": false
  }
}
```

Until schema lands, `spectacle` + `IdentityStamp.is_birth_moment` remain the runtime detectors; `ceremony{}` is the V3 authoring hook.

---

## 7. Identity scoring as drama (not HUD spam)

### 7.1 What is scored

`IdentityStamp.evaluate` already computes:

| Metric | Weight | Meaning |
|---|---|---|
| `symmetry` | 0.42 | Echo silhouette respects transform axis |
| `negative_space` | 0.33 | Face / figure readability in voids |
| `non_thrash` | 0.25 | Unique ink vs move thrash |
| → `portrait` | — | Clamped blend |
| → `grade` | — | `scribble` <0.45 · `readable` <0.72 · `signed` ≥0.72 |
| → `portrait_stars` | — | 1 / 2 / 3 from thresholds |

### 7.2 When scores touch the player

| Context | Stars merge? | Presentation |
|---|---|---|
| Mirror Birth / Looking Glass | **No** (`affects_stars = false`) | Ceremony stamp + grade word only |
| Identity bosses | **Yes** — `merge_stars(move_stars, portrait_stars)` | Stamp plate, grade, optional one-line critique |
| Remix / lesson | No stamp | Silence |
| Daily featuring identity | Same as boss rules for that chamber | Friend-code comparable silhouette |

Progression **never** requires `signed`. Scribble still clears. Stars remain optional mastery bait.

### 7.3 Drama beats (replace meters)

| Beat | Trigger | On screen | Off screen (forbidden) |
|---|---|---|---|
| **Ink settle** | Boss clear | Stamp draws cell-by-cell (chalk → rust) | Radar charts |
| **Grade word** | After stamp | Single ledger verb: Scribble / Readable / Signed | Percentages |
| **Critique line** | If grade ≤ readable | Localized `identity.critique.*` from dominant weak metric | Feature dump |
| **Museum tuck** | If Museum enabled | Self row title from archetype template | Live archetype HUD during boss |
| **Retry hunger** | Scribble clear | Soft invite: “Sign it cleaner?” — never blocking | Fail state / game over |

Critique mapping (player language):

| Weakest metric | Line intent |
|---|---|
| Symmetry | “The fold doesn’t recognize itself.” |
| Negative space | “The face never opened.” |
| Non-thrash | “Too much ink. Fewer steps next signing.” |

### 7.4 HUD policy (normative)

| Surface | Allowed habit / identity UI |
|---|---|
| During walk | Punch-card moves; path telegraph; **no** archetype label |
| Near checkpoint | Telegraph forced + habit evidence cells (role colors) |
| Mid-rewrite | Slam / habit ink only |
| Win card | Stars; optional archetype glyph **once**; stamp plate on birth/identity |
| Pause | Hints may surface; no live portrait % |
| Museum / replay | Vignette path + stamp — atmosphere, not score overlay |

If a widget can be removed without hurting interaction or understanding, remove it (Field Ledger rule).

---

## 8. Player-visible feedback map

End-to-end “I felt seen” channels — ranked by honesty.

| Channel | Priority | Habit V3 use |
|---|---|---|
| **Geometry** | P0 | Habit cells + forced fossils *are* the feedback |
| **Telegraph** | P0 | Evidence cells tint before commit (habit vs forced roles) |
| **Operator ink / audio** | P1 | Secondary identity per §5.3 |
| **PA / subtitle** | P1 | Geometry truth; rare archetype name |
| **Ceremony pause** | P1 | Birth / identity only |
| **Stamp / grade word** | P1 | Clear of birth / boss |
| **Win glyph** | P2 | Archetype mark after reveal threshold |
| **Adaptive music** | P2 | Already consumes profile — keep under speech |
| **Numeric HUD** | P3 | Dev / Reader assist only; default off |

### 8.1 Feedback budget per chamber

- ≤ **1** archetype naming event.  
- ≤ **1** ceremony pause (S-tier).  
- Habit cells ≤ bias max (0–2).  
- Subtitles: checkpoint arm + rewrite family + optional one habit op line.  
- No stacked popups.

### 8.2 “It answered you” acceptance lines

Playtesters should be able to say at least one of:

1. “It blocked the way I always go.” (`place_deflector` / grow)  
2. “The spot I kept touching turned solid.” (`fossilize` / thicken)  
3. “The stamp looked like my route.” (identity / birth)  
4. “Looking Glass felt like a second birth.” (ceremony kinship)

Without saying: “I watched my looper percentage climb.”

---

## 9. Chamber authoring hooks

V3 extends the content bible without breaking PR #48 playable shape. Loader keeps exposing `{id, title, caption, transform, map}` plus richer play fields already threaded (`soft_hard_bias`, identity, spectacle).

### 9.1 `rewrite{}` (extended)

```jsonc
"rewrite": {
  "cap": 1,
  "forced_op": "mirror_v",
  "soft_hard_bias": 0.25,
  "require_shorter_or_equal": false,

  // V3 hooks
  "habit_ops_allow": ["place_deflector"],      // subset; omit = balance defaults
  "habit_ops_deny": ["fossilize_hot_cell"],    // authorship veto
  "habit_cells_max": null,                     // null = bias table; int overrides
  "require_habit_op": false,                   // true = teaching room must land a soft cell if legal
  "reading": {
    "reveal_archetype": "on_counter",          // never | on_counter | on_clear | always_debug
    "evidence_telegraph": true
  }
}
```

### 9.2 `ceremony{}` / identity hooks

```jsonc
"identity": "induction_signature",
"spectacle": true,
"ceremony": {
  "tier": "S",
  "pause_ms": 320,
  "label_key": "ceremony.mirror_birth.label",
  "stamp_on_clear": true,
  "second_birth": false,
  "critique_on_scribble": true
},
"portrait": {
  "affects_stars": true,          // bosses true; births false even if omitted
  "target_grade": "readable",     // authoring intent for QA, not a fail gate
  "mask_hint": "vertical_bar"     // optional designer note for intended silhouette
}
```

### 9.3 Act reveal thresholds (defaults)

| Act | Name archetype when confidence ≥ | Default reveal mode |
|---|---|---|
| Induction | 0.90 | `on_clear` (glyph only) |
| Reflection | 0.75 | `on_counter` |
| Pressure | 0.65 | `on_counter` |
| Mastery | 0.60 | `on_counter` |

Reader mode forces `on_clear` minimum naming; Cold may use `on_counter` earlier.

### 9.4 Motif banner vs habit reason

- `motifs[].banner` / `caption` — authored lesson line (human).  
- `reason_key` from ReadingBundle — reactive line (system).  
Never show both at once on first Birth; banners win until post-clear.

### 9.5 Schema / validator TODOs

1. Extend `chamber.schema.json` with `ceremony`, `portrait`, `rewrite.habit_*`, `rewrite.reading`.  
2. `validate_chambers.py`: bias ∈ [0,1]; deny/allow ops ⊂ known Layer B set; births have `spectacle` or `ceremony.tier`.  
3. Playthrough author: if `require_habit_op`, solver walk must produce ≥1 habit cell under Standard.  
4. Content bible gains a “Habit V3 hooks” subsection pointing here as authority for reactive fields; forced transforms remain bible-owned.

### 9.6 Author checklist (per chamber)

- [ ] One teaching job stated in `teaches` / caption.  
- [ ] `soft_hard_bias` matches syllabus phase (§4.2).  
- [ ] Habit allow/deny lists do not contradict the lesson (no fossilize in first soft land).  
- [ ] If `ceremony.tier = S`, label_key + stamp path verified.  
- [ ] Identity bosses: intended silhouette noted in `portrait.mask_hint`; clearable via `REACH_GOAL` with scribble.  
- [ ] BFS base + post-rewrite solvability.  
- [ ] Hints exist for pause surfacing (audit U6).

---

## 10. Act syllabus (habit × ceremony)

| Act | Forced spine | Habit teaching | Ceremony |
|---|---|---|---|
| **I Induction** | none → mirror_v → thicken intro | Bias 0.25 soft deflector; hard off until index ≥ 4 | Mirror Birth S; Who Walked S |
| **II Reflection** | dual-axis literacy | Bias 0.50; fossilize on; archetype named on counter | Looking Glass S; Portrait S |
| **III Pressure** | thicken / multi-commit | Bias 0.72; up to 2 habit cells; loops hurt | Calcify S |
| **IV Mastery** | compose + invert honesty | Bias 0.85; counters as signature pressure | Nameplate S; Open Lattice toy |

Daily / Endless / Hard+ reuse the same operators and stamp rules — no parallel genre systems.

---

## 11. Runtime module map (implementation targets)

| Module | V3 job |
|---|---|
| `habit_signature.gd` | Features + hot cells (stable) |
| `habit_archetype.gd` | Classify + weights; emit ReadingBundle fields |
| `rewrite_score_bias.gd` | Blend sort (stable) |
| `habit_rewrite_lever.gd` | Expand proposers beyond deflector/fossilize; honor allow/deny / max |
| `chamber.gd` | Telegraph evidence; ceremony pause; habit ink channel |
| `identity_stamp.gd` / `_card.gd` | Drama presentation contract |
| `balance_tuning.gd` / `balance_v2.json` | Bias bands, reveal thresholds, op registry |
| `chamber.schema.json` + validators | Authoring hooks |
| `AudioDirector` / locale | `habit.op.*`, `habit.read.*`, `ceremony.*`, `identity.critique.*` |
| `museum_of_selves.gd` | Store stamp + archetype for vignette titles |
| Local telemetry | `archetype_classified`, habit op ids, stamp grades, ceremony shown |

---

## 12. Sequencing (implementation, not calendar)

Impact-first, pure fantasy only.

| Step | Deliverable | Pays off |
|---|---|---|
| **H1** | ReadingBundle + evidence telegraph | Archetypes READ |
| **H2** | Ceremony script on Birth + Looking Glass | Setpiece kinship |
| **H3** | Win-card stamp drama (grade word, no %) | Identity as drama |
| **H4** | Author hooks in schema + 2–3 teaching chambers tuned | Soft/hard TEACH |
| **H5** | Expand proposers (`grow`, `carve`, `thicken_walked`) under gates | Depth without new verbs |
| **H6** | Reader/Cold surface **or** delete dead dials | Stop lying (audit U13) |
| **H7** | Invert lesson honesty + Nameplate critique lines | Mastery closure |

Do **not** sequence: enemy/pulsar juice, habit RPG stats, LLM portraits, live-service seasons.

---

## 13. Acceptance tests

| ID | Check |
|---|---|
| HV3-1 | Blind Act II playtester states a personal counter without HUD jargon. |
| HV3-2 | Same seed + walk → identical habit cells and stamp mask. |
| HV3-3 | Bias `< 0.45` never commits hard ops; `≥ 0.45` may when unlocked. |
| HV3-4 | Forced transform always primary; habit cells additive and BFS-safe. |
| HV3-5 | Mirror Birth shows ceremony label once; no archetype % during slam. |
| HV3-6 | Identity scribble still clears; `signed` can raise ★ via merge only on bosses. |
| HV3-7 | Looking Glass triggers second-birth voicing (PA/chroma), not generic remix UX. |
| HV3-8 | Chamber with `habit_ops_deny: ["fossilize_hot_cell"]` never selects that op. |
| HV3-9 | Default UI has zero live habit meters; win glyph ≤ 1 per chamber. |
| HV3-10 | Telemetry includes archetype, habit_op, evidence count, stamp grade; `user://` only. |
| HV3-11 | Reduce-motion: skips ceremony hold micro-juice; keeps fossils + stamp. |
| HV3-12 | Offline Python parity tests cover new proposers + allow/deny (`test_habit_rewrite_wire.py` lineage). |

---

## 14. Non-goals

- Archetype as selectable class / loadout.  
- Online personality models or cloud learning.  
- Replacing forced transforms with fully generative mazes.  
- Combat, HP, horror stakes, deckbuilder ops-as-cards.  
- Always-on radar, damage numbers, or “habit XP.”  
- Failing the campaign for a bad portrait.  
- Tempo/STALLED as required V3 spine (delete-or-ship separately; habit drama does not need a clock).

---

## 15. Doc authority

| Topic | Wins |
|---|---|
| Forced transforms, lattice ASCII, acts roster | `04_CONTENT_BIBLE.md` |
| Numeric bias / windows / star math | `balance_v2.json` (intent: `14_BALANCE_V2.md`) |
| Habit READ / TEACH / ceremony / drama / author hooks | **This doc (V3)** |
| Art / juice language | `05_ART_BIBLE.md`, `14_VISUAL_V2.md` |
| RC1 gap list | `AUDIT/DESIGN_GAMEPLAY.md` |

If JSON numbers and Balance v2 disagree, JSON wins on values; if intent disagrees with this vision on *feedback drama* or *teaching bias*, this vision wins and numbers/docs are updated together.

---

## 16. Evidence index

| Topic | Paths |
|---|---|
| Signature / archetype / lever | `game/echo_lattice/scripts/habit_*.gd`, `rewrite_score_bias.gd` |
| Chamber wire | `game/echo_lattice/scripts/chamber.gd` (`_select_habit_rewrite_cells`) |
| Identity drama code | `identity_stamp.gd`, `identity_stamp_card.gd` |
| Balance numbers | `game/echo_lattice/config/balance_v2.json` |
| Birth chamber | `content/chambers/02_mirror_birth.json` |
| Habit offline tests | `tests/test_habit_rewrite_wire.py` |
| Museum / vignette | `museum_of_selves.gd`, `habit_replay_vignette.gd` |

---

*End of Habit Systems V3. Cloud-only vision contract; implementation lands in follow-up code PRs against the Echo Lattice playable tree.*
