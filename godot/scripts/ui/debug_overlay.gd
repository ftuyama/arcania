extends CanvasLayer
## Debug overlay — toggle with F3.


@onready var label: Label = $Label


func _ready() -> void:
	visible = false
	layer = 100
	PerformanceProfiler.reset()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		visible = not visible
		if visible:
			PerformanceProfiler.reset()


func _process(delta: float) -> void:
	PerformanceProfiler.record_frame(delta)
	if not visible:
		return
	var fps := Engine.get_frames_per_second()
	var room := GameManager.current_room_id
	var region := GameManager.current_region_id
	var playtime := PlaytestTracker.format_playtime(GameManager.playtime_seconds)
	var checkpoint_line := ""
	if PlaytestTracker.is_tracking():
		checkpoint_line = "\nPlaytest: %d/%d checkpoints | F4: export report" % [
			PlaytestTracker.get_checkpoint_count(),
			PlaytestTracker.get_total_checkpoints(),
		]
	var perf_line := ""
	var room_loader := GameManager.get_room_loader()
	if room_loader != null and room_loader.get_current_room() != null:
		perf_line = "\n" + PerformanceProfiler.format_overlay_line(room_loader.get_current_room())
	label.text = (
		"FPS: %d | Room: %s | Region: %s | Time: %s%s%s\n"
		+ "J: melee | 1: Ember Sigil | 2: Ember Bolt | 3/Shift: Veil Step\n"
		+ "F3: toggle debug"
		% [fps, room, region, playtime, checkpoint_line, perf_line]
	)
