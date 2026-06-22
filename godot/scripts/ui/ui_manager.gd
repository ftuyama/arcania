extends CanvasLayer
## Central UI input router for Phase 4 overlays.


@onready var inventory_panel: Control = $InventoryPanel
@onready var quest_log: Control = $QuestLog
@onready var map_overlay: Control = $MapOverlay
@onready var spell_wheel: Control = $SpellWheel
@onready var pause_menu: Control = $PauseMenu
@onready var game_over_screen: Control = $GameOverScreen
@onready var relic_toast: Control = $RelicToast

var _ui_open: bool = false


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_hide_all_overlays()
	EventBus.relic_acquired.connect(_on_relic_acquired)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	EventBus.game_over_started.connect(_on_game_over_started)


func _exit_tree() -> void:
	if EventBus.relic_acquired.is_connected(_on_relic_acquired):
		EventBus.relic_acquired.disconnect(_on_relic_acquired)
	if EventBus.game_paused.is_connected(_on_game_paused):
		EventBus.game_paused.disconnect(_on_game_paused)
	if EventBus.game_resumed.is_connected(_on_game_resumed):
		EventBus.game_resumed.disconnect(_on_game_resumed)
	if EventBus.game_over_started.is_connected(_on_game_over_started):
		EventBus.game_over_started.disconnect(_on_game_over_started)


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.state == GameManager.GameState.GAME_OVER:
		return
	if event.is_action_pressed(&"pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if GameManager.state == GameManager.GameState.PAUSED:
		return
	if event.is_action_pressed(&"inventory_toggle"):
		_toggle_panel(inventory_panel)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"map_toggle"):
		_toggle_panel(map_overlay)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"spell_wheel"):
		_toggle_panel(spell_wheel)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"interact") and map_overlay.visible:
		_try_place_map_marker()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	if pause_menu.visible:
		_close_pause()
	else:
		_open_pause()


func _open_pause() -> void:
	_hide_all_overlays()
	pause_menu.visible = true
	_ui_open = true
	GameManager.state = GameManager.GameState.PAUSED
	get_tree().paused = true
	EventBus.game_paused.emit()


func _close_pause() -> void:
	pause_menu.visible = false
	_ui_open = false
	GameManager.state = GameManager.GameState.PLAYING
	get_tree().paused = false
	EventBus.game_resumed.emit()


func _toggle_panel(panel: Control) -> void:
	if panel == pause_menu:
		return
	var was_visible := panel.visible
	_hide_all_overlays()
	if not was_visible:
		panel.visible = true
		_ui_open = true
		if panel.has_method(&"refresh"):
			panel.refresh()
	else:
		_ui_open = false


func _hide_all_overlays() -> void:
	inventory_panel.visible = false
	quest_log.visible = false
	map_overlay.visible = false
	spell_wheel.visible = false
	if not pause_menu.visible:
		_ui_open = false


func _try_place_map_marker() -> void:
	if GameManager.current_room_id.is_empty():
		return
	MapManager.place_marker(GameManager.current_region_id, GameManager.current_room_id)
	if map_overlay.has_method(&"refresh"):
		map_overlay.refresh()


func close_game_over(should_respawn: bool = true) -> void:
	if game_over_screen.has_method(&"dismiss"):
		game_over_screen.dismiss()
	GameManager.dismiss_game_over(should_respawn)


func _on_game_over_started() -> void:
	_hide_all_overlays()
	if game_over_screen.has_method(&"present"):
		game_over_screen.present()


func _on_relic_acquired(relic_id: StringName) -> void:
	if relic_toast.has_method(&"show_relic"):
		relic_toast.show_relic(relic_id)


func _on_game_paused() -> void:
	pass


func _on_game_resumed() -> void:
	pass
