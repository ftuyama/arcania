extends SceneTree
## Capture Elara idle/walk/melee frames to tmp/scene_captures/ for animation QA.
## ./tools/godot.sh --path godot --script res://tests/debug/capture_player_anims.gd


const PLAYER_SCENE := "res://scenes/player/player.tscn"
const OUT_DIR := "res://../tmp/scene_captures/player_anims"
const VIEWPORT_SIZE := Vector2i(320, 240)


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	if packed == null:
		push_error("capture_player_anims: missing player scene")
		quit(1)
		return

	var player: Node = packed.instantiate()
	root.add_child(player)

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	get_root().size = VIEWPORT_SIZE

	var sprite := player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		push_error("capture_player_anims: no AnimatedSprite2D")
		quit(1)
		return

	sprite.position = Vector2(VIEWPORT_SIZE) * 0.5
	var cam := Camera2D.new()
	cam.position = sprite.position
	player.add_child(cam)
	cam.make_current()

	var out_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(out_dir)

	var anims: Array[StringName] = [&"idle", &"walk", &"jump", &"dash", &"melee_1", &"cast", &"hit"]
	for anim_name in anims:
		if not sprite.sprite_frames.has_animation(anim_name):
			push_warning("capture_player_anims: missing anim %s" % String(anim_name))
			continue
		var speed := sprite.sprite_frames.get_animation_speed(anim_name)
		var total := sprite.sprite_frames.get_frame_count(anim_name)
		print("capture_player_anims: %s frames=%d speed=%.1f duration≈%.2fs" % [
			String(anim_name), total, speed, float(total) / maxf(speed, 0.01)
		])
		sprite.animation = anim_name
		sprite.stop()
		var frame_count := mini(total, 4)
		for fi in frame_count:
			sprite.frame = fi
			sprite.pause()
			for _w in 3:
				await process_frame
			RenderingServer.force_draw()
			await process_frame
			var img := get_root().get_texture().get_image()
			var path := "%s/%s_f%d.png" % [out_dir, String(anim_name), fi]
			img.save_png(path)
			print("capture_player_anims: wrote ", path)

	quit(0)
