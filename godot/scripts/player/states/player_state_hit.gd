extends State
## Hit stun with knockback and brief invulnerability.


var _timer: float = 0.0


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	var hit_iframes := int(ProjectSettings.get_setting("gameplay/hit_iframes", 20))
	_timer = float(hit_iframes) / 60.0
	player.set_invulnerable(true)


func exit() -> void:
	_get_player().set_invulnerable(false)


func physics_update(delta: float) -> void:
	var player := _get_player()
	_timer -= delta
	player.apply_gravity(delta)
	player.velocity.x = move_toward(player.velocity.x, 0.0, 600.0 * delta)
	player.move_and_slide()

	if _timer <= 0.0:
		if player.is_on_floor():
			state_machine.transition_to(&"Idle", {})
		else:
			state_machine.transition_to(&"Fall", {})


func _get_player() -> Player:
	return state_machine.get_parent() as Player
