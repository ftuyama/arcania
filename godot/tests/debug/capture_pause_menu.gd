extends SceneTree
## Capture the pause menu for visual QA.

const VIEWPORT_SIZE := Vector2i(960, 540)
const OUT_PATH := "res://../tmp/scene_captures/pause_menu.png"


func _initialize() -> void:
	call_deferred(&"_run_capture")


func _run_capture() -> void:
	var packed: PackedScene = load("res://scenes/ui/ui_layer.tscn") as PackedScene
	var ui: CanvasLayer = packed.instantiate()
	root.add_child(ui)

	var pause_menu: Control = ui.get_node("PauseMenu")
	pause_menu.visible = true

	# Simulate future content expansion to verify scrolling instead of clipping.
	var vbox: VBoxContainer = pause_menu.get_node("Panel/Margin/ScrollContainer/VBox")
	for i in 4:
		var btn := Button.new()
		btn.text = "Extra %d" % (i + 1)
		vbox.add_child(btn)
		vbox.move_child(btn, vbox.get_child_count() - 2)
	if pause_menu.has_method(&"_fit_scroll_to_viewport"):
		pause_menu._fit_scroll_to_viewport()

	DisplayServer.window_set_title("Arcania pause menu capture")
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	for _i in 12:
		await process_frame

	RenderingServer.force_draw()
	await process_frame
	_capture_and_quit()


func _capture_and_quit() -> void:
	var viewport := root.get_viewport()
	var texture := viewport.get_texture()
	var image := texture.get_image()
	var abs_out := OUT_PATH
	if abs_out.begins_with("res://") or abs_out.begins_with("user://"):
		abs_out = ProjectSettings.globalize_path(abs_out)

	var parent_dir := abs_out.get_base_dir()
	if not parent_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(parent_dir)

	var err := image.save_png(abs_out)
	if err != OK:
		push_error("capture_pause_menu: save_png failed (%d)" % err)
		quit(1)
		return

	print("capture_pause_menu: wrote %s (%dx%d)" % [abs_out, image.get_width(), image.get_height()])
	quit(0)
