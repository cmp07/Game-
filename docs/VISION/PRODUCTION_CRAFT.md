# Production Craft — The “Real Game” Shell

**Status:** vision authority (CLOUD ONLY) · **Product:** Echo Lattice · **Date:** 2026-08-09  
**Audience:** anyone shipping the playable slice who wonders why it still feels like a prototype.  
**Companion docs:** [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) · [`../ECHO_LATTICE/06_AUDIO_BIBLE.md`](../ECHO_LATTICE/06_AUDIO_BIBLE.md) · [`../ECHO_LATTICE/07_JUICE.md`](../ECHO_LATTICE/07_JUICE.md) · [`../AUDIT/AUDIO_ART_UX.md`](../AUDIT/AUDIO_ART_UX.md) · [`../AUDIT/UPGRADE_LIST.md`](../AUDIT/UPGRADE_LIST.md) · [`../RELEASE/COMPLIANCE_FINAL.md`](../RELEASE/COMPLIANCE_FINAL.md)

---

## 0. Thesis

Players decide “this is a real game” in the **first ten seconds of boot** and every time the sim **stops**. Core loop juice (rewrite slam, telegraph, hitstop) sells the verb. **Shell craft** sells authorship.

Top small-team indies do not win that trust with more systems. They win it with a short, intentional list of shell beats that look *designed* rather than *defaulted*:

| Beat | What it signals |
|---|---|
| Boot splash | Someone owned the cold start |
| Title card | Brand is the product, not a label on a template |
| Transitions | Scenes are continuous fiction, not scene swaps |
| Pause | The world can rest without breaking |
| Fail / death / softlock recovery | Failure is authored, not an exception path |
| Settings as object | Options live in the same world as play |
| Credits | People made this; licenses are honest |

**Hard rule for Echo Lattice:** every shell beat obeys Field Ledger — paper, ink, rust, diegetic chrome. No frosted glass, no purple void, no generic Godot blue buttons, no fade-to-black as the only transition language.

**Non-goals:** new genres, combat death loops, horror stakes, live-service menus, achievement toast spam, “press any key” meme screens that fight the brand.

---

## 1. What top indies actually ship (study structure, not mechanics)

Use these as **craft references** — pacing, confidence, material honesty. Do not import their verbs.

| Reference | Shell lesson for us |
|---|---|
| **Celeste** | Pause is a first-class screen; death is fast, fair, and stylized; chapter cards teach place |
| **Outer Wilds** | Boot + title confidence; diegetic ship computer for “settings / log”; death is a loop beat, not a punish |
| **Baba Is You / Patrick’s Parabox** | Minimal chrome still feels finished; fail is undo-adjacent; title is typography |
| **Hades** | Every exit from play (death, pause, run end) is written and voiced; settings never feel like OS prefs |
| **Return of the Obra Dinn** | Single material language from boot through menus through end; credits feel like the book closing |
| **Papers, Please** | Menu *is* the desk; options are stamped paperwork, not a Windows dialog |
| **Vampire Survivors / short paid vignettes** | Boot → title → play in seconds; end card is a product moment (wishlist / restart) |

**Echo Lattice translation:** the shell is a **field notebook on a lightbox**. Cards turn. Stamps land. The lattice never becomes a glass overlay game.

---

## 2. Master checklist (ship signals)

Status keys against `cursor/echo-lattice-rc1` playable root `game/echo_lattice/`:

`[x]` present and on-vision · `[~]` scaffold / partial · `[ ]` missing or off-vision

### 2.1 Boot splash

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| B1 | Custom boot image (not Godot default robot) | `[ ]` `boot_splash/show_image=false` | Paper-bone field with ink mark or miniature punch-card; no logo soup |
| B2 | Boot bg color matches `paper_bone` / `ink_black` | `[ ]` | No bright grey flash before first frame |
| B3 | Splash duration short (≤ ~1.2 s perceived) or skippable | `[ ]` | Cold start never feels like a tech demo bumper |
| B4 | Optional PA / silence policy on first enter | `[~]` `pa.boot.lattice_online` cataloged | Induction stays silence-capable; boot chime is institutional, not cute |
| B5 | No `ui.click` / menu SFX before first intentional input | `[ ]` menu fires `ui.click` on `_ready` | Cold boot quiet except intentional title bed / PA policy |

**Field Ledger note:** splash is a **rubber stamp on blank stock**, not a cinematic logo animation.

### 2.2 Title card

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| T1 | Brand-first lockup dominates first viewport | `[~]` strong scaffold in `menu.gd` | Remove chrome labels → still obviously Echo Lattice |
| T2 | One composition: brand, one tagline, one CTA column, one ambient teaching visual | `[~]` | No stat strips, schedule blocks, or promo chips in hero |
| T3 | Tagline `IT LEARNED YOU` (or locked equivalent) secondary to brand | `[~]` | Headline never overpowers title |
| T4 | Diegetic teaching (seed + punch-card / ambient chalk) | `[~]` | First viewport sells the verb without a tutorial dump |
| T5 | Vendor display + mono fonts (not ThemeDB fallback alone) | `[ ]` | Matches art bible typography stack |
| T6 | Continue / Start / Daily / Settings / Quit focus chain + glyphs | `[x]` | Keyboard + gamepad; Deck glyphs when appropriate |
| T7 | Demo wishlist CTA gated, not always-on clutter | `[x]` `DemoBuild` | Present only when demo + real store URL |

**Upgrade map:** [`UPGRADE_LIST.md`](../AUDIT/UPGRADE_LIST.md) P2-01, P2-05.

### 2.3 Transitions

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| X1 | Menu ↔ chamber uses **paper turn / page slide**, not black fade | `[ ]` | Art bible §6 motion: “paper turns, never fades” |
| X2 | Chamber → chamber keeps continuous paper (no 1-frame black) | `[~]` | Act transitions update title/HUD without blanking ([`BUGBASH.md`](../RELEASE/BUGBASH.md)) |
| X3 | Won / end / daily results enter as a **loose ledger page** | `[~]` functional labels | Same underline index language as title card |
| X4 | Rewrite slam is the *in-play* transition spectacle; shell stays quieter | `[x]` juice path | Shell does not compete with origami slam |
| X5 | Steam rich presence updates on scene edges | `[~]` wired from `main.gd` | Presence copy matches current shell beat |
| X6 | Reduce-motion / flash gates respected on shell transitions | `[~]` a11y services exist | Paper turn has a cut alternative when motion reduced |

**Anti-pattern:** crossfade through pure black, modal dimmers, or “level loading…” spinner chrome.

### 2.4 Pause

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| P1 | Esc / Start / B opens a **pause card**, not an instant dump to main menu | `[ ]` `pause_menu` → `menu_requested` | Player can resume without losing chamber context |
| P2 | Tree paused (or sim gated) while card up; audio ducks per bible | `[~]` overlay pause only via Steam | Gameplay clock stops; Music/UI policy explicit |
| P3 | Pause card is index-card material (Resume / Restart / Settings / Menu) | `[ ]` | No glass `PanelContainer` look |
| P4 | Mid-rewrite slam: flush or block pause so Continue cannot softlock | `[~]` flush-on-leave exists | Documented; pause during lock is safe |
| P5 | Steam overlay open also pauses tree when feature flagged | `[x]` `SteamService` | Shift+Tab does not desync hitstop permanently |
| P6 | Focus loss policy chosen (pause vs keep running) and documented | `[ ]` | Adversarial QA notes `pause_on_focus_loss` unset |
| P7 | Glyph footer shows Resume binding; remap-aware | `[~]` remap exists | Matches `InputGlyphs` / ActionRemap |

**Craft bar:** Celeste-class — pause is a place you *are*, not a router away from the game.

### 2.5 Death / fail / recovery

Echo Lattice is not a combat-death game. “Fail” means **softlock, habit trap, give-up, or run end** — still needs authorship.

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| F1 | Restart chamber is first-class, bound, glyph’d | `[~]` restart action exists | ≤1 input from stuck; no OS-kill expectation |
| F2 | Undo is the primary micro-fail recovery | `[x]` | Taught on title + chamber hint |
| F3 | Softlock / assert path leaves a breadcrumb + recoverable UI | `[~]` `CrashLogHook` | Never silent grey screen |
| F4 | Give-up / return-to-checkpoint (if shipped) is a stamped choice on the pause card | `[ ]` | Wording is ledger (“retrace”), not “You Died” |
| F5 | Run / wing / daily end screen is a designed page | `[~]` `end_screen.gd` | Stamp numerals; brand present; demo wishlist rules |
| F6 | Fail copy avoids horror / permadeath language | `[~]` | Pure puzzle honesty; no fake stakes |
| F7 | Audio: fail/recover uses dry institutional cue, not cartoon sting | `[~]` placeholders | Matches audio bible; no brass “game over” |

**Product fence:** do not add a death loop to look “more game.” Author the recoveries you already have.

### 2.6 Settings as object

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| S1 | Settings is a **paper plate / index card**, not dim glass overlay | `[ ]` `settings_menu.tscn` PanelContainer | UPGRADE P2-02 |
| S2 | Open/close = paper turn (same language as title) | `[ ]` | Shared transition helper |
| S3 | Groups readable as ledger sections (Audio, Display, Accessibility, Controls, Language) | `[~]` | One job per section; no OS-settings dump |
| S4 | Remap + glyphs live on the same card | `[x]` / `[~]` | Full keyboard remap; Deck defaults preserved |
| S5 | A11y: colorblind, flash, motion, UI scale, bus mutes | `[~]` | Documented in [`ACCESSIBILITY.md`](../RELEASE/ACCESSIBILITY.md) |
| S6 | Telemetry opt-out present if retail default-on | `[ ]` compliance C7 | Local-only today; keep honest |
| S7 | Settings reachable from title **and** pause without losing place | `[~]` title only today | Pause → Settings → back to pause |
| S8 | Persist via `SettingsStore`; sane defaults on first boot | `[x]` | Corrupt/missing file recovers |

**Craft bar:** Outer Wilds ship computer / Papers Please desk — options are **in-fiction equipment**, not a borrowed ImGui theme.

### 2.7 Credits

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| C1 | Menu → Credits first-class entry | `[ ]` | Compliance C11 |
| C2 | In-game copy matches [`COMPLIANCE_FINAL.md`](../RELEASE/COMPLIANCE_FINAL.md) §4.5 draft | `[ ]` | Studio, Godot MIT, fonts OFL, audio honesty |
| C3 | Placeholder audio labeled as procedural until final mix | `[ ]` | Never marketed as licensed library music (C9) |
| C4 | Scroll/page turn works with gamepad; B/Start exits | `[ ]` | Same input grammar as pause |
| C5 | Depot `THIRD_PARTY_NOTICES.txt` + Godot COPYRIGHT beside Windows build | `[ ]` C10 | Credits screen ≠ license depot (ship both) |
| C6 | Credits visual = closing the ledger (quiet, paper, no parade) | `[ ]` | Brand mark once; no emoji; no purple |

### 2.8 Adjacent “real game” signals (same craft budget)

These are not the headline list, but reviewers feel their absence.

| # | Check | RC1 | Acceptance |
|---|---|---|---|
| A1 | Window title + taskbar / `.ico` identity | `[~]` name set; final `.ico` open | Reads at 32×32 (rust infecting grid) |
| A2 | First-run locale / device glyph correctness | `[~]` | No wrong “Press A” on keyboard-only boot |
| A3 | Quit confirm only if progress would be lost mid-chamber | `[ ]` optional | Prefer silent save + clean quit |
| A4 | Act / chamber title sting (short printed card) | `[~]` | Diagrammatic; no cinematic letterbox |
| A5 | Volume / mute respects OS and in-game buses | `[~]` bus layout live | UI bus separate from SFX |
| A6 | Controllers hot-plug; focus not lost forever | `[~]` | Re-grab focus on pause/title |
| A7 | Demo end is a product beat (wishlist), not a stub | `[~]` | Copy locked in `end_screen` + DEMO_SPEC |

---

## 3. Player journey map (shell only)

```
[OS launch]
    → Boot splash (stamp)          B1–B5
    → Title card                   T1–T7
    → Paper turn into chamber      X1
    → Play (slam = in-world craft)
         ↳ Pause card              P1–P7
         ↳ Settings object         S1–S8
         ↳ Fail / restart / undo   F1–F7
    → Won / end ledger page        X3, F5, A7
    → Credits (from title)         C1–C6
    → Quit
```

If any arrow is a hard cut to an unstyled Control scene, the journey fails the craft bar even when the maze is excellent.

---

## 4. Material & motion contracts (shell)

Pulled forward from the art bible so shell work cannot “temporarily” violate them.

| Contract | Rule |
|---|---|
| Substrate | `paper_bone` / `paper_deep` — never pure white, never void |
| Ink | `ink_black` / `ink_soft` — never pure `#000` panels |
| Accent | `rust_fossil` for selection; `slate_teal` for info — **anti-purple** |
| Corners | ≤ 2 px radius; prefer square stamp edges |
| Panels | No blur, no drop shadow, no translucent glass |
| Buttons | Underlined type; rust underline = focus; slate = hover |
| Motion | Paper turn / stamp; **nothing pulses or breathes** |
| Type | One display, one body, one mono — no fourth font |
| Sound | Soft UI ticks; PA institutional; Induction silence respected |

Shared implementation intent (when code lands): one `ShellTransition` helper + one `IndexCard` chrome theme used by title, pause, settings, credits, won/end.

---

## 5. Priority for Next Fest / 1.0 trust

Ordered by **player trust per unit of work**, not by systems novelty.

| Priority | Beat | Why |
|---|---|---|
| **P0** | Pause card (P1–P4) | Esc-to-main-menu reads as unfinished on every reviewer machine |
| **P0** | Boot splash + quiet cold start (B1–B5) | First seconds set “prototype vs product” |
| **P0** | Settings as index-card (S1–S2, S7) | Current glass overlay breaks Field Ledger the moment someone opens Options |
| **P1** | Paper-turn transitions (X1–X3) | Connects the strong title card to the strong chamber |
| **P1** | Credits surface (C1–C3) | Compliance gate + authorship signal |
| **P1** | End / won ledger restyle (F5, X3) | Demo wishlist moment must look like the title card’s sibling |
| **P2** | Fail copy + focus-loss policy (F4, F6, P6) | Edge trust; adversarial QA |
| **P2** | Icons / act cards / quit polish (A1, A4, A3) | Finish the perimeter |

Loop juice and store trailers remain critical — they are covered elsewhere. This doc owns the **shell**.

---

## 6. Acceptance playtest (15 minutes)

Run on a clean save, keyboard then gamepad:

1. Launch from desktop — **no Godot robot**, no grey flash, no click before input.  
2. Title card: brand test (cover the button column — still Echo Lattice).  
3. Start → chamber via paper turn.  
4. Esc — **pause card**, Resume returns mid-chamber; Open Settings and return to pause.  
5. Soft-fail: fill buffer poorly → Undo / Restart from pause without main-menu exile.  
6. Finish a chamber → won page matches materials.  
7. Menu → Credits → scroll → exit.  
8. Quit; relaunch → Continue works; boot still quiet.

If step 4 or 5 fails, the build still feels like a vertical slice no matter how good the slam is.

---

## 7. RC1 gap summary

| Beat | Verdict |
|---|---|
| Title card | **Strong scaffold** — fonts + motion still open |
| Transitions | **Off-vision** — functional scene swaps; paper-turn language not shell-wide |
| Pause | **Missing as craft** — input exists; behavior is leave-to-menu |
| Death / fail | **Partial** — undo/restart/end exist; not authored as a fail suite |
| Settings as object | **Wrong material** — feature-complete a11y under glass chrome |
| Credits | **Missing** — copy drafted in compliance only |
| Boot splash | **Missing** — splash disabled |

**Bottom line:** the playable loop already argues for a real game. The shell still argues for a build. Close the seven beats above before calling the slice “reviewer-ready.”

---

## 8. Doc ownership

| Doc | Owns |
|---|---|
| **This file** | Shell craft checklist + acceptance |
| `05_ART_BIBLE.md` | Materials, type, motion law |
| `06_AUDIO_BIBLE.md` | Buses, PA, silence, UI ticks |
| `07_JUICE.md` | In-play feel (not shell) |
| `AUDIO_ART_UX.md` / `UPGRADE_LIST.md` | Audit status + implementation backlog IDs |
| `COMPLIANCE_FINAL.md` | Credits legal copy + C1–C12 |
| `ACCESSIBILITY.md` | Settings content requirements |
| `STEAMWORKS.md` | Overlay pause / presence |

When shell code ships, update §2 checkboxes here and tick matching rows in `UPGRADE_LIST.md` (P2-02, P2-04, P2-05, plus new pause/boot items as they are filed).
)
