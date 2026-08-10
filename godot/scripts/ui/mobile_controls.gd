class_name MobileControls
extends CanvasLayer
## Touch-only gameplay controls for mobile browsers and native touch devices.
##
## TouchScreenButton nodes handle touch detection, but their built-in action
## injection is bypassed because it does not reliably trigger
## Input.is_action_just_pressed() on mobile/web exports. Instead, the
## pressed/released signals are wired to Input.parse_input_event() so the
## regular input map behaves identically to keyboard/gamepad input.
##
## Mobile layout (960x540 design resolution):
##   Top-right: inventory | map | pause icons
##   Bottom-left: < >  (enlarged movement)
##   Bottom-right: attack (sword icon) in the centre, jump below, four quick
##   spells in a semi-circle to the left and above the attack button.


const BASE_VIEWPORT := Vector2(960.0, 540.0)
const MIN_SCALE := 0.55

const MOVE_BUTTON_RADIUS := 34.0
const ATTACK_BUTTON_RADIUS := 34.0
const JUMP_BUTTON_RADIUS := 24.0
const SPELL_BUTTON_RADIUS := 26.0
const UTILITY_BUTTON_RADIUS := 17.0
const UTILITY_ICON_RADIUS := 14.0

const MOVE_BUTTONS: Array[Dictionary] = [
	{"id": &"move_left", "label": "<", "position": Vector2(74, 466)},
	{"id": &"move_right", "label": ">", "position": Vector2(150, 466)},
]

const ATTACK_BUTTON := {"id": &"melee_attack", "position": Vector2(880, 420)}
const JUMP_BUTTON := {"id": &"jump", "label": "J", "position": Vector2(910, 480)}

const SPELL_CLUSTER_CENTER := Vector2(880, 420)
const SPELL_BUTTON_OFFSET := 72.0
const SPELL_BUTTON_ANGLES: Array[float] = [
	deg_to_rad(135.0),
	deg_to_rad(180.0),
	deg_to_rad(225.0),
	deg_to_rad(270.0),
]

const TOP_UTILITY_BUTTONS: Array[Dictionary] = [
	{"id": &"inventory_toggle", "icon": &"inventory", "position": Vector2(820, 52)},
	{"id": &"map_toggle", "icon": &"map", "position": Vector2(860, 52)},
	{"id": &"pause", "icon": &"menu", "position": Vector2(900, 52)},
]

const SIDE_UTILITY_BUTTONS: Array[Dictionary] = [
	{"id": &"dash", "icon": &"dash", "position": Vector2(886, 300)},
	{"id": &"interact", "icon": &"use", "position": Vector2(480, 496)},
]

const QUICK_SPELL_ACTIONS: Array[StringName] = [
	&"quick_spell_1",
	&"quick_spell_2",
	&"quick_spell_3",
	&"quick_spell_4",
]

var _gameplay_controls := Node2D.new()
var _rotate_prompt := Control.new()
var _touch_confirmed := false
var _touch_available_at_startup := false
var _spell_buttons: Array[Dictionary] = []
var _dash_icon: Sprite2D = null


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "MobileControls"
	_gameplay_controls.name = "GameplayControls"
	_touch_available_at_startup = _detect_touch_available()
	add_child(_gameplay_controls)

	for button_data in MOVE_BUTTONS:
		_add_action_button(button_data, MOVE_BUTTON_RADIUS)
	_add_attack_button()
	_add_action_button(JUMP_BUTTON, JUMP_BUTTON_RADIUS)
	_build_quick_spell_buttons()
	for button_data in TOP_UTILITY_BUTTONS:
		_add_icon_button(button_data, UTILITY_ICON_RADIUS)
	for button_data in SIDE_UTILITY_BUTTONS:
		_add_icon_button(button_data, UTILITY_BUTTON_RADIUS)

	_build_rotate_prompt()
	get_viewport().size_changed.connect(_refresh_visibility)
	get_viewport().size_changed.connect(_refresh_layout)
	EventBus.spell_acquired.connect(_on_spell_acquired)
	_refresh_spell_icons()
	_refresh_visibility()
	_refresh_layout()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_refresh_visibility):
		get_viewport().size_changed.disconnect(_refresh_visibility)
	if get_viewport().size_changed.is_connected(_refresh_layout):
		get_viewport().size_changed.disconnect(_refresh_layout)
	if EventBus.spell_acquired.is_connected(_on_spell_acquired):
		EventBus.spell_acquired.disconnect(_on_spell_acquired)


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
	var button := _create_touch_button(action, button_data["position"] as Vector2, radius)
	_gameplay_controls.add_child(button)

	button.add_child(_create_button_face(radius))
	button.add_child(_create_button_border(radius))

	var label := Label.new()
	label.position = Vector2(-radius, -8)
	label.size = Vector2(radius * 2.0, 16.0)
	label.text = String(button_data.get("label", ""))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	HudStyle.apply_hud_font(label, 9)
	label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	button.add_child(label)


func _add_icon_button(button_data: Dictionary, radius: float) -> void:
	var action := button_data["id"] as StringName
	var button := _create_touch_button(action, button_data["position"] as Vector2, radius)
	_gameplay_controls.add_child(button)

	button.add_child(_create_button_face(radius))
	button.add_child(_create_button_border(radius))

	var icon_type := button_data["icon"] as StringName
	match icon_type:
		&"inventory":
			button.add_child(_create_inventory_icon(radius))
		&"map":
			button.add_child(_create_map_icon(radius))
		&"menu":
			button.add_child(_create_menu_icon(radius))
		&"use":
			button.add_child(_create_use_icon(radius))
		&"dash":
			var icon := Sprite2D.new()
			icon.name = "DashIcon"
			button.add_child(icon)
			_dash_icon = icon


func _add_attack_button() -> void:
	var button := _create_touch_button(
		ATTACK_BUTTON["id"] as StringName,
		ATTACK_BUTTON["position"] as Vector2,
		ATTACK_BUTTON_RADIUS
	)
	_gameplay_controls.add_child(button)
	button.add_child(_create_button_face(ATTACK_BUTTON_RADIUS))
	button.add_child(_create_button_border(ATTACK_BUTTON_RADIUS))
	button.add_child(_create_sword_icon(ATTACK_BUTTON_RADIUS))


func _build_quick_spell_buttons() -> void:
	_spell_buttons.clear()
	for i in QUICK_SPELL_ACTIONS.size():
		var angle: float = SPELL_BUTTON_ANGLES[i]
		var offset := Vector2(cos(angle), sin(angle)) * SPELL_BUTTON_OFFSET
		var position := SPELL_CLUSTER_CENTER + offset
		var action := QUICK_SPELL_ACTIONS[i]
		var button := _create_touch_button(action, position, SPELL_BUTTON_RADIUS)
		_gameplay_controls.add_child(button)
		button.add_child(_create_button_face(SPELL_BUTTON_RADIUS))
		button.add_child(_create_button_border(SPELL_BUTTON_RADIUS))

		var icon := Sprite2D.new()
		icon.name = "SpellIcon"
		button.add_child(icon)
		_spell_buttons.append({"index": i, "icon": icon})


func _create_touch_button(action: StringName, position: Vector2, radius: float) -> TouchScreenButton:
	var button := TouchScreenButton.new()
	button.name = String(action)
	button.position = position
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
	return button


func _create_button_face(radius: float) -> Polygon2D:
	var face := Polygon2D.new()
	face.polygon = _circle_points(radius - 1.0)
	var face_color := HudStyle.COLOR_BG
	face_color.a = 0.82
	face.color = face_color
	return face


func _create_button_border(radius: float) -> Line2D:
	var border := Line2D.new()
	border.width = 1.0
	border.default_color = HudStyle.COLOR_BORDER_GOLD
	border.points = _circle_points(radius - 1.5)
	border.points.append(border.points[0])
	return border


func _create_sword_icon(radius: float) -> Node2D:
	var root := Node2D.new()
	root.rotation = deg_to_rad(42.0)
	var reach := radius * 0.62

	var blade := Polygon2D.new()
	blade.polygon = PackedVector2Array([
		Vector2(-reach * 0.14, reach * 0.25),
		Vector2(-reach * 0.14, -reach * 0.58),
		Vector2(0, -reach * 0.82),
		Vector2(reach * 0.14, -reach * 0.58),
		Vector2(reach * 0.14, reach * 0.25),
	])
	blade.color = HudStyle.COLOR_TEXT
	root.add_child(blade)

	var guard := Line2D.new()
	guard.width = 4.0
	guard.default_color = HudStyle.COLOR_BORDER_GOLD
	guard.begin_cap_mode = Line2D.LINE_CAP_ROUND
	guard.end_cap_mode = Line2D.LINE_CAP_ROUND
	guard.points = PackedVector2Array([
		Vector2(-reach * 0.42, reach * 0.22),
		Vector2(reach * 0.42, reach * 0.22),
	])
	root.add_child(guard)

	var grip := Line2D.new()
	grip.width = 5.0
	grip.default_color = HudStyle.COLOR_BORDER
	grip.begin_cap_mode = Line2D.LINE_CAP_ROUND
	grip.end_cap_mode = Line2D.LINE_CAP_ROUND
	grip.points = PackedVector2Array([
		Vector2(0, reach * 0.25),
		Vector2(0, reach * 0.62),
	])
	root.add_child(grip)

	var pommel := Polygon2D.new()
	pommel.polygon = _circle_points(reach * 0.14)
	pommel.position = Vector2(0, reach * 0.68)
	pommel.color = HudStyle.COLOR_EMBER
	root.add_child(pommel)

	return root


func _create_inventory_icon(radius: float) -> Node2D:
	var root := Node2D.new()
	var reach := radius * 0.5
	var color := HudStyle.COLOR_TEXT

	var body := Line2D.new()
	body.width = 2.0
	body.default_color = color
	body.joint_mode = Line2D.LINE_JOINT_ROUND
	body.begin_cap_mode = Line2D.LINE_CAP_ROUND
	body.end_cap_mode = Line2D.LINE_CAP_ROUND
	body.points = PackedVector2Array([
		Vector2(-reach, -reach * 0.3),
		Vector2(reach, -reach * 0.3),
		Vector2(reach * 0.7, reach * 0.6),
		Vector2(-reach * 0.7, reach * 0.6),
		Vector2(-reach, -reach * 0.3),
	])
	root.add_child(body)

	var handle := Line2D.new()
	handle.width = 2.0
	handle.default_color = color
	handle.begin_cap_mode = Line2D.LINE_CAP_ROUND
	handle.end_cap_mode = Line2D.LINE_CAP_ROUND
	handle.points = PackedVector2Array([
		Vector2(-reach * 0.3, -reach * 0.3),
		Vector2(-reach * 0.3, -reach * 0.65),
		Vector2(reach * 0.3, -reach * 0.65),
		Vector2(reach * 0.3, -reach * 0.3),
	])
	root.add_child(handle)

	return root


func _create_map_icon(radius: float) -> Node2D:
	var root := Node2D.new()
	var reach := radius * 0.55
	var color := HudStyle.COLOR_TEXT

	var ring := Line2D.new()
	ring.width = 2.0
	ring.default_color = color
	ring.points = _circle_points(reach)
	ring.points.append(ring.points[0])
	root.add_child(ring)

	var needle := Line2D.new()
	needle.width = 2.0
	needle.default_color = color
	needle.begin_cap_mode = Line2D.LINE_CAP_ROUND
	needle.end_cap_mode = Line2D.LINE_CAP_ROUND
	needle.points = PackedVector2Array([
		Vector2(0, -reach * 0.7),
		Vector2(0, reach * 0.3),
	])
	root.add_child(needle)

	return root


func _create_menu_icon(radius: float) -> Node2D:
	var root := Node2D.new()
	var w := radius * 0.6
	var color := HudStyle.COLOR_TEXT
	var y_positions := [-radius * 0.25, 0.0, radius * 0.25]
	for y in y_positions:
		var line := Line2D.new()
		line.width = 2.0
		line.default_color = color
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.points = PackedVector2Array([Vector2(-w, y), Vector2(w, y)])
		root.add_child(line)
	return root


func _create_use_icon(radius: float) -> Node2D:
	var root := Node2D.new()
	var reach := radius * 0.5
	var color := HudStyle.COLOR_TEXT

	var arrow := Line2D.new()
	arrow.width = 2.5
	arrow.default_color = color
	arrow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	arrow.end_cap_mode = Line2D.LINE_CAP_ROUND
	arrow.joint_mode = Line2D.LINE_JOINT_ROUND
	arrow.points = PackedVector2Array([
		Vector2(-reach * 0.55, reach * 0.15),
		Vector2(0, -reach * 0.55),
		Vector2(reach * 0.55, reach * 0.15),
	])
	root.add_child(arrow)

	return root


func _refresh_spell_icons() -> void:
	for entry in _spell_buttons:
		var index: int = entry["index"]
		var icon: Sprite2D = entry["icon"]
		var spell_id := SpellManager.get_quick_slot(index)
		var spell := SpellManager.get_spell(spell_id)
		if spell and spell.icon:
			icon.texture = spell.icon
			var size := spell.icon.get_size()
			var target := SPELL_BUTTON_RADIUS * 1.4
			icon.scale = Vector2(target / size.x, target / size.y)
			icon.modulate = Color.WHITE
		else:
			icon.texture = null
			icon.scale = Vector2.ONE
			icon.modulate = Color(1, 1, 1, 0.25)

	if _dash_icon:
		var dash_spell := SpellManager.get_spell(&"veil_step")
		if dash_spell and dash_spell.icon:
			_dash_icon.texture = dash_spell.icon
			var size := dash_spell.icon.get_size()
			var target := UTILITY_BUTTON_RADIUS * 1.6
			_dash_icon.scale = Vector2(target / size.x, target / size.y)
			_dash_icon.modulate = Color.WHITE if SpellManager.has_spell(&"veil_step") else Color(1, 1, 1, 0.35)
		else:
			_dash_icon.texture = null
			_dash_icon.modulate = Color(1, 1, 1, 0.25)


func _on_spell_acquired(_spell_id: StringName) -> void:
	_refresh_spell_icons()


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
