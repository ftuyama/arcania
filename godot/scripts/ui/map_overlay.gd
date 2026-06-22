extends Control
## Fog-of-war map overlay for discovered regions.


const CELL_SIZE := 48

@onready var grid_container: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var region_label: Label = $Panel/Margin/VBox/RegionLabel
@onready var completion_label: Label = $Panel/Margin/VBox/CompletionLabel


func _ready() -> void:
	visible = false


func refresh() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	var region_id := &"whisperwood_hollow"
	if not GameManager.current_region_id.is_empty():
		region_id = GameManager.current_region_id
	var region := MapManager.get_region(region_id)
	if region == null:
		region_label.text = "Unknown Region"
		completion_label.text = ""
		return
	region_label.text = region.display_name
	completion_label.text = "Completion: %d%%" % int(MapManager.get_region_completion(region_id) * 100.0)
	grid_container.columns = region.grid_width
	var player_pos := MapManager.get_room_grid_pos(region_id, GameManager.current_room_id)
	for room_name in region.room_layout:
		var cell := ColorRect.new()
		cell.custom_minimum_size = Vector2(CELL_SIZE - 4, CELL_SIZE - 4)
		if room_name.is_empty():
			cell.color = Color(0.05, 0.05, 0.06, 0.3)
		else:
			var state: MapManager.DiscoveryState = MapManager.get_discovery_state(
				region_id, StringName(room_name)
			)
			match state:
				MapManager.DiscoveryState.UNKNOWN:
					cell.color = Color(0.08, 0.08, 0.1, 0.9)
				MapManager.DiscoveryState.ADJACENT:
					cell.color = Color(0.15, 0.18, 0.14, 0.6)
				MapManager.DiscoveryState.VISITED, MapManager.DiscoveryState.MAPPED:
					cell.color = Color(0.22, 0.35, 0.2, 0.95)
			if room_name == String(GameManager.current_room_id):
				cell.color = Color(0.9, 0.75, 0.2, 1.0)
		grid_container.add_child(cell)
	for marker in MapManager.get_markers():
		if marker.get("region_id", "") != String(region_id):
			continue
		var pos := MapManager.get_room_grid_pos(region_id, StringName(marker.get("room_id", "")))
		if pos.x >= 0:
			var idx := pos.y * region.grid_width + pos.x
			if idx < grid_container.get_child_count():
				var marker_cell := grid_container.get_child(idx) as ColorRect
				if marker_cell:
					marker_cell.color = Color(0.85, 0.3, 0.5, 1.0)
