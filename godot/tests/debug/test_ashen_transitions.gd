extends SceneTree
## Test ashen threshold and dev room transitions.

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

	var transitions: Array[Array] = [
		[&"at_01_threshold_hub", &"default"],
		[&"at_03_east_road", &"from_left"],
		[&"ww_01_forest_gate", &"from_right"],
		[&"at_03_east_road", &"from_left"],
		[&"at_01_threshold_hub", &"default"],
		[&"dev/test_room_01", &"default"],
		[&"dev/test_room_02", &"from_left"],
		[&"dev/test_room_01", &"from_right"],
	]

	for t in transitions:
		var room_id: StringName = t[0]
		var spawn: StringName = t[1]
		gm.change_room(room_id, spawn)
		for i in 3:
			await process_frame
		print("room=%s spawn=%s player=%s" % [gm.current_room_id, spawn, player.global_position])

	quit(0)
