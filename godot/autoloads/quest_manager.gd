extends Node
## Active and completed quest tracking.


const QUEST_PATHS: Array[String] = [
	"res://resources/quests/ashen_awakening.tres",
	"res://resources/quests/peddlers_price.tres",
]

var _registry: Dictionary = {}
var _active: Dictionary = {}
var _completed: Array[StringName] = []


func _ready() -> void:
	_build_quest_registry()
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.spell_acquired.connect(_on_spell_acquired)
	EventBus.ability_gate_cleared.connect(_on_ability_gate_cleared)
	EventBus.relic_acquired.connect(_on_relic_acquired)
	start_quest(&"ashen_awakening")


func _exit_tree() -> void:
	EventBus.room_entered.disconnect(_on_room_entered)
	EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
	EventBus.spell_acquired.disconnect(_on_spell_acquired)
	EventBus.ability_gate_cleared.disconnect(_on_ability_gate_cleared)
	EventBus.relic_acquired.disconnect(_on_relic_acquired)


func _build_quest_registry() -> void:
	_register_quest(_make_ashen_awakening())
	_register_quest(_make_peddlers_price())
	for path in QUEST_PATHS:
		if ResourceLoader.exists(path):
			var quest := load(path) as QuestData
			if quest:
				_register_quest(quest)


func _register_quest(quest: QuestData) -> void:
	if quest and not quest.id.is_empty():
		_registry[quest.id] = quest


func _make_ashen_awakening() -> QuestData:
	var quest := QuestData.new()
	quest.id = &"ashen_awakening"
	quest.title = "Ashen Awakening"
	quest.description = "Elara wakes in the Threshold. The Weave flickers."
	quest.quest_type = QuestData.QuestType.MAIN

	var obj_wake := QuestObjective.new()
	obj_wake.id = &"wake"
	obj_wake.description = "Awaken in the Ashen Threshold"
	obj_wake.objective_type = QuestObjective.ObjectiveType.REACH_LOCATION
	obj_wake.target_id = &"at_01_threshold_hub"

	var obj_veil := QuestObjective.new()
	obj_veil.id = &"learn_veil_step"
	obj_veil.description = "Learn Veil Step on the East Road"
	obj_veil.objective_type = QuestObjective.ObjectiveType.ACQUIRE_SPELL
	obj_veil.target_id = &"veil_step"
	obj_veil.optional = true

	var obj_wood := QuestObjective.new()
	obj_wood.id = &"enter_wood"
	obj_wood.description = "Reach Whisperwood Forest Gate"
	obj_wood.objective_type = QuestObjective.ObjectiveType.REACH_LOCATION
	obj_wood.target_id = &"ww_01_forest_gate"

	quest.objectives = [obj_wake, obj_veil, obj_wood]

	var rewards := QuestRewards.new()
	rewards.weave_silk = 2
	rewards.world_flags = [&"quest_ashen_awakening_done"]
	quest.rewards = rewards
	return quest


func _make_peddlers_price() -> QuestData:
	var quest := QuestData.new()
	quest.id = &"peddlers_price"
	quest.title = "Peddler's Price"
	quest.description = "Peddler Ash wants Memory Fragments from the Hollow."
	quest.quest_type = QuestData.QuestType.SIDE
	quest.prerequisites = [&"ashen_awakening"]

	var obj_path := QuestObjective.new()
	obj_path.id = &"reach_path"
	obj_path.description = "Explore Whisperwood Whisper Path"
	obj_path.objective_type = QuestObjective.ObjectiveType.REACH_LOCATION
	obj_path.target_id = &"ww_02_whisper_path"

	var obj_hollow := QuestObjective.new()
	obj_hollow.id = &"defeat_hollow"
	obj_hollow.description = "Defeat Bramble Stalkers (2)"
	obj_hollow.objective_type = QuestObjective.ObjectiveType.DEFEAT_ENEMY
	obj_hollow.target_id = &"e_03_bramble_stalker"
	obj_hollow.required_count = 2

	var obj_spell := QuestObjective.new()
	obj_spell.id = &"acquire_rootbind"
	obj_spell.description = "Acquire Rootbind spell"
	obj_spell.objective_type = QuestObjective.ObjectiveType.ACQUIRE_SPELL
	obj_spell.target_id = &"rootbind"
	obj_spell.optional = true

	var obj_whisper := QuestObjective.new()
	obj_whisper.id = &"whisper_secret"
	obj_whisper.description = "Solve the Whisper Loop puzzle"
	obj_whisper.objective_type = QuestObjective.ObjectiveType.INTERACT_OBJECT
	obj_whisper.target_id = &"whisper_loop"
	obj_whisper.optional = true

	quest.objectives = [obj_path, obj_hollow, obj_spell, obj_whisper]

	var rewards := QuestRewards.new()
	rewards.weave_silk = 5
	rewards.ley_residue = 1
	rewards.world_flags = [&"quest_peddlers_price_done"]
	quest.rewards = rewards
	return quest


func start_quest(quest_id: StringName) -> bool:
	if quest_id in _completed or _active.has(quest_id):
		return false
	var quest := _registry.get(quest_id) as QuestData
	if quest == null:
		return false
	for prereq in quest.prerequisites:
		if prereq not in _completed:
			return false
	var progress: Dictionary = {}
	for obj in quest.objectives:
		progress[String(obj.id)] = 0
	_active[quest_id] = progress
	EventBus.quest_started.emit(quest_id)
	_check_auto_complete_on_start(quest_id, quest)
	return true


func get_active_quests() -> Array[StringName]:
	var ids: Array[StringName] = []
	for key in _active.keys():
		ids.append(key)
	return ids


func get_quest(quest_id: StringName) -> QuestData:
	return _registry.get(quest_id) as QuestData


func get_active_objective_text(quest_id: StringName) -> String:
	var quest := get_quest(quest_id)
	if quest == null or not _active.has(quest_id):
		return ""
	var progress: Dictionary = _active[quest_id]
	for obj in quest.objectives:
		var count := int(progress.get(String(obj.id), 0))
		if count < obj.required_count and not obj.optional:
			return obj.description
	for obj in quest.objectives:
		if obj.optional:
			var count := int(progress.get(String(obj.id), 0))
			if count < obj.required_count:
				return "%s (optional)" % obj.description
	return "Complete"


func is_quest_complete(quest_id: StringName) -> bool:
	return quest_id in _completed


func get_save_data() -> Dictionary:
	var active_data: Dictionary = {}
	for quest_id in _active.keys():
		active_data[String(quest_id)] = _active[quest_id].duplicate()
	var completed_str: Array[String] = []
	for id in _completed:
		completed_str.append(String(id))
	return {"active": active_data, "completed": completed_str}


func apply_save_data(data: Dictionary) -> void:
	_active.clear()
	_completed.clear()
	for quest_str in data.get("completed", []):
		_completed.append(StringName(quest_str))
	var active_data: Dictionary = data.get("active", {})
	for quest_str in active_data.keys():
		_active[StringName(quest_str)] = active_data[quest_str].duplicate()


func _check_auto_complete_on_start(quest_id: StringName, quest: QuestData) -> void:
	for obj in quest.objectives:
		_try_advance(quest_id, quest, obj, 1)


func _try_advance(quest_id: StringName, quest: QuestData, obj: QuestObjective, amount: int) -> void:
	if not _active.has(quest_id):
		return
	var progress: Dictionary = _active[quest_id]
	var key := String(obj.id)
	var current := int(progress.get(key, 0))
	if current >= obj.required_count:
		return
	progress[key] = mini(current + amount, obj.required_count)
	_active[quest_id] = progress
	EventBus.quest_updated.emit(quest_id, obj.id)
	if _is_quest_objectives_met(quest):
		_complete_quest(quest_id, quest)


func _is_quest_objectives_met(quest: QuestData) -> bool:
	if not _active.has(quest.id):
		return false
	var progress: Dictionary = _active[quest.id]
	for obj in quest.objectives:
		if obj.optional:
			continue
		if int(progress.get(String(obj.id), 0)) < obj.required_count:
			return false
	return true


func _complete_quest(quest_id: StringName, quest: QuestData) -> void:
	_active.erase(quest_id)
	_completed.append(quest_id)
	if quest.rewards:
		InventorySystem.add_currency("weave_silk", quest.rewards.weave_silk)
		InventorySystem.add_currency("ley_residue", quest.rewards.ley_residue)
		InventorySystem.add_currency("shard_dust", quest.rewards.shard_dust)
		for flag in quest.rewards.world_flags:
			GameManager.set_world_flag(flag)
		if not quest.rewards.spell_id.is_empty():
			SpellManager.acquire_spell(quest.rewards.spell_id)
		if not quest.rewards.relic_id.is_empty():
			InventorySystem.acquire_relic(quest.rewards.relic_id)
	EventBus.quest_completed.emit(quest_id)
	if quest_id == &"ashen_awakening":
		start_quest(&"peddlers_price")


func _on_room_entered(room_id: StringName, region_id: StringName) -> void:
	for quest_id in _active.keys():
		var quest := get_quest(quest_id)
		if quest == null:
			continue
		for obj in quest.objectives:
			match obj.objective_type:
				QuestObjective.ObjectiveType.REACH_LOCATION:
					if obj.target_id == room_id:
						_try_advance(quest_id, quest, obj, 1)
				QuestObjective.ObjectiveType.DISCOVER_ROOMS:
					if obj.target_id == region_id:
						_try_advance(quest_id, quest, obj, 1)


func _on_enemy_defeated(enemy_id: StringName, _position: Vector2) -> void:
	for quest_id in _active.keys():
		var quest := get_quest(quest_id)
		if quest == null:
			continue
		for obj in quest.objectives:
			if obj.objective_type == QuestObjective.ObjectiveType.DEFEAT_ENEMY:
				if obj.target_id == enemy_id:
					_try_advance(quest_id, quest, obj, 1)


func _on_spell_acquired(spell_id: StringName) -> void:
	for quest_id in _active.keys():
		var quest := get_quest(quest_id)
		if quest == null:
			continue
		for obj in quest.objectives:
			if obj.objective_type == QuestObjective.ObjectiveType.ACQUIRE_SPELL:
				if obj.target_id == spell_id:
					_try_advance(quest_id, quest, obj, 1)


func _on_ability_gate_cleared(gate_id: StringName) -> void:
	for quest_id in _active.keys():
		var quest := get_quest(quest_id)
		if quest == null:
			continue
		for obj in quest.objectives:
			if obj.objective_type == QuestObjective.ObjectiveType.CLEAR_ABILITY_GATE:
				if obj.target_id == gate_id:
					_try_advance(quest_id, quest, obj, 1)


func advance_objective(quest_id: StringName, objective_id: StringName, amount: int = 1) -> void:
	var quest := get_quest(quest_id)
	if quest == null:
		return
	for obj in quest.objectives:
		if obj.id == objective_id:
			_try_advance(quest_id, quest, obj, amount)
			return


func _on_relic_acquired(relic_id: StringName) -> void:
	for quest_id in _active.keys():
		var quest := get_quest(quest_id)
		if quest == null:
			continue
		for obj in quest.objectives:
			if obj.objective_type == QuestObjective.ObjectiveType.ACQUIRE_RELIC:
				if obj.target_id == relic_id:
					_try_advance(quest_id, quest, obj, 1)


func reset_to_defaults() -> void:
	_active.clear()
	_completed.clear()
	start_quest(&"ashen_awakening")
