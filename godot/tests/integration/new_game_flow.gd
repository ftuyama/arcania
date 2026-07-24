extends SceneTree
## Headless smoke test — title → new game → game world.


func _save_manager() -> Node:
	return root.get_node("SaveManager")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/ui/title_screen.tscn")
	if err != OK:
		push_error("title load failed: %s" % error_string(err))
		quit(1)
		return
	await process_frame
	_save_manager().start_new_game()
	err = change_scene_to_file("res://scenes/world/game_world.tscn")
	if err != OK:
		push_error("game_world load failed: %s" % error_string(err))
		quit(1)
		return
	for i in 10:
		await process_frame
	var ui := get_first_node_in_group(&"ui_layer")
	if ui == null:
		push_error("UILayer missing after new game")
		quit(1)
		return
	var overlay := ui.get_node_or_null("ControlsOverlay")
	if overlay == null:
		push_error("ControlsOverlay missing after new game")
		quit(1)
		return
	print("new game flow OK (overlay visible=%s)" % overlay.visible)
	quit(0)
