# Echo Lattice — Godot 4 project

A first-person tension vignette. The world you walk through is a lattice of
your own habits, played back at you.

This directory is the standalone Godot 4 project. Higher-level design and
marketing live in [`../../docs/`](../../docs/).

- **Engine:** [Godot 4.3+](https://godotengine.org/) (stable Forward+ renderer)
- **Primary platform:** Windows desktop (Steam)
- **Language:** GDScript, typed

## Open in the editor

1. Install Godot 4.3+ (standard build, not Mono/.NET unless you plan to add C#).
2. Launch Godot → **Import** → pick this directory's `project.godot`.
3. First-open will regenerate `.godot/` and any missing `.import` sidecars —
   this can take a minute for a cold checkout. That's expected.
4. Press **F5** (Run Project). The main scene is
   [`scenes/main/main.tscn`](scenes/main/main.tscn).

Recommended editor settings for this project:

- **Editor → Editor Settings → Interface → Editor → Main Font Antialiasing:** LCD
- **Editor Settings → Text Editor → Behavior → Files → Auto Reload Scripts:** on
- **Project → Project Settings → Rendering → Renderer:** Forward+

## Play controls

| Action           | Key(s)         |
| ---------------- | -------------- |
| Move             | `W A S D`      |
| Look             | Mouse          |
| Jump             | `Space`        |
| Crouch (walk)    | `Left Shift`   |
| Interact         | `E`            |
| Pause            | `Escape`       |
| Debug overlay    | `F3`           |

Mouse capture releases while paused.

## Project structure

```
game/echo_lattice/
├── project.godot                Engine config, autoloads, input map, layers
├── icon.svg                     App icon
├── export_presets.cfg.example   Windows export stub — copy before exporting
├── README.md                    This file
├── assets/                      Art, audio, fonts (drop-in folders)
│   ├── audio/
│   ├── fonts/
│   ├── images/
│   └── shaders/
├── scenes/
│   ├── main/                    Root scene + default environment
│   │   ├── main.tscn
│   │   ├── main.gd
│   │   └── default_env.tres
│   ├── player/                  First-person CharacterBody3D
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── chamber/                 One explorable room (spawnable at will)
│   │   ├── chamber.tscn
│   │   └── chamber.gd
│   ├── lattice_world/           Meta-world that instances chambers + player
│   │   ├── lattice_world.tscn
│   │   └── lattice_world.gd
│   └── ui/                      HUD + overlays
│       ├── ui_canvas.tscn
│       └── ui_canvas.gd
└── scripts/
    ├── autoload/                Singletons registered in project.godot
    │   ├── event_bus.gd
    │   ├── game_state.gd
    │   ├── habit_tracker.gd
    │   ├── audio_bus.gd
    │   └── scene_router.gd
    ├── systems/                 Reusable data + runtime types
    │   ├── habit_event.gd
    │   ├── lattice_node.gd
    │   └── echo.gd
    └── util/
        └── logger.gd
```

## Architecture at a glance

- **`EventBus`** — global signal hub. All cross-system communication goes
  through past-tense signals (`habit_recorded`, `chamber_entered`,
  `interactable_used`) so no gameplay node holds hard references to another.
- **`GameState`** — session-level state (paused, current chamber, run id).
- **`HabitTracker`** — buckets every `habit_recorded` event, persists them
  to `user://habits.save`, and exposes counts + recent history.
- **`AudioBus`** — sets up `Music` / `SFX` / `Ambience` / `UI` audio buses
  and provides a one-shot SFX pool.
- **`SceneRouter`** — fade-out / `change_scene_to_file` / fade-in with an
  overlay that survives scene changes.
- **`LatticeWorld`** — the meta-world. Instances the current `Chamber`,
  spawns the `Player`, and, when a habit crosses the resonance threshold,
  spawns an `Echo` that plays that habit back to the player.
- **`Chamber`** — a self-contained room scene. Announces `chamber_entered`
  / `chamber_exited` on ready / exit.
- **`Player`** — first-person `CharacterBody3D`. Movement is deliberately
  restrained; interaction and habit recording live here.
- **`UICanvas`** — always-on HUD (crosshair, transient messages, pause
  overlay, debug overlay).

## Exporting for Windows

1. In the editor: **Project → Export…**
2. **Manage Export Templates → Download and Install** the templates
   matching your editor version.
3. Copy `export_presets.cfg.example` to `export_presets.cfg` (it's
   gitignored).
4. Add a **Windows Desktop** preset, or import the stub. Point
   `export_path` at `build/windows/EchoLattice.exe`.
5. Click **Export Project** (uncheck "Export With Debug" for a shipping
   build). Godot writes `EchoLattice.exe` + `EchoLattice.pck` next to each
   other.

Headless export (CI or local one-shot):

```bash
godot --headless --export-release "Windows Desktop" build/windows/EchoLattice.exe
```

Run this from the project root (the directory containing `project.godot`).

## Steam / distribution notes

- Ship both `EchoLattice.exe` and `EchoLattice.pck` from the same folder,
  or check **Embed PCK** on the preset to bundle them into a single `.exe`.
  Embedding makes patches slightly larger for Steam depot uploads; leaving
  the PCK external makes patches smaller. Pick one and stick with it.
- Do **not** commit `export_presets.cfg` — it may contain signing paths
  and hashes local to your machine.
- Steamworks integration (GodotSteam or similar) is intentionally not in
  the scaffold. Add it as an addon under `addons/` once the vertical slice
  is playable.

## Coding style

- Typed GDScript everywhere (`func foo(x: int) -> void:`).
- `class_name` on any script that is instanced by name or referenced as a
  type; skip it on scene-only glue scripts.
- Snake_case for files, functions, and node paths; PascalCase for
  `class_name` and node display names.
- Cross-system talk goes through `EventBus`. Direct node references only
  within a scene's own subtree.
- Comments explain *why*, not *what*. Line-narrating comments get removed.
