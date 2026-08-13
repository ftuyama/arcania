extends SceneTree
## Debug test all standard left/right door transitions.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var err := change_scene_to_file("res://scenes/world/game_world.tscn")
	if err != OK:
		push_error("game_world load failed: %s" % error_string(err))
		quit(1)
		return
	for i in 5:
		await process_frame

	var gm: Node = root.get_node("GameManager")
	var loader: Node = gm.get_room_loader()
	var player: CharacterBody2D = get_first_node_in_group(&"player") as CharacterBody2D

	# List of connected room pairs and expected spawn side (left/right).
	# Format: [from_room, spawn_marker, to_room, expected_x_side]
	var transitions: Array[Array] = [
		[&"ww_01_forest_gate", &"from_left", &"ww_02_whisper_path", "left"],
		[&"ww_02_whisper_path", &"from_right", &"ww_01_forest_gate", "right"],
		[&"ww_02_whisper_path", &"from_left", &"ww_03_thorn_hollow", "left"],
		[&"ww_03_thorn_hollow", &"from_right", &"ww_02_whisper_path", "right"],
		[&"ww_03_thorn_hollow", &"from_left", &"ww_04_branch_crossing", "left"],
		[&"ww_04_branch_crossing", &"from_right", &"ww_03_thorn_hollow", "right"],
		[&"ww_04_branch_crossing", &"from_left", &"ww_05_spore_glen", "left"],
		[&"ww_05_spore_glen", &"from_right", &"ww_04_branch_crossing", "right"],
		[&"ww_05_spore_glen", &"from_left", &"ww_06_root_pit", "left"],
		[&"ww_06_root_pit", &"from_right", &"ww_05_spore_glen", "right"],
		[&"ww_06_root_pit", &"from_left", &"ww_07_heartwood_chamber", "left"],
		[&"ww_07_heartwood_chamber", &"from_right", &"ww_06_root_pit", "right"],
		[&"ww_07_heartwood_chamber", &"from_left", &"ww_08_vine_lift", "left"],
		[&"ww_08_vine_lift", &"from_right", &"ww_07_heartwood_chamber", "right"],
		[&"ww_08_vine_lift", &"from_left", &"ww_09_canopy_walk", "left"],
		[&"ww_09_canopy_walk", &"from_right", &"ww_08_vine_lift", "right"],
		[&"ww_09_canopy_walk", &"from_left", &"ww_10_matron_approach", "left"],
		[&"ww_10_matron_approach", &"from_right", &"ww_09_canopy_walk", "right"],
		[&"ww_10_matron_approach", &"from_left", &"ww_11_heartwood_grove", "left"],
		[&"ww_11_heartwood_grove", &"from_right", &"ww_10_matron_approach", "right"],
		[&"ww_11_heartwood_grove", &"from_left", &"ww_12_ironroot_gate", "left"],
		[&"ww_12_ironroot_gate", &"from_right", &"ww_11_heartwood_grove", "right"],
		[&"ww_12_ironroot_gate", &"from_left", &"ww_13_cart_tunnel", "left"],
		[&"ww_13_cart_tunnel", &"from_right", &"ww_12_ironroot_gate", "right"],
		[&"ww_13_cart_tunnel", &"from_left", &"ww_14_anchor_tutorial", "left"],
		[&"ww_14_anchor_tutorial", &"from_right", &"ww_13_cart_tunnel", "right"],
		[&"ww_14_anchor_tutorial", &"from_left", &"ww_15_ironroot_depths", "left"],
		[&"ww_15_ironroot_depths", &"from_right", &"ww_14_anchor_tutorial", "right"],
		[&"ww_15_ironroot_depths", &"from_left", &"ww_16_post_warden", "left"],
		[&"ww_16_post_warden", &"from_right", &"ww_15_ironroot_depths", "right"],
	]

	var failed := false
	for t in transitions:
		var to_room: StringName = t[2]
		var spawn: StringName = t[1]
		var expected: String = t[3]
		await loader.change_room(to_room, spawn)
		await process_frame
		var room: Node = loader.get_current_room()
		var bounds: Rect2i = room.get_camera_limits()
		var mid_x := bounds.position.x + bounds.size.x / 2
		var side := "right" if player.global_position.x >= mid_x else "left"
		var ok := side == expected
		if not ok:
			failed = true
		print("%s (%s): pos=%s mid=%s -> %s (expected %s) %s" % [to_room, spawn, player.global_position, mid_x, side, expected, "OK" if ok else "FAIL"])

	if failed:
		push_error("Some transitions placed the player on the wrong side.")
		quit(1)
	else:
		print("All transitions OK.")
		quit(0)
