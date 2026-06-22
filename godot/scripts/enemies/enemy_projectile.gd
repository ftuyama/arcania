extends Area2D
## Simple enemy ranged projectile.


@export var speed: float = 280.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 8
var damage_type: StringName = &"physical"
var knockback: Vector2 = Vector2.ZERO

var _elapsed: float = 0.0

@onready var _hitbox: HitboxComponent = $HitboxComponent


func _ready() -> void:
	collision_layer = 16
	collision_mask = 32
	_hitbox.damage = damage
	_hitbox.damage_type = damage_type
	_hitbox.knockback_vector = knockback
	_hitbox.enable_hitbox()
	_hitbox.hit_landed.connect(_on_hit_landed)


func launch(from: Vector2, aim: Vector2, projectile_damage: int, type: StringName = &"physical") -> void:
	global_position = from
	direction = aim.normalized() if aim.length_squared() > 0.01 else Vector2.RIGHT
	damage = projectile_damage
	damage_type = type
	_hitbox.damage = damage
	_hitbox.damage_type = type
	_elapsed = 0.0
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()


func _on_hit_landed(_target: Node, _amount: int) -> void:
	queue_free()
