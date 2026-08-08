class_name EchoLog
extends RefCounted
##
## Tiny leveled logger. Prints go through here so we can flip verbosity in
## one place instead of hunting `print` statements before shipping.
##

enum Level { TRACE, DEBUG, INFO, WARN, ERROR }

static var level: Level = Level.INFO


static func trace(tag: String, msg: String) -> void:
	_emit(Level.TRACE, tag, msg)


static func debug(tag: String, msg: String) -> void:
	_emit(Level.DEBUG, tag, msg)


static func info(tag: String, msg: String) -> void:
	_emit(Level.INFO, tag, msg)


static func warn(tag: String, msg: String) -> void:
	_emit(Level.WARN, tag, msg)


static func error(tag: String, msg: String) -> void:
	_emit(Level.ERROR, tag, msg)


static func _emit(lvl: Level, tag: String, msg: String) -> void:
	if lvl < level:
		return
	var prefix := "[%s][%s]" % [_level_name(lvl), tag]
	match lvl:
		Level.WARN:
			push_warning("%s %s" % [prefix, msg])
		Level.ERROR:
			push_error("%s %s" % [prefix, msg])
		_:
			print("%s %s" % [prefix, msg])


static func _level_name(lvl: Level) -> String:
	match lvl:
		Level.TRACE: return "TRACE"
		Level.DEBUG: return "DEBUG"
		Level.INFO: return "INFO"
		Level.WARN: return "WARN"
		Level.ERROR: return "ERROR"
	return "?"
