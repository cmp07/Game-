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
	"pa.undo.hint": "pa.board_tick",
	"pa.death.habit": "pa.attention",
	"pa.wing.clear": "pa.wing_clear",
	"pa.ghost.floor": "pa.board_tick",
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
	_fire(event_id)


func _fire(event_id: String) -> void:
	var director := get_node_or_null("/root/AudioDirector")
	if director and director.has_method("fire"):
		director.fire(event_id)
		pa_played.emit(event_id)
		return
	var manager := get_node_or_null("/root/AudioManager")
	if manager and manager.has_method("play_event"):
		manager.play_event(event_id)
		pa_played.emit(event_id)
