extends StaticBody2D
## Breakable bark wall — opens a secret room when destroyed by melee or Ember Sigil.


@export var gate_id: StringName = &""
@export var max_hp: int = 30
@export var target_room_id: StringName = &""
@export var spawn_marker: StringName = &"default"

var _hp: int = 30
var _destroyed: bool = false

@onready var _blocker: CollisionShape2D = $CollisionShape2D
@onready var _visual: ColorRect = $Visual
@onready var _secret_door: Area2D = $SecretDoor


func _ready() -> void:
	add_to_group(&"ability_gates")
	_hp = max_hp
	collision_layer = 1
	if gate_id and GameManager.is_gate_cleared(gate_id):
		_open(false)
		return
	EventBus.spell_cast.connect(_on_spell_cast)
	_secret_door.body_entered.connect(_on_secret_entered)
	_secret_door.monitoring = false


func _exit_tree() -> void:
	if EventBus.spell_cast.is_connected(_on_spell_cast):
		EventBus.spell_cast.disconnect(_on_spell_cast)
	if _secret_door.body_entered.is_connected(_on_secret_entered):
		_secret_door.body_entered.disconnect(_on_secret_entered)


func on_hit_by_spell(spell_id: StringName, _hitbox: HitboxComponent) -> void:
	if _destroyed:
		return
	if spell_id == &"ember_sigil":
		_take_hit(15)
		return
	GateFailureFeedback.try_emit(spell_id, &"ember_sigil")


func _on_spell_cast(spell_id: StringName, caster: Node2D) -> void:
	if _destroyed:
		return
	if caster == null or caster.global_position.distance_to(global_position) > 96.0:
		return
	if spell_id == &"ember_sigil":
		_take_hit(15)
		return
	GateFailureFeedback.try_emit(spell_id, &"ember_sigil")


func _take_hit(amount: int) -> void:
	_hp -= amount
	_visual.modulate = Color(1.0, 0.7, 0.5, 1.0)
	if _hp <= 0:
		_open(true)


func _open(emit_event: bool) -> void:
	if _destroyed:
		return
	_destroyed = true
	_blocker.set_deferred(&"disabled", true)
	_visual.visible = false
	_secret_door.monitoring = true
	if emit_event and not gate_id.is_empty():
		EventBus.ability_gate_cleared.emit(gate_id)


func _on_secret_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player") or target_room_id.is_empty():
		return
	GameManager.change_room(target_room_id, spawn_marker)
