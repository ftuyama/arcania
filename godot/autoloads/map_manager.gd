extends Node
## Room discovery grid, fog of war, and map persistence.


enum DiscoveryState { UNKNOWN, ADJACENT, VISITED, MAPPED }

const REGION_PATHS: Array[String] = [
	"res://resources/world/whisperwood_hollow.tres",
]

const MAX_MARKERS := 3

var _regions: Dictionary = {}
var _discovery: Dictionary = {}
var _markers: Array[Dictionary] = []
var _secrets_found: Dictionary = {}
var _bosses_defeated: Dictionary = {}


func _ready() -> void:
	for path in REGION_PATHS:
		var region := load(path) as RegionData
		if region:
			_regions[region.region_id] = region
			_init_region_discovery(region)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.boss_defeated.connect(_on_boss_defeated)


func _exit_tree() -> void:
	if EventBus.room_entered.is_connected(_on_room_entered):
		EventBus.room_entered.disconnect(_on_room_entered)
	if EventBus.boss_defeated.is_connected(_on_boss_defeated):
		EventBus.boss_defeated.disconnect(_on_boss_defeated)


func get_region(region_id: StringName) -> RegionData:
	return _regions.get(region_id) as RegionData


func get_discovery_state(region_id: StringName, room_id: StringName) -> DiscoveryState:
	var region_key := String(region_id)
	if not _discovery.has(region_key):
		return DiscoveryState.UNKNOWN
	return _discovery[region_key].get(String(room_id), DiscoveryState.UNKNOWN) as DiscoveryState


func get_room_grid_pos(region_id: StringName, room_id: StringName) -> Vector2i:
	var region := get_region(region_id)
	if region == null:
		return Vector2i(-1, -1)
	for i in region.room_layout.size():
		if region.room_layout[i] == String(room_id):
			return Vector2i(i % region.grid_width, i / region.grid_width)
	return Vector2i(-1, -1)


func get_region_completion(region_id: StringName) -> float:
	var region := get_region(region_id)
	if region == null:
		return 0.0
	var region_key := String(region_id)
	var visited := 0
	var total := 0
	for room_name in region.room_layout:
		if room_name.is_empty():
			continue
		total += 1
		var state: DiscoveryState = _discovery.get(region_key, {}).get(room_name, DiscoveryState.UNKNOWN)
		if state >= DiscoveryState.VISITED:
			visited += 1
	var secrets := int(_secrets_found.get(region_key, 0))
	var bosses := int(_bosses_defeated.get(region_key, 0))
	if total == 0:
		return 0.0
	return (float(visited) / float(total) * 0.4
		+ float(secrets) / float(maxi(region.total_secrets, 1)) * 0.3
		+ float(bosses) / float(maxi(region.total_bosses, 1)) * 0.3)


var _waystones: Dictionary = {}


func register_waystone(waystone_id: StringName, room_id: StringName) -> void:
	_waystones[String(waystone_id)] = String(room_id)


func get_waystones() -> Dictionary:
	return _waystones.duplicate()


func place_marker(region_id: StringName, room_id: StringName) -> bool:
	if _markers.size() >= MAX_MARKERS:
		return false
	_markers.append({"region_id": String(region_id), "room_id": String(room_id)})
	return true


func remove_marker(index: int) -> void:
	if index >= 0 and index < _markers.size():
		_markers.remove_at(index)


func mark_secret_found(region_id: StringName) -> void:
	var key := String(region_id)
	_secrets_found[key] = int(_secrets_found.get(key, 0)) + 1


func is_room_visited(room_id: StringName) -> bool:
	for region_key in _discovery.keys():
		var state: DiscoveryState = _discovery[region_key].get(String(room_id), DiscoveryState.UNKNOWN)
		if state >= DiscoveryState.VISITED:
			return true
	return false


func get_save_data() -> Dictionary:
	return {
		"discovery": _discovery.duplicate(true),
		"markers": _markers.duplicate(true),
		"secrets_found": _secrets_found.duplicate(),
		"bosses_defeated": _bosses_defeated.duplicate(),
		"waystones": _waystones.duplicate(),
	}


func apply_save_data(data: Dictionary) -> void:
	_discovery = data.get("discovery", {}).duplicate(true)
	_markers.clear()
	for marker in data.get("markers", []):
		if marker is Dictionary:
			_markers.append(marker.duplicate())
	_secrets_found = data.get("secrets_found", {}).duplicate()
	_bosses_defeated = data.get("bosses_defeated", {}).duplicate()
	_waystones = data.get("waystones", {}).duplicate()


func reset_to_defaults() -> void:
	_discovery.clear()
	_markers.clear()
	_secrets_found.clear()
	_bosses_defeated.clear()
	_waystones.clear()
	for region in _regions.values():
		_init_region_discovery(region as RegionData)


func _init_region_discovery(region: RegionData) -> void:
	var region_key := String(region.region_id)
	if not _discovery.has(region_key):
		_discovery[region_key] = {}


func _on_room_entered(room_id: StringName, region_id: StringName) -> void:
	var region := get_region(region_id)
	if region == null:
		return
	var region_key := String(region_id)
	if not _discovery.has(region_key):
		_discovery[region_key] = {}
	var room_key := String(room_id)
	_discovery[region_key][room_key] = DiscoveryState.VISITED
	_reveal_adjacent(region, region_key, room_key)


func _reveal_adjacent(region: RegionData, region_key: String, room_key: String) -> void:
	var pos := get_room_grid_pos(region.region_id, StringName(room_key))
	if pos.x < 0:
		return
	var offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for offset in offsets:
		var neighbor := pos + offset
		if neighbor.x < 0 or neighbor.y < 0:
			continue
		if neighbor.x >= region.grid_width or neighbor.y >= region.grid_height:
			continue
		var idx := neighbor.y * region.grid_width + neighbor.x
		if idx >= region.room_layout.size():
			continue
		var neighbor_room: String = region.room_layout[idx]
		if neighbor_room.is_empty():
			continue
		var current: DiscoveryState = _discovery[region_key].get(neighbor_room, DiscoveryState.UNKNOWN)
		if current < DiscoveryState.ADJACENT:
			_discovery[region_key][neighbor_room] = DiscoveryState.ADJACENT


func _on_boss_defeated(boss_id: StringName) -> void:
	var region_id := GameManager.current_region_id
	if region_id.is_empty():
		return
	var key := String(region_id)
	_bosses_defeated[key] = int(_bosses_defeated.get(key, 0)) + 1
