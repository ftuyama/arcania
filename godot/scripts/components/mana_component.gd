class_name ManaComponent
extends Node
## Mana pool, combat regen, and overcast spending.


signal mana_changed(current: float, maximum: float)
signal overcast_used(hp_cost: int)


@export var max_mana: int = 100
var current_mana: float = 100.0

var combat_regen_rate: float = 2.0
var regen_delay: float = 1.2
var _regen_timer: float = 0.0


func _ready() -> void:
	current_mana = float(max_mana)
	mana_changed.emit(current_mana, float(max_mana))


func _process(delta: float) -> void:
	if _regen_timer > 0.0:
		_regen_timer = maxf(_regen_timer - delta, 0.0)
		return
	if current_mana >= float(max_mana):
		return
	current_mana = minf(current_mana + combat_regen_rate * delta, float(max_mana))
	mana_changed.emit(current_mana, float(max_mana))


func can_afford(cost: int) -> bool:
	return current_mana >= float(cost)


func try_spend(cost: int, health: HealthComponent) -> bool:
	if cost <= 0:
		return true
	if current_mana >= float(cost):
		current_mana -= float(cost)
		_regen_timer = regen_delay
		mana_changed.emit(current_mana, float(max_mana))
		return true
	return _try_overcast(cost, health)


func _try_overcast(cost: int, health: HealthComponent) -> bool:
	if health == null:
		return false
	var threshold := int(float(health.max_hp) * 0.15)
	if health.current_hp <= threshold:
		return false
	var deficit := float(cost) - current_mana
	var hp_cost := maxi(int(deficit * 1.5), 5)
	health.take_damage(hp_cost, null)
	current_mana = 0.0
	_regen_timer = regen_delay
	overcast_used.emit(hp_cost)
	mana_changed.emit(current_mana, float(max_mana))
	return true


func restore_full() -> void:
	current_mana = float(max_mana)
	_regen_timer = 0.0
	mana_changed.emit(current_mana, float(max_mana))
