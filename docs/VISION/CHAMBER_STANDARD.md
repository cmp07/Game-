# Echo Lattice — Chamber Authorship Standard

**Status:** vision authority (does not mutate shipping JSON)  
**Branch:** `cursor/vision-chambers`  
**Audience:** content authors, balance, demo/marketing  
**Live inventory source:** `game/echo_lattice/content/chambers/*.json` + `acts.json`  
**Related:** [`04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) (format contract), [`CONTENT_CHAMBERS.md`](../AUDIT/CONTENT_CHAMBERS.md) (RC1 audit)

This doc defines the **gold-standard beat model** for every chamber, inventories the current book, and ranks what to **rebuild**, **cut**, or **elevate**. Schema roles (`lesson` / `remix` / `boss` / `hard` / `daily_showcase`) stay as machine tags; authorship beats below are the design language for human review.

---

## 1. Gold standard — Teach / Test / Twist / Boss

Every shipping chamber earns exactly one primary beat. Secondary flavors are allowed; dual primary beats are not.

| Beat | Player promise | Geometry rules | Copy rules | Pass bar |
|---|---|---|---|---|
| **Teach** | “I just learned one new verb.” | Generous floor; one forced op; one `C` (or literacy `C` with `cap: 0`); dead-ends rare and scenic, not punitive | Caption states the rule in plain English; one hint that names the fossil | Cold player clears on first or second try without UI lecture |
| **Test** | “Prove you own that verb.” | Same op, denser or longer; fair traps that punish the *wrong* habit of that op | Caption assumes literacy; hint optional, never spoils the intended stroke | Failures feel like player error, not map malice; softlock net almost never fires on intended path |
| **Twist** | “The rule still holds — the room lied.” | Subverts a Teach/Test expectation (false symmetry, multi-commit tax, composition claim, bait corridor) while keeping one readable idea | Caption may tease; must not name a transform the room does not run | The “aha” is visual after the slam, not a glossary surprise |
| **Boss** | “Leave a signature the lattice can read.” | Identity-shaped solve path; distinct footprint from every other boss; multi-`C` only if each commit authors a portrait stroke | No “Boss.” prefix mold; voice asks for a mark, not a lecture | Intended human solve leaves a legible echo portrait; Hamming distance ≥ 12 from other bosses |

### Beat → schema role mapping

| Authorship beat | Typical `role` | Notes |
|---|---|---|
| Teach | `lesson` | First introduction of a transform **in this Act** |
| Test | `remix` | Default remix — fair exam, no subversion claim |
| Twist | `remix` (tag `twist`) | Prefer adding `tags: ["twist"]` when the room’s job is subversion |
| Boss | `boss` | One per Act; `teaches: identity` + `identity` tag |
| (sidecar) | `hard` | Tight parent Teach/Test; not a fifth beat — a difficulty skin |
| (sidecar) | `daily_showcase` | Epilogue / friend-seed poster; treat as elevated Test |

Hard variants and Daily showcase are **not** primary beats. They inherit Teach/Test/Twist/Boss intent from their parent and tighten floor, par, or commit count.

### Act cadence (target)

| Act | Ideal spine | Chamber budget |
|---|---|---|
| **I Induction** | Teach ladder → one Twist → Boss | 8–9 (demo wing; protect Mirror Birth) |
| **II Reflection** | Re-Teach known ops under dual-axis → Looking Glass Teach → Twist → Boss | 7–9 |
| **III Pressure** | Thicken Teach → Tests that make habits hurt → one multi-commit Twist → Boss | 7–9 |
| **IV Mastery** | Short re-Teach baton → true composition Twist(s) → Boss → showcase | 6–8 + showcase |

**Fatigue rule:** if an Act has more than **three** same-transform Tests with no Twist between them, cut or rebuild one.

### Non-negotiables (author checklist)

1. One rewrite idea per chamber (composition Twists are the only exception, and only in Mastery).
2. Base map: `P` reaches every `C` and `G`; Hamming distance to any other chamber ≥ 8 (exact clone = ship block).
3. `rewrite.cap >=` checkpoint count; caption never advertises more commits than cap.
4. Caption ≤ ~55 chars; no act-name leaks (“under pressure”, “thicken mastery”).
5. Title names the *room fantasy*, not a future unlock (`invert` reserved until the op ships).
6. Boss footprints unique; hard variants honestly tighter than parent (floor and/or commits and/or par).
7. Hints required on Teach + Boss; encouraged on Twist; optional on Test.

---

## 2. Inventory (all 39 chambers)

Snapshot of HEAD on `cursor/echo-lattice-rc1` (post clone-fix). **Vision beat** is the authorship assignment this standard wants; it may disagree with current `role`.

### Act I — Induction (demo wing)

| Id | Title | Op | Role | Diff | C | Vision beat | Disposition |
|---|---|---|---|---|---|---|---|
| `00_quiet_span` | Quiet Span | `none` | lesson | 0 | 0 | Teach | **Elevate** — silence opener; trim scenic void or tag it |
| `01_echo_plate` | Echo Plate | `none` | lesson | 0 | 1 | Teach | **Elevate** — literacy plate before first slam |
| `02_mirror_birth` | Mirror Birth | `mirror_v` | lesson | 1 | 1 | Teach | **Elevate** — product hook; protect geometry + caption |
| `03_break_the_loop` | Break the Loop | `mirror_v` | remix | 1 | 1 | Twist | **Elevate** — first “walk cleaner” lesson; seal dead pockets |
| `04_ceiling_first` | Ceiling First | `mirror_h` | lesson | 1 | 1 | Teach | **Elevate** — keep as horizontal Teach |
| `05_two_glances` | Two Glances | `mirror_v` | remix | 2 | 2 | Twist | **Elevate** — multi-commit Twist; keep cap honest |
| `06_far_side` | Far Side | `rotate_180` | lesson | 2 | 1 | Teach | **Rebuild** — leave rail-stack family (`06`/`18`/`22`) |
| `07_first_thicken` | First Thicken | `thicken` | lesson | 2 | 1 | Teach | **Elevate** — keep as thicken Teach |
| `08_identity_induction` | Who Walked | `mirror_v` | boss | 3 | 2 | Boss | **Elevate** — Act I boss; diverge from Nameplate |
| `35_mirror_birth_hard` | Mirror Birth+ | `mirror_v` | hard | 3 | 1 | (hard of Teach) | **Elevate** — now true child of `02`; polish caption |

### Act II — Reflection

| Id | Title | Op | Role | Diff | C | Vision beat | Disposition |
|---|---|---|---|---|---|---|---|
| `09_twin_rail` | Twin Rail | `mirror_v` | lesson | 2 | 1 | Teach | **Elevate** — rebuilt spine lesson; keep distinct |
| `10_roof_writing` | Roof Writing | `mirror_h` | remix | 2 | 1 | Teach | **Rebuild tags** — first Act II `mirror_h` → Teach/`lesson` + hint |
| `11_opposite_room` | Opposite Room | `rotate_180` | remix | 2 | 1 | Teach | **Rebuild tags** — first Act II rotation → Teach/`lesson` + hint |
| `12_looking_glass` | Looking Glass | `mirror_v_then_h` | lesson | 3 | 2 | Teach | **Elevate** — dual-axis pillar lesson |
| `13_gallery_walk` | Gallery Walk | `mirror_v` | remix | 3 | 1 | Test | **Rebuild** — near-clone of Panic Lattice |
| `14_horizon_fold` | Horizon Fold | `mirror_h` | remix | 3 | 2 | Test | **Elevate** — solid dual horizontal Test |
| `15_spin_gallery` | Spin Gallery | `rotate_180` | remix | 3 | 2 | Test | **Elevate** — keep; add hint |
| `16_false_twin` | False Twin | `mirror_v` | remix | 3 | 1 | Twist | **Elevate** — best Act II Twist fantasy |
| `17_identity_reflection` | Portrait | `mirror_v_then_h` | boss | 4 | 2 | Boss | **Elevate** — face promise; prove portrait in Museum shot |
| `36_looking_glass_hard` | Looking Glass+ | `mirror_v_then_h` | hard | 4 | 2 | (hard) | **Rebuild** — thinner corridors claim; verify vs parent |

### Act III — Pressure

| Id | Title | Op | Role | Diff | C | Vision beat | Disposition |
|---|---|---|---|---|---|---|---|
| `18_cement_trail` | Cement Trail | `thicken` | lesson | 3 | 1 | Teach | **Elevate** — thicken under load; leave rail family |
| `19_no_retread` | No Retread | `thicken` | remix | 3 | 1 | Test | **Elevate** — fair thicken Test |
| `20_squeeze_mirror` | Squeeze Mirror | `mirror_v` | remix | 3 | 1 | Test | **Cut candidate** — filler mirror; merge job into `21` or rebuild as true Twist |
| `21_stacked_echo` | Stacked Echo | `mirror_v` | remix | 4 | 3 | Twist | **Elevate** — multi-commit net; flagship Pressure Twist |
| `22_spin_trap` | Spin Trap | `rotate_180` | remix | 4 | 1 | Test | **Rebuild** — Hamming-near cement/far-side rails |
| `23_ceiling_press` | Ceiling Press | `mirror_h` | remix | 4 | 1 | Test | **Elevate** — keep low-room fantasy; add hint |
| `24_compound_fracture` | Compound Fracture | `mirror_v_then_h` | remix | 4 | 2 | Twist | **Elevate** — dual-axis under pressure |
| `25_panic_lattice` | Panic Lattice | `thicken` | remix | 4 | 1 | Test | **Rebuild** — diverge from Gallery Walk pillars |
| `26_identity_pressure` | Calcify | `thicken` | boss | 5 | 2 | Boss | **Elevate** — habits-as-walls identity |
| `37_cement_trail_hard` | Cement Trail+ | `thicken` | hard | 4 | 1 | (hard) | **Rebuild** — too close to Ceiling Press; tighten vs `18` |

### Act IV — Mastery

| Id | Title | Op | Role | Diff | C | Vision beat | Disposition |
|---|---|---|---|---|---|---|---|
| `27_conductors_cut` | Conductor's Cut | `mirror_v` | lesson | 4 | 1 | Teach | **Elevate** — rebuilt Mastery baton; keep |
| `28_invert_ballet` | Invert Ballet | `rotate_180` | remix | 4 | 2 | Test | **Cut name / rebuild** — rename until `invert` ships |
| `29_two_axes` | Two Axes | `mirror_v_then_h` | remix | 4 | 2 | Teach | **Rebuild tags** — Act IV dual-axis re-Teach; mark `lesson` |
| `30_habit_orchestra` | Habit Orchestra | `mirror_v` | remix | 5 | 3 | Twist | **Rebuild** — claims composition; still single forced op |
| `31_last_buffer` | Last Buffer | `thicken` | remix | 5 | 1 | Test | **Cut candidate** — thin Mastery thicken; merge into Calcify echo or cut |
| `32_signature_stack` | Signature Stack | `mirror_v_then_h` | remix | 5 | 2 | Twist | **Rebuild** — same composition lie as `30` |
| `33_nameplate` | Nameplate | `mirror_v_then_h` | boss | 5 | 3 | Boss | **Rebuild** — near Who Walked footprint; final portrait must be unique |
| `34_open_lattice` | Open Lattice | `mirror_v` | daily_showcase | 4 | 2 | Test (showcase) | **Elevate** — friend-seed poster; wire Daily special-case |
| `38_nameplate_hard` | Nameplate+ | `mirror_v_then_h` | hard | 5 | 3 | (hard) | **Rebuild** — same floor as parent; dishonest “less room” |

### Counts

| Bucket | Count |
|---|---|
| Authored chambers | **39** (35 campaign + 4 hard) |
| Current roles | lesson 10 · remix 20 · boss 4 · hard 4 · daily_showcase 1 |
| Vision beats (campaign 00–34) | Teach 14 · Test 11 · Twist 7 · Boss 4 · showcase 1 |
| Disposition (all 39) | Elevate 22 · Rebuild 12 · Cut/rename 5 |

Near-clone debt still open (Hamming < 8): `13≈25`, `08≈33`, `18≈22`, `06≈22`, `23≈37`, `16≈26`, rail family `06`/`18`/`22`. Exact clones from the content audit are already fixed.

---

## 3. Rebuild vs cut vs elevate

### Elevate (keep; polish copy/hints/presentation)

Protect and showcase these. Do not redesign unless a bug forces it.

| Priority | Chamber | Why |
|---|---|---|
| E1 | `02_mirror_birth` | Demo conversion beat; caption + slam are the brand |
| E2 | `00` / `01` | Silent literacy before the hook |
| E3 | `12_looking_glass` | Dual-axis Teach — Act II’s Mirror Birth |
| E4 | `16_false_twin` | Clean Twist fantasy (“symmetry lies”) |
| E5 | `21_stacked_echo` | Multi-commit Pressure Twist |
| E6 | `08` / `17` / `26` | Three bosses with distinct fantasies (after Nameplate diverges) |
| E7 | `34_open_lattice` | Daily/friend poster chamber |
| E8 | `03`, `05`, `07`, `09`, `14`, `15`, `18`, `19`, `24`, `27`, `35` | Solid Teach/Test/Twist stock once hints/captions land |

### Rebuild (same slot, new geometry or honest systems)

| Priority | Chamber | Rebuild brief |
|---|---|---|
| R1 | `33_nameplate` | Unique Mastery portrait; Hamming ≥ 12 from `08`; three commits that *stack* a readable nameplate |
| R2 | `13_gallery_walk` + `25_panic_lattice` | Break pillar-hall twin; Gallery = Reflection Test, Panic = thicken panic Test |
| R3 | `06_far_side` / `22_spin_trap` (+ rail kinship with `18`) | Distinct rotation Teach vs Pressure rotation Test; leave thicken rails to Cement Trail |
| R4 | `30_habit_orchestra` | Either true multi-phrase authorship (sequenced strokes that feel composed) or drop `teaches: composition` |
| R5 | `32_signature_stack` | Same — stack two *different* portrait strokes, or retitle as dual-axis Test |
| R6 | `38_nameplate_hard` | Actually less floor / tighter commits than `33`; caption must match |
| R7 | `36_looking_glass_hard` / `37_cement_trail_hard` | Honest parent deltas; `37` must not echo Ceiling Press |
| R8 | Role retags | `10`,`11` → Teach; Pressure first-of-op (`20`/`22`/`23`/`24`) and Mastery (`28`/`29`/`31`) → Teach or honest Test |

### Cut or rename (free a slot / fix glossary)

Prefer **cut** when the Act already has three same-op Tests. Prefer **rename** when the fantasy is good but the name lies.

| Priority | Chamber | Action | Rationale |
|---|---|---|---|
| C1 | `28_invert_ballet` | **Rename** (e.g. Far Mark / Counterspin) | Runs `rotate_180`; burns `invert` unlock name |
| C2 | `20_squeeze_mirror` | **Cut or merge** into `21` | Pressure mirror filler; Stacked Echo already owns the beat |
| C3 | `31_last_buffer` | **Cut or merge** into `26` echo / Daily | Mastery thicken Test without a new idea; act-name voice leak |
| C4 | Scenic voids in `00`/`03` | **Trim cells or tag** `scenic_void` | Not full cuts — stop reading as unfinished maps |
| C5 | Future `invert` lesson | **Do not ship** under a fake name | Hold for post-1.0 / systems-ready wing |

**Target shipped shape after cuts:** ~32–34 campaign chambers + 4–6 honest hards, still four Acts, denser Mastery, less remix fatigue.

---

## 4. Ranked rebuild list

Work top-down. Each item is one PR-sized content pass unless noted. Validation after every geometry edit:

```bash
python3 game/echo_lattice/tests/validate_chambers.py
python3 game/echo_lattice/tests/validate_locale.py
python3 game/echo_lattice/tests/test_demo_spec.py
```

| Rank | Pri | Action | Target | Outcome |
|---|---|---|---|---|
| 1 | **P0** | Rebuild Boss footprint | `33_nameplate` (+ then `38`) | Final identity ≠ Who Walked; hard child honest |
| 2 | **P0** | Break near-clone pair | `13` ≠ `25` | Reflection hall vs Pressure panic read as different Acts |
| 3 | **P0** | Leave rail-stack family | `06`, `22` (keep `18` as thicken rail authority) | Rotation Teach/Test stop rhyming with Cement Trail |
| 4 | **P1** | Rename glossary hazard | `28_invert_ballet` → rotation-true slug/title + locale | `invert` reserved |
| 5 | **P1** | Cut/merge filler | Drop or fold `20_squeeze_mirror`, `31_last_buffer` | Shorter Pressure/Mastery; fatigue rule satisfied |
| 6 | **P1** | Composition honesty | Rebuild `30` / `32` **or** strip composition claims | Mastery fantasy matches forced_op reality |
| 7 | **P1** | Hard honesty pass | `36`, `37`, `38` (+ verify `35`) | Every hard = tighter parent; captions true |
| 8 | **P1** | Teach/Test retags + hints | `10`,`11`, Pressure/Mastery first-ops; hint pack | Bible + vision beat alignment |
| 9 | **P1** | Caption voice pass | All Boss/Hard prefixes; act-name leaks; motif banners on multi-`C` | Trust + pedagogy |
| 10 | **P2** | Elevate demo spine presentation | `00`–`02`, `08` Museum/tour shots | Marketing matches gold Teach→Boss |
| 11 | **P2** | Elevate showcase wiring | `34_open_lattice` Daily/friend special-case | Liveops poster chamber |
| 12 | **P2** | Variation gates | Daily-eligible Tests/Twists | Replay without new maps |
| 13 | **P3** | True composition setpiece | New or rebuilt Mastery Twist with authored multi-op fantasy | Only when systems allow |
| 14 | **P3** | Real `invert` Teach + Test | New ids, never rename-back of ballet | Post-1.0 fence |

### Suggested engineering order

```
P0 Nameplate + near-clones + rail family
  → P1 rename Invert Ballet + cut fillers
    → P1 composition honesty + hard honesty
      → P1 tags/hints/captions
        → P2 elevate demo/showcase/variations
          → P3 composition systems / invert wing
```

---

## 5. Reference chambers (study these)

| Beat | Gold example | Why it passes |
|---|---|---|
| Teach | `02_mirror_birth` | One op, one `C`, caption = rule, slam readable, demo-safe |
| Teach (literacy) | `01_echo_plate` | Arms buffer without fossils |
| Twist | `16_false_twin` | Promise in the title; subverts symmetry without new ops |
| Twist (multi-commit) | `05_two_glances` / `21_stacked_echo` | Cap matches checkpoints; each rewrite changes the plan |
| Boss | `17_identity_reflection` (aspiration) | Dual-axis + “face” fantasy — elevate with Museum proof |
| Hard | `35_mirror_birth_hard` (post-fix) | True child of Mirror Birth with less floor |

Anti-patterns to retire: exact/near map clones, “Boss.”/“Hard.” caption mold, titles that name unshipped ops, `teaches: composition` on single `forced_op`, hard variants with equal floor to parent.

---

## 6. Doc contract

| Layer | Authority |
|---|---|
| File format, schema, loader | `04_CONTENT_BIBLE.md` + `chamber.schema.json` |
| RC1 defect inventory | `docs/AUDIT/CONTENT_CHAMBERS.md` |
| **Authorship beat quality + rebuild priority** | **This file** |

When bible role tags and this vision disagree, **fix the tags/maps to match Teach/Test/Twist/Boss** — do not weaken the beat model to match fatigued remix volume.

---

*Vision draft 2026-08-09. Documentation only; chamber JSON not mutated in this PR.*
