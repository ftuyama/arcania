extends SceneTree
## Headless FPS profile for ww_07 — `godot --headless --path godot --script res://tests/integration/fps_profile_ww07.gd`


var _room: Node2D


func _initialize() -> void:
	PerformanceProfiler.reset()
	call_deferred(&"_run_profile")


func _run_profile() -> void:
	var scene: PackedScene = load(PerformanceProfiler.WW07_ROOM_PATH)
	if scene == null:
		push_error("fps_profile_ww07: failed to load %s" % PerformanceProfiler.WW07_ROOM_PATH)
		quit(1)
		return

	_room = scene.instantiate()
	root.add_child(_room)

	# Let room _ready / enemy spawns settle before budgeting.
	await process_frame
	await process_frame

	var budget := PerformanceProfiler.evaluate_room_budget(_room)
	if not budget.get("enemies_ok", false):
		push_error(
			"fps_profile_ww07: expected >= %d enemies, found %d"
			% [PerformanceProfiler.WW07_MIN_ENEMIES, int(budget.get("enemy_count", 0))]
		)
		quit(1)
		return
	if not budget.get("physics_ok", false):
		push_error(
			"fps_profile_ww07: physics bodies %d exceed budget %d"
			% [int(budget.get("physics_bodies", 0)), PerformanceProfiler.MAX_PHYSICS_BODIES]
		)
		quit(1)
		return

	for _i in PerformanceProfiler.WARMUP_FRAMES:
		await process_frame

	for _i in PerformanceProfiler.DEFAULT_SAMPLE_WINDOW:
		var t0 := Time.get_ticks_usec()
		await process_frame
		var frame_ms := float(Time.get_ticks_usec() - t0) / 1000.0
		PerformanceProfiler.record_frame(frame_ms / 1000.0)

	var summary := PerformanceProfiler.get_summary()
	if not PerformanceProfiler.meets_frame_budget(summary):
		push_error(
			"fps_profile_ww07: avg %.2f ms exceeds %.2f ms target (p95 %.2f ms)"
			% [
				float(summary.get("avg_ms", 0.0)),
				PerformanceProfiler.TARGET_FRAME_MS,
				float(summary.get("p95_ms", 0.0)),
			]
		)
		quit(1)
		return

	print(
		"fps_profile_ww07 passed: avg %.2f ms (%.1f FPS), p95 %.2f ms, bodies %d"
		% [
			float(summary.get("avg_ms", 0.0)),
			float(summary.get("avg_fps", 0.0)),
			float(summary.get("p95_ms", 0.0)),
			PerformanceProfiler.count_physics_bodies(_room),
		]
	)
	quit(0)
