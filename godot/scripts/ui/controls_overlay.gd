extends Control
## Onboarding overlay — controls and core loop tips at new game start.


signal dismissed

const CONTROL_ROWS: Array[Dictionary] = [
	{"action": "Move", "keys": "A / D  or  ← / →"},
	{"action": "Jump", "keys": "Space"},
	{"action": "Melee Attack", "keys": "J"},
	{"action": "Aim Spell", "keys": "Arrow keys"},
	{"action": "Veil Step", "keys": "Shift"},
	{"action": "Interact", "keys": "E"},
	{"action": "Spell Wheel", "keys": "Tab"},
	{"action": "Quick Spells", "keys": "1 – 4"},
	{"action": "Map", "keys": "M"},
	{"action": "Inventory", "keys": "I"},
	{"action": "Pause", "keys": "Esc"},
]

const TIPS: PackedStringArray = [
	"Spells fight enemies and open new paths — swap loadouts from the spell wheel.",
	"Restore mana at Focus Crucibles. Collect relics to grow stronger.",
]

var _active: bool = false
var _prompt_label: Label


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func present() -> void:
	_active = true
	visible = true
	GameManager.state = GameManager.GameState.CUTSCENE
	get_tree().paused = true
	if _prompt_label:
		_prompt_label.modulate.a = 1.0
		_start_prompt_pulse()


func _build_ui() -> void:
	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.02, 0.06, 1.0)
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 0)
	var panel_style := HudStyle.make_panel_style(true)
	panel_style.bg_color.a = 1.0
	panel.add_theme_stylebox_override(&"panel", panel_style)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", 10)
	margin.add_theme_constant_override(&"margin_top", 10)
	margin.add_theme_constant_override(&"margin_right", 10)
	margin.add_theme_constant_override(&"margin_bottom", 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 4)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "How to Play"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(title, 13, &"semibold")
	title.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
	vbox.add_child(title)

	var tips_box := VBoxContainer.new()
	tips_box.add_theme_constant_override(&"separation", 2)
	vbox.add_child(tips_box)
	for tip in TIPS:
		tips_box.add_child(_make_body_label("• %s" % tip))

	var section := Label.new()
	section.text = "Controls"
	section.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(section, 11, &"semibold")
	section.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	vbox.add_child(section)

	var controls_row := HBoxContainer.new()
	controls_row.add_theme_constant_override(&"separation", 14)
	controls_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(controls_row)

	var split := ceili(float(CONTROL_ROWS.size()) / 2.0)
	controls_row.add_child(_make_control_column(CONTROL_ROWS.slice(0, split)))
	controls_row.add_child(_make_control_column(CONTROL_ROWS.slice(split)))

	_prompt_label = Label.new()
	_prompt_label.text = "Tap to begin" if MobileControls.is_likely_touch_device() else "Press Space or E to begin"
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	HudStyle.apply_hud_font(_prompt_label, 10)
	_prompt_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	vbox.add_child(_prompt_label)
	if MobileControls.is_likely_touch_device():
		var begin_button := Button.new()
		begin_button.text = "Begin"
		begin_button.pressed.connect(_dismiss)
		HudStyle.apply_ui_font(begin_button, 11)
		vbox.add_child(begin_button)


func _make_control_column(rows: Array) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 8)
	grid.add_theme_constant_override(&"v_separation", 2)
	for row in rows:
		grid.add_child(_make_action_label(row["action"]))
		grid.add_child(_make_key_label(row["keys"]))
	return grid


func _make_body_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 420.0
	HudStyle.apply_hud_font(label, 9)
	label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	return label


func _make_action_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 80.0
	HudStyle.apply_hud_font(label, 9)
	label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	return label


func _make_key_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	HudStyle.apply_hud_font(label, 9, &"semibold")
	label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	return label


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not visible:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"jump"):
		_dismiss()
		get_viewport().set_input_as_handled()


func _dismiss() -> void:
	if not _active:
		return
	_active = false
	visible = false
	get_tree().paused = false
	GameManager.state = GameManager.GameState.PLAYING
	dismissed.emit()


func _start_prompt_pulse() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_prompt_label, "modulate:a", 0.35, 0.9)
	tween.tween_property(_prompt_label, "modulate:a", 1.0, 0.9)
