extends State
## Dash — Veil Step with i-frames and phase-barrier pass-through.


var _elapsed: float = 0.0
var _iframe_duration: float = 0.0


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	_elapsed = 0.0
	_iframe_duration = float(player.get_dash_iframe_duration())
	player.velocity = Vector2(float(player.facing_direction) * Player.DASH_SPEED, 0.0)
	player.set_invulnerable(true)
	player.set_phasing(true)
	player.play_animation(&"dash", true)
	player.play_dash_sfx()


func exit() -> void:
	var player := _get_player()
	player.set_invulnerable(false)
	player.set_phasing(false)


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
