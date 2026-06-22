extends State
## Move — horizontal locomotion on ground.


func enter(_payload: Dictionary) -> void:
	_get_player().play_animation(&"walk")


func physics_update(delta: float) -> void:
	var player := _get_player()
	var input_axis := player.get_move_input()
	player.apply_horizontal_movement(input_axis)
	player.apply_gravity(delta)
	player.move_and_slide()
	player.tick_footsteps(delta, input_axis != 0.0)

	if not player.is_on_floor():
		state_machine.transition_to(&"Fall", {})
		return

	if player.is_dash_pressed():
		state_machine.transition_to(&"Cast", {"spell_id": &"veil_step"})
		return

	if _try_spell(player):
		return

	if player.is_attack_pressed():
		state_machine.transition_to(&"Attack", {})
		return

	if player.is_jump_pressed() or player.can_buffer_jump():
		state_machine.transition_to(&"Jump", {})
		return

	if input_axis == 0.0:
		state_machine.transition_to(&"Idle", {})


func _try_spell(player: Player) -> bool:
	var spell_id := player.get_spell_input()
	if spell_id == &"":
		return false
	state_machine.transition_to(&"Cast", {"spell_id": spell_id})
	return true


func _get_player() -> Player:
	return state_machine.get_parent() as Player
