# Fonts — Echo Lattice

## Latin stack (art bible / W1A.3)

| Role | Face | File |
|---|---|---|
| Display / brand | IBM Plex Sans Condensed **Bold** | `latin/IBMPlexSansCondensed-Bold.ttf` |
| UI actions | IBM Plex Sans Condensed **Medium** | `latin/IBMPlexSansCondensed-Medium.ttf` |
| Body | IBM Plex Serif Regular | `latin/IBMPlexSerif-Regular.ttf` |
| Mono (seed / buffer / folio) | IBM Plex Mono Regular | `latin/IBMPlexMono-Regular.ttf` |

OFL notice: `latin/OFL.txt` (IBM Plex® © IBM Corp., SIL OFL 1.1).

Runtime wiring: autoload `LedgerType` (`scripts/ledger_type.gd`) loads the stack and sets `ThemeDB.fallback_font` for Latin locales. `LocaleManager` still swaps to Noto Sans SC for `zh_Hans` when vendored.

### Re-fetch / repair

```bash
python3 tools/fonts/fetch_ibm_plex_latin.py
```

Latin faces are **committed** (Git LFS via root `.gitattributes`). Do **not** embed Akkurat (commercial).

## CJK plan (zh-Hans ship)

Han coverage is **required** for Simplified Chinese UI. Do **not** rely on OS fonts — Steam Deck / minimal Windows installs tofu missing glyphs.

| Priority | Face | File to vendor | License |
|---|---|---|---|
| 1 (display + UI) | **Noto Sans SC** Regular | `cjk/NotoSansSC-Regular.otf` (or `.ttf`) | OFL-1.1 |
| 2 (alt) | Source Han Sans SC Regular | `cjk/SourceHanSansSC-Regular.otf` | OFL-1.1 |
| Optional body | Noto Serif SC Regular | `cjk/NotoSerifSC-Regular.otf` | OFL-1.1 |

`LocaleManager` (`scripts/locale/locale_manager.gd`) swaps `ThemeDB.fallback_font` to the first existing candidate when the active locale is `zh_Hans` (or other CJK tags). Labels and `draw_string(..., ThemeDB.fallback_font, …)` both pick it up.

### Vendor steps (CJK)

1. Run `python3 tools/fonts/fetch_noto_sans_sc.py` (downloads OFL-licensed Regular from [noto-cjk Sans 2.004](https://github.com/notofonts/noto-cjk/releases/tag/Sans2.004)), **or** download manually from [Google Fonts — Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC).
2. Confirm `game/echo_lattice/fonts/cjk/NotoSansSC-Regular.otf` exists (gitignored by default).
3. Open the project once in Godot 4.3 so `.import` is generated (or commit a checked import).
4. Keep `fonts/cjk/OFL.txt` (committed) and list the face in ship credits / `COMPLIANCE_FINAL.md`.
5. Smoke-test menu brand lockup + chamber captions at 960×560 and 1280×720 — CJK runs wider; shorten copy rather than shrinking below 14 px body.

### Git LFS note

CJK binaries stay **gitignored** to keep the clone small. Root `.gitattributes` already declares LFS filters for `fonts/cjk/*.{otf,ttf,ttc,otc}` and latin faces. Details in [`cjk/README.md`](cjk/README.md).

### Explicit non-goals for v1

- No JP / KR catalogs yet (font candidates can stay; strings ship later).
- Do not commit multi‑MB variable font collections if a single Regular static face covers UI.
