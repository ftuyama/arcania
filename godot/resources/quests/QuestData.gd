class_name QuestData
extends Resource
## Quest definition. See docs/08-technical-architecture.md §12.


enum QuestType { MAIN, SIDE, FACTION, REGIONAL }

@export var id: StringName = &""
@export var title: String = ""
@export var description: String = ""
@export var quest_type: QuestType = QuestType.MAIN
@export var prerequisites: Array[StringName] = []
@export var objectives: Array[QuestObjective] = []
@export var rewards: QuestRewards
