# The Weaver — Name Lock

**Doc:** `docs/WEAVER/31_NAME_LOCK.md`  
**Status:** Cloud-only ship-name recommendation (not Partner-final)  
**Source shortlist:** [`19_NAMES.md`](19_NAMES.md)  
**Companions:** [`MASTER_GDD.md`](MASTER_GDD.md) · [`17_MVP.md`](17_MVP.md) · [`18_RISKS.md`](18_RISKS.md) · [`PIVOT.md`](PIVOT.md)  
**Mode:** Docs only. No AppID invention. No Echo Lattice code edits. Do **not** rename `game/echo_lattice/`.

---

## 0. Decision (read this first)

| Field | Lock |
|---|---|
| **Internal working title** | **The Weaver** (docs / branches / fantasy voice) |
| **Recommended ship / store name** | **Threadfall** |
| **Runner-up** | **Tension Yard** |
| **Authority** | This doc ranks Tier A from [`19_NAMES.md`](19_NAMES.md); human Steam search + trademark still required before Partner |
| **Echo Lattice** | Frozen; no shared store title, no “Echo / Lattice / Weaver” mash |

**One line:** Ship as **Threadfall**; keep **The Weaver** as the internal craft identity until Partner checks clear.

---

## 1. Scoring rubric (from naming pillars)

Candidates scored against [`19_NAMES.md`](19_NAMES.md) §1 + MASTER fantasy:

| # | Pillar | Weight |
|---|---|---|
| 1 | Craft / tension / textile-adjacent (not cozy knitting default) | High |
| 2 | Authorship — Structures that work | High |
| 3 | Capsule-readable: short, sayable, searchable | High |
| 4 | Not Echo Lattice brand bleed | Hard fail if broken |
| 5 | Not purple chronomancy / AI-slop stacks | Hard fail if broken |
| 6 | Fits Shed Yard MVP (physics judges stitches) | Medium |

Legal / Steam collision checks remain **human-required** (see §5). This lock is a design recommendation, not a trademark opinion.

---

## 2. Top 5 (from Tier A)

Ordered for ship readiness. All five are Tier A in [`19_NAMES.md`](19_NAMES.md) §3.

| Rank | Name | Why it ranks | Residual risk |
|---|---|---|---|
| **1** | **Threadfall** | One word; verb-clear thread-physics signal; capsule-legible; already seeded in inventive research; authorship without “Weaver” SEO crowd | May be claimed — confirm Steam / TM |
| **2** | **Tension Yard** | Place + verb; mirrors Shed Yard hub; teaches the toy’s judge (tension) in the title | Slightly industrial; softness of brand |
| **3** | **Loadbearing** | Physics joke + craft seriousness; Structures-as-pride in one compound | Length; hyphenation debates (`Load-Bearing`?) |
| **4** | **Pin & Span** | Literal MVP verbs (pin thread, span gap); literacy on the box | Ampersand / toolbox vibe |
| **5** | **Slackline** | Instant tension literacy; failure language (slack) is first-class in MVP | Outdoor sports brand collisions |

### Why these five beat the rest of Tier A

| Name | Held back because |
|---|---|
| Shed Yard | Too hub-literal; reads small / location-only |
| Fibercraft | Pulls cozy-sim expectations against physics-puzzle shelf |
| Guyline | Sharp but obscure for many locales |
| Splice | Tech / film title collisions |
| Keyline | Design-tool SEO noise |

Tier B stays parked per [`19_NAMES.md`](19_NAMES.md) §4 unless all Top 5 collide.

---

## 3. Ship recommendation — **Threadfall**

### 3.1 Why Threadfall wins

1. **Capsule test** — single word, high contrast at small size; no ampersand or compound debate.  
2. **Verb literacy** — “thread” + kinetic suffix sells Fragments → Threads → Structures without a subtitle.  
3. **Category purity** — craft / tension toy, not maze-habit (EL), not chronomancy, not cozy knit-sim.  
4. **Crowd escape** — retires crowded English **Weaver** from the store chrome while docs keep the craft identity.  
5. **Trailer fit** — mute still of a snap / seat can caption as Threadfall without lore dump.

### 3.2 Store sentence (draft)

> Offline craft puzzles: pin threads, tension Structures, clear Yard jobs — physics is the judge.

### 3.3 Subtitle policy

Prefer **no subtitle** if Partner search is clean.  
Allowed fallback (one only): *Threadfall — Tension Puzzles*  
Do **not** stack (“craft sandbox physics adventure”).

### 3.4 Do not ship as

Per [`19_NAMES.md`](19_NAMES.md) §2 avoid list, plus:

- Weaver AI / Weaver GPT / Echo Weaver / Lattice Weaver  
- Threadfall Echo / Thread Lattice / Habit Thread  
- Void / Nexus / Chrono / Temporal * anything

---

## 4. Fallback ladder

If human collision research kills the recommend, climb in order — do not reshuffle without a new PR:

1. **Threadfall** ← current ship recommend  
2. **Tension Yard**  
3. **Loadbearing**  
4. **Pin & Span**  
5. **Slackline**  
6. Tier B shortlist in [`19_NAMES.md`](19_NAMES.md) §4

Internal docs and branches may keep **The Weaver** through step 5; only store / capsule / `project.godot` name must follow the ladder when Partner work starts.

---

## 5. Decision gate (still open)

Copy of [`19_NAMES.md`](19_NAMES.md) §7 — all must pass before Partner paste:

1. Steam search: not drowning in unrelated hits.  
2. Trademark quick look in primary locale.  
3. Domain / social handle plausible (or accept intentional absence).  
4. Capsule test: title readable at small size.  
5. Team can say it out loud without explaining Echo Lattice.

| Check | Owner | Status |
|---|---|---|
| Design shortlist → Top 5 + recommend | This PR | **Done** |
| Steam search / TM / handles | Human | **Open** |
| Rename `game/weaver/` + store pack | Post-slice | **Blocked** on gate |

Until human checks clear, **The Weaver** remains the internal working title.

---

## 6. Rename checklist (when Partner-final)

From [`19_NAMES.md`](19_NAMES.md) §8 — tick only after §5 is green:

- [ ] `docs/WEAVER/` headers / MASTER_GDD title line → Threadfall (or fallback)  
- [ ] Future `game/weaver/` project name & `project.godot`  
- [ ] Steam depot / capsule filenames (Weaver pack only — never mutate EL freeze)  
- [ ] Pivot + README north-star sentence if store name ≠ working title  
- [ ] Do **not** rename `game/echo_lattice/` as part of this

---

## 7. Doc status

**v0.1** — Top 5 locked from Tier A; **Threadfall** recommended to ship. Update this file with collision research dates when a human runs Partner checks; bump fallback if Threadfall dies.
