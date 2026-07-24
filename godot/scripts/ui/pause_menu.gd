extends Control
## Pause menu with save/load slots.


const COLOR_GOLD := Color(0.92, 0.78, 0.55, 1.0)
const COLOR_TEXT := Color(0.88, 0.84, 0.76, 1.0)
const COLOR_DISABLED := Color(0.55, 0.50, 0.44, 1.0)
const TITLE_FONT_SIZE := 13
const BODY_FONT_SIZE := 10
const BUTTON_FONT_SIZE := 10
const BUTTON_MARGIN_V := 2
const BUTTON_MARGIN_H := 5

@onready var slot_list: ItemList = $Panel/Margin/ScrollContainer/VBox/SlotList
@onready var status_label: Label = $Panel/Margin/ScrollContainer/VBox/StatusLabel
@onready var _panel: PanelContainer = $Panel
@onready var _scroll: ScrollContainer = $Panel/Margin/ScrollContainer
@onready var _title: Label = $Panel/Margin/ScrollContainer/VBox/Title


func _ready() -> void:
	visible = false
	_style_ui()
	$Panel/Margin/ScrollContainer/VBox/SaveButton.pressed.connect(_on_save_pressed)
	$Panel/Margin/ScrollContainer/VBox/LoadButton.pressed.connect(_on_load_pressed)
	$Panel/Margin/ScrollContainer/VBox/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/Margin/ScrollContainer/VBox/QuestButton.pressed.connect(_on_quest_pressed)
	_add_settings_button()
	_populate_slots()
	UiSfx.wire_tree(self)
	call_deferred(&"_fit_scroll_to_viewport")


func _style_ui() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.11, 0.96)
	panel_style.border_color = Color(0.72, 0.48, 0.18, 0.65)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(3)
	panel_style.content_margin_left = 8
	panel_style.content_margin_top = 8
	panel_style.content_margin_right = 8
	panel_style.content_margin_bottom = 8
	_panel.add_theme_stylebox_override(&"panel", panel_style)

	HudStyle.apply_hud_font(_title, TITLE_FONT_SIZE, &"semibold")
	HudStyle.apply_hud_font(status_label, BODY_FONT_SIZE)
	_title.add_theme_color_override(&"font_color", COLOR_GOLD)
	status_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	slot_list.add_theme_font_size_override(&"font_size", BODY_FONT_SIZE)

	var slot_style := StyleBoxFlat.new()
	slot_style.bg_color = Color(0.06, 0.06, 0.09, 0.95)
	slot_style.border_color = Color(0.55, 0.38, 0.14, 0.55)
	slot_style.set_border_width_all(1)
	slot_style.set_corner_radius_all(2)
	slot_style.content_margin_left = 4
	slot_style.content_margin_top = 4
	slot_style.content_margin_right = 4
	slot_style.content_margin_bottom = 4
	slot_list.add_theme_stylebox_override(&"panel", slot_style)

	var vbox: VBoxContainer = $Panel/Margin/ScrollContainer/VBox
	for child in vbox.get_children():
		if child is Button:
			_apply_button_theme(child as Button)


func _apply_button_theme(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.11, 0.10, 0.14, 0.94)
	normal.border_color = Color(0.55, 0.38, 0.14, 0.75)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(2)
	normal.content_margin_top = BUTTON_MARGIN_V
	normal.content_margin_bottom = BUTTON_MARGIN_V
	normal.content_margin_left = BUTTON_MARGIN_H
	normal.content_margin_right = BUTTON_MARGIN_H
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_font_size_override(&"font_size", BUTTON_FONT_SIZE)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.18, 0.14, 0.10, 0.96)
	hover.border_color = Color(0.85, 0.65, 0.28, 0.95)
	btn.add_theme_stylebox_override(&"hover", hover)

	var pressed := hover.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.24, 0.18, 0.10, 1.0)
	btn.add_theme_stylebox_override(&"pressed", pressed)

	var focus := hover.duplicate() as StyleBoxFlat
	focus.border_color = Color(0.95, 0.78, 0.35, 1.0)
	focus.set_border_width_all(2)
	btn.add_theme_stylebox_override(&"focus", focus)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.07, 0.07, 0.09, 0.6)
	disabled.border_color = Color(0.35, 0.32, 0.28, 0.5)
	btn.add_theme_stylebox_override(&"disabled", disabled)

	btn.add_theme_color_override(&"font_color", COLOR_TEXT)
	btn.add_theme_color_override(&"font_hover_color", COLOR_GOLD)
	btn.add_theme_color_override(&"font_pressed_color", COLOR_GOLD)
	btn.add_theme_color_override(&"font_focus_color", COLOR_GOLD)
	btn.add_theme_color_override(&"font_disabled_color", COLOR_DISABLED)


func _fit_scroll_to_viewport() -> void:
	await get_tree().process_frame
	var viewport_h: float = get_viewport().get_visible_rect().size.y
	var max_panel_h: float = viewport_h - 20.0
	var margin_h: float = $Panel/Margin.get_combined_minimum_size().y - _scroll.get_combined_minimum_size().y
	var max_scroll_h: float = maxf(max_panel_h - margin_h, 96.0)
	var content_h: float = _scroll.get_combined_minimum_size().y
	_scroll.custom_minimum_size.y = minf(content_h, max_scroll_h)


func _add_settings_button() -> void:
	var vbox: VBoxContainer = $Panel/Margin/ScrollContainer/VBox
	var btn := Button.new()
	btn.text = "Settings"
	btn.pressed.connect(_on_settings_pressed)
	_apply_button_theme(btn)
	vbox.add_child(btn)
	vbox.move_child(btn, vbox.get_child_count() - 2)


func _on_settings_pressed() -> void:
	var ui := get_parent()
	if ui.has_method(&"open_settings"):
		ui.open_settings()


func _populate_slots() -> void:
	slot_list.clear()
	for i in 3:
		slot_list.add_item("Slot %d" % (i + 1))
		slot_list.set_item_metadata(slot_list.item_count - 1, "slot_%d" % (i + 1))


func _on_save_pressed() -> void:
	var selected := slot_list.get_selected_items()
	if selected.is_empty():
		status_label.text = "Select a slot first"
		return
	var slot_id: String = slot_list.get_item_metadata(selected[0])
	if SaveManager.save_game(slot_id):
		status_label.text = "Saved to %s" % slot_id
	else:
		status_label.text = "Save failed"


func _on_load_pressed() -> void:
	var selected := slot_list.get_selected_items()
	if selected.is_empty():
		status_label.text = "Select a slot first"
		return
	var slot_id: String = slot_list.get_item_metadata(selected[0])
	get_tree().paused = false
	if SaveManager.load_game(slot_id):
		status_label.text = "Loaded %s" % slot_id
		visible = false
		GameManager.state = GameManager.GameState.PLAYING
		EventBus.game_resumed.emit()
	else:
		status_label.text = "No save in %s" % slot_id
		get_tree().paused = true


func _on_resume_pressed() -> void:
	var ui := get_parent()
	if ui.has_method(&"_close_pause"):
		ui._close_pause()


func _on_quest_pressed() -> void:
	var quest_log: Control = get_parent().get_node_or_null("QuestLog")
	if quest_log:
		visible = false
		get_tree().paused = false
		quest_log.visible = true
		if quest_log.has_method(&"refresh"):
			quest_log.refresh()
