## Headless test runner for Echo Lattice.
##
## Usage from the game/echo_lattice/ project root:
##
##     godot4 --headless --path . -s tests/test_runner.gd
##
## Exit code is 0 on all-green and 1 on any assertion failure so CI can
## treat this as a plain pass/fail check. When the GUT plugin is present
## the same test files can be run through it — see `docs/ECHO_LATTICE/09_QA.md`
## §"Running the automated suite" for the alternate invocation.
extends SceneTree

const TEST_MANIFEST: Array = [
	"res://tests/test_lattice.gd",
	"res://tests/test_move_buffer.gd",
	"res://tests/test_habit_profile.gd",
	"res://tests/test_solver.gd",
	"res://tests/test_maze_solvability.gd",
	"res://tests/test_habit_rewrite_invariants.gd",
]


class Reporter:
	extends RefCounted

	var passed_tests: int = 0
	var failed_tests: int = 0
	var failed_details: Array = []

	func report_pass(class_name_: String, test_name: String) -> void:
		passed_tests += 1
		print("  [PASS] %s::%s" % [class_name_, test_name])

	func report_fail(class_name_: String, test_name: String, failures: Array) -> void:
		failed_tests += 1
		var joined: String = "\n    ".join(failures)
		print("  [FAIL] %s::%s\n    %s" % [class_name_, test_name, joined])
		failed_details.append("%s::%s" % [class_name_, test_name])

	func report_class_summary(class_name_: String, passed: int, failed: int) -> void:
		print("  --- %s: %d passed, %d failed ---" % [class_name_, passed, failed])


func _init() -> void:
	var reporter: Reporter = Reporter.new()
	var start_ms: int = Time.get_ticks_msec()
	print("Echo Lattice test suite")
	print("=======================")
	for path in TEST_MANIFEST:
		print("")
		print("Running %s" % path)
		var script: Script = load(path)
		if script == null:
			push_error("could not load test script: %s" % path)
			reporter.failed_tests += 1
			continue
		var instance: Object = script.new()
		instance.run(reporter)
	var elapsed_ms: int = Time.get_ticks_msec() - start_ms
	var total: int = reporter.passed_tests + reporter.failed_tests
	print("")
	print("=======================")
	print("Totals: %d/%d passed (%d failed) in %dms" % [
		reporter.passed_tests,
		total,
		reporter.failed_tests,
		elapsed_ms,
	])
	if reporter.failed_tests > 0:
		print("Failed tests:")
		for detail in reporter.failed_details:
			print("  - %s" % detail)
		quit(1)
	else:
		quit(0)
