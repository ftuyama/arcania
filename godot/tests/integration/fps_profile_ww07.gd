extends SceneTree
## Headless FPS profile for ww_07 — `godot --headless --path godot --script res://tests/integration/fps_profile_ww07.gd`


var _room: Node2D
var _frame := 0
var _budget_checked := false


func _initialize() -> void:
	PerformanceProfiler.reset()
	var scene: PackedScene = load(PerformanceProfiler.WW07_ROOM_PATH)
	if scene == null:
		push_error("fps_profile_ww07: failed to load %s" % PerformanceProfiler.WW07_ROOM_PATH)
		quit(1)
		return

	_room = scene.instantiate()
	root.add_child(_room)


func _process(delta: float) -> void:
	if not _budget_checked:
		_budget_checked = true
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

	_frame += 1
	if _frame <= PerformanceProfiler.WARMUP_FRAMES:
		return

	PerformanceProfiler.record_frame(delta)
	var total_frames := PerformanceProfiler.WARMUP_FRAMES + PerformanceProfiler.DEFAULT_SAMPLE_WINDOW
	if _frame < total_frames:
		return

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
