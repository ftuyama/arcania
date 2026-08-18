extends Node
## Run as the main scene to verify Matron's permanent reward and inert defeat state.
## `./tools/godot.sh --headless --path godot res://tests/integration/test_matron_defeat.tscn`


func _ready() -> void:
	call_deferred(&"_run_test")


func _run_test() -> void:
	var tree_root := get_tree().root
	var game_manager := tree_root.get_node("GameManager")
	var spell_manager := tree_root.get_node("SpellManager")
	var audio_manager := tree_root.get_node("AudioManager")
	game_manager.reset_session()
	spell_manager.reset_to_defaults()

	var player_scene := load("res://scenes/player/player.tscn") as PackedScene
	var boss_scene := load("res://scenes/bosses/thornweft_matron.tscn") as PackedScene
	var player := player_scene.instantiate() as Player
	var boss := boss_scene.instantiate() as BaseBoss
	add_child(player)
	add_child(boss)
	await get_tree().process_frame
	await get_tree().process_frame

	var starting_max_hp := player.health_component.max_hp
	player.health_component.current_hp = 1
	boss.start_fight()
	boss.health_component.take_damage(boss.health_component.max_hp, player)
	await get_tree().process_frame
	await get_tree().process_frame

	var failures := 0
	failures += _expect(player.health_component.max_hp == starting_max_hp + 10, "Matron should grant +10 max HP")
	failures += _expect(player.health_component.current_hp == player.health_component.max_hp, "Matron should fully restore HP")
	failures += _expect(boss.velocity == Vector2.ZERO, "Defeated Matron should have zero velocity")
	failures += _expect(not boss.is_physics_processing(), "Defeated Matron should stop physics processing")
	failures += _expect(boss.animated_sprite.animation == &"dead", "Defeated Matron should show the dead sprite")
	failures += _expect(not boss.animated_sprite.is_playing(), "Dead sprite should be frozen")
	failures += _expect(not boss.hitbox_component.monitoring, "Defeated Matron hitbox should be disabled")
	failures += _expect(not boss.hurtbox_component.monitorable, "Defeated Matron hurtbox should be disabled")
	var body_collision := boss.get_node("CollisionShape2D") as CollisionShape2D
	failures += _expect(body_collision.disabled, "Defeated Matron body collision should be disabled")
	var snapshot: Dictionary = game_manager.get_player_snapshot()
	failures += _expect(int(snapshot.get("hp_max", 0)) == starting_max_hp + 10, "Save snapshot should include rewarded max HP")
	failures += _expect(audio_manager.get("_victory_stream") is AudioStreamWAV, "Matron defeat should create the victory sound")

	boss._on_boss_defeated()
	failures += _expect(player.health_component.max_hp == starting_max_hp + 10, "Matron reward should only be granted once")

	boss.free()
	player.free()
	if failures == 0:
		print("Matron defeat integration test passed.")
	get_tree().quit(0 if failures == 0 else 1)


func _expect(condition: bool, message: String) -> int:
	if condition:
		return 0
	push_error(message)
	return 1
