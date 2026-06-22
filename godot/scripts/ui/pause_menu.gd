extends Control
## Pause menu with save/load slots.


@onready var slot_list: ItemList = $Panel/Margin/VBox/SlotList
@onready var status_label: Label = $Panel/Margin/VBox/StatusLabel


func _ready() -> void:
	visible = false
	$Panel/Margin/VBox/SaveButton.pressed.connect(_on_save_pressed)
	$Panel/Margin/VBox/LoadButton.pressed.connect(_on_load_pressed)
	$Panel/Margin/VBox/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/Margin/VBox/QuestButton.pressed.connect(_on_quest_pressed)
	_populate_slots()


func _populate_slots() -> void:
	slot_list.clear()
	for i in 3:
		slot_list.add_item("Slot %d" % (i + 1))
		slot_list.set_item_metadata(slot_list.item_count - 1, "slot_%d" % (i + 1))


func _on_save_pressed() -> void:
	var selected := slot_list.get_selected_items()
	if selected.is_empty():
		status_label.text = "Select a slot first"
		return
	var slot_id: String = slot_list.get_item_metadata(selected[0])
	if SaveManager.save_game(slot_id):
		status_label.text = "Saved to %s" % slot_id
	else:
		status_label.text = "Save failed"


func _on_load_pressed() -> void:
	var selected := slot_list.get_selected_items()
	if selected.is_empty():
		status_label.text = "Select a slot first"
		return
	var slot_id: String = slot_list.get_item_metadata(selected[0])
	get_tree().paused = false
	if SaveManager.load_game(slot_id):
		status_label.text = "Loaded %s" % slot_id
		visible = false
		GameManager.state = GameManager.GameState.PLAYING
		EventBus.game_resumed.emit()
	else:
		status_label.text = "No save in %s" % slot_id
		get_tree().paused = true


func _on_resume_pressed() -> void:
	var ui := get_parent()
	if ui.has_method(&"_close_pause"):
		ui._close_pause()


func _on_quest_pressed() -> void:
	var quest_log: Control = get_parent().get_node_or_null("QuestLog")
	if quest_log:
		visible = false
		get_tree().paused = false
		quest_log.visible = true
		if quest_log.has_method(&"refresh"):
			quest_log.refresh()
