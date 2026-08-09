# The Weaver — 34 · Adversarial GDD Attack

**Doc:** `docs/WEAVER/34_ADVERSARIAL.md`  
**Status:** Design attack + fix lock (CLOUD ONLY) · **Branch:** `cursor/weaver-adversarial`  
**Product:** **The Weaver** (north star; Echo Lattice frozen — see [`PIVOT.md`](PIVOT.md))  
**Job:** Break the Master GDD before players do. Three death modes — **boring idle**, **combo spreadsheet**, **empty void** — with mandatory fixes.  
**Authority peers:** [`MASTER_GDD.md`](MASTER_GDD.md) · [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`17_MVP.md`](17_MVP.md) · [`18_RISKS.md`](18_RISKS.md) · [`09_VISUAL.md`](09_VISUAL.md)  
**Hard rules:** No AppID invention. Do not edit `game/echo_lattice/`. Docs-only wave.

---

## 0. Verdict (read this first)

The GDD already bans idle tags, purple cosmos, and Besiege encyclopedias — and still **dies three ways by soft gravity**:

| Death mode | How the current corpus invites it | Severity |
|---|---|---|
| **A. Boring idle** | Quiet Survey, residue “memory,” gallery pride, and job-board cadence can become wait / drip / shrine loops | **H** |
| **B. Combo spreadsheet** | 6 Fragment families × 4 Thread types × ≤20 recipes + “elegance” stars invite wiki matrices | **H** |
| **C. Empty void** | “Void-weave” language + frayed-gap antagonist can read as blank purple emptiness *or* contentless fields | **H** |

**Lock:** If a prototype or store frame fails any kill-test in §4, rewrite content — do not add systems to paper over the hole.

**One line:** Hands always busy; graphs stay authored and few; the gap is torn material, never cosmic nothing.

---

## 1. Attack A — Boring idle

### 1.1 Indictment

Category purity says “not idle” ([`MASTER_GDD.md`](MASTER_GDD.md) §4 · [`02_CORE_LOOP.md`](02_CORE_LOOP.md) §1). That is a **tag fence**, not a play feel. Idle creeps in when:

| Soft spot in GDD | Idle shape it becomes |
|---|---|
| Survey is “quiet — no timer panic” ([`02`](02_CORE_LOOP.md) §2) | Player stands in a field with nothing to press for 20s |
| Residue biases the next field ([`02`](02_CORE_LOOP.md) §6 · [`11`](11_PROGRESSION.md) §5) | Offline accrual / “come back for a better bias” prestige drip |
| Gallery wall as long-loop pride ([`06`](06_WORLD.md) · [`08`](08_LEGACY.md)) | AFK shrine; open hub, stare at stamps |
| Job board as world content ([`06`](06_WORLD.md) §2.3) | Daily appointment / login cadence dressed as contracts |
| Sandbox “dessert” ([`11`](11_PROGRESSION.md) §7) | Infinite noodle with no clear beat — Particul gravity |
| Tension commits scarce (1–2 / field) | Waiting for the “real” button while chalk feels optional |
| Stars on Thread economy ([`02`](02_CORE_LOOP.md) §5) | Overnight theorycrafting instead of another 4-minute retry |

Idle is not “numbers go up.” Idle is **progress without a hand verb**. Weaver dies the moment Survey / Residue / Gallery / Sandbox grant dopamine without Recover → Bind → Tension → Inhabit.

### 1.2 Fixes (mandatory)

| ID | Fix | Ship test |
|---|---|---|
| **A1** | **No offline accrual.** Residue, scrap, gallery, bias tags change **only** on field clear / abandon confirm — never on wall-clock, login, or Steam overlay return. | Leave the game open 30 minutes on Yard; zero state change |
| **A2** | **Survey ≤3s to a hand.** Entering a field must present a tangible scarcity tell (torn plank, starved trough, sealed peg) the player can point at before the first tip. Quiet ≠ empty. | Cold clip: finger lands on the gap inside 3s |
| **A3** | **Inhabit is the clear.** Build-alone / Tension-alone never completes a campaign job ([`11`](11_PROGRESSION.md) §10). | QA: Tension stand without walk/route fails the job |
| **A4** | **Residue is a stamp, not a drip.** One signature silhouette ± optional scrap; bias is a **next-field authored reaction**, not a stacking buff farm. | No UI shows “bias %” climbing across sessions |
| **A5** | **Gallery is a shelf, not a loop.** Opening gallery never advances jobs, currencies, or unlocks. Pride only. | Gallery interactors have no accept-predicate side effects |
| **A6** | **Job board ≠ appointment mode.** Campaign contracts are always available offline; no daily lock, energy, or “returns in 4h.” Post daily seeds stay dessert ([`11`](11_PROGRESSION.md) §5). | Campaign completable Steam-disabled with no clock |
| **A7** | **Sandbox after literacy, capped session ask.** Free-build offers a optional craft prompt (“span this gap”) or a clear Exit; it does not replace the Yard spine. | First-thirty never routes through sandbox |
| **A8** | **Chalk is the toy; Tension is the beat — both are hands.** Provisional draw must feel physical every second; scarcity of commits cannot make Bind feel like loading screen. | Bind→undo→Bind loop stays fun for 60s without Tension |

### 1.3 Kill criteria (idle)

Park the slice if after two pedagogy passes:

- Median session has **>30%** wall time with no Fragment / Thread / walk input.
- Players describe the game as “waiting for something to finish.”
- Anyone asks for prestige / offline earnings “to make residue matter.”

---

## 2. Attack B — Combo spreadsheet

### 2.1 Indictment

The systems pack sells sparse mastery — four Thread types, six Fragment families, ≤20 Structures ([`03`](03_FRAGMENTS.md)–[`05`](05_STRUCTURES.md) · [`17_MVP.md`](17_MVP.md)). Combinatorics still explode:

```
6 families × port sets × 4 Thread types × span/stress × ≤20 recipes
        → community matrix → “optimal kiln vent graph” wiki
        → play becomes filling cells, not stitching a gap
```

| Soft spot in GDD | Spreadsheet shape |
|---|---|
| Thread = `(type, from, to, span_cost, stress)` ([`04`](04_THREADS.md)) | DPS/armor sheet with craft nouns |
| Capacity as readable thickness ([`03`](03_FRAGMENTS.md)) | Hidden numeric table players extract |
| Stars on “Thread economy + elegance” ([`02`](02_CORE_LOOP.md) §5) | Min-max score attack, not authorship |
| Recipe stamps as progression ([`11`](11_PROGRESSION.md) §3) | Collectathon catalog before jobs teach verbs |
| Multi-channel Structures as mastery ([`05`](05_STRUCTURES.md) §3) | Early dual-channel puzzles force theorycraft |
| Soft planarity / crossing stress ([`04`](04_THREADS.md) §3) | Another column on the matrix |
| “Remix six × four instead of prefabs” ([`05`](05_STRUCTURES.md) §4) | Correct anti-Besiege move — still a chemistry sheet if jobs don’t constrain |

If players need a grid to choose the next stitch, **verb mud (D1)** has already lost to wiki gravity (cousin of **Besiege gravity D3**).

### 2.2 Fixes (mandatory)

| ID | Fix | Ship test |
|---|---|---|
| **B1** | **Jobs constrain chemistry.** Each authored job lists allowed Fragment families, Thread types in teach order, and **one** primary rewrite channel. Illegal extras snap or stay chalk-only. | Job JSON/spec has `families[]`, `threads[]`, `channel` — tools reject wild cards in teach set |
| **B2** | **One channel until F3.** Topology / flow / load / pulse / vent taught singly ([`05`](05_STRUCTURES.md) §3). No dual-channel accept predicates before composition field. | Teaching ladder audit |
| **B3** | **No numeric combat sheet in UI.** Capacity/stress read as thickness, rust creep, taut/slack fiber, audio — never HP bars, DPS, or floating ±integers on ports. | Screenshot QA: zero digit readouts on Fragments during Bind |
| **B4** | **Elegance = inhabit clarity, not cell count.** If stars exist: grade “could a stranger walk it,” leftover Thread budget as secondary — never a hidden weight matrix published to players. | Star rubric fits on one index card |
| **B5** | **Recipes trail jobs (D3 hard).** Recipe count ≤ job count at every milestone; vertical slice ≤8 recipes with 8–12 jobs ([`17_MVP.md`](17_MVP.md)). | Content spreadsheet check in ROADMAP reviews |
| **B6** | **Ban community-facing balance dumps in-game.** No codex page of port×type tables in MVP. Literacy comes from illegal snap glyphs + collapse culprit. | Codex ships materials + silhouettes only |
| **B7** | **Optimal line is a joke, not a requirement.** At least two distinct standing graphs clear each non-teach job; par is soft. | Design review: second solution sketched before lock |
| **B8** | **Prototype fence: four families × two Threads first.** W1 spike uses Span/Anchor + Brace/Feed only ([`ROADMAP.md`](ROADMAP.md) W1). Add Oppose/Echo/Filter/Charge only after clip tests pass. | Spike exit clip without full matrix |

### 2.3 Kill criteria (spreadsheet)

Park content expansion if:

- Cold players open notes/wiki before drawing a Thread on job 3+.
- Design meetings spend more time on compatibility matrices than on gap silhouettes.
- Stars correlate only with Thread count minimization, not with inhabit readability.

---

## 3. Attack C — Empty void

### 3.1 Indictment

Two voids kill the product:

1. **Cosmic void** — purple-black emptiness, nebula plate, mystic drone (already banned in [`09`](09_VISUAL.md) · [`10`](10_AUDIO.md) · MASTER hard bans).  
2. **Content void** — a “frayed gap” that is just blank play space; Shed Yard as empty menu; fields with scarcity named but not staged.

The corpus worsens (2) by leaning on **“void-weave”** as thesis language ([`09_VISUAL.md`](09_VISUAL.md) §0 · [`10_AUDIO.md`](10_AUDIO.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) §0). Internally “void = physical gap” is defined; externally the word **Void** still reads as chronomancy shelf ([`19_NAMES.md`](19_NAMES.md) avoid list). Empty stage + void noun = trailer that looks like every generative fantasy flip **or** like nothing at all.

| Soft spot | Empty-void shape |
|---|---|
| Allowed void = frayed gap ([`MASTER_GDD.md`](MASTER_GDD.md) glossary) | Greybox air with no torn edge, dust, or missing plank |
| Hub “menu made of place” ([`06`](06_WORLD.md)) | Empty shed shell; brand fails brand test |
| Field = solvable scarcity | Scarcity described in doc, not built into spawn layout |
| Sandbox / free-build | Infinite empty cloth with no antagonist gap |
| Anti-purple still + soft painterly haze ban | Team ships flat bone fill with no material grain — sterile, not workshop |

### 3.2 Fixes (mandatory)

| ID | Fix | Ship test |
|---|---|---|
| **C1** | **Rename pressure for store & UI.** Prefer **fray / gap / seam / span** in player-facing copy. “Void” allowed only as designer shorthand for the physical gap — never in trailer VO, Steam tags, or Fragment names. | Grep ship strings: no `Void`/`void-weave` in store-facing packs |
| **C2** | **Gap must be material.** Every field’s antagonist is staged with at least two tells: torn substrate edge + one of (missing plank, dust fall column, starved trough, sealed peg, rust bite). | Mute still: stranger names the problem without UI |
| **C3** | **Density budget (anti-empty).** Playable field frame targets ~60% substrate / ~25% craft objects / ~10% Threads / ≤5% kiln accent ([`09`](09_VISUAL.md) §2). **Forbidden:** >70% unbroken empty fill in the focus rectangle during Survey. | Art review checklist |
| **C4** | **Hub brand test.** Shed Yard first viewport: brand + one job CTA + dominant workshop plane (fiber, dust, timber, lamp). No floating void plate behind UI. | Remove nav labels — still reads Weaver, not generic dark UI |
| **C5** | **Audio anti-drone.** Title / Survey bed = shed air, distant kiln, hush — not mystic pad ([`10`](10_AUDIO.md)). Silence is craft, not cosmos. | Blind listen: “workshop,” not “space temple” |
| **C6** | **Sandbox inherits a gap.** Free-build lite always spawns one authored fray to stitch; never a blank infinite grid as default. | Sandbox boot screenshot shows a tear |
| **C7** | **Collapse comedy fills the frame.** On failure, culprit Thread/Fragment highlight + seam tear occupy attention — collapse must not dump the player into a cleared empty stage. | Collapse clip readable at 0.5× speed mute |

### 3.3 Kill criteria (empty void)

Replan art/fantasy if:

- Capsule or trailer still reads as purple-void after removing logo.
- Playtesters ask “what am I looking at?” on Survey more than once per teach job.
- Designers keep writing “the void” when they mean “the broken bridge.”

---

## 4. Combined kill-tests (print on the wall)

Run before demo date and before any Coming Soon ask:

| # | Test | Pass |
|---|---|---|
| K1 | **Hands test** | 90s mute clip is full of recover / bind / tension / walk — not waiting |
| K2 | **Matrix test** | New designer explains job 2’s legal stitches without a spreadsheet |
| K3 | **Gap test** | Cropped Survey still shows torn material, not blank plate or nebula |
| K4 | **Shrine test** | Gallery + residue docs can be deleted from a vertical-slice build and the loop still teaches |
| K5 | **Purity test** | Removing words *idle / void / combo / meta* does not empty the pitch |
| K6 | **Inhabit test** | Clear requires living in the Structure ([`11`](11_PROGRESSION.md) §10.3) |

Fail any → fix content and copy; do not add trade, dailies, or catalog rows.

---

## 5. Patch list into the corpus (follow-through)

This PR lands the attack. Sibling docs should absorb the locks below on follow-up (do not block spike on full rewrite):

| Target | Absorb |
|---|---|
| [`MASTER_GDD.md`](MASTER_GDD.md) | Add death modes A–C to weekly risks; glossary: player-facing ban on “Void” as product noun |
| [`02_CORE_LOOP.md`](02_CORE_LOOP.md) | Survey ≤3s hand tell; explicit no-offline-accrual |
| [`09_VISUAL.md`](09_VISUAL.md) / [`11_PROGRESSION.md`](11_PROGRESSION.md) | Retire “void-weave” thesis phrasing → **fray-weave / seam craft** |
| [`06_WORLD.md`](06_WORLD.md) | Density + material gap requirements on field specs |
| [`17_MVP.md`](17_MVP.md) / [`ROADMAP.md`](ROADMAP.md) | Spike = 4×2 chemistry; stars rubric = inhabit clarity |
| [`18_RISKS.md`](18_RISKS.md) | New rows D8 idle creep · D9 spreadsheet gravity · D10 empty void (content) — mark related mitigations when prototype proves them |
| [`15_MARKET.md`](15_MARKET.md) | Store sentence uses gap/seam/span — never Void |

---

## 6. Relationship to existing risks

| This attack | Existing risk | Delta |
|---|---|---|
| Boring idle | D2 physics toy without puzzle · D7 tip slides · M1 category mush | Adds **time-without-verbs** and appointment gravity |
| Combo spreadsheet | D1 verb mud · D3 Besiege gravity | Adds **wiki matrix** even inside the MVP cap |
| Empty void | D5 purple-void identity · art kill criterion | Adds **contentless gap** and **void noun** store risk |

Adversarial QA for Echo Lattice ([`../AUDIT/ADVERSARIAL_QA.md`](../AUDIT/ADVERSARIAL_QA.md)) is session integrity for a frozen SKU. **This doc is design integrity for Weaver** — different product, same attitude: assume the soft reading wins unless fenced.

---

## 7. Acceptance (docs wave)

1. This file names all three death modes with indictment → fixes → kill criteria.  
2. Index / MASTER / ROADMAP point here.  
3. No `game/echo_lattice/` edits; no AppIDs; no Coming Soon claims.  
4. Prototype spike (W1) treats A2, A3, B8, C2 as non-negotiable exit checks.

---

## 8. Lock line

**Attack the soft readings until they cannot ship:** no progress without hands, no chemistry without a job fence, no gap without torn material — and never call the wound a cosmic Void.
