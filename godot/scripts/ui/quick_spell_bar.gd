extends HBoxContainer
## Persistent quick-spell slots 1–4 with ornate frames, cooldown overlays, key labels.


const SLOT_SIZE := 42

var _slots: Array[Dictionary] = []
var _active_index: int = 0
var _name_label: Label
var _name_tween: Tween
var _inactive_tex: Texture2D
var _active_tex: Texture2D


func _ready() -> void:
	add_theme_constant_override(&"separation", 6)
	alignment = BoxContainer.ALIGNMENT_BEGIN
	_inactive_tex = HudStyle.get_hud_texture(&"spell_slot")
	_active_tex = HudStyle.get_hud_texture(&"spell_slot_active")
	_build_slots()
	_name_label = get_node_or_null("../SpellNameFade") as Label
	if _name_label:
		HudStyle.apply_hud_font(_name_label, 12)
		_name_label.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
	EventBus.spell_acquired.connect(_on_spell_acquired)
	EventBus.spell_cast.connect(_on_spell_cast)
	refresh()


func _exit_tree() -> void:
	if EventBus.spell_acquired.is_connected(_on_spell_acquired):
		EventBus.spell_acquired.disconnect(_on_spell_acquired)
	if EventBus.spell_cast.is_connected(_on_spell_cast):
		EventBus.spell_cast.disconnect(_on_spell_cast)


func _process(_delta: float) -> void:
	_update_cooldowns()
	_poll_active_slot()


func refresh() -> void:
	for i in SpellManager.QUICK_SLOT_COUNT:
		var spell_id := SpellManager.get_quick_slot(i)
		var spell := SpellManager.get_spell(spell_id)
		var icon: TextureRect = _slots[i]["icon"]
		if spell and spell.icon:
			icon.texture = spell.icon
			icon.modulate = Color.WHITE
		else:
			icon.texture = null
			icon.modulate = Color(1, 1, 1, 0.25)
		_set_slot_active(i, i == _active_index)


func show_spell_name(spell_id: StringName) -> void:
	var spell := SpellManager.get_spell(spell_id)
	if spell == null or _name_label == null:
		return
	_name_label.text = spell.display_name
	_name_label.visible = true
	_name_label.modulate.a = 1.0
	if _name_tween and _name_tween.is_valid():
		_name_tween.kill()
	_name_tween = create_tween()
	_name_tween.tween_interval(1.2)
	_name_tween.tween_property(_name_label, "modulate:a", 0.0, 0.35)
	_name_tween.tween_callback(func() -> void:
		if is_instance_valid(_name_label):
			_name_label.visible = false
	)


func _build_slots() -> void:
	for i in SpellManager.QUICK_SLOT_COUNT:
		var column := VBoxContainer.new()
		column.add_theme_constant_override(&"separation", 2)
		column.alignment = BoxContainer.ALIGNMENT_CENTER

		var stack := Control.new()
		stack.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		column.add_child(stack)

		var frame_node: Control
		var uses_texture := _inactive_tex != null
		if uses_texture:
			var frame := TextureRect.new()
			frame.name = "Frame"
			frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			frame.stretch_mode = TextureRect.STRETCH_SCALE
			frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
			frame.texture = _inactive_tex
			stack.add_child(frame)
			frame_node = frame
		else:
			var panel := PanelContainer.new()
			panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			panel.add_theme_stylebox_override(&"panel", HudStyle.make_slot_style(false))
			stack.add_child(panel)
			frame_node = panel

		var icon := TextureRect.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 6
		icon.offset_top = 6
		icon.offset_right = -6
		icon.offset_bottom = -6
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_child(icon)

		var cd_overlay := ColorRect.new()
		cd_overlay.name = "CooldownOverlay"
		cd_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cd_overlay.offset_left = 4
		cd_overlay.offset_top = 4
		cd_overlay.offset_right = -4
		cd_overlay.offset_bottom = -4
		cd_overlay.color = Color(0.05, 0.05, 0.1, 0.0)
		cd_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_child(cd_overlay)

		var key := Label.new()
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.text = _key_label_for_slot(i)
		HudStyle.apply_hud_font(key, 9)
		key.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
		key.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(key)

		add_child(column)
		_slots.append({
			"frame": frame_node,
			"icon": icon,
			"overlay": cd_overlay,
			"key": key,
			"uses_texture": uses_texture,
		})


func _key_label_for_slot(index: int) -> String:
	var action := &"quick_spell_%d" % (index + 1)
	var events := InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			var key_event := event as InputEventKey
			var code := key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
			return "[%s]" % OS.get_keycode_string(code)
	return "[%d]" % (index + 1)


func _set_slot_active(index: int, active: bool) -> void:
	var entry: Dictionary = _slots[index]
	if entry["uses_texture"]:
		var frame: TextureRect = entry["frame"]
		frame.texture = _active_tex if active and _active_tex else _inactive_tex
		frame.modulate = Color(0.65, 1.0, 1.0, 1.0) if active else Color.WHITE
	else:
		var frame: PanelContainer = entry["frame"]
		frame.add_theme_stylebox_override(&"panel", HudStyle.make_slot_style(active))


func _poll_active_slot() -> void:
	for i in SpellManager.QUICK_SLOT_COUNT:
		var action := &"quick_spell_%d" % (i + 1)
		if Input.is_action_just_pressed(action):
			_active_index = i
			refresh()
			var spell_id := SpellManager.get_quick_slot(i)
			if not spell_id.is_empty():
				show_spell_name(spell_id)
			return
	if Input.is_action_just_pressed(&"cast_spell"):
		_active_index = 0
		refresh()


func _update_cooldowns() -> void:
	for i in _slots.size():
		var spell_id := SpellManager.get_quick_slot(i)
		var overlay: ColorRect = _slots[i]["overlay"]
		if spell_id.is_empty():
			overlay.color.a = 0.0
			continue
		var remaining := SpellManager.get_cooldown_remaining(spell_id)
		var total := SpellManager.get_effective_cooldown(spell_id)
		if remaining <= 0.0 or total <= 0.0:
			overlay.color.a = 0.0
		else:
			overlay.color.a = 0.55 * (remaining / total)


func _on_spell_acquired(_spell_id: StringName) -> void:
	refresh()


func _on_spell_cast(spell_id: StringName, _caster: Node2D) -> void:
	for i in SpellManager.QUICK_SLOT_COUNT:
		if SpellManager.get_quick_slot(i) == spell_id:
			_active_index = i
			refresh()
			show_spell_name(spell_id)
			break
