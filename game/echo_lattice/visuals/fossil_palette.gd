class_name FossilPalette
extends RefCounted
## Colorblind-safe palettes for path fossils (move-buffer heat / ghost trails).
## Color is never the only cue when fossil_use_patterns is on.

enum Mode {
	DEFAULT,
	PROTANOPIA,
	DEUTERANOPIA,
	TRITANOPIA,
	HIGH_CONTRAST,
	MONO_PATTERN,
}

enum FossilRole {
	FRESH, ## most recent steps
	WARM, ## mid buffer
	COLD, ## oldest fossils
	GHOST, ## assist / replay ghost
	OVERUSE, ## habit-infection accent
	CHECKPOINT,
}

## Pattern overlays used as a second channel (independent of hue).
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
			return "Protanopia (red-weak)"
		Mode.DEUTERANOPIA:
			return "Deuteranopia (green-weak)"
		Mode.TRITANOPIA:
			return "Tritanopia (blue-weak)"
		Mode.HIGH_CONTRAST:
			return "High contrast"
		Mode.MONO_PATTERN:
			return "Mono + patterns"
		_:
			return "Default"


## Returns Color for a fossil role under the active palette.
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


## Pattern cue so fossils remain distinct without relying on hue alone.
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
		FossilRole.OVERUSE:
			return Pattern.CROSSHATCH
		FossilRole.CHECKPOINT:
			return Pattern.SOLID
		_:
			return Pattern.NONE


## Convenience for renderers: color + pattern pair.
static func style_for(mode: Mode, role: FossilRole, use_patterns: bool) -> Dictionary:
	return {
		"color": color_for(mode, role),
		"pattern": pattern_for(role, use_patterns),
		"role": role,
		"mode": mode_to_string(mode),
	}


static func _default() -> Dictionary:
	return {
		FossilRole.FRESH: Color("5CE1FF"),
		FossilRole.WARM: Color("3AA0C8"),
		FossilRole.COLD: Color("2A5F78"),
		FossilRole.GHOST: Color("F0E6A8"),
		FossilRole.OVERUSE: Color("E85D4C"),
		FossilRole.CHECKPOINT: Color("FFFFFF"),
	}


static func _protan() -> Dictionary:
	## Blue / yellow / gray — avoids red-green confusion.
	return {
		FossilRole.FRESH: Color("0072B2"),
		FossilRole.WARM: Color("56B4E9"),
		FossilRole.COLD: Color("6C757D"),
		FossilRole.GHOST: Color("F0E442"),
		FossilRole.OVERUSE: Color("E69F00"),
		FossilRole.CHECKPOINT: Color("FFFFFF"),
	}


static func _deutan() -> Dictionary:
	## Okabe-Ito inspired; distinct from protan warm accents.
	return {
		FossilRole.FRESH: Color("0072B2"),
		FossilRole.WARM: Color("56B4E9"),
		FossilRole.COLD: Color("999999"),
		FossilRole.GHOST: Color("F0E442"),
		FossilRole.OVERUSE: Color("D55E00"),
		FossilRole.CHECKPOINT: Color("FFFFFF"),
	}


static func _tritan() -> Dictionary:
	## Red / cyan / magenta — avoids blue-yellow confusion.
	return {
		FossilRole.FRESH: Color("00B4D8"),
		FossilRole.WARM: Color("E63980"),
		FossilRole.COLD: Color("6D6875"),
		FossilRole.GHOST: Color("FFB703"),
		FossilRole.OVERUSE: Color("C1121F"),
		FossilRole.CHECKPOINT: Color("FFFFFF"),
	}


static func _high_contrast() -> Dictionary:
	return {
		FossilRole.FRESH: Color("FFFFFF"),
		FossilRole.WARM: Color("FFD60A"),
		FossilRole.COLD: Color("ADB5BD"),
		FossilRole.GHOST: Color("00F5D4"),
		FossilRole.OVERUSE: Color("FF006E"),
		FossilRole.CHECKPOINT: Color("FFFFFF"),
	}


static func _mono() -> Dictionary:
	## Luminance steps; patterns carry identity.
	return {
		FossilRole.FRESH: Color("F8F9FA"),
		FossilRole.WARM: Color("CED4DA"),
		FossilRole.COLD: Color("868E96"),
		FossilRole.GHOST: Color("E9ECEF"),
		FossilRole.OVERUSE: Color("FFFFFF"),
		FossilRole.CHECKPOINT: Color("FFFFFF"),
	}
