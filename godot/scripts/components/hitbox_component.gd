class_name HitboxComponent
extends Area2D
## Damage-dealing hitbox. Enable only during attack frames.


signal hit_landed(target: Node, damage: int)

@export var damage: int = 10
@export var knockback_vector: Vector2 = Vector2.ZERO
@export var damage_type: StringName = &"physical"
@export var poise_damage: float = 5.0

var _hit_targets: Array[Node] = []

const _SHAPE_REACH: float = 16.0

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitoring = false
	monitorable = false


func configure_melee(facing: int, local_offset: Vector2 = Vector2(6.0, -6.0)) -> void:
	position = Vector2(local_offset.x * float(facing), local_offset.y)
	if _shape:
		_shape.position.x = _SHAPE_REACH * float(facing)


func enable_hitbox() -> void:
	_hit_targets.clear()
	monitoring = true
	call_deferred(&"_resolve_overlaps")


func disable_hitbox() -> void:
	monitoring = false


func _resolve_overlaps() -> void:
	if not monitoring:
		return
	for area in get_overlapping_areas():
		_on_area_entered(area)


func _on_area_entered(area: Area2D) -> void:
	if not area is HurtboxComponent:
		return
	var hurtbox := area as HurtboxComponent
	if hurtbox.owner_body in _hit_targets:
		return
	_hit_targets.append(hurtbox.owner_body)
	var applied := hurtbox.receive_hit(self)
	if applied:
		hit_landed.emit(hurtbox.owner_body, damage)
