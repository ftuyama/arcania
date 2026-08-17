extends Control
## Fog-of-war map overlay for discovered regions.


@onready var grid_container: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var region_label: Label = $Panel/Margin/VBox/RegionLabel
@onready var completion_label: Label = $Panel/Margin/VBox/Footer/CompletionLabel
@onready var scene_label: Label = $Panel/Margin/VBox/Footer/SceneLabel
@onready var map_canvas: Control = $Panel/Margin/VBox/MapCanvas


func _ready() -> void:
	visible = false
	HudStyle.apply_hud_font(region_label, 16, &"semibold")
	HudStyle.apply_hud_font(completion_label, 12)
	HudStyle.apply_hud_font(scene_label, 12)
	HudStyle.apply_hud_font($Panel/Margin/VBox/Footer/LegendLabel, 11)
	_style_panel()


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
		scene_label.text = ""
		return
	region_label.text = region.display_name
	completion_label.text = "Completion: %d%%" % int(MapManager.get_region_completion(region_id) * 100.0)
	scene_label.text = "Scene: %s" % _format_scene_name(GameManager.current_room_id)
	grid_container.columns = region.grid_width
	for room_name in region.room_layout:
		var cell := ColorRect.new()
		grid_container.add_child(cell)
	map_canvas.set_region(region, region_id, GameManager.current_room_id, MapManager.get_markers())


func _style_panel() -> void:
	var panel := HudStyle.make_panel_style(true)
	panel.bg_color = Color("2b2527")
	$Panel.add_theme_stylebox_override(&"panel", panel)
	$Panel/Margin/VBox/RegionLabel.add_theme_color_override(&"font_color", HudStyle.COLOR_XP)
	completion_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	scene_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)


func _format_scene_name(room_id: StringName) -> String:
	var raw := String(room_id)
	if raw.is_empty():
		return "Unknown"
	var separator := raw.find("_", 3)
	if separator >= 0:
		raw = raw.substr(separator + 1)
	return raw.replace("_", " ").capitalize()
