extends Node2D
## Loads and swaps room scenes; positions the player at spawn markers.


const ROOM_SCENES: Dictionary = {
	# Phase 3 — Ashen Threshold
	&"at_01_threshold_hub": "res://scenes/rooms/ashen_threshold/at_01_threshold_hub.tscn",
	&"at_03_east_road": "res://scenes/rooms/ashen_threshold/at_03_east_road.tscn",
	# Phase 3 — Whisperwood Hollow
	&"ww_01_forest_gate": "res://scenes/rooms/whisperwood_hollow/ww_01_forest_gate.tscn",
	&"ww_02_whisper_path": "res://scenes/rooms/whisperwood_hollow/ww_02_whisper_path.tscn",
	&"ww_03_thorn_hollow": "res://scenes/rooms/whisperwood_hollow/ww_03_thorn_hollow.tscn",
	&"ww_04_branch_crossing": "res://scenes/rooms/whisperwood_hollow/ww_04_branch_crossing.tscn",
	&"ww_05_spore_glen": "res://scenes/rooms/whisperwood_hollow/ww_05_spore_glen.tscn",
	&"ww_06_root_pit": "res://scenes/rooms/whisperwood_hollow/ww_06_root_pit.tscn",
	&"ww_07_heartwood_chamber": "res://scenes/rooms/whisperwood_hollow/ww_07_heartwood_chamber.tscn",
	&"ww_08_vine_lift": "res://scenes/rooms/whisperwood_hollow/ww_08_vine_lift.tscn",
	&"ww_09_canopy_walk": "res://scenes/rooms/whisperwood_hollow/ww_09_canopy_walk.tscn",
	&"ww_10_matron_approach": "res://scenes/rooms/whisperwood_hollow/ww_10_matron_approach.tscn",
	&"ww_11_heartwood_grove": "res://scenes/rooms/whisperwood_hollow/ww_11_heartwood_grove.tscn",
	&"ww_12_ironroot_gate": "res://scenes/rooms/whisperwood_hollow/ww_12_ironroot_gate.tscn",
	&"ww_13_cart_tunnel": "res://scenes/rooms/whisperwood_hollow/ww_13_cart_tunnel.tscn",
	&"ww_14_anchor_tutorial": "res://scenes/rooms/whisperwood_hollow/ww_14_anchor_tutorial.tscn",
	&"ww_15_ironroot_depths": "res://scenes/rooms/whisperwood_hollow/ww_15_ironroot_depths.tscn",
	&"ww_16_post_warden": "res://scenes/rooms/whisperwood_hollow/ww_16_post_warden.tscn",
	# Phase 5 — Whisperwood secrets (optional; filler rooms ww_17–ww_37 deferred per docs/11-scoped-release.md)
	&"ww_s01_gardener_cache": "res://scenes/rooms/whisperwood_hollow/ww_s01_gardener_cache.tscn",
	&"ww_s02_whisper_loop": "res://scenes/rooms/whisperwood_hollow/ww_s02_whisper_loop.tscn",
	&"ww_s03_canopy_nest": "res://scenes/rooms/whisperwood_hollow/ww_s03_canopy_nest.tscn",
}

@onready var room_container: Node2D = $RoomContainer

var _player: Player
var _current_room: Node2D
var _current_room_id: StringName = &""
var _previous_region_id: StringName = &""
var _is_changing_room: bool = false


func _ready() -> void:
	_player = get_node_or_null("Player") as Player
	if _player == null:
		push_error("RoomLoader: Player node not found in game_world")
		return
	GameManager.register_room_loader(self)
	GameManager.state = GameManager.GameState.PLAYING
	change_room(&"at_01_threshold_hub", &"default")


func change_room(
	room_id: StringName,
	spawn_marker: StringName = &"default",
	spawn_position: Vector2 = Vector2.INF
) -> void:
	if _is_changing_room:
		return
	if not ROOM_SCENES.has(room_id):
		push_error("RoomLoader: unknown room_id %s" % room_id)
		return

	_is_changing_room = true

	if _current_room:
		_current_room.queue_free()
		_current_room = null

	var scene: PackedScene = load(ROOM_SCENES[room_id])
	if scene == null:
		push_error("RoomLoader: failed to load scene for %s at %s" % [room_id, ROOM_SCENES[room_id]])
		_is_changing_room = false
		return
	_current_room = scene.instantiate()
	room_container.add_child(_current_room)

	_current_room_id = room_id
	GameManager.current_room_id = room_id
	var new_region_id: StringName = (_current_room as Room).region_id if _current_room is Room else &"dev"
	GameManager.current_region_id = new_region_id
	if new_region_id != _previous_region_id:
		EventBus.region_entered.emit(new_region_id)
		_previous_region_id = new_region_id

	await get_tree().process_frame

	if _player and _current_room is Room:
		var room := _current_room as Room
		if spawn_position != Vector2.INF:
			_player.global_position = spawn_position
			_player.set_respawn_position(spawn_position)
		else:
			_player.global_position = room.get_spawn_position(spawn_marker)
			if not GameManager.has_bound_crucible():
				_player.set_respawn_position(room.get_spawn_position(&"default"))
		_apply_camera_limits(room)
		AudioManager.play_region(room.region_id)

	_is_changing_room = false


func respawn_current_room() -> void:
	if _current_room_id.is_empty():
		return
	if _player:
		_player.health_component.current_hp = _player.health_component.max_hp
		_player.mana_component.restore_full()
		if _player.animated_sprite:
			_player.animated_sprite.modulate = Color.WHITE
		_player.set_invulnerable(false)

	var target_room := _current_room_id
	var target_position := Vector2.INF
	if GameManager.has_bound_crucible():
		var respawn := GameManager.get_last_crucible_respawn()
		target_room = respawn.get("room_id", _current_room_id)
		target_position = respawn.get("position", Vector2.INF)

	change_room(target_room, &"default", target_position)
	if _player:
		_player.state_machine.transition_to(&"Idle", {})


func get_current_room() -> Node2D:
	return _current_room


func _apply_camera_limits(room: Room) -> void:
	if _player == null:
		return
	var limits := room.get_camera_limits()
	var camera := _player.camera
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.position.x + limits.size.x
	camera.limit_bottom = limits.position.y + limits.size.y
