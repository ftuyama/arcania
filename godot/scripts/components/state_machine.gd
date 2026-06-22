class_name StateMachine
extends Node
## Generic finite state machine. See docs/08-technical-architecture.md §17.

@export var initial_state: State

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
	if initial_state == null:
		var idle := get_node_or_null("Idle")
		if idle is State:
			initial_state = idle
		else:
			for child in get_children():
				if child is State:
					initial_state = child
					break
	if initial_state:
		current_state = initial_state
		current_state.enter({})


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition_to(state_name: StringName, payload: Dictionary = {}) -> void:
	if not states.has(state_name):
		push_error("StateMachine: unknown state %s" % state_name)
		return
	if current_state:
		current_state.exit()
	current_state = states[state_name]
	current_state.enter(payload)
