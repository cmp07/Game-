# Fonts — Echo Lattice

## Latin stack (art bible)

| Role | Preferred | MVP fallback |
|---|---|---|
| Display | Akkurat / Inter Tight / IBM Plex Sans Condensed | Godot default (Inter-like) |
| Body | IBM Plex Serif / PT Serif | Godot default |
| Mono (seed / buffer) | IBM Plex Mono | Godot default |

Ship final OFL or licensed files under `fonts/latin/` before store submission. See also `docs/RELEASE/COMPLIANCE_FINAL.md` (credits) when that pack lands.

## CJK plan (zh-Hans ship)

Han coverage is **required** for Simplified Chinese UI. Do **not** rely on OS fonts — Steam Deck / minimal Windows installs tofu missing glyphs.

| Priority | Face | File to vendor | License |
|---|---|---|---|
| 1 (display + UI) | **Noto Sans SC** Regular | `cjk/NotoSansSC-Regular.otf` (or `.ttf`) | OFL-1.1 |
| 2 (alt) | Source Han Sans SC Regular | `cjk/SourceHanSansSC-Regular.otf` | OFL-1.1 |
| Optional body | Noto Serif SC Regular | `cjk/NotoSerifSC-Regular.otf` | OFL-1.1 |

`LocaleManager` (`scripts/locale/locale_manager.gd`) swaps `ThemeDB.fallback_font` to the first existing candidate when the active locale is `zh_Hans` (or other CJK tags). Labels and `draw_string(..., ThemeDB.fallback_font, ...)` both pick it up.

### Vendor steps (release)

1. Download Noto Sans SC from [Google Fonts — Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC) or the [noto-cjk](https://github.com/notofonts/noto-cjk) release.
2. Place the Regular file at `game/echo_lattice/fonts/cjk/NotoSansSC-Regular.otf`.
3. Open the project once in Godot 4.3 so `.import` is generated (or commit a checked import).
4. Keep the OFL text in `fonts/cjk/OFL.txt` and list the face in ship credits.
5. Smoke-test menu brand lockup + chamber captions at 960×560 and 1280×720 — CJK runs wider; shorten copy rather than shrinking below 14 px body.

### Explicit non-goals for v1

- No JP / KR catalogs yet (font candidates can stay; strings ship later).
- No per-control Theme resource yet — fallback font swap is enough for the vertical slice HUD.
- Do not commit multi‑MB variable font collections if a single Regular static face covers UI.

Binary font files are **gitignored** until legal/size review clears them; CI may fetch via a release script later.
