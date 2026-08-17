extends SceneTree
## Diagnostic: load game_world, move player to hub FocusCrucible, check prompt & activation.


func _initialize() -> void:
	call_deferred(&"_run_test")


func _run_test() -> void:
	var gm: Node = root.get_node("GameManager")
	var game_world: Node2D = load("res://scenes/world/game_world.tscn").instantiate() as Node2D
	root.add_child(game_world)
	await process_frame
	await process_frame
	await process_frame

	var player: Player = game_world.get_node("Player") as Player
	var crucible: Area2D = null

	# RoomLoader changes room into RoomContainer.
	var container: Node2D = game_world.get_node("RoomContainer") as Node2D
	for child in container.get_children():
		var c := child.find_child("FocusCrucible", true, false) as Area2D
		if c:
			crucible = c
			break

	print("Game state: ", gm.state)
	print("Player exists: ", player != null)
	print("Player in group: ", player.is_in_group(&"player") if player else false)
	print("Crucible exists: ", crucible != null)

	if crucible and player:
		player.global_position = crucible.global_position + Vector2(0, -20)
		await process_frame
		await process_frame

		print("Crucible overlapping bodies: ", crucible.get_overlapping_bodies())
		var prompt: Label = null
		for c in crucible.get_children():
			if c is Label:
				prompt = c
				break
		print("Prompt visible: ", prompt.visible if prompt else "no prompt")
		print("Prompt text: ", prompt.text if prompt else "")

		# Simulate pressing interact.
		var event := InputEventAction.new()
		event.action = "interact"
		event.pressed = true
		Input.parse_input_event(event)
		await process_frame
		print("After interact: player HP=", player.health_component.current_hp, "/", player.health_component.max_hp)
		print("Last crucible bound: ", gm.has_bound_crucible())

	quit()
