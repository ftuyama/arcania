extends SceneTree
## Capture a room/scene viewport to PNG for visual debugging.
## Prefer the shell wrapper: `./tools/capture_scene_screenshot.sh [scene|room_id] [out.png]`
## Direct: `godot --path godot --script res://tests/debug/capture_scene_screenshot.gd -- --scene=... --out=...`


const DEFAULT_SCENE := "res://scenes/rooms/ashen_threshold/at_01_threshold_hub.tscn"
const VIEWPORT_SIZE := Vector2i(960, 540)
const WARMUP_FRAMES := 12

var _scene_path: String = DEFAULT_SCENE
var _out_path: String = ""
var _room: Node2D
var _camera: Camera2D


func _initialize() -> void:
	_parse_args()
	if _out_path.is_empty():
		_out_path = ProjectSettings.globalize_path("res://../tmp/scene_captures/capture.png")
	call_deferred(&"_run_capture")


func _run_capture() -> void:
	var packed: PackedScene = load(_scene_path) as PackedScene
	if packed == null:
		push_error("capture_scene_screenshot: failed to load %s" % _scene_path)
		quit(1)
		return

	_room = packed.instantiate() as Node2D
	if _room == null:
		push_error("capture_scene_screenshot: root is not Node2D for %s" % _scene_path)
		quit(1)
		return

	root.add_child(_room)
	_configure_window()
	_setup_camera()
	print("capture_scene_screenshot: rendering %s → %s" % [_scene_path, _out_path])

	for _i in WARMUP_FRAMES:
		await process_frame

	# Ensure the latest frame is presented before reading the texture.
	RenderingServer.force_draw()
	await process_frame
	_capture_and_quit()


func _parse_args() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			_scene_path = _resolve_scene(arg.substr("--scene=".length()))
		elif arg.begins_with("--out="):
			_out_path = arg.substr("--out=".length())


func _resolve_scene(raw: String) -> String:
	var trimmed := raw.strip_edges()
	if trimmed.is_empty():
		return DEFAULT_SCENE
	if trimmed.begins_with("res://"):
		return trimmed
	if trimmed.ends_with(".tscn"):
		return trimmed

	var candidates: PackedStringArray = [
		"res://scenes/rooms/ashen_threshold/%s.tscn" % trimmed,
		"res://scenes/rooms/whisperwood_hollow/%s.tscn" % trimmed,
		"res://scenes/rooms/dev/%s.tscn" % trimmed,
		"res://scenes/%s.tscn" % trimmed,
	]
	for path: String in candidates:
		if ResourceLoader.exists(path):
			return path

	push_error("capture_scene_screenshot: unknown scene/room_id '%s'" % trimmed)
	quit(1)
	return DEFAULT_SCENE


func _setup_camera() -> void:
	_camera = Camera2D.new()
	_camera.enabled = true
	_room.add_child(_camera)

	var bounds := _room.get_node_or_null("CameraBounds") as ReferenceRect
	if bounds == null:
		_camera.position = Vector2(VIEWPORT_SIZE) * 0.5
	else:
		var size := Vector2(bounds.offset_right, bounds.offset_bottom)
		if size.x <= 0.0 or size.y <= 0.0:
			_camera.position = Vector2(VIEWPORT_SIZE) * 0.5
		else:
			_camera.position = size * 0.5
			var zoom_x := float(VIEWPORT_SIZE.x) / size.x
			var zoom_y := float(VIEWPORT_SIZE.y) / size.y
			var z := minf(zoom_x, zoom_y)
			_camera.zoom = Vector2(z, z)

	if _camera.is_inside_tree():
		_camera.make_current()
	else:
		_camera.ready.connect(_camera.make_current, CONNECT_ONE_SHOT)


func _configure_window() -> void:
	DisplayServer.window_set_title("Arcania scene capture")
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	# Keep the window on-screen so the viewport actually renders (minimized = black).
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func _capture_and_quit() -> void:
	var viewport := root.get_viewport()
	var texture := viewport.get_texture()
	if texture == null:
		push_error("capture_scene_screenshot: viewport texture is null")
		quit(1)
		return

	var image := texture.get_image()
	if image == null or image.get_width() <= 0:
		push_error("capture_scene_screenshot: failed to read viewport image")
		quit(1)
		return

	var abs_out := _out_path
	if abs_out.begins_with("res://") or abs_out.begins_with("user://"):
		abs_out = ProjectSettings.globalize_path(abs_out)

	var parent_dir := abs_out.get_base_dir()
	if not parent_dir.is_empty():
		var mk_err := DirAccess.make_dir_recursive_absolute(parent_dir)
		if mk_err != OK and not DirAccess.dir_exists_absolute(parent_dir):
			push_error("capture_scene_screenshot: cannot create %s (err %d)" % [parent_dir, mk_err])
			quit(1)
			return

	var save_err := image.save_png(abs_out)
	if save_err != OK:
		push_error("capture_scene_screenshot: save_png failed (%d) for %s" % [save_err, abs_out])
		quit(1)
		return

	print("capture_scene_screenshot: wrote %s (%dx%d)" % [abs_out, image.get_width(), image.get_height()])
	quit(0)
