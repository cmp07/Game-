extends Node
##
## Global signal hub.
##
## Systems emit and connect through EventBus instead of holding direct
## references to each other. This keeps Player / Chamber / LatticeWorld / UI
## decoupled: any of them can be swapped or reloaded without other systems
## breaking their connections.
##
## Convention: signals are named after past-tense facts ("player_moved"),
## not commands. Anything imperative should be a method call on the
## responsible node, not a bus signal.
##

# --- Player lifecycle ---------------------------------------------------------

signal player_spawned(player: Node3D)
signal player_despawned()
signal player_moved(position: Vector3, velocity: Vector3)
signal player_died(cause: StringName)

# --- Interaction --------------------------------------------------------------

signal interactable_focused(target: Node)
signal interactable_unfocused(target: Node)
signal interactable_used(target: Node, actor: Node)

# --- Habit / Echo lattice -----------------------------------------------------

## Emitted whenever a habit-worthy action happens. HabitTracker listens and
## buckets these into its rolling record; LatticeWorld listens to spawn echoes.
signal habit_recorded(kind: StringName, payload: Dictionary)

## Emitted by LatticeWorld when a new echo node is materialised.
signal echo_spawned(echo: Node)

## Emitted when a previously-recorded habit is played back to the player.
signal echo_replayed(kind: StringName, payload: Dictionary)

# --- Chamber / world flow -----------------------------------------------------

signal chamber_entered(chamber_id: StringName)
signal chamber_exited(chamber_id: StringName)
signal lattice_shifted(from_id: StringName, to_id: StringName)

# --- UI / meta ----------------------------------------------------------------

signal ui_message_requested(text: String, duration_s: float)
signal game_paused(paused: bool)
signal settings_changed(section: StringName, key: StringName, value: Variant)
