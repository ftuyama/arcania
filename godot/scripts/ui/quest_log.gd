extends Control
## Minimal quest log showing active objectives.


@onready var quest_list: ItemList = $Panel/Margin/VBox/QuestList
@onready var objective_label: Label = $Panel/Margin/VBox/ObjectiveLabel


func _ready() -> void:
	visible = false
	quest_list.item_selected.connect(_on_item_selected)
	EventBus.quest_started.connect(_on_quest_changed)
	EventBus.quest_updated.connect(_on_quest_changed)
	EventBus.quest_completed.connect(_on_quest_changed)


func _exit_tree() -> void:
	if EventBus.quest_started.is_connected(_on_quest_changed):
		EventBus.quest_started.disconnect(_on_quest_changed)
	if EventBus.quest_updated.is_connected(_on_quest_changed):
		EventBus.quest_updated.disconnect(_on_quest_changed)
	if EventBus.quest_completed.is_connected(_on_quest_changed):
		EventBus.quest_completed.disconnect(_on_quest_changed)


func refresh() -> void:
	quest_list.clear()
	for quest_id in QuestManager.get_active_quests():
		var quest := QuestManager.get_quest(quest_id)
		if quest:
			quest_list.add_item(quest.title)
			quest_list.set_item_metadata(quest_list.item_count - 1, quest_id)
	if quest_list.item_count > 0:
		quest_list.select(0)
		_update_objective(0)
	else:
		objective_label.text = "No active quests"


func _on_quest_changed(_a = null, _b = null) -> void:
	if visible:
		refresh()


func _on_item_selected(index: int) -> void:
	_update_objective(index)


func _update_objective(index: int) -> void:
	var quest_id: StringName = quest_list.get_item_metadata(index)
	objective_label.text = QuestManager.get_active_objective_text(quest_id)
