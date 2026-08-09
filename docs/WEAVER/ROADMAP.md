# The Weaver — Roadmap

**Role:** Execution order after Master GDD v2 lock.  
**Authority peers:** [`MASTER_GDD.md`](MASTER_GDD.md) · [`17_MVP.md`](17_MVP.md) · [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) · [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) · [`18_RISKS.md`](18_RISKS.md) · [`PIVOT.md`](PIVOT.md) · [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md)  
**Hard rules:** Do not delete `game/echo_lattice/`. Do not invent AppIDs. Do not schedule Coming Soon before vertical-slice exit criteria. Migrate EL only via human-gated execute PR ([`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md)).

---

## 0. Now → next (one screen)

| Phase | Outcome | Done when | Status |
|---|---|---|---|
| **W0 Docs seal** | Master GDD v2 + `01`–`34` on integration line | This ROADMAP + MASTER v2 merged to RC1 | **In PR** (`cursor/weaver-master-v2`) |
| **W0.5 Scaffold** | `game/weaver/` Godot stub beside EL | Import + F5; placeholder recover→bind→tension | **Landed** |
| **W1 Spike** | Feel-proof Tension seat | [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) clear; still-test clip | **In progress** (loop #192 + juice #191 merged) |
| **W2 Vertical slice** | First-thirty spine | MVP §8 exit criteria 1–4 green | Not started |
| **W3 Demo pack** | Wishlistable build | Trailer still + demo CTA; no meta dump | Blocked |
| **W4 MVP 1.0 content** | 3–5 h Yard jobs | Caps in [`17_MVP.md`](17_MVP.md) §4 | Blocked |
| **W5 Store / Partner** | Separate Weaver pack | Only after W2/W3 gates — never mutate EL freeze paste | Blocked |

Echo Lattice Steam resume gates in [`../VISION/ROADMAP_EXECUTE.md`](../VISION/ROADMAP_EXECUTE.md) are **historical** unless a human reopens that product line.

---

## 0.1 Prototype scaffold status (2026-08-09)

| Item | State | Notes |
|---|---|---|
| Path | `game/weaver/` | Beside `game/echo_lattice/` — **both kept** |
| Engine | Godot **4.3** GDScript stub | [`game/weaver/project.godot`](../../game/weaver/project.godot) |
| Default scene | `scenes/main.tscn` (prototype loop) | Juice demo: `scenes/demo_field.tscn` |
| Loop | Void → recover Fragments → combine Brace Thread → seat Structure | [`game/weaver/README.md`](../../game/weaver/README.md) · screenshots under `docs/WEAVER/screenshots/` |
| Juice | Recover suck · Bind flash · Tension pulse | [`35_JUICE.md`](35_JUICE.md) · `scripts/juice/` |
| Sim fence | **2D placeholder** (not final G1 pick) | Pick 2D *or* constrained 3D before art ramp |
| Contracts | Python smokes for juice + loop | Expand determinism / softlock suite in W1 |
| Echo Lattice | Untouched | Migrate plan only — [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md) |

**Scaffold + juice ≠ cold spike pass.** W1 still owns first-five timing and mute still-test.

---

## 1. Gate table

| Gate | Name | Pass condition | Fail / park |
|---|---|---|---|
| **G0** | Vocab lock | MASTER glossary used in all new Weaver docs/PRs | Rewrite drifted nouns |
| **G1** | Sim fence | 2D **or** constrained 3D chosen; dual-stack killed | No art ramp |
| **G2** | Verb proof | Cold playtest: names Fragments / Threads / Structures without coach | Pedagogy redesign |
| **G3** | Slice thirty | First useful Structure ≤24:00; collapse fair | No demo date |
| **G4** | Identity | Mute still ≠ purple-void; audio seat phrase lands | Art/audio block |
| **G5** | Offline bar | Full loop Steam-disabled; local save | No Partner work |
| **G6** | Demo convert | Wishlist CTA after slice; trailer ≤15s mute-legible | No Coming Soon |
| **G7** | MVP ship | [`17_MVP.md`](17_MVP.md) §8 all true | Cut content, don’t add systems |
| **G8** | Adversarial | Kill-tests K1–K6 in [`34_ADVERSARIAL.md`](34_ADVERSARIAL.md) | No Coming Soon ask |

---

## 2. Workstream order

### W0 — Docs seal v2 (this wave)

- [x] Sibling packs `01`–`19` + `PIVOT` on RC1 (#172)  
- [x] Elevations `20`–`34` + `PRODUCT_IDENTITY` on remotes  
- [x] Merge into `cursor/weaver-master-v2`  
- [x] Write `MASTER_GDD.md` **v2** · this ROADMAP · `CHANGELOG_DESIGN.md` · index README  
- [x] Merge `game/weaver/` Godot MVP stub  
- [x] Merge prototype loop (#192) + juice spike (#191 → `35_JUICE.md`)  
- [ ] Land PR into `cursor/echo-lattice-rc1`  
- [ ] Follow-up: elevate `01_CONCEPT` + align `15_MARKET` / `14_TECH` stubs (see MASTER §11)

### W1 — Prototype spike (playable truth)

**Beat script:** [`32_FIRST_FIVE.md`](32_FIRST_FIVE.md) (Structure ≤3:40; clear ≤4:30).  
**Feel clocks:** [`23_WEAVE_VERB.md`](23_WEAVE_VERB.md) · [`21_FRAGMENT_FEEL.md`](21_FRAGMENT_FEEL.md).

| Task | Notes |
|---|---|
| Deepen `game/weaver/` beyond stub | Copy **patterns** from EL, not scenes; do not edit EL |
| Pick sim fence (G1) | Verlet/beam budget sheet day one |
| Implement six-beat loop on **one** field | Timed to first-five; no hub meta, no gallery yet |
| Fragment ×2 + Thread ×1 + Structure ×1 for spike | Prefer Anchor + Span + Brace |
| Collapse readability | Culprit highlight + undo tension |
| Python/GDScript contracts | Determinism + softlock smoke |

**Exit:** Internal clip of Tension seat that passes still test; cold clear inside five minutes per `32_FIRST_FIVE`.

### W2 — Vertical slice (first thirty)

Follow [`16_FIRST_THIRTY.md`](16_FIRST_THIRTY.md) spine:

1. Boot / Shed Yard brand  
2. Fragment literacy (3 materials)  
3. Thread literacy (slack / tension / cut)  
4. First job Structure (authorship ceremony)  
5. One world-answer residue  
6. Single next-session CTA  

Content caps: [`17_MVP.md`](17_MVP.md) vertical-slice row.  
Craft: [`09_VISUAL.md`](09_VISUAL.md) · [`25_VOID_ART_V2.md`](25_VOID_ART_V2.md) · [`10_AUDIO.md`](10_AUDIO.md) · [`26_AUDIO_V2.md`](26_AUDIO_V2.md).  
Discovery: [`22_DISCOVERY_UX.md`](22_DISCOVERY_UX.md). Ecology: [`24_STRUCTURE_ECOLOGY.md`](24_STRUCTURE_ECOLOGY.md).

### W3 — Demo

- Polish pass on tension readability (P5 risk)  
- Trailer / GIF pack (hands → thread → structure → consequence)  
- Demo build = slice + CTA; **no** economy/MP surfaces  
- Controller snap targets from day one (T3)  
- Adversarial K1–K6 green before Coming Soon ask

### W4 — MVP 1.0

| Track | Cap |
|---|---|
| Fragment families | ≤12 |
| Structure recipes | ≤20 |
| Jobs | 40–60 |
| Hub | Shed Yard + optional second corner |
| Legacy | Local gallery + ghosts; evolution per [`28_LEGACY_V2.md`](28_LEGACY_V2.md) post-slice |
| MP / trade | Still **out** |

Progression voice: [`11_PROGRESSION.md`](11_PROGRESSION.md). Economy law: [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md).

### W5 — Store (separate pack)

- New store copy / capsules / screenshots for Weaver only — draft in [`30_STEAM_PITCH.md`](30_STEAM_PITCH.md)  
- Price band $4.99–$8.99 (default $6.99) — [`13_MONETIZATION.md`](13_MONETIZATION.md)  
- Name legal check — [`31_NAME_LOCK.md`](31_NAME_LOCK.md)  
- Steam rename plan — [`PRODUCT_IDENTITY.md`](PRODUCT_IDENTITY.md)  
- **Never** paste EL Partner freeze as Weaver  
- AppIDs remain human-only placeholders until created  

### W6 — Archive migrate (separate PR, human-gated)

- Plan: [`33_MIGRATE_FROM_LATTICE.md`](33_MIGRATE_FROM_LATTICE.md)  
- **Not scheduled in this PR** — keep `game/echo_lattice/` until execute gates are green  

---

## 3. Explicit non-schedule (do not staff yet)

| Temptation | Earliest reconsider |
|---|---|
| Realtime co-op / servers | Post-G7 + human reopen per [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) (co-op only; no seamless competitive) |
| Seamless competitive / invade / rival PvP | **Never** for Weaver — killed in [`29_MULTIPLAYER_V2.md`](29_MULTIPLAYER_V2.md) |
| Player trade / stalls | Default **never**; see [`27_SOLO_ECONOMY_V2.md`](27_SOLO_ECONOMY_V2.md) |
| Second biome pack | Post-MVP, pick one expansion lane |
| Workshop / mods | After job quality proven |
| Echo Lattice Coming Soon resume | Only if EL product line explicitly reopened |
| `git mv` EL to archive | Only after migrate §6 gates + human ack |

---

## 4. Integration policy for agents

| Do | Do not |
|---|---|
| Target `docs/WEAVER/` + `game/weaver/` | Edit `game/echo_lattice/` “to save time” |
| Link MASTER v2 / PIVOT / PRODUCT_IDENTITY from new Weaver PRs | Invent a third product fantasy mid-wave |
| Keep MVP cuts when sibling docs fantasize post features | Merge player-trade or MP into slice milestones |
| Open PRs into active integration line (`cursor/echo-lattice-rc1`) | Delete BACKUP / RELEASE / EL trees |
| Merge juice into `game/weaver/` | Treat migrate plan as permission to move EL today |

---

## 5. Success snapshot

Weaver is on track when a stranger can watch a 20-second mute clip and say: **“They stitched parts into a bridge and had to walk it.”**  
Weaver is off track when docs multiply but no Tension seat feels fair, or when store language drifts back into maze-habit or purple time-magic.

---

## 6. Lock line

Docs v2 first, scaffold present, spike next, slice before demo, demo before Partner — and Echo Lattice stays frozen and present the whole way until a dedicated migrate PR.
