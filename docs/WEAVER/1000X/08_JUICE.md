# The Weaver — 1000× · 08 · Juice (Diegetic Verb Map)

**Doc:** `docs/WEAVER/1000X/08_JUICE.md`  
**Status:** 1000× feel authority — **50 diegetic juice specs** mapped to verbs (CLOUD ONLY)  
**Branch:** `cursor/weaver-1000x-juice`  
**Base:** `cursor/echo-lattice-rc1`  
**Product:** **The Weaver** (north star; Echo Lattice frozen — see [`../PIVOT.md`](../PIVOT.md))  
**Job:** Elevate W1’s three workshop motions into a **complete verb→juice ledger** so every interactive beat has a named, timed, diegetic answer — fiber, chalk, timber, dust — never HUD fireworks.  
**Peers (v2 locks):** [`../35_JUICE.md`](../35_JUICE.md) · [`../23_WEAVE_VERB.md`](../23_WEAVE_VERB.md) · [`../02_CORE_LOOP.md`](../02_CORE_LOOP.md) · [`../09_VISUAL.md`](../09_VISUAL.md) · [`../10_AUDIO.md`](../10_AUDIO.md) · [`../21_FRAGMENT_FEEL.md`](../21_FRAGMENT_FEEL.md) · [`../MASTER_GDD.md`](../MASTER_GDD.md)  
**Series siblings:** [`00_MASTER_VISION.md`](00_MASTER_VISION.md) · [`01_CORE_LOOP.md`](01_CORE_LOOP.md) · [`09_AUDIO.md`](09_AUDIO.md) · [`10_ART.md`](10_ART.md) · [`12_UI.md`](12_UI.md)

---

## 0. Thesis

Weaver juice is **workshop punctuation**. The world reacts as materials — not as UI chrome, combat kits, or cosmic bloom.

**One-line brief:** _Fifty diegetic beats; every verb owns sight + weight + sound; mute still sells authorship._

**Still test:** mute audio; crop HUD. A stranger must narrate *parts gather → fiber fights → cloth seats → feet own the stitch*.

**1000× elevation over W1:** [`../35_JUICE.md`](../35_JUICE.md) ships three spike motions (`fragment_suck` · `combine_flash` · `weave_pulse`). This doc **maps the full verb surface** — Survey through Residue, plus stress, undo, comedy fails, and shell folio — so feel work never invents detached VFX for an unnamed verb.

| Lock | Meaning |
|---|---|
| **Diegetic or cut** | If it cannot be chalk, fiber, timber, dust, stamp, or kiln-warm metal in the shed, delete it |
| **Verb-owned** | Every juice ID maps to exactly one player/system verb |
| **Clocked** | Spec without a timing window is a mood board — rewrite or cut |
| **Dual channel** | Sight + sound (or sight + pattern for a11y); audio never sole telegraph |
| **Reduce-motion** | Outcome remains readable in ≤3 frames + one audio hit |

---

## 1. Hard ban

| Banned | Why |
|---|---|
| Cosmic purple / violet bloom / magenta cyber flash | Gameslop; fights Fragment ban ([`../03_FRAGMENTS.md`](../03_FRAGMENTS.md)) |
| Full-screen energy wash on Recover / Bind / Tension | Document/textile game settles; physics games explode |
| Magnet / Pokémon catch beam on Recover | Fragments are craft atoms, not orbs |
| Idle UI breathe / pulse chrome | Motion budget is for verbs ([`../09_VISUAL.md`](../09_VISUAL.md) §6) |
| Confetti, portal swallow, rarity sparkle, XP banners | Wrong shelf |
| Combat hitstop kit as default (flash + bass drop + trauma shake) | Weaver hitstop is optional, tiny, seat-only |
| Chrono rewind swoosh / hourglass shake | Pulse is craft beat, not time magic |
| Detached glow halos floating off Thread bodies | Copper rides the cord, never orbits it |

**Allowed accent:** kiln copper ≤10% of frame, riding **Thread body** during weave/seat crest — never a free-floating aura.

---

## 2. Verb index (coverage)

Core loop from [`../02_CORE_LOOP.md`](../02_CORE_LOOP.md) + micro-verbs from [`../23_WEAVE_VERB.md`](../23_WEAVE_VERB.md):

| Verb family | Spec IDs | Count |
|---|---|---|
| **Survey** | J01–J04 | 4 |
| **Recover** | J05–J12 | 8 |
| **Bind** | J13–J22 | 10 |
| **Tension** | J23–J32 | 10 |
| **Stress / Collapse** | J33–J38 | 6 |
| **Inhabit** | J39–J43 | 5 |
| **Residue / Yard** | J44–J47 | 4 |
| **Shell / a11y / comedy** | J48–J50 | 3 |
| **Total** | **J01–J50** | **50** |

W1 spike API mapping (do not delete; deepen):

| W1 API ([`../35_JUICE.md`](../35_JUICE.md)) | 1000× owners |
|---|---|
| `fragment_suck` | J05–J08 |
| `combine_flash` | J17–J18 |
| `weave_pulse` | J27–J30 |

---

## 3. Spec card schema

Each of the fifty specs uses this card:

| Field | Meaning |
|---|---|
| **ID** | Stable `Jnn` — cite in code / tests / art tickets |
| **Verb** | Player or system verb that owns the juice |
| **Name** | Short diegetic name (workshop language) |
| **Diegetic read** | What a mute stranger should *see as material fact* |
| **Sight** | Visual punctuation |
| **Sound** | Ear punctuation (bus: SFX unless noted) |
| **Timing** | Wall-clock window (reduce-motion collapse in §5) |
| **Must not** | Cheap fail / ban for this beat |
| **Signal** | Optional finished event for code |

---

## 4. Fifty diegetic juice specs

### 4.1 Survey — J01–J04

#### J01 · Survey · Field hush settle
| | |
|---|---|
| **Diegetic read** | The yard holds its breath; the gap is a tear in cloth, not a void portal |
| **Sight** | Camera eases 120–200 ms onto frayed field; gap edge reads as torn weave; no objective spam |
| **Sound** | Shed HVAC / distant kiln bed ≤ −28 dB or authored silence |
| **Timing** | 0.0–2.0 s of first interactive frame |
| **Must not** | Timer panic, rarity toast, neon objective arrow |
| **Signal** | `survey_hush_ready` |

#### J02 · Survey · Gap antagonist read
| | |
|---|---|
| **Diegetic read** | Missing span / starved basin / broken load path is the problem, readable at a glance |
| **Sight** | Physical fray silhouette (torn cloth / plank absence); chalk ghost optional ≤1 diegetic caption |
| **Sound** | Soft air across the tear once (≤80 ms); then hush |
| **Timing** | Readable within 2.0–5.0 s of enter |
| **Must not** | Quest log novel; floating exclamation marks |
| **Signal** | — |

#### J03 · Survey · Material silhouette notice
| | |
|---|---|
| **Diegetic read** | Fragments sit as **stuff** in the yard — timber, peg, copper scrap — not loot orbs |
| **Sight** | Shed-light edge catch on nearest 1–2 Fragment bodies; no radar ping |
| **Sound** | None, or ≤1 fiber brush if cursor passes within pick radius |
| **Timing** | Continuous while surveying; catch ≤100 ms on enter FOV |
| **Must not** | Loot sparkles, rarity breathe, magnet pull before Recover |
| **Signal** | — |

#### J04 · Survey · Scarcity shelf glance
| | |
|---|---|
| **Diegetic read** | Carry / Thread budgets are workshop facts (empty nests, spare spindles), not RPG bars |
| **Sight** | Diegetic shelf / spindle row shows empty nests; no glass HUD meter pulse |
| **Sound** | Silent |
| **Timing** | Available on demand; never auto-pulses |
| **Must not** | Idle UI breathe; gem-currency chrome |
| **Signal** | — |

---

### 4.2 Recover — J05–J12

#### J05 · Recover · Unstick grit
| | |
|---|---|
| **Diegetic read** | Fragment was seated in the field; it leaves with resistance |
| **Sight** | Target lifts 1–2 px; contact highlight on **body** (not rarity border) |
| **Sound** | Soft fiber brush / grit unstick |
| **Timing** | F0 (~16 ms) |
| **Must not** | Instant vacuum; sky beam |
| **Signal** | `recover_unstick(id)` |

#### J06 · Recover · Chalk fiber suck *(W1 `fragment_suck`)*
| | |
|---|---|
| **Diegetic read** | Chalk/fiber wisps + plank silhouette ease into the hand shelf |
| **Sight** | ≤6 chalk wisps; fiber strand back to origin; silhouette shrinks to hand (~320 ms) |
| **Sound** | Mass whoom ≤40 ms (timber) or filament tick (wire) |
| **Timing** | ~320 ms (reduce-motion ≤80 ms hard cut) |
| **Must not** | Homing beam, additive bloom, screen trauma |
| **Signal** | `fragment_suck_finished(id)` |

#### J07 · Recover · Palm mass settle
| | |
|---|---|
| **Diegetic read** | Weight lands in the palm / bin — craft atom, not currency |
| **Sight** | Brief squash into pocket; shadow shortens; no idle bob after |
| **Sound** | Settled tick |
| **Timing** | F5–F8 of recover phrase (~80–130 ms after suck start) |
| **Must not** | Confetti, XP pop, rarity sting |
| **Signal** | `recover_settled(id)` |

#### J08 · Recover · Shelf nest snap
| | |
|---|---|
| **Diegetic read** | Fragment occupies a stamped nest; silhouette stays readable at HUD scale |
| **Sight** | Outline snaps to nest stamp; shelf depresses like cloth pocket |
| **Sound** | Soft wood/cloth nest click −6 dB under settle |
| **Timing** | ≤60 ms after palm settle |
| **Must not** | Bounce-spam; stack counter alone without outline |
| **Signal** | `shelf_nest_seated(id)` |

#### J09 · Recover · Size-tier tug
| | |
|---|---|
| **Diegetic read** | S soft, L stubborn — mass is literacy |
| **Sight** | Reach stretch ∝ size tier; L may need 2-frame hold before unstick |
| **Sound** | Pitch/length of unstick scales with tier (±3 st) |
| **Timing** | Reach window 80–220 ms by tier |
| **Must not** | Same vacuum timing for S and L |
| **Signal** | — |

#### J10 · Recover · Wrong-tug fail
| | |
|---|---|
| **Diegetic read** | Comedy weight teach — Fragment stays; dust puff |
| **Sight** | F0–F3 stretch → recoil; Fragment remains in field; ≤3 chalk dust |
| **Sound** | Dry dud tick; no buzzer |
| **Timing** | ≤400 ms total return |
| **Must not** | Tip spam; red error toast; shame stamp |
| **Signal** | `recover_fail(id)` |

#### J11 · Recover · Full-hands comedy
| | |
|---|---|
| **Diegetic read** | Hands are full — refuse with a soft knock, not a sell/trash prompt |
| **Sight** | New Fragment knocks lightly; carry nests shake once |
| **Sound** | Soft knuckle-wood knock |
| **Timing** | ≤300 ms |
| **Must not** | Marketplace dump UI; trash economy |
| **Signal** | `recover_hands_full` |

#### J12 · Recover · Pulse beat tick *(Pulse family only)*
| | |
|---|---|
| **Diegetic read** | Pendulum / bellows Fragment announces craft tempo — not chronomancy |
| **Sight** | Single brass edge tick on bob (`--pulse-brass`); ≤2 frames ochre flash max |
| **Sound** | Dry pendulum tick |
| **Timing** | On recover settle of Pulse only |
| **Must not** | Purple; rewind swoosh; hourglass |
| **Signal** | — |

---

### 4.3 Bind — J13–J22

#### J13 · Bind · Port pin kiss
| | |
|---|---|
| **Diegetic read** | Finger plants on a from-port; chalk mote marks the pin |
| **Sight** | Port glyph accepts once; chalk mote at pin |
| **Sound** | Dry chalk kiss |
| **Timing** | t=0.00 of draw |
| **Must not** | RTS power-line snap grid |
| **Signal** | `bind_pin_down(port)` |

#### J14 · Bind · Slack fiber scrape
| | |
|---|---|
| **Diegetic read** | Pulling fiber across a page — forearm fight begins |
| **Sight** | Dashed slack chalk follows tip; thickness ∝ stress estimate |
| **Sound** | Continuous scrape; pitch ↑ with `span_cost` (≤+4 st) |
| **Timing** | While dragging (continuous) |
| **Must not** | Instant perfect neon beam; constant-thickness glow line |
| **Signal** | — |

#### J15 · Bind · Legal port brighten
| | |
|---|---|
| **Diegetic read** | “It will take” — mouth opens once |
| **Sight** | To-port glyph brightens once (≤100 ms) |
| **Sound** | Soft tick −12 dB under scrape |
| **Timing** | On legal port enter |
| **Must not** | Green checkmark UI sticker; linger glow |
| **Signal** | `bind_port_legal(port)` |

#### J16 · Bind · Illegal port grit
| | |
|---|---|
| **Diegetic read** | “Wrong mouth” — pre-snap warning without a lecture |
| **Sight** | Glyph flashes white once |
| **Sound** | Pre-snap grit |
| **Timing** | On illegal port enter |
| **Must not** | Red error toast essay |
| **Signal** | `bind_port_illegal(port)` |

#### J17 · Bind · Paper-press flash *(W1 `combine_flash`)*
| | |
|---|---|
| **Diegetic read** | Local chalk-bright paper press + crease cross at the seam |
| **Sight** | Local disc at bind point; peak `chalk_bright`; ink crease cross |
| **Sound** | Short fiber settle 30–50 ms |
| **Timing** | ~140 ms |
| **Must not** | Full-viewport flash; cadmium spam; purple |
| **Signal** | `combine_flash_finished` |

#### J18 · Bind · Chalk-taut settle
| | |
|---|---|
| **Diegetic read** | Provisional Thread becomes chalk-taut between honest ports |
| **Sight** | Line settles; endpoints pin; provisional vs ink still distinct in greyscale |
| **Sound** | Fiber settle tail |
| **Timing** | ≤50 ms after legal release |
| **Must not** | Auto-seat as Structure |
| **Signal** | `bind_legal_settled(thread)` |

#### J19 · Bind · Illegal snap phrase
| | |
|---|---|
| **Diegetic read** | Dry break — craft tell, not UI scold |
| **Sight** | Thread whites out → retracts to from-port; ≤4 chalk dust |
| **Sound** | Short white transient → designed silence rest |
| **Timing** | ≤0.55 s total (0–50 white · 50–200 retract · 200–550 rest) |
| **Must not** | Buzzer cartoon; modal; Thread budget spent on illegal |
| **Signal** | `bind_snap_finished` |

#### J20 · Bind · Crossing rust speck
| | |
|---|---|
| **Diegetic read** | Crossing lines argue — stress rises, not auto-fail |
| **Sight** | Rust speck at crossing; lines remain readable |
| **Sound** | Optional dry grit −18 dB |
| **Timing** | While crossed provisional exists |
| **Must not** | Instant fail; spaghetti without tell |
| **Signal** | — |

#### J21 · Bind · Undo re-pin
| | |
|---|---|
| **Diegetic read** | Last Thread re-pins as fiber returning home — not “reload checkpoint” |
| **Sight** | Fiber retracts along path; chalk dust ≤3; ports idle |
| **Sound** | Soft rewind-fiber (material), never chrono whoosh |
| **Timing** | ≤350 ms |
| **Must not** | Screen wipe; shame undo stamp |
| **Signal** | `bind_undo_finished(thread)` |

#### J22 · Bind · Type earprint
| | |
|---|---|
| **Diegetic read** | Brace / Feed / Oppose / Echo each have a distinct stitch voice |
| **Sight** | Shared chalk grammar; type glyph at ports |
| **Sound** | Brace = cord pull · Feed = sift/flow tick · Oppose = vent air · Echo = dry sense click |
| **Timing** | On legal settle (≤80 ms earprint) |
| **Must not** | One generic “link” blip for all types |
| **Signal** | — |

---

### 4.4 Tension — J23–J32

#### J23 · Tension · Commit arm
| | |
|---|---|
| **Diegetic read** | Held breath — graph promises ink; mash ignored |
| **Sight** | Provisional chalk dims → ink promise; input lock |
| **Sound** | Bed ducks −3 dB |
| **Timing** | 0–200 ms of seat phrase |
| **Must not** | Instant pop Structure |
| **Signal** | `tension_armed` |

#### J24 · Tension · Crease gather
| | |
|---|---|
| **Diegetic read** | Cloth/page gathers at pins — body leans in |
| **Sight** | Multi-fiber gather at pins; Threads pull taut |
| **Sound** | Multi-fiber rustle; micro silence gaps |
| **Timing** | 200–550 ms |
| **Must not** | Screen bloom warp; chromatic aberration |
| **Signal** | — |

#### J25 · Tension · Lift inhale
| | |
|---|---|
| **Diegetic read** | Soft mass inhale — shadow / weight, not library whoosh |
| **Sight** | Brief cast shadow; Structure rises a hair |
| **Sound** | Soft air body inhale |
| **Timing** | 550–750 ms |
| **Must not** | Jump cut to finished mesh; rim-light magic |
| **Signal** | — |

#### J26 · Tension · Wood/cord seat downbeat
| | |
|---|---|
| **Diegetic read** | Loudest honest hit — joints bite; law becomes walkable |
| **Sight** | Joints bite; Structure materializes as law (topology/flow/load/pulse/vent) |
| **Sound** | Wood/cord downbeat — phrase peak |
| **Timing** | 750–950 ms; optional hitstop ≤90 ms @ floor 0.06 |
| **Must not** | Confetti; portal swallow; default trauma shake |
| **Signal** | `tension_seated` |

#### J27 · Tension · Copper weave pulse *(W1 `weave_pulse`)*
| | |
|---|---|
| **Diegetic read** | Kiln-copper crest rides the Thread polyline — cord load made visible |
| **Sight** | Width/alpha pulse on Thread path; copper crest ≤10% frame |
| **Sound** | Cord load crest under seat (or layered with J26) |
| **Timing** | ~480 ms · up to 2 cycles overlapping seat |
| **Must not** | Expanding neon ring; detached halo; purple |
| **Signal** | `weave_pulse_finished` |

#### J28 · Tension · Dust settle
| | |
|---|---|
| **Diegetic read** | Pride without brass — dust falls; hush returns |
| **Sight** | Dust fall; ink seams commit; rust clear if healthy |
| **Sound** | Stitch lock ticks; bed returns to shed hush |
| **Timing** | 950–1200 ms |
| **Must not** | XP banner; fanfare |
| **Signal** | `tension_settled` |

#### J29 · Tension · Channel rewrite tell
| | |
|---|---|
| **Diegetic read** | Standing Structure rewrites **one** channel the eye can name |
| **Sight** | Topology: walkable edge appears · Flow: sift path · Load: brace thicken · Pulse: brass beat stripe · Vent: air dump plume (dust, not fireball) |
| **Sound** | Channel-specific settle layer under J26 |
| **Timing** | Concurrent with seat→settle (≤400 ms tell) |
| **Must not** | Multi-channel fireworks on teach fields |
| **Signal** | `structure_channel_told(channel)` |

#### J30 · Tension · Anti-mash cool-down
| | |
|---|---|
| **Diegetic read** | Loom refuses spam — hands rest on the cloth |
| **Sight** | Commit affordance dulls; cursor mass rests |
| **Sound** | Silence (designed) |
| **Timing** | ≥350 ms after seat or collapse before next commit |
| **Must not** | Shorten cool-down “for juice” |
| **Signal** | `tension_ready` |

#### J31 · Tension · Cancel release
| | |
|---|---|
| **Diegetic read** | Abort before seat — fibers unpromise without shame |
| **Sight** | Ink promise fades to chalk; graph returns to Plan |
| **Sound** | Soft un-duck bed; no fail sting |
| **Timing** | ≤200 ms |
| **Must not** | Collapse tear VFX on cancel |
| **Signal** | `tension_cancelled` |

#### J32 · Tension · Second Structure scaffold nod
| | |
|---|---|
| **Diegetic read** | When a standing Scaffold enables Structure #2, the yard nods once |
| **Sight** | Load channel thicken on supporting Anchors; no level-up chrome |
| **Sound** | Low timber acknowledgment tick |
| **Timing** | ≤180 ms after enabling seat |
| **Must not** | Skill-tree unlock fanfare |
| **Signal** | — |

---

### 4.5 Stress / Collapse — J33–J38

#### J33 · Stress · Rust speck creep
| | |
|---|---|
| **Diegetic read** | Overload is felt **before** tear |
| **Sight** | Rust speck on Thread when stress ≥ ~70% for ≥0.4 s |
| **Sound** | Dry grit ≤ −18 dB under bed; optional slow pitch rise |
| **Timing** | Continuous while armed |
| **Must not** | First stress signal only at collapse |
| **Signal** | — |

#### J34 · Stress · Micro-vibrate cord
| | |
|---|---|
| **Diegetic read** | Hand feels the argument in the fiber |
| **Sight** | Line micro-vibrate ±0.5 px at 8–12 Hz near commit |
| **Sound** | Optional grit sync |
| **Timing** | While hovering commit with high stress |
| **Must not** | Screen shake spam |
| **Signal** | — |

#### J35 · Collapse · Culprit nominate
| | |
|---|---|
| **Diegetic read** | Failure points a finger — one seam named |
| **Sight** | Culprit Thread/Fragment highlights (rust → gap); rest of graph greys |
| **Sound** | Fiber tear onset |
| **Timing** | 0–80 ms |
| **Must not** | Red fullscreen flash with no named seam |
| **Signal** | `collapse_culprit(id)` |

#### J36 · Collapse · Culprit hold
| | |
|---|---|
| **Diegetic read** | Eyes learn *why* — comedy, not shame |
| **Sight** | Hold on culprit ~0.5 s |
| **Sound** | Tear → rest |
| **Timing** | 80–500 ms |
| **Must not** | “You died”; shame stamp |
| **Signal** | — |

#### J37 · Collapse · Refund rustle
| | |
|---|---|
| **Diegetic read** | Graph undoes; Fragments return to owned set — fair toy |
| **Sight** | Graph restores to pre-Tension; Fragments re-nest |
| **Sound** | Refund rustle |
| **Timing** | 500–900 ms |
| **Must not** | Inventory wipe; long blackout |
| **Signal** | `collapse_refunded` |

#### J38 · Collapse · Retry hunger
| | |
|---|---|
| **Diegetic read** | Adjust one Thread — stand again soon |
| **Sight** | Culprit fades; cursor free on graph |
| **Sound** | Shed hush returns; optional tiny invite scrape |
| **Timing** | Ready for re-Tension well inside ≤30 s player clock |
| **Must not** | Forced tip carousel; softlock |
| **Signal** | — |

---

### 4.6 Inhabit — J39–J43

#### J39 · Inhabit · Foot material plant
| | |
|---|---|
| **Diegetic read** | First step on your stitch proves authorship |
| **Sight** | Foot plant chalk/stamp on Structure material |
| **Sound** | Distinct footstep (timber / cloth / wire grate) — ~2–4 dB over yard dirt, shorter transient |
| **Timing** | First plant after seat unlock (0.0–0.3 s window) |
| **Must not** | Same footstep on dirt and span |
| **Signal** | `inhabit_first_plant(material)` |

#### J40 · Inhabit · Route dust path
| | |
|---|---|
| **Diegetic read** | Walking the Structure wears a quiet path — ledger of use |
| **Sight** | Faint chalk wear along walked Structure cells (no rarity trail) |
| **Sound** | Material footsteps continue |
| **Timing** | Accrues over inhabit |
| **Must not** | Combat afterimage trails; neon breadcrumbs |
| **Signal** | — |

#### J41 · Inhabit · Pulse gate tick
| | |
|---|---|
| **Diegetic read** | Authored beat opens/closes — craft metronome |
| **Sight** | Thin brass timing stripe on Gate / Loom-mark; bob tick |
| **Sound** | Dry beat; never rewind swoosh |
| **Timing** | On Pulse period while inhabiting |
| **Must not** | Purple chronomancy wash |
| **Signal** | — |

#### J42 · Inhabit · Goal world-answer
| | |
|---|---|
| **Diegetic read** | Field answers once — wind, dust path, light — then stamp arms |
| **Sight** | One environmental resolve (dust settle path / kiln quiet / gap bridged stillness) |
| **Sound** | Short major-lean resolve ≤1.0 s — workshop, not brass fanfare |
| **Timing** | On goal predicate true |
| **Must not** | Confetti piñata; battle-pass drip |
| **Signal** | `field_goal_true` |

#### J43 · Inhabit · Fray warn
| | |
|---|---|
| **Diegetic read** | Misuse frays the cloth — reinforce or abandon |
| **Sight** | Seam fuzz / thread hair along damaged edge |
| **Sound** | Dry fray whisper ≤ −20 dB |
| **Timing** | When Structure enters Fray state |
| **Must not** | HP bar; combat damage numbers |
| **Signal** | `structure_fray(id)` |

---

### 4.7 Residue / Yard — J44–J47

#### J44 · Residue · Cloth panel press
| | |
|---|---|
| **Diegetic read** | Your Structure presses into a panel — quiet pride |
| **Sight** | Cloth/paper panel presses into view or Yard wall |
| **Sound** | Pressed stamp |
| **Timing** | 0–120 ms |
| **Must not** | Loot chest open; rarity reveal |
| **Signal** | `residue_press_started` |

#### J45 · Residue · Silhouette hold
| | |
|---|---|
| **Diegetic read** | “I wove that” — mute-readable authorship silhouette |
| **Sight** | Silhouette of *your* Structure holds |
| **Sound** | Hungry interval — silence that wants the next gap |
| **Timing** | 120–400 ms |
| **Must not** | Brass fanfare; battle-pass drip |
| **Signal** | `residue_silhouette_held` |

#### J46 · Residue · Next-gap hunger
| | |
|---|---|
| **Diegetic read** | One next-session hook max — the tear wants stitching |
| **Sight** | Soft underline / spindle point toward next field affordance |
| **Sound** | Rising fourth → cut early (optional; never wall-to-wall music) |
| **Timing** | 400 ms+ |
| **Must not** | Shop CTA mid-pride; streak strip |
| **Signal** | — |

#### J47 · Yard · Folio page-turn
| | |
|---|---|
| **Diegetic read** | Leaving a field is turning a shed folio page — not a black loading void |
| **Sight** | Paper-turn / cloth fold transition; authorship silhouette may linger one beat |
| **Sound** | Page fiber turn |
| **Timing** | ≤600 ms transition |
| **Must not** | Cross-fade through black; portal swirl |
| **Signal** | `yard_page_turned` |

---

### 4.8 Shell / a11y / comedy — J48–J50

#### J48 · Shell · Title shed air
| | |
|---|---|
| **Diegetic read** | Menu is a yard folio, not a neon void lobby |
| **Sight** | Ambient Yard/loom plane; brand dominates; no EL maze chrome |
| **Sound** | Shed air / distant kiln / silence — no mystic void drone |
| **Timing** | Cold boot → first intentional input |
| **Must not** | Purple-void AI lobby; idle CTA pulse spam |
| **Signal** | — |

#### J49 · A11y · Reduce-motion hard cuts
| | |
|---|---|
| **Diegetic read** | Outcomes stay honest when motion is cut |
| **Sight** | Suck/flash/pulse/crease/lift collapse to ≤100 ms hard cuts; wisp spawn skipped; flash peak capped |
| **Sound** | Keep seat/snap/collapse identity hits |
| **Timing** | When `reduce_motion = true` |
| **Must not** | Hide outcome; rely on hue alone |
| **Signal** | — |

#### J50 · A11y · Greyscale verb distinct
| | |
|---|---|
| **Diegetic read** | Shape, not hue, sells Recover / Bind / Tension / Collapse |
| **Sight** | Suck wisps / press crease / cord width pulse / culprit gap remain distinct at sat=0 |
| **Sound** | Dual channel preserved |
| **Timing** | Continuous acceptance constraint |
| **Must not** | Purple or cadmium as sole differentiator |
| **Signal** | — |

---

## 5. Reduce-motion & flash policy

| Flag | Behavior |
|---|---|
| **Reduce motion** | J06/J17/J27 durations → hard cuts ≤100 ms; skip J24–J25 staging; keep J26 outcome + J35 culprit |
| **Reduce flash** | Cap J17 peak; skip optional ochre on J12; never full-viewport |
| **Mute Music** | Must **not** mute snap / seat / collapse (load literacy) |
| **Colorblind** | Port glyphs + silhouette grammar carry legality; copper is accent only |

---

## 6. Palette lock (juice jobs)

Source of truth for spike: `game/weaver/content/palette.json` via `WeaverPalette` ([`../35_JUICE.md`](../35_JUICE.md)). 1000× does not reopen the banlist.

| Swatch | Juice jobs |
|---|---|
| `chalk_dust` | J06 wisps · J10/J19 dust · J40 wear |
| `chalk_bright` | J17 press peak |
| `kiln_copper` | J27 crest · thin inhabit accents |
| `ink_seat` / `timber` | J26 seams · Fragment bodies · footsteps |
| `gap_void` | Frayed physical gap (torn cloth — not cosmos) |
| `--pulse-brass` / `--pulse-flash` | J12 · J41 only ([`../21_FRAGMENT_FEEL.md`](../21_FRAGMENT_FEEL.md)) |

---

## 7. Implementation map (feel → code)

Not a full tech design — fences for `game/weaver/` and future Lattice-host migrate:

| Cluster | Suggested API surface | Notes |
|---|---|---|
| Recover | `fragment_suck` · `recover_fail` · `shelf_nest_seated` | Deepen W1 suck; add fail + nest |
| Bind | `combine_flash` · `bind_snap_finished` · `bind_undo_finished` | Type earprints are audio layers |
| Tension | Seat state machine Arm→Crease→Lift→Seat→Settle + `weave_pulse` | Same masters for trailer and game ([`../23_WEAVE_VERB.md`](../23_WEAVE_VERB.md)) |
| Collapse | `collapse_culprit` → hold → `collapse_refunded` | Culprit from solver stress accumulator |
| Inhabit | Material footstep tag flips on `Stand` | Foot proof is a ship gate |
| Residue | `residue_press` phrase | Quiet; one hunger cue |

**Invariant:** reaction VFX advance on **wall-clock**. If Tension hitstop dips timescale, dust/crease keep moving.

---

## 8. Acceptance (1000× juice)

| Gate | Pass |
|---|---|
| **Count** | Exactly **50** specs J01–J50 present and verb-mapped |
| **Mute trailer** | 60–90 s silent capture still reads parts → line → place → walk |
| **Greyscale** | Recover / Bind flash / weave pulse / collapse culprit distinguishable by shape |
| **No purple** | No purple hex in juice scripts, palette swatches, or this doc’s allowed accents |
| **Flash budget** | Combine/press never covers full viewport |
| **Pulse on path** | Weave pulse is a property of the Thread polyline |
| **Foot proof** | First Structure step ≠ yard dirt |
| **Culprit speech** | On collapse, player names the failing seam without help |
| **Language ban** | Zero unexplained “satisfying / juicy / immersive / premium feel” claims |
| **EL untouched** | This PR is docs-only under `docs/WEAVER/1000X/` |

---

## 9. Relationship to other docs

| Doc | Relationship |
|---|---|
| [`../35_JUICE.md`](../35_JUICE.md) | W1 spike authority for three motions — **kept**; this doc expands the ledger |
| [`../23_WEAVE_VERB.md`](../23_WEAVE_VERB.md) | Body clocks win on micro-timing; this doc indexes juice IDs |
| [`09_AUDIO.md`](09_AUDIO.md) | Owns stems / buses / leitmotifs; this doc names when they fire |
| [`10_ART.md`](10_ART.md) | Owns materials / lighting; this doc consumes chalk/timber/copper grammar |
| [`12_UI.md`](12_UI.md) | Diegetic shell; J04 / J48 bridge |
| [`../PIVOT.md`](../PIVOT.md) | Weaver ≠ EL rewrite slam toy — different juice family |

---

## 10. Non-goals

- Implementing the fifty specs in Godot in this PR (**CLOUD ONLY** docs).  
- Sharing a juice autoload with `game/echo_lattice/`.  
- Combat juice kits, rarity VFX atlases, or chronomancy trails.  
- Replacing [`../35_JUICE.md`](../35_JUICE.md) — elevate by ledger, do not renumber the spike doc again.

---

## 11. Lock line

Fifty workshop beats. If a verb fires without a **J-id**, the feel is unauthorized. If a J-id needs purple, bloom, or a detached halo to read, the materials are wrong — rewrite the tell, not the banlist.
