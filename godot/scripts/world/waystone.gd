extends Area2D
## Discoverable fast-travel anchor (Sigil Recall activation deferred).


@export var waystone_id: StringName = &""

var _discovered: bool = false

@onready var _visual: ColorRect = $Visual
@onready var _label: Label = $Label


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	if waystone_id and GameManager.has_world_flag(StringName("waystone_%s" % waystone_id)):
		_discovered = true
		_visual.color = Color(0.55, 0.85, 0.95, 1.0)
		_label.text = "Waystone"


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _discovered or not body.is_in_group(&"player"):
		return
	if waystone_id.is_empty():
		return
	_discovered = true
	GameManager.set_world_flag(StringName("waystone_%s" % waystone_id))
	MapManager.register_waystone(waystone_id, GameManager.current_room_id)
	_visual.color = Color(0.55, 0.85, 0.95, 1.0)
	_label.text = "Waystone"
	EventBus.ui_toast.emit("Waystone discovered.")
