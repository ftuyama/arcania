class_name HurtboxComponent
extends Area2D
## Damage-receiving hurtbox. Forwards hits to a HealthComponent.


var owner_body: Node2D
var _health: HealthComponent
var _damage_multipliers: Dictionary = {}


func _ready() -> void:
	owner_body = get_parent() as Node2D
	_health = owner_body.get_node_or_null("HealthComponent") as HealthComponent
	monitoring = false
	monitorable = true


func set_damage_multipliers(multipliers: Dictionary) -> void:
	_damage_multipliers = multipliers


func receive_hit(hitbox: HitboxComponent) -> bool:
	if _health == null or _health.is_invulnerable:
		return false
	var multiplier := 1.0
	if _damage_multipliers.has(hitbox.damage_type):
		multiplier = float(_damage_multipliers[hitbox.damage_type])
	var final_damage := maxi(int(float(hitbox.damage) * multiplier), 1)
	var knockback := hitbox.knockback_vector
	if owner_body and owner_body.global_position.x < hitbox.global_position.x:
		knockback.x *= -1.0
	_health.apply_poise_damage(hitbox.poise_damage)
	_health.take_damage(final_damage, hitbox.get_parent(), knockback)
	if final_damage >= 10:
		CombatJuice.on_heavy_hit()
	return true
