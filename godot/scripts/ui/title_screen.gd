extends Control
## Title screen — new game, continue, load, quit.


const GAME_WORLD_SCENE := "res://scenes/world/game_world.tscn"
const TITLE_STINGER := "res://assets/audio/music/mus_stinger_main_menu.wav"

const COLOR_GOLD := Color(0.92, 0.78, 0.55, 1.0)
const COLOR_TEXT := Color(0.88, 0.84, 0.76, 1.0)
const COLOR_DISABLED := Color(0.55, 0.50, 0.44, 1.0)

const BORDER_WIDTH := 1
const BORDER_WIDTH_FOCUS := 2
const PANEL_BORDER_WIDTH := 1
const BUTTON_FONT_SIZE := 12

@onready var safe_area: MarginContainer = $SafeArea
@onready var menu_panel: VBoxContainer = $SafeArea/MainLayout/MenuCenter/MenuPanel
@onready var load_panel: PanelContainer = $LoadPanel
@onready var new_game_button: Button = $SafeArea/MainLayout/MenuCenter/MenuPanel/NewGameButton
@onready var continue_button: Button = $SafeArea/MainLayout/MenuCenter/MenuPanel/ContinueButton
@onready var load_button: Button = $SafeArea/MainLayout/MenuCenter/MenuPanel/LoadButton
@onready var quit_button: Button = $SafeArea/MainLayout/MenuCenter/MenuPanel/QuitButton
@onready var slot_list: ItemList = $LoadPanel/Margin/VBox/SlotList
@onready var load_status: Label = $LoadPanel/Margin/VBox/LoadStatus
@onready var prompt_label: Label = $SafeArea/MainLayout/PromptLabel

var _starting: bool = false


func _ready() -> void:
	GameManager.state = GameManager.GameState.TITLE
	AudioManager.play_ui(TITLE_STINGER)
	AudioManager.play_region(&"ashen_threshold")
	_style_buttons()
	_style_load_panel()
	_style_slot_list()
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	load_button.pressed.connect(_on_load_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	$LoadPanel/Margin/VBox/LoadConfirmButton.pressed.connect(_on_load_confirm_pressed)
	$LoadPanel/Margin/VBox/LoadBackButton.pressed.connect(_on_load_back_pressed)
	_apply_button_theme($LoadPanel/Margin/VBox/LoadConfirmButton)
	_apply_button_theme($LoadPanel/Margin/VBox/LoadBackButton)
	_populate_save_slots()
	_refresh_continue_button()
	load_panel.visible = false
	UiSfx.wire_tree(self)
	new_game_button.grab_focus()
	_start_prompt_pulse()


func _style_buttons() -> void:
	for btn in [new_game_button, continue_button, load_button, quit_button]:
		_apply_button_theme(btn)


func _style_load_panel() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.08, 0.08, 0.11, 0.96)
	panel.border_color = Color(0.72, 0.48, 0.18, 0.65)
	panel.set_border_width_all(PANEL_BORDER_WIDTH)
	panel.set_corner_radius_all(3)
	panel.content_margin_left = 8
	panel.content_margin_top = 8
	panel.content_margin_right = 8
	panel.content_margin_bottom = 8
	load_panel.add_theme_stylebox_override(&"panel", panel)


func _style_slot_list() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.06, 0.06, 0.09, 0.95)
	panel.border_color = Color(0.55, 0.38, 0.14, 0.55)
	panel.set_border_width_all(BORDER_WIDTH)
	panel.set_corner_radius_all(2)
	panel.content_margin_left = 4
	panel.content_margin_top = 4
	panel.content_margin_right = 4
	panel.content_margin_bottom = 4
	slot_list.add_theme_stylebox_override(&"panel", panel)


func _apply_button_theme(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.11, 0.10, 0.14, 0.94)
	normal.border_color = Color(0.55, 0.38, 0.14, 0.75)
	normal.set_border_width_all(BORDER_WIDTH)
	normal.set_corner_radius_all(2)
	normal.content_margin_top = 4
	normal.content_margin_bottom = 4
	normal.content_margin_left = 6
	normal.content_margin_right = 6
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_font_size_override(&"font_size", BUTTON_FONT_SIZE)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.18, 0.14, 0.10, 0.96)
	hover.border_color = Color(0.85, 0.65, 0.28, 0.95)
	hover.set_border_width_all(BORDER_WIDTH)
	btn.add_theme_stylebox_override(&"hover", hover)

	var pressed := hover.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.24, 0.18, 0.10, 1.0)
	pressed.set_border_width_all(BORDER_WIDTH)
	btn.add_theme_stylebox_override(&"pressed", pressed)

	var focus := hover.duplicate() as StyleBoxFlat
	focus.border_color = Color(0.95, 0.78, 0.35, 1.0)
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


func _unhandled_input(event: InputEvent) -> void:
	if _starting or load_panel.visible:
		return
	if event.is_action_pressed(&"jump") or event.is_action_pressed(&"interact"):
		var viewport := get_viewport()
		if viewport:
			viewport.set_input_as_handled()
		_on_new_game_pressed()


func _refresh_continue_button() -> void:
	var latest := SaveManager.get_latest_save_slot()
	continue_button.disabled = latest.is_empty()
	if latest.is_empty():
		continue_button.text = "Continue (no save)"
	else:
		var summary := SaveManager.get_save_summary(latest)
		var room: String = summary.get("room_id", "")
		continue_button.text = "Continue — %s" % room if not room.is_empty() else "Continue"


func _populate_save_slots() -> void:
	slot_list.clear()
	for i in 3:
		var slot_id := "slot_%d" % (i + 1)
		if SaveManager.has_save(slot_id):
			var summary := SaveManager.get_save_summary(slot_id)
			var label := "Slot %d — %s" % [i + 1, summary.get("room_id", "saved")]
			slot_list.add_item(label)
		else:
			slot_list.add_item("Slot %d — Empty" % (i + 1))
		slot_list.set_item_metadata(slot_list.item_count - 1, slot_id)


func _on_new_game_pressed() -> void:
	if _starting:
		return
	_starting = true
	SaveManager.start_new_game()
	_enter_game_world()


func _on_continue_pressed() -> void:
	if _starting or continue_button.disabled:
		return
	var slot_id := SaveManager.get_latest_save_slot()
	if slot_id.is_empty():
		return
	_starting = true
	if not SaveManager.load_game(slot_id):
		_starting = false
		return
	_enter_game_world()


func _on_load_menu_pressed() -> void:
	safe_area.visible = false
	load_panel.visible = true
	load_status.text = "Select a save slot"
	_populate_save_slots()
	if slot_list.item_count > 0:
		slot_list.select(0)


func _on_load_confirm_pressed() -> void:
	var selected := slot_list.get_selected_items()
	if selected.is_empty():
		load_status.text = "Select a slot first"
		return
	var slot_id: String = slot_list.get_item_metadata(selected[0])
	if not SaveManager.has_save(slot_id):
		load_status.text = "Slot is empty"
		return
	_starting = true
	if SaveManager.load_game(slot_id):
		_enter_game_world()
	else:
		_starting = false
		load_status.text = "Load failed"


func _on_load_back_pressed() -> void:
	load_panel.visible = false
	safe_area.visible = true
	new_game_button.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _enter_game_world() -> void:
	GameManager.state = GameManager.GameState.LOADING
	AudioManager.enter_gameplay()
	get_tree().change_scene_to_file(GAME_WORLD_SCENE)


func _start_prompt_pulse() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(prompt_label, "modulate:a", 0.4, 1.0)
	tween.tween_property(prompt_label, "modulate:a", 1.0, 1.0)
