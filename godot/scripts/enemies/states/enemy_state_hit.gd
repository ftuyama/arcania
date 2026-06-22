extends State
## Brief stagger after taking damage.


var _timer: float = 0.35


func enter(_payload: Dictionary) -> void:
	_timer = 0.35
	_get_enemy().velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		state_machine.transition_to(&"Chase", {})


func _get_enemy() -> BaseEnemy:
	return state_machine.get_parent() as BaseEnemy
