# The Weaver — 10 · Audio Craft

**Doc:** `docs/WEAVER/10_AUDIO.md`  
**Status:** Craft authority (CLOUD ONLY) · **Branch:** `cursor/weaver-craft`  
**Product:** **The Weaver** (north star)  
**Job:** Define the earprint of void-weave craft — fiber tension, timber knock, kiln hush — so audio sells Fragments / Threads / Structures without synth-trailer or purple-mystic pads.  
**Peers:** [`02_CORE_LOOP.md`](02_CORE_LOOP.md) · [`03_FRAGMENTS.md`](03_FRAGMENTS.md) · [`04_THREADS.md`](04_THREADS.md) · [`05_STRUCTURES.md`](05_STRUCTURES.md) · [`09_VISUAL.md`](09_VISUAL.md) · [`11_PROGRESSION.md`](11_PROGRESSION.md) · [`14_TECH.md`](14_TECH.md) · [`PIVOT.md`](PIVOT.md)  
**Leitmotif identity (v2):** [`26_AUDIO_V2.md`](26_AUDIO_V2.md) — Fragment Atom · Thread Stitch · Structure Cloth

---

## 0. Thesis

Sound is how players **feel load** before they read a number. Slack, taut, snap, and seat must be audible sentences. If the game looks like a shed loom but sounds like cosmic pads and UI candy, the fantasy collapses.

**One-line brief:** _Workshop hush, fiber scrape, timber seat — silence between stitches. No choir. No chronomancy chimes._

**Weaver rule:** visual Tension stages and audio seat phrase are **one sentence**. Progression never celebrates unlocks with slot-machine jingles.

---

## 1. Hard ban — slop ear

| Banned | Replace with |
|---|---|
| Epic orchestra / choir / “destiny” brass | Dry workshop bed or true hush |
| Cute UI blips, coin jingles, rarity fanfares | Soft fiber brush, wood tick, stamp |
| Horror risers, jumpscare stingers | Honest snap + short rest |
| Magic whoosh / shimmer / aether pads | Crease → seat; dust fall |
| Time-rewind swooshes, hourglass shakes | Pendulum *tick* only as Pulse Fragment tell |
| Speech / VO / robot quips | Diegetic craft lines on-screen ([`04_THREADS.md`](04_THREADS.md) §7) |
| Wall-to-wall music under Survey teach | Authored silence / HVAC shed tone |

**Anti-purple-void audio:** no mystic void drone under menus. Title bed = shed air / distant kiln / silence.

---

## 2. Sonic material dictionary

| Visual / system | Sonic material |
|---|---|
| Page / cloth substrate | Soft fiber brush, cloth damp |
| Chalk provisional Thread | Dry chalk scrape, low friction |
| Taut seated seam | Waxed cord pull → settled tick |
| Timber Span / Anchor | Soft wood knock; mass on seat |
| Wire / thin brace | Higher metallic filament |
| Channel flow | Sparse liquid / dust sift (never hose-loop spam) |
| Charge / kiln | Low warm body; vent as air dump |
| Pulse / pendulum | Dry beat — clockwork craft, not magic time |
| Illegal snap | Short white transient + rest |
| Collapse tear | Fiber tear → culprit hold → refund rustle |
| Residue stamp | Pressed cloth / paper stamp |

---

## 3. Bus sketch (MVP)

Godot buses ([`14_TECH.md`](14_TECH.md)); keep tiny:

| Bus | Role |
|---|---|
| **Master** | Final / mute-all |
| **SFX** | Recover, draw, snap, seat, collapse, inhabit footsteps |
| **Music** | Optional shed bed; default quiet or off in early teaches |
| **UI** | Menu / pause ticks — never before first intentional input |

Rules:

1. Every player sets `bus` explicitly.  
2. Mute Music must **not** mute snap/seat/collapse (load literacy stays).  
3. No Master FX soup for MVP.  
4. Cold boot quiet except intentional title policy.

---

## 4. Signature phrase — Tension seat

Align to visual crease → lift → seat ([`09_VISUAL.md`](09_VISUAL.md) §5 · [`05_STRUCTURES.md`](05_STRUCTURES.md) §8).

| Stage | Sonic job | Silence job |
|---|---|---|
| **Draw** (pre) | Fiber scrape; pitch rises with span stress | Leave bed almost untouched |
| **Crease** | Cloth gather / multi-fiber rustle | Micro-gaps — not noise wall |
| **Lift** | Soft mass inhale (air, not whoosh library) | One breath of hush |
| **Seat** | Wood/cord downbeat — loudest honest hit | No layering under the hit |
| **Settle** | Dust fall / stitch lock; Structure “is law” | Tail into shed tone or silence |
| **Fail path** | Snap or tear → rest → refund rustle | Never mask the culprit |

Players should clap or hum the seat after three hearings. Trailer and in-game share masters.

**Reduce-motion:** drop stages wholesale; do not ugly-stretch.

---

## 5. Loop beat voice

| Core beat ([`02_CORE_LOOP.md`](02_CORE_LOOP.md)) | Audio craft |
|---|---|
| **Survey** | Near silence; wind/dust only if it teaches fray |
| **Recover** | Soft pick / unstick; inventory stays quiet |
| **Bind** | Draw scrape; illegal = snap + glyph (no error buzzer cartoon) |
| **Tension** | Seat phrase (§4) |
| **Inhabit** | Footsteps change on Structure material; Pulse gates tick |
| **Residue** | Stamp + open hungry interval toward next job — addiction without brass |

---

## 6. Fragment / Thread tells (ear literacy)

| Event | Ear |
|---|---|
| Port mismatch | Snap white + different rest length than overload |
| Overload approach | Rust creep = dry grit along cord; optional slow pitch rise |
| Feed starve / burst | Thin hiss vs sudden dump — still workshop, not sci-fi |
| Echo desync | Chatter ticks that resolve when beat aligns |
| Pulse impose | Pendulum body — readable tempo, never rewind swoosh |

Mastery is hearing **which** Thread failed — not a VO coach.

**Motif expansion:** family consonants, Thread contours, and Structure archetype endings live in [`26_AUDIO_V2.md`](26_AUDIO_V2.md).

---

## 7. Mode / progression voice

Support [`11_PROGRESSION.md`](11_PROGRESSION.md) without live-service ear:

| Beat | Audio |
|---|---|
| Job clear | Seat settle → quiet stamp → open interval |
| Recipe / material unlock | Single stamp tick — **not** level-up fanfare |
| Gallery / ghost browse | Paper turn hush |
| Daily / shared seed (if shipped) | Same grammar as campaign; institutional date-tick optional |
| Collapse comedy | Allow humor in tear timing; never laugh-track |

---

## 8. Acceptance listening (~12 min)

1. Boot → title hush; no chirp spam.  
2. First illegal bind: snap teaches without rage buzzers.  
3. Successful Tension: clap the seat phrase; visual lock-step.  
4. Collapse: culprit audible + visible together.  
5. Music muted: draw / seat / snap still teach load.  
6. No choir, no chronoswoosh, no rarity jingle.

---

## 9. Non-goals

- Middleware adaptive suites for MVP.  
- Licensed trailer libraries as identity.  
- Echo Lattice PA / rewrite catalog reuse as Weaver earprint (different product).  
- Asset authorship in this PR — **CLOUD ONLY**.
