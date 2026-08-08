# Echo Lattice — Game Design Document (v1.0)

**Doc ID:** `docs/ECHO_LATTICE/01_GDD.md`
**Status:** Implementation‑ready draft. All numbers here are seed values; every one is tunable via the values in `§17 Data & Tuning Constants`.
**Target platform:** Windows desktop (Steam), Godot 4 (per repo stack). Deterministic, offline, single‑player.
**Non‑goals guardrail:** No LLM anything. No online worldgen. All content generation is deterministic, seed‑based, systems‑only.

---

## 0. TL;DR

You tend a growing crystal called **the Lattice**. You have **six verbs**. You use them to build **Motifs** — small target sub‑shapes. When you complete a Motif, the game reads a rolling window of your recent actions, extracts **eight habit metrics**, and applies a deterministic **Rewrite Rule** that permanently mutates the Lattice's geometry and physics. Difficulty comes from geometry, not stats. You beat a **Chamber** by producing all of its Motifs plus a global constraint (**Resonance**) simultaneously. The game teaches you to notice yourself in your play, and then to change on purpose.

---

## 1. Fantasy

### 1.1 Central fantasy
> *"I am tending a crystal that is learning who I am. If I don't like what it becomes, I have to change how I move."*

The player is not a hero or a designer. They are a **caretaker of a reactive object**. The Lattice is intimate, quiet, and precise. Every session is a private dialogue between the player's motor and cognitive habits and a geometric substrate that remembers.

### 1.2 What it is not
- Not narrative. There is no story, no NPCs, no dialogue.
- Not roguelike. There is no run structure and no meta‑currency stockpile.
- Not a builder. You are not "making a base." You are eliciting a structure.
- Not therapy. The habit reading is mechanical, not psychological.
- Not a puzzler with a single solution. Every Chamber has a **family of legal solutions**, defined by the Motif Book and Resonance constraint.

### 1.3 Tone
Cold, luminous, quiet. Think ceramics, cold‑cathode blue, chalk white, deep graphite. Sound is closer to a well‑tuned chime and paper unfolding than to a soundtrack. No cinematics. No text overlay in play.

### 1.4 Elevator pitch (marketing‑safe)
> A quiet, geometric puzzle game where a crystal you build learns your habits and rewrites itself in response. Six verbs, twenty‑one chambers, no words.

---

## 2. Design Pillars

Every design decision must serve at least one pillar and violate none.

| # | Pillar | Litmus test |
|---|---|---|
| P1 | **Legible reflection** | At any moment the player can point at any lattice change and say which of their habits caused it. |
| P2 | **Bounded generativity** | All generative behavior is a deterministic finite ruleset seeded per chamber. No neural inference at runtime. |
| P3 | **Diegetic difficulty** | Difficulty is expressed as denser geometry, tighter constraints, and stricter Motifs — never as stat inflation. |
| P4 | **Silent play** | No text is required to play. All rules are learnable from a legend screen plus in‑world affordances. |
| P5 | **Six verbs, no clutter** | Everything the player can do reduces to one of six verbs. If a feature can't be expressed as one, it is cut. |
| P6 | **Consent to change** | Every Rewrite is previewed for ≥3s before commit; the player can defer once per Chamber via **Hold**. |

---

## 3. Player Fantasy — Moment to Moment

### 3.1 Moment (0–3 seconds)
The player rotates the camera around the Lattice with the right stick. They select a node. They press **Extend**. A pale edge unspools outward one lattice unit and a Ghost node hums into place. A tone plays — the pitch is bound to the current Bias Axis. The **Habit Meter** ring in the corner nudges one degree toward `EXTEND`.

### 3.2 Encounter (10–90 seconds)
The player is halfway through a Motif. They notice they have used `EXTEND` seven times in a row. The bottom‑of‑screen **Rewrite Preview** shows an incoming **BLOOM** rule if they finish the Motif under these conditions. They don't want Bloom right now, so they deliberately place a stray node with `PLACE`, then rotate a face, then finish the Motif. Rewrite Preview changes to `CHORUS`.

### 3.3 Session (20–40 minutes)
The player enters Chamber `2.3 Cinder Vault`. They see the seed lattice, read the Motif Book, choose to attempt Motifs in an order that keeps Rewrites additive rather than restrictive. They complete 6 of 7 Motifs, then attempt Resonance. Their Compaction rewrite makes the last Motif impossible; they roll back to the last Motif Snapshot, un‑bias their movement, and try again. They finish with two Runes earned.

### 3.4 Meta (10–30 hours)
Across three Acts, the player accumulates 21 Runes. Rune combinations enable **New Game +** style Free Chambers where the player can select any Substrate and generate a Motif Book from Rune loadouts. There is no leaderboard; there is a personal **Lattice Ledger** that shows which habits the player converged toward.

---

## 4. Core Loop

The loop is intentionally described at four time scales. Everything below is deterministic; nothing depends on wall clock time.

### 4.1 Second‑scale loop (per action, 0.5–2s)
```
observe lattice → choose verb → aim → execute → tone plays → habit meter updates
```
- Every action commits atomically to an **Action Log** (Chamber‑scoped, monotonically numbered).
- Every action updates the **Habit Window** (see §5).

### 4.2 Minute‑scale loop (per Motif, 45s–4min)
```
inspect Motif Book (X) → attempt Motif → complete Motif isomorphism →
  Rewrite Preview shown (3s) → commit or Hold → Rewrite applied → Snapshot saved
```
- Chamber Snapshot: a full lattice state + habit window + rune loadout, taken atomically at Rewrite commit.
- The player has **1 Hold token** per Chamber. Hold defers the Rewrite until next Motif.

### 4.3 Session‑scale loop (per Chamber, 20–40min)
```
enter Chamber → read seed + Motif Book + Resonance target → complete N Motifs in any order →
  attempt Resonance → succeed → award Rune → exit
```
- If Tempo (see §6) runs out, Chamber is **STALLED**. Player must Reset (back to Chamber seed) or Rewind to a Snapshot.

### 4.4 Meta loop (per Act, 4–10h; per Campaign, 10–30h)
```
complete Chamber → unlock next Chamber → complete 7 Chambers → unlock next Act →
  after Act 3 → unlock Free Chambers, Ledger, Rune Loadout mode
```

---

## 5. Habit → Geometry Rewrite Rules — The Core System

This is the innovation. It must be built exactly as specified. Every threshold below is stored in `tuning.json` (`§17`) and can be adjusted, but the *shape* of the system is normative.

### 5.1 Verbs (canonical set of six)

| Code | Verb | Cost (Tempo) | Behavior |
|---|---|---|---|
| V1 | **PLACE** | 2 | Spawn a node at a legal empty lattice site adjacent to an existing node. Illegal if no adjacent free site is targeted. |
| V2 | **EXTEND** | 1 | From a selected node, along a legal template direction, produce either (a) a new node at the neighbour site with an edge, or (b) an edge to an already‑present neighbour node. |
| V3 | **ROTATE** | 2 | Rotate a **face** (a minimal cycle in the current substrate) by the substrate's smallest legal rotation (60°/90°/120°). Adjacent faces may shear if their basis differs — see §5.6 Substrate Rules. |
| V4 | **PRUNE** | 1 | Remove a node. Illegal if the node is **Anchored** or part of a **Bond**. When a node is removed, its edges are removed. If the removal disconnects the graph, the smaller component becomes **Drift** (see §5.7). |
| V5 | **ANCHOR** | 2 | Toggle Anchor state of a node. Anchored nodes cannot be Pruned or Rotated. |
| V6 | **ECHO** | 1 (+1 per depth) | Replay the last completed **Verb Macro** (contiguous run of same‑verb actions of length ≥1) at the current selection. Depth limit = 3 by default, raised by Refrain rewrite. |

Only these six exist. All player capabilities descend from Runes that specialize one of these six (`§8.3`).

### 5.2 Action Log & Habit Window

- **Action Log**: append‑only, monotonic, chamber‑scoped. Entry: `{ id:int, verb:V1..V6, target: NodeId | FaceId, direction: unit3 | null, t_ms:int, tempo_left:int, undo:bool }`.
- **Habit Window `W`**: last `w` actions, where `w = 32` in Act 1, `48` in Act 2, `64` in Act 3.
- Undo actions are tagged and consume from Tempo the same as forward actions (an Undo costs `1` Tempo baseline; Forgive Field waives up to 3).

### 5.3 Eight Habit Metrics (H1–H8)

All metrics are recomputed **after every action**, in the following exact order (order matters when metrics feed each other):

| ID | Name | Formula | Buckets |
|---|---|---|---|
| **H1** | **Cadence** | `median(Δt_ms)` across W (Δt = t_i − t_{i−1}) | FAST < 600ms; MID 600–1800; SLOW > 1800 |
| **H2** | **Directionality** | Bin unit direction of each `EXTEND` and `PLACE` action into one of 8 (cubic) or 12 (FCC/hex) direction buckets. Compute max‑bucket share `s`. | DIFFUSE `s<0.30`; TILTED `0.30–0.55`; BIASED `s≥0.55` |
| **H3** | **Verb Mix** | 6‑vector `p_v = count(v) / |W|`. Dominant verb `v* = argmax(p_v)`. | Trigger‑checked per rule (thresholds vary). |
| **H4** | **Run Length** | Median length of maximal same‑verb runs within W. | STACCATO 1; REGULAR 2–3; LONG ≥4 |
| **H5** | **Symmetry** | For the current lattice, find best mirror plane through centroid. Compute fraction `f` of nodes with mirror partner within `0.5` lattice units. Rolling avg of `f` at each action time over W. | ASYM `<0.40`; SEMI `0.40–0.75`; SYM `≥0.75` |
| **H6** | **Density Slope** | `(|nodes at end of W| − |nodes at start of W|) / (W/2)`. | SHRINK `<−0.05`; STEADY `−0.05..+0.05`; GROW `>+0.05` |
| **H7** | **Undo Rate** | `undo_count / |W|` | TIDY `<0.05`; TRIAL `0.05–0.20`; THRASH `≥0.20` |
| **H8** | **Echo Depth** | Median length of maximal consecutive Echo runs in W (0 if none). | NONE 0; LIGHT 1–2; REFRAIN ≥3 |

**Derived signals (D‑series):** computed only when a rule needs them, to keep the hot path cheap.

| ID | Name | Formula |
|---|---|---|
| D1 | Cadence Variance | `σ(Δt_ms)` across W |
| D2 | Anchor Rate | `count(V5)/|W|` |
| D3 | Prune Rate | `count(V4)/|W|` |
| D4 | Symmetry Delta | `H5_now − H5_start_of_W` |

### 5.4 Rewrite Rules (R1–R15)

**Firing rule:** at each **Motif completion**, the engine evaluates R1–R15 in the priority order below. It picks the **first rule whose trigger is satisfied and which is not already active** (see §5.5 caps). The picked rule is shown as a **Rewrite Preview** for 3 seconds; the player may press **Hold** (once per Chamber) to defer to the next Motif. On commit, the Effect is applied; the Reversal criterion is registered; the rule's `active_since_action_id` is stored.

**Semantics of "Ghost", "Bond", "Anchored", "Crystal", "Drift":** see §5.7.

| # | Trigger | Effect | Reversal | Priority |
|---|---|---|---|---|
| **R1 CRYSTALLIZE** | `H1=FAST ∧ H4=LONG` | The last 5 edges you played become **Bonds** (permanent, unbreakable by Prune). | 3 consecutive Prunes within a single Motif convert one random Bond back to a normal edge. | 10 |
| **R2 BLOOM** | `H1=SLOW ∧ H6=STEADY` | Every current leaf node **Extends** by 1 along its local dominant direction. New nodes spawn as **Ghost** (see §5.7). | Prune 3 Ghost nodes within one Motif. | 9 |
| **R3 BIAS AXIS** | `H2=BIASED` | The chamber gains a gravity vector +g along the biased direction. Any Ghost within 2 units of a lattice site in that direction snaps to it. Camera tilts 5° per rewrite. | 5 EXTENDs strictly perpendicular to bias axis. | 9 |
| **R4 SEED SURPLUS** | `H3.p_place > 0.40` | +1 **Seed** token (max 3). A Seed allows one `PLACE` action at any legal *isolated* lattice site (no adjacency required). | Consume all Seeds. (Perk — reversal not required.) | 7 |
| **R5 SPIN FIELD** | `H3.p_rotate > 0.40` | All un‑Anchored faces auto‑rotate by 1 step every `12s` of in‑chamber time. | Anchor 3 faces within one Motif. | 8 |
| **R6 CHORUS** | `H4=LONG` | Consecutive same‑verb actions cost `−1` Tempo (min 0). | (Perk.) | 5 |
| **R7 MIRROR GROWTH** | `H5=SYM` | The best mirror plane is fixed. Any subsequent `PLACE` spawns a Ghost at the mirrored site. | 3 `PLACE`s at asymmetric sites. | 8 |
| **R8 COMPACTION** | `H6=GROW ∧ D3<0.05` | The outermost 10% of un‑Anchored, non‑Bond nodes collapse by 1 lattice unit toward the centroid. Bonds bend; edges do not break. | 5 outward EXTENDs (away from centroid). | 9 |
| **R9 FORGIVE FIELD** | `H7=THRASH` | Your last 3 actions become **Soft**: each may be undone for `0` Tempo cost once. | (Perk.) | 4 |
| **R10 REFRAIN** | `H8=REFRAIN` | Echo depth cap +1 for the rest of the Chamber. | (Perk.) | 4 |
| **R11 SILENT LATTICE** | `D2 > 0.25` | Anchored nodes emit no verb tone. Visually they lose their halo. | Un‑Anchor 3 nodes. | 6 |
| **R12 ATROPHY** | `D3 > 0.40` | Any leaf that has not been the target of an EXTEND within 30s of chamber time auto‑Prunes. | 3 EXTENDs into leaves within one Motif. | 8 |
| **R13 REVERB** | `D1 > 2000ms` | Every subsequent `PLACE` schedules a Ghost 2s later at the mirrored site of the last symmetry plane. | 3 actions within `Δt<1500ms` of each other. | 6 |
| **R14 SHEAR** | `H2=BIASED ∧ H5=ASYM` | Lattice basis skews 15° along bias axis. Faces near skew may become non‑planar (visually shear, mechanically still a face). | 5 symmetric placements (H5 rises to SEMI). | 7 |
| **R15 CALCIFY** | `H1=FAST ∧ H7=TIDY` | Any face closed and un‑Rotated for ≥30s becomes **Crystal**: cannot rotate, counts double for Motif matching. **Permanent.** | None. Player must Rewind to reverse. | 10 |

Rules **R1**, **R8**, **R15** are marked **HARD**. HARD rules never fire in Act 1 Chambers 1.1–1.4 (training zone).

### 5.5 Active Rewrite Cap

- Act 1 Chambers: max 1 active rule.
- Act 2 Chambers: max 2 active rules.
- Act 3 Chambers: max 3 active rules.
- When a rule fires and the cap is reached, the **oldest non‑HARD** active rule ages out (its ongoing effect stops; permanent effects like Bonds/Crystal remain).
- HARD rules never age out; they must be reversed or Rewound.

### 5.6 Substrate Rules

Substrates define the legal lattice sites and face definitions. All substrates are on integer/rational coordinates for deterministic snapping.

| Substrate | Basis | Faces | Available | Rotation step |
|---|---|---|---|---|
| **Cubic** | `(1,0,0),(0,1,0),(0,0,1)` | 4‑cycle squares | Act 1 | 90° |
| **FCC** | `½(1,1,0), ½(0,1,1), ½(1,0,1)` | 3‑cycle triangles + 4‑cycle rhombi | Act 2 | 60° / 90° |
| **Hex‑prism** | `(1,0,0), (½, √3/2, 0), (0,0,1)` | 6‑cycle hexagons + 4‑cycle rectangles | Act 2 | 60° / 90° |
| **Diamond** | Two interpenetrating FCC (0 and ¼,¼,¼) | 6‑cycle chair hexagons | Act 3 | 120° |
| **Icosahedral cluster** | Discrete quasi‑lattice on I_h axes | 3‑cycle triangles + 5‑cycle pentagons | Act 3 (last two chambers) | 72° / 120° |

- **Skew** (R14) modifies the basis of the current substrate by a 15° shear matrix on the biased axis. Snapping tolerance widens by `+0.15` lattice units while skew is active.
- Faces are recomputed as **minimal induced cycles** after every graph mutation, up to `k=6` nodes; icosahedral is up to `k=5`.
- No non‑planar face is allowed as a Motif match unless the Motif is explicitly marked `nonplanar` in the Motif Book.

### 5.7 Node/Edge State Machine

Each node holds:
```
NodeState := { pos: Vec3int, base: Base, tags: Set<Tag> }
Tag       ∈ { Normal, Ghost, Anchored, Bond‑incident, Drift, Crystal‑face‑incident }
```
- **Ghost:** dashed outline. Counts for adjacency but not for Motif matching. Becomes Normal on any user action targeting it (Anchor, Extend from it, Rotate a face containing it) or after 8s of stable adjacency to ≥2 Normal nodes.
- **Anchored:** halo ring, cannot be Pruned or Rotated.
- **Bond‑incident:** thick edge glyph. Node itself is not immune to Prune unless also Anchored, but Bonds prevent edge removal.
- **Drift:** a component disconnected from the main lattice. Drift components float outward at `0.05 units/s`; if they exit the chamber's bound sphere they are removed. Drift can be re‑adopted by an `EXTEND` from a Normal node reaching them.
- **Crystal‑face‑incident:** three or more Bonds around a face have "Calcified"; visually a filled panel. Cannot rotate. Counts double for Motif area.

### 5.8 Motif Matching

A **Motif** is a labelled graph pattern with node labels in `{ *, anchored, bond-only }` and edge labels in `{ *, bond, ghost-ok }`.

- Matching is subgraph isomorphism (VF3 or Ullmann; acceptable performance up to `|M|=30`).
- Multiple Motifs may share nodes.
- A Motif is **satisfied** the first frame the isomorphism holds and remains satisfied for `500ms` of continuous match.
- Every Motif has a **Signature Tone** (see §12).

### 5.9 Determinism guarantees

- Every Chamber has an integer seed `S_chamber`.
- All PRNG draws for: initial seed lattice, Motif Book selection order, tie‑breaking in R‑selection when multiple rules with same priority trigger, direction picks for Bloom, Drift removal RNG, Skew axis orientation, camera tilt sign — go through a single `xoshiro256**` stream seeded from `S_chamber`.
- Habit metrics are pure functions of the Action Log.
- No wall‑clock reads inside rule evaluation; only the in‑chamber time counter (integer ms) is used.

---

## 6. Win / Lose Conditions

### 6.1 Chamber
- **Win:** all listed Motifs in the Chamber's Motif Book are simultaneously satisfied AND the Resonance global constraint holds AND player commits by pressing `Confirm Resonance`.
- **Non‑win but not lose (STALLED):** Tempo budget hits 0 before Resonance is achieved. Player options:
  1. **Rewind** to previous Motif Snapshot (Chamber Snapshot after last Motif commit).
  2. **Reset** to Chamber seed (all runes remain, Motif progress lost, Tempo restored).
  3. **Exit** to Chamber select (progress not lost; can resume from most recent Snapshot).
- **There is no failure state.** The player never sees a "Game Over."

### 6.2 Tempo budget
- `Tempo_start = 60 + 8 × Motif_count + 12 × (Act−1)` per Chamber.
- Chorus reduces cost; Bloom/Spin auto‑generate no Tempo drain.
- Tempo is displayed as a bar; when ≤10% remaining, the border flushes slowly (accessibility: flush respects reduced motion setting).

### 6.3 Resonance constraint types (chosen per Chamber)
| Code | Constraint |
|---|---|
| RC‑PLANAR | Lattice graph is planar. |
| RC‑2COL | Chromatic number ≤ 2 for the induced subgraph over completed Motifs. |
| RC‑GENUS | Combinatorial genus ≥ 1 (contains at least one 3‑torus handle). |
| RC‑DIA | Diameter of induced Motif graph ≤ `d`. |
| RC‑MASS | Node count in `[m_lo, m_hi]`. |
| RC‑MIRROR | Mirror symmetry `H5 ≥ 0.75` at commit time. |
| RC‑ISOL | ≥ `k` Drift components at commit. |
| RC‑TONAL | Sum of Motif signature tone intervals is a perfect 5th, octave, or unison. |

### 6.4 Global loss / meta
- No permadeath. No meta‑currency to lose.
- Deleting a save file is the only way to lose progress. Autosave (§18.4) prevents accidental loss.

---

## 7. Progression

### 7.1 Runes
- 21 Runes total, 1 per Chamber.
- Each Rune is a **modifier on one verb**. Applied automatically as soon as unlocked, no equip screen (P4: silent play).
- Runes are cumulative and stack rules are explicit (`§8.3` full list).
- Some Runes conflict; conflict is resolved by later Rune overriding earlier. All conflict pairs are enumerated (`§8.3`).

### 7.2 Substrate unlocks
- Act 1 completion → FCC + Hex‑prism unlocked in Free Chambers.
- Act 2 completion → Diamond unlocked.
- Act 3 completion → Icosahedral unlocked.

### 7.3 Free Chambers (post‑campaign)
- Choose Substrate, Motif Book size (3–12), Rewrite Cap (0–3), Resonance type.
- Seed can be entered manually or randomized; both are deterministic.
- Free Chambers do not grant Runes; they update the Ledger.

### 7.4 Ledger (post‑campaign; also visible from Chamber Select)
- Distribution histograms of H1–H8 across all completed Chambers.
- Most‑fired Rewrite Rules.
- Fastest and slowest Resonance times per Chamber.
- No comparison to other players; no online leaderboard.

---

## 8. Content Structure — Chambers, Acts, Motif Book, Runes

### 8.1 Acts

| Act | Name | Substrates | Chambers | Rewrite cap | HARD rules allowed |
|---|---|---|---|---|---|
| I | **SEED** | Cubic | 7 | 1 | none in 1.1–1.4; R1 allowed from 1.5; R8 from 1.6; R15 from 1.7 |
| II | **GROWTH** | FCC, Hex‑prism | 7 | 2 | all |
| III | **PRISM** | Diamond, Icosahedral | 7 | 3 | all |

### 8.2 Chamber Catalog (all 21, hand‑authored seeds)

Each chamber row lists: `Substrate | Verbs unlocked at entry | Motif count | Resonance | Restrictions | Seed motifs sketch`.

**Act I — SEED (Cubic)**

| ID | Name | Substrate | Verbs | Motifs | Resonance | Restrictions |
|---|---|---|---|---|---|---|
| 1.1 | Pale Vertex | Cubic | PLACE, EXTEND | 5 | RC‑MASS `[6,10]` | none |
| 1.2 | Vibrissa | Cubic | +ROTATE | 5 | RC‑PLANAR | max Tempo 68 |
| 1.3 | The Fingering | Cubic | +ECHO | 6 | RC‑MASS `[10,16]` | must include one Echo chain ≥2 |
| 1.4 | Under‑Bloom | Cubic | +PRUNE | 6 | RC‑2COL | PRUNE cost 0 |
| 1.5 | Anchor | Cubic | +ANCHOR | 7 | RC‑MIRROR | R1 permitted |
| 1.6 | Hemlock Snap | Cubic | all 6 | 7 | RC‑DIA `d=4` | R1, R8 permitted |
| 1.7 | Concordance | Cubic | all 6 | 9 | RC‑TONAL | all HARD rules permitted |

**Act II — GROWTH (FCC and Hex‑prism)**

| ID | Name | Substrate | Verbs | Motifs | Resonance | Restrictions |
|---|---|---|---|---|---|---|
| 2.1 | Kite Field | FCC | all 6 | 6 | RC‑PLANAR | rotate step forced 60° |
| 2.2 | Hex‑Choir | Hex‑prism | all 6 | 7 | RC‑2COL | Anchor cost 1 |
| 2.3 | Cinder Vault | FCC | all 6 | 7 | RC‑GENUS ≥1 | one Motif must contain a triangle |
| 2.4 | Wren's Loom | Hex‑prism | all 6 | 8 | RC‑DIA `d=5` | Ghost decay 4s (halved) |
| 2.5 | Skew Yard | FCC | all 6 | 7 | RC‑MIRROR | R14 pre‑activated |
| 2.6 | Bone Prism | Hex‑prism | all 6 | 8 | RC‑MASS `[24,32]` | ECHO depth cap 2 |
| 2.7 | Vane | FCC | all 6 | 9 | RC‑TONAL | Resonance requires simultaneous Mirror + Tonal |

**Act III — PRISM (Diamond and Icosahedral)**

| ID | Name | Substrate | Verbs | Motifs | Resonance | Restrictions |
|---|---|---|---|---|---|---|
| 3.1 | Diamond Anvil | Diamond | all 6 | 7 | RC‑PLANAR | Rotate 120° only |
| 3.2 | Cindra | Diamond | all 6 | 8 | RC‑GENUS ≥1 | R8 pre‑active |
| 3.3 | Chalk Line | Diamond | all 6 | 8 | RC‑MIRROR | no Anchor |
| 3.4 | Rime Lantern | Icos | all 6 | 8 | RC‑DIA `d=5` | Pentagon Motif required |
| 3.5 | Meridian | Diamond | all 6 | 9 | RC‑TONAL | R15 pre‑active |
| 3.6 | The Loom | Icos | all 6 | 9 | RC‑ISOL `k≥2` | one Drift must be adopted |
| 3.7 | Echo Lattice | Icos | all 6 | 9 | RC‑GENUS ≥2 ∧ RC‑MIRROR | 3 active rewrites, all HARD allowed |

### 8.3 Rune Catalog (all 21, one per Chamber above)

Priority key: `A>B` means A overrides B when they conflict on the same base verb.

| Chamber | Rune | Verb modified | Effect | Conflicts |
|---|---|---|---|---|
| 1.1 | **Pale Placer** | V1 | PLACE cost `−1` (min 1) | — |
| 1.2 | **Whorl** | V3 | ROTATE animates 60% faster (cosmetic + input timing) | — |
| 1.3 | **Refrain‑B** | V6 | ECHO base depth `+1` | — |
| 1.4 | **Green Prune** | V4 | Undo‑as‑Prune: undo of a PLACE returns 1 Tempo | Grey Prune (3.3) |
| 1.5 | **Iron Anchor** | V5 | Anchor cannot be un‑Anchored for 30s after set | Loose Anchor (2.4) |
| 1.6 | **Snap‑Extend** | V2 | EXTEND to an existing neighbour costs 0 | — |
| 1.7 | **Chord** | V2 | Every 4th EXTEND grants +1 Tempo | — |
| 2.1 | **Kite Place** | V1 | On FCC, PLACE across two 60° neighbours simultaneously (2 nodes, cost 3) | — |
| 2.2 | **Six‑Tone** | V3 | Hex ROTATE emits full‑hex tone chord | — |
| 2.3 | **Volt Extend** | V2 | EXTEND may skip 1 site (cost +1) | — |
| 2.4 | **Loose Anchor** | V5 | Anchor is toggle‑free at any time | Iron Anchor (1.5); Loose overrides |
| 2.5 | **Slip Rotate** | V3 | ROTATE ignores shear penalty | — |
| 2.6 | **Bone Echo** | V6 | ECHO extends across Chambers via last Snapshot | — |
| 2.7 | **Vane Bias** | V1 | PLACE ignores Bias Axis snap | — |
| 3.1 | **Anvil** | V3 | ROTATE also acts on adjacent face if both Bonded | — |
| 3.2 | **Cindra Bloom** | V2 | Every 8 EXTENDs auto‑promotes a Ghost | — |
| 3.3 | **Grey Prune** | V4 | Prune returns 1 Tempo regardless of source | Green Prune (1.4); Grey overrides |
| 3.4 | **Rime Anchor** | V5 | Anchored nodes count 3× for RC‑MASS | Iron/Loose stack additively |
| 3.5 | **Meridian Line** | V6 | ECHO across two chained Motifs (macro of macros) | — |
| 3.6 | **Loom Adopt** | V2 | EXTEND may adopt Drift within `4` units | — |
| 3.7 | **Prism** | ALL | Six‑verb macro: press ECHO twice within 200ms to replay last one of each verb | supersedes all base ECHO depth |

### 8.4 Motif Book — organization

- **60 Motifs total.**
- Grouped by node count tier: T1 (6–10 nodes), T2 (10–16), T3 (16–24), T4 (24–30).
- Each Motif has: `id, tier, nodeCount, edgeSpec, labelSpec, signatureTone (frequency ratio), preferredSubstrates, allowsGhost:bool, mirrorAware:bool`.
- Motif Book selection per Chamber is deterministic given `S_chamber`: draw Motifs from tiers matching the Chamber's difficulty vector, without repeat within an Act.
- All 60 Motifs are hand‑authored, stored as JSON in `game/motifs/*.json`. Format detailed in §17.4. No generative Motifs at runtime.

### 8.5 Chamber seed generation

- Seed lattice is procedural per Chamber, but from a hand‑authored **template family** for that Chamber (not from an LLM, not from any neural process).
- Template family = a list of 2–6 authored "seed skeletons," each with parametric holes (which lattice sites are omitted, which are Anchored, which are Ghost). The procedural step chooses one skeleton by hashing `S_chamber` into `[0, family.size)` and instantiates the parametric holes deterministically.
- Guarantees each replay of a Chamber has the same seed lattice.

---

## 9. Difficulty

### 9.1 Difficulty vector per Chamber
```
Difficulty = { motifCount, motifTierMix, tempoTight, activeRewriteCap, hardRuleMask,
               substrateComplexity, restrictions }
```

### 9.2 Difficulty curve (published)
- Act I: Motifs T1‑T2 dominant, tempo generous (`+15%` slack).
- Act II: Motifs T2‑T3 dominant, tempo neutral.
- Act III: Motifs T3‑T4 dominant, tempo tight (`−10%` slack), rewrite cap 3.

### 9.3 Player‑facing difficulty modes (in Options)
| Mode | Effect |
|---|---|
| **Reader** | +50% Tempo, rewrites previewed for 6s, HARD rules disabled. |
| **Standard** | Values as above. |
| **Cold** | −20% Tempo, rewrite preview 1.5s, +1 rewrite cap in Act III. |

Modes can be changed at any time from Options and take effect at the next Chamber start.

### 9.4 Anti‑stall guarantees
- Every Chamber has been solver‑verified: the shipped state has at least one legal path to Resonance with each of the three difficulty modes. Solver is a rules‑based search over verb sequences up to a bounded depth (`§17.5`), *not* an ML model.
- Chamber test manifest (`docs/ECHO_LATTICE/tests/chamber_solve.md`, to be created in a later commit) will list solver depth, verb count, and Tempo margin for each shipped Chamber.

---

## 10. Accessibility

All accessibility settings can be changed at any time from the Options overlay and take effect immediately.

### 10.1 Motor
- Full remap for keyboard, mouse, and controller (§11).
- **Single‑input mode**: navigation with 4 directional inputs + 1 confirm; a radial verb wheel appears on hold. Everything the game requires is reachable.
- Hold‑to‑repeat is toggleable to tap‑to‑repeat.
- Adjustable input dead‑zone (0–40%), input repeat rate (100–800ms), input hold time (50–800ms).
- Toggle vs hold for all modifier keys.
- One‑handed keyboard layout preset.

### 10.2 Vision
- Colorblind palettes: **Deuteranopia**, **Protanopia**, **Tritanopia**, plus **High‑Contrast**.
- All colored elements are also **shape‑coded** (dashed vs solid vs dotted vs double lines; halos vs bars vs frames).
- Text scaling `100–200%` on all UI text.
- Icon scaling `100–150%` independent of text.
- Camera field of view adjustable `40–90°`.
- Motion sickness: **Reduced motion** disables camera tilt on rewrites (R3), auto‑rotate (R5), and screen flush (§6.2). Keeps functional animation.
- **Chromatic bloom** slider (0–100%); default 40% in Standard, 0% in Reduced‑motion.

### 10.3 Photosensitivity
- **Flatten Shimmer** disables Ghost node pulse, Crystal shimmer, and Refrain overlay flicker.
- No screen flashes above `3 Hz` in any state; enforced at renderer.
- Bloom rewrite spawn animation uses fade instead of flash when Flatten Shimmer is on.

### 10.4 Cognitive
- **Soft Rewrite** halves rewrite effect magnitudes (e.g., R2 blooms 1 in 2 leaves, R8 collapses 5% instead of 10%).
- **Preview extension**: rewrite preview time up to 15s.
- **Ledger view** shows current active rewrites in plain glyphs at all times (§13.4).
- **Rule Legend** overlay (accessible via `?` key) enumerates all 15 rules with visual glyph, trigger, effect, reversal.
- **Hints**: opt‑in, off by default. If enabled, a subtle ring highlights a legal Motif‑completing action after 90s of inactivity.
- No timers by default. No twitch challenges.

### 10.5 Audio
- Independent volume sliders: Master, Verb Tones, Ambient Bed, UI, Rewrite Cue.
- **Mono mix** toggle.
- **Subtitles for audio cues**: on‑screen glyphs describing verb tones and rewrite sounds; described in §12.6.
- HRTF toggle (positional audio).
- **Silent Mode**: entire game playable with all audio disabled; visual glyphs replace every audio cue.

### 10.6 Screen reader
- All menus fully screen‑reader accessible (Windows Narrator + third‑party via UI Automation).
- In‑play screen reader mode announces: verb executed, node id, current H1–H8 buckets on request (`F1`), active rewrites, Motif satisfaction changes, Tempo remaining every N actions (configurable).

### 10.7 Save state
- **Rewind to Snapshot** is always available (Reader mode allows unlimited; Standard 5/Chamber; Cold 2/Chamber).
- Cross‑session resume from last Snapshot on crash.

---

## 11. Controls

### 11.1 Input priorities
KBM and gamepad are equal peers. All bindings are rebindable. Both can be active simultaneously (hot‑swap without menu).

### 11.2 KBM default map

| Action | Binding |
|---|---|
| PLACE | Left click on empty adjacent site |
| EXTEND | `E` + direction, OR drag from node to neighbour |
| ROTATE | Middle‑click drag on face, OR `R` on hovered face |
| PRUNE | Right‑click on node |
| ANCHOR | `A` on hovered node |
| ECHO | Space |
| Undo | `Ctrl+Z` (tracked as undo action; counts in H7) |
| Confirm Motif attempt | `Enter` |
| Confirm Resonance | `Ctrl+Enter` (double confirm) |
| Hold rewrite | `H` during preview |
| Motif Book | `M` |
| Ledger | `L` |
| Rule Legend | `?` |
| Pan camera | `WASD` |
| Orbit camera | Right‑click drag on empty space, OR `Q`/`E` (yaw), `Z`/`X` (pitch) |
| Zoom | Mouse wheel, OR `−`/`+` |
| Fine mode | Hold `Shift` |
| Snapshot rewind | `Ctrl+R` |
| Options | `Esc` |
| Quick save | `F5` |

### 11.3 Controller default map (Xbox layout, translated for PS/other)

| Action | Binding |
|---|---|
| Pan cursor | Left stick |
| Orbit camera | Right stick |
| Zoom | LT (out) / RT (in) |
| PLACE | A |
| EXTEND | X (then flick left stick) |
| ROTATE | Y |
| PRUNE | B |
| ANCHOR | LB |
| ECHO | RB |
| Undo | Back / Select |
| Confirm Motif | Start |
| Hold rewrite | Y during preview |
| Motif Book | D‑pad up |
| Ledger | D‑pad down |
| Rule Legend | D‑pad left |
| Options | D‑pad right |

### 11.4 Rebind constraints
- Any binding may be rebound to any input; conflicts warned but permitted (last‑binding wins).
- Chorded bindings up to 2 inputs (e.g., `Ctrl+Enter`).
- Modifier‑only bindings not allowed (Shift/Ctrl alone).

### 11.5 Input timing
- Fixed input polling at renderer rate (target 60 Hz).
- Undo respects a `120ms` debounce window (accidental double‑undo prevented).
- Long‑press threshold `450ms` default.

---

## 12. Audio Design Needs

### 12.1 Musical premise
No music tracks. The game's audio is a **tuning system**: the Lattice is a resonator. Verb tones, motif completion, and rewrite cues are all pitched in a shared tuning grid.

### 12.2 Tuning
- **Just intonation** on a fundamental per Chamber (see §12.3 grid). Ratios `1/1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8`, plus `2/1` octave.
- Each verb has a base ratio (Place=`1/1`, Extend=`3/2`, Rotate=`5/4`, Prune=`4/3`, Anchor=`5/3`, Echo=`9/8`).
- Motif signature tones are ratios composed from the involved verbs (§8.4).

### 12.3 Per‑Chamber fundamentals (published, mutable via `tuning.json`)

| Chamber | Fundamental (Hz) | Notes |
|---|---|---|
| 1.1 | 220 | A3 |
| 1.2 | 246.94 | B3 |
| 1.3 | 261.63 | C4 |
| 1.4 | 293.66 | D4 |
| 1.5 | 329.63 | E4 |
| 1.6 | 349.23 | F4 |
| 1.7 | 392.00 | G4 |
| 2.1 | 220 | back to A3, one octave down feel via bed |
| ... | ... | (full 21 rows in `tuning.json`) |

### 12.4 Ambient bed
- One 90s stereo loop per Chamber, tuned to that Chamber's fundamental.
- Bed is drone‑like, no rhythmic pulse.
- Level ducks by −6 dB during rewrite preview.

### 12.5 Rewrite cues
- Each of R1–R15 has a distinct 2‑second cue sample.
- HARD rules (R1, R8, R15) have an extra low sub‑tone `⅓` octave below the fundamental.
- Perk rules (R4, R6, R9, R10) have a bright upper harmonic.

### 12.6 Audio subtitles (accessibility overlay)
When the "Subtitles for audio cues" toggle is on, a small glyph appears in the lower‑right for every audio event:

| Event | Glyph |
|---|---|
| PLACE | ▪ |
| EXTEND | → |
| ROTATE | ⟳ |
| PRUNE | × |
| ANCHOR | ⊕ |
| ECHO | ↩ |
| Motif satisfied | ◇ |
| Rewrite preview | 〔R#〕 |
| Rewrite commit | ▲ |
| Resonance achieved | ★ |

### 12.7 Voice
- No voice acting.
- No spoken words in‑game.

### 12.8 Silence budget
- The game must be pleasant with all audio off (P4).
- Silent Mode replaces all audio events with the glyphs above.

### 12.9 Deliverables
- 21 ambient beds (one per Chamber).
- 15 rewrite cues.
- 6 verb tones × 21 chamber fundamentals (procedurally re‑pitched at load, single source file per verb).
- 60 Motif signature tones (procedurally composed at load from verb tones and ratios in Motif JSON).
- 4 UI clicks: hover, select, confirm, error.
- 1 rewind swell.
- 1 Chamber complete swell.
- 1 Act complete swell.

Total: ~50 asset files. All bounces at 48 kHz / 24‑bit stereo, licensed royalty‑free or commissioned original.

---

## 13. UI — Text Wireframes

The game is designed around a single 3D play view with translucent side/edge overlays. Nothing on the HUD blocks the Lattice by more than 12% of screen area.

### 13.1 Global HUD (in‑Chamber)

```
+-------------------------------------------------------------+
|   [Chamber 2.3  Cinder Vault]              [Menu ≡]         |
|                                                             |
|                                                             |
|                                                             |
|                 ~~~~~~ 3D LATTICE VIEW ~~~~~~               |
|                                                             |
|                                                             |
|                                                             |
|                                                             |
|  ┌───── Habit Ring ────┐             ┌──── Motif Track ───┐ |
|  |   H1: MID           |             | ◇ ◇ ◇ ◇ ○ ○ ○      | |
|  |   H2: TILTED  ↗     |             | 4 / 7 satisfied    | |
|  |   Dom.verb: EXTEND  |             └────────────────────┘ |
|  |   H4: LONG          |             ┌── Active Rewrites ─┐ |
|  |   H5: SEMI          |             | R6 CHORUS           | |
|  |   H6: STEADY        |             |                     | |
|  |   H7: TIDY          |             |                     | |
|  |   H8: LIGHT (2)     |             └────────────────────┘ |
|  └─────────────────────┘                                    |
|                                                             |
|  Tempo  ██████████████████████████░░░░░░░░░  42 / 60        |
|  Snap ⤺  Rewind [Ctrl+R]     Hold [H]      Book [M]         |
+-------------------------------------------------------------+
```

- **Habit Ring**: at rest a compact ring with H1–H8 bucket dots; expanded on hover.
- **Motif Track**: hollow circles for pending, filled diamonds for satisfied.
- **Active Rewrites**: up to 3 glyph strips; glyph is unique per rule (see §12.6).
- **Tempo Bar**: horizontal; segments per Tempo unit; last 10% flushes (or not, if reduced motion).

### 13.2 Motif Book overlay (M)

```
+---------------------------- MOTIF BOOK ----------------------------+
|                                                                    |
|   Tier 1                Tier 2                Tier 3               |
|   ┌───────┐             ┌───────┐             ┌───────┐            |
|   |   ▲   |  ◇          |  ⬡    |  ○          | ✦     |  ○         |
|   | ▲ ▲ ▲ |             | ⬡ ⬡ ⬡ |             | ✦ ✦   |            |
|   └───────┘             └───────┘             └───────┘            |
|   Motif 03  ◇           Motif 12  ○          Motif 41  ○           |
|                                                                    |
|   Tone: 3:2             Tone: 5:4             Tone: 15:8           |
|   Nodes: 8              Nodes: 14             Nodes: 22            |
|   Allows Ghost: no      Allows Ghost: yes     Mirror aware: yes    |
|                                                                    |
|   Legend:  ◇ satisfied   ○ pending   ✕ contradicts current rule    |
|                                                                    |
|                                                        [Close M]   |
+--------------------------------------------------------------------+
```

- Each Motif renders a schematic view (subgraph drawn in 2D).
- Selecting a Motif briefly highlights matching partial subgraphs in the 3D view.

### 13.3 Rewrite Preview banner (3–15s)

```
+-------------------------------------------------------------+
| MOTIF SATISFIED · REWRITE INCOMING · R8 COMPACTION           |
|                                                             |
| Trigger read:  H6 GROW  ·  D3 PRUNE-RATE 0.02               |
| Effect:  Outer 10% of un-Anchored, non-Bond nodes collapse  |
|          1 unit toward centroid.                            |
| Reversal:  5 outward EXTENDs (away from centroid).          |
|                                                             |
| Preview:     ████████████████░░░░░  3.0s remaining          |
|                                                             |
|   [ Commit (Enter) ]     [ Hold  1 available (H) ]          |
+-------------------------------------------------------------+
```

### 13.4 Chamber Select

```
+---------------- CHAMBER SELECT ----------------+
|                                                |
|      ACT I  SEED                               |
|      [1.1]  [1.2]  [1.3]  [1.4]  [1.5]  [1.6] [1.7]  |
|       ●      ●      ●      ●      ●      ○     ○    |
|                                                |
|      ACT II  GROWTH                            |
|      [2.1]  [2.2]  [2.3]  [2.4]  [2.5]  [2.6] [2.7]  |
|       ○      ○      -      -      -      -     -    |
|                                                |
|      ACT III  PRISM                            |
|      [3.1]  ...                                |
|       -      ...                               |
|                                                |
|      Ledger  |  Free Chambers  |  Options       |
+------------------------------------------------+
```

- `●` complete, `○` unlocked, `-` locked.

### 13.5 Ledger

```
+--------- LEDGER — YOUR LATTICE ---------+
|                                          |
|  H1 CADENCE histogram (last 100 Motifs)  |
|  FAST  ██████████░░░░░░  32              |
|  MID   ██████████████    47              |
|  SLOW  ██████░░░░░░░░░   21              |
|                                          |
|  H2 DIRECTIONALITY                       |
|  DIFFUSE  ████░░░░░░░    12              |
|  TILTED   ██████████░░   38              |
|  BIASED   ███████████    50              |
|                                          |
|  ...                                     |
|                                          |
|  Most‑fired rewrite: R3 BIAS AXIS (22)   |
|  Least‑fired rewrite: R10 REFRAIN (1)    |
|                                          |
|                          [Close L]       |
+------------------------------------------+
```

### 13.6 Options (top level)

```
+---------------------- OPTIONS ----------------------+
|  Difficulty:   ( ) Reader  (●) Standard  ( ) Cold   |
|  Reduced motion:              [OFF][ON]             |
|  Flatten shimmer:             [OFF][ON]             |
|  Colorblind palette:          [Default v]           |
|  Text scale:                  [ 100% - + 200% ]     |
|  Icon scale:                  [ 100% - + 150% ]     |
|  FOV:                         [ 60°  - + ]          |
|  Soft rewrite:                [OFF][ON]             |
|  Preview extension:           [ 3s  - + 15s ]       |
|  Hints (opt-in):              [OFF][ON]             |
|  Audio subtitles:             [OFF][ON]             |
|  HRTF:                        [OFF][ON]             |
|  Mono mix:                    [OFF][ON]             |
|  Screen reader mode:          [OFF][ON]             |
|  Master volume    ██████████░ 90%                   |
|  Verb tones       ████████░░░ 80%                   |
|  Ambient bed      ██████░░░░░ 60%                   |
|  UI               ████████░░░ 80%                   |
|  Rewrite cue      █████████░░ 90%                   |
|  Rebind controls...           [Open]                |
|  Save management...           [Open]                |
+-----------------------------------------------------+
```

### 13.7 Rebind controls sub‑screen

```
+---------------------- REBIND ------------------------+
|  Verb PLACE               Left Click  |  A          |
|  Verb EXTEND              E + arrow   |  X          |
|  Verb ROTATE              R           |  Y          |
|  ...                                                |
|  Reset to defaults [KBM] [Controller] [Both]        |
|  Single‑input mode: [OFF][ON]                       |
|  Input repeat rate  [ 400ms - + ]                   |
|  Input dead‑zone     [ 12% - + ]                    |
|                                                     |
|                                     [Close]         |
+-----------------------------------------------------+
```

### 13.8 Save management

```
+--------------- SAVE MANAGEMENT -----------------+
|                                                 |
|  Slot 1  ●  Act II — 2.3 Cinder Vault           |
|             Playtime 12h 08m   |  17 Runes      |
|             [Continue]  [Snapshots]  [Delete]   |
|                                                 |
|  Slot 2  ○  (empty)                             |
|  Slot 3  ○  (empty)                             |
|                                                 |
|  Import save [Open]     Export save [Save]      |
+-------------------------------------------------+
```

### 13.9 Startup screen (minimal)

```
+-----------------------------------------+
|                                         |
|                                         |
|              ECHO LATTICE               |
|                                         |
|                                         |
|            [ Continue ]                 |
|            [ New Lattice ]              |
|            [ Free Chambers ]  (locked)  |
|            [ Ledger ]        (locked)   |
|            [ Options ]                  |
|            [ Quit ]                     |
|                                         |
+-----------------------------------------+
```

---

## 14. Edge Cases

Every edge case below must have a shipped test in `docs/ECHO_LATTICE/tests/` at implementation time.

### 14.1 Save & Persistence
- **Crash mid‑action**: Action Log is append‑only, flushed to disk every action (or every 250ms, whichever is more frequent). On resume, replay Action Log against last full Snapshot.
- **Snapshot corruption**: if snapshot fails checksum, fall back to previous snapshot; if none, back to Chamber seed.
- **Save format migration**: `save.version` int. Migrations are pure functions in `game/save/migrations/*.gd`, applied in order on load.
- **Two writers**: game holds a lock on save file (`.lock` sentinel). Second instance boots read‑only.

### 14.2 Input & Devices
- **Controller unplug mid‑action**: pause on unplug; resume on replug or on any KBM input.
- **Simultaneous KBM + gamepad**: both active; the most recent input source drives the cursor.
- **Non‑Latin keyboard**: default bindings avoid layout‑dependent keys where possible; text uses UI icons.
- **High DPI**: UI scales by OS DPI, capped at 200% by text scale slider.
- **Ultra‑wide (≥ 21:9)**: HUD panels dock to safe zones (16:9 letterbox for HUD elements only; lattice fills full width).
- **4K**: renders native; UI stays at 100% until scaled.
- **High refresh rate (120–240 Hz)**: physics runs at fixed 60 Hz; rendering interpolated. Habit metrics use logical action time, not frame time.

### 14.3 Focus & System
- **Alt‑Tab**: game pauses. Ambient bed fades to −inf dB over 250ms.
- **Sleep/hibernate**: on resume, all timers use monotonic in‑chamber time; wall clock skew ignored.
- **Timezone/DST change**: irrelevant; game never uses wall‑clock for logic.
- **System locale**: only Options text is localized (v1.0 shipping English; layout supports right‑to‑left and CJK by design).

### 14.4 Numerics & Snapping
- **Lattice near skew boundary**: snapping tolerance widened to 0.15 lattice units under skew; ambiguous nodes resolved by lower `NodeId`.
- **Rotate on a face with mixed Bond/non‑Bond**: face rotates; Bonds carry with their two endpoints; edges break only where they cross another Bond.
- **Drift component adopted mid‑rotate**: rotate cancels for the adopted subset; explicit undo issued.
- **Empty Lattice**: PLACE is always legal at Chamber origin site; UI shows a ring at origin.

### 14.5 Gameplay Corner Cases
- **Motif satisfaction flickering**: a Motif toggling in/out inside the 500ms sustain window resets the sustain; the sustain must be uninterrupted.
- **Two Motifs share a required node with contradictory labels**: contradiction is legal; both Motifs may match if the underlying graph satisfies both label sets simultaneously.
- **Rewrite that would prune all nodes (R8 or R12)**: rule clamps to preserve at least `⌈|N|·0.5⌉` nodes and never remove Anchored nodes.
- **Rewrite Preview during Hold**: only one Hold per Chamber; after using it, next rewrite still gets its 3s preview.
- **Simultaneous multi‑Motif completion in one action**: all triggered Motifs are queued; rewrites fire one at a time with independent 3s previews between (or Hold cascading, one Hold per Chamber total).

### 14.6 Determinism
- **Different physics tick rate on different hardware**: physics is a fixed logical step; renderer decouples. Given the same Action Log, the Lattice state is bit‑identical across machines within the same save format version.
- **Loading a save on a different substrate build**: substrate parameters are versioned; incompatible loads offer a migration or a read‑only view.

### 14.7 Audio Edge Cases
- **No audio device**: game runs, audio subtitles auto‑enable.
- **Sample rate mismatch**: engine resamples verb tones at load; pitching is done in the frequency ratio table, not by sample stretching.

### 14.8 Accessibility Edge Cases
- **Screen reader + gamepad**: TTS announces cursor context on RS movement; latency budget 250ms.
- **Single‑input mode + rewrite preview**: preview extended automatically to 6s minimum.

### 14.9 Content Edge Cases
- **Motif contradicts current rewrite (e.g., a planarity Resonance while R14 SHEAR is active)**: allowed but marked with `✕` in Motif Book. Player must reverse the rewrite before satisfying the Motif.
- **Chamber unsolvable due to player action + HARD rewrite**: Rewind is always available; no chamber is trap‑lockable because at least one Snapshot exists (Chamber seed).

---

## 15. Anti‑Features (Explicit)

The following are forbidden by design. Any PR introducing them requires explicit design sign‑off overriding this document.

| # | Anti‑feature | Rationale |
|---|---|---|
| A1 | LLM or neural worldgen at runtime | P2 bounded generativity. All generation is deterministic rules. |
| A2 | LLM or neural content at build time in ways that leak into user‑visible strings unaudited | P2, product safety. Any AI‑assisted asset is human‑reviewed and its output is baked in. |
| A3 | Procedural narrative | The game has no narrative. |
| A4 | Voice acting / dialog | P4 silent play. |
| A5 | Cutscenes | P4; also breaks flow. |
| A6 | Tutorial pop‑ups mid‑play | P4; teach through Legend + affordance only. |
| A7 | Text overlays during Lattice interaction | P4. |
| A8 | Microtransactions | Priced flat on Steam. |
| A9 | DLC that adds mechanics rather than chambers | Mechanics changes go to base game or a paid new game. |
| A10 | Always‑online requirement | Offline‑first. |
| A11 | Telemetry without explicit opt‑in | Opt‑in only; must be off by default. |
| A12 | Player‑vs‑player | Not the fantasy. |
| A13 | Public leaderboards | Player is compared only to themselves in Ledger. |
| A14 | Daily rewards / streaks / retention hooks | Anti‑habit‑exploit; ironic given the theme. |
| A15 | Cosmetics store | No purchases beyond base game. |
| A16 | Progression gates for time (energy bars, timers) | No. |
| A17 | Random cosmetic drops | No. |
| A18 | Advertising / cross‑promo in UI | No. |
| A19 | Forced sign‑in / third‑party accounts | Steam login only; nothing else. |
| A20 | Notifications when app is closed | No. |
| A21 | "Metaverse" features, avatars, or emotes | No. |
| A22 | Season passes | No. |
| A23 | Kernel anti‑cheat | Single‑player; not required. |
| A24 | Data harvesting of habit metrics beyond local Ledger | H1–H8 never leave the device. |
| A25 | Difficulty ramp keyed to session length or engagement funnels | Difficulty comes from Chamber design, not from behavior‑modeling. |
| A26 | Achievement design that rewards grinding or repetition | Achievements (if shipped at all) are milestone‑based. |
| A27 | UI text longer than 3 lines in play | P4. |
| A28 | Any "call the mothership" behavior | Offline; only Steam interaction is standard app launch. |

---

## 16. Test Matrix (implementation gate)

Every row must have a documented, automated or manual test at gold master.

| Area | Test | Type |
|---|---|---|
| Determinism | Replay Action Log → identical Lattice state on 3 different machines | automated |
| Determinism | Same `S_chamber` → identical seed lattice + Motif Book across runs | automated |
| Rewrites | R1–R15 each fire on prepared Action Log fixtures | automated |
| Rewrites | Hold defers exactly one Rewrite per Chamber | automated |
| Rewrites | Rewrite cap enforced (age‑out oldest non‑HARD) | automated |
| Rewrites | HARD rules gated per Chamber table | automated |
| Habit metrics | H1–H8 computed correctly on 50 fixture logs | automated |
| Motif | Isomorphism finds all 60 Motifs on golden lattices | automated |
| Motif | Sustain 500ms enforced (no flicker satisfaction) | automated |
| Resonance | Each RC type verified on prepared graphs | automated |
| Save | Crash mid‑action recovers from Action Log | manual |
| Save | Version migration from `v0` fixture to `v1` | automated |
| Input | Controller unplug/replug during rewrite preview | manual |
| Accessibility | Single‑input mode completes 1.1 with only 5 keys | manual |
| Accessibility | Screen reader announces all state transitions | manual |
| Photosensitivity | No flash above 3 Hz in any state | automated (render frame diff) |
| Performance | 60 Hz sustained on GTX 1060 at 1080p on Chamber 3.7 | manual |
| Determinism | All 21 Chambers solve within solver budget | automated |
| Localization | Options screen wraps correctly at 200% text | manual |

---

## 17. Data & Tuning Constants (initial values)

All constants below live in `game/config/tuning.json` for `code‑review‑at‑a‑glance` tunability. Any change must land with a note in `docs/ECHO_LATTICE/CHANGELOG.md`.

### 17.1 Timing & budgets
```json
{
  "habit_window": { "act1": 32, "act2": 48, "act3": 64 },
  "tempo_start_base": 60,
  "tempo_per_motif": 8,
  "tempo_per_act": 12,
  "rewrite_preview_seconds": { "reader": 6.0, "standard": 3.0, "cold": 1.5 },
  "hold_tokens_per_chamber": 1,
  "spin_field_period_seconds": 12,
  "atrophy_leaf_timeout_seconds": 30,
  "reverb_delay_seconds": 2,
  "motif_sustain_ms": 500,
  "undo_debounce_ms": 120
}
```

### 17.2 Habit thresholds
```json
{
  "H1": { "fast_max_ms": 600, "slow_min_ms": 1800 },
  "H2": { "diffuse_max": 0.30, "biased_min": 0.55 },
  "H3": { "dominant_min": 0.40 },
  "H4": { "long_min": 4 },
  "H5": { "asym_max": 0.40, "sym_min": 0.75 },
  "H6": { "shrink_max": -0.05, "grow_min": 0.05 },
  "H7": { "tidy_max": 0.05, "thrash_min": 0.20 },
  "H8": { "refrain_min": 3 },
  "D1_var_ms_reverb_min": 2000,
  "D2_anchor_rate_silent_min": 0.25,
  "D3_prune_rate_atrophy_min": 0.40
}
```

### 17.3 Rewrite effect magnitudes
```json
{
  "crystallize_edges": 5,
  "compaction_pct": 0.10,
  "compaction_min_preserved_pct": 0.50,
  "bloom_ghost_decay_seconds": 8,
  "seed_reserve_max": 3,
  "shear_deg": 15,
  "spin_field_step_deg": "$substrate.rotation_step",
  "refrain_extra_depth": 1,
  "chorus_cost_reduction": 1,
  "silent_lattice_zero_verb_tone": true
}
```
(`"$substrate.rotation_step"` = placeholder resolved at Chamber load from the substrate's rotation step.)

### 17.4 Motif JSON schema
```json
{
  "id": "M-014",
  "tier": 2,
  "nodeCount": 14,
  "edges": [ [0,1], [1,2], [2,3], "..." ],
  "labels": { "0": "*", "3": "anchored", "12": "bond-only" },
  "edgeLabels": { "0-1": "bond", "5-7": "ghost-ok" },
  "signatureTone": [3, 2],
  "preferredSubstrates": ["FCC", "Hex-prism"],
  "allowsGhost": true,
  "mirrorAware": true
}
```

### 17.5 Solver budget (per Chamber, pre‑ship)
```json
{
  "max_search_depth_verbs": 60,
  "max_search_time_seconds_per_chamber": 300,
  "solver_uses_ml": false
}
```

### 17.6 Save file layout
```
save.json
├── version: int
├── slot: int
├── active_chamber: string   ("1.3")
├── runes_unlocked: [string]
├── options: { ... }
├── ledger: { H1_hist, H2_hist, ..., rewrite_counts }
├── chambers: { "1.1": { snapshots: [...], action_log_path: "..." }, ... }
└── audit: { created_at, last_played_at, playtime_seconds }
```
- Human‑readable JSON. No binary.
- Action logs stored per Chamber in `action_log_<chamber>.jsonl`, one action per line.

---

## 18. Non‑functional Requirements

### 18.1 Performance
- 60 fps at 1080p on a 2018‑era mid‑range GPU (e.g., GTX 1060) for all shipped Chambers.
- CPU budget per frame: renderer 8ms; game logic 4ms; audio 1ms; slack 4ms.
- Node budget per Chamber: 300 Normal nodes + 200 Ghosts + 50 Anchored + 50 Drift.
- Motif isomorphism must run under 3ms per attempt at maximum Motif size (30 nodes) on target hardware.

### 18.2 Memory
- 200MB RAM steady in‑Chamber.
- 1GB peak on Chamber 3.7.
- No unbounded growth during long sessions (Snapshot ring buffer size = 16 per Chamber).

### 18.3 Load times
- Cold start to Main Menu: ≤ 4 seconds.
- Chamber load: ≤ 1 second.

### 18.4 Autosave & Crash
- Autosave every action (Action Log append).
- Full Snapshot every Motif commit and Chamber transition.
- Crash resume reproduces the last committed action to the frame.

### 18.5 Determinism budget
- All PRNG use `xoshiro256**`, seeded per Chamber.
- No use of wall‑clock, no environmental entropy in game logic.
- Floating‑point ops in the hot path avoid transcendentals except in audio; where used, results are quantized to `1e-4` before storing.

### 18.6 Platform
- Windows 10 x64 and Windows 11 x64 primary targets.
- Steam client integration for Cloud Save (opt‑in), Achievements (§15 A26 compliant), Steam Input.
- Linux (Proton) supported best‑effort; no Steam Deck verified stamp targeted at v1.0 (targeted at post‑launch patch).

---

## 19. Milestones (design‑side, engineering plans separately)

Milestones are described by what is playable, not by time.

| Milestone | Playable state |
|---|---|
| **M1 Vertical Slice** | Chamber 1.1 fully playable, 3 rewrites (R2, R3, R6) live, 6 verbs, no Runes. |
| **M2 Act I Complete** | 1.1–1.7 playable, 7 Runes live, 8 rewrites (R1–R6, R9, R10) live, Ledger read‑only. |
| **M3 Substrate Expansion** | FCC + Hex‑prism substrates live; Act II Chambers 2.1–2.4 playable. |
| **M4 All Rewrites** | R1–R15 shipped; Act II complete; all accessibility settings shipped. |
| **M5 Act III Complete** | 3.1–3.7 shipped; Diamond + Icosahedral substrates; all 21 Runes; Free Chambers. |
| **M6 Certification** | Full test matrix (§16) green; solver‑verified all Chambers under all difficulty modes; localization strings frozen. |

---

## 20. Glossary

| Term | Definition |
|---|---|
| **Lattice** | The active 3D graph the player manipulates. |
| **Substrate** | Underlying legal geometry (Cubic, FCC, Hex‑prism, Diamond, Icosahedral). |
| **Verb** | One of six atomic player actions: PLACE, EXTEND, ROTATE, PRUNE, ANCHOR, ECHO. |
| **Node** | A vertex of the Lattice at a legal substrate site. |
| **Edge** | A connection between two adjacent nodes along a substrate direction. |
| **Face** | Minimal induced cycle in the current substrate; the target of ROTATE. |
| **Bond** | An unbreakable edge (introduced by Crystallize). |
| **Ghost** | A tentative node not yet permanent; does not count for Motif matching. |
| **Anchored** | A node marked immovable and non‑Prunable. |
| **Drift** | Disconnected component of the Lattice, floating outward. |
| **Crystal (face)** | A face made permanent by R15; cannot rotate, doubles Motif area. |
| **Motif** | A hand‑authored target subgraph the player must produce. |
| **Motif Book** | The set of Motifs for the current Chamber, drawn deterministically from 60 authored Motifs. |
| **Chamber** | One playable puzzle unit (21 total, 7 per Act × 3 Acts). |
| **Act** | Group of 7 Chambers sharing substrate progression. |
| **Rewrite** | A deterministic geometric mutation triggered on Motif completion, keyed to a habit metric. |
| **Rewrite Rule** | One of R1–R15. |
| **Habit Window** | Rolling set of last `w` actions used to compute H1–H8. |
| **Habit Metric (H1–H8)** | The eight scalars derived from Habit Window. |
| **Tempo** | Per‑Chamber budget spent by verbs. |
| **Rune** | A permanent verb modifier unlocked at Chamber completion (21 total). |
| **Resonance** | The chamber‑final global constraint that must hold with all Motifs simultaneously. |
| **Snapshot** | Full lattice + habit window save taken at Motif commit and Chamber start. |
| **Hold** | Once‑per‑Chamber token to defer an incoming Rewrite. |
| **Ledger** | Local, private, per‑save record of the player's habit history. |
| **STALLED** | A Chamber state where Tempo has run out before Resonance; recoverable via Rewind/Reset. |

---

## 21. Open Questions (design‑side, tracked for follow‑up docs)

These are deliberately open and NOT blockers for implementation start. They will be closed in `docs/ECHO_LATTICE/02_*.md` documents.

- **O‑1** Whether the Ledger should surface trend lines (H1 over time) or only snapshots. Default in v1.0: snapshots only.
- **O‑2** Whether Free Chambers may unlock a 16th rule slot for community‑authored `motifs.json` packs. Default in v1.0: no (P2).
- **O‑3** Precise tuning of R14 SHEAR angle (15° vs 10° vs 20°) — pending playtest.
- **O‑4** Whether to allow "manual rewrite" (spend Tempo to skip preview). Default in v1.0: no.
- **O‑5** Whether Chamber 3.7 unlocks a 22nd rune (a themed capstone). Default in v1.0: no; the Chamber itself is the reward.

---

*End of GDD v1.0. Next document: `02_TECH_SPEC.md` (engine, data flow, ECS layout). Implementation may begin against this document as‑is; every constant is a defined seed value.*
