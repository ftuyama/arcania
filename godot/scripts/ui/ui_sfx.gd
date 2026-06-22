class_name UiSfx
## Wires menu confirm/select SFX to Button nodes via AudioManager.play_ui.

const CONFIRM := "res://assets/audio/sfx/ui/ui_menu_confirm.wav"
const SELECT := "res://assets/audio/sfx/ui/ui_menu_select.wav"

const _WIRED_META := &"ui_sfx_wired"


static func wire_button(button: Button) -> void:
	if button == null or button.get_meta(_WIRED_META, false):
		return
	button.set_meta(_WIRED_META, true)
	button.focus_entered.connect(_play_select)
	button.pressed.connect(_play_confirm)


static func wire_tree(root: Node) -> void:
	if root == null:
		return
	for node in root.find_children("*", "Button", true, false):
		wire_button(node as Button)


static func _play_select() -> void:
	AudioManager.play_ui(SELECT)


static func _play_confirm() -> void:
	AudioManager.play_ui(CONFIRM)
