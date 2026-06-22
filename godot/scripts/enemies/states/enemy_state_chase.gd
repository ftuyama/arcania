extends State
## Chase the player until in attack range.


func physics_update(_delta: float) -> void:
	var enemy := _get_enemy()
	var data := enemy.get_data()
	var player := enemy.get_player()
	if player == null:
		state_machine.transition_to(&"Patrol", {})
		return

	var to_player := player.global_position - enemy.global_position
	var distance := to_player.length()
	if distance > data.detection_radius * 1.5:
		state_machine.transition_to(&"Patrol", {})
		return
	if distance <= data.attack_range:
		state_machine.transition_to(&"Attack", {})
		return

	enemy.face_player()
	enemy.play_animation(&"walk")
	enemy.velocity = to_player.normalized() * data.chase_speed
	enemy.move_and_slide()


func _get_enemy() -> BaseEnemy:
	return state_machine.get_parent() as BaseEnemy
