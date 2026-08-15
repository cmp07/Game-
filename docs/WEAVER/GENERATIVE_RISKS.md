# The Weaver — Generative Risks

**Doc:** `docs/WEAVER/GENERATIVE_RISKS.md`  
**Status:** Generative failure pre-mortem + constraint lock (CLOUD ONLY) · **Branch:** `cursor/generative-risks-4f2e`  
**Product:** **The Weaver** (north star; Echo Lattice frozen — see [`PIVOT.md`](PIVOT.md))  
**Job:** Attack the three ways “generative Weaver” dies — **empty chatbot**, **AI slop purple void**, **no game** — and lock constraints so any generative *tooling* still ships a **playable, beautiful craft toy**.  
**Authority peers:** [`18_RISKS.md`](18_RISKS.md) · [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md) · [`MASTER_GDD.md`](MASTER_GDD.md) · [`09_VISUAL.md`](09_VISUAL.md) · [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) · [`14_TECH.md`](14_TECH.md) · [`17_MVP.md`](17_MVP.md) · [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) · [`1000X/10_ART.md`](1000X/10_ART.md)  
**Hard rules:** No AppID invention. Do not edit `game/echo_lattice/`. Docs-only. Runtime LLM remains **cut** for the shipped game ([`14_TECH.md`](14_TECH.md) · [`17_MVP.md`](17_MVP.md)).

---

## 0. Verdict (read this first)

“Generative” is not a genre for Weaver. It is a **production hazard**: agents, image models, offline grammars, and content pipelines that can replace hands-on craft with chat, glow, and empty stages.

| Death mode | What the player gets | Severity |
|---|---|---|
| **G1. Empty chatbot** | A talkative companion / tip narrator / “worldbuilder” where the verb is *prompt*, not stitch | **H** |
| **G2. AI slop purple void** | Cosmic violet plate, orb Fragments, bloom mystery — every Midjourney fantasy default | **H** |
| **G3. No game** | Docs, moodboards, and generated lore with no recoverable → bind → Tension → inhabit loop | **H** |

**Lock:** Generative methods may assist **offline** authorship (tables, drafts, layout proposals). They must never become the product, the look, or the win condition.

**One line:** Hands on fiber; materials on page; physics judges the stitch — chat and purple cosmos stay off the loom.

---

## 1. Scope — what “generative Weaver” is allowed to mean

| Allowed (offline / tooling) | Forbidden (product / runtime) |
|---|---|
| Agent-assisted **doc** drafts that humans merge against this corpus | In-game LLM tip narrator, companion, or quest giver |
| Offline generators that emit **checked JSON** under `content/weaver/` | Online generative dungeon / “AI builds your Yard” |
| Image-model **mood refs** discarded before ship; final art follows material bible | Shipping Midjourney/SD frames as capsules or in-game plates |
| Seeded table remix within authored families / jobs | Runtime model calls, API bills, or “world evolves for you” marketing |
| Grammar/expand tools that fail CI if they break determinism | Chat UI as the primary loop |

**Disclosure:** If any gen-AI touched production *assets*, disclose per [`14_TECH.md`](14_TECH.md). Runtime LLM stays cut regardless.

**Store sentence test:** Removing the words “AI,” “generative,” and “LLM” must leave a complete pitch ([`02_CORE_LOOP.md`](02_CORE_LOOP.md) purity · [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) anti-AI test).

---

## 2. Attack G1 — Empty chatbot

### 2.1 Indictment

Chat is the softest product shape for an agent stack. Weaver dies when:

| Soft entry | Chatbot shape |
|---|---|
| “Help the player discover recipes” ([`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md) risk) | LLM tip narrator naming illegal/legal stitches |
| Legacy / residue “memory” language ([`08_LEGACY.md`](08_LEGACY.md) · [`28_LEGACY_V2.md`](28_LEGACY_V2.md)) | Companion that remembers *for* you in prose |
| Yard Folio / diegetic stamps | Talking ledger that answers questions instead of showing scarcity |
| Pedagogy pressure after verb mud (D1) | Patch confusion with a chat overlay |
| “AI Weaver” marketing heat | Store lead becomes chatbot dungeon adjacent |

Empty chatbot is not “bad copy.” It is **progress without a hand verb** — cousin of adversarial idle (A) — where the hand presses Enter instead of Recover → Bind → Tension.

### 2.2 Constraints (mandatory)

| ID | Constraint | Ship test |
|---|---|---|
| **C1** | **No runtime chat surface.** No companion, no free-text prompt box, no “ask the loom” modal in MVP or 1.0. | Grep UI trees: zero chat/prompt widgets in `game/weaver` / Weaver-on-Lattice path |
| **C2** | **Literacy is diegetic, not narrated.** Illegal snaps, collapse culprits, chalk glyphs, and job scarcity teach — not paragraphs from a model. | Cold play: job 1–3 completable with tips muted |
| **C3** | **Offline tip copy is authored strings.** If tips exist, they are fixed localization keys; no token stream, no “rewrite this tip” at runtime. | Tips load from content tables; network disabled still identical |
| **C4** | **Agents write docs and JSON drafts — humans gate play.** Merged content must pass job accept predicates and determinism checks; agent prose alone is not a field. | CI / content lint rejects fields without scarcity + accept test |
| **C5** | **Ban “AI worldbuilder” / companion lead** on store, trailer VO, and capsule text. | Pitch review uses [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) anti-AI checklist |

### 2.3 Kill criteria (chatbot)

Park the generative experiment if:

- Players spend more session time reading or typing than drawing Threads.
- Design response to confusion is “add a smarter narrator” instead of fixing the gap silhouette / snap glyph.
- Wishlist copy leads with AI, chat, or generative world.

---

## 3. Attack G2 — AI slop purple void

### 3.1 Indictment

Image models and default “premium indie” prompts converge on the same dead plate Weaver already bans ([`09_VISUAL.md`](09_VISUAL.md) §1 · [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) · [`1000X/10_ART.md`](1000X/10_ART.md) §2):

| Generative default | Why it kills Weaver |
|---|---|
| Near-black cosmic clear + nebula | Gap reads as mood, not scarcity |
| Violet / magenta bloom, god-rays | Chronomancy shelf; Fragment Time cliché |
| Orb / crystal / circle Fragments | Node-editor cosplay; no craft silhouette |
| Soft painterly haze, glass HUD | Process marks vanish; OS chrome wins |
| “Mystical void loom” prompt language | Noun **void** drifts from torn plank to cosmos |

Purple void is risk **D5** and adversarial death **C** accelerated by generative asset pipelines. Beauty without material honesty is still slop.

### 3.2 Constraints (mandatory)

| ID | Constraint | Ship test |
|---|---|---|
| **C6** | **Material bible is non-negotiable.** Fiber, dust, timber, wire, chalk, kiln copper only; kiln accent ≤10% of frame. | Mute still: stranger says shed/page craft, not “magic ruins” |
| **C7** | **Hard ban list is CI-taste.** No cosmic purple hexes, pure `#000` clear, orb Fragments, neon Threads, glass HUD, chronoshard icons ([`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) §2). | Hero / capsule frames fail review if ban hues dominate |
| **C8** | **Void = physical gap only.** Torn edge + value step + occlusion (or equivalent triad) in every teach field and trailer still. | Gap anatomy checklist from Void Art V2 §3.2 |
| **C9** | **Gen-image outputs are refs, never ship plates.** Final menu, field, and capsule art must be authored to pillars P1–P7 ([`1000X/10_ART.md`](1000X/10_ART.md)). | Provenance note: no raw model frame in `media/` ship set |
| **C10** | **Prompt hygiene for agents.** Any art/agent brief must include the ban table + “shed lamp, bone page, family silhouettes” — never “ethereal purple void loom.” | Brief template checked in design review |
| **C11** | **Seat, don’t radiate.** Tension juice stays crease → lift → seat; no portal swallow, bloom stack, or confetti clear ([`35_JUICE.md`](35_JUICE.md) · [`09_VISUAL.md`](09_VISUAL.md) §5). | Capture reel: seat readable greyscale |

### 3.3 Kill criteria (purple void)

Park art / generative look work if:

- Capsule passes the brand test for a *different* cosmic fantasy game after removing the word Weaver.
- Greyscale mute still fails “plank across a torn shed floor.”
- Nobody will own the material bible (risk D5 kill criterion in [`18_RISKS.md`](18_RISKS.md)).

---

## 4. Attack G3 — No game

### 4.1 Indictment

Generative workflows love **corpus without play**: more markdown, more moodboards, more “systems,” zero recoverable Fragment in a running build.

| Soft entry | No-game shape |
|---|---|
| Doc waves without `game/weaver` / Lattice hybrid spike (P2) | Beautiful README, unplayable toy |
| Offline generators that emit lore, not jobs | Myth PDF, no accept predicates |
| Agent PRs that only rearrange vision copy | Fantasy drift (O4) without verb proof |
| Sandbox / gallery / residue without Inhabit clear (A3) | Shrine sim, not Yard craft |
| “Playable” defined as chat demo or slideshow | Prompt theater |

**No game** means the player cannot complete **Survey → Recover → Bind → Tension → Inhabit** on a deterministic field with a physical gap. Everything else is brochure.

### 4.2 Constraints (mandatory)

| ID | Constraint | Ship test |
|---|---|---|
| **C12** | **Playable before generative expansion.** No content-gen feature work until one Structure job clears cold in ≤30 minutes ([`17_MVP.md`](17_MVP.md) · [`18_RISKS.md`](18_RISKS.md) kill list). | Slice gate checked before generator PRs merge |
| **C13** | **Generators emit jobs, not novels.** Output = Fragment/Thread/Structure fields with scarcity tells + accept tests; lore is optional residue only. | Schema rejects fields missing gap + inhabit predicate |
| **C14** | **Determinism fence.** Same seed → same field; no model nondeterminism in the play path ([`14_TECH.md`](14_TECH.md) · [`1000X/13_TECH.md`](1000X/13_TECH.md)). | Replay / ghost compare on teach jobs |
| **C15** | **Hands budget.** Median session must keep hand verbs dominant; generative tooling must not insert wait-for-model beats. | No network/model wait in Recover→Inhabit path |
| **C16** | **One composition first viewport.** Generative shell proposals obey hero budget: brand, one line, one CTA, one shed visual — no chatbot dock, stat strip, or orb collage ([`09_VISUAL.md`](09_VISUAL.md) §4). | Title still brand-test |
| **C17** | **Docs cite a runnable path.** Any generative design PR names how to launch the loop (`BUILD_ON_LATTICE` / `game/weaver`) and what job proves the change. | PR template / review checklist |

### 4.3 Kill criteria (no game)

Stop digging if after two honest prototype passes:

- Cold players cannot clear one Structure job in 30 minutes.
- The only demo that “feels generative” has no Tension seat.
- Agent output volume (docs/assets) grows while playable job count stays flat.

---

## 5. Constraint constitution (print weekly)

| # | Rule |
|---|---|
| 1 | **Runtime LLM is cut** — offline authored content only. |
| 2 | **Chat is not a verb** — stitch is. |
| 3 | **Purple cosmos is never the gap** — torn material is. |
| 4 | **Beauty = process marks** — chalk, ink, timber grain, shed lamp. |
| 5 | **Generators serve jobs** — jobs do not serve generators. |
| 6 | **Deterministic loom** — seeds replay; models stay off the critical path. |
| 7 | **Disclose asset gen; never market AI dungeon.** |
| 8 | **Playable proof beats corpus mass.** |

---

## 6. Mapping to existing risk IDs

| Generative death | Existing anchors |
|---|---|
| G1 Empty chatbot | D1 verb mud · D8 idle · A1–A8 · tip-narrator bans in discovery/threads · LLM runtime cut |
| G2 AI slop purple void | D5 · D10 · adversarial C · [`09`](09_VISUAL.md) / [`25`](25_VOID_ART_V2.md) / [`1000X/10_ART`](1000X/10_ART.md) |
| G3 No game | P2 docs-without-playable · O3 agent wave · O4 fantasy drift · MVP exit / kill list |

This doc does **not** reopen player trade, combat, or dual-SKU. It fences generative *methods* so they cannot reopen those either.

---

## 7. Allowed generative workflow (if used at all)

```
authored brief (bans + pillars)
        ↓
agent / model draft (docs or JSON only)
        ↓
human + schema lint + determinism check
        ↓
playtest: Recover → Bind → Tension → Inhabit
        ↓
mute still + brand test (anti-purple)
        ↓
merge — or discard
```

**Never:** model → ship frame → store.  
**Never:** model → runtime narrator → “literacy.”  
**Never:** model → infinite fields with no job accept test.

---

## 8. Top to watch (print with [`18_RISKS.md`](18_RISKS.md) §6)

1. **Chat overlay as pedagogy patch** — fix the gap, not the narrator.  
2. **Capsule drift to violet void** — material bible ownership.  
3. **Doc/agent throughput without new clearable jobs** — P2 / G3.  
4. **“Just offline gen” that needs a network** — C14 / C15.  
5. **Store copy flirting with AI heat** — C5.

---

## Doc status

**v0.1** — Generative death modes G1–G3 + constraints C1–C17. Companion to [`18_RISKS.md`](18_RISKS.md) and [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md). Mark constraints **mitigated** with date when prototype telemetry or CI taste gates exist; do not delete rows.
