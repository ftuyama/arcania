extends Control
## Minimal dialogue overlay — advance lines with Interact.


signal dialogue_finished

var _panel: PanelContainer
var _name_label: Label
var _body_label: Label
var _prompt_label: Label
var _continue_button: Button

var _lines: Array[String] = []
var _speaker: String = ""
var _index: int = 0
var _active: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bottom := MarginContainer.new()
	bottom.set_anchors_preset(Control.PRESET_FULL_RECT)
	bottom.add_theme_constant_override(&"margin_left", 24)
	bottom.add_theme_constant_override(&"margin_right", 24)
	bottom.add_theme_constant_override(&"margin_bottom", 24)
	add_child(bottom)

	_panel = PanelContainer.new()
	_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.09, 0.94)
	style.border_color = Color(0.72, 0.48, 0.18, 0.75)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	_panel.add_theme_stylebox_override(&"panel", style)
	bottom.add_child(_panel)

	var vbox := VBoxContainer.new()
	_panel.add_child(vbox)
	_name_label = Label.new()
	HudStyle.apply_hud_font(_name_label, 13, &"semibold")
	_name_label.add_theme_color_override(&"font_color", Color(0.92, 0.78, 0.55, 1.0))
	vbox.add_child(_name_label)
	_body_label = Label.new()
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	HudStyle.apply_hud_font(_body_label, 12)
	_body_label.add_theme_color_override(&"font_color", Color(0.88, 0.84, 0.76, 1.0))
	vbox.add_child(_body_label)
	_prompt_label = Label.new()
	HudStyle.apply_hud_font(_prompt_label, 11)
	_prompt_label.add_theme_color_override(&"font_color", Color(0.58, 0.54, 0.48, 1.0))
	vbox.add_child(_prompt_label)
	if MobileControls.is_likely_touch_device():
		_continue_button = Button.new()
		_continue_button.pressed.connect(_advance)
		HudStyle.apply_ui_font(_continue_button, 11)
		vbox.add_child(_continue_button)


func start_dialogue(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		return
	_speaker = speaker
	_lines = lines.duplicate()
	_index = 0
	_active = true
	visible = true
	GameManager.state = GameManager.GameState.CUTSCENE
	get_tree().paused = true
	_show_line()


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not visible:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"jump"):
		_advance()
		get_viewport().set_input_as_handled()


func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
		return
	_show_line()


func _show_line() -> void:
	_name_label.text = _speaker
	_body_label.text = _lines[_index]
	if MobileControls.is_likely_touch_device():
		_prompt_label.text = "Tap Continue" if _index < _lines.size() - 1 else "Tap Close"
		if _continue_button:
			_continue_button.text = "Continue" if _index < _lines.size() - 1 else "Close"
	else:
		_prompt_label.text = "[E] Continue" if _index < _lines.size() - 1 else "[E] Close"


func _close() -> void:
	_active = false
	visible = false
	get_tree().paused = false
	GameManager.state = GameManager.GameState.PLAYING
	dialogue_finished.emit()
