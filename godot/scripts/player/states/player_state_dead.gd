extends State
## Player death — hold pose until game over screen handles respawn.


var _fade_tween: Tween


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	player.velocity = Vector2.ZERO
	player.set_invulnerable(true)
	player.play_animation(&"death", true)
	_fade_tween = player.create_tween()
	_fade_tween.tween_property(player.animated_sprite, "modulate", Color(0.4, 0.4, 0.4, 0.6), 1.0)


func exit() -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null


func _get_player() -> Player:
	return state_machine.get_parent() as Player
