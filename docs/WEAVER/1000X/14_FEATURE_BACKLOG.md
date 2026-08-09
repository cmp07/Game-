# The Weaver — 1000× Feature Backlog

**Doc:** `docs/WEAVER/1000X/14_FEATURE_BACKLOG.md`  
**Status:** Cloud-only design backlog · **Branch:** `cursor/weaver-1000x-backlog`  
**Product:** **The Weaver** (shipping north star) — Echo Lattice frozen & kept ([`../PIVOT.md`](../PIVOT.md) · [`../PRODUCT_IDENTITY.md`](../PRODUCT_IDENTITY.md))  
**Job:** **100+ concrete features** prioritized **P0–P3**, each with a pass/fail **acceptance test** — execution fuel after Master GDD v2, not a second fantasy.  
**Authority peers:** [`../MASTER_GDD.md`](../MASTER_GDD.md) · [`../17_MVP.md`](../17_MVP.md) · [`../ROADMAP.md`](../ROADMAP.md) · [`../34_ADVERSARIAL.md`](../34_ADVERSARIAL.md) · [`../35_JUICE.md`](../35_JUICE.md) · [`../BUILD_ON_LATTICE.md`](../BUILD_ON_LATTICE.md)  
**Hard rules:** No AppID invention. Do not delete `game/echo_lattice/`. No player trade. No realtime MP at MVP. No purple chronomancy. Coming Soon blocked until slice exit criteria.

---

## 0. Thesis gate

Every feature below must serve:

```
Survey → Recover → Bind → Tension → Inhabit → Residue
```

| Keep | Reject |
|---|---|
| Fragments as **material atoms with ports** | Time shards, rarity gems, gacha orbs |
| Threads as **typed relations** (Brace / Feed / Oppose / Echo) | DPS wires, mana links, skill trees |
| Structures as **seated graphs that rewrite place** | Besiege encyclopedia before jobs exist |
| Collapse as **fair comedy teacher** | Softlock shame, red-toast spreadsheet fails |
| Legacy as **local gallery / chalk ghosts** | Trade stalls, invade PvP, login drip |
| Juice as **workshop punctuation** | Purple bloom, loot beams, confetti portals |

**One line:** Hands stitch parts into place; physics judges; the yard remembers — alone, offline, without cosmic neon.

---

## 1. Priority model

| Priority | Meaning | ROADMAP home | Staff when |
|---|---|---|---|
| **P0** | Spike / vertical-slice blockers — feel-proof the verb | W1 → W2 gates G1–G4 | Now |
| **P1** | MVP 1.0 / first-thirty spine — content + literacy mountain | W2 → W4 · G3/G5/G7 | After P0 verb proof |
| **P2** | Demo polish + post-slice deepen — wishlistable, adversarial green | W3 · G6/G8 | After slice metrics |
| **P3** | Post-1.0 fence / stretch — still pure Weaver | W5+ / human reopen | After G7; never reopen bans |

**Ordering inside a priority:** Core loop & fair toy → discovery/anti-wiki → identity (art/audio/juice) → content caps → store surfaces → fences.

**Counts in this doc:** **P0** 30 · **P1** 50 · **P2** 32 · **P3** 20 · **Total 132**.

---

## 2. Master index (compact)

| ID | P | Category | Feature |
|---|---|---|---|
| **W001** | P0 | Core loop | Survey gap tell ≤3s |
| **W002** | P0 | Fragments | Recover Fragment with palm weight |
| **W003** | P0 | Threads | Bind Brace Thread between ports |
| **W004** | P0 | Threads | Tension commit with readable collapse |
| **W005** | P0 | Core loop | Undo Tension (re-pin) |
| **W006** | P0 | Structures | Inhabit clears the job |
| **W007** | P0 | Structures | First Structure seat ceremony |
| **W008** | P0 | Core loop | Six-beat loop on one field |
| **W009** | P0 | Fragments | Anchor + Span + Brace spike set |
| **W010** | P0 | Juice | Fragment suck juice |
| **W011** | P0 | Juice | Combine flash juice |
| **W012** | P0 | Juice | Weave pulse juice |
| **W013** | P0 | Tech | Sim fence lock (2D XOR constrained 3D) |
| **W014** | P0 | Tech | Deterministic seed grammar |
| **W015** | P0 | Tech | Softlock smoke suite |
| **W016** | P0 | Tech | Local save / offline bar |
| **W017** | P0 | Discovery | Collapse culprit highlight |
| **W018** | P0 | Discovery | Port glyph language (Brace notch) |
| **W019** | P0 | Discovery | Diegetic craft nouns only |
| **W020** | P0 | Audio | Workshop hush bed (first 90s) |
| **W021** | P0 | Audio | Slack→taut earprint |
| **W022** | P0 | Audio | Snap / seat audio pair |
| **W023** | P0 | Visual | Anti-purple palette lock |
| **W024** | P0 | Visual | Physical void, not cosmos |
| **W025** | P0 | Input | WASD + mouse loom controls |
| **W026** | P0 | Input | Controller snap targets (spike) |
| **W027** | P0 | A11y | Reduce-motion juice path |
| **W028** | P0 | Discovery | One coach line per beat |
| **W029** | P0 | Tech | Lattice host gather→combine→weave path |
| **W030** | P0 | Quality | Adversarial K1–K3 smoke (idle/spreadsheet/void) |
| **W031** | P1 | World | Shed Yard hub boot |
| **W032** | P1 | World | First-thirty spine jobs (8–12) |
| **W033** | P1 | Fragments | Fragment family: Channel |
| **W034** | P1 | Fragments | Fragment family: Charge |
| **W035** | P1 | Fragments | Fragment family: Filter |
| **W036** | P1 | Threads | Thread type: Feed |
| **W037** | P1 | Threads | Thread type: Oppose |
| **W038** | P1 | Threads | Thread type: Echo |
| **W039** | P1 | Structures | Structure recipe catalog ≤8 (slice) |
| **W040** | P1 | Structures | Structure class: Span bridge |
| **W041** | P1 | Structures | Structure class: Brace frame |
| **W042** | P1 | Structures | Structure class: Channel / sail / shelter (pick 3 more) |
| **W043** | P1 | Discovery | Jobs constrain chemistry |
| **W044** | P1 | Discovery | One channel until composition field |
| **W045** | P1 | Discovery | No numeric combat sheet in Bind UI |
| **W046** | P1 | Economy | Tiny carry spindle inventory |
| **W047** | P1 | Economy | Thread budget as scarcity |
| **W048** | P1 | Legacy | Residue stamp + next-field bias |
| **W049** | P1 | Legacy | Local gallery wall (thin MVP) |
| **W050** | P1 | Legacy | Ghost self replay (chalk) |
| **W051** | P1 | Progression | Elegance stars (optional, not speed tax) |
| **W052** | P1 | Progression | Literacy unlock order |
| **W053** | P1 | World | Job board always-available campaign |
| **W054** | P1 | World | World-answer residue beat |
| **W055** | P1 | World | Single next-session CTA |
| **W056** | P1 | Audio | Fragment leitmotifs (6 families) |
| **W057** | P1 | Audio | Thread type earprints |
| **W058** | P1 | Audio | Structure seat phrase |
| **W059** | P1 | Visual | Material bible pass (fiber/dust/timber/wire/chalk/kiln) |
| **W060** | P1 | Visual | Tension seat signature still |
| **W061** | P1 | Input | Controller parity for slice |
| **W062** | P1 | Input | Remappable controls |
| **W063** | P1 | A11y | Colorblind-safe stress reads |
| **W064** | P1 | A11y | Caption / subtitle toggle |
| **W065** | P1 | Tech | Performance 60 FPS Yard target |
| **W066** | P1 | Tech | Content caps enforcement tools |
| **W067** | P1 | Fragments | MVP Fragment count ramp (≤12) |
| **W068** | P1 | Structures | MVP Structure recipes ≤20 |
| **W069** | P1 | World | MVP jobs 40–60 |
| **W070** | P1 | World | Sandbox after literacy (capped ask) |
| **W071** | P1 | Economy | Scrap residue (optional, non-trade) |
| **W072** | P1 | Core loop | Abandon field fair refund |
| **W073** | P1 | Threads | Cut Thread verb |
| **W074** | P1 | Threads | Re-pin after cut |
| **W075** | P1 | Discovery | Feed port glyph + mouth silhouette |
| **W076** | P1 | Discovery | Oppose vent glyph |
| **W077** | P1 | Discovery | Echo tick glyph |
| **W078** | P1 | Discovery | Field scarcity family readable at Survey |
| **W079** | P1 | Juice | Collapse comedy three languages |
| **W080** | P1 | Structures | Structure ecology answers |
| **W081** | P2 | Store | Demo build = slice + CTA |
| **W082** | P2 | Store | Mute-legible 15s trailer cut |
| **W083** | P2 | Store | GIF pack (collapse + elegant solve) |
| **W084** | P2 | Store | Steam pitch page draft lock |
| **W085** | P2 | Store | Name legal check gate |
| **W086** | P2 | Quality | Adversarial K4–K6 green |
| **W087** | P2 | World | Second Yard corner (optional 1.0) |
| **W088** | P2 | Fragments | Pulse/Pendulum craft beat tool |
| **W089** | P2 | Structures | Multi-channel composition field |
| **W090** | P2 | Threads | Planarity / crossing stress tell |
| **W091** | P2 | Progression | Elegance rubric on index card |
| **W092** | P2 | Legacy | Gallery stamp share via screenshot/seed |
| **W093** | P2 | Legacy | Daily shared seed (dessert) |
| **W094** | P2 | Legacy | Friend seed handoff string |
| **W095** | P2 | Legacy | Legacy evolution (post-slice) |
| **W096** | P2 | Audio | Workshop ambiences per Yard corner |
| **W097** | P2 | Audio | Adaptive tension music (post-seat only) |
| **W098** | P2 | Visual | Kiln copper stress creep VFX |
| **W099** | P2 | Visual | Chalk provisional Thread rendering |
| **W100** | P2 | Juice | Structure dust settle motion |
| **W101** | P2 | Juice | Fair collapse share prompt (optional) |
| **W102** | P2 | Discovery | Discovery without spoiler wiki |
| **W103** | P2 | Discovery | Illegal bind snap catalog (craft tells) |
| **W104** | P2 | World | Job replay from board |
| **W105** | P2 | Audio | Settings: audio buses + mute groups |
| **W106** | P2 | Tech | Linux build nice-to-have smoke |
| **W107** | P2 | Input | Deck input parity checklist |
| **W108** | P2 | Store | Photo mode / still export (workshop) |
| **W109** | P2 | Tech | Localization string table (EN first) |
| **W110** | P2 | Tech | Content authoring pipeline docs |
| **W111** | P2 | Tech | Telemetry fence (opt-in, privacy) |
| **W112** | P2 | Economy | Pause does not advance residue |
| **W113** | P3 | Multiplayer | Co-op build fence (design only until reopen) |
| **W114** | P3 | Multiplayer | Async ghost Structures from friends |
| **W115** | P3 | Legacy | Share-code Structure cards |
| **W116** | P3 | World | Second biome pack (one lane) |
| **W117** | P3 | Tech | Workshop / mods (after job quality) |
| **W118** | P3 | Store | Material pack DLC fence |
| **W119** | P3 | Progression | Advanced elegance trials |
| **W120** | P3 | Legacy | Structure aging / patina layers |
| **W121** | P3 | World | Yard weather as craft climate |
| **W122** | P3 | Legacy | Photo plate museum night |
| **W123** | P3 | World | Contraption remix seeds (official) |
| **W124** | P3 | Fragments | Advanced Filter alchemy (authored) |
| **W125** | P3 | Threads | Echo harmony puzzles |
| **W126** | P3 | Juice | Contrasting elegance vs comedy catalog |
| **W127** | P3 | A11y | Accessibility: sticky ports / aim friction |
| **W128** | P3 | A11y | Narration / audio description pack |
| **W129** | P3 | Progression | Speedrun / challenge seed room (optional) |
| **W130** | P3 | Store | Credits loom colophon |
| **W131** | P3 | Tech | Migrate EL execute (human-gated) |
| **W132** | P3 | Tech | Console / Deck verified ship |

---

## 3. Features with acceptance tests

## 3.1 P0 — Spike & vertical-slice blockers

### W001 · Survey gap tell ≤3s
**Priority:** P0 · **Category:** Core loop  
**Spec:** On field enter, camera and silhouette announce a physical scarcity (torn span, starved trough, sealed peg) the player can point at before any tip.  
**Acceptance:** Cold clip: tester finger lands on the gap within 3s; no purple skybox; Survey quiet ≠ empty.

### W002 · Recover Fragment with palm weight
**Priority:** P0 · **Category:** Fragments  
**Spec:** Recover is pick-with-weight: silhouette settle + fiber suck into hand shelf; tiny carry 3–5 slots.  
**Acceptance:** Blind A/B: ≥80% sort two families by settle alone; zero magnet-loot beams or rarity sparkles.

### W003 · Bind Brace Thread between ports
**Priority:** P0 · **Category:** Threads  
**Spec:** Draw one Brace Thread between legal ports on Anchor+Span; illegal snap is craft tell, not error toast.  
**Acceptance:** Player completes one legal Brace bind and one illegal snap without reading a tooltip paragraph.

### W004 · Tension commit with readable collapse
**Priority:** P0 · **Category:** Threads  
**Spec:** Tension seats or collapses; culprit joint glyph + audible tear; Fragments refund with rustle.  
**Acceptance:** Cold player recovers from three distinct collapse causes without opening help.

### W005 · Undo Tension (re-pin)
**Priority:** P0 · **Category:** Core loop  
**Spec:** One-commit undo framed as re-pinning fiber — cheap, diegetic, no checkpoint shame.  
**Acceptance:** ≥50% of teach-field players undo once before first clear; abandon never shames.

### W006 · Inhabit clears the job
**Priority:** P0 · **Category:** Structures  
**Spec:** Standing alone never auto-wins; player must walk/route/use the Structure to clear.  
**Acceptance:** QA: Tension stand without inhabit fails the job; mute GIF shows inhabit path.

### W007 · First Structure seat ceremony
**Priority:** P0 · **Category:** Structures  
**Spec:** Quiet timber/ink seat with dust/joints; no confetti, portal swallow, or full-screen wash.  
**Acceptance:** Mute still: stranger says 'parts became a bridge/span'; brand test passes with title removed.

### W008 · Six-beat loop on one field
**Priority:** P0 · **Category:** Core loop  
**Spec:** Survey→Recover→Bind→Tension→Inhabit→Residue playable on one authored field timed to first-five.  
**Acceptance:** Cold clear Structure ≤3:40 and job ≤4:30 per 32_FIRST_FIVE; no hub meta required.

### W009 · Anchor + Span + Brace spike set
**Priority:** P0 · **Category:** Fragments  
**Spec:** Ship exactly Anchor, Span Fragments and Brace Thread for W1 feel-proof — no catalog browse.  
**Acceptance:** Spike content JSON lists only those nouns; player names them without coach after one clear.

### W010 · Fragment suck juice
**Priority:** P0 · **Category:** Juice  
**Spec:** Implement fragment_suck: ≤6 chalk wisps, silhouette ease-in ~320ms (80ms reduce-motion).  
**Acceptance:** Mute crop: Recover reads as fiber into hand; API emits fragment_suck_finished; purple bloom = fail.

### W011 · Combine flash juice
**Priority:** P0 · **Category:** Juice  
**Spec:** Local chalk-bright paper press + crease cross ~140ms at bind point.  
**Acceptance:** Flash stays local (not full viewport); combine_flash_finished fires; cadmium/purple absent.

### W012 · Weave pulse juice
**Priority:** P0 · **Category:** Juice  
**Spec:** Kiln-copper crest rides Thread polyline ~480ms ×2 cycles; width/alpha = cord load.  
**Acceptance:** Pulse is on Thread body only — no neon ring; weave_pulse_finished → seat.

### W013 · Sim fence lock (2D XOR constrained 3D)
**Priority:** P0 · **Category:** Tech  
**Spec:** Pick one sim stack before art ramp; kill dual-stack experiments in docs + code comments.  
**Acceptance:** ROADMAP G1 green: single sim README lock; no second physics path in game/weaver/.

### W014 · Deterministic seed grammar
**Priority:** P0 · **Category:** Tech  
**Spec:** Same seed → same field scarcity, Fragment spawns, and Tension outcomes.  
**Acceptance:** Python/GDScript contract: two runs same seed bit-identical accept/collapse results.

### W015 · Softlock smoke suite
**Priority:** P0 · **Category:** Tech  
**Spec:** Expand prototype tests: cannot trap player with zero legal binds and no undo/refund path.  
**Acceptance:** CI smoke fails if Recover inventory full + all ports illegal with no return-to-bin.

### W016 · Local save / offline bar
**Priority:** P0 · **Category:** Tech  
**Spec:** Full spike loop with Steam disabled; save/load session on Yard/field.  
**Acceptance:** Steam-disabled run clears first-five; save reload restores Fragments + provisional Threads.

### W017 · Collapse culprit highlight
**Priority:** P0 · **Category:** Discovery  
**Spec:** On collapse, one glyph flash names the failing joint/port pair.  
**Acceptance:** Player can point to culprit after collapse without tip modal; three collapse types distinguishable.

### W018 · Port glyph language (Brace notch)
**Priority:** P0 · **Category:** Discovery  
**Spec:** Brace legality shown as body glyph on ports; tooltip optional long-press only.  
**Acceptance:** Brace literacy job clearable without reading paragraph tooltip.

### W019 · Diegetic craft nouns only
**Priority:** P0 · **Category:** Discovery  
**Spec:** UI speaks Brace/Feed/Oppose/Echo/Seat/Slack — never DPS, mana, rarity, chrono.  
**Acceptance:** String audit: zero banned chronomancy/loot terms in player-facing MVP copy.

### W020 · Workshop hush bed (first 90s)
**Priority:** P0 · **Category:** Audio  
**Spec:** Title/Survey = shed air / distant kiln / authored silence; no orchestra/choir/aether pad.  
**Acceptance:** First 90s contain no mystic pad; seat phrase audible over ambient.

### W021 · Slack→taut earprint
**Priority:** P0 · **Category:** Audio  
**Spec:** Provisional Threads start slack; continuous climb to taut is interruptible motion+ear phrase.  
**Acceptance:** Mute-on: 'line goes tight' readable ≤3s; players describe strain before 'HP'.

### W022 · Snap / seat audio pair
**Priority:** P0 · **Category:** Audio  
**Spec:** Distinct snap tear vs seat settle; both workshop materials, not UI beeps.  
**Acceptance:** Blind listen: ≥80% distinguish snap vs seat; no generic coin chime.

### W023 · Anti-purple palette lock
**Priority:** P0 · **Category:** Visual  
**Spec:** Warm bone / shed grey / fiber / kiln copper ≤10%; ban violet bloom defaults.  
**Acceptance:** Hero frame palette audit flags purple channel dominance; overload reads rust.

### W024 · Physical void, not cosmos
**Priority:** P0 · **Category:** Visual  
**Spec:** Every field void is torn material scarcity — never near-black nebula.  
**Acceptance:** Cropped still without UI: stranger says broken bridge/yard not magic ruins.

### W025 · WASD + mouse loom controls
**Priority:** P0 · **Category:** Input  
**Spec:** Move, recover, bind, tension, undo mapped; Esc to title; no chord hell.  
**Acceptance:** First-five clearable with listed keys only; control card ≤6 lines.

### W026 · Controller snap targets (spike)
**Priority:** P0 · **Category:** Input  
**Spec:** Gamepad can snap ports and tension with stick magnet to ports — parity path starts W1.  
**Acceptance:** Spike clear on gamepad without touchpad mouse emulation.

### W027 · Reduce-motion juice path
**Priority:** P0 · **Category:** A11y  
**Spec:** Fragment suck / pulse shorten or static settles when reduce-motion on.  
**Acceptance:** Toggle on: suck ≤80ms or instant settle; no seizure full-screen flashes.

### W028 · One coach line per beat
**Priority:** P0 · **Category:** Discovery  
**Spec:** ≤1 diegetic caption per loop beat; silence after is intentional.  
**Acceptance:** First Structure job ≤24:00 with captions alone; prior teach → captions off still passable.

### W029 · Lattice host gather→combine→weave path
**Priority:** P0 · **Category:** Tech  
**Spec:** Keep Echo Lattice host contract for playable loop per BUILD_ON_LATTICE; twin spike may exist but host is launch path.  
**Acceptance:** Documented run path opens host and completes gather→combine→weave once; EL tree not deleted.

### W030 · Adversarial K1–K3 smoke (idle/spreadsheet/void)
**Priority:** P0 · **Category:** Quality  
**Spec:** Wire kill-test checklists from 34_ADVERSARIAL for idle Survey, numeric sheet UI, purple void.  
**Acceptance:** Checklist attached to PR template; any K1–K3 fail parks Coming Soon ask.

## 3.2 P1 — MVP 1.0 / first-thirty

### W031 · Shed Yard hub boot
**Priority:** P1 · **Category:** World  
**Spec:** Boot into Shed Yard brand: job board, fragment shelf, gallery wall stubs — one hub.  
**Acceptance:** Cold boot ≤10s to Yard; brand readable; no second biome required.

### W032 · First-thirty spine jobs (8–12)
**Priority:** P1 · **Category:** World  
**Spec:** Authored contracts covering Fragment literacy, Thread literacy, first Structure, world answer, CTA.  
**Acceptance:** Spine matches 16_FIRST_THIRTY; first useful Structure ≤24:00 cold.

### W033 · Fragment family: Channel
**Priority:** P1 · **Category:** Fragments  
**Spec:** Channel Fragment for flow jobs — ports and settle distinct from Span/Anchor.  
**Acceptance:** Flow teach job clearable using Channel; blind settle ID ≥70%.

### W034 · Fragment family: Charge
**Priority:** P1 · **Category:** Fragments  
**Spec:** Charge as kiln-warm pressure atom — never 'mana crystal' framing.  
**Acceptance:** Copy audit: no mana/chrono; Charge job uses warmth/pressure tell.

### W035 · Fragment family: Filter
**Priority:** P1 · **Category:** Fragments  
**Spec:** Filter gates flow/vent; silhouette reads sieve/cloth, not rarity gem.  
**Acceptance:** Vent/flow filter job; silhouette crop ID without UI labels.

### W036 · Thread type: Feed
**Priority:** P1 · **Category:** Threads  
**Spec:** Feed Thread legality + thickness/read for flow between ports.  
**Acceptance:** Feed literacy job; illegal Feed snap glyph matches failing pair.

### W037 · Thread type: Oppose
**Priority:** P1 · **Category:** Threads  
**Spec:** Oppose vents/counters load; distinct glyph and ear from Brace.  
**Acceptance:** Oppose teach clear; players don't call it 'armor'.

### W038 · Thread type: Echo
**Priority:** P1 · **Category:** Threads  
**Spec:** Echo for pulse/beat relations; never rewind/time magic.  
**Acceptance:** Pulse job uses Echo; string ban on rewind/chrono language.

### W039 · Structure recipe catalog ≤8 (slice)
**Priority:** P1 · **Category:** Structures  
**Spec:** ≤8 recipes in vertical slice; each 3–8 parts, one primary job.  
**Acceptance:** Content cap enforced in data; jobs ≥ Structures count.

### W040 · Structure class: Span bridge
**Priority:** P1 · **Category:** Structures  
**Spec:** Bridge/span Structure that rewrites topology across gap.  
**Acceptance:** Inhabit walk-across clears; collapse if under-braced.

### W041 · Structure class: Brace frame
**Priority:** P1 · **Category:** Structures  
**Spec:** Load-bearing frame for yard jobs; answers Oppose/Brace ecology.  
**Acceptance:** Load job fails without Brace frame; ecology doc class mapped.

### W042 · Structure class: Channel / sail / shelter (pick 3 more)
**Priority:** P1 · **Category:** Structures  
**Spec:** Ship three additional classes from ecology set with distinct rewrite channels.  
**Acceptance:** Each has one primary channel; mute still distinguishable.

### W043 · Jobs constrain chemistry
**Priority:** P1 · **Category:** Discovery  
**Spec:** Each job lists allowed families, threads, one primary channel.  
**Acceptance:** Job JSON has families[]/threads[]/channel; tools reject wild cards in teach set.

### W044 · One channel until composition field
**Priority:** P1 · **Category:** Discovery  
**Spec:** Topology/flow/load/pulse/vent taught singly before dual-channel.  
**Acceptance:** Teaching ladder audit: no dual-channel accept before F3 composition.

### W045 · No numeric combat sheet in Bind UI
**Priority:** P1 · **Category:** Discovery  
**Spec:** Stress/capacity as thickness, rust creep, taut/slack, audio — never HP/DPS digits on ports.  
**Acceptance:** Screenshot QA: zero digit readouts on Fragments during Bind.

### W046 · Tiny carry spindle inventory
**Priority:** P1 · **Category:** Economy  
**Spec:** 3–5 Fragment slots as spindle/bin; wrong picks cheap to return.  
**Acceptance:** No full-bags anxiety VFX; return-to-field works in ≤2 inputs.

### W047 · Thread budget as scarcity
**Priority:** P1 · **Category:** Economy  
**Spec:** Solo-satisfying Thread budget per field — not currency, not trade.  
**Acceptance:** Clear possible under budget; overdraw snaps; no coin iconography.

### W048 · Residue stamp + next-field bias
**Priority:** P1 · **Category:** Legacy  
**Spec:** Clear emits silhouette stamp + one bias tag reshaping next scarcity; no offline accrual.  
**Acceptance:** Leave game 30m on Yard → zero state change; bias has no % climb UI.

### W049 · Local gallery wall (thin MVP)
**Priority:** P1 · **Category:** Legacy  
**Spec:** Yard wall shows stood Structure silhouettes; offline; no leaderboards.  
**Acceptance:** Gallery interactors have no accept-predicate side effects; Steam-disabled works.

### W050 · Ghost self replay (chalk)
**Priority:** P1 · **Category:** Legacy  
**Spec:** Optional chalk replay of own prior clear — not rival invade.  
**Acceptance:** Ghost never blocks clear; toggle off leaves campaign intact.

### W051 · Elegance stars (optional, not speed tax)
**Priority:** P1 · **Category:** Progression  
**Spec:** Stars reward inhabit clarity + Thread leftover — never FOMO timer on Survey.  
**Acceptance:** Slow careful seat can top-mark; Survey has no countdown.

### W052 · Literacy unlock order
**Priority:** P1 · **Category:** Progression  
**Spec:** Unlock materials → joints → recipes → Yard corners only when jobs need them.  
**Acceptance:** Player never sees full prefab encyclopedia before first inhabit win.

### W053 · Job board always-available campaign
**Priority:** P1 · **Category:** World  
**Spec:** Campaign contracts offline always; no daily lock/energy/appointment mode.  
**Acceptance:** Campaign completable Steam-disabled with system clock skewed +24h.

### W054 · World-answer residue beat
**Priority:** P1 · **Category:** World  
**Spec:** After first Structure, field visibly answers (scaffold bias, longer gap, etc.).  
**Acceptance:** Players name how next field 'noticed' them without wiki table.

### W055 · Single next-session CTA
**Priority:** P1 · **Category:** World  
**Spec:** End of first-thirty: one quiet CTA (next job / wishlist in demo) — no meta dump.  
**Acceptance:** CTA appears after authorship pride; zero Discord/wiki requirement.

### W056 · Fragment leitmotifs (6 families)
**Priority:** P1 · **Category:** Audio  
**Spec:** Each Fragment family has a short leitmotif sting on recover/seat use.  
**Acceptance:** Blind listen ≥70% map sting→family for three taught families.

### W057 · Thread type earprints
**Priority:** P1 · **Category:** Audio  
**Spec:** Brace/Feed/Oppose/Echo distinct overtones on taut.  
**Acceptance:** Blind listen distinguishes Brace vs Feed ≥75%.

### W058 · Structure seat phrase
**Priority:** P1 · **Category:** Audio  
**Spec:** Per Structure class seat chord/phrase; workshop materials.  
**Acceptance:** Seat phrase survives mute? No — audio-on recognition ≥70% for two classes.

### W059 · Material bible pass (fiber/dust/timber/wire/chalk/kiln)
**Priority:** P1 · **Category:** Visual  
**Spec:** Replace procedural placeholders on hero Fragments with material-readable silhouettes.  
**Acceptance:** Mute still brand test; no circles-on-black default in Yard hero frames.

### W060 · Tension seat signature still
**Priority:** P1 · **Category:** Visual  
**Spec:** Art-direct the Tension seat as the store still — hands, thread, structure, consequence.  
**Acceptance:** 15s mute trailer open uses this still grammar; capsule passes brand test.

### W061 · Controller parity for slice
**Priority:** P1 · **Category:** Input  
**Spec:** Full first-thirty on gamepad including UI job board.  
**Acceptance:** Cold gamepad clear of spine job 1 without keyboard.

### W062 · Remappable controls
**Priority:** P1 · **Category:** Input  
**Spec:** Key/gamepad remap persisted in local settings.  
**Acceptance:** Remap Recover; save; relaunch; binding held.

### W063 · Colorblind-safe stress reads
**Priority:** P1 · **Category:** A11y  
**Spec:** Stress uses thickness + pattern + audio, not hue alone.  
**Acceptance:** Deuteranopia sim: slack vs taut still distinguishable.

### W064 · Caption / subtitle toggle
**Priority:** P1 · **Category:** A11y  
**Spec:** Coach lines and critical audio tells have caption track.  
**Acceptance:** Captions off/on both support clear of teach job for literacy players.

### W065 · Performance 60 FPS Yard target
**Priority:** P1 · **Category:** Tech  
**Spec:** Yard + field scenes hold ~60 FPS on mid-tier Windows laptop target resolution.  
**Acceptance:** Perf smoke doc with machine class; no uncapped particle spam on Recover.

### W066 · Content caps enforcement tools
**Priority:** P1 · **Category:** Tech  
**Spec:** Validate ≤12 Fragments / ≤20 Structures / job counts for MVP milestones.  
**Acceptance:** CI fails content pack exceeding slice/MVP caps without explicit waive flag.

### W067 · MVP Fragment count ramp (≤12)
**Priority:** P1 · **Category:** Fragments  
**Spec:** Grow from spike 2 toward ≤12 families/materials with jobs-first unlocks.  
**Acceptance:** At MVP 1.0 content audit: Fragments ≤12 and each has ≥1 job.

### W068 · MVP Structure recipes ≤20
**Priority:** P1 · **Category:** Structures  
**Spec:** Catalog capped; recipes authored with ecology answers.  
**Acceptance:** Audit: recipes ≤20; each maps to a primary rewrite channel.

### W069 · MVP jobs 40–60
**Priority:** P1 · **Category:** World  
**Spec:** Authored Yard contracts for 3–5h campaign + light sandbox dessert.  
**Acceptance:** Job count in range; sandbox never required for campaign clear.

### W070 · Sandbox after literacy (capped ask)
**Priority:** P1 · **Category:** World  
**Spec:** Free-build offers optional craft prompt or Exit; not first-thirty route.  
**Acceptance:** First-thirty path never enters sandbox; sandbox has Exit ≤1 click.

### W071 · Scrap residue (optional, non-trade)
**Priority:** P1 · **Category:** Economy  
**Spec:** Optional scrap on clear as solo craft resource — never player-tradeable.  
**Acceptance:** No stall/auction UI; scrap sinks into recipes only.

### W072 · Abandon field fair refund
**Priority:** P1 · **Category:** Core loop  
**Spec:** Abandon returns owned Fragments; no shame screen; residue rules explicit.  
**Acceptance:** Abandon→Yard→reenter: inventory fair; no softlock.

### W073 · Cut Thread verb
**Priority:** P1 · **Category:** Threads  
**Spec:** Cut/re-pin provisional Threads before Tension.  
**Acceptance:** Cut is ≤1 input; cut Thread does not spend Tension commit.

### W074 · Re-pin after cut
**Priority:** P1 · **Category:** Threads  
**Spec:** Re-pin to alternate ports without full inventory reset.  
**Acceptance:** Re-pin loop stays fun 60s without Tension (adversarial A8).

### W075 · Feed port glyph + mouth silhouette
**Priority:** P1 · **Category:** Discovery  
**Spec:** Feed mouth glyph distinct from Brace notch.  
**Acceptance:** Players complete Feed job without paragraph tooltip.

### W076 · Oppose vent glyph
**Priority:** P1 · **Category:** Discovery  
**Spec:** Oppose vent glyph; illegal pairs flash matching ports.  
**Acceptance:** Illegal Oppose→Brace misuse identifiable by glyph alone.

### W077 · Echo tick glyph
**Priority:** P1 · **Category:** Discovery  
**Spec:** Echo tick for pulse ports; no clock/time iconography.  
**Acceptance:** Icon audit: zero hourglasses/chronometers in Echo set.

### W078 · Field scarcity family readable at Survey
**Priority:** P1 · **Category:** Discovery  
**Spec:** Gap width / spill / pendulum in frame → hypothesis before Recover.  
**Acceptance:** Pause at Survey: ≥70% guess job family (span/flow/pulse/vent).

### W079 · Collapse comedy three languages
**Priority:** P1 · **Category:** Juice  
**Spec:** Slack, stretch, snap — three failure languages fair and visible.  
**Acceptance:** Players name failure mode after clip without HUD text.

### W080 · Structure ecology answers
**Priority:** P1 · **Category:** Structures  
**Spec:** Classes answer each other per 24_STRUCTURE_ECOLOGY (bridge vs brace vs channel…).  
**Acceptance:** At least one job requires reading ecology (wrong class fails inhabit).

## 3.3 P2 — Demo polish & post-slice deepen

### W081 · Demo build = slice + CTA
**Priority:** P2 · **Category:** Store  
**Spec:** Demo ships Yard corner + teach spine + one mastery job + wishlist CTA; offline; no account wall.  
**Acceptance:** Demo→wishlist path zero Discord; CTA after pride not lore cliffhanger.

### W082 · Mute-legible 15s trailer cut
**Priority:** P2 · **Category:** Store  
**Spec:** Hands→Thread across gap→Tension seat→inhabit; no lore cold open.  
**Acceptance:** Mute 0–15s reads 'parts became place'; no purple key art.

### W083 · GIF pack (collapse + elegant solve)
**Priority:** P2 · **Category:** Store  
**Spec:** Two GIFs: fair collapse comedy + elegant inhabit win.  
**Acceptance:** Store reviewers can pick either as shelf loop; both mute-legible.

### W084 · Steam pitch page draft lock
**Priority:** P2 · **Category:** Store  
**Spec:** Capsules/screenshots/copy from 30_STEAM_PITCH — Weaver only, never EL freeze paste.  
**Acceptance:** Checklist: no EL habit→geometry claims; price band $4.99–$8.99 noted.

### W085 · Name legal check gate
**Priority:** P2 · **Category:** Store  
**Spec:** Human legal check on ship name before Partner; AppIDs human-only.  
**Acceptance:** Docs mark placeholder; no invented AppID in repo.

### W086 · Adversarial K4–K6 green
**Priority:** P2 · **Category:** Quality  
**Spec:** Remaining kill-tests from 34_ADVERSARIAL green before Coming Soon ask.  
**Acceptance:** G8 gate: K1–K6 all green signed in ROADMAP.

### W087 · Second Yard corner (optional 1.0)
**Priority:** P2 · **Category:** World  
**Spec:** Optional second corner for variety without second biome tourism.  
**Acceptance:** Corner unlock via literacy; still one hub fantasy.

### W088 · Pulse/Pendulum craft beat tool
**Priority:** P2 · **Category:** Fragments  
**Spec:** Pulse/Pendulum only as craft beat tool — never rewind.  
**Acceptance:** Job uses beat timing; copy ban on time-travel.

### W089 · Multi-channel composition field
**Priority:** P2 · **Category:** Structures  
**Spec:** After single-channel literacy, one composition field with two channels.  
**Acceptance:** Appears only after F3 ladder; accept predicate documents both.

### W090 · Planarity / crossing stress tell
**Priority:** P2 · **Category:** Threads  
**Spec:** Soft planarity: crossing Threads add readable stress — not a spreadsheet column.  
**Acceptance:** Crossing shows rust/creak; no floating ±integers.

### W091 · Elegance rubric on index card
**Priority:** P2 · **Category:** Progression  
**Spec:** Star rubric: stranger-walk clarity primary; leftover Thread secondary.  
**Acceptance:** Rubric fits one index card in docs + UI help long-press.

### W092 · Gallery stamp share via screenshot/seed
**Priority:** P2 · **Category:** Legacy  
**Spec:** Share = screenshot or seed paste only at this tier — no lobby.  
**Acceptance:** Seed paste round-trips Structure silhouette offline.

### W093 · Daily shared seed (dessert)
**Priority:** P2 · **Category:** Legacy  
**Spec:** Optional daily seed from local clock/bundled rotation — not appointment campaign.  
**Acceptance:** Campaign clearable ignoring daily; daily runs Steam-disabled.

### W094 · Friend seed handoff string
**Priority:** P2 · **Category:** Legacy  
**Spec:** Clipboard seed string for friend handoff; comparable offline; no chat/ladder.  
**Acceptance:** Import friend seed; clear; no network required mid-run.

### W095 · Legacy evolution (post-slice)
**Priority:** P2 · **Category:** Legacy  
**Spec:** Offline Structure evolution per 28_LEGACY_V2 — deepen after slice metrics.  
**Acceptance:** Evolution changes silhouette/bias only on clear/abandon; no wall-clock drip.

### W096 · Workshop ambiences per Yard corner
**Priority:** P2 · **Category:** Audio  
**Spec:** Distinct hush beds per corner without genre mash music beds.  
**Acceptance:** Corner A vs B blind ambient ID ≥60%; still no choir destiny.

### W097 · Adaptive tension music (post-seat only)
**Priority:** P2 · **Category:** Audio  
**Spec:** If music enters, only after first seat; tension-reactive within workshop family.  
**Acceptance:** Pre-seat: hush only; post-seat: music never masks snap tells.

### W098 · Kiln copper stress creep VFX
**Priority:** P2 · **Category:** Visual  
**Spec:** Overload creep as rust/copper along Thread — ≤10% frame.  
**Acceptance:** Palette audit; no magenta cyber.

### W099 · Chalk provisional Thread rendering
**Priority:** P2 · **Category:** Visual  
**Spec:** Provisional Threads read as chalk/fiber; committed as cord/wire.  
**Acceptance:** Screenshot: provisional vs committed distinguishable mute-on.

### W100 · Structure dust settle motion
**Priority:** P2 · **Category:** Juice  
**Spec:** Seat adds dust/joint settle — third motion budget item beyond suck/flash/pulse.  
**Acceptance:** Mute still shows settle; reduce-motion safe.

### W101 · Fair collapse share prompt (optional)
**Priority:** P2 · **Category:** Juice  
**Spec:** After comedy collapse, optional local GIF buffer — never forces social.  
**Acceptance:** Prompt dismissible; offline; no account.

### W102 · Discovery without spoiler wiki
**Priority:** P2 · **Category:** Discovery  
**Spec:** In-game tells teach combinations; no forced external guide.  
**Acceptance:** Playtest: ≤20% open external wiki before job 8.

### W103 · Illegal bind snap catalog (craft tells)
**Priority:** P2 · **Category:** Discovery  
**Spec:** Each illegal pair has unique snap tell (glyph+sound).  
**Acceptance:** Matrix of taught pairs: unique tells; no generic buzz.

### W104 · Job replay from board
**Priority:** P2 · **Category:** World  
**Spec:** Re-run cleared jobs for elegance without story gate.  
**Acceptance:** Replay does not reset campaign unlocks unfairly.

### W105 · Settings: audio buses + mute groups
**Priority:** P2 · **Category:** Audio  
**Spec:** Separate buses: hush bed / verb SFX / music; mute groups.  
**Acceptance:** Mute music keeps snap/seat audible.

### W106 · Linux build nice-to-have smoke
**Priority:** P2 · **Category:** Tech  
**Spec:** Export Linux build for slice; input parity notes.  
**Acceptance:** Headless or manual smoke boots main scene.

### W107 · Deck input parity checklist
**Priority:** P2 · **Category:** Input  
**Spec:** Steam Deck control checklist before Deck claim.  
**Acceptance:** Checklist signed; no Deck marketing until parity.

### W108 · Photo mode / still export (workshop)
**Priority:** P2 · **Category:** Store  
**Spec:** Simple still export of Tension seat for trailer grabs — diegetic camera optional.  
**Acceptance:** Export PNG of seat without HUD; no purple post stack.

### W109 · Localization string table (EN first)
**Priority:** P2 · **Category:** Tech  
**Spec:** All player-facing strings externalized; EN ship.  
**Acceptance:** No hardcoded unique coach lines in GDScript literals (allowlist exceptions).

### W110 · Content authoring pipeline docs
**Priority:** P2 · **Category:** Tech  
**Spec:** How to add Fragment/Thread/Structure/job JSON with validation.  
**Acceptance:** New contributor adds a dummy job via doc in <1 focused session.

### W111 · Telemetry fence (opt-in, privacy)
**Priority:** P2 · **Category:** Tech  
**Spec:** If any analytics: opt-in, offline-default off, no gameplay gate.  
**Acceptance:** Fresh install: telemetry off; campaign clearable offline.

### W112 · Pause does not advance residue
**Priority:** P2 · **Category:** Economy  
**Spec:** Pause/overlay time never accrues scrap/bias.  
**Acceptance:** Pause 30m: zero economy change (A1 ally).

## 3.4 P3 — Post-1.0 fence (still pure)

### W113 · Co-op build fence (design only until reopen)
**Priority:** P3 · **Category:** Multiplayer  
**Spec:** Post-1.0 realtime only as co-op build per 29_MULTIPLAYER_V2 — no seamless competitive.  
**Acceptance:** Docs+proto: competitive invade/PvP paths absent; human reopen required to staff.

### W114 · Async ghost Structures from friends
**Priority:** P3 · **Category:** Multiplayer  
**Spec:** Import friend Structure ghosts as chalk — never required for campaign.  
**Acceptance:** Campaign 100% without ghosts; ghost cannot grief.

### W115 · Share-code Structure cards
**Priority:** P3 · **Category:** Legacy  
**Spec:** Schema-versioned Structure share cards offline import/export.  
**Acceptance:** Round-trip card; reject corrupt/foreign schema safely.

### W116 · Second biome pack (one lane)
**Priority:** P3 · **Category:** World  
**Spec:** Post-MVP pick one expansion lane — second biome OR co-op OR Workshop, not all.  
**Acceptance:** Expansion proposal names single lane; MVP caps unchanged.

### W117 · Workshop / mods (after job quality)
**Priority:** P3 · **Category:** Tech  
**Spec:** Mod/Workshop only after job quality proven; sandbox safety.  
**Acceptance:** Gate checklist references G7; no day-one Workshop claim.

### W118 · Material pack DLC fence
**Priority:** P3 · **Category:** Store  
**Spec:** DLC = material packs post-1.0 after core jobs praised — no day-one DLC.  
**Acceptance:** Monetization doc: day-one DLC = reject; core campaign uncut.

### W119 · Advanced elegance trials
**Priority:** P3 · **Category:** Progression  
**Spec:** Optional mastery trials for Thread economy artists — never gate story.  
**Acceptance:** Campaign clearable ignoring trials; trials offline.

### W120 · Structure aging / patina layers
**Priority:** P3 · **Category:** Legacy  
**Spec:** Gallery silhouettes accrue workshop patina across clears — recognition, not grind meter.  
**Acceptance:** Patina visual only; no power creep stats.

### W121 · Yard weather as craft climate
**Priority:** P3 · **Category:** World  
**Spec:** Visual/audio climate from recent craft style (dusty, damp fiber) — never survival meters.  
**Acceptance:** No wet/dry HP; climate optional toggle.

### W122 · Photo plate museum night
**Priority:** P3 · **Category:** Legacy  
**Spec:** Occasional Yard 'museum night' lighting for gallery pride — no appointment rewards.  
**Acceptance:** Opening museum night grants zero currency/unlocks.

### W123 · Contraption remix seeds (official)
**Priority:** P3 · **Category:** World  
**Spec:** Bundled remix seeds of official Structures for sandbox dessert.  
**Acceptance:** Remix never required; labeled dessert.

### W124 · Advanced Filter alchemy (authored)
**Priority:** P3 · **Category:** Fragments  
**Spec:** Deeper Filter behaviors still authored, not chemistry spreadsheet wiki bait.  
**Acceptance:** Each behavior taught by a job; no public numeric matrix.

### W125 · Echo harmony puzzles
**Priority:** P3 · **Category:** Threads  
**Spec:** Multi-Echo pulse alignment puzzles post-literacy.  
**Acceptance:** Still one primary channel per job unless composition-tagged.

### W126 · Contrasting elegance vs comedy catalog
**Priority:** P3 · **Category:** Juice  
**Spec:** Curated shareable moments library for marketing — collapses + seats.  
**Acceptance:** ≥10 approved clips with mute-legible thesis.

### W127 · Accessibility: sticky ports / aim friction
**Priority:** P3 · **Category:** A11y  
**Spec:** Assistive stickiness for port aiming without solving puzzles.  
**Acceptance:** Assist does not auto-Tension or auto-clear.

### W128 · Narration / audio description pack
**Priority:** P3 · **Category:** A11y  
**Spec:** Optional audio description for Survey scarcity tells.  
**Acceptance:** Toggle; offline; not required for clear.

### W129 · Speedrun / challenge seed room (optional)
**Priority:** P3 · **Category:** Progression  
**Spec:** Optional challenge room — no FOMO on campaign board.  
**Acceptance:** Hidden from first-thirty; no rewards that gate content.

### W130 · Credits loom colophon
**Priority:** P3 · **Category:** Store  
**Spec:** End credits as workshop colophon: materials used, Structures stood — document ending.  
**Acceptance:** Colophon generates from save; not only video credits.

### W131 · Migrate EL execute (human-gated)
**Priority:** P3 · **Category:** Tech  
**Spec:** Execute 33_MIGRATE_FROM_LATTICE only after gates + human ack — not this backlog's default staff.  
**Acceptance:** No git mv EL until migrate §6 green + human ack checkbox.

### W132 · Console / Deck verified ship
**Priority:** P3 · **Category:** Tech  
**Spec:** Input+perf verified on Deck/console targets after PC MVP.  
**Acceptance:** Parity checklist complete; store Deck flag only then.

---

## 4. Recommended packs (ship without sprawl)

### Pack A — Verb proof (P0 core)

W001–W012 · W017–W022 · W023–W024 · W029

**Acceptance:** Cold first-five clear; mute still sells parts→thread→structure; Lattice host path documented.

### Pack B — Fair toy & tech fence (P0)

W013–W016 · W025–W028 · W030

**Acceptance:** G1 sim fence locked; deterministic seed contract green; Steam-disabled loop; K1–K3 checklist attached.

### Pack C — First thirty (P1 spine)

W031–W032 · W033–W038 · W039–W042 · W043–W045 · W052–W055 · W078

**Acceptance:** First useful Structure ≤24:00; jobs constrain chemistry; inhabit mandatory.

### Pack D — Solo economy & legacy thin (P1)

W046–W051 · W071–W074 · W079–W080

**Acceptance:** No trade UI; gallery offline pride-only; abandon fair; ecology answers at least once.

### Pack E — Identity craft (P1–P2)

W056–W060 · W096–W100 · W082–W083

**Acceptance:** Non-generic art/audio; 15s mute trailer; copper creep ≤10%.

### Pack F — Demo & Partner gate (P2)

W081–W086 · W092–W094 · W106–W108

**Acceptance:** Demo CTA offline; K1–K6 green; no invented AppID; EL freeze never pasted as Weaver.

### Pack G — Fence only (P3)

W113–W118 · W131

**Acceptance:** Co-op-only MP fence; no competitive; migrate human-gated; one expansion lane.

---

## 5. Explicit rejects (scope crawl)

| Temptation | Why rejected |
|---|---|
| Player trade / auction / stalls | Killed — [`../27_SOLO_ECONOMY_V2.md`](../27_SOLO_ECONOMY_V2.md) |
| Realtime competitive / invade | Killed — [`../29_MULTIPLAYER_V2.md`](../29_MULTIPLAYER_V2.md) |
| F2P, battle pass, gacha, energy | Monetization fence — premium paid only |
| Purple-void / chronomancy Fragments | Identity + Fragment bans |
| Besiege-scale part encyclopedia before 20 great jobs | MVP cut · risk D3 |
| Skill tree to paper over muddy verbs | Progression = literacy, not XP theater |
| Rename/delete `game/echo_lattice/` as Weaver | Pivot + migrate plan-only |
| LLM runtime / AI worldbuilder marketing | Offline authored content only |
| Coming Soon before slice exit criteria | ROADMAP G3/G6/G8 |
| Offline accrual / login drip on residue | Adversarial A1 |

---

## 6. Traceability

| Cluster | Authority docs |
|---|---|
| Loop / spike timing | [`../02_CORE_LOOP.md`](../02_CORE_LOOP.md) · [`../32_FIRST_FIVE.md`](../32_FIRST_FIVE.md) · [`../16_FIRST_THIRTY.md`](../16_FIRST_THIRTY.md) |
| Fragments / Threads / Structures | [`../03_FRAGMENTS.md`](../03_FRAGMENTS.md)–[`../05_STRUCTURES.md`](../05_STRUCTURES.md) · [`../24_STRUCTURE_ECOLOGY.md`](../24_STRUCTURE_ECOLOGY.md) |
| Discovery / anti-wiki | [`../22_DISCOVERY_UX.md`](../22_DISCOVERY_UX.md) · [`../20_ELEVATIONS_V2.md`](../20_ELEVATIONS_V2.md) |
| Juice / weave feel | [`../35_JUICE.md`](../35_JUICE.md) · [`../23_WEAVE_VERB.md`](../23_WEAVE_VERB.md) · [`../21_FRAGMENT_FEEL.md`](../21_FRAGMENT_FEEL.md) |
| Art / audio identity | [`../09_VISUAL.md`](../09_VISUAL.md) · [`../25_VOID_ART_V2.md`](../25_VOID_ART_V2.md) · [`../10_AUDIO.md`](../10_AUDIO.md) · [`../26_AUDIO_V2.md`](../26_AUDIO_V2.md) |
| Economy / legacy / MP fences | [`../27_SOLO_ECONOMY_V2.md`](../27_SOLO_ECONOMY_V2.md) · [`../28_LEGACY_V2.md`](../28_LEGACY_V2.md) · [`../29_MULTIPLAYER_V2.md`](../29_MULTIPLAYER_V2.md) |
| Kill-tests / risks | [`../34_ADVERSARIAL.md`](../34_ADVERSARIAL.md) · [`../18_RISKS.md`](../18_RISKS.md) |
| Host / scaffold | [`../BUILD_ON_LATTICE.md`](../BUILD_ON_LATTICE.md) · `game/weaver/` · `game/echo_lattice/` |
| Historical EL 1000× backlog (not live north star) | [`../../VISION/FEATURE_BACKLOG_1000X.md`](../../VISION/FEATURE_BACKLOG_1000X.md) |

---

## 7. Doc contract

| Field | Lock |
|---|---|
| Mode | Cloud-only docs in this PR — no gameplay code required |
| Minimum size | **≥100** features with acceptance tests (this file: **132**) |
| Priority labels | **P0 / P1 / P2 / P3** only |
| Conflict order | PIVOT → PRODUCT_IDENTITY → 17_MVP → systems → elevations |
| EL tree | Kept; migrate is human-gated execute PR |
| Success | A stranger can watch a 20s mute clip and say: *they stitched parts into a bridge and had to walk it* |

**Lock line:** Prioritize the verb until it is undeniable; grow the Yard job mountain next; polish for the shelf only after adversarial kill-tests are green — and never staff rejects to feel productive.
