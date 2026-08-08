extends SceneTree

## Headless test runner. Invoke with:
##   godot --headless --path game --script res://echo_lattice/tests/run_tests.gd
##
## Loads every test_*.gd suite, runs them, prints a summary, and exits with
## code 0 on success or 1 on any failure.

const TEST_SUITES := [
	"res://echo_lattice/tests/test_lattice.gd",
	"res://echo_lattice/tests/test_bfs.gd",
	"res://echo_lattice/tests/test_path_recorder.gd",
	"res://echo_lattice/tests/test_habit_signature.gd",
	"res://echo_lattice/tests/test_rewrite_operators.gd",
	"res://echo_lattice/tests/test_rewrite_engine.gd",
]


func _init() -> void:
	var total_pass := 0
	var total_fail := 0
	var t0 := Time.get_ticks_msec()
	var failures: Array = []

	print("== Echo Lattice unit tests ==")
	for path in TEST_SUITES:
		var suite_script: Script = load(path)
		if suite_script == null:
			printerr("Cannot load %s" % path)
			total_fail += 1
			continue
		var suite = suite_script.new()
		suite.run_all()
		var status := "ok" if suite.failed == 0 else "FAIL"
		var suite_name: String = path.get_file().get_basename()
		print("  %-32s %d passed, %d failed  [%s]" % [suite_name, suite.passed, suite.failed, status])
		for e in suite.errors:
			failures.append({"suite": suite_name, "test": e["test"], "msg": e["msg"]})
		total_pass += suite.passed
		total_fail += suite.failed

	var dt := Time.get_ticks_msec() - t0
	print("")
	print("== Result: %d passed, %d failed in %d ms ==" % [total_pass, total_fail, dt])
	if failures.size() > 0:
		print("")
		print("Failures:")
		for f in failures:
			print("  * [%s::%s] %s" % [f["suite"], f["test"], f["msg"]])

	quit(1 if total_fail > 0 else 0)
