class_name FrameProfiler
extends RefCounted
## Lightweight scope timers for rewrite / bake / pool hotspots.
## Enable via `enabled = true` in debug overlays; no-ops when disabled.

signal budget_exceeded(scope: StringName, msec: float, budget_msec: float)

var enabled: bool = false
var _open: Dictionary = {} ## StringName -> usec start
var last_ms: Dictionary = {} ## StringName -> float ms
var peak_ms: Dictionary = {} ## StringName -> float ms


func begin(scope: StringName) -> void:
	if not enabled:
		return
	_open[scope] = Time.get_ticks_usec()


func end(scope: StringName, budget_msec: float = -1.0) -> float:
	if not enabled:
		return 0.0
	if not _open.has(scope):
		return 0.0
	var start_usec: int = int(_open[scope])
	_open.erase(scope)
	var msec: float = float(Time.get_ticks_usec() - start_usec) / 1000.0
	last_ms[scope] = msec
	if not peak_ms.has(scope) or msec > float(peak_ms[scope]):
		peak_ms[scope] = msec
	if budget_msec >= 0.0 and msec > budget_msec:
		budget_exceeded.emit(scope, msec, budget_msec)
	return msec


func reset_peaks() -> void:
	peak_ms.clear()
	last_ms.clear()


func snapshot() -> Dictionary:
	return {
		"enabled": enabled,
		"last_ms": last_ms.duplicate(),
		"peak_ms": peak_ms.duplicate(),
	}
