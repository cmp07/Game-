class_name PerfBudget
extends RefCounted
## Hard performance caps for Echo Lattice (1080p low-end / 60 fps).
## See docs/ECHO_LATTICE/10_PERFORMANCE.md.

const TARGET_FPS := 60
const FRAME_MS := 16.67
const SOFT_SCRIPT_MS := 12.0
const REWRITE_COMPUTE_MS := 4.0

const MAX_GRID_WIDTH := 64
const MAX_GRID_HEIGHT := 64
const PREFERRED_GRID_WIDTH := 32
const PREFERRED_GRID_HEIGHT := 48

const MAX_VISIBLE_WALL_CELLS := 2000
const MAX_ENTITY_NODES := 64

const MAX_FOSSILS_LIVE := 256
const FOSSIL_PREWARM := 64
const MAX_GHOST_TRAIL_POINTS := 256

const MAX_PARTICLES_LIVE := 200
const MAX_VFX_NODES_LIVE := 48
const VFX_FOOTSTEP_PREWARM := 24
const VFX_FOOTSTEP_CAP := 48
const VFX_REWRITE_PREWARM := 4
const VFX_REWRITE_CAP := 8
const VFX_OVERUSE_PREWARM := 8
const VFX_OVERUSE_CAP := 24
const REWRITE_BURST_MAX_SEC := 0.6

const MAX_AUDIO_VOICES := 24
const SAVE_HITCH_MS := 50.0
const WORKING_SET_MB := 400
const COLD_START_SEC := 3.0


static func fossil_cap() -> int:
	return MAX_FOSSILS_LIVE


static func grid_within_limits(width: int, height: int) -> bool:
	return width > 0 and height > 0 and width <= MAX_GRID_WIDTH and height <= MAX_GRID_HEIGHT
