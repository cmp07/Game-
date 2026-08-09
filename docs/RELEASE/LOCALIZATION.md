# Echo Lattice — Localization (EN + zh-Hans)

**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4.3+ `TranslationServer`  
**Catalog:** [`game/echo_lattice/locale/echo_lattice.csv`](../../game/echo_lattice/locale/echo_lattice.csv)  
**Runtime:** [`game/echo_lattice/scripts/locale/locale_manager.gd`](../../game/echo_lattice/scripts/locale/locale_manager.gd) (autoload)  
**Fonts:** [`game/echo_lattice/fonts/README.md`](../../game/echo_lattice/fonts/README.md)  
**Status:** Shipping locales = **English (`en`)** + **Simplified Chinese (`zh_Hans`)**. JP/KR deferred.

Companions: art bible typography ([`05_ART_BIBLE.md`](../ECHO_LATTICE/05_ART_BIBLE.md)), vertical-slice gaps ([`13_VERTICAL_SLICE_README.md`](../ECHO_LATTICE/13_VERTICAL_SLICE_README.md)), compliance credits when merged (`COMPLIANCE_FINAL.md`).

---

## 1. Goals

| Goal | Ship rule |
|---|---|
| Player-facing copy is keyed | No new hard-coded English in UI scripts — use `tr("key")` |
| Source language | English in the `en` CSV column |
| First expansion locale | `zh_Hans` (Simplified Chinese) — China Steam + global SC players |
| Locale selection | OS / Steam locale at boot; override persisted in `user://locale.cfg` |
| Fonts | Latin stack per art bible; **CJK fallback mandatory** for `zh_Hans` |
| Content JSON | Chamber `title` / `caption` stay English in JSON; display layer looks up `chamber.<id>.title` / `.caption` |

---

## 2. Architecture

```
┌─────────────────────┐
│ locale/echo_lattice.csv │  keys,en,zh_Hans
└──────────┬──────────┘
           │ LocaleManager._load_catalog (autoload _ready)
           ▼
┌─────────────────────┐
│ TranslationServer   │  Translation resources per locale
└──────────┬──────────┘
           │ TranslationServer.set_locale(...)
           ▼
┌─────────────────────┐
│ UI scripts / Labels │  tr("menu.continue") % args
│ ChamberBook display │  LocaleManager.translate_chamber_*()
└─────────────────────┘
```

Why CSV + runtime load (not editor `.translation` binaries):

- Headless / cloud agents can edit and validate the catalog without Godot import.
- Repo already gitignores `*.translation`.
- One source of truth reviewed in PRs as plain text.

`project.godot` sets `locale/fallbacks=["en"]`. The CSV is **not** listed under `locale/translations`; `LocaleManager` owns registration.

---

## 3. Locale codes

| Catalog locale | Aliases accepted at boot | Notes |
|---|---|---|
| `en` | `en_US`, `en_GB`, … | Source / fallback |
| `zh_Hans` | `zh`, `zh_CN`, `zh_SG`, `zh-Hans`, `zh-CN` | Simplified Chinese |

`LocaleManager.normalize_locale()` maps Steam/OS tags onto the table above. Unknown tags fall back to `en`.

Persisted override:

```
user://locale.cfg
[locale]
code="zh_Hans"
```

Settings → **Language** OptionButton calls `LocaleManager.apply_locale(...)` (`system` / `en` / `zh_Hans`) using the `locale.*` catalog keys.

---

## 4. String inventory

Catalog columns: `keys,en,zh_Hans`.

| Prefix | Coverage |
|---|---|
| `brand.*` | Title lockup, tagline, blurb |
| `menu.*` | Main menu buttons, progress/daily lines, chrome (`FIELD INDEX`, `BUFFER`, controls) |
| `hud.*` | In-chamber moves/habit/restart/menu |
| `habit.*` | Direction names (`up`/`down`/`left`/`right`) |
| `won.*` | Chamber-cleared screen |
| `end.*` | End-of-wing / end-of-daily screen |
| `act.*` | Act names (Induction / Reflection / Pressure / Mastery) |
| `chamber.<id>.title` / `.caption` | All 39 content chambers |
| `locale.*` | Language picker labels (Settings row) |
| `settings.*` / `colorblind.*` / `input.*` | Settings chrome, palette names, remap row titles |
| `subtitle.*` | PA / rewrite / assist subtitle stubs |
| `glyphs.*` / `hud.*_fmt` / `menu.controls_hint_remap` | Controller / remap-aware prompt chrome |
| `end.demo_*` / `menu.subtitle_demo` | Next Fest demo copy |
| `project.description` | Store/engine description string |

Placeholders use GDScript `%` formatting (`%s`, literal `%%` for a percent sign).

**Extracted from:** `menu.gd`, `chamber_scene.gd`, `chamber_won.gd`, `end_screen.gd`, scene button labels, and `content/chambers/*.json` titles/captions.

**Intentionally not translated (v1):**

- Debug / `printerr` strings
- Audio event ids, transform op names, content ids / slugs
- Seed hex strip digits (labels translate; hex stays latin)
- Raw audio event ids (on-screen PA/rewrite stubs are keyed under `subtitle.*`)

---

## 5. Authoring workflow

1. Add or change English copy behind a stable key in the CSV `en` column.
2. Fill `zh_Hans` in the same PR (or mark `TODO` only if a native pass is scheduled — empty cells fall back to the key/`en` via TranslationServer fallback).
3. Wire UI with `tr("your.key")` or `tr("your.key") % [a, b]`.
4. For chamber text, add `chamber.<content_id>.title` / `.caption` and keep JSON English as the design-source.
5. Validate:

```bash
python3 game/echo_lattice/tests/validate_locale.py
```

6. In-editor smoke: Project → Project Settings → Localization → set test locale, or call `LocaleManager.apply_locale("zh_Hans")` from the remote debugger.

### CSV rules

- First column header must be `keys`.
- Do not reuse English sentences as keys — keys are stable ids (`menu.start_new`).
- Keep newlines only inside quoted multi-line values (`won.stats`, `end.summary`).
- Prefer short SC copy; CJK UI runs wider than Latin at the same px size.

---

## 6. CJK font plan

Full vendor steps live in [`game/echo_lattice/fonts/README.md`](../../game/echo_lattice/fonts/README.md). Release checklist:

| Step | Detail |
|---|---|
| Face | **Noto Sans SC Regular** (OFL) as primary UI/display fallback |
| Path | `game/echo_lattice/fonts/cjk/NotoSansSC-Regular.otf` |
| Fetch | `python3 tools/fonts/fetch_noto_sans_sc.py` (OFL zip from noto-cjk Sans 2.004) |
| Wiring | `LocaleManager` sets `ThemeDB.fallback_font` when locale is CJK |
| Credits | `fonts/cjk/OFL.txt` + compliance pack Noto Sans SC line |
| Layout QA | Menu brand + captions at 960×560 and 1280×720; no type below 14 px body |
| Git | Binaries gitignored; optional Git LFS via root `.gitattributes` (see `fonts/cjk/README.md`) |

Without the vendor file, `zh_Hans` still selects and translates strings, but Han glyphs may tofu — CI warns via `LocaleManager` `push_warning`.

Art bible already calls for “Fallback CJK fonts vetted against the display + body stack” and SC title lockups in the 1.0 marketing kit — this pack implements the **runtime** half; store capsules stay a marketing deliverable.

---

## 7. Steam / store notes

| Item | Action |
|---|---|
| Steam language support | Enable **English** + **Simplified Chinese** on the app |
| Store text | Translate short/long description + captions in Steamworks (separate from in-game CSV) |
| Community hub default | English; SC players pick language in Steam client |
| Achievements | English API names; localized display strings when achievements ship |
| Capsules | Art bible: SC title lockup in the 1.0 marketing set |

China RMB pricing notes live with the platforms pack (`docs/RELEASE/PLATFORMS.md` when merged).

---

## 8. Test plan

- [ ] `python3 game/echo_lattice/tests/validate_locale.py` passes (key parity, chamber coverage, placeholder parity).
- [ ] Boot with OS locale `en*` → English menu chrome.
- [ ] Boot with OS locale `zh_CN` / `zh-Hans` → Simplified Chinese chrome + chamber captions.
- [ ] `LocaleManager.apply_locale("zh_Hans")` then `"en"` live-switches labels that listen to `locale_changed`.
- [ ] With Noto Sans SC vendored, brand lockup / HUD show Han glyphs (no tofu).
- [ ] Without the font file, game still runs; warning printed once.
- [ ] Daily / wing end summaries format numbers correctly in both locales.
- [ ] New chamber JSON → matching `chamber.<id>.*` keys added in the same PR.

---

## 9. Deferred

| Item | Why deferred |
|---|---|
| `ja` / `zh_Hant` / `ko` catalogs | Font + native pass cost; architecture already alias-ready |
| Steamworks store localization | Marketing track, not runtime CSV |
| Editor auto-translate on `.tscn` text | Scripts set `tr()` in `_ready` so placeholders stay readable in the editor |
| PO / Weblate pipeline | CSV is enough for two locales; graduate if locale count > 4 |

---

## 10. Change log

- **v0.1** — Extract UI + 39 chamber strings; `LocaleManager` + `en`/`zh_Hans` CSV; CJK font plan; this doc.
- **v0.2** — Settings / subtitles / glyphs / demo keyed; in-game language picker; Noto Sans SC fetch script + OFL + LFS note.
