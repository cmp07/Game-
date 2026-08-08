# Echo Lattice — Tech Architecture

**Product:** Echo Lattice (Game 1)  
**Engine:** Godot 4.x (GDScript, Compatibility or Forward+ — see Rendering)  
**SKU:** Windows desktop Steam (`.exe` + `.pck`), offline single-player  
**Doc index:** `00_PRODUCTION_BIBLE` · `01_GDD` · `02_SYSTEMS` · **`03_TECH_ARCHITECTURE`**  
**Status:** Architecture lock for scaffold + vertical slice  
**Last updated:** August 2026

---

## 1. Goals & non-goals

### Goals

| Goal | Implication |
|---|---|
| Readable habit → geometry rewrite | Deterministic lattice ops on CPU; ghost/buffer always visible |
| 60 fps on low-end Windows | Strict draw / particle / alloc budgets; no heavy 3D |
| Steam desktop ship | Real Windows export, Steamworks via GDExtension, Cloud optional |
| Parallel agent ownership | Clear folder layout + autoload contracts under `game/echo_lattice/` |
| Offline-first | Core loop never calls network |

### Non-goals (v1)

- Multiplayer / co-op / netcode of any kind  
- Runtime LLM / cloud worldgen  
- HTML5 / mobile as primary SKU  
- Open-world streaming, chunked 3D worlds  
- Live-service economies, server authority  

---

## 2. High-level runtime shape

```text
┌─────────────────────────────────────────────────────────────┐
│  Autoloads (process always)                                 │
│  App · Save · Audio · InputMap bootstrap · Steam (optional) │
└───────────────────────────┬─────────────────────────────────┘
                            │ change_scene / load chamber
┌───────────────────────────▼─────────────────────────────────┐
│  Main / Shell scene                                         │
│  UI overlays + SceneHost (current gameplay scene)           │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
   Boot / Title        Run (chamber)        Meta / Gallery
```

**Simulation model:** Discrete grid logic (cells, walls, keys, doors) with optional smooth presentation lerp. Rewrite operators run at checkpoints on the move buffer — never mid-step unless GDD explicitly allows soft adaptation ticks.

**Determinism contract:** Same `(chamber_template_id, seed, move_buffer, transform_id)` → identical lattice. No `randf()` in rewrite path without a seeded `RandomNumberGenerator` owned by `LatticeRNG`.

---

## 3. Scene tree

### 3.1 Boot

```text
Boot (Node)
├── ColorRect (fade / brand hold)
└── BootController.gd   # version check, Save.load_meta, goto Title
```

`project.godot` → `run/main_scene = res://scenes/boot/boot.tscn`

### 3.2 Shell (persistent UI host)

Loaded after boot; gameplay scenes are children of `SceneHost`, not full replacements of the shell (except hard reboot).

```text
Shell (Control)                         # full-rect, mouse_filter STOP on menus only
├── SceneHost (Node)                    # gameplay root swap target
├── HUD (CanvasLayer, layer=10)
│   ├── MoveBufferStrip                 # last N moves as glyphs
│   ├── HabitMeterRow                   # optional compact signature
│   ├── ChamberLabel                    # wing / chamber / seed string
│   └── PromptHints                     # contextual controls
├── PauseMenu (CanvasLayer, layer=20)
├── ToastLayer (CanvasLayer, layer=30)
└── Transition (CanvasLayer, layer=40)  # wipe / lattice shatter
```

### 3.3 Run (chamber gameplay)

Presentation: **2D top-down** (MVP). Camera is orthographic `Camera2D`.

```text
Run (Node2D)
├── World (Node2D)
│   ├── LatticeMap (TileMapLayer × N or custom LatticeRenderer)
│   │   ├── FloorLayer
│   │   ├── WallLayer
│   │   ├── PropLayer          # keys, doors, checkpoints
│   │   └── DebugOverlay       # rewrite preview (dev / accessibility)
│   ├── Entities (Node2D)
│   │   ├── Player (CharacterBody2D or Node2D + custom mover)
│   │   │   ├── Sprite2D / AnimatedSprite2D
│   │   │   ├── CollisionShape2D
│   │   │   └── MoveController.gd
│   │   ├── GhostTrail (Node2D)        # MultiMesh or Line2D of prior path
│   │   └── Pickups (Node2D)
│   ├── FX (Node2D)
│   │   ├── RewriteBurst               # CPUParticles2D / GPUParticles2D
│   │   └── FootstepDecals             # pooled sprites, short life
│   └── Camera2D
│       └── Shake / ParallaxHost
├── Systems (Node)                     # non-visual, owned by Run
│   ├── ChamberController.gd           # load template, win/lose, restart
│   ├── MoveBuffer.gd                  # ring buffer of InputSteps
│   ├── HabitSignature.gd              # aggregates → profile features
│   ├── LatticeRewriter.gd             # applies operators from 02_SYSTEMS
│   ├── SolvabilityGuard.gd            # post-rewrite path check
│   └── GhostRecorder.gd               # serialize path for replay
└── RunUIBinder.gd                     # pushes state to Shell HUD
```

**TileMap vs custom grid:** Prefer Godot 4 `TileMapLayer` for authored kits + collision. Keep a parallel **logical grid** (`PackedByteArray` / `Array[int]`) as source of truth for rewrite ops; bake to TileMap after each rewrite. Never rewrite by mutating TileMap cells ad hoc without updating the logical grid.

### 3.4 Title / Meta / Settings

```text
Title (Control)
├── BrandMark
├── Continue / New Run / Daily / Settings / Quit
└── SeedReveal (Label)                 # last seed + habit tagline

MetaHub (Control)                      # post-wing unlocks
├── TransformDeck
├── HabitProfileCard
└── DailyBoard (local only in v1)

Settings (Control)
├── Video (window, vsync, shake, flash)
├── Audio (master / sfx / music)
├── Accessibility (colorblind, hold-to-walk, reduce FX)
└── Controls (rebind)
```

### 3.5 Scene transition rules

| From → To | Method |
|---|---|
| Boot → Title | `change_scene_to_packed` once |
| Title ↔ Run / Meta | Shell `SceneHost` swap + Transition |
| Chamber → Chamber | Soft reload inside Run (no full scene change) |
| Fatal error / corrupt save | Boot with safe defaults |

---

## 4. Autoloads

Register in `project.godot` under `[autoload]`. Keep the set small; chamber-local systems stay under `Run/Systems`.

| Autoload | Path | Responsibility |
|---|---|---|
| `App` | `res://src/autoload/app.gd` | Build id, feature flags, scene routing helpers, pause ownership |
| `ELSave` | `res://src/autoload/el_save.gd` | Load/save meta + run slots; migration; atomic write |
| `ELAudio` | `res://src/autoload/el_audio.gd` | Buses, SFX pool, music stems, rewrite stingers |
| `ELEvents` | `res://src/autoload/el_events.gd` | Typed signal bus (rewrite, death, unlock) — avoid spaghetti |
| `ELSteam` | `res://src/autoload/el_steam.gd` | Optional GodotSteam wrapper; no-ops if addon missing |

**Optional (slice+):** `ELDebug` — overlay toggles, seed force, God-mode path draw. Strip or `#if` for release export.

### Autoload contracts (sketch)

```gdscript
# App
func go_title() -> void
func go_run(chamber_id: StringName, seed: int) -> void
func set_paused(p: bool) -> void

# ELSave
func load_meta() -> ElMeta
func save_meta(meta: ElMeta) -> Error
func write_run_slot(slot: int, data: ElRunState) -> Error
func read_run_slot(slot: int) -> ElRunState

# ELEvents (signals)
signal chamber_loaded(id: StringName, seed: int)
signal rewrite_applied(op_id: StringName, buffer_hash: int)
signal player_died(reason: StringName)
signal wing_cleared(wing_id: StringName)
```

**Do not autoload:** Player, LatticeRewriter, TileMap references. Those belong to the Run scene so chambers can be unit-tested / stubbed.

---

## 5. Networking

**None for v1.**

| Concern | Policy |
|---|---|
| Core loop | Offline only; airplane-mode playable |
| HTTP / WebSocket / ENet / MultiplayerAPI | Not used; do not add nodes |
| Daily “same seed as a friend” | Share seed string out-of-band (clipboard); local evaluation |
| Leaderboards / ghost races online | Post-1.0; Steam Leaderboards optional later via `ELSteam` |
| Analytics | None in v1 binary |
| GodotSteam | Achievements, Cloud (optional), overlay — **not** multiplayer sessions |

If a future agent adds networking, it must be a new doc revision + feature flag default **off**, and must not gate chamber solvability.

---

## 6. Save format

### 6.1 Location & names

| Slot | Path | Notes |
|---|---|---|
| Meta | `user://echo_lattice/meta.json` | Unlocks, settings, habit profile, last seed |
| Run | `user://echo_lattice/run_%d.json` | Active run (slot 0 default) |
| Ghost | `user://echo_lattice/ghosts/%s.bin` | Compact path dumps keyed by chamber+seed |
| Backup | `*.bak` beside target | Previous good file kept one deep |

Use `DirAccess.make_dir_recursive_absolute` for folders. Prefer JSON for meta/run (diffable, human support); binary for ghosts (volume).

### 6.2 Versioning

Every file starts with:

```json
{
  "format": 1,
  "game": "echo_lattice",
  "build": "0.1.0+slice"
}
```

`ELSave` runs migrations `format n → n+1` before gameplay. Unknown newer format → refuse load + toast, do not wipe silently.

### 6.3 Meta schema (`ElMeta`)

```json
{
  "format": 1,
  "game": "echo_lattice",
  "build": "0.1.0+slice",
  "settings": {
    "master_vol": 1.0,
    "sfx_vol": 1.0,
    "music_vol": 0.8,
    "window_mode": "borderless_window",
    "vsync": true,
    "shake": true,
    "flash": true,
    "colorblind": "off",
    "hold_to_walk": false,
    "reduce_fx": false,
    "language": "en"
  },
  "progress": {
    "unlocked_transforms": ["mirror"],
    "cleared_chambers": ["w1_c01"],
    "cleared_wings": [],
    "habit_profile": {
      "dash_heavy": 0.0,
      "loopy": 0.0,
      "hesitant": 0.0,
      "samples": 0
    },
    "achievements_local": []
  },
  "last_session": {
    "seed": 0,
    "chamber_id": "",
    "slot": 0,
    "unix_time": 0
  }
}
```

### 6.4 Run schema (`ElRunState`)

```json
{
  "format": 1,
  "game": "echo_lattice",
  "build": "0.1.0+slice",
  "slot": 0,
  "seed": 1840123,
  "wing_id": "wing_1",
  "chamber_id": "w1_c04",
  "transform_id": "mirror",
  "rng_state": 0,
  "move_buffer": [
    {"t": 0, "dir": "N"},
    {"t": 1, "dir": "E"}
  ],
  "inventory": {"keys": 1},
  "stats": {"deaths": 2, "rewrites": 5, "steps": 420},
  "flags": {"demo_cap": false}
}
```

`dir` enum: `N|E|S|W` (and later `WAIT` if systems allow). Timestamps `t` are step indices, not wall-clock.

### 6.5 Atomic write recipe

1. Serialize to string/bytes.  
2. Write `path.tmp`.  
3. `flush` / close.  
4. Rename over target (replace).  
5. Update `.bak` from previous target if present.  

Autosave: on chamber clear, on rewrite applied, on pause menu open, on `NOTIFICATION_WM_CLOSE_REQUEST`.

### 6.6 Steam Cloud (optional)

Map `user://echo_lattice/` via Steam Cloud if enabled. Keep files small (<1 MB meta+run). Ghost binaries: Cloud only if under budget; else local-only.

---

## 7. Input

### 7.1 Devices

| Device | v1 support |
|---|---|
| Keyboard | Required |
| Mouse | UI only (not required for move) |
| Gamepad (XInput / SDL) | Required by Demo |
| Touch | Not a target |

### 7.2 Actions (`project.godot` Input Map)

| Action | Defaults (KB) | Defaults (Pad) |
|---|---|---|
| `move_north` | W / ↑ | D-pad / stick up |
| `move_east` | D / → | D-pad / stick right |
| `move_south` | S / ↓ | D-pad / stick down |
| `move_west` | A / ← | D-pad / stick left |
| `interact` | E / Space | A / Cross |
| `undo` | Z / Backspace | X / Square |
| `restart_chamber` | R | Select + A (confirm) |
| `pause` | Esc | Start |
| `buffer_inspect` | Tab | Y / Triangle |

Stick → digital grid: use deadzone `0.5` and **one step per deflection** (edge trigger), matching keyboard discreteness. Hold-to-walk accessibility: repeat step every `settings.step_repeat_ms` (default 180 ms) while held.

### 7.3 Move pipeline

```text
InputMap → MoveController
  → validate neighbor walkable
  → commit step to MoveBuffer
  → tween/lerp presentation
  → emit step_committed
  → ChamberController checks checkpoint / goal / death
```

**Buffer rule:** Only successful steps enter the buffer (failed bumps optional as SFX-only, not habit). Exact rules live in `02_SYSTEMS.md`.

### 7.4 Rebinding

Settings writes overrides into `ElMeta.settings.binds` or Godot `InputMap` persistence via custom config. Ship defaults reset button.

---

## 8. Rendering approach

### 8.1 Mode

| Choice | MVP | Rationale |
|---|---|---|
| Dimension | 2D top-down | Matches pitch; cheapest readability |
| Renderer | **Compatibility** default for low-end; test Forward+ | Broader GPU coverage on old Intel/AMD |
| Viewport | Base design **1280×720**; stretch `canvas_items`, aspect `keep` | Crisp UI + integer-friendly tiles |
| Textures | PNG atlases, nearest or light filter per art bible | Modular corridor kit (≤8 tile archetypes) |

### 8.2 Visual stack

1. **Floor / wall TileMapLayers** — primary geometry after rewrite bake.  
2. **Accent infection** — modulate or overlay tiles overused in buffer (shader or atlas variant).  
3. **GhostTrail** — `Line2D` or MultiMesh instances of player silhouette; capped points.  
4. **Particles** — short-lived rewrite bursts only; pool aggressively.  
5. **Post** — optional subtle vignette / chromatic on rewrite (disable under `reduce_fx`).  

**No** realtime GI, SDFGI, VoxelGI, SSAO stacks, or full-screen blur spam.

### 8.3 Shaders (budgeted)

Allowed MVP shaders:

- Tile accent pulse (cheap fragment)  
- Transition wipe  
- Flash bang soft (accessibility-gated)  

Reject: heavy noise fog, multi-pass outlines on every sprite, per-tile unique materials.

### 8.4 Camera

`Camera2D` follow with deadzone; pixel-snap optional (`position_smoothing` modest). Screen shake via offset on Camera2D — magnitude scaled by settings.

---

## 9. Performance budgets (60 fps low-end)

**Target hardware (floor):** Intel UHD 620-class / GT 1030-class, 8 GB RAM, 1080p, Windows 10 x64.  
**Hard goal:** **16.6 ms** frame; soft warn at 12 ms script+physics.

| Budget | Limit | Notes |
|---|:---:|---|
| Logical grid | ≤ 64×64 per chamber | Prefer ≤ 32×48 handmade |
| Wall tiles drawn | ≤ 2k visible cells | One atlas, few source IDs |
| Active nodes under `Entities` | ≤ 64 | Pool pickups / FX |
| Ghost trail points | ≤ 256 | Decimate older samples |
| GPU/CPU particles live | ≤ 200 | Rewrite burst ≤ 0.6 s |
| Audio voices | ≤ 24 | Footsteps steal-oldest |
| GDScript alloc / frame (steady) | near-zero | Prealloc buffers; no per-frame `Dictionary` churn in rewrite hot path |
| Rewrite compute | ≤ 4 ms on floor CPU | If exceeded, staged bake across frames with input lock |
| Save hitch | ≤ 50 ms | Async-friendly; never mid-tween without pause |
| Cold start to Title | ≤ 3 s HDD | Small `res://` footprint |
| Working set RAM | ≤ 400 MB typical | Atlas discipline |

### 9.1 Profiling checklist

- Godot Debugger → Monitors: FPS, process, physics, draw calls, video mem  
- `LatticeRewriter` micro-bench in debug builds (usec before/after)  
- Steam Deck / low-end laptop playtest before Demo lock  

### 9.2 Degradation knobs (`settings.reduce_fx`)

Disable: particles, shake, accent pulse shader, ghost soft glow. Keep: tiles, player, HUD, rewrite correctness.

---

## 10. Folder layout (`game/echo_lattice/`)

Godot project root for this SKU:

```text
game/echo_lattice/
├── project.godot
├── export_presets.cfg          # committed (no secrets)
├── icon.svg
├── README.md                   # how to open / export
│
├── addons/
│   └── godotsteam/             # GDExtension; documented version pin
│
├── scenes/
│   ├── boot/
│   │   └── boot.tscn
│   ├── shell/
│   │   └── shell.tscn
│   ├── title/
│   ├── run/
│   │   ├── run.tscn
│   │   ├── player.tscn
│   │   └── components/
│   ├── meta/
│   └── ui/
│       ├── hud.tscn
│       ├── pause_menu.tscn
│       └── settings.tscn
│
├── src/
│   ├── autoload/
│   │   ├── app.gd
│   │   ├── el_save.gd
│   │   ├── el_audio.gd
│   │   ├── el_events.gd
│   │   └── el_steam.gd
│   ├── grid/
│   │   ├── logical_grid.gd
│   │   ├── grid_types.gd
│   │   └── grid_bake.gd        # logical → TileMapLayer
│   ├── habit/
│   │   ├── move_buffer.gd
│   │   ├── habit_signature.gd
│   │   └── ghost_recorder.gd
│   ├── lattice/
│   │   ├── rewriter.gd
│   │   ├── operators/          # mirror.gd, rotate.gd, thicken.gd, invert.gd
│   │   ├── solvability_guard.gd
│   │   └── lattice_rng.gd
│   ├── chamber/
│   │   ├── chamber_controller.gd
│   │   ├── chamber_data.gd     # Resource loader
│   │   └── win_lose.gd
│   ├── player/
│   │   └── move_controller.gd
│   └── util/
│       ├── ring_buffer.gd
│       └── atomic_file.gd
│
├── data/
│   ├── chambers/               # .tres / .json templates
│   ├── grammars/               # rewrite packs
│   ├── transforms/             # unlock definitions
│   └── localization/           # optional csv
│
├── art/
│   ├── tiles/
│   ├── player/
│   ├── ui/
│   ├── vfx/
│   └── fonts/
│
├── audio/
│   ├── sfx/
│   ├── music/
│   └── buses.tres              # if used
│
├── shaders/
│   ├── accent_pulse.gdshader
│   └── transition_wipe.gdshader
│
├── tests/                      # GUT or custom scene harness
│   ├── test_move_buffer.gd
│   ├── test_operators.gd
│   └── test_solvability.gd
│
├── build/                      # gitignored export output
└── steam/                      # vdf notes, depot layout (no secrets)
    └── README.md
```

**Repo-level docs** stay in `docs/ECHO_LATTICE/` (this file). Do not duplicate GDD into `res://` except short `data/` tables needed at runtime.

### Ownership hints (parallel agents)

| Area | Primary owner doc / agent |
|---|---|
| Scenes + movement | core-move / scaffold |
| Operators + schemas | `02_SYSTEMS` |
| Art atlases | art bible |
| Audio buses / stingers | audio bible |
| HUD / settings | UI polish |
| Juice FX within budgets | juice |
| Steam page metadata | metadata |

---

## 11. Export presets (Windows Steam)

Commit `export_presets.cfg` with **Windows Desktop** presets. Templates must match editor minor version.

| Preset name | Purpose |
|---|---|
| `windows_debug` | Dev shares, console enabled, remote debug OK |
| `windows_release` | Steam depot candidate |
| `windows_demo` | Feature flag / chamber gate for Demo depot |

### 11.1 Recommended knobs

```text
platform=Windows Desktop
binary_format/architecture=x86_64
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
application/modify_resources=true
application/company_name=<studio>
application/product_name=Echo Lattice
application/file_description=Echo Lattice
application/product_version=0.1.0.0
application/icon=res://icon.svg
```

**Release:**

- Export mode: export resources filtered (exclude `tests/`, `**/*_debug*`)  
- Encryption: optional later; not required for Demo  
- Embed PCK: `true` for single-file convenience **or** external `.pck` for Steam depot patching — pick one and document in `steam/README.md` (recommend **external `.pck`** for faster depot diffs)

### 11.2 Steamworks integration

- Addon: **GodotSteam** GDExtension pinned in `addons/godotsteam/` + `steam_appid.txt` for local only (**gitignored**).  
- `ELSteam` init on App ready; fail soft.  
- Achievements IDs listed in metadata doc; unlock calls are fire-and-forget.  
- Do not ship `steam_appid.txt` inside the Steam depot (Steam provides app id).

### 11.3 Local export commands (CI-friendly)

```bash
# Example — paths vary by runner image
godot4 --headless --path game/echo_lattice \
  --export-release "windows_release" build/windows/EchoLattice.exe
```

Artifacts land in `game/echo_lattice/build/` (gitignored).

---

## 12. CI ideas

Start lean; grow with the scaffold.

### 12.1 PR checks (GitHub Actions)

| Job | Trigger | Steps |
|---|---|---|
| `docs-lint` | PRs touching `docs/` | markdown link check optional; forbid secrets patterns |
| `gdscript-syntax` | PRs touching `game/echo_lattice/**` | `godot4 --headless --path … --quit-after 1` project load; optional [gdformat](https://github.com/Scony/godot-gdscript-toolkit) / gdlint |
| `unit-tests` | same | GUT headless or custom `tests/run_all.gd` |
| `export-windows` | main / tags / manual | Cache export templates; export `windows_release`; upload artifact |

### 12.2 Suggested workflow sketch

```yaml
# .github/workflows/echo-lattice.yml (future)
name: echo-lattice
on:
  pull_request:
    paths: ["game/echo_lattice/**", "docs/ECHO_LATTICE/**"]
  workflow_dispatch:
jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Godot
        uses: # community Godot action pinned to 4.x
      - name: Load project
        run: godot4 --headless --path game/echo_lattice --quit-after 1
      - name: Run tests
        run: godot4 --headless --path game/echo_lattice -s res://tests/run_all.gd
```

Windows export may need `windows-latest` + matching templates; keep that job `workflow_dispatch` until templates are cached reliably.

### 12.3 Acceptance gates (not all automated)

- Chamber solvability tests from `02_SYSTEMS` (automated)  
- 60 fps soak on low-end (manual / scheduled)  
- Determinism: replay fixture seed → golden grid hash  
- Demo gate: cannot open post-demo chambers  

### 12.4 Secrets

Steam upload (SteamCMD) only on protected workflow with secrets: `STEAM_USERNAME`, `STEAM_PASSWORD` / MFA strategy, app/depot ids. Never put Steam Guard into the repo.

---

## 13. Risk register

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Rewrite feels random / unfair | H | H | Always show ghost + seed; preview overlay; solvability guard with constrained re-roll |
| R2 | Frame spikes on rewrite bake | M | H | Budget 4 ms; double-buffer grid; stage bake; reduce_fx path |
| R3 | TileMap / logical grid desync bugs | M | H | Single bake API; assert hashes in debug; tests per operator |
| R4 | Scope creep (editor, Workshop, MP) | H | H | Non-goals lock; chambers-first milestone DoD |
| R5 | Cold abstract aesthetic → poor wishlist CTR | M | M | Art/audio bibles; accent infection; trailer beat mandatory |
| R6 | GodotSteam / export template mismatch | M | M | Pin versions in README; CI project-load smoke |
| R7 | Save corruption / cloud clobber | L | H | Atomic writes, format migrations, `.bak`, Cloud size discipline |
| R8 | Input feel mismatch KB vs pad | M | M | Edge-trigger stick; shared MoveController; playtest matrix |
| R9 | Parallel agents conflict on `project.godot` | H | M | Ownership map; tiny PR slices; autoload list owned by tech/scaffold |
| R10 | Performance death by particles/juice | M | M | Budgets in §9; juice agent must profile; hard caps in code |
| R11 | Accessibility flash / seizure risk | L | H | `flash` setting default on but rewrite flashes capped; reduce_fx |
| R12 | Demo players judge “random maze” | M | H | First chamber no rewrite; second teaches mirror with ghost |

---

## 14. Implementation sequence (tech-only)

1. Scaffold `game/echo_lattice/` project + autoloads + Boot/Shell.  
2. Logical grid + player step + wall collision + camera.  
3. MoveBuffer + ghost trail + HUD strip.  
4. One operator (`mirror`) + bake + solvability assert.  
5. Save meta/run round-trip.  
6. Export `windows_debug` / `windows_release` smoke.  
7. Headless tests for buffer + operator fixtures.  
8. Hook GodotSteam no-op safe init.

Gameplay content counts and transform packs are owned by GDD/Systems — this doc only constrains **how** they plug in.

---

## 15. Related documents

| Doc | Role |
|---|---|
| `docs/ECHO_LATTICE/00_PRODUCTION_BIBLE.md` | Lock, milestones, ownership |
| `docs/ECHO_LATTICE/01_GDD.md` | Fantasy, loop, chambers |
| `docs/ECHO_LATTICE/02_SYSTEMS.md` | Formal rewrite models & schemas |
| `docs/FIVE_GAMES_TO_BUILD.md` (sibling PR) | Product pitch source |
| `docs/research/INVENTIVE_GAME_SEEDS.md` | Seed #05 origin |
| `docs/research/GODOT_AI_STEAM_PIPELINE.md` (sibling PR) | Export / Steam / AI-layer policy |

---

## 16. Decision log (tech)

| Decision | Choice | Rationale |
|---|---|---|
| Language | GDScript (typed where practical) | Speed of iteration; matches solo pipeline |
| Netcode | **None** | Product is offline adaptive puzzle |
| Presentation | 2D top-down grid | MVP clarity; fake-3D optional later |
| Source of truth | Logical grid → bake tiles | Safe rewrites + tests |
| Save | Versioned JSON + atomic write | Supportable, migratable |
| Renderer default | Compatibility | Low-end 60 fps floor |
| Project path | `game/echo_lattice/` | Multi-game repo isolation |
