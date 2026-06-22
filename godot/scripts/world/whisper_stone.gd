extends Area2D
## Whisper stone puzzle — activate in sequence 1 → 3 → 2.


@export var sequence_index: int = 1

const EXPECTED_SEQUENCE: Array[int] = [1, 3, 2]
const PUZZLE_FLAG := &"whisper_loop_solved"

var _activated: bool = false

@onready var _visual: ColorRect = $Visual


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	if GameManager.has_world_flag(PUZZLE_FLAG):
		_visual.color = Color(0.6, 0.95, 0.75, 1.0)
		_activated = true


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.is_in_group(&"player"):
		return
	if GameManager.has_world_flag(PUZZLE_FLAG):
		return
	var progress: Array = GameManager.get_world_value(&"whisper_loop_progress", [])
	if progress.is_empty():
		progress = []
	if progress.size() >= EXPECTED_SEQUENCE.size():
		progress = []
	if sequence_index != EXPECTED_SEQUENCE[progress.size()]:
		GameManager.set_world_value(&"whisper_loop_progress", [])
		_visual.color = Color(0.9, 0.3, 0.3, 1.0)
		return
	progress.append(sequence_index)
	GameManager.set_world_value(&"whisper_loop_progress", progress)
	_visual.color = Color(0.6, 0.95, 0.75, 1.0)
	_activated = true
	if progress.size() >= EXPECTED_SEQUENCE.size():
		_complete_puzzle()


func _complete_puzzle() -> void:
	GameManager.set_world_flag(PUZZLE_FLAG)
	MapManager.place_marker(&"whisperwood_hollow", &"ww_s02_whisper_loop")
	MapManager.mark_secret_found(&"whisperwood_hollow")
	EventBus.ui_toast.emit("Whisper Loop solved — map marker placed.")
	QuestManager.advance_objective(&"peddlers_price", &"whisper_secret")
