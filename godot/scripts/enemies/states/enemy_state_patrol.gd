extends State
## Slow patrol between local bounds.


func physics_update(delta: float) -> void:
	var enemy := _get_enemy()
	var data := enemy.get_data()
	var player := enemy.get_player()
	if player and enemy.global_position.distance_to(player.global_position) <= data.detection_radius:
		state_machine.transition_to(&"Chase", {})
		return

	var left := enemy.home_position.x + enemy.patrol_left
	var right := enemy.home_position.x + enemy.patrol_right
	var speed := data.move_speed * float(enemy.facing_direction)
	enemy.velocity = Vector2(speed, 0.0)
	enemy.move_and_slide()

	if enemy.global_position.x <= left:
		enemy.facing_direction = 1
	elif enemy.global_position.x >= right:
		enemy.facing_direction = -1
	enemy.update_facing()
	enemy.play_animation(&"walk")


func _get_enemy() -> BaseEnemy:
	return state_machine.get_parent() as BaseEnemy
