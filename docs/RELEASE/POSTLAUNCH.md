# Echo Lattice — Post-Launch Ops

**Product:** Echo Lattice (Godot 4.3 / Steam desktop)  
**Audience:** solo / tiny studio ops during launch week  
**Companions:** [`CRASH_LOG_HOOK.md`](CRASH_LOG_HOOK.md) · [`ROADMAP.md`](ROADMAP.md) · [`SUPPORT_FAQ.md`](SUPPORT_FAQ.md) · [`../ECHO_LATTICE/04_CONTENT_BIBLE.md`](../ECHO_LATTICE/04_CONTENT_BIBLE.md)

This is the runbook. Keep 1.0 frozen except for stability, save safety, and daily calendar integrity.

---

## 0. Roles (tiny studio)

| Role | Owner hat | Primary channel |
|---|---|---|
| Build / hotfix | Engineer | Steam depots + Git tag |
| Content / daily | Designer | `content/daily/calendar_90.json` |
| Community | Same person wearing a different hat | Steam forums, Discord, Twitter/X |
| Support triage | Same | `SUPPORT_FAQ.md` + crash packs |

Rule: **one person may wear multiple hats; never ship two hotfix tracks at once.**

---

## 1. Day 0 — Hotfix plan (launch day + 24h)

### 1.1 Pre-flight (T−6h → T−0)

- [ ] Steam build published to **default** branch; previous build kept as rollback depot.
- [ ] `python3 game/echo_lattice/tests/test_release_liveops.py` green.
- [ ] `python3 game/echo_lattice/tests/validate_chambers.py` green.
- [ ] Confirm today's UTC daily resolves from `calendar_90.json` (not a surprise catalog miss).
- [ ] Crash log path verified on a clean Windows profile: `%APPDATA%/Godot/app_userdata/<app>/logs/`.
- [ ] Support inbox / Steam discussions watched; Discord `#release` pinned with FAQ link.
- [ ] Freeze feature work. Only severity **S0/S1** ships on Day 0.

### 1.2 Severity ladder

| Sev | Definition | Action window | Example |
|---|---|---|---|
| **S0** | Unbootable / wipe-progress / wrong daily for everyone | Hotfix in **≤4h** or rollback | Save corruption; black screen on boot |
| **S1** | Softlock / crash loop in campaign or daily | Hotfix same day | Checkpoint rewrite traps player; crash on Act III enter |
| **S2** | Wrong stars / audio mute / UI layout | Week-1 patch | Star formula off-by-one; PA missing one line |
| **S3** | Polish / wishlist | Backlog / free update | Museum pedestals, new palette frames |

### 1.3 Day-0 triage loop (repeat every 2h while awake)

1. Pull Steam reviews + discussions + Discord + crash packs (see crash hook).
2. Classify top 3 reports against the severity ladder.
3. Reproduce on the shipping build hash (write the hash in the incident note).
4. Decide: **hotfix**, **rollback**, or **acknowledge + Week-1**.
5. Post a short status (template §3.1) even if “investigating”.

### 1.4 Hotfix contents (allowed on Day 0)

Allowed:

- Null guards, save migration fixes, crash-on-boot.
- Daily calendar typo (wrong `chamber_id` / variation that breaks solvability).
- Input / fullscreen / vsync regressions that block play.
- Localization string that blocks a menu (EN only for 1.0).

Forbidden on Day 0 (scope creep):

- New chambers, Act V, cosmetics UI, Steam Cloud, online boards.
- Balance retunes that change star cutoffs mid-daily week.
- “While we’re here” juice / art.

### 1.5 Rollback criteria

Roll back the Steam build if **any** of:

- >5% of active sessions fail to reach the main menu (from crash packs / forum volume).
- Save wipe confirmed on more than one machine.
- Daily challenge unsolvable for the UTC day and a content hotfix cannot land in <4h.

Tag rollback: `release/1.0.0-rollback-<n>`. Keep the bad build for forensics.

### 1.6 Day-0 checklist (end of first 24h)

- [ ] Incident log filled (even if quiet): top reports, sev, disposition.
- [ ] One public “we’re watching” post.
- [ ] Candidate Week-1 patch list seeded (see §2).
- [ ] Confirm Day+1 calendar entry still valid after any seed hotfix.

---

## 2. Week-1 patch (Day 2–7)

### 2.1 Goals

Ship **one** numbered patch (`1.0.1`) that players feel: “studio is awake.” Prefer a short list that closes the loudest S1/S2 items.

### 2.2 Patch candidate bucket (fill during Day 0)

| ID | Symptom | Sev | Owner | In 1.0.1? |
|---|---|---|---|---|
| W1-01 | | | | ☐ |
| W1-02 | | | | ☐ |
| W1-03 | | | | ☐ |
| W1-04 | Controller glyphs / remap gaps | S2 | | ☐ |
| W1-05 | Reduce-motion misses one slam | S2 | | ☐ |
| W1-06 | Daily calendar Day N softlock | S1 | | ☐ |

Cap: **≤6** player-facing fixes. Overflow → `1.0.2` or free update track in [`ROADMAP.md`](ROADMAP.md).

### 2.3 Week-1 cadence

| Day | Focus |
|---|---|
| D1 | Triage only; hotfix if S0/S1 |
| D2 | Reproduce + fix branch `hotfix/1.0.1` |
| D3 | Internal play of campaign Act I–II + 3 dailies |
| D4 | Build to Steam **beta** branch `patch-week1` |
| D5 | Community beta volunteers (Discord); watch crash packs |
| D6 | Promote to default if no S0/S1; else slip 24h |
| D7 | Patch notes + thank-you; open wishlist for free update #1 |

### 2.4 Patch notes skeleton

```
Echo Lattice 1.0.1 — Week One

Stability
- …

Daily Challenge
- …

Quality of life
- …

Not in this patch (still planned as free updates / DLC — see roadmap)
- Act V, Museum cosmetics frames
```

Never promise dates inside patch notes unless the binary is already on the beta branch.

---

## 3. Community responses

Tone: calm Field Ledger voice — paper, ink, no corporate cheer. Short. Never argue reviews.

### 3.1 Day-0 status (Steam / Discord)

> **Launch watch.** We’re online and reading reports. If the game won’t boot or a save looks wrong, use Options → Support → Export crash pack (or grab `%APPDATA%/Godot/app_userdata/.../logs/`) and reply here with your build id. Daily Challenge uses UTC — today’s chamber is listed on the Daily card.

### 3.2 Known issue acknowledge

> **Known issue:** [one sentence]. Workaround: [one sentence or “none yet”]. Fix target: Day-0 hotfix / Week-1 patch / next free update. Thanks for the clear repro.

### 3.3 “Game too hard / softlock” (design vs bug)

> Softlocks are bugs — please send chamber id + friend code (`EL-#####`) + a crash/log pack if it hard-crashed. If the chamber is solvable but brutal, that’s on us for Week-1 balance notes; stars never gate progress.

### 3.4 Review reply (positive)

> Thank you — glad the rewrites clicked. If you clear Daily, the friend code on the card is shareable offline.

### 3.5 Review reply (negative, actionable)

> Sorry this missed. If you can share OS + build id + whether it was Campaign or Daily, we’ll chase it for the Week-1 patch.

### 3.6 Review reply (negative, taste / length)

> Heard. Echo Lattice is a short vignette by design; Museum of Selves and Daily are the return loop. Appreciate you trying it.

### 3.7 Do-not-say list

- No “skill issue.”
- No arguing Steam refund policy in public (point to Steam Support).
- No promising Act V / cosmetics ship dates on Day 0.
- No “AI-generated” jokes about the game’s systems.
- No posting other players’ crash packs publicly (PII / paths).

### 3.8 Channels

| Channel | Use |
|---|---|
| Steam News | Patch notes, known issues |
| Steam Discussions | Bug thread + FAQ sticky |
| Discord | Fast triage; mirror decisions to Steam |
| Email (support) | Save recovery, refunds redirect, crash packs |

Sticky the FAQ: [`SUPPORT_FAQ.md`](SUPPORT_FAQ.md).

---

## 4. Daily calendar during launch week

- Source of truth: `game/echo_lattice/content/daily/calendar_90.json`.
- Runtime: `DailyCalendar.pick_for_date(date)` → calendar hit, else catalog hash fallback (`DailySeeds`).
- **Never** edit today’s entry after 00:00 UTC on that day (friend-code integrity). Fix forward: amend tomorrow + patch notes.
- Hard / boss days are pre-marked in the calendar (`tag`); community posts may tease weekend “portrait” days only.

---

## 5. Metrics that matter (offline-first)

From local crash packs + Steam: boot failures, softlock reports, refund reasons, Daily clear mentions.  
From optional opt-in upload (off by default): crash signature histogram only — see crash hook doc.  
**Not** Day-0 goals: DAU charts, battle-pass style retention hacks.

---

## 6. Exit criteria — “launch week closed”

- [ ] No open S0.
- [ ] `1.0.1` shipped or explicitly deferred with public reason.
- [ ] FAQ updated with real launch questions.
- [ ] Roadmap still fenced (Act V + Museum cosmetics remain post-1.0).
- [ ] Incident log archived under `docs/RELEASE/incidents/` (create when first real incident lands).
