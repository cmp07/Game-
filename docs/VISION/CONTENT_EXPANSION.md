# Echo Lattice — Content Expansion Vision

**Doc:** `docs/VISION/CONTENT_EXPANSION.md`  
**Status:** Planning / vision (no chamber JSON in this PR)  
**Authority today:** [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) · [`../AUDIT/CONTENT_CHAMBERS.md`](../AUDIT/CONTENT_CHAMBERS.md) · [`../RELEASE/ROADMAP.md`](../RELEASE/ROADMAP.md)  
**Baseline:** RC1 roster — **35 campaign + 4 hard = 39** authored chambers, four acts (Induction → Reflection → Pressure → Mastery).

**North star:** A volume *and* quality jump that makes every wing feel authored — not recolored — and makes Hard a second campaign track, not a par multiplier.

---

## 0. Verdict (read this first)

| Question | Answer |
|---|---|
| More acts or denser four? | **Denser 4 first**, then **Act V (Afterimage)** as the headline volume pack. Do **not** ship six acts in one jump. |
| Why not 5–6 in the base book? | Four acts already match balance SEED→MASTERY and the demo/marketing story. A fifth act needs one new pedagogical idea (`invert` **or** true compose). A sixth act without a new verb is remix bloat. |
| What “quality” means here | Unique geometry, honest hard parents, readable identity portraits, one setpiece per act, teach→test roles that match the bible. |
| What “volume” means here | Roughly **~55–65 campaign clears + ~14–18 hard** across denser-4 + Act V — not 100 thin maps. |
| Fence | Keep **Act V / `invert` out of 1.0** per Roadmap unless leadership explicitly reopens the fence. Denser-4 quality work *can* land in 1.0 or Free Update #1. |

```
Phase A (quality): denser Acts I–IV + real Hard track
Phase B (volume):  Act V Afterimage (+ optional Act VI only if a second new verb earns it)
```

---

## 1. Baseline debt (why expansion cannot be “add files”)

From the content chambers audit — treat as preconditions, not optional polish:

| Debt | Why it blocks expansion |
|---|---|
| Exact / near map clones | New chambers on a clone template inflate count without novelty |
| Hard variants with wrong parent / same floor | Players learn Hard is a lie → second track dies |
| Identity bosses sharing footprints (`08`≈`33`) | Act climax fails the brand promise |
| `invert_ballet` name lie | Burns the Act V / invert unlock |
| Composition tagged but single `forced_op` | Mastery fantasy under-delivers |
| Hint / caption / role tag drift | Pedagogy collapses as roster grows |

**Gate rule:** no net-new campaign chamber merges until Hamming-distance clone detector stays green and every hard lists an honest `hard_variant_of` with measurable tighten (floor −≥12% **or** −1 checkpoint **or** choke geometry the parent lacks).

---

## 2. Act structure decision

### 2.1 Options compared

| Option | Shape | Pros | Cons | Verdict |
|---|---|---|---|---|
| **A. Denser 4** | Keep I–IV; +2–4 unique chambers/act; setpiece pass; Hard ×3–4/act | Fits balance doc; demo story intact; fastest quality lift | Store still says “four acts”; less headline volume | **Do first** |
| **B. Five acts** | I–IV denser + **V Afterimage** | Clean DLC/free-update story; one new lesson wing; Museum titles expand | Needs systems for `invert` **or** player-compose; save/depot work | **Do second** |
| **C. Six acts** | V + VI (e.g. Invert then Compose, or Epilogue wing) | Max shelf depth | Transform fatigue; dilutes identity-boss meaning; pricing/scope risk at $6.99 | **Defer** — only if V proves demand |

### 2.2 Recommended spine

Keep the four pedagogical jobs; thicken them; then add one post-mastery wing.

| Act | Id | Job (unchanged) | Denser-4 target (campaign) | Hard track target |
|---|---|---|---|---|
| **I — Induction** | `induction` | Silence → first rewrite → base ops | 9 → **10–11** (protect demo path `00`–`08`) | 1 → **3** (one per early pillar lesson) |
| **II — Reflection** | `reflection` | Dual-axis literacy → portrait | 9 → **11–12** | 1 → **3–4** |
| **III — Pressure** | `pressure` | Habits hurt; multi-commit nets | 9 → **11–12** | 1 → **3–4** |
| **IV — Mastery** | `mastery` | Compose + sign + epilogue | 8 → **10–11** (+ Open Lattice stays showcase) | 1 → **3–4** |
| **V — Afterimage** | `afterimage` | New verb / compose-forward wing | **0 → 8–10** (+ boss) | **0 → 2–3** |
| **VI — (optional)** | TBD | Only if V needs a sequel verb | — | — |

**Campaign clears after Phase A:** ~44–46 (+ ~12–14 hard).  
**After Phase B:** ~52–56 campaign (+ ~14–18 hard).  
That is the volume band — handmade, validator-green, clone-free.

### 2.3 Why denser 4 before a fifth act

1. **Demo & store copy** already sell Induction → Mastery; denser 4 raises review quality without rewriting the funnel.
2. **Balance v2** already maps four acts; a fifth needs a new row (window, cap, clear-rate ideal) — do that with Act V, not by splitting Mastery into two thin acts.
3. **Fatigue:** Act II–IV already risk remix fatigue (`mirror_v` heavy). Adding Act VI *without* a new verb worsens that.
4. **Roadmap alignment:** Act V Afterimage is already the paid/optional volume headline; this vision fills in *what goes inside* denser 4 so Act V is not asked to paper over a thin base game.

---

## 3. Setpiece program (one job per beat)

A **setpiece** is a chamber (or short pair) that earns a trailer still, a Museum plaque, or a “I can’t believe the room did that” clip. Not every remix is a setpiece.

### 3.1 Required setpieces (Phase A — denser 4)

| # | Act | Working title | Beat | Design brief |
|---|---|---|---|---|
| S1 | I | **Mirror Birth** (keep) | First authorship | Already the demo hook — protect path budget; do not bury with new pre-hooks |
| S2 | I | **Who Walked** (rebuild) | Induction identity | Distinct geometry from Nameplate; intended solve leaves a vertical-bar “signature” |
| S3 | II | **Looking Glass** (keep + face scaffold) | Dual-axis lesson | Light authored “face frame” walls so Portrait is readable even on imperfect paths |
| S4 | II | **Portrait** (rebuild) | Reflection identity | Open hall → gallery with asymmetric pillars; dual-axis fossil should read as a face/mask |
| S5 | III | **Cement Trail → Panic Lattice** pair | Pressure thesis | Thicken must *cost* floor the player wanted; Panic is not Gallery Walk with a new title |
| S6 | III | **Calcify** (rebuild) | Pressure identity | Intended solve leaves a dense “scar” mass; multi-commit with honest `rewrite.cap` |
| S7 | IV | **Habit Orchestra / Signature Stack** | Composition | At least one chamber with **sequenced forced ops** (C1≠C2 op) *or* player-picked op — systems-gated |
| S8 | IV | **Nameplate** (rebuild) | Mastery identity | New footprint; three-commit nameplate that is not Induction’s hall |
| S9 | IV | **Open Lattice** (elevate) | Daily / toy showcase | Second showcase sibling optional; Museum screenshot seed attached |

### 3.2 Act V setpieces (Phase B)

| # | Working title | Beat | Brief |
|---|---|---|---|
| S10 | **Afterimage Lesson** | New verb teach | First `invert` (preferred) **or** compose-pick lesson — generous floor, one idea |
| S11 | **Ghost Double** | Remix setpiece | Invert / compose creates a path that solves a room the base layout cannot |
| S12 | **Afterimage Boss** | Identity | Portrait that only reads under the new verb; new `identity` tag |

### 3.3 Setpiece acceptance (all phases)

- Unique map vs all other chambers (Hamming ≥ 8; preferably ≥ 16 for bosses).
- Intended human solve documented in `hints[0]` + author comment in roster script.
- Museum / trailer still listed in release media index when the chamber lands.
- No “Boss.” / “Hard.” caption mold; voice stays Field Ledger imperative.

---

## 4. New chamber slate (concrete volume)

Counts are targets, not filenames until authoring PRs. Slugs are proposals.

### 4.1 Phase A — denser Acts I–IV (~10–12 net-new campaign)

| Act | Add | Proposed slugs / jobs | Notes |
|---|---|---|---|
| Induction | +1–2 | `ink_rehearsal` (post–Mirror Birth gentle remix); optional `habit_margin` (thicken tease before `07`) | Demo allow-list stays `00`–`08` unless DEMO_SPEC revises |
| Reflection | +2–3 | `axis_debt` (single-axis trap before Looking Glass); `mask_negative` (negative-space dual-axis); `twin_liar` (false twin with distinct geometry) | Fix role tags: first `mirror_h` / `rotate_180` in-act → `lesson` |
| Pressure | +2–3 | `retread_tax` (thicken punishes loops); `triple_commit` (cap 3 literacy); `choke_mirror` (mirror under floor scarcity) | Kill rail-stack family reuse |
| Mastery | +2–3 | Rename/retarget `invert_ballet` → rotation-true slug; `op_sequence` (composition setpiece); `conductor_reprise` (unique Mastery opener ≠ Pressure) | Open Lattice remains epilogue, not a difficulty spike |

**Also Phase A (rebuild, not net-new count):** diverge near-clones (`13`/`25`, `08`/`33`, rail stack); rewrite dishonest hard parents.

### 4.2 Phase A — Hard track as real content (~+8–12 hard)

Today: one hard per act, several dishonest. Target: **Hard is a parallel syllabus**.

| Parent lesson class | Hard mandate |
|---|---|
| Each Act I pillar (`mirror_v`, `mirror_h`, `rotate_180`, `thicken`) | ≥1 hard derived from *that* parent map |
| Looking Glass / dual-axis | Keep + add a second dual-axis hard with different choke |
| Cement / multi-commit Pressure | Hard that removes a commit **or** seals a lure corridor |
| Nameplate / composition | Hard with tighter par **and** less floor — not par-only |

**Hard definition (normative):**

```
hard_variant_of = <parent slug>
AND (
  walkable_floor(parent) - walkable_floor(hard) >= 12% of parent
  OR checkpoint_count(hard) < checkpoint_count(parent)
  OR authored choke corridors absent in parent
)
AND transform == parent.transform   # unless explicitly a "compound hard"
AND caption tells the truth
```

Ship as full JSON (bible rule). List under each act’s `hard_variants` in `acts.json`. UI Hard+ menu already exists — fill it with honest maps.

### 4.3 Phase B — Act V Afterimage (~8–10 campaign + 2–3 hard)

Aligns with Roadmap DLC A; this vision locks content intent:

| Slot | Role | Transform / rule |
|---|---|---|
| 1 | lesson | `invert` (preferred) — teach floor↔wall authorship carefully with safety net |
| 2–3 | remix | Invert under Pressure-like floor scarcity |
| 4 | lesson/remix | Compose-pick **or** sequenced ops if invert slips |
| 5–7 | remix | Mix invert with prior ops (forced per chamber, not free sandbox) |
| 8 | boss | Afterimage identity portrait |
| 9 optional | daily_showcase | Act V poster chamber |
| +2–3 | hard | Honest parents from Act V lessons |

**Systems dependency:** `invert` already exists in playable code / audio / art expectation — content must not ship under a fake name again. If invert stays fenced, Act V teaches **player-chosen op at checkpoint** instead (compose-forward) and invert waits for Act VI.

### 4.4 Explicit non-goals

- Procedural campaign generation.
- Season-pass weekly chamber drip.
- Six-act base game for 1.0.
- Hard mode that only changes `par_moves_mult` / tempo.
- Reintroducing glyph/echo-propagation puzzles.

---

## 5. Pedagogy & quality bar

### 5.1 Teach → remix → boss → hard

Per act, minimum shape after denser 4:

```
[lesson per new-in-act idea] → remixes (≥1 per idea) → identity boss → hard variants (off-critical-path)
```

Rules carried forward from the content bible:

- First introduction of a transform in an act is `role: lesson`.
- Bosses use `teaches: identity` + unique `identity` tag + unique footprint.
- Hards never gate campaign progression.
- Auto-solver + BFS safety net green; authors still design fair intended paths.

### 5.2 Copy & locale

- Every new/rebuilt chamber ships `title`/`caption` + locale keys same PR.
- Hints: ≥1 line on every remix/hard/boss (Induction lessons already covered).
- No act-name leaks inside chamber voice (“under pressure”, “thicken mastery”).

### 5.3 Variation / Daily

Volume without Daily depth is wasted. For denser-4 remixes:

- Open `allow_rotate` / `allow_reflect` where transform-safe.
- Keep tutorial `00`–`02`/`04` daily-ineligible.
- Aim ≤30% palette-only chambers in the daily-eligible pool (today ~21/39).

### 5.4 Validation gates (merge checklist)

```bash
python3 game/echo_lattice/tests/validate_chambers.py   # solvability + clone detector
python3 game/echo_lattice/tests/validate_locale.py
python3 game/echo_lattice/tests/test_demo_spec.py      # if Act I touched
```

Add (if missing): hard-honesty check (`hard_variant_of` + floor/checkpoint delta); role-tag check (first-in-act transform → lesson).

---

## 6. Phasing vs ship fence

| Phase | Ship vehicle | Content | Systems |
|---|---|---|---|
| **A0** | 1.0 / hotfix | Clone purge, hard honesty, role/caption/hint truth, boss footprint split | `rewrite.cap` enforced or captions fixed |
| **A1** | 1.0 polish or Free Update #1 | +10–12 campaign, Hard track to ~12–14, setpieces S3–S9 | Sequenced ops **or** compose-pick for S7 |
| **B** | DLC A / Free Update (per Roadmap) | Act V Afterimage slate | `invert` teachable **or** compose-pick; depot/save unlock |
| **C** | Only if B succeeds | Act VI decision | Second new verb only |

**Do not** market Phase A as “Act V.” Store copy stays four acts until B ships.

---

## 7. Success metrics

| Signal | Baseline (RC1) | After Phase A | After Phase B |
|---|---|---|---|
| Campaign chambers | 35 | ~44–46 | ~52–56 |
| Hard chambers | 4 (weak) | ~12–14 (honest) | ~14–18 |
| Exact map clones | must stay **0** | **0** | **0** |
| Identity footprints distinct | fail (`08`≈`33`) | pass | pass + Act V |
| Setpieces trailer-ready | ~2 (Mirror Birth, Looking Glass) | ≥6 | ≥8 |
| Daily palette-only share | high (~half+) | ≤30% eligible pool | ≤30% |
| Review language (qual) | “short / neat” | “every room feels made” | “new wing worth buying” |

Telemetry ideals (Balance v2) stay the clear-rate anchors; denser 4 must **not** tank Act I ≥0.90 or demo ≤3‑minute hook.

---

## 8. Authoring workflow (when content PRs start)

1. Extend `tests/author_chambers_v2.py` roster + map overrides; regenerate JSON.
2. One lesson per chamber; checkpoints on the natural path.
3. For hards: fork parent map, tighten, re-verify `hard_variant_of`.
4. For bosses: sketch intended fossil in comments; playtest portrait readability.
5. Run validators + demo spec if Act I touched; update `acts.json`, locale, content bible roster table in the same PR.
6. Media: add still ids to release screenshot/trailer indexes when a setpiece lands.

---

## 9. Doc map & ownership

| Doc | Role after this vision |
|---|---|
| **This file** | Volume/quality *plan* — acts, setpieces, hard track, phases |
| `04_CONTENT_BIBLE.md` | Authoring *contract* — update roster/counts when chambers land |
| `CONTENT_CHAMBERS.md` | Audit baseline — A0 closes its P0/P1 map debts |
| `ROADMAP.md` | Ship fence — Act V remains post-1.0 unless fence reopened |
| `14_BALANCE_V2.md` | Gains Act V row only in Phase B |
| `DEMO_SPEC.md` | Untouched by Act V; denser Induction only with explicit demo budget check |

---

## 10. Decision log

| Date | Decision |
|---|---|
| 2026-08-09 | Prefer **denser 4 → Act V**; reject six-act base jump. Hard variants must be real content. Setpiece program S1–S12 defined. Phase A can improve 1.0 quality without claiming Act V. |

---

*Vision only — no chamber JSON, schema, or runtime changes in the PR that introduces this document.*
