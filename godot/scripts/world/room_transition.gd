extends Area2D
## Door trigger — requests a room change through GameManager.

const TRIGGER_W := 48.0
const TRIGGER_H := 64.0
const STANDARD_SPAWN_MARKERS: Array[StringName] = [&"default", &"from_left", &"from_right"]

@export var target_room_id: StringName = &""
@export var spawn_marker: StringName = &"default"
@export var edge: StringName = &"east"
@export var required_boss_id: StringName = &""
@export var locked_message := "This path is sealed until the battle is finished."
@export_enum("auto", "ashen_threshold", "whisperwood_hollow", "sunken_catacombs", "planar_rift") var door_style: String = "auto"

var _triggered: bool = false


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	_resolve_spawn_marker()
	body_entered.connect(_on_body_entered)
	_layout_collision()
	_build_visual()


func _layout_collision() -> void:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		return
	var rect_shape := shape_node.shape as RectangleShape2D
	if rect_shape == null:
		rect_shape = RectangleShape2D.new()
		shape_node.shape = rect_shape
	rect_shape.size = Vector2(TRIGGER_W, TRIGGER_H)
	shape_node.position = Vector2(0.0, -TRIGGER_H * 0.5)


func _build_visual() -> void:
	var visual: AnimatedSprite2D = $Visual
	visual.animation = _resolved_door_style()
	visual.flip_h = edge == &"west"


func _resolved_door_style() -> StringName:
	if door_style != "auto":
		return StringName(door_style)
	if String(target_room_id).begins_with("ww_"):
		return &"whisperwood_hollow"
	return &"ashen_threshold"


func _resolve_spawn_marker() -> void:
	## Standard directional doors always spawn on the opposite side of the target room.
	## Custom spawn markers are preserved for special transitions.
	if not spawn_marker in STANDARD_SPAWN_MARKERS:
		return
	if edge == &"west":
		spawn_marker = &"from_right"
	elif edge == &"east":
		spawn_marker = &"from_left"


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group(&"player"):
		return
	if not required_boss_id.is_empty() and not GameManager.is_boss_defeated(required_boss_id):
		EventBus.ui_toast.emit(locked_message)
		return
	if target_room_id.is_empty():
		push_error("RoomTransition: target_room_id not set on %s" % name)
		return
	_triggered = true
	monitoring = false
	GameManager.change_room(target_room_id, spawn_marker)
