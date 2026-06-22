extends State
## Fall — gravity-driven descent until landing.


func enter(_payload: Dictionary) -> void:
	_get_player().play_animation(&"fall")


func physics_update(delta: float) -> void:
	var player := _get_player()
	var input_axis := player.get_move_input()
	player.apply_horizontal_movement(input_axis)
	player.apply_gravity(delta)
	player.move_and_slide()

	if player.is_dash_pressed():
		state_machine.transition_to(&"Cast", {"spell_id": &"veil_step"})
		return

	if player.is_attack_pressed():
		state_machine.transition_to(&"Attack", {})
		return

	if _try_spell(player):
		return

	if player.is_jump_pressed() and player.can_coyote_jump():
		state_machine.transition_to(&"Jump", {})
		return

	if player.is_on_floor():
		if player.can_buffer_jump():
			state_machine.transition_to(&"Jump", {})
		else:
			state_machine.transition_to(&"Idle", {})


func _try_spell(player: Player) -> bool:
	var spell_id := player.get_spell_input()
	if spell_id == &"":
		return false
	state_machine.transition_to(&"Cast", {"spell_id": spell_id})
	return true


func _get_player() -> Player:
	return state_machine.get_parent() as Player
