# The Weaver — 26 · Audio v2 (Leitmotifs)

**Doc:** `docs/WEAVER/26_AUDIO_V2.md`  
**Status:** Identity lock (CLOUD ONLY) · **Branch:** `cursor/weaver-audio-v2`  
**Product:** **The Weaver** (north star)  
**Job:** Make Fragments, Threads, and Structures **audibly distinct motifs** — not louder versions of the same fiber scrape — while keeping workshop hush from [`10_AUDIO.md`](10_AUDIO.md).  
**Peers:** [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`04_THREADS.md`](04_THREADS.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`09_VISUAL.md`](09_VISUAL.md) · [`10_AUDIO.md`](10_AUDIO.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) · [`MASTER_GDD.md`](MASTER_GDD.md) · [`PIVOT.md`](PIVOT.md)

**Relationship to craft audio:** [`10_AUDIO.md`](10_AUDIO.md) owns buses, bans, Tension seat phrase, and loop-beat voice. **This doc owns leitmotif grammar** — how the three system nouns state and transform musical cells. When identity and wiring conflict, **v2 leitmotifs win on identity**; **10 wins on buses / mute law / seat staging** until an implementation PR updates both.

---

## 0. Why AUDIO v2 exists

`10_AUDIO` shipped the **earprint contract**: workshop hush, fiber scrape, timber seat, silence between stitches. That is enough to reject choir / chronoswoosh / rarity jingles. It is **not** enough to make the three verbs *sound like different craft acts*.

Without leitmotifs, Recover / Bind / Tension collapse into one “fiber kit” with different volumes. Players then need glyphs and VO to know what failed. Weaver mastery is hearing **which** Fragment family, **which** Thread type, and **which** Structure archetype spoke.

| Layer | Owner | Ship gate |
|---|---|---|
| Buses, bans, seat phrase, mute law | [`10_AUDIO.md`](10_AUDIO.md) | Vertical-slice earprint |
| Fragment / Thread / Structure leitmotifs | **This doc** | Authored motif cells before trailer / demo audio |
| Asset authorship | Future `game/weaver/audio/**` | Not this PR — **CLOUD ONLY** |

**One-line brief:** _Three craft cells — Atom, Stitch, Cloth — stated sparsely, varied by family / type / archetype, resolved only at seat. No choir. No Ledger Cell reuse._

**Weaver rule:** visual silhouette families and audio motif families are **one literacy**. If a greyscale still can name the family, headphones should too.

---

## 1. Three pillars (non-negotiable)

Any cue that fails two pillars goes back.

### P1 · Fragment is an Atom cell

Each Fragment family owns a **short consonant** (1–2 notes or a single material hit with a fixed envelope). Recover states the consonant. Inventory stays quiet. Port hover may whisper the consonant once — never a menu of fanfares.

### P2 · Thread is a Stitch contour

Each Thread type owns a **draw contour** (pitch path + friction quality). Slack chalk vs taut ink is the same contour at different tension — not two unrelated SFX. Illegal snap is a **contour cut**, not an error buzzer.

### P3 · Structure is a Cloth cadence

A standing Structure answers Atom + Stitch with a **cadence** that rhymes the Tension seat phrase ([`10_AUDIO.md`](10_AUDIO.md) §4). Archetypes vary the cadence ending; the shared grammar (crease → lift → seat → settle) never changes.

**Silence remains a tool** (from 10): authored rests inside draw, snap, and seat. Motifs never fill every millisecond.

---

## 2. Motif cells (normative contours)

Composer may retune pitch; **contour and material job** are normative. Tuning home = dry prepared plate / muted timber — never lush triad pads.

### 2.1 Atom cell — Fragments

Working name: **Atom Cell**.

```
gesture:     pick → body → micro-rest
scale hint:  1      →  (optional) 5♭ or open 5
register:    family-colored (see §3)
```

| Job | Spec |
|---|---|
| Recover | Full Atom consonant once |
| Seat into Structure | Atom consonant reappears as a **partial** inside seat settle |
| Collapse refund | Soft reverse rustle of the same consonant (no “loot return” jingle) |
| Ban | Rarity arpeggios, collectible sparkle packs, chronoshard chimes |

### 2.2 Stitch contour — Threads

Working name: **Stitch Contour**.

```
gesture:     contact scrape → span travel → port kiss (or snap cut)
tension:     slack = breathy / incomplete; taut = waxed / settled tick
```

| Job | Spec |
|---|---|
| Provisional chalk draw | Contour at low friction; ends open |
| Legal commit (pre-Tension) | Contour completes with soft port kiss |
| Illegal bind | Contour shears mid-travel; rest length encodes failure class (§5) |
| Overload approach | Contour gains dry grit; pitch creep optional, never siren |

### 2.3 Cloth cadence — Structures

Working name: **Cloth Cadence**.

Aligns to visual crease → lift → seat ([`09_VISUAL.md`](09_VISUAL.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) §8):

| Stage | Motif job |
|---|---|
| Draw (pre) | Dominant Stitch contours stack sparsely — still readable as separate fibers |
| Crease | Atom consonants of seated Fragments flicker as paper-fiber cascade |
| Lift | Shared air inhale (not whoosh library) |
| Seat | Shared timber/cord downbeat — loudest honest hit |
| Settle | **Archetype ending** (§4) lands into shed tone or silence |
| Fail | Snap/tear → rest → refund Atom rustle — no cadence completion |

Players should clap the seat after three hearings; trailer and in-game share masters (same law as 10).

---

## 3. Fragment leitmotifs (family consonants)

Six MVP families ([`03_FRAGMENTS.md`](03_FRAGMENTS.md) §3). Each owns **material + interval color**. Greyscale silhouette and ear literacy must agree.

| Family | Material consonant | Interval / envelope color | Recover tell |
|---|---|---|---|
| **Span** | Soft cloth strip / plank fiber | Open fifth, longer decay | Horizontal brush |
| **Anchor** | Peg / stake wood knock | Low perfect 1, short decay | Mass tick into ground |
| **Channel** | Hollow trough / duct air | Narrow hiss band → soft drip tick | Directed whisper |
| **Charge** | Spring / kiln-heart body | Warm low body + held pressure | Stored hum (≤200 ms), then rest |
| **Filter** | Sieve / baffle tick-stop | Bright cut-off (high → mute) | Refuse click |
| **Pulse** | Pendulum / knocker beat | Dry clockcraft 1–2; readable tempo | Beat body — **never** rewind swoosh |

### Capacity tiers (S/M/L)

Same consonant; **body weight** only (louder fundamental, longer tail). Never new melody per tier. Never rarity rainbow.

### Port literacy (optional whisper)

| Port class | Ear hint |
|---|---|
| `brace` / `ground` | Wood / cord body |
| `in` / `out` / `release` | Directed air or liquid sift |
| `sense` / `beat` | Dry tick / pendulum |

Port mismatch uses **Thread snap** (§5), not a Fragment fanfare.

---

## 4. Thread leitmotifs (type contours)

Four MVP types ([`04_THREADS.md`](04_THREADS.md) §2).

| Type | Contour character | Legal end | Failure ear |
|---|---|---|---|
| **Brace** | Waxed cord pull; mass in the middle | Settled wood tick | Overload tear (fiber split) |
| **Feed** | Directed flow scrape (dust / charge path) | Soft arrival kiss at `in` | Starve = thin hiss fade; burst = sudden dump |
| **Oppose** | Reverse / vent scrape (outward breath) | Air dump settle | Blowback = dump returns at player |
| **Echo** | Sparse copied ticks; no mass transfer | Alignment resolve | Desync chatter that locks when beat matches |

### Slack → taut (one contour)

| Visual ([`04_THREADS.md`](04_THREADS.md) §4) | Audio |
|---|---|
| Slack fiber (dashed chalk) | Contour incomplete; chalk dry; gaps audible |
| Taut ink | Contour completes; waxed body; settled tick |
| Rust creep | Grit along the **same** contour — not a new theme |

Mastery is hearing **which** Thread failed — not a coach VO ([`10_AUDIO.md`](10_AUDIO.md) §6).

---

## 5. Failure grammar (rest as ID)

Snap / tear must be distinguishable by **rest length + transient**, not by cartoon buzzers.

| Failure class | Transient | Rest after | Motif note |
|---|---|---|---|
| Port mismatch | Short white shear | **Longer** rest (~180–250 ms) | Contour cut before port kiss |
| Overload tear | Fiber split + grit | Medium rest (~120–160 ms) | Brace/Feed body was present |
| Starve | Thin hiss collapse | Soft open interval | Feed contour never arrives |
| Burst / blowback | Sudden dump | Short rest then Oppose vent color | Charge / Oppose consonant flashes |
| Echo desync | Chatter ticks | Resolves into Pulse Atom tempo | No rewind language |
| Collapse (Structure) | Tear → culprit hold | Hold ≥ seat downbeat gap | Cadence aborts; refund Atom rustle |

---

## 6. Structure leitmotifs (archetype endings)

Shared Cloth Cadence grammar (§2.3). Archetypes ([`05_STRUCTURES.md`](05_STRUCTURES.md) §4) own **settle endings only** — stages 1–4 stay shared so the seat remains clap-able.

| Archetype | Primary channel | Settle ending (motif) |
|---|---|---|
| **Span** | Topology | Horizontal fifth lands; dust fall along the bridge line |
| **Culvert** | Flow | Soft liquid sift resolves into dry path hush |
| **Kiln** | Vent / Charge | Warm body dump + copper tick; vent air, not explosion |
| **Gate** | Pulse | Pendulum downbeat locks open/close; tempo readable |
| **Scaffold** | Load | Stacked low wood knocks (accretion); invites second Tension |
| **Loom-mark** | Residue | Pressed cloth stamp — same family as Residue beat in 10 §5 |

Multi-channel mastery Structures may **layer two endings** at −6 to −9 dB under the primary — never a third unrelated theme.

### Inhabit voice

Footsteps / interactables inherit the standing archetype’s material (timber on Span, trough damp on Culvert, kiln warmth near Charge). Pulse gates tick the Atom Pulse consonant. No combat hit fanfares.

---

## 7. Loop map — when cells speak

| Core beat ([`02_CORE_LOOP.md`](02_CORE_LOOP.md)) | Leitmotif duty |
|---|---|
| **Survey** | Near silence; optional fray dust only if it teaches the gap |
| **Recover** | Atom Cell per Fragment; inventory mute |
| **Bind** | Stitch Contour per Thread; snap = §5 |
| **Tension** | Cloth Cadence; archetype ending on success |
| **Inhabit** | Archetype material bed under player verbs; Pulse tempo if authored |
| **Residue** | Loom-mark stamp + hungry open interval — addiction without brass |

Progression stamps ([`11_PROGRESSION.md`](11_PROGRESSION.md)) reuse Residue / Loom-mark ticks — **never** level-up fanfare.

---

## 8. Anti-bleed from Echo Lattice

Weaver borrows craft lessons; it does **not** inherit Field Ledger earprint.

| Echo Lattice | Weaver AUDIO v2 |
|---|---|
| Ledger Cell (1→5→♭2→1') habit motif | Atom / Stitch / Cloth craft cells |
| Operator rewrite slam endings | Structure archetype settle endings |
| Diegetic transit PA | Shed hush / kiln vent only — no institutional two-tone board |
| Habit intensity L0–L3 stems | Optional shed bed; default quiet in early teaches ([`10_AUDIO.md`](10_AUDIO.md) §3) |
| `game/echo_lattice/audio/**` reuse as identity | Forbidden as Weaver earprint |

Placeholder DSP from EL tools may inform wiring patterns later; **masters and motif contours must be authored for Weaver**.

---

## 9. Implementation sketch (future — not this PR)

CLOUD ONLY now. When `game/weaver/` spikes:

| Piece | Sketch |
|---|---|
| Catalog | `audio/events/weaver_audio_events.json` — IDs for `fragment.<family>.recover`, `thread.<type>.draw|snap`, `structure.<archetype>.seat`, shared seat stages |
| Director | Thin facade (pattern from EL `AudioDirector`, new scripts under `game/weaver/`) |
| Buses | Master / SFX / Music / UI per [`10_AUDIO.md`](10_AUDIO.md) §3 — no PA bus required for MVP |
| Phrase vs oneshots | Prefer staged oneshots fired on seat phases **or** one streamed cadence per archetype; listener experience must be one phrase |
| Reduce-motion | Drop Cloth Cadence stages wholesale at boundaries — never chipmunk stretch |
| Validation | Sibling of `tools/audio/validate_audio_events.py` when catalog lands |

Deterministic demo captures: no generative MIDI that breaks seed replay.

---

## 10. Acceptance listening (~15 min)

1. Recover six families blindfolded: stranger names ≥4 correctly from consonant alone.  
2. Draw Brace vs Feed vs Echo: contours distinguishable; mute Music still teaches.  
3. Illegal port vs overload: rest lengths feel different without UI.  
4. Seat a Span then a Gate: shared clap-able seat; endings differ.  
5. Collapse: cadence aborts; culprit + refund Atom audible with visual hold.  
6. No choir, chronoswoosh, rarity jingle, transit PA, or Ledger Cell contour.  
7. Trailer cut uses the same Atom / Stitch / Cloth masters as in-game.

---

## 11. Non-goals

- Middleware adaptive suites / generative score for MVP.  
- Licensed trailer libraries as identity.  
- Echo Lattice catalog reuse as Weaver earprint.  
- VO coach lines (diegetic on-screen copy only — [`04_THREADS.md`](04_THREADS.md) §7).  
- Asset authorship or Godot wiring in this PR — **CLOUD ONLY**.

---

## 12. Lock line

**Atom, Stitch, Cloth** — Fragment consonants, Thread contours, Structure cadences — are how The Weaver teaches load without words. Seat remains the signature phrase; leitmotifs make the three craft nouns audible as separate literacy.
