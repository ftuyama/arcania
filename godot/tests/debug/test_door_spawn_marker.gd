extends SceneTree
## Debug test to verify spawn_marker values on room transition instances.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/rooms/whisperwood_hollow/ww_02_whisper_path.tscn")
	var room := scene.instantiate()
	root.add_child(room)
	await process_frame

	var transitions := room.get_node("RoomTransitions")
	for child in transitions.get_children():
		if child.has_method("_on_body_entered"):
			print("door %s: target=%s spawn_marker=%s edge=%s" % [child.name, child.target_room_id, child.spawn_marker, child.edge])

	quit(0)
