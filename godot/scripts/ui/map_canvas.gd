class_name MapCanvas
extends Control
## Draws the discovered region as a parchment cartographic diagram.


const PARCHMENT := Color("cab7a2")
const INK := Color("1d1718")
const FOG := Color("0b090a")
const ADJACENT := Color("6d6a5f")
const VISITED := Color("496b5a")
const MAPPED := Color("3d7c70")
const EMBER := Color("ff6b35")
const MARKER := Color("8e3b6c")

var _region: RegionData
var _region_id: StringName = &""
var _current_room: StringName = &""
var _markers: Array[Dictionary] = []


func set_region(region: RegionData, region_id: StringName, current_room: StringName, markers: Array[Dictionary]) -> void:
	_region = region
	_region_id = region_id
	_current_room = current_room
	_markers = markers
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), PARCHMENT)
	if _region == null:
		return
	var padding := 24.0
	var cell_size := minf((size.x - padding * 2.0) / float(_region.grid_width), (size.y - padding * 2.0) / float(_region.grid_height))
	var map_size := Vector2(cell_size * _region.grid_width, cell_size * _region.grid_height)
	var origin := (size - map_size) * 0.5
	_draw_connections(origin, cell_size)
	for index in _region.room_layout.size():
		var room_id := StringName(_region.room_layout[index])
		if room_id.is_empty():
			continue
		var grid_pos := Vector2i(index % _region.grid_width, index / _region.grid_width)
		var room_rect := Rect2(origin + Vector2(grid_pos) * cell_size + Vector2(3, 3), Vector2(cell_size - 6.0, cell_size - 6.0))
		var state := MapManager.get_discovery_state(_region_id, room_id)
		var fill := _room_color(state)
		draw_rect(room_rect, fill)
		draw_rect(room_rect, INK, false, 1.0)
		if room_id == _current_room:
			draw_circle(room_rect.get_center(), maxf(cell_size * 0.14, 4.0), EMBER)
		elif _has_marker(room_id):
			_draw_marker(room_rect.get_center(), maxf(cell_size * 0.14, 4.0))


func _draw_connections(origin: Vector2, cell_size: float) -> void:
	var offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1)]
	for index in _region.room_layout.size():
		var room_id := StringName(_region.room_layout[index])
		if room_id.is_empty() or MapManager.get_discovery_state(_region_id, room_id) < MapManager.DiscoveryState.ADJACENT:
			continue
		var from_pos := Vector2i(index % _region.grid_width, index / _region.grid_width)
		for offset in offsets:
			var to_pos: Vector2i = from_pos + offset
			if to_pos.x >= _region.grid_width or to_pos.y >= _region.grid_height:
				continue
			var target_index: int = to_pos.y * _region.grid_width + to_pos.x
			if target_index >= _region.room_layout.size():
				continue
			var target_id := StringName(_region.room_layout[target_index])
			if target_id.is_empty() or MapManager.get_discovery_state(_region_id, target_id) < MapManager.DiscoveryState.ADJACENT:
				continue
			var start := origin + (Vector2(from_pos) + Vector2(0.5, 0.5)) * cell_size
			var finish := origin + (Vector2(to_pos) + Vector2(0.5, 0.5)) * cell_size
			draw_line(start, finish, INK, 3.0)
			draw_line(start, finish, Color("7e6651"), 1.0)


func _room_color(state: MapManager.DiscoveryState) -> Color:
	match state:
		MapManager.DiscoveryState.UNKNOWN:
			return FOG
		MapManager.DiscoveryState.ADJACENT:
			return ADJACENT
		MapManager.DiscoveryState.MAPPED:
			return MAPPED
		_:
			return VISITED


func _has_marker(room_id: StringName) -> bool:
	for marker in _markers:
		if marker.get("region_id", "") == String(_region_id) and marker.get("room_id", "") == String(room_id):
			return true
	return false


func _draw_marker(center: Vector2, radius: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -radius), center + Vector2(radius, 0),
		center + Vector2(0, radius), center + Vector2(-radius, 0),
	])
	draw_colored_polygon(points, MARKER)
