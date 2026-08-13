extends SceneTree
## Simulate actual player walking into doors to test transitions.

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

	# Load ww_02 and walk into west door to return to ww_01.
	await loader.change_room(&"ww_02_whisper_path", &"default")
	print("loaded ww_02, player at %s" % player.global_position)

	# Move player from outside west door (x=8) to inside (x=40) over frames.
	player.global_position = Vector2(8, 448)
	await process_frame
	for i in 10:
		player.global_position += Vector2(4, 0)
		await process_frame
	print("after walking into west door: room=%s player at %s" % [gm.current_room_id, player.global_position])

	# Now walk into east door of ww_01 to go back to ww_02.
	if gm.current_room_id == &"ww_01_forest_gate":
		player.global_position = Vector2(1272, 576)
		await process_frame
		for i in 10:
			player.global_position += Vector2(4, 0)
			await process_frame
		print("after walking into east door: room=%s player at %s" % [gm.current_room_id, player.global_position])

	quit(0)
