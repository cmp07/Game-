# The Weaver — Player-Shaped Generative

**Doc:** `docs/WEAVER/PLAYER_SHAPED.md`  
**Status:** Generative lock — world grows around *this* player (CLOUD ONLY)  
**Product line:** Weaver (north star; Echo Lattice frozen — see [`PIVOT.md`](PIVOT.md))  
**Branch:** `cursor/weaver-player-shaped-97b8`  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`06_WORLD.md`](06_WORLD.md) · [`08_LEGACY.md`](08_LEGACY.md) · [`14_TECH.md`](14_TECH.md) · [`24_STRUCTURE_ECOLOGY.md`](24_STRUCTURE_ECOLOGY.md) · [`28_LEGACY_V2.md`](28_LEGACY_V2.md) · [`MASTER_GDD.md`](MASTER_GDD.md) · [`1000X/05_WORLD.md`](1000X/05_WORLD.md)  
**Code hook:** `game/echo_lattice/scripts/weaver/loom/loom_state.gd` (player seed / void memory)

---

## 0. One sentence

**Player-shaped** generative means the void **remembers your stitches as local laws** and grows the next fray from a **seeded emergence grammar** — differently per save — with **no always-online LLM** required for MVP.

```
Act → leave a law → void remembers → seed mutates → next field emerges (offline)
```

**Player line:** *“This gap answers the way I weave — and it never asked the cloud.”*

---

## 1. Why this doc exists

Weaver already locks:

| Layer | Doc | Gap this fills |
|---|---|---|
| Residue / bias tag | [`08_LEGACY.md`](08_LEGACY.md) | Thin next-field pedagogy — not a growing void |
| Offline Structure evolution | [`28_LEGACY_V2.md`](28_LEGACY_V2.md) | Pedigree of stood graphs — not action→law grammar |
| Structure ecology | [`24_STRUCTURE_ECOLOGY.md`](24_STRUCTURE_ECOLOGY.md) | Classes answer each other *in-field* — not across players |
| Seeded yards | [`06_WORLD.md`](06_WORLD.md) · [`1000X/05_WORLD.md`](1000X/05_WORLD.md) | Same seed → same place — needs *player salt* so two weavers diverge |

Research taste (Residue / Echo Cartography / One-Law) said: **actions leave laws; the world reshapes around authorship; simulation-first, not rented inference.** This doc binds that taste to Weaver’s shed-yard product without reopening purple-void AI-dungeon marketing ([`30_STEAM_PITCH.md`](30_STEAM_PITCH.md), [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md)).

---

## 2. Hard fence — MVP generative stack

| Allowed (MVP) | Banned (MVP) |
|---|---|
| Local rule tables + weighted grammars | Runtime LLM / cloud chat inventing jobs, art, or copy |
| Deterministic **player seed** + field seed | Non-replayable “AI surprise” |
| Compact **void memory** in local save | Always-online world authority |
| Seeded emergence (pick among authored bricks) | Freeform gen that softlocks or invents illegal Threads |
| Optional later: **typed intent** parsed **locally** | Online intent API / metered “Ink” as core loop |

**Acceptance bar:** Full gather→combine→weave→emit + void growth with Steam disabled and network killed ([`MASTER_GDD.md`](MASTER_GDD.md) pillar 5 · [`14_TECH.md`](14_TECH.md)).

Steam Cloud sync of the local player-seed file (post-1.0) is **backup**, not generative intelligence.

---

## 3. Fantasy contract

| Layer | Promise |
|---|---|
| **Authorship** | What you do becomes *law* the void must obey — not a score, not a skin |
| **Memory** | The empty gap keeps a fingerprint of your hand across sessions |
| **Divergence** | Two players on the “same” Yard job grow different frays because their void memory differs |
| **Fair toy** | Same `(field_seed, player_seed, action_log prefix)` → same emergence |
| **Honesty** | “Generative” means local rules + seeds — never a chatbot wallpaper |

### What “actions leave laws” means

An **action** (recover, bind, tension, inhabit, abandon) may stamp a **law residue** — a tiny enum the void consults later:

| Law family (MVP shortlist) | Born from | Void answer (examples) |
|---|---|---|
| `brace_bias` | Brace Threads seated often | Longer gaps that expect lattice; or punish over-brace |
| `span_hunger` | Span-heavy gathers | More torn midspans; fewer free Anchors |
| `anchor_nest` | Anchor hoarding / early seats | Peg-dense shelves; tighter carry teaches |
| `inhabit_dwell` | Long inhabit before clear | Slower emit cadence; denser residue stamps |
| `abandon_scar` | Abandon / collapse | Weathered chalk; one soft “scar” brick in next fray |

Laws are **pedagogy + atmosphere**, never permanent damage buffs or softlock gates ([`08_LEGACY.md`](08_LEGACY.md) · [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md)).

---

## 4. Void memory (data)

Persist under Weaver loom save (hook: `user://weaver_player_seed.json` via Loom), separate from Echo Lattice chamber `save.json` so archive chambers stay untouched.

| Field | Type | Role |
|---|---|---|
| `version` | int | Schema |
| `base_seed` | int | Stable per profile (created once) |
| `player_seed` | int | `hash(base_seed, law_weights, action_count)` — emergence salt |
| `law_weights` | map[string→int] | Compact counters for law families |
| `recent_actions` | ring buffer ≤32 | Debug / ghost / determinism audit |
| `session_count` | int | Quiet aging signal for weathering |
| `updated_at` | unix | Ops only |

**Growth rule:** every remembered action bumps one or more law weights (clamped). `player_seed` recomputes. Emergence never reads raw timestamps for outcomes — only seed + weights + authored tables.

```
player_seed = mix64(base_seed, fingerprint(law_weights), action_count)
emergence_pick(bricks, salt) = bricks[ hash(player_seed, field_seed, salt) % bricks.size() ]
```

---

## 5. Seeded emergence (how the void grows)

MVP emergence is **selection among authored bricks**, not open-ended generation.

| Stage | Input | Output |
|---|---|---|
| **Field open** | `field_seed` + `player_seed` | Fragment spawn table bias, gap weather brick |
| **Structure emit** | `player_seed` + seat count | Emit kind from recipe list (weighted by laws) |
| **Next job bias** | Top law weight | Teach variant tag (aligns with [`08`](08_LEGACY.md) residue) |
| **Yard weathering (1.0+)** | `session_count` + pedigree | Gallery chalk density ([`28`](28_LEGACY_V2.md)) |

**Determinism test:** two headless runs with identical save + identical inputs produce identical emit sequences and law_weights.

**Divergence test:** same `field_seed`, different `player_seed` → visibly different fray bias within authored bounds.

---

## 6. Optional later — typed intent (local)

Post-MVP dessert, not a ship gate:

| Piece | Spec |
|---|---|
| **Input** | Short typed / stamped phrase from a **closed lexicon** (glyph tray, not free chat) |
| **Parse** | Local finite grammar → intent token (`want_span`, `need_brace`, `calm_gap`, …) |
| **Effect** | One-shot bias salt for the *next* emergence pick — still offline |
| **Ban** | Cloud LLM parse; open-vocabulary objects; intent that invents illegal recipes |

Mythographic summon fantasy (research Direction 7 affinity — lexeme → prefab) stays a **closed table**. If the lexicon cannot express it, it does not spawn.

---

## 7. Store & trailer honesty

| Say | Do not say |
|---|---|
| “The void remembers how you weave.” | “AI generates infinite unique worlds.” |
| “Same job seed — your laws diverge.” | “Powered by ChatGPT / cloud brain.” |
| “Offline craft that grows with your hand.” | “Always-online living server.” |

Anti-AI / anti-slop still holds ([`30_STEAM_PITCH.md`](30_STEAM_PITCH.md) · [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md)). Player-shaped ≠ generative-AI dungeon.

---

## 8. Implementation map (Lattice host)

| Piece | Location | MVP duty |
|---|---|---|
| Void memory + seed I/O | `scripts/weaver/loom/loom_state.gd` | Load/save `user://weaver_player_seed.json`; recompute seed |
| Remember hooks | combine / seat / emit | Stamp law residues; feed emergence RNG |
| Emit emergence | `emit_from_structure` | Pick emit kind from `player_seed`, not bare `randomize()` |
| Contracts | `tests/test_weaver_on_lattice.py` | Assert hook symbols + save path constant |
| Twin spike | `game/weaver/` | Optional mirror later — launch path is Lattice |

Do **not** fold player-seed into Echo Lattice `SaveManager` chamber save until a deliberate migrate — keeps archive chambers and Weaver void memory separable ([`BUILD_ON_LATTICE.md`](BUILD_ON_LATTICE.md)).

---

## 9. Ship tests

| # | Test |
|---|---|
| S1 | Airplane mode: remember → quit → relaunch → `player_seed` and `law_weights` intact |
| S2 | `selftest_loop(seed)` still deterministic; player memory isolated or reset under `--weaver-selftest` |
| S3 | Two profiles, same field seed, different law_weights → different emit / bias within brick table |
| S4 | No network calls in loom seed path |
| S5 | Store sentence survives mute trailer without “AI” claim |

---

## 10. Authority

- MVP cuts in [`17_MVP.md`](17_MVP.md) still win on scope. Player-shaped void memory is a **thin hook** at Lattice host; full law ecology schedules with W4 / post-slice ([`28_LEGACY_V2.md`](28_LEGACY_V2.md)).
- If this doc conflicts with offline-first or anti-LLM store fences, **those fences win**.
