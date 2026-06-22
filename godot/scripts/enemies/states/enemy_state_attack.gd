extends State
## Lunge attack with green telegraph (#52B788).


var _phase: int = 0
var _timer: float = 0.0


func enter(_payload: Dictionary) -> void:
	_phase = 0
	_timer = 0.5
	var enemy := _get_enemy()
	enemy.velocity = Vector2.ZERO
	enemy.telegraph.visible = true
	enemy.telegraph.modulate = Color(0.32, 0.72, 0.53, 0.9)


func exit() -> void:
	var enemy := _get_enemy()
	enemy.telegraph.visible = false
	enemy.hitbox_component.disable_hitbox()


func physics_update(delta: float) -> void:
	var enemy := _get_enemy()
	var data := enemy.get_data()
	var player := enemy.get_player()
	_timer -= delta

	if _phase == 0 and _timer <= 0.0:
		_phase = 1
		_timer = 0.18
		enemy.face_player()
		enemy.telegraph.visible = false
		enemy.hitbox_component.damage = data.attack_damage
		enemy.hitbox_component.damage_type = &"physical"
		enemy.hitbox_component.knockback_vector = Vector2(160.0 * float(enemy.facing_direction), -80.0)
		var offset := Vector2(20.0 * float(enemy.facing_direction), 0.0)
		enemy.hitbox_component.global_position = enemy.global_position + offset
		enemy.hitbox_component.enable_hitbox()
		enemy.velocity = Vector2(220.0 * float(enemy.facing_direction), -40.0)
	elif _phase == 1:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0.0, 800.0 * delta)
		enemy.move_and_slide()
		if _timer <= 0.0:
			enemy.hitbox_component.disable_hitbox()
			if player and enemy.global_position.distance_to(player.global_position) <= data.detection_radius:
				state_machine.transition_to(&"Chase", {})
			else:
				state_machine.transition_to(&"Patrol", {})


func _get_enemy() -> BaseEnemy:
	return state_machine.get_parent() as BaseEnemy
