extends RefCounted
class_name SfxCatalog
## Path constants for Echo Lattice AUDIO v2 placeholders (and later authored audio).

# Locomotion / UI
const FOOTSTEP := "res://audio/sfx/footstep_placeholder.ogg"
const FOOTSTEP_BLOCKED := "res://audio/sfx/footstep_blocked_placeholder.ogg"
const UI_CLICK := "res://audio/ui/ui_click_placeholder.ogg"

# Rewrite (generic + warn)
const REWRITE := "res://audio/sfx/rewrite_placeholder.ogg"
const REWRITE_WARN := "res://audio/sfx/rewrite_warn_placeholder.ogg"

# Per-operator stingers (habit engine + transform pack)
const REWRITE_FOSSILIZE := "res://audio/sfx/rewrite/fossilize_hot_cell.ogg"
const REWRITE_DEFLECTOR := "res://audio/sfx/rewrite/place_deflector.ogg"
const REWRITE_CARVE := "res://audio/sfx/rewrite/carve_shortcut.ogg"
const REWRITE_GROW_WALL := "res://audio/sfx/rewrite/grow_wall_far_from_path.ogg"
const REWRITE_WIDEN := "res://audio/sfx/rewrite/widen_hot_corridor.ogg"
const REWRITE_MIRROR := "res://audio/sfx/rewrite/mirror.ogg"
const REWRITE_ROTATE := "res://audio/sfx/rewrite/rotate.ogg"
const REWRITE_THICKEN := "res://audio/sfx/rewrite/thicken.ogg"
const REWRITE_INVERT := "res://audio/sfx/rewrite/invert.ogg"

# Diegetic PA (no VO — tones only)
const PA_ATTENTION := "res://audio/sfx/pa/attention_chime.ogg"
const PA_BOARD_TICK := "res://audio/sfx/pa/board_tick.ogg"
const PA_REWRITE_ARMED := "res://audio/sfx/pa/rewrite_armed.ogg"
const PA_WING_CLEAR := "res://audio/sfx/pa/wing_clear.ogg"

# Win / queue-next addiction beat
const WIN := "res://audio/sfx/win_placeholder.ogg"
const WIN_CHAMBER := "res://audio/sfx/win/chamber_resolve.ogg"
const WIN_QUEUE_NEXT := "res://audio/sfx/win/queue_next.ogg"
const WIN_FANFARE := "res://audio/sfx/win/fanfare.ogg"
const WIN_WING := "res://audio/sfx/win/wing_clear.ogg"

# Adaptive music stems
const MUSIC_BED := "res://audio/music/bed_placeholder.ogg"
const MUSIC_L0 := "res://audio/music/L0_bed.ogg"
const MUSIC_L1 := "res://audio/music/L1_lattice.ogg"
const MUSIC_L2 := "res://audio/music/L2_habit.ogg"
const MUSIC_L3 := "res://audio/music/L3_rewrite.ogg"

const OPERATOR_STREAMS := {
	"fossilize_hot_cell": REWRITE_FOSSILIZE,
	"place_deflector": REWRITE_DEFLECTOR,
	"carve_shortcut": REWRITE_CARVE,
	"grow_wall_far_from_path": REWRITE_GROW_WALL,
	"widen_hot_corridor": REWRITE_WIDEN,
	"mirror": REWRITE_MIRROR,
	"rotate": REWRITE_ROTATE,
	"thicken": REWRITE_THICKEN,
	"invert": REWRITE_INVERT,
}


static func rewrite_stream_for_operator(operator_name: String) -> String:
	if OPERATOR_STREAMS.has(operator_name):
		return String(OPERATOR_STREAMS[operator_name])
	return REWRITE
