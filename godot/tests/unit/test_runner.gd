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
	failures += _test_dead_health_component_ignores_hits()
	failures += _test_experience_component()
	failures += _test_level_up_sfx()
	failures += _test_gate_failure_hints()
	failures += _test_playtest_tracker()
	failures += _test_performance_profiler()
	failures += _test_spell_manager()
	failures += _test_hub_quest()
	failures += _test_ability_gate_save_persistence()
	failures += _test_spore_glen_progression()
	failures += _test_save_manager()
	failures += _test_player_load_resets_death_state()
	failures += _test_enemy_hit_vfx()
	failures += _test_mobile_controls()
	failures += _test_map_toggle()
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


func _test_dead_health_component_ignores_hits() -> int:
	var health := HealthComponent.new()
	health.max_hp = 10
	health.current_hp = 10
	health.take_damage(10)
	health.take_damage(10)
	if health.current_hp != 0:
		push_error("HealthComponent should ignore damage after death")
		return 1
	return 0


func _test_experience_component() -> int:
	var experience := preload("res://scripts/components/experience_component.gd").new()
	if experience.get_xp_to_next_level() != 100:
		push_error("ExperienceComponent level 1 requirement should be 100")
		return 1
	experience.award_experience(100)
	if experience.level != 2 or experience.current_xp != 0:
		push_error("ExperienceComponent should level at 100 XP")
		return 1
	if experience.get_xp_to_next_level() != 125:
		push_error("ExperienceComponent level 2 requirement should be 125")
		return 1
	experience.award_experience(275)
	if experience.level != 4 or experience.current_xp != 0:
		push_error("ExperienceComponent should carry XP across multiple levels")
		return 1
	experience.set_progress(3, 150)
	if experience.level != 4 or experience.current_xp != 0:
		push_error("ExperienceComponent should normalize loaded overflow XP")
		return 1
	return 0


func _test_level_up_sfx() -> int:
	var audio_manager := root.get_node("AudioManager")
	audio_manager.play_ui("res://assets/audio/sfx/ui/ui_menu_confirm.wav")
	audio_manager.play_level_up()
	for child in audio_manager.get_children():
		var player := child as AudioStreamPlayer
		if player and player.bus == &"UI":
			if not player.stream is AudioStreamWAV:
				push_error("AudioManager should restore the level-up stream after UI audio")
				return 1
			return 0
	push_error("AudioManager UI player missing")
	return 1


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

	spells.acquire_spell(&"veil_step")
	spells.acquire_spell(&"rootbind")
	if spells.get_quick_slot(2) != &"veil_step":
		push_error("SpellManager should assign veil_step to quick slot 3")
		return 1
	if spells.get_quick_slot(3) != &"rootbind":
		push_error("SpellManager should assign rootbind to quick slot 4")
		return 1
	spells.set_quick_slot(2, &"rootbind")
	spells.set_quick_slot(3, &"veil_step")
	spells.apply_save_data(spells.get_save_data())
	if spells.get_quick_slot(2) != &"veil_step" or spells.get_quick_slot(3) != &"rootbind":
		push_error("SpellManager legacy quick-slot repair failed")
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
	if spells.get_quick_slot(2) != &"veil_step":
		push_error("SpellManager save round-trip lost quick slot")
		return 1

	spells.start_cooldown(&"ember_sigil")
	if not spells.is_on_cooldown(&"ember_sigil"):
		push_error("SpellManager start_cooldown failed")
		return 1

	spells.reset_to_defaults()
	return 0


func _test_hub_quest() -> int:
	var quests := root.get_node("QuestManager")
	quests.reset_to_defaults()
	if not quests.start_quest(&"null_rope_bind"):
		push_error("Null-Rope Bind should start after Corin's dialogue")
		return 1
	var quest: QuestData = quests.get_quest(&"null_rope_bind")
	if quest == null or quest.title != "Null-Rope Bind":
		push_error("Null-Rope Bind quest data is missing")
		return 1
	var hub_scene := load("res://scenes/rooms/ashen_threshold/at_01_threshold_hub.tscn") as PackedScene
	var hub := hub_scene.instantiate()
	var corin := hub.get_node_or_null("Entities/MagisterCorin")
	if corin == null or corin.get("quest_to_start") != &"null_rope_bind":
		push_error("Magister Corin should start Null-Rope Bind")
		hub.free()
		return 1
	if hub.get_node_or_null("Waystone") != null:
		push_error("Threshold hub should not contain a dormant Waystone")
		hub.free()
		return 1
	hub.free()
	quests.reset_to_defaults()
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


func _test_spore_glen_progression() -> int:
	var has_cast_key := false
	for event in InputMap.action_get_events(&"cast_spell"):
		if event is InputEventKey and event.physical_keycode == KEY_K:
			has_cast_key = true
			break
	if not has_cast_key:
		push_error("cast_spell should be bound to K")
		return 1

	var scene := load("res://scenes/rooms/whisperwood_hollow/ww_05_spore_glen.tscn") as PackedScene
	var room := scene.instantiate()
	var geometry := room.get_node_or_null("Geometry")
	var platforms: Array[Rect2] = geometry.platform_rects
	room.free()
	if platforms.size() < 2 or platforms[1].position.y != 480.0:
		push_error("Spore Glen's first platform should be reachable by a normal jump")
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


func _test_player_load_resets_death_state() -> int:
	var scene = load("res://scenes/player/player.tscn")
	if scene == null:
		push_error("Failed to load player scene for reset test")
		return 1
	var player = scene.instantiate()
	if player == null:
		push_error("Failed to instantiate player for reset test")
		return 1
	root.add_child(player)

	player.state_machine.transition_to(&"Dead", {})
	if player.state_machine.current_state.name != &"Dead":
		push_error("Player should enter Dead state for reset test")
		player.free()
		return 1

	player.reset_state()
	if player.state_machine.current_state.name != &"Idle":
		push_error("reset_state should return player to Idle")
		player.free()
		return 1
	if player.animated_sprite.modulate != Color.WHITE:
		push_error("reset_state should restore sprite color")
		player.free()
		return 1
	if player.is_invulnerable or player.health_component.is_invulnerable:
		push_error("reset_state should clear invulnerability")
		player.free()
		return 1

	player.free()
	return 0


func _test_enemy_hit_vfx() -> int:
	if EnemyHitVFX.resolve_damage_type(null) != &"physical":
		push_error("EnemyHitVFX null source should be physical")
		return 1

	var host := Node2D.new()
	root.add_child(host)
	EnemyHitVFX.spawn(host, Vector2.ZERO, Vector2.RIGHT, &"physical")
	EnemyHitVFX.spawn(host, Vector2.ZERO, Vector2.LEFT, &"fire")
	var vfx_count := 0
	for child in host.get_children():
		if child is EnemyHitVFX:
			vfx_count += 1
	if vfx_count < 2:
		push_error("EnemyHitVFX.spawn should add VFX nodes")
		host.queue_free()
		return 1

	var flash_script := load("res://scripts/components/hit_flash.gd") as GDScript
	var flash: Node = flash_script.new()
	var sprite := AnimatedSprite2D.new()
	root.add_child(sprite)
	root.add_child(flash)
	flash.call(&"setup", sprite)
	flash.call(&"flash")
	var mat := sprite.material as ShaderMaterial
	if mat == null or float(mat.get_shader_parameter(&"flash")) <= 0.0:
		push_error("HitFlash should set flash shader parameter")
		flash.queue_free()
		sprite.queue_free()
		host.queue_free()
		return 1

	flash.queue_free()
	sprite.queue_free()
	host.queue_free()

	var stalker_scene := load("res://scenes/enemies/bramble_stalker.tscn") as PackedScene
	if stalker_scene == null:
		push_error("Failed to load bramble_stalker.tscn")
		return 1
	var stalker := stalker_scene.instantiate() as Node
	if stalker == null or stalker.get_node_or_null("HitFlash") == null:
		push_error("BrambleStalker missing HitFlash node")
		if stalker:
			stalker.queue_free()
		return 1
	root.add_child(stalker)
	if stalker.has_method(&"play_hit_feedback"):
		stalker.call(&"play_hit_feedback", 5, null)
	else:
		push_error("BaseEnemy missing play_hit_feedback")
		stalker.queue_free()
		return 1
	var anim := stalker.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim == null or anim.material == null:
		push_error("play_hit_feedback should apply HitFlash material")
		stalker.queue_free()
		return 1
	stalker.queue_free()
	return 0


func _test_mobile_controls() -> int:
	var mobile_controls_script := load("res://scripts/ui/mobile_controls.gd") as GDScript
	var controls := mobile_controls_script.new() as CanvasLayer
	root.add_child(controls)
	for action in [
		&"move_left", &"move_right",
		&"jump", &"melee_attack", &"dash", &"interact",
		&"quick_spell_1", &"quick_spell_2", &"quick_spell_3", &"quick_spell_4",
	]:
		var button := controls.get_node_or_null(NodePath("GameplayControls/%s" % action)) as TouchScreenButton
		if button == null:
			push_error("MobileControls missing touch button: %s" % action)
			controls.queue_free()
			return 1
		if button.name != String(action):
			push_error("MobileControls button misnamed for action: %s" % action)
			controls.queue_free()
			return 1
		# Built-in action is intentionally empty so we can inject InputEventAction
		# events that reliably trigger Input.is_action_just_pressed() on mobile/web.
		if button.action != &"":
			push_error("MobileControls action should be manually injected: %s" % action)
			controls.queue_free()
			return 1
		if button.visibility_mode != TouchScreenButton.VISIBILITY_ALWAYS:
			push_error("MobileControls action should always be visible when enabled: %s" % action)
			controls.queue_free()
			return 1
	for action in [&"pause", &"map_toggle", &"inventory_toggle"]:
		var button := controls.get_node_or_null(NodePath("TopBar/%s" % action)) as TouchScreenButton
		if button == null:
			push_error("MobileControls missing top bar button: %s" % action)
			controls.queue_free()
			return 1
		if button.name != String(action):
			push_error("MobileControls top bar button misnamed for action: %s" % action)
			controls.queue_free()
			return 1
		if button.action != &"":
			push_error("MobileControls top bar action should be manually injected: %s" % action)
			controls.queue_free()
			return 1
		if button.visibility_mode != TouchScreenButton.VISIBILITY_ALWAYS:
			push_error("MobileControls top bar action should always be visible when enabled: %s" % action)
			controls.queue_free()
			return 1
	if not bool(controls.call(&"is_landscape")):
		push_error("MobileControls should treat the default viewport as landscape")
		controls.queue_free()
		return 1
	controls.queue_free()
	return 0


func _test_map_toggle() -> int:
	var ui_layer := load("res://scenes/ui/ui_layer.tscn") as PackedScene
	var ui := ui_layer.instantiate() as CanvasLayer
	root.add_child(ui)
	var game_manager := _autoload_game_manager()
	game_manager.state = game_manager.GameState.PLAYING
	paused = false
	var input := InputEventAction.new()
	input.action = &"map_toggle"
	input.pressed = true
	ui._unhandled_input(input)
	var map_overlay := ui.get_node_or_null("MapOverlay") as Control
	if map_overlay == null or not map_overlay.visible:
		push_error("Map toggle should open the map overlay")
		ui.queue_free()
		return 1
	if not paused or game_manager.state != game_manager.GameState.PAUSED:
		push_error("Map toggle should pause the game")
		ui.queue_free()
		return 1
	var grid := map_overlay.get_node_or_null("Panel/Margin/VBox/GridContainer") as GridContainer
	if grid == null or grid.get_child_count() == 0:
		push_error("Map toggle should render the map grid")
		ui.queue_free()
		return 1
	ui._unhandled_input(input)
	if paused or game_manager.state != game_manager.GameState.PLAYING:
		push_error("Map toggle should resume the game when closed")
		ui.queue_free()
		return 1
	ui.queue_free()
	return 0


func _cleanup_test_saves() -> void:
	for slot_id in [TEST_SAVE_SLOT, CORRUPT_SAVE_SLOT]:
		var path: String = SAVE_DIR + slot_id + ".json"
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
