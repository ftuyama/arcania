extends Area2D
## Room transition gated by boss defeat or world flag.


@export var target_room_id: StringName = &""
@export var spawn_marker: StringName = &"default"
@export var required_boss_id: StringName = &""
@export var required_flag: StringName = &""

var _triggered: bool = false


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)


func _is_unlocked() -> bool:
	if not required_boss_id.is_empty():
		return GameManager.is_boss_defeated(required_boss_id)
	if not required_flag.is_empty():
		return GameManager.has_world_flag(required_flag)
	return true


func _on_body_entered(body: Node2D) -> void:
	if _triggered or not body.is_in_group(&"player"):
		return
	if not _is_unlocked():
		EventBus.ui_toast.emit("The vine chute is still bound.")
		return
	if target_room_id.is_empty():
		return
	_triggered = true
	monitoring = false
	GameManager.change_room(target_room_id, spawn_marker)
