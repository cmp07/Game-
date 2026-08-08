## TestBase — the tiny assertion + reporting harness that every Echo
## Lattice test file extends. It is intentionally compatible with GUT
## (Godot Unit Test) at the source level so the same files can be run
## with `gut` if the plugin is installed: methods start with `test_`,
## each assertion appends to a per-test list of failures.
##
## When GUT is not available, `tests/test_runner.gd` discovers subclasses
## via a static manifest, calls `run(reporter)`, and aggregates results
## into a plain "OK / FAIL" report suitable for CI stdout.
class_name EchoLatticeTestBase
extends RefCounted

var _failures: Array = []
var _current_test: String = ""


func run(reporter: Object) -> int:
	# Walks every method starting with `test_`, calls it, and asks the
	# reporter to log the result. Returns the number of failures so the
	# outer runner can compute a total.
	var failures: int = 0
	var passed: int = 0
	for method_info in get_method_list():
		var name: String = String(method_info["name"])
		if not name.begins_with("test_"):
			continue
		_current_test = name
		_failures = []
		# Optional per-test setup/teardown mirror GUT's `before_each`/`after_each`.
		if has_method("before_each"):
			call("before_each")
		call(name)
		if has_method("after_each"):
			call("after_each")
		if _failures.is_empty():
			passed += 1
			reporter.report_pass(_test_display_name(), name)
		else:
			failures += 1
			reporter.report_fail(_test_display_name(), name, _failures)
	reporter.report_class_summary(_test_display_name(), passed, failures)
	return failures


func _test_display_name() -> String:
	var s: Script = get_script()
	if s == null:
		return "UnknownTest"
	var path: String = s.resource_path
	if path.is_empty():
		return "UnknownTest"
	return path.get_file().get_basename()


func fail(msg: String) -> void:
	_failures.append(msg)


func assert_true(cond: bool, msg: String = "") -> void:
	if not cond:
		fail("assert_true failed: %s" % msg)


func assert_false(cond: bool, msg: String = "") -> void:
	if cond:
		fail("assert_false failed: %s" % msg)


func assert_eq(a, b, msg: String = "") -> void:
	if not _deep_equal(a, b):
		fail("assert_eq failed: %s (a=%s b=%s)" % [msg, str(a), str(b)])


func assert_ne(a, b, msg: String = "") -> void:
	if _deep_equal(a, b):
		fail("assert_ne failed: %s (both=%s)" % [msg, str(a)])


func assert_gt(a: float, b: float, msg: String = "") -> void:
	if not (a > b):
		fail("assert_gt failed: %s (%s <= %s)" % [msg, str(a), str(b)])


func assert_ge(a: float, b: float, msg: String = "") -> void:
	if not (a >= b):
		fail("assert_ge failed: %s (%s < %s)" % [msg, str(a), str(b)])


func assert_lt(a: float, b: float, msg: String = "") -> void:
	if not (a < b):
		fail("assert_lt failed: %s (%s >= %s)" % [msg, str(a), str(b)])


func assert_le(a: float, b: float, msg: String = "") -> void:
	if not (a <= b):
		fail("assert_le failed: %s (%s > %s)" % [msg, str(a), str(b)])


func assert_in(needle, haystack, msg: String = "") -> void:
	if not (needle in haystack):
		fail("assert_in failed: %s (%s not in %s)" % [msg, str(needle), str(haystack)])


func assert_lattices_equal(a: Lattice, b: Lattice, msg: String = "") -> void:
	if a == null or b == null:
		fail("assert_lattices_equal: null argument (%s)" % msg)
		return
	if not a.equals(b):
		fail("assert_lattices_equal failed: %s\n  a=%s\n  b=%s" % [
			msg,
			str(a.to_rows()),
			str(b.to_rows()),
		])


func _deep_equal(a, b) -> bool:
	if typeof(a) != typeof(b):
		return false
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not _deep_equal(a[i], b[i]):
				return false
		return true
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for k in a.keys():
			if not b.has(k):
				return false
			if not _deep_equal(a[k], b[k]):
				return false
		return true
	return a == b
