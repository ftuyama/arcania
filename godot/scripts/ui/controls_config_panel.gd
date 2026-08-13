extends Control
## Keyboard controls configuration panel for the title screen.


signal closed

const COLOR_GOLD := Color(0.92, 0.78, 0.55, 1.0)
const COLOR_TEXT := Color(0.88, 0.84, 0.76, 1.0)
const COLOR_DISABLED := Color(0.55, 0.50, 0.44, 1.0)
const TITLE_FONT_SIZE := 13
const BODY_FONT_SIZE := 10
const BUTTON_FONT_SIZE := 10
const BUTTON_MARGIN_V := 2
const BUTTON_MARGIN_H := 5

const ACTION_DISPLAY_NAMES: Dictionary = {
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"melee_attack": "Melee Attack",
	"dash": "Veil Step",
	"interact": "Interact",
	"spell_wheel": "Spell Wheel",
	"quick_spell_1": "Quick Spell 1",
	"quick_spell_2": "Quick Spell 2",
	"quick_spell_3": "Quick Spell 3",
	"quick_spell_4": "Quick Spell 4",
	"map_toggle": "Map",
	"inventory_toggle": "Inventory",
	"pause": "Pause",
}

var _row_by_action: Dictionary = {}
var _listening_action: StringName = &""
var _status_label: Label
var _scroll: ScrollContainer


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	UiSfx.wire_tree(self)


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0, 0, 0, 0.55)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(320, 0)
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
	vbox.add_theme_constant_override(&"separation", 6)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Controls"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(title, TITLE_FONT_SIZE, &"semibold")
	title.add_theme_color_override(&"font_color", COLOR_GOLD)
	vbox.add_child(title)

	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size.y = 180
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(_scroll)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override(&"separation", 4)
	_scroll.add_child(rows)

	for action in GameManager.REMAPPABLE_ACTIONS:
		rows.add_child(_make_action_row(action))

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(_status_label, BODY_FONT_SIZE)
	_status_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	vbox.add_child(_status_label)

	var reset_btn := Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.pressed.connect(_on_reset_pressed)
	_apply_button_theme(reset_btn)
	vbox.add_child(reset_btn)

	var close_btn := Button.new()
	close_btn.text = "Back"
	close_btn.pressed.connect(_on_close_pressed)
	_apply_button_theme(close_btn)
	vbox.add_child(close_btn)


func _make_action_row(action: StringName) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	var name_label := Label.new()
	name_label.text = ACTION_DISPLAY_NAMES.get(String(action), String(action))
	name_label.custom_minimum_size.x = 110
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	HudStyle.apply_hud_font(name_label, BODY_FONT_SIZE)
	name_label.add_theme_color_override(&"font_color", COLOR_TEXT)
	row.add_child(name_label)

	var key_label := Label.new()
	key_label.name = "KeyLabel"
	key_label.custom_minimum_size.x = 80
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(key_label, BODY_FONT_SIZE, &"semibold")
	key_label.add_theme_color_override(&"font_color", COLOR_GOLD)
	row.add_child(key_label)

	var change_btn := Button.new()
	change_btn.text = "Change"
	change_btn.pressed.connect(_on_change_pressed.bind(action))
	_apply_button_theme(change_btn)
	row.add_child(change_btn)

	_row_by_action[action] = {"row": row, "key_label": key_label, "button": change_btn}
	_refresh_row(action)
	return row


func _refresh_row(action: StringName) -> void:
	var row_data = _row_by_action.get(action)
	if row_data == null:
		return
	var key_label: Label = row_data["key_label"]
	var button: Button = row_data["button"]
	var events := InputMap.action_get_events(action)
	var key_text := "—"
	for event in events:
		if event is InputEventKey:
			key_text = _key_name(event.physical_keycode)
			break
	if key_text == "—":
		var default_keycode: int = GameManager.DEFAULT_KEY_BINDINGS.get(String(action), 0)
		if default_keycode != 0:
			key_text = _key_name(default_keycode)
	key_label.text = key_text
	button.text = "Change" if _listening_action != action else "Press key..."
	button.disabled = _listening_action != &"" and _listening_action != action


func _key_name(keycode: int) -> String:
	if keycode == KEY_SPACE:
		return "Space"
	if keycode == KEY_ESCAPE:
		return "Esc"
	if keycode == KEY_TAB:
		return "Tab"
	if keycode == KEY_SHIFT:
		return "Shift"
	if keycode == KEY_CTRL:
		return "Ctrl"
	if keycode == KEY_ALT:
		return "Alt"
	if keycode == KEY_ENTER:
		return "Enter"
	if keycode == KEY_BACKSPACE:
		return "Backspace"
	if keycode >= KEY_0 and keycode <= KEY_9:
		return String.chr(keycode)
	if keycode >= KEY_A and keycode <= KEY_Z:
		return String.chr(keycode)
	return OS.get_keycode_string(keycode)


func _on_change_pressed(action: StringName) -> void:
	_listening_action = action
	_status_label.text = "Press a key for %s" % ACTION_DISPLAY_NAMES.get(String(action), String(action))
	_refresh_all_rows()


func _on_reset_pressed() -> void:
	GameManager.reset_controls_to_defaults()
	_status_label.text = "Controls reset to defaults"
	_refresh_all_rows()


func _on_close_pressed() -> void:
	_listening_action = &""
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE):
		if _listening_action.is_empty():
			_on_close_pressed()
		else:
			_listening_action = &""
			_status_label.text = "Cancelled"
			_refresh_all_rows()
		get_viewport().set_input_as_handled()
		return
	if _listening_action.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_set_action_key(_listening_action, event.physical_keycode)
		_listening_action = &""
		_status_label.text = "Binding updated"
		_refresh_all_rows()
		get_viewport().set_input_as_handled()


func _set_action_key(action: StringName, keycode: int) -> void:
	InputMap.action_erase_events(action)
	var new_event := InputEventKey.new()
	new_event.physical_keycode = keycode
	InputMap.action_add_event(action, new_event)
	GameManager.save_controls(_capture_bindings())


func _capture_bindings() -> Dictionary:
	var bindings := {}
	for action in GameManager.REMAPPABLE_ACTIONS:
		var events := InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				bindings[String(action)] = event.physical_keycode
				break
	return bindings


func _refresh_all_rows() -> void:
	for action in GameManager.REMAPPABLE_ACTIONS:
		_refresh_row(action)


func present() -> void:
	visible = true
	_status_label.text = ""
	_listening_action = &""
	_refresh_all_rows()


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
	HudStyle.apply_ui_font(btn, BUTTON_FONT_SIZE)

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
