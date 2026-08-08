# Echo Lattice — Steam Readiness Checklist

**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4.3+ (Windows desktop `.exe`)  
**Price band:** $5.99–$8.99  
**Steamworks status:** AppID not yet assigned — use placeholders below until Partner creates the app.

Use this doc as the single checklist from Steamworks app creation → depot upload → store page → launch candidate. Related export how-to: [`EXPORT_WINDOWS.md`](EXPORT_WINDOWS.md).

---

## 0. Status legend

| Mark | Meaning |
|------|---------|
| `[ ]` | Not started |
| `[~]` | In progress / blocked on AppID or art |
| `[x]` | Done |

Update marks in PRs as work lands. Do **not** invent a real AppID.

---

## 1. Steamworks identity (placeholders)

| Field | Value | Notes |
|-------|-------|-------|
| **AppID** | `YOUR_APP_ID` | Replace everywhere after Partner → Create new app → Application. |
| **Demo AppID** | `YOUR_DEMO_APP_ID` | Separate app recommended; link as demo of main. |
| **DepotID (Windows content)** | `YOUR_DEPOT_ID` | Usually AppID + 1 for first depot; confirm in Steamworks. |
| **Demo DepotID** | `YOUR_DEMO_DEPOT_ID` | |
| **Steam Cloud AppID** | same as AppID | Only if Cloud enabled (optional for MVP). |
| **Internal name** | `EchoLattice` | No spaces in script/depot paths. |
| **Store name** | Echo Lattice | Exact casing for capsules / trailer title card. |

**Repo placeholders to search-replace when AppID lands:**

- `steam/echo_lattice/*.vdf` → `YOUR_APP_ID`, `YOUR_DEPOT_ID`
- `game/echo_lattice/` GodotSteam / `steam_appid.txt` (when wired)
- This checklist tables

**Local testing before a real AppID:** GodotSteam and `steam_api64.dll` can use Valve’s Spacewar AppID `480` for SDK bring-up only. **Never ship** Spacewar IDs in a public build or store depot.

---

## 2. Store tags & taxonomy

Primary store positioning (from product lock): adaptive habit labyrinth / puzzle with light roguelike framing — **not** AI chatbot, not loot crawl.

### Primary tags (pick ≤5 “most important”)

1. Puzzle  
2. Procedural Generation  
3. Minimalist  
4. Singleplayer  
5. Replay Value  

### Secondary / supporting tags

- Roguelike *(light — chambers + rewrites, not loot meta)*  
- 2D  
- Atmospheric  
- Abstract  
- Indie  
- Controllers *(when supported)*  
- Level Editor *(post-MVP / Workshop)*  

### Category / features (Steamworks checkboxes)

| Feature | MVP | Later |
|---------|-----|-------|
| Single-player | Yes | — |
| Steam Achievements | Yes (launch candidate) | Expand set |
| Steam Cloud | Optional | Enable if saves are small + stable |
| Steam Workshop | No | Level editor path |
| Leaderboards | No | Ghost races |
| Steam Deck Verified path | Target | Deck QA pass |
| Multiplayer | **No** | Never for v1 |
| In-App Purchases | **No** | — |

### Store copy reminders

- Trailer / capsule hook: *“It learned you.”*  
- Do **not** market as AI, LLM, or chatbot dungeon.  
- Demo = first wing; must be the core loop, not a trailer-only tease.

---

## 3. Capsule & asset sizes

All store assets: final art in sRGB PNG (or JPG where Valve allows). Keep a source PSD/Krita file outside the depot.

| Asset | Size (px) | Required | Notes |
|-------|-----------|----------|-------|
| **Header capsule** | 460 × 215 | Yes | Library / store header |
| **Small capsule** | 231 × 87 | Yes | Search / lists |
| **Main capsule** | 616 × 353 | Yes | Store page hero |
| **Vertical capsule** | 374 × 448 | Yes | Library vertical |
| **Library hero** | 1920 × 620 | Yes | Library detail |
| **Library logo** | 1280 × 720 *(transparent PNG)* | Yes | Logo only; no busy background |
| **Page background** | 1438 × 810 | Optional | Store page atmosphere |
| **Community icon** | 184 × 184 | Yes | Client shortcut / community |
| **Client icon** | 32 × 32 + ICO set | Yes | Windows `.ico` for `.exe` |
| **Event cover** | 800 × 450 | As needed | News / Next Fest |
| **Screenshot** | ≥ 1920 × 1080 | ≥5 | Show rewrite spectacle + UI readability |
| **Trailer** | 1920 × 1080, ≤30s cutdown + 60–90s | Yes | First 5s: clean hall → walls reshape → “It learned you.” |

**Art direction for capsules (cheap but strong):** monochrome lattice + one accent color infection; brutalist subway-map vibe — not fantasy dungeon kitbash, not purple-glow AI slop.

**Checklist**

- [ ] Header / small / main / vertical capsules  
- [ ] Library hero + logo  
- [ ] Community + client icons  
- [ ] ≥5 screenshots (no debug overlays)  
- [ ] Trailer cutdowns uploaded  
- [ ] All text legible at small capsule scale  

---

## 4. AI content disclosure

**Policy for Echo Lattice gameplay:** **none** — do **not** disclose AI for gameplay systems.

| Content | Uses generative AI? | Steam disclosure |
|---------|---------------------|------------------|
| Gameplay / adaptation / dungeon rewrite | **No** — offline deterministic habit buffer → authored grammar (WFC / rewrite rules) | **Do not list** |
| Runtime LLM / online model | **No** — forbidden for v1 | N/A |
| Marketing art / trailer assist | Only if a human-directed tool was used for *store assets* | Disclose **asset** generation only if required by current Steam questionnaire; keep copy clear that the **game does not use AI** |
| Code assistants in production | Dev tooling only | Not a store “AI features” claim |

**Store questionnaire stance**

1. Answer **No** to gameplay AI / AI-generated game content.  
2. If any capsule/trailer frame used an image model, disclose that *store artwork* path only — never imply the labyrinth is AI-driven.  
3. Achievements, tags, and trailer must reinforce **systems**, not “AI dungeon.”

This matches the product thesis: sell the *feeling* of generative reality with **offline authored systems**, and avoid the AI-flagged shovelware conversion trap.

---

## 5. Achievements list (MVP → launch)

Define in Steamworks → Stats & Achievements. API names are stable; display names can localize later. Wire via GodotSteam `setAchievement` / `storeStats` when the plugin is integrated.

| API name | Display name | Description | When to unlock | MVP |
|----------|--------------|-------------|----------------|-----|
| `EL_FIRST_STEPS` | First Steps | Enter the lattice. | Complete tutorial / chamber 0 | Yes |
| `EL_HABIT_SEEN` | It Noticed | Trigger your first visible rewrite. | First rewrite event fired | Yes |
| `EL_WING_ONE` | Clear Air | Escape the first wing. | Clear Act 1 / demo wing | Yes |
| `EL_GHOST_TRACE` | Afterimage | Finish a chamber with ghost path replay enabled. | Complete any chamber while ghost visible | Yes |
| `EL_UNDO_DISCIPLINE` | Second Thought | Use undo 25 times in a single run. | Counter ≥ 25 | Yes |
| `EL_KIND_CORRIDORS` | Kinder Corridors | Clear a chamber without repeating the same 4-move loop. | Habit score threshold | Yes |
| `EL_MIRROR_BREAK` | Broken Mirror | Survive a mirror-grammar rewrite without reset. | Specific grammar flag | Yes |
| `EL_PERFECT_BUFFER` | Clean Buffer | Clear a chamber with ≤ N moves (chamber-defined). | Under par | Yes |
| `EL_DAILY_SEED` | Same Seed, New You | Complete a daily-seed run. | Daily mode clear | Later |
| `EL_ALL_CHAMBERS` | Full Lattice | Clear every MVP chamber. | 12/12 (or final count) | Launch |
| `EL_NO_UNDO` | Commit | Clear a wing without using undo. | Wing clear, undo == 0 | Launch |
| `EL_ACCENT_SPREAD` | Infection | Let your accent color infect ≥50% of a chamber’s tiles. | Visual/meta stat | Launch |

**Implementation notes**

- Keep unlocks **readable** from play (no hidden grind).  
- Demo build: ship only achievements that can unlock inside the demo wing, or omit achievements from the demo AppID.  
- Do not gate story on Steam; achievements are optional chrome.

**Checklist**

- [ ] Create achievements in Steamworks (icons 64×64 + 256×256 where required)  
- [ ] Wire GodotSteam unlocks + failed-call logging  
- [ ] QA: offline / Steam-down does not crash  
- [ ] Reset test app stats during QA (Partner tools)  

---

## 6. Cloud saves (optional)

**MVP default:** **local saves only** (see tech architecture save format). Steam Cloud is **optional** for 1.0.

| Decision | Recommendation |
|----------|----------------|
| Enable at demo? | **No** — keep demo frictionless; local `%APPDATA%` / `user://` is enough |
| Enable at 1.0? | **Optional** — turn on if save schema is versioned and ≤ Steam quota |
| Quota | Start with **10–50 MB**; Echo Lattice saves should be tiny (JSON / binary state) |
| Paths | Root: `user://saves/` → map in Steamworks Cloud paths |
| Conflicts | Last-write-wins acceptable for single-player puzzle; show “cloud vs local” only if you invest in UI |

**If enabling Cloud**

1. Steamworks → Steam Cloud → enable for AppID.  
2. Add root paths matching Godot `user://` on Windows (`%APPDATA%\Godot\app_userdata\Echo Lattice\` or custom `user://` override).  
3. Exclude crash dumps, screenshots, and editor scratch.  
4. Test: machine A save → machine B read; airplane mode; quota exceeded.

**Checklist**

- [ ] Decision recorded: Cloud **off** / **on** for 1.0  
- [ ] If on: paths + quota configured  
- [ ] Save version field present before Cloud on  

---

## 7. Depot layout

Windows-first SKU. Mac/Linux depots are out of scope until after Windows launch candidate.

### Recommended SteamPipe tree

```text
steam/echo_lattice/
  app_build.vdf                 # build script (AppID placeholder)
  depot_windows.vdf             # Windows content depot
  depot_build/
    windows/                    # <-- upload root (contents of this folder)
      EchoLattice.exe
      EchoLattice.pck
      steam_api64.dll           # if using GodotSteam / Steamworks SDK
      steam_appid.txt           # DEV ONLY — do not ship in retail depot
      crashpad / D3D12 optional Godot redistributables as required
      LICENSE.txt
      README_STEAM.txt          # optional support blurb
```

### Depot rules

| Rule | Detail |
|------|--------|
| One primary depot | Windows x86_64 content |
| No Godot editor | Never upload `.godot/`, source `.tscn` trees, or export cache |
| No secrets | No Steamworks shipping keys in git; CI injects if used |
| `steam_appid.txt` | Allowed in **dev** copies next to exe; **strip for retail** upload |
| Demo depot | Separate folder `depot_build/demo/` with demo `.exe` / `.pck` |
| Naming | Executable: `EchoLattice.exe` (matches store / shortcuts) |

### Build → upload flow (summary)

1. Export Windows release via [`scripts/echo_lattice/export_windows.sh`](../../scripts/echo_lattice/export_windows.sh) (or PowerShell twin).  
2. Copy artifacts into `steam/echo_lattice/depot_build/windows/`.  
3. Strip `steam_appid.txt` for retail.  
4. Fill AppID/DepotID in VDF templates.  
5. Run `steamcmd` + `run_app_build` with `app_build.vdf`.  
6. Set new build live on a Steam branch (`default` / `beta` / `demo`).

VDF templates live under [`steam/echo_lattice/`](../../steam/echo_lattice/).

**Checklist**

- [ ] App + Windows depot created in Steamworks  
- [ ] Launch option: `EchoLattice.exe` (working dir = install dir)  
- [ ] Beta branch for QA builds  
- [ ] Demo depot linked as demo of main app  
- [ ] Install size sanity check (< ~500 MB target for MVP)  

---

## 8. GodotSteam notes

Echo Lattice does **not** require Steamworks for the vertical slice. Integrate GodotSteam when approaching demo / launch candidate.

### Integration choices

| Topic | Guidance |
|-------|----------|
| Plugin | [GodotSteam](https://godotsteam.com/) GDExtension matching Godot **4.3+** minor version |
| Platforms | Windows x86_64 first; download matching editor + export template pair |
| Init | Call Steam init once from an autoload (e.g. `SteamService`); tolerate failure in editor / non-Steam runs |
| AppID | Set via `steam_appid.txt` beside exe for local runs; Partner AppID in shipping Steam install (Steam injects overlay — file often omitted in retail) |
| Overlay | Ensure game runs in exclusive-ish fullscreen or borderless that still allows Shift+Tab |
| Achievements | Batch unlocks; always `storeStats()`; handle `userStatsReceived` |
| Cloud | Prefer Godot `FileAccess` + Steam Cloud path config over reinventing file sync |
| Input | Keyboard/mouse MVP; Steam Input later — do not block launch on controller glyphs |
| Deck | Separate QA pass; 1280×800 UI scale; no unique Deck depot required for MVP |

### Dev vs retail

| Environment | AppID source | Overlay | Achievements |
|-------------|--------------|---------|--------------|
| Godot editor | Optional / skip Steam | Usually off | Stub no-ops |
| Local exported `.exe` | `steam_appid.txt` (`YOUR_APP_ID` or `480` for SDK tests) | If Steam client running | Test app |
| Steam-installed build | Steam client | On | Real AppID |

### Do / don’t

- **Do** keep a `SteamService` stub that no-ops when the plugin is missing so CI and non-Steam testers still run.  
- **Do** document the exact GodotSteam + Godot version pair in the release notes.  
- **Don’t** ship with AppID `480`.  
- **Don’t** hard-crash if Steam is not running — puzzle gameplay must work offline.  
- **Don’t** put Redistributable Steamworks DLLs into git LFS without license review; follow Valve / GodotSteam redistrib rules.

**Checklist**

- [ ] GodotSteam version pinned in project README / tech arch  
- [ ] Autoload stub + real impl behind feature flag  
- [ ] Achievement smoke test on Steam branch build  
- [ ] Overlay + Cloud (if enabled) verified  

---

## 9. Windows `.exe` export (pointer)

Full procedure, scripts, and acceptance checks: **[`EXPORT_WINDOWS.md`](EXPORT_WINDOWS.md)**.

Quick path:

```bash
# From repo root (Godot 4.3+ on PATH as `godot` or set GODOT_BIN)
./scripts/echo_lattice/export_windows.sh
# → dist/echo_lattice/windows/EchoLattice.exe (+ .pck)
```

PowerShell: `scripts/echo_lattice/export_windows.ps1`.

---

## 10. Pre-launch master checklist

### Steamworks / store

- [ ] AppID + Demo AppID created; placeholders replaced  
- [ ] Tags + features set  
- [ ] Capsules / library assets / icons uploaded  
- [ ] AI disclosure answered (**no gameplay AI**)  
- [ ] Achievements created  
- [ ] Cloud decision applied  
- [ ] Store page copy + trailer + ≥5 screenshots  
- [ ] Pricing + release date / Coming Soon  
- [ ] Demo linked; wishlist CTA live  

### Build / depots

- [ ] Windows export script produces runnable `.exe`  
- [ ] Depot layout validated; retail build without `steam_appid.txt`  
- [ ] Steam branch install + playtest (keyboard)  
- [ ] GodotSteam init + achievements smoke (if integrated)  
- [ ] Uninstall / reinstall / Cloud conflict (if Cloud on)  

### Product QA (store-facing)

- [ ] Demo is the loop in ≤3 minutes  
- [ ] Determinism / seed string visible (anti-“feels random”)  
- [ ] No debug HUD in shipping export  
- [ ] Deck / gamepad pass or “keyboard-first” stated honestly  

---

## 11. Related paths

| Path | Role |
|------|------|
| [`EXPORT_WINDOWS.md`](EXPORT_WINDOWS.md) | Export docs |
| [`scripts/echo_lattice/export_windows.sh`](../../scripts/echo_lattice/export_windows.sh) | Linux/mac CI-friendly export |
| [`scripts/echo_lattice/export_windows.ps1`](../../scripts/echo_lattice/export_windows.ps1) | Windows host export |
| [`steam/echo_lattice/`](../../steam/echo_lattice/) | SteamPipe VDF templates |
| `game/echo_lattice/` | Godot project (scaffold lands on parallel branch) |
| [`../FIVE_GAMES_TO_BUILD.md`](../FIVE_GAMES_TO_BUILD.md) | Concept lock (when merged) |
| `00_PRODUCTION_BIBLE.md` / `01_GDD.md` / `03_TECH_ARCHITECTURE.md` | Parallel Echo Lattice specs |

---

*Last updated: 2026-08 — AppID still placeholder.*
