class_name MobileControls
extends CanvasLayer
## Touch-only gameplay controls for mobile browsers and native touch devices.
##
## TouchScreenButton nodes handle touch detection, but their built-in action
## injection is bypassed because it does not reliably trigger
## Input.is_action_just_pressed() on mobile/web exports. Instead, the
## pressed/released signals are wired to Input.parse_input_event() so the
## regular input map behaves identically to keyboard/gamepad input.


const BASE_VIEWPORT := Vector2(960.0, 540.0)
const BUTTON_RADIUS := 25.0
const SMALL_BUTTON_RADIUS := 17.0
const MIN_SCALE := 0.55

const ACTION_BUTTONS: Array[Dictionary] = [
	{"id": &"move_left", "label": "<", "position": Vector2(54, 478)},
	{"id": &"move_right", "label": ">", "position": Vector2(116, 478)},
	{"id": &"aim_up", "label": "UP", "position": Vector2(786, 388)},
	{"id": &"aim_left", "label": "<", "position": Vector2(752, 422)},
	{"id": &"aim_right", "label": ">", "position": Vector2(820, 422)},
	{"id": &"aim_down", "label": "DN", "position": Vector2(786, 456)},
	{"id": &"jump", "label": "JUMP", "position": Vector2(902, 458)},
	{"id": &"melee_attack", "label": "ATK", "position": Vector2(900, 394)},
	{"id": &"cast_spell", "label": "CAST", "position": Vector2(848, 484)},
	{"id": &"dash", "label": "DASH", "position": Vector2(906, 330)},
	{"id": &"interact", "label": "USE", "position": Vector2(480, 496)},
]

const UTILITY_BUTTONS: Array[Dictionary] = [
	{"id": &"pause", "label": "II", "position": Vector2(926, 32)},
	{"id": &"map_toggle", "label": "MAP", "position": Vector2(878, 32)},
	{"id": &"inventory_toggle", "label": "INV", "position": Vector2(826, 32)},
	{"id": &"spell_wheel", "label": "SPELL", "position": Vector2(758, 32)},
	{"id": &"quick_spell_1", "label": "1", "position": Vector2(650, 32)},
	{"id": &"quick_spell_2", "label": "2", "position": Vector2(688, 32)},
	{"id": &"quick_spell_3", "label": "3", "position": Vector2(726, 32)},
	{"id": &"quick_spell_4", "label": "4", "position": Vector2(764, 70)},
]

var _gameplay_controls := Node2D.new()
var _rotate_prompt := Control.new()
var _touch_confirmed := false
var _touch_available_at_startup := false


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "MobileControls"
	_gameplay_controls.name = "GameplayControls"
	_touch_available_at_startup = _detect_touch_available()
	add_child(_gameplay_controls)
	for button_data in ACTION_BUTTONS:
		_add_action_button(button_data, BUTTON_RADIUS)
	for button_data in UTILITY_BUTTONS:
		_add_action_button(button_data, SMALL_BUTTON_RADIUS)
	_build_rotate_prompt()
	get_viewport().size_changed.connect(_refresh_visibility)
	get_viewport().size_changed.connect(_refresh_layout)
	_refresh_visibility()
	_refresh_layout()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_refresh_visibility):
		get_viewport().size_changed.disconnect(_refresh_visibility)
	if get_viewport().size_changed.is_connected(_refresh_layout):
		get_viewport().size_changed.disconnect(_refresh_layout)


func _process(_delta: float) -> void:
	_refresh_visibility()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if not _touch_confirmed:
			_touch_confirmed = true
			_refresh_visibility()


func is_landscape() -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	return viewport_size.x >= viewport_size.y


func _refresh_visibility() -> void:
	var touch_available := _is_touch_available()
	var can_play := GameManager.state == GameManager.GameState.PLAYING and _no_modal_is_open()
	var landscape := is_landscape()
	_gameplay_controls.visible = touch_available and can_play and landscape
	_rotate_prompt.visible = touch_available and not landscape


func _refresh_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var scale_x := viewport_size.x / BASE_VIEWPORT.x
	var scale_y := viewport_size.y / BASE_VIEWPORT.y
	var scale := clampf(minf(scale_x, scale_y), MIN_SCALE, 1.0)
	_gameplay_controls.scale = Vector2(scale, scale)
	_gameplay_controls.position = (viewport_size - BASE_VIEWPORT * scale) * 0.5


func _is_touch_available() -> bool:
	return _touch_confirmed or _touch_available_at_startup


func _detect_touch_available() -> bool:
	return is_likely_touch_device()


## Returns true when running on a platform that is expected to use touch input.
## This is cached at startup by MobileControls; other UI scripts can call it
## directly to decide whether to show tap-friendly UI.
static func is_likely_touch_device() -> bool:
	if DisplayServer.is_touchscreen_available():
		return true
	if OS.has_feature("mobile"):
		return true
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return true
	if OS.has_feature("web"):
		return _is_mobile_user_agent()
	return false


static func _is_mobile_user_agent() -> bool:
	if not OS.has_feature("web"):
		return false
	var js_bridge := Engine.get_singleton("JavaScriptBridge")
	if js_bridge == null:
		return false
	var window: Variant = js_bridge.get_interface("window")
	if window == null:
		return false
	var user_agent: String = window.navigator.userAgent
	user_agent = user_agent.to_lower()
	var mobile_tokens := ["android", "iphone", "ipad", "ipod", "windows phone", "mobile"]
	for token in mobile_tokens:
		if user_agent.contains(token):
			return true
	return false


func _no_modal_is_open() -> bool:
	var ui := get_parent()
	if ui == null:
		return true
	for modal_name in [&"InventoryPanel", &"QuestLog", &"MapOverlay", &"SpellWheel", &"PauseMenu", &"GameOverScreen", &"DialogueBox", &"ControlsOverlay", &"SettingsPanel"]:
		var modal := ui.get_node_or_null(NodePath(modal_name)) as CanvasItem
		if modal and modal.visible:
			return false
	return true


func _add_action_button(button_data: Dictionary, radius: float) -> void:
	var action := button_data["id"] as StringName
	var button := TouchScreenButton.new()
	button.name = String(action)
	button.position = button_data["position"] as Vector2
	# Leave the built-in action empty so we can inject InputEventAction manually.
	# This avoids the mobile/web bug where TouchScreenButton actions do not
	# reliably trigger Input.is_action_just_pressed().
	button.action = &""
	button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
	button.passby_press = true
	button.shape_visible = false
	var shape := CircleShape2D.new()
	shape.radius = radius
	button.shape = shape
	button.pressed.connect(_on_button_pressed.bind(action))
	button.released.connect(_on_button_released.bind(action))
	_gameplay_controls.add_child(button)

	var face := Polygon2D.new()
	face.polygon = _circle_points(radius - 1.0)
	var face_color := HudStyle.COLOR_BG
	face_color.a = 0.82
	face.color = face_color
	button.add_child(face)

	var border := Line2D.new()
	border.width = 1.0
	border.default_color = HudStyle.COLOR_BORDER_GOLD
	border.points = _circle_points(radius - 1.5)
	border.points.append(border.points[0])
	button.add_child(border)

	var label := Label.new()
	label.position = Vector2(-radius, -8)
	label.size = Vector2(radius * 2.0, 16.0)
	label.text = String(button_data["label"])
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	HudStyle.apply_hud_font(label, 9)
	label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	button.add_child(label)


func _on_button_pressed(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	event.device = 0
	Input.parse_input_event(event)


func _on_button_released(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = false
	event.device = 0
	Input.parse_input_event(event)


func _circle_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 12:
		var angle := TAU * float(i) / 12.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _build_rotate_prompt() -> void:
	_rotate_prompt.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rotate_prompt.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_rotate_prompt)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.02, 0.06, 0.96)
	_rotate_prompt.add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rotate_prompt.add_child(center)

	var label := Label.new()
	label.text = "Rotate your device to landscape"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(260, 0)
	HudStyle.apply_hud_font(label, 16, &"semibold")
	label.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
	center.add_child(label)
