extends Node
## Autoload: tiny session state for the MVP stub.
## Loop: Recover Fragments → Bind Thread → Tension Structure across the void.

signal fragments_changed(count: int)
signal threads_changed(count: int)
signal structure_seated
signal prompt_changed(text: String)

var fragment_inventory: Array[String] = []
var thread_count: int = 0
var structure_built: bool = false

const MAX_CARRY := 4
const COMBINE_COST := 2


func reset() -> void:
	fragment_inventory.clear()
	thread_count = 0
	structure_built = false
	fragments_changed.emit(0)
	threads_changed.emit(0)
	prompt_changed.emit("Walk the frayed field. Collect Fragments near the void.")


func can_carry() -> bool:
	return fragment_inventory.size() < MAX_CARRY


func add_fragment(family: String) -> bool:
	if not can_carry():
		prompt_changed.emit("Carry full (%d). Press C to combine two into a Thread." % MAX_CARRY)
		return false
	fragment_inventory.append(family)
	fragments_changed.emit(fragment_inventory.size())
	prompt_changed.emit("Collected %s. Fragments: %d. Press C with 2+ to spin a Thread." % [
		family, fragment_inventory.size()
	])
	return true


func can_combine() -> bool:
	return fragment_inventory.size() >= COMBINE_COST and not structure_built


func combine_two_into_thread() -> bool:
	if fragment_inventory.size() < COMBINE_COST:
		prompt_changed.emit("Need two Fragments to bind a Thread.")
		return false
	var a: String = fragment_inventory.pop_back()
	var b: String = fragment_inventory.pop_back()
	thread_count += 1
	fragments_changed.emit(fragment_inventory.size())
	threads_changed.emit(thread_count)
	prompt_changed.emit("Bound %s + %s → Brace Thread. Stand at the void and press Space to weave." % [a, b])
	return true


func can_weave() -> bool:
	return thread_count > 0 and not structure_built


func seat_structure() -> bool:
	if thread_count <= 0:
		prompt_changed.emit("No Thread to tension. Combine Fragments first (C).")
		return false
	if structure_built:
		return false
	thread_count -= 1
	structure_built = true
	threads_changed.emit(thread_count)
	structure_seated.emit()
	prompt_changed.emit("Structure seated across the void. The span holds — stub complete.")
	return true
