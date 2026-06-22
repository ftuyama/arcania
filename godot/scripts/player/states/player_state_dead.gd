extends State
## Player death — hold pose until game over screen handles respawn.


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	player.velocity = Vector2.ZERO
	player.set_invulnerable(true)
	player.animated_sprite.modulate = Color(0.4, 0.4, 0.4, 0.6)


func _get_player() -> Player:
	return state_machine.get_parent() as Player
