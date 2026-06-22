extends Node
## High-level game state, world flags, and save snapshots.


enum GameState { TITLE, LOADING, PLAYING, PAUSED, CUTSCENE, GAME_OVER }

var state: GameState = GameState.TITLE
var playtime_seconds: float = 0.0
var current_region_id: StringName = &""
var current_room_id: StringName = &""
var is_combat_active: bool = false

var _room_loader: Node = null
var _world_flags: Dictionary = {}
var _cleared_gates: Array[StringName] = []
var _collected_pickups: Array[StringName] = []
var _last_crucible_id: StringName = &""
var _pending_load: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.player_died.connect(_on_player_died)
	EventBus.ability_gate_cleared.connect(_on_gate_cleared)
	EventBus.boss_defeated.connect(_on_boss_defeated)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	if state in [GameState.CUTSCENE, GameState.GAME_OVER, GameState.TITLE, GameState.LOADING]:
		return
	toggle_pause()


func toggle_pause() -> void:
	if state == GameState.PLAYING:
		state = GameState.PAUSED
		get_tree().paused = true
		EventBus.game_paused.emit()
	elif state == GameState.PAUSED:
		state = GameState.PLAYING
		get_tree().paused = false
		EventBus.game_resumed.emit()


func _exit_tree() -> void:
	if EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.disconnect(_on_player_died)
	if EventBus.ability_gate_cleared.is_connected(_on_gate_cleared):
		EventBus.ability_gate_cleared.disconnect(_on_gate_cleared)
	if EventBus.boss_defeated.is_connected(_on_boss_defeated):
		EventBus.boss_defeated.disconnect(_on_boss_defeated)


func _process(delta: float) -> void:
	if state == GameState.PLAYING:
		playtime_seconds += delta


func reset_session() -> void:
	state = GameState.TITLE
	playtime_seconds = 0.0
	current_region_id = &""
	current_room_id = &""
	is_combat_active = false
	_world_flags.clear()
	_cleared_gates.clear()
	_collected_pickups.clear()
	_last_crucible_id = &""
	_pending_load = {}
	_room_loader = null


func register_room_loader(loader: Node) -> void:
	_room_loader = loader
	if not _pending_load.is_empty():
		_apply_pending_load()


func change_room(room_id: StringName, spawn_marker: StringName = &"") -> void:
	current_room_id = room_id
	if _room_loader and _room_loader.has_method(&"change_room"):
		_room_loader.change_room(room_id, spawn_marker)
	else:
		push_warning("GameManager.change_room called before RoomLoader registered: %s" % room_id)


func respawn_player() -> void:
	if _room_loader and _room_loader.has_method(&"respawn_current_room"):
		_room_loader.respawn_current_room()


func set_world_flag(flag: StringName, value: bool = true) -> void:
	_world_flags[String(flag)] = value


func has_world_flag(flag: StringName) -> bool:
	return bool(_world_flags.get(String(flag), false))


func is_boss_defeated(boss_id: StringName) -> bool:
	return has_world_flag(StringName("defeated_%s" % boss_id))


func is_gate_cleared(gate_id: StringName) -> bool:
	return gate_id in _cleared_gates


func get_world_value(key: StringName, default: Variant = null) -> Variant:
	return _world_flags.get(String(key), default)


func set_world_value(key: StringName, value: Variant) -> void:
	_world_flags[String(key)] = value


func set_last_crucible(crucible_id: StringName) -> void:
	_last_crucible_id = crucible_id


func mark_pickup_collected(pickup_id: StringName) -> void:
	if pickup_id not in _collected_pickups:
		_collected_pickups.append(pickup_id)


func is_pickup_collected(pickup_id: StringName) -> bool:
	return pickup_id in _collected_pickups


func _on_player_died() -> void:
	_enter_game_over()


func _enter_game_over() -> void:
	if state == GameState.GAME_OVER:
		return
	await get_tree().create_timer(1.2).timeout
	if state == GameState.GAME_OVER:
		return
	state = GameState.GAME_OVER
	get_tree().paused = true
	EventBus.game_over_started.emit()


func dismiss_game_over(should_respawn: bool = true) -> void:
	if state != GameState.GAME_OVER:
		return
	state = GameState.PLAYING
	get_tree().paused = false
	EventBus.game_over_ended.emit()
	if should_respawn:
		respawn_player()
	AudioManager.restore_region_music()


func _on_gate_cleared(gate_id: StringName) -> void:
	if gate_id not in _cleared_gates:
		_cleared_gates.append(gate_id)


func _on_boss_defeated(boss_id: StringName) -> void:
	set_world_flag(StringName("defeated_%s" % boss_id))


func get_player_snapshot() -> Dictionary:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return {}
	return {
		"room_id": String(current_room_id),
		"spawn_marker": "default",
		"x": player.global_position.x,
		"y": player.global_position.y,
		"hp_current": player.health_component.current_hp,
		"hp_max": player.health_component.max_hp,
		"mana_current": player.mana_component.current_mana,
		"mana_max": player.mana_component.max_mana,
		"essence": player.essence_collected,
		"facing": player.facing_direction,
	}


func get_world_flags() -> Dictionary:
	return {
		"flags": _world_flags.duplicate(),
		"cleared_gates": _cleared_gates.duplicate(),
		"collected_pickups": _collected_pickups.duplicate(),
		"last_crucible": String(_last_crucible_id),
	}


func get_settings_snapshot() -> Dictionary:
	return {
		"master_volume": 1.0,
		"music_volume": 1.0,
		"sfx_volume": 1.0,
	}


func apply_save_data(player_data: Dictionary, world_data: Dictionary) -> void:
	_world_flags = world_data.get("flags", {}).duplicate()
	_cleared_gates.assign(world_data.get("cleared_gates", []))
	_collected_pickups.assign(world_data.get("collected_pickups", []))
	_last_crucible_id = StringName(world_data.get("last_crucible", ""))
	playtime_seconds = float(player_data.get("playtime_seconds", playtime_seconds))

	var room_id := StringName(player_data.get("room_id", &"at_01_threshold_hub"))
	var spawn := StringName(player_data.get("spawn_marker", &"default"))
	_pending_load = {
		"room_id": room_id,
		"spawn_marker": spawn,
		"position": Vector2(
			float(player_data.get("x", 0.0)),
			float(player_data.get("y", 0.0))
		),
		"hp_current": int(player_data.get("hp_current", 100)),
		"hp_max": int(player_data.get("hp_max", 100)),
		"mana_current": float(player_data.get("mana_current", 100.0)),
		"mana_max": float(player_data.get("mana_max", 100.0)),
		"essence": int(player_data.get("essence", 0)),
		"facing": int(player_data.get("facing", 1)),
	}
	call_deferred(&"_apply_pending_load")


func _apply_pending_load() -> void:
	if _pending_load.is_empty() or _room_loader == null:
		return
	var data := _pending_load.duplicate()
	_pending_load = {}
	change_room(data["room_id"], data["spawn_marker"])
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return
	if data.has("position"):
		player.global_position = data["position"]
		player.set_respawn_position(data["position"])
	if data.has("hp_current"):
		player.health_component.max_hp = int(data.get("hp_max", player.health_component.max_hp))
		player.health_component.current_hp = int(data["hp_current"])
	if data.has("mana_current"):
		player.mana_component.max_mana = int(data.get("mana_max", player.mana_component.max_mana))
		player.mana_component.current_mana = float(data["mana_current"])
	if data.has("essence"):
		player.essence_collected = int(data["essence"])
	if data.has("facing"):
		player.facing_direction = int(data["facing"])
