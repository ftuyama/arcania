extends SceneTree
## Capture a room/scene viewport to PNG for visual debugging.
## Prefer the shell wrapper: `./tools/capture_scene_screenshot.sh [scene|room_id] [out.png]`
## Direct: `godot --path godot --script res://tests/debug/capture_scene_screenshot.gd -- --scene=... --out=...`
##
## Use `--scene=game_world` (or res://scenes/world/game_world.tscn) to include HUD + player.


const DEFAULT_SCENE := "res://scenes/rooms/ashen_threshold/at_01_threshold_hub.tscn"
const GAME_WORLD_SCENE := "res://scenes/world/game_world.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const VIEWPORT_SIZE := Vector2i(960, 540)
const WARMUP_FRAMES := 12
const GAME_WORLD_WARMUP_FRAMES := 36

var _scene_path: String = DEFAULT_SCENE
var _out_path: String = ""
var _with_hud: bool = false
var _hide_debug: bool = true
var _room: Node
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

	_room = packed.instantiate()
	if _room == null:
		push_error("capture_scene_screenshot: failed to instantiate %s" % _scene_path)
		quit(1)
		return

	root.add_child(_room)
	_configure_window()

	var is_game_world := _scene_path == GAME_WORLD_SCENE or _room.name == &"GameWorld"
	if is_game_world:
		_hide_debug_overlay(_room)
		_setup_camera_from_player(_room)
		_suppress_region_toast(_room)
	else:
		if not (_room is Node2D):
			push_error("capture_scene_screenshot: root is not Node2D for %s" % _scene_path)
			quit(1)
			return
		_setup_camera()
		if _with_hud:
			_attach_hud()

	print("capture_scene_screenshot: rendering %s → %s" % [_scene_path, _out_path])

	var warmup := GAME_WORLD_WARMUP_FRAMES if is_game_world else WARMUP_FRAMES
	for _i in warmup:
		await process_frame

	if is_game_world:
		_suppress_region_toast(_room)

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
		elif arg == "--with-hud":
			_with_hud = true
		elif arg == "--show-debug":
			_hide_debug = false


func _resolve_scene(raw: String) -> String:
	var trimmed := raw.strip_edges()
	if trimmed.is_empty():
		return DEFAULT_SCENE
	if trimmed == "game_world" or trimmed == "game":
		return GAME_WORLD_SCENE
	if trimmed.begins_with("res://"):
		return trimmed
	if trimmed.ends_with(".tscn"):
		return trimmed

	var candidates: PackedStringArray = [
		"res://scenes/rooms/ashen_threshold/%s.tscn" % trimmed,
		"res://scenes/rooms/whisperwood_hollow/%s.tscn" % trimmed,
		"res://scenes/rooms/dev/%s.tscn" % trimmed,
		"res://scenes/world/%s.tscn" % trimmed,
		"res://scenes/%s.tscn" % trimmed,
	]
	for path: String in candidates:
		if ResourceLoader.exists(path):
			return path

	push_error("capture_scene_screenshot: unknown scene/room_id '%s'" % trimmed)
	quit(1)
	return DEFAULT_SCENE


func _attach_hud() -> void:
	var hud_packed := load(HUD_SCENE) as PackedScene
	if hud_packed == null:
		push_warning("capture_scene_screenshot: could not load HUD")
		return
	var hud := hud_packed.instantiate()
	root.add_child(hud)


func _hide_debug_overlay(world: Node) -> void:
	if not _hide_debug:
		return
	var debug := world.get_node_or_null("DebugOverlay")
	if debug:
		debug.visible = false


func _suppress_region_toast(world: Node) -> void:
	## Screenshot goal has no centered region title card during play.
	var hud := world.get_node_or_null("HUD")
	if hud == null:
		return
	var toast := hud.get_node_or_null("RegionNameToast") as CanvasItem
	if toast:
		toast.visible = false
		toast.modulate.a = 0.0
	var ui_layer := world.get_node_or_null("UILayer")
	if ui_layer:
		ui_layer.visible = false


func _setup_camera_from_player(world: Node) -> void:
	var player := world.get_node_or_null("Player") as Node2D
	_camera = Camera2D.new()
	_camera.enabled = true
	if player:
		player.add_child(_camera)
		_camera.position = Vector2.ZERO
	else:
		world.add_child(_camera)
		_camera.position = Vector2(VIEWPORT_SIZE) * 0.5
	if _camera.is_inside_tree():
		_camera.make_current()
	else:
		_camera.ready.connect(_camera.make_current, CONNECT_ONE_SHOT)


func _setup_camera() -> void:
	_camera = Camera2D.new()
	_camera.enabled = true
	(_room as Node2D).add_child(_camera)

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
	# Dark purple clear — matches Ashen sky so missing parallax isn't grey checkerboard.
	RenderingServer.set_default_clear_color(Color(0.102, 0.102, 0.18, 1.0))
	var vp := root.get_viewport()
	if vp:
		vp.transparent_bg = false
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

	# Composite onto opaque Ashen sky, then flatten — transparent void must
	# never become gray checkerboard in the PNG (common with RGBA→RGB alone).
	var sky := Color(0.102, 0.102, 0.18, 1.0)
	if image.get_format() == Image.FORMAT_RGBA8 or image.get_format() == Image.FORMAT_RGBA4444:
		var flat := Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
		flat.fill(sky)
		flat.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i.ZERO)
		image = flat
	if image.get_format() != Image.FORMAT_RGB8:
		image.convert(Image.FORMAT_RGB8)

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
