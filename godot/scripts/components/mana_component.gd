class_name ManaComponent
extends Node
## Mana pool with Focus Shard segments, combat regen, and overcast spending.


signal mana_changed(current: float, maximum: float)
signal overcast_used(hp_cost: int)
signal focus_shards_changed(count: int, max_shards: int)

const MANA_PER_SHARD := 10
const BASE_SHARDS := 3
const MAX_SHARDS := 8

var focus_shard_count: int = BASE_SHARDS
var max_mana: int = BASE_SHARDS * MANA_PER_SHARD
var current_mana: float = float(BASE_SHARDS * MANA_PER_SHARD)

var combat_regen_rate: float = 2.0
var regen_delay: float = 1.2
var _regen_timer: float = 0.0


func _ready() -> void:
	_recalc_max_mana()
	current_mana = float(max_mana)
	mana_changed.emit(current_mana, float(max_mana))
	focus_shards_changed.emit(focus_shard_count, MAX_SHARDS)


func _recalc_max_mana() -> void:
	max_mana = focus_shard_count * MANA_PER_SHARD


func add_focus_shards(count: int) -> bool:
	if count <= 0 or focus_shard_count >= MAX_SHARDS:
		return false
	focus_shard_count = mini(focus_shard_count + count, MAX_SHARDS)
	_recalc_max_mana()
	current_mana = minf(current_mana + float(count * MANA_PER_SHARD), float(max_mana))
	mana_changed.emit(current_mana, float(max_mana))
	focus_shards_changed.emit(focus_shard_count, MAX_SHARDS)
	return true


func set_focus_shard_count(count: int) -> void:
	focus_shard_count = clampi(count, BASE_SHARDS, MAX_SHARDS)
	_recalc_max_mana()
	current_mana = minf(current_mana, float(max_mana))
	mana_changed.emit(current_mana, float(max_mana))
	focus_shards_changed.emit(focus_shard_count, MAX_SHARDS)


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
	_open_overcast_vulnerability(health)
	return true


func _open_overcast_vulnerability(health: HealthComponent) -> void:
	var owner := health.get_parent()
	if owner and owner.has_method(&"set_invulnerable"):
		owner.set_invulnerable(false)
	health.is_invulnerable = false
	get_tree().create_timer(0.3).timeout.connect(func() -> void:
		pass
	, CONNECT_ONE_SHOT)


func restore_full() -> void:
	current_mana = float(max_mana)
	_regen_timer = 0.0
	mana_changed.emit(current_mana, float(max_mana))
