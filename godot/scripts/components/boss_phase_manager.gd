class_name BossPhaseManager
extends Node
## HP threshold phase transitions for bosses.


signal phase_changed(phase: int)
signal boss_defeated

@export var phase_thresholds: Array[float] = [0.5]

var current_phase: int = 0
var _health: HealthComponent
var _boss_id: StringName = &""
var _defeated: bool = false


func setup(health: HealthComponent, boss_id: StringName) -> void:
	_health = health
	_boss_id = boss_id
	_health.damaged.connect(_on_damaged)
	_health.died.connect(_on_died)


func get_phase_count() -> int:
	return phase_thresholds.size() + 1


func get_hp_ratio() -> float:
	if _health == null or _health.max_hp <= 0:
		return 1.0
	return float(_health.current_hp) / float(_health.max_hp)


func _on_damaged(_amount: int, _source: Node) -> void:
	if _defeated or _health == null:
		return
	var ratio := get_hp_ratio()
	var target_phase := 0
	for i in phase_thresholds.size():
		if ratio <= phase_thresholds[i]:
			target_phase = i + 1
	if target_phase > current_phase:
		current_phase = target_phase
		phase_changed.emit(current_phase)
		EventBus.boss_phase_changed.emit(_boss_id, current_phase)


func _on_died() -> void:
	if _defeated:
		return
	_defeated = true
	boss_defeated.emit()
	EventBus.boss_defeated.emit(_boss_id)
