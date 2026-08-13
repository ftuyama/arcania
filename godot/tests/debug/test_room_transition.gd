extends SceneTree
## Debug test for room transition spawn positions.

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
	if loader == null:
		push_error("RoomLoader not registered")
		quit(1)
		return

	var player: CharacterBody2D = get_first_node_in_group(&"player") as CharacterBody2D
	if player == null:
		push_error("Player not found")
		quit(1)
		return

	# Start in ww_02_whisper_path, then go west to ww_01_forest_gate.
	await loader.change_room(&"ww_02_whisper_path", &"default")
	print("spawned in ww_02 at %s" % player.global_position)

	# Simulate entering the west door (which has spawn_marker = from_right).
	await loader.change_room(&"ww_01_forest_gate", &"from_right")
	print("after west door: spawned in ww_01 at %s (expected right side ~1180)" % player.global_position)

	# Go back east to ww_02 (spawn_marker = from_left).
	await loader.change_room(&"ww_02_whisper_path", &"from_left")
	print("after east door: spawned in ww_02 at %s (expected left side ~80)" % player.global_position)

	quit(0)
