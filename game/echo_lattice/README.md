# Echo Lattice — Core Movement Slice

Minimal Godot 4 vertical slice: a lattice-style grid maze, one player, one goal, restart-on-key.
Scope is deliberately narrow — this is the "core movement + grid maze" foundation only.

## Movement mode (decision + rationale)

**Top-down, smooth (velocity-based) movement on a grid maze.**

- **View:** top-down orthographic 2D — clearest read on the lattice; cheapest to build.
- **Movement:** smooth velocity with acceleration + friction against a `CharacterBody2D` colliding with static wall bodies via `move_and_slide()`.
- **Why not first-person / grid-step:** first-person needs 3D assets and shader work outside a "core movement" slice. Grid-step (one-tile-per-input) reads as puppet-like and hides the collision system this slice is meant to exercise. Smooth top-down proves collision, camera follow, and reset in the smallest amount of code, and can be swapped for grid-step or first-person later without rewriting the maze/player split.

## Controls

| Action  | Keys                    |
|---------|-------------------------|
| Move    | `W A S D` / Arrow keys  |
| Restart | `R`                     |

Input actions are registered at runtime in `main.gd::_register_default_input_actions()` so the project runs without hand-edited `InputMap` entries in `project.godot`.

## Run

Requires **Godot 4.2+**.

```
godot --path game/echo_lattice
```

Or open `game/echo_lattice/project.godot` in the Godot 4 editor and press F5.

## Project layout

```
game/echo_lattice/
├── project.godot          # Godot 4 project config
├── icon.svg               # Project icon
├── main.tscn              # Single entry scene — hosts main.gd
├── .gitignore             # Ignores .godot/ import cache
├── README.md              # This file
└── scripts/
    ├── main.gd            # Bootstraps HUD, maze, player, camera + reset
    ├── maze.gd            # Turns ASCII layout into walls / start / goal
    ├── maze_generator.gd  # Randomized-DFS perfect maze generator
    └── player.gd          # CharacterBody2D controller (smooth top-down)
```

## Architecture notes

- **Pure logic vs. scene tree are separated.** `MazeGenerator` is a `RefCounted`
  with only static functions — deterministic given a seed, easy to test.
  `Maze` is a `Node2D` that turns an ASCII layout into concrete nodes
  (`StaticBody2D` walls, `Area2D` goal, decorative markers).
- **No hidden state in `project.godot`.** Input actions and the maze layout are
  defined in code, so cloning the folder is enough to get a runnable project.
- **Camera is childed to the player** and clamped to the maze bounds so the
  view never scrolls into the void.
- **Signals over polling.** The goal fires `Maze.goal_touched(body)`; `main.gd`
  filters on the player node — no per-frame distance checks.

## Legend (ASCII layout)

| Char | Meaning |
|------|---------|
| `#`  | Wall    |
| `.`  | Floor   |
| `S`  | Start   |
| `G`  | Goal    |

`MazeGenerator.generate(cells_wide, cells_tall, seed)` produces a perfect maze
(one unique path between any two cells) using randomized-DFS. The seed is fixed
in `main.gd::MAZE_SEED` for reproducibility; set it to `0` to randomize per run.

## Next slices (out of scope here)

- Multiple mazes / level progression
- Echo mechanic (record + replay a past path)
- Enemies / hazards
- Audio + juice pass
- Export presets for Windows Steam build
