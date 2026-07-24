extends Control
## Volume and accessibility settings panel.


const COLOR_GOLD := Color(0.92, 0.78, 0.55, 1.0)
const COLOR_TEXT := Color(0.88, 0.84, 0.76, 1.0)
const COLOR_DISABLED := Color(0.55, 0.50, 0.44, 1.0)
const TITLE_FONT_SIZE := 13
const BODY_FONT_SIZE := 10
const BUTTON_FONT_SIZE := 10
const BUTTON_MARGIN_V := 2
const BUTTON_MARGIN_H := 5

var _master_slider: HSlider
var _music_slider: HSlider
var _sfx_slider: HSlider
var _damage_toggle: CheckBox
var _status_label: Label


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	UiSfx.wire_tree(self)
	_load_from_game_manager()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_right = 0.0
	offset_bottom = 0.0

	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.offset_right = 0.0
	dimmer.offset_bottom = 0.0
	dimmer.color = Color(0, 0, 0, 0.45)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_right = 0.0
	center.offset_bottom = 0.0
	add_child(center)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(208, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.11, 0.96)
	style.border_color = Color(0.72, 0.48, 0.18, 0.65)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override(&"panel", style)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", 4)
	margin.add_theme_constant_override(&"margin_top", 4)
	margin.add_theme_constant_override(&"margin_right", 4)
	margin.add_theme_constant_override(&"margin_bottom", 4)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 4)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(title, TITLE_FONT_SIZE, &"semibold")
	title.add_theme_color_override(&"font_color", COLOR_GOLD)
	vbox.add_child(title)

	_master_slider = _add_slider_row(vbox, "Master")
	_music_slider = _add_slider_row(vbox, "Music")
	_sfx_slider = _add_slider_row(vbox, "SFX")

	_damage_toggle = CheckBox.new()
	_damage_toggle.text = "Damage numbers"
	_damage_toggle.add_theme_font_size_override(&"font_size", BODY_FONT_SIZE)
	_damage_toggle.add_theme_color_override(&"font_color", COLOR_TEXT)
	vbox.add_child(_damage_toggle)

	var apply_btn := Button.new()
	apply_btn.text = "Apply"
	apply_btn.pressed.connect(_on_apply_pressed)
	_apply_button_theme(apply_btn)
	vbox.add_child(apply_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_on_close_pressed)
	_apply_button_theme(close_btn)
	vbox.add_child(close_btn)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(_status_label, BODY_FONT_SIZE)
	_status_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	vbox.add_child(_status_label)


func _add_slider_row(parent: VBoxContainer, label_text: String) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 6)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 44
	HudStyle.apply_hud_font(label, BODY_FONT_SIZE)
	label.add_theme_color_override(&"font_color", COLOR_TEXT)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = 1.0
	slider.custom_minimum_size.y = 12
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	parent.add_child(row)
	return slider


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


func refresh() -> void:
	_load_from_game_manager()


func _load_from_game_manager() -> void:
	var settings := GameManager.get_settings_snapshot()
	_master_slider.value = float(settings.get("master_volume", 1.0))
	_music_slider.value = float(settings.get("music_volume", 1.0))
	_sfx_slider.value = float(settings.get("sfx_volume", 1.0))
	_damage_toggle.button_pressed = bool(settings.get("damage_numbers", false))


func _on_apply_pressed() -> void:
	GameManager.apply_settings({
		"master_volume": _master_slider.value,
		"music_volume": _music_slider.value,
		"sfx_volume": _sfx_slider.value,
		"damage_numbers": _damage_toggle.button_pressed,
	})
	AudioManager.apply_settings(GameManager.get_settings_snapshot())
	_status_label.text = "Settings applied"


func _on_close_pressed() -> void:
	visible = false
	var ui := get_parent()
	if ui.has_method(&"_close_pause"):
		ui._close_pause()
