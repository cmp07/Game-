# Echo Lattice — Godot 4 UI/UX Scaffold

A high-polish UI/UX layer for **Echo Lattice**, a short vignette about habits,
rewrite telegraphs, and the loops we choose to break. This branch ships the
shell only: menus, HUD, pause, settings, win/lose, tutorial prompts, and a
central theme. Gameplay simulation is intentionally stubbed so the UX can be
tuned and playtested in isolation.

## Requirements

- **Godot 4.3+** (any 4.x should work; developed against `4.3-stable`).

Open the project by pointing Godot at `game/project.godot`.

## Layout

```
game/
├── project.godot                — engine config, input map, autoloads
├── assets/icon.svg              — game icon
├── autoload/
│   ├── Settings.gd              — video/audio/keybinds, persists to user://
│   ├── Accessibility.gd         — font & UI scale, reduce motion, high contrast
│   ├── GameState.gd             — goal, habit, phase, rewrite queue
│   ├── SceneRouter.gd           — scene loads with fade transitions
│   └── Audio.gd                 — small UI SFX router (streams unregistered)
├── resources/
│   ├── default_bus_layout.tres  — Master / Music / SFX / UI buses
│   └── theme/
│       ├── echo_lattice_theme.tres
│       └── echo_lattice_theme_high_contrast.tres
├── scenes/
│   ├── boot/Boot.tscn           — 2-second ident that fades into menu
│   ├── menus/
│   │   ├── MainMenu.tscn        — New Loop / Continue / Settings / Credits / Quit
│   │   ├── SettingsDialog.tscn  — Video, Audio, Keybinds, Accessibility tabs
│   │   └── Credits.tscn
│   └── game/
│       ├── Game.tscn            — HUD + tutorial + pause + world backdrop
│       └── EndScreen.tscn       — win/lose overlay (reused)
├── ui/
│   ├── HUD.tscn/gd              — goal banner, timer, controls row
│   ├── HabitMeter.tscn/gd       — 0..100 gauge with readable-window band
│   ├── RewriteTelegraph.tscn/gd — countdown card with accept/hold prompts
│   ├── TutorialLayer.tscn/gd    — queued toast prompts
│   ├── PauseMenu.tscn/gd        — modal overlay while paused
│   ├── LatticeArt.gd            — procedural lattice backdrop
│   └── KeybindRow.tscn/gd       — one line of the keybind rebinder
└── scripts/
    ├── Boot.gd
    ├── MainMenu.gd
    ├── Credits.gd
    ├── Game.gd
    ├── EndScreen.gd
    ├── SettingsDialog.gd
    └── World.gd
```

## Features

- **Consistent theme** — cyan/violet on deep navy; buttons, sliders, tabs,
  option buttons, tooltips, and popups all share styling. Focus stylebox is
  bright cyan so keyboard/gamepad navigation is always visible.
- **Main menu** — reduced-motion aware animated lattice art, five clear
  actions, keyboard + gamepad focus, footer hints.
- **HUD**
  - **Goal banner** with kicker + current stanza.
  - **Habit meter** — vertical 0..100 gauge with readable-window band that
    flashes on delta and re-colors when the value leaves the target zone.
  - **Rewrite telegraph** — countdown card that changes color as ETA elapses
    and rewrites the prompt string to reflect the user's current keybinds.
  - **Loop timer** and dynamic **controls row**.
- **Pause menu** — modal overlay with dim + scale-in tween. `Esc` / `Start`
  toggle. Buttons: Resume, Settings, Return to Menu, Quit.
- **Settings**
  - **Video** — window mode, resolution, VSync, frame limit, UI scale,
    reduce motion, screen shake, high contrast toggle.
  - **Audio** — master / music / sfx / ui sliders, master mute.
  - **Keybinds** — parallel keyboard-and-gamepad rebinding for every action;
    `Reset to Defaults` restores project.godot bindings.
  - **Accessibility** — font scale (0.85..1.5, live), dyslexic-font toggle
    (stub), colorblind mode picker (stub), subtitle size.
- **Tutorial prompts** — bottom-center toast that queues, animates in/out,
  and can be disabled globally from settings.
- **Win/Lose** — shared EndScreen with copy, accent color, and stat summary.
- **Persistence** — `user://settings.cfg` stores every setting including
  keybinds; loads on boot without needing a restart.
- **Gamepad + keyboard parity** — every UI action has both. Focus starts on
  the primary action of every screen.

## Debug helpers

While in the Game scene:

- `F5` — force win.
- `F6` — force lose.
- `E` / **A** — accept incoming rewrite.
- `Q` / **X** — hold incoming rewrite.
- `R` / **Y** — reset loop (pulls habit toward steady).
- `Esc` / **Start** — pause.

## Roadmap

- Register real SFX streams via `Audio.register()` (nav, confirm, cancel,
  rewrite ping, tick, win, lose).
- Replace the default font with a bespoke pair once art direction is locked.
- Implement the true rewrite scheduler; the `GameState` API is already
  stable (`schedule_rewrite`, `resolve_rewrite`, `adjust_habit`).
