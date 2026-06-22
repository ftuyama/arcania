extends Node2D
## Spell-gated vine wall cleared by Rootbind.


@export var gate_id: StringName = &""
@export var required_spell: StringName = &"rootbind"


func _ready() -> void:
	add_to_group(&"ability_gates")
	EventBus.spell_cast.connect(_on_spell_cast)
	if gate_id.is_empty():
		gate_id = StringName(name)
	if GameManager.has_world_flag(StringName("gate_%s" % gate_id)):
		_clear_visual()


func _exit_tree() -> void:
	if EventBus.spell_cast.is_connected(_on_spell_cast):
		EventBus.spell_cast.disconnect(_on_spell_cast)


func _on_spell_cast(spell_id: StringName, caster: Node2D) -> void:
	if spell_id != required_spell:
		return
	if not SpellManager.has_spell(required_spell):
		return
	if caster == null or caster.global_position.distance_to(global_position) > 140.0:
		return
	_clear_gate()


func on_hit_by_spell(spell_id: StringName, _hitbox: HitboxComponent) -> void:
	if spell_id == required_spell:
		_clear_gate()


func _clear_gate() -> void:
	var blocker := get_node_or_null("Blocker")
	if blocker:
		blocker.queue_free()
	_clear_visual()
	EventBus.ability_gate_cleared.emit(gate_id)
	GameManager.set_world_flag(StringName("gate_%s" % gate_id))
	set_deferred(&"monitoring", false)


func _clear_visual() -> void:
	var visual := get_node_or_null("Sprite")
	if visual is Sprite2D:
		(visual as Sprite2D).modulate = Color(0.32, 0.62, 0.28, 0.5)
	elif visual is ColorRect:
		(visual as ColorRect).color = Color(0.32, 0.62, 0.28, 0.5)
