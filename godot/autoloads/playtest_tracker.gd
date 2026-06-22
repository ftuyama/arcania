extends Node
## Vertical slice playtest checkpoint tracker. See docs/playtest-vertical-slice.md.


const SLICE_MIN_SECONDS := 45.0 * 60.0
const SLICE_MAX_SECONDS := 90.0 * 60.0
const REPORT_PATH := "user://playtest_slice_report.json"

const CHECKPOINT_ORDER: Array[StringName] = [
	&"session_start",
	&"threshold_hub",
	&"whisperwood_entered",
	&"veil_step_acquired",
	&"rootbind_acquired",
	&"matron_defeated",
	&"arc_step_acquired",
	&"crucible_saved",
	&"warden_defeated",
]

const CHECKPOINT_LABELS: Dictionary = {
	&"session_start": "New game started",
	&"threshold_hub": "Ashen Threshold hub entered",
	&"whisperwood_entered": "Whisperwood entered (ww_01)",
	&"veil_step_acquired": "Veil Step acquired",
	&"rootbind_acquired": "Rootbind acquired",
	&"matron_defeated": "Thornweft Matron defeated",
	&"arc_step_acquired": "Arc Step acquired",
	&"crucible_saved": "Focus Crucible save",
	&"warden_defeated": "Root Warden defeated (slice end)",
}

const BUDGET_MINUTES: Dictionary = {
	&"session_start": 0.0,
	&"threshold_hub": 8.0,
	&"whisperwood_entered": 15.0,
	&"veil_step_acquired": 22.0,
	&"rootbind_acquired": 35.0,
	&"matron_defeated": 50.0,
	&"arc_step_acquired": 55.0,
	&"crucible_saved": 65.0,
	&"warden_defeated": 90.0,
}

var _tracking_enabled: bool = false
var _checkpoints: Dictionary = {}
var _slice_complete: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.region_entered.connect(_on_region_entered)
	EventBus.spell_acquired.connect(_on_spell_acquired)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.anchor_activated.connect(_on_anchor_activated)


func _exit_tree() -> void:
	if EventBus.room_entered.is_connected(_on_room_entered):
		EventBus.room_entered.disconnect(_on_room_entered)
	if EventBus.region_entered.is_connected(_on_region_entered):
		EventBus.region_entered.disconnect(_on_region_entered)
	if EventBus.spell_acquired.is_connected(_on_spell_acquired):
		EventBus.spell_acquired.disconnect(_on_spell_acquired)
	if EventBus.boss_defeated.is_connected(_on_boss_defeated):
		EventBus.boss_defeated.disconnect(_on_boss_defeated)
	if EventBus.anchor_activated.is_connected(_on_anchor_activated):
		EventBus.anchor_activated.disconnect(_on_anchor_activated)


func _unhandled_input(event: InputEvent) -> void:
	if not _tracking_enabled:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F4:
		export_report(false)


func begin_new_game_session() -> void:
	_tracking_enabled = true
	_checkpoints.clear()
	_slice_complete = false
	_mark(&"session_start")


func disable_tracking() -> void:
	_tracking_enabled = false


func is_tracking() -> bool:
	return _tracking_enabled


func is_slice_complete() -> bool:
	return _slice_complete


func get_checkpoint_count() -> int:
	return _checkpoints.size()


func get_total_checkpoints() -> int:
	return CHECKPOINT_ORDER.size()


func has_checkpoint(checkpoint_id: StringName) -> bool:
	return _checkpoints.has(checkpoint_id)


func get_elapsed_seconds(checkpoint_id: StringName) -> float:
	var entry: Variant = _checkpoints.get(checkpoint_id, null)
	if entry is Dictionary:
		return float(entry.get("elapsed_seconds", -1.0))
	return -1.0


static func format_playtime(seconds: float) -> String:
	var total := maxi(0, int(seconds))
	var mins := total / 60
	var secs := total % 60
	return "%d:%02d" % [mins, secs]


static func is_within_slice_target(seconds: float) -> bool:
	return seconds >= SLICE_MIN_SECONDS and seconds <= SLICE_MAX_SECONDS


func export_report(slice_finished: bool) -> Dictionary:
	var report := _build_report(slice_finished)
	var json := JSON.stringify(report, "\t")
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json)
		file.close()
	print("PlaytestTracker: report written to %s" % REPORT_PATH)
	_log_report_summary(report)
	return report


func _build_report(slice_finished: bool) -> Dictionary:
	var rows: Array[Dictionary] = []
	var prev_elapsed := 0.0
	for checkpoint_id in CHECKPOINT_ORDER:
		var elapsed := get_elapsed_seconds(checkpoint_id)
		var segment := -1.0
		if elapsed >= 0.0:
			segment = elapsed - prev_elapsed
			prev_elapsed = elapsed
		rows.append({
			"id": String(checkpoint_id),
			"label": String(CHECKPOINT_LABELS.get(checkpoint_id, checkpoint_id)),
			"budget_minutes": float(BUDGET_MINUTES.get(checkpoint_id, 0.0)),
			"elapsed_seconds": elapsed,
			"segment_seconds": segment,
			"hit": elapsed >= 0.0 and elapsed <= float(BUDGET_MINUTES.get(checkpoint_id, 0.0)) * 60.0,
		})
	var slice_seconds := get_elapsed_seconds(&"warden_defeated")
	if slice_seconds < 0.0:
		slice_seconds = GameManager.playtime_seconds
	return {
		"timestamp": Time.get_datetime_string_from_system(),
		"slice_finished": slice_finished,
		"tracking_enabled": _tracking_enabled,
		"playtime_seconds": GameManager.playtime_seconds,
		"slice_seconds": slice_seconds,
		"within_target": is_within_slice_target(slice_seconds) if slice_finished else false,
		"target_min_minutes": 45,
		"target_max_minutes": 90,
		"checkpoints": rows,
	}


func _mark(checkpoint_id: StringName) -> void:
	if not _tracking_enabled or _checkpoints.has(checkpoint_id):
		return
	_checkpoints[checkpoint_id] = {
		"elapsed_seconds": GameManager.playtime_seconds,
		"timestamp": Time.get_datetime_string_from_system(),
	}
	print(
		"PlaytestTracker [%s] %s"
		% [format_playtime(GameManager.playtime_seconds), CHECKPOINT_LABELS.get(checkpoint_id, checkpoint_id)]
	)


func _on_room_entered(room_id: StringName, _region_id: StringName) -> void:
	if not _tracking_enabled:
		return
	match room_id:
		&"at_01_threshold_hub":
			_mark(&"threshold_hub")
		&"ww_01_forest_gate":
			_mark(&"whisperwood_entered")


func _on_region_entered(region_id: StringName) -> void:
	if not _tracking_enabled:
		return
	if region_id == &"whisperwood_hollow":
		_mark(&"whisperwood_entered")


func _on_spell_acquired(spell_id: StringName) -> void:
	if not _tracking_enabled:
		return
	match spell_id:
		&"veil_step":
			_mark(&"veil_step_acquired")
		&"rootbind":
			_mark(&"rootbind_acquired")
		&"arc_step":
			_mark(&"arc_step_acquired")


func _on_boss_defeated(boss_id: StringName) -> void:
	if not _tracking_enabled:
		return
	match boss_id:
		&"mb_01_thornweft_matron":
			_mark(&"matron_defeated")
		&"boss_01_root_warden":
			_mark(&"warden_defeated")
			_finish_slice()


func _on_anchor_activated(_anchor_id: StringName) -> void:
	if _tracking_enabled:
		_mark(&"crucible_saved")


func _finish_slice() -> void:
	if _slice_complete:
		return
	_slice_complete = true
	var report := export_report(true)
	var slice_seconds := float(report.get("slice_seconds", 0.0))
	if is_within_slice_target(slice_seconds):
		EventBus.ui_toast.emit("Slice complete in %s — within 45–90 min target" % format_playtime(slice_seconds))
	else:
		EventBus.ui_toast.emit("Slice complete in %s — outside 45–90 min target" % format_playtime(slice_seconds))


func _log_report_summary(report: Dictionary) -> void:
	print("=== Vertical Slice Playtest Report ===")
	print("Playtime: %s" % format_playtime(float(report.get("playtime_seconds", 0.0))))
	if bool(report.get("slice_finished", false)):
		var within: bool = report.get("within_target", false)
		print("Slice target (45–90 min): %s" % ("PASS" if within else "REVIEW"))
	for row in report.get("checkpoints", []):
		if row is Dictionary and float(row.get("elapsed_seconds", -1.0)) >= 0.0:
			print(
				"  %s @ %s (budget ≤%dm)"
				% [
					row.get("label", ""),
					format_playtime(float(row.get("elapsed_seconds", 0.0))),
					int(row.get("budget_minutes", 0)),
				]
			)
