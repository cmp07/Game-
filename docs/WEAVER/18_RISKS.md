# The Weaver — Risks

**Working title:** The Weaver  
**Purpose:** Pre-mortem for design, production, market, and pivot hygiene.  
**Companions:** [`17_MVP.md`](17_MVP.md) · [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) · [`15_MARKET.md`](15_MARKET.md) · [`14_TECH.md`](14_TECH.md) (when present)

Severity: **H** = can kill the product · **M** = can stall a quarter · **L** = annoyance if ignored.

---

## 1. Design risks

| ID | Risk | Sev | Tell | Mitigation |
|---|---|---|---|---|
| D1 | **Verb mud** — Fragments / Threads / Structures sound poetic but play like three inventories | H | Players ask “what do I press?” at minute 5 | One Yard job teaches the chain; no parallel meta currencies |
| D2 | **Physics toy without puzzle** — sandbox collapse comedy, no reasons to care | H | Session ends after one funny snap | Authored jobs with acceptance tests; sandbox is dessert |
| D3 | **Besiege gravity** — part catalog and Workshop expectations balloon | H | Recipe count > job count | Cap recipes; jobs first ([`17_MVP.md`](17_MVP.md)) |
| D4 | **Economy creep** — player trade / soft MMO enters “just for legacy” | H | Design docs mention stalls before first Structure sings | Solo scarcity law [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md); trade pre-mortem [`07_ECONOMY.md`](07_ECONOMY.md); MVP forbids human trade |
| D5 | **Purple-void identity** — default AI-fantasy look (glow, chronomancy, rarity gems) | M | Capsule looks like every generative asset flip | Material bible: fiber, dust, timber, wire, chalk, rust |
| D6 | **Echo Lattice mash** — store page or trailer mixes maze-habit with loom-craft | M | Wishlist confusion; “is this the same game?” | Separate fantasy; EL frozen; no shared store copy |
| D7 | **Tutorial slides instead of literacy** | M | Tip stack in first eight minutes | Follow [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) pedagogy rules |
| D8 | **Spoiler-wiki gravity** — players (or UI) treat recipe lists as the skill surface | H | In-game encyclopedia / “look up the graph” as default path | Hint ecology + thin stamps only ([`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md)) |

---

## 2. Production risks

| ID | Risk | Sev | Tell | Mitigation |
|---|---|---|---|---|
| P1 | **Dual simulation** — 2D and 3D prototypes neither ship | H | Two half-toys at week 6 | Pick one sim fence in week 1 of prototype |
| P2 | **Doc wave without playable** — 01–19 land, no `game/weaver` spike | H | Design complete, feel unknown | Schedule a throwaway prototype gate before art ramp |
| P3 | **Scope from sibling docs** — World/Legacy/Multiplayer written as if in MVP | M | Engineers schedule netcode | MVP doc is authority for cuts; other docs label “post” |
| P4 | **EL maintenance distraction** — RC1 menu polish steals Weaver prototype time | M | Commits only under `echo_lattice` | Timebox EL; Weaver spike on its own branch/path |
| P5 | **Audio/art late** — greybox never gets material soul | M | Trailer cannot show tension | Block demo date on Thread tension readability |

---

## 3. Market & discovery risks

| ID | Risk | Sev | Tell | Mitigation |
|---|---|---|---|---|
| M1 | **Category mush** — tagged as cozy + puzzle + sandbox + multiplayer | H | Tags fight the trailer | Pure category: craft / physics puzzle toy |
| M2 | **Comp crush** — read as thin Besiege / Poly Bridge / Townscaper clone | M | Reviewers say “I’ve played this” | Hook = textile tension literacy + Yard jobs, not part count |
| M3 | **Price mismatch** — $19.99 ambition on MVP content mountain | M | Refunds, “short” reviews | Stay in $4.99–$9.99 until content proves otherwise |
| M4 | **Name collision** — “Weaver” crowded (tools, other games, fiction) | M | SEO / Steam search noise | See [`19_NAMES.md`](19_NAMES.md); lock legal check before Partner |
| M5 | **Coming Soon too early** | H | Wishlist rot while verbs unfinished | Freeze Partner until vertical slice passes MVP §8 |

---

## 4. Pivot / org risks

| ID | Risk | Sev | Tell | Mitigation |
|---|---|---|---|---|
| O1 | **Silent pivot** — Weaver docs exist, EL still marketed as north star | M | Contradictory READMEs | [`PIVOT.md`](PIVOT.md) + freeze doc cross-link |
| O2 | **Delete temptation** — “clean” repo by removing `game/echo_lattice/` | H | Lost playable + Steam pack | Hard rule: keep EL tree; freeze ≠ delete |
| O3 | **Agent wave without merge** — many `cursor/weaver-*` PRs never integrate | M | Fragmented truth | Synthesizer `MASTER_GDD` + integration branch |
| O4 | **Fantasy drift** — each doc invents a different Weaver | H | Fragments mean four things | Glossary lock in MASTER; MVP vocabulary wins ties |

---

## 5. Technical risks

| ID | Risk | Sev | Tell | Mitigation |
|---|---|---|---|---|
| T1 | **Unstable ropes** — verlet / joints explode, save scum only fix | H | Players disable physics mentally | Deterministic tuning sheet; max node counts; sleep islands |
| T2 | **Perf cliffs** — thread counts tank Deck/laptop | M | 30 FPS in Yard with 20 lines | Budget threads/structures; LOD for cloth/fiber |
| T3 | **Input precision gate** — mouse-only pin placement | M | Gamepad reviews tank | Snap points + gamepad draw from day one |
| T4 | **Mod/Workshop promise** | L | Discord asks before 1.0 | Say no until job quality proven |

---

## 6. Top five to watch (print weekly)

1. **D1 Verb mud** — if the chain isn’t obvious, nothing else matters.  
2. **D3 Besiege gravity** — catalog is a trap.  
3. **D8 Spoiler-wiki gravity** — recipe lists must not become the skill surface.  
4. **D4 Economy creep** — player trade is a different game.  
5. **P2 / M5 / O2** — schedule the spike; don’t Coming Soon early; don’t delete Echo Lattice.

---

## 7. Kill criteria (stop digging)

Stop the current Weaver prototype and replan if any hold after a honest slice:

- Cold players cannot complete one Structure job in 30 minutes after two tutorial iterations.
- Physics is unreadably noisy after a tuning week.
- The only “fun” is a feature that MVP forbids (trade, combat, LLM worldgen).
- Art direction collapses to purple-void generics and nobody will own a material bible.

---

## Doc status

**v0.1** — Risk register for Weaver MVP pack. Update severities when prototype telemetry exists; do not delete rows — mark **mitigated** with date instead.
