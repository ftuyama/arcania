extends PanelContainer
## Bottom-right weave silk currency counter with skull icon + ornate end-cap.


var _icon: TextureRect
var _value: Label
var _endcap: TextureRect


func _ready() -> void:
	# Flatter currency plate — closer to screenshot bottom-right chrome.
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.07, 0.1, 0.82)
	style.border_color = HudStyle.COLOR_BORDER_GOLD
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 8
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	add_theme_stylebox_override(&"panel", style)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(row)

	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(16, 16)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture = HudStyle.get_hud_texture(&"skull_icon")
	row.add_child(_icon)

	_value = Label.new()
	_value.text = "0"
	HudStyle.apply_hud_font(_value, 13, &"semibold")
	_value.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_value.custom_minimum_size = Vector2(48, 0)
	row.add_child(_value)

	_endcap = TextureRect.new()
	_endcap.custom_minimum_size = Vector2(22, 22)
	_endcap.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_endcap.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_endcap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_endcap.texture = HudStyle.get_hud_texture(&"currency_endcap")
	row.add_child(_endcap)

	custom_minimum_size = Vector2(120, 26)
	EventBus.currency_changed.connect(_on_currency_changed)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.quest_completed.connect(_on_quest_completed)
	refresh()


func _exit_tree() -> void:
	if EventBus.currency_changed.is_connected(_on_currency_changed):
		EventBus.currency_changed.disconnect(_on_currency_changed)
	if EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
	if EventBus.quest_completed.is_connected(_on_quest_completed):
		EventBus.quest_completed.disconnect(_on_quest_completed)


func refresh() -> void:
	if _value:
		_value.text = str(InventorySystem.get_currency("weave_silk"))


func _on_currency_changed(_type: String, _amount: int) -> void:
	refresh()


func _on_enemy_defeated(_enemy_id: StringName, _position: Vector2) -> void:
	refresh()


func _on_quest_completed(_quest_id: StringName) -> void:
	refresh()
