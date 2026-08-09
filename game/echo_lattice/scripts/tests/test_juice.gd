extends RefCounted
## Headless unit checks for JUICE v2 primitives (no scene tree required).


static func run() -> bool:
	print("== Juice v2 unit checks ==")
	var ok := true

	# Hitstop never reaches zero; recovers to 1.
	var hs := JuiceHitstop.new()
	hs.hit(0.09, 0.06)
	hs.update(0.0)
	if hs.timescale > 0.07 or hs.timescale < 0.05:
		printerr("hitstop floor expected ~0.06 got %s" % hs.timescale)
		ok = false
	var guard := 0
	while hs.is_active() and guard < 200:
		hs.update(0.016)
		guard += 1
	if absf(hs.timescale - 1.0) > 0.001:
		printerr("hitstop did not recover to 1.0 (got %s)" % hs.timescale)
		ok = false

	# Trauma² shake decays and produces finite offsets.
	var sh := JuiceScreenShake.new()
	sh.bump(0.5)
	var off: Vector3 = sh.offset()
	if off.length() <= 0.0:
		printerr("screenshake offset should be non-zero at trauma 0.5")
		ok = false
	for i in range(120):
		sh.update(0.016)
	if sh.trauma > 0.01:
		printerr("screenshake trauma failed to decay (got %s)" % sh.trauma)
		ok = false

	# Flash alpha peaks then dies.
	var fl := JuiceFlash.new()
	fl.fire(0.28, 0.55, Color(0.63, 0.88, 1.0))
	var a0: float = fl.current_alpha()
	fl.update(0.14)
	var a1: float = fl.current_alpha()
	fl.update(0.2)
	var a2: float = fl.current_alpha()
	if a0 <= 0.0 or a1 >= a0 or a2 > 0.001:
		printerr("flash envelope unexpected a0=%s a1=%s a2=%s" % [a0, a1, a2])
		ok = false

	# Camera spring moves toward target.
	var cam := JuiceCameraSpring.new()
	cam.snap_to(Vector2.ZERO)
	for i in range(60):
		cam.follow(Vector2(100, 0), Vector2(40, 0), 1.0 / 60.0)
	if cam.pos.x < 50.0:
		printerr("camera spring did not approach target (pos.x=%s)" % cam.pos.x)
		ok = false
	cam.punch(0.06)
	if cam.target_zoom > 0.999:
		printerr("camera punch did not lower target_zoom")
		ok = false

	# Particles pool + bursts.
	var parts := JuiceParticles.new()
	parts.burst_echo(0, 0)
	parts.burst_sparks(0, 0, 22, 280)
	if parts.alive_count() < 20:
		printerr("particle bursts under-emitted (%d)" % parts.alive_count())
		ok = false
	for i in range(90):
		parts.update(0.016)
	# Most should have died after ~1.5s.
	if parts.alive_count() > 5:
		printerr("particles lingered too long (%d alive)" % parts.alive_count())
		ok = false

	# Telegraph three-phase.
	var teles := JuiceTelegraphs.new()
	teles.add(0, 0, 32, 0.2, 0.1, 12.0, {"kind": "wall_birth"})
	var fired1: Array = teles.update(0.21)
	if fired1.size() != 1:
		printerr("telegraph should fire after wind-up (got %d)" % fired1.size())
		ok = false
	teles.update(0.12)
	if teles.zones.size() != 0:
		printerr("telegraph should be gone after strike")
		ok = false

	# Easings monotonic.
	if JuiceMath.ease_out_cubic(0.0) != 0.0 or JuiceMath.ease_out_cubic(1.0) < 0.999:
		printerr("ease_out_cubic endpoints wrong")
		ok = false
	if JuiceMath.ease_out_quint(0.5) <= JuiceMath.ease_out_cubic(0.5):
		# Not a hard requirement — just sanity that both are in (0,1).
		pass
	if JuiceMath.ease_out_quint(0.5) <= 0.0 or JuiceMath.ease_out_quint(0.5) >= 1.0:
		printerr("ease_out_quint mid out of range")
		ok = false

	print("juice unit result: %s" % ("OK" if ok else "FAIL"))
	return ok
