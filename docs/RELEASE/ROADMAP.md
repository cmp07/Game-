# Echo Lattice — Update & DLC Roadmap

**Rule:** nothing in this document expands **1.0** scope.  
1.0 ships the four-act campaign, Daily Challenge (90-day calendar + catalog fallback), Museum of Selves (archive + ghost race as in META v2), local crash packs, and Support FAQ. Everything below is **post-launch**.

Companions: [`POSTLAUNCH.md`](POSTLAUNCH.md) · [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md) · [`../ECHO_LATTICE/05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md) · META v2 Museum (`15_META_V2.md` on meta branch).

---

## 1. 1.0 scope fence (do not reopen)

**In 1.0**

- Acts I–IV campaign + hard variants already authored.
- Daily Challenge with pre-authored 90-day UTC calendar.
- Stars, streaks, achievements (milestone-only), NG+ hooks as implemented.
- Museum of Selves: archive clears, browse, race a self — **no cosmetic shop**.
- Local telemetry + local crash/log export.
- Windows Steam build; EN UI.

**Explicitly out of 1.0**

- Act V chambers / new transforms.
- Museum cosmetics (frames, pedestals, plaque inks).
- Cosmetic microtransactions or gacha (Art Bible hard ban).
- Battle pass, cloud leaderboards, Workshop editor.
- Full VO, full localization, cross-run online ghosts.
- Mandatory telemetry upload.

If a launch bug seems to “need” Act V content, **it doesn’t** — ship a hotfix or Week-1 patch inside the fence.

---

## 2. Free updates (post-1.0)

Shipped as depot patches, not DLC packages.

| Update | Contents | Notes |
|---|---|---|
| **1.0.x** | Hotfixes / Week-1 | See Postlaunch |
| **Free Update #1 — Ledger Polish** | QoL, accessibility, controller glyphs, calendar days 90–180 generator, FAQ refresh | No new act |
| **Free Update #2 — Museum Exhibits** | Better Museum browser, exhibit filters (archetype / act), export self plaque image | Still no paid cosmetics |
| **Free Update #3 — Daily Yearpack tooling** | Authoring tools + next 90-day calendar drop | Content ops, not new campaign |

Cadence is “when ready,” not a live-ops season clock. Prefer quiet weeks over forced drops.

---

## 3. Paid DLC (optional, post-1.0)

Price band stays inside the studio plan (**≈ $0.99–$10** total product + DLC). DLC must not gate 1.0 endings.

### 3.1 DLC A — **Act V: Afterimage** (new act)

| Field | Plan |
|---|---|
| Pitch | A fifth wing that teaches one **new** compose-forward rewrite idea without invalidating Acts I–IV identity portraits |
| Content | ~8–10 chambers + 1 boss identity + 1–2 hard variants; `acts.json` gains `afterimage` |
| Systems | At most **one** new transform **or** a strict compose rule over existing ops — no engine rewrite |
| Meta | New Museum titles/archetype lines; Daily catalog gains Act V–eligible seeds after free calendar tooling |
| Does not include | New game mode, online, cosmetics shop |

Acceptance sketch: campaign clear of 1.0 unchanged; Act V unlocks from Mastery clear or explicit DLC gate; saves migrate with `unlocks.chambers` only.

### 3.2 DLC B — **Museum Cosmetics: Plaque & Pedestal**

| Field | Plan |
|---|---|
| Pitch | Earnable / DLC **presentation** for selves you already archived — the lattice colors the exhibit, not a player avatar |
| Contents | Pedestal kits, ink plaque frames, palette paper backs (Field Ledger / Cyanotype / Newsprint / Slate — Art Bible packs) |
| Grant model | **Buy-to-own DLC unlock** + optional in-save earn from milestones — **no gacha, no paid random, no MX** |
| Compatibility | Cosmetics are Museum UI + plaque export only; never change solvability or stars |
| 1.0 relationship | Base Museum remains fully usable without DLC |

Aligns with Art Bible: “No cosmetic microtransactions” / “No character customization.” These are **exhibit skins**, not character skins.

### 3.3 Explicitly rejected DLC ideas

- Season pass that dribbles chambers weekly.
- Lootboxes for frames.
- Pay-to-skip chambers.
- Cross-promo skins from other titles.
- “Act V Early” that splits the community save format unnecessarily — ship Act V as one coherent pack.

---

## 4. Sequencing (technical, not calendar dates)

```
1.0 ship → Week-1 (1.0.1) → Free Update #1 (polish)
     → Free Update #2 (Museum browser)
     → DLC B (Museum cosmetics) and/or DLC A (Act V)
     → Free Update #3 (next 90-day calendar)
```

Prefer **Museum cosmetics after** Museum browser polish so DLC has a surface worth buying. Act V can proceed in parallel on a content branch without blocking cosmetics.

---

## 5. Save & depot policy

- DLC content lives in optional Godot packs / Steam DLC depots; base app runs without them.
- Save `version` migrations stay backward compatible; unknown cosmetic ids ignored.
- Daily friend codes remain comparable across owners; DLC chambers only appear in Daily when the calendar day points at them **and** the player owns Act V (others get a documented fallback chamber from 1.0 catalog).

---

## 6. Communication

- Steam page: 1.0 description never lists Act V as included.
- Postlaunch community scripts defer roadmap questions to this doc.
- Patch notes use the “Not in this patch” section rather than silent scope creep.
