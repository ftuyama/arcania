extends State
## Death animation and loot notification.


var _timer: float = 0.8


func enter(_payload: Dictionary) -> void:
	var enemy := _get_enemy()
	_timer = 0.8
	enemy.velocity = Vector2.ZERO
	enemy.collision_layer = 0
	enemy.animated_sprite.modulate = Color(0.35, 0.25, 0.2, 0.7)
	var data := enemy.get_data()
	if data:
		EventBus.enemy_defeated.emit(data.id, enemy.global_position)
		var player := enemy.get_player()
		if player:
			player.add_essence(data.essence_reward)


func physics_update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_get_enemy().queue_free()


func _get_enemy() -> BaseEnemy:
	return state_machine.get_parent() as BaseEnemy
