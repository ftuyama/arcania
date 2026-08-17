extends SceneTree
## Diagnostic: verify FocusCrucible detects player and prompt shows in hub room.


func _initialize() -> void:
	var room: Node2D = load("res://scenes/rooms/ashen_threshold/at_01_threshold_hub.tscn").instantiate() as Node2D
	root.add_child(room)
	await process_frame

	var crucible: Area2D = room.find_child("FocusCrucible", true, false) as Area2D
	var player: CharacterBody2D = load("res://scenes/player/player.tscn").instantiate() as CharacterBody2D
	player.global_position = Vector2(200, 680)
	room.add_child(player)
	await process_frame
	await process_frame

	print("Crucible found: ", crucible != null)
	print("Player found: ", player != null)
	print("Player in 'player' group: ", player.is_in_group(&"player"))
	print("Crucible monitoring: ", crucible.monitoring)
	print("Crucible layer/mask: ", crucible.collision_layer, "/", crucible.collision_mask)
	print("Player layer/mask: ", player.collision_layer, "/", player.collision_mask)
	print("Overlapping bodies: ", crucible.get_overlapping_bodies())

	var prompt := crucible.get_child(0) if crucible.get_child_count() > 0 else null
	for c in crucible.get_children():
		if c is Label:
			prompt = c
			break
	print("Prompt label found: ", prompt != null)
	if prompt:
		print("Prompt visible: ", prompt.visible)
		print("Prompt text: ", prompt.text)

	quit()
