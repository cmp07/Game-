# Echo Lattice — Security Audit

| Field | Value |
|---|---|
| **Scope** | `game/echo_lattice`, `steam/echo_lattice`, `docs/RELEASE` CI/export notes, `tools/` |
| **Base** | `cursor/echo-lattice-rc1` @ `03e9a7ae5bc75b937f7cecb18b32a7b526fd22ab` |
| **Mode** | Cloud-only, **read-focused** review (no exploits, PoCs, or attack payloads) |
| **Date** | 2026-08-09 |
| **Engine** | Godot 4.3 · GDScript · optional GodotSteam |

This audit examines trust boundaries around local persistence, authored content JSON, Steam stub/cloud paths, privacy surfaces, resource I/O, repository secrets hygiene, planned CI supply chain, and Godot export configuration. Findings are ordered by severity within each band.

---

## Executive summary

No committed secrets, network telemetry upload client, or dynamic script evaluation surfaces were found. The shipping threat model is primarily **local integrity** (save/settings/content), **privacy/disclosure**, and **release/process mistakes** (Spacewar AppID, unencrypted PCK, CI artifact trust). Highest practical risks before Steam enablement are: (1) AppID / `steam_appid.txt` mishandling when leaving the stub, (2) unvalidated cloud→local save writes once Cloud is on, (3) CLI screenshot `--out` accepting unconstrained paths in release binaries, and (4) planned CI downloading Godot without checksum/pinning guidance.

| Severity | Count |
|---|---|
| Critical | 0 |
| High | 0 (3 fixed on `cursor/fix-sec-high`) |
| Medium | 7 → **5 open** (+ SEC-04 fixed, SEC-08 partial on `cursor/fix-remaining-p1`) |
| Low | 6 |

---

## Findings

### SEC-01 — Steam AppID resolution can fall back to Spacewar `480`

| | |
|---|---|
| **Severity** | High |
| **Status** | **FIXED** (`cursor/fix-sec-high`) — fail-closed; `allow_spacewar_dev` gated to editor/debug. See [`SECURITY_HIGH_FIXES.md`](SECURITY_HIGH_FIXES.md). |
| **Area** | Steam AppID stub abuse |
| **Evidence** | `scripts/steam/steam_service.gd` → `_resolve_app_id()`; `config/steam_features.json` (`spacewar_dev_app_id: 480`, `app_id_placeholder: "YOUR_APP_ID"`) |

**Impact.** When `steam_enabled` is true and neither a numeric `app_id_placeholder` nor a valid `steam_appid.txt` beside the executable is present, init uses Spacewar (`480`). A mis-exported “Steam” build can attach to the wrong AppID, confuse Partner stats/achievements, or ship a depot that still resolves Spacewar via a leftover `steam_appid.txt` (depot exclusions exist but are process-dependent).

**Remediation.**

- Fail closed in release/Steam feature builds: refuse init unless a real AppID is configured; never silently select `480` outside explicit `debug` / editor profiles.
- Gate `spacewar_dev_app_id` behind a dedicated `allow_spacewar_dev` flag that is false in shipping presets.
- Add a release checklist / CI grep that fails if retail artifacts contain `steam_appid.txt` or the string `480` in runtime config meant for Steam stores.
- Keep depot `FileExclusion` for `steam_appid.txt` (already in `steam/echo_lattice/depot_windows.vdf`) and verify on every upload.

---

### SEC-02 — Steam Cloud pull writes remote bytes to `user://save.json` without schema validation

| | |
|---|---|
| **Severity** | High |
| **Status** | **FIXED** (`cursor/fix-sec-high`) — `SaveManager.validate_save_*` + atomic cloud tmp. See [`SECURITY_HIGH_FIXES.md`](SECURITY_HIGH_FIXES.md). |
| **Area** | Cloud save |
| **Evidence** | `scripts/steam/steam_cloud_save.gd` → `pull_if_newer()`; consumed by `SaveManager._apply_save()` |

**Impact.** Remote cloud content is written verbatim to the local save path when local is missing/empty. `SaveManager` then applies dictionary fields with light typing (`int`/`str`/`duplicate`) but **no save-version gate, size limits, or allowlisted key schema**. A corrupted or hostile cloud blob for the same Steam account can softlock Continue, inflate memory via huge maps/arrays, or drive achievement evaluation off tampered progress once Steam achievements are live.

**Remediation.**

- Validate cloud payloads with the same (or stricter) schema as local load before replacing `save.json` (version bounds, max key counts, typed `run_queue` of chamber indices in range, capped dictionary sizes).
- Write cloud pulls to a temp file, validate, then atomic-rename (mirror local save rotation).
- Prefer Steam Cloud conflict resolution with explicit timestamps/hashes rather than “empty local loses.”
- Never enable Cloud sync for `user://telemetry/**` or crash logs (already called out in compliance docs — enforce in Partner path rules).

---

### SEC-03 — Release CLI `--screenshot --out` accepts unconstrained filesystem paths

| | |
|---|---|
| **Severity** | High |
| **Status** | **FIXED** (`cursor/fix-sec-high`) — `user://` or project-root allowlist; tools use `.capture_staging/`. See [`SECURITY_HIGH_FIXES.md`](SECURITY_HIGH_FIXES.md). |
| **Area** | Path traversal / arbitrary write (local) |
| **Evidence** | `scripts/main.gd` → `_ready()` / `_capture_screenshot()` |

**Impact.** `--out` is passed to `DirAccess.make_dir_recursive_absolute` and PNG write with no allowlist to `user://` or a capture staging directory. Any local launcher, shortcut, or script that can start the game binary can direct writes (and directory creation) anywhere the process may write. This is a developer capture affordance that remains in the main scene path for all builds that include this script.

**Remediation.**

- Strip or no-op screenshot CLI in shipping exports (`OS.has_feature("editor")` / custom feature `dev_tools`, or exclude via export).
- If kept for Deck/CI capture builds only: require `user://` or a fixed project-relative staging root; reject `..`, absolute paths outside that root, and empty/`kind` injection into filenames beyond a safe charset.
- Document that capture scripts under `game/echo_lattice/tools/` are non-retail.

---

### SEC-04 — LocalTelemetry path taken from JSON without `user://` allowlist

| | |
|---|---|
| **Severity** | Medium |
| **Status** | **FIXED** (`cursor/fix-remaining-p1`) — `LocalTelemetry.sanitize_path` allowlists `user://telemetry/**` only. |
| **Area** | Path traversal / untrusted config |
| **Evidence** | `scripts/local_telemetry.gd` → `from_balance()`; `config/balance_v2.json` → `telemetry.path` |

**Impact.** Telemetry open/create uses `cfg.path` directly. Combined with `encrypt_pck=false` (see SEC-10), a replaced or patched `balance_v2.json` inside the game tree/PCK can redirect append writes to unexpected locations the process can open, and can force `enabled` / event allowlists. Default path is safe (`user://telemetry/...`); the missing allowlist is the defect.

**Remediation.**

- Resolve telemetry path only under `user://telemetry/`; reject absolute paths and `..` segments after `globalize_path`.
- Treat `include_pii` as an enforced code gate (currently config-only; see SEC-08).
- Consider shipping balance config in encrypted/signed form if mod resistance matters.

---

### SEC-05 — Untrusted / authored chamber JSON retained as `raw` after partial validation

| | |
|---|---|
| **Severity** | Medium |
| **Area** | Untrusted chamber JSON |
| **Evidence** | `scripts/chamber_loader.gd` → `validate()`, `_normalize()` |

**Impact.** Loader is **fail-closed** for map geometry, act, and transform enums — a strong baseline. Residual risks: `_normalize` keeps the full `raw` dictionary; string fields (`title`, `caption`, `identity`, motifs, hints) are not length-capped; invalid files are skipped but a hostile valid-shaped chamber can still alter gameplay difficulty and UI copy. No dynamic code execution path from chamber fields was identified (transforms are allowlisted strings; UI uses plain `Label` text, not BBCode parsers).

**Remediation.**

- Drop or strip `raw` from runtime records after normalize; keep only playable fields.
- Cap string lengths; ignore unknown keys; validate `index` uniqueness and campaign references in `acts.json`.
- Keep CI `tests/validate_chambers.py` as a merge gate (already sketched in `CI_BUILDS.md`).

---

### SEC-06 — Local save/settings load trust local files with weak schema

| | |
|---|---|
| **Severity** | Medium |
| **Area** | Saves / loads |
| **Evidence** | `scripts/save_manager.gd`; `scripts/a11y/settings_store.gd` |

**Impact.** Fixed paths under `user://` avoid classic relative traversal in the happy path. Issues are integrity-oriented: save `version` is written but not enforced on load; `run_queue` / score maps accept attacker-shaped local JSON (shared machine, sync tools, cloud pull); settings `_deep_merge` imports arbitrary nested keys. Atomic tmp→rename + `.bak` recovery is good for crash safety, not for authenticity.

**Remediation.**

- Enforce `SAVE_VERSION` (reject or migrate unknown majors).
- Allowlist keys; clamp chamber indices to `ChamberBook` range; bound collection sizes.
- Settings: merge only known sections/keys; ignore unknown keys; validate numeric ranges for a11y/audio.

---

### SEC-07 — Telemetry default-on without in-game opt-out; privacy contract drift

| | |
|---|---|
| **Severity** | Medium |
| **Area** | Telemetry / privacy |
| **Evidence** | `balance_v2.json` `enabled_default: true`; `LocalTelemetry`; `docs/RELEASE/COMPLIANCE_FINAL.md` |

**Impact.** Balance telemetry is append-only local JSONL and does not upload — good. It is still on-device data collection (moves, chamber clears, softlock events). Compliance docs require a Settings toggle before 1.0 if default stays on; no settings UI binding to `LocalTelemetry.enabled` was found. Crash-hook upload is correctly fenced (no network client; opt-in required), but `maybe_upload_latest()` returns `would_post_to` echoing `upload_url` into caller-visible status.

**Remediation.**

- Ship Settings toggle wired to telemetry enable; default off for privacy-strict regions if required, or default on only with clear disclosure + store privacy URL.
- Do not echo full `upload_url` in status dictionaries destined for UI/logs.
- Redact session breadcrumbs before any future upload; keep Steam Cloud exclusions for telemetry/crash paths.

---

### SEC-08 — `include_pii: false` is documentation/config only (not enforced)

| | |
|---|---|
| **Severity** | Medium |
| **Status** | **PARTIAL** (`cursor/fix-remaining-p1`) — `_scrub_pii` drops known PII keys when `include_pii` is false; full per-event allowlist still open. |
| **Area** | Telemetry / privacy |
| **Evidence** | `balance_v2.json`; `local_telemetry.gd` merges `default_context` + `payload` unchecked |

**Impact.** Call sites can attach arbitrary keys to events. A future feature adding player-entered names, Steam IDs, or device identifiers would silently violate the published privacy stub unless a denylist/allowlist exists in code.

**Remediation.**

- Enforce an event payload allowlist per event name; drop unknown keys when `include_pii` is false.
- Add a unit test that fails if emitted keys escape the allowlist.

---

### SEC-09 — Planned CI downloads Godot / actions without pin + checksum guidance

| | |
|---|---|
| **Severity** | Medium |
| **Area** | CI supply chain |
| **Evidence** | `docs/RELEASE/CI_BUILDS.md` (sketch only; **no** committed `.github/workflows`) |

**Impact.** When the sketch is copied into production workflows, floating action tags (`actions/checkout@v4`) and unverified Godot binary downloads are classic CI compromise amplifiers (malicious runner steps, trojaned engine builds, secret exfil via export/publish jobs). Secrets checklist correctly places Steam/Apple/itch credentials in CI secrets — good — but download trust is unspecified.

**Remediation.**

- Pin GitHub Actions to full commit SHAs; pin Godot version + publish checksum verification (sha256 from Godot release metadata).
- Prefer official Godot build artifacts; cache by content hash.
- Separate `validate` from `publish-*` jobs; require environment approval for Steam/itch credentials.
- Never pass store passwords on CLI flags in logs; prefer Steam build accounts + limited tokens.

---

### SEC-10 — Godot export: unencrypted PCK, console wrapper, full resource filter

| | |
|---|---|
| **Severity** | Medium |
| **Area** | Godot export risks |
| **Evidence** | `export_presets.cfg` (`encrypt_pck=false`, `script_export_mode=2`, `debug/export_console_wrapper=1`, `export_filter="all_resources"`) |

**Impact.** Players (or malware) can unpack/replace `.pck` contents: chambers, balance, audio event catalogs, Steam feature flags. `script_export_mode=2` (compressed tokens) raises the bar versus plaintext `.gd` but is not a confidentiality control. Console wrapper on desktop aids debugging and local automation abuse. Demo preset excludes late chamber JSON via `exclude_filter` but still ships `all_resources` otherwise (locale/acts may retain references — spoiler/content issue more than RCE).

**Remediation.**

- For Steam retail: enable PCK encryption (or directory encryption) with keys only in CI secrets / local export config (never commit encryption keys); rotate if leaked.
- Disable console wrapper on shipping Windows presets.
- Use export filters so demo builds cannot load full-game content even if flags are patched.
- Ensure `steam_enabled` is compile-time / feature-tag separated between itch DRM-free and Steam depots.

---

### SEC-11 — Stub backend reports cloud enabled; AppID file beside exe wins

| | |
|---|---|
| **Severity** | Low |
| **Area** | Steam stub / AppID |
| **Evidence** | `steam_stub_backend.gd` `cloud_enabled_for_account() -> true`; `_resolve_app_id()` reads `steam_appid.txt` next to executable |

**Impact.** Tests can believe Cloud is available when offline. On shared machines, a writable install directory allows dropping `steam_appid.txt` to influence init AppID when Steam is enabled (usually install dirs are privileged; still relevant for portable copies).

**Remediation.** Stub should return cloud-disabled unless a test flag is set. Prefer embedded AppID for retail; ignore sideloaded `steam_appid.txt` when `OS.has_feature("steam")` / release builds.

---

### SEC-12 — `ArtKit.tex` / audio loaders accept caller-supplied paths

| | |
|---|---|
| **Severity** | Low |
| **Area** | Resource loading |
| **Evidence** | `scripts/art_kit.gd`; `scripts/audio/audio_manager.gd` `_load_stream()` |

**Impact.** Current call sites pass fixed `res://` literals. Helpers themselves will open arbitrary readable PNG/WAV paths (including absolute) if ever fed config/user input. Audio catalog `stream` fields from JSON become more sensitive once PCK replacement is considered (SEC-10).

**Remediation.** Require `res://` prefix; reject `..`; optionally restrict to `res://art/` and `res://audio/`. Do not pass through user:// or absolute paths in shipping builds.

---

### SEC-13 — Crash pack export destination is caller-controlled

| | |
|---|---|
| **Severity** | Low |
| **Area** | Path traversal |
| **Evidence** | `scripts/ops/crash_log_hook.gd` → `export_crash_pack(dest_dir, ...)` |

**Impact.** Creates directories and writes meta/logs under `dest_dir` with no sandbox. Not wired to an autoload in `project.godot` yet; risk rises when Support UI exposes “Export crash pack.”

**Remediation.** Default to `user://crash_exports/`; validate destination; never accept raw player-typed absolute paths without a native folder picker scoped by the OS.

---

### SEC-14 — Wishlist uses `OS.shell_open` on a compile-time URL

| | |
|---|---|
| **Severity** | Low |
| **Area** | Script injection / URL open |
| **Evidence** | `scripts/demo_build.gd` → `open_wishlist()` |

**Impact.** URL is a constant (placeholder AppID). `OS.shell_open` is appropriate for Steam store links; risk is low unless the URL becomes data-driven without scheme allowlisting (`https://store.steampowered.com/...` only).

**Remediation.** Keep URL constant or validate scheme/host allowlist before `shell_open`. Replace `YOUR_APP_ID` before demo ship (release process).

---

### SEC-15 — No dynamic script / Expression evaluation found

| | |
|---|---|
| **Severity** | Low (positive control; residual watch item) |
| **Area** | Script injection |

**Impact.** Grep across GDScript found no `Expression`, `GDScript.new`/`source_code`, `OS.execute` / `OS.create_process`, or HTTP clients in game scripts. Content remains data-only JSON. Residual risk is future features (mod support, rich text, deep links).

**Remediation.** Ban `Expression` / runtime script compile in review checklist; if mods are added later, use a capability-limited data format, not GDScript packing.

---

### SEC-16 — Repository secrets hygiene is currently clean

| | |
|---|---|
| **Severity** | Low (positive control; residual watch item) |
| **Area** | Secrets in repo |

**Impact.** No private keys, `.pem`/`.p12`/`.p8`, Steam Guard ma-files, or live API tokens were found. `export_presets.cfg` certificate/password fields are empty. Press kit keys doc is a template. `.gitignore` excludes `steam_appid.txt`, build outputs, and depot staging contents. Residual risk: future commits of GodotSteam redistributables, encryption keys, or filled press key tables.

**Remediation.** Keep encryption keys and Apple/Steam credentials out of git; scan CI for accidental `echo` of secrets; continue “last 4 only” policy for key logs.

---

## Coverage matrix

| Topic | Status | Primary refs |
|---|---|---|
| Path traversal in saves/loads | Reviewed — fixed `user://` paths; CLI/config path sinks called out | SEC-03, SEC-04, SEC-06, SEC-13 |
| Untrusted chamber JSON | Reviewed — fail-closed geometry; residual `raw`/string caps | SEC-05 |
| Telemetry / privacy | Reviewed — local-only; default-on + allowlist gaps | SEC-07, SEC-08 |
| Steam AppID stub abuse | Reviewed — Spacewar fallback + sideload file | SEC-01, SEC-11 |
| Cloud save | Reviewed — unvalidated pull; conflict policy | SEC-02 |
| Script injection | Reviewed — no eval/execute surfaces | SEC-14, SEC-15 |
| Resource loading | Reviewed — helpers overly permissive | SEC-12, SEC-10 |
| Secrets in repo | Reviewed — clean at audit SHA | SEC-16 |
| CI supply chain | Reviewed — sketch only; pinning gaps | SEC-09 |
| Godot export risks | Reviewed — no PCK encrypt; console wrapper | SEC-10 |

---

## Recommended priority order

1. **Before enabling `steam_enabled` / Cloud:** SEC-01, SEC-02, stub cloud flag (SEC-11).  
2. **Before retail/demo binaries freeze:** SEC-03, SEC-10, placeholder AppID/wishlist replacement.  
3. **Before public privacy URL / 1.0:** SEC-07, SEC-08.  
4. **When committing real workflows:** SEC-09.  
5. **Hardening backlog:** SEC-04–SEC-06, SEC-12–SEC-14.

---

## Method notes

- Static review of GDScript, JSON config, export presets, Steam VDF templates, and release docs.  
- Pattern search for credential material, process execution, HTTP clients, and dynamic script APIs.  
- No runtime fuzzing, no exploit development, no intentional generation of malicious save/chamber payloads.  
- Re-audit after GodotSteam addon commit, PCK encryption enablement, or any network upload client.
