extends State
## Jump — upward impulse; transitions to Fall at apex.


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	player.velocity.y = Player.JUMP_VELOCITY
	player.consume_jump_buffer()
	player.play_animation(&"jump")
	player.play_jump_sfx()


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

	if player.velocity.y >= 0.0:
		state_machine.transition_to(&"Fall", {})


func _try_spell(player: Player) -> bool:
	var spell_id := player.get_spell_input()
	if spell_id == &"":
		return false
	state_machine.transition_to(&"Cast", {"spell_id": spell_id})
	return true


func _get_player() -> Player:
	return state_machine.get_parent() as Player
