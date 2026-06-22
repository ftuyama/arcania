extends Node2D
## Loads and swaps room scenes; positions the player at spawn markers.


const ROOM_SCENES: Dictionary = {
	# Dev / Phase 2
	&"test_room_01": "res://scenes/rooms/dev/test_room_01.tscn",
	&"test_room_02": "res://scenes/rooms/dev/test_room_02.tscn",
	&"combat_test_arena": "res://scenes/rooms/dev/combat_test_arena.tscn",
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
	# Phase 5 — Whisperwood remainder
	&"ww_17_upper_canopy": "res://scenes/rooms/whisperwood_hollow/ww_17_upper_canopy.tscn",
	&"ww_18_moss_bridge": "res://scenes/rooms/whisperwood_hollow/ww_18_moss_bridge.tscn",
	&"ww_19_fungal_shelf": "res://scenes/rooms/whisperwood_hollow/ww_19_fungal_shelf.tscn",
	&"ww_20_root_archive": "res://scenes/rooms/whisperwood_hollow/ww_20_root_archive.tscn",
	&"ww_21_spore_vault": "res://scenes/rooms/whisperwood_hollow/ww_21_spore_vault.tscn",
	&"ww_22_bark_gallery": "res://scenes/rooms/whisperwood_hollow/ww_22_bark_gallery.tscn",
	&"ww_23_thorn_maze": "res://scenes/rooms/whisperwood_hollow/ww_23_thorn_maze.tscn",
	&"ww_24_heartwood_loft": "res://scenes/rooms/whisperwood_hollow/ww_24_heartwood_loft.tscn",
	&"ww_25_silk_chamber": "res://scenes/rooms/whisperwood_hollow/ww_25_silk_chamber.tscn",
	&"ww_26_canopy_edge": "res://scenes/rooms/whisperwood_hollow/ww_26_canopy_edge.tscn",
	&"ww_27_grove_rest": "res://scenes/rooms/whisperwood_hollow/ww_27_grove_rest.tscn",
	&"ww_28_vine_cathedral": "res://scenes/rooms/whisperwood_hollow/ww_28_vine_cathedral.tscn",
	&"ww_29_ironroot_overlook": "res://scenes/rooms/whisperwood_hollow/ww_29_ironroot_overlook.tscn",
	&"ww_30_cart_bypass": "res://scenes/rooms/whisperwood_hollow/ww_30_cart_bypass.tscn",
	&"ww_31_anchor_loft": "res://scenes/rooms/whisperwood_hollow/ww_31_anchor_loft.tscn",
	&"ww_32_matron_backtrail": "res://scenes/rooms/whisperwood_hollow/ww_32_matron_backtrail.tscn",
	&"ww_33_whisper_depths": "res://scenes/rooms/whisperwood_hollow/ww_33_whisper_depths.tscn",
	&"ww_34_spore_sink": "res://scenes/rooms/whisperwood_hollow/ww_34_spore_sink.tscn",
	&"ww_35_larva_nursery": "res://scenes/rooms/whisperwood_hollow/ww_35_larva_nursery.tscn",
	&"ww_36_hunter_roost": "res://scenes/rooms/whisperwood_hollow/ww_36_hunter_roost.tscn",
	&"ww_37_garden_remnant": "res://scenes/rooms/whisperwood_hollow/ww_37_garden_remnant.tscn",
	&"ww_s01_gardener_cache": "res://scenes/rooms/whisperwood_hollow/ww_s01_gardener_cache.tscn",
	&"ww_s02_whisper_loop": "res://scenes/rooms/whisperwood_hollow/ww_s02_whisper_loop.tscn",
	&"ww_s03_canopy_nest": "res://scenes/rooms/whisperwood_hollow/ww_s03_canopy_nest.tscn",
}

@onready var room_container: Node2D = $RoomContainer

var _player: Player
var _current_room: Node2D
var _current_room_id: StringName = &""
var _is_changing_room: bool = false


func _ready() -> void:
	_player = get_node_or_null("Player") as Player
	if _player == null:
		push_error("RoomLoader: Player node not found in game_world")
		return
	GameManager.register_room_loader(self)
	GameManager.state = GameManager.GameState.PLAYING
	change_room(&"at_01_threshold_hub", &"default")


func change_room(room_id: StringName, spawn_marker: StringName = &"default") -> void:
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
	GameManager.current_region_id = _current_room.region_id if _current_room is Room else &"dev"

	await get_tree().process_frame

	if _player and _current_room is Room:
		var room := _current_room as Room
		_player.global_position = room.get_spawn_position(spawn_marker)
		_player.set_respawn_position(room.get_spawn_position(&"default"))
		_apply_camera_limits(room)

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
	change_room(_current_room_id, &"default")
	if _player:
		_player.state_machine.transition_to(&"Idle", {})


func _apply_camera_limits(room: Room) -> void:
	if _player == null:
		return
	var limits := room.get_camera_limits()
	var camera := _player.camera
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.position.x + limits.size.x
	camera.limit_bottom = limits.position.y + limits.size.y
