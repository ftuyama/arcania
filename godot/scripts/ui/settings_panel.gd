extends Control
## Volume and accessibility settings panel.


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
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -180
	panel.offset_top = -120
	panel.offset_right = 180
	panel.offset_bottom = 120
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.11, 0.96)
	style.border_color = Color(0.72, 0.48, 0.18, 0.65)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override(&"panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_master_slider = _add_slider_row(vbox, "Master")
	_music_slider = _add_slider_row(vbox, "Music")
	_sfx_slider = _add_slider_row(vbox, "SFX")

	_damage_toggle = CheckBox.new()
	_damage_toggle.text = "Damage numbers"
	vbox.add_child(_damage_toggle)

	var apply_btn := Button.new()
	apply_btn.text = "Apply"
	apply_btn.pressed.connect(_on_apply_pressed)
	vbox.add_child(apply_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_on_close_pressed)
	vbox.add_child(close_btn)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_status_label)


func _add_slider_row(parent: VBoxContainer, label_text: String) -> HSlider:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 56
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	parent.add_child(row)
	return slider


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
