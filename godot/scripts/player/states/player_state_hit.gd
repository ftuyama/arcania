extends State
## Hit stun with knockback, recoil animation, and brief invulnerability.


var _timer: float = 0.0


func enter(payload: Dictionary) -> void:
	var player := _get_player()
	var hit_iframes := int(ProjectSettings.get_setting("gameplay/hit_iframes", 20))
	_timer = float(hit_iframes) / 60.0
	player.set_invulnerable(true)
	player.play_animation(&"hit", true)
	_apply_knockback(player, payload.get(&"source"))


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


func _apply_knockback(player: Player, source: Variant) -> void:
	var knock_x := -float(player.facing_direction) * 100.0
	if source is Node2D:
		var delta_x := player.global_position.x - (source as Node2D).global_position.x
		if absf(delta_x) > 1.0:
			knock_x = signf(delta_x) * 120.0
	player.velocity.x = knock_x
	player.velocity.y = -60.0


func _get_player() -> Player:
	return state_machine.get_parent() as Player
