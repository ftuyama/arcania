extends SceneTree
## Headless unit test runner — `godot --headless --path godot --script res://tests/unit/test_runner.gd`

const TEST_SAVE_SLOT := "_unit_test_slot"
const CORRUPT_SAVE_SLOT := "_corrupt_test_slot"
const SAVE_DIR := "user://saves/"


func _autoload_playtest_tracker() -> Node:
	return root.get_node("PlaytestTracker")


func _autoload_spell_manager() -> Node:
	return root.get_node("SpellManager")


func _autoload_save_manager() -> Node:
	return root.get_node("SaveManager")


func _autoload_game_manager() -> Node:
	return root.get_node("GameManager")


func _autoload_event_bus() -> Node:
	return root.get_node("EventBus")


func _initialize() -> void:
	call_deferred(&"_run_all_tests")


func _run_all_tests() -> void:
	var failures := 0
	failures += _test_modifier_stack()
	failures += _test_mana_shards()
	failures += _test_gate_failure_hints()
	failures += _test_playtest_tracker()
	failures += _test_performance_profiler()
	failures += _test_spell_manager()
	failures += _test_ability_gate_save_persistence()
	failures += _test_save_manager()
	_cleanup_test_saves()
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
	if GateFailureFeedback.build_hint(&"rootbind", &"") != "Vines resist this — reshape them with Rootbind":
		push_error("GateFailureFeedback rootbind hint mismatch")
		return 1
	if GateFailureFeedback.build_hint(&"ember_sigil", &"ember_receptor") != "Ember receptor — ignite with Ember Sigil or Ember Bolt":
		push_error("GateFailureFeedback ember receptor hint mismatch")
		return 1
	return 0


func _test_playtest_tracker() -> int:
	var tracker := _autoload_playtest_tracker()
	if tracker.format_playtime(125.0) != "2:05":
		push_error("PlaytestTracker format_playtime expected 2:05")
		return 1
	if not tracker.is_within_slice_target(50.0 * 60.0):
		push_error("PlaytestTracker 50 min should be within slice target")
		return 1
	if tracker.is_within_slice_target(30.0 * 60.0):
		push_error("PlaytestTracker 30 min should be outside slice target")
		return 1
	if tracker.get_total_checkpoints() < 8:
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


func _test_spell_manager() -> int:
	var spells := _autoload_spell_manager()
	spells.reset_to_defaults()
	if not spells.has_spell(&"ember_sigil"):
		push_error("SpellManager starter spell ember_sigil missing")
		return 1
	if not spells.has_spell(&"ember_bolt"):
		push_error("SpellManager starter spell ember_bolt missing")
		return 1
	if spells.has_spell(&"arc_step"):
		push_error("SpellManager arc_step should not be acquired by default")
		return 1

	spells.acquire_spell(&"rootbind")
	if not spells.has_spell(&"rootbind"):
		push_error("SpellManager acquire_spell rootbind failed")
		return 1
	spells.set_quick_slot(2, &"rootbind")
	if spells.get_quick_slot(2) != &"rootbind":
		push_error("SpellManager set_quick_slot failed")
		return 1
	spells.set_quick_slot(0, &"not_a_spell")
	if spells.get_quick_slot(0) != &"ember_sigil":
		push_error("SpellManager should reject unknown quick-slot spell")
		return 1

	var saved: Dictionary = spells.get_save_data()
	spells.reset_to_defaults()
	spells.apply_save_data(saved)
	if not spells.has_spell(&"rootbind"):
		push_error("SpellManager save round-trip lost acquired spell")
		return 1
	if spells.get_quick_slot(2) != &"rootbind":
		push_error("SpellManager save round-trip lost quick slot")
		return 1

	spells.start_cooldown(&"ember_sigil")
	if not spells.is_on_cooldown(&"ember_sigil"):
		push_error("SpellManager start_cooldown failed")
		return 1

	spells.reset_to_defaults()
	return 0


func _test_ability_gate_save_persistence() -> int:
	const GATE_ID := &"unit_test_vine_gate"
	var saves := _autoload_save_manager()
	var game := _autoload_game_manager()
	var bus := _autoload_event_bus()
	saves.start_new_game()
	bus.ability_gate_cleared.emit(GATE_ID)
	if not game.is_gate_cleared(GATE_ID):
		push_error("GameManager should track cleared gate from EventBus")
		return 1

	if not saves.save_game(TEST_SAVE_SLOT):
		push_error("SaveManager save failed for gate persistence test")
		return 1

	saves.start_new_game()
	if game.is_gate_cleared(GATE_ID):
		push_error("start_new_game should clear gate state")
		return 1

	if not saves.load_game(TEST_SAVE_SLOT):
		push_error("SaveManager load failed for gate persistence test")
		return 1
	if not game.is_gate_cleared(GATE_ID):
		push_error("cleared gate not restored after load")
		return 1
	return 0


func _test_save_manager() -> int:
	var saves := _autoload_save_manager()
	var game := _autoload_game_manager()
	var spells := _autoload_spell_manager()
	_cleanup_test_saves()
	saves.start_new_game()
	game.playtime_seconds = 42.5
	game.set_world_flag(&"unit_test_flag")
	spells.acquire_spell(&"veil_step")

	if not saves.save_game(TEST_SAVE_SLOT):
		push_error("SaveManager save_game failed")
		return 1
	if not saves.has_save(TEST_SAVE_SLOT):
		push_error("SaveManager has_save false after save")
		return 1

	var summary: Dictionary = saves.get_save_summary(TEST_SAVE_SLOT)
	if float(summary.get("playtime_seconds", 0.0)) != 42.5:
		push_error("SaveManager get_save_summary playtime mismatch")
		return 1

	saves.start_new_game()
	if saves.load_game("nonexistent_slot"):
		push_error("SaveManager load_game should fail for missing slot")
		return 1

	var corrupt_path: String = SAVE_DIR + CORRUPT_SAVE_SLOT + ".json"
	var corrupt_file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	if corrupt_file == null:
		push_error("SaveManager could not write corrupt test file")
		return 1
	corrupt_file.store_string("{not valid json")
	corrupt_file.close()
	if saves.load_game(CORRUPT_SAVE_SLOT):
		push_error("SaveManager load_game should fail on corrupt JSON")
		return 1

	if not saves.load_game(TEST_SAVE_SLOT):
		push_error("SaveManager load_game round-trip failed")
		return 1
	if not is_equal_approx(game.playtime_seconds, 42.5):
		push_error("SaveManager round-trip playtime mismatch")
		return 1
	if not game.has_world_flag(&"unit_test_flag"):
		push_error("SaveManager round-trip world flag missing")
		return 1
	if not spells.has_spell(&"veil_step"):
		push_error("SaveManager round-trip spell missing")
		return 1

	var path: String = SAVE_DIR + TEST_SAVE_SLOT + ".json"
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		parsed["version"] = 999
		var patched := FileAccess.open(path, FileAccess.WRITE)
		patched.store_string(JSON.stringify(parsed, "\t"))
		patched.close()
	saves.start_new_game()
	if not saves.load_game(TEST_SAVE_SLOT):
		push_error("SaveManager should still load save with version mismatch")
		return 1
	if not spells.has_spell(&"veil_step"):
		push_error("SaveManager version-mismatch load lost spell data")
		return 1

	saves.start_new_game()
	return 0


func _cleanup_test_saves() -> void:
	for slot_id in [TEST_SAVE_SLOT, CORRUPT_SAVE_SLOT]:
		var path: String = SAVE_DIR + slot_id + ".json"
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
