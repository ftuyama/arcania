extends State
## Dash — Veil Step placeholder with i-frames, no VFX yet.


var _elapsed: float = 0.0


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	_elapsed = 0.0
	player.velocity = Vector2(float(player.facing_direction) * Player.DASH_SPEED, 0.0)
	player.set_invulnerable(true)
	player.play_animation(&"dash")
	player.play_dash_sfx()


func exit() -> void:
	var player := _get_player()
	player.set_invulnerable(false)


func physics_update(delta: float) -> void:
	var player := _get_player()
	_elapsed += delta
	player.velocity = Vector2(float(player.facing_direction) * Player.DASH_SPEED, 0.0)
	player.move_and_slide()

	if _elapsed >= Player.DASH_DURATION:
		player.velocity.x = 0.0
		if player.is_on_floor():
			state_machine.transition_to(&"Idle", {})
		else:
			state_machine.transition_to(&"Fall", {})


func _get_player() -> Player:
	return state_machine.get_parent() as Player
