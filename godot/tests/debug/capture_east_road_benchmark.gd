extends SceneTree
## Capture the playable East Road benchmark with Elara and the HUD.
## ./tools/godot.sh --path godot --script res://tests/debug/capture_east_road_benchmark.gd


const GAME_WORLD_SCENE := "res://scenes/world/game_world.tscn"
const OUT_PATH := "res://../tmp/scene_captures/at_03_east_road_benchmark.png"
const RENDER_SIZE := Vector2i(1920, 1080)
const REVIEW_SIZE := Vector2i(960, 540)


func _initialize() -> void:
	call_deferred(&"_capture")


func _capture() -> void:
	DisplayServer.window_set_title("Arcania East Road benchmark")
	DisplayServer.window_set_size(RENDER_SIZE)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	var packed := load(GAME_WORLD_SCENE) as PackedScene
	if packed == null:
		push_error("capture_east_road_benchmark: missing game world")
		quit(1)
		return
	var game_world := packed.instantiate()
	root.add_child(game_world)

	for _frame in 12:
		await process_frame
	await game_world.change_room(&"at_03_east_road", &"default", Vector2(800, 420))

	var debug_overlay := game_world.get_node_or_null("DebugOverlay") as CanvasLayer
	if debug_overlay:
		debug_overlay.visible = false
	var region_title := game_world.get_node_or_null("HUD/RegionNameToast") as Control
	if region_title:
		region_title.visible = false
	var player := game_world.get_node_or_null("Player") as CharacterBody2D
	if player:
		player.velocity = Vector2.ZERO

	for _frame in 24:
		await process_frame
	RenderingServer.force_draw()
	await process_frame

	var image := root.get_texture().get_image()
	image.resize(REVIEW_SIZE.x, REVIEW_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var absolute_path := ProjectSettings.globalize_path(OUT_PATH)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var error := image.save_png(absolute_path)
	if error != OK:
		push_error("capture_east_road_benchmark: save failed (%d)" % error)
		quit(1)
		return
	print("capture_east_road_benchmark: wrote ", absolute_path)
	quit(0)
