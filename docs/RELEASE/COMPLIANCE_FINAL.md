# Echo Lattice — Final Compliance Pack (Ship)

**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4.3+ (Windows desktop Steam `.exe`)  
**Doc:** `docs/RELEASE/COMPLIANCE_FINAL.md`  
**Status:** Draft answers for Partner / store submission — fill AppID / legal entity names before publish  
**Gate A paste pack:** [`legal/`](legal/) — Content Survey, AI disclosure, hostable privacy page, ratings notes  
**Companions:** [`docs/ECHO_LATTICE/08_STEAM_CHECKLIST.md`](../ECHO_LATTICE/08_STEAM_CHECKLIST.md) (when merged), [`14_BALANCE_V2.md`](../ECHO_LATTICE/14_BALANCE_V2.md) (local telemetry), [`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) (fonts)

Use this file for the full compliance pack (survey rationale, credits, depot notices, C1–C12). For **Partner paste**, prefer [`legal/STEAM_CONTENT_SURVEY.md`](legal/STEAM_CONTENT_SURVEY.md), [`legal/AI_DISCLOSURE.md`](legal/AI_DISCLOSURE.md), [`legal/PRIVACY_POLICY.md`](legal/PRIVACY_POLICY.md), and [`legal/RATINGS_NOTES.md`](legal/RATINGS_NOTES.md). Answers match the **shipping puzzle product** (habit→geometry labyrinth), not the older tension/horror research lane in `GAME_PLAN.md`. **Do not invent an AppID.**

---

## 0. Product facts that drive every answer

| Fact | Ship truth |
|---|---|
| Genre | Single-player 2D puzzle / labyrinth |
| Combat | **None** — no weapons, HP, damage, or enemies |
| Violence depiction | **None** — abstract chalk/paper lattice; walls rewrite from the player’s path |
| Online features (v1) | **None** — no multiplayer, chat, UGC upload, or live services |
| Generative AI (player-facing) | **None** — deterministic authored chambers + offline rewrite rules |
| Telemetry | **Local JSONL only** under `user://telemetry/` — no network upload |
| Language | English + Simplified Chinese (`zh_Hans`) UI/copy; no profanity |
| Substances / sexual content / gambling | **None** |

---

## 1. Steam Content Survey — draft answers

**Paste-ready Partner copy:** [`legal/STEAM_CONTENT_SURVEY.md`](legal/STEAM_CONTENT_SURVEY.md) · AI section: [`legal/AI_DISCLOSURE.md`](legal/AI_DISCLOSURE.md).

Steamworks → App Admin → **Content Survey** (General / Mature / Generative AI).  
Valve compares these answers to the build and store page. Do not invent mature content “to be safe.”

### 1.1 General Content

Finishing this section drives the **automatic regional rating estimates** on the store page. Answer from actual playable content.

| Topic (typical survey phrasing) | Draft answer | Rationale |
|---|---|---|
| Violence / depictions of violence | **None / No** | No combat, injury, death animations, or hostile creatures |
| Blood / gore | **None / No** | Palette is paper / ink / rust accent — rust is habit fossilization, not blood |
| Sexual content / nudity | **None / No** | Abstract surveyor stamp + geometry only |
| Adult only sexual content | **No** | N/A |
| Language / profanity | **None / No** | Chamber captions + PA tones; no swear words |
| Alcohol / tobacco / drugs | **None / No** | Not present |
| Gambling / real-money wagering | **None / No** | Stars/par are skill metrics, not gambling |
| Horror / fear / jump scares | **None / Mild at most — prefer None** | Cold transit-PA atmosphere; not a horror product. Do **not** market as horror on the store page |
| Online interaction / user-generated content | **No** | Single-player; local saves + optional daily seed (deterministic, not UGC hosting) |
| In-game purchases / loot boxes | **No** | Paid upfront SKU; no IAP |
| Controllable characters committing crime | **No** | Walking a maze / rewriting geometry |
| Discrimination / extreme content | **No** | |

**General free-text (if asked for a short content description):**

> Echo Lattice is a single-player abstract puzzle game. The player walks grid chambers; checkpoints turn the walked path into walls via authored geometric transforms (mirror, rotate, thicken). There is no combat, violence, sexual content, or online play.

### 1.2 Mature Content

| Disclosure | Draft |
|---|---|
| Any mature content players may encounter? | **No** |
| Violence (any depiction)? | **No** |
| Sexual content? | **No** |
| Other adult content in uploaded builds (including unused assets)? | **No** — keep depot free of unused mature scratch assets |

If a future build adds gore/horror skins or VO, **re-open the survey with Steam Support** before shipping that build (surveys lock after release approval).

### 1.3 Generative Artificial Intelligence Content

Steam’s focus (2026 clarification): **player-consumed** AI content (art, sound, narrative, localization, etc.), **not** IDE/copilot efficiency tools.

| Question | Draft answer |
|---|---|
| Does this product use generative AI to create content consumed by players (pre-generated or live-generated)? | **No** |
| Pre-Generated AI content in the ship build? | **No** |
| Live-Generated AI during gameplay? | **No** |
| Runtime LLM / cloud model / chatbot? | **No** — forbidden for v1 |

**What we are *not* disclosing as generative AI**

| System | Why it is out of scope |
|---|---|
| Habit buffer → rewrite operators | Offline deterministic rules / scoring (`LocalTelemetry`, `HabitArchetype`, `RewriteEngine`) — not a generative model |
| Chamber content | Hand-authored JSON mazes under `game/echo_lattice/content/` |
| Placeholder SFX/music | Procedural DSP tones from `tools/audio/generate_echo_lattice_placeholders.py` (math synthesis), not a generative model service |
| Placeholder art | Deterministic Pillow scripts + palette JSON |
| Code assistants used while coding | Dev efficiency tools — Steam explicitly says this is **not** the focus of the AI section |

**If marketing assets later use an image/audio model**

1. Disclose **only** that store/trailer artwork path under Pre-Generated, with a clear note that **gameplay does not use generative AI**.  
2. Do **not** retcon gameplay systems as “AI dungeon.” Store tags stay Puzzle / Minimalist / Singleplayer (see Steam checklist).  
3. Until that happens, keep the survey answer **No**.

**Suggested Steam questionnaire blurb if forced to explain “adaptive” systems:**

> The game adapts geometry using deterministic, offline rules based on the player’s recent moves. No generative AI models are used to create art, audio, text, or levels at runtime or in the shipping content pipeline.

---

## 2. ESRB / PEGI / IARC expectation

**Paste-ready ratings notes:** [`legal/RATINGS_NOTES.md`](legal/RATINGS_NOTES.md).

Echo Lattice is an **Everyone-ish abstract puzzle**. Expect automatic IARC-style outcomes in that band when the Content Survey is answered as above. Official board certificates are optional for Steam PC if you rely on Steam’s questionnaire-derived ratings; obtain formal ratings only if a platform/region requires them.

| Board | Expected rating | Content descriptors |
|---|---|---|
| **ESRB** | **E (Everyone)** | None expected (no Mild Violence — there is no violence). Alternate: some abstract titles list no descriptors. |
| **PEGI** | **PEGI 3** | Suitable for all ages; no violence, fear, or bad language flags |
| **USK** | **USK 0** | No impairment of development |
| **CERO** | **A** (all ages) | If ever required |
| **GRAC / others** | All-ages equivalent | Follow local questionnaire |

**Not expected:** ESRB T, PEGI 12/16, horror fear descriptors, blood, language.

**Store page consistency checks**

- [ ] Capsules/screenshots show puzzle geometry only (no fake combat key art)  
- [ ] Short description does not call the game horror or AI-powered  
- [ ] Trailers match E/PEGI 3 tone  
- [ ] Content Survey answers match the build Valve will play  

**Age gate:** none required for the puzzle SKU.

---

## 3. Privacy policy stub (local telemetry)

Telemetry **exists**: `LocalTelemetry` appends JSON Lines to  
`user://telemetry/echo_lattice_balance.jsonl`  
(see `game/echo_lattice/scripts/local_telemetry.gd`, `config/balance_v2.json` → `telemetry`).

| Property | Ship contract |
|---|---|
| Network upload | **None** — disk only |
| PII | **`include_pii: false`** — no account IDs, emails, or real names |
| Events | Gameplay balance hooks only (`run_start`, `chamber_clear`, `softlock_assert_failed`, etc.) |
| Opt-out | Settings may disable (`enabled` flag / `enabled_default`); ship UI toggle before 1.0 if default stays on |
| Steam Cloud | Optional later for **saves** only — do **not** sync telemetry JSONL to Cloud |

Because any on-device logging can still be described as “data collection,” publish a short privacy URL on the Steam store (Partner → Edit Store Page → Legal). **Hostable page (preferred):** [`legal/PRIVACY_POLICY.md`](legal/PRIVACY_POLICY.md). Inline stub below matches that page.

### 3.1 Paste-ready privacy policy (stub)

> **Privacy Policy — Echo Lattice**  
> **Last updated:** 2026-08-09  
> **Contact:** `[LEGAL_CONTACT_EMAIL]` · Publisher: `[LEGAL_ENTITY_NAME]`
>
> **Summary.** Echo Lattice is a single-player offline puzzle game. We do not operate online accounts for the game, and the game does not upload gameplay analytics to our servers.
>
> **Data stored on your device.** The game may write: (1) save progress and settings under the Godot user data folder; (2) optional local balance telemetry as an append-only log (`telemetry/echo_lattice_balance.jsonl`) containing chamber IDs, seeds, move counts, star ratings, and similar gameplay metrics. This log is intended for offline tuning. It does not include your name, email, or Steam account identifier.
>
> **Steam.** If you play through Steam, Valve may collect data under the [Steam Privacy Policy](https://store.steampowered.com/privacy_agreement/). Achievements or Steam Cloud (if enabled later) are provided by Steam and governed by Valve’s terms.
>
> **No selling of data.** We do not sell personal information. The shipping game build does not include third-party ad or analytics SDKs.
>
> **Your choices.** You may delete local saves and telemetry by removing the game’s user data folder, or disable local telemetry in Settings when that toggle is present. Uninstalling the game removes the install directory; user data may remain until deleted manually.
>
> **Children.** The game is suitable for a general audience and does not knowingly collect personal information from children.
>
> **Changes.** We will update this policy if we add network telemetry, accounts, or Cloud sync of analytics. Material changes will be noted by date above and on the Steam store page.
>
> **Contact.** Privacy questions: `[LEGAL_CONTACT_EMAIL]`.

**Ship checklist**

- [ ] Replace `[LEGAL_*]` placeholders  
- [ ] Host stub on a stable HTTPS URL (GitHub Pages / studio site) **or** paste into Steam’s privacy field if Partner allows inline text  
- [ ] Link from Steam store Legal section before release review  
- [ ] Confirm retail build never opens sockets for telemetry  
- [ ] Exclude `user://telemetry/**` from Steam Cloud path rules if Cloud is enabled for saves  

---

## 4. Credits & licenses (fonts / audio / engine)

Ship a readable credits surface (menu → Credits) **and** keep license texts next to the Windows depot (`LICENSE.txt` / `THIRD_PARTY_NOTICES.txt`). Replace placeholders when final typefaces land.

### 4.1 Engine & runtime

| Component | License | Obligation |
|---|---|---|
| **Godot Engine** | MIT | Include Godot copyright + MIT text in depot notices |
| **Godot third-party** | Mixed (see Godot `COPYRIGHT.txt`) | Ship Godot’s aggregated copyright file for the export template you use |
| Echo Lattice game code & authored chambers | `[STUDIO_LICENSE — default All Rights Reserved]` | Studio copyright notice on store + credits |

### 4.2 Fonts

Art bible stack ([`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) § Typography):

| Role | Intended face | MVP / current | License to ship |
|---|---|---|---|
| Display | Akkurat **or** Inter Tight / IBM Plex Sans Condensed | Godot default **Inter** fallback | **Inter:** SIL Open Font License 1.1 — include OFL text + reserve name notice |
| Body | IBM Plex Serif or PT Serif | **Noto Serif** fallback (if embedded) | **Noto / IBM Plex / PT Serif:** SIL OFL 1.1 |
| Mono | IBM Plex Mono | System / Godot default mono until embedded | SIL OFL 1.1 when embedded |

**Hard rule:** **Akkurat is commercial** — do **not** embed or redistribute Akkurat files without a purchased license. Prefer IBM Plex / Inter Tight for Steam ship unless Akkurat is licensed.

**Credits line (fonts):**

> Fonts: Inter / Inter Tight © The Inter Project Authors (SIL OFL 1.1).  
> IBM Plex® © IBM Corp. (SIL OFL 1.1) — when embedded.  
> Noto Serif © Google Inc. (SIL OFL 1.1) — when embedded.  
> Noto Sans SC © Adobe / Google (SIL OFL 1.1) — when embedded for `zh_Hans` (`fonts/cjk/OFL.txt`).  
> PT Serif © ParaType (SIL OFL 1.1) — when embedded.

Bundle `OFL.txt` beside each embedded `.ttf`/`.otf` in the repo (e.g. `game/echo_lattice/art/fonts/`) before locking the store build.

### 4.3 Audio

| Asset class | Path / tool | License / credit |
|---|---|---|
| Placeholder SFX, PA tones, win fanfare, L0–L3 beds | `game/echo_lattice/audio/**` via `tools/audio/generate_echo_lattice_placeholders.py` | **Original procedural synthesis** for this project — credit “Echo Lattice audio placeholders (procedural)” until replaced |
| Final music / SFX (when commissioned or bought) | Replace same paths | Credit composer/library + license (e.g. proprietary buyout, CC0, Audionautix, etc.) in the table below |
| Voice-over | **None in v1** — PA is tonal only (`06_AUDIO_BIBLE.md`) | N/A |

**Credits line (audio, current placeholders):**

> Audio: procedural placeholders generated for Echo Lattice (tools/audio) — temporary ship identity; replace before marketing “final mix.”  
> No third-party sample libraries are embedded in the placeholder set.

**Final-audio credit table (fill when assets land)**

| Track / bank | Author | License | URL / invoice |
|---|---|---|---|
| _(TBD)_ | | | |

### 4.4 Art & other third parties

| Asset | Source | License |
|---|---|---|
| Palette + placeholder tiles / UI / capsule thumbs | `game/echo_lattice/art/generate_placeholders.py` | Original to project |
| Steam capsule final key art | _(TBD human-authored)_ | Studio / contractor agreement |
| Third-party textures/samples | **None in tree today** | Add row before merge if any are introduced |

### 4.5 In-game Credits screen copy (draft)

```text
ECHO LATTICE

Design, code, content
[STUDIO_OR_AUTHOR]

Engine
Godot Engine — © Juan Linietsky, Ariel Manzur, and contributors (MIT)

Fonts
[list embedded faces + SIL OFL]

Audio
[composer or “Procedural placeholders — Echo Lattice”]

Legal
Privacy: [PRIVACY_POLICY_URL]
```

---

## 5. Store / legal checklist (final gate)

| # | Item | Owner | Done |
|---|---|---|---|
| C1 | Content Survey General = all-ages puzzle answers above | Partner admin | [ ] |
| C2 | Mature Content = none | Partner admin | [ ] |
| C3 | Generative AI = No / No pre / No live | Partner admin | [ ] |
| C4 | ESRB E / PEGI 3 expectation matches capsules & trailer | Store | [ ] |
| C5 | Privacy policy stub published + linked on Steam | Legal | [ ] |
| C6 | Local telemetry has no network path (code review) | Eng | [ ] |
| C7 | Telemetry opt-out in Settings (if default on for retail) | Eng | [ ] |
| C8 | Font files licensed; OFL texts in depot | Art | [ ] |
| C9 | Audio credits updated for final mix; placeholders not marketed as licensed library music | Audio | [ ] |
| C10 | `THIRD_PARTY_NOTICES.txt` (+ Godot COPYRIGHT) in Windows depot | Release | [ ] |
| C11 | In-game Credits screen wired | Eng | [ ] |
| C12 | No AppID `480` / no secrets in retail depot | Release | [ ] |

---

## 6. Document history

| Date | Change |
|---|---|
| 2026-08-09 | Initial final-compliance pack: Steam Content Survey drafts, E/PEGI 3 expectation, privacy stub for local telemetry, font/audio credits. |
| 2026-08-09 | Linked Gate A Partner paste pack under [`legal/`](legal/) (survey, AI disclosure, privacy page, ratings notes). |
