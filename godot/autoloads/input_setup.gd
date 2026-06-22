extends Node
## Registers gamepad bindings at runtime (Steam-ready defaults).


const JOY_DEADZONE := 0.2

const ACTION_JOY_BUTTONS: Dictionary = {
	&"jump": JOY_BUTTON_A,
	&"melee_attack": JOY_BUTTON_X,
	&"cast_spell": JOY_BUTTON_Y,
	&"dash": JOY_BUTTON_B,
	&"interact": JOY_BUTTON_A,
	&"spell_wheel": JOY_BUTTON_LEFT_SHOULDER,
	&"quick_spell_1": JOY_BUTTON_DPAD_UP,
	&"quick_spell_2": JOY_BUTTON_DPAD_RIGHT,
	&"quick_spell_3": JOY_BUTTON_DPAD_DOWN,
	&"quick_spell_4": JOY_BUTTON_DPAD_LEFT,
	&"map_toggle": JOY_BUTTON_BACK,
	&"inventory_toggle": JOY_BUTTON_START,
	&"pause": JOY_BUTTON_START,
}

const ACTION_JOY_AXES: Dictionary = {
	&"move_left": {"axis": JOY_AXIS_LEFT_X, "value": -1.0},
	&"move_right": {"axis": JOY_AXIS_LEFT_X, "value": 1.0},
	&"move_up": {"axis": JOY_AXIS_LEFT_Y, "value": -1.0},
	&"move_down": {"axis": JOY_AXIS_LEFT_Y, "value": 1.0},
	&"aim_left": {"axis": JOY_AXIS_RIGHT_X, "value": -1.0},
	&"aim_right": {"axis": JOY_AXIS_RIGHT_X, "value": 1.0},
	&"aim_up": {"axis": JOY_AXIS_RIGHT_Y, "value": -1.0},
	&"aim_down": {"axis": JOY_AXIS_RIGHT_Y, "value": 1.0},
}


func _ready() -> void:
	_register_gamepad_bindings()


func _register_gamepad_bindings() -> void:
	for action: StringName in ACTION_JOY_BUTTONS:
		if not InputMap.has_action(action):
			continue
		var button: JoyButton = ACTION_JOY_BUTTONS[action]
		if _has_joy_button(action, button):
			continue
		var event := InputEventJoypadButton.new()
		event.button_index = button
		InputMap.action_add_event(action, event)

	for action: StringName in ACTION_JOY_AXES:
		if not InputMap.has_action(action):
			continue
		var axis_info: Dictionary = ACTION_JOY_AXES[action]
		var axis: JoyAxis = axis_info["axis"]
		var axis_value: float = axis_info["value"]
		if _has_joy_axis(action, axis, axis_value):
			continue
		var event := InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = axis_value
		InputMap.action_add_event(action, event)


func _has_joy_button(action: StringName, button: JoyButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button:
			return true
	return false


func _has_joy_axis(action: StringName, axis: JoyAxis, axis_value: float) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion and event.axis == axis:
			if signf(event.axis_value) == signf(axis_value):
				return true
	return false
