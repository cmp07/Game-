class_name FossilPalette
extends RefCounted
## Colorblind-safe roles for path fossils, echo walls, and ghost trails.
## Default mode stays inside Field Ledger (paper / ink / rust). Assist modes
## use Okabe–Ito-inspired hues; patterns remain a second non-color channel.

enum Mode {
	DEFAULT,
	PROTANOPIA,
	DEUTERANOPIA,
	TRITANOPIA,
	HIGH_CONTRAST,
	MONO_PATTERN,
}

enum FossilRole {
	FRESH, ## most recent steps / chalk
	WARM, ## mid buffer
	COLD, ## oldest fossils
	GHOST, ## assist / replay ghost
	OVERUSE, ## habit colonization
	ECHO_WALL, ## rewrite fossil walls
	CHECKPOINT,
	WARN, ## rewrite telegraph / cadmium
}

enum Pattern {
	NONE,
	SOLID,
	STRIPES,
	DOTS,
	CROSSHATCH,
	DASHES,
}


static func mode_from_string(name: String) -> Mode:
	match name.to_lower():
		"protanopia", "protan":
			return Mode.PROTANOPIA
		"deuteranopia", "deutan":
			return Mode.DEUTERANOPIA
		"tritanopia", "tritan":
			return Mode.TRITANOPIA
		"high_contrast", "high-contrast", "hc":
			return Mode.HIGH_CONTRAST
		"mono_pattern", "mono", "pattern":
			return Mode.MONO_PATTERN
		_:
			return Mode.DEFAULT


static func mode_to_string(mode: Mode) -> String:
	match mode:
		Mode.PROTANOPIA:
			return "protanopia"
		Mode.DEUTERANOPIA:
			return "deuteranopia"
		Mode.TRITANOPIA:
			return "tritanopia"
		Mode.HIGH_CONTRAST:
			return "high_contrast"
		Mode.MONO_PATTERN:
			return "mono_pattern"
		_:
			return "default"


static func all_mode_ids() -> PackedStringArray:
	return PackedStringArray([
		"default",
		"protanopia",
		"deuteranopia",
		"tritanopia",
		"high_contrast",
		"mono_pattern",
	])


static func display_name(mode: Mode) -> String:
	match mode:
		Mode.PROTANOPIA:
			return tr("colorblind.protanopia")
		Mode.DEUTERANOPIA:
			return tr("colorblind.deuteranopia")
		Mode.TRITANOPIA:
			return tr("colorblind.tritanopia")
		Mode.HIGH_CONTRAST:
			return tr("colorblind.high_contrast")
		Mode.MONO_PATTERN:
			return tr("colorblind.mono_pattern")
		_:
			return tr("colorblind.default")


static func color_for(mode: Mode, role: FossilRole) -> Color:
	match mode:
		Mode.PROTANOPIA:
			return _protan()[role]
		Mode.DEUTERANOPIA:
			return _deutan()[role]
		Mode.TRITANOPIA:
			return _tritan()[role]
		Mode.HIGH_CONTRAST:
			return _high_contrast()[role]
		Mode.MONO_PATTERN:
			return _mono()[role]
		_:
			return _default()[role]


static func pattern_for(role: FossilRole, use_patterns: bool) -> Pattern:
	if not use_patterns:
		return Pattern.SOLID
	match role:
		FossilRole.FRESH:
			return Pattern.SOLID
		FossilRole.WARM:
			return Pattern.STRIPES
		FossilRole.COLD:
			return Pattern.DOTS
		FossilRole.GHOST:
			return Pattern.DASHES
		FossilRole.OVERUSE, FossilRole.ECHO_WALL:
			return Pattern.CROSSHATCH
		FossilRole.CHECKPOINT:
			return Pattern.SOLID
		FossilRole.WARN:
			return Pattern.STRIPES
		_:
			return Pattern.NONE


static func style_for(mode: Mode, role: FossilRole, use_patterns: bool) -> Dictionary:
	return {
		"color": color_for(mode, role),
		"pattern": pattern_for(role, use_patterns),
		"role": role,
		"mode": mode_to_string(mode),
	}


static func _default() -> Dictionary:
	## Mirrors Palette / art bible Field Ledger.
	return {
		FossilRole.FRESH: Color("#F5EFDD"),
		FossilRole.WARM: Color("#D9CDB0"),
		FossilRole.COLD: Color("#3A342C"),
		FossilRole.GHOST: Color("#F5EFDD"),
		FossilRole.OVERUSE: Color("#8B3A1F"),
		FossilRole.ECHO_WALL: Color("#8B3A1F"),
		FossilRole.CHECKPOINT: Color("#2D4A55"),
		FossilRole.WARN: Color("#D6432B"),
	}


static func _protan() -> Dictionary:
	## Blue / yellow / gray — avoids red-green confusion.
	return {
		FossilRole.FRESH: Color("#F0E442"),
		FossilRole.WARM: Color("#56B4E9"),
		FossilRole.COLD: Color("#6C757D"),
		FossilRole.GHOST: Color("#F0E442"),
		FossilRole.OVERUSE: Color("#E69F00"),
		FossilRole.ECHO_WALL: Color("#0072B2"),
		FossilRole.CHECKPOINT: Color("#0072B2"),
		FossilRole.WARN: Color("#E69F00"),
	}


static func _deutan() -> Dictionary:
	return {
		FossilRole.FRESH: Color("#F0E442"),
		FossilRole.WARM: Color("#56B4E9"),
		FossilRole.COLD: Color("#999999"),
		FossilRole.GHOST: Color("#F0E442"),
		FossilRole.OVERUSE: Color("#D55E00"),
		FossilRole.ECHO_WALL: Color("#0072B2"),
		FossilRole.CHECKPOINT: Color("#0072B2"),
		FossilRole.WARN: Color("#D55E00"),
	}


static func _tritan() -> Dictionary:
	## Red / cyan / magenta — avoids blue-yellow confusion.
	return {
		FossilRole.FRESH: Color("#FFB703"),
		FossilRole.WARM: Color("#E63980"),
		FossilRole.COLD: Color("#6D6875"),
		FossilRole.GHOST: Color("#FFB703"),
		FossilRole.OVERUSE: Color("#C1121F"),
		FossilRole.ECHO_WALL: Color("#00B4D8"),
		FossilRole.CHECKPOINT: Color("#E63980"),
		FossilRole.WARN: Color("#C1121F"),
	}


static func _high_contrast() -> Dictionary:
	return {
		FossilRole.FRESH: Color("#FFFFFF"),
		FossilRole.WARM: Color("#FFD60A"),
		FossilRole.COLD: Color("#ADB5BD"),
		FossilRole.GHOST: Color("#00F5D4"),
		FossilRole.OVERUSE: Color("#FF006E"),
		FossilRole.ECHO_WALL: Color("#FFD60A"),
		FossilRole.CHECKPOINT: Color("#00F5D4"),
		FossilRole.WARN: Color("#FF006E"),
	}


static func _mono() -> Dictionary:
	## Luminance steps; patterns carry identity.
	return {
		FossilRole.FRESH: Color("#F8F9FA"),
		FossilRole.WARM: Color("#CED4DA"),
		FossilRole.COLD: Color("#868E96"),
		FossilRole.GHOST: Color("#E9ECEF"),
		FossilRole.OVERUSE: Color("#212529"),
		FossilRole.ECHO_WALL: Color("#495057"),
		FossilRole.CHECKPOINT: Color("#212529"),
		FossilRole.WARN: Color("#FFFFFF"),
	}
