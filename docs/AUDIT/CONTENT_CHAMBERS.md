# Echo Lattice — Content Chambers Audit

**Branch audited:** `cursor/echo-lattice-rc1`  
**Audit branch:** `cursor/audit-content`  
**Scope:** authored chamber JSON, `acts.json`, captions/hints/locale, teach-vs-test roles, dead ends / unreachable geometry, demo spoiler surface, replay/daily value, missing setpieces, balance hotspots.  
**Authority docs:** [`04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md), [`DEMO_SPEC.md`](../RELEASE/DEMO_SPEC.md), [`14_BALANCE_V2.md`](../ECHO_LATTICE/14_BALANCE_V2.md).  
**Method:** static inventory of all 39 chamber files + `acts.json` + locale/demo gates; BFS topology; Hamming map-clone scan; schema/bible cross-check. `validate_chambers.py` → **OK** (solvability net green; does not catch clones or pedagogy).

**Verdict:** Campaign spine and Act I demo beat are coherent; the biggest content debt is **template reuse** (three exact map clones, several near-clones), **dead `rewrite.cap` metadata**, and **replay variation gates** that make Daily mostly palette-deep. Fix clones + hard-variant honesty before adding more chambers.

### P0 resolution notes (`cursor/fix-content-clones`)

| P0 item | Status | Notes |
|---|---|---|
| Exact clones `04==09`, `18==35`, `19==27` | **Fixed** | Distinct teach/test maps in author roster + regen; clone detector in `validate_chambers.py` |
| Wire or delete `rewrite.cap` | **Wired** | Enforced in `chamber.gd`; `05`/`08` caps raised to 2; author `max(act_default, C)` |
| Balance ↔ four-act roster | **Retargeted** | SEED/GROWTH/**PRISM**/**MASTERY** ↔ Induction/Reflection/**Pressure**/**Mastery**; no Act IV→PRISM clamp |

See also [`content/README.md`](../../game/echo_lattice/content/README.md) CONTENT notes.

---

## 1. Inventory

| Bucket | Count |
|---|---|
| Authored chambers | **39** (35 campaign + 4 hard) |
| Acts | Induction (9) · Reflection (9) · Pressure (9) · Mastery (8) |
| Roles | lesson 10 · remix 20 · boss 4 · hard 4 · daily_showcase 1 |
| Transforms used | `none`, `mirror_v`, `mirror_h`, `rotate_180`, `thicken`, `mirror_v_then_h` |
| Transforms missing | `invert` (named in art/audio/bible as later unlock; slug `invert_ballet` still uses `rotate_180`) |
| Daily-eligible | 35 / 39 (tutorial `00`–`02`, `04` excluded) |
| Locale keys | title+caption present for all 39 (EN + zh_Hans) |

Roster lives in `game/echo_lattice/content/acts.json`. Full machine table: [Appendix A](#appendix-a--chamber-roster).

### Transform mix by act

| Act | Dominant | Notes |
|---|---|---|
| Induction | `mirror_v` ×5 | Full teach of all four base ops + identity boss |
| Reflection | even mix | Only act that **introduces** `mirror_v_then_h` |
| Pressure | `thicken` ×5 | Correct thematic focus; mirrors feel like fillers |
| Mastery | `mirror_v_then_h` ×4 | Composition claim is thin — still single forced ops |

---

## 2. Findings

### 2.1 Exact / near map clones (severity: critical)

Hamming distance on padded 24×14 maps:

| Dist | Pair | Why it hurts |
|---|---|---|
| **0** | `04_ceiling_first` == `09_twin_rail` | Act II “lesson” is a transform swap on Act I’s horizontal-mirror map. No new geometry. |
| **0** | `18_cement_trail` == `35_mirror_birth_hard` | Hard variant of Mirror Birth is **Cement Trail’s map** with `mirror_v`. Caption “Less floor / same lesson” is false vs parent (`02` differs by 41 cells; floor count unchanged vs `18`). |
| **0** | `19_no_retread` == `27_conductors_cut` | Mastery opener reuses Pressure remix geometry. |
| **2** | `13_gallery_walk` ≈ `25_panic_lattice` | Pillar hall reused; only checkpoint x-shift. Same 12 floor dead-ends. |
| **3** | `08_identity_induction` ≈ `33_nameplate` | Final boss nearly identical to first boss footprint. |
| **2–6** | `06` / `18` / `22` / `35` family | Shared “horizontal rail stack” template. |

**Impact:** late-act novelty collapses; hard mode and Daily feel like re-skinned early maps; identity “portraits” risk looking the same across acts.

### 2.2 Teach vs test (pedagogy)

Bible rule: *first chamber that introduces a transform in an Act is `lesson`; later same-transform chambers are `remix` / `boss` / `hard`.*

| Status | Detail |
|---|---|
| **Good** | Induction: clean ladder `none` → `mirror_v` → `mirror_h` → `rotate_180` → `thicken` → boss. Demo hook `02_mirror_birth` lands early. |
| **Role tags wrong** | First `mirror_h` / `rotate_180` in Reflection (`10_roof_writing`, `11_opposite_room`) tagged `remix` not `lesson`. Same pattern for Pressure reintroductions (`20`/`22`/`23`/`24`) and Mastery (`28`/`29`/`31`). |
| **Cap vs checkpoints** | `05_two_glances` and `08_identity_induction` claim **two** checkpoints / rewrites in caption but `rewrite.cap: 1`. Playable `chamber.gd` fires every unused `C` and **does not read** chamber `rewrite.cap` — field is ornamental. |
| **Hint drought** | 24 / 39 chambers have **empty** `hints[]`, including all hard variants and most Pressure/Mastery remixes. Induction lessons + bosses are covered. |
| **Name vs op** | `28_invert_ballet` teaches rotation, not invert — spoils the future unlock name and confuses glossary. |
| **Act openers** | Difficulty correctly eases −1 after each boss (`3→2`, `4→3`, `5→4`). |

### 2.3 Captions & copy

Strengths: short, imperative, mostly under 55 chars; locale parity complete.

Hotspots:

| Issue | Examples |
|---|---|
| Meta “Boss.” / “Hard.” prefixes | All four bosses + four hards — readable but same sentence mold |
| Caption dishonest vs geometry | `35` “Less floor”; `38` “less breathing room” (floor 175==parent) |
| Mechanic spoilers in caption | `05` “Two checkpoints, two rewrites” while cap says 1 |
| Flavor drift | `31` “Thicken **mastery**”, `18` “under **pressure**” — act-name leaks inside chamber voice |
| Motif banners | Duplicate the chamber caption on `M1` only; multi-`C` chambers never get per-checkpoint banners |

### 2.4 Dead ends & unreachable volume

Pre-rewrite BFS from `P` (walkable = `.PGC`):

| Chamber | Unreachable walkable | Notes |
|---|---|---|
| `00_quiet_span` | **154** | Sealed lower rooms — theatrical dead volume; fine for tutorial, but wastes the grid and can confuse map-readers / screenshot framing |
| `03_break_the_loop` | **65** | Large sealed pockets inside the loop maze — intended “don’t go there” ink, but reads as unfinished |
| `06_far_side`, `15_spin_gallery`, `21_stacked_echo` | 1–4 | Minor orphans |

High floor dead-end counts (≥8, single-neighbor `.` cells): `13_gallery_walk` (12), `25_panic_lattice` (12), `20_squeeze_mirror` (8), `36_looking_glass_hard` (8). For mirror/thicken puzzles these are **pre-commit lure cul-de-sacs** — good pressure if intentional; clone pair `13`/`25` doubles the same trap layout.

All chambers: `P` reaches `G` and every `C` on the base layout (validator OK). Softlock safety net remains the design crutch for post-rewrite fairness.

### 2.5 Demo spoiler leaks

Runtime/export gates are mostly solid:

- `DemoBuild.allowed_campaign_ids` = Act I `00`–`08`
- Windows Demo `exclude_filter` drops `09_*`…`3*_*.json`
- `ChamberBook.acts_summary()` strips non-Induction acts
- Menu demo subtitle hardcoded: `Demo — Act I · Mirror Birth. Ink on paper.`
- Self-test asserts late ids not loaded

Residual leaks / risks:

| Surface | Risk | Severity |
|---|---|---|
| `locale/echo_lattice.csv` | **All** late-act titles/captions + `act.reflection/pressure/mastery` ship in demo PCK | Med — dumpable; any UI bug that lists locale keys spoils |
| `content/acts.json` | Full four-act roster + blurbs still packed; filtered only in GDScript | Med |
| `config/achievements_steam.json` | “Escape Act II/III/IV”, “Pressure Fold”, etc. | Low–Med if Steam overlay lists locked ach in demo |
| Daily seeds catalog | Full-game seed list packed; runtime pools Act I only | Low |
| Hardcoded demo subtitle | Bypasses `tr()` / DEMO_SPEC table (EN-only) | Low |

Act I captions themselves are demo-safe (no late-act names).

### 2.6 Replay value

| Lever | State |
|---|---|
| `variations.allow_rotate` | **8 / 39** true |
| `variations.allow_reflect` | **18 / 39** true |
| Palette-only (both false) | **21 / 39** — Daily often only recolors |
| `hard_mode` deltas | Uniform `tempo_delta` −4/−8 + `par_moves_mult` 0.85; not geometry |
| `tempo_start` | **9999 on every chamber** — unused as a difficulty lever |
| Stars vs `par_moves` | Multi-commit chambers use authored par ≫ base BFS (`33` par 100 / bfs 32 ≈ 3.1×) — star chase OK if rewrite path length tracked; verify against `StarRater` telemetry |
| Friend/ghost | `34_open_lattice` is the only `daily_showcase`; cross-run ghost still deferred (changelog) |

### 2.7 Missing setpieces

Expected by bible / art / roadmap but absent or hollow:

1. **`invert` transform chamber** — audio/art ready; content non-goal for v2, but `invert_ballet` burns the name.
2. **Per-act hard for each pillar lesson** — only one hard/act; no `mirror_h` / `rotate_180` / dual-axis Pressure hard.
3. **True composition setpiece** — `teaches: composition` on `30`/`32` still `forced_op` single transform; no player-chosen op.
4. **Distinct identity geometries** — bosses should not share footprints (`08`≈`33`).
5. **Act II dual-axis “face” readable layout** — caption promises a face; map is open hall, portrait left entirely to player path (acceptable if Museum screenshots prove it).
6. **Act V / invert** correctly fenced post-1.0 in `ROADMAP.md` — do not sneak into this backlog as 1.0 scope creep except renaming / one optional optional-op chamber if systems land.

### 2.8 Balance hotspots

| Hotspot | Evidence |
|---|---|
| **Doc drift** | `balance_v2.json` / `14_BALANCE_V2.md` still describe **3 acts** (SEED/GROWTH/PRISM, 7 chambers each). Shipping content is **4 acts × ~9**. Numbers and telemetry targets do not map. |
| **Ornamental `rewrite.cap`** | Chamber JSON caps unused by `chamber.gd`; Act bible caps (1/2/3/3) only loosely match multi-`C` rooms. |
| **Induction multi-commit under cap 1** | `05`, `08` teach two commits while Act I bias/cap story says one rewrite. |
| **Difficulty plateau** | Campaign sits at difficulty 4–5 from `21` through `34` with little geometric novelty (clones). Risk: fatigue, not spike. |
| **Par inflation** | `21`, `26`, `30`, `33`, `38` par/BFS ≥ 2.66 without verified rewrite-path par regeneration. |
| **Hard variants** | `35` wrong parent geometry; `38` same floor as parent; only transform/par tweaks. |
| **Dead-end bias** | Balance JSON `dead_end_bias` unused by authored maps — authorship is hand-tuned, not driven by config. |

---

## 3. Ranked content upgrade backlog

Priority: **P0** ship-blocking / trust · **P1** campaign quality · **P2** demo/liveops polish · **P3** post-1.0 adjacent.

| Rank | Pri | Item | Why | Touch |
|---|---|---|---|---|
| 1 | **P0** | **Rebuild exact clone maps** — unique geometry for `09_twin_rail`, `27_conductors_cut`, and a true `35_mirror_birth_hard` derived from `02` | Players notice; hard mode is a lie; Mastery opener is Pressure | chamber JSON + `author_chambers_v2.py` |
| 2 | **P0** | **Wire or delete `rewrite.cap`** — either enforce in `chamber.gd` or raise caps on `05`/`08` and stop advertising dual rewrites under cap 1 | Caption/systems mismatch | scripts + JSON |
| 3 | **P0** | **Reconcile Balance v2 ↔ four-act roster** — retarget act tables, escalation curve, clear-rate ideals | Telemetry/tuning aimed at wrong skeleton | `balance_v2.json`, `14_BALANCE_V2.md` |
| 4 | **P1** | **Diverge near-clones** — `13`≠`25`, `08`≠`33`, rail-stack family (`06`/`18`/`22`) | Restores act identity | maps |
| 5 | **P1** | **Fix teach/test roles** — mark first-in-act transforms as `lesson`; keep remixes honest | Bible compliance; UI/filters | JSON tags |
| 6 | **P1** | **Hard-variant pass** — each hard = tighter parent (floor/checkpoints/par), honest captions; add `mirror_h` + `rotate_180` hards | Daily + mastery track | 4–6 JSON · **UI entry done** (`cursor/fix-remaining-p1` Hard+ menu); map/caption honesty still open |
| 7 | **P1** | **Hint pack** for Pressure/Mastery remixes + hards (1 line each) | Anti-frustration without spoiling | JSON + locale |
| 8 | **P1** | **Caption rewrite** — drop mechanical Boss./Hard. mold; remove act-name leaks; align `05`/`35`/`38` with truth | Voice + trust | JSON + `echo_lattice.csv` |
| 9 | **P1** | **Rename `invert_ballet`** → rotation-true title (e.g. Far Mark / Counterspin) until `invert` ships | Glossary hygiene | id/slug migration carefully |
| 10 | **P2** | **Demo spoiler hygiene** — strip or stub late `chamber.*` / `act.*` keys from demo export; slim `acts.json` or generate demo acts | DEMO_SPEC §3 | export_presets + build script |
| 11 | **P2** | **Localize demo subtitle** (`menu.subtitle_demo`) instead of hardcoded EN | DEMO_SPEC §4 | menu.gd + csv |
| 12 | **P2** | **Open variation gates** on Daily-eligible remixes (rotate/reflect where transform-safe) | Replay without new maps | `variations` |
| 13 | **P2** | **Trim theatrical unreachable volumes** in `00`/`03` or mark as intentional `tags: [scenic_void]` | Clarity | maps or tags |
| 14 | **P2** | **Per-checkpoint motif banners** on multi-`C` chambers | Pedagogy at the slam | motifs |
| 15 | **P2** | **Regenerate `par_moves`** from auto-solver path length (+ slack) | Star fairness | author script |
| 16 | **P3** | **Composition setpiece** — one Mastery chamber with player-picked op or sequenced forced ops that feel authored | Fantasy payoff | systems+content |
| 17 | **P3** | **`invert` lesson + remix** when op enabled (do not ship under fake name) | Art/audio already expect it | post-1.0 / DLC fence |
| 18 | **P3** | **Second daily_showcase** + Museum-facing identity screenshot seeds | Liveops / marketing | content+meta |

---

## 4. Suggested fix order (engineering)

```
P0 clones + cap truth
    → P0 balance doc/json retarget
        → P1 near-clone divergence + hard honesty
            → P1 captions/hints/roles + locale
                → P2 demo export slim + variation gates
                    → P3 composition / invert (systems-gated)
```

Validation after each content edit:

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/test_demo_spec.py
python3 game/echo_lattice/tests/validate_locale.py
# optional: godot --headless --path game/echo_lattice -- --selftest --demo
```

Add a **clone detector** to `validate_chambers.py` (fail if Hamming == 0 across distinct ids; warn if < 8). That prevents regressions.

---

## 5. What is already in good shape

- Act I teach ladder and demo marketing beat (`Mirror Birth` → induction boss).
- Demo runtime filters + export chamber exclude + self-test spoiler asserts.
- Schema + Python solvability playthrough green for all 39.
- Locale title/caption coverage complete.
- Act boundary difficulty breathers after bosses.
- Identity bosses exist per act with distinct `identity` tags.
- Content bible / acts.json / filenames stay in sync (no orphan files).

---

## Appendix A — Chamber roster

| # | Id | Title | Act | Transform | Role | Diff | Par | C | Daily |
|---|---|---|---|---|---|---|---|---|---|
| 00 | `00_quiet_span` | Quiet Span | induction | `none` | lesson | 0 | 18 | 0 | False |
| 01 | `01_echo_plate` | Echo Plate | induction | `none` | lesson | 0 | 34 | 0 | False |
| 02 | `02_mirror_birth` | Mirror Birth | induction | `mirror_v` | lesson | 1 | 40 | 1 | False |
| 03 | `03_break_the_loop` | Break the Loop | induction | `mirror_v` | remix | 1 | 48 | 1 | True |
| 04 | `04_ceiling_first` | Ceiling First | induction | `mirror_h` | lesson | 1 | 42 | 1 | False |
| 05 | `05_two_glances` | Two Glances | induction | `mirror_v` | remix | 2 | 55 | 2 | True |
| 06 | `06_far_side` | Far Side | induction | `rotate_180` | lesson | 2 | 44 | 1 | True |
| 07 | `07_first_thicken` | First Thicken | induction | `thicken` | lesson | 2 | 46 | 1 | True |
| 08 | `08_identity_induction` | Who Walked | induction | `mirror_v` | boss | 3 | 70 | 2 | True |
| 09 | `09_twin_rail` | Twin Rail | reflection | `mirror_v` | lesson | 2 | 50 | 1 | True |
| 10 | `10_roof_writing` | Roof Writing | reflection | `mirror_h` | remix | 2 | 52 | 1 | True |
| 11 | `11_opposite_room` | Opposite Room | reflection | `rotate_180` | remix | 2 | 56 | 1 | True |
| 12 | `12_looking_glass` | Looking Glass | reflection | `mirror_v_then_h` | lesson | 3 | 58 | 2 | True |
| 13 | `13_gallery_walk` | Gallery Walk | reflection | `mirror_v` | remix | 3 | 64 | 1 | True |
| 14 | `14_horizon_fold` | Horizon Fold | reflection | `mirror_h` | remix | 3 | 66 | 2 | True |
| 15 | `15_spin_gallery` | Spin Gallery | reflection | `rotate_180` | remix | 3 | 68 | 2 | True |
| 16 | `16_false_twin` | False Twin | reflection | `mirror_v` | remix | 3 | 70 | 1 | True |
| 17 | `17_identity_reflection` | Portrait | reflection | `mirror_v_then_h` | boss | 4 | 80 | 2 | True |
| 18 | `18_cement_trail` | Cement Trail | pressure | `thicken` | lesson | 3 | 55 | 1 | True |
| 19 | `19_no_retread` | No Retread | pressure | `thicken` | remix | 3 | 62 | 1 | True |
| 20 | `20_squeeze_mirror` | Squeeze Mirror | pressure | `mirror_v` | remix | 3 | 60 | 1 | True |
| 21 | `21_stacked_echo` | Stacked Echo | pressure | `mirror_v` | remix | 4 | 85 | 3 | True |
| 22 | `22_spin_trap` | Spin Trap | pressure | `rotate_180` | remix | 4 | 72 | 1 | True |
| 23 | `23_ceiling_press` | Ceiling Press | pressure | `mirror_h` | remix | 4 | 68 | 1 | True |
| 24 | `24_compound_fracture` | Compound Fracture | pressure | `mirror_v_then_h` | remix | 4 | 78 | 2 | True |
| 25 | `25_panic_lattice` | Panic Lattice | pressure | `thicken` | remix | 4 | 74 | 1 | True |
| 26 | `26_identity_pressure` | Calcify | pressure | `thicken` | boss | 5 | 90 | 2 | True |
| 27 | `27_conductors_cut` | Conductor's Cut | mastery | `mirror_v` | lesson | 4 | 72 | 1 | True |
| 28 | `28_invert_ballet` | Invert Ballet | mastery | `rotate_180` | remix | 4 | 76 | 2 | True |
| 29 | `29_two_axes` | Two Axes | mastery | `mirror_v_then_h` | remix | 4 | 70 | 2 | True |
| 30 | `30_habit_orchestra` | Habit Orchestra | mastery | `mirror_v` | remix | 5 | 95 | 3 | True |
| 31 | `31_last_buffer` | Last Buffer | mastery | `thicken` | remix | 5 | 80 | 1 | True |
| 32 | `32_signature_stack` | Signature Stack | mastery | `mirror_v_then_h` | remix | 5 | 88 | 2 | True |
| 33 | `33_nameplate` | Nameplate | mastery | `mirror_v_then_h` | boss | 5 | 100 | 3 | True |
| 34 | `34_open_lattice` | Open Lattice | mastery | `mirror_v` | daily_showcase | 4 | 64 | 2 | True |
| 35 | `35_mirror_birth_hard` | Mirror Birth+ | induction | `mirror_v` | hard | 3 | 50 | 1 | True |
| 36 | `36_looking_glass_hard` | Looking Glass+ | reflection | `mirror_v_then_h` | hard | 4 | 70 | 2 | True |
| 37 | `37_cement_trail_hard` | Cement Trail+ | pressure | `thicken` | hard | 4 | 65 | 1 | True |
| 38 | `38_nameplate_hard` | Nameplate+ | mastery | `mirror_v_then_h` | hard | 5 | 110 | 3 | True |

---

## Appendix B — Clone scan (Hamming < 8)

| Dist | A | B |
|---|---|---|
| 0 | `04_ceiling_first` | `09_twin_rail` |
| 0 | `18_cement_trail` | `35_mirror_birth_hard` |
| 0 | `19_no_retread` | `27_conductors_cut` |
| 2 | `13_gallery_walk` | `25_panic_lattice` |
| 2 | `18_cement_trail` | `22_spin_trap` |
| 2 | `22_spin_trap` | `35_mirror_birth_hard` |
| 3 | `08_identity_induction` | `33_nameplate` |
| 3 | `23_ceiling_press` | `37_cement_trail_hard` |
| 4 | `06_far_side` | `22_spin_trap` |
| 5 | `16_false_twin` | `26_identity_pressure` |
| 6 | `06_far_side` | `18_cement_trail` / `35_mirror_birth_hard` |

---

*Audit generated 2026-08-09. Content-only; no chamber JSON mutated in this PR.*
