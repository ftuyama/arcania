extends SceneTree
## Test GameManager.change_room path used by actual door triggers.

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

	# Use GameManager.change_room as door triggers do.
	gm.change_room(&"ww_02_whisper_path", &"default")
	for i in 3:
		await process_frame
	print("loaded ww_02, player at %s" % player.global_position)

	gm.change_room(&"ww_01_forest_gate", &"from_right")
	for i in 3:
		await process_frame
	print("after west door via GM: room=%s player at %s" % [gm.current_room_id, player.global_position])

	quit(0)
