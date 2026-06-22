extends Area2D
## Thin wall gate cleared by Arc Step blink through.


@export var gate_id: StringName = &""
@export var target_room_id: StringName = &""
@export var spawn_marker: StringName = &"default"
@export var proximity_radius: float = 80.0

var _cleared: bool = false

@onready var _blocker: StaticBody2D = $Blocker
@onready var _visual: ColorRect = $Visual
@onready var _passage: Area2D = $Passage


func _ready() -> void:
	add_to_group(&"ability_gates")
	if gate_id and GameManager.is_gate_cleared(gate_id):
		_clear(false)
		return
	EventBus.spell_cast.connect(_on_spell_cast)
	_passage.body_entered.connect(_on_passage_entered)
	_passage.monitoring = false


func _exit_tree() -> void:
	if EventBus.spell_cast.is_connected(_on_spell_cast):
		EventBus.spell_cast.disconnect(_on_spell_cast)
	if _passage.body_entered.is_connected(_on_passage_entered):
		_passage.body_entered.disconnect(_on_passage_entered)


func _on_spell_cast(spell_id: StringName, caster: Node2D) -> void:
	if _cleared:
		return
	if caster == null or caster.global_position.distance_to(global_position) > proximity_radius:
		return
	if spell_id == &"arc_step" and SpellManager.has_spell(&"arc_step"):
		_clear(true)
		return
	GateFailureFeedback.try_emit(spell_id, &"arc_step")


func _clear(emit_event: bool) -> void:
	if _cleared:
		return
	_cleared = true
	if _blocker:
		_blocker.queue_free()
	if _visual:
		_visual.visible = false
	_passage.monitoring = true
	if emit_event and not gate_id.is_empty():
		EventBus.ability_gate_cleared.emit(gate_id)


func _on_passage_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player") or target_room_id.is_empty():
		return
	GameManager.change_room(target_room_id, spawn_marker)
