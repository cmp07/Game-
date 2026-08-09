# Echo Lattice — Support FAQ

Copy-paste source for Steam Discussions sticky, Discord `#faq`, and email replies.  
Keep answers short; link deeper docs only when needed.

**Build id:** shown in Options → Support (also written into crash packs).  
**Logs folder (Windows):** `%APPDATA%\Godot\app_userdata\Echo Lattice\logs\`  
(Exact app folder name follows the Godot `config/name` / Steam install; if missing, search `app_userdata` for `echo_lattice`.)

---

## A. Install / launch

### A1. The game won’t start / black screen

1. Verify Steam files.
2. Update GPU drivers; try windowed mode via launch option `--windowed` if offered.
3. Export a crash pack (Options → Support) or zip the `logs` folder and post the **build id** + OS.
4. If it never reaches the menu, say so — that is severity S0 for us.

### A2. Wrong language / missing text

1.0 ships **English** and **Simplified Chinese** (`zh_Hans`). Settings → Language can force English, Simplified Chinese, or System. OS locale should not softlock menus; if it does, send a crash pack. Missing Han glyphs usually mean the CJK font was not fetched for that build (`tools/fonts/fetch_noto_sans_sc.py`).

### A3. Steam Deck / controller

Keyboard/mouse is the authority path for 1.0. Controllers often work via Steam Input; full glyph maps are a Week-1 / free-update item. Remap in Steam if a face button is wrong.

---

## B. Saves & progress

### B1. Where is my save?

Local: `user://save.json` under the Godot userdata folder (see path above). Cloud sync is **not** in 1.0.

### B2. Progress disappeared after an update

1. Check for `save.json.bak` next to the save and restore by renaming (quit the game first).
2. Send us `save.json` **and** `save.json.bak` heads (or a crash pack with redacted save head).
3. Do not edit chamber unlock arrays by hand unless we ask.

### B3. Can I reset?

Options → erase save (wording may be “Wipe Field Notes”). This clears Museum selves, stars, and streaks. Export a crash pack first if you are reporting a bug.

---

## C. Daily Challenge

### C1. Why is my Daily different from a friend’s?

Dailies use **UTC date**, not local midnight. After 00:00 UTC the chamber rolls. Compare the **friend code** (`EL-#####`) on the Daily card — same code means same challenge.

### C2. I only get one attempt?

Yes for the recorded daily streak / outcome. You can still practice in Campaign. Streaks are soft; a miss does not delete prior Museum selves.

### C3. Today’s Daily feels broken / softlocked

That is a bug, not a skill gate. Note friend code + chamber title, export crash pack, post in the bug thread. We do **not** change today’s calendar entry after UTC midnight; fixes go forward + hotfix if launch-critical.

### C4. What is the 90-day calendar?

Launch ships a pre-authored UTC calendar (`calendar_90.json`) so weekends/hard portrait days are intentional. After day 90, the game falls back to the seed catalog hash until the next free calendar drop.

---

## D. Gameplay & difficulty

### D1. Stars?

1–3★ from path length vs par. Stars never gate campaign progress. Deaths do not write stars.

### D2. I softlocked the maze

Try Rewind / Reset from the stall options. If Reset still cannot reach the goal, send chamber id + description — solvability bugs are hotfix candidates.

### D3. What is the Museum of Selves?

Clears archive a compact “self” (habit fossil). You can browse and ghost-race prior selves. Cosmetic frames/pedestals are **post-1.0 DLC**, not required for Museum use.

### D4. Is there DLC / Act V?

Not inside 1.0. See [`ROADMAP.md`](ROADMAP.md): Act V and Museum cosmetics are planned **after** launch polish, without microtransactions.

---

## E. Performance & accessibility

### E1. Screen shake / motion

Options: reduce motion, toggle shake. Rewrite slam should respect reduce-motion; if a slam still strobes, report as Week-1 QoL.

### E2. Low FPS

Lower resolution / disable shake; the game targets integrated GPUs. Include GPU model in reports.

### E3. No sound

Check master / SFX / music sliders and OS mixer. Adaptive music is quiet by design in places (silence director).

---

## F. Crash packs & privacy

### F1. How do I send logs?

Options → Support → **Export crash pack**, or zip the `logs` folder. Attach build id. Avoid posting full `save.json` publicly if it contains a display name you care about — packs redact profile name when exported through the game.

### F2. Are you uploading my data?

**No**, not by default. Local logs stay on disk. Optional crash upload (if ever enabled in a build) is opt-in and off by default; see [`CRASH_LOG_HOOK.md`](CRASH_LOG_HOOK.md).

---

## G. Refunds & store

### G1. Refunds

Handled by Steam’s refund policy. We cannot override Steam Support; we can help diagnose so you can play.

### G2. Wishlist / follow

Steam follow + News is the channel for Week-1 patch notes and free updates.

---

## H. Contact

| Channel | Best for |
|---|---|
| Steam Discussions — Bug Reports | Repro steps, friend codes |
| Steam Discussions — FAQ | This document |
| Discord (if linked on store) | Fast “is it just me?” checks |
| Email (store support alias) | Save recovery attachments |

When filing a bug, include: **build id**, **OS**, **Campaign vs Daily**, **chamber id or friend code**, **crash pack**.
