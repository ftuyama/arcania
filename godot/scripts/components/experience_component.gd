class_name ExperienceComponent
extends Node
## Tracks Elara's earned experience and applies the agreed level-up rewards.


signal experience_changed(level: int, current_xp: int, xp_to_next_level: int)
signal leveled_up(level: int)

const STARTING_LEVEL := 1
const BASE_XP_TO_NEXT_LEVEL := 100
const XP_REQUIREMENT_INCREASE := 25
const HP_PER_LEVEL := 10
const MANA_PER_LEVEL := 10

var level: int = STARTING_LEVEL
var current_xp: int = 0


func _ready() -> void:
	var event_bus := _event_bus()
	if event_bus:
		event_bus.experience_awarded.connect(_on_experience_awarded)
	_emit_experience_changed()


func _exit_tree() -> void:
	var event_bus := _event_bus()
	if event_bus and event_bus.experience_awarded.is_connected(_on_experience_awarded):
		event_bus.experience_awarded.disconnect(_on_experience_awarded)


func get_xp_to_next_level() -> int:
	return BASE_XP_TO_NEXT_LEVEL + (level - STARTING_LEVEL) * XP_REQUIREMENT_INCREASE


func award_experience(amount: int) -> void:
	if amount <= 0:
		return
	current_xp += amount
	while current_xp >= get_xp_to_next_level():
		current_xp -= get_xp_to_next_level()
		level += 1
		_apply_level_up()
		_play_level_up_sfx()
		leveled_up.emit(level)
	_emit_experience_changed()


func set_progress(saved_level: int, saved_xp: int) -> void:
	level = maxi(saved_level, STARTING_LEVEL)
	current_xp = maxi(saved_xp, 0)
	while current_xp >= get_xp_to_next_level():
		current_xp -= get_xp_to_next_level()
		level += 1
	_emit_experience_changed()


func _on_experience_awarded(amount: int) -> void:
	award_experience(amount)


func _apply_level_up() -> void:
	var player := get_parent()
	if player == null or not player.has_node("HealthComponent") or not player.has_node("ManaComponent"):
		return
	var health := player.get_node("HealthComponent") as HealthComponent
	var mana := player.get_node("ManaComponent") as ManaComponent
	health.max_hp += HP_PER_LEVEL
	health.restore_full()
	mana.max_mana += MANA_PER_LEVEL
	mana.restore_full()


func _emit_experience_changed() -> void:
	experience_changed.emit(level, current_xp, get_xp_to_next_level())


func _play_level_up_sfx() -> void:
	if not is_inside_tree():
		return
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method(&"play_level_up"):
		audio_manager.play_level_up()


func _event_bus() -> Node:
	return get_node_or_null("/root/EventBus")
