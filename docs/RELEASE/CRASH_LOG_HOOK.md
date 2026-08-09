# Echo Lattice — Crash / Log Hook Design

**Status:** Local autoload wired for RC1 (`CrashLogHook` in `project.godot`)  
**Code:** `game/echo_lattice/scripts/ops/crash_log_hook.gd`  
**Related:** `scripts/local_telemetry.gd` (balance JSONL; unchanged contract)  
**UI:** Settings → Support → Export crash pack

Two layers: **local always-on diagnostics** (privacy-safe, no network) and an **optional** opt-in upload path for post-launch triage. 1.0 ships local only; upload stays behind an explicit setting and is off by default.

---

## 1. Goals

1. A player can export a **crash pack** that lets us reproduce Day-0 / Week-1 bugs without remote access.
2. Engine errors, softlock asserts, and uncaught failures land in one append-only JSONL sink.
3. Optional upload never runs unless the player toggles it; no account IDs; no move-by-move telemetry in the crash channel.

Non-goals: always-on cloud analytics, session replay video, automatic Steam Cloud of logs.

---

## 2. Local sink (ships with 1.0)

### 2.1 Paths (`user://`)

| File | Role |
|---|---|
| `user://logs/echo_lattice_crash.jsonl` | Append-only crash / error events |
| `user://logs/echo_lattice_session.jsonl` | Boot / focus / exit breadcrumbs (ring-trimmed) |
| `user://logs/last_session.json` | Last clean shutdown marker |
| `user://telemetry/echo_lattice_balance.jsonl` | Existing balance telemetry (`LocalTelemetry`) |

On Windows Steam builds these resolve under the Godot userdata folder (see Support FAQ).

### 2.2 Event schema (crash channel)

```jsonc
{
  "channel": "crash",
  "schema_version": 1,
  "t_unix_ms": 1786243363374,
  "build_id": "1.0.0+steam.42",
  "godot": "4.3.stable",
  "os": "Windows",
  "os_version": "10.0.22631",
  "locale": "en",
  "kind": "engine_error",          // engine_error | freeze_watchdog | softlock | unhandled | breadcrumb
  "severity": "Identifier expected",
  "stack": ["res://scripts/chamber.gd:412", "..."],
  "context": {
    "scene": "chamber",
    "mode": "daily",
    "chamber_id": "18_cement_trail",
    "seed": 13001,
    "friend_code": "EL-13001",
    "act": "pressure",
    "save_version": 2
  },
  "notes": "player-optional short string from export dialog"
}
```

Rules:

- No profile display name, no absolute machine user path in exported packs (strip `user://` → relative).
- `stack` capped at 32 frames; `signature` is a stable hash of `kind|fingerprint|top_frame` for grouping.
- Breadcrumbs are not crashes; keep last **200** session lines (ring file or truncate on boot).

### 2.3 Capture hooks

| Source | When | Kind |
|---|---|---|
| `Engine` error / script error callback | Autoload boot | `engine_error` |
| `softlock_assert_failed` (balance / chamber) | Assert path | `softlock` |
| Freeze watchdog (main loop stall > N ms) | Optional, off if `reduce_motion` debug | `freeze_watchdog` |
| `NOTIFICATION_CRASH` / OS crash handler | If platform allows | `unhandled` |
| Scene change / run start / run end | Breadcrumb | `breadcrumb` |

Wire through an autoload `CrashLogHook` (fragment: `project.godot.crash_log.fragment`). Safe if absent: no-op stubs.

### 2.4 Export crash pack

Player path: **Options → Support → Export crash pack** (or FAQ manual copy).

Pack = zip or folder:

```
echo_lattice_crash_<YYYYMMDD_HHMM>/
  meta.json          # build_id, os, export time
  crash.jsonl        # copy of crash sink
  session.jsonl      # last session breadcrumbs
  save_head.json     # redacted: version, unlocks counts, last_daily_date — NOT full run history paths
  balance_tail.jsonl # last ≤100 lines of LocalTelemetry (optional checkbox)
```

Redaction: drop `profile.name` if present; keep chamber ids and seeds (needed to repro dailies).

---

## 3. Optional upload (design only for 1.0)

**Default: OFF.** Setting key: `settings.crash_upload_opt_in` (bool).

### 3.1 Contract

```
POST {CRASH_UPLOAD_URL}/v1/crash
Headers: Content-Type: application/json
Body: {
  "schema_version": 1,
  "build_id": "...",
  "signature": "...",
  "events": [ /* ≤20 crash-channel rows, no balance move spam */ ]
}
Response: { "ok": true, "ticket": "ELC-..." }
```

Constraints:

- Upload only events with `kind ∈ {engine_error, softlock, freeze_watchdog, unhandled}`.
- Rate limit: ≤3 uploads / UTC day / install (local counter).
- No Steam auth required for 1.0 optional path; ticket is enough for forum follow-up.
- Endpoint URL is a build-time constant or empty; **empty URL ⇒ feature compiles as local-only** (no network call sites hit).

### 3.2 What we refuse to collect

- Keystrokes / full move buffers.
- Screenshots unless the player attaches them manually on Steam.
- Friends list, Steam ID (unless we later add an explicit Steam ticket flow post-1.0).

### 3.3 Implementation fence

| Piece | 1.0 | Post-1.0 |
|---|---|---|
| Local JSONL + export pack | **Ship** | Maintain |
| Settings toggle UI | Ship (can be disabled/hidden if URL empty) | |
| HTTP upload client | Stub / no-op unless URL set | Enable with backend |
| Grouping dashboard | Out of scope | Studio tooling |

---

## 4. Godot API (stub)

```gdscript
# Autoload CrashLogHook
func configure(build_id: String, upload_url: String = "") -> void
func breadcrumb(scene: String, detail: Dictionary = {}) -> void
func report_engine_error(message: String, stack: PackedStringArray = []) -> void
func report_softlock(detail: Dictionary) -> void
func export_crash_pack(dest_dir: String, include_balance_tail := false) -> String  # returns path
func maybe_upload_latest() -> void  # no-op unless opt-in AND url non-empty
```

See `game/echo_lattice/scripts/ops/crash_log_hook.gd` for the local implementation. Network body intentionally omitted.

---

## 5. Acceptance

| ID | Check |
|---|---|
| CL-1 | Fresh boot creates `user://logs/` and writes a session breadcrumb. |
| CL-2 | Simulated engine error appends one crash JSONL line with `build_id`. |
| CL-3 | Export pack contains `meta.json` + crash/session files; no `profile.name`. |
| CL-4 | With default settings, zero network attempts (upload URL empty). |
| CL-5 | Softlock assert path can forward into `kind=softlock` without breaking `LocalTelemetry`. |

Headless contract tests live in `game/echo_lattice/tests/test_release_liveops.py` (schema + calendar; GDScript wiring verified when Godot is available).
