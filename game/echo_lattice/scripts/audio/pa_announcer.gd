extends Node
## Diegetic PA — brutalist transit tones only (no VO).
## Pairs with on-screen copy from 12_TONE_AND_TUTORIAL; audio is institutional
## attention chimes / board ticks, never speech.

signal pa_played(event_id: String)

const LINE_TO_EVENT := {
	"pa.boot.lattice_online": "pa.attention",
	"pa.checkpoint.armed": "pa.rewrite_armed",
	"pa.rewrite.fired": "pa.attention",
	"pa.rewrite.matched": "pa.board_tick",
	"pa.rewrite.second_birth": "pa.board_tick",
	"pa.undo.hint": "pa.board_tick",
	"pa.death.habit": "pa.attention",
	"pa.wing.clear": "pa.wing_clear",
	"pa.ghost.floor": "pa.board_tick",
	"pa.ghost.race": "pa.board_tick",
}


func play_attention() -> void:
	_fire("pa.attention")


func play_board_tick() -> void:
	_fire("pa.board_tick")


func play_rewrite_armed() -> void:
	_fire("pa.rewrite_armed")


func play_wing_clear() -> void:
	_fire("pa.wing_clear")


## Map a diegetic line id (tone bible) to a PA tone event.
func play_line(line_id: String) -> void:
	var event_id := str(LINE_TO_EVENT.get(line_id, "pa.attention"))
	_subtitle_for_pa(line_id)
	_fire(event_id, false)


func _fire(event_id: String, with_subtitle: bool = true) -> void:
	if with_subtitle:
		_subtitle_for_pa(event_id)
	var director := get_node_or_null("/root/AudioDirector")
	if director and director.has_method("fire"):
		director.fire(event_id)
		pa_played.emit(event_id)
		return
	var manager := get_node_or_null("/root/AudioManager")
	if manager and manager.has_method("play_event"):
		manager.play_event(event_id)
		pa_played.emit(event_id)


func _subtitle_for_pa(line_or_event: String) -> void:
	## Pair institutional PA tones with on-screen stubs when subtitles are on.
	var tree := get_tree()
	if tree == null or tree.root == null:
		return
	var overlay := tree.root.find_child("SubtitleOverlay", true, false)
	if overlay == null or not overlay.has_method("show_line"):
		return
	var stub := line_or_event
	match line_or_event:
		"pa.attention":
			stub = "pa.boot.lattice_online"
		"pa.rewrite_armed":
			stub = "pa.checkpoint.armed"
		"pa.board_tick":
			# Prefer the original diegetic line id when play_line already mapped it.
			stub = "pa.ghost.floor"
		"pa.wing_clear":
			stub = "pa.wing.clear"
<<<<<<< HEAD
		"pa.rewrite.matched", "pa.rewrite.second_birth", "pa.undo.hint", "pa.checkpoint.armed", "pa.ghost.floor":
=======
		"pa.rewrite.matched", "pa.undo.hint", "pa.checkpoint.armed", "pa.ghost.floor", "pa.ghost.race":
>>>>>>> origin/cursor/g1-ghost-self
			stub = line_or_event
	overlay.call("show_line", stub)
