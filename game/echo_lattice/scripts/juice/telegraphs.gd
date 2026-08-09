class_name JuiceTelegraphs
extends RefCounted
## Three-phase foreshadow zones: wind-up → strike → done.


enum Phase { WINDUP, STRIKE, DONE }

signal fired(zone: Dictionary)

var zones: Array = []


func add(x: float, y: float, radius: float, wind_up: float, strike: float, hue: float = 12.0, meta: Variant = null) -> Dictionary:
	var z := {
		"x": x,
		"y": y,
		"radius": radius,
		"age": 0.0,
		"wind_up": wind_up,
		"strike": strike,
		"phase": Phase.WINDUP,
		"fired": false,
		"hue": hue,
		"meta": meta,
	}
	zones.append(z)
	return z


func clear() -> void:
	zones.clear()


func update(dt: float) -> Array:
	# Returns list of zones that entered STRIKE this tick.
	var just_fired: Array = []
	for i in range(zones.size() - 1, -1, -1):
		var z: Dictionary = zones[i]
		z["age"] = float(z["age"]) + dt
		if int(z["phase"]) == Phase.WINDUP and float(z["age"]) >= float(z["wind_up"]):
			z["phase"] = Phase.STRIKE
			z["fired"] = true
			just_fired.append(z)
			fired.emit(z)
		if int(z["phase"]) == Phase.STRIKE and float(z["age"]) >= float(z["wind_up"]) + float(z["strike"]):
			z["phase"] = Phase.DONE
		if int(z["phase"]) == Phase.DONE:
			zones.remove_at(i)
	return just_fired


func draw_on(ci: CanvasItem, now: float) -> void:
	for z in zones:
		var wind_up: float = float(z["wind_up"])
		var strike: float = float(z["strike"])
		var age: float = float(z["age"])
		var radius: float = float(z["radius"])
		var center := Vector2(float(z["x"]), float(z["y"]))
		var hue: float = float(z["hue"])
		var base := Color.from_hsv(hue / 360.0, 0.90, 0.70)

		if int(z["phase"]) == Phase.WINDUP:
			var wp: float = JuiceMath.clampf01(age / maxf(0.0001, wind_up))
			var floor_col := base
			floor_col.a = 0.06 + 0.18 * wp
			ci.draw_circle(center, radius, floor_col)
			# Outer dashed rotating ring (approximated as arc segments).
			var segs := 18
			var rot: float = now * 2.4
			var dash_col := base
			dash_col.a = 0.35 + 0.45 * wp
			for s in range(segs):
				if s % 2 == 1:
					continue
				var a0: float = rot + (float(s) / float(segs)) * TAU
				var a1: float = rot + (float(s + 1) / float(segs)) * TAU
				ci.draw_arc(center, radius, a0, a1, 8, dash_col, 2.0, true)
			# Filling arc timer.
			var fill := base
			fill.a = 0.85
			ci.draw_arc(center, radius * 0.72, -PI * 0.5, -PI * 0.5 + TAU * wp, 40, fill, 2.5, true)
			# Crosshair — jitter in last 15%.
			var jitter := Vector2.ZERO
			if wp > 0.85:
				jitter = Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))
			var cross := base
			cross.a = 0.7
			var c2: Vector2 = center + jitter
			ci.draw_line(c2 + Vector2(-5, 0), c2 + Vector2(5, 0), cross, 1.0, true)
			ci.draw_line(c2 + Vector2(0, -5), c2 + Vector2(0, 5), cross, 1.0, true)
		elif int(z["phase"]) == Phase.STRIKE:
			var sp: float = JuiceMath.clampf01((age - wind_up) / maxf(0.0001, strike))
			var fade: float = 1.0 - JuiceMath.ease_out_quint(sp)
			var disc := base
			disc.a = 0.55 * fade
			ci.draw_circle(center, radius * (0.85 + 0.25 * sp), disc)
			var ring := base
			ring.a = 0.9 * fade
			ci.draw_arc(center, radius * (1.0 + 0.35 * sp), 0.0, TAU, 48, ring, 2.5, true)
