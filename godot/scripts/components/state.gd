class_name State
extends Node
## Base class for StateMachine states.


var state_machine: StateMachine


func enter(_payload: Dictionary) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
