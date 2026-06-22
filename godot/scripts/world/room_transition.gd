extends Area2D
## Door trigger — requests a room change through GameManager.

const DOOR_GAP := 64.0
const OPEN_W := 36.0
const OPEN_H := 56.0
const FRAME_W := 6.0
const LINTEL_H := 6.0
const TRIGGER_W := 48.0
const TRIGGER_H := 64.0

const COLOR_FRAME := Color(0.42, 0.30, 0.18, 1.0)
const COLOR_LINTEL := Color(0.52, 0.36, 0.20, 1.0)
const COLOR_OPENING := Color(0.04, 0.05, 0.08, 0.92)
const COLOR_GLOW := Color(0.78, 0.55, 0.22, 0.35)

@export var target_room_id: StringName = &""
@export var spawn_marker: StringName = &"default"
@export var edge: StringName = &"east"

var _triggered: bool = false


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
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
	var existing := get_node_or_null("Visual")
	if existing:
		existing.queue_free()

	var visual := Node2D.new()
	visual.name = "Visual"
	add_child(visual)

	var half_open := OPEN_W * 0.5
	var half_gap := DOOR_GAP * 0.5
	var frame_outer := half_gap
	var frame_inner := half_open

	_add_rect(visual, "Opening", Vector2(-half_open, -OPEN_H), Vector2(OPEN_W, OPEN_H), COLOR_OPENING)
	_add_rect(visual, "FrameLeft", Vector2(-frame_outer, -OPEN_H - LINTEL_H), Vector2(FRAME_W, OPEN_H + LINTEL_H), COLOR_FRAME)
	_add_rect(visual, "FrameRight", Vector2(frame_inner, -OPEN_H - LINTEL_H), Vector2(FRAME_W, OPEN_H + LINTEL_H), COLOR_FRAME)
	_add_rect(visual, "Lintel", Vector2(-frame_outer, -OPEN_H - LINTEL_H), Vector2(frame_outer * 2.0 + FRAME_W, LINTEL_H), COLOR_LINTEL)
	_add_rect(visual, "Glow", Vector2(-half_open + 4.0, -OPEN_H + 8.0), Vector2(OPEN_W - 8.0, OPEN_H - 16.0), COLOR_GLOW)

	if edge == &"west":
		visual.scale.x = -1.0


func _add_rect(parent: Node, node_name: String, pos: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.position = pos
	rect.size = size
	rect.color = color
	parent.add_child(rect)


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group(&"player"):
		return
	if target_room_id.is_empty():
		push_error("RoomTransition: target_room_id not set on %s" % name)
		return
	_triggered = true
	monitoring = false
	GameManager.change_room(target_room_id, spawn_marker)
