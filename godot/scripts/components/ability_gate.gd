extends Area2D
## Spell-gated obstacle. Clears when required spell is cast nearby or hits the gate.


@export var gate_id: StringName = &""
@export var required_spell: StringName = &"ember_sigil"
@export var gate_type: StringName = &"ember_receptor"
@export var proximity_radius: float = 96.0

@onready var _blocker: StaticBody2D = get_node_or_null("Blocker")
@onready var _visual: CanvasItem = get_node_or_null("Sprite")


func _ready() -> void:
	add_to_group(&"ability_gates")
	EventBus.spell_cast.connect(_on_spell_cast)


func _exit_tree() -> void:
	if EventBus.spell_cast.is_connected(_on_spell_cast):
		EventBus.spell_cast.disconnect(_on_spell_cast)


func _on_spell_cast(spell_id: StringName, caster: Node2D) -> void:
	if spell_id != required_spell:
		return
	if not SpellManager.has_spell(required_spell):
		return
	if caster == null:
		return
	if caster.global_position.distance_to(global_position) > proximity_radius:
		return
	_clear_gate()


func on_hit_by_spell(spell_id: StringName, _hitbox: HitboxComponent) -> void:
	if spell_id != required_spell:
		return
	if not SpellManager.has_spell(required_spell):
		return
	_clear_gate()


func _clear_gate() -> void:
	if _blocker:
		_blocker.queue_free()
		_blocker = null
	if _visual and _visual is Sprite2D:
		(_visual as Sprite2D).modulate = Color(1.0, 0.45, 0.1, 0.9)
	elif _visual and _visual is ColorRect:
		(_visual as ColorRect).color = Color(1.0, 0.45, 0.1, 0.9)
	EventBus.ability_gate_cleared.emit(gate_id)
	set_deferred(&"monitoring", false)
