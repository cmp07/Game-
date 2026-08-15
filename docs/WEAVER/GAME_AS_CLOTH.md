# The Weaver — Game as Cloth (Metaphor Lock)

**Doc:** `docs/WEAVER/GAME_AS_CLOTH.md`  
**Status:** Metaphor lock — CLOUD ONLY  
**Branch:** `cursor/weaver-game-as-cloth-020c`  
**Product:** **The Weaver** (north star; Echo Lattice frozen — see [`PIVOT.md`](PIVOT.md))  
**Job:** Lock the fantasy that the player is **weaving the game / universe into being** — not building a shed, base, or prefab workshop. Features unlock as **structures of play**: new verbs appear *because you wove them*.  
**Peers:** [`01_CONCEPT.md`](01_CONCEPT.md) · [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) · [`23_WEAVE_VERB.md`](23_WEAVE_VERB.md) · [`MASTER_GDD.md`](MASTER_GDD.md) · [`1000X/00_MASTER_VISION.md`](1000X/00_MASTER_VISION.md)

**Code stub:** `game/weaver/scripts/loom/game_as_cloth.gd` — a woven play-structure unlocks a new verb.

---

## 0. Decision (read this first)

| Lock | Meaning |
|---|---|
| **You weave the game** | Standing a Structure is not “place shed furniture.” It is **authoring a panel of the universe** — local law the player must inhabit. |
| **Shed Yard is set dressing** | Timber, dust, and lamp light are the *material voice* of the loom ([`09_VISUAL.md`](09_VISUAL.md)). They are **not** the product fantasy of base-building or cozy shed sim. |
| **Features = structures of play** | Progression unlocks are **woven Structures** that add **verbs** to the grammar — never XP bars, skill trees, or shop menus that grant abilities. |
| **New verb because you wove it** | Until the play-structure seats, the verb does not exist in the player’s hands. After seat + inhabit, the verb is part of the cloth. |
| **No prefab unlock theater** | Forbidden: “Unlock Combine in the tech tree,” “Buy Echo Verb,” neon ability toasts. Allowed: seat a Loom-mark / play-structure → verb appears as craft literacy. |

**One line:** The player is not building a shed — they are weaving the game into being; features arrive as structures of play, and new verbs appear because you wove them.

**Player line:** *“I didn’t unlock Echo — I wove it into the yard.”*

---

## 1. Why this lock (failure modes it kills)

| Wrong fantasy | Why it breaks Weaver |
|---|---|
| **Shed / base builder** | Reads as housing / decoration meta; Structures become scenery props instead of local law |
| **Skill-tree ability drip** | Verbs become RPG powers; literacy becomes XP theater ([`11_PROGRESSION.md`](11_PROGRESSION.md)) |
| **Cosmic purple “weave reality”** | Banned AI-slop lane — cloth is material (fiber, timber, chalk), not nebula magic ([`25_VOID_ART_V2.md`](25_VOID_ART_V2.md)) |
| **Idle unlock timers** | Progress without a hand verb is forbidden ([`1000X/01_CORE_LOOP.md`](1000X/01_CORE_LOOP.md)) |
| **Menu grants the verb** | Authorship dies — mute trailer can no longer show *parts → relations → place → new hand* |

The Shed Yard hub remains ([`06_WORLD.md`](06_WORLD.md)). This lock only bans treating the **product** as shed construction. Visual craft may still look like a worked yard; the *verb* is universe authorship through cloth.

---

## 2. Metaphor stack

```
Universe / game grammar  =  the cloth being woven
Field / Yard job         =  a frayed panel waiting for law
Fragment                 =  yarn / atom of matter
Thread                   =  stitch (typed relation)
Structure (work)         =  seated panel that rewrites place (bridge, gate, kiln…)
Structure (play)         =  seated panel that rewrites the *game* — unlocks a verb
Inhabit                  =  live inside the law you authored (required for unlock to stick)
Residue                  =  memory of the panel in the next field’s grammar
```

| Kind | Rewrites | Example |
|---|---|---|
| **Work Structure** | Field topology / flow / load / pulse / vent | Span across East Post Gap |
| **Play Structure** | Player verb set / literacy grammar | Loom-mark that seats **Echo** into the hands |

Work Structures solve jobs. Play Structures expand **what the toy can say**. Both are woven the same way (Recover → Bind → Tension → Inhabit). Only the rewrite channel differs: place vs play-grammar.

---

## 3. Structures of play (feature unlock contract)

A **structure of play** is a Structure whose primary product is a **new player verb** (or a named literacy stamp that *is* a verb).

| Rule | Spec |
|---|---|
| **Same seat grammar** | Play-structures use Fragment → Thread → Tension. No separate “ability forge” UI. |
| **Inhabit seals the unlock** | Build-alone does not grant the verb. Feet / use must complete the teach predicate ([`05_STRUCTURES.md`](05_STRUCTURES.md)). |
| **Verb appears in hands** | After seal, the verb is available as input / bind type / field action — named in craft nouns, not ability icons. |
| **Deterministic** | Same seed + same seated play-structure → same verb unlock. No gacha. |
| **Sparse** | MVP: few play-structures; each unlocks **one** verb. Do not batch-unlock skill trees. |
| **Readable in mute** | Trailer beat: seat → inhabit → *new hand motion appears* — stranger understands without HUD essay. |

### 3.1 MVP stub verb (code)

| Field | Value |
|---|---|
| **Play-structure id** | `echo_loom` |
| **Label** | Echo Loom (play-structure) |
| **Unlocks verb** | `echo` — typed Thread / bind literacy for Echo ([`04_THREADS.md`](04_THREADS.md)) |
| **Gate** | Seat `echo_loom` (stub: seat marks unlock; inhabit seal is follow-on) |
| **Stub path** | `game/weaver/scripts/loom/game_as_cloth.gd` |

Prototype may start with only Brace in content fences ([`32_FIRST_FIVE.md`](32_FIRST_FIVE.md)). The stub **names the contract** so later content can attach Echo without inventing a skill tree.

### 3.2 Example unlock ladder (design — not all shipped)

| Play-structure (craft name) | Verb unlocked | Player feels |
|---|---|---|
| Echo Loom | **Echo** (bind / Thread type) | “The stitch can answer itself.” |
| Oppose Vent | **Vent / Oppose** | “I can dump charge safely.” |
| Pulse Ledger | **Pulse** (timed gate literacy) | “I walk the beat I authored.” |
| Survey Peg | **Survey tell** (soft read) | “The yard shows me the fray.” |

Names stay workshop nouns. Never “Ability: Echo II.”

---

## 4. Language bans & preferred voice

| Banned phrasing | Prefer |
|---|---|
| Build / upgrade the shed | Weave the field / seat the panel |
| Unlock ability / skill point | Weave a structure of play / seat the verb into the cloth |
| Base building / housing | Yard craft / local law |
| Tech tree / skill tree | Content graph of jobs + play-structures ([`11_PROGRESSION.md`](11_PROGRESSION.md)) |
| Level up / XP | Literacy stamp / workshop stamp |
| Cosmic weave / reality hack | Material cloth — fiber, timber, chalk, kiln copper |

Store and trailer copy may keep “shed-yard craft” as **material mood**. They must not promise “build your shed.”

---

## 5. Authority & conflict resolution

| Conflict | Verdict |
|---|---|
| Visual docs call the hub a Shed Yard | **Keep** — place name. Metaphor lock still forbids shed-*builder* fantasy. |
| Progression says “literacy unlocks” | **Aligned** — literacy unlocks **are** play-structures / job stamps, not XP. |
| FIRST_FIVE only has Brace | **Keep fence** — stub unlocks `echo` as future verb; do not expand fragment fence in this PR. |
| Idle emit from standing Structure | Emit is post-inhabit dessert ([`02_CORE_LOOP.md`](02_CORE_LOOP.md)); it does **not** unlock verbs. Only play-structure seat (+ inhabit) does. |

When copy or systems drift toward base-building or ability menus, **this doc wins** on metaphor. MVP cut lists still win on *what ships when*.

---

## 6. Ship tests

| Test | Pass |
|---|---|
| **Brand / fantasy** | After removing HUD, first useful Structure still reads as *authoring the world*, not placing shed decor |
| **Verb causality** | A reviewer can point to the Structure that caused a new verb — no menu middleman |
| **Mute trailer** | Seat → inhabit → new hand verb, without ability toast |
| **Code stub** | `GameAsCloth` reports `echo` locked until `echo_loom` seats; then `has_verb("echo")` is true |
| **Category purity** | No combat skill tree, no housing grid, no purple cosmos unlock VFX |

---

## 7. Agent / PR policy

| Do | Do not |
|---|---|
| Cite this doc when adding feature unlocks | Add skill trees, ability shops, or shed furniture meta |
| Unlock verbs via woven play-structures | Grant verbs from XP, quest checklists, or idle timers |
| Keep Shed Yard as material hub language | Equate product fantasy with “build a shed” |
| Grow stub in `game/weaver/` | Overwrite Echo Lattice or invent AppIDs |

---

## 8. One-screen summary

```
NOT:  player builds a shed / unlocks abilities from a menu
YES:  player weaves the game-universe cloth
YES:  features = structures of play
YES:  new verbs appear because you wove them
```
