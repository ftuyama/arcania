extends StaticBody2D
## Thin wall passable while the player is phasing (Veil Step / Arc Step).


@export var barrier_id: StringName = &""

var _collision_enabled: bool = true

@onready var _detector: Area2D = $Detector
@onready var _visual: ColorRect = $Visual


func _ready() -> void:
	add_to_group(&"phase_barriers")
	collision_layer = 1
	collision_mask = 0
	if _visual:
		_visual.color = Color(0.45, 0.35, 0.65, 0.55)


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		_restore_collision()
		return
	if player.is_phasing and _detector_overlaps_player(player):
		_disable_collision()
	else:
		_restore_collision()


func _detector_overlaps_player(player: Player) -> bool:
	if _detector == null:
		return false
	for body in _detector.get_overlapping_bodies():
		if body == player:
			return true
	return false


func _disable_collision() -> void:
	if not _collision_enabled:
		return
	_collision_enabled = false
	set_collision_layer_value(1, false)
	if _visual:
		_visual.modulate.a = 0.25


func _restore_collision() -> void:
	if _collision_enabled:
		return
	_collision_enabled = true
	set_collision_layer_value(1, true)
	if _visual:
		_visual.modulate.a = 0.55
