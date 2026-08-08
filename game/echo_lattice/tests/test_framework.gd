class_name EchoTestSuite
extends RefCounted

## Minimal xUnit-style base for pure-GDScript unit tests.
##
## Subclasses declare `test_*` methods. `run_all` discovers them via
## `get_method_list()` and executes each in a fresh instance of the subclass
## so per-test state is isolated. Failures are collected, not thrown, so a
## single failing assertion does not mask later tests.

var passed: int = 0
var failed: int = 0
var errors: Array = []             # Array<{test: String, msg: String}>
var current_test: String = ""


func run_all() -> void:
	var test_names := _collect_tests()
	test_names.sort()
	for name in test_names:
		var runner := _new_instance()
		runner.current_test = name
		if runner.has_method("before_each"):
			runner.call("before_each")
		runner.call(name)
		if runner.has_method("after_each"):
			runner.call("after_each")
		passed += runner.passed
		failed += runner.failed
		for e in runner.errors:
			errors.append(e)


func _new_instance() -> EchoTestSuite:
	var s := get_script() as Script
	return s.new()


func _collect_tests() -> Array:
	var out: Array = []
	for m in get_method_list():
		var n: String = m.name
		if n.begins_with("test_"):
			out.append(n)
	return out


# -----------------------------------------------------------------------------
# Assertions
# -----------------------------------------------------------------------------

func assert_true(v, msg: String = "") -> void:
	if v:
		passed += 1
	else:
		_fail("assert_true failed: %s" % msg)


func assert_false(v, msg: String = "") -> void:
	if not v:
		passed += 1
	else:
		_fail("assert_false failed: %s" % msg)


func assert_eq(actual, expected, msg: String = "") -> void:
	if _deep_equal(actual, expected):
		passed += 1
	else:
		_fail("assert_eq failed: expected %s, got %s. %s" % [_repr(expected), _repr(actual), msg])


func assert_ne(actual, expected, msg: String = "") -> void:
	if not _deep_equal(actual, expected):
		passed += 1
	else:
		_fail("assert_ne failed: %s == %s. %s" % [_repr(actual), _repr(expected), msg])


func assert_gt(actual, expected, msg: String = "") -> void:
	if actual > expected:
		passed += 1
	else:
		_fail("assert_gt failed: %s not > %s. %s" % [_repr(actual), _repr(expected), msg])


func assert_ge(actual, expected, msg: String = "") -> void:
	if actual >= expected:
		passed += 1
	else:
		_fail("assert_ge failed: %s not >= %s. %s" % [_repr(actual), _repr(expected), msg])


func assert_lt(actual, expected, msg: String = "") -> void:
	if actual < expected:
		passed += 1
	else:
		_fail("assert_lt failed: %s not < %s. %s" % [_repr(actual), _repr(expected), msg])


func assert_approx(actual: float, expected: float, tol: float = 1e-6, msg: String = "") -> void:
	if abs(actual - expected) <= tol:
		passed += 1
	else:
		_fail("assert_approx failed: |%f - %f| > %f. %s" % [actual, expected, tol, msg])


func assert_contains(collection, item, msg: String = "") -> void:
	var found := false
	for c in collection:
		if _deep_equal(c, item):
			found = true
			break
	if found:
		passed += 1
	else:
		_fail("assert_contains failed: %s not in %s. %s" % [_repr(item), _repr(collection), msg])


func assert_not_contains(collection, item, msg: String = "") -> void:
	var found := false
	for c in collection:
		if _deep_equal(c, item):
			found = true
			break
	if not found:
		passed += 1
	else:
		_fail("assert_not_contains failed: %s in %s. %s" % [_repr(item), _repr(collection), msg])


func fail(msg: String = "") -> void:
	_fail(msg)


func _fail(msg: String) -> void:
	failed += 1
	errors.append({"test": current_test, "msg": msg})


func _deep_equal(a, b) -> bool:
	if typeof(a) != typeof(b):
		return a == b
	if typeof(a) == TYPE_ARRAY:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not _deep_equal(a[i], b[i]):
				return false
		return true
	if typeof(a) == TYPE_DICTIONARY:
		if a.size() != b.size():
			return false
		for k in a.keys():
			if not b.has(k):
				return false
			if not _deep_equal(a[k], b[k]):
				return false
		return true
	return a == b


func _repr(v) -> String:
	return str(v)
