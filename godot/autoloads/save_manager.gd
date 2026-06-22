extends Node
## JSON save/load orchestration. See docs/08-technical-architecture.md §10.

const SAVE_VERSION := 1
const SAVE_DIR := "user://saves/"

var current_slot: String = ""


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func save_game(slot_id: String) -> bool:
	var data := _build_save_data()
	var path := SAVE_DIR + slot_id + ".json"
	var json := JSON.stringify(data, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open %s" % path)
		return false
	file.store_string(json)
	file.close()
	current_slot = slot_id
	EventBus.save_requested.emit(slot_id)
	return true


func load_game(slot_id: String) -> bool:
	var path := SAVE_DIR + slot_id + ".json"
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		push_error("SaveManager: invalid JSON in %s" % path)
		return false
	_apply_save_data(parsed)
	current_slot = slot_id
	EventBus.game_loaded.emit(slot_id)
	return true


func _build_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"playtime_seconds": GameManager.playtime_seconds,
		"player": GameManager.get_player_snapshot(),
		"spells": SpellManager.get_save_data(),
		"inventory": InventorySystem.get_save_data(),
		"world": GameManager.get_world_flags(),
		"quests": QuestManager.get_save_data(),
		"map": MapManager.get_save_data(),
		"settings": GameManager.get_settings_snapshot(),
	}


func has_save(slot_id: String) -> bool:
	return FileAccess.file_exists(SAVE_DIR + slot_id + ".json")


func get_save_slot_ids() -> Array[String]:
	var slots: Array[String] = []
	for i in 3:
		var slot_id := "slot_%d" % (i + 1)
		if has_save(slot_id):
			slots.append(slot_id)
	return slots


func get_latest_save_slot() -> String:
	var latest_slot := ""
	var latest_time := ""
	for slot_id in get_save_slot_ids():
		var path := SAVE_DIR + slot_id + ".json"
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			var timestamp: String = parsed.get("timestamp", "")
			if timestamp > latest_time:
				latest_time = timestamp
				latest_slot = slot_id
	return latest_slot


func get_save_summary(slot_id: String) -> Dictionary:
	var path := SAVE_DIR + slot_id + ".json"
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		return {
			"timestamp": parsed.get("timestamp", ""),
			"playtime_seconds": parsed.get("playtime_seconds", 0.0),
			"room_id": parsed.get("player", {}).get("room_id", ""),
		}
	return {}


func start_new_game() -> void:
	current_slot = ""
	GameManager.reset_session()
	SpellManager.reset_to_defaults()
	InventorySystem.reset_to_defaults()
	QuestManager.reset_to_defaults()
	MapManager.reset_to_defaults()


func _apply_save_data(data: Dictionary) -> void:
	if data.get("version", 0) != SAVE_VERSION:
		push_warning("SaveManager: version mismatch")
	GameManager.playtime_seconds = float(data.get("playtime_seconds", 0.0))
	GameManager.apply_save_data(data.get("player", {}), data.get("world", {}))
	SpellManager.apply_save_data(data.get("spells", {}))
	InventorySystem.apply_save_data(data.get("inventory", {}))
	QuestManager.apply_save_data(data.get("quests", {}))
	MapManager.apply_save_data(data.get("map", {}))
