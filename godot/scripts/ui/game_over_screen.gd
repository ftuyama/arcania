extends Control
## Game over screen — retry, load save, return to title.


const GAME_OVER_MUSIC := "res://assets/audio/music/mus_game_over.wav"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"

const COLOR_GOLD := Color(0.92, 0.78, 0.55, 1.0)
const COLOR_TEXT := Color(0.88, 0.84, 0.76, 1.0)
const COLOR_DISABLED := Color(0.55, 0.50, 0.44, 1.0)
const COLOR_ACCENT := Color(0.72, 0.42, 0.42, 0.75)

const BORDER_WIDTH := 1
const BORDER_WIDTH_FOCUS := 2
const PANEL_BORDER_WIDTH := 1
const BUTTON_FONT_SIZE := 12

@onready var panel: PanelContainer = $Panel
@onready var retry_button: Button = $Panel/Margin/VBox/RetryButton
@onready var load_button: Button = $Panel/Margin/VBox/LoadButton
@onready var title_button: Button = $Panel/Margin/VBox/TitleButton
@onready var status_label: Label = $Panel/Margin/VBox/StatusLabel


func _ready() -> void:
	visible = false
	_style_panel()
	_style_buttons()
	retry_button.pressed.connect(_on_retry_pressed)
	load_button.pressed.connect(_on_load_pressed)
	title_button.pressed.connect(_on_title_pressed)


func present() -> void:
	visible = true
	status_label.text = ""
	_refresh_load_button()
	retry_button.grab_focus()
	AudioManager.play_music(GAME_OVER_MUSIC)


func dismiss() -> void:
	visible = false


func _style_panel() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.08, 0.07, 0.09, 0.96)
	box.border_color = COLOR_ACCENT
	box.set_border_width_all(PANEL_BORDER_WIDTH)
	box.set_corner_radius_all(3)
	box.content_margin_left = 8
	box.content_margin_top = 8
	box.content_margin_right = 8
	box.content_margin_bottom = 8
	panel.add_theme_stylebox_override(&"panel", box)


func _style_buttons() -> void:
	for btn in [retry_button, load_button, title_button]:
		_apply_button_theme(btn)


func _apply_button_theme(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.11, 0.10, 0.14, 0.94)
	normal.border_color = Color(0.55, 0.32, 0.32, 0.75)
	normal.set_border_width_all(BORDER_WIDTH)
	normal.set_corner_radius_all(2)
	normal.content_margin_top = 4
	normal.content_margin_bottom = 4
	normal.content_margin_left = 6
	normal.content_margin_right = 6
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_font_size_override(&"font_size", BUTTON_FONT_SIZE)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.18, 0.12, 0.12, 0.96)
	hover.border_color = Color(0.85, 0.55, 0.45, 0.95)
	hover.set_border_width_all(BORDER_WIDTH)
	btn.add_theme_stylebox_override(&"hover", hover)

	var pressed := hover.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.24, 0.14, 0.12, 1.0)
	pressed.set_border_width_all(BORDER_WIDTH)
	btn.add_theme_stylebox_override(&"pressed", pressed)

	var focus := hover.duplicate() as StyleBoxFlat
	focus.border_color = Color(0.95, 0.65, 0.45, 1.0)
	focus.set_border_width_all(BORDER_WIDTH_FOCUS)
	btn.add_theme_stylebox_override(&"focus", focus)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.07, 0.07, 0.09, 0.6)
	disabled.border_color = Color(0.35, 0.32, 0.28, 0.5)
	disabled.set_border_width_all(BORDER_WIDTH)
	btn.add_theme_stylebox_override(&"disabled", disabled)

	btn.add_theme_color_override(&"font_color", COLOR_TEXT)
	btn.add_theme_color_override(&"font_hover_color", COLOR_GOLD)
	btn.add_theme_color_override(&"font_pressed_color", COLOR_GOLD)
	btn.add_theme_color_override(&"font_focus_color", COLOR_GOLD)
	btn.add_theme_color_override(&"font_disabled_color", COLOR_DISABLED)


func _refresh_load_button() -> void:
	var latest := SaveManager.get_latest_save_slot()
	load_button.disabled = latest.is_empty()
	if latest.is_empty():
		load_button.text = "Load Save (none)"
	else:
		var summary := SaveManager.get_save_summary(latest)
		var room: String = summary.get("room_id", "")
		load_button.text = "Load Save — %s" % room if not room.is_empty() else "Load Save"


func _on_retry_pressed() -> void:
	var ui := get_parent()
	if ui.has_method(&"close_game_over"):
		ui.close_game_over(true)


func _on_load_pressed() -> void:
	var latest := SaveManager.get_latest_save_slot()
	if latest.is_empty():
		status_label.text = "No save found"
		return
	get_tree().paused = false
	if SaveManager.load_game(latest):
		var ui := get_parent()
		if ui.has_method(&"close_game_over"):
			ui.close_game_over(false)
	else:
		status_label.text = "Load failed"
		get_tree().paused = true


func _on_title_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_session()
	get_tree().change_scene_to_file(TITLE_SCENE)
