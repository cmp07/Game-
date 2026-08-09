# Echo Lattice — Next Fest Demo Spec

**Authority:** shipping demo gates for `game/echo_lattice/`.  
**Marketing context:** store / trailer Next Fest notes in `docs/ECHO_LATTICE/11_STORE_AND_TRAILER.md` §9 (when present on branch).  
**Code gate:** `DemoBuild` (`scripts/demo_build.gd`) + export custom feature `demo`.

---

## 1. Product shape

| Item | Value |
|---|---|
| Product name | **Echo Lattice Demo** |
| Full game | Echo Lattice (four Acts) |
| Platforms (fest) | **Windows** first (Steam Next Fest) |
| Export preset | `Windows Demo` in `game/echo_lattice/export_presets.cfg` |
| Feature tag | `demo` (`OS.has_feature("demo")`) |
| Local test flag | `--demo` on the cmdline (editor / full project tree) |
| Wishlist CTA | `DemoBuild.WISHLIST_URL` — replace `YOUR_APP_ID` before ship |

The demo is a **marketing surface**, not a truncated full build left unlocked. Late-act chambers are excluded from the Windows Demo PCK and filtered out of the run queue at runtime.

---

## 2. Content in

**Act I — Induction** (campaign ids, in order):

| Id | Title | Transform | Role |
|---|---|---|---|
| `00_quiet_span` | Quiet Span | `none` | lesson |
| `01_echo_plate` | Echo Plate | `none` | lesson |
| `02_mirror_birth` | **Mirror Birth** | `mirror_v` | lesson (hook) |
| `03_break_the_loop` | Break the Loop | `mirror_v` | remix |
| `04_ceiling_first` | Ceiling First | `mirror_h` | lesson |
| `05_two_glances` | Two Glances | `mirror_v` | remix |
| `06_far_side` | Far Side | `rotate_180` | lesson |
| `07_first_thicken` | First Thicken | `thicken` | lesson |
| `08_identity_induction` | Who Walked | `mirror_v` | boss |

**Required beat:** the player reaches **Mirror Birth** (`02_mirror_birth`) — first vertical-mirror rewrite. Act I continues through the Induction identity boss so the wing has a clear finish.

**Wishlist CTA:** once, on the demo end screen after Act I clear (also available from the demo main menu). Opens the Steam store wishlist URL. No other storefront links.

**Daily Challenge:** remains available but draws only from the demo chamber pool (Act I).

---

## 3. Content out (no late-act spoilers)

Deliberately withheld:

- Acts **Reflection / Pressure / Mastery** (chambers `09_*` … `34_*`)
- Hard variants (`35_*` … `38_*`), including `Mirror Birth+`
- Any UI copy that names later Acts, bosses, or “four Acts” as playable scope
- Achievements, Workshop, editor, “coming soon” splash for post-demo content

Windows Demo `exclude_filter` drops late chamber JSON from the exported PCK:

```
content/chambers/09_*.json
content/chambers/1*_*.json
content/chambers/2*_*.json
content/chambers/3*_*.json
```

Runtime still filters via `DemoBuild.filter_campaign_ids` so `--demo` in a full tree matches export behaviour.

---

## 4. Player-facing copy (demo)

| Surface | Copy |
|---|---|
| Menu subtitle (fresh) | `Demo — Act I · Mirror Birth. Ink on paper.` |
| Menu index header | `DEMO INDEX` |
| Menu wishlist | `Wishlist on Steam` |
| Chamber-won (last) | `→ Finish Demo` |
| End title | `DEMO COMPLETE` |
| End tagline | `You met Mirror Birth. The full lattice waits.` |
| End wishlist | `Wishlist on Steam` (focused) |

Do not tease Reflection / Pressure / Mastery names or transforms beyond what Act I already teaches.

---

## 5. Build & verify

### Export (Godot 4.3 + Windows templates)

```bash
cd game/echo_lattice
godot --headless --path . --export-release "Windows Demo" builds/windows_demo/EchoLatticeDemo.exe
```

Preset sets `custom_features="demo"`, product name **Echo Lattice Demo**, path `builds/windows_demo/EchoLatticeDemo.exe`.

### Godot self-test

Full game:

```bash
cd game/echo_lattice && godot --headless --path . -- --selftest
```

Demo scope (Act I + Mirror Birth + no spoilers):

```bash
cd game/echo_lattice && godot --headless --path . -- --selftest --demo
```

### Python self-test (no Godot required)

```bash
python3 game/echo_lattice/tests/test_demo_spec.py
```

Checks: Act I allow-list vs `acts.json`, Mirror Birth present, late-act ids excluded from the allow-list, export preset `Windows Demo` + `demo` feature + exclude filters, wishlist placeholder present in `demo_build.gd`.

---

## 6. Acceptance checklist (ship gate)

- [ ] Windows Demo export runs on Win10 / Win11 / Steam Deck Proton
- [ ] Fresh player clears Quiet Span → Echo Plate → **Mirror Birth** without a tutorial wall of text
- [ ] Act I end screen shows wishlist once; URL uses real AppID (not `YOUR_APP_ID`)
- [ ] No Reflection / Pressure / Mastery chamber files in the demo PCK
- [ ] `--selftest --demo` (or `test_demo_spec.py`) green in CI
- [ ] Store page marks demo playable; Next Fest trailer cut ready

---

## 7. Placeholders before Partner upload

| Placeholder | Where | Action |
|---|---|---|
| `YOUR_APP_ID` | `scripts/demo_build.gd` → `WISHLIST_URL` | Full game Steam AppID |
| `YOUR_DEMO_APP_ID` / `YOUR_DEMO_DEPOT_ID` | `steam/echo_lattice/app_build_demo.vdf`, `depot_windows_demo.vdf` | Separate demo app + Windows depot |
| Exit survey | Marketing §9.4 | Optional follow-up; not required for this code gate |

Full placeholder gate list: [`APPID_PLACEHOLDER_GATES.md`](APPID_PLACEHOLDER_GATES.md).

---

## 8. Change log

| Date | Change |
|---|---|
| 2026-08-09 | Initial demo flag, Windows Demo preset, Act I + Mirror Birth scope, wishlist CTA, self-tests. |
