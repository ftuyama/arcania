extends Control
## Persistent corner minimap — fog-of-war grid with ornate frame + diamond marker.


const MAP_SIZE := 64
const FRAME_PAD := 4

var _grid: GridContainer
var _frame: TextureRect
var _marker: TextureRect
var _refreshing: bool = false
var _player_cell_index: int = -1


func _ready() -> void:
	custom_minimum_size = Vector2(MAP_SIZE + FRAME_PAD * 2, MAP_SIZE + FRAME_PAD * 2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_tex := HudStyle.get_hud_texture(&"minimap_frame")
	if frame_tex == null:
		var panel := Panel.new()
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_theme_stylebox_override(&"panel", HudStyle.make_panel_style())
		add_child(panel)
	# Dark map backdrop inside frame
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.offset_left = FRAME_PAD
	backdrop.offset_top = FRAME_PAD
	backdrop.offset_right = -FRAME_PAD
	backdrop.offset_bottom = -FRAME_PAD
	backdrop.color = Color(0.04, 0.04, 0.06, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_grid = GridContainer.new()
	_grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_grid.offset_left = FRAME_PAD
	_grid.offset_top = FRAME_PAD
	_grid.offset_right = -FRAME_PAD
	_grid.offset_bottom = -FRAME_PAD
	_grid.add_theme_constant_override(&"h_separation", 1)
	_grid.add_theme_constant_override(&"v_separation", 1)
	add_child(_grid)
	_marker = TextureRect.new()
	_marker.custom_minimum_size = Vector2(8, 8)
	_marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker.texture = HudStyle.get_hud_texture(&"player_marker")
	_marker.visible = false
	_marker.z_index = 2
	add_child(_marker)
	# Ornate frame on top so border draws over map cells (center is transparent)
	if frame_tex:
		_frame = TextureRect.new()
		_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_frame.stretch_mode = TextureRect.STRETCH_SCALE
		_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_frame.texture = frame_tex
		_frame.z_index = 3
		add_child(_frame)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.region_entered.connect(_on_region_entered)
	refresh()


func _exit_tree() -> void:
	if EventBus.room_entered.is_connected(_on_room_entered):
		EventBus.room_entered.disconnect(_on_room_entered)
	if EventBus.region_entered.is_connected(_on_region_entered):
		EventBus.region_entered.disconnect(_on_region_entered)


func _on_room_entered(_room_id: StringName, _region_id: StringName) -> void:
	refresh.call_deferred()


func _on_region_entered(_region_id: StringName) -> void:
	refresh.call_deferred()


func refresh() -> void:
	if _grid == null or _refreshing:
		return
	_refreshing = true
	while _grid.get_child_count() > 0:
		var child := _grid.get_child(0)
		_grid.remove_child(child)
		child.free()
	_player_cell_index = -1
	_marker.visible = false
	var region_id := GameManager.current_region_id
	if region_id.is_empty() or region_id == &"dev":
		region_id = &"ashen_threshold"
	var region := MapManager.get_region(region_id)
	if region == null:
		_refreshing = false
		return
	_grid.columns = region.grid_width
	var cell_count := region.room_layout.size()
	var cols := maxi(region.grid_width, 1)
	var rows := maxi(ceili(float(cell_count) / float(cols)), 1)
	var cell_w := float(MAP_SIZE) / float(cols) - 1.0
	var cell_h := float(MAP_SIZE) / float(rows) - 1.0
	var cell_size := Vector2(maxf(cell_w, 4.0), maxf(cell_h, 4.0))
	var idx := 0
	for room_name in region.room_layout:
		var cell := ColorRect.new()
		cell.custom_minimum_size = cell_size
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
				_player_cell_index = idx
		_grid.add_child(cell)
		idx += 1
	_refreshing = false
	_place_marker.call_deferred()


func _place_marker() -> void:
	if _marker == null or _player_cell_index < 0:
		return
	if _player_cell_index >= _grid.get_child_count():
		return
	var cell := _grid.get_child(_player_cell_index) as Control
	if cell == null:
		return
	# Cell position is relative to grid; grid is inset by FRAME_PAD
	var cell_center := cell.position + cell.size * 0.5
	_marker.position = _grid.position + cell_center - Vector2(4, 4)
	_marker.visible = true
