class_name Room
extends Node2D
## Room root — metadata, spawn points, and camera bounds for a single playable space.

const REGION_BACKDROP_SCRIPT := preload("res://scripts/world/region_backdrop.gd")
const DOOR_GAP := 64.0
const WALL_THICKNESS := 16.0

@export var room_id: StringName = &""
@export var region_id: StringName = &"dev"


func _ready() -> void:
	if room_id.is_empty():
		room_id = StringName(name)
	_ensure_backdrop()
	_ensure_edge_walls()
	EventBus.room_entered.emit(room_id, region_id)


func _ensure_backdrop() -> void:
	if get_node_or_null("Backdrop") != null:
		return
	if not RegionBackdrop.region_has_backdrop(region_id):
		return

	var backdrop := ParallaxBackground.new()
	backdrop.name = &"Backdrop"
	backdrop.set_script(REGION_BACKDROP_SCRIPT)
	backdrop.region_id = region_id
	add_child(backdrop)
	move_child(backdrop, 0)


func get_spawn_position(marker_name: StringName = &"default") -> Vector2:
	var spawn_points := get_node_or_null("SpawnPoints")
	if spawn_points == null:
		return global_position

	for child in spawn_points.get_children():
		if child is Marker2D and child.name == String(marker_name):
			return child.global_position

	for child in spawn_points.get_children():
		if child is Marker2D:
			return child.global_position

	return global_position


func get_camera_limits() -> Rect2i:
	var bounds := get_node_or_null("CameraBounds")
	if bounds is ReferenceRect:
		return Rect2i(
			int(bounds.global_position.x),
			int(bounds.global_position.y),
			int(bounds.size.x),
			int(bounds.size.y)
		)
	return Rect2i(0, 0, 960, 540)


func _ensure_edge_walls() -> void:
	if get_node_or_null("RoomBoundaries") != null:
		return

	var bounds_node := get_node_or_null("CameraBounds")
	if bounds_node == null:
		return

	var bounds := Rect2(bounds_node.position, bounds_node.size)
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return

	var west_open := false
	var east_open := false
	var floor_top := bounds.position.y + bounds.size.y - DOOR_GAP

	var geometry := get_node_or_null("Geometry")
	if geometry != null:
		west_open = bool(geometry.get("west_transition"))
		east_open = bool(geometry.get("east_transition"))
		var rects: Variant = geometry.get("platform_rects")
		if rects is Array and not rects.is_empty() and rects[0] is Rect2:
			floor_top = rects[0].position.y

	var walls := Node2D.new()
	walls.name = &"RoomBoundaries"
	add_child(walls)

	var left_x := bounds.position.x
	var right_x := bounds.position.x + bounds.size.x - WALL_THICKNESS
	var wall_height := floor_top - bounds.position.y

	if west_open:
		_add_wall(walls, Rect2(left_x, bounds.position.y, WALL_THICKNESS, wall_height))
	else:
		_add_wall(walls, Rect2(left_x, bounds.position.y, WALL_THICKNESS, bounds.size.y))

	if east_open:
		_add_wall(walls, Rect2(right_x, bounds.position.y, WALL_THICKNESS, wall_height))
	else:
		_add_wall(walls, Rect2(right_x, bounds.position.y, WALL_THICKNESS, bounds.size.y))


func _add_wall(parent: Node, rect: Rect2) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.position = rect.position

	var shape_node := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = rect.size
	shape_node.position = rect.size * 0.5
	shape_node.shape = rect_shape
	body.add_child(shape_node)
	parent.add_child(body)
