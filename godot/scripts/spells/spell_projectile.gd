class_name SpellProjectile
extends Node2D
## Pooled spell projectile with fire damage.


@export var speed: float = 420.0
@export var lifetime: float = 1.2

var direction: Vector2 = Vector2.RIGHT
var spell_id: StringName = &"ember_bolt"
var _impact_sfx: AudioStream
var _elapsed: float = 0.0
var _active: bool = false

@onready var _hitbox: HitboxComponent = $HitboxComponent
@onready var _visual: AnimatedSprite2D = $Visual


func _ready() -> void:
	_hitbox.hit_landed.connect(_on_hitbox_hit)
	set_physics_process(false)
	visible = false


func launch(from: Vector2, aim: Vector2, spell: SpellData) -> void:
	global_position = from
	direction = aim.normalized() if aim.length_squared() > 0.01 else Vector2.RIGHT
	spell_id = spell.id
	_impact_sfx = spell.impact_sfx
	_hitbox.damage = spell.base_damage
	var mods := InventorySystem.get_aggregated_modifiers()
	if mods.has("burn_damage_mult"):
		_hitbox.damage = int(float(spell.base_damage) * float(mods["burn_damage_mult"]))
	_hitbox.damage_type = &"fire"
	_hitbox.knockback_vector = Vector2(140, -60)
	_elapsed = 0.0
	_active = true
	visible = true
	set_physics_process(true)
	_hitbox.enable_hitbox()
	_visual.play(&"effect")
	_visual.rotation = direction.angle()


func deactivate() -> void:
	_active = false
	visible = false
	set_physics_process(false)
	_hitbox.disable_hitbox()
	var pool := get_parent()
	if pool and pool.has_method(&"release"):
		pool.release(self)


func _physics_process(delta: float) -> void:
	if not _active:
		return
	global_position += direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		deactivate()


func _on_hitbox_hit(_target: Node, _damage: int) -> void:
	if not _active:
		return
	if _impact_sfx:
		AudioManager.play_sfx_stream(_impact_sfx, global_position)
	deactivate()
