class_name QuestObjective
extends Resource
## Single quest objective step.


enum ObjectiveType {
	REACH_LOCATION,
	TALK_TO_NPC,
	DEFEAT_ENEMY,
	DEFEAT_BOSS,
	ACQUIRE_SPELL,
	ACQUIRE_RELIC,
	COLLECT_ITEM,
	CLEAR_ABILITY_GATE,
	INTERACT_OBJECT,
	DISCOVER_ROOMS,
}

@export var id: StringName = &""
@export var description: String = ""
@export var objective_type: ObjectiveType = ObjectiveType.REACH_LOCATION
@export var target_id: StringName = &""
@export var required_count: int = 1
@export var optional: bool = false
