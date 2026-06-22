extends SceneTree
## Headless unit test runner — `godot --headless --script res://tests/unit/test_runner.gd`


func _initialize() -> void:
	var failures := 0
	failures += _test_modifier_stack()
	failures += _test_mana_shards()
	failures += _test_gate_failure_hints()
	failures += _test_playtest_tracker()
	failures += _test_performance_profiler()
	if failures == 0:
		print("All unit tests passed.")
	else:
		push_error("%d unit test(s) failed." % failures)
	quit(0 if failures == 0 else 1)


func _test_modifier_stack() -> int:
	var entry := ModifierEntry.new()
	entry.stat = &"burn_damage_mult"
	entry.op = ModifierEntry.ModifierOp.MULTIPLY
	entry.value = 1.2
	var mana_entry := ModifierEntry.new()
	mana_entry.stat = &"max_mana"
	mana_entry.op = ModifierEntry.ModifierOp.FLAT_ADD
	mana_entry.value = 10.0
	var result := ModifierStack.aggregate([entry, mana_entry] as Array[ModifierEntry])
	if not is_equal_approx(float(result.get("burn_damage_mult", 0.0)), 1.2):
		push_error("ModifierStack burn_damage_mult expected 1.2")
		return 1
	if int(result.get("max_mana", 0)) != 10:
		push_error("ModifierStack max_mana expected 10")
		return 1
	return 0


func _test_mana_shards() -> int:
	var mana := ManaComponent.new()
	mana.focus_shard_count = ManaComponent.BASE_SHARDS
	mana._recalc_max_mana()
	if mana.max_mana != ManaComponent.BASE_SHARDS * ManaComponent.MANA_PER_SHARD:
		push_error("ManaComponent base shards max mana mismatch")
		return 1
	if not mana.add_focus_shards(1):
		push_error("ManaComponent add_focus_shards failed")
		return 1
	if mana.focus_shard_count != ManaComponent.BASE_SHARDS + 1:
		push_error("ManaComponent shard count not incremented")
		return 1
	return 0


func _test_gate_failure_hints() -> int:
	if GateFailureFeedback._build_hint(&"rootbind", &"") != "Vines resist this — reshape them with Rootbind":
		push_error("GateFailureFeedback rootbind hint mismatch")
		return 1
	if GateFailureFeedback._build_hint(&"ember_sigil", &"ember_receptor") != "Ember receptor — ignite with Ember Sigil or Ember Bolt":
		push_error("GateFailureFeedback ember receptor hint mismatch")
		return 1
	return 0


func _test_playtest_tracker() -> int:
	if PlaytestTracker.format_playtime(125.0) != "2:05":
		push_error("PlaytestTracker format_playtime expected 2:05")
		return 1
	if not PlaytestTracker.is_within_slice_target(50.0 * 60.0):
		push_error("PlaytestTracker 50 min should be within slice target")
		return 1
	if PlaytestTracker.is_within_slice_target(30.0 * 60.0):
		push_error("PlaytestTracker 30 min should be outside slice target")
		return 1
	if PlaytestTracker.get_total_checkpoints() < 8:
		push_error("PlaytestTracker checkpoint count too low")
		return 1
	return 0


func _test_performance_profiler() -> int:
	PerformanceProfiler.reset(3)
	PerformanceProfiler.record_frame(1.0 / 60.0)
	PerformanceProfiler.record_frame(1.0 / 60.0)
	PerformanceProfiler.record_frame(1.0 / 60.0)
	var summary := PerformanceProfiler.get_summary()
	if not PerformanceProfiler.meets_frame_budget(summary):
		push_error("PerformanceProfiler 60 FPS samples should meet target")
		return 1

	PerformanceProfiler.reset(1)
	PerformanceProfiler.record_frame(1.0 / 30.0)
	summary = PerformanceProfiler.get_summary()
	if PerformanceProfiler.meets_frame_budget(summary):
		push_error("PerformanceProfiler 30 FPS sample should fail target")
		return 1

	var scene: PackedScene = load(PerformanceProfiler.WW07_ROOM_PATH)
	if scene == null:
		push_error("PerformanceProfiler ww_07 scene missing")
		return 1
	var room := scene.instantiate()
	var budget := PerformanceProfiler.evaluate_room_budget(room)
	room.free()
	if not budget.get("enemies_ok", false):
		push_error("ww_07 should ship with profiling enemy baseline")
		return 1
	if not budget.get("physics_ok", false):
		push_error("ww_07 physics body count exceeds budget")
		return 1
	return 0
