extends Node2D
## Builds greybox StaticBody2D platforms from exported rectangles.


@export var floor_color := Color(0.18, 0.17, 0.2, 1.0)
@export var platform_color := Color(0.28, 0.26, 0.32, 1.0)
@export var platform_rects: Array[Rect2] = []
@export var west_transition: bool = false
@export var east_transition: bool = false

const DOOR_GAP := 64.0


func _ready() -> void:
	if platform_rects.is_empty():
		return

	var floor_rect: Rect2 = platform_rects[0]
	var extras := platform_rects.slice(1)

	if west_transition or east_transition:
		for segment in _split_floor(floor_rect):
			add_child(_make_platform(segment, true))
	else:
		add_child(_make_platform(floor_rect, true))

	for rect: Rect2 in extras:
		add_child(_make_platform(rect, false))


func _split_floor(floor_rect: Rect2) -> Array[Rect2]:
	var segments: Array[Rect2] = []
	var gap := DOOR_GAP
	var left := floor_rect.position.x
	var top := floor_rect.position.y
	var width := floor_rect.size.x
	var height := floor_rect.size.y

	if west_transition and east_transition:
		segments.append(Rect2(left + gap, top, width - gap * 2.0, height))
	elif west_transition:
		segments.append(Rect2(left + gap, top, width - gap, height))
	elif east_transition:
		segments.append(Rect2(left, top, width - gap, height))
	else:
		segments.append(floor_rect)

	return segments


func _make_platform(rect: Rect2, is_floor: bool) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.position = rect.position

	var shape_node := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = rect.size
	shape_node.position = rect.size * 0.5
	shape_node.shape = rect_shape
	body.add_child(shape_node)

	var visual := ColorRect.new()
	visual.size = rect.size
	visual.color = floor_color if is_floor else platform_color
	body.add_child(visual)

	return body
